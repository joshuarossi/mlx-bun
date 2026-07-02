// mlx-bun memory — the read tools the local assistant uses to consult your wiki.
//
// These are pi custom tools (defineTool), registered alongside the coding +
// web tools in both front doors (pi-terminal.ts, pi-web.ts). They're read-only,
// so they auto-allow (not in GATED_TOOLS) — consulting your own memory never
// needs an approval gate. They read ~/.mlx-bun/wiki via src/memory/vault.ts +
// the deterministic navigation index in src/memory/query.ts.
//
// The read surface is a deliberate FIND → READ path, never a vector search and
// never an infobox-field filter (the infobox is CONTENT the model reads, not a
// query target — there is NO memory_infobox_query):
//
//   memory_resolve  (name/alias → the article)        ─┐ FIND the article
//   memory_category (category/type/series → members)  ─┘ deterministically
//   memory_read     (TOC + lead by default)            ─┐ READ it small:
//   memory_section  (one section's body — THE DEFAULT) ─┘ TOC → one section
//   memory_links / memory_infobox (follow the graph / read the infobox)
//   memory_search   (LAST resort: substring fallback when FIND failed)
//
// Silent-colleague contract (ported from lucien's LUCIEN_INSTRUCTIONS): look the
// article up BEFORE answering; each article is the consolidated current position,
// so read it rather than reconstructing from raw history; then speak as a
// continuation, never "per the wiki…". Knowing *when* to consult is driven by
// these tool descriptions + the bundled memory skill (pi surfaces its description
// and loads the body on demand); the system prompt carries only a one-line
// presence hint (memoryIndexHint), not a title dump.

import { defineTool, type ToolDefinition } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import {
  infoboxFieldValues,
  parseInfobox,
  parseSeriesBanner,
  type Infobox,
} from "./article";
import {
  articlesInCategory,
  buildMemoryIndex,
  resolveName,
  type MemoryIndex,
} from "./query";
import { scheduleStatus } from "./schedule";
import {
  extractSection,
  extractWikilinkTargets,
  listArticles,
  listReferenceDocs,
  parseToc,
  readArticle,
  resolveWikilinkToStem,
  searchArticles,
  vaultRoot,
  vaultStatus,
  type SearchHit,
} from "./vault";

/** Tool names, exported so the front doors can add them to the allowlist. The
 *  order is the recommended call order: FIND (resolve/category) → READ (read/
 *  section) → follow (links/infobox) → reference utilities → search LAST. */
export const MEMORY_TOOL_NAMES = [
  "memory_resolve",
  "memory_category",
  "memory_read",
  "memory_section",
  "memory_links",
  "memory_infobox",
  "memory_list",
  "memory_status",
  "memory_search",
] as const;

export const REFERENCE_TOOL_NAMES = [
  "reference_search",
  "reference_read",
  "reference_list",
] as const;

const MAX_SEARCH_HITS = 30;
/** memory_search is the demoted fallback: only the strongest few summaries. */
const MAX_MEMORY_SUMMARIES = 8;
/** A whole-article read above this many bytes degrades to TOC+lead+steer. */
const MAX_FULL_READ_BYTES = 8 * 1024;
/** memory_category page size (rows) and per-row lead budget. */
const MAX_CATEGORY_ROWS = 40;
const CATEGORY_LEAD_CHARS = 140;
/** memory_links: cap per origin group before "+N more". */
const MAX_LINKS_PER_GROUP = 25;

function textResult(text: string): { content: [{ type: "text"; text: string }]; details: Record<string, never> } {
  return { content: [{ type: "text", text }], details: {} };
}

export async function isMemoryEnabled(): Promise<boolean> {
  try {
    return (await vaultStatus()).exists;
  } catch {
    return false;
  }
}

function isReferenceId(article: string): boolean {
  return article.trim().startsWith("Reference/");
}

async function memoryUnavailableMessage(): Promise<string | null> {
  const st = await vaultStatus();
  if (st.exists) return null;
  return `Memory is not set up yet at ${st.root}. Run \`mlx-bun memory init\` to create the local Markdown wiki, or ask the user before setting it up.`;
}

