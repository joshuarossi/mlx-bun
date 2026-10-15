import type { MlxArray } from "@mlx-bun/mlx/array";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import { residualRmsNorm } from "../kernels/residual-rms-norm";
import { gatedRmsNorm } from "../kernels/gated-rms-norm";

// Shared traces take weights as inputs: they retain no model weights or cache
// state. Shape-aware compilation retraces the custom grid when dimensions change.
const residualFunctions = new Map<number, CompiledFunction>();
const gatedFunctions = new Map<number, CompiledFunction>();

/** Residual addition and weighted normalization, preserving both rounding steps. */
export class CompiledResidualRMSNorm {
  readonly #operation: CompiledFunction;
  constructor(readonly weight: MlxArray, readonly eps: number) {
    let operation = residualFunctions.get(eps);
    if (!operation) {
      operation = new CompiledFunction(inputs => residualRmsNorm(inputs[0]!, inputs[1]!, inputs[2]!, eps), false);
      residualFunctions.set(eps, operation);
    }
    this.#operation = operation;
  }
  forward(x: MlxArray, update: MlxArray): [MlxArray, MlxArray] {
    return this.#operation.apply([x, update, this.weight]) as [MlxArray, MlxArray];
  }
}

/** Weighted normalization followed by Qwen's float32 SiLU gate. */
export class CompiledGatedRMSNorm {
  readonly #operation: CompiledFunction;
  constructor(readonly weight: MlxArray, readonly eps: number) {
    let operation = gatedFunctions.get(eps);
    if (!operation) {
      operation = new CompiledFunction(inputs => [gatedRmsNorm(inputs[0]!, inputs[1]!, inputs[2]!, eps)], false);
      gatedFunctions.set(eps, operation);
    }
    this.#operation = operation;
  }
  forward(x: MlxArray, gate: MlxArray): MlxArray {
    return this.#operation.apply([x, gate, this.weight])[0]!;
  }
}
