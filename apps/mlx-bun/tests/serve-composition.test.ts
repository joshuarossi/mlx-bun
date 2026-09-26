import { expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { dirname, relative, resolve } from "node:path";

// The serve composition splits into a persistent, CPU-only state and a
// model-scoped host (src/cli/serve-state.ts, src/cli/serve-host.ts). These
// examples prove the halves' contract; tests/serve-cli.test.ts remains the
// oracle for the composed CLI behavior.
const app = new URL("../", import.meta.url).pathname;

async function runChild(script: string, env: Record<string, string> = {}) {
  const child = Bun.spawn([process.execPath, "--eval", script], { stdout: "pipe", stderr: "pipe", cwd: app,
    env: { ...process.env, MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1", ...env } });
  const [code, stdout, stderr] = await Promise.all([child.exited, new Response(child.stdout).text(), new Response(child.stderr).text()]);
  return { code, stdout, stderr };
}

test("the persistent state never reaches the native library through a runtime import", () => {
  // Static gate over the runtime import closure (type-only imports elided),
  // following workspace package exports; the child-script examples below are
  // the runtime proof. The only engine modules reached are contract files.
  const workspace = resolve(app, "../..");
  const transpiler = new Bun.Transpiler({ loader: "ts" });
  const seen = new Set<string>(), native: string[] = [];
  const visit = (file: string) => {
    if (seen.has(file)) return;
    seen.add(file);
    for (const { path } of transpiler.scanImports(readFileSync(file, "utf8"))) {
      if (path.startsWith("node:") || path === "bun" || path.startsWith("bun:")) continue;
      if (!path.startsWith(".") && !path.startsWith("@mlx-bun/")) continue;
      const target = Bun.resolveSync(path, dirname(file));
      if (target.startsWith(resolve(workspace, "packages/mlx/src") + "/")) native.push(`${relative(workspace, file)} -> ${path}`);
      else visit(target);
    }
  };
  visit(resolve(app, "src/cli/serve-state.ts"));
  expect(native).toEqual([]);
  const engine = [...seen].filter(file => file.startsWith(resolve(app, "src/engine") + "/")).map(file => relative(app, file)).sort();
  expect(engine).toEqual(["src/engine/completion.ts"]);
  expect(seen.size).toBeGreaterThan(20);
});

test("the persistent state composes and serves its routes with fakes, without the engine or native library", async () => {
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    import { existsSync } from "node:fs";
    import { join } from "node:path";
    const app = ${JSON.stringify(app)};
    const root = process.env.HOME;
    // Tripwires: composing the state must not import the engine or the native binding.
    mock.module(app + "src/engine/index.ts", () => { throw new Error("engine imported"); });
    mock.module(app + "src/engine/model-host.ts", () => { throw new Error("model host imported"); });
    mock.module("@mlx-bun/mlx/ffi", () => { throw new Error("native library loaded"); });
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => request =>
      new URL(request.url).pathname === "/" ? new Response("web") : null }));
    let serverPort;
    mock.module(app + "src/server/dataset-routes.ts", () => ({ createDatasetRoutes(deps) { serverPort = deps.serverPort; return { handle: async () => null }; } }));
    const { createAppState } = await import(app + "src/cli/serve-state.ts");
    const memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
    const chatPaths = { sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
    const storagePaths = { jobsDb: join(root, "store", "jobs.sqlite"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
    const state = await createAppState({ port: 0, memoryPaths, chatPaths }, storagePaths);
    assert.equal(state.sessionDir, chatPaths.sessionDir);
    assert.deepEqual(state.memoryPaths, memoryPaths);
    assert.equal(state.chatPaths, chatPaths);
    assert.equal(state.storagePaths, storagePaths);
    assert.equal(state.responses.size, 0);
    const get = (path) => new Request("http://127.0.0.1" + path);
    assert.equal(await (state.web(get("/"))).text(), "web");
    assert.equal(state.web(get("/api/hub/local")), null);
    assert.deepEqual(await (await state.routes.hub.handle(get("/api/hub/local"))).json(), { ok: true, models: [] });
    assert.deepEqual(await (await state.routes.jobs.handle(get("/api/jobs"))).json(), { ok: true, jobs: [] });
    assert.ok(existsSync(storagePaths.jobsDb), "the job store follows the storage seam");
    const status = await (await state.routes.memory.handle(get("/api/memory/status"))).json();
    assert.deepEqual([status.ok, status.enabled, status.root], [false, false, memoryPaths.vault]);
    assert.equal(await state.memorySurface(), undefined);
    assert.ok(!existsSync(memoryPaths.vault), "reading memory status never initializes a vault");
    assert.deepEqual(await (await state.routes.sessions.handle(get("/api/sessions/search?q=hello"))).json(), { ok: true, results: [] });
    assert.deepEqual(await (await state.routes.publishing.handle(get("/api/settings/hf-token"))).json(), { ok: true, hasToken: false });
    for (const group of ["quantize", "finetune"]) assert.equal(await state.routes[group].handle(get("/api/" + group + "/anything")), null);
    // Loopback clients follow the attached host's port and fall back to the requested one.
    assert.equal(serverPort(), 0);
    const detach = state.attach({ port: 4321, async acquireExecutionLease() { throw new Error("unused"); }, invalidateLibrary() {} });
    assert.equal(serverPort(), 4321);
    detach();
    assert.equal(serverPort(), 0);
    assert.deepEqual(state.downloads.active, []);
    await state.close(); await state.close();
    assert.throws(() => state.downloads.start("org/model"), /downloads are closed/);
  `;
  const home = `${process.env.TMPDIR ?? "/tmp"}/mlx-serve-state-${crypto.randomUUID()}`;
  const result = await runChild(script, { HOME: home, HF_HUB_CACHE: `${home}/hub`, HF_TOKEN: "" });
  expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
});

test("the model host takes persistent services by parameter, mounts the app's route order, and closes in the pre-split order", async () => {
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    const app = ${JSON.stringify(app)};
    const events = [], visited = [];
    const group = name => ({ async handle() { visited.push(name); return null; } });
    const context = { modelId: "test", model: { config: { text: { maxPositionEmbeddings: 4096 } }, weightsBytes: 1e9 }, glmMemoryPlan: null, tokenizer: {},
      template: { supportsThinking: false }, genDefaults: {}, draft: null, dispose() { events.push("model close"); } };
    const cache = { promptCache: {}, resolvedKvScheme: { mode: "off", fitOptions: undefined }, kvScheme: {}, stateCodecs: {}, adapterNamespace() {},
      checkpoints: null, continuationServices: {}, stopIdleDemotion() { events.push("timer stop"); }, async close() { events.push("cache close"); return { durable: true }; } };
    const gateway = { async acquireExecutionLease(signal) { events.push("lease"); return { dispose() {} }; }, async runExclusive(fn) { return fn(); } };
    let engine;
    mock.module(app + "src/engine/index.ts", () => ({
      loadContext: async () => context, modelServingBinding: async () => ({ gateway: { configureContinuation() {} } }),
      createCacheServices: async () => cache,
      createAppEngine: async (_context, options) => engine = { gateway, async close() { events.push("engine close"); await options.beforeModelDispose(); context.dispose(); } },
    }));
    let limit = 77;
    mock.module("@mlx-bun/mlx/ffi", () => ({ setMemoryLimit(bytes) { events.push("allocator " + bytes); const previous = limit; limit = bytes; return previous; } }));
    mock.module(app + "src/engine/transcription-service.ts", () => ({ TranscriptionService: class {
      constructor(options) { this.modelId = options.modelId; this.resident = false; }
      close() { return this.closing ??= (async () => { await Promise.resolve(); events.push("whisper close"); })(); }
    } }));
    let completionOptions, piOptions, managementOptions, artifactOptions, listenerInput, whisperProbe;
    mock.module(app + "src/server/routes.ts", () => ({ createCompletionRoutes(_engine, options) { completionOptions = options; whisperProbe = options.transcription;
      return { ...group("completions"), invalidateLibrary() { events.push("invalidate"); }, responseStats: () => ({}) }; } }));
    mock.module(app + "src/server/status-routes.ts", () => ({ createStatusRoutes: () => group("status") }));
    mock.module(app + "src/server/cache-routes.ts", () => ({ createCacheRoutes: () => group("cacheAdmin") }));
    mock.module(app + "src/server/adapter-routes.ts", () => ({ createAdapterRoutes: () => group("adapters") }));
    mock.module(app + "src/server/management-routes.ts", () => ({ createManagementRoutes(options) { managementOptions = options; return group("management"); } }));
    mock.module(app + "src/server/audio-routes.ts", () => ({ createAudioRoutes: () => group("audio") }));
    mock.module(app + "src/server/adapter-artifact-routes.ts", () => ({ createAdapterArtifactRoutes(_gateway, options) { artifactOptions = options; return group("adapterArtifacts"); } }));
    mock.module(app + "src/server/generated-token-history.ts", () => ({ GeneratedTokenHistory: class { remember() {} } }));
    mock.module(app + "src/chat/pi-backend.ts", () => ({ createPiBackend(options) { piOptions = options; return () => {}; } }));
    let bind = true;
    mock.module(app + "src/server/start.ts", () => ({ startServer: async input => {
      listenerInput = input; events.push("listener");
      if (!bind) { await input.closeEngine(); throw new Error("bind failed"); }
      let closing;
      return { server: { port: 1234 }, close: () => closing ??= (async () => {
        await input.beforeDrain(); events.push("chat dispose"); events.push("drain"); await input.closeEngine(); })() };
    } }));
    // A hand-built persistent state: every service the host needs, nothing reachable any other way.
    const chatPaths = { cwd: "/unused", toolApprovalsFile: "/unused/approvals.json" };
    const surface = { readOnly: true };
    const snapshot = () => [];
    let link, detaches = 0, stateCloses = 0;
    const state = {
      web: () => null, downloads: { snapshot, active: [], start() {}, async close() {} }, responses: { size: 0 },
      memoryPaths: { vault: "/unused/vault", skills: "/unused/skills" }, chatPaths, sessionDir: "/unused/sessions",
      storagePaths: { artifactRoot: "/unused/artifacts" }, memorySurface: async () => surface,
      routes: Object.fromEntries(["hub", "sessions", "memory", "jobs", "quantize", "dataset", "finetune", "publishing"].map(name => [name, group(name)])),
      attach(supplied) { link = supplied; events.push("attach"); return () => { detaches++; events.push("detach"); }; },
      async close() { stateCloses++; },
    };
    const { startModelHost } = await import(app + "src/cli/serve-host.ts");
    const { parseServeOptions } = await import(app + "src/cli/serve.ts");
    const { parseCommand } = await import(app + "src/cli/args.ts");
    const options = parseServeOptions(parseCommand("serve", ["--memory-budget", "8", "--whisper-model", "large", "--no-open"]));
    options.whisper = { ...options.whisper, modelDir: "/unused/whisper", modelId: "org/whisper" };
    const host = await startModelHost(state, { path: "/unused", repoId: "test", expertsBytes: 0 }, options,
      { beforeDrain: async () => { events.push("jobs close"); events.push("downloads close"); } });
    assert.equal(host.port, 1234);
    // The link is lent before the listener binds and reads the bound port afterwards.
    assert.deepEqual(events, ["allocator 8000000000", "attach", "listener"]);
    assert.equal(link.port, 1234);
    await link.acquireExecutionLease(new AbortController().signal); link.invalidateLibrary();
    assert.deepEqual(events.slice(3), ["lease", "invalidate"]);
    // Persistent services arrive by parameter.
    assert.equal(completionOptions.downloads, snapshot); assert.equal(completionOptions.responseHistory, state.responses);
    assert.equal(piOptions.memory, state.memorySurface); assert.equal(piOptions.downloadsSnapshot, snapshot);
    assert.deepEqual(piOptions.paths, { ...chatPaths, sessionDir: "/unused/sessions" });
    assert.equal(await piOptions.memory(), surface);
    assert.equal(managementOptions.toolApprovalsFile, chatPaths.toolApprovalsFile); assert.equal(managementOptions.servedModelPath, "/unused");
    assert.equal(artifactOptions.outputRoot, "/unused/artifacts");
    assert.equal(listenerInput.web, state.web);
    // The route table keeps the app's mount order across both halves.
    assert.equal(await listenerInput.routes.handle(new Request("http://127.0.0.1/unmounted")), null);
    assert.deepEqual(visited, ["status", "cacheAdmin", "hub", "sessions", "adapters", "management", "audio", "memory", "jobs", "quantize", "dataset", "finetune", "adapterArtifacts", "publishing", "completions"]);
    // Close order recorded from the pre-split serve-cli examples: timer stop, background producers (the hook)
    // with Whisper alongside them before drain, chat and HTTP drain, Whisper again (idempotent, catches a
    // companion created by a request admitted during drain), engine, caches, model, process settings; then the link detaches.
    assert.deepEqual(await whisperProbe(), { id: "org/whisper", resident: false });
    events.length = 0;
    await host.close(); await host.close();
    assert.deepEqual(events, ["timer stop", "jobs close", "downloads close", "whisper close", "chat dispose", "drain", "engine close", "cache close", "model close", "allocator 77", "detach"]);
    assert.equal(limit, 77); assert.equal(detaches, 1);
    assert.equal(stateCloses, 0, "the host never closes the persistent state");
    // Startup failure after the link is lent detaches it and restores the process without touching the state.
    events.length = 0; bind = false;
    await assert.rejects(startModelHost(state, { path: "/unused", repoId: "test", expertsBytes: 0 }, options), /bind failed/);
    assert.deepEqual(events, ["allocator 8000000000", "attach", "listener", "engine close", "cache close", "model close", "allocator 77", "detach"]);
    assert.equal(stateCloses, 0);
  `;
  const result = await runChild(script);
  expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
});

test("two sequential model hosts share one persistent state; only the app closes its producers", async () => {
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    const app = ${JSON.stringify(app)};
    const events = [], loads = [];
    const contextFor = path => ({ modelId: path, model: { config: { text: { maxPositionEmbeddings: 4096 } }, weightsBytes: 1e9 }, glmMemoryPlan: null, tokenizer: {},
      template: { supportsThinking: false }, genDefaults: {}, draft: null, dispose() { events.push("model close " + path); } });
    const cache = { promptCache: {}, resolvedKvScheme: { mode: "off", fitOptions: undefined }, kvScheme: {}, stateCodecs: {}, adapterNamespace() {},
      checkpoints: null, continuationServices: {}, stopIdleDemotion() {}, async close() { return { durable: true }; } };
    mock.module(app + "src/engine/index.ts", () => ({
      loadContext: async path => { loads.push(path); return contextFor(path); }, modelServingBinding: async () => ({ gateway: { configureContinuation() {} } }),
      createCacheServices: async () => cache,
      createAppEngine: async context => ({ gateway: {}, async close() { events.push("engine close " + context.modelId); context.dispose(); } }),
    }));
    const histories = [];
    mock.module(app + "src/server/routes.ts", () => ({ createCompletionRoutes(_engine, options) { histories.push(options.responseHistory);
      return { handle: async () => null, invalidateLibrary() {}, responseStats: () => ({}) }; } }));
    mock.module(app + "src/server/status-routes.ts", () => ({ createStatusRoutes: () => ({ handle: async () => null }) }));
    mock.module(app + "src/server/generated-token-history.ts", () => ({ GeneratedTokenHistory: class { remember() {} } }));
    mock.module(app + "src/chat/pi-backend.ts", () => ({ createPiBackend: () => () => {} }));
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => () => null }));
    mock.module(app + "src/jobs/host.ts", () => ({ createJobHost() { let closing;
      return { signal: new AbortController().signal, ensureStore() { throw new Error("unused"); }, submit() {}, submitTask() {},
        close() { return closing ??= (async () => { events.push("jobs close"); })(); } }; } }));
    let serverPort;
    mock.module(app + "src/server/dataset-routes.ts", () => ({ createDatasetRoutes(deps) { serverPort = deps.serverPort; return { handle: async () => null }; } }));
    let port = 1000;
    mock.module(app + "src/server/start.ts", () => ({ startServer: async input => { let closing; const bound = ++port;
      return { server: { port: bound }, close: () => closing ??= (async () => { await input.beforeDrain(); await input.closeEngine(); })() }; } }));
    const { createAppState } = await import(app + "src/cli/serve-state.ts");
    const { startModelHost } = await import(app + "src/cli/serve-host.ts");
    const state = await createAppState({ port: 0, memoryPaths: { vault: "/unused/vault", skills: "/unused/skills" }, chatPaths: { sessionDir: "/unused/sessions" } }, {});
    const options = { query: null, hostname: "127.0.0.1", port: 0, capacity: 8, contextLimit: null, readOnly: false, noOpen: true, request: {}, cache: { kvQuant: "off" } };
    const first = await startModelHost(state, { path: "/a", repoId: "a", expertsBytes: 0 }, options);
    assert.equal(first.port, 1001); assert.equal(serverPort(), 1001);
    await first.close();
    assert.deepEqual(events, ["engine close /a", "model close /a"]);
    assert.equal(serverPort(), 0, "a closed host lends nothing");
    const second = await startModelHost(state, { path: "/b", repoId: "b", expertsBytes: 0 }, options);
    assert.equal(second.port, 1002); assert.equal(serverPort(), 1002);
    assert.deepEqual(loads, ["/a", "/b"]);
    assert.equal(histories.length, 2); assert.equal(histories[0], histories[1], "Responses history outlives a host");
    assert.equal(histories[0], state.responses);
    await second.close();
    assert.deepEqual(events, ["engine close /a", "model close /a", "engine close /b", "model close /b"]);
    await state.close();
    assert.deepEqual(events.slice(4), ["jobs close"]);
  `;
  const result = await runChild(script);
  expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
});

test("jobs and downloads reach the serving host only through the attached link", async () => {
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    const app = ${JSON.stringify(app)};
    const events = [];
    let jobOptions, downloadOptions;
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => () => null }));
    mock.module(app + "src/jobs/host.ts", () => ({ createJobHost(options) { jobOptions = options;
      return { signal: new AbortController().signal, ensureStore() { throw new Error("unused"); }, submit() {}, submitTask() {}, async close() {} }; } }));
    mock.module(app + "src/hub/downloads.ts", () => ({ DuplicateDownloadError: class extends Error {}, createDownloadOwner(options) { downloadOptions = options;
      return { active: [], start() {}, snapshot: () => [], async close() {} }; } }));
    const { createAppState } = await import(app + "src/cli/serve-state.ts");
    const state = await createAppState({ port: 0, memoryPaths: { vault: "/unused/vault", skills: "/unused/skills" }, chatPaths: { sessionDir: "/unused/sessions" } }, {});
    assert.ok(jobOptions.entry.endsWith("/src/cli/job-entry.ts"));
    // Without a host, a lease request fails and library invalidation is a no-op.
    assert.throws(() => jobOptions.acquire(new AbortController().signal), /no model host is attached/);
    jobOptions.onComplete();
    const log = console.log; console.log = message => events.push(message);
    try { await downloadOptions.onComplete("org/model"); } finally { console.log = log; }
    assert.deepEqual(events, ["[hub] download complete: org/model"]);
    events.length = 0;
    const lease = { dispose() {} };
    const detach = state.attach({ port: 1, async acquireExecutionLease(signal) { events.push("lease " + signal.aborted); return lease; },
      invalidateLibrary() { events.push("invalidate"); } });
    assert.equal(await jobOptions.acquire(new AbortController().signal), lease);
    jobOptions.onComplete();
    console.log = () => {};
    try { await downloadOptions.onComplete("org/model"); } finally { console.log = log; }
    assert.deepEqual(events, ["lease false", "invalidate", "invalidate"]);
    detach();
    assert.throws(() => jobOptions.acquire(new AbortController().signal), /no model host is attached/);
    await state.close();
  `;
  const home = `${process.env.TMPDIR ?? "/tmp"}/mlx-serve-link-${crypto.randomUUID()}`;
  const result = await runChild(script, { HOME: home, HF_HUB_CACHE: `${home}/hub` });
  expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
});
