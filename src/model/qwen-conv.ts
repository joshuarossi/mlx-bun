// Experimental Qwen GDN convolution. Its two outputs are evaluated together:
// consuming the activation also materializes the small, independently owned
// state tail, without keeping a concatenated prefill buffer alive for it.
// Arithmetic follows MLX 0.31.2 depthwise_conv_1d and unary sigmoid (MIT,
// Copyright Apple Inc.), preserving the bf16 intermediate rounding.
import type { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";

/** Borrow all inputs; return owned activation and an independent state tail. */
export type QwenConvolution = (x: MlxArray, state: MlxArray, weight: MlxArray) => [MlxArray, MlxArray];

let kernel: MetalKernel | null = null;
export const fusedQwenConvolution: QwenConvolution = (x, state, weight) => {
  const [B, M, D] = x.shape as [number, number, number];
  const K = weight.shape[1]!;
  if (x.shape.length !== 3 || weight.shape.length !== 3 || weight.shape[0] !== D ||
      weight.shape[2] !== 1 || K !== 4 || state.shape.join() !== [B, K - 1, D].join() ||
      ![Dtype.bfloat16, Dtype.float32].includes(x.dtype) || state.dtype !== x.dtype || weight.dtype !== x.dtype)
    throw new Error("fused Qwen convolution requires matching bf16/f32 inputs, [B,M,D], [B,3,D], [D,4,1]");
  kernel ??= new MetalKernel({ name: "qwen_causal_conv_silu_tail",
    inputNames: ["state", "x", "w"], outputNames: ["out", "tail"],
    source: String.raw`
      const uint c = thread_position_in_grid.x;
      const uint t = thread_position_in_grid.y;
      const uint b = thread_position_in_grid.z;
      if (c >= D) return;
      if (t < M) {
        float acc = 0.0f;
        for (uint i = 0; i < K; ++i) {
          const uint row = t + i;
          const T value = row < K-1 ? state[(b*(K-1)+row)*D+c] : x[(b*M+row-(K-1))*D+c];
          acc += float(value) * float(w[c*K+i]);
        }
        const T conv = T(acc);
        // Preserve the pinned MLX sigmoid's typed operations and bf16
        // intermediate rounding. Promoting this expression to f32 differs.
        const auto y = 1 / (1 + metal::exp(metal::abs(conv)));
        const T sig = conv < 0 ? y : 1-y;
        out[(b*M+t)*D+c] = conv * sig;
      }
      if (t < K-1) {
        const uint row = M + t;
        tail[(b*(K-1)+t)*D+c] = row < K-1 ? state[(b*(K-1)+row)*D+c] : x[(b*M+row-(K-1))*D+c];
      }
    ` });
  return kernel.apply([state, x, weight], {
    outputs: [{ shape: [B, M, D], dtype: x.dtype }, { shape: [B, K - 1, D], dtype: x.dtype }],
    grid: [D, Math.max(M, K - 1), B], threadGroup: [256, 1, 1],
    templateDtypes: { T: x.dtype }, templateInts: { D, M, K },
  }) as [MlxArray, MlxArray];
};
