---
status: landed
axis: ON
canonical-for: speculative-decoding
plan-anchor: "Phase 14 — Qwen 3.x family bring-up `[~]`"
last-verified: 2026-08-31
---

# Speculative decoding — one verifier, every draft source

Speculative decoding in mlx-bun is ONE verify/accept executor
(`src/spec/serve-loop.ts`, `specServeRun`) behind ONE seam
(`src/spec/source.ts`, `DraftProvider` / `DraftSource` / `TargetView`), with
every drafter — a second model, a KV-borrowing head, a trained block
drafter, a model-free lookup, a target-native MTP row — differing only in
what fills the draft. Output is the target's own samples at every position;
a drafter can only change decode SPEED (acceptance, tokens per target
forward), never which tokens are emitted. This doc is canonical for the
seam contract, the verifier/rollback contract, the source roster and each
source's oracle, and the DSpark program (our trained drafter + DeepSeek's
released one). Status and changelog prose live in PLAN.md; this doc keeps the
design plus a short dated History.

Consolidated 2026-08-23 from `docs/design/speculative-decoding.md` (base),
`docs/design/speculative-decoding.md` (phases 0–6 + the wall-clock-negative problem
statement) and `docs/design/speculative-decoding.md` (12B assistant γ=1 result).
The DSpark handoff (first live run, recipe) is archived at
[docs/archive/investigations/dspark-handoff.md](../archive/investigations/dspark-handoff.md).

## 1. The seam (`src/spec/source.ts`)

```
DraftProvider   server-lifetime: owns the loaded draft weights
  .open({ sampler, target: { model, caches } }) → DraftSource   (per request)
DraftSource     per request: owns draft-side state
  prefillMode?  "tail-split" (default, mlx-lm shape) | "full" (native MTP)
  pinTargetKernelFamily?   GLM native MTP: one M=1 quantized family across the verify batch
  tapLayers?    layer indices the loop must capture on prefill + every verify forward
  prefill(promptIds, ctxML?)                       seed draft state (ctxML iff tapLayers)
  draft(feed, n, stepBase, anchorHidden?) → 0..n   RETURN LENGTH IS AUTHORITATIVE
  commit(d, kAccept, vCtxML?, verifiedHidden?, acceptedTokens?)
  weightsBytes  admission accounting (0 when the provider owns the weights)
```

- `target` is a read-only view of the target model + its LIVE caches (the
  same arrays the loop drives). Two-model ignores it; every KV-borrowing
  source reads donor K/V, embeddings, lm-head or hidden taps through it.
- `sampler` is the REQUEST sampler (mlx-lm parity: drafts are sampled with
  the same sampler as the target; greedy drafting under a temperature>0
  request is not parity — two-model and both MTP sources honor this; the
  assistant and DSpark sources draft greedily, which is lossless but not
  parity at temp>0).
- `feed` is mlx-lm's re-feed rule (generate.py:645-648): `[correction]` after
  a rejected round, `[lastDraft, bonus]` after an all-accept round.
- `draft()` may return fewer than `n` (DSpark confidence pruning) or ZERO
  (DeepSpec ℓ=0 / ngram no-match): the loop degenerates to one plain target
  step, still tapped and committed for context-growing sources.
- `commit()` ownership: `vCtxML` transfers to the source; `verifiedHidden`
  stays caller-owned.
- Per-slot readiness: each source binds its own target state (donor views,
  anchor hidden, tapped context), which is what a batched executor would
  need to open one source per row. The executor is the hard part — variable
  accept length per slot breaks a uniform-B step — so per-slot spec is a
  batched-scheduler project tracked in
  [unified-engine-frontier-plan.md](unified-engine-frontier-plan.md), not
  free composition. Today a mounted draft forces the serial lane for every
  request (upstream `is_batchable = draft is None`).

## 2. The verifier / rollback contract (`src/spec/serve-loop.ts`)

Faithful to mlx-lm `speculative_generate_step` (generate.py:473-654, read
from the oracle venv). Per round:

1. **Draft** `d ≤ n` tokens (`n = min(γ, tokens left)`), with the anchor
   hidden offered to sources that borrow it.
2. **One target forward** over `[pending, ...drafts]` (d+1 positions),
   tapped when `tapLayers` is set. The lm-head runs ONCE over the whole
   window (batched — matches mlx-lm and optiq; NOT bit-exact to stock
   token-at-a-time decode at bf16 knife-edges, see §2.1).
3. **Accept walk**: sample the target at each position in order through the
   shared `StepSampler` (processors, grammar mask, history — identical
   ordering to the serial and batched lanes); accept while the target's
   token equals the draft's (exact token-match acceptance, NOT
   distribution-level rejection sampling); the first mismatch emits the
   target's correction, an all-accept round emits the bonus. EOS is never
   emitted as content, even when it arrives as an accepted draft.
4. **Emit** the round's tokens through `onToken` one at a time, in order
   (bursts of ≤ d+1), so stop-sequence matching and detokenization see the
   stream `generate()` would produce.
5. **Roll back + commit**: the verify window kept positions `0..kAccept`.
   Trimmable caches `trim(d − kAccept)`; recurrent caches
   `specRoundRollback(kAccept + 1)`; on full accept `specRoundCommit()`.
   Then `source.commit(d, kAccept, vCtxML, vHidden, drafts[0..kAccept))`;
   the next anchor hidden is the verify hidden at the emitted position.
6. **Chain** via the re-feed rule; `pending = emit`.

**Cache rollback contract** (`src/model/gemma4-base.ts` `Cache`):
`trim(n, bypass?)` for trimmable caches; the optional spec-round trio
`specRoundBegin()` / `specRoundCommit()` / `specRoundRollback(keep)` for
non-trimmable recurrent state. `SSMCache` (`src/model/qwen3-delta.ts`,
gated-DeltaNet) implements the trio: the snapshot is free (MLX arrays are
immutable — the layer hands its replaced conv/recurrent refs to the round),
and rollback restores the snapshot then REPLAYS the kept `keep` window tokens
through conv1d + the delta kernel from recorded position-local inputs
(`qkv`/`a`/`b`, retained not copied). Replay is bit-exact by construction:
the kernel's per-thread loop is serial, so the prefix arithmetic is identical
whether or not the rejected tail was processed (gated in
tests/qwen-ssm-specround.test.ts). The loop arms every cache before the
verify forward; a cache that is neither trimmable nor round-capable ends
speculation for the request.

**Deliberate deviations from upstream**

