import { expect, test } from "bun:test";
import { bindContinuationPolicy, type ContinuationStore } from "../../src/backends/mlx/continuation";
import type { Cache } from "../../src/model/gemma4-base";
import type { ResolvedExecution } from "../../src/contracts/execution";

const execution = { method: "autoregressive", mechanism: "continuous", pagedKv: false,
  promptCache: true, checkpoint: true, fill: false, compiledDecode: false, grammarJump: false,
  reasons: [] } satisfies ResolvedExecution;

test("continuation policy recovers implicit seed and preserves namespace on save and completion", async () => {
  const captures: any[] = [], removed: string[] = [], lookups: any[] = [];
  const store = { findGenerationCheckpoint(...args: unknown[]) { lookups.push(args); return {}; },
    storeGenerationCheckpoint(...args: unknown[]) { captures.push(args); return Promise.resolve(true); },
    removeGenerationCheckpoints(key: string) { removed.push(key); } } as unknown as ContinuationStore;
  const caches = [] as Cache[];
  const input = { store, restore: (() => ({ tokens: [1, 2, 3], caches, header: {
    generationCheckpoint: { originalPromptTokens: 2, generatedTokens: 1, pendingToken: 4, seed: 77 } } })) as any,
    prompt: [1, 2], options: { seed: 999, seedWasExplicit: false }, execution,
    identity: "fixture-v1", namespace: "adapter:revision-a" };
  const policy = bindContinuationPolicy(input);
  const restored = policy.restore()!;
  expect(restored).toMatchObject({ seed: 77, generatedTokens: 1, pendingToken: 4, cacheTokens: [1, 2, 3] });
  await policy.capture({ caches, cacheTokens: [1, 2, 3, 4], generatedTokens: 2, pendingToken: 5 });
  expect(captures[0][2]).toMatchObject({ seed: 77, seedWasExplicit: false, cacheNs: input.namespace });
  expect(lookups[0]).toEqual([[1, 2], policy.key, input.namespace]);
  expect(bindContinuationPolicy({ ...input, namespace: "adapter:revision-b" }).key).not.toBe(policy.key);
  expect(removed).toEqual([]);
  policy.complete(); expect(removed).toEqual([policy.key]);
});

test("inconsistent restored coverage releases owned state before rejecting", () => {
  let disposed = 0;
  const store = { findGenerationCheckpoint() { return {}; } } as unknown as ContinuationStore;
  const policy = bindContinuationPolicy({ store, restore: (() => ({ tokens: [1, 2, 3],
    caches: [{ dispose() { disposed++; } }], header: { generationCheckpoint: {
      originalPromptTokens: 2, generatedTokens: 2, pendingToken: 4, seed: 0 } } })) as any,
    prompt: [1, 2], options: {}, execution, identity: "fixture", namespace: "" });
  expect(() => policy.restore()).toThrow("inconsistent continuation metadata");
  expect(disposed).toBe(1);
});

test("actual request preparation generates fresh implicit seeds and restore recovers the original sampler", async () => {
  const { createRequestPrep } = await import("../../src/serve/request-prep");
  const { createOrdinaryContinuationRequest } = await import("../../src/backends/mlx/continuation-request");
  const { ContinuationPersistence } = await import("../../src/backends/mlx/continuation-persistence");
  const { makeStepSampler } = await import("../../src/sampler");
  const { MlxArray } = await import("../../src/mlx/array");
  const prep = createRequestPrep({ ctx: { model: { config: { modelType: "gemma4", eosTokenIds: [] } },
    tokenizer: { encode: () => [1] }, genDefaults: {} } as any,
    serverOptions: {}, kvScheme: {}, defaultGeneratedTokens: 16 });
  const first = prep.toOptions({ messages: [], temperature: 0.7 });
  const retry = prep.toOptions({ messages: [], temperature: 0.7 });
  expect(first.seed).toBeDefined(); expect(retry.seed).not.toBe(first.seed);
  const stored: any[] = [];
  const store = { findGenerationCheckpoint: () => ({}),
    async storeGenerationCheckpoint(...args: unknown[]) { stored.push(args); return true; },
    removeGenerationCheckpoints() {} } as unknown as ContinuationStore;
  const persistence = new ContinuationPersistence(store, { maxBytes: 1024, runStep: async step => step() });
  const restore = (() => ({ caches: [], tokens: [1, 2, 3], header: { generationCheckpoint: {
    originalPromptTokens: 2, generatedTokens: 1, pendingToken: 4, seed: first.seed } } })) as any;
  const common = { store, restore, persistence, prompt: [1, 2], execution, identity: "fixture", interval: 1, onToken() {} };
  expect(bindContinuationPolicy({ ...common, options: first, namespace: "" }).key)
    .toBe(bindContinuationPolicy({ ...common, options: retry, namespace: "" }).key);
  const request = createOrdinaryContinuationRequest({ ...common, options: retry });
  const state = request.continuation.restore("")!;
  request.continuation.resumeSampling(state);
  const oracle = makeStepSampler(first, { tokenRepresentation: "device", grammarWait: "external", historyUpdate: "after-sample", initialHistory: [1, 2, 3, 4] });
  try {
    using logits = MlxArray.fromFloat32(new Float32Array([0, 1, 2, 3, 4]), [1, 5]);
    using actual = request.sample(logits, 2);
    using expected = oracle.sample(logits, 2).token;
    expect(actual.toIntTokens()).toEqual(expected.toIntTokens());
    request.continuation.captureOwned({ caches: [], cacheTokens: [1, 2, 3, 4], generatedTokens: 2, pendingToken: 0 });
    await persistence.flush(); expect(stored[0][2].seed).toBe(first.seed);
    expect(stored[0][2].seedWasExplicit).toBe(false);
  } finally { request.dispose(); oracle.dispose(); }
  for (const [options, greedy] of [[{ temperature: 0 }, true], [{ temperature: 0, repetitionPenalty: 1.1 }, false]] as const) {
    const item = createOrdinaryContinuationRequest({ ...common, options });
    try { expect(item.plainGreedy).toBe(greedy); } finally { item.dispose(); }
  }
});
