/** A FIFO execution lease, including when no model is resident. Cancellation gives up
 * a queued turn without letting later callers overtake the current owner. */
export function createExecutionLock() {
  let tail: Promise<void> = Promise.resolve();
  const acquire = (signal?: AbortSignal): Promise<{ dispose(): void }> => {
    if (signal?.aborted) return Promise.reject(signal.reason);
    const previous = tail;
    let unlock!: () => void;
    tail = new Promise(resolve => { unlock = resolve; });
    return new Promise((resolve, reject) => {
      let settled = false;
      const abort = () => {
        if (settled) return;
        settled = true;
        void previous.then(unlock);
        reject(signal!.reason);
      };
      signal?.addEventListener("abort", abort, { once: true });
      void previous.then(() => {
        if (settled) return;
        settled = true;
        signal?.removeEventListener("abort", abort);
        let released = false;
        resolve({ dispose() { if (!released) { released = true; unlock(); } } });
      });
    });
  };
  return { acquire, exclusive: async <T>(fn: () => Promise<T>, signal?: AbortSignal): Promise<T> => {
    const lease = await acquire(signal);
    try { signal?.throwIfAborted(); return await fn(); } finally { lease.dispose(); }
  } };
}
