// Read-side name resolution, extracted from main without synthesis/store dependencies.

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

export class EntityResolver {
  /** normal-form stem → canonical. */
  private byStem = new Map<string, string>();
  /** squeeze key → canonical. */
  private bySqueeze = new Map<string, string>();
  /** canonical → union of content tokens across its name + aliases. */
  private tokensOf = new Map<string, Set<string>>();
  /** content token → set of canonicals carrying it (distinctiveness check). */
  private tokenOwners = new Map<string, Set<string>>();

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

