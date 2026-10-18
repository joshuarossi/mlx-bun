import host.ts.Source
namespace Host.Ts.Sources.Inference.Kernels.Trellis.DownMmaWide
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/kernels/trellis/down-mma-wide.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import { HEADER } from "./codebook";
import type { TrellisGeometry } from "./geometry";

// Down projection on the simdgroup matrix unit for any number of activation
// rows: down-mma's splits and accumulation (each output row bit for bit the
// same), with every decoded B fragment feeding an MMA for MT blocks of 8 rows;
// grid z walks chunks of 8·MT rows. A simdgroup's S sub-tiles and MT follow
// the layout and the rows (`plan`): neither changes a sum. Each code value y
// is read from a half table of the 2^L values (exact in half) the threadgroup
// generates once, in place of the 1MAD arithmetic (the M1 Max form, where the
// matrix products issue on the ordinary ALU pipes and the integer decode
// competes with them); a window is one bit-field extract (one that straddles a
// word reads a virtual word: the high half of one word and the low half of the
// next) and the B fragments are half. Input rows come in whole steps of 8 (the
// rows a multiple of 8, so is every split's); activation rows past M repeat
// the last row and are not written. The row count is read at run time (one
// pipeline per geometry and launch). SPLITS f32 partials [M, SPLITS, C] fold
// in one MLX sum. Two kernels, one per code layout: row-major [rows, cols·K/32]
// and the 3-bit block interleave [cols/512, rows, 48]. Measured on the M1 Max at
// the Qwen down shape (17408 x 5120, real weights) at 8, 16, 24, 32 and 64 rows,
// 3-bit interleaved: 0.24, 0.44, 0.64, 0.84 and 1.65 ms, against 0.66, 0.67,
// 0.87, 1.24 and 2.39 decoding with the 1MAD arithmetic (downMma at 8 rows
// 0.45); 2-bit row-major: 0.24, 0.40, 0.58, 0.76 and 1.49, against 0.62, 0.64,
// 0.88, 1.08 and 2.13 (downMma 0.43).
const SG_TG = 4, SPLITS = 8;

/** One pass of the kernel: S sub-tiles per simdgroup, MT blocks of 8 rows per decoded fragment. */
export interface DownPass { readonly S: number; readonly MT: number }

/** One block of 8 rows per pass, sixteen sub-tiles: the cheapest pass for 1..8 rows in either layout. */
export const DOWN_ONE_BLOCK: DownPass = Object.freeze({ S: 16, MT: 1 });

/** Each layout's passes and their relative cost, measured per pass at 8 to 128 rows: the 3-bit interleave runs one
 *  block per pass at every row count; row-major codes take sixteen sub-tiles for one block and eight for two or
 *  three. */
const PLANS: Readonly<Record<"rowMajor" | "interleaved", readonly (DownPass & { readonly cost: number })[]>> = {
  interleaved: [{ ...DOWN_ONE_BLOCK, cost: 1 }],
  rowMajor: [{ ...DOWN_ONE_BLOCK, cost: 0.6 }, { S: 8, MT: 2, cost: 1 }, { S: 8, MT: 3, cost: 1.44 }],
};

/** The pass for M rows: the one whose passes cost least in all (the more blocks on a tie). */
function plan(layout: keyof typeof PLANS, M: number): DownPass {
  let best = { S: 0, MT: 0, cost: Infinity };
  for (const { S, MT, cost } of PLANS[layout]) {
    const total = Math.ceil(M / (8 * MT)) * cost;
    if (total <= best.cost) best = { S, MT, cost: total };
  }
  return { S: best.S, MT: best.MT };
}

