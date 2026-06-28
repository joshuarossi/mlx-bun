// mlx-bun memory — surface-variant RESOLUTION (the dedup fix for P5-T3/T4).
//
// canonicalize() in entity.ts is a *pure string normal form*: casefold, collapse
// whitespace, strip articles/possessives. That is necessary but NOT sufficient —
// the self-check turned the spacing, brand-only, and possessive surfaces of ONE
// product name into several different stems:
//   - "<name>" vs "<na me>"  (internal spacing the normal form keeps)
//   - "<brand>" / "<brand> <model>"  (brand-only and compositional surfaces that
//     no purely-lexical normalizer can fold onto one canonical)
//
// The resolver adds three layers on top of canonicalize():
//   1. SQUEEZE — strip ALL non-alphanumerics so "<na me>" / "<name>" / "<nam e>"
//      collapse to one key deterministically (fixes the spacing split).
//   2. ALIAS SEED — a known-entity index (entities + entity_aliases in the store,
//      seeded from goldens/dreaming-entities-gold.json) so brand-only / nickname
//      surfaces (a "<the brand>", a "<the role>") resolve by exact alias hit.
//   3. TOKEN-SUBSET FUZZY — a conservative compositional match: a surface folds
//      onto an entity iff its content tokens are a SUBSET of that entity's tokens
//      AND the overlap carries at least one DISTINCTIVE token (a token unique to
//      that entity among all known entities). This merges "<my brand model>" → the
//      entity via the distinctive model token while REFUSING to merge
//      "<brand A>" into "<brand B>" (a shared brand token is not distinctive;
//      the model-number tokens differ) — the over-merge guard.
//
// Resolution is conservative by construction: when in doubt it MINTS a new
// canonical rather than fusing two distinct things. ROUTE (route.ts) escalates
// the genuine misses to the model for binary disambiguation.

import { readFileSync } from "node:fs";
import { join } from "node:path";

import { canonicalize } from "./entity";
import type { MemoryStore } from "./db";

/** Tokens that carry no disambiguating signal on their own (articles, glue, and
 *  generic gear nouns shared across many entities). Used only for the fuzzy
 *  token-subset layer — never for the exact alias index. */
const STOP = new Set([
  "the", "a", "an", "and", "or", "of", "to", "for", "in", "on", "with", "is",
  "as", "my", "your", "his", "her", "its", "our", "their",
]);

/** Strip ALL non-alphanumerics and casefold: the spacing/punct-insensitive key.
 *  A name's spacing and punctuation variants all collapse here. */
export function squeeze(surface: string): string {
  return surface.toLowerCase().replace(/[^a-z0-9]+/g, "");
}

/** Content tokens of a surface (casefold, split on non-alphanumerics, drop
 *  stopwords and single characters). Order-insensitive set. */
export function contentTokens(surface: string): Set<string> {
  const out = new Set<string>();
  for (const t of surface.toLowerCase().split(/[^a-z0-9]+/)) {
    if (t.length > 1 && !STOP.has(t)) out.add(t);
  }
  return out;
}

/** How a surface resolved (for instrumentation + the deterministic gates). */
export type MatchKind = "stem" | "squeeze" | "alias" | "fuzzy" | "new";

export interface ResolveResult {
  /** The canonical entity name the surface resolved to (or was minted as). */
  name: string;
  /** Which layer produced the resolution. "new" ⇒ a canonical was minted. */
  matched: MatchKind;
  /** True iff this call minted a NEW canonical (no existing entity matched). */
  created: boolean;
}

interface Seed {
  canonical: string;
  aliases: string[];
}

/**
 * In-memory variant resolver over a KNOWN-ENTITY set. Indexes each canonical by
 * its normal-form stem, its squeeze key, and its content tokens, then resolves a
 * surface through stem → squeeze → alias → token-subset-fuzzy, minting a new
 * canonical only when every layer misses.
 *
 * Construct from a seed list, from a {@link MemoryStore} (entities +
 * entity_aliases), or from the curated gold — and compose them (store first,
 * gold to backfill notable brand-only aliases).
 */
export class EntityResolver {
  /** normal-form stem → canonical. */
  private byStem = new Map<string, string>();
  /** squeeze key → canonical. */
  private bySqueeze = new Map<string, string>();
  /** canonical → union of content tokens across its name + aliases. */
  private tokensOf = new Map<string, Set<string>>();
  /** content token → set of canonicals carrying it (distinctiveness check). */
  private tokenOwners = new Map<string, Set<string>>();

