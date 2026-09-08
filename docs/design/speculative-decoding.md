---
status: landed
axis: ON
canonical-for: speculative-decoding
plan-anchor: "Phase 14 — Qwen 3.x family bring-up `[~]`"
last-verified: 2026-09-07
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

### 4.7 Packed 27B MTP recheck after kernel changes (2026-09-05)

The M4 Pro screen uses the actual packed k300 artifact and the existing
folded MTP companion from the affine flagship. Their recorded R1 seed,
hidden size and R2 setting agree; the head's documented final-gamma
approximation remains a draft-quality limitation. No head was downloaded,
trained or changed. The target verifies every MTP proposal; this is separate
from strict fill's no-verification assertions.

`tests/parity/qwen38-mtp.test.ts` now supports a warm native wall-time
diagnostic via `MLX_BUN_TEST_MTP_REPORT`. Target/draft path overrides select
the exact pair; `MLX_BUN_TEST_MTP_GAMMA` selects 1..4. The report records
both token sequences, actual completion counts, first-token and full-request
wall time, speculation counters, source and artifact identity, and machine
state. It does not compare differently defined decode-rate counters.

Six AB/BA blocks on the short enumeration fixture compare gamma 2 on variants
6 and 8, then gamma 1/2/3/4 on variant 8. The optimized verification kernels
improve MTP's economics on that fixture; gamma 4 loses when the target append
crosses the packed/expanded boundary. Exact emitted-token identity holds in
the observed cells. These are loaded-machine diagnostics under
`reports/qwen38-rd/mtp-v*-gamma*.json`, not default-promotion evidence.

A predeclared code, explanation, arithmetic, extraction, JSON and prose
screen has one warm pair per prompt with alternating arm order. Four valid
cases improve, while prose loses with lower draft acceptance. The extraction
case ran past chat EOS and is excluded from serving comparisons. All six
preserve the observed token IDs, including that invalid overrun. Reports and the frozen prompts are under
`reports/qwen38-rd/mtp-corpus-screen/` and `mtp-screen-prompts.json`. The
fixed output budget truncates some answers; this is not a task-quality eval.
MTP remains opt-in. Repeat diverse longer sessions, include rejection/rollback
cost and memory, and test a bounded adaptive policy on held-out prompts before
changing that decision.

The next adaptive screen stays within the existing `DraftSource` contract:
start at two drafts, decrease after a partial acceptance and increase toward
three only after two fully accepted rounds. Per-request state stays with the
source. Keep one draft as the floor for this experiment. Qwen MTP's current
`draft(n<=0)` returns without appending its pending cache row, and the
zero-draft commit does not add that row. A skip/recovery policy therefore
needs an explicit cache-advancement design before it can preserve the source's
alignment. This is a source-audit constraint on a future policy, not a failure
in the current fixed-positive-length path. Compare complete native/HTTP
requests and memory against both fixed gamma and non-spec generation on new
frozen prompts before retaining an adaptive policy.

The subsequent three-arm serving gate freezes three new prompts and the
adaptive rule before measurement. It uses the lossless interleaved packed
artifact, variant 13 and shared affine dispatch, with one serial request at a
time, temperature zero, seed 42, thinking disabled, no prompt/SSD cache and a
128-token budget. Six balanced-order blocks start 18 fresh servers. All exit
cleanly; measured sources remain fixed. Across 126 warm/measured responses,
all 84 native-versus-MTP text, prompt-count and finish-reason comparisons
match. The 12 JSON completion-count differences remain in the report. Native
`generateInner` counts the stopping EOS before excluding it from content;
`specRunInner` excludes it from both emitted content and `generatedTokens`.
Thus JSON reports 112 versus 111 despite identical response text. Compare
complete wall time for that cell, not the differently counted decode rates.

On the M4 Pro 24 GB, these are diagnostic medians in seconds:

| Frozen prompt | Native | Fixed two drafts | Adaptive one to three drafts |
|---|---:|---:|---:|
| TypeScript run-length encoder | 11.912 | 6.690 | 6.483 |
| Composite database index explanation | 11.914 | 7.217 | 7.062 |
| Normalize three records to JSON | 10.969 | 5.968 | 5.751 |

Every fixed/native, adaptive/native and adaptive/fixed complete-time pair
improves. Median paired adaptive/fixed time ratios are 0.9698, 0.9782 and
0.9624 respectively. Fixed MTP also reduces observed TTFT by about 160 ms;
adaptive/fixed TTFT is essentially unchanged. Median per-server peak RSS is
12,370,534,400 bytes native, 13,045,129,216 fixed and 13,029,392,384 adaptive.
The adaptive source exercises widths one, two and three; its policy state is
per request through the existing provider interface. The earlier broad corpus
and these held-out cells still do not establish a universal MTP gain. Code
and explanation stop at the token budget, so this is not a task-quality eval.
Machine preflight fails on existing swap use. Fixed MTP remains opt-in and
the adaptive wrapper is research-only. Raw evidence and source identities are
`reports/qwen38-rd/mtp-heldout-{plan,http,http-review}.json`. The native follow-up runs both arm orders and preserves every emitted token
ID in all 18 runs. Its 500 draft rounds include 78 partial-acceptance commits
and all three adaptive widths. Assertions check source offsets before and
after each draft and all 488 commits; all 12 sources dispose cleanly. Both
JSON runs emit exactly 111 IDs on every arm, confirming the separate native
EOS accounting. This is an alignment and trajectory gate, not a claim of
identical cache bytes between speculative and serial computation. The first
native run includes loading, so its times do not form a warm performance
comparison. Evidence: `reports/qwen38-rd/mtp-heldout-native{,-review}.json`.
Longer contexts, other quants and both quiet-machine gates remain open.

The EOS usage discrepancy is now fixed in the speculative serving loop.
It counts a stopping EOS from the initial sample, accepted draft, correction,
bonus or plain-decode fallback without emitting it. A callback or token-budget
stop before that position excludes the unused suffix. This follows the pinned
mlx-lm `stream_generate` final `generation_tokens=n+1` accounting. Nine
model-free cases reproduce seven old failures and cover both early-stop
controls. All typechecks, hygiene and 1,812 model-free tests pass. The fresh
three-arm HTTP gate completes 21 requests with fixed sources, clean exits and
no text, prompt-count, completion-count or finish-reason differences. JSON
now reports 112 tokens on every arm. This single block checks the fix; the
historical timing reports retain their original counts. Evidence:
`spec-token-counts-{before,after,typecheck,hygiene,model-free}.txt` and
`mtp-post-eos-http{,-review}.json` under the campaign reports.

