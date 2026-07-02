// Functional op layer over MlxArray. Parity-critical conventions:
// - Python-float scalars in mlx promote weakly (bf16 array × float →
//   bf16, scalar cast to bf16 first). `scalarLike` replicates that.
// - Op composition order mirrors mlx-lm exactly; see model/gemma4.ts.

import { ptr, read } from "bun:ffi";
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

export function sigmoid(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("sigmoid", (o) => C.mlx_sigmoid(o, a.handle, s)));
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

export function layerNorm(
  x: MlxArray, weight: MlxArray | null, bias: MlxArray | null, eps: number,
  s: S = gpuStream,
): MlxArray {
  return new MlxArray(
    outArray("fast_layer_norm", (o) =>
      C.mlx_fast_layer_norm(o, x.handle, weight?.handle ?? 0n, bias?.handle ?? 0n, eps, s),
    ),
  );
}

export function matmul(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("matmul", (o) => C.mlx_matmul(o, a.handle, b.handle, s)));
}

/** Materialize a row-major contiguous copy (needed before rawBytes on views). */
export function contiguous(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("contiguous", (o) => C.mlx_contiguous(o, a.handle, false, s)),
  );
}

export function logicalOr(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("logical_or", (o) => C.mlx_logical_or(o, a.handle, b.handle, s)),
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

/** fast::rope with every knob exposed (traditional + scale), for the
 *  universal rope factory (rope_utils.initialize_rope port). The plain
 *  `rope` above stays byte-identical for existing call sites. */
export function ropeScaled(
  x: MlxArray, dims: number, traditional: boolean, base: number | null,
  scale: number, offset: number, freqs: MlxArray | null, s: S = gpuStream,
): MlxArray {
  return new MlxArray(
    outArray("fast_rope", (o) =>
      C.mlx_fast_rope(
        o, x.handle, dims, traditional, optFloat(base), scale, offset,
        freqs?.handle ?? 0n, s,
      ),
    ),
  );
}

/** fast::rope with the position offset as an ARRAY (int32 scalar) instead
 *  of a baked int — required inside compiled decode graphs, where the
 *  offset changes every step but the graph must not. Same kernel as
 *  `rope`; bit-exactness vs the static form is asserted in
 *  tests/compile.test.ts. */
export function ropeDynamic(
  x: MlxArray, dims: number, base: number | null, offset: MlxArray,
  freqs: MlxArray | null, s: S = gpuStream,
): MlxArray {
  return new MlxArray(
    outArray("fast_rope_dynamic", (o) =>
      C.mlx_fast_rope_dynamic(
        o, x.handle, dims, false, optFloat(base), 1.0, offset.handle,
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

/** Gathered quantized matmul over stacked expert weights (MoE).
 *  x [..., 1, K] with rhs_indices [...] selecting the expert per row;
 *  port of mx.gather_qmm as QuantizedSwitchLinear uses it. */
export function gatherQmm(
  x: MlxArray, w: MlxArray, scales: MlxArray, biases: MlxArray | null,
  rhsIndices: MlxArray, spec: QuantSpec, sortedIndices: boolean,
  transpose = true, s: S = gpuStream,
): MlxArray {
  return new MlxArray(
    outArray("gather_qmm", (o) =>
      C.mlx_gather_qmm(
        o, x.handle, w.handle, scales.handle, biases?.handle ?? 0n,
        0n /* lhs_indices */, rhsIndices.handle, transpose,
        optInt(spec.groupSize), optInt(spec.bits), ptr(cstr(spec.mode)),
        sortedIndices, s,
      ),
    ),
  );
}

export function floorDivide(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("floor_divide", (o) => C.mlx_floor_divide(o, a.handle, b.handle, s)),
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

export function erf(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("erf", (o) => C.mlx_erf(o, a.handle, s)));
}

/** nn.gelu (PRECISE, erf-based): x · (1 + erf(x/√2)) / 2 — composed exactly
 *  as mlx's python source (weak scalars promote to x's dtype). Used by the
 *  gemma-1 gated MLP and starcoder2's plain MLP; distinct from geluApprox
 *  (gelu_pytorch_tanh). */
export function geluPrecise(x: MlxArray, s: S = gpuStream): MlxArray {
  const sqrt2 = scalarLike(Math.sqrt(2), x);
  const xs = div(x, sqrt2, s); // x / math.sqrt(2) — division, not mul-by-reciprocal
  const e = erf(xs, s);
  const one = scalarLike(1, x);
  const e1 = add(one, e, s);
  const xe = mul(x, e1, s);
  const two = scalarLike(2, x);
  const out = div(xe, two, s); // (...) / 2
  for (const a of [sqrt2, xs, e, one, e1, xe, two]) a.dispose();
  return out;
}

/** mx.addmm(c, a, b): a@b + c fused (α=β=1) — nn.Linear's bias path
 *  (`mx.addmm(bias, x, weight.T)`). */
export function addmm(c: MlxArray, a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("addmm", (o) => C.mlx_addmm(o, c.handle, a.handle, b.handle, 1.0, 1.0, s)),
  );
}

export function exp(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("exp", (o) => C.mlx_exp(o, a.handle, s)));
}

export function cos(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("cos", (o) => C.mlx_cos(o, a.handle, s)));
}

export function sin(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("sin", (o) => C.mlx_sin(o, a.handle, s)));
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

/** Cumulative maximum along `axis` (inclusive, forward) — mlx.core.cummax. */
export function cummax(a: MlxArray, axis: number, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("cummax", (o) => C.mlx_cummax(o, a.handle, axis, false, true, s)),
  );
}

export function where(cond: MlxArray, x: MlxArray, y: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("where", (o) => C.mlx_where(o, cond.handle, x.handle, y.handle, s)),
  );
}

