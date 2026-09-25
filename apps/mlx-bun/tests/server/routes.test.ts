import { expect, spyOn, test } from "bun:test";
import type { ModelContext } from "../../src/engine/model-host";
import type { CompletionEngine } from "../../src/engine/completion";
import { UnsupportedExecutionError } from "../../src/engine/completion";
import { createCompletionRoutes } from "../../src/server/routes";
import { errorResponse } from "../../src/server/http";

const execution = { method: "autoregressive", mechanism: "continuous" as const, pagedKv: false, promptCache: true, checkpoint: true, fill: false, compiledDecode: false, grammarJump: false, reasons: [] };
type RouteEngine = Parameters<typeof createCompletionRoutes>[0];
function harness(run?: CompletionEngine["run"], overrides: {
  place?: CompletionEngine["place"];
  preparation?: RouteEngine["preparation"];
  runExclusive?: RouteEngine["gateway"]["runExclusive"];
  buildPrompt?: Parameters<typeof createCompletionRoutes>[1]["buildPrompt"];
} = {}) {
  const seen: Parameters<CompletionEngine["run"]>[] = [];
  let placements = 0;
  const context = {
    modelId: "test/model", model: { config: { modelType: "qwen3", eosTokenIds: [0], text: { vocabSize: 16 } } },
    tokenizer: { encode: () => [7, 8, 9], decode: (ids: number[]) => ids.map(id => `t${id}`).join(" "), idToToken: (id: number) => `t${id}`, bosTokenId: null, eosTokenId: null },
    template: { render: () => "<rendered>", supportsThinking: false, thinkingFormat: "none" },
    adapters: { resolveSpec: () => [] }, genDefaults: {}, draft: null,
  } as unknown as ModelContext;
  const completion: CompletionEngine = {
    place: (shape, options) => { placements++; return overrides.place?.(shape, options) ?? { shape, mechanism: "continuous", execution }; },
    async run(...args) {
      seen.push(args);
      if (run) return run(...args);
      await args[2](1); await args[2](2);
      return { promptTokens: 3, cachedTokens: 1, generatedTokens: 2, prefillTps: 10, decodeTps: 20, prefillMs: 30, decodeMs: 40, cacheTokens: [7, 8, 9, 1, 2] };
    },
  };
  let exclusive = 0;
  const routes = createCompletionRoutes({ context, completion,
    preparation: overrides.preparation ?? { run: work => work() },
    binding: { discovery: { adapters: false, training: false, dsa: false, embeddings: true },
      embed: inputs => inputs.map(input => ({ vector: Float32Array.from([1, 2]), tokens: input.length })) },
    gateway: { runExclusive: overrides.runExclusive ?? (async (work, _session, signal) => { signal?.throwIfAborted(); exclusive++; return work(); }) },
  }, { contextLimit: 100, promptCache: { peekPrefixLen: () => 0 }, buildPrompt: overrides.buildPrompt });
  return { routes, seen, exclusive: () => exclusive, placements: () => placements };
}
function request(path: string, body: unknown, headers: Record<string, string> = {}, signal?: AbortSignal) {
  return new Request(`http://local${path}`, { method: "POST", body: JSON.stringify(body), headers, signal });
}

test("chat and text routes preserve wire shapes and session affinity through the continuous engine", async () => {
  const { routes, seen } = harness();
  const response = (await routes.handle(request("/v1/chat/completions", { messages: [{ role: "user", content: "hi" }] }, { "x-session-affinity": "session-a" })))!;
  expect(response.status).toBe(200);
  const body = await response.json();
  expect(body.object).toBe("chat.completion"); expect(body.model).toBe("test/model");
  expect(body.choices[0].message.content).toBe("t1 t2"); expect(body.usage.lane).toBe("batched");
  expect(seen[0]![1].cacheSessionId).toBe("session-a");
  const text = (await routes.handle(request("/v1/completions", { prompt: "raw", max_tokens: 2, logprobs: true })))!;
  expect((await text.json()).object).toBe("text_completion");
  expect(seen).toHaveLength(2);
});

test("invalid requests return 400 before scheduling and unmatched routes remain composable", async () => {
  const { routes, seen } = harness();
  for (const body of [null, [], {}, { messages: [] }, { messages: [{ role: "user", content: "x" }], logit_bias: { invalid: "value" } }]) {
    expect((await routes.handle(request("/v1/chat/completions", body)))!.status).toBe(400);
  }
  expect(seen).toHaveLength(0);
  expect(await routes.handle(new Request("http://local/not-migrated"))).toBeNull();
  const health = (await routes.handle(new Request("http://local/health")))!;
  expect(await health.json()).toEqual({ status: "ok" });
  const index = await (await routes.handle(new Request("http://local/v1")))!.json();
  expect(index.endpoints).toContain("POST /v1/chat/completions");
  expect(index.endpoints).not.toContain("POST /v1/messages");
});

test("embeddings retain their OpenAI shape and run under engine exclusivity", async () => {
  const { routes, exclusive } = harness();
  expect((await routes.handle(request("/v1/embeddings", { input: [7] })))!.status).toBe(400);
  const response = (await routes.handle(request("/v1/embeddings", { input: ["abc", "xy"] })))!;
  expect(await response.json()).toEqual({ object: "list", model: "test/model", data: [
    { object: "embedding", index: 0, embedding: [1, 2] }, { object: "embedding", index: 1, embedding: [1, 2] },
  ], usage: { prompt_tokens: 5, total_tokens: 5 } });
  expect(exclusive()).toBe(1);
});

