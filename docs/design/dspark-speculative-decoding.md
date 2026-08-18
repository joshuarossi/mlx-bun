# DSpark speculative decoding for mlx-bun

Implementation of DeepSeek's **DSpark** ("Confidence-Scheduled Speculative
Decoding with Semi-Autoregressive Generation", `DSpark_paper.pdf`) against this
repo's models. DSpark = a **DFlash** parallel backbone (KV-injected, all γ draft
tokens in one pass) **+ a lightweight sequential head** (Markov, Eq 5, or RNN,
Eq 6) that adds intra-block dependency (the *semi-autoregressive* part) **+ a
confidence head → STS calibration → hardware-aware prefix scheduler**. Decode
becomes draft → verify → accept; output is lossless (bit-identical to the target
at any temperature); only decode speed (τ) changes.

> **DFlash vs DSpark:** DFlash is *only* the parallel backbone (prior work) and
> suffers suffix decay. DSpark adds the sequential head + confidence-scheduled
> verification. The sequential Markov head is what makes this DSpark.

## Two implementations (flag-selected, both in `src/spec/dspark/`)

| | `module.ts` (v1) | `module-dflash.ts` (v2, **the real one**) |
|---|---|---|
| context | **single vector** (final hidden at the anchor) fused as one token | faithful **multi-layer KV injection** (Eq 2–3): H_ctx = RMSNorm(W_c·[H^{l1};…;H^{lm}]) over the FULL context, re-projected into every draft layer's K/V |
| layers | 2 | 5 |
| status | **superseded** — dropped the paper's core idea (kept as baseline) | the actual DSpark model (Markov variant) |

v1 was a shortcut that removed the load-bearing mechanism; it never tested the
paper. v2 is faithful. Checkpoints stamp `variant` in `dspark.json`; the runtime
loads the matching module. (`variant:"dflash"` should be renamed to `"dspark"` —
see Open items.)

## The mechanism (v2, paper Eq 2–3)

- **Eq 2 (context):** tap the target's hidden states at layers `{l1…lm}` (e4b
  default {20,31,41,42}, the last = post-finalNorm), concat on the feature axis,
  project to the draft width: `H_ctx ∈ [L_ctx, d]`. Extraction via a parity-safe
  `model.hiddenTap` (no-op when off) added to `gemma4.ts` `forwardLayers`.
- **Eq 3 (injection):** every draft layer forms `K_i=[W_i^K H_ctx; W_i^K H_d]`,
  `V_i` likewise, `Q_i=W_i^Q H_d`; the γ-block queries attend bidirectionally
  over `[context ++ block]`. Context is read-only memory re-projected fresh each
  layer. The draft projects the target's HIDDEN STATES with its OWN Wk/Wv (not
  the target's K/V — that's the separate `GemmaAssistantDrafter` baseline).
- **Markov head (Eq 5):** `B_k = W1[x_{k-1}]·W2`, r=256, W2=0 init → starts as
  pure DFlash, τ climbs as intra-block dependency is learned.
- **Confidence head (Eq 7):** `c_k = σ(wᵀ[h_k; W1[x_{k-1}]])`.
- **Loss (Eq 9–12):** `0.1·CE + 0.9·TV + 1.0·BCE`, position-weighted.
- **Lossless verify** (`generate-dflash.ts`): greedy = longest-prefix match;
  temp>0 = `min(1,p/q)` accept + residual `norm(relu(p−q))` resample. Growing
  multi-layer H_ctx buffer; rollback via `trim(n, bypass=true)` (physically
  slices the rejected tips past the sliding window — see `gemma4-base.ts`).

## Results & findings (measured, M1 Max 32GB, e4b OptiQ-4bit)

**The architecture is CORRECT — proven by an overfit test.** Trained on 3
articles, eval on the same 3: per-position acceptance **~0.75**, τ **3.24** —
squarely paper-range (0.6–0.9 / τ 3–4). So the faithful DFlash, correctly
implemented, reaches the paper's numbers.

**Getting there required finding a real bug — an off-by-one in the p^t target
alignment** (the TV loss, weight 0.9). Block position k predicts `x_{t+1+k}`,
whose target distribution is `softmax(LM_head(h_{t+k}))`; the data gathered the
hidden at `t+k+1` (shifted forward one). Present in **both v1 and v2** — so every
τ number before the fix was trained against a shifted target. Fixed in
`data-dflash.ts` (`blockIdx = g+k`, k=0..γ-1). Before fix: per-pos ~0.08. After:
~0.17 generalizing, ~0.75 overfit.

**Two things stand between "correct architecture" and "net speedup," now
separated:**
1. **Data.** 160 articles → generalizes only to per-pos ~0.17 (plateaus, doesn't
   climb); overfit on 3 proves capacity. The paper uses 1.3M samples × 10 epochs.
   → needs real data scale.
