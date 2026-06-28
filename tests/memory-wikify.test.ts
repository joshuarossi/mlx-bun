// P8-T1 / P8-T2 — LLM WIKIFY pass: deterministic scaffolding + gate wiring.
//
// Everything reachable WITHOUT the GPU: the per-section tighten node's
// gate-rejection wiring (a good tighten is accepted; a weak edit that drops a
// citation or leaks is rejected and the original kept), the infobox
// extract/refresh node's single-info-block invariant, grounded-field rule, and
// alias merge — all driven by a FAKE model so the test is pure and fast. The
// real one-load base-model sweep lives in scripts/memory/wikify-smoke.ts.

import { describe, expect, it } from "bun:test";
import { mkdtemp, mkdir, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { parseInfobox, infoboxAliases } from "../src/memory/article";
import { countFencedInfoBlocks } from "../src/memory/synthesize";
import {
  buildSectionEditorialPrompt,
  improvableSectionTitles,
  improveSections,
  refreshInfobox,
  refreshInfoboxFields,
  setInfobox,
  wikifyArticle,
} from "../src/memory/wikify";

// ---- inline fixture (footnote-bijective, infobox + 2 body sections) --------

function fixture(): string {
  return [
    "# Test Camera",
    "",
    "```info",
    "type: camera-body",
    "kind: thing",
    "mount: [[L-Mount]]",
    "aliases: TC, Test Cam",
    "```",
    "",
    "**Test Camera** is a body the user owns and uses for video work.[^1]",
    "",
    "## Build Quality",
    "",
    "The build is solid and weather-sealed. The build is solid and weather-sealed again, a redundant restatement that says nothing new.[^1] It has a magnesium alloy frame.[^2]",
    "",
    "## Lens Pairing",
    "",
    "It pairs well with adapted vintage glass.[^2]",
    "",
    "## References",
    "",
    "[^1]: `conv:a1b2c3d4` (2024-01-01, Build Notes)",
    "[^2]: `conv:deadbeef` (2024-02-02, Lens Notes)",
    "",
  ].join("\n");
}

/** A fake editor model: tightens Build Quality cleanly (markers + specifics
 *  kept), returns a WEAK edit for Lens Pairing that drops the [^2] citation, and
 *  extracts a plain (un-linked) infobox for the refresh node. */
async function fakeEditor(prompt: string): Promise<string> {
  if (prompt.includes("tightening ONE section")) {
    if (prompt.includes("magnesium")) {
      return "The build is solid and weather-sealed.[^1] It has a magnesium alloy frame.[^2]";
    }
    if (prompt.includes("vintage glass")) {
      return "It pairs well with various lenses."; // drops [^2] — a weak edit
    }
  }
  if (prompt.includes("extracting the INFOBOX")) {
    return "type: camera-body\nmount: L-Mount\nsensor: full-frame 24.2MP\nowned: yes";
  }
  return "NONE";
}

// ---- P8-T1 · per-section tighten -------------------------------------------

describe("improvableSectionTitles", () => {
  it("lists body sections only (not lead / See also / References)", () => {
    expect(improvableSectionTitles(fixture())).toEqual(["Build Quality", "Lens Pairing"]);
  });
});

describe("buildSectionEditorialPrompt", () => {
  it("embeds the section body and the keep-every-citation invariant, no copyable values", () => {
    const p = buildSectionEditorialPrompt("Some body prose.[^1]");
    expect(p).toContain("SECTION TO TIGHTEN");
    expect(p).toContain("Some body prose.[^1]");
    expect(p).toContain("Keep EVERY citation marker");
  });
});

describe("improveSections (gate-rejection wiring)", () => {
  it("accepts a clean tighten and rejects a weak edit that drops a citation", async () => {
    const r = await improveSections(fixture(), { call: fakeEditor });

    expect(r.improved).toEqual(["Build Quality"]);
    expect(r.rejected).toEqual(["Lens Pairing"]);

    // Build Quality: the redundant restatement is gone, both markers survive.
    expect(r.content).not.toContain("redundant restatement");
    expect(r.content).toContain("magnesium alloy frame.[^2]");
    expect(r.content).toContain("[^1]");

    // Lens Pairing: the weak edit was NOT applied — original bytes kept.
    expect(r.content).toContain("adapted vintage glass.[^2]");
    expect(r.content).not.toContain("various lenses");
  });

  it("rejects a meta/reasoning leak, keeping the original", async () => {
    const leakCall = async (prompt: string): Promise<string> =>
      prompt.includes("tightening ONE section")
        ? "I will now draft the body prose for this section. The source material discusses the build."
        : "NONE";
    const r = await improveSections(fixture(), { call: leakCall });
    expect(r.improved).toEqual([]);
    expect(r.rejected).toEqual(["Build Quality", "Lens Pairing"]);
    expect(r.content).toBe(fixture());
  });
});

// ---- P8-T2 · infobox extract / refresh -------------------------------------

describe("refreshInfoboxFields (grounded-field rule + sticky links)", () => {
  it("keeps a grounded physical-spec key on a thing and the existing wikilink sticks", () => {
    const fields = refreshInfoboxFields(fixture(), "thing", "mount: L-Mount\nsensor: full-frame 24.2MP\nowned: yes");
    // mount stays the existing [[L-Mount]] wikilink (existing wins), never the bare scalar.
    expect(fields).toContain("mount: [[L-Mount]]");
    expect(fields).not.toContain("mount: L-Mount");
    // a new world-fact the model added is folded in.
    expect(fields).toContain("sensor: full-frame 24.2MP");
    expect(fields).toContain("kind: thing");
  });

  it("drops physical-spec keys on a non-thing entity (the parroting guard)", () => {
    const fields = refreshInfoboxFields("# Photography\n\n**Photography** is a domain.", "domain", "mount: [[L-Mount]]\nfocal_length: 58mm\nopinion: a lifelong craft");
    expect(fields.some((f) => f.startsWith("mount:"))).toBe(false);
    expect(fields.some((f) => f.startsWith("focal_length:"))).toBe(false);
    expect(fields).toContain("opinion: a lifelong craft");
    expect(fields).toContain("kind: domain");
  });

  it("merges declared aliases with the existing infobox aliases", () => {
    const fields = refreshInfoboxFields(fixture(), "thing", "type: camera-body", ["Camera X"]);
    const aliasLine = fields.find((f) => f.startsWith("aliases:"));
    expect(aliasLine).toContain("TC");
    expect(aliasLine).toContain("Test Cam");
    expect(aliasLine).toContain("Camera X");
  });
});

describe("setInfobox (single-block invariant)", () => {
  it("replaces an existing block in place — still exactly one info block", () => {
    const out = setInfobox(fixture(), ["type: camera-body", "kind: thing", "mount: [[L-Mount]]"]);
    expect(countFencedInfoBlocks(out)).toBe(1);
    expect(out).toContain("mount: [[L-Mount]]");
  });

  it("inserts a fresh block after the H1 when the article has none", () => {
    const noBox = "# Bare\n\n**Bare** is a thing.\n\n## Body\n\nSome prose.\n";
    const out = setInfobox(noBox, ["type: thing", "kind: thing"]);
    expect(countFencedInfoBlocks(out)).toBe(1);
    const lines = out.split("\n");
    expect(lines[0]).toBe("# Bare");
    // the info block precedes the lead prose.
    expect(out.indexOf("```info")).toBeLessThan(out.indexOf("**Bare**"));
  });
});

describe("refreshInfobox (extract/refresh node)", () => {
  it("yields a parseable mount [[L-Mount]] and exactly one info block", async () => {
    const r = await refreshInfobox(fixture(), {
      title: "Test Camera",
      stem: "Test_Camera",
      kind: "thing",
      call: fakeEditor,
      stems: new Set(["L-Mount"]),
      aliases: ["Test Camera"],
    });
    expect(r.reason).toBeNull();
    expect(countFencedInfoBlocks(r.content)).toBe(1);
    const box = parseInfobox(r.content);
    expect(box).not.toBeNull();
    const mount = box!.fields.find((f) => f.key === "mount");
    expect(mount?.value).toBe("[[L-Mount]]");
    expect(mount?.isEntityLink).toBe(true);
    expect(infoboxAliases(box!)).toContain("Test Cam");
  });
});

// ---- effectful entry (temp vault, no GPU, no commit) -----------------------

describe("wikifyArticle (end-to-end, fake model)", () => {
  it("improves a section, refreshes the infobox, and reports the metrics", async () => {
    const root = await mkdtemp(join(tmpdir(), "wikify-"));
    const dir = join(root, "articles");
    await mkdir(dir, { recursive: true });
    await writeFile(join(dir, "Test_Camera.md"), fixture());

    const r = await wikifyArticle({ stem: "Test_Camera", root, call: fakeEditor, commit: false });

    expect(r.status).toBe("edited");
    expect(r.sectionsImproved).toBe(1);
    expect(r.weakEditRejected).toBe(1);
    expect(r.infoboxRefreshed).toBe(true);

    const written = await readFile(join(dir, "Test_Camera.md"), "utf8");
    expect(written).not.toContain("redundant restatement");
    expect(written).toContain("adapted vintage glass.[^2]"); // weak edit not applied
    expect(countFencedInfoBlocks(written)).toBe(1);
    // footnote-bijective survivor (both defs still referenced).
    expect(written).toContain("[^1]:");
    expect(written).toContain("[^2]:");
  });
});
