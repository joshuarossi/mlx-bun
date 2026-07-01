# STATUS — live handoff

The single "what's the state, what's next" doc. Durable phase history,
exit criteria, and findings live in [PLAN.md](PLAN.md); this file is the
transient front door that stays current. Product/UX north star:
[docs/planning/PRODUCT_ROADMAP.md](docs/planning/PRODUCT_ROADMAP.md).

## THE DREAMING (local personal-wiki memory) — ACTIVE 2026-06-28. Full handoff: [docs/design/the-dreaming-handoff.md](docs/design/the-dreaming-handoff.md)

Conversations → chunks → entities → **subject articles** → cross-linked, self-healing
wiki, all local (`src/memory/`). **Works end-to-end on real data.** Staged, chronological,
resumable pipeline (`stages.ts`): segment(our e4b-chunk-300 chunker) → extract → route
(surface-EVERYTHING, no notability/ownership gate) → create/patch(self-healing, date-aware,
`## History` for position-evolution) → reconcile → **link**(cross-link: mention + co-occurrence
→ See-also + `[[wikilinks]]`, 18%→96% See-also, 22.7× edges) → wikify.

- **Full-corpus import STOPPED at cursor 720/2096** (677 articles in `~/.mlx-bun/wiki-full`),
  **resumable**: `bun scripts/experiments/dreaming-full-run.ts`. Real vault `~/.mlx-bun/wiki` untouched.
- **In progress:** inference-path rework (`docs/design/memory-inference-path.md`). Template fix
  done (chunk adapter trained with a **system role**; inference dropped it → now passes {system,user}).
  **Batching = dead end** (~1.7× SLOWER — scheduler pads heterogeneous prefills). **Load-once via the
  persistent server** is the real efficiency win for daily use — wire memory generation through it next.
- **Key corrections this session:** notability = "recurs in your thinking" (surface everything; the
  ownership gate was fabricated, ripped out); subject-based articles (the one improvement over Lucien);
  chronological ordering; cross-linking is WIKIFY's job not synthesis; ALL prompts/Meta must be SCHEMATIC
  (parroting bit 5×). Lucien = read-only oracle. Quality judged by CLOUD JUDGE, never bucket-F1.
- **Next:** finish inference-path (server load-once) → resume import (~50h serial) → reindex + `memory link`
  → judge a broad sample → promote to the real vault + nightly daily fold-in. See HANDOFF.md for full detail.

## DSpark speculative drafter — FAITHFUL BUILD DONE, architecture proven correct 2026-06-30. Handoff: [docs/investigations/dspark-handoff.md](docs/investigations/dspark-handoff.md) · Design: [docs/design/dspark-speculative-decoding.md](docs/design/dspark-speculative-decoding.md)

Faithful DSpark = DFlash multi-layer KV injection (Eq 2–3) + Markov head +
confidence head, in `src/spec/dspark/*-dflash.ts` (v1 single-vector `*.ts` kept
as superseded baseline; both flag-selected). **Architecture proven correct** via
overfit (3 articles, eval-on-same): per-pos **~0.75**, τ **3.24** = paper-range.
- **Status:** repo typechecks 0; CPU smoke 16/16 (dflash) + 33/33 (v1). Fixed a
  real **off-by-one in the p^t/TV target** (was in v1 too → all pre-fix τ bogus).
  Confirmed: width isn't the ceiling (1024≈2560); parity-safe `hiddenTap`;
  `trim(n,bypass)` lossless rollback past the sliding window.
- **Two gaps to a real speedup (not architecture):** (1) DATA — 160 articles →
  generalizes only to per-pos ~0.17 (overfit proves capacity; paper uses 1.3M×10).
  (2) TARGET SPEED — decode e4b 45.9 / 12b 27.5 / 27B ~15 tok/s; the fixed draft
  overhead only amortizes on a SLOW target, so **e4b is ~worst-case; the 27B
  agentic workload is the real target** (τ≈3 there could net ~2–3× → 15→~35–45).
- **Next:** retarget to 27B/12b (drafter ports; regen+train there; 27B/32GB is
  memory-tight), scale data, tighten the draft loop, then RNN head + STS + Alg-1
  scheduler, then rename dflash→dspark. See handoff.

## DiffusionGemma port — D1–D3 + D5 DONE 2026-06-24. COMPLETE (D4 perf = Josh-gated bench).

**THE WHOLE PORT IS DONE.** DiffusionGemma-26B-A4B-it (first non-autoregressive model) runs in
mlx-bun: bit-exact forward, token-for-token denoising (both samplers), text + image serving
(parity-exact, live), and LoRA fine-tuning. Plan + dossier: docs/design/diffusion-gemma-port.md.
- **D1** static forward: BIT-EXACT vs optiq (`tests/diffusion-parity.test.ts`). [[diffusion-gemma-router-norm-no-fold]]
- **D2** denoising engine, BOTH samplers: TOKEN-FOR-TOKEN (`tests/diffusion-gen-parity.test.ts`). [[diffusion-gemma-d2-oracle-rng-parity]]
- **D3** serving: CLI + OpenAI/Anthropic + streaming (text) AND image-text-to-text via a DEDICATED
  vision tower (`src/vision/diffusion-vision.ts`) — token-for-token + served live
  (`tests/diffusion-{serving,vision}.test.ts`). [[diffusion-gemma-vision-dedicated-tower]]
- **D5** diffusion-LoRA: `src/train/diffusion-lora.ts` — the denoising-objective trains end-to-end
  (loss 3.9→1.2), MoE backward via stop_gradient'd routing indices, adapter changes output
  (`tests/diffusion-lora.test.ts`). [[diffusion-gemma-lora-denoising]]
- **D4 (perf)** is the only open item — optional/measured; quotable tok/s needs a clean-machine
  `benchmark.sh` (Josh-gated, preflight). The confidence-threshold path is already the fast one.
- Typecheck baseline held at 117 throughout (zero new errors); AR models unregressed
  (instanceof-guarded branches). Goldens regen: `scripts/gen-diffusion-{golden,gen-golden,vision-golden}.py`.

### (historical) DiffusionGemma port — D1 + D2 + D3 DONE; D4/D5 next