/** Title form of a stem (underscores → spaces). */
function titleOf(stem: string): string {
  return stem.replace(/_/g, " ");
}

/** Casefold + collapse whitespace/underscores (mirrors query.ts/reindex.ts). */
function normalizeAlias(s: string): string {
  return s.trim().toLowerCase().replace(/_/g, " ").replace(/\s+/g, " ").trim();
}

/** Truncate to a budget, marking the cut so callers never silently lose text. */
function clip(text: string, max: number): string {
  const t = text.trim();
  return t.length <= max ? t : `${t.slice(0, max - 1).trimEnd()}…`;
}

/** Compact, model-friendly rendering of search hits grouped by relevance. */
function formatSearch(
  query: string,
  summaries: { article: string; occurrences: number; matched_terms?: string[] }[],
  hits: SearchHit[],
  opts: { corpusLabel?: string; readTool?: string; maxSummaries?: number } = {},
): string {
  const corpus = opts.corpusLabel ?? "personal-memory articles";
  const readTool = opts.readTool ?? "memory_read";
  const maxSummaries = opts.maxSummaries ?? 12;
  if (summaries.length === 0) return `No ${corpus} match "${query}".`;
  const top = summaries.slice(0, maxSummaries);
  const lines = [`${corpus[0]!.toUpperCase()}${corpus.slice(1)} matching "${query}" (most relevant first):`, ""];
  for (const s of top) {
    const terms = s.matched_terms && s.matched_terms.length ? ` [${s.matched_terms.join(", ")}]` : "";
    lines.push(`- ${s.article} (${s.occurrences} hit${s.occurrences === 1 ? "" : "s"})${terms}`);
  }
  if (summaries.length > top.length) lines.push(`  …and ${summaries.length - top.length} more.`);
  if (hits.length) {
    lines.push("", "Sample lines:");
    for (const h of hits.slice(0, 8)) {
      const where = h.anchor ? `${h.article}#${h.anchor}` : h.article;
      lines.push(`- ${where}:${h.line}  ${h.excerpt}`);
    }
  }
  lines.push("", `Read a result with ${readTool} (e.g. ${readTool} stem="${top[0]!.article}").`);
  return lines.join("\n");
}

// ---- index access -----------------------------------------------------

/** Build the (mtime-cached) navigation index over the live vault. */
function index(): MemoryIndex {
  return buildMemoryIndex(vaultRoot());
}

function kindOf(idx: MemoryIndex, stem: string): string {
  return idx.infoboxByStem.get(stem)?.entityKind ?? "thing";
}

function leadOf(idx: MemoryIndex, stem: string): string | null {
  return idx.leadByStem.get(stem) ?? null;
}

// ---- FIND: resolve by name/alias --------------------------------------

const memoryResolveTool = defineTool({
  name: "memory_resolve",
  label: "Resolve Memory Article",
  description:
    "FIND the user's article for a name or alias — the first move when the user names a specific thing, person, project, or topic. " +
    "Deterministic alias lookup (no model, no substring search): returns the matched article's stem, title, kind, and lead so you can then read it. " +
    "On a miss it offers up to 3 near candidates. Look the article up before answering rather than guessing from raw history.",
  parameters: Type.Object({
    surface: Type.String({ description: "The name or alias as the user said it (a short form or the way they referred to the thing)." }),
  }),
  execute: async (_id, params) => {
    const surface = params.surface.trim();
    if (!surface) return textResult("memory_resolve needs a name or alias.");
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      const idx = index();
      const stem = resolveName(idx, surface);
      if (stem) {
        const lead = leadOf(idx, stem);
        return textResult(
          [
            `${titleOf(stem)}  (stem: ${stem}, kind: ${kindOf(idx, stem)})`,
            lead ? `\n${clip(lead, 360)}` : "",
            `\n\nRead it with memory_read stem="${stem}" (TOC + lead), then memory_section for the part you need.`,
          ].join(""),
        );
      }
      // Miss: deterministic token-overlap candidates (no substring, no model).
      const qTokens = new Set(normalizeAlias(surface).split(" ").filter(Boolean));
      const scored = new Map<string, number>();
      for (const [alias, st] of idx.aliasToStem) {
        let shared = 0;
        for (const tok of alias.split(" ")) if (qTokens.has(tok)) shared++;
        if (shared > 0) scored.set(st, Math.max(scored.get(st) ?? 0, shared));
      }
      const candidates = [...scored.entries()]
        .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))
        .slice(0, 3)
        .map(([st]) => st);
      if (candidates.length === 0) {
        return textResult(`No article resolves "${surface}". Try memory_category to find articles about a topic, or memory_search as a last resort.`);
      }
      return textResult(
        `No exact match for "${surface}". Did you mean one of:\n` +
          candidates.map((st) => `- ${titleOf(st)} (stem: ${st})`).join("\n") +
          `\n\nResolve one with memory_read, or use memory_category for a topic.`,
      );
    } catch (err) {
      return textResult(`memory_resolve failed: ${err instanceof Error ? err.message : String(err)}`);
    }
  },
});

