// The Dreaming — CROSS-LINK stage (the dedicated edge builder).
//
// Synthesis builds NODES bounded to one article; the cross-link stage builds the
// EDGES. These tests pin the deterministic (no-model) behaviour:
//   • a body that mentions another article gets an inline [[link]] + a See also entry;
//   • two articles that share folded chunks get a See also even with no mention;
//   • self-links / partial words / redlinks-to-nonexistent are NOT linked;
//   • a re-run is byte-identical (idempotent);
//   • the result is run through normalizeWikilinks (spaced → underscore stems).

import { mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterAll, describe, expect, it } from "bun:test";

import {
  buildAliasIndex,
  coOccurrence,
  linkBodyMentions,
  rebuildArticleLinks,
  runLinkStage,
  setSeeAlsoSection,
} from "../src/memory/crosslink";
import { MemoryStore } from "../src/memory/db";

const temps: string[] = [];

/** A throwaway vault with the given `stem → markdown` articles. */
function vaultWith(articles: Record<string, string>): string {
  const root = mkdtempSync(join(tmpdir(), "mlxbun-crosslink-"));
  temps.push(root);
  const dir = join(root, "articles");
  mkdirSync(dir, { recursive: true });
  for (const [stem, md] of Object.entries(articles)) writeFileSync(join(dir, `${stem}.md`), md);
  return root;
}

const read = (root: string, stem: string): string => readFileSync(join(root, "articles", `${stem}.md`), "utf8");

afterAll(() => {
  for (const d of temps) rmSync(d, { recursive: true, force: true });
});

const indexOf = (articles: Record<string, string>) =>
  buildAliasIndex(Object.entries(articles).map(([stem, content]) => ({ stem, content })));

describe("MENTION edges (inline links)", () => {
  it("wraps the first clear mention of another existing article", () => {
    const articles = {
      Toyota_Production_System: `# Toyota Production System\n\nThe **Toyota Production System** relies on Kaizen for continuous improvement.\n`,
      Kaizen: `# Kaizen\n\n**Kaizen** is continuous improvement.\n`,
    };
    const index = indexOf(articles);
    const out = linkBodyMentions(articles.Toyota_Production_System, index, "Toyota_Production_System");
    expect(out).toContain("[[Kaizen]]");
    // No self-link: the article's own bold title is not wrapped.
    expect(out).not.toContain("[[Toyota_Production_System");
  });

  it("only links the FIRST mention of a given article", () => {
    const articles = {
      Toyota_Production_System: `# Toyota Production System\n\nKaizen first. Then more Kaizen later.\n`,
      Kaizen: `# Kaizen\n\n**Kaizen**.\n`,
    };
    const out = linkBodyMentions(articles.Toyota_Production_System, indexOf(articles), "Toyota_Production_System");
    expect((out.match(/\[\[Kaizen\]\]/g) ?? []).length).toBe(1);
  });

  it("does NOT link partial words or code spans, and only the first occurrence", () => {
    const articles = {
      Lean: `# Lean\n\n**Lean**.\n`,
      Host: `# Host\n\nWe use Lean here. But Leanness and \`Lean\` are left alone.\n`,
    };
    const out = linkBodyMentions(articles.Host, indexOf(articles), "Host");
    // The bare word "Lean" links once; "Leanness" (partial) and the code span are untouched.
    expect(out).toContain("We use [[Lean]] here.");
    expect(out).toContain("Leanness");
    expect(out).toContain("`Lean`");
    expect((out.match(/\[\[Lean\]\]/g) ?? []).length).toBe(1);
  });

  it("treats a pre-existing [[link]] as already-linked (idempotent seed)", () => {
    const articles = {
      Lean: `# Lean\n\n**Lean**.\n`,
      Host: `# Host\n\nWe use Lean here, and [[Lean]] there.\n`,
    };
    const out = linkBodyMentions(articles.Host, indexOf(articles), "Host");
    // The stem is already linked, so the earlier bare "Lean" is left untouched.
    expect(out).toBe(articles.Host);
  });

  it("does NOT link a redlink to a non-existent article", () => {
    const articles = { Host: `# Host\n\nWe discussed Atlantis at length.\n` };
    const out = linkBodyMentions(articles.Host, indexOf(articles), "Host");
    expect(out).toBe(articles.Host); // nothing to link
  });
});

describe("rebuildArticleLinks — mentions feed See also", () => {
  it("a mentioned article appears inline AND in ## See also", async () => {
    const articles = {
      Toyota_Production_System: `# Toyota Production System\n\nThe system uses Kaizen.\n`,
      Kaizen: `# Kaizen\n\n**Kaizen**.\n`,
    };
    const r = await rebuildArticleLinks({
      content: articles.Toyota_Production_System,
      stem: "Toyota_Production_System",
      index: indexOf(articles),
      stems: new Set(Object.keys(articles)),
    });
    expect(r.mentioned).toEqual(["Kaizen"]);
    expect(r.seeAlso).toEqual(["Kaizen"]);
    expect(r.content).toContain("[[Kaizen]]");
    expect(r.content).toContain("## See also");
    expect(r.content).toContain("- [[Kaizen]]");
  });
});

