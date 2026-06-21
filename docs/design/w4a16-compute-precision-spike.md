# Research spike — W4A16 head GEMM (compute precision, not storage)

**Status:** proposed (not started) · **Opened:** 2026-06-19 · **Owner:** Josh
**Surface:** `src/train/flash-cce.ts` (steel + SG kernels) · **Gate:** the existing
1e-5 CCE parity gate + greedy-prefix logit parity.

> One-line thesis (Josh): *we've maxed **storage** quant (4-bit weights), but we
> dequant into fp32 and run the matmul in fp32 — so the head GEMM is **W4A32**.
> The untouched lever is **compute** precision: dequant 4-bit → half, matmul in
> `half` operands with an fp32 accumulator (**W4A16**), gate on parity. Same 4-bit
> storage, untouched. The only change is the float width we dequant into and
> multiply in.*

---

## TL;DR

- The flash-CCE head (forward logit GEMM `E@Wᵀ` and backward phase-2 `coeffᵀ@W`)
  currently runs **W4A32**: 4-bit weights are dequantized into **fp32** threadgroup
  tiles and multiplied with **fp32** simdgroup matrices. Verified in source (below).
- The 4-bit packing bought the cheap HBM read; the fp32 matmul throws away the
  compute advantage. Apple GPUs run **fp16 FMA at ~2× fp32** on the regular SIMD
  ALUs (no tensor cores). Both head GEMMs are **compute-bound** (see roofline note),
  so half operands are the lever.
- **Industry-standard for the forward** (MLX `quantized_matmul`, llama.cpp, every
  on-device 4-bit stack do exactly W4A16). Low risk; do it first.
- **Backward needs the mixed-precision caveat** — fp32 accumulate is non-negotiable
  (already planned), and the **operands** (`coeffᵀ`, `h`) need a dynamic-range probe
  before trusting fp16, specifically the near-zero coeff tails after the skips fire.
- **M1 Max constraint:** no `bf16` simdgroup_matrix (M2+ only), so **fp16 is the
  only half option** — which makes the range-probe matter more here than on M3.
- Gate exactly like the existing skip epsilons: **fp32 stays the default-exact
  parity mode**; half is the training default; the 1e-5 gate test runs against fp32.

---

## Current state — verified W4A32