An observed EOS now survives the method and serving adapters as
`finishReason: "stop"`. Native and speculative loops record it explicitly;
the adapters use the observed cause before their legacy count-based fallback.
Tool-call and explicit text-stop handling retain precedence. The first HTTP
replay exposed two additional serving overrides: at the known 112-token JSON
EOS budget, it still returned `"length"`. Three regression tests reproduced
those failures before the adapter fix. The final fresh replay completes all
21 requests with fixed sources, clean exits and unchanged text/counts.
Native, fixed and adaptive MTP now report `"stop"` for that JSON response
and `"length"` for the two genuinely budget-limited responses. All typechecks,
hygiene and 1,820 model-free tests pass. The speculative tests also cover
bonus EOS at the limit and early callback stops. Evidence:
`spec-eos-serving-{before,after,typecheck,hygiene,model-free}.txt`, the failed
`mtp-eos-budget-http{,-review}.json` gate and the passing
`mtp-eos-budget-integrated-http{,-review}.json` replay.

The continuous scheduler already records the terminal cause in `BatchStats`;
the gateway now preserves it when returning `GenerateStats`. Two regression
tests reproduce the dropped stop/length field before this correction. The
expanded model-free tier passes 1,822 tests, with all typechecks and hygiene
passing. Two fresh default-scheduler servers then preserve all six HTTP
responses under synchronous/bounded projection evaluation. Both measured JSON
responses count 112 tokens and finish with `"stop"`; every request reports
the wire lane `"batched"` and increments the scheduler submission count.
Sources stay fixed and both servers exit cleanly. The test seeds MLX to 42
at startup and uses greedy sampling; an explicit request seed would force
serial placement. The initial harness used the wrong wire enum and stopped
at its routing assertion. Evidence:
`spec-eos-continuous-{before,after,typecheck,hygiene,model-free}.txt`,
`eos-budget-continuous-http.json` and
`eos-budget-continuous-v2-http{,-review}.json`.

The first draft-only quantization screen replaces the MTP head's eight dense
projections with affine g64 8-bit or 4-bit matmuls. Target computation and
fixed two-token verification are unchanged. Three fresh servers complete 21
requests with identical response text, counts and finish reasons, fixed
sources and clean exits. Relative to the dense draft, 8-bit complete time is
flat on code and falls about 2% on explanation/JSON; 4-bit falls 0.92%, 3.15%
and 3.06%. These are single-block diagnostics, requiring repeated pairs.
Acceptance changes slightly, including an extra code verification round.
The prototype retains dense buffers in every arm and adds 451/239 MB of
quantized arrays, so it establishes no memory saving. Its preload explicitly
disposes providers after request shutdown because normal CLI exit retains
the resident provider; the initial experiment stopped on that cleanup check.
Evidence: `mtp-quantized-draft-screen-http.json` and the completed
`mtp-quantized-draft-screen-v2-http{,-review}.json` under campaign reports.

The six-block repeat completes 126 requests across 18 fresh servers with
all 84 paired response comparisons identical, fixed sources, clean exits
and explicit provider disposal. Median paired request wall time with the
4-bit draft falls 1.45% on code, 3.09% on explanation and 2.03% on JSON,
with six/five/four improving pairs. The 8-bit reductions are 0.34%, 2.16%
and 2.07%, with six/six/five improving pairs. TTFT is approximately flat.
The retained dense buffers mean sampled RSS remains unsuitable evidence
for the benefit of removing those weights. Quantized on-disk artifacts and
their actual loader/serving/memory gates are next; broader prompts, quants
and quiet acceptance remain. Evidence:
`mtp-quantized-draft-repeat-http{,-review}.json`.

The existing atomic CPU converter produces separate folded 4-bit and 8-bit
MTP artifacts with 238,930,944 and 451,267,584 tensor bytes, respectively.
Both retain all seven dense norm tensors and quantize exactly eight matrices.
The 4-bit artifact fails the initial comparison against GPU quantization,
but all 31 saved tensors match fresh CPU quantization or source passthrough.
CPU/GPU results differ in 16 quantized tensors, totaling 810,927 differing
bytes. The pinned Python oracle reproduces Bun's CPU and GPU hashes for all
three fc tensors, and the original companion files are unchanged. MLX 0.31.2
uses `std::rint` in the CPU affine quantizer and `round` in Metal; these
artifacts therefore require fresh serving/acceptance gates rather than
inheriting the GPU prototype's results. The 8-bit artifact passes all 31 CPU
comparisons, with fixed sources and zero active allocation after cleanup.
The provider now loads companion projections through the existing
`QuantizedLinear` when scales are present and retains dense projection
behavior otherwise. Its resource stack continues to own dense transpose
views; quantized companions retain no dense matrices. No draft policy or
target verification changes. The loader and initial serving/memory gates
pass below. Evidence: `mtp-draft-artifact-q4-{build,audit}.json`,
`mtp-draft-quant-oracle.json` and `mtp-draft-artifact-q8-build.json`.

The integrated loader passes all three typechecks, hygiene and the existing
1,822-test model-free suite. Its ownership file also passes a new malformed
quantization-metadata case after earlier dense projections have loaded.
Nine materialized provider cycles cover dense/8-bit/4-bit heads three times
each. Loaded allocation is exactly 849,398,784/451,267,584/238,930,944 bytes,
and every cycle returns to its initial zero active allocation after repeated
disposal, without GC. The initial ownership helper read the counter before
lazy weight materialization and failed its coverage assertion at zero/zero;
it did not reproduce a leak. These are companion allocation measurements,
not complete-server RSS. The additional typecheck after the new ownership
case also passes. Evidence: `mtp-quantized-loader-{typecheck,hygiene,model-free}.txt`,
`mtp-quantized-loader-typecheck-v2.txt`,
`mtp-quantized-loader-ownership-tests-v2.txt` and
`mtp-artifact-ownership{,-v2}.json`.

The saved-artifact HTTP screen completes 21 responses across three fresh
servers. All 14 dense-versus-quantized comparisons preserve text, prompt and
completion counts, and finish reasons. Sources remain fixed; all servers exit
cleanly. Observation confirms dense projections only in the dense arm and
quantized projections only in the smaller arms. Explicit provider disposal
releases exactly each companion's tensor allocation and reaches the same
11,936,569,478-byte resident-target baseline. This proves the smaller heads
load without retained dense matrices. Both quantized heads need one extra
target call on the code prompt, so cheaper projections do not guarantee a
faster request. Six balanced repeat blocks and instrumented native replay
are the next gates. Evidence: `mtp-artifact-screen-http{,-review}.json`.

Six balanced saved-artifact blocks then complete 126 responses from 18 fresh
servers, with all 84 paired text/count/finish comparisons exact, fixed sources
and clean exits. On the M4 Pro 24 GB, median paired complete-time changes
for code/explanation/JSON are -1.48/-3.67/-2.95% for the 4-bit companion and
-0.65/-2.29/-1.86% for 8-bit. The 4-bit arm wins 5/6, 6/6 and 5/6 pairs;
8-bit wins all six pairs per fixture. TTFT is approximately flat. Median
per-server peak RSS is 13,036,756,992 bytes dense, 12,740,034,560 bytes 8-bit
and 12,531,777,536 bytes 4-bit. Unlike the earlier GPU projection prototype,
these arms actually replace the dense companion tensors. Every explicit
provider disposal releases exactly its companion's allocation to the same
resident-target baseline. Existing system swap prevents canonical benchmark
claims. Instrumented native token/logit/state checks, broader contexts/quants,
pressure and quiet-machine acceptance remain. Evidence:
`mtp-artifact-repeat-http{,-review}.json`.

