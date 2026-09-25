import { expect, spyOn, test } from "bun:test";
import type { ModelContext } from "../../src/engine/model-host";
import type { CompletionEngine } from "../../src/engine/completion";
import { UnsupportedExecutionError } from "../../src/engine/completion";
import { createCompletionRoutes } from "../../src/server/routes";
import { errorResponse } from "../../src/server/http";
import { startServer } from "../../src/server/start";
import { ResponseStore } from "../../src/server/responses";

const execution = { method: "autoregressive", mechanism: "continuous" as const, pagedKv: false, promptCache: true, checkpoint: true, fill: false, compiledDecode: false, grammarJump: false, reasons: [] };
type RouteEngine = Parameters<typeof createCompletionRoutes>[0];
function harness(run?: CompletionEngine["run"], overrides: {
  responseHistory?: ResponseStore;
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
  }, { contextLimit: 100, promptCache: { peekPrefixLen: () => 0 }, buildPrompt: overrides.buildPrompt, responseHistory: overrides.responseHistory });
  return { routes, seen, exclusive: () => exclusive, placements: () => placements };
}
function request(path: string, body: unknown, headers: Record<string, string> = {}, signal?: AbortSignal) {
  return new Request(`http://local${path}`, { method: "POST", body: JSON.stringify(body), headers, signal });
}

test("response history exposes current read-only counters to status composition", async () => {
  const store = new ResponseStore();
  const { routes } = harness(undefined, { responseHistory: store });
  expect(routes.responseStats()).toEqual({ entries: 0, bytes: 0, max_bytes: store.maxBytes, ttl_ms: store.ttlMs });
  await routes.handle(request("/v1/responses", { input: "hello" }));
  expect(routes.responseStats()).toEqual({ entries: 1, bytes: store.totalBytes, max_bytes: store.maxBytes, ttl_ms: store.ttlMs });
  expect(routes.responseStats().bytes).toBeGreaterThan(0);
});

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
  expect(index.endpoints).toContain("POST /v1/messages");
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


test("Messages JSON and SSE use the shared engine and preserve usage and session affinity", async () => {
  const run = harness();
  const body = { messages: [{ role: "user", content: "hi" }], max_tokens: 2, temperature: 0.2, top_p: 0.8 };
  const json = (await run.routes.handle(request("/v1/messages", body, { "x-session-affinity": "anthropic-session" })))!;
  expect(json.status).toBe(200);
  const result = await json.json();
  expect(result).toMatchObject({ type: "message", role: "assistant", model: "test/model",
    content: [{ type: "text", text: "t1 t2" }], usage: { input_tokens: 3, output_tokens: 2, cache_read_input_tokens: 1 } });
  expect(run.seen[0]![1]).toMatchObject({ cacheSessionId: "anthropic-session", maxTokens: 2, temperature: 0.2, topP: 0.8 });
  const stream = (await run.routes.handle(request("/v1/messages", { ...body, stream: true })))!;
  expect(stream.headers.get("content-type")).toBe("text/event-stream");
  const wire = await stream.text();
  expect(wire).toContain("event: message_start");
  expect(wire).toContain("event: content_block_delta");
  expect(wire).toContain('"output_tokens":2');
  expect(wire).toContain("event: message_stop");
  expect(wire).not.toContain("[DONE]");
  expect(run.placements()).toBe(2);
});

for (const stream of [false, true]) test(`Messages capability admission precedes protocol output (${stream})`, async () => {
  let disposed = 0;
  const failure = new UnsupportedExecutionError("example", "denoising", ["method-requires-serial"]);
  const run = harness(undefined, { place: () => { throw failure; },
    buildPrompt: async (_body, _tools, ownership) => {
      ownership.own({ dispose: () => { disposed++; } });
      return { promptIds: [7], vision: undefined, startInThinking: false, probeStableLen: false, diffusionPixels: null };
    } });
  const response = (await run.routes.handle(request("/v1/messages", { messages: [{ role: "user", content: "hi" }], stream })))!;
  expect(response.status).toBe(501);
  expect(response.headers.get("content-type")).toContain("application/json");
  expect(await response.json()).toEqual({ type: "error", error: { type: "api_error", message: failure.message,
    code: "unsupported_execution", reasons: ["method-requires-serial"] } });
  expect(run.placements()).toBe(1); expect(run.seen).toHaveLength(0); expect(disposed).toBe(1);
});

