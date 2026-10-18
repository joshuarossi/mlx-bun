import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Glm52.Family
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/glm52/family.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { renderGlm52Chat } from "../../input/chat-template";
import { L3, configuredMoe, defineFamily } from "../family";

/** GLM-5.2 Colibri architecture. Its dedicated MLA/DSA/shared-MoE graph is
 * intentionally distinct from the universal dense `glm4` descriptor. */
export const GLM52_FAMILY = defineFamily({
  graph: "glm5.2",
  accepts: config => config.modelType === "glm_moe_dsa",
  hasModelType: modelType => modelType === "glm_moe_dsa",
  tier: "targeted",
  label: "glm_moe_dsa",
  loader: "colibri",
  loop: "autoregressive",
  fidelity: L3,
  specialization: "dedicated",
  profileId: "glm5.2-colibri",
  capabilities: ["glm5.2-graph", "streamed-experts"],
  moe: configuredMoe,
  chatTemplateFallback: { render: renderGlm52Chat, thinkingFormat: "think-tag" },
});
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Glm52.Family
