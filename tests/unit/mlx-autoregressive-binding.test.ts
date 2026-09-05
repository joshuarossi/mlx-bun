import { expect, test } from "bun:test";
import { generateAutoregressive } from "../../src/generate";
import type { MlxAutoregressiveBinding } from "../../src/backends/mlx/autoregressive";
import { bindMlxGraph } from "../../src/backends/mlx/graph";
import { KVCache, type Cache } from "../../src/model/gemma4";
import { MlxArray } from "../../src/mlx/array";

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
