import host.ts.Source
namespace Host.Ts.Sources.Inference.Kernels.Quantization.AffineRow
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/kernels/quantization/affine-row.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

// One-row matmul over MLX affine 3- or 4-bit, group-64 weights: y = x · Wᵀ for
// a single activation row, bit for bit MLX 0.32.2's affine_qmv_fast (the
// kernel MLX's quantized matmul runs at one row). Every output keeps MLX's
// arithmetic: each lane owns 16 values of every 512-value K step (lane·16 on),
// computes MLX's load_vector (x_thread, its bf16 sum) and qdot over them,
// adds each step's qdot into its partial from 0 in K order, and the 32
// partials meet in simd_sum. Only what does not touch a bit changes:
// - load_vector runs once per threadgroup, every 16-value chunk of x into
//   threadgroup memory, where MLX recomputes it per simdgroup and K step (its
//   bf16 sum chain is software-rounded on the M1 Max);
// - each masked weight field's float is formed as (q | 2^23 bits) − 2^23, which
//   is float(q) exactly (q < 2^23), in place of an integer convert;
// - R = 4 rows per simdgroup and S = 16 simdgroups per threadgroup (MLX: 4
//   and 2), so 64 rows share one threadgroup's x.
// Measured on the M1 Max, each layer's weights back to back, against MLX's
// quantized matmul at one row: 3-bit 5120 to 10240 outputs 0.082 ms against
// 0.100, 5120 to 6144 0.053 against 0.062, 6144 to 5120 0.054 against 0.062,
// 4-bit 5120 to 248320 (the head) 1.96 against 2.26; 4-bit projections of 1024
// to 12288 outputs level or up to 3% slower (left on MLX's).
const R = 4, S = 16;

const HEADER = String.raw`
// MLX 0.32.2 load_vector (quantized.h) at values_per_thread 16, bits 3 and 4.
template <typename T, int bits>
inline float mlxq_load_vector(const device T* x, thread float* x_thread) {
  float sum = 0;
  if (bits == 3) {
    for (int i = 0; i < 16; i += 8) {
      sum += x[i] + x[i + 1] + x[i + 2] + x[i + 3] + x[i + 4] + x[i + 5] +
          x[i + 6] + x[i + 7];
      x_thread[i] = x[i];
      x_thread[i + 1] = x[i + 1] / 8.0f;
      x_thread[i + 2] = x[i + 2] / 64.0f;
      x_thread[i + 3] = x[i + 3] / 2.0f;
      x_thread[i + 4] = x[i + 4] / 16.0f;
      x_thread[i + 5] = x[i + 5] / 128.0f;
      x_thread[i + 6] = x[i + 6] / 4.0f;
      x_thread[i + 7] = x[i + 7] / 32.0f;
    }
  } else {
    for (int i = 0; i < 16; i += 4) {
      sum += x[i] + x[i + 1] + x[i + 2] + x[i + 3];
      x_thread[i] = x[i];
      x_thread[i + 1] = x[i + 1] / 16.0f;
      x_thread[i + 2] = x[i + 2] / 256.0f;
      x_thread[i + 3] = x[i + 3] / 4096.0f;
    }
  }
  return sum;
}

// float(q) for a masked field q < 2^23: q in the mantissa of 2^23, minus 2^23.
#define MLXQ_F(q) (as_type<float>((uint)(q) | 0x4B000000u) - 8388608.0f)

// MLX 0.32.2 qdot (quantized.h) at values_per_thread 16, bits 3 and 4: the
// same products and additions in the same order.
template <int bits>
inline float mlxq_qdot(const device uint8_t* w, const threadgroup float* x_thread, float scale, float bias, float sum) {
  float accum = 0;
  if (bits == 3) {
    for (int i = 0; i < 2; i++) {
      x_thread += 8 * i;
      w += 3 * i;
      accum += MLXQ_F(w[0] & 0x07) * x_thread[0];
      accum += MLXQ_F(w[0] & 0x38) * x_thread[1];
      accum += MLXQ_F(w[0] & 0xc0) * x_thread[2];
      accum += MLXQ_F(w[1] & 0x01) * (x_thread[2] * 256.0f);
      accum += MLXQ_F(w[1] & 0x0e) * x_thread[3];
      accum += MLXQ_F(w[1] & 0x70) * x_thread[4];
      accum += MLXQ_F(w[1] & 0x80) * x_thread[5];
      accum += MLXQ_F(w[2] & 0x03) * (x_thread[5] * 256.0f);
      accum += MLXQ_F(w[2] & 0x1c) * x_thread[6];
      accum += MLXQ_F(w[2] & 0xe0) * x_thread[7];
    }
  } else {
    const device uint16_t* ws = (const device uint16_t*)w;
    for (int i = 0; i < 4; i++) {
      accum +=
          (x_thread[4 * i] * MLXQ_F(ws[i] & 0x000f) +
           x_thread[4 * i + 1] * MLXQ_F(ws[i] & 0x00f0) +
           x_thread[4 * i + 2] * MLXQ_F(ws[i] & 0x0f00) +
           x_thread[4 * i + 3] * MLXQ_F(ws[i] & 0xf000));
    }
  }
  return scale * accum + sum * bias;
}
`;

