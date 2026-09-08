import { expect, test } from "bun:test";
import { MlxBatchExecutionGroup, type BatchRequest } from "../../src/backends/mlx/batch-group";
import { KVCache } from "../../src/model/gemma4-base";
import { Qwen35Model } from "../../src/model/qwen3_5";
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
    config: { modelType: "fixture", text: { numHiddenLayers: 1, layerTypes: ["full_attention"],
      numGlobalKeyValueHeads: 1, globalHeadDim: 8, slidingWindow: 0 } },
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

test("continuous headroom refusal happens after cache take under the lease and releases ownership", async () => {
  const f = fixture();
  const events: string[] = [];
  let locked = false;
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2,
    lock: { async acquire() { locked = true; return () => { locked = false; }; } },
    promptCache: {
      take() {
        expect(locked).toBe(true);
        events.push("take");
        return { tokens: [0], caches: [new f.TrackedCache()], retain: () => { f.calls.retains++; } };
      },
      put() { throw new Error("failed state must not be stored"); },
    },
    memoryBudget: { usableBytes: 0, kvOptions: {}, promptCache: {
      totalBytes: 0,
      relievePressure(overBudget) {
        expect(locked).toBe(true);
        expect(overBudget()).toBe(true);
        events.push("pressure");
        return 0;
      },
    } },
  });
  try {
    await expect(group.submit(f.request)).rejects.toThrow("insufficient GPU headroom");
    expect(events).toEqual(["take", "pressure"]);
    expect(f.calls.disposals).toBe(2);
    expect(f.calls.retains).toBe(1);
    expect(group.activeRows + group.pendingRows).toBe(0);
  } finally { await group.close(); }
  expect(locked).toBe(false);
});

test("continuous forward failure restores the model's previous layer guard", async () => {
  const f = fixture();
  Object.setPrototypeOf(f.model, Qwen35Model.prototype);
  const model = f.model as Qwen35Model;
  const previous = () => {};
  model.prefillMemoryGuard = previous;
  model.forwardHidden = () => {
    expect(model.prefillMemoryGuard).not.toBe(previous);
    model.prefillMemoryGuard!();
    throw new Error("forward failed");
  };
  const group = new MlxBatchExecutionGroup(model, { maxBatch: 2,
    memoryBudget: { usableBytes: Number.MAX_SAFE_INTEGER, kvOptions: {},
      promptCache: { totalBytes: 0, relievePressure() { throw new Error("unexpected pressure"); } } },
  });
  try {
    await expect(group.submit(f.request)).rejects.toThrow("forward failed");
    expect(model.prefillMemoryGuard).toBe(previous);
    expect(f.calls.disposals).toBe(2);
  } finally { await group.close(); }
});
