import host.ts.Source
namespace Host.Ts.Sources.Inference.Runtime.Integers
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/runtime/integers.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"/** `value` when it is a positive safe integer; otherwise a RangeError naming `label`. */
export function positiveInteger(value: number, label: string): number {
  if (!Number.isSafeInteger(value) || value <= 0)
    throw new RangeError(`${label} must be a positive safe integer`);
  return value;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Runtime.Integers
