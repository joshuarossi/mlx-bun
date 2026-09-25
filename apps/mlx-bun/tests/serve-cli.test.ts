import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import { expect, test } from "bun:test";
import { EventEmitter } from "node:events";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { commandInvocation, parseCommand } from "../src/cli/args";
import { browserUrl, installShutdownHandlers, parseServeOptions, resolveServingLimits, runServe, type ServeDependencies, type ServeOptions } from "../src/cli/serve";

const parse = (...args: string[]) => parseServeOptions(parseCommand("serve", args));
const model = { repoId: "example/model", path: "/model" } as ModelRecord;
const tick = () => new Promise(resolve => setImmediate(resolve));

test("serving defaults to continuous capacity eight; capacity one uses the same engine options", () => {
  expect(parse()).toMatchObject({ query: null, capacity: 8, port: 8080, hostname: "127.0.0.1", contextLimit: null, cache: { kvQuant: "off" }, request: {} });
  expect(parse("--batch", "1").capacity).toBe(1);
  expect(() => parse("--serial")).toThrow();
  expect(() => parse("--compiled-decode", "on")).toThrow();
});

test("serving forwards explicit sampling and cache choices with their original units", () => {
  expect(parse("fallback", "--model", "chosen", "--query", "ignored", "--port", "0",
    "--temp", "0.7", "--thinking", "off", "--top-p", "0.9", "--top-k", "20", "--max-tokens", "7.9",
    "--prompt-cache", "2", "--ssd-cache", "/cache", "--ssd-cache-max", "0", "--ssd-cache-verify",
    "--ssd-demote-idle", "0", "--generation-checkpoint", "128", "--kv-quant", "4", "--kv-budget", "3",
    "--no-open")).toMatchObject({
      query: "chosen", port: 0, contextLimit: null, defaultGeneratedTokens: 7, kvBudgetBytes: 3e9,
      readOnly: false, noOpen: true,
      request: { defaultTemperature: 0.7, defaultThinking: false, defaultTopP: 0.9, defaultTopK: 20 },
      cache: { promptCacheBytes: 2 * 2 ** 30, ssdCacheDir: "/cache", ssdCacheMaxBytes: Infinity,
        ssdCacheVerify: true, ssdDemoteIdleSec: 0, generationCheckpointTokens: 128, kvQuant: 4 },
    });
  expect(parse("--temp", "1", "--temperature", "0").request.defaultTemperature).toBe(0);
  expect(parse("positional", "--query", "fallback").query).toBe("positional");
});

test("the existing runtime context cap is validated without adding serve flags", () => {
  const restore = configureRuntime({ MLX_BUN_RD_CONTEXT_LIMIT: "2048" });
  try {
    expect(parse().contextLimit).toBe(2048);
    expect(() => parse("--ctx", "4096")).toThrow();
    expect(() => parse("--read-only")).toThrow();
  } finally { restore(); }
  for (const raw of ["", "0", "-1", "1.5", "NaN"]) {
    const restore = configureRuntime({ MLX_BUN_RD_CONTEXT_LIMIT: raw });
    try { expect(() => parse()).toThrow("MLX_BUN_RD_CONTEXT_LIMIT must be a positive integer"); }
    finally { restore(); }
  }
});

test("loaded GLM plans supply context/output defaults and intersect explicit or profile context caps", () => {
  const plan = { contextTokens: 8192, maxGenerationTokens: 2048 };
  expect(resolveServingLimits(parse(), plan)).toEqual({ contextLimit: 8192, defaultGeneratedTokens: 2048 });
  expect(resolveServingLimits({ ...parse(), contextLimit: 16384 }, plan)).toEqual({ contextLimit: 8192, defaultGeneratedTokens: 2048 });
  expect(resolveServingLimits({ ...parse("--max-tokens", "512"), contextLimit: 4096 }, plan))
    .toEqual({ contextLimit: 4096, defaultGeneratedTokens: 512 });
  // Main lets an explicit default generation cap override the plan default.
  expect(resolveServingLimits(parse("--max-tokens", "3000"), plan).defaultGeneratedTokens).toBe(3000);
  const restore = configureRuntime({ MLX_BUN_RD_CONTEXT_LIMIT: "1024" });
  try { expect(resolveServingLimits(parse(), plan)).toEqual({ contextLimit: 1024, defaultGeneratedTokens: 2048 }); }
  finally { restore(); }
});

test("ordinary models receive no inferred context or generation cap from GLM composition", () => {
  expect(resolveServingLimits(parse())).toEqual({ contextLimit: null, defaultGeneratedTokens: undefined });
  expect(resolveServingLimits({ ...parse("--max-tokens", "512"), contextLimit: 4096 }, null))
    .toEqual({ contextLimit: 4096, defaultGeneratedTokens: 512 });
});

