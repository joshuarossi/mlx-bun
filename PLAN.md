# PLAN

Working plan for mlx-bun. Each phase has an exit criterion — we don't move
on until it's met. Status markers: `[ ]` todo, `[~]` in progress, `[x]` done.

## Design principles

- **Logit parity is the oracle.** mlx-lm with the same weights is the
  reference implementation. Any divergence is a bug until proven a fix.
- **The GPU sets the speed; we delete overhead around it.** Decode is
  memory-bandwidth-bound (~273 GB/s on the target M4 Pro ÷ bytes-of-weights
  = ceiling). Wins come from: fewer bytes per token (quantization, MoE),
  more tokens per weight-read (speculative decoding), or skipped work
  (prompt-cache persistence). Never from "faster JS".
- **mmap'd weights are immutable and shared.** Parse safetensors headers,
  take zero-copy views, hand pointers to mlx via external-buffer arrays.
  One mapping, no copies.
- **Profile before optimizing, measure after.** Every perf claim gets a
  number on this machine, recorded in the eval DB.
- **Scope is the survival strategy.** Target model families: Gemma
  (4/3), Qwen (3.x), and one MoE family. Not parity with mlx-lm's dozens.

## Reference environment (the oracle setup)

- Machine: MacBook Pro, M4 Pro, 24 GB unified (~273 GB/s), macOS 26.6.
- Python oracle: `/Users/joshrossi/Code/mlx-lm/.venv` — mlx 0.31.2,
  mlx-lm 0.31.3, mlx-optiq 0.2.1, pillow. No source code in that dir;
  it's just the venv + `serve-gemma.sh` (working reference server,
  run it directly — don't start servers from agent sessions).
- Oracle weights: gemma-4-12B-it-OptiQ-4bit at
  `~/.cache/huggingface/hub/models--mlx-community--gemma-4-12B-it-OptiQ-4bit/snapshots/5b1101065d2094c8f12aa87fee80e0afa5b292b7/`
  (8.3 GB, 2 shards + optiq_vision.safetensors sidecar + kv_config.json).
  Note: optiq tooling wants the local snapshot *path*, not the HF repo id.
- Measured baseline: 14.1 tok/s decode (600 tok / 42.5 s, 29-tok prompt),
  ~8.5 GB resident serving. Theoretical bandwidth ceiling ≈ 32 tok/s.
- optiq source (readable, in the venv): `runtime/fused_quant_sdpa.py`,
  `runtime/streaming_kv_quant.py`, `vlm/` (vision sidecar wiring),
  `serve.py`. HF auth: `hf auth login` done; Xet disabled via
  `HF_HUB_DISABLE_XET=1` (Xet stalls on this network).
- Client integration reference: pi models.json at
  `~/.pi/agent/models.json` (provider "optiq", apiKey must start with
  `sk-optiq-`; server port 8080).

## Phase 0 — Feasibility: what does mlx-c expose? `[x]`

The load-bearing question for the whole project.

- [x] Install mlx-c (brew or cmake build); pin the version.
- [x] Inventory the exported C API. Critical symbols:
      `mlx_quantized_matmul`, `mlx_fast_scaled_dot_product_attention`,
      RoPE / RMSNorm fast ops, dtype support (bf16), stream/device handles,
      lazy-eval control (`mlx_eval`), external-buffer array creation.
- [x] Smoke test: `bun:ffi` opens libmlxc, creates two arrays, adds them
      on GPU, reads result back. (`spikes/phase0-smoke.ts` — PASS.)
- [x] Memory-management spike: wrapper class with explicit `.dispose()` +
      `FinalizationRegistry` backstop; confirm no leaks under a tight
      alloc loop (watch wired memory). (`spikes/phase0-memory.ts` — 2000
      alloc/add/eval/dispose iterations, mlx active memory returns to
      baseline exactly; registry backstop freed 50/50 dropped handles.)
