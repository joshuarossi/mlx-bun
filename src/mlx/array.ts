// MlxArray: ownership wrapper around an mlx_array handle.
// Explicit .dispose() is the contract; a FinalizationRegistry backstop
// frees leaked handles on GC (verified in lab/spikes/phase0-memory.ts).

import { dlopen, ptr, toArrayBuffer } from "bun:ffi";
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
// array. fromView pins the JS view in this map (a GC root, nothing more);
// release is EXPLICIT and JS-thread-only via unpinHostBuffer() — never an
// mlx dtor. See the hazard note below.

const pinned = new Map<number, Uint8Array>();
let nextPinId = 1;

// HAZARD (root cause of the 2026-07-06 restart-restore hang): mlx releases
// buffer Data wherever the LAST shared_ptr drops — often the Metal
// COMPLETION thread (gpu::eval retains buffers until the command buffer
// finishes, i.e. past dispose()). A bun:ffi JSCallback dtor invoked from
// that thread deadlocks when the JS thread is inside a blocking FFI eval
// (completion waits on JS, JS waits on completion) and SIGTRAPs mid-GC.
// So NO array here ever gets a JS dtor: fromPointer AND fromView both hand
// mlx the native no-op dtor below (payload 0), and host-buffer lifetime is
// the CALLER's contract, released only from the JS thread (unpinHostBuffer)
// or never (process-lifetime mmaps: expert-offload, kv-store).

