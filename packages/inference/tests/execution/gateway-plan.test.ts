import { describe, expect, test } from "bun:test";
import { bindMlxGateway, type MlxGatewayBinding } from "../../src/execution/gateway-binding";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/runtime/config";
import { Gemma4Model } from "../../src/models/gemma4/model";
import { UniversalDenseModel } from "../../src/models/universal/dense";
import { universalCacheWindows, type UniversalArgs } from "../../src/models/universal/archs";
import { KVCache } from "../../src/state/kv";
import { RotatingKVCache } from "../../src/state/rotating-kv";
import { SSMCache } from "../../src/state/ssm";
import { KvScheme } from "../../src/state/kv-scheme";
import type { GenerateOptions } from "../../src/generation/index";
import type { ResolvedExecution } from "../../src/contracts/portable/execution";
import type { RuntimeModel } from "../../src/models/factory";
import { NgramProvider } from "../../src/generation/speculative/sources/ngram-source";
import type { DraftProvider } from "../../src/generation/speculative/source";
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
    args: { modelType: "gemma2", maskArray: true, attnLogitSoftcap: 50, layerTypes: null }, encodedKvAttention: false,
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
// one class whose grammar jump commits forced spans instead of verifying proposals.
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

test("Gemma2 softcap grammar and adapter requests plan continuous; its KV schemes follow the scheme's dense-read certification", () => {
  for (const env of environments) {
    for (const request of [shape, grammar, { ...shape, hasAdapters: true }, { ...grammar, hasAdapters: true }])
      expect(planUnder(env, softcapUniversal(), request))
        .toMatchObject({ mechanism: "continuous", fill: false, checkpoint: false, grammarJump: false });
    // The gateway's scheduling fact carries the scheme's certification (kvBatchable).
    for (const [request, reason] of [[{ ...grammar, kvQuant: true }, "kv-scheme-batch-unsupported"],
      [{ ...grammar, turboQuant: true }, "turbo-kv-batch-unsupported"]] as const) {
      const binding = withRuntimeConfig(createRuntimeConfig(env), () => bindMlxGateway(softcapUniversal()));
      const refused = binding.plan(request, {}, { ...schedule, quantizedBatch: false });
      expect(refused.mechanism).toBe("unsupported");
      expect(refused.reasons).toContain(reason);
      expect(binding.plan(request, {}, schedule)).toMatchObject({ method: "autoregressive", mechanism: "continuous" });
    }
  }
});

test("a dense-read graph takes KV schemes whose own maintenance certifies dense reads, probed per scheme", () => {
  const gemma2 = () => universal({ modelType: "gemma2", maskArray: true, attnLogitSoftcap: 50 });
  const binding = bindMlxGateway(gemma2());
  for (const scheme of [new KvScheme("bf16", {}), resolveKvScheme({ override: 4, quantizedKvStart: 0 }),
    resolveKvScheme({ override: 8, quantizedKvStart: 64 }), resolveKvScheme({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 }),
    resolveKvScheme({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 64 })])
    expect(binding.kvBatchable(scheme), scheme.cacheKey).toBe(true);
  // The probe is the storage's answer: layers whose storage cannot certify keep the scheme off.
  const opaque = gemma2(); opaque.makeCache = () => [new KVCache(), new SSMCache(), new KVCache(), new KVCache()];
  expect(bindMlxGateway(opaque).kvBatchable(resolveKvScheme({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 }))).toBe(false);
  // Every probe cache is released, whether the probe certifies or throws.
  for (const failing of [false, true]) {
    const made: { dispose(): void }[] = [], disposed = new Set<object>();
    const track = <T extends { dispose(): void }>(cache: T): T => {
      const dispose = cache.dispose.bind(cache);
      cache.dispose = () => { disposed.add(cache); dispose(); };
      made.push(cache); return cache;
    };
    const counted = gemma2();
    counted.makeCache = () => {
      const ring = new RotatingKVCache(8);   // never wrapped by TurboQuant maintenance: its answer is read directly
      if (failing) Object.defineProperty(ring, "denseKvReads", { get() { throw new Error("probe failed"); } });
      return [track(new KVCache()), track(ring)];
    };
    const binding = bindMlxGateway(counted);
    const probe = () => binding.kvBatchable(resolveKvScheme({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 }));
    if (failing) expect(probe).toThrow("probe failed"); else expect(probe()).toBe(true);
    expect(made.length).toBeGreaterThan(2);
    expect(made.filter(cache => !disposed.has(cache))).toEqual([]);
  }
});

