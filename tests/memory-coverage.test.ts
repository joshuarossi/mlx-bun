import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterAll, describe, expect, it } from "bun:test";

import { coverageReport, type NotableEntity } from "../src/memory/coverage";
import { MemoryStore } from "../src/memory/db";
import { articlesDir } from "../src/memory/vault";
import { reindex } from "../src/memory/reindex";

// P9-T4 — migration coverage. A two-entity gold against a fixture vault that
// contains exactly one of them: the present one is COVERED (by alias), the
// absent one is REPORTED MISSING (the 0-lost ledger). No model, no embedder.

const PRESENT: NotableEntity = {
  name: "Panasonic Lumix S5IIX",
  kind: "thing",
  domain: "photography",
  aliases: ["S5IIX", "the Panasonic"],
  whyNotable: "schematic fixture — owned body",
};
const ABSENT: NotableEntity = {
  name: "Bambu A1 Mini",
  kind: "thing",
  domain: "3d-printing",
  aliases: ["Bambu A1", "the Bambu"],
  whyNotable: "schematic fixture — owned printer, no article",
};

const temps: string[] = [];
afterAll(() => {
  for (const d of temps) rmSync(d, { recursive: true, force: true });
});

/** A throwaway vault with one article for PRESENT (resolvable via its alias). */
function fixtureVault(opts: { stub?: boolean } = {}): string {
  const root = mkdtempSync(join(tmpdir(), "mlxbun-coverage-"));
  temps.push(root);
  const dir = articlesDir(root);
  rmSync(dir, { recursive: true, force: true });
  mkdirSync(dir, { recursive: true });
  const body = opts.stub
    ? "Short."
    : "**Panasonic Lumix S5IIX** is a full-frame body. ".repeat(20);
  writeFileSync(
    join(dir, "Panasonic_Lumix_S5IIX.md"),
    `# Panasonic Lumix S5IIX\n\n\`\`\`info\nkind: thing\naliases: S5IIX, the Panasonic\n\`\`\`\n\n${body}\n`,
  );
  return root;
}

function reportFor(root: string): ReturnType<typeof coverageReport> {
  const store = new MemoryStore(":memory:");
  reindex(store, root);
  return coverageReport(store, [PRESENT, ABSENT], root);
}

describe("memory coverage — migration parity", () => {
  it("counts a present gold entity as covered and an absent one as missing", () => {
    const report = reportFor(fixtureVault());
    expect(report.goldNotable).toBe(2);
    expect(report.coveredCount).toBe(1);
    expect(report.missingCount).toBe(1);
    expect(report.covered.map((r) => r.name)).toEqual(["Panasonic Lumix S5IIX"]);
    expect(report.missing.map((r) => r.name)).toEqual(["Bambu A1 Mini"]);
  });

  it("resolves the present entity by alias, not just the canonical name", () => {
    const report = reportFor(fixtureVault());
    const row = report.covered.find((r) => r.name === "Panasonic Lumix S5IIX")!;
    expect(row.stem).toBe("Panasonic_Lumix_S5IIX");
    expect(row.matchedVia).toBe("Panasonic Lumix S5IIX");
  });

  it("flags a present-but-thin article as a stub (still covered)", () => {
    const report = reportFor(fixtureVault({ stub: true }));
    expect(report.coveredCount).toBe(1);
    expect(report.stubCount).toBe(1);
    expect(report.covered[0]!.stub).toBe(true);
  });

  it("reports zero coverage on an empty vault — every gold thing missing", () => {
    const root = mkdtempSync(join(tmpdir(), "mlxbun-coverage-empty-"));
    temps.push(root);
    mkdirSync(articlesDir(root), { recursive: true });
    const store = new MemoryStore(":memory:");
    reindex(store, root);
    const report = coverageReport(store, [PRESENT, ABSENT], root);
    expect(report.coveredCount).toBe(0);
    expect(report.missingCount).toBe(2);
  });
});
