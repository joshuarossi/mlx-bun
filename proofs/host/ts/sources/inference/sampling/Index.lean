import host.ts.Source
namespace Host.Ts.Sources.Inference.Sampling.Index
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/sampling/index.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"export * from "./types";
export * from "./filters";
export * from "./hlg";
export * from "./processors";
export * from "./step";
export * from "./extras";
export * from "./sampler";
export * from "./grammar";
export * from "./curve";
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Sampling.Index
