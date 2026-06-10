# mlx-bun

Native MLX inference for Bun. Run quantized LLMs on Apple Silicon from
TypeScript — no Python, no sidecar server, one runtime.

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

Measured on the reference M4 Pro (24 GB): decode within 3% of mlx-lm
(24.9 vs 25.7 tok/s on gemma-4-12B 4-bit), prefill at parity (~257
tok/s), lower peak memory, logits **bit-exact** against the Python
reference, and cold start → first token of a cached prompt in 394 ms.

## Requirements

- Apple Silicon Mac (macOS only, by design — that's where MLX is)
- [Bun](https://bun.sh) ≥ 1.3.14
- `brew install mlx-c` (installs `libmlxc.dylib` + `libmlx`)
- A supported model in your Hugging Face cache (Gemma 4 family;
  OptiQ mixed-precision quants supported, including the vision sidecar)

```sh
git clone <this repo> && cd mlx-bun
bun install
bun test          # fast tier runs everywhere; model-loaded tests
                  # auto-skip unless the reference snapshot is present
```

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

`fit` is deterministic, not vibes: weights bytes from safetensors
headers, KV bytes/token from the config (sliding-window layers capped),
calibrated prefill transient, and the machine's wired-memory ceiling.
Predictions are recorded next to measured peaks in the eval DB.

## HTTP API

`serve` exposes an OpenAI-compatible API (works with any OpenAI client;
point pi/OpenClaw-style agents at it):

```sh
curl localhost:8090/v1/chat/completions -d '{
  "messages": [{"role": "user", "content": "Hello!"}],
  "max_tokens": 128, "temperature": 0.7, "stream": true
}'
```

- **Streaming** — SSE chunks with usage (including `cached_tokens`).
- **Tool calling** — pass OpenAI `tools`; the model's native
  `<|tool_call>` markers are parsed into `tool_calls` JSON with
  `finish_reason: "tool_calls"`; `role: "tool"` round-trips.
- **Vision** — `image_url` content parts (data: URLs or http/s).
  PNG, JPEG, HEIC, AVIF, WebP, TIFF, GIF, BMP via native OS codecs.
- **Prompt caching** — a byte-capped LRU KV cache reuses the longest
  common token prefix across requests (multi-turn conversations re-prefill
  only the new turn). `GET /stats` shows hit rates and bytes.
- `GET /v1/models`, `GET /stats`.

## Library

The server is one consumer of a library-first API:

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

## Status

Pre-alpha, moving fast. See [PLAN.md](./PLAN.md) for phases, exit
criteria, measured numbers, and the findings log. Currently: phases 0–5
essentially complete (load path, bit-exact model port, sampling/serving,
tools + vision, registry/fit/KV-persistence); Phase 6 (speculative
decoding, MoE) in progress.

## License

MIT. Third-party attributions: [THIRD_PARTY_LICENSES.md](./THIRD_PARTY_LICENSES.md).
