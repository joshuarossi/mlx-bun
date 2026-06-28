// mlx-bun memory — the article grammar parser/serializer.
//
// The Dreaming write pipeline emits Wikipedia-shaped articles: each entity gets
// one Markdown file with a fixed top-to-bottom skeleton —
//   H1 → series banner → infobox → lead → sections → See also → Notes → References
// (see docs/design/the-dreaming-master-plan.md and write-pipeline-entity.md).
// This module reads that grammar deterministically: the structured outputs the
// read side traverses (infobox key-value facts, the [[wikilink]] graph, footnote
// bijection) are parsed here, never by the model.
//
// It owns the ONE fence scanner — `isFenceLine` / `fenceLabel` — so that this
// module and `vault.ts` (parseToc / extractSection / searchArticles) agree on
// exactly what "inside a fenced code block" means. `vault.ts` imports it; this
// module never imports from `vault.ts` (no cycle).

// ---- fence scanner (the one shared implementation) -------------------

/** A line that opens or closes a Markdown fenced block (```...). */
export function isFenceLine(line: string): boolean {
  return /^```/.test(line);
}

/** The info string after a fence's backticks (e.g. ```info → "info"); null if
 *  the line is not a fence. A bare closing ``` yields "". */
export function fenceLabel(line: string): string | null {
  const m = /^```(.*)$/.exec(line);
  return m ? m[1]!.trim() : null;
}

/** Total number of fence lines (``` openers/closers) in a document. A BALANCED
 *  article has an EVEN count; an odd count means a fence was opened and never
 *  closed, which leaves every fence-aware scanner (this module, vault.ts,
 *  normalize.ts, crosslink.ts) stuck "inside a code block" for the rest of the
 *  file — so trailing real sections (## References / ## See also) are read as
 *  code and never recognized. */
export function countFenceLines(content: string): number {
  let n = 0;
  for (const line of content.split(/\r?\n/)) if (isFenceLine(line)) n++;
  return n;
}

/** True when the document's fences are balanced (an even number of fence lines),
 *  i.e. every opened fence is closed — the precondition every fence-aware parser
 *  depends on. */
export function hasBalancedFences(content: string): boolean {
  return countFenceLines(content) % 2 === 0;
}

const REPAIR_HEADING_RE = /^#{1,6}\s+\S/;

/**
 * Deterministically repair an UNBALANCED code fence (odd fence-line count). Fences
 * strictly alternate open/close, so an odd count means the LAST fence line is an
 * opener that is never closed and swallows everything after it. The repair closes
 * (or strips) that dangling fence so trailing headings stop being read as code:
 *
 *   - prefer to CLOSE the fence right before the first ##-style heading the fence
 *     would otherwise swallow (rescuing ## References / ## See also);
 *   - if the dangling open has only blank lines before that heading (or before
 *     EOF), it is a SPURIOUS stray fence — strip the line instead of wrapping an
 *     empty block;
 *   - with no heading to protect, close at EOF (or strip when the tail is blank).
 *
 * A balanced article is returned byte-identical (changed: false); after a repair
 * the count is even, so a second pass is a no-op (idempotent). Pure.
 */
export function repairFences(content: string): { content: string; changed: boolean } {
  const lines = content.split(/\r?\n/);
  const fenceIdx: number[] = [];
  for (let i = 0; i < lines.length; i++) if (isFenceLine(lines[i]!)) fenceIdx.push(i);
  if (fenceIdx.length % 2 === 0) return { content, changed: false };

  const dangling = fenceIdx[fenceIdx.length - 1]!; // the unmatched opener

  // The first heading the dangling fence would otherwise swallow.
  let heading = -1;
  for (let i = dangling + 1; i < lines.length; i++) {
    if (REPAIR_HEADING_RE.test(lines[i]!)) {
      heading = i;
      break;
    }
  }

  const stop = heading >= 0 ? heading : lines.length;
  // Last non-blank content line strictly between the dangling opener and `stop`.
  let j = stop - 1;
  while (j > dangling && lines[j]!.trim() === "") j--;

  let out: string[];
  if (j === dangling) {
    // Nothing but blanks under the dangling fence → it opens an empty block; strip it.
    out = [...lines.slice(0, dangling), ...lines.slice(dangling + 1)];
  } else {
    // Close the fence right after the last real content line, before `stop`.
    out = [...lines.slice(0, j + 1), "```", ...lines.slice(j + 1)];
  }
  const next = out.join("\n");
  return { content: next, changed: next !== content };
}

