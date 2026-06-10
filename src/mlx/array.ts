// MlxArray: ownership wrapper around an mlx_array handle.
// Explicit .dispose() is the contract; a FinalizationRegistry backstop
// frees leaked handles on GC (verified in spikes/phase0-memory.ts).

import { JSCallback, ptr, toArrayBuffer } from "bun:ffi";
import { C, Dtype, DTYPE_NAMES, type MlxHandle, optInt, outArray, takeMlxError } from "./ffi";
import type { SafetensorsDtype } from "../safetensors";

export const gpuStream: MlxHandle = C.mlx_default_gpu_stream_new();
export const cpuStream: MlxHandle = C.mlx_default_cpu_stream_new();

/** Shape buffer for FFI; ptr() rejects empty views, so 0-d arrays pass a
 *  dummy buffer with dim=0 (the pointee is never read). */
function shapeBuf(shape: number[]): Int32Array {
  return shape.length === 0 ? new Int32Array(1) : new Int32Array(shape);
}

export const SAFETENSORS_TO_MLX: Record<SafetensorsDtype, Dtype> = {
  BOOL: Dtype.bool, U8: Dtype.uint8, I8: Dtype.int8,
  U16: Dtype.uint16, I16: Dtype.int16, U32: Dtype.uint32, I32: Dtype.int32,
  U64: Dtype.uint64, I64: Dtype.int64,
  F16: Dtype.float16, BF16: Dtype.bfloat16, F32: Dtype.float32, F64: Dtype.float64,
};

// --- zero-copy pinning ---------------------------------------------------
// Buffers handed to mlx via new_data_managed_payload must outlive the mlx
// array. We pin the JS view in a map keyed by a payload id; the shared dtor
// callback unpins when mlx drops its last reference. threadsafe: mlx may
// release buffers from its eval thread.

const pinned = new Map<number, Uint8Array>();
let nextPinId = 1;

const unpinCallback = new JSCallback(
  (payloadId: number) => { pinned.delete(payloadId); },
  { args: ["u64"], returns: "void", threadsafe: true },
);

export function pinnedBufferCount(): number {
  return pinned.size;
}

// --- finalization backstop ----------------------------------------------

const registry = new FinalizationRegistry((handle: MlxHandle) => {
  C.mlx_array_free(handle);
});

export class MlxArray {
  #handle: MlxHandle;
  #disposed = false;
  #token = {};

