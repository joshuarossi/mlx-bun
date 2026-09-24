import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisGeometry } from "./geometry";
import { HEADER, lutFor, decoderVariant, wordsPerBlock } from "./codebook";

const THREADS = 128, SG_PER_TG = 4, SCATTER_SPLITS = 128;

const SCATTER_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += 128u) lutTG[i] = lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint wpb = (uint)(BT * K / 32);
  const uint nb = 32u / wpb;                       // blocks per SIMD group
  const uint nBlocks = (uint)C / (uint)BT;
  const uint groups = (nBlocks + nb - 1u) / nb;
  const uint group = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint zi = thread_position_in_grid.z;
  const uint sample = zi / (uint)SPLITS;
  const uint split = zi - sample * (uint)SPLITS;
  const uint bi = lane / wpb;
  const uint wi = lane - bi * wpb;
  const uint blk = group * nb + bi;
  const bool active = (group < groups) && (bi < nb) && (blk < nBlocks) && (sample < (uint)M);
  const uint nbrLane = bi * wpb + ((wi + 1u == wpb) ? 0u : wi + 1u);
  // This lane's positions: symbol offsets p = multiples of K inside [32wi, 32wi+32).
  const uint pBase = 32u * wi;
  const uint p0 = ((pBase + (uint)K - 1u) / (uint)K) * (uint)K;
  uint offs[NP];
  bool valid[NP];
  bool spill[NP];
  uint cols[NP];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i) {
    const uint p = p0 + i * (uint)K;
    valid[i] = active && (p < pBase + 32u);
    offs[i] = p - pBase;
    spill[i] = offs[i] + (uint)L > 32u;
    const uint t = (uint)BT - 1u - p / (uint)K;
    cols[i] = blk * (uint)BT + t;
  }
  const ulong rowWords = (ulong)(INTERLEAVE ? 2 : nBlocks) * wpb;
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  const device T* xs = x + (ulong)sample * (ulong)R;
  const device uint32_t* col0 = codes + (INTERLEAVE
    ? (ulong)(blk / 2) * R * 2 * wpb + (blk % 2) * wpb : (ulong)blk * wpb) + wi;
  const uint mask = (1u << (uint)L) - 1u;
  float acc[NP];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i) acc[i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = active ? col0[(ulong)r * rowWords] : 0u;
    const uint nxt = metal::simd_shuffle(word, (ushort)nbrLane);
    const float xr = float(xs[r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i) {
      uint win = word >> offs[i];
      if (spill[i]) win |= nxt << (32u - offs[i]);
      win &= mask;
      acc[i] = metal::fma(TRELLIS_ROUND(TRELLIS_DECODE(win, lutTG, lut) * sr), xr, acc[i]);
    }
  }
  const ulong outBase = ((ulong)sample * (ulong)SPLITS + split) * (ulong)C;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i)
    if (valid[i]) partial[outBase + cols[i]] = acc[i];
`;

const BALANCED_SCATTER_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint block = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint nBlocks = (uint)C / (uint)BT;
  const uint zi = thread_position_in_grid.z;
  const uint sample = zi / (uint)SPLITS;
  const uint split = zi - sample * (uint)SPLITS;
  if (block >= nBlocks || sample >= (uint)M) return;
  const uint wpb = (uint)(BT * K / 32);
  const ulong rowWords = (ulong)(INTERLEAVE ? 2 : nBlocks) * wpb;
  const uint pBase = lane * 8u * (uint)K;
  const uint wi = pBase >> 5u;
  const uint off = pBase & 31u;
  const uint next = (wi + 1u == wpb) ? 0u : wi + 1u;
  const device uint32_t* words = codes + (INTERLEAVE
    ? (ulong)(block / 2) * R * 2 * wpb + (block % 2) * wpb : (ulong)block * wpb);
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  const device T* xs = x + (ulong)sample * (ulong)R;
  float acc[8];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < 8u; ++i) acc[i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = words[(ulong)r * rowWords + wi];
    const uint nxt = words[(ulong)r * rowWords + next];
    const uint lo = off == 0u ? word : (word >> off) | (nxt << (32u - off));
    const uint hi = off == 0u ? nxt : nxt >> off;
    const float xr = float(xs[r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) {
      const uint shift = i * (uint)K;
      uint win = lo >> shift;
      if (shift + (uint)L > 32u) win |= hi << (32u - shift);
      win &= (1u << (uint)L) - 1u;
      const float value = (float)trellis_y(win) * (1.0f / 147.800537109375f);
      acc[i] = metal::fma(value * sr, xr, acc[i]);
    }
  }
  const ulong outBase = ((ulong)sample * (ulong)SPLITS + split) * (ulong)C;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < 8u; ++i)
    partial[outBase + block * (uint)BT + (uint)BT - 1u - lane * 8u - i] = acc[i];
`;

