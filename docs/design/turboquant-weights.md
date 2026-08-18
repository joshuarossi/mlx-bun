# TurboQuant weights — rotation-folded quantization (design)

Status: opened 2026-08-17. Phase: PLAN.md "TurboQuant weights". W0 spike
not started. Companion to docs/design/turboquant-kv.md (the landed KV
leg); this is the queued weight leg from its "Future" section.

## What it is

Fold an orthogonal rotation R offline into producer/consumer weight
pairs so every weight matrix is quantized in a rotated basis where
outlier channels are smeared into near-Gaussian marginals — then
quantize with mlx's EXISTING formats (affine / mxfp4 / nvfp4). Zero
runtime cost, zero new kernels, output loadable by stock mlx-lm. The
QuaRot/SpinQuant family; composes with (does not replace) per-layer
allocation (OptiQ-style) and calibration.

Target: `Qwen3.8-27B-MTP-turbo` beating OptiQ-4bit / plain 4bit at
equal effective bpw (gate: ppl + frozen 6-task eval, eval DB rows).

## Oracle chain

"The oracle is whoever ships it": the folding mechanics come from the
reference repos, read 2026-08-17 (agent fan-out, full-file reads):

- **QuaRot** (arXiv:2404.00456, github spcl/QuaRot):
  `fake_quant/rotation_utils.py` (fuse_ln_linear, fuse_layer_norms,
  rotate_model), `fake_quant/hadamard_utils.py` (get_hadK, matmul_hadU,
  random_hadamard_matrix), `fake_quant/model_utils.py`.
- **SpinQuant** (arXiv:2405.16406, github facebookresearch/SpinQuant):
  `utils/fuse_norm_utils.py` (a copy of QuaRot's γ-fold),
  `eval_utils/rotation_utils.py` (R1/R2 folds), `optimize_rotation.py`
  (Cayley-SGD learned R — deferred to W5).

Weight layout: torch and MLX `nn.Linear` are both `[out, in]`,
`y = x @ W.T` — their fold table transfers verbatim.

## The recipe (weight-only, fully offline)

Order matters: γ-fold FIRST (R1 commutes only with gain-free RMSNorm),
then R1, then R2, then quantize.

**0. Untie embeddings** if `tie_word_embeddings` (clone into a separate
lm_head, set the flag false). Required: step 1 transforms lm_head but
not embed_tokens. (SpinQuant `ptq.py` does exactly this.)

**1. γ-fold (norm fusion)** — for each RMSNorm feeding linears,
`W' = W · diag(γ)` on the INPUT dim (columns of [out,in]), then set that
norm's γ to ones (keep the module + its eps — do NOT copy QuaRot's
replacement RMSN, which hardcodes eps=1e-5; our subjects use 1e-6):
- input_layernorm → q/k/v_proj
- post_attention_layernorm → gate/up_proj
- final norm → lm_head

**2. R1 residual fold** — one hidden-size orthogonal R1:

| matrix | transform | reason |
|---|---|---|
| embed_tokens | `W @ R1` | writes residual (rows are embeddings) |
| q/k/v_proj | `W @ R1` | reads residual (input dim) |
| o_proj (+bias) | `R1ᵀ @ W` | writes residual (output dim) |
| gate/up_proj | `W @ R1` | reads residual |
| down_proj (+bias) | `R1ᵀ @ W` | writes residual |
| lm_head | `W @ R1` | reads residual |

Q/K outputs untouched → RoPE unaffected. Input-side folds never touch
biases (bias lives on the output).

**3. R2 per-head v/o fold — SpinQuant's version, NOT QuaRot's.** Per
layer, one head_dim-sized orthogonal R2 applied block-diagonally:
v_proj output blocks get R2ᵀ, o_proj input blocks get R2; softmax
weights are R2-invariant so it cancels exactly, incl. under GQA (same
R2 for all heads; repeat_kv replicates whole heads). QuaRot's variant
folds a FULL Hadamard into o_proj and needs an ONLINE cross-head
Hadamard (`online_partial_had`) to cancel — folding its v-side alone
breaks the network. Skip QuaRot's pairing entirely.

**4. Quantize** the folded weights with the stock convert path
(affine g64 / mxfp4 / nvfp4 arms).

