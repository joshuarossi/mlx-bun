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
    let servedLink;
    mock.module(app + "src/cli/served-model-host.ts", () => ({ createServedModelHost(options) { servedLink = options.link; return {}; } }));
    const serverPort = () => servedLink()?.port ?? 0;
    const { createAppState } = await import(app + "src/cli/serve-state.ts");
    const memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
    const chatPaths = { sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
    const storagePaths = { jobsDb: join(root, "store", "jobs.sqlite"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
    const { installedModules } = await import(app + "src/modules.ts");
    // The state runs the modules that need job runners; Whisper's module belongs to the model host.
    const stateModules = await installedModules("state");
    assert.deepEqual(stateModules.map(module => module.id), ["datasets", "metrics", "quantize", "benchmarks", "train"]);
    assert.deepEqual((await installedModules("model")).map(module => module.id), ["transcription"]);
    const state = await createAppState({ port: 0, memoryPaths, chatPaths }, storagePaths, stateModules);
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
    // The datasets module runs in the state: shipped paths, one task job in the state's store, output under the artifact root.
    assert.equal((await (await state.routes.appModules.handle(get("/api/dataset/templates"))).json()).templates.length, 13);
    assert.equal(await state.routes.appModules.handle(get("/api/dataset/unknown")), null);
    const submitted = await (await state.routes.appModules.handle(new Request("http://127.0.0.1/api/dataset/submit", { method: "POST",
      body: JSON.stringify({ template_id: "sft_qa_pairs", inputs: { pairs_text: "Q: a\\nA: b" } }) }))).json();
    assert.ok(submitted.ok && submitted.output_dir.startsWith(join(storagePaths.artifactRoot, "datasets")), submitted.output_dir);
    let job;
    for (let i = 0; i < 200 && job?.status !== "done" && job?.status !== "failed"; i++) {
      job = (await (await state.routes.jobs.handle(get("/api/jobs/" + submitted.job_id))).json()).job; await Bun.sleep(10);
    }
    assert.equal(job.status, "done", job.error);
    assert.equal(job.kind, "dataset");
    // The quantize module runs in the state too, at its shipped paths: its process job is recorded in the state's store, and with no
    // model host attached the execution lease is refused, so the job ends failed without spawning anything.
    const post = (path, body) => new Request("http://127.0.0.1" + path, { method: "POST", body: JSON.stringify(body) });
    assert.equal((await state.routes.appModules.handle(post("/api/quantize/submit", {}))).status, 400);
    assert.equal((await (await state.routes.appModules.handle(post("/api/quantize/inspect", { model_id: "/nonexistent/model" }))).json()).ok, false);
    assert.deepEqual(await (await state.routes.models.handle(post("/api/model/resolve-folder", { folder_name: "nothing-here" }))).json(),
      { ok: false, error: "Couldn't locate this folder on disk — paste the path instead." });
    const quantized = await (await state.routes.appModules.handle(post("/api/quantize/submit", { model_id: "/nonexistent/model" }))).json();
    assert.equal(quantized.output_dir, join(storagePaths.artifactRoot, "models", "model-4bit"));
    let quantizing;
    for (let i = 0; i < 200 && quantizing?.status !== "failed" && quantizing?.status !== "done"; i++) {
      quantizing = (await (await state.routes.jobs.handle(get("/api/jobs/" + quantized.job_id))).json()).job; await Bun.sleep(10);
    }
    assert.equal(quantizing.kind, "quantize");
    assert.equal(quantizing.status, "failed");
    assert.match(quantizing.error, /no model host is attached/);
    // The train module runs in the state as well: the shipped fine-tune paths, a default adapter directory under the artifact root, and a
    // finetune process job that the missing model host's lease refuses.
    assert.equal((await state.routes.appModules.handle(post("/api/finetune/submit", {}))).status, 400);
    assert.deepEqual(await (await state.routes.appModules.handle(post("/api/finetune/inspect-dataset", { path: "/nonexistent/data" }))).json(),
      { ok: false, n_train: 0, n_valid: 0, format: "unknown", error: "/nonexistent/data/train.jsonl not found" });
    const trained = await (await state.routes.appModules.handle(post("/api/finetune/submit", { model_dir: "/nonexistent/model", data_dir: "/nonexistent/data" }))).json();
    assert.ok(trained.adapter_path.startsWith(join(storagePaths.artifactRoot, "adapters", "adapter-")), trained.adapter_path);
    let training;
    for (let i = 0; i < 200 && training?.status !== "failed" && training?.status !== "done"; i++) {
      training = (await (await state.routes.jobs.handle(get("/api/jobs/" + trained.job_id))).json()).job; await Bun.sleep(10);
    }
    assert.equal(training.kind, "finetune");
    assert.equal(training.status, "failed");
    assert.match(training.error, /no model host is attached/);
    const status = await (await state.routes.memory.handle(get("/api/memory/status"))).json();
    assert.deepEqual([status.ok, status.enabled, status.root], [false, false, memoryPaths.vault]);
    assert.equal(await state.memorySurface(), undefined);
    assert.ok(!existsSync(memoryPaths.vault), "reading memory status never initializes a vault");
    assert.deepEqual(await (await state.routes.sessions.handle(get("/api/sessions/search?q=hello"))).json(), { ok: true, results: [] });
    assert.deepEqual(await (await state.routes.publishing.handle(get("/api/settings/hf-token"))).json(), { ok: true, hasToken: false });
    for (const group of ["models"]) assert.equal(await state.routes[group].handle(get("/api/" + group + "/anything")), null);
    assert.equal(await state.routes.appModules.handle(get("/api/finetune/anything")), null);
    // Modules leasing the served model follow the attached host's port; none is lent before one attaches and after it detaches.
    assert.equal(serverPort(), 0);
    const detach = state.attach({ model: { id: "m", bytes: 1 }, port: 4321, async acquireExecutionLease() { throw new Error("unused"); }, invalidateLibrary() {} });
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
    import { createEventHub } from "@mlx-bun/app-services/portable";
    const app = ${JSON.stringify(app)};
    const events = [], visited = [];
    const group = name => ({ async handle() { visited.push(name); return null; } });
    const context = { modelId: "test", model: { config: { text: { maxPositionEmbeddings: 4096 } }, weightsBytes: 1e9 }, memoryPlan: null, tokenizer: {},
      template: { supportsThinking: false }, genDefaults: {}, draft: null, dispose() { events.push("model close"); } };
    const cache = { promptCache: { totalBytes: 0 }, resolvedKvScheme: { mode: "off", fitOptions: undefined }, kvScheme: {}, stateCodecs: {}, adapterNamespace() {},
      checkpoints: null, continuationServices: {}, stopIdleDemotion() { events.push("timer stop"); }, async close() { events.push("cache close"); return { durable: true }; } };
    const gateway = { activeRows: 0, kvBytes: { projected: 0, budget: null }, async acquireExecutionLease(signal) { events.push("lease"); return { dispose() {} }; }, async runExclusive(fn) { return fn(); } };
    let engine;
    mock.module(app + "src/engine/index.ts", () => ({
      loadContext: async () => context, modelServingBinding: async () => ({ discovery: { embeddings: false }, gateway: { configureContinuation() {} } }),
      createCacheServices: async () => cache,
      createAppEngine: async (_context, options) => engine = { gateway, async close() { events.push("engine close"); await options.beforeModelDispose(); context.dispose(); } },
    }));
    let limit = 77;
    mock.module("@mlx-bun/mlx/ffi", () => ({ setMemoryLimit(bytes) { events.push("allocator " + bytes); const previous = limit; limit = bytes; return previous; },
      maxRecommendedWorkingSetSize: () => 32e9, activeMemory: () => 0 }));
    const lib = app + "../../packages/app-services/src/";
    // The Whisper model host records its close once used, as the real one releases only what it loaded; the module routes stand in as one group at the audio routes' place.
    mock.module(lib + "whisper-model-host.ts", () => ({ ModelHostFailure: class extends Error {},
      createWhisperModelHost: options => ({ used: false, policy: {}, async defaultFor() { this.used = true; return options.configured?.id; },
        stats() { this.used = true; return { resident: false, loads: 0, unloads: 0, lastLoadMs: 0, idleUnloadSec: 0 }; },
        resident: () => [], async acquire() { throw new Error("unused"); }, async plan() {}, async unload() {}, pin() {}, unpin() {}, async preload() { this.used = true; },
        close() { return this.closing ??= (async () => { await Promise.resolve(); if (this.used) events.push("whisper close"); })(); } }) }));
    mock.module(lib + "routes.ts", () => ({ createModuleRoutes: () => group("modules") }));
    let completionOptions, piOptions, managementOptions, artifactOptions, listenerInput, whisperProbe;
    mock.module(app + "src/server/routes.ts", () => ({ createCompletionRoutes(_engine, options) { completionOptions = options; whisperProbe = options.transcription;
      return { ...group("completions"), invalidateLibrary() { events.push("invalidate"); }, responseStats: () => ({}) }; } }));
    mock.module(app + "src/server/status-routes.ts", () => ({ createStatusRoutes: () => group("status") }));
    mock.module(app + "src/server/cache-routes.ts", () => ({ createCacheRoutes: () => group("cacheAdmin") }));
    mock.module(app + "src/server/adapter-routes.ts", () => ({ createAdapterRoutes: () => group("adapters") }));
    mock.module(app + "src/server/management-routes.ts", () => ({ createManagementRoutes(options) { managementOptions = options; return group("management"); } }));
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
      events: createEventHub(),
      routes: Object.fromEntries(["hub", "sessions", "memory", "jobs", "models", "appModules", "publishing"].map(name => [name, group(name)])),
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
    assert.equal(managementOptions.toolApprovalsFile, chatPaths.toolApprovalsFile); assert.deepEqual(managementOptions.servedModelPaths(), ["/unused"]);
    assert.equal(artifactOptions.outputRoot, "/unused/artifacts");
    assert.equal(listenerInput.web, state.web);
    // The route table keeps the app's mount order across both halves.
    assert.equal(await listenerInput.routes.handle(new Request("http://127.0.0.1/unmounted")), null);
    assert.deepEqual(visited, ["status", "cacheAdmin", "adapters", "adapterArtifacts", "completions", "hub", "sessions", "management", "modules", "memory", "jobs", "models", "appModules", "publishing"]);
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
    const contextFor = path => ({ modelId: path, model: { config: { text: { maxPositionEmbeddings: 4096 } }, weightsBytes: 1e9 }, memoryPlan: null, tokenizer: {},
      template: { supportsThinking: false }, genDefaults: {}, draft: null, dispose() { events.push("model close " + path); } });
    const cache = { promptCache: { totalBytes: 0 }, resolvedKvScheme: { mode: "off", fitOptions: undefined }, kvScheme: {}, stateCodecs: {}, adapterNamespace() {},
      checkpoints: null, continuationServices: {}, stopIdleDemotion() {}, async close() { return { durable: true }; } };
    mock.module(app + "src/engine/index.ts", () => ({
      loadContext: async path => { loads.push(path); return contextFor(path); }, modelServingBinding: async () => ({ discovery: { embeddings: false }, gateway: { configureContinuation() {} } }),
      createCacheServices: async () => cache,
      createAppEngine: async context => ({ gateway: { activeRows: 0, kvBytes: { projected: 0, budget: null } }, async close() { events.push("engine close " + context.modelId); context.dispose(); } }),
    }));
    mock.module("@mlx-bun/mlx/ffi", () => ({ maxRecommendedWorkingSetSize: () => 32e9, activeMemory: () => 0 }));
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
    let servedLink;
    mock.module(app + "src/cli/served-model-host.ts", () => ({ createServedModelHost(options) { servedLink = options.link; return {}; } }));
    const serverPort = () => servedLink()?.port ?? 0;
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

test("memory synthesis runs on one lazily created task model, bound to each run's signal, and closes it after the runs join", async () => {
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    import { mkdirSync, writeFileSync } from "node:fs";
    import { join } from "node:path";
    const app = ${JSON.stringify(app)};
    const events = [];
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => () => null }));
    mock.module(app + "src/jobs/host.ts", () => ({ createJobHost() { return { signal: new AbortController().signal,
      ensureStore() { throw new Error("unused"); }, submit() {}, submitTask() {}, async close() { events.push("jobs close"); } }; } }));
    const { createAppState } = await import(app + "src/cli/serve-state.ts");
    // A vault with articles: the wikify sweep reaches for the model.
    const vault = join(process.env.HOME, "vault");
    mkdirSync(join(vault, "articles"), { recursive: true });
    writeFileSync(join(vault, "articles", "Alpha.md"), "# Alpha\\n\\nAlpha is a test article about lenses. See [[Beta]].\\n");
    writeFileSync(join(vault, "articles", "Beta.md"), "# Beta\\n\\nBeta links to [[Alpha]].\\n");
    let created = 0, reached = 0;
    const signals = [], twoReached = Promise.withResolvers();
    // Each completion is held until its run's signal aborts.
    const held = signal => () => { if (++reached === 2) twoReached.resolve(); events.push("completion");
      return new Promise((_resolve, reject) => signal.addEventListener("abort", () => { events.push("aborted"); reject(signal.reason); }, { once: true })); };
    const memoryTaskModel = () => { created++; return { client: undefined,
      clientFor(signal) { signals.push(signal); return { complete: held(signal), completeBatch: held(signal) }; },
      async close() { events.push("task model close"); } }; };
    const state = await createAppState({ port: 0, memoryPaths: { vault, skills: join(process.env.HOME, "skills") },
      chatPaths: { sessionDir: join(process.env.HOME, "sessions") }, memoryTaskModel }, {});
    assert.equal(created, 0, "composing the state creates no task model");
    // Each task-model call holds the attached host's execution lease, as managed jobs do.
    state.attach({ port: 1, invalidateLibrary() {}, async acquireExecutionLease(signal) { signal.throwIfAborted(); events.push("lease");
      return { dispose() { events.push("release"); } }; } });
    const first = await state.routes.memory.handle(new Request("http://app/v1/memory/synthesize"));
    const second = await state.routes.memory.handle(new Request("http://app/v1/memory/synthesize"));
    const bodies = Promise.all([first.text(), second.text()]);
    await twoReached.promise;
    assert.equal(created, 1, "concurrent runs share one resident task model");
    assert.equal(signals.length, 2);
    assert.notEqual(signals[0], signals[1], "each run binds its own signal");
    await state.close();
    assert.ok(signals.every(signal => signal.aborted));
    // Every completion ran under a lease taken before it; runs stop, release and join before the task model closes.
    const model = events.indexOf("task model close");
    assert.deepEqual(events.slice(0, model).filter(event => event !== "jobs close").slice(0, 4), ["lease", "completion", "lease", "completion"]);
    assert.deepEqual(events.slice(4, model).filter(event => event !== "jobs close").toSorted(), ["aborted", "aborted", "release", "release"]);
    assert.equal(events.filter(event => event === "task model close").length, 1);
    for (const body of await bodies) assert.ok(!body.includes("[DONE]"));
    await state.close();
    assert.equal(events.filter(event => event === "task model close").length, 1, "close is idempotent");
  `;
  const home = (await import("node:fs")).mkdtempSync(resolve((await import("node:os")).tmpdir(), "mlx-synthesis-state-"));
  try {
    const result = await runChild(script, { HOME: home, MLX_BUN_WIKI: resolve(home, "vault") });
    expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
  } finally { (await import("node:fs")).rmSync(home, { recursive: true, force: true }); }
});

test("a synthesis run waiting on the execution lease is cancelled cleanly, and close during an active managed job joins it before the task model closes", async () => {
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    import { mkdirSync, writeFileSync } from "node:fs";
    import { join } from "node:path";
    const app = ${JSON.stringify(app)};
    const events = [];
    let jobOptions, jobLease;
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => () => null }));
    mock.module(app + "src/jobs/host.ts", () => ({ createJobHost(options) { jobOptions = options; return { signal: new AbortController().signal,
      ensureStore() { throw new Error("unused"); }, submit() {}, submitTask() {},
      async close() { events.push("jobs close"); jobLease?.dispose(); } }; } }));
    const { createAppState } = await import(app + "src/cli/serve-state.ts");
    const vault = join(process.env.HOME, "vault");
    mkdirSync(join(vault, "articles"), { recursive: true });
    writeFileSync(join(vault, "articles", "Alpha.md"), "# Alpha\\n\\nAlpha is a test article about lenses. See [[Beta]].\\n");
    writeFileSync(join(vault, "articles", "Beta.md"), "# Beta\\n\\nBeta links to [[Alpha]].\\n");
    const memoryTaskModel = () => { const client = { async complete() { events.push("completion"); return ""; }, async completeBatch() { events.push("completion"); return []; } };
      return { client, clientFor: () => client, async close() { events.push("task model close"); } }; };
    const state = await createAppState({ port: 0, memoryPaths: { vault, skills: join(process.env.HOME, "skills") },
      chatPaths: { sessionDir: join(process.env.HOME, "sessions") }, memoryTaskModel }, {});
    // The host's execution lease is exclusive; a waiter leaves the queue when its signal aborts.
    let holder = false;
    const queue = [];
    state.attach({ port: 1, invalidateLibrary() {}, acquireExecutionLease(signal) {
      return new Promise((resolve, reject) => {
        const grant = () => { holder = true; resolve({ dispose() { holder = false; queue.shift()?.(); } }); };
        if (!holder) return grant();
        queue.push(grant);
        events.push("waiting");
        signal.addEventListener("abort", () => { queue.splice(queue.indexOf(grant), 1); events.push("wait cancelled"); reject(signal.reason); }, { once: true });
      });
    } });
    // An active managed job holds the lease.
    jobLease = await jobOptions.acquire(new AbortController().signal);
    const waitFor = async what => { for (let i = 0; i < 500 && !events.includes(what); i++) await Bun.sleep(10); assert.ok(events.includes(what), what); };
    // A run waiting for the lease is cancelled by its request: no completion starts.
    const request = new AbortController();
    const first = await state.routes.memory.handle(new Request("http://app/v1/memory/synthesize", { signal: request.signal }));
    const firstBody = first.text().catch(() => "");
    await waitFor("waiting");
    request.abort(new Error("client left"));
    await waitFor("wait cancelled");
    assert.ok(!(await firstBody).includes("[DONE]"));
    // Close while the job still holds the lease and another run waits: runs and the job are joined, then the task model closes.
    events.length = 0;
    const second = await state.routes.memory.handle(new Request("http://app/v1/memory/synthesize"));
    const secondBody = second.text();
    await waitFor("waiting");
    await state.close();
    assert.ok(!(await secondBody).includes("[DONE]"));
    assert.ok(!events.includes("completion"), "no completion ran while the job held the lease");
    const model = events.indexOf("task model close");
    assert.ok(model > events.indexOf("wait cancelled") && model > events.indexOf("jobs close"), JSON.stringify(events));
    assert.equal(events.at(-1), "task model close");
  `;
  const home = (await import("node:fs")).mkdtempSync(resolve((await import("node:os")).tmpdir(), "mlx-synthesis-lease-"));
  try {
    const result = await runChild(script, { HOME: home, MLX_BUN_WIKI: resolve(home, "vault") });
    expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
  } finally { (await import("node:fs")).rmSync(home, { recursive: true, force: true }); }
});

