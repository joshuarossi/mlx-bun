import { expect, test } from "bun:test";
import { bindMlxGateway } from "../../src/backends/mlx/gateway-binding";
import { Gemma4Model } from "../../src/model/gemma4";
import { Qwen35Model } from "../../src/model/qwen3_5";
import { KVCache } from "../../src/model/gemma4-base";
import type { MlxSerialServices } from "../../src/backends/mlx/serial-executor";

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
  binding.configureContinuation!({ checkpointPersistence: {}, checkpoints: {}, checkpointEveryTokens: 4 } as MlxSerialServices);
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
