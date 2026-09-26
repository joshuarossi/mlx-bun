import { expect, test } from "bun:test";
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

async function runChild(script: string, env: Record<string, string> = {}) {
  const child = Bun.spawn([process.execPath, "--eval", script], { stdout: "pipe", stderr: "pipe", cwd: app,
    env: { ...process.env, ...workerEnv, ...env } });
  const [code, stdout, stderr] = await Promise.all([child.exited, new Response(child.stdout).text(), new Response(child.stderr).text()]);
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
    const { decodeLaunch, encodeLaunch } = await import(app + "src/jobs/worker-process.ts");
    const options = parseServeOptions(parseCommand("serve", ["--isolate", "--port", "0", "--ssd-cache", join(root, "ssd"), "--ssd-cache-max", "0", "--temperature", "0.3", "--no-open"]));
    options.chatPaths = { sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
    options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
    options.storagePaths = { jobsDb: join(root, "store", "jobs.sqlite"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
    const model = { repoId: "org/model", path: join(root, "model"), modelType: "qwen3", expertsBytes: 0, sizeBytes: 1 };
    const record = join(root, "launches.jsonl");
    const notices = [];
    const env = { FAKE_WORKER_RECORD: record, MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1" };
    const running = await startIsolatedServer(model, options, { entry: process.env.FAKE_WORKER, env, restarts: { max: 1, windowMs: 60_000, delayMs: 0 }, notice: line => notices.push(line) });
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
    const base = "http://127.0.0.1:" + running.port;
    const get = (path, init) => fetch(base + path, init);
    // The parent's own answers.
    assert.equal(await (await get("/")).text(), "web");
    const engine = await (await get("/engine")).json();
    assert.deepEqual([engine.isolated, engine.state, engine.pid, engine.restarts, engine.model, engine.socket, engine.last_exit], [true, "ready", launches[0].pid, 0, "org/model", launch.socketPath, null]);
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
    const stats = await (await get("/stats")).json();
    assert.deepEqual(stats.response_store, { entries: 0, bytes: 0, max_bytes: 32 * 1024 * 1024, ttl_ms: 3_600_000 });
    assert.deepEqual([stats.server.model, stats.admission.enforced_context_tokens, stats.engine.state], ["org/model", 2048, "ready"]);
    // Model-scoped routes reach the worker.
    assert.equal((await (await get("/v1/models")).json()).data[0].id, "org/model");
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
