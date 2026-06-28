import { cpSync, mkdtempSync, rmSync, statSync, utimesSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterAll, beforeEach, describe, expect, it } from "bun:test";

import { getEmbedCounter, resetEmbedCounter } from "../src/embed";
import {
  articlesInCategory,
  buildMemoryIndex,
  neighbors,
  resetMemoryIndexCache,
  resolveName,
  serializeMemoryIndex,
} from "../src/memory/query";

const FIXTURE_ROOT = join(import.meta.dir, "fixtures", "wiki");

const temps: string[] = [];
function tempVault(): string {
  const dir = mkdtempSync(join(tmpdir(), "mlxbun-query-"));
  temps.push(dir);
  cpSync(FIXTURE_ROOT, dir, { recursive: true });
  return dir;
}

afterAll(() => {
  for (const d of temps) rmSync(d, { recursive: true, force: true });
});

beforeEach(() => {
  // Each test starts from a cold parse cache so warm/cold builds are comparable.
  resetMemoryIndexCache();
});

// ---- find: category membership ---------------------------------------

describe("articlesInCategory", () => {
  it("returns exactly the declared lens fixtures (no substring false positives)", () => {
    resetEmbedCounter();
    const index = buildMemoryIndex(FIXTURE_ROOT);
    expect(articlesInCategory(index, "Lenses")).toEqual(["Lumix_75-300", "Sigma_100-400", "Sigma_150-600"]);
    // Toyota_Production_System mentions "lens" in prose but declares no Category:Lenses.
    expect(articlesInCategory(index, "Lenses")).not.toContain("Toyota_Production_System");
    expect(articlesInCategory(index, "Materials")).toEqual(["PETG"]);
    expect(articlesInCategory(index, "Lens Mounts")).toEqual(["L-Mount"]);
    expect(articlesInCategory(index, "Nonexistent")).toEqual([]);
    expect(getEmbedCounter()).toBe(0);
  });
});

// ---- find: name / alias resolution -----------------------------------

describe("resolveName", () => {
  it("resolves aliases and article-prefixed names to the canonical stem", () => {
    resetEmbedCounter();
    const index = buildMemoryIndex(FIXTURE_ROOT);
    expect(resolveName(index, "S5 IIX")).toBe("Panasonic_Lumix_S5IIX");
    expect(resolveName(index, "the Lumix S5IIX")).toBe("Panasonic_Lumix_S5IIX");
    expect(resolveName(index, "LUMIX S5IIX")).toBe("Panasonic_Lumix_S5IIX");
    expect(resolveName(index, "Panasonic Lumix S5IIX")).toBe("Panasonic_Lumix_S5IIX");
    expect(resolveName(index, "PETG")).toBe("PETG");
    expect(resolveName(index, "L mount")).toBe("L-Mount");
    expect(resolveName(index, "nonexistent thing")).toBeNull();
    expect(getEmbedCounter()).toBe(0);
  });
});

// ---- follow: link graph ----------------------------------------------

describe("neighbors", () => {
  it("includes the infobox mount:[[L-Mount]] edge and its backlink", () => {
    resetEmbedCounter();
    const index = buildMemoryIndex(FIXTURE_ROOT);

    const cam = neighbors(index, "Panasonic_Lumix_S5IIX");
    expect(cam.outbound).toContain("L-Mount"); // the navigation hop the read path rides

    // L-Mount is pointed at by every native lens + the camera (inbound backlinks).
    const mount = neighbors(index, "L-Mount");
    expect(mount.inbound).toEqual(
      expect.arrayContaining(["Panasonic_Lumix_S5IIX", "Sigma_150-600", "Lumix_75-300", "Sigma_100-400"]),
    );
    expect(mount.outbound).toContain("Lens_Mount_Adaptation");
    expect(getEmbedCounter()).toBe(0);
  });
});

// ---- the index: deterministic + incremental --------------------------

describe("buildMemoryIndex", () => {
  it("a second build is byte-identical and re-parses nothing (warm cache)", () => {
    resetEmbedCounter();
    const root = tempVault();

    const first = buildMemoryIndex(root);
    // First build over a cold cache parses every article.
    expect(first.reused).toEqual([]);
    expect(first.parsed.length).toBeGreaterThan(0);

    const second = buildMemoryIndex(root);
    expect(second.parsed).toEqual([]); // nothing changed → nothing re-parsed
    expect(serializeMemoryIndex(second)).toBe(serializeMemoryIndex(first));
    expect(getEmbedCounter()).toBe(0);
  });

  it("touching one file re-indexes ONLY that file", () => {
    resetEmbedCounter();
    const root = tempVault();
    buildMemoryIndex(root); // warm the cache

    const target = join(root, "articles", "PETG.md");
    const future = statSync(target).mtimeMs / 1000 + 100;
    utimesSync(target, future, future);

    const after = buildMemoryIndex(root);
    expect(after.parsed).toEqual(["PETG"]); // only the touched file
    expect(after.reused).not.toContain("PETG");
    expect(after.reused.length).toBeGreaterThan(0);
    expect(getEmbedCounter()).toBe(0);
  });

  it("a cold rebuild yields maps byte-identical to the warm one", () => {
    const root = tempVault();
    const warm = buildMemoryIndex(root);
    resetMemoryIndexCache();
    const cold = buildMemoryIndex(root);
    expect(serializeMemoryIndex(cold)).toBe(serializeMemoryIndex(warm));
  });
});