// ---- FIND: articles about a category / type / series ------------------

const memoryCategoryTool = defineTool({
  name: "memory_category",
  label: "Articles in Category",
  description:
    "FIND the articles ABOUT a topic by membership — the \"articles about X\" finder. " +
    "Pass exactly one of category, type, or series; returns the member articles as \"stem · lead\" rows. " +
    "This is deterministic set membership (declared [[Category:…]] / infobox type / series banner), NOT a search and NOT an infobox-field filter. " +
    "Use it to land on the right article, then memory_read its TOC and memory_section the one part you need.",
  parameters: Type.Object({
    category: Type.Optional(Type.String({ description: "Category name — the grouping declared as [[Category:<Name>]] near the top of member articles." })),
    type: Type.Optional(Type.String({ description: "Infobox type label (the article's `type:` field value)." })),
    series: Type.Optional(Type.String({ description: "Series name from a *Part of a series on [[X]]* banner." })),
  }),
  execute: async (_id, params) => {
    const category = params.category?.trim();
    const type = params.type?.trim();
    const series = params.series?.trim();
    const picked = [category, type, series].filter((v) => v && v.length > 0);
    if (picked.length !== 1) {
      return textResult("memory_category needs exactly one of: category, type, or series.");
    }
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      const idx = index();
      let stems: string[];
      let label: string;
      if (category) {
        stems = articlesInCategory(idx, category);
        label = `Category:${category}`;
      } else if (type) {
        stems = [...(idx.typeToStems.get(type) ?? [])];
        label = `type:${type}`;
      } else {
        stems = [...(idx.seriesToStems.get(series!) ?? [])];
        label = `series:${series}`;
      }
      if (stems.length === 0) return textResult(`No articles in ${label}.`);
      const page = stems.slice(0, MAX_CATEGORY_ROWS);
      const lines = [`Articles in ${label} (${stems.length}):`, ""];
      for (const stem of page) {
        const lead = leadOf(idx, stem);
        lines.push(lead ? `- ${stem} · ${clip(lead, CATEGORY_LEAD_CHARS)}` : `- ${stem}`);
      }
      if (stems.length > page.length) lines.push(`  …and ${stems.length - page.length} more.`);
      lines.push("", "Open one with memory_read, then memory_section for the relevant part.");
      return textResult(lines.join("\n"));
    } catch (err) {
      return textResult(`memory_category failed: ${err instanceof Error ? err.message : String(err)}`);
    }
  },
});

// ---- READ: TOC + lead by default; full only on force -------------------

