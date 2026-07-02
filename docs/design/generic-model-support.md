# Generic model support — run anything mlx-lm runs

**Status: Phase 1 + 1.5 BUILT (2026-07-01, commit 9bd9f1b)** — `src/model/universal/`
(UniversalDense + descriptor table for 11 archs, rope factory bit-exact vs oracle
fixtures, DenseLinear/bf16 checkpoints, weight audit, dispatch ladder in
factory/support, manifest-driven parity harness). Parity gates light per-model
once the small checkpoints are downloaded (`scripts/regen-universal-goldens.ts` →
`MLX_BUN_TEST_UNIVERSAL=1`). Phases 2 (UniversalMoE), 3 (SSM/MLA one-offs),
4 (`mlx-bun port` scaffold) remain design.

Direction (Josh): *"we should be able to run any model that mlx-lm can run.
Run any model generically; for the specific models we target, optimize them
further — push the quality/performance border outwards. Like the gemma
generator methodology."*

The architecture already embodies the two-tier idea for one family:
`src/model/gemma4-base.ts` (shared machinery) + `gemma4.ts` (config-driven
monolith) + `src/model/generated/*.ts` (codegen'd specializations via
`scripts/gen-model.ts`, gated bit-exact by `tests/generated-parity.test.ts`).
This doc generalizes that shape to the whole mlx-lm zoo:

