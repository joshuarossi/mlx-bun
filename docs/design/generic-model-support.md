---
status: active
axis: ON
canonical-for: model-support
plan-anchor: "Serving architecture consolidation `[~]` (opened 2026-08-21)"
last-verified: 2026-08-23
---

# Model support — run anything mlx-lm runs, and the ports we target

**This is the one design doc for model support.** New model ports become
SECTIONS under §6 (Ports) of this file, not new files in `docs/design/`.
Per-port phase logs, gate results, and dates belong in PLAN.md (anchors are
named per section); this doc keeps the design and the oracle each port is
held to.

Direction (Josh): *"we should be able to run any model that mlx-lm can run.
Run any model generically; for the specific models we target, optimize them
further — push the quality/performance border outwards. Like the gemma
generator methodology."*

Two tiers, one contract:

- **Tier-0 GENERIC** — one config-driven "universal" module per architecture
  *family*. Runs any covered checkpoint at **L1 parity** (bit-exact vs mlx-lm
  on this machine's GPU). Monolith path only: no compiled decode, no
  kv-quant. Slow, never broken. Built: `src/model/universal/` (dense
  llama-family). Design only: UniversalMoE.
- **Tier-1 TARGETED** — a model *graduates*: dedicated or generated forward,
  L2 (mlx-optiq) composition where an optiq artifact exists, Lab experiments
  where warranted, benchmark entries. The ports in §6.

**L1 = mlx-lm bit-exact is the gate for ANY new model**, generic or targeted.
Where no mlx-lm arm exists (audio, vision towers, DiffusionGemma, GLM-5.2's
Colibri container) the oracle is whoever ships the capability — optiq's
internal machinery, mlx-vlm, or the pinned Colibri engine — and the profile
declares that fidelity honestly (§3). A model the generic tier cannot hold to
L1 parity is not "supported with caveats"; it is unsupported until fixed.

---

## 1. The mlx-lm zoo, inventoried (mlx-lm 0.31.3, the oracle venv)

108 model files in `site-packages/mlx_lm/models/` after excluding
infrastructure (`base`, `cache`, `rope_utils`, `activations`,
`switch_layers`, `ssm`, `gated_delta`, `mla`, `bitlinear_layers`,
`pipeline`). `utils.py MODEL_REMAPPING` adds free aliases (`mistral→llama`,
`kimi_k2→deepseek_v3`, `qwen2_5_vl→qwen2_vl`, `falcon_mamba→mamba`, …).

| Bucket | ~Files | Shape | Unlocked by |
|---|---|---|---|
| A. dense llama-family | ~36 | embed → N × (norm → GQA attn(+rope) → residual → norm → MLP → residual) → norm → head; every file a permutation of a dozen knobs | **UniversalDense** (built) |
| B. MoE llama-family | ~17 | same block, MLP → router + SwitchGLU (+ shared expert) | **UniversalMoE** (design) |
| F. vision/text wrappers | ~10 | mlx-lm runs only the text stack; ~50–120 lines of config unwrapping + prefix stripping | thin shims over A/B |
| C. MLA lineage | ~11 | DeepSeek latent attention, usually + MoE + yarn | one MLA module, demand-driven (most exceed local RAM at 4-bit) |
| D. SSM / hybrid / linear-attention | ~17 | individually shaped (mamba, jamba, lfm2, qwen3_next, rwkv7, qwen3_5 …) | individual ports, the qwen3_5 pattern |
| E. legacy / exotic | ~13 | gpt2, openelm, phi3small, dbrx, bitnet … | individual ports, likely never |

Two generic modules + the wrapper shims cover roughly 60% of the zoo by
file count and the large majority of what actually gets downloaded (Llama
3.x, Mistral/Ministral, Qwen 2.5/3 dense+MoE, Gemma 1–3, Phi-3/4, SmolLM3,
OLMo-2/3, GLM-4, Granite, Mixtral, OLMoE are all in A/B/F).

---

## 2. Building blocks (what every tier is made of)

- **Config parsing** — `src/config.ts loadModelConfig` produces a normalized
  `TextConfig` (layerTypes/slidingWindow, headDim fallback, tie, softcap,
  partialRotaryFactor, `ropeParameters`, per-layer quant map via `quantFor`,
  kv_config, sidecar detection). Per-arch quirks for the generic tier live in
  the descriptor table (§4.1), not in this if-chain.
- **Primitives** — `src/model/gemma4-base.ts`: `QuantizedLinear` (+LoRA
  residual), `QuantizedEmbedding` (+tied `asLinear`), `RMSNorm`,
  `QuantizedSwitchLinear` (MoE experts), `KVCache`/`RotatingKVCache` (+
  quantized and TurboQuant variants), mask machinery, `logitSoftcap`,
  `disposing`. `src/model/universal/modules.ts` adds the dense
  (unquantized) `nn.Linear`/`nn.Embedding` ports and the load-time
  `WeightAudit`.
- **Generator** — `scripts/gen-model.ts` emits unrolled, branch-resolved
  `forwardLayers` overrides of `Gemma4Model` into `src/model/generated/`
  (e4b, 12B, 26B), dispatched by config fingerprint, gated bit-exact vs the
  monolith by `tests/generated-parity.test.ts`.
- **Parity harness** — `scripts/regen.ts <job>` (jobs: `parity`,
  `parity-26b`, `kvq`, `rotating-kvq`, `mixed-kv`, `lora`, `fused-sdpa`,
  `universal`, `qwen-parity`, `minicpm5`, `minicpm5-kv`, `turboquant`,
  `audio-fixtures`) drives the oracle venv
  (`/Users/joshrossi/Code/mlx-lm/.venv/bin/python`) to emit
  `<prefix>-parity.json` (explicit prompt ids + greedy ids) plus per-step raw
  logit `.bin`s; `tests/*-parity.test.ts` replay the ids (no cross-stack
  tokenizer dependency) and compare bit-exact on the same GPU. Manifests are
  tracked; `.bin` blobs are machine-specific and untracked
  (goldens/README.md).
- **Tokenizer** — `src/tokenizer.ts` (`@huggingface/tokenizers`, pure JS)
  reads stock `tokenizer.json` + `tokenizer_config.json`. Known landmine:
  BOS conventions (the double-BOS bug). Chat-template rendering rides Pi;
  `/v1` is the boundary.

---

## 3. Model profiles — capability declaration (`src/model/profile.ts`)

Model loading resolves ONE immutable profile before weights are opened.
A profile declares **construction only**: request-level methods (MTP, KV
schemes, adapters, grammar, sampling) are resolved elsewhere and cannot be
rewritten by profile selection.

```ts
interface ModelProfile {
  id: string;
  artifactFingerprint?: string;   // exact external identity (hf:<repo>@<rev>); family profiles omit
  configFingerprint?: string;     // structural guard for an exact artifact declaration
  fidelity: FidelityTarget;       // {l1, mlx-lm, bit-exact} | {l2, mlx-optiq, bit-exact} | {l3, null, measured}
  requiredCapabilities: EngineCapability[];
  execution: { loader: "safetensors" | "colibri";
               graph: "gemma4" | "minicpm5" | "qwen3.5" | "qwen3" | "qwen3-moe"
                    | "diffusion-gemma" | "glm5.2" | "universal-dense";
               loop: "autoregressive" | "diffusion";
               specialization: "artifact" | "dedicated" | "generated" | "generic" };
}
```

Engine capabilities (`ENGINE_CAPABILITIES`): `autoregressive`,
`colibri-container`, `diffusion`, `diffusion-gemma-graph`, `gemma4-graph`,
`generated-graph`, `glm5.2-graph`, `minicpm5-graph`, `mixed-precision-kv`,
`native-mtp`, `qwen3-graph`, `qwen3-moe-graph`, `qwen3.5-graph`,
`recurrent-state`, `safetensors`, `streamed-experts`,
`universal-dense-graph`, `vision-sidecar`.

Resolution (`resolveModelProfile`):

1. **Exact artifact profiles outrank family profiles.** The external
   fingerprint is derived only from an immutable HF snapshot path
   (`models--<org>--<repo>/snapshots/<40–64 hex>`); relocation keeps the
   identity, mutable aliases and arbitrary local dirs return null. A matched
   exact profile whose config fingerprint or graph acceptance mismatches
   REFUSES — it never falls back. Built-in exact declarations today:
   `qwen3.8-27b-optiq-4bit` (L1) and `glm5.2-colibri-int4-int8-mtp` (L3).
2. **Family profile** by config predicate (`src/model/support.ts`), in this
   order: `glm_moe_dsa` → `diffusion_gemma` → MiniCPM5 (exact-shape `llama`
   predicate) → `qwen3_5`/`qwen3_5_text` (dense hybrid only; the MoE variant
   is excluded) → `qwen3_moe` → `qwen3` → `gemma4*` (generated class if
   `GENERATED.has(fingerprint)`, else monolith) → universal-dense if
   `genericArgsFor(config)` resolves → throw naming the targeted list and
   the generic descriptor keys.
3. `validateProfile` enforces the fidelity/oracle pairing, loader↔graph
   (`glm5.2` ⇒ colibri), loop↔graph (`diffusion-gemma` ⇒ diffusion), and that
   every capability the execution composition implies is declared. Missing
   engine capabilities refuse; nothing downgrades.

**Factory** (`src/model/factory.ts`): `openModel(dir)` resolves the profile,
routes `loader: "colibri"` through `openGlm52RuntimeModel` (header-only
memory plan first, then `Glm52Model.openStreamed`; the Colibri snapshot has no
`model.safetensors.index.json` so it bypasses `Weights.open`), and otherwise
`createModel(weights, config, profile)` switches on `execution.graph`.
`RuntimeModel` = `Gemma4Model | MiniCPM5Model | Qwen35Model | Qwen3Model |
Qwen3MoeModel | DiffusionGemmaModel | Glm52Model | UniversalDenseModel`.

**Support tiers in UX** (`supportTier(modelType, repoId)` →
`"targeted" | "generic" | null`): consumed by `mlx-bun ls`
(src/cli.ts), `src/hub-rest.ts`, and the serve discovery routes. Drafters
(`*_assistant`) are never selectable on their own. Note the MiniCPM5
*record*-level check keys on the repo id containing
`minicpm5-1b-optiq-4bit`; the config-level check is the exact-shape predicate.

Reference mirror of this section: docs/reference/models.md "Declared model
profiles" (keep in sync).

---

## 4. Tier-0 design

### 4.1 `UniversalDense` (`src/model/universal/`)

One module (`dense.ts`), shaped like `qwen3.ts`, with every arch delta
selected by a `UniversalArgs` descriptor. `archs.ts` holds an explicit
table keyed by `model_type` (mlx-lm's `MODEL_REMAPPING` vendored in) — no
config sniffing to *identify* an arch; fingerprints remain a generated-
dispatch guard only. Descriptors in the table today (11):
**llama, smollm3, qwen2, qwen3, gemma, gemma2, phi3, olmo2, glm4, granite,
starcoder2**. `GENERIC_MODEL_TYPES` = the table's keys.

Key choices:

- **Transcribe mlx-lm op-for-op** inside each descriptor branch (q/k-norm
  before vs after reshape, rope order, scale points, softcap, mask kinds).
  The descriptor selects branches; it never approximates.
- **Rope factory** (`rope.ts`) — faithful port of `rope_utils.initialize_rope`:
  default / linear / llama3 / yarn / longrope (SuScaledRoPE) / proportional.
  Frequency tables are computed with the same mlx float32 ops the oracle uses
  at module init so the bytes match; host double math only where the oracle
  uses python floats. Gated by `tests/universal-rope.test.ts` against
  machine-keyed oracle fixtures (`tests/fixtures/universal-rope/`).
- **Dense checkpoints** (`modules.ts`) — verbatim `mlx.nn.Linear`
  (`addmm(bias, x, W.T)` / `x @ W.T`) and `nn.Embedding`; quantized paths
  delegate to gemma4-base. Additive bias is a first-class field (qwen2 qkv,
  starcoder2 all-bias).
- **Weight audit at load** — `WeightAudit.finish` diffs consumed tensors
  against the shard index minus the arch's sanitize-drop rules; unconsumed
  or missing tensors are a LOAD ERROR naming them, never a silently-wrong
  model.
- **KV cache** — `KVCache`/`RotatingKVCache` unchanged; `layer_types` /
  `sliding_window` already normalized. No kv-quant at Tier-0.
- **RuntimeModel surface** — the minimal contract `Qwen3Model` implements
  (config, weightsBytes, loraState, makeCache, forwardHidden,
  logitsFromHidden, forward, generate, loraTargets) so serving/eval/LoRA
  hot-swap work day one. `forwardEmbeddings` is a stub (vision is per-arch).

### 4.2 The parity gate for a new generic arch

`tests/universal-manifest.ts` — one entry per launch arch pointing at the
SMALLEST mlx-community 4-bit checkpoint of that arch, skip-if-absent, with
`expectClass: "universal" | "dedicated"` (the `qwen3` entry expects
`Qwen3Model` — generic never shadows targeted, the gate still runs the
oracle bar). Flow: user downloads → `bun scripts/regen.ts universal [<prefix>|all]`
→ `MLX_BUN_TEST_UNIVERSAL=1 bun test tests/universal-parity.test.ts`.
Asserts: fingerprint-free construction, weight audit clean, greedy
trajectory match, per-step logits bit-exact.

**Definition of supported-generic = manifest entry green on the current
machine.** Adding a descriptor without its manifest goldens is the one
anti-pattern this design forbids.

### 4.3 `UniversalMoE` (design only)

Same block with the MLP swapped for router + `QuantizedSwitchLinear`
(already serving 26B-A4B and Qwen3-MoE). Deltas to parameterize: top-k,
`norm_topk_probs`, routing score fn (softmax/sigmoid), routing scale,
shared-expert branch (+ optional shared-expert gate — qwen2_moe),
first-k-dense-replace (deepseek/glm4_moe layouts), grouped routing
(deepseek_v3-style, defer). gpt_oss (attention sinks) and llama4 (chunked
attention) are not claimed by the generic MoE. RAM honesty belongs in the
`ls`/fit output (weightsBytes vs RAM), not in marketing.

### 4.4 Graduation to Tier-1

Criteria (all three): (a) L1 generic parity green and stable across real
use; (b) it is a daily driver / benchmark / product target; (c) a measured
perf or memory gap vs a dedicated path worth the maintenance (number in
docs/reference/benchmarks.md).

Process, in order, stop at any step: (1) L2 — optiq goldens
(`mixed-kv` pattern) if an optiq artifact/kv_config exists; (2) dedicated
or generated forward — extend `gen-model.ts` if gemma4-base-shaped,
otherwise a hand port (`qwen3_5.ts` pattern; hand ports are proven and
cheap); (3) perf levers behind their existing flags (compiled decode,
kv-quant, fused sdpa) — output-changing experiments are Lab items
(unified-engine-frontier-plan.md §6); (4) benchmark + docs entries, tier
label flips to `targeted`. Graduation never deletes the generic path — it
stays the permanent correctness fallback, as the monolith does for generated
gemma classes.

### 4.5 Remaining phases

| Phase | Scope | State |
|---|---|---|
| 1 | UniversalDense + descriptor table + rope factory + bias + manifest harness | built |
| 1.5 | dense (bf16/fp16) checkpoints, no `.scales` | built (`modules.ts`) |
| 2 | UniversalMoE: mixtral, qwen2_moe, olmoe, glm4_moe, dots1, granitemoe, ernie4_5_moe, phimoe (qwen3_moe is already a dedicated port) | design |
| 3 | demand-driven one-offs (SSM/hybrid: lfm2, qwen3_next, mamba2, nemotron_h; MLA if a runnable target appears) — each a real port with its own goldens and cache types | design |
| 4 | `mlx-bun port <hf-repo>`: download smallest snapshot → descriptor coverage check (config keys + weight-audit dry run) → auto-regen goldens vs the oracle venv → run the gate → print verdict + manifest entry. Optionally generalize `gen-model.ts` to emit from UniversalDense | design (no CLI command exists) |

---

## 5. Multimodal seams shared by the ports

Every tower (vision or audio) returns language-space soft tokens
`[1, soft, textHidden]` pre-divided by `embed_scale` (the language model
re-multiplies), splices into the prompt through
`src/vision/prompt.ts buildMultimodalPrompt` (images + audio in document
order; `buildVisionPrompt` is a byte-identical wrapper), and enters the model
through `forwardEmbeddings` (merged embeddings; per-layer-input models take
a `multimodal` zeroing mask decoupled from the `bidir` attention overlay).
Media requests route to the **serial lane**, skip the prompt cache and spec
decode, and capability flags (`visionCapable`, `audioCapable` in
`src/registry.ts`) check TENSORS, not just config. Non-WAV audio transcodes
via macOS `afconvert`; video decodes via the AVFoundation sidecar
`mlx-bun-frame-extract` — zero vendored codecs.

---

## 6. Ports

One subsection per family. Each states the graph, its oracle, and the
design-relevant facts; phase logs live in PLAN.md at the named anchor.

### 6.1 Gemma-4 (e4b / 12B / 26B-A4B) — `src/model/gemma4.ts`, `gemma4-base.ts`, `generated/`

- **Graph**: line-for-line port of mlx-lm `gemma4_text.py` covering 12B
  (dense), e4b (per-layer-input embeddings + KV-shared layers), 26B-A4B
  (MoE: router + gather_qmm experts). SDPA scale 1.0 (q/k normalized);
  full-attention layers use global_head_dim 512, one global KV head,
  `attention_k_eq_v`; ProportionalRoPE rotates only
  `partial_rotary_factor` dims; python-float scalars promote weakly; mlx
  helper implementations replicated exactly (`x**3` is `mx.power`).
  Sliding layers use a plain cache + window masks (numerically identical to
  mlx-lm's RotatingKVCache).
- **Specialization**: `scripts/gen-model.ts` → `generated/gemma4-{e4b,12b,26b}.ts`,
  fingerprint-dispatched, bit-exact vs the monolith
  (`tests/generated-parity.test.ts`).
- **Oracle**: L1 mlx-lm (`goldens/parity.json` on the 12B snapshot,
  `tests/parity.test.ts`; 26B `tests/parity-26b.test.ts`); L2 mlx-optiq for
  the mixed-KV composition (26B `logits-26b-kvmix.bin`, `mixed-kv` job).
  Profile: `gemma4-generated` / `gemma4-dedicated`, L1.
- **Vision**: two towers behind one merge contract — `src/vision/siglip.ts`
  (full SigLIP encoder shipped by e2b/e4b/26B/31B; port of optiq's vendored
  mlx-vlm gemma4 encoder from the bf16 `optiq_vision.safetensors` sidecar)
  and `src/vision/embedder.ts` (12B `gemma4_unified` encoder-free patch
  embedder). Oracle = optiq internals (`goldens/e4b-vision.json`,
  `tests/e4b-vision.test.ts`, `tests/vision.test.ts`): spliced ids and
  soft-token count EXACT, greedy PREFIX match; full bit-exact greedy is not
  asserted because the 16-layer bf16 encoder composition drifts sub-bf16 and
  the scale-1.0 softmax amplifies it (siglip.ts header).
- **Audio**: §6.6.
- PLAN anchors: Phase 12 (SigLIP), Phase 2 findings (parity notes).

### 6.2 MiniCPM5-1B — `src/model/minicpm5.ts`

- **Graph**: `model_type: llama` (plain Llama block — no MiniCPM residual
  scaling), 24 layers, hidden 1536, 16/2 heads @128, vocab 130560, untied,
  `rope_theta` from `ropeParameters.full_attention`. Port target mlx-lm
  `models/llama.py`; the expert swiglu is mx.compile-compiled like the
  oracle's `activations.py` (`compiledSwiglu`, kill-switch
  `MLX_BUN_COMPILED_SWIGLU=0`) — the one fusion that matched the oracle's
  kernel set and brought CPM5 decode to parity with mlx-lm
  (decode-speed-program.md).
- **Dispatch**: the exact-shape `isMiniCPM5Config` predicate keeps it on
  the dedicated class ahead of the generic `llama` descriptor.
- **Oracle**: L1 mlx-lm (`goldens/minicpm5-parity.json`,
  `tests/minicpm5-parity.test.ts`); L2 mlx-optiq for per-layer quantized KV
  (`goldens/minicpm5-kv-parity.json`, `tests/minicpm5-kv-parity.test.ts`,
  bit-exact via `QuantizedKVCache` + `quantizedSdpaUnfused`). Also the
  TurboQuant KV testbed (`TurboQuantKVCache`). Profile
  `minicpm5-dedicated`, L1 (the L2 composition is a request-level KV scheme,
  not a profile property).
- Training reference model for segmented backward and ORPO
  (docs/design/orpo-training.md, orpo-training.md).

### 6.3 Qwen3 / Qwen3-MoE / Qwen3.5-family (3.6, 3.8) — `qwen3.ts`, `qwen3-moe.ts`, `qwen3_5.ts`

- **Qwen3** (`model_type: qwen3`): dense GQA with per-head q/k RMSNorm
  before RoPE, theta 1e6, tied embeddings. Primary use is the
  text-embedding backbone (`embedPooled`: last-token hidden, L2-normalized).
  Oracle L1 mlx-lm (`tests/qwen3-embed-parity.test.ts`). Shadows the
  generic `qwen3` descriptor.
- **Qwen3-MoE** (`qwen3_moe`): straight op-for-op transcription of
  mlx-lm `qwen3_moe.py` + `switch_layers.py` — gate Linear → precise
  softmax over all experts → argpartition top-k → renormalize → SwitchGLU
  with compiled swiglu; `decoder_sparse_step` / `mlp_only_layers` dense
  layers handled. Oracle L1 mlx-lm on the 30B-A3B
  (`tests/qwen3-moe-parity.test.ts`; the cached checkpoint has no
  kv_config, so no L2 bar).
- **Qwen3.5 hybrid** (`qwen3_5` / `qwen3_5_text`; the `qwen3_5_moe` variant
  is excluded by `isQwen35Config`): 64 layers, every
  `full_attention_interval`-th (4) a gated softmax-attention layer (q-gate
  split, per-head q/k norm, partial RoPE 0.25 @ base 1e7, GQA 24/4 @256,
  `o_proj(out·σ(gate))`), the rest **gated DeltaNet** linear attention
  (`in_proj_qkv/z/b/a`, depthwise causal conv1d k=4, `A_log`/`dt_bias`
  float, `RMSNormGated`). The recurrence is the reference's custom Metal
  kernel `gated_delta_step` ported VERBATIM (`src/model/qwen3-delta.ts`) —
  bit-exact parity requires it; the ops fallback reduces in a different
  order. `SSMCache` (conv + recurrent state) implements `Cache` and the
  spec-round contract (`specRoundBegin/Commit/Rollback`: free snapshot,
  replay of the kept window on partial reject — bit-exact by construction
  because the kernel's per-thread loop is serial). Weights under
  `language_model.`; `output_gate_type` other than `"swish"`/absent throws.
  **Qwen3.8-27B is byte-for-byte the 3.6-27B text geometry** — zero new
  graph work; the exact profile `qwen3.8-27b-optiq-4bit` pins the validated
  revision.
- **Oracles**: L1 mlx-lm `qwen3_5.py` with bf16 KV
  (`goldens/qwen38-parity.json`, `tests/qwen-parity.test.ts`; earlier 4B/3.6
  goldens via `regen.ts qwen-parity`); L2 mlx-optiq mixed-KV on the 3.5/3.6
  OptiQ artifacts (`install_mixed_kv` per-layer bits keyed by cache index ≡
  our `maybeQuantizeKv`). Qwen3.8's OptiQ repo ships no mixed-KV config →
  no L2 bar; mixed-KV serving there is Lab-tier.
- **Vision + video** (`src/vision/qwen3vl-{preprocess,tower,prompt}.ts`,
  `video-frames.ts`, `src/model/qwen3-mrope.ts`): mlx-vlm `qwen3_vl`
  vision tower at the qwen3_5 configuration (depth 27, hidden 1152, heads
  16 @72, patch 16, temporal 2, merge 2, deepstack empty) from the bf16
  sidecar `optiq/optiq_vision.safetensors`; PIL-exact fixed-point bicubic
  smart_resize; conv3d patch embed (new `mlx_conv3d` binding);
  `ensure_fused_sdpa`'s 72→80 head-dim pad replicated; **interleaved
  mRoPE** via the reference's verbatim Metal apply kernel with
  `get_rope_index` positions + delta exact, installed per request on the
  serial lane (text-only keeps the untouched fast-rope path — equal
  position streams degenerate mRoPE to plain RoPE). Video: AVFoundation
  sidecar samples at 2 fps (max 768 frames), temporal-pair patchify, gridT>1
  tower, transformers' `<t seconds>` per-frame-group prompt format with a
  python-`%.1f` port. Oracle = **mlx-vlm 0.6.14 pinned to mlx 0.31.2**
  (independent of mlx-lm, so no composite bit-match target exists): tower
  bit-exact at small grids, calibrated envelope at 2304 patches; e2e greedy
  token-exact on 2/3 image fixtures, step-0 argmax exact on all
  (`tests/qwen38-vision*.test.ts`).
- **Native MTP** (`src/spec/qwen-mtp-source.ts`, `--draft-kind mtp`): the
  separately published `Qwen3.8-27B-MTP-*` head (`fc` over
  concat(rms(embed(next)), rms(target_hidden)) → one full-attention layer
  with its own KVCache → target lm_head, block_size 3, DeepSeek-V3 shape)
  reads the target's PRE-final-norm hidden via `captureLayer`. Gate:
  greedy speculation token-identical to non-spec greedy
  (`tests/qwen38-mtp.test.ts`). Durable negative perf verdict on the quiet
  M1 Max (MTP-on slower than off at γ=2 despite 61% acceptance) — stays
  opt-in. Drafter logits verified against the mlx-vlm reference fed the
  oracle's captured hidden grid.
- Training: `loraTargets()` wired; the DeltaNet kernel is inference-only —
  training needs mlx-lm's pure-mlx `gated_delta_ops` scan under training
  (open).
- PLAN anchors: Phase 14 (bring-up, 14g MTP, 14v vision, 14w video, 14y
  YaRN open, 14z TurboQuant weights).

### 6.4 GLM-5.2 (`glm_moe_dsa`) — the Colibri hierarchy, `src/model/glm52*.ts`

Summary of docs/archive/investigations/colibri-glm52-port.md (frozen);
full phase record G0–G8 in git (`git show 3199c75:PLAN-archive.md`,
Phase 21, closed 2026-08-17). GLM-5.3+ would extend THIS section.

- **Decision**: a native `Glm52Model` over the PUBLIC Colibri container in
  place (no second copy, no Colibri child process, no `--backend`); the
  pinned Colibri build (`JustVugg/colibri` @ `44e489b`) is an external
  executable oracle for formats, logits/tokens, routing traces, memory and
  speed. Its policy code is studied and reproduced, not shipped.
- **Model**: 78 main layers (3 dense FFN + 75 sparse MoE, 256 routed
  experts, top-8) + an MTP row with its own 256 experts (19,456 expert
  instances). The dense spine (embeddings, lm-head, attention, norms, first
  dense FFNs, routers, shared experts) stays resident at int4 (~9.9 GB); the
  ~370 GB routed-expert pool stays on disk.
- **Graph** (`glm52.ts`, `glm52-mla.ts`, `glm52-dsa.ts`, `glm52-moe.ts`):
  MLA — q-a → norm → q-b; kv-a → latent norm; **compressed cache** of the
  512-wide latent + 64 RoPE values per token (`MLACache`, ~57× smaller than
  reconstructed K/V at this geometry), weight-absorption decode,
  reconstructed-prefill fallback, partial interleaved RoPE. **DSA indexer**
  — q/k/projection/norm, per-layer full/shared schedule, exact dense
  fallback when the selected set covers the prefix (`DSAIndexCache` only on
  layers that own it). MoE — sigmoid scores + correction bias for
  selection, un-biased gate weights, true top-8, routed scale, shared expert
  in parallel. Colibri arithmetic (offset-binary int4, per-row int8 scale
  applied once, RMSNorm with multiplicative weight and double-accumulated
  reduction) is mirrored in `glm52-reference.ts`. G2 favors an auditable
  dequantize→f32 path; the Metal streamed kernel (`glm52-streamed-metal.ts`)
  replaces the expert resolver without changing the graph.
- **Expert residency / streaming** (`glm52-residency.ts`,
  `glm52-streamed-experts.ts`, `glm52-expert-layout.ts`, `glm52-pilot.ts`,
  `glm52-coupling.ts`, `glm52-atlas.ts`): per-layer bounded LRU slots
  derived from the whole-process memory equation, pinned hot-store seeded
  from persistent usage, LFRU repinning with hysteresis, batch-union of
  unique (layer, expert) across rows so each expert is read once per
  layer/step, `pread` worker pool with slot generations and completion
  fences (no reuse while a lazy MLX command can retain the buffer), PILOT
  (next-layer router on the current state) and COUPLE (cross-layer route
  pairs) prefetch, RSS feedback shrinking only the evictable tier. Unified
  memory removes a copy, not the 370 GB: the meaningful states are disk /
  resident / pinned / loading / in-flight / evictable.
- **Fixed-context admission** (`glm52-memory.ts`, `factory.ts
  openGlm52RuntimeModel`): a header-only resource plan runs BEFORE any
  resident tensor or expert slab is opened — process limit (default 25 GiB
  preset or physical RAM, whichever is smaller), fixed context
  (default 4096 tokens, 128 generation), allocator/Bun/safety reserves — and
  refuses an impossible placement; the opened runtime's planned bytes must
  equal the preflight equation or load fails. Serving clamps `max_tokens`
  to the room under the fixed context (STATUS: "GLM fixed-context admission
  correction", generalized to every model in v0.2.0).
- **Native MTP** (`src/spec/glm52-mtp-source.ts`): the checkpoint's int8 MTP
  row as an in-process draft source sharing the target; serial only —
  batched rows decode single tokens (Colibri keeps MTP out of its mux path
  too). Batched caches land via `makeEmptyBatch/mergeRows/extractRow/
  filterRows/projectedBytes` on right-justified latent/RoPE/DSA tensors —
  no full K/V at merge, admission, extraction or cancellation.
- **Oracle / fidelity**: profile `glm5.2-colibri` / exact
  `glm5.2-colibri-int4-int8-mtp`, **L3 (measured)** — Colibri is neither
  mlx-lm nor mlx-optiq, so the tier system cannot call it bit-exact even
  though the G2 gate is a teacher-forced trajectory from the pinned engine
  on a tiny converted artifact (`tests/glm52-teacher-forcing.test.ts`,
  `fixtures/colibri-glm52/`). Curated numbers live in code as operator
  guidance (`GLM52_G5_MEASURED_WARM_DECODE_TPS`,
  `GLM52_G5_DIRECT_ORACLE_WARM_DECODE_TPS`, M1 Max 32 GB, MTP on) and in
  docs/reference/models.md "GLM-5.2 on a 32 GB Mac". The 24 GB M4 Pro is
  below the one-slot-per-layer floor and out of scope.
- **Not claimed**: embeddings, image/audio input, LoRA, training, adapters
  — advertised false, never faked (archive N8).
- PLAN anchor: Phase 21 (closed 2026-08-17); probes, gate tests, and
  lab spikes for the port surface retired afterwards (commit fbafe44).

### 6.5 DiffusionGemma-26B-A4B — `src/model/diffusion-gemma.ts`, `src/diffusion/`, `src/vision/diffusion-vision.ts`

Summary of docs/design/generic-model-support.md (the D0 reference dossier
there stays the porting contract; do not extend it).

- **What it is**: the first non-autoregressive model — an encoder prefill
  over the prompt builds a KV cache, then a decoder pass over a fixed
  256-token canvas (initialized to uniform-random ids, NOT a mask token) is
  denoised over up to 48 steps. 30 layers, hidden 2816, 16 heads; each
  layer runs a parallel dense MLP + 128-expert top-8 MoE summed through 7
  RMSNorms and a `layer_scalar`; attention scale 1.0, no attention softcap
  (final-logit softcap 30 in fp32), QK/V-norm post-proj/pre-RoPE, full
  layers (5,11,17,23,29) reuse k as v at hd 512 / kv 2 with partial rotary
  0.25; tied 4-bit head via `QuantizedEmbedding.asLinear`; a
  `SelfConditioning` MLP feeds soft embeddings from the previous step.
  Bidirectional decoder masks (`_make_decoder_masks`) are the crux.
- **Engine** (`diffusion-generate.ts`): linear temperature schedule
  (`t_min 0.4 → t_max 0.8`, DIVIDES logits), both samplers
  (confidence-threshold = optiq public default, entropy-bound = engine
  default), self-conditioning feedback, stability/EOS, block loop. RNG
  parity via bound `mlx_random_randint`/`mlx_random_seed` threading the
  global key in the reference's draw order. Parity traps recorded in the
  source doc: division not reciprocal-multiply; independent history copies;
  the as-loaded oracle has `generation_config = None` (stable-stop OFF,
  eos {1, 106}).
- **Vision**: a DEDICATED tower (`diffusion-vision.ts`), not the e4b SigLIP
  — inline-quantized `input_proj` truncates `2*(x-0.5)` patches to integers
  (a trained-in quirk), head_dim 72 padded to 80 like the reference, plain
  bf16 `down_proj`.
- **Oracle**: **mlx-optiq IS the oracle** (stock mlx-lm cannot load it);
  the mixed-precision quant is the native weight format, so matching optiq
  = L2 = the floor. Profile `diffusion-gemma-dedicated`, L2. Gates:
  single forward bit-exact (`tests/diffusion-parity.test.ts`), generation
  token-for-token for both samplers (`diffusion-gen-parity`), image
  token-for-token (`diffusion-vision`), serving (`diffusion-serving`), LoRA
  with the denoising objective (`diffusion-lora`,
  `src/train/diffusion-lora.ts`; MoE backward by stop-gradient on router
  indices). All `MLX_BUN_TEST_DIFFUSION=1`.
- **Entry points — honest state**: `src/generate.ts` routes by
  `instanceof DiffusionGemmaModel` to `generateDiffusionInner`, and
  `src/server.ts` has a diffusion vision lane; **`src/cli.ts` contains no
  diffusion reference** (`grep -c diffusion src/cli.ts` = 0). There is no
  diffusion-specific CLI surface; the model is reachable only through the
  generic `serve` / `generate` path by profile + instanceof dispatch, and
  streaming yields tokens after the engine completes. D4 (performance,
  measured) is open.

### 6.6 Audio input (gemma-4 audio tower) — `src/audio/`

Summary of docs/design/generic-model-support.md. Scope: audio-in, text-out
through the chat API; TTS/STT endpoints, streaming audio, >30 s, batched
audio prefill, and 26B-A4B/DiffusionGemma audio (no `audio_config`) are
non-goals.

- **Oracle**: mlx-lm strips `audio_tower`/`embed_audio` at load and rejects
  non-text content; optiq's internal gemma4 machinery is complete but its
  serve frontend never exposes audio → the oracle is the optiq internal
  model driven directly (`scripts/oracle/gen-e4b-audio-golden.py`,
  `goldens/e4b-audio.json`). The e4b OptiQ-4bit sidecar already holds all
  752 audio tensors (bf16, incl. clipped-linear min/max stats) plus
  `audio_config` and token ids (`boa 256000`, `audio 258881`,
  `eoa 258883`) — no download.
- **Pipeline**: `decode.ts` (RIFF/WAVE PCM16/24/32/f32, mean mixdown, linear
  resample to 16 kHz, PCM16/32768 like the oracle; >30 s truncates at
  480 000 samples BEFORE features, the oracle extractor's default) →
  `transcode.ts` (`afconvert` for non-WAV, content-sniffed) →
  `features.ts` (USM log-mel, frame 320 / hop 160 / rfft 512 in f64, 128 HTK
  bins, `log(x+1e-3)`, the oracle's exact f32 Hann values baked in because
  numpy's vectorized f32 cos differs by 1 ulp and log-amplifies) →
  `conformer.ts` (SSCP two Conv2d stride-2 stages (128, 32) → Linear 1024 →
  12 Conformer blocks with chunked local attention (chunk 12, left 13,
  softcap 50), depthwise Conv1d k=5, clipped linears → output_proj 1536 →
  `embed_audio` RMSNormNoScale → Linear → /embed_scale). **Dtype contract
  differs from siglip**: the oracle feeds f32 mel into bf16 weights and mlx
  promotes, so activations stay f32 end-to-end — do not cast to weight
  dtype. Clipped-linear stats are load-bearing (off diverges 90%).
- **LM semantics (resolved against the oracle)**: audio tokens are strictly
  CAUSAL; any audio in the prompt disables the vision bidir overlay
  entirely; per-layer-input zeroing uses the union multimodal mask; USM
  parameters are fixed constructor defaults (no per-bin normalization);
  `<|audio|>` → `boa + audio×n + eoa` with `n = min(ceil(ms/40), 750)` is
  splice-side. The merge divides by embed_scale AFTER the bf16 cast (weak
  scalar) — `features(preDivide=false)` + astype + div mirrors it.
- **Serve**: OpenAI `input_audio` plus optiq `audio`/`audio_url` parts;
  lazy `getAudioTower` from the same sidecar, zero new flags; a request
  with audio on a towerless model is an explicit 400; Anthropic
  `/v1/messages` rejects audio blocks with a pointer to the OpenAI
  endpoint; `audio` capability flag on `/v1/models`, `/library`, and the pi
  `ready` frame (requires `audio_config` AND tower tensors — the 12B stub
  sidecar reads false).
- **Gates**: T0 mel model-free (`tests/audio-features.test.ts`, 1e-5),
  T1 tower rel-RMSE (`e4b-audio-tower`, bit-exact result), T2 e2e greedy +
  decoded text EXACT for both fixtures (`e4b-audio`), T3 HTTP
  (`e4b-audio-serve`, `MLX_BUN_TEST_AUDIO_SERVE=1`).
- **Open (A5)**: bench cells (tower ms, TTFT delta, RSS delta) into
  docs/reference/benchmarks.md; 12B audio cell needs a sidecar rebuild via
  optiq `build_vision_sidecar` (local 12B sidecar holds 1 audio tensor);
  features-matrix note audio×batching = serial.
- PLAN anchor: "Phase: audio input — gemma-4 audio tower, e4b first".

---

## 7. Top design decisions

1. **Explicit descriptor table keyed by model_type (+ vendored
   MODEL_REMAPPING), not config sniffing** — support is a declared,
   testable surface; fingerprints remain a generated-dispatch guard only.
2. **One profile per load, resolved before weights open** — exact artifact
   > family > generic; mismatches refuse, never downgrade; profiles declare
   construction only.
3. **L1 bit-exact is the gate for generic too** — manifest-driven golden
   harness (explicit ids, raw per-step logits, same GPU).
4. **Weight audit at load** — unconsumed/missing tensors are a load error.
5. **Generic never shadows targeted; graduation never deletes generic.**
6. **The oracle for any capability is whoever ships it** — mlx-lm (L1),
   mlx-optiq (L2), mlx-vlm / optiq internals / Colibri where those are the
   only implementations — and the profile's fidelity label says which.
7. **Honest tiering in UX** — `mlx-bun ls`, hub REST, and discovery routes
   show `targeted` vs `generic`; media capability flags check tensors.
8. **New ports are sections of this doc**, with their durable phase record
   in PLAN.md.

## History

- 2026-06-24 — MiniCPM5 decode megakernel shelved (persistent single-dispatch
  decode kernel, ~0.94× baseline at best; L2 ceiling 93/100 from quant
  discontinuity amplifying 1-ULP GEMV drift). Premise removed by the
  bandwidth-wall finding (decode-speed-program.md: the baseline decode path
  sits at the memory-bandwidth wall; the real CPM5 waste was the unfused
  swiglu, fixed by `compiledSwiglu`). Code shelved to scripts/experiments
  2026-07-01 and deleted with that directory 2026-08-23 (git history); no
  megakernel code remains in `src/`. The doc
  `docs/design/generic-model-support.md` is superseded by this line.
- 2026-06-24 — DiffusionGemma D0–D3 + D5 landed (bit-exact forward,
  token-for-token generation, image, LoRA); D4 open.
- 2026-06-15 → 2026-08-18 — Qwen3.5-family: 3.6 text parity both bars;
  3.8 retarget (identical geometry), native MTP, vision, video landed.
- 2026-07-01 — Generic Phase 1 + 1.5 built (commit 9bd9f1b):
  UniversalDense, 11 descriptors, rope factory, dense checkpoints, weight
  audit, manifest harness.
- 2026-07-07 — Audio A0–A4 landed (e4b, oracle-exact); A5 open.
- 2026-08-17 — GLM-5.2 Colibri port closed (Phase 21); surface retired,
  design archived.
- 2026-08-21 — Model profiles (`src/model/profile.ts`) introduced; exact
  artifact declarations for Qwen3.8 OptiQ and GLM-5.2 Colibri.
- 2026-08-23 — This doc consolidated: audio-input-plan,
  diffusion-gemma-port, minicpm5-decode-megakernel, and the Colibri archive
  summarized here; ports become sections.
