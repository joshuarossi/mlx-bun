// SITU gated activation (MOSS-Image's `_situ`), fused into one kernel:
//   (4 * tanh(gate / 4) * sigmoid(gate)) * (25 * tanh(hidden / 25))
// traced once from the reference's operation order and replayed. The reference
// runs it on bf16 tensors in eager torch, where each operation computes in
// float32 and stores its result in bf16; this computes every operation in
// float32 and stores it in the inputs' dtype, so bf16 inputs round where the
// reference rounds (on the captured block-22 activations this reproduces every
// element; MLX's own bf16 operations missed about three in ten) and float32
// inputs pass through unrounded.

import type { MlxArray } from "@mlx-bun/mlx/array";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

/** The compiled closure for each dtype bound so far: built at most once, looked up only when a layer binds it. */
const closures = new Map<Dtype, CompiledFunction>();

/** SITU for inputs of `dtype`, its stores rounding to `dtype`: the layer that owns this kernel binds it once, at
 * construction, and each call replays the compiled trace. The returned callable takes `hidden` and `gate` of that
 * dtype (equal shapes, borrowed) and returns an owned result in it. */
export function situFor(dtype: Dtype): (hidden: MlxArray, gate: MlxArray) => MlxArray {
  let closure = closures.get(dtype);
  if (!closure) closures.set(dtype, closure = new CompiledFunction(inputs => {
    /** A float32 result stored in the inputs' dtype and widened again (consumes `wide`). */
    const stored = (wide: MlxArray) => { using held = wide; using rounded = held.astype(dtype); return rounded.astype(Dtype.float32); };
    using h = inputs[0]!.astype(Dtype.float32), g = inputs[1]!.astype(Dtype.float32);
    using four = ops.scalarLike(4, g);
    using quarter = stored(ops.div(g, four));
    using bounded = stored(ops.tanh(quarter));
    using scaledGate = stored(ops.mul(four, bounded));
    using sig = stored(ops.sigmoid(g));
    using gated = stored(ops.mul(scaledGate, sig));
    using limit = ops.scalarLike(25, h);
    using shrunk = stored(ops.div(h, limit));
    using squashed = stored(ops.tanh(shrunk));
    using clamped = stored(ops.mul(limit, squashed));
    using product = ops.mul(gated, clamped);
    return [product.astype(dtype)];
  }));
  const bound = closure;
  return (hidden, gate) => bound.apply([hidden, gate])[0]!;
}
