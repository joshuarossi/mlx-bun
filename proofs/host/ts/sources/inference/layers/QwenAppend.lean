import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.QwenAppend
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/qwen-append.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// MLX 0.32.2, mlx/backend/metal/scaled_dot_product_attention.cpp (MIT):
// https://github.com/ml-explore/mlx/blob/v0.32.2/mlx/backend/metal/scaled_dot_product_attention.cpp
// For the qualified Qwen GQA-6/D256 graph on applegpu_g16s, one-pass/vector
// selection and two-pass block counts change after these inclusive KV lengths.
// A committed span must stay within one arithmetic regime to match M=1.
const ATTENTION_BOUNDARIES = [1023, 1024, 8192, 32768, 65536];

export function qwenAppendChunkSize(cacheTokens: number): number {
  for (const end of ATTENTION_BOUNDARIES)
    if (cacheTokens < end) return Math.min(4, end - cacheTokens);
  return 4;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.QwenAppend
