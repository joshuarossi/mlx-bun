import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.DiffusionGemma.Family
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/diffusion-gemma/family.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { L2, configuredMoe, defineFamily } from "../family";
import { GEMMA_MEDIA_TOKENS, GEMMA_TRAINING_DEFAULTS } from "../gemma4/family";

/** DiffusionGemma (model_type `diffusion_gemma`): block/masked-diffusion canvas
 * model. Non-autoregressive, routed through the diffusion engine, not the AR loop. */
export const DIFFUSION_GEMMA_FAMILY = defineFamily({
  graph: "diffusion-gemma",
  accepts: config => config.modelType === "diffusion_gemma",
  hasModelType: modelType => modelType === "diffusion_gemma",
  tier: "targeted",
  label: "diffusion_gemma",
  loader: "safetensors",
  loop: "diffusion",
  fidelity: L2,
  specialization: "dedicated",
  profileId: "diffusion-gemma-dedicated",
  capabilities: ["diffusion-gemma-graph"],
  moe: configuredMoe,
  trainingDefaults: GEMMA_TRAINING_DEFAULTS,
  mediaTokens: GEMMA_MEDIA_TOKENS,
});
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.DiffusionGemma.Family