- Rotating-cache ring wrap: upstream RAISES when a `RotatingKVCache` stops
  being trimmable mid-generation (generate.py:529-533); a serve endpoint
  must not 500 mid-stream, so the loop checks `offset + n + 1 < maxSize`
  before each round and, if the window is about to wrap, STOPS SPECULATING
  and finishes with plain single-token decode (bit-equivalent — the
  target's own samples). The standalone `src/spec/generate.ts` loop keeps
  the reference behavior and throws.
- Prompt-cache reuse is BYPASSED on the spec path (fresh caches per spec
  request, `cachedTokens = 0`). mlx-lm composes spec with its LRU prompt
  cache; wiring ours through `PromptCache` + the SSD tier is the open item
  in §8.
- Grammar × spec (novel — no runtime serves both): the drafter runs FREE;
  the grammar mask rides the accept walk in `samplePos` (mask before
  sample; the matcher advances on emitted tokens only, so rejected drafts
  never touch grammar state and no matcher rollback exists). Grammar
  termination mid-burst truncates the round. Gates: greedy grammar+spec ≡
  greedy grammar-only long-prefix + 100% schema validity
  (tests/spec-serve.test.ts).

Telemetry (`usage.speculation`): drafted / accepted / rejected / targetCalls /
rounds / acceptanceLengths / tokensPerForward / forwardsSaved, plus
per-position `draftedByPos` / `acceptedByPos` (the acceptance-A/B report).
`MLX_BUN_SPEC_TRACE=1` prints per-round feed + drafts.

### 2.1 Prefill convention and what "lossless" means here

- **Oracle prefill shape** (`MLX_BUN_PREFILL_TAIL_SPLIT`, default on): mlx-lm's
  speculative path drains BOTH models to len−1 and has NO separate step-0 —
  the un-drained last prompt token HEADS the first verify window, and the
  first emitted token is that window's position-0 sample. A separate L=1
  step-0 is ulp-different from the (1+γ)-window GEMM and flips near-ties.
  Gated live 4/4 token-for-token vs the oracle venv (γ∈{2,3} × 2 prompts,
  including a knife-edge cell). Sources with `prefillMode: "full"` (Qwen
  MTP, GLM MTP) take the full-prompt shape their references use.
- **Batched verify vs stock decode**: both oracles (mlx-lm, optiq) batch the
  verify lm-head, so greedy spec is bit-exact to THE SPEC ORACLE and agrees
  with stock decode only on tie-free prompts. An earlier port verified
  per-position to match stock — a target no real implementation has, at a
  γ× lm-head read tax — and was replaced by `picksBatched`
  (`src/spec/generate.ts`, 2026-06-14). Losslessness gates therefore use
  TIE-FREE prompts (tests/spec-decode.test.ts, spec-serve-assistant,
  qwen38-mtp) or long-prefix agreement (spec-decode-12b): a flip on a
  tie-free prompt is an accept/reject/rollback bug, never rounding.
- **"Lossless" is a claim about the verifier, not the artifact.** The
  Qwen3.8-27B TQ artifact's serve gauntlet recorded MTP at 76% acceptance /
  2.53 tokens per forward WITH an output-divergence flag vs plain greedy
  (consistent with verify-width reduction-order near-ties, the same class as
  the 12B step-0 convention; margin analysis queued) — it is NOT claimed
  lossless on the model card. The 27B bf16-target pairing gate, by
  contrast, was token-identical on its tie-free prompt (PLAN 14g).

## 3. Draft-source roster

`--draft-model <dir>` mounts a drafter; the artifact's KIND selects the
provider (`src/server.ts` `detectDraftKind`; `--draft-kind` overrides).
Detection order: `dspark.json` → `dspark`; `config.json` `architectures[0]
=== "Gemma4DSparkModel"` → `deepspec`; `model_type` containing `assistant` →
`assistant`; `model_type` ending `_mtp` → `mtp`; else `two-model`. `ngram`
is never detected (no artifact) and refuses a `--draft-model`; any other
kind without one is refused. `--draft-kind mtp` with no `--draft-model`
resolves the companion bundled at `<model>/mtp/` (single-repo artifacts) and
refuses otherwise. GLM-5.2's checkpoint-native MTP row mounts by default
(`--mtp on|off`) and is mutually exclusive with an explicit drafter.

| kind | source | what fills the draft | target state used | draft sampler | default γ | oracle / gate |
|---|---|---|---|---|---|---|
| `two-model` | `src/spec/two-model.ts` | a full second model, autoregressive, own KV | none | request sampler | 3 (mlx_lm.server) | **L1**: mlx_lm.server `--draft-model`, same pair, greedy, token-for-token (spec-vs-spec). Draft-cache rewind `max(d − kAccept − 1, 0)`. Tokenizer-family probe at startup refuses mismatches (upstream silently accepts ~0%). |
| `assistant` | `src/spec/assistant-source.ts` (+ `drafter.ts`) | Gemma "-assistant" Q-only 4-layer head | donor K/V (last sliding + last full layer) + anchor hidden, borrowed each step | greedy (own head) | 3 | **L2**: optiq `spec_generate` — e4b γ=2 identical 48-token output AND identical accept/reject trace (drafted 60 / accepted 17 / target calls 31), `scripts/oracle/oracle-spec.py`. Head picked by TENSOR PRESENCE (centroid vs tied-embedding) — optiq's config-based detection loads the 12B/26B unified drafters with zero-init centroids → 0% acceptance; ours 29% on the same artifact. |
| `dspark` | `src/spec/dflash-source.ts` (+ `dspark/module-dflash.ts`) | our trained DSpark block drafter (KV injection + Markov + confidence) | multi-layer hidden tap (`tapLayers`, e4b {20,31,41,42}) grown into H_ctx | greedy | pinned to `cfg.gamma` | **Lab** (no external oracle for our checkpoints): CPU smoke, infer-loop bit-identity pins, real-weights serve gate. See §4. |
| `deepspec` | `src/spec/deepspec-source.ts` (+ `dspark/deepspec-module.ts`) | DeepSeek's released `Gemma4DSparkModel` drafters (e.g. `dspark_gemma4_12b_block7`, γ=7) | tap `[5,17,29,41,46]` on the 12B, projected into an incremental context-KV cache; accepted rows only | argmax (temp-0 reference) | pinned to `block_size` | **DeepSpec reference** at temperature 0: its leaky rejection sampling degenerates to exact argmax token-match, RNG-free — round-for-round trace fixtures (`scripts/oracle/oracle-dspark-deepspec.py`; the compare script was deleted 2026-08-23, git history). |
| `ngram` | `src/spec/ngram-source.ts` | model-free prompt lookup: longest trailing k-gram (max..min) matched at its FIRST earlier occurrence; the continuation is the draft | token history rebuilt from prompt + feed/commit | none | 10 (Saxena `num_pred_tokens`); `--ngram-max 3` / `--ngram-min 1` | Ported from Prompt Lookup Decoding (Saxena) + vLLM `ngram`. Lossless by verify — gated token-identical to non-spec greedy (tests/spec-ngram.test.ts on e4b; tests/qwen35-spec-ngram.test.ts on the 0.8B hybrid, proving real accepts AND real DeltaNet rollbacks). |
| `mtp` | `src/spec/qwen-mtp-source.ts` | Qwen-trained MTP head (`qwen3_5_mtp`, one full-attention layer + `fc` merge; `mlx-community/Qwen3.8-27B-MTP-*`) | target `embed_tokens` + `lm_head` (not standalone) + PRE-final-norm last-layer hidden via `tapLayers = [nLayers−1]`; `prefillMode: "full"` | request sampler | `block_size − 1` (=2) | Reference: mlx-vlm `qwen3_5_mtp` drafter. Draft-logit parity vs mlx-vlm 0.6.14: draft tokens exact through the chained block, worst \|Δlogprob\| 1.9e-1 = bf16-vs-f32 floor. Losslessness: token-identical on the tie-free 27B pairing gate (tests/qwen38-mtp.test.ts, opt-in `MLX_BUN_TEST_QWEN38_MTP=1`). Target rollback = the SSMCache spec-round contract (§2). |
| GLM native | `src/spec/glm52-mtp-source.ts` | GLM-5.2's checkpoint-native MTP row (`enorm`/`hnorm`/`eh_proj` + one decoder layer, int8 routed experts) | target embeddings + output head + anchor hidden; own `MLACache` role `mtp`; `prefillMode: "full"`, `pinTargetKernelFamily` | request sampler | `glmMemoryPlan.mtpDraftTokens` | Direct Colibri (SPEC_PIN contract; "niente prefill" — the first draft opens a decode-only window from the anchor). Commit rebuilds accepted rows from the target's VERIFIED hidden window (only the first speculative row was conditioned on a true hidden). Measured in docs/reference/benchmarks.md "Colibri G4 serial native MTP". |

The `source.ts` header roster lists five of these (two-model, assistant,
dflash, ngram, GLM MTP); `deepspec` and `mtp` are wired in `server.ts` and
the CLI and belong in the same list — this table is the complete roster.

**Row conventions worth knowing.** Qwen MTP is predict-2-ahead: drafter KV
row at position p is built from `(embed(token_{p+1}), hidden_p)`; `draft()`
opens by building the pending token's row from the target's TRUE hidden at
the emitted position (held over from the verify tap), then chains its own
output for the rest of the block; `commit()` trims rejected rows and, on
all-accept, appends the missing accepted row from the verify hidden. The
sampler contract is `[1, V]` — the module output `[1,1,H]` must be
reshaped before sampling or 2-D-slicing samplers (top-k) throw (the
2026-08-20 serve-lane MTP 500; both MTP sources carry the fix).

## 4. DSpark — the trained block drafter

DSpark (DeepSeek, arXiv:2607.05147, "Confidence-Scheduled Speculative
Decoding with Semi-Autoregressive Generation") = a **DFlash** parallel
backbone (KV-injected, all γ draft tokens in one pass) + a lightweight
**sequential head** (Markov, Eq 5; RNN, Eq 6) adding intra-block dependency
+ a **confidence head → calibration → draft-length scheduler**. DFlash alone
suffers suffix decay; the sequential head is what makes it DSpark.

### 4.1 Mechanism (our module, `src/spec/dspark/module-dflash.ts`, paper Eq 2–3)

- **Eq 2 (context):** tap the target's hidden states at layers `{l1…lm}`
  (e4b default {20,31,41,42}, the last = post-finalNorm sentinel at index
  nLayers), concat on the feature axis, project to draft width:
  `H_ctx ∈ [L_ctx, d]`. Extraction is the parity-safe `model.hiddenTap`
  (no-op when off) in `gemma4.ts` `forwardLayers`; `qwen3_5.ts` carries the
  same contract.
- **Eq 3 (injection):** every draft layer forms
  `K_i = [W_i^K H_ctx; W_i^K H_d]`, `V_i` likewise, `Q_i = W_i^Q H_d`; the
  γ-block queries attend bidirectionally over `[context ++ block]`. The
  draft projects the target's HIDDEN STATES with its OWN Wk/Wv (not the
  target's K/V — that is the assistant drafter).
- **Markov head (Eq 5):** `B_k = W1[x_{k−1}]·W2`, r=256, W2 zero-init →
  starts as pure DFlash, τ climbs as intra-block dependency is learned.
- **Confidence head (Eq 7):** `c_k = σ(wᵀ[h_k; W1[x_{k−1}]])` (we add a
  zero-init bias — superset).
- **Loss (Eq 8–12):** `0.1·CE + 0.9·TV + 1.0·BCE`, position weights
  `w_k = exp(−(k−1)/γ)`, analytic c*. Audit verdict: matches the paper to
  the letter; our defaults (γ=5, 5 layers, Markov) = their production
  config.
- **RNN head (`cfg.seqHead: "rnn"`)**: ungated Elman
  `s_k = tanh(s_{k−1}·wH + E[x_{k−1}] + bH)`, `B_k = s_k·wO` (wO zero-init;
  init-equivalent to Markov). The paper's Eq 6 is a gated cell over
  `[s_{k−1}; W₁[x_{k−1}]; h_k]` — ours differs, kept as a variant (paper
  calls the RNN gains marginal; DeepSpec ships the gated form if ever
  wanted).
- **Confidence-scheduled pruning (Alg 1, single-user form)**: `forwardInfer`
  drops position k (and truncates the block) when
  `c_k < thresholds[k] ?? minConf`; position 0 always survives. Activation is
  checkpoint-driven (`cfg.sts` thresholds) or `MLX_BUN_DSPARK_MINCONF`;
  uncalibrated checkpoints draft fixed-γ. Invariant: pruning changes how
  many positions the target verifies, never what is emitted (gated:
  truncation-never-redraw, prefix-identical to the unpruned block).
- **Calibration (`src/spec/dspark/calibration.ts`)**: per position, the
  smallest threshold whose Laplace-smoothed `P(accepted | conf ≥ τ)` meets
  the target; pos 0 → 0; under-sampled → 0; unreachable → 1.0. This fits the
  RELEASED reference's scheduler shape (per-position threshold truncation on
  sigmoid confidence, default 0 = off, ℓ=0 allowed). The PAPER's §3.2.1 STS
  (per-position temperatures by ECE grid search on survival products) and
  Alg 1's throughput maximization over a profiled SPS(B) table live in
  DeepSeek's UNRELEASED serving layer — paper-faithful STS/Alg-1 is a Lab
  item only if the survival-product scheduler ever earns a default.
- **Verify**: the serve loop's token-match acceptance (§2). The standalone
  `generate-dflash.ts` keeps the paper's distribution-level verify
  (`min(1, p/q)` accept + residual `norm(relu(p−q))` resample) for the
  measure path; greedy is identical, temp>0 is lossless either way but
  token-match accepts less.
- **Rollback past the sliding window**: `trim(n, bypass=true)` physically
  slices rejected tips on rotating caches (`gemma4-base.ts`).
- **Checkpoint format**: `dspark.json` stamps `variant: "dspark"` (legacy
  `"dflash"` accepted); `src/spec/dspark/loader.ts` `loadDsparkDrafter()`
  dispatches by variant and REFUSES v1 single-vector checkpoints
  (`module.ts`/`data.ts`/`generate.ts` — the superseded baseline that
  dropped KV injection) with a pointer at the trainer.

### 4.2 The v1 → v2 finding (why "faithful" matters)

v1 fused a single final-hidden vector as one token — it removed the paper's
load-bearing mechanism and never tested it. v2 is faithful. Getting v2 to
paper-range required an off-by-one fix in the TV-loss target alignment
(block position k predicts `x_{t+1+k}` whose target is
`softmax(LM_head(h_{t+k}))`; the data gathered `t+k+1`) — present in both
v1 and v2, fixed in `data-dflash.ts` (`blockIdx = g+k`). Overfit on 3
articles: per-position acceptance ~0.75, τ 3.24 (paper range 0.6–0.9 / τ
3–4) — the architecture is correct. 160 articles generalize to ~0.17 and
plateau; width is not the ceiling (`dDraft` 1024 and 2560 both plateau);
the paper trains on 1.3M samples × 10 epochs. (M1 Max 32 GB, e4b
OptiQ-4bit, 2026-06-30.)

### 4.3 DeepSpec — the released reference, and why DSpark has an oracle

DeepSeek open-sourced DeepSpec (MIT) + trained drafters incl.
`deepseek-ai/dspark_gemma4_12b_block7` (6.86 GB bf16, γ=7, for
gemma-4-12B-it). Their drafter is a DIFFERENT module from ours: a full
Gemma4-shaped 5-layer transformer — hidden 3840, 16 Q heads × head_dim 512,
1 KV head with K≡V (`attention_k_eq_v`, no v_proj), scale 1.0 (QK-norm),
partial RoPE 0.25 θ=1e6, per-layer `layer_scalar`, scaled embed (×√3840),
UNTIED lm_head, final softcap 30, incremental context-KV cache. 74 bf16
tensors, no key prefix, `architectures: ["Gemma4DSparkModel"]`. 12B tap
layers `[5,17,29,41,46]` (their layer_id+1 output convention == our
`tapLayers` index; no final-norm sentinel). Ported verbatim in
`deepspec-module.ts` (transcribe their forward, then op-for-op), with
context rows cached post-norm-post-rope (bit-equivalent to their in-round
concat; argued in `projectContextKV`). Argmax is over the bf16 sum — an f32
sum reorders near-ties vs torch.

Consequence: DSpark is no longer oracle-less. The DeepSpec port + their
checkpoint is the no-training path to a 12B speedup, gateable
round-for-round at temp 0. Our trainable module remains the research path
for custom targets. Their training recipe (for scale reference):
open-perfectblend regenerated by the target, 10 epochs, batch 512, lr 6e-4,
~38 TB cached hiddens.

The drafter also loads QUANTIZED: `scripts/dspark.ts quantize` writes an
mlx-native affine sibling (`src/spec/dspark/quantize-drafter.ts`: every 2-D
matmul weight + `embed_tokens`/`markov_w1` as quantized-gather tables;
`confidence_head`, norms, `layer_scalar`, biases stay bf16 — the mlx
`false` convention), and `deepspec-module.ts` detects `.scales` siblings and
routes through `quantized_matmul` / QuantizedEmbedding gather-dequant
(mlx-lm numerics). 8-bit tracks bf16 token-for-token on the synthetic
checkpoint. Drafter numerics only move ACCEPTANCE, never correctness, so the
entire quality gate for any drafter quantization is one acceptance A/B.

### 4.4 The wall-clock problem (why spec is opt-in)

Spec decode amortizes fixed draft overhead only when the TARGET forward is
expensive. The recurring finding across every drafter and target:

- **e4b is near the worst case** (fast target): assistant γ=2 ran 0.78× of
  a 54 tok/s baseline at ~23% acceptance (Phase 6, 2026-06-10); even a τ≈3
  DSpark drafter nets ~0.4–0.5×.
- **12B assistant γ=1 is a modest win** — see History 2026-06-14.
- **12B + DeepSpec block7 (first live run, 2026-07-07, loaded M4 Pro
  24 GB, directional only):** τ ≈ 2.8 committed tokens per target forward
  at 26–33% per-token acceptance (the predicted OptiQ-4bit-target
  degradation vs their bf16 training) — the algorithm WORKS — but
  wall-clock LOST ~3.4× (spec 14.6 vs serial 49.8 aggregate tok/s, conc-4).
  The tax is the drafter: 6.9 GB bf16 → ~3 GB of weight reads per round
  (2 GB untied lm_head + 7 × 134 MB markov_w2 + layers), ~14 host syncs
  per round in the transcription-faithful `draftBlock`, tapped verifies
  falling back to the unoptimized monolith, and ~14 GB of paired weights
  on a 24 GB box.
- **27B + Qwen native MTP (2026-08-18, quiet M1 Max 32 GB, interleaved
  off/on ×3, spreads 2.2%/4.4%, arms token-identical):** median OFF 15.75
  vs ON 12.93 tok/s — 0.821× at γ=2 despite 61% acceptance and 2.25
  tokens/forward. The bf16 head's serial per-draft cost (full-vocab lm-head
  matmul + sample per draft) exceeds the saved 27B forwards. Levers if
  reopened: quantize the head; batch/defer its per-draft lm-head sampling.
