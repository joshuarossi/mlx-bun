// bun repro.ts
import { dlopen, FFIType, ptr } from "bun:ffi";

const { ptr: P, i32, u64, f64 } = FFIType;
const lib = dlopen(new URL("librepro.dylib", import.meta.url).pathname, {
  write_and_check: { args: [P, f64, f64, f64, i32, u64], returns: i32 },
  read_mem: { args: [P], returns: f64 },
});
const { write_and_check, read_mem } = lib.symbols;

const out = new Float64Array(1);
const outPtr = ptr(out);

function main(): void {
  let stale = 0;
  let first = -1;
  let shown = 0;
  for (let i = 0; i < 100_000; i++) {
    const a = (i % 1000) + 0.5;
    const rc = write_and_check(outPtr, a, 7, 9, 3, 5n);
    if (rc !== 7) throw new Error("C received wrong args"); // never fires
    if (out[0] !== a) {
      stale++;
      if (first < 0) first = i;
      if (shown++ < 3) {
        console.error(
          `iter=${i}: C wrote ${a}; memory actually contains ${read_mem(outPtr)}; JS reads out[0] = ${out[0]}`,
        );
      }
    }
  }
  if (stale) {
    console.error(`FAIL: ${stale}/100000 stale typed-array reads (first at iter ${first})`);
    process.exit(1);
  }
  console.log("OK: no stale reads");
}
main();
