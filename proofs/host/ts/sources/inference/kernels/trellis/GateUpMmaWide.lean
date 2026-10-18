import host.ts.Source
namespace Host.Ts.Sources.Inference.Kernels.Trellis.GateUpMmaWide
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/kernels/trellis/gate-up-mma-wide.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisWeights } from "./geometry";
import { HEADER } from "./codebook";

// Fused gate/up/SwiGLU on the simdgroup matrix unit for any number of
// activation rows: gate-up-mma's fragments, decode and accumulation (each
// output row bit for bit the same), with every decoded weight fragment feeding
// an MMA for MT blocks of 8 rows. A threadgroup of SG_TG simdgroups (8 output
// rows each) generates the 2^L code values y once into a threadgroup codebook
// (half: every y in [-510, 510] is exact) and stages the activations of its
// 8·MT rows over each 256-position K step in threadgroup memory, where every
// simdgroup reads its B fragments; grid z walks chunks of 8·MT rows. The row
// count is read at run time (one pipeline per geometry and MT). Measured on
// the M1 Max at the Qwen MLP shape (17408 x 5120, 3-bit): 9 rows 1.01 ms, 16
// 0.98, 24 1.52, 32 1.87, 64 3.68, 128 7.22 for gate and up together,
// against 11.3, 10.9, 10.9, 9.5 (the prefill tiles), 5.3 and 8.1 (weight
// expansion and GEMM).
const SG_TG = 8;

const RUN_HEADER = String.raw`
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

const SOURCE = String.raw`
  const uint M = (uint)x_shape[0];
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint tid = sg * 32u + lane;
  threadgroup half codebook[1 << L];
  threadgroup T xs[8 * MT][256];
  for (uint i = tid; i < (1u << (uint)L); i += 32u * (uint)SG_TG) codebook[i] = half(trellis_y_f32(i));
  const uint n0 = (threadgroup_position_in_grid.y * (uint)SG_TG + sg) * 8u;
  const uint fm = ((lane / 4u) & 4u) + ((lane / 2u) % 4u);
  const uint fn = ((lane / 4u) & 2u) * 2u + (lane % 2u) * 2u;
  // A simdgroup past the last output row still stages its share and meets every barrier; it writes nothing.
  const uint row = metal::min(n0 + fm, (uint)R - 1u);
  const device uint32_t* gRow = gcodes + (ulong)row * (ulong)((C / BT) * (BT * KG / 32));
  const device uint32_t* uRow = ucodes + (ulong)row * (ulong)((C / BT) * (BT * KU / 32));
  const uint mBase = threadgroup_position_in_grid.z * 8u * (uint)MT;
  metal::simdgroup_float8x8 accG[MT], accU[MT];
  #pragma clang loop unroll(full)
  for (uint bk = 0; bk < (uint)MT; ++bk) {
    accG[bk] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
    accU[bk] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
  }
  for (uint base = 0; base < (uint)C; base += 256u) {
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
    for (uint e = tid; e < 8u * (uint)MT * 64u; e += 32u * (uint)SG_TG) {
      const uint r = e / 64u, c4 = e % 64u, m = mBase + r;
      const metal::vec<T, 4> v = m < M ? ((const device metal::vec<T, 4>*)(x + (ulong)m * (ulong)C + base))[c4]
        : metal::vec<T, 4>(0);
      *((threadgroup metal::vec<T, 4>*)(&xs[r][c4 * 4u])) = v;
    }
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
    const uint runA = base / 32u + fn;
    uint ga[KG + 1], gb[KG + 1], ua[KU + 1], ub[KU + 1];
    load_run<KG, BT>(gRow, runA, ga);
    load_run<KG, BT>(gRow, runA + 1u, gb);
    load_run<KU, BT>(uRow, runA, ua);
    load_run<KU, BT>(uRow, runA + 1u, ub);
    #pragma clang loop unroll(full)
    for (uint j = 0; j < 32u; ++j) {
      metal::simdgroup_float8x8 aG, aU;
      aG.thread_elements()[0] = float(codebook[run_state<KG, L>(ga, j)]);
      aG.thread_elements()[1] = float(codebook[run_state<KG, L>(gb, j)]);
      aU.thread_elements()[0] = float(codebook[run_state<KU, L>(ua, j)]);
      aU.thread_elements()[1] = float(codebook[run_state<KU, L>(ub, j)]);
      #pragma clang loop unroll(full)
      for (uint bk = 0; bk < (uint)MT; ++bk) {
        metal::simdgroup_float8x8 b;
        b.thread_elements()[0] = float(xs[8u * bk + fn][fm * 32u + j]);
        b.thread_elements()[1] = float(xs[8u * bk + fn + 1u][fm * 32u + j]);
        metal::simdgroup_multiply_accumulate(accG[bk], aG, b, accG[bk]);
        metal::simdgroup_multiply_accumulate(accU[bk], aU, b, accU[bk]);
      }
    }
  }
  if (n0 >= (uint)R) return;
  const float gs = float(gscales[row]) * TRELLIS_RCP;
  const float us = float(uscales[row]) * TRELLIS_RCP;
  #pragma clang loop unroll(full)
  for (uint bk = 0; bk < (uint)MT; ++bk)
    #pragma clang loop unroll(full)
    for (uint j = 0; j < 2u; ++j) {
      const uint m = mBase + 8u * bk + fn + j;
      if (m >= M) continue;
      const T gateT = T(accG[bk].thread_elements()[j] * gs);
      const T upT = T(accU[bk].thread_elements()[j] * us);
      const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
      const T siluT = T(float(gateT) * float(sigmoidT));
      mid[(ulong)m * (ulong)R + row] = T(float(siluT) * float(upT));
    }
