// mlx-bun memory — "The Dreaming" STAGE WORKERS (pipeline decomposition).
//
// The monolithic runPipeline (segment-ALL → extract-ALL → route → create, one
// blocking call) is decomposed here into four INDEPENDENT, DB-state-keyed stage
// workers — exactly the split Lucien made between chunk-recent / cluster-assign /
// synthesize. Each worker:
//   • pulls its eligible work from the DB *by state* (a watermark / the absence
//     of a downstream row), so it is RESUMABLE — an interrupted run continues;
//   • processes a bounded batch and PERSISTS, so two of them can run as separate
//     concurrent processes on different slices;
//   • is individually runnable (`mlx-bun memory segment|extract|route|synthesize`).
//
// CHRONOLOGY IS LOAD-BEARING. Every stage walks oldest-conversation-first
// (conversations.updated_at ASC, then intra-conversation chunks.start ASC).
// `messages` carry only a position, so conv-level updated_at + start is the
// chronological key. This is what makes self-healing correct: the synthesis chunk
// feed for an entity is chronological, so the user's LATEST statement dominates a
// contradicted claim — never "whichever conversation UUID sorts last wins" (the
// old ORDER BY chunk-id == conv-UUID, which is random w.r.t. time).
//
// runPipeline (pipeline.ts) now simply drives these four in sequence, so the full
// DAG and the existing tests still pass.

import { toEntityKind, type EntityKind } from "./article";
import { chunkConversations, type ChunkCall, type ChunkResult } from "./chunk";
import {
  firstSentences,
  routeSections,
  type SectionCall,
  type SectionRouteArticle,
  type SectionRouteChunk,
} from "./cluster";
import type { MemoryStore } from "./db";
import { buildEntityPrompt, extractEntities, type ExtractCall } from "./entity";
import { callLocalBatch } from "./model";
import type { SynthesisEvent } from "./pipeline";
import { loadMetaPolicy } from "./prompts";
import {
  EntityResolver,
  goldSeeds,
  loadDreamingGold,
  type DreamingGold,
} from "./resolve";
import {
  RouteAccumulator,
  engagesAsSubject,
  CAPTURED_BUCKET,
  type CreateStats,
  type RouteAction,
} from "./route";
import { reconcileArticle } from "./reconcile";
import { registerRedirect, relatedArticleStem } from "./redirect";
import {
  entityStem,
  synthesizeCreate,
  synthesizeNewSection,
  synthesizePatch,
  type SynthesisCall,
} from "./synthesize";
import { commitVault, listArticles, readArticle, vaultRoot } from "./vault";

/** Default CREATE cap per synthesize pass (bounds a run's GPU cost). */
export const DEFAULT_ARTICLE_CAP = 20;

// ---- chronological selectors (shared) --------------------------------------

/**
 * Every chunk id in CHRONOLOGICAL order — conversations.updated_at ASC, then
 * chunks.start ASC — optionally restricted to `convIds`. Also returns the
 * distinct conversation count. This replaces the old `ORDER BY chunks.id` (chunk
 * id == conv UUID, which sorts RANDOMLY w.r.t. time).
 */
export function chronoChunkIds(
  store: MemoryStore,
  convIds?: string[],
): { convs: number; chunkIds: string[] } {
  const base =
    "SELECT chunks.id AS id, chunks.conv AS conv FROM chunks " +
    "JOIN conversations c ON c.conv = chunks.conv";
  const order = " ORDER BY c.updated_at ASC, chunks.start ASC";
  let rows: { id: string; conv: string }[];
  if (convIds && convIds.length) {
    const ph = convIds.map(() => "?").join(",");
    rows = store.db.query(`${base} WHERE chunks.conv IN (${ph})${order}`).all(...convIds) as {
      id: string;
      conv: string;
    }[];
  } else {
    rows = store.db.query(`${base}${order}`).all() as { id: string; conv: string }[];
  }
  return { convs: new Set(rows.map((r) => r.conv)).size, chunkIds: rows.map((r) => r.id) };
}

/**
 * Routed chunk ids for ONE entity in CHRONOLOGICAL order (conv.updated_at ASC,
 * chunks.start ASC), optionally restricted to a run's chunk set. The synthesis
 * feed rides this order so the latest statement dominates.
 */
