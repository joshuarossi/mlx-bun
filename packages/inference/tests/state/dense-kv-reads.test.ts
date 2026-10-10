// Dense KV reads (`updateAndFetch` returning keys and values as arrays) are
// certified per row by the storage that can answer and by what its own
// transition leaves. For delayed affine KV the query is pure and must predict
// the actual plain read: it holds exactly when that read appends. TurboQuant
// storage decodes on read, so its rows stay dense-readable through conversion.
// A cache without the capability is not certified, whatever a direct read of
// it would do.
import { unfusedAffineKernels } from "../../src/state/affine-attention";
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
import { BatchedTurboQuantKVCache } from "../../src/state/batched-turboquant-kv";
import { DelayedQuantizedKVCache } from "../../src/state/delayed-quantized-kv";
import { DelayedRotatingQuantizedKVCache } from "../../src/state/delayed-rotating-quantized-kv";
import { DelayedTurboQuantKVCache } from "../../src/state/delayed-turboquant-kv";
import { createKvMaintenance } from "../../src/state/kv-maintenance";
import { turboQuantFusedDecode } from "../../src/state/turboquant-codec";
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
const delayed = (rotating: boolean, start: number, lengths: number[], seed: number): Delayed => {
  const group = rotating ? new DelayedRotatingQuantizedKVCache(W, 64, 4, start) : new DelayedQuantizedKVCache(64, 4, start);
  const rows = lengths.map((length, index) => plainRow(rotating, length, seed + 2 * index));
  try { group.mergeRows(rows); } finally { for (const row of rows) row.dispose(); }
  return group;
};
const appendable = (cache: Cache, rows: number) => Array.from({ length: rows }, (_, row) => cache.denseKvReads!.appendable(row));
/** Attempt the actual plain read; true when it appended. */
const reads = (cache: Cache, rows: number, seed: number) => {
  using k = tensor(rows, 1, seed), v = tensor(rows, 1, seed + 1);
  try { for (const a of cache.updateAndFetch(k, v)) a.dispose(); return true; }
  catch (error) { expect(String(error)).toContain("mixed precision rows use their attention state"); return false; }
};
const kinds = (cache: Delayed) => cache.rowOffsets.map((_, row) => { const r = cache.extractRow(row); try { return r.constructor.name; } finally { r.dispose(); } });

for (const rotating of [false, true]) for (const start of [0, 3, 6]) for (const lengths of [[2], [5], [2, 6], [3, 3], [1, 4, 7]]) for (const prefilling of [false, true])
test(`${rotating ? "rotating" : "full"} start ${start}, rows ${lengths}${prefilling ? ", prefilling" : ""}: the query predicts the plain read`, () => {
  const probe = delayed(rotating, start, lengths, 11), attempt = delayed(rotating, start, lengths, 11);
  try {
    if (prefilling) { probe.beginPrefill(); attempt.beginPrefill(); }
    const predicted = appendable(probe, lengths.length);
    const offsets = [...attempt.rowOffsets];
    // Asking is pure: nothing about the probe changed.
    expect(kinds(probe)).toEqual(lengths.map(() => rotating ? "RotatingKVCache" : "KVCache"));
    expect(reads(attempt, lengths.length, 20)).toBe(predicted.every(Boolean));
    if (predicted.every(Boolean)) expect(attempt.rowOffsets).toEqual(offsets.map(o => o + 1));
    else {
      // No row appended; exactly the rows the query refused were converted by the transition.
      expect(attempt.rowOffsets).toEqual(offsets);
      expect(kinds(attempt).map(kind => kind === "RotatingKVCache" || kind === "KVCache")).toEqual(predicted);
    }
  } finally { if (prefilling) { probe.endPrefill(); attempt.endPrefill(); } probe.dispose(); attempt.dispose(); }
});

test("an empty prepared row never converts, even from start 0", () => {
  for (const rotating of [false, true]) {
    const group = rotating ? new DelayedRotatingQuantizedKVCache(W, 64, 4, 0) : new DelayedQuantizedKVCache(64, 4, 0);
    try {
      group.preparePrefill({ lengths: [2, 2] });
      expect(appendable(group, 2)).toEqual([true, true]);
      expect(reads(group, 2, 30)).toBe(true);
      // Now populated: the next append's transition converts both.
      expect(appendable(group, 2)).toEqual([false, false]);
      expect(reads(group, 2, 32)).toBe(false);
    } finally { group.dispose(); }
  }
});

