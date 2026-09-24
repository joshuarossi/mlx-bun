import { Glm52Cache } from "./glm52-cache";
import { SpeculativeRotatingKVCache } from "./speculative-rotating-kv";
import { RotatingAffineLayout, SpeculativeRotatingAffineLayout } from "./rotating-kv-layout";
import type { Cache } from "../contracts/mlx/cache";
import { KVCache } from "./kv";
import { QuantizedKVCache } from "./quantized-kv";
import { TurboQuantKVCache } from "./turboquant-kv";
import { RotatingKVCache } from "./rotating-kv";
import { RotatingQuantizedKVCache } from "./rotating-quantized-kv";
import { DelayedRotatingQuantizedKVCache } from "./delayed-rotating-quantized-kv";
import { DelayedQuantizedKVCache } from "./delayed-quantized-kv";
import { DelayedTurboQuantKVCache } from "./delayed-turboquant-kv";
import { SSMCache } from "./ssm";
import { BatchedSSMCache } from "./batched-ssm";
import { BatchedKVCache } from "./batched-kv";
import { BatchedQuantizedKVCache } from "./batched-quantized-kv";
import { BatchedTurboQuantKVCache } from "./batched-turboquant-kv";

export type TargetRowLayout = Glm52Cache | DelayedRotatingQuantizedKVCache | RotatingAffineLayout | SpeculativeRotatingKVCache | BatchedKVCache | BatchedQuantizedKVCache | BatchedTurboQuantKVCache |
  BatchedSSMCache | DelayedTurboQuantKVCache | DelayedQuantizedKVCache;

/** The storage binding advertises a row transaction factory. The gateway can
 * compose supported model graphs without identifying their model family. */
export function targetRowLayoutFactory(cache: Cache): (() => TargetRowLayout) | undefined {
  if (cache instanceof Glm52Cache) return () => cache.makeEmptyBatch();
  if (cache instanceof DelayedRotatingQuantizedKVCache)
    return () => new DelayedRotatingQuantizedKVCache(cache.maxSize, cache.groupSize, cache.bits, cache.start, cache.maintain, undefined, true);
  if (cache instanceof RotatingAffineLayout || cache instanceof RotatingQuantizedKVCache)
    return () => new SpeculativeRotatingAffineLayout(cache.maxSize, cache.groupSize, cache.bits);
  if (cache instanceof RotatingKVCache || cache instanceof SpeculativeRotatingKVCache) return () => new SpeculativeRotatingKVCache(cache.maxSize);
  if (cache instanceof DelayedTurboQuantKVCache || cache instanceof DelayedQuantizedKVCache ||
      cache instanceof BatchedTurboQuantKVCache || cache instanceof BatchedKVCache ||
      cache instanceof BatchedQuantizedKVCache || cache instanceof BatchedSSMCache) return () => cache.makeEmptyBatch();
  if (cache instanceof TurboQuantKVCache) return () => new BatchedTurboQuantKVCache(cache.kBits, cache.vBits, cache.fusedDecode);
  if (cache instanceof SSMCache) return () => new BatchedSSMCache();
  if (cache instanceof QuantizedKVCache) return () => new BatchedQuantizedKVCache(cache.groupSize, cache.bits);
  if (cache instanceof KVCache) return () => new BatchedKVCache();
  return undefined;
}