- **Tier-0 GENERIC** — one config-driven "universal" module per architecture
  *family* (dense llama-family first, MoE second). Runs any covered checkpoint
  at **L1 parity** (bit-exact vs mlx-lm on this machine's GPU). Monolith path
  only: no perf kernels, no compiled decode, no kv-quant. Slow, never broken.
- **Tier-1 TARGETED** — a model *graduates*: dedicated/generated forward,
  optiq-quant **L2** parity, **L3** original kernels, benchmark entries.
  Exactly what gemma4 / minicpm5 / qwen3_5 already are.

The fidelity contract is unchanged (three-level tree): **L1 = mlx-lm
bit-exact is the gate for ANY new model**, generic or targeted. A model the
generic tier cannot hold to L1 parity is not "supported with caveats" — it is
unsupported until fixed.

---

## 1. The mlx-lm model zoo, inventoried

Source: `mlx-lm 0.31.3` (the oracle venv),
`site-packages/mlx_lm/models/*.py`. **108 model files** after excluding
infrastructure (`base`, `cache`, `rope_utils`, `activations`,
`switch_layers`, `ssm`, `gated_delta`, `mla`, `bitlinear_layers`,
`pipeline`). `utils.py MODEL_REMAPPING` adds free aliases on top
(`mistral→llama`, `kimi_k2→deepseek_v3`, `qwen2_5_vl→qwen2_vl`,
`minimax_m2→minimax`, `iquestcoder→llama`, `falcon_mamba→mamba`, …).

### Buckets (by reading llama.py in full + feature-grep + sampling ~20 files)

**A. Dense llama-family — ~36 files, one parameterized module covers them.**
All are: embed → N × (norm → GQA-attention(+rope) → residual → norm →
MLP → residual) → norm → head. Every file is a ~170–240-line permutation of
the same dozen knobs (verified deltas listed in §3.1):

> llama (+mistral, iquestcoder via remap), qwen2, qwen3, gemma, gemma2,
> helium, olmo2, olmo3, smollm3, starcoder2, stablelm, phi3, internlm2,
> internlm3, granite, exaone, exaone4, glm, glm4, nemotron, minicpm, mimo,
> ministral3, seed_oss, hunyuan_v1_dense, ernie4_5, cohere, cohere2,
> apertus, nanochat, lille-130m, telechat3, solar_open, olmo, phi, plamo

(`smollm3` is literally a 75-line subclass of `llama` that swaps some
layers' rope for a no-op; `solar_open` is 38 lines. mlx-lm itself treats
this family as one module with per-file ModelArgs.)

**B. MoE llama-family (SwitchGLU experts) — ~17 files, a second module.**
Same block, MLP replaced by router + `SwitchGLU` (+ optional shared expert):

> mixtral, qwen2_moe, qwen3_moe, olmoe, phimoe, dots1, granitemoe,
> ernie4_5_moe, glm4_moe, hunyuan, Klear, bailing_moe, exaone_moe, deepseek
> (v1: MoE without MLA), step3p5, mimo_v2_flash, afmoe
> (llama4_text / gpt_oss are near-family but carry extra deltas —
> chunked-attention/NoPE, attention sinks.)

**C. MLA lineage (DeepSeek latent attention, usually + MoE + yarn) — ~11:**
> deepseek_v2, deepseek_v3 (+kimi_k2 remap), deepseek_v32, glm4_moe_lite,
> glm_moe_dsa, kimi_k25, kimi_vl, longcat_flash(+ngram), minicpm3, youtu_llm

**D. SSM / hybrid / linear-attention — ~17, individually shaped:**
> mamba, mamba2 (+falcon_mamba remap), falcon_h1, jamba, granitemoehybrid,
> nemotron_h, plamo2, lfm2, lfm2_moe, qwen3_next, kimi_linear, minimax,
> recurrent_gemma, rwkv7, baichuan_m1, **qwen3_5 (already ported)**,
> qwen3_5_moe

**E. Legacy / exotic one-offs — ~13, deprioritized:**
> gpt2, gpt_bigcode, gpt_neox, qwen (v1), openelm (per-layer varying dims),
> phi3small (blocksparse attn), phixtral, dbrx, nemotron-nas (variable
> blocks), bitnet (bitlinear), afm7, baichuan_m1 (also in D), lille-130m-ish
> oddities

**F. Vision/text wrappers — ~10, ~free once the text base exists:**
> gemma3, gemma4 (ours already), qwen2_vl (+qwen2_5_vl), qwen3_vl,
> qwen3_vl_moe, kimi_vl, lfm2-vl, mistral3 (+llava remap), pixtral, llama4
> — mlx-lm runs only their *text* stack; each wrapper is ~50–120 lines of
> config unwrapping + weight-prefix stripping.

### Coverage math

| Bucket | Files | Unlocked by |
|---|---|---|
| A. dense llama-family | ~36 (33%) | **one** UniversalDense module (Phase 1) |
| B. MoE llama-family | ~17 (16%) | **one** UniversalMoE module (Phase 2) |
| F. vision wrappers | ~10 (9%) | thin config/prefix shims over A/B (Phase 1–2) |
| C. MLA lineage | ~11 (10%) | one MLA attention module (Phase 3, demand-driven — most are >24 GB even at 4-bit) |
| D. SSM/hybrid | ~17 (16%) | individual ports, qwen3_5 pattern (Phase 3) |
| E. legacy/exotic | ~13 (12%) | individual ports, likely never |
| already in mlx-bun | 5 | gemma4(+text), qwen3, qwen3_5, minicpm5(llama-typed), diffusion_gemma |

**Two generic modules + the wrapper shims ≈ 60% of the zoo by file count,
and >90% of what actually gets downloaded** (Llama 3.x, Mistral/Ministral,
Qwen 2.5/3 dense+MoE, Gemma 1–3, Phi-3/4, SmolLM3, OLMo-2/3, GLM-4,
Granite, Mixtral, OLMoE are all in A/B/F).

---

## 2. What mlx-bun already has to build on

Audited 2026-07-01; file references are load-bearing.

- **Config parsing** — `src/config.ts loadModelConfig`: already a *normalized*
  config (`TextConfig`) with per-model_type quirk handling inline (gemma
  nested `text_config`, qwen3_5 flat rope dict, llama defaults, diffusion
  backfill). Already carries: layerTypes/slidingWindow, headDim fallback,
  tie, softcap, partialRotaryFactor, `ropeParameters` map, per-layer quant
  map (`quantFor`), kv_config. **This is 70% of the normalization layer;**
  it needs the delta fields from §3.1 and a table-driven (not if-chain)
  quirk mechanism before it drowns.
- **Primitives** — `src/model/gemma4-base.ts`: `QuantizedLinear` (+LoRA
  residual), `QuantizedEmbedding` (+tied `asLinear`), `RMSNorm`,
  `QuantizedSwitchLinear` (MoE experts — already used by 26B),
  `KVCache`/`RotatingKVCache`(+quantized variants), mask machinery,
  `logitSoftcap`, `disposing`. `src/model/qwen3.ts` (276 lines) is the
  proof-of-shape: a complete dense port using only these primitives.
  `minicpm5.ts`/`qwen3_5.ts` show the "dedicated module conforming to
  RuntimeModel" pattern.
- **Gating/dispatch** — `src/model/support.ts` (allowlist by model_type +
  config predicates), `src/model/factory.ts` (specific classes →
  fingerprint-matched generated class → monolith; *rejects* unknown types),
  `src/model/fingerprint.ts` (structural hash for generated dispatch).
- **Generator** — `scripts/gen-model.ts`: emits unrolled, branch-resolved
  `forwardLayers` overrides *of Gemma4Model specifically* (reads the shard
  index for layout facts, folds kv-quant constants, guards cache signature,
  falls back to monolith). Gated by `tests/generated-parity.test.ts`
  (bit-exact vs monolith, fingerprint asserted, fast-path-use asserted).
- **Parity harness** — the `scripts/regen-*-goldens.ts` +
  `tests/*-parity.test.ts` pattern (e.g. `regen-qwen-parity-goldens.ts`):
  oracle venv emits `<prefix>-parity.json` (explicit prompt ids + greedy
  ids) + per-step raw logit `.bin`s; the test replays ids (no cross-stack
  tokenizer dependency) and compares bit-exact on the same GPU. Plus
  `scripts/check-minicpm5-port.ts` (hard, no-skip port check) and
  `scripts/inspect-model.ts` (tensor name/shape/dtype dump — the seed of
  the weight audit).
- **Tokenizer** — `src/tokenizer.ts`: `@huggingface/tokenizers` (pure JS)
  reads stock `tokenizer.json` + `tokenizer_config.json`; already
  generic across BPE/SentencePiece-as-tokenizer.json. Known landmine class:
  BOS conventions (the double-BOS bug cost a debug session — see memory);
  chat-template rendering rides Pi, with `/v1` as the boundary.

### Gaps the generic tier must close (found in this audit)

1. **No unquantized Linear.** `QuantizedLinear.load` throws without a
   `.scales` tensor (`gemma4-base.ts:94`). Tier-0 v1 can inherit this
   constraint (target mlx-community 4/8-bit checkpoints — what users pull
   anyway), but a plain `DenseLinear` (bf16/fp16 `ops.matmul`) is a required
   fast-follow: many small models ship only fp16.
2. **No additive linear bias.** `QuantizedLinear`'s `biases` are quant
   zero-points, not a bias *term*. qwen2 (attention qkv bias), stablelm,
   starcoder2, phi et al. need an optional post-matmul `+ bias` in the
   linear primitive.
3. **Rope variants.** Only default/proportional exist in the runtime.
   mlx-lm `rope_utils.py` also ships: `linear`, `llama3` (Llama3RoPE),
   `yarn` (3 spellings), `longrope`/`su` (SuScaledRoPE), `mrope`. llama3 +
   yarn + longrope are hard requirements for bucket A (Llama 3.x, Phi-3,
   DeepSeek-lineage, various long-context finetunes).
4. **Attention-score softcap** (gemma2): needs the manual
   (q·kᵀ → tanh-cap → softmax) path — `ops.sdpa` can't express it.
5. **factory.ts rejects unknown types** rather than attempting a generic
   fallback (by design today; changes in §3.3).

---

## 3. Design

### 3.1 Tier-0: `UniversalDense` (src/model/universal/)

One module, shaped exactly like `qwen3.ts` but every delta a config field.
**The normalized config is the union of mlx-lm's per-arch ModelArgs**, and a
declarative **arch descriptor table** supplies per-model_type defaults +
config-key aliases — mirroring mlx-lm's structure (shared base module,
per-arch args) without one file per arch:

