import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Dtype } from "@mlx-bun/mlx/ffi";

/** Numerical ports are backend-specific; returned arrays are caller-owned. */
export interface DraftProjection {
  readonly embed: {
    encode(ids: MlxArray): MlxArray;
    readonly scales: { readonly dtype: Dtype };
  };
  logitsFromHidden(hidden: MlxArray): MlxArray;
}
