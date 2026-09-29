import type { SentinelTokenTexts, MediaTokenTexts } from "../../input/special-tokens";
import { L1, type TrainingDefaults, configuredMoe, defineFamily } from "../family";

/** Construction identities of the specializations generated from a Gemma 4 config
 * (`scripts/gen-gemma4.ts`). Metadata only: inspecting a profile never loads a graph. */
export const GENERATED_GEMMA_FINGERPRINTS = Object.freeze({
  "12b": "9f812d2eb461fcbe",
  "e4b": "418e9adc386ea67c",
  "26b": "c9dd67ed5a525231",
});

/** Gemma-family towers (Gemma 4 and DiffusionGemma) train on longer sequences than the generic default. */
export const GEMMA_TRAINING_DEFAULTS: TrainingDefaults = Object.freeze({ maxSeqLength: 8192 });

const GEMMA_SENTINELS: SentinelTokenTexts = Object.freeze({
  toolCallStart: "<|tool_call>", toolCallEnd: "<tool_call|>", channelStart: "<|channel>", channelEnd: "<channel|>",
});
export const GEMMA_MEDIA_TOKENS: MediaTokenTexts = Object.freeze({
  vision: Object.freeze({ image: "<|image|>", begin: "<|image>", end: "<image|>" }),
  audio: Object.freeze({ audio: "<|audio|>", begin: "<|audio>", end: "<audio|>" }),
});

export const GEMMA4_FAMILY = defineFamily({
  graph: "gemma4",
  accepts: config => config.modelType.startsWith("gemma4"),
  hasModelType: modelType => modelType.startsWith("gemma4"),
  tier: "targeted",
  label: "gemma4*",
  loader: "safetensors",
  loop: "autoregressive",
  fidelity: L1,
  specialization: "dedicated",
  profileId: "gemma4-dedicated",
  capabilities: ["gemma4-graph"],
  generated: { profileId: "gemma4-generated", fingerprints: Object.values(GENERATED_GEMMA_FINGERPRINTS) },
  moe: configuredMoe,
  trainingDefaults: GEMMA_TRAINING_DEFAULTS,
  sentinels: GEMMA_SENTINELS,
  mediaTokens: GEMMA_MEDIA_TOKENS,
});