- **GLM-5.2 native MTP (M1 Max 32 GB, Colibri G4):** 1.235× wall
  throughput, 32/92 accepted, 2.065 tokens per verify forward — the one
  measured wall-clock win, on a target whose forward is expensive enough
  (docs/reference/benchmarks.md).

Doctrine: a lone request must never get slower because a flag exists; spec
stays opt-in per (target, drafter) pair until it wins a clean-machine
paired A/B; losing configs stay documented default-off. Denominator
discipline: speedups only ever vs the SAME model's non-spec baseline.

### 4.5 The DSpark serving program (12B) — phases and gates

Goal: spec ≥ 1.3× serial decode on 12B at the best config, clean-machine
paired A/B — then decide when it is on by default. Objective stated right
(Josh, 2026-07-07): 26–33% acceptance with the bf16 drafter is the
WORKABLE baseline (τ≈2.8 already pays in forwards); the question
quantization must answer is PRESERVATION — do we keep that number at
4-bit? Sensitivity is MEASURED, never guessed: optiq's method (simulate-quant
one group → KL vs reference on a calibration mix → greedy knapsack to target
bpw), cheaper on the drafter because cached tapped hiddens remove the 12B
from the sweep loop. TurboQuant's role is better-quant-at-EQUAL-bits (finer
levels around the Gaussian peak) — a preservation instrument, measured at
equal bpw before any lower rung.

