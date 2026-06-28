// mlx-bun memory — the read-side navigation index + primitives.
//
// The read path FINDS an article deterministically — by category membership, by
// name/alias, or by following the [[wikilink]] graph — then hands the agent off
// to the read tools (TOC → section). It NEVER ranks by a vector and NEVER filters
// on an infobox field: the infobox is CONTENT the model reads, not a query
// target. There is deliberately no `byInfoboxField`, no numeric facet, no
// `gte/lte` here. Every lookup below touches only indexed names/categories/links;
// the embedding tripwire (src/embed.ts) MUST stay at zero across this module.
//
// `buildMemoryIndex` mirrors the same facts the reindex derives into the DB
// (aliases, categories, series, kind/type, infobox, lead, link graph) into plain
// in-memory maps, so the primitives are pure functions over a snapshot with no
// DB round-trip. The build is mtime-incremental: each file is parsed at most once
// per (path, mtime), so a rebuild after touching one article re-parses only that
// file and is otherwise byte-identical to the prior build.

import { readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";

import {
  deriveCategories,
  infoboxAliases,
  infoboxFieldValues,
  parseInfobox,
  parseLead,
  parseSeriesBanner,
  type EntityKind,
  type Infobox,
} from "./article";
import { EntityResolver, nearNameMatch } from "./resolve";
import { articlesDir, extractWikilinkTargets, resolveWikilinkToStem, vaultRoot } from "./vault";

// ---- normalization (mirrors reindex.ts so resolveName agrees exactly) -

/** Casefold + collapse whitespace/underscores so title, stem, and alias forms of
 *  the same surface text key the alias index identically. */
function normalizeAlias(s: string): string {
  return s.trim().toLowerCase().replace(/_/g, " ").replace(/\s+/g, " ").trim();
}

const LEADING_ARTICLE_RE = /^(?:the|a|an)\s+/;
const WIKILINK_RE = /\[\[([^\]]+)\]\]/;

/** The inner target of a `[[wikilink]]` value, before any `|alias`/`#anchor`. */
function wikilinkInner(value: string): string {
  const m = WIKILINK_RE.exec(value);
  if (!m) return "";
  return m[1]!.split("|")[0]!.split("#")[0]!.trim();
}

// ---- per-article parse + the index ------------------------------------

/** One article's structured facts, parsed once and cached by (path, mtime). */
interface IndexedArticle {
  stem: string;
  infobox: Infobox | null;
  lead: string | null;
  categories: string[];
  series: string | null;
  kind: EntityKind;
  type: string | null;
  /** Normalized alias surfaces (stem, spaced stem, infobox aliases). */
  aliases: string[];
  /** Resolved outbound link targets (existing article stems only, deduped). */
  outbound: string[];
}

export interface MemoryIndex {
  root: string;
  /** normalized alias → stem (first writer in sorted-stem order wins). */
  aliasToStem: Map<string, string>;
  /** category name → member stems (sorted). */
  categoryToStems: Map<string, string[]>;
  /** series name → member stems (sorted). */
  seriesToStems: Map<string, string[]>;
  /** entity kind → stems (sorted). */
  kindToStems: Map<string, string[]>;
  /** emergent `type:` label → stems (sorted). */
  typeToStems: Map<string, string[]>;
  /** stem → parsed infobox (null when the article has none). */
  infoboxByStem: Map<string, Infobox | null>;
  /** stem → lead abstract (null when absent). */
  leadByStem: Map<string, string | null>;
  /** stem → resolved outbound article stems (the link graph). */
  outboundByStem: Map<string, string[]>;
  /** Stems (re)parsed on the most recent build (mtime miss). */
  parsed: string[];
  /** Stems served from the parse cache on the most recent build (mtime hit). */
  reused: string[];
}

interface CacheEntry {
  mtimeMs: number;
  article: IndexedArticle;
}

/** Module-level parse cache keyed by absolute file path. Memoizes per-file
 *  PARSING only (keyed by mtime); the aggregate maps are rebuilt every call so
 *  they always reflect the current file set. */
const ARTICLE_CACHE = new Map<string, CacheEntry>();

/** Drop the parse cache. A cold rebuild after this yields maps byte-identical to
 *  a warm one (the cache is a pure speedup, never a source of truth). */
export function resetMemoryIndexCache(): void {
  ARTICLE_CACHE.clear();
}

