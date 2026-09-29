import { expect, spyOn, test } from "bun:test";
import { generateAutoregressive } from "../../src/generation/index";
import { bindLegacyAutoregressiveModel } from "../../src/generation/bindings/autoregressive";
import { stepKey } from "../../src/sampling/sampler";
import { bindGrammarGroupRequests } from "../../src/execution/grammar-group";
import { MlxBatchExecutionGroup } from "../../src/execution/batch-group";
import { type BatchRequest } from "../../src/execution/batch-types";
import * as ops from "@mlx-bun/mlx/ops";
import { MlxArray } from "@mlx-bun/mlx/array";
import { disposeResources } from "../../src/runtime/resources";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { KVCache } from "../../src/state/kv";
import type { RuntimeModel } from "../../src/models/factory";
import type { PromptResponseTrace } from "../../src/runtime/trace";
import { configureRuntime, createRuntimeConfig, runtimeValue } from "../../src/runtime/config";
import { declareGraph } from "../../src/models/capabilities";

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
    // Its one layer's keys and values are read plain (updateAndFetch).
    requiredDenseKvLayers: [0], graphCapabilities: declareGraph({ kv: { denseReads: true } }),
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
  return { key, data: null, open(host: import("../../src/execution/batch-types").MlxGroupMethodHost) {
    events.push(`open:${key}`);
    return {
      prepare(row: import("../../src/execution/batch-types").Row) {
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

test("forward-state compatibility groups rows independently of method and cache policy", async () => {
  const f = fixture(), groups: Array<Array<string | undefined>> = [];
  const bound = methodFixture(f, "same-method", []);
  let held = true;
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 4, admissionHeld: () => held });
  const method = { ...bound, open(host: Parameters<typeof bound.open>[0]) {
    const active = bound.open(host);
    return { ...active, async advance() {
      groups.push(host.rows.map(row => row.req.promptInput?.decodeState?.key));
      await active.advance();
    } };
  } };
  const unused = (): never => { throw new Error("fixture method owns forwarding"); };
  try {
    const requests = ["grid-a", "grid-a", undefined, "grid-b", "grid-b"].map((key, row) =>
      group.submit({ ...f.request, promptIds: [row + 1], maxTokens: 4, onToken() {}, method,
        ...(key ? { promptInput: { forward: unused, decodeState: { key, forward: unused } } } : {}),
      }));
    held = false; group.kick();
    await Promise.all(requests);
    expect(groups.every(rows => new Set(rows).size === 1)).toBe(true);
    expect(groups.some(rows => rows.length === 2 && rows[0] === "grid-a")).toBe(true);
    expect(groups.some(rows => rows.length === 2 && rows[0] === "grid-b")).toBe(true);
    expect(groups.some(rows => rows.length === 1 && rows[0] === undefined)).toBe(true);
  } finally { await group.close(); }
});

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

test("automatic request chunks reach ordinary and grouped preparation without rewriting caller settings", async () => {
  const f = fixture(), chunks: number[] = [], methodChunks: (number | undefined)[] = [];
  Object.assign(f.model.config.text, { numHiddenLayers: 2, numAttentionHeads: 24,
    globalHeadDim: 256, headDim: 256, layerTypes: ["linear_attention", "full_attention"] });
  f.model.forwardHidden = ids => { chunks.push(ids.shape[1]!); throw new Error("observed chunk"); };
  const runtime = createRuntimeConfig({});
  const ordinary = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, runtime });
  const method = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, runtime });
  const request = { ...f.request, promptIds: Array.from({ length: 78_678 }, () => 0) };
  const bound = methodFixture(f, "auto-prefill", []);
  try {
    for (const override of [undefined, 512]) {
      await expect(ordinary.submit({ ...request, prefillChunkSize: override })).rejects.toThrow("observed chunk");
      await method.submit({ ...request, prefillChunkSize: override, maxTokens: 1, onToken() {}, method: {
        ...bound, open(host) {
          const active = bound.open(host);
          return { ...active, prepare(row) { methodChunks.push(row.req.prefillChunkSize); return active.prepare(row); } };
        },
      } });
    }
    expect(chunks).toEqual([256, 512]);
    expect(methodChunks).toEqual(chunks);
    expect(request.prefillChunkSize).toBeUndefined();
  } finally { await ordinary.close(); await method.close(); }
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
  const { captureKvAttention } = await import("../../src/state/kv-attention-view");
  const { PromptResponseTrace } = await import("../../src/runtime/trace");
  type TokenGroup = import("../../src/contracts/mlx/token-work").TokenGroup;
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
  (f.model as RuntimeModel & { forwardHiddenMixed(groups: readonly TokenGroup[]): import("@mlx-bun/mlx/array").MlxArray[] }).forwardHiddenMixed = groups => {
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


test("the forced-span binding requires the graph's dense-read layers as distinct indices within its caches", () => {
  const f = fixture();
  expect(() => bindGrammarGroupRequests(f.model, undefined as never, 1)).toThrow(TypeError);
  // The fixture's graph has one cache layer.
  for (const layers of [[-1], [0.5], [0, 0], [1]]) expect(() => bindGrammarGroupRequests(f.model, layers, 1), String(layers)).toThrow(RangeError);
  expect(bindGrammarGroupRequests(f.model, [0], 1)({}).key).toBe("grammar-forced-span");
});

function grammarGroupFixture() {
  const f = fixture();
  const forwards: { owner: number; ids: number[] }[] = [];
  const owners = new Map<import("../../src/contracts/mlx/cache").Cache, number>();
  f.model.forwardHidden = (ids, caches) => {
    const tokens = ids.toIntTokens();
    if (!owners.has(caches[0]!)) owners.set(caches[0]!, owners.size);
    forwards.push({ owner: owners.get(caches[0]!)!, ids: tokens });
    using kv = MlxArray.fromFloat32(new Float32Array(tokens.length * 8), [1, 1, tokens.length, 8]);
    const results = caches[0]!.updateAndFetch(kv, kv);
    for (const result of results) result.dispose();
    return MlxArray.fromFloat32(Float32Array.from(tokens), [1, tokens.length, 1]);
  };
  f.model.logitsFromHidden = hidden => {
    const ids = [...hidden.toFloat32Host()];
    const values = new Float32Array(ids.length * 16);
    ids.forEach((token, index) => { values[index * 16 + (token + 1) % 16] = 20; });
    return MlxArray.fromFloat32(values, [1, ids.length, 16]);
  };
  // The graph reads its one layer's keys and values plain. The binding keeps
  // its own copy: a layer the caller adds later would refuse every row.
  const layers = [0], method = bindGrammarGroupRequests(f.model, layers, 1);
  layers.push(1);
  const request = (forcedIds: number[], terminal = false, overrides: import("../../src/generation/index").GenerateOptions = {}) => {
    let jumped = false, terminated = false, disposed = 0;
    const accepted: number[] = [], tokens: number[] = [];
    const grammar = {
      get isTerminated() { return terminated; }, ready: async () => {},
      applyMask: (scores: import("@mlx-bun/mlx/array").MlxArray) => scores,
      accept(token: number) { accepted.push(token); },
      jumpForward(budget: number) {
        if (jumped || budget < 2) return null;
        jumped = true;
        const ids = forcedIds.slice(0, budget);
        accepted.push(...ids); terminated = terminal && ids.length === forcedIds.length;
        return ids;
      },
      dispose() { disposed++; },
    } as unknown as import("../../src/sampling/grammar").GrammarController;
    const options = { temperature: 0, ...overrides, grammar };
    return { grammar, options, accepted, tokens, get disposed() { return disposed; },
      input: { promptIds: [0, 1], maxTokens: overrides.maxTokens ?? 6, eosTokenIds: [], grammar,
        method: method(options), onToken(token: number) { tokens.push(token); } } satisfies BatchRequest };
  };
  return { ...f, forwards, request };
}

for (const cancel of ["none", "callback-false", "abort-false", "abort-last"] as const) {
  test(`shared forced grammar spans preserve ownership and peers: ${cancel}`, async () => {
    const f = grammarGroupFixture(), first = f.request([3, 4], true), peer = f.request([3, 4, 5], true);
    const stored: { tokens: number[]; caches: import("../../src/contracts/mlx/cache").Cache[] }[] = [];
    const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, prefillChunkSize: 1,
      promptCache: { take: () => null, put(tokens, caches) { stored.push({ tokens: [...tokens], caches }); } } });
    const abort = new AbortController(), reason = new Error("cancel forced publication");
    let simultaneous = false;
    const matchers = [first.grammar, peer.grammar];
    try {
      const a = group.submit({ ...first.input, signal: abort.signal, onToken(token) {
        simultaneous ||= group.activeRows === 2;
        expect(f.forwards.some(call => JSON.stringify(call.ids) === "[2,3,4]")).toBe(true);
        first.tokens.push(token);
        if (cancel === "callback-false") return false;
        if (cancel === "abort-false") { abort.abort(reason); return false; }
        if (cancel === "abort-last" && token === 4) abort.abort(reason);
      } }).then(stats => ({ stats, error: undefined }), error => ({ stats: undefined, error }));
      const b = group.submit(peer.input);
      const [outcome, survivor] = await Promise.all([a, b]);
      expect(simultaneous).toBe(true);
      expect(peer.tokens).toEqual([2, 3, 4, 5]);
      expect(survivor).toMatchObject({ generatedTokens: 4, finishReason: "stop" });
      if (cancel.startsWith("abort")) {
        expect(outcome.error).toBe(reason); expect(outcome.stats).toBeUndefined();
        expect(stored).toHaveLength(1);
      } else {
        expect(outcome.error).toBeUndefined();
        expect(outcome.stats).toMatchObject({ generatedTokens: cancel === "none" ? 3 : 1, finishReason: "stop" });
        expect(stored).toHaveLength(2);
        expect(stored.some(entry => JSON.stringify(entry.tokens) === "[0,1,2,3,4]")).toBe(true);
      }
      for (const entry of stored) expect(entry.caches[0]!.offset).toBe(entry.tokens.length);
      expect(first.disposed + peer.disposed).toBe(0); // borrowed matchers
      const again = f.request([3, 4], true);
      matchers.push(again.grammar);
      const recovered = await group.submit(again.input);
      expect(again.tokens).toEqual([2, 3, 4]);
      expect(recovered.generatedTokens).toBe(3);
      expect(group.activeRows + group.pendingRows).toBe(0);
    } finally {
      try { await group.close(); }
      finally {
        disposeResources([...stored.flatMap(entry => entry.caches), ...matchers]);
      }
    }
    expect(f.calls.disposals).toBe(f.calls.allocations);
  });
}

