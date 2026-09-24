import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { BatchableCache,Cache,RowBatchCache } from "../contracts/mlx/cache";
import { KVCache } from "./kv";
import { QuantizedKVCache } from "./quantized-kv";
import { RotatingKVCache } from "./rotating-kv";
import { RotatingQuantizedKVCache } from "./rotating-quantized-kv";


/** Retain an independent array handle for positions used across cache writes.
 * The contiguous view preserves the integer values and shares their storage;
 * callers release it with the fetched attention state. */
export function captureRopeOffsets(cache: Pick<Cache, "ropeOffsetArr">): MlxArray | undefined {
  const offsets = cache.ropeOffsetArr;
  return offsets ? ops.contiguous(offsets) : undefined;
}

export function cacheSignature(cache: Cache | undefined): string {
  return cache ? cache.signature() : "unknown";
}

export function isRowBatchCache(cache: Cache): cache is RowBatchCache {
  const candidate = cache as Partial<RowBatchCache>;
  return typeof candidate.batchSize === "number" &&
    typeof candidate.filterRows === "function" &&
    typeof candidate.extractRow === "function";
}

export function isPlainKvCache(cache: Cache | undefined): cache is KVCache {
  return cacheSignature(cache) === "kv:plain";
}

export function isQuantizedKvCache(cache: Cache | undefined): cache is QuantizedKVCache {
  return cacheSignature(cache).startsWith("kv:quant:");
}

export function isRotatingPlainCache(cache: Cache | undefined): cache is RotatingKVCache {
  return cacheSignature(cache) === "kv:rotating-plain";
}

export function isRotatingQuantizedCache(
  cache: Cache | undefined,
): cache is RotatingQuantizedKVCache {
  return cacheSignature(cache).startsWith("kv:rotating-quant:");
}

export function isBatchableCache(cache: Cache): cache is BatchableCache {
  const candidate = cache as Partial<BatchableCache>;
  return (
    typeof candidate.makeEmptyBatch === "function" &&
    typeof candidate.mergeRows === "function" &&
    typeof candidate.extractRow === "function" &&
    typeof candidate.filterRows === "function" &&
    typeof candidate.projectedBytes === "function" &&
    Array.isArray(candidate.rowOffsets) &&
    Array.isArray(candidate.leftPad)
  );
}
