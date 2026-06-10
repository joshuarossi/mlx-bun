// Phase 0 smoke test: bun:ffi → libmlxc → GPU add → read back.
//
// mlx-c handle types (mlx_array, mlx_stream, ...) are structs containing a
// single `void* ctx`. On arm64 AAPCS these are passed/returned in one
// register, so FFIType.ptr works for by-value handles. Out-params
// (`mlx_array* res`) are a pointer to that one-pointer struct: we keep a
// BigUint64Array slot and pass its address.

import { dlopen, FFIType, ptr, toArrayBuffer } from "bun:ffi";

const { ptr: P, i32, u64 } = FFIType;

const lib = dlopen("/opt/homebrew/lib/libmlxc.dylib", {
  mlx_array_new: { args: [], returns: u64 },
  mlx_array_new_data: { args: [P, P, i32, i32], returns: u64 },
  mlx_array_free: { args: [u64], returns: i32 },
  mlx_array_eval: { args: [u64], returns: i32 },
  mlx_array_size: { args: [u64], returns: u64 },
  mlx_array_data_float32: { args: [u64], returns: P },
  mlx_default_gpu_stream_new: { args: [], returns: u64 },
  mlx_stream_free: { args: [u64], returns: i32 },
  mlx_add: { args: [P, u64, u64, u64], returns: i32 },
}).symbols;

const MLX_FLOAT32 = 10;

function arrayFromFloat32(data: Float32Array, shape: number[]): bigint {
  const shapeBuf = new Int32Array(shape);
  return lib.mlx_array_new_data(ptr(data), ptr(shapeBuf), shape.length, MLX_FLOAT32);
}

const a = arrayFromFloat32(new Float32Array([1, 2, 3, 4]), [4]);
const b = arrayFromFloat32(new Float32Array([10, 20, 30, 40]), [4]);
const stream = lib.mlx_default_gpu_stream_new();

// out-param slot for `mlx_array* res`
const resSlot = new BigUint64Array([lib.mlx_array_new()]);
const status = lib.mlx_add(ptr(resSlot), a, b, stream);
if (status !== 0) throw new Error(`mlx_add failed with status ${status}`);
const res = resSlot[0];

if (lib.mlx_array_eval(res) !== 0) throw new Error("mlx_array_eval failed");

const n = Number(lib.mlx_array_size(res));
const dataPtr = lib.mlx_array_data_float32(res);
const out = new Float32Array(toArrayBuffer(dataPtr, 0, n * 4));

console.log("a + b =", Array.from(out));
const expected = [11, 22, 33, 44];
const ok = out.length === 4 && expected.every((v, i) => out[i] === v);

for (const h of [a, b, res]) lib.mlx_array_free(h);
lib.mlx_stream_free(stream);

if (!ok) {
  console.error("FAIL: expected", expected);
  process.exit(1);
}
console.log("PASS: GPU add via bun:ffi works");
