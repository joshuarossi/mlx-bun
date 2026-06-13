// Raw bun:ffi bindings to libmlxc.
//
// Calling convention (verified in Phase 0, see PLAN.md):
// - Every mlx-c handle is a one-pointer struct `{ void* ctx }` — passed and
//   returned by value in a single register on arm64, so FFIType.u64 works.
// - Out-params (`mlx_array* res`) are a pointer to that slot: allocate a
//   BigUint64Array(1), pass ptr(), reread after the call via read.u64 —
//   NOT slot[0] (DFG stale-read bug, see rule above outArray).
// - Ops return int status; 0 = success.
// - mlx_optional_int is `{ int32 value; bool has_value }` = 8 bytes, by
//   value in one register: value in bits 0..31, has_value at bit 32.

import { dlopen, FFIType, ptr, read } from "bun:ffi";
import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { nativePackDir } from "../native-pack";

const { ptr: P, i32, u64, f32, cstring } = FFIType;

/** libmlxc resolution, in order: explicit env override → next to the
 *  executable (the `bun build --compile` sidecar layout, where
 *  libmlxc.dylib + libmlx.dylib + mlx.metallib ship beside the binary —
 *  see docs/embedding.md) → the downloaded native-pack cache
 *  (src/native-pack.ts; populated on first run by the CLI) → homebrew
 *  (arm64, then Intel prefix). Keep in sync with nativeRuntimeDir(). */
function resolveLibmlxc(): string {
  const env = process.env.MLX_BUN_LIBMLXC;
  if (env) return env;
  const beside = join(dirname(process.execPath), "libmlxc.dylib");
  if (existsSync(beside)) return beside;
  const cached = join(nativePackDir(), "libmlxc.dylib");
  if (existsSync(cached)) return cached;
  for (const p of ["/opt/homebrew/lib/libmlxc.dylib", "/usr/local/lib/libmlxc.dylib"])
    if (existsSync(p)) return p;
  // let dlopen produce the canonical error message for the default path
  return "/opt/homebrew/lib/libmlxc.dylib";
}

export const LIBMLXC_PATH = resolveLibmlxc();

