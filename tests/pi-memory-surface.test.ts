import { mkdirSync, mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import { describe, expect, it } from "bun:test";
import { buildPiAgentSurface } from "../src/pi-session";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "../src/memory/tools";
import { searchArticles } from "../src/memory/vault";

const hasAny = (haystack: readonly string[], needles: readonly string[]) => needles.some((n) => haystack.includes(n));

describe("pi shared memory surface", () => {
  it("omits memory skill and memory/reference tools when memory is disabled", async () => {
    const surface = await buildPiAgentSurface({ memory: "off" });
    expect(surface.memoryEnabled).toBe(false);
    expect(hasAny(surface.tools, MEMORY_TOOL_NAMES)).toBe(false);
    expect(hasAny(surface.tools, REFERENCE_TOOL_NAMES)).toBe(false);
    expect(surface.customTools.map((t) => t.name).some((n) => n.startsWith("memory_") || n.startsWith("reference_"))).toBe(false);
    expect(surface.skillPaths.map((p) => basename(p))).not.toContain("web-research");
    expect(surface.skillPaths.map((p) => basename(p))).not.toContain("memory");
    expect(surface.memoryHint).toBe("");
  });

  it("includes memory and reference tools only when memory is enabled", async () => {
    const surface = await buildPiAgentSurface({ memory: "on" });
    expect(surface.memoryEnabled).toBe(true);
    for (const tool of MEMORY_TOOL_NAMES) expect(surface.tools).toContain(tool);
    for (const tool of REFERENCE_TOOL_NAMES) expect(surface.tools).toContain(tool);
    expect(surface.customTools.map((t) => t.name)).toEqual(expect.arrayContaining([...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES]));
    expect(surface.skillPaths.map((p) => basename(p))).toContain("memory");
  });

  it("keeps personal memory separate from mlx-bun reference lookup", async () => {
    const surface = await buildPiAgentSurface({ memory: "on" });
    expect(surface.tools).toContain("memory_search");
    expect(surface.tools).toContain("reference_search");
    expect(surface.tools).not.toContain("memory_reference_search");

    const root = mkdtempSync(join(tmpdir(), "mlx-bun-memory-scope-"));
    mkdirSync(join(root, "articles"));
    mkdirSync(join(root, "Reference"));
    writeFileSync(join(root, "articles", "Lucien.md"), "personal Lucien project context");
    writeFileSync(join(root, "Reference", "mlx-bun_Lucien.md"), "reference Lucien docs");

    const personal = await searchArticles(root, "Lucien", { scope: "articles" });
    expect(personal.summaries.map((s) => s.article)).toEqual(["Lucien"]);

    const refs = await searchArticles(root, "Lucien", { scope: "reference" });
    expect(refs.summaries.map((s) => s.article)).toEqual(["Reference/mlx-bun_Lucien"]);
  });
});
