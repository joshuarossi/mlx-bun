// mlx-bun memory — reindex the derived cache from the markdown vault.
//
// The vault is truth; the DB's derived tables are a cache. `reindex` rebuilds
// them to MATCH the markdown — never the reverse. It drops and rebuilds exactly
// six tables purely from the article files via the P0-T2 parser:
//
//   entities · entity_aliases · categories · article_categories ·
//   infobox_facts · links
//
// Pipeline-state tables (messages, chunks, chunk_*, synthesized_*, watermarks,
// buckets) are the synthesis ledger and are left UNTOUCHED. Foreign keys are
// disabled across the rebuild so deleting+recreating `entities` does not cascade
// into the pipeline's `chunk_entities` rows (which reference entities ON DELETE
// CASCADE) — those are ledger state, not derivable from the vault.
//
// Determinism is a contract: reindexing the same vault into a fresh DB twice
// yields byte-identical derived tables (articles are visited in sorted-stem
// order; rows are inserted deterministically). See P2-T2.

import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

import {
  deriveCategories,
  infoboxFieldValues,
  parseInfobox,
  parseSeriesBanner,
  type InfoboxField,
} from "./article";
import type { MemoryStore } from "./db";
import { listRedirects } from "./redirect";
import { EntityResolver, nearNameMatch } from "./resolve";
import { articlesDir, resolveWikilinkToStem, vaultRoot } from "./vault";

// ---- normalization helpers -------------------------------------------

/** Casefold + collapse whitespace/underscores so title, stem, and alias forms
 *  of the same surface text key the entity index identically. */
function normalizeAlias(s: string): string {
  return s.trim().toLowerCase().replace(/_/g, " ").replace(/\s+/g, " ").trim();
}

const WIKILINK_RE = /\[\[([^\]]+)\]\]/;
const DATE_RE = /^\d{4}-\d{2}(-\d{2})?$/;
const MAIN_BANNER_RES = [
  /\{\{\s*Main\s*\|\s*([^}]+)\}\}/i, // {{Main|Target}}
  /^\*?\s*Main article:\s*\[\[([^\]]+)\]\]\s*\.?\*?$/i, // *Main article: [[Target]]*
];

/** The inner target of a `[[wikilink]]` value, before any `|alias`/`#anchor`. */
function wikilinkInner(value: string): string {
  const m = WIKILINK_RE.exec(value);
  if (!m) return "";
  return m[1]!.split("|")[0]!.split("#")[0]!.trim();
}

/** Resolve a wikilink target to an existing article stem, else its underscored
 *  form (a not-yet-written "red link" still carries a stable graph key). */
function linkStem(target: string, stems: Set<string>): string {
  const base = target.split("|")[0]!.split("#")[0]!.trim();
  return resolveWikilinkToStem(base, stems) ?? base.replace(/\s+/g, "_");
}

function elementKind(value: string): string {
  if (WIKILINK_RE.test(value)) return "entity-link";
  if (DATE_RE.test(value.trim())) return "date";
  return "scalar";
}

// ---- result ----------------------------------------------------------

export interface ReindexResult {
  articles: number;
  entities: number;
  aliases: number;
  categories: number;
  articleCategories: number;
  facts: number;
  links: number;
}

// ---- the rebuild ------------------------------------------------------

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

/**
 * Rebuild the derived cache from the markdown vault. Idempotent and
 * deterministic: same vault → byte-identical derived tables.
 */