export const C = dlopen(LIBMLXC_PATH, {
  // array lifecycle
  mlx_array_new: { args: [], returns: u64 },
  mlx_array_new_data: { args: [P, P, i32, i32], returns: u64 },
  mlx_array_new_data_managed_payload: { args: [P, P, i32, i32, P, P], returns: u64 },
  mlx_array_free: { args: [u64], returns: i32 },
  mlx_array_eval: { args: [u64], returns: i32 },
  // array metadata
  mlx_array_ndim: { args: [u64], returns: u64 },
  mlx_array_shape: { args: [u64], returns: P },
  mlx_array_dim: { args: [u64, i32], returns: i32 },
  mlx_array_dtype: { args: [u64], returns: i32 },
  mlx_array_size: { args: [u64], returns: u64 },
  mlx_array_nbytes: { args: [u64], returns: u64 },
  // data access (forces eval/copy to host-visible memory)
  mlx_array_data_float32: { args: [u64], returns: P },
  mlx_array_data_float16: { args: [u64], returns: P },
  mlx_array_data_bfloat16: { args: [u64], returns: P },
  mlx_array_data_uint32: { args: [u64], returns: P },
  mlx_array_item_float32: { args: [P, u64], returns: i32 },
  // streams
  mlx_default_gpu_stream_new: { args: [], returns: u64 },
  mlx_default_cpu_stream_new: { args: [], returns: u64 },
  mlx_stream_free: { args: [u64], returns: i32 },
  // eval control (both take mlx_vector_array)
  mlx_eval: { args: [u64], returns: i32 },
  mlx_async_eval: { args: [u64], returns: i32 },
  // memory introspection / limits
  mlx_get_active_memory: { args: [P], returns: i32 },
  mlx_get_peak_memory: { args: [P], returns: i32 },
  mlx_reset_peak_memory: { args: [], returns: i32 },
  // mlx_device_info is a one-pointer struct like every other handle
  mlx_device_info_new: { args: [], returns: u64 },
  mlx_device_info_get: { args: [P, u64], returns: i32 },
  mlx_device_info_free: { args: [u64], returns: i32 },
  mlx_device_info_get_size: { args: [P, u64, cstring], returns: i32 },
  mlx_get_default_device: { args: [P], returns: i32 },
  mlx_device_free: { args: [u64], returns: i32 },
  mlx_synchronize: { args: [u64], returns: i32 },
  mlx_get_cache_memory: { args: [P], returns: i32 },
  mlx_clear_cache: { args: [], returns: i32 },
  mlx_set_memory_limit: { args: [P, u64], returns: i32 },
  mlx_set_wired_limit: { args: [P, u64], returns: i32 },
  // io: native lazy safetensors loader (Load primitive is CPU-only —
  // always pass the CPU stream; GPU ops consume the unified buffers)
  mlx_load_safetensors: { args: [P, P, cstring, u64], returns: i32 },
  mlx_map_string_to_array_new: { args: [], returns: u64 },
  mlx_map_string_to_array_free: { args: [u64], returns: i32 },
  mlx_map_string_to_array_get: { args: [P, u64, cstring], returns: i32 },
  mlx_map_string_to_string_new: { args: [], returns: u64 },
  mlx_map_string_to_string_free: { args: [u64], returns: i32 },
  // fast fused ops
  // (res, x, weight may-be-null, eps, stream)
  mlx_fast_rms_norm: { args: [P, u64, u64, f32, u64], returns: i32 },
  // (res, x, weight may-be-null, bias may-be-null, eps, stream)
  mlx_fast_layer_norm: { args: [P, u64, u64, u64, f32, u64], returns: i32 },
  mlx_matmul: { args: [P, u64, u64, u64], returns: i32 },
  mlx_contiguous: { args: [P, u64, FFIType.bool, u64], returns: i32 },
  // (res: mlx_vector_array*, w, opt group_size, opt bits, mode, global_scale, stream)
  mlx_quantize: { args: [P, u64, u64, u64, cstring, u64, u64], returns: i32 },
  mlx_vector_array_get: { args: [P, u64, u64], returns: i32 },
  mlx_vector_array_new: { args: [], returns: u64 },
  mlx_softmax_axis: { args: [P, u64, i32, FFIType.bool, u64], returns: i32 },
  mlx_max_axis: { args: [P, u64, i32, FFIType.bool, u64], returns: i32 },
  mlx_sum_axis: { args: [P, u64, i32, FFIType.bool, u64], returns: i32 },
  mlx_maximum: { args: [P, u64, u64, u64], returns: i32 },
  mlx_expand_dims: { args: [P, u64, i32, u64], returns: i32 },
  mlx_logical_or: { args: [P, u64, u64, u64], returns: i32 },
  // (res, x, dims, traditional, opt base, scale, offset, freqs may-be-null, stream)
  mlx_fast_rope: { args: [P, u64, i32, FFIType.bool, u64, f32, i32, u64, u64], returns: i32 },
  // (res, q, k, v, scale, mask_mode, mask may-be-null, sinks may-be-null, stream)
  mlx_fast_scaled_dot_product_attention: {
    args: [P, u64, u64, u64, f32, cstring, u64, u64, u64], returns: i32,
  },
  // ops (grown as phases need them)
  mlx_add: { args: [P, u64, u64, u64], returns: i32 },
  mlx_subtract: { args: [P, u64, u64, u64], returns: i32 },
  mlx_multiply: { args: [P, u64, u64, u64], returns: i32 },
  mlx_divide: { args: [P, u64, u64, u64], returns: i32 },
  mlx_tanh: { args: [P, u64, u64], returns: i32 },
  mlx_sigmoid: { args: [P, u64, u64], returns: i32 },
  mlx_power: { args: [P, u64, u64, u64], returns: i32 },
  mlx_take_axis: { args: [P, u64, u64, i32, u64], returns: i32 },
  mlx_reshape: { args: [P, u64, P, u64, u64], returns: i32 },
  mlx_transpose_axes: { args: [P, u64, P, u64, u64], returns: i32 },
  mlx_argmax_axis: { args: [P, u64, i32, FFIType.bool, u64], returns: i32 },
  mlx_concatenate_axis: { args: [P, u64, i32, u64], returns: i32 },
  mlx_vector_array_new_data: { args: [P, u64], returns: u64 },
  mlx_vector_array_free: { args: [u64], returns: i32 },
  mlx_array_item_uint32: { args: [P, u64], returns: i32 },
  mlx_array_item_int32: { args: [P, u64], returns: i32 },
  mlx_slice: { args: [P, u64, P, u64, P, u64, P, u64, u64], returns: i32 },
  // (res, src, update, start*, n, stop*, n, strides*, n, stream)
  mlx_slice_update: { args: [P, u64, u64, P, u64, P, u64, P, u64, u64], returns: i32 },
  mlx_zeros: { args: [P, P, u64, i32, u64], returns: i32 },
  mlx_exp: { args: [P, u64, u64], returns: i32 },
  mlx_negative: { args: [P, u64, u64], returns: i32 },
  mlx_argsort_axis: { args: [P, u64, i32, u64], returns: i32 },
  mlx_argpartition_axis: { args: [P, u64, i32, i32, u64], returns: i32 },
  mlx_take_along_axis: { args: [P, u64, u64, i32, u64], returns: i32 },
  mlx_put_along_axis: { args: [P, u64, u64, u64, i32, u64], returns: i32 },
  mlx_cumsum: { args: [P, u64, i32, FFIType.bool, FFIType.bool, u64], returns: i32 },
  mlx_where: { args: [P, u64, u64, u64, u64], returns: i32 },
  mlx_logsumexp_axis: { args: [P, u64, i32, FFIType.bool, u64], returns: i32 },
  mlx_greater_equal: { args: [P, u64, u64, u64], returns: i32 },
  mlx_less: { args: [P, u64, u64, u64], returns: i32 },
  mlx_logical_and: { args: [P, u64, u64, u64], returns: i32 },
  mlx_random_key: { args: [P, u64], returns: i32 },
  mlx_random_categorical: { args: [P, u64, i32, u64, u64], returns: i32 },
  mlx_astype: { args: [P, u64, i32, u64], returns: i32 },
  // (res, w, scales, biases, opt group_size, opt bits, mode, global_scale, opt dtype, stream)
  mlx_dequantize: { args: [P, u64, u64, u64, u64, u64, cstring, u64, u64, u64], returns: i32 },
  mlx_quantized_matmul: { args: [P, u64, u64, u64, u64, FFIType.bool, u64, u64, cstring, u64], returns: i32 },
  // (res, x, w, scales, biases?, lhs_indices?, rhs_indices?, transpose,
  //  opt group_size, opt bits, mode, sorted_indices, stream)
  mlx_gather_qmm: { args: [P, u64, u64, u64, u64, u64, u64, FFIType.bool, u64, u64, cstring, FFIType.bool, u64], returns: i32 },
  mlx_floor_divide: { args: [P, u64, u64, u64], returns: i32 },
  // compile via closures (Phase A compiled decode — optimization_plan.md).
  // mlx_closure is the usual one-pointer struct; the func-payload variant
  // carries an id we use to route the trace callback back to JS.
  mlx_closure_new: { args: [], returns: u64 },
  mlx_closure_new_func_payload: { args: [P, P, P], returns: u64 },
  mlx_closure_free: { args: [u64], returns: i32 },
  mlx_closure_apply: { args: [P, u64, u64], returns: i32 },
  mlx_compile: { args: [P, u64, FFIType.bool], returns: i32 },
  mlx_set_compile_mode: { args: [i32], returns: i32 },
  mlx_vector_array_size: { args: [u64], returns: u64 },
  mlx_vector_array_set_data: { args: [P, P, u64], returns: i32 },
  // dynamic-start variants: per-decode-step offsets enter the graph as
  // array VALUES instead of baked ints, so one compiled graph serves
  // every step (no per-step retrace).
  // (res, x, dims, traditional, opt base, scale, offset ARRAY, freqs may-be-null, stream)
  mlx_fast_rope_dynamic: { args: [P, u64, i32, FFIType.bool, u64, f32, u64, u64, u64], returns: i32 },
  // (res, src, update, start ARRAY, axes*, axes_num, stream)
  mlx_slice_update_dynamic: { args: [P, u64, u64, u64, P, u64, u64], returns: i32 },
  // (res, a, start ARRAY, axes*, axes_num, slice_size*, n, stream)
  mlx_slice_dynamic: { args: [P, u64, u64, P, u64, P, u64, u64], returns: i32 },
  // custom Metal kernels (Phase E — mx.fast.metal_kernel from Bun)
  mlx_vector_string_new_data: { args: [P, u64], returns: u64 },
  mlx_vector_string_free: { args: [u64], returns: i32 },
  // (name, input_names, output_names, source, header, ensure_row_contiguous, atomic_outputs)
  mlx_fast_metal_kernel_new: { args: [cstring, u64, u64, cstring, cstring, FFIType.bool, FFIType.bool], returns: u64 },
  mlx_fast_metal_kernel_free: { args: [u64], returns: FFIType.void },
  // (outputs: mlx_vector_array*, kernel, inputs, config, stream)
  mlx_fast_metal_kernel_apply: { args: [P, u64, u64, u64, u64], returns: i32 },
  mlx_fast_metal_kernel_config_new: { args: [], returns: u64 },
  mlx_fast_metal_kernel_config_free: { args: [u64], returns: FFIType.void },
  mlx_fast_metal_kernel_config_add_output_arg: { args: [u64, P, u64, i32], returns: i32 },
  mlx_fast_metal_kernel_config_set_grid: { args: [u64, i32, i32, i32], returns: i32 },
  mlx_fast_metal_kernel_config_set_thread_group: { args: [u64, i32, i32, i32], returns: i32 },
  mlx_fast_metal_kernel_config_set_init_value: { args: [u64, f32], returns: i32 },
  mlx_fast_metal_kernel_config_add_template_arg_int: { args: [u64, cstring, i32], returns: i32 },
  mlx_fast_metal_kernel_config_add_template_arg_dtype: { args: [u64, cstring, i32], returns: i32 },
  // GPU trace capture (Phase E step 2: size the prize before the kernel)
  mlx_metal_start_capture: { args: [cstring], returns: i32 },
  mlx_metal_stop_capture: { args: [], returns: i32 },
}).symbols;

