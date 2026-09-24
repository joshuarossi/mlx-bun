import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisWeights } from "./geometry";
import { HEADER, lutFor, decoderVariant } from "./codebook";

import { TRELLIS_MATVEC_MAX_M as MATVEC_MAX_M } from "./reduce";
const THREADS = 128, SG_PER_TG = 4;

const GATEUP_SOURCE = String.raw`
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
  const ulong rowWords = (ulong)((C / BT) * wpb);
  const device uint32_t* gRow = gcodes + (ulong)row * rowWords;
  const device uint32_t* uRow = ucodes + (ulong)row * rowWords;
  const device T* xs = x + (ulong)sample * (ulong)C;
  const float gScale = float(gscales[row]);
  const float uScale = float(uscales[row]);
  float gAcc = 0.0f, gAcc2 = 0.0f;
  float uAcc = 0.0f, uAcc2 = 0.0f;
  for (uint run = lane; run < nRuns; run += 32u) {
    const uint blk = run / runsPerBlock;
    const uint t0 = (run - blk * runsPerBlock) * 32u;
    const device uint32_t* gw = gRow + blk * wpb;
    const device uint32_t* uw = uRow + blk * wpb;
    const uint w0 = ((uint)BT - 32u - t0) * (uint)K / 32u;
    uint g[K + 1];
    uint u[K + 1];
    #pragma clang loop unroll(full)
    for (uint i = 0; i <= (uint)K; ++i) {
      const uint wi = w0 + i;
      const uint idx = wi >= wpb ? wi - wpb : wi;
      g[i] = gw[idx];
      u[i] = uw[idx];
    }
    const uint c0 = blk * (uint)BT + t0;
    const device metal::vec<T, 4>* x4 = (const device metal::vec<T, 4>*)(xs + c0);
    #pragma clang loop unroll(full)
    for (uint j4 = 0; j4 < 8u; ++j4) {
      const float4 xv4 = float4(x4[j4]);
      #pragma clang loop unroll(full)
      for (uint q = 0; q < 4u; ++q) {
        const uint j = j4 * 4u + q;
        const uint b = (31u - j) * (uint)K;
        const uint wi = b >> 5;
        const uint off = b & 31u;
        uint gwin = g[wi] >> off;
        uint uwin = u[wi] >> off;
        if (off + (uint)L > 32u) { gwin |= g[wi + 1] << (32u - off); uwin |= u[wi + 1] << (32u - off); }
        gwin &= (1u << (uint)L) - 1u;
        uwin &= (1u << (uint)L) - 1u;
        const float xv = xv4[q];
        const float gv = TRELLIS_ROUND(TRELLIS_DECODE(gwin, lutTG, lut) * gScale);
        const float uv = TRELLIS_ROUND(TRELLIS_DECODE(uwin, lutTG, lut) * uScale);
        if (q & 1u) { gAcc2 = metal::fma(gv, xv, gAcc2); uAcc2 = metal::fma(uv, xv, uAcc2); }
        else { gAcc = metal::fma(gv, xv, gAcc); uAcc = metal::fma(uv, xv, uAcc); }
      }
    }
  }
  const float gate = metal::simd_sum(gAcc + gAcc2);
  const float up = metal::simd_sum(uAcc + uAcc2);
  if (lane == 0u) {
    const T gateT = T(gate);
    const T upT = T(up);
    const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
    const T siluT = T(float(gateT) * float(sigmoidT));
    mid[(ulong)sample * (ulong)R + row] = T(float(siluT) * float(upT));
  }
`;