function tocAndLead(content: string, stem: string, idx: MemoryIndex, note?: string): string {
  const lead = leadOf(idx, stem);
  const toc = parseToc(content);
  const lines = [`${titleOf(stem)}  (stem: ${stem})`];
  if (lead) lines.push("", clip(lead, 480));
  if (note) lines.push("", note);
  lines.push("", "Sections:");
  if (toc.length === 0) lines.push("- (no headings)");
  else for (const h of toc) lines.push(`${"  ".repeat(Math.max(0, h.depth - 1))}- ${h.title}  (#${h.anchor})`);
  lines.push("", `Read the one relevant section with memory_section stem="${stem}" anchor="…". Whole article: memory_read stem="${stem}" force=true.`);
  return lines.join("\n");
}

const memoryReadTool = defineTool({
  name: "memory_read",
  label: "Read Memory Article",
  description:
    "Open one article. BY DEFAULT returns its TOC + lead so you can pick the one section you need — small focused reads are the norm, never a whole-article dump. " +
    "Pass force=true for the full prose+infobox, but only when you genuinely need the whole article (large articles still degrade to TOC+lead). " +
    "The article is the user's consolidated current position on its topic; read it before answering rather than reconstructing from history. " +
    "Pass the article stem (underscored, e.g. an \"<Article_Stem>\" filename without .md).",
  parameters: Type.Object({
    stem: Type.String({ description: "Article stem (underscored filename, no .md — e.g. \"<Article_Stem>\")." }),
    force: Type.Optional(Type.Boolean({ description: "Return the FULL article instead of TOC+lead. Use sparingly." })),
  }),
  execute: async (_id, params) => {
    const stem = params.stem.trim();
    if (!stem) return textResult("memory_read needs an article stem.");
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      if (isReferenceId(stem)) return textResult("memory_read is for personal-memory articles. Use reference_read for Reference/ documents.");
      const { content } = await readArticle(vaultRoot(), stem);
      const idx = index();
      if (!params.force) return textResult(tocAndLead(content, stem, idx));
      const bytes = Buffer.byteLength(content, "utf8");
      if (bytes > MAX_FULL_READ_BYTES) {
        return textResult(
          tocAndLead(content, stem, idx, `(This article is large — ${(bytes / 1024).toFixed(1)} KB. Read just the section you need.)`),
        );
      }
      return textResult(content);
    } catch (err) {
      return textResult(`${err instanceof Error ? err.message : String(err)} — try memory_resolve or memory_category to find the right article.`);
    }
  },
});

const memorySectionTool = defineTool({
  name: "memory_section",
  label: "Read Memory Section",
  description:
    "Read ONE section of an article by its heading anchor. This is the DEFAULT read: find the article, scan its TOC with memory_read, then read just the relevant section here — much cheaper than the whole article. " +
    "Get anchors from memory_read's TOC.",
  parameters: Type.Object({
    stem: Type.String({ description: "Article stem (underscored, e.g. \"<Article_Stem>\")." }),
    anchor: Type.String({ description: "Heading anchor (the slug of a section heading from memory_read's TOC, e.g. \"<section-anchor>\")." }),
  }),
  execute: async (_id, params) => {
    const stem = params.stem.trim();
    const anchor = params.anchor.trim().replace(/^#/, "");
    if (!stem) return textResult("memory_section needs an article stem.");
    if (!anchor) return textResult("memory_section needs a heading anchor.");
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      if (isReferenceId(stem)) return textResult("memory_section is for personal-memory articles. Use reference_read for Reference/ documents.");
      const { content } = await readArticle(vaultRoot(), stem);
      const section = extractSection(content, anchor);
      if (!section) return textResult(`No section #${anchor} in ${stem}. Use memory_read stem="${stem}" to see the TOC.`);
      return textResult(section);
    } catch (err) {
      return textResult(`${err instanceof Error ? err.message : String(err)} — try memory_resolve or memory_category to find the right article.`);
    }
  },
});

// ---- FOLLOW: links grouped by origin ----------------------------------

const WIKILINK_RE = /\[\[([^\]]+)\]\]/g;

/** Resolved outbound links grouped by where they appear in the article. Mirrors
 *  the reindex `via` taxonomy (infobox/series/seealso/prose); red links (no
 *  existing article) are dropped, matching getArticleLinks. */
