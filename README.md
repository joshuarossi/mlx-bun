# mlx-bun

Native MLX inference for Bun. Run quantized LLMs on Apple Silicon from
TypeScript — no Python, no sidecar server, one runtime.

Measured head-to-head on an M4 Pro (24 GB), same models, same day:
logits **bit-exact** against the Python reference; served over HTTP the
**fastest stack on every model tested** (TTFT 45–89 ms vs python's
220–327 ms, zero server overhead vs mlx-lm's −5–6%); prefill up to
**1.8×** mlx-lm at 8k context; cold start → first token of a cached
prompt in **394 ms**. Full table: [benchmarks](#benchmarks).

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

**2. Get a model.** The built-in downloader is resumable (interrupt it,
rerun, it continues with a Range request) and checksum-verifies every
file. It writes the standard Hugging Face cache layout, so models you
already have are found as-is:

```sh
bun src/cli.ts get mlx-community/MiniCPM5-1B-OptiQ-4bit
```

(Models fetched with the HF CLI work too — same cache. Gated repos use
your existing `hf auth login` token automatically.)

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
Currently MiniCPM5 plus the Gemma-4 OptiQ quants:

| Model | Download | Fits on | Vision | Notes |
|---|---|---|---|---|
| [`mlx-community/MiniCPM5-1B-OptiQ-4bit`](https://huggingface.co/mlx-community/MiniCPM5-1B-OptiQ-4bit) | 0.92 GB | 8 GB | — | Sub-GB starter; bit-exact 100-step oracle parity (bf16 + mixed KV), tool calling + agent loop verified |
| [`mlx-community/gemma-4-e4b-it-OptiQ-4bit`](https://huggingface.co/mlx-community/gemma-4-e4b-it-OptiQ-4bit) | 7.0 GB | 16 GB | — | ~54 tok/s; good first model |
| [`mlx-community/gemma-4-12B-it-OptiQ-4bit`](https://huggingface.co/mlx-community/gemma-4-12B-it-OptiQ-4bit) | 8.4 GB | 16 GB | ✓ | Vision sidecar + tool calling, both verified end-to-end |
| [`mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit`](https://huggingface.co/mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit) | 18 GB | 24 GB | — | MoE (top-8 of 128 experts); ~54 tok/s — the python servers crash loading it on 24 GB |

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
bun src/cli.ts get mlx-community/gemma-4-12B-it-OptiQ-4bit   # resumable, verified download
bun src/cli.ts scan                 # index your HF cache into the registry
bun src/cli.ts ls                   # list models (size, params, quant, capabilities)
bun src/cli.ts ls --vision --max-size 10GB
bun src/cli.ts fit gemma --ctx 32768          # memory contract: fits? max context? predicted tok/s
bun src/cli.ts fit gemma --ctx 8192 --skus    # ...same, across the Apple Silicon lineup
bun src/cli.ts serve gemma --port 8090        # OpenAI-compatible server
bun src/cli.ts serve gemma --memory-budget 18 # ...with admission control (GB)
bun src/cli.ts evals                # recorded benchmark runs
./benchmark.sh                      # head-to-head matrix vs mlx-lm/optiq (reboot first;
                                    #   preflight-gated, resumable, writes benchmarks-h2h-<date>.md)
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
  `temperature`, `top_p`, `top_k`, `max_tokens`, `seed`,
  `repetition_penalty`, `stop` (string or array, matched on decoded
  text with streaming hold-back); omitted sampling fields default to
  the model's own `generation_config.json` recipe; usage includes
  `cached_tokens`. Full schemas in
  [docs/reference/server-api.md](./docs/reference/server-api.md).
- **Tool calling** — pass OpenAI `tools`; each family's native format
  is parsed into `tool_calls` JSON with `finish_reason: "tool_calls"`
  (Gemma 4 `<|tool_call>` sentinel tokens; MiniCPM5
  `<function name=…>` XML with schema-aware argument decoding);
  `role: "tool"` round-trips, including multi-turn agent loops.
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
  uniform bits. Long prefills over quantized caches run a fused
  FlashAttention-2 tiling that never materializes the full scores
  matrix (bounded transient; `MLX_BUN_NO_FUSED_SDPA=1` to disable).
  `MLX_BUN_FUSED_DECODE=1` extends the tiling to single-token decode —
  experimental, default off (measured ~4% slower on Gemma @8k kv8;
  kept for model families where it may win).
- **Memory admission control** — `--memory-budget <GB>` refuses to load
  a model that can't serve within the budget and rejects requests whose
  `prompt + max_tokens` exceed the budget's max safe context with a 400
  (`type: "memory_admission"`) *before* generating. The GPU
  out-of-memory crash it prevents is uncatchable by design — rejection
  up front is the only defense. Ceiling visible at `GET /stats`.
- **Anthropic Messages API** (`POST /v1/messages`, on by default) —
  point any Anthropic-SDK tool at the server
  (`ANTHROPIC_BASE_URL=http://localhost:8090`); Claude Code runs
  against it as a fully local backend. Streaming event grammar, native
  tool_use/tool_result mapping, image blocks via the vision path.
- **OpenAI Responses API** (`POST /v1/responses`) — the protocol
  Codex/Cursor/Continue speak; includes `previous_response_id`
  resumption backed by a TTL + byte-capped store (visible in /stats).
- **`GET /v1/models`**, **`GET /stats`** (cache hit rates, bytes,
  active KV scheme, response store), **`GET/POST/DELETE /v1/adapters`**.

## Library

The server is one consumer of a library-first API. Not yet published to
npm — clone the repo and import from `src/`. Full reference:
[docs/reference/library-api.md](./docs/reference/library-api.md). For shipping inside a
Mac app (Tauri/Electron sidecar), `./scripts/build-binary.sh` produces
a relocatable single-binary bundle — recipe incl. signing/notarization
in [docs/reference/embedding.md](./docs/reference/embedding.md).

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

## Benchmarks

Head-to-head against the Python stacks (mlx-lm 0.31.3, mlx-optiq 0.2.1),
same machine (M4 Pro 24 GB), same day, same HF snapshots, preflight-gated
clean machine, median-of-N with warmups discarded. Full table with
per-row provenance:
[benchmarks/benchmarks-h2h-2026-06-11-Joshs-MBP-2025.md](./benchmarks/benchmarks-h2h-2026-06-11-Joshs-MBP-2025.md).

| | mlx-bun | mlx-lm | optiq |
|---|---|---|---|
| **TTFT, served (warm)** | **45–90 ms** | 219–224 ms | 222–331 ms |
| **server start → ready** | **0.36–0.47 s** | 0.76–0.98 s | 0.79–1.00 s |
| **decode through HTTP** (e4b / 12B / 26B) | **54.5** / 25.2 / **54.9** | 53.5 / — / 52.2 | 53.5 / **25.5** / † |
| **server tax vs own direct decode** | **≈ 0%** | −5…−7% | ≈ 0% |
| **direct decode** (engine only) | −1.9…−4.4% vs mlx-lm | baseline | −0.8…−1.2% |
| **12B decode @8k context** | 23.3 (23.0 kv-mixed) | **24.4** | 23.2 kv-mixed |

Honest negatives, same table: in this matrix our direct decode trailed
mlx-lm on every model (12B −1.9%, 26B −2.9%, e4b −4.4% at short
context; the 12B gap grew to −4.5% @8k), and optiq's served 12B edges
ours by ~1% (25.5 vs 25.2) while paying 3.7× the TTFT. **Post-matrix
(2026-06-11) the decode gap was root-caused and fixed** — a
prefill→decode allocator-reclaim stall that mlx-lm clears with
`mx.clear_cache` and bills to prompt time (we billed it to decode);
after the reference-faithful fix, same-session paired runs put the 12B
*ahead* at short context (25.1 vs 24.0) and at parity @8k (23.8 vs
23.9). Clean-machine re-measure pending; e4b retains a ~5% per-step
host-overhead residual (see PLAN.md "Decode gap RESOLVED"). Served through HTTP — how agents actually use a local
model — mlx-bun has the fastest decode on e4b and the 26B, and the
fastest TTFT and startup everywhere by 2–5×. † = cell failed: optiq
serve produced no output on the 26B (the Metal OOM crash class from
python's non-lazy load transient — reproduced in isolation; mlx-bun
and mlx-lm both served the same model from the same machine state).
One further optiq cell is blocked on an upstream optiq bug; both are
documented in the results file.

These numbers are the 2026-06-11 cleared-machine re-run with the
long-context guard active (every @8k row verified at its requested
context — an earlier harness bug had fed python @8k baselines
~31-token prompts; fixed, guarded, and re-measured).

## Correctness

Logit parity with mlx-lm (same weights, Python reference) is the
project's oracle. The test suite holds the forward pass **bit-exact**
against it — including every quantized-KV configuration (kv8, kv4, and
the 26B's mixed per-layer scheme) and the fused quantized-attention
prefill, which is bit-exact against optiq's reference implementation.
Every ported helper follows the reference implementation's exact op
composition, down to constants built at load time (the one latent
divergence ever found — rope frequencies computed host-side instead of
on-device — was root-caused and fixed in Phase 10; see PLAN.md
findings). Golden files are regenerated only by explicit scripts
(`scripts/regen-*.ts`) running the Python oracle.

```sh
bun test    # fast tier runs everywhere; model-loaded tests auto-skip
            # unless the reference snapshot is in your HF cache
```

## Troubleshooting

- **`dlopen` / `libmlxc.dylib` not found** — `brew install mlx-c`; on
  older setups check `/opt/homebrew/lib` is in your dyld path.
- **`no models match`** — run `bun src/cli.ts scan` after downloading;
  models must be in the standard HF cache (`~/.cache/huggingface/hub`).
- **HF download stalls at 0%** — use `bun src/cli.ts get <org/repo>`
  (plain HTTPS, no Xet, resumes where it left off); for the Python CLI,
  `HF_HUB_DISABLE_XET=1` before the download command.
- **Slow decode on a model near your RAM ceiling** — close memory-heavy
  apps; a model that doesn't fit the wired-memory budget pages weights
  every token (check with `fit`).
- **Bun version** — requires ≥ 1.3.14 (`bun upgrade`); pinned for
  `Bun.Image` and verified FFI behavior.

## Status

Pre-alpha, moving fast. See [PLAN.md](./PLAN.md) for phases, exit
criteria, measured numbers, and the findings log. Complete: load path,
bit-exact model port (12B dense / e4b per-layer-input / 26B MoE),
sampling + serving (tools, vision, prompt cache), registry/fit/KV
persistence, quantized + mixed-precision KV serving (rotating-cache
KV-quant included, Phase 9) with fused quantized prefill (Phase 10),
LoRA hot-swap with per-request selection, resumable verified downloads
(`mlx-bun get`), memory admission control, and the head-to-head
benchmark harness, and the decode-gap root-cause fix (clear_cache
placement + boundary accounting, 2026-06-11 — 12B now at-or-above
mlx-lm decode in paired runs). Open: e4b's ~5% host-overhead decode
residual (Phase 7), Anthropic messages + Responses API (Phase 11),
SigLIP vision for e4b/26B, Qwen 3.x, the embeddable single-binary
build.

## License

MIT. Third-party attributions: [THIRD_PARTY_LICENSES.md](./THIRD_PARTY_LICENSES.md).
