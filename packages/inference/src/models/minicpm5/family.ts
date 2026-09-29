import { GENERIC_GENERATION_DEFAULTS, L1, defineFamily } from "../family";

/** MiniCPM5 ships as `llama`; its dimensions are what tell it from a plain
 * Llama, so a listing that has only the `model_type` cannot name it. */
export const MINICPM5_FAMILY = defineFamily({
  graph: "minicpm5",
  accepts: config => {
    const t = config.text;
    return config.modelType === "llama" &&
      t.hiddenSize === 1536 &&
      t.numHiddenLayers === 24 &&
      t.numAttentionHeads === 16 &&
      t.numKeyValueHeads === 2 &&
      t.headDim === 128 &&
      t.vocabSize === 130560 &&
      t.tieWordEmbeddings === false;
  },
  hasModelType: () => false,
  tier: "targeted",
  label: "MiniCPM5",
  loader: "safetensors",
  loop: "autoregressive",
  fidelity: L1,
  specialization: "dedicated",
  profileId: "minicpm5-dedicated",
  capabilities: ["minicpm5-graph"],
  // The model card recommends direct replies unless thinking is asked for.
  generationDefaults: { ...GENERIC_GENERATION_DEFAULTS, enableThinking: false },
});
