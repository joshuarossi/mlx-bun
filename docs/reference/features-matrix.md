# Features matrix — everything mlx-bun serves, in one table

The complete option inventory: every serving feature, its default, which
execution lane it runs on, which fidelity tier verifies it, and its knob.
This is the *what-exists* view; per-flag detail lives in
[server-config.md](server-config.md), wire formats in
[server-api.md](server-api.md), CLI verbs in [cli.md](cli.md).

**Lanes:** `serial` = the default single-queue path; `batch` = the
`--batch N` continuous-batching engine (bf16 compat mode, mlx-lm B=N
parity). **Tiers:** L1 = bit-exact vs mlx-lm · L2 = bit-exact vs mlx-optiq
· L3 = no external oracle, gated by envelope/KL/validity (see
[server-config.md → Fidelity tiers](server-config.md#fidelity-tiers-and-the-decode-route---l1----l2----l3)).

## Serving & performance

| Feature | Default | Lane | Tier | Knob |
| --- | --- | --- | --- | --- |
| OpenAI chat completions (`/v1/chat/completions`, SSE) | on | both | — | — |
| Raw text completions (`/v1/completions`) | on | both | — | — |
| Anthropic Messages (`/v1/messages`) | on | both | — | — |
| OpenAI Responses shim (`/v1/responses`) | on | both | — | — |
| Continuous batching (mlx-lm B=N parity) | **off** (serial) | batch | L1 | `--batch <n>` |
| Prompt cache (prefix KV reuse) | on, 2 GB | serial | — | `--prompt-cache <GB>` (0 = off) |
| **SSD KV cold tier** (cache survives eviction + restarts) | off | serial | — | `--ssd-cache <dir>` (+ `-max`, `-verify`) |
| Mixed-precision KV (`kv_config.json`, optiq default) | **on** when the model ships one | serial | L2 | `--kv-quant config\|off\|4\|8` |
| Compiled decode (bit-exact graph replay) | on, every tier | serial | L1/L2 | `--compiled-decode on\|off` |
| Fused SDPA (optiq-exact quantized-KV attention) | on (no-op on bf16) | serial | L2 | `--fused-sdpa on\|off` |
| Flash perf-kernel (envelope-gated decode) | **off** | serial | L3 | `--l3` / `--perf-kernel on` |
| **Speculative decoding** (two-model, mlx-lm parity) | off | serial (forces all-serial) | L1 | `--draft-model <path\|query>`, `--num-draft-tokens` |
| Memory admission (refuse what can't fit; never GPU-OOM) | on (RAM × 0.75) | both | — | `--memory-budget <GB>` |
| Aggregate KV admission for batch rows (queue, don't OOM) | off | batch | — | `--kv-budget <GB>` |
| Expert offload (MoE cold experts on mmap) | off | serial | L3 | `--expert-offload` |
| Extend-join (O(1) batch admission) | on | batch | L1 (own oracle) | `MLX_BUN_BATCH_EXTEND=0` |
| Vectorized greedy batch sampling | on | batch | bit-equal A/B | `MLX_BUN_BATCH_VEC_SAMPLE=0` |

## Request features

| Feature | Default | Lane | Tier | Knob |
| --- | --- | --- | --- | --- |
| **Structured output** (`response_format` json_object/json_schema) | on | both | L2 (oMLX) | request field; `MLX_BUN_GRAMMAR=0` kills |
| `guided_grammar` (EBNF) / `guided_regex`¹ / `guided_choice` / `structured_outputs` | on | both | L2 | request fields |
| Structured output × speculative decoding | on (when both active) | serial | L3 (validity+equivalence) | — |
| Tool calling (Gemma sentinel / CPM+Qwen XML) + `role:"tool"` loops | on | both | — | request `tools` |
| Vision (`image_url` parts; PNG/JPEG/HEIC/AVIF/WebP/TIFF/GIF/BMP) | on (models with a tower) | serial | L1/L2 | — |
| LoRA adapters (mount at start / hot-swap at runtime) | off | serial | — | `--adapter <dir>`, `POST /v1/adapters` |
| Sampling: temperature / top-p / top-k / min-p / XTC / logit_bias / presence+frequency+repetition penalties | per-request | both | L1 (mlx-lm-faithful) | request fields / server defaults |
| `logprobs` / `top_logprobs` (mlx-lm semantics) | off | serial | L1 | request fields |
| Fixed `seed` reproducibility | off | serial (routes solo) | — | request field |
| Thinking-mode control (hybrid-reasoning models) | model default | both | — | `--thinking`, `chat_template_kwargs` |
| Stop sequences / streaming / usage accounting | on | both | — | request fields |
| HLG tone-curve sampling | off | serial | L3 | `--hlg-sampling on` |
| Spec-decode telemetry (`usage.speculation`) | on with a draft | serial | — | — |

## Model coverage (per-model validated cells — no generic path is trusted untested)

| Family | Serial | Batch | Notes |
| --- | --- | --- | --- |
| MiniCPM5 (cpm5) | ✅ L1/L2 | ✅ | the starter model |
| Gemma 4 (1B/e4b/12B/26B, + vision e4b/12B) | ✅ L1/L2 | ✅ | sliding+full interleaved; MoE 26B |
| Qwen3.5 (gated-DeltaNet hybrid) | ✅ L1 | ✅ (SSM path) | `MLX_BUN_BATCH_SSM=0` reverts |
| DiffusionGemma-26B (non-autoregressive) | ✅ (own engine) | — serial always | first bit-exact non-AR port |
| Tier-0 universal (llama/qwen2/qwen3/olmo2/…, 11 archs) | ✅ L1 | ✅ plain full-attention archs² | gemma2-family/sliding universal → serial |

## Beyond serving (the same binary)

Training (`mlx-bun train`: ORPO/DPO/SFT, flash-CCE, segmented backward) ·
quantization (`convert`, `fuse`, `--target-bpw`) · embeddings · local
memory/wiki (`mlx-bun memory`) · pi agent integration (`mlx-bun pi`) ·
model registry + `fit` planner + `gc` · HF `upload`. See
[cli.md](cli.md) and the per-topic reference docs.

---
¹ `guided_regex` accepts the regex∩EBNF subset today (no `\d`/anchors — those degrade to prompt injection); real regex support is tracked.
² Gated token-exact vs mlx-lm B=2 (static + dynamic join/leave) on Llama-3.2-3B.

Composition rules and exclusions (what combines with what):
[server-config.md → Compatibility matrix](server-config.md#compatibility-matrix).
Performance per mode: `scripts/bench-modes.ts` (TTFT / prefill / decode /
peak-memory across every cell above); feature-composition perf:
`scripts/bench-feature-matrix.ts`.