The default production path for **both** forward and backward is the **steel**
kernel (MLX's verbatim `BlockMMA` GEMM, `steel-qmm-header.ts`), selected when
`H,V,blockV0 % 32 == 0` (`flash-cce.ts:1034`, `:1130`). The `simdgroup_float8x8`
SG kernels and the scalar/lane kernels are fallbacks for non-32-divisible shapes or
explicit `MLX_BUN_CCE_*` overrides.

Every one of these instantiations is fp32-operand:

| path | site | instantiation | operand width |
|---|---|---|---|
| steel fwd (default) | `flash-cce.ts:950` | `BlockMMA<float,float,…>` | fp32 |
| steel bwd phase-1 (default) | `flash-cce.ts:799` | `BlockMMA<float,float,…>` (lmma_t) | fp32 |
| steel bwd phase-2 (default) | `flash-cce.ts:800` | `BlockMMA<float,float,…>` (dmma_t) | fp32 |
| steel staging tiles | `:596–598`, loaders `:801` | `threadgroup float` / `BlockLoader<float,…>` | fp32 |
| SG fwd (fallback) | `:251–254` | `simdgroup_float8x8`, `Csh`/`Esh` = `threadgroup float` | fp32 |
| SG bwd (fallback) | `:617`, `:684–704` | `simdgroup_float8x8`, `Wsh` = `threadgroup float` | fp32 |

The dequant itself (`Csh[…] = sc * q + bi`, `flash-cce.ts:244`) computes into fp32
and stores fp32. The dh accumulator is already fp32 (`MMATile<float,…>`,
`flash-cce.ts:828`) — i.e. **the accumulator is already where it should be**; only
the matmul *operands* are wider than they need to be.

---

## The lever — what actually changes

W4A16 = **same 4-bit storage, half-width operands, fp32 accumulate.** Concretely:

1. **Steel operand type** — the `BlockMMA<float,float,…>` first template param is the
   GEMM input/operand type; flip operand to `half` while keeping the
   accumulator/fragment in `float`. (**Spike task 0: confirm the exact MLX steel
   template param that selects operand vs accumulator width** in
   `steel-qmm-header.ts` before editing — don't assume the param order.)
2. **Staging tiles** — `Esh`, `Cstg`, `Wsh`, `Csh` go `threadgroup half`; dequant
   arithmetic can stay fp32 then narrow on store, or compute in half.
3. **Loaders** — `BlockLoader<float,…>` → `BlockLoader<half,…>` to stage half tiles.
4. **SG fallback** — `simdgroup_float8x8` → `simdgroup_half8x8` for the operands,
   keep an `simdgroup_float8x8` accumulator (Apple supports the mixed `half×half→float`
   `simdgroup_multiply_accumulate`).

Everything reduction-shaped (the online-softmax `m`/`d` recurrence, the dh accum,
logsumexp) **stays fp32**.

---

## First thoughts (mine) — what to add to Josh's analysis

The analysis is right and the change is well-targeted. Five additions, each grounded
in the current source:

**1. Aim at the steel kernel, not the SG snippet.** Josh's note led with the SG path
(`simdgroup_float8x8`, `Csh`). That path is a *fallback*. The lever that moves the
measured 180 ms fwd / 754 ms bwd (e4b) numbers is the **steel `BlockMMA<float,float>`**
instantiations (`:950`, `:799`, `:800`) and their `BlockLoader<float>`/staging tiles.
Do the SG path too for completeness, but the steel path is where the production time is.

**2. The 2× is an upper bound gated by the FMA fraction — get the roofline split
first.** The whole flash-CCE design is `[M,V]`-free and amortizes dequant across
`BLOCK_B` tokens specifically because the **dequant ALU** was "the dominant cost in
v1" (`flash-cce.ts:59`). The runtime splits into (a) nibble-unpack + `sc·q+bi`
dequant and (b) the FMA matmul. **W4A16 only speeds up (b).** The kernel is
unambiguously compute-bound, not BW-bound — **confirmed live** (see the measured box
below), and Josh flagged it from `mactop` before this doc existed. *But* the win
ceiling is the FMA share of that ALU time. The dequant-amortization work was done
precisely to shrink (a)'s share, which *should* leave (b) dominant and favorable — but
**measure the (a)/(b) split before predicting 2×.** The live numbers prove the
*whole kernel* is ALU-bound; they do **not** resolve the intra-kernel (a)/(b) split,
which is what actually bounds the reclaim. If the kernel is still dequant-ALU-bound,
half operands move it less.

> **Live roofline — measured (M1 Max 32 GB, MiniCPM5-1B ORPO, `--no-segment`, seq 4096):**
> GPU **100% @ 1296 MHz, 81 °C, Nominal** (sustained, not throttling) · memory
> **BW 129.2 GB/s ≈ ⅓ of the M1 Max's ~400 GB/s ceiling** (bus two-thirds idle) ·
> mem **17.37 / 32 GB (54%)**, swap 0 · CPU ~5%, ANE 0%. The training `bun` proc is
> 92.6% GPU. **GPU pegged + memory bus mostly idle = ALU-bound.** This is the regime
> where W4A16 pays; if it were BW-bound (BW near 400, GPU spiky) the spike would be
> moot. The 4-bit storage already did its job — *that's why BW is low* — and the GPU
> is now spending its cycles on the fp32 FMAs.

**3. Threadgroup memory is a free secondary win — possibly a compounding one.** The
staging tiles (`Esh`/`Cstg`/`Wsh`/`Csh`) are the kernel's threadgroup-memory pressure,
and tile sizing is *already* occupancy-constrained — see the note at `flash-cce.ts:71`
("the 8KB `Csh` tile measured SLOWER"). Half-width staging **halves that footprint**,
which can either raise occupancy or admit larger tiles. So W4A16 may buy more than the
raw 2× FMA: it could relieve the exact constraint that capped the current tiling.
Worth re-sweeping `BLOCK_B`/tile dims *after* the precision change, not just measuring
the drop-in.

**4. SDPA in the segmented forward is probably already half — don't chase it.** Josh's
aside ("if your SDPA tiles are also fp32, same logic"). The segmented forward uses
`ops.sdpa` — MLX's own fused flash kernel ([[opssdpa-dk-vjp-bug]]) — which runs in the
model's dtype (bf16), **not** our fp32 tiles. So that lever is likely already pulled by
delegating to MLX. One-line confirm, then drop it; the head GEMM is the real target.

**5. Free instrumentation hooks already exist for the backward range-probe.** The
backward already computes `cmax = simd_max(coeff)` for the FILTER_EPS skip
(`flash-cce.ts:682`). That same reduction is the natural hook to log the coeff dynamic
range (min nonzero |coeff|) across a real run *before* committing the operand to fp16 —
the underflow-to-zero case Josh flagged. Pair it with a max-abs probe on `h`: at e4b's
`scale=1.0` peaked attention the residual stream can carry outliers
([[e4b-forward-length-sensitivity]], [[siglip-vision-parity-cross-build]]), and with no
bf16 on M1 Max we can't lean on a wider exponent to eat them.

---

## Risk analysis (preserving the forward/backward split)

**Forward — low risk, boring industry default.** Logits are well-scaled; the
online-softmax max-subtraction bounds the `exp` args. W4A16 here is what the dense
path already assumes. Validate against the 1e-5 gate (fp16 operands won't hold 1e-5 —
that's expected; the **fp32 path stays the exact-parity gate**, half is graded by
greedy-prefix logit agreement, same as the vision tier-a bar).

**Backward — fp16 matmul is mainstream, but as *mixed precision*, with eyes on
operand range.** What makes the forward safe (well-scaled, max-subtracted) is **not**
automatically true here:
- `coeff_v = g·(onehot − softmax)·sech²` — after the skips fire, the survivors are the
  **near-zero tails**. Small magnitudes are exactly where fp16's ~3-digit mantissa and
  narrow range (subnormals < ~6e-5) bite. **`coeffᵀ` as an fp16 operand is the highest
  risk** — tail coeffs underflowing to zero silently drop gradient contribution. Probe
  the range first (task 5 above).
- `h` (activations) as fp16 operand — residual outliers; the classic bf16-beats-fp16
  case, but bf16 isn't available on M1 Max. Range-check before trusting.
- **fp32 accumulate is non-negotiable** (already planned; `MMATile<float>` already is).
- **Validate grads against autograd, not a hand-derived backward** ([[opssdpa-dk-vjp-bug]]).

---

## Spike plan

Sequenced so each step is independently measurable and revertible (Josh: *"Don't flip
both at once — you'll learn more, and if parity drifts you'll know which GEMM did it."*).

- [ ] **0. Confirm the steel template semantics.** In `steel-qmm-header.ts`, identify
  which `BlockMMA`/`BlockLoader` template params are operand vs accumulator width.
  Exit: a one-line mapping, no code change.
- [x] **1a. Whole-kernel roofline — DONE (live).** GPU 100% / BW 129 GB/s (~⅓ of 400)
  on M1 Max confirms the kernel is ALU-bound, not BW-bound (see the measured box above).
  The spike is worth chasing.
- [ ] **1b. Intra-kernel split (still open).** Profile the steel fwd (180 ms) and bwd
  (754 ms, e4b) into dequant-ALU vs FMA fractions — 1a says the GPU is the wall, this
  says *which part* of the GPU work. Exit: a number that bounds the expected win. *If
  FMA < ~40% of either kernel, reset expectations before coding.*
- [ ] **2. Add the precision gate.** New codegen `#define` (e.g. `CCE_A_HALF`) +
  env flag (e.g. `MLX_BUN_CCE_A16`), mirroring `CCE_BWD_FILTER_EPS`/`CCE_BWD_BLOCK_EPS`
  (`flash-cce.ts:732`,`:739`). Default: fp32 (exact) for the parity suite; half is the
  training default. Per [[three-level-fidelity-tree-model]] the exact path must stay
  selectable.
- [ ] **3. Forward → half operands.** Steel fwd `BlockMMA`/loader/staging to half.
  Validate: 1e-5 gate (fp32 path) + greedy-prefix logit parity (half path) + measure
  the fwd GEMM delta. Land as its own change.
- [ ] **4. Backward range probe.** Instrument coeff (via the `simd_max` hook) and `h`
  dynamic range across a real MiniCPM5/e4b ORPO step. Exit: min-nonzero-coeff and
  max-|h| numbers + a go/no-go on fp16 operands.
- [ ] **5. Backward → half operands** (only if 4 says go). `coeffᵀ`/`h`/`W` operands
  half, dh accumulator stays fp32. Validate grads **vs autograd** + measure bwd delta.
- [ ] **6. Re-sweep tiling.** With half-width staging, re-check `BLOCK_B`/tile dims and
  occupancy (first-thought #3) — the precision win may unlock a tiling win.

**Exit criteria for the spike:** a measured fwd/bwd speedup on e4b (V=262144) and
MiniCPM5 (V=130560) on the bench machine (M4 Pro 24 GB; numbers verified against
`~/.cache/mlx-bun/evals.sqlite`, not docs — [[verify-benchmarks-against-evaldb-not-docs]]),
with the fp32 exact path still passing the 1e-5 gate and the half training path inside
the greedy-prefix parity bar. Either it lands as the training default behind the gate,
or the roofline/range data explains why it didn't pay and the spike closes with that.

---

## Open questions

- Steel `BlockMMA` mixed operand/accum: does MLX's steel already support
  `half`-operand / `float`-accum, or does it need a local template tweak? (task 0)
- Is the dequant cheaper to do **in half** (fewer ALU bits) or **in fp32 then narrow**
  (preserves the scale/bias precision)? A/B inside task 3.
- Does the half staging change the `+4-float` padding trick (`flash-cce.ts:197`, the
  BK_padded bank-conflict avoidance)? Half-width may re-introduce or shift bank
  conflicts — re-derive the pad.

---

## References

**Code:** `src/train/flash-cce.ts` — steel fwd `:937–1028`, steel bwd `:763–935`, SG
fwd `:174–270`, SG bwd `:561–726`, gates `:732`/`:739`/`:1034`/`:1130`; staging tiles
`:596–598`; dequant `:244`; coeff `simd_max` hook `:682`; dh fp32 accum `:828`.
`src/train/steel-qmm-header.ts` (the verbatim MLX BlockMMA). `src/mlx/metal-kernel.ts`
(kernel infra).

**Cross-links:** [[flash-cce-metal-kernel-prototype]] · [[three-level-fidelity-tree-model]]
· [[opssdpa-dk-vjp-bug]] · [[e4b-forward-length-sensitivity]] ·
[[verify-benchmarks-against-evaldb-not-docs]] · `docs/investigations/steel-flash-cce-handoff.md`.

**Sibling deferred lever** (queued together, post-run): `docs/design/orpo-future-enhancements.md`
→ "Deferred levers" (expose `--grad-accum`).
