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
| `--ssd-cache` | dir | off | SSD cold tier under the prompt cache ([docs/design/ssd-kv-cold-tier.md](../design/ssd-kv-cold-tier.md)): prefix KV spills to disk on RAM eviction, is snapshotted after requests settle (debounced 1 s), and **survives restarts** — a long-context agent re-attach restores via zero-copy mmap instead of re-prefilling (measured 13.7k-token prefix: 12 s → 0.24 s TTFT; 0% decode overhead). Entries are keyed by model fingerprint **+ effective kv scheme** + tokenizer hash + adapter ns; incompatible/corrupt files self-quarantine. Serial lane only. Requires the RAM cache. |
| `--ssd-cache-max` | GB | `32` | SSD tier byte cap (binary GiB); oldest-mtime entries evicted at the cap. |
| `--ssd-cache-verify` | (bool) | off | Verify every tensor hash on restore. Reads all bytes eagerly (defeats lazy page fault-in) — integrity paranoia only; the header hash is always verified. |
| `--batch` | n | `1` (serial) | Max concurrent requests batched through the mlx-lm-parity engine. `>1` switches the **whole server** into bf16 continuous batching — a *mode*, not a load fallback. See [Execution modes](#execution-modes-serial-vs---batch-n). `--decode-concurrency` is accepted for drop-in compatibility, but the semantics differ: in mlx_lm.server it caps per-BatchGenerator decode parallelism (default 32); in mlx-bun it enables continuous batching with this cap (mlx-bun's default is the optimized serial path). |
| `--kv-quant` | `config`\|`off`\|`4`\|`8` | `off` (bf16) | KV-cache quantization. **Default flipped to bf16 2026-07-05** (naked = L1): quantized KV measured 5–20% slower decode than bf16 at ≤16k on every model — on mlx-lm too — so it pays only in **memory headroom** (e.g. ~1.3 GB on the 12B @16k) and is an explicit opt-in (`--kv-quant …` or `--l2`/`--l3`, whose presets pass `config`). `off` = bf16 (L1). `4`/`8` = **uniform** bits (group 64, start 0) — the scheme mlx-lm exposes as `--kv-bits`/`--kv-group-size`/`--quantized-kv-start`. In the L1 kernel set (`--l1 --kv-quant 8` = fused-sdpa off) our unfused quantized SDPA is **op-for-op identical** to mlx-lm's `quantized_scaled_dot_product_attention`, so uniform-quant is **bit-exact L1** (the fused-sdpa-ON path is optiq-aligned). `config` = **per-layer mixed-precision** from `kv_config.json` — optiq-only, no mlx-lm analog → **L2**. Under `--batch N`, an explicit value routes those requests to the **serial** lane (batched is bf16-only). |
| `--adapter` | dir | none | Mount a LoRA adapter at startup (same machinery as `POST /v1/adapters`; the adapter id is the directory's basename) and make it the **default** for requests that send no `adapter` field. A request's explicit `adapter` — including `"none"` — always wins, and hot-swap via `/v1/adapters` is unchanged. `--adapter-path` is accepted as the mlx_lm.server-named alias. A bad adapter fails startup loudly rather than silently serving the base model. This is the flag `mlx-bun train`'s completion message points at. |
| `--draft-model` | path/query | none | **Speculative decoding** (mlx_lm.server parity): a smaller same-tokenizer model drafts tokens the main model verifies in one forward — exact results (L1: token-for-token vs mlx-lm's speculative path), faster decode when drafts land. Resolves like the main model. Tokenizer-family mismatch fails startup (upstream silently accepts ~0%). Mounting a draft routes **every** request to the serial lane (upstream `is_batchable = draft is None`). Pays on slow targets (12B+); fast small models lose to the draft overhead. Composes with structured output (the constrained verify walk). Prompt-cache reuse is bypassed on the spec path (v1). Telemetry: `usage.speculation` (`drafted`/`accepted`/`targetCalls`). |
| `--num-draft-tokens` | n | `3` | Drafts per verify round (mlx_lm.server's default; `mlx_lm.generate`'s is 2). |
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
| `--l1` | (bool) | — | **Parity tier ALIAS:** bit-for-bit IDENTICAL to mlx-lm (bf16 KV, compiled activations — the faithful `@mx.compile` geglu/swiglu — no perf kernel, no custom fused-gelu). Expands to the fastest set of per-fork flags that still holds the guarantee; any explicit per-fork flag (`--kv-quant`/`--perf-kernel`/`--compiled-activations`/…) overrides one. See [docs/design/faithful-l1-consolidation.md](../design/faithful-l1-consolidation.md) and [parity-tier-dag.md](../design/parity-tier-dag.md). |
| `--l2` | (bool) | — | **Parity tier preset:** bit-for-bit IDENTICAL to mlx-optiq (quantized KV per `kv_config.json` + fused N-tiled prefill SDPA + **stock unfused decode** — the composition the optiq goldens track, `scripts/regen-kvq-goldens.ts`). The perf kernel stays **off**: it is envelope-gated, not bit-exact (see `--l3`), and opting into it (`--l2 --perf-kernel on`) is an explicit choice that leaves the bare-tier guarantee. |
| `--l3` | (bool) | — | **Parity tier preset:** best performance, no bit-exact oracle (KL + test gated). On the decode path L3 = L2 + the envelope-gated perf kernel; L3 also owns the no-oracle features (HLG sampler, expert offload). **No tier given ⇒ `--l1`** (decided 2026-07-05: the L1 faithful kernel set matches mlx-lm 1.00× on every model and no output-changing lever has beaten that baseline in a paired A/B — each is opt-in until it does). |
| `--compiled-decode` | on\|off | on | Replay the per-step decode graph in C++ (`MLX_BUN_COMPILED_DECODE`). Bit-exact A/B lever. **Serial lane only** (see note below). **Gemma4-dense only** — LoRA, MoE, and non-Gemma4 models (MiniCPM5 / Qwen3.5) run eager; an unsupported step falls back to eager for the rest of that generation. |
| `--compiled-activations` | on\|off | on | Route the geglu/swiglu activation through mlx-lm's `@mx.compile` closure (`MLX_BUN_COMPILED_GEGLU` + `MLX_BUN_COMPILED_SWIGLU`) — the **faithful** kernel: same libmlx graph as mlx-lm → **bit-exact** AND one dispatch instead of ~9. `off` = the uncompiled composition (same L1 parity, slower). Toggles gemma geglu + MiniCPM5 swiglu; qwen3/qwen3.5/universal compile unconditionally. |
| `--perf-kernel` | on\|off | **off** | Fused quantized-KV decode-SDPA Metal kernel (`MLX_BUN_PERF_KERNEL`), the perf side of the compat A/B. **Not bit-exact** — envelope-gated (≥56/64 teacher-forced argmax vs the frozen compat trajectory, `tests/perf-kernel-oracle.test.ts`), so it is an **L3 lever**: on in `--l3` only, **off by default and in bare `--l1`/`--l2`** (flipped 2026-07-05 — the perf arm measured 0.62–0.93× vs compat on e4b at every context; its one win, 12B @16k +6%, came with a KL WARN). Engages on quantized caches at decode. **Serial lane only.** |
| `--fused-gelu` | on\|off | **off** | Custom single-pass fused-geglu Metal kernel (`MLX_BUN_FUSED_GELU`). Bit-exact with our uncompiled path but **NOT vs mlx-lm** (pow/tanh math-lib residual) → an **L3 lever**, off in `--l1`/`--l2`. The default gemma geglu is `--compiled-activations` (which IS bit-exact vs mlx-lm). Gemma only. |
| `--fused-decode` | on\|off | off | Experimental: tile the quantized decode SDPA (`MLX_BUN_FUSED_DECODE`). **Serial lane only.** |
| `--fused-sdpa` | on\|off | follows `--kv-quant` | Fused SDPA path for quantized prefill/continuation (inverted env `MLX_BUN_NO_FUSED_SDPA`). Defaults to the composition its oracle uses: **on** under `--kv-quant config` (the optiq-golden composition), **off** under uniform `4`/`8` (mlx-lm's `quantized_scaled_dot_product_attention`, the bit-exact L1-eligible scheme) and bf16 (no-op there). **Serial lane only.** |
| `--force-wire` | (bool) | off | Wire weights into memory for the whole generation (`MLX_BUN_FORCE_WIRE`). Near-ceiling models (e.g. 26B) need it. **Serial lane only.** |

The default host/port (`127.0.0.1:8080`) match `mlx_lm.server`, so running
mlx-bun alongside the Python reference server needs an explicit `--port`.

The performance levers are A/B knobs; **the naked default is the L1 set**
(2026-07-05 decision: an output-changing lever earns a default only by
beating the L1 faithful baseline in a paired A/B, and none has yet — the
2026-07-05 pass measured fused-decode at 1.00×, fused-gelu at +0–1%, the
perf arm at 0.62–0.93× on e4b, and quantized KV 5–20% *slower* decode
than bf16 at ≤16k on both stacks). Flip them to compare. They are set as
`MLX_BUN_*` env vars before the model loads, so they apply to
`mlx-bun pi` too. They affect the **serial** decode path (`generate()`);
the batched scheduler calls `model.forwardHidden` directly and so is
unaffected by all of them — see
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
for `bun scripts/serve.ts` or paired A/B harnesses). Three have no CLI flag.

| Env var | CLI flag | Default | Effect |
| --- | --- | --- | --- |
| `MLX_BUN_COMPILED_DECODE` | `--compiled-decode` | on (`!=="0"`) | Compiled decode graph replay. |
| `MLX_BUN_PERF_KERNEL` | `--perf-kernel` | on (`!=="0"`) | Fused quantized-KV decode kernel (not bit-exact; perf A/B). |
| `MLX_BUN_FUSED_DECODE` | `--fused-decode` | off (`==="1"`) | Tile quantized decode SDPA. |
| `MLX_BUN_NO_FUSED_SDPA` | `--fused-sdpa` (inverted) | fused on | `=1` forces the stock unfused SDPA everywhere. |
| `MLX_BUN_COMPILED_GEGLU` | `--compiled-activations` | on (`!=="0"`) | Gemma geglu via mlx-lm's `@mx.compile` closure — the faithful default (bit-exact vs mlx-lm, one kernel). `=0` → uncompiled composition (same parity, slower). |
| `MLX_BUN_COMPILED_SWIGLU` | `--compiled-activations` | on (`!=="0"`) | `mx.compile`'d SwiGLU (`silu(gate)·up` → one kernel) on MiniCPM5 decode (M=1), porting mlx-lm's `activations.py`. Bit-exact (passes the exact logit-parity gate), both lanes. +5.5% CPM5 decode. (qwen3/qwen3.5/universal compile swiglu unconditionally, independent of this flag.) |
| `MLX_BUN_FUSED_GELU` | `--fused-gelu` | **off** (`==="1"`) | Custom single-pass fused-geglu Metal kernel. Bit-exact vs our uncompiled path but NOT vs mlx-lm (pow/tanh math-lib residual) → L3 opt-in. The bit-exact gemma default is `MLX_BUN_COMPILED_GEGLU`. |
| `MLX_BUN_CPM5_FAITHFUL` | *(none)* | off (`==="1"`) | Swap the MiniCPM5 backend to `FaithfulMiniCPM5` — an exact op-for-op copy of mlx-lm's `llama.py` + `activations.py` (`src/model/minicpm5-faithful.ts`), selected in `createModel`. Bit-exact to the golden; an A/B reference for comparing our optimized `MiniCPM5Model` against a verbatim mlx-lm reproduction. Falls back to the monolith outside the plain-llama envelope. |
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
| `logprobs` / `top_logprobs` | ❌ serial — the batched sampler doesn't capture logprob arrays yet |
| explicit `seed` | ❌ serial — reproducibility ⇒ solo (matches mlx-lm) |
| KV quant active (explicit `--kv-quant`) | ❌ serial — batched is bf16-only in v1 |
| `--draft-model` mounted | ❌ serial, server-wide — speculation is a B=1 latency mode (upstream `is_batchable = draft is None`) |
| `repetition_penalty` / `min_p` / `xtc_*` / `logit_bias` / presence+frequency penalties | ✅ batches — per-row logits processors over a per-row device-side history (since 2026-07-02; some models — Qwen3.5 — ship a *default* repetition penalty, which used to route everything serial) |
| structured output (`response_format` / `guided_*`) | ✅ batches — per-row grammar matchers driven by the scheduler (`MLX_BUN_GRAMMAR_BATCH=0` forces serial) |
| `temperature` / `top_p` / `top_k` | ✅ batches (each row samples with its own seed) |
| `stop` sequences | ✅ batches (per-row `StopMatcher` in the onToken closure) |
| `tools` / `tool_choice` | ✅ batches (per-row tool router; decode-layer parse) |
| `--thinking` / `enable_thinking` | ✅ batches (template-render concern, lane-independent) |
| multi-turn / long prompt | ✅ batches, but **no prompt-cache reuse** (`cached_tokens=0`) |

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
| structured output (`response_format`/`guided_*`) | ✅ (mask in the decode loop) | ✅ (batches; per-row matchers) |
| `--draft-model` | ✅ spec decode (grammar composes) | ⚠️ mounts, but routes **every** request serial — spec and batching are different modes |
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
4. **bf16 only — by contract.** mlx-lm's batched path *is* bf16, so
   bf16-only batching is exactly what mlx-lm-parity means (not a
   shortcoming). Going further — batched + mixed-precision KV quant — is
   novel territory with no mlx-lm/optiq oracle, so it's a deferred,
   KL-gated extension.
5. **`extend` join (landed 2026-07-03).** A joining request appends to
   the running batch's full-attention KV in one pad+concat (mlx-lm
   `BatchKVCache.extend` semantics, token-exact vs its oracle);
   `MLX_BUN_BATCH_EXTEND=0` reverts to the old whole-batch re-merge
   (numerically equivalent, O(B·S)). Sliding-window layers still re-merge
   on join (rotating-extend is a follow-up).

## Fidelity tiers and the decode route (`--l1` / `--l2` / `--l3`)

The tiers are **correctness contracts**, and each flag is an alias for a
decode-route preset (`applyDecodeRoute()` in [src/cli.ts](../../src/cli.ts));
any per-fork flag (`--kv-quant`, `--perf-kernel`, `--compiled-decode`,
`--compiled-activations`, `--fused-gelu`, `--fused-sdpa`, `--fused-decode`)
overrides its tier's preset.

| Tier | Contract | KV | Kernels | Verified against |
| --- | --- | --- | --- | --- |
| `--l1` | mlx-lm **bit-for-bit** | bf16 | compiled-decode + compiled activations (faithful geglu/swiglu) | mlx-lm goldens (per machine) |
| `--l2` | mlx-optiq **bit-for-bit** | mixed-precision (`kv_config.json`) | + fused-SDPA (matches optiq exactly) | optiq goldens |
| `--l3` | fastest; envelope-gated | as L2 | + the flash perf-kernel | frozen-trajectory envelope + KL — **not** bit-exact |
| *(none)* | **= the L2 composition** | `config` when the model ships one, else bf16 | compiled + fused-SDPA | — |

Compiled-decode is on in **every** tier (proven bit-exact with uncompiled —
free speed, not a fidelity trade). The only thing `--l3` adds today is the
perf kernel.

**KV precision is a separate axis from the tier's kernels.** Each tier row shows its
*default* KV scheme, but KV is not what defines the tier. mlx-lm supports **uniform**
quantized KV (`--kv-bits`), and `--l1 --kv-quant 8` is a **bit-exact L1** config: with
fused-sdpa off (the L1 default) our quantized decode runs `quantizedSdpaUnfused`,
which is op-for-op identical to mlx-lm's `quantized_scaled_dot_product_attention`
(`mlx_lm/models/base.py`) — same `mx.quantized_matmul` ×2 + `mx.softmax(precise=True)`
+ `where(…, finfo.min)`. bf16 is just the simplest L1 default. The **fused / N-tiled**
quantized path (fused-sdpa ON — naked default and `--l2`) is the **optiq**-aligned
one. Only the **per-layer mixed-precision** `config` scheme is optiq-only (→ L2).

**Where each feature sits:** batching = L1-class (mlx-lm B=N parity);
speculative decoding = L1-class (token-for-token vs mlx-lm's spec path);
structured output = L2-class (oMLX oracle; masking doesn't touch the
numerics of valid tokens, so it composes with any tier); grammar × spec
together, HLG sampling, expert offload, and (future) batched quantized KV
= L3-class — no ancestor runtime does them, so they're gated by
validity/KL/quality instead of bit-parity.

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

**Recipes:**

- *Single-user agent/chat (the default use):*
  `mlx-bun serve <model> --ssd-cache <dir>` — L2 serial, prompt cache +
  SSD tier. On 12B+ add `--draft-model <small-same-tokenizer>`. Max
  decode speed, accepting the envelope gate: `--l3`.
- *Several clients at once (throughput):*
  `mlx-bun serve <model> --batch 4 --ssd-cache <dir>` — don't set
  `--kv-quant` (it would just un-batch everything), don't mount a draft.
- *Reproducibility:* `--l1` (≡ mlx-lm), `--l1 --batch N` (≡ mlx-lm B=N),
  bare / `--l2` (≡ optiq).
- *Memory-tight big model:* serial + `--kv-quant config|4|8` +
  `--memory-budget <GB>` + `--ssd-cache <dir>`; MoE adds
  `--expert-offload`. Inherently the serial recipe until batched
  quantized KV lands.

**The two exclusions to remember:** batching ⊕ kv-quant (batch is bf16 by
contract; the resolver is the KL-gated L3 follow-up) and spec ⊕ prompt
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
