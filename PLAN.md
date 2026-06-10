# PLAN

Working plan for mlx-bun. Each phase has an exit criterion — we don't move
on until it's met. Status markers: `[ ]` todo, `[~]` in progress, `[x]` done.

## Design principles

- **Logit parity is the oracle; optiq-equivalence is the ceiling.**
  Every OptiQ model runs on stock mlx-lm — that shared subset is the
  FLOOR, and mlx-lm is its bit-exact oracle (any divergence is a bug
  until proven a fix). optiq's added behaviors (LoRA hot-swap, rotating
  KV-quant, fused prefill, MTP, Responses API, SigLIP, TurboQuant) are
  the SUPERSET we are climbing toward; for those, the optiq source in
  the venv is the reference and parity contracts are stated per phase.
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
- Measured baseline: ~~14.1 tok/s~~ **25.7 tok/s direct decode** (the
  14.1 was server-inflated — Phase 3 finding; compare direct-vs-direct
  only). ~8.5 GB resident serving. Bandwidth ceiling ≈ 32 tok/s.
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

## Phase 4 — Server `[x]` (exit met 2026-06-10)

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
- **Exit criterion → MET (2026-06-10, all three legs):**
  (1) pi 0.79.1 connected via models.json ("mlx-bun" provider added,
  port 8090) and completed the ls-and-summarize agent task end-to-end —
  listed, read, and correctly summarized 3 files through tool calls;
  (2) vision on a real photo (424 KB wedding JPEG → grounded two-
  sentence description; full JPEG→ImageIO→PNG-bridge→vision path);
  (3) kill -9 mid-stream → restart→ready 34 ms, first reply +0.64 s
  (≈0.7 s total, well under 2 s).

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
  Filed upstream: https://github.com/oven-sh/bun/issues/32054
  (`repro/bun-ffi-f64/ISSUE.md` is the local copy). The arange
  host-side workaround stays (it removed the offending read path).
- **Out-param read hardening (2026-06-10)**: audited every JS read of
  memory a bun:ffi call wrote; all out-param readbacks now go through
  `read.u64`/`read.u32` — `outArray`, `activeMemory`, `peakMemory`
  (src/mlx/ffi.ts), `itemUint32` (src/mlx/ops.ts), safetensors-map slots
  in `Weights.open`/`tensor` and `VisionTower.load`. Sites left as-is
  with documented reasoning: `toArrayBuffer` readbacks (`shape`,
  `rawBytes`, `toFloat32` in src/mlx/array.ts) build a fresh view from
  the call's *returned* pointer — data-dependent on the call, no prior
  JS access to forward from; node:fs reads into buffers (kv-store
  header parse) are host builtins, not dlopen'd FFI. Constructor-
  initialized slots (`new BigUint64Array([handle])`) stay: the init
  store happens in host code the DFG can't elide. Notable negative
  result: temporarily reverting `outArray` to `slot[0]` did NOT fail
  under bun:test even at 50k iterations — fresh-per-call buffers (and
  loop bodies with interleaved host calls) don't currently trigger the
  elimination; only the minimal persistent-buffer repro does. So the
  hardening is defensive (risk class, not observed breakage) and
  `tests/ffi-jit.test.ts` (3 tests, ~0.9 s) pins the read.* paths past
  DFG tier-up + logs naive-read staleness if a future Bun makes it bite.
  All 72 pre-existing tests pass post-change (75 total now).
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

## ~~NEXT UP gate~~ — bun:ffi JIT hardening `[x]` (2026-06-10)

Root cause found: not f64 marshaling — a JSC DFG stale-read eliding
typed-array reads of memory a bun:ffi call wrote (filed as bun#32054
with minimal repro). Hardened in commit 891fb70: all out-param readbacks
go through `read.u64`/`read.u32`; toArrayBuffer readbacks documented
safe; `tests/ffi-jit.test.ts` pins the paths past DFG tier-up.
75/75 tests, no perf regression (23.6 tok/s bench).

## NEXT UP (updated 2026-06-10, post-Phase-15 — THE HANDOFF BLOCK)

State: all three Gemma-4 targets at tier-a/d bit-exact parity; Phases
4, 8 done; mixed-precision KV serving shipped; Phase 15 matrix
published (benchmarks-h2h-2026-06-10.md + README Benchmarks — TTFT
3–5×, zero server tax, fastest served stack on every model). The
repo's durable state is THIS FILE + the findings sections; trust rows
in the eval DB over numbers quoted in old findings (some early
"measurements" were made on a memory-degraded machine — see the
Phase 15 corrections finding).

Remaining work, in priority order:

1. **12B long-context decode gap (−10.0% @8k vs mlx-lm, n=3
   zero-spread — benchmarks-h2h-2026-06-10.md).** The Phase 3 finding,
   now precisely bounded. Suspects recorded then: KVCache slice_update
   buffer donation; per-step dispatch overhead. Related measured fact:
   our kv-mixed decode costs ~3% @8k (22.7 vs 23.4) where optiq's
   fused path is free — so Phase 10 (fused_quant_sdpa port, op-level,
   ~line-for-line) plausibly closes BOTH. Start there.
2. **Phase 15 closeout**: leg (c) purge-cold rows (`sudo purge` +
   cold start → first token per stack); fix the failure-footer to
   record the child's stderr line instead of our wrapper line.
3. **Phase 5 leftovers** (independent): memoryBudget enforcement
   (admission control — the optiq 26B server crash is the cautionary
   tale), downloader, embeddable build. Docs-pass items.
4. Then Phase 9 (rotating KV-quant — reframed, see preamble),
   11 (Responses), 12 (SigLIP), 14 (Qwen).

## Phase 6 — Speed: change what gets computed `[~]`

Ordered by expected payoff on this hardware:

