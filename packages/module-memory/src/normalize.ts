// mlx-bun memory — deterministic NORMALIZE pass (P6-T2). No model.
//
// After every write, before `commitVault`, an article is run through this pass
// so the invariants the read path depends on are CONSTITUTIVE, not advisory.
// Ported from lucien (~/Code/lucien): `normalize-footnotes.ts` (footnote
// bijection + contiguous renumber) and `normalize-wikilinks.ts` (spaced →
// underscore link canonicalization), extended with the Dreaming structural
// guards (infobox key sort, `## References` last / `## See also` before it,
// `{{stub}}` for thin articles, `title = H1 = stem`).
//
// Everything here is PURE (string in, string out) and idempotent: a second pass
// over a normalized article is a byte-identical no-op. Every step is non-fatal —
// a step that cannot complete logs a note and the others still run, so a single
// malformed region never corrupts the vault. `normalizeVault` is the on-disk
// entry the pipeline calls; the per-article core is `normalizeArticle`.

import { readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { isFenceLine, fenceLabel, parseInfobox, repairFences, serializeInfobox } from "./article";
import { articlesDir, listArticles, resolveWikilinkToStem, vaultRoot } from "./vault";

// ---- shared scanners --------------------------------------------------

const HEADING_RE = /^(#{1,6})\s+(.+)$/;
const DEF_LINE = /^[ \t]*\[\^(\d+)\]:/;
const SERIES_RE = /^\*Part of a series on \[\[([^\]]+)\]\]\.?\*$/;
/** A merged-away title's one-line pointer at its canonical article. */
const REDIRECT_RE = /^\*Redirects to \[\[[^\]]+\]\]\.?\*$/m;
/** The `{{stub}}` template, recognized only as a line of its own. */
const STUB_LINE_RE = /^\{\{stub\}\}\s*$/;
/** The `{{Main}}` summary-style pointer (`*Main article: [[Target]]*`). */
export const MAIN_POINTER_RE = /^\*Main article: \[\[[^\]]+\]\]\*$/;

// ---- footnote integrity (local copy of lucien wikify.ts) -------------

export interface CheckResult {
  ok: boolean;
  errors: string[];
}

/**
 * Verify footnote markers and definitions are consistent:
 * every `[^N]` body marker has a `[^N]:` definition and vice-versa; marker
 * numbers are contiguous from 1; every definition carries exactly one
 * backticked `conv:HASH`. (Ported from lucien `wikify.ts`.)
 */
export function checkFootnoteIntegrity(text: string): CheckResult {
  const errors: string[] = [];

  const defNums = new Set<number>();
  const defLineByNum = new Map<number, string>();
  for (const m of text.matchAll(/^\[\^(\d+)\]:(.*)$/gm)) {
    const n = parseInt(m[1]!, 10);
    defNums.add(n);
    defLineByNum.set(n, m[2]!);
  }

  // Body markers = every `[^N]` NOT on a `[^N]:` definition line. Only a
  // line-START `[^N]:` is a definition; a marker glued to a list colon
  // (`two types[^2]:`) is still a marker.
  const bodyText = text
    .split("\n")
    .filter((l) => !/^\[\^\d+\]:/.test(l))
    .join("\n");
  const markerNums = new Set<number>();
  for (const m of bodyText.matchAll(/\[\^(\d+)\]/g)) {
    markerNums.add(parseInt(m[1]!, 10));
  }

  for (const n of markerNums) {
    if (!defNums.has(n)) errors.push(`marker [^${n}] has no definition`);
  }
  for (const n of defNums) {
    if (!markerNums.has(n)) errors.push(`definition [^${n}] has no marker`);
  }

  const all = [...new Set([...markerNums, ...defNums])].sort((a, b) => a - b);
  for (let i = 0; i < all.length; i++) {
    if (all[i] !== i + 1) {
      errors.push(`footnote numbers not contiguous from 1 (saw ${all.join(",")})`);
      break;
    }
  }

  for (const [n, line] of defLineByNum) {
    const backticked = line.match(/`conv:[0-9a-z]{8}`/gi) ?? [];
    if (backticked.length !== 1) {
      errors.push(`[^${n}] definition lacks a backticked \`conv:HASH\` (found ${backticked.length})`);
    }
  }

  return { ok: errors.length === 0, errors };
}

