// Parent-side ownership of one isolation worker process: spawn it through the
// executable captured at startup, hand it its launch record on stdin, wait for
// its ready line, forward its logs, and stop it (SIGTERM, then SIGKILL after a
// grace). HTTP never passes through here; the parent talks to the worker's
// socket directly (I3). There is no restart policy yet: the budget field is
// carried so the parent's spec is stable when I3 applies it.
import { rmSync } from "node:fs";
import { executablePath } from "./executable";
import { pumpLines } from "./runner";

/** A stdout line the worker reserves for the parent; every other line is log output. */
export const WORKER_MESSAGE_PREFIX = "<mlx-bun-worker>";

export interface WorkerReady { type: "ready"; socketPath: string; modelId: string; pid: number }
export type WorkerMessage = WorkerReady;

export function formatWorkerMessage(message: WorkerMessage): string {
  return WORKER_MESSAGE_PREFIX + JSON.stringify(message);
}

/** The launch record is JSON with non-finite numbers preserved: resolved serve
 * options carry `Infinity` (an unbounded SSD cache), which JSON would null. */
export function encodeLaunch(value: unknown): string {
  return JSON.stringify(value, (_key, item: unknown) =>
    typeof item === "number" && !Number.isFinite(item) ? { $number: String(item) } : item);
}
export function decodeLaunch(text: string): unknown {
  return JSON.parse(text, (_key, item: unknown) =>
    item !== null && typeof item === "object" && "$number" in item && Object.keys(item).length === 1
      ? Number((item as { $number: string }).$number) : item);
}

export interface WorkerProcessOptions {
  /** The worker entry for source runs; a `$bunfs` path selects the compiled binary's `__worker` dispatch. */
  entry: string;
  /** The Unix socket path the worker must bind. The parent owns the file's
   * directory; a stale file is removed before the spawn and after the exit. */
  socketPath: string;
  /** The launch record the worker reads from stdin (`cli/worker-entry.ts` defines it). */
  launch: unknown;
  /** Defaults to the executable captured at startup (Bun for source execution). */
  bin?: string;
  /** Override process creation for deterministic tests. */
  spawn?: typeof Bun.spawn;
  env?: Record<string, string | undefined>;
  /** Worker stdout lines that are not protocol messages; default `console.log`. */
  log?(line: string): void;
  /** Worker stderr lines; default `console.error`. */
  error?(line: string): void;
  /** Give up on a worker that has not reported ready by then (weights load
   * behind it; default 15 min, as main). The worker is stopped. */
  readyTimeoutMs?: number;
  /** SIGTERM first; SIGKILL when the worker is still alive after this (default 3 s). */
  graceMs?: number;
  /** Reserved for I3's automatic respawn; carried, not applied. */
  restarts?: { max: number; windowMs: number; delayMs?: number };
}

export interface WorkerExit { code: number | null; signal: string | null }

export class WorkerExitedError extends Error {
  constructor(readonly exit: WorkerExit, stage: string) {
    super(exit.signal ? `worker was killed by ${exit.signal} ${stage}` : `worker exited with code ${exit.code} ${stage}`);
    this.name = "WorkerExitedError";
  }
}

export interface WorkerProcess {
  readonly pid: number;
  readonly socketPath: string;
  /** From the ready line; undefined until then. */
  readonly modelId: string | undefined;
  /** Resolves once the worker has bound its socket; rejects with the exit when
   * the worker dies first, or when it echoes another socket, or on timeout. */
  readonly ready: Promise<{ socketPath: string; modelId: string }>;
  /** The worker's exit, however it happened, after its logs have drained. */
  readonly exited: Promise<WorkerExit>;
  /** Stop the worker and join it. Idempotent. */
  close(): Promise<WorkerExit>;
}

export function spawnWorker(options: WorkerProcessOptions): WorkerProcess {
  const bin = options.bin ?? executablePath;
  const command = options.entry.includes("$bunfs") ? [bin, "__worker"] : [bin, options.entry];
  const log = options.log ?? (line => console.log(`[worker] ${line}`));
  const error = options.error ?? (line => console.error(`[worker] ${line}`));
  rmSync(options.socketPath, { force: true });
  const proc = (options.spawn ?? Bun.spawn)(command, {
    stdin: "pipe", stdout: "pipe", stderr: "pipe",
    env: { ...process.env, ...options.env },
  });
  // The pipe stays open after the launch record: its end tells the worker the
  // parent is gone, so a crashed parent leaves no orphan holding the GPU.
  proc.stdin.write(encodeLaunch(options.launch) + "\n");
  void proc.stdin.flush();
  const ready = Promise.withResolvers<{ socketPath: string; modelId: string }>();
  let settled = false, modelId: string | undefined;
  const settle = (outcome: { value: { socketPath: string; modelId: string } } | { error: Error }) => {
    if (settled) return;
    settled = true;
    clearTimeout(timer);
    if ("value" in outcome) ready.resolve(outcome.value); else ready.reject(outcome.error);
  };
  const stdout = pumpLines(proc.stdout, line => {
    if (!line.startsWith(WORKER_MESSAGE_PREFIX)) return log(line);
    let message: WorkerMessage;
    try { message = JSON.parse(line.slice(WORKER_MESSAGE_PREFIX.length)) as WorkerMessage; }
    catch { return settle({ error: new Error(`worker sent an unreadable message: ${line}`) }); }
    if (message.type !== "ready") return settle({ error: new Error(`worker sent an unknown message: ${line}`) });
    if (message.socketPath !== options.socketPath)
      return settle({ error: new Error(`worker bound ${message.socketPath}, not ${options.socketPath}`) });
    modelId = message.modelId;
    settle({ value: { socketPath: message.socketPath, modelId: message.modelId } });
  });
  const stderr = pumpLines(proc.stderr, error);
  const exited = (async () => {
    await proc.exited;
    await Promise.all([stdout, stderr]);
    try { proc.stdin.end(); } catch { /* already closed */ }
    const exit: WorkerExit = { code: proc.exitCode, signal: proc.signalCode };
    settle({ error: new WorkerExitedError(exit, "before ready") });
    rmSync(options.socketPath, { force: true });
    return exit;
  })();
  const alive = () => proc.exitCode === null && proc.signalCode === null;
  let closing: Promise<WorkerExit> | undefined;
  const close = () => closing ??= (async () => {
    if (!alive()) return exited;
    proc.kill("SIGTERM");
    const force = setTimeout(() => { if (alive()) proc.kill("SIGKILL"); }, options.graceMs ?? 3_000);
    try { return await exited; } finally { clearTimeout(force); }
  })();
  const timer = setTimeout(() => {
    settle({ error: new Error(`worker did not report ready within ${options.readyTimeoutMs ?? 900_000} ms`) });
    void close();
  }, options.readyTimeoutMs ?? 900_000);
  timer.unref();
  void ready.promise.catch(() => {}); // observed through `ready` by the owner
  return { pid: proc.pid, socketPath: options.socketPath, get modelId() { return modelId; }, ready: ready.promise, exited, close };
}
