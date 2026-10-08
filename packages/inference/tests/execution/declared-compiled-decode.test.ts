import { expect, test } from "bun:test";
import * as ops from "@mlx-bun/mlx/ops";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MlxArray } from "@mlx-bun/mlx/array";
import type { MlxCompiledDecodeStep } from "../../src/contracts/mlx/graph";
import { MlxBatchExecutionGroup } from "../../src/execution/batch-group";
import { bindMlxAutoregressiveGraph } from "../../src/generation/bindings/autoregressive";
import { compiledDecodeStepOf, declareGraph } from "../../src/models/capabilities";
import type { MlxTokenGraph } from "../../src/models/graph";
import { createRuntimeConfig } from "../../src/runtime/config";
import { KVCache } from "../../src/state/kv";
import type { Cache } from "../../src/contracts/mlx/cache";

// A graph that is none of the model classes and declares its own compiled step:
// the scheduler and the autoregressive binding reach it only through that
// declaration. Ordinary forwards produce token 0; the declared step, token 3.
const VOCAB = 8, COMPILED_TOKEN = 3;

function graph(declared: Parameters<typeof declareGraph>[0], extra: Partial<MlxTokenGraph> = {}) {
  const forwards: number[] = [];
  const append = (caches: Cache[], width: number) => {
    using kv = ops.zeros([1, 1, width, 4], Dtype.float32);
    for (const cache of caches) { const [k, v] = cache.updateAndFetch(kv, kv); k.dispose(); v.dispose(); }
  };
  const model: MlxTokenGraph = {
    weightsBytes: 0,
    config: { modelType: "fixture", eosTokenIds: [], text: { numHiddenLayers: 1, layerTypes: ["full_attention"],
      numGlobalKeyValueHeads: 1, globalHeadDim: 4, slidingWindow: 0 } } as never,
    makeCache: () => [new KVCache()], requiredDenseKvLayers: [], graphCapabilities: declareGraph(declared),
    forwardHidden(ids, caches) { forwards.push(ids.shape[1]!); append(caches, ids.shape[1]!); return ops.zeros([1, ids.shape[1]!, VOCAB], Dtype.float32); },
    logitsFromHidden: hidden => ops.copyOf(hidden),
    ...extra,
  };
  return { model, forwards, append };
}

function countingStep(model: { append: (caches: Cache[], width: number) => void }, options: { accepts?: boolean; failAt?: number } = {}) {
  const calls = { accepts: 0, steps: 0 };
  const step: MlxCompiledDecodeStep = {
    accepts() { calls.accepts++; return options.accepts ?? true; },
    step(_token: MlxArray, caches: Cache[]) {
      if (calls.steps++ === options.failAt) throw new Error("compiled step failed");
      model.append(caches, 1);
      const row = new Float32Array(VOCAB); row[COMPILED_TOKEN] = 1;
      return { logits: MlxArray.fromFloat32(row, [1, 1, VOCAB]), evalWith: [] };
    },
  };
  return { step, calls };
}

async function decode(model: MlxTokenGraph, options: { compiledDecode?: boolean; env?: Record<string, string> } = {}) {
  const group = new MlxBatchExecutionGroup(model, { maxBatch: 2, runtime: createRuntimeConfig(options.env ?? {}) });
  const tokens: number[] = [];
  try {
    await group.submit({ promptIds: [1, 2, 3], maxTokens: 6, eosTokenIds: [], sample: logits => ops.argmaxAxis(logits, -1),
      ...(options.compiledDecode === undefined ? {} : { compiledDecode: options.compiledDecode }),
      onToken(token) { tokens.push(token); return undefined; } });
  } finally { await group.close(); }
  return tokens;
}

test("a lone row decodes through the step its graph declares, and other graphs never get one", async () => {
  const fixture = graph({ compiledDecode: true });
  const declared = countingStep(fixture);
  const model = { ...fixture.model, compiledDecodeStep: () => declared.step };
  const tokens = await decode(model);
  expect(tokens[0]).toBe(0); // token zero comes from the prefill projection
  expect(tokens.slice(1)).toEqual(Array(5).fill(COMPILED_TOKEN));
  expect(declared.calls.steps).toBeGreaterThan(0);
  expect(fixture.forwards).toEqual([2, 1]); // the prompt (tail split off) only; no decode forward ran

  // A graph that declares no compiled decode is never asked for a step, even if it has the method.
  const undeclared = graph({});
  const unused = countingStep(undeclared);
  expect(await decode({ ...undeclared.model, compiledDecodeStep: () => unused.step })).toEqual(Array(6).fill(0));
  expect(unused.calls).toEqual({ accepts: 0, steps: 0 });
  expect(undeclared.forwards.length).toBeGreaterThan(1);
});

test("the request, the kill switch and the step's own acceptance keep decoding on the ordinary forward", async () => {
  for (const [name, options, accepts] of [
    ["request opt-out", { compiledDecode: false }, true],
    ["kill switch", { env: { MLX_BUN_COMPILED_DECODE: "0" } }, true],
    ["state not accepted", {}, false],
  ] as const) {
    const fixture = graph({ compiledDecode: true });
    const declared = countingStep(fixture, { accepts });
    expect(await decode({ ...fixture.model, compiledDecodeStep: () => declared.step }, options), name).toEqual(Array(6).fill(0));
    expect(declared.calls.steps, name).toBe(0);
  }
});

test("a step that fails is retired and the same token continues on the ordinary forward", async () => {
  const fixture = graph({ compiledDecode: true });
  const declared = countingStep(fixture, { failAt: 2 });
  const tokens = await decode({ ...fixture.model, compiledDecodeStep: () => declared.step });
  expect(tokens).toEqual([0, COMPILED_TOKEN, COMPILED_TOKEN, 0, 0, 0]);
  expect(declared.calls.steps).toBe(3);
});

test("a graph that promises a compiled step and provides none is refused where it binds", () => {
  const fixture = graph({ compiledDecode: true });
  expect(() => compiledDecodeStepOf(fixture.model)).toThrow("provides no compiledDecodeStep");
  expect(() => new MlxBatchExecutionGroup(fixture.model, { maxBatch: 1 })).toThrow("provides no compiledDecodeStep");
  expect(compiledDecodeStepOf(graph({}).model)).toBeNull();
});

test("the autoregressive binding offers the declared step unless adapters or paging rule replay out", () => {
  const fixture = graph({ compiledDecode: true });
  const declared = countingStep(fixture);
  const binding = bindMlxAutoregressiveGraph({ ...fixture.model, compiledDecodeStep: () => declared.step });
  expect(binding.createDecode!({ hasAdapters: true, pagedKv: false })).toBeNull();
  expect(binding.createDecode!({ hasAdapters: false, pagedKv: true })).toBeNull();
  const decoder = binding.createDecode!({ hasAdapters: false, pagedKv: false })!;
  const caches = fixture.model.makeCache();
  try {
    using token = MlxArray.fromFloat32(new Float32Array([0]), [1]);
    const result = decoder.tryStep(token, caches)!;
    expect(result.logits.shape).toEqual([1, 1, VOCAB]);
    result.logits.dispose();
    expect(caches[0]!.offset).toBe(1);
    expect(declared.calls.steps).toBe(1);
  } finally { for (const cache of caches) cache.dispose(); void decoder.close(); }
  // A graph declaring nothing has no decoder, whatever methods it carries.
  expect(bindMlxAutoregressiveGraph({ ...graph({}).model, compiledDecodeStep: () => declared.step }).createDecode!({ hasAdapters: false, pagedKv: false })).toBeNull();
});