function groupedOutbound(content: string, stem: string, stemSet: Set<string>, box: Infobox | null): {
  infobox: string[];
  series: string[];
  seealso: string[];
  prose: string[];
} {
  const dedupe = (arr: string[]): string[] => [...new Set(arr)].sort((a, b) => a.localeCompare(b));
  const resolve = (raw: string): string | null => {
    const base = raw.split("|")[0]!.split("#")[0]!.trim();
    const r = resolveWikilinkToStem(base, stemSet);
    return r && r !== stem ? r : null;
  };

  const infobox: string[] = [];
  if (box) {
    for (const field of box.fields) {
      for (const value of infoboxFieldValues(field)) {
        WIKILINK_RE.lastIndex = 0;
        const m = WIKILINK_RE.exec(value);
        if (m) {
          const r = resolve(m[1]!);
          if (r) infobox.push(r);
        }
      }
    }
  }

  const series: string[] = [];
  const banner = parseSeriesBanner(content);
  if (banner) {
    const r = resolve(banner);
    if (r) series.push(r);
  }

  const seealso: string[] = [];
  const prose: string[] = [];
  const lines = content.split(/\r?\n/);
  let inFence = false;
  let section: string | null = null;
  for (const line of lines) {
    if (/^```/.test(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const hm = /^(#{1,6})\s+(.+)$/.exec(line);
    if (hm) {
      if (hm[1]!.length >= 2) section = hm[2]!.trim().toLowerCase();
      continue;
    }
    const t = line.trim();
    if (/^\*part of a series on \[\[/i.test(t)) continue;
    if (/^categories:/i.test(t)) continue;
    if (/^\*?\s*main article:/i.test(t)) continue;
    WIKILINK_RE.lastIndex = 0;
    let m: RegExpExecArray | null;
    while ((m = WIKILINK_RE.exec(line)) !== null) {
      const base = m[1]!.split("|")[0]!.split("#")[0]!.trim();
      if (!base || /^conv:/i.test(base) || /^Category:/i.test(base)) continue;
      const r = resolve(base);
      if (!r) continue;
      if (section === "see also") seealso.push(r);
      else prose.push(r);
    }
  }

  return { infobox: dedupe(infobox), series: dedupe(series), seealso: dedupe(seealso), prose: dedupe(prose) };
}

const memoryLinksTool = defineTool({
  name: "memory_links",
  label: "Memory Links",
  description:
    "Follow the wiki graph: the article's outgoing [[links]] grouped by where they come from (infobox / series / see also / prose), plus inbound backlinks. " +
    "Use to hop to a neighbouring article (e.g. from one entity's infobox [[wikilink]] to the linked entity's article) when a topic genuinely spans articles.",
  parameters: Type.Object({
    stem: Type.String({ description: "Article stem (underscored, e.g. \"<Article_Stem>\")." }),
  }),
  execute: async (_id, params) => {
    const stem = params.stem.trim();
    if (!stem) return textResult("memory_links needs an article stem.");
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      if (isReferenceId(stem)) return textResult("memory_links is for personal-memory articles; Reference/ documents are not in the link graph.");
      const { content } = await readArticle(vaultRoot(), stem);
      const stems = await listArticles(vaultRoot());
      const stemSet = new Set(stems);
      if (!stemSet.has(stem)) return textResult(`Article not found: ${stem}.`);
      const box = parseInfobox(content);
      const groups = groupedOutbound(content, stem, stemSet, box);

      // Inbound: who points here (any origin).
      const inbound: string[] = [];
      for (const other of stems) {
        if (other === stem) continue;
        try {
          const oc = (await readArticle(vaultRoot(), other)).content;
          const og = groupedOutbound(oc, other, stemSet, parseInfobox(oc));
          if ([...og.infobox, ...og.series, ...og.seealso, ...og.prose].includes(stem)) inbound.push(other);
        } catch {
          // best-effort
        }
      }

      const renderGroup = (title: string, arr: string[]): string => {
        if (arr.length === 0) return `${title}: (none)`;
        const shown = arr.slice(0, MAX_LINKS_PER_GROUP);
        const extra = arr.length > shown.length ? ` +${arr.length - shown.length} more` : "";
        return `${title}: ${shown.join(", ")}${extra}`;
      };
      return textResult(
        [
          `Links for ${stem}:`,
          "",
          renderGroup("infobox", groups.infobox),
          renderGroup("series", groups.series),
          renderGroup("see also", groups.seealso),
          renderGroup("prose", groups.prose),
          renderGroup("inbound", inbound.sort((a, b) => a.localeCompare(b))),
        ].join("\n"),
      );
    } catch (err) {
      return textResult(`${err instanceof Error ? err.message : String(err)} — try memory_resolve or memory_category to find the right article.`);
    }
  },
});

// ---- READ the infobox as content (NOT a query target) -----------------

const memoryInfoboxTool = defineTool({
  name: "memory_infobox",
  label: "Read Memory Infobox",
  description:
    "Read an article's infobox as key:value CONTENT — the structured facts (the `type:`, `kind:`, relationship, and world-fact fields). " +
    "This surfaces facts to READ, not a filter: there is no way to query/sort articles by an infobox field; to find articles use memory_category or memory_resolve.",
  parameters: Type.Object({
    stem: Type.String({ description: "Article stem (underscored, e.g. \"<Article_Stem>\")." }),
  }),
  execute: async (_id, params) => {
    const stem = params.stem.trim();
    if (!stem) return textResult("memory_infobox needs an article stem.");
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      if (isReferenceId(stem)) return textResult("memory_infobox is for personal-memory articles.");
      const idx = index();
      if (!idx.infoboxByStem.has(stem)) return textResult(`Article not found: ${stem}.`);
      const box = idx.infoboxByStem.get(stem) ?? null;
      if (!box || box.fields.length === 0) return textResult(`${stem} has no infobox.`);
      return textResult(
        `Infobox for ${stem} (facts to read, not a filter):\n\n` +
          box.fields.map((f) => `${f.key}: ${f.value}`).join("\n"),
      );
    } catch (err) {
      return textResult(`memory_infobox failed: ${err instanceof Error ? err.message : String(err)}`);
    }
  },
});

// ---- overview + status ------------------------------------------------

const memoryListTool = defineTool({
  name: "memory_list",
  label: "List Memory",
  description:
    "List the stems of the user's personal-memory articles. An overview/fallback when memory_resolve and memory_category don't surface what you expected — not a first move.",
  parameters: Type.Object({}),
  execute: async () => {
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      const articles = await listArticles(vaultRoot());
      if (articles.length === 0) return textResult("The user's memory has no personal articles yet.");
      return textResult(
        `${articles.length} personal-memory article(s):\n\n` + articles.map((s) => `- ${s}`).join("\n"),
      );
    } catch (err) {
      return textResult(`memory_list failed: ${err instanceof Error ? err.message : String(err)}`);
    }
  },
});

/** Last synthesis-pipeline write to the vault, from its git log (every
 *  pipeline write commits with a "memory: …" message — synthesize.ts,
 *  reconcile.ts, wikify.ts, stages.ts). null when the vault has no git repo
 *  or no synthesis commit yet. */
async function lastSynthesisCommit(root: string): Promise<{ date: string; subject: string } | null> {
  try {
    const proc = Bun.spawn(
      ["git", "log", "-1", "--grep=^memory: ", "--format=%cI\t%s"],
      { cwd: root, stdout: "pipe", stderr: "ignore" },
    );
    const out = (await new Response(proc.stdout).text()).trim();
    if ((await proc.exited) !== 0 || !out) return null;
    const tab = out.indexOf("\t");
    if (tab === -1) return null;
    return { date: out.slice(0, tab), subject: out.slice(tab + 1) };
  } catch {
    return null;
  }
}

const memoryStatusTool = defineTool({
  name: "memory_status",
  label: "Memory Status",
  description:
    "Show read-only status for the user's memory: vault path, setup state, article count, git state, last synthesis run, and nightly schedule state. Use when the user asks whether memory is on or where it lives.",
  parameters: Type.Object({}),
  execute: async () => {
    try {
      const st = await vaultStatus();
      const sched = await scheduleStatus();
      const last = st.isGitRepo ? await lastSynthesisCommit(st.root) : null;
      const recent = st.recentArticles.length
        ? st.recentArticles.slice(0, 5).map((r) => `  - ${r.article} (${new Date(r.mtimeMs).toISOString()})`).join("\n")
        : "  - (none)";
      return textResult([
        "Memory status:",
        `- vault: ${st.root}`,
        `- setup: ${st.exists ? "yes" : "no"}`,
        `- articles: ${st.articleCount}`,
        `- read-only references: ${st.referenceCount}`,
        `- git: ${st.isGitRepo ? "tracked" : "not tracked"}`,
        `- last synthesis: ${last ? `${last.date} (${last.subject})` : "no synthesis run recorded yet"}`,
        "- synthesis: available — `mlx-bun memory synthesize` runs the full local pipeline (conversations → articles); the nightly job runs it automatically when scheduled",
        `- nightly: ${sched.installed ? (sched.loaded ? "scheduled" : "installed but not loaded") : "not scheduled"}`,
        sched.installed ? `- launchd plist: ${sched.plistPath}` : "- setup command: mlx-bun memory init",
        "- recent changed articles:",
        recent,
      ].join("\n"));
    } catch (err) {
      return textResult(`memory_status failed: ${err instanceof Error ? err.message : String(err)}`);
    }
  },
});

// ---- search: the demoted last-resort fallback -------------------------

const memorySearchTool = defineTool({
  name: "memory_search",
  label: "Search Memory (fallback)",
  description:
    "LAST-RESORT substring search across memory articles — use ONLY when name/category lookup (memory_resolve, memory_category) has failed across a couple of phrasings. " +
    "It does not understand meaning; prefer the deterministic finders first. Returns the top few article matches; follow up with memory_read.",
  parameters: Type.Object({
    query: Type.String({ description: "Word or phrase to substring-match across memory articles." }),
    limit: Type.Optional(Type.Number({ description: `Max sample line-hits to return (default ${MAX_SEARCH_HITS}).` })),
  }),
  execute: async (_id, params) => {
    const query = params.query.trim();
    if (!query) return textResult("memory_search needs a non-empty query.");
    const limit = Math.max(1, Math.min(MAX_SEARCH_HITS, Math.round(params.limit ?? MAX_SEARCH_HITS)));
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      const { summaries, hits } = await searchArticles(vaultRoot(), query, { limit, scope: "articles" });
      return textResult(formatSearch(query, summaries, hits, { maxSummaries: MAX_MEMORY_SUMMARIES }));
    } catch (err) {
      return textResult(`memory_search failed: ${err instanceof Error ? err.message : String(err)}`);
    }
  },
});

// ---- reference docs (separate from personal memory) -------------------

const referenceSearchTool = defineTool({
  name: "reference_search",
  label: "Search mlx-bun Reference",
  description:
    "Search read-only mlx-bun reference documents that are symlinked into the memory vault. " +
    "Use for mlx-bun documentation questions when repository files are not enough. This is project reference, not personal memory.",
  parameters: Type.Object({
    query: Type.String({ description: "Word or phrase to search for across mlx-bun reference documents." }),
    limit: Type.Optional(Type.Number({ description: `Max sample line-hits to return (default ${MAX_SEARCH_HITS}).` })),
  }),
  execute: async (_id, params) => {
    const query = params.query.trim();
    if (!query) return textResult("reference_search needs a non-empty query.");
    const limit = Math.max(1, Math.min(MAX_SEARCH_HITS, Math.round(params.limit ?? MAX_SEARCH_HITS)));
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      const { summaries, hits } = await searchArticles(vaultRoot(), query, { limit, scope: "reference" });
      return textResult(formatSearch(query, summaries, hits, { corpusLabel: "read-only reference documents", readTool: "reference_read" }));
    } catch (err) {
      return textResult(`reference_search failed: ${err instanceof Error ? err.message : String(err)}`);
    }
  },
});

const referenceReadTool = defineTool({
  name: "reference_read",
  label: "Read mlx-bun Reference",
  description:
    "Read one read-only mlx-bun reference document from the vault's Reference/ namespace. " +
    "Pass the id exactly as returned by reference_search or reference_list, e.g. \"Reference/mlx-bun_Server_API\".",
  parameters: Type.Object({
    article: Type.String({ description: "Reference doc id, e.g. \"Reference/mlx-bun_Server_API\"." }),
  }),
  execute: async (_id, params) => {
    const article = params.article.trim();
    if (!article) return textResult("reference_read needs a Reference/... document id.");
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      const id = article.startsWith("Reference/") ? article : `Reference/${article}`;
      const { content } = await readArticle(vaultRoot(), id);
      return textResult(content);
    } catch (err) {
      return textResult(`${err instanceof Error ? err.message : String(err)} — try reference_search to find the right reference document.`);
    }
  },
});

const referenceListTool = defineTool({
  name: "reference_list",
  label: "List mlx-bun References",
  description: "List read-only mlx-bun reference documents available under the vault's Reference/ namespace.",
  parameters: Type.Object({}),
  execute: async () => {
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      const refs = await listReferenceDocs(vaultRoot());
      if (refs.length === 0) return textResult("No read-only reference documents are linked in the memory vault.");
      return textResult(`${refs.length} read-only reference document(s):\n\n` + refs.map((s) => `- ${s}`).join("\n"));
    } catch (err) {
      return textResult(`reference_list failed: ${err instanceof Error ? err.message : String(err)}`);
    }
  },
});

export function createMemoryTools(): ToolDefinition[] {
  return [
    memoryResolveTool,
    memoryCategoryTool,
    memoryReadTool,
    memorySectionTool,
    memoryLinksTool,
    memoryInfoboxTool,
    memoryListTool,
    memoryStatusTool,
    memorySearchTool,
  ];
}

export function createReferenceTools(): ToolDefinition[] {
  return [referenceSearchTool, referenceReadTool, referenceListTool];
}

/**
 * One gated line for the system prompt: states that memory is ON for this user
 * and points at the `memory` skill, plus the FIND→READ order and the
 * silent-colleague contract. NOT a title dump and NOT a how-to. pi already
 * auto-injects every skill's name+description+location (formatSkillsForPrompt)
 * and loads the SKILL.md body on demand, so the skill owns the detailed
 * workflow. This hint is intentionally soft: memory is a scoped retrieval
 * capability for user-specific continuity, not a default first step for every
 * prompt. Returns "" when memory is not turned on (vault absent) so we never
 * advertise memory the user hasn't enabled. Runs once at session construction.
 */
export async function memoryIndexHint(): Promise<string> {
  let st: Awaited<ReturnType<typeof vaultStatus>>;
  try {
    st = await vaultStatus();
  } catch {
    return "";
  }
  if (!st.exists) return ""; // memory not turned on → don't advertise it
  const articleCount = st.articleCount > 0 ? `${st.articleCount} article${st.articleCount === 1 ? "" : "s"}` : "no user articles yet";
  const refCount = st.referenceCount > 0 ? ` plus ${st.referenceCount} read-only mlx-bun reference doc${st.referenceCount === 1 ? "" : "s"}` : "";
  return (
    `\n\nThe user's personal memory is on (${articleCount}${refCount}). When the answer depends on user-specific ` +
    `continuity or missing personal context, look it up BEFORE answering: FIND the article (memory_resolve a name, ` +
    `or memory_category for a topic), open its TOC with memory_read, then memory_section the one relevant part — ` +
    `each article is the user's consolidated current position, so read it rather than reconstructing from history. ` +
    `Whole-article reads and memory_search are last resorts. Use what you find silently, as a continuation — never ` +
    `"per the wiki…". Do not use memory for weather, current public facts, generic web research, or ordinary ` +
    `coding/file tasks when the current files are enough. See the \`memory\` skill for the workflow.`
  );
}
