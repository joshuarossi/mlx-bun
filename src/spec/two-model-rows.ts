import type { MlxAutoregressiveBinding } from "../backends/mlx/autoregressive";
import { MlxAutoregressiveDraftRows, type MlxDraftLayout } from "../backends/mlx/autoregressive-draft-rows";
import { prefillCacheLayout } from "../backends/mlx/cache-layout";
import { MlxStateRows } from "../backends/mlx/state-rows";
import { captureCacheAttachment, restoreCacheAttachment } from "../backends/mlx/cache-attachment";
import { applyStateChanges, cleanupFailure, disposeResources } from "../engine/resources";
import type { Cache } from "../model/gemma4-base";
import type { DraftPrefillGroup, DraftRowCheckpoint, DraftRowGroup, DraftRowSampling, GroupedDraftProvider } from "./source";
import type { PreparedStateChange } from "../contracts/resources";
import type { MlxArray } from "../mlx/array";

export interface StandaloneDraftRows extends DraftPrefillGroup {
  draft: DraftRowGroup["draft"];
  commit(accepted: readonly number[], context?: MlxArray): Promise<void>;
}

/** The standalone model supplies graph/state capabilities once. Target
 * verification, scheduling and cache tiers use the existing provider ports. */
export function openStandaloneDraftRows(binding: MlxAutoregressiveBinding, namespace: string,
  sampling: DraftRowSampling | null, checkpoints: readonly (DraftRowCheckpoint | null)[]): StandaloneDraftRows {
    const empty = binding.makeCache(), layouts: MlxDraftLayout[] = [];
    try { for (const cache of empty) layouts.push(prefillCacheLayout(cache) as MlxDraftLayout); }
    catch (error) { disposeResources(layouts); throw error; }
    finally { disposeResources(empty); }
    const state = new MlxStateRows(layouts), rows = new MlxAutoregressiveDraftRows(binding.graph, state, sampling);
    const prepareAppend = (checkpoints: readonly (DraftRowCheckpoint | null)[]): PreparedStateChange => {
      const restored: Cache[][] = [], pending: Array<number | null> = [];
      try {
        for (const checkpoint of checkpoints) {
          restored.push(checkpoint ? restoreCacheAttachment(checkpoint.attachment, binding.makeCache) : binding.makeCache());
          pending.push(checkpoint && checkpoint.attachment.metadata.pendingLast !== false ? Number(checkpoint.attachment.metadata.pendingLast) : null);
        }
        return rows.prepareAppend(restored, pending);
      } finally { disposeResources(restored.flat()); }
    };
    const append = (checkpoints: readonly (DraftRowCheckpoint | null)[]) => applyStateChanges([() => prepareAppend(checkpoints)]);
    try { append(checkpoints); }
    catch (error) { return cleanupFailure(error, () => rows.dispose()); }
    return {
      namespace, prefillMode: "tail-split", tapLayers: [],
      get rowCount() { return state.rowCount; },
      append, prepareAppend, prefill: tokens => rows.prefill(tokens), materialize: () => rows.materialize(),
      filterRows: keep => rows.filterRows(keep), draft: rows.draft.bind(rows), commit: accepted => rows.commit(accepted),
      capture(row): DraftRowCheckpoint {
        const caches = state.extractRow(row), pendingLast = rows.pendingLast[row] ?? null;
        try {
          const processedTokens = caches[0]!.offset + Number(pendingLast !== null);
          return { processedTokens, attachment: captureCacheAttachment("standalone-draft-v1", caches,
            { processedTokens, pendingLast: pendingLast ?? false }) };
        } finally { disposeResources(caches); }
      },
      dispose: () => rows.dispose(),
    };
}

export function standaloneDraftGroups(binding: MlxAutoregressiveBinding, namespace: string): GroupedDraftProvider {
  return {
    open: options => openStandaloneDraftRows(binding, namespace, options.sampling, options.checkpoints),
    openPrefill: options => openStandaloneDraftRows(binding, namespace, null, options.checkpoints),
  };
}
