import { expect, test } from "bun:test";
import { spawn } from "node:child_process";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, realpathSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import type { ClientMessage, ServerMessage } from "../src/chat/protocol";
import { parseCommand } from "../src/cli/args";
import { startIsolatedServer } from "../src/cli/serve-isolated";
import { parseServeOptions } from "../src/cli/serve";

// The isolated composition (src/cli/serve-isolated.ts) over the fake worker
// (tests/fake-worker.ts): the parent never loads the engine, spawns the worker
// with the resolved model and options, keeps the persistent routes and web
// chat, and proxies the rest. The child script carries the tripwire mocks;
// the in-process test drives real Pi over a real listener and WebSocket.
const app = new URL("../", import.meta.url).pathname;
const entry = join(app, "tests/fake-worker.ts");
const workerEnv = { MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1" };
const model = (root: string) => ({ repoId: "org/model", path: join(root, "model"), modelType: "qwen3", expertsBytes: 0, sizeBytes: 1 }) as ModelRecord;
const workerDirs = () => readdirSync(tmpdir()).filter(name => name.startsWith("mlx-worker-")).length;
const alive = (pid: number) => { try { process.kill(pid, 0); return true; } catch { return false; } };

test("the isolated composition and the serve entry never reach the engine or the native library through a runtime import", () => {
  // Static gate over import closures (type-only imports elided), following
  // workspace package exports; the child script below is the runtime proof.
  // serve.ts loads the model half only inside the direct composition, so its
  // static closure is the isolated parent's; the only engine file reached is
  // the contract edge through server/http.ts, as for serve-state.ts.
  const root = realpathSync(app), workspace = resolve(root, "../..");
  const transpiler = new Bun.Transpiler({ loader: "ts" });
  const closure = (start: string, staticOnly: boolean) => {
    const seen = new Set<string>(), native: string[] = [];
    const visit = (file: string) => {
      if (seen.has(file) || !/\.(ts|tsx|js|mjs)$/.test(file)) return;
      seen.add(file);
      for (const { path, kind } of transpiler.scanImports(readFileSync(file, "utf8").replace(/^#!.*\n/, ""))) {
        if (staticOnly && kind !== "import-statement") continue;
        if (path.startsWith("node:") || path === "bun" || path.startsWith("bun:")) continue;
        if (!path.startsWith(".") && !path.startsWith("@mlx-bun/")) continue;
        const target = realpathSync(Bun.resolveSync(path, dirname(file)));
        if (target.startsWith(resolve(workspace, "packages/mlx/src") + "/")) native.push(`${relative(workspace, file)} -> ${path}`);
        else visit(target);
      }
    };
    visit(resolve(root, start));
    const engine = [...seen].filter(file => file.startsWith(resolve(root, "src/engine") + "/")).map(file => relative(root, file)).sort();
    return { size: seen.size, native, engine };
  };
  const isolated = closure("src/cli/serve-isolated.ts", false);
  expect(isolated.native).toEqual([]);
  expect(isolated.engine).toEqual(["src/engine/completion.ts"]);
  expect(isolated.size).toBeGreaterThan(40);
  const serve = closure("src/cli/serve.ts", true);
  expect(serve.native).toEqual([]);
  expect(serve.engine).toEqual(["src/engine/completion.ts"]);
  expect(closure("src/cli/main.ts", true).engine).toEqual([]);
});

/** Run a child script in its own process group, so every worker it spawns is
 * in reach: past the deadline the whole group is killed and the call fails.
 * Either way the group is joined before this returns: workers the child left
 * behind get a grace to exit on their closed stdin, then are killed. */
async function runChild(script: string, env: Record<string, string> = {}, deadlineMs = 25_000) {
  const child = spawn(process.execPath, ["--eval", script], { cwd: app, env: { ...process.env, ...workerEnv, ...env },
    detached: true, stdio: ["ignore", "pipe", "pipe"] });
  const group = -child.pid!;
  const alive = () => { try { process.kill(group, 0); return true; } catch { return false; } };
  const kill = () => { try { process.kill(group, "SIGKILL"); } catch { /* the group is gone */ } };
  const read = (stream: NodeJS.ReadableStream) => new Promise<string>(resolve => {
    let text = "";
    stream.setEncoding("utf8");
    stream.on("data", (chunk: string) => { text += chunk; });
    stream.on("end", () => resolve(text));
  });
  const exited = new Promise<number | null>(resolve => child.once("exit", code => resolve(code)));
  let timedOut = false;
  const deadline = setTimeout(() => { timedOut = true; kill(); }, deadlineMs);
  const [code, stdout, stderr] = await Promise.all([exited, read(child.stdout!), read(child.stderr!)]);
  clearTimeout(deadline);
  const grace = Date.now() + 5_000, limit = grace + 5_000;
  while (alive()) {
    if (Date.now() > limit) throw new Error(`process group ${-group} did not exit after SIGKILL`);
    if (Date.now() > grace) kill();
    await Bun.sleep(20);
  }
  if (timedOut) throw new Error(`child script exceeded ${deadlineMs} ms; its process group was killed and joined\n${stderr}`);
  return { code, stdout, stderr };
}
async function until(check: () => boolean | Promise<boolean>, what: string, timeoutMs = 10_000) {
  const end = Date.now() + timeoutMs;
  while (!await check()) { if (Date.now() > end) throw new Error(`timed out waiting for ${what}`); await Bun.sleep(10); }
}

test("the parent composes the persistent state and the proxy without the engine or native library, spawns the worker through the captured executable with the resolved model and options, and closes cleanly", async () => {
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    import { existsSync, readFileSync } from "node:fs";
    import { dirname, join } from "node:path";
    const app = ${JSON.stringify(app)};
    const root = process.env.HOME;
    // Tripwires: the parent must not import the engine or the native binding.
    mock.module(app + "src/engine/index.ts", () => { throw new Error("engine imported"); });
    mock.module(app + "src/engine/model-host.ts", () => { throw new Error("model host imported"); });
    mock.module("@mlx-bun/mlx/ffi", () => { throw new Error("native library loaded"); });
    mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => request =>
      new URL(request.url).pathname === "/" ? new Response("web") : null }));
    const { startIsolatedServer } = await import(app + "src/cli/serve-isolated.ts");
    const { parseServeOptions } = await import(app + "src/cli/serve.ts");
    const { parseCommand } = await import(app + "src/cli/args.ts");
    const { executablePath } = await import(app + "src/jobs/executable.ts");
    const { decodeLaunch, encodeLaunch, WORKER_PROTOCOL_VERSION } = await import(app + "src/jobs/worker-process.ts");
    const options = parseServeOptions(parseCommand("serve", ["--isolate", "--port", "0", "--ssd-cache", join(root, "ssd"), "--ssd-cache-max", "0", "--temperature", "0.3", "--no-open"]));
    options.chatPaths = { sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
    options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
    options.storagePaths = { jobsDb: join(root, "store", "jobs.sqlite"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
    const model = { repoId: "org/model", path: join(root, "model"), modelType: "qwen3", expertsBytes: 0, sizeBytes: 1 };
    const record = join(root, "launches.jsonl");
    const notices = [];
    const env = { FAKE_WORKER_RECORD: record, MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1" };
    const running = await startIsolatedServer(model, options, { entry: process.env.FAKE_WORKER, env, restarts: { max: 1, windowMs: 60_000, delayMs: 0 }, notice: line => notices.push(line) });
    // A failed assertion still closes the server, stopping its workers and removing their sockets.
    try {
      // The spawn: the captured executable, the entry, and the launch record with the model pinned and the options serialized (Infinity intact, the flag the parent's).
      const launches = readFileSync(record, "utf8").trim().split("\\n").map(line => JSON.parse(line));
      assert.equal(launches.length, 1);
      assert.deepEqual(launches[0].argv.slice(0, 2), [executablePath, process.env.FAKE_WORKER]);
      assert.equal(executablePath, process.execPath);
      const launch = decodeLaunch(launches[0].launch);
      assert.deepEqual(launch.model, model);
      assert.deepEqual(launch.options, decodeLaunch(encodeLaunch({ ...options, isolate: false })));
      assert.equal(launch.options.cache.ssdCacheMaxBytes, Infinity);
      assert.ok(launch.socketPath.endsWith("/engine.sock"));
      assert.equal(launch.version, WORKER_PROTOCOL_VERSION, "the model form carries the protocol version");
      const base = "http://127.0.0.1:" + running.port;
      const get = (path, init) => fetch(base + path, init);
      // The parent's own answers.
      assert.equal(await (await get("/")).text(), "web");
      const engine = await (await get("/engine")).json();
      assert.deepEqual([engine.isolated, engine.state, engine.pid, engine.restarts, engine.model, engine.socket, engine.last_exit], [true, "ready", launches[0].pid, 0, "org/model", launch.socketPath, null]);
      assert.deepEqual(engine.pool, { cap: 1, default: "org/model", resident: [{ id: "org/model", pid: launches[0].pid, state: "ready", restarts: 0, socket: launch.socketPath }], loading: [] });
      assert.ok(dirname(engine.socket).startsWith(join(process.env.TMPDIR_PROBE, "mlx-worker-")) && existsSync(engine.socket));
      assert.deepEqual(notices, ["engine worker pid " + launches[0].pid + " ready (socket " + engine.socket + ")"]);
      assert.deepEqual(await (await get("/api/hub/local")).json(), { ok: true, models: [] });
      assert.deepEqual(await (await get("/api/jobs")).json(), { ok: true, jobs: [] });
      assert.deepEqual(await (await get("/downloads")).json(), { downloads: [] });
      assert.deepEqual(await (await get("/api/settings/tool-approvals")).json(), { ok: true, alwaysAllow: [] });
      assert.deepEqual(await (await get("/api/settings/hf-token")).json(), { ok: true, hasToken: false });
      const status = await (await get("/api/memory/status")).json();
      assert.deepEqual([status.ok, status.enabled], [false, false]);
      for (const [path, init] of [["/admin/lease", { method: "POST" }], ["/admin/drain", { method: "POST" }]])
        assert.equal((await get(path, init)).status, 501, path);
      // Memory synthesis is parent-owned (its loopback client reaches the model through this proxy):
      // the dry run streams from the parent without touching the worker.
      const synthesize = await get("/v1/memory/synthesize?dry=1");
      assert.equal(synthesize.status, 200);
      assert.match(await synthesize.text(), /\[DONE\]/);
      assert.equal((await get("/unknown")).status, 404);
      const health = await (await get("/health")).json();
      assert.deepEqual([health.status, health.isolated, health.engine.state, health.engine.pid, health.engine.in_flight, health.engine.leases], ["ok", true, "ready", launches[0].pid, 0, 0]);
      assert.deepEqual(health.pool, { cap: 1, default: "org/model", resident: ["org/model"], loading: [] });
      const stats = await (await get("/stats")).json();
      assert.deepEqual(stats.response_store, { entries: 0, bytes: 0, max_bytes: 32 * 1024 * 1024, ttl_ms: 3_600_000 });
      assert.deepEqual([stats.server.model, stats.admission.enforced_context_tokens, stats.engine.state], ["org/model", 2048, "ready"]);
      // Model-scoped routes reach the worker.
      const listed = (await (await get("/v1/models")).json()).data[0];
      assert.deepEqual([listed.id, listed.resident], ["org/model", true]);
      const completion = await (await get("/v1/chat/completions", { method: "POST", body: JSON.stringify({ model: "x", messages: [{ role: "user", content: "hi" }] }) })).json();
      assert.equal(completion.choices[0].message.content, "echo: hi");
      const seen = await (await get("/fake/seen")).json();
      assert.deepEqual(seen.seen.filter(entry => entry.path.startsWith("/api") || entry.path === "/engine" || entry.path === "/downloads" || entry.path.startsWith("/admin")), []);
      // The parent's link lends the worker's execution lease to managed jobs.
      // Close: the worker is drained then stopped, the socket directory is gone, the state is closed.
      await running.close(); await running.close();
      assert.ok(!existsSync(dirname(engine.socket)), "the socket directory is removed");
      assert.throws(() => process.kill(launches[0].pid, 0), "the worker has exited");
      assert.throws(() => running.downloads.start("org/x"), /downloads are closed/);
    } finally { await running.close(); }
    // A first load that fails: startup rejects with the worker's exit; the first load is never retried and nothing stays behind.
    const failure = await startIsolatedServer(model, options, { entry: process.env.FAKE_WORKER, env: { ...env, FAKE_WORKER_FAIL: "start" }, notice: line => notices.push(line) })
      .then(() => { throw new Error("must fail"); }, error => error);
    assert.equal(failure.name, "WorkerExitedError");
    assert.equal(failure.message, "worker exited with code 1 before ready");
    assert.equal(readFileSync(record, "utf8").trim().split("\\n").length, 2);
    assert.equal(notices.length, 1);
  `;
  const home = mkdtempSync(join(tmpdir(), "mlx-isolated-compose-"));
  const before = workerDirs();
  try {
    const result = await runChild(script, { HOME: home, HF_HUB_CACHE: `${home}/hub`, HF_TOKEN: "", FAKE_WORKER: entry, TMPDIR_PROBE: tmpdir() });
    // The worker's output is forwarded to the parent's log with the worker prefix; nothing else is printed.
    expect({ code: result.code, stdout: result.stdout.split("\n").filter(Boolean), stderr: result.stderr.split("\n").filter(Boolean) }).toEqual({ code: 0,
      stdout: ["[worker] loading org/model"], stderr: ["[worker] drain requested", "[worker] stopping", "[worker] worker startup failed: fake load failure"] });
    expect(workerDirs()).toBe(before);
  } finally { rmSync(home, { recursive: true, force: true }); }
}, 30_000);

// The memory synthesis scripts share this parent: tripwires for the engine,
// the native library and a parent-side task model, and a pipeline stand-in that
// sends one batch over the rows the script picks, then one single call.
const memoryPreamble = `
  import { mock } from "bun:test";
  import { strict as assert } from "node:assert";
  import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
  import { dirname, join } from "node:path";
  const app = ${JSON.stringify(app)};
  const root = process.env.HOME;
  mock.module(app + "src/engine/index.ts", () => { throw new Error("engine imported"); });
  mock.module(app + "src/engine/model-host.ts", () => { throw new Error("model host imported"); });
  mock.module(app + "src/cli/memory-engine.ts", () => { throw new Error("task model imported by the parent"); });
  mock.module("@mlx-bun/mlx/ffi", () => { throw new Error("native library loaded"); });
  mock.module(app + "src/web/assets.ts", () => ({ createWebHandler: async () => () => null }));
  let rows = [];
  mock.module(app + "src/memory/pipeline.ts", () => ({ async runSynthesis(options, onEvent) {
    const batch = await options.client.completeBatch(rows.map(user => ({ stage: "entity", input: { user }, maxTokens: 8 })));
    const single = await options.client.complete({ stage: "route", input: { system: "yes or no", user: "single" }, maxTokens: 4 });
    onEvent({ type: "log", message: JSON.stringify([...batch, single]) });
    return { implemented: true, stages: ["entity", "route"], note: "probe" };
  } }));
  const { startIsolatedServer } = await import(app + "src/cli/serve-isolated.ts");
  const { parseServeOptions } = await import(app + "src/cli/serve.ts");
  const { parseCommand } = await import(app + "src/cli/args.ts");
  const until = async (check, what) => { const end = Date.now() + 10000; while (!await check()) { if (Date.now() > end) throw new Error("timed out waiting for " + what); await Bun.sleep(10); } };
  const alive = pid => { try { process.kill(pid, 0); return true; } catch { return false; } };
  const options = parseServeOptions(parseCommand("serve", ["--isolate", "--port", "0", "--no-open"]));
  options.chatPaths = { sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
  options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
  options.storagePaths = { jobsDb: join(root, "jobs.sqlite"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
  const records = ["org/model", "org/other"].map(id => ({ repoId: id, path: join(root, id.split("/")[1]), modelType: "qwen3", expertsBytes: 0, sizeBytes: 1 }));
  const eventsFile = join(root, "events.jsonl"), lines = [];
  const started = [];
  const start = async env => {
    const running = await startIsolatedServer(records[0], options, { entry: process.env.FAKE_WORKER,
      env: { FAKE_WORKER_EVENTS: eventsFile, MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1", ...env },
      restarts: { max: 1, windowMs: 60_000, delayMs: 0 }, createRegistry: () => ({ listCanonical: () => records, close() {} }),
      notice: line => lines.push(line), log: line => lines.push(line), error: line => lines.push(line) });
    started.push(running);
    return running;
  };
  const events = () => existsSync(eventsFile) ? readFileSync(eventsFile, "utf8").trim().split("\\n").map(line => JSON.parse(line)) : [];
  // The task model's cache: each new revision moves refs/main, the parent's canonical selection, leaving the previous one prunable.
  const repo = join(process.env.HF_HUB_CACHE, "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit");
  const revision = name => {
    mkdirSync(join(repo, "snapshots", name), { recursive: true });
    writeFileSync(join(repo, "snapshots", name, "config.json"), JSON.stringify({ model_type: "gemma4" }));
    writeFileSync(join(repo, "snapshots", name, "model.safetensors"), new Uint8Array(64));
    mkdirSync(join(repo, "refs"), { recursive: true }); writeFileSync(join(repo, "refs", "main"), name);
  };
  const snapshot = name => existsSync(join(repo, "snapshots", name));
  try {
`;
// Every server the script started is closed (idempotently) even when an
// assertion failed, so its workers stop and their sockets are removed.
const memoryCleanup = `
  } finally { for (const running of started) await running.close().catch(() => {}); }
`;
const memoryRequest = (base: string) => `
  const base = ${base};
  const get = (path, init) => fetch(base + path, init);
  const engine = async () => await (await get("/engine")).json();
  const fakeSeen = async () => await (await get("/fake/seen")).json();
  const memoryCalls = async () => (await fakeSeen()).seen.filter(entry => entry.path === "/admin/memory/complete");
`;

test("memory synthesis under isolation: the parent keeps the pipeline and SSE, each stage call or batch runs on the default worker's task model over its private route without a pool lease, a cancelled run aborts the worker's call, a crash fails the call without a replay, and shutdown aborts it", async () => {
  const script = memoryPreamble + `
    const running = await start({});
  ` + memoryRequest(`"http://127.0.0.1:" + running.port`) + `
    const socket = (await engine()).socket;
    // Without a cached task model the parent's selection fails the run; the worker is never called.
    rows = ["alpha"];
    assert.match(await (await get("/v1/memory/synthesize")).text(), /"type":"error","message":"memory: Gemma-4-e4b is not downloaded \\(looked under /);
    assert.deepEqual(await memoryCalls(), []);
    // Ordered raw outputs from the worker's task model; each call carries the parent's selected snapshot; the served model's routes are never called.
    revision("first");
    const selected = join(repo, "snapshots", "first");
    rows = ["alpha", "beta", "gamma"];
    const text = await (await get("/v1/memory/synthesize")).text();
    assert.ok(text.includes(JSON.stringify({ type: "log", message: JSON.stringify(["task entity: alpha", "task entity: beta", "task entity: gamma", "task route: single"]) })), text);
    assert.match(text, /\\[DONE\\]/);
    assert.deepEqual((await memoryCalls()).map(entry => entry.body), [
      { call: "completeBatch", snapshot: selected, requests: rows.map(user => ({ stage: "entity", input: { user }, maxTokens: 8 })) },
      { call: "complete", snapshot: selected, requests: [{ stage: "route", input: { system: "yes or no", user: "single" }, maxTokens: 4 }] }]);
    assert.deepEqual((await (await get("/fake/seen")).json()).seen.filter(entry => entry.method === "POST" && entry.path.startsWith("/v1/")), []);
    // The private route is the worker's socket surface: the parent's TCP listener never forwards it.
    for (const init of [{ method: "POST", body: "{}" }, { method: "GET" }]) assert.equal((await get("/admin/memory/complete", init)).status, 404);
    assert.equal((await memoryCalls()).length, 2);
    // A held call is in flight on the worker, and the parent holds no lease there; cancelling the SSE request aborts it.
    rows = ["hold then cancel"];
    const client = new AbortController();
    // (The SSE response carries no bytes before the pipeline's first event, so the body is read without waiting on it first.)
    const cancelled = get("/v1/memory/synthesize", { signal: client.signal }).then(response => response.text()).catch(error => error.name);
    await until(async () => (await memoryCalls()).length === 3, "the cancelled run's call");
    const health = (await (await get("/health")).json()).engine;
    assert.deepEqual([health.in_flight, health.leases], [1, 0]);
    client.abort();
    assert.equal(await cancelled, "AbortError");
    await until(async () => (await memoryCalls())[2].aborted && events().at(-1).event === "memory aborted", "the worker to see the cancellation");
    // A worker that dies under a call fails the run; the respawned worker never sees the call again.
    const crashed = (await engine()).pid;
    rows = ["crash now"];
    const failed = await (await get("/v1/memory/synthesize")).text();
    assert.match(failed, /"type":"error","message":"memory: the model worker did not complete the task model completeBatch \\(.+\\); it is not retried"/);
    assert.ok(!failed.includes("[DONE]"));
    await until(async () => { const report = await engine(); return report.state === "ready" && report.pid !== crashed; }, "the respawn");
    assert.deepEqual(await memoryCalls(), []);
    assert.equal(events().filter(item => item.pid === crashed && item.event === "memory").length, 4);
    // Parent shutdown mid-call aborts it on the worker, which joins it before it stops.
    const respawned = (await engine()).pid;
    rows = ["hold through shutdown"];
    const interrupted = get("/v1/memory/synthesize").then(response => response.text());
    await until(async () => (await memoryCalls()).length === 1, "the call before shutdown");
    await running.close();
    assert.ok(!(await interrupted).includes("[DONE]"));
    const last = events().filter(item => item.pid === respawned).map(item => item.event).filter(event => event !== "loading" && event !== "ready");
    assert.deepEqual(last.filter(event => event !== "drain"), ["memory", "memory aborted", "stop"]);
    assert.ok(last.includes("drain"));
    assert.ok(!existsSync(dirname(socket)), "the socket directory is removed");
    assert.ok(!alive(respawned), "the worker has exited");
    assert.ok(lines.some(line => line.includes("exited with code 137 — respawning (restart 1/1)")), lines.join("\\n"));
  ` + memoryCleanup;
  const home = mkdtempSync(join(tmpdir(), "mlx-isolated-memory-"));
  const before = workerDirs();
  try {
    const result = await runChild(script, { HOME: home, HF_HUB_CACHE: `${home}/hub`, HF_TOKEN: "", FAKE_WORKER: entry });
    expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
    expect(workerDirs()).toBe(before);
  } finally { rmSync(home, { recursive: true, force: true }); }
}, 40_000);

test("the task model snapshot the parent selects for a worker, the one that worker loads, stays out of hub GC for the worker's lifetime: through a canonical change before the load, idle after calls, after a client disconnect before the worker's join, and through eviction, until the worker has closed", async () => {
  const script = memoryPreamble + `
    revision("first");
    // Worker stops take a while, so an evicted worker is observably draining; an aborted call joins late.
    const running = await start({ FAKE_WORKER_STOP_MS: "1000", FAKE_WORKER_MEMORY_JOIN_MS: "300" });
  ` + memoryRequest(`"http://127.0.0.1:" + running.port`) + `
    const gc = async () => { const response = await get("/api/gc/execute", { method: "POST", body: JSON.stringify({ yes: true }) }); return [response.status, (await response.json()).snapshots]; };
    // The parent selects "first" and the worker holds the call before its load; a new revision moves the canonical selection meanwhile.
    rows = ["hold before the load"];
    const loading = get("/v1/memory/synthesize").then(response => response.text());
    await until(async () => (await memoryCalls()).length === 1, "the held call");
    revision("second");
    assert.deepEqual(await gc(), [409, undefined]);
    assert.deepEqual(await (await get("/fake/memory/release")).json(), { released: 1 });
    assert.match(await loading, /\\[DONE\\]/);
    // The worker loaded the snapshot the call carried, not the new canonical one, and it stays protected while the worker idles.
    assert.equal((await fakeSeen()).task_snapshot, join(repo, "snapshots", "first"));
    assert.deepEqual((await memoryCalls()).map(entry => entry.body.snapshot), [join(repo, "snapshots", "first"), join(repo, "snapshots", "second")]);
    assert.deepEqual(await gc(), [409, undefined]);
    assert.ok(snapshot("first"));
    // Eviction: another exact id at cap 1 replaces the default worker; its snapshots stay protected while it drains and stops.
    const evicted = (await engine()).pid;
    const other = await get("/v1/chat/completions", { method: "POST", body: JSON.stringify({ model: "org/other", messages: [{ role: "user", content: "hi" }] }) });
    assert.equal((await other.json()).model, "org/other");
    assert.ok(alive(evicted));
    assert.deepEqual(await gc(), [409, undefined]);
    assert.ok(alive(evicted) && snapshot("first"));
    // Once that worker has closed, GC prunes the snapshot it had loaded.
    await until(() => !alive(evicted), "the evicted worker to exit");
    let pruned;
    await until(async () => (pruned = await gc())[0] === 200, "GC after the worker closed");
    assert.deepEqual(pruned, [200, 1]);
    assert.ok(!snapshot("first") && snapshot("second"));
    // A client disconnect: the call reaches a respawned default worker with "second" selected; the client leaves before the worker's join.
    rows = ["hold then cancel"];
    const client = new AbortController();
    const cancelled = get("/v1/memory/synthesize", { signal: client.signal }).then(response => response.text()).catch(error => error.name);
    await until(async () => (await engine()).state === "ready" && (await memoryCalls()).length === 1, "the respawned default worker's call");
    const respawned = (await engine()).pid;
    assert.notEqual(respawned, evicted);
    assert.equal((await memoryCalls())[0].body.snapshot, join(repo, "snapshots", "second"));
    client.abort();
    assert.equal(await cancelled, "AbortError");
    revision("third");
    assert.deepEqual(await gc(), [409, undefined]);
    assert.ok(!events().some(item => item.pid === respawned && item.event === "memory aborted"), "the worker has not joined the call yet");
    await until(() => events().some(item => item.pid === respawned && item.event === "memory aborted"), "the worker's join");
    assert.deepEqual(await gc(), [409, undefined]);
    assert.ok(snapshot("second"));
    await running.close();
    assert.ok(!alive(respawned));
  ` + memoryCleanup;
  const home = mkdtempSync(join(tmpdir(), "mlx-isolated-memory-gc-"));
  const before = workerDirs();
  try {
    const result = await runChild(script, { HOME: home, HF_HUB_CACHE: `${home}/hub`, HF_TOKEN: "", FAKE_WORKER: entry });
    expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
    expect(workerDirs()).toBe(before);
  } finally { rmSync(home, { recursive: true, force: true }); }
}, 40_000);

function openChat(base: URL) {
  const frames: ServerMessage[] = [];
  const observers = new Set<() => void>();
  const closed = Promise.withResolvers<void>();
  const socket = new WebSocket(new URL("/ws/chat", base).href.replace("http:", "ws:"));
  socket.addEventListener("message", event => { frames.push(JSON.parse(String(event.data)) as ServerMessage); for (const observer of [...observers]) observer(); });
  socket.addEventListener("close", () => closed.resolve());
  const turns = () => frames.filter(frame => frame.type === "turn_end").length;
  return {
    frames, turns,
    send: (message: ClientMessage) => socket.send(JSON.stringify(message)),
    waitFor: (predicate: () => boolean, what: string, timeoutMs = 15_000) => new Promise<void>((resolve, reject) => {
      const timer = setTimeout(() => { observers.delete(check); reject(new Error(`timed out waiting for ${what}`)); }, timeoutMs);
      const check = () => { if (predicate()) { clearTimeout(timer); observers.delete(check); resolve(); } };
      observers.add(check); check();
    }),
    /** The assistant text of the turn that ended `n`th (1-based). */
    text: (n: number) => {
      let ended = 0;
      const deltas: string[] = [];
      for (const frame of frames) {
        if (frame.type === "turn_end") ended++;
        else if (ended === n - 1 && frame.type === "text_delta") deltas.push(frame.delta);
      }
      return deltas.join("");
    },
    close: async () => { socket.close(1000, "done"); await closed.promise; },
  };
}

test("web chat under isolation: Pi lives in the parent and streams through the proxy, a stop cancels the worker's request, and a crash ends the turn with an error before the worker respawns", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-isolated-chat-"));
  const cwd = join(root, "project"), agentDir = join(root, "agent");
  mkdirSync(cwd); mkdirSync(agentDir);
  const options = parseServeOptions(parseCommand("serve", ["--isolate", "--port", "0", "--no-open", "--temperature", "0"]));
  options.chatPaths = { cwd, agentDir, sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
  options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
  options.storagePaths = { jobsDb: join(root, "jobs.sqlite"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
  const notices: string[] = [], workerLog: string[] = [];
  const before = workerDirs();
  const running = await startIsolatedServer(model(root), options, { entry, env: workerEnv, restarts: { max: 2, windowMs: 60_000, delayMs: 0 },
    notice: line => notices.push(line), log: line => workerLog.push(line), error: line => workerLog.push(line) });
  const base = new URL(`http://127.0.0.1:${running.port}`);
  const engine = async () => await (await fetch(new URL("/engine", base))).json() as { state: string; pid: number | null; restarts: number };
  const seen = async () => await (await fetch(new URL("/fake/seen", base))).json() as { pid: number; seen: { path: string; aborted: boolean; body?: unknown }[] };
  const socket = (await engine() as unknown as { socket: string }).socket;
  const chat = openChat(base);
  try {
    // The ready frame describes the worker's model through the proxy: capabilities and defaults from /v1/models, the option's temperature on top.
    await chat.waitFor(() => chat.frames.some(frame => frame.type === "ready"), "ready");
    expect(chat.frames.find(frame => frame.type === "ready")).toEqual({ type: "ready", model: "org/model", vision: false, audio: false, thinking: false,
      genDefaults: { temperature: 0, topP: 0.9, topK: null }, transcription: false });
    chat.send({ type: "prompt", text: "hello" });
    await chat.waitFor(() => chat.turns() === 1, "the first turn");
    expect(chat.text(1)).toBe("Hello from the worker.");
    expect(chat.frames.filter(frame => frame.type === "error")).toEqual([]);
    const first = await seen();
    expect(first.seen.find(entry => entry.path === "/v1/chat/completions")!.body).toMatchObject({ model: "local", stream: true });
    // Stop: the turn ends and the worker sees its request aborted.
    chat.send({ type: "prompt", text: "please hang" });
    await chat.waitFor(() => chat.frames.some(frame => frame.type === "text_delta" && frame.delta === "partial"), "the hanging turn's first delta");
    chat.send({ type: "abort" });
    await chat.waitFor(() => chat.turns() === 2, "the stopped turn");
    await until(async () => (await seen()).seen.some(entry => JSON.stringify(entry.body ?? "").includes("please hang") && entry.aborted), "the worker to see the abort");
    expect((await engine()).state).toBe("ready");
    // Crash mid-turn: the browser gets the cause as an error and the turn ends; nothing is replayed; the worker respawns.
    const crashed = first.pid;
    chat.send({ type: "prompt", text: "crash now" });
    await chat.waitFor(() => chat.turns() === 3, "the crashed turn");
    const failure = chat.frames.find(frame => frame.type === "error") as { message: string } | undefined;
    expect(failure?.message).toMatch(/^inference engine unavailable: the engine worker stopped while streaming this response(?: \(the worker exited with code 137\))?; it is being respawned$/);
    expect(chat.text(3)).toBe("partial");
    await until(async () => { const report = await engine(); return report.state === "ready" && report.pid !== crashed; }, "the respawn");
    expect((await engine()).restarts).toBe(1);
    expect(notices.some(line => line.includes("exited with code 137 — respawning (restart 1/2)"))).toBe(true);
    const respawned = await seen();
    expect(respawned.pid).not.toBe(crashed);
    expect(respawned.seen.filter(entry => entry.path === "/v1/chat/completions")).toEqual([]);
    // The same connection keeps working against the new worker.
    chat.send({ type: "prompt", text: "hello again" });
    await chat.waitFor(() => chat.turns() === 4, "the turn after the respawn");
    expect(chat.text(4)).toBe("Hello from the worker.");
    expect(chat.frames.filter(frame => frame.type === "error")).toHaveLength(1);
    expect(existsSync(join(root, "sessions"))).toBe(true);
    expect(workerLog).toEqual(["loading org/model", "loading org/model"]);
  } finally {
    await chat.close();
    await running.close();
    rmSync(root, { recursive: true, force: true });
  }
  expect(workerLog.slice(2)).toEqual(["drain requested", "stopping"]);
  expect(existsSync(dirname(socket))).toBe(false);
  expect(workerDirs()).toBe(before);
}, 40_000);

test("the model pool through the real composition: exact ids reach their own workers on sockets in the same private directory, the least recently used is evicted at the cap and respawned when named again, and shutdown joins every worker", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-isolated-pool-"));
  const options = parseServeOptions(parseCommand("serve", ["--isolate", "--model-pool", "2", "--port", "0", "--no-open"]));
  options.chatPaths = { cwd: root, agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
  options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
  options.storagePaths = { jobsDb: join(root, "jobs.sqlite"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
  const records = ["org/model", "org/second", "org/third"].map(id => ({ ...model(root), repoId: id, path: join(root, id.split("/")[1]!) }) as ModelRecord);
  const notices: string[] = [], workerLog: string[] = [];
  const before = workerDirs();
  const running = await startIsolatedServer(records[0]!, options, { entry, env: workerEnv, restarts: { max: 1, windowMs: 60_000, delayMs: 0 },
    createRegistry: () => ({ listCanonical: () => records, close() {} }),
    notice: line => notices.push(line), log: line => workerLog.push(line), error: line => workerLog.push(line) });
  const base = `http://127.0.0.1:${running.port}`;
  const chat = async (model?: string) => {
    const response = await fetch(`${base}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ ...(model ? { model } : {}), messages: [{ role: "user", content: "hi" }] }) });
    return (await response.json() as { model: string }).model;
  };
  const engine = async () => await (await fetch(`${base}/engine`)).json() as { state: string; pid: number | null; socket: string | null;
    pool: { cap: number; default: string; resident: { id: string; pid: number | null; state: string; restarts: number; socket: string }[]; loading: string[] } };
  const pids: number[] = [];
  let socketDir = "";
  try {
    const first = await engine();
    pids.push(first.pid!);
    socketDir = dirname(first.socket!);
    expect(first.pool).toEqual({ cap: 2, default: "org/model", resident: [{ id: "org/model", pid: first.pid, state: "ready", restarts: 0, socket: first.socket! }], loading: [] });
    // Two turns to two ids reach two workers.
    expect(await chat("org/model")).toBe("org/model");
    expect(await chat("org/second")).toBe("org/second");
    const two = await engine();
    expect(two.pool.resident.map(worker => worker.id)).toEqual(["org/model", "org/second"]);
    expect(two.pool.resident.map(worker => dirname(worker.socket))).toEqual([socketDir, socketDir]);
    pids.push(two.pool.resident[1]!.pid!);
    expect(new Set(pids).size).toBe(2);
    expect(notices).toContain(`engine worker pid ${pids[1]} ready for org/second (socket ${two.pool.resident[1]!.socket})`);
    expect(await (await fetch(`${base}/v1/models`)).json()).toMatchObject({ data: [{ id: "org/model", resident: true }, { id: "org/second", resident: true }] });
    // A third id evicts the least recently used (the default): its worker drains and stops, the parent's default fields go null, an empty model field brings it back.
    expect(await chat("org/third")).toBe("org/third");
    const three = await engine();
    expect([three.state, three.pid, three.socket, three.pool.resident.map(worker => worker.id), three.pool.loading]).toEqual(["evicted", null, null, ["org/second", "org/third"], []]);
    pids.push(three.pool.resident[1]!.pid!);
    await until(() => !alive(pids[0]!), "the evicted default worker to exit");
    expect(notices).toContain("evicting org/model (pool cap 2): draining, then stopping");
    expect(await (await fetch(`${base}/health`)).json()).toMatchObject({ engine: { state: "evicted", pid: null }, pool: { cap: 2, default: "org/model", resident: ["org/second", "org/third"], loading: [] } });
    expect(await chat()).toBe("org/model");
    const back = await engine();
    expect([back.state, back.pool.resident.map(worker => worker.id)]).toEqual(["ready", ["org/third", "org/model"]]);
    pids.push(back.pid!);
    expect(new Set(pids).size).toBe(4);
  } finally {
    await running.close();
    rmSync(root, { recursive: true, force: true });
  }
  for (const pid of pids) expect(alive(pid)).toBe(false);
  expect(existsSync(socketDir)).toBe(false);
  expect(workerDirs()).toBe(before);
  expect(workerLog.filter(line => line.startsWith("loading"))).toEqual(["loading org/model", "loading org/second", "loading org/third", "loading org/model"]);
  expect(workerLog.filter(line => line === "drain requested")).toHaveLength(4);
}, 40_000);