```ts
// src/model/universal/archs.ts — ~15–25 lines per arch vs mlx-lm's ~200
export interface ArchDescriptor {
  // block structure
  block: "sequential" | "sandwich" | "parallel";  // llama | gemma2/glm4 | cohere/phi
  norm: { kind: "rmsnorm" | "layernorm"; plusOne?: boolean; bias?: boolean };
  qkNorm: "none" | "head-rms" | "layernorm-2d";   // qwen3/olmo2 | cohere
  mlp: { kind: "gated" | "plain"; act: "silu" | "gelu" | "gelu_tanh" | "relu2" };
  fusedQkv?: boolean; fusedGateUp?: boolean;      // phi3 — split in sanitize
  // scalars (all read from config.json when present; descriptor = default)
  attnLogitSoftcap?: number;   // gemma2
  logitScale?: ConfigPath;     // cohere (multiply), granite logits_scaling (divide)
  embedScale?: "sqrt-hidden" | "mup" | null;      // gemma family, minicpm
  residualMultiplier?: ConfigPath;                // granite
  bias: { qkv?: boolean; o?: boolean; mlp?: boolean };
  nope?: "interval" | "list";  // smollm3, llama4-style no-rope layers
  // weights
  weightMap?: Partial<Record<CanonicalName, string>>;  // starcoder2 c_fc/c_proj, gpt2 h.N.*
  sanitize?: (names: string[]) => Rename[];       // fused-proj splits, inv_freq drops
  configAliases?: Record<string, string>;         // norm_epsilon→rms_norm_eps etc.
}
export const ARCHS: Record<string /* model_type */, ArchDescriptor> = { ... };
```

