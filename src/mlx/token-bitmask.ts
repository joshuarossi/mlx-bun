// XGrammar's additive 0/-Infinity mask contract, decoded from packed bits.
// Reference: mlc-ai/xgrammar b5048784, apply_token_bitmask_mlx.py (Apache-2.0).
import { MlxArray } from "./array";
import { CompiledFunction } from "./compile";
import { Dtype } from "./ffi";
import { MetalKernel } from "./metal-kernel";

let compiled: CompiledFunction | undefined;
let kernel: MetalKernel | undefined;

function maskGraph(logits: MlxArray, bits: MlxArray): MlxArray {
  kernel ??= new MetalKernel({
    name: "mlx_bun_token_bitmask",
    inputNames: ["logits", "bits"],
    outputNames: ["out"],
    source: String.raw`
      const uint i = thread_position_in_grid.x;
      if (i >= SIZE) return;
      const uint id = i % V;
      const uint word = uint(bits[id >> 5]);
      const bool valid = ((word >> (id & 31)) & 1u) != 0;
      out[i] = logits[i] + T(valid ? 0.0f : -INFINITY);
    `,
  });
  return kernel.apply([logits, bits], {
    outputs: [{ shape: logits.shape, dtype: logits.dtype }],
    grid: [logits.size, 1, 1],
    threadGroup: [128, 1, 1],
    templateDtypes: { T: logits.dtype },
    templateInts: { V: logits.shape.at(-1)!, SIZE: logits.size },
  })[0]!;
}

/** Apply one little-endian token bitmask to every row along the final axis.
 * Borrow logits; return an owned lazy result. Copy the mutable host bits now,
 * so a matcher can advance before GPU evaluation. Missing words reject tokens.
 * Preserve the additive-mask expression, including NaNs and signed zero.
 * Shape-specialized compilation handles bf16/f16/f32 and strided inputs. */
export function applyTokenBitmask(logits: MlxArray, bits: Int32Array): MlxArray {
  const vocab = logits.shape.at(-1);
  if (!vocab || logits.size === 0 || logits.size > 0x7fffffff)
    throw new Error("token bitmask requires nonempty logits with at most 2^31-1 elements");
  if (![Dtype.bfloat16, Dtype.float16, Dtype.float32].includes(logits.dtype))
    throw new Error("token bitmask requires bf16, f16 or f32 logits");
  const copy = new Int32Array(Math.ceil(vocab / 32));
  copy.set(bits.subarray(0, copy.length));
  const deviceBits = MlxArray.fromInt32(copy, [copy.length]);
  try {
    compiled ??= new CompiledFunction(([x, mask]) => [maskGraph(x!, mask!)], false);
    return compiled.apply([logits, deviceBits])[0]!;
  } finally { deviceBits.dispose(); }
}
