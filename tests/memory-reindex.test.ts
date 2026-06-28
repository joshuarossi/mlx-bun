import { cpSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterAll, describe, expect, it } from "bun:test";

import { MemoryStore } from "../src/memory/db";
import { articlesInCategory, reindex, resolveName } from "../src/memory/reindex";

const FIXTURE_ROOT = join(import.meta.dir, "fixtures", "wiki");

// ---- snapshot helpers -------------------------------------------------

const TABLE_ORDER: Record<string, string> = {
  entities: "name, article_stem, kind, notable",
  entity_aliases: "alias, entity_name",
  categories: "name, definition, parent",
  article_categories: "article_stem, category, source",
  infobox_facts: "article_stem, key, value, kind, entity_link",
  links: "src_stem, dst_stem, via",
};

/** Deterministic JSON snapshot of every derived table (ordered by all columns). */
function snapshot(store: MemoryStore): string {
  const out: Record<string, unknown[]> = {};
  for (const [table, order] of Object.entries(TABLE_ORDER)) {
    out[table] = store.db.query(`SELECT * FROM ${table} ORDER BY ${order}`).all();
  }
  return JSON.stringify(out);
}

/** Map of article_stem → sorted category names. */
function categoriesByArticle(store: MemoryStore): Record<string, string[]> {
  const rows = store.db
    .query("SELECT article_stem, category FROM article_categories ORDER BY article_stem, category")
    .all() as { article_stem: string; category: string }[];
  const map: Record<string, string[]> = {};
  for (const r of rows) (map[r.article_stem] ??= []).push(r.category);
  return map;
}

function reindexed(root: string): MemoryStore {
  const store = new MemoryStore(":memory:");
  reindex(store, root);
  return store;
}

const temps: string[] = [];
function tempVault(): string {
  const dir = mkdtempSync(join(tmpdir(), "mlxbun-reindex-"));
  temps.push(dir);
  cpSync(FIXTURE_ROOT, dir, { recursive: true });
  return dir;
}

afterAll(() => {
  for (const d of temps) rmSync(d, { recursive: true, force: true });
});

// ---- tests ------------------------------------------------------------

describe("articlesInCategory", () => {
  it("returns exactly the articles that DECLARED [[Category:Lenses]] — zero false positives", () => {
    const store = reindexed(FIXTURE_ROOT);
    expect(articlesInCategory(store, "Lenses")).toEqual(["Lumix_75-300", "Sigma_100-400", "Sigma_150-600"]);
    // Toyota_Production_System mentions "lens" in prose but declares no Category:Lenses.
    expect(articlesInCategory(store, "Lenses")).not.toContain("Toyota_Production_System");
    expect(articlesInCategory(store, "Cameras")).toEqual(["Panasonic_Lumix_S5IIX"]);
    expect(articlesInCategory(store, "Manufacturing")).toEqual(["Toyota_Production_System"]);
    store.close();
  });

  it("a fresh reindex accumulates exactly the declared category names — none invented", () => {
    const store = reindexed(FIXTURE_ROOT);
    const cats = (store.db.query("SELECT name FROM categories ORDER BY name").all() as { name: string }[]).map(
      (r) => r.name,
    );
    expect(cats).toEqual(["Cameras", "Lens Mounts", "Lenses", "Manufacturing", "Materials"]);
    store.close();
  });
});

describe("determinism", () => {
  it("reindexing the same vault into two fresh DBs is byte-identical", () => {
    const a = reindexed(FIXTURE_ROOT);
    const b = reindexed(FIXTURE_ROOT);
    expect(snapshot(b)).toBe(snapshot(a));
    a.close();
    b.close();
  });
});

