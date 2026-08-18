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

## Non-goals

Mirrors the PLAN.md phase: no custom weight format / new qmm kernels,
no activation quant, no runtime weight rotation, no GGUF/AWQ export.
