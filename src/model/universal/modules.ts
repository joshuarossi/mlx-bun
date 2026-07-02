// Universal-tier primitives: dense (unquantized) linear/embedding modules
// (Phase 1.5 — mlx nn.Linear / nn.Embedding semantics), quantized-or-dense
// loader helpers, norm loaders, and the load-time weight audit.
//
// The quantized paths delegate to the proven gemma4-base primitives; the
// dense paths are verbatim ports of mlx.nn.Linear (`mx.addmm(bias, x, W.T)`
// / `x @ W.T`) and mlx.nn.Embedding (`weight[ids]`, `x @ weight.T`).

import type { ModelConfig } from "../../config";
import type { Weights } from "../../weights";
import { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import { QuantizedEmbedding, QuantizedLinear, RMSNorm } from "../gemma4-base";

/** Records every tensor a universal load consumes; `finish` diffs against
 *  the shard index so a descriptor mistake is a LOAD error (unconsumed /
 *  missing tensors named), never a silently-wrong model
 *  (docs/design/generic-model-support.md §3.4). */
export class WeightAudit {
  readonly consumed = new Set<string>();

  use(name: string): void {
    this.consumed.add(name);
  }

  /** `drop` = the arch's sanitize rules (tensors mlx-lm discards on load,
   *  e.g. rotary_emb.inv_freq, or lm_head.weight under tied embeddings). */
  finish(weights: Weights, drop: RegExp[]): void {
    const unconsumed = weights.tensorNames.filter(
      (n) => !this.consumed.has(n) && !drop.some((re) => re.test(n)),
    );
    if (unconsumed.length > 0)
      throw new Error(
        `weight audit: ${unconsumed.length} tensor(s) in the checkpoint were not consumed ` +
        `by the universal module (descriptor mismatch?): ${unconsumed.slice(0, 12).join(", ")}` +
        (unconsumed.length > 12 ? ", …" : ""),
      );
  }
}

/** Load a tensor and record it in the audit. */
function tensorUsed(weights: Weights, audit: WeightAudit, name: string): MlxArray {
  audit.use(name);
  return weights.tensor(name);
}

/** Plain unquantized linear — mlx nn.Linear:
 *  `mx.addmm(bias, x, weight.T)` when bias is present, else `x @ weight.T`. */
export class DenseLinear {
  readonly wT: MlxArray;

  constructor(readonly w: MlxArray, readonly bias: MlxArray | null) {
    this.wT = ops.transposeAxes(w, [1, 0]); // lazy view, shared across calls
  }

  get inFeatures(): number {
    return this.w.shape[1]!;
  }
  get outFeatures(): number {
    return this.w.shape[0]!;
  }

  forward(x: MlxArray): MlxArray {
    return this.bias ? ops.addmm(this.bias, x, this.wT) : ops.matmul(x, this.wT);
  }
}

/** Either linear flavor behind one call surface. */
export type AnyLinear = QuantizedLinear | DenseLinear;

/** Quantized when `.scales` exists (MLX-quantized checkpoints), else dense
 *  bf16/f16/f32 (Phase 1.5). Both flavors carry the optional ADDITIVE
 *  `.bias` term (qwen2 qkv, starcoder2, …). */
export function loadLinear(
  weights: Weights, path: string, config: ModelConfig, audit: WeightAudit,
): AnyLinear {
  if (weights.has(`${path}.scales`)) {
    const lin = QuantizedLinear.load(weights, path, config);
    audit.use(`${path}.weight`);
    audit.use(`${path}.scales`);
    if (weights.has(`${path}.biases`)) audit.use(`${path}.biases`);
    if (weights.has(`${path}.bias`)) audit.use(`${path}.bias`);
    return lin;
  }
  if (!weights.has(`${path}.weight`))
    throw new Error(`${path}: no .weight tensor (nor .scales) in checkpoint`);
  return new DenseLinear(
    tensorUsed(weights, audit, `${path}.weight`),
    weights.has(`${path}.bias`) ? tensorUsed(weights, audit, `${path}.bias`) : null,
  );
}

/** Plain unquantized embedding — mlx nn.Embedding (+ as_linear tied head). */
export class DenseEmbedding {
  readonly wT: MlxArray;

  constructor(readonly w: MlxArray) {
    this.wT = ops.transposeAxes(w, [1, 0]);
  }

  encode(ids: MlxArray): MlxArray {
    return ops.takeAxis(this.w, ids, 0);
  }

  /** nn.Embedding.as_linear: `x @ weight.T`. */
  asLinear(h: MlxArray): MlxArray {
    return ops.matmul(h, this.wT);
  }
}

export type AnyEmbedding = QuantizedEmbedding | DenseEmbedding;

export function loadEmbedding(
  weights: Weights, path: string, config: ModelConfig, audit: WeightAudit,
): AnyEmbedding {
  if (weights.has(`${path}.scales`)) {
    const emb = QuantizedEmbedding.load(weights, path, config);
    audit.use(`${path}.weight`);
    audit.use(`${path}.scales`);
    if (weights.has(`${path}.biases`)) audit.use(`${path}.biases`);
    return emb;
  }
  return new DenseEmbedding(tensorUsed(weights, audit, `${path}.weight`));
}

/** RMSNorm loader; `plusOne` = the gemma-family `1.0 + weight` variant
 *  (the add is folded once at load — identical value to mlx-lm's
 *  per-call `1.0 + self.weight`). */
export function loadRmsNorm(
  weights: Weights, path: string, eps: number, plusOne: boolean, audit: WeightAudit,
): RMSNorm {
  const w = tensorUsed(weights, audit, `${path}.weight`);
  if (!plusOne) return new RMSNorm(w, eps);
  const one = ops.scalarLike(1, w);
  const w1 = ops.add(one, w);
  one.dispose();
  return new RMSNorm(w1, eps);
}

/** mlx nn.LayerNorm (weight + bias affine — starcoder2's norm). */
export class LayerNorm {
  constructor(
    readonly weight: MlxArray,
    readonly bias: MlxArray | null,
    readonly eps: number,
  ) {}

  forward(x: MlxArray): MlxArray {
    return ops.layerNorm(x, this.weight, this.bias, this.eps);
  }
}

export type AnyNorm = RMSNorm | LayerNorm;

export function loadLayerNorm(
  weights: Weights, path: string, eps: number, audit: WeightAudit,
): LayerNorm {
  return new LayerNorm(
    tensorUsed(weights, audit, `${path}.weight`),
    weights.has(`${path}.bias`) ? tensorUsed(weights, audit, `${path}.bias`) : null,
    eps,
  );
}
