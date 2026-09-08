import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { expandTrellis, trellisGeometry } from "../../src/model/trellis-linear";
import { splitKTrellisPrefill, splitKTrellisPrefillEligible } from "../../src/model/trellis-splitk-prefill";

test("split-K trellis prefill matches stock expansion on other shapes and partition tails", () => {
  for (const bits of [2, 3, 4]) for (const [k, n, m] of [[1280, 256, 5], [2080, 512, 8], [4096, 768, 5]]) {
    const words = n! * bits / 32;
    let seed = 913;
    const data = Int32Array.from({ length: k! * words }, () => seed = Math.imul(seed, 1664525) + 1013904223);
    const ints = MlxArray.fromInt32(data, [k!, words]);
    const codes = ints.astype(Dtype.uint32); ints.dispose();
    const rawScales = MlxArray.fromFloat32(Float32Array.from({ length: k! }, (_, i) => 0.0003 + (i % 71) / 500), [k!]);
    const scales = rawScales.astype(Dtype.float16); rawScales.dispose();
    const g = trellisGeometry(codes, { bits, groupSize: 256, mode: "trellis", trellis: { L: 12, code: "1mad", axis: 0 } });
    const key = ops.randomKey(BigInt(bits));
    const storage = ops.randomNormal([k!, m!], Dtype.bfloat16, 0, 1, key); key.dispose();
    const x = ops.transposeAxes(storage, [1, 0]);
    const expanded = expandTrellis(codes, scales, g, Dtype.bfloat16);
    const expected = ops.matmul(x, expanded);
    const actual = splitKTrellisPrefill(x, codes, scales, g);
    try {
      expect(actual.shape).toEqual([m!, n!]);
      expect(actual.rawBytes()).toEqual(expected.rawBytes());
      expect(splitKTrellisPrefillEligible(g, m!, Dtype.bfloat16)).toBe(false);
    } finally { for (const a of [actual, expected, expanded, x, storage, codes, scales]) a.dispose(); }
  }
});

test("split-K dispatch stays within the measured regime", () => {
  const g = { k: 3, L: 12, T: 256, axis: 0 as const, rows: 17408, cols: 5120, inFeatures: 17408, outFeatures: 5120 };
  for (const m of [5, 6, 7, 8]) expect(splitKTrellisPrefillEligible(g, m, Dtype.bfloat16)).toBe(true);
  for (const m of [1, 4, 9, 16, 32]) expect(splitKTrellisPrefillEligible(g, m, Dtype.bfloat16)).toBe(false);
  for (const dtype of [Dtype.float16, Dtype.float32]) expect(splitKTrellisPrefillEligible(g, 5, dtype)).toBe(false);
  for (const changed of [{ axis: 1 as const }, { T: 128 }, { L: 10 }, { k: 1 }, { outFeatures: 4096 }])
    expect(splitKTrellisPrefillEligible({ ...g, ...changed }, 5, Dtype.bfloat16)).toBe(false);
});
