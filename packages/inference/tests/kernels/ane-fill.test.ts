// The ANE fill kernel decodes stored Trellis rows (variant-6 code·scale) as
// fp16 into a destination buffer at an offset, the layout the ANE program's
// weight input expects; compared with the f32 expansion of the same rows.
import { expect, test } from "bun:test";
import { Dtype, MlxArray, ops } from "@mlx-bun/mlx";
import { expandTrellis, type TrellisGeometry } from "@mlx-bun/inference/kernels/trellis";
import { trellisFillEligible, trellisFillHalf, trellisFillHalfK3Interleaved, trellisFillK3InterleavedEligible } from "../../src/kernels/ane/fill";

function weights(k: number, axis: 0 | 1 = 1, interleave = false, seedBase = 31) {
  const rows = 64, cols = 512, words = cols * k / 32;
  let seed = seedBase + k;
  const data = Int32Array.from({ length: rows * words }, () => seed = Math.imul(seed, 1664525) + 1013904223);
  using ints = MlxArray.fromInt32(data, interleave ? [1, rows, 48] : [rows, words]);
  const codes = ints.astype(Dtype.uint32);
  using scale32 = MlxArray.fromFloat32(Float32Array.from({ length: rows }, (_, i) => (i % 17 + 1) / 200), [rows]);
  const scales = scale32.astype(Dtype.float16);
  const geometry: TrellisGeometry = { k, L: 12, T: 256, axis, rows, cols,
    inFeatures: axis === 1 ? cols : rows, outFeatures: axis === 1 ? rows : cols,
    ...(interleave ? { blockInterleave: 2 as const } : {}) };
  return { codes, scales, geometry, [Symbol.dispose]() { codes.dispose(); scales.dispose(); } };
}

function relErr(actual: MlxArray, expected: MlxArray): number {
  expect(actual.shape).toEqual(expected.shape);
  const a = actual.astype(Dtype.float32).toFloat32(), b = expected.astype(Dtype.float32).toFloat32();
  let err = 0, mag = 0;
  for (let i = 0; i < b.length; i++) { err = Math.max(err, Math.abs(a[i]! - b[i]!)); mag = Math.max(mag, Math.abs(b[i]!)); }
  return err / mag;
}

test("the ANE fill kernels write the code-times-scale rows as fp16, both code layouts", () => {
  for (const [k, axis, interleave] of [[3, 1, false], [2, 0, false], [3, 0, true]] as const) {
    using w = weights(k, axis, interleave);
    expect(interleave ? trellisFillK3InterleavedEligible(w.geometry) : trellisFillEligible(w.geometry)).toBe(true);
    const n = 32, C = w.geometry.cols;
    using dst = ops.zeros([n * C + 16], Dtype.float16);
    using done = (interleave ? trellisFillHalfK3Interleaved : trellisFillHalf)(w.codes, w.scales, w.geometry, n, dst, 16);
    ops.evalAll([done, dst]);
    using dense = expandTrellis(w.codes, w.scales, w.geometry, Dtype.float32, 6); // [rows, cols] stored order
    using head = dense.slice([0, 0], [n, C]);
    using written = dst.slice([16], [16 + n * C]);
    using expected = ops.reshape(head, [n * C]);
    expect(relErr(written, expected), `k${k} axis${axis}${interleave ? "i" : ""}`).toBeLessThan(2e-3);
  }
});
