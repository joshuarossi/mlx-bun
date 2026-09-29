// A graph declares the layers its attention reads as plain keys and values.
// Consumers bind the declaration once against the graph's own fresh caches:
// an absent or malformed declaration is refused rather than read as none, and
// a declared layer must hold storage that reads dense. CPU only.
import { expect, test } from "bun:test";
import { bindRequiredDenseKvLayers, plainKvStorage } from "../../src/state/dense-kv-reads";
import type { Cache } from "../../src/contracts/mlx/cache";

const plain = { denseKvReads: plainKvStorage } as unknown as Cache;
const recurrent = {} as Cache;

test("a declaration is copied and frozen once; later edits to the caller's list do not reach it", () => {
  const declared = [0, 2];
  const bound = bindRequiredDenseKvLayers(declared, [plain, recurrent, plain]);
  declared.push(1);
  expect(bound).toEqual([0, 2]);
  expect(Object.isFrozen(bound)).toBe(true);
  expect(bindRequiredDenseKvLayers([], [recurrent])).toEqual([]);
});

test("an absent declaration is refused, never read as no requirement", () => {
  for (const declared of [undefined, null, "0", { 0: 0, length: 1 }])
    expect(() => bindRequiredDenseKvLayers(declared, [plain]), String(declared)).toThrow(TypeError);
});

test("layers must be distinct indices within the graph's caches", () => {
  for (const declared of [[-1], [0.5], [Number.NaN], [1], [0, 0], ["0"]])
    expect(() => bindRequiredDenseKvLayers(declared, [plain]), JSON.stringify(declared)).toThrow(RangeError);
});

test("a declared layer whose storage does not read dense is refused", () => {
  expect(() => bindRequiredDenseKvLayers([0, 1], [plain, recurrent])).toThrow("does not read dense: 1");
});
