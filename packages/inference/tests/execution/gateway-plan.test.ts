import { describe, expect, test } from "bun:test";
import { bindMlxGateway, type MlxGatewayBinding } from "../../src/execution/gateway-binding";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/runtime/config";
import { Gemma4Model } from "../../src/models/gemma4/model";
import { UniversalDenseModel } from "../../src/models/universal/dense";
import { KVCache } from "../../src/state/kv";
import { RotatingKVCache } from "../../src/state/rotating-kv";
import { KvScheme } from "../../src/state/kv-scheme";
import type { GenerateOptions } from "../../src/generation/index";
import type { ResolvedExecution } from "../../src/contracts/portable/execution";
import type { RuntimeModel } from "../../src/models/factory";
import { NgramProvider } from "../../src/generation/speculative/sources/ngram-source";
import { TwoModelProvider } from "../../src/generation/speculative/sources/two-model";
import { FillSession } from "../../src/generation/fill/session";
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

test.each(families)("%s places grammar with a bound grouped draft exactly as the draft alone", (_, model) => {
  const binding = bindMlxGateway(model(), { provider: new NgramProvider(), numDraftTokens: 3 });
  const draft = { ...shape, hasDraft: true };
  const plan = place(binding, { ...draft, hasGrammar: true });
  expect(plan).toEqual(place(binding, draft));
  expect(plan).toMatchObject({ method: "speculative", mechanism: "continuous", grammarJump: false });
});