`;

let kernel: MetalKernel | undefined;

/** Row blocks per pass for M rows: two (16 rows), or three where three blocks of 8 cover them (17..24 rows: 1.52
 *  against 1.64 ms for three passes of one block and 1.86 for two of two). */
function rowBlocks(M: number): number { return Math.ceil(M / 8) === 3 ? 3 : 2; }

/** silu(gate(x))·up(x) for any number of activation rows. Gate and up share their axis-1 geometry (rows a multiple
 *  of 8, columns of 256, L at most 12); their bit widths may differ. Borrows x and the weights; returns owned lazy
 *  output with x's leading dimensions. */
export function gateUpMmaWide(x: MlxArray, gate: TrellisWeights, up: TrellisWeights): MlxArray {
  const g = gate.geometry, u = up.geometry;
  const lead = x.shape.slice(0, -1), M = lead.reduce((a, b) => a * b, 1);
  if (M < 1) throw new Error("gateUpMmaWide: no rows");
  if (g.axis !== 1 || u.axis !== 1 || g.rows !== u.rows || g.cols !== u.cols || g.T !== u.T || g.L !== u.L ||
      g.rows % 8 !== 0 || g.cols % 256 !== 0 || g.T % 32 !== 0 || g.L > 12)
    throw new Error("gateUpMmaWide: unsupported gate/up geometry");
  kernel ??= new MetalKernel({ name: "mlx_bun_trellis_gateup_mma_wide", inputNames: ["x", "gcodes", "gscales", "ucodes", "uscales"],
    outputNames: ["mid"], source: SOURCE, header: HEADER + RUN_HEADER, ensureRowContiguous: true });
  const MT = rowBlocks(M);
  using x2 = ops.reshape(x, [M, g.inFeatures]);
  const [mid] = kernel.apply([x2, gate.codes, gate.scales, up.codes, up.scales], {
    outputs: [{ shape: [M, g.rows], dtype: x.dtype }],
    grid: [32 * SG_TG, Math.ceil(g.rows / 8 / SG_TG), Math.ceil(M / (8 * MT))], threadGroup: [32 * SG_TG, 1, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { R: g.rows, C: g.cols, BT: g.T, KG: g.k, KU: u.k, L: g.L, SG_TG, MT },
  });
  using y = mid!;
  return ops.reshape(y, [...lead, g.rows]);
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Kernels.Trellis.GateUpMmaWide
