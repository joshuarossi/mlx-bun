import { modelShortName } from "../storage/paths";

/** The default output directory name for quantizing `source` (a repo id or a
 * path), shared by `convert` and the web job: `<name>-<bits>bit` or
 * `<name>-mixed-<bpw>bpw`, plus `-rot<seed>` when the weights are rotated. */
export function quantizedModelName(source: string, options: { bits: number; targetBpw?: number; rotationSeed?: number }): string {
  const precision = options.targetBpw !== undefined ? `mixed-${options.targetBpw}bpw` : `${options.bits}bit`;
  return `${modelShortName(source)}-${precision}${options.rotationSeed !== undefined ? `-rot${options.rotationSeed}` : ""}`;
}
