import host.ts.Source
namespace Host.Ts.Sources.Inference.Kernels.Delta.SiluRmsHeads
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/kernels/delta/silu-rms-heads.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// Copyright © 2024 Apple Inc. RMS reduction adapted under the MIT license;
// see THIRD_PARTY_NOTICES.md.
import type { MlxArray } from "@mlx-bun/mlx/array";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

// The convolution's compiled SiLU, then MLX's four-reads RMS reduction for
// Q/K heads of up to 128 values. Keep the activation in registers and write V directly:
// no full activated convolution tensor or strided split views are needed.
// Sigmoid, SiLU, normalization, and scaling each retain their dtype rounding.
const SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint head = threadgroup_position_in_grid.x;
  const uint row = threadgroup_position_in_grid.y;
  const bool normalize = head < uint(2 * HK);
  const uint width = normalize ? uint(DK) : uint(DV);
  const uint channel = normalize ? head * uint(DK)
    : uint(2 * HK * DK) + (head - uint(2 * HK)) * uint(DV);
  T values[4];
  float sum = 0.0f;
  for (uint i = 0; i < 4u; ++i) {
    const uint col = lane * 4u + i;
    const T value = col < width ? x[row * uint(C) + channel + col] : T(0);
    const auto y = 1 / (1 + metal::exp(metal::abs(value)));
    const T sigmoid = T(value < T(0) ? y : 1 - y);
    values[i] = T(value * sigmoid);
    const float activated = float(values[i]);
    sum += activated * activated;
  }
  if (normalize) {
    sum = metal::simd_sum(sum);
    const float inv = metal::precise::rsqrt(sum / float(DK) + 1e-6f);
    const uint index = (row * uint(HK) + head % uint(HK)) * uint(DK) + lane * 4u;
    for (uint i = 0; i < 4u; ++i) {
      if (lane * 4u + i >= uint(DK)) continue;
      const T normalized = T(float(values[i]) * inv);
      if (head < uint(HK)) q[index + i] = qscale[lane * 4u + i] * normalized;
      else k[index + i] = kscale[lane * 4u + i] * normalized;
    }
  } else {
    const uint index = (row * uint(HV) + head - uint(2 * HK)) * uint(DV) + lane * 4u;
    for (uint i = 0; i < 4u; ++i) if (lane * 4u + i < uint(DV)) v[index + i] = values[i];
  }
`;

let kernel: MetalKernel | undefined;

/** Convolved [B,S,2*Hk*Dk+Hv*Dv] to owned Q, K, V heads, Dk/Dv <=128.
 * Scale vectors have Dk entries in the input dtype, as MLX's RMS weights do. */
export function siluRmsHeads(x: MlxArray, qScale: MlxArray, kScale: MlxArray,
  keyHeads: number, valueHeads: number, valueWidth: number): [MlxArray, MlxArray, MlxArray] {
  const [batch, sequence, channels] = x.shape;
  const keyWidth = qScale.size;
  if (x.ndim !== 3 || channels !== 2 * keyHeads * keyWidth + valueHeads * valueWidth ||
      keyWidth < 1 || keyWidth > 128 || valueWidth < 1 || valueWidth > 128 ||
      qScale.ndim !== 1 || kScale.ndim !== 1 || kScale.size !== keyWidth ||
      qScale.dtype !== x.dtype || kScale.dtype !== x.dtype)
    throw new Error("siluRmsHeads: expects heads of up to 128 values and matching scale vectors");
  kernel ??= new MetalKernel({ name: "mlx_bun_silu_rms_heads", inputNames: ["x", "qscale", "kscale"],
    outputNames: ["q", "k", "v"], source: SOURCE });
  return kernel.apply([x, qScale, kScale], {
    outputs: [
      { shape: [batch!, sequence!, keyHeads, keyWidth], dtype: x.dtype },
      { shape: [batch!, sequence!, keyHeads, keyWidth], dtype: x.dtype },
      { shape: [batch!, sequence!, valueHeads, valueWidth], dtype: x.dtype },
    ],
    grid: [32 * (2 * keyHeads + valueHeads), batch! * sequence!, 1], threadGroup: [32, 1, 1],
    templateDtypes: { T: x.dtype }, templateInts: { C: channels!, HK: keyHeads, HV: valueHeads, DK: keyWidth, DV: valueWidth },
  }) as [MlxArray, MlxArray, MlxArray];
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Kernels.Delta.SiluRmsHeads