### Deviations from the references (decided, with reasons)

- **No embedding mean-centering.** Their `fuse_layer_norms`
  mean-centers embedding rows (SliceGPT LayerNorm→RMSNorm trick). For
  RMSNorm models this is NOT an exact-invariance (RMSNorm doesn't
  subtract means) — they do it anyway; we don't, because W0's exit
  criterion is logit parity of the folded bf16 model.
- **Delete the hidden R4 half-fold.** BOTH repos'
  `rotate_mlp_output` unconditionally applies a full Hadamard to
  down_proj's input dim right after the R1ᵀ fold — that is the offline
  HALF of R4 and requires the runtime `online_full_had` on down_proj's
  activation. Weight-only must skip both halves together (their line:
  QuaRot rotation_utils.py:173 / SpinQuant eval_utils/rotation_utils.py
  98-100). The `R1ᵀ @ W_down` part stays.
- **No R3.** Post-RoPE Q/K rotation exists only for KV-cache quant
  (their code registers it only when k_bits < 16). Our KV story is the
  landed TurboQuant KV codec — online rotation remains KV-only.
- **Fold precision: fp32, not fp64.** References fold in fp64 (fp16-era
  caution). Our weights are bf16 (8-bit mantissa); fp32 accumulation at
  n≲6k leaves ample headroom. Escape hatch if the W0 parity gate fails:
  generate fold goldens in the oracle venv (mlx CPU float64).

### R generation

- Random-Hadamard R1 = `diag(±1 signs) · H_n / √n` (QuIP#-style).
  Non-pow-2 n via Kronecker: n = K·2^m with hardcoded H_K, K ∈ {12, 20,
  28, 36, 40, 44, 52, 60, 108, 140, 156, 172}; else n must be pow-2.
  QR-of-Gaussian `random` mode works for any n (fold-time only, speed
  irrelevant).
- R2 default: plain Hadamard of head_dim (must be pow-2) or any
  orthogonal.
- Seed-pin and persist R1/R2 (sidecar JSON in the output snapshot) for
  reproducible artifacts; R is never needed at runtime.
- W5 (only if random-R wins first): SpinQuant Cayley-SGD learned R1 +
  per-layer R2, folded identically afterward.

## W1 — Qwen3.8 (qwen3_5) corridor map (2026-08-18, from src/model/qwen3_5.ts
+ src/spec/qwen-mtp-source.ts + src/vision/qwen3vl-tower.ts + tensor dumps)

**R2 is architecturally OFF for this family:** full attention computes
`o_proj(attention_output · σ(gate))` — q_proj emits 2×head_dim per head and
the gate multiplies the attention output ELEMENTWISE in head space. An
elementwise gate does not commute with a per-head rotation, so only γ+R1
apply. hidden 5120 = 20·256 — mlx's hadamard_transform takes it natively
(m·2^k, m ∈ {1,12,20,28}; verified live).

Trunk corridors (prefix `language_model.`):
- readers (@R1 input dim, γ folded in): self_attn.q/k/v_proj,
  linear_attn.in_proj_{qkv,z,b,a}, mlp.gate/up_proj, lm_head (γ = model.norm)
- writers (R1ᵀ output dim): self_attn.o_proj, linear_attn.out_proj,
  mlp.down_proj
- vision: `vision_tower.merger.linear_fc2` weight+bias is the ONLY
  vision→residual seam (deepstack is empty for qwen3_5 and not ported) —
  output-dim fold; everything else in the tower passes through bf16
- untouched internal bases: q_norm/k_norm (head-space), linear_attn.{norm,
  A_log, conv1d, dt_bias} (post-projection), rotary
- 27B trunk is untied; the 0.8B proof subject is tied (untie step exercised)

MTP companion (separate artifact, same seed/R1 — shared residual basis):
- `fc [H,2H]`: input block 0 = embedding stream (γ = pre_fc_norm_embedding),
  block 1 = hidden stream (γ = pre_fc_norm_hidden) — per-block γ+@R1 — plus
  an output-dim R1ᵀ fold; both pre-fc norms → ones
- `layers.0`: standard full-attention corridor treatment
- **final `norm` γ is DROPPED (→ ones):** it feeds the SHARED trunk lm_head,
  which already carries the trunk's final γ. Draft logits therefore see
  γ_trunk instead of γ_mtp — draft-quality-only (the verified target path is
  exact); revisit lever = ship a private folded head inside the companion.

