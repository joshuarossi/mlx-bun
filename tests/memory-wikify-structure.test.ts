// P8-T3 / P8-T4 — summary-style SPLIT, series banner, MERGE signal, Talk-page
// triage. The deterministic half: split detection + mechanics, the {{Main}} edge
// reindex records via=main, near-duplicate-stub merge signals, series-banner
// maintenance, the embedding silhouette (FAKE embed — the read path never
// embeds), and Talk-page suggestion writing. No GPU; the real one-load embedding
// silhouette lives in scripts/memory/eval-wikify-split.ts.

import { describe, expect, it } from "bun:test";
import { mkdtemp, mkdir, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { parseInfobox } from "../src/memory/article";
import { MemoryStore } from "../src/memory/db";
import { getEmbedCounter, resetEmbedCounter } from "../src/embed";
import { reindex } from "../src/memory/reindex";
import { extractSection, listArticles, parseToc } from "../src/memory/vault";
import {
  bodySectionSizes,
  buildStructureTalk,
  detectMergeCandidates,
  detectSplitCandidate,
  sectionCohesion,
  setSeriesBanner,
  splitOutSection,
  writeTalkPage,
  type EmbedFn,
} from "../src/memory/wikify";

// ---- fixtures --------------------------------------------------------------

/** An article whose "Anamorphic Workflow" section has outgrown everything else:
 *  it dominates in absolute prose AND vs all other body sections combined. */
function oversizedArticle(): string {
  const big = Array.from({ length: 30 }, (_, i) =>
    `The anamorphic rig detail number ${i} covers squeeze factor, desqueeze, and the taking lens pairing in depth.`,
  ).join(" ");
  return [
    "# Camera Gear",
    "",
    "```info",
    "type: collection",
    "kind: thing",
    "```",
    "",
    "**Camera Gear** is the user's photography kit and how each piece is used.[^1]",
    "",
    "## Bodies",
    "",
    "The user shoots one full-frame body.[^1]",
    "",
    "## Anamorphic Workflow",
    "",
    `${big} The user owns a dedicated anamorphic adapter and uses it for cinematic video.[^2]`,
    "",
    "## References",
    "",
    "[^1]: `conv:a1b2c3d4` (2024-01-01, Kit Notes)",
    "[^2]: `conv:deadbeef` (2024-02-02, Anamorphic Notes)",
    "",
  ].join("\n");
}

/** A cohesive article: three balanced, short body sections — none dominates. */
function cohesiveArticle(): string {
  return [
    "# Photography",
    "",
    "```info",
    "kind: domain",
    "```",
    "",
    "**Photography** is a craft the user practices.[^1]",
    "",
    "## History",
    "",
    "The user took up the craft years ago and keeps at it.[^1]",
    "",
    "## Approach",
    "",
    "The user favors available light and candid framing in daily work.[^1]",
    "",
    "## Gear Philosophy",
    "",
    "The user keeps a small kit and buys deliberately, never chasing specs.[^1]",
    "",
    "## References",
    "",
    "[^1]: `conv:a1b2c3d4` (2024-01-01, Craft Notes)",
    "",
  ].join("\n");
}

// ---- P8-T3 · split detection -----------------------------------------------

describe("detectSplitCandidate", () => {
  it("flags the one section that has outgrown the article", () => {
    const cand = detectSplitCandidate(oversizedArticle());
    expect(cand).not.toBeNull();
    expect(cand!.title).toBe("Anamorphic Workflow");
    expect(cand!.words).toBeGreaterThan(cand!.otherWords);
  });

  it("does NOT split a cohesive article with balanced sections (no false split)", () => {
    expect(detectSplitCandidate(cohesiveArticle())).toBeNull();
  });

  it("bodySectionSizes excludes the lead and References", () => {
    const sizes = bodySectionSizes(oversizedArticle());
    expect(sizes.map((s) => s.title)).toEqual(["Bodies", "Anamorphic Workflow"]);
  });
});

// ---- P8-T3 · split mechanics -----------------------------------------------

describe("splitOutSection", () => {
  it("produces a child (infobox + moved cited prose) and a parent summary + Main pointer", async () => {
    const cand = detectSplitCandidate(oversizedArticle())!;
    const r = await splitOutSection(oversizedArticle(), cand.anchor, { parentStem: "Camera_Gear" });
    expect(r).not.toBeNull();

    // Child: own infobox, the moved [^2] citation, footnote-bijective.
    expect(r!.childStem).toBe("Anamorphic_Workflow");
    expect(parseInfobox(r!.child)).not.toBeNull();
    expect(r!.child).toContain("anamorphic adapter");
    expect(r!.child).toMatch(/\[\^\d+\]:/); // a moved definition rides along
    expect(r!.movedMarkers).toContain(2);

    // Parent: the dominant section is now a summary + the {{Main}} edge; the
    // moved section's prose is gone, the moved citation does not dangle.
    expect(r!.parent).toContain("*Main article: [[Anamorphic_Workflow]]*");
    expect(r!.parent).not.toContain("anamorphic adapter");
    expect(r!.parent).not.toContain("conv:deadbeef"); // orphan def dropped by NORMALIZE
    // The surviving citation is intact and the parent still parses cleanly.
    expect(r!.parent).toContain("conv:a1b2c3d4");
    expect(parseToc(r!.parent).some((e) => e.title === "References")).toBe(true);
  });

  it("reindex records the {{Main}} split as a via=main parent→child edge", async () => {
    const cand = detectSplitCandidate(oversizedArticle())!;
    const r = await splitOutSection(oversizedArticle(), cand.anchor, { parentStem: "Camera_Gear" });
    expect(r).not.toBeNull();

    const root = await mkdtemp(join(tmpdir(), "wikify-split-"));
    const dir = join(root, "articles");
    await mkdir(dir, { recursive: true });
    await writeFile(join(dir, "Camera_Gear.md"), r!.parent);
    await writeFile(join(dir, `${r!.childStem}.md`), r!.child);

    const store = new MemoryStore(":memory:");
    reindex(store, root);
    const rows = store.db
      .query("SELECT src_stem, dst_stem FROM links WHERE via = 'main'")
      .all() as { src_stem: string; dst_stem: string }[];
    expect(rows).toContainEqual({ src_stem: "Camera_Gear", dst_stem: "Anamorphic_Workflow" });
    store.db.close();
  });
});

// ---- P8-T3 · series banner -------------------------------------------------

describe("setSeriesBanner", () => {
  it("inserts a banner directly under the H1 when absent", () => {
    const r = setSeriesBanner("# Sigma 150-600\n\n**Sigma 150-600** is a lens.\n", "Lenses");
    expect(r.changed).toBe(true);
    const lines = r.content.split("\n");
    expect(lines[0]).toBe("# Sigma 150-600");
    expect(lines[2]).toBe("*Part of a series on [[Lenses]].*");
  });

  it("rewrites a divergent banner and no-ops on a match", () => {
    const withBanner = "# X\n\n*Part of a series on [[Old]].*\n\nbody\n";
    const rewritten = setSeriesBanner(withBanner, "Lenses");
    expect(rewritten.changed).toBe(true);
    expect(rewritten.content).toContain("*Part of a series on [[Lenses]].*");
    expect(setSeriesBanner(rewritten.content, "Lenses").changed).toBe(false);
  });

  it("a null/empty series is a no-op (maintain, not remove)", () => {
    const src = "# X\n\nbody\n";
    expect(setSeriesBanner(src, null).changed).toBe(false);
    expect(setSeriesBanner(src, "  ").changed).toBe(false);
  });
});

// ---- P8-T3 · merge signal --------------------------------------------------

describe("detectMergeCandidates", () => {
  it("emits a MERGE signal for two near-duplicate stubs", () => {
    const a = "# Sankor 16C\n\n```info\nkind: thing\n```\n\n**Sankor 16C** is the user's anamorphic adapter, a single-focus projection lens used for cinematic video.\n";
    const b = "# Sankor 16-C\n\n```info\nkind: thing\n```\n\n**Sankor 16-C** is an anamorphic projection adapter the user owns and uses for cinematic single-focus video.\n";
    const sigs = detectMergeCandidates([
      { stem: "Sankor_16C", content: a },
      { stem: "Sankor_16-C", content: b },
    ]);
    expect(sigs.length).toBe(1);
    expect(new Set([sigs[0]!.a, sigs[0]!.b])).toEqual(new Set(["Sankor_16C", "Sankor_16-C"]));
    expect(sigs[0]!.jaccard).toBeGreaterThanOrEqual(0.5);
  });

  it("does not merge two unrelated stubs", () => {
    const a = "# L-Mount\n\n```info\nkind: standard\n```\n\n**L-Mount** is a lens mount standard shared across three manufacturers.\n";
    const b = "# PETG\n\n```info\nkind: standard\n```\n\n**PETG** is a 3D-printing filament the user prints structural brackets with.\n";
    expect(detectMergeCandidates([{ stem: "L-Mount", content: a }, { stem: "PETG", content: b }])).toEqual([]);
  });
});

// ---- P8-T4 · silhouette + Talk page ----------------------------------------

/** A deterministic fake embed: a token-hashed bag-of-words vector (real shared
 *  words → real similarity), so cohesion is computable with no GPU. Counts its
 *  own calls. */
function fakeEmbed(): { fn: EmbedFn; calls: () => number } {
  let calls = 0;
  const DIM = 96;
  const hash = (s: string): number => {
    let h = 2166136261;
    for (let i = 0; i < s.length; i++) h = (Math.imul(h ^ s.charCodeAt(i), 16777619) >>> 0);
    return h % DIM;
  };
  const fn: EmbedFn = (texts) => {
    calls += texts.length;
    return texts.map((t) => {
      const v = new Float32Array(DIM);
      for (const w of t.toLowerCase().split(/[^a-z0-9]+/)) if (w.length > 2) v[hash(w)]! += 1;
      return v;
    });
  };
  return { fn, calls: () => calls };
}

describe("sectionCohesion (offline silhouette)", () => {
  it("scores distinct-topic sections lower than cohesive ones, via the injected embed", () => {
    const distinct = sectionCohesion(oversizedArticle(), fakeEmbed().fn);
    const cohesive = sectionCohesion(cohesiveArticle(), fakeEmbed().fn);
    expect(distinct.sections).toBeGreaterThanOrEqual(2);
    expect(distinct.meanPairwise).toBeLessThan(cohesive.meanPairwise);
  });

  it("invokes the injected embed once per body section", () => {
    const { fn, calls } = fakeEmbed();
    sectionCohesion(oversizedArticle(), fn);
    expect(calls()).toBe(bodySectionSizes(oversizedArticle()).length);
  });
});

describe("buildStructureTalk + writeTalkPage", () => {
  it("composes split + merge suggestions and writes Talk/<stem>.md (never touches articles/)", async () => {
    const cand = detectSplitCandidate(oversizedArticle());
    const merges = detectMergeCandidates([
      { stem: "Camera_Gear", content: "# Camera Gear\n\n```info\nkind: thing\n```\n\n**Camera Gear** is the user's anamorphic kit and how each part is used for video." },
      { stem: "Gear", content: "# Gear\n\n```info\nkind: thing\n```\n\n**Gear** is the user's anamorphic kit and how each part is used for video." },
    ]);
    const suggestions = buildStructureTalk({ stem: "Camera_Gear", split: cand, merges });
    expect(suggestions.some((s) => s.kind === "split")).toBe(true);
    expect(suggestions.some((s) => s.kind === "merge")).toBe(true);

    const root = await mkdtemp(join(tmpdir(), "wikify-talk-"));
    await mkdir(join(root, "articles"), { recursive: true });
    const path = await writeTalkPage({ stem: "Camera_Gear", suggestions, root });
    expect(path).not.toBeNull();
    expect(path!).toContain(`${join("Talk", "Camera_Gear.md")}`);
    const written = await readFile(path!, "utf8");
    expect(written).toContain("<<<TALK>>>");
    expect(written).toContain("<<<END TALK>>>");
    expect(written).toContain("SPLIT");
    expect(written).toContain("MERGE");
    // The article store is untouched — no silent cross-article surgery.
    expect(await listArticles(root)).toEqual([]);
  });

  it("returns null and writes nothing when there are no suggestions", async () => {
    const root = await mkdtemp(join(tmpdir(), "wikify-talk-empty-"));
    expect(await writeTalkPage({ stem: "X", suggestions: [], root })).toBeNull();
  });
});

// ---- P8-T4 · read-path embedding tripwire stays 0 --------------------------

describe("read-path tripwire", () => {
  it("the structural read path (toc/section/reindex) never touches embeddings", async () => {
    const root = await mkdtemp(join(tmpdir(), "wikify-read-"));
    const dir = join(root, "articles");
    await mkdir(dir, { recursive: true });
    await writeFile(join(dir, "Camera_Gear.md"), oversizedArticle());

    resetEmbedCounter();
    // A representative read: list → reindex → TOC → section → split detection.
    const stems = await listArticles(root);
    const store = new MemoryStore(":memory:");
    reindex(store, root);
    const content = await readFile(join(dir, "Camera_Gear.md"), "utf8");
    parseToc(content);
    extractSection(content, "anamorphic-workflow");
    detectSplitCandidate(content);
    store.db.close();

    expect(stems).toEqual(["Camera_Gear"]);
    expect(getEmbedCounter()).toBe(0); // ONLY offline triage may embed
  });
});