test("per-layer policy: configured layers answer through their own scheme, unconfigured ones stay plain", () => {
  const maintain = createKvMaintenance({ kvConfig: [{ layerIdx: 0, bits: 4, groupSize: 64 }], quantizedKvStart: 3 });
  const caches = [plainRow(false, 5, 40), plainRow(true, 5, 42), plainRow(false, 2, 44)];
  try {
    expect(maintain.keepsDenseReads!(caches[0]!, 0)).toBe(false);
    expect(maintain.keepsDenseReads!(caches[1]!, 1)).toBe(true);   // not in the policy
    maintain.preparePrefill!(caches);
    expect(caches[0]).toBeInstanceOf(DelayedQuantizedKVCache);
    expect(caches[1]).toBeInstanceOf(RotatingKVCache);
    expect(caches.map(cache => cache.denseKvReads!.appendable(0))).toEqual([false, true, true]);
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
      const group = delayed(rotating, 5, [2, 6], 60);
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
    const group = delayed(rotating, 3, [4, 2], 70);
    try {
      group.beginPrefill();
      expect(appendable(group, 2)).toEqual([true, true]);
      group.commitPrefill([0]);
      expect(appendable(group, 2)).toEqual([false, true]);
      expect(reads(group, 2, 72)).toBe(false);
    } finally { group.endPrefill(); group.dispose(); }
  }
});

test("converted and packed affine storage is never dense-readable", () => {
  for (const rotating of [false, true]) {
    const group = delayed(rotating, 2, [3, 5], 80);
    try {
      using k = tensor(2, 1, 81), v = tensor(2, 1, 82);
      group.appendAndFetch(k, v).dispose();   // converts both rows and packs them
      expect(kinds(group).every(kind => kind.includes("Quantized"))).toBe(true);
      expect(appendable(group, 2)).toEqual([false, false]);
      expect(reads(group, 2, 83)).toBe(false);
    } finally { group.dispose(); }
  }
});

test("a start the rows never reach keeps every row plain, and the capability is built once", () => {
  for (const rotating of [false, true]) {
    const stays = delayed(rotating, Infinity, [6, 7], 90);
    try {
      expect(stays.denseKvReads).toBe(stays.denseKvReads);
      expect(appendable(stays, 2)).toEqual([true, true]);
      expect(reads(stays, 2, 91)).toBe(true);
      expect(kinds(stays).every(kind => kind === "RotatingKVCache" || kind === "KVCache")).toBe(true);
    } finally { stays.dispose(); }
  }
});

test("plain storage and storage that decodes on read declare dense reads; affine storage does not", () => {
  const fused = turboQuantFusedDecode();
  const dense: Cache[] = [new KVCache(), new RotatingKVCache(W), new BatchedKVCache(), new BatchedRotatingCache(W, []),
    new TurboQuantKVCache(8, 3), new BatchedTurboQuantKVCache(8, 3),
    new DelayedTurboQuantKVCache(8, 3, 0, fused, new KVCache())];   // one real (empty) row: its row 0
  // Capability presence is the storage's declaration; appendability is asked of
  // an actual row. An empty delayed layout declares, but has no row 0 to append.
  const empty = new DelayedTurboQuantKVCache(8, 3, 0, fused);
  const encoded: Cache[] = [new QuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)), new RotatingQuantizedKVCache(W, 64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)), new BatchedQuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)),
    new RotatingAffineLayout(W, 64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16))];
  try {
    for (const cache of dense) expect(cache.denseKvReads?.appendable(0), cache.constructor.name).toBe(true);
    expect(empty.denseKvReads).toBeDefined();
    expect(empty.denseKvReads!.appendable(0)).toBe(false);
    for (const cache of encoded) expect(cache.denseKvReads, cache.constructor.name).toBeUndefined();
    // The prefill cohort's rotating layout never converts, and says so.
    const layout = prefillCacheLayout(new RotatingKVCache(W));
    try { expect(layout).toBeInstanceOf(DelayedRotatingQuantizedKVCache); expect(layout.denseKvReads).toBeDefined(); }
    finally { layout.dispose(); }
  } finally { for (const cache of [...dense, ...encoded, empty]) cache.dispose(); }
});