  constructor(seeds: Seed[] = []) {
    for (const s of seeds) this.register(s.canonical, s.aliases);
  }

  /** All known canonical names (registration order is not guaranteed). */
  canonicals(): string[] {
    return [...this.tokensOf.keys()];
  }

  /** Is `name` an already-known canonical entity? */
  has(name: string): boolean {
    return this.tokensOf.has(name);
  }

  /** Register a canonical and its aliases into every index. Idempotent; adding
   *  aliases to an existing canonical merges them. The canonical's own surface is
   *  always indexed as an alias of itself. */
  register(canonical: string, aliases: string[] = []): void {
    if (!this.tokensOf.has(canonical)) this.tokensOf.set(canonical, new Set());
    const tokset = this.tokensOf.get(canonical)!;
    for (const surface of [canonical, ...aliases]) {
      const stem = canonicalize(surface);
      const sq = squeeze(surface);
      if (stem && !this.byStem.has(stem)) this.byStem.set(stem, canonical);
      if (sq && !this.bySqueeze.has(sq)) this.bySqueeze.set(sq, canonical);
      for (const t of contentTokens(surface)) {
        tokset.add(t);
        let owners = this.tokenOwners.get(t);
        if (!owners) this.tokenOwners.set(t, (owners = new Set()));
        owners.add(canonical);
      }
    }
  }

  /** A token is DISTINCTIVE iff exactly one known canonical carries it — the
   *  signal the fuzzy layer requires to merge a compositional surface. */
  private distinctive(token: string): string | null {
    const owners = this.tokenOwners.get(token);
    if (!owners || owners.size !== 1) return null;
    return [...owners][0]!;
  }

  /**
   * Conservative token-subset fuzzy match: the surface's content tokens must be a
   * non-empty SUBSET of some entity's tokens, and at least one of them must be
   * distinctive to that same entity. Returns the canonical, or null if no
   * unambiguous owner (zero or conflicting distinctive owners ⇒ refuse to merge).
   */
  private fuzzy(surface: string): string | null {
    const toks = contentTokens(surface);
    if (toks.size === 0) return null;
    // The distinctive tokens present in the surface, and who owns them.
    const owners = new Set<string>();
    for (const t of toks) {
      const owner = this.distinctive(t);
      if (owner) owners.add(owner);
    }
    if (owners.size !== 1) return null; // none, or a tie across entities → no merge
    const cand = [...owners][0]!;
    // Subset guard: every surface token must belong to the candidate, else the
    // surface names something MORE than (a variant of) the candidate.
    const ets = this.tokensOf.get(cand)!;
    for (const t of toks) if (!ets.has(t)) return null;
    return cand;
  }

  /** Resolve a surface to an EXISTING canonical, or null if every layer misses.
   *  Pure: never mutates the index. */
  match(surface: string): { name: string; matched: MatchKind } | null {
    const stem = canonicalize(surface);
    if (stem) {
      const byStem = this.byStem.get(stem);
      if (byStem) return { name: byStem, matched: "stem" };
    }
    const sq = squeeze(surface);
    if (sq) {
      const bySq = this.bySqueeze.get(sq);
      if (bySq) return { name: bySq, matched: "squeeze" };
    }
    const fz = this.fuzzy(surface);
    if (fz) return { name: fz, matched: "fuzzy" };
    return null;
  }

  /**
   * Resolve a surface, MINTING a new canonical when nothing matches. The minted
   * canonical is the cleaned surface; it is registered so later variants of the
   * same thing fold onto it. Brand-only nicknames still need a gold/store seed —
   * fuzzy cannot invent a "<the brand>" ≡ "<brand model>" link from lexis alone.
   */
  resolve(surface: string, mintName?: string): ResolveResult {
    const hit = this.match(surface);
    if (hit) return { name: hit.name, matched: hit.matched, created: false };
    const canonical = (mintName ?? surface).trim();
    this.register(canonical, surface === canonical ? [] : [surface]);
    return { name: canonical, matched: "new", created: true };
  }

  /** Register one canonical per stem with its alias surfaces, grouped from a
   *  normalized `alias → stem` map (the read-index's `aliasToStem`). The stem is
   *  the canonical; its surfaces become aliases. */
  static fromAliasMap(aliasToStem: Iterable<readonly [string, string]>): EntityResolver {
    const byStem = new Map<string, string[]>();
    for (const [alias, stem] of aliasToStem) {
      let list = byStem.get(stem);
      if (!list) byStem.set(stem, (list = []));
      list.push(alias);
    }
    const r = new EntityResolver();
    for (const [stem, aliases] of byStem) r.register(stem, aliases);
    return r;
  }

