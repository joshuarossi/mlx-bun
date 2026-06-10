// Minimal bun:ffi f64 corruption repro: one symbol, one tight loop.
// Build: clang -O2 -shared -o librepro.dylib repro.c
// Run:   bun minimal.ts
import { dlopen, FFIType, ptr } from "bun:ffi";

const lib = dlopen(new URL("librepro.dylib", import.meta.url).pathname, {
  echo_f64: {
    args: [FFIType.ptr, FFIType.f64, FFIType.f64, FFIType.f64, FFIType.i32, FFIType.u64],
    returns: FFIType.i32,
  },
});

const out = new Float64Array(5);
const outPtr = ptr(out);
const FLOAT_ARGS = process.env.FLOAT_ARGS === "1";

let first = -1;
let failures = 0;
for (let i = 0; i < 50_000; i++) {
  // Integer-valued JS numbers (int32-tagged in JSC) by default;
  // FLOAT_ARGS=1 makes them genuine doubles.
  const stop = (i % 1000) + (FLOAT_ARGS ? 1.5 : 1);
  const rc = lib.symbols.echo_f64(outPtr, 0, stop, 1, 6, 7n);
  if (rc !== 0 || out[1] !== stop) {
    failures++;
    if (first < 0) {
      first = i;
      console.error(`iter=${i}: sent stop=${stop}, C received ${out[1]} (rc=${rc})`);
    }
  }
}
if (failures) {
  console.error(`FAIL: ${failures}/50000 corrupted calls, first at iter ${first}`);
  process.exit(1);
}
console.log("OK: no corruption");
