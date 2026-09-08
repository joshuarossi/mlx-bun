import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype, clearCache } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { quantizedMatmulRows } from "../../src/mlx/quantized-rows";

for (const bits of [2, 3, 4, 6, 8]) for (const groupSize of [32, 64, 128]) for (const dtype of [Dtype.bfloat16, Dtype.float16, Dtype.float32]) {
  test(`independent-row affine ${bits}-bit group ${groupSize} dtype ${dtype} preserves sequential M1`, () => {
    for (const [width, outputs] of [[128, 48], [5120, 128]]) {
      const floats = MlxArray.fromFloat32(Float32Array.from({ length: width! * outputs! }, (_, i) => Math.sin(i * 0.37) * 1.7), [outputs!, width!]);
      const values = floats.astype(dtype); floats.dispose();
      const spec = { mode: "affine" as const, bits, groupSize };
      const quant = ops.quantize(values, spec.groupSize, spec.bits, spec.mode); values.dispose();
      try {
        const before = [quant.packed, quant.scales, quant.biases].map(value => Buffer.from(value.rawBytesView()));
        for (const rows of [1, 2, 3, 4]) for (const strided of [false, true]) {
          const source = MlxArray.fromFloat32(Float32Array.from({ length: rows * width! }, (_, i) => Math.cos(i * 0.29 + rows) * 0.8), strided ? [width!, rows] : [rows, width!]);
          const typed = source.astype(dtype); source.dispose();
          const input = strided ? ops.transposeAxes(typed, [1, 0]) : ops.contiguous(typed); typed.dispose();
          const expectedRows: MlxArray[] = [];
          let expected: MlxArray | undefined, actual: MlxArray | undefined;
          try {
            for (let row = 0; row < rows; row++) {
              const slice = input.slice([row, 0], [row + 1, width!]);
              try { expectedRows.push(ops.quantizedMatmul(slice, quant.packed, quant.scales, quant.biases, spec)); }
              finally { slice.dispose(); }
            }
            expected = ops.concatAxis(expectedRows, 0);
            actual = quantizedMatmulRows(input, quant.packed, quant.scales, quant.biases, spec);
            expect(actual.shape).toEqual([rows, outputs!]);
            expect(Buffer.from(actual.rawBytesView())).toEqual(Buffer.from(expected.rawBytesView()));
          } finally {
            actual?.dispose(); expected?.dispose(); input.dispose();
            for (const value of expectedRows) value.dispose();
          }
        }
        [quant.packed, quant.scales, quant.biases].forEach((value, i) => expect(Buffer.from(value.rawBytesView())).toEqual(before[i]!));
      } finally {
        quant.packed.dispose(); quant.scales.dispose(); quant.biases.dispose(); clearCache();
      }
    }
  });
}
