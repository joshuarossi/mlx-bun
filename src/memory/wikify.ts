// mlx-bun memory — the LLM WIKIFY structural pass (P8-T1 / P8-T2).
//
// The periodic editorial sweep, distinct from the deterministic NORMALIZE pass
// (`normalize.ts`). Where NORMALIZE enforces invariants with zero judgment,
// WIKIFY asks the local model for JUDGMENT — and the deterministic gate disposes
// of weak judgment (LoRAs propose, gates dispose). It runs PERIODICALLY (the
// nightly sweep), NOT per chunk, after synthesis has folded the day's notes in.
//
// Two nodes, both behind the conservative gate (`gateEdit`) + NORMALIZE:
//   P8-T1 · per-section IMPROVE — port of lucien `scripts/wikify.ts`
//           buildEditorialPrompt, applied PER SECTION via callLocal("editor"):
//           "tighten this section, keep every citation and every specific
//           detail, do not generalize away particulars." A weak edit is a NO-OP
//           — the section keeps its original bytes.
//   P8-T2 · infobox EXTRACT/REFRESH — pull the kind's structured key-value facts
//           out of the article (entity-valued fields → [[wikilinks]], declared
//           aliases: feed the entity index on reindex). Creates infoboxes where
//           missing and refreshes them where present, never losing a grounded
//           fact; the single-info-block invariant is asserted.
//
// Every prompt here is SCHEMATIC — no copyable concrete values — because a small
// base model parrots example values verbatim (the policy-example parroting bug).
// Meta/reasoning leakage is rejected by the shared `isLeakyDraft` heuristic.

import {
  articleStructure,
  infoboxAliases,
  isFenceLine,
  fenceLabel,
  parseInfobox,
  validateArticleStructure,
  type EntityKind,
} from "./article";
import { checkFootnoteIntegrity, gateEdit, type GateVerdict } from "./gate";
import { callLocal } from "./model";
import { articleThinness, hasStubMarker, normalizeArticle } from "./normalize";
import {
  assembleArticle,
  buildInfoboxFields,
  countFencedInfoBlocks,
  entityStem,
  isLeakyDraft,
  replaceSection,
  sanitizeSection,
  type SynthesisCall,
} from "./synthesize";
import { articlesDir, commitVault, extractSection, listArticles, slugifyHeading, vaultRoot } from "./vault";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

// ===========================================================================
// P8-T1 — per-section IMPROVE (the editorial tighten node)
// ===========================================================================

/** The per-section editorial prompt — a section-scoped port of lucien
 *  `scripts/wikify.ts` EDITORIAL_PROMPT. Purely SCHEMATIC: it names no concrete
 *  value the model could copy. The hard invariant (keep every [^N] and every
 *  particular) is what the gate then enforces deterministically. */
const SECTION_EDITORIAL_PROMPT = `You are an expert Wikipedia editor tightening ONE section of a personal-wiki article. You are NOT given new source material — your only job is to restructure and condense the section below into its leanest, clearest form.

TIGHTEN:
- Remove redundancy: wherever the same point, fact, or example is stated more than once, merge it into ONE clean sentence and delete the echoes. State each thing exactly once, in the right place.
- Improve flow: order the sentences so the section reads cleanly; fix run-ons and filler.

HARD INVARIANT — preserve every particular (non-negotiable):
- Keep EVERY citation marker [^N] exactly — never drop, renumber, or invent one.
- Keep EVERY specific detail: names, model numbers, measurements, prices, dates, and stated opinions. Do NOT generalize a particular into a vague summary; do NOT drop a claim.
- Do NOT add any claim the section did not already make.

OUTPUT:
Output ONLY the tightened section prose. Do NOT repeat the section heading, do NOT write any other section, do NOT write a "## References" section or any [^N]: definition line. No preamble, no explanation, no code fences.

SECTION TO TIGHTEN:
{{SECTION}}
`;

/** Build the per-section editorial prompt for one section's body prose. */
export function buildSectionEditorialPrompt(sectionBody: string): string {
  return SECTION_EDITORIAL_PROMPT.replace("{{SECTION}}", sectionBody);
}

/** Distinct `[^N]` marker numbers in a section body (definition lines excluded —
 *  a section body never carries defs; those live in `## References`). */
function bodyMarkers(text: string): Set<number> {
  const out = new Set<number>();
  for (const line of text.split("\n")) {
    if (/^\s*\[\^\d+\]:/.test(line)) continue;
    for (const m of line.matchAll(/\[\^(\d+)\]/g)) out.add(parseInt(m[1]!, 10));
  }
  return out;
}

/** The body-section titles of an article (in document order), excluding the
 *  lead, See also, Notes, and References — only the sections an editorial tighten
 *  should touch. */
export function improvableSectionTitles(content: string): string[] {
  return articleStructure(content)
    .filter((it) => it.kind === "section" && it.title)
    .map((it) => it.title!);
}

export interface SectionImproveResult {
  /** The article with every accepted section swapped in (raw — caller NORMALIZEs). */
  content: string;
  /** Sections whose tightened body passed the gate and was swapped in. */
  improved: string[];
  /** Sections whose tightened body was a weak edit (leak / dropped a citation /
   *  below the word floor / gate veto) — the original section was kept. */
  rejected: string[];
}

