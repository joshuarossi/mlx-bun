// Parent-side restart policy over one isolation worker (worker-process.ts):
// respawn after an unexpected exit within a rolling budget, expose the state
// the proxy and `/engine` report, hand out connection-owned execution leases
// for managed jobs, and drain the worker before stopping it. Request bodies
// never pass through here; the proxy fetches the socket through `fetch`.
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";
import { spawnWorker, type WorkerExit, type WorkerProcess, type WorkerProcessOptions } from "./worker-process";

export type WorkerSupervisorState = "starting" | "ready" | "restarting" | "exhausted" | "closed";

/** Main's numbers: at most three restarts in a rolling minute; a worker that
 * died within ten seconds of its spawn waits five seconds before the retry. */
export interface WorkerRestartBudget { max: number; windowMs: number; delayMs?: number }
export const DEFAULT_RESTART_BUDGET: Readonly<WorkerRestartBudget> = Object.freeze({ max: 3, windowMs: 60_000 });
const CRASH_LOOP_WINDOW_MS = 10_000, CRASH_LOOP_DELAY_MS = 5_000;

export interface WorkerSupervisorOptions extends Omit<WorkerProcessOptions, "restarts"> {
  restarts?: Partial<WorkerRestartBudget>;
  /** Supervisor notices (exits, respawns, the exhausted budget); default `console.error`. */
  notice?(line: string): void;
  /** How long `close()` lets the worker quiesce through `/admin/drain` (default 10 s). */
  drainTimeoutMs?: number;
}

/** The typed refusal behind every 502: the worker cannot take this request now. */
export class EngineUnavailableError extends Error {
  constructor(readonly state: WorkerSupervisorState, readonly exit: WorkerExit | null, detail?: string) {
    super(detail ?? describeUnavailable(state, exit));
    this.name = "EngineUnavailableError";
  }
}
/** The restart budget is spent: nothing respawns until the server restarts. */
export class RestartBudgetExhaustedError extends EngineUnavailableError {
  constructor(exit: WorkerExit | null, readonly budget: Readonly<WorkerRestartBudget>) {
    super("exhausted", exit, `engine restart limit reached (${budget.max} in ${Math.round(budget.windowMs / 1000)} s)${exit ? ` after ${describeExit(exit)}` : ""}; restart the server`);
    this.name = "RestartBudgetExhaustedError";
  }
}

export function describeExit(exit: WorkerExit): string {
  return exit.signal ? `the worker was killed by ${exit.signal}` : `the worker exited with code ${exit.code}`;
}
function describeUnavailable(state: WorkerSupervisorState, exit: WorkerExit | null): string {
  switch (state) {
    case "starting": return "the engine worker is still loading";
    case "restarting": return `${exit ? describeExit(exit) : "the engine worker exited"}; respawning`;
    case "closed": return "the server is shutting down";
    case "exhausted": return "engine restart limit reached; restart the server";
    case "ready": return "the engine worker did not answer";
  }
}

export interface WorkerSupervisor {
  readonly state: WorkerSupervisorState;
  /** The live worker's pid while one exists (loading or serving); null between workers. */
  readonly pid: number | null;
  readonly socketPath: string;
  readonly modelId: string | undefined;
  /** Automatic respawns so far; a startup failure of the first worker is not one. */
  readonly restarts: number;
  readonly lastExit: WorkerExit | null;
  readonly budget: Readonly<WorkerRestartBudget>;
  /** The first worker's readiness. It rejects when that worker dies, echoes
   * another socket, or misses the ready timeout; the first load is never retried. */
  readonly ready: Promise<{ socketPath: string; modelId: string }>;
  /** Resolves once a worker serves; rejects when the budget is spent, on close, or on the signal. */
  whenReady(signal?: AbortSignal): Promise<void>;
  /** One request over the worker socket. Rejects with EngineUnavailableError
   * unless a worker is serving; a transport failure means it died mid-request. */
  fetch(url: string, init?: RequestInit & { duplex?: "half" }): Promise<Response>;
  /** A managed job's execution lease, owned by a `/admin/lease` connection
   * inside the worker: it waits for a serving worker and for generation in
   * flight; a respawn waits until every lease has been released. */
  acquireExecutionLease(signal: AbortSignal): Promise<DisposableResource>;
  /** Best effort `POST /admin/drain`; returns once the worker reports or the deadline passes. */
  drain(timeoutMs?: number): Promise<void>;
  /** Drain, stop, and join the worker; a respawn in progress is joined too. Idempotent. */
  close(): Promise<void>;
}

