// The Dreaming — P9-T3 · Bootstrap audit (PURE STRUCTURAL, no model).
//
// Audits every article a bootstrap produced for the four structural invariants
// that make a synthesized vault trustworthy — none of which needs a model, an
// embedding, or the DB; they read straight off the markdown grammar that
// src/memory/article.ts already parses:
//
//   (i)   TITLE      — the stem is a thing/noun, not an `X_and_Y` bin blob (the
//                      385-bin pathology we replace). A genuine compound entity
//                      may be allowlisted; the default is to reject `_and_`.
//   (ii)  INFOBOX    — an infobox is present and populated, and every
//                      entity-value `[[wikilink]]` either RESOLVES to an article
//                      stem or is a recognized REDLINK (an entity referenced in
//                      prose/aliases but not yet synthesized = legitimate
//                      parking). A link that resolves to NOTHING and is referenced
//                      NOWHERE is DANGLING — the infobox invented it.
//   (iii) FOOTNOTES  — marker/def bijection: every inline `[^N]` has exactly one
//                      `[^N]:` definition and vice-versa (id-level; reusing one
//                      footnote across several claims is fine).
//   (iv)  CLAIMS     — every claim traces to a cited chunk: an article with a
//                      populated infobox carries ≥1 citation
//                      (infobox-traces-to-cited-claim), and no body section makes
//                      prose claims with zero `[^N]` markers (no uncited section).
//
// Run it on a vault (defaults to MLX_BUN_WIKI / ~/.mlx-bun/wiki):
//
//   MLX_BUN_WIKI=~/.mlx-bun/wiki-smoke bun scripts/memory/audit-bootstrap.ts
//
// The plan target on the FULL bootstrap is 100% structural pass and ≤40 entity
// articles each with a populated infobox + ≥1 citation; here we just PROVE the
// harness and report the real numbers on whatever vault is pointed at.

import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";
import {
  articleStructure,
  infoboxFieldValues,
  parseFootnotes,
  parseInfobox,
  type Infobox,
} from "../../src/memory/article";
import {
  articlesDir,
  extractWikilinkTargets,
  resolveWikilinkToStem,
  vaultRoot,
} from "../../src/memory/vault";

// ---- inputs ----------------------------------------------------------------

export interface ArticleInput {
  /** Filename stem (e.g. `Panasonic_Lumix_S5IIX`). */
  stem: string;
  /** Full markdown content. */
  content: string;
}

/** A normalized key for cross-referencing link targets / stems / aliases:
 *  case-folded, whitespace and underscores unified. */
function normKey(raw: string): string {
  return raw.trim().replace(/[\s_]+/g, " ").toLowerCase();
}

/** Genuine compound entities whose canonical name legitimately contains `and`
 *  (a deliberate, hand-maintained exception to the `_and_` reject — empty by
 *  default; the bin pathology is the rule, the proper-name compound the rare
 *  exception). Match against the stem with `_`→space. */
const COMPOUND_ALLOW = new Set<string>([
  // e.g. "Dungeons and Dragons", "Smith and Wesson" — add by judgment.
]);

// ---- per-check results -----------------------------------------------------

export interface InfoboxLinkAudit {
  field: string;
  target: string;
  status: "resolved" | "redlink" | "dangling";
}

export interface ArticleAudit {
  stem: string;
  title: { ok: boolean; reason?: string };
  infobox: {
    ok: boolean;
    present: boolean;
    populated: boolean;
    links: InfoboxLinkAudit[];
    reasons: string[];
  };
  footnotes: {
    ok: boolean;
    markerIds: string[];
    defIds: string[];
    danglingMarkers: string[];
    orphanDefs: string[];
    duplicateDefs: string[];
  };
  claims: {
    ok: boolean;
    citationCount: number;
    uncitedSections: string[];
    reasons: string[];
  };
  /** True only when all four structural checks pass. */
  pass: boolean;
  /** Flat list of every violation across the four checks. */
  reasons: string[];
}

