import { describe, expect, test } from "bun:test";
import { BatchedRotatingState } from "../../src/model/batched-rotating-state";
import {
  temporalStorageView,
  type RowStorage,
} from "../../src/model/batched-row-storage";

type FakeRows = number[][];
const fakeStorage: RowStorage<FakeRows> = {
  shape: (value) => [value.length, 1, value[0]?.length ?? 0, 1],
  slice: (value, batchFrom, batchTo, tokenFrom, tokenTo) =>
    value.slice(batchFrom, batchTo).map((row) => row.slice(tokenFrom, tokenTo)),
  concatTokens: (values) => values[0]!.map((_, row) =>
    values.flatMap((value) => value[row]!),
  ),
  concatRows: (values) => values.flatMap((value) => value.map((row) => [...row])),
  padLeft: (value, tokens) => value.map((row) => [...new Array(tokens).fill(0), ...row]),
  takeRows: (value, keep) => keep.map((row) => [...value[row]!]),
  copy: (value) => value.map((row) => [...row]),
  dispose: () => {},
};

describe("BatchedRotatingState", () => {
  test("tracks grow, wrap, writes, and row filtering once", () => {
    const state = new BatchedRotatingState(4, [2, 0]);
    state.restoreMerged(4, [-2, 0]);
    expect(state.beginWrite(1)).toBe(0);
    state.commitWrite(1);
    expect(state.rotated).toBe(true);
    expect(state.leftPad).toEqual([1, -1]);
    expect(state.offsets).toEqual([-1, 1]);
    expect(state.temporalRanges(4)).toEqual([[1, 4], [0, 1]]);
    state.filter([1]);
    expect(state.leftPad).toEqual([-1]);
    expect(state.offsets).toEqual([1]);
  });

  test("merged and trimmed state uses the same scalar rules", () => {
    const state = new BatchedRotatingState(8, [3, 0]);
    state.restoreMerged(5, [2, 5]);
    expect(state.validLength).toBe(5);
    expect(state.trimmable).toBe(true);
    expect(state.trim(2)).toBe(2);
    expect(state.totalOffset).toBe(3);
    expect(state.ringIndex).toBe(3);
    expect(state.offsets).toEqual([0, 3]);
  });

  test("one storage algorithm de-rolls and extracts either representation", () => {
    const state = new BatchedRotatingState(4, [0, 1]);
    state.restoreMerged(4, [4, 3]);
    state.beginWrite(1);
    state.commitWrite(1);
    const physical = [[5, 2, 3, 4], [15, 12, 13, 14]];

    expect(temporalStorageView(fakeStorage, physical, state))
      .toEqual([[2, 3, 4, 5], [12, 13, 14, 15]]);
    expect(temporalStorageView(fakeStorage, physical, state, {
      row: 1,
      from: Math.max(0, state.leftPad[1]!),
      copy: true,
    })).toEqual([[12, 13, 14, 15]]);
  });
});
