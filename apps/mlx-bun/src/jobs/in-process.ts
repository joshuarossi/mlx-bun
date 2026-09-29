import { jobError, nowIso, type JobStore } from "./db";
import { makeEmit } from "./events";
import type { JobKind, JobRunner } from "./protocol";

/** Owns tasks until they settle. Loopback inference borrows the server scheduler;
 * these tasks must never hold its exclusive execution lease. */
export function createInProcessJobs() {
  const cancellation = new AbortController();
  const tasks = new Set<Promise<void>>();
  /** Running tasks' own cancellation, beside the host's shutdown. */
  const running = new Map<string, AbortController>();
  const failures: unknown[] = [];
  const signal = cancellation.signal;
  return {
    submit(store: JobStore, kind: JobKind, config: Record<string, unknown>, runner: JobRunner, outputPath?: string) {
      signal.throwIfAborted();
      const row = store.create(kind, config, outputPath);
      const emit = makeEmit(store, row.id, row.log_path);
      const own = new AbortController(), job = AbortSignal.any([signal, own.signal]);
      running.set(row.id, own);
      const task = Promise.resolve().then(async () => {
        try {
          job.throwIfAborted();
          store.setStatus(row.id, "running");
          emit({ type: "started", ts: Date.now() });
          const result = await runner(event => { job.throwIfAborted(); emit(event); }, config, job);
          job.throwIfAborted();
          if (result?.outputPath) store.setOutputPath(row.id, result.outputPath);
          store.setProgress(row.id, 1);
          store.setStatus(row.id, "done", { endedAt: nowIso() });
          emit({ type: "done", ts: Date.now(), output_dir: result?.outputPath ?? outputPath });
        } catch (error) {
          // Main's row format for every job kind: the timestamp and the failure's name.
          const message = jobError(error);
          store.setStatus(row.id, "failed", { error: message, endedAt: nowIso() });
          emit({ type: "failed", error: message, ts: Date.now() });
        }
      }).catch(error => { failures.push(error); }).finally(() => { tasks.delete(task); running.delete(row.id); });
      tasks.add(task);
      return { jobId: row.id, outputPath };
    },
    /** Stops a running task: it ends `failed` with "job cancelled". Nothing for an unknown or finished job. */
    cancel(jobId: string) { running.get(jobId)?.abort(new Error("job cancelled")); },
    async close() {
      cancellation.abort(new Error("Server shutting down"));
      await Promise.all([...tasks]);
      if (failures.length) throw new AggregateError(failures, "Could not persist in-process job status");
    },
  };
}
