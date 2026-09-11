import { expect, test } from "bun:test";
import { createKvMaintenance } from "../../src/backends/mlx/kv-maintenance";
import { KVCache, RotatingKVCache, QuantizedKVCache, RotatingQuantizedKVCache, type Cache } from "../../src/model/gemma4-base";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";

function populate(cache: KVCache | RotatingKVCache, length: number): void {
  const source = MlxArray.fromFloat32(Float32Array.from({ length: length * 64 }, (_, i) => Math.sin(i * 0.13)), [1, 1, length, 64]);
  const value = source.astype(Dtype.bfloat16);
  source.dispose();
  const fetched = cache.updateAndFetch(value, value);
  ops.evalAll(fetched);
  for (const array of fetched) array.dispose();
  value.dispose();
}

test("shared KV maintenance preserves populated boundary, layer policy and converted bytes", () => {
  const config = [{ layerIdx: 0, bits: 4, groupSize: 32 }, { layerIdx: 1, bits: 8, groupSize: 64 }];
  const maintain = createKvMaintenance({ kvBits: 8, kvConfig: config, quantizedKvStart: 3 });
  const caches: Cache[] = [new KVCache(), new RotatingKVCache(8), new KVCache()];
  const references = [new KVCache(), new RotatingKVCache(8)];
  try {
    maintain(caches);
    expect(caches[0]).toBeInstanceOf(KVCache);
    for (const cache of [...caches, ...references]) populate(cache as KVCache | RotatingKVCache, 2);
    maintain(caches);
    expect(caches[0]).toBeInstanceOf(KVCache);
    expect(caches[1]).toBeInstanceOf(RotatingKVCache);
    for (const cache of [...caches, ...references]) populate(cache as KVCache | RotatingKVCache, 1);
    maintain(caches);
    expect(caches[0]).toBeInstanceOf(QuantizedKVCache);
    expect(caches[1]).toBeInstanceOf(RotatingQuantizedKVCache);
    expect(caches[2]).toBeInstanceOf(KVCache);
    for (let layer = 0; layer < 2; layer++) {
      const entry = config[layer]!;
      const expected = references[layer]!.toQuantized(entry.groupSize, entry.bits);
      try {
        const actual = caches[layer]!.state();
        const wanted = expected.state();
        expect(actual.length).toBe(wanted.length);
        actual.forEach((array, i) => expect(Buffer.from(array.rawBytesView())).toEqual(Buffer.from(wanted[i]!.rawBytesView())));
      } finally { expected.dispose(); }
    }
    const converted = [...caches];
    maintain(caches);
    caches.forEach((cache, i) => expect(cache).toBe(converted[i]!));
  } finally {
    for (const cache of caches) cache.dispose();
    for (const cache of references) cache.dispose();
  }
});

test("uniform defaults wait for 5000 tokens; explicit zero still skips empty caches", () => {
  const caches: Cache[] = [new KVCache(), new RotatingKVCache(8)];
  try {
    createKvMaintenance({ kvBits: 4, quantizedKvStart: 0 })(caches);
    expect(caches[0]).toBeInstanceOf(KVCache);
    expect(caches[1]).toBeInstanceOf(RotatingKVCache);
    for (const cache of caches) populate(cache as KVCache | RotatingKVCache, 3);
    createKvMaintenance({ kvBits: 4 })(caches);
    expect(caches[0]).toBeInstanceOf(KVCache);
    expect(caches[1]).toBeInstanceOf(RotatingKVCache);
    createKvMaintenance({ kvBits: 4, quantizedKvStart: 0 })(caches);
    expect(caches[0]).toBeInstanceOf(QuantizedKVCache);
    expect(caches[1]).toBeInstanceOf(RotatingQuantizedKVCache);
  } finally { for (const cache of caches) cache.dispose(); }
});


test("delayed batch preparation binds layer precision before interpreting row membership", async () => {
  const { DelayedQuantizedKVCache } = await import("../../src/model/delayed-quantized-kv");
  const { cloneKvCaches } = await import("../../src/kv-store");
  const maintain = createKvMaintenance({ kvConfig: [
    { layerIdx: 0, bits: 4, groupSize: 32 },
    { layerIdx: 2, bits: 8, groupSize: 64 },
  ], quantizedKvStart: 3 });
  const rows: Cache[][] = [2, 4].map(length => Array.from({ length: 3 }, () => {
    const cache = new KVCache(); populate(cache, length); return cache;
  }));
  const reference = rows.map(row => cloneKvCaches(row));
  const groups: Cache[] = [];
  try {
    for (const row of rows) { maintain(row); maintain.prepareBatch!(row); }
    for (const row of reference) maintain(row);
    expect(rows[0]![1]).toBeInstanceOf(KVCache);
    for (const [layer, bits, groupSize] of [[0, 4, 32], [2, 8, 64]]) {
      const first = rows[0]![layer!] as InstanceType<typeof DelayedQuantizedKVCache>;
      expect(first).toBeInstanceOf(DelayedQuantizedKVCache);
      const group = first.makeEmptyBatch(); groups.push(group);
      group.mergeRows(rows.map(row => row[layer!]!));
      group.specRoundBegin(); group.specRoundCommit();
      expect(group.rowOffsets).toEqual([2, 4]);
      for (let row = 0; row < rows.length; row++) {
        const actual = group.extractRow(row), expected = reference[row]![layer!]!;
        try {
          expect(actual.constructor).toBe(expected.constructor);
          expect(actual.minimumReusableOffset ?? 0).toBe(expected.minimumReusableOffset ?? 0);
          if (actual instanceof QuantizedKVCache) {
            expect(actual.bits).toBe(bits!); expect(actual.groupSize).toBe(groupSize!);
          }
          expect(actual.state().map(a => Buffer.from(a.rawBytesView())))
            .toEqual(expected.state().map(a => Buffer.from(a.rawBytesView())));
        } finally { actual.dispose(); }
      }
    }
  } finally {
    for (const cache of [...groups, ...rows.flat(), ...reference.flat()]) cache.dispose();
  }
});
