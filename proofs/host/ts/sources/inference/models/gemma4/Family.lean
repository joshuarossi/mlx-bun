import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.Family
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/family.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { SentinelTokenTexts, MediaTokenTexts } from "../../input/special-tokens";
import { L1, type TrainingDefaults, configuredMoe, defineFamily } from "../family";

/** Artifact fingerprints used by the written Gemma 4 graph entries
 * (`graphs.ts`). Metadata only. */
export const GEMMA_GRAPH_FINGERPRINTS = Object.freeze({
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
  moe: configuredMoe,
  trainingDefaults: GEMMA_TRAINING_DEFAULTS,
  sentinels: GEMMA_SENTINELS,
  mediaTokens: GEMMA_MEDIA_TOKENS,
});
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.Family
