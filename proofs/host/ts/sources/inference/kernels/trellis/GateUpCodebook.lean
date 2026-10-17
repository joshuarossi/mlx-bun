import host.ts.Source
namespace Host.Ts.Sources.Inference.Kernels.Trellis.GateUpCodebook
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/kernels/trellis/gate-up-codebook.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisWeights } from "./geometry";
import { CODEBOOK_WINDOW, HEADER } from "./codebook";
import { TRELLIS_CODEBOOK_ROW_THREADS, TRELLIS_CODEBOOK_ROW_SG_PER_TG } from "./launch";
import type { MixedGateUpTail } from "./mixed-gate-up";

// Fused gate/up/SwiGLU for one activation row over axis-1 Trellis codes whose
// gate and up widths may differ (KG, KU), decoding through a threadgroup
// codebook: every code value y·(1/147.8) of the 2^L states, generated once per
// threadgroup and shared by the rows its 32 SIMD groups take in turn (at most
// THREADGROUPS threadgroups, so each table serves several rows). Same
// lanes, runs, accumulation order and f32 code·scale weights as
// fusedGateUpSwiglu (same widths) and fusedGateUpSwigluMixed (different
// widths), bit for bit; TAIL selects the mixed kernel's SwiGLU arithmetic (1:
// MLX's compiled swiglu over the bf16 projections; 0: the float32 sigmoid of
// the same-width kernel).
//
// The threadgroup also stages the activation row, in 16-byte chunks ordered
// so the 32 lanes of one load read consecutive chunks; a lane reads each
// chunk of 8 positions just before it uses them (a threadgroup of 1024
// threads fits an M1 Max core only below 53 registers per thread). Each window
// is one bit-field extract (CODEBOOK_WINDOW, codebook.ts); code words are
// addressed by 32-bit offsets.
const SOURCE = String.raw`
  threadgroup float codebook[1 << L];
  threadgroup uint4 xs[C / 8];
  constexpr uint N_RUNS = (uint)C / 32u;
  for (uint i = thread_position_in_threadgroup.x; i < (1u << (uint)L); i += (uint)THREADS)
    codebook[i] = trellis_unrefined_bits_y(trellis_y(i));
  // Chunk q (positions 8q..8q+7) of run r at q·N_RUNS + r.
  for (uint c = thread_position_in_threadgroup.x; c < (uint)C / 8u; c += (uint)THREADS)
    xs[c] = ((const device uint4*)x)[(c % N_RUNS) * 4u + c / N_RUNS];
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  const threadgroup uchar* table = (const threadgroup uchar*)codebook;
  const uint lane = thread_index_in_simdgroup;
  const uint gWpb = (uint)(BT * KG / 32);
  const uint uWpb = (uint)(BT * KU / 32);
  const uint runsPerBlock = (uint)BT / 32u;
  const uint rowStep = threadgroups_per_grid.y * (uint)ROWS_TG;
  for (uint row = thread_position_in_grid.y * (uint)ROWS_TG + simdgroup_index_in_threadgroup; row < (uint)R; row += rowStep) {
    const uint gRow = row * (uint)((C / BT) * gWpb);
    const uint uRow = row * (uint)((C / BT) * uWpb);
    const float gScale = float(gscales[row]);
    const float uScale = float(uscales[row]);
    float gAcc = 0.0f, gAcc2 = 0.0f, uAcc = 0.0f, uAcc2 = 0.0f;
    for (uint run = lane; run < N_RUNS; run += 32u) {
      const uint blk = run / runsPerBlock;
      const uint t0 = (run - blk * runsPerBlock) * 32u;
      const uint gw = gRow + blk * gWpb, uw = uRow + blk * uWpb;
      const uint gW0 = ((uint)BT - 32u - t0) * (uint)KG / 32u;
      const uint uW0 = ((uint)BT - 32u - t0) * (uint)KU / 32u;
      uint g[KG + 1], gv[KG + 1];
      uint u[KU + 1], uv[KU + 1];
      // Words W0 .. W0 + K - 1 stay in the block; the next word wraps to the block's first for its last run.
      #pragma clang loop unroll(full)
      for (uint i = 0; i < (uint)KG; ++i) g[i] = gcodes[gw + gW0 + i];
      g[KG] = gcodes[gw + (t0 == 0u ? 0u : gW0 + (uint)KG)];
      #pragma clang loop unroll(full)
      for (uint i = 0; i < (uint)KU; ++i) u[i] = ucodes[uw + uW0 + i];
      u[KU] = ucodes[uw + (t0 == 0u ? 0u : uW0 + (uint)KU)];
      // Virtual words: bits [32i - 16, 32i + 16) of the run's words (only the ignored bits below word 0 are absent).
      gv[0] = g[0] << 16;
      uv[0] = u[0] << 16;
      #pragma clang loop unroll(full)
      for (uint i = 1; i <= (uint)KG; ++i) gv[i] = (g[i - 1] >> 16) | (g[i] << 16);
      #pragma clang loop unroll(full)
      for (uint i = 1; i <= (uint)KU; ++i) uv[i] = (u[i - 1] >> 16) | (u[i] << 16);
      #pragma clang loop unroll(full)
      for (uint q = 0; q < 4u; ++q) {
        const uint4 chunk = xs[q * N_RUNS + run];
        #pragma clang loop unroll(full)
        for (uint p = 0; p < 8u; ++p) {
          const uint j = q * 8u + p;
          // The bf16 in either half of a word, as the float of its bits.
          const float xv = as_type<float>((p & 1u) ? chunk[p >> 1] & 0xFFFF0000u : chunk[p >> 1] << 16);
          const float gWeight = trellis_codebook_window(table, g, gv, (31u - j) * (uint)KG, (uint)L) * gScale;
          const float uWeight = trellis_codebook_window(table, u, uv, (31u - j) * (uint)KU, (uint)L) * uScale;
          if (j & 1u) { gAcc2 = metal::fma(gWeight, xv, gAcc2); uAcc2 = metal::fma(uWeight, xv, uAcc2); }
          else { gAcc = metal::fma(gWeight, xv, gAcc); uAcc = metal::fma(uWeight, xv, uAcc); }
        }
      }
    }
    const float gate = metal::simd_sum(gAcc + gAcc2);
    const float up = metal::simd_sum(uAcc + uAcc2);
    if (lane == 0u) {
      const T gateT = T(gate);
      const T upT = T(up);
      if ((TAIL) == 1) {
        const T sigY = 1 / (1 + metal::exp(metal::abs(gateT)));
        const T sigmoidT = (gateT < 0) ? sigY : 1 - sigY;
        const T siluT = gateT * sigmoidT;
        mid[row] = siluT * upT;
      } else {
        const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
        const T siluT = T(float(gateT) * float(sigmoidT));
        mid[row] = T(float(siluT) * float(upT));
      }
    }
  }
`;

