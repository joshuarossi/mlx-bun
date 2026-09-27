import { expect, test } from "bun:test";
import { bindMlxGateway, type MlxGatewayBinding } from "../../src/execution/gateway-binding";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/runtime/config";
import { Gemma4Model } from "../../src/models/gemma4/model";
import { UniversalDenseModel } from "../../src/models/universal/dense";
import { KVCache } from "../../src/state/kv";
import type { ResolvedExecution } from "../../src/contracts/portable/execution";
import type { RuntimeModel } from "../../src/models/factory";
import { NgramProvider } from "../../src/generation/speculative/sources/ngram-source";
import { DiffusionGemmaModel } from "../../src/models/diffusion-gemma/model";
import { Glm52Model } from "../../src/models/glm52/model";
import { MiniCPM5Model } from "../../src/models/minicpm5/model";
import { Qwen3Model } from "../../src/models/qwen/qwen3";
import { Qwen3MoeModel } from "../../src/models/qwen/qwen3-moe";
import { Qwen35Model } from "../../src/models/qwen/qwen3_5";
import { resolveKvScheme } from "../../src/state/kv-scheme";

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

const standIn = (prototype: object, modelType: string, extra: object = {}): RuntimeModel =>
  Object.assign(Object.create(prototype), {
    config: { modelType, text: { enableMoeBlock: false }, eosTokenIds: [] },
    makeCache: () => [new KVCache()], loraState: { active: [] }, ...extra,
  });

// Every autoregressive class the binding distinguishes. Stand-ins share plain
// KV caches, so only class guards differ: Gemma2's plain softcap graph is the
// one class that declines grammar jump and grouped speculation.
const qualifiedFamilies: [string, () => RuntimeModel][] = [
  ["universal dense", () => standIn(UniversalDenseModel.prototype, "llama",
    { args: { modelType: "llama", maskArray: false, attnLogitSoftcap: null, layerTypes: null } })],
  ["gemma4", gemma4],
  ["qwen3", () => standIn(Qwen3Model.prototype, "qwen3")],
  ["qwen3-moe", () => standIn(Qwen3MoeModel.prototype, "qwen3_moe")],
  ["qwen3.5", () => standIn(Qwen35Model.prototype, "qwen3_5")],
  ["minicpm5", () => standIn(MiniCPM5Model.prototype, "minicpm5")],
  ["glm52", () => standIn(Glm52Model.prototype, "glm_moe_dsa")],
];
const families: [string, () => RuntimeModel][] = [["gemma2 softcap", softcapUniversal], ...qualifiedFamilies];

// GenerationGateway.place derives `continuous` from the bound caches.
const place = (binding: MlxGatewayBinding, request: typeof shape) =>
  binding.plan(request, {}, { ...schedule, continuous: binding.cachesBatchable() });
const refusals = (plan: ResolvedExecution) =>
  plan.reasons.filter(reason => reason.endsWith("-unsupported") || reason === "continuous-unavailable");

test("the retired MLX_BUN_GRAMMAR_BATCH switch no longer changes grammar placement", () => {
  const [baseline, ...others] = environments.map(env => planUnder(env, gemma4()));
  expect(baseline).toMatchObject({ method: "autoregressive", mechanism: "continuous", grammarJump: false });
  expect(baseline!.reasons).toEqual([]);
  for (const plan of others) expect(plan).toEqual(baseline!);
});

test("Gemma2 softcap grammar and adapter requests plan continuous; its encoded KV stays unsupported", () => {
  for (const env of environments) {
    for (const request of [shape, grammar, { ...shape, hasAdapters: true }, { ...grammar, hasAdapters: true }])
      expect(planUnder(env, softcapUniversal(), request))
        .toMatchObject({ mechanism: "continuous", fill: false, checkpoint: false, grammarJump: false });
    for (const [request, reason] of [[{ ...grammar, kvQuant: true }, "kv-scheme-batch-unsupported"],
      [{ ...grammar, turboQuant: true }, "turbo-kv-batch-unsupported"]] as const) {
      const plan = planUnder(env, softcapUniversal(), request);
      expect(plan.mechanism).toBe("unsupported");
      expect(plan.reasons).toContain(reason);
    }
  }
});

