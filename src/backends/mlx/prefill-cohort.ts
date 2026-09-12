import type { Cache } from "../../model/gemma4-base";
import type { RuntimeModel } from "../../model/factory";
import type { MlxArray } from "../../mlx/array";
import { nextPrefillStep } from "../../inference/prefill";
import type { CacheCodecProvider } from "../../kv-store";
import { disposeResources, cleanupFailure } from "../../engine/resources";
import type { Row, RowPromptCache } from "./batch-group";
import type { KvMaintenance } from "./kv-maintenance";
import { MlxPrefillRows, type MlxPrefillState } from "./prefill-rows";

export interface PrefillState extends MlxPrefillState {
  snapAt: number | null;
  continuation?: import("./continuation").OrdinaryContinuationState;
  closePrefill?: () => void;
}

interface PrefillHost {
  model: RuntimeModel;
  chunkSize: number;
  tailSplit: boolean;
  promptCache?: RowPromptCache;
  stateCodecs?: CacheCodecProvider;
  maintain?: KvMaintenance;
  forward(ids: MlxArray, caches: Cache[]): Promise<MlxArray>;
  /** Target projection preserves the forward batch geometry before sampling. */
  project(hidden: MlxArray, caches: Cache[], completed: readonly PrefillState[]): MlxArray;
  /** Borrows [1,1,V] logits; takes ownership of the completed request caches. */
  complete(state: PrefillState, logits: MlxArray): Promise<void>;
  resume?(state: PrefillState): Promise<void>;
  reject(row: Row, error: unknown): void;
}

/** Ordinary sampling/cache policy over the shared target preparation driver. */
export class MlxPrefillCohort extends MlxPrefillRows<PrefillState> {
  constructor(readonly host: PrefillHost) {
    super({
      stateCodecs: host.stateCodecs, maintain: host.maintain,
      open(row) {
        let owned: { caches: Cache[]; retain?: () => void } | undefined;
        let closeCache: (() => void) | undefined;
        let closePrefill: (() => void) | undefined;
        try {
          closeCache = row.req.trace?.begin("cache.lookup_restore", { mechanism: "continuous" });
          const continuation = row.req.continuation?.restore(row.cacheNamespace ?? "");
          if (continuation) {
            owned = { caches: continuation.caches };
            return { row, solo: continuation.caches, pos: row.req.promptIds.length,
              snapAt: null, continuation };
          }
          const hit = host.promptCache?.take(row.req.promptIds, row.cacheNamespace, row.req.cacheSessionId) ?? null;
          if (hit) owned = hit;
          closeCache?.(); closeCache = undefined;
          if (hit) row.cachedTokens = hit.tokens.length;
          const length = row.req.promptIds.length;
          const boundary = Math.min(row.req.snapshotAt ?? length, length - 1);
          const snapAt = host.promptCache && boundary >= 256 && boundary > (hit?.tokens.length ?? 0) ? boundary : null;
          closePrefill = row.req.trace?.begin("prefill.total", {
            mechanism: "continuous", promptTokens: row.promptTokens, cachedTokens: row.cachedTokens,
          });
          const closeSetup = row.req.trace?.begin("prefill.batch_setup", { mechanism: "continuous" });
          owned ??= { caches: row.req.statePolicy?.create() ?? host.model.makeCache() }; closeSetup?.();
          return { row, solo: owned.caches, pos: hit?.tokens.length ?? 0, retain: owned.retain, snapAt, closePrefill };
        } catch (error) {
          return cleanupFailure(error, () => disposeResources([...(owned?.caches ?? []),
            { dispose: () => owned?.retain?.() }, { dispose: () => closePrefill?.() }]));
        } finally { closeCache?.(); }
      },
      ready: state => !!state.continuation,
      plan(state) { return nextPrefillStep({ length: state.row.promptTokens, position: state.pos,
        chunkSize: state.row.req.prefillChunkSize ?? host.chunkSize,
        tailSplit: host.tailSplit, snapshotAt: state.snapAt }); },
      forward: (ids, caches, _states, work) => work ? work(ids, caches) : host.forward(ids, caches),
      project: host.project.bind(host),
      complete: (state, logits) => state.continuation ? host.resume!(state) : host.complete(state, logits!), reject: host.reject.bind(host),
      checkpoint(state, capture) {
        let snapshot: Cache[] | undefined;
        try {
          snapshot = capture();
          host.promptCache!.put(state.row.req.promptIds.slice(0, state.pos), snapshot, state.row.cacheNamespace, undefined, undefined, state.row.req.cacheSessionId);
          snapshot = undefined;
        } catch (error) {
          if (snapshot) disposeResources(snapshot);
          console.warn(`batch-lane boundary snapshot skipped: ${(error as Error).message}`);
        }
        state.snapAt = null;
      },
      close(state) { const close = state.closePrefill; state.closePrefill = undefined; close?.(); },
    });
  }
}
