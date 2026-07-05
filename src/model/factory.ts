// Model construction with generated-specialization dispatch
// (docs/design/optimization_plan.md Phase C): pick the generated class whose config
// fingerprint matches, else the monolith. Generated classes subclass
// Gemma4Model and only override forwardLayers (with their own
// cache-signature guard), so the choice is always safe.

import type { ModelConfig } from "../config";
import type { Weights } from "../weights";
import { Gemma4Model } from "./gemma4";
import { configFingerprint } from "./fingerprint";
import { GENERATED } from "./generated";
import { MiniCPM5Model } from "./minicpm5";
import { Qwen35Model } from "./qwen3_5";
import { Qwen3Model } from "./qwen3";
import { Qwen3MoeModel } from "./qwen3-moe";
import { DiffusionGemmaModel } from "./diffusion-gemma";
import { UniversalDenseModel } from "./universal/dense";
import { genericArgsFor, GENERIC_MODEL_TYPES, remapModelType } from "./universal/archs";
import { isDiffusionGemmaConfig, isMiniCPM5Config, isQwen35Config, isQwen3Config, isQwen3MoeConfig } from "./support";

export type RuntimeModel =
  | Gemma4Model | MiniCPM5Model | Qwen35Model | Qwen3Model | Qwen3MoeModel
  | DiffusionGemmaModel | UniversalDenseModel;

/** Dispatch ladder (docs/design/generic-model-support.md §3.3):
 *  dedicated → generated/monolith (gemma4*) → generic (Tier-0 universal)
 *  → reject with a helpful error. Generic never shadows a dedicated port. */
export function createModel(weights: Weights, config: ModelConfig): RuntimeModel {
  // 1. Dedicated classes.
  // DiffusionGemma is non-autoregressive — generate() detects it and routes to
  // the denoising engine instead of the AR decode loop. It exposes the shared
  // RuntimeModel surface (config/weightsBytes/loraState/makeCache) with the
  // AR-only methods as throwing stubs (never called on this model).
  if (isDiffusionGemmaConfig(config)) return new DiffusionGemmaModel(weights, config);
  if (isMiniCPM5Config(config)) return new MiniCPM5Model(weights, config);
  if (isQwen35Config(config)) return new Qwen35Model(weights, config);
  if (isQwen3MoeConfig(config)) return new Qwen3MoeModel(weights, config);
  if (isQwen3Config(config)) return new Qwen3Model(weights, config);
  // 2. gemma4*: fingerprint-matched generated specialization, else monolith.
  //    Always prefer the model-specific generated file when its config
  //    fingerprint matches — the parity regime is selected by the OUTPUT-changing
  //    flags (kv-quant), which the generated forward already gates, NOT by
  //    detouring an optimized model through the generic monolith.
  if (config.modelType.startsWith("gemma4")) {
    const cls = GENERATED.get(configFingerprint(config)) ?? Gemma4Model;
    return new cls(weights, config);
  }
  // 3. Generic Tier-0 fallback: the universal-dense descriptor table
  // (replaces the old hard "llama = MiniCPM5 only" / unknown-type throws).
  const generic = genericArgsFor(config);
  if (generic) return new UniversalDenseModel(weights, config, generic);
  // 4. Reject, naming the arch (post-remap) and the declared surface.
  const arch = remapModelType(config.modelType);
  throw new Error(
    `unsupported model_type "${config.modelType}"` +
    (arch !== config.modelType ? ` (mlx-lm remaps it to "${arch}")` : "") +
    ` — targeted: gemma4*, diffusion_gemma, qwen3_5, qwen3, qwen3_moe, MiniCPM5;` +
    ` generic (Tier-0): ${[...GENERIC_MODEL_TYPES].sort().join(", ")}`,
  );
}