export function entityChunkIdsChrono(
  store: MemoryStore,
  entity: string,
  runChunks?: Set<string>,
): string[] {
  const rows = store.db
    .query(
      "SELECT ce.chunk_id AS id FROM chunk_entities ce " +
        "JOIN chunks ch ON ch.id = ce.chunk_id " +
        "JOIN conversations c ON c.conv = ch.conv " +
        "WHERE ce.entity_name = ? ORDER BY c.updated_at ASC, ch.start ASC",
    )
    .all(entity) as { id: string }[];
  const ids = rows.map((r) => r.id);
  return runChunks ? ids.filter((id) => runChunks.has(id)) : ids;
}

/** The earliest source-conversation updated_at across an entity's in-scope
 *  chunks — the chronological sort key for ordering entities oldest-first. */
function entityEarliestAt(store: MemoryStore, entity: string, runChunks?: Set<string>): number {
  const ids = entityChunkIdsChrono(store, entity, runChunks);
  if (ids.length === 0) return Number.POSITIVE_INFINITY;
  const row = store.db
    .query(
      "SELECT c.updated_at AS at FROM chunks ch JOIN conversations c ON c.conv = ch.conv WHERE ch.id = ?",
    )
    .get(ids[0]!) as { at: number | null } | null;
  return row?.at ?? Number.POSITIVE_INFINITY;
}

/** A chunk's label (the SECTION-ROUTE note label), or null. */
function chunkLabel(store: MemoryStore, chunkId: string): string | null {
  const row = store.db.query("SELECT label FROM chunks WHERE id = ?").get(chunkId) as
    | { label: string | null }
    | null;
  return row?.label ?? null;
}

/** `loadMetaPolicy` that never throws — a missing Meta page yields "" so a
 *  fixture/smoke vault without seeded Meta still runs. */
function loadMetaPolicyQuiet(names: string[]): string {
  try {
    return loadMetaPolicy(names);
  } catch {
    return "";
  }
}

// ---- gold-derived entity metadata (kind + aliases) -------------------------

/** Map every gold canonical → its declared kind + alias set, so a created
 *  article carries the right `kind:` and seeds its `aliases:`. Non-gold entities
 *  default to `thing`. (Lives here so the synthesize stage can stand alone.) */
export interface EntityMeta {
  kindByCanonical: Map<string, EntityKind>;
  aliasesByCanonical: Map<string, string[]>;
}

export function buildEntityMeta(gold: DreamingGold = loadDreamingGold()): EntityMeta {
  const kindByCanonical = new Map<string, EntityKind>();
  const aliasesByCanonical = new Map<string, string[]>();
  const addAliases = (canonical: string, aliases: string[]): void => {
    const set = new Set(aliasesByCanonical.get(canonical) ?? []);
    for (const a of aliases) set.add(a);
    aliasesByCanonical.set(canonical, [...set]);
  };
  for (const g of gold.variantGroups) {
    if (!kindByCanonical.has(g.canonical)) kindByCanonical.set(g.canonical, toEntityKind(g.kind));
    addAliases(g.canonical, g.variants);
  }
  for (const n of gold.notableEntities) {
    if (!kindByCanonical.has(n.name)) kindByCanonical.set(n.name, toEntityKind(n.kind));
    addAliases(n.name, n.aliases);
  }
  return { kindByCanonical, aliasesByCanonical };
}

// ---- CREATE-target selection (pure) ----------------------------------------

export interface RouteDecision {
  entity: string;
  action: RouteAction;
  stats: CreateStats;
}

/**
 * Pick which `create` decisions actually become articles this run: rank by
 * routed-chunk count (then name) and cap, but ALWAYS keep the `mustInclude`
 * entities when they earned a `create`. Pure. Retained for callers/tests that
 * want the routed-count ranking; the chronological synthesize stage orders by
 * earliest-chunk time instead.
 */
