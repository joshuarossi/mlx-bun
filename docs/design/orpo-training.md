---
status: landed
axis: USING
canonical-for: training
plan-anchor: "Phase: Steel flash-CCE ORPO head + full ORPO training stack"
last-verified: 2026-08-23
---

# Training — design (ORPO, flash-CCE head, prefix sharing, segmented backward)

The canonical design record for mlx-bun's LoRA trainer: the **ORPO** objective
(Hong et al. 2024) as a third `method` beside `sft`/`dpo`, and the long-context
machinery it runs on — the `[M,V]`-free **flash-CCE** head, the **prefix-shared**
two-branch forward, and the **segmented backward**. All of it is landed and
default-on in `scripts/train-orpo.ts` and `mlx-bun train`.

- Usage, flags, measured run tables: [training.md](../reference/training.md),
  [docs/reference/training.md](../reference/training.md).
- Build narratives (frozen): [steel-flash-cce-handoff.md](../archive/investigations/steel-flash-cce-handoff.md),
  [segmented-backward-handoff.md](../archive/investigations/segmented-backward-handoff.md),
  [orpo-flash-cce-pin-leak.md](../archive/investigations/orpo-flash-cce-pin-leak.md),
  [orpo-base-uf-experiment-and-directions.md](../archive/investigations/orpo-base-uf-experiment-and-directions.md),
  [orpo-uf-testing-handoff.md](../archive/investigations/orpo-uf-testing-handoff.md).
- Open training work is tracked in PLAN.md under the plan-anchor above; status
  prose lives there, not here.

Code: [`src/train/loss.ts`](../../src/train/loss.ts) (objective + heads),
[`trainer.ts`](../../src/train/trainer.ts) (loops, config), [`segmented.ts`](../../src/train/segmented.ts),
[`prefix-shared.ts`](../../src/train/prefix-shared.ts), [`flash-cce.ts`](../../src/train/flash-cce.ts)
(+ `steel-qmm-header.ts`), [`job.ts`](../../src/train/job.ts) (submit surface),
[`lora-params.ts`](../../src/train/lora-params.ts), [`rank.ts`](../../src/train/rank.ts).
Entry points: [`scripts/train-orpo.ts`](../../scripts/train-orpo.ts) (env launcher),
`mlx-bun train` (`src/cli.ts`), the `/finetune` job runner. SFT examples:
`scripts/examples/chunk-finetune.ts`, `scripts/examples/ft-e4b-v2.sh`,
`scripts/examples/chunk-eval.ts`.

## 1. The objective

$$\mathcal{L}_{ORPO} = \mathcal{L}_{NLL}(y_w) + \lambda \cdot \mathcal{L}_{OR}$$

- $\mathcal{L}_{NLL}(y_w)$ — cross-entropy on the **chosen** sequence. Scope is
  `sft_scope` (`TrainConfig.sftScope`, default **`full`**):
  - `full` (paper/TRL-faithful): token-mean CE over all non-pad positions,
    prompt AND response, from the **same chosen forward** — the head runs once
    over the prompt span and once over the response span (disjoint), combined
    as $\text{NLL}_{full} = -\frac{(P{-}1)\,\text{pm} + M\,\ell_w}{(P{-}1)+M}$
    (`combineFullNll`). Matches TRL `ORPOTrainer.chosen_nll_loss` and
    xfactlab/orpo `outputs_pos.loss`.
  - `response`: $-\ell_w$, the pre-2026-07 house convention (prompt masked),
    kept bit-exact for reproducing older runs.
- $\mathcal{L}_{OR} = -\log\sigma(\text{log\_odds})$ with
  $\text{log\_odds} = (\ell_w - \ell_r) - (\text{log1mexp}(\ell_w) - \text{log1mexp}(\ell_r))$,
  $\text{log1mexp}(x) = \log(1-e^x)$. $\ell_w,\ell_r$ are **length-normalized
  means** over response tokens in BOTH scope modes (also TRL's convention —
  its `get_batch_logps` masks the prompt for the odds ratio; only the NLL term
  is full-sequence). $\lambda$ weights only $\mathcal{L}_{OR}$; the NLL term is
  unweighted.

Implementation (`loss.ts`): `log1mexp` (stable `log(clip(1 − exp(x), eps, 1))`
— mlx-bun has no `expm1`/`log1p`; per-token mean logp is comfortably negative
so the clip is safe), `orpoLogOdds`, `orpoLossFromLogps(lw, lr, λ, nllFull?)`
(model-free, unit-testable against a hand reference), `orpoLoss(model, batch,
λ, chunk?, sftScope)` (runs the two forwards), `orpoMetrics` (no-grad
`loss`/`nll`/`or`/`accuracy`/`margin`).

Two facts that shape everything downstream:

1. **Mean, not sum.** The one substantive difference from DPO's `seqLogp`
   (per-row sum). Summing biases toward short responses and makes the OR
   gradient length-dependent.
2. **The chosen forward does double duty.** ORPO is **2 forwards/step**
   (chosen + rejected, both with grad) vs DPO's 4 (2 reference + 2 policy). No
   reference model, no `setLoraScale(0)` dance, no detached reference tensors.
   Never forward chosen twice; never compute a rejected NLL.

Two unpadded sequential B=1 forwards are the *right* shape, not a limitation:
TRL's padded `concatenated_forward` exists to amortize FSDP all-gathers we
don't have; on unified memory the padding is pure waste.

## 2. Oracles and the parity ladder

Neither `mlx_lm` nor `optiq` ships ORPO, so — unlike DPO (`loss.ts` ported
`optiq/lora/dpo.py`) — ORPO is a **no-oracle mlx-bun original (Lab-class)**.
The current MLX SOTA (`mlx-lm-lora`) ships a non-canonical ORPO
(`log_sigmoid(chosen − rejected)`, no SFT-NLL term); do not copy it.

What IS oracle-backed, and where each tier bottoms out:

