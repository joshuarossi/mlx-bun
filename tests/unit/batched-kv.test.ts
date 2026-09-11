import { expect, test } from "bun:test";
import * as ops from "../../src/mlx/ops";
import { MlxArray } from "../../src/mlx/array";
import { KVCache } from "../../src/model/gemma4-base";
import { bindRowCacheRollback } from "../../src/backends/mlx/rollback";
import { BatchedKVCache } from "../../src/model/batched-kv";

function tensor(rows: number[][], width = 3): MlxArray {
  const values = rows.flatMap(tokens => Array.from({ length: 2 }, (_, head) =>
    tokens.flatMap(token => Array.from({ length: width }, (_, column) => token * 100 + head * 10 + column))).flat());
  return MlxArray.fromFloat32(Float32Array.from(values), [rows.length, 2, rows[0]!.length, width]);
}
function cache(tokens: number[]): KVCache {
  const value = new KVCache(); value.restoreState(tensor([tokens]), tensor([tokens], 2), tokens.length); return value;
}
function append(batch: BatchedKVCache, rows: number[][]): void {
  using keys = tensor(rows), values = tensor(rows, 2);
  for (const view of batch.updateAndFetch(keys, values)) view.dispose();
}
function expectRow(batch: BatchedKVCache, row: number, tokens: number[]): void {
  const value = batch.extractRow(row);
  try {
    using expectedK = tensor([tokens]), expectedV = tensor([tokens], 2);
    expect(value.offset).toBe(tokens.length);
    expect(value.keys!.toFloat32()).toEqual(expectedK.toFloat32());
    expect(value.values!.toFloat32()).toEqual(expectedV.toFloat32());
  } finally { value.dispose(); }
}

test("different accepted lengths roll back coverage without moving KV, then overwrite rejected rows", () => {
  const a = cache([1, 2]), b = cache([11, 12, 13, 14]), batch = new BatchedKVCache();
  try {
    batch.mergeRows([a, b]);
    expect(batch.rowOffsets).toEqual([2, 4]);
    expect(batch.leftPad).toEqual([2, 0]);
    const transaction = bindRowCacheRollback([batch], 2);
    transaction.begin(2);
    append(batch, [[3, 4, 5], [15, 16, 17]]);
    const keyHandle = batch.keys!.handle, valueHandle = batch.values!.handle;
    transaction.resolve([0, 2]);
    expect(batch.keys!.handle).toBe(keyHandle);
    expect(batch.values!.handle).toBe(valueHandle);
    expect(batch.rowOffsets).toEqual([3, 7]);
    expect(batch.ropeOffsetArr!.toIntTokens()).toEqual([3, 7]);
    const mask = batch.makeMask(2, null);
    try {
      expect(mask.arr!.shape).toEqual([2, 1, 2, 9]);
      expect([...mask.arr!.toFloat32()]).toEqual([5, 7].flatMap((end, row) =>
        [0, 1].flatMap(query => Array.from({ length: 9 }, (_, key) =>
          Number(key >= batch.leftPad[row]! && key <= end + query)))));
    } finally { mask.arr?.dispose(); }
    append(batch, [[30, 31], [40, 41]]);
    expectRow(batch, 0, [1, 2, 3, 30, 31]);
    expectRow(batch, 1, [11, 12, 13, 14, 15, 16, 17, 40, 41]);
    expect(a.offset).toBe(2); expect(b.offset).toBe(4);
    using original = tensor([[1, 2]]);
    expect(a.keys!.toFloat32()).toEqual(original.toFloat32());
  } finally { a.dispose(); b.dispose(); batch.dispose(); }
});

test("late joins, filtering and growth preserve each independently advancing row", () => {
  const a = cache([1, 2]), b = cache([11, 12, 13, 14]), c = cache([101, 102, 103]);
  const first = new BatchedKVCache(), joined = new BatchedKVCache();
  try {
    first.mergeRows([a, b]);
    first.specRoundBegin(); append(first, [[3, 4, 5], [15, 16, 17]]);
    first.specRoundRollback([1, 3]);
    joined.mergeRows([first, c]);
    first.dispose();
    expect(joined.rowOffsets).toEqual([3, 7, 3]);
    expectRow(joined, 0, [1, 2, 3]);
    expectRow(joined, 1, [11, 12, 13, 14, 15, 16, 17]);
    expectRow(joined, 2, [101, 102, 103]);
    joined.filterRows([2, 0]);
    const tail = Array.from({ length: 300 }, (_, index) => index + 200);
    append(joined, [tail, tail.map(value => value + 400)]);
    expectRow(joined, 0, [101, 102, 103, ...tail]);
    expectRow(joined, 1, [1, 2, 3, ...tail.map(value => value + 400)]);
    joined.specRoundBegin(); append(joined, [[700], [800]]); joined.specRoundCommit();
    expect(joined.rowOffsets).toEqual([304, 304]);
  } finally { a.dispose(); b.dispose(); c.dispose(); first.dispose(); joined.dispose(); }
});