Small-scale proof (0.8B, dequantized from OptiQ-4bit since no bf16 is
published; fold-parity on dequant-vs-folded-dequant tests the fold exactly):
teacher-forced logits through STOCK mlx-lm (also the W2 cross-stack check) —
worst per-position KL 0.00353, argmax flips 2/42 positions BOTH at reference
margin 0.0 (exact ties). scripts/experiments/{dequant-model,fold-qwen35}.ts +
tq-fold-parity.py.

Quantization packaging (CORRECTED 2026-08-18: OptiQ does NOT fully strip
vision — its main weights omit it but `optiq/optiq_vision.safetensors`
carries it, and `optiq/mtp.safetensors` bundles MTP; their artifact also
publishes `optiq/sensitivity.json` — per-layer KL sensitivities for
{4,8}-bit g64 against the SAME bf16 trunk, the ready-made allocation
input for a GPTQ+sensitivity mixed pass. No kv_config.json is published.)
Our packaging: language modules quantize uniformly (embed + lm_head
included), `vision_tower.*` is predicate-excluded and stays bf16 both
IN-MAIN (mlx-vlm compatible — OptiQ's sidecar-only vision is not) and as
the `optiq/` sidecar, so one self-contained artifact serves text+vision
across stacks.

## Subject models

- **W0/W3: mlx-community/Llama-3.2-1B-Instruct-bf16** (~2.5 GB; the
  reference repos' literal target family; 4bit sibling already proven
  in our engine; TIED embeddings → exercises step 0). MiniCPM5-1B has
  no published mlx bf16 (would need a dtype-convert of openbmb's torch
  weights) — alternate subject if Llama surprises us; its geometry is
  fold-friendly too (model_type llama, untied, head_dim 128,
  hidden 1536 = had12 ⊗ H128, eps 1e-6).
- **W4: mlx-community/Qwen3.8-27B-bf16** (11 shards, 54.7 GB) +
  `Qwen3.8-27B-MTP-bf16` companion (~850 MB, local). The companion
  shares the trunk's residual basis → must fold consistently (W1
  decision). DeltaNet linear-attention corridors: folding math not in
  the papers; derive or fall back to allocation-only for those blocks
  (community quants mark exactly those projections sensitive).

## W3/W4 measured curve (2026-08-18, RTN affine g64, ppl via stock mlx-lm
on the local UF-derived corpus, seq 512; M1 Max 32 GB)

**Headline: rotation-only + RTN does NOT beat plain RTN at the 4-bit
operating point; it wins decisively at 3-bit — the paper's law, reproduced.**
Per-module function-space Frobenius error is a wash at 4-bit (~0.091 all
arms, scripts/experiments/tq-quant-error.py — γs are tame, 0.7–2.7, no
module class is the culprit); the 4-bit regression is the anisotropy story
(isotropic rotated error vs activation-aligned plain error), which is
exactly what GPTQ-style calibration fixes — the composition the paper and
this doc already name as the real win.

0.8B lab (dequant-OptiQ source; PAIRED arms; bf16 anchor 6.41, 48×512):

| arm | bpw | ppl |
|---|---|---|
| plain 4-bit | 4.50 | 7.01 |
| TQ(R1+γ) 4-bit | 4.50 | 7.39  ← regression, reproduces 27B |
| plain 3-bit | 3.50 | 19.19 ← RTN collapse |
| **TQ 3-bit** | 3.50 | **14.54** ← rotation −24% ppl |
| plain mixed (3-bit MLP, 4-bit attn/embed) | 4.15 | 9.69 |
| **TQ mixed (same profile)** | 4.24 | **9.22** ← paired rotation win |

27B (32×512, same corpus): plain 4-bit 4.659 ±0.093 (4.50 bpw, 15.0 GB) ·
TQ 4-bit 4.923 ±0.102 (+5.7%, consistent with the lab) · **TQ-mixed
(4-bit attn/embed + 3-bit MLP) 4.932 ±0.098 at 3.86 bpw / 13.9 GB** —
matches rotated-uniform-4-bit quality at −0.64 bpw; the artifact of
record for the 14z M4-Pro fit lever.