export type MlxHandle = bigint;

// --- error handling -------------------------------------------------------
// mlx-c's default error handler prints and aborts the process. Install a
// recording handler instead: ops then return non-zero status and outArray
// throws a JS Error carrying the mlx message + JS stack. mlx-c invokes the
// handler on the calling thread (exceptions are caught in the C wrappers),
// so a non-threadsafe JSCallback is safe here.
import { CString, JSCallback } from "bun:ffi";

let lastMlxError: string | null = null;

const errorHandler = new JSCallback(
  (msgPtr: number) => {
    lastMlxError = msgPtr ? new CString(msgPtr as never).toString() : "unknown mlx error";
  },
  { args: ["ptr", "ptr"], returns: "void" },
);

const errLib = dlopen(LIBMLXC_PATH, {
  mlx_set_error_handler: { args: [P, P, P], returns: FFIType.void },
}).symbols;
errLib.mlx_set_error_handler(errorHandler.ptr, null, null);

/** Consume the last recorded mlx error message (if any). */
export function takeMlxError(): string | null {
  const e = lastMlxError;
  lastMlxError = null;
  return e;
}

/** mlx_dtype enum values (array.h). */
export const enum Dtype {
  bool = 0, uint8 = 1, uint16 = 2, uint32 = 3, uint64 = 4,
  int8 = 5, int16 = 6, int32 = 7, int64 = 8,
  float16 = 9, float32 = 10, float64 = 11, bfloat16 = 12, complex64 = 13,
}

