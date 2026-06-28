import type { ModelConfig } from "../config";

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

export function isSupportedModelRecord(modelType: string, repoId = ""): boolean {
  if (isDrafterModelType(modelType)) return false;
  if (modelType.startsWith("gemma4")) return true;
  if (modelType === "diffusion_gemma") return true;
  // qwen3_5 / qwen3_5_text (dense hybrid). The MoE variant is a separate type.
  if (modelType === "qwen3_5" || modelType === "qwen3_5_text") return true;
  if (modelType === "qwen3") return true; // plain Qwen3 (embedding backbone)
  return modelType === "llama" && repoId.toLowerCase().includes("minicpm5-1b-optiq-4bit");
}

export function isSupportedModelConfig(config: ModelConfig): boolean {
  if (isDrafterModelType(config.modelType)) return false;
  return config.modelType.startsWith("gemma4") || isMiniCPM5Config(config) ||
    isQwen35Config(config) || isQwen3Config(config) || isDiffusionGemmaConfig(config);
}
