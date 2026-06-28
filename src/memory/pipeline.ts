// mlx-bun memory — synthesis pipeline orchestrator (P6-T4).
//
// Ties the stage modules into the cold-start DAG:
//   ingest → SEGMENT → ENTITY-EXTRACT → ROUTE → CREATE → NORMALIZE → commitVault.
//
// `ingest` + `SEGMENT` already populated the corpus (conversations / messages /
// chunks live in the MemoryStore), so for an already-chunked conversation
// SEGMENT is a no-op and the pipeline operates on the existing chunks. The model
// stages reuse the existing modules verbatim:
//   - ENTITY-EXTRACT — entity.ts `extractEntities` (one chunk per call, persists
//     chunk_entities + a candidate entities/aliases row via the variant resolver).
//   - ROUTE — route.ts `RouteAccumulator` over the persisted chunk_entities
//     (the deterministic canonical join + the B8/P1-T5 CREATE gate); the optional
//     model substantive-engagement gate promotes thin-but-owned candidates.
//   - CREATE/NORMALIZE/commit — synthesize.ts `synthesizeCreate` (sub-cluster →
//     OUTLINE → per-section DRAFT → INFOBOX → assemble → NORMALIZE → gate → write
//     + ledger), with a single `commitVault` at the end of the run.
//
// `runSynthesis` keeps the M1 event/summary contract `src/cli.ts` drives; it now
// runs the real DAG over the default store + vault. The FULL-corpus bootstrap is
// USER-ACTION (P6-T5) — the agent never starts it; `scripts/experiments`
// drives a bounded handful of conversations through `runPipeline` directly.

import type { ChunkCall } from "./chunk";
import type { SectionCall } from "./cluster";
import { runLinkStage } from "./crosslink";
import { MemoryStore } from "./db";
import type { ExtractCall } from "./entity";
import {
  buildEntityMeta,
  chronoChunkIds,
  runExtractStage,
  runRouteStage,
  runSegmentStage,
  runSynthesizeStage,
  selectCreateTargets,
  type EntityMeta,
  type PipelineCreated,
  type PipelinePatched,
  type RouteDecision,
} from "./stages";
import type { SynthesisCall } from "./synthesize";
import { vaultRoot } from "./vault";
import { wikifyVault } from "./wikify";

// Re-export the factored-out pure helpers + types so existing importers (tests,
// scripts) keep their `from "./pipeline"` entry points.
export { buildEntityMeta, selectCreateTargets };
export type { EntityMeta, PipelineCreated, PipelinePatched, RouteDecision };

// ---- stage / event contract (consumed by src/cli.ts) -----------------------

export type SynthesisStage =
  | "ingest"
  | "segment"
  | "chunk"
  | "extract"
  | "route"
  | "create"
  | "section-route"
  | "patch"
  | "reconcile"
  | "link"
  | "wikify"
  | "commit";

export interface SynthesisEvent {
  type: "stage" | "log" | "done";
  stage?: SynthesisStage;
  message: string;
}

export interface SynthesisOptions {
  /** Only synthesize conversations newer than this (ISO date / conv cursor). */
  since?: string;
  /** Override the synthesis model (default e4b). Reserved — the stages resolve
   *  their own per-stage adapter via model.ts. */
  model?: string;
  /** Plan only — never write the vault (deterministic, no model). */
  dryRun?: boolean;
}

export interface SynthesisSummary {
  implemented: boolean;
  stages: SynthesisStage[];
  note: string;
}

const STAGES: SynthesisStage[] = [
  "ingest",
  "segment",
  "extract",
  "route",
  "create",
  "section-route",
  "patch",
  "link",
  "wikify",
  "commit",
];

// ---- pipeline run ----------------------------------------------------------

export interface PipelineOptions {
  /** Restrict the run to these conversation ids; default every conversation. */
  convIds?: string[];
  /** Vault root (honors MLX_BUN_WIKI); defaults to `vaultRoot()`. */
  root?: string;
  /** Max articles to CREATE this run (bounds a smoke's GPU cost). */
  articleCap?: number;
  /** Entities to force into the CREATE set when they earn a `create`. */
  mustCreate?: string[];
  /** Model-call seam for SEGMENT (the `chunk` stage — our e4b-chunk-300 /
   *  `memory-chunk` adapter). Defaults to `callLocal("chunk", …)` inside
   *  chunkConversations; tests inject a fake to avoid a real model load. */
  segmentCall?: ChunkCall;
  /** Model-call seam for the CREATE drafting AND the steady-state PATCH (both run
   *  the `synthesis` stage). Tests inject a fake. */
  call?: SynthesisCall;
  /** Model-call seam for ENTITY-EXTRACT (the `entity` stage). Tests inject a fake. */
  extractCall?: ExtractCall;
  /** Model-call seam for SECTION-ROUTE (the `section` stage binary/name calls).
   *  Tests inject a fake. */
  sectionCall?: SectionCall;
  /** Run the subject-engagement model gate to promote a thin (single-chunk)
   *  genuine-subject candidate to a `create` stub. Off by default (a recurring
   *  subject already creates). */
  useSubjectGate?: boolean;
  /** Skip the final git commit (tests). */
  commit?: boolean;
  now?: number;
  onEvent?: (e: SynthesisEvent) => void;
}

export interface PipelineResult {
  convs: number;
  chunks: number;
  /** Distinct resolved entities seen across the routed chunks. */
  entities: number;
  created: PipelineCreated[];
  /** Sections of existing articles patched this run (the self-healing folds). */
  patched: PipelinePatched[];
  skippedByGate: string[];
  /** Subjects captured (not yet articled) — still retrievable by search. */
  captured: string[];
}

