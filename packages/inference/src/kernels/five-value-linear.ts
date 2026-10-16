import { Dtype } from "@mlx-bun/mlx/ffi";
import type { MlxArray } from "@mlx-bun/mlx/array";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

/** Expand once at load time; the five palette values are exactly representable
 * in fp16. Forward projections use MLX's tiled matrix multiplication. */
export class FiveValueExpandKernel {
  readonly #kernel = new MetalKernel({
    name: "mlx_bun_five_value_expand",
    inputNames: ["base", "residual", "lo", "delta"],
    outputNames: ["weight"],
    source: String.raw`
      const uint i = thread_position_in_grid.x;
      if (i >= uint(N * K)) return;
      const uint row = i / uint(K), shift = 2u * (i % 16u);
      const float a = float(int((base[i / 16u] >> shift) & 3u) - 1) * lo[row];
      const float b = float(int((residual[i / 16u] >> shift) & 3u) - 1) * delta[row];
      weight[i] = half(a + b);
    `,
  });
  apply(
    base: MlxArray,
    residual: MlxArray,
    lo: MlxArray,
    delta: MlxArray,
  ): MlxArray {
    const n = base.shape[0]!,
      k = base.shape[1]! * 16;
    return this.#kernel.apply([base, residual, lo, delta], {
      outputs: [{ shape: [n, k], dtype: Dtype.float16 }],
      grid: [n * k, 1, 1],
      threadGroup: [256, 1, 1],
      templateInts: { N: n, K: k },
    })[0]!;
  }
  dispose(): void {
    this.#kernel.dispose();
  }
}
