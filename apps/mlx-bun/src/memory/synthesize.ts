// mlx-bun memory — SYNTHESIZE / CREATE flow (P6-T3).
//
// The write pipeline's cold-start branch: turn an entity's accumulated chunks
// into a fresh Wikipedia-shaped article. Entered ONLY when the P1-T5/P5-T4
// CREATE rule fired for the entity (≥3 routed chunks, or ≥1 substantive
// ownership/decision chunk). The complementary UPDATE branch (fold one chunk
// into an existing section) is P7's section-patch — not built here.
//
// The decomposition is the whole point (capacity-by-decomposition): we NEVER
// hold a whole article in the model's head. CREATE is
//   sub-cluster → OUTLINE (a clean TOC of single-topic sections) → per-section
//   DRAFT (each section drafted from empty, the SAME bounded op as a patch) →
//   seed INFOBOX → assemble.
// Sharp section structure is the primary quality goal: the read path's
// TOC→section reads ride this outline.
//
// Citations are deterministic by construction (AI does judgment, CODE enforces
// invariants): we assign each source conversation a stable `[^N]` up front and
// generate the `## References` `[^N]:` definition lines ourselves in the fixed
// Lucien standard — `[^N]: `conv:HASH` (YYYY-MM-DD, source) — desc`, HASH = the
// first 8 lowercase hex of the conversation UUID with hyphens stripped. The
// model only PLACES the markers; it never writes a definition or invents a hash.
// This sidesteps the most common base-model defect (malformed/fabricated
// footnotes) entirely.
//
// Citation/wikilink rules are ported from lucien `scripts/synthesize.ts`
// (SYNTHESIS_PROMPT_BOOTSTRAP). Every CREATE output is run through the P6-T1
// gate (a weak pass → NO-OP, vault unchanged) and the P6-T2 NORMALIZE pass, then
// committed via `commitVault`; the integrated (chunk, section) edges are written
// to the `synthesized_chunk_sections` ledger.

