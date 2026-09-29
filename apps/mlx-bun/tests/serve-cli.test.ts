import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import { expect, test } from "bun:test";
import { EventEmitter } from "node:events";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { commandInvocation, parseCommand } from "../src/cli/args";
import { resolveKvScheme } from "@mlx-bun/inference/state/kv-scheme";
import { browserUrl, installShutdownHandlers, parseServeOptions, resolveServingLimits, runServe, validatePagedServingOptions, type ServeDependencies, type ServeOptions } from "../src/cli/serve";
import { decodeLaunch, encodeLaunch } from "../src/jobs/worker-process";

const parse = (...args: string[]) => parseServeOptions(parseCommand("serve", args));
const model = { repoId: "example/model", path: "/model" } as ModelRecord;
const tick = () => new Promise(resolve => setImmediate(resolve));

test("serving defaults to continuous capacity eight; capacity one uses the same engine options", () => {
  expect(parse()).toMatchObject({ query: null, capacity: 8, port: 8080, hostname: "127.0.0.1", contextLimit: null, cache: { kvQuant: "off" }, request: {} });
  expect(parse("--batch", "1").capacity).toBe(1);
  expect(parse("--decode-concurrency", "3").capacity).toBe(3);
  expect(parse("--batch", "2", "--decode-concurrency", "5").capacity).toBe(2);
  expect(() => parse("--decode-concurrency", "0")).toThrow();
  expect(() => parse("--serial")).toThrow();
  expect(() => parse("--compiled-decode", "on")).toThrow();
});

test("saved prompt/KV state is on by default under MLX_BUN_HOME/kv with a 20 GiB budget; a directory moves it, off and a zero RAM cache disable it", () => {
  const restore = configureRuntime({ MLX_BUN_HOME: "/tmp/mlx-home" });
  try {
    expect(parse().cache).toMatchObject({ ssdCacheDir: "/tmp/mlx-home/kv", ssdCacheMaxBytes: 20 * 2 ** 30, ssdCacheVerify: false });
    expect(parse("--generation-checkpoint", "64").cache).toMatchObject({ ssdCacheDir: "/tmp/mlx-home/kv", generationCheckpointTokens: 64 });
    expect(parse("--ssd-cache-max", "0").cache.ssdCacheMaxBytes).toBe(Infinity);
    expect(parse("--ssd-cache-max", "3").cache.ssdCacheMaxBytes).toBe(3 * 2 ** 30);
    expect(parse("--ssd-cache", "/elsewhere").cache.ssdCacheDir).toBe("/elsewhere");
    expect(parse("--ssd-cache", "off").cache.ssdCacheDir).toBeUndefined();
    expect(parse("--prompt-cache", "0").cache.ssdCacheDir).toBeUndefined();
  } finally { restore(); }
});

