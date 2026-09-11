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
