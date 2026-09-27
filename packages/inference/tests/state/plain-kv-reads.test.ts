// Plain KV reads (`updateAndFetch`) are certified per row by the storage that
// can answer, from the conversion test its own maintenance applies. The
// query is pure and must predict the actual read: it holds exactly when the
// delayed cache's plain read appends. A cache without the capability (or
// maintained by a callback that cannot answer) is not certified, whatever a
// direct read of it would do.
import { expect, test } from "bun:test";
import * as ops from "@mlx-bun/mlx/ops";
import { Dtype } from "@mlx-bun/mlx/ffi";
import type { MlxArray } from "@mlx-bun/mlx/array";
import { KVCache } from "../../src/state/kv";
import { RotatingKVCache } from "../../src/state/rotating-kv";
import { QuantizedKVCache } from "../../src/state/quantized-kv";
import { RotatingQuantizedKVCache } from "../../src/state/rotating-quantized-kv";
import { BatchedKVCache } from "../../src/state/batched-kv";
import { BatchedRotatingCache } from "../../src/state/batched-rotating";
import { BatchedQuantizedKVCache } from "../../src/state/batched-quantized-kv";
import { RotatingAffineLayout } from "../../src/state/rotating-kv-layout";
import { TurboQuantKVCache } from "../../src/state/turboquant-kv";
import { DelayedQuantizedKVCache } from "../../src/state/delayed-quantized-kv";
import { DelayedRotatingQuantizedKVCache } from "../../src/state/delayed-rotating-quantized-kv";
import { DelayedTurboQuantKVCache } from "../../src/state/delayed-turboquant-kv";
import { createKvMaintenance, unchangedKv, type KvMaintenance } from "../../src/state/kv-maintenance";
import { prefillCacheLayout } from "../../src/state/layout";
import type { Cache } from "../../src/contracts/mlx/cache";

const W = 8;
const tensor = (b: number, n: number, seed: number) => {
  using key = ops.randomKey(BigInt(seed)); return ops.randomNormal([b, 2, n, 64], Dtype.bfloat16, 0, 1, key);
};
const plainRow = (rotating: boolean, length: number, seed: number): Cache => {
  const row = rotating ? new RotatingKVCache(W) : new KVCache();
  using k = tensor(1, length, seed), v = tensor(1, length, seed + 1);
  for (const a of row.updateAndFetch(k, v)) a.dispose();
  return row;
};
type Delayed = DelayedQuantizedKVCache | DelayedRotatingQuantizedKVCache;
const delayed = (rotating: boolean, start: number, maintain: KvMaintenance, lengths: number[], seed: number): Delayed => {
  const group = rotating ? new DelayedRotatingQuantizedKVCache(W, 64, 4, start, maintain) : new DelayedQuantizedKVCache(64, 4, start, maintain);
  const rows = lengths.map((length, index) => plainRow(rotating, length, seed + 2 * index));
  try { group.mergeRows(rows); } finally { for (const row of rows) row.dispose(); }
  return group;
};
const appendable = (cache: Cache, rows: number) => Array.from({ length: rows }, (_, row) => cache.plainKvReads!.appendable(row));
/** Attempt the actual plain read; true when it appended. */
const reads = (cache: Cache, rows: number, seed: number) => {
  using k = tensor(rows, 1, seed), v = tensor(rows, 1, seed + 1);
  try { for (const a of cache.updateAndFetch(k, v)) a.dispose(); return true; }
  catch (error) { expect(String(error)).toContain("mixed precision rows use their attention state"); return false; }
};
const kinds = (cache: Delayed) => cache.rowOffsets.map((_, row) => { const r = cache.extractRow(row); try { return r.constructor.name; } finally { r.dispose(); } });

