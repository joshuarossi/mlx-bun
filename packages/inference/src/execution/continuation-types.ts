import type { Cache } from "../contracts/mlx/cache";
import type { SsdCacheStore } from "../state/ssd-cache";

export interface OrdinaryContinuationState {
  caches: Cache[];
  cacheTokens: number[];
  generatedTokens: number;
  pendingToken: number;
  seed: number;
}

/** Request-owned policy. Restore and captureOwned transfer cache ownership.
 * No store or key knowledge enters the driver. */
export interface OrdinaryContinuation {
  readonly interval: number;
  restore(namespace: string): OrdinaryContinuationState | null;
  resumeSampling(state: Omit<OrdinaryContinuationState, "caches">): void;
  captureOwned(state: Omit<OrdinaryContinuationState, "seed">): void;
  complete(): void;
}

export type ContinuationStore = Pick<SsdCacheStore, "findGenerationCheckpoint" | "restore" |
  "storeGenerationCheckpoint" | "removeGenerationCheckpoints">;
