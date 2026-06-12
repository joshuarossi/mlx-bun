# Handoff: the sub-GB starter model port (publishing gate 1)

*2026-06-12. Goal: a runnable sub-gigabyte model so first run is
chatting in ~1 minute (PLAN Phase 16 starter item; publishing gate).
This document is the complete implementation plan. Read PLAN.md's
"Reference environment" + Phase 14 first. Written from live
inspection of the actual model configs (HF API) and our porting
infrastructure — every claim below was verified, not remembered.*

---

## 0. CRITICAL DISCOVERY — read before starting

**Qwen3.5-0.8B is NOT a vanilla transformer.** Its config
(`model_type: qwen3_5_text`, fetched 2026-06-12) reveals the
qwen3-next hybrid lineage:

- **24 layers: 18 `linear_attention` + 6 `full_attention`**
  (`full_attention_interval: 4`). The linear layers are **gated
  DeltaNet**: causal conv (kernel 4), 16 key heads × 128, 16 value
  heads × 128, recurrent state in **float32** (`mamba_ssm_dtype`).
- Full-attention layers: 8 heads / 2 KV heads, head_dim 256,
  **partial rotary 0.25**, **interleaved MRoPE** (sections
  [11,11,10]), theta 1e7, **`attn_output_gate: true`**.
- `tie_word_embeddings`, vocab 248,320 (embeddings quantized 8-bit),
  hidden 1024; bundled `mtp.safetensors` (1-layer MTP head) and a
  201 MB `optiq_vision.safetensors` sidecar; per-tensor mixed quant
  (some projections 8-bit).

This is a **major port**: a DeltaNet recurrence + conv-state cache is
a new cache *kind*, a new prefill strategy, and new numerics
(float32 state) — none of which our Gemma-shaped pipeline has.

**MiniCPM5-1B-OptiQ-4bit, by contrast, is textbook `llama`**
(config verified the same way): 24 layers, plain GQA 16/2 heads,
head_dim 128, standard RoPE theta 5e6 with **no scaling**, SiLU MLP,
RMSNorm, untied embeddings, vocab 130,560, 0.92 GB. Every mechanism
it needs already exists in our gemma4 port (GQA attention, RoPE,
RMSNorm, quantized linear) — minus Gemma's quirks (no sliding
windows, no softcapping, no per-layer embeds, no QK-norm... verify
QK-norm against the oracle, llama has none).

