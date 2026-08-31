# Server configuration

The canonical reference for **every start flag, every `MLX_BUN_*`
environment variable, and every serving feature** of `mlx-bun serve` (and
`mlx-bun pi`, which shares the flag set). Each default here is read from
the code, not from memory: flags are parsed by `serverRuntimeFlags()` /
`applyDecodeRoute()` in [src/cli.ts](../../src/cli.ts) (the `SERVER_FLAGS`
help block is the same list), runtime knobs land in `ServerOptions`
([src/server.ts](../../src/server.ts)), environment reads go through
[src/runtime-config.ts](../../src/runtime-config.ts), and the `--isolate`
proxy lives in [src/serve/isolate.ts](../../src/serve/isolate.ts). For the
request/response wire format see [server-api.md](./server-api.md); for
CLI verbs see [cli.md](./cli.md).

Sections: [Start flags](#start-flags) · [`--isolate` semantics](#--isolate-semantics)
· [Per-request overrides](#per-request-overrides) · [Environment variables](#environment-variables)
· [Execution modes](#execution-modes-serial-vs---batch-n) · [Compatibility matrix](#compatibility-matrix)
· [Fidelity tiers](#fidelity-tiers-and-the-decode-route---l1----l2) · [Feature matrix](#feature-matrix)
· [Performance & recipes](#performance-characteristics--recipes) · [`GET /stats`](#observability--get-stats).

## Start flags

How flags are parsed (`src/cli.ts` `opt`/`flag`/`positional`):

- A value flag is `--name value` (space-separated; `--name=value` is not
  recognized). A value flag with no following token takes its default.
- **Unknown flags are silently ignored** — there is no unknown-flag error.
  mlx_lm.server's `--kv-group-size` and `--quantized-kv-start` are in this
  class: `src/serve/isolate.ts` lists them as value-taking so the engine
  argv builder does not mistake their value for a model positional, but
  `serve` never reads them (uniform `--kv-quant 4|8` is fixed at group
  size 64, start 0).
- Aliases: `--adapter-path` = `--adapter`; `--temp` = `--temperature`
  (explicit `--temperature` wins); `--decode-concurrency` = `--batch`
  (`--batch` wins); `--query`/`-q` = the positional model query.
- `mlx-bun pi` consumes the same flag set; when it attaches to an
  already-running server every server-shaping flag except `--port` is
  reported as ignored (the running server keeps its configuration).

**Lane/tier column:** `serial` = the strict single-queue executor;
`batch` = the continuous scheduler (`--batch N`); `both` = lane-independent.
L1 = bit-exact vs mlx-lm, L2 = bit-exact vs mlx-optiq, Lab = no external
oracle. See [Fidelity tiers](#fidelity-tiers-and-the-decode-route---l1----l2).

### Model selection

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `[query]` (positional) | registry query | auto-pick | both | First non-flag token after `serve`: a registry query (`"12B"`, `"e4b"`, a repo substring). Omitted: serves e4b when downloaded, else the largest downloaded model that fits; a fresh install downloads a small starter model first, then e4b in the background. |
| `--model` | path \| query | none | both | mlx_lm.server's spelling, and the **highest-precedence** selector: a directory containing `config.json` loads straight from that path (`scanSnapshot`, no registry lookup — the bench/CI shape; an HF-cache path recovers its repo id from `models--org--name/snapshots/`); anything else resolves like the positional query. Precedence: `--model` > positional > `--query` > auto-pick. Under `--isolate`, the parent resolves the model and pins `--model <path>` on the engine child. |
| `--query` / `-q` | registry query | none | both | Same as the positional query (lowest-precedence explicit selector). `-q` is the `mlx-bun pi` spelling. |

### Network

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--host` | addr | `127.0.0.1` | both | Interface to bind. Loopback-only by default (mlx_lm.server parity); `--host 0.0.0.0` exposes the server on your network. The browser-open uses `localhost` when the bind is `0.0.0.0`/`::`. |
| `--port` | n | `8080` | both | Listen port. Before loading weights the CLI probes `http://localhost:<port>/v1` and refuses to start if something is already serving there (skipped under `--unix`). |
| `--unix` | socket path | none | both | **Internal.** Listen on a unix domain socket instead of TCP — the engine half of `--isolate` (`ServerOptions.unixSocket`; `hostname`/port are ignored, stale socket files are unlinked before bind). Usable directly for socket-level integration. |

### Memory, admission, and caches

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--memory-budget` | GB (decimal, ×10⁹) | machine RAM × `WIRED_FRACTION` (0.75, `src/fit.ts`); GLM-5.2: min(25 GiB, physical RAM) | both (per request) | Admission ceiling. A request whose prompt fits is always admitted: a broad client `max_tokens` is capped to the room left under the safe context; only a prompt that leaves no generation slot is rejected with **400** (`type: memory_admission`) — the alternative is an uncatchable GPU OOM. The safe-context ceiling bills the active `--kv-quant` scheme at its true bytes/element (`turbo` is billed bf16, conservatively). A budget too small for any context logs a warning and serves anyway. GLM-5.2 runs its header-only resource equation against this ceiling before opening any resident weights or expert slabs. Not an aggregate cap across batch rows — see `--kv-budget`. |
| `--kv-budget` | GB (decimal) | off | batch | Aggregate KV budget across concurrently admitted batch rows: a joiner whose projected KV (prompt + `max_tokens`, window-capped) would exceed it **queues** until rows finish; a request over the budget alone is rejected. Without it, N large-context rows can collectively exceed memory. Reported in `/stats.batch.kv_budget_bytes`. |
| `--prompt-cache` | GB (binary GiB) | `8` | both | RAM prefix-KV cache (byte-capped LRU). `--prompt-cache 0` disables it. Serves are **non-consuming**: a hit hands out zero-copy clones and leaves the donor entry intact, so N agents sharing a system prompt reuse one prefill. Batch-lane joiners `take()` the longest usable prefix at admission; a row that finishes without ever merging `put()`s its caches back (merged rows' entries age out). |
| `--ssd-cache` | dir | off | both | SSD cold tier under the prompt cache ([docs/design/kv-cache.md](../design/kv-cache.md)): prefix KV spills to disk on RAM eviction and idle demotion, is snapshotted after requests settle (debounced, idle-gated per tensor so it never taxes an active decode — `MLX_BUN_SSD_WRITEBEHIND=0` disables), and **survives restarts**. Entries are keyed by model fingerprint + effective KV scheme + tokenizer hash + adapter namespace; incompatible or corrupt files self-quarantine. `SIGINT`/`SIGTERM` drains active requests and flushes dirty snapshots before exit (`MLX_BUN_SHUTDOWN_TIMEOUT_MS`); `POST /admin/cache/flush` is the explicit boundary. Requires the RAM cache. |
| `--ssd-cache-max` | GB (binary GiB, min 1) | `32` | both | SSD tier byte cap; oldest-mtime entries are evicted at the cap. Warns and is ignored without `--ssd-cache`. |
| `--ssd-cache-verify` | (bool) | off | both | Verify every tensor hash on restore (reads all bytes eagerly, defeating lazy fault-in) — integrity paranoia only; the header hash is always verified. Warns and is ignored without `--ssd-cache`. |
| `--ssd-demote-idle` | seconds | `300` with `--ssd-cache`, else off | both | Prompt-cache entries unused this long spill to the SSD tier and free their GPU memory; the next hit restores them. Swept only when the engine is fully idle. `0` disables. Warns and is ignored without `--ssd-cache`. |

### Runtime isolation

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--isolate` | (bool) | off | both | Run the inference engine as a **child process** on a unix socket while this process stays a pure UI/API reverse proxy — instant under any GPU load, survives engine crashes (auto-respawn). Full semantics in [`--isolate` semantics](#--isolate-semantics). |
| `--model-pool` | n (≥1) | `1` | both | With `--isolate`: max **resident** model engines. A request whose `model` field is an **exact** `/v1/models` id spawns/routes to that model's own engine child (spawn-overlap: the new model loads while the old keeps serving). Over the cap the least-recently-used engine is drained (`POST /admin/drain` over its socket), demotes its prompt cache to the SSD tier, and exits; switching back respawns it with state restored from disk. Without `--isolate` the flag warns and is ignored. |

### Scheduling

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--batch` | n (integer ≥ 1) | `8` | batch / L1 | Max concurrent requests decoded together. A lone admitted request uses the B=1 fast path (adopted serial-class caches, compiled decode, prompt cache + SSD restore — byte-identical to serial); a batch layout only exists once a second request arrives. `--batch 1` pins the strict serial executor (arrival-independent numerics — use it for golden regeneration). `--decode-concurrency` is accepted as the mlx_lm.server alias, but its semantics differ there (per-`BatchGenerator` decode parallelism, default 32). See [Execution modes](#execution-modes-serial-vs---batch-n). |

### KV cache

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--kv-quant` | `config` \| `off` \| `4` \| `8` \| `turbo[:k<bits>v<bits>]` | `off` (bf16) | see row | KV-cache quantization. `off` = bf16 (the L1 default: quantized KV measured 5–20% slower decode than bf16 at ≤16k on both stacks, so it is an opt-in that buys **memory headroom**). `4`/`8` = **uniform** bits (group 64, start 0 — mlx-lm's `--kv-bits` scheme); with fused-sdpa off (the default for uniform) our unfused quantized SDPA is op-for-op mlx-lm's `quantized_scaled_dot_product_attention`, so uniform is **bit-exact L1**; uniform requests route **serial**. `config` = **per-layer mixed precision** from the model's `kv_config.json` — optiq-only → **L2**; per-layer configs **batch** on every shipped model (full-attention and rotating layers; gated bit-exact per row vs the serial composition). `turbo[:k<bits>v<bits>]` = **TurboQuant** ([docs/design/turboquant.md](../design/turboquant.md)): rotation-based KV quantization, default `k8v3`; `kBits` ∈ {2,4,5,8}, `vBits` ∈ {2,3,4,5,8}; a separate axis (mutually exclusive with `config`/`4`/`8`), v1 is dequantize-on-fetch via stock `ops.sdpa`, **full-attention layers only** (sliding-window layers stay bf16 with a one-time warning), refuses head dims outside `TURBOQUANT_HEAD_DIMS`, and is **solo-only** — `GenerationGateway.place` refuses continuous scheduling for it unconditionally. Any explicit `--kv-quant` overrides the tier preset. |
| `--paged-kv` | (bool) | off | serial / gated bit-exact | **Optional vLLM-style paged KV cache** ([docs/design/kv-cache.md](../design/kv-cache.md)): full-attention layers store K/V in fixed-size block pools (host-side block table, gather back to contiguous before the stock SDPA; no new attention math). Env mirror `MLX_BUN_PAGED_KV=1`. With no explicit `--batch` the CLI pins `--batch 1`. `createServer` **refuses** (fails startup, never downgrades) `--batch N>1`, any `--kv-quant` (incl. turbo), `--draft-model`, and non-Gemma4 models. Media and adapter requests run the plain cache path per request. Paged requests bypass the prompt cache and run uncompiled decode; pool exhaustion is a typed error, never truncation. Gated bit-exact vs the plain path (`tests/parity/paged-kv-parity.test.ts`). |
| `--paged-kv-block-size` | n | `256` | serial | Tokens per KV block (`--paged-kv` only); 256 = the plain cache's growth step. |

### Adapters and speculative decoding

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--adapter` | dir | none | serial (adapter requests route serial) | Mount a LoRA adapter at startup (same machinery as `POST /v1/adapters`; the id is the directory basename) and make it the default for requests without an `adapter` field. A request's explicit `adapter` — including `"none"` — wins; hot-swap via `/v1/adapters` is unchanged. A bad adapter fails startup. Alias `--adapter-path`. |
| `--draft-model` | path \| query | none | serial (all requests) / per-drafter oracle | **Speculative decoding**: a drafter proposes tokens the target verifies in one forward — exact results, faster decode when drafts land. Resolves like the main model. Kind is auto-detected: a full same-tokenizer model (mlx_lm.server parity, L1 token-for-token; tokenizer-family mismatch fails startup), a Gemma `-assistant` KV-borrowing drafter (L2 vs optiq `spec_generate`), a locally trained **DSpark** checkpoint (`dspark.json`), or a released DeepSpec `Gemma4DSparkModel` drafter. Mounting a draft routes **every** request serial (upstream `is_batchable = draft is None`). Composes with structured output; prompt-cache reuse is bypassed on the spec path. Telemetry: `usage.speculation`. |
| `--draft-kind` | `two-model` \| `assistant` \| `dspark` \| `deepspec` \| `mtp` \| `ngram` | auto | serial | Override drafter detection. `mtp` = a native multi-token-prediction head split from the target's release (`*_mtp` model_type; shares the target's embeddings/lm-head, defaults `--num-draft-tokens` to its trained `block_size − 1`, rolls DeltaNet caches back by snapshot/replay on partial rejects); `mtp` alone mounts the companion bundled at `<model>/mtp/` when present. `ngram` = **model-free prompt lookup** (drafts copied from the request's own prompt+generation; port of prompt-lookup decoding / vLLM's `ngram` proposer) — mount it **alone** (`--draft-kind ngram` with a `--draft-model` is refused, as is any other kind without one); lossless by the same verify, a no-match round degrades to one plain target step. Any other value fails startup. |
| `--num-draft-tokens` | n (integer ≥ 1) | `3` (`ngram`: `10`; DSpark: pinned ≤ its trained `gamma`) | serial | Drafts per verify round (mlx_lm.server's default; `mlx_lm.generate`'s is 2). |
| `--ngram-max` / `--ngram-min` | k (integer ≥ 1) | `3` / `1` | serial | `--draft-kind ngram` only: longest/shortest trailing k-gram searched (longest first, first occurrence wins). `--ngram-min` > `--ngram-max` fails startup; either flag without `ngram` warns and is ignored. |
| `--mtp` | `on` \| `off` | `on` for GLM-5.2 | serial+spec | GLM-5.2 checkpoint-native MTP row as the server's drafter, using the bounded auxiliary expert tier and the exact serial verify loop (`usage.lane: "serial+spec"`). `off` removes the draft so ordinary GLM requests can use continuous batching. Other model families ignore it. |
| `--context-length` | tokens (integer ≥ 1) | `4096` (GLM-5.2) | both | Context reserved by GLM-5.2's header-only resource equation; also the request-admission ceiling, reported in `/stats.glm52`. An impossible plan fails before committing model memory. Ignored by other families. |

### Sampling and template defaults

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--thinking` | `true`\|`false` (also `on`/`off`/`1`/`0`) | model's own (`false` for MiniCPM5) | both | Server-wide default for the chat template's `enable_thinking`. Precedence (`resolveEnableThinking`): explicit request `chat_template_kwargs.enable_thinking` → request `reasoning_effort` (`"none"` = off, any other level = on) → this flag → the model's default. With no explicit temperature, a no-think turn is capped at 0.7 while a think turn keeps the model's configured temperature. |
| `--temperature` | n ∈ [0, 5] | `generation_config.json`, else `0.7` | both | Server-wide sampling default; a per-request `temperature` wins; the browser chat (sends none) inherits it. Alias `--temp` (mlx_lm.server spelling — note its *default* there is `0.0`; pass `--temp 0` for that behavior). |
| `--top-p` | n ∈ [0, 1] | `generation_config.json`, else `0` (off) | both | Server-wide top-p default (per-request `top_p` wins). |
| `--top-k` | n ∈ [0, 1e6] | `generation_config.json`, else `0` (off) | both | Server-wide top-k default (per-request `top_k` wins). |
| `--max-tokens` | n ∈ [1, 1e7] | GLM-5.2: `128` (memory-plan reservation); otherwise none — a request that omits `max_tokens` generates until EOS or the admitted context is exhausted (admission clamps to `maxSafeContext − promptLen`; an invented cap ahead of that could only stop work that would have succeeded) | both | Completion cap when a request omits `max_tokens` (mlx_lm.server flag). DEVIATION when unset: `mlx_lm.server` stops a defaulted request at 512 — `--max-tokens 512` reproduces it. For GLM-5.2 the value is also reserved by the pre-open resource equation and must fit inside `--context-length`. Note: `max_tokens` also feeds `--kv-budget` row projections (prompt + cap), so a defaulted request reserves worst-case and batches conservatively — clients that state `max_tokens` pack tighter. |
| `--hlg-sampling` | `on`\|`off` | off | serial / Lab | Piecewise tone-curve (HLG) sampling: rolls off the top-token region, boosts the mids, gentles the tail; the gain folds from `--temperature`. Design: [docs/archive/hlg-sampling.md](../archive/hlg-sampling.md). |
| `--hlg-width` | nats ∈ [0, 100] | `4` | serial | HLG mid-region half-width. Only with `--hlg-sampling on`. |
| `--hlg-shoulder` | nats ∈ [0, 100] | `4` | serial | HLG highlight rolloff scale. Only with `--hlg-sampling on`. |
| `--hlg-toe` | nats ∈ [0, 100] | `6` | serial | HLG shadow rolloff scale. Only with `--hlg-sampling on`. |
| `--hlg-pivot-offset` | nats ∈ [0, 100] | `6` | serial | HLG pivot: nats below the top token. Only with `--hlg-sampling on`. |

### Media and UX

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--allow-private-media` | (bool) | off | serial (media requests) | Let `image_url`/`audio_url`/`video_url` parts fetch from **private/loopback/link-local** hosts. Off by default: a request's URL is attacker-controlled, so `src/media-fetch.ts` refuses non-http(s) schemes and private/loopback/link-local/CGNAT destinations — including hosts that *resolve* there and every redirect hop (SSRF guard). Independent of the flag, every remote fetch has a 10 s timeout and a 64 MB streaming-enforced cap; violations are clean `400`s. `data:` URLs are never policy-checked. Env mirror `MLX_BUN_ALLOW_PRIVATE_MEDIA=1`. |
| `--no-open` | (bool) | off | both | Skip the automatic browser open. By default an interactive TTY opens `http://<host>:<port>/#/chat` once the server is ready; non-TTY runs never open. Parent-only under `--isolate`. |

### Parity tier and kill switches

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--l1` | (bool) | **the default** | serial route / L1 | Tier alias: bit-for-bit identical to mlx-lm — bf16 KV, compiled decode, compiled activations, fused-sdpa off. No tier flag ⇒ `--l1` (decision 2026-07-05). Any per-fork flag below overrides one preset value. |
| `--l2` | (bool) | — | serial route / L2 | Tier alias: bit-for-bit identical to mlx-optiq — `--kv-quant config` + fused N-tiled prefill SDPA + stock unfused decode (the composition the optiq goldens track). |
| `--l3` | — | — | — | **Removed 2026-07-05.** Passing it exits with a pointer to `--l2` / the Lab. |
| `--compiled-decode` | `on`\|`off` | on | serial, and batch at B=1 / L1 | Replay the per-step decode graph in C++ (`MLX_BUN_COMPILED_DECODE`). Bit-exact A/B lever. Gemma4-dense only; LoRA, MoE, and other families run eager, and an unsupported step falls back to eager for the rest of that generation. |
| `--compiled-activations` | `on`\|`off` | on | both / L1 | Route geglu/swiglu through mlx-lm's `@mx.compile` closure (`MLX_BUN_COMPILED_GEGLU` + `MLX_BUN_COMPILED_SWIGLU`) — same libmlx graph as mlx-lm, bit-exact, one dispatch. `off` = the uncompiled composition (same parity, slower). Toggles gemma geglu + MiniCPM5 swiglu; qwen3/qwen3.5/universal compile unconditionally. |
| `--fused-sdpa` | `on`\|`off` | follows `--kv-quant`: on for `config`, off for `4`/`8` and bf16 | serial / L2 | Fused SDPA for quantized-KV prefill/continuation (inverted env `MLX_BUN_NO_FUSED_SDPA`). Defaults to the composition its oracle uses. No-op on bf16. |
| `--force-wire` | (bool) | off | serial | Wire weights into memory for the whole generation (`MLX_BUN_FORCE_WIRE=1`). Near-ceiling models need it. The batch scheduler bypasses `generate()`'s wired scope. |
| `--expert-offload` | (bool) | off | serial / Lab | **MoE only.** Serve experts from a page-aligned file mmap (`<model>/.mlx-bun-offload`, built on first use) — physical footprint ≈ active params. Dense models log "ignored". Bit-exact with the resident path. Env mirror: `MLX_BUN_EXPERT_OFFLOAD=<dir>`. |

The default host/port (`127.0.0.1:8080`) match `mlx_lm.server`, so running
mlx-bun alongside the Python reference needs an explicit `--port`.

## Reproducing mlx_lm.server

Numeric parity (same tokens in → same logits, bit-for-bit) is unconditional
— no flag buys it back and none is needed. **Behavior policy** (defaults,
caps, sampling fallbacks) is mlx-bun's own; mlx_lm.server's policy is one
configuration of it:

```sh
mlx-bun serve <model> --temp 0 --top-p 0 --top-k 0 --max-tokens 512 --batch 1
```

- `--temp 0 --top-p 0 --top-k 0` — mlx_lm.server does not read
  `generation_config.json` (we inject its sampling defaults, optiq-style);
  its unset-request defaults are temperature 0.0, top-p/top-k off.
- `--max-tokens 512` — its cap when a request omits `max_tokens` (ours is
  none: run to EOS or the admitted context). Note a defaulted mlx-bun run's
  first 512 tokens are byte-identical to mlx-lm's capped run — the cap only
  moves the stopping point and `finish_reason`.
- `--batch 1` — strict serial, arrival-independent numerics. (`--batch N`
  is itself bit-parity with mlx-lm at B=N; pin 1 for golden regeneration.)
- Already matching without flags: host/port, bf16 KV (`--kv-quant off`),
  the L1 kernel preset (`--l1` is the default), logprobs caps, error text.

The kill switches are bit-exact A/B levers; **the naked default is the L1
set** (2026-07-05: an output-changing lever earns a default only by beating
the L1 baseline in a paired A/B, and none did — the losing kernels were
deleted, Phase 1 of
[unified-engine-frontier-plan.md](../design/unified-engine-frontier-plan.md)).
They are installed as `MLX_BUN_*` runtime values before the model loads,
so they apply to `mlx-bun pi` too. They affect the **serial** decode path;
the batch scheduler drives `model.forwardHidden` directly and is unaffected
except by `--compiled-decode` at B=1 — see
[Levers that don't reach the batched lane](#--batch-n-is-compat-mode--perf-flags-dont-apply-by-design).

## `--isolate` semantics

Design and measurements: [docs/reference/server-config.md](./server-config.md)
(P1 single engine and P2 model pool landed). What the flag does, from
`src/serve/isolate.ts` and the `serve` handler in `src/cli.ts`:

- **Process layout.** The parent binds the TCP `--host`/`--port` and makes
  zero MLX calls. It re-execs itself as `serve` with the same argv minus
  the **parent-only flags** (`--isolate`, `--port`, `--host`, `--model-pool`,
  `--no-open`), the model selectors replaced by a pinned `--model <path>`,
  plus `--unix <socket>` (socket under the OS temp dir, named by parent
  pid). Every other flag and every exported `MLX_BUN_*` variable reaches
  the engine child unchanged (`env: process.env`); the child's stdout/stderr
  are inherited, so load progress prints in your terminal.
- **Readiness.** The parent polls the child's `/health` over the socket
  (up to 15 minutes — large models take a while) and prints "engine ready
  pid N". Requests arriving earlier wait on that readiness.
- **Proxying.** Every HTTP request is forwarded verbatim over the unix
  socket (hop-by-hop headers stripped, SSE streams through, a client
  abort aborts the proxied fetch so the engine sees the disconnect).
  `GET /engine` answers from the parent:
  `{ isolated: true, pid, restarts, socket, pool?: { resident, default } }`.
  `/ws/chat` is **not proxied** — `501` with a pointer to run without
  `--isolate` for the web chat UI.
- **Crashes.** A child exit (uncatchable Metal OOM/SIGTRAP included) is
  respawned automatically (`restarts` increments); an engine that dies
  within 10 s of spawning waits 5 s before the retry. In-flight requests
  get `502 { error: { type: "engine_unavailable" } }`; bodyless `GET`/`HEAD`
  requests are retried once after the respawn. A request whose client
  disconnected answers `499`.
- **Model pool (`--model-pool n`).** `POST` bodies on `/v1/chat/completions`,
  `/v1/completions`, `/v1/messages`, `/v1/responses`, `/v1/embeddings` are
  buffered to read `model`. An **exact** registry id (`/v1/models` id)
  spawns/routes to that model's own child; anything else — empty, fuzzy,
  `"gpt-4"`-style — rides the default engine (mlx-lm's ignored-field
  semantics). Eviction over the cap: `POST /admin/drain` on the victim's
  socket (gateway quiesce + demote its prompt cache to the SSD tier),
  then stop; `/admin/drain` is unix-socket-only, never on the TCP
  listener. `--model-pool` is clamped to ≥ 1.
- **Shutdown.** `SIGINT`/`SIGTERM` on the parent stops every child and
  unlinks the sockets.

## Near-ceiling models on small machines (24 GB)

A model whose weights approach the default macOS GPU wired ceiling (~75%
of RAM) loads and serves short prompts, but a long prefill can exceed the
ceiling and die with an **uncatchable** Metal OOM. `mlx-bun serve` checks
this at startup (model bytes > 80% of `maxRecommendedWorkingSetSize` while
`iogpu.wired_limit_mb` is at its default) and prints the remedy:

```
sudo sysctl iogpu.wired_limit_mb=<RAM_MB - ~2500>   # resets on reboot
```

For very long contexts on such machines, additionally prefer `--kv-quant`
(e.g. `turbo`) — the prefill transient scales with chunk size × context.

## Per-request overrides

Most quality knobs can be set per request in the chat body and override
the server-wide default. Precedence, highest first:

1. explicit request field (`temperature`, `top_p`, `top_k`, `seed`,
   `min_p`, `xtc_probability`/`xtc_threshold`, `logit_bias`,
   `repetition_penalty`, `presence_penalty`/`frequency_penalty` (+ their
   `*_context_size` windows), `max_tokens`/`max_completion_tokens`, `stop`,
   `chat_template_kwargs.enable_thinking`, `reasoning_effort`, `adapter`,
   `tools`)
2. the matching `--temperature`/`--top-p`/`--top-k`/`--thinking`/`--max-tokens`
   server default
3. the model's `generation_config.json`
4. the built-in fallback (temperature 0.7, top-p/top-k 0 = off)

These ride all three protocol surfaces (`/v1/chat/completions`,
`/v1/messages`, `/v1/responses`) because each funnels through one
chat stage (`src/serve/chat-stage.ts`). Full field list: [server-api.md](./server-api.md).

## Environment variables

All `MLX_BUN_*` variables are captured once at process start into an
immutable snapshot (`src/runtime-config.ts`); CLI flags install overrides
into the same snapshot before the model loads. Boolean levers read the
literal strings `"1"`/`"0"` — `flagOn` treats any other value as unset.
Under `--isolate` the whole environment is inherited by the engine child.

### Serving levers (flag-backed and lane kill switches)

| Env var | CLI flag | Default | Effect |
| --- | --- | --- | --- |
| `MLX_BUN_COMPILED_DECODE` | `--compiled-decode` | on (`"0"` disables) | Compiled decode graph replay (serial lane; batch lane at B=1). |
| `MLX_BUN_NO_FUSED_SDPA` | `--fused-sdpa` (inverted) | follows `--kv-quant` | `=1` forces the stock unfused SDPA everywhere. |
| `MLX_BUN_COMPILED_GEGLU` | `--compiled-activations` | on (`"0"` disables) | Gemma geglu via mlx-lm's `@mx.compile` closure. `=0` → uncompiled composition (same parity, slower). |
| `MLX_BUN_COMPILED_SWIGLU` | `--compiled-activations` | on (`!== "0"`) | Compiled SwiGLU on MiniCPM5 decode (M=1). qwen3/qwen3.5/universal compile unconditionally. |
| `MLX_BUN_FORCE_WIRE` | `--force-wire` | off (`=1`) | Wire weights for the generation. |
| `MLX_BUN_PAGED_KV` | `--paged-kv` | off (`=1`) | Paged KV cache; the same refusals and prompt-cache bypass as the flag. |
| `MLX_BUN_ALLOW_PRIVATE_MEDIA` | `--allow-private-media` | off (`=1`) | Permit media fetches to private/loopback/link-local hosts (timeout + size cap still apply). |
| `MLX_BUN_EXPERT_OFFLOAD` | `--expert-offload` | off | `=<dir>` — the path of a built expert-offload file, activated at module load (`src/expert-offload.ts`) for scripts and library runs that never parse serve flags. The CLI flag builds the file and activates it itself. |
| `MLX_BUN_PREFILL_TAIL_SPLIT` | — | on (`"0"` disables) | Oracle prefill convention: drain the prompt to len−1, then compute step-0 logits from a separate L=1 forward of the last prompt token (mlx-lm `generate_step` and its batched engine). Both lanes. The spec lane follows its own oracle's shape under the same flag (mlx-lm `speculative_generate_step`: target and draft drain to len−1, no separate step 0). `=0` restores the full-final-chunk convention everywhere — ulp-different at step 0, flips near-tie greedy streams vs mlx-lm. |
| `MLX_BUN_GRAMMAR` | — | on (`"0"` disables) | `=0` disables structured-output mask compilation; requested constraints take the graceful-degrade route (chat prompt injection + a `Warning` header; raw completions header only). |
| `MLX_BUN_GRAMMAR_JUMP` | — | **off** (`=1`) | Jump-forward decoding for structured output (SGLang's technique via xgrammar's `findJumpForwardString`): when the grammar forces a unique continuation, the **serial** lane emits its retokenized ids with one multi-token forward. Lossless in string space and always grammar-valid, but the token stream can legally differ from an unjumped run — no oracle, hence opt-in. Skipped when `logprobs`/`top_logprobs` is requested; SentencePiece-family tokenizers that can't reproduce a mid-stream span never jump. The batch lane does not jump. |
| `MLX_BUN_FILL` | — | **off** (`=strict` \| `=echo`) | **Token fast-forwarding** — lookup, not speculation. Spans of the assistant turn that the request's `tools` + the chat template already DETERMINE (tool-call open scaffold, the rest of a tool name after its first disambiguating token, a sole-required-key skeleton) are appended by the engine itself in ONE multi-token forward, and sampling resumes after them. No draft, no verify, no rollback — an injected token is context, indistinguishable to the model from one it sampled. Rows are compiled per request by diffing probe renderings of the model's OWN template, always sliced from a rendering carrying the REAL tool names and schema keys (so a span can never split a merged token such as Qwen3.5's `=get`), so a template that does not render `tool_calls` yields no rows and no fill. **Serial lane only** (it never forces a request off the batch lane) and refused for: fixed `seed`, `logprobs`/`top_logprobs`, structured output (grammar owns forced tokens), image/audio/video prompts, a mounted draft model, quantized/TurboQuant KV, and sliding-window models (one warning). Injection bypasses the sampler — a behavior-policy deviation at `temperature > 0` — hence opt-in. `=echo` additionally arms the **echo index** (Lab tier): spans copied from earlier in the same session, held under policy `verify` — the engine appends them in the same single forward, reads the argmax already in that forward's logits at every span position (free, no extra pass), keeps the prefix the model agrees with, and rewinds the rest through the same cache contract the spec lane's rounds use. A wrong echo costs a rewound forward, never a wrong token. Strict rows stay policy `assert` (no readback, no checkpoint). Telemetry: `usage.fill`. |
| `MLX_BUN_FILL_MAX_SPAN` | — | `32` (floor 2) | Hard cap on one injected span. |
| `MLX_BUN_FILL_K` | — | `8` (floor 2) | Echo anchor length: the k-gram that must match before a copied span is proposed (the corpus study's token-level threshold). |
| `MLX_BUN_FILL_CANDIDATES` | — | `24` | Echo bucket-scan cap — the NEAREST occurrences of the anchor win. A span extends only while every one of them agrees; the first disagreement (a **branch point**) ends it. |
| `MLX_BUN_FILL_INDEX_MAX` | — | `131072` (floor 1024) | Token cap on the growing echo index; past it the index freezes rather than growing. |
| `MLX_BUN_FILL_TRACE` | — | off (`=1`) | Assert the fill cache-alignment invariant (`cache offset == prompt + forwarded`) on both sides of every append, and log each event. |
| `MLX_BUN_GRAMMAR_BATCH` | — | on (`"0"` forces serial) | `=0` routes grammar requests to the serial lane instead of per-row batch matchers (A/B + kill switch). |
| `MLX_BUN_BATCH_SSM` | — | on (`"0"` forces serial) | `=0` excludes SSMCache (Qwen3.5 gated-DeltaNet hybrids) from the batch capability gate → those models route serial. |
| `MLX_BUN_BATCH_EXTEND` | — | on (`"0"` reverts) | Joining rows append to the running batch's KV in one pad+concat (mlx-lm `BatchKVCache.extend`). `=0` reverts to whole-batch re-merge (numerically equivalent, O(B·S)). |
| `MLX_BUN_BATCH_VEC_SAMPLE` | — | on (`"0"` reverts) | Vectorized greedy batch sampling; `=0` falls back to per-row sampling (bit-equal A/B). |
| `MLX_BUN_BATCH_NO_PIPELINE` | — | off (`=1`) | Read each batch step's tokens synchronously instead of pipelined (A/B lever; numerically equivalent, slower). Read once at module load. |
| `MLX_BUN_SSD_WRITEBEHIND` | — | on (`"0"` disables) | `--ssd-cache`'s debounced, idle-gated write-behind snapshot (restart survival). `=0` disables it — eviction/demotion spills still write. |
| `MLX_BUN_SSD_SPILL_QUEUE_GB` | — | `2` (GiB; any finite value ≥ 0) | Byte cap on pending write-behind spill clones (they pin evicted entries' GPU memory until the idle-gated flush runs). Over cap the oldest queued spill drops and frees immediately; the durability coordinator keeps its snapshot dirty so an explicit or shutdown flush can retry. `=0` keeps only the newest + in-flight clone pinned. Counters in `/stats.ssd_cache`. |
| `MLX_BUN_SHUTDOWN_TIMEOUT_MS` | — | `120000` (any finite value > 0) | Maximum time `serve` gives active requests plus the SSD durability flush after `SIGINT`/`SIGTERM`; on timeout it logs the remaining snapshot/spill counters and exits. |
| `MLX_BUN_DSPARK_MINCONF` | — | checkpoint-driven | Overrides the DSpark/DeepSpec draft scheduler's minimum-confidence threshold (draft-length pruning). Spec lane only ([docs/design/speculative-decoding.md](../design/speculative-decoding.md)). |
| `MLX_BUN_MEMORY_BATCH` | — | `1` (integer ≥ 1) | Row width for `mlx-bun memory` model calls. 1 = serial (batching measured 1.7–1.9× slower on the heterogeneous extract/chunk workload — [docs/design/dreaming-nightly-pipeline.md](../design/dreaming-nightly-pipeline.md)). |

### Paths and tooling

| Env var | Default | Effect |
| --- | --- | --- |
| `MLX_BUN_LIBMLXC` | resolved: beside the executable → native-pack cache (`~/Library/Caches/mlx-bun/native-v<ver>-<arch>/`) → Homebrew | Explicit path to `libmlxc.dylib`; its directory is then the native runtime dir (`src/mlx/ffi.ts`, `src/native-pack.ts`). |
| `MLX_BUN_NATIVE_PACK_URL` | the GitHub release asset for `NATIVE_PACK_VERSION` | Override the native runtime pack download URL (first-run fetch, sha256-verified). |
| `MLX_BUN_FRAME_EXTRACT` | resolved: beside the executable → native-pack cache → `dist-native/` → compile from `src/native` | Explicit path to the `mlx-bun-frame-extract` AVFoundation sidecar used for video input. |
| `MLX_BUN_EXPERT_IO_DYLIB` | resolved: beside the executable → native-pack cache → `dist-native/` | Explicit path to `libmlx_bun_expert_io.dylib` (GLM-5.2 streamed expert I/O). |
| `MLX_BUN_WIKI` | `~/.mlx-bun/wiki` | Root of the memory vault (`~` expands). |
| `MLX_BUN_JOBS_DB` / `MLX_BUN_JOBS_DIR` | the `JobStore` defaults | Job-store SQLite path and logs dir. The job runner sets both on the subprocess it spawns so the child opens the same store; override for tests. |
| `MLX_BUN_CALIBRATION_JSONL` | bundled optiq mix in the oracle venv | Explicit calibration corpus for `mlx-bun convert`/quantize. |
| `MLX_BUN_ORACLE_PYTHON` | `/Users/joshrossi/Code/mlx-lm/.venv/bin/python` (the reference box; machine-specific, never re-commit) | Oracle venv interpreter for evals that shell out to Python (HumanEval). |
| `MLX_BUN_EVAL_DATA` | `~/.cache/mlx-bun/eval-data` | Directory of exported eval `.jsonl` datasets. |

### Diagnostics and tracing (off unless set)

| Env var | Value | Effect |
| --- | --- | --- |
| `MLX_BUN_P2R_TRACE` | `=1` | Per-request prompt→response phase trace (admission wait, prefill, token-zero, …) for `/v1/chat/completions` and `/v1/completions`; records print to stderr as JSON lines. The trace id is `x-mlx-bun-trace-id` when the request sends it. |
| `MLX_BUN_P2R_SYNC` | `=1` (with `MLX_BUN_P2R_TRACE`) | Attribution mode: synchronizes the GPU at phase boundaries so each phase is charged its own work (MLX is lazy — without it, unsubmitted work lands in the next phase). Slows the traced request. |
| `MLX_BUN_LANE_DEBUG` | `=1` | Logs each request's scheduling placement (`mechanism` + shape) to stderr. |
| `MLX_BUN_BATCH_STEP_TRACE` | `=1` | Per-step phase timing in the batch scheduler (build / read / emit / gap), read once at module load; summarized by `stepTraceReport()`. |
| `MLX_BUN_GRAMMAR_DEBUG` | `=1` | Logs per-step grammar row state in the batch scheduler. |
| `MLX_BUN_PREFILL_MEM_LOG` | `=1` | Logs active/peak memory after each serial prefill chunk. |
| `MLX_BUN_EXPERT_TRACE` | `=<path>` | Records every MoE router decision as JSONL to that path (adds a per-call GPU→host sync — a measurement tool, not a serving path). |
| `MLX_BUN_PI_DEBUG` | any non-empty | Extra `[pi-web]` logging (prompt fingerprint, tool/memory surface) for the web-chat pi session. |
| `MLX_BUN_EVAL_DEBUG` | `=1` | HumanEval: pipe the sandbox's stderr and print failures. |

### Eval and training

| Env var | Default | Effect |
| --- | --- | --- |
| `MLX_BUN_EVAL_THINK` | off (`=1`) | Evaluate with `enable_thinking` on (default off for parity with optiq's published non-thinking numbers). |
| `MLX_BUN_EVAL_KV_QUANT` | off (`=1`) | Generate through the model's `kv_config.json` quantized KV during evals (default full-precision KV, matching optiq's eval). An explicit `--kv-quant` on `mlx-bun eval` wins. |
| `MLX_BUN_MMLU_FROZEN` / `MLX_BUN_GSM8K_FROZEN` / `MLX_BUN_HUMANEVAL_FROZEN` / `MLX_BUN_IFEVAL_FROZEN` / `MLX_BUN_BFCL_FROZEN` / `MLX_BUN_HASHHOP_FROZEN` | on (`"0"` reverts) | Use the frozen oracle-exported problem sets (parity with the reference numbers); `=0` falls back to our own sampling of the full set. |
| `MLX_BUN_TRAIN_ATTN` | `ops.sdpa` (unset) | `=flash` selects the hand-rolled O(L)-memory flash kernel for training attention (~30× slower). **Refused for Gemma models** (e4b SIGTRAPs at seq ≥ 2048); MiniCPM5 allowed. |
| `MLX_BUN_FLASH_MIN_M` | `1024` | With a flash-CCE head requested, rows shorter than this take the exact fused head instead; `=0` always honors flash. |
| `MLX_BUN_MEM_LOG` | off (`=1`) | Trainer per-step memory logging. |

`MLX_BUN_CCE_*` (flash-CCE kernel variant selectors and epsilons in
`src/train/flash-cce.ts`) and `MLX_BUN_SEG_*` (segmented-backward head and
memory probes in `src/train/segmented.ts`) are intentionally undocumented
developer knobs; `MLX_BUN_EVAL_KV_ARM_NOOP` is an inert placeholder the KL
harness flips.

### Removed

`MLX_BUN_PERF_KERNEL`, `MLX_BUN_FUSED_GELU`, `MLX_BUN_FUSED_DECODE`,
`MLX_BUN_FUSED_SWIGLU*`, `MLX_BUN_CPM5_FAITHFUL`, and the `--l3` tier were
deleted 2026-07-05 with their kernels
([unified-engine-frontier-plan.md](../design/unified-engine-frontier-plan.md));
exporting the variables now does nothing, and `--l3` exits with a pointer.

## Execution modes: serial vs. `--batch N`

Scheduling is **concurrency-driven** (default cap 8): a lone scheduler
request uses the B=1 fast path — its caches are adopted serial-class
objects, compiled decode replays, and the prompt cache and SSD tier serve
it. Only a second concurrent request causes a batch layout to exist. The
flag declares the concurrency cap; active rows select B=1 or B=N inside
the scheduler.

`--batch 1` pins the strict serialized single-queue path: one generation
at a time, arrival-independent numerics (a request's bits never depend on
what else was in flight). Pin it for golden regeneration and
reproducibility work. Batched rows carry bf16 left-pad reduction-order
noise vs their solo runs (calibrated per model in the gated suites) — a
request that never shares a step is bit-identical either way.

The batched engine is **bit-parity with `mlx_lm.server` at `B=N`** per
row for bf16, and per-row oracle-gated for the quantized compositions:

- **KV quant unset ⇒ bf16** — the batch path engages out of the box.
- **`--kv-quant config`** (per-layer mixed precision) **batches** on
  every shipped model — full-attention and rotating layers — applied per
  row, gated bit-exact for unpadded rows vs the serial composition.
- **`--kv-quant 4|8`** (uniform bits) and **`turbo`** route those
  requests to the serial lane.

### Scheduling declaration (`GenerationGateway.place`)

With a cap greater than one, `GenerationGateway.place()` freezes one
scheduling mechanism for the exact resolved request shape: `continuous`
admits it to the scheduler (which then picks B=1 or B=N from active rows);
`serial` preserves the strict executor. The support check never removes,
downgrades, or substitutes MTP, KV schemes, TurboQuant, grammar, adapters,
or sampling — a composition the scheduler does not implement drains it and
runs unchanged serially. The two mechanisms are mutually exclusive on the
GPU (one `AsyncMutex`).

| Request property | Continuous scheduler? |
| --- | --- |
| vision / audio / video parts | ❌ serial — offset-0 single-sequence prefill + media masks |
| LoRA `adapter` (resolves to ≥1) | ❌ serial — one active adapter per generation |
| `logprobs` / `top_logprobs` | ❌ serial — the batched sampler doesn't capture logprob arrays |
| explicit `seed` | ❌ serial — reproducibility ⇒ solo (matches mlx-lm) |
| KV quant active | ✅ batches for per-layer `config` schemes; uniform bits → serial |
| `--kv-quant turbo` | ❌ serial, unconditionally (novel `Cache` class, no batched merge/filter; explicit refusal in placement on top of the capability gate) |
| `--draft-model` mounted | ❌ serial, server-wide (`is_batchable = draft is None`) |
| `repetition_penalty` / `min_p` / `xtc_*` / `logit_bias` / presence+frequency penalties | ✅ batches — per-row logits processors over per-row device-side history (Qwen3.5 ships a *default* repetition penalty, so this is load-bearing) |
| structured output (`response_format` / `guided_*`) | ✅ batches — per-row grammar matchers (`MLX_BUN_GRAMMAR_BATCH=0` forces serial) |
| `temperature` / `top_p` / `top_k` | ✅ batches (each row samples with its own seed) |
| `stop` sequences | ✅ batches (per-row `StopMatcher`) |
| `tools` / `tool_choice` | ✅ batches (per-row tool router) |
| `--thinking` / `enable_thinking` | ✅ batches (template-render concern) |
| multi-turn / long prompt | ✅ batches with prompt-cache reuse: a joiner restores the longest usable cached prefix and prefills only the suffix (`cached_tokens` reported) |

**Which models use continuous scheduling** (`#modelCachesBatchable`):
full-attention (CPM), sliding-window (Gemma), hybrid gated-DeltaNet
(Qwen3.5 — `MLX_BUN_BATCH_SSM=0` reverts to serial routing), and plain
full-attention Tier-0 universal archs (Llama etc., gated token-exact vs
mlx-lm B=2). Still serial by the capability gate: gemma2-family
(`maskArray`) and sliding-window *universal* archs (unvalidated cells) and
DiffusionGemma (non-autoregressive).

A request requiring the serial mechanism **drains** the scheduler: while
it waits, the scheduler stops admitting new rows, finishes the running
ones, and releases the GPU (mlx-lm's `drain_batch`); admission then
resumes, so batchable traffic cannot starve a serial-lane request.
Placement is not load-dependent: a request admitted to the continuous
scheduler stays there whether it is the only row or one of many.

## Compatibility matrix

"serial" = `--batch 1`; `--batch N` permits continuous scheduling, though a
declared composition may still require the serial mechanism as shown above.

| Option | serial (`--batch 1`) | `--batch N` (N>1) |
| --- | --- | --- |
| `--kv-quant config` | ✅ applied to all requests | ✅ batches where the loaded cache capability supports the per-layer scheme; otherwise routes serial |
| `--kv-quant 4`/`8` | ✅ applied to all requests | ⚠️ uniform-threshold semantics route requests serial |
| `--kv-quant turbo[:k<bits>v<bits>]` | ✅ applied to all requests | ⚠️ applied, but forces **all** requests to the serial lane |
| `--kv-quant off` / unset | ✅ bf16 (the L1 default) | ✅ bf16 |
| `--paged-kv` | ✅ (pinned here by default) | ❌ startup refusal |
| `--memory-budget` | ✅ per-request admission | ✅ per-request admission — not aggregate (use `--kv-budget`) |
| `--kv-budget` | n/a | ✅ aggregate queue/reject across rows |
| `--prompt-cache` / `--ssd-cache` | ✅ prefix reuse + SSD restore | ✅ on both lanes: joiners `take()` at admission; never-merged rows `put()` back |
| `--temperature`/`--top-p`/`--top-k` | ✅ | ✅ (per-row) |
| `--thinking` | ✅ | ✅ |
| vision / audio / video request | ✅ | ✅ via serial lane |
| LoRA `adapter` | ✅ | ✅ via serial lane |
| `repetition_penalty` / `min_p` / `xtc_*` / `logit_bias` / presence+frequency | ✅ | ✅ (batches — per-row processors) |
| `seed` | ✅ | ✅ via serial lane |
| `tools` / `stop` | ✅ | ✅ (batches) |
| structured output (`response_format`/`guided_*`) | ✅ (mask in the decode loop) | ✅ (batches; per-row matchers) |
| `--draft-model` / `--draft-kind` | ✅ spec decode (grammar composes) | ⚠️ mounts, but routes **every** request serial |
| GLM `--mtp on` | ✅ native MTP spec decode | ⚠️ default-on MTP routes every request serial+spec; `--mtp off` exposes ordinary GLM batching |
| `--compiled-decode` | ✅ | ✅ at **B=1 only**: a lone request's adopted serial-class caches replay the same compiled step; B>1 steps run the plain graph |
| `--fused-sdpa` / `--force-wire` | ✅ (serial decode route) | n/a — compat mode, no perf flags by design |

### `--batch N` is compat mode — perf flags don't apply by design

The bit-parity guarantee (mlx-lm B=N) is the *whole point* of `--batch N`,
and it requires running the plain forward path. The scheduler
([batch-scheduler.ts](../../src/serve/batch-scheduler.ts)) drives the
model through `forwardHidden`/`logitsFromHidden` directly (not
`generate()`), so:

- **`--compiled-decode`** engages at **B=1 only** (adopt-don't-copy: the
  lone request's caches stay serial-class, so the scheduler replays the
  serial engine's compiled step — same kill switch). A second row ⇒ the
  plain batched graph.
- **`--fused-sdpa`** never engages in the batched lane (an L2 serial-lane
  composition).
- **`--force-wire`** doesn't wire (the scheduler bypasses `generate()`'s
  wired scope).
- **Always-on bit-exact kernels still run.** The compiled activations are
  bit-exact with the spelled-out MLP, so they stay on in both lanes —
  "compat mode" means *no parity-breaking optionality*, not -O0.

## Known limitations under `--batch N`

Deliberate v1 scope, not bugs:

1. **Prompt cache on the SPEC path is bypassed.** A `--draft-model`
   server re-prefills every request (the target+draft cache-entry
   composition is designed in mlx-lm-tool-parity-plan §7.6, not built).
2. **Aggregate admission is opt-in** via `--kv-budget`; without it N
   large-context rows can collectively exceed memory.
3. **Short-context only.** Verified pre-ring-wrap (rows < the 1024 sliding
   window); long-context batched decode is a separate validation.
4. **bf16 by contract; mixed-KV batching beyond it.** mlx-lm's batched
   path *is* bf16. Per-layer `config` batching is a beyond-mlx-lm
   composition verified per row against the optiq oracle. Batched
   uniform/turbo KV has no oracle and is deferred.
5. **`extend` join** appends a joining request to the running batch's
   full-attention KV in one pad+concat (`MLX_BUN_BATCH_EXTEND=0` reverts
   to whole-batch re-merge); sliding-window layers still re-merge on join.

## Fidelity tiers and the decode route (`--l1` / `--l2`)

The tiers are **correctness contracts**; each flag is an alias for a
decode-route preset (`applyDecodeRoute()` in `src/cli.ts`), and any
per-fork flag (`--kv-quant`, `--compiled-decode`, `--compiled-activations`,
`--fused-sdpa`) overrides its tier's preset.

| Tier | Contract | KV | Kernels | Verified against |
| --- | --- | --- | --- | --- |
| `--l1` | mlx-lm **bit-for-bit** | bf16 | compiled decode + compiled activations, fused-sdpa off | mlx-lm goldens (per machine) |
| `--l2` | mlx-optiq **bit-for-bit** | mixed precision (`kv_config.json`) | + fused SDPA (matches optiq exactly) | optiq goldens |
| *(none)* | **= `--l1`** | bf16 | as `--l1` | mlx-lm goldens |
| **Lab** | no external oracle | — | env-flagged experiments with a bench + expiry; graduate only by beating L1 in a paired A/B | validity / KL / eval gates |

Compiled decode is on in **every** tier (proven bit-exact with uncompiled —
free speed, not a fidelity trade). **There is no `--l3` tier** (removed
2026-07-05; its role is the Lab).

**KV precision is a separate axis from the tier's kernels.** `--l1
--kv-quant 8` is a bit-exact L1 config: with fused-sdpa off our quantized
decode runs `quantizedSdpaUnfused`, op-for-op mlx-lm's
`quantized_scaled_dot_product_attention` (`mlx_lm/models/base.py`). Only
the per-layer `config` scheme is optiq-only (→ L2).

**Where each feature sits:** batching = L1-class (mlx-lm B=N parity);
two-model speculative decoding = L1-class; structured output = L2-class
(oMLX oracle; masking doesn't touch the numerics of valid tokens, so it
composes with any tier); grammar × spec, HLG sampling, expert offload,
TurboQuant's cache class, jump-forward decoding, and batched
uniform/turbo KV are **no-oracle (Lab-gated)**.

## Feature matrix

Everything mlx-bun serves, with its default, lane, fidelity tier, and knob.

### Serving & performance

| Feature | Default | Lane | Tier | Knob |
| --- | --- | --- | --- | --- |
| OpenAI chat completions (`/v1/chat/completions`, SSE) | on | both | — | — |
| Raw text completions (`/v1/completions`) | on | both | — | — |
| Anthropic Messages (`/v1/messages`) | on | both | — | — |
| OpenAI Responses shim (`/v1/responses`) | on | both | — | — |
| Continuous batching (mlx-lm parity at the same B) | on, cap 8 | batch | L1 | `--batch <n>` (`1` pins serial) |
| Prompt cache (prefix KV reuse) | on, 8 GiB | both | — | `--prompt-cache <GB>` (`0` = off) |
| SSD KV cold tier (survives eviction + restarts; GLM compressed MLA/DSA state included) | off | both | — | `--ssd-cache <dir>` (+ `--ssd-cache-max`, `--ssd-cache-verify`, `--ssd-demote-idle`) |
| Runtime isolation (crash-isolated engine child behind a proxy parent) | off | both | — | `--isolate` |
| Model pool (LRU-capped resident engines under `--isolate`) | 1 | both | — | `--model-pool <n>` |
| Mixed-precision KV (`kv_config.json`, optiq's scheme) | off | serial + batch (per-layer configs batch) | L2 | `--kv-quant config`, `--l2` |
| Uniform quantized KV (mlx-lm's `--kv-bits` scheme) | off | serial | L1 | `--kv-quant 4\|8` |
| TurboQuant KV (rotation-based: affine keys + FWHT/Lloyd-Max values) | off | serial only (solo) | Lab (codec oracle-backed vs vllm-metal; cache class unvalidated) | `--kv-quant turbo[:k<bits>v<bits>]` (default `k8v3`) |
| Compiled decode (bit-exact graph replay) | on | serial, batch at B=1 | L1/L2 | `--compiled-decode on\|off` |
| Compiled activations (mlx-lm's `@mx.compile` geglu/swiglu) | on | both | L1 | `--compiled-activations on\|off` |
| Fused SDPA (optiq-exact quantized-KV attention) | follows `--kv-quant` | serial | L2 | `--fused-sdpa on\|off` |
| Paged KV (vLLM-style block pool, gather before the stock SDPA) | off | serial (pins `--batch 1`) | gated bit-exact vs plain `KVCache` | `--paged-kv`, `--paged-kv-block-size <n>` |
| Speculative decoding (two-model / Gemma `-assistant` / DSpark / DeepSpec / native MTP head) | off | serial (forces all-serial) | per-drafter oracle (L1 two-model, L2 assistant, DeepSpec reference, Lab DSpark) | `--draft-model`, `--draft-kind`, `--num-draft-tokens` |
| GLM-5.2 checkpoint-native MTP | on for GLM-5.2 | serial+spec | oracle trajectory + synthetic HTTP gate | `--mtp on\|off` |
| Model-free prompt-lookup speculation (vLLM `ngram` port) | off | serial (forces all-serial) | lossless by verify (gated vs non-spec greedy) | `--draft-kind ngram`, `--ngram-max`, `--ngram-min`, `--num-draft-tokens` (default 10) |
| Memory admission (never GPU-OOM) | on (RAM × 0.75) | both | — | `--memory-budget <GB>` |
| Aggregate KV admission for batch rows | off | batch | — | `--kv-budget <GB>` |
| Expert offload (MoE experts on mmap) | off | serial | Lab | `--expert-offload` |
| Extend-join (O(1) batch admission) | on | batch | L1 (mlx-lm `extend`) | `MLX_BUN_BATCH_EXTEND=0` |
| Vectorized greedy batch sampling | on | batch | bit-equal A/B | `MLX_BUN_BATCH_VEC_SAMPLE=0` |
| Pipelined batch token readback | on | batch | numerically equivalent | `MLX_BUN_BATCH_NO_PIPELINE=1` |

### Request features

| Feature | Default | Lane | Tier | Knob |
| --- | --- | --- | --- | --- |
| Structured output (`response_format` json_object/json_schema) | on | both | L2 (oMLX) | request field; `MLX_BUN_GRAMMAR=0` kills |
| Structured-output jump-forward (grammar-forced spans in one forward) | off | serial only | Lab | `MLX_BUN_GRAMMAR_JUMP=1` |
| Token fast-forwarding for tool calls (template-determined spans in one forward) | off | serial only | token-identical by construction (weights gate: `tests/parity/fill-strict.test.ts`) | `MLX_BUN_FILL=strict` |
| Echo injection (session self-copy spans, verified against the same forward's logits) | off | serial only | Lab (paired A/B on task success + wall clock before any default) | `MLX_BUN_FILL=echo`, `MLX_BUN_FILL_K`, `MLX_BUN_FILL_CANDIDATES`, `MLX_BUN_FILL_INDEX_MAX` |
| `guided_grammar` (EBNF) / `guided_regex`¹ / `guided_choice` / `structured_outputs` | on | both | L2 | request fields |
| Structured output × speculative decoding | on when both active | serial | Lab | — |
| Quantized KV × speculative decoding | KV scheme wins — drafted requests decode serially without speculation (startup warning) | serial | — | omit `--kv-quant` to speculate |
| Tool calling (Gemma sentinel / CPM+Qwen XML / GLM `arg_key`+`arg_value`) + `role:"tool"` loops | on | both | — | request `tools` |
| Vision (`image_url`; PNG/JPEG/HEIC/AVIF/WebP/TIFF/GIF/BMP) | on for models with a tower; SSRF guard on remote URLs | serial | L1/L2 | `--allow-private-media` |
| Video input (`video_url`/`video`; AVFoundation sidecar, 2 fps, ≤768 frames, 256 MB body cap; never with audio) | on for Qwen3.5-family | serial | mlx-vlm oracle | `--allow-private-media`, `MLX_BUN_FRAME_EXTRACT` |
| Audio input (`input_audio`/`audio`/`audio_url`; WAV native, mp3/m4a/flac/ogg/aiff via CoreAudio; ≤30 s per clip; mixes with images) | on for models with `audio_config` + sidecar tower (e4b) | serial³ | L2 (greedy stream exact vs optiq's internal model) | `--allow-private-media` |
| LoRA adapters (mount at start / hot-swap) | off | serial | — | `--adapter <dir>`, `POST /v1/adapters` |
| Sampling: temperature / top-p / top-k / min-p / XTC / logit_bias / presence+frequency+repetition penalties | per request | both | L1 (mlx-lm-faithful) | request fields / server defaults |
| `logprobs` / `top_logprobs` | off | serial | L1 | request fields |
| Fixed `seed` reproducibility | off | serial | — | request field |
| Thinking-mode control (hybrid-reasoning models) | model default | both | — | `--thinking`, `chat_template_kwargs`, `reasoning_effort` |
| Stop sequences / streaming / usage accounting | on | both | — | request fields |
| HLG tone-curve sampling | off | serial | Lab | `--hlg-sampling on` |
| Spec-decode telemetry (`usage.speculation`) | on with a draft | serial | — | — |
| Token-fast-forwarding telemetry (`usage.fill`) | on with `MLX_BUN_FILL=strict` | serial | — | — |
| Per-turn lane telemetry (`usage.lane`: serial / serial+spec / batched) | on | both | — | — |

### Model coverage (per-model validated cells)

| Family | Serial | Batch | Notes |
| --- | --- | --- | --- |
| MiniCPM5 (cpm5) | ✅ L1/L2 | ✅ | the starter model |
| Gemma 4 (1B/e4b/12B/26B, + vision e4b/12B, + audio e4b) | ✅ L1/L2 | ✅ | sliding+full interleaved; MoE 26B |
| Qwen3.5 (gated-DeltaNet hybrid) | ✅ L1/L2 | ✅ (SSM path) | `MLX_BUN_BATCH_SSM=0` reverts |
| Qwen3.8-27B (same qwen3_5 graph) | ✅ L1 | ✅ (SSM path) | native MTP head via `--draft-model`/`--draft-kind mtp` (lossless-gated; slower on a quiet box — opt-in); images and video serve (mlx-vlm oracle) |
| GLM-5.2 / Colibri | ✅ chat/text, Messages, Responses, SSE, tools, grammar, logprobs | ✅ compressed MLA/DSA scheduler | native MTP defaults to serial+spec; `--mtp off` enables batching; embeddings, vision/audio, adapters, training unsupported |
| DiffusionGemma-26B (non-autoregressive) | ✅ (own engine) | — serial always | first bit-exact non-AR port |
| Tier-0 universal (llama/qwen2/qwen3/olmo2/…, 11 archs) | ✅ L1 | ✅ plain full-attention archs² | gemma2-family / sliding-window universal → serial |

¹ `guided_regex` accepts the regex∩EBNF subset today (no `\d`/anchors — those degrade to prompt injection).
² Gated token-exact vs mlx-lm B=2 (static + dynamic join/leave) on Llama-3.2-3B.
³ Audio is a capability neither ancestor serves (mlx-lm strips the tower; optiq never wires it into its serve frontend). Serial by design; prompt cache skipped.

Beyond serving, the same binary does training (`mlx-bun train`),
quantization (`convert`, `fuse`), embeddings, local memory (`mlx-bun
memory`), the pi agent (`mlx-bun pi`), the registry/`fit`/`gc`, HF
`upload`, and the web Model Hub — see [cli.md](./cli.md).

## Performance characteristics & recipes

Reference numbers are from this project's dev machines (loaded-machine
numbers are directional only; [benchmarks.md](./benchmarks.md) holds the
quotable set, and `scripts/bench-matrix.ts features` measures the
composition cells in one run).

- **A lone request is the serial engine** — prompt cache, compiled
  decode, and SSD restore all apply at B=1 under the default cap.
- **`--batch N` wins under concurrency** — cpm5 `--batch 4`: ~349 tok/s
  aggregate vs ~173 serial-queued, TTFT 2–3× better; Llama-3B at B=2:
  1.7× aggregate, TTFT 765→162 ms.
- **Spec pays only on slow targets.** One accepted draft = one skipped
  target forward: 12B ≈ 1.09× at γ=1; fast small targets lose (e4b
  0.78×). Draft for 12B+, skip below.
- **Structured output is ~free** (<1% serial; bounded ~0.1 ms/step class
  in the batch lane).
- **`--ssd-cache` has 0% decode overhead** — pure TTFT/restart win.
- **Quantized-KV prefill pays a scheme-intrinsic tax at long context** —
  chunked prefill converts each chunk's KV at the boundary, so later
  chunks attend against the quantized prefix (the same streaming
  conversion optiq serve uses): ~30% prefill throughput vs bf16 at ~16k
  where the config quantizes every cache, single-digit % on the
  sliding-window gemmas. The lever is upstream (mlx `quantized_matmul`,
  [decode-speed-program.md](../design/decode-speed-program.md) lever 2).

**Recipes:**

- *Single-user agent/chat (the default use):*
  `mlx-bun serve <model> --ssd-cache <dir>` — L1, prompt cache + SSD tier.
  On 12B+ add `--draft-model <small-same-tokenizer>`.
- *Several clients at once (throughput):*
  `mlx-bun serve <model> --batch 4 --ssd-cache <dir> --kv-budget <GB>` —
  don't set uniform/turbo `--kv-quant` (it un-batches everything), don't
  mount a draft.
- *UI must never lag / survive engine crashes:* add `--isolate`
  (`--model-pool 2` to keep two models resident).
- *Reproducibility:* bare / `--l1` (≡ mlx-lm), `--l1 --batch 1` (strict
  serial), `--l2` (≡ optiq).
- *Memory-tight big model:* `--kv-quant config|4|8|turbo` +
  `--memory-budget <GB>` + `--ssd-cache <dir>`; MoE adds
  `--expert-offload`. Uniform/turbo make this the serial recipe.

**The two exclusions to remember:** batching excludes uniform/TurboQuant KV
(per-layer `kv_config.json` does compose), and spec excludes prompt-cache
reuse (v1 bypass).

## Observability — `GET /stats`

The live config and batch state. The canonical field-by-field snippet
lives in [server-api.md](server-api.md#get-stats); highlights:
`prompt_cache` (cap), `kv_quant.mode` (incl. `turbo kXvY`), the
conditional `ssd_cache` block (pending/dropped/failed spill counters), the
conditional `glm52` block, and `batch`
(`mode`/`active_rows`/`pending_rows`/`submitted_rows`/`kv_bytes`/
`kv_budget_bytes`).

`batch.mode` is the truthful configured/capability state: `off` for
`--batch 1`, `serial` when a larger configured cap cannot batch the loaded
model's cache layout, and `batch` when the model is admitted.
`batch.batched` is the compatibility boolean for `mode == "batch"`;
`active_rows` is the instantaneous live-row count. Under `--isolate`,
`GET /engine` on the parent reports the child pid, restart count, socket,
and pool residency.
