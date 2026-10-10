import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisWeights } from "./geometry";
import { HEADER } from "./codebook";
import { TRELLIS_THREADS, TRELLIS_SG_PER_TG } from "./launch";

// Fused gate/up/SwiGLU over same-width axis-1 Trellis codes with the row scale
// factored out: each weight contributes its code value y (trellis_y_f32), and
// scale·(1/147.8) multiplies each output once after the reduction. Same lanes
// and runs as fusedGateUpSwiglu; reassociated relative to its f32 code·scale
// weights (not bit-identical; gate by KL).

// One activation row; two accumulators per projection (even/odd positions).
const ROW_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  if (row >= (uint)R) return;
  const uint wpb = (uint)(BT * K / 32);
  const uint runsPerBlock = (uint)BT / 32u;
  const uint nRuns = (uint)C / 32u;
  const ulong rowWords = (ulong)((C / BT) * wpb);
  const device uint32_t* gRow = gcodes + (ulong)row * rowWords;
  const device uint32_t* uRow = ucodes + (ulong)row * rowWords;
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
    const device metal::vec<T, 4>* x4 = (const device metal::vec<T, 4>*)(x + c0);
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
        const float gv = trellis_y_f32(gwin);
        const float uv = trellis_y_f32(uwin);
        if (q & 1u) { gAcc2 = metal::fma(gv, xv, gAcc2); uAcc2 = metal::fma(uv, xv, uAcc2); }
        else { gAcc = metal::fma(gv, xv, gAcc); uAcc = metal::fma(uv, xv, uAcc); }
      }
    }
  }
  const float gate = metal::simd_sum(gAcc + gAcc2) * (gScale * TRELLIS_RCP);
  const float up = metal::simd_sum(uAcc + uAcc2) * (uScale * TRELLIS_RCP);
  if (lane == 0u) {
    const T gateT = T(gate);
    const T upT = T(up);
    const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
    const T siluT = T(float(gateT) * float(sigmoidT));
    mid[row] = T(float(siluT) * float(upT));
  }
`;

// M activation rows share each decoded weight; one accumulator per row and
// projection (the rows supply the independent FMA chains).
const ROWS_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  if (row >= (uint)R) return;
  const uint wpb = (uint)(BT * K / 32);
  const uint runsPerBlock = (uint)BT / 32u;
  const uint nRuns = (uint)C / 32u;
  const ulong rowWords = (ulong)((C / BT) * wpb);
  const device uint32_t* gRow = gcodes + (ulong)row * rowWords;
  const device uint32_t* uRow = ucodes + (ulong)row * rowWords;
  const float gScale = float(gscales[row]);
  const float uScale = float(uscales[row]);
  float gAcc[M], uAcc[M];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) { gAcc[m] = 0.0f; uAcc[m] = 0.0f; }
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
      const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
      const T siluT = T(float(gateT) * float(sigmoidT));
      mid[(ulong)m * (ulong)R + row] = T(float(siluT) * float(upT));
    }
  }
`;

const INPUTS = ["x", "gcodes", "gscales", "ucodes", "uscales"];
let rowKernel: MetalKernel | undefined, rowsKernel: MetalKernel | undefined;

function check(name: string, gate: TrellisWeights, up: TrellisWeights): void {
  const a = gate.geometry, b = up.geometry;
  if (a.axis !== 1 || b.axis !== 1 || a.k !== b.k || a.rows !== b.rows || a.cols !== b.cols || a.T !== b.T || a.L !== b.L)
    throw new Error(`${name}: gate and up need the same axis-1 geometry`);
}
function launch(kernel: MetalKernel, x: MlxArray, gate: TrellisWeights, up: TrellisWeights, M: number): MlxArray {
  const g = gate.geometry, lead = x.shape.slice(0, -1);
  const x2 = ops.reshape(x, [M, g.inFeatures]);
  const [mid] = kernel.apply([x2, gate.codes, gate.scales, up.codes, up.scales], {
    outputs: [{ shape: [M, g.rows], dtype: x.dtype }],
    grid: [TRELLIS_THREADS, Math.ceil(g.rows / TRELLIS_SG_PER_TG), 1],
    threadGroup: [TRELLIS_THREADS, 1, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { M, R: g.rows, C: g.cols, BT: g.T, K: g.k, L: g.L, ROWS_TG: TRELLIS_SG_PER_TG },
  });
  x2.dispose();
  const out = ops.reshape(mid!, [...lead, g.rows]);
  mid!.dispose();
  return out;
}

/** silu(gate(x))·up(x) for exactly one activation row. Borrows x and the
 *  weights; returns owned lazy output with x's leading dimensions. */
export function gateUpFactoredRow(x: MlxArray, gate: TrellisWeights, up: TrellisWeights): MlxArray {
  check("gateUpFactoredRow", gate, up);
  if (x.size !== x.shape.at(-1)) throw new Error("gateUpFactoredRow: expects one activation row");
  rowKernel ??= new MetalKernel({ name: "mlx_bun_trellis_gateup_factored_row", inputNames: INPUTS,
    outputNames: ["mid"], source: ROW_SOURCE, header: HEADER, ensureRowContiguous: true });
  return launch(rowKernel, x, gate, up, 1);
}

/** silu(gate(x))·up(x) for 2..4 activation rows sharing each decoded weight. */
export function gateUpFactoredRows(x: MlxArray, gate: TrellisWeights, up: TrellisWeights): MlxArray {
  check("gateUpFactoredRows", gate, up);
  const M = x.size / x.shape.at(-1)!;
  if (M < 2 || M > 4) throw new Error(`gateUpFactoredRows: M=${M} outside 2..4`);
  rowsKernel ??= new MetalKernel({ name: "mlx_bun_trellis_gateup_factored_rows", inputNames: INPUTS,
    outputNames: ["mid"], source: ROWS_SOURCE, header: HEADER, ensureRowContiguous: true });
  return launch(rowsKernel, x, gate, up, M);
}
