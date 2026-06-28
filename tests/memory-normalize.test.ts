// P6-T2 — deterministic NORMALIZE pass (no model).
//
// Ports lucien's `normalize-footnotes.test.ts` + `normalize-wikilinks.test.ts`
// suites and adds the Dreaming structural guards (infobox key sort, References
// last, {{stub}} for thin articles, H1 = stem) + the acceptance assertions:
// out-of-order footnotes renumber contiguous; every run leaves a
// footnote-bijective, orphan-free article; a 1-section/20-word article gets
// {{stub}}.

import { describe, expect, it } from "bun:test";
import {
  articleThinness,
  checkFootnoteIntegrity,
  enforceH1Title,
  hasStubMarker,
  normalizeArticle,
  normalizeFootnotes,
  normalizeWikilinks,
  reorderSections,
  sortInfoboxKeys,
  stubGuard,
} from "../src/memory/normalize";

const REFS = "\n\n## References\n\n";

// ---- ported: normalize-footnotes ------------------------------------

describe("normalizeFootnotes (ported from lucien)", () => {
  it("healthy article is a byte-identical no-op", () => {
    const a =
      "# T\n\nClaim one.[^1] Claim two.[^2]" +
      REFS +
      "[^1]: `conv:a1b2c3d4` — one\n[^2]: `conv:deadbeef` — two\n";
    const r = normalizeFootnotes(a);
    expect(r.changed).toBe(false);
    expect(r.article).toBe(a);
    expect(r.talk).toBeNull();
  });

  it("orphan marker is dropped, prose intact", () => {
    const a =
      "# T\n\nA.[^1] B.[^2] C is unsourced.[^9]" +
      REFS +
      "[^1]: `conv:a1b2c3d4` — one\n[^2]: `conv:deadbeef` — two\n";
    const r = normalizeFootnotes(a);
    expect(r.changed).toBe(true);
    expect(r.droppedMarkers).toEqual([9]);
    expect(r.article).toContain("C is unsourced.\n");
    expect(r.article).not.toContain("[^9]");
    expect(checkFootnoteIntegrity(r.article).ok).toBe(true);
    expect(r.talk).toContain("orphan citation marker");
  });

  it("orphan definition is dropped", () => {
    const a =
      "# T\n\nOnly A is cited.[^1]" +
      REFS +
      "[^1]: `conv:a1b2c3d4` — one\n[^2]: `conv:deadbeef` — unused\n";
    const r = normalizeFootnotes(a);
    expect(r.changed).toBe(true);
    expect(r.droppedDefs).toEqual([{ num: 2, conv: "conv:deadbeef" }]);
    expect(r.article).not.toContain("conv:deadbeef");
    expect(checkFootnoteIntegrity(r.article).ok).toBe(true);
  });

  it("survivors are renumbered contiguously in body order", () => {
    const a =
      "# T\n\nFirst.[^3] Second.[^1]" +
      REFS +
      "[^1]: `conv:11111111` — was one\n[^3]: `conv:33333333` — was three\n";
    const r = normalizeFootnotes(a);
    expect(checkFootnoteIntegrity(r.article).ok).toBe(true);
    expect(r.article).toContain("First.[^1] Second.[^2]");
    expect(r.article).toContain("[^1]: `conv:33333333`");
    expect(r.article).toContain("[^2]: `conv:11111111`");
  });

  it("idempotent — a second pass is a no-op", () => {
    const a =
      "# T\n\nA.[^1] B.[^2] phantom[^7]" +
      REFS +
      "[^1]: `conv:a1b2c3d4` — one\n[^5]: `conv:deadbeef` — unused\n[^2]: `conv:cafebabe` — two\n";
    const once = normalizeFootnotes(a);
    expect(once.changed).toBe(true);
    expect(checkFootnoteIntegrity(once.article).ok).toBe(true);
    const twice = normalizeFootnotes(once.article);
    expect(twice.changed).toBe(false);
    expect(twice.article).toBe(once.article);
  });

  it("merges duplicate conv:HASH definitions into one footnote", () => {
    const a =
      "# T\n\nA.[^1] B.[^2]" +
      REFS +
      "[^1]: `conv:aaaaaaaa` — same conv\n[^2]: `conv:aaaaaaaa` — same conv again\n";
    const r = normalizeFootnotes(a);
    expect(r.changed).toBe(true);
    expect(r.mergedDefs).toEqual([2]);
    expect(r.article).toContain("A.[^1] B.[^1]");
    expect(checkFootnoteIntegrity(r.article).ok).toBe(true);
    // and it is then idempotent
    expect(normalizeFootnotes(r.article).changed).toBe(false);
  });
});