The subsequent native audit runs all three saved companions against the same
full-prefill native generation on each short fixture. All nine emitted-ID,
usage and terminal-cause comparisons pass. For every verification window,
it clones the incoming target state and replays the same tokens individually
with the same hidden taps. All 1,184 complete vocabulary-logit rows across
395 windows match byte-for-byte. At the first three and every sixteenth
window per request, every live attention and recurrent cache array also
matches, covering 48 complete state samples. All 386 commits, including 58
partial accepts, preserve the source position; all nine sources dispose.
Three fresh children exit cleanly with fixed sources and the same 16,390-byte
post-model-disposal active counter. This is instrumented correctness evidence,
not a timing result. Longer fixtures and other quants remain separate gates.
Evidence: `mtp-artifact-native{,-review}.json`.

Two new warehouse-ledger fixtures extend that audit to 688 and 1,968 prompt
tokens, using matching 2,048-token full-prefill chunks. Dense, 8-bit and 4-bit
companions preserve all six native/MTP ID, count and finish comparisons.
All 180 vocabulary-logit rows and 18 sampled complete cache states match;
54 fully accepted commits preserve position. All twelve native/MTP outputs
are valid JSON and contain the independently computed requested records.
Each response counts 30 generation tokens. Sources stay fixed, all three
children exit cleanly and each leaves the same 16,390-byte active counter.
This extends correctness coverage; long serving pressure and other quants
remain open. Evidence: `mtp-artifact-native-context{,-review}.json`.

The matching saved-companion HTTP screen completes 15 warm/measured responses
from three fresh servers at those two context lengths. All ten paired
text/count/finish comparisons match, with fixed sources and clean exits.
Both measured fixtures stop at 30 generation tokens. Dense and quantized
projection counts and explicit provider release pass on every arm. This is
one serving screen, not a repeated performance or long-agent pressure claim.
Evidence: `mtp-artifact-context-screen-http.json`.

Matched-prefill timing screens now separate native tail-split, native full
prefill and dense fixed-two MTP in fresh HTTP servers. All 21 packed responses
preserve text/count/finish across the three arms. The RTN4 screen also completes
21 responses; MTP matches native full-prefill throughout, while the two measured
code/explanation tail-split responses retain their known text differences.
Both screens have fixed sources and clean exits. On the M4 Pro 24 GB, complete
MTP request times improve 38.8–44.0% on packed and 27.6–38.1% on RTN4 relative
to native full-prefill. Each is one block, pending balanced repeats. MTP's
remaining TTFT advantage motivates checking native work before the first yield;
its decode loop constructs the next step before emitting the current token.
No default prefill policy changes. Evidence:
`mtp-matched-prefill-{r6,rtn4}-screen-http{,-review}.json`.

The packed matched-prefill repeat completes six balanced three-arm blocks,
18 servers and 126 warm/measured responses. All text, token counts and finish
reasons match across native tail-split, native full-prefill and fixed-two
MTP. Sources stay fixed and all servers exit cleanly. Against native full
prefill on the M4 Pro 24 GB, MTP changes median paired complete request time
by -43.22% for code, -38.81% for explanation and -44.92% for JSON. Every pair
improves. Corresponding TTFT changes are -7.36/-8.42/-5.47%. Median paired
peak server RSS rises by 684,335,104 bytes, about 653 MiB; this samples startup
and the whole request sequence, not each fixture's physical-memory demand.
Native tail-split adds roughly 0.77–0.86% complete time and 7.37–10.46% TTFT
relative to native full-prefill. Existing swap and background CPU activity
in the final block keep these results diagnostic. All samples are retained.
Broader workloads and quiet acceptance remain.
Evidence: `mtp-matched-prefill-r6-repeat{,-review}.json`.

The RTN4 repeat also completes six balanced blocks, 18 servers and 126
responses with fixed sources and clean exits. MTP and native full-prefill
match all text/count/finish comparisons. Native tail-split retains the code
and explanation differences in every block. Relative to native full-prefill
on the M4 Pro 24 GB, median paired MTP complete-time changes are -34.95% for
code, -26.95% for explanation and -38.48% for JSON. Code and explanation
improve in five of six pairs; JSON improves in all six. Median paired sampled
peak server RSS rises by 850,173,952 bytes, about 811 MiB. The losing block
overlaps another application's TypeScript and Playwright work, followed by
system indexing and increased swap. Retain that block and the other samples;
these diagnostic medians do not substitute for quiet acceptance. Evidence:
`mtp-matched-prefill-rtn4-repeat{,-review}.json`.

The RTN4 cross-quant screen uses its unrotated target and the original
unrotated mlx-community MTP head, with the same three held-out prompts and
fixed/adaptive policies. All three servers exit cleanly with fixed sources.
Usage counts and finish reasons match, but both MTP arms differ from native
on the measured code and explanation responses. Those timings do not establish
identical-work speedups. The JSON response matches at 117 counted tokens;
its single-block complete times are 8.292/5.042/4.776 seconds for native,
fixed and adaptive MTP. Repeated timing and a first-divergence audit remain.
Keep the packed result specific to its tested artifact and prompts. Evidence:
`mtp-rtn4-screen-{plan,http,http-review}.json` under the campaign reports.

The RTN4 native follow-up reproduces code/explanation divergence at emitted
token indices 48/26 with seed 42 and greedy sampling. For each of 140 target
verification windows, it clones the pre-forward cache and replays the same
IDs through serial M1 forwards with the same hidden taps. All 420 projected
logit rows have identical values, and all cache offsets agree. Instrumented
MTP preserves the uninstrumented emitted IDs on all three fixtures. Thus a
local verification-window arithmetic difference does not explain these
responses. Native tail-split versus MTP full-prompt prefill and state
accumulation require separate controls.
Sources remain fixed. Evidence: `mtp-rtn4-divergence-v2-audit{,-review}.json`.

Two fresh processes isolate the prefill choice using the existing
`MLX_BUN_PREFILL_TAIL_SPLIT` setting. Native traces show 57+1, 53+1 and 91+1
prompt forwards with splitting, versus 58, 54 and 92 without it. MTP uses
full-prompt prefill in both processes. With splitting enabled, the earlier
code/explanation token differences recur. With splitting disabled, every
native emitted ID matches MTP on all three fixtures; MTP itself is unchanged
across processes. Counts are 128/128/117 including JSON EOS. Both children
exit cleanly and all source hashes stay fixed. This isolates the observed
trajectory differences to the native prefill policy for these fixtures.
Retain the original failed comparisons and add a native full-prefill arm
when measuring MTP, so prefill savings and drafting savings are distinct.
Changing that policy still needs its own oracle/quality gates. Evidence:
`mtp-rtn4-prefill-control{,-review}.json` under the campaign reports.

