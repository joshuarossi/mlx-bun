import { expect, test } from "bun:test";
import { generateAutoregressive } from "../../src/generate";
import type { MlxAutoregressiveBinding } from "../../src/backends/mlx/autoregressive";
import { bindMlxGraph } from "../../src/backends/mlx/graph";
import { KVCache, type Cache } from "../../src/model/gemma4";
import { MlxArray } from "../../src/mlx/array";
import { configureRuntime, createRuntimeConfig, runtimeValue } from "../../src/runtime-config";

function fixture() {
  const seen = { forwards: 0, steps: 0, allocations: 0, disposals: 0 };
  function advance(state: Cache[], length: number) {
    const kv = MlxArray.fromFloat32(new Float32Array(length * 4), [1, 1, length, 4]);
    try {
      const outputs = state[0]!.updateAndFetch(kv, kv);
      for (const output of outputs) output.dispose();
    } finally { kv.dispose(); }
  }
  function logits(ids: readonly number[]) {
    const data = new Float32Array(ids.length * 8);
    ids.forEach((id, index) => { data[index * 8 + (id + 1) % 8] = 10; });
    return MlxArray.fromFloat32(data, [1, ids.length, 8]);
  }
  const binding: MlxAutoregressiveBinding = {
    graph: bindMlxGraph({
      forwardHidden(ids, state: Cache[]) {
        seen.forwards++;
        const tokens = ids.toIntTokens();
        advance(state, tokens.length);
        return MlxArray.fromFloat32(Float32Array.from(tokens), [1, tokens.length, 1]);
      },
      logitsFromHidden(hidden) { return logits([...hidden.toFloat32Host()]); },
    }, { id: "independent-fixture", artifact: "fixture", stateAbi: "legacy-cache-array-v1" }),
    memory: { weightsBytes: 0 }, eosTokenIds: [7],
    makeCache() {
      seen.allocations++;
      class OwnedCache extends KVCache {
        override dispose() { seen.disposals++; super.dispose(); }
      }
      return [new OwnedCache()];
    },
  };
  return { binding, seen, advance, logits };
}

async function run(binding: MlxAutoregressiveBinding) {
  const generation = generateAutoregressive(binding, [0, 1], {
    temperature: 0, maxTokens: 3, prefillChunkSize: 1,
  });
  const tokens: number[] = [];
  for await (const token of generation) tokens.push(token.token);
  return { tokens, cacheTokens: generation.stats!.cacheTokens };
}

test("an independent binding runs without a RuntimeModel or class-based dispatch", async () => {
  const { binding, seen } = fixture();
  expect(await run(binding)).toEqual({ tokens: [2, 3, 4], cacheTokens: [0, 1, 2, 3] });
  expect(seen).toEqual({ forwards: 4, steps: 0, allocations: 1, disposals: 1 });
});

test("prefill policy supplies the request default while explicit sizes take precedence", async () => {
  const captured: number[] = [];
  const policy = { chunkSize(length: number) { captured.push(length); return 2; } };
  const automatic = fixture(), explicit = fixture();
  for (const [source, override] of [[automatic, undefined], [explicit, 2]] as const) {
    const generation = generateAutoregressive({ ...source.binding, prefillPolicy: policy }, [0, 1, 2, 3], {
      temperature: 0, maxTokens: 2, prefillChunkSize: override,
    });
    const tokens = [];
    for await (const token of generation) tokens.push(token.token);
    expect(tokens).toEqual([4, 5]);
  }
  expect(captured).toEqual([4]);
  expect(automatic.seen).toEqual(explicit.seen);
});

for (const early of [undefined, false, true]) {
  const enabled = early !== false;
  test(`first-token scheduling uses the captured binding policy: early=${early}`, async () => {
    const { binding, seen } = fixture();
    const generation = generateAutoregressive({ ...binding,
      runtime: createRuntimeConfig({ MLX_BUN_EARLY_FIRST_TOKEN: early === undefined ? undefined : early ? "1" : "0" }),
    }, [0, 1], { temperature: 0, maxTokens: 5, prefillChunkSize: 1,
      logprobs: true, topLogprobs: 3 });
    const restore = configureRuntime({ MLX_BUN_EARLY_FIRST_TOKEN: enabled ? "0" : "1" });
    try {
      const iter = generation[Symbol.asyncIterator]();
      const first = await iter.next();
      expect(first.value).toMatchObject({ token: 2, index: 0 });
      expect(first.value?.logprobs).toBeDefined();
      expect(seen.forwards).toBe(enabled ? 2 : 3);
      await iter.return(undefined);
      expect(generation.stats!.generatedTokens).toBe(1);
      expect(generation.stats!.cacheTokens).toEqual(enabled ? [0, 1] : [0, 1, 2]);
      expect(seen.disposals).toBe(1);
    } finally { restore(); }
  });
}