test("invalid serving input fails before model selection", async () => {
  for (const args of [["--batch", "0"], ["--batch", "1.5"], ["--port", "65536"],
    ["--temp", "6"], ["--top-p", "2"], ["--thinking", "maybe"], ["--kv-quant", "3"],
    ["--ssd-cache-verify"], ["--generation-checkpoint", "128"], ["--ssd-cache", "/cache", "--prompt-cache", "0"]]) {
    let selected = false;
    await expect(runServe(parseCommand("serve", args), { resolve: async () => { selected = true; throw new Error("must not select"); } })).rejects.toThrow();
    expect(selected).toBe(false);
  }
});

function runtime(interactive = true) {
  const signals = new EventEmitter(), opens: string[] = [], exits: number[] = [], errors: unknown[] = [], starts: ServeOptions[] = [];
  let closes = 0;
  const dependencies: ServeDependencies = {
    resolve: async () => ({ m: model, picked: true }),
    start: async (m, options) => { expect(m).toBe(model); starts.push(options); return { port: 4321, close: async () => { closes++; } }; },
    interactive, open: url => { opens.push(url); }, log() {}, signals,
    exit: code => { exits.push(code); }, error: error => { errors.push(error); },
  };
  return { dependencies, signals, opens, exits, errors, starts, closes: () => closes };
}

test("interactive startup opens the bound port and graceful shutdown drains exactly once", async () => {
  const run = runtime();
  const app = await runServe(parseCommand("serve", ["--batch", "1", "--port", "0", "--host", "0.0.0.0"]), run.dependencies);
  expect(run.starts[0]?.capacity).toBe(1);
  expect(run.opens).toEqual(["http://localhost:4321/#/chat"]);
  run.signals.emit("SIGINT"); run.signals.emit("SIGTERM");
  await tick(); await app.close();
  expect(run.closes()).toBe(1); expect(run.exits).toEqual([0]);
  expect(run.signals.listenerCount("SIGINT")).toBe(0);
  expect(run.signals.listenerCount("SIGTERM")).toBe(0);
});

test("noninteractive startup and no-open leave the browser closed; programmatic close removes listeners", async () => {
  for (const [interactive, args] of [[false, []], [true, ["--no-open"]]] as const) {
    const run = runtime(interactive);
    const app = await runServe(parseCommand("serve", [...args]), run.dependencies);
    expect(run.opens).toEqual([]); await app.close(); await app.close();
    expect(run.closes()).toBe(1); expect(run.exits).toEqual([]);
    expect(run.signals.listenerCount("SIGTERM")).toBe(0);
  }
});

test("browser failure does not abandon a running server", async () => {
  const run = runtime(), failure = new Error("open failed");
  const app = await runServe(parseCommand("serve", []), { ...run.dependencies, open: () => { throw failure; } });
  expect(run.errors).toEqual([failure]); expect(run.closes()).toBe(0); await app.close();
});

test("startup failure installs no signal handlers and opens no browser", async () => {
  const run = runtime();
  await expect(runServe(parseCommand("serve", []), { ...run.dependencies, start: async () => { throw new Error("bind failed"); } })).rejects.toThrow("bind failed");
  expect(run.signals.listenerCount("SIGINT")).toBe(0); expect(run.opens).toEqual([]);
});

test("signals wait for teardown and report cleanup failures with a nonzero exit", async () => {
  const run = runtime(), failure = new Error("flush failed");
  let reject!: (error: Error) => void, calls = 0;
  installShutdownHandlers(() => { calls++; return new Promise<void>((_, fail) => { reject = fail; }); }, {
    signals: run.signals, exit: run.dependencies.exit, error: run.dependencies.error,
  });
  run.signals.emit("SIGTERM"); run.signals.emit("SIGINT");
  expect(calls).toBe(1); expect(run.exits).toEqual([]);
  expect(run.signals.listenerCount("SIGINT")).toBe(1);
  reject(failure); await tick();
  expect(run.errors).toEqual([failure]); expect(run.exits).toEqual([1]);
  expect(run.signals.listenerCount("SIGINT")).toBe(0);
});

test("browser addresses support IPv6 and wildcard listeners", () => {
  expect(browserUrl("::", 8080)).toBe("http://localhost:8080/#/chat");
  expect(browserUrl("::1", 8080)).toBe("http://[::1]:8080/#/chat");
});


test("the process owner bounds shutdown without releasing live resources or exiting twice", async () => {
  const run = runtime();
  const pending = Promise.withResolvers<void>();
  const exited = Promise.withResolvers<void>();
  let releases = 0;
  installShutdownHandlers(async () => { await pending.promise; releases++; }, {
    signals: run.signals, timeoutMs: 5, error: run.dependencies.error,
    exit(code) { run.exits.push(code); exited.resolve(); },
  });
  run.signals.emit("SIGTERM");
  await exited.promise;
  expect(run.exits).toEqual([1]);
  expect((run.errors[0] as Error).message).toContain("persistence may be incomplete");
  expect(releases).toBe(0);
  pending.resolve(); await tick();
  expect(releases).toBe(1); expect(run.exits).toEqual([1]);
  expect(run.signals.listenerCount("SIGTERM")).toBe(0);
});


