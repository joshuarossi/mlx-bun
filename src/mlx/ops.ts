// Functional op layer over MlxArray. Parity-critical conventions:
// - Python-float scalars in mlx promote weakly (bf16 array × float →
//   bf16, scalar cast to bf16 first). `scalarLike` replicates that.
// - Op composition order mirrors mlx-lm exactly; see model/gemma4.ts.

import { ptr } from "bun:ffi";
import { C, Dtype, type MlxHandle, optFloat, optInt, outArray, takeMlxError } from "./ffi";
import { MlxArray, gpuStream } from "./array";

const cstrCache = new Map<string, Buffer>();
function cstr(s: string): Buffer {
  let b = cstrCache.get(s);
  if (!b) {
    b = Buffer.from(s + "\0", "utf8");
    cstrCache.set(s, b);
  }
  return b;
}

type S = MlxHandle;

export function add(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("add", (o) => C.mlx_add(o, a.handle, b.handle, s)));
}

export function sub(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("subtract", (o) => C.mlx_subtract(o, a.handle, b.handle, s)));
}

export function mul(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("multiply", (o) => C.mlx_multiply(o, a.handle, b.handle, s)));
}

export function div(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("divide", (o) => C.mlx_divide(o, a.handle, b.handle, s)));
}

export function tanh(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("tanh", (o) => C.mlx_tanh(o, a.handle, s)));
}

/** Scalar constant with the same dtype as `like` (python weak-scalar semantics). */
export function scalarLike(value: number, like: MlxArray): MlxArray {
  const f = MlxArray.fromFloat32(new Float32Array([value]), []);
  if (like.dtype === Dtype.float32) return f;
  const cast = f.astype(like.dtype);
  f.dispose();
  return cast;
}

export function mulScalar(a: MlxArray, value: number, s: S = gpuStream): MlxArray {
  const k = scalarLike(value, a);
  const r = mul(a, k, s);
  k.dispose();
  return r;
}

export function rmsNorm(
  x: MlxArray, weight: MlxArray | null, eps: number, s: S = gpuStream,
): MlxArray {
  return new MlxArray(
    outArray("fast_rms_norm", (o) =>
      C.mlx_fast_rms_norm(o, x.handle, weight?.handle ?? 0n, eps, s),
    ),
  );
}

export function rope(
  x: MlxArray, dims: number, base: number | null, offset: number,
  freqs: MlxArray | null, s: S = gpuStream,
): MlxArray {
  return new MlxArray(
    outArray("fast_rope", (o) =>
      C.mlx_fast_rope(
        o, x.handle, dims, false, optFloat(base), 1.0, offset,
        freqs?.handle ?? 0n, s,
      ),
    ),
  );
}

export function sdpa(
  q: MlxArray, k: MlxArray, v: MlxArray, scale: number,
  maskMode: "" | "causal" | "array", maskArr: MlxArray | null = null,
  s: S = gpuStream,
): MlxArray {
  return new MlxArray(
    outArray("fast_sdpa", (o) =>
      C.mlx_fast_scaled_dot_product_attention(
        o, q.handle, k.handle, v.handle, scale, ptr(cstr(maskMode)),
        maskArr?.handle ?? 0n, 0n, s,
      ),
    ),
  );
}

export interface QuantSpec {
  bits: number;
  groupSize: number;
  mode: string;
}

export function quantizedMatmul(
  x: MlxArray, w: MlxArray, scales: MlxArray, biases: MlxArray | null,
  spec: QuantSpec, transpose = true, s: S = gpuStream,
): MlxArray {
  return new MlxArray(
    outArray("quantized_matmul", (o) =>
      C.mlx_quantized_matmul(
        o, x.handle, w.handle, scales.handle, biases?.handle ?? 0n,
        transpose, optInt(spec.groupSize), optInt(spec.bits),
        ptr(cstr(spec.mode)), s,
      ),
    ),
  );
}

export function dequantize(
  w: MlxArray, scales: MlxArray, biases: MlxArray | null, spec: QuantSpec,
  s: S = gpuStream,
): MlxArray {
  return new MlxArray(
    outArray("dequantize", (o) =>
      C.mlx_dequantize(
        o, w.handle, scales.handle, biases?.handle ?? 0n,
        optInt(spec.groupSize), optInt(spec.bits), ptr(cstr(spec.mode)),
        0n, optInt(null), s,
      ),
    ),
  );
}