const GATEUP_SHARED_M_SOURCE = String.raw`
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
  const ulong rowWords = (ulong)((C / BT) * wpb);
  const device uint32_t* gRow = gcodes + (ulong)row * rowWords;
  const device uint32_t* uRow = ucodes + (ulong)row * rowWords;
  const float gScale = float(gscales[row]);
  const float uScale = float(uscales[row]);
  float gAcc[M], gAcc2[M], uAcc[M], uAcc2[M];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    gAcc[m] = 0.0f; gAcc2[m] = 0.0f; uAcc[m] = 0.0f; uAcc2[m] = 0.0f;
  }
  for (uint run = lane; run < nRuns; run += 32u) {
    const uint blk = run / runsPerBlock;
    const uint t0 = (run - blk * runsPerBlock) * 32u;
    const device uint32_t* gw = gRow + blk * wpb;
    const device uint32_t* uw = uRow + blk * wpb;
    const uint w0 = ((uint)BT - 32u - t0) * (uint)K / 32u;
    uint g[K + 1];
    uint u[K + 1];
    #pragma clang loop unroll(full)
    for (uint i = 0; i <= (uint)K; ++i) {
      const uint wi = w0 + i;
      const uint idx = wi >= wpb ? wi - wpb : wi;
      g[i] = gw[idx];
      u[i] = uw[idx];
    }
    const uint c0 = blk * (uint)BT + t0;
    #pragma clang loop unroll(full)
    for (uint j4 = 0; j4 < 8u; ++j4) {
      float4 xv4[M];
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m)
        xv4[m] = float4(((const device metal::vec<T, 4>*)(x + (ulong)m * (ulong)C + c0))[j4]);
      #pragma clang loop unroll(full)
      for (uint q = 0; q < 4u; ++q) {
        const uint j = j4 * 4u + q;
        const uint b = (31u - j) * (uint)K;
        const uint wi = b >> 5;
        const uint off = b & 31u;
        uint gwin = g[wi] >> off;
        uint uwin = u[wi] >> off;
        if (off + (uint)L > 32u) { gwin |= g[wi + 1] << (32u - off); uwin |= u[wi + 1] << (32u - off); }
        gwin &= (1u << (uint)L) - 1u;
        uwin &= (1u << (uint)L) - 1u;
        const float gv = TRELLIS_ROUND(TRELLIS_DECODE(gwin, lutTG, lut) * gScale);
        const float uv = TRELLIS_ROUND(TRELLIS_DECODE(uwin, lutTG, lut) * uScale);
        #pragma clang loop unroll(full)
        for (uint m = 0; m < (uint)M; ++m) {
          const float xv = xv4[m][q];
          if (q & 1u) { gAcc2[m] = metal::fma(gv, xv, gAcc2[m]); uAcc2[m] = metal::fma(uv, xv, uAcc2[m]); }
          else { gAcc[m] = metal::fma(gv, xv, gAcc[m]); uAcc[m] = metal::fma(uv, xv, uAcc[m]); }
        }
      }
    }
  }
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const float gate = metal::simd_sum(gAcc[m] + gAcc2[m]);
    const float up = metal::simd_sum(uAcc[m] + uAcc2[m]);
    if (lane == 0u) {
      const T gateT = T(gate);
      const T upT = T(up);
      const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
      const T siluT = T(float(gateT) * float(sigmoidT));
      mid[(ulong)m * (ulong)R + row] = T(float(siluT) * float(upT));
    }
  }
`;

let base: MetalKernel | undefined, shared: MetalKernel | undefined;
function gateUpKernel(): MetalKernel {
  return base ??= new MetalKernel({ name: "mlx_bun_trellis_gateup_swiglu",
    inputNames: ["x", "gcodes", "gscales", "ucodes", "uscales", "lut"], outputNames: ["mid"],
    source: GATEUP_SOURCE, header: HEADER, ensureRowContiguous: true });
}
function sharedGateUpKernel(): MetalKernel {
  return shared ??= new MetalKernel({ name: "mlx_bun_trellis_gateup_shared_m",
    inputNames: ["x", "gcodes", "gscales", "ucodes", "uscales", "lut"], outputNames: ["mid"],
    source: GATEUP_SHARED_M_SOURCE, header: HEADER, ensureRowContiguous: true });
}

/** Borrow matching axis-1 gate/up weights with the same bit width; M must be 1..4.
 * Return owned lazy SwiGLU output, retaining the input's leading dimensions. */
export function fusedGateUpSwiglu(x: MlxArray, gate: TrellisWeights, up: TrellisWeights, selected: number): MlxArray {
  const g = gate.geometry;
  const lead = x.shape.slice(0, -1);
  const M = lead.reduce((a, b) => a * b, 1);
  if (M > MATVEC_MAX_M) throw new Error(`fusedGateUpSwiglu: M=${M} > ${MATVEC_MAX_M}`);
  const shared = selected >= 7 && selected <= 13 && M > 1;
  const kernel = shared ? sharedGateUpKernel() : gateUpKernel();
  const x2 = ops.reshape(x, [M, g.inFeatures]);
  const [mid] = kernel.apply([x2, gate.codes, gate.scales, up.codes, up.scales, lutFor(g.L)], {
    outputs: [{ shape: [M, g.rows], dtype: x.dtype }],
    grid: [THREADS, Math.ceil(g.rows / SG_PER_TG), shared ? 1 : M],
    threadGroup: [THREADS, 1, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { M, R: g.rows, C: g.cols, BT: g.T, K: g.k, L: g.L, ROWS_TG: SG_PER_TG, VARIANT: decoderVariant(selected) },
  });
  x2.dispose();
  const out = ops.reshape(mid!, [...lead, g.rows]);
  mid!.dispose();
  return out;
}
