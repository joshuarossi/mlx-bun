import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";
import { KVCache, RotatingKVCache, QuantizedKVCache, RotatingQuantizedKVCache, disposeTriple, type Cache } from "../../src/model/gemma4-base";
import { BatchedKVCache } from "../../src/model/batched-kv";
import { SpeculativeRotatingKVCache } from "../../src/model/speculative-rotating-kv";
import { BatchedQuantizedKVCache } from "../../src/model/batched-quantized-kv";
import { SpeculativeRotatingAffineLayout } from "../../src/model/rotating-kv-layout";
import { readAssistantDonors } from "../../src/backends/mlx/assistant-target";

// Zero queries make attention the arithmetic mean of retained value columns.
// This detects leaked padding/rejected tokens independently of model logits.
test("assistant donor attention follows row validity through rejection, wrap and retirement", () => {
  for (const bits of [0, 4, 8]) for (const lengths of [[2, 7], [11, 19]]) {
    const dimensions = bits ? 64 : 32;
    const append = (cache: Cache, data: MlxArray) => {
      if (cache.quantizedAttention) {
        for (const plane of cache.quantizedAttention.updateAndFetchQuantized(data, data)) disposeTriple(plane);
      } else for (const array of cache.updateAndFetch(data, data)) array.dispose();
    };
    using resources = new DisposableStack();
    const sliding = bits ? new SpeculativeRotatingAffineLayout(8, 64, bits) : new SpeculativeRotatingKVCache(8);
    const full = bits ? new BatchedQuantizedKVCache(64, bits) : new BatchedKVCache();
    resources.defer(() => { sliding.dispose(); full.dispose(); });
    let histories = lengths.map((length, row) => Array.from({ length }, (_, i) => row * 100 + i + 1));
    for (const [target, rotating] of [[sliding, true], [full, false]] as const) {
      const sources = histories.map(values => {
        const cache = bits
          ? (rotating ? new RotatingQuantizedKVCache(8, 64, bits) : new QuantizedKVCache(64, bits))
          : (rotating ? new RotatingKVCache(8) : new KVCache());
        using data = MlxArray.fromFloat32(Float32Array.from(values.flatMap(value => Array(dimensions).fill(value))), [1,1,values.length,dimensions]);
        append(cache, data);
        return cache;
      });
      try { target.mergeRows(sources); } finally { for (const source of sources) source.dispose(); }
    }
    const verify = () => {
      const donors = readAssistantDonors(sliding,full);
      try {
        expect(donors.positions).toEqual(histories.map(history => history.length - 1));
        using query = ops.zeros([histories.length,2,1,dimensions],Dtype.float32);
        for (const [donor, count] of [[donors.full, Infinity], [donors.sliding, 8], [donors.sliding, 3]] as const) {
          using output = donor.attend(query,1,count === Infinity ? null : count);
          const values = output.toFloat32();
          for (let row = 0; row < histories.length; row++) {
            const retained = histories[row]!.slice(-count);
            const mean = retained.reduce((sum,value) => sum + value,0) / retained.length;
            for (let i = 0; i < dimensions * 2; i++) expect(values[row * dimensions * 2 + i]!).toBeCloseTo(mean,4);
          }
        }
      } finally { donors.dispose(); }
    };
    verify();
    for (let round = 0; round < 5; round++) {
      const appended = histories.map((history,row) => Array.from({length:4},(_,i) => row * 100 + history.length + i + 1));
      using data = MlxArray.fromFloat32(Float32Array.from(appended.flatMap(row => row.flatMap(value => Array(dimensions).fill(value)))), [2,1,4,dimensions]);
      for (const cache of [sliding,full]) {
        cache.specRoundBegin();
        append(cache, data);
        cache.specRoundRollback([1,3]);
      }
      histories.forEach((history,row) => history.push(...appended[row]!.slice(0,row ? 3 : 1)));
      verify();
    }
    sliding.filterRows([1]); full.filterRows([1]); histories = [histories[1]!]; verify();
  }
});

import { TurboQuantKVCache, type KvDonorAttention } from "../../src/model/gemma4-base";
import { BatchedTurboQuantKVCache } from "../../src/model/batched-turboquant-kv";
import { DelayedTurboQuantKVCache } from "../../src/model/delayed-turboquant-kv";
import { createKvMaintenance } from "../../src/backends/mlx/kv-maintenance";