test("ragged attention ignores rejected tips and padding for multi-token and windowed queries", () => {
  const a = cache([1, 2]), b = cache([11, 12, 13, 14]), batch = new BatchedKVCache();
  try {
    batch.mergeRows([a, b]);
    batch.specRoundBegin(); append(batch, [[3, 900, 901], [15, 16, 17]]);
    batch.specRoundRollback([1, 3]);
    for (const window of [null, 3]) {
      const mask = batch.makeMask(2, window);
      try {
        const actual = mask.arr!.toFloat32();
        const expected = [5, 7].flatMap((end, row) => [0, 1].flatMap(query =>
          Array.from({ length: 9 }, (_, key) => Number(key >= batch.leftPad[row]! &&
            key <= end + query && (window === null || key > end + query - window)))));
        expect([...actual]).toEqual(expected);
      } finally { mask.arr?.dispose(); }
    }
    const mask = batch.makeMask(2, null);
    using newK = tensor([[30, 31], [40, 41]]), newV = tensor([[30, 31], [40, 41]], 2);
    const [keys, values] = batch.updateAndFetch(newK, newV);
    try {
      using q = MlxArray.fromFloat32(Float32Array.from({ length: 2 * 2 * 2 * 3 },
        (_, index) => Math.sin(index) * 0.001), [2, 2, 2, 3]);
      using actual = ops.sdpa(q, keys, values, 3 ** -0.5, mask.mode, mask.arr);
      // Rebuild the physical attention input independently, with rejected
      // columns filled differently. Only each row's causal prefix is visible.
      using expectedK = tensor([[0, 0, 1, 2, 3, 30, 31, -900, -901], [11, 12, 13, 14, 15, 16, 17, 40, 41]]);
      using expectedV = tensor([[0, 0, 1, 2, 3, 30, 31, -900, -901], [11, 12, 13, 14, 15, 16, 17, 40, 41]], 2);
      using expected = ops.sdpa(q, expectedK, expectedV, 3 ** -0.5, mask.mode, mask.arr);
      expect(actual.toFloat32()).toEqual(expected.toFloat32());
    } finally { keys.dispose(); values.dispose(); mask.arr?.dispose(); }
  } finally { a.dispose(); b.dispose(); batch.dispose(); }
});

test("a singleton uses the same transaction and causal mask without a row mask allocation", () => {
  const source = cache([1, 2]), batch = new BatchedKVCache();
  try {
    batch.mergeRows([source]);
    expect(batch.ropeOffsetArr).toBeUndefined();
    expect(batch.makeMask(1, null)).toEqual({ mode: "", arr: null });
    expect(batch.makeMask(3, null)).toEqual({ mode: "causal", arr: null });
    const transaction = bindRowCacheRollback([batch], 1);
    transaction.begin(2); append(batch, [[3, 900, 901]]); transaction.resolve([0]);
    append(batch, [[4]]);
    expectRow(batch, 0, [1, 2, 3, 4]);
  } finally { source.dispose(); batch.dispose(); }
});


test("empty draft prefixes join populated rows and allocate only when their first token is processed", () => {
  const empty = new KVCache(), populated = cache([11, 12]), batch = new BatchedKVCache();
  const singleton = new BatchedKVCache();
  try {
    singleton.mergeRows([empty, empty]);
    singleton.filterRows([1]);
    expect(singleton.state()).toEqual([]);
    expect(singleton.rowOffsets).toEqual([0]);
    const extractedEmpty = singleton.extractRow(0);
    expect(extractedEmpty.keys).toBeNull(); extractedEmpty.dispose();
    append(singleton, [[1]]);
    expectRow(singleton, 0, [1]);
    batch.mergeRows([empty, populated]);
    expect(batch.rowOffsets).toEqual([0, 2]);
    expect(batch.leftPad).toEqual([2, 0]);
    append(batch, [[1], [13]]);
    expectRow(batch, 0, [1]); expectRow(batch, 1, [11, 12, 13]);
    expect(empty.offset).toBe(0);
    expect(empty.keys).toBeNull();
  } finally { empty.dispose(); populated.dispose(); batch.dispose(); singleton.dispose(); }
});


test("starting alone preserves allocated prefill capacity and keeps its donor immutable", () => {
  const source = new KVCache(), batch = new BatchedKVCache();
  try {
    using k = tensor([[1, 2]]), v = tensor([[1, 2]], 2);
    for (const view of source.updateAndFetch(k, v)) view.dispose();
    const capacity = source.keys!.shape[2]!;
    expect(capacity).toBeGreaterThan(2);
    batch.mergeRows([source]);
    expect(batch.keys!.shape[2]).toBe(capacity);
    append(batch, [[3]]);
    expectRow(batch, 0, [1, 2, 3]);
    expect(source.offset).toBe(2);
    const restored = new BatchedKVCache();
    try { restored.mergeRows([source]); expectRow(restored, 0, [1, 2]); }
    finally { restored.dispose(); }
  } finally { source.dispose(); batch.dispose(); }
});


test("retiring the longest row removes shared padding before survivor attention", () => {
  const short = cache([1, 2]), long = cache([11, 12, 13, 14, 15]), batch = new BatchedKVCache();
  try {
    batch.mergeRows([short, long]);
    expect(batch.leftPad).toEqual([3, 0]);
    batch.filterRows([0]);
    expect(batch.leftPad).toEqual([0]); expect(batch.offset).toBe(2);
    expect(batch.keys!.shape[2]).toBe(2);
    expect(batch.makeMask(1, null)).toEqual({ mode: "", arr: null });
    append(batch, [[3, 4]]); expectRow(batch, 0, [1, 2, 3, 4]);
  } finally { batch.dispose(); short.dispose(); long.dispose(); }
});
