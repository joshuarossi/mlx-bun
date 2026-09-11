import { TurboQuantKVCache, RotatingKVCache, RotatingQuantizedKVCache, isBatchableCache, type BatchableCache, type Cache } from "../../model/gemma4-base";
import { DelayedRotatingQuantizedKVCache } from "../../model/delayed-rotating-quantized-kv";
import { RotatingAffineLayout } from "../../model/rotating-kv-layout";
import { BatchedTurboQuantKVCache } from "../../model/batched-turboquant-kv";
import { targetRowLayoutFactory, type TargetRowLayout } from "./target-layout-capability";
import { PagedKVCache } from "../../lab/paged-kv/paged-kv";
import { PagedKvRows } from "../../lab/paged-kv/paged-kv-rows";

/** Bind encoded state to its row layout. Execution owners only move rows. */
export function ownedCacheLayout(cache: Cache): BatchableCache | undefined {
  if (cache instanceof PagedKVCache) return new PagedKvRows(cache.capacityTokens, cache.blockSize);
  if (isBatchableCache(cache)) return cache.makeEmptyBatch();
  if (cache instanceof TurboQuantKVCache) return new BatchedTurboQuantKVCache(cache.kBits, cache.vBits);
  return undefined;
}

/** Prefill reuses decode's layouts; shape selection belongs to storage. */
export function prefillCacheLayout(cache: Cache): BatchableCache {
  if (cache instanceof PagedKVCache) return new PagedKvRows(cache.capacityTokens, cache.blockSize);
  if (isBatchableCache(cache)) return cache.makeEmptyBatch();
  if (cache instanceof RotatingKVCache) return new DelayedRotatingQuantizedKVCache(cache.maxSize, 64, 4, Infinity, () => {});
  if (cache instanceof RotatingQuantizedKVCache) return new RotatingAffineLayout(cache.maxSize, cache.groupSize, cache.bits);
  return targetCacheLayout(cache);
}

/** Target transaction layouts retain each source cache's numerical codec. */
export function targetCacheLayout(cache: Cache): TargetRowLayout {
  const make = targetRowLayoutFactory(cache);
  if (!make) throw new Error(`No target row layout for ${cache.signature()}`);
  return make();
}
