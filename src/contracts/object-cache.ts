/** Exact reusable work, independent of token-prefix matching. The same cache
 * owner chooses residency and persistence for objects and conversation state. */
export interface ObjectCache<Value> {
  /** Borrow immutable data through an owned lease. A miss permits recompute. */
  take(key: string): Promise<{ value: Value; dispose(): void } | null>;
  /** Successful return transfers ownership, including immediate eviction. */
  put(key: string, value: Value): void;
}
