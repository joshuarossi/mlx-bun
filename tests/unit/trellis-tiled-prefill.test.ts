import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { expandTrellis, trellisGeometry, setTrellisVariant } from "../../src/model/trellis-linear";
import { tiledTrellisPrefill, tiledTrellisPrefillEligible } from "../../src/model/trellis-tiled-prefill";
import { nativeTrellisWidePrefill } from "../../src/model/trellis-wide-prefill";

test("tiled trellis prefill preserves precise expansion on other matrix shapes", () => {
  try {
    setTrellisVariant(6);
    for (const bits of [2, 3, 4]) for (const [rows, m] of [
      [512, 5], [769, 6], [512, 7], [769, 8], [512, 9], [512, 17], [769, 32],
    ]) {
      const cols = 256, words = cols * bits / 32;
      const host = new Int32Array(rows! * words);
      let seed = 31;
      for (let i = 0; i < host.length; i++) host[i] = seed = Math.imul(seed, 1664525) + 1013904223;
      const ints = MlxArray.fromInt32(host, [rows!, words]);
      const codes = ints.astype(Dtype.uint32); ints.dispose();
      const scale32 = MlxArray.fromFloat32(Float32Array.from({ length: rows! }, (_, i) => 0.0003 + (i % 71) / 500), [rows!]);
      const scales = scale32.astype(Dtype.float16); scale32.dispose();
      const g = trellisGeometry(codes, { bits, groupSize: 256, mode: "trellis", trellis: { L: 12, code: "1mad", axis: 1 } });
      const key = ops.randomKey(BigInt(bits));
      const storage = ops.randomNormal([cols, m!], Dtype.bfloat16, 0, 1, key); key.dispose();
      const x = ops.transposeAxes(storage, [1, 0]);
      const expanded = expandTrellis(codes, scales, g, Dtype.bfloat16);
      const transposed = ops.transposeAxes(expanded, [1, 0]);
      const expected = ops.matmul(x, transposed);
      const actual = tiledTrellisPrefill(x, codes, scales, g);
      try {
        expect(actual.shape).toEqual([m!, rows!]);
        expect(actual.rawBytes()).toEqual(expected.rawBytes());
        expect(tiledTrellisPrefillEligible(g, m!, Dtype.bfloat16)).toBe(false);
      } finally {
        for (const a of [actual, expected, transposed, expanded, x, storage, codes, scales]) a.dispose();
      }
    }
  } finally { setTrellisVariant(null); }
});

test("tiled trellis dispatch requires the measured shape and numerical contract", () => {
  const g = { k: 3, L: 12, T: 256, axis: 1 as const, rows: 17408, cols: 5120, inFeatures: 5120, outFeatures: 17408 };
  for (const m of [5, 8, 16, 17, 32])
    expect(tiledTrellisPrefillEligible(g, m, Dtype.bfloat16)).toBe(!nativeTrellisWidePrefill(m));
  for (const m of [1, 4, 33, 128]) expect(tiledTrellisPrefillEligible(g, m, Dtype.bfloat16)).toBe(false);
  for (const dtype of [Dtype.float16, Dtype.float32]) expect(tiledTrellisPrefillEligible(g, 8, dtype)).toBe(false);
  for (const changed of [{ axis: 0 as const }, { T: 128 }, { L: 10 }, { k: 1 }, { inFeatures: 4096 }])
    expect(tiledTrellisPrefillEligible({ ...g, ...changed }, 8, Dtype.bfloat16)).toBe(false);
});