export function selectCreateTargets(
  decisions: RouteDecision[],
  cap: number,
  mustInclude: Iterable<string> = [],
): string[] {
  const creatable = decisions.filter((d) => d.action === "create");
  const byEntity = new Map(creatable.map((d) => [d.entity, d]));
  const must = [...mustInclude].filter((e) => byEntity.has(e));
  const ranked = creatable
    .slice()
    .sort((a, b) => b.stats.routedChunks - a.stats.routedChunks || a.entity.localeCompare(b.entity))
    .map((d) => d.entity);
  const out: string[] = [];
  const seen = new Set<string>();
  for (const e of [...must, ...ranked]) {
    if (seen.has(e)) continue;
    seen.add(e);
    out.push(e);
    if (out.length >= cap) break;
  }
  return out;
}

// ---- result shapes (shared with pipeline.ts) -------------------------------

export interface PipelineCreated {
  stem: string;
  hasInfobox: boolean;
  citedSections: number;
  chunkEdges: number;
}

export interface PipelinePatched {
  stem: string;
  anchor: string;
  chunkId: string;
  footnote: number | null;
}

// ===========================================================================
// STAGE 1 — SEGMENT
// ===========================================================================

export interface SegmentStageOptions {
  /** Restrict to these conversation ids (default: every eligible conversation). */
  convIds?: string[];
  /** Cap the number of conversations (re)segmented this pass. */
  limit?: number;
  /** Generation budget per conversation. */
  maxTokens?: number;
  /** Model-call seam (default `callLocal("chunk", …)`). Tests inject a fake. */
  call?: ChunkCall;
  onEvent?: (e: SynthesisEvent) => void;
}

/**
 * SEGMENT — (re)chunk every conversation whose `chunked_at` is NULL or stale
 * (`updated_at > chunked_at`), oldest-first, DELETE+rewrite per conv with OUR
 * adapter, and set `chunked_at`. Resumable by the watermark (a re-run is a
 * no-op). This is a thin, named wrapper over `chunkConversations` so SEGMENT is
 * an independently-runnable worker.
 */
export async function runSegmentStage(
  store: MemoryStore,
  opts: SegmentStageOptions = {},
): Promise<ChunkResult> {
  const result = await chunkConversations(
    store,
    { convs: opts.convIds, limit: opts.limit, maxTokens: opts.maxTokens, call: opts.call },
    opts.onEvent,
  );
  opts.onEvent?.({
    type: "stage",
    stage: "segment",
    message: `segment: ${result.valid} conversation(s) segmented, ${result.chunks} chunk(s) written (${result.skipped} skipped, ${result.errored} errored)`,
  });
  return result;
}

// ===========================================================================
// STAGE 2 — ENTITY-EXTRACT
// ===========================================================================

export interface ExtractStageOptions {
  /** Restrict to these conversation ids (default: all). */
  convIds?: string[];
  /** Cap the number of chunks extracted this pass (default: all pending). */
  limit?: number;
  /** Pre-rendered Entities policy (cached across passes); default loads it. */
  policy?: string;
  /** Model-call seam (default the local `entity` stage). Tests inject a fake. */
  call?: ExtractCall;
  onEvent?: (e: SynthesisEvent) => void;
}

export interface ExtractStageResult {
  /** Chunks extracted this pass. */
  extracted: number;
  /** Pending chunks still un-extracted after the cap (0 ⇒ stage drained). */
  remaining: number;
}

/** Chunks that have NO `chunk_entities` row yet, CHRONOLOGICAL — the extract
 *  work queue (state-keyed: presence of a downstream row ⇒ done). */
function pendingExtractChunkIds(store: MemoryStore, convIds?: string[]): string[] {
  const base =
    "SELECT chunks.id AS id FROM chunks JOIN conversations c ON c.conv = chunks.conv " +
    "WHERE NOT EXISTS (SELECT 1 FROM chunk_entities ce WHERE ce.chunk_id = chunks.id)";
  const order = " ORDER BY c.updated_at ASC, chunks.start ASC";
  if (convIds && convIds.length) {
    const ph = convIds.map(() => "?").join(",");
    return (store.db.query(`${base} AND chunks.conv IN (${ph})${order}`).all(...convIds) as {
      id: string;
    }[]).map((r) => r.id);
  }
  return (store.db.query(`${base}${order}`).all() as { id: string }[]).map((r) => r.id);
}

