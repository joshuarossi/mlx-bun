import { expect, test } from "bun:test";
import { resolveExecution } from "../../src/execution/plan";
import type { ExecutionCapabilities, ExecutionRequirements } from "../../src/contracts/portable/execution";

const request: ExecutionRequirements = {
  hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false,
  kvQuant: false, turboQuant: false, hasLogitsExtras: false, hasGrammar: false,
  wantsLogprobs: false, hasDraft: false,
};
const capabilities: ExecutionCapabilities = {
  method: "autoregressive", continuous: true, quantizedBatch: true,
  grammarBatch: true, checkpoints: true,
};

test("logprobs compose with continuous ordinary decoding", () => {
  const plan = resolveExecution({ ...request, wantsLogprobs: true }, capabilities);
  expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous" });
  expect(plan.reasons).toEqual([]);
});

test("prepared media uses ordinary shared decode without token-only reuse or speculative proposals", () => {
  const supported = { ...capabilities, mediaBatch: true, sharedGrammarProposals: true,
    sharedFill: true, sharedCheckpoints: true, groupedMethods: ["autoregressive", "speculative"] };
  for (const options of [{}, { hasDraft: true }, { hasGrammar: true }, { wantsLogprobs: true }]) {
    const plan = resolveExecution({ ...request, hasVision: true, ...options }, supported,
      { pagedKv: false, fill: true, grammarJump: true });
    expect(plan).toMatchObject({ mechanism: "continuous", method: "autoregressive",
      promptCache: false, checkpoint: false, fill: false, grammarJump: false });
  }
  expect(resolveExecution({ ...request, hasVision: true }, capabilities).mechanism).toBe("unsupported");
});

test("prepared-prefix identity enables qualified shared reuse independently of media decode", () => {
  const media = { ...request, hasVision: true, hasPreparedPrefixIdentity: true };
  const supported = { ...capabilities, mediaBatch: true, mediaPrefixCache: true, sharedCheckpoints: true };
  expect(resolveExecution(media, supported)).toMatchObject({ mechanism: "continuous", promptCache: true, checkpoint: false });
  expect(resolveExecution({ ...media, hasPreparedPrefixIdentity: false }, supported).promptCache).toBe(false);
  expect(resolveExecution(media, { ...supported, mediaPrefixCache: false }).promptCache).toBe(false);
  expect(resolveExecution(media, { ...supported, continuous: false })).toMatchObject({ mechanism: "unsupported", promptCache: false });
});

test("an explicit seed composes with ordinary logprobs and grammar in continuous execution", () => {
  const plan = resolveExecution({ ...request, userSeed: true, wantsLogprobs: true, hasGrammar: true }, capabilities);
  expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous" });
  expect(plan.reasons).toEqual([]);
});

test.each(["hasVision", "hasAdapters", "wantsLogprobs", "kvQuant", "turboQuant"] as const)(
  "%s uses AR and retains an explicit draft fallback reason", (key) => {
    const plan = resolveExecution({ ...request, hasDraft: true, [key]: true }, capabilities);
    expect(plan.method).toBe("autoregressive");
    expect(plan.mechanism).toBe(key === "wantsLogprobs" || key === "kvQuant" ? "continuous" : "unsupported");
    expect(plan.reasons).toContain("draft-incompatible-with-request");
  },
);

test("grammar and an explicit seed select speculation, which needs a grouped verifier", () => {
  const plan = resolveExecution({ ...request, hasDraft: true, hasGrammar: true, userSeed: true }, capabilities);
  expect(plan).toMatchObject({ method: "speculative", mechanism: "unsupported", promptCache: false, checkpoint: false });
  expect(plan.reasons).toEqual(["method-batch-unsupported"]);
});

test("qualified speculative KV without a grouped verifier is unsupported; other guards keep AR", () => {
  const qualified = { ...capabilities, speculativeKvQuant: true };
  const draft = { ...request, hasDraft: true, kvQuant: true };
  expect(resolveExecution(draft, qualified)).toMatchObject({
    method: "speculative", mechanism: "unsupported", promptCache: false, checkpoint: false,
  });
  for (const key of ["hasVision", "hasAdapters", "wantsLogprobs", "turboQuant"] as const)
    expect(resolveExecution({ ...draft, [key]: true }, qualified).method).toBe("autoregressive");
  expect(resolveExecution(draft, qualified, { pagedKv: true, fill: false }).method).toBe("autoregressive");
});

test("supported affine KV batches; unavailable layouts and TurboQuant are unsupported", () => {
  expect(resolveExecution({ ...request, kvQuant: true }, capabilities).mechanism).toBe("continuous");
  expect(resolveExecution({ ...request, kvQuant: true }, { ...capabilities, quantizedBatch: false }).mechanism).toBe("unsupported");
  expect(resolveExecution({ ...request, turboQuant: true }, capabilities).mechanism).toBe("unsupported");
});

