import type { ModelConfig } from "../config";
import { GENERIC_MODEL_TYPES, genericArgsFor, remapModelType } from "./universal/archs";

export function isMiniCPM5Config(config: ModelConfig): boolean {
  const t = config.text;
  return config.modelType === "llama" &&
    t.hiddenSize === 1536 &&
    t.numHiddenLayers === 24 &&
    t.numAttentionHeads === 16 &&
    t.numKeyValueHeads === 2 &&
    t.headDim === 128 &&
    t.vocabSize === 130560 &&
    t.tieWordEmbeddings === false;
}

/** Qwen3.5 hybrid gated-DeltaNet family (model_type qwen3_5 / qwen3_5_text).
 *  Dense MLP only for now — the MoE variant (qwen3_5_moe) is deferred. */
export function isQwen35Config(config: ModelConfig): boolean {
  return (config.modelType === "qwen3_5" || config.modelType === "qwen3_5_text") &&
    !config.text.enableMoeBlock &&
    config.text.numExperts === 0 &&
    config.text.linearNumValueHeads > 0 &&
    config.text.fullAttentionInterval > 0;
}

/** Plain Qwen3 (model_type `qwen3`, Qwen3ForCausalLM) — a standard dense decoder
 *  with per-head q/k norm and tied embeddings. Used here as the text-embedding
 *  backbone (mlx-community Qwen3-Embedding-*). Distinct from the qwen3_5 hybrid. */
export function isQwen3Config(config: ModelConfig): boolean {
  return config.modelType === "qwen3";
}

/** Speculative-decoding drafters (e.g. `gemma4_assistant`) are companion
 *  artifacts to a target model — Q-only, centroid-head, no standalone LM
 *  head. They are never servable/selectable on their own (the spec path
 *  loads them by explicit path), so they must be excluded from model
 *  resolution and the supported-model lists. See src/spec/drafter.ts. */
export function isDrafterModelType(modelType: string): boolean {
  return modelType.endsWith("_assistant");
}

/** DiffusionGemma (model_type `diffusion_gemma`): block/masked-diffusion canvas
 *  model. Non-autoregressive — routed through the diffusion engine, not the AR
 *  loop. See docs/design/diffusion-gemma-port.md. */
export function isDiffusionGemmaConfig(config: ModelConfig): boolean {
  return config.modelType === "diffusion_gemma";
}

/** Support tier for a registry record (docs/design/generic-model-support.md):
 *  "targeted" = dedicated/generated forward + L2/L3 paths;
 *  "generic"  = the Tier-0 universal module (L1 monolith only);
 *  null       = unsupported. Generic never shadows targeted. */
export function supportTier(modelType: string, repoId = ""): "targeted" | "generic" | null {
  if (isDrafterModelType(modelType)) return null;
  if (modelType.startsWith("gemma4")) return "targeted";
  if (modelType === "diffusion_gemma") return "targeted";
  // qwen3_5 / qwen3_5_text (dense hybrid). The MoE variant is a separate type.
  if (modelType === "qwen3_5" || modelType === "qwen3_5_text") return "targeted";
  if (modelType === "qwen3") return "targeted"; // plain Qwen3 (embedding backbone)
  if (modelType === "llama" && repoId.toLowerCase().includes("minicpm5-1b-optiq-4bit"))
    return "targeted";
  // Tier-0 generic fallback: the universal-dense descriptor table.
  if (GENERIC_MODEL_TYPES.has(remapModelType(modelType))) return "generic";
  return null;
}

export function isSupportedModelRecord(modelType: string, repoId = ""): boolean {
  return supportTier(modelType, repoId) !== null;
}

export function isSupportedModelConfig(config: ModelConfig): boolean {
  if (isDrafterModelType(config.modelType)) return false;
  if (
    config.modelType.startsWith("gemma4") || isMiniCPM5Config(config) ||
    isQwen35Config(config) || isQwen3Config(config) || isDiffusionGemmaConfig(config)
  ) return true;
  // Generic tier: an arch descriptor exists for this model_type (and its
  // config parses — a malformed config is unsupported, not a crash).
  try {
    return genericArgsFor(config) !== null;
  } catch {
    return false;
  }
}
