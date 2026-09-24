// Explicit compact storage for a value that must release a larger backing
// buffer. MLX 0.31.2 Copy::eval shares storage; contiguous() may also alias.
// MLX's dynamic slice allocates the logical output size and has a native VJP.
import { MlxArray } from "./array";
import * as ops from "./ops";

let zero: MlxArray | undefined;

/** Borrow an array; return an owned, row-contiguous copy on the GPU.
 * Values and dtype are unchanged. Evaluation stays lazy and never reads data
 * back to the host. Use only when independent compact storage is required;
 * immutable array aliases normally avoid this allocation and dispatch.
 * Slice sizes are concrete, so use shape-specialized compiled graphs. */
export function materializeCopy(input: MlxArray): MlxArray {
  zero ??= MlxArray.fromInt32(new Int32Array([0]), []);
  if (input.ndim > 0) return ops.sliceDynamic(input, zero, [0], input.shape);
  const vector = ops.reshape(input, [1]);
  try {
    const copy = ops.sliceDynamic(vector, zero, [0], [1]);
    try { return ops.reshape(copy, []); }
    finally { copy.dispose(); }
  } finally { vector.dispose(); }
}