const SOURCE = String.raw`
  constexpr int BPL = 2 * BITS;                   // weight bytes per lane per K step
  constexpr int ROWB = K * BITS / 8;
  constexpr int GROUPS = K / 64;
  const uint sg = simdgroup_index_in_threadgroup, lane = thread_index_in_simdgroup;
  // MLX's x_thread for every 16-value chunk of x, and each chunk's sum.
  threadgroup float xs[K];
  threadgroup float ss[K / 16];
  for (int c = (int)(sg * 32 + lane); c < K / 16; c += S * 32) {
    thread float t[16];
    ss[c] = mlxq_load_vector<T, BITS>(x + c * 16, t);
    for (int j = 0; j < 16; j++) xs[c * 16 + j] = t[j];
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  const int row0 = (threadgroup_position_in_grid.y * S + sg) * R;
  const device uint8_t* ws = (const device uint8_t*)w + row0 * ROWB + lane * BPL;
  const device T* sc = scales + row0 * GROUPS + lane / 4;
  const device T* bi = biases + row0 * GROUPS + lane / 4;
  float result[R] = {0};
  #pragma clang loop unroll_count(1)
  for (int k = 0; k < K; k += 512) {
    const float sum = ss[(k + lane * 16) / 16];
    const threadgroup float* x_thread = xs + k + lane * 16;
    for (int r = 0; r < R; r++) {
      const float s = sc[r * GROUPS];
      const float b = bi[r * GROUPS];
      result[r] += mlxq_qdot<BITS>(ws + r * ROWB, x_thread, s, b, sum);
    }
    ws += 32 * BPL;
    sc += 8;
    bi += 8;
  }
  for (int r = 0; r < R; r++) {
    const float v = simd_sum(result[r]);
    if (lane == 0) y[row0 + r] = static_cast<T>(v);
  }
`;

let kernel: MetalKernel | undefined;

/** Eligible: affine 3- or 4-bit, group 64, one row, K a multiple of 512 whose x_thread fits threadgroup memory
 *  (K <= 7680), N a multiple of 64. */
export function affineRowEligible(rows: number, w: MlxArray, scales: MlxArray, spec: { bits: number; groupSize: number; mode: string }): boolean {
  if (spec.mode !== "affine" || spec.groupSize !== 64 || (spec.bits !== 3 && spec.bits !== 4)) return false;
  const N = scales.shape[0]!, K = scales.shape[1]! * 64;
  return rows === 1 && K % 512 === 0 && K <= 7680 && N % (R * S) === 0 && w.shape.length === 2;
}

/** x [..., K] (one row) · Wᵀ → [..., N] in x's dtype, for `bits`-bit weights: MLX's quantized matmul's bits.
 *  Borrows inputs. */
export function affineRow(x: MlxArray, w: MlxArray, scales: MlxArray, biases: MlxArray, bits: 3 | 4): MlxArray {
  const K = x.shape.at(-1)!, M = x.size / K, N = scales.shape[0]!;
  if (M !== 1) throw new Error(`affineRow: M=${M}, one row only`);
  kernel ??= new MetalKernel({ name: "mlx_bun_affine_row", inputNames: ["x", "w", "scales", "biases"],
    outputNames: ["y"], source: SOURCE, header: HEADER, ensureRowContiguous: true });
  const [y] = kernel.apply([x, w, scales, biases], {
    outputs: [{ shape: [...x.shape.slice(0, -1), N], dtype: x.dtype }],
    grid: [32, N / R, 1], threadGroup: [32, S, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { N, K, BITS: bits, R, S },
  });
  return y!;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Kernels.Quantization.AffineRow
