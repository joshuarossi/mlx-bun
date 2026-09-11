import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { QuantizedKVCache, disposeTriple } from "../../src/model/gemma4-base";
import { BatchedQuantizedKVCache } from "../../src/model/batched-quantized-kv";
import { bindRowCacheRollback } from "../../src/backends/mlx/rollback";

function tensor(rows: number[][], width: number): MlxArray {
  return MlxArray.fromFloat32(Float32Array.from(rows.flatMap(tokens => [0, 1].flatMap(head =>
    tokens.flatMap(token => Array.from({ length: width }, (_, column) =>
      Math.sin(token * 7 + head * 3 + column * 0.13) * 3))))), [rows.length, 2, rows[0]!.length, width]);
}
function append(cache: QuantizedKVCache | BatchedQuantizedKVCache, rows: number[][]): void {
  using k = tensor(rows, 128), v = tensor(rows, 64);
  for (const triple of cache.updateAndFetchQuantized(k, v)) disposeTriple(triple);
}
function cache(tokens: number[], bits: number): QuantizedKVCache {
  const result = new QuantizedKVCache(32, bits); if (tokens.length) append(result, [tokens]); return result;
}
function snapshot(cache: QuantizedKVCache): unknown {
  if (!cache.offset) return [];
  const triples = cache.temporalView();
  try { return triples.flatMap(triple => [triple.packed, triple.scales, triple.biases].map(array => {
    using flat = ops.contiguous(array); return { shape: array.shape, bytes: new Uint8Array(flat.rawBytesView()) };
  })); } finally { for (const triple of triples) disposeTriple(triple); }
}
function expectRow(batch: BatchedQuantizedKVCache, row: number, tokens: number[]): void {
  const actual = batch.extractRow(row), expected = cache(tokens, batch.bits);
  try { expect(actual.offset).toBe(tokens.length); expect(snapshot(actual)).toEqual(snapshot(expected)); }
  finally { actual.dispose(); expected.dispose(); }
}

test("affine KV retains different accepted prefixes without rewriting packed state", () => {
  for (const bits of [4, 8]) {
    const a = cache([1, 2, 3], bits), b = cache([11, 12, 13, 14, 15, 16], bits);
    const batch = new BatchedQuantizedKVCache(32, bits);
    const original = [snapshot(a), snapshot(b)];
    try {
      batch.mergeRows([a, b]);
      const tx = bindRowCacheRollback([batch], 2); tx.begin(2);
      append(batch, [[4, 5, 6], [17, 18, 19]]);
      const handles = batch.state().map(array => array.handle);
      tx.resolve([0, 2]);
      expect(batch.state().map(array => array.handle)).toEqual(handles);
      expect(batch.rowOffsets).toEqual([4, 9]);
      expect(batch.ropeOffsetArr!.toIntTokens()).toEqual([4, 9]);
      const mask = batch.makeMask(2, null);
      try {
        expect(mask.arr!.shape).toEqual([2, 1, 2, 11]);
        expect([...mask.arr!.toFloat32()]).toEqual([7, 9].flatMap((end, row) =>
          [0, 1].flatMap(query => Array.from({ length: 11 }, (_, key) =>
            Number(key >= batch.leftPad[row]! && key <= end + query)))));
      } finally { mask.arr?.dispose(); }
      append(batch, [[40, 41], [50, 51]]);
      expectRow(batch, 0, [1, 2, 3, 4, 40, 41]);
      expectRow(batch, 1, [11, 12, 13, 14, 15, 16, 17, 18, 19, 50, 51]);
      expect([snapshot(a), snapshot(b)]).toEqual(original);
      const c = cache([101, 102, 103, 104, 105], bits);
      try { batch.mergeRows([batch, c]); } finally { c.dispose(); }
      batch.filterRows([2, 0]);
      const tail = Array.from({ length: 300 }, (_, i) => i + 200);
      append(batch, [tail, tail]);
      expectRow(batch, 0, [101, 102, 103, 104, 105, ...tail]);
      expectRow(batch, 1, [1, 2, 3, 4, 40, 41, ...tail]);
    } finally { a.dispose(); b.dispose(); batch.dispose(); }
  }
});

test("singleton affine storage preserves capacity and empty rows can join and extract", () => {
  const source = cache([1, 2], 4), empty = cache([], 4), batch = new BatchedQuantizedKVCache(32, 4);
  try {
    batch.mergeRows([source]);
    expect(batch.state().map(array => array.shape)).toEqual(source.state().map(array => array.shape));
    expect(batch.ropeOffsetArr).toBeUndefined();
    expect(batch.makeMask(2, null)).toEqual({ mode: "causal", arr: null });
    batch.mergeRows([batch, empty]);
    expectRow(batch, 1, []);
    append(batch, [[3], [11]]);
    expectRow(batch, 0, [1, 2, 3]); expectRow(batch, 1, [11]);
    batch.filterRows([1]); append(batch, [[12]]); expectRow(batch, 0, [11, 12]);
    expect(batch.bytesPerToken()).toBe(source.bytesPerToken());
  } finally { source.dispose(); empty.dispose(); batch.dispose(); }
});
