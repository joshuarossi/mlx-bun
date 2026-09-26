import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { spawnWorker, WorkerExitedError } from "../src/jobs/worker-process";

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
  const context = { modelId: "org/model", model: { config: { text: { maxPositionEmbeddings: 4096 } }, weightsBytes: 1e9 }, glmMemoryPlan: null, tokenizer: {},
    template: { supportsThinking: false }, genDefaults: {}, draft: null, dispose() { events.push("model close"); } };
  const cache = { promptCache: {}, resolvedKvScheme: { mode: "off", fitOptions: undefined }, kvScheme: {}, stateCodecs: {}, adapterNamespace() {},
    checkpoints: null, continuationServices: {}, stopIdleDemotion() { events.push("timer stop"); }, async close() { events.push("cache close"); return { durable: true }; } };
  const gateway = { held: 0, async acquireExecutionLease(signal) { signal.throwIfAborted(); gateway.held++; events.push("lease");
    return { dispose() { gateway.held--; events.push("release"); } }; }, async runExclusive(fn) { return fn(); } };
  mock.module("@mlx-bun/mlx/ffi", () => { throw new Error("native library loaded"); });
  mock.module(app + "src/engine/index.ts", () => ({
    loadContext: async () => { if (process.env.WORKER_LOAD_FAILS) throw new Error("load failed"); events.push("load"); return context; },
    modelServingBinding: async () => ({ gateway: { configureContinuation() {} } }),
    createCacheServices: async () => cache,
    createAppEngine: async () => ({ gateway, async close() { events.push("engine close"); await cache.close(); context.dispose(); } }),
  }));
  mock.module(app + "src/engine/transcription-service.ts", () => ({ TranscriptionService: class {} }));
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
  mock.module(app + "src/server/audio-routes.ts", () => ({ createAudioRoutes: group }));
  mock.module(app + "src/server/adapter-artifact-routes.ts", () => ({ createAdapterArtifactRoutes: group }));
  mock.module(app + "src/server/generated-token-history.ts", () => ({ GeneratedTokenHistory: class { remember() {} } }));
  mock.module(app + "src/chat/pi-backend.ts", () => ({ createPiBackend: () => () => ({ async start() {}, async handle() {}, dispose() {} }) }));
  mock.module(app + "src/chat/session-files.ts", () => ({ defaultSessionDir: () => "/unused/sessions" }));
  const { runWorkerEntry, createWorkerState, parseWorkerLaunch } = await import(app + "src/cli/worker-entry.ts");
  const { encodeLaunch, WORKER_MESSAGE_PREFIX } = await import(app + "src/jobs/worker-process.ts");
  const socketPath = process.env.WORKER_SOCKET;
  const launch = { socketPath, model: { repoId: "org/model", path: "/unused", expertsBytes: 0 }, options: { query: null, hostname: "127.0.0.1", port: 0,
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
    assert.deepEqual(JSON.parse(written[0].slice(WORKER_MESSAGE_PREFIX.length)), { type: "ready", socketPath, modelId: "org/model", pid: process.pid });
    assert.deepEqual(events, ["load", "routes 0"], "only the model half composes; the Responses history is the worker's own, empty store");
    assert.equal(statSync(socketPath).mode & 0o777, 0o600);
    assert.deepEqual(await (await get("/health")).json(), { status: "ok", state: "ready", model: "org/model", pid: process.pid, in_flight: 0, leases: 0 });
    assert.deepEqual(await (await get("/v1/models")).json(), { object: "list", data: [{ id: "org/model" }] });
    // Persistent surfaces are the parent's: no web app, no hub, jobs, sessions, memory, or publishing routes.
    for (const path of ["/", "/index.html", "/api/hub/local", "/api/jobs", "/api/sessions/search?q=x", "/api/memory/status", "/api/settings/hf-token", "/api/quantize/anything"])
      assert.equal((await get(path)).status, 404, path);
    assert.equal((await get("/engine")).status, 501, "/engine stays the parent's, unmigrated");
    // A lease runs through the attached link to the engine's gateway and is owned by the connection.
    const holder = new AbortController();
    const leased = await get("/admin/lease", { method: "POST", signal: holder.signal });
    assert.equal(leased.status, 200);
    assert.equal(new TextDecoder().decode((await leased.body.getReader().read()).value), "leased\\n");
    assert.equal(gateway.held, 1);
    assert.equal((await (await get("/health")).json()).leases, 1);
    holder.abort();
    await until(() => gateway.held === 0, "the lease release");
    // Drain waits for an admitted request, then reports; admission stays shut.
    const inflight = get("/v1/chat/completions", { method: "POST", body: "{}" });
    await until(() => false || true, "");
    let report = await (await get("/admin/drain", { method: "POST", body: JSON.stringify({ timeout_ms: 2000 }) })).json();
    assert.deepEqual([report.drained, report.state, report.timed_out, report.in_flight, report.leases], [true, "draining", false, 0, 0]);
    assert.deepEqual(await (await inflight).json(), { id: "chatcmpl" });
    assert.equal((await get("/v1/models")).status, 503);
    assert.equal((await (await get("/health")).json()).state, "draining");
    assert.deepEqual(events.filter(event => event === "lease" || event === "release"), ["lease", "release", "lease", "release"]);
    // The parent leaves: stdin ends, the host closes in the app's order, the socket is gone, the exit code is clean.
    events.length = 0;
    end();
    assert.equal(await running, 0);
    assert.deepEqual(events, ["timer stop", "engine close", "cache close", "model close"]);
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
    for (const name of ["hub", "sessions", "memory", "jobs", "quantize", "dataset", "finetune", "publishing"])
      assert.equal(await state.routes[name].handle(new Request("http://worker/api/" + name)), null);
    const supplied = { port: 1, async acquireExecutionLease() { throw new Error("unused"); }, invalidateLibrary() {} };
    const detach = state.attach(supplied);
    assert.equal(link.current, supplied); detach(); assert.equal(link.current, undefined);
    await state.close();
    // Launch validation names what is missing.
    for (const [bad, message] of [["nope", "not JSON"], ["[]", "must be an object"], ["{}", "needs socketPath"],
      [JSON.stringify({ socketPath }), "model.repoId"], [JSON.stringify({ socketPath, model: { repoId: "a", path: "/a" } }), "resolved serve options"]])
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
    assert.deepEqual(events, ["timer stop", "engine close", "cache close", "model close"]);
    assert.deepEqual([signals.listenerCount("SIGTERM"), signals.listenerCount("SIGINT")], [0, 0]);
    assert.ok(!existsSync(socketPath));
    // Startup failure: exit 1, the error on stderr, nothing bound, no ready line.
    process.env.WORKER_LOAD_FAILS = "1";
    let push2;
    const stdin2 = new ReadableStream({ start(controller) { push2 = text => controller.enqueue(new TextEncoder().encode(text)); } });
    push2(encodeLaunch(launch) + "\\n");
    const failed = await runWorkerEntry({ stdin: stdin2, write: line => written.push(line), signals });
    assert.equal(failed, 1);
    assert.deepEqual(errors, ["worker startup failed: load failed"]);
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

test("the real entry, spawned through the parent-side helper with the native library blocked, fails closed before ready on both the launch and the load", async () => {
  const socket = socketDir();
  const env = { MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1", HOME: socket.dir };
  try {
    for (const [entry, expectedExit, launch, message] of [
      [join(app, "src/cli/worker-entry.ts"), 2, { socketPath: socket.socketPath }, "worker launch needs model.repoId and model.path"],
      [join(app, "src/cli/worker-entry.ts"), 1, { socketPath: socket.socketPath, model: { repoId: "org/missing", path: join(socket.dir, "missing-model"), expertsBytes: 0 },
        options: { query: null, hostname: "127.0.0.1", port: 0, capacity: 8, contextLimit: null, readOnly: false, noOpen: true, request: {}, cache: { kvQuant: "off" } } }, "worker startup failed: "],
    ] as const) {
      const errors: string[] = [], logs: string[] = [];
      const worker = spawnWorker({ entry, socketPath: socket.socketPath, launch, env, log: line => logs.push(line), error: line => errors.push(line) });
      const failure = await worker.ready.then(() => { throw new Error("must not be ready"); }, (error: unknown) => error);
      expect(failure).toBeInstanceOf(WorkerExitedError);
      expect((failure as WorkerExitedError).exit).toEqual({ code: expectedExit, signal: null });
      expect(errors.join("\n")).toContain(message);
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
