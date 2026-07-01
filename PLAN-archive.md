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
docs/investigations/pi-builtin-investigation.md (investigation + P1–P4 plan +
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
gotchas + glossary: [docs/investigations/steel-flash-cce-handoff.md](docs/investigations/steel-flash-cce-handoff.md).**

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
report (start here): [docs/investigations/segmented-backward-handoff.md](docs/investigations/segmented-backward-handoff.md)**
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
  [docs/investigations/expert-offload-single-user-moe.md](docs/investigations/expert-offload-single-user-moe.md).
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

