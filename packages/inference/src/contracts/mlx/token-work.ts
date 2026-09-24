import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "./cache";

export interface TokenWorkOptions {
  /** Verification keeps its established GEMV/GEMM geometry. Other groups may
   * still pack their tokenwise work independently. */
  readonly preserveTokenGeometry?: boolean;
  /** Borrows a residual stream; the method copies only the layers it needs.
   * The layer-count index denotes the post-final-norm output. */
  readonly captureLayer?: (layer: number, hidden: MlxArray) => void;
}

/** Independent sequences presented to one model execution. Each item keeps
 * its existing rectangular row geometry and owns a disjoint cache. */
export interface TokenGroup extends TokenWorkOptions {
  readonly ids: MlxArray;
  readonly cache: Cache[];
}

export interface MixedTokenModel {
  /** Borrows inputs/state; returns one owned hidden array per input group. */
  forwardHiddenMixed(groups: readonly TokenGroup[]): MlxArray[];
}
