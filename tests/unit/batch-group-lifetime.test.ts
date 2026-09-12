import { expect, test } from "bun:test";
import { MlxBatchExecutionGroup, type BatchRequest } from "../../src/backends/mlx/batch-group";
import * as ops from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";
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

test("an uncapped request reaches execution and an actual forward failure releases state", async () => {
  const f = fixture();
  const events: string[] = [];
  let locked = false;
  f.model.forwardHidden = () => { events.push("forward"); throw new Error("forward failed"); };
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
  });
  try {
    await expect(group.submit({ ...f.request, maxTokens: Infinity })).rejects.toThrow("forward failed");
    expect(events).toEqual(["take", "forward"]);
    expect(f.calls.disposals).toBe(2);
    expect(f.calls.retains).toBe(1);
    expect(group.activeRows + group.pendingRows).toBe(0);
  } finally { await group.close(); }
  expect(locked).toBe(false);
});

test("backend context and cache identity bind under the lease and release on admission failure", async () => {
  const f = fixture();
  let locked = false;
  const events: string[] = [];
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2,
    lock: { async acquire() { locked = true; return () => { locked = false; }; } },
  });
  try {
    await expect(group.submit({ ...f.request,
      cacheNamespace() { expect(locked).toBe(true); events.push("identity"); return "adapter@new"; },
      context: { key: "adapter", enter() {
        expect(locked).toBe(true); events.push("enter");
        return () => { events.push("leave"); };
      } },
      onAdmitted() { throw new Error("admission failed"); },
    })).rejects.toThrow("admission failed");
  } finally { await group.close(); }
  expect(events).toEqual(["identity", "enter", "leave"]);
  expect(locked).toBe(false);
});

function methodFixture(f: ReturnType<typeof fixture>, key: string, events: string[]) {
  return { key, data: null, open(host: import("../../src/backends/mlx/batch-group").MlxGroupMethodHost) {
    events.push(`open:${key}`);
    return {
      prepare(row: import("../../src/backends/mlx/batch-group").Row) {
        events.push(`prepare:${key}:${row.req.promptIds[0]}`);
        return { rows: [row], dispose() { events.push(`release:${row.req.promptIds[0]}`); },
          async advance() {
            if (row.req.promptIds[0] === -1) throw new Error("preparation failed");
            host.join(row);
            if (row.req.promptIds[0] === -2) throw new Error("admission cleanup failed");
            return true;
          } };
      },
      async advance() {
        events.push(`advance:${key}:${host.rows.length}`);
        const keep: number[] = [];
        for (const [index, row] of host.rows.entries()) {
          try {
            row.generated++;
            const more = await host.publish(row, row.req.promptIds[0]!);
            if (more === false || row.generated === row.req.maxTokens) host.finish(row, more === false ? "stop" : "length");
            else keep.push(index);
          } catch (error) { row.reject(error); }
        }
        host.filterRows(keep);
      },
      filterRows(keep: readonly number[]) { events.push(`filter:${key}:${keep.length}`); },
      dispose() { events.push(`dispose:${key}`); },
    };
  } };
}

test.each([undefined, 7])("ordinary prefill and method hosts share a captured chunk setting, explicit=%s", async explicit => {
  const f = fixture(), chunks: number[] = [], observed: number[] = [];
  f.model.forwardHidden = ids => { chunks.push(ids.shape[1]!); throw new Error("observed first chunk"); };
  const runtime = createRuntimeConfig({ MLX_BUN_RD_PREFILL_CHUNK: "3" });
  const ordinary = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, runtime, prefillChunkSize: explicit });
  const method = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, runtime, prefillChunkSize: explicit });
  const restore = configureRuntime({ MLX_BUN_RD_PREFILL_CHUNK: "99" });
  try {
    await expect(ordinary.submit({ ...f.request, promptIds: Array.from({ length: 12 }, (_, index) => index) }))
      .rejects.toThrow("observed first chunk");
    const bound = methodFixture(f, "prefill-policy", []);
    await method.submit({ ...f.request, maxTokens: 1, onToken() {}, method: {
      ...bound, open(host) { observed.push(host.prefillChunkSize); return bound.open(host); },
    } });
    expect(chunks).toEqual([explicit ?? 3]);
    expect(observed).toEqual(chunks);
    await expect(ordinary.submit({ ...f.request, prefillChunkSize: 5,
      promptIds: Array.from({ length: 12 }, (_, index) => index) })).rejects.toThrow("observed first chunk");
    expect(chunks).toEqual([explicit ?? 3, 5]);
  } finally { await ordinary.close(); await method.close(); restore(); }
});

