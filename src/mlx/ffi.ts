// Raw bun:ffi bindings to libmlxc.
//
// Calling convention (verified in Phase 0, see PLAN.md):
// - Every mlx-c handle is a one-pointer struct `{ void* ctx }` — passed and
//   returned by value in a single register on arm64, so FFIType.u64 works.
// - Out-params (`mlx_array* res`) are a pointer to that slot: allocate a
//   BigUint64Array(1), pass ptr(), reread after the call.
// - Ops return int status; 0 = success.
// - mlx_optional_int is `{ int32 value; bool has_value }` = 8 bytes, by
//   value in one register: value in bits 0..31, has_value at bit 32.

import { dlopen, FFIType, ptr } from "bun:ffi";

const { ptr: P, i32, u64, f32, cstring } = FFIType;

export const LIBMLXC_PATH = "/opt/homebrew/lib/libmlxc.dylib";

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
  mlx_arange: { args: [P, FFIType.f64, FFIType.f64, FFIType.f64, i32, u64], returns: i32 },
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
}).symbols;

export type MlxHandle = bigint;

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

const statusErr = (op: string) => new Error(`${op} failed (mlx error)`);

/** Run an op that writes its result through an mlx_array* out-param. */
export function outArray(op: string, call: (slotPtr: number) => number): MlxHandle {
  const slot = new BigUint64Array([C.mlx_array_new()]);
  const status = call(ptr(slot));
  if (status !== 0) {
    C.mlx_array_free(slot[0]!);
    throw statusErr(op);
  }
  return slot[0]!;
}

export function activeMemory(): number {
  const out = new BigUint64Array(1);
  C.mlx_get_active_memory(ptr(out));
  return Number(out[0]);
}

export function peakMemory(): number {
  const out = new BigUint64Array(1);
  C.mlx_get_peak_memory(ptr(out));
  return Number(out[0]);
}
