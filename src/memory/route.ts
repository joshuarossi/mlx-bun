// mlx-bun memory — ROUTE: chunk-entities → subject articles.
//
// Routing is the deterministic-first join from a chunk's extracted entity
// surfaces to subject articles, with the model used ONLY to break genuine ties.
// It is the routing thesis under test: read the subjects a chunk is *about* and
// fan it out to EVERY article it touches (a single chunk routes to many).
//
// The policy here is Lucien's `Bucketing.md` / `Editorial_Guidelines.md`, ported
// faithfully: SURFACE EVERYTHING (nothing is dropped as trivia), STRONGLY PREFER
// EXISTING articles (existing wins ties), and mint a NEW article only for a
// substantive subject with no existing home. There is NO ownership/usefulness
// test — "anything that recurs in your thinking is notable enough."
//
// Per surface, in order:
//   1. RESOLVE — squeeze/alias/token-subset against the known-entity index
//      (resolve.ts). A hit routes deterministically (folds into that existing
//      article), no model call.
//   2. DISAMBIGUATE — a miss gets a trigram shortlist of existing entities; each
//      candidate is put to the model as a bounded binary "is {surface} the same
//      thing as {candidate}?" (callLocal("route"), 4 tokens, parseBinary). The
//      first yes routes (existing wins).
//   3. CREATE / CAPTURE — a surface that matches nothing runs the CREATE gate: a
//      subject earns its OWN article when it RECURS (≥ RECURRENCE_THRESHOLD
//      routed chunks) OR the chunk engages it as a genuine subject (stubs are
//      encouraged for emerging topics). A thin single fleeting mention with no
//      existing home is CAPTURED — left in its chunk, retrievable by search,
//      never dropped and never forced into a junk article. It earns an article
//      later if it recurs.
//
// The deterministic pieces (resolve-to-one, trigram shortlist, fan-out, the
// CREATE gate arithmetic) are pure and unit-tested; only disambiguate() and
// engagesAsSubject() touch the GPU.

import type { MemoryStore } from "./db";
import { callLocal } from "./model";
import { parseBinary } from "./parse";
import { EntityResolver, type MatchKind } from "./resolve";

/** Reserved bucket for subjects captured (not yet articled) — still retrievable
 *  by search, NOT a trivia graveyard. The leading underscore keeps it out of the
 *  emergent bucket namespace. */
export const CAPTURED_BUCKET = "_captured";

/** A subject RECURS (and so is notable enough for its own article) once it has
 *  routed this many distinct chunks. Tunable (Bucketing.md: lower = more/smaller
 *  articles, raise = fewer/larger); ≥2 == "recurs in your thinking." */
export const RECURRENCE_THRESHOLD = 2;

// ---- trigram shortlist -----------------------------------------------------

/** Character trigrams of a casefolded, space-collapsed surface (padded so short
 *  names still yield boundary grams). */
function trigrams(surface: string): Set<string> {
  const s = ` ${surface.toLowerCase().replace(/[^a-z0-9]+/g, " ").replace(/\s+/g, " ").trim()} `;
  const out = new Set<string>();
  for (let i = 0; i + 3 <= s.length; i++) out.add(s.slice(i, i + 3));
  return out;
}

/** Overlap coefficient |A∩B| / min(|A|,|B|) — credits a short name CONTAINED in
 *  a longer one rather than penalizing the length gap a Jaccard would. */
function overlap(a: Set<string>, b: Set<string>): number {
  const m = Math.min(a.size, b.size);
  if (m === 0) return 0;
  const [small, big] = a.size <= b.size ? [a, b] : [b, a];
  let inter = 0;
  for (const x of small) if (big.has(x)) inter++;
  return inter / m;
}

/**
 * Trigram-ranked shortlist of existing canonicals for a surface that the
 * resolver missed — the candidate set handed to the model for disambiguation.
 * Returns up to `k` canonicals with nonzero overlap, best first.
 */