for (const rotating of [false, true]) for (const start of [0, 3, 6]) for (const lengths of [[2], [5], [2, 6], [3, 3], [1, 4, 7]]) for (const prefilling of [false, true])
test(`${rotating ? "rotating" : "full"} start ${start}, rows ${lengths}${prefilling ? ", prefilling" : ""}: the query predicts the plain read`, () => {
  const maintain = createKvMaintenance({ kvBits: 4, kvGroupSize: 64, quantizedKvStart: start });
  const probe = delayed(rotating, start, maintain, lengths, 11), attempt = delayed(rotating, start, maintain, lengths, 11);
  try {
    if (prefilling) { probe.beginPrefill(); attempt.beginPrefill(); }
    const predicted = appendable(probe, lengths.length);
    const offsets = [...attempt.rowOffsets];
    // Asking is pure: nothing about the probe changed.
    expect(kinds(probe)).toEqual(lengths.map(() => rotating ? "RotatingKVCache" : "KVCache"));
    expect(reads(attempt, lengths.length, 20)).toBe(predicted.every(Boolean));
    if (predicted.every(Boolean)) expect(attempt.rowOffsets).toEqual(offsets.map(o => o + 1));
    else {
      // No row appended; exactly the rows the query refused were converted by the maintenance.
      expect(attempt.rowOffsets).toEqual(offsets);
      expect(kinds(attempt).map(kind => kind === "RotatingKVCache" || kind === "KVCache")).toEqual(predicted);
    }
  } finally { if (prefilling) { probe.endPrefill(); attempt.endPrefill(); } probe.dispose(); attempt.dispose(); }
});

test("an empty prepared row never converts, even from start 0", () => {
  for (const rotating of [false, true]) {
    const maintain = createKvMaintenance({ kvBits: 4, kvGroupSize: 64, quantizedKvStart: 0 });
    const group = rotating ? new DelayedRotatingQuantizedKVCache(W, 64, 4, 0, maintain) : new DelayedQuantizedKVCache(64, 4, 0, maintain);
    try {
      group.preparePrefill({ lengths: [2, 2] });
      expect(appendable(group, 2)).toEqual([true, true]);
      expect(reads(group, 2, 30)).toBe(true);
      // Now populated: the next append's maintenance converts both.
      expect(appendable(group, 2)).toEqual([false, false]);
      expect(reads(group, 2, 32)).toBe(false);
    } finally { group.dispose(); }
  }
});

test("per-layer policy: configured layers answer through their own maintenance, unconfigured ones stay plain", () => {
  const maintain = createKvMaintenance({ kvConfig: [{ layerIdx: 0, bits: 4, groupSize: 64 }], quantizedKvStart: 3 });
  const caches = [plainRow(false, 5, 40), plainRow(true, 5, 42), plainRow(false, 2, 44)];
  try {
    expect(maintain.converts!(caches[0]!, 0)).toBe(true);
    expect(maintain.converts!(caches[1]!, 1)).toBe(false);   // not in the policy
    maintain.preparePrefill!(caches);
    expect(caches[0]).toBeInstanceOf(DelayedQuantizedKVCache);
    expect(caches[1]).toBeInstanceOf(RotatingKVCache);
    expect(caches.map(cache => cache.plainKvReads!.appendable(0))).toEqual([false, true, true]);
  } finally { for (const cache of caches) cache.dispose(); }
});

test("adoption and filtering: the query follows the rows each cache currently holds", () => {
  for (const rotating of [false, true]) {
    const maintain = createKvMaintenance({ kvBits: 4, kvGroupSize: 64, quantizedKvStart: 5 });
    const solo = [plainRow(rotating, 3, 50)];
    try {
      maintain.prepareBatch!(solo);   // adopt one row
      const adopted = solo[0] as Delayed;
      expect(appendable(adopted, 1)).toEqual([true]);
      expect(reads(adopted, 1, 52)).toBe(true);
      expect(reads(adopted, 1, 54)).toBe(true);
      expect(adopted.rowOffsets).toEqual([5]);
      expect(appendable(adopted, 1)).toEqual([false]);
    } finally { for (const cache of solo) cache.dispose(); }
    for (const [keep, expected] of [[[1], [false]], [[0], [true]], [[1, 0], [false, true]]] as const) {
      const group = delayed(rotating, 5, maintain, [2, 6], 60);
      try {
        expect(appendable(group, 2)).toEqual([true, false]);
        group.filterRows([...keep]);
        expect(appendable(group, keep.length)).toEqual([...expected]);
        expect(reads(group, keep.length, 62)).toBe(expected.every(Boolean));
      } finally { group.dispose(); }
    }
  }
});