function donorData(B: number, N: number, seed: number): MlxArray {
  using values = MlxArray.fromFloat32(Float32Array.from({ length: B * N * 64 }, (_, i) =>
    ((i * 7 + seed) % 113 - 56) / 16), [B, 1, N, 64]);
  return values.astype(Dtype.bfloat16);
}
function exactDonorArray(actual: MlxArray, expected: MlxArray): void {
  using a = ops.contiguous(actual), b = ops.contiguous(expected);
  expect(a.shape).toEqual(b.shape); expect(a.dtype).toBe(b.dtype);
  expect(Buffer.from(a.rawBytesView())).toEqual(Buffer.from(b.rawBytesView()));
}
function encodedDonorState(cache: Cache): string[] {
  const state = cache.state();
  try { return state.map(array => { using copy = ops.contiguous(array); return Buffer.from(copy.rawBytesView()).toString("hex"); }); }
  finally { if (cache.stateNeedsDispose) for (const array of state) array.dispose(); }
}
function donorMask(width: number, starts: readonly number[], ends: readonly number[]): MlxArray {
  using mask = MlxArray.fromFloat32(Float32Array.from(starts.flatMap((start, row) =>
    Array.from({ length: width }, (_, column) => column < start || column >= ends[row]! ? -1e9 : 0))), [starts.length, 1, 1, width]);
  return mask.astype(Dtype.bfloat16);
}

for (const fused of ["0", "1"]) for (const [kBits, vBits] of [[8, 3], [4, 2]]) {
  test(`TQ donor snapshots preserve decoded-value arithmetic and own their state (${kBits}/${vBits}, fused=${fused})`, () => {
    const previous = process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE;
    process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE = fused;
    const solo = new TurboQuantKVCache(kBits!, vBits!);
    let donor: KvDonorAttention | undefined;
    let keys: MlxArray | undefined, values: MlxArray | undefined;
    try {
      using k = donorData(1, 7, 3), v = donorData(1, 7, 19), q = donorData(1, 1, 41);
      [keys, values] = solo.updateAndFetch(k, v);
      const before = encodedDonorState(solo);
      donor = solo.captureDonorAttention();
      expect(encodedDonorState(solo)).toEqual(before);
      expect(solo.offset).toBe(7);
      expect(donor.offsets).toEqual([7]); expect(donor.starts).toEqual([0]); expect(donor.ends).toEqual([7]);
      // Read views outlive the cache and retain eager decoded-V arithmetic.
      solo.dispose();
      using expected = ops.sdpa(q, keys, values, 0.125, "", null);
      using actual = donor.attend(q, 0.125, { mode: "", arr: null });
      exactDonorArray(actual, expected);
    } finally {
      donor?.dispose(); keys?.dispose(); values?.dispose(); solo.dispose();
      if (previous === undefined) delete process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE;
      else process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE = previous;
    }
  });

  test(`packed TQ donors exclude prefill padding and rejected suffixes (${kBits}/${vBits}, fused=${fused})`, () => {
    const previous = process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE;
    process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE = fused;
    const cache = new BatchedTurboQuantKVCache(kBits!, vBits!);
    let snapshot: KvDonorAttention | undefined;
    let keys: MlxArray | undefined, values: MlxArray | undefined;
    try {
      cache.preparePrefill({ lengths: [3, 5], rightPadding: [2, 0] });
      using k = donorData(2, 5, 7), v = donorData(2, 5, 23), q = donorData(2, 1, 47);
      [keys, values] = cache.updateAndFetch(k, v);
      snapshot = cache.captureDonorAttention();
      expect(snapshot.offsets).toEqual([3, 5]); expect(snapshot.starts).toEqual([0, 0]); expect(snapshot.ends).toEqual([3, 5]);
      using mask = donorMask(5, [0, 0], [3, 5]);
      using expected = ops.sdpa(q, keys, values, 0.125, "array", mask);
      cache.finalizePrefill(); cache.filterRows([1, 0]);
      using actual = snapshot.attend(q, 0.125, { mode: "array", arr: mask });
      exactDonorArray(actual, expected);
      snapshot.dispose(); snapshot = undefined; keys.dispose(); values.dispose(); keys = values = undefined;
      expect(cache.rowOffsets).toEqual([5, 3]); expect(cache.leftPad).toEqual([0, 2]);
      cache.specRoundBegin();
      using nk = donorData(2, 4, 31), nv = donorData(2, 4, 61);
      [keys, values] = cache.updateAndFetch(nk, nv);
      cache.specRoundRollback([1, 3]); // Same physical end, unequal logical positions.
      const before = encodedDonorState(cache);
      snapshot = cache.captureDonorAttention();
      expect(encodedDonorState(cache)).toEqual(before);
      expect(snapshot.offsets).toEqual([6, 6]); expect(snapshot.starts).toEqual([0, 2]); expect(snapshot.ends).toEqual([6, 8]);
      const donors = readAssistantDonors(cache, cache);
      try {
        expect(donors.positions).toEqual([5, 5]);
        // Expected arithmetic uses the original verification rectangle; right
        // columns rejected by the transaction are masked, never averaged in.
        using expectedKeys = keys.slice([0, 0, 0, 0], [2, 1, 8, 64]);
        using expectedValues = values.slice([0, 0, 0, 0], [2, 1, 8, 64]);
        using expectedMask = donorMask(8, [0, 2], [6, 8]);
        using reference = ops.sdpa(q, expectedKeys, expectedValues, 0.125, "array", expectedMask);
        using result = donors.full.attend(q, 0.125, null);
        exactDonorArray(result, reference);
      } finally { donors.dispose(); }
      cache.filterRows([1]); cache.dispose();
      using capturedMask = donorMask(snapshot.width, [0, 2], [6, 8]);
      using kept = snapshot.attend(q, 0.125, { mode: "array", arr: capturedMask });
      // The snapshot still contains both rows after retirement/disposal.
      expect(kept.shape).toEqual([2, 1, 1, 64]);
    } finally {
      snapshot?.dispose(); keys?.dispose(); values?.dispose(); cache.dispose();
      if (previous === undefined) delete process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE;
      else process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE = previous;
    }
  });
}

