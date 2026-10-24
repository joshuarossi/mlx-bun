import { expect, test } from "bun:test";
import { totalmem } from "node:os";
import { DEFAULT_STAGE_BUDGET_FRACTION, defaultStageBudgetBytes, stageBudgetRule, stageResidency } from "../src";

test("the standalone image host keeps stages that fit and releases them one at a time above its budget", () => {
  const stages = [300, 500, 100];
  expect(stageResidency(stages, 1_000)).toEqual({ releaseStages: false, bytes: 900 });
  expect(stageResidency(stages, 900)).toEqual({ releaseStages: false, bytes: 900 });
  expect(stageResidency(stages, 899)).toEqual({ releaseStages: true, bytes: 500 });
  expect(stageResidency([], 1)).toEqual({ releaseStages: false, bytes: 0 });
  expect(stageBudgetRule(899)(stages)).toEqual({ releaseStages: true, bytes: 500 });
  expect(defaultStageBudgetBytes()).toBe(Math.floor(totalmem() * DEFAULT_STAGE_BUDGET_FRACTION));
});
