import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Whisper.Family
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/whisper/family.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { L1_WHISPER, defineFamily } from "../family";

/** Whisper (model_type `whisper`, mlx-whisper ModelDimensions config):
 * encoder-decoder speech recognition, audio in and text out. Routed through the
 * transcription engine, never the chat loop. */
export const WHISPER_FAMILY = defineFamily({
  graph: "whisper",
  accepts: config => config.modelType === "whisper" && typeof config.raw.n_audio_ctx === "number",
  hasModelType: modelType => modelType === "whisper",
  tier: "targeted",
  label: "whisper",
  loader: "safetensors",
  loop: "encoder-decoder",
  fidelity: L1_WHISPER,
  specialization: "dedicated",
  profileId: "whisper-dedicated",
  capabilities: ["whisper-graph"],
  transcribes: true,
});
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Whisper.Family