for (const fused of ["0", "1"]) test(`delayed donor capture neither converts nor advances padded rows (fused=${fused})`, () => {
  const previous = process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE;
  process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE = fused;
  const maintain = createKvMaintenance({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 4 });
  const cache = new DelayedTurboQuantKVCache(8, 3, 4, maintain);
  let mixed: KvDonorAttention | undefined, reference: MlxArray | undefined;
  try {
    cache.beginPrefill(); cache.preparePrefill({ lengths: [3, 5], rightPadding: [2, 0] });
    using k = donorData(2, 5, 71), v = donorData(2, 5, 79), q = donorData(2, 1, 83);
    for (const a of cache.updateAndFetch(k, v)) a.dispose();
    cache.commitPrefill([0, 1]);
    const before = encodedDonorState(cache);
    mixed = cache.captureDonorAttention();
    expect(mixed.offsets).toEqual([3, 5]); expect(mixed.starts).toEqual([0, 0]); expect(mixed.ends).toEqual([3, 5]);
    expect(encodedDonorState(cache)).toEqual(before);
    const views = cache.captureDonorRows();
    try {
      using mask = donorMask(5, [0, 0], [3, 5]);
      reference = ops.sdpa(q, views.keys, views.values, 0.125, "array", mask);
      // The first row retains plain values; the second has already converted.
      using plain = v.slice([0, 0, 0, 0], [1, 1, 3, 64]);
      using fetched = views.values.slice([0, 0, 0, 0], [1, 1, 3, 64]);
      exactDonorArray(fetched, plain);
    } finally { views.keys.dispose(); views.values.dispose(); }
    cache.finalizePrefill(); cache.endPrefill();
    cache.specRoundBegin();
    using nk = donorData(2, 1, 89), nv = donorData(2, 1, 97);
    for (const a of cache.updateAndFetch(nk, nv)) a.dispose();
    cache.specRoundCommit();
    for (let row = 0; row < 2; row++) {
      const saved = cache.extractRow(row);
      try { expect(saved).toBeInstanceOf(TurboQuantKVCache); expect(saved.minimumReusableOffset).toBe(row ? 5 : 4); }
      finally { saved.dispose(); }
    }
    cache.filterRows([1, 0]); cache.filterRows([1]);
    const fresh = new KVCache(), joined = cache.makeEmptyBatch();
    try {
      using fk = donorData(1, 2, 101), fv = donorData(1, 2, 103);
      for (const a of fresh.updateAndFetch(fk, fv)) a.dispose();
      joined.mergeRows([cache, fresh]);
      const admitted = joined.captureDonorRows();
      try {
        expect(admitted.offsets).toEqual([4, 2]);
        expect(admitted.starts).toEqual([0, 2]); expect(admitted.ends).toEqual([4, 4]);
        using actualFresh = admitted.values.slice([1, 0, 2, 0], [2, 1, 4, 64]);
        exactDonorArray(actualFresh, fv);
      } finally { admitted.keys.dispose(); admitted.values.dispose(); }
    } finally { fresh.dispose(); joined.dispose(); }
    cache.dispose();
    using mask = donorMask(5, [0, 0], [3, 5]);
    using result = mixed.attend(q, 0.125, { mode: "array", arr: mask });
    exactDonorArray(result, reference);
  } finally {
    mixed?.dispose(); reference?.dispose(); cache.dispose();
    if (previous === undefined) delete process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE;
    else process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE = previous;
  }
});

