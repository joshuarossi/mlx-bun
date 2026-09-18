/** Sampling owns score processing, token selection, and request-local history.
 * Score/token representations and sync/device execution belong to the backend;
 * this contract has no scheduling, cache, or tensor-runtime dependency. */
export interface SampledToken<Token, Metadata> {
  token: Token;
  extras: Metadata | null;
}

export interface SamplingSession<Scores, DeviceToken, Result> {
  /** Optional stateless operation shared across compatible rows and positions.
   * It borrows scores and returns owned device tokens, without advancing history. */
  readonly independent?: { sample(scores: Scores): DeviceToken };
  /** Optional per-position operation for ONE request whose selection at each
   * position depends only on that position's scores and step (no processor
   * history, grammar or probability capture). Borrows [N,V] scores and returns
   * owned device tokens [N] for the given steps, without advancing history.
   * Draws are those sample() would make at each step: seeded sampling keys by
   * (seed, step), never by a shared stream, so unused positions cost nothing. */
  readonly positional?: { sample(scores: Scores, steps: readonly number[]): DeviceToken };
  readonly isPlainGreedy: boolean;
  readonly capturesLogprobs: boolean;
  readonly needsHistory: boolean;
  /** Borrows scores; transfers ownership of the result to the caller. */
  sample(logits: Scores, step: number): Result;
  seedHistory(tokens: readonly number[]): void;
  /** Commit accepted tokens when configured for manual history updates. */
  commitDevice(token: DeviceToken): void;
  commitNumbers(tokens: readonly number[]): void;
  dispose(): void;
}
