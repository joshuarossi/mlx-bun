import host.ts.Source
namespace Host.Ts.Sources.Inference.Kernels.Trellis.Launch
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/kernels/trellis/launch.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"/** Default Trellis matvec launch: four SIMD groups of 32 lanes per threadgroup,
 * one output row per SIMD group. Qualified codebook decode uses wider groups. */
export const TRELLIS_THREADS = 128;
export const TRELLIS_SG_PER_TG = 4;
/** Amortize the 16 KiB codebook over sixteen rows in the qualified M1 decode. */
export const TRELLIS_CODEBOOK_THREADS = 512;
export const TRELLIS_CODEBOOK_SG_PER_TG = 16;
/** The one-row gate/up codebook kernel: one threadgroup per M1 Max core, each table serving 32 rows at a time. */
export const TRELLIS_CODEBOOK_ROW_THREADS = 1024;
export const TRELLIS_CODEBOOK_ROW_SG_PER_TG = 32;
/** The one-row down codebook kernel: eight SIMD groups per threadgroup (each split's lanes own 16 positions). */
export const TRELLIS_CODEBOOK_DOWN_THREADS = 256;
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Kernels.Trellis.Launch