test("Messages malformed requests retain their protocol error envelope", async () => {
  const run = harness();
  for (const body of [null, [], {}, { messages: [] }]) {
    const response = (await run.routes.handle(request("/v1/messages", body)))!;
    expect(response.status).toBe(400);
    expect(await response.json()).toMatchObject({ type: "error", error: { type: "invalid_request_error" } });
  }
  expect(run.seen).toHaveLength(0);
});

for (const phase of ["preparation", "json"] as const) test(`Messages client abort during ${phase} uses a protocol 499`, async () => {
  const entered = Promise.withResolvers<void>(), abort = new AbortController();
  const wait = <T>(signal?: AbortSignal): Promise<T> => {
    entered.resolve();
    return new Promise((_, reject) => {
      signal!.addEventListener("abort", () => reject(signal!.reason), { once: true });
      if (signal!.aborted) reject(signal!.reason);
    });
  };
  const run = harness(phase === "json" ? async (...args) => wait(args[6]) : undefined, phase === "preparation" ? {
    preparation: { run: <T>(_work: () => Promise<T>, signal?: AbortSignal) => wait<T>(signal) },
    buildPrompt: async (_body, _tools, _ownership, _prep, nativeWork) => nativeWork!(async () => ({
      promptIds: [7], vision: undefined, startInThinking: false, probeStableLen: false, diffusionPixels: null,
    })),
  } : {});
  const logs = spyOn(console, "error").mockImplementation(() => {});
  try {
    const pending = run.routes.handle(request("/v1/messages", { messages: [{ role: "user", content: "hi" }] }, {}, abort.signal));
    await entered.promise; abort.abort(null);
    const response = (await pending)!;
    expect(response.status).toBe(499);
    expect(await response.json()).toEqual({ type: "error", error: {
      message: "request cancelled", type: "invalid_request_error", code: "request_cancelled",
    } });
    expect(logs).not.toHaveBeenCalled();
  } finally { logs.mockRestore(); }
});

test("Messages listener disconnect cancels execution and permits the next request", async () => {
  const entered = Promise.withResolvers<void>(), cancelled = Promise.withResolvers<void>();
  let count = 0, closed = 0;
  const run = harness(async (_ids, _opts, token, _vision, _shape, _placement, signal) => {
    if (++count === 1) {
      entered.resolve();
      await new Promise<void>((_, reject) => {
        const abort = () => { cancelled.resolve(); reject(signal!.reason); };
        signal!.addEventListener("abort", abort, { once: true });
        if (signal!.aborted) abort();
      });
    }
    await token(1);
    return { promptTokens: 3, cachedTokens: 0, generatedTokens: 1, prefillTps: 0, decodeTps: 0, prefillMs: 0, decodeMs: 0, cacheTokens: [7, 8, 9, 1] };
  });
  const listener = await startServer({ routes: run.routes, web: () => null,
    chat: () => ({ async start() {}, async handle() {}, dispose() {} }),
    closeEngine: async () => { closed++; },
  }, { port: 0 });
  const abort = new AbortController();
  try {
    const url = new URL("/v1/messages", listener.server.url);
    const response = await fetch(url, { method: "POST", signal: abort.signal,
      body: JSON.stringify({ messages: [{ role: "user", content: "hi" }], stream: true }) });
    expect(response.status).toBe(200);
    const first = await response.body!.getReader().read();
    expect(new TextDecoder().decode(first.value)).toContain("message_start");
    await entered.promise; abort.abort(); await cancelled.promise;
    const next = await fetch(url, { method: "POST", body: JSON.stringify({ messages: [{ role: "user", content: "again" }] }) });
    expect(next.status).toBe(200); expect((await next.json()).type).toBe("message");
  } finally { abort.abort(); await listener.close(); }
  expect(closed).toBe(1);
});