| phase | what | state |
|---|---|---|
| 0a | oracle-gate the bf16 DeepSpec port ONCE (round-for-round vs their temp-0 trace on the bf16 HF 12B; OptiQ arm acceptance-only) | open (Josh: torch venv + GPU) |
| 0b | γ sweep {2,3,5,7} at conc 1 → per-γ tok/s / acceptance / TTFT table | open |
| 0c | time attribution (draft GPU / draft host syncs / verify / tap+commit; paging check) — orders phases 1–3 by measured value | open |
| 1a | `scripts/dspark.ts quantize` | done 2026-07-07 |
| 1b | quantized forward in `deepspec-module.ts` | done 2026-07-07 |
| 1c | `scripts/dspark.ts ab` — same target, same ≥32 prompts, temp 0, drafter A vs B; per-position acceptance, τ, tok/s, paired verdict (drop ≤ 3 pts AND wall-clock strictly improves); stats in `ab-stats.ts`, unit-tested | done 2026-07-07 |
| 1d | RUN 4-bit vs bf16 at best-γ | open (GPU) |
| 1e | measured sensitivity map (optiq's method on cached hiddens) → knapsack allocation → one confirming A/B | open |
| 1.5 | OPTIONAL acceptance upside: adaptation fine-tune on OUR target's tapped hiddens (their checkpoint as init; gradient in their torch trainer vs a local path — undecided); threshold sweep at 26% (objective = tok/s, not τ); target-fidelity axis measurement | open |
| 2 | tighten `Gemma4DSparkModel.draftBlock`: on-device token chaining (one host read per round), compute no confidence at threshold ≤ 0, skip unread `baseLogits`; gate = bit-identity on the synthetic checkpoint + real-checkpoint determinism | open |
| 3 | `captureLayer` in the generated Gemma forwards (`scripts/gen-model.ts`) so tapped prefill/verify keep the fast path; drop the `hiddenTap !== null` fallback guard; regen 12b/26b/e4b; gate = generated-parity + tap-parity + spec bench | open (guard still present 2026-08-23) |
| 4 | serving UX on 0–3 data: per-kind γ default (trained γ is the cap, not necessarily the default), quantized-drafter UX (`mlx-bun get` → quantize), spec × prompt-cache composition, surface audit (`/stats` drafter+kind+γ; server-config "speculative serving" section), the default decision per pair written down | open |
| 5 | TurboQuant weight scheme for the drafter: TQ-4 vs affine-4 AT EQUAL BPW through the 1c harness (headline); lower rungs only after that is won; method (TQ vs affine) and allocation (knapsack) are orthogonal axes, never mixed within an artifact; per-tensor mixed rungs from the measured table (lm_head ~2 GB read fully per round; embed ~2 GB gather-only; markov_w2 134 MB ×7) | open |
| 6 | clean-machine protocol → promote to benchmarks + default decision; close or re-defer loose ends (gated RNN head, paper Alg-1/STS, per-slot spec) | open |

Exit criteria: (1) ≥ 1.3× on 12B clean-machine paired, or a written verdict
that it cannot be reached and why; (2) acceptance PRESERVED and understood
(the quantized drafter holds the bf16 baseline, or the mixed rung that does
is adopted, or the loss is measured and accepted); (3) the
acceptance-per-byte curve exists (TQ vs 4-bit vs mixed vs bf16); (4) the
surface is documented, defaults decided per pair, and `mlx-bun get` →
serve → speedup works without reading a design doc.

### 4.6 The 27B program (Qwen3.8, 2026-08-19)

The TurboQuant-weights campaign's 17 GB Qwen3.8-27B (~11.8 tok/s decode,
2026-08-19) is the slow-target regime where τ≈3 nets 2–3×, and it retires
the "27B infeasible to train on 24 GB" premise: with the quantized trunk
FROZEN (inference-only taps + teacher logits) and only the ~5-layer drafter
holding grads/optimizer state, drafter training fits a 32 GB machine.
Verify/rollback across the 48 DeltaNet layers is proven engine behavior
(§2). Two tracks, cheap-first, queued behind the certification suite's GPU
ownership (PLAN.md TurboQuant-weights phase, "Queued follow-ups"):

