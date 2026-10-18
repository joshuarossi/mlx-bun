import host.ts.Source
namespace Host.Ts.Sources.Inference.Generation.Bindings.Autoregressive
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/generation/bindings/autoregressive.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"export function assertMlxAutoregressiveBinding(binding: MlxAutoregressiveBinding): void {
  const descriptor = binding.descriptor;
  if (descriptor.backend !== "mlx" || descriptor.graphAbi !== "mlx-hidden-bsh-v1" ||
      descriptor.stateAbi !== "legacy-cache-array-v1")
    throw new Error(`AR binding ${descriptor.id} has an incompatible backend, graph, or state ABI`);
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Generation.Bindings.Autoregressive
