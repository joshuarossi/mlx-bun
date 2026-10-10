import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

// Verify-width matmul over MLX affine 4-bit, group-64 weights: y = x · Wᵀ for
// 2..8 activation rows. MLX's qmv runs each row as its own threadgroups, so
// every weight is fetched and decoded M times. Here each simdgroup owns NR = 4
// output rows; per 512-value K step, every lane decodes its VPT = 16 values of
// each output row once (exact floats via the 2^23 mantissa trick, MLX's
// little-endian packing) and reuses them for all M rows held in registers.
// SGS = 2 simdgroups per threadgroup. Same algebra as MLX:
// Σ_g scale·Σ q·x + bias·Σ x. Summation order differs from MLX's qmv (not
// bit-identical; gate by KL).
const NR = 4, SGS = 2, VPT = 16;

const SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint n0 = (threadgroup_position_in_grid.y * (uint)SGS + sg) * (uint)NR;
  if (n0 >= (uint)N) return;
  const ulong rowBytes = (ulong)K / 2u;
  const uint groups = (uint)K / 64u;
  const device uint8_t* wb = (const device uint8_t*)w;
  float acc[NR][M];
  #pragma clang loop unroll(full)
  for (uint r = 0; r < (uint)NR; ++r)
    #pragma clang loop unroll(full)
    for (uint m = 0; m < (uint)M; ++m) acc[r][m] = 0.0f;
  for (uint k0 = lane * (uint)VPT; k0 < (uint)K; k0 += 32u * (uint)VPT) {
    float xr[M][VPT];
    float xs[M];
    #pragma clang loop unroll(full)
    for (uint m = 0; m < (uint)M; ++m) {
      const device metal::vec<T, 4>* xp = (const device metal::vec<T, 4>*)(x + (ulong)m * (ulong)K + k0);
      float sum = 0.0f;
      #pragma clang loop unroll(full)
      for (uint v = 0; v < (uint)VPT / 4u; ++v) {
        const float4 f = float4(xp[v]);
        xr[m][4 * v] = f.x; xr[m][4 * v + 1] = f.y; xr[m][4 * v + 2] = f.z; xr[m][4 * v + 3] = f.w;
        sum += (f.x + f.y) + (f.z + f.w);
      }
      xs[m] = sum;
    }
    const uint g = k0 / 64u;
    #pragma clang loop unroll(full)
    for (uint r = 0; r < (uint)NR; ++r) {
      const uint n = n0 + r;
      const device uint8_t* p = wb + (ulong)n * rowBytes + (ulong)k0 / 2u;
      float q[VPT];
      #pragma clang loop unroll(full)
      for (uint c = 0; c < (uint)VPT / 8u; ++c) {
        const uint packed = ((const device uint32_t*)p)[c];
        #pragma clang loop unroll(full)
        for (uint j = 0; j < 8u; ++j)
          q[8 * c + j] = as_type<float>(0x4b000000u | ((packed >> (4u * j)) & 15u)) - 8388608.0f;
      }
      const float s = float(scales[(ulong)n * groups + g]);
      const float b = float(biases[(ulong)n * groups + g]);
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m) {
        float dot = 0.0f;
        #pragma clang loop unroll(full)
        for (uint j = 0; j < (uint)VPT; ++j) dot = metal::fma(q[j], xr[m][j], dot);
        acc[r][m] = metal::fma(s, dot, metal::fma(b, xs[m], acc[r][m]));
      }
    }
  }
  #pragma clang loop unroll(full)
  for (uint r = 0; r < (uint)NR; ++r)
    #pragma clang loop unroll(full)
    for (uint m = 0; m < (uint)M; ++m) {
      const float v = metal::simd_sum(acc[r][m]);
      if (lane == 0u) y[(ulong)m * (ulong)N + n0 + r] = T(v);
    }
`;

let kernel: MetalKernel | undefined;

/** Eligible: affine 4-bit, group 64, K a multiple of 512, N of 4, 2..8 rows. */
export function affine4RowsEligible(rows: number, w: MlxArray, scales: MlxArray, spec: { bits: number; groupSize: number; mode: string }): boolean {
  if (spec.mode !== "affine" || spec.groupSize !== 64 || spec.bits !== 4) return false;
  const N = scales.shape[0]!, K = scales.shape[1]! * 64;
  return rows >= 2 && rows <= 8 && K % (32 * VPT) === 0 && N % NR === 0 && w.shape.length === 2;
}

/** x [..., K] (2..8 rows) · Wᵀ → [..., N] in x's dtype. Borrows inputs. */
export function affine4Rows(x: MlxArray, w: MlxArray, scales: MlxArray, biases: MlxArray): MlxArray {
  const K = x.shape.at(-1)!, M = x.size / K, N = scales.shape[0]!;
  if (M < 2 || M > 8) throw new Error(`affine4Rows: M=${M} outside 2..8`);
  kernel ??= new MetalKernel({ name: "mlx_bun_affine4_rows", inputNames: ["x", "w", "scales", "biases"],
    outputNames: ["y"], source: SOURCE, ensureRowContiguous: true });
  using x2 = ops.reshape(x, [M, K]);
  const [y] = kernel.apply([x2, w, scales, biases], {
    outputs: [{ shape: [M, N], dtype: x.dtype }],
    grid: [32 * SGS, Math.ceil(N / (NR * SGS)), 1], threadGroup: [32 * SGS, 1, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { M, N, K, NR, SGS, VPT },
  });
  const out = ops.reshape(y!, [...x.shape.slice(0, -1), N]);
  y!.dispose();
  return out;
}
