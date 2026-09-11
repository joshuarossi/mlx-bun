import { test, expect } from "bun:test";
import { SsmPrefillPadding } from "../../src/model/ssm-prefill-padding";
import { BatchedSSMCache } from "../../src/model/batched-ssm";

test("left padding advances coverage only after each row reaches real tokens", () => {
  const padding = new SsmPrefillPadding({ leftPadding: [4, 0, 6], lengths: [9, 9, 9] });
  expect(padding.advance(3)).toEqual([0, 3, 0]);
  expect(padding.advance(3)).toEqual([2, 3, 0]);
  expect(padding.advance(3)).toEqual([3, 3, 3]);
});

test("finished rows preserve their convolution tails through later prompt chunks", () => {
  const padding = new SsmPrefillPadding({ lengths: [5, 9, 0], rightPadding: [4, 0, 9] });
  expect(padding.convolutionLengths(3)).toEqual([3, 3, 0]);
  expect(padding.advance(3)).toEqual([3, 3, 0]);
  expect(padding.convolutionLengths(4)).toEqual([2, 4, 0]);
  expect(padding.advance(4)).toEqual([2, 4, 0]);
  expect(padding.convolutionLengths(2)).toEqual([0, 2, 0]);
  expect(padding.advance(2)).toEqual([0, 2, 0]);
});

test("retirement during preparation keeps remaining padding and cached coverage aligned", () => {
  const cache = new BatchedSSMCache();
  try {
    cache.offsets = [20, 40, 0]; cache.offset = 40;
    cache.preparePrefill({ lengths: [5, 9, 0], rightPadding: [4, 0, 9] });
    cache.advance(3);
    expect(cache.rowOffsets).toEqual([23, 43, 0]);
    cache.filterRows([2, 0]);
    expect(cache.rowOffsets).toEqual([0, 23]);
    cache.advance(4);
    expect(cache.rowOffsets).toEqual([0, 25]);
    cache.finalizePrefill();
    cache.advance(1);
    expect(cache.rowOffsets).toEqual([1, 26]);
    expect(cache.offset).toBe(26);
    cache.filterRows([]);
    expect(cache.rowOffsets).toEqual([]);
    expect(cache.offset).toBe(0);
  } finally { cache.dispose(); }
});


test("uniform prompt batches retain unmasked decode and prefill", () => {
  const cache = new BatchedSSMCache();
  try {
    cache.preparePrefill({ lengths: [7, 7], leftPadding: [0, 0], rightPadding: [0, 0] });
    expect(cache.prefillPadding).toBeNull();
    expect(cache.makeMask(7, null)).toEqual({ mode: "", arr: null });
    cache.advance(7);
    expect(cache.rowOffsets).toEqual([7, 7]);
  } finally { cache.dispose(); }
});