**D3 IMAGE-TEXT-TO-TEXT COMPLETE — token-for-token parity, served live.** A DEDICATED vision
tower (`src/vision/diffusion-vision.ts`, `DiffusionVisionTower`) — its OWN module (the user was
right: e4b and the 26B-diffusion are SEPARATE models with SEPARATE towers; e4b uses a bf16
sidecar, diffusion's vision is inline-quantized). Parity-exact op-for-op port of optiq's gemma4
`VisionModel` at the diffusion geometry (hidden 1152, head_dim 72, 27 layers, standardize). Wired
through the encoder vision merge + bidirectional overlay → denoising engine; preprocess + splice
build the prompt; server `handleChat` gets a diffusion vision lane. **Verified:**
`tests/diffusion-vision.test.ts` (spliced ids EXACT + token-for-token "This is a solid gray
square." on grad-768) AND served live via the OpenAI vision API.
- **3 vision bugs (per-stage diffing): (1)** input_proj is QUANTIZED → the reference's
  `patches.astype(weight.dtype)` is a uint32 truncation of the patches (a trained-in quirk; e4b's
  bf16 input_proj never hit it). **(2)** head_dim 72 → `ensure_fused_sdpa` pads to 80 + slices.
  **(3)** down_proj is plain bf16 (a quantized-or-plain `VisionLinear`). Residual ~2.3% feature
  relRMSE = 27-layer bf16 accumulation (e4b-class), robust → identical tokens. [[diffusion-gemma-vision-dedicated-tower]]
- **NEXT — D4 (perf, optional) + D5 (diffusion-LoRA).** D5: port optiq's denoising-objective
  `train_diffusion_lora` (the `loraTargets` map already exists on the model). D4: measure tok/s
  with benchmark.sh.

### (historical) DiffusionGemma port — D1 + D2 + D3(text) DONE 2026-06-24; image next

**D3 TEXT serving COMPLETE — verified live on a running server.** `createModel` returns
`DiffusionGemmaModel` (in the `RuntimeModel` union with AR-only methods as throwing stubs +
real `loraState`/`loraTargets`/`makeCache` — baseline held at 117 errors, zero new). `generate()`
detects it and routes to the denoising engine (`generateDiffusionInner`), same
`Generation`/`GenerateStats` contract → CLI + server stream it for free; gateway keeps it serial.
**Verified:** `mlx-bun generate diffusiongemma "…"` (coherent haiku) AND `mlx-bun serve
diffusiongemma` answering OpenAI chat (stream + non-stream), Anthropic `/v1/messages`,
`/v1/models`, single+multi-block ("…is Paris.", primary colors). Gate:
`tests/diffusion-serving.test.ts` (4/4). No AR regression (instanceof-guarded).
- Files touched: `src/model/factory.ts` (union + dispatch), `src/model/diffusion-gemma.ts`
  (AR stubs + loraTargets), `src/generate.ts` (diffusion branch + `generateDiffusionInner`),
  `src/eval/runner.ts` (bypass bit-exact fast path), `src/serve/generation-gateway.ts`
  (serial-only guard).
- **Streaming:** v1 yields tokens after the engine completes (SSE emits as deltas); true
  per-block intra-stream + temperature>0 (categorical) are follow-ups.
- **NEXT — D3 image-text-to-text** (the remaining v1-scope item): wire the 27-layer SigLIP
  tower into the diffusion encoder. Needs: `<|image|>`→`boi+image_token*N+eoi` splice +
  `mm_token_type_ids`; encoder vision merge (`_embed_inputs` masked_scatter +
  `_vision_block_overlay` bidirectional overlay in `_make_encoder_masks`); SigLIP weight-name
  adaptation (diffusion uses `.linear` suffix + `patch_embedder`); image-text-to-text golden.
  Then D4 (perf, optional) + D5 (diffusion-LoRA, the `loraTargets` map already exists).

### (historical) DiffusionGemma port — D1 + D2 DONE 2026-06-24, D3 next

**D2 (denoising engine) COMPLETE — token-for-token parity vs the optiq engine.**
`src/diffusion/diffusion-generate.ts` (`diffusionGenerate`): prefill→cache reuse, linear
temp schedule, un-mask loop, BOTH samplers (confidence-threshold = OptiQ public default;
entropy-bound = engine default), self-conditioning feedback, EOS/stop, block loop. At temp 0
on a fixed seed, both samplers match optiq exactly: confidence 17 tok/7 steps, entropy
15 tok/48 steps (`tests/diffusion-gen-parity.test.ts`; golden `scripts/gen-diffusion-gen-golden.py`).
- **RNG parity solved:** bound `mlx_random_randint`+`mlx_random_seed`+`mlx_cummax` (and
  `logicalNot`/`equal`/`all`/`anyAxis`/`lessEqual`/`itemBool`) in `src/mlx/{ffi,ops}.ts`.
  `ops.randint(key=null)` threads the GLOBAL mlx key → seed + same-order calls reproduce every
  draw bit-for-bit (verified 0/256 mismatch). The denoising loop calls randint once for init +
  once per non-final re-noise step.
- **3 bugs fixed:** (1) `processed = logits / schedT` must be a real DIVISION (not ×reciprocal)
  — 1-ULP shift flips the hard 0.9 confidence cutoff → trajectory diverges. (2) stability history
  needs an independent copy (add-zero), not a reshape/view (aliases freed buffer → false stable).
  (3) **the as-loaded oracle has `generation_config=None`** → `stable_and_confident` is a NO-OP
  (entropy runs all 48) and eos = tokenizer's `{1,106}` (NOT the 50 in generation_config.json).
  L2 = match the oracle as it RUNS → stable-stop OFF unless explicitly configured. [[diffusion-gemma-d2-oracle-rng-parity]]
- **NEXT — D3 (serving + CLI + image):** route diffusion_gemma into generate.ts/cli.ts/server.ts
  (its own non-AR lane in the gateway — currently `createModel` throws "wired in D3"); decide
  streaming semantics (per-block, not left-to-right); image input via the 27-layer SigLIP tower
  (`parseSiglipConfig`, present in checkpoint); add `DiffusionGemmaModel` to the runtime union
  (give it the gateway-facing surface so it doesn't break the 96 AR script-callers — likely a
  separate lane/interface, not the AR `forward`). Also: temperature>0 (categorical) sampling.

### (historical) DiffusionGemma port — D1 DONE 2026-06-24 (BIT-EXACT), D2 next

**D1 (single-forward parity) COMPLETE — BIT-EXACT vs mlx-optiq.** `src/model/diffusion-gemma.ts`
(`DiffusionGemmaModel`): one full forward over the real 14 GB checkpoint — encoder prefill →
bidirectional decoder canvas pass (`_make_decoder_masks`) → parallel dense-MLP + 128-expert
top-8 MoE (fused gate_up SwitchLinear) → SelfConditioning → tied 4-bit head → fp32 softcap —
matches the optiq golden **bit-for-bit**: argmax 256/256, maxDiff 0.0, relRMSE 0.0, meanKL 0.0
(`tests/diffusion-parity.test.ts`, `MLX_BUN_TEST_DIFFUSION=1`; golden via `scripts/gen-diffusion-golden.py`).
Every per-stage sub-gate (enc/dec hidden, presoftcap, per-layer, layer-0 attn/dense/MoE) is 0.0.
- **The single bug (per-model gotcha worth remembering):** the Router pre-projection norm must be
  the literal **two-step** `rms_norm(x, None, eps) * scale * hidden**-0.5`, NOT gemma4's **folded**
  `rms_norm(x, scale*hidden**-0.5)`. The fold changes bf16 intermediate rounding → routing weights
  drift ~0.01 → 1.7% MoE error → 12.7% by encoder output (argmax mostly survived, hiding it).
  Localized by copy-verbatim per-component diffing (attn/dense were already 0.0; only MoE diverged).
- **Architecture confirmed in TS:** attn scale=1.0 no-softcap, QK/V-norm pre-RoPE (v_norm no-scale,
  no RoPE on V), full layers reuse k as v + partial-rotary 0.25, plain RMSNorm (no Gemma +1), encoder
  layer_scalars separate from decoder's, all decoder masks None for short prompts (the risky
  `_make_decoder_masks` sliding-window path only fires past 1023 ctx — D2 concern).
- **Factory:** `createModel` detects diffusion_gemma and throws "wired in D3" (serving lane is D3);
  the AR `RuntimeModel` union is deliberately NOT widened (would break 96 script-callers that assume
  `.forward`/`.forwardHidden`). D1/D2 drive `DiffusionGemmaModel` directly.
- **NEXT — D2 (denoising engine):** `src/diffusion/` canvas init (uniform-random ids — needs
  `randint`, currently missing → randomUniform+cast), linear temp schedule, the un-mask loop,
  confidence-threshold (OptiQ default) + entropy-bound (model default) samplers (entropy needs
  `cummax`, missing), self-conditioning feedback (the `_embed_canvas` soft-embedding path is already
  ported + the quantized transpose=false matmul), stability/EOS. Gate: token-for-token vs optiq
  `generate()` on a fixed seed. The static-graph forward it builds on is now bit-exact.

### (historical) DiffusionGemma port — STARTED 2026-06-24 (Phase D0 done, D1 next)

Porting **DiffusionGemma-26B-A4B-it** (`diffusiongemma-26B-A4B-it-OptiQ-4bit`, ~14 GB,
`model_type diffusion_gemma`) — the first **non-autoregressive** model: fills a fixed
256-token canvas and un-masks it over ≤48 denoising steps. Goal: **L2 parity with
mlx-optiq** (stock mlx-lm/mlx-vlm CAN'T load it → **optiq IS the oracle**, no L1 ancestor).
**Plan + full D0 reference dossier: [docs/design/diffusion-gemma-port.md](docs/design/diffusion-gemma-port.md).**
- **Oracle env moved: `mlx-optiq` 0.2.1 → 0.2.7** in `/Users/joshrossi/Code/mlx-lm/.venv`
  (diffusion decoder needs ≥0.2.3). `mlx`/`mlx-lm`/`mlx-metal` UNCHANGED (0.31.2/0.31.3)
  → existing Gemma/CPM/Qwen oracles unaffected. Reference src:
  `optiq/vlm/_mlxvlm/models/diffusion_gemma/` + `optiq/vlm/_mlxvlm/generate/diffusion.py`;
  public API `optiq.vlm.diffusion_gemma.{load→(model,tokenizer), generate}`.
- **D0 recon DONE** (dossier appended to the design doc). Headlines: NO Canon/conv tensors
  (pure transformer); TIED head (`embed_tokens.as_linear()`); hidden 2816 / 30 layers /
  16 heads; **parallel dense-MLP + 128-expert MoE** per layer (7 norms + `layer_scalar`);
  attention **scale=1.0, QK/V-norm pre-RoPE, NO attn softcap** (only final logit softcap
  30.0 fp32); sliding hd256/kv8 + full(5,11,17,23,29) hd512/kv2 partial-rotary 0.25;
  canvas init = **uniform-random ids** (no mask token); bidirectional decoder masks
  (`_make_decoder_masks`) = the crux. `randint`/`cummax` look ABSENT in src/mlx/ops.ts
  (engine-level, D2 — not a D1 blocker).
- **Scope (confirmed w/ Josh):** text + image TOGETHER in v1; **D5 diffusion-LoRA IN scope**.
- **D1 (single-forward parity) IN PROGRESS** — weights-independent pieces DONE + verified:
  - **Config + detection DONE & VERIFIED on the real config.json** (no weights needed).
    `config.json` ships ONLY token ids + `canvas_length` + the quant map — all arch dims come
    from optiq `config.py` TextConfig defaults. `loadModelConfig` now backfills them for
    `diffusion_gemma` (`diffusionGemmaRawDefaults()` in `src/config.ts`, snake_case so the
    generic parser + `parseRope` pick them up; +optional `TextConfig.canvasLength`). Parsed
    output checks out: hidden 2816/30L/16H, kv 8 (sliding)/2 (full), hd 256/512, moe 704,
    128 experts top-8, sliding_window 1024, softcap 30, layer_types [slide×5,full]×5 last-full,
    rope sliding(default,1e4)/full(proportional,0.25,1e6), eos [1,106], quant map resolves
    (q_proj 8b / experts+embed 4b). `isDiffusionGemmaConfig` + supported-gates wired
    (`src/model/support.ts`).
  - **Golden harness written** (`scripts/gen-diffusion-golden.py`, compiles; verified optiq
    `load()→(model,tokenizer)` + `Model.__call__(input_ids,canvas_ids,…)` signatures). Dumps
    module-tree + full-forward logits — runs when shards land.
  - **Building-blocks API mapped** (Explore agent): every reusable piece exists — `Attention`,
    `Router`, `Experts`/`SwitchGLU`, `QuantizedSwitchLinear`, `QuantizedEmbedding.asLinear`
    (tied head), `SiglipVisionTower`; `ops.{rmsNorm,rope,sdpa,gatherQmm,quantizedMatmul,
    argpartitionAxis,takeAlongAxis,softmaxAxis,geluApprox,where,clip}`. Missing (D2 engine
    only): `randint` (use randomUniform+cast) + `cummax`. Model contract: `(weights,config)`
    ctor + `makeCache()` + `forward(tokens,cache)→logits`.
  - **NEXT (needs weights / next focused step):** write `src/model/diffusion-gemma.ts`
    (DecoderLayer = parallel dense-MLP+MoE w/ 7 norms+layer_scalar; attn scale=1.0 no-softcap,
    QK/V-norm pre-RoPE, full layers k=v + partial-rotary 0.25; SelfConditioning; bidirectional
    `_make_decoder_masks`; tied quantized head) + wire `factory.ts` → run harness for goldens →
    per-component sub-gates → full-forward gate. Weights still downloading (one shard as of
    2026-06-24).

**Current release: v0.0.6** (2026-06-23) — npm + Homebrew + GitHub release all live
(`brew upgrade joshuarossi/tap/mlx-bun` / `npm i -g mlx-bun` / `bunx mlx-bun`).
Adds `mlx-bun train` (CLI ORPO/SFT/DPO LoRA), `mlx-bun generate`, the `--l1/--l2/--l3`
parity-tier aliases, web sampling sliders, mixed-precision quantize, and the
train-watch dashboard. Notes: https://github.com/joshuarossi/mlx-bun/releases/tag/v0.0.6

## MiniCPM5 decode megakernel — SHELVED for M=1 (2026-06-24), research only

The entire CPM5 decode forward in ONE resident Metal dispatch
(`src/model/megakernel-kernel.ts`, `MegakernelRunner`), multi-threadgroup + software
grid-barrier. **DECISION (Josh): do not ship it; keep using the mlx-ops path.** It is
NOT wired into production (generate/server/cli/minicpm5 never reference it — Phase 5
never done); the live decode path is unaffected.
- **Why shelved — MEASURED, decisive (`megakernel-perf.ts` + NOBAR ablation):** vs the
  pure weight-read floor (~4.5ms), **mlx per-op = 4.62ms (~0.12ms overhead — near optimal)**;
  megakernel = 5.41ms (with barriers) and **4.95ms even with barriers no-op'd** — STILL
  slower. So it's NOT a bandwidth wall: mlx is already near the floor. The megakernel
  replaces Apple's *cheap hardware dispatch sync* with *expensive software grid-barriers
  (0.46ms) + atomic cross-threadgroup activation coherence (0.33ms)* — structurally heavier
  for M=1. There is no M=1 trick that wins (even zero-barrier loses on the atomic tax).
- **Where a megakernel COULD win (if revisited): M=K** (speculative-verify / batch) — the
  coordination overhead is FIXED per forward, so amortized over K tokens it drops below
  mlx's per-token cost while the dominant weight read is shared. qmv→steel-qmm.
- **Banked learnings (the value):** mlx `qmv_fast` GEMV port (8-bit bit-exact; 4-bit 1-ULP
  = compiler-level, not source), the software grid-barrier, generated-kernel codegen, L2
  quant-KV (93/100 KL-gated), and the **copy-verbatim methodology** + the measured
  coordination-overhead finding. See [[megakernel-qmv-port-win]],
  [[megakernel-copy-verbatim-methodology]].
- **THE win this session:** ported mlx's `qmv_fast` decode GEMV verbatim
  (load_vector pre-scale + mask-only qdot + 4-rows/simdgroup register reuse) →
  0.70→0.94×. Naive-GEMV bits/K-literal templating REGRESSED (register bloat → lower
  occupancy); the kernel is occupancy/bandwidth-bound, not branch-bound.
- **Correctness:** 97/100 teacher-forced, KL 9.7e-4, deterministic, no NaN (3 argmax
  near-ties; passes the perf-kernel-oracle-style KL bar, 1 under the strict 98 line).
- Built but perf-neutral (kept behind flags): generated layer-unrolled kernel
  (`MLX_BUN_MEGAKERNEL_GEN=1`, constants baked — confirms bandwidth-bound), RMSNorm-
  local + SwiGLU barrier folds (~194→145 barriers/tok).
- **Phase 4 — L2 quantized KV: increment 1 DONE, increment 2a is NEXT.**
  - Validated mlx's `affine_quantize` formula vs `ops.quantize` (bf16 ULP) —
    `scripts/experiments/kv-quant-formula-check.ts`.
  - Increment 1 (in-kernel quantize→dequant round-trip after rope, per-layer KVBITS
    literal in the generated kernel; `MLX_BUN_MEGAKERNEL_KVQUANT=1`,
    `kv-quant`→`megakernel-kv-teacherforced.ts`): **93/100, KL 1.49e-2, deterministic,
    no NaN** vs the optiq mixed-KV golden. Quant formula correct; the ~gap is a known
    storage-precision artifact — increment-1 stores `bf16(scale·q+bias)` (one extra
    bf16 rounding), but optiq's `quantizedMatmulQT` dequants K/V to **f32 on-the-fly**.
  - **Increment 2a DONE + DIAGNOSED: L2 PASSES the L3-class gate** (93/100, KL 1.38e-2,
    deterministic, no NaN; `MLX_BUN_MEGAKERNEL_KVQUANT=1`). Stores int q (exact in bf16) +
    bf16 scale/bias side buffer; `attend_simd_q<KVBITS>` dequants to f32 on read.
    Fixed a cross-threadgroup **coherence bug** (current-pos scale/bias → atomic `d_sb`;
    78→93). **Root cause of 93-not-97 FOUND (decisive, vs our bit-exact reference):** the
    megakernel's `qmv4` GEMV differs from mlx's `quantized_matmul` by **~1 bf16 ULP** (==
    L1's 9.7e-4 residual; confirmed `megakernel-kv-cmpl1.ts`: 425/1536 K elems >1 ULP), and
    **quantization is DISCONTINUOUS** so that 1-ULP K shift flips a q-level/group boundary →
    full quant-step dequant error (`cmpkv.ts`: 0.166) → amplified to 1.38e-2. NOT a bug —
    93/100 is the L2 ceiling exactly as 97/100 is L1's; bit-exact L2 would need a bit-exact
    GEMV (defeats qmv4). Gate is KL+agreement (L3 class), not the bit-exact golden.
  - **Increment 2b (deferred):** bit-pack q → uint32 for the actual 4-bit memory win
    (same logits as 2a).
  - Then **Phase 5** (wire into decodeStep/generate.ts, CLI flag, CI gate).

## Current work — Steel flash-CCE ORPO head + the ORPO training stack (2026-06-19)

Porting MLX's `steel` quantized GEMM verbatim into the flash-CCE ORPO head + fusing
the ORPO epilogue, wiring the whole new system end to end. **SHIPPED in v0.0.5**
(merged PR #16; `npm i mlx-bun` / `brew install joshuarossi/tap/mlx-bun`). **Forward +
backward: BOTH done + live + fast + `[M,V]`-free.**
- **Forward** ✅ steel GEMM + softcap + online-softmax → logp; default in
  `flashCceForward`; 180 ms; parity PASS e4b/cpm.
- **Backward** ✅ **IN PRODUCTION** (`BWD_STEEL_SOURCE`/`bwdSteelKernel`, H-tiled
  persistent accumulator + vocab-blocking + atomic dh; phase-2 W dequant via MLX's fused
  `QuantizedBlockLoader`). Parity PASS e4b (dh 0.40%) + cpm (0.28%); **754 ms = 5× the
  old SG's 3687 ms** (exact); peak **0.928 GB flat @ M=8192**. `MLX_BUN_CCE_BWD_NOSTEEL=1`
  fallback.
- **Prefix-sharing** ✅ wired into the trainer (`orpoPrefixShared`), composed with the
  flash head per branch (matches whole-vocab to 0.018%). **Composes with the segmented
  backward for BOTH MiniCPM5 (`SegmentedBackwardOrpoPrefix`) AND e4b
  (`SegmentedBackwardOrpoPrefixGemma4` — donor-KV + logical-position sliding-window prefix
  mask threaded through segments)** — grads 1.7–2.3% bf16-class, peak 30–39% lower.
- **Integration tests** ✅ `tests/train-orpo-fused-ce.test.ts` (`MLX_BUN_TEST_TRAIN=1`,
  6 pass): flash / segmented+flash / prefix+flash / **segmented+prefix+flash** all train
  CPM5 end-to-end, loss decreases. e4b parity: `prefix-shared-segmented-parity-e4b.ts`.
- **CLI verb** ✅ `mlx-bun train <model> --data <dir>` (src/cli.ts) — foreground, full ORPO
  stack on by default, auto-detects e4b/Gemma + sets its env, `--method/--save-every/--resume/
  --dry-run/--no-flash/--no-prefix/--no-segment`, streams loss + saves a mountable adapter.
  Drives the **same** `finetuneRunner` the server uses (in-process here; subprocess+GPU-lease
  there). Smoke-verified on CPM5 (3 steps, flash + prefix + seg). `mlx-bun help train` for flags.
- **Preconfigured launcher** ✅ `scripts/train-orpo.ts` — the same stack via env vars (scripting),
  auto-detects e4b (sets its env flags), per-row fallback + logging. **Measured e4b @ 8192
  full stack (prompt-dominant): 13.3 GB, ~70 s/step** (prefix-share makes it lighter AND
  faster than segmented+flash alone). See [docs/reference/orpo-quickstart.md](docs/reference/orpo-quickstart.md).

- **e4b @ 8192** ✅ **PROBED + FITS**: segmented+flash, SEG=2 → peak **16.14 GB** (~16 GB
  headroom on 32 GB), loss finite + decreasing — the historical "e4b OOMs ≥2048" ceiling
  is BROKEN. Footprint linear in seq (~+1.5 GB/1024 tok). Validated overnight config +
  the full SEQ→peak table are in the handoff doc.

- **Warm-start** ✅ `warmStartFromAdapter` (lora-params) + `RESUME=<dir>` on the launcher:
  continue a run from a checkpoint's LoRA weights (optimizer + LR schedule restart). Insurance
  for long runs that get interrupted.
- **Segmented head-sink UAF fixed** ✅ the segmented ORPO classes freed the flash head's
  `headSink` (lse/blockMax/CustomVjp) *before* the lazy CustomVjp backward read it →
  use-after-free segfault ~step 100. Fix: `ops.evalAll` the head-VJP roots before the dispose,
  in all four ORPO segmented classes.
- **Adapters live in the cache** ✅ launcher defaults `ADAPTER` to
  `~/.cache/mlx-bun/mlx-bun-finetunes/orpo-<model>` (never the repo; `adapters/` gitignored).
- **Eval loop (IFEval + UltraFeedback)** — the optiq capability suite is ported
  (`src/eval/`, datasets exported to `~/.cache/mlx-bun/eval-data/`). Dress-rehearsal result,
  reported honestly: an 800-step CPM5 ORPO run on UltraFeedback moved **IFEval 22.5% → 22.5%**
  (flat — general preference data + tiny run is the wrong lever for IFEval; the val loss did
  drop, so it learned). The real before/after is the **chunk segmenter** scored by boundary/label
  accuracy vs the Opus/GPT-5.5 gold — see [[training-tracks-are-appliance-components]].

**Remaining / next:**
- **CPM5 UltraFeedback run** — dress-rehearsal, PAUSED at ~step 4820 (val 1.66 → ~1.50 plateau,
  as expected for open-ended UF; checkpoints every 200 in `./adapters/cpm5-uf-8h/checkpoints/`,
  best-val ~`step-04200`). Resumable via `RESUME=<ckpt>`. NOTE: a session-spawned background run
  got **reaped by the agent runtime at ~47 min** (not a crash/OOM — confirmed via logs + `pmset`);
  long runs MUST be launched detached from the user's OWN shell (`nohup … &`), not by the agent.
- **The chunk segmenter** (THE load-bearing run): distill Opus/GPT-5.5 conversation-segmentation
  into a local model (data: `~/Code/lucien/.../chunk-v3/dpo/orpo-curated-*.fixed.jsonl`), scored by
  **boundary/label accuracy vs gold (chunk-eval), NOT val loss** — this localizes the Lucien
  synthesis pipeline's `chunk-recent` stage. See [[training-tracks-are-appliance-components]].
- **The e4b overnight** — `scripts/train-orpo.ts` full stack at 8192 (Josh runs it — ground rule).
- Perf follow-up: the optional lossless `MLX_BUN_CCE_BWD_BLOCK_EPS=1e-5` vocab-block skip on real
  long text.

**→ Quickstart + perf table: [docs/reference/orpo-quickstart.md](docs/reference/orpo-quickstart.md).
Training-flag reference: [docs/reference/training.md](docs/reference/training.md). Full plan +
gotchas + glossary: [docs/investigations/steel-flash-cce-handoff.md](docs/investigations/steel-flash-cce-handoff.md).**

## Vision — SigLIP sidecar lights up e4b image input (2026-06-17, merged to `main`)

Phase 12 (SigLIP vision tower) BUILT + validated for **gemma-4-e4b**. e4b now
answers image questions end-to-end (grounded descriptions). The 16-layer SigLIP
encoder is ported from `optiq/vlm/gemma4/` in **`src/vision/siglip.ts`**
(`SiglipVisionTower`): patchify → input_proj + 2D pos-embedding → 16× transformer
blocks (clippable linears with the trained finite clip bounds, manual-f32 q/k/v
RMS norms, on-device 2D RoPE, fused SDPA scale=1.0, GeGLU) → 3×3 avg-pool →
MultimodalEmbedder → /embed_scale. Single images run **unpadded** (numerically
identical to optiq's padded+masked path, verified, but far cheaper).

**Two gaps closed to make it work:**
1. `Gemma4Model.forwardEmbeddings` used to **throw** for per-layer-input models
   (e2b/e4b). Now threads the spliced ids (image positions zeroed) into the
   per-layer-input path — matches optiq's `zeroed = where(text_mask, ids, 0)`.
2. Tower selection + **lazy loading**: `vision_config.model_type` picks SigLIP
   (`gemma4_vision`: e2b/e4b/26B/31B) vs the encoder-free tower
   (`gemma4_unified_vision`: 12B). The tower loads on the **first image
   request**, not at server start (`getVisionTower`/`makeVisionLoader` in
   `server.ts`) — text-only sessions never pay for it.

**Works across the fidelity tree.** Vision prefill always falls back to the
**monolith** adapter (`forwardEmbeddings` → `forwardLayers`; the per-model
generated adapter returns `super.forwardLayers` when `bidir !== null`), so it's
adapter-agnostic. Decode flows through the chosen KV path: verified end-to-end on
**L1** (mlx-lm bf16) AND **L2** (optiq mixed-precision quantized-KV — the default
`mlx-bun serve`, monolith `quantizedSdpaUnfused` for the bidir prefill, generated
fused decode), both grounded (`tests/e4b-vision.test.ts`, 3/3). L3 perf flags
(`FUSED_GELU`/`PERF_KERNEL`/`FUSED_DECODE`) don't change the greedy. The vision
ENCODER (bf16, no KV cache) is the same across all three paths — its SDPA
divergence (below) is orthogonal to the KV-path choice.

**Parity (PLAN Phase 12 bar = tier-a ids + greedy prefix): MET.** Spliced prompt
ids bit-exact (256 soft tokens); pre-transformer features bit-exact (0.003%);
**ONE encoder layer on bit-exact input is bit-exact (0.0007%)**; greedy prefix
matches; output grounded. Full 16-layer features land at **~1.0-1.2% rel-RMSE**
vs optiq. **EVERY primitive is bit-identical** between mlx-bun's libmlx and the
oracle's mlx-metal on this machine — verified model-free
(`scripts/op-parity-{dump.py,check.ts}`): rms_norm, gelu, matmul, clip, cos, sin,
full multidim RoPE, sdpa (no-mask AND array-mask), sdpa padded-vs-unpadded
(no-op), pool (f32 matmul == optiq einsum). So there is **NO kernel / cross-build
divergence** (an earlier "fast-SDPA dispatch boundary" claim was a bug in the
op-test: `toFloat32` mis-read a non-contiguous SDPA output — must
`ops.contiguous()` before raw readback). The residual is a **sub-bf16
(≈0.0007%/layer) composition non-associativity that accumulates and is amplified
by the encoder's design**: scale=1.0 on RMS-normed q/k → q·k ~N(0, head_dim) →
sharply peaked softmax, so tiny roundings flip attention weights and, downstream,
greedy argmaxes (~0.17% of it is the patchify input: JS `pixel/127.5-1` vs
optiq's two-step f32 `2*(pixel/255-0.5)`). Toggling the LM flags
(`FUSED_GELU`/`PERF_KERNEL`/`NO_FUSED_SDPA`/`FUSED_DECODE`) did NOT change the
greedy. So the test asserts ids + greedy-prefix + grounded output, not full
bit-exact greedy.
**TODO(revisit):** full bit-exact vision IS achievable (it's the bar for the
rest of the codebase, 0.0000% on the text models) — match optiq's EXACT
op/lazy-eval/fusion ordering in the full graph, readable straight from
`optiq/vlm/gemma4/{vision,merge}.py`. Primitives already match bit-for-bit; only
the full-graph composition order remains. Left at tier-a for now (good enough). Gate: `tests/e4b-vision.test.ts` (golden
`goldens/e4b-vision.json` ← `scripts/gen-e4b-vision-golden.py`). 12B encoder-free
path unregressed (`tests/vision.test.ts` 4/4). **Not done:** audio tower (the
sidecar also carries `audio_tower.*`/`embed_audio.*`); 26B/31B SigLIP (same
tower, untested); image preprocessing on **resize** paths stays PIL-impure.

## Training — segmented backward, Phase A + Phase B BOTH COMPLETE (merged to `main`, PRs #9–11)

Long-context LoRA SFT that streams the backward segment-by-segment so only one
segment's activations are live — fits where the optiq/mlx-lm reference spikes/crashes.
**Phase A (MiniCPM5) done + validated + quality-confirmed** (PR #9): bit-exact grads vs the
full backward (relNorm 0.0000% under flash), peak **10.91 → 3.29 GB @2048** (non-seg
spikes to 21–26 GB @4096; seg stays 6–8 GB), **no memory leak**. Real 300-iter run:
peak **6.51 GB** (baseline 25.47 GB), `chunk-eval` **95.10/100** — EXCEEDS the
non-segmented baseline (91.70). **Phase B (e4b) COMPLETE + merged** (PRs #10–11):
`SegmentedBackwardGemma4` (`src/train/segmented.ts`, wired into the trainer) —
forward bit-exact, grads bit-exact for single-consumer donor reuse / ~1% bf16-class
(bf16 non-associativity, grouping-controllable) for the multi-consumer donor-KV sum.
**Trains all 42 layers at 8K (17.5 GB) where `mlx_lm.lora --grad-checkpoint` OOMs
training the same (verified: mlx-lm fits 8K only by dropping to its default 16
trainable layers, 25.7 GB).** At 2K/4K both train all 42; segmented ~15-25% lower
(seg 11.0/16.1 vs mlx-lm 12.8/20.9 GB). No leak; adapter saves. NOTE the earlier
"reference crashes at 4K / ~70 GB" claim was WRONG — it used mlx-bun's OWN
checkpoint (ineffective, 23 GB @2048) as the baseline, not mlx-lm's. **Handoff
report (start here): [docs/investigations/segmented-backward-handoff.md](docs/investigations/segmented-backward-handoff.md)**
— current state, validated numbers, how to run/train an adapter. Deep dossier:
docs/design/segmented-backward-training.md §9 (MiniCPM5) / §10 (e4b). Enable via `TrainConfig.segmentSize` (layers
per segment; 0 = off). Key files: `src/train/segmented.ts` (`SegmentedBackward`),
`src/model/minicpm5.ts` (`runLayerRange`), `src/mlx/autograd.ts` (`Vjp` — the
backward uses `mlx_vjp`, NOT a surrogate-loss `value_and_grad`, which leaked).
Two findings worth knowing: (a) `ops.sdpa`'s fused-eager forward ≠ its autograd
forward in bf16 (~0.12%) — use `MLX_BUN_TRAIN_ATTN=flash` for exact segmented grads;
(b) mlx `eval` doesn't detach, so boundaries are copied to leaves (`fromBytesCopy`).
Full dossier: [docs/design/segmented-backward-training.md](docs/design/segmented-backward-training.md) §9–10.

## Phase 14 bring-up — Qwen3.6-27B-OptiQ-4bit (merged; 27B confirmation Josh-gated)

> **Phase 14 bring-up — BOTH PARITY BARS PASS (2026-06-15, M1 Max).** Target
> family = **hybrid gated-DeltaNet** arch (`model_type qwen3_5`): every 4th layer
> full-attention + the rest linear-attention (Mamba-like), dense MLP. Verified
> end-to-end on **Qwen3.5-4B-OptiQ-4bit** (~4.5 GB, tied head): per-step logits
> bit-exact + greedy identical vs **mlx-lm** (bf16 KV) AND vs **mlx-optiq**
> (mixed-precision per-layer KV). The whole graph — gated-DeltaNet recurrence,
> gated full-attention, tied head, mixed-KV — is correct on real weights.
> Remaining: confirm the **27B** both bars (~15 GB, same arch, untied + Hv=48 —
> lower risk now) + 14f polish (fit/registry columns, chat-template/eos smoke).
>
> **Done + verified (model-free, no 15 GB load):**
> - Config/scaffolding (`config.ts`, `support.ts`, `factory.ts`) — validated on
>   the real config.json; model detected + supported.
> - New primitives: `mlx_conv1d` binding + depthwise `ops.conv1d`, `ops.split`,
>   `ops.softplus`, `ops.silu`. The gated-DeltaNet Metal kernel + `compute_g`
>   (`src/model/qwen3-delta.ts`) — **BIT-EXACT vs mlx-lm** at the real head
>   geometry (`tests/qwen-delta.test.ts`); conv1d **bit-exact**
>   (`tests/qwen-ops.test.ts`).
> - Model graph (`src/model/qwen3_5.ts`): typechecks; **static weight-name
>   audit clean (0 missing / 0 unused)**.
> - Parity harness READY: `scripts/regen-qwen-parity-goldens.ts` (bf16 + mixed)
>   + `tests/qwen-parity.test.ts` (opt-in `MLX_BUN_TEST_QWEN35=1`).
>
> Also supports the lighter same-arch **Qwen3.5-4B-8bit** (32 layers, tied head,
> no kv_config) — tied embeddings implemented; config + weight-name audit clean.
> It's the cheap first end-to-end check (bf16 bar only).
>
> **Next action:**
> 1. ✅ DONE — 4B both bars green (`MLX_BUN_TEST_QWEN35_4B=1`).
> 2. Optional confirmation — 27B both bars (~15 GB):
>    `bun scripts/regen-qwen-parity-goldens.ts 27b` then
>    `MLX_BUN_TEST_QWEN35=1 bun test tests/qwen-parity.test.ts`.
> 3. Commit the branch (Josh-gated); 14f polish (fit/registry, chat-template/eos).
>
> **Deferred** (orthogonal to the parity bars; sidecars not downloaded):
> MTP speculation (`mtp.safetensors`), Qwen3-VL vision, 35B-A3B MoE. See PLAN
> Phase 14 bring-up for the full findings.

## Current state (2026-06-17) — merged to `main`: distribution + onboarding + vision + adapters + training

> **Distribution story landed (2026-06-17).** Four install methods now live:
> direct-download (`install.sh`), **npm 0.0.4** (`bunx mlx-bun` / `npm i -g
> mlx-bun`), **Homebrew** (sign + notarize + tap auto-sync to
> `joshuarossi/homebrew-tap`; `brew install joshuarossi/tap/mlx-bun`), and build
> from source. `bun run publish` is the single-command release pipeline.
>
> **First-run onboarding** (commit `47a5d64`): `mlx-bun serve` with no model
> auto-downloads MiniCPM5, opens the browser, and starts the CPM5 welcome
> assistant — zero-config first run.
>
> **Focus-existing-chat-tab** (commit `472bc6f`): opening a new chat when one is
> already open focuses the existing tab instead of duplicating.
>
> **Adapters end-to-end** (PR #13): web chat selector + CLI `/adapter` command;
> discovery endpoint + `before_provider_request` injection hook. Scale/lr/
> checkpoints are run-configurable; `keep-all-checkpoints` + `metrics.json`.
>
> **SigLIP vision sidecar** (commit `4625fe5`): see the Vision section above.
>
> **Segmented-backward training** (PRs #9–11): see the Training section above.
>
> **Qwen3.5/MiniCPM5 reasoning fix** (PR #12): reasoning channel + restore
> messages fixed in the web UI.
>
> ---
>
> **HLG Curve Designer** (merged earlier). A v2 replacement sampler — draw a
> monotone curve in log-probability space and it replaces temperature+softmax
> (`p_out ∝ exp(curve(log p_in))`); identity ≡ temperature 1. Engine
> `src/curve-sampler.ts` (PCHIP over N movable control points, on-device), wired
> into `makeSampler` via `opts.curve`; served live (`GET /curves` editor,
> `POST /generate` curve sampler, `POST /signal` next-token histogram; "Curves"
> nav tab). Identity falls back to the model's default chat recipe (the honest
> baseline). Gated by `tests/curve-sampler.test.ts`. Built on the batched-serving
> + expert-offload work below.
> **UX bug fixed:** changing curve state (Reset / drag), prompt chips, engine,
> or a new generation now clears old samples, old blind-test reveal state,
> `LAST`/`TESTST`, and the visible "Copy text" action so results cannot appear to
> belong to the wrong prompt/curve.
>
> ---
> **`--batch N` now actually serves B>1** for BOTH full-attention (CPM) and
> sliding-window (Gemma) models: scheduler + gateway wired into the live server,
> end-to-end tested, sliding-window ring-wrap bit-exact vs mlx-lm. **This meets
> the mlx-lm-parity target** — mlx-lm's batched path is bf16 (its quantized
> batching is NYI), so bf16 continuous batching IS the drop-in. `--batch N` is a
> bf16 MODE: with KV quant unset it defaults to bf16 so the batch path engages
> out of the box (Option B); the serial default stays mixed-precision (optiq
> parity). An explicit `--kv-quant` under `--batch N` routes those requests to
> serial (bf16-only batching — warned). **Batched + mixed-precision KV is NOT a
> parity gap** — no ancestor does it (mlx-lm NYI, optiq no batching), so it's an
> optional novel extension (KL-gated, deferred), not required.
> Remaining (all optional polish): the `extend` join optimization, prompt-cache
> reuse under batching, KV-budget admission, throughput numbers.

- **Active: Phase 18 — concurrent / batched serving (slots)** `[~]`.
  Scheduler + gateway are live for BOTH full-attention (CPM) and
  sliding-window (Gemma) models; B=N bit-parity vs mlx-lm achieved for both.
  Polish items remaining: `extend` join op, prompt-cache reuse under batching,
  KV-budget admission, throughput numbers. See PLAN.md Phase 18 +
  `docs/design/parallel-slots.md`.
- **Just completed: docs/repo reorganization** — benchmark provenance
  consolidated into [benchmarks/RESULTS.md](benchmarks/RESULTS.md)
  (3 sections: parity / performance / quality), planning docs moved under
  `docs/planning/`, root decluttered, AGENTS.md de-duplicated. Plan and
  rationale: [docs/design/docs-reorg-plan.md](docs/design/docs-reorg-plan.md).
- **Phase 20 — expert offload (single-user MoE residency): spike complete,
  E1 in progress** `[~]`. Mechanism FULLY de-risked (probes all green: GPU
  `gather_qmm` over a page-aligned mmap is bit-exact + row-local; clean
  read-only file-mmap expert pages cost ~0 `phys_footprint` AND Metal does
  NOT wire them on GPU access → the ~14 GB pool becomes reclaimable cache,
  Apple's outcome without retraining). E0 measured + PASSED (routing
  concentrates ~90% on ~40–47% of experts, tasks specialise). **E1a done**:
  `scripts/convert-offload-experts.ts` produces a page-aligned offload-ready
  expert file, verified byte-identical on the real 26B. **E1b + E1c DONE
  2026-06-14 — IT WORKS ON THE REAL 26B**: env-gated `--expert-offload`
  (`src/expert-offload.ts` + one-line hook in `QuantizedSwitchLinear.load`)
  serves expert weights from a page-aligned file mmap →
  **phys_footprint 17.1 GB → 4.2 GB (−12.9 GB), BIT-EXACT, decode unregressed
  (38.9 → 41.5 tok/s)**. The 26B runs with the memory pressure of a ~4B model.
  **E1d (CLI flag) DONE 2026-06-14**: `mlx-bun serve <model> --expert-offload`
  builds `<model>/.mlx-bun-offload` on first use + activates (bit-exact runtime
  from E1c); split into runtime `src/expert-offload.ts` + build
  `src/expert-offload-build.ts`, wired in `cli.ts` serve. Verified (build /
  help / converter / reuse); `serve --expert-offload` smoke test is Josh's
  (starts a server). **Resume at E1e**: cleared-machine tok/s + optional
  hot-expert pinning + offload scales/biases (last ~6%). Design + all findings:
  PLAN Phase 20 +
  [docs/investigations/expert-offload-single-user-moe.md](docs/investigations/expert-offload-single-user-moe.md).
  Probes/tooling: `scripts/experiments/probe-{expert-residency,mmap-gather,madvise-eviction,footprint,metal-wire}.ts`,
  `scripts/run-expert-trace.ts`, `scripts/analyze-expert-trace.ts`, `src/expert-trace.ts`.

> **Resume here (2026-06-17):** distribution + onboarding + vision + adapters + training all merged to
> `main`. Active Phase 18 [~] batching polish (extend join op, prompt-cache reuse
> under batching, KV-budget admission, throughput numbers). Phase 14 Qwen 27B
> confirmation is Josh-gated (download). Phase 13 TurboQuant is next research
> direction. Full design + rationale: `docs/design/parallel-slots.md`.

**Goal: `--batch N` batched serving as a true `mlx_lm.server` drop-in.**
`--batch N` is a **mode switch** (default 1): N=1 = today's optimized serial
path (untouched); N>1 opts the WHOLE server into a continuous-batching engine
that is **bit-parity with mlx-lm B=N** (B floats 1..N). It is NOT a
load-dependent fallback — that would make results depend on concurrency, which
breaks determinism and the drop-in promise. (Decided with Josh.) No perf
downside: the bit-exact `bf16` path is already at decode/prefill parity with
mlx-lm with zero optimizations — see `benchmarks/RESULTS.md`.

**DONE (verified, committed on `batch-serving`):**
- **L1 batched FORWARD = bit-parity with mlx-lm B=2 across ALL 4 models** (CPM
  full-attn, Gemma 12B sliding+full, e4b per-layer-input+KV-share, 26B MoE),
  short-context. ✅ **Now wired into the live server for full-attention models**
  (see the scheduler + gateway bullets below); Gemma/sliding-window still falls
  back to serial (dynamic-B sliding is the follow-up).
- Verified primitive: `BatchedDecodeMaskCache` (`src/model/batched-mask.ts`) —
  left-pad + per-row `ropeOffsetArr` + `j>=leftPad` mask + fused bool sdpa;
  handles batch-prefill (offset 0) AND decode.
- Per-path fixes (all B=1-identity, no single-stream regression): gemma4
  `Attention` rope captured-once; `LlamaAttention` array-offset rope
  (`minicpm5.ts`); e4b per-layer-input `[1,L,…]` → B-generic (`gemma4.ts`).
- `--batch N` flag (`cli.ts`/`server.ts`; `--decode-concurrency` alias).
- Dynamic-B cache ops `mergeKVRows`/`filterKVRows` (`batched-mask.ts`) =
  mlx-lm's `cache.merge`/`filter`; unit-tested (no model) **AND now
  oracle-verified end-to-end** (next bullet).
- **Dynamic-B (rows join/leave mid-stream) = bit-parity with mlx-lm
  `BatchKVCache.merge`/`.extract`/`.filter` (CPM L1).** `realDynamicBatchedGreedy`
  (`tests/batched-decode-parity.test.ts`) drives a real batched decode through
  {A,B}→join C→{A,B,C}→evict A→{B,C} using `mergeKVRows`/`filterKVRows`; all 3
  per-row greedy trajectories match the oracle token-for-token. Oracle:
  `scripts/gen-batched-dynamic-golden.py` → `tests/fixtures/batched-dynamic-golden-cpm.json`.
  (Join = re-merge of extracted advanced-offset rows + fresh prefill; `extend`
  — the keep-running-batch optimization — is deferred to the scheduler.)
  Added `BatchedDecodeMaskCache.releaseRopeArr()` (free per-step RoPE array
  without disposing the delegated KV — needed when rebuilding a wrapper each
  step around a persistent inner). Full-attention only so far (CPM); Gemma
  dynamic-B is a follow-up (same staging as the static oracle rollout).
- **Scheduler CORE** (`src/serve/batch-scheduler.ts`, `BatchScheduler`): Bun-async
  detached driver owning one running batch; `submit(req)→Promise<stats>`; admit
  (solo prefill + first token + `mergeKVRows`) → batched decode step → per-row
  `sample` + accounting → `filterKVRows` evict. Optional `ExclusiveLock` held for
  the whole active period. Gate: `tests/batch-scheduler.test.ts` (teacher-forced,
  KL vs solo — staggered evict + mid-stream join, CPM L1, KL ≤2e-3).
- **Wired into the live server** (`src/serve/generation-gateway.ts` +
  `src/server.ts`): `GenerationGateway` picks the lane per request and an
  `AsyncMutex` keeps the serial path and the scheduler off the GPU/`loraState`
  simultaneously (batched requests run concurrently with each other; a
  non-batchable one drains the batch then runs solo). Both `handleChat` call
  sites (streaming + non-streaming, hence OpenAI chat / Anthropic messages /
  Responses) route through `gateway.run`; per-row SSE fan-out falls out for free.
  v1 batchable gate: full-attention model + no vision/adapter/repetition-penalty/
  user-seed (temp/top-p/top-k DO batch, per-row seed). Gate:
  `tests/batch-serving.test.ts` (ephemeral CPM server, `--batch 2`: /stats
  batched, 3 concurrent completions, streaming fan-out, batched+serial coexist).
  No serial regression: `tests/server.test.ts` 17/17, `server-tools.test.ts` 13/13.
- **Sliding-window (Gemma) dynamic-B** — `BatchedRotatingCache`
  (`src/model/batched-rotating.ts`): port of mlx-lm `BatchRotatingKVCache` (shared
  scalar ring state, per-row offset/leftPad, the ring-wrap rolled `make_mask`),
  scope-limited to what the scheduler needs (merge / N=1 decode / make_mask /
  filter / temporalView). Gate: `tests/batched-rotating.test.ts` model-FREE,
  bit-exact vs mlx-lm across the wrap (`scripts/gen-rotating-golden.py`). Scheduler
  generalized to per-layer cache types (full→KVCache+wrapper, sliding→rotating
  cache); fixed a stale-batch-size bug (`#B` must track `filter`). Gemma 12B
  scheduled greedy == mlx-lm B=2 golden with staggered eviction
  (`tests/batch-scheduler.test.ts`). Gateway enables sliding-window models;
  kv-quant requests route to serial (batched is bf16-only — L2 follow-up).
  `tests/batch-serving.test.ts` adds a Gemma `--batch 2` HTTP case.
- Oracle tooling: `scripts/gen-batched-golden.py` (needs optiq `register()` to
  load gemma4_unified in mlx-lm; uses mlx-lm `_make_cache`) → fixtures
  `tests/fixtures/batched-golden-*.json`. Real-path validator: `realBatchedGreedy`
  + gated `…ORACLE…` tests in `tests/batched-decode-parity.test.ts`
  (run: `MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batched-decode-parity.test.ts`).
- Earlier (on `main`): P1 parallel-load harness (`scripts/bench-serving-load.ts`).

## Next action — Phase 18 batching polish + Phase 14 Qwen 27B confirmation + Phase 13 TurboQuant

The engine is BUILT and LIVE for BOTH full-attention (CPM) and sliding-window
(Gemma) models (steps 1, 2a, 2b, AND sliding-window dynamic-B done — below).
Remaining work, in rough priority. Gate each with the parity tests; keep
`--batch 1` (and serial fallback) untouched.

- ~~**Gemma / sliding-window dynamic-B**~~ **DONE 2026-06-14** — `BatchedRotatingCache`
  (`src/model/batched-rotating.ts`, port of mlx-lm `BatchRotatingKVCache`, incl.
  the ring-wrap rolled mask) gated bit-exact vs mlx-lm model-free
  (`tests/batched-rotating.test.ts`); scheduler assembles each layer's cache by
  type (full → KVCache+BatchedDecodeMaskCache, sliding → BatchedRotatingCache);
  Gemma 12B scheduled greedy trajectories bit-exact vs the mlx-lm B=2 golden with
  staggered eviction (`tests/batch-scheduler.test.ts`). Gateway enables Gemma.
  **`--batch N` defaults KV to bf16** (Option B, `server.ts` kvScheme) so the
  batch path engages without `--kv-quant off`; gated by the prompt-cache-bypass
  signal in `tests/batch-serving.test.ts`.

**Not a gap — deferred optional extension:** **batched + mixed-precision KV
quant** is novel territory (mlx-lm's quantized batching is NYI; optiq doesn't
batch — no bit-exact oracle). It's a memory-density win (batching + 4-bit KV
compound), NOT an mlx-lm-parity requirement, so it's KL-gated and deferred. The
gateway routes explicit-kv-quant requests to serial.

- **`extend` join op** — today a join RE-MERGES the whole batch (extract all +
  prefill + `mergeKVRows`), O(B·S) per join. mlx-lm keeps the running batch and
  `extend`s the new rows in. Add `extendKVRows` + gate, swap into `#admit`.
- **Prompt-cache reuse under batching** — v1 solo-prefills every row from scratch
  (`cachedTokens`=0). Wire `PromptCache` take/put into the scheduler (it must be
  the sole cache owner — see parallel-slots.md "Prompt cache").
- **`B×S_max` KV-budget admission** — the scheduler admits up to `maxBatch` with
  no byte budget. Add total-projected-bytes admission (mirror the byte-capped
  PromptCache); mlx-lm `--prompt-concurrency` analogue.
- **Throughput numbers** — clean-machine `benchmark.sh` for aggregate tok/s vs B
  (the bandwidth→compute crossover). Josh-gated (preflight).
- Later rows: **L2** (quantized-KV batched, vs optiq) and **L3** (perf kernels
  under batching, KL+quality) — see the matrix in `parallel-slots.md`.

### Done (the build sequence)

1. ~~**Numerical gate for merge/filter**~~ **DONE 2026-06-14** — dynamic golden
   (`gen-batched-dynamic-golden.py`, rows join/leave) + `realDynamicBatchedGreedy`
   prove `mergeKVRows`/`filterKVRows` drive a real CPM batched decode bit-parity
   with mlx-lm's `BatchKVCache`. See the DONE list above. **NEXT starts at 2.**
2. **The async scheduler loop** — **2a (core) + 2b (wiring) both DONE 2026-06-14.**
   - **2a — scheduler CORE: DONE 2026-06-14.** `src/serve/batch-scheduler.ts`
     (`BatchScheduler`): Bun-async detached driver owning one running batch;
     `submit(req)→Promise<stats>`; per loop iter → admit waiting reqs (solo
     prefill + emit first token + `mergeKVRows` into the running batch) → one
     batched decode step (verified forward via `BatchedDecodeMaskCache`) →
     per-row `sample` + token accounting (EOS terminates w/o emit, onToken=false
     halts, maxTokens→length) → `filterKVRows` evict finished rows. Gated:
     `tests/batch-scheduler.test.ts` (`MLX_BUN_TEST_BATCH_DECODE=1`),
     **teacher-forced** (force each row's solo-greedy trajectory, compare per-row
     logits to solo via KL — NOT free-running greedy, which measures chaos);
     covers staggered eviction (3→2→1→0) AND mid-stream join (CPM L1, KL ≤2e-3 ≪
     1e-2). v1: full-attention only (rotating-cache model throws → serial);
     greedy/any per-row sampler; join = re-merge (no `extend` yet);
     `cachedTokens`=0 (no prompt-cache reuse under batching yet).
   - **2b — WIRED into `createServer`: DONE 2026-06-14.** `GenerationGateway`
     (`src/serve/generation-gateway.ts`) picks the lane; `AsyncMutex` enforces
     serial↔batched GPU/`loraState` exclusivity (batched run concurrently with
     each other; a non-batchable req drains the batch then runs solo). Both
     `handleChat` call sites route through `gateway.run`; per-row onToken closures
     (own `StopMatcher` + tool router + SSE stream) give per-row fan-out for free.
     `_is_batchable` gate lives here (full-attention + no vision/adapter/
     repetition-penalty/user-seed). `/stats.batch` now reports `{configured,
     batched, active_rows}`. See `tests/batch-serving.test.ts`.
3. **`_is_batchable` gate** — DONE as part of 2b (the willBatch predicate).
   `B×S_max` memory admission is still TODO (see the "Next action" list above).

**Caveats / scope (don't re-derive):**
- Short-context only so far (pre-wrap, rows < 1024 sliding window). Ring-wrap
  (context > window) batched decode is a separate follow-up (long-context golden
  + RotatingKVCache wrap handling).
- This is **L1** (bf16 KV). **L2** (quantized KV batched: `QuantizedKVCache` +
  `quantizedSdpaUnfused` with a 4-D mask) and **L3** (perf kernels under
  batching, gated by KL+quality) are separate later rows.
- Deferred spikes: paged KV (zero-waste alloc); batched mixed-precision serving
  (novel — no oracle). KV memory today = rung-2 contiguous shape, no budget yet.

## Open / Josh-gated

These need Josh physically (hardware, downloads, reboots):

1. **Clean-machine `./benchmark.sh --redo`** after a reboot (+ `sudo purge`
   for purge-cold rows) — quotable rows for the post-decode-fix engine and
   the perf-kernel default decision. Promote results into
   `benchmarks/RESULTS.md`.
2. **M1 Max rerun** — `git pull` then `./benchmark.sh --redo` (its last
   matrix predates the rope-fix).
3. **Phase 14 — Qwen 3.x bring-up** (was targeted ~2026-06-15): pick +
   download the first Qwen quant; also the MTP home and a consumer of the
   default-off fused-decode flag.
4. **Phase 13 — TurboQuant** (promoted research direction).
5. **Phase 12 — SigLIP vision**: e4b DONE + merged 2026-06-17 (see the Vision
   section at the top). Remaining: audio tower + 26B/31B SigLIP.
6. **`MLX_BUN_PERF_KERNEL` default flip** — gated on the clean-machine pass.

## Archived handoffs

Older dated handoff blocks (2026-06-10 / 06-11) live in PLAN-archive.md under the
"NEXT UP" / "NEXT SESSION PICKUP" / "SESSION SWEEP" headings, marked as
superseded. They're kept for history; this file is the current state.
