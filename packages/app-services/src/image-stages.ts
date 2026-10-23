// What one run of a text-to-image pipeline holds at once, under the stage
// residency the image model host applies (image-model-host.ts): a run that
// releases each stage after its output holds the largest stage; otherwise the
// stages stay open and a run holds all of them. Whether to release them is a
// stage rule the composer gives the host: the budget rule (release when the
// stages together exceed a byte budget) where the host's own admission counts
// the same stage bytes, or a decision made elsewhere. The isolated parent,
// which loads no native module, makes that decision from the snapshot's files,
// charges the worker by it and sends it to the worker. Nothing here loads a model.
import { readdirSync, statSync } from "node:fs";
import { totalmem } from "node:os";
import { join } from "node:path";

/** The share of physical memory a pipeline's stages may hold together before each run releases them one by one. */
export const DEFAULT_STAGE_BUDGET_FRACTION = 0.5;

/** The stage budget a host applies when none is given: `DEFAULT_STAGE_BUDGET_FRACTION` of physical memory. */
export function defaultStageBudgetBytes(): number {
  return Math.floor(totalmem() * DEFAULT_STAGE_BUDGET_FRACTION);
}

/** Whether each run releases its stages one by one, and the bytes one run holds at once. */
export interface StageResidency { readonly releaseStages: boolean; readonly bytes: number }
/** How a host decides a pipeline's stage residency from its stages' weight bytes. */
export type StageRule = (stageBytes: readonly number[]) => StageResidency;

/** What one run holds under a decision: the largest stage when the stages are released one by one, else all of them. */
function held(stageBytes: readonly number[], releaseStages: boolean): StageResidency {
  return { releaseStages, bytes: releaseStages ? Math.max(0, ...stageBytes) : stageBytes.reduce((sum, bytes) => sum + bytes, 0) };
}

/** The residency of stages holding `stageBytes` under `budgetBytes`: released one by one when they together exceed it. */
export function stageResidency(stageBytes: readonly number[], budgetBytes: number): StageResidency {
  return held(stageBytes, stageBytes.reduce((sum, bytes) => sum + bytes, 0) > budgetBytes);
}

/** The budget rule: `stageResidency` under `budgetBytes`. */
export function stageBudgetRule(budgetBytes: number): StageRule {
  return stageBytes => stageResidency(stageBytes, budgetBytes);
}

/** A decision made elsewhere, applied as made: the host only reports what its stages hold under it. */
export function fixedStageRule(releaseStages: boolean): StageRule {
  return stageBytes => held(stageBytes, releaseStages);
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
