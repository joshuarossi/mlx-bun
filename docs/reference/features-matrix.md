# Features matrix — everything mlx-bun serves, in one table

The complete option inventory: every serving feature, its default, which
execution lane it runs on, which fidelity tier verifies it, and its knob.
This is the *what-exists* view; per-flag detail lives in
[server-config.md](server-config.md), wire formats in
[server-api.md](server-api.md), CLI verbs in [cli.md](cli.md).

**Lanes:** `serial` = the default single-queue path; `batch` = the
`--batch N` continuous-batching engine (bf16 compat mode, mlx-lm B=N
parity). **Tiers:** L1 = bit-exact vs mlx-lm · L2 = bit-exact vs mlx-optiq
· Lab = no external oracle; KL/eval-gated experiments (see
[server-config.md → Fidelity tiers](server-config.md#fidelity-tiers-and-the-decode-route---l1----l2)).

## Serving & performance

| Feature | Default | Lane | Tier | Knob |
| --- | --- | --- | --- | --- |
| OpenAI chat completions (`/v1/chat/completions`, SSE) | on | both | — | — |
| Raw text completions (`/v1/completions`) | on | both | — | — |
| Anthropic Messages (`/v1/messages`) | on | both | — | — |
| OpenAI Responses shim (`/v1/responses`) | on | both | — | — |
| Continuous batching (mlx-lm parity at the same B) | **on** — cap 8 (default flipped 2026-07-05; a lone admitted request uses the gated B=1 fast path and concurrent requests can form B=N; `--batch 1` pins the strict serial executor) | batch | L1 | `--batch <n>` |
| Prompt cache (prefix KV reuse) | on, 8 GB | both | — | `--prompt-cache <GB>` (0 = off) |
| **SSD KV cold tier** (cache survives eviction + restarts; v3 includes GLM compressed MLA/DSA state without full-K/V reconstruction) | off | both | — | `--ssd-cache <dir>` (+ `-max`, `-verify`, `-demote-idle <sec>` — default 300s once `--ssd-cache` is on, `0` disables) |
| **Runtime isolation** (engine runs as a crash-isolated CHILD process behind a reverse-proxy parent; UI stays instant under GPU load and survives engine crashes — [runtime-isolation.md](../design/runtime-isolation.md)) | off | both | — | `--isolate` |
| **Model pool** (with `--isolate`: LRU-capped RESIDENT model engines; over the cap the least-recently-used engine demotes its cache to the SSD tier and exits, respawning on the next request) | 1 resident engine | both | — | `--model-pool <n>` (requires `--isolate`) |
| Mixed-precision KV (`kv_config.json`, optiq's scheme) | **off** — opt-in (default flipped to bf16 2026-07-05; quantized KV trades 5–20% decode for memory headroom) | serial + **batch** (per-layer configs batch on every shipped model — full-attention layers Phase 3.1, rotating layers milestone 2; uniform bits stay serial) | L2 | `--kv-quant config\|off\|4\|8`, `--l2` |
| **TurboQuant KV** (rotation-based: affine keys + FWHT/Lloyd-Max values) | off — opt-in ([turboquant-kv.md](../design/turboquant-kv.md); v1 dequantize-on-fetch, full-attention layers only, no speed claim) | serial only (solo-only, unconditionally) | Lab (codec is oracle-backed vs vllm-metal; the cache class is unvalidated) | `--kv-quant turbo[:k<bits>v<bits>]` (default `k8v3`) |
| Compiled decode (bit-exact graph replay) | on, every tier | serial | L1/L2 | `--compiled-decode on\|off` |
| Compiled activations (faithful geglu/swiglu — mlx-lm's `@mx.compile`) | **on**, every tier | both | L1 | `--compiled-activations on\|off` |
| Fused SDPA (optiq-exact quantized-KV attention) | follows `--kv-quant`: on for `config`, off for uniform/bf16 | serial | L2 | `--fused-sdpa on\|off` |
| **Paged KV** (vLLM-style block pool: host-side block table + gather before the stock SDPA, no fused kernel in v1 — [paged-kv-cache.md](../design/paged-kv-cache.md)) | off | serial (pins `--batch 1` unless `--batch` given) | gated bit-exact vs the plain `KVCache` (`tests/paged-kv-parity.test.ts`) | `--paged-kv`, `--paged-kv-block-size <n>` (default 256) — v1 scope Gemma4-family bf16; refuses `--batch N>1`, `--kv-quant`, `--draft-model` |
| **Speculative decoding** (auto-detected drafter: two-model = mlx-lm parity/L1, Gemma `-assistant` = optiq/L2, DSpark local = Lab, DeepSpec released = DeepSpec-reference oracle) | off | serial (forces all-serial) | per-drafter oracle | `--draft-model <path\|query>`, `--draft-kind`, `--num-draft-tokens` |
| **GLM-5.2 checkpoint-native MTP** (bounded auxiliary expert tier, exact verify) | **on** for GLM-5.2 | serial (`usage.lane: serial+spec`) | Colibri/oracle trajectory + synthetic HTTP gate | `--mtp on\|off` (`off` enables ordinary GLM batching) |
| Speculative decoding, **model-free prompt lookup** (drafts copied from the request's own context; port of prompt-lookup decoding / vLLM `ngram`; zero weights) | off | serial (forces all-serial) | lossless by verify (gated vs non-spec greedy, tests/spec-ngram.test.ts) | `--draft-kind ngram` (no `--draft-model`), `--ngram-max`, `--ngram-min`, `--num-draft-tokens` (default 10) |
| Memory admission (refuse what can't fit; never GPU-OOM) | on (RAM × 0.75) | both | — | `--memory-budget <GB>` |
| Aggregate KV admission for batch rows (queue, don't OOM) | off | batch | — | `--kv-budget <GB>` |
| Expert offload (MoE cold experts on mmap) | off | serial | Lab | `--expert-offload` |
| Extend-join (O(1) batch admission) | on | batch | L1 (own oracle) | `MLX_BUN_BATCH_EXTEND=0` |
| Vectorized greedy batch sampling | on | batch | bit-equal A/B | `MLX_BUN_BATCH_VEC_SAMPLE=0` |

## Request features

| Feature | Default | Lane | Tier | Knob |
| --- | --- | --- | --- | --- |
| **Structured output** (`response_format` json_object/json_schema) | on | both | L2 (oMLX) | request field; `MLX_BUN_GRAMMAR=0` kills |
| Structured output **jump-forward** (grammar-forced spans emitted without per-token forwards; SGLang technique via xgrammar) | **off** | serial only | Lab (string-lossless + validity gates, tests/grammar-jump.test.ts; token stream may differ — no oracle) | `MLX_BUN_GRAMMAR_JUMP=1` |
| `guided_grammar` (EBNF) / `guided_regex`¹ / `guided_choice` / `structured_outputs` | on | both | L2 | request fields |
| Structured output × speculative decoding | on (when both active) | serial | Lab (validity+equivalence) | — |
| Quantized KV × speculative decoding (any axis: uniform / config / turbo) | KV scheme wins — drafted requests decode serially WITHOUT speculation (spec lane is bf16-KV-only in v1; startup warning) | serial | — | omit `--kv-quant` to speculate |
| Tool calling (Gemma sentinel / CPM+Qwen XML / GLM `arg_key`+`arg_value`) + `role:"tool"` loops | on | both | — | request `tools` |
| Vision (`image_url` parts; PNG/JPEG/HEIC/AVIF/WebP/TIFF/GIF/BMP) | on (models with a tower); remote fetches refuse private/loopback/link-local hosts by default (SSRF guard) | serial | L1/L2 | `--allow-private-media` / `MLX_BUN_ALLOW_PRIVATE_MEDIA=1` re-permits LAN hosts |
| **Video input** (`video_url`/`video` parts; mp4/mov H.264/HEVC/ProRes/… via the AVFoundation sidecar `mlx-bun-frame-extract`; 2 fps sampling, ≤768 frames, 256 MB body cap; never combines with audio) | on (Qwen3.5-family models); same SSRF guard | serial | mlx-vlm oracle (frames pipeline bit-exact; tests/qwen38-vision.test.ts) | `--allow-private-media` for LAN hosts |
| **Audio input** (`input_audio`/`audio`/`audio_url` parts; WAV native, mp3/m4a/flac/ogg/aiff via CoreAudio; ≤30 s / 750 tokens per clip; mixes with images) | on (models with `audio_config` + sidecar tower: e4b); remote fetches refuse private/loopback/link-local hosts by default (SSRF guard) | serial³ | L2 (greedy stream EXACT vs the optiq internal model) | `--allow-private-media` / `MLX_BUN_ALLOW_PRIVATE_MEDIA=1` re-permits LAN hosts |
| LoRA adapters (mount at start / hot-swap at runtime) | off | serial | — | `--adapter <dir>`, `POST /v1/adapters` |
| Sampling: temperature / top-p / top-k / min-p / XTC / logit_bias / presence+frequency+repetition penalties | per-request | both | L1 (mlx-lm-faithful) | request fields / server defaults |
| `logprobs` / `top_logprobs` (mlx-lm semantics) | off | serial | L1 | request fields |
| Fixed `seed` reproducibility | off | serial (routes solo) | — | request field |
| Thinking-mode control (hybrid-reasoning models) | model default | both | — | `--thinking`, `chat_template_kwargs` |
| Stop sequences / streaming / usage accounting | on | both | — | request fields |
| HLG tone-curve sampling | off | serial | Lab | `--hlg-sampling on` |
| Spec-decode telemetry (`usage.speculation`) | on with a draft | serial | — | — |
| Per-turn lane telemetry (`usage.lane`: serial / serial+spec / batched) | on | both | — | — |

## Model coverage (per-model validated cells — no generic path is trusted untested)

| Family | Serial | Batch | Notes |
| --- | --- | --- | --- |
| MiniCPM5 (cpm5) | ✅ L1/L2 | ✅ | the starter model |
| Gemma 4 (1B/e4b/12B/26B, + vision e4b/12B, + audio e4b) | ✅ L1/L2 | ✅ | sliding+full interleaved; MoE 26B |
| Qwen3.5 (gated-DeltaNet hybrid) | ✅ L1/L2 | ✅ (SSM path) | `MLX_BUN_BATCH_SSM=0` reverts |
| Qwen3.8-27B (same qwen3_5 graph) | ✅ L1 (no L2 oracle) | ✅ (SSM path) | thinking depths + preserve_thinking; native MTP head mounts via `--draft-model` (DeltaNet spec rollback = snapshot/replay, lossless-gated; quiet-box A/B: 0.82× — correct but slower, opt-in); **vision (images) AND video SERVE** — bf16 tower sidecar + mRoPE + embed splice, oracle = mlx-vlm on pinned mlx (preprocessor/tower/positions bit-exact, e2e token-exact on 2/3 fixtures, serve smokes green; tests/qwen38-vision.test.ts); video files decode via the shipped AVFoundation sidecar (`mlx-bun-frame-extract`, src/native/frame_extract.swift — 2 fps, ≤768 frames, temporal pairs, per-frame-group attention) |
| GLM-5.2 / Colibri (pre-release port gate) | ✅ chat/text, Messages, Responses, SSE, tools, grammar, logprobs, library/CLI | ✅ compressed MLA/DSA scheduler | native MTP defaults to serial+spec; `--mtp off` enables ordinary batching; artifact-aware CLI/API/status `fit` and live main/MTP expert-tier telemetry; embeddings, vision/audio, adapters, and training are explicitly unsupported; per-row batched MTP is post-release |
| DiffusionGemma-26B (non-autoregressive) | ✅ (own engine) | — serial always | first bit-exact non-AR port |
| Tier-0 universal (llama/qwen2/qwen3/olmo2/…, 11 archs) | ✅ L1 | ✅ plain full-attention archs² | gemma2-family/sliding universal → serial |

## Beyond serving (the same binary)

Training (`mlx-bun train`: ORPO/DPO/SFT, flash-CCE, segmented backward) ·
quantization (`convert`, `fuse`, `--target-bpw`) · embeddings · local
memory/wiki (`mlx-bun memory`) · pi agent integration (`mlx-bun pi`) ·
model registry + `fit` planner + `gc` · HF `upload` · web chat Model Hub
(`/api/hub/local` + `/search` + `/download`, per-row `/fit` verdict;
`/api/hub/serve` is `restart_required`-only today — no in-process model-swap
seam reaches `/ws/chat`, see [server-api.md](server-api.md#model-hub-apihub))
· **PWA installability** (manifest + shell-only service worker —
installable, instant static-shell paint; explicitly not offline chat, see
[server-api.md](server-api.md#web-app-static-routes--pwa-installability)).
See [cli.md](cli.md) and the per-topic reference docs.

---
¹ `guided_regex` accepts the regex∩EBNF subset today (no `\d`/anchors — those degrade to prompt injection); real regex support is tracked.
² Gated token-exact vs mlx-lm B=2 (static + dynamic join/leave) on Llama-3.2-3B.
³ Audio is a capability neither ancestor SERVES: mlx-lm strips the audio tower at load and 400s non-text parts; optiq ships the full machinery but never wires it into its serve frontend — mlx-bun exposes it. Serial lane by design (embeddings prefill; batched audio has no oracle → novel-territory gates would apply), prompt cache skipped.

Composition rules and exclusions (what combines with what):
[server-config.md → Compatibility matrix](server-config.md#compatibility-matrix).
Performance per mode: `scripts/bench-matrix.ts modes` (TTFT / prefill / decode /
peak-memory across every cell above); feature-composition perf:
`scripts/bench-matrix.ts features`.