test("one executor batches compatible methods and drains before changing method", async () => {
  const f = fixture(), events: string[] = [];
  const first = methodFixture(f, "first", events), second = methodFixture(f, "second", events);
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 4 });
  try {
    const result = await Promise.all([1, 2, 3, 4, 5].map((id) => group.submit({ ...f.request,
      method: id === 5 ? second : first, promptIds: [id], maxTokens: 3, onToken() {} })));
    expect(result.map(r => r.generatedTokens)).toEqual([3, 3, 3, 3, 3]);
    expect(events).toContain("advance:first:4");
    expect(events.indexOf("dispose:first")).toBeLessThan(events.indexOf("open:second"));
    expect(events.filter(e => e === "open:first")).toHaveLength(1);
    expect(group.activeRows + group.pendingRows).toBe(0);
  } finally { await group.close(); }
  expect(events.filter(e => e === "dispose:second")).toHaveLength(1);
});

test("method preparation and output failures leave sibling jobs running", async () => {
  const f = fixture(), events: string[] = [], output: number[] = [];
  const method = methodFixture(f, "shared", events);
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 4 });
  try {
    const result = await Promise.allSettled([-1, 1, 2].map(id => group.submit({ ...f.request,
      method, promptIds: [id], maxTokens: 3,
      onToken(token) { if (id === 1) throw new Error("consumer failed"); output.push(token); },
    })));
    expect(result[0]).toMatchObject({ status: "rejected", reason: { message: "preparation failed" } });
    expect(result[1]).toMatchObject({ status: "rejected", reason: { message: "consumer failed" } });
    expect(result[2]).toMatchObject({ status: "fulfilled", value: { generatedTokens: 3 } });
    expect(output).toEqual([2, 2, 2]);
    expect(events.filter(e => e === "release:-1")).toHaveLength(1);
    expect(group.activeRows + group.pendingRows).toBe(0);
  } finally { await group.close(); }
});

test("a method's first publication can flush before its next graph executes", async () => {
  const f = fixture();
  let flushed = false;
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 4 });
  try {
    const stats = await group.submit({ promptIds: [7], maxTokens: 2, eosTokenIds: [],
      onToken() { setImmediate(() => { flushed = true; }); },
      method: { key: "publishing", data: null, open(host) { return {
        prepare(row) { return { rows: [row], dispose() {}, async advance() {
          row.generated = 1; await host.publish(row, 7); host.join(row); return true;
        } }; },
        async advance() {
          expect(flushed).toBe(true);
          host.finish(host.rows[0]!, "stop"); host.filterRows([]);
        },
        filterRows() {}, dispose() {},
      }; } },
    });
    expect(stats.generatedTokens).toBe(1);
  } finally { await group.close(); }
});

test("published output flushes before preparation resumes its remaining state work", async () => {
  const f = fixture();
  let flushed = false;
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 4 });
  try {
    const stats = await group.submit({ promptIds: [7], maxTokens: 2, eosTokenIds: [],
      onToken() { setImmediate(() => { flushed = true; }); },
      method: { key: "staged", data: null, open(host) { return {
        prepare(row) {
          let published = false;
          return { rows: [row], dispose() {}, async advance() {
            if (!published) { row.generated = 1; await host.publish(row, 7); published = true; return false; }
            expect(flushed).toBe(true);
            host.join(row); return true;
          } };
        },
        async advance() { host.finish(host.rows[0]!, "stop"); host.filterRows([]); },
        filterRows() {}, dispose() {},
      }; } },
    });
    expect(stats.generatedTokens).toBe(1);
  } finally { await group.close(); }
});