export function trigramShortlist(
  resolver: EntityResolver,
  surface: string,
  k = 5,
): string[] {
  const q = trigrams(surface);
  const scored: { name: string; score: number }[] = [];
  for (const name of resolver.canonicals()) {
    const s = overlap(q, trigrams(name));
    if (s > 0) scored.push({ name, score: s });
  }
  scored.sort((a, b) => b.score - a.score || a.name.localeCompare(b.name));
  return scored.slice(0, k).map((c) => c.name);
}

// ---- model gates -----------------------------------------------------------

/**
 * Bounded binary disambiguation: is `surface` (in the chunk's `label` context)
 * the same thing as the candidate `entity` (one-line `lead`)? One short call,
 * parsed by parseBinary.
 */
export async function disambiguate(
  surface: string,
  label: string | null,
  entity: string,
  lead: string,
): Promise<boolean> {
  const prompt =
    `Is "${surface}" (context: ${label ?? "—"}) the same thing as ` +
    `"${entity}" — ${lead}? Answer yes or no.`;
  return parseBinary(await callLocal("route", { user: prompt }, { maxTokens: 4 }));
}

/**
 * Bounded subject-engagement gate: does this chunk engage with `entity` as a
 * genuine SUBJECT — a topic/idea/person/project/thing the user is actually
 * thinking about and discussing — rather than mentioning it only in passing?
 * Feeds the CREATE gate's single-chunk stub path (NOT an ownership test).
 */
export async function engagesAsSubject(
  entity: string,
  chunkText: string,
): Promise<boolean> {
  const prompt =
    `${chunkText}\n\n---\n` +
    `Based on the note above, does it engage with "${entity}" as a genuine ` +
    `SUBJECT — a topic, idea, person, project, or thing the user is actually ` +
    `thinking about and discussing — rather than mentioning it only in passing? ` +
    `Answer yes or no.`;
  return parseBinary(await callLocal("route", { user: prompt }, { maxTokens: 4 }));
}

// ---- CREATE gate (pure) ----------------------------------------------------

export interface CreateStats {
  /** Distinct chunks that routed to this candidate entity. */
  routedChunks: number;
  /** At least one routed chunk engages this entity as a genuine subject. */
  subjectEngagement: boolean;
}

/**
 * CREATE gate (Bucketing.md / Editorial_Guidelines.md): a subject earns its own
 * article when it RECURS (≥ RECURRENCE_THRESHOLD routed chunks — "recurs in your
 * thinking is notable enough") OR a chunk engages it as a genuine subject (stubs
 * are encouraged for emerging topics). Otherwise it is CAPTURED — kept in its
 * chunk, retrievable by search, never dropped. Pure — the model fills
 * `subjectEngagement` upstream. NO ownership/usefulness test.
 */
export function createGate(stats: CreateStats): "create" | "capture" {
  if (stats.routedChunks >= RECURRENCE_THRESHOLD) return "create";
  if (stats.subjectEngagement) return "create";
  return "capture";
}

// ---- fan-out accumulation --------------------------------------------------

export type RouteAction = "routed" | "create" | "capture";

export interface SurfaceRoute {
  surface: string;
  /** Resolved/candidate canonical, or null when no entity could be assigned. */
  entity: string | null;
  matched: MatchKind | "disambig" | "none";
}

/**
 * Accumulates the chunk→entity fan-out across a run so the CREATE gate can see
 * each candidate's full chunk count + subject-engagement signal before deciding
 * create-vs-capture. Deterministic and model-free: callers route surfaces (via
 * the resolver + optional model disambig) and `enqueue` the resolved canonicals.
 */
export class RouteAccumulator {
  /** canonical → set of chunk ids routed to it (fan-in). */
  private chunks = new Map<string, Set<string>>();
  /** canonical → at least one chunk engages it as a genuine subject. */
  private engaged = new Map<string, boolean>();
  /** canonicals that already exist as known entities (resolver hits) vs minted. */
  private known = new Set<string>();