test("an early consumer return aligns caller-owned caches before reuse", async () => {
  const { binding, seen } = fixture();
  const cache = binding.makeCache();
  try {
    const generation = generateAutoregressive({ ...binding,
      runtime: createRuntimeConfig({ MLX_BUN_EARLY_FIRST_TOKEN: "1" }),
    }, [0, 1], { cache, temperature: 0, maxTokens: 5, prefillChunkSize: 1 });
    const iter = generation[Symbol.asyncIterator]();
    expect((await iter.next()).value).toMatchObject({ token: 2, index: 0 });
    expect(seen.forwards).toBe(2);
    await iter.return(undefined);
    expect(seen.forwards).toBe(3);
    expect(generation.stats!.cacheTokens).toEqual([0, 1, 2]);
    expect(cache[0]!.offset).toBe(3);
    expect(seen.disposals).toBe(0);
  } finally { for (const c of cache) c.dispose(); }
});

test("an aborted early consumer return does not advance caller-owned caches", async () => {
  const { binding, seen } = fixture();
  const cache = binding.makeCache(), abort = new AbortController();
  try {
    const generation = generateAutoregressive({ ...binding,
      runtime: createRuntimeConfig({ MLX_BUN_EARLY_FIRST_TOKEN: "1" }),
    }, [0, 1], { cache, temperature: 0, maxTokens: 5, prefillChunkSize: 1, signal: abort.signal });
    const iter = generation[Symbol.asyncIterator]();
    await iter.next(); abort.abort(); await iter.return(undefined);
    expect(seen.forwards).toBe(2);
    expect(cache[0]!.offset).toBe(2);
  } finally { for (const c of cache) c.dispose(); }
});

test("retained-cache alignment failures close the decoder and publish no final stats", async () => {
  const { binding, seen } = fixture();
  const cache = binding.makeCache();
  let closed = 0;
  const forward = binding.graph.forwardHidden.bind(binding.graph);
  try {
    const generation = generateAutoregressive({ ...binding,
      graph: { ...binding.graph, async forwardHidden(...args) {
        if (seen.forwards === 2) throw new Error("alignment forward failed");
        return forward(...args);
      } },
      createDecode: () => ({ tryStep: () => null, close() { closed++; } }),
      runtime: createRuntimeConfig({ MLX_BUN_EARLY_FIRST_TOKEN: "1" }),
    }, [0, 1], { cache, temperature: 0, maxTokens: 5, prefillChunkSize: 1 });
    const iter = generation[Symbol.asyncIterator]();
    await iter.next();
    await expect(iter.return(undefined)).rejects.toThrow("alignment forward failed");
    expect(closed).toBe(1);
    expect(generation.stats).toBeNull();
    expect(seen.disposals).toBe(0);
  } finally { for (const c of cache) c.dispose(); }
});

for (const maxTokens of [1, 2, 3]) {
  test(`early first-token yield preserves the ${maxTokens}-token budget`, async () => {
    const { binding, seen } = fixture();
    const generation = generateAutoregressive({ ...binding,
      runtime: createRuntimeConfig({ MLX_BUN_EARLY_FIRST_TOKEN: "1" }),
    }, [0, 1], { temperature: 0, maxTokens, prefillChunkSize: 1 });
    const emitted = [];
    for await (const token of generation) emitted.push([token.index, token.token]);
    expect(emitted).toEqual([[0, 2], [1, 3], [2, 4]].slice(0, maxTokens));
    expect(generation.stats!.generatedTokens).toBe(maxTokens);
    expect(generation.stats!.cacheTokens).toEqual([0, 1, ...[2, 3].slice(0, maxTokens - 1)]);
    expect(seen.disposals).toBe(1);
  });
}

