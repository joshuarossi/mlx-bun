import { expect, test } from "bun:test";
import { bindMlxGateway } from "../../src/execution/gateway-binding";
import { Gemma4Model } from "../../src/models/gemma4/model";
import { UniversalDenseModel } from "../../src/models/universal/dense";
import { FillSession } from "../../src/generation/fill";
import type { GenerateOptions } from "../../src/generation";
import { Qwen35Model } from "../../src/models/qwen/qwen3_5";
import { KVCache } from "../../src/state/kv";
import type { ContinuationServices, ContinuationStore } from "../../src/execution/continuation";
import { ContinuationPersistence } from "../../src/execution/continuation-persistence";

const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false,
  kvQuant: false, turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: false };

for (const [name, prototype] of [["gemma4", Gemma4Model.prototype], ["qwen3_5", Qwen35Model.prototype]] as const) {
test(`ordinary shared continuation binds ${name} through its loaded backend`, () => {
  const model = Object.assign(Object.create(prototype), {
    config: { modelType: name, text: { enableMoeBlock: false }, eosTokenIds: [] },
    makeCache: () => [new KVCache()],
    loraState: { active: [] },
  }) as Gemma4Model;
  const binding = bindMlxGateway(model);
  const unconfigured = bindMlxGateway(model);
  const schedule = { continuous: true, quantizedBatch: true, checkpoints: true };
  expect(binding.plan(shape, {}, schedule).checkpoint).toBe(false);
  binding.configureContinuation!({ checkpointPersistence: {}, checkpoints: {}, checkpointEveryTokens: 4 } as ContinuationServices);
  expect(binding.plan(shape, {}, schedule)).toMatchObject({ mechanism: "continuous", checkpoint: true });
  const adapterShape = { ...shape, hasAdapters: true };
  expect(binding.plan(adapterShape, { adapters: ["upper"] }, schedule)).toMatchObject({
    method: "autoregressive", mechanism: "continuous", checkpoint: true,
  });
  expect(unconfigured.plan(adapterShape, { adapters: ["upper"] }, schedule).checkpoint).toBe(false);
  for (const excluded of [{ hasDraft: true }, { hasGrammar: true },
    { wantsLogprobs: true }]) {
    const request = { ...shape, ...excluded };
    const baseline = unconfigured.plan(request, {}, schedule);
    const plan = binding.plan(request, {}, schedule);
    expect(plan.checkpoint).toBe(false);
    expect(plan.method).toBe(baseline.method);
    expect(plan.mechanism).toBe(baseline.mechanism);
    expect(plan).toEqual(baseline);
  }
  for (const options of [{ kvBits: 4 }, { kvBits: 8, quantizedKvStart: 14 },
    { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 14 },
    { kvConfig: [{ layerIdx: 0, bits: 4, groupSize: 64 }], quantizedKvStart: 14 }]) {
    const request = { ...shape, kvQuant: !!(options.kvBits || options.kvConfig), turboQuant: !!options.turboQuant };
    expect(binding.plan(request, options, schedule)).toMatchObject({ mechanism: "continuous", checkpoint: true });
    expect(unconfigured.plan(request, options, schedule).checkpoint).toBe(false);
  }
});
}