export function takeAxis(a: MlxArray, indices: MlxArray, axis: number, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("take_axis", (o) => C.mlx_take_axis(o, a.handle, indices.handle, axis, s)),
  );
}

export function reshape(a: MlxArray, shape: number[], s: S = gpuStream): MlxArray {
  const buf = new Int32Array(shape);
  return new MlxArray(
    outArray("reshape", (o) => C.mlx_reshape(o, a.handle, ptr(buf), BigInt(shape.length), s)),
  );
}

export function transposeAxes(a: MlxArray, axes: number[], s: S = gpuStream): MlxArray {
  const buf = new Int32Array(axes);
  return new MlxArray(
    outArray("transpose", (o) => C.mlx_transpose_axes(o, a.handle, ptr(buf), BigInt(axes.length), s)),
  );
}

export function argmaxAxis(a: MlxArray, axis: number, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("argmax_axis", (o) => C.mlx_argmax_axis(o, a.handle, axis, false, s)),
  );
}

export function concatAxis(arrays: MlxArray[], axis: number, s: S = gpuStream): MlxArray {
  const handles = new BigUint64Array(arrays.map((a) => a.handle));
  const vec = C.mlx_vector_array_new_data(ptr(handles), BigInt(arrays.length));
  try {
    return new MlxArray(
      outArray("concatenate", (o) => C.mlx_concatenate_axis(o, vec, axis, s)),
    );
  } finally {
    C.mlx_vector_array_free(vec);
  }
}

export function pow(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("power", (o) => C.mlx_power(o, a.handle, b.handle, s)));
}

/** nn.gelu_approx: 0.5 x (1 + tanh(√(2/π) (x + 0.044715 x³))) — composed
 *  exactly as mlx's python source: x**3 is mx.power (NOT x·x·x — they
 *  round differently in bf16), scalars promote weakly to x's dtype. */
export function geluApprox(x: MlxArray, s: S = gpuStream): MlxArray {
  const three = scalarLike(3, x);
  const x3 = pow(x, three, s);
  const cx3 = mulScalar(x3, 0.044715, s);
  const inner = add(x, cx3, s);
  const scaled = mulScalar(inner, Math.sqrt(2 / Math.PI), s);
  const t = tanh(scaled, s);
  const one = scalarLike(1, x);
  const t1 = add(one, t, s);
  const halfx = mulScalar(x, 0.5, s);
  const out = mul(halfx, t1, s);
  for (const a of [three, x3, cx3, inner, scaled, t, one, t1, halfx]) a.dispose();
  return out;
}

export function exp(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("exp", (o) => C.mlx_exp(o, a.handle, s)));
}

export function neg(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("negative", (o) => C.mlx_negative(o, a.handle, s)));
}

export function argsortAxis(a: MlxArray, axis: number, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("argsort", (o) => C.mlx_argsort_axis(o, a.handle, axis, s)));
}

export function argpartitionAxis(a: MlxArray, kth: number, axis: number, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("argpartition", (o) => C.mlx_argpartition_axis(o, a.handle, kth, axis, s)),
  );
}

export function takeAlongAxis(a: MlxArray, idx: MlxArray, axis: number, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("take_along_axis", (o) => C.mlx_take_along_axis(o, a.handle, idx.handle, axis, s)),
  );
}

export function putAlongAxis(
  a: MlxArray, idx: MlxArray, values: MlxArray, axis: number, s: S = gpuStream,
): MlxArray {
  return new MlxArray(
    outArray("put_along_axis", (o) =>
      C.mlx_put_along_axis(o, a.handle, idx.handle, values.handle, axis, s),
    ),
  );
}

export function cumsum(a: MlxArray, axis: number, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("cumsum", (o) => C.mlx_cumsum(o, a.handle, axis, false, true, s)),
  );
}

export function where(cond: MlxArray, x: MlxArray, y: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("where", (o) => C.mlx_where(o, cond.handle, x.handle, y.handle, s)),
  );
}

// arange is built host-side and uploaded: mlx_arange is our only binding
// with f64 args, and bun:ffi f64 marshaling proved unreliable once the
// calling path got JIT-optimized (args arrive as NaN at the C++ layer —
// "[arange] Cannot compute length"; identical args pass in isolation).
// See PLAN.md Phase 4 findings. Large constant ranges (topP's vocab
// arange) are cached for the process lifetime.
const arangeCache = new Map<string, MlxArray>();
const ARANGE_CACHE_MIN = 65536;

