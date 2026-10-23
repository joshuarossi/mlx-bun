// One row through a biased projection, rounded once: y = bias + x @ w.T with the
// products accumulated in float32, the bias added in float32 and a single store in
// the weights' dtype. Eager torch computes MOSS-Image's single-row bf16 Linear this
// way; MLX's one-row bf16 addmm stores the product in bf16 before adding the bias,
// a second rounding (on the captured timestep embedding and modulations it changed
// 25% to 52% of the elements). Reading the bf16 weights directly keeps the float32
// accumulation without a widened copy of them.
//
//   x     [1, K]  one row
//   w     [N, K]  as stored
//   bias  [N]
//   y     [1, N]
// One simdgroup per output: each lane sums up to four adjacent products per
// 128-wide stride, then the lanes are summed. Products of bf16 values are exact in
// float32, so only that summation order differs from the reference's.

import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel, type MetalKernelCall } from "@mlx-bun/mlx/metal-kernel";

const SOURCE = String.raw`
    constexpr int per_lane = 4;
    auto n = thread_position_in_grid.y;
    auto lane = thread_index_in_simdgroup;
    auto row = w + n * K;
    float sum = 0.0f;
    for (int base = lane * per_lane; base < K; base += 32 * per_lane) {
      for (int i = 0; i < per_lane && base + i < K; ++i) {
        sum += static_cast<float>(x[base + i]) * static_cast<float>(row[base + i]);
      }
    }
    sum = simd_sum(sum);
    if (lane == 0) {
      y[n] = static_cast<T>(sum + static_cast<float>(bias[n]));
    }
`;

let kernel: MetalKernel | undefined;

/** The projection of one row by `w` `[N, K]` and `bias` `[N]` (borrowed; they must outlive the callable), bound once:
 * the layer that owns this kernel binds it at construction, fixing the weights, their dtype and shape. The callable
 * takes a borrowed `[1, K]` row and returns an owned `[1, N]` result in the weights' dtype. */
export function rowProjection(w: MlxArray, bias: MlxArray): (x: MlxArray) => MlxArray {
  const [N, K] = w.shape as [number, number];
  if (w.shape.length !== 2 || bias.shape.length !== 1 || bias.shape[0] !== N)
    throw new Error(`row projection: need w [N, K] and bias [N], got w [${w.shape}] and bias [${bias.shape}]`);
  const dtype: Dtype = w.dtype;
  kernel ??= new MetalKernel({
    name: "mlx_bun_row_projection",
    inputNames: ["x", "w", "bias"],
    outputNames: ["y"],
    source: SOURCE,
    ensureRowContiguous: true,
  });
  const bound = kernel;
  const call: MetalKernelCall = {
    outputs: [{ shape: [1, N], dtype }],
    grid: [32, N, 1],
    threadGroup: [32, 8, 1],
    templateInts: { K },
    templateDtypes: { T: dtype },
  };
  return x => bound.apply([x, w, bias], call)[0]!;
}