Variant 10 further shares small-M scatter work. Six warm AB/BA blocks at
gamma 2 and 3 on both enumeration and the earlier losing prose prompt now
retain an observed wall-time gain with identical token IDs. Enumeration
prefers gamma 3; prose prefers gamma 2. This changes the measured cost of
verification, not the recorded acceptance sequences. The reports are
`reports/qwen38-rd/mtp-v10-{planets,prose}-gamma{2,3}.json`. These repeated
fixtures are still diagnostic, with no general workload or quiet-machine
verdict. Native request rows are recorded in the eval DB under
`mlx-bun-native-diagnostic`, which does not replace the status page's
ordinary inference measurements.

The native MTP test now also uses the server's config-plus-tokenizer EOS set
and records it. The repeated variant-10 enumeration/prose cells contain no
additional EOS ID within their fixed budget, so that correction does not
truncate those sequences. The broader corpus audit found chat-EOS overrun
in extraction only. Its two DB rows and the old strict-fill rows now carry
explicit exclusion notes; corrected strict-fill reports are recorded separately.

The provider-lifetime audit found a separate cleanup bug. The Qwen provider's
old no-op `dispose()` assumed process-lifetime mapped weights, but `Weights`
now owns native MLX maps and each dense projection also retains a transpose
view. Three bounded load/use/source-dispose/provider-dispose cycles retained
849,398,784 additional MLX bytes each, including after garbage collection.
The provider now owns a `DisposableStack`: weight-map cleanup is registered
first, then each derived transpose view, so disposal releases views before
maps. The same scope unwinds a partially constructed module. Disposal is
idempotent and opening a source after provider disposal is rejected. The
caller closes active request sources before unloading their provider, as for
the other providers. Inference operations and their ordering are unchanged.

The real 27B MTP-head probe returns active MLX memory to zero after each of
three cycles, before GC. Model-free tests also cover map/view release, repeat
disposal and failure at the final norm after earlier views have been created.
Evidence: `reports/qwen38-rd/mtp-provider-dispose-{before,after}.json` and
`mtp-provider-ownership-tests.txt`. All three typechecks, hygiene and the full
model-free tier pass: 1,803 tests, 10 skips and no failures. The post-change serving
gate completes all three native/fixed/adaptive servers with clean exits and
matching response text on the frozen requests. Only the previously documented
JSON EOS-count difference remains; sources stay fixed. Evidence:
`reports/qwen38-rd/mtp-post-dispose-http.json`. This addresses drafter unload/replacement;
it is separate from the already-fixed target-cache disposal and admission work.

### 4.8 Paired Qwen MTP conversation state

An isolated candidate adds an optional prefix-state interface to `DraftSource`.
The Qwen provider retains one evaluated prefill boundary containing target KV
and recurrent state, draft KV, the preceding target hidden row, and exact token
IDs. Restore transfers ownership only when the incoming prompt extends those
IDs under the same target and adapter namespace. A mismatch releases the old
entry. Reuse never trims recurrent state to an arbitrary common prefix.

The MTP cache is one position behind the target at a prefill boundary. Extending
it first pairs the next incoming token with the saved preceding hidden row,
then processes the remaining suffix. Future generation cannot alter the retained
prefix. The candidate caps this one snapshot by the configured prompt-cache
budget and disposes it with the provider. It does not yet retain completed
generation state or participate in the ordinary cache's pressure eviction,
SSD persistence, or byte telemetry. It remains experimental and separate from
the default serving path.

On the M4 Pro, the unit gate passes 18 tests. Native prompts at 128, 513 and
2,051 tokens pass six restore checks with unchanged state hashes, token IDs
and acceptance traces; repeated allocation is stable at each length. The HTTP
gate completes eight responses with identical text, token counts and finish
reasons across uncached and cached MTP policies, including repeated cache hits.
The native restore check also passes with Luke's coding sampling recipe,
temperature 0.6, top-p 0.95, top-k 20 and seed 42: six unchanged state restores
and exact repeated continuations. Evidence: `mtp-prefix-luke-sampling.json`.
These gates establish the initial composition, not complete long-task speed or
pressure acceptance. The fresh thinking-off Pi task reused saved prefixes and
finished generation without compaction, but its generated app failed acceptance.
The task disposition and next frozen configuration are in decode-speed-program
section 7.7. Raw evidence: `reports/qwen38-rd/mtp-cache-candidate-native.json` and
`reports/qwen38-rd/mtp-cache-http-gate.json`.

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

**What "already knows" means in the strict tier.** A request's
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

**Serialization and state invariants.**
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
tier must demonstrate token identity against ordinary generation. A fixed
template serialization does not prove that the unconstrained model chooses
it. The weights gate is `tests/parity/fill-strict.test.ts`; section 7.4 states
the stronger contract needed for a claim of guaranteed deterministic replay.

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

### 7.3 Measuring it (K3d, `scripts/fill.ts`)

Neither tier ships on a vibe. The harness replays RECORDED agent sessions with
their tool results mocked verbatim from the JSONL — the transcript IS the
environment, a model cannot tell an executed result from a recorded one — so a
whole corpus replays deterministically and side-effect-free. The session reader
is a straight port of the corpus study's (`reports/k3-replication/analyze.py`
`load_session` / `serialize_tool_call`), including its `excludeFromContext` rule
and corrupt-line tolerance, so the measured rates in PLAN K3 keep describing
what the harness actually sends. The recordings carry no `tools` array, so the
harness SYNTHESIZES one per session (union of observed argument keys; keys
present in every call marked required) — a reconstruction that is itself part
of what the A/B measures.

```
bun scripts/fill.ts replay --sessions <file|dir> --server-url <url>
bun scripts/fill.ts ab     --sessions <file|dir> --url-a <off> --url-b <echo>
bun scripts/fill.ts ab     --showcase fixtures/showcase-silicon-exchange.txt --url-a … --url-b …
bun scripts/fill.ts report <runs.jsonl> [--by-tool]
```

Fill is a process-wide lever, so the two arms are two SERVERS (A without
`MLX_BUN_FILL`, B with it). Turns interleave A, B, A, B … so load drift and
thermal state land on both arms, and the verdict pairs on (session, turn, rep).

**The echo-tier gate**: task-output agreement must not drop within CI AND
median wall clock must strictly improve. Agreement is the CALL the model made
(tool name + arguments, key-order independent) or a prose turn's normalized
text — never token identity, which sampling never promised and which an agent
loop does not care about. "Does not drop" is McNemar's paired counts with a
one-sided 95% bound, so a tie or a swing inside the noise passes and a real
regression does not. The strict tier keeps its own, stricter bar (token
identity at temperature 0, `tests/parity/fill-strict.test.ts`).

**The showcase** runs ONE large tool-dense prompt ×3 interleaved and reports
emitted vs decoded tok/s, the fill fraction, time-to-first-tool-call, and the
comparison with a one-token-per-forward bandwidth estimate. An emitted rate
above that estimate can show amortized weight reads; the injected positions
still pass through the state-update graph. `apparent = decoded / (1 − fillFrac)`
omits append cost and is not a speedup measurement.

