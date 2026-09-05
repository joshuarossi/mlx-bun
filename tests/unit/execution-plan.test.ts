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
