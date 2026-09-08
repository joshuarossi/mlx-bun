import { expect, test } from "bun:test";
import { MlxArray, cpuStream, gpuStream } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";

test("cumulative operations preserve axes, dtype and stream across the C ABI", () => {
  for (const stream of [cpuStream, gpuStream]) {
    for (const dtype of [Dtype.float32, Dtype.int32]) {
      const raw = MlxArray.fromFloat32(new Float32Array([1, 4, -2, 3, -1, 2]), [2, 3]);
      const input = raw.astype(dtype, stream);
      try {
        const cases = [
          { output: ops.cumsum(input, 0, stream), expected: [1, 4, -2, 4, 3, 0] },
          { output: ops.cumsum(input, -1, stream), expected: [1, 5, 3, 3, 2, 4] },
          { output: ops.cummax(input, 0, stream), expected: [1, 4, -2, 3, 4, 2] },
          { output: ops.cummax(input, -1, stream), expected: [1, 4, 4, 3, 3, 3] },
        ];
        try {
          for (const { output, expected } of cases) {
            expect(output.shape).toEqual([2, 3]);
            expect(output.dtype).toBe(dtype);
            expect(Array.from(output.toFloat32())).toEqual(expected);
          }
          expect(Array.from(input.toFloat32())).toEqual([1, 4, -2, 3, -1, 2]);
        } finally { for (const { output } of cases) output.dispose(); }
      } finally { input.dispose(); raw.dispose(); }
    }
  }
});

test("attention preserves grouped heads, masks and stream across the C ABI", () => {
  for (const stream of [cpuStream, gpuStream]) {
    const q = MlxArray.fromFloat32(new Float32Array(16), [1, 2, 2, 4]);
    const k = MlxArray.fromFloat32(new Float32Array(8), [1, 1, 2, 4]);
    const v = MlxArray.fromFloat32(new Float32Array([1, 3, 5, 7, 9, 11, 13, 15]), [1, 1, 2, 4]);
    const mask = MlxArray.fromFloat32(new Float32Array([-Infinity, 0]), [2]);
    try {
      const cases = [
        { output: ops.sdpa(q, k, v, 0.5, "", null, stream), expected: [5, 7, 9, 11, 5, 7, 9, 11] },
        { output: ops.sdpa(q, k, v, 0.5, "causal", null, stream), expected: [1, 3, 5, 7, 5, 7, 9, 11] },
        { output: ops.sdpa(q, k, v, 0.5, "array", mask, stream), expected: [9, 11, 13, 15, 9, 11, 13, 15] },
      ];
      try {
        for (const { output, expected } of cases) {
          expect(output.shape).toEqual([1, 2, 2, 4]);
          expect(Array.from(output.toFloat32())).toEqual([...expected, ...expected]);
        }
      } finally { for (const { output } of cases) output.dispose(); }
    } finally { q.dispose(); k.dispose(); v.dispose(); mask.dispose(); }
  }
});
