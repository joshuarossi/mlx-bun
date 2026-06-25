# DiffusionGemma port — plan & parity strategy

Porting **DiffusionGemma-26B-A4B-it** (`mlx-community/diffusiongemma-26B-A4B-it-OptiQ-4bit`,
14 GB, model_type `diffusion_gemma`) into mlx-bun, holding **L2 parity with
mlx-optiq**. This is the first **non-autoregressive** model in the codebase:
it fills a fixed 256-token *canvas* and un-masks it over a few denoising steps
rather than generating left-to-right. mlx-optiq docs:
https://mlx-optiq.com/docs/diffusion

> Status doc: STATUS.md. Durable phase log: PLAN.md. This file is the design +
> phase plan for this one feature; promote the phase checklist into PLAN.md once
> approved.

## The parity oracle (resolved 2026-06-24)

**Stock mlx-lm/mlx-vlm cannot load this model** — there is no bf16 ancestor in
the usual L1 sense. OptiQ ships a *vendored, dependency-free decoder*, so **the
oracle IS mlx-optiq itself**. The mixed-precision quant in the checkpoint is the
model's native weight format (not an optional L3 layer), so **matching optiq's
output = L2 = the correctness floor here.**

- Reference is now installed: `mlx-optiq 0.2.7` in
  `/Users/joshrossi/Code/mlx-lm/.venv` (upgraded from 0.2.1; the diffusion
  decoder needs ≥0.2.3). `mlx`/`mlx-lm`/`mlx-metal` stayed pinned at
  **0.31.2 / 0.31.3 / 0.31.2**, so the existing parity oracles (Gemma/CPM/Qwen)
  are **unaffected** — verified by `pip install --dry-run`.
- Reference source (read these; they are the contract):
  - Model: `optiq/vlm/_mlxvlm/models/diffusion_gemma/`
    — `language.py` (802 L, the core: Attention, Router/Experts MoE,
    DecoderLayer, SelfConditioning, DecoderModel `_embed_canvas` /
    `_make_decoder_masks`, EncoderModel vision merge), `diffusion_gemma.py`
    (178 L, top `Model` + `sanitize` + `quant_predicate`), `config.py` (87 L),
    `processing_diffusion_gemma.py` (137 L).
  - Engine: `optiq/vlm/_mlxvlm/generate/diffusion.py` (1148 L) — canvas init,
    linear temperature schedule (`t_min`→`t_max`), the un-mask loop, the two
    samplers (`confidence-threshold` default in OptiQ, `entropy-bound` model
    default), self-conditioning feedback, stability/EOS handling.
  - OptiQ surface: `optiq/vlm/diffusion_gemma/{loader,generate,lora,
    calibration,convert,eval_adapter}.py` (load/generate/train entry points).
- Run the reference with `/Users/joshrossi/Code/mlx-lm/.venv/bin/python`. Golden
  dumps for parity tests go through `optiq.vlm.diffusion_gemma.{load,generate}`.

## What the checkpoint actually is (from config.json + weight map)

- `architectures: ["DiffusionGemmaForBlockDiffusion"]`, `canvas_length: 256`,
  `model_type: diffusion_gemma`, bf16 base, OptiQ mixed-precision quant
  (group_size 64, bits ∈ {4,8} per-tensor; 8-bit budget on **early-layer
  attention + routers**, 4-bit on dense MLPs — inverse of the hand-coded recipe).
