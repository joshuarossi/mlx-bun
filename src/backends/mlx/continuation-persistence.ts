import { SpillQueue, type SpillItem } from "../../kv-store";
import { cacheBytes } from "../../prompt-cache";
import { disposeResources } from "../../engine/resources";
import type { ContinuationStore, OrdinaryContinuationState } from "./continuation";

type Metadata = Parameters<ContinuationStore["storeGenerationCheckpoint"]>[2];
interface Attempt { key: string; completed: boolean; pending: number; failed: boolean; version: number; retired: boolean }
interface Job { attempt: Attempt; metadata?: Metadata; cleanup?: number }

/** One coordinator per checkpoint store. Queue owns snapshots through disk
 * completion; per-key attempts order cleanup before subsequent writes. */
export class ContinuationPersistence {
  readonly #attempts = new Map<string, Attempt>();
  readonly #jobs = new WeakMap<SpillItem["caches"], Job>();
  readonly #queue: SpillQueue;
  readonly #cleanupFailures = new Map<string, Set<number>>();
  readonly #cleanupPending = new Map<string, Set<number>>();
  readonly #cleanupSucceeded = new Map<string, number>();
  #nextBarrier = 0;
  constructor(readonly store: ContinuationStore, options: {
    maxBytes: number;
    /** All blocking tensor serialization runs through the owner's idle gate. */
    runStep: <T>(step: () => T) => Promise<T>;
  }) {
    this.#queue = new SpillQueue(options.maxBytes, cacheBytes, async item => {
      const job = this.#jobs.get(item.caches)!;
      if (job.cleanup) {
        await options.runStep(() => store.removeGenerationCheckpoints(job.attempt.key));
        return true;
      }
      const current = () => this.#attempts.get(job.attempt.key) === job.attempt && !job.attempt.completed;
      if (!current()) return true;
      const stored = await store.storeGenerationCheckpoint(item.tokens, item.caches, job.metadata!, options.runStep);
      // No newer queued write can run until this callback returns. An old
      // in-flight rename can therefore be removed without deleting new work.
      if (!current()) await options.runStep(() => store.removeGenerationCheckpoints(job.attempt.key));
      return stored;
    }, disposeResources, item => !this.#jobs.get(item.caches)?.cleanup);
  }
  /** A completed response is ineligible immediately, before queued unlink. */
  canRestore(key: string): boolean { return !this.#cleanupPending.has(key) && !this.#cleanupFailures.has(key); }
  begin(key: string): Attempt {
    const attempt = { key, completed: false, pending: 0, failed: false, version: 0, retired: false };
    this.#attempts.set(key, attempt);
    this.#queue.cancelWhere(item => !this.#jobs.get(item.caches)?.cleanup && this.#jobs.get(item.caches)?.attempt.key === key);
    return attempt;
  }
  /** Takes ownership even when a completed/superseded attempt declines it. */
  enqueue(attempt: Attempt, state: Omit<OrdinaryContinuationState, "seed">, metadata: Metadata): void {
    if (attempt.completed || this.#attempts.get(attempt.key) !== attempt) {
      disposeResources(state.caches); return;
    }
    this.#jobs.set(state.caches, { attempt, metadata: { ...metadata } });
    attempt.pending++;
    const version = ++attempt.version;
    let completion: Promise<boolean>;
    try { completion = this.#queue.enqueue({ caches: state.caches, tokens: [...state.cacheTokens], ns: attempt.key }); }
    catch (error) { attempt.pending--; disposeResources(state.caches); throw error; }
    void completion.then(stored => {
      attempt.pending--;
      if (version === attempt.version && !attempt.completed) attempt.failed = !stored;
      this.#releaseSettled(attempt);
    });
  }
  complete(attempt: Attempt): void {
    attempt.completed = true;
    this.#queue.cancelWhere(item => !this.#jobs.get(item.caches)?.cleanup && this.#jobs.get(item.caches)?.attempt === attempt);
    if (this.#attempts.get(attempt.key) === attempt) {
      this.#attempts.delete(attempt.key);
      const barrier = ++this.#nextBarrier;
      const pending = this.#cleanupPending.get(attempt.key) ?? new Set<number>();
      pending.add(barrier); this.#cleanupPending.set(attempt.key, pending);
      const caches: SpillItem["caches"] = [];
      this.#jobs.set(caches, { attempt, cleanup: barrier });
      void this.#queue.enqueue({ caches, tokens: [], ns: attempt.key }).then(stored => {
        const key = attempt.key;
        const outstanding = this.#cleanupPending.get(key)!;
        outstanding.delete(barrier);
        if (!outstanding.size) this.#cleanupPending.delete(key);
        const failures = this.#cleanupFailures.get(key) ?? new Set<number>();
        if (stored) {
          this.#cleanupSucceeded.set(key, Math.max(barrier, this.#cleanupSucceeded.get(key) ?? 0));
          // A successful unlink covers older failures, never a newer barrier.
          for (const failed of failures) if (failed <= barrier) failures.delete(failed);
        } else if (barrier > (this.#cleanupSucceeded.get(key) ?? 0)) failures.add(barrier);
        if (failures.size) this.#cleanupFailures.set(key, failures);
        else this.#cleanupFailures.delete(key);
        if (!outstanding.size) this.#cleanupSucceeded.delete(key);
      });
    }
  }
  /** Request cancellation/disposal preserves queued and durable state. */
  release(attempt: Attempt): void { attempt.retired = true; this.#releaseSettled(attempt); }
  #releaseSettled(attempt: Attempt): void {
    if (attempt.retired && attempt.pending === 0 && !attempt.failed && this.#attempts.get(attempt.key) === attempt)
      this.#attempts.delete(attempt.key);
  }
  get stats() { return { pendingCount: this.#queue.pendingCount, pendingBytes: this.#queue.pendingBytes,
    dropped: this.#queue.droppedCount, failed: this.#queue.failedCount }; }
  async flush(): Promise<{ durable: boolean; pendingBytes: number; failed: number }> {
    await this.#queue.drain();
    const active = [...this.#attempts.values()].filter(attempt => !attempt.completed);
    return { durable: this.#cleanupFailures.size === 0 && active.every(attempt => attempt.pending === 0 && !attempt.failed),
      pendingBytes: this.#queue.pendingBytes, failed: this.#cleanupFailures.size + active.filter(attempt => attempt.failed).length };
  }
}