The verdict math is model-free and unit-tested against a stub server
(`tests/research/fill-echo-replay.test.ts`), including the ways it FAILS — a
harness that can only produce PASS is not a gate.

**Live result, 2026-09-02 (M1 Max 32 GB, mjriii/Qwen3.8-27B 4.80 bpw, six
recorded pi sessions, 32 paired turns, `--batch 1`).** Two servers do not fit
the wired ceiling at 27B, so the arms ran SERIALLY (one server restarted
between them; `fill report` now prints the paired verdict for two `replay`
files). Two false starts are findings in their own right: (1) the default
server lane is the batch scheduler, which never fills — an A/B on it is two
identical arms (fill 0.0%, same 4925 tokens); the serial lane needs
`--batch 1`. (2) The strict tier compiled ZERO rows on the 27B: Qwen3.x
thinking templates end the primer in `<think>\n` and the reply opens with
`\n</think>`, the tokenizer merges the two newlines, the primer stops being a
token prefix and the compiler bailed silently. Fixed (`schema-rows.ts
after()`: text-level boundary, suffix tokenized on its own; 4 rows compile on
the 27B). So the run measured the ECHO tier alone:

| arm | tok/s emitted · decoded | fill | median wall | agreement |
|---|---|---|---|---|
| fill-off | 8.0 · 8.0 | 0 | 7663 ms | 3.1% |
| fill-echo | 8.1 · 7.5 | 7.4% (bash 10%, read 32%) | 7630 ms | 6.3% |