import { mkdir, readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

import {
  articleStructure,
  fenceLabel,
  isFenceLine,
  parseInfobox,
  repairFences,
  type EntityKind,
} from "./article";
import { LEAD_ANCHOR } from "./cluster";
import type { MemoryStore } from "./db";
import { checkFootnoteIntegrity, gateEdit, type GateVerdict } from "./gate";
import {
  buildContradictionClassifierPrompt,
  classifyContradiction,
  type ContradictionKind,
} from "./history";
import { callLocal, MAX_OUTPUT_TOKENS } from "./model";
import { hasStubMarker, normalizeArticle } from "./normalize";
import { parseLines } from "./parse";
import { loadMetaPolicy } from "./prompts";
import {
  articlesDir,
  commitVault,
  extractSection,
  listArticles,
  parseToc,
  resolveWikilinkToStem,
  vaultRoot,
} from "./vault";

// ---- ported citation / wikilink rules (lucien SYNTHESIS_PROMPT_BOOTSTRAP) ----

/** Use ONLY content from the provided chunk(s); never copy names/values from these instructions. */
const NO_COPY_GUARD = `Use ONLY content from the provided chunk(s)/source notes below; never copy any name, value, or example from these instructions into the article.`;

/** Wikilink contract: exact stem, underscores, never the spaced phantom form. */
const WIKILINK_RULES = `WIKILINKS — link to OTHER ARTICLES below using the exact article stem, underscores not spaces: [[Exact_Stem]] or with display text [[Exact_Stem|display text]]. The spaced form [[Exact Stem]] resolves to nothing and creates a broken orphan link; it is forbidden. Only link to a stem that appears in OTHER ARTICLES.`;

/** Citation contract: place the GIVEN markers, never write defs or hashes. */
const CITATION_RULES = `CITATIONS — cite a substantive claim by placing one of the GIVEN footnote markers ([^1], [^2], …) immediately after it, e.g. "<claim>.[^1]". Two sources for one sentence: adjacent markers, no space — [^1][^2]. Reuse the same marker every time you cite that source. Do NOT write any footnote DEFINITION line, do NOT invent or guess a hash, do NOT emit a ## References section — the definitions are generated for you. NEVER fabricate a citation: an uncited true statement is fine, but only ever use a marker FROM THE LIST ABOVE — never a placeholder letter or any marker not in that list. FORBIDDEN — never emit HTML <sup>, #ref-/#cite- links, escaped [\\[1\\]] markers, or [[1]] wikilink markers; [^N] is the ONLY citation syntax.`;

/** Date contract (CREATE): every source note is tagged with its date. The model
 *  must treat the LATER-DATED note as the user's CURRENT position when notes
 *  conflict — chronology is a first-class signal, not just processing order. Kept
 *  schematic (no copyable concrete value) per the small-model parroting failure. */
const DATE_RESOLVE_RULES = `DATES — each source note below is tagged with its date in [YYYY-MM-DD] form (the same date that appears in its [^N] footnote). When two notes CONFLICT (a changed favourite, a reversed preference, an updated fact), the LATER-DATED note is the user's CURRENT position: resolve toward it. Write a superseded value as a past stage ("originally …, now …"), never as still-true.`;

// ---- conv:HASH + footnote scaffolding --------------------------------------

/** A filesystem-safe bare article stem from a free-form entity name: collapse
 *  whitespace to `_`, map path separators (a value containing `/`) and other
 *  filename-hostile characters to `-`, and strip leading dots, so a model-minted
 *  name like `<value>/<value>` yields a bare `<value>-<value>` stem (never a
 *  `articles/…` subpath). Stems with no separators are unchanged. The original
 *  surface survives as an `aliases:` entry, so name resolution still reaches the
 *  article. */
export function entityStem(entity: string): string {
  const stem = entity
    .trim()
    .replace(/[/\\]+/g, "-")
    .replace(/\s+/g, "_")
    .replace(/[<>:"|?*]+/g, "")
    .replace(/_+/g, "_")
    .replace(/^\.+/, "")
    .replace(/^[-_]+|[-_]+$/g, "");
  return stem || "entity";
}

/** The fixed Lucien `conv:HASH`: the first 8 lowercase hex digits of the
 *  conversation UUID with hyphens stripped (`<8hex>-<4hex>-…` → `<8hex>`). An
 *  already-8-char hex id passes through unchanged. */
export function convHash(conv: string): string {
  return conv.toLowerCase().replace(/[^0-9a-f]/g, "").slice(0, 8);
}

/** `YYYY-MM-DD` (UTC) from an epoch-millis timestamp; `undated` when missing. */
export function footnoteDate(ms: number | null | undefined): string {
  if (ms == null || !Number.isFinite(ms)) return "undated";
  return new Date(ms).toISOString().slice(0, 10);
}

/** The fixed Lucien footnote definition line for a source conversation as
 *  `[^n]: `conv:HASH` (YYYY-MM-DD, source)`. The single source of truth both
 *  CREATE (buildFootnoteMap) and PATCH (appendReferenceDef) generate defs from,
 *  so the model never writes — and cannot malform — a definition line. */
export function footnoteDefLine(n: number, conv: string, title: string, dateMs: number | null): string {
  const source = (title ?? "").trim() || "conversation";
  return `[^${n}]: \`conv:${convHash(conv)}\` (${footnoteDate(dateMs)}, ${source})`;
}

/** One source-conversation footnote: its stable per-article number, hash, and
 *  the generated `[^N]: `conv:HASH` (date, source)` definition line. */
export interface FootnoteEntry {
  conv: string;
  n: number;
  hash: string;
  source: string;
  def: string;
}

/** Assign each distinct source conversation a stable `[^N]` (first-appearance
 *  order across the entity's chunks) and pre-generate its definition line in the
 *  fixed Lucien standard. The model places these markers; it never writes defs. */
export function buildFootnoteMap(chunks: SynthesisChunk[]): {
  byConv: Map<string, FootnoteEntry>;
  entries: FootnoteEntry[];
} {
  const byConv = new Map<string, FootnoteEntry>();
  const entries: FootnoteEntry[] = [];
  for (const c of chunks) {
    if (byConv.has(c.conv)) continue;
    const n = entries.length + 1;
    const hash = convHash(c.conv);
    const source = (c.title ?? "").trim() || "conversation";
    const def = footnoteDefLine(n, c.conv, c.title, c.dateMs);
    const entry: FootnoteEntry = { conv: c.conv, n, hash, source, def };
    byConv.set(c.conv, entry);
    entries.push(entry);
  }
  return { byConv, entries };
}

// ---- chunk input -----------------------------------------------------------

/** One source chunk for synthesis: its id, conversation, reassembled text, and
 *  the metadata the footnote line needs. Text is NOT stored — the caller pulls
 *  it from `store.chunkText(id)`. */
export interface SynthesisChunk {
  id: string;
  conv: string;
  label: string | null;
  text: string;
  title: string;
  dateMs: number | null;
}

// ---- deterministic tokenizer (sub-clustering + see-also) -------------------

const TOK_STOP = new Set([
  "the", "a", "an", "and", "or", "of", "to", "for", "in", "on", "with", "is",
  "vs", "and", "its", "my", "your", "our", "their",
]);

function tokens(s: string): Set<string> {
  const out = new Set<string>();
  for (const t of s.toLowerCase().split(/[^a-z0-9]+/)) {
    if (t.length > 1 && !TOK_STOP.has(t)) out.add(t);
  }
  return out;
}

// ---- OUTLINE ---------------------------------------------------------------

const GENERIC_SECTION = new Set(["overview", "introduction", "summary", "details", "misc", "other"]);

/** Parse a model OUTLINE into clean single-topic section titles: strip bullet /
 *  heading / numbering markup, drop empties + bare generics, dedupe by anchor,
 *  cap at `max`. */
export function parseOutline(raw: string, max = 6): string[] {
  const seen = new Set<string>();
  const out: string[] = [];
  for (const line of parseLines(raw)) {
    const title = line
      .replace(/^#{1,6}\s+/, "")
      .replace(/^[-*+]\s+/, "")
      .replace(/^\d+[.)]\s+/, "")
      .replace(/[`*_]/g, "")
      .trim();
    if (!title) continue;
    const key = title.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(title);
    if (out.length >= max) break;
  }
  // An outline that is ONLY a generic single section is fine (→ stub); an empty
  // outline falls back to one "Overview" so we always draft something.
  if (out.length === 0) return ["Overview"];
  return out;
}

/** Anchor (heading slug) for a section title — must match vault.ts slugifyHeading
 *  so the read path's TOC→section anchors line up. */
export function sectionAnchor(title: string): string {
  return title
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

/**
 * Assign each chunk to the single best-matching section by label/text token
 * overlap (deterministic, GPU-free), so each section drafts only from its own
 * sub-topic chunks and the (chunk → section) edge is recorded. A chunk with no
 * overlap lands in the first section; sections that win no chunk are dropped by
 * the caller so we never draft an empty section.
 */
export function subClusterChunks(
  chunks: SynthesisChunk[],
  sections: string[],
): Map<string, SynthesisChunk[]> {
  const byAnchor = new Map<string, SynthesisChunk[]>();
  const sectionToks = sections.map((t) => ({ title: t, anchor: sectionAnchor(t), toks: tokens(t) }));
  for (const c of chunks) {
    const ctoks = tokens(`${c.label ?? ""} ${c.text.slice(0, 400)}`);
    let best = sectionToks[0]!;
    let bestScore = -1;
    for (const s of sectionToks) {
      let score = 0;
      for (const t of s.toks) if (ctoks.has(t)) score++;
      if (score > bestScore) {
        bestScore = score;
        best = s;
      }
    }
    const list = byAnchor.get(best.anchor) ?? [];
    list.push(c);
    byAnchor.set(best.anchor, list);
  }
  return byAnchor;
}

// ---- prompt builders -------------------------------------------------------

/** A `getOtherArticles`-style stem list (lucien synthesize.ts) so the model's
 *  [[wikilinks]] resolve to real articles. Capped to keep the prefill bounded. */
function otherArticlesBlock(stems: Iterable<string>, selfStem: string, cap = 200): string {
  const list = [...stems].filter((s) => s !== selfStem).sort((a, b) => a.localeCompare(b)).slice(0, cap);
  return list.length ? list.map((s) => `- ${s}`).join("\n") : "(none yet)";
}

/** Compact source block for the OUTLINE/INFOBOX/LEAD calls: each chunk DATE-TAGGED
 *  (so the model knows which note is most recent), its label + a short text excerpt
 *  (the model reads the gist, not the whole transcript). The `[YYYY-MM-DD]` tag is
 *  the same date carried in the chunk's `[^N]` footnote. */
function sourceDigest(chunks: SynthesisChunk[], perChunk = 600): string {
  return chunks
    .map(
      (c, i) =>
        `[${i + 1}] [${footnoteDate(c.dateMs)}] ${c.label ?? "(chunk)"}\n${c.text.slice(0, perChunk).trim()}`,
    )
    .join("\n\n");
}

function buildOutlinePrompt(entity: string, chunks: SynthesisChunk[], policy: string): string {
  return (
    `${policy}\n\n${NO_COPY_GUARD}\n\n` +
    `You are outlining a personal-wiki article about "${entity}". Below are the source notes (chunk label + excerpt). ` +
    `Propose a clean table of contents: 2 to 6 section headings, each a single sub-topic, in natural reading order. ` +
    `Each heading is 2–5 words, Title Case, specific (not "Overview"/"Details"). Output ONE heading per line, nothing else, NONE if there is only one sub-topic.\n\n` +
    `SOURCE NOTES:\n${sourceDigest(chunks)}\n`
  );
}

function buildLeadPrompt(
  entity: string,
  chunks: SynthesisChunk[],
  footnotes: Map<string, FootnoteEntry>,
  otherArticles: string,
  policy: string,
): string {
  return (
    `${policy}\n\n${NO_COPY_GUARD}\n\n${WIKILINK_RULES}\n\n${CITATION_RULES}\n\n${DATE_RESOLVE_RULES}\n\n` +
    `${footnoteList(chunks, footnotes)}\n\n` +
    `OTHER ARTICLES (link to these stems only):\n${otherArticles}\n\n` +
    `Write the LEAD for a personal-wiki article about "${entity}": 2–4 sentences, present tense, naming **${entity}** in bold in the first sentence, describing what it is AND how the user relates to it (uses / owns / chose / considered). Write in the THIRD PERSON, Wikipedia-style — NEVER the first person ("I", "my"); refer to the user in the third person ("the user"). When the notes disagree, frame the user's CURRENT position from the LATEST-DATED note. Output ONLY the lead prose — no heading, no list, no References.\n\n` +
    `SOURCE NOTES:\n${sourceDigest(chunks)}\n`
  );
}

function buildInfoboxPrompt(
  entity: string,
  kind: EntityKind,
  chunks: SynthesisChunk[],
  otherArticles: string,
  policy: string,
): string {
  return (
    `${policy}\n\n${NO_COPY_GUARD}\n\n${WIKILINK_RULES}\n\n` +
    `Produce the INFOBOX facts for a personal-wiki article about "${entity}". Output ONLY \`key: value\` lines, one per line, no fence, no prose. Rules:\n` +
    `- snake_case keys.\n` +
    `- A value that names another entity is a [[wikilink]] to a stem in OTHER ARTICLES (e.g. \`<entity_key>: [[Linked Entity]]\`).\n` +
    `- Include \`type:\` (the emergent label — a short free-form noun phrase) when clear.\n` +
    `- Include world-facts only if the notes support them; include relationship-facts (owned / acquired / used_for / chosen_over / opinion) the notes establish.\n` +
    `- Do NOT emit \`kind:\` or \`aliases:\` — those are added for you.\n` +
    `Emit nothing for a fact the notes do not support — never guess a spec.\n\n` +
    `OTHER ARTICLES (link targets):\n${otherArticles}\n\n` +
    `SOURCE NOTES:\n${sourceDigest(chunks)}\n`
  );
}

/** The "Cite source X as [^n]" lines for the chunks in one draft call. */
function footnoteList(chunks: SynthesisChunk[], footnotes: Map<string, FootnoteEntry>): string {
  const seen = new Set<number>();
  const lines: string[] = [];
  for (const c of chunks) {
    const e = footnotes.get(c.conv);
    if (!e || seen.has(e.n)) continue;
    seen.add(e.n);
    lines.push(`- [^${e.n}] = "${e.source}"`);
  }
  return lines.length
    ? `Cite sources with these footnote markers (use ONLY these):\n${lines.join("\n")}`
    : `(no citable sources for this section — leave it uncited)`;
}

function buildSectionPrompt(
  entity: string,
  sectionTitle: string,
  chunks: SynthesisChunk[],
  footnotes: Map<string, FootnoteEntry>,
  otherArticles: string,
  policy: string,
): string {
  const sources = chunks
    .map((c) => {
      const e = footnotes.get(c.conv);
      const tag = e ? `[^${e.n}]` : "(uncited)";
      return `SOURCE ${tag} [${footnoteDate(c.dateMs)}] — ${c.label ?? "chunk"}:\n${c.text.slice(0, 1400).trim()}`;
    })
    .join("\n\n---\n\n");
  return (
    `${policy}\n\n${NO_COPY_GUARD}\n\n${WIKILINK_RULES}\n\n${CITATION_RULES}\n\n${DATE_RESOLVE_RULES}\n\n` +
    `${footnoteList(chunks, footnotes)}\n\n` +
    `OTHER ARTICLES (link to these stems only):\n${otherArticles}\n\n` +
    `Draft ONLY the body of the "${sectionTitle}" section of the article about "${entity}". Factual prose in the THIRD PERSON, Wikipedia-style — NEVER the first person ("I", "my"); refer to the user in the third person ("the user"). These articles document what the user thinks, so they are NOT neutral: capture the user's positions and opinions accurately. Preserve specifics, and when two sources conflict fold the correction toward the user's LATEST-DATED position. Output ONLY this section's prose — do NOT repeat the "## ${sectionTitle}" heading, do NOT write other sections, do NOT write a References section.\n\n` +
    `SOURCE MATERIAL:\n${sources}\n`
  );
}

// ---- model-output sanitizers -----------------------------------------------

/**
 * Meta / planning / refusal phrasings — the base model narrating ABOUT the task
 * instead of writing the article body. A hit on any one rejects the draft (the
 * real defect: a section body that literally read "The user is asking to draft
 * the body prose for the <section name> section. The source material
 * discusses: 1. …"). Tuned to NOT fire on legitimate personal-wiki prose, which
 * IS about the user ("the user owned…", "the user weighed…").
 */
const LEAK_PATTERNS: RegExp[] = [
  /\bthe user (is asking|is requesting|wants me|asked me|requests|would like me|needs me|wanted me)\b/i,
  /\bthe source material\b/i,
  /\bthe source notes?\b/i,
  /\bsource material discusses\b/i,
  /\bbased on the (source|provided|notes|material)\b/i,
  /\bdraft the body\b/i,
  /\bbody prose for\b/i,
  /\bfor the [^.\n]{0,40} section\b/i,
  /\bi need to\b/i,
  /\bi (will|shall) (draft|write|now|create|provide|outline|summarize)\b/i,
  /\bi'?ll (draft|write|provide|outline|summarize)\b/i,
  /\blet (me|us|'?s) (draft|write|outline|provide|start|begin|summarize)\b/i,
  /\bhere ?(is|'?s) (the|a|my) (article|section|lead|prose|draft|body)\b/i,
  /\bas an ai\b/i,
  /\bi (cannot|can'?t|can not)\b/i,
  /\bi'?m sorry\b/i,
  /\bi am sorry\b/i,
  /\bi apologize\b/i,
  /\bi (do not|don'?t) have (enough|sufficient|any)\b/i,
  /\bi'?m (unable|not able)\b/i,
  /\bi am (unable|not able)\b/i,
  /\bsorry,?\s+(i|but)\b/i,
];

/**
 * True when a drafted body is meta-commentary, a plan, or a refusal rather than
 * article prose. Heuristic: any {@link LEAK_PATTERNS} hit, OR a leading
 * numbered/bulleted PLAN that restates the task. Pure; empty text is not leaky.
 */
export function isLeakyDraft(text: string): boolean {
  const s = text.trim();
  if (!s) return false;
  for (const re of LEAK_PATTERNS) if (re.test(s)) return true;
  // A leading numbered/bulleted PLAN that restates the task ("1. discuss the
  // <subject>, 2. the <subject>") — a list item FIRST, plus task-restating vocabulary.
  const firstLine = s.split("\n").map((l) => l.trim()).find((l) => l.length > 0) ?? "";
  if (
    /^(\d+[.)]|[-*+])\s+/.test(firstLine) &&
    /\b(draft|discuss|summariz|describe the|outline|restate|the user|source material)\b/i.test(s)
  ) {
    return true;
  }
  return false;
}

/** Remove any model-emitted fenced ```info block from drafted text so the only
 *  infobox in the final article is the ONE code-constructed block. A fenced info
 *  block is a ``` fence whose info string is exactly `info`. */
export function stripFencedInfoBlocks(text: string): string {
  const lines = text.split("\n");
  const out: string[] = [];
  let i = 0;
  while (i < lines.length) {
    if (isFenceLine(lines[i]!) && fenceLabel(lines[i]!) === "info") {
      i++; // skip the opening ```info
      while (i < lines.length && !isFenceLine(lines[i]!)) i++;
      if (i < lines.length) i++; // skip the closing fence
      continue;
    }
    out.push(lines[i]!);
    i++;
  }
  return out.join("\n");
}

/** Count fenced ```info blocks in an article (the single-infobox invariant). */
export function countFencedInfoBlocks(content: string): number {
  let count = 0;
  let inFence = false;
  for (const line of content.split(/\r?\n/)) {
    if (isFenceLine(line)) {
      if (!inFence && fenceLabel(line) === "info") count++;
      inFence = !inFence;
    }
  }
  return count;
}

/** Strip code fences, a repeated section heading, any model-emitted References /
 *  definition lines, a stray model-emitted infobox, and surrounding blank lines
 *  from a drafted section body. */
export function sanitizeSection(raw: string, title: string): string {
  let s = stripFencedInfoBlocks(raw.trim()).trim();
  s = s.replace(/^```[a-z]*\s*\n/i, "").replace(/\n```\s*$/i, "").trim();
  // Drop any NON-numeric footnote marker (e.g. a parroted `[^N]` placeholder from
  // the citation contract). Only `[^<digits>]` is a real, code-assigned marker.
  s = s.replace(/ ?\[\^[^\]\d][^\]]*\]/g, "");
  const wanted = title.trim().toLowerCase();
  const kept: string[] = [];
  let dropping = false;
  for (const line of s.split("\n")) {
    const t = line.trim();
    const h = /^(#{1,6})\s+(.+)$/.exec(t);
    if (h) {
      const ht = h[2]!.trim().toLowerCase();
      if (ht === wanted) continue; // model repeated our heading
      if (ht === "references" || ht === "see also" || ht === "notes") {
        dropping = true; // model spilled trailing meta sections — cut them
        continue;
      }
    }
    if (dropping) continue;
    if (/^\[\^\d+\]:/.test(t)) continue; // a stray definition line — we own defs
    kept.push(line);
  }
  // A drafted section that opened a ``` fence but never closed it would, once
  // assembled, swallow every trailing section (## References / ## See also) of
  // the WHOLE article. Balance the section's fences before it reaches assembly.
  return repairFences(kept.join("\n").trim()).content.trim();
}

/** Strip fences / a leading heading / a stray infobox from a drafted lead,
 *  collapse to prose. */
export function sanitizeLead(raw: string): string {
  let s = stripFencedInfoBlocks(raw.trim()).trim();
  s = s.replace(/^```[a-z]*\s*\n/i, "").replace(/\n```\s*$/i, "").trim();
  s = s.replace(/ ?\[\^[^\]\d][^\]]*\]/g, ""); // drop parroted non-numeric markers
  const lines = s.split("\n").filter((l) => !/^#{1,6}\s+/.test(l.trim()) && !/^\[\^\d+\]:/.test(l.trim()));
  // Balance any unclosed ``` so a lead fence can't swallow the rest of the article.
  return repairFences(lines.join("\n").trim()).content.trim();
}

/**
 * Physical spec-sheet keys describing a concrete object's hardware. They belong
 * on a `thing` (a concrete named object) and must NEVER bleed onto a broad
 * `domain` / `standard` / `person` / `project` entity — the policy-example
 * parroting bug, where a broad DOMAIN article inherited a hardware spec key.
 * Grounding the infobox in the entity's own kind blocks the leak deterministically.
 */
export const PHYSICAL_SPEC_KEYS = new Set([
  "mount", "sensor", "sensor_size", "focal_length", "aperture", "format",
  "resolution", "megapixels", "coverage", "compatible_with", "lens_mount",
]);

/**
 * Parse model `key: value` lines into a clean info-block field list. Keeps only
 * snake_case keys with a non-empty value (first occurrence wins), drops any
 * model-supplied `kind`/`aliases` (we own those) and any physical-spec key that
 * is ungrounded for this entity kind (a world-fact spec key on a `domain` is a
 * parroted example, never a fact), then prepends `type:` (if any), the declared `kind:`,
 * and appends `aliases:` when we have them. Always returns at least the `kind:`
 * line, so the article always has a parseable infobox.
 */
export function buildInfoboxFields(raw: string, kind: EntityKind, aliases: string[] = []): string[] {
  const fields = new Map<string, string>();
  for (const line of raw.split("\n")) {
    const t = line.trim().replace(/^[-*+]\s+/, "");
    const idx = t.indexOf(":");
    if (idx <= 0) continue;
    const key = t.slice(0, idx).trim();
    const value = t.slice(idx + 1).trim();
    if (!/^[a-z][a-z0-9_]*$/.test(key)) continue;
    if (!value) continue;
    if (key === "kind" || key === "aliases") continue;
    // Ground the box in the entity's kind: a hardware spec on a non-`thing`
    // entity is a parroted example, not a fact established by its chunks.
    if (kind !== "thing" && PHYSICAL_SPEC_KEYS.has(key)) continue;
    if (!fields.has(key)) fields.set(key, value);
  }
  const lines: string[] = [];
  const type = fields.get("type");
  if (type) lines.push(`type: ${type}`);
  lines.push(`kind: ${kind}`);
  for (const [k, v] of fields) {
    if (k === "type") continue;
    lines.push(`${k}: ${v}`);
  }
  const cleanAliases = [...new Set(aliases.map((a) => a.trim()).filter(Boolean))];
  if (cleanAliases.length) lines.push(`aliases: ${cleanAliases.join(", ")}`);
  return lines;
}

// ---- assembly --------------------------------------------------------------

export interface AssembledSection {
  title: string;
  anchor: string;
  body: string;
}

/** Distinct wikilink targets in `text` that resolve to a known stem (excluding
 *  self / Category: / conv:) — the See also list, sorted. */
export function deriveSeeAlso(text: string, stems: Set<string>, selfStem: string): string[] {
  const out = new Set<string>();
  for (const m of text.matchAll(/\[\[([^\]]+?)\]\]/g)) {
    const inner = m[1]!.split("|")[0]!.split("#")[0]!.trim();
    if (!inner || /^conv:/i.test(inner) || /^Category:/i.test(inner)) continue;
    const r = resolveWikilinkToStem(inner, stems);
    if (r && r !== selfStem) out.add(r);
  }
  return [...out].sort((a, b) => a.localeCompare(b));
}

/** Compose the fixed article skeleton from its parts. `## See also` /
 *  `## References` are emitted only when non-empty; References is always last. */
export function assembleArticle(parts: {
  stem: string;
  infoboxFields: string[];
  lead: string;
  sections: AssembledSection[];
  seeAlso: string[];
  referenceDefs: string[];
}): string {
  const title = parts.stem.replace(/_/g, " ");
  const out: string[] = [`# ${title}`, ""];
  if (parts.infoboxFields.length) {
    out.push("```info", ...parts.infoboxFields, "```", "");
  }
  if (parts.lead.trim()) out.push(parts.lead.trim(), "");
  for (const s of parts.sections) {
    if (!s.body.trim()) continue;
    out.push(`## ${s.title}`, "", s.body.trim(), "");
  }
  if (parts.seeAlso.length) {
    out.push("## See also", "", ...parts.seeAlso.map((s) => `- [[${s}]]`), "");
  }
  if (parts.referenceDefs.length) {
    out.push("## References", "", ...parts.referenceDefs, "");
  }
  const assembled = out.join("\n").replace(/\n{3,}/g, "\n\n").trimEnd() + "\n";
  // Final assembly guard: a drafted section may still carry an unbalanced ``` that
  // the per-section sanitizer missed; never emit an article whose fences are odd
  // (it would read its own trailing ## References / ## See also as code). Closing
  // the dangling fence before the first heading it would swallow keeps every
  // trailing section a recognized heading.
  const repaired = repairFences(assembled).content;
  return repaired.replace(/\n{3,}/g, "\n\n").trimEnd() + "\n";
}

/** Distinct `[^N]` marker numbers present in body prose (definition lines and
 *  fenced blocks excluded — markers live in prose). */
function usedMarkers(text: string): Set<number> {
  const used = new Set<number>();
  for (const line of text.split("\n")) {
    if (/^\[\^\d+\]:/.test(line.trim())) continue;
    for (const m of line.matchAll(/\[\^(\d+)\]/g)) used.add(parseInt(m[1]!, 10));
  }
  return used;
}

/** Count sections (by the parsed skeleton) whose body carries ≥1 footnote
 *  marker — the "≥1 cited section" acceptance signal. */
export function countCitedSections(content: string): number {
  const items = articleStructure(content);
  const lines = content.split(/\r?\n/);
  let cited = 0;
  for (const it of items) {
    if (it.kind !== "section") continue;
    const body = lines.slice(it.startLine - 1, it.endLine).join("\n");
    if (/\[\^\d+\](?!:)/.test(body)) cited++;
  }
  return cited;
}

// ---- CREATE (pure-ish: model via deps, no disk writes) ---------------------

/** Per-stage model call seam (defaults to the local synthesis stage). Injected
 *  by tests so the deterministic scaffolding runs with no GPU. */
export type SynthesisCall = (prompt: string, opts?: { maxTokens?: number }) => Promise<string>;

/** Retry instruction when a draft leaks meta/planning/refusal text. */
const ANTI_LEAK_HINT =
  "Output ONLY the article prose for this section — no preamble, no meta-commentary, no plan, no restating the task.";

/**
 * Draft prose that is NOT meta/planning/refusal leakage: draft once; if the
 * sanitized body is {@link isLeakyDraft}, retry ONCE with a sharper instruction;
 * if it still leaks, return "" so the caller DROPS the section rather than
 * emitting garbage. The sanitizer (section vs lead) is injected.
 */
async function draftCleanProse(
  call: SynthesisCall,
  prompt: string,
  opts: { maxTokens?: number },
  sanitize: (raw: string) => string,
): Promise<string> {
  let out = sanitize(await call(prompt, opts));
  if (!isLeakyDraft(out)) return out;
  out = sanitize(await call(`${prompt}\n\n${ANTI_LEAK_HINT}`, opts));
  return isLeakyDraft(out) ? "" : out;
}

export interface CreateDeps {
  /** Model call; defaults to `callLocal("synthesis", …)`. */
  call?: SynthesisCall;
  /** Other article stems (for wikilink resolution); defaults to the vault list. */
  stems?: Set<string>;
  /** Declared aliases to seed the infobox `aliases:` line. */
  aliases?: string[];
  /** Pre-existing article content for the gate's `before` (CREATE: ""). */
  before?: string;
}

export interface CreateOutcome {
  entity: string;
  stem: string;
  /** Final post-NORMALIZE markdown, or null when the gate vetoed the write. */
  content: string | null;
  action: "created" | "skipped";
  /** Gate reason when skipped; null on success. */
  reason: string | null;
  /** (chunk_id, section_anchor) edges for the `synthesized_chunk_sections` ledger. */
  chunkSections: { chunkId: string; anchor: string }[];
  sectionAnchors: string[];
  citedSections: number;
  hasInfobox: boolean;
  stub: boolean;
  normalizeNotes: string[];
}

/**
 * Build ONE entity article from its accumulated chunks, end to end:
 * sub-cluster → OUTLINE → per-section DRAFT → seed INFOBOX → assemble →
 * NORMALIZE → gate. Returns the final content (or null when the gate vetoes a
 * weak pass). Pure with respect to disk — the caller persists.
 */
export async function createArticle(
  entity: string,
  kind: EntityKind,
  chunks: SynthesisChunk[],
  deps: CreateDeps = {},
): Promise<CreateOutcome> {
  const call: SynthesisCall = deps.call ?? ((p, o) => callLocal("synthesis", { user: p }, o));
  const stem = entityStem(entity);
  const stems = new Set(deps.stems ?? []);
  stems.add(stem);
  const otherArticles = otherArticlesBlock(stems, stem);
  const policy = loadMetaPolicyQuiet(["Article_Conventions", "Infobox_Schemas", "Entities"]);
  const { byConv, entries } = buildFootnoteMap(chunks);

  // OUTLINE → sections; assign chunks; drop sections that won no chunk.
  const outline = parseOutline(await call(buildOutlinePrompt(entity, chunks, policy), { maxTokens: MAX_OUTPUT_TOKENS }));
  const clustered = subClusterChunks(chunks, outline);
  const sections: AssembledSection[] = [];
  const chunkSections: { chunkId: string; anchor: string }[] = [];
  for (const title of outline) {
    const anchor = sectionAnchor(title);
    const secChunks = clustered.get(anchor);
    if (!secChunks || secChunks.length === 0) continue;
    const body = await draftCleanProse(
      call,
      buildSectionPrompt(entity, title, secChunks, byConv, otherArticles, policy),
      { maxTokens: MAX_OUTPUT_TOKENS },
      (raw) => sanitizeSection(raw, title),
    );
    // A leaky draft survives to "" after one retry — DROP the section (and its
    // chunk edges); never emit meta/planning/refusal prose into the article.
    if (!body.trim()) continue;
    sections.push({ title, anchor, body });
    for (const c of secChunks) chunkSections.push({ chunkId: c.id, anchor });
  }

  // LEAD + INFOBOX (bounded, single-purpose calls). The lead runs the same
  // leak-rejection so a refusal/plan never lands as the article's abstract.
  const lead = await draftCleanProse(
    call,
    buildLeadPrompt(entity, chunks, byConv, otherArticles, policy),
    { maxTokens: MAX_OUTPUT_TOKENS },
    sanitizeLead,
  );
  const infoboxFields = buildInfoboxFields(
    await call(buildInfoboxPrompt(entity, kind, chunks, otherArticles, policy), { maxTokens: MAX_OUTPUT_TOKENS }),
    kind,
    deps.aliases ?? [],
  );

  // References: only the defs whose marker the model actually placed.
  const bodyForMarkers = [lead, ...sections.map((s) => s.body)].join("\n");
  const used = usedMarkers(bodyForMarkers);
  const referenceDefs = entries.filter((e) => used.has(e.n)).map((e) => e.def);

  const seeAlso = deriveSeeAlso([infoboxFields.join("\n"), bodyForMarkers].join("\n"), stems, stem);

  const raw = assembleArticle({ stem, infoboxFields, lead, sections, seeAlso, referenceDefs });

  // NORMALIZE (footnote bijection + renumber, wikilink canonicalization, infobox
  // sort, structural guards, {{stub}} for thin), then the conservative gate.
  const norm = normalizeArticle(raw, { stem, stems });

  const base: Omit<CreateOutcome, "content" | "action" | "reason"> = {
    entity,
    stem,
    chunkSections,
    sectionAnchors: sections.map((s) => s.anchor),
    citedSections: countCitedSections(norm.content),
    hasInfobox: parseInfobox(norm.content) != null,
    stub: hasStubMarker(norm.content),
    normalizeNotes: norm.notes,
  };

  // Defect-2: every committed article MUST be footnote-bijective. NORMALIZE
  // already repairs (drops orphan markers, renumbers, merges dup defs); if the
  // result is STILL broken (an unrepairable malformed citation), veto the write
  // rather than commit a citation-broken article.
  const fn = checkFootnoteIntegrity(norm.content);
  if (!fn.ok) {
    return { ...base, content: null, action: "skipped", reason: `footnote bijection unrepairable: ${fn.errors.join("; ")}` };
  }

  // Defect-3: exactly ONE infobox — the code-constructed block. Drafted info
  // blocks are stripped in sanitizeSection/sanitizeLead; this asserts they were,
  // so a parroted second infobox can never reach the vault.
  const infoboxCount = countFencedInfoBlocks(norm.content);
  if (infoboxCount > 1) {
    return { ...base, content: null, action: "skipped", reason: `multiple infoboxes (${infoboxCount})` };
  }

  const verdict: GateVerdict = gateEdit(deps.before ?? "", norm.content);
  if (!verdict.ok) {
    return { ...base, content: null, action: "skipped", reason: verdict.reason };
  }
  return { ...base, content: norm.content, action: "created", reason: null };
}

/** `loadMetaPolicy` that never throws — a missing Meta page yields an empty
 *  policy block so a fixture/smoke vault without seeded Meta still drafts. */
function loadMetaPolicyQuiet(names: string[]): string {
  try {
    return loadMetaPolicy(names);
  } catch {
    return "";
  }
}

// ---- effectful entry: CREATE into the vault + ledger -----------------------

export interface SynthesizeResult {
  created: boolean;
  stem: string;
  skippedByGate: boolean;
  reason: string | null;
  hasInfobox: boolean;
  citedSections: number;
  sectionAnchors: string[];
}

export interface SynthesizeCreateOpts {
  entity: string;
  kind?: EntityKind;
  /** The entity's accumulated chunk ids (the CREATE rule already fired). */
  chunkIds: string[];
  /** Vault root (honors MLX_BUN_WIKI); defaults to `vaultRoot()`. */
  root?: string;
  /** Declared aliases for the infobox. */
  aliases?: string[];
  /** Model-call override (tests inject a fake). */
  call?: SynthesisCall;
  /** Skip the git commit (tests). */
  commit?: boolean;
  now?: number;
}

/** Read the chunk + its conversation metadata into a {@link SynthesisChunk}. */
export function loadSynthesisChunk(store: MemoryStore, chunkId: string): SynthesisChunk | null {
  const row = store.db
    .query(
      "SELECT c.id, c.conv, c.label, conv.title, conv.updated_at FROM chunks c " +
        "JOIN conversations conv ON conv.conv = c.conv WHERE c.id = ?",
    )
    .get(chunkId) as
    | { id: string; conv: string; label: string | null; title: string | null; updated_at: number | null }
    | null;
  if (!row) return null;
  return {
    id: row.id,
    conv: row.conv,
    label: row.label,
    text: store.chunkText(chunkId),
    title: row.title ?? "",
    dateMs: row.updated_at,
  };
}

/**
 * CREATE an entity article from its chunks and persist it: draft via
 * {@link createArticle}, write the markdown to the vault (unless the gate vetoed
 * it), commit via `commitVault`, and record the integrated (chunk, section)
 * edges in `synthesized_chunk_sections`. The CREATE decision itself is upstream
 * (ROUTE's B8/P1-T5 gate) — this assumes the entity earned its article.
 */
export async function synthesizeCreate(
  store: MemoryStore,
  opts: SynthesizeCreateOpts,
): Promise<SynthesizeResult> {
  const root = opts.root ?? vaultRoot();
  const stem = entityStem(opts.entity);
  const chunks: SynthesisChunk[] = [];
  for (const id of opts.chunkIds) {
    const c = loadSynthesisChunk(store, id);
    if (c) chunks.push(c);
  }

  const stems = new Set(await listArticles(root));
  const outcome = await createArticle(opts.entity, opts.kind ?? "thing", chunks, {
    call: opts.call,
    stems,
    aliases: opts.aliases,
  });

  const result: SynthesizeResult = {
    created: outcome.action === "created",
    stem,
    skippedByGate: outcome.action === "skipped",
    reason: outcome.reason,
    hasInfobox: outcome.hasInfobox,
    citedSections: outcome.citedSections,
    sectionAnchors: outcome.sectionAnchors,
  };

  if (outcome.action !== "created" || outcome.content == null) return result;

  // Write the article, then record the integration ledger + commit.
  const dir = articlesDir(root);
  await mkdir(dir, { recursive: true });
  const path = join(dir, `${stem}.md`);
  // Never clobber an existing article from the CREATE branch — that's UPDATE's job.
  if (await fileExists(path)) {
    result.created = false;
    result.skippedByGate = false;
    result.reason = "article already exists (CREATE is for new entities)";
    return result;
  }
  await writeFile(path, outcome.content);

  const now = opts.now ?? Date.now();
  const insSec = store.db.query(
    "INSERT OR IGNORE INTO chunk_sections (chunk_id, article_stem, section_anchor) VALUES (?, ?, ?)",
  );
  const insSynth = store.db.query(
    "INSERT OR REPLACE INTO synthesized_chunk_sections " +
      "(chunk_id, article_stem, section_anchor, synthesized_at) VALUES (?, ?, ?, ?)",
  );
  const tx = store.db.transaction((rows: { chunkId: string; anchor: string }[]) => {
    for (const r of rows) {
      insSec.run(r.chunkId, stem, r.anchor);
      insSynth.run(r.chunkId, stem, r.anchor, now);
    }
  });
  tx(outcome.chunkSections);

  if (opts.commit !== false) {
    await commitVault(root, `memory: create ${stem} (${outcome.chunkSections.length} chunk edges)`);
  }

  return result;
}

async function fileExists(path: string): Promise<boolean> {
  try {
    await readFile(path);
    return true;
  } catch {
    return false;
  }
}

// ===========================================================================
// PATCH — the UPDATE branch (P7-T2): fold ONE chunk into ONE existing section.
//
// The steady-state counterpart to CREATE. Where CREATE drafts a whole article
// from an entity's cold-start chunks, PATCH is the same bounded section-draft op
// run against an article that already exists: integrate THIS chunk into THIS
// (SECTION-ROUTE-chosen) section, citing it, changing nothing else. It is the
// self-healing mechanism — a user's in-conversation CORRECTION is just an
// ordinary chunk, so folding it rewrites the contradicted claim TOWARD the
// user's latest position (resolve-to-latest, not append-both, not ignore).
//
// Citations stay deterministic by construction exactly as in CREATE: the chunk's
// source conversation is assigned a stable `[^N]` (a re-cited conversation
// reuses its existing marker; a new one mints `maxN+1`) and we GENERATE the
// `[^N]:` definition line — the model only PLACES the marker. We swap only the
// target section's bytes via `extractSection`/`replaceSection` (every other
// section stays byte-identical) and append the def to `## References`, then run
// the SAME gate (weak → NO-OP, the vault is untouched and the chunk retries next
// run) + NORMALIZE as CREATE. Idempotency rides `synthesized_chunk_sections`'s PK
// — a second fold of the same (chunk, article, section) writes nothing.
// ===========================================================================

/** The article's H1 title (depth-1 TOC heading), or a neutral fallback. */
function articleH1Title(article: string): string {
  const h1 = parseToc(article).find((e) => e.depth === 1);
  return h1 ? h1.title : "this article";
}

/**
 * The article's current footnote state: the highest `[^N]` number in use
 * (markers ∪ definitions) and a map from each DEFINED `conv:HASH` to its number.
 * PATCH assigns a re-cited conversation its existing marker (no duplicate def)
 * and a brand-new one `maxN + 1`, so the article stays footnote-bijective and
 * NORMALIZE's renumber short-circuits (no shuffle of other sections). Pure.
 */
export function articleFootnoteState(article: string): { maxN: number; byHash: Map<string, number> } {
  let maxN = 0;
  const byHash = new Map<string, number>();
  for (const line of article.split("\n")) {
    const d = /^\[\^(\d+)\]:(.*)$/.exec(line);
    if (d) {
      const n = parseInt(d[1]!, 10);
      if (n > maxN) maxN = n;
      const h = d[2]!.match(/conv:([0-9a-z]{8})/i);
      if (h) byHash.set(h[1]!.toLowerCase(), n);
      continue;
    }
    for (const m of line.matchAll(/\[\^(\d+)\]/g)) {
      const n = parseInt(m[1]!, 10);
      if (n > maxN) maxN = n;
    }
  }
  return { maxN, byHash };
}

/**
 * Map each `[^N]:` definition's marker number to the `YYYY-MM-DD` (or `undated`)
 * date its generated def line carries — the dates we tagged via `footnoteDefLine`
 * (`[^n]: \`conv:HASH\` (DATE, source)`). PATCH reads this so it can tell the model
 * how old the claim it is correcting is, and resolve toward the LATER date. Pure.
 */
export function referenceDatesByMarker(article: string): Map<number, string> {
  const out = new Map<number, string>();
  for (const m of article.matchAll(/^\[\^(\d+)\]:[^\n]*?\((\d{4}-\d{2}-\d{2}|undated),/gm)) {
    out.set(parseInt(m[1]!, 10), m[2]!);
  }
  return out;
}

/** The distinct `[^N]` marker numbers present in a single section/body block
 *  (definition lines excluded), in first-appearance order. Pure. */
function markersInBlock(body: string): number[] {
  const order: number[] = [];
  const seen = new Set<number>();
  for (const line of body.split("\n")) {
    if (/^\[\^\d+\]:/.test(line.trim())) continue;
    for (const m of line.matchAll(/\[\^(\d+)\]/g)) {
      const n = parseInt(m[1]!, 10);
      if (!seen.has(n)) {
        seen.add(n);
        order.push(n);
      }
    }
  }
  return order;
}

/**
 * Swap exactly the `anchor` section's block for `newBlock`, leaving every byte
 * OUTSIDE that section identical (the byte-preservation invariant PATCH and the
 * gate depend on). Returns null when the section is absent. Pure.
 */
export function replaceSection(article: string, anchor: string, newBlock: string): string | null {
  const block = extractSection(article, anchor);
  if (block == null) return null;
  const idx = article.indexOf(block);
  if (idx < 0) return null;
  return article.slice(0, idx) + newBlock + article.slice(idx + block.length);
}

/**
 * Insert a generated `[^N]:` definition line into the article's `## References`
 * section (after the last existing def), creating the section at the end when
 * the article has none. The model never writes defs — this is the only path that
 * does. Pure.
 */
export function appendReferenceDef(article: string, defLine: string): string {
  const refs = extractSection(article, "references");
  if (refs == null) {
    return `${article.replace(/\s+$/, "")}\n\n## References\n\n${defLine}\n`;
  }
  const newRefs = `${refs.replace(/\s+$/, "")}\n${defLine}\n`;
  return replaceSection(article, "references", newRefs) ?? article;
}

/** Retry hint when a patched section leaks meta/planning or fails to cite. */
const PATCH_ANTI_LEAK_HINT =
  "Output ONLY the integrated section prose — no preamble, no meta-commentary, no plan, no restating the task.";

/**
 * Draft the integrated section body, rejecting leakage AND an uncited fold:
 * draft once; if the sanitized body is {@link isLeakyDraft} OR is missing the
 * assigned `[^marker]` (the integration didn't actually place the citation),
 * retry ONCE with a sharper instruction; if it still fails, return "" so the
 * caller NO-OPs (the vault is untouched; the chunk retries next run).
 */
async function draftPatchedProse(
  call: SynthesisCall,
  prompt: string,
  marker: number,
  sanitize: (raw: string) => string,
): Promise<string> {
  const wants = new RegExp(`\\[\\^${marker}\\](?!:)`);
  const clean = (raw: string): string => {
    const body = sanitize(raw);
    return !isLeakyDraft(body) && wants.test(body) ? body : "";
  };
  const first = clean(await call(prompt, { maxTokens: MAX_OUTPUT_TOKENS }));
  if (first) return first;
  return clean(await call(`${prompt}\n\n${PATCH_ANTI_LEAK_HINT} Place the [^${marker}] marker for the new note.`, { maxTokens: MAX_OUTPUT_TOKENS }));
}

/** Draft an integrated SECTION body (sanitized as a section, must place the marker). */
function draftPatchedSection(
  call: SynthesisCall,
  prompt: string,
  marker: number,
  heading: string,
): Promise<string> {
  return draftPatchedProse(call, prompt, marker, (raw) => sanitizeSection(raw, heading));
}

/** The schematic PATCH prompt: current section markdown + the chunk + the inlined
 *  footnote/correction contract. Kept free of copyable example values per the
 *  small-model parroting failure mode. */
export function buildPatchPrompt(
  title: string,
  heading: string,
  currentBody: string,
  chunk: SynthesisChunk,
  n: number,
  otherArticles: string,
  policy: string,
  priorDates: string[] = [],
): string {
  const chunkDate = footnoteDate(chunk.dateMs);
  return (
    `${policy}\n\n${NO_COPY_GUARD}\n\n${WIKILINK_RULES}\n\n` +
    `You are integrating ONE new note (dated ${chunkDate}) into the "${heading}" section of the personal-wiki article about "${title}". ` +
    `Keep the existing prose and every existing [^k] citation marker intact; weave in only what the new note adds.\n\n` +
    `CITATION — cite the new note by placing the marker [^${n}] immediately after the specific claim it supports. ` +
    `Use [^${n}] for the new note, and reuse any [^k] markers already in the section exactly where they are. ` +
    `Do NOT write any [^k]: definition line — definitions are generated for you. ` +
    `[^N] is the only citation syntax; never emit HTML, bare links, or invent another number.\n\n` +
    correctionRule(n, chunkDate, priorDates) +
    `OTHER ARTICLES (link to these stems only):\n${otherArticles}\n\n` +
    `CURRENT "${heading}" SECTION:\n${currentBody || "(empty)"}\n\n` +
    `NEW NOTE (${chunkDate})${chunk.label ? ` — ${chunk.label}` : ""}:\n${chunk.text.slice(0, 1400).trim()}\n\n` +
    `Output ONLY the rewritten section body prose — do NOT repeat the "## ${heading}" heading, do NOT add other sections, do NOT write a References section.`
  );
}

/**
 * The PROVENANCE-PRESERVING correction rule (schematic). A correction resolves
 * toward the LATER-DATED statement so the latest position wins — but it KEEPS the
 * superseded claim's existing `[^k]` marker alongside the new `[^N]`, phrased as a
 * change over time, so no citation is lost. This is what lets the resolve fold pass
 * the gate's citation-survival check instead of being NO-OP'd for dropping `[^k]`.
 */
function correctionRule(n: number, chunkDate: string, priorDates: string[]): string {
  const prior = priorDates.filter((d) => d && d !== "undated");
  const priorClause = prior.length
    ? `The claim it corrects is dated ${[...new Set(prior)].join(" / ")}, so the new note (dated ${chunkDate}) is LATER. `
    : `The new note is dated ${chunkDate}. `;
  return (
    `CORRECTION — if the new note CONTRADICTS a claim already in the section, this is a correction: resolve toward the LATER-DATED statement so the user's CURRENT position wins. ` +
    priorClause +
    `DEMOTE the superseded claim to the PAST TENSE — rewrite the OLD clause itself from present ("is my favourite", "currently", "the one I reach for") to past ("previously was my favourite", "originally", "used to be") — do NOT leave the old value asserted as still-current and merely append the new one. ` +
    `KEEP the superseded claim's existing [^k] citation marker in place ALONGSIDE the new note's [^${n}] marker, so no [^N] is lost — phrase it like "previously <earlier position>[^k]; as of <later date> <current position> is now my pick[^${n}]". ` +
    `Do NOT assert both as simultaneously true, and do NOT ignore the new note.\n\n`
  );
}

/**
 * The CLASSIFIED LEAD correction rule (schematic). The lead must read as a CLEAN
 * current-state summary — never scattered "previously …" caveats (RULE 1). So when
 * a contradiction is classified:
 *   - EVOLUTION (the user changed their own position) → resolve the lead to the
 *     CURRENT value in the present tense; KEEP the superseded claim's `[^k]` marker
 *     so provenance survives the gate (the full trajectory is consolidated into a
 *     `## History` section by the reconcile pass), but do NOT narrate the change in
 *     the lead itself.
 *   - ERROR (a wrong fact being corrected) → SILENTLY replace the wrong value with
 *     the correct one; the wrong value's `[^k]` citation MAY be dropped (it is
 *     pruned as if it had never been there).
 */
function leadCorrectionRule(kind: ContradictionKind, n: number, chunkDate: string): string {
  if (kind === "error") {
    return (
      `CORRECTION (factual error) — the new note (dated ${chunkDate}) corrects a WRONG fact already in the lead. ` +
      `Silently REPLACE the wrong value with the correct one and cite it [^${n}]; state ONLY the correct value. ` +
      `Do NOT mention the wrong value, do NOT write "previously" — it was never a real position. ` +
      `You MAY drop the wrong value's [^k] citation marker.\n\n`
    );
  }
  return (
    `CORRECTION (the user's view evolved) — the new note (dated ${chunkDate}) supersedes an earlier position in the lead. ` +
    `Resolve the lead to the user's CURRENT position in the PRESENT TENSE and cite it [^${n}]. ` +
    `Keep it a clean current-state summary: do NOT scatter "previously …" caveats through the lead — the trajectory is recorded separately in a History section. ` +
    `KEEP the superseded claim's existing [^k] citation marker somewhere in the lead so no [^N] is lost (provenance survives), but frame the lead around the current value, not the change.\n\n`
  );
}

/** The schematic LEAD-PATCH prompt: the article's current lead + the chunk + the
 *  inlined footnote/correction contract. The lead is where an entity's headline
 *  verdict lives, so the CORRECTION rule is the load-bearing one. When a `kind` is
 *  classified, the lead resolves to a CLEAN current-state summary (evolution) or a
 *  silent overwrite (error); otherwise the default provenance-preserving fold runs. */
export function buildLeadPatchPrompt(
  title: string,
  currentLead: string,
  chunk: SynthesisChunk,
  n: number,
  otherArticles: string,
  policy: string,
  priorDates: string[] = [],
  kind?: ContradictionKind,
): string {
  const chunkDate = footnoteDate(chunk.dateMs);
  return (
    `${policy}\n\n${NO_COPY_GUARD}\n\n${WIKILINK_RULES}\n\n` +
    `You are updating the LEAD (the opening summary) of the personal-wiki article about "${title}" with ONE new note (dated ${chunkDate}). ` +
    `The lead names **${title}** in bold and states what it is and how the user relates to it. ` +
    `Keep every existing [^k] citation marker that still applies; weave in only what the new note adds.\n\n` +
    `CITATION — cite the new note by placing the marker [^${n}] immediately after the specific claim it supports. ` +
    `Reuse any [^k] markers already in the lead exactly where they are. ` +
    `Do NOT write any [^k]: definition line — definitions are generated for you. ` +
    `[^N] is the only citation syntax; never emit HTML, bare links, or invent another number.\n\n` +
    (kind ? leadCorrectionRule(kind, n, chunkDate) : correctionRule(n, chunkDate, priorDates)) +
    `OTHER ARTICLES (link to these stems only):\n${otherArticles}\n\n` +
    `CURRENT LEAD:\n${currentLead || "(empty)"}\n\n` +
    `NEW NOTE (${chunkDate})${chunk.label ? ` — ${chunk.label}` : ""}:\n${chunk.text.slice(0, 1400).trim()}\n\n` +
    `Output ONLY the rewritten lead prose — 2–4 sentences, no heading, no list, no References section.`
  );
}

export interface PatchInput {
  /** The full current article markdown. */
  article: string;
  /** The target section's anchor (a `chunk_sections` row's section_anchor), or
   *  {@link LEAD_ANCHOR} to fold into the article's opening lead. */
  anchor: string;
  /** The chunk to integrate (text + footnote metadata). */
  chunk: SynthesisChunk;
}

export interface PatchDeps {
  /** Model call; defaults to `callLocal("synthesis", …)` (same stage as CREATE). */
  call?: SynthesisCall;
  /** Other article stems for wikilink resolution. */
  stems?: Set<string>;
  /** Article stem (H1/NORMALIZE); defaults to the entity stem of the H1 title. */
  stem?: string;
}

export interface PatchOutcome {
  anchor: string;
  /** Final post-NORMALIZE article, or null when the patch was a NO-OP. */
  content: string | null;
  action: "patched" | "skipped";
  /** Skip reason; null on success. */
  reason: string | null;
  /** The `[^N]` number assigned to the chunk (null when never reached). */
  footnote: number | null;
  /** True when the chunk's conversation was already cited (reused marker, no new def). */
  reusedFootnote: boolean;
  /** True when a new `[^N]:` definition line was appended. */
  addedDef: boolean;
  normalizeNotes: string[];
}

/**
 * Fold ONE chunk into ONE existing section of an article, end to end:
 * assign the chunk's `[^N]` → draft the integrated body (leak/uncited → retry →
 * NO-OP) → swap ONLY that section's bytes → append the generated `[^N]:` def →
 * NORMALIZE → gate. Returns the patched article (or null when the gate vetoes a
 * weak pass). Pure with respect to disk — the caller persists.
 */
export async function patchSection(input: PatchInput, deps: PatchDeps = {}): Promise<PatchOutcome> {
  const call: SynthesisCall = deps.call ?? ((p, o) => callLocal("synthesis", { user: p }, o));
  const { article, anchor, chunk } = input;
  // The LEAD is patched by swapping exactly the lead bytes (no `## heading`).
  if (anchor === LEAD_ANCHOR) return patchLead(article, chunk, deps, call);
  const skip = (reason: string, footnote: number | null = null, reusedFootnote = false, addedDef = false): PatchOutcome => ({
    anchor,
    content: null,
    action: "skipped",
    reason,
    footnote,
    reusedFootnote,
    addedDef,
    normalizeNotes: [],
  });

  const block = extractSection(article, anchor);
  if (block == null) return skip(`section not found: ${anchor}`);
  const headingLine = block.split("\n")[0] ?? `## ${anchor}`;
  const heading = headingLine.replace(/^#{1,6}\s+/, "").trim();
  const currentBody = block.split("\n").slice(1).join("\n").trim();

  const title = articleH1Title(article);
  const stem = deps.stem ?? entityStem(title);
  const stems = new Set(deps.stems ?? []);
  stems.add(stem);
  const otherArticles = otherArticlesBlock(stems, stem);
  const policy = loadMetaPolicyQuiet(["Article_Conventions"]);

  // Assign the chunk's footnote: reuse the conversation's existing marker, else
  // mint maxN+1 (keeps the article bijective+contiguous → NORMALIZE no-ops).
  const state = articleFootnoteState(article);
  const hash = convHash(chunk.conv);
  const reused = state.byHash.get(hash);
  const n = reused ?? state.maxN + 1;
  const addedDef = reused === undefined;

  // The dates of the claims this section already cites — so a contradicting fold
  // can be told it is the LATER statement and resolve toward itself (provenance
  // preserved: it keeps the old [^k] marker).
  const refDates = referenceDatesByMarker(article);
  const priorDates = markersInBlock(currentBody)
    .map((m) => refDates.get(m))
    .filter((d): d is string => d != null);

  const newBody = await draftPatchedSection(
    call,
    buildPatchPrompt(title, heading, currentBody, chunk, n, otherArticles, policy, priorDates),
    n,
    heading,
  );
  // Empty after one retry = leaky/uncited → NO-OP (vault untouched, chunk retries).
  if (!newBody.trim()) return skip("patched section leaked, refused, or did not cite the new note (NO-OP)", n, reused !== undefined, addedDef);

  let next = replaceSection(article, anchor, `${headingLine}\n\n${newBody}\n`);
  if (next == null) return skip(`section vanished on swap: ${anchor}`, n, reused !== undefined, addedDef);
  if (addedDef) next = appendReferenceDef(next, footnoteDefLine(n, chunk.conv, chunk.title, chunk.dateMs));

  const norm = normalizeArticle(next, { stem, stems });

  // Footnote bijection must hold (a hallucinated marker number the gate cannot
  // repair → NO-OP rather than a citation-broken commit).
  const fn = checkFootnoteIntegrity(norm.content);
  if (!fn.ok) return skip(`footnote bijection unrepairable: ${fn.errors.join("; ")}`, n, reused !== undefined, addedDef);

  // The conservative gate over (before = original article, after = patched).
  const verdict: GateVerdict = gateEdit(article, norm.content);
  if (!verdict.ok) return skip(verdict.reason ?? "gate veto", n, reused !== undefined, addedDef);

  return {
    anchor,
    content: norm.content,
    action: "patched",
    reason: null,
    footnote: n,
    reusedFootnote: reused !== undefined,
    addedDef,
    normalizeNotes: norm.notes,
  };
}

/**
 * Fold ONE chunk into the article's LEAD (its opening summary), swapping exactly
 * the lead bytes — every section and the References stay byte-identical except for
 * the appended def. Same assign-footnote → draft (leak/uncited → retry → NO-OP) →
 * NORMALIZE → gate contract as {@link patchSection}, but the lead has no `##`
 * heading so we locate it via the structural skeleton and replace those lines.
 */
async function patchLead(
  article: string,
  chunk: SynthesisChunk,
  deps: PatchDeps,
  call: SynthesisCall,
): Promise<PatchOutcome> {
  const skip = (reason: string, footnote: number | null = null, reusedFootnote = false, addedDef = false): PatchOutcome => ({
    anchor: LEAD_ANCHOR,
    content: null,
    action: "skipped",
    reason,
    footnote,
    reusedFootnote,
    addedDef,
    normalizeNotes: [],
  });

  const leadItem = articleStructure(article).find((it) => it.kind === "lead");
  if (!leadItem) return skip("article has no lead to patch");
  const lines = article.split("\n");
  const start = leadItem.startLine - 1;
  const end = leadItem.endLine - 1; // 1-based inclusive → 0-based inclusive
  const currentLead = lines.slice(start, end + 1).join("\n").trim();

  const title = articleH1Title(article);
  const stem = deps.stem ?? entityStem(title);
  const stems = new Set(deps.stems ?? []);
  stems.add(stem);
  const otherArticles = otherArticlesBlock(stems, stem);
  const policy = loadMetaPolicyQuiet(["Article_Conventions"]);

  // Assign the chunk's footnote exactly as the section path does.
  const state = articleFootnoteState(article);
  const hash = convHash(chunk.conv);
  const reused = state.byHash.get(hash);
  const n = reused ?? state.maxN + 1;
  const addedDef = reused === undefined;

  const refDates = referenceDatesByMarker(article);
  const priorMarkers = markersInBlock(currentLead);
  const priorDates = priorMarkers
    .map((m) => refDates.get(m))
    .filter((d): d is string => d != null);

  // CLASSIFY the contradiction when the lead already cites a prior claim the new
  // note may conflict with: is the user CHANGING THEIR OWN view (evolution — the
  // lead resolves to current-state, the trajectory preserved in History by the
  // reconcile pass) or correcting a WRONG fact (error — silent overwrite, the
  // wrong value's citation may be pruned)?
  let kind: ContradictionKind | undefined;
  const allowDroppedHashes = new Set<string>();
  if (priorMarkers.length) {
    kind = classifyContradiction(
      await call(buildContradictionClassifierPrompt(currentLead, chunk.text.slice(0, 1400).trim()), { maxTokens: MAX_OUTPUT_TOKENS }),
    );
    if (kind === "error") {
      // A factual fix may drop the wrong value's citation. Permit dropping the
      // hashes the corrected lead cited (bounded to the lead's own prior claims).
      const hashByMarker = new Map<number, string>();
      for (const [h, m] of state.byHash) hashByMarker.set(m, h);
      for (const m of priorMarkers) {
        const h = hashByMarker.get(m);
        if (h) allowDroppedHashes.add(h);
      }
    }
  }

  const newLead = await draftPatchedProse(
    call,
    buildLeadPatchPrompt(title, currentLead, chunk, n, otherArticles, policy, priorDates, kind),
    n,
    sanitizeLead,
  );
  if (!newLead.trim()) return skip("patched lead leaked, refused, or did not cite the new note (NO-OP)", n, reused !== undefined, addedDef);

  // Swap exactly the lead lines; every other byte is preserved.
  let next = [...lines.slice(0, start), newLead, ...lines.slice(end + 1)].join("\n");
  if (addedDef) next = appendReferenceDef(next, footnoteDefLine(n, chunk.conv, chunk.title, chunk.dateMs));

  const norm = normalizeArticle(next, { stem, stems });

  const fn = checkFootnoteIntegrity(norm.content);
  if (!fn.ok) return skip(`footnote bijection unrepairable: ${fn.errors.join("; ")}`, n, reused !== undefined, addedDef);

  const verdict: GateVerdict = gateEdit(article, norm.content, { allowDroppedHashes });
  if (!verdict.ok) return skip(verdict.reason ?? "gate veto", n, reused !== undefined, addedDef);

  return {
    anchor: LEAD_ANCHOR,
    content: norm.content,
    action: "patched",
    reason: null,
    footnote: n,
    reusedFootnote: reused !== undefined,
    addedDef,
    normalizeNotes: norm.notes,
  };
}

// ---- effectful entry: PATCH a vault article + ledger -----------------------

export interface SynthesizePatchOpts {
  /** The article to patch (its filename stem). */
  stem: string;
  /** The section anchor to fold into (a `chunk_sections` row). */
  anchor: string;
  /** The chunk id to integrate. */
  chunkId: string;
  /** Vault root (honors MLX_BUN_WIKI); defaults to `vaultRoot()`. */
  root?: string;
  /** Model-call override (tests inject a fake). */
  call?: SynthesisCall;
  /** Skip the git commit (tests). */
  commit?: boolean;
  now?: number;
}

export interface PatchResult {
  patched: boolean;
  stem: string;
  anchor: string;
  /** The gate (or a draft NO-OP) vetoed the write. */
  skippedByGate: boolean;
  /** The (chunk, article, section) edge was already folded (idempotent NO-OP). */
  alreadyIntegrated: boolean;
  reason: string | null;
  footnote: number | null;
}

/**
 * PATCH one chunk into one section of a vault article and persist it. Idempotent
 * BEFORE the model: a present `synthesized_chunk_sections` PK row short-circuits
 * to a NO-OP (no GPU, no write). Otherwise drafts via {@link patchSection}, writes
 * the swapped article (unless the gate vetoed), records the integration edge, and
 * commits.
 */
export async function synthesizePatch(store: MemoryStore, opts: SynthesizePatchOpts): Promise<PatchResult> {
  const root = opts.root ?? vaultRoot();
  const base: PatchResult = {
    patched: false,
    stem: opts.stem,
    anchor: opts.anchor,
    skippedByGate: false,
    alreadyIntegrated: false,
    reason: null,
    footnote: null,
  };

  // Idempotency: the (chunk, article, section) PK blocks a double-fold up front.
  const already = store.db
    .query("SELECT 1 FROM synthesized_chunk_sections WHERE chunk_id = ? AND article_stem = ? AND section_anchor = ?")
    .get(opts.chunkId, opts.stem, opts.anchor);
  if (already) return { ...base, alreadyIntegrated: true, reason: "already integrated (synthesized_chunk_sections PK)" };

  const path = join(articlesDir(root), `${opts.stem}.md`);
  let article: string;
  try {
    article = await readFile(path, "utf8");
  } catch {
    return { ...base, reason: `article not found: ${opts.stem}` };
  }

  const chunk = loadSynthesisChunk(store, opts.chunkId);
  if (!chunk) return { ...base, reason: `chunk not found: ${opts.chunkId}` };

  const stems = new Set(await listArticles(root));
  const outcome = await patchSection({ article, anchor: opts.anchor, chunk }, { call: opts.call, stems, stem: opts.stem });

  if (outcome.action !== "patched" || outcome.content == null) {
    return { ...base, skippedByGate: true, reason: outcome.reason, footnote: outcome.footnote };
  }

  await writeFile(path, outcome.content);

  const now = opts.now ?? Date.now();
  const insSec = store.db.query(
    "INSERT OR IGNORE INTO chunk_sections (chunk_id, article_stem, section_anchor) VALUES (?, ?, ?)",
  );
  const insSynth = store.db.query(
    "INSERT OR REPLACE INTO synthesized_chunk_sections " +
      "(chunk_id, article_stem, section_anchor, synthesized_at) VALUES (?, ?, ?, ?)",
  );
  const tx = store.db.transaction(() => {
    insSec.run(opts.chunkId, opts.stem, opts.anchor);
    insSynth.run(opts.chunkId, opts.stem, opts.anchor, now);
  });
  tx();

  if (opts.commit !== false) {
    await commitVault(root, `memory: patch ${opts.stem} #${opts.anchor} (+chunk ${opts.chunkId})`);
  }

  return { ...base, patched: true, footnote: outcome.footnote };
}

// ===========================================================================
// NEW SECTION — the third SECTION-ROUTE outcome (P7): a chunk that fits NO
// existing section AND is not a verdict-level correction earns its OWN section.
//
// SECTION-ROUTE returns a NAMED new section for a substantive chunk that matched
// nothing; honoring it (rather than dropping the chunk) is the difference between
// self-healing and silent loss. We mint an EMPTY `## Title` section, then run the
// SAME bounded fold as PATCH against it — so the new section is drafted, cited,
// gated, and normalized exactly like every other integration, never a raw dump.
// ===========================================================================

/** Insert an empty `## title` section into the article just before its `## See
 *  also` / `## References` tail (or at the end when neither exists), so a fresh
 *  topical section lands among the body sections, not after the references. The
 *  body is left empty — {@link patchSection} fills it by folding the chunk in. */
export function insertEmptySection(article: string, title: string): string {
  const lines = article.replace(/\s+$/, "").split("\n");
  const idx = lines.findIndex((l) => /^##\s+(see also|references)\s*$/i.test(l.trim()));
  if (idx < 0) return [...lines, "", `## ${title}`, ""].join("\n") + "\n";
  return [...lines.slice(0, idx), `## ${title}`, "", "", ...lines.slice(idx)].join("\n") + "\n";
}

export interface SynthesizeNewSectionOpts {
  /** The article to grow (its filename stem). */
  stem: string;
  /** The new section's display title. */
  title: string;
  /** The new section's anchor (slug of `title`); also the ledger key. */
  anchor: string;
  /** The chunk id to fold into the new section. */
  chunkId: string;
  /** Vault root (honors MLX_BUN_WIKI); defaults to `vaultRoot()`. */
  root?: string;
  /** Model-call override (tests inject a fake). */
  call?: SynthesisCall;
  /** Skip the git commit (tests). */
  commit?: boolean;
  now?: number;
}

/**
 * CREATE a new section in an existing article and fold ONE chunk into it. Mints
 * the `## Title` heading then drafts its body via {@link patchSection} (so the
 * fold is cited, gated, NORMALIZED, and footnote-bijective just like a PATCH),
 * writes the grown article, and records the (chunk, section) edge. Idempotent via
 * `synthesized_chunk_sections`'s PK — a re-run of the same (chunk, article,
 * section) writes nothing. Used by SYNTHESIZE when SECTION-ROUTE returns a
 * `newSection` for a chunk that fit no existing section.
 */
export async function synthesizeNewSection(
  store: MemoryStore,
  opts: SynthesizeNewSectionOpts,
): Promise<PatchResult> {
  const root = opts.root ?? vaultRoot();
  const base: PatchResult = {
    patched: false,
    stem: opts.stem,
    anchor: opts.anchor,
    skippedByGate: false,
    alreadyIntegrated: false,
    reason: null,
    footnote: null,
  };

  const already = store.db
    .query("SELECT 1 FROM synthesized_chunk_sections WHERE chunk_id = ? AND article_stem = ? AND section_anchor = ?")
    .get(opts.chunkId, opts.stem, opts.anchor);
  if (already) return { ...base, alreadyIntegrated: true, reason: "already integrated (synthesized_chunk_sections PK)" };

  const path = join(articlesDir(root), `${opts.stem}.md`);
  let article: string;
  try {
    article = await readFile(path, "utf8");
  } catch {
    return { ...base, reason: `article not found: ${opts.stem}` };
  }

  const chunk = loadSynthesisChunk(store, opts.chunkId);
  if (!chunk) return { ...base, reason: `chunk not found: ${opts.chunkId}` };

  // Mint the empty section unless the article already carries it (idempotent
  // across the same name), then fold the chunk into it via the PATCH op.
  const withSection = extractSection(article, opts.anchor) != null ? article : insertEmptySection(article, opts.title);
  const stems = new Set(await listArticles(root));
  const outcome = await patchSection(
    { article: withSection, anchor: opts.anchor, chunk },
    { call: opts.call, stems, stem: opts.stem },
  );

  if (outcome.action !== "patched" || outcome.content == null) {
    return { ...base, skippedByGate: true, reason: outcome.reason, footnote: outcome.footnote };
  }

  await writeFile(path, outcome.content);

  const now = opts.now ?? Date.now();
  const insSec = store.db.query(
    "INSERT OR IGNORE INTO chunk_sections (chunk_id, article_stem, section_anchor) VALUES (?, ?, ?)",
  );
  const insSynth = store.db.query(
    "INSERT OR REPLACE INTO synthesized_chunk_sections " +
      "(chunk_id, article_stem, section_anchor, synthesized_at) VALUES (?, ?, ?, ?)",
  );
  const tx = store.db.transaction(() => {
    insSec.run(opts.chunkId, opts.stem, opts.anchor);
    insSynth.run(opts.chunkId, opts.stem, opts.anchor, now);
  });
  tx();

  if (opts.commit !== false) {
    await commitVault(root, `memory: new section ${opts.stem} #${opts.anchor} (+chunk ${opts.chunkId})`);
  }

  return { ...base, patched: true, footnote: outcome.footnote };
}
