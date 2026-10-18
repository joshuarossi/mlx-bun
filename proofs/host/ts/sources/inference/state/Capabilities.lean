import host.ts.Source
namespace Host.Ts.Sources.Inference.State.Capabilities
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/capabilities.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// What the state modules ask of a cache's representation. Every caller is in
// `state/`: the planner, the scheduler and the methods read none of it.
import type { BatchableCache,Cache,RowBatchCache } from "../contracts/mlx/cache";
import { KVCache } from "./kv";
import { QuantizedKVCache } from "./quantized-kv";
import { RotatingKVCache } from "./rotating-kv";
import { RotatingQuantizedKVCache } from "./rotating-quantized-kv";

export function cacheSignature(cache: Cache | undefined): string {
  return cache ? cache.signature() : "unknown";
}

/** The storage a cache holds: a composed lego's (`Cache.composed`), else the
 * cache itself. What the request state reads to learn which layers a fresh
 * cache list pages. */
export function composedStorageOf(cache: Cache): Cache {
  return cache.composed ? cache.composed.storage() : cache;
}

export function isRowBatchCache(cache: Cache): cache is RowBatchCache {
  const candidate = cache as Partial<RowBatchCache>;
  return typeof candidate.batchSize === "number" &&
    typeof candidate.filterRows === "function" &&
    typeof candidate.extractRow === "function";
}

/** Recurrent state (gated DeltaNet): fixed-size, never trimmed. */
export function isRecurrentCache(cache: Cache | undefined): boolean {
  return cacheSignature(cache) === "ssm";
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

export function isTurboQuantKvCache(cache: Cache | undefined): boolean {
  return cacheSignature(cache).startsWith("kv:turboquant:");
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
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.Capabilities