/** Vault-wide context shared by every per-article audit. */
export interface AuditContext {
  /** Every article stem (for wikilink resolution). */
  stems: Set<string>;
  /** Normalized keys of everything a redlink may legitimately point at: stems,
   *  prose wikilink targets, and declared aliases. A target outside this set is
   *  DANGLING (referenced nowhere). */
  known: Set<string>;
}

// ---- context building ------------------------------------------------------

const WIKILINK_RE = /\[\[([^\]]+)\]\]/g;

/** Wikilink targets inside a single (already fence-free) value, cleaned of
 *  `Category:` / `conv:` non-entity links and any `|alias` / `#anchor` suffix. */
function entityLinkTargets(value: string): string[] {
  const out: string[] = [];
  WIKILINK_RE.lastIndex = 0;
  let m: RegExpExecArray | null;
  while ((m = WIKILINK_RE.exec(value)) !== null) {
    const inner = m[1]!.trim();
    if (!inner || /^conv:/i.test(inner) || /^Category:/i.test(inner)) continue;
    const target = inner.split("|")[0]!.split("#")[0]!.trim();
    if (target) out.push(target);
  }
  return out;
}

/** Count of `[[` openers minus well-formed `[[…]]` links — a positive value
 *  signals a malformed/unclosed wikilink in the text. */