/**
 * P8-T1 driver. Tighten each body section in turn via `call("editor", …)`,
 * accepting the edit ONLY when it survives the gate, otherwise keeping the
 * section's original bytes (a weak edit is a NO-OP). The gate is applied at the
 * whole-article level after swapping the candidate section in, so the footnote
 * bijection (a dropped [^N] orphans its `## References` def) and citation
 * preservation are checked the same way the write pipeline checks every edit;
 * a per-section word floor + leak check pre-reject the obvious failures. Pure
 * with respect to disk — the caller persists.
 */
export async function improveSections(
  content: string,
  opts: { call: SynthesisCall; floor?: number; maxTokens?: number },
): Promise<SectionImproveResult> {
  const floor = opts.floor ?? 0.7;
  const maxTokens = opts.maxTokens ?? 512;
  let working = content;
  const improved: string[] = [];
  const rejected: string[] = [];

  for (const title of improvableSectionTitles(working)) {
    const anchor = slugifyHeading(title);
    const block = extractSection(working, anchor);
    if (block == null) continue;
    const lines = block.split("\n");
    const headingLine = lines[0] ?? `## ${title}`;
    const beforeBody = lines.slice(1).join("\n").trim();
    if (!beforeBody) continue; // empty section — nothing to tighten

    const raw = await opts.call(buildSectionEditorialPrompt(beforeBody), { maxTokens });
    const candidate = sanitizeSection(raw, title);

    // Pre-reject the obvious failures before the swap: a meta/reasoning leak, or
    // a dropped citation marker (also caught by the whole-article footnote
    // bijection below, but rejected here with a crisp per-section reason). A
    // per-section word floor is deliberately NOT applied — legitimately removing
    // a duplicated sentence can halve a short section's words; the bulk-deletion
    // guard is the whole-article gate's floor, which sees all the structural text.
    if (!candidate.trim() || isLeakyDraft(candidate)) {
      rejected.push(title);
      continue;
    }
    const beforeMarkers = bodyMarkers(beforeBody);
    const afterMarkers = bodyMarkers(candidate);
    const lostCitation = [...beforeMarkers].some((n) => !afterMarkers.has(n));
    if (lostCitation) {
      rejected.push(title);
      continue;
    }

    // Whole-article gate: swap the candidate in and verify the edit preserved
    // the article (footnote bijection, citations, structure). Weak → keep original.
    const trial = replaceSection(working, anchor, `${headingLine}\n\n${candidate}\n`);
    if (trial == null) continue;
    const verdict: GateVerdict = gateEdit(working, trial, { floor });
    if (verdict.ok) {
      working = trial;
      improved.push(title);
    } else {
      rejected.push(title);
    }
  }

  return { content: working, improved, rejected };
}

// ===========================================================================
// P8-T2 — infobox EXTRACT / REFRESH
// ===========================================================================

/** The infobox extraction prompt — SCHEMATIC (no copyable spec values). The
 *  model proposes `key: value` facts; `buildInfoboxFields` then applies the
 *  grounded-field rule (physical-spec keys only on a `kind:thing`), drops any
 *  model-supplied kind/aliases (we own those), and orders the block. */
function buildInfoboxRefreshPrompt(title: string, body: string, otherArticles: string): string {
  return (
    `Use ONLY content from the article below; never copy any name or value from these instructions.\n` +
    `You are extracting the INFOBOX facts for the personal-wiki article about "${title}". ` +
    `Read the article below and emit its structured key-value facts. Output ONLY \`key: value\` lines, one per line, no fence, no prose. Rules:\n` +
    `- snake_case keys.\n` +
    `- A value that names another entity is a [[wikilink]] to one of the stems in OTHER ARTICLES (a related entity, component, or standard).\n` +
    `- Emit a world-fact (a spec-sheet/citable property) only if the article states it; emit a relationship-fact (owned / acquired / used_for / chosen_over / opinion) the article establishes.\n` +
    `- Include \`type:\` (the emergent label) when the article makes it clear.\n` +
    `- Do NOT emit \`kind:\` or \`aliases:\` — those are added for you.\n` +
    `- Never guess a spec the article does not state.\n\n` +
    `OTHER ARTICLES (link targets):\n${otherArticles}\n\n` +
    `ARTICLE:\n${body}\n`
  );
}

/** The article text the extractor reads — capped so the prefill stays bounded. */
function infoboxSourceText(content: string, cap = 4000): string {
  return content.slice(0, cap);
}

/** A stem list block for the extractor so its [[wikilinks]] resolve. */
function otherArticlesBlock(stems: Iterable<string>, selfStem: string, cap = 200): string {
  const list = [...stems].filter((s) => s !== selfStem).sort((a, b) => a.localeCompare(b)).slice(0, cap);
  return list.length ? list.map((s) => `- ${s}`).join("\n") : "(none yet)";
}

/**
 * Merge the model's freshly-extracted facts with the article's existing infobox
 * into the final ordered field list. EXISTING facts are placed first so
 * `buildInfoboxFields`' first-occurrence-wins keeps a grounded [[wikilink]] (a
 * `<entity_key>: [[Linked Entity]]` already in the vault) sticky — a refresh adds
 * new keys and the declared aliases, it never degrades a linked fact to a bare scalar or drops
 * one. With no existing infobox this is a pure CREATE (only the model's facts).
 */
export function refreshInfoboxFields(
  content: string,
  kind: EntityKind,
  modelRaw: string,
  declaredAliases: string[] = [],
): string[] {
  const box = parseInfobox(content);
  const existingLines: string[] = [];
  if (box) {
    for (const f of box.fields) {
      if (f.key === "kind" || f.key === "aliases") continue;
      existingLines.push(`${f.key}: ${f.value}`);
    }
  }
  const existingAliases = box ? infoboxAliases(box) : [];
  const aliases = [...existingAliases, ...declaredAliases];
  const combinedRaw = `${existingLines.join("\n")}\n${modelRaw}`;
  return buildInfoboxFields(combinedRaw, kind, aliases);
}

