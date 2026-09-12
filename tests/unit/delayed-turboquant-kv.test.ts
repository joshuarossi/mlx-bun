import { configureRuntime } from "../../src/runtime-config";
import { expect, test } from "bun:test";
import * as ops from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";
import type { MlxArray } from "../../src/mlx/array";
import { KVCache, TurboQuantKVCache, type Cache } from "../../src/model/gemma4-base";
import { DelayedTurboQuantKVCache } from "../../src/model/delayed-turboquant-kv";
import { createKvMaintenance } from "../../src/backends/mlx/kv-maintenance";
import { cloneKvCaches } from "../../src/kv-store";
import { unrotateValues } from "../../src/mlx/turboquant-ops";

function input(B: number, N: number, seed: number): MlxArray {
  using key = ops.randomKey(BigInt(seed));
  using data = ops.randomNormal([B, 2, N, 64], Dtype.float32, 0, 1, key);
  return data.astype(Dtype.bfloat16);
}
function plain(length: number): Cache {
  const row = new KVCache();
  using k = input(1, length, length); using v = input(1, length, length + 100);
  for (const a of row.updateAndFetch(k, v)) a.dispose();
  return row;
}
function equal(a: MlxArray, b: MlxArray) {
  using aa = ops.contiguous(a); using bb = ops.contiguous(b);
  expect(aa.shape).toEqual(bb.shape); expect(aa.dtype).toBe(bb.dtype);
  expect(Buffer.from(aa.rawBytesView()).equals(Buffer.from(bb.rawBytesView()))).toBe(true);
}
function stateEqual(a: Cache, b: Cache) {
  expect(a.signature()).toBe(b.signature()); expect(a.offset).toBe(b.offset);
  expect(a.minimumReusableOffset ?? 0).toBe(b.minimumReusableOffset ?? 0);
  const arrays = (c: Cache) => c instanceof KVCache ? c.temporalView() : c.state();
  const av = arrays(a), bv = arrays(b);
  try { expect(av.length).toBe(bv.length); for (let i = 0; i < av.length; i++) equal(av[i]!, bv[i]!); }
  finally { for (const array of [...av, ...bv]) array.dispose(); }
}
for (const fused of ["0", "1"]) test(`delayed TQ preserves exact row boundaries, values and retirement (fused=${fused})`, () => {
  const restore = configureRuntime({ MLX_BUN_TURBOQUANT_FUSED_DECODE: fused });
  const maintain = createKvMaintenance({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 5 });
  let reference = [plain(3), plain(6)];
  const copies = cloneKvCaches(reference);
  let group = new DelayedTurboQuantKVCache(8, 3, 5, maintain);
  group.mergeRows(copies); copies.forEach(c => c.dispose());
  let sawMixed = false, sawPacked = false;
  try {
    for (let step = 0; step < 7; step++) {
      if (step === 2 || step === 3) {
        const keep = step === 2 ? [1, 0] : [1];
        group.filterRows(keep);
        reference.forEach((c, index) => { if (!keep.includes(index)) c.dispose(); });
        reference = keep.map(index => reference[index]!);
      }
      if (step === 4) {
        const fresh = plain(2), joined = group.makeEmptyBatch();
        joined.mergeRows([group, fresh]); group.dispose(); group = joined;
        reference.push(fresh);
      }
      const offsets = reference.map(c => c.offset);
      maintain(reference);
      const rotated = reference.map(c => c instanceof TurboQuantKVCache);
      sawMixed ||= rotated.some(Boolean) && !rotated.every(Boolean);
      sawPacked ||= rotated.every(Boolean);
      for (let row = 0; row < reference.length; row++) expect(rotated[row]).toBe(offsets[row]! >= 5);
      using k = input(reference.length, 1, 1000 + step); using v = input(reference.length, 1, 2000 + step);
      using q = input(reference.length, 1, 3000 + step);
      const mask = group.makeMask(1, null);
      const [keys, values] = group.updateAndFetchDeferredV(k, v);
      const restore = group.captureValueTransform();
      const parts: [MlxArray, MlxArray][] = [];
      try {
        for (const [index, row] of reference.entries()) {
          using kr = k.slice([index, 0, 0, 0], [index + 1, 2, 1, 64]);
          using vr = v.slice([index, 0, 0, 0], [index + 1, 2, 1, 64]);
          parts.push(row.rotatedValueAttention
            ? row.rotatedValueAttention.updateAndFetchDeferredV(kr, vr) : row.updateAndFetch(kr, vr));
          const extracted = group.extractRow(index);
          try { stateEqual(extracted, row); } finally { extracted.dispose(); }
        }
        const padded = (field: 0 | 1) => {
          const width = keys.shape[2]!;
          const arrays = parts.map(part => {
            const a = part[field];
            using pad = ops.zeros([1, 2, width - a.shape[2]!, 64], a.dtype);
            return ops.concatAxis([pad, a], 2);
          });
          try { return ops.concatAxis(arrays, 0); } finally { arrays.forEach(a => a.dispose()); }
        };
        using expectedK = padded(0); using expectedV = padded(1);
        // Padding is masked; encoded zero-scale padding may decode to -0.
        // Every live fetched byte must still match each serial cache.
        for (let row = 0; row < reference.length; row++) {
          const start = keys.shape[2]! - reference[row]!.offset;
          for (const [actual, expected] of [[keys, expectedK], [values, expectedV]]) {
            using a = actual!.slice([row, 0, start, 0], [row + 1, 2, keys.shape[2]!, 64]);
            using b = expected!.slice([row, 0, start, 0], [row + 1, 2, keys.shape[2]!, 64]);
            equal(a, b);
          }
        }
        using attn = ops.sdpa(q, keys, values, 0.125, mask.mode, mask.arr);
        using actual = restore(attn);
        using expectedAttn = ops.sdpa(q, expectedK, expectedV, 0.125, mask.mode, mask.arr);
        const expectedRows = rotated.map((rotate, row) => {
          using slice = expectedAttn.slice([row, 0, 0, 0], [row + 1, 2, 1, 64]);
          return rotate ? unrotateValues(slice) : ops.contiguous(slice);
        });
        try { using expected = ops.concatAxis(expectedRows, 0); equal(actual, expected); }
        finally { expectedRows.forEach(a => a.dispose()); }
        // Captured transforms remain attached to the fetched state even when
        // subsequent filtering changes the cache's current row order.
        if (step === 6) { group.filterRows([1, 0]); using repeated = restore(attn); equal(actual, repeated); }
      } finally { keys.dispose(); values.dispose(); mask.arr?.dispose(); parts.flat().forEach(a => a.dispose()); }
    }
    expect(sawMixed).toBe(true); expect(sawPacked).toBe(true);
  } finally {
    group.dispose(); reference.forEach(c => c.dispose());
    restore();
  }
});

