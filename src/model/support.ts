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

/** Speculative-decoding drafters (e.g. `gemma4_assistant`) are companion
 *  artifacts to a target model — Q-only, centroid-head, no standalone LM
 *  head. They are never servable/selectable on their own (the spec path
 *  loads them by explicit path), so they must be excluded from model
 *  resolution and the supported-model lists. See src/spec/drafter.ts. */
export function isDrafterModelType(modelType: string): boolean {
  return modelType.endsWith("_assistant");
}

export function isSupportedModelRecord(modelType: string, repoId = ""): boolean {
  if (isDrafterModelType(modelType)) return false;
  if (modelType.startsWith("gemma4")) return true;
  return modelType === "llama" && repoId.toLowerCase().includes("minicpm5-1b-optiq-4bit");
}

export function isSupportedModelConfig(config: ModelConfig): boolean {
  if (isDrafterModelType(config.modelType)) return false;
  return config.modelType.startsWith("gemma4") || isMiniCPM5Config(config);
}