/**
 * ENTITY-EXTRACT — read each not-yet-extracted chunk (CHRONOLOGICAL: oldest
 * conversation first, then by position) and persist the entities it is about via
 * the store-seeded + gold-seeded resolver, so canonicals fold across the pass.
 * Resumable: a chunk with `chunk_entities` rows is skipped. Returns how many were
 * extracted and how many remain (so a bounded pass can be repeated to drain).
 */
export async function runExtractStage(
  store: MemoryStore,
  opts: ExtractStageOptions = {},
): Promise<ExtractStageResult> {
  const policy = opts.policy ?? loadMetaPolicyQuiet(["Entities"]);
  const resolver = EntityResolver.fromStore(store);
  for (const s of goldSeeds()) resolver.register(s.canonical, s.aliases);

  const pending = pendingExtractChunkIds(store, opts.convIds);
  const cap = opts.limit ?? pending.length;
  const target = Math.min(cap, pending.length);
  opts.onEvent?.({
    type: "stage",
    stage: "extract",
    message: `extract: ${target} of ${pending.length} pending chunk(s) for the entities they are about`,
  });

  const targetIds = pending.slice(0, target);

  // BATCHED model path (the prime uniform-prompt win: one 128-tok call per chunk,
  // independent). Only when no `call` is injected (tests inject a string-matching
  // fake → keep the serial seam) — callLocalBatch itself falls back to a serial
  // bit-exact loop when batching is disabled, so this stays correct either way.
  // The model calls run in a batch; PARSE + RESOLVE + PERSIST stay sequential so
  // the shared resolver folds canonicals in chronological order.
  if (!opts.call && targetIds.length > 1) {
    const inputs = targetIds.map((id) => ({ user: buildEntityPrompt(store.chunkText(id), policy) }));
    const outputs = await callLocalBatch("entity", inputs, { maxTokens: 128 });
    let extracted = 0;
    for (let i = 0; i < targetIds.length; i++) {
      const out = outputs[i] ?? "";
      await extractEntities(store, targetIds[i]!, { resolver, policy, call: async () => out });
      extracted++;
      if (extracted % 10 === 0) {
        opts.onEvent?.({ type: "log", message: `  extracted ${extracted}/${target} chunks` });
      }
    }
    return { extracted, remaining: pending.length - extracted };
  }

  // SERIAL fallback (injected `call`, single chunk, or batching disabled).
  let extracted = 0;
  for (const id of targetIds) {
    await extractEntities(store, id, { resolver, policy: policy || undefined, call: opts.call });
    extracted++;
    if (extracted % 10 === 0) {
      opts.onEvent?.({ type: "log", message: `  extracted ${extracted}/${target} chunks` });
    }
  }
  return { extracted, remaining: pending.length - extracted };
}

// ===========================================================================
// STAGE 3 — ROUTE
// ===========================================================================

export interface RouteStageOptions {
  /** Restrict the routed chunk set to these conversation ids (default: all). */
  convIds?: string[];
  /** Run the subject-engagement model gate to promote a thin (single-chunk)
   *  genuine-subject candidate to a `create` stub. Off by default (a recurring
   *  subject already creates without it). */
  useSubjectGate?: boolean;
  onEvent?: (e: SynthesisEvent) => void;
}

export interface RouteStageResult {
  /** Per-entity create/capture/routed decisions (name-sorted). */
  decisions: RouteDecision[];
  /** Count of entities the gate marked create-eligible. */
  createEligible: number;
  /** Subjects captured (not yet articled) — their chunks land in `_captured`,
   *  still retrievable by search, never dropped. */
  captured: string[];
}

/**
 * ROUTE — recompute the create/capture decisions over `chunk_entities` with the
 * deterministic `RouteAccumulator` + the CREATE gate (Bucketing.md), then PERSIST
 * the outcome so SYNTHESIZE can read it without recomputing: `entities.notable =
 * 1` for a create-eligible (or already-homed) entity, `0` for a captured one, and
 * the captured subjects' chunks into the reserved `_captured` bucket (still
 * searchable — capture is not a drop). Deterministic/CPU (only the optional
 * subject gate touches the GPU). Resumable/idempotent — re-running rewrites the
 * same flags.
 */
