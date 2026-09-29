import { TurboQuantKVCache } from "./turboquant-kv";
import { RotatingKVCache } from "./rotating-kv";
import { RotatingQuantizedKVCache } from "./rotating-quantized-kv";
import { isBatchableCache, isPlainKvCache, isQuantizedKvCache, isRecurrentCache, isRotatingPlainCache, isRotatingQuantizedCache } from "./capabilities";
import { PaddedKVRows } from "./batched-mask";
import { PaddedQuantKVRows } from "./batched-quant";
import { BatchedRotatingCache } from "./batched-rotating";
import { BatchedRotatingQuantCache } from "./batched-rotating-quant";
import { BatchedSSMCache } from "./batched-ssm";
import { type BatchableCache, type Cache } from "../contracts/mlx/cache";
import { DelayedRotatingQuantizedKVCache } from "./delayed-rotating-quantized-kv";
import { RotatingAffineLayout } from "./rotating-kv-layout";
import { BatchedTurboQuantKVCache } from "./batched-turboquant-kv";
import { targetRowLayoutFactory, type TargetRowLayout } from "./target-layout";
import { PagedKVCache } from "./paged/cache";
import { PagedKvRows } from "./paged/rows";
import { unchangedKv } from "./kv-maintenance";

/** The row layout a running batch keeps this cache's rows in, for ordinary
 * continuous decoding: an empty layout whose `mergeRows` accepts the cache (and
 * the layouts it made). Every storage a graph's caches, or their precision
 * maintenance, produce has one; undefined for a cache that cannot batch. Answers
 * without allocating, so a binding can probe support. */
export function ownedCacheLayoutFactory(cache: Cache): (() => BatchableCache) | undefined {
  if (cache instanceof PagedKVCache) return () => new PagedKvRows(cache.capacityTokens, cache.blockSize, cache.direct, cache.quantization);
  if (isBatchableCache(cache)) return () => cache.makeEmptyBatch();
  if (cache instanceof TurboQuantKVCache) return () => new BatchedTurboQuantKVCache(cache.kBits, cache.vBits, cache.fusedDecode);
  if (isPlainKvCache(cache)) return () => new PaddedKVRows();
  if (isQuantizedKvCache(cache)) return () => new PaddedQuantKVRows(cache.groupSize, cache.bits);
  if (isRotatingPlainCache(cache)) return () => new BatchedRotatingCache(cache.maxSize, []);
  if (isRotatingQuantizedCache(cache)) return () => BatchedRotatingQuantCache.empty(cache.maxSize, cache.groupSize, cache.bits, []);
  if (isRecurrentCache(cache)) return () => new BatchedSSMCache();
  return undefined;
}

/** Bind encoded state to its row layout. Execution owners only move rows. */
export function ownedCacheLayout(cache: Cache): BatchableCache | undefined {
  return ownedCacheLayoutFactory(cache)?.();
}

/** Prefill reuses decode's layouts; shape selection belongs to storage. */
export function prefillCacheLayout(cache: Cache): BatchableCache {
  if (cache instanceof PagedKVCache) return new PagedKvRows(cache.capacityTokens, cache.blockSize, cache.direct, cache.quantization);
  if (isBatchableCache(cache)) return cache.makeEmptyBatch();
  // Plain rotating rows never convert here; their dense reads say so.
  if (cache instanceof RotatingKVCache) return new DelayedRotatingQuantizedKVCache(cache.maxSize, 64, 4, Infinity, unchangedKv);
  if (cache instanceof RotatingQuantizedKVCache) return new RotatingAffineLayout(cache.maxSize, cache.groupSize, cache.bits);
  return targetCacheLayout(cache);
}

/** Target transaction layouts retain each source cache's numerical codec. */
export function targetCacheLayout(cache: Cache): TargetRowLayout {
  const make = targetRowLayoutFactory(cache);
  if (!make) throw new Error(`No target row layout for ${cache.signature()}`);
  return make();
}
