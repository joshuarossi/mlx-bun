// The Dreaming — RECONCILE pass: the INFOBOX value is the consistency AUTHORITY.
// After a fold resolves the infobox relationship field (against the lead verdict),
// the LEAD and EVERY body section must AGREE with that ground-truth value — any
// passage still asserting a SUPERSEDED value as current is rewritten (constrained:
// "<ground-truth> is current, <old> is former"), with a deterministic check + one
// retry, provenance preserved.
//
// All reachable WITHOUT the GPU via injected value-aware fakes:
//   • a STALE article (infobox 35mm resolves to 50mm; a sibling section still says
//     35mm) → the field is refreshed AND the section is demoted to past tense, its
//     [^1] surviving;
//   • a LEAD that itself asserts BOTH values as current (the demo bug) → the lead is
//     demoted so only the ground-truth value is present, duplicate markers deduped;
//   • a CONSISTENT article → a byte-identical NO-OP (idempotent);
//   • a STUBBORN model that cannot demote → the original is kept and reported as
//     `unresolved` (honest, not a silent success);
//   • the pure deterministic helpers (assertsValueAsCurrent / dedupeAdjacentMarkers).

import { describe, expect, it, afterEach } from "bun:test";
import { mkdtemp, mkdir, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { MemoryStore } from "../src/memory/db";
import { checkFootnoteIntegrity, extractConvHashes } from "../src/memory/gate";
import { parseInfobox, parseLead } from "../src/memory/article";
import { extractSection } from "../src/memory/vault";
import {
  assertsValueAsCurrent,
  dedupeAdjacentMarkers,
  reconcileArticle,
  reconcileContent,
} from "../src/memory/reconcile";
import type { SynthesisCall } from "../src/memory/synthesize";

const STEM = "Focal_Length_Preference";

// Infobox favorite is the SUPERSEDED 35mm; the lead verdict is 50mm; the Background
// section still records 35mm — exactly what a verdict flip leaves behind.
const STALE = `# Focal Length Preference

\`\`\`info
type: preference
kind: thing
favorite_focal_length: 35mm
\`\`\`

**Focal Length Preference** — the user's current favorite is 50mm.[^2]

## Background

The user's favorite focal length is 35mm, the one they reach for.[^1]

## References

[^1]: \`conv:aaaa1111\` (2023-01-01, Early take)
[^2]: \`conv:bbbb2222\` (2025-01-01, Updated take)
`;

// The demo bug: the LEAD itself asserts BOTH 35mm (currently) AND 50mm (as of date)
// as current, and carries a duplicated [^2][^2] marker. Infobox still 35mm.
const LEAD_BUG = `# Focal Length Preference

\`\`\`info
type: preference
kind: thing
favorite_focal_length: 35mm
\`\`\`

**Focal Length Preference** — I currently consider 35mm to be my favorite[^1]; as of 2025-01-01 my favorite is 50mm[^2][^2].

## Preferred Focal Length

My current favorite focal length is 35mm[^1]; as of 2025-01-01 my favorite is 50mm[^2].

## References

[^1]: \`conv:aaaa1111\` (2023-01-01, Early take)
[^2]: \`conv:bbbb2222\` (2025-01-01, Updated take)
`;

// Everything already agrees on 50mm — a reconcile must do nothing.
const CONSISTENT = `# Focal Length Preference

\`\`\`info
type: preference
kind: thing
favorite_focal_length: 50mm
\`\`\`

**Focal Length Preference** — the user's current favorite is 50mm.[^2]

## Background

The user originally favored 35mm[^1]; their current pick is now 50mm.[^2]

## References

[^1]: \`conv:aaaa1111\` (2023-01-01, Early take)
[^2]: \`conv:bbbb2222\` (2025-01-01, Updated take)
`;

/** A value-aware fake that demotes cleanly: it refreshes a stale infobox fact to
 *  50mm, reports a passage stating 35mm-as-current as a conflict, and rewrites any
 *  passage to a clean "previously 35mm; now 50mm" (both markers kept). */
const cleanCall: SynthesisCall = async (prompt) => {
  // The CURRENT-STATE-ONLY rewrite (the LEAD path): drop 35mm, state only 50mm.
  if (prompt.includes("VALUE TO REMOVE")) {
    return "**Focal Length Preference** — the user's current favorite is 50mm[^2].";
  }
  // The constrained rewrite (ground-truth + superseded both named).
  if (prompt.includes("FORMER (SUPERSEDED) VALUE")) {
    return "Previously 35mm was my favorite[^1]; as of 2025-01-01 my current favorite is now 50mm[^2].";
  }
  // Conflict detection for an already-correct infobox field.
  if (prompt.includes("ESTABLISHED CURRENT VALUE")) {
    const body = prompt.split("ESTABLISHED CURRENT VALUE")[1] ?? "";
    return /35mm/.test(body) ? "35mm" : "KEEP";
  }
  // Infobox resolution vs the lead verdict.
  if (prompt.includes("INFOBOX FACT")) {
    const fact = prompt.split("INFOBOX FACT")[1] ?? "";
    return /50mm/.test(fact.split("If the fact")[0] ?? fact) ? "KEEP" : "50mm";
  }
  return "KEEP";
};

describe("reconcile — infobox is the authority; stale prose is demoted to past tense", () => {
  it("refreshes a 35mm infobox field and demotes the 35mm Background section to past", async () => {
    const res = await reconcileContent(STALE, { call: cleanCall, stem: STEM });

    expect(res.changed).toBe(true);
    expect(res.refreshedFields).toContain("favorite_focal_length");
    expect(res.rewrittenSections).toContain("background");
    expect(res.unresolved).toEqual([]);

    const box = parseInfobox(res.content)!;
    expect(box.fields.find((f) => f.key === "favorite_focal_length")!.value).toBe("50mm");

    // The section now reads 50mm as current and NO LONGER asserts 35mm as current,
    // while KEEPING its [^1] citation (provenance).
    const bg = extractSection(res.content, "background")!;
    expect(bg).toContain("50mm");
    expect(bg).toContain("[^1]");
    expect(assertsValueAsCurrent(bg, "35mm")).toBe(false);

    const hashes = extractConvHashes(res.content);
    expect(hashes.has("aaaa1111")).toBe(true);
    expect(hashes.has("bbbb2222")).toBe(true);
    expect(checkFootnoteIntegrity(res.content).ok).toBe(true);
    expect(res.gateVetoed).toBe(false);

    // A preference that CHANGED over time is an EVOLUTION: the trajectory is
    // PRESERVED in a `## History` section citing BOTH sources (history kept).
    expect(res.historyEntries.length).toBeGreaterThan(0);
    expect(res.content).toContain("## History");
    const hist = extractSection(res.content, "history")!;
    expect(hist).toContain("35mm");
    expect(hist).toContain("[^1]"); // the earlier source
    expect(hist).toContain("[^2]"); // the later source
  });

  it("EVOLUTION: cleans the LEAD to current-state-only AND preserves the trajectory in ## History", async () => {
    const res = await reconcileContent(LEAD_BUG, { call: cleanCall, stem: STEM });

    expect(res.changed).toBe(true);
    expect(res.rewrittenSections).toContain("lead");

    const lead = parseLead(res.content)!;
    // RULE 1: the lead is a CLEAN current-state summary — only 50mm, no scattered
    // "previously 35mm" caveat (the trajectory lives in History instead).
    expect(assertsValueAsCurrent(lead, "35mm")).toBe(false);
    expect(lead).toContain("50mm");
    expect(lead).not.toContain("35mm");
    // Duplicated [^2][^2] collapsed.
    expect(res.content).not.toContain("[^2][^2]");

    // History section records the change, both sources cited (history kept).
    expect(res.historyEntries.length).toBeGreaterThan(0);
    expect(res.content).toContain("## History");
    const hist = extractSection(res.content, "history")!;
    expect(hist).toContain("35mm");
    expect(hist).toContain("[^1]");
    expect(hist).toContain("[^2]");

    // Both citations survive; bijection intact.
    const hashes = extractConvHashes(res.content);
    expect(hashes.has("aaaa1111")).toBe(true);
    expect(hashes.has("bbbb2222")).toBe(true);
    expect(checkFootnoteIntegrity(res.content).ok).toBe(true);
  });

  it("is a NO-OP on an already-consistent article (byte-identical)", async () => {
    const res = await reconcileContent(CONSISTENT, { call: cleanCall, stem: STEM });
    expect(res.changed).toBe(false);
    expect(res.refreshedFields).toEqual([]);
    expect(res.rewrittenSections).toEqual([]);
    expect(res.content).toBe(CONSISTENT);
  });
});

// A FACTUAL ERROR (not an evolution): the infobox recorded a wrong status that the
// lead has since corrected. The wrong value must be SILENTLY overwritten — no
// History entry, the wrong value (and its now-orphaned citation) pruned entirely.
const ERROR_ARTICLE = `# Project Alpha

\`\`\`info
type: project
kind: thing
status: paused
\`\`\`

**Project Alpha** — the project is active.[^2]

## Background

The project status is paused.[^1]

## References

[^1]: \`conv:aaaa1111\` (2024-01-01, Misread status)
[^2]: \`conv:bbbb2222\` (2025-01-01, Correction)
`;

// Classifies the contradiction as ERROR, refreshes status→active, and rewrites the
// stale passage to state ONLY "active" — dropping "paused" and its [^1] citation.
const errorCall: SynthesisCall = async (prompt) => {
  if (prompt.includes("EARLIER value")) return "ERROR"; // the contradiction classifier
  if (prompt.includes("VALUE TO REMOVE")) return "The project is active.[^2]";
  if (prompt.includes("ESTABLISHED CURRENT VALUE")) {
    const body = prompt.split("ESTABLISHED CURRENT VALUE")[1] ?? "";
    return /paused/.test(body) ? "paused" : "KEEP";
  }
  if (prompt.includes("INFOBOX FACT")) {
    const fact = prompt.split("INFOBOX FACT")[1] ?? "";
    return /active/.test(fact.split("If the fact")[0] ?? fact) ? "KEEP" : "active";
  }
  return "KEEP";
};

describe("reconcile — a factual ERROR is silently overwritten (no History, wrong value gone)", () => {
  it("refreshes the field, removes the wrong value everywhere, writes NO ## History", async () => {
    const res = await reconcileContent(ERROR_ARTICLE, { call: errorCall, stem: "Project_Alpha" });

    expect(res.changed).toBe(true);
    expect(res.refreshedFields).toContain("status");
    // A factual error leaves NO trajectory behind.
    expect(res.historyEntries).toEqual([]);
    expect(res.content).not.toContain("## History");

    // The wrong value is gone as if it had never been there.
    expect(res.content).not.toContain("paused");
    const box = parseInfobox(res.content)!;
    expect(box.fields.find((f) => f.key === "status")!.value).toBe("active");

    // The corrected value survives; the wrong value's orphaned citation was pruned.
    const hashes = extractConvHashes(res.content);
    expect(hashes.has("bbbb2222")).toBe(true);
    expect(hashes.has("aaaa1111")).toBe(false);
    expect(checkFootnoteIntegrity(res.content).ok).toBe(true);
    expect(res.gateVetoed).toBe(false);
  });
});

// Infobox already correct (50mm) but a body section still asserts 35mm as current,
// and the model is STUBBORN — every rewrite keeps 35mm present. Reconcile must keep
// the original and report it as `unresolved`, never claim a false success.
const STALE_SECTION_ONLY = `# Focal Length Preference

\`\`\`info
type: preference
kind: thing
favorite_focal_length: 50mm
\`\`\`

**Focal Length Preference** — the user's current favorite is 50mm.[^2]

## Background

My current favorite focal length is 35mm, the one I reach for.[^1]; as of 2025-01-01 my favorite is 50mm[^2].

## References

[^1]: \`conv:aaaa1111\` (2023-01-01, Early take)
[^2]: \`conv:bbbb2222\` (2025-01-01, Updated take)
`;

const stubbornCall: SynthesisCall = async (prompt) => {
  if (prompt.includes("FORMER (SUPERSEDED) VALUE")) {
    // Refuses to demote — still asserts 35mm as the current favorite.
    return "My current favorite focal length is 35mm[^1]; as of 2025-01-01 my favorite is 50mm[^2].";
  }
  if (prompt.includes("ESTABLISHED CURRENT VALUE")) {
    const body = prompt.split("ESTABLISHED CURRENT VALUE")[1] ?? "";
    return /35mm/.test(body) ? "35mm" : "KEEP";
  }
  if (prompt.includes("INFOBOX FACT")) {
    const fact = prompt.split("INFOBOX FACT")[1] ?? "";
    return /50mm/.test(fact.split("If the fact")[0] ?? fact) ? "KEEP" : "50mm";
  }
  return "KEEP";
};

describe("reconcile — honest reporting when the small model cannot demote", () => {
  it("keeps the original + flags `unresolved` after the retry still asserts the stale value", async () => {
    const res = await reconcileContent(STALE_SECTION_ONLY, { call: stubbornCall, stem: STEM });
    expect(res.changed).toBe(false);
    expect(res.retried).toBe(true);
    expect(res.unresolved).toContain("background");
    // Untouched — the stale assertion is still present (NOT a silent rewrite).
    expect(res.content).toBe(STALE_SECTION_ONLY);
  });
});

describe("reconcile — deterministic helpers", () => {
  it("assertsValueAsCurrent flags a present-tense assertion, not a past-framed one", () => {
    expect(assertsValueAsCurrent("My current favorite is 35mm.", "35mm")).toBe(true);
    expect(assertsValueAsCurrent("35mm is the one I reach for.", "35mm")).toBe(true);
    expect(assertsValueAsCurrent("I currently consider 35mm to be my favorite.", "35mm")).toBe(true);
    // Past-framed in the same clause → not flagged.
    expect(assertsValueAsCurrent("Previously 35mm was my favorite; now 50mm.", "35mm")).toBe(false);
    expect(assertsValueAsCurrent("I originally favored 35mm.", "35mm")).toBe(false);
    expect(assertsValueAsCurrent("My current favorite is 50mm.", "35mm")).toBe(false);
  });

  it("dedupeAdjacentMarkers collapses repeated markers", () => {
    expect(dedupeAdjacentMarkers("the pick[^2][^2].")).toBe("the pick[^2].");
    expect(dedupeAdjacentMarkers("the pick[^2] [^2].")).toBe("the pick[^2].");
    expect(dedupeAdjacentMarkers("a[^1] b[^2].")).toBe("a[^1] b[^2].");
  });
});

const savedWiki = process.env.MLX_BUN_WIKI;
afterEach(() => {
  if (savedWiki === undefined) delete process.env.MLX_BUN_WIKI;
  else process.env.MLX_BUN_WIKI = savedWiki;
});

describe("reconcile — effectful entry writes the file + a ledger row, idempotent", () => {
  async function seed(content: string): Promise<{ root: string; store: MemoryStore }> {
    const root = await mkdtemp(join(tmpdir(), "dreaming-reconcile-"));
    await mkdir(join(root, "articles"), { recursive: true });
    await writeFile(join(root, "articles", `${STEM}.md`), content);
    process.env.MLX_BUN_WIKI = root;
    return { root, store: new MemoryStore(":memory:") };
  }

  it("reconciles on disk, records reconciled_articles, then a second pass is a NO-OP", async () => {
    const { root, store } = await seed(STALE);

    const first = await reconcileArticle(store, STEM, { root, call: cleanCall, commit: false });
    expect(first.reconciled).toBe(true);
    expect(first.refreshedFields).toContain("favorite_focal_length");
    expect(first.rewrittenSections).toContain("background");

    const afterFirst = await readFile(join(root, "articles", `${STEM}.md`), "utf8");
    expect(afterFirst).toContain("favorite_focal_length: 50mm");
    expect(afterFirst).toContain("[^1]");

    const ledger = store.db
      .query("SELECT article_stem, refreshed, rewritten FROM reconciled_articles")
      .all() as { article_stem: string; refreshed: string; rewritten: string }[];
    expect(ledger.length).toBe(1);
    expect(ledger[0]!.article_stem).toBe(STEM);
    expect(ledger[0]!.refreshed).toContain("favorite_focal_length");
    expect(ledger[0]!.rewritten).toContain("background");

    // Second pass — the article is now consistent, so nothing is written.
    const second = await reconcileArticle(store, STEM, { root, call: cleanCall, commit: false });
    expect(second.reconciled).toBe(false);
    const afterSecond = await readFile(join(root, "articles", `${STEM}.md`), "utf8");
    expect(afterSecond).toBe(afterFirst);

    store.close();
  });
});
