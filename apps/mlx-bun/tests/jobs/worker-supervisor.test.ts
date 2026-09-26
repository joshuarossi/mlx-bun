import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { EngineUnavailableError, RestartBudgetExhaustedError, superviseWorker, type WorkerSupervisor } from "../../src/jobs/worker-supervisor";
import { WorkerExitedError } from "../../src/jobs/worker-process";

// The restart policy over the fake worker (tests/fake-worker.ts) on a real
// Unix socket: readiness, respawn within the budget, exhaustion, the lease
// gate before a reload, drain before stop, and close joining every process.
const entry = new URL("../fake-worker.ts", import.meta.url).pathname;
const env = { MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1" };
const launch = (socketPath: string) => ({ socketPath, model: { repoId: "org/model", path: "/unused", expertsBytes: 0 },
  options: { query: null, hostname: "127.0.0.1", port: 0, capacity: 8, contextLimit: null, readOnly: false, noOpen: true, request: {}, cache: { kvQuant: "off" } } });

async function until(check: () => boolean, what: string, timeoutMs = 5_000) {
  const end = Date.now() + timeoutMs;
  while (!check()) { if (Date.now() > end) throw new Error(`timed out waiting for ${what}`); await Bun.sleep(5); }
}
function fixture(extra: Partial<Parameters<typeof superviseWorker>[0]> = {}) {
  const dir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  const socketPath = join(dir, "engine.sock");
  const notices: string[] = [], errors: string[] = [], logs: string[] = [];
  const engine = superviseWorker({ entry, socketPath, launch: launch(socketPath), env, graceMs: 500,
    restarts: { max: 2, windowMs: 60_000, delayMs: 0 }, notice: line => notices.push(line), error: line => errors.push(line), log: line => logs.push(line), ...extra });
  return { dir, socketPath, engine, notices, errors, logs, remove: () => rmSync(dir, { recursive: true, force: true }) };
}
const health = async (engine: WorkerSupervisor) => await (await engine.fetch("http://engine/health")).json() as { pid: number; leases: number; state: string };
const rejection = (work: Promise<unknown>) => work.then(() => { throw new Error("must reject"); }, (error: unknown) => error);

test("a serving worker is respawned after each unexpected exit until the budget is spent, then the supervisor is exhausted", async () => {
  const fake = fixture();
  const { engine } = fake;
  try {
    expect(engine.state).toBe("starting");
    await expect(engine.whenReady()).resolves.toBeUndefined();
    expect(await engine.ready).toEqual({ socketPath: fake.socketPath, modelId: "org/model" });
    expect([engine.state, engine.restarts, engine.modelId, engine.lastExit]).toEqual(["ready", 0, "org/model", null]);
    const first = engine.pid!;
    expect((await health(engine)).pid).toBe(first);
    expect(fake.logs).toEqual(["loading org/model"]);
    // Crash one: the supervisor notices, refuses requests while the worker is down, and comes back with a new pid.
    process.kill(first, "SIGKILL");
    await until(() => engine.state !== "ready", "the exit to be noticed");
    expect(engine.state).toBe("restarting");
    expect(engine.lastExit).toEqual({ code: null, signal: "SIGKILL" });
    const refused = await rejection(engine.fetch("http://engine/health"));
    expect(refused).toBeInstanceOf(EngineUnavailableError);
    expect((refused as EngineUnavailableError).state).toBe("restarting");
    expect((refused as Error).message).toBe("the worker was killed by SIGKILL; respawning");
    const pending = engine.whenReady();
    await until(() => engine.state === "ready", "the respawn");
    await pending;
    const second = engine.pid!;
    expect(second).not.toBe(first);
    expect(engine.restarts).toBe(1);
    expect((await health(engine)).pid).toBe(second);
    expect(fake.notices).toEqual(["the worker was killed by SIGKILL — respawning (restart 1/2)", `engine worker pid ${second} ready`]);
    // Crash two spends the last restart; crash three leaves the supervisor exhausted.
    process.kill(second, "SIGKILL");
    await until(() => engine.state === "ready" && engine.pid !== second, "the second respawn");
    expect(engine.restarts).toBe(2);
    const third = engine.pid!;
    process.kill(third, "SIGKILL");
    await until(() => engine.state === "exhausted", "exhaustion");
    expect(engine.pid).toBeNull();
    expect(engine.restarts).toBe(2);
    const exhausted = await rejection(engine.fetch("http://engine/health"));
    expect(exhausted).toBeInstanceOf(RestartBudgetExhaustedError);
    expect((exhausted as Error).message).toBe("engine restart limit reached (2 in 60 s) after the worker was killed by SIGKILL; restart the server");
    await expect(engine.whenReady()).rejects.toBeInstanceOf(RestartBudgetExhaustedError);
    await expect(engine.acquireExecutionLease(new AbortController().signal)).rejects.toBeInstanceOf(RestartBudgetExhaustedError);
    expect(fake.notices.at(-1)).toBe("the worker was killed by SIGKILL; restart limit reached (2 in 60 s) — requests answer 502 until the server restarts");
    await engine.close();
    expect(engine.state).toBe("closed");
    expect(existsSync(fake.socketPath)).toBe(false);
    await engine.close();
  } finally { await engine.close(); fake.remove(); }
});

test("the first worker's failure rejects ready and is never retried; a waiter's abort and a closed supervisor reject too", async () => {
  const failing = fixture({ env: { ...env, FAKE_WORKER_FAIL: "start" } });
  try {
    const failure = await rejection(failing.engine.ready);
    expect(failure).toBeInstanceOf(WorkerExitedError);
    expect((failure as WorkerExitedError).exit).toEqual({ code: 1, signal: null });
    expect(failing.errors).toEqual(["worker startup failed: fake load failure"]);
    expect([failing.engine.state, failing.engine.restarts, failing.engine.pid, failing.notices]).toEqual(["starting", 0, null, []]);
    await expect(failing.engine.fetch("http://engine/health")).rejects.toBeInstanceOf(EngineUnavailableError);
    await failing.engine.close();
    expect(failing.engine.state).toBe("closed");
    await expect(failing.engine.whenReady()).rejects.toThrow("the server is shutting down");
  } finally { await failing.engine.close(); failing.remove(); }
  const fake = fixture();
  try {
    const cancelled = new AbortController();
    const waiting = rejection(fake.engine.whenReady(cancelled.signal));
    cancelled.abort(new Error("caller left"));
    expect(((await waiting) as Error).message).toBe("caller left");
    await fake.engine.ready;
    await fake.engine.close();
    await expect(fake.engine.fetch("http://engine/health")).rejects.toThrow("the server is shutting down");
  } finally { await fake.engine.close(); fake.remove(); }
});

test("a managed job's lease is owned by its worker connection, waits for a serving worker, and delays a respawn until released", async () => {
  const fake = fixture({ restarts: { max: 3, windowMs: 60_000, delayMs: 100 } });
  const { engine } = fake;
  try {
    // Acquired before ready: the lease waits for the worker, then holds a `/admin/lease` connection open.
    const lease = await engine.acquireExecutionLease(new AbortController().signal);
    expect(engine.state).toBe("ready");
    expect((await health(engine)).leases).toBe(1);
    lease.dispose(); lease.dispose();
    await until(() => false, "", 50).catch(() => {});
    expect((await health(engine)).leases).toBe(0);
    // A held lease keeps the reload waiting: the worker's GPU is a job's.
    const held = await engine.acquireExecutionLease(new AbortController().signal);
    const first = engine.pid!;
    const killedAt = Date.now();
    process.kill(first, "SIGKILL");
    await until(() => engine.state === "restarting", "the exit");
    await Bun.sleep(250);
    expect([engine.state, engine.pid]).toEqual(["restarting", null]);
    held.dispose();
    await until(() => engine.state === "ready", "the respawn after release");
    // The configured delay applies before the respawn.
    expect(Date.now() - killedAt).toBeGreaterThanOrEqual(100);
    expect(engine.pid).not.toBe(first);
    // A lease request abandoned while waiting leaves nothing behind.
    process.kill(engine.pid!, "SIGKILL");
    await until(() => engine.state === "restarting", "the second exit");
    const abandoned = new AbortController();
    const waiting = rejection(engine.acquireExecutionLease(abandoned.signal));
    abandoned.abort(new Error("job cancelled"));
    expect(((await waiting) as Error).message).toBe("job cancelled");
    await until(() => engine.state === "ready", "the third worker");
    expect((await health(engine)).leases).toBe(0);
  } finally { await engine.close(); fake.remove(); }
});

test("close drains the serving worker before stopping it, joins a respawn in progress, and leaves no socket or process", async () => {
  const fake = fixture();
  try {
    await fake.engine.ready;
    const pid = fake.engine.pid!;
    await fake.engine.close();
    expect(fake.errors).toEqual(["drain requested", "stopping"]);
    expect(existsSync(fake.socketPath)).toBe(false);
    expect(() => process.kill(pid, 0)).toThrow();
  } finally { await fake.engine.close(); fake.remove(); }
  // Closing during the backoff before a respawn: nothing new is spawned and close returns promptly.
  const restarting = fixture({ restarts: { max: 3, windowMs: 60_000, delayMs: 60_000 } });
  try {
    await restarting.engine.ready;
    process.kill(restarting.engine.pid!, "SIGKILL");
    await until(() => restarting.engine.state === "restarting", "the exit");
    const started = Date.now();
    await restarting.engine.close();
    expect(Date.now() - started).toBeLessThan(2_000);
    expect(restarting.logs).toEqual(["loading org/model"]);
    expect(existsSync(restarting.socketPath)).toBe(false);
  } finally { await restarting.engine.close(); restarting.remove(); }
  // Closing while a respawned worker is loading stops that worker too.
  const loading = fixture({ restarts: { max: 3, windowMs: 60_000, delayMs: 0 } });
  try {
    await loading.engine.ready;
    process.kill(loading.engine.pid!, "SIGKILL");
    await until(() => loading.engine.state === "restarting", "the exit");
    await until(() => loading.engine.pid !== null, "the respawned worker");
    const pid = loading.engine.pid!;
    await loading.engine.close();
    await until(() => { try { process.kill(pid, 0); return false; } catch { return true; } }, "the respawned worker to exit");
    expect(existsSync(loading.socketPath)).toBe(false);
  } finally { await loading.engine.close(); loading.remove(); }
});


test("an already cancelled job and a cancellation at the readiness handoff never acquire a worker lease", async () => {
  const fake = fixture();
  try {
    await fake.engine.ready;
    for (const immediately of [true, false]) {
      const cancelled = new AbortController();
      const reason = new Error("job cancelled before acquisition");
      if (immediately) cancelled.abort(reason);
      const pending = fake.engine.acquireExecutionLease(cancelled.signal);
      if (!immediately) cancelled.abort(reason);
      // Dispose an incorrectly granted lease too, so the regression leaves no connection behind.
      const result = await pending.then(lease => { lease.dispose(); return undefined; }, error => error);
      expect(result).toBe(reason);
    }
    expect((await health(fake.engine)).leases).toBe(0);
    const seen = await (await fake.engine.fetch("http://engine/fake/seen")).json() as { seen: { path: string }[] };
    expect(seen.seen.some(request => request.path === "/admin/lease")).toBe(false);
  } finally { await fake.engine.close(); fake.remove(); }
});


test("a respawn with an invalid readiness handshake is stopped and joined before the restart budget is spent", async () => {
  let launches = 0;
  const pids: number[] = [];
  const fake = fixture({ spawn: ((command: string[], options: { env?: Record<string, string | undefined>; stdin: "pipe"; stdout: "pipe"; stderr: "pipe" }) => {
    const process = Bun.spawn(command, { ...options,
      env: { ...options.env, FAKE_WORKER_BAD_READY: launches++ === 0 ? "0" : "1" },
    });
    pids.push(process.pid);
    return process;
  }) as typeof Bun.spawn });
  try {
    await fake.engine.ready;
    process.kill(fake.engine.pid!, "SIGKILL");
    await until(() => fake.engine.state === "exhausted", "invalid handshakes to exhaust the restart budget", 2_000);
    expect(launches).toBe(3);
    expect(fake.engine.pid).toBeNull();
    for (const pid of pids) expect(() => process.kill(pid, 0)).toThrow();
    expect(fake.errors.filter(line => line === "stopping")).toHaveLength(2);
  } finally { await fake.engine.close(); fake.remove(); }
});