export function superviseWorker(options: WorkerSupervisorOptions): WorkerSupervisor {
  const budget: Readonly<WorkerRestartBudget> = Object.freeze({ ...DEFAULT_RESTART_BUDGET, ...options.restarts });
  const notice = options.notice ?? (line => console.error(`[isolate] ${line}`));
  const { restarts: _budget, notice: _notice, drainTimeoutMs: _drain, ...spawnOptions } = options;
  const lifetime = new AbortController();
  let state: WorkerSupervisorState = "starting";
  let worker: WorkerProcess | undefined, live = false, started = false;
  let restarts = 0, lastExit: WorkerExit | null = null, spawnedAt = 0;
  const exits: number[] = [];
  let backoff: ReturnType<typeof setTimeout> | undefined, wakeBackoff: (() => void) | undefined;
  const respawns = new Set<Promise<void>>();
  const readyWaiters = new Set<{ resolve(): void; reject(error: unknown): void }>();
  let held = 0;
  const idleWaiters = new Set<() => void>();

  const unavailable = () => state === "exhausted" ? new RestartBudgetExhaustedError(lastExit, budget) : new EngineUnavailableError(state, lastExit);
  const setState = (next: WorkerSupervisorState) => {
    state = next;
    if (next === "ready") for (const waiter of [...readyWaiters]) { readyWaiters.delete(waiter); waiter.resolve(); }
    else if (next === "exhausted" || next === "closed") for (const waiter of [...readyWaiters]) { readyWaiters.delete(waiter); waiter.reject(unavailable()); }
  };
  const wakeIdle = () => { if (held === 0) for (const wake of [...idleWaiters]) wake(); };
  const untilIdle = (signal: AbortSignal) => new Promise<void>((resolve, reject) => {
    if (signal.aborted) return reject(signal.reason);
    if (held === 0) return resolve();
    const wake = () => { idleWaiters.delete(wake); signal.removeEventListener("abort", stop); resolve(); };
    const stop = () => { idleWaiters.delete(wake); reject(signal.reason); };
    idleWaiters.add(wake);
    signal.addEventListener("abort", stop, { once: true });
  });

  const spawn = (): WorkerProcess => {
    spawnedAt = Date.now();
    const proc = spawnWorker(spawnOptions);
    worker = proc; live = true;
    void proc.exited.then(exit => onExit(proc, exit));
    return proc;
  };
  const onExit = (proc: WorkerProcess, exit: WorkerExit) => {
    if (worker !== proc) return;
    live = false; lastExit = exit;
    // The first worker's failure reaches the owner through `ready`; a closing
    // supervisor stopped it on purpose.
    if (state === "closed" || !started) return;
    const now = Date.now();
    while (exits.length && now - exits[0]! >= budget.windowMs) exits.shift();
    if (exits.length >= budget.max) {
      setState("exhausted");
      notice(`${describeExit(exit)}; restart limit reached (${budget.max} in ${Math.round(budget.windowMs / 1000)} s) — requests answer 502 until the server restarts`);
      return;
    }
    exits.push(now); restarts++;
    // Crash-loop backoff: a worker that died soon after spawning (bad flags,
    // OOM on load) waits before the retry instead of spinning.
    const delay = budget.delayMs ?? (now - spawnedAt < CRASH_LOOP_WINDOW_MS ? CRASH_LOOP_DELAY_MS : 0);
    setState("restarting");
    notice(`${describeExit(exit)} — respawning (restart ${exits.length}/${budget.max}${delay ? `, after ${delay} ms` : ""})`);
    const respawn = (async () => {
      await new Promise<void>(resolve => { wakeBackoff = resolve; backoff = setTimeout(resolve, delay); });
      backoff = undefined; wakeBackoff = undefined;
      if (state !== "restarting") return;
      // A managed job may own the GPU right now; the reload waits for its lease.
      try { await untilIdle(lifetime.signal); } catch { return; }
      if (state !== "restarting") return;
      let next: WorkerProcess;
      try { next = spawn(); }
      catch (error) {
        // The executable or entry is gone: nothing more can be respawned.
        setState("exhausted");
        notice(`respawn failed: ${error instanceof Error ? error.message : String(error)}; restart the server`);
        return;
      }
      try {
        await next.ready;
        if (worker === next && state === "restarting") { setState("ready"); notice(`engine worker pid ${next.pid} ready`); }
      } catch { /* the exit handler applies the budget */ }
    })();
    respawns.add(respawn);
    void respawn.finally(() => respawns.delete(respawn)).catch(() => {});
  };

  const first = spawn();
  const ready = first.ready.then(value => {
    started = true;
    if (state === "starting") setState("ready");
    return value;
  });
  void ready.catch(() => {});

  const whenReady = (signal?: AbortSignal) => {
    if (state === "ready") return Promise.resolve();
    if (state === "exhausted" || state === "closed") return Promise.reject(unavailable());
    if (signal?.aborted) return Promise.reject(signal.reason);
    return new Promise<void>((resolve, reject) => {
      const waiter = { resolve() { signal?.removeEventListener("abort", abort); resolve(); },
        reject(error: unknown) { signal?.removeEventListener("abort", abort); reject(error); } };
      const abort = () => { readyWaiters.delete(waiter); reject(signal!.reason); };
      readyWaiters.add(waiter);
      signal?.addEventListener("abort", abort, { once: true });
    });
  };

  const fetchWorker = (url: string, init: RequestInit & { duplex?: "half" } = {}) => {
    if (state !== "ready" || !worker) return Promise.reject(unavailable());
    const signal = init.signal ? AbortSignal.any([init.signal, lifetime.signal]) : lifetime.signal;
    return fetch(url, { ...init, signal, unix: worker.socketPath } as RequestInit);
  };

  const acquireExecutionLease = async (signal: AbortSignal): Promise<DisposableResource> => {
    await whenReady(signal);
    // The connection owns the lease (main's semantics): a parent that dies
    // releases it, and disposing here ends the stream the worker holds open.
    const abort = new AbortController();
    const cancel = () => abort.abort(signal.reason);
    signal.addEventListener("abort", cancel, { once: true });
    try {
      const response = await fetchWorker("http://engine/admin/lease", { method: "POST", signal: abort.signal });
      if (!response.ok) { await response.body?.cancel().catch(() => {}); throw new Error(`worker lease failed (${response.status})`); }
      held++;
      let released = false;
      return { dispose() {
        if (released) return;
        released = true; held--;
        abort.abort();
        void response.body?.cancel().catch(() => {});
        wakeIdle();
      } };
    } catch (error) { abort.abort(); throw error; }
    finally { signal.removeEventListener("abort", cancel); }
  };

  const drain = async (timeoutMs = options.drainTimeoutMs ?? 10_000) => {
    const current = worker;
    if (!current || !live) return;
    try {
      const response = await fetch("http://engine/admin/drain", { method: "POST", body: JSON.stringify({ timeout_ms: timeoutMs }),
        signal: AbortSignal.timeout(timeoutMs + 1_000), unix: current.socketPath } as RequestInit);
      await response.arrayBuffer();
    } catch { /* best effort: the worker is stopped next */ }
  };

  let closing: Promise<void> | undefined;
  const close = () => closing ??= (async () => {
    const wasReady = state === "ready";
    setState("closed");
    lifetime.abort(new Error("engine host is closed"));
    clearTimeout(backoff); wakeBackoff?.();
    const current = worker;
    if (current) {
      if (wasReady) await drain();
      await current.close();
    }
    await Promise.allSettled([first.ready, ...respawns]);
    if (worker && worker !== current) await worker.close();
  })();

  return {
    get state() { return state; },
    get pid() { return live && worker ? worker.pid : null; },
    socketPath: options.socketPath,
    get modelId() { return worker?.modelId; },
    get restarts() { return restarts; },
    get lastExit() { return lastExit; },
    budget, ready, whenReady, fetch: fetchWorker, acquireExecutionLease, drain, close,
  };
}
