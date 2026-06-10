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

## Phase 1 — Load path `[x]`

- [x] Safetensors parser: JSON header → {name, dtype, shape, offset};
      mmap the blob (libc mmap via FFI — see findings); zero-copy views.
      (`src/safetensors.ts`, `src/mmap.ts`; fixture unit tests.)
- [x] config.json reader; quantization metadata (per-layer bits/group_size
      for OptiQ mixed-precision). (`src/config.ts` — also parses
      kv_config.json and detects the vision sidecar.)
- [x] Construct mlx arrays without copying — **amended, see findings**:
      tensor data goes through mlx's native lazy loader
      (`mlx_load_safetensors`); our parser is the metadata path.
      (`src/weights.ts`; oracle value-parity tests pass.)
- [x] Tokenizer: **decision = `@huggingface/tokenizers` (pure JS/TS)** —
      no native code, no WASM, embeds in `bun build --compile`. Oracle
      round-trip parity on 7 prompts (unicode/emoji/code/template markers).
      Chat template: **decision = render the model's own template with
      `@huggingface/jinja`** instead of hand-porting — a hand-port rots
      when the model updates; rendering upstream's template can't. Parity
      with `apply_chat_template` verified. (`src/tokenizer.ts`,
      `src/chat-template.ts`.)
- **Exit criterion:** load gemma-4-12B-it-OptiQ-4bit from the HF cache,
  print every tensor's name/shape/dtype, tokenize and detokenize a
  round-trip string identical to mlx-lm's tokenizer output. → **Met**:
  `scripts/inspect-model.ts` enumerates all 1324 tensors (8.86 GB) in
  ~15 ms at 75 MB RSS; tokenizer + template parity in `bun test`.

### Phase 1 findings (2026-06-09)

- **`Bun.mmap` panics (SIGTRAP) on files > 4 GB** (Bun 1.3.3) — JSC
  ArrayBuffers cap at 2^32 bytes and Bun traps instead of erroring.
  Weight shards exceed that (shard 1 is 5.35 GB). Workaround that's also
  the better design: libc `mmap` via bun:ffi (`src/mmap.ts`), tensors
  handed around as raw pointers, JS views created only for small ranges.
- **Metal can't no-copy-wrap unaligned host pointers.** GPU ops on
  externally-wrapped buffers (`mlx_array_new_data_managed*`) read
  garbage unless the pointer is page-aligned — mlx evidently wraps the
  rounded-down page. Safetensors tensor offsets are arbitrary (layer-0
  layernorm sits 9707 bytes past a page boundary — not even element-
  aligned). CPU-stream ops on the same wrapped pointer are correct.
  **Decision:** weights go through `mlx_load_safetensors` (mlx's native
  lazy loader — open in ~2 ms, per-tensor read into mlx-owned page-
  aligned unified buffers on first eval; exactly what Python's mx.load
  does). The Load primitive is CPU-only (`Load::eval_gpu` not
  implemented) — always pass the CPU stream to the loader.
- **Phase 5 corollary:** files *we* write (KV-cache persistence) can pad
  tensor offsets to page boundaries, making true zero-copy GPU wrapping
  viable for cache reload. The mmap-wrap machinery (`MlxArray.fromPointer`)
  is kept for that.
- **Read full signatures from headers, never from memory/truncated grep**:
  `mlx_dequantize` has 10 params (an `mlx_optional_dtype` hides before
  the stream); binding it with 9 put the stream in the dtype slot →
  "There is no Stream(gpu, <garbage>)". Controlled FFI tests confirmed
  bun:ffi handles 9/10-arg calls and by-value structs correctly — the
  bug was the signature. `mlx_optional_int` packing as u64
  (value | 1n<<32n) verified working via dequantize parity.
