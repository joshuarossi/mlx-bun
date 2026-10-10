import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

// One-row decode attention over a 4-bit, group-64 affine KV cache, head dim
// 256: the shape of MLX's duplication-free GQA vector kernel
// (sdpa_vector_2pass_1_gqa: each simdgroup reads a K/V row once into registers
// and serves several query heads) with dequantize-on-load. Each lane owns 8 of
// the 256 dims: one 4-byte load of packed K (and V) per row plus its group's
// scale and bias. A threadgroup = one KV head × one block of BLOCK = 512
// tokens, split across SUB = 4 token sub-chunks × 2 head groups (REP/2 heads
// each; threadgroup memory bounds SUB at 4 for D 256); the sub-chunks combine
// in threadgroup memory and a second kernel merges blocks. K/V bytes per token
// vs bf16: ~0.28× (with scales). Online softmax in f32: agrees with the
// unfused path to bf16 precision, not bit for bit.
const BLOCK = 512, SUB = 4;
const PARTIAL_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint hk = threadgroup_position_in_grid.y, block = threadgroup_position_in_grid.x;
  const uint hg = sg % 2u, sc = sg / 2u;              // head group, token sub-chunk
  constexpr uint HPG = REP / 2;                       // heads per group
  const uint t0 = block * (uint)BLOCK, tEnd = metal::min((uint)N, t0 + (uint)BLOCK);
  const uint sub = ((uint)BLOCK + (uint)SUB - 1u) / (uint)SUB;
  const uint s0 = t0 + sc * sub, s1 = metal::min(tEnd, s0 + sub);
  // Queries (pre-scaled), 8 dims per lane.
  float qv[HPG][8];
  #pragma clang loop unroll(full)
  for (uint j = 0; j < HPG; ++j)
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) qv[j][i] = float(q[(hk * (uint)REP + hg * HPG + j) * (uint)D + lane * 8u + i]);
  float m[HPG], l[HPG], o[HPG][8];
  #pragma clang loop unroll(full)
  for (uint j = 0; j < HPG; ++j) { m[j] = -INFINITY; l[j] = 0.0f; for (uint i = 0; i < 8u; ++i) o[j][i] = 0.0f; }
  const uint g = lane / 8u;                           // this lane's 64-dim group
  const ulong kph = (ulong)kp_strides[1], kpr = (ulong)kp_strides[2];
  const ulong ksh = (ulong)ks_strides[1], ksr = (ulong)ks_strides[2];
  const ulong vph = (ulong)vp_strides[1], vpr = (ulong)vp_strides[2];
  const ulong vsh = (ulong)vs_strides[1], vsr = (ulong)vs_strides[2];
  for (uint t = s0; t < s1; ++t) {
    const uint kword = kp[(ulong)hk * kph + (ulong)t * kpr + lane];
    const uint vword = vp[(ulong)hk * vph + (ulong)t * vpr + lane];
    const float kscale = float(ks[(ulong)hk * ksh + (ulong)t * ksr + g]), kbias = float(kb[(ulong)hk * ksh + (ulong)t * ksr + g]);
    const float vscale = float(vs[(ulong)hk * vsh + (ulong)t * vsr + g]), vbias = float(vb[(ulong)hk * vsh + (ulong)t * vsr + g]);
    float kr[8], vr[8];
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) {
      kr[i] = metal::fma(kscale, float((kword >> (4u * i)) & 15u), kbias);
      vr[i] = metal::fma(vscale, float((vword >> (4u * i)) & 15u), vbias);
    }
    #pragma clang loop unroll(full)
    for (uint j = 0; j < HPG; ++j) {
      float score = 0.0f;
      #pragma clang loop unroll(full)
      for (uint i = 0; i < 8u; ++i) score = metal::fma(qv[j][i], kr[i], score);
      score = metal::simd_sum(score);
      const float mn = metal::max(m[j], score);
      const float factor = metal::exp(m[j] - mn), e = metal::exp(score - mn);
      m[j] = mn;
      l[j] = l[j] * factor + e;
      #pragma clang loop unroll(full)
      for (uint i = 0; i < 8u; ++i) o[j][i] = metal::fma(o[j][i], factor, e * vr[i]);
    }
  }
  // Combine the SUB token sub-chunks of each head in threadgroup memory.
  threadgroup float osh[SUB * REP * D];
  threadgroup float msh[SUB * REP], lsh[SUB * REP];
  #pragma clang loop unroll(full)
  for (uint j = 0; j < HPG; ++j) {
    const uint h = hg * HPG + j, slot = sc * (uint)REP + h;
    for (uint i = 0; i < 8u; ++i) osh[slot * (uint)D + lane * 8u + i] = o[j][i];
    if (lane == 0u) { msh[slot] = m[j]; lsh[slot] = l[j]; }
  }
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  for (uint e = thread_position_in_threadgroup.x; e < (uint)(REP * D); e += threads_per_threadgroup.x) {
    const uint h = e / (uint)D, d = e % (uint)D;
    float gmax = -INFINITY;
    for (uint s = 0; s < (uint)SUB; ++s) gmax = metal::max(gmax, msh[s * (uint)REP + h]);
    float acc = 0.0f, den = 0.0f;
    for (uint s = 0; s < (uint)SUB; ++s) {
      const float ms = msh[s * (uint)REP + h];
      if (ms == -INFINITY) continue;
      const float w = metal::exp(ms - gmax);
      acc += w * osh[(s * (uint)REP + h) * (uint)D + d];
      den += w * lsh[s * (uint)REP + h];
    }
    const ulong base = ((ulong)block * (uint)KVH + hk) * (uint)REP + h;
    opart[base * (uint)D + d] = acc;
    if (d == 0u) { mpart[base] = gmax; lpart[base] = den; }
  }
