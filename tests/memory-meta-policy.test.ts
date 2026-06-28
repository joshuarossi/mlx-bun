// Unit tests for the meta-policy inliner (pure — no model needed).
//
// The point of the inliner is "edit-in-the-vault": Meta policy lives on disk,
// so changing a Meta page must change the rendered prompt block with zero code
// change. These tests drive a throwaway vault via MLX_BUN_WIKI.

import { afterEach, beforeEach, describe, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { loadMetaPolicy } from "../src/memory/prompts";

describe("loadMetaPolicy", () => {
  let root: string;
  let metaDir: string;
  const prevWiki = process.env.MLX_BUN_WIKI;

  beforeEach(() => {
    root = mkdtempSync(join(tmpdir(), "mlx-bun-wiki-"));
    metaDir = join(root, "Meta");
    mkdirSync(metaDir, { recursive: true });
    process.env.MLX_BUN_WIKI = root;
  });

  afterEach(() => {
    if (prevWiki === undefined) delete process.env.MLX_BUN_WIKI;
    else process.env.MLX_BUN_WIKI = prevWiki;
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
