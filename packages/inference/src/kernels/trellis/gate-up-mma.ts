import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisWeights } from "./geometry";
import { HEADER } from "./codebook";

// Verify-width fused gate/up/SwiGLU on the simdgroup matrix unit: one
// simdgroup owns an 8-output-row tile for up to 8 activation rows. The K index
// inside each 8x8 step is permuted so that A column i at step s is position
// base + 32·i + s: every lane decodes two contiguous 32-position runs per
// projection from K+1 words (the matvec's word window, unrolled) straight into
// its A fragment and reads its two activation rows contiguously, so per-weight
// decode work matches the one-row matvec. Raw code values y accumulate in f32;
// scale·(1/147.8) applies once per output. Gate and up may differ in bit width.
// Not bit-identical to the per-lane matvec reduction (different summation
// order); gate it by KL. Fragment coordinates follow MLX steel's Metal layout.
const SG_TG = 4, MT = 1;

const RUN3_HEADER = String.raw`
template <int K, int BT_>
inline void load_run(const device uint32_t* rowCodes, uint run, thread uint* w) {
  const uint wpb = (uint)(BT_ * K / 32);
  const uint runsPerBlock = (uint)BT_ / 32u;
  const uint blk = run / runsPerBlock;
  const uint t0 = (run - blk * runsPerBlock) * 32u;
  const device uint32_t* bw = rowCodes + blk * wpb;
  const uint w0 = ((uint)BT_ - 32u - t0) * (uint)K / 32u;
  #pragma clang loop unroll(full)
  for (uint i = 0; i <= (uint)K; ++i) {
    const uint wi = w0 + i;
    w[i] = bw[wi >= wpb ? wi - wpb : wi];
  }
}
template <int K, int L_>
inline uint run_state(thread const uint* w, uint j) {
  const uint b = (31u - j) * (uint)K;
  const uint wi = b >> 5;
  const uint off = b & 31u;
  uint win = w[wi] >> off;
  if (off + (uint)L_ > 32u) win |= w[wi + 1] << (32u - off);
  return win & ((1u << (uint)L_) - 1u);
}
`;
const SOURCE_V3 = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint n0 = (threadgroup_position_in_grid.y * (uint)SG_TG + sg) * 8u;
  if (n0 >= (uint)R) return;
  const uint fm = ((lane / 4u) & 4u) + ((lane / 2u) % 4u);
  const uint fn = ((lane / 4u) & 2u) * 2u + (lane % 2u) * 2u;
  const uint row = n0 + fm;
  const device uint32_t* gRow = gcodes + (ulong)row * (ulong)((C / BT) * (BT * KG / 32));
  const device uint32_t* uRow = ucodes + (ulong)row * (ulong)((C / BT) * (BT * KU / 32));
  // MT activation blocks of 8 rows; grid z walks chunks of 8·MT rows.
  const uint mBase = threadgroup_position_in_grid.z * 8u * (uint)MT;
  bool m0[MT], m1[MT];
  const device T* x0[MT];
  const device T* x1[MT];
  #pragma clang loop unroll(full)
  for (uint bk = 0; bk < (uint)MT; ++bk) {
    const uint r0 = mBase + 8u * bk + fn;
    m0[bk] = r0 < (uint)M; m1[bk] = r0 + 1u < (uint)M;
    x0[bk] = x + (ulong)(m0[bk] ? r0 : 0u) * (ulong)C + fm * 32u;
    x1[bk] = x + (ulong)(m1[bk] ? r0 + 1u : 0u) * (ulong)C + fm * 32u;
  }
  metal::simdgroup_float8x8 accG[MT], accU[MT];
  #pragma clang loop unroll(full)
  for (uint bk = 0; bk < (uint)MT; ++bk) {
    accG[bk] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
    accU[bk] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
  }
  for (uint base = 0; base < (uint)C; base += 256u) {
    const uint runA = base / 32u + fn;
    uint ga[KG + 1], gb[KG + 1], ua[KU + 1], ub[KU + 1];
    load_run<KG, BT>(gRow, runA, ga);
    load_run<KG, BT>(gRow, runA + 1u, gb);
    load_run<KU, BT>(uRow, runA, ua);
    load_run<KU, BT>(uRow, runA + 1u, ub);
    #pragma clang loop unroll(full)
    for (uint s4 = 0; s4 < 8u; ++s4) {
      float4 va[MT], vb[MT];
      #pragma clang loop unroll(full)
      for (uint bk = 0; bk < (uint)MT; ++bk) {
        va[bk] = m0[bk] ? float4(((const device metal::vec<T, 4>*)(x0[bk] + base))[s4]) : float4(0.0f);
        vb[bk] = m1[bk] ? float4(((const device metal::vec<T, 4>*)(x1[bk] + base))[s4]) : float4(0.0f);
      }
      #pragma clang loop unroll(full)
      for (uint q = 0; q < 4u; ++q) {
        const uint j = s4 * 4u + q;
        metal::simdgroup_float8x8 aG, aU;
        aG.thread_elements()[0] = trellis_y_f32((run_state<KG, L>(ga, j)));
        aG.thread_elements()[1] = trellis_y_f32((run_state<KG, L>(gb, j)));
        aU.thread_elements()[0] = trellis_y_f32((run_state<KU, L>(ua, j)));
        aU.thread_elements()[1] = trellis_y_f32((run_state<KU, L>(ub, j)));
        #pragma clang loop unroll(full)
        for (uint bk = 0; bk < (uint)MT; ++bk) {
          metal::simdgroup_float8x8 b;
          b.thread_elements()[0] = va[bk][q];
          b.thread_elements()[1] = vb[bk][q];
          metal::simdgroup_multiply_accumulate(accG[bk], aG, b, accG[bk]);
          metal::simdgroup_multiply_accumulate(accU[bk], aU, b, accU[bk]);
        }
      }
    }
  }
  const float gs = float(gscales[row]) * TRELLIS_RCP;
  const float us = float(uscales[row]) * TRELLIS_RCP;
  #pragma clang loop unroll(full)
  for (uint bk = 0; bk < (uint)MT; ++bk)
    #pragma clang loop unroll(full)
    for (uint j = 0; j < 2u; ++j) {
      const uint m = mBase + 8u * bk + fn + j;
      if (m >= (uint)M) continue;
      const T gateT = T(accG[bk].thread_elements()[j] * gs);
      const T upT = T(accU[bk].thread_elements()[j] * us);
      const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
      const T siluT = T(float(gateT) * float(sigmoidT));
      mid[(ulong)m * (ulong)R + row] = T(float(siluT) * float(upT));
    }