test("forced-span pending disposal failure rejects without publishing final cache and leaves its peer usable", async () => {
  const f = grammarGroupFixture(), first = f.request([3, 4]), peer = f.request([3, 4, 5], true);
  const stored: { tokens: number[]; caches: import("../../src/contracts/mlx/cache").Cache[] }[] = [];
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, prefillChunkSize: 1,
    promptCache: { take: () => null, put(tokens, caches) { stored.push({ tokens: [...tokens], caches }); } } });
  const original = ops.asyncEvalAll;
  const failure = new Error("pending dispose failed");
  let injected = false;
  const mock = spyOn(ops, "asyncEvalAll").mockImplementation(arrays => {
    original(arrays);
    if (!injected && arrays.length === 1 && arrays[0]!.toIntTokens()[0] === 5) {
      injected = true;
      const array = arrays[0]!, dispose = array.dispose.bind(array);
      array.dispose = () => { array.dispose = dispose; dispose(); throw failure; };
    }
  });
  try {
    const failed = group.submit({ ...first.input, onToken() { return false; } })
      .then(() => null, error => error);
    const survived = group.submit(peer.input);
    expect(await failed).toBe(failure);
    expect(await survived).toMatchObject({ generatedTokens: 4, finishReason: "stop" });
    expect(injected).toBe(true);
    expect(stored).toHaveLength(1);
    expect(stored[0]!.tokens).toEqual([0, 1, 2, 3, 4, 5]);
  } finally {
    try { await group.close(); }
    finally {
      mock.mockRestore();
      for (const entry of stored) for (const cache of entry.caches) cache.dispose();
      first.grammar.dispose(); peer.grammar.dispose();
    }
  }
  expect(f.calls.allocations).toBe(f.calls.disposals);
});


