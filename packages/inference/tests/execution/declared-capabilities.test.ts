import { describe, expect, test } from "bun:test";
import { bindMlxGateway } from "../../src/execution/gateway-binding";
import { declareGraph, PLAIN_KV_VERIFICATION } from "../../src/models/capabilities";
import type { RuntimeModel } from "../../src/models/factory";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/runtime/config";
import { KVCache } from "../../src/state/kv";
import { resolveKvScheme } from "../../src/state/kv-scheme";
import { NgramProvider } from "../../src/generation/speculative/sources/ngram-source";
import type { GenerateOptions } from "../../src/generation/index";
import type { GraphCapabilities } from "../../src/contracts/portable/graph";

// A graph that is none of the model classes. Placement can only follow what it
// declares: its name, its model type, and its shape mean nothing to the scheduler.
const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false,
  kvQuant: false, turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: false };
const schedule = { continuous: true, quantizedBatch: true, checkpoints: false };

function replacement(declared: Parameters<typeof declareGraph>[0] = {}, extra: object = {}, modelType = "replacement"): RuntimeModel {
  return {
    config: { modelType, text: { enableMoeBlock: false, numHiddenLayers: 1, layerTypes: ["full_attention"] }, eosTokenIds: [] },
    makeCache: () => [new KVCache()], loraState: { active: [] }, requiredDenseKvLayers: [], logitsFromHidden() {},
    graphCapabilities: declareGraph(declared), ...extra,
  } as unknown as RuntimeModel;
}
const bind = (model: RuntimeModel, draft = false) => bindMlxGateway(model,
  draft ? { provider: new NgramProvider(), numDraftTokens: 3 } : undefined);
const refusals = (plan: { reasons: readonly string[] }) => plan.reasons.filter(reason => reason.endsWith("-unsupported") || reason === "continuous-unavailable");

describe("placement follows the graph's declarations", () => {
  test("the binding reports what the graph declared, once", () => {
    const declared = declareGraph({ pagedAttention: true });
    expect(bind(replacement({ pagedAttention: true })).capabilities).toEqual(declared);
  });

  test("a model type or class name declares nothing", () => {
    // Named like the graphs whose declarations grant these capabilities, this graph declares none.
    const binding = bind(replacement({}, {}, "gemma4"));
    expect(refusals(binding.plan({ ...shape, hasVision: true }, {}, schedule))).toEqual(["media-batch-unsupported"]);
    expect(refusals(binding.plan(shape, { pagedKv: {} }, schedule))).toEqual(["paged-kv-batch-unsupported"]);
    expect(binding.plan(shape, {}, schedule).compiledDecode).toBe(false);
    expect(binding.kvBatchable(resolveKvScheme({ override: 4, quantizedKvStart: 64 }))).toBe(false);
  });

  test("paged attention, adapters and compiled decode are placed from their declarations", () => {
    const paged = bind(replacement({ pagedAttention: true }));
    expect(paged.plan(shape, { pagedKv: {} }, schedule)).toMatchObject({ mechanism: "continuous", pagedKv: true });
    const unadapted = bind(replacement({ adapters: { batched: false } }));
    expect(refusals(unadapted.plan({ ...shape, hasAdapters: true }, {}, schedule))).toEqual(["adapter-batch-unsupported"]);
    expect(unadapted.bindAdapterContext).toBeUndefined();
    expect(bind(replacement({ adapters: { batched: true } })).plan({ ...shape, hasAdapters: true }, {}, schedule).mechanism).toBe("continuous");
    const compiled = bind(replacement({ compiledDecode: true }));
    expect(compiled.plan(shape, {}, schedule).compiledDecode).toBe(true);
    expect(withRuntimeConfig(createRuntimeConfig({ MLX_BUN_COMPILED_DECODE: "0" }), () => bind(replacement({ compiledDecode: true })))
      .plan(shape, {}, schedule).compiledDecode).toBe(false);
  });

  test("prepared media enters through the graph's own operation, declared and provided together", () => {
    const forward = () => { throw new Error("placement never forwards"); };
    const media = bind(replacement({ media: { input: "embeddings", video: false } }, { bindMediaInput: () => ({ forward }) }));
    expect(media.plan({ ...shape, hasVision: true }, {}, schedule)).toMatchObject({ mechanism: "continuous" });
    expect(media.mediaInput!({ embeddings: {} as never }).forward).toBe(forward);
    // Denoising pixels are that method's own input, not the shared media path.
    expect(() => bind(replacement({ media: { input: "embeddings", video: false } }))).toThrow("provides no bindMediaInput");
    expect(() => bind({ config: {}, makeCache: () => [] } as unknown as RuntimeModel)).toThrow("must declare its capabilities");
  });

  test("delayed affine KV batches per the declared level", () => {
    const delayed = resolveKvScheme({ override: 4, quantizedKvStart: 64 }), immediate = resolveKvScheme({ override: 4, quantizedKvStart: 0 });
    for (const [level, batches] of [["none", false], ["ordinary", true], ["all", true]] as const)
      expect(bind(replacement({ kv: { delayedAffine: level } })).kvBatchable(delayed), level).toBe(batches);
    expect(bind(replacement()).kvBatchable(immediate)).toBe(true);
    // Ordinary-only graphs serve delayed rows ordinarily and refuse to speculate over them; `all` graphs speculate.
    const request = { ...shape, kvQuant: true, hasDraft: true }, options = { kvBits: 4, quantizedKvStart: 64 } as GenerateOptions;
    const ordinary = bind(replacement({ kv: { delayedAffine: "ordinary" } }), true).plan(request, options, schedule);
    expect(ordinary).toMatchObject({ mechanism: "unsupported" });
    expect(ordinary.reasons).toContain("continuous-unavailable");
    expect(bind(replacement({ kv: { delayedAffine: "all" } }), true).plan(request, options, schedule))
      .toMatchObject({ method: "speculative", mechanism: "continuous" });
  });

  test("a verifier that does not qualify a request shape leaves it ordinary", () => {
    const specs: [keyof GraphCapabilities["speculation"], Record<string, unknown>, GenerateOptions][] = [
      ["logprobs", { wantsLogprobs: true }, {}],
      ["turboKv", { turboQuant: true }, { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 }],
    ];
    for (const [flag, extra, options] of specs) {
      const request = { ...shape, hasDraft: true, ...extra };
      expect(bind(replacement(), true).plan(request, options, schedule), `${flag} qualified`).toMatchObject({ method: "speculative" });
      const unqualified = bind(replacement({ speculation: { [flag]: false } }), true).plan(request, options, schedule);
      expect(unqualified, `${flag} unqualified`).toMatchObject({ method: "autoregressive" });
      expect(unqualified.reasons).toContain("draft-incompatible-with-request");
    }
    // Plain-KV verification qualifies none of them at once.
    const plain = bind(replacement({ speculation: PLAIN_KV_VERIFICATION }), true);
    expect(plain.plan({ ...shape, hasDraft: true }, {}, schedule)).toMatchObject({ method: "speculative", mechanism: "continuous" });
    expect(plain.plan({ ...shape, hasDraft: true, wantsLogprobs: true }, {}, schedule)).toMatchObject({ method: "autoregressive" });
  });
});
