import type { JobStore } from "./db";
import { makeEmit } from "./events";
import type { JobKind, JobRunner } from "./protocol";

/** Owns tasks until they settle. Loopback inference borrows the server scheduler;
 * these tasks must never hold its exclusive execution lease. */
export function createInProcessJobs() {
  const cancellation = new AbortController();
  const tasks = new Set<Promise<void>>();
  const failures: unknown[] = [];
  const signal = cancellation.signal;
  return {
    submit(store: JobStore, kind: JobKind, config: Record<string, unknown>, runner: JobRunner, outputPath?: string) {
      signal.throwIfAborted();
      const row = store.create(kind, config, outputPath);
      const emit = makeEmit(store, row.id, row.log_path);
      const task = Promise.resolve().then(async () => {
        try {
          signal.throwIfAborted();
          store.setStatus(row.id, "running");
          emit({ type: "started", ts: Date.now() });
          const result = await runner(event => { signal.throwIfAborted(); emit(event); }, config, signal);
          signal.throwIfAborted();
          if (result?.outputPath) store.setOutputPath(row.id, result.outputPath);
          store.setProgress(row.id, 1);
          store.setStatus(row.id, "done", { endedAt: new Date().toISOString() });
          emit({ type: "done", ts: Date.now(), output_dir: result?.outputPath ?? outputPath });
        } catch (error) {
          const message = error instanceof Error ? error.message : String(error);
          store.setStatus(row.id, "failed", { error: message, endedAt: new Date().toISOString() });
          emit({ type: "failed", error: message, ts: Date.now() });
        }
      }).catch(error => { failures.push(error); }).finally(() => { tasks.delete(task); });
      tasks.add(task);
      return { jobId: row.id, outputPath };
    },
    async close() {
      cancellation.abort(new Error("Server shutting down"));
      await Promise.all([...tasks]);
      if (failures.length) throw new AggregateError(failures, "Could not persist in-process job status");
    },
  };
}
