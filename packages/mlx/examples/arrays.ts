import { MlxArray, ops } from "@mlx-bun/mlx";

export function double(values: number[]): number[] {
  using input = MlxArray.fromFloat32(new Float32Array(values), [values.length]);
  using output = ops.mulScalar(input, 2);
  return [...output.toFloat32()];
}

if (import.meta.main) console.log(double([1, 2, 3]));
