import { expect, test } from "bun:test";
import { bindMlxGateway } from "../../src/execution/gateway-binding";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/runtime/config";
import { Gemma4Model } from "../../src/models/gemma4/model";
import { UniversalDenseModel } from "../../src/models/universal/dense";
import { KVCache } from "../../src/state/kv";

// Placement only: bound graphs are prototype stand-ins and no tensors are created.
const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false,
  kvQuant: false, turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: false };
const grammar = { ...shape, hasGrammar: true };
const schedule = { continuous: true, quantizedBatch: true, checkpoints: false };
const environments: Record<string, string>[] = [{}, { MLX_BUN_GRAMMAR_BATCH: "0" }, { MLX_BUN_GRAMMAR_BATCH: "1" }];

function gemma4(): Gemma4Model {
  return Object.assign(Object.create(Gemma4Model.prototype), {
    config: { modelType: "gemma4", text: { enableMoeBlock: false }, eosTokenIds: [] },
    makeCache: () => [new KVCache()], loraState: { active: [] },
  });
}

function softcapUniversal(): UniversalDenseModel {
  return Object.assign(Object.create(UniversalDenseModel.prototype), {
    args: { modelType: "gemma2", maskArray: true, attnLogitSoftcap: 50, layerTypes: null },
    config: { modelType: "gemma2", text: { enableMoeBlock: false }, eosTokenIds: [] },
    makeCache: () => [new KVCache()], loraState: { active: [] },
  });
}

const planUnder = (env: Record<string, string>, model: Gemma4Model | UniversalDenseModel, request = grammar) =>
  withRuntimeConfig(createRuntimeConfig(env), () => bindMlxGateway(model)).plan(request, {}, schedule);

test("the retired MLX_BUN_GRAMMAR_BATCH switch no longer changes grammar placement", () => {
  const [baseline, ...others] = environments.map(env => planUnder(env, gemma4()));
  expect(baseline).toMatchObject({ method: "autoregressive", mechanism: "continuous", grammarJump: false });
  expect(baseline!.reasons).toEqual([]);
  for (const plan of others) expect(plan).toEqual(baseline!);
});

test("grammar on an attention-softcap universal graph stays unsupported with its batch reason", () => {
  for (const env of environments) {
    expect(planUnder(env, softcapUniversal(), shape)).toMatchObject({ mechanism: "continuous" });
    const plan = planUnder(env, softcapUniversal());
    expect(plan).toMatchObject({ mechanism: "unsupported", fill: false, checkpoint: false, grammarJump: false });
    // Rejection reasons are separate from optional-feature diagnostics (compiled decode here).
    expect(plan.reasons.filter(reason => reason.endsWith("-unsupported") || reason === "continuous-unavailable"))
      .toEqual(["grammar-batch-unsupported"]);
  }
});
