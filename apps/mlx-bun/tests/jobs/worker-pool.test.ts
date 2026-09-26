import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, readdirSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { createWorkerPool } from "../../src/jobs/worker-pool";
import { EngineUnavailableError, superviseWorker, type WorkerSupervisor } from "../../src/jobs/worker-supervisor";
import { WorkerExitedError } from "../../src/jobs/worker-process";

// The exact-id LRU pool over real supervisors and the fake worker
// (tests/fake-worker.ts) on Unix sockets: routing, spawn on first use,
// serialized cold starts overlapping the serving worker, LRU eviction that
// drains before it stops, respawn on switch-back, invalidation fan-out, job
// leases spanning every resident worker, and close joining everything.
const entry = new URL("../fake-worker.ts", import.meta.url).pathname;
const env = { MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1" };
const record = (id: string) => ({ repoId: id, path: `/models/${id}`, modelType: "qwen3", expertsBytes: 0, sizeBytes: 1 }) as ModelRecord;
const options = { query: null, hostname: "127.0.0.1", port: 0, capacity: 8, contextLimit: null, readOnly: false, noOpen: true, request: {}, cache: { kvQuant: "off" } };

async function until(check: () => boolean | Promise<boolean>, what: string, timeoutMs = 5_000) {
  const end = Date.now() + timeoutMs;
  while (!await check()) { if (Date.now() > end) throw new Error(`timed out waiting for ${what}`); await Bun.sleep(5); }
}
function fixture(cap: number, extra: { env?: Record<string, string>; restarts?: { max: number; windowMs: number; delayMs?: number } } = {}) {
  const dir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  const events = join(dir, "events.jsonl");
  const notices: string[] = [], logs: string[] = [], errors: string[] = [], resolutions: string[] = [];
  const known = new Set(["org/a", "org/b", "org/c", "org/d"]);
  const pool = createWorkerPool({ cap, defaultModel: record("org/a"), aliases: ["local"],
    resolve: id => { resolutions.push(id); return known.has(id) ? record(id) : null; },
    socketFor: index => join(dir, index === 0 ? "engine.sock" : `engine-${index}.sock`),
    supervise: (model, socketPath) => superviseWorker({ entry, socketPath, launch: { socketPath, model, options },
      env: { ...env, FAKE_WORKER_EVENTS: events, ...extra.env }, graceMs: 500, restarts: extra.restarts ?? { max: 2, windowMs: 60_000, delayMs: 0 },
      notice: line => notices.push(`${model.repoId}: ${line}`), log: line => logs.push(`${model.repoId}: ${line}`), error: line => errors.push(`${model.repoId}: ${line}`) }),
    notice: line => notices.push(line) });
  const ask = async (model?: string, signal?: AbortSignal) => {
    const engine = await pool.workerFor(model, signal);
    const response = await engine.fetch("http://engine/v1/chat/completions", { method: "POST", body: JSON.stringify({ model, messages: [{ role: "user", content: "hi" }] }) });
    return (await response.json() as { model: string }).model;
  };
  const health = async (engine: WorkerSupervisor) => await (await engine.fetch("http://engine/health")).json() as { pid: number; leases: number; state: string; model: string };
  const seen = async (engine: WorkerSupervisor) => await (await engine.fetch("http://engine/fake/seen")).json() as { model: string; seen: { path: string }[] };
  const timeline = () => existsSync(events) ? readFileSync(events, "utf8").trim().split("\n").filter(Boolean)
    .map(line => JSON.parse(line) as { event: string; model: string; pid: number; at: number }) : [];
  const ids = () => pool.report().resident.map(worker => worker.id);
  const sockets = () => readdirSync(dir).filter(name => name.endsWith(".sock")).sort();
  return { dir, pool, notices, logs, errors, resolutions, ask, health, seen, timeline, ids, sockets, remove: () => rmSync(dir, { recursive: true, force: true }) };
}
const alive = (pid: number) => { try { process.kill(pid, 0); return true; } catch { return false; } };
const rejection = (work: Promise<unknown>) => work.then(() => { throw new Error("must reject"); }, (error: unknown) => error);

test("exact ids get their own worker on first use while the default keeps serving; anything else rides the default; over the cap the least recently used worker is drained, stopped, and respawned when named again", async () => {
  const fake = fixture(2);
  const { pool } = fake;
  try {
    expect(pool.report()).toEqual({ cap: 2, default: "org/a", resident: [], loading: ["org/a"] });
    expect(pool.default?.state).toBe("starting");
    expect(pool.worker("org/a")).toBe(pool.default);
    expect(pool.inspect()).toBe(pool.default);
    const a = await pool.ready;
    const aPid = a.pid!;
    expect(a.modelId).toBe("org/a");
    expect(pool.report()).toEqual({ cap: 2, default: "org/a", resident: [{ id: "org/a", pid: aPid, state: "ready", restarts: 0, socket: join(fake.dir, "engine.sock") }], loading: [] });
    expect(pool.servedPaths()).toEqual(["/models/org/a"]);
    // Empty, the alias, a fuzzy name, and the default's own id all ride the default; a miss is resolved once until the library changes.
    expect(await fake.ask()).toBe("org/a");
    expect(await fake.ask("local")).toBe("org/a");
    expect(await fake.ask("gpt-4")).toBe("org/a");
    expect(await fake.ask("gpt-4")).toBe("org/a");
    expect(await fake.ask("org/a")).toBe("org/a");
    expect(await pool.workerFor("")).toBe(a);
    expect(fake.resolutions).toEqual(["gpt-4"]);
    // An exact id spawns its worker on its own socket; the default is untouched and the new worker is the most recently used.
    expect(await fake.ask("org/b")).toBe("org/b");
    const b = pool.worker("org/b")!;
    expect(b).not.toBe(a);
    expect(b.socketPath).toBe(join(fake.dir, "engine-1.sock"));
    expect(fake.ids()).toEqual(["org/a", "org/b"]);
    expect(pool.residents().map(worker => [worker.id, worker.model.path, worker.engine])).toEqual([["org/a", "/models/org/a", a], ["org/b", "/models/org/b", b]]);
    expect(fake.sockets()).toEqual(["engine-1.sock", "engine.sock"]);
    expect(fake.notices).toEqual([`loading org/b on a new worker (socket ${b.socketPath})`, `engine worker pid ${b.pid} ready for org/b (socket ${b.socketPath})`]);
    // Using the default again makes b the least recently used; a third id evicts b: deregistered at once, drained, then stopped.
    expect(await fake.ask("org/a")).toBe("org/a");
    expect(fake.ids()).toEqual(["org/b", "org/a"]);
    const bPid = b.pid!;
    expect(await fake.ask("org/c")).toBe("org/c");
    expect(fake.ids()).toEqual(["org/a", "org/c"]);
    expect(pool.worker("org/b")).toBeUndefined();
    expect(fake.notices).toContain("evicting org/b (pool cap 2): draining, then stopping");
    await until(() => !alive(bPid), "the evicted worker to exit");
    expect(fake.errors.filter(line => line.startsWith("org/b:"))).toEqual(["org/b: drain requested", "org/b: stopping"]);
    expect(fake.timeline().filter(item => item.model === "org/b").map(item => item.event)).toEqual(["loading", "ready", "drain", "stop"]);
    expect(pool.servedPaths().sort()).toEqual(["/models/org/a", "/models/org/c"]);
    expect(fake.sockets()).toEqual(["engine-2.sock", "engine.sock"]);
    // Library invalidation reaches every serving worker and forgets the misses.
    pool.invalidateLibrary();
    const c = pool.worker("org/c")!;
    await until(async () => (await fake.seen(a)).seen.some(item => item.path === "/library") && (await fake.seen(c)).seen.some(item => item.path === "/library"), "the refresh on both workers");
    expect(await fake.ask("gpt-4")).toBe("org/a");
    expect(fake.resolutions).toEqual(["gpt-4", "org/b", "org/c", "gpt-4"]);
    // Naming b again respawns it on a fresh worker; c, least recently used since the default answered, goes.
    expect(await fake.ask("org/b")).toBe("org/b");
    expect(pool.worker("org/b")).not.toBe(b);
    expect(fake.ids()).toEqual(["org/a", "org/b"]);
    // The default is not pinned: once least recently used it is evicted like any other, and the pool has no default until it is named.
    expect(await fake.ask("org/c")).toBe("org/c");
    expect(fake.ids()).toEqual(["org/b", "org/c"]);
    expect(pool.default).toBeUndefined();
    expect(pool.inspect()).toBe(pool.worker("org/c"));
    await until(() => !alive(aPid), "the evicted default to exit");
    // An empty model field brings the default back on a new worker.
    expect(await fake.ask()).toBe("org/a");
    expect(fake.ids()).toEqual(["org/c", "org/a"]);
    expect(pool.default).toBe(pool.worker("org/a"));
    expect(pool.default).not.toBe(a);
    expect(pool.inspect()).toBe(pool.default);
    expect(fake.logs).toEqual(["org/a: loading org/a", "org/b: loading org/b", "org/c: loading org/c", "org/b: loading org/b", "org/c: loading org/c", "org/a: loading org/a"]);
  } finally { await pool.close(); fake.remove(); }
});

test("cold starts run one at a time while the serving worker keeps answering; a waiter that leaves does not cancel a load; a failed cold start fails its request and leaves the pool as it was", async () => {
  const fake = fixture(4, { env: { FAKE_WORKER_LOAD_MS: "400", FAKE_WORKER_FAIL_MODEL: "org/d" } });
  const { pool } = fake;
  try {
    await pool.ready;
    const started = Date.now();
    const b = pool.workerFor("org/b"), c = pool.workerFor("org/c");
    expect(pool.report().loading).toEqual(["org/b", "org/c"]);
    // Spawn-overlap: the default answers while b loads.
    expect(await fake.ask()).toBe("org/a");
    expect(Date.now() - started).toBeLessThan(350);
    expect(pool.report().loading).toEqual(["org/b", "org/c"]);
    const gone = new AbortController();
    const abandoned = rejection(pool.workerFor("org/c", gone.signal));
    gone.abort(new Error("client left"));
    expect(((await abandoned) as Error).message).toBe("client left");
    expect((await b).modelId).toBe("org/b");
    const bReady = Date.now() - started;
    expect(bReady).toBeGreaterThanOrEqual(400);
    expect(pool.report().loading).toEqual(["org/c"]);
    expect((await c).modelId).toBe("org/c");
    expect(Date.now() - started).toBeGreaterThanOrEqual(bReady + 400);
    const timeline = fake.timeline();
    const at = (model: string, event: string) => timeline.find(item => item.model === model && item.event === event)!.at;
    expect(at("org/c", "loading")).toBeGreaterThanOrEqual(at("org/b", "ready"));
    expect(fake.ids()).toEqual(["org/a", "org/b", "org/c"]);
    // The failed load fails the request with the worker's exit, is not retried, and changes nothing.
    const failure = await rejection(fake.ask("org/d"));
    expect(failure).toBeInstanceOf(WorkerExitedError);
    expect((failure as Error).message).toBe("worker exited with code 1 before ready");
    expect(fake.notices.at(-1)).toBe("org/d did not load: worker exited with code 1 before ready");
    expect([fake.ids(), pool.report().loading, pool.worker("org/d")]).toEqual([["org/a", "org/b", "org/c"], [], undefined]);
    expect(fake.errors.filter(line => line.startsWith("org/d:"))).toEqual(["org/d: worker startup failed: fake load failure"]);
    expect(fake.sockets()).toEqual(["engine-1.sock", "engine-2.sock", "engine.sock"]);
    await expect(fake.ask("org/d")).rejects.toBeInstanceOf(WorkerExitedError);
    expect(pool.servedPaths().sort()).toEqual(["/models/org/a", "/models/org/b", "/models/org/c"]);
  } finally { await pool.close(); fake.remove(); }
});

test("a managed job leases every resident worker, holds back cold starts and respawns until disposal, and joins draining evictions first", async () => {
  const fake = fixture(3, { restarts: { max: 3, windowMs: 60_000, delayMs: 50 } });
  const { pool } = fake;
  try {
    const a = await pool.ready;
    const b = await pool.workerFor("org/b");
    const lease = await pool.acquireExecutionLease(new AbortController().signal);
    expect([(await fake.health(a)).leases, (await fake.health(b)).leases]).toEqual([1, 1]);
    // A cold start would touch the GPU while loading: it must not spawn at all.
    const pendingC = pool.workerFor("org/c");
    await Bun.sleep(50);
    expect(pool.worker("org/c")).toBeUndefined();
    expect(pool.servedPaths()).toContain("/models/org/c");
    expect(fake.timeline().some(item => item.model === "org/c")).toBe(false);
    // A crashed worker's respawn waits for the job's release, as with one worker.
    process.kill(b.pid!, "SIGKILL");
    await until(() => b.state === "restarting", "the exit");
    await Bun.sleep(150);
    expect([b.state, b.pid]).toEqual(["restarting", null]);
    lease.dispose(); lease.dispose();
    const c = await pendingC;
    await until(() => b.state === "ready", "the respawn after release");
    await until(async () => (await fake.health(a)).leases === 0 && (await fake.health(b)).leases === 0 && (await fake.health(c)).leases === 0, "every lease released");
    // A lease abandoned while a worker is down holds nothing anywhere.
    process.kill(b.pid!, "SIGKILL");
    await until(() => b.state === "restarting", "the second exit");
    const abandoned = new AbortController();
    const waiting = rejection(pool.acquireExecutionLease(abandoned.signal));
    abandoned.abort(new Error("job cancelled"));
    expect(((await waiting) as Error).message).toBe("job cancelled");
    await until(() => b.state === "ready", "the third worker");
    expect([(await fake.health(a)).leases, (await fake.health(b)).leases, (await fake.health(c)).leases]).toEqual([0, 0, 0]);
  } finally { await pool.close(); fake.remove(); }
  // A lease taken right after a switch resolves once the evicted worker has drained and stopped.
  const one = fixture(1);
  try {
    const aPid = (await one.pool.ready).pid!;
    expect(await one.ask("org/b")).toBe("org/b");
    expect(one.ids()).toEqual(["org/b"]);
    const lease = await one.pool.acquireExecutionLease(new AbortController().signal);
    expect(alive(aPid)).toBe(false);
    expect(one.errors.filter(line => line.startsWith("org/a:"))).toEqual(["org/a: drain requested", "org/a: stopping"]);
    expect((await one.health(one.pool.worker("org/b")!)).leases).toBe(1);
    lease.dispose();
  } finally { await one.pool.close(); one.remove(); }
});

test("close joins resident, loading, and evicting workers, refuses later routing, and leaves no process or socket", async () => {
  const fake = fixture(1, { env: { FAKE_WORKER_LOAD_MS: "300" } });
  const { pool } = fake;
  try {
    const aPid = (await pool.ready).pid!;
    const b = pool.workerFor("org/b");
    void b.catch(() => {});
    await until(() => pool.worker("org/b") !== undefined, "b's worker");
    const bPid = pool.worker("org/b")!.pid!;
    await pool.close();
    const failure = await rejection(b);
    expect(failure instanceof EngineUnavailableError || failure instanceof WorkerExitedError).toBe(true);
    await expect(pool.workerFor(undefined)).rejects.toThrow("the server is shutting down");
    expect([alive(aPid), alive(bPid)]).toEqual([false, false]);
    expect(fake.sockets()).toEqual([]);
    expect(pool.report()).toEqual({ cap: 1, default: "org/a", resident: [], loading: [] });
    expect(pool.default).toBeUndefined();
    await pool.close();
  } finally { await pool.close(); fake.remove(); }
  // Closing during an eviction joins the draining worker.
  const switching = fixture(1);
  try {
    const aPid = (await switching.pool.ready).pid!;
    expect(await switching.ask("org/b")).toBe("org/b");
    const bPid = switching.pool.worker("org/b")!.pid!;
    await switching.pool.close();
    expect([alive(aPid), alive(bPid)]).toEqual([false, false]);
    expect(switching.errors.filter(line => line.startsWith("org/a:"))).toEqual(["org/a: drain requested", "org/a: stopping"]);
    expect(switching.errors.filter(line => line.startsWith("org/b:"))).toEqual(["org/b: drain requested", "org/b: stopping"]);
    expect(switching.sockets()).toEqual([]);
  } finally { await switching.pool.close(); switching.remove(); }
});

// Deferred supervisors make load, lease, and drain boundaries deterministic.
// The socket tests above separately exercise the real supervisor protocol.
function controlledPool(cap = 2) {
  const workers = new Map<string, ReturnType<typeof controlledWorker>>();
  const pool = createWorkerPool({ cap, defaultModel: record("org/a"), resolve: id => record(id),
    socketFor: index => `/fake/worker-${index}.sock`, notice() {},
    supervise(model, socketPath) { const worker = controlledWorker(model.repoId, socketPath); workers.set(model.repoId, worker); return worker.engine; } });
  return { pool, workers };
}
function controlledWorker(modelId: string, socketPath: string) {
  const ready = Promise.withResolvers<{ socketPath: string; modelId: string }>();
  const stopped = Promise.withResolvers<void>();
  const lease = Promise.withResolvers<{ dispose(): void }>();
  let state: WorkerSupervisor["state"] = "starting", closeStarted = false, leases = 0, releases = 0;
  let deferClose = false, deferLease = false;
  const engine: WorkerSupervisor = {
    get state() { return state; }, pid: 1, socketPath, modelId, restarts: 0, lastExit: null,
    budget: { max: 2, windowMs: 60_000 }, ready: ready.promise,
    whenReady: async () => { await ready.promise; }, fetch: async () => new Response("{}"), drain: async () => {},
    acquireExecutionLease: async () => { leases++; return deferLease ? lease.promise : { dispose() { releases++; } }; },
    close() { closeStarted = true; state = "closed"; ready.reject(new EngineUnavailableError("closed", null)); if (!deferClose) stopped.resolve(); return stopped.promise; },
  };
  return { engine, get closeStarted() { return closeStarted; }, get leases() { return leases; }, get releases() { return releases; },
    load() { state = "ready"; ready.resolve({ modelId, socketPath }); },
    holdClose() { deferClose = true; }, stop: () => stopped.resolve(),
    holdLease() { deferLease = true; }, releaseLease() { lease.resolve({ dispose() { releases++; } }); },
    failLease(error: Error) { lease.reject(error); } };
}

const turn = () => Bun.sleep(0);

test("job admission joins the active load, covers it, and leaves queued cold starts blocked until disposal", async () => {
  const { pool, workers } = controlledPool(3);
  try {
    workers.get("org/a")!.load(); await pool.ready; await turn();
    const loadingB = pool.workerFor("org/b");
    const loadingC = pool.workerFor("org/c");
    let admitted = false;
    const pendingLease = pool.acquireExecutionLease(new AbortController().signal).then(lease => { admitted = true; return lease; });
    await turn();
    expect(admitted).toBe(false);
    expect(workers.get("org/c")).toBeUndefined();
    workers.get("org/b")!.load(); await loadingB;
    const lease = await pendingLease;
    expect([workers.get("org/a")!.leases, workers.get("org/b")!.leases]).toEqual([1, 1]);
    expect(workers.get("org/c")).toBeUndefined();
    lease.dispose();
    await turn();
    workers.get("org/c")!.load(); await loadingC;
    expect([workers.get("org/a")!.releases, workers.get("org/b")!.releases]).toEqual([1, 1]);
  } finally { await pool.close(); }
});

test("GC retains an evicting snapshot until drain ends, and job cancellation does not wait for that drain", async () => {
  const { pool, workers } = controlledPool(1);
  const a = workers.get("org/a")!;
  try {
    a.load(); await pool.ready; await turn(); a.holdClose();
    const loading = pool.workerFor("org/b"); workers.get("org/b")!.load(); await loading;
    expect(a.closeStarted).toBe(true);
    expect(pool.servedPaths().sort()).toEqual(["/models/org/a", "/models/org/b"]);
    const controller = new AbortController();
    const lease = rejection(pool.acquireExecutionLease(controller.signal));
    controller.abort(new Error("cancelled while draining"));
    expect((await lease as Error).message).toBe("cancelled while draining");
    a.stop(); await turn();
    expect(pool.servedPaths()).toEqual(["/models/org/b"]);
  } finally { a.stop(); await pool.close(); }
});

test("failed pool lease admission releases the other workers and unblocks cold starts", async () => {
  const { pool, workers } = controlledPool(3);
  try {
    workers.get("org/a")!.load(); await pool.ready; await turn();
    const loading = pool.workerFor("org/b"); workers.get("org/b")!.load(); await loading;
    workers.get("org/b")!.holdLease();
    const lease = rejection(pool.acquireExecutionLease(new AbortController().signal));
    await turn();
    const next = pool.workerFor("org/c");
    expect(workers.get("org/c")).toBeUndefined();
    workers.get("org/b")!.failLease(new Error("worker lease failed"));
    expect((await lease as Error).message).toBe("worker lease failed");
    await turn();
    expect(workers.get("org/a")!.releases).toBe(1);
    workers.get("org/c")!.load(); await next;
  } finally { await pool.close(); }
});

test("closing aborts pending pool admission and cold starts without resurrecting workers; late leases are disposed", async () => {
  const { pool, workers } = controlledPool();
  const a = workers.get("org/a")!;
  try {
    a.load(); await pool.ready; await turn(); a.holdLease();
    const lease = rejection(pool.acquireExecutionLease(new AbortController().signal));
    await turn();
    const cold = rejection(pool.workerFor("org/b"));
    await pool.close();
    expect(await lease).toBeInstanceOf(EngineUnavailableError);
    expect(await cold).toBeInstanceOf(EngineUnavailableError);
    a.releaseLease(); await turn();
    expect(a.releases).toBe(1);
    expect(workers.size).toBe(1);
    expect(pool.report()).toEqual({ cap: 2, default: "org/a", resident: [], loading: [] });
    await expect(pool.acquireExecutionLease(new AbortController().signal)).rejects.toBeInstanceOf(EngineUnavailableError);
  } finally { a.releaseLease(); await pool.close(); }
});

test("concurrent jobs cannot split ownership of workers and deadlock when their lease requests arrive in a different order", async () => {
  const { pool, workers } = controlledPool();
  const firstArrival = Promise.withResolvers<void>();
  const granted: string[] = [];
  // Each worker's execution lock is exclusive. Delay only the first request
  // to A, emulating independent socket delivery order across the workers.
  const mutex = (id: string) => {
    let tail = Promise.resolve(), calls = 0;
    return async () => {
      const call = ++calls;
      if (id === "a" && call === 1) await firstArrival.promise;
      const previous = tail, done = Promise.withResolvers<void>();
      tail = done.promise;
      await previous;
      granted.push(`${id}${call}`);
      return { dispose: () => done.resolve() };
    };
  };
  try {
    workers.get("org/a")!.load(); await pool.ready; await turn();
    const loading = pool.workerFor("org/b"); workers.get("org/b")!.load(); await loading; await turn();
    workers.get("org/a")!.engine.acquireExecutionLease = mutex("a");
    workers.get("org/b")!.engine.acquireExecutionLease = mutex("b");
    const first = pool.acquireExecutionLease(new AbortController().signal);
    void first.catch(() => {});
    // Change LRU between callers: lock order must not follow usage order.
    await pool.workerFor("org/a");
    const second = pool.acquireExecutionLease(new AbortController().signal);
    void second.catch(() => {});
    await turn();
    expect(granted).toEqual(["a2", "b1"]);
    (await second).dispose();
    firstArrival.resolve();
    (await first).dispose();
  } finally { firstArrival.resolve(); await pool.close(); }
});
