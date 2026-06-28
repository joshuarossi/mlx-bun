// mlx-bun memory — ENTITY-EXTRACT (P5-T3).
//
// Reads ONE chunk's reassembled TEXT and asks the local model "what things is
// this chunk about?", returning canonical wiki-title entity names — the specific
// things AND the broad domain. This is the REAL routing-thesis test: unlike the
// P4 label-proxy (which routed on the 4–10-word episodic chunk label), this
// stage reads the full conversation text, so it sees the entities the label
// merely gestures at.
//
// Design (P5-T3):
//   - ONE chunk per call (NO multi-item JSON, NO batch indices — that
//     batch-index drift is what sank Lucien's batched assign). Output is a plain
//     newline list parsed by parseLines.
//   - `Entities.md` policy (the five kinds, notability checklist, naming rules,
//     emit-both-granularities) is inlined into the prompt via loadMetaPolicy, so
//     editing the vault page re-tunes extraction with no code change.
//   - Deterministic canonicalization (casefold, ws-collapse, strip leading
//     articles/possessives) so a name's spacing/short-form/brand-only variants
//     collapse to one stem. The canonical stem feeds dedup + the entity_aliases index.
//   - Persists chunk_entities(chunk_id, entity_name, surface_form) and upserts a
//     candidate entities row (article_stem NULL — no article exists yet) so the
//     FK on chunk_entities.entity_name is satisfied; the raw model surface is
//     stored as an alias of the canonical name.
//
// The base model + policy runs until a `memory-entity` LoRA is trained (P10-T3),
// which only happens on a measured recall miss here.

import type { MemoryStore } from "./db";
import { callLocal } from "./model";
import { parseLines } from "./parse";
import { loadMetaPolicy } from "./prompts";
import { EntityResolver, goldSeeds } from "./resolve";

/** Model-call seam for extraction (defaults to the local `entity` stage). Injected
 *  by the pipeline + tests so the deterministic scaffolding runs with no GPU. */
export type ExtractCall = (prompt: string, opts?: { maxTokens?: number }) => Promise<string>;

/** One extracted entity: the canonical wiki-title name + the raw model surface. */
export interface ExtractedEntity {
  /** Canonical wiki-title name (the model's line, cleaned of markup/trailing
   *  punctuation) — the value written to chunk_entities.entity_name. */
  name: string;
  /** The raw surface the model emitted (chunk_entities.surface_form). */
  surface: string;
  /** Deterministic canonical stem (casefold/ws-collapse/strip articles+
   *  possessives) used for dedup and alias keying. */
  stem: string;
}

const QUESTION =
  "What things is this chunk about? List canonical wiki-title names, one per " +
  "line; include specific things AND the broad domain. Output NONE if nothing " +
  "nameable or substantive.";

/**
 * Deterministic canonical stem of an entity surface: casefold, collapse
 * whitespace/underscores, strip surrounding markdown/quotes, drop a trailing
 * period, then strip ONE leading article (the/a/an) and ONE leading possessive
 * determiner (my/your/his/her/its/our/their), plus a trailing possessive `'s`.
 *
 * This is the dedup key: a name's spacing variants, short forms, brand-only
 * surfaces, and possessive surfaces all collapse toward one stem so variants of
 * the same thing unify.
 */
export function canonicalize(surface: string): string {
  let t = surface
    .toLowerCase()
    .replace(/[*_`"'“”]+/g, " ") // strip md emphasis / quotes
    .replace(/[_\s]+/g, " ")
    .trim()
    .replace(/[.,;:]+$/, "")
    .trim();
  // strip a leading list marker / numbering the model may emit ("- ", "1. ")
  t = t.replace(/^(?:[-*•]\s+|\d+[.)]\s+)/, "").trim();
  // strip ONE leading article, then ONE leading possessive determiner
  t = t.replace(/^(?:the|a|an)\s+/, "").trim();
  t = t.replace(/^(?:my|your|his|her|its|our|their)\s+/, "").trim();
  // strip a trailing saxon-genitive
  t = t.replace(/['’]s$/, "").trim();
  return t;
}

/** Clean a raw model line into a stored canonical NAME (preserve casing/words,
 *  just strip surrounding markup, list markers, and trailing punctuation). */
function cleanName(line: string): string {
  return line
    .replace(/^(?:[-*•]\s+|\d+[.)]\s+)/, "")
    .replace(/^[*_`"“]+|[*_`"”]+$/g, "")
    .replace(/[.,;:]+$/, "")
    .trim();
}

/**
 * Build the entity-extraction prompt: inlined `Entities.md` policy + the chunk
 * text + the fixed question. The policy block is passed in so callers can cache
 * it across many chunks (loadMetaPolicy does disk IO).
 */
