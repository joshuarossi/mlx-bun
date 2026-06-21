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

function isFenceLine(line: string): boolean {
  return /^```/.test(line);
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

This wiki follows Wikipedia's editorial conventions except as noted. When in
doubt, do what Wikipedia would do.

## Scope adaptations for a personal wiki

- **Subject**: you. Articles describe the people, projects, ideas, tools, and
  topics relevant to your thinking.
- **Sources**: your conversation transcripts with the local assistant. Each
  article cites the conversations that contributed to it (\`conv:HASH\`).
- **Neutral point of view**: adapted. The wiki represents your actual views and
  reasoning. "Neutral" here means faithful to the evidence in your
  conversations, not pretending to be from no perspective.
- **Notability**: anything that recurs in your thinking is notable enough. Stub
  articles are encouraged for emerging topics.

## Maintenance disposition

Synthesis operates like a Wikipedia editor making small, conservative
contributions. Edits integrate rather than replace. Trajectories ("used to
think X, now thinks Y") are preserved. Talk pages surface concerns rather than
silently resolving them.
`;

const ARTICLE_CONVENTIONS = `# Article Conventions

Each article follows roughly this shape:

1. **Lead paragraph** — a 2-4 sentence summary of what the article is about
2. **Sections** — organized by sub-topic, in a logical reading order
3. **See also** — links to related articles
4. **References** — \`conv:HASH\` citations to source conversations

## Citations

Inline claims are followed by a footnote marker; the \`## References\` section at
the bottom collects the entries. The canonical conversation identifier is the
first 8 hex chars of its session UUID, written \`conv:HASH\`, followed by an
em-dash and a short description of what the conversation covered.

## Links

Use wikilinks for internal references: \`[[Article Name]]\`. These resolve to the
correct files (spaces vs underscores and case are normalized).

## Stubs

New or thin articles may be marked \`{{stub}}\` at the top. Stubs are legitimate —
the wiki earns its value through coverage; depth comes through accumulation.
`;

const BUCKETS = `# Buckets

The bucket taxonomy used to organize segments of conversation into articles.
Buckets are emergent — derived from the actual content of conversations, not
imposed in advance. Populated by synthesis runs.
`;

const TOPICS_TO_IGNORE = `# Topics to Ignore

Topics, individuals, or content categories that should NOT be synthesized into
your wiki. Synthesis consults this page during its filter step. Add entries as
plain-text descriptions; semantic matching catches related content even when
the phrasing differs.

## Examples

- (none yet — add your own)
`;

const META_PAGES: Record<string, string> = {
  "Editorial_Guidelines.md": EDITORIAL_GUIDELINES,
  "Article_Conventions.md": ARTICLE_CONVENTIONS,
  "Buckets.md": BUCKETS,
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
