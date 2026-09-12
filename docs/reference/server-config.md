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

The server runs generation through method-neutral sessions. A model binding
supplies execution planning, its supported methods, media preparation and
diagnostics. Stop/tool parsing runs directly in session delivery, so it can stop
generation before another token is produced. This adds no architecture flag.

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

Memory estimates are advisory by default. The server attempts requests without
rejecting a prompt or shortening `max_tokens` based on predicted GPU headroom.
`fit` and `/stats.admission.max_safe_context` remain estimates; they do not
set the default execution limit. Explicit `--memory-budget`, `--kv-budget`,
and context caps remain opt-in restrictions. GLM-5.2's allocated context
layout retains its configured capacity.

When batch rows finish, full-attention caches drop padding shared by every
surviving row, matching MLX-LM while preserving each row's absolute position.

Qwen prefills longer than four tokens materialize each layer and its cache
state before continuing, bounding deferred buffer lifetimes. Cache maintenance
demotes least recently used snapshots under allocator pressure without
refusing the request. With SSD enabled, an unwritten victim stays in RAM until
its queued write completes. The RAM target can be exceeded while writes are
pending or failing;
it does not promise that every workload fits.
Actual allocation failures use the ordinary error path when recoverable;
a native Metal allocation failure can terminate the process.
Recurrent-cache hits lend independently owned views before any donor is
reclaimed. The request can advance those views while the original boundary
remains in RAM or in a completed SSD snapshot. Persistence stays asynchronous.

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--memory-budget` | GB (decimal, ×10⁹) | unset; memory estimates are advisory | both (per request) | Explicit opt-in budget. Sets the allocator limit and enforces the fit estimate: a prompt leaving no generation slot gets **400** (`type: memory_admission`); a broader completion cap is reduced to the remaining context. Estimates account for active KV quantization and prefill temporaries. Not an aggregate batch cap — see `--kv-budget`. GLM-5.2 also uses this value in its resource plan before loading. |
| `--kv-budget` | GB (decimal) | off | batch | Aggregate KV budget across concurrently admitted batch rows: a joiner whose projected KV (prompt + `max_tokens`, window-capped) would exceed it **queues** until rows finish; a request over the budget alone is rejected. Without it, N large-context rows can collectively exceed memory. Reported in `/stats.batch.kv_budget_bytes`. |
| `--prompt-cache` | GB (binary GiB) | `8` | both | RAM prefix-KV residency target, managed by LRU. `--prompt-cache 0` disables it. RAM hits lend zero-copy views, including recurrent Qwen and method state. With SSD enabled, eviction persists an unwritten donor before removing it from RAM; pending writes can temporarily exceed the target. A successful write alone does not evict RAM. The target does not reserve that much memory. SSD persistence runs in the background; RAM reuse never waits for a write. Explicit cache flush and graceful shutdown report durability, including snapshots lost before persistence. Batch-lane joiners `take()` the longest usable prefix at admission; completed decode publishes reusable processed-token state through the same interface. |
| `--ssd-cache` | dir | off | both | SSD cold tier under the prompt cache ([docs/design/kv-cache.md](../design/kv-cache.md)): prefix KV spills to disk on RAM eviction and idle demotion, is also persisted after publication by a dedicated CPU worker while inference continues (`MLX_BUN_SSD_WRITEBEHIND=0` disables proactive writes), and **survives restarts**. Entries are keyed by model fingerprint + effective KV scheme + backend numerical identity + tokenizer hash + adapter namespace. MLX includes its runtime version and GPU architecture; older numerical identities use separate directories. `SIGINT`/`SIGTERM` drains active requests and flushes dirty snapshots before exit (`MLX_BUN_SHUTDOWN_TIMEOUT_MS`); `POST /admin/cache/flush` is the explicit boundary. Requires the RAM cache. |
| `--ssd-cache-max` | GB (binary GiB; `0` = unlimited) | unlimited | both | Optional SSD tier byte cap; oldest-mtime entries are evicted only when a positive cap is configured. Warns and is ignored without `--ssd-cache`. |
| `--ssd-cache-verify` | (bool) | off | both | Verify every tensor hash on restore (reads all bytes eagerly, defeating lazy fault-in) — integrity paranoia only; the header hash is always verified. Warns and is ignored without `--ssd-cache`. |
| `--ssd-demote-idle` | seconds | `300` with `--ssd-cache`, else off | both | Prompt-cache entries unused this long spill to the SSD tier and free their GPU memory; the next hit restores them. The cache sweeps by entry age independently of scheduler activity; RAM remains resident until SSD coverage exists. `0` disables. Warns and is ignored without `--ssd-cache`. |
| `--generation-checkpoint` | output tokens | off | qualified requests | Queues an owned in-flight generation snapshot every N emitted tokens. Repeating the identical request after a restart replays the saved assistant prefix and continues from its already-sampled next token. Requires `--ssd-cache`. Shared execution qualifies ordinary requests with supported row-cache layouts, including Qwen, Llama, MiniCPM and Gemma4, with or without adapters, excluding media, grammar, fill, paging, logprobs or speculative methods; existing serial qualification remains available. Explicit cache flush drains queued writes. Completed generations remove their checkpoint, while client cancellation preserves the latest checkpoint. |

Generation checkpoint identity includes stop strings, sampling/KV policy, the
resolved execution method, compiled/grammar policy, and artifact/implementation
identity. Changing any of these starts a new completion. Version-2/3 generation keys are not
selected for automatic resume. Prefix-cache files retain their state codec
format, but automatic reuse also requires the model binding's numerical
identity. MLX runtime or GPU architecture changes select a fresh cache
directory and leave the previous directory intact. A different backend codec
identity refuses incompatible files. Adapter namespaces include the mounted weight contents and
scale, so a changed adapter starts with a fresh prefix and checkpoint.
Native media and grammar preparation waits for the generation execution lease
and retains a reservation through completion. At most one media preparation and
`--batch` grammar preparations can be retained. Generation and preparation
queues each allow 64 waiting requests; overflow returns `429` before a response
stream opens, or a terminal stream error after it opens. Disconnects release
queued reservations and completed preparation resources.

Ordinary requests in the continuous scheduler can join an ongoing prefill
between chunks when their execution context is compatible and batch capacity
is available. Scheduling also budgets the initial prefill work in a cohort, so
long prompts can be prepared one at a time through the continuous executor
while decode remains batched. Subsequent forwards process real-token chunks from admitted requests
together. Each request keeps its own cache-maintenance and checkpoint boundaries.
Arrival timing can change batch geometry and near-tie generated text. Qwen MTP,
prompt lookup and standalone drafting use the same target prefill driver.
Their providers prepare companion state through a separate interface;
scheduling determines admission and work budgets.

Disconnected serial requests leave the admission queue immediately. Active AR
requests check cancellation between prefill chunks and decode steps; a native
operation already running completes before that boundary.

### Runtime isolation

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--isolate` | (bool) | off | both | Run the inference engine as a **child process** on a unix socket while this process owns CPU application routes and proxies inference — instant under any GPU load, survives engine crashes (auto-respawn). Full semantics in [`--isolate` semantics](#--isolate-semantics). |
| `--model-pool` | n (≥1) | `1` | both | With `--isolate`: max **resident** model engines. A request whose `model` field is an **exact** `/v1/models` id spawns/routes to that model's own engine child (spawn-overlap: the new model loads while the old keeps serving). Over the cap the least-recently-used engine is drained (`POST /admin/drain` over its socket), demotes its prompt cache to the SSD tier, and exits; switching back respawns it with state restored from disk. Without `--isolate` the flag warns and is ignored. |

### Scheduling

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--batch` | n (integer ≥ 1) | `8` | batch / L1 | Max concurrent requests decoded together. A lone admitted request uses the B=1 fast path (adopted serial-class caches, compiled decode, prompt cache + SSD restore — byte-identical to serial); a batch layout only exists once a second request arrives. `--batch 1` pins the strict serial executor (arrival-independent numerics — use it for golden regeneration). `--decode-concurrency` is accepted as the mlx_lm.server alias, but its semantics differ there (per-`BatchGenerator` decode parallelism, default 32). See [Execution modes](#execution-modes-serial-vs---batch-n). |

### KV cache

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--kv-quant` | `config` \| `off` \| `4` \| `8` \| `turbo[:k<bits>v<bits>]` | `off` (bf16) | see row | KV-cache quantization. `off` = bf16 (the L1 default: quantized KV measured 5–20% slower decode than bf16 at ≤16k on both stacks, so it is an opt-in that buys **memory headroom**). `4`/`8` = **uniform** bits (group 64, start 0 — mlx-lm's `--kv-bits` scheme); with fused-sdpa off (the default for uniform) our unfused quantized SDPA is op-for-op mlx-lm's `quantized_scaled_dot_product_attention`, so uniform is **bit-exact L1**; uniform requests use shared B=1/B>1 execution where the loaded cache layout supports affine conversion. `config` = **per-layer mixed precision** from the model's `kv_config.json` — optiq-only → **L2**; per-layer configs **batch** on every shipped model (full-attention and rotating layers; gated bit-exact per row vs the serial composition). `turbo[:k<bits>v<bits>]` = **TurboQuant** ([docs/design/turboquant.md](../design/turboquant.md)): rotation-based KV quantization, default `k8v3`; `kBits` ∈ {2,4,5,8}, `vBits` ∈ {2,3,4,5,8}; a separate axis (mutually exclusive with `config`/`4`/`8`), uses the existing decoded or deferred rotated-value attention path, **full-attention layers only** (sliding-window layers stay bf16 with a one-time warning), refuses head dims outside `TURBOQUANT_HEAD_DIMS`, and supports shared ordinary and grouped drafting execution at B=1/B>1 including positive library conversion thresholds when the cache layout qualifies. Any explicit `--kv-quant` overrides the tier preset. |
| `--paged-kv` | (bool) | off | shared / optional | Full-attention block pools through the common cache-layout and attention interfaces. Supports bf16 and uniform affine `--kv-quant 4|8`; affine pages encode from their first token. Default attention gathers into stock SDPA; `MLX_BUN_PAGED_ATTN=1` selects the experimental direct Metal reader. RAM/SSD reuse uses a separate numerical namespace. Gemma4-family only; draft models, per-layer KV schemes and TurboQuant pages remain unsupported. Media/adapter requests retain their existing non-paged behavior. Env mirror `MLX_BUN_PAGED_KV=1`. |
| `--paged-kv-block-size` | n | `256` | shared | Tokens per KV block (`--paged-kv` only); 256 = the plain cache's growth step. |

### Adapters and speculative decoding

In v0.4.0, Qwen MTP publishes aligned target/draft
prefill snapshots through the shared prompt cache by default. The RAM budget
includes the draft KV and pending hidden row; configured SSD persistence
queues those tensors with the target state and supports reuse after restart.
RAM hits retain immutable snapshots for later requests. Target, draft-weight,
adapter-revision and KV-policy identities separate incompatible state.
`usage.cached_tokens` reports the reused target prefix.
`MLX_BUN_MTP_PROMPT_CACHE=0` disables this reuse. Completed decode also
publishes checkpoints for processed tokens through the same cache.
Long-conversation performance acceptance remains open.

In v0.4.0, Qwen uniform affine KV4 with
`quantizedKvStart=0` supports configured speculative execution by default.
`MLX_BUN_QWEN_SPEC_KV4=0` restores the ordinary-decode compatibility control. Recurrent state and draft KV keep their original precision. Shared Qwen MTP
also supports bf16, uniform KV8 and TurboQuant at start zero; per-layer mixed
KV remains incompatible. Strict legacy serial speculation retains bf16/KV4.
The KV4 control does not disable bf16, KV8 or TQ shared speculation. Six paired M4 Pro combined suites and two completed Kanban tasks support
this default. Configuring a drafter and selecting KV4 remain explicit choices.

For controlled experiments, `MLX_BUN_RD_PREFILL_CHUNK` sets the prefill chunk,
default 2048. Shared ordinary and speculative methods use the group's captured
default; an explicit group option overrides the environment and a library
request's `prefillChunkSize` overrides that default for its request.
`MLX_BUN_RD_CONTEXT_LIMIT` sets an explicit request context cap
without enlarging it. Both require positive integers; the context cap is unset
by default. These are benchmark controls, not changes to the published model
profile or sampling policy.

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--adapter` | dir | none | compatible adapter groups | Mount a LoRA adapter at startup (same machinery as `POST /v1/adapters`; the id is the directory basename) and make it the default for requests without an `adapter` field. A request's explicit `adapter` — including `"none"` — wins; hot-swap via `/v1/adapters` is unchanged. A bad adapter fails startup. Alias `--adapter-path`. |
| `--draft-model` | path \| query | none | shared Qwen methods; full-attention/rotating lookup/standalone and Gemma assistant/DeepSpec/DSpark; other combinations serial | **Speculative decoding**: a drafter proposes tokens the target verifies in one forward — exact results, faster decode when drafts land. Resolves like the main model. Kind is auto-detected: a full same-tokenizer model (mlx_lm.server parity, L1 token-for-token; tokenizer-family mismatch fails startup), a Gemma `-assistant` KV-borrowing drafter (L2 vs optiq `spec_generate`), a locally trained **DSpark** checkpoint (`dspark.json`), or a released DeepSpec `Gemma4DSparkModel` drafter. Qwen MTP, prompt lookup and standalone drafting use the shared executor at one or several active rows, including logprobs. Supported full-attention and rotating targets, including Llama, MiniCPM and Gemma, also share bf16, uniform KV4/KV8 or per-layer affine KV or TurboQuant prompt lookup and standalone drafting. Rotating target transactions retain different accepted lengths across the sliding window and publish paired RAM/SSD state. Gemma assistant drafting shares the same execution at B1/B>1 with bf16, uniform KV4/KV8 or per-layer affine KV or TurboQuant target storage. Its hidden-state companion and target KV use the RAM/SSD cache; donor attention owns row validity while the assistant graph stays independent of storage. DeepSpec and DSpark share bf16, uniform KV4/KV8 or per-layer affine KV or TurboQuant target execution and projected-context RAM/SSD companions. DeepSpec supports bf16 or affine-quantized draft weights; DSpark supports its Markov/RNN heads. Confidence selects each row's proposal length independently. Other provider/target combinations still run serial. Unsupported speculative compositions use ordinary execution when their own features support it. Composes with structured output; Qwen MTP, prompt lookup, standalone, Gemma assistant, DeepSpec and DSpark drafting use the shared RAM/SSD prefix cache by default (`MLX_BUN_MTP_PROMPT_CACHE=0` disables); other speculative sources start fresh. Telemetry: `usage.speculation`. |
| `--draft-kind` | `two-model` \| `assistant` \| `dspark` \| `deepspec` \| `mtp` \| `ngram` | auto | shared Qwen methods; full-attention/rotating lookup/standalone and Gemma assistant/DeepSpec/DSpark; other combinations serial | Override drafter detection. `mtp` = a native multi-token-prediction head split from the target's release (`*_mtp` model_type; shares the target's embeddings/lm-head, defaults `--num-draft-tokens` to its trained `block_size − 1`, rolls DeltaNet caches back by snapshot/replay on partial rejects); `mtp` alone mounts the companion bundled at `<model>/mtp/` when present. Qwen MTP companions accept dense or affine-quantized projections using their checkpoint metadata; changing the draft can change acceptance and speed. `ngram` = **model-free prompt lookup** (drafts copied from the request's own prompt+generation; port of prompt-lookup decoding / vLLM's `ngram` proposer) — mount it **alone** (`--draft-kind ngram` with a `--draft-model` is refused, as is any other kind without one); lossless by the same verify, a no-match round degrades to one plain target step. Any other value fails startup. |
| `--num-draft-tokens` | n (integer ≥ 1) | `3` (`ngram`: `10`; DSpark: pinned ≤ its trained `gamma`) | method-dependent | Drafts per verify round (mlx_lm.server's default; `mlx_lm.generate`'s is 2). |
| `--ngram-max` / `--ngram-min` | k (integer ≥ 1) | `3` / `1` | Qwen and full-attention targets shared / other models serial | `--draft-kind ngram` only: longest/shortest trailing k-gram searched (longest first, first occurrence wins). `--ngram-min` > `--ngram-max` fails startup; either flag without `ngram` warns and is ignored. |
| `--mtp` | `on` \| `off` | `on` for GLM-5.2 | serial+spec | GLM-5.2 checkpoint-native MTP row as the server's drafter, using the bounded auxiliary expert tier and the exact serial verify loop (`usage.lane: "serial+spec"`). `off` removes the draft so ordinary GLM requests can use continuous batching. Other model families ignore it. |
| `--context-length` | tokens (integer ≥ 1) | `4096` (GLM-5.2) | both | Context reserved by GLM-5.2's header-only resource equation; also the request-admission ceiling, reported in `/stats.glm52`. An impossible plan fails before committing model memory. Ignored by other families. |

### Sampling and template defaults

| Flag | Arg | Default | Lane/tier | What it does |
| --- | --- | --- | --- | --- |
| `--thinking` | `true`\|`false` (also `on`/`off`/`1`/`0`) | model's own (`false` for MiniCPM5) | both | Server-wide default for the chat template's `enable_thinking`. Precedence (`resolveEnableThinking`): explicit request `chat_template_kwargs.enable_thinking` → request `reasoning_effort` (`"none"` = off, any other level = on) → this flag → the model's default. With no explicit temperature, a no-think turn is capped at 0.7 while a think turn keeps the model's configured temperature. |
| `--temperature` | n ∈ [0, 5] | `generation_config.json`, else `0.7` | both | Server-wide sampling default; a per-request `temperature` wins; the browser chat (sends none) inherits it. Alias `--temp` (mlx_lm.server spelling — note its *default* there is `0.0`; pass `--temp 0` for that behavior). |
| `--top-p` | n ∈ [0, 1] | `generation_config.json`, else `0` (off) | both | Server-wide top-p default (per-request `top_p` wins). |
| `--top-k` | n ∈ [0, 1e6] | `generation_config.json`, else `0` (off) | both | Server-wide top-k default (per-request `top_k` wins). |
| `--max-tokens` | n ∈ [1, 1e7] | GLM-5.2: `128` (memory-plan reservation); otherwise none — an omitted cap generates until EOS/stop or an explicitly configured limit | both | Completion cap when a request omits `max_tokens` (mlx_lm.server flag). DEVIATION when unset: `mlx_lm.server` stops a defaulted request at 512 — `--max-tokens 512` reproduces it. For GLM-5.2 the value is also reserved by the pre-open resource equation and must fit inside `--context-length`. Note: `max_tokens` also feeds `--kv-budget` row projections (prompt + cap), so an uncapped request cannot fit a finite explicit KV budget; set `--max-tokens` or send a request cap when using that budget. |
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
| `--compiled-activations` | `on`\|`off` | on | both / L1 | Route geglu/swiglu through mlx-lm's `@mx.compile` closure (`MLX_BUN_COMPILED_GEGLU` + `MLX_BUN_COMPILED_SWIGLU`). MiniCPM5 uses compiled SwiGLU for decode and prefill. `off` selects the uncompiled composition and can change prefill numerics on MLX 0.32.2. Toggles gemma geglu + MiniCPM5 swiglu; qwen3/qwen3.5/universal compile unconditionally. |
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
  none: run to EOS/stop or an explicit operator limit). The cap changes the stopping
  point and `finish_reason`.
- `--batch 1` — strict serial, arrival-independent numerics. (`--batch N`
  is itself bit-parity with mlx-lm at B=N; pin 1 for golden regeneration.)
- Already matching without flags: host/port, bf16 KV (`--kv-quant off`),
  the L1 kernel preset (`--l1` is the default), logprobs caps, error text.

These flags align sampling and caps. Exact generated trajectories also need
matching prefill and cache boundaries. Stock MLX-LM HTTP splits system and
thinking segments before reserving the final token. Different forward shapes
can change near-tie greedy choices even inside the same Python model.
The benchmark's explicit `--reference-prefill unsplit` control and the saved
MiniCPM/Qwen investigation are documented in [benchmarks.md](benchmarks.md).

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
- **Application state.** The web shell, job submissions, records, progress streams, settings and
  Responses conversation history live in the CPU-only parent, so worker death or model eviction does not remove
  them. Native inspection/merge/export and generation still execute in workers.
  WebSocket chat retains its existing unsupported status under isolation.
- **Proxying.** Remaining HTTP requests are forwarded over the unix
  socket (hop-by-hop headers stripped, SSE streams through, a client
  abort aborts the proxied fetch so the engine sees the disconnect).
  `GET /engine` answers from the parent:
  `{ isolated: true, pid, restarts, socket, response_store, pool?: { resident, default } }`.
  Worker fields describe the currently resident default worker and are `null`
  while it is evicted; inspection does not load a model. A recreated worker has
  its own restart count.
  `/ws/chat` is **not proxied** — `501` with a pointer to run without
  `--isolate` for the web chat UI.
- **Crashes.** A child exit (uncatchable Metal OOM/SIGTRAP included) is
  respawned automatically (`restarts` increments), with at most three restarts
  in a rolling 60-second window. Exhausting that budget leaves the host
  unavailable until restarted. An engine that dies within 10 s of spawning
  waits 5 s before the retry. In-flight requests
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
  listener. Cold model starts are serialized through a bounded queue while the
  resident model keeps serving; concurrent switches cannot evict a newly loaded
  worker before its pending request is returned. `--model-pool` is clamped to ≥ 1.
- **Managed GPU jobs.** A FIFO parent coordinator waits for active worker
  responses, then holds a native execution lease inside every resident worker
  before spawning a quantization/finetuning job. Startup, restart and eviction
  participate in admission too. Job exit releases those leases. Dataset jobs use
  the same loopback completion API and keep their progress in the parent.
- **Shutdown.** `SIGINT`/`SIGTERM` cancels queued jobs, stops the active GPU job,
  waits for in-process task cleanup, then closes workers and unlinks sockets.
  Worker close also waits for pending startup admission and failed startup
  attempts to release their execution leases, including before a child exists.

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
| `MLX_BUN_MIXED_PREFILL` | — | off (`=1`) | Lab mixed prefill/decode execution for Gemma 4 and Qwen3.5/3.8 text groups, including grouped speculative methods. The scheduler reserves running tokens before prompt work; the model packs feed-forward operations across real tokens while attention and KV state retain their original group geometry. Methods supply candidate-token demand and per-group hidden taps; speculative verification preserves its existing matmul geometry. Packed matmuls can select different kernels from solo decode; this does not claim solo-logit identity or a measured serving win. |
| `MLX_BUN_MIXED_PACKED_MLP` | — | on (`=0` disables) | Lab control inside mixed model work: disable feed-forward packing while keeping the same scheduling budget and attention geometry, to measure packing separately from chunk scheduling. No effect when mixed execution is off. |
| `MLX_BUN_MIXED_TOKEN_BUDGET` | — | `256` | Total real tokens in an enabled mixed iteration, including running decode rows. At least one token per participating row progresses. A lone preparation retains its existing chunk setting. Precision transitions and checkpoint endpoints remain method-owned. |
| `MLX_BUN_EARLY_FIRST_TOKEN` | — | off (`=1`) | Serial/native generation yields token zero before constructing the next decode step. This can reduce first visible output latency when token zero contains visible text. Later decode remains pipelined. Serial fill, grammar, checkpoint resume and single-token budgets retain their existing order. When a native consumer stops at the first yield and retains caller-owned caches, a non-aborted return completes that token’s M=1 forward before returning the cache. This preserves the ordinary pipeline’s boundary for later prefix reuse. Aborted requests do not start another forward; caches owned and disposed by the generation need no alignment. Native M1 packed-Qwen/MiniCPM/Gemma continuation gates pass; M4 packed/affine and serving acceptance remain. The continuous scheduler also yields after preparation creates its first active row when no other request is queued, allowing prepared output to flush before decode. It then rechecks cancellation, admission and shutdown; queued short admissions still group together. The setting is captured by generation and the batch runtime. Experimental pending broader cached/pressure and quiet-machine acceptance. |
| `MLX_BUN_TURBOQUANT_FUSED_DECODE` | — | off (`=1`) | Experimental packed K/V decode fusion for an existing `--kv-quant turbo:...` cache, captured when each cache is created. A shared Metal operation unpacks keys and values, applies the existing key zero/scale and Lloyd-Max value scale, and preserves the codec's eager or deferred inverse rotation. It accepts supported bit widths, head dimensions 64/128/256/512 and 32/64-element groups with fp16/bf16/f32 metadata. Eager k8v3 with B1/H4, head dimension 256, fp16 metadata, group32 and at least 8192 cached tokens also fuses inverse rotation; other shapes keep the existing rotation path. Unsupported inputs, CPU streams and shapeless traces retain ordinary operations. Quantization, stored cache format and serving eligibility are unchanged. Joint-decoder Qwen native/serial and repeated long-context HTTP gates pass. The inverse operation passes both integrated Qwen model gates and six HTTP pairs per quant. MiniCPM/Gemma deferred-consumer serving gates also pass. The shared codec/layout supports ordinary and supported drafting groups without changing this kernel selection. Gemma now owns pre-write row positions across cache appends; the fix passes native checks on both Macs. Combined settings, pressure and strict M4 Pro acceptance remain. |
| `MLX_BUN_NO_FUSED_SDPA` | `--fused-sdpa` (inverted) | follows `--kv-quant` | `=1` forces the stock unfused SDPA everywhere. |
| `MLX_BUN_COMPILED_GEGLU` | `--compiled-activations` | on (`"0"` disables) | Gemma geglu via mlx-lm's `@mx.compile` closure. `=0` → uncompiled composition (same parity, slower). |
| `MLX_BUN_COMPILED_SWIGLU` | `--compiled-activations` | on (`!== "0"`) | Compiled SwiGLU on MiniCPM5 decode and prefill, matching mlx-lm. An enclosing compiled graph owns its own fusion. qwen3/qwen3.5/universal compile unconditionally. |
| `MLX_BUN_FORCE_WIRE` | `--force-wire` | off (`=1`) | Wire weights for the generation. |
| `MLX_BUN_TRELLIS` | — | `kernel` (`=expand`) | Packed trellis-coded weights (`mode: "trellis"` modules, Q2b — design: `docs/design/turboquant.md`). `kernel` serves them through the Metal decode kernels (M≤4 matvec; larger M expands one tensor to bf16 and runs a stock matmul). `=expand` decodes every trellis tensor at LOAD into 8-bit g64 affine (+~4 GiB at 27B, the eval-carrier numerics) and serves it through the stock quantized path — the fallback for a machine where the kernels lose. |
| `MLX_BUN_TRELLIS_VARIANT` | — | `13` | Trellis kernel variant (see [Q2b experiments](../design/turboquant.md)): `6` = code computed inline × reciprocal, weight served as f32 code×scale; `1` adds a residual step and bf16 rounding to reproduce the fake-quant artifact's weights. `0`/`2`/`3`/`4`/`5` are bench-only decoder variants. Variants `7`–`13` retain variant-6 decode values; `13` is the measured default. These variants tune work assignment; `11` tiles eligible short axis-1 prefills, `12` adds split-K axis-0 prefill at M=5..8, and `13` also vectorizes remaining bf16 expansion for k2/k3/k4, T=256, L=12. On MLX 0.32.2/M3+ the axis-1 M5..15 path instead uses direct packed decoding with native wide-matvec arithmetic when Qwen's RMSNorm establishes aligned row-contiguous inputs; callers without that layout proof use native expansion/matmul. Qwen27B additionally selects an integer codebook for its interleaved k3 down projection at M=3/4 with bf16 activations; other calls retain the computed decoder. Prefill rounds weights to the activation dtype. |
| `MLX_BUN_TRELLIS_ASYNC_EXPAND` | — | off (`=1`) | Experimental variant-13 expansion scheduling. Submit an expanded projection asynchronously while MLX active allocation is below 75% of the device's recommended working set; retain blocking evaluation above it. Other variants are unchanged. Uses the execution's runtime-policy snapshot and preserves the caller's layer barriers. The threshold is not a total-memory cap. Qwen27B integrated native, repeated serial/continuous HTTP and both saved-agent pressure gates pass on M4 Pro 24 GB. Broader-model, combined-optimization and quiet M4 Pro acceptance remain. |
| `MLX_BUN_PAGED_KV` | `--paged-kv` | off (`=1`) | Paged KV cache; the same refusals and prompt-cache bypass as the flag. |
| `MLX_BUN_ALLOW_PRIVATE_MEDIA` | `--allow-private-media` | off (`=1`) | Permit media fetches to private/loopback/link-local hosts (timeout + size cap still apply). |
| `MLX_BUN_EXPERT_OFFLOAD` | `--expert-offload` | off | `=<dir>` — the path of a built expert-offload file, activated at module load (`src/expert-offload.ts`) for scripts and library runs that never parse serve flags. The CLI flag builds the file and activates it itself. |
| `MLX_BUN_PREFILL_TAIL_SPLIT` | — | on (`"0"` disables) | Oracle prefill convention: drain the prompt to len−1, then compute step-0 logits from a separate L=1 forward of the last prompt token (mlx-lm `generate_step` and its batched engine). Both lanes. The spec lane follows its own oracle's shape under the same flag (mlx-lm `speculative_generate_step`: target and draft drain to len−1, no separate step 0). `=0` restores the full-final-chunk convention everywhere — ulp-different at step 0, flips near-tie greedy streams vs mlx-lm. |
| `MLX_BUN_GRAMMAR` | — | on (`"0"` disables) | `=0` disables structured-output mask compilation; requested constraints take the graceful-degrade route (chat prompt injection + a `Warning` header; raw completions header only). |
| `MLX_BUN_TOKEN_MASK` | `host` \| `metal` | `host` | Experimental grammar-mask implementation. `metal` uploads packed bits and applies the same additive mask in a compiled shared Metal kernel. Captured when the grammar controller is created; serving performance gates remain open. |
| `MLX_BUN_GRAMMAR_JUMP` | — | **off** (`=1`) | Grammar-supplied continuations. Eligible shared requests without a configured drafter propose xgrammar's forced string to the existing target verifier; the sampler validates every emitted token, including requested logprobs. Candidates leave the matcher unchanged until sampling. Affine/TurboQuant layouts compose through their speculative capabilities; paged requests keep ordinary grammar sampling. Explicit serial execution retains direct jump-forward: it emits retokenized forced spans with one multi-token forward, skips jumping with logprobs, and can choose different tokens than ordinary sampling. A configured drafter retains its own proposal policy. This remains opt-in; tokenization/verification width can change numerical trajectories. |
| `MLX_BUN_GRAMMAR_DRAFT_TOKENS` | — | `3` | Maximum grammar candidates per shared verification round when `MLX_BUN_GRAMMAR_JUMP=1`. Changes proposal depth, independently of scheduler capacity. |
| `MLX_BUN_FILL` | — | **off** (`=strict` \| `=echo`) | **Token fast-forwarding** — lookup, not speculation. Spans of the assistant turn that the request's `tools` + the chat template already DETERMINE (tool-call open scaffold, the rest of a tool name after its first disambiguating token, a sole-required-key skeleton) are appended as committed context in bounded model forwards, and sampling resumes after them. No draft, no verify, no rollback — an injected token is context, indistinguishable to the model from one it sampled. Rows are compiled per request by diffing probe renderings of the model's OWN template, always sliced from a rendering carrying the REAL tool names and schema keys (so a span can never split a merged token such as Qwen3.5's `=get`), so a template that does not render `tool_calls` yields no rows and no fill. Key and call-close assertions require a closed object schema with exactly one required property and no pattern properties; optional/additional arguments stay available. If no property is required, the compiler preserves the empty-argument choice. Template-derived rows require a fresh request-local parser context. Tool-only output after closed reasoning qualifies; quoted/fenced examples, incomplete delimiters and ambiguous literals decline. Requests with more than 32 tools decline template-derived fills. Held-out identity coverage remains open. **Serial lane only** (it never forces a request off the batch lane) and refused for: fixed `seed`, `logprobs`/`top_logprobs`, structured output (grammar owns forced tokens), image/audio/video prompts, a mounted draft model, quantized/TurboQuant KV, and sliding-window models (one warning). Injection bypasses the sampler — a behavior-policy deviation at `temperature > 0` — hence opt-in. `=echo` additionally arms the **echo index** (Lab tier): spans copied from earlier in the same session, held under policy `verify` — the engine appends them in the same single forward, reads the argmax already in that forward's logits at every span position (free, no extra pass), keeps the prefix the model agrees with, and rewinds the rest through the same cache contract the spec lane's rounds use. A wrong echo costs a rewound forward, never a wrong token. Strict rows stay policy `assert` (no readback, no checkpoint). Telemetry: `usage.fill`. |
| `MLX_BUN_FILL_MAX_SPAN` | — | `32` (floor 2) | Hard cap on one injected span. |
| `MLX_BUN_FILL_APPEND_CHUNK_SIZE` | — | `0` (model limit) | Execution chunk cap for assert-policy fill, captured by each FillSession. Zero selects the model's qualified limit; a positive value can lower that limit. The Qwen 27B text path on `applegpu_g16s`, validated on the M4 Pro, supports up to four positions with supported affine projections and optional Trellis MLPs. It rechecks the limit after each chunk and splits at MLX's attention arithmetic boundaries to preserve one-token numerics. Other configurations use one position per forward. The engine commits the complete span before emission and resumes sampling after it, with no intermediate vocabulary heads or verification. Verify-policy proposals keep a single forward for recurrent rollback. The injected-token cap is unchanged. Library callers can set `FillSession`'s `appendChunkSize` option. Held-out, broader-model and quiet M4 Pro acceptance remain. |
| `MLX_BUN_FILL_K` | — | `8` (floor 2) | Echo anchor length: the k-gram that must match before a copied span is proposed (the corpus study's token-level threshold). |
| `MLX_BUN_FILL_CANDIDATES` | — | `24` | Echo bucket-scan cap — the NEAREST occurrences of the anchor win. A span extends only while every one of them agrees; the first disagreement (a **branch point**) ends it. |
| `MLX_BUN_FILL_INDEX_MAX` | — | `131072` (floor 1024) | Token cap on the growing echo index; past it the index freezes rather than growing. |
| `MLX_BUN_FILL_TRACE` | — | off (`=1` \| `=<file.jsonl>`) | `=1`: assert the fill cache-alignment invariant (`cache offset == prompt + forwarded`) on both sides of every append, and log each event. `=<file.jsonl>`: additionally append one record per proposal — proposed ids/text next to what the model's own logits said at every span position (position 0 = the in-flight sample, then argmax), for both policies; under `assert` that readback is trace-only. `bun scripts/fill.ts trace <file>` prints the list and per-position agreement. |
| `MLX_BUN_GRAMMAR_BATCH` | — | on (`"0"` forces serial) | `=0` routes grammar requests to the serial lane instead of per-row batch matchers (A/B + kill switch). |
| `MLX_BUN_BATCH_SSM` | — | on (`"0"` forces serial) | `=0` excludes SSMCache (Qwen3.5 gated-DeltaNet hybrids) from the batch capability gate → those models route serial. |
| `MLX_BUN_BATCH_EXTEND` | — | on (`"0"` reverts) | Joining rows append to the running batch's KV in one pad+concat (mlx-lm `BatchKVCache.extend`). `=0` reverts to whole-batch re-merge (numerically equivalent, O(B·S)). |
| `MLX_BUN_BATCH_VEC_SAMPLE` | — | on (`"0"` reverts) | Vectorized greedy batch sampling; `=0` falls back to per-row sampling (bit-equal A/B). |
| `MLX_BUN_BATCH_NO_PIPELINE` | — | off (`=1`) | Read each batch step's tokens synchronously instead of pipelined (A/B lever; numerically equivalent, slower). Read once at module load. |
| `MLX_BUN_SSD_WRITEBEHIND` | — | on (`"0"` disables) | Proactive persistence after cache publication. A CPU worker packs, hashes and writes immutable state without a generation lock. Writing does not evict RAM. `=0` keeps eviction-triggered persistence; RAM victims remain resident until their SSD copy commits. |
| `MLX_BUN_SSD_LAYOUT` | — | `whole` | `blocks` writes immutable content-addressed blocks with atomic checkpoint manifests (format 5). Existing whole files remain readable. Shared blocks count once toward an explicit SSD cap and survive deletion of other referencing checkpoints. Experimental space/time tradeoff; see benchmarks. |
| `MLX_BUN_SSD_SEGMENTED` | — | on (`"0"` disables) | With block storage, read contiguous spans directly and pack arbitrary strides in at most 1 MiB scratch. `=0` retains whole-tensor CPU packing for paired measurements. |
| `MLX_BUN_SSD_PREFETCH` | — | on (`"0"` disables) | Prepare cold prefixes before execution, using a separate CPU read queue and owned page-aligned allocations. Concurrent identical reads coalesce. Cancellation releases request interest; the cache chooses residency. `=0` retains synchronous restore for comparison. |
| `MLX_BUN_SESSION_CACHE` | — | on (`"0"` disables) | Honor application session affinity for checkpoint lookup and soft RAM retention. `=0` ignores session metadata for paired HTTP measurements. Full input is still required; see server-api.md for body/header fields and session closure. |
| `MLX_BUN_CACHE_RETENTION` | — | `lru` | `cost-size` selects GreedyDual-style reuse/size retention, with reused prefix tokens as the processing-cost proxy. This changes RAM residency only; SSD durability remains independent. |
| `MLX_BUN_PAGED_ATTN` | — | off | With paged KV, `1` selects direct Metal reads for short causal queries (≤8 tokens), bf16 or affine KV4/KV8. Longer prefill and explicit masks use the established SDPA shape dispatch. Lab numerical contract: tolerance-tested against the same stored values, not an L1 bit-exact claim. |
| `MLX_BUN_SSD_SPILL_QUEUE_GB` | — | `2` (GiB; any finite value ≥ 0) | Pending snapshot cap for optional interrupted-generation checkpoints. Older queued intervals may be superseded; `=0` retains the newest plus any in-flight interval. Normal prompt-history persistence does not use this drop policy; its cache owns RAM residency and SSD demotion. Counters in `/stats.ssd_cache`. |
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
| `MLX_BUN_P2R_TRACE` | `=1` | Per-request prompt→response phase trace (admission wait, prefill forward/evaluation/maintenance/checkpoints, mixed-forward token counts, token-zero, bounded initial token routing, response writes) for `/v1/chat/completions` and `/v1/completions`; records print to stderr as JSON lines. The trace id is `x-mlx-bun-trace-id` when the request sends it. |
| `MLX_BUN_P2R_SYNC` | `=1` (with `MLX_BUN_P2R_TRACE`) | Token-zero attribution mode: synchronizes hidden/cache state, projection and sampling at the instrumented boundaries. This changes overlap and slows the traced request. Ordinary prefill traces add no synchronization: forward includes any backend evaluation, while evaluate measures the remaining state wait. |
| `MLX_BUN_LANE_DEBUG` | `=1` | Logs each request's scheduling placement (`mechanism` + shape) to stderr. |
| `MLX_BUN_BATCH_STEP_TRACE` | `=1` | Per-step phase timing in the batch scheduler (build / read / emit / gap), read once at module load; summarized by `stepTraceReport()`. |
| `MLX_BUN_GRAMMAR_DEBUG` | `=1` | Logs per-step grammar row state in the batch scheduler. |
| `MLX_BUN_PREFILL_MEM_LOG` | `=1` | Logs active/peak memory after each serial prefill chunk. |
| `MLX_BUN_EXPERT_TRACE` | `=<path>` | Records every MoE router decision as JSONL to that path (adds a per-call GPU→host sync — a measurement tool, not a serving path). |
| `MLX_BUN_PI_DEBUG` | any non-empty | Extra `[pi-web]` logging (prompt fingerprint, tool/memory surface) for the web-chat pi session. |
| `MLX_BUN_EVAL_DEBUG` | `=1` | HumanEval: pipe the sandbox's stderr and print failures. |

P2R records include a process-local `startedAtMs` origin to align concurrent
requests. Prefill `workId` attributes identify shared spans recorded on several
rows; these spans and their nested children must not be summed as separate
GPU work. The first eight token-routing spans stop at the first semantic event
and distinguish hidden channel markers from visible output. With tracing
enabled, `bench-serve.ts all` retains complete records by child PID in
`promptResponseTraces`, including records emitted during shutdown. Summarize a
saved report with `bun scripts/bench/prefill-trace.ts report.md.json --out
breakdown.json`. Clocks from different server processes are independent.

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

No flag is needed to enable this default. The cap is a maximum, not a minimum
group size: a lone eligible request starts at B=1. The serial executor remains
available through `--batch 1` and for unsupported request compositions.

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
- **`--kv-quant 4|8`** uses shared affine conversion and batches on supported
  full-attention, rotating and hybrid recurrent models.
- **`turbo`** uses encoded shared rows for qualified start-zero full-attention caches; sliding layers stay bf16.

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
| LoRA `adapter` (resolves to ≥1) | ✅ identical ordered adapter sets share a group; different sets wait for the next group |
| `logprobs` / `top_logprobs` | ✅ ordinary and qualified MTP/lookup/standalone-draft groups capture per-request probabilities; other exclusions still apply |
| explicit `seed` | ✅ request-local random stream; reproducibility also depends on model arithmetic and batch composition |
| KV quant active | ✅ batches for per-layer `config` and uniform `4`/`8` schemes on supported cache layouts |
| `--kv-quant turbo` | ✅ qualified TQ layouts; ordinary and supported grouped drafting library requests also support delayed row-local conversion |
| `--draft-model` mounted | ✅ qualified MTP, lookup, standalone, assistant, DeepSpec and DSpark/DFlash groups; provider and request capabilities determine eligibility; supported ordinary requests batch |
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
| `--kv-quant 4`/`8` | ✅ applied to all requests | ✅ server start=0 converts during prefill and batches on supported cache layouts; delayed library thresholds use qualified shared affine row layouts |
| `--kv-quant turbo[:k<bits>v<bits>]` | ✅ ordinary decode; strict serial speculation remains excluded | ✅ ordinary TQ, including delayed library conversion; supported grouped drafting also supports delayed library conversion |
| `--kv-quant off` / unset | ✅ bf16 (the L1 default) | ✅ bf16 |
| `--paged-kv` | ✅ | ✅ Gemma4 bf16/affine4/8 with separate RAM/SSD namespace; experimental direct attention is opt-in |
| `--memory-budget` | ✅ per-request admission | ✅ per-request admission — not aggregate (use `--kv-budget`) |
| `--kv-budget` | n/a | ✅ aggregate queue/reject across rows |
| `--prompt-cache` / `--ssd-cache` | ✅ prefix/output reuse + SSD restore | ✅ immutable prefill/output checkpoints, session lookup and queued SSD persistence |
| `--temperature`/`--top-p`/`--top-k` | ✅ | ✅ (per-row) |
| `--thinking` | ✅ | ✅ |
| vision / audio / video request | ✅ | ✅ via serial lane |
| LoRA `adapter` | ✅ | ✅ compatible groups on adapter-capable backends |
| `repetition_penalty` / `min_p` / `xtc_*` / `logit_bias` / presence+frequency | ✅ | ✅ (batches — per-row processors) |
| `seed` | ✅ | ✅ request-local sampling |
| `tools` / `stop` | ✅ | ✅ (batches) |
| structured output (`response_format`/`guided_*`) | ✅ (mask in the decode loop) | ✅ (batches; per-row matchers) |
| `--draft-model` / `--draft-kind` | ✅ eligible spec decode | ✅ qualified MTP, lookup, standalone, Gemma assistant/DeepSpec/DSpark groups, including grammar/logprobs |
| GLM `--mtp on` | ✅ native MTP spec decode | ✅ native MTP uses grouped state/verification; tiny-model and oracle tests pass, final Colibri artifact testing is deferred |
| `--compiled-decode` | ✅ | ✅ at **B=1 only**: a lone request's adopted serial-class caches replay the same compiled step; B>1 steps run the plain graph |
| `--fused-sdpa` | ✅ eligible affine attention | ✅ kernel eligibility depends on dtype, quantization and mask geometry |
| `--force-wire` | ✅ serial wired scope | not applied by the shared executor |

### Shared execution and kernel settings

The scheduler selects request work. The inference method advances it through
model-owned numerical operations. Specialized kernels and sampling policies
remain available wherever their backend capabilities qualify; batching does
not disable performance settings as a category.

- `--compiled-decode` uses the qualified compiled graph for one active,
  unpadded request. Multi-row steps use the batched graph.
- `--fused-sdpa` follows affine kernel eligibility. Padded/array masks can
  require the ordinary attention operation; this is an attention decision.
- `--force-wire` controls the explicit serial wired scope. The shared executor
  does not enter that scope.
- Trellis, compiled activations, affine row reuse and TurboQuant kernel choices
  belong to the numerical backend and remain independent of admission policy.

Executors capture an immutable runtime configuration. Later host configuration
changes do not change an active request's kernel choices. TurboQuant storage
carries its decode policy through RAM copies, row extraction and delayed
conversion; restored SSD state is opened under the receiving binding's policy.

## Known limitations under shared execution

1. Media and direct tool-call fill still use the explicit serial executor.
   Grammar has shared masking and opt-in verified proposals; direct serial
   jump-forward is a different algorithm.
2. Aggregate admission is opt-in through `--kv-budget`. Without it, concurrent
   contexts can exceed available memory. Default fit estimates remain advisory.
3. Native GLM MTP has tiny-model/same-B oracle coverage; final Colibri artifact
   testing is deferred. DSpark/DFlash execution has fixture coverage, with no
   trained checkpoint available for a performance claim.
4. Paged Gemma storage supports bf16/affine4/8. TurboQuant pages, per-layer
   paged KV and paged speculative methods remain unsupported. Qualified
   ordinary resume and adapter resume are implemented; exact combinations are
   tracked in [batching](../design/batching.md).
5. Stock bf16, affine mixed-KV and TurboQuant retain separate correctness
   contracts. A passing storage test does not qualify an untested model or
   numerical geometry. Existing accepted matrices remain in the design and
   benchmark references.

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
| SSD KV cold tier (survives eviction + restarts; GLM compressed MLA/DSA state included) | off | both | — | `--ssd-cache <dir>` (+ `--ssd-cache-max`, `--ssd-cache-verify`, `--ssd-demote-idle`, `--generation-checkpoint`) |
| Runtime isolation (crash-isolated engine child behind a proxy parent) | off | both | — | `--isolate` |
| Model pool (LRU-capped resident engines under `--isolate`) | 1 | both | — | `--model-pool <n>` |
| Mixed-precision KV (`kv_config.json`, optiq's scheme) | off | serial + batch (per-layer configs batch) | L2 | `--kv-quant config`, `--l2` |
| Uniform quantized KV (mlx-lm's `--kv-bits` scheme) | off | serial + batch | L1 | `--kv-quant 4\|8` |
| TurboQuant KV (rotation-based: affine keys + FWHT/Lloyd-Max values) | off | serial + qualified shared ordinary/drafting | Lab (codec oracle-backed; composition gates apply) | `--kv-quant turbo[:k<bits>v<bits>]` (default `k8v3`) |
| Compiled decode (bit-exact graph replay) | on | serial, batch at B=1 | L1/L2 | `--compiled-decode on\|off` |
| Compiled activations (mlx-lm's `@mx.compile` geglu/swiglu) | on | both | L1 | `--compiled-activations on\|off` |
| Fused SDPA (optiq-exact quantized-KV attention) | follows `--kv-quant` | serial | L2 | `--fused-sdpa on\|off` |
| Paged KV (vLLM-style block pool, gather before the stock SDPA) | off | shared B1/B>1 | gated bit-exact vs plain `KVCache` | `--paged-kv`, `--paged-kv-block-size <n>` |
| Speculative decoding (two-model / Gemma `-assistant` / DSpark / DeepSpec / native MTP head) | off | shared Qwen methods; full-attention/rotating lookup/standalone and Gemma assistant/DeepSpec/DSpark; other combinations serial | per-drafter oracle (L1 two-model, L2 assistant, DeepSpec reference, Lab DSpark) | `--draft-model`, `--draft-kind`, `--num-draft-tokens` |
| GLM-5.2 checkpoint-native MTP | on for GLM-5.2 | serial+spec | oracle trajectory + synthetic HTTP gate | `--mtp on\|off` |
| Model-free prompt-lookup speculation (vLLM `ngram` port) | off | Qwen and full-attention targets shared / other models serial | lossless by verify (gated vs non-spec greedy) | `--draft-kind ngram`, `--ngram-max`, `--ngram-min`, `--num-draft-tokens` (default 10) |
| Estimated memory admission | off (advisory) | both | — | `--memory-budget <GB>` opts in |
| Aggregate KV admission for batch rows | off | batch | — | `--kv-budget <GB>` |
| Expert offload (MoE experts on mmap) | off | serial | Lab | `--expert-offload` |
| Extend-join (O(1) batch admission) | on | batch | L1 (mlx-lm `extend`) | `MLX_BUN_BATCH_EXTEND=0` |
| Vectorized greedy batch sampling | on | batch | bit-equal A/B | `MLX_BUN_BATCH_VEC_SAMPLE=0` |
| Pipelined batch token readback | on | batch | numerically equivalent | `MLX_BUN_BATCH_NO_PIPELINE=1` |

### Request features

| Feature | Default | Lane | Tier | Knob |
| --- | --- | --- | --- | --- |
| Structured output (`response_format` json_object/json_schema) | on | both | L2 (oMLX) | request field; `MLX_BUN_GRAMMAR=0` kills |
| Structured-output continuations (shared verified proposals / serial direct jump) | off | shared and serial | Lab | `MLX_BUN_GRAMMAR_JUMP=1` |
| Token fast-forwarding for tool calls (template-determined spans in one forward) | off | serial only | opt-in; identity tested on covered fixtures, parser/held-out gates remain (`tests/parity/fill-strict.test.ts`) | `MLX_BUN_FILL=strict` |
| Echo injection (session self-copy spans, verified against the same forward's logits) | off | serial only | Lab (paired A/B on task success + wall clock before any default) | `MLX_BUN_FILL=echo`, `MLX_BUN_FILL_K`, `MLX_BUN_FILL_CANDIDATES`, `MLX_BUN_FILL_INDEX_MAX` |
| `guided_grammar` (EBNF) / `guided_regex`¹ / `guided_choice` / `structured_outputs` | on | both | L2 | request fields |
| Structured output × speculative decoding | on when both active | Qwen grouped MTP, lookup and standalone drafting / eligible serial methods | Lab | — |
| Quantized KV × speculative decoding | Shared Qwen supports uniform KV4/KV8 and TQ with zero or positive conversion thresholds; strict serial supports qualified KV4; per-layer mixed KV remains excluded | Qwen grouped MTP, lookup and standalone drafting / eligible serial methods | scheme and method gates | `MLX_BUN_QWEN_SPEC_KV4=0` disables the KV4 composition |
| Tool calling (Gemma sentinel / CPM+Qwen XML / GLM `arg_key`+`arg_value`) + `role:"tool"` loops | on | both | — | request `tools` |
| Vision (`image_url`; PNG/JPEG/HEIC/AVIF/WebP/TIFF/GIF/BMP) | on for models with a tower; SSRF guard on remote URLs | serial | L1/L2 | `--allow-private-media` |
| Video input (`video_url`/`video`; AVFoundation sidecar, 2 fps, ≤768 frames, 256 MB body cap; never with audio) | on for Qwen3.5-family | serial | mlx-vlm oracle | `--allow-private-media`, `MLX_BUN_FRAME_EXTRACT` |
| Audio input (`input_audio`/`audio`/`audio_url`; WAV native, mp3/m4a/flac/ogg/aiff via CoreAudio; ≤30 s per clip; mixes with images) | on for models with `audio_config` + sidecar tower (e4b) | serial³ | L2 (greedy stream exact vs optiq's internal model) | `--allow-private-media` |
| LoRA adapters (mount at start / hot-swap) | off | compatible groups | — | `--adapter <dir>`, `POST /v1/adapters` |
| Sampling: temperature / top-p / top-k / min-p / XTC / logit_bias / presence+frequency+repetition penalties | per request | both | L1 (mlx-lm-faithful) | request fields / server defaults |
| `logprobs` / `top_logprobs` | off | both | L1 | request fields |
| Fixed `seed` reproducibility | off | both | — | request field; compare the same execution composition |
| Thinking-mode control (hybrid-reasoning models) | model default | both | — | `--thinking`, `chat_template_kwargs`, `reasoning_effort` |
| Stop sequences / streaming / usage accounting | on | both | — | request fields |
| HLG tone-curve sampling | off | serial | Lab | `--hlg-sampling on` |
| Spec-decode telemetry (`usage.speculation`) | on with a draft | Qwen shared MTP, lookup and standalone drafting / eligible serial methods | — | — |
| Token-fast-forwarding telemetry (`usage.fill`) | on with `MLX_BUN_FILL=strict` | serial | — | — |
| Per-turn lane telemetry (`usage.lane`: serial / serial+spec / batched) | on | both | — | — |

### Model coverage (per-model validated cells)

| Family | Serial | Batch | Notes |
| --- | --- | --- | --- |
| MiniCPM5 (cpm5) | ✅ L1/L2 | ✅ | the starter model |
| Gemma 4 (1B/e4b/12B/26B, + vision e4b/12B, + audio e4b) | ✅ L1/L2 | ✅ | sliding+full interleaved; MoE 26B |
| Qwen3.5 (gated-DeltaNet hybrid) | ✅ L1/L2 | ✅ (SSM path) | `MLX_BUN_BATCH_SSM=0` reverts |
| Qwen3.8-27B (same qwen3_5 graph) | ✅ L1 | ✅ (SSM path) | native MTP head via `--draft-model`/`--draft-kind mtp` (lossless-gated; slower on a quiet box — opt-in); images and video serve (mlx-vlm oracle) |
| GLM-5.2 / Colibri | ✅ chat/text, Messages, Responses, SSE, tools, grammar, logprobs | ✅ compressed MLA/DSA scheduler | native MTP shares the executor; final Colibri artifact testing is deferred; embeddings, vision/audio, adapters, training unsupported |
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
  supports the qualified grouped methods and cache layouts in the compatibility
  matrix. Use the default cap eight unless a workload calls for another cap.
- *UI must never lag / survive engine crashes:* add `--isolate`
  (`--model-pool 2` to keep two models resident).
- *Reproducibility:* bare / `--l1` (≡ mlx-lm), `--l1 --batch 1` (strict
  serial), `--l2` (≡ optiq).
- *Memory-tight big model:* `--kv-quant config|4|8|turbo` +
  `--memory-budget <GB>` + `--ssd-cache <dir>`; MoE adds
  `--expert-offload`. Start-zero TurboQuant supports shared execution.

**Remaining exclusions:** media, direct fill, and unsupported provider/layout
combinations. Qualified ordinary resume, paged storage and grouped draft
providers are implemented; see the compatibility matrix above.
Qwen ordinary, shared MTP and prompt lookup support positive library thresholds for uniform
affine KV4/KV8 and TurboQuant. Ordinary Gemma supports positive affine KV4/KV8
thresholds, including sliding-window layers. Other-model delayed affine remains
open. Qwen MTP
prefill and completed decode state use the common RAM/SSD cache. Generated
checkpoints contain only processed tokens; persistence uses the existing
queue. Chat preparation preserves generated token IDs when their decoded text
exactly prefixes the next rendered request, including provenance recovered from
SSD headers. This avoids a full prefill when re-encoding identical generated
text would choose a different BPE segmentation. Edited text retains ordinary
tokenization. Input token counts can differ from encoding the full prompt again;
cache state is always matched by exact IDs and execution namespace.
Strict serial deletion is deferred. Remaining feature and performance work
is tracked in Phase 6/18.

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

Managed quantization and finetuning jobs wait for the serving gateway to drain,
then hold its execution lease until their subprocess exits. Generation and native
preparation wait during that job. Shutdown cancels queued jobs and terminates the
host's active job before releasing its lease. Resident model weights remain
loaded. Under isolation, the parent coordinates all of its model-pool workers.
This controls execution, not memory capacity or independently launched servers.

### Delayed KV conversion in library requests

The CLI keeps `quantizedKvStart=0`. A library `KvScheme("turbo", ...)` can
set a positive threshold for ordinary or Qwen MTP shared execution. Every row converts
at its own existing maintenance boundary. During the mixed phase, the
cache retains plain and encoded rows independently while model attention
still runs at the shared batch size. The fetched attention state restores
only the rotated value rows; once all rows convert, the standard packed
batch layout takes over. Shared MTP converts committed history before a
verification round; crossing the threshold inside that round converts at
resolution after rollback and before checkpoint publication. Rejected tokens
cannot set the conversion offset.

Qwen ordinary, shared MTP and prompt lookup also support positive `quantizedKvStart` with
uniform affine KV4/KV8. Affine and TQ adapters share the same row-transition
lifecycle. During mixed affine precision, each row uses its existing plain or
quantized attention arithmetic; after conversion, the packed batch layout owns
attention. The model binding declares this support; scheduling does not choose
the codec or conversion boundary. Ordinary Gemma also supports delayed affine
conversion in full and sliding-window layers. Rotating rows retain the same
physical columns while converting independently, so shared attention masks stay
aligned. Gemma speculative methods and other-model delayed affine remain open.

A delayed conversion records the earliest reusable prefix offset. RAM and
SSD reuse preserve earlier plain donors and never trim converted state
below that boundary. Older TQ SSD files without this metadata remain
usable at their stored offset, but cannot serve shorter prefixes. The
start-zero default-group cache keys are unchanged; positive TQ and affine
thresholds, and non-default affine group sizes, have distinct keys.
No memory budget or admission default changes.


Supported grouped draft providers also accept TurboQuant with positive library
conversion thresholds. Full-attention layers use the selected codec; sliding
layers stay bf16. Generated target and method-companion snapshots preserve
precision through RAM and queued SSD persistence. Defaults are unchanged.
Composition evidence and remaining gaps: [batching design](../design/batching.md).

The programmatic `createServer` option `quantizedKvStart` sets the absolute
per-row offset at which the selected KV scheme converts. Omission preserves
the existing start-zero server policy. This option is resolved once with the
KV scheme and shared by request preparation, execution, and checkpoint identity.
Generation checkpoints preserve encoded state and each cache's earliest reusable
offset; restoring a checkpoint does not re-quantize it. TurboQuant retains its
existing full-attention scope, with sliding-window caches in bf16.