test("TurboQuant on a dense-read graph decodes as main did: drafts and supplied fill are ignored, certified grammar spans commit", () => {
  const turbo = { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 } as GenerateOptions;
  const request = { ...shape, turboQuant: true }, scheduling = { continuous: true, quantizedBatch: true, checkpoints: true };
  const drafted = bindMlxGateway(softcapUniversal(), { provider: new NgramProvider(), numDraftTokens: 3 });
  drafted.configureContinuation!({ checkpointPersistence: {} } as never);
  // A configured draft is ignored: ordinary continuous decoding with its checkpoints.
  const ignored = drafted.plan({ ...request, hasDraft: true }, turbo, scheduling);
  expect(ignored).toMatchObject({ method: "autoregressive", mechanism: "continuous", checkpoint: true });
  expect(ignored.reasons).toContain("draft-incompatible-with-request");
  expect(drafted.methodRequest!(ignored, turbo)).toBeUndefined();
  // Supplied fill decodes ordinarily, as main's did: main filled only through a
  // committed append declaring TurboQuant formats, which this graph lacks. No fill
  // method binds, and a request supplying fill stays ineligible for checkpoints.
  const plain = bindMlxGateway(softcapUniversal());
  plain.configureContinuation!({ checkpointPersistence: {} } as never);
  const withFill = { ...turbo, ...fillOptions(false) };
  for (const other of [{}, { userSeed: true }, { wantsLogprobs: true }, { hasGrammar: true }]) {
    const plan = plain.plan({ ...request, ...other }, withFill, scheduling);
    expect(plan, JSON.stringify(other)).toMatchObject({ method: "autoregressive", mechanism: "continuous", fill: false, checkpoint: false });
    expect(refusals(plan)).toEqual([]);
    expect(plan.reasons).toContain("fill-incompatible-with-request");
    expect(plain.methodRequest!(plan, withFill)).toBeUndefined();
  }
  // Direct grammar jump commits spans over TurboQuant, as main's serial path did,
  // once the gateway has certified the scheme; grammar keeps its checkpoint exclusion.
  const jumpRuntime = createRuntimeConfig({ MLX_BUN_GRAMMAR_JUMP: "1" });
  const jumping = withRuntimeConfig(jumpRuntime, () => bindMlxGateway(softcapUniversal()));
  jumping.configureContinuation!({ checkpointPersistence: {} } as never);
  const spans = jumping.plan({ ...request, hasGrammar: true }, turbo, scheduling);
  expect(spans).toMatchObject({ method: "autoregressive", mechanism: "continuous", grammarJump: true, fill: false, checkpoint: false });
  expect(refusals(spans)).toEqual([]);
  expect(jumping.methodRequest!(spans, turbo)!.key).toBe("grammar-forced-span");
  // Logprobs keep masking; an uncertified scheme is refused.
  expect(jumping.plan({ ...request, hasGrammar: true, wantsLogprobs: true }, turbo, scheduling))
    .toMatchObject({ mechanism: "continuous", grammarJump: false });
  expect(jumping.plan({ ...request, hasGrammar: true }, turbo, { ...scheduling, quantizedBatch: false }).mechanism).toBe("unsupported");
  // Certified delayed affine KV commits spans the same way; the span method
  // refuses a row before an append its storage would no longer read plain.
  const affineKv = { kvBits: 4 }, affineRequest = { ...shape, kvQuant: true, hasGrammar: true };
  const affine = jumping.plan(affineRequest, affineKv, scheduling);
  expect(affine).toMatchObject({ method: "autoregressive", mechanism: "continuous", grammarJump: true, fill: false, checkpoint: false });
  expect(refusals(affine)).toEqual([]);
  expect(jumping.methodRequest!(affine, affineKv)!.key).toBe("grammar-forced-span");
  expect(jumping.plan({ ...affineRequest, wantsLogprobs: true }, affineKv, scheduling))
    .toMatchObject({ mechanism: "continuous", grammarJump: false });
  expect(jumping.plan(affineRequest, affineKv, { ...scheduling, quantizedBatch: false }).mechanism).toBe("unsupported");
  // A configured draft is ignored and the spans still commit, as in main.
  const draftedJump = withRuntimeConfig(jumpRuntime,
    () => bindMlxGateway(softcapUniversal(), { provider: new NgramProvider(), numDraftTokens: 3 }));
  const ignoredJump = draftedJump.plan({ ...request, hasGrammar: true, hasDraft: true }, turbo, scheduling);
  expect(ignoredJump).toMatchObject({ method: "autoregressive", mechanism: "continuous", grammarJump: true });
  expect(draftedJump.methodRequest!(ignoredJump, turbo)!.key).toBe("grammar-forced-span");
  // Without the jump flag, grammar masks as ever.
  expect(plain.plan({ ...request, hasGrammar: true }, turbo, schedule)).toMatchObject({ mechanism: "continuous", grammarJump: false });
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

test("Gemma2 softcap selects committed grammar spans without changing the ordinary lane", () => {
  const binding = withRuntimeConfig(createRuntimeConfig({ MLX_BUN_GRAMMAR_JUMP: "1" }),
    () => bindMlxGateway(softcapUniversal()));
  const plan = place(binding, grammar);
  expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous", grammarJump: true,
    checkpoint: false, promptCache: true, fill: false });
  expect(plan.reasons).not.toContain("grammar-jump-incompatible-with-request");
  expect(binding.methodRequest!(plan, {})!.key).toBe("grammar-forced-span");
  expect(refusals(plan)).toEqual([]);
  // This preexisting paging admission limitation is not changed by adding a
  // grammar method. Actual paged Gemma2 remains unqualified, including the
  // separately tracked adapter-bypass request shape.
  expect(binding.plan({ ...grammar, hasAdapters: true }, { pagedKv: {} }, schedule))
    .toMatchObject({ mechanism: "unsupported", pagedKv: false, grammarJump: false });
  for (const request of [{ ...grammar, wantsLogprobs: true }, { ...grammar, hasVision: true }])
    expect(place(binding, request).grammarJump).toBe(false);
  // Once the gateway has certified the scheme, spans commit over TurboQuant,
  // which decodes on read, and over affine KV until a row stops reading plain;
  // an uncertified scheme stays refused.
  for (const kv of [{ turboQuant: true }, { kvQuant: true }]) {
    expect(place(binding, { ...grammar, ...kv }), JSON.stringify(kv)).toMatchObject({ mechanism: "continuous", grammarJump: true });
    expect(binding.plan({ ...grammar, ...kv }, {}, { ...schedule, quantizedBatch: false }), JSON.stringify(kv))
      .toMatchObject({ mechanism: "unsupported", grammarJump: false });
  }
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
    args: { modelType: "llama", maskArray: false, attnLogitSoftcap: null, layerTypes: null }, encodedKvAttention: true,
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
  expect(bindMlxGateway(standIn(Qwen3Model.prototype, "qwen3"))
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
    // Genuine delayed speculation stays refused; supplied fill follows main's ordinary fallback.
    for (const [request, options] of [[{ ...kv, hasDraft: true }, delayed]] as const) {
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

/** A universal descriptor with the graph's own cache layout: caches follow the descriptor. */
function universal(args: Record<string, unknown> = {}, layers = 4): UniversalDenseModel {
  const descriptor = { modelType: "qwen2", maskArray: false, attnLogitSoftcap: null, layerTypes: null, slidingWindow: null,
    numHiddenLayers: layers, ...args };
  return Object.assign(Object.create(UniversalDenseModel.prototype), {
    args: descriptor,
    // The bound attention fact a constructed graph derives from this descriptor.
    encodedKvAttention: descriptor.attnLogitSoftcap === null,
    makeCache: () => universalCacheWindows(descriptor as unknown as UniversalArgs)
      .map(window => window ? new RotatingKVCache(window) : new KVCache()),
    config: { modelType: descriptor.modelType, text: { enableMoeBlock: false, numHiddenLayers: layers,
      layerTypes: (descriptor.layerTypes as string[] | null) ?? Array(layers).fill("full_attention") }, eosTokenIds: [] },
    loraState: { active: [] },
  });
}

// Graphs whose bound attention reads encoded KV and whose layers all convert,
// plain or rotating, share one delayed-affine policy.
const SLIDING = ["full_attention", "sliding_attention", "full_attention", "sliding_attention"];
for (const [name, make] of [
  ["plain", () => universal()],
  ["mixed full/sliding", () => universal({ modelType: "llama", layerTypes: SLIDING, slidingWindow: 16 })],
  ["mixed sliding/full", () => universal({ modelType: "llama", layerTypes: [...SLIDING].reverse(), slidingWindow: 16 })],
  ["explicit mask, mixed", () => universal({ modelType: "llama", maskArray: true, layerTypes: SLIDING, slidingWindow: 16 })],
] as [string, () => UniversalDenseModel][]) test(`${name} universal KV batches delayed affine KV for ordinary continuous decoding and its generation checkpoints`, () => {
  const model = make();
  expect(model.makeCache().some(cache => cache instanceof RotatingKVCache)).toBe(name !== "plain");
  const binding = bindMlxGateway(model, { provider: { grouped: {} } as never, numDraftTokens: 4 });
  const config = [{ layerIdx: 0, bits: 8, groupSize: 64 }, { layerIdx: 2, bits: 4, groupSize: 64 }];
  const delayedSchemes = [resolveKvScheme({ override: 4, quantizedKvStart: 8 }), resolveKvScheme({ override: 8, quantizedKvStart: 8 }),
    resolveKvScheme({ override: "config", config, quantizedKvStart: 8 })];
  for (const scheme of delayedSchemes) expect(binding.kvBatchable(scheme)).toBe(true);
  expect(binding.kvBatchable(resolveKvScheme({ override: 4, quantizedKvStart: 0 }))).toBe(true);

  binding.configureContinuation!({ checkpointPersistence: {} } as never);
  const kv = { ...shape, kvQuant: true }, scheduling = { continuous: true, quantizedBatch: true, checkpoints: true };
  const fill = { fill: { plan: { echo: false } } } as never;
  for (const delayed of [{ kvBits: 4, quantizedKvStart: 8 }, { kvBits: 8 }, { kvConfig: config, quantizedKvStart: 8 }] as const) {
    // Main checkpointed this generation through its serial executor.
    expect(binding.plan(kv, delayed, scheduling)).toMatchObject({ method: "autoregressive", mechanism: "continuous", checkpoint: true });
    expect(binding.plan({ ...kv, userSeed: true, hasRepetitionPenalty: true }, { ...delayed, seed: 3, repetitionPenalty: 1.1 }, scheduling))
      .toMatchObject({ mechanism: "continuous", checkpoint: true });
    expect(bindMlxGateway(make()).plan(kv, delayed, scheduling)).toMatchObject({ mechanism: "continuous", checkpoint: false });
    // Grammar and logprobs ride shared sampling, without checkpoints as for every family.
    for (const request of [{ hasGrammar: true }, { wantsLogprobs: true }])
      expect(binding.plan({ ...kv, ...request }, delayed, scheduling)).toMatchObject({ mechanism: "continuous", checkpoint: false });
    // Adapters compose with the ordinary row and its continuation, as on main.
    const adapted = { ...kv, hasAdapters: true };
    const options = { ...delayed, adapters: ["upper"] };
    const plan = binding.plan(adapted, options, scheduling);
    expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous", checkpoint: true,
      fill: false, grammarJump: false, compiledDecode: false });
    expect(binding.methodRequest!(plan, options)).toBeUndefined();
    for (const extra of [{ hasGrammar: true }, { wantsLogprobs: true }])
      expect(binding.plan({ ...adapted, ...extra }, options, scheduling))
        .toMatchObject({ mechanism: "continuous", checkpoint: false });
    expect(binding.plan({ ...adapted, hasDraft: true }, options, scheduling))
      .toMatchObject({ method: "autoregressive", mechanism: "continuous", checkpoint: true, fill: false });
    expect(binding.plan(adapted, { ...options, ...(fill as object) }, scheduling))
      .toMatchObject({ mechanism: "continuous", method: "autoregressive", fill: false, checkpoint: false });
    // Genuine delayed speculation remains refused.
    const refusals: [typeof kv, GenerateOptions][] = [[{ ...kv, hasDraft: true }, delayed]];
    for (const [request, options] of refusals) {
      const refused = binding.plan(request, options, scheduling);
      expect(refused.mechanism).toBe("unsupported");
      expect(refused.reasons).toContain("continuous-unavailable");
    }
  }
  const previous = model.loraState.active;
  const selected = ["upper"];
  const context = binding.bindAdapterContext!(selected, "upper");
  selected.push("caller-change");
  const leave = context.enter();
  expect(model.loraState.active).toEqual(["upper"]);
  leave();
  expect(model.loraState.active).toBe(previous);
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

/** The n-gram provider's operations behind a plain object: no class identity, same contracts. */
function delegatingNgram(): DraftProvider {
  const inner = new NgramProvider(), grouped = inner.grouped;
  return { id: "ngram-delegate", weightsBytes: 0, open: options => inner.open(options), dispose: () => inner.dispose(),
    grouped: { checkpointNamespace: () => grouped.checkpointNamespace!(), supportsTargetAdapters: grouped.supportsTargetAdapters,
      ...(grouped.targetTapLayers ? { targetTapLayers: target => grouped.targetTapLayers!(target) } : {}),
      open: options => grouped.open(options), openPrefill: options => grouped.openPrefill(options) } };
}

test.each([["two-model", twoModelDraft, "gemma2-draft"], ["n-gram", () => new NgramProvider(), "ngram"],
  ["delegating n-gram", delegatingNgram, "ngram-delegate"]] as const)(
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
  // Over encoded KV, TurboQuant read decoded or affine until a row's transition,
  // a drafted request decodes ordinarily: the draft is ignored, and so is supplied
  // fill, as for any drafted request; checkpoints follow the ordinary rules.
  const turbo = { turboQuant: { kBits: 8, vBits: 3 } } as GenerateOptions;
  const affine = { kvBits: 4, quantizedKvStart: 64 } as GenerateOptions;
  for (const [flag, kv] of [[{ turboQuant: true }, turbo], [{ kvQuant: true }, affine]] as const)
    for (const supplied of [kv, { ...kv, ...fillOptions(true) }]) {
      const plan = binding.plan({ ...draft, ...flag }, supplied, scheduling);
      expect(plan, JSON.stringify(flag)).toMatchObject({ method: "autoregressive", mechanism: "continuous", fill: false, checkpoint: !supplied.fill });
      expect(plan.reasons).toContain("draft-incompatible-with-request");
      expect(binding.methodRequest!(plan, supplied)).toBeUndefined();
    }
  // Drafted media and paging stay refused, including when fill is supplied.
  for (const [request, options, expected] of [
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
  expect(jump.plan({ ...shape, hasGrammar: true }, {}, schedule)).toMatchObject({ method: "autoregressive", grammarJump: true });
  expect(jump.plan({ ...shape, hasGrammar: true, hasAdapters: true, hasDraft: true }, {}, schedule))
    .toMatchObject({ method: "autoregressive", mechanism: "continuous", grammarJump: true });
  expect(jump.plan({ ...shape, hasGrammar: true, hasDraft: true }, {}, schedule))
    .toMatchObject({ method: "speculative", mechanism: "continuous", grammarJump: false });
});

test.each([["two-model", twoModelDraft], ["n-gram", () => new NgramProvider()], ["delegating n-gram", delegatingNgram]] as const)(
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

test.each([["two-model", twoModelDraft], ["n-gram", () => new NgramProvider()], ["delegating n-gram", delegatingNgram]] as const)(
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
      // The ignored draft leaves the ordinary checkpoint rules: no fill, grammar
      // or logprobs.
      expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous", fill: false,
        checkpoint: !fill && !("wantsLogprobs" in extra) && !("hasGrammar" in extra), promptCache: true, grammarJump: false });
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
  // Over affine KV the adapter request likewise ignores the draft and decodes
  // ordinarily, as on the other graphs restricted to ordinary affine execution,
  // and over TurboQuant as main's serial path did, keeping its checkpoints.
  for (const [extra, kv] of [[{ kvQuant: true }, { kvBits: 4 }], [{ turboQuant: true }, { turboQuant: { kBits: 8, vBits: 3 } }]] as const) {
    const options = { ...kv, adapters: ["upper"] } as GenerateOptions;
    const ordinary = binding.plan({ ...request, ...extra }, options, scheduling);
    expect(ordinary, JSON.stringify(kv)).toMatchObject({ method: "autoregressive", mechanism: "continuous", fill: false,
      checkpoint: true, grammarJump: false });
    expect(ordinary.reasons).toContain("draft-incompatible-with-request");
    expect(binding.methodRequest!(ordinary, options)).toBeUndefined();
  }
  for (const [extra, options, reason] of [
    [{ hasVision: true }, {}, "media-batch-unsupported"],
    [{}, { pagedKv: {} }, "paged-kv-batch-unsupported"],
  ] as const) {
    const plan = binding.plan({ ...request, ...extra }, { ...options, adapters: ["upper"] } as GenerateOptions, scheduling);
    expect(plan.mechanism).toBe("unsupported");
    expect(plan.reasons).toContain(reason);
  }
});

test("an adapter request its draft cannot serve decodes ordinarily with ordinary checkpoints on every graph", () => {
  // Including sliding and explicit-mask universal graphs: the draft is ignored
  // and the request checkpoints like a draftless adapter request.
  const graphs: [string, () => RuntimeModel][] = [...families,
    ["sliding universal", () => universal({ modelType: "llama", layerTypes: SLIDING, slidingWindow: 16 })],
    ["explicit-mask sliding universal", () => universal({ modelType: "llama", maskArray: true, layerTypes: SLIDING, slidingWindow: 16 })]];
  const services = { checkpointPersistence: {}, checkpoints: {}, checkpointEveryTokens: 4 } as never;
  const request = { ...shape, hasDraft: true, hasAdapters: true };
  const options: GenerateOptions = { adapters: ["upper"] };
  for (const [name, model] of graphs) {
    const binding = bindMlxGateway(model(), { provider: twoModelDraft(), numDraftTokens: 3 });
    binding.configureContinuation!(services);
    const scheduling = { ...schedule, continuous: binding.cachesBatchable(), checkpoints: true };
    const plan = binding.plan(request, options, scheduling);
    expect({ name, plan }).toMatchObject({ name, plan: { method: "autoregressive", mechanism: "continuous", checkpoint: true } });
    expect(plan.reasons).toContain("draft-incompatible-with-request");
    expect(binding.methodRequest!(plan, options)).toBeUndefined();
    for (const extra of [{ hasGrammar: true }, { wantsLogprobs: true }])
      expect({ name, extra, checkpoint: binding.plan({ ...request, ...extra }, options, scheduling).checkpoint })
        .toEqual({ name, extra, checkpoint: false });
    // The same draft still serves the request without adapters, uncheckpointed.
    expect({ name, plan: binding.plan({ ...shape, hasDraft: true }, {}, scheduling) })
      .toMatchObject({ name, plan: { method: "speculative", mechanism: "continuous", checkpoint: false } });
    // A provider that serves target adapters speculates with them, except on the
    // softcap graph, which serves adapters ordinarily.
    const aware = bindMlxGateway(model(), { provider: new NgramProvider(), numDraftTokens: 3 });
    aware.configureContinuation!(services);
    const softcap = name === "gemma2 softcap";
    expect({ name, plan: aware.plan(request, options, scheduling) }).toMatchObject({ name,
      plan: { method: softcap ? "autoregressive" : "speculative", mechanism: "continuous", checkpoint: softcap } });
  }
});

test.each(families)("%s places a delegating provider exactly like the provider it delegates to", (_, model) => {
  const direct = bindMlxGateway(model(), { provider: new NgramProvider(), numDraftTokens: 3 });
  const delegate = bindMlxGateway(model(), { provider: delegatingNgram(), numDraftTokens: 3 });
  for (const extra of [{}, { userSeed: true }, { hasGrammar: true }, { wantsLogprobs: true }, { hasAdapters: true },
    { hasRepetitionPenalty: true }] as const) {
    const request = { ...shape, hasDraft: true, ...extra };
    const options: GenerateOptions = "hasAdapters" in extra ? { adapters: ["upper"] } : {};
    const expected = direct.plan(request, options, { ...schedule, continuous: direct.cachesBatchable() });
    const plan = delegate.plan(request, options, { ...schedule, continuous: delegate.cachesBatchable() });
    expect({ extra, plan }).toEqual({ extra, plan: expected });
    if (plan.method === "speculative" && plan.mechanism === "continuous")
      expect(JSON.parse(delegate.methodRequest!(plan, options)!.key).slice(0, 2)).toEqual(["speculative", "ngram-delegate"]);
  }
});

/** A provider whose rows tap target hidden layers; placement must never open its rows. */
function tapper(layers: readonly number[]) {
  const unexpected = () => { throw new Error("placement opened draft rows"); };
  const taps = Object.freeze([...layers]);
  return { id: "tapper", weightsBytes: 0, grouped: { checkpointNamespace: () => "tapper",
    targetTapLayers: () => taps, open: unexpected, openPrefill: unexpected } } as never;
}

test("a provider that taps target layers binds only where the forward captures them; otherwise placement refuses it", () => {
  const request = { ...shape, hasDraft: true };
  const refused = (binding: MlxGatewayBinding) => {
    const plan = binding.plan(request, {}, { ...schedule, continuous: binding.cachesBatchable() });
    expect(plan).toMatchObject({ method: "speculative", mechanism: "unsupported" });
    expect(refusals(plan)).toEqual(["method-batch-unsupported"]);
    expect(plan.reasons).not.toContain("draft-incompatible-with-request");
  };
  // Graphs without a hidden-tap operation, softcap or not, refuse it rather than decode ordinarily.
  refused(bindMlxGateway(softcapUniversal(), { provider: tapper([2, 5]), numDraftTokens: 3 }));
  refused(bindMlxGateway(qualifiedFamilies[0]![1](), { provider: tapper([2, 5]), numDraftTokens: 3 }));
  // The Gemma4 graph fields its legacy target view reads, with and without the hidden-tap operation.
  const graph = (tap: boolean) => Object.assign(gemma4(), { numDonors: 8,
    layers: Array.from({ length: 8 }, () => ({ layerType: "full_attention" })), ...(tap ? { hiddenTap: null } : {}),
    config: { modelType: "gemma4", text: { enableMoeBlock: false, numHiddenLayers: 8 }, eosTokenIds: [] } });
  refused(bindMlxGateway(graph(false), { provider: tapper([2]), numDraftTokens: 3 }));
  // A graph whose forward captures hidden layers binds it within its layer range,
  // the post-final-norm sentinel included, and refuses layers beyond it.
  expect(bindMlxGateway(graph(true), { provider: tapper([2, 8]), numDraftTokens: 3 }).plan(request, {}, schedule))
    .toMatchObject({ method: "speculative", mechanism: "continuous" });
  refused(bindMlxGateway(graph(true), { provider: tapper([9]), numDraftTokens: 3 }));
  // Declaring no taps needs no tap operation.
  for (const model of [softcapUniversal(), qualifiedFamilies[0]![1]()])
    expect(bindMlxGateway(model, { provider: tapper([]), numDraftTokens: 3 }).plan(request, {}, { ...schedule, continuous: true }))
      .toMatchObject({ method: "speculative", mechanism: "continuous" });
});

test("Gemma2 softcap fill runs with adapters and keeps uncertified KV schemes and unbound drafts unsupported", () => {
  const options = fillOptions(true);
  const plain = bindMlxGateway(softcapUniversal());
  for (const [binding, request, expected] of [
    [plain, { ...shape, kvQuant: true }, ["kv-scheme-batch-unsupported"]],
    [plain, { ...shape, turboQuant: true }, ["turbo-kv-batch-unsupported"]],
    [plain, { ...shape, hasDraft: true }, ["method-batch-unsupported"]],
  ] as const) {
    // A scheme the gateway found uncertified (kvBatchable) is refused.
    const plan = binding.plan(request, options, { ...schedule, continuous: binding.cachesBatchable(), quantizedBatch: false });
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

test.each([["MiniCPM5", minicpm5], ["plain universal", universal]] as const)(
  "%s delayed affine adapter requests ignore every configured draft and fill, retaining ordinary checkpoints", (_, model) => {
    let opened = 0;
    const unexpected = () => { opened++; throw new Error("ignored draft provider was opened"); };
    // Structural providers deliberately have no built-in class identity. Both
    // grouped capabilities and the legacy-only provider stay unused.
    const providers = [new NgramProvider(), twoModelDraft(),
      { id: "custom-adapter-aware", weightsBytes: 0, open: unexpected,
        grouped: { supportsTargetAdapters: true, supportsExternalTokens: true,
          checkpointNamespace: unexpected, open: unexpected, openPrefill: unexpected } },
      { id: "custom-base-only", weightsBytes: 0, open: unexpected,
        grouped: { supportsTargetAdapters: false, checkpointNamespace: unexpected, open: unexpected, openPrefill: unexpected } },
      { id: "custom-legacy-only", weightsBytes: 0, open: unexpected }];
    for (const provider of providers) {
      const binding = bindMlxGateway(model(), { provider: provider as never, numDraftTokens: 3 });
      binding.configureContinuation!({ checkpointPersistence: {} } as never);
      for (const kv of [{ kvBits: 4, quantizedKvStart: 8 }, { kvBits: 8, quantizedKvStart: 8 },
        { kvConfig: [{ layerIdx: 0, bits: 4, groupSize: 64 }, { layerIdx: 2, bits: 8, groupSize: 64 }], quantizedKvStart: 8 }]) {
        const scheme = new KvScheme("kvBits" in kv ? "affine-uniform" : "affine-config", kv);
        const scheduling = { continuous: binding.cachesBatchable(), quantizedBatch: binding.kvBatchable(scheme), checkpoints: true };
        for (const fill of [undefined, fillOptions(false).fill, fillOptions(true).fill]) {
          for (const extra of [{}, { wantsLogprobs: true }, { hasGrammar: true }, { userSeed: true, hasRepetitionPenalty: true }]) {
            const request = { ...shape, ...extra, kvQuant: true, hasAdapters: true, hasDraft: true };
            const options = Object.freeze({ ...kv, adapters: ["upper"], ...(fill ? { fill } : {}) });
            const plan = binding.plan(request, options, scheduling);
            expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous", fill: false,
              checkpoint: !fill && !request.wantsLogprobs && !request.hasGrammar, grammarJump: false, compiledDecode: false });
            expect(plan.reasons).toContain("draft-incompatible-with-request");
            if (fill) expect(plan.reasons).toContain("fill-incompatible-with-request");
            expect(binding.methodRequest!(plan, options)).toBeUndefined();
            expect(binding.prefixNamespace!(plan, options, "adapter-namespace")).toBe("adapter-namespace");
            expect(options.fill).toBe(fill);
          }
        }
        const refused: [typeof shape, GenerateOptions][] = [[{ ...shape, kvQuant: true, hasDraft: true }, kv]];
        for (const [request, options] of refused)
          expect(binding.plan(request, options, scheduling).mechanism).toBe("unsupported");
        expect(binding.plan({ ...shape, kvQuant: true, hasAdapters: true, hasDraft: true },
          { ...kv, adapters: ["upper"], pagedKv: {} } as GenerateOptions, scheduling).mechanism).toBe("unsupported");
        expect(binding.plan({ ...shape, kvQuant: true, hasAdapters: true, hasDraft: true },
          { ...kv, adapters: ["upper"] }, { ...scheduling, quantizedBatch: false }).mechanism).toBe("unsupported");
      }
    }
    expect(opened).toBe(0);
  });


test.each([["MiniCPM5", minicpm5], ["plain universal", universal]] as const)(
  "%s delayed affine requests ignore supplied fill without binding a fill method", (_, model) => {
    const binding = bindMlxGateway(model());
    binding.configureContinuation!({ checkpointPersistence: {} } as never);
    for (const kv of [{ kvBits: 4, quantizedKvStart: 8 }, { kvBits: 8 },
      { kvConfig: [{ layerIdx: 0, bits: 4, groupSize: 64 }, { layerIdx: 2, bits: 8, groupSize: 64 }], quantizedKvStart: 8 }]) {
      const scheme = new KvScheme("kvBits" in kv ? "affine-uniform" : "affine-config", kv);
      const scheduling = { continuous: binding.cachesBatchable(), quantizedBatch: binding.kvBatchable(scheme), checkpoints: true };
      for (const echo of [false, true]) for (const extra of [{}, { hasAdapters: true }, { wantsLogprobs: true }, { userSeed: true }]) {
        const { fill } = fillOptions(echo);
        const stats = { ...fill.stats };
        const options = Object.freeze({ ...kv, fill, ...(extra.hasAdapters ? { adapters: ["upper"] } : {}),
          ...(extra.userSeed ? { seed: 3 } : {}) });
        const request = { ...shape, ...extra, kvQuant: true };
        const plan = binding.plan(request, options, scheduling);
        expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous", fill: false,
          checkpoint: false, grammarJump: false });
        expect(plan.reasons).toContain("fill-incompatible-with-request");
        expect(binding.methodRequest!(plan, options)).toBeUndefined();
        expect(options.fill).toBe(fill);
        expect(fill.stats).toEqual(stats);
        expect(binding.plan(request, options, { ...scheduling, quantizedBatch: false }).mechanism).toBe("unsupported");
        expect(binding.plan(request, { ...options, pagedKv: {} } as GenerateOptions, scheduling).mechanism).toBe("unsupported");
        expect(binding.plan({ ...request, hasVision: true }, options, scheduling).mechanism).toBe("unsupported");
      }
    }
  });

test("delayed affine KV needs the graph's encoded-attention fact and convertible layers", () => {
  const delayed = resolveKvScheme({ override: 4, quantizedKvStart: 64 });
  const plan = (model: UniversalDenseModel) => bindMlxGateway(model).kvBatchable(delayed);
  // Manual softcap attention reads dense KV: delayed affine rows batch through the
  // scheme's dense-read certification (rows past their transition are rejected).
  expect(plan(universal({ modelType: "gemma2", maskArray: true, attnLogitSoftcap: 50 }))).toBe(true);
  // A graph that does not state the fact is not assumed to read encoded KV.
  const silent = universal(); delete (silent as { encodedKvAttention?: boolean }).encodedKvAttention;
  expect(plan(silent)).toBe(false);
  // A layer without an affine conversion keeps the whole graph off delayed batching.
  const recurrent = universal(); recurrent.makeCache = () => [new KVCache(), new SSMCache(), new KVCache(), new KVCache()];
  expect(plan(recurrent)).toBe(false);
});

test("gateway policy follows the graph as bound, not a later descriptor", () => {
  const immediate = resolveKvScheme({ override: 4, quantizedKvStart: 0 }), delayed = resolveKvScheme({ override: 4, quantizedKvStart: 64 });
  // Bound without softcap; the descriptor later claims one: still encoded KV, not a softcap graph.
  const encoded = universal({ modelType: "llama", layerTypes: SLIDING, slidingWindow: 16 });
  (encoded.args as { attnLogitSoftcap: number | null }).attnLogitSoftcap = 50;
  const a = bindMlxGateway(encoded);
  expect([a.kvBatchable(immediate), a.kvBatchable(delayed)]).toEqual([true, true]);
  // Bound with softcap; the descriptor later drops it: still manual attention over
  // dense KV, admitting schemes through their dense-read certification, affine
  // and TurboQuant alike.
  const softcap = universal({ modelType: "gemma2", maskArray: true, attnLogitSoftcap: 50 });
  (softcap.args as { attnLogitSoftcap: number | null }).attnLogitSoftcap = null;
  const b = bindMlxGateway(softcap);
  expect([b.kvBatchable(immediate), b.kvBatchable(delayed), b.kvBatchable(new KvScheme("bf16", {})),
    b.kvBatchable(resolveKvScheme({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 }))]).toEqual([true, true, true, true]);
  // Its token-method policy is the softcap graph's, whatever the descriptor now says.
  const request = { ...shape, hasGrammar: true };
  expect(bindMlxGateway(softcap).plan(request, {}, schedule)).toEqual(bindMlxGateway(softcapUniversal()).plan(request, {}, schedule));
});

const LAYERS = ["full_attention", "sliding_attention", "full_attention", "sliding_attention"];

test("universal graphs batch and bind drafts through the operations their caches provide", () => {
  const graphs: [string, UniversalDenseModel][] = [
    ["plain", universal()],
    ["sliding, full first", universal({ modelType: "llama", layerTypes: LAYERS, slidingWindow: 16 })],
    ["sliding, sliding first", universal({ modelType: "llama", layerTypes: [...LAYERS].reverse(), slidingWindow: 16 })],
    ["explicit mask, mixed", universal({ modelType: "llama", maskArray: true, layerTypes: LAYERS, slidingWindow: 16 })],
    ["gemma2", universal({ modelType: "gemma2", maskArray: true, attnLogitSoftcap: 50 })],
  ];
  for (const [name, model] of graphs) {
    const binding = bindMlxGateway(model, { provider: new NgramProvider(), numDraftTokens: 4 });
    expect({ name, batchable: binding.cachesBatchable(), plan: place(binding, shape).mechanism,
      drafted: place(binding, { ...shape, hasDraft: true }).method })
      .toEqual({ name, batchable: true, plan: "continuous", drafted: "speculative" });
  }
});

test("storage is probed once per binding, released on every path and never touched again", () => {
  let made = 0;
  const released: string[] = [];
  /** A probe cache that records its release and fails on any later use. */
  const track = <T extends object>(name: string, cache: T): T => {
    let disposed = false;
    return new Proxy(cache, { get(target, key, receiver) {
      if (key === "dispose") return () => { disposed = true; released.push(name); (target as { dispose(): void }).dispose(); };
      if (disposed) throw new Error(`${name} used after release (${String(key)})`);
      return Reflect.get(target, key, receiver);
    } });
  };
  const model = universal({ modelType: "llama", layerTypes: LAYERS, slidingWindow: 16 });
  const makeCache = model.makeCache.bind(model);
  model.makeCache = () => { made++; return makeCache().map((cache, layer) => track(`layer ${layer}`, cache)); };
  const binding = bindMlxGateway(model, { provider: new NgramProvider(), numDraftTokens: 4 });
  expect({ made, released: released.length }).toEqual({ made: 1, released: 4 });
  // Planning reads the bound facts; request schemes and options stay dynamic.
  for (let round = 0; round < 3; round++) {
    expect(binding.cachesBatchable()).toBe(true);
    expect(binding.kvBatchable(resolveKvScheme({ override: 4, quantizedKvStart: 0 }))).toBe(true);
    // Encoded-KV attention with every layer convertible: a delayed start batches too.
    expect(binding.kvBatchable(resolveKvScheme({ override: 4, quantizedKvStart: 64 }))).toBe(true);
    for (const request of [shape, { ...shape, hasDraft: true }, { ...shape, kvQuant: true }]) place(binding, request);
  }
  expect({ made, released: released.length }).toEqual({ made: 1, released: 4 });

  // A probe predicate that throws still releases every probe cache.
  released.length = 0;
  const failing = universal();
  failing.makeCache = () => [track("kept", new KVCache()), new Proxy({}, { get(_target, key) {
    if (key === "dispose") return () => { released.push("failed"); };
    throw new Error("probe failed");
  } }) as never];
  expect(() => bindMlxGateway(failing)).toThrow("probe failed");
  expect(released.sort()).toEqual(["failed", "kept"]);
});

test("GLM-5.2's MLA cache takes no KV scheme: every requested scheme is refused while bf16 and its batching are unaffected", async () => {
  const { MLACache } = await import("../../src/state/glm52-cache");
  const binding = bindMlxGateway(standIn(Glm52Model.prototype, "glm_moe_dsa", {
    config: { modelType: "glm_moe_dsa", text: { enableMoeBlock: false, numHiddenLayers: 1, layerTypes: ["full_attention"] }, eosTokenIds: [] },
    makeCache: () => [new MLACache({ kvLoraRank: 512, ropeHeadDim: 64 })],
    // The graph's declared dense-read layers: MLA reads its compressed cache.
    requiredDenseKvLayers: [] }));
  expect(binding.cachesBatchable()).toBe(true);
  expect(binding.kvBatchable(new KvScheme("bf16", {}))).toBe(true);
  for (const scheme of [resolveKvScheme({ override: 4 }), resolveKvScheme({ override: 8 }),
    resolveKvScheme({ override: 4, quantizedKvStart: 64 }), resolveKvScheme({ turboQuant: { kBits: 8, vBits: 3 } }),
    resolveKvScheme({ override: "config", config: [{ layerIdx: 0, bits: 4, groupSize: 64 }] })])
    expect(binding.kvBatchable(scheme), scheme.cacheKey).toBe(false);
});

test("each binding keeps the SSM batching policy it was built with", () => {
  const model = standIn(Qwen35Model.prototype, "qwen3_5", { makeCache: () => [new SSMCache(), new KVCache()] });
  const off = withRuntimeConfig(createRuntimeConfig({ MLX_BUN_BATCH_SSM: "0" }), () => bindMlxGateway(model));
  const on = withRuntimeConfig(createRuntimeConfig({}), () => bindMlxGateway(model));
  expect([off.cachesBatchable(), on.cachesBatchable()]).toEqual([false, true]);
  expect(withRuntimeConfig(createRuntimeConfig({}), () => off.cachesBatchable())).toBe(false);
  expect(withRuntimeConfig(createRuntimeConfig({ MLX_BUN_BATCH_SSM: "0" }), () => on.cachesBatchable())).toBe(true);
});
