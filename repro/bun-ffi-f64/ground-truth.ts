// Ground truth: on the first JS-visible mismatch, ask the C side what it
// actually received (stashed in dylib globals, dumped via a cold call).
import { dlopen, FFIType, ptr } from "bun:ffi";

const { ptr: P, i32, u64, f64 } = FFIType;
const lib = dlopen(new URL("librepro.dylib", import.meta.url).pathname, {
  probe6: { args: [P, f64, f64, f64, i32, u64], returns: i32 },
  dump_last: { args: [], returns: FFIType.void },
  dump_mem: { args: [], returns: FFIType.void },
});
const probe = lib.symbols.probe6;

const out = new Float64Array(1);
const outPtr = ptr(out);
const N = 100_000;

function main(): void {
  let staleRet = 0, staleMem = 0, reported = 0;
  for (let i = 0; i < N; i++) {
    const a = (i % 1000) + 0.5;
    const b = (i % 777) + 1;
    const c = (i % 13) + 2;
    const n = (i % 31) + 3;
    const s = BigInt((i % 17) + 4);
    const rc = probe(outPtr, a, b, c, n, s);
    const retBad = rc !== b;
    const memBad = out[0] !== a;
    if (retBad) staleRet++;
    if (memBad) staleMem++;
    if ((retBad || memBad) && reported < 3) {
      reported++;
      console.error(
        `iter=${i} retBad=${retBad} memBad=${memBad}\n` +
          `  JS sent:             ptr=0x${outPtr.toString(16)} a=${a} b=${b} c=${c} n=${n} s=${s}\n` +
          `  JS rc=${rc} (expected ${b}), out[0]=${out[0]} (expected ${a})`,
      );
      lib.symbols.dump_last();
      lib.symbols.dump_mem();
    }
  }
  console.log(`return-based stale: ${staleRet}/${N}, memory-based stale: ${staleMem}/${N}`);
}
main();
