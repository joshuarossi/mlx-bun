// Copyright © 2024 Apple Inc. RMS reduction adapted under the MIT license;
// see THIRD_PARTY_NOTICES.md.
import type { MlxArray } from "@mlx-bun/mlx/array";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

// Reduction and rounding follow MLX 0.32.2's rms_norm.metal (Apple Inc., MIT).
// Round the residual sum before squaring, and the normalized value before
// multiplying by the weight, just as add followed by fast::rms_norm does.
const SOURCE = String.raw`
  const uint row = threadgroup_position_in_grid.x;
  const uint tid = thread_position_in_threadgroup.x;
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  threadgroup float sums[32];
  threadgroup float inv[1];
  float acc = 0.0f;
  for (uint r = 0; r < uint(D); r += uint(THREADS) * 4u) {
    for (uint i = 0; i < 4u; ++i) {
      const uint col = r + tid * 4u + i;
      if (col < uint(D)) {
        const uint index = row * uint(D) + col;
        const T value = T(float(x[index]) + float(update[index]));
        residual[index] = value;
        const float v = float(value);
        acc += v * v;
      }
    }
  }
  acc = metal::simd_sum(acc);
  if (sg == 0) sums[lane] = 0.0f;
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  if (lane == 0) sums[sg] = acc;
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  if (sg == 0) {
    acc = metal::simd_sum(sums[lane]);
    if (lane == 0) inv[0] = metal::precise::rsqrt(acc / float(D) + as_type<float>(uint(EPS)));
  }
  threadgroup_barrier(metal::mem_flags::mem_threadgroup | metal::mem_flags::mem_device);
  for (uint r = 0; r < uint(D); r += uint(THREADS) * 4u) {
    for (uint i = 0; i < 4u; ++i) {
      const uint col = r + tid * 4u + i;
      if (col < uint(D)) {
        const uint index = row * uint(D) + col;
        normalized[index] = weight[col] * T(float(residual[index]) * inv[0]);
      }
    }
  }
`;

let kernel: MetalKernel | undefined;

/** Equal-shaped, row-contiguous inputs and a same-dtype vector weight. Returns
 * two owned arrays: the rounded residual and its weighted RMS normalization. */
export function residualRmsNorm(x: MlxArray, update: MlxArray, weight: MlxArray, eps: number): [MlxArray, MlxArray] {
  const shape = x.shape, width = shape.at(-1)!;
  const threads = Math.min(1024, Math.ceil(width / 128) * 32);
  const epsBits = new Uint32Array(new Float32Array([eps]).buffer)[0]!;
  kernel ??= new MetalKernel({ name: "mlx_bun_residual_rms_norm", inputNames: ["x", "update", "weight"],
    outputNames: ["residual", "normalized"], source: SOURCE });
  return kernel.apply([x, update, weight], {
    outputs: [{ shape, dtype: x.dtype }, { shape, dtype: x.dtype }],
    grid: [x.size / width * threads, 1, 1], threadGroup: [threads, 1, 1],
    templateDtypes: { T: x.dtype }, templateInts: { D: width, THREADS: threads, EPS: epsBits },
  }) as [MlxArray, MlxArray];
}