// ---- ported: normalize-wikilinks ------------------------------------

describe("normalizeWikilinks (ported from lucien)", () => {
  const stems = new Set(["AI_Coding_Workflow", "Archie_Project", "Lucien_Synthesis_Pipeline"]);

  it("rewrites a plain spaced link whose underscore stem exists", () => {
    const { content, edits } = normalizeWikilinks("see [[AI Coding Workflow]] for context", stems);
    expect(content).toBe("see [[AI_Coding_Workflow]] for context");
    expect(edits).toBe(1);
  });

  it("rewrites the target of an aliased link but preserves the alias verbatim", () => {
    const { content, edits } = normalizeWikilinks(
      "the [[AI Coding Workflow|subagent-driven development pattern]] is key",
      stems,
    );
    expect(content).toBe("the [[AI_Coding_Workflow|subagent-driven development pattern]] is key");
    expect(edits).toBe(1);
  });

  it("rewrites the target of a section link but preserves the #anchor verbatim", () => {
    const { content, edits } = normalizeWikilinks("jump to [[Archie Project#The Clarity run]] here", stems);
    expect(content).toBe("jump to [[Archie_Project#The Clarity run]] here");
    expect(edits).toBe(1);
  });

  it("handles the combined #section|alias form", () => {
    const { content, edits } = normalizeWikilinks("[[Archie Project#The journal|the BTS journal]]", stems);
    expect(content).toBe("[[Archie_Project#The journal|the BTS journal]]");
    expect(edits).toBe(1);
  });

  it("leaves a true redlink (no matching stem) untouched and flags it", () => {
    const { content, edits, orphans } = normalizeWikilinks(
      "unrelated [[Mercury (planet)]] and [[La Leche League]]",
      stems,
    );
    expect(content).toBe("unrelated [[Mercury (planet)]] and [[La Leche League]]");
    expect(edits).toBe(0);
    expect(orphans).toEqual(["Mercury (planet)", "La Leche League"]);
  });

  it("is idempotent: already-underscored links are left alone", () => {
    const input = "[[AI_Coding_Workflow]] and [[Archie_Project|the project]] and [[Lucien_Synthesis_Pipeline#Stage 4]]";
    const { content, edits } = normalizeWikilinks(input, stems);
    expect(content).toBe(input);
    expect(edits).toBe(0);
  });

  it("rewrites multiple distinct links in one pass", () => {
    const { content, edits } = normalizeWikilinks(
      "[[AI Coding Workflow]] then [[Archie Project|it]] then [[Mercury (planet)]]",
      stems,
    );
    expect(content).toBe("[[AI_Coding_Workflow]] then [[Archie_Project|it]] then [[Mercury (planet)]]");
    expect(edits).toBe(2);
  });

  it("normalizes infobox entity-values the same way (whole-text replace)", () => {
    const md = "# X\n\n```info\nmount: [[Archie Project]]\n```\n\nlead";
    const { content, edits } = normalizeWikilinks(md, stems);
    expect(content).toContain("mount: [[Archie_Project]]");
    expect(edits).toBe(1);
  });

  it("does not touch conv: or Category: links", () => {
    const md = "see [[Category:Camera Bodies]] and `conv:deadbeef`";
    const { content, edits } = normalizeWikilinks(md, stems);
    expect(content).toBe(md);
    expect(edits).toBe(0);
  });
});

// ---- structural guards ----------------------------------------------

describe("infobox key sort", () => {
  it("orders type/kind first, aliases last, rest alphabetical — idempotently", () => {
    const md =
      "# Cam\n\n```info\nowned: yes\nmount: [[L-Mount]]\naliases: S5IIX, S5 IIX\nkind: thing\ntype: Mirrorless camera\n```\n\nlead";
    const r = sortInfoboxKeys(md);
    expect(r.changed).toBe(true);
    const keys = r.content
      .split("\n")
      .filter((l) => /^[a-z_]+:/.test(l))
      .map((l) => l.split(":")[0]);
    expect(keys).toEqual(["type", "kind", "mount", "owned", "aliases"]);
    expect(sortInfoboxKeys(r.content).changed).toBe(false);
  });

  it("is a no-op when there is no infobox", () => {
    expect(sortInfoboxKeys("# X\n\njust prose").changed).toBe(false);
  });
});