369 tokens injected in 66 echo events; verify accepted 369 / rejected 1195
(76% of proposed span positions), 31 branch stops, 147 ms of checkpoints.
Agreement held (B-only agreements 1, A-only 0; the McNemar bound cannot
resolve +3 pts at n=32). **Wall clock ×1.00 — the echo gate FAILS**: each
event pays a multi-token forward for its whole span and a rewind, and with
three of four proposed positions rejected the forward compute per accepted
token exceeds a decode step. Echo stays Lab, default off. Levers before a
rerun: a longer anchor (`MLX_BUN_FILL_K`), fewer candidates, a span cap near
the observed accepted length (~5–6), and asserting corroborated spans instead
of verifying. Absolute rates are not quotable: the box ran at 8 tok/s (2.3 GB
swapped, the 16 GB server plus the day's leftovers) where 19 is predicted;
both arms saw the same conditions.

**Strict tier, same day, corrected rows** (serial arms back to back, 32 paired
turns): fill 5.3% of emitted tokens, all proposed strict spans injected
(assert policy, no agreement readback), identical tool calls on every paired turn,
median wall ×0.99 (the win is bounded by the fill fraction). The proposal
trace (`MLX_BUN_FILL_TRACE=<file.jsonl>`, `bun scripts/fill.ts trace`) is
what made the rows right: the first strict run's list showed the scaffold row
firing on `</think>` and asserting `<tool_call>…` where the model would have
written prose ("Hey", "You", "I") in 10 of 47 template proposals, while the
schema-derived name/close rows agreed 9/9. The scaffold trigger now runs
through the first token where the call rendering diverges from a plain-
content rendering — the model's own `<tool_call>` — and the failure class is
gone by construction. Echo-tier list, same tool: 66 events, verify accepted
369 / rejected 1195, survival by position falls to ~50% by position 6 — the
policy levers named above are what the list points at. **Showcase measured**
(same day, `fixtures/showcase-silicon-exchange.txt`, 1024 tokens × 2 reps,
serial arms): echo 8.9 tok/s emitted = 8.9 decoded, off 9.0 — fill 0.0%.
A fresh build prompt has no earlier session text to copy, so the echo index
has nothing to propose; the bandwidth-ceiling demonstration (25.2 tok/s for
14.76 GiB at 400 GB/s) needs a turn that REPEATS earlier context. The fixture
is the wrong shape for the tier it was written for — a multi-turn edit loop
is the honest showcase. Repro to file: turn 8 of session
`2026-08-18T04-34-36-341Z_01a01326…` kills the server on either lane (bare
MLX C++ exception, three of three runs, `runs/k3/serve-*.log`).

**Files.** `src/fill/proposal.ts` (the interface + the two policies),
`src/fill/fill-session.ts` (sources, clamping, flags, telemetry),
`src/fill/schema-rows.ts` (scaffold probing + value delimiters),
`src/fill/echo-index.ts` (k-gram index + branch-point rule), the apply
primitive in `src/generate.ts`, `fillPlanFor` in `src/serve/request-prep.ts`,
the attach + serve-level refusals in `src/serve/chat-stage.ts`, `usage.fill` in
`src/serve/{completion-executor,openai-wire}.ts`. Tests:
`tests/unit/fill-{session,schema-rows,echo-index,generate-loop}.test.ts`,
`tests/serve/fill-{composition,stream}.test.ts`,
`tests/parity/fill-strict.test.ts` (weights-gated). Harness: `scripts/fill.ts`
+ `scripts/fill/{session-replay,runner,client,metrics,args,replay,ab,report}.ts`,
`tests/unit/fill-session-reader.test.ts`,
`tests/research/fill-echo-replay.test.ts`,
`fixtures/showcase-silicon-exchange.txt`.
User-facing mirror: `docs/reference/server-config.md` (`MLX_BUN_FILL`,
`MLX_BUN_FILL_MAX_SPAN`, `MLX_BUN_FILL_TRACE`, `MLX_BUN_FILL_K`,
`MLX_BUN_FILL_CANDIDATES`, `MLX_BUN_FILL_INDEX_MAX`), `server-api.md`
(`usage.fill`).

### 7.4 No-verification replay contract and next experiments

The 2026-09-04 Qwen performance program makes this a dedicated track.
Production `assert` must remain free of verification. Separate correctness
runs may inspect every skipped prediction; those instrumented runs cannot
supply the performance number. `applyProposal` in `generate.ts` already
implements this separation: `verify` or a trace filename computes logits at
all appended positions, while normal `assert` projects only the final hidden
state to resume sampling. It still forwards the span through model layers
and updates attention KV and GDN state.

This track appends serialization fixed by the current tool-call state. It
does not predict unknown tokens. Once the protocol fixes a field following
a selected tool name, that field can become context immediately; sampling
resumes where the tool or argument value has a choice. Map fixed protocol
fields through the model's own chat template, including the preceding token
boundary. Pi's client-side tool representation and a model's wire rendering
can differ. Parser state must distinguish structural fields from the same
text inside argument strings, quoted examples or code. Offline parity audits
validate the implementation; they do not add verification to served asserts.

There are different possible guarantees:

| source | what would justify an assertion |
|---|---|
| Enforced output grammar/protocol | All legal continuations share the emitted token span at the current parser state. Account for tokenizer boundaries and stop conditions. Grammar uniqueness over bytes does not automatically imply unique token IDs. |
| Deterministic application transform | An explicit contract fixes the source span and transformation, such as escaping a selected literal. Choosing which source/value to emit remains a model/application decision. |
| Cached continuation | Exact model/quant, prefix, recurrent state, positional metadata and sampler/constraint state establish an identical continuation. A matching short suffix is insufficient. |
| Template/schema row | Establishes a valid serialization. Without enforced generation constraints, token identity with the model is an empirical gate and can fail even at temperature zero. |
| Repeated text | Agreement among observed occurrences is evidence, not certainty; retain the existing Lab distinction for echo assertions. |

Audit suffix triggers against real parser/role state, tool-name prefixes,
optional/extra parameters, `additionalProperties`, multiple calls, quoted
markup, code blocks, escaping, EOS and partial-burst cancellation. The original
strict row source matched a token suffix without an independent parser-state
guard. Do not interpret an all-assert `accepted` count as verified agreement.

A CPU-only audit with the actual R6 tokenizer/template finds a concrete close
boundary error in both thinking modes. The compiled close trigger ends at
`</parameter`, before `>`. A valid bash argument containing
`printf "%s" "</parameterization>"` therefore triggers the structural close
inside argument data. Injecting the current row changes the parsed command to
`printf "%s" "`. Both complete calls parse; the suffix alone cannot establish
that the value ended. The audit constructs valid token streams from the exact
compiled trigger IDs; it does not claim these are observed model trajectories
or quantify their frequency. Scaffold/close rows also match reasoning, quoted
prose and fenced examples without a role/parser guard. Evidence:
fill-parser-boundary-r6.json. Keep fill off by default. Complete the delimiter
and establish protocol state before asserting its continuation; runtime model
verification is not the remedy for a missing structural proof.

An isolated parser prototype now waits for the complete `</parameter>` or
`</arg_value>` delimiter and requires a request-local tool-only assistant
context, optionally following closed reasoning. It reuses the tool parser
with full input consumption and no repair; quoted or fenced examples,
nested reasoning, unfinished literals, duplicate XML/GLM keys and requests
above the probe budget decline strict fills. Cached row plans create context
from the current prompt and do not retain the first request's messages.
The CPU-only real-R6-tokenizer audit rejects all sixteen negative contexts
and preserves four positive rendered token streams across both thinking
modes, including the original `</parameterization>` command. Each positive
case injects nineteen tokens in two spans with zero verification events.
The broader parser/stream suite passes 138 tests. Evidence:
`fill-boundary-tokenizer-audit-v4.json` and `fill-boundary-cpu-tests-v8.log`.
The parser and model-owned append method are integrated in the main tree.
The gates below distinguish the original short-context integration from
the subsequent attention-boundary correction.
On the consolidated MLX 0.32.2 core with the interleaved R6 artifact and
variant 13, the first weather fixture emits identical tokens but four-token
appends change recurrent state and continuation logits. One-token appends
restore exact state, all four continuation probes and disposal accounting,
with the same twelve injected tokens and zero verification. The earlier
four-token acceptance used a different runtime/artifact configuration;
it does not establish this combination. Isolate the changed arithmetic
before selecting an append shape. Evidence: `fill-boundary-native-r6.json`
and `fill-boundary-native-m1-r6.json`. A first-layer operation audit localizes
the drift to native affine projections: embedding and normalization match,
but MLX's new multirow matvec differs from repeated M1. Broadcast weight
views with input shape `[M,1,K]` select native batched M1 instead. All six
boundary/chunk cases then match every captured intermediate and both state
arrays exactly, without copying stored weights. The arithmetic prototype
then passes seven full native fixtures per R6/RTN4 quant, with exact emitted
IDs, complete state, four continuation probes, usage and disposal accounting.
Runtime verification remains zero. RTN4's negative-intent code-block prompt
produces a valid weather call in both arms; its original no-fill expectation
is retained as a failed fixture assumption, and the rerun classifies that
cell as a generated-call identity control. Forced-token negative contexts
remain covered by the tokenizer/parser gates. Evidence:
`fill-first-layer-shape-probe.json` and `fill-first-layer-batched-m1.json`.
The full-model reports are `fill-boundary-native-batch1-r6.json` and
`fill-boundary-native-batch1-v2-rtn4.json`.
The original guarded-parser/arithmetic prototype also passes six balanced
three-arm HTTP blocks per quant on the loaded M4 Pro 24 GB. All 144 responses
match across 36 clean server exits, with fixed effective seed 42, empty prompt
caches, identical tool calls and zero verification. Four-token append reduces
paired-median complete time for weather/bash fixtures by 9.95%/15.24% on R6
and 1.92%/3.34% on RTN4; every corresponding pair improves. M1 append is
mostly flat, and RSS supplies no memory-reduction claim. Tool output is
buffered until completion here, so these are complete-request and first
meaningful-tool-output results, not decode-rate measurements. Source hashes
remain fixed across the initial screen and five remaining order blocks.
Evidence: `fill-boundary-http-{screen,repeat,review}.json`. The model-owned
integration passes the same fourteen native cases and six balanced four-arm
HTTP blocks per quant. All 192 responses match across 48 clean server exits.
Paired-median weather/bash complete time improves by 9.87%/15.37% on R6
and 1.97%/2.77% on RTN4, with every pair improving. Ordinary generation's
before/after medians differ by at most 0.23%. These remain loaded M4 Pro
diagnostics. The independent-row operator matches sequential M1 across
720 shape/bit/group/dtype/layout cases, with unchanged stored weight bytes.
The main-source state regression passes on both quants, and eight actual
HTTP cancellations recover exact responses and steady active allocations.
Evidence: `fill-append-integration.json`,
`fill-append-http-integration-review.json`, `fill-append-main-native.json`
and `fill-append-lifecycle.json`.

A longer-context audit finds another native dispatch dependency. MLX 0.32.2
changes its attention kernel and two-pass reduction block count according
to sequence length and GPU architecture. The rules are in
[MLX's attention dispatch](https://github.com/ml-explore/mlx/blob/v0.32.2/mlx/backend/metal/scaled_dot_product_attention.cpp).
The qualified GQA-6/D256 path on
`applegpu_g16s` must end chunks at inclusive KV lengths 1023, 1024, 8192,
32768 and 65536. An unsplit append that crosses a transition can change
arithmetic for its earlier positions. The first operation screen reproduces
18 failures among 108 cases. The corrected model-owned limit is rechecked
after every chunk; MLX still selects the kernels. Other architectures retain
single-token appends pending their own qualification.

All 225 corrected attention cases through 65,537 cached tokens are exact
across bf16, fp16 and fp32, and active allocation returns to zero. Full R6
and RTN4 models also match eight committed positions from identical prefixes
of 1021 and 8189 tokens. Hidden rows, per-position M1 vocabulary projections,
complete live state and four ordinary continuation probes match exactly;
the borrowed prefix state and post-arm active allocation are unchanged.
These teacher-forced checks establish arithmetic identity, not that the
model would independently choose those committed IDs. Production regression
coverage checks the attention boundaries and dynamic model limit. The final
model-free suite passes 1,947 tests with ten skips and no failures; all three
typechecks pass. The corrected path also passes eight actual HTTP
cancellations, fourteen completed responses and exact steady allocation
recovery across both quants. Final serving timing acceptance passes the
internal-SSD diagnostic below; held-out, combined, pressure and quiet gates
remain open.
Evidence: `fill-sdpa-context-probe.json`,
`fill-sdpa-context-boundaries.json`, `fill-append-context.json`,
`fill-append-final-model-free.log` and `fill-append-lifecycle-boundaries.json`.
The final-source timing attempts complete 116 responses with exact content,
tool calls and usage comparisons. Two RTN4 first-request warmups hit Metal
GPU timeouts, one with fill disabled and one with fill enabled. Neither
executes an append forward. Keep both failed requests and the incomplete
block in the evidence. Complete three-arm blocks cover six R6 pairs and
three RTN4 pairs; every append-versus-native pair improves complete time on
both fixtures. The dynamic boundary checks retain the earlier append benefit.
Separate recovery, storage and loading controls do not fill missing timing
cells. The failure investigation and its limits live in
[environment.md](../reference/environment.md#external-storage-loading).
Evidence: `fill-append-http-final.json`, `fill-append-http-resume.json` and
`fill-append-http-final-partial-review.json`.

After Josh specifies internal storage for active models, a separate final
comparison uses byte-verified R6 and RTN4 copies with ordinary lazy loading.
All 96 responses across 24 fresh servers match, with twelve balanced pairs,
zero failures, zero verification calls and identical final active allocation.
On the M4 Pro 24 GB, the median paired complete-time reductions are 9.83% and
15.40% for R6's weather/bash fixtures, and 1.63% and 2.94% for RTN4. Every pair
improves on each fixture. Tool output is buffered, so first visible output
arrives near completion; these figures do not establish faster ordinary
decode. The machine still fails the quiet preflight, so these are diagnostic
results. Both external-drive failures remain recorded separately. Evidence:
`fill-append-http-internal-repeat.json` and `fill-append-http-internal-review.json`.

Quantized-KV composition remains disabled. A direct R6 append screen with
TurboQuant k8v3 preserves hidden rows, logits, live cache state and four
continuations at prefixes 128 and 1021, but exposes retained temporary state
views between chunks. `appendFillHidden` now uses the existing
`leaseCacheStates` ownership interface, as prefill does. Explicit release
removes the extra 21,528,576 and 131,153,920 active bytes in those two checks;
both ordinary and fused TurboQuant decoding then have identical post-arm
allocation and numerical results. This fixes the research composition's
view lifetime; the ordinary served path already excludes this combination.
Seven targeted ownership tests and all three typechecks pass. The affine
KV4 comparison fails both contexts, first changing recurrent state at layer
4 after the first attention layer. Keep its failure and the composition
guard. Other quant/cache modes, longer contexts and actual serving
performance remain unqualified. Evidence:
`fill-append-quant-cache-review.json` and
`fill-append-state-ownership-native-test.log`.

The literal/reasoning checks deliberately decline ambiguous text, including some
otherwise valid prose with unmatched quote characters. This is bounded
coverage, not proof for every unconstrained model trajectory.

The schema-choice audit reproduced assertions that selected a first key or
closed the call while other valid arguments remained. The compiler now uses
a sole required key only when `additionalProperties: false` and no nonempty
`patternProperties` map establish that no other key is legal. Optional keys
may come before a required key. When no property is required, the common
span also includes the empty-argument rendering. This follows the
[JSON Schema object applicators](https://json-schema.org/draft/2020-12/json-schema-core#section-10.3.2),
where omitting `additionalProperties` leaves those properties unconstrained.
Open objects also compare an undeclared-key rendering, even when declared
keys share a tokenizer prefix. Twenty-seven regressions across XML, JSON and
GLM templates preserve these
choices, alongside the existing positive fill cases. This is a compiler
correctness fix, with no runtime verification or new inference operation.
The real packed-Qwen and RTN4 tokenizers each pass 20 cases across thinking
on/off with nonzero row matches. The packed weighted regression also retains
token-identical output and nonzero injection with four-token appends. All
1,867 model-free tests and three typechecks pass. Parser/role-state proof
and the broader session corpus remain. Evidence is
`fill-schema-open-objects-before.json`,
`fill-schema-choices-original-control-corrected.txt`,
`fill-schema-shared-prefix-merged-before.txt`,
`fill-schema-choices-model-free-final.txt`,
`fill-schema-tokenizer-{r6,rtn4}-final.json` and
`fill-schema-choices-weighted-r6.json` in the campaign report directory.

Run the actual artifact regression with
`MLX_BUN_TEST_FILL_MODEL=<local-model-dir> MLX_BUN_FILL=strict bun test tests/parity/fill-strict.test.ts`.
It selects one artifact per process and defaults to the small Qwen fixture
when no override is set. This is an initial positive-fill identity check;
extend it to the held-out 27B session/adversarial corpus before a default.
Track token IDs and subsequent logits/state as well as parsed tool arguments.

On 2026-09-05 the actual packed Qwen3.8-27B passes this regression on both
trellis variants 6 and 7. Both runs perform nonzero assert injection with
zero verification events and emit the same token IDs as their unfilled
control. Logs: `reports/qwen38-rd/strict-fill-variant{6,7}.txt`. This is one
weather/tool-call fixture; it does not establish universal determinism or a
wall-time win. Test duration includes loading and warmup and is not the
performance comparison. The older logs' `baselineForwardSteps` field contains
the baseline generated-token count; the test now labels it accordingly.

The native tests now union config EOS with tokenizer EOS, matching
`loadRuntimeModel`. The packed config alone omits the chat terminator. Earlier
`strict-fill-v10-{wall,max4-wall}.json` runs continued beyond the first chat
turn and are excluded from serving-performance conclusions. This was a test
policy error; the server already applies the union. The initial variant-6/7
logs also used the config-only stop policy.

Corrected variant-10 diagnostics warm complete answers and retain six
alternating on/off pairs per cap. Both the default cap and the existing
`MLX_BUN_FILL_MAX_SPAN=4` cap preserve the first-turn token IDs with nonzero
assertions and no verification. Both improve observed request time; the
shorter cap injects fewer tokens and avoids an expanded append. These are
separate diagnostic sessions with prefill noise, not a default-policy verdict
or a direct comparison of truncation against chunking. Corrected reports:
`reports/qwen38-rd/strict-fill-v10-cap{32,4}-served-eos.json`.
`MLX_BUN_TEST_FILL_REPORT` enables the retained test's paired diagnostic;
`MLX_BUN_TEST_FILL_BLOCKS`, `MLX_BUN_TEST_FILL_PROMPT` and
`MLX_BUN_TEST_FILL_REVERSE` select its workload and schedule. Reports record
the cap, rows, prompt IDs, exact emitted IDs, counters and whole-request time.
`MLX_BUN_TEST_FILL_THINKING=0|1` and `MLX_BUN_TEST_FILL_TOKENS` select the
thinking policy and completion budget for broader fixtures. The test rejects
emitted EOS IDs; its report records the effective stop set.
The corrected variant-11 default-cap repeat also preserves first-turn IDs
with nonzero injection, zero verification and lower complete-request time.
Evidence: `reports/qwen38-rd/strict-fill-v11-cap32-served-eos.json`.
The EOS-correct five-case audit (weather control plus four frozen adversarial
prompts) preserves all emitted IDs, cache-token records and offsets. Quoted
malformed markup and code blocks produce no injections and retain exact
state/probe logits. The three injected cases preserve the response but differ
in live state after longer appends; subsequent teacher-forced logits differ
too. All verification counts remain zero. Explicit seed 42 reproduces those
results; temperature-zero sampling uses argmax. Reducing the span cap to four
restores exact state and four subsequent probes in the weather/multiple-call
fixtures, while injecting fewer tokens. Evidence:
`reports/qwen38-rd/fill-adversarial-state-v12-eos-review.json`,
`fill-state-v12-cap4-eos.json` and
`fill-state-v12-cap{32,4}-seed42.json` in the same directory.

An isolated follow-up removes generation and sampling entirely. It copies a
nine-token span from the unfilled model's recorded output and appends it to
byte-identical cloned starting caches. Serial and repeated serial appends,
full M3/4 appends, and chunks of at most four tokens agree exactly in state,
final logits and the next teacher-forced probe. Full M5/9 appends reproduce
the numerical difference. Restoring the saved serial cache preserves its
bytes and next logits exactly. Thus copying a cached state works as expected;
recomputing known tokens through a different graph shape changes numerics.
The packed projection dispatch crosses from small-M matvec to prefill at
M=5; that prefill path also rounds reconstructed weights to the activation
dtype. This is a compute-path distinction, not a changed token span or seed.
Evidence: `reports/qwen38-rd/fill-identical-input-append-review.json`.

Four-token execution chunks now preserve every asserted token and pass all
five complete-generation fixtures at seed 42. Emitted ids, cache-covered ids,
live cache bytes and four subsequent teacher-forced logits are exact against
ordinary generation. Positive cases still inject 12, 8 and 20 tokens with no
verification; both negative cases inject zero. The production implementation
passes the same audit, without the prototype model adapter. It is a shared
MLX append operation, selected by a captured FillSession setting rather than
model inspection in the generation loop. Verify proposals retain a single
forward because recurrent rollback records one forward per round. Tests cover
budget clamping, one final vocabulary projection, a consumer break inside the
burst, cancellation, failed-chunk cleanup and recurrent verification rollback.
The setting and default live in server-config.md.

Six balanced three-arm blocks per positive timing fixture compare ordinary
generation, existing full-span fill and four-token execution chunks. The full
span is retained in both fill arms; every pair preserves emitted ids and
cache-covered ids. The chunked prototype improves complete-request diagnostic
timing in every pair, with higher peak allocation than ordinary generation.
These are local M4 Pro observations with residual swap, not quiet benchmark
rows or a universal determinism guarantee. Six production HTTP server pairs
then preserve all 24 paired warm/measured responses, tool calls and injection
counts. Every measured fixture pair improves complete-request time. Dispatch
counters confirm chunking is used only by the candidate, all twelve servers
exit cleanly, and source hashes remain fixed. HTTP uses greedy temperature zero
without an explicit seed because explicit HTTP seeds currently exclude fill;
the separate native acceptance uses seed 42. Broader held-out/parser, model
and quiet/second-Mac gates remain. Evidence:
`reports/qwen38-rd/fill-chunked-complete-requests-review.json`,
`fill-chunked-state-v12-seed42-review.json`,
`fill-integrated-state-v12-seed42-review.json` and
`fill-integrated-http-packed-review.json`, plus
`fill-chunked-integrated-{unit,model-free,typecheck,hygiene}.txt`.

Performance experiments: eliminate redundant in-flight sampling/head work,
merge adjacent determined spans, reuse compiled schema plans with exact
identity keys, and choose append batch size from the packed-trellis M curve.
For the discarded head, test scheduling the next model body first, reading
the current token while that body runs, then projecting only when the fill
decision requires a sampled continuation. The existing graph interface already
separates body and head. Cache advancement must be tracked independently of
a pending sample. Verify and trace policies still require their sampled
position; assert must not acquire runtime verification. Check EOS, cancellation,
budget limits and consumer breaks, and measure unfilled tokens for any loss
of pipeline overlap before retaining this change.
The first staged-body prototype passes 26 lifecycle/verification checks and
all five frozen 27B fixtures. Both arms retain strict fill and four-token
appends, with compiled decode disabled. Emitted IDs, cache-covered tokens,
live cache bytes and all continuation probes match. The positive fixtures
retain their injected spans with zero wasted samples and zero verification;
the two negative fixtures still inject nothing. This establishes the staged
path's tested correctness, not its speed or a universal forced-token proof.
Six complete-request pairs per fixture include an enabled-fill negative
fixture and an explicit fill-disabled control. All emitted IDs, cache-covered
tokens and injection counts match. Timing is approximately flat in every
fixture; the disabled control moves by as much as the best positive fixture.
Peak allocation is unchanged or slightly higher. Close this staging prototype
without integration: removing discarded samples does not establish a useful
complete-request gain. Evidence: `reports/qwen38-rd/fill-staged-unit.txt`,
`fill-staged-state-v13-seed42-review.json` and
`fill-staged-complete-requests-review.json`. Closed staging helpers are removed.
Superseded chunking/state/HTTP research helpers are removed; their frozen
fixtures, raw reports and the retained production append helper remain.
On default variant 6, M>4 triggers dense expansion. Experimental variants
11/12 add direct tiles and change that cost curve; span policy needs the
selected variant's measured append costs. A longer known span is not
necessarily cheaper per token. Inspect cache writes and resume logits in traces, then
time with `MLX_BUN_FILL_TRACE` unset. Measure emitted/predicted counts, total
wall time, first-tool-call latency and task success. Extend the current
grammar/KV/batch/logprobs/seed exclusions individually after their own gates.
The full experimental matrix and completion rule are in
[decode-speed-program.md](decode-speed-program.md#7-qwen38-27b-research-program).

## 8. Open items

- K3 (fill): the packed 27B positive-fill token-identity fixture passes;
  held-out/adversarial token and state identity plus a paired wall-time win
  remain before default-on (§7.4). Echo-tier policy levers before any
  rerun (§7.3); a multi-turn showcase fixture (the single-prompt one fills
  0%); the turn-8 server-crash repro (`lab/repro/serve-crash-turn8`).

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
- **2026-09-02** — K3 live A/B on the 27B (§7.3): echo tier injects 7.4%
  but wall clock ×1.00 (76% verify rejection) — gate FAILS, stays Lab; batch
  lane never fills; strict rows were silently empty on thinking templates
  (primer newline merge) — fixed.