test("failure after method state admission retires only the admitted row", async () => {
  const f = fixture(), events: string[] = [], output: number[] = [];
  const method = methodFixture(f, "shared", events);
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 4 });
  try {
    const result = await Promise.allSettled([-2, 2].map(id => group.submit({ ...f.request,
      method, promptIds: [id], maxTokens: 3, onToken(token) { output.push(token); },
    })));
    expect(result[0]).toMatchObject({ status: "rejected", reason: { message: "admission cleanup failed" } });
    expect(result[1]).toMatchObject({ status: "fulfilled", value: { generatedTokens: 3 } });
    expect(output).toEqual([2, 2, 2]);
    expect(events.filter(e => e === "release:-2")).toHaveLength(1);
    expect(group.activeRows + group.pendingRows).toBe(0);
  } finally { await group.close(); }
});

test("ordinary preparation admits a cohort before its first shared forward and rejects all members on failure", async () => {
  const f = fixture(), shapes: number[][] = [];
  f.model.forwardHidden = ids => { shapes.push([...ids.shape]); throw new Error("cohort forward failed"); };
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 3, prefillChunkSize: 4,
    lock: { async acquire() { return () => {}; } },
  });
  try {
    const results = await Promise.allSettled([6, 8, 10].map(length => group.submit({ ...f.request,
      promptIds: Array.from({ length }, (_, index) => index),
    })));
    for (const result of results) expect(result).toMatchObject({ status: "rejected", reason: { message: "cohort forward failed" } });
    expect(shapes).toEqual([[3, 4]]);
    expect(group.activeRows + group.pendingRows).toBe(0);
    expect(f.calls.disposals).toBe(f.calls.allocations);
  } finally { await group.close(); }
});


test("a request arriving during a forward joins the next prefill chunk", async () => {
  const f = fixture(), shapes: number[][] = [];
  let late: Promise<unknown> | undefined;
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, prefillChunkSize: 4 });
  f.model.forwardHidden = (ids, caches) => {
    shapes.push([...ids.shape]);
    if (shapes.length > 1) throw new Error("observed staggered batch");
    late = group.submit({ ...f.request, promptIds: Array(9).fill(2) }).catch(error => error);
    using kv = ops.zeros([1, 1, 4, 8], Dtype.float32);
    const [k, v] = caches[0]!.updateAndFetch(kv, kv); k.dispose(); v.dispose();
    return ops.zeros([1, 4, 8], Dtype.float32);
  };
  try {
    await expect(group.submit({ ...f.request, promptIds: Array(12).fill(1) }))
      .rejects.toThrow("observed staggered batch");
    expect(await late).toHaveProperty("message", "observed staggered batch");
    expect(shapes).toEqual([[1, 4], [2, 4]]);
    expect(group.activeRows + group.pendingRows).toBe(0);
    expect(f.calls.disposals).toBe(f.calls.allocations);
  } finally { await group.close(); }
});

test("a nearly completed prefill keeps its admission weight until it retires", async () => {
  const f = fixture(), shapes: number[][] = [];
  let late: Promise<unknown> | undefined;
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, prefillChunkSize: 4, prefillBatchTokenLimit: 20 });
  f.model.forwardHidden = (ids, caches) => {
    shapes.push([...ids.shape]);
    if (shapes.length > 1) throw new Error("observed separate preparation");
    late = group.submit({ ...f.request, promptIds: Array(9).fill(2) }).catch(error => error);
    using kv = ops.zeros([1, 1, 4, 8], Dtype.float32);
    const [k, v] = caches[0]!.updateAndFetch(kv, kv); k.dispose(); v.dispose();
    return ops.zeros([1, 4, 8], Dtype.float32);
  };
  try {
    await expect(group.submit({ ...f.request, promptIds: Array(12).fill(1) }))
      .rejects.toThrow("observed separate preparation");
    expect(await late).toHaveProperty("message", "observed separate preparation");
    // Remaining work would fit (8+9), but original work (12+9) does not.
    // The later request still reaches the same forward after the first retires.
    expect(shapes).toEqual([[1, 4], [1, 4], [1, 4]]);
    expect(group.activeRows + group.pendingRows).toBe(0);
    expect(f.calls.disposals).toBe(f.calls.allocations);
  } finally { await group.close(); }
});