`;

const MERGE_SOURCE = String.raw`
  const uint d = thread_position_in_grid.x, qv = thread_position_in_grid.y;
  if (d >= (uint)D || qv >= (uint)(KVH * REP)) return;
  float mmax = -INFINITY;
  for (uint s = 0; s < (uint)BLOCKS; ++s) mmax = metal::max(mmax, mpart[(ulong)s * (uint)(KVH * REP) + qv]);
  float num = 0.0f, den = 0.0f;
  for (uint s = 0; s < (uint)BLOCKS; ++s) {
    const ulong b = (ulong)s * (uint)(KVH * REP) + qv;
    const float ms = mpart[b];
    if (ms == -INFINITY) continue;
    const float w = metal::exp(ms - mmax);
    num += w * opart[b * (uint)D + d];
    den += w * lpart[b];
  }
  out[(ulong)qv * (uint)D + d] = T(num / den);
`;

let partial: MetalKernel | undefined, merge: MetalKernel | undefined;

/** One query row, head dim 256, a 4-bit group-64 cache, an even GQA factor. */
export function kvq4DecodeEligible(q: MlxArray, keys: ops.QuantizedTensor, groupSize: number, bits: number): boolean {
  const [B, H, L, D] = q.shape as [number, number, number, number];
  const KVH = keys.packed.shape[1]!;
  return B === 1 && L === 1 && D === 256 && bits === 4 && groupSize === 64 && H % KVH === 0 && (H / KVH) % 2 === 0;
}

/** q [1, H, 1, 256]; keys/values: 4-bit group-64 affine [1, KVH, N, ·] (any strides) → [1, H, 1, 256]. */
export function kvq4DecodeSdpa(q: MlxArray, keys: ops.QuantizedTensor, values: ops.QuantizedTensor, scale: number): MlxArray {
  const [, H, , D] = q.shape as [number, number, number, number];
  const KVH = keys.packed.shape[1]!, N = keys.packed.shape[2]!, REP = H / KVH;
  const blocks = Math.ceil(N / BLOCK);
  partial ??= new MetalKernel({ name: "mlx_bun_kvq4_decode_partial", inputNames: ["q", "kp", "ks", "kb", "vp", "vs", "vb"],
    outputNames: ["opart", "mpart", "lpart"], source: PARTIAL_SOURCE, ensureRowContiguous: false });
  merge ??= new MetalKernel({ name: "mlx_bun_kvq4_decode_merge", inputNames: ["opart", "mpart", "lpart"],
    outputNames: ["out"], source: MERGE_SOURCE, ensureRowContiguous: true });
  using qs = ops.mulScalar(q, scale);
  using qc = ops.contiguous(qs);
  const [opart, mpart, lpart] = partial.apply([qc, keys.packed, keys.scales, keys.biases, values.packed, values.scales, values.biases], {
    outputs: [{ shape: [blocks, KVH, REP, D], dtype: Dtype.float32 }, { shape: [blocks, KVH, REP], dtype: Dtype.float32 },
      { shape: [blocks, KVH, REP], dtype: Dtype.float32 }],
    grid: [32 * 2 * SUB * blocks, KVH, 1], threadGroup: [32 * 2 * SUB, 1, 1],
    templateDtypes: { T: q.dtype },
    templateInts: { D, N, KVH, REP, BLOCK, SUB },
  });
  try {
    const [out] = merge.apply([opart!, mpart!, lpart!], {
      outputs: [{ shape: [1, H, 1, D], dtype: q.dtype }],
      grid: [D, KVH * REP, 1], threadGroup: [Math.min(256, D), 1, 1],
      templateDtypes: { T: q.dtype },
      templateInts: { D, KVH, REP, BLOCKS: blocks },
    });
    return out!;
  } finally { opart!.dispose(); mpart!.dispose(); lpart!.dispose(); }
}