- **Exit criterion:** documented yes/no per critical symbol. → **All
  present; no pivot needed. Decision (2026-06-09): proceed with bun:ffi
  against brew libmlxc.** Findings below.
- **Risk:** mlx-c lags mlx core features; the Bun Zig→Rust transition
  (canary as of 2026-05) may move `bun:ffi` behavior — build against
  stable, CI against canary.

### Phase 0 findings (2026-06-09)

- **Pinned: mlx-c 0.6.0_2 (brew), against mlx 0.31.2 — the exact mlx
  version in the Python oracle venv.** Headers:
  `/opt/homebrew/Cellar/mlx-c/0.6.0_2/include/mlx/c/`, lib:
  `/opt/homebrew/lib/libmlxc.dylib`. 621 exported functions. Bun 1.3.3.
- Symbol inventory — all YES:
  `mlx_quantized_matmul` (per-call optional `group_size`/`bits` + `mode`
  string → OptiQ per-layer mixed precision is directly expressible);
  `mlx_gather_qmm` (MoE, Phase 6); `mlx_fast_scaled_dot_product_attention`
  (mask_mode string + optional mask array + attention sinks);
  `mlx_fast_rope` (+`_dynamic`); `mlx_fast_rms_norm`; `mlx_fast_layer_norm`;
  MLX_BFLOAT16 dtype + accessors; `mlx_eval`/`mlx_async_eval`;
  `mlx_fast_metal_kernel_*` (Phase 7 custom kernels);
  `memory.h` introspection (`mlx_get_active/peak_memory`,
  `mlx_set_memory_limit`, `mlx_set_wired_limit`, `mlx_set_cache_limit` —
  the enforcement half of Phase 5 memory contracts).
- **Zero-copy confirmed**: `mlx_array_new_data_managed(_payload)` wraps
  the buffer — data pointer identical to source, mutations visible
  through mlx, dtor callback fires on `mlx_array_free`. (Its header doc
  comment says "will be copied" — copy-paste error, empirically false.
  Plain `mlx_array_new_data` *does* copy.) mmap → mlx array without
  copies is viable; dtor + JSCallback keeps the mmap alive exactly as
  long as mlx references it.
- **FFI calling convention**: every handle type is a one-pointer struct
  (`{ void* ctx }`) — pass/return as `u64` on arm64. Out-params
  (`mlx_array* res`) = pointer to a `BigUint64Array(1)` slot; reread the
  slot after the call. Ops return `int` status, 0 = ok.
- Watch-item: `mlx_optional_int` is `{int, bool}` (≤16 bytes, by value
  in one register) — needs packing as a u64 when calling
  `mlx_quantized_matmul` from bun:ffi. Verify the packing in Phase 2
  before relying on it.

## Phase 1 — Load path `[ ]`

- [ ] Safetensors parser: JSON header → {name, dtype, shape, offset};
      `Bun.mmap` the blob; zero-copy subarray views per tensor.
- [ ] config.json reader; quantization metadata (per-layer bits/group_size
      for OptiQ mixed-precision).
- [ ] Construct mlx arrays from mmap'd views without copying.
- [ ] Tokenizer: bind HF `tokenizers` (Rust) via its C API, or use its
      WASM build — decision spike. Chat template: hand-port Gemma's Jinja
      template (no general Jinja engine).
- **Exit criterion:** load gemma-4-12B-it-OptiQ-4bit from the HF cache,
  print every tensor's name/shape/dtype, tokenize and detokenize a
  round-trip string identical to mlx-lm's tokenizer output.

## Phase 2 — The model graph + correctness oracle `[ ]`

- [ ] Port mlx-lm's gemma model definition (~300 lines): attention with
      GQA + sliding-window/global pattern, RMSNorm, MLP, QuantizedLinear.
