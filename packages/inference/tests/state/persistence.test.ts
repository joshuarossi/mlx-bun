import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Dtype, MlxArray } from "@mlx-bun/mlx";
import type { Cache } from "@mlx-bun/inference/contracts";
import {
  KVCache, QuantizedKVCache, RotatingKVCache, RotatingQuantizedKVCache,
  TurboQuantKVCache, cloneKvCaches, saveKvCache, loadKvCache,
} from "@mlx-bun/inference/state";

const factories = [
  () => new KVCache(), () => new QuantizedKVCache(64, 4),
  () => new RotatingKVCache(8), () => new RotatingQuantizedKVCache(8, 64, 4),
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
