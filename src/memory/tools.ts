// mlx-bun memory — the read tools the local assistant uses to consult your wiki.
//
// These are pi custom tools (defineTool), registered alongside the coding +
// web tools in both front doors (pi-terminal.ts, pi-web.ts). They're read-only,
// so they auto-allow (not in GATED_TOOLS) — consulting your own memory never
// needs an approval gate. They read ~/.mlx-bun/wiki via src/memory/vault.ts.
//
// Mirrors lucien's read surface: search (discovery) → focused read (toc /
// section / links) → full read / list / status. Knowing *when* to consult is
// driven by these tool descriptions and the bundled memory skill (pi surfaces
// its description and loads the body on demand); the system prompt carries only
// a one-line presence hint (memoryIndexHint), not a title dump.

import { defineTool, type ToolDefinition } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { scheduleStatus } from "./schedule";
import {
  extractSection,
  getArticleLinks,
  listArticles,
  listReferenceDocs,
  parseToc,
  readArticle,
  searchArticles,
  vaultRoot,
  vaultStatus,
  type SearchHit,
} from "./vault";

/** Tool names, exported so the front doors can add them to the allowlist. */
export const MEMORY_TOOL_NAMES = [
  "memory_search",
  "memory_read",
  "memory_toc",
  "memory_section",
  "memory_links",
  "memory_list",
  "memory_status",
] as const;

export const REFERENCE_TOOL_NAMES = [
  "reference_search",
  "reference_read",
  "reference_list",
] as const;

const MAX_SEARCH_HITS = 30;

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

/** Compact, model-friendly rendering of search hits grouped by relevance. */
function formatSearch(
  query: string,
  summaries: { article: string; occurrences: number; matched_terms?: string[] }[],
  hits: SearchHit[],
  opts: { corpusLabel?: string; readTool?: string } = {},
): string {
  const corpus = opts.corpusLabel ?? "personal-memory articles";
  const readTool = opts.readTool ?? "memory_read";
  if (summaries.length === 0) return `No ${corpus} match "${query}".`;
  const top = summaries.slice(0, 12);
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
  lines.push("", `Read a full result with ${readTool} (e.g. ${readTool} article="${top[0]!.article}").`);
  return lines.join("\n");
}

const memorySearchTool = defineTool({
  name: "memory_search",
  label: "Search Memory",
  description:
    "Search the user's local personal-memory articles for user-specific continuity: prior conversations, named personal projects, people, preferences, decisions, or history. " +
    "Use when the answer depends on missing personal context; do not use for weather, current public facts, generic web research, or ordinary coding/file tasks when current files are sufficient. " +
    "Returns ranked article matches and sample lines; follow up with memory_read to read a relevant article in full.",
  parameters: Type.Object({
    query: Type.String({ description: "Word or phrase to search for across the user's memory articles." }),
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
      return textResult(formatSearch(query, summaries, hits));
    } catch (err) {
      return textResult(`memory_search failed: ${err instanceof Error ? err.message : String(err)}`);
    }
  },
});

const memoryReadTool = defineTool({
  name: "memory_read",
  label: "Read Memory",
  description:
    "Read one full Markdown article from the user's personal memory. " +
    "Use after memory_search when user-specific prior context is needed. " +
    "Pass the article stem exactly as returned by memory_search or memory_list (underscored, e.g. \"Archie_Project\").",
  parameters: Type.Object({
    article: Type.String({ description: "Article stem to read (underscored filename, no .md, e.g. \"Archie_Project\")." }),
  }),
  execute: async (_id, params) => {
    const article = params.article.trim();
    if (!article) return textResult("memory_read needs an article name.");
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      if (isReferenceId(article)) return textResult("memory_read is for personal-memory articles. Use reference_read for Reference/ documents.");
      const { content } = await readArticle(vaultRoot(), article);
      return textResult(content);
    } catch (err) {
      return textResult(`${err instanceof Error ? err.message : String(err)} — try memory_search to find the right article name.`);
    }
  },
});

const memoryTocTool = defineTool({
  name: "memory_toc",
  label: "Memory TOC",
  description:
    "List the Markdown headings in one memory article, with anchors. Use before memory_section when the article is long or you need a specific part.",
  parameters: Type.Object({
    article: Type.String({ description: "Article stem (underscored filename, no .md, e.g. \"Archie_Project\")." }),
  }),
  execute: async (_id, params) => {
    const article = params.article.trim();
    if (!article) return textResult("memory_toc needs an article name.");
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      if (isReferenceId(article)) return textResult("memory_toc is for personal-memory articles. Use reference_read for Reference/ documents.");
      const { content } = await readArticle(vaultRoot(), article);
      const toc = parseToc(content);
      if (toc.length === 0) return textResult(`${article} has no Markdown headings.`);
      return textResult(
        `Headings in ${article}:\n\n` +
          toc.map((h) => `${"  ".repeat(Math.max(0, h.depth - 1))}- ${h.title}  (#${h.anchor})`).join("\n"),
      );
    } catch (err) {
      return textResult(`${err instanceof Error ? err.message : String(err)} — try memory_search to find the right article name.`);
    }
  },
});