const SCATTER_SHARED_M_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += 128u) lutTG[i] = lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint wpb = (uint)(BT * K / 32);
  const uint nb = 32u / wpb;                       // blocks per SIMD group
  const uint nBlocks = (uint)C / (uint)BT;
  const uint groups = (nBlocks + nb - 1u) / nb;
  const uint group = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint zi = thread_position_in_grid.z;
  const uint sample = 0u;
  const uint split = zi;
  const uint bi = lane / wpb;
  const uint wi = lane - bi * wpb;
  const uint blk = group * nb + bi;
  const bool active = (group < groups) && (bi < nb) && (blk < nBlocks) && (sample < (uint)M);
  const uint nbrLane = bi * wpb + ((wi + 1u == wpb) ? 0u : wi + 1u);
  // This lane's positions: symbol offsets p = multiples of K inside [32wi, 32wi+32).
  const uint pBase = 32u * wi;
  const uint p0 = ((pBase + (uint)K - 1u) / (uint)K) * (uint)K;
  uint offs[NP];
  bool valid[NP];
  bool spill[NP];
  uint cols[NP];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i) {
    const uint p = p0 + i * (uint)K;
    valid[i] = active && (p < pBase + 32u);
    offs[i] = p - pBase;
    spill[i] = offs[i] + (uint)L > 32u;
    const uint t = (uint)BT - 1u - p / (uint)K;
    cols[i] = blk * (uint)BT + t;
  }
  const ulong rowWords = (ulong)(INTERLEAVE ? 2 : nBlocks) * wpb;
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);

  const device uint32_t* col0 = codes + (INTERLEAVE
    ? (ulong)(blk / 2) * R * 2 * wpb + (blk % 2) * wpb : (ulong)blk * wpb) + wi;
  const uint mask = (1u << (uint)L) - 1u;
  float acc[M][NP];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m)
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i) acc[m][i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = active ? col0[(ulong)r * rowWords] : 0u;
    const uint nxt = metal::simd_shuffle(word, (ushort)nbrLane);
    float xr[M];
    #pragma clang loop unroll(full)
    for (uint m = 0; m < (uint)M; ++m) xr[m] = float(x[(ulong)m * (ulong)R + r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i) {
      uint win = word >> offs[i];
      if (spill[i]) win |= nxt << (32u - offs[i]);
      win &= mask;
      const float weight = TRELLIS_ROUND(TRELLIS_DECODE(win, lutTG, lut) * sr);
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m) acc[m][i] = metal::fma(weight, xr[m], acc[m][i]);
    }
  }
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const ulong outBase = ((ulong)m * (ulong)SPLITS + split) * (ulong)C;
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i)
      if (valid[i]) partial[outBase + cols[i]] = acc[m][i];
  }
`;

const BALANCED_SCATTER_SHARED_M_SOURCE = String.raw`
  // Model-owned tuning selects this table for measured small-M shapes.
  // Store integers so the reciprocal multiply retains its original rounding.
  threadgroup short codebookY[CODEBOOK ? 4096 : 1];
  if (CODEBOOK) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += threads_per_threadgroup.x)
      codebookY[i] = (short)trellis_y(i);
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint block = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint nBlocks = (uint)C / (uint)BT;
  const uint zi = thread_position_in_grid.z;
  const uint sample = 0u;
  const uint split = zi;
  if (block >= nBlocks || sample >= (uint)M) return;
  const uint wpb = (uint)(BT * K / 32);
  const ulong rowWords = (ulong)(INTERLEAVE ? 2 : nBlocks) * wpb;
  const uint pBase = lane * 8u * (uint)K;
  const uint wi = pBase >> 5u;
  const uint off = pBase & 31u;
  const uint next = (wi + 1u == wpb) ? 0u : wi + 1u;
  const device uint32_t* words = codes + (INTERLEAVE
    ? (ulong)(block / 2) * R * 2 * wpb + (block % 2) * wpb : (ulong)block * wpb);
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  float acc[M][8];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m)
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) acc[m][i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = words[(ulong)r * rowWords + wi];
    const uint nxt = words[(ulong)r * rowWords + next];
    const uint lo = off == 0u ? word : (word >> off) | (nxt << (32u - off));
    const uint hi = off == 0u ? nxt : nxt >> off;
    float xr[M];
    #pragma clang loop unroll(full)
    for (uint m = 0; m < (uint)M; ++m) xr[m] = float(x[(ulong)m * (ulong)R + r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) {
      const uint shift = i * (uint)K;
      uint win = lo >> shift;
      if (shift + (uint)L > 32u) win |= hi << (32u - shift);
      win &= (1u << (uint)L) - 1u;
      const float value = (CODEBOOK ? (float)codebookY[win] : (float)trellis_y(win)) * (1.0f / 147.800537109375f);
      const float weight = value * sr;
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m) acc[m][i] = metal::fma(weight, xr[m], acc[m][i]);
    }
  }
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const ulong outBase = ((ulong)m * (ulong)SPLITS + split) * (ulong)C;
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i)
      partial[outBase + block * (uint)BT + (uint)BT - 1u - lane * 8u - i] = acc[m][i];
  }
