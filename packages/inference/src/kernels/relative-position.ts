import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

/** FastConformer's reversed relative positions, directly in the activation dtype. */
export class RelativePositionKernel {
  readonly #kernel = new MetalKernel({
    name: "mlx_bun_relative_positions",
    inputNames: ["frequencies"],
    outputNames: ["positions"],
    source: String.raw`
      const uint i = thread_position_in_grid.x;
      if (i >= uint((2 * Length - 1) * 1024)) return;
      const uint pair = i / 2u;
      const float theta = float(Length - 1 - int(pair / 512u)) * frequencies[pair % 512u];
      positions[i] = bfloat16_t((i & 1u) ? metal::precise::cos(theta) : metal::precise::sin(theta));
    `,
  });
  apply(frequencies: MlxArray, length: number): MlxArray {
    return this.#kernel.apply([frequencies], {
      outputs: [{ shape: [1, 2 * length - 1, 1024], dtype: Dtype.bfloat16 }],
      grid: [(2 * length - 1) * 1024, 1, 1],
      threadGroup: [256, 1, 1],
      templateInts: { Length: length },
    })[0]!;
  }
  dispose(): void {
    this.#kernel.dispose();
  }
}
