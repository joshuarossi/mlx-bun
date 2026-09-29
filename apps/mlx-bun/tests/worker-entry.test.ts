import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync, statSync } from "node:fs";
import { EventEmitter } from "node:events";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { startModelServer, validateAppLaunchArgv, type AppSocketHooks, type RunningApp, type ServeOptions } from "../src/cli/serve";
import { runWorkerEntry, type AppWorkerDependencies } from "../src/cli/worker-entry";
import { encodeLaunch, spawnWorker, WorkerExitedError, WORKER_MESSAGE_PREFIX, WORKER_PROTOCOL_VERSION } from "../src/jobs/worker-process";
import { startServer } from "../src/server/start";

// Worker mode composes only the model host (src/cli/serve-host.ts) over a Unix
// socket with the persistent services stubbed (src/cli/worker-entry.ts). The
// child scripts mock the engine like tests/serve-composition.test.ts and drive
// the entry in-process; the spawned runs exercise the real entry across the
// process boundary on its failure paths, where no mock is needed.
const app = new URL("../", import.meta.url).pathname;

async function runChild(script: string, env: Record<string, string> = {}) {
  const child = Bun.spawn([process.execPath, "--eval", script], { stdout: "pipe", stderr: "pipe", cwd: app,
    env: { ...process.env, MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1", ...env } });
  const [code, stdout, stderr] = await Promise.all([child.exited, new Response(child.stdout).text(), new Response(child.stderr).text()]);
  return { code, stdout, stderr };
}

function socketDir() {
  const dir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  return { dir, socketPath: join(dir, "worker.sock"), remove: () => rmSync(dir, { recursive: true, force: true }) };
}

// The fakes every composition script shares: an engine whose gateway hands out
// counted leases, model route groups that answer nothing but /v1/models, and
// no native library anywhere.
const preamble = `
  import { mock } from "bun:test";
  import { strict as assert } from "node:assert";
  import { existsSync, statSync } from "node:fs";
  import { EventEmitter } from "node:events";
  const app = ${JSON.stringify(app)};
  const events = [];
  const until = async (check, what) => { const end = Date.now() + 5000; while (!check()) { if (Date.now() > end) throw new Error("timed out waiting for " + what); await Bun.sleep(5); } };
  const context = { modelId: "org/model", model: { config: { text: { maxPositionEmbeddings: 4096 } }, weightsBytes: 1e9 }, memoryPlan: null, tokenizer: {},
    template: { supportsThinking: false }, genDefaults: {}, draft: null, dispose() { events.push("model close"); } };
  const cache = { promptCache: {}, resolvedKvScheme: { mode: "off", fitOptions: undefined }, kvScheme: {}, stateCodecs: {}, adapterNamespace() {},
    checkpoints: null, continuationServices: {}, stopIdleDemotion() { events.push("timer stop"); }, async close() { events.push("cache close"); return { durable: true }; } };
  const gateway = { activeRows: 0, kvBytes: { projected: 0, budget: null }, held: 0, async acquireExecutionLease(signal) { signal.throwIfAborted(); gateway.held++; events.push("lease");
    return { dispose() { gateway.held--; events.push("release"); } }; }, async runExclusive(fn) { return fn(); } };
  mock.module("@mlx-bun/mlx/ffi", () => { throw new Error("native library loaded"); });
  mock.module(app + "src/engine/index.ts", () => ({
    loadContext: async () => { if (process.env.WORKER_LOAD_FAILS) throw new Error("load failed"); events.push("load"); return context; },
    modelServingBinding: async () => ({ gateway: { configureContinuation() {} } }),
    createCacheServices: async () => cache,
    createAppEngine: async () => ({ gateway, async close() { events.push("engine close"); await cache.close(); context.dispose(); } }),
  }));
  mock.module(app + "src/server/routes.ts", () => ({ createCompletionRoutes(_engine, options) { events.push("routes " + (options.responseHistory?.size ?? "?"));
    return { async handle(request) { const path = new URL(request.url).pathname;
      if (path === "/v1/models") return Response.json({ object: "list", data: [{ id: "org/model" }] });
      if (path === "/health") return Response.json({ status: "ok" });
      if (path === "/v1/chat/completions") { await new Promise(resolve => setTimeout(resolve, 200)); return Response.json({ id: "chatcmpl" }); }
      return null; }, invalidateLibrary() {}, responseStats: () => ({}) }; } }));
  const group = () => ({ handle: async () => null });
  mock.module(app + "src/server/status-routes.ts", () => ({ createStatusRoutes: group }));
  mock.module(app + "src/server/cache-routes.ts", () => ({ createCacheRoutes: group }));
  mock.module(app + "src/server/adapter-routes.ts", () => ({ createAdapterRoutes: group }));
  mock.module(app + "src/server/management-routes.ts", () => ({ createManagementRoutes: group }));
  mock.module(app + "src/server/adapter-artifact-routes.ts", () => ({ createAdapterArtifactRoutes: group }));
  mock.module(app + "src/server/generated-token-history.ts", () => ({ GeneratedTokenHistory: class { remember() {} } }));
  mock.module(app + "src/chat/pi-backend.ts", () => ({ createPiBackend: () => () => ({ async start() {}, async handle() {}, dispose() {} }) }));
  mock.module(app + "src/chat/session-files.ts", () => ({ defaultSessionDir: () => "/unused/sessions" }));
  // The memory task model the admin surface runs the parent's synthesis calls on; each call records the gateway's lease count.
  mock.module(app + "src/cli/memory-engine.ts", () => ({ createInProcessMemoryClient: () => ({ client: undefined,
    clientFor: (signal, snapshot) => ({ async complete(request) { events.push("task " + request.input.user + " held=" + gateway.held); return "task " + request.input.user; },
      async completeBatch(requests) { events.push("task batch " + snapshot + " held=" + gateway.held); return requests.map(request => "task " + request.input.user); } }),
    async close() { events.push("task model close"); } }) }));
  const { runWorkerEntry, createWorkerState, parseWorkerLaunch } = await import(app + "src/cli/worker-entry.ts");
  const { encodeLaunch, WORKER_MESSAGE_PREFIX, WORKER_PROTOCOL_VERSION: version } = await import(app + "src/jobs/worker-process.ts");
  const socketPath = process.env.WORKER_SOCKET;
  const launch = { version, socketPath, model: { repoId: "org/model", path: "/unused", expertsBytes: 0 }, options: { query: null, hostname: "127.0.0.1", port: 0,
    capacity: 8, contextLimit: null, readOnly: false, noOpen: true, request: {}, cache: { kvQuant: "off", ssdCacheMaxBytes: Infinity } } };
  // The parent's pipe: the launch line now; it stays open until the parent leaves.
  let push, end;
  const stdin = new ReadableStream({ start(controller) { push = text => controller.enqueue(new TextEncoder().encode(text)); end = () => controller.close(); } });
  const written = [], signals = new EventEmitter();
  const errors = [], error = console.error; console.error = message => errors.push(String(message));
  const start = () => runWorkerEntry({ stdin, write: line => written.push(line), signals });
  const get = (path, init) => fetch("http://worker" + path, { unix: socketPath, ...init });
`;

test("the worker entry composes the model host alone over the parent's socket, serves the admin surface ahead of it, and leaves when the parent does", async () => {
  const script = preamble + `
    push(encodeLaunch(launch) + "\\n");
    const running = start();
    await until(() => written.length > 0, "the ready line");
    assert.ok(written[0].startsWith(WORKER_MESSAGE_PREFIX));
    assert.deepEqual(JSON.parse(written[0].slice(WORKER_MESSAGE_PREFIX.length)), { type: "ready", socketPath, modelId: "org/model", pid: process.pid, version });
    assert.deepEqual(events, ["load", "routes 0"], "only the model half composes; the Responses history is the worker's own, empty store");
    assert.equal(statSync(socketPath).mode & 0o777, 0o600);
    assert.deepEqual(await (await get("/health")).json(), { status: "ok", state: "ready", model: "org/model", pid: process.pid, in_flight: 0, leases: 0 });
    assert.deepEqual(await (await get("/v1/models")).json(), { object: "list", data: [{ id: "org/model" }] });
    // Persistent surfaces are the parent's: no web app, no hub, jobs, sessions, memory, or publishing routes.
    for (const path of ["/", "/index.html", "/api/hub/local", "/api/jobs", "/api/sessions/search?q=x", "/api/memory/status", "/api/settings/hf-token", "/api/quantize/anything"])
      assert.equal((await get(path)).status, 404, path);
    assert.equal((await get("/engine")).status, 404, "/engine is the parent's, not the worker's");
    // A lease runs through the attached link to the engine's gateway and is owned by the connection.
    const holder = new AbortController();
    const leased = await get("/admin/lease", { method: "POST", signal: holder.signal });
    assert.equal(leased.status, 200);
    assert.equal(new TextDecoder().decode((await leased.body.getReader().read()).value), "leased\\n");
    assert.equal(gateway.held, 1);
    assert.equal((await (await get("/health")).json()).leases, 1);
    holder.abort();
    await until(() => gateway.held === 0, "the lease release");
    // The parent's synthesis calls run on the worker's task model under the same execution lease.
    events.length = 0;
    const memory = await get("/admin/memory/complete", { method: "POST", body: JSON.stringify({ call: "completeBatch", snapshot: "/hub/task/selected",
      requests: ["a", "b"].map(user => ({ stage: "entity", input: { user }, maxTokens: 8 })) }) });
    assert.deepEqual(await memory.json(), { outputs: ["task a", "task b"] });
    assert.deepEqual(events, ["lease", "task batch /hub/task/selected held=1", "release"], "the parent's selected snapshot reaches the task model");
    // Drain waits for an admitted request, then reports; admission stays shut.
    const inflight = get("/v1/chat/completions", { method: "POST", body: "{}" });
    await until(() => false || true, "");
    let report = await (await get("/admin/drain", { method: "POST", body: JSON.stringify({ timeout_ms: 2000 }) })).json();
    assert.deepEqual([report.drained, report.state, report.timed_out, report.in_flight, report.leases], [true, "draining", false, 0, 0]);
    assert.deepEqual(await (await inflight).json(), { id: "chatcmpl" });
    assert.equal((await get("/v1/models")).status, 503);
    assert.equal((await (await get("/health")).json()).state, "draining");
    assert.deepEqual(events.filter(event => event === "lease" || event === "release"), ["lease", "release", "lease", "release"]);
    // The parent leaves: stdin ends, the host closes in the app's order (the task model before the engine), the socket is gone, the exit code is clean.
    events.length = 0;
    end();
    assert.equal(await running, 0);
    assert.deepEqual(events, ["timer stop", "task model close", "engine close", "cache close", "model close"]);
    assert.ok(!existsSync(socketPath), "the socket file is removed on close");
    assert.deepEqual(errors, []);
    assert.equal(written.length, 1);
    // The stubbed persistent half: nothing served, no producers, the link kept for the admin routes.
    const link = {};
    const state = createWorkerState(launch.options, link);
    assert.equal(state.web(new Request("http://worker/")), null);
    assert.throws(() => state.downloads.start("org/x"), /owns no downloads/);
    assert.deepEqual([state.downloads.active, state.downloads.snapshot()], [[], []]);
    assert.equal(await state.memorySurface(), undefined);
    assert.equal(state.responses.size, 0);
    assert.equal(state.sessionDir, "/unused/sessions");
    for (const name of ["hub", "sessions", "memory", "jobs", "quantize", "appModules", "finetune", "publishing"])
      assert.equal(await state.routes[name].handle(new Request("http://worker/api/" + name)), null);
    const supplied = { port: 1, async acquireExecutionLease() { throw new Error("unused"); }, invalidateLibrary() {} };
    const detach = state.attach(supplied);
    assert.equal(link.current, supplied); detach(); assert.equal(link.current, undefined);
    await state.close();
    // Launch validation names what is missing.
    for (const [bad, message] of [["nope", "not JSON"], ["[]", "must be an object"], ["{}", "needs socketPath"],
      [JSON.stringify({ version, socketPath }), "model.repoId"], [JSON.stringify({ version, socketPath, model: { repoId: "a", path: "/a" } }), "resolved serve options"]])
      assert.throws(() => parseWorkerLaunch(bad), new RegExp("worker launch.*" + message));
    assert.deepEqual(parseWorkerLaunch(encodeLaunch(launch)), launch);
  `;
  const socket = socketDir();
  try {
    const result = await runChild(script, { WORKER_SOCKET: socket.socketPath });
    expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
    expect(existsSync(socket.socketPath)).toBe(false);
  } finally { socket.remove(); }
});

test("a signal closes the worker once, a repeated signal waits on that close, and a failed start reports without a ready line", async () => {
  const script = preamble + `
    push(encodeLaunch(launch) + "\\n");
    const running = start();
    await until(() => written.length > 0, "the ready line");
    events.length = 0;
    signals.emit("SIGTERM"); signals.emit("SIGINT"); signals.emit("SIGTERM");
    assert.equal(await running, 0);
    assert.deepEqual(events, ["timer stop", "task model close", "engine close", "cache close", "model close"]);
    assert.deepEqual([signals.listenerCount("SIGTERM"), signals.listenerCount("SIGINT")], [0, 0]);
    assert.ok(!existsSync(socketPath));
    // Startup failure: exit 1, the error on stderr, nothing bound, no ready line.
    process.env.WORKER_LOAD_FAILS = "1";
    let push2;
    const stdin2 = new ReadableStream({ start(controller) { push2 = text => controller.enqueue(new TextEncoder().encode(text)); } });
    push2(encodeLaunch(launch) + "\\n");
    events.length = 0;
    const failed = await runWorkerEntry({ stdin: stdin2, write: line => written.push(line), signals });
    assert.equal(failed, 1);
    assert.deepEqual(errors, ["worker startup failed: load failed"]);
    assert.deepEqual(events, ["task model close"], "a failed start closes the unused task model");
    assert.equal(written.length, 1);
    assert.ok(!existsSync(socketPath));
    // A launch record that never arrives, or is not one, exits 2 before any composition.
    const empty = new ReadableStream({ start(controller) { controller.close(); } });
    assert.equal(await runWorkerEntry({ stdin: empty, write: () => {}, signals }), 2);
    const junk = new ReadableStream({ start(controller) { controller.enqueue(new TextEncoder().encode("{}\\n")); controller.close(); } });
    assert.equal(await runWorkerEntry({ stdin: junk, write: () => {}, signals }), 2);
    assert.deepEqual(errors.slice(1), ["worker launch: stdin ended before the launch record", "worker launch needs socketPath"]);
  `;
  const socket = socketDir();
  try {
    const result = await runChild(script, { WORKER_SOCKET: socket.socketPath });
    expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
  } finally { socket.remove(); }
});

test("the real entry, spawned through the parent-side helper with the native library blocked, fails closed before ready on the launch, the app form's arguments, the protocol version, and the load", async () => {
  const socket = socketDir();
  const env = { MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1", HOME: socket.dir };
  const other = `${WORKER_PROTOCOL_VERSION}-other`;
  try {
    for (const [entry, expectedExit, launch, message] of [
      [join(app, "src/cli/worker-entry.ts"), 2, { version: WORKER_PROTOCOL_VERSION, socketPath: socket.socketPath }, "worker launch needs model.repoId and model.path"],
      [join(app, "src/cli/worker-entry.ts"), 2, { kind: "app", version: other, socketPath: socket.socketPath, argv: ["--model", "org/model"] },
        `worker protocol version mismatch: the launch record is ${other}, this worker is ${WORKER_PROTOCOL_VERSION}`],
      [join(app, "src/cli/worker-entry.ts"), 2, { kind: "app", version: WORKER_PROTOCOL_VERSION, socketPath: socket.socketPath, argv: ["--model", "org/model", "--isolate"] },
        "--isolate is not supported in a worker app launch"],
      [join(app, "src/cli/worker-entry.ts"), 1, { version: WORKER_PROTOCOL_VERSION, socketPath: socket.socketPath, model: { repoId: "org/missing", path: join(socket.dir, "missing-model"), expertsBytes: 0 },
        options: { query: null, hostname: "127.0.0.1", port: 0, capacity: 8, contextLimit: null, readOnly: false, noOpen: true, request: {}, cache: { kvQuant: "off" } } }, "worker startup failed: "],
    ] as const) {
      const errors: string[] = [], logs: string[] = [];
      const worker = spawnWorker({ entry, socketPath: socket.socketPath, launch, env, log: line => logs.push(line), error: line => errors.push(line) });
      const failure = await worker.ready.then(() => { throw new Error("must not be ready"); }, (error: unknown) => error);
      expect(failure).toBeInstanceOf(WorkerExitedError);
      expect((failure as WorkerExitedError).exit).toEqual({ code: expectedExit, signal: null });
      expect(errors.join("\n")).toContain(message);
      // A refused launch (exit 2) carries the worker's reason into the parent's rejection.
      if (expectedExit === 2) expect((failure as Error).message).toBe(`worker exited with code 2 before ready: ${errors.at(-1)}`);
      expect(logs).toEqual([]);
      expect(await worker.close()).toEqual({ code: expectedExit, signal: null });
      expect(existsSync(socket.socketPath)).toBe(false);
    }
    // The compiled binary reaches the same entry through main's private `__worker` dispatch.
    const child = Bun.spawn([process.execPath, "--no-env-file", join(app, "src/cli/main.ts"), "__worker"], {
      stdin: Buffer.from("{}\n"), stdout: "pipe", stderr: "pipe", env: { ...process.env, ...env } });
    const [code, stdout, stderr] = await Promise.all([child.exited, new Response(child.stdout).text(), new Response(child.stderr).text()]);
    expect({ code, stdout, stderr: stderr.trim() }).toEqual({ code: 2, stdout: "", stderr: "worker launch needs socketPath" });
  } finally { socket.remove(); }
}, 30_000);

// The app form (`{ kind: "app", version, socketPath, argv }`): runServe composes
// the app from serve arguments on the parent's socket. These in-process
// examples stand in for model selection and composition (the seam hands them
// the socket hooks) and bind a real listener through server/start.ts; the
// child script after them composes the real app with a fake engine.
async function until(check: () => boolean | Promise<boolean>, what: string, timeoutMs = 5_000) {
  const end = Date.now() + timeoutMs;
  while (!await check()) { if (Date.now() > end) throw new Error(`timed out waiting for ${what}`); await Bun.sleep(5); }
}
const chatModel = { repoId: "org/model", path: "/unused/model", modelType: "qwen3", expertsBytes: 0 } as ModelRecord;
const whisperModel = { repoId: "org/whisper", path: "/unused/whisper", modelType: "whisper", expertsBytes: 0 } as ModelRecord;

/** A composition stand-in that serves a tiny model surface through the hooks it
 * receives; `closeError` makes its close reject after releasing the listener. */
function fakeHost(events: string[], beforeBind?: () => void | Promise<void>, closeError?: Error) {
  const calls: { model: ModelRecord; options: ServeOptions; hooks: AppSocketHooks }[] = [];
  const start = async (model: ModelRecord, options: ServeOptions, hooks: AppSocketHooks = {}): Promise<RunningApp> => {
    calls.push({ model, options, hooks });
    events.push(`start ${model.repoId}`);
    await beforeBind?.();
    const group = { async handle(request: Request) {
      const path = new URL(request.url).pathname;
      if (path === "/slow") { await Bun.sleep(200); return Response.json({ slow: true }); }
      if (path === "/v1/models") return Response.json({ data: [{ id: model.repoId }] });
      return null;
    } };
    const listener = await startServer({ routes: hooks.routes!(group), web: () => null,
      chat: () => ({ async start() {}, async handle() {}, dispose() {} }),
      beforeDrain: async () => { await hooks.beforeDrain?.(); events.push("producers close"); },
      closeEngine: async () => { events.push("engine close"); } }, { unix: hooks.unix! });
    // What the model host lends the app state; the admin lease reaches the gateway through it.
    if (hooks.link) hooks.link.current = { model: { id: model.repoId, bytes: 0 }, port: 0, unix: hooks.unix, invalidateLibrary() {},
      async acquireExecutionLease() { events.push("lease"); return { dispose() { events.push("release"); } }; } };
    return { downloads: { active: [], start() {} }, async close() {
      events.push("app close"); await listener.close();
      if (closeError) throw closeError;
    } };
  };
  return { start, calls };
}

function appWorker(argv: string[], app: Partial<AppWorkerDependencies>, extra: { launch?: Record<string, unknown>; write?(line: string): void } = {}) {
  const socket = socketDir();
  const written: string[] = [], logs: string[] = [], errors: string[] = [];
  const signals = new EventEmitter();
  let push!: (text: string) => void, end!: () => void;
  const stdin = new ReadableStream<Uint8Array>({ start(controller) {
    push = text => controller.enqueue(new TextEncoder().encode(text)); end = () => { try { controller.close(); } catch { /* closed */ } };
  } });
  push(encodeLaunch({ kind: "app", version: WORKER_PROTOCOL_VERSION, socketPath: socket.socketPath, argv, ...extra.launch }) + "\n");
  const error = console.error;
  console.error = (message: unknown) => { errors.push(String(message)); };
  const restore = () => { console.error = error; };
  const exited = runWorkerEntry({ stdin, write: extra.write ?? (line => { written.push(line); }), signals,
    app: { log: line => { logs.push(line); }, ...app } }).finally(restore);
  const get = (path: string, init: RequestInit = {}) => fetch(`http://worker${path}`, { ...init, unix: socket.socketPath } as RequestInit);
  return { socketPath: socket.socketPath, written, logs, errors, signals, end: () => end(), exited, get,
    ready: () => JSON.parse(written[0]!.slice(WORKER_MESSAGE_PREFIX.length)) as Record<string, unknown>,
    cleanup() { restore(); end(); socket.remove(); } };
}

test("the app form runs serve arguments through runServe on the parent's socket: ready only after start with the model and version, the admin surface ahead of the app, and one close when the parent leaves", async () => {
  const events: string[] = [], queries: (string | null)[] = [];
  const loaded = Promise.withResolvers<void>();
  const host = fakeHost(events, () => loaded.promise);
  const run = appWorker(["--model", "org/model", "--host", "0.0.0.0", "--port", "0", "--no-open", "--batch", "2"],
    { resolve: async query => { queries.push(query); return { m: chatModel, picked: false }; }, start: host.start });
  try {
    await until(() => host.calls.length === 1, "the start");
    // Loading: nothing announced, nothing bound.
    await Bun.sleep(20);
    expect(run.written).toEqual([]);
    expect(existsSync(run.socketPath)).toBe(false);
    loaded.resolve();
    await until(() => run.written.length === 1, "the ready line");
    expect(run.ready()).toEqual({ type: "ready", socketPath: run.socketPath, modelId: "org/model", pid: process.pid, version: WORKER_PROTOCOL_VERSION });
    expect(queries).toEqual(["org/model"]);
    // The CLI's parse, with the transport flags accepted and the socket hooks handed to the composition.
    const { options, hooks } = host.calls[0]!;
    expect(options).toMatchObject({ query: "org/model", hostname: "0.0.0.0", port: 0, noOpen: true, isolate: false, capacity: 2 });
    expect([hooks.unix, typeof hooks.routes, typeof hooks.beforeDrain, typeof hooks.link]).toEqual([run.socketPath, "function", "function", "object"]);
    expect(run.logs).toEqual(["Loading org/model", "Serving org/model with continuous batching (capacity 2) over the Unix socket"]);
    expect(statSync(run.socketPath).mode & 0o777).toBe(0o600);
    expect(await (await run.get("/health")).json()).toEqual({ status: "ok", state: "ready", model: "org/model", pid: process.pid, in_flight: 0, leases: 0 });
    expect(await (await run.get("/v1/models")).json()).toEqual({ data: [{ id: "org/model" }] });
    // The lease reaches the attached host's gateway and is owned by the connection.
    const holder = new AbortController();
    const leased = await run.get("/admin/lease", { method: "POST", signal: holder.signal });
    expect(new TextDecoder().decode((await leased.body!.getReader().read()).value)).toBe("leased\n");
    holder.abort();
    await until(() => events.includes("release"), "the lease release");
    // Drain: the admitted request completes, a new one is refused.
    const slow = run.get("/slow");
    await until(async () => (await (await run.get("/health")).json() as { in_flight: number }).in_flight === 1, "the admitted request");
    const report = await (await run.get("/admin/drain", { method: "POST", body: JSON.stringify({ timeout_ms: 2000 }) })).json() as Record<string, unknown>;
    expect([report.drained, report.state, report.timed_out, report.in_flight]).toEqual([true, "draining", false, 0]);
    expect(await (await slow).json()).toEqual({ slow: true });
    const refused = await run.get("/v1/models");
    expect(refused.status).toBe(503);
    expect(await refused.json()).toMatchObject({ error: { type: "draining" } });
    // The parent leaves: one close through runServe's shutdown, exit 0, the socket gone.
    events.length = 0;
    run.end();
    expect(await run.exited).toBe(0);
    expect(events).toEqual(["app close", "producers close", "engine close"]);
    expect(existsSync(run.socketPath)).toBe(false);
    expect([run.signals.listenerCount("SIGTERM"), run.signals.listenerCount("SIGINT")]).toEqual([0, 0]);
    expect(run.written).toHaveLength(1);
    expect(run.errors).toEqual([]);
  } finally { run.cleanup(); }
});

test("the app form announces nothing when startup fails or is stopped, closes an app that did start, and stops once after ready", async () => {
  // A failed load: exit 1 with the reason, no ready line, nothing bound.
  {
    const run = appWorker(["--model", "org/model"], { resolve: async () => ({ m: chatModel, picked: false }),
      start: fakeHost([], () => { throw new Error("load failed"); }).start });
    try {
      expect(await run.exited).toBe(1);
      expect([run.written, run.errors, existsSync(run.socketPath)]).toEqual([[], ["worker startup failed: load failed"], false]);
    } finally { run.cleanup(); }
  }
  // A stop during the load is not a clean cancellation when the load fails anyway.
  {
    let run!: ReturnType<typeof appWorker>;
    run = appWorker(["--model", "org/model"], { resolve: async () => ({ m: chatModel, picked: false }),
      start: fakeHost([], () => { run.signals.emit("SIGTERM"); throw new Error("load failed"); }).start });
    try {
      expect(await run.exited).toBe(1);
      expect([run.written, run.errors]).toEqual([[], ["worker startup failed: load failed"]]);
    } finally { run.cleanup(); }
  }
  // A signal during selection cancels startup before any load.
  {
    const events: string[] = [];
    let run!: ReturnType<typeof appWorker>;
    run = appWorker(["--model", "org/model"], { resolve: async () => { run.signals.emit("SIGTERM"); return { m: chatModel, picked: false }; },
      start: fakeHost(events).start });
    try {
      expect(await run.exited).toBe(0);
      expect([run.written, events, run.errors]).toEqual([[], [], ["worker startup cancelled: startup cancelled by signal"]]);
    } finally { run.cleanup(); }
  }
  // A stop while the app loads (a signal, or the parent leaving) lets it finish, then closes it once without a ready line.
  for (const stop of ["SIGTERM", "end of stdin"] as const) {
    const events: string[] = [];
    let run!: ReturnType<typeof appWorker>;
    const host = fakeHost(events, async () => { if (stop === "SIGTERM") run.signals.emit("SIGTERM"); else { run.end(); await Bun.sleep(20); } });
    run = appWorker(["--model", "org/model"], { resolve: async () => ({ m: chatModel, picked: false }), start: host.start });
    try {
      expect([stop, await run.exited]).toEqual([stop, 0]);
      expect(run.written).toEqual([]);
      expect(events).toEqual(["start org/model", "app close", "producers close", "engine close"]);
      expect(existsSync(run.socketPath)).toBe(false);
      expect([run.signals.listenerCount("SIGTERM"), run.signals.listenerCount("SIGINT")]).toEqual([0, 0]);
      expect(run.errors).toEqual([]);
    } finally { run.cleanup(); }
  }
  // A stop while the app loads whose close then fails: one close attempt, no ready line, the original error, a nonzero exit.
  for (const stop of ["SIGTERM", "end of stdin"] as const) {
    const events: string[] = [];
    let run!: ReturnType<typeof appWorker>;
    const host = fakeHost(events, async () => { if (stop === "SIGTERM") run.signals.emit("SIGTERM"); else { run.end(); await Bun.sleep(20); } },
      new Error("cache flush failed"));
    run = appWorker(["--model", "org/model"], { resolve: async () => ({ m: chatModel, picked: false }), start: host.start });
    try {
      expect([stop, await run.exited]).toEqual([stop, 1]);
      expect(run.written).toEqual([]);
      expect(events.filter(event => event === "app close")).toEqual(["app close"]);
      expect(run.errors).toEqual(["worker startup failed: cache flush failed"]);
      expect(existsSync(run.socketPath)).toBe(false);
    } finally { run.cleanup(); }
  }
  // A started app whose ready line cannot be written is closed, and the worker fails.
  {
    const events: string[] = [];
    const run = appWorker(["--model", "org/model"], { resolve: async () => ({ m: chatModel, picked: false }), start: fakeHost(events).start },
      { write() { throw new Error("stdout closed"); } });
    try {
      expect(await run.exited).toBe(1);
      expect(events).toEqual(["start org/model", "app close", "producers close", "engine close"]);
      expect(run.errors).toEqual(["worker ready line failed: stdout closed"]);
      expect(existsSync(run.socketPath)).toBe(false);
    } finally { run.cleanup(); }
  }
  // After ready: a signal closes the app once; a repeated one waits on that close.
  {
    const events: string[] = [];
    const run = appWorker(["--model", "org/model"], { resolve: async () => ({ m: chatModel, picked: false }), start: fakeHost(events).start });
    try {
      await until(() => run.written.length === 1, "the ready line");
      events.length = 0;
      run.signals.emit("SIGTERM"); run.signals.emit("SIGINT"); run.signals.emit("SIGTERM");
      expect(await run.exited).toBe(0);
      expect(events).toEqual(["app close", "producers close", "engine close"]);
      expect([run.signals.listenerCount("SIGTERM"), run.signals.listenerCount("SIGINT")]).toEqual([0, 0]);
    } finally { run.cleanup(); }
  }
});

test("the app form refuses nested isolation, a missing model, arguments the CLI refuses, and another package version's launch record with exit 2 before composing", async () => {
  const version = `${WORKER_PROTOCOL_VERSION}-other`;
  for (const [argv, launch, message] of [
    [["--model", "org/model", "--isolate"], {}, "--isolate is not supported in a worker app launch: nested isolation would bind TCP, never the launch socket"],
    [["--model", "org/model", "--model-pool", "2"], {}, "--model-pool is not supported in a worker app launch: nested isolation would bind TCP, never the launch socket"],
    [["--model", ""], {}, "a worker app launch needs a non-empty --model: automatic selection may download the starter model"],
    [["--port", "0"], {}, "a worker app launch needs a non-empty --model: automatic selection may download the starter model"],
    [["--model", "org/model", "--bogus"], {}, "Unknown option '--bogus'"],
    [["--model", "org/model", "--batch", "0"], {}, "--batch expects an integer in [1, 9007199254740991]"],
    [["--model", "org/model"], { version }, `worker protocol version mismatch: the launch record is ${version}, this worker is ${WORKER_PROTOCOL_VERSION}`],
    [["--model", "org/model"], { version: undefined }, `worker protocol version mismatch: the launch record is unversioned, this worker is ${WORKER_PROTOCOL_VERSION}`],
    [["--model", "org/model"], { argv: "--model org/model" }, "worker launch needs argv, the serve arguments"],
  ] as const) {
    let selected = false;
    const run = appWorker([...argv], { resolve: async () => { selected = true; return { m: chatModel, picked: false }; } }, { launch });
    try {
      expect(await run.exited).toBe(2);
      expect(run.errors).toHaveLength(1);
      expect(run.errors[0]).toContain(message);
      expect([selected, run.written, existsSync(run.socketPath)]).toEqual([false, [], false]);
    } finally { run.cleanup(); }
  }
  // The helper a parent calls to fail fast: transport flags pass and do not steer the socket.
  expect(validateAppLaunchArgv(["--model", "org/model", "--host", "0.0.0.0", "--port", "9", "--no-open"]).values)
    .toMatchObject({ model: "org/model", host: "0.0.0.0", port: "9", "no-open": true });
  // And composition itself never nests an isolated app behind a socket.
  await expect(startModelServer(chatModel, { isolate: true } as ServeOptions, { unix: "/unused.sock" })).rejects.toThrow("--isolate is not supported in a worker app launch");
});

test("a Whisper checkpoint in the app form hands the socket hooks to the transcription-only host, whose admin surface has no lease", async () => {
  const events: string[] = [];
  const host = fakeHost(events);
  let started = false;
  const run = appWorker(["--model", "org/whisper"], { resolve: async () => ({ m: whisperModel, picked: false }),
    start: async () => { started = true; throw new Error("unused"); }, startTranscription: host.start });
  try {
    await until(() => run.written.length === 1, "the ready line");
    expect(run.ready()).toMatchObject({ type: "ready", socketPath: run.socketPath, modelId: "org/whisper", version: WORKER_PROTOCOL_VERSION });
    expect(started).toBe(false);
    const { model, hooks } = host.calls[0]!;
    expect([model, hooks.unix, typeof hooks.routes, typeof hooks.beforeDrain, hooks.link]).toEqual([whisperModel, run.socketPath, "function", "function", undefined]);
    expect(run.logs).toEqual(["Serving org/whisper as a transcription-only server", "POST /v1/audio/transcriptions over the Unix socket (released after every take; loads on first request)"]);
    expect(await (await run.get("/health")).json()).toMatchObject({ status: "ok", state: "ready", model: "org/whisper" });
    const lease = await run.get("/admin/lease", { method: "POST" });
    expect([lease.status, await lease.json()]).toEqual([404, { error: { message: "Not found" } }]);
    const report = await (await run.get("/admin/drain", { method: "POST" })).json() as Record<string, unknown>;
    expect([report.drained, report.state]).toEqual([true, "draining"]);
    expect(events).not.toContain("lease");
    run.signals.emit("SIGTERM");
    expect(await run.exited).toBe(0);
    expect(existsSync(run.socketPath)).toBe(false);
    expect(run.errors).toEqual([]);
  } finally { run.cleanup(); }
});

test("the app form composes the real app over the socket with private storage: persistent routes, synthesis on the memory task model, dataset loopback to the same socket, streaming, and client aborts", async () => {
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    import { existsSync, statSync } from "node:fs";
    import { EventEmitter } from "node:events";
    import { join } from "node:path";
    const app = ${JSON.stringify(app)};
    const root = process.env.HOME;
    const until = async (check, what) => { const end = Date.now() + 10000; while (!await check()) { if (Date.now() > end) throw new Error("timed out waiting for " + what); await Bun.sleep(10); } };
    const events = [], seen = [];
    mock.module("@mlx-bun/mlx/ffi", () => { throw new Error("native library loaded"); });
    const context = { modelId: "org/model", model: { config: { text: { maxPositionEmbeddings: 4096 } }, weightsBytes: 1e9 }, memoryPlan: null, tokenizer: {},
      template: { supportsThinking: false }, genDefaults: {}, draft: null, dispose() { events.push("model close"); } };
    const cache = { promptCache: {}, resolvedKvScheme: { mode: "off", fitOptions: undefined }, kvScheme: {}, stateCodecs: {}, adapterNamespace() {},
      checkpoints: null, continuationServices: {}, stopIdleDemotion() {}, async close() { return { durable: true }; } };
    const gateway = { activeRows: 0, kvBytes: { projected: 0, budget: null }, async acquireExecutionLease(signal) { signal.throwIfAborted(); events.push("lease"); return { dispose() { events.push("release"); } }; }, async runExclusive(fn) { return fn(); } };
    mock.module(app + "src/engine/index.ts", () => ({
      loadContext: async () => context, modelServingBinding: async () => ({ gateway: { configureContinuation() {} } }),
      createCacheServices: async () => cache,
      createAppEngine: async () => ({ gateway, async close() { events.push("engine close"); context.dispose(); } }),
    }));
    // The Whisper model host records its close; nothing else about it is under test here.
    mock.module(app + "../../packages/app-services/src/whisper-model-host.ts", () => ({ ModelHostFailure: class extends Error {},
      createWhisperModelHost: options => ({ used: false, policy: {}, async defaultFor() { this.used = true; return options.configured?.id; },
        stats() { this.used = true; return { resident: false, loads: 0, unloads: 0, lastLoadMs: 0, idleUnloadSec: 0 }; },
        resident: () => [], async acquire() { throw new Error("unused"); }, async plan() {}, async unload() {}, pin() {}, unpin() {}, async preload() { this.used = true; },
        close() { return this.closing ??= (async () => { if (this.used) events.push("whisper close"); })(); } }) }));
    // The model's HTTP surface, recorded: it exists only on the worker socket.
    const encoder = new TextEncoder();
    const frame = text => "data: " + JSON.stringify({ choices: [{ index: 0, delta: { content: text } }] }) + "\\n\\n";
    mock.module(app + "src/server/routes.ts", () => ({ createCompletionRoutes() { return {
      async handle(request) {
        const url = new URL(request.url);
        if (url.pathname === "/library") return Response.json({ models: [{ repo_id: "org/model", serving: true }] });
        if (url.pathname !== "/v1/chat/completions" || request.method !== "POST") return null;
        const body = await request.json();
        const entry = { host: url.host, authorization: request.headers.get("authorization"), prompt: body.messages.at(-1).content, stream: body.stream === true, aborted: false };
        seen.push(entry);
        request.signal.addEventListener("abort", () => { entry.aborted = true; }, { once: true });
        if (!entry.stream) return Response.json({ choices: [{ index: 0, message: { role: "assistant", content: "loopback reply" }, finish_reason: "stop" }] });
        if (entry.prompt === "hang") return new Response(new ReadableStream({ start(controller) { controller.enqueue(encoder.encode(frame("partial"))); },
          cancel() { entry.aborted = true; } }), { headers: { "content-type": "text/event-stream" } });
        return new Response([frame("Hello"), frame(" world"), "data: [DONE]\\n\\n"].join(""), { headers: { "content-type": "text/event-stream" } });
      }, invalidateLibrary() {}, responseStats: () => ({}) }; } }));
    const group = () => ({ handle: async () => null });
    for (const [module, name] of [["status-routes", "createStatusRoutes"], ["cache-routes", "createCacheRoutes"], ["adapter-routes", "createAdapterRoutes"],
      ["adapter-artifact-routes", "createAdapterArtifactRoutes"]])
      mock.module(app + "src/server/" + module + ".ts", () => ({ [name]: group }));
    mock.module(app + "src/server/generated-token-history.ts", () => ({ GeneratedTokenHistory: class { remember() {} } }));
    mock.module(app + "src/chat/pi-backend.ts", () => ({ createPiBackend: () => () => ({ async start() {}, async handle() {}, dispose() {} }) }));
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => request => new URL(request.url).pathname === "/" ? new Response("web") : null }));
    // The app form is the direct composition: synthesis runs on the memory task model, not over loopback.
    mock.module(app + "src/cli/memory-engine.ts", () => ({ createInProcessMemoryClient: () => {
      const client = { complete: async request => "task model reply to " + request.input.user, completeBatch: async () => [] };
      return { client, clientFor: () => client, async close() { events.push("task model close"); } };
    } }));
    // Synthesis's pipeline stand-in: one stage call through the run's client.
    mock.module(app + "src/memory/pipeline.ts", () => ({ async runSynthesis(options, onEvent) {
      onEvent({ type: "log", message: await options.client.complete({ stage: "extract", input: { user: "synthesis probe" }, maxTokens: 4 }) });
      return { implemented: true, stages: ["extract"], note: "probe" };
    } }));
    const { runWorkerEntry } = await import(app + "src/cli/worker-entry.ts");
    const { startModelServer } = await import(app + "src/cli/serve.ts");
    const { encodeLaunch, WORKER_MESSAGE_PREFIX, WORKER_PROTOCOL_VERSION: version } = await import(app + "src/jobs/worker-process.ts");
    // Every app store is private: overrides where composition takes them, HOME and the HF cache for the rest.
    const chatPaths = { sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json"), agentDir: join(root, "pi") };
    const memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
    const storagePaths = { jobsDb: join(root, "store", "jobs.sqlite"), jobsLogs: join(root, "store", "jobs"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
    const worker = (socketPath, argv, model) => {
      let end;
      const stdin = new ReadableStream({ start(controller) {
        controller.enqueue(encoder.encode(encodeLaunch({ kind: "app", version, socketPath, argv }) + "\\n")); end = () => controller.close(); } });
      const written = [], signals = new EventEmitter();
      const exited = runWorkerEntry({ stdin, write: line => written.push(line), signals, app: { log() {},
        resolve: async query => { assert.equal(query, model.repoId); return { m: model, picked: false }; },
        start: (m, options, hooks) => startModelServer(m, { ...options, chatPaths, memoryPaths, storagePaths }, hooks) } });
      const get = (path, init = {}) => fetch("http://worker" + path, { ...init, unix: socketPath });
      return { written, signals, exited, get, end: () => end() };
    };
    // --port 1 is the loopback URL's placeholder: a request that left the socket would be refused, never served.
    const socketPath = process.env.WORKER_SOCKET;
    const run = worker(socketPath, ["--model", "org/model", "--port", "1", "--no-open"], { repoId: "org/model", path: join(root, "model"), modelType: "qwen3", expertsBytes: 0 });
    await until(() => run.written.length === 1, "the ready line");
    assert.deepEqual(JSON.parse(run.written[0].slice(WORKER_MESSAGE_PREFIX.length)), { type: "ready", socketPath, modelId: "org/model", pid: process.pid, version });
    assert.equal(statSync(socketPath).mode & 0o777, 0o600);
    const json = async (path, init) => { const response = await run.get(path, init); assert.equal(response.status, 200, path); return response.json(); };
    // The whole app answers on the socket, over private storage.
    assert.equal(await (await run.get("/")).text(), "web");
    assert.deepEqual(await json("/health"), { status: "ok", state: "ready", model: "org/model", pid: process.pid, in_flight: 0, leases: 0 });
    assert.deepEqual(await json("/library"), { models: [{ repo_id: "org/model", serving: true }] });
    assert.deepEqual(await json("/api/hub/local"), { ok: true, models: [] });
    assert.deepEqual(await json("/api/jobs"), { ok: true, jobs: [] });
    assert.ok(existsSync(storagePaths.jobsDb), "the job store is the private one");
    assert.deepEqual(await json("/api/sessions/search?q=hello"), { ok: true, results: [] });
    assert.deepEqual(await json("/api/settings/hf-token"), { ok: true, hasToken: false });
    assert.deepEqual(await json("/api/settings/tool-approvals"), { ok: true, alwaysAllow: [] });
    const status = await json("/api/memory/status");
    assert.deepEqual([status.enabled, status.root], [false, memoryPaths.vault]);
    // Memory synthesis runs on the task model; nothing reaches the served model's routes.
    const synthesis = await (await run.get("/v1/memory/synthesize")).text();
    assert.match(synthesis, /"message":"task model reply to synthesis probe"/);
    assert.match(synthesis, /\\[DONE\\]/);
    assert.deepEqual(seen, []);
    // So does a dataset job's chat client (the job runs in this process).
    const submitted = await json("/api/dataset/submit", { method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ template_id: "style_transfer", inputs: { reference_samples: "Plain words.", raw_text: "dataset probe" } }) });
    assert.ok(submitted.ok && submitted.output_dir.startsWith(join(storagePaths.artifactRoot, "datasets")), submitted.output_dir);
    let job;
    await until(async () => { job = (await json("/api/jobs/" + submitted.job_id)).job; return job.status === "done" || job.status === "failed"; }, "the dataset job");
    assert.equal(job.status, "done", job.error);
    assert.equal(seen.length, 1);
    assert.deepEqual([seen[0].host, seen[0].authorization, seen[0].stream], ["127.0.0.1:1", "Bearer sk-mlx-bun-local", false]);
    assert.match(seen[0].prompt, /dataset probe/);
    assert.ok(existsSync(join(submitted.output_dir, "train.jsonl")));
    // Streaming passes through; a client abort mid-stream reaches the route.
    const streamed = await run.get("/v1/chat/completions", { method: "POST", body: JSON.stringify({ stream: true, messages: [{ role: "user", content: "hi" }] }) });
    assert.equal(streamed.headers.get("content-type"), "text/event-stream");
    assert.equal(await streamed.text(), [frame("Hello"), frame(" world"), "data: [DONE]\\n\\n"].join(""));
    const client = new AbortController();
    const hanging = await run.get("/v1/chat/completions", { method: "POST", signal: client.signal, body: JSON.stringify({ stream: true, messages: [{ role: "user", content: "hang" }] }) });
    const reader = hanging.body.getReader();
    assert.equal(new TextDecoder().decode((await reader.read()).value), frame("partial"));
    client.abort();
    await until(() => seen.at(-1).aborted, "the abort to reach the route");
    // The parent leaves: one close, the engine released, the socket gone.
    run.end();
    assert.equal(await run.exited, 0);
    // The task model closes with the persistent state, before the engine drains.
    assert.deepEqual(events.filter(event => event.endsWith("close")), ["task model close", "engine close", "model close"]);
    assert.ok(!existsSync(socketPath));
    // A Whisper checkpoint composes the real transcription-only host on the socket.
    const whisperSocket = process.env.WORKER_SOCKET_2;
    events.length = 0;
    const whisper = worker(whisperSocket, ["--model", "org/whisper"], { repoId: "org/whisper", path: join(root, "whisper"), modelType: "whisper", expertsBytes: 0 });
    await until(() => whisper.written.length === 1, "the transcription ready line");
    assert.equal(JSON.parse(whisper.written[0].slice(WORKER_MESSAGE_PREFIX.length)).modelId, "org/whisper");
    assert.deepEqual((await (await whisper.get("/v1/models")).json()).data.map(row => [row.id, row.transcription]), [["org/whisper", true]]);
    assert.equal((await (await whisper.get("/health")).json()).status, "ok");
    assert.equal((await whisper.get("/admin/lease", { method: "POST" })).status, 404);
    assert.equal((await whisper.get("/", {})).status, 404);
    whisper.signals.emit("SIGTERM");
    assert.equal(await whisper.exited, 0);
    assert.deepEqual(events, ["whisper close"]);
    assert.ok(!existsSync(whisperSocket));
  `;
  const socket = socketDir(), second = socketDir();
  const home = mkdtempSync(join(tmpdir(), "mlx-app-worker-home-"));
  try {
    const result = await runChild(script, { HOME: home, HF_HUB_CACHE: join(home, "hub"), HF_HOME: join(home, "hf"), HF_TOKEN: "",
      WORKER_SOCKET: socket.socketPath, WORKER_SOCKET_2: second.socketPath });
    expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
  } finally { socket.remove(); second.remove(); rmSync(home, { recursive: true, force: true }); }
}, 30_000);