- Gemma 4 architecture notes for Phase 2 (from config.json): 48 layers
  (40 sliding @ window 1024, 8 full), GQA 16 heads / 8 kv heads @
  head_dim 256, but **full-attention layers use 1 kv head @ head_dim 512
  with `attention_k_eq_v: true`** (K and V shared); per-layer
  `layer_scalar` tensors; partial rotary (factor 0.25) + rope_theta 1e6
  on full layers vs theta 1e4 on sliding; final_logit_softcapping 30;
  tied embeddings. Port target is mlx-lm's **gemma4** model (model_type
  is `gemma4_unified`, not gemma3 as CLAUDE.md guessed).

## Phase 2 — The model graph + correctness oracle `[x]`

- [x] Port mlx-lm's gemma model definition (~300 lines): attention with
      GQA + sliding-window/global pattern, RMSNorm, MLP, QuantizedLinear.
      (`src/model/gemma4.ts` — port of mlx-lm `gemma4_text.py`, non-MoE /
      non-per-layer-input / non-KV-shared paths; others throw explicitly.)
- [x] KV cache (bf16, concat-based — numerically identical to mlx-lm's
      step-allocated cache; preallocation is a Phase 3 perf item).
- [x] Greedy decode loop, batch=1.
- [x] **Oracle harness**: `scripts/parity-check.ts` (CI-able, exit code)
      + `tests/parity.test.ts` (12-step smoke in `bun test`).
- **Exit criterion:** 100-token greedy generation, token-identical with
  mlx-lm, on the OptiQ Gemma weights. → **Met, exceeded: logits are
  BIT-EXACT (max|Δ| = 0) at every compared step, 100/100 tokens
  identical.** Peak memory 8.91 GB. Unoptimized decode ~20 tok/s
  (caveat: includes per-step full-vocab logits like the reference loop;
  proper benchmarking is Phase 3).

### Phase 2 findings (2026-06-10)

- **Bit-exact parity is achievable and is now the test bar** (`toBe(0)`
  in tests/parity.test.ts — loosen only with documented cause). Same
  mlx kernels + same op composition order ⇒ deterministic identity,
  fp-tolerance arguments unnecessary.
- **Op-order fidelity is everything.** The one real divergence found:
  python's `gelu_approx` computes `x**3` via `mx.power`, not `x·x·x` —
  they round differently in bf16 (diff up to 512 at large magnitudes,
  compounding to ~12 in final-norm activations over 48 layers, max
  logit Δ ≈ 5). Porting rule: read the *implementation* of every mlx
  python helper (nn.gelu_approx, nn.RMSNorm, ...), never the docstring
  formula, and replicate scalar promotion (python floats are weak —
  they cast to the array's dtype, e.g. embed_scale √3840 becomes
  bf16 62.0) and association order exactly.
- `mx.compile` does NOT change numerics (compiled vs uncompiled geglu:
  identical) — no need to replicate compilation for parity.
- mlx-lm cannot load `gemma4_unified` configs by itself; optiq patches
  `MODEL_REMAPPING` (gemma4_unified → gemma4 wrapper → gemma4_text).
  Oracle scripts must call `optiq.mlx_lm_patches._register.register()`.
- Mask handling matches mlx-lm for N ≤ sliding_window: "causal" string
  for prefill (all layer types), no mask for single-token decode.
  Sequences crossing the 1024-token window need real window masks and
  rotating caches — **deferred to Phase 3** (the harness prompt+100 stays
  under the window).
- 0-d scalars via bun:ffi: `ptr()` rejects empty TypedArrays — pass a
  dummy 1-element shape buffer with `dim=0`.

## Phase 3 — Sampling + streaming generation `[x]`

- [x] Temperature, top-p, top-k, repetition penalty, seeded RNG
      (`src/sampler.ts` — port of mlx-lm sample_utils; per-step keys
      derived from (seed, step); all filtering on-device).
- [x] Prefill chunking (2048, matching mlx-lm; cache state evaluated per
      chunk; logits never computed for non-final chunk positions).