| Tier | Path | Oracle / gate |
|---|---|---|
| L1 | Non-segmented SFT `value_and_grad` through `ops.sdpa` | **Bit-exact vs `mlx_lm.lora`** — loss on 4/6 mask spans, 0.5 f32-ulp on 2; `dB` over all 42 e4b q_proj layers `0.000e+0` (2026-06-16). Response-only CE == full-masked CE on every span. |
| L2 | `MLX_BUN_TRAIN_ATTN=flash` (port of optiq's `flash_attention_metal`) | optiq flash dK == `ops.sdpa` to f16 (`scripts/oracle/flash-optiq-check.py`); ours == `ops.sdpa` (`tests/flash-attention.test.ts`). |
| Lab | ORPO loss math | Standalone JS/numpy reference + finite differences (`tests/train-orpo.test.ts`; the deleted `parity-orpo.ts` passed 10/10 incl. FD grads at B=1/B=3). |
| Lab | Each memory tier (chunked → fused → flash head; segmented; prefix) | Validated against the tier below: value bit-exact or bf16-class, grads bf16-class, bottoming out at the naive full-logits two-forward path. |

Rules learned the hard way:

- A parity reference is trustworthy only if read **contiguously**
  (`ops.contiguous` before `toFloat32`) with a **non-uniform cotangent** — both
  pitfalls produced false "kernel is wrong" signals; finite differences settled it.
- "0.28% dh" for the flash-CCE head is fp-reassociation vs a full-logits
  *proxy*, not error (two correct reductions in different orders aren't
  bit-identical). Correctness is FD + the math audit; fidelity is
  **teacher-forced on real hiddens**, not synthetic random logits (whose flat
  softmax is the coeff filter's worst case). Standing regression:
  `tests/train-orpo-fused-ce.test.ts` "teacher-forced fidelity" (cos > 0.999,
  relnorm < 5% vs a `Vjp` full-logits reference).
- Validate every custom `.vjp` against `mx.vjp`/autograd, never a hand formula.

## 3. Trainer architecture

`trainLora` dispatches on `cfg.method`: `sftLoop` / `dpoLoop` / `orpoLoop`. All
share `resolveRanks` → `buildTrainableLora` → `AdamW` → a closure that swaps the
LoRA A/B primals so only those leaves differentiate. ORPO consumes the
**preference** dataset format `{prompt, chosen, rejected}` (`"dpo"` kept as an
alias) via `loadDpoDataset` / `iterateDpoBatches`.

`orpoLoop` path selection (verified in `trainer.ts`):

- `segmentSize > 0` → segmented classes (MiniCPM5 or Gemma4 only; else throws).
  With `orpoPrefixShared` the composed `SegmentedBackwardOrpoPrefix[Gemma4]` is
  built alongside a plain `SegmentedBackwardOrpo[Gemma4]` for per-row fallback.
  The segmented head is `boundedHeadFromHidden` (Checkpoint-chunked or fused)
  when `orpoFusedCe || orpoFlashCe`, else full `responseOnlyLogpMean`.
- Otherwise a `ValueAndGrad` over `orpoLossPrefixShared[Gemma]` (when the row's
  prompts are byte-identical; `splitPrefixBatch`) or `orpoLoss`, with a
  `ChunkCtx` selecting the head: `{fused, flash}` (chunk = `orpoChunkSize` or
  512) / Checkpoint token-chunked (`orpoChunkSize > 0`) / full logits.
- Every micro-step goes through `accumulateStep(gradAccumSteps, …)`; the
  per-chunk Checkpoint sink is disposed in its `afterMicroEval` hook.
- Dropout: `model.loraState.dropoutSeed` is set once per micro-step so the
  segmented/checkpoint recompute replays the same mask; cleared before
  metrics/val.
- `MLX_BUN_TRAIN_ATTN=flash` is **refused for Gemma models** (e4b SIGTRAPed at
  ≥2K and has not been re-validated since the kernel fixes); MiniCPM5 allowed.

### Config surface (TrainConfig ↔ job submit ↔ CLI/launcher)

| TrainConfig | `FinetuneSubmit` | `mlx-bun train` / `train-orpo.ts` env | Default | Notes |
|---|---|---|---|---|
| `orpoLambda` | `orpo_lambda` | `LAMBDA` | 0.1 | weights only L_OR |
| `orpoWarmupIters` / `orpoLrSchedule` | `orpo_warmup_iters` / `orpo_lr_schedule` | — | 0 / `cosine` | launcher sets warmup = min(10, iters/10) |
| `orpoChunkSize` | `orpo_chunk_size` | — | 0 (job: 512 for orpo) | token-chunk for all head variants |
| `orpoFusedCe` | `orpo_fused_ce` | `FLASH=0` selects it | false | analytic MLX fused head |
| `orpoFlashCe` | `orpo_flash_ce` | `FLASH` (default on) | false (job: true for orpo) | implies fused |
| `orpoPrefixShared` | `orpo_prefix_shared` | `PREFIX` (default on) | false (job: true for orpo) | MiniCPM5 + Gemma4, B=1 |
| `sftScope` | `sft_scope` | `SFT_SCOPE` | `full` | |
| `segmentSize` | `segment_size` | `SEG` / `SEGOFF=1`; `--seg` / `--no-segment` | 0 (job/CLI: 2 for orpo) | |
| `gradAccumSteps` | `grad_accumulation_steps` | `--grad-accum` (CLI only; no env knob in `train-orpo.ts`) | 1 | |
| `loraDropout` / `rsLora` / `loraPlusRatio` | `lora_dropout` / `rs_lora` / `lora_plus_ratio` | — | 0 / false / 1 | |
| `warmStartAdapter` | `warm_start_adapter` | `RESUME` / `--resume` | "" | weights only; optimizer + schedule restart |
| `gradCheckpoint` + `mlpSplit` | `grad_checkpoint` / `mlp_split` | — | false | mutually exclusive with `segmentSize`; `mlpSplit` Gemma4-only |
| `learningRate` | `learning_rate` | `LR` | 1e-5 for orpo (job/CLI/launcher) | `DEFAULT_TRAIN_CONFIG` is 2e-4 (SFT) |
| `rank` / `scale` | `rank` / `scale` | `RANK` / `SCALE` | orpo: 16 / **2.0** (CLI + launcher) | `DEFAULT_TRAIN_CONFIG`: 8 / 1.0; SFT example scripts use 20 |

Method-prefixed knobs (`orpo_*` / `dpo_*`) are deliberate: no shared or renamed
fields.

## 4. Recommended defaults and regularization geometry

From the hyperparameter spike (paper, TRL `ORPOConfig`, Labonne's Llama-3
ORPO-LoRA). The trap: the paper's `8e-6` is for *full* fine-tuning and
DPO-LoRA's `5e-5` is too hot because ORPO carries a full SFT-NLL term.

| Knob | Default | Why |
|---|---|---|
| `learning_rate` | 1e-5 | matches our SFT recipe; sweep 5e-6–2e-5 |
| `orpo_lambda` | 0.1 | paper's primary value + TRL default; stable 0.1–0.5 (λ=1.0 depresses chosen logp) |
| schedule / warmup | cosine, ≈3% of iters | the OR gradient's `1/(1−P)` factor amplifies low-likelihood updates, so cold high LR hurts more than in SFT |
| `rank` | 16 | |
| epochs | 1 to start | eval loss rises fast past epoch 1–2; early-stop on val margin |

Sources: [ORPO paper](https://aclanthology.org/2024.emnlp-main.626/),
[TRL `orpo_config.py`](https://github.com/huggingface/trl/blob/main/trl/trainer/orpo_config.py),
[Labonne](https://huggingface.co/blog/mlabonne/orpo-llama-3).

**Regularization, ordered by leverage** (ORPO is ~1 epoch on small sets, so
overfitting and step geometry matter more than capacity):

- **Rank is the primary regularizer**; `rank_scaling` (`by_bits`/`by_kl`) is how
  capacity is distributed. `bitsMapFromModel` (reads `linear.spec.bits`) and
  `readPerLayerKl` (`optiq_metadata.json`) feed `resolveRanks` — before this was
  wired the policy silently went uniform. `by_bits`: `rank·(bits/4)`; `by_kl`:
  `rank·clip(kl/median, 0.5, 2)` — optiq's "one signal, two optimizations"
  (`tests/train-rank.test.ts`).
- **Rank ↔ scale ↔ init.** Update is `α·BA` with B zero-init, A uniform(±1/√in).
  At step 0 `dA ∝ dy·Bᵀ = 0`: B does all the early learning → **LoRA+**
  (`lora_plus_ratio`, higher LR on B leaves) helps. A fixed α makes the step
  size scale with per-layer rank, defeating rank scaling → **rsLoRA**
  (`rs_lora`, α/√r; saved into the adapter config so inference applies the same
  per-layer scale).
- **Weight decay** on A and B independently is a nuclear-norm-style penalty on
  `ΔW`, not Frobenius; the SFT-NLL term already anchors, so default lower than
  SFT's 0.01 and tune.
- **LoRA-input dropout** (`lora_dropout`, PEFT-style, default 0, ~0.05 for small
  sets). The base has no dropout modules (TRL's `disable_dropout` is moot).
  Recompute determinism is mandatory: mask keyed by (step, layer) so segmented
  / checkpoint / chunked recompute reproduces it (`tests/train-regularization*.test.ts`).

The remaining work here is empirical: sweep `rs_lora` / `lora_plus_ratio` /
`lora_dropout` / `weight_decay` on a real run and judge by held-out val margin
(`bestMargin` in `metrics.json`).

## 5. Memory and speed

Two terms dominate at long context, and neither is the LoRA grads: (1) the LM
head logits `[1,T,V]` + gradient (~4.3/8.6 GB bf16 at T=8192, V=262k), doubled
by ORPO's two branches; (2) per-layer activations held for the backward. The
ordering principle for Apple Silicon: **only reducing total live footprint
moves the constraint — relocation does not.** CPU and GPU share one pool, so
activation offloading frees zero bytes, risks double residency, and burns the
scarce bandwidth. We do not implement it.

### 5.1 The head: from token-chunking to the flash-CCE kernel

CE and the per-token target logp ORPO needs are the same quantity
(`logp_t = h_t·W_{y_t} − logsumexp_v(h_t·W_v)`), so one memory-efficient engine
serves the NLL and the odds-ratio terms. Four tiers were built; each is
validated against the one below.

1. **Token-chunked Checkpoint head** (`chunkedLogpMeanB1`, `orpoChunkSize`).
   Each `[chunk,V]` head is wrapped in a `Checkpoint` and recomputed in the
   backward. A Checkpoint *drops* its input activations, so the hidden slices
   it reads must live in the `sink` until grads are eval'd (found during
   bring-up). Forward parity within bf16 (single-ULP head-matmul tiling
   differences), exact for one chunk (`tests/train-orpo-chunked.test.ts`).
2. **Fused linear-CE head** (`fusedLogpMeanB1`, `orpo_fused_ce`; Liger
   `FusedLinearCrossEntropy` on MLX). One `CustomVjp`: forward materializes
   `[chunk,V]` per chunk (`quantizedMatmul(h, W, transpose=true)` + Gemma
   `logitSoftcap`), reduces to `target − lse`, drops the logits; the analytic
   backward recomputes and forms `g·(onehot − softmax)·sech²` directly, then
   `dh = quantizedMatmul(grad, W, transpose=false)` — mlx's own x-vjp,
   contracting vocab without dequantizing the head. Value **bit-exact** vs full
   logits on MiniCPM5 and e4b (softcap=30 matched by reusing `logitSoftcap`'s
   div-by-bf16-cap formula); grads 0.51% / 1.97% bf16-class
   (`tests/train-orpo-fused-ce.test.ts`). The head is frozen (not a LoRA
   target), so only `dh` flows back.
3. **Vocab-blocked online-softmax in pure MLX** — implemented, numerically
   correct, **does not bound memory**, gated off. The `(m,d)` recurrence and
   the cross-block `dh` accumulation must be f32 (bf16 gave 17→45% grad error
   scaling with block count). But the online softmax is a sequentially
   dependent chain and MLX's lazy eval retains the whole chain: head-isolated
   peak went 3.4 GB → 14.1 GB at 512-wide blocks (MiniCPM5 M=2048, 2026-06-18).
   Forcing an eval mid-chain breaks autodiff. Conclusion: the CCE residency
   bound needs the vocab loop INSIDE a kernel.
4. **flash-CCE Metal kernel** (`flash-cce.ts`, `orpo_flash_ce`) — Apple
   Cut-Cross-Entropy + Liger transpiled Triton → Metal with three divergences:
   the classifier is the **quantized** head (in-Metal 4/8-bit affine dequant,
   mlx `quantized.h` qdot pattern); only `dE`/`dh` is needed (frozen head, no
   `dC`); the cross-block LSE merge is cheap MLX ops on per-block partials, not
   atomic logaddexp. Evolution, all 2026-06-18/19 on the M1 Max 32 GB dev box:
   - v1 (one threadgroup per token, whole vocab serially): memory bound
     achieved (MiniCPM5 M=8192 fwd 2.45 → 0.34 GB; e4b M=512 bwd 2.06 → 1.17
     GB) but e4b ≥1024 tripped the GPU watchdog.
   - Vocab-parallel grid `[TG, nVocabBlocks, M]`, `VOCAB_BLOCK=8192`; backward
     atomic-adds partial `dh` into `[M,H]`. e4b M=1024 deterministic, logp
     0.20% / dh 0.40%, bwd peak 3.41 → 1.46 GB.
   - `BLOCK_B` token tiling (dequant a vocab row once, reuse across 8 tokens
     fwd / 4 bwd — the backward is register-bound by `dacc`): 2.5× total.
   - **steel GEMM** (`steel-qmm-header.ts`, MLX's verbatim `BlockMMA`) for
     forward and backward, with a temp-BlockMMA-per-H-tile + lane-local
     fragment accumulation: e4b bwd **3687 → 754 ms**, fwd 180 ms, peak
     **0.93 GB flat @ M=8192**; dh 0.40% e4b / 0.28% cpm.
     `MLX_BUN_CCE_NOSTEEL` / `MLX_BUN_CCE_BWD_NOSTEEL` fall back to the
     simdgroup / scalar kernels (also the non-32-divisible-shape fallback).
   - Apple-CCE backward skips: coeff filter (`MLX_BUN_CCE_BWD_FILTER_EPS`) and
     blockMax skip (`MLX_BUN_CCE_BWD_BLOCK_EPS`), **both default `1e-5` since
     2026-07-02** (`=0` compiles them out). Real-data teacher-forced
     measurement (M1 Max, chunk-ORPO data): filter 0.343%/1.41× (CPM5),
     0.158%/1.70× (e4b); block skip ≤0.004% dh; combined **1.71× / 3.16×**
     backward vs exact. Run-to-run dh is not byte-stable at any eps (atomic-add
     reassociation). Note: docs/reference/training.md still describes the skips as
     off by default; `flash-cce.ts` is the truth.
   - Operand precision today is **W4A32**: 4-bit weights dequantized into fp32
     tiles and multiplied with fp32 simdgroup matrices; the `dh` accumulator is
     already fp32. See §8.1 (W4A16 spike).

Composition finding: the fused `CustomVjp` **does not bound memory when nested
inside the segmented `mlx_vjp` head** (its per-chunk graph is not freed
incrementally there; +0.8–1.1 GB at L=3072–4096 on MiniCPM5), so the segmented
bounded head uses the Checkpoint variant `chunkedLogpMeanFromHidden` (bit-exact
recompute). And bounding the head did not reduce the segmented peak at any
reachable scale (MiniCPM5 L=2048–4096 × SEG 2/6; e4b L=2048: 11.95 GB both) —
the head `[M,V]` is transient and never stacks with the per-segment backward
peak. The trainer still routes flash/fused into the segmented head so e4b never
reintroduces `[M,V]`.

Host-buffer lesson (2026-06-21): `u32()` kernel-arg arrays built with the
zero-copy `fromView` and disposed before the lazy kernel evaluated leaked pins
(+32/step) → use-after-free that ran clean on the 32 GB M1 Max and crashed on
the 24 GB M4 Pro. Fix: `fromBytesCopy`; `MetalKernel.apply` `ptr()` lifetimes
hardened; a `pinned` canary on the train metric. `fromView` is only for
process-lifetime memory. A related UAF in the segmented ORPO classes (the flash
head's `headSink` freed before the lazy backward read `lse`/`blockMax`) is fixed
by `ops.evalAll` on the head-VJP roots before dispose.

### 5.2 Attention backward: `ops.sdpa` vs the flash kernel

Default training attention is `ops.sdpa` (`mx.fast.scaled_dot_product_attention`)
— exact (dQ/dK/dV FD-verified 0.00%) and fast, but its Metal backward is NYI
(`ScaledDotProductAttentionVJP::use_fallback()` returns true), so MLX
decomposes it and **materializes the L×L scores for every layer**: O(L²)
backward memory (0.02 → 0.33 → 1.40 GB at T=512/2048/4096 in the isolated
attention-backward bench; ~3.5 GB/layer @8K on e4b). The hand-rolled flash
kernel (`src/model/flash-attention.ts`, `MLX_BUN_TRAIN_ATTN=flash`) is O(L)
(0.03 → 0.23 → 0.90 GB) but ~30× slower — a naive scalar kernel at ~0.5% of GPU
peak. Two genuine port bugs were fixed rather than deleting it (a spurious dK
transpose for Tkv≠D; a divergent `threadgroup_barrier` in the dQ causal
tile-skip), restoring L2 parity with optiq. It remains the dormant long-context
fallback for MiniCPM5; the trainer refuses it for Gemma.

The sliding-window layers are NOT cheaper in the backward — the window is only
an additive mask on the materialized scores (measured 2026-07-02: a sliding
pair +7.1 GB ≈ sliding+full +7.15 GB @8K). This falsified the earlier
full-attention-isolation planner premise (§5.3).

### 5.3 Segmented backward

Naive gradient checkpointing (ours and Python mlx's) does not stream: the
checkpointed backward holds every layer's recompute activations at once, so
e4b spiked to 23 GB live @2048 (resting 6.95 GB) and crashed at 4096
(`peak(L) ≈ 7.7 GB + 7.6 MB/token`). Measurement note that unlocked this:
`mlx_get_peak_memory` is peak **live**, not live+cache; use
`activeMemory()`/`cacheMemory()`/`clearCache()` to separate them, and eval the
loss and grads together (`evalAll([value, ...grads])`) — evaluating `value`
separately frees the forward and forces the backward to recompute-and-hold
everything.

**Mechanism** (`SegmentedBackward*`, `planSegmentsBySize`):

1. Forward, saving boundaries: run the layer stack; at each segment edge
   (`segmentSize` layers) eval and **detach** the residual hidden into a leaf
   (`detachLeaf` = `ops.contiguous` + `detachCopy`; `detachLeaves` batches the
   eval barrier). mlx `eval` does not detach — without the copy each boundary
   drags a layer-stack of activations.
2. Head: `finalNorm` + LM head + loss over the last boundary as a `Vjp` with
   scalar cotangent 1.0 → loss value and `dh_out`.
3. Backward, reverse over segments: `vjp.apply([boundary_k, ...LoRA_k], [dh_out])`
   → `[dh_in, ...dLoRA_k]`; `dh_in` seeds segment k−1; LoRA grads scatter into
   the flat grad vector. Only one segment's activations are live. Recompute
   overhead ≈ 1× forward regardless of segment count, so `segmentSize` is a
   peak knob at ~fixed time.

**The `mlx_vjp` finding.** The first implementation used optiq's
surrogate-loss trick — `value_and_grad` of
`sum(stop_grad(dh) ⊙ segment_forward(...))` per segment. Numerically identical,
but it **leaked ~32 MB of live memory per segment per step** (linear, no
plateau; 1.12 → 6.61 GB over 30 iters at SEG=4/2048), unreclaimable by
`clearCache`/GC/`synchronize`/disposal. A minimal repro pinned it to
`value_and_grad` (`MODE=layers` leaks ~6 MB/iter; `MODE=vjp` flat). Driving
each segment with **`mlx_vjp`** (`Vjp` in `src/mlx/autograd.ts`) is the
production path: active flat (1.04 GB × 12 iters end-to-end at SEQ=4096). Vjp
objects are built once per run and reused; rebuilding per step leaks.

**Numbers.** MiniCPM5-1B, SEG=4, M1 Max 32 GB, 2026-06-16, peak live:

| seq | full backward | segmented | note |
|---|---|---|---|
| 512 | 3.15 GB | 1.87 GB | |
| 2048 | 10.91 GB | **3.29 GB** | post-vjp fix (3.44 pre) |
| 4096 | 21–26 GB (spikes) | 6–8 GB | |

Under flash attention the segmented grads bit-match the full `value_and_grad`
(relNorm 0.0000%, maxAbs 0.0). Under `ops.sdpa` they differ ~6% relNorm — not a
segmentation bug: mlx's fused sdpa gives a different bf16 result in its eager
forward (12.0712) than its autograd-decomposed forward (12.0568), so boundaries
saved eagerly and recomputed under autograd disagree. The non-segmented trainer
already trained against the autograd forward while inference used the eager
one. A real 300-iter run (SEG=4, SEQ=4096) peaked 6.51 GB (non-seg 25.47 GB),
no leak, and its adapter scored 95.10 on the chunk holdout vs 91.70
non-segmented.

**e4b (Gemma4) additions** (`SegmentedBackwardGemma4`, `Gemma4Model.runLayerRange`
/ `makeTrainingMasks` / `embedForSegmented` / `reusedDonors`):

- Per-layer-input is a pure constant boundary (its grad would flow to the
  embed / `per_layer_model_projection`, neither a LoRA target): detached once,
  sliced per segment, cotangent discarded.
- KV-shared donor K/V (donors 22 sliding / 23 full feed all sharers in
  [24,42)) is a **second boundary stream with its own cotangent**: sharer
  segments differentiate `[h, donorK, donorV, ...LoRA]` and accumulate the
  donor vjps into `dKV[d]`; the donor segment's multi-output forward
  `[h_out, k, v]` takes `[dh, dKV.k, dKV.v]`. Two contiguity fixes were
  essential: `detachLeaf` must force row-major (donor K/V are transposed
  views) and the producer must output contiguous donor K/V.
- Grads: single-consumer donor reuse is bit-exact (2-segment split at 24: 0/258
  off); the natural 7-segment cut is ~0.97% relNorm from bf16
  non-associativity of the within-vjp cotangent sums — flat in consumer count,
  tracks summand count (donor 22 ≈0.46%, donor 23 ≈0.000%), not helped by fp32
  cross-segment accumulation. **The lever is the segment cut, not the dtype**:
  keep a donor's sharers in one consumer segment for tighter grads at higher
  peak. Vs the `mlx_lm.lora` bit-exact reference: segmented q_proj dB ~2.3%
  (bf16-class).
- Memory vs the honest reference (`mlx_lm.lora --train --grad-checkpoint`,
  which checkpoints per layer, 42 groups of 1; oracle venv, M1 Max 32 GB,
  2026-06-16), matched grouping:

  | L | mlx-lm (per-layer) | ours segSize=1 | ours segSize=6 |
  |---|---|---|---|
  | 2048 | 12.84 GB | **8.76 GB** | 11.05 |
  | 4096 | 20.87 GB | **10.93 GB** | 16.06 |
  | 8192 | OOM (25.72 @16 layers) | **15.29 GB** | 17.5 (seg2) |

  Two unisolated confounds: mlx-lm's `default_loss` materializes full
  `[1,L,262144]` logits (~4 GB @4K) vs our response-only CE; and full streaming
  vs per-layer checkpoint inside one backward. The headline is part
  CE-optimization, part mechanism.

**Segmentation strategy — corrected 2026-07-02.** The original plan (isolate the
7 O(L²) full-attention layers in singleton segments, `planSegments` with a
memory cost model) was built and A/B'd @8K: **zero peak win** (18.09 vs 18.02
GB seg2), because every layer's sdpa backward is O(L²) (§5.2). The worst
segment is set by **layer count alone** — `segment_size` is the whole knob:
seg1 = 14.59 GB @8K on e4b, +3% step time, loss identical. Going lower needs an
O(L)-memory attention backward, not smarter segmentation. `planSegmentsBySize`
stays; the donor/boundary constraints from the plan still hold. Rotor/min-cut
planners (§8.1) would need a corrected cost model.

**ORPO variants.** `SegmentedBackwardOrpo[Gemma4]` run chosen and rejected
forwards segment-by-segment, a two-input head `Vjp` over `[hC, hR]` yields
`[dh_c, dh_r]`, each branch walks backward over its segments (donor cotangents
in a per-branch `dKV`), LoRA grads summed. e4b at L=256: full two-branch 12.67
GB → segmented 7.66 GB; 8.71 GB at L=1024 where the full backward doesn't fit
(2026-06-18, M1 Max 32 GB). At λ=0 the e4b path is byte-identical to SFT
`SegmentedBackwardGemma4` (relNorm 1.1341%, maxAbs 3.79e-3 — the same numbers),
proving zero added error; donor recipients (layers 22/23 k/v_proj) stay <0.5%.

**Intra-layer MLP split** (`mlpSplit`, gradCheckpoint path, Gemma4 only):
`forwardAttn` / `forwardMlp` checkpointed separately with the post-attn
residual `hMid` as the boundary. Bit-exact (0.000000%). Honest peak: L=2048
no-ckpt 28.60 → single 23.40 → split 23.35 GB — the per-layer checkpoint
already serializes layers, so the split saves one layer's attn-sized window;
under `ops.sdpa` the MLP intermediate dominates. Off by default.

### 5.4 Shared prompt-prefix forward

Chosen and rejected share the prompt; the causal mask makes the prefix's
hidden states independent of the continuation. One forward over
`[prompt(P); chosen(Rc); rejected(Rr)]` with (a) a **block-sparse mask**
(causal AND NOT rejected→chosen, `blockSparseMask`, carried by
`PrefixSharedCache`), (b) **block-wise RoPE** resetting each response to offset
P (`ropeBlocks`, `setMiniCpmPrefixPlan` / `setGemmaPrefixPlan`), and the head
gathering `chosen[k] ← H[P−1+k]`, `rejected[0] ← H[P−1]`, `rejected[k≥1] ←
H[P+Rc+k−1]` (`prefixGatherIdx`). Token cost `2(P+R) → P+2R`; reverse-mode AD
sums the two branches' cotangents into the prefix for free. Published for DPO
(Wang & Hegde, arXiv 2410.20305); no mainstream trainer does it at training
time. `splitPrefixBatch` falls back to two-forward for rows whose prompts
differ (logged once, counted).

- **MiniCPM5**: forward **bit-exact** vs two-forward (P=512/Rc=64/Rr=80), grads
  ~1.05% (f32-over-bf16 reassociation in LoRA grad matmuls over the merged
  length; holds at λ=0), 1.78× fewer token-passes, peak 5.40 → 3.80 GB
  (2026-06-18).
- **e4b** (`blockSparsePrefixMaskGemma` with a LOGICAL-position sliding-window
  cut, `Gemma4PrefixSharedCache`, `orpoLossPrefixSharedGemma`): the
  construction is proven — block-RoPE+mask == a plain forward over the same
  concat to 0.00% at every chosen position — but it does NOT reproduce the
  two-forward numbers (loss ~0.08%, hiddens 3–14%) because **the e4b forward is
  itself length-sensitive**: `forward([prompt])` vs `forward([prompt; extra])`
  differ 1.7% at position 0 up to ~14% later, through the production
  `TrainingCache`. Root cause is e4b's scale=1.0 attention (headDim 256, normed
  q/k → sharply peaked softmax) amplifying sub-bf16 matmul-tiling roundings
  that vary with row count — the same class as the SigLIP tower. MiniCPM5
  (1/√d) shows 0.00%. Accepted as a numerical caveat for a fine-tune; the
  single-concat forward is its oracle. Composed with the segmented backward
  (`SegmentedBackwardOrpoPrefixGemma4`, donor-KV + logical-window mask threaded
  through segments): seg-vs-non-seg grads 1.7–2.3%, peak 30–39% lower
  (2026-06-19).
- Measured effect on e4b @8192 (M1 Max 32 GB, prompt-dominant data, short
  probe): 16.1 GB / ~175 s/step → **13.3 GB / ~70 s/step** with prefix-share.

### 5.5 What composes with what

| | flash/fused head | segmented | prefix-shared | grad-accum | B>1 |
|---|---|---|---|---|---|
| flash/fused head | — | yes (Checkpoint-bounded head inside segments) | yes (per branch) | yes | no (B=1) |
| segmented | | — | yes (MiniCPM5 + Gemma4) | yes | no |
| prefix-shared | | | — | yes | no |
| grad-accum | | | | — | n/a |

The memory-optimized paths are **B=1 only**; `grad_accumulation_steps` is the
effective-batch lever at B=1 memory (`accumulateStep` evals and frees each
micro-graph; measured ~1.02× peak at N=3 on MiniCPM5, both SFT and ORPO;
`tests/train-gradaccum.test.ts`). B>1 falls out on the monolithic path via
`iterateDpoBatches` padding + the batched pad mask (`forward.ts`). True batched
segmented backward is not built. Qwen has no segmented backward (needs
`SSMCache` + a differentiable gated-delta kernel) and would land on the full
backward first.

Explicitly dropped: activation offloading (no-op on unified memory), TRL's
padded concatenated forward, sequence packing / length-grouped batching
(SFT-only wins, moot at B=1).

### 5.6 Quantized base

Each `QuantizedLinear` carries its own `QuantSpec`; `quantized_matmul` has a
working x-vjp and the base is frozen, so mixed precision costs nothing in the
layer stack. The only quant-aware training code is the head: a vocab chunk is
an axis-0 row slice of the quantized `w`/`scales`/`biases` (one spec per head),
and the flash-CCE kernel dequantizes in-kernel.

## 6. Kernel-fusion notes (the flat-DAG payoff)

Verified MLX facts (re-grep against the pinned 0.31.2 before relying):
`mx.compile` fuses contiguous elementwise chains in fwd AND bwd, bounded by
matmul/SDPA/reductions/reshape — compile the *outermost* `value_and_grad` or
the backward lands outside the region; `mx.fast` ships fused fwd+bwd for
`rms_norm`/`layer_norm`/`rope` (use them); SDPA backward is the Metal
exception (§5.2); `mx.fast.metal_kernel` inside `mx.custom_function` with a
`.vjp` is fully differentiable (the mechanism every custom head uses).

Remaining custom-kernel targets, ranked: fused SDPA backward (FA2-style,
store per-row LSE, recompute `P` — removes the O(L²) term segmentation
compensates for); fused dequant-GEMM + LoRA epilogue with the Unsloth-style
manual backward (`h=x@A; dB=s·hᵀ@dy; dA=s·xᵀ@(dy@Bᵀ); dx=dy@Wᵀ + s·(dy@Bᵀ)@Aᵀ`);
recompute↔backward fusion in the segmented path; min-cut rematerialization
(AOTAutograd's partitioner) as a fusion-aware replacement for hand-chosen cuts.
The GeGLU/SwiGLU `CustomVjp` (grad_b = dc·gelu(a), grad_a = dc·b·gelu'(a)) was
written and validated, then deleted 2026-07-05 with the fused kernels —
compiled activations own that fusion bit-exactly
([unified-engine-frontier-plan.md §6](unified-engine-frontier-plan.md)), and
training needs no env-flag sanitization.

Per-model specialized training paths would mirror `scripts/gen-model.ts`'s
fingerprint-dispatched generated forwards with the monolith as fallback; not
built.

## 7. Quality experiment pipeline

Pieces (judge-free, unit-tested): `src/eval/ifeval.ts` (verifiable-instruction
scorer), `src/eval/ultrafeedback.ts` + `scripts/curate-ultrafeedback.ts`
(binarized UF → preference JSONL with length filtering), `scripts/run-ifeval.ts`
(before/after runner), `scripts/bench-orpo.ts` (ms/step + peak across head /
segment configs). Prompt masking is verified (`tests/dpo-masking.test.ts`):
left-truncation preserves the prompt/response boundary; the only leak is a
completion ≥ `max_seq_length`, which `loadDpoDataset` warns on.

Result so far: an 800-step MiniCPM5 UltraFeedback run left IFEval flat
(22.5%) — general data + a tiny run on a 1B is the wrong lever. The
load-bearing target is the **chunk segmenter** (distilled segmentation with
boundary/label accuracy vs gold). Small sets (~450 pairs) overfit fast: keep λ
modest, carve a ~50-pair `valid.jsonl`, watch val margin, `save_checkpoints`
and mount the best-margin checkpoint.

## 8. Future

### 8.1 Deferred performance levers

- **Grad-accumulation A/B.** `--grad-accum` is exposed in `mlx-bun train`
  (`scripts/train-orpo.ts` has no env knob for it). What's open is the
  measurement: at hard B=1 every update is one pair (the 0.4↔3.3 per-step loss
  swing is that noise); A/B G=4/8 on val margin. It is not a speedup and not a
  guaranteed win (the prior run converged at B=1, val 1.66→1.50). Generic
  N-way batching is parked — prefix-share is already a hand-built
  batch-of-2 (1F+1B over `[P; Rc; Rr]`), strictly cheaper than a generic
  2-batch's 2F+2B.
- **W4A16 head GEMM (compute precision) — proposed 2026-06-19, not started.**
  The steel head runs W4A32 (`BlockMMA<float,float>` fwd and both bwd phases;
  fp32 staging tiles; dequant into fp32). Apple GPUs run fp16 FMA at ~2× fp32,
  and the kernel is **ALU-bound, measured live** (M1 Max, MiniCPM5 ORPO
  `--no-segment` seq 4096: GPU 100% @1296 MHz, memory BW 129 GB/s ≈ ⅓ of ~400,
  17.4/32 GB) — the 4-bit storage already did its job and the GPU spends
  cycles on fp32 FMAs. Plan: (0) confirm which `BlockMMA`/`BlockLoader`
  template params are operand vs accumulator; (1b) profile the dequant-ALU vs
  FMA split — if FMA < ~40% of the kernel, reset expectations; (2) add a gate
  (`CCE_A_HALF` define + env flag, fp32 stays the exact parity mode for the
  1e-5 gate, half graded by greedy-prefix logit parity); (3) forward to half
  operands first, land alone; (4) backward range probe — the survivors after
  the skips are near-zero coeff tails where fp16 underflows, and `h` can carry
  residual outliers (M1 Max has no bf16 simdgroup_matrix, so fp16 is the only
  half); (5) backward to half only on a go; (6) re-sweep `BLOCK_B`/tiles —
  half staging halves threadgroup memory, the constraint that capped the
  current tiling. fp32 accumulate is non-negotiable; validate grads vs
  autograd. Context measurement (M1 Max, MiniCPM5 seq 4096): `--no-segment`
  ~1.25 s/step @9.26 GB vs `--seg 2` ~1.58 s/step @2.62 GB — bit-identical
  output, ~20% faster for 3.5× peak.
- **Sequence-chunk the MLP sub-block** inside segments: MLP is per-token
  independent, so its `d_ff` intermediate can drop from `O(T·d_ff)` to
  `O(chunk·d_ff)` at ~zero recompute — the bigger MLP lever than `mlpSplit`.
- **Budget-aware segment planner** (rotor DP / min-cut): only worth building
  with the corrected cost model (every layer O(L²) under `ops.sdpa`); today
  `segment_size` is the whole knob.
- **Faster flash-attention backward**: simdgroup tiling, larger threadgroups,
  FA2-style LSE-only storage — matters only where `ops.sdpa`'s O(L²) is the
  blocker (≳16K). MLX's own `mx.fast.sdpa` source is the blueprint.
- **Fused LoRA epilogue** (§6) — benefits SFT/DPO/ORPO and adapter serving.
- **Shape-specialized compiled training graphs**: each row has concrete
  `(P, Rc, Rr)`, so ORPO can compile exact or bucketed shapes keyed on model
  checksum + flags + segment plan + chunk sizes, eager fallback for misses.
  Custom Metal kernels stay outside compiled regions.
- **ORPO-grad folding inside the head kernel** (speed-only; autograd composes
  the odds-ratio grad outside it today) and a head-LoRA `∇A/∇B` path if the
  head ever becomes a target.
- Optimize the flash SDPA kernel with simdgroup_matrix, or beat `mx.fast.sdpa`
  for our fixed head-dims / training-only backward / O(L) constraint —
  research spike, not scheduled.

### 8.2 Dynamic λ controller (proposed 2026-06-20, reframed 2026-07-01; not built)

Josh's framing: *λ is not a hyperparameter to tune but a process variable to
control* — push preference pressure to the maximum the model can bear
(self-discovering), retreat on confirmed coherence damage (self-stabilizing),
hold inside the healthy band. Motivation: the SFT/NLL half learns easily (val
loss falls while accuracy/margin barely move); over-weighting OR triggers
**likelihood displacement** (margin widened by crushing `logp(rejected)` and
sometimes `logp(chosen)`, cf. arXiv 2410.08847). Closest prior is β-DPO
(arXiv 2407.08639, per-batch calibration); the claim here would be closed-loop
trajectory control with a displacement-aware signal — the controller must beat
the *best constant* λ from a sweep, not λ=0.1.

- **Signals**: `lw` and `lr` separately (today `orpoMetrics` returns only
  `loss/nll/or/accuracy/margin` — surfacing `lw`/`lr` is the load-bearing
  instrumentation), on **val** each `stepsPerEval` (per-step B=1 train metrics
  are too noisy). Control on the **response-only** `lw` — full-scope NLL mixes
  prompt modeling into the level. Margin↑ via `lw`↑ is healthy; margin↑ via
  `lr`↓ with `lw` flat/falling is displacement.
- **Law**: phase machine (SFT warmup at `LAMBDA_MIN` until `dLw` plateaus →
  ramp `+RAMP` per eval while `dLw ≥ −EPS_DISP` → back off on displacement,
  hysteresis over K evals; hard stop if `lw` falls below its start by a
  threshold) — i.e. AIMD; generalize to P → PD → PID incrementally, each term
  earning its place (D on a robust EMA slope for the leading indicator; I with
  anti-windup for chronic offset). Bias toward pushing with a safety margin
  below the cliff; the degenerate failure is collapsing to pure SFT.
- **Wiring**: λ becomes a mutable ref read per step (today it is a constant
  threaded into `orpoLoss` and baked into the segmented classes' constructors
  → add `setLambda`); controller lives in `orpoLoop` after each val eval;
  gated `orpoLambdaSchedule: "static" | "adaptive"`, static = today exactly.
- **Validation**: same data/seed, Arm A static 0.1 vs Arm B adaptive; compare
  val accuracy/margin and `lw` trajectories plus downstream win-rate; validate
  the controller on the prefer-uppercase positive control first; set EPS from
  observed val-`lw` noise, not hand-fit. Report both arms (adaptive is our
  method, not "standard ORPO").

### 8.3 Objective variants and data

Once the shared logp engine exists these are cheap siblings: **SimPO**
(`softplus(−β((lw − lr) − γ))`), **IPO**, **hinge/SLiC** margin loss, label
smoothing / per-example weights / loss clipping / ambiguity filtering. Data
quality likely beats objective cleverness on small runs: filter UltraFeedback
by score gap, bounded length ratio, semantic contrast, and instruction-following
categories if IFEval is the metric.

## History

- 2026-06-15 — e4b LoRA enablement diagnosis: the wall is backward memory
  (full-vocab logits + un-streamed activations), not attention; response-only
  CE landed.
- 2026-06-16 — Segmented backward Phase A (MiniCPM5, bit-exact under flash,
  10.91 → 3.29 GB @2048) and Phase B (e4b, donor-KV + per-layer-input
  threading, all 42 layers @8K where mlx-lm OOMs); surrogate `value_and_grad`
  leak found, replaced by `mlx_vjp`; non-segmented SFT proven bit-exact vs
  `mlx_lm.lora`.
- 2026-06-17 — ORPO landed as a method: loss math + tests, `orpoLoop`, job
  submit, `/finetune` picker, e2e on MiniCPM5; `bitsMap` rank scaling wired;
  dataset format renamed `preference`; flash SDPA kernel fixed to L2 parity.
- 2026-06-18 — Token-chunked head; fused linear-CE head; vocab-blocked pure-MLX
  CCE (correct, unbounded, gated off); flash-CCE kernel v1 → vocab-parallel →
  `BLOCK_B`; `SegmentedBackwardOrpo` + `SegmentedBackwardOrpoGemma4`; MiniCPM5
  prefix-shared reference (forward bit-exact); LoRA dropout / rsLoRA / LoRA+;
  `mlpSplit`.
- 2026-06-19 — Steel GEMM flash head fwd+bwd in production (e4b bwd 3687 → 754
  ms, 0.93 GB flat); prefix-sharing wired and composed with the flash head and
  segmented backward for MiniCPM5 and e4b; warm-start (`RESUME`);
  `scripts/train-orpo.ts` launcher; W4A16 spike proposed; grad-accum A/B
  deferred.
- 2026-06-20/23 — Dynamic λ controller proposed, PID/AIMD framing added.
- 2026-06-21/22 — Host-buffer pin-leak post-mortem (`fromView` → `fromBytesCopy`);
  Lab gates: FD + teacher-forced fidelity replace "parity" for the no-oracle
  head; coeff filter measured near-free on real data.
- 2026-07-01 — `sft_scope: full | response` (default `full`), implemented on
  every ORPO path; dynamic-λ reframed as band control.
- 2026-07-02 — Apple-CCE skips default 1e-5 (1.71× / 3.16× backward);
  teacher-forced fidelity regression test; full-attention isolation planner
  refuted (every layer O(L²)); `segment_size` 1 = 14.59 GB @8K on e4b.
- 2026-07-05 — Fused GeGLU/SwiGLU and perf kernels deleted; no training flag
  sanitization remains.
- 2026-08-23 — This doc consolidated `docs/design/orpo-training.md`,
  `docs/design/orpo-training.md`, `docs/design/orpo-training.md`, and
  `docs/design/orpo-training.md`; examples scripts moved to
  `scripts/examples/`.