`;

let kernel: MetalKernel | undefined;

/** silu(gate(x))·up(x) for 1..8 activation rows. Gate and up share their
 *  axis-1 geometry (rows a multiple of 8, columns of 256); their bit widths may
 *  differ. Borrows x and the weights; returns owned lazy output with x's
 *  leading dimensions. */
export function gateUpMma(x: MlxArray, gate: TrellisWeights, up: TrellisWeights): MlxArray {
  const g = gate.geometry, u = up.geometry;
  const lead = x.shape.slice(0, -1), M = lead.reduce((a, b) => a * b, 1);
  if (M < 1 || M > 8) throw new Error(`gateUpMma: M=${M} outside 1..8`);
  if (g.axis !== 1 || u.axis !== 1 || g.rows !== u.rows || g.cols !== u.cols || g.T !== u.T || g.L !== u.L ||
      g.rows % 8 !== 0 || g.cols % 256 !== 0 || g.T % 32 !== 0)
    throw new Error("gateUpMma: unsupported gate/up geometry");
  kernel ??= new MetalKernel({ name: "mlx_bun_trellis_gateup_mma", inputNames: ["x", "gcodes", "gscales", "ucodes", "uscales"],
    outputNames: ["mid"], source: SOURCE_V3, header: HEADER + RUN3_HEADER, ensureRowContiguous: true });
  const x2 = ops.reshape(x, [M, g.inFeatures]);
  const [mid] = kernel.apply([x2, gate.codes, gate.scales, up.codes, up.scales], {
    outputs: [{ shape: [M, g.rows], dtype: x.dtype }],
    grid: [32 * SG_TG, Math.ceil(g.rows / 8 / SG_TG), 1], threadGroup: [32 * SG_TG, 1, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { M, R: g.rows, C: g.cols, BT: g.T, KG: g.k, KU: u.k, L: g.L, SG_TG, MT },
  });
  x2.dispose();
  const out = ops.reshape(mid!, [...lead, g.rows]);
  mid!.dispose();
  return out;
}