export function reindex(store: MemoryStore, root: string = vaultRoot()): ReindexResult {
  const db = store.db;
  const stems = listArticleStems(root);
  const stemSet = new Set(stems);

  const result: ReindexResult = {
    articles: stems.length,
    entities: 0,
    aliases: 0,
    categories: 0,
    articleCategories: 0,
    facts: 0,
    links: 0,
  };

  // FK off so dropping `entities` does not cascade into the pipeline ledger
  // (`chunk_entities`). PRAGMA cannot change inside a transaction, so set it
  // around the transactional rebuild.
  // Sub-concept redirect edges (fold/capture) projected into entity_aliases below,
  // so a discussed subject resolves to its home article. Read before the rebuild
  // transaction; an older DB without the table yields none.
  let redirects: { surface: string; target_stem: string }[] = [];
  try {
    redirects = listRedirects(store);
  } catch {
    redirects = [];
  }

  db.exec("PRAGMA foreign_keys = OFF");
  try {
    db.transaction(() => {
      // Drop the six derived tables (children first for clarity).
      db.exec("DELETE FROM links");
      db.exec("DELETE FROM infobox_facts");
      db.exec("DELETE FROM article_categories");
      db.exec("DELETE FROM categories");
      db.exec("DELETE FROM entity_aliases");
      db.exec("DELETE FROM entities");

      const insEntity = db.query(
        "INSERT OR IGNORE INTO entities (name, article_stem, kind, notable) VALUES (?, ?, ?, 0)",
      );
      const insAlias = db.query("INSERT OR IGNORE INTO entity_aliases (alias, entity_name) VALUES (?, ?)");
      const insCategory = db.query("INSERT OR IGNORE INTO categories (name) VALUES (?)");
      const insArtCat = db.query(
        "INSERT OR IGNORE INTO article_categories (article_stem, category, source) VALUES (?, ?, ?)",
      );
      const insFact = db.query(
        "INSERT OR IGNORE INTO infobox_facts (article_stem, key, value, kind, entity_link) VALUES (?, ?, ?, ?, ?)",
      );
      const insLink = db.query("INSERT OR IGNORE INTO links (src_stem, dst_stem, via) VALUES (?, ?, ?)");

      const addLink = (dst: string, via: string, src: string): void => {
        if (!dst || dst === src) return;
        const r = insLink.run(src, dst, via);
        if (r.changes) result.links++;
      };
      const addAlias = (raw: string, entity: string): void => {
        const a = normalizeAlias(raw);
        if (!a) return;
        const r = insAlias.run(a, entity);
        if (r.changes) result.aliases++;
      };

      for (const stem of stems) {
        let content: string;
        try {
          content = readFileSync(join(articlesDir(root), `${stem}.md`), "utf8");
        } catch {
          continue;
        }
        const box = parseInfobox(content);

        // entities: one row per article; kind from the explicit infobox kind:.
        const kind = box ? box.entityKind : "thing";
        if (insEntity.run(stem, stem, kind).changes) result.entities++;

        // entity_aliases: title (stem→spaces) + the stem itself + infobox aliases.
        addAlias(stem, stem);
        addAlias(stem.replace(/_/g, " "), stem);
        if (box) {
          const aliasField = box.fields.find((f) => f.key === "aliases");
          if (aliasField) for (const a of infoboxFieldValues(aliasField)) addAlias(a, stem);
        }

        // categories + article_categories: from explicit [[Category:…]] declarations.
        const derived = deriveCategories(content, stem);
        for (const cat of derived.categories) {
          if (insCategory.run(cat).changes) result.categories++;
        }
        for (const row of derived.categoryRows) {
          if (insArtCat.run(row.article_stem, row.category, row.source).changes) result.articleCategories++;
        }

        // infobox_facts: one row per (split) field value, with element kind +
        // resolved entity_link; infobox entity-values also feed the link graph.
        if (box) {
          for (const field of box.fields) emitFieldFacts(field, stem, stemSet, insFact, addLink, result);
        }

        // links: prose [[links]] (See-also tagged distinctly), series + main banners.
        emitProseLinks(content, stem, stemSet, addLink);
        const series = parseSeriesBanner(content);
        if (series) addLink(linkStem(series, stemSet), "series", stem);
      }

      // Project the sub-concept redirect ledger into entity_aliases: a fold/capture
      // surface becomes an alias of its home article (only when that article still
      // exists), so resolveName reaches it. Articles are truth — a redirect never
      // overrides a real alias (INSERT OR IGNORE keeps the first writer).
      for (const r of redirects) {
        if (stemSet.has(r.target_stem)) addAlias(r.surface, r.target_stem);
      }
    })();
  } finally {
    db.exec("PRAGMA foreign_keys = ON");
  }

  return result;
}

