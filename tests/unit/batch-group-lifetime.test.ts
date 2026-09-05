import { expect, test } from "bun:test";
import { MlxBatchExecutionGroup, type BatchRequest } from "../../src/backends/mlx/batch-group";
import { KVCache } from "../../src/model/gemma4-base";
import type { RuntimeModel } from "../../src/model/factory";
import type { PromptResponseTrace } from "../../src/serve/prompt-response-trace";
import { configureRuntime, createRuntimeConfig, runtimeValue } from "../../src/runtime-config";

function fixture() {
  const calls = { allocations: 0, disposals: 0, retains: 0 };
  class TrackedCache extends KVCache {
    override dispose() { calls.disposals++; super.dispose(); }
  }
  const model = {
    weightsBytes: 0,
    config: { modelType: "fixture", text: { numHiddenLayers: 1, layerTypes: ["full_attention"] } },
    makeCache() { calls.allocations++; return [new TrackedCache()]; },
  } as unknown as RuntimeModel;
  const request: BatchRequest = { promptIds: [0, 1], maxTokens: 1, eosTokenIds: [],
    sample() { throw new Error("unexpected sampling"); }, onToken() { throw new Error("unexpected output"); } };
  return { calls, model, request, TrackedCache };
}

test("admission callback failure rejects the removed request instead of losing it", async () => {
  const f = fixture();
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2 });
  try {
    await expect(group.submit({ ...f.request, onAdmitted() { throw new Error("admission failed"); } }))
      .rejects.toThrow("admission failed");
    expect(group.pendingRows).toBe(0);
    expect(f.calls.allocations).toBe(1); // constructor's empty prototype only
  } finally { await group.close(); }
});

test("lazy batch construction and admission execute under the captured runtime", async () => {
  const f = fixture();
  const seen: (string | undefined)[] = [];
  const makeCache = f.model.makeCache.bind(f.model);
  f.model.makeCache = () => { seen.push(runtimeValue("MLX_BUN_GRAMMAR")); return makeCache(); };
  const restore = configureRuntime({ MLX_BUN_GRAMMAR: "host" });
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2,
    runtime: createRuntimeConfig({ MLX_BUN_GRAMMAR: "bound" }),
  });
  try {
    await expect(group.submit({ ...f.request, onAdmitted() {
      seen.push(runtimeValue("MLX_BUN_GRAMMAR"));
      throw new Error("admission failed");
    } })).rejects.toThrow("admission failed");
    expect(seen).toEqual(["bound", "bound"]);
    expect(runtimeValue("MLX_BUN_GRAMMAR")).toBe("host");
  } finally { await group.close(); restore(); }
});

test("failure after prefix acquisition releases both caches and backing retention", async () => {
  const f = fixture();
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, promptCache: {
    take() { return { tokens: [0], caches: [new f.TrackedCache()], retain: () => { f.calls.retains++; } }; },
    put() { throw new Error("failed state must not be stored"); },
  } });
  const trace = { begin(phase: string) {
    return () => { if (phase === "prefill.batch_setup") throw new Error("setup failed"); };
  } } as unknown as PromptResponseTrace;
  try {
    await expect(group.submit({ ...f.request, trace })).rejects.toThrow("setup failed");
    expect(f.calls.disposals).toBe(2); // prototype plus acquired prefix
    expect(f.calls.retains).toBe(1);
    expect(group.activeRows + group.pendingRows).toBe(0);
  } finally { await group.close(); }
});

test("closing a drained group rejects queued requests and refuses further submission", async () => {
  const f = fixture();
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, admissionHeld: () => true });
  const pending = group.submit(f.request).then(() => null, (error: unknown) => error);
  await group.close();
  expect(await pending).toHaveProperty("message", "scheduler closed");
  await group.close();
  expect(f.calls.allocations).toBe(1);
  expect(group.pendingRows).toBe(0);
  await expect(group.submit(f.request)).rejects.toThrow("scheduler closed");
});
