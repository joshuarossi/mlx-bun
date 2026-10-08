import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { quantFor,type ModelConfig } from "../artifacts/config";
import { expertOffloadArray } from "../artifacts/expert-offload";
import type { Weights } from "../artifacts/weights";

/** Port of switch_layers.QuantizedSwitchLinear (gather_qmm over stacked
 *  expert weights; rhs_indices selects the expert per row). */
export class QuantizedSwitchLinear {
  constructor(
    readonly w: MlxArray,
    readonly scales: MlxArray,
    readonly biases: MlxArray | null,
    readonly spec: ops.QuantSpec,
  ) {}

  static load(weights: Weights, path: string, config: ModelConfig): QuantizedSwitchLinear {
    if (!weights.has(`${path}.scales`))
      throw new Error(`${path}: expected quantized switch linear (no .scales tensor)`);
    const spec = quantFor(config.quantization, path);
    if (!spec) throw new Error(`${path}: no quant spec`);
    // Expert WEIGHT (the ~94% of expert bytes) comes from the page-aligned
    // offload mmap when --expert-offload is active (else resident); scales/
    // biases stay resident (small). Same bytes either way → bit-exact.
    const wName = `${path}.weight`;
    return new QuantizedSwitchLinear(
      expertOffloadArray(wName) ?? weights.tensor(wName),
      weights.tensor(`${path}.scales`),
      weights.has(`${path}.biases`) ? weights.tensor(`${path}.biases`) : null,
      spec,
    );
  }

  forward(x: MlxArray, indices: MlxArray, sortedIndices: boolean): MlxArray {
    return ops.gatherQmm(x, this.w, this.scales, this.biases, indices, this.spec, sortedIndices);
  }
}
