# ORPO training — design

Plan to add **ORPO** (Odds Ratio Preference Optimization, Hong et al. 2024)
as a third training `method` alongside `sft` and `dpo`. Status: **in production —
flash-CCE head (steel GEMM fwd+bwd) + prefix-sharing + segmented backward, composed
(see the STATUS callout below).**

ORPO folds the SFT objective and preference learning into a single
**reference-free** loss. Because it needs no reference model, it is a *smaller*
addition than DPO was — it reuses DPO's data format, loader, and batching, and
runs half the forwards per step.

> **STATUS (2026-06-19) — the ORPO stack is in PRODUCTION.** The flash-CCE head is
> live in both directions (verbatim MLX **steel** GEMM + ORPO epilogue; `[M,vocab]`-free;
> e4b backward **754 ms**, peak **0.93 GB flat @ M=8192**; `orpo_flash_ce`), prefix-sharing
> is trainer-wired (`orpo_prefix_shared`) and **composed with the flash head AND the
> segmented backward for both MiniCPM5 and e4b/Gemma4**, and adapter **warm-start**
> (`RESUME=`) landed — all default-on in [`scripts/train-orpo.ts`](../../scripts/train-orpo.ts).
> The ✅/🔬 entries + optimization log below are the **design/build history**; for the
> current usage, flags, and numbers see [training.md](../reference/training.md) +
> [orpo-quickstart.md](../reference/orpo-quickstart.md), and the live engineering record
> [steel-flash-cce-handoff.md](../investigations/steel-flash-cce-handoff.md).