test.each(families)("%s places ordinary grammar exactly like the same request without grammar", (_, model) => {
  const binding = bindMlxGateway(model());
  expect(binding.cachesBatchable()).toBe(true);
  const ordinary = place(binding, grammar);
  expect(ordinary).toMatchObject({ method: "autoregressive", mechanism: "continuous", grammarJump: false });
  expect(ordinary.reasons.filter(reason => reason.includes("grammar"))).toEqual([]);
  // Refused compositions keep their own reasons; grammar adds none.
  for (const extra of [{}, { hasAdapters: true }, { wantsLogprobs: true }, { userSeed: true },
    { hasRepetitionPenalty: true }, { hasLogitsExtras: true }, { kvQuant: true }, { turboQuant: true },
    { hasVision: true }, { hasDraft: true }])
    expect({ extra, plan: place(binding, { ...shape, ...extra, hasGrammar: true }) })
      .toEqual({ extra, plan: place(binding, { ...shape, ...extra }) });
});

test.each(qualifiedFamilies)("%s qualifies multi-token grammar jump when it is enabled", (_, model) => {
  const binding = withRuntimeConfig(createRuntimeConfig({ MLX_BUN_GRAMMAR_JUMP: "1" }), () => bindMlxGateway(model()));
  const plan = place(binding, grammar);
  expect(plan).toMatchObject({ method: "speculative", mechanism: "continuous", grammarJump: true });
  expect(refusals(plan)).toEqual([]);
});

test("Gemma2 softcap declines only the grammar jump and keeps ordinary masked decoding", () => {
  const binding = withRuntimeConfig(createRuntimeConfig({ MLX_BUN_GRAMMAR_JUMP: "1" }),
    () => bindMlxGateway(softcapUniversal()));
  const plan = place(binding, grammar);
  expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous", grammarJump: false });
  expect(plan.reasons).toContain("grammar-jump-incompatible-with-request");
  expect(refusals(plan)).toEqual([]);
});

test.each(families)("%s places grammar with a bound grouped draft exactly as the draft alone", (name, model) => {
  const binding = bindMlxGateway(model(), { provider: new NgramProvider(), numDraftTokens: 3 });
  const draft = { ...shape, hasDraft: true };
  const plan = place(binding, { ...draft, hasGrammar: true });
  expect(plan).toEqual(place(binding, draft));
  if (name === "gemma2 softcap") {
    // Softcap speculation lacks numerical evidence; grammar is not the reason.
    expect(plan).toMatchObject({ method: "speculative", mechanism: "unsupported" });
    expect(refusals(plan)).toEqual(["continuous-unavailable", "method-batch-unsupported"]);
  } else expect(plan).toMatchObject({ method: "speculative", mechanism: "continuous", grammarJump: false });
});

test("denoising refuses grammar by method, exactly as it refuses the same request without grammar", () => {
  const binding = bindMlxGateway(standIn(DiffusionGemmaModel.prototype, "diffusion_gemma"));
  const plan = place(binding, grammar);
  expect(plan).toEqual(place(binding, shape));
  expect(plan).toMatchObject({ method: "denoising", mechanism: "unsupported" });
  expect(refusals(plan)).toEqual(["method-batch-unsupported"]);
});

function minicpm5(layers = 4): MiniCPM5Model {
  return Object.assign(Object.create(MiniCPM5Model.prototype), {
    config: { modelType: "minicpm5", text: { enableMoeBlock: false, numHiddenLayers: layers, layerTypes: Array(layers).fill("full_attention") }, eosTokenIds: [] },
    makeCache: () => Array.from({ length: layers }, () => new KVCache()), loraState: { active: [] },
  });
}