export async function runRouteStage(
  store: MemoryStore,
  opts: RouteStageOptions = {},
): Promise<RouteStageResult> {
  const { chunkIds } = chronoChunkIds(store, opts.convIds);
  const chunkSet = new Set(chunkIds);

  const known = (
    store.db.query("SELECT name FROM entities WHERE article_stem IS NOT NULL").all() as {
      name: string;
    }[]
  ).map((r) => r.name);
  const acc = new RouteAccumulator(known);

  // Feed the fan-out CHRONOLOGICALLY (oldest conversation first).
  const rows = store.db
    .query(
      "SELECT ce.chunk_id AS chunk_id, ce.entity_name AS entity_name FROM chunk_entities ce " +
        "JOIN chunks ch ON ch.id = ce.chunk_id JOIN conversations c ON c.conv = ch.conv " +
        "ORDER BY c.updated_at ASC, ch.start ASC, ce.entity_name ASC",
    )
    .all() as { chunk_id: string; entity_name: string }[];
  for (const r of rows) {
    if (!chunkSet.has(r.chunk_id)) continue;
    acc.enqueue(r.entity_name, r.chunk_id);
  }

  // Optional model gate: promote a thin genuine-subject candidate to a `create`
  // stub (chronological scan). NO ownership test — pure subject engagement.
  if (opts.useSubjectGate) {
    for (const d of acc.decisions()) {
      if (d.action !== "capture") continue;
      for (const cid of entityChunkIdsChrono(store, d.entity, chunkSet)) {
        if (await engagesAsSubject(d.entity, store.chunkText(cid))) {
          acc.enqueue(d.entity, cid, { subjectEngagement: true });
          break;
        }
      }
    }
  }

  const decisions = acc.decisions() as RouteDecision[];
  const captured = decisions.filter((d) => d.action === "capture").map((d) => d.entity);

  // PERSIST: notable flag + capture chunks into the reserved _captured bucket
  // (still searchable — capture is not a drop).
  const setNotable = store.db.query("UPDATE entities SET notable = ? WHERE name = ?");
  const ensureBucket = store.db.query(
    "INSERT OR IGNORE INTO buckets (name, article_stem, description) VALUES (?, '', ?)",
  );
  const insChunkBucket = store.db.query(
    "INSERT OR IGNORE INTO chunk_buckets (chunk_id, bucket) VALUES (?, ?)",
  );
  const capturedChunks = new Map<string, string[]>();
  for (const e of captured) capturedChunks.set(e, entityChunkIdsChrono(store, e, chunkSet));
  const tx = store.db.transaction(() => {
    for (const d of decisions) {
      const notable = d.action === "create" || d.action === "routed" ? 1 : 0;
      setNotable.run(notable, d.entity);
    }
    if (captured.length) {
      ensureBucket.run(CAPTURED_BUCKET, "subjects captured but not yet articled — still retrievable by search");
      for (const [, cids] of capturedChunks) for (const cid of cids) insChunkBucket.run(cid, CAPTURED_BUCKET);
    }
  });
  tx();

  // REDIRECTS: every discussed subject must resolve to a home, even when it never
  // earns its own article. A subject FOLDED into an existing article (action
  // "routed") registers its surfaces → that article; a CAPTURED subject registers
  // its surfaces → the article it most co-occurs with (its neighbourhood), so a
  // later resolveName reaches its home instead of NOT FOUND. Idempotent; reindex
  // projects these into entity_aliases. Purely additive — does not affect routing.
  const stemOf = store.db.query("SELECT article_stem AS stem FROM entities WHERE name = ?");
  const surfacesOf = (entity: string): string[] =>
    (
      store.db
        .query("SELECT DISTINCT surface_form AS s FROM chunk_entities WHERE entity_name = ? AND surface_form IS NOT NULL")
        .all(entity) as { s: string }[]
    ).map((r) => r.s);
  const registerHome = (entity: string, home: string, kind: "fold" | "capture"): void => {
    if (!home) return;
    registerRedirect(store, entity, home, kind);
    for (const s of surfacesOf(entity)) registerRedirect(store, s, home, kind);
  };
  for (const d of decisions) {
    if (d.action === "routed") {
      const home = (stemOf.get(d.entity) as { stem: string | null } | null)?.stem;
      if (home) registerHome(d.entity, home, "fold");
    } else if (d.action === "capture") {
      const home = relatedArticleStem(store, d.entity, chunkSet);
      if (home) registerHome(d.entity, home, "capture");
    }
  }

  const createEligible = decisions.filter((d) => d.action === "create").length;
  opts.onEvent?.({
    type: "stage",
    stage: "route",
    message: `route: ${decisions.length} entities — ${createEligible} create, ${captured.length} captured`,
  });
  return { decisions, createEligible, captured };
}