// arange is built host-side and uploaded. The original mlx_arange binding
// broke once the calling path got JIT-optimized; a standalone repro
// (repro/bun-ffi-f64/) traced the root cause to a Bun bug: after DFG
// tier-up, typed-array reads following a bun:ffi call return stale values
// (the JIT eliminates the load across the native call). Not f64 marshaling
// — args reach C intact. See PLAN.md Phase 4 findings. Large constant
// ranges (topP's vocab arange) are cached for the process lifetime.
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

export function lessEqual(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("less_equal", (o) => C.mlx_less_equal(o, a.handle, b.handle, s)));
}

export function logicalNot(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("logical_not", (o) => C.mlx_logical_not(o, a.handle, s)));
}

export function equal(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("equal", (o) => C.mlx_equal(o, a.handle, b.handle, s)));
}

/** Reduce-all to a scalar (mlx.core.all). */
export function allReduce(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("all", (o) => C.mlx_all(o, a.handle, false, s)));
}

/** any along one axis (mlx.core.any). */
export function anyAxis(a: MlxArray, axis: number, keepdims: boolean, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("any_axis", (o) => C.mlx_any_axis(o, a.handle, axis, keepdims, s)));
}

/** Read a 0-d/1-elem boolean array to host (forces eval). */
export function itemBool(a: MlxArray): boolean {
  const u = a.astype(Dtype.uint32);
  try {
    return itemUint32(u) !== 0;
  } finally {
    u.dispose();
  }
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

/** mx.slice with start as an ARRAY and the output shape as constants —
 *  the shapeless-compile-safe slice (mlx's Slice primitive cannot infer
 *  output shapes; DynamicSlice's output shape IS sliceSize). Used only
 *  inside compiled-decode traces for subrange slices whose bounds are
 *  per-layer constants (full-range slices get simplified away and need
 *  no substitute). Values identical to `slice`. */
export function sliceDynamic(
  a: MlxArray, start: MlxArray, axes: number[], sliceSize: number[], s: S = gpuStream,
): MlxArray {
  const ax = new Int32Array(axes);
  const sz = new Int32Array(sliceSize);
  return new MlxArray(
    outArray("slice_dynamic", (o) =>
      C.mlx_slice_dynamic(
        o, a.handle, start.handle,
        ptr(ax), BigInt(ax.length), ptr(sz), BigInt(sz.length), s,
      ),
    ),
  );
}

/** slice_update with the start index as an ARRAY (one int32 per entry in
 *  `axes`) — the compiled-decode form of the per-step cache write. Same
 *  write as `sliceUpdate`; bit-exactness vs the static form is asserted
 *  in tests/compile.test.ts. */
export function sliceUpdateDynamic(
  src: MlxArray, update: MlxArray, start: MlxArray, axes: number[], s: S = gpuStream,
): MlxArray {
  const ax = new Int32Array(axes);
  return new MlxArray(
    outArray("slice_update_dynamic", (o) =>
      C.mlx_slice_update_dynamic(
        o, src.handle, update.handle, start.handle,
        ptr(ax), BigInt(ax.length), s,
      ),
    ),
  );
}

export function randomKey(seed: bigint): MlxArray {
  return new MlxArray(outArray("random_key", (o) => C.mlx_random_key(o, seed)));
}

/** Set the GLOBAL mlx PRNG seed (mlx.core.random.seed). Calls to randint/etc
 *  with a null key thread the global key, so seeding then calling in the same
 *  order as the reference reproduces its draws bit-for-bit. */
export function randomSeed(seed: bigint): void {
  if (C.mlx_random_seed(seed) !== 0) throw new Error(`mlx_random_seed failed: ${takeMlxError() ?? ""}`);
}

/** Uniform integers in [low, high) — mlx.core.random.randint. With key=null it
 *  uses (and advances) the global key, matching mx.random.randint exactly. */
export function randint(
  low: number, high: number, shape: number[], dtype: Dtype,
  key: MlxArray | null = null, s: S = gpuStream,
): MlxArray {
  const buf = new Int32Array(shape);
  const lo = MlxArray.fromInt32(new Int32Array([low]), []);
  const hi = MlxArray.fromInt32(new Int32Array([high]), []);
  try {
    return new MlxArray(
      outArray("random_randint", (o) =>
        C.mlx_random_randint(o, lo.handle, hi.handle, ptr(buf), BigInt(shape.length), dtype, key?.handle ?? 0n, s),
      ),
    );
  } finally {
    lo.dispose();
    hi.dispose();
  }
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

/** Read a scalar uint32 (forces eval). Hot per-token path: the out-param
 *  is read back via read.u32, never out[0] (DFG stale-read bug — see
 *  outArray in ffi.ts). */
export function itemUint32(a: MlxArray): number {
  a.eval();
  const out = new Uint32Array(1);
  const p = ptr(out);
  if (C.mlx_array_item_uint32(p, a.handle) !== 0)
    throw new Error("mlx_array_item_uint32 failed");
  return read.u32(p, 0);
}

export function fromInt32(data: number[], shape: number[]): MlxArray {
  return MlxArray.fromInt32(new Int32Array(data), shape);
}

// --- quantized KV support (Phase 6) ---------------------------------------

export interface QuantizedTensor {
  packed: MlxArray;
  scales: MlxArray;
  biases: MlxArray;
}

/** mx.quantize: w → (packed u32, scales, biases). `mode` defaults to the
 *  mlx-standard "affine" scheme; the quantizer seam may pass others. */
export function quantize(
  w: MlxArray, groupSize: number, bits: number, mode = "affine", s: S = gpuStream,
): QuantizedTensor {
  const slot = new BigUint64Array([C.mlx_vector_array_new()]);
  const slotPtr = ptr(slot);
  const status = C.mlx_quantize(
    slotPtr, w.handle, optInt(groupSize), optInt(bits), ptr(cstr(mode)), 0n, s,
  );
  if (status !== 0) throw new Error(`quantize failed: ${takeMlxError() ?? ""}`);
  const vec = read.u64(slotPtr, 0);
  const get = (i: number): MlxArray => {
    const aSlot = new BigUint64Array([C.mlx_array_new()]);
    const aPtr = ptr(aSlot);
    if (C.mlx_vector_array_get(aPtr, vec, BigInt(i)) !== 0)
      throw new Error("vector_array_get failed");
    return new MlxArray(read.u64(aPtr, 0));
  };
  try {
    return { packed: get(0), scales: get(1), biases: get(2) };
  } finally {
    C.mlx_vector_array_free(vec);
  }
}

// --- training: elementwise / reductions / random ------------------------

/** Stops gradient flow through `a` (identity forward; ∂=0). DPO reference
 *  logprobs are stop_gradient'd before the policy forward. */
export function stopGradient(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("stop_gradient", (o) => C.mlx_stop_gradient(o, a.handle, s)));
}

export function log(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("log", (o) => C.mlx_log(o, a.handle, s)));
}

