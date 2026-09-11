import { expect, test } from "bun:test";
import { mkdtempSync, readFileSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { KVCache, type Cache } from "../../src/model/gemma4-base";
import { createKvMaintenance } from "../../src/backends/mlx/kv-maintenance";
import { PromptCache } from "../../src/prompt-cache";
import { SsdCacheStore } from "../../src/ssd-cache";
import { cloneKvCaches, readKvHeader } from "../../src/kv-store";
import { leaseCacheState } from "../../src/backends/mlx/state-views";
import { withResource } from "../../src/engine/resources";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";

function append(cache: Cache, count: number) {
  using raw = ops.fromInt32(Array.from({ length: count * 64 }, (_, i) => i % 7), [1, 1, count, 64]);
  using data = raw.astype(Dtype.bfloat16);
  cache.updateAndFetch(data, data).forEach(a => a.dispose());
}
function fixture() {
  const source: Cache[] = [new KVCache()]; append(source[0]!, 3);
  const plain = cloneKvCaches(source);
  append(source[0]!, 2);
  createKvMaintenance({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 5 })(source);
  append(source[0]!, 2);
  return { plain, converted: source, dispose() { [...plain, ...source].forEach(c => c.dispose()); } };
}
function bytes(cache: Cache) {
  return withResource(leaseCacheState(cache), state => state.map(array => {
    using contiguous = ops.contiguous(array);
    return [array.shape, array.dtype, Buffer.from(contiguous.rawBytesView()).toString("hex")];
  }));
}
const short = [1, 2, 3], long = [1, 2, 3, 4, 5, 6, 7];
function release(hit: { caches: Cache[]; retain?: () => void } | null | undefined) {
  hit?.caches.forEach(c => c.dispose()); hit?.retain?.();
}

test("RAM keeps a plain donor below a conversion boundary and selects only valid prefixes", () => {
  const f = fixture(), store = new PromptCache(1e8);
  try {
    store.put(short, cloneKvCaches(f.plain)); const donor = store.findExact(short)!;
    store.put(long, cloneKvCaches(f.converted));
    expect(f.converted[0]!.minimumReusableOffset).toBe(5);
    expect(store.findExact(short)).toBe(donor);
    expect(store.peekPrefixLen([1, 2, 3, 4, 99])).toBe(3);
    const below = store.take([1, 2, 3, 4, 99]);
    try { expect(below?.tokens).toEqual(short); expect(below?.caches[0]!.signature()).toBe("kv:plain"); }
    finally { release(below); }
    const at = store.take([1, 2, 3, 4, 5, 99]);
    try {
      expect(at?.tokens).toHaveLength(5);
      expect(at?.caches[0]!.minimumReusableOffset).toBe(5);
      expect(at?.caches[0]!.signature()).toBe("kv:turboquant:8:3");
    } finally { release(at); }
    const isolated = new PromptCache(1e8);
    try {
      isolated.put(long, cloneKvCaches(f.converted));
      expect(isolated.peekPrefixLen([1, 2, 3, 4, 99])).toBe(0);
      expect(isolated.take([1, 2, 3, 4, 99])).toBeNull();
    } finally { isolated.clear(); }
  } finally { store.clear(); f.dispose(); }
});

test("SSD preserves precision ancestors through sync/async storage, restart and RAM restore", async () => {
  const f = fixture(), dir = mkdtempSync(join(tmpdir(), "kv-reuse-boundary-"));
  const options = { dir, maxBytes: 1e8, configFingerprint: "reuse", tokenizerHash: "tokens", modelId: "stub" };
  try {
    const first = new SsdCacheStore(options);
    expect(first.store(short, f.plain)).toBe(true);
    expect(await first.storeAsync(long, f.converted)).toBe(true);
    expect(first.hasDurablePrefix(short)).toBe(true);
    const restarted = new SsdCacheStore(options);
    expect(restarted.scan()).toBe(2);
    expect(restarted.find([1, 2, 3, 4, 99])?.prefixLen).toBe(3);
    const hit = restarted.find([...long, 99])!;
    expect(readKvHeader(hit.entry.path).caches[0]!.minimumReusableOffset).toBe(5);
    const loaded = restarted.restore(hit.entry, { makeCache: () => [new KVCache()] });
    try {
      expect(loaded?.caches[0]!.minimumReusableOffset).toBe(5);
      expect(bytes(loaded!.caches[0]!)).toEqual(bytes(f.converted[0]!));
      const continuation = cloneKvCaches(f.converted);
      try {
        append(loaded!.caches[0]!, 1); append(continuation[0]!, 1);
        expect(bytes(loaded!.caches[0]!)).toEqual(bytes(continuation[0]!));
      } finally { continuation.forEach(c => c.dispose()); }
    }
    finally { release(loaded); }
    const ram = new PromptCache(1e8, null, {
      find(prompt, ns) { const hit = restarted.find(prompt, ns); return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null; },
      restore(handle) {
        const loaded = restarted.restore(handle as typeof hit.entry, { makeCache: () => [new KVCache()] });
        return loaded ? { ...loaded, retain() {} } : null;
      },
      store() {},
    });
    try {
      const below = ram.take([1, 2, 3, 4, 99]);
      try { expect(below?.tokens).toEqual(short); expect(below?.caches[0]!.signature()).toBe("kv:plain"); }
      finally { release(below); }
      const at = ram.take([1, 2, 3, 4, 5, 99]);
      try { expect(at?.caches[0]!.minimumReusableOffset).toBe(5); expect(at?.caches[0]!.offset).toBe(5); }
      finally { release(at); }
    } finally { ram.clear(); }
    // An isolated converted descendant cannot claim durability of a prefix
    // below its minimum, even though its storage is physically trimmable.
    const other = new SsdCacheStore({ ...options, configFingerprint: "isolated" });
    expect(other.store(long, f.converted)).toBe(true);
    expect(other.hasDurablePrefix(short)).toBe(false);
  } finally { f.dispose(); rmSync(dir, { recursive: true, force: true }); }
});

test("old TQ SSD headers without a boundary resume only at the stored offset", () => {
  const f = fixture(), dir = mkdtempSync(join(tmpdir(), "kv-reuse-legacy-"));
  const options = { dir, maxBytes: 1e8, configFingerprint: "legacy", tokenizerHash: "tokens", modelId: "stub" };
  try {
    const writer = new SsdCacheStore(options);
    expect(writer.store(long, f.converted)).toBe(true);
    const path = writer.find([...long, 99])!.entry.path;
    // Produce a valid pre-trait v3 header without touching tensor data or offsets.
    const file = readFileSync(path), magic = Buffer.byteLength("MLXBUNKV2\n");
    const length = file.readUInt32LE(magic), begin = magic + 16;
    const header = JSON.parse(file.subarray(begin, begin + length).toString());
    for (const cache of header.caches) delete cache.minimumReusableOffset;
    const bytes = Buffer.from(JSON.stringify(header).padEnd(length, " "));
    expect(bytes.byteLength).toBe(length);
    bytes.copy(file, begin); file.writeBigUInt64LE(BigInt(Bun.hash(bytes)), magic + 8); writeFileSync(path, file);
    const reader = new SsdCacheStore(options);
    expect(reader.scan()).toBe(1);
    expect(reader.find([1, 2, 3, 4, 5, 99])).toBeNull();
    expect(reader.hasDurablePrefix(short)).toBe(false);
    const exact = reader.find([...long, 99])!;
    expect(exact.prefixLen).toBe(7);
    const restored = reader.restore(exact.entry, { makeCache: () => [new KVCache()] });
    try {
      expect(restored?.caches[0]!.minimumReusableOffset).toBe(7);
      const copies = cloneKvCaches(restored!.caches);
      try { expect(copies[0]!.minimumReusableOffset).toBe(7); } finally { copies.forEach(c => c.dispose()); }
    } finally { release(restored); }
  } finally { f.dispose(); rmSync(dir, { recursive: true, force: true }); }
});


test("RAM declines a cold provider's unusable precision boundary and keeps its shorter donor", () => {
  const f = fixture();
  const store = new PromptCache(1e8, null, {
    find() { return { prefixLen: 4, handle: null }; },
    restore() { return { tokens: long, caches: cloneKvCaches(f.converted), retain() {} }; },
    store() {},
  });
  try {
    store.put(short, cloneKvCaches(f.plain));
    const hit = store.take([1, 2, 3, 4, 99]);
    try { expect(hit?.tokens).toEqual(short); expect(hit?.caches[0]!.signature()).toBe("kv:plain"); }
    finally { release(hit); }
  } finally { store.clear(); f.dispose(); }
});
