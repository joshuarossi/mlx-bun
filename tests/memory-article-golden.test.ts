import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { describe, expect, it } from "bun:test";

import {
  infoboxAliases,
  parseInfobox,
  serializeInfobox,
  validateArticleStructure,
} from "../src/memory/article";
import { parseToc } from "../src/memory/vault";

// The hand-authored P1-T1 golden lives in the real vault (~/.mlx-bun/wiki),
// not the repo — it is the canonical article-grammar exemplar. These checks are
// pure: parse it, assert the grammar, and round-trip its infobox byte-for-byte.

const GOLDEN_PATH = join(homedir(), ".mlx-bun", "wiki", "articles", "Panasonic_Lumix_S5IIX.md");
const GOLDEN = readFileSync(GOLDEN_PATH, "utf8");

// The infobox exactly as written in the golden (the byte-for-byte round-trip target).
const INFOBOX = [
  "```info",
  "type: Mirrorless camera",
  "mount: [[L-Mount]]",
  "sensor: full-frame 24.2MP",
  "kind: thing",
  "owned: yes",
  "acquired: 2024-12",
  "used_for: video-conference camera; anamorphic",
  "aliases: S5IIX, S5 IIX, Lumix S5IIX, LUMIX S5IIX",
  "```",
].join("\n");

describe("P1-T1 golden — Panasonic_Lumix_S5IIX", () => {
  it("parses cleanly with parseToc (See also before References, References last)", () => {
    const toc = parseToc(GOLDEN);
    const h1s = toc.filter((t) => t.depth === 1);
    expect(h1s.map((t) => t.title)).toEqual(["Panasonic Lumix S5IIX"]);

    const sections = toc.filter((t) => t.depth === 2).map((t) => t.title);
    const seeIdx = sections.indexOf("See also");
    const refIdx = sections.indexOf("References");
    expect(seeIdx).toBeGreaterThanOrEqual(0);
    expect(refIdx).toBe(sections.length - 1); // References is the LAST section
    expect(seeIdx).toBeLessThan(refIdx); // See also comes before References
  });

  it("passes structural validation", () => {
    expect(validateArticleStructure(GOLDEN)).toEqual({ ok: true, errors: [] });
  });

  it("round-trips its infobox byte-identically", () => {
    expect(GOLDEN.includes(INFOBOX)).toBe(true);
    const box = parseInfobox(GOLDEN);
    expect(box).not.toBeNull();
    expect(serializeInfobox(box!)).toBe(INFOBOX);
  });

  it("extracts the declared aliases", () => {
    const box = parseInfobox(GOLDEN)!;
    expect(infoboxAliases(box)).toEqual(["S5IIX", "S5 IIX", "Lumix S5IIX", "LUMIX S5IIX"]);
  });

  it("names the subject in bold in the lead and cites it", () => {
    expect(GOLDEN).toContain("**Panasonic Lumix S5IIX**");
    expect(GOLDEN).toMatch(/\[\^1\]/); // an inline citation
    expect(GOLDEN).toMatch(/^\[\^1\]: `conv:[0-9a-f]{8}`/m); // a matching def
  });
});

describe("P1-T1 grammar rejects malformed articles", () => {
  it("rejects References that is not the last section", () => {
    const bad = [
      "# Title",
      "",
      "Lead prose.",
      "",
      "## References",
      "",
      "[^1]: `conv:00000000` (2024-01-01, x) — y",
      "",
      "## See also",
      "",
      "- [[Other]]",
    ].join("\n");
    const v = validateArticleStructure(bad);
    expect(v.ok).toBe(false);
    expect(v.errors).toContain("## References must be the last section");
  });

  it("rejects two H1 headings", () => {
    const bad = ["# First", "", "# Second", "", "Lead.", "", "## References", "", "[^1]: `conv:00000000` (2024-01-01, x) — y"].join("\n");
    const v = validateArticleStructure(bad);
    expect(v.ok).toBe(false);
    expect(v.errors).toContain("expected exactly one H1, found 2");
  });

  it("rejects an infobox placed after the lead", () => {
    const bad = [
      "# Title",
      "",
      "Lead prose comes first, which is wrong.",
      "",
      "```info",
      "type: Lens",
      "kind: thing",
      "```",
      "",
      "## References",
      "",
      "[^1]: `conv:00000000` (2024-01-01, x) — y",
    ].join("\n");
    const v = validateArticleStructure(bad);
    expect(v.ok).toBe(false);
    expect(v.errors).toContain("infobox must precede the lead and all sections");
  });
});