/** Threadgroups at most: five per M1 Max GPU core, measured against 128 to 256 (the codebook generated 544 times per
 *  projection at the artifact's 17408 rows otherwise). */
const THREADGROUPS = 160;

let kernel: MetalKernel | undefined;

/** silu(gate(x))·up(x) for exactly one activation row over matching axis-1
 *  geometry (L at most 12, at most 8192 bf16 inputs; the bit widths may differ). `tail` applies where the
 *  widths differ; same widths take the float32 sigmoid. Borrows x and the
 *  weights; returns owned lazy output with x's leading dimensions. */
export function gateUpCodebookRow(x: MlxArray, gate: TrellisWeights, up: TrellisWeights, tail: MixedGateUpTail): MlxArray {
  const g = gate.geometry, u = up.geometry;
  if (g.axis !== 1 || u.axis !== 1 || g.rows !== u.rows || g.cols !== u.cols || g.T !== u.T || g.L !== u.L || g.L > 12)
    throw new Error("gateUpCodebookRow: gate and up need matching axis-1 geometry with L <= 12");
  if (x.size !== x.shape.at(-1)) throw new Error("gateUpCodebookRow: expects one activation row");
  if ((4 << g.L) + 2 * g.cols > 32768) throw new Error("gateUpCodebookRow: the codebook and staged row exceed 32 KiB of threadgroup memory");
  kernel ??= new MetalKernel({ name: "mlx_bun_trellis_gateup_codebook_row",
    inputNames: ["x", "gcodes", "gscales", "ucodes", "uscales"], outputNames: ["mid"],
    source: SOURCE, header: HEADER + CODEBOOK_WINDOW, ensureRowContiguous: true });
  const lead = x.shape.slice(0, -1);
  const x2 = ops.reshape(x, [1, g.inFeatures]);
  const [mid] = kernel.apply([x2, gate.codes, gate.scales, up.codes, up.scales], {
    outputs: [{ shape: [1, g.rows], dtype: x.dtype }],
    grid: [TRELLIS_CODEBOOK_ROW_THREADS, Math.min(THREADGROUPS, Math.ceil(g.rows / TRELLIS_CODEBOOK_ROW_SG_PER_TG)), 1],
    threadGroup: [TRELLIS_CODEBOOK_ROW_THREADS, 1, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { R: g.rows, C: g.cols, BT: g.T, KG: g.k, KU: u.k, L: g.L, ROWS_TG: TRELLIS_CODEBOOK_ROW_SG_PER_TG,
      THREADS: TRELLIS_CODEBOOK_ROW_THREADS, TAIL: g.k !== u.k && tail === "split" ? 1 : 0 },
  });
  x2.dispose();
  const out = ops.reshape(mid!, [...lead, g.rows]);
  mid!.dispose();
  return out;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Kernels.Trellis.GateUpCodebook
