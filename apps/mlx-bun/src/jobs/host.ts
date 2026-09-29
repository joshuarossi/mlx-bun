import { createInProcessJobs } from "./in-process";
import type { JobKind, JobRunner } from "./protocol";
import { JobStore } from "./db";
import { cancelSubprocessJob, closeSubprocessJobs, submitSubprocess, type SubprocessOpts } from "./runner";

/** Owns the lazily opened store, in-process tasks, and managed subprocesses. Composition supplies
 * an execution lease; the host never unloads the application's resident model. */
export function createJobHost(options: SubprocessOpts & { createStore?: () => JobStore }) {
  const tasks = createInProcessJobs();
  let store: JobStore | undefined;
  let closed = false;
  let closing: Promise<void> | undefined;
  const cancellation = new AbortController();
  const ensureStore = () => {
    if (closed) throw new Error("job host is closed");
    if (!store) {
      store = options.createStore?.() ?? new JobStore();
      store.markZombies();
    }
    return store;
  };
  return {
    signal: cancellation.signal,
    ensureStore,
    submit(kind: string, config: Record<string, unknown>, outputPath?: string, scratchDir?: string) {
      return submitSubprocess(ensureStore(), kind, config, outputPath, options, scratchDir);
    },
    submitTask(kind: JobKind, config: Record<string, unknown>, runner: JobRunner, outputPath?: string) {
      return tasks.submit(ensureStore(), kind, config, runner, outputPath);
    },
    /** Stop a running in-process task; it ends `failed` with "job cancelled". Resolves once it has ended. */
    cancelTask(jobId: string) { return tasks.cancel(jobId); },
    /** Stop a queued or running child process of this store and wait until its process group is gone. */
    cancelProcess(jobId: string) { return cancelSubprocessJob(ensureStore(), jobId); },
    close() {
      if (closing) return closing;
      closed = true;
      cancellation.abort();
      return closing = (async () => {
        if (!store) return;
        try {
          const results = await Promise.allSettled([tasks.close(), closeSubprocessJobs(store)]);
          const failures = results.filter((r): r is PromiseRejectedResult => r.status === "rejected").map(r => r.reason);
          if (failures.length === 1) throw failures[0];
          if (failures.length) throw new AggregateError(failures, "Job shutdown failed");
        }
        finally { store.close(); }
      })();
    },
  };
}
