// Job runner: turns a registered `JobRunner` into a tracked, logged job.
// Two execution modes — both create a row, both stream NDJSON events to the
// log, both own terminal status:
//
//   submitInProcess   — runs the runner as a fire-and-forget async task in
//                        THIS process. For pure-JS work (dataset builds) with
//                        no MLX/GPU state to isolate.
//   submitSubprocess  — spawns `bun job-entry.ts <jobId>` so MLX state is
//                        isolated and an uncatchable crash (segfault,
//                        process.exit) can't take the server down. Gated by a
//                        single global GPU lease: only one MLX job runs at a
//                        time; the rest wait 'queued' and drain in order.
//
// Port of optiq lab jobs.py `submit` + `_job_main`, split across this file
// and job-entry.ts.

import type { DisposableResource } from "../contracts/resources";
import { createJobTaskClient } from "./task-client";
import { appendFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import type { Emit, JobEvent, JobRunner } from "./types";
import type { JobStore } from "./db";

/** Absolute path to the child-process entry (`bun job-entry.ts <jobId>`). */
export const JOB_ENTRY_PATH = fileURLToPath(new URL("./job-entry.ts", import.meta.url));

// ---------------------------------------------------------------------------
// Runner registry
// ---------------------------------------------------------------------------

const RUNNERS = new Map<string, JobRunner>();

export function registerRunner(kind: string, run: JobRunner): void {
  RUNNERS.set(kind, run);
}

export function getRunner(kind: string): JobRunner | undefined {
  return RUNNERS.get(kind);
}

// Built-in test kinds. Real kinds (quantize/finetune) register their runner
// on import of their module (see job-entry.ts KIND_MODULES).

/** Emits a couple of stage events then resolves — exercises the happy path. */
const noopRunner: JobRunner = async (emit) => {
  emit({ type: "stage", stage: "warmup", progress: 0.25, message: "starting up" });
  emit({ type: "stage", stage: "work", progress: 0.75, message: "doing the thing" });
  return { outputPath: undefined };
};

/** Hard-exits the process — simulates an uncatchable crash (segfault-class).
 *  Only meaningful under submitSubprocess: the child dies, the parent lives. */
const crashRunner: JobRunner = async (emit) => {
  emit({ type: "stage", stage: "boom", message: "about to crash" });
  process.exit(1);
};

registerRunner("noop", noopRunner);
registerRunner("crash", crashRunner);

// ---------------------------------------------------------------------------
// Emit factory
// ---------------------------------------------------------------------------

/** Build the `emit` sink for a job: appends each event as one NDJSON line
 *  (line-buffered via appendFileSync for crash durability) and mirrors
 *  progress/message from stage/metric events onto the row. Never throws — a
 *  logging failure must not kill a job. The terminal `done`/`failed` status
 *  is owned by the submit wrapper / job-entry, NOT here. */
export function makeEmit(store: JobStore, jobId: string, logPath: string): Emit {
  return (e: JobEvent) => {
    try {
      appendFileSync(logPath, JSON.stringify(e) + "\n");
    } catch {
      // swallow: a job must survive a logging hiccup
    }
    if (e.type === "stage" || e.type === "metric") {
      const progress = typeof e.progress === "number" ? e.progress : undefined;
      const message = typeof e.message === "string" ? e.message : undefined;
      if (progress !== undefined || message !== undefined) {
        try {
          if (progress !== undefined) store.setProgress(jobId, progress, message);
          else if (message !== undefined) {
            // message-only update preserves current progress
            store.db.prepare("UPDATE jobs SET message = ? WHERE id = ?").run(message, jobId);
          }
        } catch {
          // swallow: DB contention must not kill a job
        }
      }
    }
  };
}

// ---------------------------------------------------------------------------
// In-process submit
// ---------------------------------------------------------------------------

export interface SubmitResult {
  jobId: string;
  outputPath?: string;
}

/** Run a registered runner as a fire-and-forget async task in this process.
 *  Sets 'running' + emits 'started' synchronously, then schedules the runner;
 *  on success sets 'done'/progress 1/ended_at + emits 'done', on throw sets
 *  'failed'/error/ended_at + emits 'failed'. Returns once the task is
 *  scheduled (does not await completion — poll the row / tail the log). */
export function submitInProcess(
  store: JobStore,
  kind: string,
  config: Record<string, unknown>,
  outputPath?: string,
): SubmitResult {
  const row = store.create(kind, config, outputPath);
  const emit = makeEmit(store, row.id, row.log_path);
  store.setStatus(row.id, "running");
  emit({ type: "started", ts: Date.now() });

  const runner = getRunner(kind);
  void (async () => {
    if (!runner) {
      const error = `no runner registered for kind "${kind}"`;
      store.setStatus(row.id, "failed", { error, endedAt: nowIso() });
      emit({ type: "failed", error, ts: Date.now() });
      return;
    }
    try {
      const result = await createJobTaskClient(runner).run(JSON.parse(row.config_json), emit);
      const out = result?.outputPath;
      if (out) store.setOutputPath(row.id, out);
      store.setProgress(row.id, 1);
      store.setStatus(row.id, "done", { endedAt: nowIso() });
      emit({ type: "done", ts: Date.now(), output_dir: out ?? outputPath });
    } catch (e) {
      const error = errString(e);
      store.setStatus(row.id, "failed", { error, endedAt: nowIso() });
      emit({ type: "failed", error, ts: Date.now() });
    }
  })();

  return { jobId: row.id, outputPath };
}

// ---------------------------------------------------------------------------
// Subprocess submit + single global GPU lease
// ---------------------------------------------------------------------------

interface QueuedSpawn {
  acquire?: (signal: AbortSignal) => Promise<DisposableResource>;
  lease?: DisposableResource;
  abort: AbortController;
  proc?: Bun.Subprocess;
  finished: Promise<void>;
  finish(): void;
  store: JobStore;
  jobId: string;
  entry: string;
  bin: string;
  spawn: typeof Bun.spawn;
  onComplete?: (jobId: string, code: number) => void;
}

let gpuLeaseHolder: string | null = null;
const spawnQueue: QueuedSpawn[] = [];
let activeSpawn: QueuedSpawn | undefined;
const closedStores = new WeakSet<JobStore>();

/** True while a GPU (subprocess) job is running — the server gates token
 *  generation on this so quantize/finetune don't fight live inference. */
export function isGpuBusy(): boolean {
  return gpuLeaseHolder !== null;
}

/** The job id currently holding the GPU lease, or null. */
export function currentGpuJob(): string | null {
  return gpuLeaseHolder;
}

export interface SubprocessOpts {
  /** Host execution lease, held until child exit (including crashes). */
  acquire?: (signal: AbortSignal) => Promise<DisposableResource>;
  /** Override the entry script (tests). Defaults to JOB_ENTRY_PATH. */
  entry?: string;
  /** Override the runtime binary (tests). Defaults to "bun". */
  bin?: string;
  /** Override process creation for deterministic failure-path tests. */
  spawn?: typeof Bun.spawn;
  /** Called on the server (parent) after the child exits — used to invalidate
   *  caches (e.g. the Library) so a finished quantize surfaces immediately. */
  onComplete?: (jobId: string, code: number) => void;
}

/** Create a 'queued' row and either spawn it now (lease free) or leave it
 *  queued to drain when the lease frees. Returns immediately with the job id
 *  — caller tails the log / polls the row. */
export function submitSubprocess(
  store: JobStore,
  kind: string,
  config: Record<string, unknown>,
  outputPath?: string,
  opts: SubprocessOpts = {},
): SubmitResult {
  if (closedStores.has(store)) throw new Error("job host is closed");
  const row = store.create(kind, config, outputPath);
  let finish!: () => void;
  const finished = new Promise<void>((resolve) => { finish = resolve; });
  const item: QueuedSpawn = {
    abort: new AbortController(), finished, finish,
    store,
    jobId: row.id,
    entry: opts.entry ?? JOB_ENTRY_PATH,
    bin: opts.bin ?? "bun",
    spawn: opts.spawn ?? Bun.spawn,
    onComplete: opts.onComplete,
    acquire: opts.acquire,
  };
  spawnQueue.push(item);
  drainQueue();
  return { jobId: row.id, outputPath };
}

/** Spawn the child, acquire the lease, stream stdout/stderr into the log,
 *  reconcile terminal status on exit, then release the lease and drain. */
function spawnNow(item: QueuedSpawn): void {
  const { store, jobId, entry, bin, spawn } = item;
  gpuLeaseHolder = jobId;

  // The child opens its OWN JobStore over the SAME DB/logs — a sqlite
  // connection can't cross the process boundary, so we hand the paths via
  // env. A :memory: DB can't be shared with a child; subprocess jobs require
  // a file-backed DB.
  let proc: Bun.Subprocess<"ignore", "pipe", "pipe">;
  try {
    proc = spawn([bin, entry, jobId], {
      stdout: "pipe",
      stderr: "pipe",
      env: {
        ...process.env,
        MLX_BUN_JOBS_DB: store.dbPath,
        MLX_BUN_JOBS_DIR: store.logsDir,
      },
    });
  } catch (e) {
    try {
      store.setStatus(jobId, "failed", {
        error: errString(e),
        endedAt: nowIso(),
      });
    } catch (error) {
      console.error(`[jobs] failed to record spawn failure: ${errString(error)}`);
    } finally {
      releaseLease(item);
    }
    return;
  }

  item.proc = proc;
  const logPath = store.get(jobId)?.log_path;
  const logLine = (line: string) => {
    if (!line || !logPath) return;
    const ev: JobEvent = { type: "log", line };
    try { appendFileSync(logPath, JSON.stringify(ev) + "\n"); } catch {}
  };

  void pumpLines(proc.stdout, logLine);
  void pumpLines(proc.stderr, logLine);

  void (async () => {
    const code = await proc.exited;
    // code 0 ⇒ trust the child's terminal status (it set done/failed itself).
    // non-zero ⇒ if the row never reached terminal (crash before the wrapper
    // could write), force it failed.
    try { if (code !== 0) {
      const cur = store.get(jobId);
      if (cur && (cur.status === "queued" || cur.status === "running")) {
        store.setStatus(jobId, "failed", {
          error: `exited ${code}`,
          endedAt: nowIso(),
        });
      }
    } } catch (error) {
      console.error(`[jobs] failed to record child exit: ${errString(error)}`);
    } finally {
      releaseLease(item);
      try { item.onComplete?.(jobId, code); } catch {}
      drainQueue();
    }
  })();
}

function releaseLease(item: QueuedSpawn): void {
  try { item.lease?.dispose(); }
  catch (error) { console.error(`[jobs] execution lease cleanup failed: ${errString(error)}`); }
  finally {
    item.lease = undefined;
    if (gpuLeaseHolder === item.jobId) gpuLeaseHolder = null;
    if (activeSpawn === item) activeSpawn = undefined;
    item.finish();
  }
}

/** Run the next queued subprocess job if the lease is free. */
export function drainQueue(): void {
  while (gpuLeaseHolder === null) {
    const next = spawnQueue.shift();
    if (!next) return;
    // A synchronous spawn failure releases the lease. Keep draining
    // iteratively so a run of bad queue entries cannot recurse or wedge the
    // first startable job behind them.
    activeSpawn = next;
    if (next.acquire) {
      gpuLeaseHolder = next.jobId; // reserve FIFO order while inference drains
      void Promise.resolve().then(() => next.acquire!(next.abort.signal)).then((lease) => {
        next.lease = lease;
        if (next.abort.signal.aborted) throw next.abort.signal.reason;
        spawnNow(next);
      }).catch((error) => {
        try {
          next.store.setStatus(next.jobId, "failed", { error: errString(error), endedAt: nowIso() });
        } catch (recordError) {
          console.error(`[jobs] failed to record admission failure: ${errString(recordError)}`);
        } finally { releaseLease(next); }
      }).finally(drainQueue);
    } else spawnNow(next);
  }
}

/** Stop only this host's managed GPU jobs. Await process death before releasing
 * the execution lease; queued and admission-waiting jobs never spawn. */
export async function closeSubprocessJobs(store: JobStore): Promise<void> {
  closedStores.add(store);
  for (let i = spawnQueue.length - 1; i >= 0; i--) {
    const item = spawnQueue[i]!;
    if (item.store !== store) continue;
    spawnQueue.splice(i, 1);
    store.setStatus(item.jobId, "failed", { error: "job host closed", endedAt: nowIso() });
    item.finish();
  }
  const active = activeSpawn;
  if (!active || active.store !== store) return;
  active.abort.abort(new Error("job host closed"));
  const proc = active.proc;
  if (proc) proc.kill("SIGTERM");
  const force = proc ? setTimeout(() => { if (proc.exitCode === null) proc.kill("SIGKILL"); }, 3000) : undefined;
  try { await active.finished; }
  finally { if (force) clearTimeout(force); }
}

/** Read a child stream line-by-line, buffering partial trailing lines, and
 *  hand each complete line to `sink`. */
async function pumpLines(
  stream: ReadableStream<Uint8Array> | undefined,
  sink: (line: string) => void,
): Promise<void> {
  if (!stream) return;
  const reader = stream.getReader();
  const decoder = new TextDecoder();
  let buf = "";
  try {
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      buf += decoder.decode(value, { stream: true });
      let nl: number;
      while ((nl = buf.indexOf("\n")) !== -1) {
        sink(buf.slice(0, nl));
        buf = buf.slice(nl + 1);
      }
    }
    buf += decoder.decode();
    if (buf) sink(buf);
  } catch {
    // stream torn down with the process — nothing actionable
  } finally {
    reader.releaseLock();
  }
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

function nowIso(): string {
  // SQLite datetime('now') is "YYYY-MM-DD HH:MM:SS" in UTC — match it so the
  // ended_at column is uniform whether set here or by a column default.
  return new Date().toISOString().replace("T", " ").slice(0, 19);
}

function errString(e: unknown): string {
  if (e instanceof Error) return `${e.name}: ${e.message}`;
  return String(e);
}
