// bun:ffi f64 argument corruption — minimal repro.
//
// Build: clang -O2 -shared -o librepro.dylib repro.c   (any cc works)
// Run:   bun repro-min.ts            -> FAIL after ~3-20k iterations
//        FLOAT=1 bun repro-min.ts    -> ?
//        BUN_JSC_useDFGJIT=false bun repro-min.ts -> ?
//
// echo_f64(double* out, double a, double b, double c, int32_t n, uint64_t s)
// writes its args into `out`. We pass integer-valued JS numbers and compare
// what C received with what JS sent.
import { dlopen, FFIType, ptr } from "bun:ffi";

const lib = dlopen(new URL("librepro.dylib", import.meta.url).pathname, {
  echo_f64: {
    args: [FFIType.ptr, FFIType.f64, FFIType.f64, FFIType.f64, FFIType.i32, FFIType.u64],
    returns: FFIType.i32,
  },
});
const echo = lib.symbols.echo_f64;

const out = new Float64Array(5);
const outPtr = ptr(out);
const FLOAT = process.env.FLOAT === "1";
const ITERS = Number(process.env.ITERS ?? 100_000);

function main(): void {
  let failures = 0;
  let first = -1;
  const samples: string[] = [];
  for (let i = 0; i < ITERS; i++) {
    const stop = (i % 1000) + (FLOAT ? 1.5 : 1); // int32-tagged unless FLOAT=1
    const rc = echo(outPtr, 0, stop, 1, 6, 7n);
    if (rc !== 0 || out[1] !== stop) {
      failures++;
      if (first < 0) first = i;
      if (samples.length < 5) {
        samples.push(`  iter=${i}: JS sent stop=${stop}, C received ${out[1]} (rc=${rc})`);
      }
    }
  }
  if (failures) {
    console.error(`FAIL: ${failures}/${ITERS} calls received a wrong f64 (first at iter ${first})`);
    for (const s of samples) console.error(s);
    process.exit(1);
  }
  console.log(`OK: ${ITERS} calls, no corruption`);
}
main();
