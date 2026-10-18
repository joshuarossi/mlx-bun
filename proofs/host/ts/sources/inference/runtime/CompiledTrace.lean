import host.ts.Source
namespace Host.Ts.Sources.Inference.Runtime.CompiledTrace
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/runtime/compiled-trace.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"

// Compiled-decode trace mode (set by compiled-decode.ts around its trace,
// which runs synchronously on the serialized generation queue — same
// safety argument as LoraState). Inside a shapeless-compiled graph, mlx's
// Slice primitive cannot re-infer output shapes, so the two subrange
// slices on the decode path (per-layer-input split, MoE top-k) swap to
// DynamicSlice — identical values, shapeless-safe — ONLY while tracing.
// The uncompiled path keeps the exact oracle op sequence.
let compiledTrace = false;
export function setCompiledTrace(v: boolean): void {
  compiledTrace = v;
}
export function isCompiledTrace(): boolean {
  return compiledTrace;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Runtime.CompiledTrace
