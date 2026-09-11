import { Glm52Cache } from "../../model/glm52-cache";
import { SpeculativeRotatingKVCache } from "../../model/speculative-rotating-kv";
import { RotatingAffineLayout, SpeculativeRotatingAffineLayout } from "../../model/rotating-kv-layout";
import type { Cache } from "../../model/gemma4-base";
import { KVCache, QuantizedKVCache, TurboQuantKVCache, RotatingKVCache, RotatingQuantizedKVCache } from "../../model/gemma4-base";
import { DelayedRotatingQuantizedKVCache } from "../../model/delayed-rotating-quantized-kv";
import { DelayedQuantizedKVCache } from "../../model/delayed-quantized-kv";
import { DelayedTurboQuantKVCache } from "../../model/delayed-turboquant-kv";
import { SSMCache } from "../../model/qwen3-delta";
import { BatchedSSMCache } from "../../model/batched-ssm";
import { BatchedKVCache } from "../../model/batched-kv";
import { BatchedQuantizedKVCache } from "../../model/batched-quantized-kv";
import { BatchedTurboQuantKVCache } from "../../model/batched-turboquant-kv";

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
  if (cache instanceof TurboQuantKVCache) return () => new BatchedTurboQuantKVCache(cache.kBits, cache.vBits);
  if (cache instanceof SSMCache) return () => new BatchedSSMCache();
  if (cache instanceof QuantizedKVCache) return () => new BatchedQuantizedKVCache(cache.groupSize, cache.bits);
  if (cache instanceof KVCache) return () => new BatchedKVCache();
  return undefined;
}