/** True when two `[^N]:` definitions cite the same `conv:HASH` (the duplicate
 *  the merge step collapses); ignores defs without a hash. */
function hasDuplicateConvDefs(text: string): boolean {
  const seen = new Set<string>();
  for (const line of text.split("\n")) {
    const m = line.match(/^[ \t]*\[\^(\d+)\]:(.*)$/);
    if (!m) continue;
    const c = m[2]!.match(/conv:[0-9a-z]{8}/i);
    if (!c) continue;
    const h = c[0]!.toLowerCase();
    if (seen.has(h)) return true;
    seen.add(h);
  }
  return false;
}

// ---- footnote normalization (ported + merge) -------------------------

export interface NormalizeFootnoteResult {
  article: string;
  changed: boolean;
  /** Orphan body markers (no definition) that were dropped. */
  droppedMarkers: number[];
  /** Orphan definitions (no body marker) that were dropped. */
  droppedDefs: { num: number; conv: string | null }[];
  /** Definitions merged into an earlier def citing the same `conv:HASH`. */
  mergedDefs: number[];
  /** Auditable summary of what changed, or null on a no-op. */
  talk: string | null;
}

/** Distinct body-marker numbers in order of first appearance (defs masked). */
function bodyMarkerOrder(text: string): number[] {
  const masked = text
    .split("\n")
    .map((l) => (DEF_LINE.test(l) ? "" : l))
    .join("\n");
  const order: number[] = [];
  const seen = new Set<number>();
  for (const m of masked.matchAll(/\[\^(\d+)\]/g)) {
    const n = parseInt(m[1]!, 10);
    if (!seen.has(n)) {
      seen.add(n);
      order.push(n);
    }
  }
  return order;
}

/**
 * Deterministically repair footnote integrity (ported from lucien
 * `normalize-footnotes.ts`, extended to merge duplicate `conv:HASH` defs):
 * drop orphan markers and orphan defs, collapse two defs that cite the same
 * conversation into the earlier one, then renumber the survivors 1..k in order
 * of first body appearance. A bijective, duplicate-free article is returned
 * byte-identical (no-op), hence idempotent. Throws only if the post-condition
 * (`checkFootnoteIntegrity`) fails — the orchestrator catches that.
 */