- [x] **Speculative decoding** (gemma-4-e4b + its -assistant drafter;
      ports of optiq runtime/spec/{runtime,drafters/gemma_assistant,
      kv_view}.py in `src/spec/`). **Measured: NET LOSS on e4b at every
      depth** — γ=1: 0.91x, γ=2: 0.78x, γ=3: 0.63x, γ=4: 0.51x of the
      54 tok/s non-spec baseline; acceptance 33/23/16/12% on agent-style
      prompts (optiq's ~70%-at-depth-2 did not materialize: the python
      reference itself measures 18% on our prompts — verified by an
      IDENTICAL accept/reject trace, 92 drafted/17 accepted/47 target
      calls in both stacks). e4b's small-model decode is too fast for
      this drafter to beat. Recorded in the eval DB.
      **e4b bring-up landed en route**: per-layer-input embeddings,
      KV-shared layers (donor/sharer plumbing), dynamic weight prefix —
      e4b single-forward logits BIT-EXACT vs python, 24/24 greedy,
      51.6 tok/s non-spec, multi-model fit predicted 7.91 GB vs 6.83
      measured (over-prediction: transient calibrated on 12B + KV@4k).
- [x] **Fused sampling** — already satisfied by the Phase 3 design:
      sampling (temp/top-p/top-k/penalties) runs entirely on-GPU; only
      the chosen token id (one uint32) crosses to JS per step; the
      pipelined loop feeds the un-read token array into the next graph.
      No vocab-tensor round-trip exists to eliminate.
- [x] **Quantized KV cache** (`QuantizedKVCache` + `quantizedSdpa` ports
      of mlx-lm cache.py/base.py; `generate({kvBits, kvGroupSize,
      quantizedKvStart})`). Full-attention layers only — rotating-cache
      quantization is NYI upstream too, and sliding layers are
      window-capped. **Measured @8k ctx: full-layer KV 134→71 MB AND
      decode 18.5→22.4 tok/s (+21%)**, identical output text. The
      N-tiled FlashAttention prefill port (fused_quant_sdpa) is still
      TODO — only needed for long-prefill-over-quantized-cache
      (continuations past quantizedKvStart); stock path covers serving.
- [x] **MoE support — gemma-4-26B-A4B (DONE 2026-06-10: bring-up,
      tier-d parity, cleared-machine bench).** Bench (recorded in eval
      DB): **32.3 tok/s decode @600 tok vs python 33.0 (−2.1%, at
      parity)**, peak 17.84 GB. Getting there surfaced the WIRED-LIMIT
      fix (see findings — was 8.6 tok/s, a 4x loss). Parity gate
      PASSED: single-forward logits BIT-EXACT
      (toBe(0), 4 steps incl. prefill over the sorted gather path) and
      12/12 greedy tokens identical vs the oracle
      (tests/parity-26b.test.ts; goldens regen:
      scripts/regen-parity-goldens-26b.ts, chat-templated). Ported: Router
      (rms_norm·√H⁻¹ → 8-bit proj → argpartition top-8 → softmax →
      per_expert_scale), QuantizedSwitchLinear/SwitchGLU (gather_qmm,
      incl. the ≥64-indices token-sort path), Experts, and the parallel
      dense+routed DecoderLayer branch (3 extra norms). New bindings:
      `mlx_gather_qmm` (13-arg; pinned by tests/moe-ops.test.ts) +
      `mlx_floor_divide`. Attention needed NOTHING new (2 global KV
      heads @ 512 + k_eq_v is generic in our port). Smoke: coherent
      grounded greedy output through the full MoE path, peak 16.5 GB.
      **Fit row (measured prediction, registry now MoE-aware)**:
      text-only FITS on 24 GB — 16.42 GB weights + 0.35 GB KV + 1.05 GB
      transient = 17.82/18.0 GB @ 8k; max safe context ~17.6k; predicted
      decode 58.6 tok/s @ 8k (decode reads only top-8/128 experts:
      ~2.4 GB active of 14.09 GB expert weights). KV is NOT the fit
      blocker at 24 GB (only 5/30 full-attention layers × 2 KV heads;
      sliding layers cap at window 1024) — Phase 9 coupling is softer
      than feared for THIS model.
      Registry/fit upgrades (cross-cutting items landed): sidecar bytes
      and `.experts.` bytes are separate registry columns (header-only
      scan); `fit` prints the sidecar line item and uses active-expert
      bytes for decode prediction.
      For Phase 8 (parallel): serving-side oracle is
      `optiq/adapters/{mount,registry,resolver}.py`; `lora/apply.py` is
      the TRAINING-side rank logic — read mount.py first for hot-swap
      (apply.py's first 60 lines confirm mlx-lm LoRALinear weight-name
      compatibility, incl. LoRASwitchLinear for MoE expert pools).
- **Exit criterion (REFRAMED 2026-06-10):** the speed/memory levers
  (quantized KV, speculation, MoE, fused prefill) are each
  CHARACTERIZED with measured numbers in the eval DB, and the
  best-performing configuration per (model, context) is shipped as the
  default. The original "≥2x over Phase 3 baseline" was workload- and
  model-dependent in ways the spec-decode result disproved (a net loss
  on a fast small model; MoE's win is capability-per-byte, not a raw
  multiple on the same model). The 12B's 25.7 tok/s is the wrong
  denominator for any other model's numbers — compare same-model,
  same-context only.

### Phase 6 findings (2026-06-10, spec-decode session)

- **Spec≡non-spec bitwise equality does not survive bf16 knife-edges,
  even in the reference**: optiq's own spec_generate diverges from its
  own incremental greedy at token 30 on a borderline prompt — the
  batched verify forward rounds differently than token-at-a-time decode.
  Our per-position lm-head picks match stock-decode kernel shapes
  exactly, but the verify ATTENTION is inherently batched. Test gate:
  toBe-exact on tie-free prompts (3/3 γ values pass), long-prefix on
  knife-edge prompts, accept/reject trace equality vs python.
- The gemma-4 assistant drafter is NOT a standalone LM: Q-only 4-layer
  net reading the TARGET's last sliding+full donor caches (chronological
  views), pre/post projections bridging 2560↔256, centroid-clustered
  output head (2048×top-32×128). Its 4-layer config with
  num_kv_shared_layers=4 cannot run standalone — loader must not try.
