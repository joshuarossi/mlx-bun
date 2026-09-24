/** RAM policy sees reuse metadata, never tensors, storage or scheduling. */
export interface RetentionCandidate {
  bytes: number;
  cost: number;
  lastUsed: number;
  uses: number;
  priority: number;
}
export interface RetentionPolicy {
  readonly name: string;
  accessed(entry: RetentionCandidate): void;
  victim<T extends RetentionCandidate>(entries: readonly T[]): T;
  evicted(entry: RetentionCandidate): void;
}
export class LruRetention implements RetentionPolicy {
  readonly name = "lru";
  accessed(_entry: RetentionCandidate): void {}
  victim<T extends RetentionCandidate>(entries: readonly T[]): T {
    return entries.reduce((a, b) => a.lastUsed < b.lastUsed ? a : b);
  }
  evicted(_entry: RetentionCandidate): void {}
}

/** GreedyDual size/frequency: saved prefill tokens are the cost proxy.
 * Advancing age on eviction lets old popularity decay without wall timers. */
export class CostSizeRetention implements RetentionPolicy {
  readonly name = "cost-size";
  #age = 0;
  accessed(entry: RetentionCandidate): void {
    entry.priority = this.#age + entry.cost * entry.uses / Math.max(1, entry.bytes);
  }
  victim<T extends RetentionCandidate>(entries: readonly T[]): T {
    return entries.reduce((a, b) => a.priority < b.priority ||
      (a.priority === b.priority && a.lastUsed < b.lastUsed) ? a : b);
  }
  evicted(entry: RetentionCandidate): void { this.#age = Math.max(this.#age, entry.priority); }
}
