import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "./cache";
import type { TokenWorkOptions } from "./token-work";

export type MlxForwardWork = (ids: MlxArray, cache: Cache[], options?: TokenWorkOptions) => Promise<MlxArray>;

export interface MlxPreparationWork {
  /** Real prompt tokens across all rows, not a padded sequence width. */
  readonly maxTokens?: number;
  readonly forward?: MlxForwardWork;
}