**Recommendation: split the work.**
- **Track A (the publishing gate): port MiniCPM5-1B.** Days, not
  weeks. Capability is respectable (52% MMLU, 30.28 OptiQ score —
  Josh's screenshot from the OptiQ site) and the starter's job is
  tour-guide + fast first impression.
- **Track B (Phase 14 proper, after publishing): port Qwen3.5.**
  It is the MTP home and a flagship family — it deserves the real
  multi-week effort, not a deadline squeeze.

Josh decides; both tracks are specified below. The shared recipe
(§2) applies to either.

---

## 1. Machine + reference environment logistics

- **The oracle lives on the M4 Pro dev machine** —
  `/Users/joshrossi/Code/mlx-lm/.venv` (mlx 0.31.2, mlx-lm 0.31.3,
  mlx-optiq 0.2.1). The M1 Max cloud box (where the 2026-06-12
  session ran) does NOT have it: `tests/paths.ts` →
  `ORACLE_PYTHON` resolves there only on the M4 Pro. **Do parity
  work on the M4 Pro**, or replicate the venv on the M1 Max first
  (pip install mlx==0.31.2 mlx-lm==0.31.3 mlx-optiq==0.2.1).
- Oracle source to read (M4 Pro, site-packages):
  - Track A: `mlx_lm/models/llama.py` (the reference llama graph).
  - Track B: `optiq/mlx_lm_patches/qwen3_5_text.py` (registered via
    optiq's MODEL_REMAPPING — see PLAN Phase 14), plus mlx-lm's
    `models/qwen3_next.py` for the gated-DeltaNet reference
    implementation, and `optiq/runtime/mtp/` (defer MTP, but its
    `trace_parity.py` encodes load-bearing invariants).
- Downloads (sub-GB, fine to do from a session):
  - `mlx-bun get mlx-community/MiniCPM5-1B-OptiQ-4bit` (0.92 GB)
  - `mlx-bun get mlx-community/Qwen3.5-0.8B-OptiQ-4bit` (0.89 GB)
  - Remember `HF_HUB_DISABLE_XET=1` applies to *python* tooling only;
    our downloader speaks plain HTTPS already.
- Goldens are **machine-specific** (`goldenOutDir()`: flat reference
  set on the M4 Pro, `goldens/<machine-key>/` elsewhere — logit
  goldens are bit-exact only on the GPU that produced them).

---

## 2. The shared porting recipe (how gemma4 was done — follow it)

Every step below exists for gemma4; the port is "do the same for the
new family." File references verified 2026-06-12.

### Step 2.1 — Config loading (`src/config.ts`)
`loadModelConfig()` currently normalizes gemma4's config.json into
`ModelConfig` (nested `text` block: layerTypes, heads, dims, rope,
quant overrides). Add a per-family branch keyed on `model_type`:
- llama (MiniCPM5): flat config — map hidden_size, heads/kv-heads,
  head_dim, intermediate, rms eps, rope theta, vocab, tie flag,
  num_hidden_layers, layerTypes = all "full_attention".
- qwen3_5: `text_config` nesting; layer_types as shipped
  (linear_attention/full_attention); linear_* dims; mrope params;
  partial_rotary_factor; attn_output_gate; mamba dtype.
- Keep `quantization` parsing (per-tensor overrides like
  `embed_tokens: {bits: 8}` — qwen uses them heavily; check
  `quantFor()` already resolves path-keyed overrides).
- **`modelType` drives everything downstream** — registry already
  stores it (that's how the CLI's `startsWith("gemma4")` filter
  works).

### Step 2.2 — Model graph (`src/model/<family>.ts`)
Pattern from `gemma4.ts`/`gemma4-base.ts`: the base file holds
config-independent machinery (QuantizedLinear/QuantizedEmbedding
loaders, KVCache/RotatingKVCache, RMSNorm, rope helpers) — REUSE it.
A new family file defines Attention/MLP/Layer/Model classes that
`Weights.open()` feeds by tensor path. Key contract points:
- `makeCache()` returns the per-layer cache array `generate()`
  threads through.
- `forwardLayers()` shape must match what compiled-decode segments
  expect — but **do NOT wire compiled-decode/fused kernels for the
  new family initially**: `generate()` gates them; ship the naive
  path first, parity gates every optimization later (that is the
  testing-strategy contract).
- Weight path prefixes differ per family (llama:
  `model.layers.N....`; qwen3_5: `language_model.model.layers...` —
  verify against `model.safetensors.index.json`).

### Step 2.3 — Factory (`src/model/factory.ts`)
`createModel()` currently returns `Gemma4Model` (generated
specializations subclass it). Introduce a `Model` interface (the
methods server/generate actually use: forward, makeCache, config,
weightsBytes, dispose...) and dispatch on `config.modelType`. The
generated-specialization map stays gemma-only.

### Step 2.4 — Tokenizer + chat template
- `src/tokenizer.ts` uses @huggingface/tokenizers over
  `tokenizer.json` — both models ship one (qwen's is 20 MB; load
  time worth checking). Verify BOS/EOS handling: qwen3_5
  eos 248044; MiniCPM5 bos 0 / eos in generation_config.
- `src/chat-template.ts` renders `chat_template.jinja` via
  @huggingface/jinja — qwen ships chat_template.jinja (7.8 KB;
  includes `enable_thinking`-style hybrid switches — render with
  thinking OFF for the starter; MiniCPM5's template TBD from its
  tokenizer_config).
- Tool-call grammar: gemma's `parseToolCalls` markers are
  family-specific (`src/tool-call.ts`). Qwen uses hermes-style
  `<tool_call>` JSON; MiniCPM5 TBD. Starter can ship text-only chat
  first; the pi session needs tool calls to be USEFUL, so budget it.

### Step 2.5 — Parity harness (the correctness contract)
Mirror `scripts/regen-parity-goldens.ts` + `tests/parity.test.ts`
for the new family (paths in `tests/paths.ts` — add SNAPSHOT_<fam>):
- **Tier a (bit-exact ids)**: oracle generates 100 greedy tokens +
  per-step argmax + full last-position logits for the first N steps
  (f32 .bin). Our side must match token-for-token, logits within
  the established tolerance, on the same GPU.
- Oracle command shape: the venv python with mlx-lm generate (Track
  A) or optiq's patched loader (Track B — needs
  `optiq.mlx_lm_patches` import side effects; read how their CLI
  registers MODEL_REMAPPING and replicate in the regen script).
- Then the e2e suite: prefill masks (L>1), decode loop, KV-quant
  tiers (Track A can reuse kv-quant goldens pattern; Track B's
  linear layers have NO KV — see §4.3).
- Suite must stay green throughout: `bun test` (157+ tests).

### Step 2.6 — Integration sweep (easy to forget — grep targets)
All the places hardcoding the gemma4 family, verified present today:
1. `src/cli.ts` — THREE `modelType.startsWith("gemma4")` filters
   (resolveModelAuto ×2 paths + ls capability column) → a shared
   `SUPPORTED_FAMILIES` predicate in one place.
2. `src/cli.ts` starter constant: `starterRepo =
   ".../gemma-4-e4b-it-OptiQ-4bit"` → the new sub-GB repo.
3. `src/fit.ts` `recommendedRepoId()` — tiers stay Gemma (the
   starter is not the recommendation), but the starter download in
   resolveModelAuto switches.
4. **`src/fit.ts` `kvGeometry()` assumes gemma layer types**
   (`sliding_attention` / full): llama = all-full (works via the
   full branch — verify window handling degrades correctly);
   qwen3_5 `linear_attention` layers have constant-size state, not
   token-proportional KV — fit's KV-growth math needs a family
   branch or the 0.8B's max-safe-context will be nonsense.
5. `src/server.ts` /stats KV accounting + /library `supported`
   flag + the registry `paramCount` parse (works off safetensors
   headers — verify for the new index layout).
6. Status page + README copy that says "Gemma".
7. Vision sidecar guard: qwen's `optiq_vision.safetensors` must NOT
   be loaded (registry already separates sidecarBytes; confirm the
   loader skips non-gemma sidecars rather than erroring).

### Step 2.7 — Starter-flow wiring + docs-grounded tour guide
- Swap `starterRepo` (§2.6.2) and keep the background-download of
  the recommended Gemma.
- The "tour guide" system prompt (PRODUCT_ROADMAP first-run UX):
  preload README/server-api/pi docs into the starter's system
  prompt so a ~1B model answers mlx-bun questions grounded instead
  of hallucinating. Suggested: a `docs/tour-guide.md` baked via
  text import, used as default system prompt ONLY for the starter
  model + surfaced in the chat UI's system field.
- E2E: fresh-machine simulation (`HOME=$(mktemp -d)` breaks
  keychain/HF paths — instead point `cacheDir`/registry at a temp
  hub via env or test flags; the downloadModel `cacheDir` option
  already exists).

---

## 3. Track A step-by-step: MiniCPM5-1B (`llama`) — the gate

Estimated: 2–4 focused sessions. Order matters; each step has a gate.

1. **Download + inspect** (30 min): `mlx-bun get
   mlx-community/MiniCPM5-1B-OptiQ-4bit`; dump
   `model.safetensors.index.json` tensor names; diff against
   mlx-lm `llama.py` expectations; note quant per-tensor overrides
   in config. Gate: full tensor-name → module mapping written down.
2. **Oracle goldens first** (1–2 h, M4 Pro): extend
   regen-parity-goldens with `--model` + plain mlx-lm loader; run
   against MiniCPM5; commit goldens. Doing this FIRST means every
   subsequent step has a target. Gate: oracle generates coherent
   text (also validates the artifact itself).
3. **Config branch** (§2.1) + **weights mapping**: llama branch in
   loadModelConfig; confirm `Weights.open` mmaps the single 650 MB
   shard fine. Gate: registry `scan` shows correct params/quant.
4. **Model graph** (`src/model/llama.ts`): embed → N×(RMSNorm →
   GQA attn (RoPE theta from config) → residual → RMSNorm → SiLU
   MLP → residual) → final norm → lm_head (untied). Reuse
   QuantizedLinear/KVCache/rope from gemma4-base — llama needs the
   non-Gemma variants (no embed scaling, no softcap, no QK-norm,
   no pre/post-feedforward norms — READ the oracle line by line;
   Gemma habits are the bug farm here). Gate: tier-a parity, 100/100
   greedy ids + logit tolerance.
5. **Factory interface** (§2.3) + integration sweep (§2.6). Gate:
   full suite green; `mlx-bun serve minicpm` chats coherently;
   `/chat` works; fit/library/status pages sane.
6. **Tool calls + template** (§2.4): render template with tools,
   implement the family's tool-call markers in tool-call.ts, e2e
   via the existing server-tools test pattern. Gate: pi session
   round-trips one read/bash tool call on the starter.
7. **Starter wiring** (§2.7) + benchmark rows (`mlx-bun benchmark
   minicpm`) + fresh-machine e2e. Gate: cold start → chatting
   under ~2 min on decent broadband, big model streaming behind.
8. **Ship gate**: PLAN updated, suite green, both testers' machines
   happy → publish.

---

## 4. Track B step-by-step: Qwen3.5-0.8B (`qwen3_5`) — Phase 14 proper

Estimated: 2+ weeks calibrated against the gemma port. The order
isolates the novel machinery so parity bisects cleanly.

1. **Read the oracle deeply** (M4 Pro): optiq's `qwen3_5_text.py` +
   mlx-lm `qwen3_next.py`. Write a NOTES file mapping every module:
   in_proj_qkv/in_proj_ba, causal conv1d, gated delta rule
   (decay a, beta b, state S update S = a·S + v·kᵀ, out = S·q —
   verify exact form from source, do NOT trust this sketch),
   norm-then-gate output path, full-attn blocks with partial
   rotary + interleaved MRoPE + output gate, shared input/output
   embeddings.
2. **Oracle goldens + per-layer fixtures**: beyond tier-a ids,
   dump PER-LAYER activations from the oracle for one short prompt
   (the gemma port's most valuable debugging tool — bisects which
   layer diverges). The optiq loader must be driven through their
   MODEL_REMAPPING registration.
3. **Config branch** (§2.1): text_config nesting, linear_* dims,
   mrope_section/interleaved, partial_rotary_factor 0.25,
   attn_output_gate, full_attention_interval, mamba_ssm_dtype.
4. **New cache kind** (`src/kv-store.ts` + model file): linear-attn
   layers carry `(conv_state[K=4 window], S[float32 16×128×128])`
   per layer — constant size, no growth, no quantization, must
   survive `generate()`'s dispose/trim/cache-reuse contract
   (PromptCache stores caches by token prefix — linear state is
   prefix-dependent, so prefix reuse REMAINS VALID only on exact
   prefix; trimming is NOT possible → mark these caches
   non-trimmable and let PromptCache fall back to full re-prefill
   when a partial-prefix hit would require trim).
5. **DeltaNet prefill**: reference implements chunked scan in pure
   mlx ops — port that first (correctness), no custom kernels.
   float32 state in a bf16 graph: respect mamba_ssm_dtype or
   parity will drift.
6. **Full-attention blocks**: GQA 8/2 with head_dim 256, partial
   rotary (first 64 dims of 256), interleaved MRoPE sections
   [11,11,10] (text-only collapses to standard positions — verify
   how the oracle treats pure-text), attn_output_gate (sigmoid gate
   on attn output — read source), theta 1e7.
7. **Graph assembly + tier-a parity** (the long haul): per-layer
   fixture bisection. Numeric hot spots from the gemma experience:
   norm epsilon placement, residual dtype, rope sign/interleave,
   quantized-embedding dequant scaling.
8. **KV-quant for the 6 full layers** (kv_config.json ships in the
   repo), fit.ts geometry branch (linear state = constant bytes).
9. **Tokenizer/template/tools** (§2.4) — template has hybrid
   thinking switches; starter runs non-thinking
   (chat_template kwargs equivalent: `enable_thinking: false`).
10. **MTP (`mtp.safetensors`) — DEFER** to its own phase per PLAN
    14(b): start at optiq `runtime/mtp/trace_parity.py`. Greedy-MTP
    must be token-identical to greedy non-MTP by construction.
11. **Vision sidecar — DEFER** (Phase 12 bucket, third vision arch).
12. Integration sweep (§2.6), benchmark, starter wiring if Track B
    ends up being the starter after all.

---

## 5. Exit criteria (both tracks)

- Tier-a parity: 100 greedy ids bit-exact vs oracle + logit deltas
  within the established tolerance, committed goldens + regen
  script, runs in CI suite behind `snapshotAvailable()` guards.
- Full existing suite stays green at every commit (house rule).
- `mlx-bun benchmark <model>` rows recorded (decode + prefill +
  peak) on at least the M4 Pro and M1 Max.
- Fresh-machine first-run e2e: starter chatting, recommended model
  background-streaming, status page sane, pi tool round-trip.
- PLAN.md updated with findings (negative results included — e.g.
  any oracle deviations discovered, like the Phase 11 ones).

## 6. Open questions for Josh

1. **Track A vs B for the gate** — recommendation is A
   (MiniCPM5) for publishing speed; B proceeds afterward as Phase
   14 on its own clock. Decide before work starts.
2. MiniCPM5's hybrid `<think>` mode (the OptiQ page's
   `enable_thinking` note): starter ships non-thinking — confirm.
3. Should the starter stay on disk as the permanent "fallback +
   tour guide" (current plan) or be deleted once the big model
   lands? (Current code keeps it; ~1 GB.)
4. Publishing mechanics can proceed in parallel with the port
   (npm `files` allowlist, un-`private` the package, repo
   visibility decision for the native pack) — green-light?
