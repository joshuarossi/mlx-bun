import { existsSync } from "node:fs";
import { dirname, join } from "node:path";

export const NATIVE_DIR = join(import.meta.dir, "..", "..", "dist", "native");
export const NATIVE_FILES = ["libmlx_bun_expert_io.dylib", "mlx-bun-frame-extract"] as const;
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
