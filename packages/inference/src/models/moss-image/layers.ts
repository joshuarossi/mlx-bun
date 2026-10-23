// MOSS-Image's own primitive layers. Each binds one kernel and does one job;
// the family's blocks and graphs arrange them. Weights are borrowed from the
// component's `Weights` (which frees them); a layer frees only what it made.

import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { quantFor, type ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import { situFor } from "../../kernels/situ";

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

/** The affine spec of a module the checkpoint stores quantized (it holds `.scales`),
 * or null for one stored dense (mlx-lm's convention: a module the quantizer
 * skipped for its shape has no table entry of its own). Inconsistent metadata
 * fails: an explicit table entry quantizing a module stored dense, a stored
 * module the table does not cover, a mode other than affine, missing `.biases`. */
export function storedAffineSpec(weights: Weights, config: ModelConfig, path: string): ops.QuantSpec | null {
  if (!weights.has(`${path}.scales`)) {
    const explicit = config.quantization?.perLayer.get(path);
    if (explicit && explicit.mode !== "none") throw new Error(`${path}: the quantization table quantizes it but the checkpoint stores it dense`);
    return null;
  }
  const spec = quantFor(config.quantization, path);
  if (!spec) throw new Error(`${path}: stored quantized but the quantization table has no entry for it`);
  if (spec.mode !== "affine") throw new Error(`${path}: ${spec.mode} quantization is not bound here (affine only)`);
  if (!weights.has(`${path}.biases`)) throw new Error(`${path}: affine-quantized but the checkpoint has no .biases`);
  return spec;
}

/** The projection the artifact stores at `path`, bound once by a family graph's
 * constructor: affine-quantized or dense as stored (`storedAffineSpec`), biased
 * when the checkpoint holds `.bias`. */
export function bindMossLinear(weights: Weights, config: ModelConfig, path: string): MossLinear {
  const weight = weights.tensor(`${path}.weight`);
  const bias = weights.has(`${path}.bias`) ? weights.tensor(`${path}.bias`) : null;
  const spec = storedAffineSpec(weights, config, path);
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

/** The SITU activation over `hidden` and `gate`, consuming both. The activations' dtype is fixed by the graph that builds
 * it; the kernel specialized to it is bound here, once. */
export class MossSitu {
  readonly #situ: (hidden: MlxArray, gate: MlxArray) => MlxArray;

  /** `dtype`: the dtype of every `hidden` and `gate` this layer will see. */
  constructor(dtype: Dtype) {
    this.#situ = situFor(dtype);
  }

  forward(hidden: MlxArray, gate: MlxArray): MlxArray {
    const out = this.#situ(hidden, gate);
    hidden.dispose(); gate.dispose();
    return out;
  }
}
