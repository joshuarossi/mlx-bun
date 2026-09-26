// Unit tests for the meta-policy inliner (pure — no model needed).
//
// The point of the inliner is "edit-in-the-vault": Meta policy lives on disk,
// so changing a Meta page must change the rendered prompt block with zero code
// change. These tests drive a throwaway vault via MLX_BUN_WIKI.

import { afterEach, beforeEach, describe, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { loadMetaPolicy } from "../../src/memory/prompts";
import { MemoryStore, chunkId } from "../../src/memory/db";
import { synthesizeCreate, synthesizePatch, synthesizeNewSection } from "../../src/memory/synthesize";
import { LEAD_ANCHOR } from "../../src/memory/cluster";
import { configureRuntime } from "@mlx-bun/inference/runtime/config";

describe("loadMetaPolicy", () => {
  let root: string;
  let metaDir: string;
  let restoreWiki = () => {};

  beforeEach(() => {
    root = mkdtempSync(join(tmpdir(), "mlx-bun-wiki-"));
    metaDir = join(root, "Meta");
    mkdirSync(metaDir, { recursive: true });
    restoreWiki = configureRuntime({ MLX_BUN_WIKI: root });
  });

  afterEach(() => {
    restoreWiki();
    restoreWiki = () => {};
    rmSync(root, { recursive: true, force: true });
  });

  test("inlines a Meta page under its --- Meta/<name>.md --- header", () => {
    writeFileSync(join(metaDir, "Buckets.md"), "# Buckets\n\nProjects, People, Ideas.\n");
    const block = loadMetaPolicy(["Buckets"]);
    expect(block).toContain("--- Meta/Buckets.md ---");
    expect(block).toContain("Projects, People, Ideas.");
  });

  test("accepts a trailing .md in the requested name", () => {
    writeFileSync(join(metaDir, "Buckets.md"), "# Buckets\n");
    expect(loadMetaPolicy(["Buckets.md"])).toContain("--- Meta/Buckets.md ---");
  });

  test("concatenates multiple pages in the requested order", () => {
    writeFileSync(join(metaDir, "A.md"), "alpha");
    writeFileSync(join(metaDir, "B.md"), "bravo");
    const block = loadMetaPolicy(["B", "A"]);
    expect(block.indexOf("bravo")).toBeLessThan(block.indexOf("alpha"));
  });

  test("reflects an on-disk edit with no code change", () => {
    const page = join(metaDir, "Editorial_Guidelines.md");
    writeFileSync(page, "# Editorial Guidelines\n\nFavor brevity.\n");
    expect(loadMetaPolicy(["Editorial_Guidelines"])).toContain("Favor brevity.");

    // Edit one line in the vault; the rendered block must change accordingly.
    writeFileSync(page, "# Editorial Guidelines\n\nFavor depth over brevity.\n");
    const after = loadMetaPolicy(["Editorial_Guidelines"]);
    expect(after).toContain("Favor depth over brevity.");
    expect(after).not.toContain("Favor brevity.\n");
  });

  test("throws naming the missing file when a Meta page is absent", () => {
    expect(() => loadMetaPolicy(["Does_Not_Exist"])).toThrow("Does_Not_Exist.md");
  });
});


test("CREATE, section/lead PATCH and new sections use the owning vault's editorial policy", async () => {
  const home = mkdtempSync(join(tmpdir(), "memory-policy-owners-"));
  const selected = join(home, "selected"), other = join(home, "other");
  const restore = configureRuntime({ MLX_BUN_WIKI: other });
  const store = new MemoryStore(":memory:");
  const conv = "11112222-0000-0000-0000-000000000000", id = chunkId(conv, 0, 0);
  try {
    for (const root of [selected, other]) {
      mkdirSync(join(root, "Meta"), { recursive: true });
      mkdirSync(join(root, "articles"), { recursive: true });
      for (const name of ["Article_Conventions", "Infobox_Schemas", "Entities"])
        writeFileSync(join(root, "Meta", `${name}.md`), `${root === selected ? "SELECTED" : "WRONG"}_${name}_POLICY`);
    }
    writeFileSync(join(selected, "articles", "Camera.md"), "# Camera\n\n**Camera** is a useful body.\n\n## Lenses\n\nA lens helps framing.\n");
    store.db.run("INSERT INTO conversations (conv, source, title, updated_at) VALUES (?,?,?,?)", [conv, "test", "Camera", 1700000000000]);
    store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [conv, 0, "user", "m0", "I use this camera with a portrait lens."]);
    store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [id, conv, 0, 0, "Camera"]);
    const prompts: string[] = [];
    const call = async (prompt: string) => { prompts.push(prompt); throw new Error("stop after policy read"); };
    const common = { root: selected, call, commit: false };
    await expect(synthesizeCreate(store, { ...common, entity: "Camera", chunkIds: [id] })).rejects.toThrow("stop after policy read");
    for (const anchor of ["lenses", LEAD_ANCHOR])
      await expect(synthesizePatch(store, { ...common, stem: "Camera", anchor, chunkId: id })).rejects.toThrow("stop after policy read");
    await expect(synthesizeNewSection(store, { ...common, stem: "Camera", title: "Travel", anchor: "travel", chunkId: id })).rejects.toThrow("stop after policy read");
    expect(prompts).toHaveLength(4);
    for (const prompt of prompts) {
      expect(prompt).toContain("SELECTED_Article_Conventions_POLICY");
      expect(prompt).not.toContain("WRONG_");
    }
    expect(prompts[0]).toContain("SELECTED_Infobox_Schemas_POLICY");
    expect(prompts[0]).toContain("SELECTED_Entities_POLICY");
  } finally { store.close(); restore(); rmSync(home, { recursive: true, force: true }); }
});