test("Gemma2 softcap plans shared continuation for plain and affine KV, keeping every other exclusion", () => {
  const model = Object.assign(Object.create(UniversalDenseModel.prototype), { encodedKvAttention: false,
    args: { modelType: "gemma2", maskArray: true, attnLogitSoftcap: 50, layerTypes: null },
    config: { modelType: "gemma2", text: { enableMoeBlock: false }, eosTokenIds: [] },
    makeCache: () => [new KVCache()], loraState: { active: [] },
  }) as UniversalDenseModel;
  const binding = bindMlxGateway(model), unconfigured = bindMlxGateway(model);
  const schedule = { continuous: true, quantizedBatch: true, checkpoints: true };
  expect(binding.plan(shape, {}, schedule)).toMatchObject({ mechanism: "continuous", checkpoint: false });
  binding.configureContinuation!({ checkpointPersistence: {}, checkpoints: {}, checkpointEveryTokens: 4 } as ContinuationServices);
  // Greedy, seeded and history-dependent sampling, and adapter requests, which Gemma2 already batches.
  const planned: [typeof shape, GenerateOptions][] = [[shape, {}],
    [{ ...shape, userSeed: true, hasRepetitionPenalty: true }, { seed: 42, repetitionPenalty: 1.1, repetitionContextSize: 32 }],
    [{ ...shape, hasAdapters: true }, { adapters: ["upper"] }]];
  for (const [request, options] of planned) {
    expect(binding.plan(request, options, schedule)).toMatchObject({ method: "autoregressive", mechanism: "continuous",
      promptCache: true, checkpoint: true, fill: false, pagedKv: false });
    expect(unconfigured.plan(request, options, schedule).checkpoint).toBe(false);
  }
  // Affine KV places ordinarily (its rows are rejected at their transition) and
  // takes continuation checkpoints; its placement is otherwise the unconfigured binding's.
  {
    const request = { ...shape, kvQuant: true }, options = { kvBits: 4 };
    const plan = binding.plan(request, options, schedule), baseline = unconfigured.plan(request, options, schedule);
    const { checkpoint: planned, ...placement } = plan, { checkpoint: unplanned, ...unchanged } = baseline;
    expect(placement).toEqual(unchanged);
    expect({ method: plan.method, mechanism: plan.mechanism, planned, unplanned })
      .toEqual({ method: "autoregressive", mechanism: "continuous", planned: true, unplanned: false });
  }
  // Grammar, fill, drafts, media, logprobs, TurboQuant and paging keep their
  // placement and bind no continuation: placed requests carry no checkpoint,
  // and the rest stay unsupported for this graph.
  const fill = { fill: new FillSession({ rows: [], eos: [], echo: null }, [2, 651]) };
  for (const [request, options, mechanism] of [[{ ...shape, hasGrammar: true }, {}, "continuous"], [shape, fill, "continuous"],
    [{ ...shape, wantsLogprobs: true }, {}, "continuous"], [{ ...shape, hasDraft: true }, {}, "unsupported"],
    [{ ...shape, hasVision: true }, {}, "unsupported"],
    [{ ...shape, turboQuant: true }, { turboQuant: { kBits: 8, vBits: 3 } }, "unsupported"],
    [shape, { pagedKv: {} }, "unsupported"]] as const) {
    const plan = binding.plan(request, options, schedule), baseline = unconfigured.plan(request, options, schedule);
    const { checkpoint: _planned, ...placement } = plan, { checkpoint: _baseline, ...unchanged } = baseline;
    expect({ request, placement }).toEqual({ request, placement: unchanged });
    expect({ request, mechanism: plan.mechanism, checkpoint: plan.mechanism === "continuous" && plan.checkpoint })
      .toEqual({ request, mechanism, checkpoint: false });
    expect(binding.continuationRequest!(plan, options, [2, 651], () => {})).toBeUndefined();
  }
});