/**
 * Run the cold-start synthesis DAG over a bounded set of conversations.
 *
 * This is now a thin ORCHESTRATOR: it drives the four INDEPENDENT, chronological,
 * resumable stage workers (`stages.ts`) in sequence — SEGMENT → ENTITY-EXTRACT →
 * ROUTE → SYNTHESIZE (CREATE + SECTION-ROUTE/PATCH) — so the full DAG behaves as
 * before while each stage is also separately runnable (`mlx-bun memory
 * segment|extract|route|synthesize`). Returns a structured report; SYNTHESIZE
 * commits once at the end via `commitVault`.
 */
export async function runPipeline(
  store: MemoryStore,
  opts: PipelineOptions = {},
): Promise<PipelineResult> {
  const root = opts.root ?? vaultRoot();
  const cap = opts.articleCap ?? 20;
  const emit = opts.onEvent ?? (() => {});

  emit({ type: "stage", stage: "ingest", message: `ingest: corpus already in the store` });

  // SEGMENT — (re)chunk every in-scope conversation whose chunked_at is NULL or
  // stale, oldest-first, then proceed on the fresh chunks. A re-run is a no-op
  // (watermark). We do NOT reuse any external chunks.
  await runSegmentStage(store, { convIds: opts.convIds, call: opts.segmentCall, onEvent: opts.onEvent });

  // Chronological run scope (oldest conversation first) for the result counts.
  const { convs, chunkIds } = chronoChunkIds(store, opts.convIds);
  emit({ type: "log", message: `operating on ${convs} conversation(s), ${chunkIds.length} chunk(s)` });

  // ENTITY-EXTRACT — every not-yet-extracted chunk, chronological + resumable.
  await runExtractStage(store, { convIds: opts.convIds, call: opts.extractCall, onEvent: opts.onEvent });

  // ROUTE — deterministic create/capture over chunk_entities + CREATE gate;
  // persists notable + captures thin subjects into _captured (still searchable)
  // so SYNTHESIZE reads the decision back.
  const route = await runRouteStage(store, {
    convIds: opts.convIds,
    useSubjectGate: opts.useSubjectGate,
    onEvent: opts.onEvent,
  });

  // SYNTHESIZE — chronological CREATE (oldest entity first, oldest chunk first so
  // the latest statement dominates) + SECTION-ROUTE → PATCH self-healing fold.
  const synth = await runSynthesizeStage(store, {
    root,
    limit: cap,
    convIds: opts.convIds,
    mustCreate: opts.mustCreate,
    call: opts.call,
    sectionCall: opts.sectionCall,
    commit: opts.commit,
    now: opts.now,
    onEvent: opts.onEvent,
  });

  // CROSS-LINK — build the EDGES synthesis (bounded to one article) cannot:
  // inline-link first mentions of other articles + rebuild each ## See also from
  // mentions + co-occurrence. Deterministic (no model) and idempotent.
  await runLinkStage(store, { root, commit: opts.commit, onEvent: (e) => emit({ type: e.type, message: e.message }) });

  emit({
    type: "done",
    message: `synthesis done — ${synth.created.length} created, ${synth.patched.length} patched, ${synth.skippedByGate.length} gated, ${route.captured.length} captured.`,
  });

  return {
    convs,
    chunks: chunkIds.length,
    entities: route.decisions.length,
    created: synth.created,
    patched: synth.patched,
    skippedByGate: synth.skippedByGate,
    captured: route.captured,
  };
}

// ---- cli entry: the M1 contract src/cli.ts drives --------------------------

/**
 * Run the synthesis pipeline over the default store + vault — the `mlx-bun
 * memory synthesize` path. Keeps the {@link SynthesisSummary} shape the CLI
 * prints. The FULL-corpus run is a long GPU job (USER-ACTION, P6-T5); this entry
 * exists so the wiring is complete — the agent never starts it.
 */
export async function runSynthesis(
  opts: SynthesisOptions = {},
  onEvent?: (e: SynthesisEvent) => void,
): Promise<SynthesisSummary> {
  if (opts.dryRun) {
    onEvent?.({ type: "log", message: "dry-run — no model calls, nothing will be written." });
    for (const stage of STAGES) onEvent?.({ type: "stage", stage, message: `${stage}: planned (dry-run)` });
    onEvent?.({ type: "done", message: "dry-run complete — no articles written." });
    return { implemented: true, stages: STAGES, note: "dry-run: DAG wired; no model calls made." };
  }

  const store = new MemoryStore();
  try {
    // WRITE branch: ingest → segment → extract → route → create → commit.
    const result = await runPipeline(store, { onEvent });

    // WIKIFY branch: the periodic editorial sweep over EVERY article (P8). Runs
    // after the write branch so freshly-created and patched articles are tightened
    // + infobox-refreshed in the same nightly pass; each article commits its own
    // change (or NO-OPs) behind the same conservative gate. Best-effort: a wikify
    // defect must not lose the create-branch work already committed above.
    onEvent?.({ type: "stage", stage: "wikify", message: "wikify: editorial sweep over every article" });
    let editedCount = 0;
    try {
      const sweep = await wikifyVault({ root: vaultRoot() });
      editedCount = sweep.edited.length;
      onEvent?.({ type: "log", message: `  wikify edited ${editedCount}/${sweep.results.length} article(s)` });
    } catch (err) {
      onEvent?.({ type: "log", message: `  wikify sweep skipped (error: ${String(err)})` });
    }
    onEvent?.({
      type: "done",
      message: `synthesis done — ${result.created.length} created, ${result.patched.length} patched, ${editedCount} wikified.`,
    });

    return {
      implemented: true,
      stages: STAGES,
      note: `synthesis wired — ${result.created.length} created, ${result.patched.length} patched, ${editedCount} wikified from ${result.convs} conversations.`,
    };
  } finally {
    store.close();
  }
}
