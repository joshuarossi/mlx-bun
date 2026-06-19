# mlx-bun

Native MLX inference for Bun, and the beginning of a one-command local AI
product for Apple Silicon Macs. `mlx-bun` detects the machine, starts a useful
local assistant, exposes OpenAI/Anthropic-compatible APIs, and gives
TypeScript apps direct access to MLX without Python or a sidecar server.

The product bet is that local AI on Mac is a finite optimization problem, not
an infinite configuration maze: Apple ships a known set of chip/RAM/bandwidth
SKUs, the supported model list is curated, and the task mode is explicit. That
means defaults can be chosen from measured device × model × mode profiles
instead of asking every user to become an ML systems engineer.

Measured head-to-head on an M4 Pro (24 GB), same models, same machine
state: logits **bit-exact** against the Python reference; served over
HTTP the **fastest stack on every model tested** — fastest decode, plus
TTFT **34–85 ms** vs python's 218–326 ms at **~0% server overhead**
(mlx-lm pays −5–6%); server start to ready in **0.17–0.47 s**, 2–5×
faster than the Python servers. Full table: [benchmarks](#benchmarks).

## Getting started

You need an Apple Silicon Mac (MLX is Metal-only, so macOS only by
design). Four ways in.

### Direct download (recommended)

No Homebrew, Bun, or git — just curl the install script. It downloads the
signed, notarized self-contained binary from the latest release and puts
`mlx-bun` on your PATH:

```sh
curl -fsSL https://mlx-bun.dev/install.sh | sh
mlx-bun
```

Self-contained (binary + MLX runtime) and notarized, so it runs without a
Gatekeeper prompt. Installs to `~/.mlx-bun` by default — override with
`MLX_BUN_INSTALL_DIR`, or pin a release with `MLX_BUN_VERSION=v0.0.4`.

### Homebrew

A self-contained, signed + notarized binary — no toolchain to install by
hand:

```sh
brew install joshuarossi/tap/mlx-bun
mlx-bun
```

That's the whole thing. The bottle already bundles the MLX native
runtime, so the only thing the first run fetches is the model.

### bunx (no install)

Already have [Bun](https://bun.sh) ≥ 1.3.14? Run it straight from npm,
nothing to install:

```sh
bunx mlx-bun
```

First run fetches the MLX native runtime (~52 MB) and the model into your
caches, then serves. (Bun only — `npx mlx-bun` under Node exits with a
"requires Bun" notice by design.)

### From source

Needs [Bun](https://bun.sh) ≥ 1.3.14 — no Python, no native library to
install by hand:

```sh
# 1. Install Bun
curl -fsSL https://bun.sh/install | bash
exec $SHELL -l

# 2. Clone, install, link the CLI
git clone https://github.com/joshuarossi/mlx-bun.git && cd mlx-bun
bun install
bun run link-cli                 # adds the `mlx-bun` command — or run `bun src/cli.ts <verb>`

# 3. Run it — that's the whole thing
mlx-bun
```

Bare `mlx-bun` is an alias for `mlx-bun serve`. On its first run, with no
model named, it does everything for you:

1. pulls the MLX native runtime (~52 MB) into `~/Library/Caches/mlx-bun/`
   (skipped on the Homebrew install — the runtime ships in the bottle);
2. downloads the sub-GB `MiniCPM5-1B` starter and serves it, so you're
   chatting in well under a minute;
3. starts downloading `gemma-4-e4b` (the stronger 4B model) in the
   background — it becomes the default on your next `mlx-bun serve`;
4. opens the chat UI in your browser at
   [`http://localhost:8090/#/chat`](http://localhost:8090/#/chat)
   (pass `--no-open` to skip).

Want a specific model instead? Name it — `mlx-bun serve e4b` (substring
match against your downloaded models), grabbing it first with
`mlx-bun get <repo-id>` if you don't have it. See
[Supported models](#supported-models) for the full list and what fits
your machine.

**Prefer the API?** It's OpenAI-compatible — any OpenAI client works:

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

## What mlx-bun is

`mlx-bun` has four faces, all sharing one native runtime:

- **The local AI product** — run `mlx-bun` or `bunx mlx-bun` and get a
  working local chat UI plus a local server. The default path should feel like
  an appliance: download the starter model, start chatting quickly, then move
  to the stronger recommended model as it becomes available.
- **The app developer library** — embed local MLX inference inside Bun,
  Tauri, Electron, and other TypeScript applications without running Python in
  the background.
- **The AI lab** — keep parity, evals, kernels, LoRA/ORPO training, adapter
  routing, and performance experiments close to the runtime that will actually
  serve them.
- **The background agent runtime** — leave a local OpenAI-compatible endpoint
  available for scripts, recurring jobs, app integrations, and per-request
  adapter routing.

The default experience is intentionally opinionated. Power users can override
models, budgets, KV modes, adapters, and flags; the average user should not
need to know those knobs exist.

## Supported models

Scope is deliberate: a few model families held to **bit-exact** logit
parity with the Python reference, rather than dozens held to none.
Currently MiniCPM5, the Gemma-4 OptiQ quants, and Qwen3.5-4B:

| Model | Download | Fits on | Vision | Notes |
|---|---|---|---|---|
| [`mlx-community/MiniCPM5-1B-OptiQ-4bit`](https://huggingface.co/mlx-community/MiniCPM5-1B-OptiQ-4bit) | 0.92 GB | 8 GB | — | Sub-GB option for 8 GB machines; bit-exact 100-step oracle parity (bf16 + mixed KV), tool calling + agent loop verified |
| [`mlx-community/Qwen3.5-4B-OptiQ-4bit`](https://huggingface.co/mlx-community/Qwen3.5-4B-OptiQ-4bit) | 3.1 GB | 8 GB | — | bf16-KV bit-exact parity (vs mlx-lm); thinking + tool calling; ~74 tok/s predicted |
| [`mlx-community/gemma-4-e4b-it-OptiQ-4bit`](https://huggingface.co/mlx-community/gemma-4-e4b-it-OptiQ-4bit) | 7.0 GB | 16 GB | ✓ | **Recommended starter** (16 GB+); ~56 tok/s |
| [`mlx-community/gemma-4-12B-it-OptiQ-4bit`](https://huggingface.co/mlx-community/gemma-4-12B-it-OptiQ-4bit) | 8.4 GB | 16 GB | ✓ | Vision + tool calling, both verified end-to-end |
| [`mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit`](https://huggingface.co/mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit) | 18 GB | 24 GB | — | MoE (top-8 of 128 experts); ~54 tok/s |

Not sure what fits your machine? `bun src/cli.ts fit <model> --ctx 8192`
gives a deterministic answer (see below). The larger
`Qwen3.6-27B-OptiQ-4bit` is still in bring-up — parity and serving polish
remain (see [PLAN.md](./PLAN.md)).

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
  first use; opening an 8.4 GB model takes milliseconds, and warm
  restarts are near-instant on cached pages.
- **`Bun.Image`** — native OS image codecs (HEIC, AVIF, WebP, JPEG, …)
  for the vision path, EXIF auto-orientation included.
- **`bun:sqlite`** — built-in storage for the model registry and eval DB.
- **One binary, one toolchain** — runtime, package manager, test runner.

## CLI

Commands are shown as `bun src/cli.ts <verb>` (runs straight from a
clone). Once installed/linked, `mlx-bun <verb>` is the identical command.

```sh
bun src/cli.ts get mlx-community/gemma-4-12B-it-OptiQ-4bit   # resumable, verified download
bun src/cli.ts scan                 # index your HF cache into the registry
bun src/cli.ts ls                   # list models (size, params, quant, capabilities)
bun src/cli.ts ls --vision --max-size 10GB
bun src/cli.ts fit gemma --ctx 32768          # memory contract: fits? max context? predicted tok/s
bun src/cli.ts fit gemma --ctx 8192 --skus    # ...same, across the Apple Silicon lineup
bun src/cli.ts serve gemma --port 8090        # OpenAI-compatible server
bun src/cli.ts serve gemma --memory-budget 18 # ...with admission control (GB)
bun src/cli.ts pi                   # built-in agentic coding CLI (pi's TUI, in-process)
bun src/cli.ts evals                # recorded benchmark runs
bun src/cli.ts harness pi           # connect your own pi install to the local server
./benchmark.sh                      # head-to-head matrix vs mlx-lm/optiq (reboot first;
                                    #   preflight-gated, resumable, writes benchmarks-h2h-<date>-<host>.md)
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
  text with streaming hold-back), `reasoning_effort` (thinking on/off for
  Qwen3.5 / MiniCPM5 — `none` disables, any level enables), and an `hlg`
  tone-curve sampling override;
  omitted sampling fields default to the model's own
  `generation_config.json` recipe; usage includes `cached_tokens`.
  Full schemas in
  [docs/reference/server-api.md](./docs/reference/server-api.md); start
  flags and the `--batch N` compatibility matrix in
  [docs/reference/server-config.md](./docs/reference/server-config.md).
- **Tool calling** — pass OpenAI `tools`; each family's native format
  is parsed into `tool_calls` JSON with `finish_reason: "tool_calls"`
  (Gemma 4 `<|tool_call>` sentinel tokens; MiniCPM5 / Qwen3.5
  `<function name=…>` XML with schema-aware argument decoding);
  `role: "tool"` round-trips, including multi-turn agent loops.
- **Vision** — `image_url` content parts (data: URLs or http/s), on
  models with the vision sidecar. PNG, JPEG, HEIC, AVIF, WebP, TIFF,
  GIF, BMP via native OS codecs.
- **Prompt caching** — a byte-capped LRU KV cache reuses the longest
  common token prefix across requests (multi-turn conversations
  re-prefill only the new turn) — automatic, no client changes.
  Entries are adapter-specific when LoRA adapters are in play.
- **LoRA hot-swap** — mount adapters at runtime (`POST /v1/adapters`)
  and discover on-disk ones (`GET /v1/adapters/available`), select per
  request with the `adapter` body field (`"id"`, stacked `"a+b"`, or
  `"none"`). The base model never reloads; an unselected adapter costs
  nothing.
- **Mixed-precision KV** — when the model repo ships `kv_config.json`
  (every Gemma-4 OptiQ repo does), per-layer KV quantization applies
  automatically; the config sets bits per layer for both full-attention
  and sliding-window (rotating) layers (Phase 9). Measured decode-neutral
  at 8k on the 12B with KV bytes ÷4 on the quantized layers. `--kv-quant off` forces bf16; `--kv-quant 4|8`
  forces uniform bits. Long prefills over quantized caches run a fused
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
  active KV scheme, response store), **`GET/POST/DELETE /v1/adapters`**,
  plus **`GET /library`**, **`GET /fit`**, **`GET /downloads`**, and
  **`GET /v1`** (a self-describing index of every endpoint).

## Library

The server is one consumer of a library-first API. Published to npm as
`mlx-bun` (current: 0.0.4) — import from the package (`from "mlx-bun"`)
or `./src/index` in a clone; `bunx mlx-bun` runs the CLI without
installing. Full reference:
[docs/reference/library-api.md](./docs/reference/library-api.md). For shipping inside a
Mac app (Tauri/Electron sidecar), `./scripts/build-binary.sh` produces
a relocatable single-binary bundle — recipe incl. signing/notarization
in [docs/reference/embedding.md](./docs/reference/embedding.md).

```ts
import {
  createModel,        // dispatches to Gemma4 / MiniCPM5 / Qwen3.5
  Weights, loadModelConfig, loadTokenizer, ChatTemplate, generate,
} from "mlx-bun";     // or "./src/index" in a clone

const dir = "/path/to/hf/snapshot";
const config = await loadModelConfig(dir);
const model = createModel(await Weights.open(dir), config);  // RuntimeModel
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
same machine (M4 Pro 24 GB), same HF snapshots, the 2026-06-14
cleared-machine run, preflight-gated, median-of-N with warmups
discarded. Full curated table (parity / performance / quality) with
per-row provenance: [benchmarks/RESULTS.md](./benchmarks/RESULTS.md).

**Served (warm)** — how agents actually use a local model.
decode tok/s · TTFT ms · start s:

| model | mlx-bun | mlx-lm | optiq |
|---|---|---|---|
| MiniCPM5-1B | **252.9** · 34 · 0.17 | — | 223.6 · 64 · 0.84 |
| gemma-4-e4b | **55.7** · 44 · 0.36 | 53.5 · 218 · 0.98 | 53.4 · 221 · 0.78 |
| gemma-4-12B | **25.9** · 85 · 0.38 | — | 25.5 · 326 · 1.24 |
| gemma-4-26B | **54.2** · 45 · 0.47 | 52.3 · 228 · 0.77 | — |

Across every served model mlx-bun has the fastest decode and the fastest
TTFT/startup (2–5×), at **~0% server tax** vs its own direct engine —
mlx-lm pays −5–6%, optiq −1 to −10%.

**Direct (engine only).** Decode is at parity-to-slightly-behind mlx-lm
(e4b +1.1%, 12B +0.4%, 26B −1.1%, MiniCPM5 −0.9% — within the per-step
host-overhead residual), and prefill leads on the larger models (12B
1.2×, 26B 1.1×, MiniCPM5 2.3×; e4b trails at 0.8×). The earlier decode
deficit was root-caused and fixed (2026-06-11) — a prefill→decode
allocator-reclaim stall mlx-lm clears with `mx.clear_cache` and bills to
prompt time; see PLAN.md "Decode gap RESOLVED".

**Long context (12B).** At 16k and 64k mlx-bun holds decode parity with
mlx-lm on bf16 (16k 23.9 = 23.9; 64k 20.9 = 20.9) while optiq drops to
21.6 then collapses to 12.3 at 64k; mixed-KV trades ~2 tok/s for ~5 GB
lower peak.

Two cross-stack served cells are absent: no mlx-lm 12B row, and optiq
produced no output on the 26B (the Metal-OOM class from python's
non-lazy load transient — reproduced in isolation; mlx-bun and mlx-lm
both served it from the same machine state). One further optiq cell
(12B/kv=config) is blocked on an upstream `quantized_matmul` bug. Both
are documented in the results file.

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
bun test    # fast tier runs everywhere; model-loaded tests run only
            # when the reference snapshot is in your HF cache
```

## Troubleshooting

- **`dlopen` / `libmlxc.dylib` not found** — the MLX runtime
  auto-downloads on first `serve` into `~/Library/Caches/mlx-bun/`; if a
  download was interrupted, just rerun `serve` (it resumes). To point at
  your own copy instead, set `MLX_BUN_LIBMLXC=/path/to/libmlxc.dylib`.
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
criteria, measured numbers, and the findings log.

**Complete** — load path; bit-exact model port (MiniCPM5, Qwen3.5-4B,
e4b per-layer-input, 12B dense, 26B MoE); sampling + serving (tools, vision,
prompt cache); registry / fit / KV persistence; quantized +
mixed-precision KV serving (rotating-cache KV-quant, Phase 9) with fused
quantized prefill (Phase 10); LoRA hot-swap with per-request selection;
segmented-backward LoRA training (SFT / DPO / ORPO, with an `[M,vocab]`-free
flash-CCE head + prefix-sharing for long-context preference data — see
[training guide](docs/reference/training.md)); resumable
verified downloads (`mlx-bun get`); memory admission control; the
head-to-head benchmark harness; the decode-gap root-cause fix
(2026-06-11); Anthropic Messages + Responses API (`/v1/messages` and
`/v1/responses`, Phase 11); SigLIP vision sidecar for e4b
(commit 4625fe5); the embeddable single-binary build (signed +
notarized — Homebrew, direct-download, and npm/bunx).

**In progress** — `Qwen3.6-27B` bring-up (Phase 14f): same architecture
as the verified 4B (untied + larger geometry); parity and serving polish
remain. MTP speculation and Qwen3-VL vision deferred.

**Experimental** — opt-in, default-off, still being hardened: transparent
expert offload for MoE models (`serve --expert-offload`, Phase 20:
page-aligned mmap-backed experts, bit-exact — 26B-A4B 17.1→4.2 GB
resident, decode unregressed); batched serving (`--batch N`, Phase 18:
continuous-batching bf16 B=N decode, B=2 bit-parity verified for
MiniCPM5/12B/e4b/26B; throughput polish remains).

**Open** — e4b's ~5% per-step host-overhead decode residual (Phase 7);
SigLIP vision for 26B.

## License

MIT. Third-party attributions: [THIRD_PARTY_LICENSES.md](./THIRD_PARTY_LICENSES.md).