/** The line range `[start, end]` (inclusive) of the first fenced ```info block,
 *  or null when there is none. */
function findInfoBlockRange(lines: string[]): { start: number; end: number } | null {
  for (let i = 0; i < lines.length; i++) {
    if (isFenceLine(lines[i]!) && fenceLabel(lines[i]!) === "info") {
      for (let j = i + 1; j < lines.length; j++) {
        if (isFenceLine(lines[j]!)) return { start: i, end: j };
      }
      return null; // unterminated — not a usable block
    }
  }
  return null;
}

const HEADING_RE = /^(#{1,6})\s+/;
const SERIES_RE = /^\*Part of a series on \[\[/;

/** The index after which a freshly-created infobox should be inserted: after the
 *  H1, or after a series banner when one follows the H1 (the grammar order is
 *  H1 → series → infobox → lead). Returns -1 when there is no H1 (prepend). */
function infoboxInsertAfter(lines: string[]): number {
  let inFence = false;
  let h1 = -1;
  let banner = -1;
  for (let i = 0; i < lines.length; i++) {
    if (isFenceLine(lines[i]!)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const t = lines[i]!.trim();
    if (h1 < 0 && HEADING_RE.test(lines[i]!) && lines[i]!.startsWith("# ")) h1 = i;
    else if (h1 >= 0 && banner < 0 && SERIES_RE.test(t)) banner = i;
  }
  return Math.max(h1, banner);
}

/**
 * Write `fields` into the article as the ONE fenced ```info block: replace an
 * existing block in place, else insert a fresh block after the H1 / series
 * banner. Returns the new content. Pure.
 */
export function setInfobox(content: string, fields: string[]): string {
  const blockLines = ["```info", ...fields, "```"];
  const lines = content.split(/\r?\n/);
  const range = findInfoBlockRange(lines);
  if (range) {
    const next = [...lines.slice(0, range.start), ...blockLines, ...lines.slice(range.end + 1)];
    return next.join("\n");
  }
  const after = infoboxInsertAfter(lines);
  if (after < 0) return [...blockLines, "", ...lines].join("\n");
  const next = [...lines.slice(0, after + 1), "", ...blockLines, ...lines.slice(after + 1)];
  return next.join("\n");
}

export interface InfoboxRefreshResult {
  /** The article with the refreshed single ```info block (raw — caller NORMALIZEs). */
  content: string;
  /** True when the on-disk content changed. */
  changed: boolean;
  /** The final ordered infobox field lines. */
  fields: string[];
  /** Set when the refresh was rejected (e.g. it would yield >1 info block). */
  reason: string | null;
}

/**
 * P8-T2 driver. Extract/refresh the entity's infobox: ask `call("editor", …)`
 * for the structured facts, merge them with the existing box (grounded facts
 * sticky), and write back the single ```info block. The single-info-block
 * invariant is asserted via `countFencedInfoBlocks` — a result with more than
 * one block is rejected (NO-OP) rather than committed. Pure with respect to disk.
 */
export async function refreshInfobox(
  content: string,
  opts: {
    title: string;
    stem: string;
    kind: EntityKind;
    call: SynthesisCall;
    stems?: Set<string>;
    aliases?: string[];
    maxTokens?: number;
  },
): Promise<InfoboxRefreshResult> {
  const stems = new Set(opts.stems ?? []);
  stems.add(opts.stem);
  const otherArticles = otherArticlesBlock(stems, opts.stem);
  const raw = await opts.call(
    buildInfoboxRefreshPrompt(opts.title, infoboxSourceText(content), otherArticles),
    { maxTokens: opts.maxTokens ?? 192 },
  );
  const fields = refreshInfoboxFields(content, opts.kind, raw, opts.aliases ?? []);
  const next = setInfobox(content, fields);

  if (countFencedInfoBlocks(next) !== 1) {
    return { content, changed: false, fields, reason: `refresh would yield ${countFencedInfoBlocks(next)} info blocks` };
  }
  return { content: next, changed: next !== content, fields, reason: null };
}

// ===========================================================================
// Effectful entry — wikify one vault article (sections + infobox)
// ===========================================================================

export interface WikifyArticleOptions {
  /** Article filename stem. */
  stem: string;
  /** Entity kind for the grounded-field rule; defaults to the infobox `kind:` or "thing". */
  kind?: EntityKind;
  /** Declared aliases to fold into the infobox `aliases:` line. */
  aliases?: string[];
  /** Vault root (honors MLX_BUN_WIKI); defaults to `vaultRoot()`. */
  root?: string;
  /** Model-call override (tests inject a fake). Defaults to `callLocal("editor", …)`. */
  call?: SynthesisCall;
  /** Run the per-section tighten node (P8-T1). Default true. */
  improveSections?: boolean;
  /** Run the infobox extract/refresh node (P8-T2). Default true. */
  refreshInfobox?: boolean;
  /** Skip the git commit (tests). */
  commit?: boolean;
  floor?: number;
}

export interface WikifyArticleResult {
  stem: string;
  status: "edited" | "unchanged" | "rejected";
  /** Sections tightened and accepted by the gate. */
  sectionsImproved: number;
  /** Sections whose tightened body was a weak edit, original kept. */
  weakEditRejected: number;
  /** True when the infobox was created/refreshed. */
  infoboxRefreshed: boolean;
  /** Veto reason when the final article failed the gate; null otherwise. */
  reason: string | null;
  normalizeNotes: string[];
}

/**
 * Wikify ONE vault article end to end: per-section tighten (P8-T1) → infobox
 * extract/refresh (P8-T2) → NORMALIZE → final gate → write + commit. The final
 * `gateEdit(original, normalized)` is the global safety net: if the cumulative
 * edit somehow degraded the article (citation/structure/word-floor loss), the
 * whole pass is a NO-OP and the vault stays byte-for-byte unchanged.
 */
export async function wikifyArticle(opts: WikifyArticleOptions): Promise<WikifyArticleResult> {
  const root = opts.root ?? vaultRoot();
  const call: SynthesisCall = opts.call ?? ((p, o) => callLocal("editor", { user: p }, o));
  const path = join(articlesDir(root), `${opts.stem}.md`);
  const base: WikifyArticleResult = {
    stem: opts.stem,
    status: "unchanged",
    sectionsImproved: 0,
    weakEditRejected: 0,
    infoboxRefreshed: false,
    reason: null,
    normalizeNotes: [],
  };

  let original: string;
  try {
    original = await readFile(path, "utf8");
  } catch {
    return { ...base, status: "rejected", reason: `article not found: ${opts.stem}` };
  }

  const stems = new Set(await listArticles(root));
  const box = parseInfobox(original);
  const kind: EntityKind = opts.kind ?? (box ? box.entityKind : "thing");
  const title = opts.stem.replace(/_/g, " ");

  let working = original;
  let sectionsImproved = 0;
  let weakEditRejected = 0;
  let infoboxRefreshed = false;

  if (opts.improveSections !== false) {
    const r = await improveSections(working, { call, floor: opts.floor });
    working = r.content;
    sectionsImproved = r.improved.length;
    weakEditRejected = r.rejected.length;
  }

  if (opts.refreshInfobox !== false) {
    const r = await refreshInfobox(working, { title, stem: opts.stem, kind, call, stems, aliases: opts.aliases });
    if (r.changed && r.reason == null) {
      working = r.content;
      infoboxRefreshed = true;
    }
  }

  const norm = normalizeArticle(working, { stem: opts.stem, stems });
  const result: WikifyArticleResult = {
    ...base,
    sectionsImproved,
    weakEditRejected,
    infoboxRefreshed,
    normalizeNotes: norm.notes,
  };

  if (norm.content === original) return { ...result, status: "unchanged" };

  // Final global safety net — the same conservative gate the write path uses.
  // A {{stub}} article legitimately falls below the prose floor, so the gate is
  // advisory there; otherwise a veto means NO-OP.
  const verdict = gateEdit(original, norm.content, { floor: opts.floor });
  if (!verdict.ok && !hasStubMarker(norm.content)) {
    return { ...result, status: "rejected", reason: verdict.reason };
  }

  await mkdir(articlesDir(root), { recursive: true });
  await writeFile(path, norm.content);
  if (opts.commit !== false) {
    await commitVault(root, `memory: wikify ${opts.stem} (+${sectionsImproved} sections${infoboxRefreshed ? ", infobox" : ""})`);
  }
  return { ...result, status: "edited" };
}

export interface WikifyVaultSummary {
  /** Stems whose on-disk content changed. */
  edited: string[];
  /** Per-stem result for every article processed. */
  results: WikifyArticleResult[];
}

/**
 * Wikify every article in the vault (the periodic sweep). Best-effort and
 * non-fatal per article; the caller drives scheduling. Each article commits its
 * own change (or is a NO-OP).
 */
export async function wikifyVault(
  opts: { root?: string; call?: SynthesisCall; commit?: boolean; floor?: number } = {},
): Promise<WikifyVaultSummary> {
  const root = opts.root ?? vaultRoot();
  const stems = await listArticles(root);
  const edited: string[] = [];
  const results: WikifyArticleResult[] = [];
  for (const stem of stems) {
    const r = await wikifyArticle({ stem, root, call: opts.call, commit: opts.commit, floor: opts.floor });
    results.push(r);
    if (r.status === "edited") edited.push(stem);
  }
  return { edited, results };
}

// ===========================================================================
// P8-T3 — summary-style SPLIT + series banner maintenance
//
// FORWARD maintenance, not a legacy retrofit: our vault is rebuilt entity-
// granular from chunks, so a section only outgrows its article LATER as nightly
// patches accrete. When one section comes to dominate the article (large in
// absolute prose AND bigger than every other body section combined), it is split
// into its own child entity article — the child takes the full cited prose + a
// minimal infobox, the parent keeps a 2–3 sentence summary and a
// `*Main article: [[Child]]*` pointer (the {{Main}} edge `reindex` records as
// via=main). EVERY [^N] in the moved section travels to the child; the parent's
// now-orphan defs are dropped by NORMALIZE, so no citation is lost.
//
// The split deliberately SKIPS the word-floor gate (it is a sanctioned bulk move,
// not an accidental deletion); its gate is structural — both halves must stay
// `validateArticleStructure`-clean and footnote-bijective, else the split is a
// NO-OP. Series-banner maintenance keeps a single `*Part of a series on [[X]].*`
// line directly under the H1.
// ===========================================================================

function wordCount(s: string): number {
  const t = s.trim();
  return t ? t.split(/\s+/).length : 0;
}

/** The H1 title of an article (the first `# Title` line), or "". */
function articleTitle(content: string): string {
  for (const line of content.split(/\r?\n/)) {
    const m = /^#\s+(.+)$/.exec(line);
    if (m) return m[1]!.trim();
  }
  return "";
}

/** Map each `[^N]:` definition number to its full definition line. */
function referenceDefMap(content: string): Map<number, string> {
  const out = new Map<number, string>();
  for (const line of content.split("\n")) {
    const d = /^\[\^(\d+)\]:.*$/.exec(line);
    if (d) out.set(parseInt(d[1]!, 10), line);
  }
  return out;
}

/** The first `n` sentences of `text`, whitespace-collapsed (the deterministic
 *  summary fallback when no model is supplied / its draft is unusable). */
function firstSentences(text: string, n: number): string {
  const flat = text.replace(/\s+/g, " ").trim();
  if (!flat) return "";
  const parts = flat.match(/[^.!?]+[.!?]+|\S[^.!?]*$/g) ?? [flat];
  return parts.slice(0, Math.max(1, n)).join(" ").trim();
}

export interface BodySectionSize {
  title: string;
  anchor: string;
  /** Word count of the section's body prose (heading excluded). */
  words: number;
}

/** Per body-section prose word counts (excludes lead, See also, Notes,
 *  References — only the `section` skeleton items). */
export function bodySectionSizes(content: string): BodySectionSize[] {
  const lines = content.split(/\r?\n/);
  const out: BodySectionSize[] = [];
  for (const it of articleStructure(content)) {
    if (it.kind !== "section" || !it.title) continue;
    const body = lines.slice(it.startLine, it.endLine).join("\n");
    out.push({ title: it.title, anchor: slugifyHeading(it.title), words: wordCount(body) });
  }
  return out;
}

export interface SplitCandidate {
  title: string;
  anchor: string;
  /** The candidate section's body word count. */
  words: number;
  /** Combined body word count of every OTHER body section. */
  otherWords: number;
}

/**
 * Detect a section that has outgrown the article: a body section that is large
 * in absolute prose (≥ `minWords`, a screen-worth) AND dominates — at least
 * `dominance`× the words of every other body section combined. Requires ≥2 body
 * sections so the parent survives the split. A cohesive article whose sections
 * are balanced has no dominator → null (no false split). The largest qualifying
 * section wins. Pure.
 */
export function detectSplitCandidate(
  content: string,
  opts: { minWords?: number; dominance?: number } = {},
): SplitCandidate | null {
  const minWords = opts.minWords ?? 120;
  const dominance = opts.dominance ?? 1.0;
  const sizes = bodySectionSizes(content);
  if (sizes.length < 2) return null;
  const total = sizes.reduce((s, x) => s + x.words, 0);
  let best: SplitCandidate | null = null;
  for (const s of sizes) {
    const other = total - s.words;
    if (s.words >= minWords && s.words >= dominance * other) {
      if (!best || s.words > best.words) {
        best = { title: s.title, anchor: s.anchor, words: s.words, otherWords: other };
      }
    }
  }
  return best;
}

/** The SCHEMATIC split-summary prompt (no copyable concrete values): the model
 *  writes the 2–3 sentence pointer that stays in the parent. Citations/headings
 *  /the Main pointer are added deterministically, so it asks for none. */
function buildSplitSummaryPrompt(parentTitle: string, childTitle: string, body: string): string {
  return (
    `A sub-topic has been split out of the personal-wiki article "${parentTitle}" into its own article. ` +
    `Write a 2 to 3 sentence SUMMARY of "${childTitle}" to leave behind in the parent, so a reader knows what it is and follows the link for detail. ` +
    `Do NOT include citation markers, headings, a "Main article" pointer, or code fences — those are added for you. Output ONLY the summary prose.\n\n` +
    `SECTION BEING SPLIT OUT:\n${body}\n`
  );
}

export interface SplitOptions {
  /** Model override for the parent summary (tests inject a fake); falls back to
   *  the first sentences of the moved body when absent/leaky. */
  call?: SynthesisCall;
  /** Known neighbor stems (for the child's wikilink canonicalization). */
  stems?: Set<string>;
  /** Parent filename stem (H1 enforcement); defaults to the H1's entity stem. */
  parentStem?: string;
  /** Aliases to seed the child infobox `aliases:`. */
  aliases?: string[];
  summarySentences?: number;
  maxTokens?: number;
}

export interface SplitResult {
  childStem: string;
  childTitle: string;
  /** The new child article (post-NORMALIZE). */
  child: string;
  /** The parent with the section replaced by a summary + Main pointer (post-NORMALIZE). */
  parent: string;
  /** The `[^N]` numbers carried to the child (parent-side renumber may differ). */
  movedMarkers: number[];
  /** The 2–3 sentence summary left in the parent. */
  summary: string;
}

/**
 * Split one section out of `content` into a child entity article. The child
 * takes the full cited section prose + a minimal `kind: thing` infobox; the
 * parent keeps a summary + `*Main article: [[Child]]*`. Every `[^N]:` definition
 * referenced by the moved section is copied to the child; the parent's resulting
 * orphan defs are dropped by NORMALIZE. The word-floor gate is intentionally NOT
 * applied (a split is a sanctioned move) — both halves are validated structurally
 * + footnote-bijectively instead, and the split is a NO-OP (null) if either
 * fails. Pure with respect to disk.
 */
export async function splitOutSection(
  content: string,
  anchor: string,
  opts: SplitOptions = {},
): Promise<SplitResult | null> {
  const block = extractSection(content, anchor);
  if (block == null) return null;
  const lines = block.split("\n");
  const headingLine = lines[0] ?? "";
  const childTitle = headingLine.replace(/^#{1,6}\s+/, "").trim();
  if (!childTitle) return null;
  const body = lines.slice(1).join("\n").trim();
  if (!body) return null;
  const childStem = entityStem(childTitle);

  const movedMarkers = [...bodyMarkers(body)].sort((a, b) => a - b);
  const refDefs = referenceDefMap(content);
  const childDefs = movedMarkers.map((n) => refDefs.get(n)).filter((x): x is string => x != null);

  // --- child: minimal infobox + the full moved prose (the lead) + moved defs ---
  const stems = new Set(opts.stems ?? []);
  stems.add(childStem);
  const infoboxFields = buildInfoboxFields("", "thing", opts.aliases ?? []);
  const childRaw = assembleArticle({
    stem: childStem,
    infoboxFields,
    lead: body,
    sections: [],
    seeAlso: [],
    referenceDefs: childDefs,
  });
  const childNorm = normalizeArticle(childRaw, { stem: childStem, stems });
  if (!checkFootnoteIntegrity(childNorm.content).ok || !validateArticleStructure(childNorm.content).ok) {
    return null;
  }

  // --- parent: summary + Main pointer in place of the section body ---
  const parentTitle = articleTitle(content);
  let summary = "";
  if (opts.call) {
    const raw = sanitizeSection(
      await opts.call(buildSplitSummaryPrompt(parentTitle, childTitle, body), { maxTokens: opts.maxTokens ?? 160 }),
      childTitle,
    );
    if (raw.trim() && !isLeakyDraft(raw)) summary = raw;
  }
  if (!summary.trim()) summary = firstSentences(body, opts.summarySentences ?? 2);
  // The pointer summary carries NO citations — every marker travels to the child,
  // so none dangles in the parent.
  summary = summary.replace(/\s*\[\^\d+\]/g, "").replace(/\s+/g, " ").trim();
  if (!summary) summary = `See the main article for details on ${childTitle}.`;

  const newBlock = `${headingLine}\n\n${summary}\n\n*Main article: [[${childStem}]]*\n`;
  const swapped = replaceSection(content, anchor, newBlock);
  if (swapped == null) return null;

  const parentStem = opts.parentStem ?? entityStem(parentTitle || "entity");
  const parentStems = new Set(opts.stems ?? []);
  parentStems.add(childStem);
  parentStems.add(parentStem);
  const parentNorm = normalizeArticle(swapped, { stem: parentStem, stems: parentStems });
  if (!checkFootnoteIntegrity(parentNorm.content).ok || !validateArticleStructure(parentNorm.content).ok) {
    return null;
  }

  return {
    childStem,
    childTitle,
    child: childNorm.content,
    parent: parentNorm.content,
    movedMarkers,
    summary,
  };
}

const H1_LINE_RE = /^#\s+/;

/**
 * Maintain the series banner: ensure a single `*Part of a series on [[series]].*`
 * line sits directly under the H1 (the grammar slot before the infobox). Inserts
 * one when absent, rewrites a divergent one, no-ops on a match. A null/empty
 * `series` is a no-op — this maintains, it does not remove. Pure.
 */
export function setSeriesBanner(content: string, series: string | null | undefined): { content: string; changed: boolean } {
  const name = (series ?? "").trim();
  if (!name) return { content, changed: false };
  const banner = `*Part of a series on [[${name}]].*`;

  const lines = content.split(/\r?\n/);
  let inFence = false;
  let h1 = -1;
  let bannerIdx = -1;
  for (let i = 0; i < lines.length; i++) {
    if (isFenceLine(lines[i]!)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    if (h1 < 0 && H1_LINE_RE.test(lines[i]!)) h1 = i;
    else if (bannerIdx < 0 && SERIES_RE.test(lines[i]!.trim())) bannerIdx = i;
  }

  if (bannerIdx >= 0) {
    if (lines[bannerIdx]!.trim() === banner) return { content, changed: false };
    lines[bannerIdx] = banner;
    return { content: lines.join("\n"), changed: true };
  }
  if (h1 < 0) return { content: `${banner}\n\n${content}`, changed: true };
  lines.splice(h1 + 1, 0, "", banner);
  return { content: lines.join("\n"), changed: true };
}

// ---- effectful SPLIT entry (write child + parent, commit) ------------------

export interface ApplySplitResult {
  status: "split" | "no-candidate" | "rejected";
  stem: string;
  childStem: string | null;
  anchor: string | null;
  reason: string | null;
}

/**
 * Detect and apply a summary-style split on one vault article: write the new
 * child article + the trimmed parent and commit. A NO-OP when no section
 * dominates ("no-candidate") or the structural split gate vetoes ("rejected").
 * Never clobbers an existing child article (that would be a MERGE, not a split).
 */
export async function applySplit(opts: {
  stem: string;
  root?: string;
  call?: SynthesisCall;
  commit?: boolean;
  minWords?: number;
  dominance?: number;
}): Promise<ApplySplitResult> {
  const root = opts.root ?? vaultRoot();
  const base: ApplySplitResult = { status: "no-candidate", stem: opts.stem, childStem: null, anchor: null, reason: null };
  const path = join(articlesDir(root), `${opts.stem}.md`);

  let content: string;
  try {
    content = await readFile(path, "utf8");
  } catch {
    return { ...base, status: "rejected", reason: `article not found: ${opts.stem}` };
  }

  const cand = detectSplitCandidate(content, { minWords: opts.minWords, dominance: opts.dominance });
  if (!cand) return base;

  const stems = new Set(await listArticles(root));
  const result = await splitOutSection(content, cand.anchor, { call: opts.call, stems, parentStem: opts.stem });
  if (!result) return { ...base, status: "rejected", anchor: cand.anchor, reason: "split failed the structural gate (NO-OP)" };

  const childPath = join(articlesDir(root), `${result.childStem}.md`);
  try {
    await readFile(childPath, "utf8");
    return { ...base, status: "rejected", anchor: cand.anchor, childStem: result.childStem, reason: "child article already exists (would be a MERGE, not a split)" };
  } catch {
    // child does not exist — good, proceed.
  }

  await mkdir(articlesDir(root), { recursive: true });
  await writeFile(childPath, result.child);
  await writeFile(path, result.parent);
  if (opts.commit !== false) {
    await commitVault(root, `memory: split ${result.childStem} out of ${opts.stem} (${result.movedMarkers.length} citations moved)`);
  }
  return { status: "split", stem: opts.stem, childStem: result.childStem, anchor: cand.anchor, reason: null };
}

// ===========================================================================
// P8-T3 (cont.) — MERGE signal: two near-duplicate stubs
//
// MERGE is a CROSS-article action: it is NEVER performed silently. This only
// EMITS a signal (which P8-T4 surfaces on a Talk page); a human / a later
// reconcile step decides. Two stubs describing the same thing under different
// names have near-identical token content — a high Jaccard overlap flags them.
// ===========================================================================

const MERGE_STOP = new Set([
  "the", "a", "an", "and", "or", "of", "to", "for", "in", "on", "with", "is", "it", "as",
  "at", "by", "be", "this", "that", "are", "was", "user", "uses", "used", "use",
]);

/** Content tokens (title + body words), markers/links/fences stripped, stopworded
 *  — the bag a stub-vs-stub Jaccard compares. */
function articleTokens(content: string): Set<string> {
  const flat = content
    .replace(/```[\s\S]*?```/g, " ") // fenced blocks (infobox/code) out
    .replace(/\[\^\d+\][:]?/g, " ") // footnote markers/defs
    .replace(/\[\[([^\]]+)\]\]/g, "$1") // wikilink → its text
    .replace(/[#*_`>|-]/g, " ");
  const out = new Set<string>();
  for (const t of flat.toLowerCase().split(/[^a-z0-9]+/)) {
    if (t.length > 1 && !MERGE_STOP.has(t)) out.add(t);
  }
  return out;
}

function jaccard(a: Set<string>, b: Set<string>): number {
  if (a.size === 0 || b.size === 0) return 0;
  let inter = 0;
  for (const t of a) if (b.has(t)) inter++;
  return inter / (a.size + b.size - inter);
}

export interface MergeSignal {
  a: string;
  b: string;
  jaccard: number;
  reason: string;
}

/**
 * Flag pairs of articles that look like the SAME thing under different names —
 * a MERGE signal, never an action. By default only stubs are considered (the
 * thin near-duplicates summary-style merges); their content-token Jaccard ≥
 * `threshold` emits a signal. Deterministic: pairs are sorted, scanned in stem
 * order. Pure.
 */
export function detectMergeCandidates(
  articles: { stem: string; content: string }[],
  opts: { threshold?: number; stubsOnly?: boolean } = {},
): MergeSignal[] {
  const threshold = opts.threshold ?? 0.5;
  const stubsOnly = opts.stubsOnly ?? true;
  const pool = articles
    .filter((x) => !stubsOnly || articleThinness(x.content).stub)
    .map((x) => ({ stem: x.stem, toks: articleTokens(x.content) }))
    .sort((p, q) => p.stem.localeCompare(q.stem));

  const out: MergeSignal[] = [];
  for (let i = 0; i < pool.length; i++) {
    for (let j = i + 1; j < pool.length; j++) {
      const score = jaccard(pool[i]!.toks, pool[j]!.toks);
      if (score >= threshold) {
        out.push({
          a: pool[i]!.stem,
          b: pool[j]!.stem,
          jaccard: score,
          reason: `near-duplicate stubs (token Jaccard ${score.toFixed(2)}) — likely the same thing under two names`,
        });
      }
    }
  }
  return out.sort((x, y) => y.jaccard - x.jaccard || x.a.localeCompare(y.a));
}

// ===========================================================================
// P8-T4 — Talk-page restructure SIGNALS (never silent cross-article surgery)
//
// The structural pass NEVER restructures across articles on its own — split and
// merge are CROSS-article actions, so it writes SUGGESTIONS to `Talk/<stem>.md`
// (Lucien `<<<TALK>>>` style) for a human / a later reconcile step. The embedding
// SILHOUETTE is the ONE sanctioned OFFLINE triage instrument here: section-cohesion
// spots an article whose sections drifted into distinct topics (a split candidate
// the size heuristic alone might miss). It runs ONLY in this offline triage — the
// `embed` function is injected, so this module never reaches `src/embed.ts` and
// the read/route hot path stays at zero embedding calls (the P0-T6 tripwire).
// ===========================================================================

/** Inject the embedding backend (so `wikify.ts` never imports `src/embed.ts` and
 *  the read path can never accidentally embed). The eval wires the real
 *  Qwen3-Embedding through here; tests inject a deterministic fake. */
export type EmbedFn = (texts: string[]) => Float32Array[];

function cosine(a: Float32Array, b: Float32Array): number {
  let dot = 0;
  let na = 0;
  let nb = 0;
  const n = Math.min(a.length, b.length);
  for (let i = 0; i < n; i++) {
    dot += a[i]! * b[i]!;
    na += a[i]! * a[i]!;
    nb += b[i]! * b[i]!;
  }
  if (na === 0 || nb === 0) return 0;
  return dot / Math.sqrt(na * nb);
}

export interface CohesionResult {
  sections: number;
  /** Mean pairwise cosine across body-section embeddings (1 when <2 sections).
   *  LOW = the sections cover distinct topics → a split candidate. */
  meanPairwise: number;
  /** The least-similar section pair's cosine (1 when <2 sections). */
  minPair: number;
}

/**
 * The OFFLINE cohesion silhouette: embed each body section and measure how alike
 * they are. A low mean pairwise cosine means the article's sections have drifted
 * into distinct topics — a structural split signal the word-size heuristic can
 * miss. This is the SANCTIONED offline use of embeddings; `embed` is injected and
 * MUST NOT be the read/route path. Pure aside from the injected `embed`.
 */
export function sectionCohesion(content: string, embed: EmbedFn): CohesionResult {
  const lines = content.split(/\r?\n/);
  const bodies: string[] = [];
  for (const it of articleStructure(content)) {
    if (it.kind !== "section" || !it.title) continue;
    const body = lines.slice(it.startLine, it.endLine).join("\n").trim();
    if (body) bodies.push(body);
  }
  if (bodies.length < 2) return { sections: bodies.length, meanPairwise: 1, minPair: 1 };

  const vecs = embed(bodies);
  let sum = 0;
  let count = 0;
  let min = 1;
  for (let i = 0; i < vecs.length; i++) {
    for (let j = i + 1; j < vecs.length; j++) {
      const c = cosine(vecs[i]!, vecs[j]!);
      sum += c;
      count++;
      if (c < min) min = c;
    }
  }
  return { sections: bodies.length, meanPairwise: count ? sum / count : 1, minPair: min };
}

export interface TalkSuggestion {
  kind: "split" | "merge" | "contradiction";
  text: string;
}

/**
 * Compose the structural-triage suggestions for one article from the detections:
 * a size-dominant split candidate, a low-cohesion silhouette split signal, and
 * any merge pairs involving this article. Pure; SCHEMATIC text (no copyable
 * concrete values from policy).
 */
export function buildStructureTalk(input: {
  stem: string;
  split?: SplitCandidate | null;
  cohesion?: CohesionResult | null;
  merges?: MergeSignal[];
  cohesionFloor?: number;
}): TalkSuggestion[] {
  const out: TalkSuggestion[] = [];
  const floor = input.cohesionFloor ?? 0.4;

  if (input.split) {
    const childStem = entityStem(input.split.title);
    out.push({
      kind: "split",
      text:
        `SPLIT: the "${input.split.title}" section (${input.split.words} words) dominates this article ` +
        `(vs ${input.split.otherWords} words across all other sections). Consider splitting it to ` +
        `[[${childStem}]] with a {{Main}} pointer; every [^N] in it travels to the child.`,
    });
  }
  if (input.cohesion && input.cohesion.sections >= 2 && input.cohesion.meanPairwise < floor) {
    out.push({
      kind: "split",
      text:
        `SPLIT (cohesion): this article's ${input.cohesion.sections} sections read as distinct topics ` +
        `(mean section cohesion ${input.cohesion.meanPairwise.toFixed(2)} < ${floor.toFixed(2)}). ` +
        `Consider splitting the divergent section(s) into their own article(s).`,
    });
  }
  for (const m of input.merges ?? []) {
    if (m.a !== input.stem && m.b !== input.stem) continue;
    const other = m.a === input.stem ? m.b : m.a;
    out.push({
      kind: "merge",
      text: `MERGE: [[${input.stem}]] and [[${other}]] look like the same thing under two names (${m.reason}). Consider merging to the canonical title; the loser becomes an alias + redirect.`,
    });
  }
  return out;
}

/** The Talk directory for a vault (sibling of articles/). */
export function talkDir(root = vaultRoot()): string {
  return join(root, "Talk");
}

/**
 * Write the structural-triage suggestions to `Talk/<stem>.md` in the Lucien
 * `<<<TALK>>>` style. Writes ONLY under `Talk/` — it NEVER edits an article, so
 * a cross-article split/merge is surfaced, never silently performed. Returns the
 * written path, or null when there is nothing to suggest. The block is rewritten
 * each run (idempotent — one managed block per article).
 */
export async function writeTalkPage(opts: {
  stem: string;
  suggestions: TalkSuggestion[];
  title?: string;
  root?: string;
  now?: number;
}): Promise<string | null> {
  if (opts.suggestions.length === 0) return null;
  const root = opts.root ?? vaultRoot();
  const dir = talkDir(root);
  await mkdir(dir, { recursive: true });
  const path = join(dir, `${opts.stem}.md`);
  const date = new Date(opts.now ?? Date.now()).toISOString().slice(0, 10);
  const title = opts.title ?? opts.stem.replace(/_/g, " ");

  const body = [
    `# Talk: ${title}`,
    "",
    "> Structural-triage suggestions from the nightly wikify sweep. These are",
    "> SUGGESTIONS ONLY — mlx-bun never restructures across articles automatically.",
    "",
    "<<<TALK>>>",
    `## ${date} — structural triage`,
    "",
    ...opts.suggestions.map((s) => `- **${s.kind.toUpperCase()}** — ${s.text}`),
    "<<<END TALK>>>",
    "",
  ].join("\n");

  await writeFile(path, body);
  return path;
}