// ---- entity kinds (the only fixed structural constant) ---------------

/** The closed set of entity KINDS — a schema, not content. Infobox `type:`
 *  labels and categories are emergent (declared per-article); only `kind` is
 *  fixed. There is NO `kindOf(type)` map. See P1-T4c. */
export const ENTITY_KINDS = ["thing", "person", "domain", "project", "standard"] as const;
export type EntityKind = (typeof ENTITY_KINDS)[number];

/** Read an entity kind from a declared `kind:` value, validating against the
 *  closed set; anything unrecognized defaults to "thing". */
export function toEntityKind(value: string): EntityKind {
  const t = value.trim().toLowerCase();
  return (ENTITY_KINDS as readonly string[]).includes(t) ? (t as EntityKind) : "thing";
}

// ---- infobox ----------------------------------------------------------

/** Syntactic value-type of an infobox field, derived deterministically from the
 *  value's shape (never from a baked key→class map — schemas are emergent). */
export type FieldValueType = "scalar" | "entity-link" | "list" | "date";

export interface InfoboxField {
  key: string;
  /** Raw value text exactly as written (so serialize round-trips byte-for-byte). */
  value: string;
  /** True when the value names another entity as a `[[wikilink]]`. */
  isEntityLink: boolean;
  kind: FieldValueType;
}

export interface Infobox {
  /** The emergent `type:` label (a short free-form noun phrase), or null if absent. */
  type: string | null;
  /** The declared `kind:` entity kind, validated; defaults to "thing". */
  entityKind: EntityKind;
  /** Every `key: value` line, in document order (includes `type`/`kind`/`aliases`). */
  fields: InfoboxField[];
}

const WIKILINK_RE = /\[\[[^\]]+\]\]/;
const DATE_RE = /^\d{4}-\d{2}(-\d{2})?$/;

function parseFieldLine(line: string): { key: string; value: string } | null {
  const idx = line.indexOf(":");
  if (idx < 0) return null;
  const key = line.slice(0, idx).trim();
  if (!key) return null;
  return { key, value: line.slice(idx + 1).trim() };
}

/** Comma-separated for `aliases`, `;`-separated for every other multi-value
 *  field (the infobox grammar). Single-value fields yield a one-element array. */
export function infoboxFieldValues(field: InfoboxField): string[] {
  const sep = field.key === "aliases" ? "," : ";";
  return field.value
    .split(sep)
    .map((v) => v.trim())
    .filter((v) => v.length > 0);
}

function classifyFieldKind(key: string, value: string, isEntityLink: boolean): FieldValueType {
  const isList = key === "aliases" ? value.includes(",") : value.includes(";");
  if (isList) return "list";
  if (isEntityLink) return "entity-link";
  if (DATE_RE.test(value.trim())) return "date";
  return "scalar";
}

function findInfoboxBlock(lines: string[]): { start: number; end: number } | null {
  for (let i = 0; i < lines.length; i++) {
    if (isFenceLine(lines[i]!) && fenceLabel(lines[i]!) === "info") {
      for (let j = i + 1; j < lines.length; j++) {
        if (isFenceLine(lines[j]!)) return { start: i, end: j };
      }
      return null; // unterminated fence — not a usable infobox
    }
  }
  return null;
}

/** Parse the first fenced ```info block in an article (or a bare block). Returns
 *  null when there is no infobox. */
export function parseInfobox(md: string): Infobox | null {
  const lines = md.split(/\r?\n/);
  const block = findInfoboxBlock(lines);
  if (!block) return null;

  const fields: InfoboxField[] = [];
  for (let i = block.start + 1; i < block.end; i++) {
    const parsed = parseFieldLine(lines[i]!);
    if (!parsed) continue;
    const isEntityLink = WIKILINK_RE.test(parsed.value);
    fields.push({
      key: parsed.key,
      value: parsed.value,
      isEntityLink,
      kind: classifyFieldKind(parsed.key, parsed.value, isEntityLink),
    });
  }

  const typeField = fields.find((f) => f.key === "type");
  const kindField = fields.find((f) => f.key === "kind");
  return {
    type: typeField ? typeField.value : null,
    entityKind: kindField ? toEntityKind(kindField.value) : "thing",
    fields,
  };
}

