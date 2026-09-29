import { basename } from "node:path";

/** The dtypes `convert --dtype` accepts (mlx_lm.convert's choices); the quantize package validates the same set. */
export const CONVERT_DTYPES: readonly string[] = ["float16", "bfloat16", "float32"];

/** A model's short name for derived output directories: the repo name of an
 * `org/name` id or a hub snapshot path, else the directory's basename. */
export function modelShortName(model: string): string {
  const snapshot = /models--[^/]+?--([^/]+)\/snapshots\//.exec(model);
  const name = snapshot ? snapshot[1]! : basename(model.replace(/\/+$/, ""));
  return name.replace(/[^\w.-]/g, "") || "model";
}

/** The default output directory name for quantizing `source` (a repo id or a
 * path), shared by `convert` and the web job: `<name>-<bits>bit`,
 * `<name>-mixed-<bpw>bpw` or `<name>-trellis-<bits>bit` (`-trellis-mixed` with a
 * per-tensor allocation), plus `-rot<seed>` when the weights are rotated. */
export function quantizedModelName(source: string,
  options: { bits: number; targetBpw?: number; rotationSeed?: number; trellis?: { bits: number; mixed: boolean } }): string {
  const precision = options.trellis ? `trellis-${options.trellis.mixed ? "mixed" : `${options.trellis.bits}bit`}`
    : options.targetBpw !== undefined ? `mixed-${options.targetBpw}bpw` : `${options.bits}bit`;
  return `${modelShortName(source)}-${precision}${options.rotationSeed !== undefined ? `-rot${options.rotationSeed}` : ""}`;
}

/** The default output directory name for a non-quantizing conversion:
 * `<name>-dense` (dequantized) and/or `-<dtype>`, else `-converted`. */
export function convertedModelName(source: string, options: { dtype?: string; dequantize?: boolean }): string {
  const parts = [options.dequantize ? "dense" : undefined, options.dtype].filter(Boolean);
  return `${modelShortName(source)}-${parts.join("-") || "converted"}`;
}