// ===========================================================================
// STAGE 4 — SYNTHESIZE (CREATE + PATCH)
// ===========================================================================

export interface SynthesizeStageOptions {
  /** Vault root (honors MLX_BUN_WIKI); defaults to `vaultRoot()`. */
  root?: string;
  /** Max articles to CREATE this pass (defaults to DEFAULT_ARTICLE_CAP). */
  limit?: number;
  /** Restrict the run to these conversation ids (default: all). */
  convIds?: string[];
  /** Entities to force into the CREATE set when create-eligible. */
  mustCreate?: string[];
  /** Model-call seam for CREATE drafting AND PATCH integration. */
  call?: SynthesisCall;
  /** Model-call seam for SECTION-ROUTE (which existing section a patch folds into). */
  sectionCall?: SectionCall;
  /** Skip the final git commit (tests). */
  commit?: boolean;
  now?: number;
  onEvent?: (e: SynthesisEvent) => void;
}

export interface SynthesizeStageResult {
  created: PipelineCreated[];
  patched: PipelinePatched[];
  skippedByGate: string[];
  /** Article stems a reconcile pass updated to stay consistent with the latest
   *  position (infobox field refresh and/or stale sibling-section rewrite). */
  reconciled: string[];
}

/**
 * SYNTHESIZE — the write stage, CHRONOLOGICAL throughout.
 *
 * (a) CREATE: for each create-eligible entity (`notable = 1`) with NO article
 *     file yet, draft via `synthesizeCreate` FEEDING ITS CHUNKS OLDEST-FIRST so
 *     the latest statement dominates; entities are processed in order of their
 *     EARLIEST chunk (oldest entity first), capped by `limit`.
 * (b) PATCH: for each chunk routed to an EXISTING article and not already in the
 *     `synthesized_chunk_sections` ledger, SECTION-ROUTE then fold via
 *     `synthesizePatch`, oldest chunk first (so a newer correction overwrites an
 *     older take, not the reverse).
 * (c) RECONCILE: after the PATCH loop, for every article it touched, run
 *     `reconcileArticle` so a fold that flipped the verdict also updates whatever
 *     it made stale (infobox relationship fields + sibling sections still asserting
 *     the old value). Bounded + idempotent — a consistent article is a NO-OP.
 *
 * Resumable via article presence + the ledger. Commits once at the end.
 */
