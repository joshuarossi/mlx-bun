import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

// Multi-query flash-decoding: causal attention for a few query rows (speculative verify, L <= 8) over a long KV
// cache, reading every K and V row ONCE for all query vectors of a KV head.
// MLX's vector kernel accepts at most 32 query vectors per KV head (5 rows at
// GQA 6) and re-reads K/V per query row; above that it falls back to unfused
// attention. Here one threadgroup owns one KV head and one key split; its
// rep·L query vectors (padded to 8-row tiles, one simdgroup per tile) multiply
// each 32-key block staged once in threadgroup memory on the simdgroup matrix
// unit, with an online softmax per row. A second kernel merges the splits.
// Row (r, i) — head kv·rep + r, query i — sees keys j <= N - L + i.
// Not bit-identical to MLX's kernels (summation order); gate by KL.
const PARTIAL_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint hk = threadgroup_position_in_grid.y;
  const uint split = threadgroup_position_in_grid.x;
  const uint fm = ((lane / 4u) & 4u) + ((lane / 2u) % 4u);
  const uint fn = ((lane / 4u) & 2u) * 2u + (lane % 2u) * 2u;
  threadgroup half kv[BK * D];
  // Query tile: rows sg*8 .. sg*8+7 of the head group's rep·L vectors.
  const bool tile = sg * 8u < (uint)NQ;               // simdgroups past the tiles only stage K/V
  const uint row = sg * 8u + fm;                      // this lane's A-fragment row
  const bool rowOk = row < (uint)NQ;
  const uint rr = rowOk ? row / (uint)L : 0u, qi = rowOk ? row % (uint)L : 0u;
  const device T* qp = q + ((ulong)(hk * (uint)REP + rr) * (uint)L + qi) * (uint)D;
  metal::simdgroup_half8x8 qf[D / 8];
  #pragma clang loop unroll(full)
  for (uint f = 0; f < (uint)D / 8u; ++f) {
    qf[f].thread_elements()[0] = rowOk ? half(qp[8u * f + fn]) : half(0.0h);
    qf[f].thread_elements()[1] = rowOk ? half(qp[8u * f + fn + 1u]) : half(0.0h);
  }
  metal::simdgroup_float8x8 o[D / 8];
  #pragma clang loop unroll(full)
  for (uint f = 0; f < (uint)D / 8u; ++f) o[f] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
  float m = -INFINITY, l = 0.0f;
  // Key range of this split; the row's causal limit.
  const uint per = ((uint)N + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint k0 = split * per, k1 = metal::min((uint)N, k0 + per);
  const uint limit = (uint)N - (uint)L + qi;          // keys <= limit are visible
  const ulong hs = (ulong)k_strides[1], rs = (ulong)k_strides[2];
  const ulong vhs = (ulong)v_strides[1], vrs = (ulong)v_strides[2];
  for (uint kb = k0; kb < k1; kb += (uint)BK) {
    // Stage K block [BK, D] as half.
    for (uint i = thread_position_in_threadgroup.x; i < (uint)(BK * D / 8); i += threads_per_threadgroup.x) {
      const uint j = (8u * i) / (uint)D, d = (8u * i) % (uint)D, key = kb + j;
      threadgroup half* dst = kv + j * (uint)D + d;
      if (key < k1) {
        const device metal::vec<T, 4>* src = (const device metal::vec<T, 4>*)(k + (ulong)hk * hs + (ulong)key * rs + d);
        const float4 a = float4(src[0]), b = float4(src[1]);
        *(threadgroup half4*)dst = half4(a); *(threadgroup half4*)(dst + 4) = half4(b);
      } else { *(threadgroup half4*)dst = half4(0.0h); *(threadgroup half4*)(dst + 4) = half4(0.0h); }
    }
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
    // S = Q · Kᵀ for BK keys: BK/8 fragments of [8 rows × 8 keys].
    metal::simdgroup_float8x8 s[BK / 8];
    metal::simdgroup_half8x8 p[BK / 8];
    if (tile) {
    #pragma clang loop unroll(full)
    for (uint c = 0; c < (uint)BK / 8u; ++c) {
      s[c] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
      #pragma clang loop unroll(full)
      for (uint f = 0; f < (uint)D / 8u; ++f) {
        metal::simdgroup_half8x8 kt;
        metal::simdgroup_load(kt, kv + (8u * c) * (uint)D + 8u * f, (ulong)D, ulong2(0, 0), true);
        metal::simdgroup_multiply_accumulate(s[c], qf[f], kt, s[c]);
      }
    }
    // Causal / range mask and online softmax for this lane's row fm.
    float bmax = -INFINITY;
    #pragma clang loop unroll(full)
    for (uint c = 0; c < (uint)BK / 8u; ++c)
      #pragma clang loop unroll(full)
      for (uint e = 0; e < 2u; ++e) {
        const uint key = kb + 8u * c + fn + e;
        float v = s[c].thread_elements()[e];
        if (!rowOk || key >= k1 || key > limit) v = -INFINITY;
        s[c].thread_elements()[e] = v;
        bmax = metal::max(bmax, v);
      }
    bmax = metal::max(bmax, metal::simd_shuffle_xor(bmax, 1u));
    bmax = metal::max(bmax, metal::simd_shuffle_xor(bmax, 8u));
    const float mnew = metal::max(m, bmax);
    const float corr = mnew == -INFINITY ? 1.0f : metal::exp(m - mnew);
    float bsum = 0.0f;
    #pragma clang loop unroll(full)
    for (uint c = 0; c < (uint)BK / 8u; ++c)
      #pragma clang loop unroll(full)
      for (uint e = 0; e < 2u; ++e) {
        const float v = s[c].thread_elements()[e];
        const float w = v == -INFINITY ? 0.0f : metal::exp(v - mnew);
        bsum += w;
        p[c].thread_elements()[e] = half(w);
      }
    bsum += metal::simd_shuffle_xor(bsum, 1u);
    bsum += metal::simd_shuffle_xor(bsum, 8u);
    l = l * corr + bsum;
    m = mnew;
    #pragma clang loop unroll(full)
    for (uint f = 0; f < (uint)D / 8u; ++f) {
      o[f].thread_elements()[0] *= corr;
      o[f].thread_elements()[1] *= corr;
    }
    }
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
    // Stage V block [BK, D] as half; O += P · V.
    for (uint i = thread_position_in_threadgroup.x; i < (uint)(BK * D / 8); i += threads_per_threadgroup.x) {
      const uint j = (8u * i) / (uint)D, d = (8u * i) % (uint)D, key = kb + j;
      threadgroup half* dst = kv + j * (uint)D + d;
      if (key < k1) {
        const device metal::vec<T, 4>* src = (const device metal::vec<T, 4>*)(v + (ulong)hk * vhs + (ulong)key * vrs + d);
        const float4 a = float4(src[0]), b = float4(src[1]);
        *(threadgroup half4*)dst = half4(a); *(threadgroup half4*)(dst + 4) = half4(b);
      } else { *(threadgroup half4*)dst = half4(0.0h); *(threadgroup half4*)(dst + 4) = half4(0.0h); }
    }
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
    if (tile)
    #pragma clang loop unroll(full)
    for (uint f = 0; f < (uint)D / 8u; ++f)
      #pragma clang loop unroll(full)
      for (uint c = 0; c < (uint)BK / 8u; ++c) {
        metal::simdgroup_half8x8 vb;
        metal::simdgroup_load(vb, kv + (8u * c) * (uint)D + 8u * f, (ulong)D);
        metal::simdgroup_multiply_accumulate(o[f], p[c], vb, o[f]);
      }
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  // Partial results: unnormalized O, running max and sum per row.
  if (!tile || !rowOk) return;
  const ulong base = ((ulong)split * (uint)KVH + hk) * (uint)NQ + row;
  #pragma clang loop unroll(full)
  for (uint f = 0; f < (uint)D / 8u; ++f) {
    opart[base * (uint)D + 8u * f + fn] = o[f].thread_elements()[0];
    opart[base * (uint)D + 8u * f + fn + 1u] = o[f].thread_elements()[1];
  }
  if (fn == 0u) { mpart[base] = m; lpart[base] = l; }
`;

const MERGE_SOURCE = String.raw`
  const uint d = thread_position_in_grid.x;            // 0..D-1
  const uint qv = thread_position_in_grid.y;           // 0..KVH·NQ-1
  if (d >= (uint)D || qv >= (uint)(KVH * NQ)) return;
  const uint hk = qv / (uint)NQ, row = qv % (uint)NQ;
  float mmax = -INFINITY;
  for (uint s = 0; s < (uint)SPLITS; ++s) mmax = metal::max(mmax, mpart[(ulong)s * (uint)(KVH * NQ) + qv]);
  float num = 0.0f, den = 0.0f;
  for (uint s = 0; s < (uint)SPLITS; ++s) {
    const ulong b = (ulong)s * (uint)(KVH * NQ) + qv;
    const float ms = mpart[b];
    if (ms == -INFINITY) continue;
    const float w = metal::exp(ms - mmax);
    num += w * opart[b * (uint)D + d];
    den += w * lpart[b];
  }
  const uint rr = row / (uint)L, qi = row % (uint)L;
  out[((ulong)(hk * (uint)REP + rr) * (uint)L + qi) * (uint)D + d] = T(num / den);
`;

let partial: MetalKernel | undefined, merge: MetalKernel | undefined;
const BK = 32;

/** q [1, H, L, D], keys/values [1, KVH, N, D] (any head/row strides) → [1, H, L, D]. */
export function multiQueryCausalSdpa(q: MlxArray, keys: MlxArray, values: MlxArray, scale: number): MlxArray {
  const [, H, L, D] = q.shape as [number, number, number, number];
  const KVH = keys.shape[1]!, N = keys.shape[2]!, REP = H / KVH, NQ = REP * L;
  if (NQ > 64) throw new Error(`multiQueryCausalSdpa: ${NQ} query vectors per KV head exceed 64`);
  const P = Math.max(1, Math.min(128, Math.ceil(N / 256)));   // key splits
  partial ??= new MetalKernel({ name: "mlx_bun_attn_multi_query_partial", inputNames: ["q", "k", "v"],
    outputNames: ["opart", "mpart", "lpart"], source: PARTIAL_SOURCE, ensureRowContiguous: false });
  merge ??= new MetalKernel({ name: "mlx_bun_attn_multi_query_merge", inputNames: ["opart", "mpart", "lpart"],
    outputNames: ["out"], source: MERGE_SOURCE, ensureRowContiguous: true });
  using qs = ops.mulScalar(q, scale);                       // softmax scale folded into q
  using qc = ops.contiguous(qs);
  const [opart, mpart, lpart] = partial.apply([qc, keys, values], {
    outputs: [{ shape: [P, KVH, NQ, D], dtype: Dtype.float32 }, { shape: [P, KVH, NQ], dtype: Dtype.float32 },
      { shape: [P, KVH, NQ], dtype: Dtype.float32 }],
    grid: [256 * P, KVH, 1], threadGroup: [256, 1, 1],
    templateDtypes: { T: q.dtype },
    templateInts: { L, D, N, KVH, REP, NQ, BK, SPLITS: P },
  });
  try {
    const [out] = merge.apply([opart!, mpart!, lpart!], {
      outputs: [{ shape: [1, H, L, D], dtype: q.dtype }],
      grid: [D, KVH * NQ, 1], threadGroup: [Math.min(256, D), 1, 1],
      templateDtypes: { T: q.dtype },
      templateInts: { L, D, KVH, REP, NQ, SPLITS: P },
    });
    return out!;
  } finally { opart!.dispose(); mpart!.dispose(); lpart!.dispose(); }
}
