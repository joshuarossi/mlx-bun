import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { RotatingKVCache } from "../../src/model/gemma4-base";
import { SpeculativeRotatingKVCache } from "../../src/model/speculative-rotating-kv";

const tagged = (values: number[], shape: number[]) => MlxArray.fromFloat32(Float32Array.from(values), shape);

// Tagged columns give an independent exact oracle for every retained window.
// Rejecting after wrap must recover columns already absent from the newest
// window, then survive more decode, cloning, retirement.
test("rotating transactions retain unequal prefixes before and after wrap", () => {
  for (const initial of [[0, 0, 0], [0, 5, 7], [2, 5, 7], [9, 15, 21]]) {
    const history = initial.map((n, row) => Array.from({ length: n }, (_, i) => row * 1000 + i));
    using resources = new DisposableStack();
    const cache = new SpeculativeRotatingKVCache(8); resources.defer(() => cache.dispose());
    const sources = history.map(tokens => {
      const solo = new RotatingKVCache(8);
      if (!tokens.length) return solo;
      using data = tagged(tokens, [1, 1, tokens.length, 1]);
      const result = solo.updateAndFetch(data, data); for (const a of result) a.dispose();
      return solo;
    });
    try { cache.mergeRows(sources); } finally { for (const source of sources) source.dispose(); }
    const verify = (value: SpeculativeRotatingKVCache) => {
      for (let row = 0; row < history.length; row++) {
        const extracted = value.extractRow(row) as RotatingKVCache; resources.defer(() => extracted.dispose());
        expect(extracted.offset).toBe(history[row]!.length);
        if (!history[row]!.length) { expect(extracted.state().length).toBe(0); continue; }
        const [keys, values] = extracted.temporalView();
        try {
          using k = ops.contiguous(keys); using v = ops.contiguous(values);
          expect(Array.from(k.toFloat32())).toEqual(history[row]!.slice(-8));
          expect(Array.from(v.toFloat32())).toEqual(history[row]!.slice(-8));
        } finally { keys.dispose(); values.dispose(); }
      }
    };
    verify(cache);
    for (const counts of [[1, 4, 2], [4, 1, 3], [2, 2, 2], [4, 4, 4],
      ...Array.from({ length: 32 }, (_, step) => [1 + step % 4, 1 + (step * 3) % 4, 1 + (step * 7 + 2) % 4])]) {
      const tokens = history.map((row, index) => Array.from({ length: 4 }, (_, i) => index * 1000 + row.length + i));
      cache.specRoundBegin();
      using data = tagged(tokens.flat(), [3, 1, 4, 1]);
      for (const a of cache.updateAndFetch(data, data)) a.dispose();
      if (counts.every(count => count === 4)) cache.specRoundCommit(); else cache.specRoundRollback(counts);
      for (let row = 0; row < 3; row++) history[row]!.push(...tokens[row]!.slice(0, counts[row]!));
      verify(cache);
      const clone = cache.makeEmptyBatch(); resources.defer(() => clone.dispose()); clone.mergeRows([cache]); verify(clone);
      using tail = tagged(history.map((row, index) => index * 1000 + row.length), [3, 1, 1, 1]);
      for (const a of cache.updateAndFetch(tail, tail)) a.dispose();
      for (let row = 0; row < 3; row++) history[row]!.push(row * 1000 + history[row]!.length);
      verify(cache);
    }
    cache.filterRows([2, 0]); history.splice(0, 3, history[2]!, history[0]!); verify(cache);
  }
});

test("an unwrapped singleton keeps scalar prefix geometry after rejection", () => {
  using resources = new DisposableStack();
  const source = new RotatingKVCache(8); resources.defer(() => source.dispose());
  using prompt = tagged([1, 2], [1, 1, 2, 1]);
  for (const a of source.updateAndFetch(prompt, prompt)) a.dispose();
  const cache = new SpeculativeRotatingKVCache(8); resources.defer(() => cache.dispose()); cache.mergeRows([source]);
  cache.specRoundBegin();
  using window = tagged([3, 99, 98, 97], [1, 1, 4, 1]);
  for (const a of cache.updateAndFetch(window, window)) a.dispose(); cache.specRoundRollback(1);
  expect(cache.rowOffsets).toEqual([3]); expect(cache.leftPad).toEqual([0]); expect(cache.offset).toBe(3);
  using tail = tagged([4], [1, 1, 1, 1]);
  const [keys, values] = cache.updateAndFetch(tail, tail);
  try {
    using k = ops.contiguous(keys); using v = ops.contiguous(values);
    expect(Array.from(k.toFloat32())).toEqual([1, 2, 3, 4]);
    expect(Array.from(v.toFloat32())).toEqual([1, 2, 3, 4]);
  } finally { keys.dispose(); values.dispose(); }
});


test("singleton rejection across the ring boundary never retains the rejected suffix", () => {
  for (const length of [7, 9]) {
    using resources = new DisposableStack();
    const source = new RotatingKVCache(8); resources.defer(() => source.dispose());
    using prompt = tagged(Array.from({ length }, (_, i) => i + 1), [1, 1, length, 1]);
    for (const a of source.updateAndFetch(prompt, prompt)) a.dispose();
    const cache = new SpeculativeRotatingKVCache(8); resources.defer(() => cache.dispose()); cache.mergeRows([source]);
    cache.specRoundBegin();
    using window = tagged([length + 1, 99, 98, 97], [1, 1, 4, 1]);
    for (const a of cache.updateAndFetch(window, window)) a.dispose(); cache.specRoundRollback(1);
    using tail = tagged([length + 2], [1, 1, 1, 1]);
    for (const a of cache.updateAndFetch(tail, tail)) a.dispose();
    const extracted = cache.extractRow(0); resources.defer(() => extracted.dispose());
    expect(extracted.offset).toBe(length + 2);
    for (const plane of extracted.state()) {
      using data = ops.contiguous(plane);
      expect(Array.from(data.toFloat32())).toEqual(Array.from({ length: 8 }, (_, i) => length - 5 + i));
    }
  }
});