function malformedLinkCount(value: string): number {
  const openers = (value.match(/\[\[/g) ?? []).length;
  WIKILINK_RE.lastIndex = 0;
  const closed = (value.match(WIKILINK_RE) ?? []).length;
  return Math.max(0, openers - closed);
}

function infoboxAliasKeys(box: Infobox | null): string[] {
  if (!box) return [];
  const f = box.fields.find((fld) => fld.key === "aliases");
  return f ? infoboxFieldValues(f).map(normKey) : [];
}

/** Build the shared audit context from the full set of articles, so redlink
 *  recognition and stem resolution see the WHOLE vault (cross-article links). */
export function buildContext(articles: ArticleInput[]): AuditContext {
  const stems = new Set(articles.map((a) => a.stem));
  const known = new Set<string>();
  for (const stem of stems) known.add(normKey(stem));
  for (const a of articles) {
    for (const t of extractWikilinkTargets(a.content)) known.add(normKey(t));
    for (const k of infoboxAliasKeys(parseInfobox(a.content))) known.add(k);
  }
  return { stems, known };
}

// ---- the four checks -------------------------------------------------------

const COMPOUND_RE = /(^|_)and(_|$)/i;

function checkTitle(stem: string): ArticleAudit["title"] {
  if (!COMPOUND_RE.test(stem)) return { ok: true };
  if (COMPOUND_ALLOW.has(normKey(stem))) return { ok: true };
  return {
    ok: false,
    reason: `title "${stem}" looks like an X_and_Y blob (reject \`_and_\` unless a genuine compound entity)`,
  };
}

function checkInfobox(box: Infobox | null, ctx: AuditContext): ArticleAudit["infobox"] {
  const reasons: string[] = [];
  const links: InfoboxLinkAudit[] = [];
  // An infobox is PRESENT/populated when there is a fenced ```info block with at
  // least one `key: value` fact. A minimal `type`/`kind`/`aliases` block is fully
  // legitimate for a `domain`/`standard`/`person` — hardware spec fields belong
  // only on `thing`s (per Infobox_Schemas), so we do NOT demand world-facts.
  const present = box !== null && box.fields.length > 0;
  const populated = present;

  if (!present) reasons.push("no infobox present");

  if (box) {
    for (const f of box.fields) {
      if (malformedLinkCount(f.value) > 0) {
        links.push({ field: f.key, target: f.value, status: "dangling" });
        reasons.push(`infobox field \`${f.key}\` has a malformed wikilink`);
        continue;
      }
      for (const target of entityLinkTargets(f.value)) {
        const resolved = resolveWikilinkToStem(target, ctx.stems);
        let status: InfoboxLinkAudit["status"];
        if (resolved) status = "resolved";
        else if (ctx.known.has(normKey(target))) status = "redlink";
        else {
          status = "dangling";
          reasons.push(`infobox field \`${f.key}\` links to [[${target}]] — resolves to no article and is referenced nowhere (dangling)`);
        }
        links.push({ field: f.key, target, status });
      }
    }
  }

  const ok = present && populated && !links.some((l) => l.status === "dangling");
  return { ok, present, populated, links, reasons };
}

function checkFootnotes(content: string): ArticleAudit["footnotes"] {
  const { markers, defs } = parseFootnotes(content);
  const markerIdSet = new Set(markers.map((m) => m.id));
  const defCounts = new Map<string, number>();
  for (const d of defs) defCounts.set(d.id, (defCounts.get(d.id) ?? 0) + 1);
  const defIdSet = new Set(defCounts.keys());

  const danglingMarkers = [...markerIdSet].filter((id) => !defIdSet.has(id)).sort();
  const orphanDefs = [...defIdSet].filter((id) => !markerIdSet.has(id)).sort();
  const duplicateDefs = [...defCounts.entries()].filter(([, n]) => n > 1).map(([id]) => id).sort();

  const ok = danglingMarkers.length === 0 && orphanDefs.length === 0 && duplicateDefs.length === 0;
  return {
    ok,
    markerIds: [...markerIdSet].sort(),
    defIds: [...defIdSet].sort(),
    danglingMarkers,
    orphanDefs,
    duplicateDefs,
  };
}

const MARKER_RE = /\[\^([^\]]+)\](?!:)/;
const POINTER_RE = /^\*(Main article|Redirects to|Part of a series)\b/i;

/** A section is uncited when it carries prose claims but no `[^N]` marker. The
 *  structural sections (See also / References / Notes) and pure pointers/stubs
 *  are not claim-bearing, so they are exempt. */
function checkClaims(content: string, infoboxPopulated: boolean): ArticleAudit["claims"] {
  const lines = content.split(/\r?\n/);
  const skeleton = articleStructure(content);
  const reasons: string[] = [];
  const uncitedSections: string[] = [];

  const citationCount = parseFootnotes(content).defs.length;

  for (const item of skeleton) {
    if (item.kind !== "section") continue; // only claim-bearing body sections
    const body = lines.slice(item.startLine, item.endLine); // exclude the heading line
    let hasProse = false;
    let hasMarker = false;
    for (const raw of body) {
      const t = raw.trim();
      if (!t) continue;
      if (POINTER_RE.test(t)) continue; // {{Main}} / redirect / series banner
      if (/^\{\{.*\}\}$/.test(t)) continue; // {{stub}} and friends
      hasProse = true;
      if (MARKER_RE.test(t)) hasMarker = true;
    }
    if (hasProse && !hasMarker) {
      uncitedSections.push(item.title ?? `line ${item.startLine}`);
    }
  }

  if (uncitedSections.length > 0) {
    reasons.push(`uncited section(s): ${uncitedSections.join(", ")}`);
  }
  if (infoboxPopulated && citationCount === 0) {
    reasons.push("infobox present but article carries no citation (claims trace to nothing)");
  }

  const ok = uncitedSections.length === 0 && !(infoboxPopulated && citationCount === 0);
  return { ok, citationCount, uncitedSections, reasons };
}

// ---- per-article + vault audit ---------------------------------------------

export function auditArticle(article: ArticleInput, ctx: AuditContext): ArticleAudit {
  const box = parseInfobox(article.content);
  const title = checkTitle(article.stem);
  const infobox = checkInfobox(box, ctx);
  const footnotes = checkFootnotes(article.content);
  const claims = checkClaims(article.content, infobox.populated);

  const reasons: string[] = [];
  if (!title.ok && title.reason) reasons.push(title.reason);
  reasons.push(...infobox.reasons);
  if (footnotes.danglingMarkers.length) reasons.push(`footnote markers with no definition: ${footnotes.danglingMarkers.map((i) => `[^${i}]`).join(", ")}`);
  if (footnotes.orphanDefs.length) reasons.push(`footnote definitions with no marker: ${footnotes.orphanDefs.map((i) => `[^${i}]`).join(", ")}`);
  if (footnotes.duplicateDefs.length) reasons.push(`duplicate footnote definitions: ${footnotes.duplicateDefs.map((i) => `[^${i}]`).join(", ")}`);
  reasons.push(...claims.reasons);

  const pass = title.ok && infobox.ok && footnotes.ok && claims.ok;
  return { stem: article.stem, title, infobox, footnotes, claims, pass, reasons };
}

export interface AuditSummary {
  articleCount: number;
  structuralPass: number;
  structuralPassRate: number;
  withInfobox: number;
  withCitation: number;
  failingTitle: number;
  failingInfobox: number;
  failingFootnotes: number;
  failingClaims: number;
}

export function auditVault(articles: ArticleInput[]): { audits: ArticleAudit[]; summary: AuditSummary } {
  const ctx = buildContext(articles);
  const audits = articles
    .map((a) => auditArticle(a, ctx))
    .sort((a, b) => a.stem.localeCompare(b.stem));
  const summary: AuditSummary = {
    articleCount: audits.length,
    structuralPass: audits.filter((a) => a.pass).length,
    structuralPassRate: audits.length ? audits.filter((a) => a.pass).length / audits.length : 1,
    withInfobox: audits.filter((a) => a.infobox.populated).length,
    withCitation: audits.filter((a) => a.claims.citationCount >= 1).length,
    failingTitle: audits.filter((a) => !a.title.ok).length,
    failingInfobox: audits.filter((a) => !a.infobox.ok).length,
    failingFootnotes: audits.filter((a) => !a.footnotes.ok).length,
    failingClaims: audits.filter((a) => !a.claims.ok).length,
  };
  return { audits, summary };
}

// ---- vault loading ---------------------------------------------------------

export async function loadVaultArticles(root = vaultRoot()): Promise<ArticleInput[]> {
  const dir = articlesDir(root);
  let names: string[];
  try {
    names = await readdir(dir);
  } catch {
    return [];
  }
  const out: ArticleInput[] = [];
  for (const name of names) {
    if (!name.endsWith(".md") || name.startsWith(".")) continue;
    out.push({ stem: name.slice(0, -3), content: await readFile(join(dir, name), "utf8") });
  }
  return out;
}

// ---- CLI -------------------------------------------------------------------

async function main(): Promise<void> {
  const root = vaultRoot();
  const articles = await loadVaultArticles(root);
  if (articles.length === 0) {
    console.error(`no articles found under ${articlesDir(root)}`);
    process.exit(1);
  }
  const { audits, summary } = auditVault(articles);

  console.log(`Bootstrap audit — ${root}\n`);
  for (const a of audits) {
    const mark = a.pass ? "PASS" : "FAIL";
    const flags = [
      a.title.ok ? null : "title",
      a.infobox.ok ? null : "infobox",
      a.footnotes.ok ? null : "footnotes",
      a.claims.ok ? null : "claims",
    ].filter(Boolean);
    const infoboxTag = a.infobox.populated ? `box` : "no-box";
    console.log(`  [${mark}] ${a.stem}  (${infoboxTag}, ${a.claims.citationCount} cite)${flags.length ? "  ← " + flags.join(",") : ""}`);
    for (const r of a.reasons) console.log(`         · ${r}`);
  }

  const pct = (summary.structuralPassRate * 100).toFixed(1);
  console.log(`\nArticles:            ${summary.articleCount}`);
  console.log(`Structural pass:     ${summary.structuralPass}/${summary.articleCount} (${pct}%)`);
  console.log(`With infobox:        ${summary.withInfobox}`);
  console.log(`With ≥1 citation:    ${summary.withCitation}`);
  console.log(`Failing  title/infobox/footnotes/claims: ${summary.failingTitle}/${summary.failingInfobox}/${summary.failingFootnotes}/${summary.failingClaims}`);
  if (summary.articleCount > 40) {
    console.log(`\nNOTE: ${summary.articleCount} articles exceeds the ≤40 first-run gate (under-cover is success).`);
  }
}

if (import.meta.main) {
  await main();
}
