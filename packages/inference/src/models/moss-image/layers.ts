// MOSS-Image's own primitive layers. Each binds one kernel and does one job;
// the family's blocks and graphs arrange them. Weights are borrowed from the
// component's `Weights` (which frees them); a layer frees only what it made.

import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { quantFor, type ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import { situ } from "../../kernels/situ";

/** A dense projection without a bias, `x @ w.T`. Owns the transposed view it makes. */
export class MossDenseLinear {
  readonly #wT: MlxArray;
  constructor(readonly w: MlxArray) { this.#wT = ops.transposeAxes(w, [1, 0]); }
  /** `x` borrowed; returns an owned result. */
  forward(x: MlxArray): MlxArray { return ops.matmul(x, this.#wT); }
  dispose(): void { this.#wT.dispose(); }
}

/** A dense projection with a bias, `bias + x @ w.T`. Owns the transposed view it makes. */
export class MossDenseBiasedLinear {
  readonly #wT: MlxArray;
  constructor(readonly w: MlxArray, readonly bias: MlxArray) { this.#wT = ops.transposeAxes(w, [1, 0]); }
  forward(x: MlxArray): MlxArray { return ops.addmm(this.bias, x, this.#wT); }
  dispose(): void { this.#wT.dispose(); }
}

/** An MLX affine-quantized projection without a bias (`.weight` packed, `.scales`, `.biases`). Holds only borrowed tensors. */
export class MossQuantizedLinear {
  constructor(readonly w: MlxArray, readonly scales: MlxArray, readonly biases: MlxArray, readonly spec: ops.QuantSpec) {}
  forward(x: MlxArray): MlxArray { return ops.quantizedMatmul(x, this.w, this.scales, this.biases, this.spec, true); }
  dispose(): void {}
}

/** An MLX affine-quantized projection with an additive `.bias`. Holds only borrowed tensors. */
export class MossQuantizedBiasedLinear {
  constructor(readonly w: MlxArray, readonly scales: MlxArray, readonly biases: MlxArray, readonly spec: ops.QuantSpec,
    readonly bias: MlxArray) {}
  forward(x: MlxArray): MlxArray {
    using product = ops.quantizedMatmul(x, this.w, this.scales, this.biases, this.spec, true);
    return ops.add(product, this.bias);
  }
  dispose(): void {}
}

export type MossLinear = MossDenseLinear | MossDenseBiasedLinear | MossQuantizedLinear | MossQuantizedBiasedLinear;

/** The projection the artifact stores at `path`, bound once by a family graph's
 * constructor: quantized when the component's quantization table covers the
 * path (affine, so `.biases` is required), dense otherwise; biased when the
 * checkpoint holds `.bias`. */
export function bindMossLinear(weights: Weights, config: ModelConfig, path: string): MossLinear {
  const spec = quantFor(config.quantization, path);
  const weight = weights.tensor(`${path}.weight`);
  const bias = weights.has(`${path}.bias`) ? weights.tensor(`${path}.bias`) : null;
  if (!spec) return bias ? new MossDenseBiasedLinear(weight, bias) : new MossDenseLinear(weight);
  const scales = weights.tensor(`${path}.scales`), biases = weights.tensor(`${path}.biases`);
  return bias ? new MossQuantizedBiasedLinear(weight, scales, biases, spec, bias) : new MossQuantizedLinear(weight, scales, biases, spec);
}

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
