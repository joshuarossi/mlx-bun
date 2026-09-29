import { NATIVE_FILES as MLX_FILES } from "../packages/mlx/src/native";
import { NATIVE_FILES as INFERENCE_FILES } from "../packages/inference/src/runtime/native";
import { MIC_CAPTURE_BINARY } from "../packages/module-transcription/src/mic-capture";

/** Flat standalone bundle. Add app-owned native helpers here when they migrate;
 * signing discovers Mach-O files rather than maintaining another helper list. */
export const BUNDLE_FILES = ["mlx-bun", ...MLX_FILES, ...INFERENCE_FILES, MIC_CAPTURE_BINARY,
  "photon_rs_bg.wasm", "LICENSE", "THIRD_PARTY_NOTICES.md"] as const;

/** The one archive command for bundles: flat members named explicitly, no
 * directory entries. Release preparation and the verifier CLI both run it. */
export function archiveCommand(archive: string, directory: string, files: readonly string[]): string[] {
  return ["tar", "-czf", archive, "-C", directory, ...files];
}