test("Responses retains completed JSON and SSE history, instructions, and cache affinity", async () => {
  let now = 0;
  const history = new ResponseStore(10, 32 * 1024 * 1024, () => now);
  const prompts: unknown[] = [];
  const run = harness(undefined, { responseHistory: history, buildPrompt: async (body) => {
    prompts.push(body.messages);
    return { promptIds: [7, 8, 9], vision: undefined, startInThinking: false, probeStableLen: false, diffusionPixels: null };
  } });
  const first = (await run.routes.handle(request("/v1/responses", { input: "first", instructions: "be terse", max_output_tokens: 9,
    temperature: 0.2, top_p: 0.8 }, { "x-session-affinity": "responses-session", "x-mlx-bun-response-owner": "parent" })))!;
  expect(first.status).toBe(200);
  const a = await first.json();
  expect(a).toMatchObject({ object: "response", status: "completed", model: "test/model", previous_response_id: null,
    usage: { input_tokens: 3, output_tokens: 2, total_tokens: 5, input_tokens_details: { cached_tokens: 1 } } });
  expect(history.get(a.id)).toMatchObject({ instructions: "be terse", input: [{ type: "message", role: "user", content: "first" }] });
  expect(run.seen[0]![1]).toMatchObject({ cacheSessionId: "responses-session", maxTokens: 9, temperature: 0.2, topP: 0.8 });
  const second = (await run.routes.handle(request("/v1/responses", { input: "second", previous_response_id: a.id, stream: true })))!;
  const wire = await second.text();
  expect(wire).toContain("event: response.output_text.delta");
  const completed = wire.split("\n\n").find(frame => frame.startsWith("event: response.completed"))!;
  const b = JSON.parse(completed.split("\ndata: ")[1]!).response;
  expect(b.previous_response_id).toBe(a.id);
  expect(history.get(b.id)?.input).toHaveLength(3);
  expect(prompts[1]).toEqual([
    { role: "system", content: "be terse" }, { role: "user", content: "first" },
    { role: "assistant", content: "t1 t2" }, { role: "user", content: "second" },
  ]);
  await run.routes.handle(request("/v1/responses", { previous_response_id: b.id, input: "third", instructions: "new policy" }));
  expect((prompts[2] as { content: string }[])[0]!.content).toBe("new policy");
  now = 11;
  const expired = (await run.routes.handle(request("/v1/responses", { input: "again", previous_response_id: a.id })))!;
  expect(expired.status).toBe(404);
  expect(await expired.json()).toEqual({ error: { message: `previous_response_id '${a.id}' not found or expired`,
    type: "invalid_request_error", param: null, code: null } });
  expect(run.seen).toHaveLength(3);
});

for (const stream of [false, true]) test(`Responses capability admission precedes protocol output and history (${stream})`, async () => {
  let disposed = 0;
  const history = new ResponseStore();
  const failure = new UnsupportedExecutionError("example", "denoising", ["method-requires-serial"]);
  const run = harness(undefined, { responseHistory: history, place: () => { throw failure; },
    buildPrompt: async (_body, _tools, ownership) => {
      ownership.own({ dispose: () => { disposed++; } });
      return { promptIds: [7], vision: undefined, startInThinking: false, probeStableLen: false, diffusionPixels: null };
    } });
  const response = (await run.routes.handle(request("/v1/responses", { input: "hi", stream })))!;
  expect(response.status).toBe(501);
  expect(response.headers.get("content-type")).toContain("application/json");
  expect(await response.json()).toEqual({ error: { type: "server_error", message: failure.message, param: null,
    code: "unsupported_execution", reasons: ["method-requires-serial"] } });
  expect(run.placements()).toBe(1); expect(run.seen).toHaveLength(0); expect(disposed).toBe(1); expect(history.size).toBe(0);
});

test("Responses malformed input returns 400 rather than masquerading as missing history", async () => {
  const run = harness();
  for (const body of [null, [], {}, { input: 1 }, { input: "hi", previous_response_id: {} }]) {
    const response = (await run.routes.handle(request("/v1/responses", body)))!;
    expect(response.status).toBe(400);
    expect(await response.json()).toMatchObject({ error: { type: "invalid_request_error", param: null, code: null } });
  }
  expect(run.seen).toHaveLength(0);
});

