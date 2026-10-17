import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.Helpers
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/helpers.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";

/** Dispose `old` and return `next` — for h = disposing(h, op(h)) chains. */
export function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.Helpers
