// How a DFlash 2 drafter (incoai/Qwen3.8-27B-DFlash2) declares itself in its
// config.json. No MLX: the draft registry reads it before loading anything.

/** `architectures[0]` of a DFlash 2 checkpoint. */
const DFLASH2_ARCHITECTURE = "DFlash2DraftModel";

export function isDflash2Architecture(architectures: unknown): boolean {
  return Array.isArray(architectures) && architectures[0] === DFLASH2_ARCHITECTURE;
}
