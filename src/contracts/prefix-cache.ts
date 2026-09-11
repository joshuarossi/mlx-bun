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
  /** Return owned state for the longest usable prefix, or null on a miss.
   * Namespace distinguishes incompatible artifacts, methods and adapters. */
  take(prompt: number[], ns?: string): PrefixCacheHit<State, Attachment> | null;
  /** Transfer state and its optional backing release to storage. If this
   * throws, ownership stays with the caller; successful return transfers
   * ownership even when storage immediately spills or disposes the entry. */
  put(tokens: number[], caches: State, ns?: string, retain?: () => void, attachments?: Attachment): void;
}
