import { appendFileSync } from "node:fs";
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";
import type { JobEvent } from "./protocol";
import { jobError, nowIso, type JobStore } from "./db";
import { executablePath } from "./executable";

export interface SubmitResult { jobId: string; outputPath?: string; }

interface QueuedSpawn {
  acquire: (signal: AbortSignal) => Promise<DisposableResource>;
  lease?: DisposableResource;
  abort: AbortController;
  proc?: JobProcess;
  finished: Promise<void>;
  finish(): void;
  store: JobStore;
  jobId: string;
  entry: string;
  bin: string;
  compiled: boolean;
  spawn: typeof Bun.spawn;
  graceMs: number;
  /** The submitter's temporary directory for the child (`TMPDIR`). */
  scratchDir?: string;
  /** Set when a caller stopped this job on purpose; recorded as the failure instead of the exit code. */
  cancelReason?: string;
  onComplete?: (jobId: string, code: number) => void;
}

type JobProcess = Bun.Subprocess<"pipe", "pipe", "pipe">;

let gpuLeaseHolder: string | null = null;
const spawnQueue: QueuedSpawn[] = [];
let activeSpawn: QueuedSpawn | undefined;
const closedStores = new WeakSet<JobStore>();

export interface SubprocessOpts {
  /** Host execution lease, held until child exit and log drain (including crashes). */
  acquire: (signal: AbortSignal) => Promise<DisposableResource>;
  /** Child entry supplied by application composition. */
  entry: string;
  /** Defaults to the executable captured at startup (Bun for source execution). */
  bin?: string;
  /** Override process creation for deterministic failure-path tests. */
  spawn?: typeof Bun.spawn;
  /** SIGTERM first; SIGKILL for whatever of the job's process group is still
   * alive after this (default 3 s, as main). */
  graceMs?: number;
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
  scratchDir?: string,
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
    bin: opts.bin ?? executablePath,
    spawn: opts.spawn ?? Bun.spawn,
    graceMs: opts.graceMs ?? 3000,
    onComplete: opts.onComplete,
    acquire: opts.acquire,
    ...(scratchDir ? { scratchDir } : {}),
  };
  spawnQueue.push(item);
  drainQueue();
  return { jobId: row.id, outputPath };
}

/** Spawn the child as the leader of its own process group, stream its
 * stdout/stderr into the log, reconcile terminal status on exit, then release
 * the lease and drain. Everything that can fail runs before the spawn, so a
 * child that exists is always joined before its lease is released. */
function spawnNow(item: QueuedSpawn): void {
  const { store, jobId, entry, bin, spawn } = item;
  gpuLeaseHolder = jobId;

  // The child opens its OWN JobStore over the SAME DB/logs — a sqlite
  // connection can't cross the process boundary, so we hand the paths via
  // env. A :memory: DB can't be shared with a child; subprocess jobs require
  // a file-backed DB. `detached` makes the child a process-group leader, so
  // stopping the job stops everything it started; a group leader no longer
  // receives the terminal's signals, so the child watches the parent pipe on
  // its stdin instead (cli/job-entry.ts) and stops when this process is gone.
  let proc: JobProcess;
  let logPath: string | undefined;
  try {
    logPath = store.get(jobId)?.log_path;
    proc = spawn(item.compiled ? [bin, "__job", jobId] : [bin, entry, jobId], {
      stdin: "pipe",
      stdout: "pipe",
      stderr: "pipe",
      detached: true,
      env: {
        ...process.env,
        MLX_BUN_JOBS_DB: store.dbPath,
        MLX_BUN_JOBS_DIR: store.logsDir,
        MLX_BUN_JOB_PARENT_PIPE: "1",
        ...(item.scratchDir ? { TMPDIR: item.scratchDir } : {}),
      },
    });
  } catch (e) {
    try {
      store.setStatus(jobId, "failed", {
        error: jobError(e),
        endedAt: nowIso(),
      });
    } catch (error) {
      console.error(`[jobs] failed to record spawn failure: ${jobError(error)}`);
    } finally {
      releaseLease(item);
    }
    return;
  }

  item.proc = proc;
  const logLine = (line: string) => {
    if (!line || !logPath) return;
    const ev: JobEvent = { type: "log", line };
    try { appendFileSync(logPath, JSON.stringify(ev) + "\n"); } catch {}
  };

  const logs = Promise.all([pumpLines(proc.stdout, logLine), pumpLines(proc.stderr, logLine)]);

  void (async () => {
    const code = await proc.exited;
    // Descendants that outlived the child still hold its work and its log
    // pipes: the job is joined once its whole process group is gone and its
    // output has drained. Both waits are bounded: a process surviving SIGKILL
    // (uninterruptible sleep) or one that left the group holding the pipes is
    // reported and left behind rather than holding the lease forever.
    const joined = await stopGroup(proc, item.graceMs) && await settles(logs, item.graceMs);
    if (!joined) console.error(`[jobs] ${jobId}: a process of the job outlived SIGKILL or its output; releasing the lease without it`);
    try { proc.stdin?.end(); } catch { /* already closed */ }
    // code 0 ⇒ trust the child's terminal status (it set done/failed itself).
    // non-zero ⇒ if the row never reached terminal (crash before the wrapper
    // could write), force it failed.
    try { if (code !== 0) {
      const cur = store.get(jobId);
      if (cur && (cur.status === "queued" || cur.status === "running")) {
        store.setStatus(jobId, "failed", {
          error: item.cancelReason ?? `exited ${code}`,
          endedAt: nowIso(),
        });
      }
    } } catch (error) {
      console.error(`[jobs] failed to record child exit: ${jobError(error)}`);
    } finally {
      releaseLease(item);
      try { item.onComplete?.(jobId, code); } catch {}
      drainQueue();
    }
  })();
}

