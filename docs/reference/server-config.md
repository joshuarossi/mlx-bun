# Server configuration

Every start flag for `mlx-bun serve` (and `mlx-bun pi`, which shares the
same flag set), what each does, its default, and — the part that bites —
**which combinations compose and which don't**. For the request/response
wire format (chat/messages/responses bodies, SSE grammar, tool calling,
adapters admin) see [server-api.md](./server-api.md); this doc is about
*starting* the server.

The flags are parsed in `serverRuntimeFlags()`
([src/cli.ts](../../src/cli.ts)); the runtime knobs live in
`ServerOptions` ([src/server.ts](../../src/server.ts)). The two execution
lanes (serial vs. `--batch N`) and the lane picker are in
[src/serve/generation-gateway.ts](../../src/serve/generation-gateway.ts);
the design rationale is in
[docs/design/parallel-slots.md](../design/parallel-slots.md).

## Start flags

| Flag | Arg | Default | What it does |
| --- | --- | --- | --- |
| `--host` | addr | `127.0.0.1` | Interface to bind. Loopback-only by default (mlx_lm.server parity); pass `--host 0.0.0.0` to expose the server on your network. |
| `--port` | n | `8080` | Listen port. A pre-flight probe refuses to start if the port is already serving. |
| `--memory-budget` | GB | machine RAM × 0.75 | Admission ceiling. Requests whose `prompt + max_tokens` exceed the budget's max safe context are **rejected with 400** (`type: memory_admission`) instead of risking an uncatchable GPU OOM. Also caps the mlx allocator (`mlx_set_memory_limit`) as defense in depth. **Decimal GB (×10⁹).** |
| `--prompt-cache` | GB | `8` | RAM prefix-KV cache (byte-capped LRU; `0` disables). **PREFIX SHARING (2026-07-05): serves are NON-CONSUMING** — a hit hands out zero-copy clones and leaves the donor entry intact, so N agents (or a brand-new session) sharing a system prompt all reuse ONE prefill without destroying each other's conversation entries (the old consume-and-trim take cannibalized the donor). Extended entries supersede their prefix-ancestors (when trimmable), so a conversation stays one entry. Works on BOTH lanes and tiers over the SSD store (Layer 0). |
| `--isolate` | (bool) | off | Runtime isolation ([runtime-isolation.md](../design/runtime-isolation.md)): the inference engine runs as a CHILD process on a unix socket; this process stays a pure UI/API reverse proxy — instant under any GPU load, survives engine crashes (auto-respawn, in-flight requests get a clean 502). Measured cost ≈0 (−0.4% tok/s, +2 ms TTFT, per-token SSE granularity preserved). `/ws/chat` is not proxied yet (501). `/engine` reports child pid/restarts. |
| `--model-pool` | n | `1` | With `--isolate`: max RESIDENT model engines. Requests naming another model (**exact `/v1/models` id** — fuzzy strings keep mlx-lm's ignored-field semantics) spawn/route to that model's own engine child (SPAWN-OVERLAP: the new model loads while the old one keeps serving; nobody's stream is interrupted). Over the cap, the LRU engine drains, **demotes its prompt cache to the SSD tier**, and exits — switching back respawns it with state restored from disk. Measured (M1 Max, cpm5⇄qwen0.8b, pool 1): switch 1.5 s, switch-back 1.2 s with `cached_tokens` 103/104 — the conversation survived the eviction. |
| `--ssd-cache` | dir | off | SSD cold tier under the prompt cache ([docs/design/ssd-kv-cold-tier.md](../design/ssd-kv-cold-tier.md)): prefix KV spills to disk on RAM eviction AND idle demotion, is snapshotted after requests settle (debounced 1 s; the flush is idle-gated per tensor so it never taxes an active decode — `MLX_BUN_SSD_WRITEBEHIND=0` disables), and **survives restarts** — a long-context agent re-attach restores via a bounded streamed copy instead of re-prefilling (measured 13.7k-token prefix: 12 s → ~0.25 s TTFT; 0% decode overhead; restore transient = live entry + one tensor, no mapping outlives the load). Entries are keyed by model fingerprint **+ effective kv scheme** + tokenizer hash + adapter ns; incompatible/corrupt files self-quarantine. **Layer 0 (2026-07-05): the tiering lives inside PromptCache.take(), so BOTH lanes restore from disk — batch-scheduler joiners included — and every put (batch rows too) schedules the write-behind snapshot.** Requires the RAM cache. |
| `--ssd-cache-max` | GB | `32` | SSD tier byte cap (binary GiB); oldest-mtime entries evicted at the cap. |
| `--ssd-cache-verify` | (bool) | off | Verify every tensor hash on restore before it is copied in (roughly doubles restore reads) — integrity paranoia only; the header hash is always verified. |
| `--ssd-demote-idle` | sec | `300` (with `--ssd-cache`) | Idle demotion (Layer 0): prompt-cache entries unused this long spill to the SSD tier and **free their GPU memory** — unified memory drains between agent bursts while every prefix stays reachable (the next hit restores via the bounded streamed copy, ~0.25 s for a 13.7k-token entry vs a 12 s re-prefill). Swept only when the engine is fully idle (never drains a running batch). `0` disables. |
| `--batch` | n | `8` | Max concurrent requests decoded together. **Default flipped 1→8 (2026-07-05)** after GATE-B1-SPEED: a LONE request through the unified engine IS the serial engine — adopted serial-class caches, compiled decode, prompt cache + SSD restore, byte-identical output, 0.992–0.996 paired decode ratios — so the cap only changes behavior when concurrent requests actually arrive (the agentic sub-agent workload: 4–8 coding agents against one local server). `--batch 1` pins strict serial (arrival-independent numerics). See [Execution modes](#execution-modes-serial-vs---batch-n). `--decode-concurrency` is accepted for drop-in compatibility (mlx_lm.server's cap, default 32). |
| `--kv-quant` | `config`\|`off`\|`4`\|`8`\|`turbo[:k<bits>v<bits>]` | `off` (bf16) | KV-cache quantization. **Default flipped to bf16 2026-07-05** (naked = L1): quantized KV measured 5–20% slower decode than bf16 at ≤16k on every model — on mlx-lm too — so it pays only in **memory headroom** (e.g. ~1.3 GB on the 12B @16k) and is an explicit opt-in (`--kv-quant …` or `--l2`, whose preset passes `config`). `off` = bf16 (L1). `4`/`8` = **uniform** bits (group 64, start 0) — the scheme mlx-lm exposes as `--kv-bits`/`--kv-group-size`/`--quantized-kv-start`. In the L1 kernel set (`--l1 --kv-quant 8` = fused-sdpa off) our unfused quantized SDPA is **op-for-op identical** to mlx-lm's `quantized_scaled_dot_product_attention`, so uniform-quant is **bit-exact L1** (the fused-sdpa-ON path is optiq-aligned). `config` = **per-layer mixed-precision** from `kv_config.json` — optiq-only, no mlx-lm analog → **L2**. `turbo[:k<bits>v<bits>]` = **TurboQuant** ([docs/design/turboquant-kv.md](../design/turboquant-kv.md)): rotation-based KV quantization (asymmetric-affine int8/int4/int2/int5 keys, FWHT + Lloyd-Max values) — default `k8v3` (2.56× compression at head_dim 128); `kBits` ∈ {2,4,5,8}, `vBits` ∈ {2,3,4,5,8}. A separate axis from the scheme above (mutually exclusive with `config`/`4`/`8`); v1 is dequantize-on-fetch (stock `ops.sdpa`, no fused kernel) and **full-attention layers only** — sliding-window layers stay bf16 (one-time warning, never a throw). Under `--batch N`, a per-layer `config` scheme **batches** — full-attention layers since Phase 3.1 (MiniCPM5), rotating/sliding layers since milestone 2 (gemma's whole kv_config), so every shipped `kv_config.json` now batches. The scheduler applies the mixed scheme per row, gated bit-exact per row vs the serial composition (`tests/batched-kv-quant-parity.test.ts` — compositions no other stack ships). Uniform `4`/`8` still routes those requests serial (quantizedKvStart threshold semantics). **`turbo` is solo-only, unconditionally** — `TurboQuantKVCache` is a novel `Cache` implementation (no merge/filter/temporalView), so it's excluded from the batch scheduler by construction; `GenerationGateway.willBatch` also refuses it explicitly (belt + braces — both layers exist on purpose). |
| `--adapter` | dir | none | Mount a LoRA adapter at startup (same machinery as `POST /v1/adapters`; the adapter id is the directory's basename) and make it the **default** for requests that send no `adapter` field. A request's explicit `adapter` — including `"none"` — always wins, and hot-swap via `/v1/adapters` is unchanged. `--adapter-path` is accepted as the mlx_lm.server-named alias. A bad adapter fails startup loudly rather than silently serving the base model. This is the flag `mlx-bun train`'s completion message points at. |
| `--draft-model` | path/query | none | **Speculative decoding**: a drafter proposes tokens the main model verifies in one forward — exact results, faster decode when drafts land. Resolves like the main model. The artifact's **kind is auto-detected**: a full same-tokenizer model (mlx_lm.server parity — L1: token-for-token vs mlx-lm's spec path; tokenizer-family mismatch fails startup, upstream silently accepts ~0%), a Gemma `-assistant` KV-borrowing drafter (L2 vs optiq spec_generate; ~1.09× γ=1 on 12B, no training), a locally-trained **DSpark** checkpoint (`dspark.json`), or one of **DeepSeek's released DSpark drafters** (DeepSpec `Gemma4DSparkModel` config stamp, e.g. `deepseek-ai/dspark_gemma4_12b_block7` for the 12B — oracle: DeepSpec's reference at temperature 0, token-for-token). All four share ONE serve loop. A confidence-calibrated DSpark checkpoint additionally self-schedules its draft length per round (threshold pruning — fewer wasted verify positions; uncalibrated checkpoints draft fixed-length). Mounting a draft routes **every** request to the serial lane (upstream `is_batchable = draft is None`). Pays on slow targets (12B+); fast small models lose to the draft overhead. Composes with structured output (the constrained verify walk). Prompt-cache reuse is bypassed on the spec path (v1). Telemetry: `usage.speculation` (`drafted`/`accepted`/`targetCalls`). |
| `--draft-kind` | `two-model`\|`assistant`\|`dspark`\|`deepspec` | auto | Override the draft-artifact kind detection (`dspark.json` → dspark; `Gemma4DSparkModel` architecture stamp → deepspec; `*_assistant` config → assistant; else two-model). |
| `--num-draft-tokens` | n | `3` | Drafts per verify round (mlx_lm.server's default; `mlx_lm.generate`'s is 2). A DSpark draft pins this to its trained block width (`cfg.gamma`). |
| `--thinking` | `true`\|`false` | model's own (false for CPM) | Server-wide default for the chat template's `enable_thinking` (MiniCPM5/CPM and Qwen3.5 hybrid reasoning). A request's `chat_template_kwargs.enable_thinking` overrides it. |
| `--temperature` | n ∈ [0,5] | `generation_config.json` | Server-wide sampling default. Per-request `temperature` still wins; the browser chat (sends none) inherits this. `--temp` is accepted as an alias (mlx_lm.server compat); explicit `--temperature` wins if both are given. **Migration note:** mlx_lm.server's `--temp` *default* is `0.0` (unset-temperature requests are greedy there); mlx-bun falls back to the model's `generation_config.json`, then `0.7` — pass `--temp 0` for mlx-lm's behavior. |
| `--top-p` | n ∈ [0,1] | `generation_config.json` | Server-wide top-p default (per-request `top_p` wins). |
| `--top-k` | n ∈ [0,1e6] | `generation_config.json` | Server-wide top-k default (per-request `top_k` wins). |
| `--max-tokens` | n | `65536` chat / `512` raw completion | Completion cap when a request omits `max_tokens` (mlx_lm.server flag; its default there is 512 — `--max-tokens 512` reproduces mlx_lm.server exactly). |
| `--allow-private-media` | (bool) | off | Let `image_url`/`audio_url` content parts fetch from **private/loopback/link-local** hosts (a NAS, another LAN box). Off by default: a request's URL is attacker-controlled input, so remote media fetches (`src/media-fetch.ts`) refuse non-http(s) schemes and destinations in private/loopback/link-local/CGNAT ranges — including hosts that *resolve* there and every **redirect hop** (each hop re-passes the whole policy) — which keeps the server from being steered at cloud metadata (`169.254.169.254`) or LAN-internal services (SSRF). Independent of the flag, every remote fetch has a **10 s wall-clock timeout** and a **64 MB response cap** (streaming-enforced, not just Content-Length); violations surface as clean `400`s (`prompt build failed: …`). `data:` URLs decode locally and are never policy-checked. |
| `--no-open` | (bool) | off | Skip the automatic browser open on start. By default an interactive terminal session opens `http://<host>:<port>/#/chat` once the server is ready; pass this flag to suppress it (e.g. headless or non-TTY environments already skip it). |
| `--hlg-sampling` | `on`\|`off` | off | Piecewise tone-curve (HLG) sampling: rolls off the top-token region, boosts the mids, gentles the tail. The overall gain folds from `--temperature`. See [docs/design/hlg-sampling.md](../design/hlg-sampling.md). |
| `--hlg-width` | nats | `4` | HLG mid-region half-width (nats). Only meaningful with `--hlg-sampling on`. |
| `--hlg-shoulder` | nats | `4` | HLG highlight rolloff scale (nats). Only meaningful with `--hlg-sampling on`. |
| `--hlg-toe` | nats | `6` | HLG shadow rolloff scale (nats). Only meaningful with `--hlg-sampling on`. |
| `--hlg-pivot-offset` | nats | `6` | HLG pivot point: nats below the top token. Only meaningful with `--hlg-sampling on`. |
| `--expert-offload` | (bool) | off | **MoE models only.** Serve experts from a page-aligned file mmap (built on first use). Keeps the model out of memory pressure — physical footprint ≈ active params. Ignored with a warning on dense models. Bit-exact with the resident path. |
| `--l1` | (bool) | — | **Parity tier ALIAS:** bit-for-bit IDENTICAL to mlx-lm (bf16 KV, compiled decode + compiled activations — the faithful `@mx.compile` geglu/swiglu). **No tier given ⇒ `--l1`** (decided 2026-07-05: the L1 faithful kernel set matches mlx-lm 1.00× on every model and no output-changing lever has beaten that baseline in a paired A/B — each is opt-in until it does). Expands to the fastest set of per-fork flags that still holds the guarantee; any explicit per-fork flag (`--kv-quant`/`--fused-sdpa`/`--compiled-decode`/`--compiled-activations`) overrides one. See [docs/design/faithful-l1-consolidation.md](../design/faithful-l1-consolidation.md) and [parity-tier-dag.md](../design/parity-tier-dag.md). |
| `--l2` | (bool) | — | **Parity tier preset:** bit-for-bit IDENTICAL to mlx-optiq (quantized KV per `kv_config.json` + fused N-tiled prefill SDPA + **stock unfused decode** — the composition the optiq goldens track, `scripts/regen-kvq-goldens.ts`). |
| `--compiled-decode` | on\|off | on | Replay the per-step decode graph in C++ (`MLX_BUN_COMPILED_DECODE`). Bit-exact A/B lever. **Serial lane only** (see note below). **Gemma4-dense only** — LoRA, MoE, and non-Gemma4 models (MiniCPM5 / Qwen3.5) run eager; an unsupported step falls back to eager for the rest of that generation. |
| `--compiled-activations` | on\|off | on | Route the geglu/swiglu activation through mlx-lm's `@mx.compile` closure (`MLX_BUN_COMPILED_GEGLU` + `MLX_BUN_COMPILED_SWIGLU`) — the **faithful** kernel: same libmlx graph as mlx-lm → **bit-exact** AND one dispatch instead of ~9. `off` = the uncompiled composition (same L1 parity, slower). Toggles gemma geglu + MiniCPM5 swiglu; qwen3/qwen3.5/universal compile unconditionally. |
| `--fused-sdpa` | on\|off | follows `--kv-quant` | Fused SDPA path for quantized prefill/continuation (inverted env `MLX_BUN_NO_FUSED_SDPA`). Defaults to the composition its oracle uses: **on** under `--kv-quant config` (the optiq-golden composition), **off** under uniform `4`/`8` (mlx-lm's `quantized_scaled_dot_product_attention`, the bit-exact L1-eligible scheme) and bf16 (no-op there). **Serial lane only.** |
| `--force-wire` | (bool) | off | Wire weights into memory for the whole generation (`MLX_BUN_FORCE_WIRE`). Near-ceiling models (e.g. 26B) need it. **Serial lane only.** |

The default host/port (`127.0.0.1:8080`) match `mlx_lm.server`, so running
mlx-bun alongside the Python reference server needs an explicit `--port`.

The remaining levers are bit-exact A/B knobs; **the naked default is the
L1 set** (2026-07-05 decision: an output-changing lever earns a default
only by beating the L1 faithful baseline in a paired A/B, and none did —
the 2026-07-05 pass measured the custom fused-decode at 1.00×, fused-gelu
at +0–1%, the flash perf-kernel at 0.62–0.93× on e4b, and quantized KV
5–20% *slower* decode than bf16 at ≤16k on both stacks; those losing
kernels and their flags were **deleted** the same day — Phase 1 of
[unified-engine-frontier-plan.md](../design/unified-engine-frontier-plan.md).
New output-changing experiments live in the **Lab**: env-flagged, with a
bench + expiry, until one beats the L1 baseline in a paired A/B). Flip
the survivors to compare. They are set as `MLX_BUN_*` env vars before the
model loads, so they apply to `mlx-bun pi` too. They affect the
**serial** decode path (`generate()`); the batched scheduler calls
`model.forwardHidden` directly and is unaffected by all of them except
`--compiled-decode`, which also covers a lone batch-lane request (Phase
3.2) — see
[Levers that don't reach the batched lane](#--batch-n-is-compat-mode--perf-flags-dont-apply-by-design).

## Per-request overrides

Most quality knobs can be set per request in the chat body and override
the server-wide default. Precedence, highest first:

1. explicit request field (`temperature`, `top_p`, `top_k`, `seed`,
   `min_p`, `xtc_probability`/`xtc_threshold`, `logit_bias`,
   `repetition_penalty`, `presence_penalty`/`frequency_penalty` (+ their
   `*_context_size` windows), `max_tokens`/`max_completion_tokens`, `stop`,
   `chat_template_kwargs.enable_thinking`, `adapter`, `tools`)
2. the matching `--temperature`/`--top-p`/`--top-k`/`--thinking` server default
3. the model's `generation_config.json`
4. the built-in fallback (temp 0.7, top-p/top-k 0 = off)

These ride all three protocol surfaces (`/v1/chat/completions`,
`/v1/messages`, `/v1/responses`) because each funnels through one
`handleChat`. Full field list: [server-api.md](./server-api.md).

## Environment levers

The CLI flags above set these; you can also export them directly (e.g.
for paired A/B harnesses).

| Env var | CLI flag | Default | Effect |
| --- | --- | --- | --- |
| `MLX_BUN_COMPILED_DECODE` | `--compiled-decode` | on (`!=="0"`) | Compiled decode graph replay. |
| `MLX_BUN_NO_FUSED_SDPA` | `--fused-sdpa` (inverted) | follows `--kv-quant` | `=1` forces the stock unfused SDPA everywhere. |
| `MLX_BUN_COMPILED_GEGLU` | `--compiled-activations` | on (`!=="0"`) | Gemma geglu via mlx-lm's `@mx.compile` closure — the faithful default (bit-exact vs mlx-lm, one kernel). `=0` → uncompiled composition (same parity, slower). |
| `MLX_BUN_COMPILED_SWIGLU` | `--compiled-activations` | on (`!=="0"`) | `mx.compile`'d SwiGLU (`silu(gate)·up` → one kernel) on MiniCPM5 decode (M=1), porting mlx-lm's `activations.py`. Bit-exact (passes the exact logit-parity gate), both lanes. +5.5% CPM5 decode. (qwen3/qwen3.5/universal compile swiglu unconditionally, independent of this flag.) |
| `MLX_BUN_FORCE_WIRE` | `--force-wire` | off (`==="1"`) | Wire weights for the generation. |
| `MLX_BUN_ALLOW_PRIVATE_MEDIA` | `--allow-private-media` | off (`==="1"`) | Permit `image_url`/`audio_url` fetches to private/loopback/link-local hosts (the SSRF guard's LAN escape hatch — see the flag row above; timeout + size cap still apply). |
| `MLX_BUN_PREFILL_TAIL_SPLIT` | — | on (`!=="0"`) | Oracle prefill convention (mlx-lm `generate_step` and its server's batched engine): drain the prompt only to len−1, then compute step-0 logits from a separate **L=1 forward of the last prompt token**. Both lanes. **The SPEC lane (`--draft-model`) follows its own oracle's shape under the same flag** (mlx-lm `speculative_generate_step`, re-anchored 2026-07-07): both target AND draft drain to len−1 and there is **no separate step-0 at all** — the un-drained last prompt token heads the first verify window. Gated live: token-for-token vs the oracle venv incl. a knife-edge cell (tests/spec-serve.test.ts "L1 knife-edge"). (The standalone optiq-oracled assistant loop `specGenerate` deliberately keeps FULL-prompt prefill — optiq's own convention.) `=0` restores the pre-2026-07-07 full-final-chunk convention everywhere (A/B lever + kill switch) — that convention is ulp-different in bf16 at step 0 AND in the last prompt token's stored KV, which flips near-tie greedy streams vs mlx-lm (the 2026-07-07 12B completion-probe divergence). |
| `MLX_BUN_SSD_WRITEBEHIND` | — | on (`!=="0"`) | `--ssd-cache`'s debounced write-behind snapshot (restart survival). `=0` disables it entirely — the paired-A/B lever + kill switch for the 2026-07-07 idle-gating fix (eviction/demotion spills still write). The flush is **idle-gated**: every per-tensor step (blocking GPU sync + `writeSync`) waits for the engine to go idle and pauses when a request arrives mid-flush, so durability work never taxes an active decode (pre-fix: a ~16k entry's flush overlapping cached ctx repeats cost e4b ~9% decode@ctx vs mlx-lm). |

(`MLX_BUN_PERF_KERNEL`, `MLX_BUN_FUSED_GELU`, `MLX_BUN_FUSED_DECODE`,
`MLX_BUN_FUSED_SWIGLU*`, and `MLX_BUN_CPM5_FAITHFUL` were deleted
2026-07-05 with their kernels — see
[unified-engine-frontier-plan.md](../design/unified-engine-frontier-plan.md);
exporting them now does nothing.)

## Execution modes: serial vs. `--batch N`

Batching is **concurrency-driven** (default cap 8, flipped 2026-07-05): a
lone request runs the exact serial engine — its caches are ADOPTED
serial-class objects, compiled decode replays, the prompt cache and SSD
tier serve it — and only a second concurrent request causes a batch
layout to exist. "How many requests you send" is the batching decision;
the flag is just the cap.

`--batch 1` pins the strict serialized single-queue path: one generation
at a time, arrival-independent numerics (a request's bits never depend on
what else was in flight). Pin it for golden regeneration and
reproducibility work. Note the trade is real but small: batched rows
carry bf16 left-pad reduction-order noise vs their solo runs (calibrated
per model in the gated suites) — a request that never shares a step is
bit-identical either way.

The batched engine is **bit-parity with `mlx_lm.server` at `B=N`** per
row for bf16, and per-row oracle-gated for the quantized compositions
(Phase 3.1 + milestone 2 — compositions mlx-lm does not ship):

- **KV quant unset ⇒ bf16** — the batch path engages out of the box
  (bf16 is the serial default too, since 2026-07-05).
- **`--kv-quant config`** (per-layer mixed precision) **batches** on
  every shipped model — full-attention layers since Phase 3.1 (cpm5),
  rotating layers since milestone 2 (gemma) — applied per row, gated
  bit-exact/KL-0 for unpadded rows vs the serial composition.
- **`--kv-quant 4|8`** (uniform bits) routes those requests to the
  serial lane (quantizedKvStart threshold semantics; a startup warning
  is printed).

### The lane picker (`GenerationGateway.willBatch`)

Under `--batch N`, each request is routed per-request. It joins the
batch only if **all** of these hold; otherwise it drains the batch and
runs solo (mlx-lm's `_is_batchable` behavior). The two lanes are
mutually exclusive on the GPU (one `AsyncMutex`), so a serial-fallback
request never runs alongside a batched step — but batched requests run
concurrently with each other.

| Request property | Batches? |
| --- | --- |
| vision (image parts) | ❌ serial — needs offset-0 single-seq prefill + bidirectional image mask |
| LoRA `adapter` (resolves to ≥1) | ❌ serial — `loraState.active` is one per-generation field; per-row adapters unsupported |
| `logprobs` / `top_logprobs` | ❌ serial — the batched sampler doesn't capture logprob arrays yet |
| explicit `seed` | ❌ serial — reproducibility ⇒ solo (matches mlx-lm) |
| KV quant active (explicit `--kv-quant`) | ✅ batches for per-layer `config` schemes — full-attention layers (Phase 3.1) AND rotating layers (milestone 2: gemma's kv_config; unpadded row gated KL-0 vs serial); uniform bits → serial |
| `--kv-quant turbo` (TurboQuant) | ❌ serial, unconditionally — solo-only in v1 (novel `Cache` class, no batched merge/filter/temporalView; belt-and-braces refusal in `willBatch` on top of the automatic capability-gate exclusion) |
| `--draft-model` mounted | ❌ serial, server-wide — speculation is a B=1 latency mode (upstream `is_batchable = draft is None`) |
| `repetition_penalty` / `min_p` / `xtc_*` / `logit_bias` / presence+frequency penalties | ✅ batches — per-row logits processors over a per-row device-side history (since 2026-07-02; some models — Qwen3.5 — ship a *default* repetition penalty, which used to route everything serial) |
| structured output (`response_format` / `guided_*`) | ✅ batches — per-row grammar matchers driven by the scheduler (`MLX_BUN_GRAMMAR_BATCH=0` forces serial) |
| `temperature` / `top_p` / `top_k` | ✅ batches (each row samples with its own seed) |
| `stop` sequences | ✅ batches (per-row `StopMatcher` in the onToken closure) |
| `tools` / `tool_choice` | ✅ batches (per-row tool router; decode-layer parse) |
| `--thinking` / `enable_thinking` | ✅ batches (template-render concern, lane-independent) |
| multi-turn / long prompt | ✅ batches **with prompt-cache reuse** (Phase 3.2): a joiner restores the longest usable cached prefix and prefills only the suffix (`cached_tokens` reported); a request that finishes without ever sharing the batch puts its caches back. **Prefix sharing (2026-07-05): serves are non-consuming clones**, so concurrent agents with a shared system prompt all reuse one prefill and nobody's entry is destroyed. A row that merges with others is not re-put (its entry ages out) — heavy concurrency reduces hit rate, never correctness |

**Which models batch:** full-attention (CPM), sliding-window (Gemma),
hybrid gated-DeltaNet (Qwen3.5 — the SSM batched path, token-exact vs the
mlx-lm B=2 oracle, landed 2026-07-02; `MLX_BUN_BATCH_SSM=0` reverts it to
serial routing), and **plain full-attention Tier-0 universal archs**
(Llama etc. — per-row RoPE gated token-exact vs mlx-lm B=2, 2026-07-03).
Still serial by the model-level capability gate: gemma2-family and
sliding-window *universal* archs (unvalidated cells) and DiffusionGemma
(non-autoregressive).

A non-batchable request **drains** the batch: while it waits, the
scheduler stops admitting new rows, finishes the running ones, and
releases the GPU so the serial request runs (mlx-lm's `drain_batch`);
admission then resumes. So a steady stream of batchable traffic cannot
starve a serial-lane request.

`--batch N` is a **mode switch, not a load-dependent fallback**:
auto-batching "when >1 request arrives" was considered and rejected —
an idle vs. loaded server would produce different numerics for the same
request, breaking determinism and the drop-in-for-`mlx_lm.server`
promise.

## Compatibility matrix

How each option behaves in each mode. "serial" = `--batch 1`; "`--batch N`"
= the batched mode (a given request may still take the serial *lane*
inside it per the table above).

| Option | serial (`--batch 1`) | `--batch N` (N>1) |
| --- | --- | --- |
| `--kv-quant config`/`4`/`8` | ✅ applied to all requests | ⚠️ applied, but forces **all** requests to the serial lane (no batching) |
| `--kv-quant turbo[:k<bits>v<bits>]` | ✅ applied to all requests | ⚠️ applied, but forces **all** requests to the serial lane (no batching) |
| `--kv-quant off` | ✅ bf16 | ✅ bf16 (same as the implicit batch default) |
| *(kv-quant unset)* | bf16 (the L1 default) | **bf16** (Option B) — incl. serial-lane fallback requests |
| `--memory-budget` | ✅ per-request admission | ✅ per-request admission — but **not aggregate** across rows (see limitations) |
| `--prompt-cache` | ✅ prefix reuse | ✅ prefix reuse on BOTH lanes (Phase 3.2): batch joiners `take()` at admission; lone never-merged rows `put()` back on finish (merged rows' entries age out) |
| `--temperature`/`--top-p`/`--top-k` | ✅ | ✅ (per-row) |
| `--thinking` | ✅ | ✅ |
| vision request | ✅ | ✅ via serial lane (in bf16 under Option B) |
| LoRA `adapter` | ✅ | ✅ via serial lane |
| `repetition_penalty` | ✅ | ✅ (batches — per-row logits processors, since 2026-07-02) |
| `min_p` / `xtc_*` / `logit_bias` / presence+frequency penalties | ✅ | ✅ (batches — same per-row processors) |
| `seed` | ✅ | ✅ via serial lane |
| `tools` / `stop` | ✅ | ✅ (batches) |
| structured output (`response_format`/`guided_*`) | ✅ (mask in the decode loop) | ✅ (batches; per-row matchers) |
| `--draft-model` | ✅ spec decode (grammar composes) | ⚠️ mounts, but routes **every** request serial — spec and batching are different modes |
| `--compiled-decode` | ✅ (serial decode route) | ✅ at **B=1 only** (Phase 3.2): a lone request's adopted serial-class caches replay the same compiled step, same kill switch; B>1 steps run the plain graph |
| `--fused-sdpa`/`--force-wire` | ✅ (serial decode route) | **n/a — compat mode, no perf flags by design** |

### `--batch N` is compat mode — perf flags don't apply by design

The bit-parity guarantee (mlx-lm B=N) is the *whole point* of `--batch N`,
and it requires running the plain forward path. So the batched lane
deliberately exposes **no** perf knobs: the scheduler
([batch-scheduler.ts](../../src/serve/batch-scheduler.ts)) drives the
model through `forwardHidden`/`logitsFromHidden` directly (not
`generate()`), running the same bit-exact kernels mlx-lm runs — never the
optional, parity-breaking ones. Flagging the batched lane would defeat
the guarantee, so it's intentionally not wired.

- **`--compiled-decode`** — engages at **B=1 only** (Phase 3.2,
  adopt-don't-copy): a lone request's caches stay serial-class, so the
  scheduler replays the serial engine's compiled step — bit-exact by the
  same gate, `MLX_BUN_COMPILED_DECODE=0` is the same kill switch. The
  moment a second row joins, steps run the plain batched graph.
- **`--fused-sdpa`** — never engages in the batched lane (the fused
  quantized-KV SDPA is an L2 serial-lane composition). See the
  validation matrix in [parallel-slots.md](../design/parallel-slots.md).
- **`--force-wire`** — doesn't wire (the scheduler bypasses `generate()`'s
  wired scope). A model that needs wiring for speed (e.g. 26B: 8.6 → 32.3
  tok/s wired) runs at mlx-lm-equivalent unwired speed under `--batch N`;
  in practice such a model has no headroom for B>1 KV anyway.
- **Always-on bit-exact kernels still run.** The compiled activations
  (mlx-lm's own `@mx.compile` geglu/swiglu) are bit-exact with the
  spelled-out MLP, so they stay on in both lanes without breaking
  parity — "compat mode" means *no parity-breaking optionality*, not
  -O0.

The serial lane is where the decode route lives: `--compiled-decode` /
`--fused-sdpa` / `--kv-quant` (and the `--l2` optiq composition) engage
there.

## Known limitations under `--batch N`

These are deliberate v1 scope, not bugs — but they change behavior, so
know them:

1. **Prompt cache bypassed.** Batched requests solo-prefill every row;
   `cached_tokens=0`. Wiring `PromptCache` into the scheduler is a
   follow-up. (The **spec path bypasses it too** — a `--draft-model`
   server re-prefills every request; the target+draft cache-entry
   composition is designed in mlx-lm-tool-parity-plan §7.6, not built.)
2. **Aggregate admission is opt-in.** `--memory-budget` checks each
   request against single-sequence max-safe-context; the AGGREGATE cap
   across N concurrent rows is `--kv-budget <GB>` (landed 2026-07-03):
   over-budget joiners queue until rows finish, a request over the budget
   alone rejects. Without `--kv-budget`, N large-context rows can still
   collectively exceed memory (uncatchable GPU OOM) — set it when running
   `--batch N` near the machine's limit.
3. **Short-context only.** Verified pre-ring-wrap (rows < the 1024
   sliding window). Long-context (context > window) batched decode is a
   separate validation.
4. **bf16 by default — by contract; mixed-KV batching beyond it.**
   mlx-lm's batched path *is* bf16, so bf16 batching is exactly what
   mlx-lm-parity means. Phase 3.1 adds batched per-layer MIXED KV for
   all-full-attention configs — a beyond-mlx-lm composition, verified
   per row against the optiq oracle instead (not a
   shortcoming). Going further — batched + mixed-precision KV quant — is
   novel territory with no mlx-lm/optiq oracle, so it's a deferred,
   KL-gated extension.
5. **`extend` join (landed 2026-07-03).** A joining request appends to
   the running batch's full-attention KV in one pad+concat (mlx-lm
   `BatchKVCache.extend` semantics, token-exact vs its oracle);
   `MLX_BUN_BATCH_EXTEND=0` reverts to the old whole-batch re-merge
   (numerically equivalent, O(B·S)). Sliding-window layers still re-merge
   on join (rotating-extend is a follow-up).

## Fidelity tiers and the decode route (`--l1` / `--l2`)

The tiers are **correctness contracts**, and each flag is an alias for a
decode-route preset (`applyDecodeRoute()` in [src/cli.ts](../../src/cli.ts));
any per-fork flag (`--kv-quant`, `--compiled-decode`,
`--compiled-activations`, `--fused-sdpa`)
overrides its tier's preset.

| Tier | Contract | KV | Kernels | Verified against |
| --- | --- | --- | --- | --- |
| `--l1` | mlx-lm **bit-for-bit** | bf16 | compiled-decode + compiled activations (faithful geglu/swiglu) | mlx-lm goldens (per machine) |
| `--l2` | mlx-optiq **bit-for-bit** | mixed-precision (`kv_config.json`) | + fused-SDPA (matches optiq exactly) | optiq goldens |
| *(none)* | **= `--l1`** | bf16 | compiled-decode + compiled activations | mlx-lm goldens |

Compiled-decode is on in **every** tier (proven bit-exact with uncompiled —
free speed, not a fidelity trade).

**There is no `--l3` tier anymore** (removed 2026-07-05; passing `--l3`
errors out with a pointer). The tier had no content: every kernel it
gated lost its paired A/B against the L1 baseline and was deleted. Its
role is replaced by the **Lab** — output-changing experiments run as env
flags with a bench + expiry, and one graduates only by beating the L1
baseline in a paired A/B. See
[docs/design/unified-engine-frontier-plan.md](../design/unified-engine-frontier-plan.md).

**KV precision is a separate axis from the tier's kernels.** Each tier row shows its
*default* KV scheme, but KV is not what defines the tier. mlx-lm supports **uniform**
quantized KV (`--kv-bits`), and `--l1 --kv-quant 8` is a **bit-exact L1** config: with
fused-sdpa off (the L1 default) our quantized decode runs `quantizedSdpaUnfused`,
which is op-for-op identical to mlx-lm's `quantized_scaled_dot_product_attention`
(`mlx_lm/models/base.py`) — same `mx.quantized_matmul` ×2 + `mx.softmax(precise=True)`
+ `where(…, finfo.min)`. bf16 is just the simplest L1 default. The **fused / N-tiled**
quantized path (fused-sdpa ON — the `--kv-quant config` / `--l2` composition) is the
**optiq**-aligned one. Only the **per-layer mixed-precision** `config` scheme is
optiq-only (→ L2).

**Where each feature sits:** batching = L1-class (mlx-lm B=N parity);
speculative decoding = L1-class (token-for-token vs mlx-lm's spec path);
structured output = L2-class (oMLX oracle; masking doesn't touch the
numerics of valid tokens, so it composes with any tier); grammar × spec
together, HLG sampling, expert offload, and (future) batched quantized KV
are **no-oracle (Lab-gated)** — no ancestor runtime does them, so they're
gated by validity/KL/quality instead of bit-parity.

## Performance characteristics & recipes

Reference numbers are from this project's dev machines (loaded-machine
numbers are directional only; `benchmarks/RESULTS.md` holds the quotable
set, and `scripts/bench-feature-matrix.ts` measures the six composition
cells in one run).

- **Serial is the fastest single stream** — prompt cache, mixed-precision
  KV, compiled decode. The batch lane at ONE live row is ~25% slower
  (cpm5 ~149 vs 193 tok/s: no prompt cache, no kv-quant, wrapper
  overhead), which is why serial stays the default.
- **`--batch N` wins under concurrency** — cpm5 `--batch 4`: ~349 tok/s
  aggregate vs ~173 serial-queued, TTFT 2–3× better; Llama-3B at just
  B=2: 1.7× aggregate, TTFT 765→162 ms.
- **Spec pays only on slow targets.** One accepted draft = one skipped
  target forward, so value scales with target step cost: 12B ≈ 1.09× at
  γ=1 (measured); fast small targets LOSE (e4b 0.78×; 3B smoke: spec
  61.5 vs serial 81.5 tok/s). Draft for 12B+, skip below.
- **Structured output is ~free** (<1% serial; the batch lane drops to
  read-before-build scheduling while a grammar row is live — bounded,
  ~0.1 ms/step class).
- **`--ssd-cache` has 0% decode overhead** — pure TTFT/restart win; no
  reason to leave it off on a persistent server.
- **Quantized-KV prefill pays a scheme-intrinsic tax at long context** —
  chunked prefill converts each chunk's KV at the chunk boundary, so
  every later chunk attends against the already-quantized prefix
  (quantize-on-write; the same streaming conversion optiq serve uses —
  `maybeQuantizeKv` in `src/generate.ts` is the port). That cost is by
  design, not an implementation gap: ~30% prefill throughput vs bf16 at
  ~16k where the config quantizes every cache (the 1B starter measured
  −33% in the 2026-07-06 serve pass), single-digit % on the
  sliding-window gemmas (rotating caches stay window-bounded). The lever
  is upstream — mlx's `quantized_matmul` kernels (the split-K work,
  [ml-explore/mlx#3120](https://github.com/ml-explore/mlx/pull/3120);
  status in [decode-speed-program.md](../design/decode-speed-program.md)
  lever 2) — not this codebase.

**Recipes:**

- *Single-user agent/chat (the default use):*
  `mlx-bun serve <model> --ssd-cache <dir>` — L1 serial, prompt cache +
  SSD tier. On 12B+ add `--draft-model <small-same-tokenizer>`.
- *Several clients at once (throughput):*
  `mlx-bun serve <model> --batch 4 --ssd-cache <dir>` — don't set
  `--kv-quant` (it would just un-batch everything), don't mount a draft.
- *Reproducibility:* bare / `--l1` (≡ mlx-lm), `--l1 --batch N`
  (≡ mlx-lm B=N), `--l2` (≡ optiq).
- *Memory-tight big model:* serial + `--kv-quant config|4|8` +
  `--memory-budget <GB>` + `--ssd-cache <dir>`; MoE adds
  `--expert-offload`. Inherently the serial recipe until batched
  quantized KV lands.

**The two exclusions to remember:** batching ⊕ kv-quant (batch is bf16 by
contract; the resolver is a Lab-gated follow-up) and spec ⊕ prompt
cache (v1 bypass; the §7.6 composition is the fix).

## Observability — `GET /stats`

The live config and batch state:

```jsonc
{
  "server":  { "owner": "serve" | "pi-session" | "embedded", "model": "...", "started_at": 0 },
  "prompt_cache":  { "entries": 0, "bytes": 0, "max_bytes": 2000000000, "hits": 0, "misses": 0 },
  "response_store": { "entries": 0, "bytes": 0, "max_bytes": 33554432, "ttl_ms": 3600000 },
  "kv_quant": {
    "mode": "mixed (kv_config.json)" | "uniform-kv8" | "bf16",
    "layers": { "kv4": 8, "bf16": 40 },
    "attention": { "global": 10, "sliding_window": 38 }
  },
  "admission": {
    "max_safe_context": 0,          // requests above this 400
    "memory_budget_bytes": null,    // explicit budget, or null = machine default
    "usable_bytes": 0, "weights_bytes": 0
  },
  "batch": {
    "configured": 1,                // the --batch N value
    "batched": false,               // batching enabled (N>1) for this server
    "active_rows": 0                // rows currently decoding in the batch
  }
}
```

`batch.batched` reflects only whether `--batch N` (N>1) is configured;
with an explicit `--kv-quant` it can read `true` while `active_rows`
never exceeds 1 (every request routes serial). `active_rows` is the
honest signal of whether anything is actually batching.