for (const phase of ["preparation", "json"] as const) test(`Responses client abort during ${phase} uses a protocol 499 without history`, async () => {
  const history = new ResponseStore();
  const entered = Promise.withResolvers<void>(), abort = new AbortController();
  const wait = <T>(signal?: AbortSignal): Promise<T> => {
    entered.resolve();
    return new Promise((_, reject) => {
      signal!.addEventListener("abort", () => reject(signal!.reason), { once: true });
      if (signal!.aborted) reject(signal!.reason);
    });
  };
  const run = harness(phase === "json" ? async (...args) => wait(args[6]) : undefined, { responseHistory: history,
    ...(phase === "preparation" ? {
      preparation: { run: <T>(_work: () => Promise<T>, signal?: AbortSignal) => wait<T>(signal) },
      buildPrompt: async (_body, _tools, _ownership, _prep, nativeWork) => nativeWork!(async () => ({
        promptIds: [7], vision: undefined, startInThinking: false, probeStableLen: false, diffusionPixels: null,
      })),
    } satisfies Parameters<typeof harness>[1] : {}),
  });
  const logs = spyOn(console, "error").mockImplementation(() => {});
  try {
    const pending = run.routes.handle(request("/v1/responses", { input: "hi" }, {}, abort.signal));
    await entered.promise; abort.abort(null);
    const response = (await pending)!;
    expect(response.status).toBe(499);
    expect(await response.json()).toEqual({ error: {
      message: "request cancelled", type: "invalid_request_error", param: null, code: "request_cancelled",
    } });
    expect(history.size).toBe(0); expect(logs).not.toHaveBeenCalled();
  } finally { logs.mockRestore(); }
});

for (const stream of [false, true]) test(`Responses generation failure is not completed or stored (${stream})`, async () => {
  const history = new ResponseStore();
  const run = harness(async (_ids, _opts, token) => { await token(1); throw new Error("generation failed"); }, { responseHistory: history });
  const logs = spyOn(console, "error").mockImplementation(() => {});
  try {
    const response = (await run.routes.handle(request("/v1/responses", { input: "hi", stream })))!;
    if (stream) {
      expect(response.status).toBe(200);
      const wire = await response.text();
      expect(wire).toContain('event: error'); expect(wire).toContain('"code":"server_error"');
      expect(wire).not.toContain('event: response.completed');
      const terminal = wire.trim().split("\n\n").at(-1)!;
      expect(terminal).toStartWith("event: response.failed\n");
      expect(JSON.parse(terminal.split("\ndata: ")[1]!).response).toMatchObject({ status: "failed",
        error: { code: "server_error", message: "generation failed" }, usage: { output_tokens: 1 } });
    } else {
      expect(response.status).toBe(500);
      expect(await response.json()).toEqual({ error: { message: "generation failed", type: "server_error", param: null, code: null } });
    }
    expect(history.size).toBe(0);
  } finally { logs.mockRestore(); }
});

test("Responses listener disconnect cancels execution without making partial output resumable", async () => {
  const entered = Promise.withResolvers<void>(), cancelled = Promise.withResolvers<void>();
  const history = new ResponseStore();
  let count = 0, closed = 0;
  const run = harness(async (_ids, _opts, token, _vision, _shape, _placement, signal) => {
    if (++count === 1) {
      await token(1); entered.resolve();
      await new Promise<void>((_, reject) => {
        const abort = () => { cancelled.resolve(); reject(signal!.reason); };
        signal!.addEventListener("abort", abort, { once: true });
        if (signal!.aborted) abort();
      });
    }
    await token(2);
    return { promptTokens: 3, cachedTokens: 0, generatedTokens: 1, prefillTps: 0, decodeTps: 0, prefillMs: 0, decodeMs: 0, cacheTokens: [7, 8, 9, 2] };
  }, { responseHistory: history });
  const listener = await startServer({ routes: run.routes, web: () => null,
    chat: () => ({ async start() {}, async handle() {}, dispose() {} }), closeEngine: async () => { closed++; },
  }, { port: 0 });
  const abort = new AbortController();
  try {
    const url = new URL("/v1/responses", listener.server.url);
    const response = await fetch(url, { method: "POST", signal: abort.signal, body: JSON.stringify({ input: "hi", stream: true }) });
    const first = new TextDecoder().decode((await response.body!.getReader().read()).value);
    expect(first).toContain("response.created");
    await entered.promise; abort.abort(); await cancelled.promise;
    expect(history.size).toBe(0);
    const next = await fetch(url, { method: "POST", body: JSON.stringify({ input: "again" }) });
    expect(next.status).toBe(200); const result = await next.json();
    expect(history.get(result.id)?.output).toEqual(result.output);
    expect(history.size).toBe(1);
  } finally { abort.abort(); await listener.close(); }
  expect(closed).toBe(1);
});
