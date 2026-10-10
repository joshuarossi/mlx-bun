import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

// Verify-width matmul over MLX affine 4-bit, group-64 weights on the simdgroup
// matrix unit: y = x · Wᵀ for 1..8 activation rows (one block of 8). One
// simdgroup owns 8 output rows. The K index inside each 8x8 step is permuted so
// that A column i at step s is position base + 32·i + s: every lane
// dequantizes 64 contiguous values of its row (exactly one quantization group,
// MLX's LSB-first bit stream) into its A-fragment elements, and reads two
// activation rows contiguously. Per-weight work is independent of M. Summation
// order differs from MLX's qmv (not bit-identical; gate by KL).
const SG_TG = 4, MT = 1;

const SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint n0 = (threadgroup_position_in_grid.y * (uint)SG_TG + simdgroup_index_in_threadgroup) * 8u;
  if (n0 >= (uint)N) return;
  const uint fm = ((lane / 4u) & 4u) + ((lane / 2u) % 4u);
  const uint fn = ((lane / 4u) & 2u) * 2u + (lane % 2u) * 2u;
  const uint n = n0 + fm;
  const uint groups = (uint)K / 64u;
  const device uint32_t* wRow = (const device uint32_t*)((const device uint8_t*)w + (ulong)n * (ulong)K / 2u);
  // MT activation blocks of 8 rows; grid z walks chunks of 8·MT rows.
  const uint mBase = threadgroup_position_in_grid.z * 8u * (uint)MT;
  bool m0[MT], m1[MT];
  const device T* x0[MT];
  const device T* x1[MT];
  metal::simdgroup_float8x8 acc[MT];
  #pragma clang loop unroll(full)
  for (uint bk = 0; bk < (uint)MT; ++bk) {
    const uint r0 = mBase + 8u * bk + fn;
    m0[bk] = r0 < (uint)M; m1[bk] = r0 + 1u < (uint)M;
    x0[bk] = x + (ulong)(m0[bk] ? r0 : 0u) * (ulong)K + fm * 32u;
    x1[bk] = x + (ulong)(m1[bk] ? r0 + 1u : 0u) * (ulong)K + fm * 32u;
    acc[bk] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
  }
  for (uint base = 0; base < (uint)K; base += 256u) {
    const uint g = base / 64u + fn / 2u;
    const float s = float(scales[(ulong)n * groups + g]);
    const float b = float(biases[(ulong)n * groups + g]);
    // 64 values of one group: 8 words.
    uint q[8];
    const device uint32_t* qp = wRow + g * 8u;
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) q[i] = qp[i];
    #pragma clang loop unroll(full)
    for (uint s4 = 0; s4 < 8u; ++s4) {
      float4 va[MT], vb[MT];
      #pragma clang loop unroll(full)
      for (uint bk = 0; bk < (uint)MT; ++bk) {
        va[bk] = m0[bk] ? float4(((const device metal::vec<T, 4>*)(x0[bk] + base))[s4]) : float4(0.0f);
        vb[bk] = m1[bk] ? float4(((const device metal::vec<T, 4>*)(x1[bk] + base))[s4]) : float4(0.0f);
      }
      #pragma clang loop unroll(full)
      for (uint c = 0; c < 4u; ++c) {
        const uint t = s4 * 4u + c;
        metal::simdgroup_float8x8 a;
        a.thread_elements()[0] = metal::fma(s, affine_q4(q, t), b);
        a.thread_elements()[1] = metal::fma(s, affine_q4(q, t + 32u), b);
        #pragma clang loop unroll(full)
        for (uint bk = 0; bk < (uint)MT; ++bk) {
          metal::simdgroup_float8x8 bx;
          bx.thread_elements()[0] = va[bk][c];
          bx.thread_elements()[1] = vb[bk][c];
          metal::simdgroup_multiply_accumulate(acc[bk], a, bx, acc[bk]);
        }
      }
    }
  }
  #pragma clang loop unroll(full)
  for (uint bk = 0; bk < (uint)MT; ++bk) {
    const uint r0 = mBase + 8u * bk + fn;
    if (m0[bk]) y[(ulong)r0 * (ulong)N + n] = T(acc[bk].thread_elements()[0]);
    if (m1[bk]) y[(ulong)(r0 + 1u) * (ulong)N + n] = T(acc[bk].thread_elements()[1]);
  }
`;

// Value t of a 64-value group as an exact f32 (2^23 mantissa trick). 4-bit
// values never straddle a word.
const HEADER = String.raw`
inline float affine_q4(thread const uint* q, uint t) {
  const uint bit = t * 4u;
  return as_type<float>(0x4b000000u | ((q[bit >> 5] >> (bit & 31u)) & 15u)) - 8388608.0f;
}
`;

let kernel: MetalKernel | undefined;

/** Eligible: affine 4-bit, group 64, K a multiple of 256, N of 8, 1..8 rows. */
export function affine4MmaEligible(rows: number, w: MlxArray, scales: MlxArray, spec: { bits: number; groupSize: number; mode: string }): boolean {
  if (spec.mode !== "affine" || spec.groupSize !== 64 || spec.bits !== 4) return false;
  const N = scales.shape[0]!, K = scales.shape[1]! * 64;
  return rows >= 1 && rows <= 8 && K % 256 === 0 && N % 8 === 0 && w.shape.length === 2;
}

/** x [..., K] (1..8 rows) · Wᵀ → [..., N] in x's dtype. Borrows inputs. */
export function affine4Mma(x: MlxArray, w: MlxArray, scales: MlxArray, biases: MlxArray): MlxArray {
  const K = x.shape.at(-1)!, M = x.size / K, N = scales.shape[0]!;
  if (M < 1 || M > 8) throw new Error(`affine4Mma: M=${M} outside 1..8`);
  kernel ??= new MetalKernel({ name: "mlx_bun_affine4_mma", inputNames: ["x", "w", "scales", "biases"],
    outputNames: ["y"], source: SOURCE, header: HEADER, ensureRowContiguous: true });
  using x2 = ops.reshape(x, [M, K]);
  const [y] = kernel.apply([x2, w, scales, biases], {
    outputs: [{ shape: [M, N], dtype: x.dtype }],
    grid: [32 * SG_TG, Math.ceil(N / (8 * SG_TG)), 1], threadGroup: [32 * SG_TG, 1, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { M, N, K, SG_TG, MT },
  });
  const out = ops.reshape(y!, [...x.shape.slice(0, -1), N]);
  y!.dispose();
  return out;
}
