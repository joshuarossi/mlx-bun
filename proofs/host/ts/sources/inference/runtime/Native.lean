import host.ts.Source
namespace Host.Ts.Sources.Inference.Runtime.Native
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/runtime/native.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { existsSync } from "node:fs";
import { dirname, join } from "node:path";

export const NATIVE_DIR = join(import.meta.dir, "..", "..", "dist", "native");
export const NATIVE_FILES = ["libmlx_bun_expert_io.dylib", "mlx-bun-frame-extract", "libmlx_bun_ane.dylib"] as const;
export function resolveInferenceNative(name: typeof NATIVE_FILES[number], override?: string): string {
  if (override) return override;
  if (import.meta.filename.startsWith("/$bunfs/")) {
    const sibling = join(dirname(process.execPath), name);
    if (existsSync(sibling)) return sibling;
  }
  return join(NATIVE_DIR, name);
}
export const EXPERT_IO_LIBRARY = resolveInferenceNative(NATIVE_FILES[0], process.env.MLX_BUN_EXPERT_IO_DYLIB);
export const FRAME_EXTRACT_BINARY = resolveInferenceNative(NATIVE_FILES[1], process.env.MLX_BUN_FRAME_EXTRACT);
export const ANE_LIBRARY = resolveInferenceNative(NATIVE_FILES[2], process.env.MLX_BUN_ANE_DYLIB);
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Runtime.Native