2. **Target speed (the decisive one).** Spec decode amortizes the fixed draft
   overhead only when the *target forward* is expensive. Measured decode:
   **e4b 45.9 tok/s, 12b 27.5 tok/s, 27B ~15 tok/s.** On fast e4b the draft
   overhead dominates → even τ≈3 nets ~0.4–0.5× (SLOWER). On a slow target (27B,
   ~67 ms/forward) that overhead is a small fraction → the same τ≈3 could land
   ~2–3× (15 → ~35–45 tok/s). **e4b is close to the worst case for spec decode;
   the 27B agentic workload is the ideal target and the real motivation.**

Also confirmed: width is NOT the ceiling (`dDraft=1024` and `2560` both plateau
~0.17 pre-scale); the parity-safe `hiddenTap` doesn't change target numerics;
long-context spec rollback works via the `trim(n, bypass)` physical-slice.

## Serve integration (Phase 1, 2026-07-06)

DSpark is now serve-loadable behind the same `--draft-model` seam as every
other drafter — one verify/accept executor, no lane routing. The seam
(`src/spec/source.ts`) was extended from its two-model-only shape to carry the
target state KV-borrowing drafters need (it previously could NOT host these,
despite the header claiming so):

- `DraftProvider.open({sampler, target:{model,caches}})` — the source gets the
  target model + its live caches.
- `DraftSource.tapLayers?` — when set (DSpark), the serve loop taps the
  target's prefill + every verify forward and hands the captured `[1,L,m*H]`
  context to `prefill(ids, ctxML)` / `commit(n, kAccept, vCtxML)` (ownership
  transfers). `draft(feed, n, stepBase, anchorHidden?)` — the assistant borrows
  the target anchor hidden; DSpark drafts from its growing `H_ctx`.

Provider selection is by artifact kind (`src/server.ts` `detectDraftKind`):
`dspark.json` → **DflashProvider** (`src/spec/dflash-source.ts`), a `*_assistant`
config → **AssistantProvider** (`src/spec/assistant-source.ts`, the optiq
KV-borrowing Gemma drafter — ships a real ~1.09× γ=1 decode win with no
training), else **TwoModelProvider**. `--draft-kind` overrides. The server pins
`--num-draft-tokens` to the DSpark checkpoint's trained block width
(`cfg.gamma`) so the serve loop never asks for more positions than were trained.

**Unified-engine alignment (per-slot readiness).** This is the
`DraftSource` seam the unified-engine plan names as the substrate for its
frontier "per-slot drafting behind the `DraftSource` seam" row
([docs/design/unified-engine-frontier-plan.md](unified-engine-frontier-plan.md)).
Spec still forces the serial lane today (upstream `is_batchable = draft is
None`); Phase 1 did NOT change that — it made the seam *carry per-source target
state* (each source binds its own `TargetView{model,caches}`, anchor hidden,
and tapped H_ctx), which is exactly what a batched executor would need to open
one `DraftSource` per row. So the seam is forward-compatible with per-slot
drafting; the hard part that remains is the executor, not the seam — variable
accept-length per slot breaks a uniform-B step (see
[spec-decode-larger-targets.md](spec-decode-larger-targets.md) caveats), so
per-slot spec is a real batched-scheduler project, not free composition.

**v1 acceptance caveat:** the serve loop verifies with TOKEN-MATCH acceptance
(mlx-lm/optiq style, lossless at any temperature), NOT the paper's
distribution-level rejection-sampling verify. Greedy is identical; temp>0 is
still lossless but lower-acceptance. The richer rejection-sampling verify stays
in the standalone `generate-dflash.ts` (the measure script). See
[[dspark-seam-kv-borrowing]].

## Files
- `src/spec/source.ts` — the extended DraftSource/DraftProvider/TargetView seam.
- `src/spec/assistant-source.ts` / `dflash-source.ts` — the two KV-borrowing providers.
- `src/spec/serve-loop.ts` — the shared verify/accept executor (now tap-aware).
- `src/model/gemma4.ts` — `hiddenTap`/`captureLayer` (parity-safe multi-layer tap).
- `src/model/gemma4-base.ts` — `trim(n, bypass)` on rotating caches (spec rollback past the window).
- `src/spec/dspark/module-dflash.ts` — faithful DFlash+Markov+confidence module.
- `src/spec/dspark/data-dflash.ts` — multi-layer shards, variable-length prefix context, left-pad masking.
- `src/spec/dspark/generate-dflash.ts` — growing-H_ctx lossless decode loop.
- `src/spec/dspark/{loss,sample}.ts` — loss (Eq 9–12) + temp>0 sampling (shared with v1).
- `src/spec/dspark/{module,data,generate}.ts` — v1 single-vector (superseded baseline).
- `scripts/dspark-regen-dflash.ts` / `dspark-train-dflash.ts` (`--resume`) / `dspark-measure-dflash.ts`.
- `scripts/dspark-dflash-smoke.ts` — CPU smoke (16/16). `scripts/dspark-smoke.ts` — v1 smoke (33/33).