const SOURCE = String.raw`
  const uint M = (uint)x_shape[0];
  const uint lane = thread_index_in_simdgroup;
  threadgroup half codebook[1 << L];
  for (uint i = simdgroup_index_in_threadgroup * 32u + lane; i < (1u << (uint)L); i += 32u * (uint)SG_TG)
    codebook[i] = half(trellis_y_f32(i));
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  const uint id = threadgroup_position_in_grid.y * (uint)SG_TG + simdgroup_index_in_threadgroup;
  const uint groupsPerBlock = 32u / (uint)S;
  const uint nGroups = ((uint)C / 256u) * groupsPerBlock;
  if (id >= nGroups * (uint)SPLITS) return;
  const uint cg = id % nGroups, split = id / nGroups;
  const uint block = cg / groupsPerBlock, pg = (cg % groupsPerBlock) * 8u * (uint)S;
  const uint fm = ((lane / 4u) & 4u) + ((lane / 2u) % 4u);
  const uint fn = ((lane / 4u) & 2u) * 2u + (lane % 2u) * 2u;
  const uint wpb = 8u * (uint)K;
  const ulong rowWords = (ulong)(INTERLEAVE ? 2u : (uint)C / 256u) * wpb;
  const device uint32_t* words = codes + (INTERLEAVE
    ? (ulong)(block / 2u) * (ulong)R * 2u * wpb + (block % 2u) * wpb : (ulong)block * wpb);
  // This lane's 2S positions start at p0; realign its bit window to bit 0.
  const uint p0 = pg + (uint)S * fn;
  const uint bit0 = p0 * (uint)K, w0 = bit0 >> 5, off0 = bit0 & 31u;
  const uint mBase = threadgroup_position_in_grid.z * 8u * (uint)MT;
  const uint rowsPer = (((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS + 7u) & ~7u;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  const device T* xm[MT];
  metal::simdgroup_float8x8 acc[S][MT];
  #pragma clang loop unroll(full)
  for (uint bk = 0; bk < (uint)MT; ++bk) {
    xm[bk] = x + (ulong)metal::min(mBase + 8u * bk + fm, M - 1u) * (ulong)R;
    #pragma clang loop unroll(full)
    for (uint s = 0; s < (uint)S; ++s) acc[s][bk] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
  }
  // The window's words in a row's block (the last ones wrap to its first).
  uint wordAt[NW + 1];
  #pragma clang loop unroll(full)
  for (uint i = 0; i <= (uint)NW; ++i) wordAt[i] = (w0 + i) % wpb;
  const device uint32_t* rowCodes = words + (ulong)(r0 + fm) * rowWords;
  for (uint r = r0; r < r1; r += 8u, rowCodes += 8u * rowWords) {
    uint raw[NW + 1];
    #pragma clang loop unroll(full)
    for (uint i = 0; i <= (uint)NW; ++i) raw[i] = rowCodes[wordAt[i]];
    uint w[NW], v[NW];
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NW; ++i) w[i] = off0 ? (raw[i] >> off0) | (raw[i + 1] << (32u - off0)) : raw[i];
    // Virtual word i: bits [32i - 16, 32i + 16) of the realigned window.
    #pragma clang loop unroll(full)
    for (uint i = 1; i < (uint)NW; ++i) v[i] = (w[i - 1] >> 16) | (w[i] << 16);
    const uint ra = r + fn;
    const float sa = float(scales[ra]) * TRELLIS_RCP, sb = float(scales[ra + 1u]) * TRELLIS_RCP;
    metal::simdgroup_float8x8 a[MT];
    #pragma clang loop unroll(full)
    for (uint bk = 0; bk < (uint)MT; ++bk) {
      a[bk].thread_elements()[0] = float(xm[bk][ra]) * sa;
      a[bk].thread_elements()[1] = float(xm[bk][ra + 1u]) * sb;
    }
    #pragma clang loop unroll(full)
    for (uint s = 0; s < (uint)S; ++s) {
      metal::simdgroup_half8x8 b;
      b.thread_elements()[0] = codebook[block_state<K, L>(w, v, s)];
      b.thread_elements()[1] = codebook[block_state<K, L>(w, v, s + (uint)S)];
      #pragma clang loop unroll(full)
      for (uint bk = 0; bk < (uint)MT; ++bk)
        metal::simdgroup_multiply_accumulate(acc[s][bk], a[bk], b, acc[s][bk]);
    }
  }
  #pragma clang loop unroll(full)
  for (uint bk = 0; bk < (uint)MT; ++bk) {
    const uint m = mBase + 8u * bk + fm;
    if (m >= M) continue;
    device float* out = partial + ((ulong)m * (ulong)SPLITS + split) * (ulong)C + (ulong)block * 256u + 255u - p0;
    #pragma clang loop unroll(full)
    for (uint s = 0; s < (uint)S; ++s) {
      out[-(int)s] = acc[s][bk].thread_elements()[0];
      out[-(int)((uint)S + s)] = acc[s][bk].thread_elements()[1];
    }
  }
`;

