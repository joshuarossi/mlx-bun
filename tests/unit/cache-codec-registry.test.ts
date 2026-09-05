import { describe, expect, test } from "bun:test";
import {
  cacheHeadersTrimmable,
  type CacheHeaderEntry,
  type CacheKind,
  createCacheCodecProvider, legacyCacheCodecs, saveKvCache, loadKvCache,
  readKvHeader, cloneKvCaches,
} from "../../src/kv-store";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import * as ops from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";
import {
  KVCache,
  QuantizedKVCache,
  RotatingKVCache,
  RotatingQuantizedKVCache,
  TurboQuantKVCache,
} from "../../src/model/gemma4-base";
import { MLACache } from "../../src/model/glm52-cache";
import { SSMCache } from "../../src/model/qwen3-delta";

const header = (
  kind: CacheKind,
  overrides: Partial<CacheHeaderEntry> = {},
): CacheHeaderEntry => ({ kind, offset: 1, tensors: [], ...overrides });

describe("cache persistence registry", () => {
  test("an alternate provider owns clone/write/restore and rejects mismatches before allocation", () => {
    const directory = mkdtempSync(join(tmpdir(), "mlx-codec-binding-"));
    const cache = new KVCache();
    cache.restoreState(ops.zeros([1, 1, 2, 8], Dtype.float32), ops.zeros([1, 1, 2, 8], Dtype.float32), 2);
    const legacy = legacyCacheCodecs.forCache(cache);
    const calls: string[] = [];
    const codecs = createCacheCodecProvider("alternate-v1", { kv: {
      ...legacy,
      clone(cache, context) { calls.push("clone"); return legacy.clone(cache, context); },
      snapshot(cache, context) { calls.push("snapshot"); return legacy.snapshot(cache, context); },
      load(entry, context) { calls.push("load"); return legacy.load(entry, context); },
    } });
    const path = join(directory, "state.mlxkv");
    try {
      const clones = cloneKvCaches([cache], codecs);
      try { saveKvCache(path, [1, 2], clones, {}, codecs); }
      finally { for (const clone of clones) clone.dispose(); }
      expect(readKvHeader(path).codecProvider).toBe("alternate-v1");
      let allocations = 0;
      const model = { makeCache() { allocations++; return [new KVCache()]; } };
      expect(() => loadKvCache(path, model)).toThrow("provider mismatch");
      expect(allocations).toBe(0);
      const restored = loadKvCache(path, model, {}, codecs);
      try { expect(restored.caches[0]!.offset).toBe(2); }
      finally { for (const state of restored.caches) state.dispose(); }
      expect(calls).toEqual(["clone", "snapshot", "load"]);
    } finally { cache.dispose(); rmSync(directory, { recursive: true, force: true }); }
  });

  test("ambiguous state bindings refuse instead of choosing by registration order", () => {
    const cache = new KVCache();
    const codec = legacyCacheCodecs.forCache(cache);
    const provider = createCacheCodecProvider("ambiguous", { kv: codec, rotating: codec });
    expect(() => provider.forCache(cache)).toThrow("2 matches");
    cache.dispose();
  });

  test("a codec failure releases partial clone views without releasing the donor", () => {
    const cache = new KVCache();
    cache.restoreState(ops.zeros([1, 1, 2, 8], Dtype.float32), ops.zeros([1, 1, 2, 8], Dtype.float32), 2);
    const legacy = legacyCacheCodecs.forCache(cache);
    let released = 0;
    const provider = createCacheCodecProvider("failing-clone", { kv: {
      ...legacy,
      clone(_cache, context) {
        const view = context.view(cache.keys!);
        const dispose = view.dispose.bind(view);
        view.dispose = () => { released++; dispose(); };
        throw new Error("clone failed after first view");
      },
    } });
    try {
      expect(() => cloneKvCaches([cache], provider)).toThrow("clone failed after first view");
      expect(released).toBe(1);
      expect(cache.keys!.shape).toEqual([1, 1, 2, 8]);
      ops.evalAll([cache.keys!]);
    } finally { cache.dispose(); }
  });

  test("every persisted kind has one trimmability policy", () => {
    const alwaysTrimmable: CacheKind[] = [
      "kv", "qkv", "turboquant", "mla", "mla-dsa", "mtp-mla",
    ];
    expect(cacheHeadersTrimmable(alwaysTrimmable.map((kind) => header(kind)))).toBe(true);
    expect(cacheHeadersTrimmable([header("ssm")])).toBe(false);
    expect(cacheHeadersTrimmable([
      header("rotating", { offset: 7, maxSize: 8 }),
      header("rotating-qkv", { offset: 7, maxSize: 8 }),
    ])).toBe(true);
    expect(cacheHeadersTrimmable([
      header("rotating", { offset: 8, maxSize: 8 }),
    ])).toBe(false);
  });

  test("serving cache signatures identify their storage schemes", () => {
    expect(new KVCache().signature()).toBe("kv:plain");
    expect(new QuantizedKVCache(64, 4).signature()).toBe("kv:quant:4:64");
    expect(new RotatingKVCache(1024).signature()).toBe("kv:rotating-plain");
    expect(new RotatingQuantizedKVCache(1024, 64, 4).signature())
      .toBe("kv:rotating-quant:4:64");
    expect(new TurboQuantKVCache(2, 4).signature()).toBe("kv:turboquant:2:4");
    expect(new SSMCache().signature()).toBe("ssm");
    expect(new MLACache({ kvLoraRank: 512, ropeHeadDim: 64 }).signature())
      .toBe("kv:mla:target");
    expect(new MLACache({
      kvLoraRank: 512, ropeHeadDim: 64, dsa: { headDim: 32 },
    }).signature()).toBe("kv:mla:target:dsa");
    expect(new MLACache({
      kvLoraRank: 512, ropeHeadDim: 64, role: "mtp",
    }).signature()).toBe("kv:mla:mtp");
  });

  test("per-token accounting is representation-owned", () => {
    expect(new SSMCache().bytesPerToken()).toBe(0);
    expect(new MLACache({ kvLoraRank: 512, ropeHeadDim: 64 }).bytesPerToken())
      .toBe((512 + 64) * 4);
    expect(new MLACache({
      kvLoraRank: 512, ropeHeadDim: 64, dsa: { headDim: 32 },
    }).bytesPerToken()).toBe((512 + 64 + 32) * 4);
  });
});
