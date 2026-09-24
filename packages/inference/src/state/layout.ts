import { TurboQuantKVCache } from "./turboquant-kv";
import { RotatingKVCache } from "./rotating-kv";
import { RotatingQuantizedKVCache } from "./rotating-quantized-kv";
import { isBatchableCache } from "./capabilities";
import { type BatchableCache, type Cache } from "../contracts/cache";
import { DelayedRotatingQuantizedKVCache } from "./delayed-rotating-quantized-kv";
import { RotatingAffineLayout } from "./rotating-kv-layout";
import { BatchedTurboQuantKVCache } from "./batched-turboquant-kv";
import { targetRowLayoutFactory, type TargetRowLayout } from "./target-layout";
import { PagedKVCache } from "./paged/cache";
import { PagedKvRows } from "./paged/rows";

/** Bind encoded state to its row layout. Execution owners only move rows. */
export function ownedCacheLayout(cache: Cache): BatchableCache | undefined {
  if (cache instanceof PagedKVCache) return new PagedKvRows(cache.capacityTokens, cache.blockSize, cache.direct, cache.quantization);
  if (isBatchableCache(cache)) return cache.makeEmptyBatch();
  if (cache instanceof TurboQuantKVCache) return new BatchedTurboQuantKVCache(cache.kBits, cache.vBits, cache.fusedDecode);
  return undefined;
}

/** Prefill reuses decode's layouts; shape selection belongs to storage. */
export function prefillCacheLayout(cache: Cache): BatchableCache {
  if (cache instanceof PagedKVCache) return new PagedKvRows(cache.capacityTokens, cache.blockSize, cache.direct, cache.quantization);
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