- [x] Generation API: `generate()` async iterable with usage stats
      (`src/generate.ts`); decode pipelined via mx.async_eval (step n+1
      dispatched before step n's token is read).
- [x] KV caches: preallocated KVCache (step 256, slice_update) +
      RotatingKVCache (ring buffer, keep=0) — full cache.py port for the
      paths gemma4 uses. Window masks via create_causal_mask port.
- **Exit criterion:** decode within 5% of mlx-lm. → **Met: 24.9 vs
  25.7 tok/s (−3.1%) on the standard workload** (600 tok, 28-tok prompt,
  same machine, same day, both via direct generate — no server). Peak
  memory 9.20 GB vs python's 9.84 GB. Prefill at parity (257 vs 258
  tok/s on a 3.5k prompt).

### Phase 3 findings (2026-06-10)

- **The PLAN baseline of 14.1 tok/s was server-inflated.** mlx-lm's
  direct `stream_generate` does 25.7 tok/s on this machine. All future
  comparisons must be direct-vs-direct (or server-vs-server).
- **Long-context (3.5k prompt) parity verified**: 24/24 greedy tokens
  identical to oracle through chunked prefill + window masks + rotating
  cache + past-window decode.
- **Long-context decode gap: ~10%** (23.2 vs 25.7 tok/s steady-state at
  3.5k context, 43 vs 39 ms/step). Suspects: buffer-donation differences
  in the cache slice_update path, per-step dispatch overhead. Phase 6
  (quantized KV) changes this code path anyway — optimize then.
- **mlx-lm's TokenizerWrapper adds 3 tokens vs canonical AutoTokenizer**
  on chat-template prompts. Our encode matches AutoTokenizer exactly
  (3511/3511 ids on a 3.5k-token prompt, zero diffs). When comparing
  generations cross-stack, always pass explicit token ids.
- Async generators run nothing until first iteration — time prefill
  *inside* the generator, or "step 0" silently includes the whole
  prefill (a 14-second 'stall' that wasn't).
- First decode step pays ~500 ms of Metal kernel compilation for the
  decode shapes (one-time, same for python).

## Phase 4 — Server `[~]` (code complete; pi end-to-end pending)

- [x] OpenAI-compatible `/v1/chat/completions` (+ streaming SSE),
      `/v1/models`. Anthropic `/v1/messages` shim later if pi/OpenClaw
      need it. (`src/server.ts`, run via `bun scripts/serve.ts`
      [default port 8090]; integration tests on an ephemeral port in
      `tests/server.test.ts`. Incremental detokenizer holds back partial
      multi-byte sequences. Generation serialized through one queue.)
- [x] Tool calling (`src/tool-call.ts` — port of mlx-lm
      tool_parsers/gemma4.py): `<|tool_call>call:name{...}<tool_call|>`
      captured at the token level (markers are single special tokens;
      `<|tool_response>` token 50 is in the EOS set = tool handoff) →
      OpenAI `tool_calls` JSON; tool role round-trip verified end-to-end
      against the live model; template renders tools byte-identical to
      `apply_chat_template`.
- [x] Vision path (`src/vision/`): `image_url` (data:/http(s):) → pure-JS
      png/jpeg decode → PIL-style bicubic resize → 48×48 patchify →
      encoder-free VisionEmbedder + MultimodalEmbedder from the bf16
      sidecar → features spliced over `<|image|>` placeholder runs
      (boi + img×soft + eoi) → single-shot prefill with image-token
      bidirectional masks. **Token-exact parity with the optiq python
      stack** on a resize-free fixture (`goldens/vision.json`).
- [x] Byte-capped LRU prompt cache (`src/prompt-cache.ts`): longest-
      common-prefix matching with cache trim (KVCache always trimmable,
      rotating caches until the ring wraps); evicts by BYTES, never
      count; `cached_tokens` reported in usage; `/stats` endpoint.
      Vision requests bypass it (placeholder image tokens would
      false-hit across different images).
- **Exit criterion:** pi connects via models.json and completes the
  ls-and-summarize agent task end-to-end; vision request on a real image
  (synthetic-image vision verified in tests — real photo still untested);
  kill -9 mid-stream restart < 2s (model open is ~15 ms lazy; expected
  trivially met — verify alongside the pi test). **→ Josh runs this part**
  (`bun scripts/serve.ts`, port 8090).

### Phase 4 findings (2026-06-10)

- **bun:ffi + JIT corruption — root cause found (2026-06-10)**: not f64
  marshaling. A standalone repro (`repro/bun-ffi-f64/`, confirmed on Bun
  1.3.3 and 1.3.14) proves that after DFG tier-up (~6–20k iterations of
  the calling function), **typed-array reads following a bun:ffi call
  return stale values** — the DFG eliminates the load across the native
  call as if it can't clobber the buffer. Ground truth: C receives every
  arg intact (ptr/f64/i32/u64) and writes correctly; a native re-read of
  the same address returns the fresh value while `buf[0]` in JS returns
  the tier-up-era value. Disappears with `BUN_JSC_useDFGJIT=false`.
  `read.f64(ptr)` (bun:ffi) reads correctly — **rule: never read a
  typed array that native code wrote into from a hot path; use
  bun:ffi `read.*` instead.** `outArray`'s fresh-buffer handle read is
  the same risk class (store-to-load forwarding) — needs hardening.
  Issue draft: `repro/bun-ffi-f64/ISSUE.md` (not yet filed). The arange
  host-side workaround stays (it removed the offending read path).
- mlx errors no longer abort: `mlx_set_error_handler` + JSCallback turns
  them into JS exceptions with stacks (server survives bad requests).
- Prompt-cache reuse boundary: the `<|channel>thought\n<channel|>`
  generation-prefill tokens never re-render in later turns, so reuse
  stops at the last assistant turn's `<|turn>model\n` (~4 tokens
  re-prefill per turn; full history before that reuses).
