import { describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import probesFixture from "../fixtures/colibri-glm52/atlas-probes.json";
import {
  buildGlm52Atlas,
  buildGlm52AtlasRun,
  glm52AtlasRunId,
  glm52AtlasWebExperts,
  validateGlm52Atlas,
  validateGlm52AtlasProbeSet,
  type Glm52AtlasProbeSet,
  type Glm52AtlasRun,
} from "../src/model/glm52-atlas";
import type { Glm52RouteTraceRecord } from "../src/model/glm52-coupling";
import { renderGlm52AtlasHtml } from "../scripts/lib/glm52-atlas-html";

function probes(categories: readonly string[]): Glm52AtlasProbeSet {
  return validateGlm52AtlasProbeSet({
    schemaVersion: 1,
    provenance: { source: "test", sourceCommit: "abc", method: "synthetic" },
    categories: Object.fromEntries(categories.map((category) => [
      category,
      [`${category} zero`, `${category} one`, `${category} two`],
    ])),
  });
}

function run(
  category: string,
  promptIndex: number,
  rows: Readonly<Record<string, number>>,
): Glm52AtlasRun {
  const counts = new Map(Object.entries(rows));
  return {
    category,
    promptIndex,
    counts,
    totalSelections: [...counts.values()].reduce((sum, count) => sum + count, 0),
  };
}

function replicatedRuns(): {
  probes: Glm52AtlasProbeSet;
  runs: Glm52AtlasRun[];
} {
  const probeSet = probes(["alpha", "beta"]);
  const runs: Glm52AtlasRun[] = [];
  for (let index = 0; index < 3; index++) {
    runs.push(run("alpha", index, {
      "3:1": index === 0 ? 50 : 60,
      "3:9": 40,
      ...(index === 0 ? { "4:7": 10 } : {}),
    }));
    runs.push(run("beta", index, { "3:2": 600, "3:9": 400 }));
  }
  return { probes: probeSet, runs };
}

describe("GLM-5.2 Expert Atlas", () => {
  test("pins the controlled 10-by-3 probe matrix and provenance", () => {
    const fixture = validateGlm52AtlasProbeSet(probesFixture);
    expect(Object.keys(fixture.categories)).toHaveLength(10);
    expect(Object.values(fixture.categories).every((items) => items.length === 3))
      .toBe(true);
    expect(fixture.provenance.sourceCommit)
      .toBe("ecade075cfc2eae684097ea7de5570c3786ce199");
  });

  test("builds an isolated run from full pre-union route rows", () => {
    const segment = glm52AtlasRunId("alpha", 0);
    const records: Glm52RouteTraceRecord[] = [
      { segment, forward: 0, row: 0, layer: 3, indices: [2, 1] },
      { segment, forward: 0, row: 1, layer: 3, indices: [2, 4] },
      { segment, forward: 0, row: 0, layer: 4, indices: [7, 1] },
    ];
    const actual = buildGlm52AtlasRun("alpha", 0, records);
    expect(actual.totalSelections).toBe(6);
    expect(Object.fromEntries(actual.counts)).toEqual({
      "3:1": 1,
      "3:2": 2,
      "3:4": 1,
      "4:1": 1,
      "4:7": 1,
    });
  });

  test("normalizes category size and drops single-prompt flukes", () => {
    const fixture = replicatedRuns();
    const atlas = buildGlm52Atlas(fixture.probes, fixture.runs, {
      minCount: 1,
      minRuns: 2,
    });
    const alpha = atlas.experts.find((expert) =>
      expert.layer === 3 && expert.expert === 1)!;
    const beta = atlas.experts.find((expert) =>
      expert.layer === 3 && expert.expert === 2)!;
    const general = atlas.experts.find((expert) =>
      expert.layer === 3 && expert.expert === 9)!;
    expect(alpha.topTopic).toBe("alpha");
    expect(alpha.specialization).toBe(1);
    expect(beta.topTopic).toBe("beta");
    expect(beta.specialization).toBe(1);
    expect(general.affinity).toEqual({ alpha: 0.5, beta: 0.5 });
    expect(general.specialization).toBe(0);
    expect(atlas.experts.some((expert) =>
      expert.layer === 4 && expert.expert === 7)).toBe(false);
    expect(atlas.summary.droppedUnreplicated).toBe(1);
  });

  test("classifies every globally held-out prompt from unseen routing", () => {
    const fixture = replicatedRuns();
    const validation = validateGlm52Atlas(fixture.probes, fixture.runs, 1);
    expect(validation.protocol).toBe("global leave-one-prompt-out");
    expect(validation.hits).toBe(6);
    expect(validation.trials).toBe(6);
    expect(validation.accuracy).toBe(1);
    expect(validation.chance).toBe(0.5);
    expect(validation.trialsByPrompt.every((trial) =>
      trial.ownShare > trial.bestOtherShare)).toBe(true);
  });

  test("emits Colibri-compatible expert entries and a self-contained viewer", () => {
    const fixture = replicatedRuns();
    const analysis = buildGlm52Atlas(fixture.probes, fixture.runs, {
      minCount: 1,
      minRuns: 2,
    });
    const validation = validateGlm52Atlas(fixture.probes, fixture.runs, 1);
    const web = glm52AtlasWebExperts(analysis) as Record<string, any>;
    expect(web["3:1"]).toMatchObject({
      top: "alpha",
      label: "specialist: alpha",
      specialization: 1,
    });
    expect(web["3:9"].label).toBe("generalist");

    const html = renderGlm52AtlasHtml({
      title: "Test Atlas",
      analysis,
      validation,
      provenance: {
        model: "model</script>",
        probeSource: "fixture",
        probeSourceCommit: "abc",
        generatedAt: "2026-08-16T00:00:00.000Z",
      },
    });
    expect(html).toContain("<!doctype html>");
    expect(html).toContain('<canvas id="atlas"></canvas>');
    expect(html).toContain("position = measured topic affinity");
    expect(html).not.toContain("model</script>");
    expect(html).not.toContain("fetch(");
  });

  test("runs the analyzer end to end and writes all three artifacts", async () => {
    const fixture = replicatedRuns();
    const root = mkdtempSync(join(tmpdir(), "mlx-bun-atlas-"));
    const traces = join(root, "traces");
    const output = join(root, "analysis");
    const probePath = join(root, "probes.json");
    try {
      mkdirSync(traces);
      await Bun.write(probePath, JSON.stringify(fixture.probes));
      for (const item of fixture.runs) {
        const records: Glm52RouteTraceRecord[] = [];
        let row = 0;
        for (const [key, count] of item.counts) {
          const [layer, expert] = key.split(":").map(Number);
          for (let index = 0; index < count; index++) {
            records.push({
              segment: glm52AtlasRunId(item.category, item.promptIndex),
              forward: 0,
              row: row++,
              layer: layer!,
              indices: [expert!],
            });
          }
        }
        await Bun.write(
          join(traces, `${item.category}_${item.promptIndex}.jsonl`),
          `${records.map((record) => JSON.stringify(record)).join("\n")}\n`,
        );
      }
      const result = Bun.spawnSync([
        process.execPath,
        "scripts/analyze-colibri-glm52-g6-atlas.ts",
        "--traces", traces,
        "--output-dir", output,
        "--probes", probePath,
        "--min-count", "1",
        "--top-k", "1",
      ], { stdout: "pipe", stderr: "pipe" });
      expect(new TextDecoder().decode(result.stderr)).toBe("");
      expect(result.exitCode).toBe(0);
      const atlas = JSON.parse(readFileSync(join(output, "atlas.json"), "utf8"));
      const web = JSON.parse(readFileSync(join(output, "experts.json"), "utf8"));
      const html = readFileSync(join(output, "atlas.html"), "utf8");
      expect(atlas.validation).toMatchObject({ hits: 6, trials: 6, accuracy: 1 });
      expect(web.experts["3:1"].label).toBe("specialist: alpha");
      expect(html).toContain("held-out accuracy");
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  test("refuses incomplete probe matrices and cross-segment contamination", () => {
    expect(() => validateGlm52AtlasProbeSet({
      schemaVersion: 1,
      provenance: { source: "x", sourceCommit: "y", method: "z" },
      categories: { alpha: ["one", "two"] },
    })).toThrow(/at least two categories|at least three prompts/);
    expect(() => buildGlm52AtlasRun("alpha", 0, [{
      segment: "beta:0",
      forward: 0,
      row: 0,
      layer: 3,
      indices: [1],
    }])).toThrow(/contains segment beta:0/);
  });
});
