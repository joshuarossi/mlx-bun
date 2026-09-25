import { NATIVE_FILES as MLX_FILES } from "../packages/mlx/src/native";
import { NATIVE_FILES as INFERENCE_FILES } from "../packages/inference/src/runtime/native";

/** Flat standalone bundle. Add app-owned native helpers here when they migrate;
 * signing discovers Mach-O files rather than maintaining another helper list. */
export const BUNDLE_FILES = ["mlx-bun", ...MLX_FILES, ...INFERENCE_FILES,
  "photon_rs_bg.wasm", "LICENSE", "THIRD_PARTY_NOTICES.md"] as const;