export function buildEntityPrompt(text: string, policy: string): string {
  return (
    `${policy}\n\n` +
    `--- Conversation chunk ---\n${text}\n--- end chunk ---\n\n` +
    QUESTION
  );
}

/**
 * Core extraction: render the prompt, call the base model (maxTokens 128), parse
 * the newline list, clean + canonicalize each surface, and de-duplicate by stem.
 * Pure w.r.t. the DB. Returns the extracted entities AND the raw newline-line
 * count (pre-dedup) so instruments can report the canonicalizer's parse health.
 */
export async function extractEntityNamesRaw(
  text: string,
  policy?: string,
  opts?: { maxTokens?: number; call?: ExtractCall },
): Promise<{ entities: ExtractedEntity[]; rawLines: number }> {
  if (!text.trim()) return { entities: [], rawLines: 0 };
  const pol = policy ?? loadMetaPolicy(["Entities"]);
  const prompt = buildEntityPrompt(text, pol);
  const call: ExtractCall = opts?.call ?? ((p, o) => callLocal("entity", { user: p }, o));
  const out = await call(prompt, { maxTokens: opts?.maxTokens ?? 128 });
  const lines = parseLines(out);
  const seen = new Set<string>();
  const entities: ExtractedEntity[] = [];
  for (const raw of lines) {
    const surface = cleanName(raw);
    const stem = canonicalize(surface);
    if (!stem || !surface) continue;
    if (seen.has(stem)) continue; // collapse variants of one thing
    seen.add(stem);
    entities.push({ name: surface, surface: raw.trim(), stem });
  }
  return { entities, rawLines: lines.length };
}

/** Convenience wrapper: just the extracted entities (no raw-line count). */
export async function extractEntityNames(
  text: string,
  policy?: string,
  opts?: { maxTokens?: number; call?: ExtractCall },
): Promise<ExtractedEntity[]> {
  return (await extractEntityNamesRaw(text, policy, opts)).entities;
}

/**
 * Full stage: extract the entities a chunk is about and PERSIST them.
 *
 * Each extracted surface is RESOLVED to a canonical entity through the variant
 * resolver (squeeze/alias/token-subset; see resolve.ts) so casing/spacing/brand
 * variants collapse onto ONE entity instead of minting a fresh row each — the
 * dedup fix. The resolver is seeded from the store's existing entities/aliases
 * AND the curated gold (so notable brand-only nicknames fold), and accumulates
 * minted canonicals across chunks when the caller threads one in via `opts`.
 *
 * Upserts the resolved canonical `entities` row (article_stem NULL — no article
 * exists yet; ROUTE/CREATE promote it later) so the chunk_entities FK is
 * satisfied, records the raw surface as an alias of the canonical, and writes one
 * chunk_entities row per distinct resolved entity. Idempotent: re-running on the
 * same chunk INSERT-OR-IGNOREs the same rows.
 *
 * Returns the extracted list (also useful to callers that route immediately).
 */
export async function extractEntities(
  store: MemoryStore,
  chunkId: string,
  opts?: { maxTokens?: number; policy?: string; resolver?: EntityResolver; call?: ExtractCall },
): Promise<ExtractedEntity[]> {
  const text = store.chunkText(chunkId);
  const extracted = await extractEntityNames(text, opts?.policy, opts);

  // Seed once from the store + gold unless the caller threads a shared resolver
  // (which lets minted canonicals carry across chunks in a single run).
  const resolver = opts?.resolver ?? EntityResolver.fromStore(store);
  if (!opts?.resolver) for (const s of goldSeeds()) resolver.register(s.canonical, s.aliases);

  const insEntity = store.db.query(
    "INSERT OR IGNORE INTO entities (name, article_stem, kind, notable) VALUES (?, NULL, NULL, 0)",
  );
  const insAlias = store.db.query(
    "INSERT OR IGNORE INTO entity_aliases (alias, entity_name) VALUES (?, ?)",
  );
  const insChunkEntity = store.db.query(
    "INSERT OR IGNORE INTO chunk_entities (chunk_id, entity_name, surface_form) VALUES (?, ?, ?)",
  );

  // Resolve OUTSIDE the write tx (the resolver index is in-memory, no DB writes),
  // collapsing within-chunk variants onto one canonical before persisting.
  const resolved = new Map<string, string>(); // canonical → first raw surface seen
  for (const e of extracted) {
    const canonical = resolver.resolve(e.name).name;
    if (!resolved.has(canonical)) resolved.set(canonical, e.surface);
  }

  const tx = store.db.transaction(() => {
    for (const [canonical, surface] of resolved) {
      insEntity.run(canonical);
      insAlias.run(canonicalize(surface), canonical);
      insChunkEntity.run(chunkId, canonical, surface);
    }
  });
  tx();
  return extracted;
}