test("a memory call holding the execution lease delays a managed job until it settles, and close waits for the job's asynchronous join before closing the task model", async () => {
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    import { mkdirSync, writeFileSync } from "node:fs";
    import { join } from "node:path";
    const app = ${JSON.stringify(app)};
    const events = [];
    let jobOptions;
    const jobJoin = Promise.withResolvers();
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => () => null }));
    mock.module(app + "src/jobs/host.ts", () => ({ createJobHost(options) { jobOptions = options; return { signal: new AbortController().signal,
      ensureStore() { throw new Error("unused"); }, submit() {}, submitTask() {},
      async close() { events.push("jobs closing"); await jobJoin.promise; events.push("jobs joined"); } }; } }));
    const { createAppState } = await import(app + "src/cli/serve-state.ts");
    const vault = join(process.env.HOME, "vault");
    mkdirSync(join(vault, "articles"), { recursive: true });
    writeFileSync(join(vault, "articles", "Alpha.md"), "# Alpha\\n\\nAlpha is a test article about lenses. See [[Beta]].\\n");
    writeFileSync(join(vault, "articles", "Beta.md"), "# Beta\\n\\nBeta links to [[Alpha]].\\n");
    // The memory call is held until released; it then settles like a batch whose rows all joined.
    const memoryCall = Promise.withResolvers();
    const call = async () => { events.push("memory call"); await memoryCall.promise; events.push("memory call settled"); return ""; };
    const memoryTaskModel = () => { const client = { complete: call, completeBatch: async () => { await call(); return []; } };
      return { client, clientFor: () => client, async close() { events.push("task model close"); } }; };
    const state = await createAppState({ port: 0, memoryPaths: { vault, skills: join(process.env.HOME, "skills") },
      chatPaths: { sessionDir: join(process.env.HOME, "sessions") }, memoryTaskModel }, {});
    let holder = false;
    const queue = [];
    state.attach({ port: 1, invalidateLibrary() {}, acquireExecutionLease(signal) {
      return new Promise((resolve, reject) => {
        const grant = () => { holder = true; resolve({ dispose() { events.push("lease released"); holder = false; queue.shift()?.(); } }); };
        if (!holder) return grant();
        queue.push(grant);
        signal.addEventListener("abort", () => { queue.splice(queue.indexOf(grant), 1); reject(signal.reason); }, { once: true });
      });
    } });
    const waitFor = async what => { for (let i = 0; i < 500 && !events.includes(what); i++) await Bun.sleep(10); assert.ok(events.includes(what), what); };
    // A memory call holds the lease: a managed job's lease waits until that call settles.
    const run = await state.routes.memory.handle(new Request("http://app/v1/memory/synthesize"));
    const body = run.text();
    await waitFor("memory call");
    const job = jobOptions.acquire(new AbortController().signal).then(lease => { events.push("job lease"); return lease; });
    await Bun.sleep(50);
    assert.ok(!events.includes("job lease"), "the job waits while the memory call holds the lease");
    memoryCall.resolve();
    const jobLease = await job;
    assert.deepEqual(events.slice(events.indexOf("memory call settled")), ["memory call settled", "lease released", "job lease"]);
    jobLease.dispose();
    await body;
    // Close waits for the job's asynchronous join before the task model closes, and closes it once.
    events.length = 0;
    const closing = state.close();
    await waitFor("jobs closing");
    await Bun.sleep(50);
    assert.ok(!events.includes("task model close"), "the task model outlives the job's join");
    jobJoin.resolve();
    await closing;
    assert.deepEqual(events.slice(events.indexOf("jobs joined")), ["jobs joined", "task model close"]);
    await state.close();
    assert.equal(events.filter(event => event === "task model close").length, 1);
  `;
  const home = (await import("node:fs")).mkdtempSync(resolve((await import("node:os")).tmpdir(), "mlx-synthesis-contention-"));
  try {
    const result = await runChild(script, { HOME: home, MLX_BUN_WIKI: resolve(home, "vault") });
    expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
  } finally { (await import("node:fs")).rmSync(home, { recursive: true, force: true }); }
});
