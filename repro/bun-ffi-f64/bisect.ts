// Bisect which ingredients trigger the f64 corruption.
// VARIANT values:
//   fn        — loop inside a function, direct FFI call
//   helper    — loop inside a function, FFI call inside a helper function
//   symbols   — like fn, but all filler symbols also dlopen'd (never called)
//   warmup    — like symbols, plus filler warm-up calls before the loop
import { dlopen, FFIType, ptr } from "bun:ffi";

const { ptr: P, i32, i64, u64, f32, f64, cstring } = FFIType;
const VARIANT = process.env.VARIANT ?? "fn";
const ITERS = Number(process.env.ITERS ?? 200_000);

const echoOnly = {
  echo_f64: { args: [P, f64, f64, f64, i32, u64], returns: i32 },
} as const;
const allSyms = {
  ...echoOnly,
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
} as const;

const wantAll = VARIANT === "symbols" || VARIANT === "warmup";
const lib = dlopen(
  new URL("librepro.dylib", import.meta.url).pathname,
  wantAll ? allSyms : echoOnly,
);
const C = lib.symbols as any;

const out = new Float64Array(5);
const outPtr = ptr(out);
const scratch = ptr(new Uint8Array(64));
const msg = ptr(Buffer.from("causal\0", "utf8"));

let failures = 0;
let first = -1;
let firstMsg = "";

function check(i: number, stop: number): void {
  const rc = C.echo_f64(outPtr, 0, stop, 1, 6, 7n);
  if (rc !== 0 || out[1] !== stop) {
    failures++;
    if (first < 0) {
      first = i;
      firstMsg = `iter=${i}: sent stop=${stop}, C received ${out[1]} (rc=${rc})`;
    }
  }
}

function loopDirect(): void {
  for (let i = 0; i < ITERS; i++) {
    const stop = (i % 1000) + 1;
    const rc = C.echo_f64(outPtr, 0, stop, 1, 6, 7n);
    if (rc !== 0 || out[1] !== stop) {
      failures++;
      if (first < 0) {
        first = i;
        firstMsg = `iter=${i}: sent stop=${stop}, C received ${out[1]} (rc=${rc})`;
      }
    }
  }
}

function loopHelper(): void {
  for (let i = 0; i < ITERS; i++) check(i, (i % 1000) + 1);
}

function warmup(): number {
  let acc = 0;
  for (let i = 0; i < 20_000; i++) {
    acc += C.f_add_i32(i | 0, 3);
    acc += Number(C.f_add_i64(BigInt(i), 7n));
    acc += C.f_add_f64(i * 0.5, 1.25);
    acc += C.f_mul_f32(1.5, 2.0);
    acc += Number(C.f_xor_u64(BigInt(i), 5n));
    acc += C.f_unary(scratch, 1n, 7n);
    acc += C.f_binary(scratch, 1n, 2n, 7n);
    acc += C.f_axis(scratch, 1n, i & 3, 7n);
    acc += C.f_axis_bool(scratch, 1n, i & 3, true, 7n);
    acc += C.f_scalar_f32(scratch, 1n, 1e-6, 7n);
    acc += C.f_cstr(scratch, msg, 7n);
    acc += C.f_wide(scratch, 1n, 2n, 3n, 4n, true, 64n, 4n, msg, 7n);
  }
  return acc;
}

if (VARIANT === "warmup") warmup();
if (VARIANT === "helper") loopHelper();
else loopDirect();

if (failures) {
  console.error(`[${VARIANT}] FAIL: ${failures}/${ITERS} corrupted, first: ${firstMsg}`);
  process.exit(1);
}
console.log(`[${VARIANT}] OK`);