/** Sorted article stems under `<root>/articles/` (`*.md`, no hidden files). */
function listArticleStems(root: string): string[] {
  let names: string[];
  try {
    names = readdirSync(articlesDir(root));
  } catch {
    return [];
  }
  return names
    .filter((n) => n.endsWith(".md") && !n.startsWith("."))
    .map((n) => n.slice(0, -3))
    .sort((a, b) => a.localeCompare(b));
}

/** Parse one article's markdown into its indexed facts (no I/O). */
function parseArticle(stem: string, md: string, stems: Set<string>): IndexedArticle {
  const box = parseInfobox(md);

  const aliasSet = new Set<string>();
  for (const a of [stem, stem.replace(/_/g, " "), ...(box ? infoboxAliases(box) : [])]) {
    const norm = normalizeAlias(a);
    if (norm) aliasSet.add(norm);
  }

  // Outbound graph edges: prose [[links]] + infobox entity-link values + series
  // banner, each resolved to an EXISTING article stem (red links are dropped,
  // matching getArticleLinks). Self-edges excluded.
  const outbound = new Set<string>();
  const addEdge = (raw: string): void => {
    const r = resolveWikilinkToStem(raw, stems);
    if (r && r !== stem) outbound.add(r);
  };
  for (const t of extractWikilinkTargets(md)) addEdge(t);
  if (box) {
    for (const field of box.fields) {
      for (const value of infoboxFieldValues(field)) {
        if (WIKILINK_RE.test(value)) addEdge(wikilinkInner(value));
      }
    }
  }
  const series = parseSeriesBanner(md);
  if (series) addEdge(series);

  return {
    stem,
    infobox: box,
    lead: parseLead(md),
    categories: deriveCategories(md, stem).categories,
    series,
    kind: box ? box.entityKind : "thing",
    type: box ? box.type : null,
    aliases: [...aliasSet].sort((a, b) => a.localeCompare(b)),
    outbound: [...outbound].sort((a, b) => a.localeCompare(b)),
  };
}

/**
 * Build the read-side navigation index for a vault. mtime-incremental: each
 * article is parsed at most once per (path, mtime), so a rebuild after touching
 * one file re-parses ONLY that file. Deterministic: stems are visited in sorted
 * order and every map array is sorted, so two builds of the same vault produce
 * byte-identical maps. Makes ZERO embedding calls.
 */
export function buildMemoryIndex(root: string = vaultRoot()): MemoryIndex {
  const stems = listArticleStems(root);
  const stemSet = new Set(stems);
  const dir = articlesDir(root);

  const parsed: string[] = [];
  const reused: string[] = [];
  const articles: IndexedArticle[] = [];

  for (const stem of stems) {
    const path = join(dir, `${stem}.md`);
    let mtimeMs: number;
    try {
      mtimeMs = statSync(path).mtimeMs;
    } catch {
      continue; // raced/deleted between listing and stat
    }
    const cached = ARTICLE_CACHE.get(path);
    if (cached && cached.mtimeMs === mtimeMs) {
      reused.push(stem);
      articles.push(cached.article);
      continue;
    }
    let md: string;
    try {
      md = readFileSync(path, "utf8");
    } catch {
      continue;
    }
    const article = parseArticle(stem, md, stemSet);
    ARTICLE_CACHE.set(path, { mtimeMs, article });
    parsed.push(stem);
    articles.push(article);
  }

  const index: MemoryIndex = {
    root,
    aliasToStem: new Map(),
    categoryToStems: new Map(),
    seriesToStems: new Map(),
    kindToStems: new Map(),
    typeToStems: new Map(),
    infoboxByStem: new Map(),
    leadByStem: new Map(),
    outboundByStem: new Map(),
    parsed,
    reused,
  };

  const pushInto = (map: Map<string, string[]>, key: string, stem: string): void => {
    const list = map.get(key);
    if (list) list.push(stem);
    else map.set(key, [stem]);
  };

  for (const a of articles) {
    for (const alias of a.aliases) {
      if (!index.aliasToStem.has(alias)) index.aliasToStem.set(alias, a.stem); // first (sorted) writer wins
    }
    for (const cat of a.categories) pushInto(index.categoryToStems, cat, a.stem);
    if (a.series) pushInto(index.seriesToStems, a.series, a.stem);
    pushInto(index.kindToStems, a.kind, a.stem);
    if (a.type) pushInto(index.typeToStems, a.type, a.stem);
    index.infoboxByStem.set(a.stem, a.infobox);
    index.leadByStem.set(a.stem, a.lead);
    index.outboundByStem.set(a.stem, a.outbound);
  }

  return index;
}