test.each(["finish", "cancel", "consumer", "grammar"])("mixed work preserves row ownership and completion through %s", async mode => {
  const f = fixture();
  const { captureKvAttention } = await import("../../src/model/kv-attention-view");
  const { PromptResponseTrace } = await import("../../src/serve/prompt-response-trace");
  type TokenGroup = import("../../src/model/token-groups").TokenGroup;
  const shapes: number[][][] = [], outputs: number[][] = [[], [], []];
  const failures: unknown[] = [], siblings: Promise<unknown>[] = [];
  const controller = new AbortController();
  let accepted = 0, readied = 0;
  const grammar = { isTerminated: false, accept() { accepted++; }, async ready() { readied++; } } as unknown as NonNullable<BatchRequest["grammar"]>;
  const forward: RuntimeModel["forwardHidden"] = (ids, caches) => {
    const [batch, count] = ids.shape;
    using reshaped = ops.reshape(ids, [batch!, 1, count!, 1]);
    using zeros = ops.zeros([batch!, 1, count!, 8], Dtype.float32);
    using expanded = ops.add(reshaped, zeros);
    using kv = expanded.astype(Dtype.float32);
    for (const cache of caches) {
      const view = cache.attentionState?.appendAndFetch(kv, kv) ?? captureKvAttention(cache, kv, kv);
      view.dispose();
    }
    return ops.zeros([batch!, count!, 8], Dtype.float32);
  };
  f.model.forwardHidden = forward;
  f.model.logitsFromHidden = hidden => ops.copyOf(hidden);
  (f.model as RuntimeModel & { forwardHiddenMixed(groups: readonly TokenGroup[]): import("../../src/mlx/array").MlxArray[] }).forwardHiddenMixed = groups => {
    shapes.push(groups.map(group => [...group.ids.shape]));
    return groups.map(group => forward(group.ids, group.cache));
  };
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 4, prefillChunkSize: 32,
    runtime: createRuntimeConfig({ MLX_BUN_MIXED_PREFILL: "1", MLX_BUN_MIXED_TOKEN_BUDGET: "9" }) });
  const request = (index: number): BatchRequest => ({
    promptIds: Array.from({ length: index ? 31 + index : 5 }, (_, t) => t + index * 100),
    maxTokens: index ? 3 : 12, eosTokenIds: [], sample: logits => ops.argmaxAxis(logits, -1),
    signal: index === 1 ? controller.signal : undefined,
    grammar: mode === "grammar" && index === 0 ? grammar : undefined,
    trace: new PromptResponseTrace({ traceId: `mixed-${index}`, requestId: `${index}`, route: "test", emit() {} }),
    onToken(token) {
      outputs[index]!.push(token);
      if (index === 0 && outputs[0]!.length === 1) {
        for (const sibling of [1, 2]) siblings.push(group.submit(request(sibling)).catch(error => { failures.push(error); return error; }));
      }
      if (index === 0 && outputs[0]!.length === 2 && mode === "cancel") controller.abort(new Error("cancelled"));
      if (index === 1 && mode === "consumer") throw new Error("consumer failed");
    },
  });
  try {
    const first = await group.submit(request(0));
    await Promise.all(siblings);
    expect(first.generatedTokens).toBe(12);
    expect(outputs[0]).toHaveLength(12); expect(outputs[2]).toHaveLength(3);
    expect(outputs[1]).toHaveLength(mode === "cancel" ? 0 : mode === "consumer" ? 1 : 3);
    expect(failures).toHaveLength(mode === "cancel" || mode === "consumer" ? 1 : 0);
    if (mode === "grammar") { expect(accepted).toBeGreaterThan(0); expect(readied).toBeGreaterThan(0); }
    expect(shapes.length).toBeGreaterThan(0);
    expect(shapes.every(groups => groups.reduce((sum, [b, n]) => sum + b! * n!, 0) <= 9)).toBe(true);
    expect(group.activeRows + group.pendingRows).toBe(0);
  } finally { await group.close(); }
});