test("paged placement keeps prefix reuse separate from interruption checkpoints", () => {
  const features = { pagedKv: true, fill: false };
  const paged = { ...capabilities, pagedBatch: true };
  expect(resolveExecution(request, paged, features))
    .toMatchObject({ mechanism: "continuous", pagedKv: true, promptCache: true, checkpoint: false });
  expect(resolveExecution(request, capabilities, features).reasons).toEqual(["paged-kv-batch-unsupported"]);
  const adapted = resolveExecution({ ...request, hasAdapters: true }, paged, features);
  expect(adapted).toMatchObject({ mechanism: "unsupported", pagedKv: false, promptCache: true, checkpoint: false });
  expect(adapted.reasons).toEqual(["adapter-batch-unsupported", "paged-kv-bypassed-for-media-or-adapters"]);
  // With adapter batching and a bound checkpoint store, adapters bypass paging into resumable continuation.
  expect(resolveExecution({ ...request, hasAdapters: true }, { ...paged, adapterBatch: true, sharedCheckpoints: true }, features))
    .toMatchObject({ mechanism: "continuous", pagedKv: false, promptCache: true, checkpoint: true });
  expect(resolveExecution({ ...request, hasVision: true }, paged, features))
    .toMatchObject({ pagedKv: false, promptCache: false, checkpoint: false });
});

test("fill requires a qualified shared binding and cannot run in another method or resumable checkpoint", () => {
  const features = { pagedKv: false, fill: true };
  expect(resolveExecution(request, capabilities, features).fill).toBe(false);
  for (const shape of [request, { ...request, kvQuant: true }, { ...request, turboQuant: true }]) {
    const plan = resolveExecution(shape, { ...capabilities, continuous: false }, features);
    expect(plan).toMatchObject({ mechanism: "unsupported", fill: false, checkpoint: false });
    expect(plan.reasons).toContain("fill-incompatible-with-request");
  }
  expect(resolveExecution({ ...request, hasDraft: true }, capabilities, features).fill).toBe(false);
  const denoising = resolveExecution(request, { ...capabilities, method: "denoising" }, features);
  expect(denoising).toMatchObject({ method: "denoising", mechanism: "unsupported", fill: false, checkpoint: false });
  expect(Object.isFrozen(denoising)).toBe(true);
  expect(Object.isFrozen(denoising.reasons)).toBe(true);
});

test("qualified shared fill retains seeded sampling and excludes paging, grammar and metadata", () => {
  const supported = { ...capabilities, sharedFill: true, turboQuantBatch: true, compiledDecode: true };
  const features = { pagedKv: false, fill: true, compiledDecode: true };
  for (const shape of [request, { ...request, userSeed: true }, { ...request, kvQuant: true },
    { ...request, turboQuant: true }]) {
    expect(resolveExecution(shape, supported, features)).toMatchObject({
      method: "autoregressive", mechanism: "continuous", fill: true,
      promptCache: true, checkpoint: false, compiledDecode: false,
    });
  }
  for (const extra of [{ hasGrammar: true }, { wantsLogprobs: true }, { hasDraft: true }])
    expect(resolveExecution({ ...request, ...extra }, supported, features).fill).toBe(false);
  expect(resolveExecution(request, { ...supported, pagedBatch: true }, { ...features, pagedKv: true }).fill).toBe(false);
  expect(resolveExecution({ ...request, userSeed: true }, { ...supported, continuous: false }, features).fill).toBe(false);
});

test("compiled replay permission is fixed by graph capability and request composition", () => {
  const features = { pagedKv: false, fill: false, compiledDecode: true };
  const supported = { ...capabilities, compiledDecode: true };
  expect(resolveExecution(request, supported, features).compiledDecode).toBe(true);
  expect(resolveExecution(request, capabilities, features).compiledDecode).toBe(false);
  expect(resolveExecution(request, supported).compiledDecode).toBe(false);
  for (const incompatible of [{ hasAdapters: true }, { hasDraft: true }]) {
    const plan = resolveExecution({ ...request, ...incompatible }, supported, features);
    expect(plan.compiledDecode).toBe(false);
    expect(plan.reasons).toContain("compiled-decode-unavailable-for-request");
  }
  expect(resolveExecution(request, supported, { ...features, pagedKv: true }).compiledDecode).toBe(false);
  // Media bypasses paged KV and still uses the graph's ordinary decode path.
  expect(resolveExecution({ ...request, hasVision: true }, supported, { ...features, pagedKv: true }).compiledDecode).toBe(true);
});

