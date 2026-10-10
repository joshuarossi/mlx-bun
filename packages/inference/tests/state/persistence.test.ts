import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Dtype, MlxArray } from "@mlx-bun/mlx";
import type { Cache } from "@mlx-bun/inference/contracts";
import {
  KVCache, QuantizedKVCache, RotatingKVCache, RotatingQuantizedKVCache,
  TurboQuantKVCache, cloneKvCaches, saveKvCache, loadKvCache, SsdCacheStore, unfusedAffineKernels,
} from "@mlx-bun/inference/state";

const factories = [
  () => new KVCache(), () => new QuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)),
  () => new RotatingKVCache(8), () => new RotatingQuantizedKVCache(8, 64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)),
  () => new TurboQuantKVCache(8, 3),
];

function append(cache: Cache, x: MlxArray): Buffer[] {
  const arrays = cache.quantizedAttention
    ? cache.quantizedAttention.updateAndFetchQuantized(x, x).flatMap(t => [t.packed, t.scales, t.biases])
    : cache.updateAndFetch(x, x);
  try { return arrays.map(a => Buffer.from(a.rawBytes())); }
  finally { for (const a of arrays) a.dispose(); }
}

for (const factory of factories) test(`${factory().signature()} cloned and persisted state preserves continuation bytes`, () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-state-")), cache = factory();
  let clones: Cache[] = [], restored: Cache[] = [];
  try {
    using raw = MlxArray.fromFloat32(Float32Array.from({ length: 12 * 64 }, (_, i) => Math.sin(i * 0.13)), [1, 1, 12, 64]);
    using data = raw.astype(Dtype.bfloat16);
    using first = data.slice([0, 0, 0, 0], [1, 1, 9, 64]);
    append(cache, first);
    clones = cloneKvCaches([cache]);
    const path = join(dir, "prefix.mlxkv");
    const tokens = Array.from({ length: 9 }, (_, i) => i);
    saveKvCache(path, tokens, [cache], { modelId: "synthetic" });
    const loaded = loadKvCache(path, { makeCache: () => [factory()] }, { modelId: "synthetic", verify: true });
    restored = loaded.caches;
    expect(loaded.tokens).toEqual(tokens);
    for (let i = 9; i < 12; i++) {
      using next = data.slice([0, 0, i, 0], [1, 1, i + 1, 64]);
      const expected = append(cache, next);
      for (const other of [...clones, ...restored]) {
        expect(append(other, next)).toEqual(expected);
        expect(other.offset).toBe(cache.offset);
      }
    }
  } finally {
    for (const c of [cache, ...clones, ...restored]) c.dispose();
    rmSync(dir, { recursive: true, force: true });
  }
});

test("scan never deletes another model's entry and each store restores only its own", () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-ssd-foreign-"));
  const options = (modelId: string, tokenizerHash = "vocab") =>
    ({ dir, maxBytes: Infinity, configFingerprint: "shared-shape", tokenizerHash, modelId });
  const save = (store: SsdCacheStore, tokens: number[]) => {
    const cache = new KVCache();
    try {
      using raw = MlxArray.fromFloat32(Float32Array.from({ length: 4 * 64 }, (_, i) => Math.cos(i)), [1, 1, 4, 64]);
      using data = raw.astype(Dtype.bfloat16);
      append(cache, data);
      expect(store.store(tokens, [cache])).toBe(true);
    } finally { cache.dispose(); }
  };
  try {
    const four = new SsdCacheStore(options("model-4bit")), eight = new SsdCacheStore(options("model-8bit"));
    save(four, [1, 2, 3, 4]); save(eight, [5, 6, 7, 8]);
    const fourPath = four.find([1, 2, 3, 4, 9])!.entry.path, eightPath = eight.find([5, 6, 7, 8, 9])!.entry.path;
    // Restarts in either order, and a same-name model with another tokenizer.
    const fourAgain = new SsdCacheStore(options("model-4bit")), eightAgain = new SsdCacheStore(options("model-8bit"));
    const retokenized = new SsdCacheStore(options("model-4bit", "other-vocab"));
    expect(fourAgain.scan()).toBe(1); expect(retokenized.scan()).toBe(0); expect(eightAgain.scan()).toBe(1);
    expect(existsSync(fourPath)).toBe(true); expect(existsSync(eightPath)).toBe(true);
    expect(fourAgain.find([1, 2, 3, 4, 9])?.prefixLen).toBe(4); expect(fourAgain.find([5, 6, 7, 8, 9])).toBeNull();
    expect(eightAgain.find([5, 6, 7, 8, 9])?.prefixLen).toBe(4); expect(eightAgain.find([1, 2, 3, 4, 9])).toBeNull();
    const restored = eightAgain.restore(eightAgain.find([5, 6, 7, 8, 9])!.entry, { makeCache: () => [new KVCache()] });
    expect(restored?.tokens).toEqual([5, 6, 7, 8]); for (const c of restored?.caches ?? []) c.dispose();
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("a store enforces the live limit its owner lends, evicting the oldest entry when it shrinks", () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-ssd-limit-"));
  let lent = Infinity;
  const store = new SsdCacheStore({ dir, maxBytes: Infinity, limit: () => lent, configFingerprint: "limited", tokenizerHash: "vocab", modelId: "limited" });
  const save = (tokens: number[]) => {
    const cache = new KVCache();
    try {
      using raw = MlxArray.fromFloat32(Float32Array.from({ length: 4 * 64 }, (_, i) => Math.cos(i + tokens[0]!)), [1, 1, 4, 64]);
      using data = raw.astype(Dtype.bfloat16);
      append(cache, data);
      return store.store(tokens, [cache]);
    } finally { cache.dispose(); }
  };
  try {
    expect(store.maxBytes).toBe(Infinity);
    expect(save([1, 2, 3, 4])).toBe(true); expect(save([5, 6, 7, 8])).toBe(true);
    expect(store.entries).toBe(2);
    // The owner now lends room for one entry: the next write evicts the older one.
    lent = store.totalBytes / 2 + 1;
    expect(store.maxBytes).toBe(lent);
    expect(save([9, 10, 11, 12])).toBe(true);
    expect(store.entries).toBe(1);
    expect(store.find([9, 10, 11, 12, 13])?.prefixLen).toBe(4); expect(store.find([1, 2, 3, 4, 13])).toBeNull();
    // An entry larger than the limit is not stored at all.
    lent = 1;
    expect(save([20, 21, 22, 23])).toBe(false);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
