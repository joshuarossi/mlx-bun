import type { Cache } from "./model/gemma4";
import type { PromptCacheEntry } from "./prompt-cache";
import type { SpillItem, SpillQueue } from "./kv-store";

export interface DurabilityGateway {
  readonly busy: boolean;
  runExclusive<T>(fn: () => Promise<T>): Promise<T>;
}

export interface DurabilityPromptCache {
  findExact(tokens: number[], ns?: string): PromptCacheEntry | null;
}

export interface DurabilitySnapshotStats {
  pendingSnapshots: number;
  pendingSpills: number;
  pendingSpillBytes: number;
  droppedSpills: number;
  failedSpills: number;
}

export interface DurabilityFlushResult extends DurabilitySnapshotStats {
  durable: boolean;
  flushedSnapshots: number;
  missingSnapshots: number;
  elapsedMs: number;
}

interface DirtySnapshot {
  key: string;
  tokens: number[];
  ns: string;
}

type StoreOutcome = "stored" | "missing" | "failed";

/**
 * Turns debounced prompt-cache puts into a durability boundary.
 *
 * A dirty record stays present until SpillQueue reports that its atomic store
 * completed. Queue drops and write failures therefore remain retryable during
 * an explicit flush or graceful shutdown.
 */
export class SsdDurabilityCoordinator {
  readonly #dirty = new Map<string, DirtySnapshot>();
  readonly #timers = new Map<string, ReturnType<typeof setTimeout>>();
  readonly #attempts = new Map<string, Promise<StoreOutcome>>();
  #flush: Promise<DurabilityFlushResult> | null = null;

  constructor(
    readonly gateway: DurabilityGateway,
    readonly promptCache: DurabilityPromptCache,
    readonly spillQueue: SpillQueue,
    readonly cloneCaches: (caches: Cache[]) => Cache[],
    readonly isAlreadyDurable: (tokens: number[], ns: string) => boolean = () => false,
    readonly debounceMs = 1_000,
    readonly busyRetryMs = 5_000,
  ) {}

  schedule(tokens: number[], ns = ""): void {
    if (tokens.length === 0) return;
    // PromptCache can hold unrelated entries with the same namespace and
    // length. Include the tokens so one conversation cannot cancel another
    // conversation's pending durability record.
    const key = `${ns.length}:${ns}:${tokens.join(",")}`;
    const rec: DirtySnapshot = { key, tokens: [...tokens], ns };
    this.#dirty.set(key, rec);
    this.#arm(key, this.debounceMs);
  }

  get stats(): DurabilitySnapshotStats {
    return {
      pendingSnapshots: this.#dirty.size,
      pendingSpills: this.spillQueue.pendingCount,
      pendingSpillBytes: this.spillQueue.pendingBytes,
      droppedSpills: this.spillQueue.droppedCount,
      failedSpills: this.spillQueue.failedCount,
    };
  }

  /** Force every dirty RAM snapshot through the queue and wait for storage. */
  flush(): Promise<DurabilityFlushResult> {
    if (this.#flush) return this.#flush;
    const started = performance.now();
    this.#flush = this.#flushInner(started).finally(() => { this.#flush = null; });
    return this.#flush;
  }

  #arm(key: string, delayMs: number): void {
    const old = this.#timers.get(key);
    if (old) clearTimeout(old);
    const timer = setTimeout(() => {
      this.#timers.delete(key);
      void this.#attempt(key, false);
    }, delayMs);
    timer.unref?.();
    this.#timers.set(key, timer);
  }

  async #attempt(key: string, force: boolean): Promise<StoreOutcome> {
    const running = this.#attempts.get(key);
    if (running) {
      const outcome = await running;
      if (!force || !this.#dirty.has(key)) return outcome;
    }

    const rec = this.#dirty.get(key);
    if (!rec) return "stored";
    if (!force && this.gateway.busy) {
      this.#arm(key, this.busyRetryMs);
      return "failed";
    }

    const task = this.#store(rec);
    this.#attempts.set(key, task);
    try {
      const outcome = await task;
      if (outcome !== "failed" && this.#dirty.get(key) === rec)
        this.#dirty.delete(key);
      if (outcome === "failed" && !force && this.#dirty.get(key) === rec)
        this.#arm(key, this.busyRetryMs);
      return outcome;
    } finally {
      if (this.#attempts.get(key) === task) this.#attempts.delete(key);
    }
  }

  async #store(rec: DirtySnapshot): Promise<StoreOutcome> {
    let snap: SpillItem | null = null;
    try {
      snap = await this.gateway.runExclusive(async () => {
        const entry = this.promptCache.findExact(rec.tokens, rec.ns);
        if (!entry) return null;
        return {
          tokens: [...entry.tokens],
          caches: this.cloneCaches(entry.caches),
          ns: rec.ns,
        };
      });
    } catch {
      return "failed";
    }
    if (!snap)
      return this.isAlreadyDurable(rec.tokens, rec.ns) ? "stored" : "missing";
    return await this.spillQueue.enqueue(snap) ? "stored" : "failed";
  }

  async #flushInner(started: number): Promise<DurabilityFlushResult> {
    for (const timer of this.#timers.values()) clearTimeout(timer);
    this.#timers.clear();

    let flushedSnapshots = 0;
    let missingSnapshots = 0;
    const droppedBefore = this.spillQueue.droppedCount;
    const failedBefore = this.spillQueue.failedCount;

    if (this.#attempts.size > 0)
      await Promise.allSettled([...this.#attempts.values()]);
    await this.spillQueue.drain();

    // Flush one entry at a time. This prevents the queue cap from dropping a
    // boundary snapshot while a large final snapshot is already in flight.
    while (this.#dirty.size > 0) {
      const keys = [...this.#dirty.keys()];
      let progressed = false;
      for (const key of keys) {
        if (!this.#dirty.has(key)) continue;
        const outcome = await this.#attempt(key, true);
        await this.spillQueue.drain();
        if (outcome === "stored") {
          flushedSnapshots++;
          progressed = true;
        } else if (outcome === "missing") {
          missingSnapshots++;
          progressed = true;
        }
      }
      if (!progressed) break;
    }

    const stats = this.stats;
    return {
      ...stats,
      durable:
        stats.pendingSnapshots === 0 &&
        stats.pendingSpills === 0 &&
        stats.droppedSpills === droppedBefore &&
        stats.failedSpills === failedBefore &&
        missingSnapshots === 0,
      flushedSnapshots,
      missingSnapshots,
      elapsedMs: performance.now() - started,
    };
  }
}