// State at position t of a realigned window (bits [t·K, +L) of w), one extract (virtual words v past a word edge).
const STATE_HEADER = String.raw`
template <int K, int L_>
inline uint block_state(thread const uint* w, thread const uint* v, uint t) {
  const uint b = t * (uint)K;
  const uint off = b & 31u;
  if (off + (uint)L_ <= 32u) return (w[b >> 5] >> off) & ((1u << (uint)L_) - 1u);
  const uint vi = (b + 16u) >> 5;
  return (v[vi] >> (b + 16u - 32u * vi)) & ((1u << (uint)L_) - 1u);
}
`;

function launch(kernel: MetalKernel, x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, interleave: 0 | 1,
  { S, MT }: DownPass): MlxArray {
  const M = x2.shape[0]!;
  if (x2.ndim !== 2 || M < 1) throw new Error("downMmaWide: expects [rows, inputs]");
  if (g.axis !== 0 || g.T !== 256 || g.cols % 256 !== 0 || g.rows % 8 !== 0 || g.L > 12)
    throw new Error("downMmaWide: unsupported geometry");
  const nGroups = (g.cols / 256) * (32 / S);
  // Words covering 2S positions plus the L-bit window, after realignment.
  const NW = Math.ceil((2 * S * g.k + g.L - 1) / 32) + 1;
  const [partial] = kernel.apply([x2, codes, scales], {
    outputs: [{ shape: [M, SPLITS, g.cols], dtype: Dtype.float32 }],
    grid: [32 * SG_TG, Math.ceil((nGroups * SPLITS) / SG_TG), Math.ceil(M / (8 * MT))], threadGroup: [32 * SG_TG, 1, 1],
    templateDtypes: { T: x2.dtype },
    templateInts: { R: g.rows, C: g.cols, K: g.k, L: g.L, SPLITS, SG_TG, INTERLEAVE: interleave, MT, S, NW },
  });
  using sum = ops.sumAxis(partial!, 1, false);
  partial!.dispose();
  return sum.astype(x2.dtype);
}

let rowMajor: MetalKernel | undefined, interleaved: MetalKernel | undefined;

/** x2 [M, inFeatures] · W → [M, outFeatures] in x2's dtype for row-major axis-0 codes (T 256, L at most 12, input
 *  features a multiple of 8), any number of rows, in passes of the given shape. Borrows inputs. */
export function downMmaWidePass(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, pass: DownPass): MlxArray {
  if (g.blockInterleave || codes.ndim !== 2) throw new Error("downMmaWide: needs row-major codes");
  rowMajor ??= new MetalKernel({ name: "mlx_bun_trellis_down_mma_wide", inputNames: ["x", "codes", "scales"],
    outputNames: ["partial"], source: SOURCE, header: HEADER + STATE_HEADER, ensureRowContiguous: true });
  return launch(rowMajor, x2, codes, scales, g, 0, pass);
}

/** downMmaWidePass for 3-bit block-interleaved codes [cols/512, rows, 48]. */
export function downK3InterleavedMmaWidePass(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry,
  pass: DownPass): MlxArray {
  if (g.blockInterleave !== 2 || g.k !== 3) throw new Error("downK3InterleavedMmaWide: needs 3-bit block-interleaved codes");
  interleaved ??= new MetalKernel({ name: "mlx_bun_trellis_down_k3i_mma_wide", inputNames: ["x", "codes", "scales"],
    outputNames: ["partial"], source: SOURCE, header: HEADER + STATE_HEADER, ensureRowContiguous: true });
  return launch(interleaved, x2, codes, scales, g, 1, pass);
}

/** downMmaWidePass in the pass the row count plans. */
export function downMmaWide(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry): MlxArray {
  return downMmaWidePass(x2, codes, scales, g, plan("rowMajor", x2.shape[0]!));
}

/** downK3InterleavedMmaWidePass in the pass the row count plans. */
export function downK3InterleavedMmaWide(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry): MlxArray {
  return downK3InterleavedMmaWidePass(x2, codes, scales, g, plan("interleaved", x2.shape[0]!));
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Kernels.Trellis.DownMmaWide