- The pipelined decode forwards a token's KV before knowing it's EOS —
  cache token lists must include it (`stats.cacheTokens`).
- Image preprocessing upscales small images (96×96 → 768×768 bicubic)
  to fill the 280-soft-token budget — PIL-resize fidelity matters for
  real photos; our convolution resize ports PIL's algorithm but isn't
  bit-identical. Resize-free inputs (multiples of 48 ≤ 768×768) are
  bit-exact through the whole vision pipeline.
- **Image decode (since Bun 1.3.14, upgraded 2026-06-10): `Bun.Image`**
  — native OS codecs (`backend: "system"` = ImageIO on macOS), EXIF
  auto-orient, off-thread. It has no raw-pixel terminal, so non-PNG
  inputs (HEIC, AVIF, WebP, JPEG, TIFF, GIF, BMP) are transcoded to
  lossless PNG and decoded by fast-png; PNG inputs skip the bridge
  (exact, the parity-golden path). `Bun.Image.resize` is NOT used — its
  kernels don't match PIL's antialiased bicubic that the vision tower
  was trained behind. jpeg-js dropped. HEIC verified end-to-end
  (sips-generated fixture; sub-LSB pixel diff; grounded description).
- Post-upgrade re-verification (1.3.3 → 1.3.14): all 72 tests pass;
  `Bun.mmap` >4 GB STILL panics (libc mmap stays); the f64 FFI
  workaround stays (whether 1.3.14 fixed it is unconfirmed — the
  host-side arange is safe regardless).
- optiq's bidirectional-mask patch has a bug on the sliding array-mask
  path (>1024-token vision prompts get +1.0 additive instead of a mask);
  ours uses proper bool OR. Divergence only matters for long vision
  prompts; parity verified in the regime where both are correct.

## Phase 5 — The appliance layer `[~]`

Where we beat Python, not just match it.

- [x] **Model registry (bun:sqlite)**: scan HF cache → models table
      (`src/registry.ts`: path, repo, model_type, params, quant, size,
      vision/tools/kv-quant capabilities). CLI (`src/cli.ts`):
      `mlx-bun scan|ls|fit|serve|evals`.