export function arange(start: number, stop: number, step: number, dtype: Dtype, s: S = gpuStream): MlxArray {
  if (!Number.isInteger(start) || !Number.isInteger(step) || step === 0)
    throw new Error(`arange: integer start/step required (${start}, ${stop}, ${step})`);
  const n = Math.max(0, Math.ceil((stop - start) / step));
  const key = `${start}|${step}|${n}|${dtype}`;
  const cached = arangeCache.get(key);
  if (cached) return cached.slice([0], [n], s);

  const data = new Int32Array(n);
  for (let i = 0; i < n; i++) data[i] = start + i * step;
  let arr = MlxArray.fromInt32(data, [n]);
  if (dtype !== Dtype.int32) {
    const cast = arr.astype(dtype, s);
    arr.dispose();
    arr = cast;
  }
  if (n >= ARANGE_CACHE_MIN) {
    arangeCache.set(key, arr);
    return arr.slice([0], [n], s);
  }
  return arr;
}

export function logsumexpAxis(a: MlxArray, axis: number, keepdims: boolean, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("logsumexp", (o) => C.mlx_logsumexp_axis(o, a.handle, axis, keepdims, s)),
  );
}

export function greaterEqual(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("greater_equal", (o) => C.mlx_greater_equal(o, a.handle, b.handle, s)),
  );
}

export function less(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("less", (o) => C.mlx_less(o, a.handle, b.handle, s)));
}

export function logicalAnd(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("logical_and", (o) => C.mlx_logical_and(o, a.handle, b.handle, s)),
  );
}

export function zeros(shape: number[], dtype: Dtype, s: S = gpuStream): MlxArray {
  const buf = new Int32Array(shape);
  return new MlxArray(
    outArray("zeros", (o) => C.mlx_zeros(o, ptr(buf), BigInt(shape.length), dtype, s)),
  );
}

export function sliceUpdate(
  src: MlxArray, update: MlxArray, start: number[], stop: number[], s: S = gpuStream,
): MlxArray {
  const st = new Int32Array(start);
  const sp = new Int32Array(stop);
  const strides = new Int32Array(start.map(() => 1));
  return new MlxArray(
    outArray("slice_update", (o) =>
      C.mlx_slice_update(
        o, src.handle, update.handle,
        ptr(st), BigInt(st.length), ptr(sp), BigInt(sp.length),
        ptr(strides), BigInt(strides.length), s,
      ),
    ),
  );
}

export function randomKey(seed: bigint): MlxArray {
  return new MlxArray(outArray("random_key", (o) => C.mlx_random_key(o, seed)));
}

export function randomCategorical(logits: MlxArray, key: MlxArray | null, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("categorical", (o) =>
      C.mlx_random_categorical(o, logits.handle, -1, key?.handle ?? 0n, s),
    ),
  );
}

/** Eval several arrays in one call (e.g. cache state after a prefill chunk). */
export function evalAll(arrays: MlxArray[]): void {
  const handles = new BigUint64Array(arrays.map((a) => a.handle));
  const vec = C.mlx_vector_array_new_data(ptr(handles), BigInt(arrays.length));
  try {
    if (C.mlx_eval(vec) !== 0) throw new Error(`mlx_eval failed: ${takeMlxError() ?? ""}`);
  } finally {
    C.mlx_vector_array_free(vec);
  }
}

/** Kick off async evaluation (decode pipelining). */
export function asyncEvalAll(arrays: MlxArray[]): void {
  const handles = new BigUint64Array(arrays.map((a) => a.handle));
  const vec = C.mlx_vector_array_new_data(ptr(handles), BigInt(arrays.length));
  try {
    if (C.mlx_async_eval(vec) !== 0) throw new Error(`mlx_async_eval failed: ${takeMlxError() ?? ""}`);
  } finally {
    C.mlx_vector_array_free(vec);
  }
}

/** Read a scalar uint32 (forces eval). */
export function itemUint32(a: MlxArray): number {
  a.eval();
  const out = new Uint32Array(1);
  if (C.mlx_array_item_uint32(ptr(out), a.handle) !== 0)
    throw new Error("mlx_array_item_uint32 failed");
  return out[0]!;
}

export function fromInt32(data: number[], shape: number[]): MlxArray {
  return MlxArray.fromInt32(new Int32Array(data), shape);
}