test("shared nonterminal grammar preserves seeded draw positions and committed processor history", async () => {
  const f = grammarGroupFixture();
  f.model.logitsFromHidden = hidden => MlxArray.fromFloat32(new Float32Array(hidden.shape[1]! * 16), [1, hidden.shape[1]!, 16]);
  const options = { seed: 42, temperature: 0.8, presencePenalty: 0.8, frequencyPenalty: 0.4,
    repetitionPenalty: 1.1, maxTokens: 6, eosTokenIds: [], prefillChunkSize: 1,
    decodePolicy: { compiledDecode: false, grammarJump: true } };
  const direct = f.request([3, 4], false, options), grouped = f.request([3, 4], false, options);
  let lane: "direct" | "grouped" = "direct";
  const captures = { direct: [] as { key: number[]; scores: number[] }[], grouped: [] as { key: number[]; scores: number[] }[] };
  const categorical = ops.randomCategorical;
  const mock = spyOn(ops, "randomCategorical").mockImplementation((scores, key) => {
    captures[lane].push({ key: key!.toIntTokens(), scores: [...scores.toFloat32Host()] });
    return categorical(scores, key);
  });
  const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, prefillChunkSize: 1 });
  try {
    const generation = generateAutoregressive(bindLegacyAutoregressiveModel(f.model), direct.input.promptIds, direct.options);
    for await (const { token } of generation) direct.tokens.push(token);
    const directForwards = f.forwards.splice(0).map(call => call.ids);
    lane = "grouped";
    const stats = await group.submit(grouped.input);
    expect(stats).toMatchObject({ generatedTokens: 6, finishReason: "length" });
    expect(grouped.tokens).toEqual(direct.tokens);
    expect(grouped.accepted).toEqual(direct.accepted);
    expect(f.forwards.map(call => call.ids)).toEqual(directForwards);
    expect(captures.grouped).toEqual(captures.direct);
    const expected = [0, 3, 4, 5].map(step => { using key = stepKey(42, step); return key.toIntTokens(); });
    expect(captures.grouped.map(sample => sample.key)).toEqual(expected);
    const untouched = Array.from({ length: 16 }, (_, id) => id)
      .find(id => ![0, 1, grouped.tokens[0]!, 3, 4].includes(id))!;
    for (const forced of [3, 4]) {
      const before = captures.grouped[0]!.scores, after = captures.grouped[1]!.scores;
      expect(after[forced]! - after[untouched]!).toBeLessThan(before[forced]! - before[untouched]!);
    }
  } finally {
    try { await group.close(); }
    finally { mock.mockRestore(); grouped.grammar.dispose(); }
  }
  expect(f.calls.allocations).toBe(f.calls.disposals);
});

