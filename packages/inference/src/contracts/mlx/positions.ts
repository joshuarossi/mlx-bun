import type { MlxArray } from "@mlx-bun/mlx/array";

export interface MropeRequestState {
  /** Full-grid positions for the prompt, one Int32Array per t/h/w stream. */
  positions: [Int32Array, Int32Array, Int32Array];
  /** (max position + 1) - promptLength; decode positions = offset + delta. */
  delta: number;
}

export interface MropeForwardState {
  /** Effective positions [3, B, L] int32 for the current forward window. */
  posIds: MlxArray;
  /** Borrowed model-owned f32 inv_freq (mropeInvFreq) — not disposed here. */
  invFreq: MlxArray;
  rotaryDims: number;
}