- **Language tower** `model.decoder`: 30 layers, hidden 2816, 16 heads. Each
  layer runs a **parallel dense `mlp` + routed MoE** branch (128-expert top-8,
  `router.proj` + `experts.{gate_up,down}_proj`) summed via 7 RMSNorms + a
  `layer_scalar` — conceptually the gemma4 parallel-branch idea, but DIFFERENT
  geometry/norm-placement than our gemma4-26B (verify, don't assume reuse).
  Attention is **scale=1.0, QK/V-norm post-proj/pre-RoPE, NO attention softcap**
  (only `final_logit_softcapping=30.0`, fp32); sliding layers hd=256/kv=8, full
  layers (5,11,17,23,29) hd=512/kv=2 + partial-rotary 0.25. Plus
  `model.decoder.self_conditioning` (gate/up/down MLP) — diffusion-specific.
- **Vision tower** `model.encoder.vision_tower`: 27-layer SigLIP
  (`patch_embedder.input_proj` + `encoder.layers.N.{self_attn,mlp}`). We already
  have a SigLIP port in `src/vision/siglip.ts` (16-layer for e4b) — likely
  reusable with a layer-count/config delta. image-text-to-text.
- Generation config: `max_denoising_steps: 48`, `max_new_tokens: 256`,
  `confidence_threshold: 0.005`, `t_min: 0.4`, `t_max: 0.8`,
  `stability_threshold: 1`, default `EntropyBoundSamplerConfig(entropy_bound=0.1)`,
  `eos_token_id: [1, 106, 50]`.
- New tokenizer + chat template (`<|turn>role`, `<|channel>thought`,
  `<|tool>`/`<tool|>` blocks, `<|image|>`). The canvas is initialized to
  **uniform-random token IDs** (`randint(0, vocab_size)`), NOT a mask token —
  no discrete mask-token path is used at inference (dossier §9.1).

## Architecture deltas vs what we already have

(Refined after D0 — see the dossier for exact shapes/math.)

| Piece | Reuse / new |
|---|---|
| MoE Router + Experts (128-expert, top-8, `SwitchLinear` `_gather_sort`) | **Reuse/adapt** gemma4.ts — but router norm is **pre**-projection + `scale`·`hidden**-0.5`, weights `*per_expert_scale`; verify against gemma4 |
| Attention — QK/V-norm **post-proj/pre-RoPE**, **scale=1.0, NO attn softcap**, partial-rotary 0.25 on full layers | **Adapt** gemma4.ts Attention (geometry differs: sliding hd=256/kv=8, full hd=512/kv=2; full layers reuse k as v) |
| SigLIP vision tower (27 layers, hidden 1152, patch 16) | **Reuse** src/vision/siglip.ts with config delta + `MultimodalEmbedder` merge |
| Quantized linear / mixed-precision load | **Reuse** loader; read per-tensor bits from `config.quantization` map (not just the predicate) |
| Tied LM head via quantized `embed_tokens.as_linear()` | **New-ish** — need quantized transpose-matmul + `quantized_matmul(...,transpose=False)` for soft embeds |
| `_embed_canvas` (hard embed + soft self-cond signal) | **New** |
| Bidirectional / block decoder masks (`_make_decoder_masks`) | **New** — NOT causal; **the crux / highest bug-risk** |
| `SelfConditioning` MLP + per-step soft-embedding feedback | **New** |
| Denoising engine (uniform-random canvas init, linear temp schedule, un-mask loop, 2 samplers, stability/EOS) | **New** — a whole second generation path |
| Cache mix: `KVCache` (full) + `RotatingKVCache(1024)` (sliding); decoder reads encoder K/V from cache state | **Reuse/adapt** — `_cache_offset`/`_cache_state` helpers |
| Tokenizer + chat template + image processor (variable soft-token budget) | **New** |
| ~~Canon depthwise-conv~~ | **N/A — absent in checkpoint** |

## Phase plan (exit criteria)

### D0 — Recon & reference dossier `[x]` (done 2026-06-24)
Dossier appended below ("Reference dossier (D0)"). Headline corrections to the
pre-recon assumptions: **no Canon/depthwise-conv tensors exist** (pure
transformer); the **LM head is tied** (`embed_tokens.as_linear()`, a 4-bit
`QuantizedEmbedding`); shapes are **hidden 2816 / 30 layers / 16 heads** (NOT the
gemma4-26B geometry); each layer runs a **parallel dense-MLP + MoE** branch with
**7 RMSNorms + a `layer_scalar`**; attention is **scale=1.0 with no attention
softcap** (only `final_logit_softcapping=30.0`, fp32); the canvas is initialized
to **uniform-random token IDs**, not a mask token. Full detail + 12 risk items
below.

#### Original D0 brief
Read the entire reference and write it down so D1–D3 are mechanical. Done as a
**parallel-reader workflow** (see Orchestration). Produces, appended to this doc:
a component-by-component spec of `language.py` + `diffusion_gemma.py`, the
weight-name → module map audited against the real checkpoint (0 missing / 0
unused), the exact `_make_decoder_masks` construction, the denoising-loop
pseudocode, both sampler algorithms, the self-conditioning data flow, and the
tokenizer/chat-template/mask-token facts.
**Exit:** dossier complete; weight-name audit clean; golden-dump harness sketched.

### D1 — Single-forward parity (the static graph) `[x]` (done 2026-06-24 — BIT-EXACT)
**DONE.** `src/model/diffusion-gemma.ts` (`DiffusionGemmaModel`) + factory detection
(`isDiffusionGemmaConfig`; serving still throws "wired in D3" — the AR `RuntimeModel`
union is left untouched so the 96 script-callers don't break). One full forward over
the real 14 GB checkpoint — **encoder prefill → bidirectional decoder canvas pass
(`_make_decoder_masks`) → parallel dense-MLP + 128-expert MoE → SelfConditioning →
tied 4-bit head → fp32 softcap** — is **BIT-EXACT vs the optiq golden**: argmax 256/256,
maxDiff 0.0, relRMSE 0.0, meanKL 0.0 (`tests/diffusion-parity.test.ts`,
`MLX_BUN_TEST_DIFFUSION=1`). Per-stage sub-gates (enc_hidden / dec_hidden / presoftcap /
per-layer / layer-0 attn·dense·MoE) all 0.0 (`scripts/experiments/diffusion-{stage,layer,l0}-diag.ts`,
golden dumps in `scripts/gen-diffusion-golden.py`).
- **The one bug found + fixed (per-model parity gotcha):** the Router pre-projection
  norm must be the literal two-step `rms_norm(x, None, eps) * scale * hidden**-0.5`,
  **NOT** the gemma4-style fold `rms_norm(x, scale*hidden**-0.5)`. The fold changes the
  bf16 intermediate rounding → shifts the softmax routing weights by ~0.01 → 1.7% on the
  expert output → 12.7% by the encoder output (argmax mostly survived, masking it). Same
  experts selected (0/21 set mismatch); only the *weights* drifted. Copy-verbatim
  methodology localized it: attn / h_mid / dense-MLP were already 0.0, only the MoE branch
  diverged.
- Vision merge deferred to D3 (golden is text-only; the 27-layer SigLIP tower is present
  in the checkpoint and wired via `parseSiglipConfig` when D3 lands).

### D1 — Single-forward parity (the static graph) — original brief `[x]`
`src/model/diffusion-gemma.ts` + config detection (`support.ts`
`isDiffusionGemmaConfig`) + factory wiring. Port embed_canvas, DecoderLayer
(attn + dense MLP + MoE parallel + softcap), SelfConditioning, the bidirectional
decoder masks, vision feature merge (reuse siglip), final norm + head.
Sub-gates (model-free where possible, then on real weights): vision features
bit-exact; one decoder layer bit-exact; MoE block bit-exact; self-conditioning
bit-exact.
**Exit:** **one full forward over the real 14 GB checkpoint produces logits
bit-exact vs the optiq reference** (Python golden dump through
`optiq.vlm.diffusion_gemma`), at a fixed canvas state. This is the L2 oracle for
the graph; where the quantized GEMV is 1-ULP off (the known megakernel finding),
gate by KL + argmax-agreement, not the bit-exact golden.

### D2 — Denoising generation engine `[x]` (done 2026-06-24 — token-for-token)
**DONE.** `src/diffusion/diffusion-generate.ts` (`diffusionGenerate`): prefill→cache
reuse, linear temp schedule, the un-mask loop, BOTH samplers (confidence-threshold =
OptiQ public default, entropy-bound = engine default), self-conditioning feedback,
stability/EOS, canvas block loop. **Token-for-token parity vs the optiq engine at
temp 0 on a fixed seed for BOTH samplers** (`tests/diffusion-gen-parity.test.ts`,
`MLX_BUN_TEST_DIFFUSION=1`; golden `scripts/gen-diffusion-gen-golden.py`):
confidence 17 tok / 7 steps, entropy 15 tok / 48 steps — both `.tokens`/`.steps`/
`.finishReason` identical.
- **RNG parity (the crux) SOLVED:** bound `mlx_random_randint` (+`mlx_random_seed`,
  `mlx_cummax`, `logicalNot`/`equal`/`all`/`anyAxis`/`lessEqual`/`itemBool`) in
  `ffi.ts`/`ops.ts`. `ops.randint(key=null)` threads the GLOBAL mlx key, so seeding +
  calling randint in the same ORDER as the reference (1 canvas init + 1 re-noise per
  non-final step) reproduces every draw bit-for-bit. Verified standalone: 0/256
  mismatch across consecutive draws.
- **Three bugs found + fixed:** (1) `processed = logits / schedT` must be a **division**,
  not reciprocal-multiply — the f32 rounding differs and the 0.9 confidence threshold
  is a hard cutoff that flips acceptance on 1 ULP, diverging the trajectory (was 8 vs 7
  steps). (2) `history.push` needs an **independent copy** (add-zero) — a reshape/view
  aliases the argmax buffer and reads freed data after disposal → false "stable" →
  premature stop. (3) **The as-loaded oracle has `model.config.generation_config = None`**,
  so `stable_and_confident` is a NO-OP (entropy runs all 48 steps) and the eos set is the
  tokenizer's `stopping_criteria` = **{1, 106}** (50 is NOT eos despite generation_config.json).
  L2 parity = match the oracle as it RUNS: stable-stop OFF unless explicitly configured.
- Multi-block continuation (`extendPrefill`) is wired but only single-block is gated
  (max_tokens 64 ≤ canvas). temperature>0 (categorical) + image input deferred to D3.

### D2 — Denoising generation engine — original brief `[x]`
`src/diffusion/` (or `src/generate-diffusion.ts`): canvas init, linear
temperature schedule, the un-mask loop, `confidence-threshold` (OptiQ default,
the L2 target) AND `entropy-bound` (model default) samplers, self-conditioning
feedback, stability/EOS termination. Deterministic harness (same canvas init →
same final tokens), parity vs optiq `generate(...)`.
**Exit:** full deterministic generation matches optiq **token-for-token** for
both samplers on a fixed seed/prompt set (text-only first). Step-count and
final-canvas match.

### D3 — Serving + CLI + image input `[x]` (DONE 2026-06-24 — text + image, parity-exact)
**IMAGE-TEXT-TO-TEXT DONE — token-for-token parity.** A DEDICATED DiffusionGemma vision
tower (`src/vision/diffusion-vision.ts`, `DiffusionVisionTower`) — its OWN module, NOT a
reuse of the e4b SigLIP path (they're separate models: e4b ships a bf16
`optiq_vision.safetensors` sidecar, DiffusionGemma's vision is inline-quantized). A
parity-exact op-for-op port of optiq's gemma4 `VisionModel` at the DiffusionGemma geometry
(hidden 1152, head_dim 72, 16 heads, 27 layers, position_embedding_size 10240, standardize ON).
Wired through the encoder vision merge (`#embedInputsVision` masked-scatter + `#encoderVisionMask`
causal|overlay) into the denoising engine; `preprocess()` (resize/rescale) + `spliceImageTokens`
build the prompt. **Verified end-to-end** (`tests/diffusion-vision.test.ts`): spliced ids EXACT
vs optiq + generation TOKEN-FOR-TOKEN ("This is a solid gray square." on grad-768) + **served
live** via the OpenAI vision API. Server branch in `handleChat` (diffusion gets its own vision
lane; v1 = single image); `generate()` threads `visionPixels`.
- **Three vision bugs found + fixed (copy-verbatim per-stage diffing, dequant→bit-exact):**
  (1) **input_proj is QUANTIZED (uint32 weight)**, so the reference's
  `patches.astype(input_proj.weight.dtype)` TRUNCATES the `2*(x-0.5)` patches to integers
  (mostly 0) before the matmul — a trained-in quirk e4b never hit (its input_proj is bf16). The
  patchembed went bit-exact once replicated. (2) head_dim 72 isn't a fused-SDPA size; the
  reference `ensure_fused_sdpa` PADS to 80 (zeros) and slices back — replicating it dropped the
  per-layer error from 0.28% to ~bf16-noise. (3) `down_proj` is plain bf16 (not quantized) —
  a `VisionLinear` that is quantized-or-plain. Residual: ~2.3% feature relRMSE from 27-layer bf16
  accumulation (the e4b-class tier), which the denoising is robust to → identical tokens.

### D3 — Serving + CLI + image input — earlier note `[x]`
**TEXT serving DONE + verified live.** `createModel` returns `DiffusionGemmaModel`
(added to the `RuntimeModel` union with the AR-only surface — `forwardHidden`/`forward`/
`generate`/`forwardEmbeddings` — as throwing stubs, real `loraState`/`loraTargets`/
`prefixBase`/`makeCache`, so the 96 AR script-callers still typecheck; baseline held at
117). `generate()` detects the model and routes to the denoising engine
(`generateDiffusionInner`), preserving the `Generation`/`GenerateStats` contract so the CLI
and server stream it through the existing token machinery. The gateway keeps diffusion on
the serial lane (`willBatch` returns false for it). CLI (`mlx-bun generate`) +
`greedyDecodeBitExact` bypass wired (`src/eval/runner.ts`). **Verified live** against a
running server (`mlx-bun serve diffusiongemma --port 8899`): OpenAI chat (stream +
non-stream), Anthropic `/v1/messages`, `/v1/models`, single- AND multi-block — all coherent
("The capital of France is Paris.", correct primary-colors answer). Gate:
`tests/diffusion-serving.test.ts` (4/4, `MLX_BUN_TEST_DIFFUSION=1`). No AR regression
(instanceof-guarded branches; typecheck baseline preserved).
- **Streaming UX:** v1 runs the engine to completion then yields tokens (the existing SSE
  machinery emits them as deltas). True per-block intra-stream + temperature>0 (categorical)
  are noted follow-ups.
- **REMAINING (image-text-to-text):** the 27-layer SigLIP tower IS in the checkpoint
  (`parseSiglipConfig` handles it) but the diffusion vision path is NOT wired yet — needs the
  encoder vision merge (`_embed_inputs` masked_scatter + `_vision_block_overlay` bidirectional
  overlay), the `<|image|>`→`boi+image_token*N+eoi` splice + `mm_token_type_ids`, the SigLIP
  weight-name adaptation (`.linear` suffix, `patch_embedder`), and an image-text-to-text golden.

### D3 — Serving + CLI + image input — original brief `[~]`
Wire DiffusionGemma into `generate.ts`/`cli.ts`/`server.ts` as a model that
routes to the diffusion engine instead of the AR loop. Decide streaming
semantics (canvas isn't left-to-right — stream per denoise-step or on
stabilization). Image input through the existing vision path. Onboarding/registry
entries; supported-model lists.
**Exit:** `mlx-bun serve` + `mlx-bun generate` answer text **and** image prompts;
output matches optiq `generate`; HTTP test green; no regression to AR models.

### D4 — Performance (L3, optional, measured) `[ ]`
`confidence-threshold` is already the fast path (optiq: ~58 tok/s code / ~9
prose). Measure mlx-bun tok/s with `benchmark.sh`; fuse kernels only if a number
says so. KV holds only the prompt (no per-step growth → no KV-quant needed).
**Exit:** quotable tok/s within range of optiq on this machine; any fused kernel
gated by KL + the 6-task quality suite (no bit-exact ancestor for novel fusions).

### D5 — Diffusion-native LoRA `[x]` (done 2026-06-24 — trains, loss decreases)
**DONE.** `src/train/diffusion-lora.ts` (`trainDiffusionLora` + `diffusionLoss`): port of
optiq's denoising-objective LoRA (NOT AR cross-entropy). Corrupt the target canvas to a
random noise level t∈[t_min,t_max] (uniform-random token per position with prob t), one
encoder+decoder forward, CE on the CORRUPTED positions. LoRA mounts on the decoder blocks
(DEFAULT_LORA_KEYS = attn q/k/v/o + dense MLP gate/up/down; the `loraTargets` map skips
full-layer v_proj), reusing the existing training stack (`buildTrainableLora`/`ValueAndGrad`/
`AdamW`/`saveAdapter`). **The MoE backward works** by `stop_gradient`-ing the router top-k
indices (identity in the forward → D1/D2 stay bit-exact; lets the gather_qmm vjp differentiate
only the activations). Autograd flows end-to-end through BOTH passes (encoder cache sliceUpdate
+ decoder cross-attention concat + MoE). **Verified** (`tests/diffusion-lora.test.ts`): loss
3.91 → 1.20 over 30 iters on one example, all finite, and the trained adapter changes the canvas
logits (maxDiff 22.4). Mountable via the existing AdapterManager (`lora_a`/`lora_b` layout).

### D5 — Diffusion-native LoRA — original brief `[x]`
Port `optiq/vlm/diffusion_gemma/lora.py` (the denoising objective, not AR
cross-entropy) into the training stack. Deferred unless prioritized.
**Exit:** a LoRA trains end-to-end on `{prompt, completion}` data, loss
decreases, adapter mounts and changes generation.

## Risks / open questions (resolve in D0)

- **Bidirectional masks** are the highest-risk port — block-diffusion attention
  is not causal; `_make_decoder_masks` + `_vision_block_overlay` define it.
- **"Canon depthwise-conv layers"** (per docs) — no conv tensors appeared in the
  quant config scan; confirm whether this checkpoint has them and where.
- **Self-conditioning ordering** in the step loop (when the previous prediction
  is fed back) must match exactly or generation diverges.
- **mask_token_id** + canvas init RNG must match optiq for deterministic parity.
- **Vision tower delta**: 27 layers here vs 16 in the e4b siglip — confirm config
  fields, pooling, and whether the same `SiglipVisionTower` covers it.
- **Streaming UX**: define how a canvas maps to token-stream SSE (D3 decision).

## Scope (confirmed with Josh 2026-06-24)

- **Text + image together.** The 27-layer vision merge is built into D1 from the
  start; v1 ships image-text-to-text. (Heavier first-parity, but the model is
  natively multimodal and that's the target.)
- **D5 LoRA is IN scope** — port optiq's denoising-objective `train_diffusion_lora`
  after the inference path (D1–D4) is green.
- **Generation parity is the bar**, not serving throughput — D4 is optional/L3.

## Orchestration (sub-agents / workflows)

- **D0** = one recon **workflow**: parallel Explore/reader agents, one per
  reference file group — (a) `language.py`, (b) `diffusion_gemma.py`+`config.py`,
  (c) `generate/diffusion.py`, (d) `processing`+tokenizer+chat_template, (e)
  `loader`/`generate`/`lora`/`convert`. Each returns a structured spec; a
  synthesis agent merges into the "Reference dossier" section here; a
  weight-audit agent diffs module names vs the real `*.safetensors` index.
- **D1** = pipeline per component (vision → decoder-layer → MoE →
  self-conditioning → full-forward), each stage verify-gated against a Python
  golden dump before the next builds on it.
- **D2/D3** = mostly serial (single engine), with an adversarial parity-verify
  agent per sampler.

---

## Reference dossier (D0)

This dossier consolidates six independent reverse-engineering passes over OptiQ's vendored DiffusionGemma (`optiq.vlm._mlxvlm.models.diffusion_gemma.*`, `optiq.vlm.diffusion_gemma.*`). It is the porting contract for the mlx-bun TypeScript/MLX implementation. Class/function/tensor names and constants are quoted as found; items the reports flagged as unverified are called out in §9.

### 1. Weight schema & quant map

**Checkpoint analyzed:** `DiffusionGemma-26B-A4B-it OptiQ-4bit`, ~14 GB safetensors (mixed 4/8-bit; BF16 full-precision ≈ 26–28 GB). OptiQ affine quant, `group_size=64` throughout. Sharded `model*.safetensors`, loaded lexicographically via `mx.load()` and kept lazy until eval.

**Top-level config (`TextConfig` / `ModelConfig`):**

| Param | Value |
|---|---|
| `model_type` (text / top) | `diffusion_gemma_text` / `diffusion_gemma` |
| `vocab_size` | 262144 |
| `hidden_size` | 2816 |
| `intermediate_size` (dense MLP) | 2112 |
| `moe_intermediate_size` (expert) | 704 |
| `num_hidden_layers` | 30 |
| `num_attention_heads` | 16 |
| `num_key_value_heads` | 8 (sliding) |
| `num_global_key_value_heads` | 2 (full_attention) |
| `head_dim` | 256 (sliding) |
| `global_head_dim` | 512 (full_attention) |
| `hidden_activation` | `gelu_pytorch_tanh` |
| `rms_norm_eps` | 1e-6 |
| `max_position_embeddings` | 262144 |
| `sliding_window` | 1024 |
| `final_logit_softcapping` | 30.0 |
| `num_experts` | 128 |
| `top_k_experts` | 8 |
| `attention_bias` | False |
| `tie_word_embeddings` | True |
| `use_bidirectional_attention` | `"vision"` |
| `pad/eos/bos_token_id` | 0 / 1 / 2 |
| `canvas_length` (ModelConfig) | 256 |
| `boi_token_id` / `eoi_token_id` / `image_token_id` | 255999 / 258882 / 258880 |
| `eos_token_id` (ModelConfig, list) | `[1, 106]` |

**Unique tensor templates (22) and per-tensor quant:**

Decoder embeddings:
- `model.decoder.embed_tokens.weight` — (262144, 2816), **4-bit**. Tied LM head (no `lm_head.weight`; logits via `embed_tokens.as_linear()`).

Per decoder layer `model.decoder.layers.N` (N=0..29):
- `self_attn.q_proj` / `k_proj` / `o_proj` — **8-bit** (all 30 layers).
- `self_attn.v_proj` — **8-bit**, present in **25 of 30** layers (absent in full_attention layers 5,11,17,23,29 — those reuse k as v).
- `self_attn.q_norm.weight` / `k_norm.weight` — unquantized RMSNorm; `v_norm` — unquantized RMSNormNoScale.
- `input_layernorm`, `post_attention_layernorm`, `pre_feedforward_layernorm`, `post_feedforward_layernorm`, `post_feedforward_layernorm_1`, `pre_feedforward_layernorm_2`, `post_feedforward_layernorm_2` — all unquantized RMSNorm (7 norms/layer).
- `mlp.gate_proj` / `up_proj` / `down_proj` — **8-bit**.
- `router.proj` — **8-bit** (Linear hidden→128, bias=False); `router.scale` (2816,), `router.per_expert_scale` (128,) — unquantized, init `mx.ones`.
- `experts.gate_up_proj.weight` — (128, 1408, 2816) **4-bit** SwitchLinear; `experts.down_proj.weight` — (128, 2816, 704) **4-bit** SwitchLinear.
- `layer_scalar` — (1,) unquantized, init `mx.ones`.

Self-conditioning (`model.decoder.self_conditioning`):
- `pre_norm` (RMSNorm) unquantized; `post_norm` (RMSNormNoScale) unquantized; `gate_proj` / `up_proj` / `down_proj` — **4-bit** (shapes mirror dense MLP: gate/up = (2112,2816), down = (2816,2112)).

Final: `model.decoder.norm.weight` — unquantized RMSNorm.

Encoder layer scalars: `model.encoder.language_model.layers.N.layer_scalar` — (1,) unquantized. (All other encoder *text* weights are skipped at load — the encoder text path reuses decoder weights via weakref.)

Vision tower (SigLIP-style, 27 layers, hidden 1152, patch 16, 16 heads), all 4-bit projections, unquantized norms:
- `model.encoder.vision_tower.patch_embedder.input_proj` — 4-bit.
- `model.encoder.embed_vision.embedding_projection` — 4-bit.
- `model.encoder.vision_tower.encoder.layers.N.self_attn.{q,k,v,o}_proj.linear` — 4-bit (all 27).
- `model.encoder.vision_tower.encoder.layers.N.mlp.{gate,up}_proj.linear` — 4-bit; vision norms unquantized.

**Quant predicate** (`LanguageModel.quant_predicate`, applied when no explicit per-module override in `config["quantization"]`):
```python
def predicate(path, m):
    if not hasattr(m, "to_quantized"): return False
    if "router" in path or path.endswith(("mlp.gate_proj","mlp.up_proj","mlp.down_proj")):
        return {"group_size": 64, "bits": 8}
    return True   # default → 4-bit, group_size 64
```
Loader-level `class_predicate` additionally returns False unless `f"{path}.scales" in weights` and `weight.size % 64 == 0`, and honors explicit `config["quantization"][path]` overrides first. Net effect: attention q/k/v/o + dense MLP + router = 8-bit; embeddings, experts, self-conditioning, vision = 4-bit.

**`sanitize()` remapping:** skip `*rotary_emb*` and `lm_head.weight` (RoPE computed at runtime, head tied); skip `model.encoder.language_model.*` except `*.layer_scalar`; keep vision keys only if vision tower present; rename `*.experts.down_proj` → `*.experts.down_proj.weight` and `*.experts.gate_up_proj` → `*.experts.gate_up_proj.weight`.

**Confirmed absences:** no depthwise/Canon conv tensors anywhere (pure transformer); no separate `lm_head`; no router bias.

### 2. Decoder architecture (layer-by-layer)

**`DecoderModel`:** `embed_tokens` (Embedding 262144→2816), `embed_scale = hidden_size**0.5` (≈53.07), 30× `DecoderLayer`, final `norm` (RMSNorm), `self_conditioning`.

**`layer_types` pattern:** `[sliding_attention ×5, full_attention] ×5`, last layer forced full. Full-attention layers at indices **5, 11, 17, 23, 29**.

**RoPE per layer type** (`initialize_rope`, `traditional=False`):
- sliding_attention: `rope_theta = 10000.0`, default.
- full_attention: `rope_theta = 1000000.0`, proportional scaling, `partial_rotary_factor = 0.25` (only 25% of `head_dim` rotated).

**`Attention.__call__(x, mask, cache, *, decoder=False, offset=None)`** (`scale = 1.0`, **no attention softcap**):
- `head_dim` = 512 if full_attention else 256; `n_kv_heads` = 2 if full else 8.
- q = `q_norm(q_proj(x))` reshaped (B,L,n_heads,head_dim) → transpose → `rope(offset)`.
- k = `k_norm(k_proj(x))` reshaped (B,L,n_kv_heads,head_dim) → transpose → `rope(offset)`.
- v: sliding → `v_norm(v_proj(x))`; full → `v_norm(keys)` (v_proj is None, reuses k). **QK/V norm is post-projection, pre-RoPE.**
- **decoder=True (canvas pass):** fetch `(encoder_keys, encoder_values)` from cache state; for sliding layers, if `offset >= encoder_len` and `encoder_len > window` (`window = sliding_window-1 = 1023`), slice encoder K/V to last 1023 and trim mask to `[..., -(window+L):]`; concat `[encoder_k, k]`, `[encoder_v, v]` on axis 2; `attn_cache=None` (no cache update on canvas pass).
- **decoder=False (encoder/prefill):** `cache.update_and_fetch(k,v)`; `attn_cache=cache`.
- `scaled_dot_product_attention(q,k,v,cache=attn_cache,scale=1.0,mask=mask)` → reshape → `o_proj`.

**`DecoderLayer.__call__(x, mask, cache, *, decoder, offset, layer_scalar=None)`** — attention branch + **parallel dense-MLP + MoE** feedforward:
```
# attention
residual = x
h = input_layernorm(x); h = self_attn(h, mask, cache, decoder=decoder, offset=offset)
h = post_attention_layernorm(h); h = residual + h
# parallel FFN
residual = h
h1 = post_feedforward_layernorm_1(mlp(pre_feedforward_layernorm(h)))     # dense
flat = residual.reshape(-1, hidden); idx, w = router(flat)
h2 = experts(pre_feedforward_layernorm_2(flat), idx, w).reshape(residual.shape)
h2 = post_feedforward_layernorm_2(h2)
h = post_feedforward_layernorm(h1 + h2); h = residual + h
return h * (layer_scalar if layer_scalar is not None else self.layer_scalar)
```

**`MLP`:** `down_proj(geglu(gate_proj(x), up_proj(x)))`, where `geglu(gate,x) = gelu_approx(gate) * x` (`@mx.compile(shapeless=True)`).

**`Router`:** `x = rms_norm(x, None, eps); x = x * scale * hidden_size**-0.5; scores = proj(x)`; top-8 via `argpartition(scores, kth=-8)[...,-8:]`; `weights = softmax(take_along_axis(scores, idx), precise=True) * per_expert_scale[idx]`. Normalization is **pre**-projection.

**`Experts`:** `gate_up_proj` / `down_proj` are `SwitchLinear` (weight (num_experts, out, in); `gather_mm(x, W.T, rhs_indices=idx, sorted_indices)`). `x = expand_dims(x,(-2,-3))`; if `idx.size>=64` → `_gather_sort` (group tokens by expert) then `_scatter_unsort`; gate_up split at 704; `y = down_proj(geglu(gate,up))`; final `(y * w[...,None]).sum(axis=-2)`.

**`_make_decoder_masks(h, caches, decoder_attention_mask)`** — returns `{layer_type → mask}`, broadcast shape `(B, 1, canvas_length, key_len)`, `key_len = encoder_len + canvas_length`. `valid_encoder_len = min(_cache_offset(cache), encoder_len)`.
- **full_attention:** canvas attends bidirectionally to all valid encoder positions + itself. If `encoder_len == valid_encoder_len` and no external mask → mask is `None` (all valid). Otherwise build a key-row: `concat([arange(encoder_len) < valid_encoder_len, ones(canvas_length, bool)])`, broadcast to `(B,1,canvas_length,key_len)`. External masks are sliced to `[..., -key_len:]` then broadcast.
- **sliding_attention:** `window_prefix = max(sliding_window-1, 0) = 1023`. If `encoder_len == valid_encoder_len and encoder_len <= window_prefix` → `None`. Else keep encoder positions in `[max(0, valid_encoder_len - 1023), valid_encoder_len)`: `encoder_mask = (arange(encoder_len) >= start) & (arange < valid_encoder_len)`; `row = concat([encoder_mask, ones(canvas_length, bool)])`. With external mask, AND it elementwise with `keep` before broadcasting.

Key invariant: **canvas tokens always see all kept encoder positions and are bidirectional among themselves (no causal mask on the canvas)** — diffusion decoding, not autoregressive. (Encoder pass `_make_encoder_masks` is the causal/sliding + vision-overlay one; see §4.)

`DecoderModel.__call__(canvas_ids, cache, self_conditioning_logits, self_conditioning_embeddings, decoder_attention_mask)`: embed canvas (§3) → `masks = _make_decoder_masks(...)` → `offset = _cache_offset(cache[0])` → loop layers with `decoder=True, offset=offset` → `norm(h)`.

### 3. Self-conditioning

`SelfConditioning` module: `pre_norm` (RMSNorm), `gate_proj`/`up_proj`/`down_proj` (dense-MLP shapes), `post_norm` (RMSNormNoScale).
```python
def __call__(inputs_embeds, signal):
    normed = pre_norm(signal)
    s = down_proj(geglu(gate_proj(normed), up_proj(normed)))
    return post_norm(inputs_embeds + s)
```

`DecoderModel._embed_canvas(canvas_ids, sc_logits=None, sc_embeddings=None)`:
- Hard: `inputs_embeds = embed_tokens(canvas_ids) * embed_scale`.
- Soft signal: if `sc_embeddings` given → cast to dtype; elif `sc_logits is None` → `zeros_like`; else `probs = softmax(sc_logits, precise=True)`, then `soft = probs @ embed_tokens.weight` (or `mx.quantized_matmul(probs, weight, scales, biases, transpose=False, group_size, bits)` if `QuantizedEmbedding`), `* embed_scale`.
- Return `self_conditioning(inputs_embeds, soft)`.

In the engine, after each denoising step except the last, soft embeddings are computed from the current logits (`_diffusion_entropy_and_soft_embeddings`) and fed as `self_conditioning_embeddings` to the next step.

### 4. Vision tower & merge

**`EncoderModel`** (holds `weakref` to decoder): `language_model` (`EncoderLanguageModel` — weakref + 30 `EncoderLayerScalar`, each `layer_scalar = mx.ones((1,))`), `vision_tower` (`VisionModel`, optional), `embed_vision` (`MultimodalEmbedder`, vision_hidden→text_hidden, eps=vision rms_norm_eps).

**`make_cache(max_size=None)`** (30 entries by `layer_types`): `StaticPrefixKVCache(max_size)` if max_size given; else `KVCache()` (unbounded) for full_attention; else `RotatingKVCache(max_size=sliding_window=1024)` for sliding.

**Patch embed** (`VisionPatchEmbedder`): reshape pixels to (B,C,pH,p,pW,p) → transpose (B,pH,pW,p,p,C) → reshape (B, pH·pW, C·p·p) → `2*(patches-0.5)` (normalize to [-1,1]) → `input_proj`. `get_image_features = embed_vision(vision_tower(pixel_values))`.

**`_embed_inputs(input_ids, pixel_values)`:** `vision_mask = (ids==image_token_id) | (ids==video_token_id?)`; `llm_input_ids = where(vision_mask, pad_token_id, input_ids)`; `inputs_embeds = embed_tokens(llm_input_ids) * embed_scale`; if pixel_values: `masked_scatter(inputs_embeds, vision_mask_expanded, get_image_features(...))`.

**`_vision_block_overlay(mm_token_type_ids, seq_len)`:** only when `use_bidirectional_attention == "vision"`. `is_vision = (mmtt==1)|(mmtt==2)`; contiguous-block IDs via `cumsum(starts)`; returns `(q_blocks != -1) & (q_blocks == k_blocks)` — tokens in the same image block attend bidirectionally.

**`_make_encoder_masks(h, cache, attention_mask, mm_token_type_ids)`:** fast path uses `create_attention_mask(window_size=sliding_window if sliding else None)`. Slow path: base causal `q_pos >= k_pos`; AND sliding window `q_pos < k_pos + sliding_window` for sliding layers; OR vision overlay; AND key/padding mask. Overlay applied only in prompt (`key_len == N`), not continuation.

**`EncoderModel.__call__`:** embed → masks → 30 layers with `decoder=False` and external `layer_scalar = language_model.layers[i].layer_scalar` → `decoder.norm(h), cache`.

**Image preprocessing (`Gemma4ImageProcessor`):** `patch_size=16`, `max_soft_tokens=280` (allowed 70/140/280/560/1120), `pooling_kernel_size=3`, resize divisor `48 = pooling·patch`, aspect-preserving bicubic resize to multiples of 48 within `max_patches = max_soft_tokens·9` budget; rescale `1/255`; `do_normalize=False` by default (mean/std 0.5 if enabled); channel-first (C,H,W). `num_soft_tokens = (H//16)·(W//16) // 9`.

### 5. Tokenizer / chat template / canvas

**Special tokens** (Gemma4 tokenizer): `bos=2 <bos>`, `eos=[1,106]` (`<eos>`, `<turn|>`), `pad=0 <pad>`, `mask=4 <mask>`, `image_token=258880 <|image|>`, `boi=255999 <|image>`, `eoi=258882 <image|>`, `video=258884 <|video|>`, `audio=258881 <|audio|>`. (Token IDs 258880/255999/258882 confirmed against `ModelConfig`; mask=4 and video=258884 flagged in §9.)

**Image splicing** (`Gemma4Processor`, `image_seq_length=280`): build `full_image_sequence = boi + image_token*280 + eoi`; per-image, replace each `<|image|>` placeholder with `boi + image_token*N + eoi` where N = that image's actual soft-token count (fallback to fixed 280). Then tokenize.

**`mm_token_type_ids`** marks tokens: `0`=text/pad, `1`=image (258880), `2`=video (258884), `3`=audio (258881).

**Chat template** (`chat_template.jinja`, Gemma4): turn markers `<|turn>user\n`, `<|turn>model\n`, `<turn|>\n`, optional `<|turn>system\n…<turn|>\n`; generation prompt continues from `<|turn>model\n`, optionally injecting `<|channel>thought\n<channel|>` when thinking enabled.

**Canvas:** a fixed 256-token (`canvas_length`) block that the decoder denoises. Initialized to uniform-random token IDs per block (`mx.random.randint(0, vocab_size, (B, canvas_length))`), **not** the mask token. Block diffusion: multiple canvas blocks generated sequentially until `max_tokens` / EOS.

### 6. Denoising engine pseudocode

`stream_diffusion_generate(model, processor, tokenizer, input_ids, pixel_values=None, attention_mask=None, *, max_tokens, skip_special_token_ids, temperature=0.0, max_denoising_steps=48, diffusion_full_canvas=False, diffusion_min_canvas_length=64, diffusion_max_canvas_length=256, diffusion_static_cache=False, diffusion_sampler="entropy-bound", diffusion_threshold=0.9, diffusion_compile=False, diffusion_show_unmasking=False, diffusion_unmasking_interval=1, mm_token_type_ids=None, prefill_step_size=None)`:

```
# 1. PREFILL — encoder builds KV cache (optionally chunked by prefill_step_size)
encoder(input_ids, attention_mask, cache, pixel_values, mm_token_type_ids)

# 2. CANVAS LOOP — block diffusion
while generated_tokens < max_new_tokens:
  canvas_length = min(diffusion_max_canvas_length, remaining, model.config.canvas_length)
  current_canvas = randint(0, vocab_size, (B, canvas_length)).astype(input_ids.dtype)
  sc_embeddings = None
  diffusion_history = []           # ring buffer for stability check
  draft_reveal_mask = zeros(bool)  # confidence sampler
  draft_canvas = current_canvas

  # 3. DENOISING LOOP — high t-step → 1
  for cur_step in reversed(range(1, max_denoising_steps + 1)):
    logits = decoder_logits_without_sc(current_canvas) if sc_embeddings is None \
             else decoder_logits_with_sc(current_canvas, sc_embeddings)
    # logits already softcapped: tanh(x_fp32 / 30.0) * 30.0

    sched_t = _diffusion_linear_temperature(cur_step, max_denoising_steps, schedule_cfg)
    processed = logits / sched_t if sched_t is not None else logits   # t_min .4 → t_max .8

    argmax_canvas = argmax(processed, -1)
    if cur_step == 1 and not diffusion_show_unmasking: break          # skip final re-noise
    denoiser_canvas = argmax_canvas if temperature <= 0 \
                      else categorical(processed / temperature)

    # 4. SAMPLER → acceptance_mask + next sc_embeddings   (see §7)
    ... acceptance_mask, sc_embeddings(next) ...

    # 5. FREEZE accepted, RE-NOISE the rest
    #   entropy:    current_canvas = where(acceptance_mask, accepted, randint(...))
    #   confidence: current_canvas = where(draft_reveal_mask | acceptance_mask, accepted, randint(...))

    # 6. EARLY STOPS
    if confidence sampler and cur_step>1 and all(draft_reveal_mask):
        accepted_canvas = draft_canvas; break
    if _diffusion_stable_and_confident(argmax_canvas, processed, history, stopping_cfg): break

  # 7. EMIT tokens from final argmax_canvas; check tokenizer.stopping_criteria(token) for EOS
```

`_diffusion_stable_and_confident`: stable if last `stability_threshold` (default 1) canvases are identical; confident if `mean(token_entropy) < confidence_threshold` (default 0.005); returns `stable and confident`. (Distinct from the sampler's `entropy_bound=0.1`.)

`_diffusion_linear_temperature`: `t_min + (t_max - t_min)*(cur_step/max_steps)`, defaults `t_min=0.4, t_max=0.8`; **divides** logits.

### 7. The two samplers

**Entropy-bound (default in engine):** `entropy_bound = 0.1`. Per step:
- `cur_step>1`: `token_entropy, next_sc_embeddings = _diffusion_entropy_and_soft_embeddings(processed, soft_embedding_weight, embed_scale)`; else `token_entropy = _diffusion_token_entropy(processed)`, `next_sc=None`.
- `_diffusion_entropy_transfer_mask(entropy, entropy_bound)`: sort positions by ascending entropy; `cum = cumsum(sorted_entropy)`, `cmax = cummax(sorted_entropy)`; `sorted_sel = (cum - cmax) <= entropy_bound`; unsort via `put_along_axis`. Accepts the lowest-entropy positions until cumulative-minus-running-max exceeds the bound.
- `accepted = where(mask, denoiser_canvas, current_canvas)`; non-accepted re-noised next step; `draft_reveal_mask = mask`, `draft_canvas = argmax_canvas`.

**Confidence-threshold:** `diffusion_threshold = 0.9` (CLI `args.threshold`, else 0.9). Per step:
- `confidence = _diffusion_token_probability(processed, denoiser_canvas)` = `exp(token_logits - logsumexp(logits))` in fp32.
- `_diffusion_confidence_transfer_mask(confidence, unrevealed_mask, threshold, force_all=(cur_step==1))`: if `force_all` → return `unrevealed_mask` (accept all on final step); else `transfer = unrevealed & (confidence >= threshold)`; for sequences with no qualifier, force the single highest-confidence unrevealed position (`argmax(where(unrevealed, confidence, -inf))`); return `transfer | forced`.
- `accepted = where(mask, denoiser_canvas, draft_canvas)`; `current_canvas = where(draft_reveal_mask | mask, accepted, randint(...))`; `draft_reveal_mask |= mask`; `draft_canvas = where(mask, accepted, draft_canvas)`.

Defaults discrepancy across reports: the engine signature default is `diffusion_sampler="entropy-bound"`, while the public `generate()` (`generate.py`) default is `DEFAULT_SAMPLER="confidence-threshold"`. The port should treat the public-API default as confidence-threshold and the engine internal default as entropy-bound.

`_diffusion_sample_canvas(processed, dtype, temperature)`: fp32; `temperature<=0` → argmax; else `categorical(logits / temperature)`.

### 8. OptiQ load / generate / lora API

**`load_diffusion_gemma(...) → (model, config_dict)`** (`loader.py:55–96`): `load_config()` → `Model(ModelConfig.from_dict(config))` → `_gather_weights()` (lazy mmap) → `model.sanitize(weights)` → quantize via `nn.quantize(group_size, bits, mode, class_predicate)` (predicate honors explicit `config["quantization"][path]`, then `to_quantized` support, `weight.size % 64 == 0`, and `f"{path}.scales" in weights`) → `model.load_weights(...)` → `mx.eval` → `model.eval()`.

**`generate(model, tokenizer, prompt, *, images=None, max_tokens=512, temperature=0.0, sampler="confidence-threshold", verbose=False) → str`** (`generate.py:169`): wraps `stream_generate()`, concatenates non-draft segments (`is_draft=False`), retries ≤3× if output collapses to empty.

**`stream_generate()` → Generator[`GenerationResult`]** fields: `text`, `is_draft`, `draft_text`, `diffusion_step`, `diffusion_total_steps`, `diffusion_canvas_index`, plus metrics `prompt_tokens/generation_tokens/total_tokens`, `prompt_tps/generation_tps`, `diffusion_canvas_tokens`, `diffusion_denoising_steps`, `diffusion_work_tokens` (= canvas_tokens·steps), `finish_reason` ∈ {`stop`,`length`,`stable`}.

**`_build_image_inputs(model, tokenizer, prompt, images)`** → `(input_ids, pixel_values, mm_token_type_ids)`: SigLIP preprocess + per-image `<|image|>` → `boi + image_token*N + eoi` expansion; `mm_token_type_ids = 1` where `t==image_token_id`.

**LoRA** (`lora.py`):
- `DEFAULT_LORA_KEYS = ["self_attn.q_proj","self_attn.k_proj","self_attn.v_proj","self_attn.o_proj","mlp.gate_proj","mlp.up_proj","mlp.down_proj"]` — applied to all decoder layers via `linear_to_lora_layers(model, len(model.layers), cfg)`. MoE experts and router stay frozen; encoder reuses decoder weights.
- `diffusion_loss(model, prompt_ids, target_ids, *, t_min, t_max, vocab_size)`: sample `t = uniform(t_min, t_max)`; `corrupt = uniform((B,L)) < t`; `noise = randint(0, vocab_size, (B,L))`; `canvas = where(corrupt, noise, target_ids)`; `logits = model(input_ids=prompt_ids, canvas_ids=canvas).logits`; `ce = cross_entropy(logits, target_ids, reduction="none")`; return `(ce * corrupt).sum() / max(corrupt.sum(), 1)` — **CE on corrupted positions only**.
- `train_diffusion_lora(model_path, data_dir, adapter_path, *, rank=8, scale=8.0, dropout=0.0, num_layers=-1, iters=200, learning_rate=1e-4, max_canvas=256, report_every=10, seed=0)`. Data: `{data_dir}/train.jsonl` with `{prompt,completion}` | `{messages:[...]}` | `{text}`. Scale 8.0 (vs AR default 20 which collapses).
- Adapter out: `adapter_config.json` (`base_model`, `fine_tune_type="lora"`, `model_type="diffusion_gemma"`, `lora_parameters`{rank,scale,dropout,keys}) + `adapters.safetensors`.

**Defaults table:**

| Param | Default | Source |
|---|---|---|
| `DEFAULT_SAMPLER` | `confidence-threshold` | generate.py:26 |
| `DEFAULT_MAX_TOKENS` | 512 | generate.py:27 |
| `DEFAULT_DIFFUSION_MAX_DENOISING_STEPS` | 48 | diffusion.py:21 |
| `DEFAULT_DIFFUSION_MIN_CANVAS_LENGTH` | 64 | diffusion.py:20 |
| canvas_length | 256 | ModelConfig |
| temperature schedule t_min / t_max | 0.4 / 0.8 | diffusion.py / generation_config.json |
| entropy_bound (sampler) | 0.1 | diffusion.py:662 |
| confidence threshold (sampler) | 0.9 | diffusion.py:597 |
| stability_threshold / confidence_threshold (stop) | 1 / 0.005 | generation_config.json |
| LoRA rank / scale | 8 / 8.0 | lora.py:99–100 |

If `sampler_config._cls_name != "EntropyBoundSamplerConfig"`, the engine raises `NotImplementedError`.

### 9. Open questions / risks for the TS port

**Confirmed (low risk), called out because the brief asked:**
- **Canon / depthwise conv: ABSENT.** No Conv tensors in the checkpoint; pure transformer (vision tower is attention-based SigLIP). Port needs no conv path.
- **Tied head: YES.** No `lm_head.weight`; logits via `embed_tokens.as_linear()` (a `QuantizedEmbedding`). The port must implement quantized `as_linear` (transpose-matmul against the 4-bit embedding table) and the matching `quantized_matmul(probs, weight, scales, biases, transpose=False, group_size, bits)` path used for soft embeddings in `_embed_canvas`.

**Unclear / verify before/while porting:**
1. **`mask_token_id` value — UNCERTAIN.** `<mask>`=4 in `tokenizer_config.json`, but no engine path uses a mask token: the canvas is initialized to **uniform-random token IDs** (`randint(0, vocab_size, …)`), and re-noising also uses random IDs. Treat canvas init/re-noise as uniform-random; don't assume a discrete mask token unless a code path consuming id 4 is found.
2. **`video_token_id`.** `ModelConfig.video_token_id = None` in the checkpoint, but tokenizer lists 258884 and `mm_token_type_ids` uses `==2` for video. Gate the video branch on a non-None config value; confirm whether this checkpoint supports video.
3. **Default sampler conflict.** `generate.py` default = `confidence-threshold`; engine default = `entropy-bound`; `generation_config.json` ships `EntropyBoundSamplerConfig`. Public `generate()` → confidence-threshold; low-level engine → entropy-bound.
4. **`eos_token_id` is a list `[1, 106]`** at ModelConfig level (106 = `<turn|>`) but `1` at TextConfig level. Stopping criteria must accept the full set.
5. **Mask broadcasting precision in `_make_decoder_masks`.** Highest bug-risk area. The interaction between in-attention encoder K/V slicing (last 1023) and the precomputed mask trim (`[..., -(window+L):]`) must be replicated exactly. Build a per-op parity harness (copy-verbatim methodology) before optimizing.
6. **`RotatingKVCache` (ring, max_size=1024) vs `KVCache` (unbounded) vs `StaticPrefixKVCache`.** `_cache_offset` / `_cache_state` helpers must be ported faithfully; the decoder reads encoder K/V out of cache state — offset/order bugs corrupt cross-attention silently.
7. **`SwitchLinear` + `_gather_sort`/`_scatter_unsort`** with the `idx.size >= 64` sort threshold and `sorted_indices` flag. Match `mlx_lm.models.switch_layers` exactly; 4-bit quant amplifies tiny mismatches.
8. **Quant predicate ordering.** Loader honors explicit `config["quantization"][path]` overrides before the predicate's blanket "8-bit attention." Read the real per-tensor map, not just the predicate.
9. **`use_clipped_linears` / calibration-scalar gating** in `sanitize()` for vision/embed_vision keys — confirm the exact keep/drop condition against source.
10. **`partial_rotary_factor=0.25` on full-attention RoPE** (only 25% of the 512-dim head rotated) + `traditional=False` + proportional scaling at theta 1e6 — verify rotary-dim split/interleaving against `initialize_rope` output.
11. **Image processor budget math** (`max_patches = max_soft_tokens·9`, divisor 48, bicubic, `do_normalize=False`, patch pre-scale `2*(x-0.5)`) and per-image variable soft-token count feeding `<|image|>` expansion — replicate exactly so encoder seq lengths line up with `mm_token_type_ids`.
12. **`final_logit_softcapping` is fp32**: `tanh(x.astype(float32)/30.0)*30.0` (`@mx.compile(shapeless=True)`); the upcast matters for parity.

Source-line references are approximate locators from the six passes, not verified citations.
