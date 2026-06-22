# flash-CCE host-buffer pin leak — post-mortem + L3 verification approach

**Date:** 2026-06-21 · **Status:** fixed (`fix(train): stop host-buffer pin leak…`,
commit `2592959`) + hardened (`harden(train): anchor ptr()'d FFI buffers…`, `6491696`).

## Symptom

ORPO LoRA training (MiniCPM5-1B, flash-CCE head + prefix-share + segmented
backward) crashed **natively** (segfault / "panic: A C++ exception occurred",
SIGTRAP — *not* an MLX-reported error) after a few hundred steps:

| config | crashed at |
|---|---|
| accum-4 + seg-2 (most ops/step) | step **363** |
| accum-4 + no-seg | step **783** |
| accum-1 + no-seg (fewest ops/step) | step **≥915** |

Tells: **deterministic** (same step across runs), **monotonic in ops/step**
(more kernel ops per step → earlier crash), and MLX `active` memory **flat**
(~1.3 GB) the whole time. Crucially, **it ran the entire training with zero
crashes on a 32 GB M1 Max**, and crashed on a 24 GB M4 Pro.

## Wrong turns (recorded so we don't repeat them)

1. **Agent sandbox** — the first crash was on a session-launched run, so the
   sandbox looked guilty. Ruled out: a user-launched run crashed at the *same*
   step 783.
2. **GPU-allocator fragmentation / OOM** — `peak` sat at 16.7 GB on a 24 GB
   box. Ruled out: with segmentation `peak` was only 2.9 GB and it crashed
   **earlier** (363), and the same 16.7 GB peak ran fine post-fix. Not memory.
3. **prefix-share fallback / templated-data seam** — a real new behavior (the
   `</think>\n\n` seam trips the byte-identical prompt check → two-forward
   fallback) but not the cause.
4. **grad-accum / grad-clip (the new settings this session)** — the right
   *thread* (look at what changed), wrong leaf. Both were exonerated.

## Root cause

`u32()` in `flash-cce.ts` (and the twin in `model/flash-attention.ts`) built the
tiny `shape` / `targets` kernel-argument arrays with **`MlxArray.fromView`** —
the **zero-copy pinning** path. `fromView` inserts the host `Uint8Array` into a
module-level `pinned` Map and hands MLX a raw pointer with an **async**
`unpinCallback` ("mlx may release buffers from its eval thread"). These args feed
a **lazy** kernel and are `dispose()`d in a `finally` *before the kernel
evaluates* — so the pin is never reclaimed in time. The pins **leaked**.

**Proof (the smoking gun).** Instrumenting `pinnedBufferCount()` per step on the
buggy code:

```
step 1: pinned 32   active 1.087GB
step 2: pinned 64   active 1.088GB
...
step 32: pinned 1024  active 1.099GB     →  +32 per step, never released
```

Perfectly linear `+32/step`, `active` dead flat. The leaked buffers live in the
JS heap + a threadsafe-JSCallback dtor queue, **outside MLX's `active`
accounting** — which is exactly why every symptom held: per-op accumulation (more
kernel calls/step → faster growth → earlier crash), `active` flat, native crash
(host allocator / callback queue corruption), and **machine-dependence** (a
24 GB box reuses the freed-but-pinned buffer sooner → a latent use-after-free
becomes a fatal read; 32 GB had the headroom to never hit it).

## Fix

`u32()` → **`fromBytesCopy`** (`mlx_array_new_data`, which **copies**). These
few-int arrays feed a lazy kernel and are disposed before it runs, so they must
be **MLX-owned**, not host-pinned. A few-int copy is free.

**Verification:** `pinned` goes `+32/step → flat 0`; the previously-fatal
seg-2/accum-4 config ran to **step 548** (past 363) clean; numerics unchanged
(copy vs pin = same bytes).

## Hardening (defense-in-depth)

- **`MetalKernel.apply` keepAlive** — anchor every `ptr()`'d JS buffer (output
  shapes, template-arg names, the input-handle array, the result slot) in a
  `keepAlive` list referenced after the FFI calls. `bun:ffi` `ptr()` does not
  retain its argument; this closes the same lifetime class. Pure-additive.
- Added `pinned: pinnedBufferCount()` to the per-step train metric as a permanent
  **canary** for this bug class (visible in `train-watch`).

## Lesson for the codebase