test("Gemma4 adapter requests bypass server-wide paging and checkpoint exactly as unpaged adapter requests", () => {
  const model = Object.assign(Object.create(Gemma4Model.prototype), {
    config: { modelType: "gemma4", text: { enableMoeBlock: false }, eosTokenIds: [] },
    makeCache: () => [new KVCache()], loraState: { active: [] },
  }) as Gemma4Model;
  const lookups: unknown[][] = [];
  const store = { findGenerationCheckpoint: (...args: unknown[]) => { lookups.push(args); return null; } } as unknown as ContinuationStore;
  const binding = bindMlxGateway(model);
  binding.configureContinuation!({ checkpoints: store, checkpointPersistence: new ContinuationPersistence(store, { maxBytes: 1024 }),
    checkpointEveryTokens: 4, identity: "fixture" } as unknown as ContinuationServices);
  const schedule = { continuous: true, quantizedBatch: true, checkpoints: true };
  const paging = { pagedKv: {} }, adapters = { adapters: ["upper"] }, adapterShape = { ...shape, hasAdapters: true };
  const prompt = [2, 651, 9];
  // Main's serial executor scoped the flag per request: the adapter row runs on
  // plain caches, so its placement, namespaces, state and continuation key are
  // those of the same request without paging.
  const on = binding.plan(adapterShape, { ...adapters, ...paging }, schedule), off = binding.plan(adapterShape, adapters, schedule);
  expect(on).toMatchObject({ method: "autoregressive", mechanism: "continuous", pagedKv: false, promptCache: true, checkpoint: true });
  const bypass = "paged-kv-bypassed-for-media-or-adapters";
  const { reasons: bypassed, ...placedOn } = on, { reasons: plain, ...placedOff } = off;
  expect(placedOn).toEqual(placedOff);
  expect(bypassed).toContain(bypass);
  expect(bypassed.filter(reason => reason !== bypass)).toEqual([...plain]);
  expect(binding.prefixNamespace!(on, { ...adapters, ...paging }, "upper@a")).toBe("upper@a");
  expect(binding.prefixNamespace!(off, adapters, "upper@a")).toBe("upper@a");
  expect(binding.statePolicy!(on, { ...adapters, ...paging }, 64)).toBeUndefined();
  expect(binding.statePolicy!(off, adapters, 64)).toBeUndefined();
  const requests = [binding.continuationRequest!(on, { ...adapters, ...paging }, prompt, () => {})!,
    binding.continuationRequest!(off, adapters, prompt, () => {})!];
  try {
    for (const request of requests) expect(request.continuation.restore("upper@a")).toBeNull();
    expect(lookups).toHaveLength(2);
    expect(lookups[0]).toEqual(lookups[1]);
    expect(lookups[0]![2]).toBe("upper@a");
  } finally { for (const request of requests) request.dispose(); }
  // Actual paging and the other exclusions are unchanged: a paged row keeps its
  // paged state and namespace without a checkpoint; media, grammar, fill and
  // logprobs rows bypass paging and still take none; a paging request on a
  // graph without paged batching stays unsupported.
  const paged = binding.plan(shape, paging, schedule);
  expect(paged).toMatchObject({ mechanism: "continuous", pagedKv: true, checkpoint: false });
  expect(binding.statePolicy!(paged, paging, 64)).toBeDefined();
  expect(JSON.parse(binding.prefixNamespace!(paged, paging, "")!)[0]).toBe("paged-v1");
  expect(binding.continuationRequest!(paged, paging, prompt, () => {})).toBeUndefined();
  const fill = { fill: new FillSession({ rows: [], eos: [], echo: null }, prompt) };
  for (const [request, options] of [[{ ...adapterShape, hasVision: true }, adapters], [{ ...shape, hasVision: true }, {}],
    [{ ...adapterShape, hasGrammar: true }, adapters], [adapterShape, { ...adapters, ...fill }],
    [{ ...adapterShape, wantsLogprobs: true }, adapters]] as const) {
    const plan = binding.plan(request, { ...options, ...paging }, schedule), unpaged = binding.plan(request, options, schedule);
    expect({ request, plan }).toMatchObject({ request, plan: { mechanism: "continuous", pagedKv: false, checkpoint: false } });
    const { reasons: withPaging, ...placed } = plan, { reasons: without, ...baseline } = unpaged;
    expect({ request, placed }).toEqual({ request, placed: baseline });
    expect(withPaging).toContain(bypass);
    expect(withPaging.filter(reason => reason !== bypass)).toEqual([...without]);
    expect(binding.continuationRequest!(plan, { ...options, ...paging }, prompt, () => {})).toBeUndefined();
  }
  const qwen = bindMlxGateway(Object.assign(Object.create(Qwen35Model.prototype), {
    config: { modelType: "qwen3_5", text: { enableMoeBlock: false }, eosTokenIds: [] },
    makeCache: () => [new KVCache()], loraState: { active: [] },
  }) as Qwen35Model);
  qwen.configureContinuation!({ checkpointPersistence: {}, checkpoints: {}, checkpointEveryTokens: 4 } as ContinuationServices);
  for (const request of [shape, adapterShape]) {
    const plan = qwen.plan(request, { ...adapters, ...paging }, schedule);
    expect(plan.mechanism).toBe("unsupported");
    expect(plan.reasons).toContain("paged-kv-batch-unsupported");
    expect(qwen.continuationRequest!(plan, { ...adapters, ...paging }, prompt, () => {})).toBeUndefined();
  }
});