- **Track A — confidence-scheduled verification on the stock MTP head (no
  training).** Dynamic per-step block length: v0 confidence = the draft's
  own token probability, mapped through the `scripts/dspark.ts calibrate`
  pattern to expected acceptance; stop drafting when marginal
  expected-accept drops below the verify amortization point. Calibration
  data = thousands of (confidence, accepted?) pairs from served traffic.
  Gate: paired A/B tok/s vs fixed-γ MTP; lossless by construction.
- **Track B — true DSpark drafter for the 27B.** The faithful v2 retargeted:
  tap-layer selection for the 64-layer trunk (bias toward the 16
  full-attention layers + post-finalNorm), data by TEACHER-FORCED passes
  over corpus text with the frozen trunk (every position yields a sample).
  Open idea: initialize/distill against the shipped MTP head. Gate:
  generalizing per-position acceptance must beat the MTP head's 0.68 or
  Track B is dropped for Track A + MTP.

Drafts trained on the TQ artifact are married to its rotation basis (card
note if published). `RadixArk/Qwen3.8-27B-DSpark` exists as a cross-check
candidate (PLAN 14h, optional).

## 5. Files

- `src/spec/source.ts` — the seam. `src/spec/serve-loop.ts` — the executor.
- Sources: `two-model.ts`, `assistant-source.ts` (+ `drafter.ts`),
  `dflash-source.ts`, `deepspec-source.ts`, `ngram-source.ts`,
  `qwen-mtp-source.ts`, `glm52-mtp-source.ts`.
- `src/spec/generate.ts` — the standalone optiq-oracled assistant loop
  (`specGenerate`, full-prompt prefill, throws on ring wrap).