export function logaddexp(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("logaddexp", (o) => C.mlx_logaddexp(o, a.handle, b.handle, s)));
}

export function sqrt(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("sqrt", (o) => C.mlx_sqrt(o, a.handle, s)));
}

export function rsqrt(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("rsqrt", (o) => C.mlx_rsqrt(o, a.handle, s)));
}

export function square(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("square", (o) => C.mlx_square(o, a.handle, s)));
}

export function abs(a: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("abs", (o) => C.mlx_abs(o, a.handle, s)));
}

/** Reduce-mean over all elements → scalar (keepdims=false) or [1,…]. */
export function meanAll(a: MlxArray, keepdims = false, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("mean", (o) => C.mlx_mean(o, a.handle, keepdims, s)));
}

export function meanAxis(a: MlxArray, axis: number, keepdims: boolean, s: S = gpuStream): MlxArray {
  return new MlxArray(outArray("mean_axis", (o) => C.mlx_mean_axis(o, a.handle, axis, keepdims, s)));
}

export function clip(a: MlxArray, lo: MlxArray | null, hi: MlxArray | null, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("clip", (o) => C.mlx_clip(o, a.handle, lo?.handle ?? 0n, hi?.handle ?? 0n, s)),
  );
}

/** mx.random.normal(shape, dtype, loc, scale, key). key may be null. */
export function randomNormal(
  shape: number[], dtype: Dtype, loc: number, scale: number,
  key: MlxArray | null, s: S = gpuStream,
): MlxArray {
  const buf = new Int32Array(shape);
  return new MlxArray(
    outArray("random_normal", (o) =>
      C.mlx_random_normal(o, ptr(buf), BigInt(shape.length), dtype, loc, scale, key?.handle ?? 0n, s),
    ),
  );
}