/** Whether any process of the group the child leads is still alive. False for
 * a child that leads no group (a supplied spawn without process groups). */
function groupAlive(proc: JobProcess): boolean {
  if (!Number.isInteger(proc.pid) || proc.pid <= 0) return false;
  try { process.kill(-proc.pid, 0); return true; } catch { return false; }
}

/** Signal the child's process group, or the child alone when it leads none. */
function signalJob(proc: JobProcess, signal: NodeJS.Signals): void {
  if (groupAlive(proc)) {
    try { process.kill(-proc.pid, signal); return; } catch { /* the group just ended */ }
  }
  if (proc.exitCode === null && proc.signalCode == null) {
    try { proc.kill(signal); } catch { /* already gone */ }
  }
}

/** After the leader's exit: SIGTERM what is left of its group, SIGKILL it after
 * the grace, and wait one more grace for it to go. Whether the group is gone. */
async function stopGroup(proc: JobProcess, graceMs: number): Promise<boolean> {
  if (!groupAlive(proc)) return true;
  signalJob(proc, "SIGTERM");
  const force = Date.now() + graceMs, giveUp = force + graceMs;
  let killed = false;
  while (groupAlive(proc)) {
    if (Date.now() >= giveUp) return false;
    if (!killed && Date.now() >= force) { killed = true; signalJob(proc, "SIGKILL"); }
    await Bun.sleep(20);
  }
  return true;
}

/** Whether `work` settles within `ms`. */
async function settles(work: Promise<unknown>, ms: number): Promise<boolean> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  const timeout = new Promise<false>((resolve) => { timer = setTimeout(() => resolve(false), ms); });
  try { return await Promise.race([work.then(() => true, () => true), timeout]); }
  finally { clearTimeout(timer); }
}

function releaseLease(item: QueuedSpawn): void {
  try { item.lease?.dispose(); }
  catch (error) { console.error(`[jobs] execution lease cleanup failed: ${jobError(error)}`); }
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
          next.store.setStatus(next.jobId, "failed", { error: jobError(error), endedAt: nowIso() });
        } catch (recordError) {
          console.error(`[jobs] failed to record admission failure: ${jobError(recordError)}`);
        } finally { releaseLease(next); }
      }).finally(drainQueue);
    }
  }
}

/** Stop only this host's managed GPU jobs. Await the death of the active child's
 * whole process group before releasing the execution lease, bounded at one
 * grace after SIGKILL; queued and admission-waiting jobs never spawn. */
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
  if (active?.store === store) await stopActive(active, "job host closed");
  if (errors.length) throw new AggregateError(errors, "Failed to persist cancelled jobs");
}

/** Stop the active job: no child is spawned if it is still waiting for the lease, otherwise the child gets SIGTERM, then SIGKILL after
 * the grace, and the lease is released once its process group is gone (bounded at one more grace). Resolves when the job has ended. */
async function stopActive(active: QueuedSpawn, reason: string): Promise<void> {
  active.abort.abort(new Error(reason));
  const proc = active.proc;
  if (proc) {
    signalJob(proc, "SIGTERM");
    const force = setTimeout(() => signalJob(proc, "SIGKILL"), active.graceMs);
    try {
      // SIGKILL at the grace, then one more grace for the child to die.
      if (!(await settles(proc.exited, 2 * active.graceMs))) {
        console.error(`[jobs] ${active.jobId}: pid ${proc.pid} outlived SIGKILL; releasing the lease without it`);
        releaseLease(active);
      }
    } finally { clearTimeout(force); }
  }
  await active.finished;
}

/** Stop one managed job of this store: a queued job never spawns, the active one is stopped as `closeSubprocessJobs` stops it. A job that
 * has finished but whose process group is still being joined is waited for; anything else is left alone. Resolves when the job's process is gone. */
export async function cancelSubprocessJob(store: JobStore, jobId: string): Promise<void> {
  const queued = spawnQueue.findIndex(item => item.store === store && item.jobId === jobId);
  if (queued >= 0) {
    const [item] = spawnQueue.splice(queued, 1);
    store.setStatus(jobId, "failed", { error: "job cancelled", endedAt: nowIso() });
    item!.finish();
    return;
  }
  const active = activeSpawn;
  if (active?.store !== store || active.jobId !== jobId) return;
  const row = store.get(jobId);
  if (row && row.status !== "done" && row.status !== "failed") { active.cancelReason = "job cancelled"; await stopActive(active, "job cancelled"); }
  else await active.finished;
}

/** Read a child stream line-by-line, buffering partial trailing lines, and
 *  hand each complete line to `sink`. Shared with the isolation worker owner. */
export async function pumpLines(
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