describe("DiffusionGemma interleaved denoising binding", () => {
  const diffusion = () => standIn(DiffusionGemmaModel.prototype, "diffusion_gemma") as DiffusionGemmaModel;
  const planWith = (binding: MlxGatewayBinding, request: typeof shape, options: GenerateOptions = {}) =>
    binding.plan(request, options, { ...schedule, continuous: binding.cachesBatchable() });

  test("plain, seeded and adapted requests place continuously without AR-only reuse", () => {
    const binding = bindMlxGateway(diffusion());
    for (const extra of [{}, { userSeed: true }, { hasAdapters: true }])
      expect(place(binding, { ...shape, ...extra })).toMatchObject({ method: "denoising", mechanism: "continuous",
        promptCache: false, checkpoint: false, fill: false, compiledDecode: false, grammarJump: false });
    expect(binding.methodRequest!(place(binding, shape), {})).toMatchObject({ key: JSON.stringify(["denoising", "legacy-diffusion-gemma"]) });
  });

  test.each([
    [{ hasGrammar: true }, {}, "grammar-batch-unsupported"],
    [{ hasDraft: true }, {}, "draft-method-unsupported"],
    [{ wantsLogprobs: true }, {}, "logprobs-method-unsupported"],
    [{ hasRepetitionPenalty: true }, {}, "repetition-penalty-method-unsupported"],
    [{ hasLogitsExtras: true }, {}, "logits-extras-method-unsupported"],
    [{}, { fill: { plan: {} } }, "fill-method-unsupported"],
    [{}, { pagedKv: {} }, "paged-kv-batch-unsupported"],
    [{ kvQuant: true }, { kvBits: 4 }, "kv-scheme-batch-unsupported"],
    [{ turboQuant: true }, { turboQuant: { kBits: 8, vBits: 3 } }, "turbo-kv-batch-unsupported"],
  ] as const)("an unsupported denoising shape is refused before execution: %#", (extra, options, reason) => {
    for (const binding of [bindMlxGateway(diffusion()), bindMlxGateway(diffusion(), { provider: new NgramProvider(), numDraftTokens: 3 }),
      withRuntimeConfig(createRuntimeConfig({ MLX_BUN_GRAMMAR_JUMP: "1" }), () => bindMlxGateway(diffusion()))]) {
      const plan = planWith(binding, { ...shape, ...extra }, options as GenerateOptions);
      expect(plan).toMatchObject({ method: "denoising", mechanism: "unsupported", fill: false, grammarJump: false });
      expect(refusals(plan)).toEqual([reason]);
    }
  });

  test("an image request places continuously and its method borrows the request's pixels", () => {
    const binding = bindMlxGateway(diffusion());
    const pixels = { dispose() {} } as unknown as NonNullable<GenerateOptions["visionPixels"]>;
    const options: GenerateOptions = { seed: 1, visionPixels: pixels };
    // Denoising pixels are that method's prefill input, so hasVision stays false.
    const plan = planWith(binding, { ...shape, userSeed: true }, options);
    expect(plan).toMatchObject({ method: "denoising", mechanism: "continuous", promptCache: false, checkpoint: false });
    expect((binding.methodRequest!(plan, options)!.data as GenerateOptions).visionPixels).toBe(pixels);
    // Prepared autoregressive media still needs a media binding this graph lacks.
    expect(refusals(planWith(binding, { ...shape, hasVision: true }))).toEqual(["media-batch-unsupported"]);
    expect(place(bindMlxGateway(gemma4()), { ...shape, hasVision: true }))
      .toMatchObject({ method: "autoregressive", mechanism: "continuous" });
  });

  test("adapters are row state: the group context is neutral and encoded KV never binds", () => {
    const model = diffusion();
    const binding = bindMlxGateway(model);
    const context = binding.bindAdapterContext!(["upper"], "adapters:[\"upper\"]");
    expect(context.key).toBe(binding.bindAdapterContext!(["lower"], "adapters:[\"lower\"]").key);
    const leave = context.enter();
    expect(model.loraState.active).toEqual([]);
    leave();
    for (const kind of ["bf16", "affine-uniform", "affine-config", "turbo"] as const)
      expect(binding.kvBatchable(new KvScheme(kind, {}))).toBe(false);
    // Token methods never bind to the denoising graph, even when configured.
    const drafted = bindMlxGateway(model, { provider: new NgramProvider(), numDraftTokens: 3 });
    const denoise = place(drafted, shape);
    for (const execution of [{ ...denoise, method: "speculative" }, { ...denoise, method: "autoregressive", fill: true }])
      expect(drafted.methodRequest!(execution, { fill: { plan: {} } } as unknown as GenerateOptions)).toBeUndefined();
  });
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

test("MiniCPM5 batches delayed affine KV for ordinary continuous decoding and its generation checkpoints", () => {
  const binding = bindMlxGateway(minicpm5(), { provider: { grouped: {} } as never, numDraftTokens: 4 });
  const unconfigured = bindMlxGateway(minicpm5(), { provider: { grouped: {} } as never, numDraftTokens: 4 });
  const config = [{ layerIdx: 0, bits: 8, groupSize: 64 }, { layerIdx: 2, bits: 4, groupSize: 64 }];
  for (const scheme of [resolveKvScheme({ override: 4, quantizedKvStart: 64 }), resolveKvScheme({ override: 8, quantizedKvStart: 64 }),
    resolveKvScheme({ override: "config", config, quantizedKvStart: 64 })])
    expect(binding.kvBatchable(scheme)).toBe(true);
  // A model without the capability still refuses a delayed start.
  expect(bindMlxGateway(universal({ attnLogitSoftcap: 50, maskArray: true, modelType: "gemma2" }))
    .kvBatchable(resolveKvScheme({ override: 4, quantizedKvStart: 64 }))).toBe(false);
  expect(bindMlxGateway(dense()).kvBatchable(resolveKvScheme({ override: 4, quantizedKvStart: 0 }))).toBe(true);

  binding.configureContinuation!({ checkpointPersistence: {} } as never);
  const kv = { ...shape, kvQuant: true }, scheduling = { continuous: true, quantizedBatch: true, checkpoints: true };
  const fill = { fill: { plan: { echo: false } } } as never;
  for (const delayed of [{ kvBits: 4, quantizedKvStart: 64 }, { kvBits: 8 }, { kvConfig: config, quantizedKvStart: 64 }] as const) {
    // Main checkpointed MiniCPM5's delayed affine generation through its serial executor.
    expect(binding.plan(kv, delayed, scheduling)).toMatchObject({ method: "autoregressive", mechanism: "continuous", checkpoint: true });
    expect(binding.plan({ ...kv, userSeed: true, hasRepetitionPenalty: true }, { ...delayed, seed: 3, repetitionPenalty: 1.1 }, scheduling))
      .toMatchObject({ mechanism: "continuous", checkpoint: true });
    expect(unconfigured.plan(kv, delayed, scheduling)).toMatchObject({ mechanism: "continuous", checkpoint: false });
    // Grammar and logprobs stay continuous without checkpoints, as for every family.
    for (const request of [{ hasGrammar: true }, { wantsLogprobs: true }])
      expect(binding.plan({ ...kv, ...request }, delayed, scheduling)).toMatchObject({ mechanism: "continuous", checkpoint: false });
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

/** A universal descriptor over the model's own makeCache: caches follow the descriptor. */
function universal(args: Record<string, unknown> = {}, layers = 4): UniversalDenseModel {
  const descriptor = { modelType: "qwen2", maskArray: false, attnLogitSoftcap: null, layerTypes: null, slidingWindow: null,
    numHiddenLayers: layers, ...args };
  return Object.assign(Object.create(UniversalDenseModel.prototype), {
    args: descriptor,
    config: { modelType: descriptor.modelType, text: { enableMoeBlock: false, numHiddenLayers: layers,
      layerTypes: (descriptor.layerTypes as string[] | null) ?? Array(layers).fill("full_attention") }, eosTokenIds: [] },
    loraState: { active: [] },
  });
}

test("plain universal KV batches delayed affine KV for ordinary continuous decoding and its generation checkpoints", () => {
  const model = universal();
  expect(model.makeCache().every(cache => cache instanceof KVCache && !(cache instanceof RotatingKVCache))).toBe(true);
  const binding = bindMlxGateway(model, { provider: { grouped: {} } as never, numDraftTokens: 4 });
  const config = [{ layerIdx: 0, bits: 8, groupSize: 64 }, { layerIdx: 2, bits: 4, groupSize: 64 }];
  const delayedSchemes = [resolveKvScheme({ override: 4, quantizedKvStart: 8 }), resolveKvScheme({ override: 8, quantizedKvStart: 8 }),
    resolveKvScheme({ override: "config", config, quantizedKvStart: 8 })];
  for (const scheme of delayedSchemes) expect(binding.kvBatchable(scheme)).toBe(true);
  // Descriptors whose layers are not all plain KV, or whose graph is not
  // qualified, keep refusing a delayed start; immediate conversion is unchanged.
  const sliding = universal({ modelType: "llama", layerTypes: ["full_attention", "sliding_attention", "full_attention", "sliding_attention"], slidingWindow: 16 });
  expect(sliding.makeCache().some(cache => cache instanceof RotatingKVCache)).toBe(true);
  for (const other of [sliding, universal({ modelType: "gemma2", maskArray: true, attnLogitSoftcap: 50 }),
    universal({ modelType: "llama", maskArray: true })])
    for (const scheme of delayedSchemes) expect({ other: other.args, batchable: bindMlxGateway(other).kvBatchable(scheme) })
      .toEqual({ other: other.args, batchable: false });
  expect(bindMlxGateway(universal({ modelType: "llama", maskArray: true })).kvBatchable(resolveKvScheme({ override: 4, quantizedKvStart: 0 }))).toBe(true);

  binding.configureContinuation!({ checkpointPersistence: {} } as never);
  const kv = { ...shape, kvQuant: true }, scheduling = { continuous: true, quantizedBatch: true, checkpoints: true };
  const fill = { fill: { plan: { echo: false } } } as never;
  for (const delayed of [{ kvBits: 4, quantizedKvStart: 8 }, { kvBits: 8 }, { kvConfig: config, quantizedKvStart: 8 }] as const) {
    // Main checkpointed this generation through its serial executor.
    expect(binding.plan(kv, delayed, scheduling)).toMatchObject({ method: "autoregressive", mechanism: "continuous", checkpoint: true });
    expect(binding.plan({ ...kv, userSeed: true, hasRepetitionPenalty: true }, { ...delayed, seed: 3, repetitionPenalty: 1.1 }, scheduling))
      .toMatchObject({ mechanism: "continuous", checkpoint: true });
    expect(bindMlxGateway(universal()).plan(kv, delayed, scheduling)).toMatchObject({ mechanism: "continuous", checkpoint: false });
    // Grammar and logprobs ride shared sampling, without checkpoints as for every family.
    for (const request of [{ hasGrammar: true }, { wantsLogprobs: true }])
      expect(binding.plan({ ...kv, ...request }, delayed, scheduling)).toMatchObject({ mechanism: "continuous", checkpoint: false });
    // Drafts, fill and adapters over delayed affine KV are refused explicitly.
    const refusals: [typeof kv, GenerateOptions][] = [[{ ...kv, hasDraft: true }, delayed], [kv, { ...delayed, ...(fill as object) }],
      [{ ...kv, hasAdapters: true }, { ...delayed, adapters: ["upper"] }]];
    for (const [request, options] of refusals) {
      const refused = binding.plan(request, options, scheduling);
      expect(refused.mechanism).toBe("unsupported");
      expect(refused.reasons).toContain("continuous-unavailable");
    }
  }
  // Immediate quantization and plain KV keep their existing placement, adapters included.
  const immediate = { kvBits: 4, quantizedKvStart: 0 };
  expect(binding.plan(kv, immediate, scheduling)).toMatchObject({ mechanism: "continuous", checkpoint: true });
  expect(binding.plan({ ...kv, hasDraft: true }, immediate, scheduling).method).toBe("speculative");
  expect(binding.plan({ ...kv, hasAdapters: true }, { ...immediate, adapters: ["upper"] }, scheduling).mechanism).toBe("continuous");
  expect(binding.plan({ ...shape, hasAdapters: true }, { adapters: ["upper"] }, scheduling).mechanism).toBe("continuous");
  expect(binding.plan({ ...shape, hasDraft: true }, {}, scheduling).method).toBe("speculative");
  // Grammar jump over delayed affine KV falls back to ordinary grammar masking with its reason.
  const jump = withRuntimeConfig(createRuntimeConfig({ MLX_BUN_GRAMMAR_JUMP: "1" }), () => bindMlxGateway(universal()));
  const masked = jump.plan({ ...kv, hasGrammar: true }, { kvBits: 4, quantizedKvStart: 8 }, { continuous: true, quantizedBatch: true, checkpoints: false });
  expect(masked).toMatchObject({ mechanism: "continuous", method: "autoregressive", grammarJump: false });
  expect(masked.reasons).toContain("grammar-jump-incompatible-with-request");
});

// A strict or echo fill session; placement reads only its plan.
const fillOptions = (echo: boolean) => ({ fill: new FillSession({ rows: [], eos: [],
  echo: echo ? { k: 8, maxSpan: 8, maxCandidates: 24, indexMax: 1024 } : null }, [2, 651]) });

test.each(families)("%s places plain-KV fill on the shared fill binding", (_, model) => {
  const binding = bindMlxGateway(model());
  for (const echo of [false, true]) {
    const options = fillOptions(echo);
    for (const extra of [{}, { userSeed: true }, { hasRepetitionPenalty: true }, { hasLogitsExtras: true }]) {
      const plan = binding.plan({ ...shape, ...extra }, options, { ...schedule, continuous: binding.cachesBatchable() });
      expect({ extra, plan }).toMatchObject({ extra, plan: { method: "autoregressive", mechanism: "continuous", fill: true, checkpoint: false } });
      expect(refusals(plan)).toEqual([]);
      expect(JSON.parse(binding.methodRequest!(plan, options)!.key)[0]).toBe("fill");
    }
  }
});

/** A two-model provider for placement only: its grouped rows must never open here. */
function twoModelDraft(): TwoModelProvider {
  const unexpected = () => { throw new Error("placement opened draft rows"); };
  return Object.assign(Object.create(TwoModelProvider.prototype), { id: "gemma2-draft", weightsBytes: 0,
    grouped: { checkpointNamespace: () => "gemma2-draft", open: unexpected, openPrefill: unexpected } }) as TwoModelProvider;
}

test.each([["two-model", twoModelDraft, "gemma2-draft"], ["n-gram", () => new NgramProvider(), "ngram"]] as const)(
  "Gemma2 softcap speculates with the %s provider over plain KV", (_, provider, id) => {
  const binding = bindMlxGateway(softcapUniversal(), { provider: provider(), numDraftTokens: 3 });
  const scheduling = { ...schedule, continuous: binding.cachesBatchable(), checkpoints: true };
  binding.configureContinuation!({ checkpointPersistence: {}, checkpoints: {}, checkpointEveryTokens: 4 } as never);
  const draft = { ...shape, hasDraft: true };
  // Grammar is shared sampling: the target's mask rides the verifier's accept walk, as in main.
  for (const [request, options] of [[draft, {}], [{ ...draft, userSeed: true, hasRepetitionPenalty: true }, { seed: 3, repetitionPenalty: 1.1 }],
    [draft, { logitBias: { 5: -100 } }], [{ ...draft, hasGrammar: true }, {}]] as const) {
    const plan = binding.plan(request, options as GenerateOptions, scheduling);
    expect({ request, plan }).toMatchObject({ request, plan: { method: "speculative", mechanism: "continuous", fill: false, checkpoint: false } });
    expect(refusals(plan)).toEqual([]);
    expect(JSON.parse(binding.methodRequest!(plan, options as GenerateOptions)!.key).slice(0, 2)).toEqual(["speculative", id]);
  }
  // As main's serial path did, a logprobs request ignores its draft and decodes ordinarily.
  const logprobs = binding.plan({ ...draft, wantsLogprobs: true }, {}, scheduling);
  expect(logprobs).toMatchObject({ method: "autoregressive", mechanism: "continuous" });
  expect(logprobs.reasons).toContain("draft-incompatible-with-request");
  // Encoded KV, media and paging stay refused, including when fill is supplied.
  for (const [request, options, expected] of [
    [{ ...draft, kvQuant: true }, { kvBits: 4 }, ["kv-scheme-batch-unsupported"]],
    [{ ...draft, turboQuant: true }, { turboQuant: { kBits: 8, vBits: 3 } }, ["turbo-kv-batch-unsupported"]],
    [{ ...draft, hasVision: true }, {}, ["media-batch-unsupported"]],
    [draft, { pagedKv: {} }, ["paged-kv-batch-unsupported"]],
  ] as const) {
    for (const supplied of [options, { ...options, ...fillOptions(true) }]) {
      const plan = binding.plan(request, supplied as GenerateOptions, scheduling);
      expect({ request, mechanism: plan.mechanism }).toEqual({ request, mechanism: "unsupported" });
      for (const reason of expected) expect({ request, reasons: plan.reasons }).toMatchObject({ request, reasons: expect.arrayContaining([reason]) });
    }
  }
  // Plain softcap requests without a draft keep their placement; grammar proposals stay off this graph.
  expect(binding.plan(shape, {}, scheduling)).toMatchObject({ method: "autoregressive", mechanism: "continuous", checkpoint: true });
  const jump = withRuntimeConfig(createRuntimeConfig({ MLX_BUN_GRAMMAR_JUMP: "1" }),
    () => bindMlxGateway(softcapUniversal(), { provider: provider(), numDraftTokens: 3 }));
  expect(jump.plan({ ...shape, hasGrammar: true }, {}, schedule)).toMatchObject({ method: "autoregressive", grammarJump: false });
});

test.each([["two-model", twoModelDraft], ["n-gram", () => new NgramProvider()]] as const)(
  "Gemma2 softcap ignores fill with the %s draft, as main's serial verifier did", (_, provider) => {
  const binding = bindMlxGateway(softcapUniversal(), { provider: provider(), numDraftTokens: 3 });
  const scheduling = { ...schedule, continuous: binding.cachesBatchable() };
  const strict = new FillSession({ rows: [{ trigger: [651], emit: [42, 43], kind: "scaffold" }], eos: [], echo: null }, [2, 651]);
  let verifyCalls = 0;
  const verify = new FillSession({ rows: [], eos: [], echo: null }, [2, 651], { sources: [{
    name: "verify", windowNeeded: 1,
    propose: () => { verifyCalls++; return { ids: [42, 43], policy: "verify", origin: "echo" }; },
  }] });
  for (const fill of [strict, verify, fillOptions(true).fill]) for (const wantsLogprobs of [false, true]) {
    const request = { ...shape, hasDraft: true, wantsLogprobs };
    const options: GenerateOptions = { fill, maxTokens: 16, temperature: 0,
      ...(wantsLogprobs ? { logprobs: true, topLogprobs: 3 } : {}) };
    const plan = binding.plan(request, options, scheduling);
    expect(plan).toMatchObject({ method: wantsLogprobs ? "autoregressive" : "speculative",
      mechanism: "continuous", fill: false, checkpoint: false });
    expect(refusals(plan)).toEqual([]);
    expect(plan.reasons).toContain("fill-incompatible-with-request");
    const method = binding.methodRequest!(plan, options);
    if (wantsLogprobs) {
      expect(plan.reasons).toContain("draft-incompatible-with-request");
      expect(method).toBeUndefined();
    } else {
      const { fill: ignored, ...numericalOptions } = options;
      expect(method!.data).toEqual({ ...numericalOptions, fill: undefined });
      expect(method!.key).toBe(binding.methodRequest!(binding.plan(request, numericalOptions, scheduling), numericalOptions)!.key);
      expect(options.fill).toBe(ignored); // stripping does not mutate the caller's session
    }
  }
  expect(verifyCalls).toBe(0);
});

test("softcap drafts ignore echo even if their provider advertises external tokens; other graphs retain echo", () => {
  const provider = new NgramProvider();
  Object.defineProperty(provider.grouped, "supportsExternalTokens", { value: true });
  const options = fillOptions(true), request = { ...shape, hasDraft: true };
  const softcap = bindMlxGateway(softcapUniversal(), { provider, numDraftTokens: 3 });
  const plan = softcap.plan(request, options, schedule);
  expect(plan).toMatchObject({ method: "speculative", mechanism: "continuous", fill: false });
  expect((softcap.methodRequest!(plan, options)!.data as GenerateOptions).fill).toBeUndefined();
  for (const [, model] of qualifiedFamilies) {
    const binding = bindMlxGateway(model(), { provider, numDraftTokens: 3 });
    const other = binding.plan(request, options, schedule);
    expect(other).toMatchObject({ method: "speculative", mechanism: "continuous", fill: true });
    expect((binding.methodRequest!(other, options)!.data as GenerateOptions).fill).toBe(options.fill);
  }
});

test.each([["two-model", twoModelDraft], ["n-gram", () => new NgramProvider()]] as const)(
  "Gemma2 softcap adapters ignore the %s draft and fill, preserving ordinary decoding", (_, provider) => {
  const model = softcapUniversal();
  const binding = bindMlxGateway(model, { provider: provider(), numDraftTokens: 3 });
  const scheduling = { ...schedule, continuous: binding.cachesBatchable(), checkpoints: true };
  binding.configureContinuation!({ checkpointPersistence: {}, checkpoints: {}, checkpointEveryTokens: 4 } as never);
  const request = { ...shape, hasDraft: true, hasAdapters: true };
  for (const fill of [undefined, fillOptions(false).fill, fillOptions(true).fill]) {
    for (const extra of [{}, { wantsLogprobs: true }, { userSeed: true }, { hasGrammar: true }]) {
      const options: GenerateOptions = { adapters: ["upper"], fill, ...(extra.userSeed ? { seed: 42 } : {}) };
      const plan = binding.plan({ ...request, ...extra }, options, scheduling);
      expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous", fill: false,
        checkpoint: false, promptCache: true, grammarJump: false });
      expect(refusals(plan)).toEqual([]);
      expect(plan.reasons).toContain("draft-incompatible-with-request");
      if (fill) expect(plan.reasons).toContain("fill-incompatible-with-request");
      // Dispatch must consume neither provider nor fill, even if both were supplied.
      expect(binding.methodRequest!(plan, options)).toBeUndefined();
    }
  }
  const previous = model.loraState.active;
  const leave = binding.bindAdapterContext!(["upper"], "upper").enter();
  expect(model.loraState.active).toEqual(["upper"]);
  leave();
  expect(model.loraState.active).toBe(previous);
  for (const [extra, options, reason] of [
    [{ kvQuant: true }, { kvBits: 4 }, "kv-scheme-batch-unsupported"],
    [{ turboQuant: true }, { turboQuant: { kBits: 8, vBits: 3 } }, "turbo-kv-batch-unsupported"],
    [{ hasVision: true }, {}, "media-batch-unsupported"],
    [{}, { pagedKv: {} }, "paged-kv-batch-unsupported"],
  ] as const) {
    const plan = binding.plan({ ...request, ...extra }, { ...options, adapters: ["upper"] } as GenerateOptions, scheduling);
    expect(plan.mechanism).toBe("unsupported");
    expect(plan.reasons).toContain(reason);
  }
});

test("Gemma2 softcap keeps other grouped draft providers unsupported", () => {
  const unexpected = () => { throw new Error("placement opened draft rows"); };
  const other = { id: "other", weightsBytes: 0, grouped: { checkpointNamespace: () => "other", open: unexpected, openPrefill: unexpected } };
  const binding = bindMlxGateway(softcapUniversal(), { provider: other as never, numDraftTokens: 3 });
  const plan = binding.plan({ ...shape, hasDraft: true }, {}, { ...schedule, continuous: binding.cachesBatchable() });
  expect(plan).toMatchObject({ method: "speculative", mechanism: "unsupported" });
  expect(refusals(plan)).toEqual(["continuous-unavailable", "method-batch-unsupported"]);
  const adapted = binding.plan({ ...shape, hasDraft: true, hasAdapters: true },
    { adapters: ["upper"], ...fillOptions(true) }, schedule);
  expect(adapted).toMatchObject({ method: "autoregressive", mechanism: "unsupported", fill: false });
  expect(refusals(adapted)).toEqual(["continuous-unavailable"]);
  expect(binding.methodRequest!(adapted, fillOptions(true))).toBeUndefined();
  // The same provider places on a qualified family.
  const qualified = bindMlxGateway(qualifiedFamilies[0]![1](), { provider: other as never, numDraftTokens: 3 });
  expect(qualified.plan({ ...shape, hasDraft: true }, {}, schedule)).toMatchObject({ method: "speculative", mechanism: "continuous" });
});

test("Gemma2 softcap fill runs with adapters and keeps encoded KV and unbound drafts unsupported", () => {
  const options = fillOptions(true);
  const plain = bindMlxGateway(softcapUniversal());
  for (const [binding, request, expected] of [
    [plain, { ...shape, kvQuant: true }, ["kv-scheme-batch-unsupported"]],
    [plain, { ...shape, turboQuant: true }, ["turbo-kv-batch-unsupported"]],
    [plain, { ...shape, hasDraft: true }, ["continuous-unavailable", "method-batch-unsupported"]],
  ] as const) {
    const plan = binding.plan(request, options, { ...schedule, continuous: binding.cachesBatchable() });
    expect({ request, plan }).toMatchObject({ request, plan: { mechanism: "unsupported", fill: false } });
    expect(refusals(plan)).toEqual([...expected]);
    expect(plan.reasons).toContain("fill-incompatible-with-request");
  }
  // Fill with adapters is placed on the shared fill binding, as for every family;
  // the request's adapter context encloses the fill group.
  for (const binding of [plain, bindMlxGateway(qualifiedFamilies[0]![1]())]) {
    const plan = binding.plan({ ...shape, hasAdapters: true }, { ...options, adapters: ["upper"] }, { ...schedule, continuous: binding.cachesBatchable() });
    expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous", fill: true, checkpoint: false });
    expect(refusals(plan)).toEqual([]);
  }
});
