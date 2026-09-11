import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { KVCache, type Cache } from "../../src/model/gemma4-base";
import { SSMCache } from "../../src/model/qwen3-delta";
import { BatchedKVCache } from "../../src/model/batched-kv";
import { BatchedSSMCache } from "../../src/model/batched-ssm";
import { MlxStateRows } from "../../src/backends/mlx/state-rows";

function seed(length: number, value: number): [KVCache, SSMCache] {
  const kv = new KVCache(), recurrent = new SSMCache();
  const array = (shape: number[]) => MlxArray.fromFloat32(
    new Float32Array(shape.reduce((a, b) => a * b, 1)).fill(value), shape);
  kv.restoreState(array([1, 1, length, 2]), array([1, 1, length, 2]), length);
  recurrent.conv = array([1, 2, 3]); recurrent.recurrent = array([1, 1, 2, 2]); recurrent.offset = length;
  return [kv, recurrent];
}
const dispose = (caches: readonly Cache[]) => { for (const cache of caches) cache.dispose(); };

test("attention and recurrent layouts share admission, reorder, extraction and empty-group reuse", () => {
  const group = new MlxStateRows([new BatchedKVCache(), new BatchedSSMCache()]);
  const first = seed(2, 11), second = seed(5, 22);
  try {
    group.append(first); group.append(second);
    expect(group.rowCount).toBe(2);
    expect(group.caches.map(cache => cache.rowOffsets)).toEqual([[2, 5], [2, 5]]);
    expect(first[1].conv!.toFloat32Host()[0]).toBe(11);
    expect(second[1].conv!.toFloat32Host()[0]).toBe(22);
    group.filterRows([1, 0]);
    expect(group.caches.map(cache => cache.rowOffsets)).toEqual([[5, 2], [5, 2]]);
    const saved = group.extractRow(1);
    try {
      group.filterRows([0]);
      expect(group.caches.map(cache => cache.offset)).toEqual([5, 5]);
      group.append(saved);
      expect(group.caches.map(cache => cache.rowOffsets)).toEqual([[5, 2], [5, 2]]);
      group.filterRows([]);
      expect(group.rowCount).toBe(0);
      expect(group.caches.map(cache => cache.state().length)).toEqual([0, 0]);
      group.append(saved);
      const restored = group.extractRow(0);
      try {
        expect(restored.map(cache => cache.offset)).toEqual([2, 2]);
        expect((restored[1] as SSMCache).conv!.toFloat32Host()).toEqual(first[1].conv!.toFloat32Host());
        expect((restored[0] as KVCache).keys!.toFloat32Host()).toEqual(first[0].keys!.toFloat32Host());
      } finally { dispose(restored); }
    } finally { dispose(saved); }
  } finally { group.dispose(); dispose(first); dispose(second); }
});

test("a failed layer merge leaves the active group and its borrowed donors intact", () => {
  const failure = new Error("merge failed"); let reject = false, closed = 0;
  class FaultLayout extends BatchedSSMCache {
    override makeEmptyBatch(): FaultLayout { return new FaultLayout(); }
    override mergeRows(rows: readonly Cache[]): void { if (reject) throw failure; super.mergeRows(rows); }
    override dispose(): void { closed++; super.dispose(); }
  }
  const group = new MlxStateRows([new BatchedKVCache(), new FaultLayout()]);
  const first = seed(2, 11), second = seed(5, 22);
  try {
    group.append(first); const before = [...group.caches], previousClosed = closed;
    reject = true;
    expect(() => group.append(second)).toThrow(failure);
    expect(closed).toBe(previousClosed + 1);
    expect(group.rowCount).toBe(1);
    expect(group.caches[0]).toBe(before[0]); expect(group.caches[1]).toBe(before[1]);
    expect(group.caches.map(cache => cache.rowOffsets)).toEqual([[2], [2]]);
    expect(second[1].conv!.toFloat32Host()[0]).toBe(22);
    reject = false; group.append(second);
    expect(group.rowCount).toBe(2);
  } finally { group.dispose(); dispose(first); dispose(second); }
});


test("recurrent admission initializes fresh rows beside existing state and preserves empty cohorts", () => {
  const first = seed(2, 11), cold: Cache[] = [new KVCache(), new SSMCache()];
  const group = new MlxStateRows([new BatchedKVCache(), new BatchedSSMCache()]);
  try {
    group.mergeRows([cold, cold]);
    expect(group.rowCount).toBe(2);
    expect(group.caches.map(cache => cache.state())).toEqual([[], []]);
    group.mergeRows([first, cold]);
    const ssm = group.caches[1] as BatchedSSMCache;
    expect(ssm.rowOffsets).toEqual([2, 0]);
    expect([...ssm.conv!.toFloat32Host()]).toEqual([...Array(6).fill(11), ...Array(6).fill(0)]);
    expect([...ssm.recurrent!.toFloat32Host()]).toEqual([...Array(4).fill(11), ...Array(4).fill(0)]);
    group.append(cold);
    expect(group.caches.map(cache => cache.rowOffsets)).toEqual([[2, 0, 0], [2, 0, 0]]);
    const extracted = group.extractRow(2);
    try { expect([...((extracted[1] as SSMCache).recurrent!.toFloat32Host())]).toEqual(Array(4).fill(0)); }
    finally { dispose(extracted); }
  } finally { group.dispose(); dispose(first); dispose(cold); }
});
