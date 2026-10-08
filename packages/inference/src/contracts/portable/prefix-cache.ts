/** A reusable prefix and the backend/method state that covers its tokens.
 * The caller owns a returned hit. After releasing or returning its state,
 * it must release any retained backing through retain. */
export interface PrefixCacheHit<State, Attachment = never> {
  tokens: number[];
  caches: State;
  attachments?: Attachment;
  retain?: () => void;
}

/** Storage is independent of request scheduling and the method producing
 * state. Both prefill and decode can publish processed-token prefixes.
 * State is opaque here; its backend/method defines layout and alignment.
 * Implementations own prefix selection, retention and storage tiers. */
export interface PrefixCache<State, Attachment = never> {
  /** Give optional retained state back to the allocator at an execution
   * boundary. This never rejects or changes the active request. */
  reclaim?(): void;
  /** Drop session affinity without deleting reusable checkpoints. */
  closeSession?(sessionId: string): void;
  /** Prepare a reusable prefix before execution. The returned release ends
   * request interest; cache residency and IO remain implementation-owned. */
  prefetch?(prompt: number[], ns?: string, sessionId?: string): Promise<() => void>;
  /** Return owned state for a usable session continuation, otherwise the
   * longest usable prefix, or null on a miss. Session identity is an affinity
   * hint and never changes the content or numerical namespace.
   * Namespace distinguishes incompatible artifacts, methods and adapters. */
  take(prompt: number[], ns?: string, sessionId?: string): PrefixCacheHit<State, Attachment> | null;
  /** Transfer state and its optional backing release to storage. If this
   * throws, ownership stays with the caller; successful return transfers
   * ownership even when storage immediately spills or disposes the entry. */
  put(tokens: number[], caches: State, ns?: string, retain?: () => void, attachments?: Attachment, sessionId?: string): void;
}
