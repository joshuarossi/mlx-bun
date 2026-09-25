import { JobStore } from "./db";
import { closeSubprocessJobs, submitSubprocess, type SubprocessOpts } from "./runner";

/** Owns the lazily opened store and managed subprocesses. Composition supplies
 * an execution lease; the host never unloads the application's resident model. */
export function createJobHost(options: SubprocessOpts & { createStore?: () => JobStore }) {
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
    submit(kind: "quantize", config: Record<string, unknown>, outputPath: string) {
      return submitSubprocess(ensureStore(), kind, config, outputPath, options);
    },
    close() {
      if (closing) return closing;
      closed = true;
      cancellation.abort();
      return closing = (async () => {
        if (!store) return;
        try { await closeSubprocessJobs(store); }
        finally { store.close(); }
      })();
    },
  };
}
