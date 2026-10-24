// The native MLX SITU expression in its eager operation order. Every operation
// retains the input dtype, including the sigmoid and divisions.
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

/** Bind the input dtype once. Inputs borrowed; the result is owned. */
export function situFor(dtype: Dtype): (hidden: MlxArray, gate: MlxArray) => MlxArray {
  return (hidden, gate) => {
    if (hidden.dtype !== dtype || gate.dtype !== dtype)
      throw new TypeError("SITU inputs must have the bound dtype");
    using four = ops.scalarLike(4, gate), limit = ops.scalarLike(25, hidden);
    using dividedGate = ops.div(gate, four);
    using boundedGate = ops.tanh(dividedGate);
    using scaledGate = ops.mul(four, boundedGate);
    using sigmoid = ops.sigmoid(gate);
    using gated = ops.mul(scaledGate, sigmoid);
    using dividedHidden = ops.div(hidden, limit);
    using boundedHidden = ops.tanh(dividedHidden);
    using scaledHidden = ops.mul(limit, boundedHidden);
    return ops.mul(gated, scaledHidden);
  };
}
