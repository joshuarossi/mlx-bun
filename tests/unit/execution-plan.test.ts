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

test.each(["hasVision", "hasAdapters", "wantsLogprobs", "kvQuant", "turboQuant"] as const)(
  "%s uses AR and retains an explicit draft fallback reason", (key) => {
    const plan = resolveExecution({ ...request, hasDraft: true, [key]: true }, capabilities);
    expect(plan.method).toBe("autoregressive");
    expect(plan.mechanism).toBe("serial");
    expect(plan.reasons).toContain("draft-incompatible-with-request");
  },
);

test("grammar and an explicit seed compose with speculative verification", () => {
  const plan = resolveExecution({ ...request, hasDraft: true, hasGrammar: true, userSeed: true }, capabilities);
  expect(plan).toMatchObject({ method: "speculative", mechanism: "serial", promptCache: false, checkpoint: false });
});

test("per-layer KV batches; uniform and TurboQuant remain serial", () => {
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
