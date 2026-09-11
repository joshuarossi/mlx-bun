import { describe, expect, test } from "bun:test";
import { BatchedRotatingState } from "../../src/model/batched-rotating-state";
import {
  appendRotatingStorage,
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
  rollRows: (value, indices) => {
    const positions = indices.toIntTokens(), width = indices.shape[2]!;
    return value.map((row, r) => Array.from({ length: width }, (_, i) => row[positions[r * width + i]!]!));
  },
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

test("block writes retain every query's window and hand back to ring writes", () => {
  const state = new BatchedRotatingState(4, [0, 2]);
  state.restoreMerged(4, [4, 2]);
  state.beginWrite(1); state.commitWrite(1);
  const previous = [[5, 2, 3, 4], [15, 0, 13, 14]];
  const incoming = [[6, 7, 8], [16, 17, 18]];
  const block = appendRotatingStorage(fakeStorage, previous, incoming, state);
  expect(block).toEqual([[3, 4, 5, 6, 7, 8], [13, 14, 15, 16, 17, 18]]);
  expect(previous).toEqual([[5, 2, 3, 4], [15, 0, 13, 14]]);
  state.commitConcat(3, state.activeLength);
  expect(state.offsets).toEqual([8, 6]);
  expect(state.leftPad).toEqual([-2, 0]);
  expect(state.activeLength).toBe(6);
  expect(state.rotated).toBe(false);
  expect(temporalStorageView(fakeStorage, block, state, { row: 1, to: state.activeLength }))
    .toEqual([[13, 14, 15, 16, 17, 18]]);
  // Before the next one-token write, remove the block's temporary overshoot.
  state.trimOvershoot(2);
  expect(state.beginWrite(1)).toBe(0);
  state.commitWrite(1);
  expect(state.offsets).toEqual([9, 7]);
  expect(state.leftPad).toEqual([-5, -3]);
  expect(state.activeLength).toBe(4);
});

test("block append ignores spare allocation and supports an empty padded batch", () => {
  const state = new BatchedRotatingState(8, [0, 2]);
  const incoming = [[1, 2, 3], [0, 0, 13]];
  expect(appendRotatingStorage(fakeStorage, null, incoming, state)).toEqual(incoming);
  state.commitConcat(3, 0);
  expect(state.offsets).toEqual([3, 1]);
  const allocated = [[1, 2, 3, 99, 99], [0, 0, 13, 99, 99]];
  expect(appendRotatingStorage(fakeStorage, allocated, [[4, 5], [14, 15]], state))
    .toEqual([[1, 2, 3, 4, 5], [0, 0, 13, 14, 15]]);
});
