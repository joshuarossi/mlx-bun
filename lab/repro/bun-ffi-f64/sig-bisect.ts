// Which signature shapes go stale after DFG tier-up? Each shape gets its
// own dedicated loop function (own JIT profile), FFI call written inline,
// varying every argument per iteration.
import { dlopen, FFIType, ptr } from "bun:ffi";

const { ptr: P, i32, u64, f64 } = FFIType;
const lib = dlopen(new URL("librepro.dylib", import.meta.url).pathname, {
  echo_p_f64: { args: [P, f64], returns: i32 },
  echo_p_i32: { args: [P, i32], returns: i32 },
  echo_p_u64: { args: [P, u64], returns: i32 },
  echo_p_2f64: { args: [P, f64, f64], returns: i32 },
  echo_p_f64_u64: { args: [P, f64, u64], returns: i32 },
  echo_p_5i: { args: [P, i32, i32, i32, i32, i32], returns: i32 },
  echo_p_5f: { args: [P, f64, f64, f64, f64, f64], returns: i32 },
  echo_r_f64: { args: [f64], returns: f64 },
  f_add_i32: { args: [i32, i32], returns: i32 },
});
const C = lib.symbols;

const out = new Float64Array(5);
const outPtr = ptr(out);
const N = 80_000;
const results: string[] = [];

function report(name: string, stale: number, first: number): void {
  results.push(
    stale
      ? `${name.padEnd(34)} STALE ${stale}/${N} (first at iter ${first})`
      : `${name.padEnd(34)} OK`,
  );
}

function tPf64(): void {
  let stale = 0, first = -1;
  for (let i = 0; i < N; i++) {
    const v = (i % 1000) + 1;
    C.echo_p_f64(outPtr, v);
    if (out[0] !== v) { stale++; if (first < 0) first = i; }
  }
  report("(ptr, f64) -> i32", stale, first);
}

function tPi32(): void {
  let stale = 0, first = -1;
  for (let i = 0; i < N; i++) {
    const v = (i % 1000) + 1;
    C.echo_p_i32(outPtr, v);
    if (out[0] !== v) { stale++; if (first < 0) first = i; }
  }
  report("(ptr, i32) -> i32", stale, first);
}

function tPu64Big(): void {
  let stale = 0, first = -1;
  for (let i = 0; i < N; i++) {
    const v = (i % 1000) + 1;
    C.echo_p_u64(outPtr, BigInt(v));
    if (out[0] !== v) { stale++; if (first < 0) first = i; }
  }
  report("(ptr, u64) -> i32 [bigint]", stale, first);
}

function tPu64Num(): void {
  let stale = 0, first = -1;
  for (let i = 0; i < N; i++) {
    const v = (i % 1000) + 1;
    C.echo_p_u64(outPtr, v);
    if (out[0] !== v) { stale++; if (first < 0) first = i; }
  }
  report("(ptr, u64) -> i32 [number]", stale, first);
}

function tP2f64(): void {
  let stale = 0, first = -1;
  for (let i = 0; i < N; i++) {
    const v = (i % 1000) + 1;
    C.echo_p_2f64(outPtr, v, v + 0.5);
    if (out[0] !== v || out[1] !== v + 0.5) { stale++; if (first < 0) first = i; }
  }
  report("(ptr, f64, f64) -> i32", stale, first);
}

function tPf64u64(): void {
  let stale = 0, first = -1;
  for (let i = 0; i < N; i++) {
    const v = (i % 1000) + 1;
    C.echo_p_f64_u64(outPtr, v, BigInt(v + 1));
    if (out[0] !== v || out[1] !== v + 1) { stale++; if (first < 0) first = i; }
  }
  report("(ptr, f64, u64) -> i32 [bigint]", stale, first);
}

function tP5i(): void {
  let stale = 0, first = -1;
  for (let i = 0; i < N; i++) {
    const v = (i % 1000) + 1;
    C.echo_p_5i(outPtr, v, v + 1, v + 2, v + 3, v + 4);
    if (out[0] !== v || out[4] !== v + 4) { stale++; if (first < 0) first = i; }
  }
  report("(ptr, i32 x5) -> i32", stale, first);
}

function tP5f(): void {
  let stale = 0, first = -1;
  for (let i = 0; i < N; i++) {
    const v = (i % 1000) + 1;
    C.echo_p_5f(outPtr, v, v + 0.5, v + 1, v + 1.5, v + 2);
    if (out[0] !== v || out[4] !== v + 2) { stale++; if (first < 0) first = i; }
  }
  report("(ptr, f64 x5) -> i32", stale, first);
}

function tRf64(): void {
  let stale = 0, first = -1;
  for (let i = 0; i < N; i++) {
    const v = (i % 1000) + 0.25;
    if (C.echo_r_f64(v) !== v) { stale++; if (first < 0) first = i; }
  }
  report("(f64) -> f64 [no ptr arg]", stale, first);
}

function tI32(): void {
  let stale = 0, first = -1;
  for (let i = 0; i < N; i++) {
    const v = (i % 1000) + 1;
    if (C.f_add_i32(v, 7) !== v + 7) { stale++; if (first < 0) first = i; }
  }
  report("(i32, i32) -> i32 [no ptr arg]", stale, first);
}

const tests: Record<string, () => void> = {
  pf64: tPf64, pi32: tPi32, pu64big: tPu64Big, pu64num: tPu64Num,
  p2f64: tP2f64, pf64u64: tPf64u64, p5i: tP5i, p5f: tP5f,
  rf64: tRf64, i32: tI32,
};

const only = process.env.SHAPE;
if (only) {
  tests[only]();
} else {
  for (const t of Object.values(tests)) t();
  console.log(`bun ${Bun.version} ${process.platform}-${process.arch}, N=${N} per shape, dedicated loop fn per shape`);
}
for (const r of results) console.log(r);
