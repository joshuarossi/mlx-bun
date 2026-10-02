import { existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

export const MLX_CORE_VERSION = "0.32.2";
export const NATIVE_FILES = [
  "libmlxc.dylib",
  "libmlx.dylib",
  "libjaccl.dylib",
  "mlx.metallib",
] as const;
export const NATIVE_DIR = fileURLToPath(new URL("../dist/native/", import.meta.url));

export function resolveLibmlxc(): string {
  const override = process.env.MLX_BUN_LIBMLXC;
  if (override) return override;
  if (import.meta.filename.startsWith("/$bunfs/")) {
    const sibling = join(dirname(process.execPath), "libmlxc.dylib");
    if (existsSync(sibling)) return sibling;
  }
  const path = fileURLToPath(new URL("../dist/native/libmlxc.dylib", import.meta.url));
  if (!existsSync(path)) {
    throw new Error(
      "@mlx-bun/mlx native runtime is missing. For a source checkout, run " +
      "bun run --cwd packages/mlx stage:native /path/to/native/lib. " +
      "Published packages must include dist/native; standalone apps must keep native files beside the executable.",
    );
  }
  return path;
}
