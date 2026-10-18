import host.ts.Source
namespace Host.Ts.Sources.Inference.Kernels.Trellis.GateUpCodebookMma
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/kernels/trellis/gate-up-codebook-mma.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisWeights } from "./geometry";
import { HEADER } from "./codebook";

// Fused gate/up/SwiGLU for 1..8 activation rows on the simdgroup matrix unit,
// decoding through a threadgroup codebook (the M1 Max form, where the matrix
// products issue on the ordinary ALU pipes and the integer decode competes with
// them). gate-up-mma's fragments, K permutation and accumulation order, so each
// output is bit for bit gateUpMma's: a simdgroup owns an 8-output-row tile, A
// column i at step j is position base + 32·i + j, and every lane decodes two
// contiguous 32-position runs per projection from K+1 words. Each code value y
// is read from a half table of the 2^L values (every y in [-510, 510] is exact
// in half) that the threadgroup generates once, in place of the 1MAD
// arithmetic; the A fragments are half, B and the accumulators float. A
// window is one bit-field extract: one that straddles a word reads a virtual
// word (the high half of one word and the low half of the next). Each lane
// reads its two activation rows from device memory, 16 bytes at a time, with
// no threadgroup staging or barrier inside the K loop; rows past M repeat the
// last row and are not written. Measured on the M1 Max at the Qwen MLP shape
// (17408 x 5120, gate and up together, real weights), 3-bit: 8 rows 0.476 ms
// against gateUpMma's 1.17, 4 rows 0.465 against 0.795, 2 rows 0.458 against
// gateUpFactoredRows' 0.664.
const SG_TG = 4;

const RUN_HEADER = String.raw`
// Words W0 .. W0 + K of run 'run' of a row's codes (the last wraps to the block's first word).
template <int K, int BT_>
inline void codebook_mma_run(const device uint32_t* rowCodes, uint run, thread uint* w, thread uint* v) {
  const uint wpb = (uint)(BT_ * K / 32);
  const uint runsPerBlock = (uint)BT_ / 32u;
  const uint blk = run / runsPerBlock;
  const uint t0 = (run - blk * runsPerBlock) * 32u;
  const device uint32_t* bw = rowCodes + blk * wpb;
  const uint w0 = ((uint)BT_ - 32u - t0) * (uint)K / 32u;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)K; ++i) w[i] = bw[w0 + i];
  w[K] = bw[t0 == 0u ? 0u : w0 + (uint)K];
  // Virtual word i: bits [32i - 16, 32i + 16) of the run.
  #pragma clang loop unroll(full)
  for (uint i = 1; i <= (uint)K; ++i) v[i] = (w[i - 1] >> 16) | (w[i] << 16);
}
// The state of position j of a run (bits [(31 - j)·K, +L) of its words), one extract.
template <int K, int L_>
inline uint codebook_mma_state(thread const uint* w, thread const uint* v, uint j) {
  const uint b = (31u - j) * (uint)K;
  const uint off = b & 31u;
  if (off + (uint)L_ <= 32u) return (w[b >> 5] >> off) & ((1u << (uint)L_) - 1u);
  const uint vi = (b + 16u) >> 5;
  return (v[vi] >> (b + 16u - 32u * vi)) & ((1u << (uint)L_) - 1u);
}
`;

