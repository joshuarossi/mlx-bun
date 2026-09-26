// mlx-bun memory — SECTION-ROUTE (P7-T1): chunk → article sections (M×N binary).
//
// The steady-state counterpart to ROUTE. ROUTE (route.ts) decides WHICH articles
// a chunk touches; SECTION-ROUTE decides, for each of those articles, WHICH
// section(s) the chunk should update — the join from a routed chunk to the
// concrete `[^N]`-patch targets P7-T2 then integrates.
//
// The shape is M×N binary, repurposed from lucien's `cluster-assign-recent.ts`
// ASSIGN_OR_PROPOSE_PROMPT + buildPrompt (assign-to-existing-or-propose-new), but
// decomposed into bounded single-section yes/no calls instead of one batched
// JSON object — the same capacity-by-decomposition the CREATE flow uses, and the
// same parseBinary gate ROUTE's disambiguation rides:
//
//   for each section S of article A (A already matched by ROUTE for this chunk):
//     "article title + S heading + S's first ~2 sentences + chunk label + 1-line
//      gist → Should this chunk update THIS section? yes/no"  (parseBinary)
//   if EVERY section said no AND the chunk is substantive for A:
//     "Name a new section (2–5 words) or NONE."  (parseLines)
//
// Hierarchical pruning is structural: the caller only ever hands us the articles
// ROUTE matched, so we never run the M×N grid over the whole vault. A chunk that
// fits no existing section yields a NAMED new section (P7-T2 creates it on patch),
// never a silent drop.
//
// The deterministic scaffolding (TOC iteration, section gists, new-section parse,
// the ledger write) is pure and unit-tested; only the binary/name calls touch the
// GPU, behind an injectable `call` seam so tests run model-free.

import { parseLead } from "./article";
import type { MemoryStore } from "./db";
import { callLocal, MAX_OUTPUT_TOKENS } from "./model";
import { parseBinary, parseLines } from "./parse";
import { extractSection, parseToc, slugifyHeading } from "./vault";

/** The synthetic anchor for an article's LEAD (its opening summary / verdict).
 *  The lead is not a `## heading` section, but it is where an entity's headline
 *  claim lives — so it is a first-class PATCH target: a correction that
 *  contradicts the verdict (a newer value reversing the lead's stated value)
 *  must rewrite the LEAD toward the latest, not leave it standing while only a
 *  body section is updated. SECTION-ROUTE offers the lead as a routable
 *  candidate; synthesize's patch path swaps exactly the lead bytes. */
export const LEAD_ANCHOR = "__lead__";

// ---- structural tail sections (never chunk-update targets) ------------------

/** Headings that are article scaffolding, not topical sections — a chunk never
 *  "updates" them, so they are excluded from the routable section set. */
const NON_TOPICAL_HEADINGS = new Set(["references", "see also", "notes"]);

// ---- section enumeration (pure) --------------------------------------------

/** One routable section of an article: its anchor, heading, and a short gist
 *  (the first ~2 sentences of its body) for the binary prompt. */
export interface SectionCandidate {
  anchor: string;
  heading: string;
  gist: string;
}

/** Strip a section body down to plain gist prose: drop the heading line, fenced
 *  blocks, footnote DEFINITION lines, list/quote markers, footnote MARKERS, and
 *  wikilink brackets, then collapse whitespace. Pure. */