const memorySectionTool = defineTool({
  name: "memory_section",
  label: "Read Memory Section",
  description:
    "Read one section from a memory article by heading anchor. Use memory_toc or memory_search first to find anchors; this is cheaper than reading a long article in full.",
  parameters: Type.Object({
    article: Type.String({ description: "Article stem (underscored filename, no .md, e.g. \"Archie_Project\")." }),
    anchor: Type.String({ description: "Heading anchor, e.g. \"origin\" or \"current-design\"." }),
  }),
  execute: async (_id, params) => {
    const article = params.article.trim();
    const anchor = params.anchor.trim().replace(/^#/, "");
    if (!article) return textResult("memory_section needs an article name.");
    if (!anchor) return textResult("memory_section needs a heading anchor.");
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      if (isReferenceId(article)) return textResult("memory_section is for personal-memory articles. Use reference_read for Reference/ documents.");
      const { content } = await readArticle(vaultRoot(), article);
      const section = extractSection(content, anchor);
      if (!section) return textResult(`No section #${anchor} found in ${article}. Try memory_toc article=\"${article}\".`);
      return textResult(section);
    } catch (err) {
      return textResult(`${err instanceof Error ? err.message : String(err)} — try memory_search to find the right article name.`);
    }
  },
});

const memoryLinksTool = defineTool({
  name: "memory_links",
  label: "Memory Links",
  description:
    "Show resolved outgoing and incoming wikilinks for one memory article. Use when nearby concepts/backlinks might matter to the answer.",
  parameters: Type.Object({
    article: Type.String({ description: "Article stem (underscored filename, no .md, e.g. \"Archie_Project\")." }),
  }),
  execute: async (_id, params) => {
    const article = params.article.trim();
    if (!article) return textResult("memory_links needs an article name.");
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      if (isReferenceId(article)) return textResult("memory_links is for personal-memory articles; Reference/ documents do not participate in the personal-memory link graph.");
      const { outbound, inbound } = await getArticleLinks(vaultRoot(), article);
      const lines = [`Links for ${article}:`, "", "Outbound:"];
      lines.push(outbound.length ? outbound.map((s) => `- ${s}`).join("\n") : "- (none)");
      lines.push("", "Inbound:");
      lines.push(inbound.length ? inbound.map((s) => `- ${s}`).join("\n") : "- (none)");
      return textResult(lines.join("\n"));
    } catch (err) {
      return textResult(`${err instanceof Error ? err.message : String(err)} — try memory_search to find the right article name.`);
    }
  },
});

const memoryListTool = defineTool({
  name: "memory_list",
  label: "List Memory",
  description:
    "List the titles of the user's personal-memory articles. Use as an overview, or as a fallback when memory_search doesn't surface what you expected.",
  parameters: Type.Object({}),
  execute: async () => {
    try {
      const unavailable = await memoryUnavailableMessage();
      if (unavailable) return textResult(unavailable);
      const articles = await listArticles(vaultRoot());
      if (articles.length === 0) return textResult("The user's memory has no personal articles yet.");
      return textResult(
        `${articles.length} personal-memory article(s):\n\n` +
          articles.map((s) => `- ${s}`).join("\n"),
      );
    } catch (err) {
      return textResult(`memory_list failed: ${err instanceof Error ? err.message : String(err)}`);
    }
  },
});

const memoryStatusTool = defineTool({
  name: "memory_status",
  label: "Memory Status",
  description:
    "Show read-only status for the user's memory: vault path, setup state, article count, git state, and nightly schedule state. Use when the user asks whether memory is on or where it lives.",
  parameters: Type.Object({}),
  execute: async () => {
    try {
      const st = await vaultStatus();
      const sched = await scheduleStatus();
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
        `- last synthesis: not available yet (M1 synthesis is stubbed)`,
        `- synthesis: M1 stub (manual/nightly writes are not implemented yet)`,
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
    memorySearchTool,
    memoryReadTool,
    memoryTocTool,
    memorySectionTool,
    memoryLinksTool,
    memoryListTool,
    memoryStatusTool,
  ];
}

export function createReferenceTools(): ToolDefinition[] {
  return [referenceSearchTool, referenceReadTool, referenceListTool];
}

/**
 * One gated line for the system prompt: states that memory is ON for this user
 * and points at the `memory` skill. NOT a title dump and NOT a how-to. pi
 * already auto-injects every skill's name+description+location
 * (formatSkillsForPrompt) and loads the SKILL.md body on demand, so the skill
 * owns the detailed workflow. This hint is intentionally soft: memory is a
 * scoped retrieval capability for user-specific continuity, not a default first
 * step for every prompt. Returns "" when memory is not turned on (vault absent)
 * so we never advertise memory the user hasn't enabled. Runs once at session
 * construction.
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
    `\n\nThe user's personal memory is on (${articleCount}${refCount}). Use it only when the answer depends on ` +
    `user-specific continuity or missing personal context; do not use it for weather, current public facts, ` +
    `generic web research, or ordinary coding/file tasks when the current files are enough. See the \`memory\` skill for the memory_* workflow.`
  );
}
