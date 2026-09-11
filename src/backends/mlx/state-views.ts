import type { StateView } from "../../contracts/resources";
import { disposeResources, ownResource } from "../../engine/resources";
import type { MlxArray } from "../../mlx/array";
import { isBatchableCache, type Cache } from "../../model/gemma4-base";
import { cloneKvCaches, type CacheCodecProvider } from "../../kv-store";

/** Compatibility boundary for legacy state(). Numerical code consumes a lease,
 * never the legacy ownership marker. No copy, evaluation or fence is added. */
export function leaseCacheState(cache: Cache): StateView<MlxArray> {
  return ownResource<readonly MlxArray[]>(cache.state(), cache.stateNeedsDispose ? disposeResources : () => {});
}

/** Preserve the existing prefill evaluation order: temporary views first,
 * borrowed state second. Partial acquisition releases every acquired view. */
export function leaseCacheStates(caches: readonly Cache[]): StateView<MlxArray> {
  const leases: StateView<MlxArray>[] = [];
  const close = () => disposeResources(leases.map((lease) => ({ dispose: () => lease.close() })));
  try {
    for (const owned of [true, false]) {
      for (const cache of caches) if (!!cache.stateNeedsDispose === owned) leases.push(leaseCacheState(cache));
    }
    return ownResource(leases.flatMap((lease) => [...lease.borrow()]), close);
  } catch (error) {
    try { close(); } catch (cleanupError) { throw new AggregateError([error, cleanupError], "state view acquisition failed"); }
    throw error;
  }
}

/** Precision/storage transitions constrain reuse independently of scheduling. */
export function minimumReusableOffset(caches: readonly Pick<Cache, "minimumReusableOffset">[]): number {
  return Math.max(0, ...caches.map(cache => cache.minimumReusableOffset ?? 0));
}

/** Snapshot an adopted single-row state into persistence-compatible caches.
 * Row layouts own compact extraction; ordinary serial caches use their codec. */
export function cloneSingleRowState(caches: readonly Cache[], codecs?: CacheCodecProvider): Cache[] {
  const owned: Cache[] = [];
  try {
    for (const cache of caches) owned.push(...(isBatchableCache(cache)
      ? [cache.extractRow(0)] : cloneKvCaches([cache], codecs)));
    return owned;
  } catch (error) {
    try { disposeResources(owned); } catch (cleanupError) { throw new AggregateError([error, cleanupError], "single-row snapshot failed"); }
    throw error;
  }
}