test("cancellation after an early first yield starts no further forward", async () => {
  const { binding, seen } = fixture();
  const abort = new AbortController();
  const generation = generateAutoregressive({ ...binding,
    runtime: createRuntimeConfig({ MLX_BUN_EARLY_FIRST_TOKEN: "1" }),
  }, [0, 1], { temperature: 0, maxTokens: 5, prefillChunkSize: 1, signal: abort.signal });
  const iter = generation[Symbol.asyncIterator]();
  expect((await iter.next()).value).toMatchObject({ token: 2, index: 0 });
  abort.abort(new Error("cancelled at first yield"));
  await expect(iter.next()).rejects.toThrow("cancelled at first yield");
  expect(seen.forwards).toBe(2);
  expect(seen.disposals).toBe(1);
  expect(generation.stats).toBeNull(); // Aborted runs do not publish final stats.
});

test("an early first token precedes cancellation inside the following decode", async () => {
  const { binding, seen, advance, logits } = fixture();
  const abort = new AbortController();
  let closed = 0;
  const generation = generateAutoregressive({ ...binding,
    runtime: createRuntimeConfig({ MLX_BUN_EARLY_FIRST_TOKEN: "1" }),
    createDecode: () => ({ close() { closed++; }, tryStep(token, state) {
      seen.steps++;
      advance(state, 1);
      abort.abort(new Error("cancelled in next decode"));
      return { logits: logits(token.toIntTokens()), evalWith: [] };
    } }),
  }, [0, 1], { temperature: 0, maxTokens: 5, prefillChunkSize: 1, signal: abort.signal });
  const iter = generation[Symbol.asyncIterator]();
  expect((await iter.next()).value).toMatchObject({ token: 2, index: 0 });
  expect(abort.signal.aborted).toBe(false);
  await expect(iter.next()).rejects.toThrow("cancelled in next decode");
  expect(seen.steps).toBe(1);
  expect(seen.disposals).toBe(1);
  expect(closed).toBe(1);
});

test("an initial EOS remains invisible and counted with early first-token scheduling", async () => {
  const { binding, seen } = fixture();
  const generation = generateAutoregressive({ ...binding,
    runtime: createRuntimeConfig({ MLX_BUN_EARLY_FIRST_TOKEN: "1" }),
  }, [5, 6], { temperature: 0, maxTokens: 5, prefillChunkSize: 1 });
  const tokens = [];
  for await (const token of generation) tokens.push(token.token);
  expect(tokens).toEqual([]);
  expect(generation.stats!.generatedTokens).toBe(1);
  expect(generation.stats!.finishReason).toBe("stop");
  expect(seen.disposals).toBe(1);
});

test("bound kernels and early-close cleanup retain runtime settings across consumer awaits", async () => {
  const { binding, seen } = fixture();
  const observed: string[] = [];
  const forward = binding.graph.forwardHidden.bind(binding.graph);
  const generation = generateAutoregressive({ ...binding,
    runtime: createRuntimeConfig({ MLX_BUN_GRAMMAR: "bound" }),
    memory: { weightsBytes: 0, expertRuntime: { plan: { plannedBytes: 0 }, flushUsage() {
      observed.push(`cleanup:${runtimeValue("MLX_BUN_GRAMMAR")}`);
    } } },
    graph: { ...binding.graph, async forwardHidden(ids, state) {
      observed.push(`forward:${runtimeValue("MLX_BUN_GRAMMAR")}`);
      await Promise.resolve();
      observed.push(`await:${runtimeValue("MLX_BUN_GRAMMAR")}`);
      return forward(ids, state);
    } },
  }, [0, 1], { temperature: 0, maxTokens: 5, prefillChunkSize: 1 });
  const restore = configureRuntime({ MLX_BUN_GRAMMAR: "host" });
  try {
    const iter = generation[Symbol.asyncIterator]();
    expect((await iter.next()).done).toBe(false);
    await Promise.resolve();
    expect(runtimeValue("MLX_BUN_GRAMMAR")).toBe("host");
    await iter.return(undefined);
    expect(observed.length).toBeGreaterThan(2);
    expect(observed.every((value) => value.endsWith(":bound"))).toBe(true);
    expect(observed.at(-1)).toBe("cleanup:bound");
    expect(seen.disposals).toBe(1);
  } finally { restore(); }
});