describe("category membership tracks the declaration, not infobox type", () => {
  it("mutating infobox type leaves article_categories unchanged but changes infobox_facts", () => {
    const root = tempVault();
    const file = join(root, "articles", "Sigma_150-600.md");

    const before = reindexed(root);
    const catsBefore = categoriesByArticle(before);
    const factsBefore = before.db
      .query("SELECT key, value FROM infobox_facts WHERE article_stem = 'Sigma_150-600' AND key = 'type'")
      .all();
    expect(catsBefore["Sigma_150-600"]).toEqual(["Lenses"]);
    before.close();

    // Change ONLY the infobox type on disk.
    writeFileSync(file, readFileSync(file, "utf8").replace("type: lens", "type: camera-body"));

    const after = reindexed(root);
    const catsAfter = categoriesByArticle(after);
    const factsAfter = after.db
      .query("SELECT key, value FROM infobox_facts WHERE article_stem = 'Sigma_150-600' AND key = 'type'")
      .all();

    // article_categories unchanged: no type→category derivation.
    expect(catsAfter).toEqual(catsBefore);
    // infobox_facts DID change: the type fact now reads camera-body.
    expect(factsAfter).not.toEqual(factsBefore);
    expect(factsAfter).toEqual([{ key: "type", value: "camera-body" }]);
    after.close();
  });

  it("adding/removing a [[Category:…]] declaration changes ONLY that article's rows", () => {
    const root = tempVault();
    const file = join(root, "articles", "Lumix_75-300.md");

    const base = reindexed(root);
    const baseCats = categoriesByArticle(base);
    base.close();

    // Add a category declaration to Lumix_75-300 only.
    writeFileSync(
      file,
      readFileSync(file, "utf8").replace(
        "categories: [[Category:Lenses]]",
        "categories: [[Category:Lenses]], [[Category:Telephoto]]",
      ),
    );
    const added = reindexed(root);
    const addedCats = categoriesByArticle(added);
    expect(addedCats["Lumix_75-300"]).toEqual(["Lenses", "Telephoto"]);
    for (const stem of Object.keys(baseCats)) {
      if (stem === "Lumix_75-300") continue;
      expect(addedCats[stem]).toEqual(baseCats[stem]); // every other article untouched
    }
    added.close();

    // Remove it again → back to the baseline exactly.
    writeFileSync(
      file,
      readFileSync(file, "utf8").replace(
        "categories: [[Category:Lenses]], [[Category:Telephoto]]",
        "categories: [[Category:Lenses]]",
      ),
    );
    const removed = reindexed(root);
    expect(categoriesByArticle(removed)).toEqual(baseCats);
    removed.close();
  });
});

describe("resolveName", () => {
  it("resolves aliases and article-prefixed names to the canonical stem", () => {
    const store = reindexed(FIXTURE_ROOT);
    expect(resolveName(store, "S5 IIX")).toBe("Panasonic_Lumix_S5IIX");
    expect(resolveName(store, "the Lumix S5IIX")).toBe("Panasonic_Lumix_S5IIX");
    expect(resolveName(store, "LUMIX S5IIX")).toBe("Panasonic_Lumix_S5IIX");
    expect(resolveName(store, "Panasonic Lumix S5IIX")).toBe("Panasonic_Lumix_S5IIX");
    expect(resolveName(store, "nonexistent thing")).toBeNull();
    store.close();
  });
});

describe("infobox links", () => {
  it("mount: [[L-Mount]] produces a via='infobox' link edge", () => {
    const store = reindexed(FIXTURE_ROOT);
    const edge = store.db
      .query("SELECT 1 FROM links WHERE src_stem = ? AND dst_stem = 'L-Mount' AND via = 'infobox'")
      .get("Sigma_150-600");
    expect(edge).not.toBeNull();
    // The same mount fact on the camera body also yields an infobox edge.
    const edge2 = store.db
      .query("SELECT 1 FROM links WHERE src_stem = ? AND dst_stem = 'L-Mount' AND via = 'infobox'")
      .get("Panasonic_Lumix_S5IIX");
    expect(edge2).not.toBeNull();
    // The series banner on the camera is a via='series' edge, not infobox.
    const series = store.db
      .query("SELECT 1 FROM links WHERE src_stem = 'Panasonic_Lumix_S5IIX' AND dst_stem = 'Cameras' AND via = 'series'")
      .get();
    expect(series).not.toBeNull();
    store.close();
  });
});
