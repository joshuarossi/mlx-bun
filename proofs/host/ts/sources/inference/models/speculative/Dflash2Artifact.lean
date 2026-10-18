import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Speculative.Dflash2Artifact
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/speculative/dflash2-artifact.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// How a DFlash 2 drafter (incoai/Qwen3.8-27B-DFlash2) declares itself in its
// config.json. No MLX: the draft registry reads it before loading anything.

/** `architectures[0]` of a DFlash 2 checkpoint. */
const DFLASH2_ARCHITECTURE = "DFlash2DraftModel";

export function isDflash2Architecture(architectures: unknown): boolean {
  return Array.isArray(architectures) && architectures[0] === DFLASH2_ARCHITECTURE;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Speculative.Dflash2Artifact