export const DTYPE_NAMES: Record<number, string> = {
  0: "bool", 1: "uint8", 2: "uint16", 3: "uint32", 4: "uint64",
  5: "int8", 6: "int16", 7: "int32", 8: "int64",
  9: "float16", 10: "float32", 11: "float64", 12: "bfloat16", 13: "complex64",
};

/** Pack mlx_optional_int for by-value passing. */
export function optInt(value: number | null): bigint {
  if (value === null) return 0n;
  return (BigInt(value >>> 0) & 0xffffffffn) | (1n << 32n);
}

/** Pack mlx_optional_dtype (same layout: enum + has_value flag). */
export const optDtype = optInt;

/** Pack mlx_optional_float `{float value; bool has_value}` for by-value passing. */
const f32Bits = new DataView(new ArrayBuffer(4));
export function optFloat(value: number | null): bigint {
  if (value === null) return 0n;
  f32Bits.setFloat32(0, value, true);
  return BigInt(f32Bits.getUint32(0, true)) | (1n << 32n);
}

/** Null handle for optional mlx_array parameters. */
export const NULL_HANDLE = 0n;

// RULE: never read a typed array that a bun:ffi call wrote through a
// pointer — once the calling function is DFG-compiled, the JIT eliminates
// the load across the native call and `buf[i]` returns stale values
// (repro/bun-ffi-f64/ISSUE.md; PLAN.md Phase 4 findings). Out-param slots
// must be read back with bun:ffi `read.*` (verified safe). Initializing the
// slot via the typed-array *constructor* is fine: that store happens in
// host code the JIT can't elide.