describe("reorderSections", () => {
  it("moves ## References last and ## See also before it", () => {
    const md =
      "# T\n\nlead.[^1]\n\n## References\n\n[^1]: `conv:deadbeef` — x\n\n## Body\n\nmore.\n\n## See also\n\n- [[X]]";
    const r = reorderSections(md);
    expect(r.changed).toBe(true);
    const order = r.content.split("\n").filter((l) => l.startsWith("## ")).map((l) => l.slice(3));
    expect(order).toEqual(["Body", "See also", "References"]);
    expect(reorderSections(r.content).changed).toBe(false);
  });

  it("is a no-op when sections are already ordered", () => {
    const md = "# T\n\nlead\n\n## Body\n\nx\n\n## See also\n\n- [[X]]\n\n## References\n\n[^1]: `conv:deadbeef` — x";
    expect(reorderSections(md).changed).toBe(false);
  });
});

describe("enforceH1Title", () => {
  it("rewrites a divergent H1 to the stem title", () => {
    const r = enforceH1Title("# Wrong Title\n\nbody", "Foo_Bar");
    expect(r.changed).toBe(true);
    expect(r.content.startsWith("# Foo Bar\n")).toBe(true);
  });

  it("prepends an H1 when absent", () => {
    const r = enforceH1Title("## Section only\n\nbody", "Foo_Bar");
    expect(r.changed).toBe(true);
    expect(r.content.startsWith("# Foo Bar\n\n")).toBe(true);
  });

  it("is a no-op when the H1 already equals the stem", () => {
    expect(enforceH1Title("# Foo Bar\n\nbody", "Foo_Bar").changed).toBe(false);
  });
});

describe("stub threshold", () => {
  it("a 1-section / ~20-word article is thin and gets {{stub}}", () => {
    const md =
      "# Thin\n\n## Overview\n\nThis is a short article with roughly twenty words of body prose and only one single section here.";
    const t = articleThinness(md);
    expect(t.bodySections).toBe(1);
    expect(t.stub).toBe(true);
    const r = stubGuard(md);
    expect(r.changed).toBe(true);
    expect(hasStubMarker(r.content)).toBe(true);
    expect(stubGuard(r.content).changed).toBe(false); // idempotent
  });

  it("a 2-section / 40+ word article is not thin and carries no stub", () => {
    const para = "word ".repeat(30).trim();
    const md = `# Full\n\n## One\n\n${para}\n\n## Two\n\n${para}`;
    expect(articleThinness(md).stub).toBe(false);
    expect(stubGuard(md).changed).toBe(false);
  });

  it("removes a stale {{stub}} once the article has outgrown the threshold", () => {
    const para = "word ".repeat(30).trim();
    const md = `# Full\n\n{{stub}}\n\n## One\n\n${para}\n\n## Two\n\n${para}`;
    const r = stubGuard(md);
    expect(r.changed).toBe(true);
    expect(hasStubMarker(r.content)).toBe(false);
  });
});

// ---- orchestrator / acceptance --------------------------------------

