// One model worker, as the isolated host holds it resident (residency/model-residency.ts).
// A unit is a supervised worker process (jobs/worker-supervisor.ts) that serves one model on
// its own Unix socket: the host leases it per request, forwards to it, pauses it for a
// managed job, and closes it by draining the worker, letting it flush its saved state, and
// waiting for it to exit. A crash respawns that worker with the same model within the
// supervisor's budget, and it resumes from the saved state. Nothing here loads a model or
// reaches the native library: the worker does, in its own process.
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import type { AppEvent, ModelOperation, ModelOperations, ModelRole } from "@mlx-bun/app-core";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";
import { WORKER_PROTOCOL_VERSION } from "../jobs/worker-process";
import { superviseWorker, type WorkerRestartBudget, type WorkerSupervisor } from "../jobs/worker-supervisor";
import type { UnitClosed } from "../residency/model-residency";
import { forwardToWorker } from "../server/proxy-routes";
import type { RoutedUnit } from "../server/model-routes";
import { shutdownTimeoutMs, type ServeOptions } from "./serve-options";

export interface WorkerUnit extends RoutedUnit {
  readonly record: ModelRecord;
  readonly role: ModelRole;
  readonly supervisor: WorkerSupervisor;
  /** Milliseconds from spawning the worker to its ready line (process start, native runtime, weights). */
  readonly readyMs: number;
}

/** What the host supplies for every worker it spawns. */
export interface WorkerUnitContext {
  options: ServeOptions;
  /** The model the server started with: its `--draft-*`, `--adapter` and `--mtp` belong to it alone. */
  startup: ModelRecord;
  /** A private directory (0700) the host removes; one socket per worker. */
  socketDir: string;
  publish(event: AppEvent): void;
  entry?: string;
  restarts?: Partial<WorkerRestartBudget>;
  env?: Record<string, string | undefined>;
  readyTimeoutMs?: number;
  /** Overrides the CLI's shutdown budget: how long a worker may take to drain and to stop before it is killed. */
  graceMs?: number;
  notice(line: string): void;
  log?(line: string): void;
  error?(line: string): void;
}

let sockets = 0;

/** The launch record of a chat worker: the resolved model and the options, one model only. */
function chatLaunch(context: WorkerUnitContext, record: ModelRecord, socketPath: string) {
  const { options } = context;
  // The worker serves one model, in-process, with no Whisper of its own: Whisper is its own worker.
  const own = record.repoId === context.startup.repoId ? options : { ...options, draft: undefined, adapterDir: undefined, mtp: undefined };
  return { version: WORKER_PROTOCOL_VERSION, socketPath, model: record, options: { ...own, inProcess: true, isolate: undefined, whisper: undefined } };
}

/** Whisper runs the transcription-only server on its socket, its weights resident for as long as its worker is. */
function transcriptionLaunch(record: ModelRecord, socketPath: string) {
  return { kind: "app" as const, version: WORKER_PROTOCOL_VERSION, socketPath, argv: ["--model", record.path, "--whisper-resident", "--preload"] };
}

/** Publish what the worker's engine publishes on its own bus. The worker's load and unload are the host's to report. */
function relayEvents(supervisor: WorkerSupervisor, publish: (event: AppEvent) => void, signal: AbortSignal): void {
  void (async () => {
    while (!signal.aborted) {
      try {
        await supervisor.whenReady(signal);
        const response = await supervisor.fetch("http://engine/admin/events", { signal });
        if (!response.body) return;
        const reader = response.body.getReader(), decoder = new TextDecoder();
        let buffered = "";
        for (;;) {
          const { done, value } = await reader.read();
          if (done) break;
          buffered += decoder.decode(value, { stream: true });
          for (let newline = buffered.indexOf("\n"); newline !== -1; newline = buffered.indexOf("\n")) {
            const line = buffered.slice(0, newline).trim();
            buffered = buffered.slice(newline + 1);
            if (!line) continue;
            try {
              const event = JSON.parse(line) as AppEvent;
              if (event.type !== "model.load" && event.type !== "model.unload") publish(event);
            } catch { /* a torn line is dropped */ }
          }
        }
      } catch { /* the worker went away or is not ready: wait for its respawn */ }
      if (signal.aborted || supervisor.state === "exhausted" || supervisor.state === "closed") return;
      await new Promise(resolve => setTimeout(resolve, 200));
    }
  })();
}