function dense(layers = 4): UniversalDenseModel {
  return Object.assign(Object.create(UniversalDenseModel.prototype), {
    args: { modelType: "llama", maskArray: false, attnLogitSoftcap: null, layerTypes: null },
    config: { modelType: "llama", text: { enableMoeBlock: false, numHiddenLayers: layers, layerTypes: Array(layers).fill("full_attention") }, eosTokenIds: [] },
    makeCache: () => Array.from({ length: layers }, () => new KVCache()), loraState: { active: [] },
  });
}

test("MiniCPM5 batches delayed affine KV for ordinary continuous decoding only", () => {
  const binding = bindMlxGateway(minicpm5(), { provider: { grouped: {} } as never, numDraftTokens: 4 });
  const config = [{ layerIdx: 0, bits: 8, groupSize: 64 }, { layerIdx: 2, bits: 4, groupSize: 64 }];
  for (const scheme of [resolveKvScheme({ override: 4, quantizedKvStart: 64 }), resolveKvScheme({ override: 8, quantizedKvStart: 64 }),
    resolveKvScheme({ override: "config", config, quantizedKvStart: 64 })])
    expect(binding.kvBatchable(scheme)).toBe(true);
  // A family without the capability still refuses a delayed start.
  expect(bindMlxGateway(dense()).kvBatchable(resolveKvScheme({ override: 4, quantizedKvStart: 64 }))).toBe(false);
  expect(bindMlxGateway(dense()).kvBatchable(resolveKvScheme({ override: 4, quantizedKvStart: 0 }))).toBe(true);

  binding.configureContinuation!({ checkpointPersistence: {} } as never);
  const kv = { ...shape, kvQuant: true }, scheduling = { continuous: true, quantizedBatch: true, checkpoints: true };
  const fill = { fill: { plan: { echo: false } } } as never;
  for (const delayed of [{ kvBits: 4, quantizedKvStart: 64 }, { kvBits: 8 }, { kvConfig: config, quantizedKvStart: 64 }] as const) {
    expect(binding.plan(kv, delayed, scheduling)).toMatchObject({ method: "autoregressive", mechanism: "continuous", checkpoint: false });
    // A draft or fill over delayed affine KV is refused explicitly, never silently dropped.
    for (const [request, options] of [[{ ...kv, hasDraft: true }, delayed], [kv, { ...delayed, ...(fill as object) }]] as const) {
      const refused = binding.plan(request, options, scheduling);
      expect(refused.mechanism).toBe("unsupported");
      expect(refused.reasons).toContain("continuous-unavailable");
    }
  }
  // Immediate quantization (start 0) keeps its existing speculative, fill and checkpoint placement.
  const immediate = { kvBits: 4, quantizedKvStart: 0 };
  expect(binding.plan(kv, immediate, scheduling)).toMatchObject({ mechanism: "continuous", checkpoint: true });
  expect(binding.plan({ ...kv, hasDraft: true }, immediate, scheduling).method).toBe("speculative");
  expect(binding.plan(kv, { ...immediate, ...(fill as object) }, scheduling).fill).toBe(true);
  // Plain KV is unaffected.
  expect(binding.plan({ ...shape, hasDraft: true }, {}, scheduling).method).toBe("speculative");
  // Grammar jump over delayed affine KV falls back to ordinary grammar masking with its reason.
  const jump = withRuntimeConfig(createRuntimeConfig({ MLX_BUN_GRAMMAR_JUMP: "1" }), () => bindMlxGateway(minicpm5()));
  const masked = jump.plan({ ...kv, hasGrammar: true }, { kvBits: 4, quantizedKvStart: 64 }, { continuous: true, quantizedBatch: true, checkpoints: false });
  expect(masked).toMatchObject({ mechanism: "continuous", method: "autoregressive", grammarJump: false });
  expect(masked.reasons).toContain("grammar-jump-incompatible-with-request");
  expect(jump.plan({ ...kv, hasGrammar: true }, immediate, { continuous: true, quantizedBatch: true, checkpoints: false }).grammarJump).toBe(true);
});