test("grammar jump comes only from shared grammar proposals, never an unsupported plan", () => {
  const features = { pagedKv: false, fill: false, grammarJump: true };
  const grammar = { ...request, hasGrammar: true };
  const unavailable = { ...capabilities, continuous: false };
  const rejected = resolveExecution(grammar, unavailable, features);
  expect(rejected).toMatchObject({ mechanism: "unsupported", grammarJump: false });
  expect(rejected.reasons).toEqual(["continuous-unavailable", "grammar-jump-incompatible-with-request"]);
  expect(resolveExecution(grammar, capabilities, features).grammarJump).toBe(false);
  expect(resolveExecution(request, unavailable, features).grammarJump).toBe(false);
  expect(resolveExecution(grammar, { ...unavailable, method: "denoising" }, features).grammarJump).toBe(false);
});


test("adapter-capable groups retain ordinary sampling features", () => {
  const plan = resolveExecution({ ...request, hasAdapters: true, wantsLogprobs: true,
    userSeed: true }, { ...capabilities, adapterBatch: true }, { pagedKv: false, fill: false, compiledDecode: true });
  expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous", compiledDecode: false });
});

test("registered grouped methods compose speculation with sampling and KV storage", () => {
  const composed = { ...capabilities, groupedMethods: ["autoregressive", "speculative"],
    speculativeLogprobs: true, speculativeKvQuant: true };
  const plan = resolveExecution({ ...request, hasDraft: true, wantsLogprobs: true,
    userSeed: true, hasGrammar: true, kvQuant: true }, composed);
  expect(plan).toMatchObject({ method: "speculative", mechanism: "continuous" });
  expect(plan.reasons).not.toContain("method-batch-unsupported");
  expect(plan.reasons).not.toContain("draft-incompatible-with-request");
});


test("TurboQuant group capability composes with ordinary and speculative methods", () => {
  const turbo = { ...request, turboQuant: true };
  const supported = { ...capabilities, turboQuantBatch: true };
  expect(resolveExecution(turbo, supported).mechanism).toBe("continuous");
  const mtp = resolveExecution({ ...turbo, hasDraft: true }, { ...supported,
    speculativeTurboQuant: true, groupedMethods: ["autoregressive", "speculative"] });
  expect(mtp.method).toBe("speculative");
  expect(mtp.mechanism).toBe("continuous");
  expect(resolveExecution({ ...turbo, hasDraft: true }, supported).method).toBe("autoregressive");
});

test("qualified target-adapter speculation stays in the shared adapter context", () => {
  const adapted = { ...request, hasDraft: true, hasAdapters: true, wantsLogprobs: true, userSeed: true, hasGrammar: true };
  const supported = { ...capabilities, adapterBatch: true, sharedSpeculativeAdapters: true,
    speculativeLogprobs: true, groupedMethods: ["autoregressive", "speculative"] };
  expect(resolveExecution(adapted, supported)).toMatchObject({ method: "speculative", mechanism: "continuous" });
  expect(resolveExecution(adapted, { ...supported, sharedSpeculativeAdapters: false }).method).toBe("autoregressive");
  for (const disabled of [{ continuous: false }, { adapterBatch: false }, { grammarBatch: false }])
    expect(resolveExecution(adapted, { ...supported, ...disabled })).toMatchObject({ method: "autoregressive", mechanism: "unsupported" });
  expect(resolveExecution({ ...adapted, hasVision: true }, supported).method).toBe("autoregressive");
});

test("bound ordinary checkpoint capability qualifies shared requests without changing other methods", () => {
  const supported = { ...capabilities, checkpoints: true, sharedCheckpoints: true };
  expect(resolveExecution(request, supported)).toMatchObject({ mechanism: "continuous", checkpoint: true });
  expect(resolveExecution(request, { ...supported, sharedCheckpoints: false }).checkpoint).toBe(false);
  for (const excluded of [{ hasGrammar: true }, { wantsLogprobs: true }, { hasVision: true }])
    expect(resolveExecution({ ...request, ...excluded }, supported).checkpoint).toBe(false);
  expect(resolveExecution({ ...request, hasDraft: true }, { ...supported,
    speculativeLogprobs: true, groupedMethods: ["autoregressive", "speculative"] }).checkpoint).toBe(false);
  expect(resolveExecution(request, supported, { pagedKv: false, fill: true }).checkpoint).toBe(false);
});

