import { afterEach, describe, expect, test } from "bun:test";
import {
  mkdtempSync,
  readFileSync,
  readdirSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  ExpertUsageLedger,
  planExpertAutoPins,
  selectExpertLfruCandidates,
} from "../src/expert-usage";

const roots: string[] = [];

function tempProfile(): { root: string; path: string } {
  const root = mkdtempSync(join(tmpdir(), "mlx-bun-expert-usage-"));
  roots.push(root);
  return { root, path: join(root, ".coli_usage") };
}

afterEach(() => {
  for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true });
});

describe("expert usage ledger", () => {
  test("loads Colibri rows, counts every pre-union route, and atomically rewrites", () => {
    const { root, path } = tempProfile();
    writeFileSync(path, "3 2 4\n4 1 9\n");
    const ledger = ExpertUsageLedger.open({
      path,
      layers: [3, 4],
      expertsPerLayer: 8,
    });

    ledger.recordRoutes(3, [
      { indices: [2, 2, 1] },
      { indices: [2] },
    ]);

    expect(ledger.entry(3, 2)).toEqual({ count: 7, heat: 3, lastAccess: 4 });
    expect(ledger.entry(3, 1)).toEqual({ count: 1, heat: 1, lastAccess: 3 });
    expect(ledger.snapshot()).toEqual({
      clock: 4,
      routeSelections: 4,
      totalCount: 17,
      nonzeroCounts: 3,
      dirty: true,
    });

    ledger.flush();
    expect(readFileSync(path, "utf8")).toBe("3 1 1\n3 2 7\n4 1 9\n");
    expect(readdirSync(root)).toEqual([".coli_usage"]);
    expect(ledger.snapshot().dirty).toBe(false);

    const reopened = ExpertUsageLedger.open({
      path,
      layers: [3, 4],
      expertsPerLayer: 8,
    });
    expect(reopened.entry(3, 2).count).toBe(7);
    expect(reopened.entry(3, 2).heat).toBe(0);
  });

  test("rejects a malformed route without partially updating the turn", () => {
    const { path } = tempProfile();
    const ledger = ExpertUsageLedger.open({
      path,
      layers: [3],
      expertsPerLayer: 4,
    });
    expect(() => ledger.recordRoutes(3, [
      { indices: [1, 2] },
      { indices: [3, 4] },
    ])).toThrow(/invalid expert 4/);
    expect(ledger.snapshot()).toMatchObject({ routeSelections: 0, dirty: false });
    expect(ledger.entry(3, 1).count).toBe(0);
  });

  test("treats a damaged profile as disposable derived state", () => {
    const { path } = tempProfile();
    writeFileSync(path, "3 1 5\nnot-a-row\n");
    const warnings: string[] = [];
    const ledger = ExpertUsageLedger.open({
      path,
      layers: [3],
      expertsPerLayer: 4,
      onWarning: (message) => warnings.push(message),
    });
    expect(warnings).toHaveLength(1);
    expect(ledger.entry(3, 1).count).toBe(0);
    ledger.recordRoutes(3, [{ indices: [2] }]);
    ledger.flush();
    expect(readFileSync(path, "utf8")).toBe("3 2 1\n");
  });

  test("plans deterministic cost-aware auto-pins within the resident budget", () => {
    const { path } = tempProfile();
    writeFileSync(path, [
      "3 2 80000",
      "4 1 80000",
      "3 1 40000",
      "4 0 1",
      "",
    ].join("\n"));
    const ledger = ExpertUsageLedger.open({
      path,
      layers: [3, 4],
      expertsPerLayer: 8,
    });
    const plan = planExpertAutoPins({
      ledger,
      residentTierBudgetBytes: 1_200_000_000,
      mandatoryResidentBytes: 200_000_000,
      slotBytes: (layer) => layer === 4 ? 400_000_000 : 200_000_000,
    });
    expect(plan).toMatchObject({
      historySelections: 200_001,
      confidence: 1,
      requestedBudgetBytes: 600_000_000,
      usableBudgetBytes: 600_000_000,
      plannedBytes: 600_000_000,
    });
    expect(plan.pins.map(({ layer, expertId }) => [layer, expertId]))
      .toEqual([[3, 2], [4, 1]]);
  });

  test("does not auto-pin low-confidence or sub-500 MB history", () => {
    const { path } = tempProfile();
    writeFileSync(path, "3 1 4999\n");
    const ledger = ExpertUsageLedger.open({
      path,
      layers: [3],
      expertsPerLayer: 4,
    });
    expect(planExpertAutoPins({
      ledger,
      residentTierBudgetBytes: 40_000_000_000,
      mandatoryResidentBytes: 1,
      slotBytes: () => 10,
    }).pins).toHaveLength(0);

    ledger.recordRoutes(3, [{ indices: [1] }]);
    const lowBudget = planExpertAutoPins({
      ledger,
      residentTierBudgetBytes: 10_000_000_000,
      mandatoryResidentBytes: 1,
      slotBytes: () => 10,
    });
    expect(lowBudget.historySelections).toBe(5_000);
    expect(lowBudget.requestedBudgetBytes).toBe(125_000_000);
    expect(lowBudget.pins).toHaveLength(0);
  });

  test("selects at most four live repins by gain with deterministic ties", () => {
    const candidates = [5, 3, 4, 2, 1].map((layer, index) => ({
      layer,
      coldSlot: 0,
      coldExpertId: 0,
      hotExpertId: index + 1,
      coldScore: 0,
      hotScore: index < 2 ? 2_048 : 1_792,
      gain: index < 2 ? 8 : 7,
    }));
    expect(selectExpertLfruCandidates(candidates).map((item) => item.layer))
      .toEqual([3, 5, 1, 2]);
  });
});
