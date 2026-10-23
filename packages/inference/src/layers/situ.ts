// SITU gated activation (MOSS-Image's `_situ`):
//   (4 * tanh(gate / 4) * sigmoid(gate)) * (25 * tanh(hidden / 25))
// spelled in the reference's operation order, each operation in the input
// dtype, so bf16 inputs round where the reference's bf16 tensors round. The
// compiled form traces the same operations once and replays them as one fused
// kernel; which form a layer runs is its owner's construction-time choice.

import type { MlxArray } from "@mlx-bun/mlx/array";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import * as ops from "@mlx-bun/mlx/ops";

/** The reference composition over borrowed `hidden` and `gate`; returns an owned result. */
function situOps(hidden: MlxArray, gate: MlxArray): MlxArray {
  using four = ops.scalarLike(4, gate), quarterGate = ops.div(gate, four);
  using bounded = ops.tanh(quarterGate);
  using scaledGate = ops.mul(four, bounded);
  using sig = ops.sigmoid(gate);
  using gated = ops.mul(scaledGate, sig);
  using limit = ops.scalarLike(25, hidden), shrunk = ops.div(hidden, limit);
  using squashed = ops.tanh(shrunk);
  using clamped = ops.mul(limit, squashed);
  return ops.mul(gated, clamped);
}

let compiled: CompiledFunction | null = null;

/** SITU as the spelled-out operations. Consumes both inputs. */
export class PlainSitu {
  forward(hidden: MlxArray, gate: MlxArray): MlxArray {
    const out = situOps(hidden, gate);
    hidden.dispose(); gate.dispose();
    return out;
  }
}

/** SITU traced once and replayed as one fused kernel: the same operations,
 * the same per-operation rounding. Consumes both inputs. */
export class CompiledSitu {
  forward(hidden: MlxArray, gate: MlxArray): MlxArray {
    compiled ??= new CompiledFunction(inputs => [situOps(inputs[0]!, inputs[1]!)]);
    const out = compiled.apply([hidden, gate])[0]!;
    hidden.dispose(); gate.dispose();
    return out;
  }
}