Key choices:

- **Descriptor keyed by `model_type` + mlx-lm's MODEL_REMAPPING table
  vendored in.** No config sniffing/fingerprinting to *identify* an arch —
  fingerprints stay what they are today: a dispatch guard for generated
  specializations. Explicit table = explicit support surface = honest
  `mlx-bun models` output.
- **Transcribe mlx-lm op-for-op** inside the universal forward, per
  descriptor branch — same discipline as every existing port (q/k-norm
  before vs after transpose, rope order, cast points). The descriptor
  selects branches; it never approximates.
- **Rope factory** `src/model/universal/rope.ts` ports
  `rope_utils.initialize_rope` verbatim: default/linear (native
  `ops.rope` with scale), llama3 (precomputed freqs), yarn, longrope/su.
  This is the single riskiest chunk of Phase 1 — rope bugs are
  off-by-a-little and only caught by logit goldens, which is why the parity
  gate feeds explicit ids and compares raw logits per step.
- **KV cache**: reuse `KVCache`/`RotatingKVCache` unchanged;
  `layer_types`/`sliding_window` already normalized. No kv-quant at Tier-0
  (that's an L2/graduation concern).
- **Quantization**: v1 requires MLX-quantized checkpoints (`.scales`
  present), same as the rest of the runtime; `DenseLinear` for
  fp16/bf16 checkpoints is Phase 1.5. Add the additive-bias term to both.
- **RuntimeModel surface**: implement the same minimal contract
  `Qwen3Model` does (config, weightsBytes, loraState, makeCache,
  forwardHidden, logitsFromHidden, forward, generate, loraTargets) so
  serving/eval/LoRA hot-swap work day one. `forwardEmbeddings` throws
  (vision is per-arch work).

### 3.2 Tier-0.5: `UniversalMoE`

Same block with the MLP swapped for router + `QuantizedSwitchLinear`
(already exists and is serving 26B-A4B). Deltas to parameterize: top-k,
`norm_topk_probs`, routing score fn (softmax/sigmoid), routing scale,
shared-expert branch (+ optional shared-expert gate — qwen2_moe),
first-k-dense-replace (deepseek/glm4_moe layouts), grouped routing
(deepseek_v3-style, defer). gpt_oss (attention sinks) and llama4 (chunked
attention) are *not* claimed by the generic MoE — they graduate to
one-offs if wanted.

Memory reality check on the reference machines (24–32 GB): Mixtral-8x7B
4-bit ≈ 25 GB — no. OLMoE-1B-7B, Qwen3-30B-A3B (≈17 GB @4bit),
GLM-4 lite variants, granitemoe small — yes. The generic MoE tier is
worth building, but expectations belong in `mlx-bun models` output
(weightsBytes vs RAM), not in marketing.

### 3.3 Dispatch changes (support.ts / factory.ts)

Order matters — **generic never shadows a dedicated port**:

```
createModel(weights, config):
  1. dedicated classes (diffusion, minicpm5, qwen3_5, qwen3)      — unchanged
  2. gemma4*: GENERATED.get(fingerprint) ?? Gemma4Model            — unchanged
  3. ARCHS[remap(config.modelType)] → new UniversalDense/MoE(...)  — NEW
  4. throw "unsupported model_type X (nearest: …)"                 — unchanged shape
```

- `support.ts isSupportedModelRecord`: add `GENERIC_MODEL_TYPES` (the
  descriptor table's keys, post-remap). Keep the drafter exclusion.
  `mlx-bun models` labels the tier: `supported (targeted)` vs
  `supported (generic)` — sets perf expectations and doubles as the
  graduation worklist.
- The current hard throw for non-MiniCPM5 `llama` configs is *replaced* by
  the generic path (that throw exists only because nothing generic existed).
  `isMiniCPM5Config`'s exact-shape predicate keeps MiniCPM5 on its
  dedicated class ahead of the generic.

### 3.4 Weight-name mapping + load audit

Bucket A is already ~uniform in HF land
(`model.layers.N.self_attn.{q,k,v,o}_proj`, `mlp.{gate,up,down}_proj`,
`input_layernorm`, `post_attention_layernorm`, `model.norm`,
`model.embed_tokens`, optional `lm_head`). The descriptor handles the
exceptions: rename maps (starcoder2 `c_fc/c_proj`), fused-proj split rules
(phi3 `qkv_proj`, `gate_up_proj` — split at load into views/copies),
prefix strips (vision wrappers `language_model.model.*` — gemma4 already
does this via `prefixBase`), and drop rules (`rotary_emb.inv_freq`,
mlx-lm `sanitize`).

**Every generic load runs a weight audit** (grow `scripts/inspect-model.ts`
into `src/model/universal/audit.ts`): after module construction, diff
{tensors in shard index} vs {tensors consumed}. Unconsumed or missing
tensors ⇒ load error naming them, not a silent wrong-answer model. This is
the cheap tripwire that catches descriptor mistakes before parity does
(the "verify the foundation" rule, mechanized).

### 3.5 The parity gate for a NEW arch (cost: ~2–4 h/arch, mostly waiting)

Pattern already proven three times (gemma/minicpm5/qwen). Parameterize it
once:

1. `scripts/regen-generic-goldens.ts <snapshot> <prefix>` — oracle venv
   (`/Users/joshrossi/Code/mlx-lm/.venv/bin/python`, mlx-lm `load()` +
   `make_prompt_cache`) emits `<prefix>-parity.json` (explicit prompt ids,
   greedy ids) + 12 step-logit `.bin`s. Same-machine rule applies (logit
   goldens are GPU-specific — label goldens with host).
2. `tests/generic-parity.test.ts` — iterates a manifest
   (`tests/generic-manifest.ts`: prefix → snapshot path → model_type),
   skipIf-gated on snapshot presence like every parity test. Asserts:
   fingerprint-free construction, weight audit clean, greedy trajectory
   match, per-step logits bit-exact.
3. Checkpoint choice: **smallest mlx-community 4-bit of the arch**
   (0.5B–3B exists for nearly all of bucket A) — keeps the gate runnable
   and the download small. Downloads stay a user action (ground rules).

Definition of supported-generic = manifest entry green on the current
machine. No entry, no support claim.

### 3.6 Graduation to Tier-1 (targeted)

**Criteria** (all three): (a) L1 generic parity green and stable across a
few sessions of real use; (b) it's a daily driver / benchmark / product
target (e.g. the Lucien pipeline models); (c) measured perf or memory gap
vs a dedicated path that's worth the maintenance (number in
`benchmarks/RESULTS.md`, per the every-perf-claim-gets-a-number rule).

**Process** (the gemma methodology, in order — stop at any step):
1. **L2**: optiq-quant goldens (`regen-*-kv-goldens` pattern, mixed-KV vs
   the optiq oracle) if an optiq checkpoint/kv_config exists for it.
2. **Dedicated or generated forward**: if the arch is gemma4-base-shaped,
   extend `gen-model.ts`; otherwise hand-port a dedicated module
   (`qwen3_5.ts` pattern). Note: today's `gen-model.ts` subclasses
   `Gemma4Model` specifically — generalizing it to emit from
   `UniversalDense` is Phase 4 work, and *optional*: hand ports are proven
   and cheap ("faithful port took ~1 hr, not the huge effort claimed").
3. **L3 kernels**: fused decode / compiled decode / kv-quant / flash paths,
   each behind its existing flag, each frozen-oracle-gated.
4. RESULTS.md + docs entries; `mlx-bun models` label flips to `targeted`.

Nothing about graduation removes the generic path — it stays as the
always-correct fallback, exactly like the monolith does for generated
gemma classes today.

---

## 4. Phased rollout

| Phase | Scope | Unlocks | Effort | Key risks |
|---|---|---|---|---|
| **1** | `UniversalDense` + descriptor table + rope factory (llama3/yarn/longrope) + bias term + goldens harness. Launch archs: **llama (⇒ Llama 3.x + Mistral + Ministral), qwen2, qwen3(fold-in), gemma, gemma2, smollm3, olmo2, olmo3, phi3, glm4, granite, starcoder2** | ~20 files at launch; the rest of bucket A (~36 total) as S-sized descriptor+golden follow-ons; F-wrappers for covered bases | **L** (module M, rope M, harness S, 12×goldens S-each) | rope variants (llama3/yarn/longrope math), gemma2 softcap manual-attn path, phi3 fused-proj split, BOS/tokenizer conventions per family (the double-BOS class of bug), qwen2 qkv bias |
| **1.5** | `DenseLinear` (bf16/fp16 checkpoints, no `.scales`) | fp16-only small models; removes the "MLX-quantized only" constraint | **S–M** | dtype/cast points vs mlx-lm (bf16 matmul accumulation — see e4b length-sensitivity memory) |
| **2** | `UniversalMoE` (router + SwitchGLU + shared experts + first-k-dense) : **mixtral, qwen2_moe, qwen3_moe, olmoe, glm4_moe, dots1, granitemoe, ernie4_5_moe, phimoe** | ~12–15 of bucket B (gpt_oss/llama4 excluded) | **M** (SwitchGLU exists; routing variants are config) | routing-score parity (softmax vs sigmoid + norm_topk), RAM honesty on 24 GB |
| **3** | Demand-driven one-offs, qwen3_5 pattern: SSM/hybrid (**lfm2, qwen3_next, mamba2, nemotron_h**…), MLA module if a runnable target appears (**minicpm3**; deepseek-lineage mostly exceeds local RAM) | bucket C/D picks, ~1 model per effort unit | **M–L each** (cumulatively XL; never a blocker for A/B) | new cache types (conv/ssm state) touch the Cache interface + serving slots; each is a real port with its own goldens |
| **4** | Tooling: **`mlx-bun port <hf-repo>`** — download smallest snapshot → descriptor coverage check (config keys + weight-audit dry run) → auto-regen goldens vs oracle venv → run parity gate → print verdict + manifest entry. Optionally: generalize `gen-model.ts` to emit from UniversalDense for graduation | turns "new arch" into a ~1-command, ~1-hour operation; makes the coverage claim self-verifying | **M** (scaffold) + **L** (generator generalization, optional) | oracle-venv coupling (mlx-lm version drift changes goldens — pin + record versions in parity.json, already the pattern) |

Sequencing note: Phase 1's descriptor table should be *born* with only the
12 launch archs actually gated green — adding an arch without its manifest
goldens is the one anti-pattern this design forbids.

## 5. Top design decisions (summary)

1. **Explicit descriptor table keyed by model_type (+ vendored
   MODEL_REMAPPING), not config sniffing** — support is a declared,
   testable surface; fingerprints remain a generated-dispatch guard only.
2. **One normalized config** — extend the existing `TextConfig` (it's
   already 70% there) with the bucket-A delta union; move per-arch quirks
   out of `loadModelConfig`'s if-chain into descriptor `configAliases`.
3. **L1 bit-exact is the gate for generic too** — manifest-driven golden
   harness (explicit ids, raw per-step logits, same-GPU), one regen script
   + one test file for all generic archs.
4. **Weight audit at load** — unconsumed/missing tensors are a load error,
   never a silently-wrong model.
5. **Generic never shadows targeted; graduation never deletes generic** —
   the dispatch ladder is dedicated → generated → generic → reject, and the
   generic path is the permanent correctness fallback.
6. **Honest tiering in UX** — `mlx-bun models` shows `targeted` vs
   `generic` (and RAM fit), which doubles as the graduation worklist.