AWQ-style equalization spike (norm-carried per-channel scales, α=0.5,
function-preservation verified at KL 0.0037/0 flips): TQ+eq 7.363 (≈no
change), plain+eq 7.809 (HURT — per-channel scales inside a g64 group
widen group ranges; real AWQ grid-searches a far gentler α and the real
4-bit fix is GPTQ-style compensated rounding). Scripts kept:
tq-collect-actstats.py + tq-equalize.ts.

**End-to-end validation of the TQ-mixed 27B artifact (2026-08-18, M1
Max, busy box — correctness only):** server chat with correct arithmetic
reasoning (thinking → `reasoning` field); vision through the folded
merger + sidecar correctly identifies the gradient fixture's colors over
HTTP; MTP via the 14g harness with the same-seed folded companion: 71%
acceptance, 2.40 tok/target-forward, arms token-identical (losslessness),
ON/OFF 0.726× (consistent with the stock 0.821× correct-but-slower
verdict; MTP stays opt-in).

Consequences for the release recipe: do NOT ship rotated uniform-4-bit
(loses to the trivial baseline); the shipping artifact is the TQ-mixed
≤4 bpw band where rotation is decisively ahead (paired no-rotation
control worse; uniform-3-bit −24% ppl). The 4.5-bpw flagship win waits
for the calibration composition (GPTQ on ROTATED weights — the W5 leg).

## W5a corrected-GPTQ matrix (2026-08-18; 0.8B lab, 4.5 bpw arms, 48×512
ppl, anchor = dequant-OptiQ 6.41 — verified lossless: original OptiQ
scores 6.4077)

mlx-lm's shipped GPTQ (`mlx_lm/quant/gptq.py`) has TWO real defects that
partially cancel: the in-loop update window is `k:k+j` (over-propagates
past the block edge; must be `k:j` — the k term itself writes the
quantized value since e·Hinv[k,k] = w−q) and `err[..., k:k+1]` indexes a
group-local buffer with the GLOBAL k (mlx out-of-range slice assignment
silently no-ops → cross-group propagation lost after block 0). Fixing
only err DOUBLE-compensates [j, k+j) and REGRESSES below RTN (measured:
7.22/7.50); fixing both = paper GPTQ. Worth an upstream report.
Fork: scripts/experiments/tq-gptq.py (also restricts GPTQ+fallback to
language modules — vision H is a zero scalar and stays bf16).

| arm | ppl |
|---|---|
| **plain + GPTQ (fixed)** | **6.741** |
| TQ(R1) + GPTQ (fixed) | 6.847 |
| plain RTN | 7.010 |
| TQ RTN | 7.390 |

**Verdict: calibration is the main course; rotation SUBTRACTS at the
4-bit band even under GPTQ on this family** (gap −1.6%; GPTQ closes half
the RTN→anchor gap). Rotation remains the sub-4-bpw lever (−24% at
3-bit). Flagship recipe = plain + GPTQ 4-bit; TQ-mixed stays the
small-footprint variant. 27B needs a chunked Hessian/GPTQ driver (stock
flow = whole bf16 model + all Hessians resident; down_proj H = 1.2 GB
f32 each).

## W5c 27B production results (2026-08-18)

**v2 run (uniform GPTQ-4): BROKEN artifact (ppl 306k).** Root cause,
evidence-backed: the compensation loop DIVERGED on layers with
rank-deficient calibration Hessians (layer-0 down_proj group scales grew
0.003 → 27 monotonically across columns, max 2.8e7; cosine ~0 vs source;
neighbors healthy). Early layers see low-rank activations (layer-0 input
= raw embeddings; rank ≤ distinct calibration tokens), so 5120 dims
outran the standard 1% damping — the 0.8B (1024 dims) never hit it,
which is why validation passed there.

**v3 fixes (all landed):** divergence guard in `gptq_one_guarded`
(GPTQ scales vs 4× the RTN scale ceiling per matrix; damping escalation
1e-2→10; RTN fallback = never worse than RTN); 4× calibration (128×512);
sensitivity-driven per-module bits from OptiQ's published
sensitivity.json (semantics: `sensitivities[b]` = measured KL GAIN at b
bits — first read had the sign flipped and allocated 0 modules); greedy
benefit-per-param to `--target-bpw`. v3 27B: 169 modules @8-bit,
4.80 bpw, 17.0 GB, ZERO guard triggers (the calibration bump fixed
conditioning outright), 64 layers in 166 min, per-layer checkpoints.