- `src/spec/dspark/`: `module-dflash.ts` (our module), `deepspec-module.ts`
  (DeepSeek's), `loader.ts`, `data-dflash.ts`, `generate-dflash.ts`,
  `loss.ts`, `sample.ts`, `calibration.ts`, `quantize-drafter.ts`,
  `ab-stats.ts`; `module.ts`/`data.ts`/`generate.ts` = v1 baseline (refused
  for serving).
- `src/model/gemma4.ts` `hiddenTap`/`captureLayer`; `src/model/qwen3_5.ts`
  `hiddenTap`; `src/model/gemma4-base.ts` `Cache` (`trim(n, bypass)`, the
  spec-round trio); `src/model/qwen3-delta.ts` `SSMCache.specRound*`.
- `src/server.ts` `detectDraftKind` / `loadContext` (provider selection, γ
  pinning, tokenizer probe, fail-fast pairing probe-open, admission).
- `scripts/dspark.ts <train|regen|calibrate|quantize|ab>` — the DSpark
  pipeline (one dispatcher, jobs in `scripts/dspark/`):
  ```
  bun scripts/dspark.ts regen --topics <topics.txt> --out <data> --max-resp 320
  bun scripts/dspark.ts train --data <data> --out <ckpt> --iters 8000 --batch 8 [--resume] [--ddraft 2560] [--seq-head rnn]
  bun scripts/dspark.ts calibrate --drafter <ckpt> --data <prompts.jsonl>
  bun scripts/dspark.ts quantize <drafter-dir> [--out <dir>] [--bits 4|8] [--group-size 32|64]
  bun scripts/dspark.ts ab --target <id|dir> --drafter-a <dir> --drafter-b <dir> [--num-draft-tokens N] [--n-prompts 32] [--max-drop 3]
  ```
  (The standalone measure/compare/bench one-offs — `dspark-measure-dflash`,
  `dspark-deepspec-compare`, `spec-bench`, `spec-dump`, `qwen38-mtp-ab` —
  were deleted 2026-08-23; git history.)
- Oracles: `scripts/oracle/oracle-spec.py` (optiq spec_generate),
  `scripts/oracle/oracle-dspark-deepspec.py` (DeepSpec temp-0 trace),
  `scripts/oracle/oracle-qwen38-mtp-logits.py` (mlx-vlm drafter logits).
- Tests: `spec-decode.test.ts` (e4b assistant, exact + knife-edge),
  `spec-decode-12b.test.ts` (long-prefix rollback gate), `spec-serve.test.ts`
  (L1 knife-edge, grammar × spec), `spec-serve-assistant.test.ts`,
  `spec-ngram.test.ts`, `qwen35-spec-ngram.test.ts`,
  `qwen-ssm-specround.test.ts`, `qwen38-mtp.test.ts` (opt-in),
  `dspark-{smoke,infer-loop,rnn,calibration,deepspec,ab-stats}.test.ts`.
- User-facing mirror: docs/reference/server-config.md (`--draft-model`,
  `--draft-kind`, `--num-draft-tokens`, `--ngram-*`, `--mtp`,
  `MLX_BUN_PREFILL_TAIL_SPLIT`, `MLX_BUN_DSPARK_MINCONF`), cli.md,
  docs/reference/server-config.md.

## 6. Composition rules (as served)

- A mounted draft routes EVERY request to the serial lane (B=1 latency
  mode).
- Quantized KV (any axis) wins over spec: drafted requests decode serially
  WITHOUT speculation, with a startup warning (spec lane is bf16-KV-only).
- Structured output composes (the constrained verify walk).
- Prompt-cache reuse is bypassed on the spec path.
- Native GLM MTP and an explicit `--draft-model`/`--draft-kind` are mutually
  exclusive; one provider per request so two draft histories never advance
  target or grammar state twice.

## 7. Token fast-forwarding — lookup, not speculation

**No draft/verify contract is involved.** Nothing in this section routes
through `src/spec/`; there is no drafter, no verify forward, no rollback, and
no comparison against what the model "would have" produced. It is filed here
only because the spec lane is the neighbouring mechanism and the two are
routinely confused. The one fact borrowed from it is that a multi-token
mid-decode append works — which the grammar jump-forward burst already proved.

**The doctrine.** A transformer is a next-token function over a token
sequence. It has no memory of who wrote which token, so an APPENDED token is
indistinguishable from a sampled one: injection is pure context extension. When
the engine already knows the next *m* tokens, consulting the model for them
buys nothing — it writes them into the KV itself with ONE chunked forward and
resumes sampling after them. The model is consulted only for tokens it does
not already know.

**What "already knows" means (strict tier, the only one built).** A request's
`tools` array plus the model's own chat template determine large parts of the
assistant turn: the tool-call opening scaffold, the remainder of a tool name
after its first disambiguating token, the punctuation from the name to the
arguments object, and — when the schema has exactly one required property —
the argument key itself. Those spans are compiled per request by **scaffold
probing**: render the same conversation several ways, tokenize each, and diff
the token id sequences. What does not change is the template's fixed scaffold,
by construction. The compiler knows nothing about tool-call syntax: Qwen3.5's
`<function=NAME>`/`<parameter=KEY>` XML, a JSON `<tool_call>` template, and
GLM's `<arg_key>`/`<arg_value>` all compile through the same diff, and a
template that does not render `tool_calls` (or renders them without the name)
produces identical probes, an empty diff, and no rows — degrade to no-fill,
never wrong output. Same technique as `request-prep.ts::stableLenFor` uses on
the generation primer, applied to the assistant turn.

**Why it is safe.**
- **Every span is sliced from a rendering the model could actually produce** —
  real tool names, real schema keys. The diff only decides WHERE to cut; the
  ids always come from the real-name rendering, so every cut is a token
  boundary of a producible stream. This is not a stylistic preference. Qwen3.5
  renders `<function=get_weather>`, which the tokenizer encodes as
  `< function =get _weather >` — `=get` is ONE token. A probe named
  `zzalphatoolqq` splits the same position as `… = zzalpha…`, inventing a
  boundary after `=`. A scaffold row cut there injects a bare `=`, the model
  then emits `get` where it would have emitted `=get`, and the result is
  byte-identical TEXT over divergent token IDS — with KV that no longer
  matches what a plain decode would have written. Caught on Qwen3.5-0.8B
  (2026-08-31); the regression gate is id containment, not text containment
  (`tests/unit/fill-schema-rows.test.ts`, `tests/parity/fill-strict.test.ts`).
  With one tool the whole header through the sole key is one span; with
  several, the scaffold ends exactly where the real merged name tokens diverge
  (`=get` vs `=search`) and per-tool name rows resume from there.
- Never `encode(fragment)` in isolation — same reason.
- Every row is anchored at a token carrying LETTERS (e.g. `<tool_call>`,
  `</parameter`), with leading template-join whitespace dropped from the
  trigger. Markup alone is not enough: `</` opens every closing tag a model
  might write in prose or a code block, so arming on it would inject tool-call
  markup into an HTML snippet.
- A close row exists only when EVERY tool in the request takes exactly one
  required argument — otherwise the model may still be about to write a second
  `<parameter=…>`, and injecting the close would silently drop it. The
  request's own schema decides whether the row exists.
- Ending the turn stays the model's decision: every span is cut at the first
  EOS id (the grammar jump burst's missing EOS check is deliberately not
  inherited).
- A span shorter than 2 ids is rejected — it would save no forward.
- The cache-alignment invariant: the fill forward carries ONLY the injected
  ids. The normal step already consumed the trigger token and wrote its KV;
  forwarding `[trigger, ...ids]` would duplicate a position and silently
  corrupt both the KV and `PromptCache.put`'s key. `MLX_BUN_FILL_TRACE=1`
  asserts `cache[0].offset === promptTokens.length + forwarded.length` on both
  sides of every append.
- Injected tokens flow through `CompletionSink.push` one at a time, in the
  same shape as the jump burst, so `StopMatcher` fires mid-burst exactly where
  it would have. The append happens BEFORE any of the burst's yields, which is
  what makes a consumer break mid-burst safe — `forwarded` already describes
  the cache exactly.

**The deviation, stated plainly.** Injection bypasses the sampler. At
`temperature > 0` a filled reply is not the same draw an unfilled one would
have been (the sampler is never asked about those positions). That is a
behavior-policy deviation, not a numerics one, and it is why the feature is
opt-in (`MLX_BUN_FILL=strict`, default off). At `temperature 0` the strict
tier is token-identical by construction; the weights gate is
`tests/parity/fill-strict.test.ts`.

**Mechanism.** `src/generate.ts::generateInner` — the same burst shape as the
grammar `jumpEmit` branch, with the DEFERRED trigger (fill reads the token the
pipelined loop already read back; it does not add grammar's eager readback).
On an ASSERT fill the in-flight sample for the next position is dropped
unexamined — a discarded pipeline dispatch, counted as `wastedSamples`, not a
rejected draft. Grammar and fill are forbidden in the same iteration
(asserted).

### 7.1 One interface, two policies (`src/fill/proposal.ts`)

Every source that can propose the next tokens implements one interface, and
one apply primitive in the decode loop hosts both policies — because the
EXPENSIVE half is identical: one chunked forward advancing the KV (and the
recurrent SSM state) over the whole span.

```ts
interface ProposalSource { propose(tail: TokenView): Proposal | null }
interface Proposal { ids: number[]; policy: "assert" | "verify"; origin: … }
```

- **assert** — the tokens are DETERMINED (a template scaffold). Append and move
  on: no readback, no checkpoint, no rewind. Strict rows are always assert.
- **verify** — the tokens are LIKELY (a session self-copy). Position 0 is
  checked BEFORE the forward against the in-flight sample — free, and a
  mismatch costs nothing because nothing has been written yet. Positions
  1..m−1 are checked against the argmax already sitting in THAT SAME forward's
  logits, so verification adds no pass over the weights. The rejected tail is
  rewound and decode resumes at the first disagreement, which reproduces
  exactly the stream an unfilled run would have produced. A wrong guess costs
  a rewound forward, never a wrong token.

**Rewind reuses the spec lane's cache contract, not its executor.** Trimmable
caches drop the tail with `trim(n)`; NON-trimmable recurrent caches (SSMCache —
gated-DeltaNet conv + recurrent state) go through `specRoundBegin()` before the
forward and `specRoundRollback(keep)` after the accept walk, which restores the
pre-round snapshot and bit-exactly REPLAYS the accepted prefix (§2). Those are
plain `Cache`-interface methods driven by the owning layer, so nothing in
`src/spec/serve-loop.ts` is touched. A model whose caches can do neither still
gets assert fills; verify proposals are dropped and counted
(`usage.fill.verifyUnsupported`). Checkpointing is real work (~48 DeltaNet
states on Qwen3.8) and is measured: `usage.fill.checkpointMs`.

**Not migrated (deliberate).** The shipped `DraftSource` roster (ngram, MTP,
two-model, DSpark) keeps its own seam and executor. The adapter — a DraftSource
wrapped as a verify-policy ProposalSource, so one apply primitive serves both
lanes — is future work; rewiring it here would have put the spec lane's oracles
at risk for no new capability.

### 7.2 The echo tier (K3c, Lab, `MLX_BUN_FILL=echo`)

A growing per-request k-gram index over promptIds plus everything emitted
(injected tokens included — the model cannot tell them apart, so neither does
the index). The structure is the TS port of `GrowingMatcher` from the corpus
study: sequence + k-gram → positions, appended incrementally, bucket scan
capped at the NEAREST occurrences (`src/fill/echo-index.ts`).

The lookup is the boring half. The **stopping rule** is the measurement that
made the tier worth building:

- **Branch-point stopping.** A match says where this context occurred before;
  it says nothing about how far the future agrees with the past. So a span
  extends only while EVERY nearby occurrence continues the same way, and stops
  the moment they disagree. That fork is exactly where old-query-vs-new-query
  divergence lives, and delimiters fall out for free — a closing quote is where
  histories fork.
- **Corroboration decides the policy.** `assert` requires (a) no branch stop,
  (b) the span ends at a delimiter-class token, AND (c) at least TWO
  occurrences agreed across the whole span. A single occurrence is a copy, not
  a pattern: it will happily replay whatever followed it in the transcript —
  including another role's turn — so it is the model's call. Verified on the
  0.8B tokenizer against a synthetic agent transcript: an uncorroborated copy
  ran 30 tokens past `</tool_call>` into a mocked tool RESULT. Under verify
  that costs one rewound forward; under assert it would have been wrong
  output. Everything else is `verify`.
- **Delimiters** are read off the template by the strict-row compiler (the
  first non-whitespace token that follows an argument value — `"` for JSON,
  `</` for Qwen3.5's XML). They clamp ECHO spans only: a strict scaffold
  legitimately contains the same tokens as structure (`{"name": "` is three
  quotes deep) and is determined by construction.

Deterministic value transforms (url-encode, JSON-escape) as
`(source-span, transform)` table entries are NOT implemented — the seam is the
same `ProposalSource` interface, and the corpus rates that motivate them are in
PLAN K3.

The bar for this tier is NOT token identity (sampling never guaranteed that):
it is a paired A/B on task success and wall clock over mocked-replay agent
sessions. Default off until that lands.

**Composition.** Serial lane only, and it never FORCES a request serial — a
batch-placed request simply does not fill, because `generate()` is the only
site that reads `options.fill`. Refused for: a compiled grammar (forced tokens
are its job), `logprobs`/`top_logprobs` (injected tokens have no distribution
row — the same rule as `shouldUseGrammarJump`), a user-fixed `seed`
(reproducibility: the step index would skip injected positions), media
prompts, a mounted draft model, quantized/TurboQuant KV (post-conversion
multi-token append is L-generic but unvalidated), and sliding-window models
(RotatingKVCache multi-token append is O(window) via `#updateConcat` — one
warning, then no fill).

**Mismatch policy.** If `parseGeneratedToolCalls` rejects the emitted markup
on a request whose rows fired, `usage.fill.parseFallback` increments and
strict rows disarm. Today the served parse runs at sink flush, i.e. after the
generation ends, so within one request this is telemetry; the seam is wired so
an incremental parse (or a plan cached across requests) disarms for real.

**Files.** `src/fill/proposal.ts` (the interface + the two policies),
`src/fill/fill-session.ts` (sources, clamping, flags, telemetry),
`src/fill/schema-rows.ts` (scaffold probing + value delimiters),
`src/fill/echo-index.ts` (k-gram index + branch-point rule), the apply
primitive in `src/generate.ts`, `fillPlanFor` in `src/serve/request-prep.ts`,
the attach + serve-level refusals in `src/serve/chat-stage.ts`, `usage.fill` in
`src/serve/{completion-executor,openai-wire}.ts`. Tests:
`tests/unit/fill-{session,schema-rows,echo-index,generate-loop}.test.ts`,
`tests/serve/fill-{composition,stream}.test.ts`,
`tests/parity/fill-strict.test.ts` (weights-gated).
User-facing mirror: `docs/reference/server-config.md` (`MLX_BUN_FILL`,
`MLX_BUN_FILL_MAX_SPAN`, `MLX_BUN_FILL_TRACE`, `MLX_BUN_FILL_K`,
`MLX_BUN_FILL_CANDIDATES`, `MLX_BUN_FILL_INDEX_MAX`), `server-api.md`
(`usage.fill`).

## 8. Open items

- DSpark serving program phases 0, 1d, 1e, 1.5, 2, 3, 4, 5, 6 (§4.5) —
  every GPU measurement is Josh's shell; Phase 3 (generated-forward tap)
  and Phase 2 (draftBlock tightening) are agent-runnable.
- 27B Track A / Track B (§4.6; PLAN.md boxes) + 14h DSpark cross-check.
- Spec × prompt-cache composition (serve-loop v1 bypass).
- Per-slot spec under batching (unified-engine frontier row, not this
  program).
- Qwen MTP wall-clock: head quantization / deferred per-draft lm-head
  sampling (the 0.821× verdict's levers); the TQ-artifact divergence-flag
  margin analysis (§2.1).
- Assistant drafter γ≥2 on 12B: the 262k tied-embedding argmax per draft
  step is the dominant cost; capping/approximating it could extend the win
  past γ=1. 26B-MoE unmeasured (expected loss — decode reads top-8/128
  experts, so per-token target cost is lower than its size).
- Optional `strictVerify` (per-position verify, "spec output identical to
  spec-off") — a product nicety no oracle provides; not implemented; ask.
- Verify the Eq 6 / §3.2.1 shapes against the paper PDF (both flagged in
  code); paper-faithful gated RNN head and survival-product scheduler stay
  Lab items.

## History

- **2026-06-10** — e4b assistant drafter measured a net loss (γ=2 0.78× of
  54 tok/s, ~23% acceptance); spec ships default-off.
- **2026-06-14** — `docs/design/speculative-decoding.md` result: the verify path
  had targeted the WRONG oracle (per-position lm-head to match stock decode;
  no real implementation does this) — fixed with `picksBatched`, now
  bit-exact to optiq `spec_generate` on e4b γ=2 (identical output and
  accept/reject trace). 12B + `gemma-4-12B-it-assistant-bf16`, batched
  verify, loaded machine (paired ratios only): γ=1 **1.09×** (42%
  acceptance), γ=2 0.91× (29%), γ=3 0.72× (23%), γ=4 0.56× (17%) — the
  earlier "net loss at every γ" (0.96/0.77/0.67/0.52×) was partly the
  wrong-oracle tax. γ≥2 loses because the 12B drafter is heavy (hidden
  1024, 16 heads, 262k tied head per draft step). Clean-machine rerun
  never promoted; 26B not run.
- **2026-06-29/30** — DSpark v1 (single-vector, superseded) then faithful
  v2 (KV injection + Markov + confidence) built; TV-loss off-by-one found;
  overfit τ 3.24 proves the architecture (M1 Max 32 GB, e4b).
- **2026-07-06** — Serve integration: the seam extended to carry target
  state (TargetView, tapLayers, ctx flow); provider selection by artifact
  kind; γ pinned to the trained block. Paper components code-complete
  (pruning, calibration, RNN variant, loop tightening, `dspark` rename +
  loader). DeepSpec audit: our loss/heads match the paper; the released
  scheduler is threshold-truncation, not the paper's STS/Alg-1; DeepSpec's
  temp-0 trace becomes the oracle. Tests 21/21 smoke, 17/17 dspark files,
  3/3 real-weights serve gate.
- **2026-07-07** — DeepSpec port first live run on 12B (τ≈2.8, 26–33%
  acceptance, wall-clock −3.4× on a loaded M4 Pro 24 GB); the serving
  program written; 1a/1b/1c landed the same day; oracle prefill convention
  re-anchored to mlx-lm's spec shape (4/4 token-for-token incl. knife-edge);
  accepted-draft EOS leak fixed.
- **2026-08-17/18** — Qwen native MTP: DeltaNet rollback solved via the
  spec-round snapshot/replay contract (bit-exact by construction, gated);
  27B pairing gate token-identical (88% = 30/34, 2.82 tok/forward); quiet
  M1 Max A/B 0.821× at γ=2 (61% acceptance) — durable negative perf
  verdict, opt-in only; drafter-logit parity vs mlx-vlm 0.6.14 exact
  through the chained block. TQ artifact gauntlet: MTP 76% accept / 2.53
  tok/forward with a divergence flag, not claimed lossless.
- **2026-08-19** — 27B program (Track A / Track B) recorded, queued behind
  the certification suite.
- **2026-08-20** — MTP `[1,V]` sampler-shape fix (serve-lane 500 under
  top-k); GLM native MTP source carries the same note.
- **2026-08-23** — DSpark scripts consolidated under `scripts/dspark.ts
  <job>`; one-off measure/compare/bench scripts deleted (git history); this
  doc consolidates the three design docs.