const SOURCE = String.raw`
  const uint M = (uint)x_shape[0];
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  threadgroup half codebook[1 << L];
  for (uint i = sg * 32u + lane; i < (1u << (uint)L); i += 32u * (uint)SG_TG) codebook[i] = half(trellis_y_f32(i));
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  const uint n0 = (threadgroup_position_in_grid.y * (uint)SG_TG + sg) * 8u;
  if (n0 >= (uint)R) return;
  const uint fm = ((lane / 4u) & 4u) + ((lane / 2u) % 4u);
  const uint fn = ((lane / 4u) & 2u) * 2u + (lane % 2u) * 2u;
  const uint row = n0 + fm;
  const device uint32_t* gRow = gcodes + (ulong)row * (ulong)((C / BT) * (BT * KG / 32));
  const device uint32_t* uRow = ucodes + (ulong)row * (ulong)((C / BT) * (BT * KU / 32));
  // Activation rows fn and fn + 1 from position 32·fm, 8 values per 16-byte load.
  const device uint4* x0 = (const device uint4*)(x + (ulong)metal::min(fn, M - 1u) * (ulong)C + fm * 32u);
  const device uint4* x1 = (const device uint4*)(x + (ulong)metal::min(fn + 1u, M - 1u) * (ulong)C + fm * 32u);
  metal::simdgroup_float8x8 accG = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
  metal::simdgroup_float8x8 accU = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
  for (uint base = 0; base < (uint)C; base += 256u) {
    const uint runA = base / 32u + fn;
    uint ga[KG + 1], gav[KG + 1], gb[KG + 1], gbv[KG + 1];
    uint ua[KU + 1], uav[KU + 1], ub[KU + 1], ubv[KU + 1];
    codebook_mma_run<KG, BT>(gRow, runA, ga, gav);
    codebook_mma_run<KG, BT>(gRow, runA + 1u, gb, gbv);
    codebook_mma_run<KU, BT>(uRow, runA, ua, uav);
    codebook_mma_run<KU, BT>(uRow, runA + 1u, ub, ubv);
    #pragma clang loop unroll(full)
    for (uint s8 = 0; s8 < 4u; ++s8) {
      const uint4 xa = x0[base / 8u + s8], xb = x1[base / 8u + s8];
      #pragma clang loop unroll(full)
      for (uint q = 0; q < 8u; ++q) {
        const uint j = s8 * 8u + q;
        metal::simdgroup_half8x8 aG, aU;
        aG.thread_elements()[0] = codebook[codebook_mma_state<KG, L>(ga, gav, j)];
        aG.thread_elements()[1] = codebook[codebook_mma_state<KG, L>(gb, gbv, j)];
        aU.thread_elements()[0] = codebook[codebook_mma_state<KU, L>(ua, uav, j)];
        aU.thread_elements()[1] = codebook[codebook_mma_state<KU, L>(ub, ubv, j)];
        metal::simdgroup_float8x8 b;
        b.thread_elements()[0] = float(as_type<T>(ushort((q & 1u) ? xa[q / 2u] >> 16 : xa[q / 2u] & 0xFFFFu)));
        b.thread_elements()[1] = float(as_type<T>(ushort((q & 1u) ? xb[q / 2u] >> 16 : xb[q / 2u] & 0xFFFFu)));
        metal::simdgroup_multiply_accumulate(accG, aG, b, accG);
        metal::simdgroup_multiply_accumulate(accU, aU, b, accU);
      }
    }
  }
  const float gs = float(gscales[row]) * TRELLIS_RCP;
  const float us = float(uscales[row]) * TRELLIS_RCP;
  #pragma clang loop unroll(full)
  for (uint j = 0; j < 2u; ++j) {
    const uint m = fn + j;
    if (m >= M) continue;
    const T gateT = T(accG.thread_elements()[j] * gs);
    const T upT = T(accU.thread_elements()[j] * us);
    const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
    const T siluT = T(float(gateT) * float(sigmoidT));
    mid[(ulong)m * (ulong)R + row] = T(float(siluT) * float(upT));
  }
`;

let kernel: MetalKernel | undefined;

/** silu(gate(x))·up(x) for 1..8 bfloat16 or float16 activation rows, each output gateUpMma's bits. Gate and up
 *  share their axis-1 geometry (rows a multiple of 8, columns of 256, L at most 12); their bit widths may differ.
 *  Borrows x and the weights; returns owned lazy output with x's leading dimensions. */
export function gateUpCodebookMma(x: MlxArray, gate: TrellisWeights, up: TrellisWeights): MlxArray {
  const g = gate.geometry, u = up.geometry;
  const lead = x.shape.slice(0, -1), M = lead.reduce((a, b) => a * b, 1);
  if (M < 1 || M > 8) throw new Error(`gateUpCodebookMma: M=${M} outside 1..8`);
  if (x.dtype !== Dtype.bfloat16 && x.dtype !== Dtype.float16)
    throw new Error("gateUpCodebookMma: needs bfloat16 or float16 activations");
  if (g.axis !== 1 || u.axis !== 1 || g.rows !== u.rows || g.cols !== u.cols || g.T !== u.T || g.L !== u.L ||
      g.rows % 8 !== 0 || g.cols % 256 !== 0 || g.T % 32 !== 0 || g.L > 12)
    throw new Error("gateUpCodebookMma: unsupported gate/up geometry");
  kernel ??= new MetalKernel({ name: "mlx_bun_trellis_gateup_codebook_mma", inputNames: ["x", "gcodes", "gscales", "ucodes", "uscales"],
    outputNames: ["mid"], source: SOURCE, header: HEADER + RUN_HEADER, ensureRowContiguous: true });
  using x2 = ops.reshape(x, [M, g.inFeatures]);
  const [mid] = kernel.apply([x2, gate.codes, gate.scales, up.codes, up.scales], {
    outputs: [{ shape: [M, g.rows], dtype: x.dtype }],
    grid: [32 * SG_TG, Math.ceil(g.rows / 8 / SG_TG), 1], threadGroup: [32 * SG_TG, 1, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { R: g.rows, C: g.cols, BT: g.T, KG: g.k, KU: u.k, L: g.L, SG_TG },
  });
  using y = mid!;
  return ops.reshape(y, [...lead, g.rows]);
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Kernels.Trellis.GateUpCodebookMma
