import type { MlxArray } from "./array";
import * as ops from "./ops";

/** Run independent affine M=1 matrix-vector products in one native batched call.
 * Weight/scales/bias views share their original buffers. MLX 0.32.2's
 * flattened M>=2 path uses different arithmetic, so appending known tokens
 * must explicitly select this layout when preserving decode state.
 */
export function quantizedMatmulRows(
  x: MlxArray, w: MlxArray, scales: MlxArray, biases: MlxArray | null,
  spec: ops.QuantSpec,
): MlxArray {
  const shape = x.shape, width = shape[shape.length - 1]!;
  const rows = shape.reduce((a, b) => a * b, 1) / width;
  if (rows === 1) return ops.quantizedMatmul(x, w, scales, biases, spec);
  if (spec.mode !== "affine")
    throw new Error("Independent-row batched matmul requires affine quantization");
  if (w.shape.length !== 2 || scales.shape.length !== 2 || (biases && biases.shape.length !== 2))
    throw new Error("Independent-row matmul requires shared two-dimensional weights");
  const views: MlxArray[] = [];
  const view = (value: MlxArray, newShape: number[]) => {
    const result = ops.reshape(value, newShape); views.push(result); return result;
  };
  let output: MlxArray | undefined;
  try {
    const input = view(x, [rows, 1, width]);
    const weight = view(w, [1, ...w.shape]);
    const scale = view(scales, [1, ...scales.shape]);
    const bias = biases ? view(biases, [1, ...biases.shape]) : null;
    output = ops.quantizedMatmul(input, weight, scale, bias, spec);
    return ops.reshape(output, [...shape.slice(0, -1), output.shape.at(-1)!]);
  } finally {
    output?.dispose();
    for (const value of views) value.dispose();
  }
}
