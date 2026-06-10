// Decisive test: does the C function receive stale ARGS, or does JS read
// stale MEMORY afterward?
//
// echo_ret(double* out, double a) writes a to out[0] and returns (int32)a.
// - If the return value is wrong -> C truly received a stale argument.
// - If the return value is right but out[0] reads stale -> the FFI call is
//   fine; the typed-array LOAD after the call was hoisted/CSE'd by DFG
//   (aliasing bug: JIT assumes the native call cannot write that memory).
import { dlopen, FFIType, ptr } from "bun:ffi";

const lib = dlopen(new URL("librepro.dylib", import.meta.url).pathname, {
  echo_ret: { args: [FFIType.ptr, FFIType.f64], returns: FFIType.i32 },
});
const echo = lib.symbols.echo_ret;

const out = new Float64Array(1);
const outPtr = ptr(out);
const N = 100_000;

function main(): void {
  let staleRet = 0, staleMem = 0, firstRet = -1, firstMem = -1;
  let lastV = 0;
  for (let i = 0; i < N; i++) {
    const v = (i % 1000) + 1;
    lastV = v;
    const rc = echo(outPtr, v);
    if (rc !== v) { staleRet++; if (firstRet < 0) firstRet = i; }
    if (out[0] !== v) { staleMem++; if (firstMem < 0) firstMem = i; }
  }
  console.log(`return-value check: ${staleRet ? `STALE ${staleRet}/${N} (first ${firstRet})` : "OK"}`);
  console.log(`memory-read check:  ${staleMem ? `STALE ${staleMem}/${N} (first ${firstMem})` : "OK"}`);
  // Cold read after the loop: if memory now holds the final value, every
  // call wrote correctly and only the in-loop reads were stale.
  const cold = new Float64Array(out.buffer)[0];
  console.log(`cold read after loop: out[0]=${cold}, last sent=${lastV} -> ${cold === lastV ? "memory is CORRECT (reads were stale)" : "memory is WRONG (C got stale arg)"}`);
}
main();
