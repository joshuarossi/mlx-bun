import { join } from "node:path";

export const NATIVE_DIR = join(import.meta.dir, "..", "dist", "native");
export const NATIVE_FILES = ["libmlx_bun_expert_io.dylib"] as const;
export const EXPERT_IO_LIBRARY = join(NATIVE_DIR, NATIVE_FILES[0]);
