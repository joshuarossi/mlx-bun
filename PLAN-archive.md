# PLAN archive — completed history (Phases 0–5 and 8–11, Opt Plans A–D, early handoffs)

Moved out of PLAN.md 2026-06-17 to slim the active plan. These are closed; nothing here is an open action item.

## Phase 0 — Feasibility: what does mlx-c expose? `[x]`

The load-bearing question for the whole project.

- [x] Install mlx-c (brew or cmake build); pin the version.
- [x] Inventory the exported C API. Critical symbols:
      `mlx_quantized_matmul`, `mlx_fast_scaled_dot_product_attention`,
      RoPE / RMSNorm fast ops, dtype support (bf16), stream/device handles,
      lazy-eval control (`mlx_eval`), external-buffer array creation.
- [x] Smoke test: `bun:ffi` opens libmlxc, creates two arrays, adds them
      on GPU, reads result back. (`lab/spikes/phase0-smoke.ts` — PASS.)
- [x] Memory-management spike: wrapper class with explicit `.dispose()` +
      `FinalizationRegistry` backstop; confirm no leaks under a tight
      alloc loop (watch wired memory). (`lab/spikes/phase0-memory.ts` — 2000
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
  marshaling. A standalone repro (`lab/repro/bun-ffi-f64/`, confirmed on Bun
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
  (`lab/repro/bun-ffi-f64/ISSUE.md` is the local copy). The arange
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

## Phase 5 — The appliance layer `[x]` (fully closed 2026-06-11 — embeddable build was the last box)

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
- [x] **Memory contracts (`mlx-bun fit`)** (`src/fit.ts`): (a) fit report
      ✓ (weights/kv/transient vs wired ceiling, max safe context solve,
      predicted decode 23.7 vs measured 24.9 tok/s — within 5%);
      (b) SKU matrix ✓ (`fit <query> --skus`); (c) memoryBudget
      enforcement ✓ (DONE 2026-06-10, promoted by the
      uncatchable-GPU-OOM finding): `loadContext(dir, id,
      {memoryBudgetBytes})` refuses models whose weights can't serve any
      context within the budget (pre-GPU, mmap-only); `createServer`
      resolves a max-safe-context admission ceiling via fit (bf16-KV
      conservative) and rejects over-budget requests with 400
      `memory_admission` BEFORE generation — rejection is the ONLY
      defense, the OOM is uncatchable; mlx allocator capped via
      mlx_set_memory_limit when a budget is set (defense in depth, not
      the defense). `--memory-budget GB` on serve.ts + `mlx-bun serve`;
      ceiling observable at /stats.admission; integration-tested
      (tight-budget server: over-budget 400 + in-budget 200; sub-weights
      budget refuses to load/serve).
- [x] Downloader (DONE 2026-06-10): resumable HF fetch with checksums
      (`src/download.ts`, `mlx-bun get <org/repo>`). Plain HTTPS
      resolve/CDN (no Xet), Range-resume of partial blobs with
      re-hash-on-resume, EVERY blob verified (sha256 vs LFS oid; git
      blob sha1 vs blobId for small files; mismatch deletes the
      partial), writes the exact huggingface_hub cache layout
      (blobs + depth-aware relative snapshot symlinks + refs) so
      registry/loaders need zero changes, auth header STRIPPED at the
      CDN redirect (presigned URLs reject it). Mock-server integration
      tests (tests/download.test.ts — resume/corruption/idempotence/
      auth-stripping, no network); real-API contract smoke-verified on
      hf-internal-testing/tiny-random-gpt2. Sequential by design
      (resumability over parallelism). Pairs with the Phase 8 deferred
      adapter-by-repo-id mount when that lands.
- [x] **Embeddable build** (DONE 2026-06-11): `./scripts/build-binary.sh`
      → relocatable dist/ bundle (61 MB binary + libmlxc/libmlx/libjaccl
      dylibs + 150 MB mlx.metallib). dylib resolution (src/mlx/ffi.ts):
      MLX_BUN_LIBMLXC env → beside-executable (sidecar) → brew.
      install_name_tool fixups: libmlxc → @loader_path/libmlx;
      libmlx +@loader_path rpath (its @rpath/libjaccl reference was the
      one non-obvious break — brew rpath is @loader_path/../lib);
      ad-hoc re-sign after rewrite (arm64 requirement). VERIFIED: lsof
      shows all four bundle files loaded from dist/ (not brew), GPU
      generation + /v1/messages served from the compiled binary
      (ready 254 ms), first-run weights via the embedded downloader.
      docs/reference/embedding.md: sidecar pattern (Tauri/Electron), signing/
      notarization recipe incl. the Bun allow-jit entitlement
      requirement under hardened runtime.
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

## NEXT UP (updated 2026-06-10 evening — THE HANDOFF BLOCK)

> **⚠️ ARCHIVED HANDOFF (2026-06-10 / 06-11) — superseded.** Live status
> is in [STATUS.md](STATUS.md). The three blocks below (NEXT UP /
> NEXT SESSION PICKUP / SESSION SWEEP) are kept verbatim for history.

State: all three Gemma-4 targets at tier-a/d bit-exact parity
(including every quantized-KV config, post rope-freqs fix); Phases 4,
8, 10 done; Phase 5 fully closed (admission control + downloader);
docs synced (README + docs/reference/server-api.md). The repo's durable state is
THIS FILE + the findings sections; trust rows in the eval DB over
numbers quoted in old findings.

**Standing directive (Josh, 2026-06-10): build first, benchmark when
the project is good.** All throughput questions (the @8k decode gap
re-baseline, the two fused-path A/Bs, purge-cold rows) batch into ONE
cleared-machine ./benchmark.sh pass later; don't block engine work on
them. Memory measurements stay fine to take in-session.

### NEXT SESSION PICKUP (written 2026-06-10 night, pre-reboot)

Josh reboots and runs `./benchmark.sh --redo` on the M4 Pro (the
--redo is REQUIRED: at 17:48 a plain run re-rendered the morning's
stale rows as "results" because of the resume window). The script now
also appends the two fused-path A/Bs after the matrix. When the
results exist, the session work is:

1. **Read** the new `benchmarks-h2h-<date>-<host>.md` + eval-DB rows
   (`bun src/cli.ts evals`, or query `~/.cache/mlx-bun/evals.sqlite`).
   This is the FIRST clean-machine measurement of the
   post-rope-fix/Phase-9/10 engine — even short-ctx numbers may move.
   Sanity rules: every @8k row must show ctx≈8000 in its notes (the
   new context guard fails cells into the footer otherwise); any
   stack whose @8k decode equals its short-ctx decode is broken, not
   fast.
2. ~~Settle the fused-flag defaults~~ **SETTLED 2026-06-11** from the
   appended A/B rows: fused prefill confirmed ≈neutral tok/s (234.7
   vs 232.4) with lower generation peak (10.35 vs 10.68 GB) → stays
   default-on. Fused decode read 0.959 (paired-median-of-3, eval rows
   258/259; the dirty-paired read was 0.885 — same direction).
   **DECISION (Josh, 2026-06-11): the MLX_BUN_FUSED_DECODE flag and
   its gate test STAY — documented escape hatch, default off. The
   pre-committed "delete if <1.0" rule is VOID and the policy
   generalizes: a losing-but-working, parity-tested experiment is
   kept as a default-off documented flag, never deleted on one
   measurement** — other models/regimes (MTP, Qwen, other silicon)
   may want it. Caveat for the record: rows 256–259 ran at the end
   of the matrix with machine_state ok:false (~700 MB accumulated
   swap) — paired ratios only, absolutes not quotable.
3. **Update README Benchmarks** (the table carries a provenance
   footnote about the invalidated @8k rows — replace with the clean
   corrected numbers) and mark Phase 15's remaining boxes.
4. ~~Continue the decode-gap investigation~~ **RESOLVED 2026-06-11**
   via exactly the "cheaper first" lever (per-step wall-time split,
   both stacks): the gap was a prefill→decode allocator-reclaim
   boundary stall that mlx-lm bills to prompt_time and clears with
   mx.clear_cache — not kernels, not the pipeline, not donation.
   Fixed reference-faithfully in generate.ts; 12B now ≥ python at
   @600 and at parity @8k (paired). Full story: "Decode gap
   RESOLVED" findings block. e4b's −5% steady-state host-graph-build
   residual stays open (Phase 7 lever: mlx_compile).
5. If the M1 Max reruns: `git pull` there FIRST (its matrix ran
   6cb4a35, pre-rope-fix), then `./benchmark.sh --redo`.

~~Open after that, in order: purge-cold rows, Phase 11, embeddable
build.~~ ALL CLOSED 2026-06-11 except the Josh-gated rows — see the
SESSION SWEEP block below. Background chip resolved: server `stop`
tests run in the default suite (tests/server.test.ts, 17 pass,
verified 2026-06-11).

### SESSION SWEEP (2026-06-11) — what's done, what's Josh-gated

Done this session (each has its own findings/commit): corrected-matrix
README refresh; decode gap ROOT-CAUSED AND FIXED (12B now ≥ python
paired — see "Decode gap RESOLVED"); Phase 11 closed (Anthropic
/v1/messages + Responses API with previous_response_id, real-SDK exit
criteria); Phase 5 closed (embeddable single-binary bundle, verified
end-to-end); docs pass closed (library-api.md + embedding.md);
registry license column. Suite 157/157 at every commit.

**Everything still open needs Josh physically:**
1. **Reboot + `./benchmark.sh --redo`** — quotable clean-machine rows
   for the post-decode-fix engine (expect the 12B decode gap GONE and
   short-ctx AHEAD; the in-session paired numbers say +4.6% @600,
   parity @8k). Add `sudo purge` for the Phase 15 purge-cold rows
   while rebooted.
2. **M1 Max**: `git pull` then `./benchmark.sh --redo` (still on
   pre-rope-fix 6cb4a35).
3. ~~Claude Code live smoke~~ **DROPPED (2026-06-12, Josh)**: the
   /v1/messages surface was already dogfooded through pi instead;
   Josh isn't going to point Claude Code at the local model. The
   protocol legs stay SDK-verified — no further smoke needed.
4. **Phase 14 (Qwen)**: medium-term, targeted ~Mon 2026-06-15. Pick +
   download the first Qwen 3.x quant (2B/4B class) — multi-GB
   download, your call. This also unlocks MTP and is a consumer of
   the kept fused-decode flag.
5. **Phase 12 (SigLIP)**: your hold — only if needed.
6. **Phase 13 (TurboQuant)**: PROMOTED (2026-06-12, Josh) — see the
   Phase 13 header; it's now the most interesting research direction
   and ties into docs/planning/PRODUCT_ROADMAP.md artifact design.

**Direction debate → DECIDED (2026-06-12): direction (A) first.** Josh
picked the pi built-in track; see Phase 16 below and
docs/archive/investigations/pi-builtin-investigation.md (investigation + P1–P4 plan +
first-run starter model). Lucien (B) stays queued. Original framing:

- **(A) DX/UX**: built-in web chat UI (pi-SDK-based, tool calls
  working, served as another page from the same executable) + an
  investigation into bundling/embedding pi (`mlx-bun pi` drops you
  into a pi agent session on the local model — embed via SDK, reuse
  its TUI components, or shell out to the executable; genuinely
  unknown, scope the options first).
- **(B) Lucien on local models**: run the Lucien/Dreaming pipeline on
  mlx-bun-served models, measure quality + perf per pipeline task
  (synthesis, article writing, recall), and investigate mlx-bun as a
  packaged Lucien backend — single executable that creates the memory
  store, ingests sessions, synthesizes articles, and serves chat
  grounded on them.

Kernel work stays available but Josh is benchmarking-fatigued; the
clean-machine ./benchmark.sh pass (perf-kernel default decision) still
gates the MLX_BUN_PERF_KERNEL flip whenever it happens.

Agent-side next when work resumes: Phase 7 research track — the
decode-split profiling already identified the lever (per-step host
graph-build, ~2–4 ms serial; e4b's −5%): prototype mlx_compile via
mlx_closure to move decode-graph construction into C++.

Remaining work, in priority order:

0. ~~Phase 9 — rotating KV-quant~~ DONE same evening (tier-a bit-exact
   mechanics + past-window e2e; KV 365→194/103 MB at saturation; see
   Phase 9 findings). **NEXT: Phase 11 — Anthropic /v1/messages
   (Josh's Claude Code backend; oracle optiq/anthropic_shim.py) +
   Responses API**, then the embeddable build. Server `stop`
   sequences: DONE 2026-06-10 (see Phase 4 follow-up note).

1. ~~12B long-context decode gap~~ **CLOSED 2026-06-11.** History:
   "−10% @8k" was first a broken-baseline artifact (ctx=31 harness
   bug), then a real-but-misattributed −4.5% @8k (clean matrix), and
   finally root-caused as a prefill→decode allocator-reclaim
   boundary stall + a prompt/decode clock-accounting asymmetry vs
   mlx-lm. Fixed in generate.ts (clear_cache placement + clock swap,
   all mirroring mlx-lm). Post-fix paired: @600 25.1 vs 24.0 (ours
   FASTER), @8k 23.8 vs 23.9 (parity). See "Decode gap RESOLVED"
   findings. Remaining: quotable cleared-machine rows (next
   benchmark pass) + e4b's −5% host-graph-build residual (Phase 7).
2. **Phase 15 closeout** — purge-cold rows: deferred into the same
   benchmark pass (needs reboot + `sudo purge`). Footer fix done
   2026-06-10.
3. **Phase 5**: CLOSED 2026-06-10 (admission control, downloader; see
   phase section). Remaining adjacent work: embeddable build
   (single-binary), library API reference (docs pass).
4. After Phase 9: Phase 11 (Anthropic messages + Responses),
   12 (SigLIP), 14 (Qwen). Server `stop` sequences: DONE
   2026-06-10.


## Documentation pass `[x]` (started 2026-06-10, closed 2026-06-11 with the library API reference)

- [x] README rewritten: requirements, CLI, HTTP API, library usage,
      correctness story, measured numbers, license pointers.
- [x] THIRD_PARTY_LICENSES.md: linked libs (MLX/mlx-c, MIT), ported code
      (mlx-lm MIT; mlx-vlm BSD-3; mlx-optiq MIT; Pillow resample
      algorithm), npm deps (tokenizers Apache-2.0, jinja MIT,
      fast-png MIT), model-license caveat. LICENSE file added (MIT).
- [x] API reference for the library surface (DONE 2026-06-11,
      hand-written): docs/reference/library-api.md — generate()/Generation/
      GenerateOptions/GenerateStats (incl. the mlx-lm-matching clock
      semantics), serving pieces, PromptCache, kv-store persistence,
      Registry+fit, LoRA, and the memory/disposal rules (uncatchable
      OOM, read.* rule). docs/reference/embedding.md covers the single-binary
      sidecar story (bundle, resolution order, signing/notarization
      incl. allow-jit).
- [x] Per-file header audit (2026-06-10): every PORTED file carries its
      upstream source in the header (sampler, tool-call, gemma4 incl.
      fused SDPA, ops, spec/*, vision/*, prompt-cache, lora, generate,
      config, registry, tokenizer — verified by grep). Files without
      headers are original code (cli, evaldb, fit, kv-store, mmap,
      preflight, safetensors, download, mlx bindings, chat-template —
      which renders upstream's own template by design). server.ts got a
      behavioral-reference note (mlx-lm server.py, no code ported).
      THIRD_PARTY_LICENSES.md stays the canonical license inventory.
- [x] Server API doc (2026-06-10): docs/reference/server-api.md — full
      request/response schemas incl. tool_calls, vision parts, SSE
      grammar, admission errors, /stats, /v1/adapters; pi models.json
      walkthrough. Found en route: the README claimed `stop` sequence
      support that does not exist — claim removed; implementing `stop`
      (with streaming hold-back) spun off as a follow-up task.
- [x] Server `stop` sequences (2026-06-10, follow-up from the doc
      audit above): OpenAI `stop` (string | string[]) on
      /v1/chat/completions. Matched on DECODED text (StopMatcher in
      server.ts) — current mlx-lm matches token-id sequences via a
      state machine and misses matches that span token boundaries or
      tokenize differently in context; ours catches both. Streaming
      holds back any tail that is a prefix of a stop sequence until
      disambiguated, so no part of a stop sequence is ever streamed;
      content excludes the sequence; finish_reason "stop". Enabling
      change: Generation/generateInner (src/generate.ts) now support
      early termination — a consumer `break` forces .return() through
      the scope wrappers, disposes in-flight arrays, and STILL returns
      stats (return-in-finally), so usage accounting and
      PromptCache.put(cacheTokens) survive an early stop (forwarded
      tokens' KV really is in the cache). Tests: 6 StopMatcher unit +
      3 e2e in tests/server.test.ts; full suite 118 pass.

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

## Phase 9 — Rotating-cache KV quantization `[x]` (2026-06-10; tok/s rows → benchmark pass)

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

- [x] Read `optiq/runtime/kv/rotating.py` (oracle) AND its SDPA
      dispatch patch BEFORE estimating — done 2026-06-10, map below.
- [x] Port `RotatingQuantizedKVCache` (DONE 2026-06-10, src/model/
      gemma4.ts): RotatingKVCache ring mechanics over (packed, scales,
      biases) triples — `_update_concat` (temporal-order →
      trim-to-window → concat) and `_update_in_place` (step-grow to
      max_size, wrap `_idx` to `keep`, slice-assign the quantized
      incoming S tokens), `_trim`/`_temporal_order` via per-component
      ops. Storage convention identical to our QuantizedKVCache;
      returns ACTIVE QUANTIZED SLICES.
- [x] `RotatingKVCache.toQuantized(group, bits)` replay (quantize the
      whole buffer incl. ring layout, copy offset/_idx; replay-from-
      WRAPPED-ring unit-tested) + generate.ts conversion: uniform
      `kvBits` mode covers rotating caches; `kvConfig` mode follows the
      file (shipped kv_config.json files list full-attention layers
      only — uniform mode is where rotating-quant engages today).
- [x] Attention dispatch: one `instanceof RotatingQuantizedKVCache`
      added to the quant branch — donor AND sharer paths were already
      generic (SharedKv carries groupSize/bits, as the oracle map
      predicted).
- [x] Trim/rollback semantics: inherited ring rule (trimmable only
      before wrap), same as bf16 rotating.
- [x] Memory measured @1536 ctx (rings saturated), 12B, all layers:
      **total KV 365→194 MB (kv8, 0.53×) / 365→103 MB (kv4, 0.28×)**;
      the sliding portion (335 MB — 92% of the 12B's KV) was the
      previously-unquantizable term. fit-table quantized-KV term left
      conservative-bf16 by design. 8k/32k + tok/s rows folded into the
      Phase 15 benchmark pass (cleared-machine matrix).
- **Parity contract → MET, tier a everywhere**: (1) class-level ring
  mechanics BIT-EXACT vs optiq's RotatingQuantizedKVCache at every
  checkpoint of a scripted sequence covering first-prefill, decode
  growth, ring wrap, prefill-concat OVER a wrapped ring, post-wrap
  decode (triples + offset/_idx compared bitwise); (2) 12B end-to-end
  single-forward logits over a PAST-WINDOW 1536-token prompt with ALL
  48 layers quantized: kv8 AND kv4 both toBe(0) vs python
  (patch_rotating_to_quantized + fused install), greedy continuations
  long-prefix aligned. tests/rotating-kvq.test.ts (mechanics + replay
  fast tier; e2e opt-in `MLX_BUN_TEST_ROTKVQ=1`, run alone — another
  12B instance on top of the default suite OOM-kills it, same policy
  as the 26B suite); goldens: scripts/regen-rotating-kvq-goldens.ts.
- **Exit criterion**: serving footprint shrink measured and tier-a
  parity shipped (above). tok/s and larger-context rows fold into the
  benchmark pass.

### Phase 9 findings (2026-06-10, port session)

- **The oracle map held exactly**: the port was the cache class + one
  instanceof; bit-exact vs python on the first full run (mechanics AND
  past-window e2e). No registry, no SDPA patch, no dispatch surgery —
  carrying groupSize/bits in SharedKv (a Phase 6 design choice) is
  what made optiq's three patch layers unnecessary.
- **Scenario-faithful fused dispatch needed one refinement**: optiq's
  fused wrapper falls back to unfused on EVERY array mask, so
  sliding-layer quantized prefill (window masks) is UNFUSED in the
  reference. Our gate now tiles only masks flagged `causalEquivalent`
  (windowless continuations — where mlx-lm would have said "causal");
  window/bidir arrays stay unfused. Without this the past-window e2e
  could not have been bit-exact.
- **A second 12B instance OOM-kills the default suite** (exit 137 —
  the Phase 6 multi-model ceiling, now measured as a hard kill rather
  than slow paging). Weights-loaded additions to the suite must either
  reuse an existing resident model's test file or go opt-in/run-alone.
- kv-store persistence of QUANTIZED caches (rotating or not) was
  already unsupported (`unknown cache type`) — pre-existing gap, now
  explicitly noted; pair it with the kv-store format rev if quantized
  prefix persistence is ever needed.

### Phase 9 oracle map (read 2026-06-10, pre-port)

- **The oracle's hardest machinery does not apply to us.** optiq needs
  an `id()`-keyed producer registry + a patched
  scaled_dot_product_attention because python KV-shared layers receive
  K/V tuples with `cache=None` and lose bits/group_size (and its
  fallback-to-kv4 shim is the upstream bug we root-caused in Phase 15,
  crashing e4b's 8-bit layers). Our SharedKv already carries
  `{kind: "quant", groupSize, bits}` through the donor→sharer plumbing
  explicitly — the registry, the SDPA patch, and the
  re-import-fixup loop all evaporate. The port is the CACHE CLASS plus
  a one-line instanceof in Attention.forward.
- **The module docstring lies about its own design** ("update_and_fetch
  returns dequantized fp16/bf16 tensors so the standard SDPA path runs
  unmodified") — the CODE returns quantized tuples from
  `_active_slices` and routes through quantized SDPA. Same lesson as
  Phase 0's "will be copied" doc comment: port from the
  implementation, never the docstring.
- RotatingQuantizedKVCache subclasses RotatingKVCache: make_mask /
  is_trimmable / trim inherit; only the storage-shape-sensitive
  methods are overridden (tree_map over the triple). `keep=0` for
  gemma4, `step=256`, defaults group 64 / bits 4.
- `to_quantized` on a quantized rotating cache returns self
  (idempotent); on a bf16 one it REPLAYS (quantize full buffer,
  preserve offset + _idx) — wrap-state is quantized in ring order, not
  temporal order, which is correct because _idx is preserved with it.
- Our fused tiled prefill applies as-is: rotating-quantized prefill
  masks are 2-d bool window arrays (already eligible) and decode stays
  on the stock path.
- Oracle-harness hazard: optiq's e4b mixed-KV registry-miss bug means
  regen scripts must use the 12B (or uniform bits) — do not exercise
  e4b 8-bit sliding layers through optiq's shared path until upstream
  fixes the shim.

## Phase 10 — fused_quant_sdpa N-tiled FlashAttention prefill `[x]` (2026-06-10)

Needed for long-prefill-over-quantized-cache (continuations past
`quantizedKvStart`, prompt-cache reuse on quantized entries).

- [x] Port the FlashAttention-2 N-tiled loop (`quantizedSdpaTiled` in
      src/model/gemma4.ts; oracle `optiq/runtime/fused_quant_sdpa.py`,
      op-level, composition order preserved; N_CHUNK 512 like the
      reference).
- [x] Wired as the L>1-over-quantized-cache path (`quantizedSdpa`
      dispatch); decode (L=1) and unsupported configs stay on the stock
      unfused port. `MLX_BUN_NO_FUSED_SDPA=1` escape hatch (mirror of
      optiq's `--no-fused-kv`). Documented dispatch deviation: the
      oracle WRAPPER falls back on array masks because mlx-lm hands it
      "causal" even at offset>0; our makeMask materializes the
      equivalent bool matrix, and the tiled loop slices 2-d bool masks
      per column exactly like the oracle's inner function — so array
      masks tile too (vision bidir masks included).
- **Parity → MET, tier a**: (1) direct-call tiled BIT-EXACT vs the
  oracle's `_prefill_flashattn_n_tiled` (3 golden cases incl. multi-tile
  + continuation; goldens/fused-sdpa.*, regen
  scripts/regen-fused-sdpa-goldens.ts); (2) end-to-end kv8 AND kv4
  single-forward logits BIT-EXACT vs the fused python reference, 26B
  kvmix likewise (tolerances tightened to toBe(0) — see findings).
  Tiled-vs-unfused is tier b BY DESIGN (online softmax ≠ one-shot
  precise softmax in bf16; measured ≤ 0.0015 on unit-scale outputs,
  tests/fused-sdpa.test.ts).
- **Exit criterion → MET**: 2048-chunk prefill over an 8k kv8 cache
  (12B): generation-only peak 10.81 GB fused vs 11.15 GB unfused
  (−336 MB transient), prefill tok/s at parity; eval-DB rows recorded
  (scripts/bench-fused-prefill.ts, fused=on/off). The saving grows with
  context — unfused scores are O(L·N), per-tile O(L·512).

### Phase 10 findings (2026-06-10)

- **The port itself was bit-exact on the first run** — direct calls,
  strided cache-view pedigree, and the real in-model first call all
  compared toBe(0) against the oracle. The end-to-end divergence the
  wiring exposed was NOT in the tiled code: bisection (per-layer
  residual dump → first divergent layer 11 → stage-by-stage attention
  dump) landed on q-rope.
- **ROOT CAUSE: ProportionalRoPE freqs must be computed ON-DEVICE in
  f32.** rope_utils.ProportionalRoPE builds freqs as
  `mx.arange(0, rotated, 2, f32) / dims` then `base ** x` (f32 powf on
  GPU); we computed them host-side in f64 `Math.pow` and cast — 17 of
  64 rotated freqs land 1 f32 ulp off. Bit-exactness through Phases
  2–8 was VALUE LUCK: bf16 rope outputs masked the ulp until Phase
  10's tiled values tripped a knife edge at layer 11 (q_roped 1 ulp →
  0.5 on softcapped logits 37 layers later). Fixed by building freqs
  with mx ops mirroring the reference implementation (gemma4.ts
  Attention constructor; `factor` now parsed from rope config too).
  Phase-2 porting rule, new corollary: it applies to CONSTANTS built
  at load time, not just forward-pass ops.
- **kv4's documented 1-ulp tolerance no longer reproduces.** With
  corrected freqs and goldens regenerated against the fused reference,
  kv4 single-forward and the 26B kvmix forward are BIT-EXACT — the old
  "strided-vs-contiguous quantized_matmul rounding" attribution was
  plausibly the freqs bug all along. tests/kv-quant.test.ts and
  tests/parity-26b.test.ts tightened to toBe(0).
- **Quantized-KV goldens now regenerate against the FUSED reference**
  (optiq serve installs fused_quant_sdpa whenever kv-quant is enabled,
  so the serving oracle for quantized-cache prefill is
  optiq-with-fused; our L>1 dispatch matches it). Trajectory legs use
  fused prefill + stock decode, mirroring our dispatch. fp16 legs came
  out byte-identical across the regen — the new harness reproduces the
  Phase-6 ad-hoc generation exactly. The kvq goldens previously had NO
  producer script (committed ad hoc in 6c37246);
  scripts/regen-kvq-goldens.ts closes that gap.
- **specGenerate emitted the EOS token into its content array** — a
  faithful port of optiq's runtime.py, which yields EOS as a stream
  EVENT; our generate() never yields EOS. Invisible until the rope fix
  shifted e4b outputs to hit EOS inside the spec test's 80-token
  window. spec `tokens` now excludes EOS (stats.emitted still counts
  it, reference-faithful). The spec exact-equality prompt was
  re-picked: tie-free is a property of the VALUES, and the old prompt
  now trips the documented verify-rounding knife edge at token 27
  (same flip at the same position for every γ — the reference-matching
  class, not an accept/reject bug).
- Decode (L=1) over quantized caches stays unfused per plan; optiq
  tiles decode too (its wrapper has no L gate). Whether tiling decode
  closes the remaining ~3% kv-mixed decode tax @8k is a
  cleared-machine question — the next benchmark.sh run should A/B
  `MLX_BUN_NO_FUSED_SDPA` and an L=1-tiled experiment.
- **L=1-tiled decode experiment built + directionally measured (same
  day)**: `MLX_BUN_FUSED_DECODE=1` tiles decode like optiq's wrapper
  (off by default); L=1/mask-None golden bit-exact vs the oracle.
  Paired in-process A/B @8k kv8 (scripts/bench-fused-decode.ts,
  interleaved, median of 3): tiled/stock ratio 0.885 with one pair
  above 1.0 — neutral-to-NEGATIVE, dirty-machine directional only.
  Consistent with the dispatch-cost concern (~16 tiles × 8 ops × 8
  layers of extra op dispatches per token from JS). Decode default
  stays stock. RESOLVED 2026-06-11: clean paired A/B read 0.959 —
  flag KEPT as a documented default-off escape hatch (Josh's call;
  see the SETTLED note in the pickup block — no deletion).
- Verified after the changes: full suite 99/99 (incl. 12 new
  fused-sdpa tests), opt-in 26B parity 2/2.

## Phase 11 — Protocol surfaces: Responses API + Anthropic messages `[x]` (2026-06-11)

Two more protocols beyond chat-completions. Both are plumbing over the
existing generation/tool/vision surfaces — no new engine work.

**Anthropic `/v1/messages`** (added 2026-06-10 — Josh: this is what
Claude Code needs as a local backend; verified that optiq ships it
ON BY DEFAULT in `optiq serve` (`--anthropic/--no-anthropic`,
default True), so the drop-in claim requires it, upgrading it from
Phase 4's "shim later if needed"):

- [x] Protocol translation, both directions + streaming (DONE
      2026-06-11, `src/anthropic.ts` + `/v1/messages` route).
      Oracle: `optiq/anthropic_shim.py` — ported at the request layer
      as planned: anthropic body → ChatRequest → the SAME handleChat
      core (extracted from the chat-completions route; generation,
      tools, vision, stops, admission live exactly once) → response/
      SSE translated back. Event grammar is the oracle's exactly
      (message_start → content_block_start/delta/stop →
      message_delta → message_stop). Documented upgrades over the
      oracle (it inlines tools as Qwen-style text, "out of scope for
      v1"; emits "[image omitted]"): tool_use/tool_result map to our
      NATIVE gemma tool calling (streamed tool_use blocks with
      input_json_delta), image blocks (base64 + url sources) map to
      our vision parts, usage is real final-chunk counts (their
      chunk-count guess is the fallback) + cache_read_input_tokens
      from the prompt cache, prior-turn thinking blocks dropped on
      re-ingest instead of json.dumps'd.
- [x] On by default like the reference; exercised in the integration
      suite (tests/server-tools.test.ts: non-streaming, streaming
      grammar + reassembly, tool_use emission, tool_result round-trip
      against the live 12B, anthropic-shaped errors; unit grammar
      tests in tests/anthropic.test.ts). 138/138 suite.
      Josh-side check: dropped 2026-06-12 — dogfooded via pi instead;
      Claude Code won't be used against the local model.

**OpenAI Responses** (`previous_response_id` resumption):

- [x] `/v1/responses` create/stream (DONE 2026-06-11,
      `src/responses.ts` + route): same handleChat-core architecture
      as the Anthropic surface. Full oracle event chain
      (response.created/in_progress → output_item.added →
      content_part.added → output_text.delta/.done → … →
      response.completed; function_call_arguments.delta/.done for
      tools); instructions + system/developer items merge into ONE
      leading system message (Codex sends both — oracle finding);
      flat→nested tool translation, built-ins dropped. Deltas vs
      oracle (documented in-file): real final-chunk usage incl.
      cached_tokens; previous_response_id echoed.
- [x] Response store: `ResponseStore` port (TTL 1 h + 32 MiB
      byte-capped LRU); previous_response_id splices prior
      input+output back in, instructions carry forward when omitted,
      unknown id → 404; streamed responses are stored too
      (finalResponse capture) so they chain. Observable at
      /stats.response_store. Pairs with PromptCache prefix reuse as
      planned (the resumed prefix re-renders identically → KV cache
      hit).
- **Exit criterion → MET (2026-06-11), both halves with REAL SDKs**
  (devDeps, tests/server-tools.test.ts): (a) the `openai` npm SDK
  completed a multi-turn RESUMED conversation + a streamed leg
  against the live server (store + /stats asserted); (b) the
  `@anthropic-ai/sdk` client completed a multi-turn STREAMED
  conversation WITH tool use (tool_use → tool_result round-trip,
  grounded answer). Suite 157/157. The planned Claude Code live smoke
  was dropped 2026-06-12 — Josh dogfooded the surface through pi
  instead and won't use Claude Code against the local model.
  docs/reference/server-api.md documents both surfaces.


## Optimization plan Phase A — compiled decode `[x]` (2026-06-10/11)

(See docs/design/optimization_plan.md for the full plan; Phases B–E follow.)

**What landed:** the single-token decode step replays through
`mlx_compile` instead of being rebuilt per token over bun:ffi.
`src/mlx/compile.ts` wraps a JSCallback-traced `mlx_closure` (trace runs
ONCE per ndim/dtype signature; shapeless=true replays across the growing
KV dims). `src/model/compiled-decode.ts` traces the UNMODIFIED
`Gemma4Model.forwardHidden` against cache adapters that subclass the
real cache classes, so the compiled graph is the production op sequence
by construction. Per-step integers cross as ARRAY inputs
(`mlx_fast_rope_dynamic`, `mlx_slice_update_dynamic`) — no baked
constants, no per-step retrace (verified: a per-closure trace counter
flags any retrace; 300-token runs across growth boundaries, ring
transitions, kv conversion and sampler paths = exactly the expected
trace count, zero unexpected).

**Two execution forms, chosen by model architecture:**
- *Segmented* (dense: 12B-class): rotating caches at steady state write
  in-graph at a dynamic ring position and the graph reads the full
  updated buffer (bit-exact by construction, donation verified by
  pointer stability); growing caches (full-attention; rings pre-window)
  put their LAYER outside the compiled graph — today's exact view-based
  ops between compiled segments. At 8k that's 42 compiled layers in 7
  segments + 6 JS layers.
- *Whole-graph* (KV-sharing/per-layer-input: e4b-class): everything in
  one closure; growing caches fetch via in-graph concat (same values as
  write-then-slice) with the write immediately outside. The concat
  MATERIALIZES the active window per step — measured cost ≈ per-op
  encode overhead + 2× window bytes + allocator churn; this is why
  dense models get the segmented form, and why e4b's win shrinks with
  context. Folding e4b into segmented form needs SharedKv plumbing
  across segment boundaries — deferred to the Phase C generator.

**Parity gate (the invariant): GREEN.** Compiled vs uncompiled is
bit-exact — full logit vectors and greedy trajectories — on 12B across
bf16/quantized × growing/ring cache configs and on e4b incl. KV-sharing
+ mixed kv_config (tests/compiled-decode.test.ts). Three trace-time op
substitutions were needed (values identical, asserted): subrange Slice →
DynamicSlice in the per-layer-input split, the MoE top-k, and the tiled
SDPA's tile slices — mlx's Slice lacks `output_shapes`, which shapeless
replay needs.

**Measured (paired in-process A/B, dirty machine — ratios only;
scripts/decode-split.ts --ab):**
- e4b: **+5.2% @600** (49.9→52.5 tok/s), +4.3% @2k, +2.9% @4k, ~0% @8k.
  The Phase-7 "e4b −5% residual" is closed at short/mid context.
- 12B: ~0% @600 (pre-window: segmented degenerates to ~uncompiled by
  design — no regression, no churn), +0–1% @8k (t_graph 3.2→0.8 ms;
  ~0.5 ms residual dispatch cost unattributed).
- 26B (MoE): falls back to uncompiled — upstream mlx 0.6.0 GatherQMM has
  no `output_shapes`, and shapeless replay re-infers the whole tape when
  any input dim changes. Lift when upstream implements it.
- Honest premise check: the 12B is GPU-bound (t_graph was only 4–8% of
  step wall), so compile is NOT a 14×-class lever here; the per-model
  headroom table (control, scripts/decode-split.ts): 12B 1.54 ms/4.0%
  @600, 3.42 ms/7.8% @8k; e4b 2.55 ms/12.9%; 26B 2.23 ms/12.4%.

**Fused-decode A/B re-run on top of compile (plan step 7): REFUTED.**
MLX_BUN_FUSED_DECODE tiled/stock = **0.921** @8k kv8, both arms
compiled (scripts/bench-fused-decode.ts) — the tile loop's L=1 cost is
GPU-side, not host overhead. Flag stays default-off; the win belongs to
Phase E's real fused kernel.

**Defaults/flags:** compiled decode is DEFAULT ON
(`MLX_BUN_COMPILED_DECODE=0` to disable / A-B); LoRA generations and MoE
models fall back automatically; any unsupported state falls back
per-generation (warn once, closure key blacklisted).
`MLX_BUN_COMPILE_MODE` escape hatch exists in compile.ts (no_fuse —
measured: fusion is NOT the cost, no_fuse is strictly worse).

**Crash found while gating (worth knowing):** the full 27-file suite in
one bun process dies DETERMINISTICALLY in `mlx::core::gpu::check_error`
→ `std::terminate` (the documented-uncatchable async Metal error, Phase
6) under cumulative residency — the failure lands asynchronously ~147
tests in (during tokenizer tests, dispatched by earlier GPU work), with
zero output because bun test buffers its report until exit. Per-file and
half-suite runs pass with headroom. Resolution: `bun run test` →
scripts/test.sh runs the suite as two sequential shards (two processes);
new heavy tests also dispose their weights (Weights.dispose), compiled
closures and the allocator cache in afterAll — keep doing both in future
model-heavy test files. Locating tool that worked: `bun test --preload`
with a beforeEach that appendFileSync's a trace line (survives the
crash).

## Optimization plan Phase B — base extraction `[x]` (2026-06-11)

src/model/gemma4-base.ts now holds the config-independent machinery
(cache classes, quantized SDPA + masks, quantized primitives + LoRA,
graph helpers) — moved VERBATIM (sed line-range extraction; only
`export` keywords added to previously module-local symbols).
gemma4.ts keeps the architecture-specific assembly (Attention, MLP,
MoE, DecoderLayer, Gemma4Model) and re-exports the base so importers
keep one entry point. No behavior change; full suite green (170 pass).

## Optimization plan Phase C — generated per-model files `[x]` (2026-06-11)

scripts/gen-model.ts reads config.json + kv_config.json (+ the shard
index, for layer_scalar presence) and emits a branch-resolved, unrolled
forward pass: per-layer helpers transcribed op-for-op from
DecoderLayer.forward + Attention.forward with the model's constants
baked (cache class per layer, donor/sharer wiring, k_eq_v, MoE,
per-layer-input, layer_scalar), plus an unrolled forwardLayers override
on a Gemma4Model subclass. Dispatch by config fingerprint
(src/model/fingerprint.ts → factory.ts, wired into the server); a
per-call cache-signature guard falls back to the monolith for anything
the file wasn't generated for (bf16 compat, vision bidir) — nothing
deleted, nothing ever broken. Three outputs registered:
gemma4-12b / e4b / 26b (src/model/generated/).

- **Parity: bit-exact for all three** vs the monolith under the shipped
  kv_config serve scenario (tests/generated-parity.test.ts for 12B+e4b;
  the 26B by standalone probe — its 16 GB load stays out of the suite).
  The generator caught two facts a hand-port would have missed: the
  12B kv_config quantizes ALL 48 layers (sliding included), and these
  checkpoints carry layer_scalar.
- **Measured (paired, kv_config @2k, uncompiled): generated/mono =
  0.994 — perf-neutral**, exactly the plan's honest expectation ("the
  large one was compile"); Phase C's value is the codegen base for
  Phases D–E and maintainability.
- Interplay with compiled decode: e4b-class whole-graph closures trace
  THROUGH the generated forwardLayers (cleaner graph); dense segmented
  decode uses CompiledDecode's own layer-wise path, so the generated
  override serves prefill + uncompiled decode there. Emitting per-model
  segmented step code from the generator is the natural Phase D/E
  follow-on (also the route to segmenting e4b past its concat-copy
  cost).
- **Bug fix found by the dual-model parity setup:** Router's
  constructor disposed the Weights-OWNED cached `.scale` tensor — any
  second model built over the same Weights got a dead handle (latent
  for registry reloads). weights.tensor() results are never disposed by
  callers now.

## Optimization plan Phase D — kv_config constant folding `[x]` (2026-06-11)

gen-model.ts now folds each layer's kv_config (bits, group_size) into
the generated SDPA dispatch as LITERALS, pre-resolves the static half of
fusedSdpaSupported at generation time (runtime half split out as
base.fusedSdpaRuntimeOk — combined predicate unchanged), and records
(bits, group_size, nRep, head_dim) at every dispatch site. The 12B's
actual site mix: sliding 4-bit nRep=2 d=256, sliding 8-bit nRep=2
d=256, full 4-bit nRep=16 d=512 (richer than the plan's worked
example — some SLIDING layers are 8-bit).

Parity: bit-exact, all three models. Measured (paired, kv_config @2k):
generated/mono = **0.998 — neutral**, exactly the plan's prediction;
per its own framing this is the finding that compile already captured
the host-side cost and **Phase E's fused kernel is the only remaining
lever**. Every dispatch site now has a single known
(bits, group_size, nRep, head_dim) — E's precondition met.


---

# Sections moved verbatim from STATUS.md (2026-07-01 docs truth pass)

Point-in-time session summaries for work that is DONE or superseded. Moved here
so STATUS.md stays a current-state front door. Nothing below is an open action.

## DiffusionGemma port — D1–D3 + D5 DONE 2026-06-24. COMPLETE (D4 perf = Josh-gated bench).

**THE WHOLE PORT IS DONE.** DiffusionGemma-26B-A4B-it (first non-autoregressive model) runs in
mlx-bun: bit-exact forward, token-for-token denoising (both samplers), text + image serving
(parity-exact, live), and LoRA fine-tuning. Plan + dossier: docs/design/diffusion-gemma-port.md.
- **D1** static forward: BIT-EXACT vs optiq (`tests/diffusion-parity.test.ts`). [[diffusion-gemma-router-norm-no-fold]]
- **D2** denoising engine, BOTH samplers: TOKEN-FOR-TOKEN (`tests/diffusion-gen-parity.test.ts`). [[diffusion-gemma-d2-oracle-rng-parity]]
- **D3** serving: CLI + OpenAI/Anthropic + streaming (text) AND image-text-to-text via a DEDICATED
  vision tower (`src/vision/diffusion-vision.ts`) — token-for-token + served live
  (`tests/diffusion-{serving,vision}.test.ts`). [[diffusion-gemma-vision-dedicated-tower]]
- **D5** diffusion-LoRA: `src/train/diffusion-lora.ts` — the denoising-objective trains end-to-end
  (loss 3.9→1.2), MoE backward via stop_gradient'd routing indices, adapter changes output
  (`tests/diffusion-lora.test.ts`). [[diffusion-gemma-lora-denoising]]
- **D4 (perf)** is the only open item — optional/measured; quotable tok/s needs a clean-machine
  `benchmark.sh` (Josh-gated, preflight). The confidence-threshold path is already the fast one.
- Typecheck baseline held at 117 throughout (zero new errors); AR models unregressed
  (instanceof-guarded branches). Goldens regen: `scripts/gen-diffusion-{golden,gen-golden,vision-golden}.py`.

### (historical) DiffusionGemma port — D1 + D2 + D3 DONE; D4/D5 next

**D3 IMAGE-TEXT-TO-TEXT COMPLETE — token-for-token parity, served live.** A DEDICATED vision
tower (`src/vision/diffusion-vision.ts`, `DiffusionVisionTower`) — its OWN module (the user was
right: e4b and the 26B-diffusion are SEPARATE models with SEPARATE towers; e4b uses a bf16
sidecar, diffusion's vision is inline-quantized). Parity-exact op-for-op port of optiq's gemma4
`VisionModel` at the diffusion geometry (hidden 1152, head_dim 72, 27 layers, standardize). Wired
through the encoder vision merge + bidirectional overlay → denoising engine; preprocess + splice
build the prompt; server `handleChat` gets a diffusion vision lane. **Verified:**
`tests/diffusion-vision.test.ts` (spliced ids EXACT + token-for-token "This is a solid gray
square." on grad-768) AND served live via the OpenAI vision API.
- **3 vision bugs (per-stage diffing): (1)** input_proj is QUANTIZED → the reference's
  `patches.astype(weight.dtype)` is a uint32 truncation of the patches (a trained-in quirk; e4b's
  bf16 input_proj never hit it). **(2)** head_dim 72 → `ensure_fused_sdpa` pads to 80 + slices.
  **(3)** down_proj is plain bf16 (a quantized-or-plain `VisionLinear`). Residual ~2.3% feature
  relRMSE = 27-layer bf16 accumulation (e4b-class), robust → identical tokens. [[diffusion-gemma-vision-dedicated-tower]]
- **NEXT — D4 (perf, optional) + D5 (diffusion-LoRA).** D5: port optiq's denoising-objective
  `train_diffusion_lora` (the `loraTargets` map already exists on the model). D4: measure tok/s
  with benchmark.sh.

### (historical) DiffusionGemma port — D1 + D2 + D3(text) DONE 2026-06-24; image next

**D3 TEXT serving COMPLETE — verified live on a running server.** `createModel` returns
`DiffusionGemmaModel` (in the `RuntimeModel` union with AR-only methods as throwing stubs +
real `loraState`/`loraTargets`/`makeCache` — baseline held at 117 errors, zero new). `generate()`
detects it and routes to the denoising engine (`generateDiffusionInner`), same
`Generation`/`GenerateStats` contract → CLI + server stream it for free; gateway keeps it serial.
**Verified:** `mlx-bun generate diffusiongemma "…"` (coherent haiku) AND `mlx-bun serve
diffusiongemma` answering OpenAI chat (stream + non-stream), Anthropic `/v1/messages`,
`/v1/models`, single+multi-block ("…is Paris.", primary colors). Gate:
`tests/diffusion-serving.test.ts` (4/4). No AR regression (instanceof-guarded).
- Files touched: `src/model/factory.ts` (union + dispatch), `src/model/diffusion-gemma.ts`
  (AR stubs + loraTargets), `src/generate.ts` (diffusion branch + `generateDiffusionInner`),
  `src/eval/runner.ts` (bypass bit-exact fast path), `src/serve/generation-gateway.ts`
  (serial-only guard).
- **Streaming:** v1 yields tokens after the engine completes (SSE emits as deltas); true
  per-block intra-stream + temperature>0 (categorical) are follow-ups.
- **NEXT — D3 image-text-to-text** (the remaining v1-scope item): wire the 27-layer SigLIP
  tower into the diffusion encoder. Needs: `<|image|>`→`boi+image_token*N+eoi` splice +
  `mm_token_type_ids`; encoder vision merge (`_embed_inputs` masked_scatter +
  `_vision_block_overlay` bidirectional overlay in `_make_encoder_masks`); SigLIP weight-name
  adaptation (diffusion uses `.linear` suffix + `patch_embedder`); image-text-to-text golden.
  Then D4 (perf, optional) + D5 (diffusion-LoRA, the `loraTargets` map already exists).

### (historical) DiffusionGemma port — D1 + D2 DONE 2026-06-24, D3 next

**D2 (denoising engine) COMPLETE — token-for-token parity vs the optiq engine.**
`src/diffusion/diffusion-generate.ts` (`diffusionGenerate`): prefill→cache reuse, linear
temp schedule, un-mask loop, BOTH samplers (confidence-threshold = OptiQ public default;
entropy-bound = engine default), self-conditioning feedback, EOS/stop, block loop. At temp 0
on a fixed seed, both samplers match optiq exactly: confidence 17 tok/7 steps, entropy
15 tok/48 steps (`tests/diffusion-gen-parity.test.ts`; golden `scripts/gen-diffusion-gen-golden.py`).
- **RNG parity solved:** bound `mlx_random_randint`+`mlx_random_seed`+`mlx_cummax` (and
  `logicalNot`/`equal`/`all`/`anyAxis`/`lessEqual`/`itemBool`) in `src/mlx/{ffi,ops}.ts`.
  `ops.randint(key=null)` threads the GLOBAL mlx key → seed + same-order calls reproduce every
  draw bit-for-bit (verified 0/256 mismatch). The denoising loop calls randint once for init +
  once per non-final re-noise step.
- **3 bugs fixed:** (1) `processed = logits / schedT` must be a real DIVISION (not ×reciprocal)
  — 1-ULP shift flips the hard 0.9 confidence cutoff → trajectory diverges. (2) stability history
  needs an independent copy (add-zero), not a reshape/view (aliases freed buffer → false stable).
  (3) **the as-loaded oracle has `generation_config=None`** → `stable_and_confident` is a NO-OP
  (entropy runs all 48) and eos = tokenizer's `{1,106}` (NOT the 50 in generation_config.json).
  L2 = match the oracle as it RUNS → stable-stop OFF unless explicitly configured. [[diffusion-gemma-d2-oracle-rng-parity]]
- **NEXT — D3 (serving + CLI + image):** route diffusion_gemma into generate.ts/cli.ts/server.ts
  (its own non-AR lane in the gateway — currently `createModel` throws "wired in D3"); decide
  streaming semantics (per-block, not left-to-right); image input via the 27-layer SigLIP tower
  (`parseSiglipConfig`, present in checkpoint); add `DiffusionGemmaModel` to the runtime union
  (give it the gateway-facing surface so it doesn't break the 96 AR script-callers — likely a
  separate lane/interface, not the AR `forward`). Also: temperature>0 (categorical) sampling.

### (historical) DiffusionGemma port — D1 DONE 2026-06-24 (BIT-EXACT), D2 next

**D1 (single-forward parity) COMPLETE — BIT-EXACT vs mlx-optiq.** `src/model/diffusion-gemma.ts`
(`DiffusionGemmaModel`): one full forward over the real 14 GB checkpoint — encoder prefill →
bidirectional decoder canvas pass (`_make_decoder_masks`) → parallel dense-MLP + 128-expert
top-8 MoE (fused gate_up SwitchLinear) → SelfConditioning → tied 4-bit head → fp32 softcap —
matches the optiq golden **bit-for-bit**: argmax 256/256, maxDiff 0.0, relRMSE 0.0, meanKL 0.0
(`tests/diffusion-parity.test.ts`, `MLX_BUN_TEST_DIFFUSION=1`; golden via `scripts/gen-diffusion-golden.py`).
Every per-stage sub-gate (enc/dec hidden, presoftcap, per-layer, layer-0 attn/dense/MoE) is 0.0.
- **The single bug (per-model gotcha worth remembering):** the Router pre-projection norm must be
  the literal **two-step** `rms_norm(x, None, eps) * scale * hidden**-0.5`, NOT gemma4's **folded**
  `rms_norm(x, scale*hidden**-0.5)`. The fold changes bf16 intermediate rounding → routing weights
  drift ~0.01 → 1.7% MoE error → 12.7% by encoder output (argmax mostly survived, hiding it).
  Localized by copy-verbatim per-component diffing (attn/dense were already 0.0; only MoE diverged).
- **Architecture confirmed in TS:** attn scale=1.0 no-softcap, QK/V-norm pre-RoPE (v_norm no-scale,
  no RoPE on V), full layers reuse k as v + partial-rotary 0.25, plain RMSNorm (no Gemma +1), encoder
  layer_scalars separate from decoder's, all decoder masks None for short prompts (the risky
  `_make_decoder_masks` sliding-window path only fires past 1023 ctx — D2 concern).
- **Factory:** `createModel` detects diffusion_gemma and throws "wired in D3" (serving lane is D3);
  the AR `RuntimeModel` union is deliberately NOT widened (would break 96 script-callers that assume
  `.forward`/`.forwardHidden`). D1/D2 drive `DiffusionGemmaModel` directly.
- **NEXT — D2 (denoising engine):** `src/diffusion/` canvas init (uniform-random ids — needs
  `randint`, currently missing → randomUniform+cast), linear temp schedule, the un-mask loop,
  confidence-threshold (OptiQ default) + entropy-bound (model default) samplers (entropy needs
  `cummax`, missing), self-conditioning feedback (the `_embed_canvas` soft-embedding path is already
  ported + the quantized transpose=false matmul), stability/EOS. Gate: token-for-token vs optiq
  `generate()` on a fixed seed. The static-graph forward it builds on is now bit-exact.

### (historical) DiffusionGemma port — STARTED 2026-06-24 (Phase D0 done, D1 next)

Porting **DiffusionGemma-26B-A4B-it** (`diffusiongemma-26B-A4B-it-OptiQ-4bit`, ~14 GB,
`model_type diffusion_gemma`) — the first **non-autoregressive** model: fills a fixed
256-token canvas and un-masks it over ≤48 denoising steps. Goal: **L2 parity with
mlx-optiq** (stock mlx-lm/mlx-vlm CAN'T load it → **optiq IS the oracle**, no L1 ancestor).
**Plan + full D0 reference dossier: [docs/design/diffusion-gemma-port.md](docs/design/diffusion-gemma-port.md).**
- **Oracle env moved: `mlx-optiq` 0.2.1 → 0.2.7** in `/Users/joshrossi/Code/mlx-lm/.venv`
  (diffusion decoder needs ≥0.2.3). `mlx`/`mlx-lm`/`mlx-metal` UNCHANGED (0.31.2/0.31.3)
  → existing Gemma/CPM/Qwen oracles unaffected. Reference src:
  `optiq/vlm/_mlxvlm/models/diffusion_gemma/` + `optiq/vlm/_mlxvlm/generate/diffusion.py`;
  public API `optiq.vlm.diffusion_gemma.{load→(model,tokenizer), generate}`.
- **D0 recon DONE** (dossier appended to the design doc). Headlines: NO Canon/conv tensors
  (pure transformer); TIED head (`embed_tokens.as_linear()`); hidden 2816 / 30 layers /
  16 heads; **parallel dense-MLP + 128-expert MoE** per layer (7 norms + `layer_scalar`);
  attention **scale=1.0, QK/V-norm pre-RoPE, NO attn softcap** (only final logit softcap
  30.0 fp32); sliding hd256/kv8 + full(5,11,17,23,29) hd512/kv2 partial-rotary 0.25;
  canvas init = **uniform-random ids** (no mask token); bidirectional decoder masks
  (`_make_decoder_masks`) = the crux. `randint`/`cummax` look ABSENT in src/mlx/ops.ts
  (engine-level, D2 — not a D1 blocker).
- **Scope (confirmed w/ Josh):** text + image TOGETHER in v1; **D5 diffusion-LoRA IN scope**.
- **D1 (single-forward parity) IN PROGRESS** — weights-independent pieces DONE + verified:
  - **Config + detection DONE & VERIFIED on the real config.json** (no weights needed).
    `config.json` ships ONLY token ids + `canvas_length` + the quant map — all arch dims come
    from optiq `config.py` TextConfig defaults. `loadModelConfig` now backfills them for
    `diffusion_gemma` (`diffusionGemmaRawDefaults()` in `src/config.ts`, snake_case so the
    generic parser + `parseRope` pick them up; +optional `TextConfig.canvasLength`). Parsed
    output checks out: hidden 2816/30L/16H, kv 8 (sliding)/2 (full), hd 256/512, moe 704,
    128 experts top-8, sliding_window 1024, softcap 30, layer_types [slide×5,full]×5 last-full,
    rope sliding(default,1e4)/full(proportional,0.25,1e6), eos [1,106], quant map resolves
    (q_proj 8b / experts+embed 4b). `isDiffusionGemmaConfig` + supported-gates wired
    (`src/model/support.ts`).
  - **Golden harness written** (`scripts/gen-diffusion-golden.py`, compiles; verified optiq
    `load()→(model,tokenizer)` + `Model.__call__(input_ids,canvas_ids,…)` signatures). Dumps
    module-tree + full-forward logits — runs when shards land.
  - **Building-blocks API mapped** (Explore agent): every reusable piece exists — `Attention`,
    `Router`, `Experts`/`SwitchGLU`, `QuantizedSwitchLinear`, `QuantizedEmbedding.asLinear`
    (tied head), `SiglipVisionTower`; `ops.{rmsNorm,rope,sdpa,gatherQmm,quantizedMatmul,
    argpartitionAxis,takeAlongAxis,softmaxAxis,geluApprox,where,clip}`. Missing (D2 engine
    only): `randint` (use randomUniform+cast) + `cummax`. Model contract: `(weights,config)`
    ctor + `makeCache()` + `forward(tokens,cache)→logits`.
  - **NEXT (needs weights / next focused step):** write `src/model/diffusion-gemma.ts`
    (DecoderLayer = parallel dense-MLP+MoE w/ 7 norms+layer_scalar; attn scale=1.0 no-softcap,
    QK/V-norm pre-RoPE, full layers k=v + partial-rotary 0.25; SelfConditioning; bidirectional
    `_make_decoder_masks`; tied quantized head) + wire `factory.ts` → run harness for goldens →
    per-component sub-gates → full-forward gate. Weights still downloading (one shard as of
    2026-06-24).


## MiniCPM5 decode megakernel — SHELVED for M=1 (2026-06-24), research only

The entire CPM5 decode forward in ONE resident Metal dispatch
(`src/model/megakernel-kernel.ts`, `MegakernelRunner`), multi-threadgroup + software
grid-barrier. **DECISION (Josh): do not ship it; keep using the mlx-ops path.** It is
NOT wired into production (generate/server/cli/minicpm5 never reference it — Phase 5
never done); the live decode path is unaffected.
- **Why shelved — MEASURED, decisive (`megakernel-perf.ts` + NOBAR ablation):** vs the
  pure weight-read floor (~4.5ms), **mlx per-op = 4.62ms (~0.12ms overhead — near optimal)**;
  megakernel = 5.41ms (with barriers) and **4.95ms even with barriers no-op'd** — STILL
  slower. So it's NOT a bandwidth wall: mlx is already near the floor. The megakernel
  replaces Apple's *cheap hardware dispatch sync* with *expensive software grid-barriers
  (0.46ms) + atomic cross-threadgroup activation coherence (0.33ms)* — structurally heavier
  for M=1. There is no M=1 trick that wins (even zero-barrier loses on the atomic tax).
- **Where a megakernel COULD win (if revisited): M=K** (speculative-verify / batch) — the
  coordination overhead is FIXED per forward, so amortized over K tokens it drops below
  mlx's per-token cost while the dominant weight read is shared. qmv→steel-qmm.
- **Banked learnings (the value):** mlx `qmv_fast` GEMV port (8-bit bit-exact; 4-bit 1-ULP
  = compiler-level, not source), the software grid-barrier, generated-kernel codegen, L2
  quant-KV (93/100 KL-gated), and the **copy-verbatim methodology** + the measured
  coordination-overhead finding. See [[megakernel-qmv-port-win]],
  [[megakernel-copy-verbatim-methodology]].
- **THE win this session:** ported mlx's `qmv_fast` decode GEMV verbatim
  (load_vector pre-scale + mask-only qdot + 4-rows/simdgroup register reuse) →
  0.70→0.94×. Naive-GEMV bits/K-literal templating REGRESSED (register bloat → lower
  occupancy); the kernel is occupancy/bandwidth-bound, not branch-bound.
- **Correctness:** 97/100 teacher-forced, KL 9.7e-4, deterministic, no NaN (3 argmax
  near-ties; passes the perf-kernel-oracle-style KL bar, 1 under the strict 98 line).
- Built but perf-neutral (kept behind flags): generated layer-unrolled kernel
  (`MLX_BUN_MEGAKERNEL_GEN=1`, constants baked — confirms bandwidth-bound), RMSNorm-
  local + SwiGLU barrier folds (~194→145 barriers/tok).
- **Phase 4 — L2 quantized KV: increment 1 DONE, increment 2a is NEXT.**
  - Validated mlx's `affine_quantize` formula vs `ops.quantize` (bf16 ULP) —
    `scripts/experiments/kv-quant-formula-check.ts`.
  - Increment 1 (in-kernel quantize→dequant round-trip after rope, per-layer KVBITS
    literal in the generated kernel; `MLX_BUN_MEGAKERNEL_KVQUANT=1`,
    `kv-quant`→`megakernel-kv-teacherforced.ts`): **93/100, KL 1.49e-2, deterministic,
    no NaN** vs the optiq mixed-KV golden. Quant formula correct; the ~gap is a known
    storage-precision artifact — increment-1 stores `bf16(scale·q+bias)` (one extra
    bf16 rounding), but optiq's `quantizedMatmulQT` dequants K/V to **f32 on-the-fly**.
  - **Increment 2a DONE + DIAGNOSED: L2 PASSES the L3-class gate** (93/100, KL 1.38e-2,
    deterministic, no NaN; `MLX_BUN_MEGAKERNEL_KVQUANT=1`). Stores int q (exact in bf16) +
    bf16 scale/bias side buffer; `attend_simd_q<KVBITS>` dequants to f32 on read.
    Fixed a cross-threadgroup **coherence bug** (current-pos scale/bias → atomic `d_sb`;
    78→93). **Root cause of 93-not-97 FOUND (decisive, vs our bit-exact reference):** the
    megakernel's `qmv4` GEMV differs from mlx's `quantized_matmul` by **~1 bf16 ULP** (==
    L1's 9.7e-4 residual; confirmed `megakernel-kv-cmpl1.ts`: 425/1536 K elems >1 ULP), and
    **quantization is DISCONTINUOUS** so that 1-ULP K shift flips a q-level/group boundary →
    full quant-step dequant error (`cmpkv.ts`: 0.166) → amplified to 1.38e-2. NOT a bug —
    93/100 is the L2 ceiling exactly as 97/100 is L1's; bit-exact L2 would need a bit-exact
    GEMV (defeats qmv4). Gate is KL+agreement (L3 class), not the bit-exact golden.
  - **Increment 2b (deferred):** bit-pack q → uint32 for the actual 4-bit memory win
    (same logits as 2a).
  - Then **Phase 5** (wire into decodeStep/generate.ts, CLI flag, CI gate).

## Current work — Steel flash-CCE ORPO head + the ORPO training stack (2026-06-19)

Porting MLX's `steel` quantized GEMM verbatim into the flash-CCE ORPO head + fusing
the ORPO epilogue, wiring the whole new system end to end. **SHIPPED in v0.0.5**
(merged PR #16; `npm i mlx-bun` / `brew install joshuarossi/tap/mlx-bun`). **Forward +
backward: BOTH done + live + fast + `[M,V]`-free.**
- **Forward** ✅ steel GEMM + softcap + online-softmax → logp; default in
  `flashCceForward`; 180 ms; parity PASS e4b/cpm.
- **Backward** ✅ **IN PRODUCTION** (`BWD_STEEL_SOURCE`/`bwdSteelKernel`, H-tiled
  persistent accumulator + vocab-blocking + atomic dh; phase-2 W dequant via MLX's fused
  `QuantizedBlockLoader`). Parity PASS e4b (dh 0.40%) + cpm (0.28%); **754 ms = 5× the
  old SG's 3687 ms** (exact); peak **0.928 GB flat @ M=8192**. `MLX_BUN_CCE_BWD_NOSTEEL=1`
  fallback.
- **Prefix-sharing** ✅ wired into the trainer (`orpoPrefixShared`), composed with the
  flash head per branch (matches whole-vocab to 0.018%). **Composes with the segmented
  backward for BOTH MiniCPM5 (`SegmentedBackwardOrpoPrefix`) AND e4b
  (`SegmentedBackwardOrpoPrefixGemma4` — donor-KV + logical-position sliding-window prefix
  mask threaded through segments)** — grads 1.7–2.3% bf16-class, peak 30–39% lower.
- **Integration tests** ✅ `tests/train-orpo-fused-ce.test.ts` (`MLX_BUN_TEST_TRAIN=1`,
  6 pass): flash / segmented+flash / prefix+flash / **segmented+prefix+flash** all train
  CPM5 end-to-end, loss decreases. e4b parity: `prefix-shared-segmented-parity-e4b.ts`.
- **CLI verb** ✅ `mlx-bun train <model> --data <dir>` (src/cli.ts) — foreground, full ORPO
  stack on by default, auto-detects e4b/Gemma + sets its env, `--method/--save-every/--resume/
  --dry-run/--no-flash/--no-prefix/--no-segment`, streams loss + saves a mountable adapter.
  Drives the **same** `finetuneRunner` the server uses (in-process here; subprocess+GPU-lease
  there). Smoke-verified on CPM5 (3 steps, flash + prefix + seg). `mlx-bun help train` for flags.
- **Preconfigured launcher** ✅ `scripts/train-orpo.ts` — the same stack via env vars (scripting),
  auto-detects e4b (sets its env flags), per-row fallback + logging. **Measured e4b @ 8192
  full stack (prompt-dominant): 13.3 GB, ~70 s/step** (prefix-share makes it lighter AND
  faster than segmented+flash alone). See [docs/reference/orpo-quickstart.md](docs/reference/orpo-quickstart.md).

- **e4b @ 8192** ✅ **PROBED + FITS**: segmented+flash, SEG=2 → peak **16.14 GB** (~16 GB
  headroom on 32 GB), loss finite + decreasing — the historical "e4b OOMs ≥2048" ceiling
  is BROKEN. Footprint linear in seq (~+1.5 GB/1024 tok). Validated overnight config +
  the full SEQ→peak table are in the handoff doc.

- **Warm-start** ✅ `warmStartFromAdapter` (lora-params) + `RESUME=<dir>` on the launcher:
  continue a run from a checkpoint's LoRA weights (optimizer + LR schedule restart). Insurance
  for long runs that get interrupted.
- **Segmented head-sink UAF fixed** ✅ the segmented ORPO classes freed the flash head's
  `headSink` (lse/blockMax/CustomVjp) *before* the lazy CustomVjp backward read it →
  use-after-free segfault ~step 100. Fix: `ops.evalAll` the head-VJP roots before the dispose,
  in all four ORPO segmented classes.
- **Adapters live in the cache** ✅ launcher defaults `ADAPTER` to
  `~/.cache/mlx-bun/mlx-bun-finetunes/orpo-<model>` (never the repo; `adapters/` gitignored).
- **Eval loop (IFEval + UltraFeedback)** — the optiq capability suite is ported
  (`src/eval/`, datasets exported to `~/.cache/mlx-bun/eval-data/`). Dress-rehearsal result,
  reported honestly: an 800-step CPM5 ORPO run on UltraFeedback moved **IFEval 22.5% → 22.5%**
  (flat — general preference data + tiny run is the wrong lever for IFEval; the val loss did
  drop, so it learned). The real before/after is the **chunk segmenter** scored by boundary/label
  accuracy vs the Opus/GPT-5.5 gold — see [[training-tracks-are-appliance-components]].

**Remaining / next:**
- **CPM5 UltraFeedback run** — dress-rehearsal, PAUSED at ~step 4820 (val 1.66 → ~1.50 plateau,
  as expected for open-ended UF; checkpoints every 200 in `./adapters/cpm5-uf-8h/checkpoints/`,
  best-val ~`step-04200`). Resumable via `RESUME=<ckpt>`. NOTE: a session-spawned background run
  got **reaped by the agent runtime at ~47 min** (not a crash/OOM — confirmed via logs + `pmset`);
  long runs MUST be launched detached from the user's OWN shell (`nohup … &`), not by the agent.
- **The chunk segmenter** (THE load-bearing run): distill Opus/GPT-5.5 conversation-segmentation
  into a local model (data: `~/Code/lucien/.../chunk-v3/dpo/orpo-curated-*.fixed.jsonl`), scored by
  **boundary/label accuracy vs gold (chunk-eval), NOT val loss** — this localizes the Lucien
  synthesis pipeline's `chunk-recent` stage. See [[training-tracks-are-appliance-components]].
- **The e4b overnight** — `scripts/train-orpo.ts` full stack at 8192 (Josh runs it — ground rule).
- Perf follow-up: the optional lossless `MLX_BUN_CCE_BWD_BLOCK_EPS=1e-5` vocab-block skip on real
  long text.

**→ Quickstart + perf table: [docs/reference/orpo-quickstart.md](docs/reference/orpo-quickstart.md).
Training-flag reference: [docs/reference/training.md](docs/reference/training.md). Full plan +
gotchas + glossary: [docs/archive/investigations/steel-flash-cce-handoff.md](docs/archive/investigations/steel-flash-cce-handoff.md).**

## Vision — SigLIP sidecar lights up e4b image input (2026-06-17, merged to `main`)

Phase 12 (SigLIP vision tower) BUILT + validated for **gemma-4-e4b**. e4b now
answers image questions end-to-end (grounded descriptions). The 16-layer SigLIP
encoder is ported from `optiq/vlm/gemma4/` in **`src/vision/siglip.ts`**
(`SiglipVisionTower`): patchify → input_proj + 2D pos-embedding → 16× transformer
blocks (clippable linears with the trained finite clip bounds, manual-f32 q/k/v
RMS norms, on-device 2D RoPE, fused SDPA scale=1.0, GeGLU) → 3×3 avg-pool →
MultimodalEmbedder → /embed_scale. Single images run **unpadded** (numerically
identical to optiq's padded+masked path, verified, but far cheaper).

**Two gaps closed to make it work:**
1. `Gemma4Model.forwardEmbeddings` used to **throw** for per-layer-input models
   (e2b/e4b). Now threads the spliced ids (image positions zeroed) into the
   per-layer-input path — matches optiq's `zeroed = where(text_mask, ids, 0)`.
2. Tower selection + **lazy loading**: `vision_config.model_type` picks SigLIP
   (`gemma4_vision`: e2b/e4b/26B/31B) vs the encoder-free tower
   (`gemma4_unified_vision`: 12B). The tower loads on the **first image
   request**, not at server start (`getVisionTower`/`makeVisionLoader` in
   `server.ts`) — text-only sessions never pay for it.

**Works across the fidelity tree.** Vision prefill always falls back to the
**monolith** adapter (`forwardEmbeddings` → `forwardLayers`; the per-model
generated adapter returns `super.forwardLayers` when `bidir !== null`), so it's
adapter-agnostic. Decode flows through the chosen KV path: verified end-to-end on
**L1** (mlx-lm bf16) AND **L2** (optiq mixed-precision quantized-KV — the default
`mlx-bun serve`, monolith `quantizedSdpaUnfused` for the bidir prefill, generated
fused decode), both grounded (`tests/e4b-vision.test.ts`, 3/3). L3 perf flags
(`FUSED_GELU`/`PERF_KERNEL`/`FUSED_DECODE`) don't change the greedy. The vision
ENCODER (bf16, no KV cache) is the same across all three paths — its SDPA
divergence (below) is orthogonal to the KV-path choice.

**Parity (PLAN Phase 12 bar = tier-a ids + greedy prefix): MET.** Spliced prompt
ids bit-exact (256 soft tokens); pre-transformer features bit-exact (0.003%);
**ONE encoder layer on bit-exact input is bit-exact (0.0007%)**; greedy prefix
matches; output grounded. Full 16-layer features land at **~1.0-1.2% rel-RMSE**
vs optiq. **EVERY primitive is bit-identical** between mlx-bun's libmlx and the
oracle's mlx-metal on this machine — verified model-free
(`scripts/op-parity-{dump.py,check.ts}`): rms_norm, gelu, matmul, clip, cos, sin,
full multidim RoPE, sdpa (no-mask AND array-mask), sdpa padded-vs-unpadded
(no-op), pool (f32 matmul == optiq einsum). So there is **NO kernel / cross-build
divergence** (an earlier "fast-SDPA dispatch boundary" claim was a bug in the
op-test: `toFloat32` mis-read a non-contiguous SDPA output — must
`ops.contiguous()` before raw readback). The residual is a **sub-bf16
(≈0.0007%/layer) composition non-associativity that accumulates and is amplified
by the encoder's design**: scale=1.0 on RMS-normed q/k → q·k ~N(0, head_dim) →
sharply peaked softmax, so tiny roundings flip attention weights and, downstream,
greedy argmaxes (~0.17% of it is the patchify input: JS `pixel/127.5-1` vs
optiq's two-step f32 `2*(pixel/255-0.5)`). Toggling the LM flags
(`FUSED_GELU`/`PERF_KERNEL`/`NO_FUSED_SDPA`/`FUSED_DECODE`) did NOT change the
greedy. So the test asserts ids + greedy-prefix + grounded output, not full
bit-exact greedy.
**TODO(revisit):** full bit-exact vision IS achievable (it's the bar for the
rest of the codebase, 0.0000% on the text models) — match optiq's EXACT
op/lazy-eval/fusion ordering in the full graph, readable straight from
`optiq/vlm/gemma4/{vision,merge}.py`. Primitives already match bit-for-bit; only
the full-graph composition order remains. Left at tier-a for now (good enough). Gate: `tests/e4b-vision.test.ts` (golden
`goldens/e4b-vision.json` ← `scripts/gen-e4b-vision-golden.py`). 12B encoder-free
path unregressed (`tests/vision.test.ts` 4/4). **Not done:** audio tower (the
sidecar also carries `audio_tower.*`/`embed_audio.*`); 26B/31B SigLIP (same
tower, untested); image preprocessing on **resize** paths stays PIL-impure.

## Training — segmented backward, Phase A + Phase B BOTH COMPLETE (merged to `main`, PRs #9–11)

Long-context LoRA SFT that streams the backward segment-by-segment so only one
segment's activations are live — fits where the optiq/mlx-lm reference spikes/crashes.
**Phase A (MiniCPM5) done + validated + quality-confirmed** (PR #9): bit-exact grads vs the
full backward (relNorm 0.0000% under flash), peak **10.91 → 3.29 GB @2048** (non-seg
spikes to 21–26 GB @4096; seg stays 6–8 GB), **no memory leak**. Real 300-iter run:
peak **6.51 GB** (baseline 25.47 GB), `chunk-eval` **95.10/100** — EXCEEDS the
non-segmented baseline (91.70). **Phase B (e4b) COMPLETE + merged** (PRs #10–11):
`SegmentedBackwardGemma4` (`src/train/segmented.ts`, wired into the trainer) —
forward bit-exact, grads bit-exact for single-consumer donor reuse / ~1% bf16-class
(bf16 non-associativity, grouping-controllable) for the multi-consumer donor-KV sum.
**Trains all 42 layers at 8K (17.5 GB) where `mlx_lm.lora --grad-checkpoint` OOMs
training the same (verified: mlx-lm fits 8K only by dropping to its default 16
trainable layers, 25.7 GB).** At 2K/4K both train all 42; segmented ~15-25% lower
(seg 11.0/16.1 vs mlx-lm 12.8/20.9 GB). No leak; adapter saves. NOTE the earlier
"reference crashes at 4K / ~70 GB" claim was WRONG — it used mlx-bun's OWN
checkpoint (ineffective, 23 GB @2048) as the baseline, not mlx-lm's. **Handoff
report (start here): [docs/archive/investigations/segmented-backward-handoff.md](docs/archive/investigations/segmented-backward-handoff.md)**
— current state, validated numbers, how to run/train an adapter. Deep dossier:
docs/design/segmented-backward-training.md §9 (MiniCPM5) / §10 (e4b). Enable via `TrainConfig.segmentSize` (layers
per segment; 0 = off). Key files: `src/train/segmented.ts` (`SegmentedBackward`),
`src/model/minicpm5.ts` (`runLayerRange`), `src/mlx/autograd.ts` (`Vjp` — the
backward uses `mlx_vjp`, NOT a surrogate-loss `value_and_grad`, which leaked).
Two findings worth knowing: (a) `ops.sdpa`'s fused-eager forward ≠ its autograd
forward in bf16 (~0.12%) — use `MLX_BUN_TRAIN_ATTN=flash` for exact segmented grads;
(b) mlx `eval` doesn't detach, so boundaries are copied to leaves (`fromBytesCopy`).
Full dossier: [docs/design/segmented-backward-training.md](docs/design/segmented-backward-training.md) §9–10.

## Phase 14 bring-up — Qwen3.6-27B-OptiQ-4bit (merged; 27B confirmation Josh-gated)

> **Phase 14 bring-up — BOTH PARITY BARS PASS (2026-06-15, M1 Max).** Target
> family = **hybrid gated-DeltaNet** arch (`model_type qwen3_5`): every 4th layer
> full-attention + the rest linear-attention (Mamba-like), dense MLP. Verified
> end-to-end on **Qwen3.5-4B-OptiQ-4bit** (~4.5 GB, tied head): per-step logits
> bit-exact + greedy identical vs **mlx-lm** (bf16 KV) AND vs **mlx-optiq**
> (mixed-precision per-layer KV). The whole graph — gated-DeltaNet recurrence,
> gated full-attention, tied head, mixed-KV — is correct on real weights.
> Remaining: confirm the **27B** both bars (~15 GB, same arch, untied + Hv=48 —
> lower risk now) + 14f polish (fit/registry columns, chat-template/eos smoke).
>
> **Done + verified (model-free, no 15 GB load):**
> - Config/scaffolding (`config.ts`, `support.ts`, `factory.ts`) — validated on
>   the real config.json; model detected + supported.
> - New primitives: `mlx_conv1d` binding + depthwise `ops.conv1d`, `ops.split`,
>   `ops.softplus`, `ops.silu`. The gated-DeltaNet Metal kernel + `compute_g`
>   (`src/model/qwen3-delta.ts`) — **BIT-EXACT vs mlx-lm** at the real head
>   geometry (`tests/qwen-delta.test.ts`); conv1d **bit-exact**
>   (`tests/qwen-ops.test.ts`).
> - Model graph (`src/model/qwen3_5.ts`): typechecks; **static weight-name
>   audit clean (0 missing / 0 unused)**.
> - Parity harness READY: `scripts/regen-qwen-parity-goldens.ts` (bf16 + mixed)
>   + `tests/qwen-parity.test.ts` (opt-in `MLX_BUN_TEST_QWEN35=1`).
>
> Also supports the lighter same-arch **Qwen3.5-4B-8bit** (32 layers, tied head,
> no kv_config) — tied embeddings implemented; config + weight-name audit clean.
> It's the cheap first end-to-end check (bf16 bar only).
>
> **Next action:**
> 1. ✅ DONE — 4B both bars green (`MLX_BUN_TEST_QWEN35_4B=1`).
> 2. Optional confirmation — 27B both bars (~15 GB):
>    `bun scripts/regen-qwen-parity-goldens.ts 27b` then
>    `MLX_BUN_TEST_QWEN35=1 bun test tests/qwen-parity.test.ts`.
> 3. Commit the branch (Josh-gated); 14f polish (fit/registry, chat-template/eos).
>
> **Deferred** (orthogonal to the parity bars; sidecars not downloaded):
> MTP speculation (`mtp.safetensors`), Qwen3-VL vision, 35B-A3B MoE. See PLAN
> Phase 14 bring-up for the full findings.

## Current state (2026-06-17) — merged to `main`: distribution + onboarding + vision + adapters + training

> **Distribution story landed (2026-06-17).** Four install methods now live:
> direct-download (`install.sh`), **npm 0.0.4** (`bunx mlx-bun` / `npm i -g
> mlx-bun`), **Homebrew** (sign + notarize + tap auto-sync to
> `joshuarossi/homebrew-tap`; `brew install joshuarossi/tap/mlx-bun`), and build
> from source. `bun run publish` is the single-command release pipeline.
>
> **First-run onboarding** (commit `47a5d64`): `mlx-bun serve` with no model
> auto-downloads MiniCPM5, opens the browser, and starts the CPM5 welcome
> assistant — zero-config first run.
>
> **Focus-existing-chat-tab** (commit `472bc6f`): opening a new chat when one is
> already open focuses the existing tab instead of duplicating.
>
> **Adapters end-to-end** (PR #13): web chat selector + CLI `/adapter` command;
> discovery endpoint + `before_provider_request` injection hook. Scale/lr/
> checkpoints are run-configurable; `keep-all-checkpoints` + `metrics.json`.
>
> **SigLIP vision sidecar** (commit `4625fe5`): see the Vision section above.
>
> **Segmented-backward training** (PRs #9–11): see the Training section above.
>
> **Qwen3.5/MiniCPM5 reasoning fix** (PR #12): reasoning channel + restore
> messages fixed in the web UI.
>
> ---
>
> **HLG Curve Designer** (merged earlier). A v2 replacement sampler — draw a
> monotone curve in log-probability space and it replaces temperature+softmax
> (`p_out ∝ exp(curve(log p_in))`); identity ≡ temperature 1. Engine
> `src/curve-sampler.ts` (PCHIP over N movable control points, on-device), wired
> into `makeSampler` via `opts.curve`; served live (`GET /curves` editor,
> `POST /generate` curve sampler, `POST /signal` next-token histogram; "Curves"
> nav tab). Identity falls back to the model's default chat recipe (the honest
> baseline). Gated by `tests/curve-sampler.test.ts`. Built on the batched-serving
> + expert-offload work below.
> **UX bug fixed:** changing curve state (Reset / drag), prompt chips, engine,
> or a new generation now clears old samples, old blind-test reveal state,
> `LAST`/`TESTST`, and the visible "Copy text" action so results cannot appear to
> belong to the wrong prompt/curve.
>
> ---
> **`--batch N` now actually serves B>1** for BOTH full-attention (CPM) and
> sliding-window (Gemma) models: scheduler + gateway wired into the live server,
> end-to-end tested, sliding-window ring-wrap bit-exact vs mlx-lm. **This meets
> the mlx-lm-parity target** — mlx-lm's batched path is bf16 (its quantized
> batching is NYI), so bf16 continuous batching IS the drop-in. `--batch N` is a
> bf16 MODE: with KV quant unset it defaults to bf16 so the batch path engages
> out of the box (Option B); the serial default stays mixed-precision (optiq
> parity). An explicit `--kv-quant` under `--batch N` routes those requests to
> serial (bf16-only batching — warned). **Batched + mixed-precision KV is NOT a
> parity gap** — no ancestor does it (mlx-lm NYI, optiq no batching), so it's an
> optional novel extension (KL-gated, deferred), not required.
> Remaining (all optional polish): the `extend` join optimization, prompt-cache
> reuse under batching, KV-budget admission, throughput numbers.

- **Active: Phase 18 — concurrent / batched serving (slots)** `[~]`.
  Scheduler + gateway are live for BOTH full-attention (CPM) and
  sliding-window (Gemma) models; B=N bit-parity vs mlx-lm achieved for both.
  Polish items remaining: `extend` join op, prompt-cache reuse under batching,
  KV-budget admission, throughput numbers. See PLAN.md Phase 18 +
  `docs/design/parallel-slots.md`.
- **Just completed: docs/repo reorganization** — benchmark provenance
  consolidated into [benchmarks/RESULTS.md](benchmarks/RESULTS.md)
  (3 sections: parity / performance / quality), planning docs moved under
  `docs/planning/`, root decluttered, AGENTS.md de-duplicated. Plan and
  rationale: [docs/design/docs-reorg-plan.md](docs/design/docs-reorg-plan.md).
- **Phase 20 — expert offload (single-user MoE residency): spike complete,
  E1 in progress** `[~]`. Mechanism FULLY de-risked (probes all green: GPU
  `gather_qmm` over a page-aligned mmap is bit-exact + row-local; clean
  read-only file-mmap expert pages cost ~0 `phys_footprint` AND Metal does
  NOT wire them on GPU access → the ~14 GB pool becomes reclaimable cache,
  Apple's outcome without retraining). E0 measured + PASSED (routing
  concentrates ~90% on ~40–47% of experts, tasks specialise). **E1a done**:
  `scripts/convert-offload-experts.ts` produces a page-aligned offload-ready
  expert file, verified byte-identical on the real 26B. **E1b + E1c DONE
  2026-06-14 — IT WORKS ON THE REAL 26B**: env-gated `--expert-offload`
  (`src/expert-offload.ts` + one-line hook in `QuantizedSwitchLinear.load`)
  serves expert weights from a page-aligned file mmap →
  **phys_footprint 17.1 GB → 4.2 GB (−12.9 GB), BIT-EXACT, decode unregressed
  (38.9 → 41.5 tok/s)**. The 26B runs with the memory pressure of a ~4B model.
  **E1d (CLI flag) DONE 2026-06-14**: `mlx-bun serve <model> --expert-offload`
  builds `<model>/.mlx-bun-offload` on first use + activates (bit-exact runtime
  from E1c); split into runtime `src/expert-offload.ts` + build
  `src/expert-offload-build.ts`, wired in `cli.ts` serve. Verified (build /
  help / converter / reuse); `serve --expert-offload` smoke test is Josh's
  (starts a server). **Resume at E1e**: cleared-machine tok/s + optional
  hot-expert pinning + offload scales/biases (last ~6%). Design + all findings:
  PLAN Phase 20 +
  [docs/archive/investigations/expert-offload-single-user-moe.md](docs/archive/investigations/expert-offload-single-user-moe.md).
  Probes/tooling: `scripts/experiments/probe-{expert-residency,mmap-gather,madvise-eviction,footprint,metal-wire}.ts`,
  `scripts/run-expert-trace.ts`, `scripts/analyze-expert-trace.ts`, `src/expert-trace.ts`.

> **Resume here (2026-06-17):** distribution + onboarding + vision + adapters + training all merged to
> `main`. Active Phase 18 [~] batching polish (extend join op, prompt-cache reuse
> under batching, KV-budget admission, throughput numbers). Phase 14 Qwen 27B
> confirmation is Josh-gated (download). Phase 13 TurboQuant is next research
> direction. Full design + rationale: `docs/design/parallel-slots.md`.

**Goal: `--batch N` batched serving as a true `mlx_lm.server` drop-in.**
`--batch N` is a **mode switch** (default 1): N=1 = today's optimized serial
path (untouched); N>1 opts the WHOLE server into a continuous-batching engine
that is **bit-parity with mlx-lm B=N** (B floats 1..N). It is NOT a
load-dependent fallback — that would make results depend on concurrency, which
breaks determinism and the drop-in promise. (Decided with Josh.) No perf
downside: the bit-exact `bf16` path is already at decode/prefill parity with
mlx-lm with zero optimizations — see `benchmarks/RESULTS.md`.

**DONE (verified, committed on `batch-serving`):**
- **L1 batched FORWARD = bit-parity with mlx-lm B=2 across ALL 4 models** (CPM
  full-attn, Gemma 12B sliding+full, e4b per-layer-input+KV-share, 26B MoE),
  short-context. ✅ **Now wired into the live server for full-attention models**
  (see the scheduler + gateway bullets below); Gemma/sliding-window still falls
  back to serial (dynamic-B sliding is the follow-up).
- Verified primitive: `BatchedDecodeMaskCache` (`src/model/batched-mask.ts`) —
  left-pad + per-row `ropeOffsetArr` + `j>=leftPad` mask + fused bool sdpa;
  handles batch-prefill (offset 0) AND decode.
- Per-path fixes (all B=1-identity, no single-stream regression): gemma4
  `Attention` rope captured-once; `LlamaAttention` array-offset rope
  (`minicpm5.ts`); e4b per-layer-input `[1,L,…]` → B-generic (`gemma4.ts`).
- `--batch N` flag (`cli.ts`/`server.ts`; `--decode-concurrency` alias).
- Dynamic-B cache ops `mergeKVRows`/`filterKVRows` (`batched-mask.ts`) =
  mlx-lm's `cache.merge`/`filter`; unit-tested (no model) **AND now
  oracle-verified end-to-end** (next bullet).
- **Dynamic-B (rows join/leave mid-stream) = bit-parity with mlx-lm
  `BatchKVCache.merge`/`.extract`/`.filter` (CPM L1).** `realDynamicBatchedGreedy`
  (`tests/batched-decode-parity.test.ts`) drives a real batched decode through
  {A,B}→join C→{A,B,C}→evict A→{B,C} using `mergeKVRows`/`filterKVRows`; all 3
  per-row greedy trajectories match the oracle token-for-token. Oracle:
  `scripts/gen-batched-dynamic-golden.py` → `tests/fixtures/batched-dynamic-golden-cpm.json`.
  (Join = re-merge of extracted advanced-offset rows + fresh prefill; `extend`
  — the keep-running-batch optimization — is deferred to the scheduler.)
  Added `BatchedDecodeMaskCache.releaseRopeArr()` (free per-step RoPE array
  without disposing the delegated KV — needed when rebuilding a wrapper each
  step around a persistent inner). Full-attention only so far (CPM); Gemma
  dynamic-B is a follow-up (same staging as the static oracle rollout).
- **Scheduler CORE** (`src/serve/batch-scheduler.ts`, `BatchScheduler`): Bun-async
  detached driver owning one running batch; `submit(req)→Promise<stats>`; admit
  (solo prefill + first token + `mergeKVRows`) → batched decode step → per-row
  `sample` + accounting → `filterKVRows` evict. Optional `ExclusiveLock` held for
  the whole active period. Gate: `tests/batch-scheduler.test.ts` (teacher-forced,
  KL vs solo — staggered evict + mid-stream join, CPM L1, KL ≤2e-3).
- **Wired into the live server** (`src/serve/generation-gateway.ts` +
  `src/server.ts`): `GenerationGateway` picks the lane per request and an
  `AsyncMutex` keeps the serial path and the scheduler off the GPU/`loraState`
  simultaneously (batched requests run concurrently with each other; a
  non-batchable one drains the batch then runs solo). Both `handleChat` call
  sites (streaming + non-streaming, hence OpenAI chat / Anthropic messages /
  Responses) route through `gateway.run`; per-row SSE fan-out falls out for free.
  v1 batchable gate: full-attention model + no vision/adapter/repetition-penalty/
  user-seed (temp/top-p/top-k DO batch, per-row seed). Gate:
  `tests/batch-serving.test.ts` (ephemeral CPM server, `--batch 2`: /stats
  batched, 3 concurrent completions, streaming fan-out, batched+serial coexist).
  No serial regression: `tests/server.test.ts` 17/17, `server-tools.test.ts` 13/13.
- **Sliding-window (Gemma) dynamic-B** — `BatchedRotatingCache`
  (`src/model/batched-rotating.ts`): port of mlx-lm `BatchRotatingKVCache` (shared
  scalar ring state, per-row offset/leftPad, the ring-wrap rolled `make_mask`),
  scope-limited to what the scheduler needs (merge / N=1 decode / make_mask /
  filter / temporalView). Gate: `tests/batched-rotating.test.ts` model-FREE,
  bit-exact vs mlx-lm across the wrap (`scripts/gen-rotating-golden.py`). Scheduler
  generalized to per-layer cache types (full→KVCache+wrapper, sliding→rotating
  cache); fixed a stale-batch-size bug (`#B` must track `filter`). Gemma 12B
  scheduled greedy == mlx-lm B=2 golden with staggered eviction
  (`tests/batch-scheduler.test.ts`). Gateway enables sliding-window models;
  kv-quant requests route to serial (batched is bf16-only — L2 follow-up).
  `tests/batch-serving.test.ts` adds a Gemma `--batch 2` HTTP case.
- Oracle tooling: `scripts/gen-batched-golden.py` (needs optiq `register()` to
  load gemma4_unified in mlx-lm; uses mlx-lm `_make_cache`) → fixtures
  `tests/fixtures/batched-golden-*.json`. Real-path validator: `realBatchedGreedy`
  + gated `…ORACLE…` tests in `tests/batched-decode-parity.test.ts`
  (run: `MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batched-decode-parity.test.ts`).
- Earlier (on `main`): P1 parallel-load harness (`scripts/bench-serving-load.ts`).

## Next action — Phase 18 batching polish + Phase 14 Qwen 27B confirmation + Phase 13 TurboQuant

The engine is BUILT and LIVE for BOTH full-attention (CPM) and sliding-window
(Gemma) models (steps 1, 2a, 2b, AND sliding-window dynamic-B done — below).
Remaining work, in rough priority. Gate each with the parity tests; keep
`--batch 1` (and serial fallback) untouched.

- ~~**Gemma / sliding-window dynamic-B**~~ **DONE 2026-06-14** — `BatchedRotatingCache`
  (`src/model/batched-rotating.ts`, port of mlx-lm `BatchRotatingKVCache`, incl.
  the ring-wrap rolled mask) gated bit-exact vs mlx-lm model-free
  (`tests/batched-rotating.test.ts`); scheduler assembles each layer's cache by
  type (full → KVCache+BatchedDecodeMaskCache, sliding → BatchedRotatingCache);
  Gemma 12B scheduled greedy trajectories bit-exact vs the mlx-lm B=2 golden with
  staggered eviction (`tests/batch-scheduler.test.ts`). Gateway enables Gemma.
  **`--batch N` defaults KV to bf16** (Option B, `server.ts` kvScheme) so the
  batch path engages without `--kv-quant off`; gated by the prompt-cache-bypass
  signal in `tests/batch-serving.test.ts`.

**Not a gap — deferred optional extension:** **batched + mixed-precision KV
quant** is novel territory (mlx-lm's quantized batching is NYI; optiq doesn't
batch — no bit-exact oracle). It's a memory-density win (batching + 4-bit KV
compound), NOT an mlx-lm-parity requirement, so it's KL-gated and deferred. The
gateway routes explicit-kv-quant requests to serial.

- **`extend` join op** — today a join RE-MERGES the whole batch (extract all +
  prefill + `mergeKVRows`), O(B·S) per join. mlx-lm keeps the running batch and
  `extend`s the new rows in. Add `extendKVRows` + gate, swap into `#admit`.
- **Prompt-cache reuse under batching** — v1 solo-prefills every row from scratch
  (`cachedTokens`=0). Wire `PromptCache` take/put into the scheduler (it must be
  the sole cache owner — see parallel-slots.md "Prompt cache").
- **`B×S_max` KV-budget admission** — the scheduler admits up to `maxBatch` with
  no byte budget. Add total-projected-bytes admission (mirror the byte-capped
  PromptCache); mlx-lm `--prompt-concurrency` analogue.
- **Throughput numbers** — clean-machine `benchmark.sh` for aggregate tok/s vs B
  (the bandwidth→compute crossover). Josh-gated (preflight).
- Later rows: **L2** (quantized-KV batched, vs optiq) and **L3** (perf kernels
  under batching, KL+quality) — see the matrix in `parallel-slots.md`.

### Done (the build sequence)

1. ~~**Numerical gate for merge/filter**~~ **DONE 2026-06-14** — dynamic golden
   (`gen-batched-dynamic-golden.py`, rows join/leave) + `realDynamicBatchedGreedy`
   prove `mergeKVRows`/`filterKVRows` drive a real CPM batched decode bit-parity
   with mlx-lm's `BatchKVCache`. See the DONE list above. **NEXT starts at 2.**
2. **The async scheduler loop** — **2a (core) + 2b (wiring) both DONE 2026-06-14.**
   - **2a — scheduler CORE: DONE 2026-06-14.** `src/serve/batch-scheduler.ts`
     (`BatchScheduler`): Bun-async detached driver owning one running batch;
     `submit(req)→Promise<stats>`; per loop iter → admit waiting reqs (solo
     prefill + emit first token + `mergeKVRows` into the running batch) → one
     batched decode step (verified forward via `BatchedDecodeMaskCache`) →
     per-row `sample` + token accounting (EOS terminates w/o emit, onToken=false
     halts, maxTokens→length) → `filterKVRows` evict finished rows. Gated:
     `tests/batch-scheduler.test.ts` (`MLX_BUN_TEST_BATCH_DECODE=1`),
     **teacher-forced** (force each row's solo-greedy trajectory, compare per-row
     logits to solo via KL — NOT free-running greedy, which measures chaos);
     covers staggered eviction (3→2→1→0) AND mid-stream join (CPM L1, KL ≤2e-3 ≪
     1e-2). v1: full-attention only (rotating-cache model throws → serial);
     greedy/any per-row sampler; join = re-merge (no `extend` yet);
     `cachedTokens`=0 (no prompt-cache reuse under batching yet).
   - **2b — WIRED into `createServer`: DONE 2026-06-14.** `GenerationGateway`
     (`src/serve/generation-gateway.ts`) picks the lane; `AsyncMutex` enforces
     serial↔batched GPU/`loraState` exclusivity (batched run concurrently with
     each other; a non-batchable req drains the batch then runs solo). Both
     `handleChat` call sites route through `gateway.run`; per-row onToken closures
     (own `StopMatcher` + tool router + SSE stream) give per-row fan-out for free.
     `_is_batchable` gate lives here (full-attention + no vision/adapter/
     repetition-penalty/user-seed). `/stats.batch` now reports `{configured,
     batched, active_rows}`. See `tests/batch-serving.test.ts`.
3. **`_is_batchable` gate** — DONE as part of 2b (the willBatch predicate).
   `B×S_max` memory admission is still TODO (see the "Next action" list above).

**Caveats / scope (don't re-derive):**
- Short-context only so far (pre-wrap, rows < 1024 sliding window). Ring-wrap
  (context > window) batched decode is a separate follow-up (long-context golden
  + RotatingKVCache wrap handling).
- This is **L1** (bf16 KV). **L2** (quantized KV batched: `QuantizedKVCache` +
  `quantizedSdpaUnfused` with a 4-D mask) and **L3** (perf kernels under
  batching, gated by KL+quality) are separate later rows.
- Deferred spikes: paged KV (zero-waste alloc); batched mixed-precision serving
  (novel — no oracle). KV memory today = rung-2 contiguous shape, no budget yet.


---

# Archived from STATUS.md on 2026-07-02 — superseded session wraps

Moved out of STATUS.md when it was condensed to current-state-only. Verbatim below.

## SESSION WRAP 2026-07-01 — v0.0.9 released; next actions below

**Landed today (~35 commits, all verified, tsc 0, no Claude trailers):**
mlx_lm.server drop-in surface complete (endpoints/fields/flags/logprobs,
L1-faithful sampler ports) · verbs: fuse/convert/perplexity/upload/gc ·
ORPO `sft_scope` (paper/TRL-faithful default; `response` bit-exact pinned) ·
Tier-0 generic models (UniversalDense, 11 archs; llama/qwen2/gemma2 verified
bit-exact) · 12+1 kernel-review bug fixes incl. the **--l2 tier restoration**
(perf kernel demoted to --l3 — envelope-gated, evidence in 381382c) ·
batching v2 steps 1–3 (capability gate, containment, drain, pipelining) ·
registry canonical dedupe + gc (~24.7GB found; NOT deleted — see task
notes on the 12B vision-weights decision + tests/paths.ts pins first) ·
pi integration 10 fixes (generics tool-calling, memory tools, harness) ·
website+README six-goals pass (23 pages; deploy release-gated) · CI gate ·
batched goldens machine-keyed (the "regression" was M4-Pro fixtures; ALL
code exonerated, 11/11 green) · decode-roofline look-again (**the floor
claim was wrong** — only the 12B is at the wall; docs/archive/investigations/
decode-roofline-lookagain.md) · curve-sampler distinctness THEOREM + witness
(TV 0.11–0.19 at forks unreachable by any truncation sampler; old "wash"
verdict invalidated — it measured the wrong sampler; preregistered protocol
in docs/planning/curve-sampler-research-plan.md).

**Next actions, ranked (each has a tracked plan):**
1. Josh: push + publish v0.0.9 (sequence above), then optionally `gc --yes`
   after the 12B-vision decision + test-pin updates.
2. ~~Kernel backlog #1 — flip the measured 1.35× coeff filter~~ **DONE
   2026-07-02** (both skips default 1e-5; combined backward **1.71× CPM5 /
   3.16× e4b** vs exact, fidelity-gated — see kernel-perf-review-2026-07.md
   backlog #1). The decode graph-build-overlap spike also ran (2026-07-02):
   **REFUTED** — the pipelined loop already hides the host build (wall = GPU
   step time; spin-injection proof in decode-roofline-lookagain.md §7), so the
   roofline doc's host-side fixes 1a–1d are dead and the recoverable decode
   gap is entirely GPU-side (26B expert reads, e4b dispatch count, CPM5
   KV-path, kernel backlog #4, spec decode).
3. Web-UI fix wave (docs/archive/planning/web-ui-pass-plan.md — 6 bugs, landing order inside).
4. Batching steps 4–10 (docs/design/batching-v2-plan.md).
5. serve --draft-model + remaining verbs (docs/design/mlx-lm-tool-parity-plan.md).
6. Curve H2/H3 preregistered run (docs/planning/curve-sampler-research-plan.md).
7. Dynamic-λ controller build (docs/design/orpo-dynamic-lambda.md).
8. fit-as-recommender; memory-docs banner pass + `mlx-bun route` verb
   (docs/planning/memory-docs-and-dag-plan.md); DSpark live-τ.
~~Open kernel bug: FUSED_DECODE×compiled-decode trace-freeze~~ **FIXED
2026-07-02** (reproduced on e4b, combo now refuses to compile + throw
backstop + regression; see kernel-perf-review-2026-07.md ledger).
Kernel backlog #2 (planSegments full-attn isolation) **REFUTED by measurement
2026-07-02**: sdpa backward is O(L²) for EVERY layer (~3.5 GB/layer @8K), so
segment_size is the whole knob — **seg1 = 14.59 GB e4b @8K (+3% time), fits
the 24 GB M4 Pro today**; next real levers = backlog #8 (head) + O(L)
attention backward. Evidence: scripts/experiments/seg-isolation-smoke.ts.
Kernel backlog #8 (bound the SFT segmented head) **LANDED 2026-07-02**:
boundedSftCe in both SFT segmented classes — head-only A/B at e4b M=6000:
**16.60 → 6.60 GB** (~10 GB head-vjp transient gone), dh relnorm 0.00000.
Landing it EXPOSED an **upstream mlx bug** (repro'd on stock 0.31.2):
quantized_matmul(transpose=false) is WRONG at 2-3 rows → every training
head's dh was silently wrong for 2-3-token responses/tail-chunks/spans.
Fixed in mlx-bun (logitsFromHiddenPadM + ops wrapper pad; f32-ground-truth
gated, chunk-4 dh 0.47→0.006); details in kernel-perf-review-2026-07.md
"NEW BUG" + research journal. Upstream report = pending task chip.
Kernel backlog #3 (head auto-dispatch by M) **LANDED 2026-07-02**
(MLX_BUN_FLASH_MIN_M=1024; fresh crossover sweep — the filter flip made
flash faster at long M too). Kernel backlog #4 (fused-decode activeN)
**built, gated byte-identical, then REFUTED end-to-end and REVERTED**
(12B kv4 interleaved A/B: 0.94 @8k / 0.97 @22k — the fetch-view copies
never applied to the KV=1 full-attn shape; evidence in
scripts/experiments/fused-decode-activen-ab.ts).
Kernel backlog #9 (segmented-step overhead) **LANDED 2026-07-02**: single-copy
detach + one barrier/segment + prefix-mask memo — grads BYTE-IDENTICAL,
short-seq steps −34% (CPM5 prefix) / −38% (e4b SFT), @8K flat.
26B gather-qmm **PROFILED 2026-07-02** (roofline item 2): the ~4 ms gap is
mx.gather_qmm's missing M=1 fast path (compute-bound at ~99 GB/s vs qmv's
~180; upstream-reproduced). Layout + dispatch-merge candidates both refuted
by measurement. The custom gather-qmv kernel was then BUILT (correct on all
three dispatch patterns) and **SHELVED on decisive numbers**: five structural
variants all slower than gather_qmm (best 12.5 vs 8-10 ms), and
mx.fast.metal_kernel's ~60-95 µs/dispatch fixed cost in dependent chains eats
the ~4 ms prize at 90 dispatches/step. Routes forward: upstream mlx
gather_qmm M=1 specialization (primary; pairs with the qmm M=2/3 bug report)
or a fused whole-MLP kernel (60 dispatches/step) in a dedicated session.
Evidence: scripts/experiments/moe-expert-read-profile.ts,
moe-qmv-kernel.ts (post-mortem in header), moe-qmv-parity.ts.

## Multi-agent review + cleanup (2026-07-01) — verified state, open decisions

Two adversarially-verified review workflows (13 agents) swept the whole repo; the
full report is local at `reports/project-review-2026-07-01.md` (gitignored). What
landed the same day: repo hygiene sweep (scratch logs/example.ts/pycache/runs
untracked; megakernel → `scripts/experiments/`; orphan worktree removed;
`fix/section-synthesis` third-person-voice fix **merged**), docs truth pass (this
file rewritten; flash-attn story reconciled; README/CLAUDE.md doc map refreshed).

**Confirmed findings, still open (ranked):**
1. ~~**ORPO L_SFT scope divergence**~~ **DONE 2026-07-01** — `sft_scope:
   full|response` landed across every ORPO path (naive/chunked/fused/flash /
   prefix-shared / all four segmented classes), **default `full`**
   (paper/TRL-faithful: chosen-NLL = token-mean CE over the full
   prompt+response, only padding excluded, from the same chosen forward);
   `response` reproduces old runs bit-exactly (regression-pinned in
   `tests/train-orpo.test.ts`). The odds-ratio ℓ terms stay response-only in
   BOTH modes (matches TRL). Config: TrainConfig `sftScope` / job `sft_scope` /
   `SFT_SCOPE=` env in `scripts/train-orpo.ts`. Cross-path full-scope parity +
   an sftLoss(promptLen=1) oracle wired in `tests/train-orpo-fused-ce.test.ts`.
   Docs: `docs/design/orpo-training.md` (“The objective” — resolved note),
   `docs/reference/training.md` (config table + ORPO section). Remaining: the
   one-line `--sft-scope` CLI flag in `src/cli.ts` (file owned by another
   workstream at land time).
2. **DSpark τ=3.24 is a teacher-forced proxy** — `evalTau` feeds the Markov head
   ground-truth previous tokens; live decode threads the drafter's own drafts.
   Run `scripts/dspark-measure-dflash.ts` (live τ via `meanAcceptLen`) on the
   overfit checkpoint before the 27B retarget. Architecture itself verified
   faithful (see DSpark section).
3. ~~**Memory batching default**~~ **DONE 2026-07-01** — `memoryBatchSize()`
   default flipped 8 → 1 (serial, bit-exact; batching measured 1.7–1.9× slower).
   Opt back in with `MLX_BUN_MEMORY_BATCH=8`.
4. **No CI** — the only GitHub workflow deploys the website; nothing runs
   `bunx tsc --noEmit` or `bun test` on push. Add a gate.
5. **Test gaps** — DPO has zero loss/e2e tests; ORPO fused-CE tests assert only
   "loss decreases" (real grad-parity checks live un-wired in
   `scripts/experiments/`); DSpark smoke tests live outside `tests/`.
6. ~~**`mlx-bun memory status`** stub text~~ **DONE 2026-07-01** — status +
   help now report synthesis as available (`mlx-bun memory synthesize`).

**In progress (Josh directive 2026-07-01):** CLI flags/defaults parity with
`mlx_lm.server` + implement all missing mlx-lm functionality. Done 2026-07-01:
default port 8090 → 8080, default host all-interfaces → 127.0.0.1 (loopback,
`--host 0.0.0.0` = LAN opt-in), `--temp` alias for `--temperature`,
`--decode-concurrency` semantics documented honestly (accepted for drop-in
compat; enables continuous batching with that cap, not mlx-lm's
per-BatchGenerator parallelism); L1-faithful min_p/XTC/presence+frequency
penalties/logit_bias in the sampler AND wired end-to-end through all three
protocol surfaces (mlx-lm wire names incl. `*_context_size`; serial-lane-only
under `--batch N`, v1); `POST /v1/completions` (raw text completion,
non-stream + SSE, no chat template, mlx-lm's 512 default max_tokens);
`GET /health` (byte-exact mlx-lm body); `/v1/models` lists served model first
+ all registry-known supported models, `/v1/models/<id>` filter; serve
`--adapter <dir>` (+ `--adapter-path` alias) mounts at startup and becomes the
request default (fixes the `mlx-bun train` completion-message inconsistency);
`logprobs`/`top_logprobs` end-to-end on chat + text completions — mlx-lm's
EXACT semantics (distribution = post-processor pre-truncation log-softmax,
generate.py L409-422; response = server.py generate_response's id-keyed block,
NOT OpenAI's; validation bool + int∈[0,11]∪{-1}; stream chunks carry no
logprobs, faithfully — mlx-lm never emits them when streaming; serial-lane-only
under `--batch N`; zero-cost when not requested).
Tests: tests/server-compat.test.ts. Also done 2026-07-01: `fuse`/`convert`/
`perplexity` verbs, server `--max-tokens`; `upload` verb (mlx_lm.upload
--path/--upload-repo parity over native `src/hf-push.ts`, + `convert
--upload-repo` runs the push after converting; tests/cli-upload.test.ts);
`--sft-scope full|response` on `mlx-bun train` (CLI spelling for the trainer's
`sft_scope`); 14-finding CLI audit applied (fit --ctx help→8192 = code, embed
no-query auto-picks a downloaded embedding model instead of a chat starter,
pi flag-strip covers --batch/--adapter/--hlg-*/--no-open/--l1-3, `setup` is a
true `memory` alias + unknown memory subcommands exit 1, --l1/--l2/--l3 +
generate + train-watch documented in help, doc lies fixed in memory.md /
server-config.md). Remaining gaps (verified vs the oracle venv): no
`--draft-model`/
`--num-draft-tokens`/`--chat-template*`/`--min-p`/`--log-level`/
`--allowed-origins`/`--prompt-concurrency`/`--prefill-step-size` flags;
CLI verbs cache_prompt/evaluate/awq/dwq/gptq absent.
Deliberately not ported: `role_mapping` (mlx-lm's synthetic "USER:/ASSISTANT:"
prompt assembly, used ONLY when a tokenizer has no chat template — every
mlx-bun-supported model ships a real template, so the branch is unreachable
here). Known adjacent gap: `/v1/responses` logprobs — OpenAI's Responses API has its
own knob (`include: ["message.output_text.logprobs"]` + `top_logprobs`); the
optiq shim oracle accepts flat `logprobs`/`top_logprobs` fields and validates
them (responses_server.py L195-196) but its output translation DROPS the block
(zero logprobs mentions in responses_shim.py), so no reference emits Responses
logprobs. Ours doesn't map the fields at all; deferred until a client needs it.
`/v1/messages` (Anthropic) has no logprobs in the protocol — correctly absent.


# STATUS archive 2026-08-18 (moved from STATUS.md by the Phase D
# hygiene sweep — CONTRIBUTING.md rule 4: STATUS holds current state only)

## Completed: pre-Colibri stabilization (2026-07-29)

Phase 22 is closed. The 25-item intake is tracked in
[docs/design/pre-colibri-stabilization.md](docs/design/pre-colibri-stabilization.md)
with stable IDs and evidence. Every P0/P1/P2 item is fixed; the conditional
WebSocket Origin, `/api/*` CSRF, and wildcard-CORS trio remains deferred while
loopback-only is the supported deployment.

PERF-01 is measured and fixed: bounded incremental detokenization is
byte/chunk-exact and 19.84× faster at 2,048 output tokens on the paired
MiniCPM5 harness. PERF-02 is also measured and fixed on the clean M1 Max
Qwen2.5-0.5B harness: selected-logprob overhead fell from 47.7% to no
measurable overhead (0.999× the off arm), and `top_logprobs=5` fell from
68.7% to 6.5%. The off control stayed flat, and all 40 parity checks plus
1,280/1,280 selected and top-k values remained exact.

The two isolated oracle drifts are resolved. The e4b chirp difference is an
allowed frontend residual crossing a later greedy near-tie: the actual bf16
language-model splice boundary is byte-exact from the oracle mel, so the e2e
fixture now gates the factual decode instead of asserting a contradictory
trajectory. The mixed-KV mismatch was stale machine-local `.bin` data; fresh
pinned-oracle blobs are bit-exact, and their manifest now binds provenance and
SHA-256 values. The final two-shard gate passed 1,857 tests with 71 intentional
skips and zero failures. Phase 21 is explicitly unpaused.

## Active: native Colibri/GLM-5.2 port (2026-08-17)

The G1–G3 foundation is landed on `main`. Phase 21 **G0–G8 are complete**.
Post-release first-prompt review found one API compatibility bug: a client-wide
`max_tokens: 8192` upper bound was rejected wholesale against GLM's fixed 4,096
context even when the prompt itself fit. The v0.0.13 fix caps that upper bound
to the remaining planned context (the reported 2,788-token prompt gets 1,308
completion tokens) and still rejects prompts that leave no generation slot.
The exact case is model-free gated on both chat-admission arithmetic and the
generic-budget non-regression.
Acquisition now has exact remaining
disk preflight/resume accounting, and the normal CLI/API/status surfaces show
the artifact-aware streamed plan, measured/direct/aspirational speed as
distinct quantities, and live main/MTP expert-tier telemetry. The landed
foundation has a strict versioned synthetic Colibri
gate/up/down artifact, fixed 16 KiB native slabs, passive bounded `pread`
workers, async Bun-side completion polling, generation-bound CPU/GPU leases,
lazy-graph evaluation plus stream synchronization before reuse, deterministic
LRU traces, and stock-MLX/custom-Metal zero-copy consumers. Forced churn covers
1,000 native reloads plus 100 GPU-fenced MLX reloads with flat allocator use.
The final adversarial audit reproduced and closed both a post-close bus error
and a lazy-graph stale-read/UAF class before passing. The Colibri checkout remains clean at
`44e489b196c9b7876b3d37a0570ebf1c6f90f54c`; the public GLM-5.2 artifact is
pinned at revision `3cc8db99b1b13fc79325d987ba3c1c430766b3b8`. All 150 files
are accounted for and all 145 LFS payloads (383,760,044,154 bytes) match the
pinned Hugging Face SHA-256 metadata. The downloader now reads the current
`lfs.sha256` field, fixing the schema bug discovered during this audit.

Direct Colibri/Metal ran the full model on this 32 GiB M1 Max at an 18 GB
budget, 128-token context, true top-8 routing, one explicit LRU slot/layer,
`DIRECT=1`, and zero pins/learned routing. The authoritative matrix has three
independent processes per MTP mode and two requests per process. Fresh-turn
median throughput was 0.34 tok/s MTP-off versus 0.26 tok/s MTP-on; MTP accepted
34/90 raw proposals and reduced main forwards from 63 to 30, but raised expert
traffic from 836.909 to 1126.703 GB and total request time by 29.1%. Median peak
footprints were 13.631 and 17.475 GB. Every process reported zero swaps, and
the same pre-existing 0.75 MB of system swap remained unchanged in every cell.

The second request uses the same PID after RESET clears KV but preserves the
expert LRU. Median MTP-off TTFT improved 29.332 -> 28.431 s while throughput
remained 0.34 tok/s. MTP-on TTFT moved 31.132 -> 31.895 s and throughput only
reached 0.27 tok/s; acceptance shifted from 34 to 33 and required one extra
main forward. All twelve turns returned exactly the same 64 token IDs. Live
`mactop` telemetry during MTP-on showed ~4.9 GB/s reads, 0 B/s writes, 24% GPU,
16.1 GB/s unified-memory bandwidth, and 19.91/32 GB memory: the current limit is
expert delivery/serialization, not compute or DRAM bandwidth. A 140-record
real-model GLM/MLA/router/MTP/KV oracle reproduced byte-for-byte twice; both
heads predict teacher token 16 and the compact validated capture is tracked in
`fixtures/colibri-glm52/real-model-oracle.json`.

The published artifact has no DSA indexer tensors. The machine-local HF
snapshot now carries the exact stock overlay generated outside this repository:
20 `out-idx-*` files, 197,202,400 bytes, from pinned
`zai-org/GLM-5.2-FP8@ba978f7d`. Header validation finds all 21 full indexers,
57 shared layers with no indexer requirement, complete MTP metadata, 118,646
tensors, and no layout errors. The original G0 waiver and model-free fixtures
remain historical evidence; the patched HF model is the long-context target.
At the original 128-token G0 context DSA still selects densely because the
context is below `topk=2048`; sparse behavior begins only at token 2,049.
Commands, caveats, and current evidence are in
[docs/archive/investigations/indexshare-performance-spike.md](docs/archive/investigations/indexshare-performance-spike.md).

G2 now has a dedicated `glm_moe_dsa` config/model and artifact-aware
`openModel()` path, exact GLM template fallback and multiple EOS, direct
Colibri shard catalog/layout validation, lazy MLX Q4/Q8 loading, compressed MLA
KV, reconstructed prefill plus absorbed serial decode, exact DSA selection and
shared-state reuse, exact lower-ID-tie top-8 routing, and shared+routed expert
composition. Focused synthetic/reference gates are green. Header-only
validation of the pinned public artifact found 59,003 quantized tensors, 472
float tensors, 19,456 routed experts, complete MTP metadata, and—as expected—
no DSA sidecar, without executing the full model.

The G2 tiny-model gate is now closed with the pinned Colibri code. An isolated
generator environment reproduced the committed BF16 trajectory exactly, then
Colibri's converter produced the production-relevant 353 KiB per-row Q4 direct
container. The apparent 26/32 discrepancy was entirely an oracle-mode mismatch:
Colibri defaults to activation-int8 `IDOT` on Apple Silicon, while G2's
quality-preserving contract is exact dequant-to-f32-MAC. With `IDOT=0`, Colibri
C and mlx-bun match at 32/32 positions on identical Q4 bytes. Across all 8,192
logits, max absolute delta is 1.3113e-6 and RMSE is 2.7423e-7; mlx-bun's
minimum top-two margin is 0.003425. The tracked fixture records the pinned
commit, exact conversion/oracle arguments, both exact and default-IDOT
trajectories, numeric bounds, and SHA-256 values. The artifact is preserved
machine-locally at `runs/colibri-glm52-tiny-i4`.

The manual production-Q4 gate is now closed too. A selected-shard runner used
the real G0 decode inputs without constructing the full model, experts, cache,
or generation loop. Layer 0's complete Q4 gate/up/down SwiGLU matched pinned
Colibri `dense_mlp` under `IDOT=0` at max absolute delta 5.2387e-9 and RMSE
9.7823e-10. Layer-3 and layer-77 router projections reproduced the exact eight
expert IDs and `keff=8`; sigmoid max deltas were 4.7684e-7 and 7.1526e-7.
Two fresh processes produced identical numeric results. The run exposed and
fixed one production-only bug: Colibri's whole-row scale implied unsupported
MLX affine-dequant group size 6144, so the same scale is now repeated over
supported 32-value groups with identical dequantized values. With the tiny
artifact gate enabled, the focused GLM suite is 55 pass, 0 fail.

Peak MLX allocation was 1,566,883,896 bytes and observed process RSS peaked at
290,455,552 bytes. System free memory remained 78%; the pre-existing 1,840.25
MiB of swap did not change. Stable evidence is tracked at
`fixtures/colibri-glm52/production-probe.json`. No performance benchmark or
full-model generation was performed; this was the bounded G2 correctness
probe authorized for the production artifact.

G3 now has the direct-artifact residency path in worktree. Native slabs accept
up to eight positioned segments across the 141 main shards, which covers the
19,114 ordinary four-segment experts and 86 cross-shard six-segment experts
without constructing a converted copy. The canonical production Q4 slot is
18,939,904 bytes (down/gate/up packed weights followed by their F32 scales);
every directly wrapped component starts on its own 16 KiB boundary.
The native layer also exposes physical-footprint sampling and safe decommit of
idle generations while preserving fixed virtual addresses.

The TypeScript policy derives capacity from a fixed byte budget and refuses
startup below the global 64-slot working bank plus one persistent slot per
sparse layer. It implements deterministic per-layer LRU, a separate pinned
tier, generation-tagged async loads, reverse-order miss promotion by logical
slot-role swap (no 19 MB copy), one shared GPU fence per wave, stable row/rank
batch union, and safe-point-only downward pressure correction. Read failures
are drained and discarded before a scratch slot can be reused.

The GLM execution chain has a parallel async path from model through layer and
MLP. It submits resident expert graphs and the shared expert before miss reads,
materializes each <=64-unique wave before releasing its slab leases, and
composes rows afterward in exact route order. Resident weights explicitly
reject every `.mlp.experts.*` access, preventing fallback to the G2 mmap
backend. The stock-MLX candidate wraps canonical packed Q4 bytes directly as
uint32 lanes and uses affine QMM with the exact `-8*scale` bias. The machine-
local tiny direct container passes the complete streamed 32/32 trajectory with
64 global working slots, one LRU slot for each sparse layer, and no live leases
or loads after the forward. Focused G3 policy/layout/async/native tests are
green.

The post-alignment bounded production expert gate also passes. Layer 3
reproduces exact top-8 `[250,64,199,172,129,191,82,63]`; the complete weighted
routed sum plus unweighted shared expert is byte-identical across cold, warm,
and forced-eviction reruns and matches the direct Colibri capture at max
absolute delta 1.8626e-9 / RMSE 3.6290e-10. The forced trace records cold
`0H/8M/0E`, warm `1H/7M/0E`, replacement `0H/1M/1E`, and post-eviction
`0H/8M/1E`. Final physical footprint is 726,549,944 bytes and swap growth is
zero. Stable evidence:
`fixtures/colibri-glm52/g3-production-expert-probe.json`.

The full streamed two-forward gate now passes: the 32-token prefix predicts
16 and the following decode predicts 13, with tie-free margins 2.9581 and
7.0824. The run used the required 64-slot global bank plus one LRU slot for
each of 75 sparse layers; final physical footprint was 13,474,688,232 bytes,
MLX peak allocation was 11,007,206,184 bytes, and no load or lease remained.
The first attempt exposed and fixed a G2-only full-table Q8 embedding/head
transient: streamed embedding now gathers rows before signed-int8 dequant,
the output head is evaluated in bounded output-row tiles, resident Q4 spine
linears use MLX affine quantized matmul, and every layer is an explicit safe
point. A live per-wave swap guard now records and bounds system-wide swap
activity. The passing non-cleared run recorded 397,148,160 bytes of swapout
with other applications open; that is not a zero-swap claim, whose cleared
machine gate remains G5. Stable evidence is
`fixtures/colibri-glm52/g3-full-model-trajectory.json`.

The final adversarial G3 review found no numeric, alignment, ownership/UAF, or
budget blocker. Its two error-path findings (double release after a failed
lease release and post-close guard sampling) are fixed, and the 98-test
focused/native suite plus both entry bundles pass afterward.

The cleared-machine G1/G3 matrix is now complete. At the production M=1 top-8
decode shape, custom Metal measured 4.282 ms versus stock MLX at 5.099 ms
(16.0% faster after ten warmups; an independent shorter run also won by 5.4%)
with max absolute output delta `2.33e-9` and relative RMSE `5.56e-7`.
Therefore custom Metal is selected for routed decode; stock MLX remains
selected for Q4 dense operations, routed M=11/M=32, and absorbed MLA. The
same-shape direct-Colibri matrix remains the performance oracle and exposes
the largest residual gap at MLA decode (1.014 ms direct vs 11.506 ms stock
MLX). Two matched idle-power matrices show no monotonic CPU/GPU/package-power
increase from 1, 2, or 4 sleeping workers, confirming passive waits; the
chosen default remains two workers. Swap stayed exactly 339.25 MiB through
the kernel runs. Raw reports are under `runs/colibri-g1/`.

G4 serial native MTP is complete. The in-process source shares the target
embedding, output head, dense weights, and sampler; the signed-int8 MTP routed
row has a bounded 24-working + 1-resident expert tier whose 945,356,800-byte
slab is included in the main plan. Partial and zero-accept tests lock exact
target/MTP rollback, and fixed Q4/Q8 Metal families are row-stable across
draft and verify widths. Grammar remains in the common constrained verify
walk; prompt lookup is the alternative model-free provider, so one draft
history owns each request.

The direct `IDOT=0,SPEC_PIN=1` capture and mlx-bun match all 64 target tokens
and the tie-free first four acceptance rounds `[1,1,1,0]`. Later direct
acceptance is retained as non-gating evidence because direct Colibri reduces
RMSNorm in float64 while MLX uses its established float32 graph. The
separate-process production A/B passed: 675.654 s MTP-on versus 834.172 s off
for 64 tokens, a 1.235x wall-throughput win / 19.0% less generation time.
MTP accepted 32/92 drafts over 31 verify forwards, emitted 2.065
tokens/forward, and saved 32 target forwards. The machine was not swap-cleared,
so the 14,679,224,320-byte completed footprint is not a G5 memory claim.
Stable evidence:
`fixtures/colibri-glm52/g4-native-mtp-e2e.json`.

The G5 implementation, model-free gates, and full-model measurement are now
complete on
`codex/colibri-g5-memory-contract`. The pinned artifact's header-only MTP-on
plan is 21,111,440,128 bytes, leaving 5,732,105,472 bytes below the 25 GiB
process ceiling plus an explicit 7 GiB OS reserve. The planner total is
byte-for-byte the same equation handed to runtime expert residency; impossible
starts fail before resident weights are mapped. The manual lane harness runs
cold then warm 128-token turns, samples physical footprint/MLX/compressor/swap,
and the paired evaluator requires exact first-64 direct-oracle and complete
128-token cold/warm/on/off identity.

The 2026-08-15 fresh-process observational pair completed all four turns with
exact identity. MTP-on measured 13.791 GiB peak footprint, 13.666 -> 13.688
GiB cold-to-warm final footprint (+23.1 MiB), and 0.146 -> 0.149 tok/s
end-to-end. MTP-off measured 12.644 GiB peak, 12.564 -> 12.583 GiB (+19.2
MiB), and 0.127 -> 0.114 tok/s. Warm MTP-on was 1.306x MTP-off. MTP accepted
72/166 drafts per turn, emitted 2.286 tokens/target forward, and saved 71
target forwards. Both peaks are far below the 25 GiB process ceiling.

Josh changed this execution from hard compressor enforcement to an explicit
before/after observation: strict mode remains the default and its thresholds
are still reported, while `--memory-mode observe` does not abort generation.
Accordingly the paired report is truthfully marked `observed` and
`strictContractSatisfied: false`: system compressor growth peaked at 4.101
GiB, task-compressed memory at 1.806 GiB, and the MTP-off lane recorded 6.8
MiB of swapout (MTP-on zero). These were bounded rather than a footprint
spiral; warm final footprint stayed nearly flat. Production/spec generation
now applies the full streamed process plan to MLX's scoped wired limit, and
native expert slabs wire slots before reads then unlock before discard.
Stable machine-local evidence is under `runs/colibri-g5/`.

G6 is active. Its first production slice adds a shared target/MTP
Colibri-compatible `.coli_usage` ledger: every top-k route is counted before
batch-union deduplication, startup history is kept separate from live
heat/recency, and generation safe points atomically replace the profile. A
damaged derived profile warns and restarts empty rather than preventing model
load; `usagePath: false` is the diagnostic opt-out. The scheduler inventory
also confirms that stable batch-union, bounded positioned-read/F_NOCACHE
workers, per-layer LRU, and resident-first Metal submission are already
implemented.

The second slice consumes that history through an opt-in startup auto-pin
candidate. It matches Colibri's 5k/200k confidence ramp, half-tier share, and
0.5 GB minimum, but adds deterministic ties and cost-aware Q4/Q8 budgeting.
Pins are clamped behind the one-slot-per-layer floor, represented in the exact
main/MTP slab plans, and loaded before the first forward. It remains off by
default until the required MTP-on comparison wins.

The third slice adds opt-in safe-turn live LFRU: exact uint32 recency scoring,
25%+4 hysteresis, session-heat decay, and one four-swap cap shared across main
and MTP. Completed loads change logical tier roles without copying a 19/38 MB
expert, while live maps now expose tier, persistent count, heat, recency,
hits/misses, and repin totals. Controlled probes explicitly disable usage
learning so benchmark traffic cannot contaminate a real model profile.

The three-repeat MTP-on learning matrix is complete. All nine cold/warm arm
runs were token-identical from the same 308,592-selection seed. Startup
auto-pin moved median warm hit rate 1.66% -> 9.62% and reduced disk GB/token
8.02%, but median warm throughput fell 4.06% (0.149 -> 0.143 tok/s), model open
rose 526 ms, and warm physical footprint rose 3.337 GiB (13.694 -> 17.032
GiB). Its 3.329 GiB preload therefore did not pay back. Live LFRU made zero
swaps across every measured turn and landed at 0.148 tok/s, 0.38% below
control; that is run-order noise over the unchanged startup placement, not an
adaptation win. Both policies remain off by default. The default-eligible
summary and raw per-turn telemetry are machine-local under
`runs/colibri-g6-learning-shakeout-2026-08-15/`.

The isolated measurement-only PILOT arm and bounded hint-only `PILOT_K=4` arm
are now implemented. The latter uses a separate bounded native advisory queue
to issue scale-tail-only `F_RDADVISE`; it skips resident experts and never
allocates/publishes slots or mutates demand/LRU state. A one-repeat MTP-on
paired full-model shakeout kept tokens exact. Each turn completed all 48,162
submitted hints (144,486 operations / 1.973 GB advised) with zero drops,
errors, queue backlog, or in-flight work at turn end. Warm logical demand bytes
were exactly unchanged, while disk-service p95 was 1.0065x control,
foreground-wait p95 was 1.0193x, and warm throughput was 0.9746x (0.14031 ->
0.13675 tok/s); final footprint increased only ~3.8 MB. Hint-only therefore
remains off and does not justify real speculative loads. This is a correctness
shakeout, not a replicated performance result. Evidence is machine-local under
`runs/colibri-g6-pilot-hint-k4-shakeout-2026-08-16/`; the preceding predictor
quality result remains under `runs/colibri-g6-pilot-measure-shakeout-2026-08-16/`.

Two-step and coupling measurement are now complete. The two-step predictor
reproduces Colibri's current-layer shared-expert correction without feeding
its output into execution. It improved top-8 precision/recall from 69.90% to
73.01% and exact rows from 5.35% to 7.90%, but the one-repeat MTP-on warm arm
fell 10.13% in throughput (0.14978 -> 0.13461 tok/s) with exactly unchanged
logical demand bytes/token. A separate 23,250-record route trace used only the
cold segment and a temporal 108-position train / 47-position held-out split.
At budget 8, coupling reached 31.02% recall for delta 1 and 30.81% for delta 2,
8.06 and 7.66 points above the marginal baselines but far below direct PILOT;
budget 32 still reached only 57.35% / 56.74%. Both mechanisms remain
default-off and real speculative loads are rejected. Evidence is machine-local
under `runs/colibri-g6-pilot-two-step-shakeout-2026-08-16/` and
`runs/colibri-g6-coupling-shakeout-2026-08-16/`.

The controlled Atlas workflow and real-model gate are complete. The 30-prompt
sweep retained 13,236 replicated experts, including 1,065 strong specialists
(8.05%), and global leave-one-prompt-out classification scored 29/30 (96.7%,
chance 10.0%). That exactly reproduces Colibri's published held-out accuracy;
its published population was 13,260 replicated / 1,041 strong (7.85%). The
single miss was Chinese prompt 1 classified as poetry. Detailed JSON,
Colibri-compatible `experts.json`, and the verified standalone interactive map
are machine-local under `runs/colibri-g6-atlas/analysis/`. Atlas-informed
warm-start and the optional G4R prompt-seeding spike remain explicitly deferred
and default-off.

**G8 productization is complete:** the downloader computes
the exact remaining payload before transfer, credits complete shared blobs and
valid `.incomplete` prefixes, and refuses before the first payload when the
target volume cannot fit the remainder plus a fixed 1 GiB reserve. The pinned
~357 GiB artifact, cache-volume selection, resume/recovery flow, exact 32 GB /
25 GiB launch command, model lineage, and Apache-2.0 Colibri attribution are
documented. The CLI/API/status surfaces now show the exact streamed resource
plan, measured/direct/aspirational speed separately, and live main/MTP expert
telemetry. `benchmarks/RESULTS.md` curates the final oracle, memory, speed,
expert-I/O, policy, DSA, and API cells, including the 13.45x gap to the 2 tok/s
aspiration. The focused G8b gate passes TypeScript plus 55 tests / 1,910
assertions. Native-pack publication and the public fresh-cache check are also
complete, closing G8d and Phase 21.

G8d is complete. Native pack v0.2.0
and the compiled/Homebrew bundle now contain `libmlx_bun_expert_io.dylib`; an
isolated empty-cache run downloaded and extracted the real 52,307,647-byte
archive, loaded MLX, and completed a positioned expert read. The compiled
bundle passed version/help/ls/pi smokes, and TypeScript, docs-map, plus 74
focused tests / 4,335 assertions are green. GitHub release `native-v0.2.0` is
published with both assets; the archive's remote size and SHA-256 match the
baked constants. Anonymous HTTP resolution and a clean default-URL
download/checksum/extraction passed with all five required files.

The actual mlx-bun v0.0.12 package release is also complete (2026-08-17).
GitHub publishes the signed/notarized 80,420,638-byte arm64 bundle under both
versioned and stable asset names with SHA-256
`64c4d697faba65789c2af7c1344ee39024f8a03bd6839d2c8df4ec7dce872a74`;
`mlx-bun@0.0.12` is live on npm (registry shasum
`0dcc5c200fa81dbea1f8be854e21a0efbbdebbfa`), and the public Homebrew tap
points to the same archive and checksum. The full two-shard release gate passed
1,936 tests / 28,378 assertions with 71 skips and zero failures. Remote `main`
contains the release implementation and in-repo formula mirror.

**G6R Stage 0 complete:** at context 2,049, the patched model produced all 21
expected full-layer top-2,048 selections. All 21 official Colibri score rows
were tie-free and replayed through mlx-bun with exact ordered positions and
float32 thresholds. Both runtimes emitted greedy tokens `[264, 264]` and the
sparse-step top-1 logit matched; full-vector cosine was 0.997645. Direct
full-runtime positions were 10/21 ordered-exact and 14/21 set-exact because
the two runtimes accumulate quantized model matmuls differently before DSA;
the official-score replay isolates and closes the DSA selection contract.
Machine-local evidence and the 20-file SHA-256 manifest live outside the repo
at `~/.cache/mlx-bun/evidence/glm52-dsa-stage0-2026-08-17/`. The current
correctness scaffold has now been replaced by Stage 1's production-shaped
device path.

**G6R Stage 1 complete:** score accumulation is tiled `[H,D] @ [D,L]`, the
deterministic uint64 device top-k preserves Colibri's threshold/lower-position
tie contract, and one 8 KiB FULL index buffer is borrowed by SHARED MLA layers
without normal-path host copies or re-uploads. Random, tied, all-equal,
2,049/2,048, borrowed-gather, and 21/21 captured official score rows pass. A
fresh live model run reproduced all 21 prior selection vectors, greedy
`[264,264]`, and byte-identical decode logits; tiled score accumulation moved
nine diagnostic thresholds by at most 3.05e-5 without moving a boundary. Warm
model-free score+top-k medians are 0.929 ms at 8K and 1.269 ms at 32K; these are
component numbers, not end-to-end claims. Evidence:
`~/.cache/mlx-bun/evidence/glm52-dsa-stage1-2026-08-17/`. Plan and source audit:
`docs/archive/investigations/indexshare-performance-spike.md`.

**G6R Stage 2 complete:** the quiet-machine direct-library matrix completed 24
eligible fresh-process cells: 2K/8K, DSA off/on, MTP off/on, and three repeats,
with cold and warm turns in each process. All cold/warm, repeat, and MTP token
gates are exact. The 12 planned 32K cells are recorded as contract-ineligible:
the exact planner requires 27.320 GiB MTP-off and 28.540 GiB MTP-on, both above
G5's 25 GiB process ceiling. At 8K without MTP, DSA improved paired median
decode throughput 12.38% but total wall time only 1.89%, below the 5% product
gate. With MTP, DSA slowed decode 34.33% and increased total wall time 8.19%; it
also reduced the deterministic MTP trace from 3.2 to 2.286 tokens/target
forward. The result is therefore negative for product performance. The exact
21F/57S schedule remains required model semantics; sparse prefill is deferred,
and no prefill or end-to-end speed claim is made. Evidence:
`~/.cache/mlx-bun/evidence/glm52-dsa-stage2-2026-08-17/`; manifest SHA-256
`90b3fe4ed53714604b7a747991b3bb1b87aedbf57a139915065f5b4be42cda38`.

**G7a compressed persistence complete:** the existing v3 `kv-store` format
remains backward-compatible and now discriminates target `mla`, target
`mla-dsa`, and native `mtp-mla` rows. It streams only compressed latent, RoPE,
and owning-layer DSA tensors; clone, prompt-cache bytes, SSD restart scanning,
trim eligibility, atomic async writes, verified copy-restore, and exact offsets
all use that state without reconstructing full K/V. Restore validates model id,
config/tokenizer metadata, cache role, and exact GLM geometry before opening the
tensor mmap. Tiny-model forks prove uninterrupted versus restored target hidden
state and offsets at two prefix lengths, while a restored MTP row produces the
same next draft sequence and offset. The focused GLM/kv-store/SSD gate passes
42 tests with 881 assertions.

**G7b continuous batching complete:** GLM's checkpoint-native cache now exposes
a structural dynamic-row capability with logical offsets, right-justified
latent/RoPE/DSA tensors, exact compressed-byte projection, merge, independent
extraction, filtering, and context bounds. Mixed-length batched DSA hidden
states and extracted tips match serial rows exactly. The streamed async path
receives the live `[B,1,H]` batch and constructs one cross-row expert plan;
scheduler coverage proves join, cancellation, sibling completion, filtering,
and exact admission bytes. Gateway and `GET /stats` report the actual
`off`/`serial`/`batch` capability mode. Requests with native MTP continue to
route serial by the explicit `hasDraft` contract; per-row batched MTP remains
post-release. The broader GLM/persistence/gateway gate passes 115 tests with
1,701 assertions. G7c implementation follows below.

**G7c serving parity is complete:** the
generic `generate()` path now awaits streamed expert layers, and the bounded
Colibri opener is wired through `openModel`, `loadContext`, `serve`, embedded
`pi`, and one-shot `generate`. GLM's native MTP row mounts by default through
the serial speculative lane (`--mtp off` enables ordinary batching); the
native `arg_key`/`arg_value` tool format parses; `/v1/models` explicitly marks
unsupported embeddings/vision/audio/adapters/training false; and `/stats.glm52`
reports the exact pre-open resource equation. Tiny streamed-model HTTP tests
cover chat/text completions, Anthropic Messages, Responses, SSE, discovery,
and native MTP. The fresh real-artifact CLI gate then passed under the exact
25 GiB contract: health, discovery, and stats were correct; chat completions,
text completions, Anthropic Messages, Responses, and SSE all returned HTTP 200
with their correct envelopes; SSE ended in `[DONE]`; and chat/SSE reported the
live `serial+spec` lane. Post-run telemetry returned to zero active/pending rows
with the 21,352,663,936-byte plan inside the 26,843,545,600-byte limit.
The final focused static/synthetic sweep passes TypeScript, diff hygiene, and
152 tests with 2,536 assertions; the refreshed full code graph covers every
operated G7c source/test file (18,774 nodes, 81,629 edges, zero skipped files).

## Where we are (2026-07-10 — v0.0.11 released)

**v0.0.11 is live on every distribution channel.** PR #29 merged the
final release notes and reference-doc accuracy sweep into main; CI and
CodeRabbit were green. The Developer-ID build passed its binary/pi smoke,
was signed and notarized (submission `434ac11a-09c3-4f74-94dd-bb9fdf94f793`),
and shipped as both versioned and stable-name GitHub assets with SHA-256
`e9178d264a375694ed1b704eb2b9f717b91e40038781f874c9ec015619ac64e5`.
The `joshuarossi/homebrew-tap` formula and npm `mlx-bun@0.0.11` are live;
the in-repo formula is synchronized in the release follow-up commit.
Release notes: [docs/archive/planning/release-notes-v0.0.11.md](docs/archive/planning/release-notes-v0.0.11.md).

Still owed (all opt-in surfaces, judged non-blocking for the release):
paged-kv try-body temp leaks + GRAMMAR_JUMP×paged-kv verify-or-refuse;
write-behind max-defer design decision.

## Where we were (2026-07-07, later — review sweep over everything landed + in flight)

**Four-agent review pass (docs drift / defaults+serving path / web-chat
worktree / paged-kv worktree), fixes on branch `josh/review-sweep-0707`.**
Two CONFIRMED serving bugs found and fixed: (1) grammar controllers
compiled before the reject paths leaked their WASM matcher on EVERY
early 400 (both API surfaces; attacker-loopable via `response_format` +
an SSRF-blocked `image_url`) — every pre-run reject now disposes, and
`GrammarController.dispose()` is idempotent; (2) the documented grammar
degrade path (prompt injection + Warning header) was dead code since the
feature landed — `compileGrammarRequest` dropped its `degradeHint`, so
malformed grammars served 200 unconstrained with no Warning; now
reachable and re-pinned in tests. Plus: `MLX_BUN_SSD_SPILL_QUEUE_GB=0`
un-coerced, refuse-loudly warnings for silently-ignored flag combos
(ssd sub-flags / --model-pool / --ngram-*), stale default-comments fixed,
docs drift closed (8 findings — far cleaner than the 2026-07-03 sweep),
openwiki-evaluation investigation landed. Full report + the worktree
findings: `reports/review-sweep-2026-07-07.md` (local). Web-chat tranche:
2 confirmed findings, the big one being the wrapperless tool-call repair
that can EXECUTE JSON-shaped assistant CONTENT as a real tool call —
owed before that tranche commits. Paged-kv was reviewed PRE-merge
(REDIRECT verdict); the merged v1 (below) addressed the
record-engagement + refusal-gate items — still owed from that review:
two try-body temp leaks (paged-kv.ts gather/updateAndFetch throw paths)
and a verify-or-refuse for `MLX_BUN_GRAMMAR_JUMP` + `--paged-kv`
(jumped spans can overflow the exactly-`prompt+maxTokens`-sized pool →
mid-request 500). OPEN design decision: write-behind flush has NO
max-defer — a continuously busy server never flushes (SpillQueue pins up
to 2 GB through exactly the loaded window; restart survival degrades to
nothing under sustained traffic).

## Where we were (2026-07-07b — optional paged KV cache v1, `--paged-kv`)

**`PagedKVCache`/`BlockPool` landed behind default-off `--paged-kv`**
(docs/design/paged-kv-cache.md — plan produced by a multi-agent design
pass, judged synthesis of 3 proposals): vLLM-style block-pool storage
for full-attention layers, host-side block table, `takeAxis` gather to
contiguous before the UNCHANGED stock SDPA (no new kernel, no new FFI
binding — the plan's proposed `mlx_gather` binding proved unnecessary).
Scope v1: serial batch=1, Gemma4-family, bf16; CLI pins `--batch 1`,
createServer REFUSES `--batch N>1`/`--kv-quant`/`--draft-model`; paged
requests bypass the prompt cache and run uncompiled decode (automatic:
`PagedKVCache` is deliberately not a `KVCache` subclass, so every
instanceof gate excludes it — the TurboQuant pattern). Gates:
tests/paged-kv.test.ts (model-free storage-layout parity incl. block
boundaries + trim/regrow + typed pool exhaustion) and
tests/paged-kv-parity.test.ts (12B: single-forward logits BIT-EXACT,
48-token greedy trajectory IDENTICAL, paged-on vs paged-off).
Honest framing: at batch=1 the gather is pure bandwidth tax — v1 is the
correctness-proven rung-3 abstraction (parallel-slots.md updated);
the payoff (batched block allocation, block-CoW prefix sharing, fused
paged kernel) is the documented follow-up chain. This does NOT reverse
the 2026-07-07 mining-pass rejection (paged-as-prompt-cache) or
ssd-kv-cold-tier D1 (paged SSD spill) — different axes, reconciled in
the design doc. **Next:** quiet-machine perf disclosure via
benchmark.sh (paged-on vs off, 12B/e4b) → benchmarks/RESULTS.md.

## Where we were (2026-07-07 — two vLLM-inspired serving features: ngram drafter + grammar jump-forward)

**Both landed with gates + reference docs, from a vLLM-mining pass that
first killed three other candidates against the code** (chunked-prefill
interleave: already built; paged KV: physical sharing already exists via
take()'s zero-copy view clones + paging explicitly rejected in
ssd-kv-cold-tier.md D1; block-hash prefix keying: our token-granular LCP
is strictly finer). The two that survived:

1. **`--draft-kind ngram` — MODEL-FREE prompt-lookup speculative drafting**
   (src/spec/ngram-source.ts; port of Saxena's prompt-lookup decoding /
   vLLM's `ngram` proposer — longest-k-first, first occurrence). No
   artifact, no dir: drafts are copied from the request's own
   prompt+generation; the shared verify makes it lossless at any
   temperature; a no-match round degrades to one plain step. Directly
   answers the DSpark drafter-tax finding (τ≈2.8 eaten by a 6.9 GB bf16
   drafter — this drafter is free). The subtle part is token-history
   reconstruction from the seam's feed/commit discipline (an all-accept
   round's last draft arrives via the NEXT feed — mlx-lm's re-feed rule);
   pinned model-free in tests/spec-ngram.test.ts. **Real-weights gates
   GREEN on this box: serve-loop ngram spec TOKEN-IDENTICAL to non-spec
   greedy on e4b (γ=3 and γ=10, tie-free prompt) + echo prompt lands
   accepts.** Flags: `--ngram-max/--ngram-min` (3/1), `--num-draft-tokens`
   defaults 10 for this kind; mounting it WITH `--draft-model` (or another
   kind without one) refuses at load. Docs: cli.md, server-config.md,
   features-matrix.md.
2. **`MLX_BUN_GRAMMAR_JUMP=1` — jump-forward decoding for structured
   output** (opt-in Lab lever, serial lane): xgrammar's
   `findJumpForwardString` (shipped in our WASM build, previously
   uncalled) + a generate() jump iteration that carries grammar-forced
   spans into the KV with ONE multi-token forward instead of per-token
   masked forwards. String-lossless + always grammar-valid; the token
   stream may legally differ (retokenized forced spans) → opt-in, no
   oracle. Partial-accept keeps matcher/emitted lockstep with no rollback;
   SP-family raw-encode mismatch degrades to normal decode (never invalid
   output). Gated: tests/grammar-jump.test.ts (contract + Llama-3.2-1B
   e2e on/off). Batch-lane #stepGrammar deliberately doesn't jump yet.
   Design: structured-output.md 2026-07-07 addendum. **Drive-by fix found
   by its tests: disposing a GrammarController with a queued bitmask fill
   called into the deleted WASM matcher and poisoned the module-wide
   wasmChain (BindingError) — fireFill() now no-ops after dispose (latent
   for any exception between accept() and ready(), both lanes).**

Open follow-ups from the same pass (small, backlog): mid-flight
preemption (demote a running row's KV to the SSD tier to admit a
higher-priority request — the restore primitive exists, only an idleness
trigger today); ngram + jump-forward composition cells in
bench-feature-matrix on a quiet box.

## Where we were (2026-07-07 — merge wave landed + post-merge review fixed; drafter-quant Phase 1 code done)

**All three threads merged within hours: PR #18 (bench residuals), PR #19
(DSpark spec decoding), PR #20 (TurboQuant KV).** A 4-agent post-merge
review over the union found and FIXED same-day: (1) CRITICAL — the
TurboQuant bit-pack/unpack helpers leaked window-scale GPU buffers per
decode step (bare `split().map(reshape)` + or-chain reassignment; measured
~8.4 MB/call at 2k ctx → OOM within dozens of tokens; splitLanes + orInto
now dispose, regression test at window scale); (2) `--kv-quant turbo` +
`--draft-model` silently dropped turbo (spec eligibility gate now excludes
turboQuant like the affine axes + startup warning); (3) turbo state()
try/finally on the eval chokepoints. The two #18-thread operational
findings are ALSO FIXED (same day): the write-behind snapshot timer now
carries demoteIdle's activity guard (re-arms while rows are active instead
of registering a serial waiter that froze batch admission), and pending
spill clones go through the new bounded `SpillQueue` (kv-store.ts; 2 GB
default cap, `MLX_BUN_SSD_SPILL_QUEUE_GB`, drop-oldest with immediate
clone disposal, `/stats.ssd_cache` pending/dropped counters;
no-shutdown-flush documented as accepted in ssd-kv-cold-tier.md's
2026-07-07 addendum). The error-path leak batch is ALSO drained (same
day): samplePos try/finally (grammar-reject orphaned a [1,V] row/hit),
spec caches+source allocated inside the try + loadContext PROBE-OPENS the
(target, drafter) pairing at startup (mismatch now refuses at load, not
500-per-request), loadKvCache pending[]-drains mid-entry orphans under
--ssd-cache-verify (regression test: repeated corrupt-file loads, flat
active memory), and the batch-scheduler quantized-rotating join no longer
takes the unused bf16 temporalView (6 arrays/join, pre-existing from
859572d). The robustness triple is CLOSED too: turbo head-dim validated at
createServer (was a per-request 500 mid-prefill for unsupported dims),
StreamDecoder's revised-text path is a truncate-safe resync + once-per-
stream warning (was whole-stream duplication for future cleanup-rule
tokenizers; regression-tested with a fake cleanup tokenizer), and the
two-model draft prefill drains in PREFILL_CHUNK=2048 chunks like its
oracle (was one unchunked forward — a 32k prompt ran a 32k-position
draft forward). **DSpark serving program
Phase 1 CODE is done** (1a quantize script, 1b quantized drafter forward,
1c acceptance A/B harness — all tested); 1d awaits Josh's GPU run:
`bun scripts/dspark-quantize-drafter.ts <bf16-drafter-dir>` then
`bun scripts/dspark-drafter-ab.ts --target gemma-4-12B-it-OptiQ-4bit
--drafter-a <bf16> --drafter-b <q4>`.

## Previous (2026-07-07 — decode@ctx gap closed: SSD write-behind flush is now idle-gated)

**The bun arms' decode@ctx losses in the 07-07 bench (e4b −9.3%, 12B
−3.9% vs mlx-lm, while short-ctx decode won on every model) were
SELF-INFLICTED CONTENTION from the --ssd-cache write-behind flush, not a
kernel gap.** The "non-blocking" flush (storeAsync on ssdWriteChain) was
only non-blocking at the event-loop level: every per-tensor step is
`ops.contiguous` (a kernel on the SAME GPU stream decode uses) →
`rawBytesView()` → a synchronous `mlx_array_eval` that blocks the JS
thread until the stream drains → a synchronous multi-MB `writeSync`, and
the `setImmediate` pacing interleaved those slices exactly between decode
tokens. The bench's decode@ctx is the median of {cold, rep1, rep2}; the
debounced ~16k-entry flush (0.4–1.1 GB bf16) lands exactly on the cached
repeats. Only bun arms carry --ssd-cache — mlx-lm runs no equivalent
background work. Internal control in the bench data: the mixed arm (4×
smaller flush bytes) BEAT both bf16 arms at decode@ctx. Reproduced
standalone (e4b, 9.5k-token entry, busy box, directional): pre-fix rep2
37.9 vs cold 47.1 tok/s (−20%); post-fix flat 45.6/44.3/45.3, restart
survival still PASS (cached=9575 after kill+respawn); the
MLX_BUN_SSD_WRITEBEHIND=0 control is equally flat (43.4/43.6/47.1 —
gated ON ≈ OFF, the gate leaves nothing on the table) with restart
cached=0, by design. Fix
(`src/serve/generation-gateway.ts`, `src/kv-store.ts`, `src/ssd-cache.ts`,
`src/server.ts`): `gateway.busy`/`onIdle()` cover BOTH lanes (the serial
lane holds the mutex but shows zero rows — activeRows alone was blind to
it); `saveKvCacheAsync`/`storeAsync` take a per-step `waitTurn` gate
awaited before EVERY tensor (a request arriving MID-flush pauses the
remaining tensors); both chain sites (write-behind snapshots AND
eviction/demotion spills) pass `() => gateway.onIdle()`.
`MLX_BUN_SSD_WRITEBEHIND=0` disables write-behind snapshots entirely
(kill switch + paired-A/B lever, server-config.md). Accepted tradeoffs
documented in ssd-kv-cold-tier.md's 07-07 scheduling-contract addendum
(durability waits for a quiet moment; spill clones' GPU release deferred
while busy, bounded by the chain). Final vs-mlx-lm decode@ctx numbers
need the quiet-machine bench rerun (loadavg was ~4–7 throughout; a
residual genuine kernel gap at 16k is not excluded — xctrace on quiet).

## Parallel thread: web chat redesign (2026-07-06/07, branch feat/web-chat-phase2)

[docs/design/web-chat-redesign.md](docs/design/web-chat-redesign.md) is the
working UI plan (supersedes web-ui-pass-plan.md; revised 2026-07-06 to the
**superset doctrine** — concede nothing, differentiate on top — with
[web-chat-beat-matrix.md](docs/design/web-chat-beat-matrix.md) (12 axes,
116 rows, MATCH/BEAT/SKIP) as the coverage contract, §6.6 the app-aware
assistant, and principle 9: the bar for done is perfect visual polish).

**Phases 0, 1, AND 2 are done + visually QA'd on this branch, rebased on
post-merge main (PR #18/#19/#20).** Phase 1: block-memoized streaming
render + vendored hljs; per-turn `lane` → live perf strip (verified live:
"230 tok/s · TTFT 292ms · BATCHED"); full sampling popover w/ per-model
defaults; message actions (regenerate/edit-as-sibling via navigateTree);
mobile drawer, light theme, Cmd+/ sheet; gc endpoints; /v1/models
tier+vision+gen_defaults. Phase 2 (248a85d): app.html's inline script →
12 typed modules (type-only WS-contract imports from pi-web; generated
committed src/web/app.js + freshness gate; tsconfig.web.json; happy-dom
harness incl. streaming-parity fixtures); /api/memory/* REST + POST init
(confined to vaultRoot/tmpdir after review caught arbitrary-path git-
commit exposure); Memory panel (vault browser, git History+diff view,
Reference docs, provenance chips, personalized hero, consent card —
full flow verified live on a scratch vault); adapter routing table
(three-state + ramBytes + "a+b" stacking test-proven); model picker w/
/fit verdicts (live swap deferred to Phase 3 Hub); per-chat system
prompt (before_agent_start layering) + presets v1; approval gate wired
(codingTools opt-in, editable args via SDK event.input mutation,
durable ~/.mlx-bun/tool-approvals.json); Developer IA toggle; "#"
mention. Lane semantics re-verified against merged DSpark GenerateStats.
Visual QA (3228734) fixed a placeholder-wrap regression + .bubble-scoped
markdown chrome missing in the panel. Follow-ups: # mention doesn't
search Reference/ docs; wikilink graph view (plan §5.5) still line-only.
**Phase 3 done + visually QA'd, rebased through main@ca0ba91 (PRs
#21–#27 incl. the audio-capability ready-frame union).** Files-RAG v1
(client BM25, [n] citations, Sources panel); Model Hub (/api/hub/* w/
real /fit verdicts; live swap honestly deferred — the isolate proxy
501s /ws/chat); Canvas v1 (allow-scripts-only iframe, verified live);
self-healing tool calls (format-aware repair in OUR parsers + envelope
guard after a critical review catch — bare-JSON replies can't execute
as tools); set_sampling scope:"next_turn"; **app-aware assistant v1
verified live: "take me to quantize" navigated the real app via
navigate_app** (§6.6 never-hijack spotlight, ambient context line,
catalog-validated tools); Cmd+K palette (live); full-text session BODY
search (live over HTTP); MD/JSON export; PWA manifest+sw (200s).
Phase-3 follow-ups: RAG [n]-citation compliance unproven on 1B-class
models; spec-lane badge demo needs a compatible draft artifact;
history-replay citations need a HistoryItem field. Next: Phase 4
(plan §9 — trust & speed: temporary chat, disk-touch tally, cache-hit
telemetry, logprobs overlay, HLG in composer, ambient assistant panel
+ process-state snapshot maturity).

## Where we were (2026-07-07 — 12B completion-probe parity closed: prefill tail split)

**The 12B completion-probe parity ✗ (07-07 bench @3d56676, diverged at
char 24 in the degenerate "1111…" stream) was a STEP-0 PREFILL-CONVENTION
mismatch with the oracle.** mlx-lm 0.31.3 — BOTH its routes — prefills the
prompt only to len−1 and computes step-0 logits from a separate **L=1
forward of the last prompt token** (serial `generate_step`: drain loop
`while total−processed > 1`, then `_step(prompt)`, generate.py:430-453;
the server's batched engine: `insert_segments` forces a final 1-token
segment + `GenerationBatch._step` forwards `inputs[:, None]`,
generate.py:1645/1182/1327). We forwarded the ENTIRE final chunk and
sampled step 0 from its last position — the same token at L=1 (qmv +
vector SDPA) vs as the tail of an L=n GEMM (qmm + L-dependent SDPA) is
ulp-different in bf16 in BOTH the step-0 logits and that token's stored
KV; near-tie greedy streams flip (12B flipped at step 24 — reproduced
with per-step top-2 logprob dumps, scripts/experiments/step0-top2-dump.ts
vs the oracle transcript). Fix: generate.ts + batch-scheduler.ts
`#prefillChunk` now drain to len−1 (chunks of `min(chunkSize,
remaining−1)`) and step-0 is an L=1 forward — bookkeeping unchanged
(after step 0 the caches cover exactly the prompt, as before);
`MLX_BUN_PREFILL_TAIL_SPLIT=0` is the kill switch (server-config.md).
Verified: 12B AND cpm5 CLI-route A/B vs oracle = 64/64 token ids AND
top-2 logprob values IDENTICAL, first diverging step NONE; serve-level
HTTP probes (scripts/experiments/serve-parity-probe.ts) = completion +
chat probes byte-IDENTICAL vs live mlx-lm servers for cpm5, e4b, AND 12B
on both bun arms (unified + --batch 1). (The e4b cells were initially
asserted without a recorded run — the completeness audit flagged it; a
recorded probe run landed 2026-07-07: all four e4b cells IDENTICAL,
completion 384 chars / chat 258 chars, prompt_tokens 6/6 + 32/32.)
Fallout re-anchored: mixed-KV
golden composition now mirrors the oracle serve loop (prefill ids[:-1] →
convert → L=1 step-0; regen-mixed-kv-goldens.ts + both goldens regen'd on
this box) — gate 1's step-0 GEMV-vs-GEMM argmax anchor is RETIRED (strict
bit-compare passes, incl. batched B=1); gate 2's padded-row KL envelope
recalibrated 5e-2→2e-1 (deterministic 1.21e-1 at K=6, the documented
join-geometry threshold-effect amplitude; unpadded row stays bit-exact
incl. step 0); generated-parity's compiled-lane dispatch count is now 1
(the L=1 step-0 legitimately rides the generated quantized fast path).
Pre-existing failures on this box, NOT this change (stash-proven at
baseline): kv-quant.test.ts ×3 + parity.test.ts (stale machine goldens —
regen chip spawned), batch-grammar B=4 (chip spawned), batched extend-join
oracle (known). Spec-decode serve lane re-anchor: **DONE 2026-07-07,
merged in PR #19** — and its oracle's true shape turned out to be
MORE than tail-split: `speculative_generate_step` drains BOTH models to
len−1 with **no separate step-0 at all** (the un-drained last prompt token
heads the first verify window; an L=1 step-0 is still ulp-different from
the (1+γ)-window GEMM head and flipped a knife-edge). The live gate also
caught a pre-existing bug: an EOS accepted AS A DRAFT leaked through
onToken as content. Both fixed; gated 4/4 token-for-token vs the oracle
venv (templated prompts, γ∈{2,3}, pinned in tests/spec-serve.test.ts "L1
knife-edge"); the optiq-oracled standalone `specGenerate` deliberately
keeps full-prompt prefill (per-scheme-oracle doctrine — optiq's own
convention, read from the installed source). Goldens on the M4 Pro
reference box need the same regen when work moves there.

## Where we were (2026-07-07 — cpm5 completion-probe parity closed)

**The MiniCPM5 completion-probe parity ✗ (07-07 bench, diverged at char
249: trailing `" "`) was a DETOKENIZATION artifact, not logit
divergence.** The 64-token greedy streams are identical; the
max_tokens-final token is the bare-space token `Ġ` (id 242).
mlx-lm 0.31.3's `BPEStreamingDetokenizer.add_token` WITHHOLDS a
single-char byte-32 token in `_unflushed` ("For single spaces wait until
the next token", tokenizer_utils.py:206-218) and `mlx_lm.server` NEVER
calls `finalize()` (zero hits) — so mlx-lm silently DROPS a genuinely
generated token's text when generation ends on a bare space; our
full-sequence StreamDecoder kept it. Fix: StreamDecoder now mirrors the
serve semantics for ByteLevel tokenizers (`LoadedTokenizer.
bareSpaceTokenId` = vocab["Ġ"]): push(bareSpace) emits nothing, the next
token's delta carries the held run, flush() drops a trailing run.
Verified END-TO-END over HTTP: our server (batch 1 AND batch 8) now
renders bytes IDENTICAL to a live mlx_lm.server on the same snapshot
(249 chars, `…numbers greater than`). Model-free regression tests pin
the served id stream (tests/serve-detok-parity.test.ts); suite +
whole-repo tsc 0 green. Two durable observations: (1) upstream-worthy —
mlx_lm.server drops served text on a final bare-space token (its own
stream_generate+finalize path disagrees with its server path; candidate
lab/repro + upstream report). (2) mlx-lm's greedy stream is
ROUTE-DEPENDENT at bf16 near-ties: its CLI route (stream_generate,
full-prompt GEMM step 0) picks "focuses on" at step 50 where its OWN
server route (BatchGenerator prompt[:-1]+[last] split) picks "deals
with"; our serve matches its serve — serve-vs-serve is the contract.
Latent hazard flagged in code: clean_up_tokenization_spaces=true BPE
models have an extra mid-stream `_space_matches` rule we don't emulate
(both current BPE targets are false). No served-surface change → no
reference-doc edits.

## Where we were (2026-07-07 — A7 closure: ssd-cache RSS)

**A7 ("ctx/restart legs read high on --ssd-cache arms") root-caused in
three parts and closed** (src/kv-store.ts; fixed against the 07-07 bench
at 3d56676). (1) WRITE residual — the v3 streaming writer's per-tensor
`rawBytes()` ended in a JS-heap `.slice()`; dead copies outlive the flush
under GC lag. Now hashes/writes from a ZERO-COPY view of the contiguous
mlx buffer (`MlxArray.rawBytesView`); save allocates no JS-heap copies at
all and 0 extra mlx bytes for contiguous sources. (2) RESTORE — the
zero-copy mmap wrap became a per-restore PROCESS-LIFETIME mapping leak
after the 07-06 FFI-dtor fix (retainMmapForProcess — now DELETED), and
exact-offset-sized restores made the first decode step concat-copy the
whole entry. Restore is now a STREAMED COPY (`fromBytesCopy` per tensor +
`MADV_DONTNEED` + unmap-before-return; plain-KV lands in STEP-rounded
capacity with slack): measured peak = live entry + ONE tensor (552 vs
520 MB on a 512 MB synthetic), vmmap-clean, 12B cold cache-load→first
token 277 ms (parity with the old ~240 ms). Copy-restore byte identity
pinned for all five cache kinds (save→load(verify)→re-save
hash-identical, tests/kv-store.test.ts) + real-model bf16/quant/SSM
continuation suites green. (3) NOT a defect — most of the benched leg
delta is `ps` RSS ACCOUNTING: the write-behind's hash+write CPU-touches
the live KV entry and makes already-allocated unified-memory pages
visible (GPU-written buffers and python-arm KV never show in ps RSS —
proven with mlx active/peak counters + footprint probes). bench-serve.ts'
hardcoded "fix A7 pending in src" note replaced with the accounting
footnote. Docs: ssd-kv-cold-tier.md addendum, server-config.md restore
rows. Residual: quiet-machine bench rerun for quotable before/after legs.

## Where we were (2026-07-06, round 2 — finish-the-list)

**Everything on the open list is closed** (PLAN.md "finish-the-list"
phase; suite 1127/0, parity suites green on every change): e4b long-ctx
prefill at parity via the causal-mask fidelity fix (makeMask now hands
mlx the string "causal" for windowless multi-token chunks at any offset,
matching mlx-lm cache.py:114-125 — 872 vs 877 post-fix, was 845-862 vs
878); incremental tokenizer encode (16-59x on conversation appends,
exact via seam verification); SSM per-row extraction for Qwen3.5
hybrids; the last JS-callback buffer dtor eliminated (fromView →
native dtor + explicit JS-thread unpin); eviction-spill and demoteIdle
non-blocking (SpillSink clones + storeAsync chain); Phase-2 host-tax
worklist audited down to three real items (12B KL-max outlier, CPM
extend-join golden regen, padded-B>1 mask rebuild pending a
forced-padding A/B). Final full h2h: benchmarks-serve-2026-07-06e.

## Where we were (2026-07-06, round 1)

**Serve-bench defect sweep (2026-07-06, this session):** the 07-06 serve
h2h (valid — quiet machine) surfaced five defects; a 20-agent verified
investigation reduced them to root causes and the fixes landed together:

- **FFI deadlock/crash (the "cpm5 serial timeout" — a real product bug):**
  `MlxArray.fromPointer` registered a bun:ffi JSCallback as the mlx buffer
  dtor; mlx releases the LAST Data reference from the **Metal completion
  thread** (gpu::eval retains buffers until the command buffer finishes),
  and a JS callback invoked there deadlocks serving (completion waits on
  JS, JS blocked in `mlx_async_eval`) or SIGTRAPs mid-GC. Repro'd
  deterministically (SSD-restored KV + streamed request), fixed with a
  native no-op dtor (`dlsym(free)`, payload 0) + process-lifetime pinning
  of restore mmaps (eager unmap-after-dispose was unsound — mlx can hold
  pages past dispose). `fromView` (expert-offload only) still carries the
  JSCallback — flagged hazard. NOTE: bun:ffi symbol `.ptr` returns the
  address bit-cast to float64 (lab/repro/bun-ffi-f64) — use dlsym.
- **Gemma prompt cache dead / restart-0 (one invariant, three tiers):**
  mlx-lm guarantees a trim-free `prompt[:-1]` entry for every request
  (insert_segments' last-token split) and makes insert+fetch
  untrimmability-aware; we had that in one tier of three. Landed: serial
  boundary cap `min(stableLen, len-1)` + `snapshotAt` plumbed so the hook
  fires mid-prefill (A1); batch-lane boundary snapshot via a
  chunk-split at the boundary (A5 — fixes 12B batched 84s ctx repeat);
  SSD supersede trimmability guard + usability-aware `find()` +
  header-derived trimmable flag (A2/A4); write-behind debounce keyed by
  ns+length so the final put can't cancel the boundary write (A3);
  unconditional exact-duplicate dedupe in RAM `put()` (A6); loud logs on
  every silent-degrade path (A8). Unit-tested (prompt-cache/ssd-cache).
- **RSS:** `saveKvCache` streams per-tensor now (format v3, fixed-width
  hashes; v2 files self-invalidate) — the write-behind no longer spikes
  RSS by the whole entry (A7). Prompt-cache default cap is now
  8 GB flat (Josh's call), overridable via `--prompt-cache`.
- **Bench harness (B1-B4):** per-phase AbortSignal budgets scaled from
  measured tps (the two vanished arms were Bun's implicit 300s fetch
  timeout), phase-tagged failures that keep measured cells, child stderr
  tails, /v1/completions engine-parity probe + pinned `enable_thinking`
  chat probe (template drift no longer renders as fake "diverged at char
  0"), per-leg RSS attribution.
- **Mixed-KV "prefill loss to optiq" was FAKE — and the arm is now off
  the default bench:** LIVE-verified (runtime spies + a crash repro):
  optiq serve's KV-quant is inert on mlx-lm 0.31.3's batched path (all
  seedless requests = bf16), and seeding is NOT a workaround — a seeded
  request quantizes into the shared prompt cache and the next batchable
  request crashes the worker (`QuantizedKVCache does not yet support
  batching with history`). So the optiq-mixed HTTP arm just re-benchmarks
  mlx-lm bf16; it's removed from the default arm set (resurrectable via
  --arms). Mixed-KV perf compares mlx-bun-mixed vs mlx-bun; correctness
  stays on script-driven optiq goldens (the L2 oracle, which DOES
  quantize). lab/repro/optiq-mixed-kv-inert has the upstream ISSUE draft
  (one open question flagged: which converter fires on the seeded path).
  Our ~33% mixed-vs-own-bf16 long-prefill cost is scheme-intrinsic
  (lever: upstream quantized_matmul split-K). RESULTS.md annotated.
  Also learned: `ps` RSS is BLIND to python-mlx KV memory (measured flat
  through a 12k prefill) — never use RSS as a quant/memory signal for
  the python arms.
- **Rerun DONE same day (benchmarks-serve-2026-07-06b + 06c splice):**
  all fixes verified at full scale — e4b warm 80ms/657 (was 1346/4), 12B
  batched ctx repeat 705ms (was 84.4s), gemma restarts restore in full,
  decode leads mlx-lm 14-33% across models, agg×4 up to 2.4×. 12B
  mlx-lm baseline mystery solved: plain mlx_lm.server can't load
  gemma4_unified (worker dies, HTTP zombies) — baseline runs via optiq
  register() bf16 now. Prompt-cache default 8 GB (Josh). Follow-ups:
  batched-lane per-row cache extract under real concurrency (PLAN);
  /v1 leading-whitespace surface diffs vs mlx-lm; kv-quant RSS tripwire
  false-positive on 1B models.

## Where we were (2026-07-05)

**Naked default = `--l1` (DECIDED 2026-07-05, uncommitted):** the full h2h
pass (benchmarks-h2h-2026-07-05, M1 Max 32GB) confirmed the L1 faithful
kernel set at exact speed parity with mlx-lm (1.00× cpm5/e4b/12B, decode
AND at-16k) while **no output-changing lever beat that baseline in a
paired A/B**: fused-decode 1.00×, fused-gelu +0–1%, the perf arm
0.62–0.93× on e4b (its one win, 12B @16k +6%, carried a KL WARN), and
quantized KV 5–20% slower decode than bf16 at ≤16k on BOTH stacks. So:
`applyDecodeRoute` now defaults the tier to l1 (bf16 KV, perf-kernel
default flipped OFF in code, serve/library kv default bf16); every
non-faithful kernel is opt-in via `--l2`/per-fork flags, and the
L1 baseline is the base future optimizations must beat (paired A/B) to
earn a default. Prior perf work is untrusted until re-proven against it.
Docs updated same session: server-config.md, cli.md, features-matrix.md,
README, faithful-l1-consolidation.md (superseding note).
**Benchmark harness hardened same session** (the 2026-07-05 report's
0.64×-vs-optiq "regression" was a mid-pass slow-window artifact —
refuted by the 07-04 pass's 1.05×): run-spread stability retries +
`unstable`/`stabilized` tags (pair verdicts withheld on unstable cells),
readable model names, chip/RAM machine labels, comparison-0 + lever-A/B
sections now render into the unified report, python-baseline prefill
warmup (the "816 vs 397" cpm5 prefill was compile-inclusion asymmetry),
KL verdict 24→96 steps, preflight high-CPU foreign-process check
(knowledgeconstructiond at 87% CPU was the likely slow-window culprit).

**Phase 1 deletion pass EXECUTED 2026-07-05** (unified-engine-frontier-plan
§6, all committed same day): deleted fused-decode, fused-gelu, fused-swiglu
(+ fused-mlp/steel-linear satellites), the perf kernel + frozen-oracle
scaffolding (tests, freeze script, tracked goldens), FaithfulMiniCPM5 +
MLX_BUN_CPM5_FAITHFUL, and `--l3` as a product mode (now a hard error
pointing at the plan; the Lab replaces it). Training needs NO flag
sanitization anymore. Surviving surface: `--kv-quant` (the one performance
trade-off) + `--l1`/`--l2` + bit-exact kill switches. Phase 0 measured the
batch-lane B=1 gap (cpm5 0.46×, e4b 0.72×, 12B 0.86× of serial — constant
~4–6 ms/step host tax; prime suspect: per-layer per-step mask rebuild) —
the Phase 2 closure worklist. The composition North Star (Josh): server →
optimized model → + mixed-precision KV → + LoRA → + spec decode → +
structured output → × sampling — all STACKABLE on one engine, no lane
routing.

**BENCHMARK HARNESS REDESIGNED same day (Josh: "run the correct things in
the correct ways"):** scripts/bench-serve.ts is the primary pass — REAL
CLI at REAL defaults (the scripts/serve.ts wrapper is deleted; bench-h2h's
legacy server leg repointed at the CLI too), one server per cell serving
ALL metrics over HTTP: decode (stability policy), cold/warm-cached TTFT,
prefill, long-context via ONE prefill + 64-token decode samples (never
"generate 16k to measure 16k"), agg×4 concurrent, ready-time. Context
recorded from measured usage.prompt_tokens. Oracle venv's console scripts
have STALE SHEBANGS (venv was moved) — python arms now invoke via the venv
python. benchmark.sh: default = serve pass (~15-30 min); --engine = the
old in-process kernel/memory/A-B matrix. Dirty-box smoke (NOT quotable):
all four arms work; warm TTFT 26 ms (ours) vs 108 ms (mlx-lm) at equal
cached tokens; agg×4 271 vs 185. NEXT QUIET-MACHINE RUN IS THE ARBITER —
including defaults-vs-defaults decode and the B=1 hop-fix verification
(cpm5 1.012 / 12B 1.005 paired post-fix; e4b reading unresolved on the
throttled box).

**MULTI-MODEL SWITCHING LANDED same day (isolation P2, task #14):**
child-per-model pool under --isolate — route by exact /v1/models id,
spawn-overlap switch (old model serves while the new loads), lossless LRU
eviction (drain → demote prompt cache to SSD → exit). Measured: switch
1.5 s, switch-back 1.2 s with cached_tokens 103/104 — conversations
survive model eviction. --model-pool N keeps N engines hot.

**RUNTIME ISOLATION P1 LANDED same day (opt-in `--isolate`):** engine =
the whole server on a unix socket (child), parent = pure reverse proxy —
zero MLX calls, instant UI under any GPU load, crash → 502 + respawn.
Measured paired: −0.4% tok/s (noise), +2 ms TTFT, per-token SSE
granularity preserved, parent 0.6 ms mid-decode. The inter-process API is
the /v1 surface itself (decision in runtime-isolation.md — deviates from
the original gateway-IPC sketch). NEXT: P2 child-per-model pool =
multi-model switching by spawn-overlap (task #14).

**PREFIX SHARING v1 LANDED same day:** PromptCache.take() serves
NON-CONSUMING zero-copy clones (ref-counted mmap retain); put() supersedes
prefix-ancestors + duplicates (trimmable-only, so boundary snapshots
survive). N agents / new sessions sharing a system prompt reuse ONE
prefill without cannibalizing each other's entries (the old consume-and-
trim flaw). Real-model gate: B served from A's entry, A's next turn still
full-hits. v1 = compute sharing + durability; single physical prefix
across concurrent rows = the paged-KV frontier item.

**`--batch` DEFAULT FLIPPED 1→8 same day (Josh's call):** every gate met —
a lone request through the unified engine is the serial engine (bits,
speed, TTFT, prompt+SSD cache), so the cap only matters under real
concurrency (the sub-agents workload). `--batch 1` pins strict serial.

**Layer 0 LANDED same day — THE SSD TIER IS NOW A PROPERTY OF THE STORE:**
tiering moved inside PromptCache.take() (ColdTier interface; server binds
SsdCacheStore+model) → the BATCH LANE restores prefixes from disk at
admission (gated E2E); onPut fires the write-behind for both lanes; idle
demotion (--ssd-demote-idle, default 300 s with --ssd-cache) spills idle
entries and frees their GPU memory — RAM drains between agent bursts,
prefixes stay reachable via zero-copy mmap. Economics: SSD competes with
RECOMPUTE not RAM (12B: 30k context ≈ 3 min prefill vs ~1 s restore).

**Phase 3 milestone 2 LANDED same day — BATCHED ROTATING-QUANTIZED KV
(gemma's kv_config now batches; every shipped kv_config does):**
BatchedRotatingQuantCache (src/model/batched-rotating-quant.ts) = the
mlx-lm batched-ring mechanics over quantized triples, subclassing
RotatingQuantizedKVCache so the L1 attention dispatch is untouched; the
scheduler converts rotating layers at the serial boundaries and merges
rot-quant twins; the gateway accepts rotating-layer configs. Gates:
model-free per-row byte-identity vs the serial oracle through ring wrap;
gemma 12B B=2 join through the real scheduler — unpadded row KL-0 at
EVERY step, padded ≤4e-3. Two hard-won contracts recorded in the plan:
a batched cache's ropeOffsetArr must be STEP-STABLE (refresh only in
releaseRopeArr — the monolith captures-then-uses-late, the GENERATED
files re-read post-update), and generated-file instanceof guards ACCEPT
batched subclasses — an all-quant gemma batch decodes through the
generated fast path (bit-exact, proven at B=1), which is also why the
bug hid whenever any single layer stayed bf16.

**Phase 3.2 LANDED same day — LONE-REQUEST = SERIAL (adopt-don't-copy +
compiled decode at B=1 + prompt cache on the batch lane):** a row joining
an EMPTY batch now ADOPTS its solo caches as the inners (pointer handoff —
the merge copy runs only when a second row joins; the merge learned to
treat an adopted serial RotatingKVCache as its first row). Because the
lone row's caches stay serial-class, (a) the scheduler replays the serial
engine's CompiledDecode step at B=1 (same runner/traces/kill switch;
gate: free-running greedy == serial generate() token-for-token on 12B,
stepsExecuted advancing), and (b) prompt-cache take()/put() works on the
batch lane (joiners restore the longest usable prefix at admission —
multi-turn chat TTFT; never-merged rows put back with exact prompt+fed
accounting; merged rows' entries age out, v1 gap noted in the plan).
**GATE-B1-SPEED decode met on all three (apple-m1-max, paired in-process
A/B): cpm5 0.996 · e4b 0.992 (was 0.93) · 12B 0.993.** All gated suites
green; full suite green PER-FILE (monolithic bun test can jetsam on a
busy 32GB box — largestProcess=bun, pre-existing; per-file loop is the
gate). Gate-2 padded-row KL proven JOIN-STEP dependent (grid-snap bin
flips; K=6→3.5e-2 vs K=7→1.5e-1, identical on pre-3.2 main, bf16 flat)
— the test now pins the join step. Docs: server-config.md rows for
prompt-cache/compiled-decode under --batch updated + website sync run.
`--batch` default flip to 8: decode+TTFT gates now met; awaiting Josh's
call after milestone 2 (batched rotating-quant).

**Phase 3.1 P1 LANDED same day — BATCHED MIXED-PRECISION KV (first on this
stack; neither mlx-lm nor optiq compose them, live-proven earlier today):**
src/model/batched-quant.ts (quantized merge/extend/filter over triples +
BatchedQuantDecodeMaskCache), scheduler converts each joiner's solo caches
at the SERIAL chunk boundaries (rows bit-exact vs serial `--kv-quant
config` by construction), gateway kv-batchability memo (all-full-attention
kvConfig batches — cpm5; uniform bits / rotating-layer configs — gemma —
stay serial = milestone 2; a scheme-less gateway REFUSES to batch kv-quant
requests rather than silently dropping quantization, the optiq bug class).
Gates green: B=1 through the scheduler BIT-EXACT vs the cpm5 optiq golden
(new golden: regen-mixed-kv-goldens.ts --model <cpm5> --name cpm); B=2
dynamic join — unpadded row BIT-EXACT vs solo every step, padded row within
the calibrated 5e-2 envelope (bf16 same-harness ~9e-3 baseline). E2E:
`--batch 2 --kv-quant config` on cpm5 → /stats active_rows 2, coherent
output, 240 tok/s aggregate for two concurrent streams.

**Phase 2 DECODE GAP CLOSED same day:** the batch lane's B=1 tax was two
bugs — `toFloat32()` on the pipeline register enqueued an astype BEHIND
the just-dispatched next step (full-step stall per token; fixed with
`MlxArray.toIntTokens()` raw reads), and per-layer per-step mask/rope
wrapper churn (fixed with the unpadded fast path: bare caches = the
serial graph). B=1 through the batch lane: cpm5 129→264 (in-process
ratio 0.994), e4b 45→57.6 (0.93, remainder = compiled decode), 12B
25.6→29.7 (1.00). Suite 1045/0 green; batched oracles 11/11 (the CPM
extend-join golden failure PRE-EXISTS — stash-proven). The Phase-3 gate
items named here (prompt cache for batched rows, compiled decode at B=1)
both LANDED in Phase 3.2 above; quantized KV under batching landed as
Phase 3.1 above.

## Where we were (2026-07-02)

**Current release: v0.0.10** (2026-07-02, shipped on all channels) —
batching parity with oMLX (`--batch 4` matches/beats on all three shared
models), SSD KV cold tier (`--ssd-cache`: restart TTFT 12.1 s → 0.24 s, 0%
decode overhead), `--model` real override in serve/bench, serial-lane
responsiveness fix (/stats 2.5 s → 10–44 ms mid-generation).
**In-tree version: 0.0.11, UNRELEASED** — structured output merged
2026-07-03 (next-action #1 below); `bun run release` ships it (also
updates the Homebrew formula, which still points at v0.0.10).

**Faithful→L1 consolidation (2026-07-04, branch `faithful-decode-parity`,
uncommitted):** the faithful (`@mx.compile` geglu/swiglu) kernels are now the
DEFAULT for every model (qwen3/qwen3.5/universal compile unconditionally; gemma
via `MLX_BUN_COMPILED_GEGLU`, default on); the custom non-bit-exact fused-gelu
Metal kernel is now opt-in. `--l1` is a pure, hand-reproducible alias (added
`--compiled-activations` + `--fused-gelu` forks, wired into the tier presets).
`MLX_BUN_FAITHFUL` and the four unwired `Faithful*` subclasses were DELETED
(`src/faithful.ts`→`src/flags.ts`); `FaithfulMiniCPM5` was kept as the A/B
reference then retired 2026-07-05 (Phase 1). Factory no longer detours gemma
through the monolith. Bit-exact vs
mlx-lm re-verified (universal/generated/gemma/cpm5 parity, tsc 0). Plan +
decision table: [docs/design/faithful-l1-consolidation.md](docs/design/faithful-l1-consolidation.md).
Open: live qwen3-dense parity (needs a box with Qwen3-Embedding) + clean-machine
bench numbers (`./benchmark.sh --redo`).

**Repo state:** main == origin/main, tree clean, tsc 0. CI is live
(`.github/workflows/ci.yml`: hygiene gate + typecheck + model-free tests —
the 2026-07-01 review's "no CI" finding is closed). The Phase C git history
rewrite EXECUTED 2026-07-02: `.git` 182 MB → **~8 MB on this box**, 497
historical goldens `.bin` purged, HEAD tree bit-identical, tags remapped,
force-pushed. B2 also closed same day: the last tracked multi-MB binaries
(fixture adapter safetensors) are untracked, sha256-pinned in
`scripts/fetch-test-fixtures.sh`; hygiene gate green with ZERO multi-MB
binaries tracked. **Remaining tail:** M4 Pro one-line reset
(`git fetch --tags --force --prune && git reset --hard origin/main`), then
delete `~/mlx-bun-mirror-backup-2026-07-02.tar.gz`.

**The 2026-07-02 session in one line:** oMLX adoption wave 1 (canonical
roadmap: [docs/design/omlx-adoption-map.md](docs/design/omlx-adoption-map.md))
+ the kernel-perf-review backlog fully resolved (every item landed, refuted,
or shelved with numbers — ledger:
[docs/archive/investigations/kernel-perf-review-2026-07.md](docs/archive/investigations/kernel-perf-review-2026-07.md))
+ repo cleanup phases A/B/C/D-gate
([docs/design/repo-cleanup-plan.md](docs/design/repo-cleanup-plan.md)).

## Next actions, ranked

1. **Structured output follow-ups** — the feature itself **MERGED to main
   2026-07-03** (was branch `feat/structured-output`, deleted after merge;
   adoption map #1 closed). `@mlc-ai/web-xgrammar` (WASM, Apache-2.0 — the
   same xgrammar oMLX uses) → per-step token-bitmask grammar-constrained
   decoding on `/v1/chat/completions` + `/v1/completions`; full
   `response_format` (json_object/json_schema) + `guided_grammar`/
   `guided_regex`/`guided_choice`/`structured_outputs` surface; L2-verified
   vs oMLX (byte-identical content through the real chat template);
   oMLX-parity degrade path (system-prompt injection + Warning header,
   never 500). Serial AND batched lanes: B0 `hasGrammar` routing + B1
   per-row matchers driven by the scheduler's read-before-build
   `#stepGrammar`, plus a module-level wasmQueue serializing ALL xgrammar
   WASM calls (the single-threaded instance corrupts under concurrent
   fills). Kill switches `MLX_BUN_GRAMMAR=0` / `MLX_BUN_GRAMMAR_BATCH=0`.
   Grammar+gateway tests 27/27 green on this box 2026-07-03 (model-free).
   Design + serial-code review + batch plan + XGrammar-2 addendum:
   [docs/design/structured-output.md](docs/design/structured-output.md).
   **Remaining work is now sequenced in the integration plan below**
   (B2+F4 = its Phase A; F5/F7 structural tags + U1/U2 parked with
   triggers).
2. **Grammar × spec × batching integration** — plan:
   [docs/design/grammar-spec-batching-integration.md](docs/design/grammar-spec-batching-integration.md).
   **Phases A, B, C, E EXECUTED 2026-07-03** (same session as the plan):
   **A** ✅ B2 batch-grammar gates (`tests/batch-grammar.test.ts`,
   `MLX_BUN_TEST_BATCH_DECODE=1`) + F4 per-TokenizerInfo compiler cache
   (single-flight) + F6/F3.
   **B** ✅ `serve --draft-model` / `--num-draft-tokens` (two-model spec,
   serial lane, `DraftSource` seam): **L1 GATE PASSED — 48/48
   token-for-token vs mlx-lm's speculative path** (Llama 3B target + 1B
   draft, 65% acceptance; oracle `scripts/oracle-spec-two-model.py`; tests
   `tests/spec-serve.test.ts`, `MLX_BUN_TEST_SPEC_SERVE=1`). `hasDraft`
   routes all requests serial under `--batch` (upstream parity); ring-wrap
   degrades to plain decode pre-pollution; prompt-cache reuse bypassed v1.
   **C** ✅ grammar×spec constrained verify walk (drafter free-running, mask
   rides the accept walk, matcher advances on emitted tokens only — no
   rollback): valid + 12/12 token-identical to grammar-only serial.
   **E** ✅ harness: `scripts/bench-feature-matrix.ts` (six cells over live
   SSE; TTFT p50/p95, agg tok/s, acceptance, 100%-conformance HARD gate;
   `usage.speculation` telemetry). Smoke-run green end-to-end on Llama
   3B+1B. **Clean-machine run for RESULTS.md "composition" = Josh-gated**
   (use CPM/e4b for real batch cells — see the Tier-0 note below).
   **The conformance gate found 3 real bugs in one smoke run** (all fixed):
   (1) `response_format`/`guided_*` were DEAD over HTTP — the resolver read
   only camelCase, the server passes snake_case (pre-existing since the
   feature landed; both spellings now accepted); (2) `#flushPipeline`
   emitted pending tokens without advancing grammar matchers →
   one-token-stale masks on every mid-decode join (regression test added);
   (3) **UniversalDenseModel batching decodes uneven rows at wrong RoPE
   positions** (scalar `cache.offset`, no per-row offsets) — LATENT for all
   Tier-0 archs since v0.0.9. **FIXED same day**: per-row RoPE ported
   (`UniversalRope.applyDynamic` + `ops.ropeScaledDynamic`), **gated
   token-exact vs mlx-lm B=2 on Llama-3.2-3B** (static uneven rows AND
   dynamic join/leave; goldens `batched-golden-llama32-3b.json` +
   `batched-dynamic-golden-llama32-3b.json`). Plain full-attention
   universal archs now BATCH (Llama matrix smoke: batch2 1.7× serial agg,
   TTFT 765→162 ms); maskArray (gemma2-family) + sliding universal archs
   stay serial (unvalidated cells). Related finding, FIXED same day:
   tests/universal-rope.test.ts fixtures were machine-specific (generated
   on the M1 Max per manifest.json's oracle stamp; 5 failed bit-exactness
   on the M4 Pro) — now machine-keyed like the goldens layer (flat set =
   m1-max reference for CI, `tests/fixtures/universal-rope/apple-m4-pro/`
   holds the 5 differing files; regen recipe in the test header). 11/11 on
   both chips; the local-oracle match also re-proves the runtime bit-exact
   per chip.
   **Phase D COMPLETE 2026-07-04** — all three items landed and gated:
   `--kv-budget` aggregate KV admission (queue-don't-OOM, oversized
   rejects, /stats.batch fields; tests/batch-kv-budget.test.ts);
   vectorized homogeneous sampling (one argmax over [B,V] for all-greedy
   batches, BIT-equal A/B vs per-row, MLX_BUN_BATCH_VEC_SAMPLE=0 switch;
   tests/batch-vec-sample.test.ts); extend-join (extendKVRows = mlx-lm
   BatchKVCache.extend semantics, one pad+concat per join instead of the
   O(B·S) re-merge, MLX_BUN_BATCH_EXTEND=0 switch; own oracle
   scripts/gen-batched-extend-golden.py — token-for-token on CPM + Llama;
   rotating-layer extend is a follow-up, Gemma joins re-merge sliding
   layers only). **The integration plan is fully executed.** Next per
   Josh's priority ranking: spec×prompt-cache composition (parity-plan
   §7.6) then prompt-cache-under-batching (perf-path P3) — the disk-cache
   track. Debug lever: `MLX_BUN_GRAMMAR_DEBUG=1`.
   **FOUND + FIXED (2026-07-04): the multi-turn prompt-cache miss.**
   12B turn-2 TTFT was 8.9 s (full re-prefill): at context > sliding
   window a hit requires an EXACT prefix (wrapped rings + quantized
   groups can't trim), and TWO drift sources break exactness — the
   assistant reply's decode→encode roundtrip, AND the template's
   generation PRIMER (12B ends prompts with `<|channel>thought` tokens
   the next turn's render never contains; found via token-level probe).
   **The fix: stable-boundary snapshot** — promptIdsFor probes the
   re-render (conversation + a fake reply) for the stable prefix;
   generate() gains `snapshotAt`/`onPrefillDone` (prefill splits at the
   boundary, fires while caches hold exactly that prefix);
   `cloneKvCaches` (kv-store.ts) makes zero-copy view clones of all five
   cache kinds; the server re-puts the boundary entry on every
   substantial request (take() CONSUMES entries, so hits must re-seed
   the next turn). **Measured: 12B turn-2 TTFT 9.0 s → 447 ms (2k) /
   19.2 s → 461 ms (4k)**; e4b intact; server-compat + grammar +
   spec-serve suites green. **Follow-up (open):** the bench's cache-ssd
   CELL still misses on 12B (RAM cap=1 forces every turn through disk;
   spill writes the files, e4b restores them, 12B doesn't — suspect
   find/restore on its mixed rotating-quantized entries); real-world SSD
   flow (normal RAM cap + restart survival) benefits from the boundary
   entries via ordinary spill. The
   12B/e4b mode-matrix results live in benchmarks-modes-2026-07-03/04.md
   (local artifacts); headline 12B: decode pinned ~24 t/s in EVERY tier
   (the wall), prefill ~260 t/s (M4 Pro compute-bound), batch4 agg 2×,
   grammar cells need a truncation-vs-nonconformance distinction in the
   bench (order-dependent FAILs reproduce as PASS in isolation).
   **Spec-decode sources (Josh directive 2026-07-04): DSpark is the GOAL
   drafter.** The Llama 3B+1B pair exists ONLY as the L1 oracle cell
   (mlx-lm can only speculate two-model, so proving the serve loop
   token-exact required that shape). Product path behind the SAME
   `--draft-model` seam (parity-plan §7.9): (1) near-term
   **AssistantSource** — the optiq KV-borrowing gemma assistant drafters
   (e4b + 12B artifacts downloaded, `src/spec/drafter.ts` bit-exact vs
   optiq; 12B γ=1 ≈ 1.09× measured) wrapped as a DraftSource (L2 oracle =
   optiq spec_generate); (2) the goal **DflashSource = DSpark** (L3,
   KL-gated) — blocked on its research milestones, NOT serve wiring:
   27B/12B retarget (regen+train), data scale (~thousands vs 160),
   draft-loop tightening (docs/archive/investigations/dspark-handoff.md).
   **Benchmarks built 2026-07-03/04:** `scripts/bench-modes.ts` (mode
   matrix: TTFT/prefill/decode/agg/peak-mem across l1/l2/l3, kv4/8,
   nocompile, batch2/4, conc-4 queueing baseline, grammar cells,
   cache-ram/cache-ssd multi-turn agent cells, spec via --draft; model is
   a param, default e4b) + docs/reference/features-matrix.md (the full
   option inventory). e4b loaded-machine shape: cold long-TTFT ~2.0 s →
   **cache-ram 125 ms / cache-ssd 231 ms**; batch4 agg 111.6 t/s vs
   serial-conc4 52.4 (TTFT p50 302 ms vs 3.8 s).
3. **Decode-speed program** — THE ranked path to faster tokens, written
   for pickup: [docs/design/decode-speed-program.md](docs/design/decode-speed-program.md)
   (2026-07-04). Baseline decode is at the bandwidth wall (mode-matrix
   confirmed the roofline); the levers, in order: **1a AssistantSource**
   (gemma assistant drafter behind `--draft-model`; artifacts downloaded,
   L2 oracle, 12B γ=1 ≈ 1.09× already measured) → **2 mlx bump**
   (qmv_wide merged upstream + gather_qmm M=1 in flight = the 26B fix;
   re-run parity + bench-modes) → **3 oQ quant spike** (~3.5 bpw at equal
   KL ≈ +10–15% decode) → **1b cheaper drafter head** → **1c DSpark**
   (the GOAL drafter, ~2–3× on 27B; blocked on its research milestones,
   not serve wiring) + §4 host residuals as filler. Scoreboard =
   `scripts/bench-modes.ts` after each lever.
4. **Menu bar app** (SwiftUI + signed binary as sidecar) — adoption map #2,
   Josh wants it; /Applications/oMLX.app is the structural reference.
5. **Batching remainder not in the integration plan** — P1 quantized KV at
   B>1 (P2 perf-kernel-at-B>1 is OBSOLETE — kernel deleted 2026-07-05), P3
   prompt-cache/adapters/default-review tail, P4 device-side step chaining
   (the cpm5 single-stream −20% counter). Superseded by the unified-engine
   plan's Phase 2/3 (docs/design/unified-engine-frontier-plan.md).
   [docs/design/batching-perf-path.md](docs/design/batching-perf-path.md);
   older queue: batching-v2-plan steps 4–10.
6. **SSD tier P4 hardening** — kill-mid-write e2e, adapter-ns isolation e2e,
   scheme-flip invalidation e2e.
   [docs/design/ssd-kv-cold-tier.md](docs/design/ssd-kv-cold-tier.md).
7. **oQ-style quantization spike** in `convert` (eval-gated; arXiv-lens).
8. **Web-UI fix wave** — 6 bugs, landing order in
   [docs/archive/planning/web-ui-pass-plan.md](docs/archive/planning/web-ui-pass-plan.md).
9. **Remaining compat verbs/flags** (`--draft-model` itself is now
   integration-plan Phase B; still open: cache_prompt, evaluate,
   awq/dwq/gptq; flags: --chat-template*, --min-p, --log-level,
   --allowed-origins, --prompt-concurrency, --prefill-step-size) —
   [docs/design/mlx-lm-tool-parity-plan.md](docs/design/mlx-lm-tool-parity-plan.md).
10. **Curve sampler H2/H3 preregistered run**
   ([docs/planning/curve-sampler-research-plan.md](docs/planning/curve-sampler-research-plan.md))
   · **dynamic-λ controller** ([docs/design/orpo-dynamic-lambda.md](docs/design/orpo-dynamic-lambda.md))
   · fit-as-recommender + memory-docs banner pass + `mlx-bun route` verb
   ([docs/planning/memory-docs-and-dag-plan.md](docs/planning/memory-docs-and-dag-plan.md)).

## Active workstreams

### Audio input — phase opened 2026-07-07 (branch `josh/audio-input`)

Audio-in/text-out through the chat API, e4b first. Survey done: mlx-lm
strips audio entirely (sanitize pops the towers, server 400s non-text) →
the oracle is optiq's internal gemma4 machinery (USM mel extractor +
12-block Conformer + embed_audio, complete but unexposed by its own serve
frontend). The local e4b OptiQ-4bit sidecar ALREADY carries all 752 audio
tensors + `audio_config` + token ids (boa 256000 / audio 258881 / eoa
258883) — no downloads. Plan + phase boxes: PLAN.md "audio input" phase,
design in [docs/design/audio-input-plan.md](docs/design/audio-input-plan.md).
**A0 DONE (2026-07-07):** conv2d bound (found + worked around a bun:ffi
stack-arg ABI bug — see CLAUDE.md hard-won facts +
lab/repro/bun-ffi-stack-args), §3.3 semantics resolved (audio strictly
causal), fixtures + oracle goldens live (speech greedy = token-perfect
transcription). A0-A4 DONE — audio is SERVED on e4b: live HTTP transcription matches the
oracle golden EXACTLY, mixed image+audio grounds on both media, serial-lane
isolation proven, docs shipped in the same commit. Capability discovery
landed 2026-07-07 (post-merge CodeRabbit follow-up): `audio` mirrors
`vision` on /v1/models, /library, and the pi ws `ready` frame —
`audioCapable` in src/registry.ts checks TENSORS not just config
(`has_audio_config AND has_audio_tower`, header-only scan), so the 12B
stub sidecar reads audio=false everywhere and clients stop probing for
400s. Remaining: A5 (quotable
bench cells need a QUIET machine — Josh-gated; 12B audio cell needs a
sidecar rebuild via optiq build_vision_sidecar — download, Josh-gated). A1 DONE:
mel port is 1-ulp-f32 from the oracle (the numpy f32 Hann window is baked
in as the spec — see PLAN.md A1).

### Batched serving — engine live, wave-1 upgraded

`--batch N` continuous batching is live for full-attention (CPM),
sliding-window (Gemma), AND Qwen3.5 (SSM batched path, token-exact vs
mlx-lm B=2 oracle; per-row logits processors killed the hidden serial
route from its default repetition penalty). `--batch 4` matches/beats oMLX
(cpm5 349 vs 339 tok/s, e4b −3%, Qwen3.5 −1%, TTFT 2–3× better). Burst
decode (oMLX's GIL trick) built and REFUTED for Bun; reverted with
breadcrumb. `MLX_BUN_LANE_DEBUG=1` for lane tracing. Remaining polish =
next-actions #3. L2 (quantized-KV batched) and L3 (perf kernels under
batching) are later, KL-gated rows. Design:
[docs/design/parallel-slots.md](docs/design/parallel-slots.md), history in
PLAN.md Phase 18.

### Training / ORPO — stack shipped; kernel backlog cleared 2026-07-02

The full stack (flash-CCE steel head fwd+bwd, segmented backward,
prefix-sharing, `sft_scope` incl. `--sft-scope` CLI flag, warm-start,
adapters-in-cache) is live — see
[docs/reference/training.md](docs/reference/training.md). 2026-07-02
kernel-review closeout (details + evidence in
[kernel-perf-review-2026-07.md](docs/archive/investigations/kernel-perf-review-2026-07.md)):
- **#1 LANDED**: coeff filter + blockMax skip default ON at 1e-5 — combined
  backward 1.71× CPM5 / 3.16× e4b vs exact, fidelity-gated.
- **#8 LANDED**: boundedSftCe — e4b M=6000 head 16.60 → 6.60 GB, dh relnorm
  0.0. Landing it exposed the upstream qmm M=2–3 correctness bug;
  workaround shipped (logitsFromHiddenPadM) — resolved, nothing pending.
  (The adjacent small-M perf cliff is already tracked upstream as
  ml-explore/mlx#3553, with qmv_wide merged post-0.31.2 — re-measure the
  pad workaround + small-M paths on the next mlx bump.)
- **#3 LANDED**: head auto-dispatch by M (MLX_BUN_FLASH_MIN_M=1024).
- **#9 LANDED**: segmented-step overhead — grads byte-identical, short-seq
  steps −34/−38%, @8K flat.
- **#2 REFUTED** by measurement (segment_size is the whole knob; seg1 =
  14.59 GB e4b @8K, fits the 24 GB M4 Pro). **#4 REFUTED** end-to-end and
  reverted. FUSED_DECODE×compiled-decode trace-freeze **FIXED**.
- Decode graph-build-overlap spike **REFUTED** — the pipelined loop already
  hides the host build; the recoverable decode gap is entirely GPU-side.

Open training items: chunk segmenter distillation (THE load-bearing run) ·
CPM5 UltraFeedback run PAUSED at step 4800 (checkpoints in
`adapters/cpm5-uf-8h/checkpoints/`, best = step-04200 val 1.5008; resume
via `RESUME=<ckpt>`, must launch from Josh's own shell — agent-spawned
runs get reaped) · e4b overnight (Josh runs it) · test gaps: DPO loss/e2e
untested (only dataset masking is covered, `tests/dpo-masking.test.ts`),
ORPO grad-parity scripts un-wired in `scripts/experiments/` (parity-orpo,
segmented-grad-test-*), DSpark smokes live in `scripts/` not `tests/`.

### THE DREAMING (local wiki memory) — ACTIVE, import paused

Works end-to-end on real data; staged resumable pipeline in
`src/memory/stages.ts`. In-process gateway landed (`src/memory/model.ts`);
memory batch default is 1 (serial, measured faster; `MLX_BUN_MEMORY_BATCH=8`
to opt back in). **Full-corpus import PAUSED at cursor 900/2096 (~43%)**
(`~/.mlx-bun/full-run-cursor.txt`), 923 articles in `~/.mlx-bun/wiki-full`;
that tree has 36 uncommitted files from the 2026-06-29 interruption (9
modified + ~27 untracked new articles; last commit = the cross-link pass) —
review/commit or reset before resuming via
`bun scripts/experiments/dreaming-full-run.ts`. Real vault `~/.mlx-bun/wiki`
untouched.
**Next:** resume import (~50 h serial) → reindex + `memory link` → cloud-judge
a broad sample → promote to the real vault + nightly fold-in. Handoff:
[docs/design/the-dreaming-handoff.md](docs/design/the-dreaming-handoff.md).

### DSpark speculative drafter — PAPER CODE-COMPLETE + SERVE-INTEGRATED + DEEPSPEC ORACLE (2026-07-06); download-gated payoff

**Phase 3 (same session): DeepSeek open-sourced DSpark** (DeepSpec, MIT +
trained drafters incl. `dspark_gemma4_12b_block7` FOR OUR 12B TARGET) — so
DSpark now has a real oracle ("if someone did it, there is already an
oracle"). Two audit agents verified our build vs the paper (arXiv:2607.05147)
+ source: our loss/backbone/Markov/confidence match the paper EXACTLY; our
scheduler matches the RELEASED reference (paper Alg-1/STS = their unreleased
production layer); our Elman RNN differs from the paper's gated cell (kept as
variant). **Their module is a different architecture** — ported faithfully
(`src/spec/dspark/deepspec-module.ts`, copy-verbatim w/ source citations;
k≡v single-KV attention, scale 1.0, partial RoPE 0.25, layer_scalar, softcap,
incremental context-KV cache), wired behind the seam
(`src/spec/deepspec-source.ts`, kind auto-detect on the `Gemma4DSparkModel`
config stamp), reviewed (7 findings fixed: bf16 sampling fidelity, conf-head
leak+precision, ~+4.8 GB transpose-copy memory, 3 silent-wrongness guards).
Enablers fixed along the way: generated gemma forwards now fall back to the
monolith when hiddenTap is set (they never captured — 12B tapping would have
thrown; generator patched too), and the seam accepts d=0 (DeepSpec ℓ=0 = plain
tapped step). Oracle scripts staged (temp-0 RNG-free trace: `scripts/
oracle-dspark-deepspec.py` → `scripts/dspark-deepspec-compare.ts`). Real 12B
tap layers `[5,17,29,41,46]` adopted (our guess superseded). **PATH A RAN
2026-07-07 (post-merge): τ ≈ 2.8 (2.7× fewer target forwards, losslessness
holding) but wall-clock −3.4× — the 6.9 GB bf16 drafter's own tax. The
follow-up program is fully planned:
[docs/design/dspark-serving-program.md](docs/design/dspark-serving-program.md)
(drafter quantization — 4-bit baseline then TurboQuant as its lowest-risk
first customer — + draftBlock tightening + generated-forward tap + the
serving-UX/defaults pass). TurboQuant merged 2026-07-07 (PR #20) — the
Phase-5 gate is CLEAR; Phase 1's code boxes (1a/1b/1c) landed the same
day, 1d is the next GPU run.**

**Phase 2 (same session): every remaining paper component LANDED** via a
multi-agent build + adversarial review — Alg-1 confidence-scheduled
draft-length pruning (variable-length `DraftSource.draft()` contract, serve
loop verifies over the returned length; activation is checkpoint-driven so
uncalibrated checkpoints are unchanged), STS calibration §3.2.1
(`src/spec/dspark/calibration.ts` + `scripts/dspark-calibrate.ts`), the RNN
sequential head Eq 6 (`--seq-head rnn`, init-equivalent to Markov; ⚠
design-doc-faithful shape, paper PDF absent — flagged in code, as is the STS
estimator), the tightened draft loop (on-device token chaining, deferred conf
reads, `collectLogits:false` on serve; bit-identity pinned in
tests/dspark-infer-loop.test.ts), and the `dspark` variant rename + central
loader. A second adversarial-review wave (17 agents) confirmed 13 findings —
1 real logic bug (sample-path pruning misaligned tokens/conf/draftLogits →
OOB in verifySampling; found independently by all 3 reviewers) + 12
leak-shaped (inline-slice orphans, try-body locals invisible to finally,
calibration NaN poisoning) — ALL FIXED same session with regression checks
(the leak shapes are now a memory: [[mlx-inline-slice-leak-pattern]]).
Final gate: tsc 0 · smoke 22/22 · 84/84 across dspark+spec+server suites
(incl. real-weights; the grammar suite's `Aborted()` line is pre-existing
xgrammar WASM teardown noise, stash-proven). **All that remains is the GPU
recipe** (regen→train→calibrate→measure on 12B):
docs/archive/investigations/dspark-handoff.md.

Architecture verified faithful (2026-07-01 review; overfit τ=3.24). **Phase 1
(merged in PR #19):** DSpark + the optiq Gemma
`-assistant` drafter are now serve-loadable behind `--draft-model` — the
`DraftSource` seam was extended for KV-borrowing sources (target donor-KV /
anchor-hidden / tapped H_ctx), provider kind is auto-detected (`dspark.json` →
DSpark, `*_assistant` → assistant, else two-model; `--draft-kind` overrides),
and the server pins `--num-draft-tokens` to a DSpark checkpoint's trained
γ. tsc-green, CPU smoke 16/16. **AssistantSource VERIFIED ON REAL WEIGHTS**
(`tests/spec-serve-assistant.test.ts`, e4b + assistant drafter, auto-gated):
serve-loop spec output is TOKEN-IDENTICAL to non-spec greedy for γ=1,2,3
(losslessness) + telemetry populates — the extended seam is proven end-to-end
(both providers share it). Ships a real ~1.09× γ=1 win with NO training. The
Phase-1 code was adversarially reviewed (multi-agent workflow) and 5
leak-on-exception bugs fixed (round/prefill scratch-tensor disposal on throw,
forwardMaybeTap partial-capture leak, DflashProvider.dispose). DSpark-source
correctness stays model-gated (needs a trained checkpoint — Josh's GPU).
Design + seam contract:
[docs/design/dspark-speculative-decoding.md](docs/design/dspark-speculative-decoding.md),
[[dspark-seam-kv-borrowing]].
**Remaining (this plan):** paper components (confidence-scheduled draft-length
pruning / STS calibration / RNN head), loop tightening, `dflash`→`dspark`
rename. **Josh-gated GPU:** data scale + **12B retarget** + train + live-τ
(27B is memory-infeasible to train on 24 GB — kept dim-generic). Handoff:
[docs/archive/investigations/dspark-handoff.md](docs/archive/investigations/dspark-handoff.md).

## Josh-gated (needs hardware / downloads / own shell)

0. **Audio A5 closeout** (branch `josh/audio-input`, PLAN "audio input"):
   - Quiet-machine bench cells → RESULTS.md: audio tower ms, TTFT delta
     vs text-only, RSS delta with the tower loaded (the serve test's e4b
     load+transcribe round trip was ~2.3 s on a loaded box — directional
     only, don't quote).
   - 12B audio cell: rebuild its sidecar via optiq `build_vision_sidecar`
     (selective download pulls only the audio shards; the local 12B
     sidecar holds 1 audio tensor) → then regen 12B audio goldens and
     clone the e4b test cells (per-model doctrine: every cell validates
     or defers explicitly).

1. **Fresh clean-machine benchmark** (reboot + `sudo purge` first):
   - `./benchmark.sh --redo` — the standing h2h rows.
   - The NEW composition matrix, per model (writes
     `benchmarks-feature-matrix-<date>.md`):
     `bun scripts/bench-feature-matrix.ts --model <cpm5-snapshot> --batch 4`
     (real batch cells), same for e4b; for spec cells the Llama pair works
     today (`--model <3B-snapshot> --draft <1B-snapshot>`), and the 12B
     needs a small same-tokenizer gemma draft (or the assistant drafter
     once it's behind --draft-model, parity-plan §7.9).
     Promote quotable rows to benchmarks/RESULTS.md "composition".
2. **M4 Pro post-rewrite reset** + delete the mirror backup tarball (see
   "Where we are"). One line, then both boxes are on rewritten history.
2. **Phase 14 retarget — Qwen3.8-27B, full support** (supersedes the
   3.6-27B confirmation; findings + sub-phases in PLAN.md "Phase 14
   retarget"). Scope per Josh: text + thinking controls + tools + MTP
   + vision + video, then retire 3.6. **Text parity is GREEN
   (2026-08-16, M4 Pro): full prefill grid plus 32 decode steps bit-exact
   vs mlx-lm on the published
   `mlx-community/Qwen3.8-27B-OptiQ-4bit` artifact, first try** —
   `MLX_BUN_TEST_QWEN38=1 bun test tests/qwen-parity.test.ts`. The MTP
   drafter (`Qwen3.8-27B-MTP-bf16`, the Qwen-trained head split from
   the release's shard 18) is also downloaded. 14r-c serving features
   LANDED (reasoning_effort depths, preserve_thinking, think-tag
   streaming, tool format verified; docs in server-api/README/matrix);
   live-serve smoke on the M4 Pro: thinking + instruct/eos PASS, the
   reasoning_effort + tool round-trips hit 30-min swap-starvation
   timeouts (logic verified model-free; re-run on the M1 Max).
   **14g MTP: the rollback blocker is SOLVED post-release (2026-08-18, M1
   Max).** The serve loop now speculates on gated-DeltaNet targets via the
   spec-round contract (SSMCache snapshot/replay — free snapshot from MLX
   array immutability; partial rejects bit-exactly replay the kept prefix
   from recorded position-local inputs). Provider/tap/CLI (`--draft-kind
   mtp`) restored. Gates green: kernel prefix property + round lifecycle
   (tests/qwen-ssm-specround.test.ts, model-free) and REAL-WEIGHTS serve-loop
   losslessness with real rollbacks on Qwen3.5-0.8B
   (tests/qwen35-spec-ngram.test.ts — also newly enables ngram/two-model
   spec for the whole qwen3_5 family). The 27B pairing gate is ALSO GREEN
   (2026-08-18, M1 Max): `MLX_BUN_TEST_QWEN38_MTP=1` token-identical to
   non-spec greedy, acceptance 88% (30/34), 2.82 tokens/target-forward.
   ALL 14g follow-ups are closed (2026-08-18, quiet M1 Max — full detail in
   PLAN 14g): the quiet-machine interleaved TPS A/B is a durable NEGATIVE
   perf verdict (median MTP-on 12.93 vs off 15.75 tok/s = 0.821× at γ=2,
   61% acceptance, arms token-identical, spreads ≤4.4%) — the head's serial
   full-vocab lm-head cost per draft eats the saved forwards, so MTP is
   correct-but-slower and stays opt-in; direct drafter-logit parity vs the
   mlx-vlm 0.6.14 reference on identical hidden inputs is EXACT in tokens
   and top-8 ordering (worst |Δlogprob| 1.9e-1 = bf16 logprob floor); and
   the M4-Pro-swap-starved serve smokes pass here 4/4 (pressure theory
   confirmed). Harnesses: scripts/experiments/qwen38-mtp-ab.ts,
   oracle-qwen38-mtp-logits.py, qwen38-mtp-logit-parity.ts.
   Separately, qwen3_5-27B serial-lane decode dies with a
   GPU command-buffer failure surfacing as an uncatchable Metal-
   completion-thread C++ throw (full finding + .ips backtrace in PLAN
   14g; leading theory = command buffers failing under the 20.35 GB +
   swap regime — parity/sync is bit-exact and the pipelined repro
   passes standalone). ~~M1 MAX PICKUP~~ **DONE 2026-08-18**:
   `MLX_BUN_TEST_QWEN38_SERVE=1` passed 4/4 on the M1 Max in 17.5s —
   pressure theory confirmed (the M4 Pro timeouts were swap starvation,
   not logic). 14z (TQ×weights, ~4 bpw) is PROMOTED as the
   M4-Pro fit lever (interim: the uniform -4bit artifact). Then:
   perplexity provenance check, 14v vision / 14w video (mlx-vlm
   reference), TurboQuant KL cell (14r-d), retire 3.6 (14r-b2).
3. ~~**Phase 13 — TurboQuant**~~ **v1 LANDED 2026-07-06** — `--kv-quant
   turbo[:k<bits>v<bits>]`, oracle = vllm-metal (vendored, bit-exact codec
   goldens), quality-vs-bpw curve gate passed on MiniCPM5-1B (k8v3 = 6.25
   effective bits @ KL 0.0325, beats uniform kv4). See PLAN.md Phase 13 +
   docs/design/turboquant-kv.md. Remaining follow-ups are non-goals recorded
   there (fused kernel, rotating layers, batching, QJL).
4. **Vision remainder** — audio tower + 26B/31B SigLIP (e4b + 12B live).
5. **e4b ORPO overnight** + resuming the CPM5 UF run (own-shell `nohup`).

(Benchmark reruns aren't tracked here — nothing is gated on them; run
`./benchmark.sh` whenever quotable numbers are wanted.)

## Recently resolved (pointers, not state)

- **v0.0.9** (2026-07-01): mlx_lm.server drop-in surface (endpoints, fields,
  logprobs, L1-faithful samplers), fuse/convert/perplexity/upload/gc verbs,
  Tier-0 generic models (11 archs), --l2 tier restoration, CI gate, curve
  sampler distinctness theorem. Full wrap archived in PLAN-archive.md.
- **2026-07-01 multi-agent review**: all six confirmed findings now closed
  except DSpark live-τ (workstream above) and the test gaps (training
  section above). Full report local at `reports/project-review-2026-07-01.md`.
- **26B gather-qmm profile** (2026-07-02): gap = mx.gather_qmm's missing M=1
  fast path; custom gather-qmv kernel built, correct, SHELVED on decisive
  numbers (dispatch fixed-cost eats the prize). Upstream is already on the
  small-M path (mlx#3553 + qmv_wide merged, gather_qqmm in flight); our only
  remaining route is a fused whole-MLP kernel in a dedicated session.
  Evidence in `scripts/experiments/`.
- **DiffusionGemma-26B port COMPLETE** · **MiniCPM5
  megakernel SHELVED** · vision SigLIP e4b, segmented backward, distribution,
  adapters e2e, expert offload E1 — all merged; history in PLAN/PLAN-archive.

## Archived handoffs

Superseded session wraps (incl. the full v0.0.9 2026-07-01 wrap, the
multi-agent review detail, DiffusionGemma history, and older handoffs) live
in [PLAN-archive.md](PLAN-archive.md). This file holds only current state.


# PLAN archive 2026-08-18 (closed phases moved out of PLAN.md — CONTRIBUTING.md rule 4)

## Phase 13 — TurboQuant `[x]` v1 LANDED 2026-07-06 (research path — PROMOTED 2026-06-12)

**Post-merge review fix (2026-07-07, CRITICAL):** the bit-pack/unpack
helpers leaked window-scale GPU buffers on every decode step — the bare
`ops.split(...).map(reshape)` orphaned every split slice (each pinning the
full window-sized input) and pack3/unpack3's or-chain reassignment orphaned
accumulators. Measured ~8.4 MB/call at [1,8,2048,96] b3 ⇒ ~67 MB per
generated token on 12B at 2k ctx ⇒ OOM within dozens of tokens of real
serving. Fixed with `splitLanes` (dispose-inside-map) + `orInto`; goldens
untouched (dispose-only change); window-scale regression test added (the
original leak test's tiny shapes + 4 MB slack had hidden it). Same review:
`--kv-quant turbo` + `--draft-model` silently dropped turbo on the spec
lane — the spec-eligibility gate now excludes turboQuant (mirrors the
affine axes) + a startup warning; the turbo `state()` eval chokepoints got
try/finally.

**v1 shipped** (multi-agent build, this worktree): design doc
`docs/design/turboquant-kv.md` is the contract. Findings that reframed the
phase, from the research fan-out:

- **Two unrelated "TurboQuants" exist.** The paper (arXiv:2504.19874) is a
  dense-QR-rotation theory quantizer; the shipping variant is
  **vllm-metal's** (`vllm_metal/attention/caches/turboquant.py`) — optiq's
  config layer is lifted verbatim from it (byte-identical CENTROIDS_3BIT,
  matching op signatures in optiq cache_state.py). **vllm-metal is the
  oracle** ("the oracle is whoever ships it"); its pure-MLX Python reference
  is vendored at `lab/repro/vllm-metal-turboquant/` and drives bit-exact
  goldens via the oracle venv (`scripts/regen-turboquant-goldens.ts` →
  `goldens/turboquant.json` + generated `src/mlx/turboquant-tables.ts`).
  Keys are NOT rotated (docs page upstream is wrong vs its own source);
  only values get sign-flip FWHT → per-32-group RMS → Lloyd-Max.
- **What landed:** codec `src/mlx/turboquant-ops.ts` (bit-exact vs vendored
  reference on 8 golden vectors incl. adversarial rows; fp32-upcast fix for
  the bf16 production path caught by adversarial review + prove-by-removal
  tests); `TurboQuantKVCache` (gemma4-base.ts, dequantize-on-fetch, NOT a
  KVCache subclass → auto solo-only + generated-file fallback); kv-store
  spill/restore + prompt-cache clone; `--kv-quant turbo[:k<bits>v<bits>]`
  (default k8v3) through generate/serve/eval; gateway solo-refusal; docs
  rows (cli/server-config/features-matrix). Rotating (sliding-window)
  layers stay bf16 in v1 — one-time warning, verified live on e4b.
- **Exit criterion MET — quality-vs-bpw curve on MiniCPM5-1B**
  (`scripts/eval-turboquant-curve.ts`, teacher-forced serving-decode KL vs
  bf16, 8×128 tokens, 32 steps, M1 Max 32 GB):
  k8v8 8.75 bits→KL 0.0021 · k8v4 6.75→0.0094 · k8v3 6.25→0.0325 ·
  k8v2 5.75→0.175 · k4v3 4.25→0.062 · k4v2 3.75→0.205. Shape matches the
  paper's law (v-bits dominate, ~4^-b decay, cliff at v2); 3-bit codec MSE
  lands in the paper's D_mse≈0.03 band. Same-harness affine baselines:
  uniform kv8 8.5 bits→0.0025 (turbo k8v8 ties at 8.75), uniform kv4
  4.5→0.052 (turbo k4v3 0.062 at 4.25 — on-curve). Turbo's value: NEW
  operating points (6.25/5.75/3.75 bits) between affine kv8 and kv4 —
  k8v3 at 2.56× KV compression beats uniform kv4's KL.
- **v1 non-goals recorded in the design doc:** fused quantized-SDPA kernel
  (deferred-InvFWHT trick), rotating-layer support, batched turbo, QJL
  residual stage. No speed claims — dequant-on-fetch is a memory/context
  feature, opt-in like all output-changing levers.

### Phase 13 original scope note (kept for history)

Rotation-based vector quantization. Oracle:
`optiq/runtime/mtp/turboquant.py`. **Confirmed from source (2026-06-12):
this is a KV-CACHE quant method, not a weight/artifact quantizer** —
`KEY_QUANTS`/`VALUE_QUANTS` (per-key/value bits, e.g. keys q8_0 / values
q3_0), FWHT rotation over head dims, 3-bit Lloyd-Max centroids; imported
by `optiq/runtime/kv/rotating.py` (our Phase 9 port's oracle). So its
product value is **more usable context** (KV grows with context length),
NOT smaller model artifacts — the "device-targeted artifacts" wording
below means context-fit via KV, not weight shrink. It composes with the
separate model-quantization workflow (Phase 17 matrix), it is not it.
~~Sequence last~~ **Re-prioritized
by Josh (2026-06-12): now ahead of Qwen in interest.** The product
frame (docs/planning/PRODUCT_ROADMAP.md "Artifact design") changed the value
calculus: TurboQuant + sensitivity analysis is the lever for
device-targeted artifacts ("make a 12B-class model hit 64k context on
24–32 GB above a decode floor"), not a generic-compression niche.
Exit criterion unchanged: reproduce the reference's quality-vs-bpw
curve on one model; otherwise record a decision not to.

## Phase 19 — HLG sampling (piecewise tone curve on the logits) `[x]` CLOSED — SUPERSEDED by Curve Designer (2026-06-14)

> **Status (2026-06-17):** Empirically a wash vs. plain temperature (Pass 4 verdict: within N=10 noise). Superseded by the Curve Designer (`src/curve-sampler.ts`) which shipped as a general-purpose tone-curve sampler. Findings preserved as history; open items below are struck as moot.

A new sampling transform inspired by HLG (Hybrid Log-Gamma, the HDR transfer
function): where temperature is one global slope, HLG is **piecewise** — a
pivoted toe/gain/shoulder curve on the per-token log-probs that rolls off the
highlight (top-token dominance), boosts the mids (novelty/local contrast), and
holds a soft toe on the shadows (suppress the tail smoothly, don't crush the
blacks). The thesis: temperature *couples* "reduce top dominance" with "inflate
the tail"; a region-aware tone curve **decouples** them. Post-inference and
model-agnostic — applies to all four models and both lanes with no per-model
code. Full design + math in **docs/archive/hlg-sampling.md**.

**First sampling feature with NO oracle ancestor** (neither mlx-lm nor optiq
does this), so it is gated by **KL + quality + diversity, not parity** (see
three-tier-parity framing). The parity-equivalent safety anchor: the curve is a
strict generalization of temperature — `gain=1`+rolloff-off ⟹ bit-exact today's
sampler; rolloff-off+`gain=1/T` ⟹ bit-exact temperature `T`. Greedy
(`temperature 0`) is a no-op by construction (monotone `g` can't move argmax).

Pieces (sequenced; keep flag-off and greedy paths bit-identical at every step):

- [x] **(1) Pure curve + tests** (2026-06-14) — `applyHlg(lp, params)` +
      `HlgParams` in `src/sampler.ts` (top-anchored pivot `μ = ℓ_max − c`,
      piecewise log-toe/linear-mid/log-shoulder, `where`-selected, dispose
      discipline; no-rolloff regime returns `mulScalar(lp, m)` so the
      degeneracy is the *same op*, not an approximation). Tests
      `tests/hlg-sampling.test.ts` (8/8, fast tier, no weights):
      degeneracy ≡ temperature/identity `max|Δ|=0`, monotone +
      ranking/argmax preserved, `-inf` masked tokens stay `-inf` (no NaN),
      shoulder compresses the highlight gap, toe gentles the tail gap. Not
      wired into `makeSampler` yet — flag-off path byte-identical. Model-level
      neutrality (real logit vectors, all 4 models, both lanes) lands with the
      wiring in (2)/(3).
- [x] **(2) Serial wiring** (2026-06-14) — `--hlg-sampling on|off` (default off)
      + `--hlg-width/-shoulder/-toe/-pivot-offset` in `serverRuntimeFlags()` (no
      `--hlg-gain`: the mid gain folds from `--temperature`); `SamplerOptions.hlg`
      → `makeSampler` calls `applyHlg` (mulScalar in the degenerate path, so the
      flag-off branch is byte-identical); `ServerOptions.hlg`; per-request `hlg`
      object on `ChatRequest` merged field-by-field by `resolveHlg` in
      `toOptions`. Wiring-neutrality tests (pure, no weights): HLG identity-config
      draws the same tokens as plain temperature; rolloff-on diverges. 10/10
      green, tsc clean. NOTE: `GenerateOptions.hlg` also reaches the batched
      gateway's per-row `makeSampler` for free — functionally live there, the
      explicit batched neutrality test is (3).
- ~~[ ] **(3) Batched wiring** — pass `hlg` through the per-row sampler in
      `generation-gateway.ts`; batched neutrality test (per-row logits unchanged
      vs serial under identity config). (moot — superseded)~~
- [x] **(4) Pivot modes 2 & 3 — runtime + tests** (2026-06-14, brought forward) —
      `hlgPivotBase()` in `src/sampler.ts` computes all three: `top` (μ = ℓmax −
      offset), `entropy` (μ = Σp·ℓ = −H, one dot product), `median` (μ = logprob
      at the 50% cumulative-mass boundary, reusing the sort). `HlgParams`/
      `HlgConfig.pivot` widened to the union. Tests: each pivot monotone +
      finite, and the three produce genuinely different curves (14/14 green).
      The `--hlg-pivot` CLI flag is the only remaining bit (the
      `scripts/experiments/hlg-compare.ts` harness sets pivot via `HlgConfig` directly).
- **Architecture decision (2026-06-14): HLG is a REPLACEMENT sampler.**
      `makeSampler` branches `if (hlg.enabled)` → the curve is the whole
      post-logits step (toe does the tail control), `else` → top-p/top-k +
      temperature, unchanged. Mutually exclusive — HLG does NOT layer on top of
      top-p/top-k. `gain` gained an explicit override (`HlgConfig.gain`), still
      folding from temperature by default, so mid-contrast can be probed while a
      model's recommended temperature is held fixed. Flag-off path stays
      byte-identical; the pure `applyHlg` degeneracy gates are unchanged.
- ~~[ ] **(5) Eval + benchmark** — KL characterization (`evaluateKlSelfFlag`,
      knob sweep), capability guardrail (`eval.ts capability` e4b + 12B, on vs
      off — does it dent reasoning/tool-calling?), NEW diversity lens
      (`src/eval/tasks/diversity.ts`: distinct-n / self-BLEU / cross-sample
      entropy, HLG vs entropy-matched temperature — the benefit), perf A/B.
      Set shipped defaults from the sweep; row in benchmarks/RESULTS.md §3. (moot — superseded)~~
- ~~[ ] **(6) Docs** — finalize design doc + investigation write-up
      (docs/archive/investigations/hlg-sampling-investigation.md), server-config /
      server-api / README sampling sections, STATUS next-action, memory note. (moot — superseded)~~

- ~~**Exit criterion**: neutrality gates bit-exact across all four models and
  both lanes; capability suite non-regressed (or, if it regresses, shipped
  default-off with a documented creative/open-ended use-case); a measured
  diversity gain at matched entropy vs temperature; ~0 decode-tok/s regression
  with the flag on. Default stays **off** regardless — novel knob, never a
  silent change to the default sampler. (moot — phase closed/superseded)~~

### Phase 19 findings (2026-06-14) — see docs/archive/investigations/hlg-sampling-investigation.md

Curve in place; HLG finalised as a **replacement sampler** (`if hlg → curve
else → top_p/top_k/temperature`). Pivot question answered empirically on e4b
(4 runs, `scripts/experiments/hlg-compare.ts`; full transcripts in
docs/archive/investigations/hlg-runs/):
- **Pivot = top-anchored.** As a replacement, `top` (μ = ℓmax − c) holds
  coherence; `entropy` (μ = −H) and `median` (50% mass) collapse to multilingual
  word-salad — they land μ near the peak on confident distributions, so the
  whole distribution falls into the (permissive) toe → tail mass ~17× the peak
  over the 262k vocab → near-uniform. top's 6-nat offset keeps tail mass ~0.4×.
- **The toe is permissive** ("don't crush the blacks" = lifts the tail toward a
  floor, not a hard cut), so in replacement mode the pivot offset below the peak
  governs coherence. Shaping the toe (smaller β_t) is the next calibration step.
- **distinct-2 rewards garbage** (salad scores ~1.0) → the Piece 5 diversity
  metric needs a coherence gate (NLL/perplexity), not lexical diversity alone.
- **Positive signal:** HLG raises open-ended diversity (brainstorm 0.78→0.88,
  continuation 0.75→0.86) while leaving the confident factual answer at 0.30 —
  the decoupling appears, mild at default knobs.

**Pass 2 (2026-06-14, full transfer system → the user's exact `HLGShaper`):**
implemented the literal BT.2100 chain (`applyHlgOetf/Eotf/Pipeline/Shaper`) as a
full replacement vs the default recipe. Two adaptations the source domain doesn't
need, both found empirically: **windowed-anchor input** (`x=clamp((ℓ−ℓmax)/W+1,0,1)`
— min-max over 262k collapses every candidate into the shoulder) and **the toe
inverted** (cubic suppress, not HLG's √ lift). Result: `HLGShaper` at W=5/os=18 is
a **working coherent replacement** (vivid, correct, no salad — runF/runG). Four
orthogonal knobs (`s_m`/`A`/`x_floor`+toe/`L_W`) where temperature gave one, BUT
the coherent slice is narrow — loosening for diversity tips into garbage (a smooth
262k tail needs aggressive gating; nothing hard-cuts like top-k).

**Pass 3 (2026-06-15, automated knob map `scripts/experiments/hlg-map.ts`) — CONCLUSIVE.** Once
out_scale is decoupled (auto-derived from a W-independent target gap), the shaper
is robust across wide W×A basins (the earlier "knife-edge" was that confound).
Two-stage canary-gated map (coherence → diversity vs the default recipe) across
all 5 knobs: **no acceptable cell beats the default** (HLG caps ~0.80 distinct-2
vs default 0.87 at equal zero-junk). Only `W` and `target_gap` matter and both are
coherence *gates*, not diversity dials; `A`/`s_m`/`L_W` near-inert. Hard tail-cut
(top_p/top_k) is strictly more diversity-efficient than a smooth gated tail.
Frontier probe (`scripts/experiments/hlg-frontier.ts`, N=10, self-BLEU on the divergent
region + `target_gap×W`/`×A` interaction corners) is the definitive landing: best
clean HLG cell **0.605 vs default 0.672** (the sharper metric widens the gap but
shows the real `target_gap`/`A` diversity gradient distinct-2 hid); and the valid
ranges are a **coupled manifold, not a box** — `tg12×W5` jointly fails though each
is clean alone (the interaction the one-at-a-time map structurally can't see).
That Pass-3 "control, not dominance" verdict was **PREMATURE — overturned in
Pass 4.** It was a sweep-range + metric artifact: A had only been swept over
[0.2,0.8] (the dead zone where the shoulder barely engages) on a noisy distinct-2.

**Pass 4 (2026-06-15) — apparent reversal, then a WASH.** Wide-range map (runL:
every knob breaks somewhere, so each does something; A breaks high ~100, s_m high
~4) + frontier re-measured at N=10 with self-BLEU + a **semantic embedding metric**
(mean-pooled LM hidden states) + text verification (runM/runN). At the loose corner
**A=0.01, s_m=0.05** it *looked like* dominance — self-BLEU 0.783 vs 0.672, text
verified genuinely diverse and correct. **But the fresh-seed repeat (runO, seed
5000) did NOT replicate it:** the default's own self-BLEU swung +0.083 across seeds
(0.672→0.755), at seed 5000 edging above the HLG cell — N=10 variance (~0.08) swamps
the effect. **Honest final landing: HLG's loose-corner cells are COMPARABLE to the
default on diversity at equal coherence (within N=10 noise), with at most a small
consistent embedding edge below the measurement resolution. Neither "dominance" nor
"negative" survives — a wash at this N; resolving it needs N in the hundreds or a
real sentence encoder.** A working/coherent/tested sampler (default off); the
thesis (loosen top + gate tail) is mechanically real but its diversity payoff over
temp is, at most, within noise. Meta-result: the fresh-seed repeat caught BOTH
premature verdicts (the Pass-3 "negative" and the Pass-4 "dominance") within one
run each. Full arc + 15-run trail + hlg-frontier.json + 3 harnesses:
docs/archive/investigations/hlg-sampling-investigation.md.

## Phase 21 — GLM-5.2 on 32 GB via the complete Colibri hierarchy `[x]` (closed 2026-08-17)

Full investigation and phased contract:
**docs/design/colibri-glm52-port.md**. Source baseline:
`JustVugg/colibri@44e489b196c9b7876b3d37a0570ebf1c6f90f54c` (post-v1.0.0),
Apache-2.0. This phase extends Phase 20; it does not rediscover expert
streaming.

**Decision:** port the complete Colibri design into mlx-bun as one native
Bun+MLX runtime. Do not embed, launch, or ship Colibri as a backend. A pinned
direct Colibri/Metal build is the same-artifact behavioral and performance
oracle. MLX owns the model/tensor graph; Bun owns residency policy, I/O
orchestration, serving, tooling, Atlas/heat telemetry, and UI. Native helpers or
custom Metal kernels remain valid implementation details at the OS/kernel
boundary. The port decision is settled: the direct-Colibri same-machine numbers
recorded in G0 are the bar the port is debugged against — a gap versus the
oracle is a bug to close, not a go/no-go. **Aspirational performance target
(not a release gate): >=2 tok/s warm on the M1 Max 32 GB, MTP on,
quality-preserving defaults** (decomposes as a
~0.8-1 tok/s no-MTP base × MTP's measured 2.2-2.6 tok/forward — which is why
serial MTP sits on the critical path as its own gate). Target machine is the
M1 Max 32 GB; the 24 GB M4 Pro is below the one-slot-per-layer floor and out
of scope. (Revised 2026-07-21 with the design doc: gates renumbered G0-G8,
serial MTP promoted to G4, batched multi-row MTP descoped to post-release.)

- [x] **G0 — direct oracle baseline:** pin/build direct Colibri arm64 Metal;
      record the public artifact; run model-free `make check` + Metal tests;
      import tiny GLM/quant/DSA/MTP/cache fixtures; measure the direct baseline
      on the cleared M1 Max 32 GB — memory/I/O/speed, **MTP on and off**. Disk
      preflight met (2026-07-21: ~556 GB unallocated + ~123 GB purgeable ≈
      679 GB available). No model download in CI or agent sessions.
      **Closed 2026-07-22:** the exact pin/license/inventory, isolated model-free
      and Metal suites, APFS preflight, model-free fixture package, full-model
      numeric capture, and same-machine runtime baseline are recorded in
      `docs/archive/investigations/colibri-oracle-pin.md`. All 145 LFS payloads
      (383,760,044,154 bytes) match the exact public-artifact revision's
      SHA-256 values. The 140-record real-model GLM/MLA/router/MTP/KV oracle is
      bitwise reproducible across two captures and is compacted into
      `fixtures/colibri-glm52/real-model-oracle.json`; both the main and MTP
      heads predict teacher token 16. The final matrix has three independent
      processes per mode and two turns per process, capturing TTFT, footprint,
      compression/swap, hit/I/O, token IDs, speed, and MTP acceptance lengths.
      Fresh-turn median throughput is 0.34 tok/s without MTP versus 0.26 tok/s
      with MTP at the one-slot 18 GB budget: 34/90 accepted raw drafts reduce
      main forwards 63 -> 30 but add 34.6% expert traffic and 29.1% wall time.
      Median peaks are 13.631/17.475 GB; all process swaps are zero and the
      same pre-existing 0.75 MB system swap is unchanged. All twelve turns are
      exact-token-identical. DSA is explicitly waived for this public-artifact
      baseline because it contains no indexer weights; G2 retains exact-pin
      model-free fixtures and later generates a separate stock indexer overlay
      from 20 pinned source shards without mutating the serving snapshot. G1 is
      unblocked.
- [x] **G1 — unified-memory MLX storage foundation:** fixed aligned shared
      slabs, bounded positioned-read workers, zero-copy MLX/custom-Metal
      consumption, completion-fenced generation-tagged slot reuse, allocator
      caps, forced-churn stress, and same-shape Colibri kernel benchmarks.
      - [x] Agent-safe foundation (2026-07-22): strict synthetic gate/up/down
        artifact; fixed 16 KiB native slabs; passive bounded positioned-read
        workers; async Bun polling; generation-bound CPU/GPU leases; dependent
        lazy-output evaluation + selected-stream fence before reuse; stateful
        LRU, cancellation, 1,000 native-churn and 100 MLX-churn tests; stock MLX
        and custom Metal consume the same registered slab. Independent audit
        passed after closing reproduced post-close and lazy-graph stale-read
        failures. The helper is build-only until G3/G8 publishes a newly
        versioned native pack; the existing v0.1.0 pack remains unchanged.
      - [x] Manual quiet-machine paired kernel matrix (2026-07-30): Colibri
        Metal vs stock MLX vs custom Metal at identical production shapes,
        ten warmups and fifteen measured samples. The mlx-bun path selection
        is custom Metal for routed SwiGLU decode M=1 (4.282 ms vs stock MLX
        5.099 ms, 16.0% faster; an independent 3/11 run also won by 5.4%).
        Stock MLX remains selected for Q4 dense decode/prefill, routed M=11
        ragged and M=32 prefill, and absorbed MLA decode. All correctness
        checks passed and swap was unchanged.
      - [x] Manual passive-worker CPU/GPU/package-power measurement
        (2026-07-30): matched baseline plus 1/2/4-worker arms, repeated in
        reverse order with raw mactop samples retained. There is no monotonic
        CPU, GPU, or package-power increase with worker count, confirming the
        `pthread_cond_wait` pool is passive. Keep the bounded default at two
        workers.
- [x] **G2 — native GLM-5.2 spine:** dedicated config/model; compressed MLA KV,
      DSA indexer, sigmoid+correction-bias top-8 router, shared+routed experts,
      MTP layer, multiple EOS; direct Colibri-container parsing. Numeric parity
      contract defined BEFORE debugging (bitwise: int4/int8 dequant, router
      top-8 selection, byte accounting; trajectory-level: tie-free greedy token
      match + recorded max-logit-delta bound — cross-implementation Metal
      accumulation order is not expected to match bitwise by default). Added
      2026-07-22: custom kernels pin numerics to dequant→f32-MAC — Colibri's
      Metal/CUDA tiers are byte-identical to its CPU engine this way — so the
      gate hardens to bitwise where accumulation semantics match. Tiny model
      32/32 token-exact on a tie-free greedy trajectory vs the pinned engine.
      - [x] Dedicated `glm_moe_dsa` config, exact GLM chat-template fallback,
        multiple-EOS handling, artifact-aware factory entrypoint, and direct
        header catalog/layout validation for `out-*`, `out-mtp-*`, and optional
        `out-idx-*` shards.
      - [x] Direct lazy MLX tensor source plus exact Colibri int4 offset-binary
        and int8 two's-complement dequantization. The int4 path repacks bytes to
        MLX's uint32 affine layout lazily on-device; it does not copy a whole
        tensor through the Bun heap.
      - [x] Compressed MLA cache and attention correctness path: native
        `[B,T,kv_lora_rank]` latent plus decoupled RoPE state, reconstructed
        causal prefill, absorbed serial decode, partial interleaved RoPE, and
        optional DSA-selected latent/RoPE gathers.
      - [x] Exact DSA and MoE semantics: one shared
        `[B,T,index_head_dim]` DSA key per token, weighted-ReLU scoring,
        threshold/tie selection, `index_topk` dense fallback, shared-selection
        reuse, sigmoid+correction-bias lower-ID-tie top-8 routing, raw-sigmoid
        execution weights, routed scaling, and unweighted shared expert.
      - [x] Direct reference-model graph and focused layer/op gates for dense
        and shared+routed layers, MLA, DSA sparse decode, cache accounting,
        Q4/Q8 arithmetic, router ties, template rendering, and artifact
        dispatch. Current focused result with the immutable direct-container
        fixture enabled: 55 pass, 0 fail.
      - [x] Header-only validation of the pinned public artifact without model
        execution: 59,003 quantized tensors, 472 float tensors, 19,456 routed
        experts, complete MTP metadata, and no DSA sidecar, matching G0.
      - [x] Tiny-model 32/32 Colibri teacher forcing (2026-07-24). The pinned
        Colibri generator reproduces its committed BF16 trajectory exactly.
        Colibri's own per-row Q4 conversion is intentionally compared against
        predictions from that exact Q4 container, not the now-irrelevant BF16
        trajectory. The first 26/32 cross-engine result was not a Q4 loader or
        graph bug: pinned Colibri defaults to `IDOT=1` on Apple Silicon, which
        quantizes every activation row to int8 and explicitly adds about 0.3%
        RMS error per matmul. With `IDOT=0`, Colibri's documented exact
        dequant-to-f32-MAC path, Colibri C and mlx-bun are 32/32 on the same Q4
        bytes. Across all 8,192 logits, max absolute delta is 1.3113e-6 and
        RMSE is 2.7423e-7; the minimum MLX top-two margin is 0.003425. The
        tracked fixture records both exact-path and default-IDOT trajectories,
        generator/converter arguments, oracle flags, numeric bounds, and
        raw/config/container hashes. The 353 KiB artifact is machine-local at
        `runs/colibri-glm52-tiny-i4`.
      - [x] Production Q4 dense/router gate (2026-07-24). A bounded
        selected-shard probe reused the real G0 decode-row inputs without
        constructing the model, caches, experts, or generation path. Layer 0's
        complete gate/up/down SwiGLU was evaluated by pinned Colibri
        `dense_mlp` with `IDOT=0` and by MLX from the same Q4 bytes:
        max absolute delta 5.2387e-9, RMSE 9.7823e-10, cosine
        0.9999999999998781. Real layer-3 and layer-77 routers selected the
        exact captured top-8 IDs with `keff=8`; sigmoid max deltas were
        4.7684e-7 and 7.1526e-7, and execution-weight max deltas were
        4.3213e-7 and 8.9407e-8. Two independent processes produced identical
        numeric reports. The run also found and fixed the production-only MLX
        affine-dequant gap: a one-scale-per-row Colibri tensor cannot request
        an unsupported `gs_6144` Metal kernel, so the identical row scale is
        now repeated over supported 32-value MLX groups. MLX peak allocation
        was 1,566,883,896 bytes; observed process RSS peaked at 290,455,552
        bytes; system free memory remained 78% and swap grew by 0 MiB. The
        stable record is
        `fixtures/colibri-glm52/production-probe.json`; the manual runner is
        `scripts/probe-colibri-glm52-production.ts`.
        Serial MTP execution remains G4 as specified; G2 validates its complete
        container/config metadata rather than advancing the MTP cache.
- [x] **G3 — explicit bounded expert residency (load-bearing):** per-layer
      expert-ID→slot LRU, separate pinned tier, 64-unique working set,
      aligned gate/up/down+scale slabs, generation-tagged async loads, GPU-use
      fence, deterministic eviction, real RSS guard, and batched routed-SwiGLU
      Metal kernel. The current whole-file mmap/page-cache path is a bring-up
      backend, not the 25 GB contract.
      - [x] Native multi-shard segmented reads, canonical 16 KiB-aligned direct
        artifact slots, generation-safe leases, idle-slot decommit, and
        `TASK_VM_INFO.phys_footprint` sampling. Every MLX-addressed component
        is independently 16 KiB aligned; production headers resolve to
        18,939,904-byte Q4 slots. The 19,114 ordinary experts need four reads
        and the 86 cross-shard experts need six, within the fixed eight-segment
        native job.
      - [x] Fixed-budget planner and pure-LRU manager with one global 64-slot
        working tier, per-layer resident tiers, separate configured pins,
        deterministic LRU ties, reverse miss promotion by logical role swap,
        safe-point-only pressure shrink, stable batch union, resident-first
        submission, and failed-generation drain/discard.
      - [x] Async GLM model/layer/MLP seam plus resident-only tensor source and
        stock-MLX streamed Q4 SwiGLU candidate. The source rejects routed
        expert names, so the streamed path cannot fall back to whole-shard
        expert tensors. The machine-local tiny direct container remains 32/32
        token-exact through 64 working slots + one LRU slot per sparse layer.
      - [x] Custom M=1 Q4 Metal candidate reads the canonical slot directly and
        performs explicit dequant-to-F32 MACs in two dispatches
        (gate+up+SiLU, then down). The measured hybrid default now selects it
        for eligible one-row jobs and falls back to stock MLX for multi-row
        ragged/prefill work; an explicit `"stock"` override remains.
      - [x] Run the G1 quiet kernel/power matrix and select the routed-SwiGLU
        path: custom Metal for M=1 decode; stock MLX for ragged/prefill.
      - [x] Bounded production pure-LRU expert gate: exact layer-3 top-8;
        complete routed+shared output is identical across cold/warm/churn and
        matches Colibri at max absolute delta 1.8626e-9 / RMSE 3.6290e-10.
        Forced replacement and rerun produce the expected miss/evict trace;
        physical footprint ends at 726,549,944 bytes and swap grows by 0 MiB.
        Stable record:
        `fixtures/colibri-glm52/g3-production-expert-probe.json`.
      - [x] Run the two-forward tie-free `[16,13]` direct-Colibri trajectory
        through the full streamed model and record footprint/swap. The
        correctness-first 32-token prefill + one-token decode reproduced
        `[16,13]` with margins 2.9581 / 7.0824. Final physical footprint was
        13,474,688,232 bytes and MLX peak allocation was 11,007,206,184 bytes;
        every load/lease was drained at exit. A live 512 MiB swapout abort
        bounded the non-cleared run, which recorded 397,148,160 bytes of
        system-wide swapout while other applications remained open. This is
        evidence, not the G5 cleared-machine zero-swap claim. Stable record:
        `fixtures/colibri-glm52/g3-full-model-trajectory.json`.
      - [x] Final adversarial G3 review: no numeric, alignment, ownership/UAF,
        or budget blocker. Fixed release-error double-attempt masking and made
        the live guard sample both before store close and after teardown; the
        98-test focused/native suite and project/probe bundles pass afterward.
- [x] **G4 — serial native MTP (requirement):** int8 MTP row sharing target
      weights, counted in the residency budget; draft-to-gamma, batched verify,
      exact rollback; `SPEC_PIN`-equivalent fixed draft/verify kernel family;
      grammar + prompt-lookup integration; tok/forward + end-to-end metrics.
      Exit: oracle accept/reject trace match + net win over MTP-off. All later
      gates measure with MTP on (the 2 tok/s aspiration assumes it).
      - [x] The in-process `Glm52NativeMtpProvider` shares the target embedding,
        output head, dense spine, sampler, and resident weight source. Its
        separate signed-int8 expert tier reserves 24 verify-working slots plus
        one resident slot (945,356,800 bytes), and that slab plus the remaining
        MTP tensors are included in the main fixed-byte plan.
      - [x] Full-prompt **target** prefill followed by Colibri's decode-only
        MTP recurrence drafts to gamma=3, verifies `[pending,...drafts]` in one
        target forward, retains the first MTP row, rebuilds accepted rows from
        the target's verified hidden window, and trims every rejected
        target/MTP cache tip. The model-free state-machine gate covers partial
        acceptance followed by full rejection.
      - [x] One row-independent custom Metal family handles Q4 target
        M=1/verify rows while a second handles signed-Q8 MTP M=1/absorption
        rows. M=1/M=4 Q4 and M=1/M=3 Q8 row-stability gates pass. Grammar
        remains in the shared constrained accept walk; prompt lookup remains
        the alternative model-free `DraftProvider`, so exactly one draft
        history owns a request and neither path double-advances target or
        grammar state.
      - [x] The direct `IDOT=0,SPEC_PIN=1` capture and mlx-bun match all 64
        target tokens and the tie-free first four acceptance rounds
        `[1,1,1,0]` (eight emitted tokens; minimum direct first-draft margin
        3.5675). The complete direct acceptance trace is retained as
        non-gating evidence: direct Colibri reduces RMSNorm squared sums in
        float64, whereas MLX uses its established float32 reduction graph, so
        later MTP hidden recurrence and proposals need not be cross-engine
        identical even though target output remains exact.
      - [x] Separate-process production A/B on the 32 GB M1 Max: MTP-on
        generated the exact 64-token trajectory in 675.654 s versus 834.172 s
        off, a 1.235x wall-throughput win / 19.0% less generation time.
        It accepted 32/92 drafts over 31 verify forwards, emitted 2.065
        tokens/forward, and saved 32 target forwards. The machine was not
        swap-cleared, so its 14,679,224,320-byte completed physical footprint
        is evidence only—not the G5 memory-contract result. Stable records:
        `fixtures/colibri-glm52/g4-direct-mtp-trace.json` and
        `fixtures/colibri-glm52/g4-native-mtp-e2e.json`.
- [ ] **G4R — prompt-seeded MTP research spike (deferred 2026-07-30):** test
      whether populating the
      MTP layer's independent KV cache from prompt context improves draft
      acceptance enough to repay its added prefill work. The landed
      direct-Colibri decode-only window remains the control and default.
      Josh explicitly deferred this non-blocking research spike so G5 can
      measure the already-correct, already-faster decode-only default first.
      Implementation parity is not the correctness oracle: candidate output
      must remain bit-for-bit identical to the target-only trajectory for the
      gated greedy and seeded-sampling cells.
      - [ ] Extend the draft-source prefill seam to expose the already-computed
        target hidden rows; do not rerun the target prompt. Seed MTP rows from
        `(promptIds[1:], targetHidden[:-1])`, preserving the final prompt
        hidden plus pending token as the first actual draft input.
      - [ ] Lock cache-position, cancellation, rejection, and accepted-row
        rebuild behavior with model-free tests, including short/single-token
        prompts and multi-round generation.
      - [ ] Run paired fresh-process A/B cells across short/long prompts and
        short/long continuations. Record exact token IDs, TTFT, MTP-prefill
        time, decode and end-to-end wall time, acceptance, target forwards,
        physical footprint, and swap.
      - [ ] Promote prompt seeding only if exact output remains closed and
        paired **end-to-end** wall time wins without breaking the G5 memory
        envelope. Otherwise record the negative result and retain the
        decode-only implementation.
- [x] **G5 — 32 GB memory contract (measured MTP on):** full dense + LRU +
      working-set + KV + reconstructed-KV + MLX allocator/transient + Bun +
      OS-reserve planner, startup refusal, and physical-footprint feedback; the
      verify batch, MTP KV row, and larger per-forward union are in the
      accounted workload. Gate on the cleared M1 Max 32 GB: startup +128 tokens
      MTP on <=25 GB, flat memory, no compression spiral/swap; record cold/warm
      speed (MTP on and off) vs the G0 baseline.
      - [x] Header-only preflight exposes every line item and refuses before
        resident weights are mapped. For the pinned production artifact,
        the conservative MTP-on plan is 21,111,440,128 process bytes:
        10,877,286,144 resident weights + 2,632,646,656 main slab +
        945,356,800 MTP slab + 736,100,352 target KV + 9,437,184 MTP KV +
        537,395,200 reconstructed-KV transient + 4,508,672 verify rows +
        4 GiB MLX allocator + 512 MiB Bun/native + 512 MiB safety. The 25 GiB
        ceiling leaves 5,732,105,472 bytes of planned process headroom and
        reserves the remaining 7 GiB of a 32 GiB machine for the OS.
      - [x] The model-free contract proves that the planner's total is exactly
        the runtime expert-residency equation, accounts the 32-slot target
        verify union and 24-slot MTP draft union, rejects undersized banks and
        impossible context/machine/process limits, and removes MTP-only bytes
        from the off lane.
      - [x] Manual harness runs two 128-token turns in one process per mode,
        preserves expert residency while rebuilding request KV, gates the first
        64 tokens against direct Colibri and all 128 cold/warm/on/off tokens
        against each other, samples task physical footprint + MLX + vm_stat
        every 15 seconds, rejects any swapout, bounds compressor growth to
        256 MiB, and requires warm final footprint within 256 MiB of cold.
      - [x] Fresh-process full-model pair (2026-08-15): all four 128-token
        cold/warm/on/off turns are identical and retain the direct-Colibri
        first-64 prefix. MTP-on peak footprint was 14,807,789,616 bytes
        (13.791 GiB), with cold/warm finals 14,673,342,512 -> 14,697,574,448
        (+23.1 MiB); MTP-off peak was 13,576,039,488 bytes (12.644 GiB), with
        finals 13,490,515,008 -> 13,510,634,560 (+19.2 MiB). Warm end-to-end
        speed was 0.149 tok/s on vs 0.114 off, a 1.306x MTP win; both remain
        below the G0 direct-Colibri warm baselines (~0.27 on / ~0.34 off), so
        G6 performance work remains material.
      - [x] Josh explicitly changed the live gate to before/after observation
        on 2026-08-15. Strict enforcement remains the harness default;
        `--memory-mode observe` records the same threshold violations without
        aborting. The paired artifact is therefore `result: observed` and
        `strictContractSatisfied: false`: maximum system/task compressor
        deltas were 4,402,905,088 / 1,939,537,920 bytes, and MTP-off observed
        7,143,424 bytes of swapout while MTP-on observed zero. The bounded
        cold-to-warm footprint deltas and <=13.791 GiB peak close the requested
        32 GB fit measurement without mislabeling it a strict zero-compression
        pass. Evidence: machine-local `runs/colibri-g5/{mtp-on,mtp-off,summary}`.
- [x] **G6 — complete scheduler + Atlas:** batch-union; bounded
      pread/F_NOCACHE workers; resident-first Metal submit overlapped with
      misses; persistent `.usage`; auto-pin; live LFRU (decay + 25%+4
      hysteresis + bounded swaps); PILOT, coupling, and two-step prediction.
      Add live tier/heat/hit maps and the replicated topic-affinity Atlas probe,
      validation, and visualization. Each lever needs a paired hit/I/O/p95/tok-s
      A/B **with MTP on** before defaulting (a lever that wins MTP-off but loses
      MTP-on is not a default); Atlas-informed warm-start is a separate
      experiment.
      - [x] Scheduler foundation already present entering G6: stable whole-batch
        expert union, bounded positioned-read/F_NOCACHE workers, per-layer LRU,
        and resident/shared Metal submission before miss reads.
      - [x] Persistent learning ledger (2026-08-15): target and MTP share one
        Colibri-compatible `<model>/.coli_usage` table. Every selected top-k
        route is counted before union deduplication; long-term counts load at
        startup while heat/recency begin session-local, and generation safe
        points publish via same-directory temp + atomic rename. Invalid derived
        profiles warn and restart empty rather than blocking model load;
        `usagePath: false` is the explicit diagnostic opt-out. Model-free gate:
        `tests/expert-usage.test.ts` plus generation-finally coverage in
        `tests/generate-wiring.test.ts`.
      - [x] Budgeted startup auto-pin candidate (2026-08-15, opt-in pending
        A/B): reproduce Colibri's 5k-history floor, confidence ramp through
        200k selections, half-resident-tier share, and 0.5 GB minimum. Rank
        deterministically by frequency then layer/expert, account Q8 MTP pins
        at their larger slot cost, clamp behind the one-slot-per-layer floor,
        reserve the exact slots in both plans, and preload the hot store before
        the first forward. Explicit pins take precedence; `autoPin` remains off
        until the required MTP-on comparison wins.
      - [x] Safe-turn live LFRU candidate (2026-08-15, opt-in pending A/B):
        exact uint32 recency score, 25%+4 hysteresis, session-heat halving after
        each pass, and one global four-swap cap across target + MTP. Promotion
        reuses an already-resident hot expert or loads it through the bounded
        working bank, then swaps logical tier roles only after the load is
        complete. Residency maps expose slot/tier, long-term count, heat,
        recency, hits/misses, and repin totals. Persistent frequency never
        decays; `liveRepin` remains off until its MTP-on comparison wins.
      - [x] Paired-measurement seam: demand and policy traffic are separated;
        both report exact read bytes/operations plus disk-service and
        foreground-wait p50/p95/p99, while main/MTP layer-forward latency is
        captured independently. The G6 harness first learns a seed in its own
        MTP-on process, then gives identical copies to control, auto-pin, and
        auto-pin+LFRU arms, refuses token drift/overwrites, and supports three
        fresh repeats for a default-eligible result.
      - [x] Three-repeat MTP-on startup-pin/LFRU decision (2026-08-16): all
        nine cold/warm arm runs were token-identical from the same 308,592-
        selection seed profile. Relative to control, startup auto-pin raised
        the median warm hit rate 1.66% -> 9.62% and cut warm disk GB/token by
        8.02%, but warm end-to-end speed fell 4.06% (0.149 -> 0.143 tok/s),
        median open time rose 526 ms, and median warm physical footprint rose
        3.337 GiB (13.694 -> 17.032 GiB). Its 3.329 GiB policy preload did not
        pay back on this workload. Live LFRU performed zero swaps in all six
        measured turns; its 0.148 tok/s median was 0.38% below control and is
        only run-order noise over the identical startup placement. **Decision:
        keep `autoPin` and `liveRepin` off by default.** Machine-local evidence:
        `runs/colibri-g6-learning-shakeout-2026-08-15/summary.json`.
      - [x] Measurement-only PILOT seam (2026-08-16): after layer L attention,
        apply layer L+1's post-attention RMS norm and router to the unnormalized
        residual, copy the predicted top-8 routes, and compare them with the
        actual next-layer routes without consulting residency or issuing I/O.
        Deterministic tests cover rank accounting, the faithful <=8-row guard,
        abandoned predictions, and an exact two-layer streamed differential.
        One MTP-on paired full-model shakeout kept tokens exact and measured
        69.90% top-8 precision/recall. The first four predicted ranks were
        87.08% precise and covered 43.54% of the actual top-8; usable lead time
        was 179.9 ms p50 / 219.7 ms p95 versus ~92.7 ms demand-read p95. The
        candidate was 1.009x control warm throughput with ~3.5 MB additional
        final footprint, but one repeat is only a correctness/cost shakeout,
        not a replicated performance claim. Machine-local evidence:
        `runs/colibri-g6-pilot-measure-shakeout-2026-08-16/summary.json`.
      - [x] Bounded hint-only `PILOT_K=4` (2026-08-16): a dedicated native
        advisory queue issues scale-tail-only `F_RDADVISE` on a buffered file
        descriptor while demand reads retain `F_NOCACHE`. Hints deduplicate
        candidates, skip resident experts, never allocate/publish slots or
        mutate demand/LRU state, and expose submitted/completed/dropped/error
        counters plus queue depth. Deterministic native/residency/model tests
        cover queue completion, exact bytes, stable deduplication, resident
        skips, and unchanged residency/demand state. The one-repeat MTP-on
        paired full-model shakeout kept tokens exact; each turn submitted and
        completed 48,162 hints (144,486 operations / 1,972,715,520 advised
        bytes) with zero drops, errors, or end-of-turn backlog. Warm logical
        demand reads were exactly unchanged at 14,883,703,168 bytes/token;
        disk-service p95 was 1.0065x control, foreground-wait p95 was 1.0193x,
        and warm throughput was 0.9746x (0.14031 -> 0.13675 tok/s) with only
        +3.8 MB final footprint. **Decision: keep hint-only off and do not
        promote this policy to real speculative loads.** This is a correctness
        shakeout, not a replicated performance claim. Evidence:
        `runs/colibri-g6-pilot-hint-k4-shakeout-2026-08-16/summary.json`.
      - [x] Coupling + two-step measurement decision (2026-08-16): the
        value-preserving two-step path reproduces Colibri's current-layer
        shared-expert correction and scores it independently from direct
        PILOT. On the one-repeat MTP-on paired shakeout it raised top-8
        precision/recall from 69.90% to 73.01% and exact rows from 5.35% to
        7.90%, but warm throughput fell 10.13% (0.14978 -> 0.13461 tok/s)
        while logical demand bytes/token were exactly unchanged. The separate
        route trace captured 23,250 full router rows; a non-leaky cold-only
        70/30 temporal split trained on 108 positions and scored 47 held-out
        positions. At budget 8, raw coactivation coupling reached 31.02%
        recall for delta 1 and 30.81% for delta 2, beating equal-budget
        marginals by 8.06 and 7.66 points but remaining far below direct
        PILOT. Even budget 32 reached only 57.35% / 56.74% recall. **Decision:
        keep both mechanisms off and reject real speculative loads.** These
        are quality/cost shakeouts, not replicated performance claims.
        Evidence: `runs/colibri-g6-pilot-two-step-shakeout-2026-08-16/` and
        `runs/colibri-g6-coupling-shakeout-2026-08-16/`.
      - [x] Atlas probe/analyzer/visualization implementation (2026-08-16): pin
        Colibri's 10-category x 3-prompt matrix at source commit
        `ecade075cfc2eae684097ea7de5570c3786ce199`; reuse one streamed model
        load but isolate every prompt with a fresh KV cache and route segment;
        disable MTP, persistence, learning, prediction, hinting, thinking, and
        sampling. Normalize per-run shares, require >=2 prompt replication,
        and validate with a globally non-leaky leave-one-prompt-out classifier.
        Emit detailed JSON, Colibri-compatible `experts.json`, and a standalone
        interactive affinity map. Seven focused tests, including an end-to-end
        analyzer run, pass; the pinned prompts tokenize to 13-36 tokens.
      - [x] Real-model Atlas reproduction (2026-08-16): the resumable sweep
        completed all 30 isolated prompts and retained 13,236 experts after
        the >=2-prompt replication gate. Global leave-one-prompt-out
        classification scored 29/30 (96.7%, chance 10.0%), exactly matching
        Colibri's published held-out accuracy; the only miss was Chinese prompt
        1 classified as poetry. Of the retained experts, 1,065 (8.05%) crossed
        the >=0.50 strong-specialist threshold, versus Colibri's published
        1,041/13,260 (7.85%). The standalone interactive report rendered at
        desktop and narrow widths without application errors (the only browser
        console event was the expected absent favicon). Atlas-informed
        warm-start remains a separate, unimplemented, default-off experiment.
        Evidence: machine-local `runs/colibri-g6-atlas/analysis/`.
- [x] **G6R — IndexShare/IndexCache long-context DSA performance spike:** the
      paper/code audit is complete in
      `docs/archive/investigations/indexshare-performance-spike.md`. GLM-5.2 already
      ships and mlx-bun already implements a 21-full/57-shared schedule, so
      this is a production-kernel + measurement spike, not a new surface.
      First generate the exact immutable indexer overlay (Josh-run selective
      reads from about 99.90 GiB of pinned source shards; no agent-session
      download), then replace the correctness-only broadcast/host-sort path
      with a tiled deterministic score/top-k buffer that shared layers reuse
      without host copies. Gate official-runtime parity above 2,048 tokens and
      run paired 2K/8K/32K MTP-off/on cells on the M1 Max, recording cells that
      fail the exact G5 planner as contract-ineligible. Keep the checkpoint
      schedule fixed; report DSA-off vs DSA+IndexShare as a combined sparse-
      attention comparison, because the checkpoint does not contain the 57
      missing indexers needed for a true all-full A/B. Sparse long prefill is a
      follow-up prerequisite before making a prefill claim.
      - [x] **Stage 0 — overlay + first-sparse parity (2026-08-17):** generated
        the external 20-file, 197,202,400-byte stock indexer overlay from
        `zai-org/GLM-5.2-FP8@ba978f7d`, header-validated the exact 21F/57S
        schedule, and ran context 2,049 through mlx-bun and pinned
        `colibri@ecade075`. All 21 tie-free official score rows replay through
        mlx-bun to exact ordered positions and float32 thresholds; both
        runtimes emit greedy `[264,264]` and the same sparse-step top-1.
        Full-vector cosine is 0.997645; direct model-state selections are
        10/21 ordered-exact and 14/21 set-exact because the runtimes' upstream
        quantized matmul accumulation differs, so official-score replay is the
        isolated DSA gate. Reproducible probe/checker scripts are tracked;
        raw capture + overlay SHA-256 manifest are machine-local under
        `~/.cache/mlx-bun/evidence/glm52-dsa-stage0-2026-08-17/`.
      - [x] **Stage 1 — production-shaped device score/top-k + reusable
        indices (2026-08-17):** tiled `[H,D] @ [D,L]` scoring removes the
        `[H,L,D]` broadcast; deterministic uint64 rank keys preserve exact
        threshold/lower-position ties; FULL retains one 8 KiB device index
        buffer and SHARED MLA consumes it without readback or re-upload. Random,
        tied, all-equal, 2,049/2,048, borrowed-gather, and all 21 captured score
        rows pass. A fresh live run reproduced all 21 prior position vectors,
        `[264,264]`, and byte-identical logits. Exact-geometry score+top-k
        medians are 0.929 ms at 8K and 1.269 ms at 32K (component numbers only).
        Evidence: `~/.cache/mlx-bun/evidence/glm52-dsa-stage1-2026-08-17/`.
      - [x] **Stage 2 — paired decode matrix (2026-08-17):** 24 eligible
        fresh-process cells (2K/8K x DSA off/on x MTP off/on x three repeats)
        passed cold/warm, repeat, and MTP exact-token gates. The 12 planned 32K
        cells are contract-ineligible: exact plans are 27.320 GiB MTP-off and
        28.540 GiB MTP-on, above G5's 25 GiB process ceiling. At 8K, DSA raised
        serial decode 12.38% and reduced paired total wall time 1.89% without
        MTP, below the 5% win gate. With MTP, DSA reduced decode throughput
        34.33% and increased total wall time 8.19%; two of three DSA+MTP cells
        also observed net swap growth. Preserve 21F/57S as model semantics, but
        make no product-speed claim. Sparse prefill remains deferred because
        decode is conclusive and the prompt-only dense benchmark seam makes no
        prefill claim. Evidence:
        `~/.cache/mlx-bun/evidence/glm52-dsa-stage2-2026-08-17/`; manifest
        SHA-256 `90b3fe4ed53714604b7a747991b3bb1b87aedbf57a139915065f5b4be42cda38`.
- [x] **G7 — persistence, concurrency, and API parity:** (a) versioned
      compressed MLA/DSA/MTP `kv-store` save/restore with no full-K/V
      materialization; (b) batchable cache merge/extract, compressed-byte
      admission, cross-row expert union, join/leave/cancel — batched rows decode
      ordinary single-token; per-row MTP under batching is **post-release**,
      with telemetry always reporting the actual mode; (c) parity on
      chat/text completions, Anthropic Messages, OpenAI Responses, streaming,
      tools, grammar, stops, sampling/penalties, usage, serial logprobs, library
      `generate`, CLI chat/serve, health/stats — incl. GLM chat-template
      rendering, thinking-block policy per surface, and tool-call parsing.
      Non-generative capabilities such as
      embeddings, vision/audio, LoRA and training remain explicitly false.
      - [x] **G7a — compressed persistence (2026-08-17):** v3 remains backward
        compatible and adds `mla`, `mla-dsa`, and `mtp-mla` cache kinds. Save,
        async/atomic streaming, clone, prompt/SSD byte accounting, restart
        scan/trim, and copy-restore operate only on checkpoint-native rank-3
        latent/RoPE/index tensors. Model id plus config/tokenizer metadata and
        exact GLM role/geometry reject incompatible restores before tensor mmap.
        Tiny GLM target continuation matches uninterrupted hidden state and
        offsets at dense and sparse prefix lengths; a restored native MTP row
        produces the same next drafts and offset. The focused GLM/kv-store/SSD
        gate passes 42 tests.
      - [x] **G7b — continuous batching (2026-08-17):** a structural
        `BatchableCache` capability now owns GLM's right-justified compressed
        latent/RoPE/DSA rows, per-row offsets, merge, independent extraction,
        filtering, context bounds, and logical byte projection. The scheduler
        dispatches the streamed async model path, admits checkpoint-native
        compressed bytes, preserves mixed-length positions, and forms one
        cross-row MoE expert plan per layer/step. Tiny differential gates match
        mixed-length DSA rows and extracted tips exactly against serial rows;
        an end-to-end scheduler gate covers join, cancellation, sibling
        completion, row filtering, context refusal, and exact projected bytes.
        Gateway/stats advertise `batch` only when the model cache capability is
        live. Native MTP requests remain truthfully serial (`hasDraft`), with
        per-row batched MTP still post-release. The broader focused
        GLM/persistence/gateway gate passes 115 tests with 1,701 assertions.
      - [x] **G7c — serving parity (2026-08-17):** complete and gate every generative HTTP,
        library, CLI, discovery, and telemetry surface listed above. The shared
        generator now awaits streamed experts; `loadContext`/`openModel`, CLI
        serve/pi/generate, native MTP defaulting, GLM tool parsing, explicit
        capability discovery, exact-plan stats, all four HTTP protocols, and
        SSE are synthetic-gated. The fresh real-artifact CLI smoke passed all
        four non-streaming protocols plus SSE under the exact 25 GiB plan;
        health/discovery/stats were correct, SSE terminated in `[DONE]`, and
        chat/SSE reported `serial+spec`. Post-run rows returned to idle. The
        final focused static/synthetic gate passes TypeScript plus 152 tests /
        2,536 assertions with zero failures.
- [x] **G8 — productization:** resumable acquisition or one-shard-at-a-time
      conversion, docs/attribution, 32 GB quickstart, curated memory/speed/
      quality cells in `benchmarks/RESULTS.md`; update README and reference
      models/memory/cli/server-config/server-api/library-api/features-matrix with
      each shipped surface rather than deferring documentation to phase end.
      Aspirational target: **>=2 tok/s warm on the M1 Max 32 GB, MTP on,
      quality-preserving defaults**. This is an optimization direction, not a
      productization blocker; record the actual result and provenance.
      - [x] **G8a — acquisition, recovery, and attribution (2026-08-17):**
        `get` now preflights the exact remaining payload before network transfer,
        credits complete shared blobs and valid resumable prefixes, and requires
        a fixed 1 GiB safety reserve. The pinned ~357 GiB artifact, optional
        `HF_HUB_CACHE` volume selection, rerun/resume behavior, exact 25 GiB
        serve command, model lineage, and Apache-2.0 Colibri source attribution
        are documented. Model-free gate: TypeScript plus 18 downloader/lock
        tests with 56 assertions.
      - [x] **G8b — operator UX and telemetry (2026-08-17):** `fit`, `/fit`,
        `/stats`, and the status UI now use the exact streamed GLM plan rather
        than the generic all-resident estimator. They separate the exact
        artifact-on-disk size from resident weights, main/MTP expert slabs,
        compressed KV, and reserves; report the measured 0.149 tok/s result,
        direct 0.27 tok/s oracle, and 2 tok/s aspiration with distinct labels;
        and publish/show last-turn main/MTP hit rates, SSD bytes, residency,
        policy/forward telemetry, and repin events. There is no standalone
        `doctor` verb; `fit` is the diagnostic command. TypeScript plus 55
        focused GLM/downloader/server tests / 1,910 assertions pass.
      - [x] **G8c — curated evidence (2026-08-17):**
        `benchmarks/RESULTS.md` now records the pinned direct-Colibri/tiny/
        production/real-model/DSA oracle gates; final DSA-aware 19.89/25 GiB
        resource plan; honest G5 before/after compressor/swap caveat; cold/warm
        MTP-on/off speed and footprint; replicated expert-I/O and rejected
        learning policies; paired DSA matrix; and real-artifact API smoke. The
        measured warm quality-preserving 0.1487 tok/s end-to-end result is
        explicitly 7.43% of / 13.45x below the aspirational 2 tok/s target.
      - [x] **G8d — release/docs closure (2026-08-17):** final cross-reference sweep across
        README and the applicable model/CLI/server/library/features references;
        package native expert I/O and verify the fresh-machine command path.
        - [x] Local package/verification (2026-08-17): native pack v0.2.0 and
          the compiled/Homebrew sidecar bundle both include the 53 KiB
          `libmlx_bun_expert_io.dylib`; resolver order covers beside-binary and
          versioned pack-cache layouts. The 52,307,647-byte arm64 pack has
          SHA-256 `9bd3795c5ea8f52b18413501f2d68c32c264a20751302300a08dc04cd67df97c`.
          An isolated empty-cache smoke downloaded/extracted it over the real
          resumable path, loaded MLX, and completed a native positioned expert
          read. The compiled binary bundle also passed version/help/ls/pi
          asset smokes. TypeScript, docs-map, and 74 focused tests / 4,335
          assertions pass.
        - [x] Published GitHub release `native-v0.2.0` after explicit
          authorization. Both assets are uploaded; GitHub reports the archive
          at exactly 52,307,647 bytes with the expected SHA-256. Anonymous
          redirect/HTTP-200 metadata passed, followed by a clean default-URL
          `ensureNativeRuntime()` download, checksum, and extraction containing
          all five required files. Phase 21 G8 is closed.
        - [x] Published the actual mlx-bun v0.0.12 distribution (2026-08-17):
          signed/notarized GitHub release plus stable asset, npm
          `mlx-bun@0.0.12`, and Homebrew tap. Both 80,420,638-byte binary
          assets report SHA-256
          `64c4d697faba65789c2af7c1344ee39024f8a03bd6839d2c8df4ec7dce872a74`;
          npm reports shasum `0dcc5c200fa81dbea1f8be854e21a0efbbdebbfa`.
          Public HTTP, registry, release metadata, and tap contents were
          independently re-read after publication. The full release gate was
          1,936 pass / 71 skip / 0 fail with 28,378 assertions.
        - [x] Post-release admission correction (v0.0.13 review): GLM's fixed
          context now caps an oversized client `max_tokens` upper bound to the
          remaining planned tokens instead of rejecting a prompt that fits.
          The reported 2,788 + 8,192 request resolves to a safe 1,308-token
          completion ceiling inside 4,096. Generic `--memory-budget` serving
          preserves its fail-fast 400 contract, and a prompt that fills the
          GLM context remains rejected. Model-free regression coverage locks
          all three cases.
        - [x] Published mlx-bun v0.0.13 (2026-08-17): reviewed Qwen3.8 text
          support plus the GLM admission correction are live on GitHub, npm,
          and the Homebrew tap. Both 80,421,168-byte release assets have
          SHA-256
          `7766573a6693a6038b2e23cee67f337718d971e2cdbc310f511e4d9155cf5b17`;
          Apple notarization submission
          `edde8b8f-1d8d-4722-878f-0b6eadc63ae5` was accepted. npm's published
          tarball shasum is `c767afe2f2fcdc85c9417934a2b891b4e4218be1`.
          The full two-shard release gate was 1,940 pass / 71 skip / 0 fail
          with 28,382 assertions. Qwen native MTP was deliberately removed
          from the release surface after review proved recurrent-state
          rollback unsound; startup still recognizes its artifact and fails
          before target weights are opened.

**Correctness boundary:** default quality policy keeps checkpoint precision and
true top-8 routing. `CACHE_ROUTE`, expert top-p/top-k, and any expert budget are
Lab-only/KL+task-quality gated. Preserve Colibri's negative result:
`EXPERT_BUDGET` currently has no measured coherent+faster operating window and
must not ship as a normal knob. Several of Colibri's best small-RAM hit-rate
numbers use expert top-p; progress toward the 2 tok/s aspiration must not use
quality-changing defaults.

**Overall exit:** a fresh 32 GB Apple Silicon machine with adequate fast disk
can start GLM-5.2 and complete a chat within the measured <=25 GB contract from
one documented mlx-bun command sequence; its actual cold/warm speed with serial
MTP on and quality-preserving defaults is provenance-recorded on the M1 Max
32 GB, including the gap to the aspirational 2 tok/s target;
save/restart continuation, mixed-row continuous batching (ordinary decode —
batched MTP is post-release), tools and structured output work through chat
completions, text completions, Anthropic Messages, OpenAI Responses, the
library and CLI; the live expert map and offline Atlas are available;
oracle/native results are provenance-recorded; and no default changes
precision or router semantics.

## Phase 22 — pre-Colibri stabilization burn-down `[x]` (opened 2026-07-29, closed 2026-07-29)

This phase **interrupts Phase 21 before G4**. Full inventory, proof contracts,
execution waves, and exit criteria:
**docs/design/pre-colibri-stabilization.md**.

**Decision:** treat the 25-item intake as a risk-ranked evidence program, not
one omnibus patch. Source line numbers are discovery anchors, not identities.
Every active item gets a stable ledger ID, a failing regression or measurement
before production edits, an explicit invariant, a narrow patch, an adversarial
test, and a recorded outcome. The two performance items remain hypotheses
until measured. WebSocket Origin, `/api/*` CSRF, and wildcard CORS stay grouped
and deferred while loopback-only is an enforced product invariant; any
supported non-loopback/tunnel/proxy deployment reopens all three together.

- [x] **S0 — baseline and proof harnesses:** record environment; reproduce or
      disprove every active item; create model-free failure injection and
      deterministic perf harnesses. No “fixed by inspection.”
- [x] **S1 — P0 safety/lifetime:** web-fetch SSRF + redirect/body cap;
      expert-I/O wait/close ownership; streaming and non-streaming
      cancellation across OpenAI/Anthropic/Responses; exception-safe GPU job
      lease.
- [x] **S2 — P1 correctness/durability:** PEFT adapter layout and awaited
      metadata; canonical IFEval semantics; B>1 token accounting; LoRA+ scope;
      Responses TTL/LRU; grammar degrade/top-logprob alignment; blob-ID
      validation.
- [x] **S3 — P2 resources/gates:** diffusion, weights, and closure failure-path
      ownership; remove dead Gemma job read; include shipped web/test sources
      in typecheck; include the model-free serving-load test in the gate.
- [x] **S4 — measured performance:** establish scaling/latency baselines for
      incremental detokenization and serial logprob readback; optimize only
      when material; require paired A/B plus exact output parity.
- [x] **S5 — closeout:** all P0/P1 fixed or disproved; P2 fixed/disproved or
      bounded and explicitly parked; full typecheck/hygiene/model-free gate
      green; public docs updated with behavior; ledger evidence complete.
- [x] **Resume Phase 21:** stabilization exit is green and Phase 21 is
      explicitly unpaused. Next, run the remaining G1/G3 quiet kernel and
      passive-worker power matrix, choose stock MLX versus custom Metal per
      shape, close G1/G3, then begin G4 serial native MTP.

**Exit:** the exact gate in the design doc is green and `STATUS.md` explicitly
unpauses the Phase 21 resume sequence. Conditional remote-deployment hardening
does not block while loopback-only remains the supported contract.

## Phase: oMLX adoption wave 1 — batching parity + SSD cold tier `[x]` (2026-07-02)

Trigger: Josh found oMLX (github.com/jundot/omlx, Apache 2.0, 17.4k★ in 4.5
months) and directed a systematic feature adoption. Governing doc:
**docs/design/omlx-adoption-map.md** (scoreboard + queue + porting
discipline). Tier ruling: oMLX is NOT an L1/L2 oracle — its stock forwards
ARE mlx-lm's (our existing L1), its inventions are oracle-less (our L3
class), its product surface is tier-agnostic serving layer.

- `[x]` **Same-machine head-to-head** (M1 Max, their running server, shared
  snapshots): single-stream we win e4b + Qwen3.5 + TTFT 3–7× everywhere;
  they win cpm5 decode +20%. Measurement traps found: their SSE burst
  streaming inflates naive tok/s ~55% (wall-clock only vs them); their own
  server log over-reports similarly.
- `[x]` **Batching parity** (docs/design/batching-perf-path.md): P5 SSM
  batched path (SSMCache mergeRows/filter, "ssm" scheduler kind, per-row
  RoPE in qwen3_5; oracle: tests/qwen35-batched-parity.test.ts token-exact
  vs mlx-lm B=2) + **per-row logits processors batch** (Qwen3.5 ships a
  default repetition penalty in generation_config.json that silently routed
  every request serial — the SSM port alone changed nothing over HTTP until
  this landed). Result at `--batch 4`: cpm5 **349 vs 339 (win)**, e4b −3%,
  Qwen3.5 −1%, mean TTFT 2–3× better than oMLX under load.
- `[x]` **Burst decode: BUILT AND REFUTED** — their `_step_burst` amortizes
  Python GIL ping-pong; faithful port regressed cpm5 B=4 345→289 (Bun has
  no GIL; bursting only delays SSE flushes). Reverted, breadcrumbed.
- `[x]` **Footgun fixes**: `--model <path|query>` now a real override in
  serve/bench (was accepted-but-ignored; auto-pick silently loaded the
  wrong model — poisoned a bench round); serial-lane event-loop starvation
  fixed (≥25 ms macrotask hop in the gateway serial branch — /stats went
  2.5 s → 10–44 ms mid-generation, decode unchanged).
- `[x]` **SSD KV cold tier** (docs/design/ssd-kv-cold-tier.md): kv-store v2
  (all five cache kinds incl. quantized + SSM, invalidation metadata,
  atomic writes), SsdCacheStore (files-are-the-database, mtime LRU,
  self-quarantine), PromptCache spill/restore + debounced write-behind.
  **Measured: restart TTFT 12.1 s → 0.24 s** on a 13.7k-token prefix (2% of
  full prefill, beats oMLX's 1–3 s), **0% decode overhead** (vs their ~20%).
  Correctness bar: SSD restore ≡ RAM cache-hit output (control-verified;
  fresh-prefill divergence is the pre-existing prefix-reuse bf16 property).
- `[x]` **Structured output / grammar-constrained decoding** — built on
  branch `feat/structured-output` (2026-07-02), merged to main 2026-07-03:
  `@mlc-ai/web-xgrammar` (WASM, the same engine oMLX uses) per-step token
  bitmask at the sampler; full `response_format`/`guided_*` surface on chat
  + text completions; serial AND batched lanes (B0 routing + B1 per-row
  matchers + wasmQueue); L2-verified vs oMLX (byte-identical content);
  degrade path (prompt injection + Warning header, never 500); kill
  switches MLX_BUN_GRAMMAR=0 / MLX_BUN_GRAMMAR_BATCH=0. Design + review +
  follow-up plan: docs/design/structured-output.md. Open: B2 model-gated
  batch tests + bench, F4–F7 follow-ups (compiler cache, real regex,
  choice escaping, thinking-model structural tags).
- `[~]` Queue (adoption map): menu bar app, EnginePool
  model switching, oQ quantization, DFlash serving wiring, vision feature
  cache, batching P0–P3 refinements (extend-join, vectorized sampling,
  admission, defaults review).

## Phase: serve-bench defect sweep — cache invariant + FFI deadlock `[x]` (2026-07-06)

The 2026-07-06 serve h2h (M1 Max 32GB, quiet machine — numbers VALID)
surfaced five defects. Multi-agent verified investigation (20 agents,
adversarial re-read of every cited line) + fixes, all landed together.

- `[x]` **FFI dtor deadlock (product bug, was "cpm5 serial timeout"):**
  fromPointer's JSCallback dtor ran on the Metal completion thread when it
  held the last Data ref → serving deadlock (completion↔JS mutual wait) or
  SIGTRAP mid-GC. Deterministic repro: SSD-restored KV + streamed request.
  Fix: native `dlsym(free)` no-op dtor + restore mmaps pinned for the
  process (`retainMmapForProcess` — eager unmap-after-dispose is unsound;
  mlx holds buffers until command-buffer completion). Verified: stream,
  forced-GC, and full-sequence repros all pass (188-194 ms restored TTFT,
  9060/9061 cached). LESSON (hard-won): never hand mlx a dtor that can
  call into JS; bun:ffi symbol `.ptr` is the f64-bit-cast bug — dlsym.
  OPEN HAZARD: fromView still uses the JSCallback (expert-offload only).
- `[x]` **The one cache invariant, ported to all three tiers** (mlx-lm
  oracle: insert_segments' prompt[:-1] split, generate.py:1645-48; guarded
  supersede cache.py:1721; shorter-prefix fallback cache.py:1690-92):
  A1 serial boundary = min(stableLen, len-1) + snapshotAt into generate()
  (tokens/caches offset match or corruption); A5 batch-lane boundary
  snapshot (chunk-split at boundary + clone/put; fixes 12B batched 84.4s
  ctx repeat vs serial 0.4s); A2 SSD supersede trimmability guard; A4 SSD
  usability-aware find (header-derived trimmable flag); A3 debounce key
  ns+len; A6 exact-dup dedupe regardless of trimmability; A8 loud logs on
  cold-reject/restore-fail/oversize. Root causes: e4b warm hit was 4
  tokens because EVERY reusable entry needed a ≥1-token trim and e4b's
  wrapped 512-window rings refuse trims (the 4 = the chat-header prefix of
  a short earlier entry); stableLen==len degeneracy (e4b template tail
  survives the probe render) made the old snapshot a full-prompt entry.
- `[x]` **saveKvCache streams (format v3)**: fixed-width hashes → header
  sized before data; one tensor materialized at a time (was: whole entry
  as host blobs — the ~390MB RSS spike the bench's 500ms sampler caught).
  v2 files self-invalidate (machine-local). Prompt-cache default cap now
  8 GB flat (Josh's call; was a flat 2 GB anti-OOM reflex from June 10).
- `[x]` **Bench harness B1-B4** (bench-serve.ts): per-phase abort budgets
  (arms died to Bun's implicit 300s fetch timeout), phase-tagged failures
  keep measured cells, stderr tails, /v1/completions parity probe +
  pinned enable_thinking (mlx-lm's TokenizerWrapper injects
  enable_thinking=has_thinking — template drift rendered as fake engine
  divergence), optiq-mixed single-stream legs seeded, per-leg RSS.
- `[x]` **optiq serve mixed-KV oracle was silently bf16 — arm dropped
  from the default bench.** Runtime-proven with spies (zero quantize
  calls across an 11.9k seedless request) + a live crash repro: seeding
  routes to _serve_single which DOES quantize, the entry lands in the
  shared LRUPromptCache, and the next batchable request kills the worker
  (`_merge_caches: QuantizedKVCache does not yet support batching with
  history`). So the HTTP arm = mlx-lm bf16 re-benchmarked → removed from
  default arms (Josh's call; `--arms ...,optiq-mixed` resurrects it).
  Mixed-KV perf = mlx-bun-mixed vs mlx-bun; correctness = script-driven
  optiq goldens (which DO quantize — the L2 oracle stands).
  lab/repro/optiq-mixed-kv-inert: ISSUE.md (3 defects; one open question
  — the seeded path quantized through NEITHER spied hook, so the exact
  converter needs one more instrumented pass before filing) + repro.py.
  Also measured: `ps` RSS is blind to python-mlx KV memory — never an
  observable for the python arms. Our mixed-KV long-prefill cost (~33%
  vs own bf16) is scheme-intrinsic; lever is upstream quantized_matmul
  split-K.
- `[x]` **Per-row cache extract LANDED (same day):** rows finishing
  inside a multi-row batch get their KV extracted into fresh serial
  caches and put() back (oracle: mlx-lm server.py:864-880
  extract_cache → BatchKVCache.extract cache.py:1080-86 /
  BatchRotatingKVCache.extract cache.py:1417-34, copied per kind:
  extractKVRow, extractQuantRow, BatchedRotating(Quant)Cache.extractRow
  — left-pad stripped, rings de-rolled to temporal order, owned
  contiguous copies, asyncEval'd off the pipeline). Row.fed made
  PROVABLY exact via #pendingReal per-slot flags + fedTainted (a
  placeholder that ever fed refuses extraction — was a fragile timing
  chain). SSM/hybrid layers refuse (per-row offset not derivable —
  unchanged dispose). Gates: merged + !tainted + promptTokens ≥ 256.
  Byte-equality unit tests vs solo replay through ring wrap
  (tests/batched-extract.test.ts) + LIVE: 4 concurrent merged rows on
  cpm5 → every repeat 413/414 cached at ~100ms (was cold re-prefill);
  e4b concurrent + repeats served by boundary snapshots (wrapped-ring
  extracted entries serve EXTENSIONS/multi-turn, not shorter repeats).
- `[x]` **Rerun gate PASSED** (benchmarks-serve-2026-07-06b, same day):
  e4b warm 80ms/657 cached (was 1346ms/4; mlx-lm 259ms); 12B batched ctx
  repeat 705ms (was 84.4s); gemma restart restores in full (e4b 925ms/
  15975, 12B 3617ms/15794 — mlx-lm pays 20-89s re-prefill); cpm5 RSS
  2077→1822MB; every mlx-bun cell green. BONUS root cause: the 12B
  mlx-lm arm's repeated silent death = `Model type gemma4_unified not
  supported` — plain mlx_lm.server can't load 12B AT ALL (zombie HTTP
  front hid it); baseline now launches via optiq register() bf16
  (needsOptiqRegister in bench-serve.ts), measured in the 06c solo rerun
  and spliced. New follow-ups: /v1 leading-whitespace surface diffs vs
  mlx-lm (cpm5 completion leading space, e4b chat leading newline —
  matched-prompt probes, token-identical); kv-quant RSS tripwire
  false-positive on 1B models.
- `[x]` **ctx-repeat gap vs mlx-lm CLOSED** (was 484/705ms vs their 400):
  the stableLen probe re-rendered + re-encoded the WHOLE conversation on
  every request (~150ms at 16k; our JS encode is ~90ms/9.6k tokens vs
  Rust ~15ms). Fixed: probe is peek-gated AND its primer length memoized
  per template mode (special tokens break BPE merges across the turn
  delimiter, so the primer is content-independent; wrong stableLen is a
  quality knob, not correctness — any prefix ≤ len-1 is a valid
  snapshot). Measured after (12B @11k): serial repeat 244ms, batched
  500ms. FOLLOW-THROUGH same day: (a) exact-input encode memo in
  loadTokenizer (repeat encode 95.8ms → 0.0ms; LRU 16 entries / 2M chars,
  ≥4k-char inputs); (b) the "~250ms batch-lane overhead" was
  MISATTRIBUTION — instrumented breadcrumbs show batched ≈ serial
  (261/277 vs 252/257ms; anatomy: take 0.7ms · graph build 7ms · token-0
  GPU eval ~190ms · merge 10ms) once the async write-behind + memo were
  live; the earlier 500ms had the sync flush blocking rep-1. Both lanes
  are now GPU-eval-bound on the repeat path (~190ms 4-token forward over
  11k restored KV) vs mlx-lm's 400ms. Remaining tokenizer levers
  (documented in tokenizer.ts): incremental suffix encode, native port.
- `[x]` **SSD write-behind is now NON-BLOCKING** (Josh's persistence-layer
  design): the gateway lock is held only for findExact + cloneKvCaches
  (zero-copy snapshot, entries immutable → consistent forever); the flush
  runs off-lock via storeAsync/saveKvCacheAsync (shared v3 generator core,
  event-loop yield after every tensor), writes chained serially. Measured:
  the rep-0-behind-the-flush tax is gone (498→277ms; rep-0 ≈ rep-1).
  Eviction-spill and demoteIdle still use the sync store (they already run
  at eviction/idle time, not on the request path).

## Phase: finish-the-list — prefill parity, incremental encode, SSM extract, FFI safety, async persistence `[x]` (2026-07-06)

Six parallel tracks (dynamic workflow: 2 investigations + 4 worktree
implementations), integrated + verified same day (suite 1127/0; parity
suites green on every change).

- `[x]` **e4b long-ctx prefill gap CLOSED — causal-mask fidelity fix.**
  Root cause (confidence 1.0, op-for-op): on every prefill chunk after
  the first, KVCache/QuantizedKVCache.makeMask shipped a MATERIALIZED
  bool [N, offset+N] mask where mlx-lm hands the string "causal"
  (cache.py:114-125) — engaging only multi-chunk, worst on e4b's
  hd=512 full-attention layers (fallback dispatch can't block-skip an
  array mask). Fix: windowless multi-token chunks return mode "causal"
  at ANY offset; windowed/batched keep arrays. This is the FAITHFUL
  port (matches mlx-lm's kernel dispatch), value-identical (bottom-right
  causal), and bit-exact by the golden suites. Paired result (06d):
  e4b prefill@ctx 872 vs mlx-lm 877 (was 862 vs 878; batched arm was
  845) — parity within spread.
- `[x]` **Incremental tokenizer encode** (append-only conversations):
  no per-token offsets in @huggingface/tokenizers 0.1.3, so boundaries
  are recovered by decoding token TAILS (endsWith check, U+FFFD-safe
  backoff); splice = cached prefix + suffix encode with a K=32-token
  seam VERIFICATION window — any mismatch falls back to full encode
  (exact by construction). Guards: specials must be prefix-only
  (post_processor structural check), clean_up_tokenization_spaces
  forced off in offset decodes. Measured: 15.9x (cpm5) / 58.8x (e4b)
  vs full re-encode on a ~10-11.5k base + ~250-char append.
- `[x]` **SSM per-row extraction** (Qwen3.5 hybrids): SSMCache gains
  per-row offsets through mergeRows/advance/filter + extractRow(i)
  (port of mlx-lm ArraysCache.extract, cache.py:673-676, owned
  contiguous copies); scheduler refusal lifted with the coverage gate
  kept (rowOffset must equal promptIds+fed length or the row refuses).
- `[x]` **fromView JSCallback dtor eliminated** (last of the deadlock
  class): expert-offload switched to fromPointer over its
  process-lifetime mmap (the pinned JS view never owned the memory —
  MmapFile.view is an alias); fromView keeps a GC-root pin but hands
  mlx the native free(NULL) dtor; release is explicit + JS-thread-only
  (unpinHostBuffer). No JS-callback buffer dtor remains in the repo.
- `[x]` **Eviction-spill + demoteIdle non-blocking**: PromptCache takes
  a SpillSink — spillOwned receives OWNED zero-copy clones (made
  before dispose) and the server chains storeAsync on ssdWriteChain;
  demoteIdle still frees GPU memory one bounded write-chain hop later
  (documented tradeoff). Legacy sync spill kept for embedders/tests.
- `[x]` **Phase-2 host-tax worklist audited** (see the updated Open
  bullet in the 07-05 phase): compiled-decode-at-B=1 + batched prompt
  cache CLOSED by 06b evidence; the optiq-mixed item reworded (no HTTP
  oracle); still open: 12B KL-max outlier, CPM extend-join golden
  regen, padded-B>1 mask rebuild (measure via forced-padding A/B
  first). Stale "serial is default" comments fixed (cli.ts/server.ts);
  cli.md --batch default corrected to 8.

## Phase: 2026-07-07 serve-bench residuals — A7 RSS, cpm5 detok, 12B step-0 convention `[x]` (2026-07-07)

Three residuals from the 07-07 serve bench @3d56676, each root-caused and
closed (details in STATUS.md, one section per fix):

- `[x]` **A7 ssd-cache RSS** — write side: per-tensor `rawBytes()` JS-heap
  slice → zero-copy `rawBytesView`; restore side: process-lifetime mmap
  retention deleted, streamed copy-restore (`fromBytesCopy` + MADV_DONTNEED,
  STEP-rounded plain-KV capacity); most of the benched leg delta was `ps`
  RSS *accounting* (write-behind CPU-touch makes GPU pages visible).
- `[x]` **cpm5 completion-probe ✗ (trailing space)** — detok artifact:
  mlx_lm.server never finalizes its BPE streaming detok, silently dropping
  a final bare-space token ("Ġ"); StreamDecoder now mirrors the hold-back
  (`bareSpaceTokenId`), regression-pinned model-free.
- `[x]` **12B completion-probe ✗ (near-tie flip at step 24)** — step-0
  prefill convention: mlx-lm (both routes) drains the prompt to len−1 and
  computes step-0 from an L=1 forward of the last prompt token; we forwarded
  the whole final chunk (ulp-different logits AND last-token KV → greedy
  flips). generate.ts + batch-scheduler.ts now tail-split
  (`MLX_BUN_PREFILL_TAIL_SPLIT=0` kill switch). Verified bit-exact vs
  oracle per step (64/64 ids + top-2 logprobs, 12B and cpm5) and
  byte-identical over HTTP vs live mlx-lm (cpm5/e4b/12B × completion/chat
  × unified/--batch 1). Mixed-KV golden composition re-anchored to the
  oracle serve loop (step-0 GEMV/GEMM argmax anchors RETIRED — strict
  bit-compare now passes); padded-row KL envelope recalibrated for the
  new join geometry. Spec-decode lane (opt-in) still on the old
  convention — re-anchor with its own oracle when next touched.

Residual: quiet-machine bench rerun for quotable perf/RSS legs (numbers
this session were on a loaded box — parity results are load-independent).
