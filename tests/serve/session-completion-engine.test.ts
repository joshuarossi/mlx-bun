import { expect, test } from "bun:test";
import type { GenerateStats } from "../../src/generate";
import type { CompletionEngine } from "../../src/serve/completion-executor";
import type { RequestShape } from "../../src/serve/generation-gateway";
import { createSessionCompletionEngine } from "../../src/serve/session-completion-engine";

const shape: RequestShape = {
  hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false,
  kvQuant: false, turboQuant: false, hasLogitsExtras: false, hasGrammar: false,
  wantsLogprobs: false, hasDraft: false,
};
const stats = (generatedTokens: number): GenerateStats => ({
  promptTokens: 1, cachedTokens: 0, generatedTokens, prefillMs: 0, decodeMs: 0,
  prefillTps: 0, decodeTps: 0, cacheTokens: [],
});

test("the shared session preserves synchronous token stops and native logprobs", async () => {
  let cleaned = false;
  let calls = 0;
  const runtime: CompletionEngine = {
    place: (shape) => ({ shape, mechanism: "serial" }),
    async run(_prompt, _options, onToken) {
      try {
        for (let n = 1; n <= 8; n++) {
          calls++;
          if (await onToken(n, { logprob: -n }) === false) break;
        }
        return stats(calls);
      } finally { cleaned = true; }
    },
  };
  const engine = createSessionCompletionEngine(runtime, () => { throw new Error("already transferred"); });
  const tokens: number[] = [];
  const result = await engine.run([0], { maxTokens: 8 }, (token, lp) => {
    expect(lp?.logprob).toBe(-token);
    tokens.push(token);
    return token < 2;
  }, undefined, shape, engine.place(shape));
  expect(tokens).toEqual([1, 2]);
  expect(calls).toBe(2);
  expect(result.generatedTokens).toBe(2);
  expect(cleaned).toBe(true);
  await engine.close();
});

test("native and consumer errors keep their identity after session cleanup", async () => {
  for (const consumerFails of [false, true]) {
    const failure = new Error("original failure");
    let cleaned = false;
    const runtime: CompletionEngine = {
      place: (shape) => ({ shape, mechanism: "serial" }),
      async run(_prompt, _options, onToken) {
        try { await onToken(1); throw failure; }
        finally { cleaned = true; }
      },
    };
    const engine = createSessionCompletionEngine(runtime, () => {});
    const run = engine.run([0], { maxTokens: 8 }, () => {
      if (consumerFails) throw failure;
    }, undefined, shape, engine.place(shape));
    expect(await run.catch((error) => error)).toBe(failure);
    expect(cleaned).toBe(true);
    await engine.close();
  }
});

test("cancelled, rejected and closed sessions release inputs before execution", async () => {
  let released = 0;
  let started = 0;
  const runtime: CompletionEngine = {
    place: (shape) => ({ shape, mechanism: "serial" }),
    async run() { started++; return stats(0); },
  };
  const engine = createSessionCompletionEngine(runtime, () => { released++; });
  const abort = new AbortController();
  abort.abort(new Error("already cancelled"));
  await expect(engine.run([0], { maxTokens: 8 }, () => {}, undefined, shape, engine.place(shape), abort.signal))
    .rejects.toThrow("already cancelled");
  await expect(engine.run([0], { maxTokens: -1 }, () => {}, undefined, shape, engine.place(shape)))
    .rejects.toThrow("invalid planned output token limit");
  await engine.close();
  await expect(engine.run([0], { maxTokens: 8 }, () => {}, undefined, shape, engine.place(shape)))
    .rejects.toThrow("inference engine is closed");
  expect(released).toBe(3);
  expect(started).toBe(0);
});

test("engine close cancels a running method and waits for its resources", async () => {
  let entered!: () => void;
  const started = new Promise<void>((resolve) => { entered = resolve; });
  let finishCleanup!: () => void;
  const cleanup = new Promise<void>((resolve) => { finishCleanup = resolve; });
  let cleaned = false;
  const runtime: CompletionEngine = {
    place: (shape) => ({ shape, mechanism: "serial" }),
    async run(_prompt, _options, _onToken, _vision, _shape, _placement, signal) {
      entered();
      await new Promise<void>((resolve) => signal!.addEventListener("abort", () => resolve(), { once: true }));
      await cleanup;
      cleaned = true;
      signal!.throwIfAborted();
      return stats(0);
    },
  };
  const engine = createSessionCompletionEngine(runtime, () => { throw new Error("already transferred"); });
  const result = engine.run([0], { maxTokens: 8 }, () => {}, undefined, shape, engine.place(shape))
    .catch((error) => error);
  await started;
  let closed = false;
  const closing = engine.close().then(() => { closed = true; });
  await Promise.resolve();
  expect(closed).toBe(false);
  finishCleanup();
  await closing;
  expect(cleaned).toBe(true);
  expect((await result).name).toBe("AbortError");
});
