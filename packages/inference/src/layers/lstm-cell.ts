import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { LstmGatesKernel } from "../kernels/lstm-gates";
/** Single-time-step LSTM. Borrows weights and owns transposed views and gate kernel. */
export class LstmCell {
  readonly #wxT: MlxArray;
  readonly #whT: MlxArray;
  readonly #gates = new LstmGatesKernel();
  constructor(
    wx: MlxArray,
    wh: MlxArray,
    readonly bias: MlxArray,
  ) {
    try {
      this.#wxT = ops.transposeAxes(wx, [1, 0]);
      this.#whT = ops.transposeAxes(wh, [1, 0]);
    } catch (error) {
      this.dispose();
      throw error;
    }
  }
  forward(x: MlxArray, h: MlxArray, c: MlxArray): [MlxArray, MlxArray] {
    using input = ops.addmm(this.bias, x, this.#wxT);
    using gates = ops.addmm(input, h, this.#whT);
    return this.#gates.apply(gates, c);
  }
  dispose(): void {
    this.#wxT?.dispose();
    this.#whT?.dispose();
    this.#gates.dispose();
  }
}