function emitFieldFacts(
  field: InfoboxField,
  stem: string,
  stems: Set<string>,
  insFact: ReturnType<MemoryStore["db"]["query"]>,
  addLink: (dst: string, via: string, src: string) => void,
  result: ReindexResult,
): void {
  for (const value of infoboxFieldValues(field)) {
    const isLink = WIKILINK_RE.test(value);
    const entityLink = isLink ? linkStem(wikilinkInner(value), stems) : null;
    const r = insFact.run(stem, field.key, value, elementKind(value), entityLink);
    if (r.changes) result.facts++;
    if (isLink && entityLink) addLink(entityLink, "infobox", stem);
  }
}

function emitProseLinks(
  content: string,
  stem: string,
  stems: Set<string>,
  addLink: (dst: string, via: string, src: string) => void,
): void {
  const lines = content.split(/\r?\n/);
  const inner = /\[\[([^\]]+)\]\]/g;
  let inFence = false;
  let section: string | null = null;
  for (const rawLine of lines) {
    const line = rawLine;
    if (/^```/.test(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const t = line.trim();

    const hm = /^(#{1,6})\s+(.+)$/.exec(line);
    if (hm) {
      section = hm[1]!.length >= 2 ? hm[2]!.trim().toLowerCase() : section;
      continue;
    }
    if (/^\*Part of a series on \[\[/.test(t)) continue; // series banner: tagged elsewhere
    if (/^categories:/i.test(t)) continue; // category declaration: not a graph edge

    // {{Main}} / *Main article: [[X]]* — a parent→child split edge.
    let mainHit = false;
    for (const re of MAIN_BANNER_RES) {
      const m = re.exec(t);
      if (m) {
        addLink(linkStem(m[1]!.trim(), stems), "main", stem);
        mainHit = true;
        break;
      }
    }
    if (mainHit) continue;

    const via = section === "see also" ? "seealso" : "prose";
    inner.lastIndex = 0;
    let m: RegExpExecArray | null;
    while ((m = inner.exec(line)) !== null) {
      const base = m[1]!.split("|")[0]!.split("#")[0]!.trim();
      if (!base || /^conv:/i.test(base) || /^Category:/i.test(base)) continue;
      addLink(linkStem(base, stems), via, stem);
    }
  }
}

// ---- name resolution -------------------------------------------------

const LEADING_ARTICLE_RE = /^(?:the|a|an)\s+/;

/**
 * Resolve an entity name or alias to its article stem via `entity_aliases`.
 * Normalizes the query the same way aliases are stored (casefold, ws-collapse)
 * and also tries with a leading article word ("the"/"a"/"an") stripped, so
 * a "<the brand model>" surface and a "<model>" short form both reach the same stem.
 */
export function resolveName(store: MemoryStore, nameOrAlias: string): string | null {
  const q = normalizeAlias(nameOrAlias);
  const candidates = [q, q.replace(LEADING_ARTICLE_RE, "")];
  const stmt = store.db.query("SELECT entity_name FROM entity_aliases WHERE alias = ? LIMIT 1");
  for (const c of candidates) {
    if (!c) continue;
    const row = stmt.get(c) as { entity_name: string } | null;
    if (row) return row.entity_name;
  }
  // NEAR-NAME fallback: a discussed sub-concept that is plainly the same subject
  // as an existing entity — the title minus a generic suffix ("<subject>" for a
  // "<subject> Theory") — resolves via the conservative token-subset fuzzy. A
  // distinct subject or a purely-generic query does not. No model, no embedding.
  return nearNameMatch(EntityResolver.fromStore(store), q);
}

// ---- category lookup -------------------------------------------------

/** Article stems that DECLARED `[[Category:<category>]]` — the only "about X"
 *  mechanism (zero substring false positives). */
export function articlesInCategory(store: MemoryStore, category: string): string[] {
  const rows = store.db
    .query("SELECT article_stem FROM article_categories WHERE category = ? ORDER BY article_stem")
    .all(category) as { article_stem: string }[];
  return rows.map((r) => r.article_stem);
}