- Spec rollback requires trimmable caches: rotating caches lose trim
  past the 512 window (reference raises; so do we). Long-context spec
  needs plain+window-mask sliding caches — not built (spec is a net
  loss here anyway).
- Drafter implementation shortcut (argmax-equivalent, documented in
  src/spec/drafter.ts): argmax over the 4096 centroid-candidate scores
  instead of scattering into 262k logits.
- ~~Phase 6 exit (≥2x) still open~~ — superseded the same day: the
  exit criterion was reframed to "characterize each lever, ship the
  best defaults" (see Phase 6), and the MoE landed with bit-exact
  parity in the following session.

### Phase 6 findings (2026-06-10, verification session)

- **mx.set_wired_limit is load-bearing for models near the working-set
  ceiling**: without it (our old state: wired limit 0), the 26B decoded
  at 8.6 tok/s — Metal evicts and re-faults weight buffers every token.
  Setting it to max_recommended_working_set_size (17.76 GiB here, via
  mlx_device_info) recovers 32.3 tok/s. mlx-lm does this in its
  wired_limit context / server startup — a reference behavior that
  lives OUTSIDE the model graph, easy to miss when porting op-for-op.
  Ours is set once per process in generate() (ensureWiredLimit).
  Models comfortably under the ceiling (12B, e4b) never showed this.
- **MoE decode is gather-bound, not pure-bandwidth**: both stacks land
  ~0.42 of the active-bytes bandwidth ceiling (vs 0.82 for dense) —
  fit now uses MOE_DECODE_EFFICIENCY 0.42; predicts 30.0 vs 32.3
  measured (−7%).
- Cold prefill on the 26B is page-in-dominated (~10 tok/s on a 28-tok
  prompt = 16.4 GB read at SSD speed inside the prefill timer) — steady
  prefill needs a warm second run to measure honestly.
- **Async GPU command-buffer errors are UNCATCHABLE and kill the
  process**: mlx's `gpu::check_error` throws from inside a Metal
  completion handler (its own dispatch thread) — no mlx-c wrapper or
  JS error handler is on that stack, so it's std::terminate ("panic:
  A C++ exception occurred" in Bun). Bisected over three suite runs:
  BOTH a process-permanent wired limit AND a faithful port of
  mlx-lm's scoped wired_limit context crashed the multi-model test
  suite (12B + e4b + vision resident in one bun process — wiring up
  to 17.76 GiB during any generation pins memory the other resident
  models need → GPU exec OOM). **Fix: wire CONDITIONALLY** — only
  when the generating model's weights exceed 0.75× the max
  recommended working set (src/generate.ts WIRE_THRESHOLD; scope
  semantics still reference-exact: set → generate → synchronize →
  restore). Deviation from mlx-lm's unconditional wiring is justified
  by measurement: 12B/e4b (≤47%) reach reference parity unwired; the
  26B (92%) needs it (8.6 vs 32.3 tok/s); and unconditional wiring is
  what killed the suite. 86/86 after; 26B bench unaffected.
  Consequences: (1) tests/parity-26b.test.ts is OPT-IN anyway
  (`MLX_BUN_TEST_26B=1`, run the file alone — 16.4 GB on top of a
  suite already holding ~15 GB is over budget regardless); (2) the
  server CANNOT defend against over-committed GPU memory by catching
  errors — admission control (Phase 5's memoryBudget enforcement) is
  the only defense; that item is now more than a nice-to-have.

### Phase 6 findings (2026-06-10, MoE bring-up session)

- **26B-A4B MoE is bit-exact vs the oracle on the first try of the
  parity gate** — the tier-d worry (bf16 knife-edges in router top-k)
  did not bite: same mlx argpartition/softmax/gather_qmm kernels + same
  composition order ⇒ identical tie-breaks by construction. The gate
  stays toBe(0).
- **gather_qmm ≠ quantized_matmul numerically** (~2e-6 rel in f32):
  different kernels, different accumulation order. Intra-stack
  comparisons of the two need bounded tolerance
  (tests/moe-ops.test.ts); cross-stack parity is unaffected because
  both stacks use gather_qmm.
- The MoE fit math must use ACTIVE expert bytes for decode prediction
  (top_k/num_experts of the 14.09 GB expert pool ≈ 0.9 GB read/token
  → predicted 58.6 tok/s @ 8k vs 11.7 if computed naively from total
  weights). Registry stores `.experts.` bytes from header-only scans.
- KV growth is NOT the 26B's fit problem on 24 GB (only 5/30 full
  layers × 2 global KV heads @ 512, k_eq_v): max safe context ~17.6k
  with bf16 KV. Phase 9 (rotating KV-quant) helps but is not a
  prerequisite for useful serving of THIS model.
- Throughput on a loaded machine is meaningless for a 16.4 GB-resident
  model: the smoke decode ran at ~0.02 tok/s under 6.4 GB of swap from
  the prior test-suite run (Phase 5 memory-pressure finding, amplified).
  The eval-DB number must come from a cleared machine.
- The 26B prompt template renders a system turn + `<|channel>thought`
  generation prefill like the 12B; mlx-lm loads model_type "gemma4"
  natively (no optiq remap needed, unlike gemma4_unified).

### Phase 6 findings (2026-06-10)

- **MTP speculative decoding is NOT possible for gemma-4-12B-it-OptiQ-4bit
  — the MTP head does not exist.** Verified exhaustively (2026-06-10):
  no `mtp.safetensors`/`mtp/weights.safetensors`/`model-mtp.safetensors`
  in the snapshot; every cache blob is linked (no orphan artifact); no
  MTP/draft tensors among the 1324 shard tensors; no
  `mlx_lm_extra_tensors.mtp_file` in config.json; and the REMOTE HF repo
  file list matches the local snapshot exactly — the artifact was never
  published for this model. Deeper: optiq's MTP runtime
  (`optiq/runtime/mtp/backends/`) has backends for deepseek/glm/mimo/
  nemotron-h/qwen3_next only — **no gemma backend**. MTP requires a
  model trained with an MTP head; Gemma-4 doesn't ship one. The "Qwen
  quants ship mtp.safetensors" pattern is real but family-specific
  (qwen3_next, optiq support level "verified-native").