for (const fused of ["0", "1"]) test(`speculative delayed TQ converts committed history and rolls back unequal rows (fused=${fused})`, () => {
  const restore = configureRuntime({ MLX_BUN_TURBOQUANT_FUSED_DECODE: fused });
  const maintain = createKvMaintenance({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 5 });
  let reference = [plain(3), plain(6)];
  let group = new DelayedTurboQuantKVCache(8, 3, 5, maintain);
  group.mergeRows(reference);
  try {
    for (let round = 0; round < 5; round++) {
      if (round === 3) {
        group.filterRows([1, 0]); reference = [reference[1]!, reference[0]!];
        group.filterRows([1]); reference[0]!.dispose(); reference = [reference[1]!];
        const fresh = plain(2), joined = group.makeEmptyBatch();
        joined.mergeRows([group, fresh]); group.dispose(); group = joined; reference.push(fresh);
      }
      const before = reference.map(row => row.offset);
      const pads = [...group.leftPad];
      maintain(reference); group.specRoundBegin();
      expect(group.leftPad).toEqual(pads);
      using k = input(2, 4, 4000 + round); using v = input(2, 4, 5000 + round);
      for (const a of group.updateAndFetch(k, v)) a.dispose();
      for (let row = 0; row < 2; row++) {
        using kr = k.slice([row, 0, 0, 0], [row + 1, 2, 4, 64]);
        using vr = v.slice([row, 0, 0, 0], [row + 1, 2, 4, 64]);
        for (const a of reference[row]!.updateAndFetch(kr, vr)) a.dispose();
      }
      const keep = round === 0 ? [1, 2] : round === 1 ? [2, 1] : [4, 4];
      if (keep.every(n => n === 4)) group.specRoundCommit(); else group.specRoundRollback(keep);
      expect(group.leftPad).toEqual(pads);
      for (let row = 0; row < 2; row++) reference[row]!.trim(4 - keep[row]!);
      maintain(reference);
      for (let row = 0; row < 2; row++) {
        const extracted = group.extractRow(row);
        stateEqual(extracted, reference[row]!);
        expect(extracted.offset).toBe(before[row]! + keep[row]!);
        if (round === 0 && row === 0) expect(extracted).toBeInstanceOf(KVCache);
        if ((round === 1 || round === 2) && row === 0) expect(extracted.minimumReusableOffset).toBe(6);
        extracted.dispose();
      }
    }
  } finally {
    group.dispose(); reference.forEach(row => row.dispose());
    restore();
  }
});