test("SSE closes with usage and DONE; cancelling a reader reaches its engine signal", async () => {
  const successful = harness();
  const response = (await successful.routes.handle(request("/v1/chat/completions", { messages: [{ role: "user", content: "hi" }], stream: true })))!;
  const stream = await response.text();
  expect(response.headers.get("content-type")).toBe("text/event-stream");
  expect(stream).toContain('"role":"assistant"'); expect(stream).toContain('"completion_tokens":2'); expect(stream.endsWith("data: [DONE]\n\n")).toBe(true);
  expect(successful.placements()).toBe(1);
  const entered = Promise.withResolvers<void>(), cancelled = Promise.withResolvers<void>();
  const blocked = harness(async (_ids, _opts, _token, _vision, _shape, _placement, signal) => {
    entered.resolve();
    return new Promise((_resolve, reject) => {
      const abort = () => { cancelled.resolve(); reject(signal!.reason); };
      signal!.addEventListener("abort", abort, { once: true });
      if (signal!.aborted) abort();
    });
  });
  const pending = (await blocked.routes.handle(request("/v1/chat/completions", { messages: [{ role: "user", content: "hi" }], stream: true })))!;
  await entered.promise;
  await pending.body!.cancel("reader closed");
  await cancelled.promise;
});

for (const stream of [false, true]) test(`unsupported execution returns JSON 501 before opening a stream (${stream})`, async () => {
  let disposed = 0;
  const failure = new UnsupportedExecutionError("example", "denoising", ["method-requires-serial", "compiled-decode-unavailable-for-request"]);
  const run = harness(undefined, { place: () => { throw failure; },
    buildPrompt: async (_body, _tools, ownership) => {
      ownership.own({ dispose: () => { disposed++; } });
      return { promptIds: [7], vision: undefined, startInThinking: false, probeStableLen: false, diffusionPixels: null };
    } });
  const logs = spyOn(console, "error").mockImplementation(() => {});
  try {
    const response = (await run.routes.handle(request("/v1/chat/completions", { messages: [{ role: "user", content: "hi" }], stream })))!;
    expect(response.status).toBe(501); expect(response.headers.get("content-type")).toContain("application/json");
    expect(await response.json()).toEqual({ error: { message: failure.message, type: "not_implemented", code: "unsupported_execution", reasons: ["method-requires-serial"] } });
    expect(run.placements()).toBe(1); expect(run.seen).toHaveLength(0); expect(disposed).toBe(1);
    expect(logs).not.toHaveBeenCalled();
  } finally { logs.mockRestore(); }
});

for (const phase of ["preparation", "json", "embedding"] as const) test(`client abort during ${phase} returns 499 without 500 logging`, async () => {
  const entered = Promise.withResolvers<void>(), abort = new AbortController();
  const wait = <T>(signal?: AbortSignal): Promise<T> => {
    entered.resolve();
    return new Promise((_, reject) => {
      signal!.addEventListener("abort", () => reject(signal!.reason), { once: true });
      if (signal!.aborted) reject(signal!.reason);
    });
  };
  const run = harness(phase === "json" ? async (...args) => wait(args[6]) : undefined, {
    ...(phase === "preparation" ? {
      preparation: { run: <T>(_work: () => Promise<T>, signal?: AbortSignal) => wait<T>(signal) },
      buildPrompt: async (_body, _tools, _ownership, _prep, nativeWork) => nativeWork!(async () => ({
        promptIds: [7], vision: undefined, startInThinking: false, probeStableLen: false, diffusionPixels: null,
      })),
    } satisfies Parameters<typeof harness>[1] : {}),
    ...(phase === "embedding" ? { runExclusive: <T>(_work: () => Promise<T>, _trace?: unknown, signal?: AbortSignal) => wait<T>(signal) } : {}),
  });
  const logs = spyOn(console, "error").mockImplementation(() => {});
  try {
    const pending = run.routes.handle(request(phase === "embedding" ? "/v1/embeddings" : "/v1/chat/completions",
      phase === "embedding" ? { input: "hi" } : { messages: [{ role: "user", content: "hi" }] }, {}, abort.signal));
    await entered.promise; abort.abort(null);
    const response = (await pending)!;
    expect(response.status).toBe(499);
    expect(await response.json()).toEqual({ error: { message: "request cancelled", type: "request_cancelled", code: "request_cancelled" } });
    expect(logs).not.toHaveBeenCalled();
  } finally { logs.mockRestore(); }
});

test("unknown thrown values produce a 500 without secondary errors; cancellation is signal-based", async () => {
  const logs = spyOn(console, "error").mockImplementation(() => {});
  try {
    for (const error of [null, undefined, "request cancelled", Object.create(null)]) {
      const response = errorResponse(error, "test");
      expect(response.status).toBe(500); expect(typeof (await response.json()).error.message).toBe("string");
    }
    expect(logs).toHaveBeenCalledTimes(4);
  } finally { logs.mockRestore(); }
});