// Native no-op dtor: payload is always 0, and libc free(NULL) is defined to
// do nothing — a dtor mlx can safely call from ANY thread. The pointed-to
// memory's lifetime is the CALLER's contract (weight mmaps live for the
// process; restored KV mmaps are kept mapped for the process too — see
// kv-store.ts retainMmapForProcess). The address comes via dlsym because
// bun:ffi's symbol .ptr returns the pointer bit-cast to float64
// (lab/repro/bun-ffi-f64) — passing that back truncates to NULL.
const libcDlsym = dlopen("/usr/lib/libSystem.B.dylib", {
  dlsym: { args: ["u64", "ptr"], returns: "u64" },
});
const FREE_NAME = Buffer.from("free\0");
const RTLD_DEFAULT = 0xfffffffffffffffen;
const freeFnAddr = Number(libcDlsym.symbols.dlsym(RTLD_DEFAULT, ptr(FREE_NAME)));
if (!freeFnAddr) throw new Error("dlsym(free) failed — zero-copy arrays need a native no-op dtor");

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
  #pinId = 0; // fromView only: key into the pinned-view map (0 = no pin)

  constructor(handle: MlxHandle) {
    this.#handle = handle;
    registry.register(this, handle, this.#token);
  }

  /** Zero-copy: wrap an existing JS buffer. The view is pinned (GC-rooted)
   *  in a process-side map; mlx gets the NATIVE no-op dtor (free(NULL)) —
   *  never a JS callback, so the last release may happen on the Metal
   *  completion thread without deadlock (see hazard note above). Buffer
   *  lifetime is therefore the CALLER's contract:
   *   - mmap-backed views (toArrayBuffer aliases): the mapping owns the
   *     memory; prefer fromPointer, which skips the pin entirely.
   *   - JS-heap buffers: the pin keeps the buffer alive; call
   *     unpinHostBuffer() only after a JS-side sync point proves mlx is
   *     done with it (everything depending on the array evaluated AND the
   *     array disposed), or never (process-lifetime, e.g. short scripts). */
  static fromView(view: Uint8Array, shape: number[], dtype: Dtype): MlxArray {
    const sb = shapeBuf(shape);
    const id = nextPinId++;
    pinned.set(id, view);
    const handle = C.mlx_array_new_data_managed_payload(
      ptr(view), ptr(sb), shape.length, dtype, 0, freeFnAddr,
    );
    const arr = new MlxArray(handle);
    arr.#pinId = id;
    return arr;
  }

  /** Release the GC root fromView placed on this array's host buffer.
   *  JS-thread-only by construction (it's a plain method) — this is the
   *  replacement for the deadlocking JSCallback unpin dtor. Idempotent;
   *  no-op for non-fromView arrays. Caller contract: only call once mlx can
   *  no longer touch the buffer (see fromView doc), or when the memory is
   *  owned elsewhere (an mmap kept mapped past every use). */
  unpinHostBuffer(): void {
    if (this.#pinId !== 0) {
      pinned.delete(this.#pinId);
      this.#pinId = 0;
    }
  }

  /** Zero-copy: wrap a raw pointer (e.g. into an mmap'd weight shard or a
   *  restored KV file). The caller guarantees the memory outlives EVERY mlx
   *  reference to the array — including GPU command buffers that retain the
   *  buffer past dispose() — i.e. mmaps backing these arrays stay mapped for
   *  the process. The dtor is free(NULL) (payload 0): native + no-op, so
   *  mlx may run it from the Metal completion thread without touching the
   *  JS runtime (the old JSCallback dtor deadlocked serving / SIGTRAPed
   *  under GC when that thread held the last reference — 2026-07-06). */
  static fromPointer(dataPtr: number, shape: number[], dtype: Dtype): MlxArray {
    const sb = shapeBuf(shape);
    const handle = C.mlx_array_new_data_managed_payload(
      dataPtr, ptr(sb), shape.length, dtype, 0, freeFnAddr,
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

  /** Copy raw bytes into a fresh mlx-managed (page-aligned) LEAF array of the
   *  given dtype/shape. Unlike fromView (which no-copy-wraps the host buffer and
   *  is unsafe to feed to GPU ops when unaligned), mlx_array_new_data COPIES, so
   *  the source bytes need not outlive the array and GPU ops are safe. Used to
   *  detach a value from its computation graph: `MlxArray.fromBytesCopy(
   *  x.rawBytes(), x.shape, x.dtype)` yields a graph-free leaf with x's exact
   *  bytes (segmented-backward boundaries — src/train/segmented.ts). */
  static fromBytesCopy(bytes: Uint8Array, shape: number[], dtype: Dtype): MlxArray {
    const sb = shapeBuf(shape);
    return new MlxArray(
      C.mlx_array_new_data(ptr(bytes), ptr(sb), shape.length, dtype),
    );
  }

  static fromInt32(data: Int32Array, shape: number[]): MlxArray {
    const sb = shapeBuf(shape);
    return new MlxArray(
      C.mlx_array_new_data(ptr(data), ptr(sb), shape.length, Dtype.int32),
    );
  }

  /** Graph-free LEAF with this array's exact bytes — ONE copy, straight from
   *  the (evaluated) mlx buffer into a fresh mlx-owned array, no JS-heap
   *  intermediate (`fromBytesCopy(rawBytes())` is TWO copies: device→JS heap
   *  →new leaf). mlx_array_new_data copies synchronously, so the source only
   *  has to outlive this call. The buffer is read LINEARLY — the caller must
   *  pass a row-major contiguous array (ops.contiguous first for views), same
   *  contract as rawBytes. Segmented-backward boundary detach hot path. */
  detachCopy(): MlxArray {
    this.eval();
    const dt = this.dtype;
    const p =
      dt === Dtype.float32 ? C.mlx_array_data_float32(this.handle)
      : dt === Dtype.float16 ? C.mlx_array_data_float16(this.handle)
      : dt === Dtype.bfloat16 ? C.mlx_array_data_bfloat16(this.handle)
      : dt === Dtype.uint32 ? C.mlx_array_data_uint32(this.handle)
      : null;
    if (p === null) throw new Error(`detachCopy: unsupported dtype ${this.dtypeName}`);
    const sb = shapeBuf(this.shape);
    return new MlxArray(C.mlx_array_new_data(p as never, ptr(sb), this.ndim, dt));
  }

  get handle(): MlxHandle {
    if (this.#disposed) throw new Error("MlxArray used after dispose");
    return this.#handle;
  }

  get ndim(): number {
    return Number(C.mlx_array_ndim(this.handle));
  }

  // NOTE on the DFG stale-read bug (lab/repro/bun-ffi-f64/ISSUE.md): the
  // toArrayBuffer readbacks below (shape/rawBytes/toFloat32) are safe.
  // The hazard is reading a *pre-existing* typed array after an FFI call
  // wrote through its pointer — the JIT forwards a stale value from before
  // the call. Here the view is constructed *after* the call, from the
  // pointer the call returned: the loads are data-dependent on the call
  // result and there is no prior JS load/store to forward from.

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
      : dt === Dtype.uint32 ? C.mlx_array_data_uint32(this.handle)
      : null;
    if (p === null) throw new Error(`rawBytes: unsupported dtype ${this.dtypeName}`);
    return new Uint8Array(toArrayBuffer(p!, 0, this.nbytes)).slice();
  }

  /** Read back an INTEGER array without enqueueing a cast kernel: eval +
   *  direct buffer read for uint32/int32. A cast (`astype`) is a NEW op that
   *  queues BEHIND everything already dispatched on the GPU stream — on the
   *  batched decode hot path, reading the pipeline register via toFloat32
   *  stalled the "overlapped" token read for a FULL step of GPU work every
   *  token (the core of the Phase-0 B=1 gap; unified-engine plan Phase 2).
   *  Non-integer dtypes fall back to the rounded float readback. */
  toIntTokens(): number[] {
    if (this.dtype === Dtype.uint32) {
      this.eval();
      const p = C.mlx_array_data_uint32(this.handle);
      return [...new Uint32Array(toArrayBuffer(p!, 0, this.size * 4))];
    }
    if (this.dtype === Dtype.int32) {
      this.eval();
      const p = C.mlx_array_data_int32(this.handle);
      return [...new Int32Array(toArrayBuffer(p!, 0, this.size * 4))];
    }
    return [...this.toFloat32()].map((x) => Math.round(x));
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
