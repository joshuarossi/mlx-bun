import { type Cache } from "../contracts/mlx/cache";
import { disposeResources } from "../runtime/resources";
import { isBatchableCache } from "./capabilities";
import { cloneKvCaches } from "./persistence";
import { type CacheCodecProvider } from "./persistence-types";

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

export { leaseCacheState,leaseCacheStates } from "./leases";
