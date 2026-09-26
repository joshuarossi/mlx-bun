import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import { afterEach, describe, expect, it } from "bun:test";
import { createMemorySurface } from "../../src/memory/surface";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "../../src/memory/tools";
import { searchArticles } from "../../src/memory/vault";

// Main built the shared pi surface from a process-global memory switch
// (`buildPiAgentSurface({ memory })`); here composition binds one vault root and
// the surface is absent when that root holds no vault.

const hasAny = (haystack: readonly string[], needles: readonly string[]) => needles.some((n) => haystack.includes(n));
const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
function temporary(): string { const root = mkdtempSync(join(tmpdir(), "mlx-bun-memory-surface-")); roots.push(root); return root; }

describe("pi shared memory surface", () => {
  it("omits memory skill and memory/reference tools when memory is disabled", async () => {
    const root = temporary();
    const surface = await createMemorySurface(join(root, "no-vault"), join(root, "skills"));
    expect(surface).toBeUndefined();
    const tools = surface?.toolNames ?? [];
    expect(hasAny(tools, MEMORY_TOOL_NAMES)).toBe(false);
    expect(hasAny(tools, REFERENCE_TOOL_NAMES)).toBe(false);
    expect((surface?.customTools ?? []).map((t) => t.name).some((n) => n.startsWith("memory_") || n.startsWith("reference_"))).toBe(false);
    expect((surface?.skillPaths ?? []).map((p) => basename(p))).not.toContain("web-research");
    expect((surface?.skillPaths ?? []).map((p) => basename(p))).not.toContain("memory");
    expect(surface?.hint ?? "").toBe("");
  });

  it("includes memory and reference tools only when memory is enabled", async () => {
    const root = temporary();
    mkdirSync(join(root, "articles"));
    const surface = await createMemorySurface(root, join(root, "skills"));
    expect(surface).toBeDefined();
    for (const tool of MEMORY_TOOL_NAMES) expect(surface!.toolNames).toContain(tool);
    for (const tool of REFERENCE_TOOL_NAMES) expect(surface!.toolNames).toContain(tool);
    expect(surface!.customTools.map((t) => t.name)).toEqual(expect.arrayContaining([...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES]));
    expect(surface!.skillPaths.map((p) => basename(p))).toContain("memory");
  });

  it("keeps personal memory separate from mlx-bun reference lookup", async () => {
    const enabled = temporary();
    mkdirSync(join(enabled, "articles"));
    const surface = await createMemorySurface(enabled, join(enabled, "skills"));
    expect(surface!.toolNames).toContain("memory_search");
    expect(surface!.toolNames).toContain("reference_search");
    expect(surface!.toolNames).not.toContain("memory_reference_search");

    const root = temporary();
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