- [x] **KV-cache persistence** (`src/kv-store.ts`): page-aligned cache
      files (the Phase 1 corollary pays off — reload is a zero-copy
      MAP_PRIVATE mmap straight to the GPU, 1 ms for the demo prefix);
      saves both cache types incl. ring state; continuation is
      token-identical. Server auto-persistence of large prefixes is
      still TODO (library API + harness done).
- [x] **Eval DB** (`src/evaldb.ts`): runs recorded with commit + fit
      predictions; `scripts/bench.ts` records automatically;
      `mlx-bun evals` lists.
- [~] **Memory contracts (`mlx-bun fit`)** (`src/fit.ts`): (a) fit report
      ✓ (weights/kv/transient vs wired ceiling, max safe context solve,
      predicted decode 23.7 vs measured 24.9 tok/s — within 5%);
      (b) SKU matrix ✓ (`fit <query> --skus`); (c) `loadModel({
      memoryBudget })` enforcement — TODO (needs mlx_set_memory_limit
      wiring + request rejection in the server).
- [ ] Downloader: resumable HF fetch with checksums (native fetch; no
      Xet; the thing the Python downloader kept failing at).
- [ ] **Embeddable build**: `bun build --compile` single-binary target for
      the Tauri/Electron sidecar pattern — apps ship local inference with
      zero user-visible dependencies. Requires: library-first API (server
      is one consumer of it), relative-path dylib loading, a documented
      signing/notarization recipe, first-run weight download via the
      registry + downloader.
- **Exit criterion:** cold start → first token of a cached-prefix prompt
  in under 1s → **Met: 394 ms** (model open 8 ms + kv load 1 ms + first
  token 385 ms; `scripts/cold-start.ts`, fresh process). `mlx-bun ls`
  answers "vision-capable models under 10 GB" → **Met**
  (`bun src/cli.ts ls --vision --max-size 10GB`).

### Phase 5 findings (2026-06-10)

- **Zero-copy KV reload works as designed**: page-aligned tensors in
  files we write mmap straight to GPU (verified positively — Phase 1's
  alignment theory confirmed; both MAP_SHARED and MAP_PRIVATE read
  correctly). MAP_PRIVATE (copy-on-write) guards the file against any
  mlx buffer donation.
- **`rawBytes` on a sliced view reads the underlying buffer layout** —
  always `mlx_contiguous` before serializing views.
- Fit calibration on this machine: DECODE_EFFICIENCY 0.82 (measured/
  bandwidth-ceiling), TRANSIENT_PER_TOKEN 0.55 MB (peak deltas at chunk
  2048), WIRED_FRACTION 0.75. Predicted 23.7 vs measured 24.9 tok/s.
- TTFT measured inside the test suite is inflated ~3× by GPU memory
  pressure from earlier tests — cold-start claims need a fresh process
  (`scripts/cold-start.ts` is the criterion harness).

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
  Phase 0 said yes; Phase 1 amended: zero-copy wrap is CPU-only unless
  page-aligned. Weights use mlx's native lazy loader instead.
- ~~Tokenizers binding: C API vs WASM — perf and packaging trade.~~
  Answered in Phase 1: neither — `@huggingface/tokenizers` is pure JS.
- Vision sidecar format: confirm optiq_vision.safetensors layout and
  preprocessing (no preprocessor_config.json in the repo; read optiq/vlm
  source).
- Bun Rust-core transition: when canary becomes stable, does bun:ffi
  change? Track release notes.
- ~~Chat template drift: hand-ported templates rot when models update —
  checksum the upstream .jinja and warn on mismatch.~~ Answered in
  Phase 1: no hand-port; render the model's own template via
  `@huggingface/jinja` — drift impossible by construction.

## Context / lore

Born from an evening of running gemma-4-12B-it-OptiQ-4bit through the
Python stack on this machine (M4 Pro, 24 GB): Xet download stalls, a
segfault on ctrl-C, a PIL-shaped missing dependency, a repo-id-vs-path
crash in the vision engine, and an OOM-by-prompt-cache footgun — none of
them GPU problems. The thesis of this project is that the layer with all
the bugs is also the layer that doesn't need Python.