## Run sequence (faithful DFlash; GPU = Josh runs)
```
bun scripts/dspark-regen-dflash.ts --topics <topics.txt> --out <data> --max-resp 320
bun scripts/dspark-train-dflash.ts --data <data> --out <ckpt> --iters 8000 --batch 8 [--resume] [--ddraft 2560]
bun scripts/dspark-measure-dflash.ts --drafter <ckpt> --data <prompts.jsonl>   # τ + tok/s vs vanilla
```

## Paper components — Phase 2 (2026-07-06): the paper is CODE-COMPLETE

All remaining components landed the same day (multi-agent build, adversarially
reviewed; smoke 21/21, dspark test files 17/17, real-weights serve gate 3/3):

- **Alg 1, single-user form — confidence-scheduled draft-length pruning.**
  `forwardInfer` drops position k (and truncates the block) when
  `c_k < thresholds[k] ?? minConf`; position 0 always survives. Activation is
  checkpoint-driven: STS thresholds in `dspark.json` (`cfg.sts`) or the
  `MLX_BUN_DSPARK_MINCONF` env override — **uncalibrated checkpoints draft
  fixed-γ exactly as before** (zero behavior change). Losslessness invariant:
  pruning changes how many positions the target verifies, never what's emitted
  (gated: truncation-never-redraw, prefix-identical to the unpruned block).
- **Variable-length draft contract.** `DraftSource.draft()` returns 1..n —
  the RETURN LENGTH is authoritative; the serve loop and `dflashGenerate`
  verify/trim/re-feed over `d = drafts.length`. Two-model/assistant return
  exactly n (unchanged).
- **STS calibration (§3.2.1).** `src/spec/dspark/calibration.ts`
  (`fitStsThresholds`: per position, smallest τ whose Laplace-smoothed
  `P(accepted | conf ≥ τ)` ≥ target; pos 0 → 0, under-sampled → 0 (don't
  prune on thin evidence), unreachable target → 1.0) +
  `scripts/dspark-calibrate.ts` (GPU: greedy unpruned rounds via
  `dflashGenerate`'s `onRound` hook → fit → patch `config.sts` into
  dspark.json in place). ⚠ estimator shape is our reading — paper PDF absent.
- **RNN sequential head (Eq 6 — ⚠ design-doc-faithful shape, paper PDF
  absent, flagged in code).** `cfg.seqHead: "markov"|"rnn"`; Elman recurrence
  `s_k = tanh(s_{k-1}·wH + E[x_{k-1}] + bH)`, `B_k = s_k·wO`, `wO` zero-init
  (starts as pure DFlash, like markov.w2); shares `markov.w1` as the token
  embedding (also feeds the confidence head). Same loss, autograd-gated;
  init-equivalence gate: rnn ≡ markov token-for-token at init.
  Train with `scripts/dspark-train-dflash.ts --seq-head rnn`.
- **Draft loop TIGHTENED** (handoff item 3): greedy tokens chain ON-DEVICE
  (one concat + one host read after the loop, was γ syncs); confidence reads
  deferred+batched when pruning is inactive (per-position only when Alg 1
  needs the answer mid-loop — inherent); `collectLogits: false` on the serve
  path skips the per-position draft-logits materialization entirely
  (`draftLogits` now optional). Gate: bit-identical to the pre-tightening
  loop (pinned reference tokens, tests/dspark-infer-loop.test.ts).
- **Rename + central loader.** Canonical variant is now `"dspark"`
  (`save()` stamps it; `load()` accepts legacy `"dflash"`);
  `src/spec/dspark/loader.ts` `loadDsparkDrafter()` dispatches by variant and
  refuses v1 single-vector checkpoints with a pointer at the v2 trainer. The
  serve path and the bench (`bench-feature-matrix.ts` via the server's
  exported `detectDraftKind`) both go through it.

## DeepSpec ground truth (2026-07-06 audit — paper arXiv:2607.05147 + source)

DeepSeek open-sourced the reference implementation (**DeepSpec**, MIT,
github.com/deepseek-ai/DeepSpec) + trained drafters incl.
**`deepseek-ai/dspark_gemma4_12b_block7`** (for google/gemma-4-12B-it — our
primary target; 6.86 GB bf16 single safetensors, γ=7). Two audit agents
verified our build against the paper AND the source. Verdicts:

- **MATCH the paper exactly:** Eq 2-3 (context + KV injection), the
  anchor++masks block, Eq 5 Markov (r=256), Eq 7 confidence (we add a
  zero-init bias — superset), **Eq 8-12 loss to the letter** (0.1/0.9/1.0,
  w_k=exp(−(k−1)/γ), analytic c*). Our defaults = their production config
  (γ=5, 5 layers, Markov head).