test("bare and option-first CLI invocations dispatch to serve without loading a model", () => {
  expect(commandInvocation([])).toEqual({ command: "serve", args: [] });
  expect(commandInvocation(["--port", "0"])).toEqual({ command: "serve", args: ["--port", "0"] });
  expect(commandInvocation(["serve", "model", "--port", "0"])).toEqual({ command: "serve", args: ["model", "--port", "0"] });
  expect(commandInvocation(["ls", "tiny"])).toEqual({ command: "ls", args: ["tiny"] });
  for (const command of ["--help", "--version", "-h", "-v"])
    expect(commandInvocation([command])).toEqual({ command, args: [] });
});

test("startup attaches continuation/cache services and token history before listener ownership", async () => {
  // Isolate module mocks in a child so other engine tests always see real modules.
  const app = new URL("../", import.meta.url).pathname;
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    const app = ${JSON.stringify(app)};
    const events = [], remembered = [];
    const chatPaths = { toolApprovalsFile: "/unused/approvals.json" };
    const context = { modelId: "test", model: { config: { text: { maxPositionEmbeddings: 65536 } } },
      glmMemoryPlan: { contextTokens: 8192, maxGenerationTokens: 2048 }, tokenizer: {},
      template: { supportsThinking: false }, genDefaults: {}, dispose() { events.push("model close"); } };
    const cache = { promptCache: {}, resolvedKvScheme: { mode: "off" }, kvScheme: {}, stateCodecs: {},
      adapterNamespace() {}, checkpoints: { tokenPrefixes: () => [[1, 2]] }, continuationServices: {},
      stopIdleDemotion() { events.push("timer stop"); }, async close() { events.push("cache close"); return { durable: true }; } };
    const binding = { gateway: { configureContinuation(services) {
      assert.equal(services, cache.continuationServices); events.push("continuation");
    } } };
    let engine, listenerInput;
    mock.module(app + "src/engine/index.ts", () => ({
      loadContext: async () => context, modelServingBinding: async () => binding, createCacheServices: async () => cache,
      createAppEngine: async (supplied, options) => {
        assert.equal(supplied, context); assert.equal(options.binding, binding);
        assert.equal(options.gateway.promptCache, cache.promptCache);
        assert.equal(options.gateway.stateCodecs, cache.stateCodecs);
        assert.equal(options.gateway.kvScheme, cache.resolvedKvScheme);
        assert.equal(options.gateway.adapterNamespace, cache.adapterNamespace);
        assert.equal(options.gateway.checkpoints, true);
        assert.deepEqual(events, ["continuation"]); events.push("engine");
        return engine = { async close() { await options.beforeModelDispose(); context.dispose(); } };
      }
    }));
    mock.module(app + "src/server/generated-token-history.ts", () => ({ GeneratedTokenHistory: class {
      remember(tokens) { remembered.push(tokens); }
    } }));
    mock.module(app + "src/server/routes.ts", () => ({ createCompletionRoutes(supplied, options) {
      assert.equal(supplied, engine); assert.equal(options.promptCache, cache.promptCache);
      assert.equal(options.contextLimit, 8192); assert.equal(options.defaultGeneratedTokens, 2048);
      assert.deepEqual(remembered, [[1, 2]]); cache.promptCache.onPut([3, 4]);
      assert.deepEqual(remembered, [[1, 2], [3, 4]]); assert.ok(options.tokenHistory);
      events.push("routes"); return { handle: async () => null, invalidateLibrary() {} };
    } }));
    mock.module(app + "src/server/management-routes.ts", () => ({ createManagementRoutes(options) {
      assert.equal(options.toolApprovalsFile, chatPaths.toolApprovalsFile);
      assert.equal(options.servedModelPath, "/unused"); assert.equal(typeof options.invalidateLibrary, "function");
      return { handle: async () => null };
    } }));
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => () => null }));
    mock.module(app + "src/chat/pi-backend.ts", () => ({ createPiBackend(options) {
      assert.equal(options.contextWindow, 8192); assert.equal(options.readOnly, true); assert.equal(options.paths, chatPaths); return () => {};
    } }));
    mock.module(app + "src/server/start.ts", () => ({ startServer: async input => {
      listenerInput = input; events.push("listener");
      return { server: { port: 1234 }, close: async () => { await input.beforeDrain(); await input.closeEngine(); } };
    } }));
    const { startModelServer } = await import(app + "src/cli/serve.ts");
    const running = await startModelServer({ path: "/unused", repoId: "test" }, {
      query: null, hostname: "127.0.0.1", port: 0, capacity: 8, contextLimit: null,
      readOnly: true, noOpen: true, chatPaths, request: {}, cache: { kvQuant: "off", generationCheckpointTokens: 32 }
    });
    assert.equal(running.port, 1234);
    assert.deepEqual(events, ["continuation", "engine", "routes", "listener"]);
    await running.close();
    assert.deepEqual(events.slice(-3), ["timer stop", "cache close", "model close"]);
  `;
  const child = Bun.spawn([process.execPath, "--eval", script], { stdout: "pipe", stderr: "pipe",
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent" } });
  const [code, stderr] = await Promise.all([child.exited, new Response(child.stderr).text()]);
  expect(stderr).toBe(""); expect(code).toBe(0);
});