/** Spawn a worker for `record` and resolve once it serves; a worker that fails to start rejects and leaves nothing behind. */
export async function spawnWorkerUnit(context: WorkerUnitContext, record: ModelRecord, role: ModelRole, estimate: number): Promise<WorkerUnit> {
  const socketPath = join(context.socketDir, `worker-${++sockets}.sock`);
  const started = performance.now();
  const budget = context.graceMs ?? shutdownTimeoutMs();
  const supervisor = superviseWorker({
    entry: context.entry ?? fileURLToPath(new URL("./worker-entry.ts", import.meta.url)), socketPath,
    launch: role === "primary" ? chatLaunch(context, record, socketPath) : transcriptionLaunch(record, socketPath),
    ...(context.restarts ? { restarts: context.restarts } : {}),
    ...(context.env ? { env: context.env } : {}),
    ...(context.readyTimeoutMs !== undefined ? { readyTimeoutMs: context.readyTimeoutMs } : {}),
    // The worker flushes its model's saved state when it closes, and a kill would cut that: it gets the CLI's shutdown
    // budget to drain and then to stop.
    drainTimeoutMs: budget, graceMs: budget,
    notice: context.notice,
    ...(context.log ? { log: context.log } : {}),
    ...(context.error ? { error: context.error } : {}),
  });
  try { await supervisor.ready; }
  catch (error) { await supervisor.close().catch(() => {}); throw error; }
  const readyMs = performance.now() - started;
  context.notice(`${role === "primary" ? "engine" : "companion"} worker pid ${supervisor.pid} ready for ${record.repoId} in ${readyMs.toFixed(0)} ms (socket ${supervisor.socketPath})`);

  // What the worker reports of the model it loaded: its weights, and whether saved state was found for it.
  let weightsBytes = 0, resumed = false;
  if (role === "primary") {
    try {
      const response = await supervisor.fetch("http://engine/stats", { signal: AbortSignal.timeout(5_000) });
      const stats = await response.json() as { admission?: { weights_bytes?: number }; ssd_cache?: { entries?: number } };
      weightsBytes = stats.admission?.weights_bytes ?? 0;
      resumed = (stats.ssd_cache?.entries ?? 0) > 0;
    } catch { /* the estimate stands */ }
  }
  const stopEvents = new AbortController();
  if (role === "primary") relayEvents(supervisor, context.publish, stopEvents.signal);
  const operations: readonly ModelOperation[] = role === "primary" ? ["generate"] : ["transcribe"];
  let closing: Promise<UnitClosed> | undefined;
  return {
    id: record.repoId, record, role, supervisor, readyMs, operations, resumed,
    routes: { handle: request => forwardToWorker(supervisor, request) },
    bytes: () => Math.max(estimate, weightsBytes),
    memory: () => ({ weightsBytes, kvBytes: 0, prefixCacheBytes: 0 }),
    operationsFor: () => (role === "primary" ? { generate: (request: Request) => forwardToWorker(supervisor, request) } : {}) as Partial<ModelOperations>,
    broken: () => supervisor.state === "exhausted" || supervisor.state === "closed",
    // A job needs the GPU to itself: the worker's own execution lease. Whisper's decode is brief and holds its own lock.
    pause: signal => role === "primary" ? supervisor.acquireExecutionLease(signal ?? new AbortController().signal) : Promise.resolve({ dispose() {} } as DisposableResource),
    close: () => closing ??= (async () => {
      stopEvents.abort();
      const drained = performance.now();
      await supervisor.close();
      // The worker exits 0 only when its saved state was durable; a kill after the budget, or an incomplete flush, is not.
      return { flushed: supervisor.lastExit?.code === 0, drainMs: performance.now() - drained };
    })(),
  };
}