  constructor(handle: MlxHandle) {
    this.#handle = handle;
    registry.register(this, handle, this.#token);
  }

  /** Zero-copy: wrap an existing buffer (e.g. an mmap view). The view is
   *  pinned until mlx releases it. */
  static fromView(view: Uint8Array, shape: number[], dtype: Dtype): MlxArray {
    const sb = shapeBuf(shape);
    const id = nextPinId++;
    pinned.set(id, view);
    const handle = C.mlx_array_new_data_managed_payload(
      ptr(view), ptr(sb), shape.length, dtype, id, unpinCallback.ptr,
    );
    return new MlxArray(handle);
  }

  /** Zero-copy: wrap a raw pointer (e.g. into an mmap'd weight shard).
   *  The caller guarantees the memory outlives the array — weight mmaps
   *  live for the process, so the dtor is a no-op unpin of id 0. */
  static fromPointer(dataPtr: number, shape: number[], dtype: Dtype): MlxArray {
    const sb = shapeBuf(shape);
    const handle = C.mlx_array_new_data_managed_payload(
      dataPtr, ptr(sb), shape.length, dtype, 0, unpinCallback.ptr,
    );
    return new MlxArray(handle);
  }

  /** Copying constructor for small host data. */
  static fromFloat32(data: Float32Array, shape: number[]): MlxArray {
    const sb = shapeBuf(shape);
    return new MlxArray(
      C.mlx_array_new_data(ptr(data), ptr(sb), shape.length, Dtype.float32),
    );
  }

  static fromInt32(data: Int32Array, shape: number[]): MlxArray {
    const sb = shapeBuf(shape);
    return new MlxArray(
      C.mlx_array_new_data(ptr(data), ptr(sb), shape.length, Dtype.int32),
    );
  }

  get handle(): MlxHandle {
    if (this.#disposed) throw new Error("MlxArray used after dispose");
    return this.#handle;
  }

  get ndim(): number {
    return Number(C.mlx_array_ndim(this.handle));
  }

  get shape(): number[] {
    const n = this.ndim;
    if (n === 0) return [];
    const shapePtr = C.mlx_array_shape(this.handle);
    return [...new Int32Array(toArrayBuffer(shapePtr!, 0, n * 4))];
  }

  get dtype(): Dtype {
    return C.mlx_array_dtype(this.handle) as Dtype;
  }

  get dtypeName(): string {
    return DTYPE_NAMES[this.dtype] ?? `unknown(${this.dtype})`;
  }

  get size(): number {
    return Number(C.mlx_array_size(this.handle));
  }

  get nbytes(): number {
    return Number(C.mlx_array_nbytes(this.handle));
  }

  eval(): this {
    if (C.mlx_array_eval(this.handle) !== 0) throw new Error(`mlx_array_eval failed: ${takeMlxError() ?? ""}`);
    return this;
  }

  /** Cast to another dtype (lazy). */
  astype(dtype: Dtype, stream: MlxHandle = gpuStream): MlxArray {
    return new MlxArray(
      outArray("astype", (slot) => C.mlx_astype(slot, this.handle, dtype, stream)),
    );
  }

  /** Raw bytes of the evaluated array (copy). bf16/f16/f32 only. */
  rawBytes(): Uint8Array {
    this.eval();
    const dt = this.dtype;
    const p =
      dt === Dtype.float32 ? C.mlx_array_data_float32(this.handle)
      : dt === Dtype.float16 ? C.mlx_array_data_float16(this.handle)
      : dt === Dtype.bfloat16 ? C.mlx_array_data_bfloat16(this.handle)
      : null;
    if (p === null) throw new Error(`rawBytes: unsupported dtype ${this.dtypeName}`);
    return new Uint8Array(toArrayBuffer(p!, 0, this.nbytes)).slice();
  }

  /** Read back as float32 (casts on GPU if needed, then copies out). */
  toFloat32(): Float32Array {
    const src = this.dtype === Dtype.float32 ? this : this.astype(Dtype.float32);
    src.eval();
    const dataPtr = C.mlx_array_data_float32(src.handle);
    const out = new Float32Array(toArrayBuffer(dataPtr!, 0, src.size * 4)).slice();
    if (src !== this) src.dispose();
    return out;
  }

  /** Basic slice: start/stop per dimension (stride 1). */
  slice(start: number[], stop: number[], stream: MlxHandle = gpuStream): MlxArray {
    const s = new Int32Array(start);
    const e = new Int32Array(stop);
    const strides = new Int32Array(start.map(() => 1));
    return new MlxArray(
      outArray("slice", (slot) =>
        C.mlx_slice(
          slot, this.handle,
          ptr(s), BigInt(s.length), ptr(e), BigInt(e.length),
          ptr(strides), BigInt(strides.length), stream,
        ),
      ),
    );
  }

  add(other: MlxArray, stream: MlxHandle = gpuStream): MlxArray {
    return new MlxArray(
      outArray("add", (slot) => C.mlx_add(slot, this.handle, other.handle, stream)),
    );
  }

  /** Dequantize (w, scales, biases) → full precision. */
  static dequantize(
    w: MlxArray, scales: MlxArray, biases: MlxArray | null,
    groupSize: number, bits: number, mode = "affine",
    stream: MlxHandle = gpuStream,
  ): MlxArray {
    const modeBuf = Buffer.from(mode + "\0", "utf8");
    return new MlxArray(
      outArray("dequantize", (slot) =>
        C.mlx_dequantize(
          slot, w.handle, scales.handle, biases?.handle ?? 0n,
          optInt(groupSize), optInt(bits), ptr(modeBuf),
          0n /* global_scale */, optInt(null) /* out dtype */, stream,
        ),
      ),
    );
  }

  dispose(): void {
    if (this.#disposed) return;
    this.#disposed = true;
    registry.unregister(this.#token);
    C.mlx_array_free(this.#handle);
  }

  [Symbol.dispose](): void {
    this.dispose();
  }
}
