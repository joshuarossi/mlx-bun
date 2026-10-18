import host.ts.Source
namespace Host.Ts.Sources.Inference.Kernels.Quantization.AffineSplitMma
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/kernels/quantization/affine-split-mma.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

// Matmul over MLX affine 3- or 4-bit, group-64 weights on the simdgroup matrix
// unit: y = x · Wᵀ for any number of activation rows, in blocks of 8 (grid z;
// the row count is read at run time, one pipeline per projection shape).
// The A/B layout of affine{3,4}-mma: A is 8 output rows x 8 k with the k index
// permuted so that A column i at step s is position base + 32·i + s (every lane
// dequantizes one 64-value group of its row over a 256-value K step); B is xᵀ.
// For the M1 Max, whose matrix products issue on the ordinary ALU pipes: each
// simdgroup owns TILES 8-row output tiles that share every B fragment, the
// threadgroup's SPLITS simdgroups take interleaved K steps and add their tiles
// through threadgroup memory, and a weight dequantizes as fma(1 + q/2^BITS,
// 2^BITS·scale, bias − 2^BITS·scale), q shifted into the mantissa of 1.0f.
// B columns past the last activation row repeat it; those columns of C are
// never written, so a block's cost does not depend on its rows. Summation order
// differs from MLX's qmv and qmm (not bit-identical; gate by KL). Measured on
// the M1 Max above eight rows (3-bit 5120 -> 10240): 9 rows 0.50 ms, 16 0.38,
// 32 0.66, 64 1.25, against MLX's quantized matmul at 0.74, 0.75, 0.67, 1.27.

const SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint fm = ((lane / 4u) & 4u) + ((lane / 2u) % 4u);
  const uint fn = ((lane / 4u) & 2u) * 2u + (lane % 2u) * 2u;
  const uint M = (uint)x_shape[0];
  const uint n0 = threadgroup_position_in_grid.y * 8u * (uint)TILES;
  const uint m0 = threadgroup_position_in_grid.z * 8u;
  const uint groups = (uint)K / 64u;
  const uint groupWords = 2u * (uint)BITS;
  const device T* x0 = x + (ulong)metal::min(m0 + fn, M - 1u) * (ulong)K + fm * 32u;
  const device T* x1 = x + (ulong)metal::min(m0 + fn + 1u, M - 1u) * (ulong)K + fm * 32u;
  const device uint32_t* wRow[TILES];
  metal::simdgroup_float8x8 acc[TILES];
  #pragma clang loop unroll(full)
  for (uint t = 0; t < (uint)TILES; ++t) {
    wRow[t] = (const device uint32_t*)w + (ulong)(n0 + 8u * t + fm) * groups * groupWords;
    acc[t] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
  }
  for (uint step = sg; step < (uint)K / 256u; step += (uint)SPLITS) {
    const uint base = step * 256u;
    const uint g = step * 4u + fn / 2u;
    uint q[TILES][2 * BITS];
    float s2[TILES], b2[TILES];
    #pragma clang loop unroll(full)
    for (uint t = 0; t < (uint)TILES; ++t) {
      const ulong at = (ulong)(n0 + 8u * t + fm) * groups + g;
      s2[t] = float(scales[at]) * (float)(1u << (uint)BITS);
      b2[t] = float(biases[at]) - s2[t];
      #pragma clang loop unroll(full)
      for (uint i = 0; i < groupWords; ++i) q[t][i] = wRow[t][g * groupWords + i];
    }
    const device metal::vec<T, 4>* xa = (const device metal::vec<T, 4>*)(x0 + base);
    const device metal::vec<T, 4>* xb = (const device metal::vec<T, 4>*)(x1 + base);
    #pragma clang loop unroll(full)
    for (uint s4 = 0; s4 < 8u; ++s4) {
      const float4 va = float4(xa[s4]);
      const float4 vb = float4(xb[s4]);
      #pragma clang loop unroll(full)
      for (uint c = 0; c < 4u; ++c) {
        const uint v = s4 * 4u + c;
        metal::simdgroup_float8x8 bx;
        bx.thread_elements()[0] = va[c];
        bx.thread_elements()[1] = vb[c];
        #pragma clang loop unroll(full)
        for (uint t = 0; t < (uint)TILES; ++t) {
          metal::simdgroup_float8x8 a;
          a.thread_elements()[0] = metal::fma(AFFINE_UNIT(q[t], v), s2[t], b2[t]);
          a.thread_elements()[1] = metal::fma(AFFINE_UNIT(q[t], v + 32u), s2[t], b2[t]);
          metal::simdgroup_multiply_accumulate(acc[t], a, bx, acc[t]);
        }
      }
    }
  }
  // Add the K splits: element (fm, fn | fn + 1) of each tile, then thread e of
  // the threadgroup writes C element e of its tile, columns below M only.
  threadgroup float part[SPLITS][TILES][64];
  #pragma clang loop unroll(full)
  for (uint t = 0; t < (uint)TILES; ++t) {
    part[sg][t][fm * 8u + fn] = acc[t].thread_elements()[0];
    part[sg][t][fm * 8u + fn + 1u] = acc[t].thread_elements()[1];
  }
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  for (uint e = sg * 32u + lane; e < 64u * (uint)TILES; e += 32u * (uint)SPLITS) {
    const uint t = e / 64u, r = (e % 64u) / 8u, m = e % 8u;
    if (m0 + m >= M) continue;
    float sum = 0.0f;
    for (uint s = 0; s < (uint)SPLITS; ++s) sum += part[s][t][r * 8u + m];
    y[(ulong)(m0 + m) * (ulong)N + n0 + 8u * t + r] = T(sum);
  }
