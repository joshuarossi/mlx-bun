import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

// One simdgroup per query. The first pass finds the final row maximum; the
// second recomputes scores and accumulates exp(score - max) in float32, storing
// only the numerator used with V in bf16. An online maximum would rescale
// already-rounded numerators, which is a different operation.
// Registers hold O(D) values per query; no score or probability array is made.
const SOURCE = String.raw`
  #pragma clang fp contract(off)
  const uint lane = thread_index_in_simdgroup;
  const uint row = thread_position_in_grid.y;
  const uint bh = thread_position_in_grid.z;
  const uint n = q_shape[2], heads = q_shape[1];
  if (row >= n) return;
  const long b = bh / heads, h = bh % heads;
  const long qo = b * q_strides[0] + h * q_strides[1] + long(row) * q_strides[2];
  const long ko = b * k_strides[0] + h * k_strides[1];
  const long vo = b * v_strides[0] + h * v_strides[1];
  constexpr uint columns = (D + 31) / 32;
  float query[columns], weighted[columns];
  for (uint i = 0; i < columns; ++i) {
    const uint d = i * 32 + lane;
    query[i] = d < D ? float(q[qo + long(d) * q_strides[3]]) : 0.0f;
    weighted[i] = 0.0f;
  }

  float peak = -INFINITY;
  for (uint key = 0; key < n; ++key) {
    float dot = 0.0f;
    for (uint i = 0; i < columns; ++i) {
      const uint d = i * 32 + lane;
      if (d < D) dot += query[i] * float(k[ko + long(key) * k_strides[2] + long(d) * k_strides[3]]);
    }
    const float score = simd_sum(dot) * SCORE_SCALE;
    peak = max(peak, score);
  }

  float denominator = 0.0f;
  for (uint key = 0; key < n; ++key) {
    float dot = 0.0f;
    for (uint i = 0; i < columns; ++i) {
      const uint d = i * 32 + lane;
      if (d < D) dot += query[i] * float(k[ko + long(key) * k_strides[2] + long(d) * k_strides[3]]);
    }
    const float score = simd_sum(dot) * SCORE_SCALE;
    const float numerator = exp(score - peak);
    denominator += numerator;
    const float stored = float(T(numerator));
    for (uint i = 0; i < columns; ++i) {
      const uint d = i * 32 + lane;
      if (d < D) weighted[i] += stored * float(v[vo + long(key) * v_strides[2] + long(d) * v_strides[3]]);
    }
  }

  const size_t out = (size_t(bh) * n + row) * D;
  for (uint i = 0; i < columns; ++i) {
    const uint d = i * 32 + lane;
    if (d < D) o[out + d] = T(weighted[i] / denominator);
  }
`;

const kernels = new Map<number, MetalKernel>();

/** Bind unmasked MOSS self-attention at construction for a positive head width.
 * Inputs are borrowed bf16 q/k/v with identical nonempty `[B, H, N, D]` shapes;
 * arbitrary strides are read directly. Returns an owned lazy bf16 array of that
 * shape. The native graph retains inputs, so their handles may be disposed after
 * the call. Workspace is O(D) per running simdgroup plus the O(B H N D) output.
 * QK, scale, exp, sums and division use float32; only the numerator multiplied
 * by V and the output round to bf16. Reduction order can differ from a matmul
 * reference. This kernel has no mask or backward operation. */
export function mossAttention(headDim: number): (q: MlxArray, k: MlxArray, v: MlxArray) => MlxArray {
  if (!Number.isSafeInteger(headDim) || headDim <= 0 || headDim > 0x7fffffff)
    throw new Error("MOSS attention: head dimension must be a positive int32");
  let kernel = kernels.get(headDim);
  if (!kernel) {
    kernel = new MetalKernel({
      name: `mlx_bun_moss_attention_d${headDim}`,
      inputNames: ["q", "k", "v"], outputNames: ["o"], source: SOURCE,
      header: `#define SCORE_SCALE (${Math.fround(Math.pow(headDim, -0.5)).toExponential(9)}f)\n`,
      ensureRowContiguous: false,
    });
    kernels.set(headDim, kernel);
  }
  const bound = kernel;
  return (q, k, v) => {
    const shape = q.shape;
    if (shape.length !== 4 || shape.some(size => size <= 0) || shape[3] !== headDim ||
        [k, v].some(x => x.shape.length !== 4 || x.shape.some((size, i) => size !== shape[i])))
      throw new Error(`MOSS attention: need equal nonempty [B, H, N, ${headDim}] shapes, got [${shape}], [${k.shape}], [${v.shape}]`);
    if ([q, k, v].some(x => x.dtype !== Dtype.bfloat16))
      throw new Error("MOSS attention: q, k and v must be bfloat16");
    const [batch, heads, length] = shape as [number, number, number, number];
    const rows = Math.ceil(length / 4) * 4, batchHeads = batch * heads;
    if (rows > 0x7fffffff || batchHeads > 0x7fffffff)
      throw new Error("MOSS attention: launch dimensions exceed int32");
    return bound.apply([q, k, v], {
      outputs: [{ shape, dtype: Dtype.bfloat16 }],
      grid: [32, rows, batchHeads], threadGroup: [32, 4, 1],
      templateInts: { D: headDim }, templateDtypes: { T: Dtype.bfloat16 },
    })[0]!;
  };
}