describe("CO-OCCURRENCE edges (shared folded chunks)", () => {
  it("two articles sharing a folded chunk get a See also without a mention", async () => {
    const articles = {
      Alpha: `# Alpha\n\nA standalone subject with no cross mention.\n`,
      Beta: `# Beta\n\nAnother standalone subject.\n`,
    };
    const stemSet = new Set(Object.keys(articles));
    const store = new MemoryStore(":memory:");
    store.db.exec("PRAGMA foreign_keys = OFF");
    // One chunk folded into BOTH articles → they co-occur once.
    for (const stem of ["Alpha", "Beta"]) {
      store.db
        .query("INSERT INTO synthesized_chunk_sections (chunk_id, article_stem, section_anchor, synthesized_at) VALUES ('c1', ?, 'overview', 1)")
        .run(stem);
    }

    const co = coOccurrence(store, stemSet);
    expect(co.get("Alpha")).toEqual([{ stem: "Beta", count: 1 }]);

    const r = await rebuildArticleLinks({
      content: articles.Alpha,
      stem: "Alpha",
      index: indexOf(articles),
      stems: stemSet,
      related: co.get("Alpha") ?? [],
    });
    expect(r.mentioned).toEqual([]); // no inline mention
    expect(r.seeAlso).toEqual(["Beta"]); // but co-occurrence earns a See also
    expect(r.content).toContain("- [[Beta]]");
    store.close();
  });

  it("an optional model gate can veto an ambiguous (low-overlap) candidate", async () => {
    const articles = { Alpha: `# Alpha\n\nStandalone.\n`, Beta: `# Beta\n\nStandalone.\n` };
    const stemSet = new Set(Object.keys(articles));
    const r = await rebuildArticleLinks({
      content: articles.Alpha,
      stem: "Alpha",
      index: indexOf(articles),
      stems: stemSet,
      related: [{ stem: "Beta", count: 1 }], // below the strong threshold → ambiguous
      call: async () => "no",
    });
    expect(r.seeAlso).toEqual([]); // model said no
  });
});

describe("setSeeAlsoSection placement", () => {
  it("places ## See also after the body and before ## References", () => {
    const content = `# A\n\nLead.\n\n## Body\n\nText.\n\n## References\n\n[^1]: \`conv:00000000\` (2026-01-01, c) — x\n`;
    const out = setSeeAlsoSection(content, ["B"]);
    expect(out.indexOf("## Body")).toBeLessThan(out.indexOf("## See also"));
    expect(out.indexOf("## See also")).toBeLessThan(out.indexOf("## References"));
  });
});

describe("runLinkStage — end to end, idempotent, normalized", () => {
  it("links a vault, canonicalizes spaced links, and re-runs to a byte-identical no-op", async () => {
    const root = vaultWith({
      Toyota_Production_System: `# Toyota Production System\n\nThe system uses Kaizen. See [[Active Inference]] for the spaced-link case.\n`,
      Kaizen: `# Kaizen\n\n**Kaizen** is continuous improvement.\n`,
      Active_Inference: `# Active Inference\n\n**Active Inference**.\n`,
    });
    const store = new MemoryStore(":memory:");

    const r1 = await runLinkStage(store, { root, commit: false });
    expect(r1.linked).toContain("Toyota_Production_System");

    const tps = read(root, "Toyota_Production_System");
    expect(tps).toContain("[[Kaizen]]"); // mention linked
    expect(tps).toContain("[[Active_Inference]]"); // spaced link canonicalized by normalizeWikilinks
    expect(tps).not.toContain("[[Active Inference]]");
    expect(tps).toContain("## See also");

    // Re-run: a fully-linked vault is a byte-identical no-op.
    const before = read(root, "Toyota_Production_System");
    const r2 = await runLinkStage(store, { root, commit: false });
    expect(r2.linked).toEqual([]);
    expect(read(root, "Toyota_Production_System")).toBe(before);

    store.close();
  });
});

// ---- See-also singularity (the non-idempotent growth bug) -------------------

describe("setSeeAlsoSection removes EVERY existing ## See also", () => {
  it("collapses multiple See-also sections (any fence state) into exactly one", () => {
    const content =
      "# T\n\nLead.\n\n## Body\n\nProse.\n\n" +
      "## See also\n\n- [[A]]\n\n## See also\n\n- [[A]]\n\n## See also\n\n- [[A]]\n\n" +
      "## References\n\n[^1]: `conv:a1b2c3d4` — x\n";
    const out = setSeeAlsoSection(content, ["A", "B"]);
    expect((out.match(/^## See also$/gm) ?? []).length).toBe(1);
    expect(out).toContain("- [[A]]");
    expect(out).toContain("- [[B]]");
    // Placed before ## References.
    expect(out.indexOf("## See also")).toBeLessThan(out.indexOf("## References"));
  });

  it("removes a See-also buried under an unbalanced fence", () => {
    // ```py opens and never closes; the See-also below it would be read as code by
    // the fence-aware splitter, so the direct heading strip must still catch it.
    const content =
      "# T\n\nLead.\n\n## Code\n\n```py\nx=1\n\n## See also\n\n- [[A]]\n";
    const out = setSeeAlsoSection(content, ["A"]);
    expect((out.match(/^## See also$/gm) ?? []).length).toBe(1);
  });
});
