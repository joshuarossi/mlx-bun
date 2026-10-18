import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Speculative.DeepspecArtifact
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/speculative/deepspec-artifact.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// How DeepSeek's released DSpark drafter (DeepSpec) declares itself in its
// config.json. No MLX: the draft registry and quantization read it to recognize
// the checkpoint before loading anything.

/** `architectures[0]` of a DeepSpec checkpoint. */
const DEEPSPEC_ARCHITECTURE = "Gemma4DSparkModel";

export function isDeepspecArchitecture(architectures: unknown): boolean {
  return Array.isArray(architectures) && architectures[0] === DEEPSPEC_ARCHITECTURE;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Speculative.DeepspecArtifact
