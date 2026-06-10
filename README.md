# mlx-bun

Native MLX inference for Bun. Run quantized LLMs on Apple Silicon from
TypeScript — no Python, no sidecar server, one runtime.

Measured on an M4 Pro (24 GB): decode within 3% of mlx-lm (24.9 vs 25.7
tok/s on Gemma-4 12B 4-bit), prefill at parity, logits **bit-exact**
against the Python reference, and cold start → first token of a cached
prompt in **394 ms**.

## Quickstart

**You need:** an Apple Silicon Mac (MLX is Metal-only, so macOS only by
design), [Bun](https://bun.sh) ≥ 1.3.14, and
[Homebrew](https://brew.sh).

**1. Install the MLX C library and the repo:**

```sh
brew install mlx-c          # installs libmlxc.dylib + libmlx
git clone <this repo> && cd mlx-bun
bun install
```

**2. Get a model.** mlx-bun loads models from your Hugging Face cache.
Until the built-in downloader lands (on the roadmap), fetch one with the
HF CLI (`pip install -U "huggingface_hub[cli]"` — yes, Python downloads
the weights for now; it never runs them):

```sh
hf download mlx-community/gemma-4-e4b-it-OptiQ-4bit
```

> Download stalling? Try `HF_HUB_DISABLE_XET=1 hf download ...` — Xet
> transfers misbehave on some networks.

**3. Index your cache and serve:**

```sh
bun src/cli.ts scan                # index the HF cache into the registry
bun src/cli.ts serve e4b           # fuzzy-matches the model; default port 8090
```

**4. Talk to it** (OpenAI-compatible API — any OpenAI client works):

```sh
curl http://localhost:8090/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 128, "temperature": 0.7
  }'
```

That's it. The server serves the one model it was started with (the
request's `model` field is ignored and the loaded model id is echoed
back in responses).

## Supported models

Scope is deliberate: a few model families held to **bit-exact** logit
parity with the Python reference, rather than dozens held to none.
Currently the Gemma-4 OptiQ quants:

| Model | Download | Fits on | Vision | Notes |
|---|---|---|---|---|
| [`mlx-community/gemma-4-e4b-it-OptiQ-4bit`](https://huggingface.co/mlx-community/gemma-4-e4b-it-OptiQ-4bit) | 7.0 GB | 16 GB | — | Fastest (~52 tok/s); good first model |
| [`mlx-community/gemma-4-12B-it-OptiQ-4bit`](https://huggingface.co/mlx-community/gemma-4-12B-it-OptiQ-4bit) | 8.4 GB | 16 GB | ✓ | Vision sidecar + tool calling, both verified end-to-end |
| [`mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit`](https://huggingface.co/mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit) | 18 GB | 24 GB | — | MoE (top-8 of 128 experts); ~32 tok/s |

Not sure what fits your machine? `bun src/cli.ts fit <model> --ctx 8192`
gives a deterministic answer (see below). Qwen 3.x is next on the
roadmap (see [PLAN.md](./PLAN.md)).

## Why

MLX is Apple's ML framework: hand-tuned Metal kernels for Apple Silicon,
with official bindings for Python, C++, Swift, and C — but no JavaScript
story. Today, a JS/TS app that wants local MLX inference must shell out to
a Python server (mlx-lm, optiq) and accept that stack's fragility: venv
setup, brittle download tooling, segfaults on exit, monkey-patched HTTP
layers.

The performance-critical work — every matmul, every attention pass — lives
in MLX's C++/Metal core and is exposed through `mlx-c`. The Python layer on
top is pure orchestration: model loading, tokenization, the sampling loop,
serving. That layer is performance-neutral (the GPU dominates), so it can
be rewritten in any runtime without losing speed — and Bun is the right
one:

- **`bun:ffi`** — lowest-overhead FFI of any JS runtime; binds `mlx-c`
  directly, no node-gyp, no binding compilation.
- **Lazy native weight loading** — mlx's loader materializes tensors on
  first use; opening an 8.9 GB model takes milliseconds, and warm
  restarts are near-instant on cached pages.
- **`Bun.Image`** — native OS image codecs (HEIC, AVIF, WebP, JPEG, …)
  for the vision path, EXIF auto-orientation included.
- **`bun:sqlite`** — built-in storage for the model registry and eval DB.
- **One binary, one toolchain** — runtime, package manager, test runner.

## CLI

```sh
bun src/cli.ts scan                 # index your HF cache into the registry
bun src/cli.ts ls                   # list models (size, params, quant, capabilities)
bun src/cli.ts ls --vision --max-size 10GB
bun src/cli.ts fit gemma --ctx 32768          # memory contract: fits? max context? predicted tok/s
bun src/cli.ts fit gemma --ctx 8192 --skus    # ...same, across the Apple Silicon lineup
bun src/cli.ts serve gemma --port 8090        # OpenAI-compatible server
bun src/cli.ts evals                # recorded benchmark runs
```

Model arguments are substring queries against the registry (`e4b`,
`26B`, `12B-it`); a query matching more than one model errors out
listing the candidates — just make it more specific.

`fit` is deterministic, not vibes: weights bytes from safetensors
headers, KV bytes/token from the config (sliding-window layers capped,
MoE active-expert bytes for decode), calibrated prefill transient, and
the machine's wired-memory ceiling. Predictions are recorded next to
measured peaks in the eval DB.

## HTTP API

`serve` exposes an OpenAI-compatible API. Anything that speaks the
OpenAI protocol can point at it — the OpenAI SDK
(`baseURL: "http://localhost:8090/v1"`, any non-empty `apiKey`), or
agent CLIs like pi/OpenClaw via their provider config.

- **`POST /v1/chat/completions`** — streaming (SSE) and non-streaming;
  `temperature`, `top_p`, `max_tokens`, `seed`, `stop`; usage includes
  `cached_tokens`.
- **Tool calling** — pass OpenAI `tools`; the model's native
  `<|tool_call>` markers are parsed into `tool_calls` JSON with
  `finish_reason: "tool_calls"`; `role: "tool"` round-trips.
- **Vision** — `image_url` content parts (data: URLs or http/s), on
  models with the vision sidecar. PNG, JPEG, HEIC, AVIF, WebP, TIFF,
  GIF, BMP via native OS codecs.
- **Prompt caching** — a byte-capped LRU KV cache reuses the longest
  common token prefix across requests (multi-turn conversations
  re-prefill only the new turn) — automatic, no client changes.
  Entries are adapter-specific when LoRA adapters are in play.
- **LoRA hot-swap** — mount adapters at startup (`--adapter id=dir`)
  or at runtime (`POST /v1/adapters`), select per request with the
  `adapter` body field (`"id"`, stacked `"a+b"`, or `"none"`). The
  base model never reloads; an unselected adapter costs nothing.
- **Mixed-precision KV** — when the model repo ships `kv_config.json`
  (every Gemma-4 OptiQ repo does), per-layer KV quantization applies
  automatically (full-attention layers; sliding layers stay bf16).
  Measured decode-neutral at 8k on the 12B with KV bytes ÷4 on the
  quantized layers. `--no-kv-quant` forces bf16; `--kv-bits N` forces
  uniform bits.
- **`GET /v1/models`**, **`GET /stats`** (cache hit rates, bytes,
  active KV scheme), **`GET/POST/DELETE /v1/adapters`**.

## Library

The server is one consumer of a library-first API. Not yet published to
npm — clone the repo and import from `src/` (a single-binary embeddable
build is on the roadmap):

```ts
import { loadModelConfig } from "./src/config";
import { Weights } from "./src/weights";
import { Gemma4Model } from "./src/model/gemma4";
import { generate } from "./src/generate";
import { loadTokenizer } from "./src/tokenizer";
import { ChatTemplate } from "./src/chat-template";

const dir = "/path/to/hf/snapshot";
const model = new Gemma4Model(await Weights.open(dir), await loadModelConfig(dir));
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);

const ids = tok.encode(template.render([{ role: "user", content: "Hi!" }]));
const gen = generate(model, ids, {
  maxTokens: 256,
  temperature: 0.7, topP: 0.95, seed: 42,   // reproducible sampling
  kvBits: 8, quantizedKvStart: 4096,        // optional: quantized KV past 4k
});
for await (const t of gen) process.stdout.write(tok.decode([t.token], true));
console.log(gen.stats); // prompt/decode tok/s, cached tokens, ...
```

KV caches can be persisted to disk (page-aligned files that reload as
zero-copy GPU-safe mmaps — see `src/kv-store.ts`) so a standard agent
preamble prefills once, ever.

## Correctness

Logit parity with mlx-lm (same weights, Python reference) is the
project's oracle. The test suite holds the forward pass **bit-exact**
against it, and every ported helper follows the reference
implementation's exact op composition (see PLAN.md for the findings that
made that possible). Golden files are regenerated only by explicit
scripts (`scripts/regen-goldens.ts`, `scripts/regen-parity-goldens.ts`)
running the Python oracle.

```sh
bun test    # fast tier runs everywhere; model-loaded tests auto-skip
            # unless the reference snapshot is in your HF cache
```

## Troubleshooting

- **`dlopen` / `libmlxc.dylib` not found** — `brew install mlx-c`; on
  older setups check `/opt/homebrew/lib` is in your dyld path.
- **`no models match`** — run `bun src/cli.ts scan` after downloading;
  models must be in the standard HF cache (`~/.cache/huggingface/hub`).
- **HF download stalls at 0%** — `HF_HUB_DISABLE_XET=1` before the
  download command.
- **Slow decode on a model near your RAM ceiling** — close memory-heavy
  apps; a model that doesn't fit the wired-memory budget pages weights
  every token (check with `fit`).
- **Bun version** — requires ≥ 1.3.14 (`bun upgrade`); pinned for
  `Bun.Image` and verified FFI behavior.

## Status

Pre-alpha, moving fast. See [PLAN.md](./PLAN.md) for phases, exit
criteria, measured numbers, and the findings log. Currently: phases 0–5
essentially complete (load path, bit-exact model port, sampling/serving,
tools + vision, registry/fit/KV-persistence); Phase 6 (quantized KV,
MoE, speculation) characterized and largely shipped; LoRA hot-swap is
next.

## License

MIT. Third-party attributions: [THIRD_PARTY_LICENSES.md](./THIRD_PARTY_LICENSES.md).
