// Unmasked native MLX scaled-dot-product attention over MOSS image/text tokens.
import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

/** Bind the head width and scale. Borrows equal-shaped bf16 [B,H,N,D]
 * inputs, including strided views, and returns an owned lazy result. */
export function mossAttention(headDim: number): (q: MlxArray, k: MlxArray, v: MlxArray) => MlxArray {
  if (!Number.isSafeInteger(headDim) || headDim <= 0)
    throw new RangeError("attention head width must be a positive integer");
  const scale = headDim ** -0.5;
  return (q, k, v) => {
    const shape = q.shape;
    if (shape.length !== 4 || shape[3] !== headDim || shape.some(n => n < 1) ||
        k.shape.length !== 4 || v.shape.length !== 4 ||
        shape.some((n, i) => k.shape[i] !== n || v.shape[i] !== n))
      throw new RangeError("attention requires equal [B,H,N,D] inputs with the bound head width");
    if (q.dtype !== Dtype.bfloat16 || k.dtype !== Dtype.bfloat16 || v.dtype !== Dtype.bfloat16)
      throw new TypeError("attention requires bf16 inputs");
    return ops.sdpa(q, k, v, scale, "");
  };
}