  /** Load the known-entity index from a store's entities + entity_aliases. */
  static fromStore(store: MemoryStore): EntityResolver {
    const r = new EntityResolver();
    const ents = store.db.query("SELECT name FROM entities").all() as { name: string }[];
    for (const e of ents) r.register(e.name, []);
    const aliases = store.db
      .query("SELECT alias, entity_name FROM entity_aliases")
      .all() as { alias: string; entity_name: string }[];
    for (const a of aliases) {
      if (!r.has(a.entity_name)) r.register(a.entity_name, [a.alias]);
      else r.register(a.entity_name, [a.alias]);
    }
    return r;
  }
}

// ---- near-name resolution (sub-concept → its home article) -----------------

/** Generic "kind-of-thing" suffix words a discussed sub-concept drops when it is
 *  the SAME subject as an existing article (a query that is the article title
 *  minus a generic tail — "<subject>" for "<subject> Theory"). They carry no
 *  disambiguating signal alone, so a query made ONLY of these never redirects. */
const GENERIC_SUFFIX = new Set([
  "theory", "framework", "system", "model", "method", "methodology", "approach",
  "principle", "principles", "technique", "concept", "paradigm", "effect", "law",
  "hypothesis", "problem", "process", "pattern", "practice",
]);

/**
 * NEAR-NAME match: resolve a surface to an EXISTING article when it is clearly the
 * SAME subject — the conservative token-subset fuzzy (a query whose content tokens
 * are a distinctive subset of an article's, e.g. the title minus a generic suffix).
 * Reuses {@link EntityResolver.match} (stem → squeeze → token-subset fuzzy) but
 * REFUSES a query made only of generic suffix words (just "Theory"/"Framework"),
 * which would over-merge onto an arbitrary article. Returns the canonical (== the
 * article stem the resolver was seeded with), or null. Pure.
 */
export function nearNameMatch(resolver: EntityResolver, surface: string): string | null {
  const toks = contentTokens(surface);
  if (toks.size === 0) return null;
  let hasContentToken = false;
  for (const t of toks) {
    if (!GENERIC_SUFFIX.has(t)) {
      hasContentToken = true;
      break;
    }
  }
  if (!hasContentToken) return null; // a purely-generic query must not redirect
  const hit = resolver.match(surface);
  return hit ? hit.name : null;
}

// ---- gold seed -------------------------------------------------------------

export interface VariantGroup {
  canonical: string;
  kind: string;
  domain: string;
  variants: string[];
}
export interface NotableEntity {
  name: string;
  kind: string;
  domain: string;
  aliases: string[];
  whyNotable: string;
}
export interface DreamingGold {
  variantGroups: VariantGroup[];
  notableEntities: NotableEntity[];
}

const GOLD_PATH = join(import.meta.dir, "..", "..", "goldens", "dreaming-entities-gold.json");

/** Read the curated entity gold (variantGroups + notableEntities). */
export function loadDreamingGold(path: string = GOLD_PATH): DreamingGold {
  return JSON.parse(readFileSync(path, "utf8")) as DreamingGold;
}

/** Seeds derived from the gold: every variant group AND every notable entity
 *  becomes a (canonical, aliases) seed. Notable entries that share a canonical
 *  with a variant group merge their aliases. */
export function goldSeeds(gold: DreamingGold = loadDreamingGold()): Seed[] {
  const byName = new Map<string, Set<string>>();
  const add = (canonical: string, aliases: string[]): void => {
    let set = byName.get(canonical);
    if (!set) byName.set(canonical, (set = new Set()));
    for (const a of aliases) set.add(a);
  };
  for (const g of gold.variantGroups) add(g.canonical, g.variants);
  for (const n of gold.notableEntities) add(n.name, n.aliases);
  return [...byName].map(([canonical, aliases]) => ({ canonical, aliases: [...aliases] }));
}

/** A resolver pre-seeded with the curated gold — the production seed for the
 *  notable brand-only aliases the model/lexis cannot derive on its own. */
export function goldResolver(gold?: DreamingGold): EntityResolver {
  return new EntityResolver(goldSeeds(gold));
}
