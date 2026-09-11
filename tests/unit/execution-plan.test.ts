import { expect, test } from "bun:test";
import { resolveExecution } from "../../src/engine/execution-plan";
import type { ExecutionCapabilities, ExecutionRequirements } from "../../src/contracts/execution";

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
  expect(plan.reasons).not.toContain("logprobs-require-serial");
});

test("an explicit seed composes with ordinary logprobs and grammar in continuous execution", () => {
  const plan = resolveExecution({ ...request, userSeed: true, wantsLogprobs: true, hasGrammar: true }, capabilities);
  expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous" });
  expect(plan.reasons).not.toContain("explicit-seed-requires-serial");
});

test.each(["hasVision", "hasAdapters", "wantsLogprobs", "kvQuant", "turboQuant"] as const)(
  "%s uses AR and retains an explicit draft fallback reason", (key) => {
    const plan = resolveExecution({ ...request, hasDraft: true, [key]: true }, capabilities);
    expect(plan.method).toBe("autoregressive");
    expect(plan.mechanism).toBe(key === "wantsLogprobs" || key === "kvQuant" ? "continuous" : "serial");
    expect(plan.reasons).toContain("draft-incompatible-with-request");
  },
);

test("grammar and an explicit seed compose with speculative verification", () => {
  const plan = resolveExecution({ ...request, hasDraft: true, hasGrammar: true, userSeed: true }, capabilities);
  expect(plan).toMatchObject({ method: "speculative", mechanism: "serial", promptCache: false, checkpoint: false });
});

test("qualified speculative KV retains the serial verifier and other incompatibility guards", () => {
  const qualified = { ...capabilities, speculativeKvQuant: true };
  const draft = { ...request, hasDraft: true, kvQuant: true };
  expect(resolveExecution(draft, qualified)).toMatchObject({
    method: "speculative", mechanism: "serial", promptCache: false, checkpoint: false,
  });
  for (const key of ["hasVision", "hasAdapters", "wantsLogprobs", "turboQuant"] as const)
    expect(resolveExecution({ ...draft, [key]: true }, qualified).method).toBe("autoregressive");
  expect(resolveExecution(draft, qualified, { pagedKv: true, fill: false }).method).toBe("autoregressive");
});

test("supported affine KV batches; unavailable layouts and TurboQuant remain serial", () => {
  expect(resolveExecution({ ...request, kvQuant: true }, capabilities).mechanism).toBe("continuous");
  expect(resolveExecution({ ...request, kvQuant: true }, { ...capabilities, quantizedBatch: false }).mechanism).toBe("serial");
  expect(resolveExecution({ ...request, turboQuant: true }, capabilities).mechanism).toBe("serial");
});

test("paged fallback, prompt-cache bypass, and checkpoints use one decision", () => {
  const features = { pagedKv: true, fill: false };
  expect(resolveExecution(request, capabilities, features)).toMatchObject({ pagedKv: true, promptCache: false, checkpoint: false });
  expect(resolveExecution({ ...request, hasAdapters: true }, capabilities, features))
    .toMatchObject({ pagedKv: false, promptCache: true, checkpoint: true });
  expect(resolveExecution({ ...request, hasVision: true }, capabilities, features))
    .toMatchObject({ pagedKv: false, promptCache: false, checkpoint: false });
});

test("fill cannot run in another method, continuous group, or resumable checkpoint", () => {
  const features = { pagedKv: false, fill: true };
  expect(resolveExecution(request, capabilities, features).fill).toBe(false);
  expect(resolveExecution(request, { ...capabilities, continuous: false }, features))
    .toMatchObject({ fill: true, checkpoint: false });
  expect(resolveExecution({ ...request, hasDraft: true }, capabilities, features).fill).toBe(false);
  const denoising = resolveExecution(request, { ...capabilities, method: "denoising" }, features);
  expect(denoising).toMatchObject({ method: "denoising", mechanism: "serial", fill: false, checkpoint: false });
  expect(Object.isFrozen(denoising)).toBe(true);
  expect(Object.isFrozen(denoising.reasons)).toBe(true);
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

test("grammar jump belongs only to eligible serial AR requests", () => {
  const features = { pagedKv: false, fill: false, grammarJump: true };
  const grammar = { ...request, hasGrammar: true };
  const serial = { ...capabilities, continuous: false };
  expect(resolveExecution(grammar, serial, features).grammarJump).toBe(true);
  expect(resolveExecution(grammar, capabilities, features).grammarJump).toBe(false);
  expect(resolveExecution(grammar, serial).grammarJump).toBe(false);
  expect(resolveExecution(request, serial, features).grammarJump).toBe(false);
  for (const incompatible of [{ wantsLogprobs: true }, { hasDraft: true }])
    expect(resolveExecution({ ...grammar, ...incompatible }, serial, features).grammarJump).toBe(false);
  expect(resolveExecution(grammar, { ...serial, method: "denoising" }, features).grammarJump).toBe(false);
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
  expect(plan.reasons).not.toContain("method-requires-serial");
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
    expect(resolveExecution(adapted, { ...supported, ...disabled })).toMatchObject({ method: "autoregressive", mechanism: "serial" });
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