test("grammar proposals select the shared verifier only when its request combination is supported", () => {
  const grammar = { ...request, hasGrammar: true };
  const features = { pagedKv: false, fill: false, grammarJump: true };
  const supported = { ...capabilities, sharedGrammarProposals: true,
    groupedMethods: ["autoregressive", "speculative"] };
  expect(resolveExecution(grammar, supported, features)).toMatchObject({
    method: "speculative", mechanism: "continuous", grammarJump: true,
  });
  expect(resolveExecution({ ...grammar, wantsLogprobs: true }, { ...supported, speculativeLogprobs: true }, features))
    .toMatchObject({ method: "speculative", mechanism: "continuous", grammarJump: true });
  expect(resolveExecution(grammar, supported).method).toBe("autoregressive");
  for (const option of [{ wantsLogprobs: true }, { kvQuant: true }, { turboQuant: true }, { hasAdapters: true }])
    expect(resolveExecution({ ...grammar, ...option }, supported, features).method).toBe("autoregressive");
  expect(resolveExecution({ ...grammar, kvQuant: true }, { ...supported, speculativeKvQuant: true }, features).grammarJump).toBe(true);
  expect(resolveExecution({ ...grammar, turboQuant: true }, { ...supported,
    turboQuantBatch: true, speculativeTurboQuant: true }, features).grammarJump).toBe(true);
  expect(resolveExecution(grammar, { ...supported, groupedMethods: ["autoregressive"] }, features).method).toBe("autoregressive");
  expect(resolveExecution({ ...grammar, hasDraft: true }, supported, features)).toMatchObject({
    method: "speculative", grammarJump: false,
  });
});

test("a provider consuming external tokens composes echo with shared speculation", () => {
  const shape = { ...request, hasDraft: true, userSeed: true, kvQuant: true };
  const supported = { ...capabilities, groupedMethods: ["autoregressive", "speculative"],
    speculativeKvQuant: true, sharedSpeculativeEcho: true };
  const features = { fill: true, pagedKv: false };
  expect(resolveExecution(shape, supported, features)).toMatchObject({
    method: "speculative", mechanism: "continuous", fill: true });
  for (const disabled of [{ sharedSpeculativeEcho: false }, { continuous: false }])
    expect(resolveExecution(shape, { ...supported, ...disabled }, features).fill).toBe(false);
  for (const extra of [{ hasVision: true }, { hasGrammar: true }, { wantsLogprobs: true }])
    expect(resolveExecution({ ...shape, ...extra }, supported, features).fill).toBe(false);
});

test("accepted plans keep their selected features", () => {
  const supported = { ...capabilities, sharedCheckpoints: true, sharedFill: true, compiledDecode: true,
    sharedGrammarProposals: true, groupedMethods: ["autoregressive", "speculative"] };
  expect(resolveExecution(request, supported, { pagedKv: false, fill: false, compiledDecode: true })).toEqual({
    method: "autoregressive", mechanism: "continuous", pagedKv: false, promptCache: true, checkpoint: true,
    fill: false, compiledDecode: true, grammarJump: false, reasons: [] });
  expect(resolveExecution({ ...request, userSeed: true }, supported, { pagedKv: false, fill: true, compiledDecode: true })).toEqual({
    method: "autoregressive", mechanism: "continuous", pagedKv: false, promptCache: true, checkpoint: false,
    fill: true, compiledDecode: false, grammarJump: false, reasons: ["compiled-decode-unavailable-for-request"] });
  expect(resolveExecution({ ...request, hasGrammar: true }, supported, { pagedKv: false, fill: false, grammarJump: true })).toEqual({
    method: "speculative", mechanism: "continuous", pagedKv: false, promptCache: false, checkpoint: false,
    fill: false, compiledDecode: false, grammarJump: true, reasons: [] });
});

test.each([
  [{}, { continuous: false }, {}, "continuous-unavailable"],
  [{ hasVision: true }, {}, {}, "media-batch-unsupported"],
  [{ hasAdapters: true }, {}, {}, "adapter-batch-unsupported"],
  [{ kvQuant: true }, { quantizedBatch: false }, {}, "kv-scheme-batch-unsupported"],
  [{ turboQuant: true }, {}, {}, "turbo-kv-batch-unsupported"],
  [{ hasGrammar: true }, { grammarBatch: false }, {}, "grammar-batch-unsupported"],
  [{}, {}, { pagedKv: true }, "paged-kv-batch-unsupported"],
  [{}, { method: "denoising" }, {}, "method-batch-unsupported"],
] as const)("an unsupported plan names its rejection reason: %#", (shape, capability, feature, reason) => {
  const plan = resolveExecution({ ...request, ...shape }, { ...capabilities, ...capability },
    { pagedKv: false, fill: false, ...feature });
  expect(plan).toMatchObject({ mechanism: "unsupported", fill: false, grammarJump: false });
  expect(plan.reasons[0]).toBe(reason);
  expect(plan.reasons.filter(entry => entry.endsWith("-unsupported") || entry === "continuous-unavailable")).toEqual([reason]);
});
