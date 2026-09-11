import { expect, test } from "bun:test";
import { FullPrefillPadding } from "../../src/model/full-prefill-padding";

test("a shortened cohort removes only processed padding after retirement and reordering", () => {
  const padding = new FullPrefillPadding();
  const positions = { rowOffsets: [11, 11, 11], leftPad: [0, 0, 0] };
  padding.prepare(positions, { lengths: [2, 10, 4], rightPadding: [8, 0, 6] });
  // Five positions were processed before the longest request was cancelled.
  positions.rowOffsets = [16, 16]; positions.leftPad = [0, 0];
  padding.filter([2, 0]);
  padding.finalize([], positions);
  expect(positions).toEqual({ rowOffsets: [15, 13], leftPad: [1, 3] });
  // Finalization is one-shot; subsequent generation retains its new positions.
  positions.rowOffsets = [16, 14];
  expect(padding.finalize([], positions)).toBeUndefined();
  expect(positions.rowOffsets).toEqual([16, 14]);
});

test("an early checkpoint before right padding does not move retained state", () => {
  const padding = new FullPrefillPadding();
  const positions = { rowOffsets: [], leftPad: [] } as { rowOffsets: number[]; leftPad: number[] };
  padding.prepare(positions, { lengths: [8, 10], rightPadding: [2, 0] });
  positions.rowOffsets = [3, 3];
  expect(padding.finalize([], positions)).toBeUndefined();
  expect(positions).toEqual({ rowOffsets: [3, 3], leftPad: [0, 0] });
  // Continue a newly prepared segment at this checkpoint.
  padding.prepare(positions, { lengths: [5, 7], rightPadding: [2, 0] });
  positions.rowOffsets = [10, 10];
  padding.finalize([], positions);
  expect(positions).toEqual({ rowOffsets: [8, 10], leftPad: [2, 0] });
});

test("finalization before any work and clear leave positions untouched", () => {
  const padding = new FullPrefillPadding();
  const positions = { rowOffsets: [7, 7], leftPad: [0, 0] };
  padding.prepare(positions, { lengths: [2, 10], rightPadding: [8, 0] });
  expect(padding.finalize([], positions)).toBeUndefined();
  expect(positions.rowOffsets).toEqual([7, 7]);
  padding.prepare(positions, { lengths: [2, 10], rightPadding: [8, 0] });
  padding.clear(); positions.rowOffsets = [17, 17];
  expect(padding.finalize([], positions)).toBeUndefined();
  expect(positions).toEqual({ rowOffsets: [17, 17], leftPad: [0, 0] });
});