- **Eq 6 RNN differs:** paper is a gated cell over
  `z_k=[s_{k−1}; W₁[x_{k−1}]; h_k]`, fused (2r+d)→3r projection,
  `B_k=W₂ᵀtanh(W_o z_k)` (conditioned on the backbone hidden). Ours is
  ungated Elman without h_k — kept as variant `"rnn"` (paper calls the gains
  "marginal"; production uses Markov); DeepSpec also ships an RNNHead of the
  gated form if we ever want the faithful one.
- **§3.2.1 STS + Alg 1: the paper's machinery is NOT in the released code.**
  STS = Sequential Temperature Scaling (per-position temperatures by ECE grid
  search on cumulative survival products); Alg 1 = expected-throughput
  maximization over survival products with a profiled SPS(B) cost table —
  both live in their UNRELEASED production serving layer. The released
  reference ships **per-position threshold truncation on sigmoid confidence
  (default 0 = off), ℓ=0 allowed** — i.e. the released reference is shaped
  like OUR scheduler. Our threshold fit (`calibration.ts`) is therefore a
  reasonable calibrator for the reference-shaped scheduler, NOT the paper's
  STS; renamed framing in code comments. Paper-faithful STS/Alg-1 = a future
  Lab item if the survival-product scheduler ever earns a default.
- **The reference drafter is a DIFFERENT module than ours:** a full
  Gemma4-shaped 5-layer transformer — hidden 3840, 16 Q heads × head_dim 512,
  **1 KV head with K≡V (`attention_k_eq_v`, no v_proj tensor; scale-less
  v_norm)**, attention scale 1.0 (QK-norm), RoPE partial_rotary 0.25 θ=1e6,
  per-layer learned `layer_scalar`, scaled embed (×√3840, not stored), UNTIED
  lm_head, final softcap 30, and an **incremental context-KV cache** (stores
  projected target-context K/V; crops the block's noise K/V each round).
  Sequential Markov sampling + confidence head (input [h; w1[prev]] = 4096)
  as in the paper. Checkpoint: 74 tensors, bf16, **no key prefix**;
  config.json `architectures: ["Gemma4DSparkModel"]` (loader detection key).
  **12B tap layers: `target_layer_ids [5,17,29,41,46]`** (their layer_id+1
  output convention == our tapLayers index; no final-norm sentinel).
- **THE ORACLE:** their verify is leaky rejection sampling that at
  temperature 0 **degenerates to exact argmax token-match — RNG-free,
  token-for-token deterministic**. Their eval emits per-round
  proposal/accepted/next-token traces. Protocol: run their eval at temp 0
  (+ a threshold arm) on fixed prompts → JSONL round fixtures → our port
  must match round-for-round. Same discipline as the D2 diffusion oracle,
  minus RNG parity entirely.

**Consequence:** DSpark is no longer oracle-less L3. The port of their module
(the `deepspec` variant) + their checkpoint gives a bit-exact-gateable path to
a REAL 12B speedup with zero training. Our own trainable module remains the
research path for custom targets. Training recipe reference: open-perfectblend
regenerated by the target, 10 epochs, batch 512, lr 6e-4, position decay
exp(−pos/4), ~38 TB cached hiddens — i.e. our "thousands of generations" data
estimate was directionally right and their scale is far beyond a laptop run.

## Open items / next

- [x] Serve integration (Phase 1) · [x] Alg-1-shaped scheduler (matches the
  RELEASED reference; paper Alg-1 unreleased) · [x] threshold calibration ·
  [x] RNN head (Elman variant; paper's gated cell differs — documented above)
  · [x] loop tightening · [x] `dspark` rename + loader —
  **everything buildable without a GPU is DONE.**
- [ ] **DeepSpec-variant port** (`Gemma4DSparkModel`) + loader detection +
  oracle scripts — the no-training path to the 12B speedup (in progress).
- [ ] **Josh-gated GPU (the payoff):** real data scale (thousands of
  on-distribution generations) + **retarget to 12B** (`--model` +
  `--tap-layers 5,17,29,41,46` (DeepSeek's trained taps); 27B memory-infeasible to train on 24 GB, kept
  dim-generic) + train (`--seq-head` A/B optional) + **calibrate**
  (`scripts/dspark-calibrate.ts`) + live-τ measure. Recipe:
  [docs/archive/investigations/dspark-handoff.md](../archive/investigations/dspark-handoff.md).
- [ ] Verify the Eq 6 / §3.2.1 shapes against the actual paper when the PDF
  is available (both flagged in code).

Full session handoff: `docs/archive/investigations/dspark-handoff.md`.
