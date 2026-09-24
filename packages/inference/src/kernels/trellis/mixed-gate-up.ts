import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisWeights } from "./geometry";
import { HEADER, lutFor, decoderVariant } from "./codebook";

import { TRELLIS_MATVEC_MAX_M as MATVEC_MAX_M } from "./reduce";
const THREADS = 128, SG_PER_TG = 4;

const MIXED_GATEUP_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += 128u) lutTG[i] = lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  if (row >= (uint)R) return;
  const uint gWpb = (uint)(BT * KG / 32);
  const uint uWpb = (uint)(BT * KU / 32);
  const uint runsPerBlock = (uint)BT / 32u;
  const uint nRuns = (uint)C / 32u;
  const device uint32_t* gRow = gcodes + (ulong)row * (ulong)((C / BT) * gWpb);
  const device uint32_t* uRow = ucodes + (ulong)row * (ulong)((C / BT) * uWpb);
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
    const device uint32_t* gw = gRow + blk * gWpb;
    const device uint32_t* uw = uRow + blk * uWpb;
    const uint gW0 = ((uint)BT - 32u - t0) * (uint)KG / 32u;
    const uint uW0 = ((uint)BT - 32u - t0) * (uint)KU / 32u;
    uint g[KG + 1];
    uint u[KU + 1];
    #pragma clang loop unroll(full)
    for (uint i = 0; i <= (uint)KG; ++i) {
      const uint wi = gW0 + i;
      g[i] = gw[wi >= gWpb ? wi - gWpb : wi];
    }
    #pragma clang loop unroll(full)
    for (uint i = 0; i <= (uint)KU; ++i) {
      const uint wi = uW0 + i;
      u[i] = uw[wi >= uWpb ? wi - uWpb : wi];
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
        const uint gb = (31u - j) * (uint)KG;
        const uint ub = (31u - j) * (uint)KU;
        const uint gwi = gb >> 5, goff = gb & 31u;
        const uint uwi = ub >> 5, uoff = ub & 31u;
        uint gwin = g[gwi] >> goff;
        uint uwin = u[uwi] >> uoff;
        if (goff + (uint)L > 32u) gwin |= g[gwi + 1] << (32u - goff);
        if (uoff + (uint)L > 32u) uwin |= u[uwi + 1] << (32u - uoff);
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
      if ((TAIL) == 1) {
        const T sigY = 1 / (1 + metal::exp(metal::abs(gateT)));
        const T sigmoidT = (gateT < 0) ? sigY : 1 - sigY;
        const T siluT = gateT * sigmoidT;
        mid[(ulong)m * (ulong)R + row] = siluT * upT;
      } else {
        const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
        const T siluT = T(float(gateT) * float(sigmoidT));
        mid[(ulong)m * (ulong)R + row] = T(float(siluT) * float(upT));
      }
    }
  }
`;

let mixedGateUp: MetalKernel | null = null;
function mixedGateUpKernel(): MetalKernel {
  return mixedGateUp ??= new MetalKernel({
    name: "mlx_bun_trellis_gateup_mixed_k",
    inputNames: ["x", "gcodes", "gscales", "ucodes", "uscales", "lut"],
    outputNames: ["mid"], source: MIXED_GATEUP_SOURCE, header: HEADER, ensureRowContiguous: true,
  });
}
/** Which SwiGLU arithmetic the mixed kernel reproduces: `"split"` is MLX's compiled
 *  swiglu over the two bf16 projections (bit-identical to gate.forward + up.forward +
 *  compiledSwiglu); `"fused"` is fusedGateUpSwiglu's float32 sigmoid. */
export type MixedGateUpTail = "split" | "fused";

/** silu(gate(x)) * up(x) for M <= 4 rows in one kernel when gate and up are coded
 *  at different k. Same lanes, accumulation order and bf16 SwiGLU boundaries as
 *  fusedGateUpSwiglu; each projection keeps its own word layout. */
export function fusedGateUpSwigluMixed(x: MlxArray, gate: TrellisWeights, up: TrellisWeights, selected: number,
  tail: MixedGateUpTail = "fused"): MlxArray {
  const g = gate.geometry, u = up.geometry;
  const lead = x.shape.slice(0, -1);
  const M = lead.reduce((a, b) => a * b, 1);
  if (M > MATVEC_MAX_M) throw new Error(`fusedGateUpSwigluMixed: M=${M} > ${MATVEC_MAX_M}`);
  const x2 = ops.reshape(x, [M, g.inFeatures]);
  const [mid] = mixedGateUpKernel().apply([x2, gate.codes, gate.scales, up.codes, up.scales, lutFor(g.L)], {
    outputs: [{ shape: [M, g.rows], dtype: x.dtype }],
    grid: [THREADS, Math.ceil(g.rows / SG_PER_TG), 1],
    threadGroup: [THREADS, 1, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { M, R: g.rows, C: g.cols, BT: g.T, KG: g.k, KU: u.k, L: g.L, ROWS_TG: SG_PER_TG,
      VARIANT: decoderVariant(selected), TAIL: tail === "split" ? 1 : 0 },
  });
  x2.dispose();
  const out = ops.reshape(mid!, [...lead, g.rows]);
  mid!.dispose();
  return out;
}
