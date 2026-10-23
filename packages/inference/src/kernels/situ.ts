// SITU gated activation (MOSS-Image's `_situ`), fused into one kernel:
//   (4 * tanh(gate / 4) * sigmoid(gate)) * (25 * tanh(hidden / 25))
// traced once from the reference's operation order and replayed. Every
// operation keeps the input dtype, so bf16 inputs round where the reference's
// bf16 tensors round.

import type { MlxArray } from "@mlx-bun/mlx/array";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import * as ops from "@mlx-bun/mlx/ops";

let closure: CompiledFunction | null = null;

/** `hidden` and `gate` (equal shapes, borrowed) to an owned result. */
export function situ(hidden: MlxArray, gate: MlxArray): MlxArray {
  closure ??= new CompiledFunction(inputs => {
    const h = inputs[0]!, g = inputs[1]!;
    using four = ops.scalarLike(4, g), quarter = ops.div(g, four);
    using bounded = ops.tanh(quarter);
    using scaledGate = ops.mul(four, bounded);
    using sig = ops.sigmoid(g);
    using gated = ops.mul(scaledGate, sig);
    using limit = ops.scalarLike(25, h), shrunk = ops.div(h, limit);
    using squashed = ops.tanh(shrunk);
    using clamped = ops.mul(limit, squashed);
    return [ops.mul(gated, clamped)];
  });
  return closure.apply([hidden, gate])[0]!;
}
