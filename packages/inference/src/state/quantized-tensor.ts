import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";


export const mapTriple = (
  t: ops.QuantizedTensor, f: (a: MlxArray) => MlxArray,
): ops.QuantizedTensor => ({ packed: f(t.packed), scales: f(t.scales), biases: f(t.biases) });

export const disposeTriple = (t: ops.QuantizedTensor): void => {
  t.packed.dispose();
  t.scales.dispose();
  t.biases.dispose();
};