`;

let balancedScatter: MetalKernel | null = null;
let sharedScatter: { generic: MetalKernel; balanced: MetalKernel } | null = null;
function sharedScatterKernelSet() {
  return sharedScatter ??= {
    generic: new MetalKernel({
      name: "mlx_bun_trellis_scatter_shared_m", inputNames: ["x", "codes", "scales", "lut"],
      outputNames: ["partial"], source: SCATTER_SHARED_M_SOURCE, header: HEADER, ensureRowContiguous: true,
    }),
    balanced: new MetalKernel({
      name: "mlx_bun_trellis_scatter_balanced3_shared_m", inputNames: ["x", "codes", "scales", "lut"],
      outputNames: ["partial"], source: BALANCED_SCATTER_SHARED_M_SOURCE, header: HEADER, ensureRowContiguous: true,
    }),
  };
}
function balancedScatterKernel() {
  return balancedScatter ??= new MetalKernel({
    name: "mlx_bun_trellis_scatter_balanced3", inputNames: ["x", "codes", "scales", "lut"],
    outputNames: ["partial"], source: BALANCED_SCATTER_SOURCE, header: HEADER, ensureRowContiguous: true,
  });
}
let base: MetalKernel | undefined;
function scatterKernel(): MetalKernel {
  return base ??= new MetalKernel({ name: "mlx_bun_trellis_scatter",
    inputNames: ["x", "codes", "scales", "lut"], outputNames: ["partial"],
    source: SCATTER_SOURCE, header: HEADER, ensureRowContiguous: true });
}

/** Borrow [M, inFeatures] and axis-0 weights; return owned lazy [M, outFeatures].
 * The caller selects a supported variant and limits M to 1..4. */
export function trellisScatter(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, selected: number, useSharedScatterCodebook = false): MlxArray {
  const M = x2.shape[0]!;
  const wpb = wordsPerBlock(g.T, g.k);
  const nb = Math.floor(32 / wpb);
  if (nb < 1) throw new Error(`trellis scatter: block of ${wpb} words exceeds one SIMD group`);
  const groups = Math.ceil((g.cols / g.T) / nb);
  const NP = Math.ceil(32 / g.k);
  const balanced = selected >= 8 && selected <= 13 && g.k === 3 && g.T === 256 && g.L <= 12;
  const shared = selected >= 10 && selected <= 13 && M > 1;
  const codebook = useSharedScatterCodebook && selected === 13 &&
    (M === 3 || M === 4) && x2.dtype === Dtype.bfloat16 &&
    g.k === 3 && g.L === 12 && g.T === 256 && g.blockInterleave === 2;
  const kernel = shared
    ? balanced ? sharedScatterKernelSet().balanced : sharedScatterKernelSet().generic
    : balanced ? balancedScatterKernel() : scatterKernel();
  const [partial] = kernel.apply([x2, codes, scales, lutFor(g.L)], {
    outputs: [{ shape: [M, SCATTER_SPLITS, g.cols], dtype: Dtype.float32 }],
    grid: [THREADS, Math.ceil(groups / SG_PER_TG), (shared ? 1 : M) * SCATTER_SPLITS],
    threadGroup: [THREADS, 1, 1],
    templateDtypes: { T: x2.dtype },
    templateInts: { M, R: g.rows, C: g.cols, BT: g.T, K: g.k, L: g.L, SG_TG: SG_PER_TG,
      SPLITS: SCATTER_SPLITS, NP, VARIANT: decoderVariant(selected), INTERLEAVE: g.blockInterleave ?? 0, CODEBOOK: Number(codebook) },
  });
  const sum = ops.sumAxis(partial!, 1, false);
  partial!.dispose();
  const out = sum.astype(x2.dtype);
  sum.dispose();
  return out;
}
