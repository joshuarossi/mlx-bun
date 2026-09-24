// Universal-tier primitives: dense (unquantized) linear/embedding modules
// (Phase 1.5 — mlx nn.Linear / nn.Embedding semantics), quantized-or-dense
// loader helpers, norm loaders, and the load-time weight audit.
//
// The quantized paths delegate to the proven gemma4-base primitives; the
// dense paths are verbatim ports of mlx.nn.Linear (`mx.addmm(bias, x, W.T)`
// / `x @ W.T`) and mlx.nn.Embedding (`weight[ids]`, `x @ weight.T`).

import * as ops from "@mlx-bun/mlx/ops";
import type { ModelConfig } from "../artifacts/config";
import { WeightAudit,tensorUsed } from "../artifacts/weight-audit";
import type { Weights } from "../artifacts/weights";
import { DenseEmbedding } from "./dense-embedding";
import { DenseLinear } from "./dense-linear";
import { LayerNorm } from "./layer-norm";
import { RMSNorm } from "./normalization";
import { QuantizedEmbedding } from "./quantized-embedding";
import { QuantizedLinear } from "./quantized-linear";
import { TrellisLinear } from "./trellis-linear";

/** Either linear flavor behind one call surface. */
export type AnyLinear = QuantizedLinear | DenseLinear | TrellisLinear;

/** Quantized when `.scales` exists (MLX-quantized checkpoints), else dense
 *  bf16/f16/f32 (Phase 1.5). Both flavors carry the optional ADDITIVE
 *  `.bias` term (qwen2 qkv, starcoder2, …). */
export function loadLinear(
  weights: Weights, path: string, config: ModelConfig, audit: WeightAudit,
): AnyLinear {
  if (TrellisLinear.isTrellis(config, path)) {
    const lin = TrellisLinear.load(weights, path, config);
    audit.use(`${path}.weight`);
    audit.use(`${path}.scales`);
    return lin;
  }
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