for (const maxTokens of [1, 3]) {
  test(`shared grammar respects the exact remaining token budget: ${maxTokens}`, async () => {
    const f = grammarGroupFixture(), row = f.request([3, 4, 5], false, { maxTokens });
    const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, prefillChunkSize: 1 });
    try {
      expect(await group.submit(row.input)).toMatchObject({ generatedTokens: maxTokens, finishReason: "length" });
      expect(row.tokens).toEqual(maxTokens === 1 ? [2] : [2, 3, 4]);
      expect(row.accepted).toEqual(maxTokens === 1 ? [] : [2, 3, 4]);
      expect(f.forwards.map(call => call.ids)).toEqual(maxTokens === 1 ? [[0], [1]] : [[0], [1], [2, 3, 4]]);
      expect(row.disposed).toBe(0);
    } finally { try { await group.close(); } finally { row.grammar.dispose(); } }
    expect(f.calls.allocations).toBe(f.calls.disposals);
  });
}


for (const failCleanup of [false, true]) {
  test(`shared grammar cleans cancellation between advances before settling: cleanup failure ${failCleanup}`, async () => {
    const f = grammarGroupFixture(), cancelled = f.request([3, 4]), peer = f.request([3, 4, 5], true);
    peer.input.promptIds = [8, 1];
    const abort = new AbortController(), reason = new Error("abort between advances"), cleanup = new Error("cancelled cache cleanup failed");
    let owner: KVCache | undefined, releases = 0;
    const forward = f.model.forwardHidden.bind(f.model);
    f.model.forwardHidden = (ids, caches) => {
      const hidden = forward(ids, caches);
      if (!owner) {
        owner = caches[0] as KVCache;
        const dispose = owner.dispose.bind(owner);
        owner.dispose = () => { releases++; dispose(); if (failCleanup) throw cleanup; };
      } else if (ids.toIntTokens()[0] === 8) abort.abort(reason);
      return hidden;
    };
    const group = new MlxBatchExecutionGroup(f.model, { maxBatch: 2, prefillChunkSize: 1 });
    try {
      const first = group.submit({ ...cancelled.input, signal: abort.signal }).then(() => null, error => {
        expect(releases).toBe(1);
        expect(owner!.keys).toBeNull(); expect(owner!.values).toBeNull();
        return error;
      });
      const second = group.submit(peer.input);
      const error = await first;
      if (failCleanup) {
        expect(error).toBeInstanceOf(AggregateError);
        expect(error.errors).toEqual([reason, cleanup]);
      } else expect(error).toBe(reason);
      expect(cancelled.tokens).toEqual([]);
      expect(await second).toMatchObject({ generatedTokens: 4, finishReason: "stop" });
      expect(peer.tokens).toEqual([2, 3, 4, 5]);
      expect(group.activeRows + group.pendingRows).toBe(0);
    } finally {
      try { await group.close(); }
      finally { cancelled.grammar.dispose(); peer.grammar.dispose(); }
    }
    expect(f.calls.allocations).toBe(f.calls.disposals);
  });
}