test("a replacement binding supplies its own fused decoder to the same loop", async () => {
  const { binding, seen, advance, logits } = fixture();
  let setup = 0;
  const replacement: MlxAutoregressiveBinding = {
    ...binding,
    createDecode(policy) {
      setup++;
      expect(seen.forwards).toBe(2); // only after prefill
      expect(policy).toEqual({ hasAdapters: false, pagedKv: false });
      return { close() {}, tryStep(token, state) {
        seen.steps++;
        advance(state, 1);
        return { logits: logits(token.toIntTokens()), evalWith: [] };
      } };
    },
  };
  expect(await run(replacement)).toEqual({ tokens: [2, 3, 4], cacheTokens: [0, 1, 2, 3] });
  expect(setup).toBe(1);
  expect(seen).toEqual({ forwards: 2, steps: 2, allocations: 1, disposals: 1 });
});

test("a decoder can decline a step without advancing state", async () => {
  const { binding, seen } = fixture();
  const result = await run({ ...binding, createDecode: () => ({ close() {}, tryStep: () => null }) });
  expect(result.cacheTokens).toEqual([0, 1, 2, 3]);
  expect(seen.forwards).toBe(4);
});

test("a resolved disabled plan never constructs the bound compiled decoder", async () => {
  const { binding, seen } = fixture();
  const generation = generateAutoregressive({ ...binding,
    createDecode() { throw new Error("disabled decoder was constructed"); },
  }, [0, 1], {
    temperature: 0, maxTokens: 3, prefillChunkSize: 1,
    decodePolicy: { compiledDecode: false, grammarJump: false },
  });
  const tokens: number[] = [];
  for await (const token of generation) tokens.push(token.token);
  expect(tokens).toEqual([2, 3, 4]);
  expect(seen.disposals).toBe(1);
});

test("cancellation before execution allocates no cache", async () => {
  const { binding, seen } = fixture();
  const abort = new AbortController(); abort.abort(new Error("cancelled"));
  const generation = generateAutoregressive(binding, [0, 1], { signal: abort.signal });
  await expect(generation[Symbol.asyncIterator]().next()).rejects.toThrow("cancelled");
  expect(seen.allocations).toBe(0);
});

test("cancellation after a prefill chunk prevents the next chunk and releases its state", async () => {
  const { binding, seen } = fixture();
  const abort = new AbortController();
  const forward = binding.graph.forwardHidden.bind(binding.graph);
  const generation = generateAutoregressive({ ...binding, graph: { ...binding.graph,
    async forwardHidden(ids, state) {
      const hidden = await forward(ids, state);
      abort.abort(new Error("cancelled during prefill"));
      return hidden;
    },
  } }, [0, 1, 2, 3], { signal: abort.signal, prefillChunkSize: 1 });
  await expect(generation[Symbol.asyncIterator]().next()).rejects.toThrow("cancelled during prefill");
  expect(seen.forwards).toBe(1);
  expect(seen.disposals).toBe(1);
});

test("pipeline cancellation after decode dispatch emits no token and closes the decoder before state", async () => {
  const { binding, seen, advance, logits } = fixture();
  const abort = new AbortController();
  let closed = false;
  const generation = generateAutoregressive({ ...binding,
    runtime: createRuntimeConfig({ MLX_BUN_EARLY_FIRST_TOKEN: "0" }), createDecode: () => ({
    tryStep(token, state) {
      advance(state, 1);
      const result = { logits: logits(token.toIntTokens()), evalWith: [] };
      abort.abort(new Error("cancelled after dispatch"));
      return result;
    },
    close() { expect(seen.disposals).toBe(0); closed = true; },
  }) }, [0, 1], { signal: abort.signal, temperature: 0, maxTokens: 3, logprobs: true, topLogprobs: 2 });
  await expect(generation[Symbol.asyncIterator]().next()).rejects.toThrow("cancelled after dispatch");
  expect(closed).toBe(true);
  expect(seen.disposals).toBe(1);
});