/** A dense read of `cache` for `rows` rows appending one position: its shapes and dtypes. */
const denseRead = (cache: Cache, rows: number, seed: number) => {
  using k = tensor(rows, 1, seed), v = tensor(rows, 1, seed + 1);
  const [keys, values] = cache.updateAndFetch(k, v);
  try { return [keys.shape, values.shape, keys.dtypeName, values.dtypeName]; } finally { keys.dispose(); values.dispose(); }
};

test("a TurboQuant conversion keeps dense reads: the converted entry declares them and reads its dequantized window", () => {
  const maintain = createKvMaintenance({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 3 });
  const caches = [plainRow(false, 5, 120), plainRow(true, 5, 122)];
  try {
    expect(caches.map((cache, index) => maintain.keepsDenseReads!(cache, index))).toEqual([true, true]);
    maintain(caches);
    expect(caches[0]).toBeInstanceOf(TurboQuantKVCache);   // a full layer past start converts
    expect(caches[1]).toBeInstanceOf(RotatingKVCache);     // a sliding layer stays plain
    expect(caches.map(cache => cache.denseKvReads?.appendable(0))).toEqual([true, true]);
    expect(denseRead(caches[0]!, 1, 124)).toEqual([[1, 2, 6, 64], [1, 2, 6, 64], "bfloat16", "bfloat16"]);
    expect(denseRead(caches[1]!, 1, 126)).toEqual([[1, 2, 6, 64], [1, 2, 6, 64], "bfloat16", "bfloat16"]);   // below its window
  } finally { for (const cache of caches) cache.dispose(); }
});

test("delayed TurboQuant rows stay dense-readable before, across and after conversion, and packed", () => {
  const group = new DelayedTurboQuantKVCache(8, 3, 4, turboQuantFusedDecode());
  const rows = [plainRow(false, 2, 130), plainRow(false, 5, 132)];
  try { group.mergeRows(rows); } finally { for (const row of rows) row.dispose(); }
  try {
    // Row 1 converts at the first append, row 0 at the third; then the rows pack.
    for (const [step, width] of [[0, 6], [1, 7], [2, 8]] as const) {
      expect(appendable(group, 2), `step ${step}`).toEqual([true, true]);
      expect(denseRead(group, 2, 134 + 2 * step)).toEqual([[2, 2, width, 64], [2, 2, width, 64], "bfloat16", "bfloat16"]);
    }
    expect(group.rowOffsets).toEqual([5, 8]);
    expect(group.rowOffsets.map((_, row) => { const r = group.extractRow(row); try { return r.constructor.name; } finally { r.dispose(); } }))
      .toEqual(["TurboQuantKVCache", "TurboQuantKVCache"]);
    expect(appendable(group, 2)).toEqual([true, true]);
  } finally { group.dispose(); }
});

test("prepared co-prefill rows answer through their current storage: padded full rows and aligned rotating rows", () => {
  // Row 0 (4 tokens) passes start 3 at the chunk's commit; row 1 (2 tokens) does not.
  const cases = [
    ["affine full", () => new DelayedQuantizedKVCache(64, 4, 3), [false, true]],
    ["affine rotating", () => new DelayedRotatingQuantizedKVCache(W, 64, 4, 3), [false, true]],
    ["TurboQuant full", () => new DelayedTurboQuantKVCache(8, 3, 3, turboQuantFusedDecode()), [true, true]],
  ] as const;
  for (const [label, make, converted] of cases) {
    const group: Cache & { beginPrefill(): void; endPrefill(): void; commitPrefill(rows: number[]): void;
      preparePrefill(padding: { lengths: number[]; rightPadding: number[] }): void; finalizePrefill(): void } = make();
    try {
      group.preparePrefill({ lengths: [4, 2], rightPadding: [0, 2] });   // the rows are now prepared owners
      group.beginPrefill();
      expect(appendable(group, 2), `${label}: prepared`).toEqual([true, true]);
      using k = tensor(2, 4, 160), v = tensor(2, 4, 161);
      for (const a of group.updateAndFetch(k, v)) a.dispose();
      expect(appendable(group, 2), `${label}: after the chunk`).toEqual([true, true]);   // transition deferred
      group.commitPrefill([0, 1]);
      expect(appendable(group, 2), `${label}: committed`).toEqual([...converted]);
      group.finalizePrefill(); group.endPrefill();
      expect(appendable(group, 2), `${label}: finalized`).toEqual([...converted]);
    } finally { group.dispose(); }
  }
});
