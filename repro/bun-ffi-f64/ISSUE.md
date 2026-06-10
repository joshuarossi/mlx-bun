# DRAFT — Bun GitHub issue (not yet filed)

> Status: repro confirmed on Bun 1.3.3 and 1.3.14 (latest), macOS arm64,
> 2026-06-10. Supporting experiments live in `repro/bun-ffi-f64/` in this
> repo; the standalone files referenced below are `issue/repro.c` and
> `issue/repro.ts`.

---

**Title:** Typed-array reads after a `bun:ffi` call return stale values once the calling function is JIT-compiled (DFG load elimination across native calls)

## What happens

If a hot JS function calls a `dlopen`'d native function that writes through a
pointer argument (`FFIType.ptr` obtained from `ptr(typedArray)`), reads of
that typed array *after* the call start returning **stale values** once the
calling function gets DFG-compiled (after ~6k–20k iterations). The native
call itself is fine — every argument arrives intact and the write lands in
the right memory. It's the subsequent JS read of the buffer that is wrong:
the load appears to be eliminated/CSE'd across the FFI call, as if the JIT
assumes a native call cannot clobber typed-array memory.

This silently corrupts any out-param-style C API binding (the dominant
calling convention in C libraries) in exactly the code that runs hot enough
to matter. We hit it in an LLM inference server where mlx-c out-params
started returning garbage mid-generation; it took a while to find because it
never reproduces in small isolated tests — only after JIT warm-up.

## Repro

`repro.c`:

```c
// cc -O2 -shared -o librepro.dylib repro.c
#include <stdint.h>

// Writes `a` into out[0]; returns (int32_t)b so the caller can verify the
// arguments arrived intact without reading memory.
int32_t write_and_check(double *out, double a, double b, double c, int32_t n, uint64_t s) {
  out[0] = a;
  return (int32_t)b;
}

// Ground truth: what does the memory at `out` actually contain right now?
double read_mem(double *out) { return out[0]; }
```

`repro.ts`:

```ts
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
```

Output on Bun 1.3.14 (macOS arm64, M4 Pro):

```
iter=16039: C wrote 39.5; memory actually contains 39.5; JS reads out[0] = 38.5
iter=16040: C wrote 40.5; memory actually contains 40.5; JS reads out[0] = 38.5
iter=16041: C wrote 41.5; memory actually contains 41.5; JS reads out[0] = 38.5
FAIL: 83878/100000 stale typed-array reads (first at iter 16039)
```

Bun 1.3.3 behaves identically (first failure at iter ~17.5k). Note the
smoking gun in each line: a *cold-path native read* of the same address
(`read_mem`) returns the freshly written value while the inline JS read of
`out[0]` returns the value from the iteration where tier-up happened.

## Evidence it's DFG load elimination, not FFI marshaling

1. **Arguments arrive intact.** A variant that captures everything the C
   function receives (pointer, three f64s, i32, u64) into globals and dumps
   them on mismatch shows C receives every argument exactly as sent, at
   every iteration, both before and after tier-up. Return values computed
   from those arguments are also always correct (`rc !== 7` never fires
   above; 0/100000 in a sweep where the return echoed a varying argument).
2. **The memory is correct.** `read_mem(outPtr)` (native, cold path) returns
   the freshly written value at the same moment `out[0]` reads stale.
3. **JIT tiers:**
   - default: FAIL
   - `BUN_JSC_useFTLJIT=false`: still FAIL
   - `BUN_JSC_useDFGJIT=false`: OK
   - `BUN_JSC_useJIT=false`: OK
4. **Onset correlates with tier-up thresholds** (~6k–20k iterations
   depending on function size), and the stale value is always the value from
   right around the moment of tier-up.
5. **Module top-level loops never reproduce it**; the loop must be inside a
   function (i.e., code DFG will compile).
6. **Contamination through shared callers:** once a helper function that
   performs FFI calls is hot, *every* call made through it reads stale from
   its first invocation — including calls to symbols never called before.

## Which signatures (each measured in a separate process, dedicated loop function, 80k iters, Bun 1.3.3)

| signature | result |
|---|---|
| `(ptr, f64) -> i32` | STALE (first ~13k) |
| `(ptr, i32) -> i32` | STALE (first ~14k) |
| `(ptr, u64) -> i32` (bigint or number arg) | STALE (first ~11k) |
| `(ptr, f64, f64) -> i32` | STALE (first ~14k) |
| `(ptr, f64, u64) -> i32` | STALE (first ~9k) |
| `(ptr, i32 ×5) -> i32` | STALE (first ~7k) |
| `(ptr, f64 ×5) -> i32` | STALE (first ~6k) |
| `(f64) -> f64` (verified via return) | OK |
| `(i32, i32) -> i32` (verified via return) | OK |
| `(u64, u64) -> u64` (verified via return) | OK |
| `(ptr) -> ptr` (verified via return) | OK |

The pattern: corruption is observed exactly when the result is read back
*through memory the native call wrote*; signatures verified via return
values are fine. (Bun 1.3.14 shows the same pattern, though some small
shapes need more iterations or don't trigger in a given run — it's
codegen-shape sensitive.)

## Workaround

Reading through `read.f64(ptr, 0)` from `bun:ffi` instead of indexing the
typed array returns correct values (verified clean over 100k iterations on
both versions). Disabling the DFG (`BUN_JSC_useDFGJIT=false`) also fixes it,
at a large perf cost.

## Environment

- Bun 1.3.3 and 1.3.14 (latest at time of writing), installed via bun.sh
- macOS 26.6 (Darwin 25.6.0), Apple M4 Pro (arm64)
- `cc`: Apple clang (any optimization level; the C side is trivial)

## Suspected cause

DFG appears to model the JIT'd FFI call as non-clobbering for typed-array
storage, so `GetByVal` on the buffer after the call is hoisted/CSE'd (and
store-to-load forwarding can serve reads from a value captured before the
call). If the FFI fast path is registered with the DFG via something like a
DOMJIT signature or an effects annotation that claims no heap writes, any
native function that writes through a pointer argument breaks this way.

We searched existing issues for f64/argument corruption, stale typed-array
reads, and JIT-related FFI bugs and found no report of this. #8430 (f64
argument corruption via the int32 epsilon coercion) is the nearest prior
art but is a different layer — in this bug the arguments and the native
write are provably correct.
