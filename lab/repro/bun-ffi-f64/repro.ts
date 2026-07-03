// bun:ffi f64 argument corruption repro.
// Build the dylib first:  clang -O2 -shared -o librepro.dylib repro.c
// Run:                    bun repro.ts
//
// Target: echo_f64(ptr, f64, f64, f64, i32, u64) — mirrors mlx-c's
// mlx_arange. We call it from hot JS functions whose number arguments are
// int32-tagged (computed via integer arithmetic), after a warm-up phase of
// many varied FFI calls, and check the doubles that arrive on the C side.

import { dlopen, FFIType, ptr } from "bun:ffi";

const { ptr: P, i32, i64, u64, f32, f64, cstring } = FFIType;

const lib = dlopen(new URL("librepro.dylib", import.meta.url).pathname, {
  echo_f64: { args: [P, f64, f64, f64, i32, u64], returns: i32 },
  f_add_i32: { args: [i32, i32], returns: i32 },
  f_add_i64: { args: [i64, i64], returns: i64 },
  f_add_f64: { args: [f64, f64], returns: f64 },
  f_mul_f32: { args: [f32, f32], returns: f32 },
  f_xor_u64: { args: [u64, u64], returns: u64 },
  f_unary: { args: [P, u64, u64], returns: i32 },
  f_binary: { args: [P, u64, u64, u64], returns: i32 },
  f_axis: { args: [P, u64, i32, u64], returns: i32 },
  f_axis_bool: { args: [P, u64, i32, FFIType.bool, u64], returns: i32 },
  f_scalar_f32: { args: [P, u64, f32, u64], returns: i32 },
  f_cstr: { args: [P, cstring, u64], returns: i32 },
  f_wide: { args: [P, u64, u64, u64, u64, FFIType.bool, u64, u64, cstring, u64], returns: i32 },
  f_ptr_id: { args: [P], returns: P },
});
const C = lib.symbols;

const out = new Float64Array(5);
const outPtr = ptr(out);
const scratch = new Uint8Array(64);
const scratchPtr = ptr(scratch);
const msg = Buffer.from("causal\0", "utf8");
const msgPtr = ptr(msg);
const STREAM = 0x1122334455667788n;

let failures = 0;
let firstFailureAt = -1;

function check(tag: string, i: number, a: number, b: number, c: number, n: number): void {
  const rc = C.echo_f64(outPtr, a, b, c, n, STREAM);
  if (rc !== 0 || out[0] !== a || out[1] !== b || out[2] !== c || out[3] !== n) {
    failures++;
    if (firstFailureAt < 0) firstFailureAt = i;
    if (failures <= 10) {
      console.error(
        `[${tag}] iter=${i} CORRUPTED rc=${rc} sent=(${a}, ${b}, ${c}, n=${n}) ` +
          `received=(${out[0]}, ${out[1]}, ${out[2]}, n=${out[3]})`,
      );
    }
  }
}

// Phase 1: warm-up — varied FFI traffic, like a model forward pass does.
function fillerStorm(i: number): number {
  let acc = 0;
  acc += C.f_add_i32(i | 0, (i * 3) | 0);
  acc += Number(C.f_add_i64(BigInt(i), 7n));
  acc += C.f_add_f64(i * 0.5, 1.25);
  acc += C.f_mul_f32(1.5, 2.0);
  acc += Number(C.f_xor_u64(BigInt(i), STREAM));
  acc += C.f_unary(scratchPtr, 1n, STREAM);
  acc += C.f_binary(scratchPtr, 1n, 2n, STREAM);
  acc += C.f_axis(scratchPtr, 1n, i & 3, STREAM);
  acc += C.f_axis_bool(scratchPtr, 1n, i & 3, true, STREAM);
  acc += C.f_scalar_f32(scratchPtr, 1n, 1e-6, STREAM);
  acc += C.f_cstr(scratchPtr, msgPtr, STREAM);
  acc += C.f_wide(scratchPtr, 1n, 2n, 3n, 4n, true, 64n, 4n, msgPtr, STREAM);
  return acc;
}

// Phase 2 callers. Each variant is a distinct function so it gets its own
// JIT profile. Arguments are integer-valued JS numbers (int32-tagged).

// V1: direct tight loop.
function v1(iters: number): void {
  for (let i = 0; i < iters; i++) {
    const start = 0;
    const stop = (i % 1000) + 1;
    const step = 1;
    check("v1-direct", i, start, stop, step, 6);
  }
}

// V2: interleaved with varied FFI calls (closest to the original workload).
function v2(iters: number): void {
  let sink = 0;
  for (let i = 0; i < iters; i++) {
    sink += fillerStorm(i);
    const stop = ((i * 7) & 0xffff) + 1;
    check("v2-interleaved", i, 0, stop, 1, 6);
  }
  if (sink === Number.MIN_SAFE_INTEGER) console.log(sink);
}

// V3: call goes through a closure layer, like outArray(name, cb) in the
// original codebase.
function viaClosure(i: number, a: number, b: number, c: number, n: number): void {
  const cb = () => check("v3-closure", i, a, b, c, n);
  cb();
}
function v3(iters: number): void {
  for (let i = 0; i < iters; i++) {
    viaClosure(i, 0, (i & 0x3ffff) + 1, 1, 6);
    if ((i & 7) === 0) fillerStorm(i);
  }
}

// V4: arguments flow from values the JIT has proven are int32 (array
// lengths, bitwise ops), passed through one wrapper frame.
const vocab = 262144;
function callEcho(start: number, stop: number, step: number, dtype: number): void {
  check("v4-wrapper", lastI, start, stop, step, dtype);
}
let lastI = 0;
function v4(iters: number): void {
  for (let i = 0; i < iters; i++) {
    lastI = i;
    callEcho(0, vocab, 1, 6);
    if ((i & 15) === 0) fillerStorm(i);
  }
}

console.log(`bun ${Bun.version} ${process.platform}-${process.arch}`);

const N = Number(process.env.ITERS ?? 200_000);

console.log("warm-up: filler storm x20000");
let sink = 0;
for (let i = 0; i < 20_000; i++) sink += fillerStorm(i);

console.log(`v1: direct loop x${N}`);
v1(N);
console.log(`v2: interleaved x${N}`);
v2(N);
console.log(`v3: closure x${N}`);
v3(N);
console.log(`v4: wrapper, constant int args x${N}`);
v4(N);

if (failures > 0) {
  console.error(`FAIL: ${failures} corrupted calls (first at iter ${firstFailureAt})`);
  process.exit(1);
}
console.log("OK: no corruption observed");
