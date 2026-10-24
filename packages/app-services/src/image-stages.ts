// The standalone image host decides whether each run releases its stages
// from the pipeline's declared stage bytes. Nothing here loads a model.
import { totalmem } from "node:os";

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
