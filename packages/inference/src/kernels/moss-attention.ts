import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

// Each lane holds two entries of an 8x8 SIMD matrix. Store the per-query Q
// and output arrays as compact fragments and form matrices only for the MMA.
const HEADER = String.raw`
  #include <metal_simdgroup_matrix>
  inline void moss_mma(thread float2& output, float2 a, float2 b, float2 c) {
    simdgroup_float8x8 ma, mb, mc, md;
    reinterpret_cast<thread float2&>(ma.thread_elements()) = a;
    reinterpret_cast<thread float2&>(mb.thread_elements()) = b;
    reinterpret_cast<thread float2&>(mc.thread_elements()) = c;
    simdgroup_multiply_accumulate(md, ma, mb, mc);
    output = reinterpret_cast<thread float2&>(md.thread_elements());
  }
`;

// Eight SIMD groups own 64 queries and share each 32-key tile. The first pass
// fixes the final row maximum. The second recomputes scores, sums unrounded
// float32 exponentials and rounds only the numerators multiplied by V to bf16.
// Rescaling an already-rounded numerator after an online maximum would change
// that operation. K and V reuse the same bounded threadgroup tile.
const SOURCE = String.raw`
  #pragma clang fp contract(off)
  constexpr uint BK = 32, SG = 8;
  constexpr uint DP = ((uint(D) + 7) / 8) * 8;
  constexpr uint TD = DP / 8;
  constexpr uint DC = DP < 128 ? DP : 128;
  constexpr uint KS = BK + 8, VS = DC + 8;
  constexpr uint KV_SIZE = DC * KS > BK * VS ? DC * KS : BK * VS;
  threadgroup T kv[KV_SIZE];
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint lid = thread_position_in_threadgroup.x;
  const uint bh = threadgroup_position_in_grid.z;
  const uint n = q_shape[2], heads = q_shape[1];
  const long b = bh / heads, h = bh % heads;
  // MLX/Metal 8x8 fragment coordinates; a row spans lanes differing by 1 or 8.
  const uint sm = ((lane / 4) & 4) + ((lane / 2) % 4);
  const uint sn = ((lane / 4) & 2) * 2 + (lane % 2) * 2;
  const uint row = threadgroup_position_in_grid.x * (SG * 8) + sg * 8 + sm;
  const long qo = b * q_strides[0] + h * q_strides[1] + long(row) * q_strides[2];
  const long ko = b * k_strides[0] + h * k_strides[1];
  const long vo = b * v_strides[0] + h * v_strides[1];
  float2 queries[TD], weighted[TD];
  #pragma unroll
  for (uint dd = 0; dd < TD; ++dd) {
    const uint d = dd * 8 + sn;
    queries[dd][0] = row < n && d < D ? float(q[qo + long(d) * q_strides[3]]) : 0.0f;
    queries[dd][1] = row < n && d + 1 < D ? float(q[qo + long(d + 1) * q_strides[3]]) : 0.0f;
    weighted[dd] = float2(0.0f);
  }

  float peak = -INFINITY, denominator = 0.0f;
  #pragma unroll
  for (uint pass = 0; pass < 2; ++pass) {
    for (uint key = 0; key < n; key += BK) {
      float2 scores[BK / 8];
      #pragma unroll
      for (uint kk = 0; kk < BK / 8; ++kk)
        scores[kk] = float2(0.0f);

      // Stage K transposed in slabs of at most 128 head columns.
      for (uint ds = 0; ds < DP; ds += DC) {
        threadgroup_barrier(mem_flags::mem_threadgroup);
        for (uint i = lid; i < BK * DC; i += SG * 32) {
          const uint r = i / DC, d = i % DC;
          kv[d * KS + r] = key + r < n && ds + d < D
            ? k[ko + long(key + r) * k_strides[2] + long(ds + d) * k_strides[3]] : T(0);
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        #pragma unroll
        for (uint dd = 0; dd < DC / 8; ++dd) {
          if (ds + dd * 8 >= DP) break;
          #pragma unroll
          for (uint kk = 0; kk < BK / 8; ++kk) {
            float2 keys;
            keys[0] = float(kv[(dd * 8 + sm) * KS + kk * 8 + sn]);
            keys[1] = float(kv[(dd * 8 + sm) * KS + kk * 8 + sn + 1]);
            moss_mma(scores[kk], queries[ds / 8 + dd], keys, scores[kk]);
          }
        }
      }
      #pragma unroll
      for (uint kk = 0; kk < BK / 8; ++kk) {
        const float s0 = key + kk * 8 + sn < n ? scores[kk][0] * SCORE_SCALE : -INFINITY;
        const float s1 = key + kk * 8 + sn + 1 < n ? scores[kk][1] * SCORE_SCALE : -INFINITY;
        if (pass == 0) {
          peak = max(peak, max(s0, s1));
        } else {
          const float e0 = precise::exp(s0 - peak), e1 = precise::exp(s1 - peak);
          denominator += e0 + e1;
          scores[kk][0] = float(T(e0));
          scores[kk][1] = float(T(e1));
        }
      }
      if (pass == 1) {
        // All K readers finish before its storage is reused for V.
        for (uint ds = 0; ds < DP; ds += DC) {
          threadgroup_barrier(mem_flags::mem_threadgroup);
          for (uint i = lid; i < BK * DC; i += SG * 32) {
            const uint r = i / DC, d = i % DC;
            kv[r * VS + d] = key + r < n && ds + d < D
              ? v[vo + long(key + r) * v_strides[2] + long(ds + d) * v_strides[3]] : T(0);
          }
          threadgroup_barrier(mem_flags::mem_threadgroup);
          #pragma unroll
          for (uint dd = 0; dd < DC / 8; ++dd) {
            if (ds + dd * 8 >= DP) break;
            #pragma unroll
            for (uint kk = 0; kk < BK / 8; ++kk) {
              float2 values;
              values[0] = float(kv[(kk * 8 + sm) * VS + dd * 8 + sn]);
              values[1] = float(kv[(kk * 8 + sm) * VS + dd * 8 + sn + 1]);
              moss_mma(weighted[ds / 8 + dd], scores[kk], values, weighted[ds / 8 + dd]);
            }
          }
        }
      }
    }
    if (pass == 0) {
      peak = max(peak, simd_shuffle_xor(peak, ushort(1)));
      peak = max(peak, simd_shuffle_xor(peak, ushort(8)));
    }
  }
  denominator += simd_shuffle_xor(denominator, ushort(1));
  denominator += simd_shuffle_xor(denominator, ushort(8));
  if (row < n) {
    const size_t out = (size_t(bh) * n + row) * D;
    #pragma unroll
    for (uint dd = 0; dd < TD; ++dd) {
      const uint d = dd * 8 + sn;
      if (d < D) o[out + d] = T(weighted[dd][0] / denominator);
      if (d + 1 < D) o[out + d + 1] = T(weighted[dd][1] / denominator);
    }
  }
`;

const kernels = new Map<number, MetalKernel>();

/** Bind unmasked MOSS self-attention at construction for a positive head width.
 * Inputs are borrowed bf16 q/k/v with identical nonempty `[B, H, N, D]` shapes;
 * arbitrary strides are read directly. Returns an owned lazy bf16 array of that
 * shape. The native graph retains inputs, so their handles may be disposed after
 * the call. Workspace is O(D) per running simdgroup and at most 10 KiB per
 * threadgroup, plus the O(B H N D) output. No N by N score matrix is made.
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
      header: `${HEADER}\n#define SCORE_SCALE (${Math.fround(Math.pow(headDim, -0.5)).toExponential(9)}f)\n`,
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
    const rows = Math.ceil(length / 64), batchHeads = batch * heads;
    if (rows * 256 > 0x7fffffff || batchHeads > 0x7fffffff)
      throw new Error("MOSS attention: launch dimensions exceed int32");
    return bound.apply([q, k, v], {
      outputs: [{ shape, dtype: Dtype.bfloat16 }],
      grid: [rows * 256, 1, batchHeads], threadGroup: [256, 1, 1],
      templateInts: { D: headDim }, templateDtypes: { T: Dtype.bfloat16 },
    })[0]!;
  };
}