> Oracle note: neither `mlx_lm` nor `optiq` ships ORPO, so — unlike DPO
> ([`loss.ts`](../../src/train/loss.ts) ported `optiq/lora/dpo.py`) — ORPO is
> an **L3 mlx-bun original**. Correctness is anchored to a standalone
> torch/numpy reference of the paper/TRL math (see [Parity](#parity)), not a
> bit-exact upstream port.

## Implementation status

**Landed (naïve correctness path — the shippable unit + the oracle everything
else validates against):**
- ✅ Mixed-precision rank scaling wired (`bitsMapFromModel` / `readPerLayerKl` →
  `resolveRanks`); unit-tested ([`tests/train-rank.test.ts`](../../tests/train-rank.test.ts)).
- ✅ ORPO loss: `branchLogpMean` (with the **response-only B=1 forward** — no
  full `[1,T,V]` logits, mirroring the SFT path), `log1mexp`, `orpoLogOdds`,
  `orpoLossFromLogps`, `orpoLoss`, `orpoMetrics` in
  [`loss.ts`](../../src/train/loss.ts). Math validated vs a standalone JS
  reference + autograd differentiability
  ([`tests/train-orpo.test.ts`](../../tests/train-orpo.test.ts)).
- ✅ `orpoLoop` + dispatch + `orpoLambda`/`orpoWarmupIters`/`orpoLrSchedule`
  config; `job.ts` submit surface + `1e-5` LR default; `/finetune` UI method
  picker + λ/schedule panel.
- ✅ End-to-end verified on MiniCPM5-1B (gated
  [`tests/train-orpo-e2e.test.ts`](../../tests/train-orpo-e2e.test.ts)): loss
  improves, preference accuracy reported, adapter saved + mountable, adapted
  generations differ.
- ✅ Docs: [training.md](../reference/training.md) updated.

**Also landed:**
- ✅ Dataset format renamed `"dpo"` → `"preference"` (with `"dpo"` kept as alias in
  the type); [`tests/train-dataset.test.ts`](../../tests/train-dataset.test.ts) updated.
- ✅ Parity oracle script
  [`scripts/experiments/parity-orpo.ts`](../../scripts/experiments/parity-orpo.ts):
  10/10 checks pass — scalar loss, log1mexp stability, gradient checks (finite
  differences vs autograd) at B=1 and B=3, edge cases.
- ✅ `fusedGegluDifferentiable` in
  [`src/model/fused-geglu-kernel.ts`](../../src/model/fused-geglu-kernel.ts):
  `CustomVjp`-backed version with hand-derived backward (grad\_b = dc·gelu(a),
  grad\_a = dc·b·gelu'(a)); tested in
  [`tests/fused-geglu-vjp.test.ts`](../../tests/fused-geglu-vjp.test.ts).
- ✅ **Fused GeGLU wired into the e4b training path.** A training-mode flag
  (`setFusedGeluTraining`, set by the trainer around the loop, cleared in its
  finally) makes BOTH Gemma GeGLU sites — the MLP (`gelu(gate)·up`) and the
  per-layer-input gate (`gelu(gate)·pli`) — use the differentiable wrapper during
  training and the plain `fusedGeglu` (byte-for-byte unchanged) at inference.
  **This removes the `MLX_BUN_FUSED_GELU=0` requirement for training** (the plain
  kernel is a bare `CustomKernel` with no vjp; feeding it to autograd threw
  `[Primitive::vjp] Not implemented for CustomKernel`). Bonus: the backward
  recomputes the gelu from the primal instead of retaining the ~9 spelled-out
  intermediates, lowering the MLP activation memory the backward holds (the
  dominant resident at long context under `ops.sdpa`). **Validated** on real e4b
  ([`scripts/experiments/fused-geglu-train-parity.ts`](../../scripts/experiments/fused-geglu-train-parity.ts)):
  forward loss bit-identical to the spelled-out path (kernel is kl=0), both sites
  dispatch (168 = 42 layers × 2 sites × 2 ORPO branches), spelled arm fused-free,
  grads match in the kernel's bf16 class (~2%; the forward is exact, the backward
  is two bf16 computations of the same gelu derivative — the hand-vjp is validated
  to the closed form at tol 0.05 in the vjp test). Composes with the segmented
  path (the fused `CustomVjp` nests inside the segmented `mlx_vjp`: segmented ORPO
  still PASSES with fused on, peak 11.25 GB full → 7.58 GB segmented). Unit guard
  ([`tests/fused-geglu-vjp.test.ts`](../../tests/fused-geglu-vjp.test.ts)): the
  flag toggles and the differentiable forward bit-matches the plain kernel.
  Training still needs `MLX_BUN_PERF_KERNEL=0` (a separate no-vjp perf kernel —
  its own follow-on).
- ✅ `responseOnlyLogpMean` helper in `loss.ts` (post-finalNorm h → mean response
  logp; used by the ORPO head VJP).
- ✅ `SegmentedBackwardOrpo` in
  [`src/train/segmented.ts`](../../src/train/segmented.ts): MiniCPM5 segmented
  backward for ORPO — runs chosen+rejected forwards segment-by-segment, two-input
  head VJP (`new Vjp(fn, 1)` with `apply([hC, hR], [one])` → vjps[0]=dh\_c,
  vjps[1]=dh\_r), backward passes sum LoRA grads from both branches. Wired into
  `orpoLoop` behind the existing `segmentSize > 0` gate.
- ✅ **Token-chunked LM head (the large-vocab moat):** `chunkedLogpMeanB1` +
  `ChunkCtx` in [`loss.ts`](../../src/train/loss.ts), gated by `orpoChunkSize`
  (`TrainConfig` / `orpo_chunk_size`). Each token-chunk's head is wrapped in a
  `Checkpoint` so its `[chunk, vocab]` logits are recomputed in the backward
  instead of all `[M, vocab]` retained — bounding the dominant large-vocab term
  to `[chunkSize, vocab]`. The per-chunk checkpoints, plus the hidden/slices they
  read (a Checkpoint *drops* its input activations, so freeing them early
  corrupts the result — found and fixed during bring-up), live in a `sink`
  disposed by `orpoLoop` via `accumulateStep`'s `afterMicroEval` hook (after the
  grads are eval'd). Verified gated
  ([`tests/train-orpo-chunked.test.ts`](../../tests/train-orpo-chunked.test.ts)):
  forward parity vs non-chunked within **bf16 tolerance** (the only divergence is
  occasional single-ULP head-matmul rounding that tiles differently for `[M,V]`
  vs `[chunk,V]` — sub-bf16, the established class), **exact** for a single
  chunk, and the chunked backward trains + improves loss. This is **token-axis**
  chunking — the high-impact win for our case (`M` up to thousands × 262k vocab).
  **Vocab-axis** chunking + online-LSE (CCE-style) is unnecessary at 262k
  (`[1, 262k]` bf16 ≈ 0.5 MB) and remains a future tier.

- ✅ **Fused linear-CE head (Liger `FusedLinearCrossEntropy` ported to MLX)** —
  `fusedLogpMeanB1` (`loss.ts`), gated by `orpo_fused_ce`. A single `CustomVjp`
  with an ANALYTIC `softmax−onehot` backward (no autograd through logsumexp+gather,
  no retained `[M,V]` logits in either direction); `dh` via mlx's own
  quantized-matmul x-vjp (`transpose=false`); Gemma softcap matched bit-exactly to
  `logitSoftcap`. Value BIT-EXACT vs the full-logits head on MiniCPM5 **and** e4b;
  grads 0.51%/1.97% bf16-class; peak `[chunk,V]`-bounded. See
  [lever 1](#ranked-levers-with-our-setup-verdicts) for the full write-up. This is
  the deeper engine the token-chunked Checkpoint head approximated.

- ✅ **Benchmark + parity harness** (the perf-tracking discipline):
  [`scripts/bench-orpo.ts`](../../scripts/bench-orpo.ts) (ms/step + peak GB
  across head/segment configs on synthetic long-response data) and
  [`scripts/bench-attn-backward.ts`](../../scripts/bench-attn-backward.ts)
  (attention-backward dQ/dK/dV parity vs a materialized reference + timing).
  MiniCPM5-1B @ SEQ=1024: baseline 3191 ms / 9.34 GB · chunked-head(256) **2758
  ms / 8.62 GB** (faster + lower) · segmented(4) 3633 ms / **2.45 GB** (the
  dominant memory lever — layer activations, not the head, dominate at this
  scale/vocab; the head win grows with vocab, e.g. Gemma's 262k).
- ✅ **SDPA backward — flash kernel FIXED to L2 parity (kept, not deleted).**
  Parity oracle, made explicit: the default `ops.sdpa` training path is **L1**
  (mlx-lm's tuner differentiates the same `mx.fast.sdpa`); the flash kernel is
  **L2** — a port of mlx-optiq's `flash_attention_metal`, so **optiq is its
  oracle**. Confirmed end to end: optiq's flash dK == `ops.sdpa` to f16
  (`scripts/flash-optiq-check.py`, rel **0.0%**), and mlx-bun's fixed flash ==
  `ops.sdpa` (`tests/flash-attention.test.ts`, ≤f16) ⟹ **mlx-bun flash == optiq
  (L2 parity)**; `ops.sdpa` itself is finite-difference verified. The original
  kernel diverged ~100% from optiq on dK — a genuine **port bug**: a spurious dK
  transpose in `flashBackward` (corrupted dK for Tkv≠D) + a per-thread
  (divergent) `threadgroup_barrier` in the dQ causal tile-skip; both fixed. The
  real `ops.sdpa`-vs-flash tradeoff is **memory**: `ops.sdpa` backward is
  **O(L²)** (0.02→0.33→1.40 GB at T=512/2048/4096), flash is **O(L)**
  (0.03→0.23→0.90 GB) but ~30× slower → flash is the opt-in long-context path.
  **Lessons:** (1) state parity *to a named oracle* (L1 mlx-lm / L2 mlx-optiq),
  not "correct"; (2) "fix, don't delete" — the kernel had a localized, fixable
  port bug + a real memory purpose; (3) a parity reference is trustworthy only if
  read **contiguously** (`ops.contiguous` before `toFloat32`) with a
  **non-uniform cotangent** — both pitfalls produced false "kernel is wrong"
  signals; finite differences settled it.
- ✅ **Regularization knobs (the small-set overfitting toolkit):** **LoRA-input
  dropout** (`lora_dropout`) — recompute-safe (mask keyed by step+layer so the
  segmented/checkpoint backward reproduces it; verified by a finite+improving
  loss through the segmented recompute path); **rsLoRA** (`rs_lora`, α/√rank,
  wired train→save→load so inference applies the same per-layer scale); **LoRA+**
  (`lora_plus_ratio`, per-param LR in AdamW — B leaves get the higher LR).
  Unit-tested ([`tests/train-regularization.test.ts`](../../tests/train-regularization.test.ts))
  + gated e2e with all three on through segmented recompute
  ([`tests/train-regularization-e2e.test.ts`](../../tests/train-regularization-e2e.test.ts)).
  The dangling `/finetune` dropout field is now wired (`lora_dropout`).
- ✅ **Segmented backward for ORPO on e4b** (`SegmentedBackwardOrpoGemma4`,
  [`src/train/segmented.ts`](../../src/train/segmented.ts)): the cross of
  `SegmentedBackwardGemma4` (per-layer-input boundary + cross-segment KV-shared
  donor cotangent threading) and `SegmentedBackwardOrpo` (two branches +
  reference-free ORPO head). Each branch streams forward saving detached
  hidden + reused-donor K/V boundaries + its own masks/per-layer constant; the
  ORPO head vjp over `[last_chosen, last_rejected]` yields `[dh_c, dh_r]`; each
  branch walks backward in reverse over its segments (donor cotangents
  accumulated in a per-branch `dKV`), and the two branches' LoRA grads are
  summed. Wired into `orpoLoop` (`segment_size > 0`, B=1) alongside the MiniCPM5
  path. **Validated** ([`scripts/experiments/segmented-grad-test-orpo-e4b.ts`](../../scripts/experiments/segmented-grad-test-orpo-e4b.ts),
  grad-parity vs the monolithic ORPO `value_and_grad` on real e4b, 2026-06-18):
  loss matches to ~6 decimals; at **λ=0 the path is byte-identical** to the SFT
  `SegmentedBackwardGemma4` (relNorm 1.1341%, maxAbs 3.79e-3 — same numbers,
  proving zero added error); the donor-KV recipients (layers 22/23 k/v_proj,
  the direct dKV recipients) stay clean (<0.5%), proving the cross-segment donor
  threading; overall match sits in the e4b segmented bf16-class (~1.1% flash /
  ~2.0–2.3% sdpa, the same level the SFT path shows here). **Peak**: full
  two-branch ORPO backward **12.67 GB → segmented 7.66 GB** at L=256 (saved
  5 GB — a bigger win than SFT's 2.4 GB, since the two-branch full backward
  holds both branches at once); 8.71 GB at L=1024 where the full backward
  won't fit.
- ✅ **Shared prompt-prefix reference (lever 7, MiniCPM5)** in
  [`src/train/prefix-shared.ts`](../../src/train/prefix-shared.ts): one forward
  over `[prompt; chosen; rejected]` with a block-sparse mask + block-wise RoPE.
  Validated 2026-06-18 — **forward BIT-EXACT** vs the two-forward path, grads in
  the bf16 class (~1.05%), **1.78× fewer token-passes**, peak 5.40 → 3.80 GB. See
  [lever 7](#ranked-levers-with-our-setup-verdicts) for the full write-up.
  **LANDED (2026-06-19):** wired into the trainer (`orpo_prefix_shared`), composed
  with the flash-CCE head per branch AND with the segmented backward
  (`SegmentedBackwardOrpoPrefix`); the e4b port is composed too (next entry).
- ✅ **e4b prefix-shared port — LANDED + composed with the segmented backward
  (`SegmentedBackwardOrpoPrefixGemma4`, 2026-06-19); the length-sensitivity below is an
  accepted numerical caveat for a fine-tune, not a blocker** (seg-vs-non-seg-same-prefix
  grads match to 1.7–2.3%, loss bit-exact-class). Ported to Gemma e4b
  (`setGemmaPrefixPlan` + block-wise RoPE in [`gemma4.ts`](../../src/model/gemma4.ts)
  `Attention.ropeBlocks`; `blockSparsePrefixMaskGemma` with a LOGICAL-position
  sliding-window cut + `Gemma4PrefixSharedCache` + `orpoLossPrefixSharedGemma` in
  [`prefix-shared.ts`](../../src/train/prefix-shared.ts), reusing
  `forwardHidden` for per-layer-input + donor-KV). **The construction is proven
  correct**: the prefix-shared forward is BIT-EXACT to a plain forward over the
  same concatenated sequence (`scripts/experiments/prefix-shared-e4b-localize.ts`:
  block-wise-RoPE+block-mask path `(c)` == plain-concat path `(b)` to 0.00% at
  every chosen position; per-layer-inputs bit-exact across lengths). **But it does
  NOT numerically reproduce the two-forward path on e4b**: prefix-shared forward
  loss diverges ~0.08% and the chosen/rejected hiddens up to ~3-14% from the two
  separate `[prompt;resp]` forwards — because **the e4b full-forward is itself
  length-sensitive**. Demonstrated model-only, independent of prefix-sharing:
  `forward([prompt])` vs `forward([prompt;extra])` differ **1.7% at position 0**
  (one attention key — softmax=1.0, cannot reassociate) up to **~14%** at later
  prompt positions, even though those positions are causally independent of the
  appended tokens, and even through the **production `TrainingCache`** path (fused
  causal). Root cause = e4b's **scale=1.0 attention** (headDim 256, q/k normed →
  q·k ~N(0,256) → sharply peaked softmax) amplifying sub-bf16 matmul-tiling
  roundings that vary with the row count — the SAME amplification class documented
  for the e4b SigLIP vision tower ([[siglip-vision-parity-cross-build]]). MiniCPM5
  (standard `1/√d` scale) shows 0.00% length-sensitivity, which is why its
  prefix-shared path is bit-exact to two-forward. **Consequence:** on e4b,
  prefix-sharing is a *self-consistent* computation (correct gradients of a valid
  single-concat loss; 1.78× fewer prompt-token passes, peak proportionally lower)
  but is NOT a drop-in numerical equivalent of two-forward training the way it is
  on MiniCPM5. **Decision pending** (Josh): land it framed via the
  single-concat-forward oracle / defer / investigate the length-sensitivity
  further. Code is committed-ready; the parity script's two-forward comparison is
  expected to show the e4b-class divergence, not bit-exactness.

**Follow-on (each validated against the naïve path via the
[oracle ladder](#parity)):** **optimize** the (now-correct) flash kernel — it's
~30× slower than `ops.sdpa` because it's a naive scalar Metal kernel (no
`simdgroup_matrix`, 32-thread threadgroups → ~0.5% of GPU peak), whereas
`ops.sdpa` is MLX's hand-tuned simdgroup-matrix flash. Its O(L) memory only pays
off when `ops.sdpa`'s O(L²) won't fit (≳16K context). **Note (future research
spike):** MLX is open source — we can read exactly how
`mx.fast.scaled_dot_product_attention` is implemented (simdgroup-matrix tiling),
match it, and then potentially **beat it for OUR specific use case** (fixed
head-dims, training-only backward, our seq-len/precision regime, the O(L)
memory constraint they don't optimize for). Not now — `ops.sdpa` is the fast
default and the current training (`ft-e4b-v2.sh`, no `MLX_BUN_TRAIN_ATTN`) uses
it for both forward and backward; the flash kernel is the dormant opt-in
fallback. Then: fused GeGLU wired into model training path,
intra-layer MLP split, shared prompt-prefix.
**End goal:** a before/after ORPO quality experiment on Gemma e4b or Qwen-4B
(curated preference set + a benchmark eval).

## The objective

$$\mathcal{L}_{ORPO} = \mathcal{L}_{NLL}(y_w) + \lambda \cdot \mathcal{L}_{OR}$$

- $\mathcal{L}_{NLL}(y_w)$ — standard SFT cross-entropy on the **chosen**
  response (prompt positions masked out), i.e. the negative mean response
  log-prob $-\ell_w$.
- $\mathcal{L}_{OR} = -\log \sigma(\text{log\_odds})$, the odds-ratio term:

$$\text{log\_odds} = (\ell_w - \ell_r) - \big(\text{log1mexp}(\ell_w) - \text{log1mexp}(\ell_r)\big)$$

where $\text{log1mexp}(x) = \log(1 - e^{x})$, and $\ell_w, \ell_r$ are the
**length-normalized** (mean over response tokens) log-probabilities of the
chosen / rejected responses. $\lambda$ weights the preference term.

### Two facts that shape the implementation

1. **Length normalization (mean, not sum).** This is the one substantive
   difference from our DPO code, whose `seqLogp` returns the per-row *sum* of
   response log-probs. ORPO requires the *mean*: $\ell = (\sum_t \log p_t) /
   (\#\text{response tokens})$. Faithful to the paper and TRL; summing instead
   would bias toward shorter responses.

2. **The chosen forward does double duty.** Since
   $\mathcal{L}_{NLL}(y_w) = -\ell_w$, the same $\ell_w$ feeds both the SFT term
   and the odds ratio. So ORPO is **2 forwards/step** (chosen + rejected),
   versus DPO's **4** (2 reference at scale 0 + 2 policy). No reference model,
   no `setLoraScale(0)` dance, no detached reference tensors — lighter on
   compute and memory than DPO.

## How it slots into the current trainer

Training is already method-dispatched, so ORPO is additive:

- [`trainLora`](../../src/train/trainer.ts) dispatches on `cfg.method`
  (`dpo` → `dpoLoop`, else `sftLoop`). Add an `orpo` branch → `orpoLoop`.
- All loops share the same scaffold: `resolveRanks` → `buildTrainableLora` →
  `AdamW` → a `ValueAndGrad` closure that swaps LoRA A/B primals so only those
  leaves differentiate. ORPO reuses it unchanged.
- Data: ORPO consumes the existing **preference** format
  `{prompt, chosen, rejected}` (today labeled `dpo`), via `loadDpoDataset` /
  `iterateDpoBatches` / `DpoBatch`. No new dataset code.

## File-by-file changes

### `src/train/loss.ts` (the only real new logic)

- **`branchLogpMean(model, ids, mask, validLen)` → `[B]`** — like `branchLogp`
  but returns the **mean** response log-prob per row (sum / mask-count).
  - B=1 uses a **response-only forward** (mirrors `responseOnlyCe`):
    `trainForwardHidden` → `sliceDynamic` the response span
    `[promptLen-1, len-1)` → `logitsFromHidden` on just that slice → gather the
    target log-probs → divide by `M` response tokens. This avoids
    materializing the `[1, T, V]` logits (and its grad) — the dominant
    long-context memory term — exactly as the SFT path already does.
  - B>1 falls back to full-logits `branchLogp` + per-row mean (DPO/ORPO default
    `batch_size` is 1, so this is the rare path).
- **`log1mexp(x)`** — stable `log(1 - exp(x))`. We have
  `exp/sub/log/clip/softplus/where/less` but **no `expm1`/`log1p`**. With
  length-normalized average log-probs, `x` is comfortably negative (per-token
  mean log-prob is well below 0), so `log(clip(1 - exp(x), eps, 1))` with a
  small `eps` is numerically safe; comment the near-zero edge case.
- **`orpoLoss(model, batch, lambda)` → scalar** —
  `ℓw = branchLogpMean(chosen)`, `ℓr = branchLogpMean(rejected)`,
  `nll = mean(-ℓw)`, `logOdds = (ℓw-ℓr) - (log1mexp(ℓw)-log1mexp(ℓr))`,
  `or = mean(softplus(-logOdds))`, return `nll + lambda*or`. Caller owns.
- **`orpoMetrics(model, lora, batch, lambda)`** (no grad) — loss with its
  `nll` / `or` split, preference accuracy (`ℓw > ℓr`), and reward margin. No
  reference forward.

### `src/train/trainer.ts`

- `TrainConfig`: add `orpoLambda: number`; extend `method` to
  `"sft" | "dpo" | "orpo"`.
- `DEFAULT_TRAIN_CONFIG`: `orpoLambda: 0.1` (TRL default; paper uses 0.1–1.0).
- `trainLora`: dispatch `method === "orpo"` → `orpoLoop`.
- `orpoLoop` — a `dpoLoop` clone **minus** `dpoRefLogps` and the `refChosen`/
  `refRejected` tensors. The `ValueAndGrad` closure calls `orpoLoss` directly.
  Reuse `warmupCosineSchedule`, driven by **`orpo`-prefixed** config knobs (see
  below). Emit the same train/val metrics, plus the nll/or split from
  `orpoMetrics`.

**Method-prefixed params (decided).** Schedule/strength knobs are namespaced
per method so each set reads naturally for its method — `dpo_*` for DPO,
`orpo_*` for ORPO. Add to `TrainConfig`: `orpoLambda`, `orpoWarmupIters`,
`orpoLrSchedule` (mirroring the `dpo*` trio). `orpoLoop` reads the `orpo*`
knobs; `dpoLoop` keeps reading `dpo*`. No shared/renamed fields.

### `src/train/job.ts`

- `FinetuneSubmit.method`: add `"orpo"`; add `orpo_lambda?: number`.
- `parseConfig`: pass `orpoLambda` / `orpoWarmupIters` / `orpoLrSchedule`; LR
  default branch `method === "orpo" ? 1e-5 : ...` (see Recommended defaults —
  **not** DPO's `5e-5`).

### `src/train/dataset.ts`

- Minimal. ORPO loads via `loadDpoDataset`. Accept `probeFormat` returning the
  preference shape for `method: "orpo"`. Optionally introduce a user-facing
  `"preference"` label with `dpo` kept as an alias, so the format name is not
  method-specific.

### Surface

- [`docs/reference/training.md`](../reference/training.md): add ORPO to the
  "SFT vs DPO" section (→ "SFT / DPO / ORPO"), the data-format table (the
  preference format serves both), and the config table (`orpo_lambda`).
- `/finetune` web UI: add `orpo` to the method picker; show λ when selected.

## Recommended defaults

From a hyperparameter spike on ORPO-for-LoRA-on-small-models (paper, TRL
`ORPOConfig`, and Labonne's Llama-3 ORPO-LoRA recipe). The one trap: the
paper's `8e-6` LR is for **full** fine-tuning — do not inherit it for LoRA, and
do not inherit DPO-LoRA's higher `5e-5` either, because ORPO's loss carries a
full SFT NLL term that a high LR destabilizes.

| Knob | Default | Why |
|---|---|---|
| `learning_rate` | **`1e-5`** | Matches our SFT recipe; lower than DPO-LoRA (`5e-5`) because the SFT NLL term is in the loss. Sweep range 5e-6–2e-5. |
| `orpo_lambda` (λ) | **`0.1`** | Paper's primary value + TRL default. Weights **only** `L_OR`; `L_SFT` stays unweighted. Stable range 0.1–0.5 (λ=1.0 also depresses chosen log-probs). |
| `orpo_lr_schedule` | **`cosine`** | Paper: linear warmup → cosine decay (linear fine for short runs). |
| `orpo_warmup_iters` | **≈3% of `iters`** | Paper warmup_ratio ≈0.03; ~10 steps on very short runs. |
| `scale` (LoRA α) | keep **`20`** (our recipe) | Labonne uses 32 (α=2·r); either is fine — no ORPO-specific reason to change ours. |
| `rank` | **`16`** | Matches our SFT recipe and Labonne's ORPO-LoRA. |
| epochs | **1** to start | ORPO is single-stage/data-efficient; eval loss rises fast past epoch 1–2 — early-stop on val rather than running long. |

Sources: [ORPO paper (EMNLP 2024)](https://aclanthology.org/2024.emnlp-main.626/),
[TRL `orpo_config.py`](https://github.com/huggingface/trl/blob/main/trl/trainer/orpo_config.py),
[Labonne, Fine-tune Llama 3 with ORPO](https://huggingface.co/blog/mlabonne/orpo-llama-3).

> Implementer correctness notes from the spike: `L = L_SFT + λ·L_OR` — the SFT
> term is **unweighted** (only `L_OR` carries λ); the odds ratio uses the
> **length-normalized mean** log-prob (summing reintroduces length bias and
> makes the `L_OR` gradient length-dependent); the `1/(1−P)` factor in the OR
> gradient amplifies low-likelihood updates (another reason to keep LR
> conservative); and `log1mexp` is the NaN hazard (clamp / two-branch).

## Regularization & optimizer geometry

ORPO is data-efficient and usually run ~1 epoch on small preference sets, so
**overfitting and step-size geometry matter more than raw capacity**. The knobs,
ordered by leverage, with the non-obvious LoRA interactions called out.

### Rank is the primary regularizer

Low rank *is* the capacity limit — the main implicit regularizer, and the
`rank_scaling` policy (`by_bits` / `by_kl`) is how capacity is *distributed*
across layers. Treat rank as the first dial; weight decay and dropout are
secondary. This is also why wiring the `bitsMap` (above) matters: it lets the
regularizer (capacity) track per-layer precision instead of silently going
uniform.

### The rank ↔ scale ↔ init interaction (the one to get right)

Our effective update is `α·B A` with `α = scale` and **B zero-init, A
uniform(±1/√in)** (so `ΔW=0` at step 0; adapted == base). Two consequences:

1. **At step 0 only B moves.** The LoRA backward is `dA = α·xᵀ(dy Bᵀ)`,
   `dB = α·(xA)ᵀ dy`. With `B=0`, `dA ∝ dy Bᵀ = 0` — **A has zero gradient on
   the first step**; B does all the early learning until it lifts off zero. This
   is intended, but it means B's effective LR and A's init scale (which sets the
   magnitude of `h=xA`, hence the first `dB`) dominate early dynamics. It's the
   reason **LoRA+** (a higher LR for B than A, often ~16×) helps — B is on the
   critical path. Worth exposing as an optional `orpo`/LoRA knob.
2. **Fixed `α` distorts rank scaling.** With `by_bits`/`by_kl` varying rank per
   layer, a *fixed* `α` makes the effective step size scale with rank — so
   wider adapters get bigger *updates*, not just more *capacity*, defeating the
   intent. **rsLoRA** (rank-stabilized: scale by `α/√r` instead of `α/r`-style)
   decouples capacity from step size and keeps gradients stable as rank grows.
   Given our rank-scaling story, this is a real correctness/stability fix, not a
   nicety — flag it as a `scale` policy option to evaluate.

### Weight decay — note the geometry, then probably lower it

AdamW already applies `weight_decay` (default `0.01`) to A/B. But decaying A and
B independently is **not** L2 on the effective update `ΔW=αBA` — minimizing
`‖A‖² + ‖B‖²` subject to a fixed `BA` is a **nuclear-norm-style** (low-rank)
penalty on `ΔW`, not Frobenius. So LoRA weight decay nudges toward
lower-effective-rank updates. For ORPO specifically the **SFT-NLL term already
anchors** the model to high chosen-likelihood (a built-in regularizer), so heavy
WD is often redundant — consider defaulting **lower (e.g. 0.0–0.01)** and tuning,
rather than inheriting the SFT `0.01` blindly.

### LR schedule & warmup

Cosine decay with a short warmup (`orpo_lr_schedule` / `orpo_warmup_iters`,
≈3%). Warmup matters *more* for ORPO than SFT: the odds-ratio gradient carries a
`1/(1−P)` factor that **amplifies low-likelihood updates**, so a cold high LR is
extra destabilizing. Reuse `warmupCosineSchedule` (already in the DPO loop).

### Dropout

LoRA-input dropout (PEFT-style), default `0.0`, `~0.05` for small sets — see the
[Dropout subsection](#dropout) for wiring and the **recompute-determinism**
constraint (the mask must be replayed in the segmented/checkpointed/chunked
backward or grads diverge). ORPO's base has no dropout modules (TRL's
`disable_dropout` is moot for us); only the adapter dropout is in play.

> Net: rank (+ `bitsMap`-aware scaling) is the main regularizer; **rsLoRA**
> (`rs_lora`), **LoRA+** (`lora_plus_ratio`), and **LoRA dropout** (`lora_dropout`)
> are now implemented (default off); default weight decay **lower** than SFT (the
> SFT-NLL term anchors); cosine + warmup. The remaining open work is **empirical**
> — sweep `rs_lora`/`lora_plus_ratio`/`lora_dropout`/`weight_decay` on a real run
> and watch the held-out **val margin** (`bestMargin` in metrics.json) to pick
> the setting that resists the ~450-example overfit.

## Parity

Anchor the loss math to a **standalone torch/numpy reference** (the paper /
TRL `odds_ratio_loss` + the NLL term) rather than an upstream port:

- `scripts/experiments/parity-orpo.ts` (or a `.py` companion run under the
  oracle venv): feed fixed `(chosen_logits, rejected_logits, masks)` to both
  our `orpoLoss` and a hand-written reference; assert the scalar loss,
  `log_odds`, and the nll/or split match to tolerance.
- Add a focused unit test with a couple of toy `(ℓw, ℓr)` cases where
  `log_odds` and the loss are computed by hand, guarding the `log1mexp`
  stability path.

**Oracle ladder for the optimized path.** With no upstream ORPO to port, each
optimization tier is validated bit-exact (within bf16 tolerance) against the
tier below it, bottoming out at the math reference above:
- **naïve ORPO** = full-logits, two separate forwards, `orpoLoss` as specified
  → validated against the torch/numpy math reference.
- **chunked fused log-prob engine** (lever 1) → loss *and* `∇A`/`∇B` vs the
  naïve full-logits forward.
- **segmented / intra-layer split** (lever 4) → grads vs the unsegmented path
  (the existing SFT segmented backward already holds to ~0.00% / bf16-class;
  same harness).
- **shared prefix** (lever 7) → vs the two-sequence forward (the published
  method is numerically identical; the prefix just accumulates both cotangents).

## Memory & speed optimization

ORPO has no upstream bit-exact oracle (L3 original), which gives us latitude to
optimize the runtime aggressively as long as we stay self-consistent with a
naïve reference (see [Parity](#parity)). This section is the result of a
dedicated research spike across three areas — activation/segmentation memory,
large-vocab loss memory, and preference-training structure — ranked for *our*
constraints: MLX, Apple-Silicon **unified memory** (~24 GB), LoRA-only, B=1,
long context, two prefix-sharing branches, 262k vocab.

### What dominates, and the one principle that orders everything

At long context two terms dominate, and **neither is the LoRA grads** (those are
tiny): (1) the LM-head logits `[1, T, 262k]` and their gradient — ~4.3/8.6 GB at
T=8192, bf16 — and (2) the per-layer activations held for the backward. ORPO
forwards *two* responses, so the logit term is effectively doubled vs SFT.

The ordering principle, specific to unified memory: **only reducing total live
footprint moves the 24 GB constraint — relocation does not.** On a discrete GPU,
offloading activations to host DRAM over PCIe is a real second lever (Unsloth's
offloaded checkpointing, ZeRO-Infinity). On Apple Silicon the CPU and GPU share
one physical pool ([MLX unified memory](https://ml-explore.github.io/mlx/build/html/usage/unified_memory.html)),
so "offload to CPU" frees **zero** bytes, risks double-residency (raising peak),
and burns the ~273 GB/s bandwidth that is the actually-scarce resource. **We do
not implement activation offloading.**

### Ranked levers (with our-setup verdicts)

**1. Chunked / fused log-prob engine — build first, biggest unconditional win.**
CE and the per-token target log-prob ORPO needs are the *same* quantity:
`logp_t = (h_t·W_{y_t}) − logsumexp_v(h_t·W_v)`, `ce_t = −logp_t`. So one
memory-efficient engine serves both the SFT-NLL term and the odds-ratio
log-probs. The trick (Liger `FusedLinearCrossEntropy`, Apple
[Cut Cross-Entropy](https://arxiv.org/abs/2411.09009)): tile the vocab
projection, combine partial `logsumexp`s with the
[online-softmax](https://arxiv.org/abs/1805.02867) recurrence, gather the target
logit — so the full `[T, V]` logits never materialize, and the backward
reconstructs `softmax − onehot` from a saved per-token LSE scalar (O(T) stored,
not O(T·V)). CCE reports loss memory **24 GB → ~1 MB**, head-training **28 → ~1
GB** at this vocab scale. This **subsumes our current `responseOnlyCe` trick**
(which only shrinks the logits to the response span) and generalizes it.
  - *MLX reality:* nothing fused/chunked exists in the MLX ecosystem today —
    this is new work. Build it in **pure MLX** as a Liger-style **chunked**
    log-prob (matmul + `logsumexp` + `takeAlongAxis` per chunk, driven by an
    `mx.vjp` per chunk — *not* a surrogate `value_and_grad`, per our
    [segmented-backward leak lesson](segmented-backward-training.md)). Pass
    `(hidden, baseW, loraA, loraB, targets)` as **explicit** VJP args so the
    LoRA-factored head backward (`∇A`, `∇B`) falls out per chunk — Apple's CCE
    has no LoRA path, so even adopting it would mean deriving this ourselves.
    Exact in forward and backward; no Metal kernel required. Reserve a
    `mx.fast.metal_kernel` flash-CCE as an **L3 speed tier** only if per-chunk
    logits are still too large in practice.

> ✅ **LANDED + validated (2026-06-18) — `fusedLogpMeanB1` in
> [`loss.ts`](../../src/train/loss.ts), gated by `orpo_fused_ce`.** A single
> `CustomVjp` (Liger `FusedLinearCrossEntropy` structure ported to MLX): forward
> token-chunks the response, materializes only `[chunk,V]` logits per chunk (=
> `quantizedMatmul(h_c, W, …, transpose=true)` + Gemma `logitSoftcap`), reduces to
> `logp = target_logit − logsumexp`, drops the logits; the **analytic** backward
> recomputes per chunk and forms `cotangent·(onehot − softmax)·sech²` directly
> (no autograd through logsumexp+gather), then `dh_c =
> quantizedMatmul(grad, W, …, transpose=false)` — mlx's own x-vjp of the
> transpose=true head (contracts vocab without dequantizing the 1.3 GB head).
> **Validated** ([`scripts/experiments/fused-ce-parity.ts`](../../scripts/experiments/fused-ce-parity.ts)
> + gated [`tests/train-orpo-fused-ce.test.ts`](../../tests/train-orpo-fused-ce.test.ts)):
> value **BIT-EXACT** vs the full-logits `branchLogpMeanB1` on BOTH MiniCPM5 (no
> softcap) and e4b (softcap=30 — matched by reusing `logitSoftcap`'s exact
> `div`-by-bf16-cap formula); LoRA grads in the bf16 class (**0.51%** MiniCPM5 /
> **1.97%** e4b, the documented scale=1.0 band); peak `[chunk,V]`-bounded both
> directions (MiniCPM5 M=2048: 13.32 → 12.80 GB, the win grows with M·V). Wired
> through `ChunkCtx.fused` → `branchLogpMean` (B=1, non-segmented; Gemma + CPM5
> heads); `orpo_fused_ce` reuses `orpo_chunk_size` as the token-chunk (default
> 512). Head is not a LoRA target so only `dh` flows back (head-LoRA `∇A/∇B` fold
> + vocab-blocked online-softmax CCE tier are the remaining follow-ons). The spec
> that guided it is below.
>
> ⚠️ **Segmented integration — investigated; head is NOT the segmented bottleneck
> (2026-06-18).** Wired a bounded head into `SegmentedBackwardOrpo` /
> `SegmentedBackwardOrpoGemma4` (constructor `fusedChunkSize`, gated by
> `orpo_fused_ce`; `boundedHeadFromHidden` in `segmented.ts`). Two findings:
> (1) the **analytic fused `CustomVjp` does NOT bound memory when nested inside the
> segmented `mlx_vjp` head** — its per-chunk `[chunk,V]` graph is not freed
> incrementally there (it IS at the top level, where peak scales with chunk size),
> so it *raised* peak, growing with M (+0.8 GB @L=3072, +1.1 GB @L=4096 on
> MiniCPM5). So the segmented bounded head uses the **Checkpoint recompute** variant
> (`chunkedLogpMeanFromHidden`) instead — bit-exact (0.00% grads, pure recompute),
> never increases peak. (2) But **bounding the head does not reduce the segmented
> peak at any reachable scale** — verified full-vs-bounded head identical peak on
> MiniCPM5 (130k vocab) L=2048/3072/4096 × SEG=2/6 AND e4b (262k vocab) L=2048
> (11.95 GB both). The per-segment backward recompute + the saved forward
> boundaries are the binding constraint; the head `[M,V]` is transient (computed in
> the head phase, freed before the segment-backward peak), so it never stacks with
> the peak. **Conclusion:** segmentation already removes the layer pressure, and at
> these scales the head was never the stacking term — so fused-CE-in-segmented is
> NOT a peak win (the cumulative-pressure hypothesis doesn't bind here). The
> Checkpoint bounded head is retained as a bit-exact, zero-cost safety for the
> extreme vocab×M regime (head would only bind well past what fits) and as the hook
> for a future Metal CCE kernel. Default segmented path (`orpo_fused_ce` off) is
> unchanged — full `responseOnlyLogpMean` head.
>
> ⚠️ **Vocab-blocked online-softmax (full CCE) — implemented + correct, but pure
> MLX can't bound its memory (2026-06-18).** `makeVocabBlockedHeadVjp` in
> `loss.ts` (reached via the `vocabBlock` param / experiment scripts) tiles the
> vocab into `vocabBlock`-wide blocks with the [online-softmax](https://arxiv.org/abs/1805.02867)
> running (max `m`, sumexp `d`) recurrence — the exact Cut Cross Entropy structure
> so `[chunk, V]` is never formed. **Numerically validated**
> ([`scripts/experiments/fused-ce-parity.ts`](../../scripts/experiments/fused-ce-parity.ts)
> `VBLOCK=…`): value bf16-class vs the whole-vocab head, grads **flat at ~0.46%
> across block sizes** (8192/2048/512) — once two precision fixes landed: the
> online `(m,d)` accumulation must be **f32** (bf16 across many blocks corrupts the
> exp-sensitive `lse`), and the **`dh` cross-block accumulation must be f32** (the
> dominant grad bug — bf16 summing hundreds of block-`dh`s gave 17%→45% error
> scaling with block count). **But it does NOT bound memory** — the head-isolated
> peak ([`scripts/experiments/fused-ce-headmem.ts`](../../scripts/experiments/fused-ce-headmem.ts),
> MiniCPM5 M=2048) goes the WRONG way: whole-vocab **3.4 GB → 14.1 GB at
> 512-wide blocks**, growing monotonically as blocks shrink. Root cause: the online
> softmax is a **sequentially-dependent chain** (`m`/`d` recurrence + the `dh`
> accumulation chain), and MLX's lazy eval **retains the whole chain** instead of
> freeing each `[chunk,Vblock]` incrementally — unlike the *independent*
> token-chunks (which free fine). Forcing an eval mid-chain breaks autodiff (a
> 35 GB blowup). **Conclusion:** the CCE residency bound (`[chunk,Vblock]` peak) is
> unreachable in pure MLX; it requires a `mx.fast.metal_kernel` with the vocab loop
> INSIDE the kernel (the L3 flash-CCE tier). The pure-MLX implementation is kept as
> a **validated correctness reference** for that kernel and is **gated off** (not
> wired to a trainer knob — it would only raise peak). So: token-chunking
> (`orpo_chunk_size`) + the analytic fused head (`orpo_fused_ce`) are the usable
> pure-MLX memory levers; vocab-blocked CCE is a Metal-kernel follow-on.
>
> 🔬 **flash-CCE Metal kernel — PROTOTYPED + working, scaling-limited at largest
> vocab (2026-06-18).** [`src/train/flash-cce.ts`](../../src/train/flash-cce.ts):
> `mx.fast.metal_kernel` forward (`logp` + `lse`) and backward (`dh`) that compute
> logits in-kernel from the quantized head (in-Metal 4/8-bit affine dequant via the
> qdot pattern from [`fused-decode-kernel.ts`](../../src/model/fused-decode-kernel.ts)),
> online softmax across vocab, target capture, softcap + sech², so the vocab loop
> lives INSIDE the kernel — neither `[M,V]` nor a dequantized `[V,hidden]` head
> touches HBM. **Validated** ([`scripts/experiments/flash-cce-parity.ts`](../../scripts/experiments/flash-cce-parity.ts)):
> forward `logp` bf16-class (~0.21%) vs the MLX whole-vocab head; backward `dh`
> ~bit-exact vs autograd (isolated 2e-4%; e4b M=512 0.40%); softcap correct on
> e4b. **Memory bound ACHIEVED** — peak ~flat in V: MiniCPM5 M=8192 forward
> reference **2.45 GB → kernel 0.34 GB**; e4b M=512 backward **2.06 → 1.17 GB**.
> **Scaling limit (v1):** one token = one threadgroup looping the WHOLE vocab
> serially. On e4b (262k vocab × 2560 hidden) each threadgroup runs ~3.3× longer
> than MiniCPM5 and **intermittently trips the GPU watchdog** at higher M (e4b ≤512
> solid; ≥1024 nondeterministic garbage — confirmed 89/95/100% across repeats; a
> timeout, not a logic bug — MiniCPM5 is solid to M=8192).
>
> ✅ **VOCAB-PARALLEL form LANDED — e4b now scales (2026-06-18).** Transpiled
> Apple CCE's `cce_lse_forward` / `cce_backward` grid: `grid=[TG, nVocabBlocks, M]`,
> each threadgroup handles a bounded `VOCAB_BLOCK`-row (8192) slice for one token,
> so no dispatch loops the whole vocab. **Forward** writes per-block partials
> (blockMax, blockΣexp, target logit) to `[M, NBLK]`, merged cross-block by cheap
> MLX ops (`gMax`/`Σexp(max−gMax)`/`lse`) — Apple uses a locked atomic logaddexp;
> the MLX merge is simpler, same result. **Backward** recomputes per (token,
> vocab-block) and **atomic-adds** its partial `dh` into the shared `[M,H]` output
> (`atomicOutputs` + `initValue 0`; NBLK-way contention per dim = Apple's locked
> atomic `dE` add — and we need only `dE`/`dh`, not `dC`, since the head is frozen).
> **Validated** ([`scripts/experiments/flash-cce-parity.ts`](../../scripts/experiments/flash-cce-parity.ts)):
> e4b M=1024 (NBLK=32) — watchdog GONE, deterministic, **logp 0.20% / dh 0.40%**
> (bf16-class), **bwd peak 3.41 → 1.46 GB**, fwd peak 1.27 → 0.82 GB; MiniCPM5
> unregressed. Dequant runs f32 in-kernel → arguably more accurate than the bf16
> MLX head.
>
> ✅ **SPEED — `BLOCK_B` token tiling landed (2026-06-18).** The v1 vocab-parallel
> kernel was correct + memory-bounded but ~1000× too slow (e4b M=512: fwd 5.1 s,
> bwd 16.8 s) — **ALU-bound on the scalar dequant** (71 GB/s effective ≪ 273
> peak), because one-token-per-threadgroup re-dequantizes the head M times.
> Transpiled Apple CCE's `BLOCK_B` token tiling: each thread dequantizes a vocab
> row ONCE and reuses it across BLOCK_B tokens. e4b M=512: **fwd 5.1→1.5 s (3.3×,
> BLOCK_B=8)**, **bwd 16.8→7.3 s (2.3×, BLOCK_B_BWD=4)**, total **2.5×**; grads +
> memory win unchanged (parity logp 0.20% / dh 0.40%, bwd peak 2.06→1.17 GB). Two
> findings: (a) past BLOCK_B≈8 the dequant is amortized and the SCALAR matmul
> dominates (BLOCK_B=16 ≈ BLOCK_B=8) → next tier **simdgroup_matrix**; (b) the
> backward is REGISTER-bound by `dacc[BLOCK_B·DPER]` (BLOCK_B=8 spills/faults;
> BLOCK_B_BWD=4 fits) → separate fwd/bwd tile widths. **Remaining:** simdgroup_matrix
> GEMM + D-tiling + CCE near-zero gradient filter (best case ≈ MLX matmul speed,
> same FLOPs); then `CustomVjp` wrap + `orpo_flash_ce` + trainer wiring.
>
> **Implementation spec — fused linear-CE log-prob head.** Concrete plan,
> grounded in the code. The head is `embed.asLinear(h)` =
> `quantizedMatmul(h, w, scales, biases, spec, /*transpose*/true)` for tied models
> (Gemma/CPM5-tied) or `lmHead` (`QuantizedLinear`) for untied; a **vocab chunk is
> an axis-0 row-slice** of `w`/`scales`/`biases` (the quant `spec` is one per head)
> fed to `quantizedMatmul` per chunk. **Gemma applies `final_logit_softcapping`
> (e4b = 30.0): `logit = cap·tanh(raw/cap)`** — must be folded into BOTH the
> online-LSE and the backward (`d logit/d raw = sech²(raw/cap) = 1 − tanh²(raw/cap)`);
> CPM5 has no softcap.
>
> - **New fn `fusedLogpMeanB1(model, ids, mask, validLen, vocabChunk)` → [1]** in
>   [`loss.ts`](../../src/train/loss.ts), selected by a new `orpo_vocab_chunk`
>   knob (the existing `orpo_chunk_size` stays the token-axis tier; the two
>   compose — token-chunk the M response rows, vocab-chunk each row's head). It
>   replaces the per-chunk `logitsFromHidden` (which materializes `[Cc, V]`) with
>   the tiled engine below, wrapped in a single `CustomVjp` (our
>   [`fused-geglu-kernel.ts`](../../src/model/fused-geglu-kernel.ts) pattern: a
>   `mx.custom_function` with a hand `.vjp`, validated against `mx.vjp`/autograd —
>   never a hand formula, per the standing rule).
> - **Explicit VJP inputs** `(hC [M,hidden], baseW, scales, biases, [loraA, loraB
>   if the head is a LoRA target], targets [M])`; output = per-token `logp [M]`
>   (or the summed scalar). The head is NOT a default LoRA target today
>   (`DEFAULT_TARGET_MODULES` is attn/MLP), so v1 can treat the head as **frozen**
>   (only `dh` flows back) and skip `∇A_head`/`∇B_head` — add the LoRA-head path
>   only when the head becomes a target. `dh` is what seeds the layer-stack LoRA
>   backward, so the frozen-head path already delivers the memory win.
> - **Forward (online-softmax over vocab tiles), per token-row block:** init
>   `m = −inf [M]`, `s = 0 [M]`, `tgtLogit = 0 [M]`. For each vocab chunk `[v0,v1)`:
>   `raw = quantizedMatmul(hC, w[v0:v1], scales[v0:v1], biases?[v0:v1], spec, true)`
>   `[M, Cv]`; apply softcap if set; `mNew = max(m, max_v raw)`;
>   `s = s·exp(m−mNew) + Σ_v exp(raw−mNew)`; `m = mNew`; where the target index
>   falls in `[v0,v1)`, capture `tgtLogit`. After all chunks: `lse = m + log(s)`,
>   `logp = tgtLogit − lse [M]`. **Store only `(m or lse, s, tgtLogit, targets)` —
>   O(M), never `[M,V]`.**
> - **Backward (recompute vocab tiles from the saved LSE):** upstream cotangent
>   `g [M]` (= `∂loss/∂logp_t`). For each vocab chunk recompute `raw`, apply
>   softcap, `softmax_v = exp(softcap(raw) − lse)`; the per-logit cotangent is
>   `g·(onehot_target − softmax)` (× `sech²` if softcap). Accumulate
>   `dh += (that)·W_chunk` (through the quantized matmul's `x`-vjp, which MLX has)
>   and, if head-LoRA, `∇A/∇B` via the factoring. **Never forms `[M,V]`.** Validate
>   the `.vjp` against `mx.vjp` over `logitsFromHidden`+gather on a small vocab.
> - **ORPO-grad folding (later micro-opt):** ORPO needs `logp` then reduces via
>   `orpoLossFromLogps`; with `logp` exposed as the `CustomVjp` output, autograd
>   composes the odds-ratio grad outside the head kernel (correct, simplest).
>   Folding `∂L_OR/∂logp` *inside* the kernel (Tier-1 fusion #3) is a speed-only
>   refinement once the exact engine lands.
> - **Oracle ladder (per [Parity](#parity)):** `fusedLogpMeanB1` loss + `∇`(LoRA)
>   vs the naïve full-logits `branchLogpMeanB1` (bf16-exact); then vs the
>   token-chunked `chunkedLogpMeanB1` (same class). New gated test
>   `tests/train-orpo-fused-ce.test.ts` mirroring `train-orpo-chunked.test.ts`;
>   bench row in [`bench-orpo.ts`](../../scripts/bench-orpo.ts) (peak at 262k vocab).
>   **Note:** at 262k a single row `[1,262k]` bf16 ≈ 0.5 MB, so the token-chunked
>   head ALREADY bounds memory to `[chunkSize, 262k]`; the fused engine's win is
>   (a) eliminating the `[chunk,V]` forward+backward materialization entirely and
>   (b) the head-LoRA + ORPO-grad fusion — the moat (no MLX preference trainer
>   has it), not a raw 24 GB→1 MB cliff at our vocab.

**2. Reference-free structure — already ours; keep it, and don't regress it.**
ORPO is **2 forwards/step** (chosen + rejected, both with grad) vs DPO's **4**
(2 reference + 2 policy). That is the single biggest reason ORPO fits 24 GB.
The chosen forward feeds **both** the NLL term and the chosen log-prob; the
rejected forward contributes only its scalar log-prob — never forward chosen
twice, never compute a rejected NLL.

**3. Two unpadded sequential forwards — NOT a padded concatenated forward.**
TRL's `concatenated_forward` pads chosen+rejected to a shared max and runs one
batch-of-2; its own docstring says this is to amortize **FSDP** all-gathers —
which we don't have. On single-device bandwidth-bound unified memory the padding
is pure waste, and we must retain both branches' activations for the backward
either way. So our two B=1 forwards (chosen, then rejected) are the *right*
shape, not a limitation.

**4. Segmented backward + intra-layer (attn/MLP) split — the per-layer AND
intra-layer ask.** Wire the preference path into the existing
[`SegmentedBackward`](../../src/train/segmented.ts) (currently SFT B=1 only),
then go finer. The residual-stream hidden `h` *between* the attention add and
the MLP add is a **graph min-cut of width one** `[1, T, d]` — the same kind of
object we already detach at segment edges. Detach `h`, run the **MLP sub-block**
VJP to get `dL/dh`, seed that into the **attention sub-block** VJP. Peak per unit
drops from `attn + MLP` to `max(attn, MLP) + h`.
  - *The non-obvious part, specific to us:* because we train through `ops.sdpa`
    (MLX's fused flash kernel), the O(T²) attention scores are **never
    materialized** — so the **MLP intermediate** (SwiGLU/GeGLU gate+up at
    `d_ff`) is the dominant resident tensor, the *reverse* of the
    materialized-scores textbook case. So the high-value isolation is the **MLP
    sub-block**, not attention. This nests strictly inside the current reverse
    VJP loop (a segment of N blocks → 2N sub-VJP units), same detach-leaf
    discipline, same e4b donor-KV threading (which lives entirely in the
    attention sub-block). Refs: Megatron
    [selective recomputation](https://arxiv.org/abs/2205.05198),
    [Checkmate](https://arxiv.org/abs/1910.02653).
  - ✅ **LANDED on the gradient-checkpoint path** (`config.mlpSplit`, Gemma4 only,
    needs `gradCheckpoint` on). `DecoderLayer.forward` is refactored into
    `forwardAttn` (inputNorm → attn → residual add, threading donor K/V) and
    `forwardMlp` (FFN + per-layer gate); `runSplitCheckpointedLayer` wraps each in
    its own `Checkpoint` with the post-attn residual `hMid` as the boundary. The
    trainer partitions each layer's LoRA into attn (`self_attn.*`) and MLP
    sub-blocks. **Validated bit-exact** on real e4b
    ([`scripts/experiments/mlp-split-checkpoint-e4b.ts`](../../scripts/experiments/mlp-split-checkpoint-e4b.ts)):
    split grads == single-checkpoint grads == no-checkpoint grads to **0.000000%
    / maxAbs 0.0** (it is pure recompute), and the fused-GeGLU `CustomVjp` nests
    cleanly inside the `Checkpoint`. **Honest peak finding:** on the *per-layer*
    checkpoint path the marginal win is small — L=2048 no-ckpt **28.60 GB** →
    single **23.40 GB** → split **23.35 GB** (the single checkpoint already
    serializes layers, so the split only saves ~one layer's attn-sized
    activations during its recompute window; under `ops.sdpa` the MLP, not attn,
    dominates, so `max(attn,MLP) ≈ MLP`). The split's value grows with coarser
    checkpoint units / inside the segmented backward; the bigger *MLP* memory
    lever at long context is lever 5 (sequence-chunk), still the documented
    follow-on. Off by default (numerically identical, a finer memory↔compute
    knob).

**5. Sequence-chunk the MLP sub-block — finer still, free, add only if needed.**
The MLP and projections are **per-token independent**, so the `[1, T, d]`
boundary can be split into row-chunks and the MLP run one chunk at a time,
dropping its resident intermediate from `O(T·d_ff)` to `O(chunk·d_ff)` at
~zero recompute. A third nesting axis (depth-segment → block → attn/MLP →
seq-chunk-of-MLP) that stacks multiplicatively. Add only if the MLP term is
still binding at 8K after lever 4. (Attention can't be token-chunked naïvely —
it's all-to-all — but `ops.sdpa` already handles it;
[Blockwise/Ring](https://arxiv.org/abs/2305.19370) is the general form.)

**6. Rotor-style segment planning — replace `planSegmentsBySize`.** The √n rule
([Chen 2016](https://arxiv.org/abs/1604.06174)) says ~√(nLayers) segments
minimize peak at ~1× recompute (≈6 segments for e4b's 42 layers — matches its
natural `sssssF` period). For our *heterogeneous* stack (full vs sliding layers,
mixed quant, and eventually sub-blocks) the right tool is a **rotor DP**
([Beaumont 2019](https://arxiv.org/abs/1911.13214)): given a peak-memory budget
it emits the recompute-minimizing split points, isolating the O(T²) full-
attention layers automatically instead of hand-tuning `segment_size`.

**7. Shared prompt-prefix — a gated, genuinely novel differentiator.** Chosen
and rejected share an identical prompt prefix; the causal mask guarantees the
prefix's hidden states/KV are independent of which response follows. So compute
the **prompt once** and reuse it for both response continuations — token cost
`2(P+R) → P + 2R`. This is published for DPO
([Wang & Hegde, "Accelerating DPO with Prefix Sharing"](https://arxiv.org/abs/2410.20305))
but **no mainstream trainer does training-time prefix sharing** (TRL's concat
encodes the prompt twice) — real differentiator territory. Backprop is sound:
the prefix is one node with two consumers, so reverse-mode AD just **sums the
two branches' cotangents** into `∂L/∂prefix` — falls out of our VJP machinery,
and it saves the prefix *backward* too.
  - *Verdict — gate on P/R.* Speedup → 2× as prompt ≫ response, → ~0 as prompt
    ≪ response (measured 1.17–1.57× depending on data). Our chunk/document
    fine-tunes are prompt-heavy → a real 1.3–1.5× win; short-prompt/long-answer
    pairs get ~nothing. Implementation is **high** complexity (needs a
    block-sparse mask or, the natural fit for our KV-cache machinery,
    **prefix-KV-once + a per-response attention pass** reading the shared prefix
    K/V, with RoPE position-ids reset to `prompt_len` for each response). Build
    it **after** lever 1, behind a flag that activates above a P/R threshold.
  - ✅ **MiniCPM5 reference BUILT + validated (2026-06-18).**
    [`src/train/prefix-shared.ts`](../../src/train/prefix-shared.ts):
    `orpoLossPrefixShared` runs ONE forward over the concat
    `[prompt(P); chosenResp(Rc); rejectedResp(Rr)]` with (a) a **block-sparse
    mask** (`blockSparseMask`: causal AND NOT rejected→chosen) carried via a
    `PrefixSharedCache`, and (b) **block-wise RoPE** that resets each response to
    offset `P` (`ropeBlocks` + `setMiniCpmPrefixPlan` in
    [`minicpm5.ts`](../../src/model/minicpm5.ts)); the head gathers
    `chosen[k]←H[P-1+k]`, `rejected[0]←H[P-1]` (shared prompt-last),
    `rejected[k≥1]←H[P+Rc+k-1]`. `splitPrefixBatch` detects an identical-prompt
    B=1 row and falls back to the two-forward `orpoLoss` otherwise.
    **Validated** ([`scripts/experiments/prefix-shared-parity.ts`](../../scripts/experiments/prefix-shared-parity.ts),
    P=512/Rc=64/Rr=80): the **FORWARD is BIT-EXACT** vs the two-forward path
    (`rel=0.00e+0%`) — the construction proof; ℓw/ℓr are identical. **Grads agree
    to ~1.05% (bf16 grad class, < 2%)** — NOT ULP-exact, and confirmed at λ=0
    (where the two-consumer prefix-cotangent sum is inert yet the ~1% gap holds),
    so the residual is **f32-over-bf16 reassociation** in the LoRA grad matmuls
    reducing over the merged length `T` vs `P+Rc`/`P+Rr` separately — the same
    band the e4b segmented ORPO path shows, not a construction error. **Token
    saving 1.78×** (two-forward 1166 → shared 656 token-passes) and **peak
    5.40 → 3.80 GB**. **Not yet wired into `orpoLoop`** — it's the standalone
    reference + correctness gate; trainer wiring (a P/R-gated `orpo_*` flag) and
    the e4b port (sliding-window mask interaction + donor-KV + per-layer-input)
    are the follow-ons.

**Explicitly dropped / deferred:** activation offloading (no-op on unified
memory — §principle); TRL padded concatenated forward (FSDP-motivated padding
tax — lever 3); sequence packing and length-grouped batching (SFT-only wins,
near-moot at B=1 — revisit if we add grad accumulation).

### Build order for the optimized path

1. **Chunked fused log-prob engine** (lever 1) — replaces `responseOnlyCe` /
   full-logits `branchLogp` for both the NLL and odds-ratio terms. Biggest win,
   unconditional, exact.
2. **Two unpadded forwards** (lever 3) + keep reference-free (lever 2).
3. **Preference path into `SegmentedBackward`** then the **intra-layer MLP
   split** (lever 4); **rotor planner** (lever 6) to choose the cuts.
4. **Seq-chunk the MLP sub-block** (lever 5) if still binding at 8K.
5. **Shared prefix** (lever 7), flagged + P/R-gated, validated bit-exact against
   the two-sequence forward.

> Sourcing caveats from the spike to re-verify before quoting in user docs:
> SimPO's "~10% memory / ~20% faster vs DPO" and the packing "2×" figures are
> paper-reported on other setups; the Griewank 1992 page cite needs a primary
> check (Algorithm 799 / 2000 is solid). None affect the design — only external
> numbers we might cite.

## Kernel fusion — the flat-DAG payoff

The reason to generate a loop-unrolled, branch-deleted forward isn't just
readability: with no Python loop or `instanceof`/conditional control flow, the
whole forward (and its differentiated backward) is a **single straight-line
dataflow DAG**. That unlocks two things — (a) `mx.compile` can form one large
fusion region over it, and (b) static pattern-matching can swap hot subgraphs
for custom fused Metal kernels. Both apply to **forward and backward**.

### Verified MLX facts (source line refs from `main`; re-grep against the pinned 0.31.2 before relying)

- **`mx.compile` fuses the autodiff graph, not just the forward** — but
  narrowly. It fuses **contiguous chains of elementwise unary/binary ops** into
  one Metal kernel (the canonical `gelu` example: ~5× on M1 Max) and "merges
  common work" (dedups duplicate subgraphs); fusion **boundaries** are the
  non-elementwise nodes — matmul, SDPA, reductions (softmax/`logsumexp`),
  reshape/transpose. So it fuses the **norm/RoPE/residual/LoRA-add/activation
  glue between matmuls**, both directions. Control flow executes at *trace* time
  (loops unroll, branches resolve), so a straight-line unrolled DAG has **no
  control-flow fusion barrier left** and the longest possible elementwise
  chains — that is exactly why unrolling helps the fuser.
  - **Implementation rule:** compile the **outermost** transformed function —
    `mx.compile(value_and_grad(...))`, or the documented
    `@partial(mx.compile, inputs=state, outputs=state)` step that fuses
    fwd+bwd+optimizer into one graph — or the backward lands *outside* the fused
    region. `shapeless=True` avoids recompiles across seq-len (but not ndim/dtype
    changes, and shape-conditional graphs break under it).
- **`mx.fast` ships fused fwd+bwd VJP kernels for `rms_norm`, `layer_norm`,
  `rope`** (`RMSNormVJP` / `LayerNormVJP`; `RoPE::vjp` cleverly re-runs the same
  kernel inverted — zero extra kernel). **Use these; don't hand-roll them.**
- **SDPA is the exception, and it matters:** the forward is fused, but the
  **backward is NYI on Metal** — `ScaledDotProductAttentionVJP::use_fallback()`
  returns true unconditionally and `eval_gpu` throws, so MLX **decomposes** the
  SDPA backward into matmul→softmax→matmul and **materializes the L×L attention
  matrix** (the fused backward exists only for CUDA/cuDNN). This is precisely why
  our `ops.sdpa` training path has **O(L²) backward memory** (see
  [training.md](../reference/training.md)) and why segmentation is doing the
  compensating. → A **fused FA2-style SDPA backward** (store only the per-row
  `logsumexp` `L`; recompute `S=QKᵀ`, `P=exp(S−L)` in the backward) is therefore
  a genuine, high-value custom-kernel target, not a free win.
- **Not covered by `mx.fast`** (need custom kernels): SDPA backward (above),
  GeGLU/SwiGLU, cross-entropy / log-softmax+gather, the LoRA epilogue.
- **`mx.fast.metal_kernel` wrapped in `mx.custom_function` with a `.vjp` is
  fully differentiable** (verified) — the mechanism for every custom fused
  fwd+bwd kernel below. Validate each `.vjp` against `mx.vjp`/autograd, never a
  hand-derived formula (our standing rule).

### Ranked fusion opportunities

**Tier 0 — free, do first (table-stakes):**
1. **Compile the outermost unrolled forward+grad.** One `mx.compile` region over
   the straight-line DAG fuses the norm/RoPE/residual/LoRA-add/activation glue
   and the matching backward, and merges duplicate work. The unrolling is what
   makes the region large; compiling the outermost `value_and_grad` is what puts
   the backward inside it.
2. **Route training through `mx.fast.rms_norm` / `layer_norm` / `rope`** —
   already fused both directions. (Note: `sdpa` forward only — its backward is
   the custom-kernel target in Tier 1.)

**Tier 1 — custom fused fwd+bwd Metal kernels (the cutting-edge; L3 originals):**
3. **Fused linear + log-softmax + gather loss (CCE/Liger-style) — THE moat.**
   Lever 1 of the memory plan as a single kernel: fuse the (quantized,
   vocab-chunked) head matmul + `logsumexp` + target gather so the `[T, 262k]`
   logits never touch memory; the backward reconstructs `softmax − onehot` from a
   saved per-token LSE (Liger writes the grad in-place; CCE skips near-zero
   softmax elements). Returns the per-token log-prob ORPO needs — **and the
   ORPO odds-ratio gradient must be folded into this kernel**, since the grad is
   produced inside the forward, not via autograd over materialized logits.
   **No MLX project has this** (see landscape) — biggest differentiator.
4. **Fused SDPA backward (FA2-style).** Fills the Metal NYI gap above: store the
   per-row `logsumexp` `L` in the forward, recompute `S=QKᵀ` / `P=exp(S−L)` in
   the backward (5 matmuls, no stored L×L matrix) → O(L) attention-backward
   memory instead of today's O(L²). High value because it removes the term
   segmentation is currently compensating for. (FA3's extra tricks are
   Hopper-specific; mirror FA2 on Metal.)
5. **Fused GeGLU/SwiGLU with a vjp.** We already have a fused-GeGLU *forward*
   kernel ([`fused-geglu-kernel.ts`](../../src/model/fused-geglu-kernel.ts))
   **disabled in training because it has no gradient** (the
   `MLX_BUN_FUSED_GELU=0` constraint). The backward math is known (Liger): for
   `c = act(a)⊙b`, save `a`,`b`, recompute the activation — `db = dc·act(a)`,
   `da = dc·b·act'(a)`. Writing this `.vjp` re-enables the kernel in training —
   doubly valuable since the MLP intermediate is our **dominant resident tensor**
   (the intra-layer split target, lever 4).
6. **Fused dequant-GEMM + LoRA epilogue (+ manual backward).** MLX's
   `quantized_matmul` already fuses dequant into the *base* GEMM; the missing
   piece is folding the LoRA epilogue `scale·(x@A)@B` into that kernel and a
   hand-derived fused backward — `h=x@A`; `dB=s·hᵀ@dy`; `dA=s·xᵀ@(dy@Bᵀ)`;
   `dx=dy@Wᵀ + s·(dy@Bᵀ)@Aᵀ` (Unsloth's `matmul_lora` is the blueprint; rank
   r≪d so `h` is cheap to recompute). MLX's stock LoRA is **three separate ops**
   + generic autograd — no fused path exists in the ecosystem.

**Tier 2 — DAG-level passes the flat graph enables:**
7. **Recompute↔backward fusion** in the segmented path: the recompute-forward
   and its per-segment vjp share one compiled fused region (the reason to do
   this in a compiler vs eager `mlx_vjp`). Plus the classic passes over the
   static DAG — TVM-style anchor pattern-fusion (matmul/SDPA absorbs an
   elementwise epilogue; two anchors never chain), Inductor-style vertical +
   horizontal fusion (fuse QKV projections, share one RoPE angle), an
   XLA-style don't-duplicate-expensive-ops guard, and cross-layer CSE/global
   value numbering (the unrolled N-layer graph repeats RoPE tables, masks,
   scale constants).
8. **Min-cut rematerialization for segment boundaries.** AOTAutograd's
   `min_cut_rematerialization_partition` is the directly-portable algorithm:
   build a flow network (internal edge capacity = tensor byte-size), bias toward
   recomputing fusion-friendly ops, and `min_cut` picks save-vs-recompute — a
   formal replacement for hand-chosen `segment_size` that *is* fusion-aware.
   [Checkmate](https://arxiv.org/abs/1910.02653)'s MILP is the exact-budget
   upgrade when we must hit the 24 GB ceiling precisely.

### Competitive landscape (why this is a flagship)

An ecosystem survey found **no MLX preference trainer fuses or chunks the
loss** — every one (`mlx-lm-lora`, `optiq`'s `dpo.py`, `mlx-tune`, SiLLM, the
`mlx-examples` DPO gist) materializes the full `[B, T, V]` logits and calls
stock `log_softmax`/`cross_entropy`. CCE and Liger are Triton/CUDA-only with **no
Metal path**. Two openings stand out:

- **Correctness:** the current MLX SOTA, `mlx-lm-lora`, ships a **non-canonical
  ORPO** — it uses `log_sigmoid(chosen_logp − rejected_logp)` and **omits the
  additive SFT-NLL term** ORPO requires. Our paper-faithful loss (true log-odds
  + λ·NLL, length-normalized) is *already* more correct than anything shipping.
  **Do not copy their loss.**
- **Efficiency:** a **Metal fused/chunked CE + fused LoRA** would be the first
  fused preference loss in the MLX world, on a quantized base, with grad
  checkpointing / segmented backward. Other gaps nobody fills: cached DPO
  reference log-probs, a concatenated/prefix-shared chosen+rejected forward.

These fused kernels are **L3 originals** (mlx-bun's own tier) — validated
against the naïve path via the [oracle ladder](#parity), consistent with the
three-level fidelity model.

## Model coverage, quantization, batching, dropout

Four cross-cutting requirements, each grounded in what the code already does.

### Mixed-precision quantized base

**Already handled in the layer stack — ORPO inherits it free.** Each
[`QuantizedLinear`](../../src/model/gemma4-base.ts) carries its **own**
`QuantSpec` (bits, group size) from `quantFor(config.quantization, path)`, and
its `forward` is `quantizedMatmul(x, w, scales, biases, spec)` + the f32 LoRA
residual. mlx's `quantized_matmul` has a working vjp **w.r.t. `x`** (the entire
project trains LoRA on a 4-bit base today), and the base weights are frozen
(grads flow only through the f32 A/B). "Mixed precision" just means a different
`spec` per call — nothing special on the layer-stack backward.

Two things ORPO must get right for mixed precision:

1. **Vocab-chunked head over a quantized, possibly-mixed head.** The fused
   log-prob engine (lever 1) tiles the LM head along the vocab axis. The head is
   quantized in every model — tied `QuantizedEmbedding.asLinear`
   (Gemma, tied Qwen) or a separate `QuantizedLinear` `lmHead` (MiniCPM5,
   untied Qwen) — so a vocab chunk is a **row-slice of the quantized
   `w`/`scales`/`biases`** fed to `quantizedMatmul` per chunk. One spec covers
   the whole head, so chunking is a clean slice; this is the only quant-aware
   piece of new code.
2. **Wire the `bitsMap` so `by_bits`/`by_kl` actually fire. ✅ DONE.** This is
   optiq's mixed-precision mechanism, confirmed from its source: a calibration
   **sensitivity pass** measures each layer's KL divergence when quantized
   (`optiq/core/sensitivity.py`), the most-sensitive layers are kept at 8-bit,
   and **the same KL signal also sets the LoRA rank** — `by_bits`:
   `rank·(bits/4)` (4-bit→r8, 8-bit→r16), `by_kl`: `rank·clip(kl/median,0.5,2)`.
   optiq's words: *"the same layers kept at 8-bit also get more adapter rank —
   one signal, two optimizations."* It is **rank scaling, not LR/loss/gradient
   weighting** — "more signal to the 8-bit layers" = more adapter capacity
   there. Our [`rank.ts`](../../src/train/rank.ts) was already a faithful port of
   optiq's `sensitivity_rank.py`, but the trainer never supplied the maps, so it
   silently went uniform. Fixed: `bitsMapFromModel` reads each target's
   `linear.spec.bits` (authoritative, always present), `readPerLayerKl` reads
   `optiq_metadata.json` for `by_kl`; the trainer builds both and passes them to
   `resolveRanks`, and emits the resulting rank spread. Benefits SFT/DPO too;
   ORPO inherits it. (Unit-tested weight-free in
   [`tests/train-rank.test.ts`](../../tests/train-rank.test.ts).)

### Per-model specialized loops vs the monolith

**Preference: a per-model loop-unrolled, branch-deleted training path, with a
monolithic fallback** — and the codebase already has this exact pattern for the
forward path. [`scripts/gen-model.ts`](../../scripts/gen-model.ts) generates
specialized files in [`src/model/generated/`](../../src/model/generated/)
(`gemma4-12b/e4b/26b`) that unroll the per-layer loop, bake per-layer constants
(cache index, sliding/full window, **per-layer quant bits/group size**), and
delete `instanceof`/conditional branches; [`factory.ts`](../../src/model/factory.ts)
dispatches `GENERATED.get(configFingerprint(config)) ?? Gemma4Model` — generated
if the fingerprint matches, **monolith otherwise**.

Plan, mirroring that structure for training:

- **Monolith first.** The generic `SegmentedBackward` (MiniCPM5) /
  `SegmentedBackwardGemma4` call stock `runLayerRange` — they cover Gemma + CPM5
  today. Qwen has no segmented backward yet (needs `SSMCache` + a gated-delta
  custom-kernel vjp), so **Qwen ORPO lands first on the full (un-segmented)
  monolithic backward**; segmented Qwen is a follow-on.
- **Then generate the specialized segment-forward** per model (Qwen / Gemma /
  CPM5) — the unrolled, branch-deleted function the per-segment vjp calls —
  emitted by extending `gen-model.ts`, fingerprint-dispatched, with the monolith
  as the miss fallback. Same proven mechanism, applied to the training segment
  forward instead of the decode forward. (The `mx.compile` flat-DAG path in
  [`compiled-decode.ts`](../../src/model/compiled-decode.ts) is the other
  specialization lever, for reference.)

All three target families exist: [`gemma4.ts`](../../src/model/gemma4.ts),
[`minicpm5.ts`](../../src/model/minicpm5.ts),
[`qwen3_5.ts`](../../src/model/qwen3_5.ts) (gated-delta hybrid).

### Batching

DPO batching already exists — [`iterateDpoBatches`](../../src/train/dataset.ts)
B>1 pads each branch to its own batch-max with response masks, and
[`forward.ts`](../../src/train/forward.ts) has the padding-aware `[B,1,L,L]`
batched attention mask. ORPO reuses all of it: the **chunked fused log-prob
engine tiles over the `(B · response-token)` axis**, so B>1 falls out, with the
length-normalization done per row.

The real constraint is the **regime matrix** — the memory-optimized paths
(segmented backward, response-only head) are **B=1 only** today:

| Regime | Path | Use when |
|---|---|---|
| **B>1 monolithic** | batched padded forward + chunked loss, no segmentation | short context, headroom for B rows |
| **B=1 segmented** | segmented/intra-layer backward, response-only/chunked head | long context (the memory-bound case) |

At long context the intended lever is **`grad_accumulation_steps`** (raise
effective batch with no extra peak) rather than true B>1. ✅ **Wired** (all three
loops, sft/dpo/orpo): the shared `accumulateStep` helper in
[`trainer.ts`](../../src/train/trainer.ts) runs `grad_accumulation_steps`
micro-batches per optimizer step and mean-accumulates their grads (each scaled by
`1/N`) before a single `opt.step`. Each micro-batch's grads (and the running
accumulator) are eval'd before the next micro-batch's forward builds, so only one
micro-batch's activations are ever live — **peak memory does not grow with `N`**
(measured ~1.02× at N=3 for both SFT and ORPO on MiniCPM5; composes with the
segmented and gradient-checkpoint paths). `N=1` is a byte-for-byte pass-through.
The accumulation math is proven deterministically in
[`tests/train-gradaccum.test.ts`](../../tests/train-gradaccum.test.ts) and
demonstrated end-to-end in
[`scripts/experiments/parity-gradaccum.ts`](../../scripts/experiments/parity-gradaccum.ts).
True batched segmented backward is a larger effort (pad-aware boundaries); not
required for a first landing.

### Dropout

**Currently a dangling stub:** the `/finetune` UI has an `f-dropout` field that
is sent in the submit payload, but it is **not** in `FinetuneSubmit` / the
trainer, and the saved config hardcodes `lora_dropout: 0.0`
([`lora-params.ts`](../../src/train/lora-params.ts)). Wire it:
`lora_dropout` → `FinetuneSubmit` → `TrainConfig` → a **training-only** dropout
on the LoRA input in the adapter forward (PEFT applies dropout to `x` before
`A`). Default `0.0`; Labonne's ORPO-LoRA uses `0.05`.

- **ORPO note:** TRL sets `disable_dropout=True` on the *base* model so
  chosen/rejected log-probs are deterministic — our quantized base has no
  dropout modules, so only the **LoRA-adapter dropout** is in play. Keep it.
- **Correctness constraint that must be flagged:** our segmented backward and
  gradient checkpointing **recompute the forward inside the vjp**. If dropout
  draws a fresh mask on the recompute, the gradient is **wrong**. So when
  dropout > 0, the dropout mask must be **deterministic per step** — draw an RNG
  key once per step and **replay the same key** in every recompute (forward and
  each per-segment vjp). Default `0.0` sidesteps this entirely; enabling dropout
  requires the key-replay plumbing. This also interacts with the
  chunked-loss recompute. Note it in the implementation.

## Experiment: before/after ORPO on Gemma e4b (IFEval)

The end-goal quality experiment — does ORPO *meaningfully improve* the model?
Train on **UltraFeedback** preference pairs, measure **IFEval**
(instruction-following) before vs after. IFEval is the primary metric because
its checks are **programmatically verifiable** — no LLM judge, fully
reproducible (AlpacaEval/MT-Bench would need a GPT-4-class judge; a follow-on).

Pieces built (all unit-tested, judge-free):
- [`src/eval/ifeval.ts`](../../src/eval/ifeval.ts) — verifiable-instruction
  scorer (keywords / length / format / case / start-end / punctuation; prompt-
  and instruction-level accuracy). [`tests/ifeval.test.ts`](../../tests/ifeval.test.ts).
- [`src/eval/ultrafeedback.ts`](../../src/eval/ultrafeedback.ts) +
  [`scripts/curate-ultrafeedback.ts`](../../scripts/curate-ultrafeedback.ts) —
  binarized UltraFeedback → `{prompt, chosen, rejected}` with length filtering.
  [`tests/ultrafeedback.test.ts`](../../tests/ultrafeedback.test.ts).
- [`scripts/run-ifeval.ts`](../../scripts/run-ifeval.ts) — generate + score, with
  or without an adapter (the before/after runner).
- [`scripts/bench-orpo.ts`](../../scripts/bench-orpo.ts) — track step time/peak.

Runbook (the generate/train steps are yours to run — they're long / download):
1. **Curate:** export `HuggingFaceH4/ultrafeedback_binarized` to JSONL, then
   `bun scripts/curate-ultrafeedback.ts uf.jsonl data/uf-pref 2048`.
2. **Baseline:** `MODEL=<e4b> bun scripts/run-ifeval.ts ifeval.jsonl` → record.
3. **Fit check:** `MODEL=<e4b> CHUNK=512 bun scripts/bench-orpo.ts` to confirm
   the config fits 24 GB (e4b's 262k vocab makes the chunked head matter).
4. **Train ORPO** (e4b is Gemma → set the no-vjp kernels off):
   `MLX_BUN_FUSED_GELU=0 MLX_BUN_PERF_KERNEL=0` + `method:"orpo"`,
   `learning_rate 1e-5`, `orpo_lambda 0.1`, `orpo_chunk_size 512`,
   `max_seq_length ~1024`, `rank 16`. ⚠️ Segmented backward for ORPO is
   **MiniCPM5-only** today (`SegmentedBackwardOrpoGemma4` is a follow-on), so
   e4b ORPO runs the non-segmented path — rely on the **chunked head** + a modest
   `max_seq_length` to fit; longer context needs the Gemma segmented port.
5. **After:** `MODEL=<e4b> bun scripts/run-ifeval.ts ifeval.jsonl --adapter <out>`
   → compare prompt/instruction accuracy to the baseline.

The curated set should bias toward instruction-following pairs so the IFEval
signal moves (UltraFeedback is broad; a topic/length filter focused on
formatting/constraint-following prompts sharpens the before/after delta).

**Prompt masking (verified):** the NLL / odds-ratio is computed on the
**completion only** — `respMask` zeroes the prompt and the loss sums only
`mask[t+1]==1` positions. This holds even for a huge prompt + tiny completion
(e.g. a 13 KB policy/transcript prompt + a ~100-char JSON answer): left-
truncation preserves the boundary (`promptLen = maxLen − completionLen`). The
*only* way the prompt leaks in is a completion that is itself ≥ `max_seq_length`
— `loadDpoDataset` warns loudly if that happens. Regression-tested in
[`tests/dpo-masking.test.ts`](../../tests/dpo-masking.test.ts).

**Small sets over-fit fast** (~450 pairs): keep `orpo_lambda` modest (default
`0.1`), carve a ~50-pair `valid.jsonl` (curate with `valFrac ≈ 0.1`), and watch
the **val margin** (mean chosen−rejected log-odds) — it's emitted per
`steps_per_eval` and persisted to `metrics.json` as `bestMargin` (a better
checkpoint signal than val loss). `save_checkpoints: true` keeps every eval
checkpoint so you can mount the best-margin one.

## Resolved decisions

- **LR / λ defaults** — `learning_rate=1e-5`, `orpo_lambda=0.1`, cosine
  schedule, warmup ≈3% of iters (see Recommended defaults). Revisit after a
  real run.
- **Schedule knobs** — **method-prefixed**: `orpo_*` for ORPO, `dpo_*` for DPO
  (no shared fields).
- **Format naming** — rename the `dpo` dataset format to `preference` with
  `dpo` kept as an alias, now that two methods consume it.
- **Mixed-precision quant** — inherited free in the layer stack (per-linear
  `QuantSpec` + working `quantized_matmul` vjp). New quant-aware code is limited
  to the vocab-chunked head. Also wire `bitsMap` from `linear.spec.bits` so
  `by_bits` rank scaling fires (fixes a known silent fallback; helps SFT/DPO).
- **Per-model paths** — monolith first (Gemma + CPM5 segmented; Qwen full
  backward), then generated per-model unrolled segment-forwards via
  `gen-model.ts`, fingerprint-dispatched with the monolith as fallback.
- **Batching** — reuse DPO batching; chunked loss makes B>1 fall out.
  Memory-optimized paths stay B=1; `grad_accumulation_steps` is the intended
  long-context lever but is **not yet consumed by any loop** (tracked follow-on).
  True batched segmented backward is a follow-on.
- **Dropout** — wire the existing UI stub through to a training-only LoRA-input
  dropout (default `0.0`). If > 0, the dropout key must be drawn per step and
  **replayed** in every recompute (segmented/checkpoint/chunked) or gradients
  diverge.
- **Regularization (open — small sweep)** — rank is the primary regularizer;
  adopt **rsLoRA** (`α/√r`) so `rank_scaling` regularizes capacity, not step
  size; consider **LoRA+** (higher LR for B, which does the early learning under
  zero-init); default **weight decay lower than SFT** (the SFT-NLL term already
  anchors); cosine + warmup. See [Regularization & optimizer geometry](#regularization--optimizer-geometry).