**27B ppl ladder (73×512, UF corpus, stock mlx-lm):** plain RTN-4
4.570 ±0.060 · OptiQ 5.14 bpw 4.574 ±0.061 · GPTQ+sens 4.80 bpw
4.618 ±0.061. **At 27B every sane ≥4.5-bpw recipe SATURATES this
instrument** — OptiQ's +0.6 bpw buys nothing measurable, and GPTQ shows
a small consistent deficit (likely calibration-domain mismatch:
calibration_v5 vs chat-flavored eval text). This contradicts the 0.8B
lab ordering (GPTQ clearly won there) — quantization robustness grows
with scale. Decision moves to task benchmarks: MMLU-100 + GSM8K-50
across {GPTQ-v3, plain4, OptiQ, TQ-mixed}, eval DB rows.

## FINAL BOARD + DECISION (2026-08-18 night 2)

Task evals (lean mlx-lm runner, paired items; in-engine sweep swap-thrashed
the box — 73 GB swap at 0.7 GB resident — killed, gap recorded below):

| arm | bpw | GB | ppl(73×512) | MMLU-100 | GSM8K-50 |
|---|---|---|---|---|---|
| **GPTQ+sens v3 (SHIPPED as mjriii/Qwen3.8-27B)** | 4.80 | 16.3 | 4.618 | 87 | **96** |
| plain RTN 4-bit | 4.50 | 15.0 | **4.570** | 88 | 94 |
| OptiQ published | 5.14 | 18.1 | 4.574 | **89** | 92 |
| TQ-mixed (staged, small-footprint variant) | 3.86 | 13.0 | 4.93 | 82 | 96 |

All ≥4.5-bpw arms statistically tied on every instrument — 27B quality
SATURATES at 4-bit; recipes differentiate below 4 bpw and on
completeness. THE artifact = v3 (never trails; protective recipe;
one-repo vision+video+MTP; additive to the ecosystem where plain-4bit
already exists publicly). Serve gauntlet on THE artifact through OUR
engine: text ✓ (23×19), image ✓ ("Green and pink"), video ✓ (gradient
motion described; AVFoundation chain), MTP harness 76% accept /
2.53 tok-per-forward with an output-divergence flag vs plain greedy
(consistent with verify-width reduction-order near-ties, 12B step-0
class — margin analysis queued; NOT claimed lossless on the card).

## Known engine gaps found in passing (not TQ defects)

- `mlx-bun perplexity` cannot score qwen3_5: it routes through
  `trainForward`, whose cache stub lacks the DeltaNet `SSMCache.advance`
  (`qwen3_5.ts:226` throws on BOTH plain and TQ arms identically).
  27B ppl therefore runs through stock mlx-lm
  (scripts/experiments/tq-ppl.py) — which doubles as the cross-stack
  load check for the release artifact.
- bf16 (unquantized) qwen3_5 trunks don't load in our engine:
  `QuantizedEmbedding.load`/`QuantizedLinear.load` hard-require `.scales`.
  The small-scale fold proof ran through stock mlx-lm instead.
- `scripts/eval.ts` capability tasks at 27B swap-thrash a 32 GB box
  (73 GB swapfiles, process 95% paged out) where the mlx-lm scoring path
  is fine — investigate the in-engine eval memory profile.
- Qwen MTP via the HTTP serve lane 500s with `[slice] Invalid number of
  indices or strides for array with dimension 3` — REPRODUCES WITH STOCK
  ARTIFACTS (plain-4bit trunk + original mlx-community MTP companion,
  `serve --draft-model <companion> --draft-kind mtp`, any chat request),
  so it is a pre-existing serving-path bug, not TQ. The 14g harness path
  (specServeRun via scripts/experiments/qwen38-mtp-ab.ts) is the green
  gate; TQ MTP was validated through that.

## Non-goals

Mirrors the PLAN.md phase: no custom weight format / new qmm kernels,
no activation quant, no runtime weight rotation, no GGUF/AWQ export.
