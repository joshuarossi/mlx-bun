import { expect, test } from "bun:test";

const modelDir = process.env.MLX_BUN_APP_TEST_MODEL;

// Opt-in: uses an already-downloaded autoregressive model, never downloads one.
// A supplied invalid path or missing native runtime must fail rather than skip.
test.skipIf(!modelDir)("real HTTP generation shares the continuous engine and recovers after stream cancellation", async () => {
  const { loadContext, modelServingBinding, createAppEngine, createCacheServices } = await import("../../src/engine");
  const { createCompletionRoutes } = await import("../../src/server/routes");
  const { startServer } = await import("../../src/server/start");
  const context = await loadContext(modelDir!);
  let close: () => void | Promise<unknown> = () => context.dispose();
  try {
    const binding = await modelServingBinding(context);
    const cache = await createCacheServices(context, binding, { promptCacheBytes: 128 * 1024 ** 2 });
    close = async () => { try { await cache.close(); } finally { context.dispose(); } };
    binding.gateway.configureContinuation?.(cache.continuationServices);
    // Construction takes ownership of context and cache even when it fails.
    close = () => {};
    const engine = await createAppEngine(context, { binding, capacity: 8,
      gateway: { promptCache: cache.promptCache, kvScheme: cache.resolvedKvScheme,
        stateCodecs: cache.stateCodecs, adapterNamespace: cache.adapterNamespace },
      beforeModelDispose: () => cache.close(),
    });
    close = () => engine.close();
    const routes = createCompletionRoutes(engine, { promptCache: cache.promptCache,
      contextLimit: 2048, kvScheme: cache.kvScheme, defaultGeneratedTokens: 8 });
    close = () => {};
    const app = await startServer({ routes, web: () => null,
      chat: () => ({ async start() {}, async handle() {}, dispose() {} }),
      closeEngine: () => engine.close(),
    }, { port: 0 });
    close = () => app.close();
    const endpoint = new URL("/v1/chat/completions", app.server.url);
    const body = { messages: [{ role: "user", content: "Say hello in one sentence." }], max_tokens: 8, temperature: 0 };
    const request = (options: typeof body & { stream?: boolean } = body) => fetch(endpoint, { method: "POST",
      headers: { "content-type": "application/json" }, body: JSON.stringify(options) });
    const baselineResponse = await request();
    expect(baselineResponse.status).toBe(200);
    const baseline = await baselineResponse.json();
    expect(baseline.choices).toHaveLength(1);
    const pair = await Promise.all([request(), request()]);
    for (const response of pair) {
      expect(response.status).toBe(200);
      expect((await response.json()).choices).toEqual(baseline.choices);
    }
    const stream = await request({ ...body, max_tokens: 128, stream: true });
    expect(stream.status).toBe(200);
    const reader = stream.body!.getReader();
    try { expect((await reader.read()).done).toBe(false); }
    finally { await reader.cancel(); }
    const afterCancel = await request();
    expect(afterCancel.status).toBe(200);
    await afterCancel.arrayBuffer();
    await app.close();
    expect(engine.gateway.activeRows).toBe(0);
    expect(engine.gateway.pendingRows).toBe(0);
  } finally { await close(); }
}, 120_000);
