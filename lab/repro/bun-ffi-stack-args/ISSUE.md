# Bun GitHub issue — DRAFT (not yet filed)

> Found 2026-07-07 while binding `mlx_conv2d` (11 args) for the gemma-4
> audio tower. Repro confirmed on Bun 1.3.14, macOS arm64.
> Standalone repro: `repro.c` + `repro.ts` in this directory
> (`cc -dynamiclib -o repro.dylib repro.c && bun repro.ts`).

---

**Title:** `bun:ffi` mis-lays sub-8-byte stack arguments on macOS arm64
(writes one 8-byte slot per arg; Apple ABI packs at natural size)

## What happens

On Apple arm64, stack-passed arguments use **natural size and alignment**
(Apple's documented divergence from standard AAPCS64, which pads every
stack slot to 8 bytes). `bun:ffi` writes each stack argument to its own
8-byte slot. The two layouts agree only when every stack arg is 8 bytes
wide (or when a single trailing sub-8 arg is followed by an 8-aligned one).

For a signature like

```c
int f(void* res, uint64_t a, uint64_t b,
      int s0, int s1, int p0, int p1, int d0,   // x0..x7 (registers)
      int d1, int g, uint64_t stream);          // stack
```

the callee expects `d1 @ sp+0` (4 B), `g @ sp+4` (4 B), `stream @ sp+8`.
Bun writes `d1 @ sp+0`, `g @ sp+8`, `stream @ sp+16`, so the callee reads
`g = 0` (the high half of d1's slot) and `stream = <g's value>`.

We hit this binding `mlx_conv2d` from mlx-c: the shifted read turns the
`mlx_stream` handle into a small integer and mlx segfaults at ~0x1 inside
the call — it looks exactly like a bad binding, not an ABI bug, which is
why it's nasty to diagnose.

## Repro

`repro.c` echoes all 11 arguments back through the out-pointer; `repro.ts`
calls it with distinct values and diffs. On Bun 1.3.14 / macOS arm64:

```
got : 111,222,2,3,4,5,6,7,0,8
want: 111,222,2,3,4,5,6,7,8,999
CORRUPTED (bug present)
```

The same 11-arg call with all-`i64` parameters is correct (every stack slot
is 8 bytes, so the layouts coincide) — the bug needs a sub-8-byte type in a
stack position that is followed by further arguments.

## Why existing code rarely trips it

- ≤8 int-class args → everything is in registers (f32/f64 args go to
  v-registers and don't consume integer slots).
- All-pointer/u64 tails (common in handle-based C APIs) → 8-byte slots
  match either way.
- A `bool` as the only sub-8 stack arg followed by an 8-byte arg → the
  8-byte arg re-aligns to the next 8-boundary in both conventions.

So the break requires ≥2 stack args where a sub-8-byte one comes first —
`mlx_conv2d`'s `(int dilation_1, int groups, mlx_stream s)` tail is the
minimal natural example.

## Workaround (what we ship)

Declare the two adjacent stack `int`s as ONE `u64` and pack them
little-endian (`d1 | g << 32`): Bun's 8-byte slot then byte-matches the
Apple packed layout. See `src/mlx/ffi.ts` (`mlx_conv2d`) and
`src/mlx/ops.ts` (`conv2d`) — verified bit-exact against Python mlx
`conv2d` including the groups path.
