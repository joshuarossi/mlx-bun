// Which argument kinds freeze after DFG tier-up? Vary every arg per
// iteration and record which ones arrive stale. Also test a pure
// f64 -> f64 function's return value.
import { dlopen, FFIType, ptr } from "bun:ffi";

const { ptr: P, i32, u64, f64 } = FFIType;
const lib = dlopen(new URL("librepro.dylib", import.meta.url).pathname, {
  echo_f64: { args: [P, f64, f64, f64, i32, u64], returns: i32 },
  f_add_f64: { args: [f64, f64], returns: f64 },
});
const echo = lib.symbols.echo_f64;
const addf = lib.symbols.f_add_f64;

const out = new Float64Array(5);
const outPtr = ptr(out);

function argsTest(): void {
  const stale = { a: 0, b: 0, c: 0, n: 0, s: 0 };
  let first = -1;
  for (let i = 0; i < 100_000; i++) {
    const a = (i % 7) + 1;
    const b = (i % 1000) + 1;
    const c = (i % 13) + 1;
    const n = (i % 31) + 1;
    const s = BigInt((i % 17) + 1);
    echo(outPtr, a, b, c, n, s);
    let bad = false;
    if (out[0] !== a) { stale.a++; bad = true; }
    if (out[1] !== b) { stale.b++; bad = true; }
    if (out[2] !== c) { stale.c++; bad = true; }
    if (out[3] !== n) { stale.n++; bad = true; }
    if (out[4] !== Number(s)) { stale.s++; bad = true; }
    if (bad && first < 0) {
      first = i;
      console.error(
        `args: first corruption iter=${i} sent=(${a}, ${b}, ${c}, n=${n}, s=${s}) ` +
          `received=(${out[0]}, ${out[1]}, ${out[2]}, n=${out[3]}, s=${out[4]})`,
      );
    }
  }
  console.error(`args: stale counts over 100k iters: ${JSON.stringify(stale)}`);
}

function returnTest(): void {
  let failures = 0;
  let first = -1;
  let firstMsg = "";
  for (let i = 0; i < 100_000; i++) {
    const x = (i % 1000) + 0.25;
    const r = addf(x, 1.0);
    if (r !== x + 1.0) {
      failures++;
      if (first < 0) {
        first = i;
        firstMsg = `sent x=${x}, got ${r}, expected ${x + 1.0}`;
      }
    }
  }
  console.error(
    failures
      ? `return: FAIL ${failures}/100000, first at iter ${first}: ${firstMsg}`
      : `return: OK (f64->f64 round-trip clean)`,
  );
}

argsTest();
returnTest();
