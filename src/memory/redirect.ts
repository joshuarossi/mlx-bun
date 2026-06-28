// mlx-bun memory — SUB-CONCEPT REDIRECTS ("you already know what I'm talking about").
//
// A subject the user discussed should always RESOLVE, even when it never earned
// its own article: it FOLDED into a broader article (routed/disambiguated to an
// existing home) or it was CAPTURED (kept in its chunk, not yet articled). Either
// way we record a redirect edge — a `(surface → home article stem)` row in the
// `subject_redirects` ledger — so the surface resolves to its home instead of a
// bare NOT FOUND.
//
// `subject_redirects` is LEDGER state (like buckets / chunk_entities): it is NOT
// reconstructable from the vault, so reindex never deletes it. Instead reindex
// PROJECTS each edge whose target article still exists into the derived
// `entity_aliases` table, so `resolveName` finds the surface → its home article
// with no extra lookup path. Registration is idempotent (INSERT OR IGNORE on the
// (surface, target_stem) PK); a fold and a later capture of the same surface both
// just point at the same home.

import type { MemoryStore } from "./db";

/** How a sub-concept reached its home article: it FOLDED into a broader existing
 *  article, or it was CAPTURED (no own article yet) and points at its most-related
 *  article. Informational only — both resolve identically. */
export type RedirectKind = "fold" | "capture";

export interface RedirectRow {
  surface: string;
  target_stem: string;
  kind: RedirectKind;
}

/**
 * Register a `surface → target_stem` redirect (idempotent). Returns true when a
 * new edge was written. A blank surface, a self-pointing redirect (surface ==
 * stem title), or a blank target is ignored.
 */
export function registerRedirect(
  store: MemoryStore,
  surface: string,
  targetStem: string,
  kind: RedirectKind,
): boolean {
  const s = surface.trim();
  const t = targetStem.trim();
  if (!s || !t) return false;
  if (s === t || s === t.replace(/_/g, " ")) return false; // surface IS the title
  const r = store.db
    .query("INSERT OR IGNORE INTO subject_redirects (surface, target_stem, kind) VALUES (?, ?, ?)")
    .run(s, t, kind);
  return r.changes > 0;
}

/** Every redirect edge (sorted) — the reindex projection input. */
export function listRedirects(store: MemoryStore): RedirectRow[] {
  return store.db
    .query("SELECT surface, target_stem, kind FROM subject_redirects ORDER BY surface, target_stem")
    .all() as RedirectRow[];
}

/**
 * The article a CAPTURED subject most relates to: the article-homed entity that
 * co-occurs with it in the most chunks (deterministic — ties break by name). This
 * is the "surface it via its neighbourhood" signal a captured subject points at,
 * so it resolves to the article it was discussed alongside rather than NOT FOUND.
 * Returns the related entity's `article_stem`, or null when it co-occurs with no
 * homed article (the read path then falls back to memory_search over its chunk).
 * `chunkSet`, when given, restricts co-occurrence to a run's chunks.
 */
export function relatedArticleStem(
  store: MemoryStore,
  entity: string,
  chunkSet?: Set<string>,
): string | null {
  const rows = store.db
    .query(
      "SELECT e.article_stem AS stem, COUNT(*) AS c FROM chunk_entities ce1 " +
        "JOIN chunk_entities ce2 ON ce2.chunk_id = ce1.chunk_id " +
        "JOIN entities e ON e.name = ce2.entity_name " +
        "WHERE ce1.entity_name = ? AND ce2.entity_name <> ? " +
        "AND e.article_stem IS NOT NULL AND e.notable = 1 " +
        "GROUP BY ce2.entity_name ORDER BY c DESC, ce2.entity_name ASC",
    )
    .all(entity, entity) as { stem: string; c: number }[];
  if (!chunkSet) return rows[0]?.stem ?? null;
  // Re-score within the run's chunk set when one is given.
  const scored = new Map<string, number>();
  const co = store.db
    .query(
      "SELECT ce1.chunk_id AS chunk_id, e.article_stem AS stem FROM chunk_entities ce1 " +
        "JOIN chunk_entities ce2 ON ce2.chunk_id = ce1.chunk_id " +
        "JOIN entities e ON e.name = ce2.entity_name " +
        "WHERE ce1.entity_name = ? AND ce2.entity_name <> ? " +
        "AND e.article_stem IS NOT NULL AND e.notable = 1",
    )
    .all(entity, entity) as { chunk_id: string; stem: string }[];
  for (const r of co) {
    if (!chunkSet.has(r.chunk_id)) continue;
    scored.set(r.stem, (scored.get(r.stem) ?? 0) + 1);
  }
  let best: string | null = null;
  let bestC = 0;
  for (const [stem, c] of [...scored].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))) {
    if (c > bestC) {
      best = stem;
      bestC = c;
    }
  }
  return best;
}