// ---- navigation primitives (find + resolve + links) -------------------

/**
 * Article stems that DECLARED `[[Category:<category>]]` — the only "articles
 * about X" mechanism (zero substring false positives). Returns a sorted copy.
 */
export function articlesInCategory(index: MemoryIndex, category: string): string[] {
  return [...(index.categoryToStems.get(category) ?? [])];
}

/** Lazily-built near-name resolver per index (token-subset fuzzy over the alias
 *  map). Keyed by index identity; a fresh `buildMemoryIndex` yields a new object,
 *  so stale resolvers fall out of the WeakMap with their index. */
const NEAR_RESOLVER = new WeakMap<MemoryIndex, EntityResolver>();

function nearResolver(index: MemoryIndex): EntityResolver {
  let r = NEAR_RESOLVER.get(index);
  if (!r) {
    r = EntityResolver.fromAliasMap(index.aliasToStem);
    NEAR_RESOLVER.set(index, r);
  }
  return r;
}

/**
 * Resolve an entity name or alias to its article stem via the alias index.
 * Normalizes the query the same way aliases are stored (casefold, ws-collapse)
 * and also retries with a leading article word ("the"/"a"/"an") stripped, so
 * a "<the brand model>" surface and a "<model>" short form both reach the same stem.
 *
 * On an exact-alias miss, falls back to a conservative NEAR-NAME match
 * ({@link nearNameMatch}) so a discussed sub-concept that is plainly the same
 * subject as an existing article — the article title minus a generic suffix
 * ("<subject>" for an "<subject> Theory" article) — still resolves to it, while a
 * distinct subject or a purely-generic query does not. No model, no embedding.
 */
export function resolveName(index: MemoryIndex, nameOrAlias: string): string | null {
  const q = normalizeAlias(nameOrAlias);
  for (const c of [q, q.replace(LEADING_ARTICLE_RE, "")]) {
    if (!c) continue;
    const stem = index.aliasToStem.get(c);
    if (stem) return stem;
  }
  return nearNameMatch(nearResolver(index), q);
}

export interface Neighbors {
  outbound: string[];
  inbound: string[];
}

/**
 * The article's resolved [[wikilink]] neighbors: `outbound` it points at,
 * `inbound` that point at it — including infobox entity-link edges (e.g. an
 * entity's `<entity_key>: [[Linked Entity]]`), which is the navigation hop the read
 * path rides. Both lists are sorted; computed entirely from the in-memory graph.
 */
export function neighbors(index: MemoryIndex, stem: string): Neighbors {
  const outbound = [...(index.outboundByStem.get(stem) ?? [])];
  const inbound: string[] = [];
  for (const [from, targets] of index.outboundByStem) {
    if (from !== stem && targets.includes(stem)) inbound.push(from);
  }
  inbound.sort((a, b) => a.localeCompare(b));
  return { outbound, inbound };
}

// ---- deterministic snapshot (for tests / cache-equivalence checks) ----

/** A stable JSON serialization of the index maps (sorted keys), so a warm and a
 *  cold rebuild can be asserted byte-identical. Excludes the build accounting
 *  (`parsed`/`reused`), which is per-build by design. */
export function serializeMemoryIndex(index: MemoryIndex): string {
  const dumpStringMap = (m: Map<string, string>): [string, string][] =>
    [...m.entries()].sort((a, b) => a[0].localeCompare(b[0]));
  const dumpListMap = (m: Map<string, string[]>): [string, string[]][] =>
    [...m.entries()].sort((a, b) => a[0].localeCompare(b[0]));
  const dumpInfobox = (m: Map<string, Infobox | null>): [string, Infobox | null][] =>
    [...m.entries()].sort((a, b) => a[0].localeCompare(b[0]));
  const dumpLeadMap = (m: Map<string, string | null>): [string, string | null][] =>
    [...m.entries()].sort((a, b) => a[0].localeCompare(b[0]));
  return JSON.stringify({
    aliasToStem: dumpStringMap(index.aliasToStem),
    categoryToStems: dumpListMap(index.categoryToStems),
    seriesToStems: dumpListMap(index.seriesToStems),
    kindToStems: dumpListMap(index.kindToStems),
    typeToStems: dumpListMap(index.typeToStems),
    infoboxByStem: dumpInfobox(index.infoboxByStem),
    leadByStem: dumpLeadMap(index.leadByStem),
    outboundByStem: dumpListMap(index.outboundByStem),
  });
}
