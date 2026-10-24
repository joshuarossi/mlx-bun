// Ordered float32 tap accumulation for a depthwise causal convolution.
import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

/** Borrowed x [B,L,C] and weight [C,1,K]. Returns owned [B,L,C], rounded
 * once to x's dtype after accumulating taps from left to right in float32. */
export function causalDepthwiseConv(x: MlxArray, weight: MlxArray): MlxArray {
  const [batch, length, channels] = x.shape as [number, number, number];
  const taps = weight.shape[2]!;
  using padded = ops.pad(x, [[0, 0], [taps - 1, 0], [0, 0]]);
  using rows = ops.reshape(weight, [channels, taps]);
  using coefficients = rows.astype(Dtype.float32);
  let sum = ops.zeros(x.shape, Dtype.float32);
  try {
    for (let tap = 0; tap < taps; tap++) {
      using inputSlice = padded.slice([0, tap, 0], [batch, tap + length, channels]);
      using input = inputSlice.astype(Dtype.float32);
      using weightSlice = coefficients.slice([0, tap], [channels, tap + 1]);
      using weights = ops.reshape(weightSlice, [channels]);
      using product = ops.mul(input, weights);
      const next = ops.add(sum, product);
      sum.dispose(); sum = next;
    }
    return sum.astype(x.dtype);
  } finally { sum.dispose(); }
}