export function normalizeFootnotes(article: string): NormalizeFootnoteResult {
  if (checkFootnoteIntegrity(article).ok && !hasDuplicateConvDefs(article)) {
    return { article, changed: false, droppedMarkers: [], droppedDefs: [], mergedDefs: [], talk: null };
  }

  const defNums = new Set<number>();
  const defConv = new Map<number, string | null>();
  for (const line of article.split("\n")) {
    const m = line.match(/^[ \t]*\[\^(\d+)\]:(.*)$/);
    if (m) {
      const n = parseInt(m[1]!, 10);
      defNums.add(n);
      const c = m[2]!.match(/conv:[0-9a-z]{8}/i);
      defConv.set(n, c ? c[0]!.toLowerCase() : null);
    }
  }

  const bodyOrder = bodyMarkerOrder(article);
  const bodySet = new Set(bodyOrder);

  // Markers that also have a definition — the merge/renumber candidates.
  const candidates = bodyOrder.filter((n) => defNums.has(n));
  const droppedMarkers = bodyOrder.filter((n) => !defNums.has(n));
  const droppedDefs = [...defNums]
    .filter((n) => !bodySet.has(n))
    .sort((a, b) => a - b)
    .map((n) => ({ num: n, conv: defConv.get(n) ?? null }));

  // Merge: each conv:HASH maps to its first-appearing candidate.
  const canonByConv = new Map<string, number>();
  const canonMap = new Map<number, number>();
  for (const n of candidates) {
    const c = defConv.get(n) ?? null;
    if (c === null) {
      canonMap.set(n, n);
      continue;
    }
    if (!canonByConv.has(c)) canonByConv.set(c, n);
    canonMap.set(n, canonByConv.get(c)!);
  }
  const mergedDefs = candidates.filter((n) => canonMap.get(n) !== n);

  // Survivors in first-appearance order → contiguous 1..k.
  const survivorOrder: number[] = [];
  const seenSurv = new Set<number>();
  for (const n of candidates) {
    const c = canonMap.get(n)!;
    if (!seenSurv.has(c)) {
      seenSurv.add(c);
      survivorOrder.push(c);
    }
  }
  const remap = new Map<number, number>();
  survivorOrder.forEach((oldN, i) => remap.set(oldN, i + 1));

  const dropMarkerSet = new Set(droppedMarkers);
  const dropDefSet = new Set<number>([...droppedDefs.map((d) => d.num), ...mergedDefs]);

  const out = article
    .split("\n")
    .filter((line) => {
      const m = line.match(DEF_LINE);
      return !(m && dropDefSet.has(parseInt(m[1]!, 10)));
    })
    .map((line) =>
      line.replace(/[ \t]?\[\^(\d+)\]/g, (whole, num: string) => {
        const n = parseInt(num, 10);
        if (dropMarkerSet.has(n)) return ""; // orphan marker
        const canon = canonMap.get(n) ?? n;
        const nn = remap.get(canon);
        const lead = /^[ \t]/.test(whole) ? whole[0]! : "";
        return nn ? `${lead}[^${nn}]` : whole;
      }),
    )
    .join("\n");

  const post = checkFootnoteIntegrity(out);
  if (!post.ok) {
    throw new Error(`normalize-footnotes post-condition failed: ${post.errors.join("; ")}`);
  }

  const parts: string[] = [];
  if (droppedMarkers.length) {
    parts.push(
      `Dropped ${droppedMarkers.length} orphan citation marker(s) — ` +
        droppedMarkers.map((n) => `[^${n}]`).join(", ") +
        ` — marker emitted with no definition; nothing recoverable, prose left intact.`,
    );
  }
  if (droppedDefs.length) {
    parts.push(
      `Dropped ${droppedDefs.length} unused definition(s): ` +
        droppedDefs.map((d) => `[^${d.num}]${d.conv ? ` (\`${d.conv}\`)` : ""}`).join(", ") +
        ` — no body marker referenced them.`,
    );
  }
  if (mergedDefs.length) {
    parts.push(
      `Merged ${mergedDefs.length} duplicate definition(s) (${mergedDefs
        .map((n) => `[^${n}]`)
        .join(", ")}) into the earlier footnote citing the same conversation.`,
    );
  }
  parts.push("Renumbered surviving footnotes contiguously from 1.");

  return {
    article: out,
    changed: out !== article,
    droppedMarkers,
    droppedDefs,
    mergedDefs,
    talk: parts.join(" "),
  };
}

// ---- wikilink canonicalization (ported) ------------------------------

export interface NormalizeWikilinkResult {
  content: string;
  /** Number of link targets rewritten to their canonical stem. */
  edits: number;
  /** Distinct unresolved (redlink) targets — flagged, not modified. */
  orphans: string[];
}

/**
 * Rewrite spaced/uncanonical wikilink targets to their underscore stem when the
 * stem is a known article (ported from lucien `normalize-wikilinks.ts`, using
 * `resolveWikilinkToStem` for resolution). The alias (`|alias`) and section
 * anchor (`#Section`) are display/match text and are preserved verbatim;
 * `conv:` and `Category:` links are left alone. Unresolved targets are true
 * redlinks — collected for flagging, never rewritten. Idempotent: an already
 * canonical link is untouched. Infobox entity-values are normalized by the same
 * pass (the replace runs over the whole article text, fence included).
 */
export function normalizeWikilinks(content: string, stems: Set<string>): NormalizeWikilinkResult {
  let edits = 0;
  const orphans = new Set<string>();

  const out = content.replace(/\[\[([^\]]+?)\]\]/g, (whole, inner: string) => {
    const pipeIdx = inner.indexOf("|");
    const alias = pipeIdx === -1 ? null : inner.slice(pipeIdx + 1);
    const beforeAlias = pipeIdx === -1 ? inner : inner.slice(0, pipeIdx);

    const hashIdx = beforeAlias.indexOf("#");
    const section = hashIdx === -1 ? null : beforeAlias.slice(hashIdx + 1);
    const target = hashIdx === -1 ? beforeAlias : beforeAlias.slice(0, hashIdx);

    const t = target.trim();
    if (!t || /^conv:/i.test(t) || /^Category:/i.test(t)) return whole;

    const resolved = resolveWikilinkToStem(t, stems);
    if (resolved === null) {
      orphans.add(t); // true redlink — flag, leave verbatim
      return whole;
    }
    if (resolved === target) return whole; // already canonical

    let rebuilt = resolved;
    if (section !== null) rebuilt += `#${section}`;
    if (alias !== null) rebuilt += `|${alias}`;
    edits++;
    return `[[${rebuilt}]]`;
  });

  return { content: out, edits, orphans: [...orphans] };
}

// ---- infobox key sort -------------------------------------------------

function findInfoBlock(lines: string[]): { start: number; end: number } | null {
  for (let i = 0; i < lines.length; i++) {
    if (isFenceLine(lines[i]!) && fenceLabel(lines[i]!) === "info") {
      for (let j = i + 1; j < lines.length; j++) {
        if (isFenceLine(lines[j]!)) return { start: i, end: j };
      }
      return null; // unterminated
    }
  }
  return null;
}

/** Schema keys lead (`type`, `kind`), `aliases` trails, the rest alphabetical. */
function infoboxKeyRank(key: string): number {
  if (key === "type") return 0;
  if (key === "kind") return 1;
  if (key === "aliases") return 3;
  return 2;
}

/** Sort an article's infobox fields into a deterministic, idempotent order. */
export function sortInfoboxKeys(content: string): { content: string; changed: boolean } {
  const box = parseInfobox(content);
  if (!box || box.fields.length === 0) return { content, changed: false };

  const sorted = box.fields
    .map((f, i) => ({ f, i }))
    .sort((a, b) => {
      const ra = infoboxKeyRank(a.f.key);
      const rb = infoboxKeyRank(b.f.key);
      if (ra !== rb) return ra - rb;
      const c = a.f.key.localeCompare(b.f.key);
      return c !== 0 ? c : a.i - b.i; // stable on equal keys
    })
    .map((x) => x.f);

  const sameOrder = sorted.every((f, i) => f === box.fields[i]);
  if (sameOrder) return { content, changed: false };

  const lines = content.split(/\r?\n/);
  const block = findInfoBlock(lines);
  if (!block) return { content, changed: false };

  const rendered = serializeInfobox({ ...box, fields: sorted }).split("\n");
  const next = [...lines.slice(0, block.start), ...rendered, ...lines.slice(block.end + 1)].join("\n");
  return { content: next, changed: next !== content };
}

// ---- structural guards ------------------------------------------------

interface TopSection {
  kind: "body" | "see" | "notes" | "refs";
  lines: string[];
}

function splitTopSections(content: string): { head: string[]; sections: TopSection[] } {
  const lines = content.split(/\r?\n/);
  const head: string[] = [];
  const sections: TopSection[] = [];
  let cur: TopSection | null = null;
  let inFence = false;
  for (const line of lines) {
    if (isFenceLine(line)) {
      inFence = !inFence;
      (cur ? cur.lines : head).push(line);
      continue;
    }
    if (!inFence) {
      const h = HEADING_RE.exec(line);
      if (h && h[1]!.length === 2) {
        const title = h[2]!.trim().toLowerCase();
        const kind: TopSection["kind"] =
          title === "see also" ? "see" : title === "notes" ? "notes" : title === "references" ? "refs" : "body";
        cur = { kind, lines: [line] };
        sections.push(cur);
        continue;
      }
    }
    (cur ? cur.lines : head).push(line);
  }
  return { head, sections };
}

/** Merge several same-kind trailing-meta sections (the duplicate `## References` /
 *  `## See also` blocks a fence-confused PATCH/cross-link left behind) into ONE:
 *  keep the first heading, then the union of every block's body lines with
 *  duplicate lines dropped (first occurrence wins) so repeated See-also bullets
 *  collapse and split footnote defs coalesce. Idempotent on a singleton group. */
function mergeMetaGroup(group: TopSection[]): TopSection {
  if (group.length === 1) return group[0]!;
  const heading = group[0]!.lines[0]!;
  const body: string[] = [];
  const seen = new Set<string>();
  for (const s of group) {
    for (const line of s.lines.slice(1)) {
      const key = line.trim();
      if (key === "") {
        if (body.length && body[body.length - 1] !== "") body.push("");
        continue;
      }
      if (seen.has(key)) continue;
      seen.add(key);
      body.push(line);
    }
  }
  while (body.length && body[body.length - 1] === "") body.pop();
  return { kind: group[0]!.kind, lines: [heading, ...body, ""] };
}

/** Reorder trailing meta sections so body → `See also` → `Notes` → `References`
 *  (References always last), MERGING any duplicate same-kind meta blocks into one
 *  along the way. Idempotent: an already-correct article (one block per kind, in
 *  order) is returned untouched. */
export function reorderSections(content: string): { content: string; changed: boolean } {
  const { head, sections } = splitTopSections(content);
  if (sections.length === 0) return { content, changed: false };

  // Body sections stay distinct and in document order; the trailing-meta kinds are
  // singletons by grammar, so collapse any duplicates into one block per kind.
  const ordered: TopSection[] = sections.filter((s) => s.kind === "body");
  for (const kind of ["see", "notes", "refs"] as const) {
    const group = sections.filter((s) => s.kind === kind);
    if (group.length) ordered.push(mergeMetaGroup(group));
  }

  const same = ordered.length === sections.length && ordered.every((s, i) => s === sections[i]);
  if (same) return { content, changed: false };

  const next = [...head, ...ordered.flatMap((s) => s.lines)].join("\n");
  return { content: next, changed: next !== content };
}

/** Enforce `title = H1 = stem` (underscores → spaces). Rewrites a divergent H1
 *  and prepends one when absent. */
export function enforceH1Title(content: string, stem: string): { content: string; changed: boolean } {
  const canonical = stem.replace(/_/g, " ");
  const lines = content.split(/\r?\n/);
  let inFence = false;
  for (let i = 0; i < lines.length; i++) {
    if (isFenceLine(lines[i]!)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const h = HEADING_RE.exec(lines[i]!);
    if (h && h[1]!.length === 1) {
      if (h[2]!.trim() === canonical) return { content, changed: false };
      lines[i] = `# ${canonical}`;
      return { content: lines.join("\n"), changed: true };
    }
  }
  // No H1 found — prepend the canonical title.
  return { content: `# ${canonical}\n\n${content}`, changed: true };
}

/** Body-section count and body-prose word count, EXCLUDING the infobox and the
 *  `## References` section (the L1 stub threshold inputs). */
export function articleThinness(content: string): { bodySections: number; bodyWords: number; stub: boolean } {
  const lines = content.split(/\r?\n/);
  let inFence = false;
  let inRefs = false;
  let bodySections = 0;
  let bodyWords = 0;
  for (const line of lines) {
    if (isFenceLine(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const h = HEADING_RE.exec(line);
    if (h) {
      if (h[1]!.length === 2) {
        const title = h[2]!.trim().toLowerCase();
        inRefs = title === "references";
        if (title !== "references" && title !== "see also" && title !== "notes") bodySections++;
      }
      continue; // headings are not prose
    }
    if (inRefs) continue;
    const t = line.trim();
    if (!t) continue;
    if (STUB_LINE_RE.test(t)) continue;
    if (/^categories:/i.test(t)) continue;
    if (SERIES_RE.test(t)) continue;
    bodyWords += t.split(/\s+/).length;
  }
  return { bodySections, bodyWords, stub: bodySections < 2 || bodyWords < 40 };
}

/** True when the article carries a `{{stub}}` line. */
export function hasStubMarker(content: string): boolean {
  return content.split(/\r?\n/).some((l) => STUB_LINE_RE.test(l));
}

/** Mark a thin article `{{stub}}` (after the H1); remove a stale marker once the
 *  article has outgrown the threshold. */
export function stubGuard(content: string): { content: string; changed: boolean } {
  const thin = articleThinness(content).stub;
  const has = hasStubMarker(content);
  if (thin === has) return { content, changed: false };

  const lines = content.split(/\r?\n/);
  if (!thin && has) {
    const next = lines.filter((l) => !STUB_LINE_RE.test(l)).join("\n");
    return { content: next, changed: next !== content };
  }
  // thin && !has — insert after the H1 (or at the very top if none).
  let inFence = false;
  let h1 = -1;
  for (let i = 0; i < lines.length; i++) {
    if (isFenceLine(lines[i]!)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const h = HEADING_RE.exec(lines[i]!);
    if (h && h[1]!.length === 1) {
      h1 = i;
      break;
    }
  }
  if (h1 < 0) lines.unshift("{{stub}}", "");
  else lines.splice(h1 + 1, 0, "", "{{stub}}");
  return { content: lines.join("\n"), changed: true };
}

// ---- orchestrator -----------------------------------------------------

export interface NormalizeArticleResult {
  content: string;
  changed: boolean;
  /** Human-readable record of every normalization applied (non-fatal log). */
  notes: string[];
  /** Whether the normalized article is marked `{{stub}}`. */
  stub: boolean;
  /** Whether the article is a merge redirect (heavy guards are skipped). */
  redirect: boolean;
}

/**
 * Run the full deterministic NORMALIZE pass over one article. Every step is
 * non-fatal: a step that throws (a footnote post-condition it cannot satisfy,
 * say) is logged and skipped while the others still run, so a malformed region
 * never blocks the rest. Idempotent.
 */
export function normalizeArticle(content: string, opts: { stem: string; stems: Set<string> }): NormalizeArticleResult {
  const notes: string[] = [];
  let out = content;
  const redirect = REDIRECT_RE.test(out);

  // 0. Fence repair — heal an unbalanced ``` BEFORE any fence-aware step runs.
  // An odd fence count leaves reorder/stub/H1 (and the read path) stuck "in code"
  // for the rest of the file, so trailing ## References / ## See also are never
  // recognized. Closing the dangling fence restores them. Non-fatal, idempotent.
  const fx = repairFences(out);
  if (fx.changed) {
    out = fx.content;
    notes.push("repaired unbalanced code fence");
  }

  // 1. Footnote bijection + renumber + merge.
  try {
    const fr = normalizeFootnotes(out);
    if (fr.changed) {
      out = fr.article;
      if (fr.droppedMarkers.length) notes.push(`dropped ${fr.droppedMarkers.length} orphan footnote marker(s)`);
      if (fr.droppedDefs.length) notes.push(`dropped ${fr.droppedDefs.length} orphan footnote def(s)`);
      if (fr.mergedDefs.length) notes.push(`merged ${fr.mergedDefs.length} duplicate footnote def(s)`);
      notes.push("renumbered footnotes contiguously");
    }
  } catch (err) {
    notes.push(`footnote normalization skipped: ${(err as Error).message}`);
  }

  // 2. Wikilink canonicalization (prose + infobox entity-values).
  const wl = normalizeWikilinks(out, opts.stems);
  if (wl.edits > 0) {
    out = wl.content;
    notes.push(`canonicalized ${wl.edits} wikilink(s)`);
  }
  if (wl.orphans.length) notes.push(`unresolved wikilink(s): ${wl.orphans.join(", ")}`);

  // 3. Infobox key sort.
  const ib = sortInfoboxKeys(out);
  if (ib.changed) {
    out = ib.content;
    notes.push("sorted infobox keys");
  }

  // 4. Structural guards.
  const h1 = enforceH1Title(out, opts.stem);
  if (h1.changed) {
    out = h1.content;
    notes.push("normalized H1 title to stem");
  }
  if (!redirect) {
    const ro = reorderSections(out);
    if (ro.changed) {
      out = ro.content;
      notes.push("reordered trailing sections (References last)");
    }
    const sg = stubGuard(out);
    if (sg.changed) {
      out = sg.content;
      notes.push(hasStubMarker(out) ? "marked {{stub}} (thin article)" : "removed stale {{stub}}");
    }
  }

  return { content: out, changed: out !== content, notes, stub: hasStubMarker(out), redirect };
}

// ---- on-disk entry (runs after every write, before commitVault) ------

export interface VaultNormalizeSummary {
  /** Stems whose on-disk content changed. */
  normalized: string[];
  /** Per-stem normalization notes (only stems with at least one note). */
  notes: Record<string, string[]>;
}

/**
 * Normalize every article in the vault, writing back the ones that changed.
 * Best-effort and non-fatal per article; the caller commits afterward. The stem
 * set is the whole article list so wikilink resolution sees every neighbor.
 */
export async function normalizeVault(root = vaultRoot()): Promise<VaultNormalizeSummary> {
  const stems = await listArticles(root);
  const stemSet = new Set(stems);
  const normalized: string[] = [];
  const notes: Record<string, string[]> = {};

  for (const stem of stems) {
    const path = join(articlesDir(root), `${stem}.md`);
    let content: string;
    try {
      content = await readFile(path, "utf8");
    } catch {
      continue;
    }
    const r = normalizeArticle(content, { stem, stems: stemSet });
    if (r.notes.length) notes[stem] = r.notes;
    if (r.changed) {
      await writeFile(path, r.content);
      normalized.push(stem);
    }
  }

  return { normalized, notes };
}