`fromView` (zero-copy pin) is only safe for buffers that **outlive the MLX
array** (mmap'd weights — `fromPointer`/`fromView` with process-lifetime memory).
For any **transient** host buffer handed to a **lazy** op and disposed before
eval, use the **copying** constructor (`fromBytesCopy`/`fromInt32`/`fromFloat32`).
Grep for `fromView` in hot paths when adding kernels.

---

# L3 verification approach (no oracle exists)

This bug also clarified how we *should* verify the flash-CCE ORPO head, because
"bf16-class error" was the wrong framing.

## The parity tiers

- **L1** — bit-for-bit drop-in for **mlx-lm** (proven: 8192/8192 greedy tokens
  identical).
- **L2** — bit-for-bit drop-in for **mlx-optiq**.
- **L3** — mlx-bun originals (the flash-CCE ORPO training head). **Neither
  mlx-lm nor optiq ships ORPO+CCE training — there is no oracle to be bit-exact
  against.**

So the "0.28% dh" figure is **not an error rate or a degradation.** It is the
**floating-point reassociation gap between two *correct* implementations** — the
flash kernel (tiled, online-softmax, fp32) vs the full-logits MLX head (a
different reduction order) — and the full-logits head is itself only a *proxy*,
not an oracle. Two correct reductions in different orders cannot be bit-identical;
0.28% is the inherent floor, not slop.

**Correctness in L3 is proven by what does NOT need a reference implementation:**

1. **Finite-difference gradient check** (`flash-fd-check.ts`) — the kernel's `dh`
   vs numerical ground truth to ~4 decimals. This is the real proof: it says the
   kernel computes the *right gradient*, independent of any other implementation.
2. **By-hand math audit** of the dequant, online-LSE recurrence, `coeff =
   onehot − softmax`, dh accumulation, and the `1/M` cotangent (done; clean).
3. **Agreement with the full-logits proxy** to fp-reassociation precision
   (logp 0.21%, dh 0.28%) — corroboration, not the proof.

## The coeff filter — measure on REAL data, not synthetic

`flash-cce-parity.ts` uses a **synthetic random hidden**, which gives a
**flat-ish** softmax (high entropy) → gradient mass spread across many tokens →
filtering the near-zero coeffs costs accuracy (the recorded 0.66%→2.7%). **That
is the filter's worst case and not what it's for.** On real trained-model
outputs the next-token distribution is **sharply peaked** (low entropy):
`coeff_v = c·(onehot_v − softmax_v)`, and for almost every non-target token
`softmax_v ≈ 0`, so its coeff ≈ 0 and dropping it costs ~nothing — the gradient
mass is in the target + the handful of high-softmax tokens. **The filter is
designed exactly for the peaky real-data regime; the synthetic benchmark
maximizes its apparent cost.**

**MEASURED (2026-06-22, `scripts/experiments/flash-cce-filter-realdata.ts`) — the
hypothesis holds.** On 8629 real response tokens from real examples (real model
forward, **real next-token targets**; mean P(true token) = 53.9% → genuinely
peaked), the filter's dh error vs exact:

| eps | dh error | backward speedup |
|---|---|---|
| 1e-6 | 0.024% | 1.15× |
| **1e-5** | **0.162%** (below the 0.33% bf16 floor → indistinguishable) | **1.35×** |
| 1e-4 | 0.681% | 1.47× |
| 1e-3 | 1.943% | 1.52× |

The synthetic `REAL=1` test (random targets) showed **21.4% @ 1e-4** — a ~30×
overstatement, an artifact of the onehot landing on a ~0-softmax random token.
**Verdict: enable the filter at eps ~1e-5** — free speed (error under the
reassociation floor) on real data. Re-measure as the model trains (peakedness
shifts), and always with REAL targets, never synthetic.

## Standing L3 gates (what to run, since there's no oracle)

Per the project's parity-as-correctness model (bit-exact where an ancestor
overlaps; KL + quality + benchmarks where it doesn't):

1. **Filter-on-real-data** — ✅ DONE (above): near-free at eps ~1e-5 on real
   targets (0.16% dh, 1.35× backward). `flash-cce-filter-realdata.ts`.
2. **Teacher-forced grad fidelity** — flash head vs full-logits head `dh`
   (gradient cosine + relnorm) on real data, as the standing L3 regression gate
   (replaces the synthetic-data parity number for *quality* claims).
3. **End-to-end quality eval** — the completed training run's downstream task
   quality (the real proof that L3 trains correctly).
