import { MlxArray } from "@mlx-bun/mlx/array";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisGeometry } from "./geometry";
import { HEADER, lutFor, decoderVariant } from "./codebook";

const THREADS = 128, SG_PER_TG = 4;
export const TRELLIS_MATVEC_MAX_M = 4;

const REDUCE_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += 128u) lutTG[i] = lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  const uint sample = thread_position_in_grid.z;
  if (row >= (uint)R || sample >= (uint)M) return;
  const uint wpb = (uint)(BT * K / 32);
  const uint runsPerBlock = (uint)BT / 32u;
  const uint nRuns = (uint)C / 32u;
  const device uint32_t* codeRow = codes + (ulong)row * (ulong)((C / BT) * wpb);
  const device T* xs = x + (ulong)sample * (ulong)C;
  const float scale = float(scales[row]);
  float acc = 0.0f, acc2 = 0.0f;
  for (uint run = lane; run < nRuns; run += 32u) {
    const uint blk = run / runsPerBlock;
    const uint t0 = (run - blk * runsPerBlock) * 32u;
    const device uint32_t* bw = codeRow + blk * wpb;
    const uint w0 = ((uint)BT - 32u - t0) * (uint)K / 32u;
    uint w[K + 1];
    #pragma clang loop unroll(full)
    for (uint i = 0; i <= (uint)K; ++i) {
      const uint wi = w0 + i;
      w[i] = bw[wi >= wpb ? wi - wpb : wi];
    }
    const uint c0 = blk * (uint)BT + t0;
    const device metal::vec<T, 4>* x4 = (const device metal::vec<T, 4>*)(xs + c0);
    #pragma clang loop unroll(full)
    for (uint j4 = 0; j4 < 8u; ++j4) {
      const float4 xv = float4(x4[j4]);
      #pragma clang loop unroll(full)
      for (uint q = 0; q < 4u; ++q) {
        const uint j = j4 * 4u + q;
        const uint b = (31u - j) * (uint)K;
        const uint wi = b >> 5;
        const uint off = b & 31u;
        uint win = w[wi] >> off;
        if (off + (uint)L > 32u) win |= w[wi + 1] << (32u - off);
        win &= (1u << (uint)L) - 1u;
        const float wv = TRELLIS_ROUND(TRELLIS_DECODE(win, lutTG, lut) * scale);
        if (q & 1u) acc2 = metal::fma(wv, xv[q], acc2);
        else acc = metal::fma(wv, xv[q], acc);
      }
    }
  }
  const float v = metal::simd_sum(acc + acc2);
  if (lane == 0u) out[(ulong)sample * (ulong)R + row] = T(v);
`;

const REDUCE_SHARED_M_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += 128u) lutTG[i] = lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  const uint sample = 0u;
  if (row >= (uint)R || sample >= (uint)M) return;
  const uint wpb = (uint)(BT * K / 32);
  const uint runsPerBlock = (uint)BT / 32u;
  const uint nRuns = (uint)C / 32u;
  const device uint32_t* codeRow = codes + (ulong)row * (ulong)((C / BT) * wpb);
  const float scale = float(scales[row]);
  float acc[M], acc2[M];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) { acc[m] = 0.0f; acc2[m] = 0.0f; }
  for (uint run = lane; run < nRuns; run += 32u) {
    const uint blk = run / runsPerBlock;
    const uint t0 = (run - blk * runsPerBlock) * 32u;
    const device uint32_t* bw = codeRow + blk * wpb;
    const uint w0 = ((uint)BT - 32u - t0) * (uint)K / 32u;
    uint w[K + 1];
    #pragma clang loop unroll(full)
    for (uint i = 0; i <= (uint)K; ++i) {
      const uint wi = w0 + i;
      w[i] = bw[wi >= wpb ? wi - wpb : wi];
    }
    const uint c0 = blk * (uint)BT + t0;
    #pragma clang loop unroll(full)
    for (uint j4 = 0; j4 < 8u; ++j4) {
      float4 xv[M];
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m)
        xv[m] = float4(((const device metal::vec<T, 4>*)(x + (ulong)m * (ulong)C + c0))[j4]);
      #pragma clang loop unroll(full)
      for (uint q = 0; q < 4u; ++q) {
        const uint j = j4 * 4u + q;
        const uint b = (31u - j) * (uint)K;
        const uint wi = b >> 5;
        const uint off = b & 31u;
        uint win = w[wi] >> off;
        if (off + (uint)L > 32u) win |= w[wi + 1] << (32u - off);
        win &= (1u << (uint)L) - 1u;
        const float wv = TRELLIS_ROUND(TRELLIS_DECODE(win, lutTG, lut) * scale);
        #pragma clang loop unroll(full)
        for (uint m = 0; m < (uint)M; ++m) {
          if (q & 1u) acc2[m] = metal::fma(wv, xv[m][q], acc2[m]);
          else acc[m] = metal::fma(wv, xv[m][q], acc[m]);
        }
      }
    }
  }
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const float v = metal::simd_sum(acc[m] + acc2[m]);
    if (lane == 0u) out[(ulong)m * (ulong)R + row] = T(v);
  }
`;

let base: MetalKernel | undefined, shared: MetalKernel | undefined;
function reduceKernel(): MetalKernel {
  return base ??= new MetalKernel({ name: "mlx_bun_trellis_reduce",
    inputNames: ["x", "codes", "scales", "lut"], outputNames: ["out"],
    source: REDUCE_SOURCE, header: HEADER, ensureRowContiguous: true });
}
function sharedKernel(): MetalKernel {
  return shared ??= new MetalKernel({ name: "mlx_bun_trellis_reduce_shared_m",
    inputNames: ["x", "codes", "scales", "lut"], outputNames: ["out"],
    source: REDUCE_SHARED_M_SOURCE, header: HEADER, ensureRowContiguous: true });
}

/** Borrow [M, inFeatures] and axis-1 weights; return owned lazy [M, outFeatures].
 * The caller selects a supported variant and limits M to 1..4. */
export function trellisReduce(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, selected: number): MlxArray {
  const M = x2.shape[0]!;
  const shared = selected >= 7 && selected <= 13 && M > 1;
  const kernel = shared ? sharedKernel() : reduceKernel();
  const [out] = kernel.apply([x2, codes, scales, lutFor(g.L)], {
    outputs: [{ shape: [M, g.rows], dtype: x2.dtype }],
    grid: [THREADS, Math.ceil(g.rows / SG_PER_TG), shared ? 1 : M],
    threadGroup: [THREADS, 1, 1],
    templateDtypes: { T: x2.dtype },
    templateInts: { M, R: g.rows, C: g.cols, BT: g.T, K: g.k, L: g.L, ROWS_TG: SG_PER_TG, VARIANT: decoderVariant(selected) },
  });
  return out!;
}