/** Render an infobox back to its fenced ```info block. Round-trips a
 *  canonically-formatted infobox byte-for-byte. */
export function serializeInfobox(box: Infobox): string {
  const body = box.fields.map((f) => `${f.key}: ${f.value}`).join("\n");
  return "```info\n" + body + "\n```";
}

/** The declared `aliases:` for an article, split exactly per the grammar. */
export function infoboxAliases(box: Infobox): string[] {
  const f = box.fields.find((f) => f.key === "aliases");
  return f ? infoboxFieldValues(f) : [];
}

// ---- series banner ----------------------------------------------------

const SERIES_RE = /^\*Part of a series on \[\[([^\]]+)\]\]\.?\*$/;
/** The `{{stub}}` template line — header region, not body prose. */
const STUB_TEMPLATE_RE = /^\{\{stub\}\}$/;

/** The series this article belongs to, from a `*Part of a series on [[X]].*`
 *  banner; returns the series entity name, or null. */
export function parseSeriesBanner(md: string): string | null {
  const lines = md.split(/\r?\n/);
  let inFence = false;
  for (const line of lines) {
    if (isFenceLine(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const m = SERIES_RE.exec(line.trim());
    if (m) return m[1]!.split("|")[0]!.split("#")[0]!.trim();
  }
  return null;
}

// ---- lead -------------------------------------------------------------

const HEADING_RE = /^(#{1,6})\s+(.+)$/;

/** The lead abstract: prose between the header region (H1 / banner / infobox)
 *  and the first `##` section, as a single line; null when there is none. */
export function parseLead(md: string): string | null {
  const lines = md.split(/\r?\n/);
  const block = findInfoboxBlock(lines);

  let inFence = false;
  let h1 = -1;
  let firstSection = lines.length;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]!;
    if (isFenceLine(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const m = HEADING_RE.exec(line);
    if (!m) continue;
    if (m[1]!.length === 1) {
      if (h1 < 0) h1 = i;
    } else if (firstSection === lines.length) {
      firstSection = i;
    }
  }

  let start = h1 + 1;
  if (block && block.end + 1 > start) start = block.end + 1;

  const leadLines: string[] = [];
  for (let i = start; i < firstSection; i++) {
    const t = lines[i]!.trim();
    if (!t) {
      if (leadLines.length) break; // paragraph end
      continue; // skip leading blanks
    }
    if (SERIES_RE.test(t)) continue;
    leadLines.push(t);
  }
  return leadLines.length ? leadLines.join(" ") : null;
}

// ---- structural skeleton ---------------------------------------------

export type SkeletonKind = "h1" | "series" | "infobox" | "lead" | "section" | "see-also" | "notes" | "references";

export interface SkeletonItem {
  kind: SkeletonKind;
  /** Heading text for h1/section/see-also/notes/references items. */
  title?: string;
  /** Heading depth (1 for h1, 2 for top-level sections). */
  depth?: number;
  /** 1-based inclusive line range of the region. */
  startLine: number;
  endLine: number;
}

/** The article's ordered skeleton with line ranges — the structural map the
 *  write pipeline patches section-by-section. */
export function articleStructure(md: string): SkeletonItem[] {
  const lines = md.split(/\r?\n/);
  const block = findInfoboxBlock(lines);

  interface Heading {
    depth: number;
    title: string;
    line: number;
  }
  const headings: Heading[] = [];
  let inFence = false;
  let bannerLine = -1;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]!;
    if (isFenceLine(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const m = HEADING_RE.exec(line);
    if (m) {
      headings.push({ depth: m[1]!.length, title: m[2]!.trim(), line: i });
    } else if (bannerLine < 0 && SERIES_RE.test(line.trim())) {
      bannerLine = i;
    }
  }

  const items: SkeletonItem[] = [];
  const h1 = headings.find((h) => h.depth === 1);
  if (h1) items.push({ kind: "h1", title: h1.title, depth: 1, startLine: h1.line + 1, endLine: h1.line + 1 });
  if (bannerLine >= 0) items.push({ kind: "series", startLine: bannerLine + 1, endLine: bannerLine + 1 });
  if (block) items.push({ kind: "infobox", startLine: block.start + 1, endLine: block.end + 1 });

  const sections = headings.filter((h) => h.depth === 2);
  const firstSectionLine = sections.length ? sections[0]!.line : lines.length;

  // Lead: prose after the header region, before the first section.
  let leadStart = h1 ? h1.line + 1 : 0;
  if (bannerLine + 1 > leadStart) leadStart = bannerLine + 1;
  if (block && block.end + 1 > leadStart) leadStart = block.end + 1;
  while (leadStart < firstSectionLine && lines[leadStart]!.trim() === "") leadStart++;
  let leadEnd = firstSectionLine - 1;
  while (leadEnd >= leadStart && lines[leadEnd]!.trim() === "") leadEnd--;
  if (leadEnd >= leadStart) items.push({ kind: "lead", startLine: leadStart + 1, endLine: leadEnd + 1 });

  for (let s = 0; s < sections.length; s++) {
    const cur = sections[s]!;
    const nextLine = s + 1 < sections.length ? sections[s + 1]!.line : lines.length;
    const norm = cur.title.trim().toLowerCase();
    const kind: SkeletonKind =
      norm === "see also" ? "see-also" : norm === "notes" ? "notes" : norm === "references" ? "references" : "section";
    items.push({ kind, title: cur.title, depth: 2, startLine: cur.line + 1, endLine: nextLine });
  }

  items.sort((a, b) => a.startLine - b.startLine);
  return items;
}

// ---- footnotes --------------------------------------------------------

const MARKER_RE = /\[\^([^\]]+)\](?!:)/g;
const DEF_RE = /^\[\^([^\]]+)\]:\s?(.*)$/;

export interface FootnoteMarker {
  id: string;
  line: number;
}

export interface FootnoteDef {
  id: string;
  line: number;
  text: string;
}

export interface Footnotes {
  /** Every inline `[^N]` reference (excludes `[^N]:` definition lines). */
  markers: FootnoteMarker[];
  /** Every `[^N]:` definition. */
  defs: FootnoteDef[];
}

/** Parse footnote markers and definitions. NORMALIZE asserts the bijection
 *  (every marker ⇔ exactly one def); this just reports what is present so a
 *  dangling marker or orphan def is detectable as a set difference. */
export function parseFootnotes(md: string): Footnotes {
  const lines = md.split(/\r?\n/);
  const markers: FootnoteMarker[] = [];
  const defs: FootnoteDef[] = [];
  let inFence = false;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]!;
    if (isFenceLine(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const dm = DEF_RE.exec(line);
    if (dm) {
      defs.push({ id: dm[1]!.trim(), line: i + 1, text: dm[2]!.trim() });
      continue;
    }
    MARKER_RE.lastIndex = 0;
    let m: RegExpExecArray | null;
    while ((m = MARKER_RE.exec(line)) !== null) {
      markers.push({ id: m[1]!.trim(), line: i + 1 });
    }
  }
  return { markers, defs };
}

// ---- category declarations -------------------------------------------
//
// Categories are EMERGENT and EXPLICIT: an article declares its memberships on a
// single `categories:` line near the top, listing comma-separated
// `[[Category:Name]]` wikilinks (P1-T4a). This deriver is the SOLE mechanism —
// there is NO `type→category` map. A category comes into existence the first
// time some article declares it; the `categories` table simply accumulates the
// names seen here on reindex.

/** A line that declares category memberships (`categories: [[Category:X]], …`). */
const CATEGORIES_LINE_RE = /^categories:\s*(.+)$/i;
/** One `[[Category:Name]]` membership wikilink. */
const CATEGORY_LINK_RE = /\[\[Category:([^\]|#]+)(?:[|#][^\]]*)?\]\]/g;

export interface CategoryRow {
  article_stem: string;
  category: string;
  source: string;
}

export interface DerivedCategories {
  /** One `article_categories` row per declared `[[Category:Name]]`. */
  categoryRows: CategoryRow[];
  /** The distinct category names this article declares, in document order. */
  categories: string[];
}

/**
 * Read an article's explicit category declarations into `article_categories`
 * rows. Scans `categories:` lines outside fenced code, collecting each
 * `[[Category:Name]]` membership. Emergent and explicit — never derived from the
 * infobox `type:` label. Returns deduped categories in first-seen order.
 */
export function deriveCategories(md: string, stem: string): DerivedCategories {
  const lines = md.split(/\r?\n/);
  const categories: string[] = [];
  const seen = new Set<string>();
  let inFence = false;
  for (const line of lines) {
    if (isFenceLine(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const decl = CATEGORIES_LINE_RE.exec(line.trim());
    if (!decl) continue;
    CATEGORY_LINK_RE.lastIndex = 0;
    let m: RegExpExecArray | null;
    while ((m = CATEGORY_LINK_RE.exec(decl[1]!)) !== null) {
      const name = m[1]!.trim();
      if (name && !seen.has(name)) {
        seen.add(name);
        categories.push(name);
      }
    }
  }
  const categoryRows = categories.map((category) => ({ article_stem: stem, category, source: "declared" }));
  return { categoryRows, categories };
}

// ---- structural validation -------------------------------------------

export interface ArticleValidation {
  ok: boolean;
  /** Human-readable grammar violations; empty when `ok`. */
  errors: string[];
}

interface ScannedHeading {
  depth: number;
  title: string;
  line: number;
}

/** Fence-aware heading scan (the one the validator shares with the grammar). */
function scanHeadings(lines: string[]): ScannedHeading[] {
  const out: ScannedHeading[] = [];
  let inFence = false;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]!;
    if (isFenceLine(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const m = HEADING_RE.exec(line);
    if (m) out.push({ depth: m[1]!.length, title: m[2]!.trim(), line: i });
  }
  return out;
}

/**
 * Assert the fixed top-to-bottom grammar (P1-T1): exactly one H1; the infobox
 * (if any) precedes the lead and all sections; `## See also` precedes
 * `## References`; `## References` (if present) is the LAST section. Returns the
 * set of violations so a malformed article is rejectable as `ok === false`.
 */
export function validateArticleStructure(md: string): ArticleValidation {
  const lines = md.split(/\r?\n/);
  const errors: string[] = [];

  // Walk once for infobox-vs-body ordering (fence-aware).
  let inFence = false;
  let sawBody = false;
  let infoboxLine = -1;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]!;
    if (isFenceLine(line)) {
      if (!inFence && fenceLabel(line) === "info") {
        if (infoboxLine < 0) infoboxLine = i;
        if (sawBody) errors.push("infobox must precede the lead and all sections");
      }
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const t = line.trim();
    if (!t) continue;
    const hm = HEADING_RE.exec(line);
    if (hm) {
      if (hm[1]!.length >= 2) sawBody = true; // a section heading is body
      continue; // the H1 is header region, not body
    }
    if (SERIES_RE.test(t)) continue; // series banner is header region
    if (CATEGORIES_LINE_RE.test(t)) continue; // category declaration is header region
    if (STUB_TEMPLATE_RE.test(t)) continue; // {{stub}} is a template marker, not prose
    sawBody = true; // any other prose is lead/body
  }

  const headings = scanHeadings(lines);
  const h1Count = headings.filter((h) => h.depth === 1).length;
  if (h1Count !== 1) errors.push(`expected exactly one H1, found ${h1Count}`);

  const sections = headings.filter((h) => h.depth === 2);
  const refIdx = sections.findIndex((s) => s.title.trim().toLowerCase() === "references");
  const seeIdx = sections.findIndex((s) => s.title.trim().toLowerCase() === "see also");
  if (refIdx >= 0 && refIdx !== sections.length - 1) errors.push("## References must be the last section");
  if (seeIdx >= 0 && refIdx >= 0 && seeIdx > refIdx) errors.push("## See also must precede ## References");

  return { ok: errors.length === 0, errors };
}
