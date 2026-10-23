// MOSS-Image's own primitive layers. Each binds one kernel and does one job;
// the family's blocks and graphs arrange them. Weights are borrowed from the
// component's `Weights` (which frees them); a layer frees only what it made.

import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { quantFor, type ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import { situ } from "../../kernels/situ";

/** A dense projection, `x @ w.T (+ bias)`. Owns the transposed view it makes. */
export class MossDenseLinear {
  readonly #wT: MlxArray;

  constructor(readonly w: MlxArray, readonly bias: MlxArray | null) {
    this.#wT = ops.transposeAxes(w, [1, 0]);
  }

  static load(weights: Weights, path: string): MossDenseLinear {
    return new MossDenseLinear(weights.tensor(`${path}.weight`), weights.has(`${path}.bias`) ? weights.tensor(`${path}.bias`) : null);
  }

  /** `x` borrowed; returns an owned result. */
  forward(x: MlxArray): MlxArray {
    return this.bias ? ops.addmm(this.bias, x, this.#wT) : ops.matmul(x, this.#wT);
  }

  dispose(): void {
    this.#wT.dispose();
  }
}

/** An MLX affine-quantized projection (`.weight` packed, `.scales`, `.biases`,
 * optional `.bias`). Holds only borrowed tensors. */
export class MossQuantizedLinear {
  constructor(readonly w: MlxArray, readonly scales: MlxArray, readonly biases: MlxArray | null,
    readonly spec: ops.QuantSpec, readonly bias: MlxArray | null) {}

  /** The spec comes from the component config's `quantization` table entry for `path`. */
  static load(weights: Weights, path: string, config: ModelConfig): MossQuantizedLinear {
    const spec = quantFor(config.quantization, path);
    if (!spec) throw new Error(`${path}: the quantization table has no entry for a quantized projection`);
    return new MossQuantizedLinear(weights.tensor(`${path}.weight`), weights.tensor(`${path}.scales`),
      weights.has(`${path}.biases`) ? weights.tensor(`${path}.biases`) : null, spec,
      weights.has(`${path}.bias`) ? weights.tensor(`${path}.bias`) : null);
  }

  forward(x: MlxArray): MlxArray {
    const out = ops.quantizedMatmul(x, this.w, this.scales, this.biases, this.spec, true);
    if (!this.bias) return out;
    using product = out;
    return ops.add(product, this.bias);
  }

  dispose(): void {}
}

export type MossLinear = MossDenseLinear | MossQuantizedLinear;

/** RMS normalization with a learned gain: statistics in float32, the normalized
 * value in the input dtype times the gain (the reference `_RMSNorm`). */
export class MossRmsNorm {
  constructor(readonly weight: MlxArray, readonly eps: number) {}

  forward(x: MlxArray): MlxArray {
    return ops.rmsNorm(x, this.weight, this.eps);
  }
}

/** The SITU activation over `hidden` and `gate`, consuming both. */
export class MossSitu {
  forward(hidden: MlxArray, gate: MlxArray): MlxArray {
    const out = situ(hidden, gate);
    hidden.dispose(); gate.dispose();
    return out;
  }
}
