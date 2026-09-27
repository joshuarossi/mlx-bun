import { expect, test } from "bun:test";
import { bindMlxGateway } from "../../src/execution/gateway-binding";
import { Gemma4Model } from "../../src/models/gemma4/model";
import { UniversalDenseModel } from "../../src/models/universal/dense";
import { FillSession } from "../../src/generation/fill";
import type { GenerateOptions } from "../../src/generation";
import { Qwen35Model } from "../../src/models/qwen/qwen3_5";
import { KVCache } from "../../src/state/kv";
import type { ContinuationServices } from "../../src/execution/continuation";

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

test("Gemma2 softcap plans shared continuation for plain KV only, keeping every other exclusion", () => {
  const model = Object.assign(Object.create(UniversalDenseModel.prototype), {
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
  // Grammar, fill, drafts, media, logprobs, encoded KV and paging keep their
  // placement and bind no continuation: placed requests carry no checkpoint,
  // and the rest stay unsupported for this graph.
  const fill = { fill: new FillSession({ rows: [], eos: [], echo: null }, [2, 651]) };
  for (const [request, options, mechanism] of [[{ ...shape, hasGrammar: true }, {}, "continuous"], [shape, fill, "continuous"],
    [{ ...shape, wantsLogprobs: true }, {}, "continuous"], [{ ...shape, hasDraft: true }, {}, "unsupported"],
    [{ ...shape, hasVision: true }, {}, "unsupported"], [{ ...shape, kvQuant: true }, { kvBits: 4 }, "unsupported"],
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
