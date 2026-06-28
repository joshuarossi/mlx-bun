import { describe, expect, it } from "bun:test";
import {
  auditArticle,
  auditVault,
  buildContext,
  type ArticleInput,
} from "../scripts/memory/audit-bootstrap";

// Synthetic fixtures — hand-written to exercise each structural check in
// isolation (no golden-file or vault dependency). The grammar mirrors the
// P1-T2 article shape: H1 → ```info → lead → ## sections → ## References last.

/** A fully-clean article: noun title, populated infobox whose link resolves to
 *  a sibling stem, footnote bijection, every body section cited. */
const GOOD: ArticleInput = {
  stem: "Panasonic_Lumix_S5IIX",
  content: [
    "# Panasonic Lumix S5IIX",
    "",
    "```info",
    "type: camera-body",
    "kind: thing",
    "mount: [[L-Mount]]",
    "owned: yes",
    "aliases: S5IIX, S5 IIX, Lumix S5IIX",
    "```",
    "",
    "The **Panasonic Lumix S5IIX** is the full-frame body the user owns.[^1]",
    "",
    "## Mounting",
    "",
    "It takes [[L-Mount]] glass and adapts vintage lenses well.[^1][^2]",
    "",
    "## References",
    "",
    "[^1]: `conv:00000000` (2024-12-01, gear) — bought the camera used",
    "[^2]: `conv:11111111` (2024-12-02, mounts) — discussed mounts",
  ].join("\n"),
};

/** The sibling the GOOD infobox link resolves to. */
const SIBLING: ArticleInput = {
  stem: "L-Mount",
  content: [
    "# L-Mount",
    "",
    "```info",
    "type: lens-mount",
    "kind: standard",
    "aliases: L-Mount, L mount",
    "```",
    "",
    "**L-Mount** is the lens mount standard the user's body uses.[^1]",
    "",
    "## References",
    "",
    "[^1]: `conv:22222222` (2025-01-01, mounts) — mount background",
  ].join("\n"),
};

function ctxFor(...articles: ArticleInput[]) {
  return buildContext(articles);
}

describe("audit-bootstrap structural checks", () => {
  it("passes a clean article on all four checks", () => {
    const a = auditArticle(GOOD, ctxFor(GOOD, SIBLING));
    expect(a.pass).toBe(true);
    expect(a.title.ok).toBe(true);
    expect(a.infobox.ok).toBe(true);
    expect(a.infobox.populated).toBe(true);
    expect(a.infobox.links.find((l) => l.target === "L-Mount")?.status).toBe("resolved");
    expect(a.footnotes.ok).toBe(true);
    expect(a.claims.ok).toBe(true);
    expect(a.claims.citationCount).toBe(2);
  });

  it("rejects an X_and_Y blob title", () => {
    const blob: ArticleInput = { ...GOOD, stem: "Camera_Gear_and_Lenses" };
    const a = auditArticle(blob, ctxFor(blob, SIBLING));
    expect(a.title.ok).toBe(false);
    expect(a.pass).toBe(false);
    expect(a.reasons.join(" ")).toContain("X_and_Y");
  });

  it("flags a dangling infobox link (resolves to nothing, referenced nowhere)", () => {
    const bad: ArticleInput = {
      ...GOOD,
      content: GOOD.content.replace("mount: [[L-Mount]]", "mount: [[Ghost_Entity]]"),
    };
    const a = auditArticle(bad, ctxFor(bad, SIBLING));
    const link = a.infobox.links.find((l) => l.target === "Ghost_Entity");
    expect(link?.status).toBe("dangling");
    expect(a.infobox.ok).toBe(false);
    expect(a.pass).toBe(false);
  });

  it("treats an unresolved-but-referenced link as a redlink, not dangling", () => {
    // [[Helios 44-2]] has no article, but the prose references it → legitimate
    // parking (a redlink), not a dangling invention.
    const withRedlink: ArticleInput = {
      stem: "L-Mount",
      content: SIBLING.content
        .replace("aliases: L-Mount, L mount", "compatible_with: [[Helios 44-2]]\naliases: L-Mount, L mount")
        .replace("the user's body uses.[^1]", "the user's body uses with [[Helios 44-2]] glass.[^1]"),
    };
    const a = auditArticle(withRedlink, ctxFor(withRedlink));
    const link = a.infobox.links.find((l) => l.target === "Helios 44-2");
    expect(link?.status).toBe("redlink");
    expect(a.infobox.ok).toBe(true);
  });

  it("flags a broken footnote bijection (marker with no definition)", () => {
    const bad: ArticleInput = {
      ...GOOD,
      content: GOOD.content.replace("It takes [[L-Mount]] glass", "It takes [[L-Mount]] glass[^9]"),
    };
    const a = auditArticle(bad, ctxFor(bad, SIBLING));
    expect(a.footnotes.ok).toBe(false);
    expect(a.footnotes.danglingMarkers).toContain("9");
    expect(a.pass).toBe(false);
  });

  it("flags an orphan footnote definition (no marker)", () => {
    const bad: ArticleInput = {
      ...GOOD,
      content: GOOD.content + "\n[^7]: `conv:33333333` (2025-02-02, extra) — orphan",
    };
    const a = auditArticle(bad, ctxFor(bad, SIBLING));
    expect(a.footnotes.ok).toBe(false);
    expect(a.footnotes.orphanDefs).toContain("7");
  });

  it("flags an uncited body section (prose claims, no citation)", () => {
    const bad: ArticleInput = {
      ...GOOD,
      content: GOOD.content.replace(
        "## References",
        "## Handling\n\nThe body feels solid and well-built in the hand.\n\n## References",
      ),
    };
    const a = auditArticle(bad, ctxFor(bad, SIBLING));
    expect(a.claims.ok).toBe(false);
    expect(a.claims.uncitedSections).toContain("Handling");
    expect(a.pass).toBe(false);
  });

  it("does not flag a pure main-article pointer section as uncited", () => {
    const ptr: ArticleInput = {
      ...GOOD,
      content: GOOD.content.replace(
        "## References",
        "## Details\n\n*Main article: [[L-Mount]]*\n\n## References",
      ),
    };
    const a = auditArticle(ptr, ctxFor(ptr, SIBLING));
    expect(a.claims.uncitedSections).not.toContain("Details");
  });

  it("aggregates a vault summary with pass rate and counts", () => {
    const blob: ArticleInput = { ...GOOD, stem: "Camera_Gear_and_Lenses" };
    const { audits, summary } = auditVault([GOOD, SIBLING, blob]);
    expect(summary.articleCount).toBe(3);
    expect(summary.structuralPass).toBe(2); // GOOD + SIBLING pass; blob fails title
    expect(summary.failingTitle).toBe(1);
    expect(summary.withInfobox).toBe(3);
    expect(summary.withCitation).toBe(3);
    expect(audits.map((a) => a.stem)).toEqual(["Camera_Gear_and_Lenses", "L-Mount", "Panasonic_Lumix_S5IIX"]);
  });
});