test("serving numerical aliases and kernel overrides survive isolated worker serialization", () => {
  for (const [flags, kvQuant, fusedSdpa] of [
    [[], "off", false], [["--l1"], "off", false], [["--l2"], "config", true],
    [["--l2", "--l1"], "config", true], [["--l1", "--l2"], "config", true],
    [["--l2", "--kv-quant", "off"], "off", false], [["--l2", "--kv-quant", "4"], 4, false],
    [["--l1", "--kv-quant", "config"], "config", true],
    [["--l2", "--fused-sdpa", "off"], "config", false], [["--l1", "--fused-sdpa", "on"], "off", true],
  ] as const) {
    const options = parse("--isolate", ...flags);
    expect(options).toMatchObject({ cache: { kvQuant }, fusedSdpa });
    expect(decodeLaunch(encodeLaunch({ ...options, isolate: false }))).toMatchObject({ cache: { kvQuant }, fusedSdpa });
  }
  for (const value of ["on", "1", "true"]) expect(parse("--fused-sdpa", value).fusedSdpa).toBe(true);
  for (const value of ["off", "0", "false"]) expect(parse("--l2", "--fused-sdpa", value).fusedSdpa).toBe(false);
  expect(parse("--l2", "--kv-quant", "turbo", "--fused-sdpa", "on"))
    .toMatchObject({ cache: { turboQuant: { kBits: 8, vBits: 3 } }, fusedSdpa: true });
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

test("loaded runtime plans supply context/output defaults and intersect explicit or profile context caps", () => {
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

test("ordinary models receive no inferred context or generation cap from plan composition", () => {
  expect(resolveServingLimits(parse())).toEqual({ contextLimit: null, defaultGeneratedTokens: undefined });
  expect(resolveServingLimits({ ...parse("--max-tokens", "512"), contextLimit: 4096 }, null))
    .toEqual({ contextLimit: 4096, defaultGeneratedTokens: 512 });
});

test("serving parses main's TurboQuant spec into the cache scheme, through the isolated launch", () => {
  expect(parse("--kv-quant", "turbo").cache).toMatchObject({ turboQuant: { kBits: 8, vBits: 3 } });
  expect(parse("--kv-quant", "turbo:k4v2").cache).toMatchObject({ turboQuant: { kBits: 4, vBits: 2 } });
  // Cache services resolve it as main's standalone scheme: TurboQuant from decode start.
  const { cache } = parse("--kv-quant", "turbo:k5v4");
  expect(resolveKvScheme({ override: cache.kvQuant, turboQuant: cache.turboQuant, quantizedKvStart: cache.quantizedKvStart })
    .generationOptions).toEqual({ turboQuant: { kBits: 5, vBits: 4 }, quantizedKvStart: 0 });
  // An isolated worker receives the parent's resolved options as its launch record.
  expect((decodeLaunch(encodeLaunch({ ...parse("--isolate", "--kv-quant", "turbo:k4v3"), isolate: false })) as ServeOptions).cache)
    .toMatchObject({ turboQuant: { kBits: 4, vBits: 3 } });
  for (const [spec, message] of [["turbo:k3v3", "kBits must be one of 2,4,5,8 (got 3)"],
    ["turbo:k8v6", "vBits must be one of 2,3,4,5,8 (got 6)"], ["turbo:8", 'must look like "turbo:k<bits>v<bits>"'],
    ["turbo8", "--kv-quant expects off|config|4|8|turbo[:k<bits>v<bits>]"]] as const)
    expect(() => parse("--kv-quant", spec)).toThrow(message);
  // Paging keeps refusing TurboQuant at startup.
  const paged = parse("--paged-kv", "--kv-quant", "turbo");
  expect(() => validatePagedServingOptions(paged.request.pagedKv, resolveKvScheme({ turboQuant: paged.cache.turboQuant }).generationOptions, false))
    .toThrow("per-layer and TurboQuant pages are not implemented");
});

test("invalid serving input fails before model selection", async () => {
  for (const args of [["--batch", "0"], ["--batch", "1.5"], ["--port", "65536"],
    ["--temp", "6"], ["--top-p", "2"], ["--thinking", "maybe"], ["--fused-sdpa", "maybe"], ["--kv-quant", "3"], ["--kv-quant", "turbo:k3v3"],
    ["--ssd-cache", "off", "--ssd-cache-verify"], ["--ssd-cache", "off", "--generation-checkpoint", "128"], ["--ssd-cache", "off", "--ssd-cache-max", "1"],
    ["--prompt-cache", "0", "--ssd-cache-verify"], ["--ssd-cache", "/cache", "--prompt-cache", "0"], ["--ssd-cache", " "]]) {
    let selected = false;
    await expect(runServe(parseCommand("serve", args), { resolve: async () => { selected = true; throw new Error("must not select"); } })).rejects.toThrow();
    expect(selected).toBe(false);
  }
});

function runtime(interactive = true) {
  const signals = new EventEmitter(), opens: string[] = [], exits: number[] = [], errors: unknown[] = [], starts: ServeOptions[] = [];
  const downloads: string[] = [], logs: string[] = [], transcriptionStarts: [ModelRecord, ServeOptions][] = [];
  let closes = 0;
  const dependencies: ServeDependencies = {
    resolve: async () => ({ m: model, picked: true }),
    start: async (m, options) => { expect(m).toBe(model); starts.push(options); return { port: 4321,
      downloads: { start: repo => { downloads.push(repo); }, active: [] }, close: async () => { closes++; } }; },
    startTranscription: async (m, options) => { transcriptionStarts.push([m, options]); return { port: 4321,
      downloads: { start() { throw new Error("no downloads"); }, active: [] }, close: async () => { closes++; } }; },
    interactive, open: url => { opens.push(url); }, log: message => { logs.push(message); }, signals,
    exit: code => { exits.push(code); }, error: error => { errors.push(error); },
  };
  return { dependencies, signals, opens, exits, errors, starts, transcriptionStarts, downloads, logs, closes: () => closes };
}

test("--isolate is a parent-only boolean that selects the isolated composition and refuses the transcription-only server", async () => {
  expect(parse().isolate).toBe(false);
  expect(parse("--isolate").isolate).toBe(true);
  expect(() => parse("--isolate=1")).toThrow();
  const run = runtime(false);
  const app = await runServe(parseCommand("serve", ["--isolate", "--port", "0", "--max-tokens", "16"]), run.dependencies);
  expect(run.starts).toHaveLength(1);
  expect(run.starts[0]).toMatchObject({ isolate: true, port: 0, defaultGeneratedTokens: 16 });
  expect(run.logs.join("\n")).toContain("Serving example/model with continuous batching (capacity 8) in an isolated engine worker");
  await app.close();
  expect(run.closes()).toBe(1);
  const whisper = { repoId: "mlx-community/whisper-large-v3-turbo", path: "/whisper", modelType: "whisper" } as ModelRecord;
  await expect(runServe(parseCommand("serve", ["whisper", "--isolate"]), { ...run.dependencies, resolve: async () => ({ m: whisper, picked: false }) }))
    .rejects.toThrow("--isolate is not supported for the transcription-only server");
  expect(run.transcriptionStarts).toEqual([]);
  expect(run.starts).toHaveLength(1);
});

test("--model-pool is a parent-only integer >= 1 that applies with --isolate; without it the flag warns and is ignored, as main", async () => {
  expect(parse("--isolate")).not.toHaveProperty("modelPool");
  expect(parse("--isolate", "--model-pool", "2").modelPool).toBe(2);
  for (const value of ["0", "1.5", "x"]) expect(() => parse("--isolate", "--model-pool", value)).toThrow("--model-pool expects an integer in [1, 9007199254740991]");
  const warnings: string[] = [], warn = console.warn;
  console.warn = (message: string) => { warnings.push(message); };
  try { expect(parse("--model-pool", "2")).not.toHaveProperty("modelPool"); }
  finally { console.warn = warn; }
  expect(warnings).toEqual(["--model-pool has no effect without --isolate (child-per-model pool) — ignored"]);
  const run = runtime(false);
  const app = await runServe(parseCommand("serve", ["--isolate", "--model-pool", "3", "--port", "0"]), run.dependencies);
  expect(run.starts[0]).toMatchObject({ isolate: true, modelPool: 3 });
  expect(run.logs.join("\n")).toContain("Serving example/model with continuous batching (capacity 8) in an isolated engine worker (model pool 3)");
  await app.close();
});

test("the Whisper companion flags keep main's spelling, units, and validation", () => {
  expect(parse("--whisper-model", "mlx-community/whisper-large-v3-turbo", "--whisper-idle-unload", "30", "--whisper-resident", "--preload").whisper)
    .toEqual({ model: "mlx-community/whisper-large-v3-turbo", idleUnloadSec: 30, resident: true, preload: true });
  expect(parse("--whisper-idle-unload", "0").whisper).toEqual({ idleUnloadSec: 0 });
  expect(parse("--whisper-idle-unload", "1.5").whisper).toEqual({ idleUnloadSec: 1.5 });
  expect(parse()).not.toHaveProperty("whisper");
  for (const args of [["--whisper-idle-unload=-1"], ["--whisper-idle-unload", "abc"], ["--whisper-idle-unload", ""], ["--whisper-model", " "]])
    expect(() => parse(...args)).toThrow(args[0]!.split("=")[0]!);
  expect(() => parse("--whisper-idle-unload=-1")).toThrow('--whisper-idle-unload expects seconds >= 0 (got "-1")');
});

test("a Whisper checkpoint as the main model starts the transcription-only server without a browser", async () => {
  const run = runtime();
  const whisper = { repoId: "mlx-community/whisper-large-v3-turbo", path: "/whisper", modelType: "whisper" } as ModelRecord;
  const app = await runServe(parseCommand("serve", ["whisper", "--port", "0", "--whisper-idle-unload", "30", "--preload"]),
    { ...run.dependencies, resolve: async () => ({ m: whisper, picked: false }) });
  expect(run.starts).toEqual([]);
  expect(run.transcriptionStarts).toHaveLength(1);
  expect(run.transcriptionStarts[0]![0]).toBe(whisper);
  expect(run.transcriptionStarts[0]![1]).toMatchObject({ port: 0, whisper: { idleUnloadSec: 30, preload: true } });
  expect(run.opens).toEqual([]);
  expect(run.logs.join("\n")).toContain("transcription-only server");
  expect(run.logs.join("\n")).toContain("http://127.0.0.1:4321/v1/audio/transcriptions (idle unload 30s; loaded)");
  run.signals.emit("SIGTERM");
  await tick(); await app.close();
  expect(run.closes()).toBe(1); expect(run.exits).toEqual([0]);
  expect(run.signals.listenerCount("SIGTERM")).toBe(0);
});

test("--whisper-model resolves like the main model and refuses a non-Whisper checkpoint before loading", async () => {
  const run = runtime(false);
  const whisper = { repoId: "mlx-community/whisper-large-v3-turbo", path: "/whisper", modelType: "whisper" } as ModelRecord;
  const resolved: (string | null)[] = [];
  const resolve: ServeDependencies["resolve"] = async query => { resolved.push(query); return query === "large-v3-turbo" ? { m: whisper, picked: false } : { m: model, picked: true }; };
  const app = await runServe(parseCommand("serve", ["--whisper-model", "large-v3-turbo", "--whisper-resident"]), { ...run.dependencies, resolve });
  expect(resolved).toEqual([null, "large-v3-turbo"]);
  expect(run.starts[0]!.whisper).toEqual({ model: "large-v3-turbo", modelDir: "/whisper", modelId: "mlx-community/whisper-large-v3-turbo", resident: true });
  expect(run.transcriptionStarts).toEqual([]);
  await app.close();
  const chat = { repoId: "org/chat", path: "/chat", modelType: "qwen3" } as ModelRecord;
  await expect(runServe(parseCommand("serve", ["--whisper-model", "chat"]), { ...run.dependencies,
    resolve: async query => ({ m: query === "chat" ? chat : model, picked: false }) }))
    .rejects.toThrow("--whisper-model chat resolved to org/chat (model_type qwen3), not a Whisper checkpoint");
  expect(run.starts).toHaveLength(1);
  expect(run.signals.listenerCount("SIGINT")).toBe(0);
});

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

for (const [sessionDir, jobPaths, expectedStore] of [
  [undefined, { jobsDb: "/unused/store/jobs.sqlite" }, "store /unused/store/jobs.sqlite /unused/store/jobs"],
  ["/unused/custom-sessions", { jobsDb: "/unused/store/jobs.sqlite", jobsLogs: "/unused/custom-logs" }, "store /unused/store/jobs.sqlite /unused/custom-logs"],
  [undefined, { jobsLogs: "/unused/custom-logs" }, "store undefined /unused/custom-logs"],
] as const) test(`startup attaches caches, token history, and shared storage paths before listener ownership (${JSON.stringify(jobPaths)})`, async () => {
  // Isolate module mocks in a child so other engine tests always see real modules.
  const app = new URL("../", import.meta.url).pathname;
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    const app = ${JSON.stringify(app)};
    const events = [], remembered = [];
    const memoryPaths = { vault: "/unused/vault", skills: "/unused/skills" };
    const memorySurface = { readOnly: true, toolNames: [], customTools: [], skillPaths: [], hint: "memory" };
    const chatPaths = { toolApprovalsFile: "/unused/approvals.json", sessionDir: ${JSON.stringify(sessionDir) ?? "undefined"} };
    const { defaultSessionDir } = await import(app + "src/chat/session-files.ts");
    let sessionsDirectory;
    const context = { modelId: "test", model: { config: { text: { maxPositionEmbeddings: 65536 } } },
      memoryPlan: { contextTokens: 8192, maxGenerationTokens: 2048 }, tokenizer: {},
      template: { supportsThinking: false }, genDefaults: {}, dispose() { events.push("model close"); } };
    const cache = { promptCache: {}, resolvedKvScheme: { mode: "off" }, kvScheme: {}, stateCodecs: {},
      adapterNamespace() {}, checkpoints: { tokenPrefixes: () => [[1, 2]] }, continuationServices: {},
      stopIdleDemotion() { events.push("timer stop"); }, async close() { events.push("cache close"); return { durable: true }; } };
    const binding = { gateway: { configureContinuation(services) {
      assert.equal(services, cache.continuationServices); events.push("continuation");
    } } };
    let engine, listenerInput, memoryCallback;
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
        return engine = { gateway: { activeRows: 0, kvBytes: { projected: 0, budget: null } }, async close() { await options.beforeModelDispose(); context.dispose(); } };
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
    mock.module(app + "src/memory/surface.ts", () => ({ createMemorySurface: async (root, skills) => {
      assert.equal(root, memoryPaths.vault); assert.equal(skills, memoryPaths.skills); return memorySurface;
    } }));
    mock.module(app + "src/server/memory-routes.ts", () => ({ createMemoryRoutes(options) {
      assert.equal(options.root(), memoryPaths.vault); return { handle: async () => null };
    } }));
    mock.module(app + "src/server/session-routes.ts", () => ({ createSessionRoutes(directory) {
      sessionsDirectory = directory; assert.equal(directory, chatPaths.sessionDir ?? defaultSessionDir());
      return { handle: async () => null };
    } }));
    // Storage seams: the job store, credential file, and artifact root follow composition, not HOME.
    const storagePaths = { ...${JSON.stringify(jobPaths)}, credentialsFile: "/unused/hf.json", artifactRoot: "/unused/artifacts" };
    let storeFactory;
    mock.module(app + "src/jobs/db.ts", () => ({ JobStore: class { constructor(db, logs) { events.push("store " + db + " " + logs); } } }));
    mock.module(app + "src/jobs/host.ts", () => ({ createJobHost(options) { storeFactory = options.createStore;
      let closing; // idempotent like the real host: one close across beforeDrain and engine release
      return { signal: new AbortController().signal, ensureStore() { return storeFactory(); }, submit() {}, submitTask() {},
        close() { return closing ??= (async () => { events.push("jobs close"); })(); } }; } }));
    mock.module(app + "src/publishing/credentials.ts", () => ({ createHfCredentials(options) {
      assert.equal(options.tokenFile, storagePaths.credentialsFile); return { get: () => null, save() {} }; } }));
    mock.module(app + "src/server/adapter-artifact-routes.ts", () => ({ createAdapterArtifactRoutes(_gateway, options) {
      assert.equal(options.outputRoot, storagePaths.artifactRoot); return { handle: async () => null }; } }));
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => () => null }));
    mock.module(app + "src/chat/pi-backend.ts", () => ({ createPiBackend(options) {
      assert.equal(typeof options.memory, "function"); memoryCallback = options.memory;
      assert.equal(options.contextWindow, 8192); assert.equal(options.readOnly, true); assert.deepEqual(options.paths, { ...chatPaths, sessionDir: sessionsDirectory }); return () => {};
    } }));
    mock.module(app + "src/server/start.ts", () => ({ startServer: async input => {
      listenerInput = input; events.push("listener");
      return { server: { port: 1234 }, close: async () => { await input.beforeDrain(); await input.closeEngine(); } };
    } }));
    const { startModelServer } = await import(app + "src/cli/serve.ts");
    const running = await startModelServer({ path: "/unused", repoId: "test" }, {
      query: null, hostname: "127.0.0.1", port: 0, capacity: 8, contextLimit: null,
      readOnly: true, noOpen: true, chatPaths, memoryPaths, storagePaths, request: {}, cache: { kvQuant: "off", generationCheckpointTokens: 32 }
    });
    assert.equal(running.port, 1234);
    assert.equal(typeof running.downloads.start, "function");
    assert.equal(await memoryCallback(), memorySurface);
    assert.deepEqual(events, ["continuation", "engine", "routes", "listener"]);
    storeFactory();
    assert.equal(events.pop(), ${JSON.stringify(expectedStore)});
    await running.close();
    assert.deepEqual(events.slice(-4), ["timer stop", "jobs close", "cache close", "model close"]);
  `;
  const child = Bun.spawn([process.execPath, "--eval", script], { stdout: "pipe", stderr: "pipe",
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent" } });
  const [code, stderr] = await Promise.all([child.exited, new Response(child.stderr).text()]);
  expect(stderr).toBe(""); expect(code).toBe(0);
});

test("restored admission, wiring, media, sampling, and context flags keep main's units and validation", () => {
  expect(parse("--memory-budget", "12", "--context-length", "4096", "--force-wire", "--expert-offload", "--allow-private-media",
    "--hlg-sampling", "on", "--hlg-width", "3", "--hlg-toe", "7")).toMatchObject({
      memoryBudgetBytes: 12e9, contextTokens: 4096, forceWire: true, expertOffload: true, allowPrivateMedia: true,
      request: { hlg: { enabled: true, width: 3, shoulder: 4, toe: 7, pivotOffset: 6, pivot: "top" } } });
  expect(parse("--memory-budget", "0")).not.toHaveProperty("memoryBudgetBytes");
  expect(parse("--hlg-sampling", "off", "--hlg-width", "3").request).not.toHaveProperty("hlg");
  expect(parse()).toMatchObject({ forceWire: false, expertOffload: false, allowPrivateMedia: false });
  expect(parse()).not.toHaveProperty("contextTokens");
  for (const args of [["--memory-budget", "-1"], ["--memory-budget", "abc"], ["--context-length", "0"], ["--context-length", "1.5"],
    ["--hlg-sampling", "maybe"], ["--hlg-sampling", "on", "--hlg-width", "101"], ["--hlg-sampling", "on", "--hlg-toe", "-1"]])
    expect(() => parse(...args)).toThrow();
});

test("a memory budget enforces the admission estimate's safe context; otherwise runtime plans and profile caps apply as before", () => {
  const budget = { ...parse("--memory-budget", "8"), contextLimit: null };
  expect(resolveServingLimits(budget, null, { maxSafeContext: 6000 })).toEqual({ contextLimit: 6000, defaultGeneratedTokens: undefined });
  expect(resolveServingLimits({ ...budget, contextLimit: 4096 }, null, { maxSafeContext: 6000 }).contextLimit).toBe(4096);
  expect(resolveServingLimits({ ...budget, contextLimit: 9000 }, null, { maxSafeContext: 6000 }).contextLimit).toBe(6000);
  expect(resolveServingLimits(budget, { contextTokens: 8192, maxGenerationTokens: 2048 }, { maxSafeContext: 6000 }))
    .toEqual({ contextLimit: 6000, defaultGeneratedTokens: 2048 });
  expect(resolveServingLimits(parse(), null, { maxSafeContext: 6000 })).toEqual({ contextLimit: null, defaultGeneratedTokens: undefined });
});

test("MLX_BUN_SHUTDOWN_TIMEOUT_MS bounds serve's shutdown deadline; unusable values keep the default", async () => {
  const restore = configureRuntime({ MLX_BUN_SHUTDOWN_TIMEOUT_MS: "5" });
  try {
    const run = runtime(false);
    const exited = Promise.withResolvers<void>();
    await runServe(parseCommand("serve", []), { ...run.dependencies,
      start: async () => ({ port: 1, downloads: { start() {}, active: [] }, close: () => new Promise<void>(() => {}) }),
      exit(code) { run.exits.push(code); exited.resolve(); } });
    run.signals.emit("SIGTERM");
    await exited.promise;
    expect(run.exits).toEqual([1]);
    expect((run.errors[0] as Error).message).toContain("deadline");
  } finally { restore(); }
  for (const raw of ["abc", "0", "-5"]) {
    const restore = configureRuntime({ MLX_BUN_SHUTDOWN_TIMEOUT_MS: raw });
    try {
      const run = runtime(false);
      const app = await runServe(parseCommand("serve", []), run.dependencies);
      await app.close();
      expect(run.errors).toEqual([]);
    } finally { restore(); }
  }
});

test("startup wires the memory budget, runtime context, allocator limit, expert offload, and force-wire through composition", async () => {
  const app = new URL("../", import.meta.url).pathname;
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    import { fit } from "@mlx-bun/inference/execution/fit";
    import { runtimeValue } from "@mlx-bun/inference/runtime/config";
    const app = ${JSON.stringify(app)};
    const events = [];
    const config = { text: { numHiddenLayers: 2, numAttentionHeads: 8, numKeyValueHeads: 2, headDim: 64, globalHeadDim: 64,
      numGlobalKeyValueHeads: 2, attentionKEqV: false, layerTypes: ["full_attention", "sliding_attention"], slidingWindow: 1024,
      maxPositionEmbeddings: 32768, enableMoeBlock: false } };
    let mountFails = false;
    const context = { modelId: "test", model: { config, weightsBytes: 2e9 }, memoryPlan: null, tokenizer: {},
      template: { supportsThinking: false }, genDefaults: {}, dispose() { events.push("model close"); },
      adapters: { async mount(id, dir) { events.push("mount " + id + " " + dir); if (mountFails) throw new Error("adapter_config.json missing"); return { id, mountedLayers: 3 }; } } };
    const cache = { promptCache: {}, resolvedKvScheme: { mode: "off", fitOptions: undefined }, kvScheme: {}, stateCodecs: {},
      adapterNamespace() {}, checkpoints: null, continuationServices: {},
      stopIdleDemotion() {}, async close() { return { durable: true }; } };
    const expected = fit(config, 2e9, 1, undefined, undefined, 0, 8e9, undefined).maxSafeContext;
    let loadOptions, cacheOptions, statusBudget, contextLimit, defaultAdapter;
    const routes = [];
    const route = seam => routes.push(seam + ":" + runtimeValue("MLX_BUN_NO_FUSED_SDPA"));
    mock.module(app + "src/engine/index.ts", () => ({
      loadContext: async (path, id, options) => { loadOptions = options; route("load"); events.push("load wire=" + runtimeValue("MLX_BUN_FORCE_WIRE") + " media=" + runtimeValue("MLX_BUN_ALLOW_PRIVATE_MEDIA")); return context; },
      modelServingBinding: async () => { route("binding"); return { gateway: { configureContinuation() {} } }; },
      createCacheServices: async (_context, _binding, options) => { cacheOptions = options; route("cache"); return cache; },
      createAppEngine: async () => { route("engine"); return { gateway: { activeRows: 0, kvBytes: { projected: 0, budget: null } }, async close() { route("close"); context.dispose(); } }; },
    }));
    let limit = 77;
    mock.module("@mlx-bun/mlx/ffi", () => ({ setMemoryLimit(bytes) { events.push("allocator " + bytes); const previous = limit; limit = bytes; return previous; } }));
    mock.module("@mlx-bun/inference/artifacts", () => ({
      async ensureOffloadFile(path) { events.push("offload " + path); return "/offload"; },
      activateExpertOffload(dir) { events.push("activate " + dir); return () => events.push("restore offload"); },
    }));
    mock.module(app + "src/server/generated-token-history.ts", () => ({ GeneratedTokenHistory: class { remember() {} } }));
    mock.module(app + "src/server/routes.ts", () => ({ createCompletionRoutes(_engine, options) {
      contextLimit = options.contextLimit; defaultAdapter = options.defaultAdapter;
      assert.deepEqual(options.pagedKv, { blockSize: 128 });
      return { handle: async () => null, invalidateLibrary() {} };
    } }));
    mock.module(app + "src/server/status-routes.ts", () => ({ createStatusRoutes(input) { statusBudget = input.memoryBudgetBytes; return { handle: async () => null }; } }));
    mock.module(app + "src/server/management-routes.ts", () => ({ createManagementRoutes: () => ({ handle: async () => null }) }));
    mock.module(app + "src/memory/surface.ts", () => ({ createMemorySurface: async () => ({}) }));
    mock.module(app + "src/server/memory-routes.ts", () => ({ createMemoryRoutes: () => ({ handle: async () => null }) }));
    mock.module(app + "src/server/session-routes.ts", () => ({ createSessionRoutes: () => ({ handle: async () => null }) }));
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => () => null }));
    mock.module(app + "src/chat/pi-backend.ts", () => ({ createPiBackend: () => () => {} }));
    // Like the real listener, close is idempotent: one drain and one engine release.
    mock.module(app + "src/server/start.ts", () => ({ startServer: async input => { let closing;
      return { server: { port: 1234 }, close: () => closing ??= (async () => { await input.beforeDrain(); await input.closeEngine(); })() }; } }));
    const { startModelServer, parseServeOptions } = await import(app + "src/cli/serve.ts");
    const { parseCommand } = await import(app + "src/cli/args.ts");
    const options = parseServeOptions(parseCommand("serve", ["--memory-budget", "8", "--context-length", "4096", "--batch", "2",
      "--force-wire", "--allow-private-media", "--expert-offload", "--adapter", "/unused/adapters/my-lora/",
      "--draft-kind", "ngram", "--num-draft-tokens", "4", "--ngram-max", "5", "--ngram-min", "2", "--mtp", "off",
      "--paged-kv", "--paged-kv-block-size", "128", "--l2", "--kv-quant", "off", "--fused-sdpa", "on", "--no-open"]));
    options.chatPaths = { cwd: "/unused", sessionDir: "/unused/sessions" }; options.memoryPaths = { vault: "/unused/vault", skills: "/unused/skills" };
    const running = await startModelServer({ path: "/unused", repoId: "test", expertsBytes: 5 }, options);
    // The adapter mounts right after the model loads, before the allocator, caches, or engine exist.
    assert.deepEqual(events, ["offload /unused", "activate /offload", "load wire=1 media=1", "mount my-lora /unused/adapters/my-lora", "allocator 8000000000"]);
    assert.equal(defaultAdapter, "my-lora");
    assert.deepEqual(loadOptions, { memoryBudgetBytes: 8e9, runtime: { batchSize: 2, maxGenerationTokens: 128, memoryBudgetBytes: 8e9, contextTokens: 4096, nativeDraft: false },
      draftKind: "ngram", numDraftTokens: 4, ngramMax: 5, ngramMin: 2 });
    assert.equal(cacheOptions.allocatorLimitBytes, 8e9);
    assert.equal(statusBudget, 8e9);
    assert.equal(contextLimit, expected);
    await running.close();
    assert.deepEqual(routes, ["load:0", "binding:0", "cache:0", "engine:0", "close:0"]);
    assert.equal(runtimeValue("MLX_BUN_NO_FUSED_SDPA"), undefined);
    // Process settings restore only after the engine released the model.
    assert.deepEqual(events.slice(5), ["model close", "restore offload", "allocator 77"]);
    assert.equal(limit, 77);
    assert.equal(runtimeValue("MLX_BUN_FORCE_WIRE"), undefined);
    assert.equal(runtimeValue("MLX_BUN_ALLOW_PRIVATE_MEDIA"), undefined);
    // A bad adapter fails startup with main's message and releases the model before anything else was created.
    events.length = 0; mountFails = true; routes.length = 0; options.fusedSdpa = false; options.cache.kvQuant = "config";
    await assert.rejects(startModelServer({ path: "/unused", repoId: "test", expertsBytes: 0 }, options), /adapter mount failed: adapter_config.json missing/);
    assert.deepEqual(events, ["load wire=1 media=1", "mount my-lora /unused/adapters/my-lora", "model close"]);
    assert.deepEqual(routes, ["load:1"]);
    assert.equal(runtimeValue("MLX_BUN_NO_FUSED_SDPA"), undefined);
    mountFails = false; options.cache.kvQuant = "off";
    events.length = 0;
    const dense = await startModelServer({ path: "/dense", repoId: "dense", expertsBytes: 0 }, options);
    assert.deepEqual(events, ["load wire=1 media=1", "mount my-lora /unused/adapters/my-lora", "allocator 8000000000"]);
    await dense.close();
    assert.deepEqual(events.slice(3), ["model close", "allocator 77"]);
    // A closed app's repeated close never resets a later app's process settings.
    events.length = 0;
    const later = await startModelServer({ path: "/later", repoId: "later", expertsBytes: 5 }, options);
    await dense.close(); await running.close();
    assert.deepEqual(events, ["offload /later", "activate /offload", "load wire=1 media=1", "mount my-lora /unused/adapters/my-lora", "allocator 8000000000"]);
    assert.equal(limit, 8e9);
    await later.close();
    assert.deepEqual(events.slice(5), ["model close", "restore offload", "allocator 77"]);
    // Startup failure after activation and the allocator limit restores both.
    events.length = 0;
    mock.module(app + "src/server/start.ts", () => ({ startServer: async input => { await input.closeEngine(); throw new Error("bind failed"); } }));
    await assert.rejects(startModelServer({ path: "/unused", repoId: "test", expertsBytes: 5 }, options), /bind failed/);
    assert.deepEqual(events, ["offload /unused", "activate /offload", "load wire=1 media=1", "mount my-lora /unused/adapters/my-lora", "allocator 8000000000", "model close", "restore offload", "allocator 77"]);
    assert.equal(limit, 77);
    assert.equal(runtimeValue("MLX_BUN_FORCE_WIRE"), undefined);
  `;
  // Bare workspace specifiers in the script resolve from the app directory, whatever the runner's cwd.
  const child = Bun.spawn([process.execPath, "--eval", script], { stdout: "pipe", stderr: "pipe", cwd: app,
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent" } });
  const [code, stderr] = await Promise.all([child.exited, new Response(child.stderr).text()]);
  expect(stderr.replace(/^--expert-offload ignored.*$/gm, "").trim()).toBe(""); expect(code).toBe(0);
});

test("a recommended background download is handed to the app's owner after startup; a refused start is reported", async () => {
  const run = runtime(false);
  const app = await runServe(parseCommand("serve", []), { ...run.dependencies,
    resolve: async () => ({ m: model, picked: true, recommended: "mlx-community/recommended" }) });
  expect(run.downloads).toEqual(["mlx-community/recommended"]);
  expect(run.errors).toEqual([]);
  await app.close();
  const refused = runtime(false), failure = new Error("a download for x is already in progress");
  const running = await runServe(parseCommand("serve", []), { ...refused.dependencies,
    resolve: async () => ({ m: model, picked: true, recommended: "x" }),
    start: async () => ({ port: 1, downloads: { start: () => { throw failure; }, active: [] }, close: async () => {} }) });
  expect(refused.errors).toEqual([failure]);
  await running.close();
});

test("a signal during model selection cancels it with the startup reason and leaves no handlers or browser", async () => {
  const run = runtime();
  await expect(runServe(parseCommand("serve", []), { ...run.dependencies, resolve: async (_query, _supplied, signal) => {
    run.signals.emit("SIGINT");
    expect(signal?.aborted).toBe(true);
    throw signal!.reason;
  } })).rejects.toThrow("startup cancelled by signal");
  expect(run.signals.listenerCount("SIGINT")).toBe(0); expect(run.signals.listenerCount("SIGTERM")).toBe(0);
  expect(run.opens).toEqual([]); expect(run.starts).toEqual([]);
});

test("a signal during model load closes the app once it exists, opens no browser, and leaves no handlers", async () => {
  const run = runtime();
  const app = await runServe(parseCommand("serve", []), { ...run.dependencies,
    start: async (m, options) => { run.signals.emit("SIGTERM"); return run.dependencies.start(m, options); } });
  expect(run.closes()).toBe(1); expect(run.opens).toEqual([]); expect(run.downloads).toEqual([]);
  expect(run.signals.listenerCount("SIGINT")).toBe(0); expect(run.signals.listenerCount("SIGTERM")).toBe(0);
  await app.close(); expect(run.closes()).toBe(1);
});

test("a signal that lands during selection but leaves it resolved still stops before the model loads", async () => {
  const run = runtime();
  await expect(runServe(parseCommand("serve", []), { ...run.dependencies,
    resolve: async () => { run.signals.emit("SIGINT"); return { m: model, picked: true }; } })).rejects.toThrow("startup cancelled by signal");
  expect(run.starts).toEqual([]); expect(run.opens).toEqual([]);
  expect(run.signals.listenerCount("SIGINT")).toBe(0); expect(run.signals.listenerCount("SIGTERM")).toBe(0);
});

test("a startup adapter directory is accepted under both spellings and validated before model selection", () => {
  expect(parse("--adapter", "/adapters/my-lora").adapterDir).toBe("/adapters/my-lora");
  expect(parse("--adapter-path", "/adapters/other").adapterDir).toBe("/adapters/other");
  expect(parse("--adapter", "/a", "--adapter-path", "/b").adapterDir).toBe("/a");
  expect(parse()).not.toHaveProperty("adapterDir");
  expect(() => parse("--adapter", " ")).toThrow("--adapter expects a directory");
});

test("speculative flags keep main's validation and messages, and only reach the load gate when a draft is configured", () => {
  expect(parse("--draft-model", "tiny", "--draft-kind", "ngram", "--num-draft-tokens", "4", "--ngram-max", "5", "--ngram-min", "2", "--mtp", "off"))
    .toMatchObject({ draft: { model: "tiny", kind: "ngram", numTokens: 4, ngramMax: 5, ngramMin: 2 }, mtp: false });
  expect(parse("--mtp", "on").mtp).toBe(true);
  expect(parse()).not.toHaveProperty("draft"); expect(parse()).not.toHaveProperty("mtp");
  expect(parse("--draft-kind", "mtp").draft).toEqual({ kind: "mtp" });
  for (const [args, message] of [
    [["--num-draft-tokens", "0"], '--num-draft-tokens expects an integer >= 1 (got "0")'],
    [["--num-draft-tokens", "1.5"], '--num-draft-tokens expects an integer >= 1 (got "1.5")'],
    [["--draft-kind", "lookahead"], "--draft-kind expects two-model|assistant|dspark|deepspec|mtp|ngram (got \"lookahead\")"],
    [["--draft-kind", "ngram", "--ngram-max", "x"], '--ngram-max expects an integer >= 1 (got "x")'],
    [["--draft-kind", "ngram", "--ngram-min", "6", "--ngram-max", "5"], "--ngram-min (6) must be <= --ngram-max (5)"],
    [["--mtp", "maybe"], '--mtp expects on|off (got "maybe")'],
    [["--draft-model", " "], "--draft-model expects a path or query"],
  ] as const) expect(() => parse(...args)).toThrow(message);
  const warnings: string[] = [], warn = console.warn;
  console.warn = (message: string) => { warnings.push(message); };
  try { expect(parse("--ngram-max", "3").draft).toEqual({ ngramMax: 3 }); }
  finally { console.warn = warn; }
  expect(warnings).toEqual(["--ngram-max/--ngram-min only apply with --draft-kind ngram — ignored"]);
});

test("a draft model query resolves through model selection before startup and reaches composition as a directory", async () => {
  const run = runtime(false);
  const queries: (string | null)[] = [];
  const app = await runServe(parseCommand("serve", ["--draft-model", "draft-query", "--num-draft-tokens", "2"]), { ...run.dependencies,
    resolve: async (query, _supplied, signal) => { queries.push(query); expect(signal?.aborted).toBe(false);
      return { m: query === "draft-query" ? { ...model, path: "/models/draft" } : model, picked: false }; } });
  expect(queries).toEqual([null, "draft-query"]);
  expect(run.starts[0]?.draft).toEqual({ model: "draft-query", numTokens: 2, modelDir: "/models/draft" });
  await app.close();
});

test("paged KV follows main's flag and env mirror, with the block size only alongside paging", () => {
  expect(parse("--paged-kv").request.pagedKv).toEqual({});
  expect(parse("--paged-kv", "--paged-kv-block-size", "512").request.pagedKv).toEqual({ blockSize: 512 });
  expect(parse().request).not.toHaveProperty("pagedKv");
  expect(() => parse("--paged-kv-block-size", "512")).toThrow("--paged-kv-block-size requires --paged-kv");
  expect(() => parse("--paged-kv", "--paged-kv-block-size", "0")).toThrow();
  const restore = configureRuntime({ MLX_BUN_PAGED_KV: "1" });
  try { expect(parse().request.pagedKv).toEqual({}); expect(parse("--paged-kv-block-size", "128").request.pagedKv).toEqual({ blockSize: 128 }); }
  finally { restore(); }
});

test("paged startup validates the resolved KV codec and loaded draft, preserving explicit overrides", () => {
  const config = [{ layerIdx: 0, bits: 4, groupSize: 64 }];
  const validate = (input: Parameters<typeof resolveKvScheme>[0], hasDraft = false, paged = true) =>
    validatePagedServingOptions(paged ? {} : undefined, resolveKvScheme(input).generationOptions, hasDraft);
  for (const override of ["off", 4, 8] as const)
    expect(() => validate({ override, config })).not.toThrow();
  // Config mode without a sidecar resolves to bf16, just as on main.
  expect(() => validate({ override: "config", config: null })).not.toThrow();
  expect(() => validate({ override: "config", config: [] })).not.toThrow();
  expect(() => validate({ override: "config", config })).toThrow("per-layer and TurboQuant pages are not implemented");
  expect(() => validate({ turboQuant: { kBits: 4, vBits: 3 } })).toThrow("per-layer and TurboQuant pages are not implemented");
  expect(() => validate({ override: "off" }, true)).toThrow("cannot combine with --draft-model");
  expect(() => validate({ override: "config", config }, true, false)).not.toThrow();
  expect(() => validate({ turboQuant: { kBits: 4, vBits: 3 } }, true, false)).not.toThrow();
});

test("incompatible paged startup closes caches and the loaded model before engine or listener ownership", async () => {
  // Keep native-free startup mocks private to this process.
  const app = new URL("../", import.meta.url).pathname;
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    import { resolveKvScheme } from "@mlx-bun/inference/state/kv-scheme";
    import { runtimeValue } from "@mlx-bun/inference/runtime/config";
    const app = ${JSON.stringify(app)}, events = [];
    const context = { modelId: "test", model: { config: { modelType: "gemma4" } },
      template: {}, draft: null, dispose() { events.push("model close"); } };
    let scheme;
    mock.module(app + "src/engine/index.ts", () => ({
      loadContext: async () => context,
      modelServingBinding: async () => ({ gateway: { configureContinuation() { events.push("continuation"); } } }),
      createCacheServices: async () => ({ resolvedKvScheme: scheme, kvScheme: scheme.generationOptions,
        async close() { events.push("cache close"); return { durable: true }; } }),
      createAppEngine: async () => { events.push("engine"); throw new Error("must not construct engine"); },
    }));
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => () => null }));
    mock.module(app + "src/chat/pi-backend.ts", () => ({ createPiBackend() { throw new Error("must not construct chat"); } }));
    mock.module(app + "src/server/start.ts", () => ({ startServer() { events.push("listener"); throw new Error("must not bind"); } }));
    const { parseServeOptions, startModelServer } = await import(app + "src/cli/serve.ts");
    const options = parseServeOptions({ values: { "paged-kv": true, "force-wire": true }, positionals: [] });
    const beforeWire = runtimeValue("MLX_BUN_FORCE_WIRE");
    for (const [input, draft, message] of [
      [{ override: "config", config: [{ layerIdx: 0, bits: 4, groupSize: 64 }] }, null, /per-layer and TurboQuant/],
      [{ turboQuant: { kBits: 4, vBits: 3 } }, null, /per-layer and TurboQuant/],
      [{ override: "off" }, { provider: {}, numDraftTokens: 3 }, /cannot combine with --draft-model/],
    ]) {
      scheme = resolveKvScheme(input); context.draft = draft; events.length = 0;
      await assert.rejects(startModelServer({ path: "/unused", repoId: "test" }, options), message);
      assert.deepEqual(events, ["cache close", "model close"]);
      assert.equal(runtimeValue("MLX_BUN_FORCE_WIRE"), beforeWire);
    }
  `;
  const child = Bun.spawn([process.execPath, "--eval", script], { stdout: "pipe", stderr: "pipe", cwd: app,
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent" } });
  const [code, stdout, stderr] = await Promise.all([child.exited, new Response(child.stdout).text(), new Response(child.stderr).text()]);
  expect({ code, stdout, stderr }).toEqual({ code: 0, stdout: "", stderr: "" });
});

test("startup composes the lazy Whisper companion with the parsed policy, shares it with discovery, audio routes, and web chat, and closes it before the model", async () => {
  const app = new URL("../", import.meta.url).pathname;
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    const app = ${JSON.stringify(app)}, lib = app + "../../packages/app-services/src/";
    const events = [], loads = [];
    let found = null, discovery, piProbe, listenerInput, drain;
    const context = { modelId: "test", model: { config: { text: { maxPositionEmbeddings: 4096 } }, weightsBytes: 1e9 }, memoryPlan: null, tokenizer: {},
      template: { supportsThinking: false }, genDefaults: {}, dispose() { events.push("model close"); } };
    const cache = { promptCache: {}, resolvedKvScheme: { mode: "off", fitOptions: undefined }, kvScheme: {}, stateCodecs: {},
      adapterNamespace() {}, checkpoints: null, continuationServices: {}, stopIdleDemotion() {}, async close() { return { durable: true }; } };
    const gateway = { activeRows: 0, kvBytes: { projected: 0, budget: null }, async runExclusive(fn, _trace, signal) { events.push("lock"); signal?.throwIfAborted(); return fn(); } };
    // The Whisper checkpoint and the local catalog are the only seams behind the model host; everything else is the real composition.
    mock.module(lib + "whisper-backend.ts", () => ({ nativeWhisperBackend: { async load(dir) { events.push("load " + dir); return { promptTokenBudget: 3, encode: () => [],
      async transcribe(samples, options) { events.push("decode " + samples.length + " " + options.language); return { text: " hi", segments: [], language: options.language ?? "en" }; },
      start() { throw new Error("no sessions here"); }, dispose() { events.push("whisper close " + dir); } }; } } }));
    mock.module(lib + "catalog.ts", () => ({ declaredOperations: () => [], createRegistryCatalog: () => ({ list: async () => { events.push("registry lookup"); return found ? [found] : []; },
      find: async query => { throw new Error("unused " + query); }, resolve: async () => undefined, estimate: async () => undefined, register: async () => {}, download: async () => {} }) }));
    mock.module("@mlx-bun/inference/input/audio", () => ({ isRiffWave: () => true, decodeWav: () => ({ samples: new Float32Array(16000), sampleRate: 16000 }), resampleTo16k: samples => samples }));
    mock.module(app + "src/engine/index.ts", () => ({
      loadContext: async () => context, modelServingBinding: async () => ({ gateway: { configureContinuation() {} } }),
      createCacheServices: async () => cache,
      createAppEngine: async () => ({ gateway, async close() { events.push("engine close"); context.dispose(); } }),
    }));
    mock.module(app + "src/server/routes.ts", () => ({ createCompletionRoutes(_engine, options) {
      discovery = options.transcription; return { handle: async () => null, invalidateLibrary() {} };
    } }));
    mock.module(app + "src/chat/pi-backend.ts", () => ({ createPiBackend(options) { piProbe = options.transcription; return () => {}; } }));
    mock.module(app + "src/server/generated-token-history.ts", () => ({ GeneratedTokenHistory: class { remember() {} } }));
    mock.module(app + "src/server/status-routes.ts", () => ({ createStatusRoutes: () => ({ handle: async () => null }) }));
    mock.module(app + "src/server/management-routes.ts", () => ({ createManagementRoutes: () => ({ handle: async () => null }) }));
    mock.module(app + "src/memory/surface.ts", () => ({ createMemorySurface: async () => ({}) }));
    mock.module(app + "src/server/memory-routes.ts", () => ({ createMemoryRoutes: () => ({ handle: async () => null }) }));
    mock.module(app + "src/server/session-routes.ts", () => ({ createSessionRoutes: () => ({ handle: async () => null }) }));
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => () => null }));
    mock.module(app + "src/server/start.ts", () => ({ startServer: async input => { let closing; listenerInput = input;
      return { server: { port: 1234 }, close: () => closing ??= (async () => { await input.beforeDrain(); await drain?.(); await input.closeEngine(); })() }; } }));
    const { startModelServer, parseServeOptions } = await import(app + "src/cli/serve.ts");
    const { parseCommand } = await import(app + "src/cli/args.ts");
    const take = async () => {
      const form = new FormData(); form.set("file", new Blob([new Uint8Array(64)], { type: "audio/wav" }), "clip.wav"); form.set("language", "en");
      return await listenerInput.routes.handle(new Request("http://127.0.0.1/v1/audio/transcriptions", { method: "POST", body: form }));
    };
    const unload = async () => await (await listenerInput.routes.handle(new Request("http://127.0.0.1/admin/transcription/unload", { method: "POST" }))).json();
    const options = parseServeOptions(parseCommand("serve", ["--whisper-model", "large-v3-turbo", "--whisper-idle-unload", "30", "--whisper-resident", "--no-open"]));
    // runServe resolves the query into the directory before composition.
    options.whisper = { ...options.whisper, modelDir: "/unused/whisper", modelId: "mlx-community/whisper-large-v3-turbo" };
    options.chatPaths = { cwd: "/unused", sessionDir: "/unused/sessions" }; options.memoryPaths = { vault: "/unused/vault", skills: "/unused/skills" };
    const running = await startModelServer({ path: "/unused", repoId: "test", expertsBytes: 0 }, options);
    // Lazy: nothing loads until a take asks; the discovery and chat probes share the one companion without loading it.
    assert.deepEqual(events, []);
    assert.deepEqual(await discovery(), { id: "mlx-community/whisper-large-v3-turbo", resident: false });
    assert.equal(await piProbe(), true);
    assert.ok(!events.includes("registry lookup"), "an explicit checkpoint never scans the registry");
    // Takes run under the gateway's exclusive lock, on the explicit checkpoint, and the parsed policy applies: resident stays loaded.
    const first = await take();
    assert.equal(first.status, 200);
    assert.equal((await first.json()).mlx_bun.model, "mlx-community/whisper-large-v3-turbo");
    assert.deepEqual(events, ["load /unused/whisper", "lock", "decode 16000 en"]);
    assert.deepEqual(await discovery(), { id: "mlx-community/whisper-large-v3-turbo", resident: true });
    assert.equal(await piProbe(), true);
    assert.deepEqual({ ...await unload(), last_load_ms: 0 }, { unloaded: true, resident: false, loads: 1, unloads: 1, requests: 1, last_load_ms: 0, idle_unload_sec: null });
    events.length = 0;
    await running.close();
    assert.deepEqual(events, ["engine close", "model close"]);
    // The idle policy without --whisper-resident: the weights stay for that long and the route reports it.
    events.length = 0;
    const idle = parseServeOptions(parseCommand("serve", ["--whisper-idle-unload", "30", "--no-open"]));
    idle.whisper = { ...idle.whisper, modelDir: "/unused/whisper", modelId: "org/whisper" };
    idle.chatPaths = options.chatPaths; idle.memoryPaths = options.memoryPaths;
    const timed = await startModelServer({ path: "/unused", repoId: "test", expertsBytes: 0 }, idle);
    await take();
    assert.equal((await unload()).idle_unload_sec, 30);
    events.length = 0;
    await timed.close();
    assert.deepEqual(events, ["engine close", "model close"]);
    // A resident companion is released by the close, before the engine and the model.
    events.length = 0;
    const kept = await startModelServer({ path: "/unused", repoId: "test", expertsBytes: 0 }, options);
    await take();
    events.length = 0;
    await kept.close();
    assert.deepEqual(events, ["whisper close /unused/whisper", "engine close", "model close"]);
    // Without a flag the first downloaded Whisper checkpoint is looked up once; none on disk means no companion.
    events.length = 0;
    delete options.whisper;
    const bare = await startModelServer({ path: "/unused", repoId: "test", expertsBytes: 0 }, options);
    assert.equal(await discovery(), null); assert.equal(await piProbe(), false);
    const unavailable = await take();
    assert.equal(unavailable.status, 503); assert.equal((await unavailable.json()).error.type, "model_unavailable");
    assert.deepEqual(events, ["registry lookup"]);
    await bare.close();
    assert.deepEqual(events, ["registry lookup", "engine close", "model close"]);
    events.length = 0; found = { id: "mlx-community/whisper-tiny", kind: "model", directory: "/cache/whisper", bytes: 1, operations: ["transcribe"] };
    const foundApp = await startModelServer({ path: "/unused", repoId: "test", expertsBytes: 0 }, options);
    assert.deepEqual(await discovery(), { id: "mlx-community/whisper-tiny", resident: false });
    assert.equal((await take()).status, 200);
    // The default policy releases the weights right after the take.
    assert.deepEqual(events, ["registry lookup", "load /cache/whisper", "lock", "decode 16000 en", "whisper close /cache/whisper"]);
    events.length = 0;
    await foundApp.close();
    assert.deepEqual(events, ["engine close", "model close"]);
    // An admitted route reaches the stopped module during drain: it answers 503 and never loads the weights.
    events.length = 0;
    const late = await startModelServer({ path: "/unused", repoId: "test", expertsBytes: 0 }, options);
    let lateStatus;
    drain = async () => { lateStatus = (await take()).status; };
    await late.close();
    assert.equal(lateStatus, 503);
    assert.deepEqual(events, ["registry lookup", "engine close", "model close"]);
    drain = undefined;
  `;
  const child = Bun.spawn([process.execPath, "--eval", script], { stdout: "pipe", stderr: "pipe",
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent" } });
  const [code, stderr] = await Promise.all([child.exited, new Response(child.stderr).text()]);
  expect(stderr).toBe(""); expect(code).toBe(0);
});

test("the transcription-only server preloads on request, serves audio and discovery over a real listener, and releases the weights on close", async () => {
  const app = new URL("../", import.meta.url).pathname;
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    const app = ${JSON.stringify(app)}, lib = app + "../../packages/app-services/src/";
    const events = [];
    let failLoad = false;
    mock.module(lib + "whisper-backend.ts", () => ({ nativeWhisperBackend: { async load(dir) { events.push("load " + dir); if (failLoad) throw new Error("no tokenizer");
      return { promptTokenBudget: 3, encode: () => [], transcribe: async () => ({ text: "", segments: [], language: "en" }),
        start() { throw new Error("unused"); }, dispose() { events.push("close " + dir); } }; } } }));
    const { startTranscriptionServer, parseServeOptions } = await import(app + "src/cli/serve.ts");
    const { parseCommand } = await import(app + "src/cli/args.ts");
    const options = parseServeOptions(parseCommand("serve", ["--port", "0", "--preload", "--whisper-idle-unload", "5"]));
    const running = await startTranscriptionServer({ path: "/unused/whisper", repoId: "org/whisper" }, options);
    try {
      assert.deepEqual(events, ["load /unused/whisper"]);
      const base = "http://127.0.0.1:" + running.port;
      const models = await (await fetch(base + "/v1/models")).json();
      assert.deepEqual(models.data.map(m => [m.id, m.transcription, m.resident]), [["org/whisper", true, true]]);
      assert.equal((await (await fetch(base + "/health")).json()).transcription.sessions, 0);
      const index = await (await fetch(base + "/v1")).json();
      assert.equal(index.mode, "transcription");
      assert.deepEqual(index.endpoints, ["POST /v1/audio/transcriptions", "POST /v1/audio/translations", "POST /admin/transcription/unload", "POST /v1/audio/sessions",
        "POST /v1/audio/sessions/:id/audio", "POST /v1/audio/sessions/:id/finish", "DELETE /v1/audio/sessions/:id", "GET /v1/models", "GET /health", "GET /stats"]);
      const unloaded = await (await fetch(base + "/admin/transcription/unload", { method: "POST" })).json();
      assert.deepEqual({ ...unloaded, last_load_ms: 0 }, { unloaded: true, resident: false, loads: 1, unloads: 1, requests: 0, last_load_ms: 0, idle_unload_sec: 5 });
      // No chat model, no web app, no chat completions: 404s, never a placeholder.
      for (const path of ["/", "/v1/chat/completions", "/api/hub/local"]) assert.equal((await fetch(base + path, { method: path === "/" ? "GET" : "POST" })).status, 404);
      assert.equal((await fetch(base + "/ws/chat")).status, 426);
      assert.throws(() => running.downloads.start("org/x"), /owns no downloads/);
    } finally { await running.close(); }
    assert.deepEqual(events, ["load /unused/whisper", "close /unused/whisper"]);
    await running.close();
    assert.deepEqual(events, ["load /unused/whisper", "close /unused/whisper"]);
    // A failed preload rejects with the library's message before any listener exists, and holds no weights.
    events.length = 0; failLoad = true;
    await assert.rejects(startTranscriptionServer({ path: "/unused/whisper", repoId: "org/whisper" }, options), /no tokenizer/);
    assert.deepEqual(events, ["load /unused/whisper"]);
  `;
  const child = Bun.spawn([process.execPath, "--eval", script], { stdout: "pipe", stderr: "pipe",
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent" } });
  const [code, stderr] = await Promise.all([child.exited, new Response(child.stderr).text()]);
  expect(stderr).toBe(""); expect(code).toBe(0);
});
