import { appendFileSync } from "node:fs";
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";
import type { JobEvent } from "./protocol";
import type { JobStore } from "./db";

export interface SubmitResult { jobId: string; outputPath?: string; }

interface QueuedSpawn {
  acquire: (signal: AbortSignal) => Promise<DisposableResource>;
  lease?: DisposableResource;
  abort: AbortController;
  proc?: Bun.Subprocess;
  finished: Promise<void>;
  finish(): void;
  store: JobStore;
  jobId: string;
  entry: string;
  bin: string;
  compiled: boolean;
  spawn: typeof Bun.spawn;
  onComplete?: (jobId: string, code: number) => void;
}

let gpuLeaseHolder: string | null = null;
const spawnQueue: QueuedSpawn[] = [];
let activeSpawn: QueuedSpawn | undefined;
const closedStores = new WeakSet<JobStore>();

export interface SubprocessOpts {
  /** Host execution lease, held until child exit and log drain (including crashes). */
  acquire: (signal: AbortSignal) => Promise<DisposableResource>;
  /** Child entry supplied by application composition. */
  entry: string;
  /** Defaults to the current Bun runtime. */
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
  outputPath: string | undefined,
  opts: SubprocessOpts,
): SubmitResult {
  if (closedStores.has(store)) throw new Error("job host is closed");
  const row = store.create(kind, config, outputPath);
  let finish!: () => void;
  const finished = new Promise<void>((resolve) => { finish = resolve; });
  const item: QueuedSpawn = {
    abort: new AbortController(), finished, finish,
    store,
    jobId: row.id,
    entry: opts.entry,
    compiled: opts.entry.includes("$bunfs"),
    bin: opts.bin ?? process.execPath,
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
    proc = spawn(item.compiled ? [process.execPath, "__job", jobId] : [bin, entry, jobId], {
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

  const logs = Promise.all([pumpLines(proc.stdout, logLine), pumpLines(proc.stderr, logLine)]);

  void (async () => {
    const code = await proc.exited;
    await logs;
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
    {
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
    }
  }
}

/** Stop only this host's managed GPU jobs. Await process death before releasing
 * the execution lease; queued and admission-waiting jobs never spawn. */
export async function closeSubprocessJobs(store: JobStore): Promise<void> {
  closedStores.add(store);
  const errors: unknown[] = [];
  for (let i = spawnQueue.length - 1; i >= 0; i--) {
    const item = spawnQueue[i]!;
    if (item.store !== store) continue;
    spawnQueue.splice(i, 1);
    try { store.setStatus(item.jobId, "failed", { error: "job host closed", endedAt: nowIso() }); }
    catch (error) { errors.push(error); }
    finally { item.finish(); }
  }
  const active = activeSpawn;
  if (active?.store === store) {
    active.abort.abort(new Error("job host closed"));
    const proc = active.proc;
    if (proc) proc.kill("SIGTERM");
    const force = proc ? setTimeout(() => { if (proc.exitCode === null) proc.kill("SIGKILL"); }, 3000) : undefined;
    try { await active.finished; }
    finally { if (force) clearTimeout(force); }
  }
  if (errors.length) throw new AggregateError(errors, "Failed to persist cancelled jobs");
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
