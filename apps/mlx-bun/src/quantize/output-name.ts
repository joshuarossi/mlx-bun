import { modelShortName } from "../storage/paths";

/** The dtypes `convert --dtype` accepts (mlx_lm.convert's choices); the quantize package validates the same set. */
export const CONVERT_DTYPES: readonly string[] = ["float16", "bfloat16", "float32"];

/** The default output directory name for quantizing `source` (a repo id or a
 * path), shared by `convert` and the web job: `<name>-<bits>bit` or
 * `<name>-mixed-<bpw>bpw`, plus `-rot<seed>` when the weights are rotated. */
export function quantizedModelName(source: string, options: { bits: number; targetBpw?: number; rotationSeed?: number }): string {
  const precision = options.targetBpw !== undefined ? `mixed-${options.targetBpw}bpw` : `${options.bits}bit`;
  return `${modelShortName(source)}-${precision}${options.rotationSeed !== undefined ? `-rot${options.rotationSeed}` : ""}`;
}

/** The default output directory name for a non-quantizing conversion:
 * `<name>-dense` (dequantized) and/or `-<dtype>`, else `-converted`. */
export function convertedModelName(source: string, options: { dtype?: string; dequantize?: boolean }): string {
  const parts = [options.dequantize ? "dense" : undefined, options.dtype].filter(Boolean);
  return `${modelShortName(source)}-${parts.join("-") || "converted"}`;
}
