import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.RowTable
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/row-table.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"export { rowOperationFor, rowTableWithDefault } from "../runtime/row-operations";
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.RowTable
