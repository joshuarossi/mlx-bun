import { describe, expect, test } from "bun:test";
import {
  cacheSignature,
  isRowBatchCache,
  KVCache,
  QuantizedKVCache,
  RotatingKVCache,
  RotatingQuantizedKVCache,
} from "../src/model/gemma4-base";
import { BatchedRotatingCache } from "../src/model/batched-rotating";
import { SSMCache } from "../src/model/qwen3-delta";

describe("cache signatures", () => {
  test("storage identity includes layout and affine parameters", () => {
    expect(cacheSignature(new KVCache())).toBe("kv:plain");
    expect(cacheSignature(new RotatingKVCache(1024))).toBe("kv:rotating-plain");
    expect(cacheSignature(new QuantizedKVCache(64, 4))).toBe("kv:quant:4:64");
    expect(cacheSignature(new QuantizedKVCache(32, 8))).toBe("kv:quant:8:32");
    expect(cacheSignature(new RotatingQuantizedKVCache(1024, 64, 4)))
      .toBe("kv:rotating-quant:4:64");
  });

  test("absent cache reads as unknown; every real cache must self-identify", () => {
    // signature() is REQUIRED on Cache (the #42/#43 bug class was a missing
    // override failing open). Only an absent cache reads as "unknown".
    expect(cacheSignature(undefined)).toBe("unknown");
    const kinds = [
      new KVCache(), new RotatingKVCache(1024), new QuantizedKVCache(64, 4),
      new RotatingQuantizedKVCache(1024, 64, 4), new BatchedRotatingCache(1024, [0]),
      new SSMCache(),
    ].map((c) => cacheSignature(c));
    expect(kinds.every((k) => k !== "unknown" && k.length > 0)).toBe(true);
  });

  test("row batching is a capability instead of a scheduler class list", () => {
    expect(isRowBatchCache(new RotatingKVCache(1024))).toBe(false);
    expect(isRowBatchCache(new BatchedRotatingCache(1024, [0, 2]))).toBe(true);
    expect(isRowBatchCache(new SSMCache())).toBe(true);
  });

  test("batched rotating carries the rotating-plain signature (merge guards)", () => {
    // The #mergeJoiner prevRot branch recognizes an already-merged ring by
    // isRowBatchCache(c) && isRotatingPlainCache(c); without the inherited-
    // shape signature the second join saw "unknown", rebuilt a one-row cache,
    // and B>=3 batches lost every sliding layer's KV (2026-08-22 agg×4 collapse).
    expect(cacheSignature(new BatchedRotatingCache(1024, [0]))).toBe("kv:rotating-plain");
  });
});
