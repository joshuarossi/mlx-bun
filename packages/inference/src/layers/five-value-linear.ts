import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { FiveValueExpandKernel } from "../kernels/five-value-linear";
/** Expands the packed artifact once with Metal, then uses tiled fp16 GEMM.
 * Inputs are borrowed during construction; the layer owns its dense weight. */
export class FiveValueLinear {
  readonly #weightT: MlxArray;
  readonly weightBytes: number;
  constructor(
    base: MlxArray,
    residual: MlxArray,
    lo: MlxArray,
    delta: MlxArray,
  ) {
    const kernel = new FiveValueExpandKernel();
    try {
      using weight = kernel.apply(base, residual, lo, delta);
      weight.eval();
      this.weightBytes = weight.nbytes;
      this.#weightT = ops.transposeAxes(weight, [1, 0]);
    } finally {
      kernel.dispose();
    }
  }
  forward(x: MlxArray): MlxArray {
    using half = x.astype(Dtype.float16);
    using y = ops.matmul(half, this.#weightT);
    return y.astype(x.dtype);
  }
  dispose(): void {
    this.#weightT.dispose();
  }
}
