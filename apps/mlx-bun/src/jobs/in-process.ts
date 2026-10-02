import { jobError, nowIso, type JobStore } from "./db";
import { makeEmit } from "./events";
import type { JobKind, JobRunner } from "./protocol";

/** Owns tasks until they settle. Loopback inference borrows the server scheduler;
 * these tasks must never hold its exclusive execution lease. */
export function createInProcessJobs() {
  const cancellation = new AbortController();
  const tasks = new Set<Promise<void>>();
  const running = new Map<string, { stop: AbortController; done: Promise<void> }>();
  const failures: unknown[] = [];
  const signal = cancellation.signal;
  return {
    submit(store: JobStore, kind: JobKind, config: Record<string, unknown>, runner: JobRunner, outputPath?: string) {
      signal.throwIfAborted();
      const row = store.create(kind, config, outputPath);
      const emit = makeEmit(store, row.id, row.log_path);
      // The host's shutdown and a single job's cancellation both stop the runner.
      const stop = new AbortController(), own = AbortSignal.any([signal, stop.signal]);
      const task = Promise.resolve().then(async () => {
        try {
          own.throwIfAborted();
          store.setStatus(row.id, "running");
          emit({ type: "started", ts: Date.now() });
          const result = await runner(event => { own.throwIfAborted(); emit(event); }, config, own);
          own.throwIfAborted();
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
      running.set(row.id, { stop, done: task });
      return { jobId: row.id, outputPath };
    },
    /** Stop one task and wait until it has ended; a task that is not running is left alone. */
    async cancel(jobId: string) {
      const entry = running.get(jobId);
      if (!entry) return;
      entry.stop.abort(new Error("job cancelled"));
      await entry.done;
    },
    async close() {
      cancellation.abort(new Error("Server shutting down"));
      await Promise.all([...tasks]);
      if (failures.length) throw new AggregateError(failures, "Could not persist in-process job status");
    },
  };
}
