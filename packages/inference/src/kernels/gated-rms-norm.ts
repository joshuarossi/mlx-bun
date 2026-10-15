// Copyright © 2024 Apple Inc. RMS reduction adapted under the MIT license;
// see THIRD_PARTY_NOTICES.md.
import type { MlxArray } from "@mlx-bun/mlx/array";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

// MLX 0.32.2's four-value RMS reduction, followed by the float32 SiLU
// gate used by Qwen's RMSNormGated. The bf16 normalization rounding stays.
const SOURCE = String.raw`
  const uint row = threadgroup_position_in_grid.x;
  const uint lane = thread_index_in_simdgroup;
  float acc = 0.0f;
  const uint tid = thread_position_in_threadgroup.x;
  threadgroup float sums[32];
  threadgroup float inverse[1];
  for (uint r = 0; r < uint(D); r += uint(THREADS) * 4u) {
    for (uint i = 0; i < 4u; ++i) {
      const uint col = r + tid * 4u + i;
      const float value = col < uint(D) ? float(x[row * uint(D) + col]) : 0.0f;
      acc += value * value;
    }
  }
  acc = metal::simd_sum(acc);
  if (THREADS > 32) {
    const uint sg = simdgroup_index_in_threadgroup;
    if (sg == 0) sums[lane] = 0.0f;
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
    if (lane == 0) sums[sg] = acc;
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
    if (sg == 0) {
      acc = metal::simd_sum(sums[lane]);
      if (lane == 0) inverse[0] = metal::precise::rsqrt(acc / float(D) + as_type<float>(uint(EPS)));
    }
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const float inv = THREADS > 32 ? inverse[0]
    : metal::precise::rsqrt(acc / float(D) + as_type<float>(uint(EPS)));
  for (uint r = 0; r < uint(D); r += uint(THREADS) * 4u) {
    for (uint i = 0; i < 4u; ++i) {
      const uint col = r + tid * 4u + i, index = row * uint(D) + col;
      if (col >= uint(D)) continue;
      const T normalized = weight[col] * T(float(x[index]) * inv);
      const float g = float(gate[index]);
      const float y = 1.0f / (1.0f + metal::exp(metal::abs(g)));
      const float sigmoid = g < 0.0f ? y : 1.0f - y;
      out[index] = T((g * sigmoid) * float(normalized));
    }
  }
`;

let kernel: MetalKernel | undefined;

/** Equal-shaped row-contiguous inputs and a vector
 * weight in the input dtype. Returns an owned gated normalization. */
export function gatedRmsNorm(x: MlxArray, gate: MlxArray, weight: MlxArray, eps: number): MlxArray {
  const shape = x.shape, width = shape.at(-1)!;
  const threads = Math.min(1024, Math.ceil(width / 128) * 32);
  const epsBits = new Uint32Array(new Float32Array([eps]).buffer)[0]!;
  kernel ??= new MetalKernel({ name: "mlx_bun_gated_rms_norm", inputNames: ["x", "gate", "weight"],
    outputNames: ["out"], source: SOURCE });
  return kernel.apply([x, gate, weight], {
    outputs: [{ shape, dtype: x.dtype }], grid: [x.size / width * threads, 1, 1], threadGroup: [threads, 1, 1],
    templateDtypes: { T: x.dtype }, templateInts: { D: width, THREADS: threads, EPS: epsBits },
  })[0]!;
}
