// What one run of a text-to-image pipeline holds at once, under the stage
// residency the image model host applies (image-model-host.ts): when the
// stages' weights together exceed the stage budget, every run releases each
// stage after its output, so a run holds the largest one; otherwise the stages
// stay open and a run holds all of them. The isolated parent, which loads no
// native module, charges an image worker by the same rule and budget from the
// snapshot's files. Nothing here loads a model.
import { readdirSync, statSync } from "node:fs";
import { totalmem } from "node:os";
import { join } from "node:path";

/** The share of physical memory a pipeline's stages may hold together before each run releases them one by one. */
export const DEFAULT_STAGE_BUDGET_FRACTION = 0.5;

/** The stage budget a host applies when none is given: `DEFAULT_STAGE_BUDGET_FRACTION` of physical memory. */
export function defaultStageBudgetBytes(): number {
  return Math.floor(totalmem() * DEFAULT_STAGE_BUDGET_FRACTION);
}

/** The residency of stages holding `stageBytes` under `budgetBytes`: whether each run releases them one by one (they
 * together exceed the budget), and the bytes one run holds at once (the largest stage when released, else all of them). */
export function stageResidency(stageBytes: readonly number[], budgetBytes: number): { readonly releaseStages: boolean; readonly bytes: number } {
  const total = stageBytes.reduce((sum, bytes) => sum + bytes, 0);
  const releaseStages = total > budgetBytes;
  return { releaseStages, bytes: releaseStages ? Math.max(0, ...stageBytes) : total };
}

/** The weight bytes of each component of a pipeline snapshot that holds weights: the sizes of the `*.safetensors` files in
 * each component directory its `model_index.json` declares (underscore keys are metadata; `[null, null]` declares an
 * absent component). Reads the index, directory listings and file sizes only; rejects when the index cannot be read. */
export async function pipelineComponentBytes(directory: string): Promise<Record<string, number>> {
  const index = await Bun.file(join(directory, "model_index.json")).json() as Record<string, unknown>;
  const components: Record<string, number> = {};
  for (const [name, entry] of Object.entries(index)) {
    if (name.startsWith("_") || !Array.isArray(entry) || (entry[0] === null && entry[1] === null)) continue;
    let files: string[];
    try { files = readdirSync(join(directory, name)); } catch { continue; }
    const bytes = files.filter(file => file.endsWith(".safetensors")).reduce((sum, file) => sum + statSync(join(directory, name, file)).size, 0);
    if (bytes > 0) components[name] = bytes;
  }
  return components;
}