describe("normalizeArticle (acceptance)", () => {
  const stems = new Set(["Foo", "L-Mount"]);

  it("renumbers appended out-of-order footnotes contiguous and leaves it bijective", () => {
    // A patched article: a new claim cited [^5], its def appended out of order.
    const md =
      "# Foo\n\nA.[^1] B.[^2] newly added.[^5]" +
      REFS +
      "[^1]: `conv:11111111` — one\n[^2]: `conv:22222222` — two\n[^5]: `conv:55555555` — five\n";
    const r = normalizeArticle(md, { stem: "Foo", stems });
    expect(r.changed).toBe(true);
    expect(r.content).toContain("A.[^1] B.[^2] newly added.[^3]");
    expect(checkFootnoteIntegrity(r.content).ok).toBe(true);
    // idempotent: a second pass over the normalized article changes nothing.
    const again = normalizeArticle(r.content, { stem: "Foo", stems });
    expect(again.changed).toBe(false);
  });

  it("every run leaves a footnote-bijective, orphan-free article", () => {
    const md =
      "# Foo\n\nclaim.[^2] phantom[^9] another.[^4]" +
      REFS +
      "[^2]: `conv:22222222` — two\n[^4]: `conv:44444444` — four\n[^8]: `conv:88888888` — unused\n";
    const r = normalizeArticle(md, { stem: "Foo", stems });
    expect(checkFootnoteIntegrity(r.content).ok).toBe(true);
    expect(r.content).not.toContain("[^9]");
    expect(r.content).not.toContain("conv:88888888");
  });

  it("a thin one-section article ends up marked {{stub}} with a stem H1", () => {
    const md = "# wrong\n\n## Overview\n\nA short stub-worthy paragraph of fewer than forty words here.";
    const r = normalizeArticle(md, { stem: "Foo", stems });
    expect(r.stub).toBe(true);
    expect(hasStubMarker(r.content)).toBe(true);
    expect(r.content.startsWith("# Foo\n")).toBe(true);
  });

  it("the whole pass is idempotent on an already-clean article", () => {
    const md =
      "# Foo\n\n```info\ntype: Thing\nkind: thing\nmount: [[L-Mount]]\naliases: F\n```\n\n" +
      "Lead about **Foo**.[^1]\n\n## Body\n\nMore body prose with well over forty words so that the article is comfortably above the stub threshold and does not get marked, padding padding padding padding padding padding padding.\n\n" +
      "## See also\n\n- [[L-Mount]]\n\n## References\n\n[^1]: `conv:deadbeef` — x\n";
    const first = normalizeArticle(md, { stem: "Foo", stems });
    const second = normalizeArticle(first.content, { stem: "Foo", stems });
    expect(second.changed).toBe(false);
    expect(second.content).toBe(first.content);
  });
});

// ---- fence repair + duplicate trailing-section merge (imported-corpus heal) ----

describe("normalizeArticle fence repair", () => {
  const stems = new Set(["JS"]);

  it("repairs an unbalanced ``` so trailing ## References / ## See also are recognized", () => {
    // ```python opens and is never closed → without repair the trailing sections
    // are read as code and the footnote def is lost.
    const a =
      "# JS\n\n```info\nkind: thing\n```\n\nLead.[^1]\n\n## Code\n\n```python\nprint(1)\n\n" +
      "## See also\n\n- [[Other]]\n\n## References\n\n[^1]: `conv:a1b2c3d4` (2024-01-01, x) — note\n";
    const r = normalizeArticle(a, { stem: "JS", stems });
    expect(r.notes).toContain("repaired unbalanced code fence");
    expect(checkFootnoteIntegrity(r.content).ok).toBe(true);
    expect(r.content).toMatch(/^## References$/m);
    expect(r.content).toMatch(/^## See also$/m);
    // Balanced now.
    expect(r.content.split("\n").filter((l) => /^```/.test(l)).length % 2).toBe(0);
    // Idempotent.
    const r2 = normalizeArticle(r.content, { stem: "JS", stems });
    expect(r2.content).toBe(r.content);
  });

  it("merges duplicate trailing meta sections (the appended-References/See-also bug)", () => {
    const a =
      "# JS\n\nLead.[^1] More.[^2]\n\n" +
      "## References\n\n[^1]: `conv:a1b2c3d4` (2024-01-01, a) — one\n\n" +
      "## References\n\n[^2]: `conv:deadbeef` (2024-02-02, b) — two\n\n" +
      "## See also\n\n- [[Other]]\n\n## See also\n\n- [[Other]]\n";
    const r = normalizeArticle(a, { stem: "JS", stems: new Set(["JS", "Other"]) });
    const refs = (r.content.match(/^## References$/gm) ?? []).length;
    const see = (r.content.match(/^## See also$/gm) ?? []).length;
    expect(refs).toBe(1);
    expect(see).toBe(1);
    expect(checkFootnoteIntegrity(r.content).ok).toBe(true);
    // Both defs survive the merge.
    expect(r.content).toContain("conv:a1b2c3d4");
    expect(r.content).toContain("conv:deadbeef");
    // Idempotent.
    expect(normalizeArticle(r.content, { stem: "JS", stems: new Set(["JS", "Other"]) }).content).toBe(r.content);
  });
});
