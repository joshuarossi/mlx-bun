import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisWeights } from "./geometry";
import { HEADER } from "./codebook";
import { TRELLIS_THREADS, TRELLIS_SG_PER_TG } from "./launch";

// Fused gate/up/SwiGLU for layers whose gate and up were coded at different
// bit widths (KG, KU), 1..4 activation rows sharing each decoded weight. Row
// scales are factored out of the reduction as in gate-up-factored.ts. The
// SwiGLU tail is MLX's compiled swiglu over bf16 gate and up (sigmoid via
// exp(|g|) in T), the arithmetic of two separate projections plus swiglu.
const SOURCE = String.raw`
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
  float gAcc[M], uAcc[M];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) { gAcc[m] = 0.0f; uAcc[m] = 0.0f; }
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
        const float gv = trellis_y_f32(gwin);
        const float uv = trellis_y_f32(uwin);
        #pragma clang loop unroll(full)
        for (uint m = 0; m < (uint)M; ++m) {
          const float xv = xv4[m][q];
          gAcc[m] = metal::fma(gv, xv, gAcc[m]); uAcc[m] = metal::fma(uv, xv, uAcc[m]);
        }
      }
    }
  }
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const float gate = metal::simd_sum(gAcc[m]) * (gScale * TRELLIS_RCP);
    const float up = metal::simd_sum(uAcc[m]) * (uScale * TRELLIS_RCP);
    if (lane == 0u) {
      const T gateT = T(gate);
      const T upT = T(up);
      const T sigY = 1 / (1 + metal::exp(metal::abs(gateT)));
      const T sigmoidT = (gateT < 0) ? sigY : 1 - sigY;
      const T siluT = gateT * sigmoidT;
      mid[(ulong)m * (ulong)R + row] = siluT * upT;
    }
  }
`;

let kernel: MetalKernel | undefined;

/** silu(gate(x))·up(x) for 1..4 activation rows when gate and up share their
 *  axis-1 geometry but not their bit width. Borrows x and the weights; returns
 *  owned lazy output with x's leading dimensions. */
export function mixedGateUpFactoredRows(x: MlxArray, gate: TrellisWeights, up: TrellisWeights): MlxArray {
  const g = gate.geometry, u = up.geometry;
  if (g.axis !== 1 || u.axis !== 1 || g.k === u.k || g.rows !== u.rows || g.cols !== u.cols || g.T !== u.T || g.L !== u.L)
    throw new Error("mixedGateUpFactoredRows: gate and up need the same axis-1 geometry at different widths");
  const lead = x.shape.slice(0, -1);
  const M = lead.reduce((a, b) => a * b, 1);
  if (M < 1 || M > 4) throw new Error(`mixedGateUpFactoredRows: M=${M} outside 1..4`);
  kernel ??= new MetalKernel({ name: "mlx_bun_trellis_gateup_mixed_factored", inputNames: ["x", "gcodes", "gscales", "ucodes", "uscales"],
    outputNames: ["mid"], source: SOURCE, header: HEADER, ensureRowContiguous: true });
  const x2 = ops.reshape(x, [M, g.inFeatures]);
  const [mid] = kernel.apply([x2, gate.codes, gate.scales, up.codes, up.scales], {
    outputs: [{ shape: [M, g.rows], dtype: x.dtype }],
    grid: [TRELLIS_THREADS, Math.ceil(g.rows / TRELLIS_SG_PER_TG), 1],
    threadGroup: [TRELLIS_THREADS, 1, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { M, R: g.rows, C: g.cols, BT: g.T, KG: g.k, KU: u.k, L: g.L, ROWS_TG: TRELLIS_SG_PER_TG },
  });
  x2.dispose();
  const out = ops.reshape(mid!, [...lead, g.rows]);
  mid!.dispose();
  return out;
}
