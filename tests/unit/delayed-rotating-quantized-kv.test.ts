import { test, expect } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";
import { RotatingKVCache, RotatingQuantizedKVCache, type Cache, type KvAttentionView } from "../../src/model/gemma4-base";
import { DelayedRotatingQuantizedKVCache } from "../../src/model/delayed-rotating-quantized-kv";
import { cloneKvCaches } from "../../src/kv-store";
import { createKvMaintenance } from "../../src/backends/mlx/kv-maintenance";
import { quantizedRowStorage } from "../../src/model/batched-row-storage";

const input = (row: number, offset: number, count: number): MlxArray => {
  using a = MlxArray.fromFloat32(Float32Array.from({ length: count * 64 }, (_, i) => ((row * 11 + offset * 7 + i) % 113 - 56) / 32), [1, 1, count, 64]);
  return a.astype(Dtype.bfloat16);
};
function append(cache: Cache, k: MlxArray, v: MlxArray): void {
  if (cache instanceof RotatingQuantizedKVCache) {
    const [keys, values] = cache.updateAndFetchQuantized(k, v);
    quantizedRowStorage.dispose(keys); quantizedRowStorage.dispose(values);
  } else { const [keys, values] = cache.updateAndFetch(k, v); keys.dispose(); values.dispose(); }
}
function logicalState(cache: Cache): { shape: readonly number[]; values: number[] }[] {
  const ring = cache as RotatingKVCache | RotatingQuantizedKVCache;
  return cache.state().map(a => {
    const len = a.shape[2]!, idx = ring.ringIdx;
    using first = a.slice([0, 0, 0, 0], [1, a.shape[1]!, idx, a.shape[3]!]);
    using tail = idx < cache.offset ? a.slice([0, 0, idx, 0], [1, a.shape[1]!, len, a.shape[3]!]) : null;
    using ordered = tail ? ops.concatAxis([tail, first], 2) : ops.contiguous(first);
    return { shape: [...ordered.shape], values: ordered.dtype === Dtype.uint32 ? [...ordered.toIntTokens()] : [...ordered.toFloat32()] };
  });
}

for (const bits of [4, 8]) for (const start of [5, 12]) for (const firstLength of [0, 3]) {
  test(`delayed rotating KV${bits} threshold ${start}, first row ${firstLength}: physical alignment, retirement, admission and captured ownership`, () => {
    const maintain = createKvMaintenance({ kvBits: bits, kvGroupSize: 64, quantizedKvStart: start });
    let refs: Cache[] = [new RotatingKVCache(8), new RotatingKVCache(8)];
    for (const [row, count] of [firstLength, 11].entries()) {
      if (count === 0) continue;
      using k = input(row, 0, count), v = input(row + 9, 0, count); append(refs[row]!, k, v);
    }
    maintain(refs);
    let batch = new DelayedRotatingQuantizedKVCache(8, 64, bits, start, maintain);
    batch.mergeRows(refs);
    let captured: KvAttentionView | undefined, capturedMask: import("../../src/model/gemma4-base").Mask | undefined;
    let capturedQ: MlxArray | undefined, capturedOutput: number[] | undefined;
    try {
      for (const [step, count] of [1, 2, 1, 3, 1, 2, 1, 1, 3, 4, 5].entries()) {
        if (step === 3) { batch.filterRows([1, 0]); refs.reverse(); }
        if (step === 5) {
          batch.filterRows([0]); refs[1]!.dispose(); refs = [refs[0]!];
          const joiner = new RotatingKVCache(8);
          using k = input(7, 0, 2), v = input(8, 0, 2); append(joiner, k, v);
          const merged = batch.makeEmptyBatch(); merged.mergeRows([batch, joiner]); batch.dispose(); batch = merged;
          refs.push(joiner);
        }
        maintain(refs);
        const keys = refs.map((row, i) => input(i, row.offset, count));
        const values = refs.map((row, i) => input(i + 9, row.offset, count));
        using k = ops.concatAxis(keys, 0), v = ops.concatAxis(values, 0);
        const mask = batch.makeMask(count, 8);
        const view = batch.appendAndFetch(k, v);
        try {
          using q = ops.contiguous(k);
          using output = view.attend(q, 0.125, mask);
          expect(output.shape).toEqual(q.shape);
          expect([...output.toFloat32()].every(Number.isFinite)).toBe(true);
          for (let row = 0; row < refs.length; row++) {
            append(refs[row]!, keys[row]!, values[row]!);
            const extracted = batch.extractRow(row);
            try {
              expect(extracted.offset).toBe(refs[row]!.offset);
              expect(extracted.minimumReusableOffset ?? 0).toBe(refs[row]!.minimumReusableOffset ?? 0);
              expect(logicalState(extracted)).toEqual(logicalState(refs[row]!));
            } finally { extracted.dispose(); }
          }
          if (step === 0) {
            captured = view; capturedMask = mask; capturedQ = ops.contiguous(q); capturedOutput = [...output.toFloat32()];
          }
        } finally {
          if (view !== captured) { view.dispose(); mask.arr?.dispose(); }
          for (const a of [...keys, ...values]) a.dispose();
        }
        batch.releaseRopeArr();
      }
      batch.dispose();
      using output = captured!.attend(capturedQ!, 0.125, capturedMask!);
      expect([...output.toFloat32()]).toEqual(capturedOutput!);
    } finally {
      batch.dispose(); for (const row of refs) row.dispose();
      captured?.dispose(); capturedMask?.arr?.dispose(); capturedQ?.dispose();
    }
  });
}

test("empty rotating groups can be cloned, merged and filled", () => {
  const maintain = createKvMaintenance({ kvBits: 4, quantizedKvStart: 5 });
  for (const quantized of [false, true]) {
    const rows = [0, 1].map(() => quantized ? new RotatingQuantizedKVCache(8, 64, 4) : new RotatingKVCache(8));
    const clones = cloneKvCaches(rows);
    const first = new DelayedRotatingQuantizedKVCache(8, 64, 4, 5, maintain);
    const second = first.makeEmptyBatch();
    try {
      first.mergeRows(clones); second.mergeRows([first]);
      using row = input(0, 0, 3), keys = ops.concatAxis([row, row], 0);
      const mask = second.makeMask(3, 8), view = second.appendAndFetch(keys, keys);
      try {
        using result = view.attend(keys, 0.125, mask);
        expect([...result.toFloat32()].every(Number.isFinite)).toBe(true);
        expect(second.rowOffsets).toEqual([3, 3]);
      } finally { view.dispose(); mask.arr?.dispose(); }
    } finally { first.dispose(); second.dispose(); for (const cache of [...rows, ...clones]) cache.dispose(); }
  }
});