function sectionBodyProse(section: string): string {
  const lines = section.split(/\r?\n/);
  const kept: string[] = [];
  let inFence = false;
  let first = true;
  for (const line of lines) {
    if (/^(```|~~~)/.test(line.trim())) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    if (first) {
      first = false; // the heading line itself
      continue;
    }
    const t = line.trim();
    if (!t) continue;
    if (/^\[\^[^\]]+\]:/.test(t)) continue; // footnote definition line
    kept.push(t.replace(/^[-*+>]\s+/, "").replace(/^\d+[.)]\s+/, ""));
  }
  return kept
    .join(" ")
    .replace(/\[\^[^\]]+\]/g, "") // footnote markers
    .replace(/\[\[([^\]|]+)(?:\|[^\]]+)?\]\]/g, "$1") // wikilinks → display text
    .replace(/[*_`]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

/** First `n` sentences of `text` (sentence = run ending in . ! or ?), falling
 *  back to a hard character cap so a punctuation-free body still yields a gist. */
export function firstSentences(text: string, n = 2, cap = 320): string {
  const s = text.trim();
  if (!s) return "";
  const parts = s.split(/(?<=[.!?])\s+/);
  const gist = parts.slice(0, n).join(" ").trim();
  return gist.length > cap ? gist.slice(0, cap).trim() : gist;
}

/**
 * Enumerate an article's routable sections from its markdown: every TOC heading
 * deeper than the H1 title, minus the non-topical tail (References / See also /
 * Notes), each carrying a ~2-sentence gist of its body. Pure — no model, no disk.
 */
export function articleSections(markdown: string): SectionCandidate[] {
  const out: SectionCandidate[] = [];
  const seen = new Set<string>();
  for (const entry of parseToc(markdown)) {
    if (entry.depth <= 1) continue; // the H1 title is not a section
    if (NON_TOPICAL_HEADINGS.has(entry.title.trim().toLowerCase())) continue;
    if (seen.has(entry.anchor)) continue;
    seen.add(entry.anchor);
    const body = extractSection(markdown, entry.anchor);
    const gist = body ? firstSentences(sectionBodyProse(body)) : "";
    out.push({ anchor: entry.anchor, heading: entry.title, gist });
  }
  return out;
}

/** The article's display title — its H1 if present, else the stem with `_`→space. */
export function articleTitle(markdown: string, stem: string): string {
  const h1 = parseToc(markdown).find((e) => e.depth === 1);
  return h1 ? h1.title : stem.replace(/_/g, " ");
}

/**
 * The article's LEAD as a routable section candidate (anchor {@link LEAD_ANCHOR}),
 * or null when the article has no lead prose. The gist is the lead's first ~2
 * sentences, footnote/wikilink-stripped — so the binary matcher can decide
 * whether a chunk's claim belongs in (and may CORRECT) the headline summary. Pure.
 */
export function leadCandidate(markdown: string): SectionCandidate | null {
  const lead = parseLead(markdown);
  if (!lead || !lead.trim()) return null;
  const prose = lead
    .replace(/\[\^[^\]]+\]/g, "") // footnote markers
    .replace(/\[\[([^\]|]+)(?:\|[^\]]+)?\]\]/g, "$1") // wikilinks → display text
    .replace(/[*_`]/g, "")
    .replace(/\s+/g, " ")
    .trim();
  return { anchor: LEAD_ANCHOR, heading: "Lead Summary", gist: firstSentences(prose) };
}

// ---- new-section parse (pure) ----------------------------------------------

/**
 * Parse the CREATE-NEW-SECTION reply into a clean 2–5-word section title, or
 * null when the model declined (NONE / empty) or the name is out of range.
 * Strips heading/bullet/quote markup so a stray `## ` or `- ` prefix is tolerated.
 */
export function parseNewSection(raw: string): { title: string; anchor: string } | null {
  const [line] = parseLines(raw);
  if (!line) return null;
  const title = line
    .replace(/^#{1,6}\s+/, "")
    .replace(/^[-*+>]\s+/, "")
    .replace(/^\d+[.)]\s+/, "")
    .replace(/[`*_]/g, "")
    .replace(/[.:;,]+$/, "")
    .trim();
  if (!title) return null;
  const words = title.split(/\s+/).filter(Boolean);
  if (words.length < 2 || words.length > 5) return null;
  return { title, anchor: slugifyHeading(title) };
}

// ---- prompt builders (pure, schematic — no parrot-able example values) ------

/**
 * Bounded binary: should THIS chunk update THIS section? Kept schematic on
 * purpose — no concrete example the small model could copy into its answer.
 *
 * Framed around the SUBJECT the heading names, NOT a value comparison: the small
 * model otherwise defaults to "no" whenever the note states a different value than
 * the section currently records (a newer value vs the section's older value), which
 * is exactly the correction we must catch. Empirically (e4b, maxTokens 4) this phrasing matches a
 * contradicting same-subject correction 3/3 while still declining off-topic and
 * cross-section notes; the chunk LABEL is deliberately omitted — including it
 * flipped the model back to value-comparison and dropped the match rate.
 */
export function buildSectionBinaryPrompt(
  title: string,
  section: SectionCandidate,
  chunkGist: string,
): string {
  return (
    `Article: "${title}"\n` +
    `Section heading: "${section.heading}"\n` +
    `What this section is about: ${section.gist || "(empty)"}\n\n` +
    `New note: ${chunkGist || "(none)"}\n\n` +
    `A note BELONGS in this section when it is about the SAME subject the heading ` +
    `names — the same preference, attribute, or topic — EVEN IF the note gives a ` +
    `different, newer, or contradicting value than the section currently records ` +
    `(a changed favourite is a correction to THIS section, not a new topic). It ` +
    `does NOT belong only if it is about a clearly different subject. Does the new ` +
    `note belong in the "${section.heading}" section? Answer yes or no.`
  );
}

/** CREATE-NEW-SECTION sub-task: name a section for a chunk that fit no existing
 *  one, or NONE. Lists the existing headings so the model proposes something new. */
export function buildNewSectionPrompt(
  title: string,
  existingHeadings: string[],
  chunkLabel: string | null,
  chunkGist: string,
): string {
  const existing = existingHeadings.length ? existingHeadings.map((h) => `- ${h}`).join("\n") : "(none)";
  return (
    `Article: "${title}"\n` +
    `Existing sections:\n${existing}\n\n` +
    `New note label: ${chunkLabel ?? "(none)"}\n` +
    `New note gist: ${chunkGist || "(none)"}\n\n` +
    `The new note does not fit any existing section above. If it is substantive ` +
    `enough to deserve its own section of this article, name that NEW section in ` +
    `2 to 5 words (a heading distinct from the ones listed). Otherwise answer NONE. ` +
    `Output only the section name or NONE.`
  );
}

// ---- model seam ------------------------------------------------------------

/** Per-call model seam (defaults to the local `section` stage). Injected by
 *  tests + the eval so the deterministic scaffolding runs with no GPU. */
export type SectionCall = (prompt: string, opts?: { maxTokens?: number }) => Promise<string>;

const defaultCall: SectionCall = (p, o) => callLocal("section", { user: p }, o);

// ---- routing inputs / outputs ----------------------------------------------

/** The chunk side of section routing: its id, label, and a 1-line gist. */
export interface SectionRouteChunk {
  id: string;
  label: string | null;
  /** A short, 1-line gist of the chunk's content (caller derives it). */
  gist: string;
}

/** The article side: its stem and current markdown (TOC + section bodies). */
export interface SectionRouteArticle {
  stem: string;
  content: string;
}

export interface SectionRouteResult {
  stem: string;
  /** Existing-section anchors the chunk should update (the patch targets). */
  matchedAnchors: string[];
  /** A newly-named section when no existing section fit AND the chunk is
   *  substantive for this article; null when it fit something or the model
   *  declined to name one. */
  newSection: { title: string; anchor: string } | null;
}

export interface SectionRouteOpts {
  /** Model-call override (tests/eval inject a fake). */
  call?: SectionCall;
  /** Whether the chunk is substantive for THIS article (gates the new-section
   *  sub-task on an all-no result). ROUTE already vouched the chunk is about the
   *  article, so this defaults to true. */
  substantive?: boolean;
}

/**
 * Route ONE chunk against ONE (ROUTE-matched) article's sections. Runs the M×N
 * grid's N binary calls for this article; if every section says no and the chunk
 * is substantive, runs the CREATE-NEW-SECTION sub-task. Returns the matched
 * existing anchors and/or a named new section. Pure w.r.t. disk.
 */
export async function routeSections(
  chunk: SectionRouteChunk,
  article: SectionRouteArticle,
  opts: SectionRouteOpts = {},
): Promise<SectionRouteResult> {
  const call = opts.call ?? defaultCall;
  const substantive = opts.substantive ?? true;
  const title = articleTitle(article.content, article.stem);
  const sections = articleSections(article.content);

  // The LEAD is a routable target too: a correction that contradicts the
  // headline claim must be able to rewrite the verdict, not just a body section.
  const lead = leadCandidate(article.content);
  const candidates = lead ? [lead, ...sections] : sections;

  const matchedAnchors: string[] = [];
  for (const section of candidates) {
    const yes = parseBinary(
      await call(buildSectionBinaryPrompt(title, section, chunk.gist), { maxTokens: MAX_OUTPUT_TOKENS }),
    );
    if (yes) matchedAnchors.push(section.anchor);
  }

  let newSection: { title: string; anchor: string } | null = null;
  if (matchedAnchors.length === 0 && substantive) {
    const raw = await call(
      buildNewSectionPrompt(title, sections.map((s) => s.heading), chunk.label, chunk.gist),
      { maxTokens: MAX_OUTPUT_TOKENS },
    );
    const named = parseNewSection(raw);
    // Guard against the model echoing an existing heading as its "new" name.
    if (named && !sections.some((s) => s.anchor === named.anchor)) newSection = named;
  }

  return { stem: article.stem, matchedAnchors, newSection };
}

/**
 * SECTION-ROUTE a chunk across the articles ROUTE matched for it — the hierarchical
 * pruning is exactly this: callers pass ONLY the matched articles, so the M×N grid
 * is bounded to (matched articles × their sections), never the whole vault.
 */
export async function routeChunkSections(
  chunk: SectionRouteChunk,
  routeMatchedArticles: SectionRouteArticle[],
  opts: SectionRouteOpts = {},
): Promise<SectionRouteResult[]> {
  const out: SectionRouteResult[] = [];
  for (const article of routeMatchedArticles) {
    out.push(await routeSections(chunk, article, opts));
  }
  return out;
}

// ---- ledger write ----------------------------------------------------------

/**
 * Persist a chunk's section routes to `chunk_sections` (the routing ledger P7-T2
 * patches from). Existing-section matches write their anchor; a named new section
 * writes its slug (the section P7-T2 will create). Idempotent via the table PK.
 * Returns the number of rows inserted (excluding PK collisions).
 */
export function persistSectionRoutes(
  store: MemoryStore,
  chunkId: string,
  results: SectionRouteResult[],
): number {
  const ins = store.db.query(
    "INSERT OR IGNORE INTO chunk_sections (chunk_id, article_stem, section_anchor) VALUES (?, ?, ?)",
  );
  let rows = 0;
  const tx = store.db.transaction(() => {
    for (const r of results) {
      for (const anchor of r.matchedAnchors) rows += ins.run(chunkId, r.stem, anchor).changes;
      if (r.newSection) rows += ins.run(chunkId, r.stem, r.newSection.anchor).changes;
    }
  });
  tx();
  return rows;
}