/** mx.random.uniform(low, high, shape, dtype, key). low/high are scalars.
 *  Matches mlx-lm LoRALinear A init: uniform(-1/√in, +1/√in). */
export function randomUniform(
  shape: number[], dtype: Dtype, low: number, high: number,
  key: MlxArray | null, s: S = gpuStream,
): MlxArray {
  const buf = new Int32Array(shape);
  const lo = MlxArray.fromFloat32(new Float32Array([low]), []);
  const hi = MlxArray.fromFloat32(new Float32Array([high]), []);
  try {
    return new MlxArray(
      outArray("random_uniform", (o) =>
        C.mlx_random_uniform(o, lo.handle, hi.handle, ptr(buf), BigInt(shape.length), dtype, key?.handle ?? 0n, s),
      ),
    );
  } finally {
    lo.dispose();
    hi.dispose();
  }
}

/** mx.random.split(key, num) → [num, 2] uint32 subkeys. */
export function randomSplitNum(key: MlxArray, num: number, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("random_split", (o) => C.mlx_random_split_num(o, key.handle, num, s)),
  );
}

export function softmaxAxis(a: MlxArray, axis: number, precise: boolean, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("softmax", (o) => C.mlx_softmax_axis(o, a.handle, axis, precise, s)),
  );
}

export function maxAxis(a: MlxArray, axis: number, keepdims: boolean, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("max_axis", (o) => C.mlx_max_axis(o, a.handle, axis, keepdims, s)),
  );
}

export function sumAxis(a: MlxArray, axis: number, keepdims: boolean, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("sum_axis", (o) => C.mlx_sum_axis(o, a.handle, axis, keepdims, s)),
  );
}

/** View-preserving expand_dims (reshape on a non-contiguous view copies —
 *  different kernel path, different reduction rounding; see Phase 6). */
export function expandDims(a: MlxArray, axis: number, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("expand_dims", (o) => C.mlx_expand_dims(o, a.handle, axis, s)),
  );
}

export function maximum(a: MlxArray, b: MlxArray, s: S = gpuStream): MlxArray {
  return new MlxArray(
    outArray("maximum", (o) => C.mlx_maximum(o, a.handle, b.handle, s)),
  );
}

/** quantized_matmul against a quantized tensor (x @ qt^T or x @ qt). */
export function quantizedMatmulQT(
  x: MlxArray, qt: QuantizedTensor, transpose: boolean,
  groupSize: number, bits: number, s: S = gpuStream,
): MlxArray {
  return new MlxArray(
    outArray("quantized_matmul", (o) =>
      C.mlx_quantized_matmul(
        o, x.handle, qt.packed.handle, qt.scales.handle, qt.biases.handle,
        transpose, optInt(groupSize), optInt(bits), ptr(cstr("affine")), s,
      ),
    ),
  );
}

/** nn.Conv1d: input [B, L, C_in], weight [C_out, K, C_in/groups] → [B, L', C_out].
 *  Depthwise (groups == channels) for the gated-DeltaNet causal conv; the model
 *  left-pads with the conv-state cache, so padding is 0 here. */
export function conv1d(
  input: MlxArray, weight: MlxArray, stride = 1, padding = 0, dilation = 1,
  groups = 1, s: S = gpuStream,
): MlxArray {
  return new MlxArray(
    outArray("conv1d", (o) =>
      C.mlx_conv1d(o, input.handle, weight.handle, stride, padding, dilation, groups, s),
    ),
  );
}

/** mx.split(a, indices, axis): split at the given boundary offsets along `axis`
 *  into N+1 contiguous slices (mirrors numpy/mlx split-by-indices). */
export function split(a: MlxArray, indices: number[], axis: number): MlxArray[] {
  const shape = a.shape;
  const ax = axis < 0 ? shape.length + axis : axis;
  const dim = shape[ax]!;
  const bounds = [0, ...indices, dim];
  const out: MlxArray[] = [];
  for (let i = 0; i < bounds.length - 1; i++) {
    const start = shape.map(() => 0);
    const stop = [...shape];
    start[ax] = bounds[i]!;
    stop[ax] = bounds[i + 1]!;
    out.push(a.slice(start, stop));
  }
  return out;
}

/** nn.softplus: log(1 + exp(x)) == logaddexp(x, 0). */
export function softplus(a: MlxArray, s: S = gpuStream): MlxArray {
  const zero = scalarLike(0, a);
  const r = logaddexp(a, zero, s);
  zero.dispose();
  return r;
}

/** nn.silu: x * sigmoid(x). */
export function silu(a: MlxArray, s: S = gpuStream): MlxArray {
  const sig = sigmoid(a, s);
  const r = mul(a, sig, s);
  sig.dispose();
  return r;
}