/** Run an op that writes its result through an mlx_array* out-param. */
export function outArray(op: string, call: (slotPtr: number) => number): MlxHandle {
  const slot = new BigUint64Array([C.mlx_array_new()]);
  const slotPtr = ptr(slot);
  const status = call(slotPtr);
  const handle = read.u64(slotPtr, 0);
  if (status !== 0) {
    C.mlx_array_free(handle);
    throw new Error(`${op} failed: ${takeMlxError() ?? "(no mlx message)"}`);
  }
  return handle;
}

export function activeMemory(): number {
  const out = new BigUint64Array(1);
  const p = ptr(out);
  C.mlx_get_active_memory(p);
  return Number(read.u64(p, 0));
}

export function peakMemory(): number {
  const out = new BigUint64Array(1);
  const p = ptr(out);
  C.mlx_get_peak_memory(p);
  return Number(read.u64(p, 0));
}

/** mx.reset_peak_memory — zero the peak counter (e.g. after model load,
 *  so a subsequent peakMemory() reads generation-only peak). */
export function resetPeakMemory(): void {
  C.mlx_reset_peak_memory();
}

/** mx.clear_cache — release the allocator's cached buffers back to the
 *  OS. mlx-lm calls this after every prefill chunk (and every 256 decode
 *  steps); without it the first decode step after a long prefill pays a
 *  one-shot allocator-reclaim stall (~800 ms after an 8k prefill —
 *  measured, scripts/decode-split.ts; the root cause of the
 *  context-scaling decode gap). */
export function clearCache(): void {
  C.mlx_clear_cache();
}

/** Metal's recommended max working-set size for the default device. */
export function maxRecommendedWorkingSetSize(): number {
  const devSlot = new BigUint64Array(1);
  const devPtr = ptr(devSlot);
  if (C.mlx_get_default_device(devPtr) !== 0)
    throw new Error(`mlx_get_default_device failed: ${takeMlxError() ?? ""}`);
  const dev = read.u64(devPtr, 0);
  const infoSlot = new BigUint64Array([C.mlx_device_info_new()]);
  const infoPtr = ptr(infoSlot);
  try {
    if (C.mlx_device_info_get(infoPtr, dev) !== 0)
      throw new Error(`mlx_device_info_get failed: ${takeMlxError() ?? ""}`);
    const info = read.u64(infoPtr, 0);
    const out = new BigUint64Array(1);
    const outPtr = ptr(out);
    const key = Buffer.from("max_recommended_working_set_size\0", "utf8");
    if (C.mlx_device_info_get_size(outPtr, info, ptr(key)) !== 0)
      throw new Error("max_recommended_working_set_size not in device info");
    return Number(read.u64(outPtr, 0));
  } finally {
    C.mlx_device_info_free(read.u64(infoPtr, 0));
    C.mlx_device_free(dev);
  }
}

/** mx.set_wired_limit — returns the previous limit. Models close to the
 *  working-set ceiling decode ~4x slower without this (Metal evicts and
 *  re-faults weight buffers every token; mlx-lm's wired_limit context
 *  is the reference behavior). MUST be scoped (set → generate →
 *  synchronize → restore), never process-permanent: a permanent limit
 *  pins buffers across idle periods and OOM-kills multi-model processes
 *  (the test suite) via uncatchable async GPU errors. */
export function setWiredLimit(bytes: number): number {
  const out = new BigUint64Array(1);
  const p = ptr(out);
  if (C.mlx_set_wired_limit(p, BigInt(Math.floor(bytes))) !== 0)
    throw new Error(`mlx_set_wired_limit failed: ${takeMlxError() ?? ""}`);
  return Number(read.u64(p, 0));
}

/** mx.set_memory_limit — returns the previous limit. At the limit the
 *  allocator reclaims/waits instead of ballooning past it. Defense in
 *  depth under admission control ONLY: it does NOT make Metal
 *  command-buffer OOM catchable (Phase 6 finding — that throw comes
 *  from a completion handler and is std::terminate). */
export function setMemoryLimit(bytes: number): number {
  const out = new BigUint64Array(1);
  const p = ptr(out);
  if (C.mlx_set_memory_limit(p, BigInt(Math.floor(bytes))) !== 0)
    throw new Error(`mlx_set_memory_limit failed: ${takeMlxError() ?? ""}`);
  return Number(read.u64(p, 0));
}

/** mx.synchronize(stream) — wired limit must not change mid-async-eval. */
export function synchronize(stream: MlxHandle): void {
  if (C.mlx_synchronize(stream) !== 0)
    throw new Error(`mlx_synchronize failed: ${takeMlxError() ?? ""}`);
}
