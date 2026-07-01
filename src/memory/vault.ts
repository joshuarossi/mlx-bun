// mlx-bun memory — the wiki vault on disk.
//
// "Memory" is the user-facing capability; the store is a plain Markdown wiki at
// ~/.mlx-bun/wiki/ — articles the local assistant reads to remember you across
// sessions. One self-contained, portable folder: copy it and your memory moves
// with you. It's a valid Obsidian vault for free.
//
// The article read/search/link helpers are ported from lucien (~/Code/lucien),
// an already-working system at real scale — they're pure filesystem functions
// with no MCP coupling, so they drop straight in. We keep lucien's good
// descriptive concepts (articles, [[wikilinks]], Meta governance pages,
// conv: citations) and drop the mythology. See docs/design/memory-system.md.
//
// M0 is the read path: setup the vault, then list / read / search / index it.
// Synthesis (writing articles from conversations) is M1 and lives elsewhere.

import { access, lstat, mkdir, readdir, readFile, readlink, stat, symlink, unlink, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { isAbsolute, join } from "node:path";
import { spawn } from "node:child_process";
import { isFenceLine } from "./article";

// ---- paths -----------------------------------------------------------

/** Root of the memory vault: ~/.mlx-bun/wiki (override with MLX_BUN_WIKI). */
export function vaultRoot(): string {
  const override = process.env.MLX_BUN_WIKI?.trim();
  if (override) return override.replace(/^~(?=$|[/\\])/, homedir());
  return join(homedir(), ".mlx-bun", "wiki");
}

export function articlesDir(root = vaultRoot()): string {
  return join(root, "articles");
}

export function referenceDir(root = vaultRoot()): string {
  return join(root, "Reference");
}

// ---- types -----------------------------------------------------------

export interface TocEntry {
  depth: number;
  title: string;
  anchor: string;
}

export interface SearchHit {
  article: string;
  anchor: string | null;
  line: number;
  excerpt: string;
}

export interface ArticleSearchSummary {
  article: string;
  occurrences: number;
  /** Distinct query terms that matched this article (multi-term queries). */
  matched_terms?: string[];
  /** Number of query terms that appear in the article's title/stem. */
  title_matches?: number;
}

// ---- markdown helpers (ported from lucien) ---------------------------

export function slugifyHeading(title: string): string {
  return title
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

/** Non-overlapping substring matches (whole file). */
export function countSubstringOccurrences(text: string, needle: string, caseSensitive: boolean): number {
  const n = needle.trim();
  if (!n) return 0;
  const haystack = caseSensitive ? text : text.toLowerCase();
  const nd = caseSensitive ? n : n.toLowerCase();
  let count = 0;
  let pos = 0;
  for (;;) {
    const idx = haystack.indexOf(nd, pos);
    if (idx === -1) break;
    count++;
    pos = idx + nd.length;
  }
  return count;
}

/** Heading outside fences; depth 1 = `#`, … 6 = `######`. */
function parseHeadingLine(line: string): { depth: number; title: string } | null {
  const m = /^(#{1,6})\s+(.+)$/.exec(line);
  if (!m) return null;
  return { depth: m[1]!.length, title: m[2]!.trim() };
}

export function parseToc(markdown: string): TocEntry[] {
  const lines = markdown.split(/\r?\n/);
  let inFence = false;
  const toc: TocEntry[] = [];
  for (const line of lines) {
    if (isFenceLine(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const h = parseHeadingLine(line);
    if (h) toc.push({ depth: h.depth, title: h.title, anchor: slugifyHeading(h.title) });
  }
  return toc;
}

function fenceAfterLine(lines: string[], lineIdx: number): boolean {
  let inFence = false;
  for (let i = 0; i <= lineIdx; i++) {
    if (isFenceLine(lines[i]!)) inFence = !inFence;
  }
  return inFence;
}

/**
 * First heading with matching anchor wins. Includes the heading line. Stops
 * before the next heading (outside fences) of equal or shallower depth.
 */
export function extractSection(markdown: string, anchor: string): string | null {
  const lines = markdown.split(/\r?\n/);
  let inFence = false;
  let startIdx = -1;
  let startDepth = 0;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]!;
    if (isFenceLine(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const h = parseHeadingLine(line);
    if (!h) continue;
    if (slugifyHeading(h.title) === anchor) {
      startIdx = i;
      startDepth = h.depth;
      break;
    }
  }
  if (startIdx < 0) return null;

  let fence = fenceAfterLine(lines, startIdx);
  let endIdxExclusive = lines.length;
  for (let j = startIdx + 1; j < lines.length; j++) {
    const line = lines[j]!;
    if (isFenceLine(line)) {
      fence = !fence;
      continue;
    }
    if (fence) continue;
    const h = parseHeadingLine(line);
    if (h && h.depth <= startDepth) {
      endIdxExclusive = j;
      break;
    }
  }
  return lines.slice(startIdx, endIdxExclusive).join("\n");
}

// ---- article/reference addressing ------------------------------------

function normalizeBareStem(article: string): string {
  const t = article.trim();
  if (!t) throw new Error("article name is required");
  const stem = t.endsWith(".md") ? t.slice(0, -3).trim() : t;
  if (!stem) throw new Error("article name is invalid");
  if (stem.includes("..")) throw new Error("article must not contain ..");
  if (isAbsolute(stem)) throw new Error("article must be a bare filename, not a path");
  if (stem.includes("/") || stem.includes("\\")) throw new Error("article must not contain path separators");
  if (stem.startsWith(".")) throw new Error("article must not be hidden or relative");
  return stem;
}

function normalizeMemoryDocId(article: string): { kind: "article" | "reference"; stem: string; id: string } {
  const raw = article.trim();
  if (/^Reference[/\\]/.test(raw)) {
    const rest = raw.replace(/^Reference[/\\]/, "");
    const stem = normalizeBareStem(rest);
    return { kind: "reference", stem, id: `Reference/${stem}` };
  }
  const stem = normalizeBareStem(raw);
  return { kind: "article", stem, id: stem };
}

function normalizeArticleStem(article: string): string {
  const doc = normalizeMemoryDocId(article);
  if (doc.kind !== "article") throw new Error("expected a user article, not a Reference document");
  return doc.stem;
}

async function pathExists(path: string): Promise<boolean> {
  try {
    await access(path);
    return true;
  } catch {
    return false;
  }
}

export async function resolveArticlePath(root: string, article: string): Promise<string> {
  const doc = normalizeMemoryDocId(article);
  const base = doc.kind === "reference" ? referenceDir(root) : articlesDir(root);
  const filePath = join(base, `${doc.stem}.md`);
  if (!(await pathExists(filePath))) {
    throw new Error(`${doc.kind === "reference" ? "Reference" : "Article"} not found: ${doc.id}.md under ${base}`);
  }
  return filePath;
}

export async function readArticle(root: string, article: string): Promise<{ path: string; content: string }> {
  const path = await resolveArticlePath(root, article);
  return { path, content: await readFile(path, "utf8") };
}

/** Filename stems for every `*.md` under articles/, sorted alphabetically. */
export async function listArticles(root: string): Promise<string[]> {
  let names: string[];
  try {
    names = await readdir(articlesDir(root));
  } catch {
    return [];
  }
  return names
    .filter((n) => n.endsWith(".md") && !n.startsWith("."))
    .map((n) => n.slice(0, -3))
    .sort((a, b) => a.localeCompare(b));
}

/** Reference document ids, prefixed so tools can pass them back to memory_read. */
export async function listReferenceDocs(root: string): Promise<string[]> {
  let names: string[];
  try {
    names = await readdir(referenceDir(root));
  } catch {
    return [];
  }
  return names
    .filter((n) => n.endsWith(".md") && !n.startsWith("."))
    .map((n) => `Reference/${n.slice(0, -3)}`)
    .sort((a, b) => a.localeCompare(b));
}

export async function listMemoryDocuments(root: string): Promise<string[]> {
  return [...(await listArticles(root)), ...(await listReferenceDocs(root))];
}

// ---- wikilinks --------------------------------------------------------

const wikilinkInnerRe = /\[\[([^\]]+)\]\]/g;

/** Raw wikilink targets from prose only (not fenced code); includes conv: etc. */
export function extractWikilinkTargets(markdown: string): string[] {
  const lines = markdown.split(/\r?\n/);
  let inFence = false;
  const out: string[] = [];
  for (const line of lines) {
    if (isFenceLine(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    wikilinkInnerRe.lastIndex = 0;
    let m: RegExpExecArray | null;
    while ((m = wikilinkInnerRe.exec(line)) !== null) {
      const inner = m[1]!.trim();
      if (!inner || /^conv:/i.test(inner)) continue;
      const hash = inner.split("|")[0]!.split("#")[0]!.trim();
      if (hash) out.push(hash);
    }
  }
  return out;
}

/** Map wikilink display text to an existing article stem (underscore filenames). */
export function resolveWikilinkToStem(raw: string, stems: Set<string>): string | null {
  const base = raw.trim();
  if (!base) return null;
  if (stems.has(base)) return base;
  const underscored = base.replace(/\s+/g, "_");
  if (stems.has(underscored)) return underscored;
  const lower = underscored.toLowerCase();
  const spacedLower = base.replace(/\s+/g, " ").trim().toLowerCase();
  for (const stem of stems) {
    if (stem.toLowerCase() === lower) return stem;
    if (stem.replace(/_/g, " ").trim().toLowerCase() === spacedLower) return stem;
  }
  return null;
}

export async function getArticleLinks(root: string, article: string): Promise<{ outbound: string[]; inbound: string[] }> {
  const stem = normalizeArticleStem(article);
  const stems = await listArticles(root);
  const stemSet = new Set(stems);
  await resolveArticlePath(root, stem);

  const dir = articlesDir(root);
  const outboundByStem = new Map<string, Set<string>>();
  for (const name of stems) {
    const content = await readFile(join(dir, `${name}.md`), "utf8");
    const resolved = new Set<string>();
    for (const t of extractWikilinkTargets(content)) {
      const r = resolveWikilinkToStem(t, stemSet);
      if (r !== null && r !== name) resolved.add(r);
    }
    outboundByStem.set(name, resolved);
  }

  const outbound = [...(outboundByStem.get(stem) ?? new Set<string>())].sort((a, b) => a.localeCompare(b));
  const inbound: string[] = [];
  for (const [from, targets] of outboundByStem) {
    if (from !== stem && targets.has(stem)) inbound.push(from);
  }
  inbound.sort((a, b) => a.localeCompare(b));
  return { outbound, inbound };
}

// ---- search -----------------------------------------------------------

const STOPWORDS = new Set([
  "the", "a", "an", "of", "for", "to", "in", "on", "at", "and", "or", "is", "it", "as", "with",
]);

export async function searchArticles(
  root: string,
  query: string,
  options?: { limit?: number; case_sensitive?: boolean; scope?: "all" | "articles" | "reference" },
): Promise<{ summaries: ArticleSearchSummary[]; hits: SearchHit[] }> {
  const limit = options?.limit ?? 50;
  const caseSensitive = options?.case_sensitive ?? false;
  const q = query.trim();
  if (!q) throw new Error("search query is required");

  const scope = options?.scope ?? "all";
  const docs: { id: string; stem: string; path: string }[] = [];
  if (scope === "all" || scope === "articles") {
    for (const stem of await listArticles(root)) {
      docs.push({ id: stem, stem, path: join(articlesDir(root), `${stem}.md`) });
    }
  }
  if (scope === "all" || scope === "reference") {
    for (const id of await listReferenceDocs(root)) {
      const stem = id.slice("Reference/".length);
      docs.push({ id, stem, path: join(referenceDir(root), `${stem}.md`) });
    }
  }
  if (docs.length === 0) return { summaries: [], hits: [] };

  // Split into terms and scan each independently; aggregate per-article so a
  // multi-word query that never appears contiguously still surfaces the
  // articles hitting the most distinct terms. Drop trivial stopwords; if the
  // query is ONLY stopwords, fall back to the whole query as one substring.
  const rawTerms = q.split(/\s+/).filter((t) => t.length > 0);
  const filtered = rawTerms.filter((t) => !STOPWORDS.has(t.toLowerCase()));
  const terms = filtered.length > 0 ? filtered : [q];
  const isMulti = terms.length > 1;

  const summaries: ArticleSearchSummary[] = [];
  type HitWithCount = SearchHit & { _termCount: number };
  const allHits: HitWithCount[] = [];

  for (const doc of docs.sort((a, b) => a.id.localeCompare(b.id))) {
    const stem = doc.id;
    let content: string;
    try {
      content = await readFile(doc.path, "utf8");
    } catch {
      continue;
    }

    const matchedTerms: string[] = [];
    let totalOccurrences = 0;
    for (const t of terms) {
      const n = countSubstringOccurrences(content, t, caseSensitive);
      if (n > 0) {
        matchedTerms.push(t);
        totalOccurrences += n;
      }
    }
    if (totalOccurrences === 0) continue;

    // Title/stem match bonus: a term in the stem signals the article is *about*
    // that term, not just mentioning it (secondary sort key).
    const stemForMatch = caseSensitive ? stem : stem.toLowerCase();
    let titleMatches = 0;
    for (const t of terms) {
      if (stemForMatch.includes(caseSensitive ? t : t.toLowerCase())) titleMatches++;
    }

    const summary: ArticleSearchSummary = { article: stem, occurrences: totalOccurrences };
    if (isMulti) summary.matched_terms = matchedTerms;
    if (titleMatches > 0) summary.title_matches = titleMatches;
    summaries.push(summary);

    const lines = content.split(/\r?\n/);
    let inFence = false;
    let lastAnchor: string | null = null;
    const lcTerms = caseSensitive ? matchedTerms : matchedTerms.map((t) => t.toLowerCase());
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]!;
      if (isFenceLine(line)) {
        inFence = !inFence;
      } else if (!inFence) {
        const h = parseHeadingLine(line);
        if (h) lastAnchor = slugifyHeading(h.title);
      }
      const compareLine = caseSensitive ? line : line.toLowerCase();
      let termCount = 0;
      for (const t of lcTerms) if (compareLine.includes(t)) termCount++;
      if (termCount > 0) {
        allHits.push({ article: stem, anchor: lastAnchor, line: i + 1, excerpt: line.trim(), _termCount: termCount });
      }
    }
  }

  // Rank summaries: distinct terms (desc) → title matches (desc) →
  // occurrences (desc) → name (asc, stable).
  summaries.sort((a, b) => {
    const am = a.matched_terms?.length ?? 1;
    const bm = b.matched_terms?.length ?? 1;
    if (bm !== am) return bm - am;
    const at = a.title_matches ?? 0;
    const bt = b.title_matches ?? 0;
    if (bt !== at) return bt - at;
    if (b.occurrences !== a.occurrences) return b.occurrences - a.occurrences;
    return a.article.localeCompare(b.article);
  });

  allHits.sort((a, b) => b._termCount - a._termCount || a.article.localeCompare(b.article) || a.line - b.line);
  const hits: SearchHit[] = allHits.slice(0, limit).map(({ _termCount, ...h }) => h);
  return { summaries, hits };
}

// ---- setup / status ---------------------------------------------------

const README = `# Your memory

This is your personal wiki — a structured, durable record of your thinking,
synthesized from your conversations with your local AI. It belongs to you: plain
Markdown, version-controlled with git, readable and editable with any tool
(Obsidian opens this folder as a vault with no setup).

mlx-bun curates it; you own it. Edit any file directly — the next synthesis run
respects your changes.

## Structure

- \`articles/\`  — the wiki articles themselves (\`Topic_Name.md\`)
- \`Reference/\` — read-only symlinks to mlx-bun's own docs; synthesis never
                 writes these
- \`Meta/\`      — operational pages: editorial guidelines, conventions, the
                 bucket taxonomy, topics to ignore
- \`Talk/\`      — per-article discussion / conflict notes

Nothing here ever leaves your machine.
`;

const EDITORIAL_GUIDELINES = `# Editorial Guidelines

This wiki follows Wikipedia's editorial conventions except as noted below. When
in doubt, do what Wikipedia would do.

## Scope adaptations for a personal wiki

- **Subject**: the user (you). Articles describe the people, projects, ideas,
  tools, and topics relevant to your thinking.
- **Sources**: your conversation transcripts with the local assistant. Each
  article cites the conversations that contributed to it (\`conv:HASH\`).
- **Neutral point of view**: adapted. The wiki represents your actual views and
  reasoning. "Neutral" here means faithful to the evidence in your
  conversations, not pretending to be from no perspective.
- **Notability**: anything that recurs in your thinking is notable enough. Stub
  articles are encouraged for emerging topics. There is no ownership or
  usefulness test — a subject earns an article by being something you actually
  think about, not by being something you own.
- **Conflict of interest**: not applicable — this is a single-subject wiki you
  own.

## Articles are subjects

Each article is named for ONE specific subject — the actual person, project,
idea, tool, or topic (one concrete named subject per article, drawn from the
conversation — never a generic placeholder), never a mixed \`X_and_Y\` topic bin. When a chunk is about several subjects it fans out to
each subject's article, and routing (see \`Bucketing.md\`) strongly prefers an
existing subject article over minting a new one. This subject-per-article shape
is the one deliberate improvement over the source wiki.

## Article structure

See \`Article_Conventions.md\`.

## Runs on local AI

Synthesis runs entirely on a small local model. Every editorial judgment is
decomposed into the smallest single-purpose task — ideally a binary ("does this
chunk update this section? yes/no") — so the model stays within its competence
and the work is cheap to repeat. The policy is the same one a cloud editor would
follow; only the execution is decomposed.

## Maintenance disposition

Synthesis operates as a Wikipedia editor making small, conservative
contributions. Edits integrate rather than replace. Trajectories ("used to think
X, now thinks Y") are preserved. Talk pages surface concerns rather than silently
resolving them.

## Time and history

Follow Wikipedia's treatment. The article describes the **current state** —
present tense, in the lead and body. The lead is a concise current-state summary:
never scatter "previously …" caveats through it.

When the user's position genuinely EVOLVES over time, the trajectory is
**PRESERVED** in a dedicated **## History** section (we KEEP the history — we do
NOT delete it). The lead/body resolve to the current state; the History section
records the change with citations to BOTH the earlier and the later source
(*"previously <earlier>; as of <date> <later>"*).

Classify before editing — keep the evolution of the USER'S POSITIONS, not the
AI's MISTAKES:
- **Evolution** (a relationship / opinion / preference / stance the user changed
  across dated statements) → resolve the lead to the current value AND add or
  extend the **## History** section preserving the trajectory.
- **Factual error** (a world-fact or spec that was simply WRONG, or a flat "no,
  that is wrong, it is actually <value>") → **silently overwrite** with the
  correct value: NO History entry, the wrong value pruned entirely as if it had
  never been there.
`;

const BUCKETING = `# Bucketing Policy

How a chunk's subjects are routed to articles. This documents the **current
default behavior** — the pipeline already works this way; edit this page to
change it.

## Defaults

- **Strongly prefer existing articles.** A chunk's subject that matches an
  existing article (by canonical name or alias) folds into that article. Only
  mint a NEW subject article when no existing one is a reasonable fit — and even
  then, only when the subject is substantive enough to warrant its own article
  (it recurs in your thinking, or the chunk engages it as a genuine subject),
  not a single fleeting mention.
- A chunk may belong to **multiple** existing articles when it genuinely spans
  them — it fans out to every subject it is about.
- If a subject fits one or more existing articles, do not also mint a new article
  for it. **Existing articles win in any tie.**
- Article names are Wikipedia-style: the specific subject, title-cased (see
  \`Entities.md\`).
- A subject too thin or fleeting to deserve its own article — and with no
  existing home — is **left captured in its chunk** (still retrievable by
  search), never dropped and never forced into a junk article. It earns an
  article later if it recurs.

## How to tune

- **More, smaller articles:** lower the bar for minting a new article (split
  readily; treat narrower subjects as article-worthy).
- **Fewer, larger articles:** raise the bar; prefer folding into an existing
  broad subject over spawning a new one.

The router follows this page over its built-in defaults.
`;

const ARTICLE_CONVENTIONS = `# Article Conventions

Every article is one Markdown file describing one entity, written to a fixed
top-to-bottom grammar. The write pipeline emits this shape and the parser reads
it deterministically — keep the order exactly as below.

## Article grammar (fixed, top to bottom)

1. **\`# H1\`** — the title, equal to the filename stem with \`_\` → space (the
   file \`<Subject_Name>.md\` has \`# <Subject Name>\`). Exactly one H1.
2. **Series banner** (optional) — a single italic line directly under the H1:
   \`*Part of a series on [[Series Name]].*\`. Present only when the article belongs
   to a named series.
3. **Infobox** (optional) — a fenced \`\`\`info\` block of \`key: value\` lines (see
   below). Comes before the lead.
4. **Lead** — a 2–4 sentence abstract: present tense, names the thing in **bold**
   in the first sentence, says what it is, and characterizes the user's
   relationship to it (uses / owns / chose / considered) — written in the THIRD
   person, not just a spec definition.
5. **Sections** — \`##\` (and nested \`###\`) sections in natural reading order,
   one sub-topic each.
6. **\`## See also\`** — bullet list of \`[[wikilinks]]\` to related articles.
7. **\`## Notes\`** (optional) — \`[^N]\` commentary footnotes.
8. **\`## References\`** — the \`[^N]:\` definitions. This is ALWAYS the LAST section.

## Voice and scope

Follow Wikipedia's conventions in every respect EXCEPT two deliberate carve-outs:

- **Voice — THIRD PERSON, always.** Write like Wikipedia: never the first person ("I
  use…", "my pick"). Refer to the user in the third person ("the user uses…",
  "the user considers…"). The subject of the article is the topic; the article
  records what the user thinks and does regarding it.
- **Carve-out 1 — notability.** Wikipedia's notability bar does NOT apply: anything
  the user discussed is notable enough for an article (see \`Entities.md\`).
- **Carve-out 2 — neutrality.** Wikipedia's neutral-point-of-view does NOT apply:
  these articles document the user's OWN positions and opinions. Capture the user's
  current stance on the topic accurately, including subjective judgments — the goal
  is to record what the user currently thinks. Everything else (structure, citations,
  summary style, third-person voice) is standard Wikipedia.

## Citations / footnotes

Inline claims carry a \`[^N]\` marker; the \`## References\` section collects the
matching definitions. Every marker has exactly one definition and vice-versa.

The footnote definition format is fixed (the Lucien standard):

\`\`\`
[^N]: \`conv:HASH\` (YYYY-MM-DD, source) — desc
\`\`\`

where **\`HASH\` = the first 8 lowercase hex digits of the conversation UUID with
hyphens stripped** (e.g. \`00000000-0000-0000-0000-000000000000\` → \`00000000\`).
The hash identifies the CONVERSATION only — it deliberately carries no chunk
range — so chunk→section provenance is recovered from structured state, never by
parsing footnotes. \`desc\` is a short note of what the conversation covered.

## Links

Use wikilinks for internal references: \`[[Article Name]]\`. These resolve to the
correct files (spaces vs underscores and case are normalized).

## Infobox

The infobox is a fenced \`\`\`info\` block placed between the H1/banner and the
lead. It is fenced so \`parseToc\`/\`extractSection\`/\`searchArticles\` skip it (its
keys are never headings or searchable prose). Rules:

- Keys are \`snake_case\`.
- A value that names another entity is a \`[[wikilink]]\` (load-bearing for
  NAVIGATION — it feeds the link graph).
- \`aliases:\` is a **comma**-separated list feeding the entity index.
- Other multi-value fields are **\`;\`**-separated.
- A \`kind:\` field tags the closed entity-kind (\`thing\`/\`person\`/\`domain\`/
  \`project\`/\`standard\`, default \`thing\`); a \`type:\` field carries the emergent
  label (a short free-form noun phrase). See \`Infobox_Schemas.md\`.

Every field is either a **world-fact** (spec-sheet / citable) or a
**relationship-fact** (conversation-established — the personal layer). Both are
CONTENT the AI reads; there is no numeric facet or \`gte/lte\` query over any field.

### Field-kind taxonomy

The table below teaches the value SHAPE per field-kind only — every \`field\` cell
is a \`<…>\` placeholder and every \`example\` cell is schematic. NEVER copy a key
or a value from here into an article; every key and value must come from the
chunk text about the actual entity. The fixed keys (\`type\`, \`kind\`, \`owned\`,
\`acquired\`, \`used_for\`, \`chosen_over\`, \`status\`, \`opinion\`, \`aliases\`) are the
domain-neutral vocabulary to draw from when the chunks support them; every
domain-specific key is supplied by the chunk, never by this page.

| field | kind | value-type | example (schematic) |
| --- | --- | --- | --- |
| \`type\` | world | enum | \`<entity type>\` |
| \`kind\` | world | enum | one of thing\\|person\\|domain\\|project\\|standard |
| \`<world_entity_key>\` | world | entity-link | \`[[Linked Entity]]\` |
| \`<world_scalar_key>\` | world | scalar | \`<value>\` |
| \`<world_enum_key>\` | world | enum | \`<value>\` |
| \`<world_list_key>\` | world | list | \`[[Entity A]]; [[Entity B]]\` |
| \`owned\` | relationship | enum | \`yes\` (\`yes\`\\|\`no\`\\|\`wishlist\`) |
| \`acquired\` | relationship | date | \`<YYYY-MM + how>\` |
| \`used_for\` | relationship | list | \`<use>; <use>\` |
| \`chosen_over\` | relationship | entity-link | \`[[Linked Entity]]\` |
| \`status\` | relationship | scalar | \`<short status>\` |
| \`opinion\` | relationship | scalar | \`<your one-line take>\` |

\`owned\`'s \`wishlist\` value means wants-but-doesn't-yet-own. Each world-fact is
spec-sheet verifiable; each relationship-fact is established in conversation.
Apply a field only when the chunk supports it — a world-fact spec key belongs on
the kind of entity it describes (typically a hardware \`thing\`), never on a
\`domain\` or \`standard\`.

### Example info block (ILLUSTRATIVE SCHEMA — never copy these values)

The block below is a SHAPE, not content: every \`<…>\` is a placeholder. NEVER
copy these keys or values into a real article — emit ONLY facts the article's own
source chunks establish, and OMIT any key the chunks do not support. A key that
does not apply to the entity (e.g. a world-fact spec key on a \`domain\`, \`person\`,
or \`standard\`) must not appear at all.

\`\`\`info
type: <emergent label, from the chunks>
kind: <thing | person | domain | project | standard>
<world_fact_key>: <world value, from the chunks>
<relationship_fact_key>: <relationship value, from the chunks>
aliases: <comma-separated surface variants>
\`\`\`

## Categories

An article declares its category memberships with a single line near the top:

\`\`\`
categories: [[Category:<Name>]], [[Category:<Name>]]
\`\`\`

Categories are emergent and explicit — declared per-article by judgment, never
derived from the infobox \`type\`. See \`Category_Definitions.md\`.

## Stubs

New or thin articles may be marked \`{{stub}}\` at the top. An article is a stub
when it has fewer than 2 body sections OR fewer than 40 words of body prose
(excluding the infobox and References). Stubs are legitimate — depth comes
through accumulation. See \`Summary_Style.md\` for split/merge rules.
`;

const BUCKETS = `# Buckets

> **Superseded by \`Entities.md\` for synthesis targeting; retained as optional
> staging.** Synthesis now routes chunks to entity articles (see \`Entities.md\`),
> not buckets. Buckets survive only as an optional staging layer.

The bucket taxonomy used to organize segments of conversation into articles.
Buckets are emergent — derived from the actual content of conversations, not
imposed in advance. Populated by synthesis runs.
`;

const TOPICS_TO_IGNORE = `# Topics to Ignore

The chunker consults this page (mandatorily) before emitting chunks.

**Current policy: nothing is ignored. Surface everything.** Emit chunks for all substantive content; do not omit any span on the basis of this page. There are no excluded topics, people, or content categories.

To change this later: add plain-text descriptions of topics/people/content that should not be synthesized into the Dreaming, one per line under a list below. Semantic matching catches related content even when phrasing differs. While this section says "nothing is ignored," ignore nothing.
`;

const INFOBOX_SCHEMAS = `# Infobox Schemas

Infobox schemas are **emergent**, not a closed type list. This page is the
editable policy: a fixed generic grammar plus a growing registry of per-\`type\`
field sets the model has actually used. There is NO code-level enum of infobox
\`type\`s and NO \`type→schema\` map — editing this page re-tunes infobox extraction
with no code change.

## The grammar (the only fixed part)

1. **Every fact is one of two kinds:**
   - a **world-fact** — spec-sheet / citable (a \`<world_fact_key>\`);
   - a **relationship-fact** — conversation-established, the personal-notability
     layer (\`owned\`, \`used_for\`, \`chosen_over\`, and the like).
   Both are CONTENT the AI reads; neither is a query/filter index.
2. **Keys are \`snake_case\`.**
3. **A value naming another entity is a \`[[wikilink]]\`** — this feeds the link
   graph for navigation.
4. **Value-types are \`scalar | entity-link | enum | list | date\`.**
5. **\`kind:\`** tags the closed entity-kind (\`thing\`/\`person\`/\`domain\`/
   \`project\`/\`standard\`, default \`thing\`); **\`type:\`** carries the emergent label
   (a short free-form label).

When a newly-emergent \`type\` has no registry entry, propose one (a world /
relationship field split) and append it below. Reconcile a new \`type\` exactly as
a new category name is added to \`Category_Definitions.md\`.

## Registry (grows by judgment)

Each entry below is an **illustrative seed, not a closed set — extend by judgment
when a new kind of thing appears.** Field NAMES are a vocabulary to draw from
WHEN the chunks support them; any example VALUE anywhere in Meta is illustrative
ONLY. **NEVER copy a key or value (a \`type\`, a \`<world_fact_key>\`) into an article
whose own chunks do not establish it**, and never attach a world-fact spec to a
\`domain\` / \`person\` / \`standard\` entity.

### <type>
*Illustrative SHAPE of a registry entry, not real content — every \`<…>\` is a
placeholder; the real keys are supplied by the entity's own chunks. Extend by
judgment.*
- **world:** \`type\`, \`<world_fact_key>\`, \`<world_fact_key>\`
- **relationship:** \`owned\`, \`acquired\`, \`used_for\`, \`chosen_over\`, \`opinion\`, \`status\`

The fixed relationship keys above are the domain-neutral personal layer; each
\`<world_fact_key>\` slot is filled per-\`type\` from the chunks, NOT from this page.
`;

const CATEGORY_DEFINITIONS = `# Category Definitions

Categories are **emergent**, derived from your actual content — never imposed in
advance. There is NO hardcoded category vocabulary and NO \`type→category\` map.
This page is the editable policy plus a growing registry; editing it re-tunes
categorization with no code change.

## What a category is

A category is a **Wikipedia-style grouping of things** — a named set an article
joins by declaring membership. An article declares its categories with a single
line near the top:

\`\`\`
categories: [[Category:<Name>]], [[Category:<Name>]]
\`\`\`

Categories come into existence the first time an article declares them. A fresh
wiki starts with **zero** categories and grows them as articles are written.

## Naming rules

- **Title-case plural noun** (a \`<Plural Noun>\` naming the shared grouping).
- **Specific**, not vague (a precise grouping name, never a catch-all like \`Things\`).
- **Create a new category only when ≥2 articles would genuinely share it**;
  otherwise reuse an existing one or omit it. **Existing categories win** —
  prefer an established name over a near-duplicate new one.

## Registry

One \`Name — definition — parent?\` line is added here as each category is first
created. (Empty until the first category is declared.)
`;

const ENTITIES_POLICY = `# Entities

Governs ENTITY-EXTRACT and ROUTE: which things become entity articles, and how
they are named. Inlined into the stage prompts.

## The five kinds

Every entity has exactly one \`kind\` from the closed set:

- **thing** — a concrete object, product, or artifact (a named object).
- **person** — a named individual.
- **domain** — a broad subject area or field (a named field or area of study).
- **project** — an ongoing effort with a goal.
- **standard** — a spec, format, protocol, or material (a named spec or material).

Default to \`thing\` when no other kind clearly applies.

## Which subjects earn an article

This page does NOT gate on ownership, usefulness, or any single hard count.
Notability is editorial: **anything that recurs in your thinking is notable
enough**, and stub articles are encouraged for emerging topics (see
\`Editorial_Guidelines.md\`). Routing strongly prefers an existing article and
mints a new one only for a substantive, recurring subject with no existing home
(see \`Bucketing.md\`). **Nothing is dropped as trivia** — a subject with no
article yet is captured in its chunk and stays retrievable by search.

## Canonical naming

- Use **Wikipedia title casing**.
- Prefer the **specific subject name** (the actual named subject from the chunk,
  not a generic descriptor like "the thing" or "that one").
- \`aliases\` capture the variants (spelling, spacing, and short-form variants of
  the same name) so they all resolve to one article.

## Emit both granularities

When a chunk is about a specific thing inside a broad area, emit **both** the
specific entity AND the broad domain it belongs to — the precise product/proper
name and its connective field — so both the precise and the connective article
get the chunk. Do NOT copy example names from this policy; only emit things that
actually appear in the chunk text.

## Always keep the most specific name

ALWAYS emit the **most specific proper noun present in the chunk text** (the named
product, tool, person, place, or model). Never drop the concrete named thing in
favor of only the broad domain — the specific name is the load-bearing entity.
`;

const SUMMARY_STYLE = `# Summary Style

How articles split, merge, and mark stubs — Wikipedia's summary-style rules,
adapted. NORMALIZE and the parser recognize the template syntax defined here.

## SPLIT

When a thing covered inside a section **crosses the notability checklist** AND is
**large enough** (≥ a screen of prose, or worth its own infobox), move it to its
own article \`Specific_Thing.md\`. In the parent, leave a **2–3 sentence summary**
followed by a main-article pointer:

\`\`\`
*Main article: [[Specific_Thing]]*
\`\`\`

Every \`[^N]\` citation in the moved text travels with it to the child — no facts
are lost.

## MERGE

When two stubs describe the **same thing under different names**, merge them into
the canonical title. The loser's name becomes an \`alias\` on the survivor, and a
redirect note records the merge.

## Template syntax

- **\`{{Main}}\`** — the main-article pointer, written \`*Main article: [[Target]]*\`.
- **\`{{stub}}\`** — placed at the top of a thin article.
- **redirect** — a one-line note on a merged-away title pointing at the canonical
  article (\`*Redirects to [[Canonical]].*\`).

## Stub threshold (baked)

An article is a **stub** when it has **fewer than 2 body sections OR fewer than
40 words of body prose** (excluding the infobox and the References section).

## Worked example (SCHEMATIC — \`<…>\` placeholders only, never copy these literally)

A \`<Parent Subject>\` article has a \`<Child Subject>\` subsection that has grown to
own an infobox-worth of owned/used facts — it crosses notability and size, so it
SPLITS.

**Parent, after the split** (\`<Parent_Subject>\`, the \`<Child Subject>\` subsection):

\`\`\`
### <Child Subject>

<A 2–3 sentence summary of the child subject and how the user relates to it,
carrying any citation marker(s) from the moved prose.>[^k]

*Main article: [[<Child Subject>]]*
\`\`\`

**New child** (\`<Child_Subject>.md\`), with its own infobox and the facts moved
from the parent:

- \`# <Child Subject>\`
- an \`info\` block: \`type: <emergent label>\`, \`<world_fact_key>: [[Linked Entity]]\`,
  \`<world_fact_key>: <value>\`, \`kind: thing\`, \`owned: <yes|no|wishlist>\`,
  \`acquired: <YYYY-MM + how>\`,
  \`used_for: <use>; <use>\`,
  \`aliases: <surface variant>, <surface variant>\`
- a lead naming the **<Child Subject>** in bold, then \`## See also\` →
  \`[[Linked Entity]]\`, then \`## References\` last.

Every \`[^N]\` from the parent subsection (here \`[^k]\`) travels to the child — the
\`[^k]: \`conv:HASH\` (…)\` definition moves with the prose so no citation is lost.
`;

const CHUNKING = `# Chunking Style

How the conversation-segmentation stage decides what a chunk is. This documents the **current default behavior** — the pipeline already works this way; edit this page to change it. (The mechanism — every conversation is segmented into topic chunks emitted in the fixed output schema — is not tunable here; only the style below is.)

## Defaults

- Most substantive conversations contain **multiple** chunks, not one. Look hard for topic shifts.
- A topic shift is when the discussion moves from one subject to a **substantially different** subject (e.g. one feature → a different feature; a problem → a distinct related concern; topic X → topic Y).
- Sub-chunks for specific aspects within a single broad topic are acceptable.
- A short conversation (under ~4 messages, a single Q&A) may legitimately be one chunk. Most longer conversations are multiple.
- A topic that recurs later in the same conversation is its **own separate chunk**, not merged with the earlier occurrence.
- **Overlap:** two chunks may share **at most one boundary message**, and only when that message is genuinely substantive to *both* the topic ending and the one beginning (true dual-membership). Never overlap for connective filler ("anyway, switching gears"), and never let one chunk's range envelop several messages of another's — if two chunks would overlap by more than one message, redraw the boundary instead.
- Labels are specific and descriptive, ~4–10 words: name the concrete subject and the facet discussed (\`<specific subject> <facet>\`), never a vague catch-all (\`<generic topic word>\` alone, "a technical discussion", "a Q&A").

## How to tune

To bias toward fewer, larger chunks: instruct fewer/coarser boundaries and discourage aspect sub-chunks. To bias toward more, smaller chunks: encourage finer aspect splits. To change overlap behavior: state how aggressively boundary messages should be shared. The chunker follows this page over its built-in defaults.
`;

export const META_PAGES: Record<string, string> = {
  "Editorial_Guidelines.md": EDITORIAL_GUIDELINES,
  "Bucketing.md": BUCKETING,
  "Article_Conventions.md": ARTICLE_CONVENTIONS,
  "Infobox_Schemas.md": INFOBOX_SCHEMAS,
  "Category_Definitions.md": CATEGORY_DEFINITIONS,
  "Entities.md": ENTITIES_POLICY,
  "Summary_Style.md": SUMMARY_STYLE,
  "Buckets.md": BUCKETS,
  "Chunking.md": CHUNKING,
  "Topics_to_Ignore.md": TOPICS_TO_IGNORE,
};

const REPO_ROOT = join(import.meta.dir, "..", "..");

const REFERENCE_LINKS: { name: string; source: string }[] = [
  { name: "mlx-bun_README", source: join(REPO_ROOT, "README.md") },
  { name: "mlx-bun_Server_API", source: join(REPO_ROOT, "docs", "reference", "server-api.md") },
  { name: "mlx-bun_Server_Config", source: join(REPO_ROOT, "docs", "reference", "server-config.md") },
  { name: "mlx-bun_Library_API", source: join(REPO_ROOT, "docs", "reference", "library-api.md") },
  { name: "mlx-bun_Embedding", source: join(REPO_ROOT, "docs", "reference", "embedding.md") },
  { name: "mlx-bun_Distribution", source: join(REPO_ROOT, "docs", "reference", "distribution.md") },
  { name: "mlx-bun_Training", source: join(REPO_ROOT, "docs", "reference", "training.md") },
  { name: "mlx-bun_ORPO_Quickstart", source: join(REPO_ROOT, "docs", "reference", "orpo-quickstart.md") },
  { name: "mlx-bun_Product_Roadmap", source: join(REPO_ROOT, "docs", "planning", "PRODUCT_ROADMAP.md") },
];

async function seedReferenceLinks(root: string): Promise<string[]> {
  await mkdir(referenceDir(root), { recursive: true });
  const changed: string[] = [];
  for (const ref of REFERENCE_LINKS) {
    if (!(await pathExists(ref.source))) continue;
    const dest = join(referenceDir(root), `${ref.name}.md`);
    try {
      const existing = await lstat(dest);
      if (existing.isSymbolicLink()) {
        if ((await readlink(dest)) === ref.source) continue;
        await unlink(dest);
      } else {
        continue; // never clobber a user's real file
      }
    } catch {
      // Missing: create it below.
    }
    await symlink(ref.source, dest);
    changed.push(dest);
  }
  return changed;
}

function runGit(args: string[], cwd: string): Promise<boolean> {
  return new Promise((resolve) => {
    const proc = spawn("git", args, { cwd, stdio: "ignore" });
    proc.on("exit", (code) => resolve(code === 0));
    proc.on("error", () => resolve(false));
  });
}

export interface SetupResult {
  root: string;
  created: string[];
  gitInitialized: boolean;
  alreadySetUp: boolean;
}

/** Idempotent: create dirs, write README + Meta pages (only if missing — never
 *  clobber user edits), git init + initial commit. Safe to re-run. */
export async function setupVault(root = vaultRoot()): Promise<SetupResult> {
  const created: string[] = [];
  const ensureDir = async (p: string) => {
    if (!(await pathExists(p))) {
      await mkdir(p, { recursive: true });
      created.push(p);
    }
  };
  const writeIfMissing = async (p: string, content: string) => {
    if (!(await pathExists(p))) {
      await writeFile(p, content);
      created.push(p);
    }
  };

  await ensureDir(root);
  for (const sub of ["articles", "Reference", "Meta", "Talk"]) await ensureDir(join(root, sub));
  await writeIfMissing(join(root, "README.md"), README);
  // The vault is pure markdown — the synthesis DB lives in the rebuildable
  // cache (~/.cache/mlx-bun/memory.sqlite), not here. Just keep OS/editor
  // cruft (Finder, Obsidian workspace state) out of git history.
  await writeIfMissing(join(root, ".gitignore"), ".DS_Store\n.obsidian/workspace*\n");
  for (const [filename, content] of Object.entries(META_PAGES)) {
    await writeIfMissing(join(root, "Meta", filename), content);
  }
  created.push(...(await seedReferenceLinks(root)));

  let gitInitialized = false;
  if (!(await pathExists(join(root, ".git")))) {
    if (await runGit(["init"], root)) {
      await runGit(["add", "."], root);
      await runGit(["commit", "-m", "Initialize mlx-bun memory wiki"], root);
      gitInitialized = true;
    }
  }

  return { root, created, gitInitialized, alreadySetUp: created.length === 0 && !gitInitialized };
}

/** Stage everything and commit, if the vault is a git repo and has changes.
 *  Best-effort: silently no-ops when git is unavailable or nothing changed. */
export async function commitVault(root: string, message: string): Promise<void> {
  if (!(await pathExists(join(root, ".git")))) return;
  await runGit(["add", "."], root);
  await runGit(["commit", "-m", message], root);
}

export interface VaultStatus {
  root: string;
  exists: boolean;
  articleCount: number;
  referenceCount: number;
  isGitRepo: boolean;
  recentArticles: { article: string; mtimeMs: number }[];
}

export async function vaultStatus(root = vaultRoot()): Promise<VaultStatus> {
  const exists = await pathExists(root);
  const stems = exists ? await listArticles(root) : [];
  const refs = exists ? await listReferenceDocs(root) : [];
  const isGitRepo = exists && (await pathExists(join(root, ".git")));
  const recentArticles: { article: string; mtimeMs: number }[] = [];
  if (exists) {
    for (const article of stems) {
      try {
        const s = await stat(join(articlesDir(root), `${article}.md`));
        recentArticles.push({ article, mtimeMs: s.mtimeMs });
      } catch {
        // Ignore races/deleted files; status is best-effort.
      }
    }
    recentArticles.sort((a, b) => b.mtimeMs - a.mtimeMs);
  }
  return { root, exists, articleCount: stems.length, referenceCount: refs.length, isGitRepo, recentArticles: recentArticles.slice(0, 8) };
}

/** Copy `*.md` articles from another wiki/vault's articles/ dir into this one
 *  (skips files that already exist). Used by `memory init` to seed from an
 *  existing vault. Returns the imported stems. */
export async function importArticlesFrom(sourceArticlesDir: string, root = vaultRoot()): Promise<string[]> {
  let names: string[];
  try {
    names = await readdir(sourceArticlesDir);
  } catch {
    return [];
  }
  await mkdir(articlesDir(root), { recursive: true });
  const imported: string[] = [];
  for (const name of names) {
    if (!name.endsWith(".md") || name.startsWith(".")) continue;
    const dest = join(articlesDir(root), name);
    if (await pathExists(dest)) continue;
    await writeFile(dest, await readFile(join(sourceArticlesDir, name), "utf8"));
    imported.push(name.slice(0, -3));
  }
  return imported;
}