- Paths to the ≥2x exit criterion, both needing a download (Josh's
  call): (a) classic two-model speculation with a small gemma-4 drafter
  (port mlx-lm generate_step's draft_model accept/reject loop; greedy
  output must stay token-identical to non-spec decode — exact-equality
  test tier); or (b) bring up Qwen 3.x (already in scope per design
  principles) with an OptiQ quant that ships the MTP head, and port
  optiq/runtime/mtp (trace_parity.py first) against its qwen3_next
  backend.

- **Greedy trajectories are loop-shape-sensitive, even within mlx-lm**:
  its pipelined stream_generate, an unpipelined manual loop, and our
  pipelined loop produce three different (all-coherent) continuations of
  the same prompt past bf16 knife-edge ties. Parity bars must be
  (a) bit-exact single-forward logits from identical state and
  (b) long-prefix trajectory agreement — never full-trajectory equality.
- **kv8 single-forward logits are BIT-EXACT vs the python reference;
  kv4 differs by 1 bf16 ulp** at the first quantized layer (≤1.0 on
  softcapped logits) — the 4-bit quantized_matmul kernel rounds
  differently for strided-vs-contiguous inputs; legitimate kernel-path
  variation far below 4-bit's own quantization noise. Bounded-tolerance
  assertion documented in tests/kv-quant.test.ts.
- mlx-lm's maybe_quantize_kv_cache CRASHES on gemma4 (calls to_quantized
  on RotatingKVCache → NotImplementedError) — upstream kv-quant is
  broken for this family; oracle scripts must pre-convert KVCache
  instances manually and pass kv_bits=None.
- The kv-quant +21% decode at 8k partially closes the Phase 3
  long-context gap (full-attention layers were the unbounded
  bandwidth term).
- Match mlx-lm's buffer growth exactly: n_steps is integer division
  `(step + L - 1) // step`, not ceil — over-allocating changes nothing
  numerically but wastes memory.
- The old parity golden's prompt was encoded WITHOUT BOS (mlx-lm
  TokenizerWrapper.encode doesn't add it) — its "greedy" sequence is
  degenerate-but-deterministic. Fine as a bit-exactness oracle; useless
  for quality judgments. Quality-sensitive goldens must use
  chat-templated prompts.

## Documentation pass `[~]` (started 2026-06-10)

- [x] README rewritten: requirements, CLI, HTTP API, library usage,
      correctness story, measured numbers, license pointers.
- [x] THIRD_PARTY_LICENSES.md: linked libs (MLX/mlx-c, MIT), ported code
      (mlx-lm MIT; mlx-vlm BSD-3; mlx-optiq MIT; Pillow resample
      algorithm), npm deps (tokenizers Apache-2.0, jinja MIT,
      fast-png MIT), model-license caveat. LICENSE file added (MIT).
- [ ] API reference for the library surface (generate options, cache
      types, fit, registry) — generate from TSDoc or hand-write.
- [ ] Per-file header audit: every ported file names its upstream source
      and license (mostly done; verify coverage).
- [ ] Server API doc: full request/response schemas incl. tool_calls,
      vision parts, /stats; pi models.json setup walkthrough.

## Phase 7 — Kernel experiments (research track) `[ ]`

Only after profiling shows where bytes move unnecessarily.

- [ ] Profile per-tile dispatch overhead in the N-tiled SDPA path.
- [ ] Custom fused Metal kernel for our exact config (4-bit, group 64,
      Gemma GQA shape): matmul + online-softmax update in one kernel via
      mlx's custom-kernel hook. Target: long-context prefill.
- [ ] Write up findings either way — negative results count; this phase
      is the "research project" part.


## Phase 8 — Hot-swap mounted LoRA adapters `[x]` (2026-06-10)

Josh's #1 priority. Mount N adapters on one quantized base, select per
request by id, never reload the base.