test("prefill deferral lasts until the row's prefill commits", () => {
  for (const rotating of [false, true]) {
    const maintain = createKvMaintenance({ kvBits: 4, kvGroupSize: 64, quantizedKvStart: 3 });
    const group = delayed(rotating, 3, maintain, [4, 2], 70);
    try {
      group.beginPrefill();
      expect(appendable(group, 2)).toEqual([true, true]);
      group.commitPrefill([0]);
      expect(appendable(group, 2)).toEqual([false, true]);
      expect(reads(group, 2, 72)).toBe(false);
    } finally { group.endPrefill(); group.dispose(); }
  }
});

test("converted and packed storage is never plain-readable", () => {
  for (const rotating of [false, true]) {
    const maintain = createKvMaintenance({ kvBits: 4, kvGroupSize: 64, quantizedKvStart: 2 });
    const group = delayed(rotating, 2, maintain, [3, 5], 80);
    try {
      using k = tensor(2, 1, 81), v = tensor(2, 1, 82);
      group.appendAndFetch(k, v).dispose();   // converts both rows and packs them
      expect(kinds(group).every(kind => kind.includes("Quantized"))).toBe(true);
      expect(appendable(group, 2)).toEqual([false, false]);
      expect(reads(group, 2, 83)).toBe(false);
    } finally { group.dispose(); }
  }
});

test("arbitrary maintenance: a callback that cannot answer never certifies, whatever it does", () => {
  for (const rotating of [false, true]) {
    // A no-op past start answers that it never converts, and the rows stay plain.
    const stays = delayed(rotating, 2, unchangedKv, [6, 7], 90);
    try {
      expect(appendable(stays, 2)).toEqual([true, true]);
      expect(reads(stays, 2, 91)).toBe(true);
      expect(kinds(stays).every(kind => kind === "RotatingKVCache" || kind === "KVCache")).toBe(true);
    } finally { stays.dispose(); }
    // The same no-op as a bare callback cannot answer: no capability.
    const bare = delayed(rotating, 2, () => {}, [6, 7], 92);
    try { expect(bare.plainKvReads).toBeUndefined(); expect(reads(bare, 2, 93)).toBe(true); } finally { bare.dispose(); }
    // Early conversion by a custom callback (below its declared start), and
    // conversion only on the second call: neither can be certified, and the
    // plain read appends to no row once it converts.
    const eager = createKvMaintenance({ kvBits: 4, kvGroupSize: 64, quantizedKvStart: 1 });
    let calls = 0;
    for (const maintain of [(rows: Cache[]) => eager(rows), (rows: Cache[]) => { if (++calls >= 2) eager(rows); }]) {
      const group = delayed(rotating, 100, maintain, [2, 3], 94);
      try {
        expect(group.plainKvReads).toBeUndefined();
        const offsets = [...group.rowOffsets];
        const first = reads(group, 2, 95);
        if (first) offsets.forEach((_, row) => offsets[row]! += 1);
        expect(reads(group, 2, 97)).toBe(false);
        expect(group.rowOffsets).toEqual(offsets);
      } finally { group.dispose(); }
    }
  }
});

test("plain storage declares plain reads; encoded storage does not", () => {
  const plain: Cache[] = [new KVCache(), new RotatingKVCache(W), new BatchedKVCache(), new BatchedRotatingCache(W, [])];
  const encoded: Cache[] = [new QuantizedKVCache(64, 4), new RotatingQuantizedKVCache(W, 64, 4), new BatchedQuantizedKVCache(64, 4),
    new RotatingAffineLayout(W, 64, 4), new TurboQuantKVCache(8, 3),
    new DelayedTurboQuantKVCache(8, 3, 0, createKvMaintenance({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 }))];
  try {
    for (const cache of plain) expect(cache.plainKvReads?.appendable(0), cache.constructor.name).toBe(true);
    for (const cache of encoded) expect(cache.plainKvReads, cache.constructor.name).toBeUndefined();
    // The prefill cohort's rotating layout never converts, and says so.
    const layout = prefillCacheLayout(new RotatingKVCache(W));
    try { expect(layout).toBeInstanceOf(DelayedRotatingQuantizedKVCache); expect(layout.plainKvReads).toBeDefined(); }
    finally { layout.dispose(); }
  } finally { for (const cache of [...plain, ...encoded]) cache.dispose(); }
});