`;

// Value v of a 64-value group (MLX's LSB-first bit stream) as the exact float
// 1 + q/2^B: q shifted into the top B mantissa bits of 1.0f; a value may
// straddle into the next word. The words go by value: v is a constant of the
// unrolled loop, so every shift and mask folds.
const HEADER = String.raw`
template <uint B>
inline float affine_unit(uint lo, uint hi, uint v) {
  const uint bit = v * B, off = bit & 31u;
  const uint top = 23u - B;
  uint u = off <= top ? lo << (top - off) : lo >> (off - top);
  if (off + B > 32u) u |= hi << (top + 32u - off);
  return as_type<float>((u & (((1u << B) - 1u) << top)) | 0x3f800000u);
}
#define AFFINE_UNIT(q, v) affine_unit<BITS>((q)[((v) * BITS) >> 5], (q)[metal::min((((v) * BITS) >> 5) + 1u, 2u * BITS - 1u)], (v))
`;

let kernel: MetalKernel | undefined;

/** The launch for an N-output projection: output tiles per simdgroup and K splits per threadgroup. Wide outputs take
 *  two tiles over two splits; narrow ones (the attention k/v and the DeltaNet a/b projections) one tile over eight,
 *  for enough simdgroups in flight. */
export interface AffineSplitMmaPlan { readonly tiles: number; readonly splits: number }
export function affineSplitMmaPlan(N: number): AffineSplitMmaPlan {
  return N >= 2048 && N % 16 === 0 ? { tiles: 2, splits: 2 } : { tiles: 1, splits: 8 };
}

/** Eligible: affine 3- or 4-bit, group 64, K a multiple of 256, N of 8, at least one row. */
export function affineSplitMmaEligible(rows: number, w: MlxArray, scales: MlxArray, spec: { bits: number; groupSize: number; mode: string }): boolean {
  if (spec.mode !== "affine" || spec.groupSize !== 64 || (spec.bits !== 3 && spec.bits !== 4)) return false;
  const N = scales.shape[0]!, K = scales.shape[1]! * 64;
  return rows >= 1 && K % 256 === 0 && N % 8 === 0 && w.shape.length === 2;
}

/** x [..., K] (any number of rows) · Wᵀ → [..., N] in x's dtype, for `bits`-bit weights under `plan`. Borrows
 *  inputs. */
export function affineSplitMma(x: MlxArray, w: MlxArray, scales: MlxArray, biases: MlxArray, bits: 3 | 4,
  plan: AffineSplitMmaPlan): MlxArray {
  const K = x.shape.at(-1)!, M = x.size / K, N = scales.shape[0]!;
  if (M < 1) throw new Error("affineSplitMma: no rows");
  kernel ??= new MetalKernel({ name: "mlx_bun_affine_split_mma", inputNames: ["x", "w", "scales", "biases"],
    outputNames: ["y"], source: SOURCE, header: HEADER, ensureRowContiguous: true });
  using x2 = ops.reshape(x, [M, K]);
  const [y] = kernel.apply([x2, w, scales, biases], {
    outputs: [{ shape: [M, N], dtype: x.dtype }],
    grid: [32 * plan.splits, N / (8 * plan.tiles), Math.ceil(M / 8)], threadGroup: [32 * plan.splits, 1, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { N, K, BITS: bits, TILES: plan.tiles, SPLITS: plan.splits },
  });
  using y2 = y!;
  return ops.reshape(y2, [...x.shape.slice(0, -1), N]);
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Kernels.Quantization.AffineSplitMma
