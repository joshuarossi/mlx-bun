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
| `--prompt-cache` | GB | `2` (≈2e9 bytes) | Byte cap for the prompt (prefix-reuse KV) cache. **Binary GiB (×2³⁰)** on input. Unset ⇒ the 2 GB default; an explicit `--prompt-cache 0` **disables** the cache (maxBytes 0 evicts every entry). |
| `--batch` | n | `1` (serial) | Max concurrent requests batched through the mlx-lm-parity engine. `>1` switches the **whole server** into bf16 continuous batching — a *mode*, not a load fallback. See [Execution modes](#execution-modes-serial-vs---batch-n). `--decode-concurrency` is accepted for drop-in compatibility, but the semantics differ: in mlx_lm.server it caps per-BatchGenerator decode parallelism (default 32); in mlx-bun it enables continuous batching with this cap (mlx-bun's default is the optimized serial path). |
| `--kv-quant` | `config`\|`off`\|`4`\|`8` | `config` serial / `off`(bf16) under `--batch N` | KV-cache quantization. `config` = per-layer `kv_config.json` (optiq parity); `off` = bf16; `4`/`8` = uniform bits (group 64, start 0). Under `--batch N`, an explicit value routes those requests to the **serial** lane (batched is bf16-only). |
| `--adapter` | dir | none | Mount a LoRA adapter at startup (same machinery as `POST /v1/adapters`; the adapter id is the directory's basename) and make it the **default** for requests that send no `adapter` field. A request's explicit `adapter` — including `"none"` — always wins, and hot-swap via `/v1/adapters` is unchanged. `--adapter-path` is accepted as the mlx_lm.server-named alias. A bad adapter fails startup loudly rather than silently serving the base model. This is the flag `mlx-bun train`'s completion message points at. |
| `--thinking` | `true`\|`false` | model's own (false for CPM) | Server-wide default for the chat template's `enable_thinking` (MiniCPM5/CPM and Qwen3.5 hybrid reasoning). A request's `chat_template_kwargs.enable_thinking` overrides it. |
| `--temperature` | n ∈ [0,5] | `generation_config.json` | Server-wide sampling default. Per-request `temperature` still wins; the browser chat (sends none) inherits this. `--temp` is accepted as an alias (mlx_lm.server compat); explicit `--temperature` wins if both are given. **Migration note:** mlx_lm.server's `--temp` *default* is `0.0` (unset-temperature requests are greedy there); mlx-bun falls back to the model's `generation_config.json`, then `0.7` — pass `--temp 0` for mlx-lm's behavior. |
| `--top-p` | n ∈ [0,1] | `generation_config.json` | Server-wide top-p default (per-request `top_p` wins). |
| `--top-k` | n ∈ [0,1e6] | `generation_config.json` | Server-wide top-k default (per-request `top_k` wins). |
| `--max-tokens` | n | `65536` chat / `512` raw completion | Completion cap when a request omits `max_tokens` (mlx_lm.server flag; its default there is 512 — `--max-tokens 512` reproduces mlx_lm.server exactly). |
| `--no-open` | (bool) | off | Skip the automatic browser open on start. By default an interactive terminal session opens `http://<host>:<port>/#/chat` once the server is ready; pass this flag to suppress it (e.g. headless or non-TTY environments already skip it). |
| `--hlg-sampling` | `on`\|`off` | off | Piecewise tone-curve (HLG) sampling: rolls off the top-token region, boosts the mids, gentles the tail. The overall gain folds from `--temperature`. See [docs/design/hlg-sampling.md](../design/hlg-sampling.md). |
| `--hlg-width` | nats | `4` | HLG mid-region half-width (nats). Only meaningful with `--hlg-sampling on`. |
| `--hlg-shoulder` | nats | `4` | HLG highlight rolloff scale (nats). Only meaningful with `--hlg-sampling on`. |
| `--hlg-toe` | nats | `6` | HLG shadow rolloff scale (nats). Only meaningful with `--hlg-sampling on`. |
| `--hlg-pivot-offset` | nats | `6` | HLG pivot point: nats below the top token. Only meaningful with `--hlg-sampling on`. |
| `--expert-offload` | (bool) | off | **MoE models only.** Serve experts from a page-aligned file mmap (built on first use). Keeps the model out of memory pressure — physical footprint ≈ active params. Ignored with a warning on dense models. Bit-exact with the resident path. |
| `--l1` | (bool) | — | **Parity tier preset:** bit-for-bit IDENTICAL to mlx-lm (bf16 KV, unfused SDPA, no perf kernel). Sets the whole decode route; any explicit per-fork flag (`--kv-quant`/`--perf-kernel`/…) overrides the preset. See [docs/design/parity-tier-dag.md](../design/parity-tier-dag.md). |
| `--l2` | (bool) | — | **Parity tier preset:** bit-for-bit IDENTICAL to mlx-optiq (quantized KV per `kv_config.json` + fused N-tiled prefill SDPA + **stock unfused decode** — the composition the optiq goldens track, `scripts/regen-kvq-goldens.ts`). The perf kernel stays **off**: it is envelope-gated, not bit-exact (see `--l3`), and opting into it (`--l2 --perf-kernel on`) is an explicit choice that leaves the bare-tier guarantee. |
| `--l3` | (bool) | — | **Parity tier preset:** best performance, no bit-exact oracle (KL + test gated). On the decode path L3 = L2 + the envelope-gated perf kernel; L3 also owns the no-oracle features (HLG sampler, expert offload). No tier given ⇒ the per-flag defaults below, which equal `--l3`. |
| `--compiled-decode` | on\|off | on | Replay the per-step decode graph in C++ (`MLX_BUN_COMPILED_DECODE`). Bit-exact A/B lever. **Serial lane only** (see note below). **Gemma4-dense only** — LoRA, MoE, and non-Gemma4 models (MiniCPM5 / Qwen3.5) run eager; an unsupported step falls back to eager for the rest of that generation. |
| `--perf-kernel` | on\|off | **on** | Fused quantized-KV decode-SDPA Metal kernel (`MLX_BUN_PERF_KERNEL`), the perf side of the compat A/B. **Not bit-exact** — envelope-gated (≥56/64 teacher-forced argmax vs the frozen compat trajectory, `tests/perf-kernel-oracle.test.ts`), so it is an **L3 lever**: on in `--l3`/no-tier default, **off in bare `--l1`/`--l2`**. Engages on quantized caches at decode. **Serial lane only.** |
| `--fused-decode` | on\|off | off | Experimental: tile the quantized decode SDPA (`MLX_BUN_FUSED_DECODE`). **Serial lane only.** |
| `--fused-sdpa` | on\|off | on | Fused SDPA path for quantized prefill/continuation (inverted env `MLX_BUN_NO_FUSED_SDPA`). **Serial lane only.** |
| `--force-wire` | (bool) | off | Wire weights into memory for the whole generation (`MLX_BUN_FORCE_WIRE`). Near-ceiling models (e.g. 26B) need it. **Serial lane only.** |

The default host/port (`127.0.0.1:8080`) match `mlx_lm.server`, so running
mlx-bun alongside the Python reference server needs an explicit `--port`.

The five performance levers are A/B knobs whose defaults are the measured
winners; flip them to compare. They are set as `MLX_BUN_*` env vars
before the model loads, so they apply to `mlx-bun pi` too. They affect
the **serial** decode path (`generate()`); the batched scheduler calls
`model.forwardHidden` directly and so is unaffected by all of them — see
[Levers that don't reach the batched lane](#--batch-n-is-compat-mode--perf-flags-dont-apply-by-design).

> **Note — `--perf-kernel` default.** The code defaults it **on**
> (`perfKernelEnabled()` returns true unless `MLX_BUN_PERF_KERNEL=0`, and
> the ready card / `/stats` report it on). `STATUS.md` still lists a
> "default flip" as pending; treat that as stale — the engaged default
> today is on. (If the intent is genuinely off-until-clean-machine-pass,
> the *code* is what needs changing, not this doc.)

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
for `bun scripts/serve.ts` or paired A/B harnesses). One has no CLI flag.

| Env var | CLI flag | Default | Effect |
| --- | --- | --- | --- |
| `MLX_BUN_COMPILED_DECODE` | `--compiled-decode` | on (`!=="0"`) | Compiled decode graph replay. |
| `MLX_BUN_PERF_KERNEL` | `--perf-kernel` | on (`!=="0"`) | Fused quantized-KV decode kernel (not bit-exact; perf A/B). |
| `MLX_BUN_FUSED_DECODE` | `--fused-decode` | off (`==="1"`) | Tile quantized decode SDPA. |
| `MLX_BUN_NO_FUSED_SDPA` | `--fused-sdpa` (inverted) | fused on | `=1` forces the stock unfused SDPA everywhere. |
| `MLX_BUN_FUSED_GELU` | *(none)* | on (`!=="0"`) | Fused GeGLU MLP kernel. Bit-exact, so it stays on both lanes; env-only opt-out. |
| `MLX_BUN_FORCE_WIRE` | `--force-wire` | off (`==="1"`) | Wire weights for the generation. |

## Execution modes: serial vs. `--batch N`

`--batch 1` (default) is the serialized single-queue path: one GPU, one
generation at a time, prompt-cache prefix reuse, mixed-precision KV by
default. Untouched and unconditional.

`--batch N` (N>1) opts the **whole server** into a continuous-batching
engine that is **bit-parity with `mlx_lm.server` at `B=N`**. It is a
*mode switch*, not a load-dependent fallback (results must not depend on
concurrency).

Parity is the guarantee, so the batched lane runs in **compat mode**: it
exposes **none** of the serial lane's perf flags and runs the plain
bit-exact forward — the same path mlx-lm runs, never the optional
parity-breaking kernels. This is the mechanism of the guarantee, not a
missing feature (see
[compat mode](#--batch-n-is-compat-mode--perf-flags-dont-apply-by-design)).
Because mlx-lm's batched path is bf16 (its quantized batching is NYI),
bf16 continuous batching **is** the drop-in:

- **KV quant unset ⇒ bf16** so the batch path engages out of the box
  ("Option B"). The serial default stays mixed-precision (optiq parity).
- **Explicit `--kv-quant config|4|8` ⇒** those requests route to the
  serial lane (batched is bf16-only; a startup warning is printed). With
  an explicit `--kv-quant`, *every* request carries a quant scheme, so
  **nothing batches** — `--batch N --kv-quant config` is effectively
  serial-with-quant. Omit `--kv-quant` to actually batch.

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
| `repetition_penalty` | ❌ serial — per-row logits processors are a later refinement |
| `min_p` / `xtc_*` / `logit_bias` / `presence_penalty` / `frequency_penalty` | ❌ serial — one gate for the whole sampler/processor family (safe v1; min_p/XTC are per-row samplers and could batch later) |
| explicit `seed` | ❌ serial — reproducibility ⇒ solo (matches mlx-lm) |
| KV quant active (explicit `--kv-quant`) | ❌ serial — batched is bf16-only in v1 |
| `temperature` / `top_p` / `top_k` | ✅ batches (each row samples with its own seed) |
| `stop` sequences | ✅ batches (per-row `StopMatcher` in the onToken closure) |
| `tools` / `tool_choice` | ✅ batches (per-row tool router; decode-layer parse) |
| `--thinking` / `enable_thinking` | ✅ batches (template-render concern, lane-independent) |
| multi-turn / long prompt | ✅ batches, but **no prompt-cache reuse** (`cached_tokens=0`) |

All three model families — full-attention (CPM), sliding-window (Gemma), and hybrid gated-DeltaNet (Qwen3.5) — batch; the
scheduler assembles each layer's cache by attention type.

## Compatibility matrix

How each option behaves in each mode. "serial" = `--batch 1`; "`--batch N`"
= the batched mode (a given request may still take the serial *lane*
inside it per the table above).

| Option | serial (`--batch 1`) | `--batch N` (N>1) |
| --- | --- | --- |
| `--kv-quant config`/`4`/`8` | ✅ applied to all requests | ⚠️ applied, but forces **all** requests to the serial lane (no batching) |
| `--kv-quant off` | ✅ bf16 | ✅ bf16 (same as the implicit batch default) |
| *(kv-quant unset)* | mixed-precision `config` | **bf16** (Option B) — incl. serial-lane fallback requests |
| `--memory-budget` | ✅ per-request admission | ✅ per-request admission — but **not aggregate** across rows (see limitations) |
| `--prompt-cache` | ✅ prefix reuse | ⚠️ bypassed for batched requests (`cached_tokens=0`); serial-lane requests still reuse |
| `--temperature`/`--top-p`/`--top-k` | ✅ | ✅ (per-row) |
| `--thinking` | ✅ | ✅ |
| vision request | ✅ | ✅ via serial lane (in bf16 under Option B) |
| LoRA `adapter` | ✅ | ✅ via serial lane |
| `repetition_penalty` | ✅ | ✅ via serial lane |
| `min_p` / `xtc_*` / `logit_bias` / presence+frequency penalties | ✅ | ✅ via serial lane |
| `seed` | ✅ | ✅ via serial lane |
| `tools` / `stop` | ✅ | ✅ (batches) |
| `--compiled-decode`/`--perf-kernel`/`--fused-*`/`--force-wire` | ✅ (serial perf tree) | **n/a — compat mode, no perf flags by design** |

### `--batch N` is compat mode — perf flags don't apply by design

The bit-parity guarantee (mlx-lm B=N) is the *whole point* of `--batch N`,
and it requires running the plain forward path. So the batched lane
deliberately exposes **no** perf knobs: the scheduler
([batch-scheduler.ts](../../src/serve/batch-scheduler.ts)) drives the
model through `forwardHidden`/`logitsFromHidden` directly (not
`generate()`), running the same bit-exact kernels mlx-lm runs — never the
optional, parity-breaking ones. Flagging the batched lane would defeat
the guarantee, so it's intentionally not wired.

- **`--perf-kernel` / `--fused-decode` / `--compiled-decode`** — never
  engage in the batched lane. They diverge from the -O0 reference (or, for
  the quantized-KV kernels, are moot since batched is bf16). They're the
  L3 perf row, a separate KL-gated path — see the validation matrix in
  [parallel-slots.md](../design/parallel-slots.md).
- **`--force-wire`** — doesn't wire (the scheduler bypasses `generate()`'s
  wired scope). A model that needs wiring for speed (e.g. 26B: 8.6 → 32.3
  tok/s wired) runs at mlx-lm-equivalent unwired speed under `--batch N`;
  in practice such a model has no headroom for B>1 KV anyway.
- **Always-on bit-exact kernels still run.** Fused GeGLU is bit-exact with
  the spelled-out MLP, so it stays on in both lanes without breaking
  parity — "compat mode" means *no parity-breaking optionality*, not
  -O0.

The serial lane is where the perf/optimization tree lives: `--perf-kernel`
/ `--fused-*` / `--compiled-decode` engage there, and the
mixed-precision-KV (optiq) default applies there.

## Known limitations under `--batch N`

These are deliberate v1 scope, not bugs — but they change behavior, so
know them:

1. **Prompt cache bypassed.** Batched requests solo-prefill every row;
   `cached_tokens=0`. Wiring `PromptCache` into the scheduler is a
   follow-up.
2. **Admission is per-request, not aggregate.** `--memory-budget` checks
   each request against single-sequence max-safe-context, but N
   concurrent rows can collectively exceed the budget (the `B×S_max`
   KV-budget admission is TODO). With a tight budget and several
   large-context requests, the allocator cap is the only backstop — and
   a true GPU OOM here is uncatchable. Size the budget with headroom for
   N rows, or keep N small.
3. **Short-context only.** Verified pre-ring-wrap (rows < the 1024
   sliding window). Long-context (context > window) batched decode is a
   separate validation.
4. **bf16 only — by contract.** mlx-lm's batched path *is* bf16, so
   bf16-only batching is exactly what mlx-lm-parity means (not a
   shortcoming). Going further — batched + mixed-precision KV quant — is
   novel territory with no mlx-lm/optiq oracle, so it's a deferred,
   KL-gated extension.
5. **`extend` join not yet used.** A joining request re-merges the whole
   batch (O(B·S)); mlx-lm's keep-the-running-batch `extend` is a later
   optimization (numerically equivalent).

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