test("cancellation during checkpoint persistence waits for its borrowed state before cleanup", async () => {
  const { binding, seen } = fixture();
  const abort = new AbortController();
  let start!: () => void, release!: () => void;
  const writing = new Promise<void>((resolve) => { start = resolve; });
  const finished = new Promise<void>((resolve) => { release = resolve; });
  const generation = generateAutoregressive(binding, [0, 1], {
    signal: abort.signal, temperature: 0, maxTokens: 3, checkpointEveryTokens: 1,
    async onDecodeCheckpoint(state) {
      expect(state.cacheTokens).toEqual([0, 1, 2]);
      expect(state.generatedTokens).toBe(1);
      expect(state.pendingToken).toBe(3);
      start(); await finished;
      expect(seen.disposals).toBe(0);
    },
  });
  const iterator = generation[Symbol.asyncIterator]();
  expect((await iterator.next()).value?.token).toBe(2);
  const next = iterator.next();
  await writing;
  abort.abort(new Error("cancelled during persistence"));
  expect(seen.disposals).toBe(0);
  release();
  await expect(next).rejects.toThrow("cancelled during persistence");
  expect(seen.disposals).toBe(1);
});

test("a replacement decoder's error is not retried through an unrelated graph", async () => {
  const { binding, seen } = fixture();
  const failure = new Error("decode failed after a native write");
  await expect(run({ ...binding, createDecode: () => ({ close() {}, tryStep: () => { throw failure; } }) }))
    .rejects.toThrow(failure);
  expect(seen.forwards).toBe(2);
  expect(seen.disposals).toBe(1);
});

test("incompatible backend/graph/state ABIs fail before cache construction", async () => {
  for (const mismatch of [{ backend: "other" }, { graphAbi: "other" }, { stateAbi: "other" }]) {
    const { binding, seen } = fixture();
    await expect(run({ ...binding, graph: { ...binding.graph,
      descriptor: { ...binding.graph.descriptor, ...mismatch },
    } })).rejects.toThrow(/incompatible.*ABI/);
    expect(seen.allocations).toBe(0);
  }
});

test("unsupported adapters and media fail before state allocation", async () => {
  const { binding, seen } = fixture();
  for (const options of [{ adapters: ["missing"] }, { promptEmbeddings: {} as MlxArray }]) {
    const generation = generateAutoregressive(binding, [0, 1], options);
    await expect((async () => { for await (const _token of generation) {} })())
      .rejects.toThrow(/does not support/);
  }
  expect(seen.allocations).toBe(0);
});

test("rejected initial state releases owned caches and preserves borrowed caches", async () => {
  const { binding, seen } = fixture();
  const invalid = { ...binding, makeCache() {
    const state = binding.makeCache();
    state[0]!.offset = 2;
    return state;
  } };
  await expect(run(invalid)).rejects.toThrow(/strict prefix/);
  expect(seen.disposals).toBe(1);
  const borrowed = invalid.makeCache();
  try {
    const generation = generateAutoregressive(binding, [0, 1], { cache: borrowed });
    await expect((async () => { for await (const _token of generation) {} })())
      .rejects.toThrow(/strict prefix/);
    expect(seen.disposals).toBe(1);
  } finally { for (const state of borrowed) state.dispose(); }
});

test("early return waits for decoder cleanup before releasing cache state", async () => {
  const { binding, seen } = fixture();
  let closes = 0;
  let release!: () => void;
  let started!: () => void;
  const closing = new Promise<void>((resolve) => { started = resolve; });
  const wait = new Promise<void>((resolve) => { release = resolve; });
  const generation = generateAutoregressive({ ...binding, createDecode: () => ({
    tryStep: () => null,
    async close() { closes++; started(); await wait; },
  }) }, [0, 1], { maxTokens: 4, temperature: 0 });
  const iterator = generation[Symbol.asyncIterator]();
  await iterator.next();
  const returning = iterator.return!(undefined);
  await closing;
  expect(seen.disposals).toBe(0);
  release();
  await returning;
  expect(closes).toBe(1);
  expect(seen.disposals).toBe(1);
});

test("decoder cleanup failure retains the execution error and still frees caches", async () => {
  const { binding, seen } = fixture();
  const execution = new Error("execution failed");
  const cleanup = new Error("cleanup failed");
  const outcome = await run({ ...binding, createDecode: () => ({
    tryStep() { throw execution; }, close() { throw cleanup; },
  }) }).catch((error: unknown) => error);
  expect(outcome).toBeInstanceOf(AggregateError);
  expect((outcome as AggregateError).cause).toBe(execution);
  expect((outcome as AggregateError).errors).toEqual([execution, cleanup]);
  expect(seen.disposals).toBe(1);
});