- [x] **Mount/registry layer** (`src/lora.ts` AdapterManager): load
      adapter safetensors (header-parse + native map-get), register by
      id, list/unmount; `/v1/adapters` GET/POST/DELETE on the server
      (mutations run through the generation queue); `serve.ts
      --adapter id=dir` mounts at startup. HF-repo-id download
      (resolver.py's snapshot path) deferred — local dirs only,
      pairs with the Phase 5 downloader item.
- [x] **Compatibility validation at mount**: all-or-nothing — every
      lora_a/lora_b pair shape-checked against the base linear's
      (in, out) BEFORE anything attaches; orphaned pairs, zero
      matches, missing dirs fail with module-path-specific errors.
- [x] **Apply layer**: residual on QuantizedLinear.forward —
      `quantized_matmul(x, W_q) + (scale·((x@A)@B)).astype(x.dtype)`;
      base path stays a null-check when nothing is mounted.
- [x] **Per-request selection**: GenerateOptions.adapters →
      model.LoraState held for exactly the generation (adapterScoped
      wrapper). No ContextVar, as planned. HTTP: `adapter` body field
      ("id", "a+b" stacking, "none"); unknown id → 400, loudly.
- [x] **Switch correctness**: A→B→A green; prompt-cache entries
      namespaced by adapter spec (PromptCache take/put `ns`).
- **Parity contract → MET**: (1) FREE gate: mounted-but-inactive AND
  active-at-scale-0 both byte-identical to base (toBe(0));
  (2) adapter-applied logits BIT-EXACT vs the mlx-lm oracle for both
  adapters + greedy prefix identical (tests/lora.test.ts, opt-in
  `MLX_BUN_TEST_LORA=1`; goldens: scripts/regen-lora-goldens.ts).
- **Exit criterion → MET (2026-06-10)**: two adapters mounted on the
  e4b base (28 layers each); per-request selection over HTTP verified
  in-process (upper → "THE SKY IS BLUE", french → "Le ciel est bleu",
  base distinct, unknown → 400, /v1/adapters lists both); scale=0
  byte-identity; A→B→A green with base logits byte-identical after
  all switching; default suite untouched. Fixtures:
  `fixtures/adapters/{upper,french}/` (mlx_lm.lora QLoRA, rank 8,
  last 4 layers; data in `fixtures/adapters/data-*`).

### Phase 8 findings (2026-06-10)

- **Three LoRA compositions exist across the references; only one is
  right.** mlx-lm LoRALinear and optiq apply.py both do
  `y + (scale·z).astype(x.dtype)`; optiq mount.py adds the residual
  UNCAST — with f32 adapter weights (what mlx-lm's trainer saves) that
  promotes the whole downstream residual stream to f32. We follow the
  cast form (it's what the adapters were trained behind); divergence
  documented, same class as the Phase 4 bidirectional-mask bug.
- **optiq mount.py silently drops trained weights on e4b**: its
  7-suffix target list misses per_layer_input_gate /
  per_layer_projection, which mlx-lm's trainer targets on e2b/e4b
  (and which carry real signal — the trained adapters put LoRA there).
  Our loraTargets() covers them; result is bit-exact vs mlx-lm's own
  load_adapters, which optiq's mounted path would NOT be.
- e4b trailing layers (38–41) have no k_proj/v_proj LoRA simply
  because KV-shared sharer layers HAVE no k/v projections — an
  adapter "missing" modules is normal, not an error; per-module
  validation is the gate, not coverage counting.
- The lazy-generator scope pattern (set state → yield* → finally
  restore) now covers both the wired limit and adapter activation —
  graphs are built strictly inside the generator body, so a plain
  field + scope wrapper is exactly as isolating as Python's
  ContextVar under our serialized queue.

## Phase 9 — Rotating-cache KV quantization `[ ]`

The second half of NEXT UP item 2 (mixed-precision KV serving): item 2
covers full-attention layers via the shipped QuantizedKVCache; this
phase extends per-layer kv_config quantization to sliding + KV-shared
layers (optiq's RotatingQuantizedKVCache + SDPA dispatch patch).

The unmatched half of KV-quant — currently 40 of 48 Gemma-4 12B layers
(and ALL e4b sliding layers) keep bf16 KV; "NYI upstream too" hides
that optiq CAN do it. ~~Effectively a co-requisite of Phase 6's MoE
being usable~~ **REFRAMED 2026-06-10 (measured)**: the 26B's sliding
KV is window-capped at ~0.2 GB total and its max safe context is
already ~17.6k with bf16 KV — rotating-quant is NOT a 26B
prerequisite. Its real value: (a) the GROWING term for 26B long
context is the 5 full-attention layers, already quantizable with the
shipped Phase 6 QuantizedKVCache (wire + measure first — cheaper than
this phase); (b) bounded-but-real savings on sliding-heavy stacks
(12B: 40/48 layers; e4b: all sliding) where every wired MB counts at
24 GB. Sequence after the cheap full-attention win is measured.

- [ ] Read `optiq/runtime/kv/rotating.py` (oracle) AND its SDPA
      dispatch patch for Gemma-4's KV-sharing layers BEFORE estimating —
      quantize-into/evict-from a ring buffer; dequant-on-read interacts
      with wrap-around; harder than the full-attention quant.
- [ ] Port: QuantizedRotatingKVCache + dispatch in Attention (donor
      AND sharer paths — sharers consume the quantized triples).
- [ ] Trim/rollback semantics under quantization (spec decode and
      prompt-cache trim both depend on `isTrimmable`).
- [ ] Re-run the long-context decode + memory benchmarks (8k/32k rows
      in the eval DB; fit-table updated with quantized sliding term).
- **Parity contract**: kv8-rotating bit-exact (tier a), kv4-rotating
  bounded-tolerance (tier b) — same tiering as full-attention quant.
- **Exit criterion**: 26B-A4B (or 12B as fallback) serves at a
  measured, materially larger max context on 24 GB with rotating
  KV-quant on; numbers in the eval DB and the fit table.

## Phase 10 — fused_quant_sdpa N-tiled FlashAttention prefill `[ ]`

Already a TODO from the kv-quant phase. Needed for
long-prefill-over-quantized-cache (continuations past
`quantizedKvStart`, prompt-cache reuse on quantized entries).

- [ ] Port the FlashAttention-2 N-tiled loop (online softmax over
      `quantized_matmul` tiles). Oracle:
      `optiq/runtime/fused_quant_sdpa.py`. It is op-level orchestration,
      ~line-for-line portable — NOT a custom kernel.
- [ ] Wire as the L>1-over-quantized-cache path; stock paths untouched.
- **Parity contract**: tier a vs the unfused quantized path at sizes
  where both run; memory: reproduce the reference's bounded-transient
  claim (measure peak at 2048-chunk prefill over an 8k quantized cache).
- **Exit criterion**: long prefill over a quantized cache runs within
  the fit-table's predicted transient; eval-DB row recorded.

## Phase 11 — Protocol surfaces: Responses API + Anthropic messages `[ ]`

Two more protocols beyond chat-completions. Both are plumbing over the
existing generation/tool/vision surfaces — no new engine work.

**Anthropic `/v1/messages`** (added 2026-06-10 — Josh: this is what
Claude Code needs as a local backend; verified that optiq ships it
ON BY DEFAULT in `optiq serve` (`--anthropic/--no-anthropic`,
default True), so the drop-in claim requires it, upgrading it from
Phase 4's "shim later if needed"):

- [ ] Protocol translation, both directions + streaming. Oracle:
      `optiq/anthropic_shim.py` (`anthropic_to_openai_body`,
      `openai_to_anthropic_response`, `AnthropicStreamTranslator`,
      369 lines) — ours translates at the request layer instead of
      monkey-patching a handler (`optiq/anthropic_server.py` exists
      only because Python has to patch mlx-lm's APIHandler; we own
      our server). Mind tool_use/tool_result blocks and the
      Anthropic SSE event grammar (message_start/content_block_delta/
      message_delta/message_stop).
- [ ] On by default like the reference; exercised in the integration
      suite (ephemeral port, streaming + tools round-trip).

**OpenAI Responses** (`previous_response_id` resumption):

- [ ] `/v1/responses` create/stream; map to our generation API.
      Oracle: `optiq/responses_server.py`, `optiq/responses_shim.py`.
- [ ] Response store with `previous_response_id` resumption — TTL+LRU
      and BYTE-capped like the reference (`optiq/response_store.py`);
      pairs naturally with our PromptCache prefix reuse.
- **Exit criterion**: (a) an OpenAI-SDK Responses client completes a
  multi-turn resumed conversation against `mlx-bun serve`; store
  eviction observable via /stats. (b) an Anthropic-SDK client (or
  Claude Code pointed at the port via ANTHROPIC_BASE_URL) completes a
  multi-turn streamed conversation with tool use.

## Phase 12 — SigLIP vision tower `[ ]` (capability — Josh's hold)

Lights up e2b/e4b/26B-A4B/31B image input. The 12B unified
(encoder-free) path is done — it was the hard case. **Do after
optimizations / only if needed**: nothing above depends on it.

- [ ] Port the SigLIP encoder + frontend. Oracle:
      `optiq/vlm/gemma4/{vision,frontend,image_processing}.py`. Mind
      the gemma4_text embed_scale pre-division detail (vision features
      pre-divided; the model re-multiplies — same as the unified path).
- [ ] Keep the existing pure-JS decode + PIL-port resize approach;
      resize-free fixtures are bit-exact, the resample impurity stays
      documented.
- **Exit criterion**: e4b answers an image question end-to-end;
  resize-free fixture parity vs the optiq stack (tier a on ids +
  greedy prefix, as the 12B vision suite does).

## Phase 13 — TurboQuant `[ ]` (research path — lowest priority)

Rotation-based vector quantization. Oracle:
`optiq/runtime/mtp/turboquant.py`. Quality-critical-workload niche even
per optiq; hardest math, lowest daily value. **Sequence last; it is
legitimate to never ship this.** Exit criterion (if attempted):
reproduce the reference's quality-vs-bpw curve on one model; otherwise
record a decision not to.

## Phase 14 — Qwen 3.x family bring-up `[ ]` (the MTP home)

Second model family (always in scope per design principles). This is
where MTP speculation actually works: Qwen quants bundle the MTP head
(`mtp.safetensors`), and optiq's MTP runtime has a `qwen3_next` backend
("verified-native") — unlike Gemma, which has no MTP head and where
two-model speculation measured a net loss.

- [ ] **(a) Model graph**: port qwen3_5_text / qwen3_6 (new
      architecture, chat template, tokenizer; registered via optiq's
      MODEL_REMAPPING — see `optiq/mlx_lm_patches/qwen3_5_text.py`).
      Fresh tier-a bit-exact parity from scratch. **Josh: pick + download
      the first Qwen quant** (2B/4B class first).
- [ ] **(b) MTP speculation**: oracle `optiq/runtime/mtp/` — start with
      `trace_parity.py` (their parity harness encodes the load-bearing
      invariants), then the `qwen3_next` backend. Parity: greedy-MTP
      token-identical to greedy-non-MTP by construction, gated per
      testing-strategy tier c.
- [ ] **(c) Measure where it pays**: small Qwen3.5 quants (2B/4B) are a
      different size regime from the e4b result — measure, don't assume,
      either direction.
- [ ] **(d) Qwen3-VL vision**: third vision architecture — defer with
      SigLIP (Phase 12 bucket).
- [ ] 35B-A3B (MTP + MoE in one model) does NOT fit on 24 GB:
      characterize as a fit-table row only; **runs on larger hardware
      (Josh's machine choice)**.
- **Exit criterion**: one Qwen text model at tier-a parity + MTP
  speculation measured (acceptance + tok/s in the eval DB), shipped as
  default config only where it wins.

## Phase 15 — Head-to-head benchmark: mlx-bun vs mlx-lm vs mlx-optiq `[~]`
(matrix complete 2026-06-10 except leg (c)'s purge-cold rows — see
findings; results: benchmarks-h2h-2026-06-10.md + README Benchmarks)

The publishable comparison (added 2026-06-10). Everything so far
measures parity per-component; this phase produces one same-day,
same-machine table across all three stacks. It also settles the two
claims we currently make on vibes: (a) startup advantage — our 394 ms
cached-prefix cold start is recorded, but no apples-to-apples Python
startup number exists; (b) server overhead — mlx-lm's server measured
−45% vs its own direct decode (14.1 vs 25.7 tok/s, Phase 3 finding);
OUR server-mediated decode has never been measured.

Matrix: stacks {mlx-bun, mlx-lm, mlx-optiq} × models {e4b, 12B,
26B-A4B} × legs:

- [x] **(a) Direct engine**: prefill + decode tok/s, peak memory
      (mostly exists in the eval DB — consolidate, re-run any number
      not from a cleared machine on the same day).
- [x] **(b) Server-vs-server**: TTFT and streamed decode tok/s through
      HTTP (same prompts, explicit token ids, measured at the client),
      peak resident memory while serving, per-request memory growth
      over a 20-request session. Compare like-for-like: ours vs
      `mlx_lm.server` vs `optiq serve` (with `--kv-config` once NEXT UP
      item 2 ships ours). First sub-step needs no Python: our
      server-vs-our-direct overhead via an ephemeral in-process server
      (e4b, idle machine) — pins the "our server adds ~nothing" half
      of the 70%-faster hypothesis.
- **Decision (Josh, 2026-06-10): do not start ANY of these
  measurements — including the Python-free server-overhead sub-step —
  until NEXT UP item 2 (mixed-precision KV serving) has landed.** The
  whole matrix runs once, against the real serving config.
- [~] **(c) Startup**: ready-time measured per stack (0.36–0.48 s vs
      0.79–0.95 s); purge-cold first-token rows still open →
      first token (fresh process, page cache cleared vs warm); our
      cached-prefix path recorded as its own row (the Python stacks
      have no KV persistence — capability diff, noted not hidden).
- [x] **(d) Long-context @8k**: decode tok/s + memory with each
      stack's best KV config (ours per kv_config.json; optiq
      `--kv-config`; mlx-lm stock — its gemma4 kv-quant crashes,
      recorded finding).
- **NEXT SESSION PICKUP (2026-06-10)**: Josh reboots and runs
      `./benchmark.sh` (one-shot; writes eval-DB rows + a
      benchmarks-h2h-<date>.md). Session work then: read the results
      file / `bench-h2h.ts table`, sanity-check spreads, fold the table
      into README, settle the "+21% kv8" question from the @8k A/B
      rows, and mark legs (a)-(d) here. If preflight aborted mid-run,
      partial rows are recorded — finish with another reboot.
- [x] Harness: `scripts/bench-h2h.ts` (built 2026-06-10):
      `preflight|direct|server|client|table`. Preflight ENFORCES the
      method rules (swap ≈ 0, free-memory floor, thermal, big foreign
      processes) — refuses uncleared machines; `--force` records rows
      flagged "preflight-failed". Interleaved median-of-N, discarded
      warmup, machine-state snapshot in every eval-DB row (new
      `stack` + `machine_state` columns). `client` mode measures
      Josh-started python servers identically (TTFT + streamed decode
      at the client). Smoke-tested end-to-end on a dirty machine
      (rows flagged, not headline).

### Phase 15 — PRE-REGISTERED cross-machine predictions (2026-06-10)

Written down BEFORE any second-machine run. Two findings, two
different predicted scaling laws — one benchmark run falsifies or
confirms both diagnoses. Reference machine: M4 Pro, 24 GB,
~273 GB/s.

- **P1 (decode ∝ bandwidth):** direct decode tok/s on another chip ≈
  reference tok/s × (BW_other / 273), ±15%. Holds for all three
  stacks (decode is memory-bound everywhere).
- **P2 (the @8k gap is bandwidth-bound):** IF the 12B@8k −10% gap is
  a non-donated cache copy (extra bytes/token), the gap stays ~the
  same PERCENTAGE on any chip. If it shrinks materially on faster
  single-core silicon, it's (partly) dispatch-bound and the copy
  story is wrong or incomplete — either outcome redirects the fix.
- **P3 (TTFT/server overhead ∝ single-core CPU, not bandwidth):**
  the ours-vs-python TTFT ratio (45–89 ms vs 220–327 ms, 3–5×) holds
  across chips; absolute values shift with single-core perf, not
  with GB/s.
- **P4 (MoE fit):** the 26B runs only where weights < 75% of RAM
  (harness now skips it otherwise); where it runs, decode follows P1
  with ACTIVE bytes.

If P1–P3 reproduce, the writeup upgrades from "on my Mac" to
"architecture-invariant". Record the second machine's rows in its own
benchmarks-h2h-<date>-<host>.md (the harness stamps host/chip per
file and per row).

### Phase 15 findings (2026-06-10, full-matrix run)

- **Full 25-cell matrix landed** (benchmarks-h2h-2026-06-10.md, commit
  0ee00dd, n=3 direct / n=5 server, preflight-clean): the README
  Benchmarks section is the publishable summary. Headlines: TTFT
  45–89 ms vs python's 220–327 ms (3–5×); start→ready 0.36–0.48 s vs
  0.79–0.95 s; OUR server tax ≈ 0 while mlx-lm's server costs itself
  5–6% decode; served-over-HTTP we are the fastest stack on every
  model. Honest negatives: direct decode trails mlx-lm 2.2–4.4%
  (e4b worst — per-token dispatch overhead exposure), and the 12B @8k
  decode gap is −10.0% (n=3, zero spread) — the Phase 3 long-context
  gap, now the top perf item.
- **Generation-only peaks resolved the memory story**: python's
  constant 9.84 GB was its LOAD transient (non-lazy load ≈ 2.7× model
  size transiently); engine-vs-engine generation peaks are at parity
  (8.98 vs 9.10 on 12B). The honest claim is cold-start/transient
  superiority, not steady-state memory.
- **Our kv-mixed costs ~3% decode @8k (22.7 vs 23.4) where optiq's is
  free (25.7 vs 26.0)** — their fused quantized-SDPA earns its keep at
  context. Promotes Phase 10 (fused_quant_sdpa) + the long-context
  decode investigation to next-perf-work, now with a measured target.
- **optiq serve crashed loading the 26B** — `[METAL] ... Insufficient
  Memory`, the SAME uncatchable completion-handler crash class we
  documented for our own test suite. Python's non-lazy load transient
  on 16.4 GB of weights has no admission control and no defense;
  reproduced in isolation. mlx-bun served the same model from the
  same machine state at 55.1 tok/s (lazy load + scoped wired limit).
  This is the strongest single differentiation datum in the matrix.
- optiq e4b mixed-KV direct stays failed (upstream 4-bit-shim bug,
  root-caused at cc0c151). Failure footer in the md carries both root
  causes — holes are self-documenting now.
- **CORRECTION to earlier same-day numbers**: the morning "26B at
  32.3 vs python 33.0 = parity" rows were BOTH memory-degraded — the
  cleared-machine matrix puts the 26B at 54.5 (ours) vs 55.7 (python).
  Parity held in both states (which is why it looked fine), but the
  absolute numbers were ~40% low. MOE_DECODE_EFFICIENCY recalibrated
  0.42 → 0.76 (fit now predicts 54.3 vs 54.5 measured). Standing rule
  sharpened: a paired comparison surviving on a dirty machine says
  nothing about absolute throughput.
- Harness nit for next pass: the failure footer records OUR wrapper
  line, not the underlying python error's first line — extract the
  child's last stderr line instead.

### Phase 15 findings (2026-06-10, harness bring-up)

- **The harness found a real serving bug in its first run: our SSE
  response didn't stream.** The decode loop is an unbroken microtask
  chain (FFI calls + async-generator resumes never yield the event
  loop), so Bun never serviced the socket — every chunk flushed in
  one burst at generation end. Client-side symptoms: "decode 687k
  tok/s", TTFT = full generation time. All prior streaming tests
  passed because they only checked content, never arrival timing.
  Fix: rate-limited macrotask hop (`setImmediate`, ≥25 ms between
  flushes) after sent chunks; per-token hopping cost ~23% decode,
  rate-limited it hides behind the in-flight GPU step. Warm TTFT
  measured at the client: 54 ms (prompt-cached e4b).
- `loadContext` crashed on e4b/26B (SigLIP-format sidecar fed to the
  encoder-free loader) — `serve` on those models had never actually
  been run. Now degrades to text-only with a warning.
- Server-mediated decode on the DIRTY machine read 37–41 tok/s vs ~53
  direct — but runs spread 30.8–41.2 across minutes; the overhead
  number is a cleared-machine question, not tunable in noise. That
  discipline (stop measuring, reboot first) is the preflight's whole
  job.
- **optiq's mixed-KV patch crashes on gemma-4 e4b — upstream optiq
  bug, verified by instrumented repro (`/tmp/repro_optiq_kv.py`).**
  Mechanism (in `optiq/runtime/kv/rotating.py`,
  `_patch_sdpa_for_kv_sharing`): when a KV-sharing layer receives
  tuple K/V with no bits-carrying cache, optiq recovers
  bits/group_size by looking the tuple up in an `id()`-keyed
  producer registry — and on a miss **falls back to a hardcoded
  `QuantizedKVCache(group_size=64, bits=4)` shim**. Only
  `_active_slices` registers producers; the `state` property (the
  path gemma's shared layers read) never does, so the lookup can
  miss. A miss on a 4-bit layer is silently "correct"; a miss on one
  of e4b's six 8-bit layers reads 8-bit packing as 4-bit →
  `quantized_matmul` shape error (w (…,N,64) vs scales (…,N,4)).
  Repro log: `registry MISS → fallback shim bits=4 → MISMATCH
  (contents bits=8) → crash`. Not a bug in
  `RotatingQuantizedKVCache` itself — its storage is
  self-consistent. Upstream fix: register producers in `state` too,
  or infer bits from packed/scales shapes instead of guessing 4.
  Harness now drops a failing cell with `[FAIL]` and finishes the
  matrix (unrecorded cell retried on re-run). For e4b "best" pair
  until optiq is fixed: uniform-bits kv config, or kv=off vs kv=off.
- **Method rules (from prior findings, non-negotiable):** cleared
  machine (no swap from earlier runs); warm second run for prefill
  (cold prefill is page-in-dominated); direct-vs-direct and
  server-vs-server only, never crossed; explicit token ids across
  stacks (TokenizerWrapper adds 3 tokens); Josh starts the Python
  servers (standing ground rule — no servers from agent sessions).
- **Exit criterion**: the full matrix published (README table +
  eval-DB rows with commit shas), including the previously-unmeasured
  numbers: our server-mediated decode overhead and a true
  startup-vs-startup comparison.

## Cross-cutting (standing items)

- **Registry**: per-model LICENSE column (Gemma custom terms vs Qwen
  Apache-2.0 vs MiniCPM Apache-2.0) — still open. ~~bf16 vision-sidecar
  size recorded SEPARATELY~~ done 2026-06-10 (sidecar_bytes column).
- ~~Fit table: the vision sidecar is its own line item~~ done
  2026-06-10 (`fit` prints the sidecar line; never folded into
  language weights). MoE corollary landed with it: experts_bytes
  column + active-expert decode prediction.
- **License headers**: every ported file carries upstream source +
  license (audit item from the docs pass).
- **Bun upgrade gate**: the bun#32054 regression test + the FFI soak
  (tests/ffi-jit.test.ts) must pass on Bun canary before any version
  bump; canary CI is the standing Phase 0 risk control.

## Testing strategy

`bun test` (built-in, Jest-compatible) — no vitest; one toolchain.

- **Unit (fast, every run):** safetensors header parsing, config/quant
  metadata, chat-template formatting, registry queries. Fixture-driven.
- **Golden-file oracle (the real safety net):** a regen script runs the
  Python reference (`/Users/joshrossi/Code/mlx-lm/.venv/bin/python`) and
  dumps goldens. Regenerating goldens is an explicit command, never
  automatic. The parity bar is TIERED (evolved over phases 2–6, replacing
  the original "never bit-exact" assumption, which five phases of
  findings disproved):
  - **(a) Bit-exact `toBe(0)`** single-forward logits from identical
    state: stock decode and kv8 paths. This is achievable and held.
  - **(b) Bounded tolerance** for kv4: ≤1 bf16 ulp at the first
    divergent layer (≤1.0 on softcapped logits) — 4-bit quantized_matmul
    rounds differently for strided-vs-contiguous inputs; cause
    documented in tests/kv-quant.test.ts.
  - **(c) Speculation:** exact equality on tie-free prompts; on
    knife-edge prompts, long-prefix agreement + accept/reject trace
    equality vs the reference (whose own spec path diverges from its
    own incremental loop — proven).
  - **(d) Router/MoE:** bit-exact single-forward logits with explicit
    gate tie-break handling (bf16 knife-edges in routing).
  **Whole-trajectory equality is never the bar**: greedy trajectories
  are loop-shape-sensitive past bf16 ties — proven within mlx-lm
  (pipelined vs unpipelined) and within optiq's own spec path.
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
- ~~Vision sidecar format: confirm optiq_vision.safetensors layout and
  preprocessing.~~ Answered in Phase 4 for the 12B's encoder-free
  unified format (bit-exact vision parity). NOTE: the 26B's sidecar is
  1.07 GB vs the 12B's 105 MB — likely a full SigLIP tower, i.e. the
  Phase 12 format; verify layout when Phase 12 starts.
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
