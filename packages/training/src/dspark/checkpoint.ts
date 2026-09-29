// A trained drafter is a directory: `model.safetensors` + `dspark.json` (what
// `DflashDrafter.save` writes and the DSpark provider loads) + a minimal
// `config.json`. The config is what lets `mlx-bun serve --draft-model <dir>`
// resolve the directory like any model (the app scans a directory only when it
// has one); its `model_type` contains `assistant`, the declaration
// (`isDrafterModelType`) that this is a companion artifact, never a
// model selectable on its own. Detection still reads `dspark.json` first.

import type { DflashDrafter } from "@mlx-bun/inference/generation/speculative/loader";
import { writeFileSync } from "node:fs";
import { join } from "node:path";

export const DRAFTER_MODEL_TYPE = "dspark_assistant";

export function saveDrafter(drafter: DflashDrafter, dir: string): void {
  drafter.save(dir);
  writeFileSync(join(dir, "config.json"), JSON.stringify({
    model_type: DRAFTER_MODEL_TYPE,
    architectures: ["DsparkDrafter"],
    hidden_size: drafter.cfg.dDraft,
    vocab_size: drafter.dims.vocabSize,
    target_hidden_size: drafter.dims.hiddenSize,
    target_id: drafter.targetId,
  }, null, 2));
}