- [ ] KV cache (fp16 first; quantized later).
- [ ] Greedy decode loop, batch=1.
- [ ] **Oracle harness**: same prompt, same weights through mlx-lm (Python)
      and mlx-bun; assert logits match within fp tolerance at every step;
      CI-able script.
- **Exit criterion:** 100-token greedy generation, token-identical with
  mlx-lm, on the OptiQ Gemma weights.

## Phase 3 — Sampling + streaming generation `[ ]`

- [ ] Temperature, top-p, top-k, repetition penalty (the small-model loop
      antidote — see notes), seeded RNG for reproducibility.
- [ ] Prefill chunking (bounded transient memory on 24 GB; default step
      size matched to mlx-lm's).
- [ ] Generation API: async iterator of tokens with usage stats
      (prompt/completion tokens, prefill and decode tok/s).
- **Exit criterion:** measured decode tok/s within 5% of mlx-lm on this
  machine (~14 tok/s baseline for the 12B OptiQ); numbers recorded.

## Phase 4 — Server `[ ]`

- [ ] OpenAI-compatible `/v1/chat/completions` (+ streaming SSE),
      `/v1/models`. Anthropic `/v1/messages` shim later if pi/OpenClaw
      need it.
- [ ] Tool calling: parse the model's tool_call markers (Gemma template
      ships them) → OpenAI `tool_calls` JSON; tool role round-trip.