  constructor(knownCanonicals: Iterable<string> = []) {
    for (const c of knownCanonicals) this.known.add(c);
  }

  /** Record that `chunkId` routes to `entity` (idempotent per chunk). */
  enqueue(entity: string, chunkId: string, opts?: { subjectEngagement?: boolean }): void {
    let set = this.chunks.get(entity);
    if (!set) this.chunks.set(entity, (set = new Set()));
    set.add(chunkId);
    if (opts?.subjectEngagement) this.engaged.set(entity, true);
    else if (!this.engaged.has(entity)) this.engaged.set(entity, false);
  }

  /** Stats for an entity (for the CREATE gate). */
  stats(entity: string): CreateStats {
    return {
      routedChunks: this.chunks.get(entity)?.size ?? 0,
      subjectEngagement: this.engaged.get(entity) ?? false,
    };
  }

  /**
   * Final decision per accumulated entity. Existing known entities are always
   * `routed` (they already have a home — existing wins); minted candidates run
   * the CREATE gate (create vs capture). Returns a stable, name-sorted report.
   */
  decisions(): { entity: string; action: RouteAction; stats: CreateStats }[] {
    const out: { entity: string; action: RouteAction; stats: CreateStats }[] = [];
    for (const entity of [...this.chunks.keys()].sort((a, b) => a.localeCompare(b))) {
      const stats = this.stats(entity);
      const action: RouteAction = this.known.has(entity) ? "routed" : createGate(stats);
      out.push({ entity, action, stats });
    }
    return out;
  }
}

// ---- chunk routing (deterministic resolve; model only on misses) -----------

export interface RouteChunkOpts {
  /** Shortlist width for the model disambiguation fallback. */
  shortlistK?: number;
  /** One-line lead per canonical, for the disambiguation prompt. */
  leads?: Map<string, string>;
  /** Disable the model fallback (deterministic-only routing) — misses become
   *  `none`. Used by the pure tests + dry runs. */
  noModel?: boolean;
}

/**
 * Route ONE chunk's surfaces to canonicals, fanning out to every entity it
 * touches. Resolver hits route deterministically; misses get a trigram shortlist
 * disambiguated by the model (unless `noModel`). Returns one {@link SurfaceRoute}
 * per surface (entity null when nothing matched — a CREATE candidate upstream).
 */
export async function routeChunkSurfaces(
  resolver: EntityResolver,
  surfaces: { surface: string }[],
  label: string | null,
  opts: RouteChunkOpts = {},
): Promise<SurfaceRoute[]> {
  const out: SurfaceRoute[] = [];
  for (const { surface } of surfaces) {
    const hit = resolver.match(surface);
    if (hit) {
      out.push({ surface, entity: hit.name, matched: hit.matched });
      continue;
    }
    if (opts.noModel) {
      out.push({ surface, entity: null, matched: "none" });
      continue;
    }
    let routed: string | null = null;
    for (const cand of trigramShortlist(resolver, surface, opts.shortlistK ?? 5)) {
      const lead = opts.leads?.get(cand) ?? cand;
      if (await disambiguate(surface, label, cand, lead)) {
        routed = cand;
        break;
      }
    }
    out.push({ surface, entity: routed, matched: routed ? "disambig" : "none" });
  }
  return out;
}

/**
 * Read a chunk's persisted entity surfaces (chunk_entities.surface_form). The
 * routing input when extraction has already run; surfaces preserve their raw
 * form so the resolver/model see what the user actually typed.
 */
export function chunkSurfaces(store: MemoryStore, chunkId: string): { surface: string }[] {
  const rows = store.db
    .query("SELECT surface_form FROM chunk_entities WHERE chunk_id = ? ORDER BY surface_form")
    .all(chunkId) as { surface_form: string }[];
  return rows.map((r) => ({ surface: r.surface_form }));
}