import { BatchedRotatingCache } from "../../src/model/batched-rotating";
import { BatchedRotatingQuantCache } from "../../src/model/batched-rotating-quant";
import { captureRotatingDonorAttention } from "../../src/model/rotating-kv-donor";

for (const bits of [0, 4, 8]) for (const window of [4, 8])
  test(`rotating donor owns pending right-prefill validity (bits=${bits}, window=${window})`, () => {
    const ring = bits ? BatchedRotatingQuantCache.empty(window, 64, bits, [0, 0])
      : new BatchedRotatingCache(window, [0, 0]);
    let donor: KvDonorAttention | undefined;
    try {
      ring.preparePrefill({ lengths: [3, 5], rightPadding: [2, 0] });
      // Large padded values make a leaked suffix unambiguous. Constant feature
      // vectors also give an independent mean oracle for affine storage.
      using data = MlxArray.fromFloat32(Float32Array.from(
        [1, 2, 3, 900, 901, 11, 12, 13, 14, 15].flatMap(value => Array(64).fill(value))), [2, 1, 5, 64]);
      if (ring instanceof BatchedRotatingQuantCache) {
        for (const triple of ring.updateAndFetchQuantized(data, data)) disposeTriple(triple);
      } else for (const array of ring.updateAndFetch(data, data)) array.dispose();
      const before = ring.positionSnapshot;
      donor = captureRotatingDonorAttention(ring);
      expect(ring.positionSnapshot).toEqual(before);
      expect(donor.offsets).toEqual([3, 5]);
      expect(donor.starts).toEqual([0, window === 4 ? 1 : 0]);
      expect(donor.ends).toEqual([3, 5]);
      expect(donor.width).toBe(5);
      // Capture owns its chronological view and validity even after the live
      // ring rolls padding, changes membership, and releases its storage.
      ring.finalizePrefill(); ring.filterRows([1, 0]); ring.dispose();
      using query = ops.zeros([2, 2, 1, 64], Dtype.float32);
      using mask = donorMask(donor.width, donor.starts, donor.ends);
      using actual = donor.attend(query, 1, { mode: "array", arr: mask });
      const result = actual.toFloat32();
      for (let i = 0; i < 128; i++) expect(result[i]!).toBeCloseTo(2, 4);
      for (let i = 128; i < 256; i++) expect(result[i]!).toBeCloseTo(window === 4 ? 13.5 : 13, 4);
    } finally { donor?.dispose(); ring.dispose(); }
  });

import { combineKvDonorAttention } from "../../src/model/kv-attention-view";

for (const bits of [4, 8]) test(`mixed rotating donor rows retain one padded mask rectangle (bits=${bits})`, () => {
  const rings = [new BatchedRotatingCache(4, [0]), BatchedRotatingQuantCache.empty(4, 64, bits, [0])];
  const views: KvDonorAttention[] = [];
  let combined: KvDonorAttention | undefined;
  try {
    for (const [row, ring] of rings.entries()) {
      const length = row ? 5 : 3;
      // Both physical rows belong to the same padded batch, including the
      // sibling whose own right-padding count is zero.
      ring.preparePrefill({ lengths: [length], rightPadding: [5 - length] }, true);
      using data = MlxArray.fromFloat32(Float32Array.from(
        (row ? [11, 12, 13, 14, 15] : [1, 2, 3, 900, 901]).flatMap(value => Array(64).fill(value))), [1, 1, 5, 64]);
      if (ring instanceof BatchedRotatingQuantCache) {
        for (const triple of ring.updateAndFetchQuantized(data, data)) disposeTriple(triple);
      } else for (const array of ring.updateAndFetch(data, data)) array.dispose();
      views.push(captureRotatingDonorAttention(ring));
    }
    expect(views.map(view => view.width)).toEqual([5, 5]);
    combined = combineKvDonorAttention(views);
    expect(combined.offsets).toEqual([3, 5]);
    expect(combined.starts).toEqual([0, 1]); expect(combined.ends).toEqual([3, 5]);
    for (const ring of rings) ring.dispose();
    using query = ops.zeros([2, 2, 1, 64], Dtype.float32);
    using mask = donorMask(5, combined.starts, combined.ends);
    using actual = combined.attend(query, 1, { mode: "array", arr: mask });
    const result = actual.toFloat32();
    for (let i = 0; i < 128; i++) expect(result[i]!).toBeCloseTo(2, 4);
    for (let i = 128; i < 256; i++) expect(result[i]!).toBeCloseTo(13.5, 4);
  } finally {
    if (combined) combined.dispose(); else for (const view of views) view.dispose();
    for (const ring of rings) ring.dispose();
  }
});