- [ ] Vision path: accept `image_url` (data: and http(s):), decode with
      Bun-native image handling, run the bf16 vision sidecar
      (optiq_vision.safetensors) → embeddings spliced into the sequence.
      (Port the sidecar wiring from optiq's vlm module.)
- [ ] In-memory LRU prompt cache with a byte cap (lesson from the
      mlx-lm OOM: a count-capped cache of multi-GB KV entries is a leak).
- **Exit criterion:** pi connects via models.json and completes the
  ls-and-summarize agent task end-to-end; vision request on a real image;
  kill -9 the server mid-stream and restart serves within 2s (warm mmap).

## Phase 5 — The appliance layer `[ ]`

Where we beat Python, not just match it.

- [ ] **Model registry (bun:sqlite)**: scan HF cache → models table
      (path, family, params, quant, size, capabilities: vision/tools/MTP,
      sidecars, kv-config path). CLI: `mlx-bun ls`, `mlx-bun serve <query>`.
- [ ] **KV-cache persistence**: registry table prefix-hash → cache file;
      save/load prompt caches across restarts. Standard agent preamble
      (system prompt + skills) prefills once, ever.
- [ ] **Eval DB**: every benchmark run (tok/s, TTFT, peak memory,
      speculation acceptance rate) recorded with model + config + commit.
- [ ] **Memory contracts (`mlx-bun fit`)** — the flagship DX feature.
      All terms are deterministic: weights (safetensors headers), KV
      bytes/token (config: layers × kv_heads × head_dim × bytes, sliding-
      window layers capped, KV-quant factored), prefill transient (chunk
      size we choose), machine (RAM + wired ceiling, queryable). Ship:
      (a) `fit <model>` report: fits?, max safe context, peak bytes,
      predicted tok/s (bandwidth ÷ bytes/token); (b) the M-series SKU
      matrix per model — finite Apple SKUs make "works on 16 GB+ at 32k"
      a printable, testable claim (the App Store requirements line for
      Tauri apps); (c) `loadModel({ memoryBudget })` solves for max
      context and *enforces* it — over-budget requests rejected up front
      with a clear error, never discovered via Metal OOM. Validate
      predictions against measured peaks in the eval DB; publish accuracy.
- [ ] Downloader: resumable HF fetch with checksums (native fetch; no
      Xet; the thing the Python downloader kept failing at).
- [ ] **Embeddable build**: `bun build --compile` single-binary target for
      the Tauri/Electron sidecar pattern — apps ship local inference with
      zero user-visible dependencies. Requires: library-first API (server
      is one consumer of it), relative-path dylib loading, a documented
      signing/notarization recipe, first-run weight download via the
      registry + downloader.
- **Exit criterion:** cold start → first token of a cached-prefix prompt
  in under 1s; `mlx-bun ls` answers "vision-capable models under 10 GB".

## Phase 6 — Speed: change what gets computed `[ ]`

Ordered by expected payoff on this hardware:

- [ ] **Speculative decoding** with a small drafter (gemma-4-E2B-assistant
      pattern): draft k, verify in one parallel pass. Measure acceptance
      on our real agent transcripts; expected 1.5–2.5x decode.
- [ ] **Fused sampling**: logits → sampled token on-GPU; never round-trip
      the 262k-vocab tensor to JS per token.
- [ ] **Quantized KV cache** with FlashAttention-style N-tiled SDPA (port
      optiq's fused_quant_sdpa orchestration — it's op-level, not a custom
      kernel; ~line-for-line portable).
- [ ] **MoE support** (one family): the bandwidth cheat — 26B-A4B-class
      models decode like small models. Likely the single biggest
      capability-per-tok/s win on 24 GB.
- **Exit criterion:** ≥2x effective tok/s over Phase 3 baseline on the
  standard eval prompts, recorded in the eval DB.

## Phase 7 — Kernel experiments (research track) `[ ]`

Only after profiling shows where bytes move unnecessarily.

- [ ] Profile per-tile dispatch overhead in the N-tiled SDPA path.
- [ ] Custom fused Metal kernel for our exact config (4-bit, group 64,
      Gemma GQA shape): matmul + online-softmax update in one kernel via
      mlx's custom-kernel hook. Target: long-context prefill.
- [ ] Write up findings either way — negative results count; this phase
      is the "research project" part.

## Testing strategy

`bun test` (built-in, Jest-compatible) — no vitest; one toolchain.

- **Unit (fast, every run):** safetensors header parsing, config/quant
  metadata, chat-template formatting, registry queries. Fixture-driven.
- **Golden-file oracle (the real safety net):** a regen script runs the
  Python reference (`/Users/joshrossi/Code/mlx-lm/.venv/bin/python`) and
  dumps goldens: tokenizer round-trips, per-step logits on fixed prompts,
  greedy token sequences. Tests compare within fp tolerance (logits
  max-abs-diff bound + argmax-identical for greedy) — never bit-exact;
  GPU reduction order legitimately varies. Regenerating goldens is an
  explicit command, never automatic.
- **FFI/memory:** alloc-dispose loops asserting wired memory returns to
  baseline (leak detection as a test). GPU suites run serially.
- **Integration:** server on an ephemeral port inside the test process
  (dies with the test — not a persistent server); real chat + vision +
  streaming requests; kill mid-stream, assert clean restart.
- **Tiering:** weights-loaded suites (full parity, memory soaks) are
  opt-in/slow tier; everything else runs on every change.

## Open questions

- ~~mlx-c external-buffer array creation: zero-copy from mmap confirmed?~~
  Answered in Phase 0: yes, via `mlx_array_new_data_managed`.
- Tokenizers binding: C API vs WASM — perf and packaging trade.
- Vision sidecar format: confirm optiq_vision.safetensors layout and
  preprocessing (no preprocessor_config.json in the repo; read optiq/vlm
  source).
- Bun Rust-core transition: when canary becomes stable, does bun:ffi
  change? Track release notes.
- Chat template drift: hand-ported templates rot when models update —
  checksum the upstream .jinja and warn on mismatch.

## Context / lore

Born from an evening of running gemma-4-12B-it-OptiQ-4bit through the
Python stack on this machine (M4 Pro, 24 GB): Xet download stalls, a
segfault on ctrl-C, a PIL-shaped missing dependency, a repo-id-vs-path
crash in the vision engine, and an OOM-by-prompt-cache footgun — none of
them GPU problems. The thesis of this project is that the layer with all
the bugs is also the layer that doesn't need Python.
