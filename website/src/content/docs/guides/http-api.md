---
title: The HTTP API
description: Chat completions, tools, vision, prompt caching, LoRA, mixed-precision KV, and the Anthropic and Responses protocols.
---

`mlx-bun serve` exposes an **OpenAI-compatible** API. Anything that speaks the
OpenAI protocol can point at it — the OpenAI SDK
(`baseURL: "http://localhost:8080/v1"`, any non-empty `apiKey`), or agent CLIs
via their provider config.

For exhaustive request/response schemas see the
[Server API reference](/reference/server-api/); for start flags and the
`--batch` matrix see [Server configuration](/reference/server-config/).
Coming from `mlx_lm.server`? See [Drop-in for mlx-lm](/guides/drop-in-mlx-lm/).

## Chat completions

**`POST /v1/chat/completions`** — streaming (SSE) and non-streaming. Supports
`temperature`, `top_p`, `top_k`, `max_tokens`, `seed`, `repetition_penalty`,
and `stop` (string or array, matched on decoded text with streaming hold-back).
Omitted sampling fields default to the model's own `generation_config.json`
recipe; usage includes `cached_tokens`.

The server serves the one model it was started with — the request's `model`
field is ignored, and the loaded model id is echoed back in responses.

## Tool calling

Pass OpenAI `tools`; each family's native format is parsed into `tool_calls`
JSON with `finish_reason: "tool_calls"`:

- **Gemma 4** — `<|tool_call>` sentinel tokens.
- **MiniCPM5** — `<function name=…>` XML with schema-aware argument decoding.

`role: "tool"` round-trips, including multi-turn agent loops.

## Vision

`image_url` content parts (data: URLs or http/s) on models with the vision
sidecar. PNG, JPEG, HEIC, AVIF, WebP, TIFF, GIF, and BMP are decoded via native
OS codecs, EXIF auto-orientation included.

## Prompt caching

A byte-capped LRU KV cache reuses the longest common token prefix across
requests — multi-turn conversations re-prefill only the new turn. Automatic, no
client changes. Entries are adapter-specific when LoRA adapters are in play.

## LoRA hot-swap

Mount adapters at startup (`--adapter <dir>`) or at runtime
(`POST /v1/adapters`), and select per request with the `adapter` body field
(`"id"`, stacked `"a+b"`, or `"none"`). The base model never reloads; an
unselected adapter costs nothing.

## Mixed-precision KV

When the model repo ships `kv_config.json` (every Gemma-4 OptiQ repo does),
per-layer KV quantization applies automatically — full-attention layers
quantized, sliding layers kept bf16. Measured decode-neutral at 8k on the 12B,
with KV bytes ÷4 on the quantized layers.

- `--kv-quant off` forces bf16; `--kv-quant 4|8` forces uniform bits
  (default `--kv-quant config` follows the model's `kv_config.json`).
- Long prefills over quantized caches run a fused FlashAttention-2 tiling that
  never materializes the full scores matrix (`MLX_BUN_NO_FUSED_SDPA=1` to
  disable).

## Memory admission control

`--memory-budget <GB>` refuses to load a model that can't serve within the
budget, and rejects requests whose `prompt + max_tokens` exceed the budget's max
safe context with a `400` (`type: "memory_admission"`) **before** generating.
The GPU out-of-memory crash it prevents is uncatchable by design — rejecting up
front is the only defense. The ceiling is visible at `GET /stats`.

## Other protocols

- **Anthropic Messages** — `POST /v1/messages` (on by default). Point any
  Anthropic-SDK tool at the server
  (`ANTHROPIC_BASE_URL=http://localhost:8080`); Claude Code runs against it as a
  fully local backend. Streaming event grammar, native tool_use/tool_result
  mapping, image blocks via the vision path.
- **OpenAI Responses** — `POST /v1/responses`, the protocol Codex/Cursor/Continue
  speak; `previous_response_id` resumption backed by a TTL + byte-capped store.
- **OpenAI completions** *(v0.0.9)* — `POST /v1/completions`, the legacy raw
  text-completion protocol (what `mlx_lm.server` clients also speak).
- **OpenAI Embeddings** *(v0.0.9)* — `POST /v1/embeddings` when the served
  model is an embedding model: last-token pooled, L2-normalized vectors,
  bit-exact vs mlx-lm.

*(v0.0.9)* Chat and raw completions also support `logprobs` /
`top_logprobs`, matching `mlx_lm.server`.

## Status & introspection

- **`GET /v1/models`** — the loaded model.
- **`GET /stats`** — cache hit rates, bytes, active KV scheme, response store,
  the admission-control ceiling.
- **`GET/POST/DELETE /v1/adapters`** — manage LoRA adapters;
  `GET /v1/adapters/available` discovers on-disk ones.
- **`GET /fit`** — the deterministic memory contract for the loaded model.
- **`GET /library`** — every downloaded model with capabilities and tiers.
- **`GET /downloads`** — progress of in-flight downloads.
- **`GET /health`** *(v0.0.9)* — liveness probe.
- **`GET /`** — the status page; the browser chat UI lives at `/chat`.
