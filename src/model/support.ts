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

export function isSupportedModelRecord(modelType: string, repoId = ""): boolean {
  if (modelType.startsWith("gemma4")) return true;
  return modelType === "llama" && repoId.toLowerCase().includes("minicpm5-1b-optiq-4bit");
}

export function isSupportedModelConfig(config: ModelConfig): boolean {
  return config.modelType.startsWith("gemma4") || isMiniCPM5Config(config);
}
