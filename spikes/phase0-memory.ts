// Phase 0 memory spike:
//  1. Wrapper with explicit .dispose() + FinalizationRegistry backstop.
//  2. Tight alloc/dispose loop — MLX active memory and process RSS must
//     return to baseline (no leaks).
//  3. Zero-copy probe: does mlx_array_new_data_managed wrap the buffer
//     (data pointer identical) or copy it? Does the dtor fire on free?

import { dlopen, FFIType, ptr, toArrayBuffer, JSCallback } from "bun:ffi";

const { ptr: P, i32, u64 } = FFIType;

const lib = dlopen("/opt/homebrew/lib/libmlxc.dylib", {
  mlx_array_new: { args: [], returns: u64 },
  mlx_array_new_data: { args: [P, P, i32, i32], returns: u64 },
  mlx_array_new_data_managed: { args: [P, P, i32, i32, P], returns: u64 },
  mlx_array_free: { args: [u64], returns: i32 },
  mlx_array_eval: { args: [u64], returns: i32 },
  mlx_array_data_float32: { args: [u64], returns: u64 },
  mlx_default_gpu_stream_new: { args: [], returns: u64 },
  mlx_add: { args: [P, u64, u64, u64], returns: i32 },
  mlx_get_active_memory: { args: [P], returns: i32 },
  mlx_get_cache_memory: { args: [P], returns: i32 },
  mlx_clear_cache: { args: [], returns: i32 },
}).symbols;

const MLX_FLOAT32 = 10;
const stream = lib.mlx_default_gpu_stream_new();

function activeMemory(): number {
  const out = new BigUint64Array(1);
  lib.mlx_get_active_memory(ptr(out));
  return Number(out[0]);
}

// --- 1. Wrapper: dispose + FinalizationRegistry backstop ---------------

let backstopFrees = 0;
const registry = new FinalizationRegistry((handle: bigint) => {
  lib.mlx_array_free(handle);
  backstopFrees++;
});

class GpuArray {
  #handle: bigint;
  #disposed = false;
  #token = {};

  constructor(handle: bigint) {
    this.#handle = handle;
    registry.register(this, handle, this.#token);
  }

  static fromFloat32(data: Float32Array, shape: number[]): GpuArray {
    const shapeBuf = new Int32Array(shape);
    return new GpuArray(
      lib.mlx_array_new_data(ptr(data), ptr(shapeBuf), shape.length, MLX_FLOAT32),
    );
  }

  get handle(): bigint {
    if (this.#disposed) throw new Error("use after dispose");
    return this.#handle;
  }

  add(other: GpuArray): GpuArray {
    const slot = new BigUint64Array([lib.mlx_array_new()]);
    if (lib.mlx_add(ptr(slot), this.handle, other.handle, stream) !== 0)
      throw new Error("mlx_add failed");
    return new GpuArray(slot[0]);
  }

  eval(): void {
    if (lib.mlx_array_eval(this.handle) !== 0) throw new Error("eval failed");
  }

  dispose(): void {
    if (this.#disposed) return;
    this.#disposed = true;
    registry.unregister(this.#token);
    lib.mlx_array_free(this.#handle);
  }
}

// --- 2. Tight alloc/dispose loop ---------------------------------------

const N = 2000;
const ELEMS = 1 << 20; // 4 MB per array, ~12 MB live per iteration

lib.mlx_clear_cache();
Bun.gc(true);
const baselineActive = activeMemory();
const baselineRss = process.memoryUsage.rss();

const src = new Float32Array(ELEMS).fill(1.5);
for (let i = 0; i < N; i++) {
  const a = GpuArray.fromFloat32(src, [ELEMS]);
  const b = a.add(a);
  b.eval();
  a.dispose();
  b.dispose();
}

lib.mlx_clear_cache();
Bun.gc(true);
const finalActive = activeMemory();
const finalRss = process.memoryUsage.rss();

const fmt = (n: number) => `${(n / 1e6).toFixed(1)} MB`;
console.log(`active: ${fmt(baselineActive)} -> ${fmt(finalActive)}`);
console.log(`rss:    ${fmt(baselineRss)} -> ${fmt(finalRss)}`);

const activeLeak = finalActive - baselineActive;
const rssGrowth = finalRss - baselineRss;
// tolerance: one iteration's worth of buffers
const loopOk = activeLeak <= 16e6 && rssGrowth <= 64e6;
console.log(loopOk ? "PASS: alloc/dispose loop returns to baseline" : "FAIL: leak detected");

// --- 3. GC backstop: drop refs without dispose -------------------------

for (let i = 0; i < 50; i++) {
  GpuArray.fromFloat32(src, [ELEMS]); // leaked on purpose
}
Bun.gc(true);
await Bun.sleep(100); // finalizers run async
Bun.gc(true);
await Bun.sleep(100);
console.log(`backstop frees after gc: ${backstopFrees}/50 ${backstopFrees > 0 ? "(registry fires)" : "(registry did NOT fire!)"}`);

// --- 4. Zero-copy probe -------------------------------------------------

let dtorFired = false;
const dtor = new JSCallback(() => { dtorFired = true; }, { args: [P], returns: "void" });

const buf = new Float32Array([1, 2, 3, 4]);
const bufPtr = ptr(buf);
const shapeBuf = new Int32Array([4]);
const managed = lib.mlx_array_new_data_managed(bufPtr, ptr(shapeBuf), 1, MLX_FLOAT32, dtor.ptr);
const dataPtr = lib.mlx_array_data_float32(managed);
const zeroCopy = dataPtr === BigInt(bufPtr);
console.log(`managed array data ptr ${zeroCopy ? "==" : "!="} source ptr -> ${zeroCopy ? "ZERO-COPY" : "COPIES"}`);

// mutate source, re-read through mlx — second confirmation
buf[0] = 99;
const view = new Float32Array(toArrayBuffer(Number(dataPtr), 0, 16));
console.log(`mutation visible through mlx: ${view[0] === 99}`);

lib.mlx_array_free(managed);
await Bun.sleep(50);
console.log(`dtor fired on free: ${dtorFired}`);
dtor.close();

process.exit(loopOk ? 0 : 1);