export async function runSynthesizeStage(
  store: MemoryStore,
  opts: SynthesizeStageOptions = {},
): Promise<SynthesizeStageResult> {
  const root = opts.root ?? vaultRoot();
  const cap = opts.limit ?? DEFAULT_ARTICLE_CAP;
  const emit = opts.onEvent ?? (() => {});
  const { chunkIds } = chronoChunkIds(store, opts.convIds);
  const runChunks = new Set(chunkIds);

  // Snapshot the EXISTING article files BEFORE drafting, so the create-vs-patch
  // split is stable (an entity created THIS run is not also patched this run).
  const existingStems = new Set(await listArticles(root));
  const dbStemByEntity = new Map(
    (
      store.db.query("SELECT name, article_stem FROM entities WHERE article_stem IS NOT NULL").all() as {
        name: string;
        article_stem: string;
      }[]
    ).map((r) => [r.name, r.article_stem] as const),
  );
  const existingArticleStem = (entity: string): string | null => {
    const dbStem = dbStemByEntity.get(entity);
    if (dbStem && existingStems.has(dbStem)) return dbStem;
    const s = entityStem(entity);
    return existingStems.has(s) ? s : null;
  };

  const meta = buildEntityMeta();
  const created: PipelineCreated[] = [];
  const skippedByGate: string[] = [];

  // ---- CREATE: notable=1, no article file, in scope, oldest entity first ----
  const convFilter = opts.convIds?.length ? `AND ch.conv IN (${opts.convIds.map(() => "?").join(",")})` : "";
  const createRows = store.db
    .query(
      "SELECT e.name AS name, MIN(c.updated_at) AS first_at FROM entities e " +
        "JOIN chunk_entities ce ON ce.entity_name = e.name " +
        "JOIN chunks ch ON ch.id = ce.chunk_id " +
        "JOIN conversations c ON c.conv = ch.conv " +
        `WHERE e.notable = 1 ${convFilter} ` +
        "GROUP BY e.name ORDER BY first_at ASC, e.name ASC",
    )
    .all(...(opts.convIds ?? [])) as { name: string; first_at: number }[];
  const eligible = createRows.map((r) => r.name).filter((n) => existingArticleStem(n) == null);
  const must = (opts.mustCreate ?? []).filter((n) => eligible.includes(n));
  const targets: string[] = [];
  const seen = new Set<string>();
  for (const e of [...must, ...eligible]) {
    if (seen.has(e)) continue;
    seen.add(e);
    targets.push(e);
    if (targets.length >= cap) break;
  }
  emit({ type: "stage", stage: "create", message: `create: drafting ${targets.length} entity article(s) (cap ${cap})` });

  for (const entity of targets) {
    const cids = entityChunkIdsChrono(store, entity, runChunks); // chronological feed
    const kind = meta.kindByCanonical.get(entity) ?? "thing";
    let res;
    try {
      res = await synthesizeCreate(store, {
        entity,
        kind,
        chunkIds: cids,
        root,
        aliases: meta.aliasesByCanonical.get(entity) ?? [],
        call: opts.call,
        commit: false,
        now: opts.now,
      });
    } catch (err) {
      skippedByGate.push(entity);
      emit({ type: "log", message: `  skipped ${entity} (error: ${String(err)})` });
      continue;
    }
    if (res.created) {
      created.push({ stem: res.stem, hasInfobox: res.hasInfobox, citedSections: res.citedSections, chunkEdges: cids.length });
      emit({ type: "log", message: `  created ${res.stem} (infobox=${res.hasInfobox}, cited=${res.citedSections})` });
    } else if (res.skippedByGate) {
      skippedByGate.push(res.stem);
      emit({ type: "log", message: `  skipped ${res.stem} (gate: ${res.reason})` });
    } else {
      emit({ type: "log", message: `  skipped ${res.stem} (${res.reason})` });
    }
  }

  // ---- SECTION-ROUTE → PATCH: existing-article entities, oldest chunk first ----
  const patchEntities = (
    opts.convIds?.length
      ? (store.db
          .query(
            `SELECT DISTINCT ce.entity_name AS name FROM chunk_entities ce JOIN chunks ch ON ch.id = ce.chunk_id WHERE ch.conv IN (${opts.convIds
              .map(() => "?")
              .join(",")})`,
          )
          .all(...opts.convIds) as { name: string }[])
      : (store.db.query("SELECT DISTINCT entity_name AS name FROM chunk_entities").all() as { name: string }[])
  ).map((r) => r.name);

  const patchTargets = patchEntities
    .map((entity) => ({ entity, stem: existingArticleStem(entity) }))
    .filter((t): t is { entity: string; stem: string } => t.stem != null)
    .sort(
      (a, b) =>
        entityEarliestAt(store, a.entity, runChunks) - entityEarliestAt(store, b.entity, runChunks) ||
        a.entity.localeCompare(b.entity),
    );
  emit({
    type: "stage",
    stage: "section-route",
    message: `section-route: ${patchTargets.length} existing-article entit${patchTargets.length === 1 ? "y" : "ies"} to fold into`,
  });

  const patched: PipelinePatched[] = [];
  let patchNoops = 0;
  for (const { entity, stem } of patchTargets) {
    for (const cid of entityChunkIdsChrono(store, entity, runChunks)) {
      let article: SectionRouteArticle;
      try {
        const { content } = await readArticle(root, stem);
        article = { stem, content };
      } catch {
        break; // article vanished mid-run
      }
      const chunk: SectionRouteChunk = {
        id: cid,
        label: chunkLabel(store, cid),
        gist: firstSentences(store.chunkText(cid), 2),
      };
      const routeRes = await routeSections(chunk, article, { call: opts.sectionCall });
      for (const anchor of routeRes.matchedAnchors) {
        const pr = await synthesizePatch(store, {
          stem,
          anchor,
          chunkId: cid,
          root,
          call: opts.call,
          commit: false,
          now: opts.now,
        });
        if (pr.patched) {
          patched.push({ stem, anchor, chunkId: cid, footnote: pr.footnote });
          emit({ type: "log", message: `  patched ${stem} #${anchor} (+chunk ${cid}, [^${pr.footnote}])` });
        } else if (!pr.alreadyIntegrated) {
          patchNoops++;
          emit({ type: "log", message: `  patch NO-OP ${stem} #${anchor} (${pr.reason})` });
        }
      }
      // No existing section fit but the chunk is substantive ⇒ SECTION-ROUTE
      // named a NEW section. HONOR it (mint heading + fold the chunk) instead of
      // dropping the chunk — silent loss is the self-healing bug we are fixing.
      if (routeRes.newSection && routeRes.matchedAnchors.length === 0) {
        const { title, anchor } = routeRes.newSection;
        const nr = await synthesizeNewSection(store, {
          stem,
          title,
          anchor,
          chunkId: cid,
          root,
          call: opts.call,
          commit: false,
          now: opts.now,
        });
        if (nr.patched) {
          patched.push({ stem, anchor, chunkId: cid, footnote: nr.footnote });
          emit({ type: "log", message: `  new section ${stem} #${anchor} (+chunk ${cid}, [^${nr.footnote}])` });
        } else if (!nr.alreadyIntegrated) {
          patchNoops++;
          emit({ type: "log", message: `  new-section NO-OP ${stem} #${anchor} (${nr.reason})` });
        }
      }
    }
  }
  emit({ type: "stage", stage: "patch", message: `patch: ${patched.length} section fold(s), ${patchNoops} NO-OP(s)` });

  // ---- RECONCILE: after a fold flips an article's verdict, update everything it
  // made stale (infobox relationship fields + sibling sections still asserting the
  // old value) so the article ends consistent with the latest position. Runs once
  // per article touched this run; a consistent article is a NO-OP.
  const reconciled: string[] = [];
  const touchedStems = [...new Set(patched.map((p) => p.stem))];
  for (const stem of touchedStems) {
    let rr;
    try {
      rr = await reconcileArticle(store, stem, { root, call: opts.call, commit: false, now: opts.now });
    } catch (err) {
      emit({ type: "log", message: `  reconcile error ${stem}: ${String(err)}` });
      continue;
    }
    if (rr.reconciled) {
      reconciled.push(stem);
      emit({
        type: "log",
        message: `  reconciled ${stem} (fields: ${rr.refreshedFields.join(", ") || "none"}; sections: ${rr.rewrittenSections.join(", ") || "none"}${rr.retried ? "; retried" : ""})`,
      });
    } else if (rr.gateVetoed) {
      emit({ type: "log", message: `  reconcile NO-OP ${stem} (gate: ${rr.reason})` });
    }
    if (rr.unresolved.length) {
      emit({
        type: "log",
        message: `  reconcile UNRESOLVED ${stem} — base-model left a stale present-tense assertion in: ${[...new Set(rr.unresolved)].join(", ")} (a memory-synthesis LoRA / P10-T1 would close it)`,
      });
    }
  }
  emit({ type: "stage", stage: "reconcile", message: `reconcile: ${reconciled.length} article(s) made consistent` });

  const wrote = created.length + patched.length + reconciled.length;
  if (opts.commit !== false && wrote) {
    await commitVault(
      root,
      `memory: synthesis (${created.length} created, ${patched.length} patched, ${reconciled.length} reconciled)`,
    );
  }
  emit({ type: "stage", stage: "commit", message: `commit: ${created.length} created + ${patched.length} patched + ${reconciled.length} reconciled written to ${root}` });

  return { created, patched, skippedByGate, reconciled };
}
