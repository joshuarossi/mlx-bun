# PLAN

Working plan for mlx-bun. Each phase has an exit criterion — we don't move
on until it's met. Status markers: `[ ]` todo, `[~]` in progress, `[x]` done.

> **Current state / what's next lives in [STATUS.md](STATUS.md).** This
> file is the durable phase log + findings; STATUS.md is the live handoff.

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
  mlx-lm 0.31.3, mlx-optiq 0.2.15 (upgraded from 0.2.4 on 2026-07-06;
  mixed-KV goldens regenerated and byte-identical across the bump —
  the script-path oracle is stable), pillow. No source code in that dir;
  it's just the venv + `serve.sh` (working reference server,
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


> Completed early history — Phases 0–5 and 8–11, Optimization Plans A–D, and the early session-handoff blocks — lives in git history (`git show 3199c75:PLAN-archive.md`). (Phases 6 `[~]` and 7 `[ ]` remain active below.)

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
      **12B MEASURED (2026-06-14): γ=1 is a WIN once the verify is fixed.**
      First pass looked like a net loss at every γ, but that was a
      WRONG-ORACLE bug: assistant-drafter spec is an OPTIQ feature (mlx-lm
      can't drive a KV-borrowing drafter), and optiq+mlx-lm both BATCH the
      verify lm-head. Our port verified PER-POSITION to be bit-exact to
      STOCK decode — a target no real impl has, re-reading the ~1GB
      lm-head matrix γ+1×/iter. Fixed (`picksBatched`): one batched verify
      lm-head, matching optiq. Results flip: γ=1/2/3/4 = 1.09/0.91/0.72/
      0.56× (was 0.96/0.77/0.67/0.52×; loaded machine, ratios paired),
      acceptance unchanged 42/29/23/17%. **γ=1 = ~9% WIN on 12B**; γ≥2
      still loses (heavy drafter: hidden 1024, 16 heads, full-262k tied
      head every draft step). Now BIT-EXACT to optiq's spec_generate
      (e4b: identical 48-tok output + identical 60/17/31 trace, via
      scripts/oracle-spec.py + spec-dump.ts). Also: optiq's INSTALLED
      runtime can't drive the 12B/26B unified drafters (config picks
      centroid path, artifact ships none → 0% accept); our tensor-presence
      tied-head detection works (29%) — we're ahead of optiq there.
      TODO: clean-machine rerun before quoting; cheaper drafter head to
      extend the win past γ=1; optional strictVerify flag for the old
      bit-exact-to-stock behavior. Full write-up:
      docs/design/spec-decode-larger-targets.md.
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
      decode 18.5→22.4 tok/s (+21%)**, identical output text. ~~The
      N-tiled FlashAttention prefill port (fused_quant_sdpa) is still
      TODO~~ — done, Phase 10 (2026-06-10).
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

### Phase 6 findings (2026-06-30, faithful DFlash — the REAL DSpark)

- The 2026-06-29 build (`module.ts`, single final-hidden tap, 2 layers) was a
  shortcut that DROPPED the paper's core KV injection — it was never DSpark, and
  its τ numbers (chunk 1.26, articles 1.16) were meaningless.
- Built the **faithful** DFlash in parallel `src/spec/dspark/*-dflash.ts`
  (multi-layer H_ctx, Eq 2–3, injected into every draft layer; 5 layers) +
  `gemma4.ts` `hiddenTap` (parity-safe multi-layer extraction) + `gemma4-base.ts`
  `trim(n, bypass)` (spec rollback past the sliding window). v1 kept as baseline;
  variant-flagged; repo stays at 0 tsc.
- **Off-by-one bug (both v1 and v2):** the TV loss's p^t target was gathered at
  hidden `t+k+1` but block position k predicts `x_{t+1+k}` (target dist =
  `softmax(LM_head(h_{t+k})))`. Shifted one token → every pre-fix τ was trained
  against the wrong distribution. Fixed in `data-dflash.ts`.
- **Architecture proven correct** by an overfit test (3 articles, eval-on-same):
  per-position ~0.75, τ=3.24 — paper-range (0.6–0.9 / 3–4). Width is NOT the
  ceiling (dDraft 1024 ≈ 2560 both plateau ~0.17 pre-scale).
- **Two non-architecture gaps to a net speedup:** (1) DATA — 160 articles only
  generalize to per-pos ~0.17 (paper uses 1.3M×10). (2) TARGET SPEED — the fixed
  draft overhead amortizes only on a slow target: decode e4b 45.9 / 12b 27.5 /
  27B ~15 tok/s; even τ≈3 nets ~0.4–0.5× on fast e4b but could be ~2–3× on 27B.
  **e4b is ~worst-case for spec decode; the 27B agentic workload is the real
  target.** Design: `docs/design/dspark-speculative-decoding.md`.

### Phase 6 findings (2026-06-29, DSpark drafter)

- **DSpark semi-autoregressive drafter built** (DeepSeek DSpark paper port):
  a TRAINABLE parallel-backbone + low-rank Markov head + confidence head
  hanging off frozen e4b, in `src/spec/dspark/` + `scripts/dspark-*`.
  Distinct from the existing optiq assistant drafter (`spec/drafter.ts`),
  which is the A/B baseline. Full design: `docs/design/dspark-speculative-decoding.md`.
- **Decisions:** final-hidden tap (`forwardHidden`, zero model-file changes);
  2-layer backbone (paper Fig 3: beats 5-layer DFlash); Markov W2 init 0
  (starts as pure DFlash, τ climbs). Tap point / multi-layer H_ctx / prefix-K/V
  injection are deferred τ levers.
- **temp>0 is first-class** (lossless speculative SAMPLING: min(1,p/q) accept +
  residual norm(relu(p−q)) resample + bonus; p,q share top-p/top-k/temp
  processing reusing `sampler.ts`). Emit distribution == target p for ANY q —
  proven statistically in `scripts/dspark-smoke.ts` (maxErr<0.01 over 200k
  draws). Greedy (temp 0) path reuses the same `picksBatched`/`trim` spine and
  must match `model.generate` (the deterministic gate).
- **Status:** code complete, repo typechecks 0, CPU smoke 33/33 (incl. full
  ValueAndGrad+AdamW step on a stub model). NOT yet run on GPU: data regen,
  training, the e4b losslessness gate. Same trim-only rollback limitation as
  the existing spec path (rotating caches lose trimability past the window).

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
  softcapped logits) — ~~the 4-bit quantized_matmul kernel rounds
  differently for strided-vs-contiguous inputs~~ SUPERSEDED 2026-06-10:
  Phase 10 root-caused this as the host-side rope-freqs knife edge;
  kv4 is bit-exact with on-device freqs (tolerance deleted).
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

### Flash-CCE / ORPO findings (2026-06-21, L3 pin-leak session)

- **A host-buffer pin leak crashed ORPO training natively** — same
  `"panic: A C++ exception occurred"` class as the wired-limit finding above, a
  DIFFERENT cause. `u32()` (flash-cce.ts + model/flash-attention.ts) built tiny
  kernel-arg arrays with the zero-copy **`fromView`** (pins the host buffer,
  async unpin from mlx's eval thread) but disposed them before the **lazy** kernel
  evaluated → pins leaked **+32/step** (proven with `pinnedBufferCount()`; `active`
  memory dead flat) → a latent use-after-free. **Ran the entire training clean on
  a 32 GB M1 Max; crashed deterministically on a 24 GB M4 Pro** (tighter memory
  reuses the freed-but-pinned buffer sooner). Fix: **`fromBytesCopy`** (copy,
  mlx-owned); hardened `MetalKernel.apply` `ptr()` lifetimes; added a `pinned`
  canary to the train metric. Post-mortem +
  [orpo-flash-cce-pin-leak.md](docs/archive/investigations/orpo-flash-cce-pin-leak.md).
  **Lesson:** `fromView` is only for process-lifetime memory (mmap'd weights);
  any transient host buffer feeding a lazy op and disposed before eval must COPY.
- **L3 (mlx-bun originals) has no oracle — verify by finite-difference +
  teacher-forced, not parity.** mlx-lm/optiq ship no ORPO+CCE training, so the
  flash-CCE head's "0.28% dh" is **fp-reassociation vs a full-logits proxy, NOT
  error**. Correctness is proven by `flash-fd-check.ts` (vs numerical ground
  truth) + the by-hand math audit. The coeff filter's recorded 0.66→2.7% cost is
  on RANDOM data (flat softmax = its worst case); real outputs are sharply peaked
  so filtering the ≈0-softmax tail is near-free — must be measured teacher-forced
  on real hiddens. Standing L3 gates to build:
  - [x] **filter-on-real-data** — DONE (2026-06-22): near-free on REAL targets —
        eps ~1e-5 = 0.16% dh (under the bf16 floor) for 1.35× backward; the
        synthetic 21.4% was a random-target artifact. `flash-cce-filter-realdata.ts`.
        → enable the filter at eps ~1e-5.
  - [x] **DEFAULT FLIPPED (2026-07-02)** — coeff filter AND blockMax skip both
        default 1e-5 (`flash-cce.ts` BWD_FILTER_EPS/BWD_BLOCK_EPS; env=0 restores
        exact). Re-measured on the M1 Max with REAL chunk-ORPO data
        (`flash-cce-filter-realdata.ts`, now also E4B=1 + blockEps sweep +
        full-logits fidelity): filter@1e-5 = CPM5 0.343%/1.41×, e4b 0.158%/1.70×;
        blockMax skip alone ≤0.004% dh at 1.23×/2.02× (real text DOES go cold —
        the old M=512 synthetic "nothing cold" was an artifact); COMBINED 1e-5/1e-5
        = **1.71× (CPM5) / 3.16× (e4b)** backward vs exact. Note: run-to-run dh is
        NOT byte-stable at any eps (atomic-add reassociation) — "eps=0 exact"
        means the identical pre-flip kernel (filter compiled out), not byte-replay.
  - [x] **teacher-forced grad fidelity** — DONE (2026-07-02): flash (at production
        defaults) vs full-logits autograd `dh`: cosine ≥0.99993, relnorm CPM5
        0.913% / e4b 1.220% — the filter adds ~nothing over the pre-existing
        flash-vs-full fp-reassociation (0.850%/1.207% at eps=0). Standing
        regression: `tests/train-orpo-fused-ce.test.ts` "teacher-forced fidelity"
        (cos>0.999, relnorm<5% vs Vjp full-logits reference).
  - [ ] **end-to-end quality eval** of the completed ORPO run (the real proof).
- **Parity-tier DAG → meaningful CLI flags** (roadmap, 2026-06-21). Tag every
  compute node with its parity tier (L1 mlx-lm / L2 optiq / L3 ours; the ORACLE is
  the gate — a node bubbles up only when it can't match a lower oracle bit-for-bit;
  an optimization that DOES match stays low, e.g. compiled-decode is L1). First
  artifact: a zoomable, tier-tagged map of both stacks at
  [docs/dag/training-inference-map.html](dag/training-inference-map.html) — shows
  training as an L1 floor with an L3 island (flash-CCE head + ORPO loss + prefix +
  segmented), inference as almost all L1. The payoff: **flags are route selectors**,
  and the tier of a route says whether a flag is an always-on default, a memory/
  training knob, or a real parity⇄optimization toggle ("what flags push down THAT
  route") — letting us collapse a growing flat flag list into a few intent switches.
  Full design + roadmap: [parity-tier-dag.md](docs/design/parity-tier-dag.md).
  - [ ] derive the DAG from code (queryable; replaces the hand-authored map)
  - [ ] CI gate: an L1-tagged node must pass bit-exact parity vs mlx-lm or be re-tagged
  - [ ] shrink the L3 surface (prove provable nodes down to L1/L2)
  - [ ] rationalize the CLI flag surface from the tier routes

## Phase 7 — Kernel experiments (research track) `[ ]`

Only after profiling shows where bytes move unnecessarily.

- [ ] Profile per-tile dispatch overhead in the N-tiled SDPA path.
- [ ] Custom fused Metal kernel for our exact config (4-bit, group 64,
      Gemma GQA shape): matmul + online-softmax update in one kernel via
      mlx's custom-kernel hook. Target: long-context prefill.
- [ ] Write up findings either way — negative results count; this phase
      is the "research project" part.

## Phase 12 — SigLIP vision tower `[~]` (e4b DONE 2026-06-17, branch `feat/siglip-vision-sidecar`)

Lights up e2b/e4b/26B-A4B/31B image input. The 12B unified
(encoder-free) path was done; **e4b SigLIP now done too.**

- [x] Port the SigLIP encoder + frontend → `src/vision/siglip.ts`
      (`SiglipVisionTower`). Oracle: `optiq/vlm/gemma4/{vision,frontend,
      image_processing,merge}.py`. embed_scale pre-division handled like the
      unified path (features /embed_scale, the LM re-multiplies). Matched
      op-for-op INCLUDING optiq's split of decomposed-f32 RMS norm for q/k/v
      vs fused fast.rms_norm for the block layernorms.
- [x] Closed the two integration gaps: (a) `forwardEmbeddings` no longer
      throws for per-layer-input models — threads zeroed image-token ids into
      the per-layer-input path (e4b/e2b); (b) tower selection by
      `vision_config.model_type` + **lazy loading** on first image request
      (`getVisionTower`/`makeVisionLoader` in `server.ts`).
- [x] Reused the pure-JS decode + PIL-port resize (resize-free fixtures
      bit-exact; resample impurity unchanged). Patchify/pos/pool precomputed
      host-side; 2D RoPE built on-device op-for-op with optiq.
- **Exit criterion → MET (e4b, 2026-06-17):** answers an image question
  end-to-end (grounded gradient description); resize-free fixture tier-a:
  spliced ids bit-exact (256 soft tokens), pre-transformer features bit-exact
  (0.003%), greedy prefix matches, output grounded. Gate
  `tests/e4b-vision.test.ts`.
- **Finding — full features ≠ bit-exact vs optiq (~1.0-1.2% rel-RMSE), but EVERY
  primitive IS bit-exact (NOT a kernel/cross-build issue):** proven model-free
  (`scripts/op-parity-{dump.py,check.ts}`) that mlx-bun's libmlx and the oracle
  venv's mlx-metal are BIT-IDENTICAL on this machine for rms_norm, gelu, matmul,
  clip, cos, sin, the full multidim RoPE, sdpa (no-mask AND array-mask), sdpa
  padded-vs-unpadded (a no-op), and the 3×3 pool (f32 matmul == optiq einsum).
  An earlier "fast-SDPA dispatch boundary" claim was WRONG — a bug in the
  op-test: `toFloat32` mis-read a non-contiguous SDPA output (force
  `ops.contiguous()` before raw readback). The residual is a **sub-bf16
  (≈0.0007%/layer) composition non-associativity that ACCUMULATES** (1L 0.0007%,
  2L 0.02%, 4L 0.14%, 8L 0.20%, 16L 0.68% on bit-exact injected input; embed_vision
  then amplifies 0.68→1.02%). It's amplified by the encoder's design: **scale=1.0
  on RMS-normed q/k → q·k ~N(0, head_dim) → sharply peaked softmax**, so tiny
  roundings flip attention weights and downstream greedy argmaxes. ~0.17% is the
  patchify input (JS `pixel/127.5-1` vs optiq's two-step f32 `2*(pixel/255-0.5)`).
  Switching q/k/v norms fast→decomposed (optiq's own choice) dropped 1.46→1.19%.
  Single images run **unpadded** — bit-identical to optiq's padded+(-1e4)-masked
  path (verified 100% bit-exact), much cheaper. Toggling the LM flags
  (FUSED_GELU/PERF_KERNEL/NO_FUSED_SDPA/FUSED_DECODE) did NOT change the greedy.
- [ ] **TODO(revisit) — drive vision to bit-exact:** every primitive already
      matches the oracle bit-for-bit; the residual ~1% is full-graph composition
      order. The codebase's standard (0.0000% on the text models) is reached by
      matching optiq's EXACT op / lazy-eval / fusion ordering, readable straight
      from `optiq/vlm/gemma4/{vision,merge}.py`. Left at tier-a for now (grounded,
      exact ids, greedy prefix — good enough); revisit to align the op order.
- [ ] **Remaining (not blocking e4b):** audio tower (`audio_tower.*`/
      `embed_audio.*` also in the sidecar); 26B-A4B / 31B SigLIP (same tower,
      untested — pick up by config); video frames.

## Phase 13 — TurboQuant `[x]` v1 LANDED 2026-07-06 (research path — PROMOTED 2026-06-12)

CLOSED — full record archived in git (`git show /Users/joshrossi/Code/mlx-bun/3199c75LAN-archive.md`) ("PLAN archive 2026-08-18").

## Phase 14 — Qwen 3.x family bring-up `[~]` (the MTP home — medium-term, ~Mon 2026-06-15 per Josh)

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

### Phase 14 bring-up — Qwen3.6-27B-OptiQ-4bit `[~]` (started 2026-06-15, branch `qwen3-5-27b-bringup`)

First Qwen target picked: `mlx-community/Qwen3.6-27B-OptiQ-4bit` (already in
the HF cache, 4 shards, ~15 GB). **It is NOT a plain dense Qwen3** — it's the
hybrid **gated-DeltaNet** architecture (`model_type: qwen3_5`, arch
`Qwen3_5ForConditionalGeneration`). Architecture verified from config +
safetensors + the two oracles (mlx-lm `models/qwen3_5.py`, optiq
`mlx_lm_patches/qwen3_5_text.py`):

- **64 layers, hybrid stack.** Every 4th layer (`full_attention_interval: 4`
  → indices 3,7,11,…,63 = 16 layers) is `full_attention`; the other 48 are
  `linear_attention` (gated DeltaNet, Mamba-like recurrent). `layer_types`
  in config is authoritative.
- **Dense MLP** (swiglu, intermediate 17408) — no MoE in this checkpoint
  (`num_experts` absent from text_config). The "27B" is dense params.
- **Full-attention layer** (`Qwen3NextAttention`): GQA 24 q-heads / 4 kv-heads,
  head_dim 256; q_proj emits `24*256*2` and splits into queries + **output
  gate** (`attn_output_gate: true`, `o_proj(out * sigmoid(gate))`); per-head
  `q_norm`/`k_norm` RMSNorm over head_dim; **partial RoPE dims=64**
  (`partial_rotary_factor 0.25`, base 1e7, traditional=False). mrope_section
  is IGNORED — `rope_parameters.type == "default"` takes `nn.RoPE`, not the
  mrope branch (text-only). Reuses our KVCache/QuantizedKVCache + sdpa.
- **Linear-attention layer** (`GatedDeltaNet`): separate `in_proj_qkv`
  (→ key_dim*2+value_dim = 10240), `in_proj_z` (→6144), `in_proj_b`/`in_proj_a`
  (→48 each); depthwise causal `conv1d` (conv_dim 10240, kernel 4, stored
  `[10240,4,1]`, bf16 unquantized); `A_log`[48]/`dt_bias`[48] kept float;
  `RMSNormGated` head_v_dim 128; out_proj. Recurrence = `gated_delta_update`
  which on GPU uses a **custom Metal kernel** (`gated_delta_step`, non-vec /
  non-masked variant for B=1). **Bit-exact parity REQUIRES porting that kernel
  verbatim** (the ops fallback reduces in a different order). Heads: Hk 16
  / Hv 48, Dk 128 / Dv 128; state `[B,48,128,128]` f32.
- **Caches:** `make_cache` = `KVCache()` for full layers, `ArraysCache(size=2)`
  (conv_state + recurrent state) for linear layers. SSM mask = None at B=1.
- **Sanitize (load-time):** mlx-lm conditionally `+1.0`-shifts all norm weights
  and moveaxis-es conv1d **only when** `has_mtp_weights or
  has_unsanitized_conv1d`. For THIS snapshot both are false (conv1d already
  `[.,.,1]`, no mtp.safetensors downloaded) → **plain RMSNorm, stored weights
  used as-is, no shift, no moveaxis.** (Replicate the condition defensively.)
- **Weight prefix:** `language_model.model.layers.N.…`, `language_model.lm_head`.
- **Per-layer quant** (501-entry map): default 4-bit gs64; embed_tokens 8-bit;
  several `linear_attn.in_proj_*` 8-bit. Honored by existing per-module
  `quantFor`.

**Parity bars (Josh):** (1) bf16 KV (KV-quant OFF) → bit-exact vs **mlx-lm**
`qwen3_5.py` (the VLM `Model` wrapper loads this config; optiq's text facade is
bit-identical). (2) mixed-precision KV (ON) → bit-exact vs **mlx-optiq**: the
16 full-attention layers quantized per `kv_config.json` (layers 3,7,…,63 at
4/8-bit gs64) via the existing `maybeQuantizeKv` + `QuantizedKVCache`.

**Sidecars NOT downloaded** (`mtp.safetensors`, `optiq_vision.safetensors`):
MTP speculation and Qwen3-VL vision are orthogonal to both parity bars and are
**deferred** (each needs its own download + parity oracle). 35B-A3B MoE variant
also deferred.

**Future workstreams (Josh, 2026-06-15 — deferred, after parity):**
- **Training** (first-class goal — the reason to replicate optiq's training side,
  not just runtime). `loraTargets()` is wired, but the gated-DeltaNet kernel is
  **inference-only / non-differentiable**. Training requires porting
  `gated_delta_ops` (mlx-lm's pure-mlx sequential scan, the `use_kernel=not
  self.training` fallback) and selecting it under training. cf. the e4b LoRA
  seq-len ceiling (memory-bound backward) — expect similar constraints.
- **Optimizations** (perf kernels, compiled decode, fused paths) — same as the
  gemma path. The per-model file is deliberately structured for the `GENERATED/`
  specialization route (Qwen35Model exposes `protected forwardLayers`): unroll
  the 64-layer loop + delete the layer-type/tie branches → a flat DAG for static
  fusion analysis. The gated-delta kernel stays one opaque fused node
  (the ops-path training variant would be transparent to the analysis).

Bring-up sub-phases (gate each with the parity tests; B=1 single-stream first):
- [x] **14a — config + scaffolding** (2026-06-15). `config.ts` parses qwen3_5
      text_config (linear_* geometry, full_attention_interval, layer_types,
      attn_output_gate, partialRotaryFactor, rope_theta from the flat
      rope_parameters; `type:"default"` ⇒ ignore mrope_section); factory /
      support / registry dispatch for `qwen3_5`/`qwen3_5_text` (MoE variant
      throws). Validated on the real config.json: 64 layers, interval 4, 24/4
      heads @256, partial 0.25, base 1e7, linear 16/48 heads @128, conv 4,
      eos [248046,248044], kv_config = 16 entries on the full-attn indices.
- [x] **14b — primitives** (2026-06-15). Bound `mlx_conv1d` + depthwise
      `ops.conv1d` (weight layout `[C,K,1]` confirmed against the stored
      tensor); `ops.split`, `ops.softplus` (logaddexp(x,0)), `ops.silu`.
      Ported the `gated_delta_step` Metal kernel verbatim + `compute_g` /
      `gatedDeltaUpdate` (`src/model/qwen3-delta.ts`; T passed as a 1-element
      int input to avoid per-length recompiles — numerically identical).
      `SSMCache` (conv + recurrent state) implementing `Cache`.
      **Both are model-free BIT-EXACT vs mlx-lm**: `tests/qwen-delta.test.ts`
      (gated-delta kernel at the real 16/48/128/128 geometry, prefill T=3 +
      chained decode T=1, `toBe(0)`) and `tests/qwen-ops.test.ts` (depthwise
      conv1d + silu, bf16-weight). De-risks the hardest piece without the
      15 GB load.
- [x] **14c — model graph** (`src/model/qwen3_5.ts`, 2026-06-15): GatedDeltaNet,
      gated full-attention (q-gate split, q/k-norm, partial RoPE 64, GQA sdpa,
      `o_proj(out·σ(gate))`), swiglu MLP, hybrid DecoderLayer, model wrapper
      (embed / 64 layers / norm / lm_head / makeCache→KVCache|SSMCache /
      forward / loraTargets / generate). Typechecks; **static weight-name
      audit: 0 missing, 0 unused** (every requested tensor resolves; the only
      index tensors not requested are the optional `.biases`).
- [x] **14d — parity, KV OFF** — **PASSED on Qwen3.5-4B-OptiQ-4bit (2026-06-15,
      M1 Max).** Per-step logits bit-exact (`toBe(0)`) + greedy identical vs
      stock mlx-lm over 12 steps. Golden gen
      `scripts/regen-qwen-parity-goldens.ts [27b|4b]`; test
      `tests/qwen-parity.test.ts` (`MLX_BUN_TEST_QWEN35[_4B]=1`).
- [x] **14e — parity, KV ON** — **PASSED on Qwen3.5-4B-OptiQ-4bit (2026-06-15,
      M1 Max).** Mixed-precision KV (per-layer bits over the 8 full-attn layers,
      SSM layers skipped) bit-exact vs mlx-optiq. optiq's `install_mixed_kv`
      patch uses per-layer bits keyed by cache index — identical to our
      `maybeQuantizeKv`. **Both bars green ⇒ the whole qwen3_5 graph
      (gated-DeltaNet + gated full-attn + tied head + mixed-KV) is correct
      end-to-end on real weights.**
- [x] **Tied embeddings** (2026-06-15) — output head reuses
      `embed_tokens.as_linear` when `tie_word_embeddings` (the 4B is tied; the
      27B is not). Harness + parity test parameterized for both checkpoints.
- [ ] **14f — wiring/polish.** LoRA target map DONE (prefixBase
      `language_model.model`). Remaining: fit/registry capability columns,
      chat template + eos smoke (no server run), and the **27B both bars**
      (~15 GB; same arch as the verified 4B but untied + larger geometry +
      Hv=48 — lower risk now, still worth confirming).

### Phase 14 retarget — Qwen3.8-27B `[~]` (2026-08-16, branch `worktree-qwen3-8-bringup`)

Alibaba shipped Qwen 3.8 in early August 2026. The open local-class release
is **Qwen/Qwen3.8-27B** — a native VLM (image + video, "hour-scale" video)
with a multi-step MTP head, thinking control (`reasoning_effort`
xhigh/medium/low, `preserve_thinking`), 262k native context (1M via YaRN),
and a new XML tool-call format. **Bring-up artifact (Josh, 2026-08-16):
`mlx-community/Qwen3.8-27B-OptiQ-4bit`** (published 2026-08-16, base
`mlx-community/Qwen3.8-27B-bf16`, 5.14 bpw achieved, 4 shards ≈ 17.4 GB,
vision tower included). Rationale: the established artifact pattern (all
primary models here are mlx-community OptiQ quants; `quantFor` honors the
per-layer map), best quality/byte, and the L1 oracle is
artifact-independent (stock mlx-lm loads the same snapshot). Fallback if
the 24 GB fit proves too tight: the uniform `-4bit` (~15.5 GB). Downloads
via OUR downloader: `mlx-bun get <repo>` (mirrors subdir files like
`optiq/…` verbatim). **Scope (Josh): full support — text, thinking
controls, tools, MTP, vision AND video; then retire 3.6.** The 3.6-27B
confirmation in 14f is superseded. Findings from the model card +
config/oracle/shard audit (2026-08-16, remote-verified):

- **The architecture is IDENTICAL to the ported qwen3_5 graph.**
  `model_type: qwen3_5` / `Qwen3_5ForConditionalGeneration`, 64 layers,
  `full_attention_interval: 4`, GQA 24/4 @ head_dim 256, hidden 5120,
  intermediate 17408 (dense swiglu, no MoE keys), linear 16/48 @ 128,
  conv 4, partial RoPE 0.25 @ base 1e7 (`rope_type: "default"` ⇒ mrope
  ignored, as before), untied head, eps 1e-6, vocab 248320,
  generation_config eos [248046, 248044] — byte-for-byte the 3.6-27B
  geometry. Zero new graph work expected.
- **`output_gate_type: "swish"` (new config field) is INERT.** Ground
  truth (transformers `modeling_qwen3_5.py`: `attn_output *
  torch.sigmoid(gate)`), pinned mlx-lm 0.31.3, and upstream mlx-lm main
  (`qwen3_next.py:158`) all hardcode sigmoid; no implementation reads the
  field. Our `o_proj(out·σ(gate))` stands. Guard added to config parse:
  throw on any value other than "swish"/absent, so a future checkpoint
  where the field starts mattering fails loudly instead of silently
  mis-gating.
- **MTP is REAL on this model — the original "MTP home" thesis lands.**
  The raw release ships `mtp.*` in the main shards (15 tensors, ≈0.85 GB
  bf16 / ~425M params: `fc` [2·5120→5120] + `pre_fc_norm_embedding` +
  `pre_fc_norm_hidden` + ONE full-attention decoder layer (gated attn +
  q/k-norm + swiglu, `full_attention_interval=1`) + final `norm`;
  `mtp_use_dedicated_embeddings: false` → binds the TARGET's
  embed_tokens + lm_head). mlx-lm's sanitize DROPS them (and keys the
  +1.0 norm shift on their presence), so **every MLX conversion (bf16
  base, OptiQ, plain 4-bit) is pre-sanitized and MTP-less** — parity
  bars are unaffected, and the OptiQ target needs a SEPARATE drafter
  download: mlx-community publishes the head split out as
  `Qwen3.8-27B-MTP-{bf16,8bit,4bit,mxfp4}` (`model_type: qwen3_5_mtp`,
  block_size 3, already-sanitized single-file repos targeting mlx-vlm's
  `--draft-kind mtp`). Mechanism (DeepSeek-V3 shape, verified from
  `mlx_vlm/speculative/drafters/qwen3_5_mtp/qwen3_5_mtp.py`):
  per step `h = fc(concat(rms(embed(next_tok)), rms(target_hidden)))` →
  the one attn layer (own KVCache, continuing positions) → norm →
  target lm_head → draft token; applied recursively for block_size−1
  drafts ("trained with multiple steps"); prompt-prefill runs the
  module over (tokens shifted by one, target hiddens) to fill the
  drafter KV; after verify, cache.trim(rejected) + append accepted
  tokens with their VERIFY hiddens; greedy = exact target verification.
- **New OptiQ repo layout.** No `kv_config.json`; instead
  `optiq/metadata.json` (per-layer WEIGHT bits, 260×8-bit + 237×4-bit
  gs64) + `optiq/sensitivity.json` + `optiq/optiq_vision.safetensors`
  (in the `optiq/` subdir, not root). config.json still carries the
  501-entry per-layer `quantization` map our `quantFor` already
  honors — the weights map is runtime-independent and loads in stock
  mlx-lm, so L1 is unaffected. There is NO published mixed-KV oracle
  for this model → no L2 bar; mixed-KV serving for 3.8 is Lab-tier
  (KL-gated, default off — 14r-d).
- **Vision tower ships IN the conversion** (`vision_tower.*`, 333
  tensors, depth-27/hidden-1152 dedicated tower + the optiq sidecar).
  Text bring-up is unaffected (we request tensors by name), and the
  registry correctly does NOT advertise vision yet (sidecar is in a
  subdir the root scan ignores; `vision_config.model_type` is
  "qwen3_5", not `*_vision`). Vision + video are IN SCOPE (14v/14w).
- **Serving surface (the card's "own stuff").** Thinking ON by default
  (`<think>…</think>`); `enable_thinking` + `preserve_thinking` (NEW:
  history keeps think blocks — better KV/prompt-cache reuse) as
  chat_template_kwargs; `reasoning_effort` xhigh/medium/low as a
  request param the template maps to instruction text; two recommended
  sampling presets (thinking: temp 1.0 / top_p 0.95 / top_k 20;
  instruct: temp 0.7 / top_p 0.8 / presence_penalty 1.5); optional
  split budgets (262k reasoning / 131k final); XML tool-call format
  (`<tool_call><function=name><parameter=...>`). Parity/bench prompts
  must pin `enable_thinking` explicitly (standing TokenizerWrapper
  hazard).
- **Oracle map.** Text: pinned mlx-lm 0.31.3 `qwen3_5.py` runs this
  model_type unchanged → the L1 bit-exact bar stands. Vision/video/MTP
  reference implementation: mlx-vlm (its `qwen3_5` model + the
  `qwen3_5_mtp` drafter the mlx-community MTP repos target). No
  published mixed-KV oracle for this model.
- **1M context via YaRN** is a config override (`rope_type: "yarn"`,
  factor 4.0, `original_max_position_embeddings: 262144`). Static YaRN
  hurts short contexts (card note) → opt-in flag only (14y).
- Ecosystem notes: `RadixArk/Qwen3.8-27B-DSpark` drafter exists (DSpark
  program tie-in, 14h); `mlx-community/Qwen3.8-27B-4bit`/`-8bit` exist
  as uniform-quant fallbacks; the 2.4T-A95B flagship is irrelevant
  locally.

Sub-phases (gate each; B=1 single-stream first; downloads via
`mlx-bun get`; Josh started the target download 2026-08-16):

- [x] **14r-a — scaffolding (model-free, 2026-08-16).** `tests/paths.ts`
      SNAPSHOT_QWEN38 + gate; regen script `38` target (bf16 bar only —
      no L2 oracle for this model); `tests/qwen-parity.test.ts` gains
      `MLX_BUN_TEST_QWEN38=1`; `output_gate_type` guard in config parse.
- [x] **Download** `mlx-community/Qwen3.8-27B-OptiQ-4bit` (~17.4 GB) —
      complete 2026-08-16 via `mlx-bun get`; all 4 shards + tokenizer +
      the `optiq/` subdir mirrored correctly (downloader handles
      subdir rfilenames — confirmed on real payload).
- [x] **14r-b — text parity (L1) — GREEN (2026-08-16, M4 Pro), then
      STRENGTHENED same day at Josh's ask ("all logits, not just
      greedy").** Final gate: the FULL PREFILL GRID (logits at every
      prompt position × 248,320 vocab, `maxDiff toBe(0)`) + 32 decode
      steps with the complete logit vector bit-exact at each + greedy
      identical vs stock mlx-lm, all on the published OptiQ artifact
      (1 pass / 66 expects). Harness upgrades landed with it: regen
      writes `<prefix>-prefill-logits.bin` + `prefill_positions`,
      step count via MLX_BUN_PARITY_STEPS (manifest-driven in the
      test), 30-min opt-in test ceiling (27B-class swaps hard on
      24 GB; ~30 s/step under pressure — wall-clock meaningless,
      paired parity pressure-immune). Config parse verified all
      geometry (64L/interval 4, 24/4@256, linear 16/48@128, partial
      RoPE 0.25 @1e7, untied, vocab 248320, eos [248046,248044]);
      `output_gate_type: "swish"` guard passes. Retires the 14f "27B
      both bars" line — 3.8-27B supersedes 3.6-27B as the open 27B
      target. STILL OPEN from this item: the artifact provenance
      check (perplexity/eval sanity — parity cannot catch a botched
      conversion; a bad artifact is equally bad in both stacks).
- [~] **14r-c — serving features + docs** (template layer DONE
      2026-08-16; serve smoke remaining). Implemented + verified
      against the real template: `reasoning_effort` maps into the
      template as depth (minimal/low→low, medium→medium,
      high/xhigh→xhigh; "xhigh" now a first-class request value;
      passed ONLY to templates with readsReasoningEffort — the 3.8
      template raises on unknown levels); `preserve_thinking`
      chat_template_kwarg (verified: true keeps history think blocks,
      false drops); thinking auto-detected think-tag, generation
      prompt opens in `<think>` (existing splitter streams
      reasoning_content); tool-call format ALREADY parsed by the
      Qwen-style `<function=name><parameter=…>` parser from the 3.5
      work (verified on the exact 3.8 shape incl. multiline params);
      primer-cache mode key extended with the new template modes.
      Sampling: generation_config carries the thinking-mode preset
      (1.0/0.95/20); the existing no-think temperature clamp (≤0.7)
      matches the card's instruct preset; instruct top_p 0.8 /
      presence 1.5 left as documented recommendations, not silent
      overrides (mlx-lm default-parity). Docs landed (server-api,
      README ×3, features-matrix). REMAINING: an end-to-end serve
      smoke (thinking stream + tool round-trip + eos) on the live
      server.
- [ ] **14r-d — KV compression (Lab).** No published mixed-KV config
      for this model → the affine per-layer path has nothing to
      mirror; **TurboQuant is the primary KV story for 3.8**
      (`--kv-quant turbo:k8v3`): head_dim 256 ∈ supported set
      {64,128,256,512}, and maybeTurboQuantizeKv already skips the 48
      SSM layers (only plain KVCache converts) — structurally works
      today, needs its per-model KL/quality gate cell on 3.8 (the v1
      gate ran on CPM5). Context math: 16 KV layers ≈ 64 KB/token bf16
      → 262k ctx ≈ 16.8 GB (doesn't fit anywhere) vs ~6.6 GB at k8v3;
      SSM state is constant (~150 MB) regardless of context. Uniform
      affine kv8/kv4 stays as the simple mlx-lm-comparable option.
      All default OFF; KL + quality gated vs our own bf16-KV baseline.
- [x] **14g — MTP speculation: DeltaNet rollback SOLVED (2026-08-18); real-
      artifact pairing gates remain.** The 2026-08-17 review block (48
      `SSMCache` instances return `isTrimmable() === false`, so the shared
      loop disabled speculation before round one) is resolved by design (a),
      recurrent-state snapshot/restore, implemented as the **spec-round
      contract**: optional `Cache.specRoundBegin/Commit/Rollback` (gemma4-base),
      `SSMCache.specRound` (qwen3-delta.ts), and the serve loop arming every
      verify forward. Snapshot is FREE (MLX arrays are immutable — the layer
      hands its replaced conv/recurrent refs to the round instead of
      disposing) and partial-reject rollback restores the snapshot then
      REPLAYS the kept `kAccept+1` window tokens through conv1d + the delta
      kernel from recorded position-local inputs (`qkv`/`a`/`b`, retained not
      copied — a few hundred KB per round). Replay is bit-exact by
      construction: the kernel's per-thread loop is serial, so the prefix
      arithmetic is identical whether or not the rejected tail was processed.
      Gates GREEN on the M1 Max (2026-08-18): (1) kernel prefix property —
      full window vs prefix+chained tail bit-exact in y and state at the real
      head geometry, every split point (tests/qwen-ssm-specround.test.ts);
      (2) round lifecycle/guard rails (same file); (3) REAL-WEIGHTS serve-loop
      losslessness on the 0.8B hybrid — ngram spec token-identical to non-spec
      greedy at γ=3/γ=10, with the echo prompt proving real accepts AND real
      rollbacks (tests/qwen35-spec-ngram.test.ts; also newly enables ngram/
      two-model spec on ALL qwen3_5-family targets). The provider
      (src/spec/qwen-mtp-source.ts), pre-final-norm tap, `--draft-kind mtp`,
      and the gated pairing test (tests/qwen38-mtp.test.ts) are restored.
      **27B PAIRING GATE GREEN (2026-08-18, M1 Max, post-merge of PR #36):**
      `MLX_BUN_TEST_QWEN38_MTP=1` passed — spec output token-identical to
      non-spec greedy on the real target+head, acceptance 88% (30/34), 2.82
      tokens/target-forward. Paired wall-clock decode was 14.31 vs 16.58
      tok/s (MTP on 0.86× off) on a just-rebooted box (load ~9, OFF arm ran
      cold-pages first) — NOT quotable; the bf16 drafter's per-step cost eats
      the 2.8× forward savings.
      **All follow-ups closed (2026-08-18, quiet M1 Max):**
      (1) QUIET-MACHINE TPS A/B (scripts/experiments/qwen38-mtp-ab.ts,
      interleaved off/on ×3, 128 tokens, spreads 2.2%/4.4%, arms
      token-identical every repeat): median OFF 15.75 vs ON 12.93 tok/s —
      **MTP-on is 0.821× at γ=2 despite 61% acceptance and 2.25
      tokens/target-forward**. The head's serial per-draft cost (full-vocab
      lm-head matmul + sample per draft) exceeds the saved 27B forwards.
      Durable negative perf verdict; MTP stays opt-in via --draft-model.
      Levers if reopened: quantize the head, batch/defer its per-draft
      lm-head sampling. (2) DIRECT DRAFTER-LOGIT PARITY vs the mlx-vlm
      0.6.14 reference (scripts/experiments/oracle-qwen38-mtp-logits.py +
      qwen38-mtp-logit-parity.ts; our drafter fed the ORACLE's captured
      pre-final-norm hidden grid so target drift can't leak in): draft
      tokens EXACT through the chained block ([513,279,31784]), top-8
      ordering identical every step, worst |Δlogprob| 1.9e-1 = the
      bf16-vs-f32 logprob-representation floor (ours bf16 logits−logsumexp,
      reference f32 log_softmax; bf16 ulp ≈ 0.06–0.125 at these magnitudes).
      Info: the cross-version target tap (venv mlx 0.32.1 vs our pinned
      stack) drifts up to |Δ| 6.0 on Qwen's large-magnitude outlier channels
      (1-ulp bf16 at |h|~1000) — which is WHY the gate feeds identical
      inputs; token0 matched anyway. (3) The M4 Pro swap-starved serve
      smokes PASS on the M1 Max (`MLX_BUN_TEST_QWEN38_SERVE=1`, 4/4, 17.5s)
      — pressure theory confirmed.
      The separate M4 Pro Metal-completion-thread crash under the 20.35 GB
      target plus swap pressure remains a 24 GB artifact-fit finding, not an
      MTP correctness gate; use the uniform 4-bit artifact there until 14z.
- [x] **14v — vision (images) LANDED (2026-08-18, M1 Max).** Oracle =
      mlx-vlm 0.6.14 PINNED to pip mlx 0.31.2 (a scratch venv; goldens
      regenerated there — the 0.32 venv's captures differ at bf16-ulp).
      Pieces, each gated: (1) preprocessor
      (src/vision/qwen3vl-preprocess.ts) — smart_resize + a PIL-EXACT
      8bpc fixed-point bicubic emulation (int coefficients at
      PRECISION_BITS 22, quantized uint8 intermediate between passes;
      the float resizeBicubic differs by ±1 uint8 count) + the exact f32
      normalize sequence → BIT-EXACT pixel grids on all three fixtures
      incl. the resized one. (2) tower (src/vision/qwen3vl-tower.ts,
      bf16 sidecar optiq/optiq_vision.safetensors, 333 tensors) — real
      conv3d patch embed (NEW mlx_conv3d ffi binding, packed-stack-args
      hazard handled; a value-equal GEMM rounds differently), addmm
      linears (nn.Linear's fused bias path), interpolated pos-embed,
      2D rope, ensure_fused_sdpa's 72→80 head-dim zero-pad replicated:
      BIT-EXACT at 36/576 patches; at 2304 ONE bf16-boundary element in
      block 13 (homebrew-libmlxc vs pip-mlx builds disagree on an FMA
      path — pre-astype f32 0x…7fff vs the tie) amplifies → calibrated
      relRMSE ≤ 2e-2 envelope. (3) language mRoPE
      (src/model/qwen3-mrope.ts) — VERBATIM port of the reference's
      custom Metal apply kernel (f32 angle/cos/sin in-kernel, one
      rounding; a bf16-cos/sin manual path moved step-0 logits ~1.0),
      interleaved selector [11,11,10], get_rope_index port EXACT on all
      fixtures (positions + rope_delta), decode = offset+delta;
      text-only requests keep the untouched bit-exact fast-rope path
      (equal position streams ⟹ mRoPE degenerates to plain RoPE — the
      14v "mRoPE question", resolved). (4) serving —
      forwardEmbeddings + embed splice (segment concat ≡
      masked_scatter), Vision.mrope scoped inside the serial run,
      makeVisionLoader qwen branch, chat-lane branch; /v1/models
      advertises vision automatically. GATES
      (tests/qwen38-vision.test.ts + tests/qwen38-vision-serve.test.ts):
      model-free 5/5; gated tower 3/3; e2e greedy TOKEN-EXACT on
      grad-500x300 + grad-768, grad-96 exact ≥16 tokens then flips a
      near-tie — mlx-vlm's language implementation is INDEPENDENT of
      mlx-lm (our bit-exact L1 oracle), so a composite bit-match target
      does not exist; step-0 argmax exact on all three. Serve smoke
      (real HTTP image chat + follow-up text isolation) PASSES. NOTE:
      never load two 27B instances in one test process (Metal
      completion-thread crash — split heavy describes per file or share
      a singleton).
- [x] **14w — video LANDED end-to-end (2026-08-18).** The AVFoundation
      sidecar is PRODUCTIZED: src/native/frame_extract.swift builds via
      scripts/build-frame-extract.sh into the release bundle AND the
      native pack as `mlx-bun-frame-extract` (build-binary.sh /
      build-native-pack.sh / release-binary.sh wired; NATIVE_PACK_VERSION
      bumped to 0.3.0 — **RELEASE BLOCKER: publish the `native-v0.3.0`
      GitHub release and bake its sha256/size into src/native-pack.ts
      before tagging the next package release**; dev trees resolve via
      env → beside-binary → pack → dist-native → compile-on-demand with
      swiftc, vision/video-frames.ts). Serve surface:
      `video_url`/`video` content parts (Qwen3.5-family only; 256 MB
      body cap; refuses audio composition and non-Qwen models with clean
      400s; AVFoundation needs a real container EXTENSION — the temp
      file sniffs the ftyp brand for .mov/.mp4). Pipeline (previously
      landed): T-aware smart_resize, last-frame padding, REAL
      temporal-pair patchify, tower gridT>1 (pos/rope tiled per frame
      group, attention split at cu_seqlens = h·w per pair), t>1
      get_rope_index. Fixed during the serve wiring: (1)
      hasMediaPart/normalizeMessages didn't know video part types — the
      content array collapsed to text and the video SILENTLY vanished
      (model answered "no video provided"); (2) buildQwen3VLVisionPrompt
      rendered without the request's thinking controls — it now takes
      templateOptionsFor's full options (media prompts honor
      enable_thinking/reasoning_effort/preserve_thinking exactly like
      text). Gates: sidecar decode of the committed clip is PIXEL-EXACT
      vs the committed frames; decoded-clip preprocessing matches the
      golden grid; extractVideos contract; serve smoke = image + text
      isolation + VIDEO request on one server (green). Committed
      fixtures: tests/fixtures/qwen38-clip.mov + extracted frames.
      Remaining non-blockers: `longest_edge` sizing for hour-scale video;
      video × prompt-cache stays bypassed (media contract).
      **2026-08-18 bug-hunt (3 parallel reviewers + CodeRabbit) — all
      confirmed findings fixed, each regression-pinned:**
      (1) THE BIG ONE — the video PROMPT FORMAT diverged from the
      training-time processor: transformers `replace_video_token` renders
      each temporal frame group as `<{t:.1f} seconds><|vision_start|>{pads}
      <|vision_end|>` with PER-GROUP t=1 grids ("timestamps are used to
      separate videos"); mlx-vlm 0.6.14 lacks this entirely and the first
      oracle capture hand-built the same naive expansion (self-referential
      gate). Builder + oracle + goldens redone; behavioral confirmation:
      the model now describes the fixture as "an animation featuring
      shifting shapes" (was: "an image"). Timestamps are frame-pair
      averages formatted with a PYTHON-%.1f port (half-even ties — JS
      toFixed says 0.3 where the reference says 0.2).
      (2) smart_resize used Math.round where Python round is HALF-TO-EVEN:
      an 80px edge resized to 96 instead of the oracle's 64 (silent wrong
      grid; our fixtures dodged it — 240/32=7.5 rounds to 8 both ways).
      Anchored against the pinned venv.
      (3) /v1/responses silently DROPPED all image/video input parts
      (`coerceText` kept only .text) — Codex/Cursor-style `input_image`
      now translates to chat parts; unknown parts reject loudly.
      (4) Anthropic /v1/messages: `tool_result` nested images (the
      computer-use screenshot shape) were silently flattened away — now
      preserved as image parts; video blocks, unsupported image sources,
      and assistant image blocks now reject loudly (the audio doctrine).
      (5) Invalid `reasoning_effort` strings silently FORCED thinking ON
      (any defined value ≠ "none") — now a 400 via validateReasoningEffort
      (covers /v1/messages + /v1/responses through handleChat).
      (6) Scoping/leak batch: model.mrope now installs INSIDE runGeneration's
      try (a makeCache throw could leave a dead request's positions live);
      forwardLayers disposes faMask/h on a mid-loop layer throw;
      buildQwen3VLVisionPrompt disposes all mlx arrays on a mid-splice
      throw; tower load frees the safetensors map on error paths;
      compileFromSource memoizes the PROMISE (concurrent first-use race);
      the video temp file writes inside the try; frame_extract guards NaN
      durations (Swift Int(NaN) traps).
      (7) Decoded-memory bounds (CodeRabbit): the sidecar caps the decoded
      longest edge at 1024px (the language budget always downscales below
      that anyway; a 4K×768-frame clip would otherwise materialize
      ~17.8 GiB) + a 1.5 GiB aggregate decoded budget in extractVideoFrames;
      `data:`-URL and inline-base64 video bodies now honor the same 256 MB
      cap as fetched bodies.
      Deliberately NOT changed: the native-pack sha/size placeholders (the
      documented release-time bake).
- [ ] **14y — 1M context (YaRN), opt-in.** `rope_type: "yarn"` branch
      (factor 4.0, original_max_position_embeddings 262144);
      flag-gated, never default (static YaRN penalizes short contexts
      per the model card). Fit math first — 1M KV on 24–32 GB needs
      the KV ladder (quant/TQ/SSD tiers).
      RESEARCH NOTE (2026-08-18, from the 14v pass): the shipped Qwen3.8
      config is `rope type: "default"` — yarn only activates when the
      user EDITS rope_scaling per the model card, so nothing is silently
      missing today (our ops.rope path has no yarn branch and correctly
      serves the shipped config). The oracle implementation when we build
      this is mlx-lm's generic `YarnRoPE` (rope_utils: correction-range
      beta_fast/beta_slow ramp mask + mscale attention scaling); mlx-vlm's
      rope_utils carries the same math, and its MRoPERotaryEmbedding would
      need the yarn-scaled inv_freq for vision×yarn composition. Port =
      precompute yarn-corrected inv_freq + attention_scaling, feed the
      SAME mrope kernel; the fast-rope text path needs a scaled-freqs
      variant (mx.fast.rope takes freqs= for that upstream).
- [ ] **14r-b2 — consolidate on the best (Josh, 2026-08-16).** Once
      3.8-27B is green and serving, retire the 3.6-27B target: drop its
      paths/test gates/docs rows and let the snapshot gc. Keep
      Qwen3.5-4B as the SMALL arch-regression gate for the shared
      qwen3_5 graph (no small 3.8 exists — the family is 27B + 2.4T
      only), unless Josh calls it too.
- [ ] **14h — DSpark cross-check (optional).**
      `RadixArk/Qwen3.8-27B-DSpark` vs the native MTP head — measure,
      don't assume.
- [ ] **14z — TQ×weights artifact (PROMOTED — Josh, 2026-08-16: this is
      also the M4 Pro FIT lever, not just quality/byte).** The 20.35 GB
      OptiQ artifact swap-crawls on 24 GB (weights ARE the resident
      set; KV is trivial at chat contexts); ~4 bpw via the rotated
      codec ≈ −3–4 GB → ~16.5–17 GB → fits with headroom, and fewer
      bytes/token is a decode WIN on the bandwidth-bound path.
      Interim for 24 GB boxes until this lands: the uniform `-4bit`
      artifact (~15.5 GB, same L1 oracle). Stacking savings: 4-bit MTP
      drafter (−0.6 GB, acceptance A/B) + the vision-tower admission
      fix (budget math only).
      Quantize the bf16 base with TurboQuant's rotated codec at the
      PUBLISHED allocation (their `optiq/sensitivity.json` = the WHAT,
      TQ rotation = the HOW — method/allocation are separate axes).
      Target: ~4 bpw at 5.14-bpw quality (≈3–4 GB off the 27B) or
      better quality at same size — the device-targeted-artifact lever.
      Needs the weights-side runtime story (QuaRot/SpinQuant-style
      rotation folding vs a custom qmm kernel — locate + port prior
      art, don't invent; design sketch = turboquant-kv.md §8, which is
      UNMERGED on `fix/objective-goldstine-a83509` — merge that first).
      Lab tier: KL + quality + bench gates, default off. Sequenced
      after 14r-b/14r-c green.

## Phase 15 — Head-to-head benchmark: mlx-bun vs mlx-lm vs mlx-optiq `[~]`
(matrix complete 2026-06-10 except leg (c)'s purge-cold rows — see
findings; results: benchmarks/benchmarks-h2h-2026-06-10.md + README Benchmarks)

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
      `mlx_lm.server` vs `optiq serve` (with `--kv-config`; mixed-precision KV
      serving now done — see `git show 3199c75:PLAN-archive.md` NEXT UP block; landed Phase 9/10).
      First sub-step needs no Python: our
      server-vs-our-direct overhead via an ephemeral in-process server
      (e4b, idle machine) — pins the "our server adds ~nothing" half
      of the 70%-faster hypothesis.
- **Decision (Josh, 2026-06-10): do not start ANY of these
  measurements — including the Python-free server-overhead sub-step —
  until mixed-precision KV serving landed (see `git show 3199c75:PLAN-archive.md` NEXT UP block;
  now done — Phase 9/10).** The whole matrix runs once, against the real serving config.
- [~] **(c) Startup**: ready-time measured per stack (0.36–0.48 s vs
      0.79–0.95 s); purge-cold first-token rows still open →
      first token (fresh process, page cache cleared vs warm); our
      cached-prefix path recorded as its own row (the Python stacks
      have no KV persistence — capability diff, noted not hidden).
- [x] **(d) Long-context @8k**: decode tok/s + memory with each
      stack's best KV config (ours per kv_config.json; optiq
      `--kv-config`; mlx-lm stock — its gemma4 kv-quant crashes,
      recorded finding).
- ~~NEXT SESSION PICKUP (2026-06-10 morning)~~ superseded — see THE
      HANDOFF BLOCK at "NEXT UP" (the morning matrix shipped, then its
      @8k baseline rows were found invalid; the corrected re-run +
      pickup instructions live there now) (now in git history (`git show /Users/joshrossi/Code/mlx-bun/3199c75LAN-archive.md`)).
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

### Phase 15 findings (2026-08-22 — current M1 Max serve matrix)

- The canonical serve matrix now includes the staged 17 GB
  `mjriii/Qwen3.8-27B` 4/8-bit winner by default. The bundle now carries the
  same-topology Qwen3.6 OptiQ `kv_config.json`; this mixed arm remains Lab
  because no Qwen3.8-specific mixed-KV oracle exists and its RSS diagnostic
  did not prove effective KV quantization.
- On the M1 Max 32 GB, Qwen mlx-bun measured 18.5 tok/s short and 16.5 tok/s
  at ~15.1k context versus mlx-lm's 16.5 and 14.9 tok/s. All bf16 and
  unified-versus-serial completion/chat parity probes passed.
- Restart persistence regressed in the unified lane: e4b and 12B restored
  only four cached tokens while their serial controls restored the full
  ~15.9k cache. Qwen bf16 restored none in either lane; Qwen mixed restored
  15,112. Investigate the scheduler/SSD restore path before quoting aggregate
  throughput as representative for e4b or 12B.
- `benchmark.sh` now runs the existing clean-machine preflight itself, so the
  documented gate cannot be bypassed by using the canonical entry point.
  Curated values and provenance are in `benchmarks/RESULTS.md`.
- Bun 1.4.0 repeated the full matrix with all parity probes green and no broad
  engine-speed shift versus 1.3.14. Qwen measured 18.6 tok/s short and 17.0
  at long context on mlx-bun versus mlx-lm's 16.5 and 14.8. Its short prefill
  remains the exception, 64 versus 85 tok/s, while long prefill ties 87 versus
  88. The SSD durability race and fix contract are written in
  `docs/design/ssd-kv-cold-tier.md`.
- Bun 1.4 optimization audit (2026-08-22): the relevant runtime change is the
  engine-native `bun:ffi` path. A local no-op binding microbench measured the
  production-shaped pointer/u64 call at 11.3-11.8 ns on Bun 1.4 versus
  75.8-77.2 ns on 1.3.14; the fresh closure shape used by `outArray` measured
  13.2-13.9 ns versus 88.0-89.2 ns. The existing direct `C.symbol(...)` call
  sites already receive that improvement, including through the callback
  wrapper. Do not rewrite the binding layer merely to "enable" Bun 1.4 FFI.
- A Bun 1.4 CPU profile of the local Qwen winner at a 794-token prompt measured
  8.89 s prefill on both passes (about 89 tok/s). `forwardLayers` accounted for
  only 64 ms across the complete 22.67 s profiled process and `outArray` for
  18.6 ms; native MLX eval calls accounted for 98% of samples. This direct
  result is already level with the mlx-lm server's 85 tok/s row, so the
  standard server's 64 tok/s result is not explained by JS graph construction
  or failure to use Bun 1.4's FFI JIT. Next isolate the serve/scheduler/cache
  path against direct `Qwen35Model.forwardHidden` before changing kernels.
- Bun 1.4 fixes the macOS arm64 stack-argument ABI repro. The minimum runtime
  and CI pin are now 1.4.0, and conv2d/conv3d use their natural mlx-c header
  signatures; the packed-u64 workaround is removed. The typed-array stale-read
  repro still fails after JIT tier-up, so `read.*` out-parameter reads remain
  mandatory. The ABI cleanup is maintenance, not a measured inference win.
- The SSD restart race now has an explicit durability boundary:
  `SsdDurabilityCoordinator` retains dirty records through debounce, queue
  drops, and failed stores; `POST /admin/cache/flush` and graceful
  SIGINT/SIGTERM await the atomic write; the benchmark records pre-kill
  durability instead of sleeping 2.5 seconds. Targeted cache and ABI tests pass.
  A dirty-machine correctness smoke on unified e4b restored 4,025 of 4,026
  prompt tokens after an observed durable flush; full clean 16k numbers wait
  for the benchmark preflight to clear.

### Phase 15e — prompt-to-response attribution + prefill optimization `[x]` (consolidated 2026-08-22, closed 2026-08-23)

This phase combines two related efforts. The Qwen prefill investigation on
`origin/chore/qwen-prefill-analysis` (`545e935`) already measured the engine
and eliminated several proposed fixes. The prompt-to-response work measures
the surrounding server path. Do not repeat the closed experiments. Use the
end-to-end trace to decide whether the remaining work belongs in server code
or native MLX execution.

The serve benchmark currently computes prefill throughput as
`prompt_tokens / client-observed TTFT`. That is the right product number, but
it combines request handling, prompt preparation, queueing, cache work, MLX
graph construction and evaluation, first-token sampling, serialization, and
the localhost hop.

**Evidence already established `[x]`:**

- e4b served prefill at approximately 1k measured 1,143 versus 866 tok/s
  (+32%), while engine-direct results were generally at parity. Server-level
  work can therefore dominate the product comparison at short context.
- The 13 GB Qwen3.8 compact artifact measured 94.3 versus 107.7 tok/s at
  approximately 256 tokens (-12.5%), 102.8 versus 113.8 at approximately 1k
  (-9.7%), then 94.2 versus 72.7 at approximately 4k (+29.6%). Its decode was
  17% faster. This disproves one universal monotonic scaling story: artifact
  and chunk count matter.
- Qwen prefill is quantized-matmul compute-bound. The DeltaNet scan uses the
  same Metal kernel as mlx-lm and accounts for only about 130 ms per chunk.
  Full weight materialization was a null result. Smaller prefill chunks were
  sometimes faster but changed logits, so they are not an L1 optimization.
- `mx.compile` is closed negative for this path. Captured weights bought about
  8-10% at a roughly 8 GB memory cost; passing weights as inputs removed the
  memory cost and the speedup. The experimental path was removed.
- Bun 1.4 profiling further weakens the FFI-overhead theory: `outArray`
  accounted for 18.6 ms in a 22.67 s Qwen process, `forwardLayers` host work
  for 64 ms, and native MLX evaluation for 98% of samples. Do not optimize FFI
  without new timing evidence that contradicts this profile.

**Working diagnoses to falsify:**

- D1: e4b's short served advantage is mainly lower fixed server work around an
  engine prefill that is otherwise close to mlx-lm.
- D2: Qwen compact's short deficit is inside native quantized operations or
  their submitted graph shapes, not HTTP, tokenization, FFI call overhead, the
  DeltaNet scan, weight paging, or compilation.
- D3: Qwen's long-context crossover comes from mlx-lm degrading with chunk
  count while mlx-bun stays flat. Measure each chunk instead of inferring this
  from request totals.

- [x] **P2R0 — define one timing contract.** Give every request a benchmark
      trace id and record monotonic durations at these product
      boundaries: client dispatch to handler entry; body read + JSON parse;
      validation + chat rendering + tokenization; placement + admission wait;
      prompt-cache lookup/restore; uncached prefill; final hidden to lm head to
      sample/readback of token 0; detokenization + stop/tool processing; SSE
      serialization/write; client receipt of the first event. Continue the
      same trace through steady decode, final-token processing, usage/final
      frame, and socket close. Define cache-hit, partial-hit, and miss as
      separate rows. Do not infer server stage times by subtracting unrelated
      benchmark runs. **DONE 2026-08-23:** versioned `[p2r]` JSONL contract in
      `src/serve/prompt-response-trace.ts`. Leaf stages are additive; named
      totals and per-chunk detail are containers/children and are never summed
      twice. Request traces are passed explicitly because batched rows
      interleave and cannot use ambient async context.
- [x] **P2R1 — instrument mlx-bun behind a diagnostic switch.** Add a small
      request-local span recorder at the HTTP handler, `CompletionExecutor`,
      serial generation loop, `BatchScheduler` admission/prefill path, token
      sink, and response writer. Inside prefill, break out token-array setup,
      each model-forward enqueue, MLX evaluation/readback wait, KV conversion,
      `clearCache`, prompt-cache snapshot/restore, and token-0 lm-head/sample.
      Record per-chunk timings so D3 is directly testable. Emit structured JSON
      after the response so ordinary SSE bytes and the public API remain
      unchanged. Instrumentation must be absent when the switch is off.
      **DONE 2026-08-23:** `MLX_BUN_P2R_TRACE=1`; absent means no recorder is
      allocated. HTTP, executor, gateway, serial, and continuous paths emit
      request preparation, placement/admission, cache, batch setup, prefill
      wall + chunks/KV work, token zero, and first/final write records.
- [x] **P2R2 — mirror the spans in mlx-lm without modifying the oracle venv.**
      Build a benchmark-only Python launcher that imports the pinned server and
      wraps `APIHandler`, `ResponseGenerator._tokenize`, `BatchGenerator`,
      `GenerationBatch`, cache lookup, detokenization, and response writes.
      Use the same trace schema and semantic boundaries. Record any boundary
      that cannot be matched exactly instead of comparing unlike spans.
      **DONE 2026-08-23:** `scripts/oracle-p2r-serve.py` imports and wraps the
      pinned install at runtime, including the optiq registration route needed
      by the 12B. The oracle venv is untouched. Python body parsing precedes
      the wrapped request object, so that boundary is explicitly unavailable
      rather than compared to mlx-bun.
- [x] **P2R3 — run two separate modes.** Product mode keeps both servers'
      normal asynchronous execution and measures critical-path wall time.
      Attribution mode inserts `mx.synchronize()` around model forward, KV
      maintenance, lm-head, and sampling boundaries to isolate completed MLX
      work. Synchronized results are diagnostic because the barriers change
      overlap. Capture one representative Metal System Trace per model to
      expose GPU idle gaps; profiler-attached timings are not headline results.
      **DONE 2026-08-23:** the 1,290-row product trace and 135-row synchronized
      diagnostic trace are in `reports/prompt-response-{rerun,attribution}-2026-08-23-forced.{jsonl,md}`.
      `reports/p2r-metal-five-models-2026-08-23.trace` contains one
      profiler-attached 1k request for every model in one 145.6-second Metal
      System Trace; those timings are excluded from the product medians.
- [x] **P2R4 — measure a token-controlled matrix.** Compare mlx-bun unified,
      mlx-bun `--batch 1`, and mlx-lm on MiniCPM, e4b, 12B, the standard Qwen
      4/8-bit winner, and the 13 GB Qwen compact artifact at 128, 256, 1,024,
      4,096, and approximately 16k prompt tokens where each model fits. Use
      identical token ids or assert identical `usage.prompt_tokens`; generate
      one token for prefill attribution and 64 tokens for the full response
      path. Measure warm-loaded cache misses first, then full and partial cache
      hits; keep process load/page-in separate. Alternate stack order, run the
      canonical quiet-machine preflight, discard warmups, and collect at least
      seven short samples and three long samples per cell. **DONE 2026-08-23:**
      all five models, three arms, five target lengths, three cache states, and
      the one-token/64-token paths completed with exact cross-arm prompt-token
      counts. Each repetition and cache scenario owned a fresh warm-loaded
      process, and arm order rotated. The run was explicitly forced after the
      preflight rejected 582 MB of historical swap; memory was 94% free, load
      approximately 1.1, and no large foreign process was present. Retain that
      waiver in every citation rather than calling it a canonical preflight pass.
- [x] **P2R5 — validate the observer.** Paired tracing-off/on runs must keep
      median TTFT and decode throughput within 2%. Server spans plus the
      client-minus-server remainder must reconcile to client TTFT within the
      larger of 2 ms or 2%. Add model-free tests for span ordering, exactly-once
      closure on success/error/abort, schema compatibility across both stacks,
      and zero trace output when disabled. **DONE 2026-08-23:** the paired
      observer run measured TTFT +0.32% and 64-token total -1.95%, inside the
      2% gate. The focused 43-test trace/serve suite passes, TypeScript is
      clean, and every recorded row reconciles server-first plus client
      remainder to client TTFT.
- [x] **P2R6 — isolate the remaining Qwen operation gap.** Only if P2R1-P2R5
      still place the short-context loss inside synchronized MLX work, dump the
      exact inputs and metadata for representative quantized matmuls and replay
      them in Bun and Python. Match shapes, dtype, strides, stream, warmup, and
      synchronization. Compare library/build identity, Metal kernel name and
      grid, command-buffer count, allocation behavior, external-mmap versus
      allocator-owned inputs, and per-op scaling with sequence length. This is
      the decision point for a layout fix, graph-shape fix, MLX build alignment,
      or upstream report. It is not permission to retry weight materialization,
      chunk-size changes, compile, or generic FFI cleanup without new evidence.
      **DONE 2026-08-23:** a forced-evaluation split first put the standard 1k
      miss at about 1,470 ms in the final L=1 transformer forward, 14 ms in the
      output head, and under 1 ms in sampling/readback. Head-only replay ruled
      the head out. The apparent graph/buffer-lifetime clue was then falsified
      by a controlled cache-disabled Python replay: the same L=1 forward took
      about 1,638 ms without a wired limit and 61.3 ms after mlx-lm's normal
      `set_wired_limit(max_recommended_working_set_size)`. Bun measured about
      1,483 ms unwired and 55 ms wired. The actual difference was policy, not
      token arithmetic or a Bun/MLX execution-strategy defect. macOS now reports
      a 26,800,603,136-byte recommended working set on this host; the old 75%
      threshold was therefore about 20.1 GB and classified neither the
      17,015,296,020-byte standard plan nor the 13,915,442,961-byte compact plan
      as large. mlx-lm's `BatchGenerator` wires unconditionally. A diagnostic
      GPU marker looked promising only because that run also forced wiring;
      holding wiring off left the marker at about 1.97 s, so it was removed.
- [x] **P2R7 — implement one proven lever and re-run the matrix.** Require a
      paired win against the current L1 path, bit-exact logits and trajectories,
      no memory regression, and no loss in decode or concurrent serving. If the
      gap belongs to MLX itself and no local parity-preserving lever wins,
      record that result rather than adding a permanent workaround. **DONE
      2026-08-23:** lower the large-model threshold from 75% to 50% of MLX's
      recommended working set, preserving the 8-9 GB class as unwired while
      covering both Qwen artifacts, and hold the same re-entrant wired scope
      around continuous scheduler GPU ownership as serial generation. Default
      direct replay now measures 55.7 ms for the standard final forward and
      54.0 ms for compact (58.5/56.7 ms through head + sample), with the same
      next token (1365) before and after. The machine-local full-logit golden is
      absent, so that check could not run; the change only adjusts OS residency
      and does not alter graph shapes or numerical operations. The post-fix
      full rerun contains 1,290 product trace rows: seven repetitions through
      1k and three at 4k/16k, with fresh warm-loaded processes for every arm and
      cache scenario. At 1k, standard Qwen is 13,431.0 ms mlx-bun versus
      13,716.2 ms mlx-lm (+2.08%) and compact is 12,780.5 versus 13,553.4 ms
      (+5.70%). Their token-zero stages are 62.5/58.3 ms versus 130.2/128.7 ms.
      At approximately 17.2k tokens, standard is 195.74 versus 196.33 s
      (+0.30%) and compact is 197.09 versus 197.64 s (+0.28%): clean practical
      ties with no long-context regression. Across all 25 cold-prefill cells,
      mlx-bun is faster in 17 and tied within 2% in eight after a five-repeat
      e4b 16k follow-up resolved the full matrix's one noisy apparent loss
      (17.559 versus 17.525 s, -0.19%). Focused tests and TypeScript pass. The
      rejected 512-token chunk lever remains rejected; it is unnecessary and
      numerically different.
- [x] **P2R8 — report causes, not just totals.** Produce an additive table and
      stacked plot for every prompt length: ingress, prompt preparation, queue,
      cache, prefill host work, synchronized MLX work, token-0 work, response
      formatting/write, and client remainder. Include per-chunk prefill timing,
      medians, spread, and raw milliseconds. Store raw traces with the eval
      record; promote quiet-machine conclusions to `benchmarks/RESULTS.md` and
      record which of D1-D3 survived here. **DONE 2026-08-23:** the final
      self-contained report is
      `reports/prompt-response-full-post-wiring-2026-08-23.html`, generated by
      `scripts/experiments/render-p2r-html.ts` from the 1,290-row JSONL source
      of truth plus the focused e4b validation JSONL. It includes the Qwen-first
      verdict, medians/IQR/raw points, full miss/full/partial matrix, 64-token
      decode table, scaling plot, and an interactive additive waterfall for
      every model/context/cache state. Desktop and 360 px layouts plus the
      model/context/cache controls were browser-verified. The run started with
      796 MB of historical swap despite 92% memory free and no competing model
      process, so the evidence is recorded in PLAN/STATUS but remains outside
      curated `benchmarks/RESULTS.md` pending a canonical preflight.

**P2R bring-up findings (2026-08-23, non-quotable harness validation):**

- The real-server schema and lifecycle work on MiniCPM across unified,
  `--batch 1`, and the Python oracle; deterministic cross-arm prompts now pass
  exact `usage.prompt_tokens` equality. The initial random-nonce smoke was
  rejected by that gate as designed and was not used.
- One-sample MiniCPM validation exposed a large named support cost in mlx-lm:
  roughly 55-65 ms before prompt-forward work while constructing/merging its
  `PromptProcessingBatch`, including on a full prompt-cache hit. mlx-bun's
  corresponding setup was about 1 ms. This is a lead for D1, not a result;
  the quiet seven-sample matrix is required.
- Product-mode `prefill.total` is critical-path wall time. `prefill.chunk`
  measures actual prompt-forward calls and `prefill.batch_setup` measures
  cache/batch construction; the remaining difference is scheduler/inter-chunk
  gap. `--attribution` enables matched MLX synchronization barriers and is
  diagnostic only.

**Corrected product findings (2026-08-23 forced local matrix):**

- **D1 survives.** On e4b at 158 measured tokens, prompt-forward work was
  effectively identical (197.3 ms mlx-bun versus 196.8 ms mlx-lm). The 44%
  end-to-end win, 221.6 versus 394.1 ms, came from mlx-lm's 156.9 ms support
  gap plus a 19.1 ms token-zero advantage. At 15,392 tokens the model work
  dominates: 17,565.6 versus 17,479.8 ms total, a 0.49% mlx-bun loss and a
  practical tie. The old three-sample claim that mlx-bun was 3% faster at 15k
  was noise and is superseded.
- **D2 is falsified and the exception is closed.** Standard Qwen's original
  1k loss was almost entirely `token_zero.total`, but matched cache-disabled
  Bun/Python replays show it was caused by mlx-bun's stale large-model wiring
  threshold after the OS-reported recommended working set increased. With the
  corrected policy, standard Qwen's three-run 1k TTFT is 1.82% faster and its
  token-zero stage is about 64 ms faster than mlx-lm. Compact is likewise 1.81%
  faster. Prompt-forward chunks were already at parity; no quantized operation,
  graph-shape, or scheduler deficit remains at short context.
- **D3 is falsified.** Fresh-process per-chunk traces show no special mlx-lm
  degradation with chunk count. Standard Qwen converges from a 9.79% mlx-bun
  loss at 1k to 2.32% at 4k and 0.63% at 16k; the 13 GB compact artifact is
  within 1.34% from 1k onward and within 0.20% at 16k. Both stacks converge as
  fixed work becomes insignificant.
- The corrected Qwen result supports the performance-replacement claim. At 1k,
  both the standard and 13 GB compact artifacts are about 1.8% faster than
  mlx-lm; at approximately 17.2k, the one-run leads are 0.30% and 0.21%, which
  are practical ties. The existing MiniCPM/e4b/12B matrix likewise showed wins
  or ties at long context. No measured cache-disabled prefill or decode cell now
  shows a material mlx-bun regression. Full prompt-cache hits remain a separate
  product capability and are not used to explain this fix.
- Two rejected harness designs are part of the result. Retaining one process
  across repetitions caused Qwen TTFT drift from 3.4 to 8.3 seconds; retaining
  unrelated 16k miss/full and partial caches together OOM'd the Python oracle.
  Fresh process per repetition *and* per cache scenario removed both biases.

**Exit criterion:** client-observed TTFT is reconciled to named stages at short
and long context for every standard model and both Qwen artifacts; tracing
overhead passes the 2% gate; mlx-bun and mlx-lm use matched boundaries; the
Qwen short-context deficit is either closed without a parity/memory regression
or assigned to a reproduced native cause; and no already-falsified experiment
is repeated.

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

### Phase 15 findings (2026-06-11 — the corrected clean matrix)

The post-reboot `./benchmark.sh --redo` pass (commit f23ef4e, eval
rows 200–259, benchmarks/benchmarks-h2h-2026-06-11-Joshs-MBP-2025.md). First
clean-machine measurement of the post-rope-fix/Phase-9/10 engine.

- **The @8k baseline is real this time**: every @8k row carries
  ctx=7993/7996 (context guard passed) and every stack shows genuine
  long-context degradation — the day-one physics red flag is gone.
- **Corrected 12B decode gap vs mlx-lm (clean): −1.9% @short
  (25.3 vs 25.8 bf16), −4.5% @8k (23.3 vs 24.4)** — still real,
  still context-scaling (our internal short→8k slowdown −7.9% vs
  their −5.4%), but ~half the −11% dirty-paired estimate. e4b direct
  still trails −4.4% (54.2 vs 56.7); 26B −2.9% (54.5 vs 56.1).
- **kv-mixed tax is now small**: −1.2% @short / −1.3% @8k vs our own
  bf16 — mixed-KV serving as default is justified.
- **"optiq's fused path is free @8k" is definitively dead**: optiq
  drops 25.6→23.2 short→8k (−9.4% internal), landing at parity with
  our kv-mixed 23.0. The old claim was entirely the 31-ctx artifact.
- **Server headlines hold or improve**: TTFT 45–90 ms vs python
  219–331 ms; ready 0.36–0.47 s vs 0.76–1.0 s; our server tax ≈ 0
  while mlx-lm's server costs itself ~7% decode on the 26B (52.2
  served vs 56.1 direct). Served over HTTP we have the fastest decode
  on e4b and the 26B; on the 12B optiq's served decode edges ours
  25.5 vs 25.2 (−1.2% — the 06-10 matrix had us ahead 25.6 vs 25.5;
  within run-to-run noise but quote it honestly) while paying 331 ms
  TTFT to our 90.
- Failures footer: optiq e4b kv=config (known upstream shim bug,
  cc0c151) and optiq 26B server (no content chunks — the uncatchable
  Metal OOM crash class; mlx-lm's server DID serve the 26B same-day,
  so the differentiation datum now has a companion row).
- ~~STANDING DIRECTIVE (Josh, 2026-06-11): why are we not FASTER than
  the python stacks at direct decode, at ANY context?~~ **RESOLVED
  same day for the 12B (root cause found + fixed, gap closed);
  e4b residual characterized — see "Decode gap RESOLVED" findings
  below.**
- Still open: purge-cold rows (sudo purge, Josh-interactive) and the
  M1 Max rerun (still on pre-rope-fix 6cb4a35).

### Decode gap RESOLVED (2026-06-11 — root cause, fix, residual)

Method: per-step wall-time split of the pipelined decode loop in BOTH
stacks (`scripts/decode-split.ts` + `scripts/oracle-decode-split.py`),
12B, @600 and @8k, same session, paired ratios (dirty machine —
absolutes not quotable, ratios are).

**Structural finding (both stacks, identical):** async_eval blocks
until the prior step's command buffer drains — the "pipeline" hides
only the token READ (t_read ≈ 0.03 ms), never the graph build. Every
decode step pays (GPU step + host graph build) SERIALLY. At equal
loop shape the engines are at parity: hand-rolled loops measured
23.4 (ours) vs 23.5 (python) @600; our MEDIAN dispatch @8k (40.4 ms)
matched or beat python's (41.5 ms).

**Root cause 1 — the context-scaling term: a one-shot
prefill→decode boundary stall.** The first decode step after a long
prefill pays an allocator buffer-cache reclaim of the prefill
transients: step #0 dispatch = 807 ms after an 8k prefill (vs 42 ms
steady), scaling with prompt length. mlx-lm sidesteps most of it
with `mx.clear_cache()` after EVERY prefill chunk (generate_step
_prefill), again after token 0, and every 256 decode tokens — we
never called it. Per-generation (not kernel compile — proven by a
two-pass-in-one-process run). With mlx-lm's clear placement the
stall drops 807 → ~370 ms; a residual ~230–370 ms boundary cost
remains in BOTH stacks (python's @8k prefill ran ~2 s slower than
ours in the same session — it pays the boundary inside prefill).

**Root cause 2 — an accounting asymmetry that turned the boundary
into a phantom "decode gap".** mlx-lm's stream_generate stops its
prompt clock at the FIRST YIELDED TOKEN; generate_step's first
iteration — including the async_eval that absorbs the boundary
stall — runs before that yield, so python bills the boundary to
prompt_time. We billed it to decodeMs. Cross-stack "decode tok/s"
measured different quantities, and the mislabeled boundary cost is
linear in prompt length — exactly the observed −2.6% @2k → −11% @8k
shape. (mlx-lm's clock swap also makes token 0 "free" on its decode
clock — replicated and documented.)

**Fix (all three reference-faithful, src/generate.ts):**
(1) clearCache() after every prefill chunk; (2) clearCache() after
token 0 and every 256 tokens; (3) prompt/decode clock swap at
first-token arrival, exactly like mlx-lm. ffi.ts exports clearCache
(mlx_clear_cache was already bound). 118/118 tests pass; clear_cache
is numerically invisible (allocator-only), parity gates untouched.

**Measured after the fix (same-session paired, ratios):** 12B @600:
23.5 → 25.1 vs python 24.0 — WE ARE NOW FASTER. 12B @8k: 23.8 vs
python 23.9 (−0.4% — parity; was −4.5% clean / −11% dirty). Peak
@8k unchanged (11.06 GB). Quotable absolutes: fold into the next
cleared-machine `./benchmark.sh --redo`.

**Residual (open, characterized): e4b −5% at short context**
(54.5 vs 57.4 paired post-fix). Mechanism: at 17 ms/step the serial
per-step host graph-build (~2–4 ms of bun:ffi op calls) is a 2.3×
larger share than on the 12B; python's pybind graph build is
cheaper. The boundary fix doesn't address this term. Next lever
(Phase 7 research track): shrink per-step host work — candidate:
mlx_compile via mlx_closure (compiled decode graph executes in C++,
eliminating per-step FFI graph construction; Phase 2 verified
mx.compile does not change numerics). Diagnostic flag added during
the hunt: MLX_BUN_FORCE_WIRE=1 (default off, kept per flag policy);
wiring was RULED OUT as a lever for the 12B (forced-wire A/B: no
change, consistent with Phase 6).

### Phase 15 findings (2026-06-10 evening — the @8k artifact + cross-machine run)

- **THE @8k BASELINE ROWS WERE INVALID — harness bug.** bench.ts
  parsed `--prompt-tokens` AFTER the `--baseline` branch had already
  exited, so every python "@8k" row (decode AND prefill, mlx-lm AND
  optiq, BOTH machines) actually measured a ~31-token context — it
  was sitting in the eval DB the whole time (`ctxreq=8000 ctx=31` in
  the row notes). Red flag that should have been caught on day one:
  python's "@8k" decode exactly equaled its short-context decode,
  which physics rules out. FIXED: the baseline now pads in python
  with the same filler convention; bench-h2h refuses to record a
  long-context cell whose child measured < 0.9× the requested
  context (fails into the footer instead). Standing-rule addendum:
  a long-context row must carry its MEASURED ctx, and a stack whose
  long-context number equals its short-context number is broken
  until proven otherwise.
- **Corrected same-evening paired measurements (dirty machine,
  interleaved pairs — ratios meaningful, absolutes not):** 12B
  decode ours-vs-mlx-lm ≈0% @short, −2.6% @2k, −5.2% @4k, −11% @8k.
  Internal short→8k slowdown: ours −15%, mlx-lm −5%. The gap is
  real, grows ~linearly with context, and its shape matches the
  full-attention KV term (the sliding-ring term saturates at the 1k
  window and cannot produce a 2k→8k growth). Invalidated along with
  the old rows: "optiq's fused path is free @8k" (their @8k cells
  were 31-ctx too) — the Phase 10 motivation table needs the
  benchmark-pass re-run; the fused prefill's MEMORY win stands
  (measured in-stack, unaffected).
- **Donation ruled out**: cache buffer data pointers are STABLE
  across 25 decode steps @8k (full-attention KVCache and rotating
  ring both) — mlx donates the slice_update buffers fine; no
  per-step cache copy exists. Combined with bit-exact parity
  (identical graphs ⇒ identical kernels), the linear-in-N extra cost
  is NOT explained by any current hypothesis — needs a Metal-level
  profile (next lever).
- **Cross-machine matrix (M1 Max 32 GB, fresh full run at 6cb4a35)**
  scored the pre-registered predictions: P1 (decode ∝ bandwidth)
  FAILS — M1 Max/M4 Pro measured ratio 1.14 vs 1.47 predicted; chip
  generation sets its own efficiency factor, so fit calibration is
  per-chip-family, not per-GB/s. P3 (TTFT ~CPU-bound, ratio holds)
  CONFIRMED — ours 88 vs 89 ms across chips, python 327–376. P2 as
  pre-registered was confounded by the artifact (both machines
  compared against the same broken baseline); its corrected reading
  is the linear-in-context gap above. P4 untested (26B fits the
  M1 Max's 32 GB; it served at 50.2 tok/s where python's servers did
  45.8–45.9).
- The M4 "rerun" at 17:48 recorded NOTHING (resume window treated
  the morning rows as recent; all cells skipped) — re-baselining
  post-rope-fix/Phase-9/10 code needs `./benchmark.sh --redo` on the
  next reboot. The M1 Max ran pre-Phase-10 code (6cb4a35 checkout).

### Phase 15 findings (2026-06-10, full-matrix run)

- **Full 25-cell matrix landed** (benchmarks/benchmarks-h2h-2026-06-10.md, commit
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

- ~~Registry: per-model LICENSE column~~ done 2026-06-11: `license`
  column from the model card README frontmatter (license_name wins
  when license is "other"); shown in `mlx-bun ls`; schema-drift
  rebuild covers old DBs. ~~bf16 vision-sidecar
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
    state: stock decode AND all quantized-KV paths (kv8, kv4, 26B
    kvmix) — kv4's former 1-ulp tolerance was the host-side rope-freqs
    bug, fixed in Phase 10.
  - **(b) Bounded tolerance** only for intra-stack comparisons of
    paths that differ BY DESIGN: tiled-vs-unfused SDPA (online softmax
    vs one-shot precise, ≤2/128 with measured ≤0.0015,
    tests/fused-sdpa.test.ts) and gather_qmm-vs-quantized_matmul
    (different kernels, tests/moe-ops.test.ts). Cross-stack stays (a).
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
- **Machine-specific goldens (per-GPU bit-exactness).** Logit goldens are
  bit-exact only on the GPU that produced them. First run on a non-reference
  box (M1 Max, 32 GB, macOS 25.5, 2026-06-10) failed 4 bit-exact logit tests
  vs the M4-generated goldens (maxDiff 0.4–1.1). Root cause: brew `libmlx`
  and pip `mlx-metal` ship metallibs that, on the same mlx 0.31.2 source,
  compile identically for M4 but diverge on M1 at the fast-SDPA
  vector→full-attention dispatch boundary — bit-exact for prefill L ≤ 15 and
  all decode steps, first divergence at exactly L = 16, deterministic
  run-to-run on both sides, affecting the fp16/no-quant path too (≤0.84 on
  softcapped logits, ~66% of vocab positions). It is NOT a port bug.
  - **Resolution (implemented):** goldens are layered, not single-set.
    `goldens/<name>` is the reference set (the box keyed by
    `REFERENCE_MACHINE`, default `apple-m4-pro`); `goldens/<machine-key>/<name>`
    is a per-machine override that wins when present. Reads go through
    `tests/goldens.ts` — `golden()` / `goldenPath()` resolve override-then-flat;
    regen scripts write to `goldenOutDir()` (flat on the reference box, the
    override dir elsewhere) so a non-reference regen can never clobber the
    committed reference goldens. Machine key auto-detects from the CPU brand
    (`apple-m1-max`); override with `MLX_BUN_GOLDEN_MACHINE` /
    `MLX_BUN_GOLDEN_REFERENCE`. This box's set is committed under
    `goldens/apple-m1-max/` (kvq-logits, logits-step, parity.json).
  - **Residual:** with the M1 Max overrides in place, the L ≥ 16 kv-quant
    single-forward tests still diverge from this box's own oracle — same
    metallib split, intrinsic to the toolchain, not the goldens. Trajectory
    tests and everything else pass. The bit-exact bar therefore holds on the
    reference machine; off it, document the ≤1-ulp-ish toolchain delta rather
    than chase it. Benchmarking is unaffected.
  - **Recurrence (fixed 2026-07-01): the batched oracles bypassed the layer.**
    The 2026-06-14 batched-serving fixtures (`batched-golden-{cpm,gemma12b,
    e4b,26b}.json`, `batched-dynamic-golden-cpm.json`) were committed flat in
    `tests/fixtures/` and read directly — M4 Pro-generated, never green on the
    M1 Max (bisect verdict: no code regression; mlx-lm regenerated on the M1
    Max reproduces mlx-bun token-for-token). Same class as above: greedy argmax
    over bf16 batched logits is per-GPU. Fix: moved them to `goldens/` as the
    reference set, tests resolve via `goldenAt()`, and the divergent ones on
    this box (e4b, 26b, dynamic-cpm; cpm + gemma12b statics happen to match)
    got `goldens/apple-m1-max/` overrides. Separately, the batch-scheduler
    Gemma test's exact-equality vs that golden was machine-LUCKY even on the
    M4 Pro — the scheduler's merged-solo-prefill and the golden's padded
    one-shot prefill have different reduction orders — so it was converted to
    the teacher-forced KL/argmax gate the CPM scheduler case uses (Gemma bound
    5e-1, justified in tests/batch-scheduler.test.ts; a per-machine
    protocol-oracle gen script is the noted tighter alternative).

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

## Optimization plan Phase E — fused decode-SDPA kernel `[~]` (started 2026-06-11)

- [x] **Step 1 — ground truth FROZEN before any kernel work**
      (goldens/perf-oracle/{12b,e4b,26b}.json): compat-mode greedy
      trajectories @600/@2k + top-128 logits for 4 decode steps under
      the shipped kv_config, keyed by config fingerprint
      (scripts/freeze-perf-oracle.ts). This is the perf-mode gate's
      oracle now that bit-exact-vs-compat won't apply to the kernel.
- [x] **Step 3 — toolchain derisked**: mx.fast.metal_kernel works from
      Bun end-to-end (src/mlx/metal-kernel.ts wrapper;
      tests/metal-kernel.test.ts: f32 + bf16-templated kernels verified)
      — the real kernel debugs numerics OR plumbing, never both.
      mlx_metal_start/stop_capture also bound (metalCapture helper).
- [x] **Step 4 — the fused decode kernel EXISTS and is quality-gated;
      v1 is a documented LOSING experiment on speed.**
      src/model/fused-decode-kernel.ts: one dispatch per L=1 quantized
      SDPA — QK^T + one-shot softmax + ×V, dequant inlined, nothing
      materialized; BITS/GS/D/NREP as template args (Phase D's site
      constants); MLX_BUN_PERF_KERNEL=1, DEFAULT OFF.
      - Numerics: per-dispatch ≤0.007 vs unfused across all 12B site
        shapes incl. real-cache views and N=2101
        (tests/fused-decode-kernel.test.ts). Probing showed any
        implementation that rounds bf16 scores differs by final-rounding
        ties (qmm vs f32-matmul vs bf16-matmul all differ ~1 ulp) — true
        bit-exactness is unreachable; ulp-level per-layer differences
        amplify chaotically through 48 layers, so free-running greedy
        trajectory comparison measures CHAOS, not quality.
      - **Gate redesigned to teacher-forced agreement** (feed compat's
        frozen token each step; contexts identical):
        tests/perf-kernel-oracle.test.ts, threshold ≥56/64, labeled:
        kernel 60/64 @600, 62/64 @2k vs the ACCEPTED tier-b tiled path's
        62/64, 63/64 on the same oracle — kernel quality is at the
        envelope the project already ships.
      - **Speed: 0.72× @8k (paired, serve config) — SLOWER. Root cause:
        occupancy.** One threadgroup per query head (8 sliding heads ×
        128 threads) cannot fill an M4 Pro. v2 lever: flash-decoding
        split-N (G N-blocks × per-block partial (max, sumexp, acc) + a
        merge pass) — the standard fix, deliberately not rushed tonight.
      - **CustomKernel cannot sit inside compiled-decode closures** (no
        output_shapes; closure self-blacklists and the generation falls
        back when the flag is on). v2 should dispatch the kernel from JS
        layers / outside compiled segments, which the segmented design
        already supports for full-attention layers.
- [x] **Step 4b — flash-decoding v2 + the mlx qdot pattern: the kernel
      WINS, +2.2–3.8% paired (2026-06-11).** Single-pass per-block
      online softmax (K and V each read once), grid [128, H, G] with
      G = ceil(N/BLOCK) (BLOCK 128 ≤2k / 512 above — occupancy was v1's
      killer), per-block (max, sumexp, unnormalized o) partials + a tiny
      deterministic merge kernel (no atomics — atomic add order would
      make rounding nondeterministic). Inner loops use the mlx qdot
      pattern lifted from quantized.h (Apache-2.0, translated to plain
      MSL): dequant FACTORED out of the loop (s·Σ(w·q) + b·Σq), 4-bit
      nibbles multiplied masked-but-UNSHIFTED against 16^k-prescaled
      queries via uint16 reads — mask+madd only; the V side transposes
      the same trick (raw per-slot accumulators, 16^k folded once per
      block, bias collapsed to Σp·b).
      Iteration ladder, paired @8k isolated: v1 one-TG-per-head 0.72× →
      v2.0 two-pass split-N 0.945× → v2.1 single-pass 1.013× → v2.2
      qdot-pattern **1.038× @8k / 1.022× @2k isolated, 1.027×
      production** (kernel arm ~23.5 tok/s vs compat ~22.9 @8k).
      Quality at the accepted envelope throughout (teacher-forced gate
      green at every iteration). Compiled-decode integration: segmented
      mode reclassifies quantized layers as JS layers under the flag
      (CustomKernel can't live in closures), so the kernel always
      dispatches outside compiled segments and nothing blacklists.
- [x] **Step 2 answered by measurement instead of capture: the prize was
      THIN** — mlx's quantized_matmul already fuses dequant; compat
      never materializes the dequantized cache, only the ~262 KB score
      row. The 2–3× expectation assumed a fat dequant round-trip our
      port never had. The kernel's real prize = score/softmax
      round-trips + dispatch count ≈ 1% — captured.
- [x] MLX_BUN_PERF_KERNEL flipped to DEFAULT ON (2026-06-11): the
      cleared-machine ./benchmark.sh pass confirmed the win — paired
      kernel vs compat 24.00 vs 23.46 tok/s (1.023×) @8k and 24.75 vs
      24.51 (1.010×) @2k, 12B serve kv_config, median-of-3
      (benchmarks/benchmarks-h2h-2026-06-11-Joshs-MBP-2025.md; eval DB
      rows 333–336). MLX_BUN_PERF_KERNEL=0 is the documented opt-out;
      compat stays the permanent -O0 reference and differential-testing
      oracle (standing rule: losing/optional paths stay as flags, never
      deleted). bench-perf-kernel.ts compat arm now pins =0 explicitly
      (deleting the var means ON post-flip).
      **Scope decision made at the flip**: the kernel dispatches only on
      DENSE architectures (gen-model.ts `dense` predicate = the
      CompiledDecode segmented-mode predicate; today that's the 12B —
      exactly where the win was measured and the frozen oracle exists).
      On whole-graph models the default-ON flag surfaced a latent
      conflict: the CustomKernel can't live in the whole-graph closure
      (no output_shapes → closure blacklists → compiled decode silently
      lost), and keeping it uncompiled-only would make e4b's compiled vs
      uncompiled trajectories diverge. So e4b/26B generated dispatch
      emits compat tiled/unfused only (regenerated 2026-06-11; 12B
      output byte-identical), quantizedSdpa additionally guards with
      !isCompiledTrace() as belt-and-suspenders, and e4b/26B kernel
      enablement stays step 6/7 work below.
- [ ] Step 6/7 — 8-bit-specific tuning and e4b/26B kernels: optional;
      the uniform kernel already handles their site shapes when their
      models leave the MoE/whole-graph constraints.

## Phase 16 — pi built-in terminal `[~]` (direction A; started 2026-06-12)

Full investigation, options, pros/cons, and plan:
docs/archive/investigations/pi-builtin-investigation.md (+ styled HTML twin). pi v0.79.1, MIT,
Bun-compile-native (upstream's own binary is `bun build --compile`).
Users' own pi stays first-class forever; the flagship ends embedded.

- [x] **P1 — `mlx-bun harness pi`** (2026-06-12): src/harness-pi.ts +
      CLI `harness` case. Detects pi without spawning it (the bin shim
      can resolve to a node too old for pi-tui's /v-regexes — version
      read from the adjacent package.json instead); generates a
      self-contained dynamic-discovery extension (registerProvider +
      live fetch of /v1/models with a 2 s timeout, install-time model
      list baked as fallback, registers nothing when both are empty)
      into `~/.pi/agent/extensions/mlx-bun-provider.ts`; `--remove`
      reverses. /v1/models reports `context_window`
      (config.text.maxPositionEmbeddings — note the nested `text`).
      Tests: tests/harness-pi.test.ts incl. executing the generated
      extension against a stub registerProvider + stub /v1/models
      server. Dogfooded on this machine (detected pi v0.79.1,
      install + remove verified).
- [x] **P2 — `mlx-bun pi` v1 (subprocess)** (2026-06-12) **— SUPERSEDED &
      REMOVED 2026-06-14: src/pi-launch.ts is gone; `mlx-bun pi` is the
      embedded agent (P3) and the user's own pi connects via `harness pi`.
      History below.**
      src/pi-launch.ts + CLI `pi` case. Reuses a healthy server on
      --port (default 8090) or loads one (--query resolves via
      Registry; errors helpfully on 0/many models); spawns the user's
      pi via a temp `-e` extension (no global writes), with
      `--provider mlx-bun --model <first>` and **model selection
      scoped to the server's models** (`--models` with EXACT ids —
      the `mlx-bun/*` glob resolves before the async extension
      registers the provider and warns "No models match"; Josh's
      scoped-models requirement). User argv passes through verbatim
      and is appended AFTER our defaults so explicit flags win.
      Spawns cli.js under our own Bun (process.execPath): pi's bin
      shim is `#!/usr/bin/env node` and a stale system node (18)
      crashes pi-tui. FIELD BUG (2026-06-12, first external tester):
      inside the COMPILED binary process.execPath is mlx-bun itself
      and cannot execute cli.js — launcher broke, the error hint said
      `bun add -g`, tester installed bun AND ran bare `pi`, whose own
      onboarding downloaded ITS default model (a Mistral via
      node-llama-cpp). Fixed: compiled pi binaries (pi.dev install.sh)
      spawn directly; JS shims resolve bun via which; hints point at
      the standalone installer; share-zip README warns to always
      launch through `mlx-bun pi`. Tests: tests/pi-launch.test.ts (6). E2E
      dogfooded: `bun src/cli.ts pi -p "Reply with exactly:
      PI-LINK-OK"` → reused the running 26B server → pi answered
      PI-LINK-OK through the local model. Appliance follow-ups
      (2026-06-12, Josh): no-server path now AUTO-PICKS the largest
      supported (gemma4) model that fits via fit(); if NOTHING
      supported is on disk it downloads the recommended model for
      this machine (fit.ts recommendedRepoId — roadmap tiers: <24 GB
      e4b, 24–48 12B, ≥48 26B; resumable+verified downloadModel);
      and lifecycle settled (Josh, same day, after a keep-alive
      detour): a server `mlx-bun pi` starts lives exactly as long as
      the pi session — any exit (clean, Ctrl+C, headless -p) tears it
      down; persistent serving is `mlx-bun serve`'s job (reused and
      never stopped). Parent ignores SIGINT while pi runs: Ctrl+C
      hits the whole foreground process group and pi's FIRST press
      means "clear input" — without the guard the parent (and its
      server) died on the first press.
- [x] **Status page** (2026-06-12, Josh ask): `GET /` and `/status`
      serve an embedded self-contained HTML page (src/status-page.html,
      text-imported so it bundles into the single binary) polling
      /stats + /v1/models every 2 s: model + context, memory bars,
      prompt-cache hit rate, response store, KV-quant layer split.
      `scripts/status-page-stub.ts` serves it with fake stats for
      styling without a model load. First brick of the web UI surface
      (the chat page lands with P4's event plumbing). v2 same day
      (Josh: "make it look AWESOME"): rebuilt in the keynote
      aesthetic (docs/archive/wwdc-mlx-bun.html grammar — black stage, gradient
      hero, blooms, hairline cards) + new `GET /fit` endpoint
      (this-machine FitReport at the admission ceiling + Apple SKU
      matrix @32k, same conservative stance as admission) rendered as
      a "Will it fit? Solved, not guessed." section with the user's
      machine class highlighted, plus a project pillars section.
      v3 additions (2026-06-12): `GET /downloads` (process-global
      tracker inside downloadModel: bytes/files/state + server-side
      rolling ~5 s transfer rate) rendered with speed + ETA;
      `GET /library` (30 s-cached registry + per-model fit assessment
      for this machine) rendered as a Library table — SERVING /
      fits / too big / unsupported(model_type) per row. CLI got a
      full help system the same day: overview, per-command help
      (`--help`, `mlx-bun help <cmd>`), `--version`, unknown-command
      exit 1; `pi --help` is intercepted only as the sole arg so pi
      flag passthrough stays intact.
- [x] **"One binary" decision + native runtime pack** (2026-06-12,
      Josh): the 61 MB executable is 100% ours, but the MLX native
      runtime (libmlx 15M + libmlxc + libjaccl + mlx.metallib 150M)
      shipped as dist/ sidecars — and MLX is NOT part of macOS (Metal
      is; MLX comes from brew/pip). Options weighed: (1) embed →
      230 MB binary, 4× for bytes that aren't ours — rejected;
      (2) require brew — rejected (the Python experience again);
      (3) **first-run download of a versioned pack — CHOSEN.**
      Implemented: scripts/build-native-pack.sh (brew dylibs +
      metallib, load-commands rewritten, tar.gz = 52 MB compressed
      from 166 MB) published as GitHub release native-v0.1.0;
      src/native-pack.ts downloads (resumable + sha256, reusing
      downloadOne) and extracts atomically to
      ~/Library/Caches/mlx-bun/native-v<ver>-<arch>/. Resolution
      order (ffi.ts + nativeRuntimeDir, kept in sync): env >
      beside-binary (sidecar stays for embedders) > pack cache >
      brew. CLI serve/pi call ensureNative() before any module that
      dlopens. PRIVATE-repo caveat: release assets 404 on the plain
      URL — resolveGithubAssetUrl() goes through the API with a
      token (gh auth token / GITHUB_TOKEN) to a presigned location;
      anonymous works once the repo is public. Verified: 4 unit
      tests (fake pack), real-release e2e (52 MB in 16.6 s, verified,
      extracted), dlopen of the extracted pack ok. Local dev command:
      package.json bin + `bun run link-cli` symlink (never downloads
      — brew resolves first).
- [x] **P3 — embedded terminal** (2026-06-14): `mlx-bun pi` now drives
      pi's OWN interactive TUI in-process — no requirement that the user
      install pi (it's a bundled dep). src/pi-terminal.ts builds an
      AgentSessionRuntime the same way pi's CLI does (createAgentSession
      Services + …FromServices + createAgentSessionRuntime, per
      examples/sdk/13-session-runtime.ts) and hands it to the exported
      `InteractiveMode`; `-p`/`--mode json`→runPrintMode, `--mode rpc`→
      runRpcMode. Tool approval is pi's own built-in TUI prompt (no custom
      gate — that's only the web path's WS need). System prompt is a
      FULLY CUSTOM mlx-bun coding-agent persona (replaces pi's default;
      Josh's call). Tools = full coding set + the web tools
      (web_search/web_fetch/weather) + the curated web-research skill.
      Sessions persist under ~/.mlx-bun/pi (so /resume works), isolated
      from the user's own ~/.pi. Provider/registry/auth wiring extracted to
      src/pi-provider.ts and shared by web + terminal so it can't drift.
      Tests: tests/pi-terminal.test.ts (system prompt + argv→mode parser).
      **DECISION (Josh, 2026-06-14): NO external-pi launcher.** An earlier
      cut shipped `mlx-bun pi --external-pi` (spawn the user's own pi). Cut
      entirely (src/pi-launch.ts + tests/pi-launch.test.ts deleted,
      probeServer moved to src/harness-pi.ts) — a user who already has pi
      already knows how to run it, so it was pure duplication. The clean
      split is: `mlx-bun pi` = the built-in agent (interactive + `-p` +
      `--mode json/rpc`); the user's OWN pi (full flag surface:
      --continue/--resume/@file/extensions/themes) connects to the local
      model via `mlx-bun harness pi` (P1, src/harness-pi.ts — sharpened the
      same day as the explicit "connect your pi" tool). **GATE STILL OPEN
      (needs Josh + a TTY + model): the one-process
      editor-latency-during-12B-decode check and a live interactive tool
      round-trip — automatable parts are green.**
- [x] **P4 — single binary**: `-p`→runPrintMode, `--mode rpc`→runRpcMode
      (done in P3). **Web-chat half** (2026-06-14, branch
      web-ui-and-native-lab): the built-in web chat UI rides
      AgentSession.subscribe() events over a WebSocket (src/pi-web.ts +
      /ws/chat) with a real pre-execution tool-approval gate. **Terminal
      assets folded into the compiled binary (2026-06-14)**: build-binary.sh
      now sidecars pi's by-path TUI assets next to the executable
      (theme/*.json, assets/*.png, export-html/*, package.json,
      CHANGELOG.md, and pi-tui's native/darwin/.../darwin-modifiers.node),
      mirroring upstream's copy-binary-assets — pi resolves them at
      dirname(process.execPath) (config.js isBunBinary branch). The asset
      smoke (scripts/verify-binary-pi.ts) now also asserts initTheme +
      the native modifier load; VERIFIED in the compiled bundle
      ("pi terminal theme assets resolved", "pi-tui native modifier helper
      loaded").
- [x] **Lab web UI + native engines** (2026-06-14, branch
      web-ui-and-native-lab): unified hash-routed SPA (src/web/app.html) —
      Chat (pi embed) / Quantize / Fine-tune / Build-Dataset / Status —
      backed by NATIVE quantization (src/quantize: mlx_quantize +
      mlx_save_safetensors → real HF-layout model dir), native LoRA+DPO
      training (src/train + src/mlx/autograd.ts: mlx_value_and_grad via a
      bun:ffi JSCallback closure, hand-rolled AdamW), the 13 OptIQ dataset
      templates (src/dataset), and a shared bun:sqlite job system with
      NDJSON-log SSE + GPU-leased subprocess isolation (src/jobs). No
      Python. Real-model e2e (MiniCPM5-1B): requant 170 modules → 4.50 bpw
      in 7 s; LoRA loss 4.48→0.68 in 4.6 s with a verified behavior change;
      live pi chat turn over WS. 85+ new tests green, tsc clean, server
      suite 17/17 (no regressions). Full story:
      docs/archive/investigations/lab-build-journal.md +
      docs/archive/mlx-bun-lab-report.html.
- [x] **First-run starter model**
      (2026-06-12, after the first external tester sat through a 16 GB
      26B download with nothing to use): interim e4b starter shipped
      first. 2026-06-13 update: true sub-GB starter is now
      `mlx-community/MiniCPM5-1B-OptiQ-4bit` (0.92 GB, Llama-family).
      Goldens were generated first from the Python oracle in
      `/Users/joshrossi/Code/mlx-lm/.venv`, then the Bun Llama
      port matched 100/100 greedy ids with bit-exact full-vector
      logits for all 100 steps, in both standard bf16 KV and the
      shipped mixed-KV (kv_config.json) modes. Fresh install now
      downloads MiniCPM5 in the foreground, starts serving/chatting
      quickly, and streams the recommended Gemma for the machine in
      the background (visible at /downloads, resumable; auto-pick
      prefers the larger supported model next run if it fits).
      Starter remains a permanent fallback.
      2026-06-12 serving-layer review (after live agent bugs): four
      fixes landed — (1) ChatTemplate rewrites `[a,b]|min`/`|max`
      (unsupported by @huggingface/jinja) so MiniCPM5 multi-turn tool
      history renders instead of 400ing every second agent turn,
      verified byte-exact vs the oracle apply_chat_template;
      (2) tools-active streaming now streams content live and
      withholds only tool markup (oracle's incremental parser
      behavior) instead of buffering whole responses; (3) tool args
      decode against the tool's JSON schema (string params stay
      strings) with CDATA-safe parsing; (4) omitted sampling fields
      default to the model's generation_config.json, the optiq
      gen_config injection (MiniCPM5 0.9/0.95; Gemma 1.0/64/0.95).
      Chat UI verified live in-browser (streaming, multi-turn,
      prompt-cache hit on turn 2). Details in docs/archive/planning/journal.md.

## Phase 17 — Compat CLI surface + parity harness `[ ]` (2026-06-12)

Design the entire CLI/flag surface from scratch (nothing published yet)
so one set of verbs serves three depths — automatic / compat /
stick-shift (PRODUCT_ROADMAP "The three modes"). mlx-lm is the
vocabulary, because it is the WWDC-default and outweighs mlx-optiq ~425×
on installs (1.64M vs 3.85k/mo; 5.8k★/765 forks vs no public repo —
measured 2026-06-12). Full surface contract + the gap matrix live in
**docs/design/compat-cli-surface-design.md**.

Three laws: (1) one surface, mlx-lm vocabulary, `mlx-bun.<verb>` is a
pure alias of `mlx-bun <verb>`; (2) compatibility = superset, never
intersection (never gate a free capability — OpenAI+Anthropic+Responses
all stay on); (3) gate behind a flag only where always-on would degrade
the automatic/compat experience. Surface parity ≠ architecture parity:
an unsupported model errors clearly, it does not silently misbehave (the
"scope is survival" principle still holds).

This phase ships the layer over **existing** capabilities; the 🟥
buckets below fill in behind it.

- [ ] Verb router + dotted-alias bin entries (`mlx-bun.server`, etc.),
      one flag vocabulary adopting mlx-lm names.
- [ ] Reconcile current ad-hoc commands: `serve --kv-quant` →
      `--kv-bits/--kv-group-size/--quantized-kv-start` (deprecated
      alias kept); `--prompt-cache` → `--prompt-cache-size/-bytes`;
      keep our levers (`--compiled-decode/--perf-kernel/--fused-*`) as
      stick-shift flags.
- [ ] Wire 🔌 wiring-only verbs (engine exists): `generate`, `chat`
      (faithful REPL), `server` flag parity, `benchmark` flag parity,
      `manage` (`--scan/--delete/--pattern`), `cache_prompt`,
      `lora info`, `latency`/`fit` `--calibrate`.
- [ ] Honest stubs for 🟥 verbs: exit non-zero with
      `not implemented in mlx-bun yet`.
- [ ] **Parity harness** against the oracle venv: per-verb flag-surface
      diff (every `mlx_lm.<verb> --help` flag accepted or explicitly
      rejected, never silently ignored) + deterministic behavior diffs
      (`generate --seed --temp 0`, `manage --scan`, `cache_prompt`
      round-trip) + gap-honesty assertions.
- **Exit criterion**: `mlx-bun.<verb>` aliases exist for every mlx-lm
  verb; the parity harness is green for the 🔌 set (faithful behavior)
  and asserts the honest-stub message for the 🟥 set; existing suites
  (Gemma/MiniCPM parity, server, tools) stay green after the flag
  reconciliation.

**Native differentiators are NOT in this phase** — the compat layer
makes us a drop-in *for* mlx-lm; pi (Phase 16: `harness pi` + `mlx-bun
pi` exist, embedded single-binary pi is the flagship — see
docs/archive/investigations/pi-builtin-investigation.md) and the built-in web UI make us *more
than* mlx-lm. Both ride pi's `AgentSession` event stream. They are the
other half of the product, tracked separately in Phase 16.

### Capability buckets behind Phase 17 (the 🟥 matrix)

The compat layer is the 🔌 column; these are the real builds that light
up the 🟥 verbs and the OptIQ-Lab web-UI tiles (full matrix in the spec):

- **Model quantization (new phase) — make a NEW model artifact**:
  `convert` (uniform/affine + mixed/sensitivity), `awq`, `dwq`, `gptq`,
  `dynamic_quant`. Offline; reads a model, writes a new quantized model
  dir to serve/upload/share. Lights up web-UI quantize tile.
- **Inference-time KV-cache quant (no artifact) — DONE**: bf16,
  uniform, and **mixed per-layer** from kv_config.json all work today
  (config.ts reads it, generate.ts applies per-layer, server.ts exposes
  `off`/`N`/`config`; Phase 9 + Phase 10). Remaining KV items are
  optional and NOT inference plumbing: a *profiler* that authors a new
  kv_config.json (model-prep, tied to the model-quant axis, low pri —
  shipped artifacts already include one) and the TurboQuant rotation-VQ
  *method* (Phase 13, an extra scheme on top). TurboQuant is a method,
  not the model-creation workflow.
- **Training (new phase)**: `lora --train/--test` (LoRA/DoRA/full),
  `--rank-scaling by_bits|by_kl`, `fuse` (+GGUF/upload). Web-UI
  fine-tune.
- **Eval (new phase)**: `evaluate` (lm-eval-harness + optiq task set),
  `perplexity`.
- **Distribution (new phase, low pri)**: `upload`, `share`.
- **Web-UI training-data template + generation**: independent of engine
  work; fourth OptIQ-Lab tile.

## Phase 18 — Concurrent / batched serving (slots) + parallel load benchmark `[~]` (2026-06-13)

> **Status:** Engine BUILT and LIVE for full-attention + sliding-window models. `bench-serving-load.ts` harness shipped; scheduler/gateway/sliding-window batched decode done; all 4 L1 cells bit-exact vs mlx-lm B=N. Remaining open items: strict batched-prefill (S1a), ring-wrap (>window) golden, L2/L3 parity layers, continuous injection (S2), paged KV (S3+). See DONE list and sub-phase markers below.

Agents hit the SERVER and real usage is concurrent, but mlx-bun's server
is `batch=1`, serialized (server.ts: "Generation is serialized through a
single queue (one GPU, batch=1)"; generate.ts builds every tensor `[1,
L]`). Concurrent requests QUEUE — aggregate throughput is capped at
single-stream, latency grows with queue depth. The competitors batch:

**Verified 2026-06-13 (oracle venv):**
- **mlx-lm 0.31.3** — continuous batching in the server (`ThreadingHTTPServer`
  + a `batch_generator` with `insert_segments`). The slot knobs are CLI
  flags: `--decode-concurrency` (default 32), `--prompt-concurrency`
  (default 8). Batchable iff no draft model AND every KV cache class
  implements `merge` (`server.py` is_batchable).
- **optiq 0.1.1** — built on mlx-lm's server; only forces *image* requests
  off the batch path, so TEXT serving batches too. Caveat to confirm
  empirically: its kv-quant cache must implement `merge`, else that path
  falls back to serial.
- **mlx-bun** — no batching. This is the gap; it's the context↔concurrency
  tradeoff. (Earlier framing was a *static* KV partition — fixed
  total_context/N per slot, llama.cpp `-np`. Superseded 2026-06-14: we
  allocate KV **dynamically by need**, see the decision block below and
  **docs/design/parallel-slots.md**.)

Two parts, sequenced:

**P1 — Parallel load benchmark `[x]`** (`scripts/bench-serving-load.ts` shipped):
- Separate harness (`mlx-bun loadtest` / `scripts/bench-serving-load.ts`),
  NOT folded into the preflight-gated single-stream h2h matrix; shares the
  eval DB.
- Concurrency sweep (closed-loop 1→20 in-flight) and/or arrival-rate sweep
  (open-loop); configurable N requesters × target rpm (Josh: e.g. 32
  requesters @10 rpm, or sweep 1→20).
- Measure: TTFT p50/p95, end-to-end latency p50/p95/p99, aggregate vs
  per-request throughput, peak memory (per in-flight KV cache), error/
  timeout rate, and the **saturation knee**.
- **Cross-stack** (mlx-bun vs mlx-lm vs optiq) — the headline is the
  *batching gap*: where mlx-bun's `batch=1` loses to a batching server
  under load. That gap is the business case for P2.
- Start with **cpm (0.84 GB) + e4b (6 GB)** — concurrent KV caches leave
  headroom, and they're the user-facing starter/recommended models.
- Against today's server this measures the serialized ceiling (throughput
  flat, latency climbs); headline output = a latency-vs-load curve + a
  "max sustainable rpm at acceptable p95 TTFT" number per model/stack.

**P2 — Batched / "slots" serving `[x]`** (scheduler/gateway/sliding-window done; decode L1 all 4 cells bit-exact):
- Add a batch dim (`[B, …]`) through the forward pass, per-slot KV caches,
  ragged-sequence attention masking, and a scheduler/admission policy
  (slots↔max-context tradeoff; mlx-lm's `--decode/--prompt-concurrency`).
- Touches the cache classes (per-slot, `merge`-capable), masks (ragged),
  and compiled-decode (assumes batch=1 today — shapeless replay over
  varying B/lengths + the CustomKernel/perf-kernel interplay are the hard
  parts).
- Continuous batching (insert mid-flight, like mlx-lm `insert_segments`) >
  static batching for bursty agent traffic.
- Exit: throughput scales with concurrency up to the slot count then
  queues (P1 confirms); per-sequence output bit-exact vs the batch=1 path
  (parity gate).

### P2 design + decisions (2026-06-14) — see docs/design/parallel-slots.md

Full design written to **docs/design/parallel-slots.md**. Key decisions
this session:
- **Continuous batching, not static.** A late request joins the in-flight
  batch at the next decode step (iteration-level scheduling); it does NOT
  wait for the running request to finish. Benefit window = requests
  *overlapping in wall-clock*, not a formed backlog. Light traffic (no
  overlap) → `--slots 1` stays the default and is the right answer.
- **KV allocation is dynamic, by need — not static partition.** Reject
  fixed budget/N per slot (wasteful, arbitrary cap). Ship rung 2 first:
  dynamic byte-budget admission with contiguous per-sequence caches
  (padded batch, no new kernel; budget mirrors the byte-capped
  PromptCache). True "who needs it most" = rung 3 **paged KV** (custom
  paged-attention Metal kernel + block manager) as the S3+ density
  upgrade — feasible given we already ship custom Metal kernels.
- **LoRA**: batch only same-adapter-set requests; mixed adapters **drain
  to solo** (accepted — Josh confirmed fine). Per-row adapters deferred.
- The hot path is already `[B, …]`-generic (attention `gemma4.ts:152`,
  KVCache `gemma4-base.ts:204`). The hard problem is per-sequence
  position: left-padding + per-row `[B,1,1,S]` mask + per-row RoPE offsets
  (`ops.ropeDynamic` / `ropeOffsetArr` already exist). Sliding-window
  (`RotatingKVCache`) per-row masking is the top correctness risk.

Phasing (each default-off behind `slots=1`, serialized path never removed):
- [x] **S0 — config seam (2026-06-14).** `--slots N` / `ServerOptions.slots`
      plumbed, validated, surfaced (ready card + `/stats`). `N>1` warns
      that batched execution lands in S1 and runs serially. No behavior
      change; suite green.
- [x] **S1** — static 2-wide, base model only. Split after the 2026-06-14
      reuse finding (below). Decode side (S1b) done; prefill wiring (S1a) still open:
      - [ ] **S1a (prefill)** — reuse the training batched-forward machinery
            (`buildBatchedPadMask` / `BatchedMaskCache` in src/train/forward.ts,
            already parity-proven by tests/train-batch-e2e.test.ts); wire the
            serving path to prefill B prompts in one forward.
      - [~] **S1b (decode)** — the new work: growing per-row KV + per-row
            offsets, per-row RoPE (array-offset path), per-row [B,1,1,S] decode
            mask, B-token/step loop + stream fan-out. **First brick landed
            2026-06-14**: src/model/batched-mask.ts `buildBatchedDecodeMask`
            (left-padded, nonzero-offset) + tests/batched-decode-mask.test.ts
            (fast, no model). Prerequisite fix landed 2026-06-14: Attention.forward
            now captures ropeOffsetArr ONCE (K/Q used different offsets across
            updateAndFetch — latent today, parity-breaking for per-row decode);
            verified bit-exact vs tests/compiled-decode.test.ts (12B, 7/7).
            Two traps documented (pad-convention mismatch; RoPE timing) — see
            docs/design/parallel-slots.md. Sequence: S1b.1 gated teacher-forced
            decode parity harness (riskiest numerics first) → S1b.2 KV assembly
            → S1b.3 scheduler + B-token/step loop + stream fan-out. Teacher-forced
            gate: 2-row decode per-row logits match two solo runs within bf16 tol.
          - [x] **S1b.1 DONE 2026-06-14**: BatchedDecodeMaskCache (wrapper:
                per-row decode mask + per-row ropeOffsetArr) + gated parity test
                tests/batched-decode-parity.test.ts (MLX_BUN_TEST_BATCH_DECODE=1,
                MiniCPM5-1B, all full-attention). PASSES: unpadded row bit-exact
                vs solo, left-padded row within bf16 reduction-order noise
                (≤0.23, bounded over 8 steps). **The gate caught a real bug**:
                LlamaAttention (minicpm5.ts) roped Q/K with the scalar
                cache.offset, ignoring ropeOffsetArr → left-padded rows
                mis-positioned (logit diff 8.7). Fixed to use the array-offset
                path when present (captured once); MiniCPM5 solo parity still
                bit-exact vs oracle (minicpm5-parity + kv-parity, 2/2). Gemma4
                Attention already had the array path (compiled-decode); its
                capture-once fix verified vs compiled-decode (12B, 7/7).
          - **"Done" gate = model × 3 parity layers** (NOT a flat grid; see
            docs/design/parallel-slots.md): L1 bf16/mlx-lm-exact, L2 quant/
            optiq-exact, L3 our perf (low-KL). Must degrade gracefully L3→L2→L1.
            Current roster CPM + 3 Gemmas; new families (Qwen) add a row + their
            own 3 layers. Modes analysis 2026-06-14 found 2 more per-path items:
            generated handlers (L3) repeat the K/Q rope double-read trap → fix in
            scripts/gen-model.ts (generator) + regenerate; the [B,1,N,S] array
            mask bypasses the fused decode kernel (mask.mode "" only) → quant
            batched falls to quantizedSdpaUnfused (correct, perf debt).
          - **Progress 2026-06-14b**: parity harness generalized (reusable per
            model, per-layer cache types KVCache/RotatingKVCache, ring-wrap
            guard) + **KL gate adopted** (batched decode is NOT bit-exact vs
            single-stream — batching changes attn reduction order; KL(solo‖batched)
            < 1e-2 is the universal gate; bit-exact unpadded is a CPM-only bonus).
            CPM L1 ✅ (KL 7e-4). Gemma 12B L1 WIP: unpadded row = benign batch
            noise (KL 5e-3, content-independent — proven via identical-prompt
            run); **padded row = real Gemma bug (KL 0.26)** — hypothesis: bool
            mask doesn't clamp zero-padding to -inf at Gemma's score magnitudes
            (headDim 256, scale 1.0).
          - **Oracle correction 2026-06-14c (Josh)**: the batch-mode gate is
            bit-exact vs **mlx-lm's batch mode at the same B** (mlx-lm B=N ≡
            mlx-bun B=N), NOT vs our own B=1. Read mlx-lm: BatchKVCache/
            BatchRotatingKVCache(left_padding), per-row offset array → RoPE,
            mask j>=left_padding, bf16 uses the SAME fused bool-mask sdpa we do.
            So our approach matches in principle; the additive-mask "fix" is WRONG
            (would deviate). Built scripts/gen-batched-golden.py (oracle venv) →
            captured CPM B=2 greedy trajectories + logits golden. The KL harness
            (solo-prefill+assemble vs solo-decode) measures the WRONG oracle —
            demoted to internal-consistency check. Next: build mlx-bun REAL
            batched prefill+decode, gate bit-exact vs the mlx-lm B=N golden.
          - [x] **CPM L1 ORACLE-VERIFIED 2026-06-14d**: built realBatchedGreedy
            (left-pad → BatchedDecodeMaskCache, which handles prefill at offset 0
            AND decode → batch-prefill → greedy decode). Its per-row trajectory ==
            mlx-lm B=2 EXACTLY (both rows incl. left-padded, 8 steps). CPM L1
            batched is bit-parity with mlx-lm's batch mode. Fixture committed
            (goldens/batched-golden-cpm.json — machine-layered via
            tests/goldens.ts since 2026-07-01).
          - [x] **Gemma 12B L1 ORACLE-VERIFIED 2026-06-14d**: realBatchedGreedy ==
            mlx-lm B=2 EXACTLY (both rows incl. left-padded; sliding layers via
            RotatingKVCache→BatchRotatingKVCache; short-context). The "KL 0.26
            padded bug" was purely the wrong-oracle artifact — RESOLVED, no fix
            needed (bool+fused path is what mlx-lm uses). Golden needs optiq's
            register() to load gemma4_unified in mlx-lm (see gen-batched-golden.py,
            mirrors regen-parity-goldens). Fixture: batched-golden-gemma12b.json.
            Caveat: short-context only; ring-wrap (>window) is a separate golden.
          - [x] **Gemma e4b L1 ORACLE-VERIFIED 2026-06-14d**: realBatchedGreedy ==
            mlx-lm B=2 EXACTLY. Required the predicted fix: computePerLayerInputs
            + the per-layer slice in forwardLayers hardcoded [1,L,…] → made
            B-generic (B from shape; B=1-identity, no single-stream regression).
            KV-sharing turned out already B-generic (no extra fix). Fixture
            batched-golden-e4b.json. 3/4 L1 cells done; 26B (MoE) next.
          - [x] **Gemma 26B L1 ORACLE-VERIFIED 2026-06-14d**: realBatchedGreedy ==
            mlx-lm B=2 EXACTLY. MoE (Router/SwitchGLU/Experts) was already
            B-generic — no fix needed. Fixture batched-golden-26b.json.
          - **🎯 L1 BATCHED DECODE COMPLETE**: all 4 cells (CPM, Gemma 12B, e4b,
            26B) bit-parity with mlx-lm B=2. Only e4b needed a fix. Caveat:
            short-context (pre-wrap); ring-wrap (>window) is the remaining L1
            follow-up. Next: L2 (quant KV vs optiq), then L3 (perf, KL+quality).
- [ ] **S2** — N-wide + continuous injection/eviction; dynamic byte-budget
      admission.
- [ ] **S3+** — paged KV (rung 3), KV-quant under batch, LoRA-group batching.

**Reuse finding (2026-06-14):** batched PREFILL is already built and proven
in the training path — `src/train/forward.ts` (`buildBatchedPadMask` +
`BatchedMaskCache`; KVCache/RotatingKVCache confirmed shape-generic over B)
and `tests/train-batch-e2e.test.ts` (B=2 padded forward's per-row loss ==
two B=1 forwards, bf16 tolerance). This is the teacher-forced gate, already
green. So S1 shrinks to wiring prefill into serving (S1a) + the genuinely new
batched-decode path (S1b).

## Phase 19 — HLG sampling (piecewise tone curve on the logits) `[x]` CLOSED — SUPERSEDED by Curve Designer (2026-06-14)

CLOSED — full record archived in git (`git show /Users/joshrossi/Code/mlx-bun/3199c75LAN-archive.md`) ("PLAN archive 2026-08-18").

## Publishing decision (2026-06-12, Josh)

Zip-sharing is over — publish properly: **bun/npm first, then brew.**
(npm channel = source package running under the user's bun; brew =
the compiled bundle. Publishing likely also means making the repo
public, which fixes the native-pack anonymous-download caveat.)
Two gates before publishing:
- [x] **Sub-GB starter model working** — MiniCPM5 Track A chosen and
      ported on branch `codex-minicpm5-starter-port`. See
      **docs/archive/investigations/starter-model-port-handoff.md** for the discovery that
      Qwen3.5-0.8B is hybrid gated-DeltaNet and remains Phase 14 proper.
      MiniCPM5 is textbook Llama and now has committed oracle goldens,
      config/model/factory support, CLI starter wiring, and bit-exact
      100-step parity tests (bf16 + mixed KV). Serving layer reviewed
      and fixed 2026-06-12 (template min-filter crash on agent loops,
      buffered tool streaming, schema-blind arg decoding,
      generation_config sampling defaults); Gemma 4 parity/server/tool
      suites re-verified green, chat UI verified live. Gate satisfied.
- [x] **Minimal chat experience in the web UI** (2026-06-12): /chat
      page served from the binary — streaming SSE chat against
      /v1/chat/completions, keynote styling, tok/s + TTFT footer per
      reply, stop button, system-prompt field; linked from the status
      page hero. E2E-verified against a live server (streamed reply,
      live tok/s).

### Publishing — SHIPPED (2026-06-17)

- **npm 0.0.4 + bunx**: published to the npm registry; `bunx mlx-bun` works.
- **Homebrew tap** (`joshuarossi/homebrew-tap`): signed + notarized release
  pipeline in place; `brew install joshuarossi/tap/mlx-bun` installs the
  compiled binary.
- **Direct-download install**: standalone shell installer script available for
  one-command installation without Homebrew or npm.

## Phase 20 — Expert offload: single-user MoE residency `[~]` (2026-06-14)

Stop the inactive experts squatting in RAM. A trained MoE activates ~0.9
GB/token but we hold the whole 14.09 GB expert pool resident (Phase 6
measured, gemma-4-26B-A4B → 16.4 GB resident, max ctx ~17.6k, ~0 GB left
for apps). Single-user task locality (one human, one job for minutes–hours)
makes per-task residency viable where a multi-tenant server can't. Full
design + reasoning: `docs/archive/investigations/expert-offload-single-user-moe.md`.

**Mechanism de-risked 2026-06-14** (`scripts/probe-expert-residency.ts`,
`scripts/probe-mmap-gather.ts`, on the M4 Pro):
- Disposing MLX *device* buffers does NOT reliably return RAM to the OS (rss
  flat through dispose+clearCache; `cache_memory` reads 0) ⇒ a fixed device-
  buffer slot pool is the wrong mechanism (holds less, can't give back).
- `munmap` of an mmap'd region returns RAM to the OS deterministically (rss
  −1 GB exact, −2 GB at scale) ⇒ the elastic clean-page substrate.
- GPU `gather_qmm` reads a quantized expert DIRECTLY from a page-aligned
  (16 KB) mmap, BIT-EXACT vs resident (max|diff|=0, no NaN, non-zero offset)
  ⇒ gather straight from the mapping, no device-buffer copy.
- ⇒ Design: bit-exact transparent offload via page-aligned, mmap-backed
  expert weights; load = fault-in on demand, evict = `munmap`/`madvise`.

**Mechanism further de-risked 2026-06-14** (`scripts/probe-madvise-eviction.ts`,
`scripts/probe-footprint.ts`):
- `gather_qmm` is ROW-LOCAL: madvise(DONTNEED) the whole stacked [E,…] expert
  tensor, fault back in ONLY the selected experts, GPU gather is BIT-EXACT
  (max|diff|=0, no NaN, no crash) ⇒ cold experts evictable within one mapping;
  no subset-tensor / index-remap needed — map the stacked tensor once.
- CLEAN read-only file-mmap pages cost ~0 `phys_footprint` (the macOS pressure
  metric = Activity Monitor "Memory"): faulting 1 GB added 0.001 GB. Today's
  experts are anonymous mlx_load_safetensors COPIES (count in phys_footprint →
  pressure); loading them as file mmap instead drops the whole ~14 GB pool OUT
  of pressure → reclaimable buffer cache (warm when RAM free, reclaimed
  instantly under pressure, re-faulted ~1 ms/expert). Win reframed: not "free
  ~7 GB" but "phys_footprint → ~core (2–3 GB); the pool becomes reclaimable
  cache." Apple's result without retraining, just by changing the load path.
- madvise does NOT move `rss` and barely moves `phys_footprint` here (clean
  file pages already don't count) — so explicit eviction is a perf hint, not a
  footprint necessity. munmap definitively drops rss if ever needed.
- **RESOLVED 2026-06-14** (`scripts/probe-metal-wire.ts`): GPU gather over a
  128 MB mmap'd quantized expert added **0.0 MB** to phys_footprint across 3×
  gathers — Metal reads mmap'd file pages as RECLAIMABLE CACHE, does NOT wire
  them. ⇒ mechanism fully de-risked end to end; the footprint win is
  confirmed. Remaining is a perf knob, NOT correctness: pin/wire hot experts
  (faster decode, counts as pressure) vs leave cold reclaimable (low pressure,
  re-fault stalls) — cf. generate.ts wired-limit. E1 is now pure engineering:
  offload-ready page-aligned file + switch expert load path to mmap+fromView
  + measure on real 26B + bit-exact parity gate.

- [ ] **E0 — per-task expert-skew measurement** (make-or-break, pure
      observation, no offload code): instrument the MoE forward to log
      per-(layer,expert) routing over real coding / writing / chat sessions
      → coverage curve (% experts covering 90/95/99% of activations),
      within-task stability, cross-task set shift. **Josh runs the 26B
      sessions on a cleared machine.** Gate: hot set small + stable enough
      to pay. **Tooling built+verified 2026-06-14**: `src/expert-trace.ts`
      (env `MLX_BUN_EXPERT_TRACE=<path>`, inert by default; one hook in
      `Router.forward` covers both the hand-written and generated handlers)
      + `scripts/analyze-expert-trace.ts` (coverage / working-set / cold-
      load / stability / cross-task / E0 gate). Build green; analyzer smoke-
      tested on synthetic traces. Awaiting Josh's cleared-machine runs.
      Per-expert geometry measured: 128 experts × 30 layers, top-8, ~3.94
      MB/expert, 15.13 GB pool, ~0.92 GB active/token; on-disk reads at
      4.2–6.6 GB/s warm. **E0 RESULT (scripted, 2026-06-14 —
      scripts/run-expert-trace.ts over 8 prompts × 3 domains, 26B): gate
      PASSES all 3.** Experts to cover 90% of activations: coding 51/128
      (40%), writing 53 (41%), chat 60 (47%) — concentrated but moderate
      (uniform ≈ 90%). Unique experts touched over ~1.2k tokens: 81–85% of
      3840 instances (working set ~12–12.6 GB). Within-task stability
      (hot-set Jaccard, 4 windows) 0.63–0.70 (moderate drift). Cross-task:
      coding vs writing/chat 0.42/0.44 (specialised), writing vs chat 0.68
      (similar). READ: bit-exact offload frees ~6–7 GB (resident ~9–10 vs
      16.4) keeping the 90% hot set + occasional SSD misses for the rare
      tail; smaller budget = more savings + more misses → that curve is E1's
      job. Domain prefetch pays for distinct domains (code vs prose).
      Caveat: scripted ~1.2k-token sessions — a real long focused session
      may tighten/broaden; re-trace before locking a budget. Traces:
      /tmp/expert-trace-{coding,writing,chat}.jsonl. **→ greenlight E1.**
- [~] **E1 — offload-ready file + mmap expert loading** behind
      `--expert-offload` (default off / inert). **Parity gate: bit-exact vs
      all-resident** (same gather_qmm, same tokens — overlaps the existing
      correctness test, not a new oracle).
   - [x] **E1a — converter DONE 2026-06-14**: `scripts/convert-offload-experts.ts`
         re-packs expert tensors into a page-aligned `experts.bin` + `manifest.json`
         (each tensor 16 KB-aligned so the GPU gathers from a clean file mmap).
         Verified byte-identical + aligned on the real 26B (3 layers → 2.43 GB at
         `/tmp/expert-offload`; full run = drop `--layers`).
   - [x] **E1b — load path switched DONE 2026-06-14**: `src/expert-offload.ts`
         (env `MLX_BUN_EXPERT_OFFLOAD=<dir>`, inert when unset) + a one-line hook
         in `QuantizedSwitchLinear.load` (gemma4-base.ts) — the expert WEIGHT
         comes from `MmapFile`+`fromView` at the manifest offset when active,
         else resident; scales/biases stay resident. Covers monolith + generated
         paths (shared construction). Build green.
   - [x] **E1c — measured on the real 26B DONE 2026-06-14** (`scripts/measure-
         offload.ts`; full 30-layer convert = 15.13 GB, 270/270 tensors
         aligned + byte-identical): **phys_footprint 17.1 GB (resident) → 4.2 GB
         (full offload), −12.9 GB**; decode 38.9 → 41.5 tok/s (NOT regressed,
         ~noise); **BIT-EXACT** (80 tokens identical resident vs offload). A
         26B-total MoE runs with the memory pressure of a ~4B model, bit-
         identical, decode unregressed — Apple's outcome on a stock model, no
         retraining, purely via the load path. CAVEATS: tok/s indicative not
         quotable (not cleared-machine — dirty-machine rule); "no regression" is
         a short WARM gen — long / under-pressure runs may surface cold-miss
         cost (then pin hot experts).
   - [x] **E1d (CLI productionization) DONE 2026-06-14**: `mlx-bun serve
         <model> --expert-offload` builds `<model>/.mlx-bun-offload` on first
         use (reused after via manifest model+size check), activates before
         `loadContext`, bit-exact runtime from E1c. Split: runtime
         `src/expert-offload.ts` (activate/array/isOffload) + build
         `src/expert-offload-build.ts` (`ensureOffloadFile`/`buildOffloadFile`);
         hooked in `cli.ts` serve after `ensureNative`, before `loadContext`;
         help + flag-parse (`OURS_BOOL`) registered; dense models warn + skip.
         Verified: build green, help shows flag, converter 9/9 byte-identical,
         reuse path hits. (`mlx-bun serve 26B --expert-offload` smoke test =
         Josh's to run — it starts a server.)
   - [ ] **E1e (remaining follow-on)**: cleared-machine tok/s → `benchmarks/
         RESULTS.md`; optional hot-expert pinning if long / under-pressure runs
         regress; offload scales/biases for the last ~6% (verify BF16-from-mmap
         GPU read first).
- [ ] **E2 — domain prefetch** reusing the `/v1/adapters` surface: per-
      session `domain` hint warms that domain's profiled hot-set; per-user
      profile learned online (memory flywheel). Still bit-exact (misses
      fault to SSD). Measure cold-start vs warm latency + switch cost.
- [ ] **E3 — admit a non-fitting model**: bring up a 35B-A3B-class model
      under offload on 24 GB; flip Phase 14's "larger hardware only" line;
      measure the domain-switch warm-up (I/O floor single-digit sec; the
      30–60 s budget is the conservative upper bound).
- [ ] **E4 — (optional) pinned mode**: restrict routing to the warm set
      (skip cold experts) for zero-miss decode → lossy, KL + 6-task quality
      gated per the optimization-tree rules, default-off flag (never the
      only path).
- **Exit criterion**: gemma-4-26B-A4B served bit-exact with resident
  footprint cut to a measured target (~5–6 GB vs 16.4), machine stays
  usable, domain-switch cost quantified — promoted into
  `benchmarks/RESULTS.md`.
- **Scope boundary**: single-user / single-active-task. Phase 18 slots /
  multi-tenant loses the locality guarantee → experts stay resident there;
  keep offload files separate from the batch/slots work.

## Phase 21 — GLM-5.2 on 32 GB via the complete Colibri hierarchy `[x]` (closed 2026-08-17)

CLOSED — full record archived in git (`git show /Users/joshrossi/Code/mlx-bun/3199c75LAN-archive.md`) ("PLAN archive 2026-08-18").

## Phase 22 — pre-Colibri stabilization burn-down `[x]` (opened 2026-07-29, closed 2026-07-29)

CLOSED — full record archived in git (`git show /Users/joshrossi/Code/mlx-bun/3199c75LAN-archive.md`) ("PLAN archive 2026-08-18").

## Fit-model calibration status (2026-06-12, second external tester)

The decode prediction is single-point-calibrated on the M4 Pro
(DECODE_EFFICIENCY 0.82, MOE_DECODE_EFFICIENCY 0.76 — accurate there)
and misses elsewhere, measured on the M1 Max @400 nominal:
26B MoE +59% optimistic (79.5 predicted vs 50.1 measured), 12B dense
+23% optimistic (35.2 vs 28.7), e4b −21% PESSIMISTIC (48.2 vs 60.9 —
fit counts the full 262k-vocab embedding table as per-token read
bytes; only one row is read). Known causes: per-chip achievable-vs-
nominal bandwidth differs by generation; MoE gather efficiency is
chip-dependent; embed-heavy models overcount. NOT retuned on one new
data point (would break the calibrated M4 Pro). Mitigation shipped
instead: all surfaces now agree (/fit passes expertsBytes like the
CLI — the page/banner/CLI used to show 23/109/~80 for the same
model), and the status page hero shows MEASURED decode (eval DB
latestFor this snapshot) over predicted whenever a benchmark has
run. Proper fix when it matters: per-chip efficiency table fed by
cli-bench rows from real machines — the eval DB schema already
carries everything needed.

## Phase: e4b LoRA training enablement for long-context tasks (2026-06-15)

Goal: fine-tune e4b on lucien's chunking task (data: ~3,400–8,200-token
SFT examples, B=1, short JSON responses) and measure quality lift on the
frozen 25-case holdout. Phase 0 smoke (`scripts/ft-chunk-smoke.ts`)
surfaced that the ported LoRA trainer had never run e4b end-to-end at
real lengths. Findings + fix:

**Diagnosis (corrects an in-flight wrong theory about attention):**
- Two fused custom kernels in the forward had no vjp: the perf decode
  kernel (`MLX_BUN_PERF_KERNEL`) and the GEGLU MLP kernel
  (`MLX_BUN_FUSED_GELU`) — BOTH DELETED 2026-07-05 (Phase 1 of
  unified-engine-frontier-plan.md; training needs no flag sanitization
  now). Historical: training had to disable both (set =0) or backward
  dies with `[Primitive::vjp] Not implemented for CustomKernel`.
- Attention is NOT the problem. `makeCache()` returns DENSE caches; only
  `generate.ts` quantizes them (`toQuantized`). With dense caches the
  generated e4b model's quantized-signature guard fails → falls back to
  `Gemma4Model.forwardLayers` → `ops.sdpa`
  (`mx.fast.scaled_dot_product_attention`, differentiable + flash). So
  training already uses efficient differentiable attention.
- The wall is backward MEMORY: (a) full-vocab logits `[1,L,262144]`+grad
  (~17 GB @8K) and (b) per-layer activations retained across ~28 layers
  with no gradient checkpointing. Peak 13.7 @512 → 20.5 @1024 → 25.7
  @1536; 2048 crosses the 32 GB M1 Max ~26.8 GB wired ceiling.

**Spike (mlx-lm + optiq, `…/mlx-lm-example/.venv/.../site-packages`):**
mlx-lm's tuner = `mx.fast.scaled_dot_product_attention` (built-in vjp) +
`grad_checkpoint(model.layers[0])` wrapping `__call__` in `mx.checkpoint`
+ a 2048 default seq cap; full logits (no chunking — they cap length
instead). optiq's fused quantized SDPA is inference-only (no vjp,
serve-scoped); its `optiq/lora/` training uses the stock differentiable
forward. So the port target is mlx-lm's tuner, not the inference kernels.

**Fix (port checklist):**
1. DONE — response-only logits: `responseOnlyCe` applies the LM head only
   at the supervised span (B=1). Correct (LM head is position-independent;
   prompt grads still flow via causal attention). Ceiling ~1280→~1792.
2. DONE (diagnostic) — `autograd.ts` now surfaces `takeMlxError()` instead
   of swallowing the underlying MLX error.
3. **LANDED 2026-06-16** — gradient checkpointing via `SegmentedBackwardGemma4`
   (see `docs/design/segmented-backward-training.md`): segmented backward with
   `mlx_vjp` per segment landed bit-exact and cuts peak from 10.91 → 3.29 GB
   @2048 on MiniCPM5 (Phase A done). Phase B (e4b) also merged. This item
   supersedes the `mlx_checkpoint` bind approach; use the segmented-backward
   path for training.
4. TODO — bake "fused kernels off" into the training path so it doesn't
   rely on env flags; raise trainer default `maxSeqLen` (512 → 8192).

Then resume: bridge (pi → local e4b server) → baseline → fine-tune →
re-measure on the 25-case holdout.

## Phase: Steel flash-CCE ORPO head + full ORPO training stack `[x]` core / `[~]` runs (2026-06-18/19)

The `[M,V]`-free ORPO head + the long-context machinery, productionized and composed.
Exit criteria (met): parity vs autograd, integration tests green, e4b fits at 8192.

- **Flash-CCE head — fwd AND bwd in production.** Verbatim MLX `steel` quantized GEMM
  (`src/train/steel-qmm-header.ts`) + the ORPO epilogue in one Metal kernel, so neither
  `[M,V]` logits nor a dequantized head touch HBM. Forward `FWD_STEEL_SOURCE` (180 ms);
  backward `BWD_STEEL_SOURCE`/`bwdSteelKernel` (H-tiled persistent accumulator + vocab-
  blocking + atomic dh; phase-2 dequant via the fused `QuantizedBlockLoader`). e4b bwd
  **3687 → 754 ms** (5×, exact), peak **0.93 GB flat @ M=8192**. Parity dh **0.40% e4b /
  0.28% cpm** (bf16 class). `MLX_BUN_CCE_BWD_NOSTEEL=1` fallback. KEY: a temp-BlockMMA-
  per-H-tile + lane-local frag accumulation avoided the hairy manual `tile_matmad`.
- **Prefix-sharing → trainer**, composed with the flash head per branch (0.018% vs
  whole-vocab), AND with the **segmented backward** for BOTH MiniCPM5
  (`SegmentedBackwardOrpoPrefix`) and e4b/Gemma4 (`SegmentedBackwardOrpoPrefixGemma4` —
  donor-KV + logical-window prefix mask threaded through segments; grads 1.7–2.3%, peak
  30–39% lower). Per-row two-forward fallback on prompt mismatch.
- **Warm-start** (`warmStartFromAdapter` / `RESUME=`) — continue from a checkpoint's
  weights (optimizer + schedule restart).
- **UAF fix** — the segmented ORPO classes freed the flash head's `headSink` before the
  lazy CustomVjp backward read its lse/blockMax → segfault ~step 100; fixed by
  `ops.evalAll` on the head-VJP roots before the dispose (all four ORPO segmented classes).
- **Launcher** `scripts/train-orpo.ts` (full stack default; e4b env auto-set; checkpoints;
  RESUME). e4b @ 8192 full stack ≈ 13 GB / ~70 s/step (M1 Max dev box) — the historical
  "e4b OOMs ≥2048" ceiling is broken.
- **Apple-CCE skips** (coeff filter + blockMax) ported as **opt-in, default OFF**: on the
  now-fast kernel they're a poor trade (coeff filter cut dh accuracy 0.66→2.7% for ~7%).
- **Eval** — optiq capability suite + IFEval scorer + UltraFeedback curation. Dress-rehearsal
  (honest): an 800-step CPM5 UF run left **IFEval flat (22.5%)** — general data + tiny run is the
  wrong lever; the load-bearing run is the **chunk segmenter** (distill Opus/GPT-5.5
  segmentation, score boundary/label accuracy vs gold → localizes the Lucien pipeline).
- **Gotcha** — agent-spawned background runs are reaped by the runtime (~47 min observed,
  not a crash/OOM); long training MUST be launched detached from the user's own shell.
- Refs: `docs/archive/investigations/steel-flash-cce-handoff.md`, `docs/reference/orpo-quickstart.md`,
  `docs/reference/training.md`. `[~]` open: the big CPM5 UF run + the chunk segmenter + e4b overnight.

## Phase: oMLX adoption wave 1 — batching parity + SSD cold tier `[x]` (2026-07-02)

CLOSED — full record archived in git (`git show /Users/joshrossi/Code/mlx-bun/3199c75LAN-archive.md`) ("PLAN archive 2026-08-18").

## Grammar × spec × batching integration (2026-07-03)

One session executed docs/design/grammar-spec-batching-integration.md
(planned the same day). Composition contract: grammar batches; spec routes
serial (upstream parity); grammar+spec = the novel constrained verify walk
(no oracle → validity + equivalence gates).

- `[x]` **Phase A** — B2 batch-grammar gates (tests/batch-grammar.test.ts)
  + F4 per-TokenizerInfo compiler cache (single-flight) + F6/F3.
- `[x]` **Phase B** — `serve --draft-model`/`--num-draft-tokens`
  (src/spec/{source,two-model,serve-loop}.ts; parity-plan §7 executed).
  **L1 gate: 48/48 token-for-token vs mlx-lm's speculative path** (Llama
  3B+1B, scripts/oracle-spec-two-model.py). Ring-wrap degrades pre-pollution;
  prompt-cache bypassed v1 (composition = §7.6 follow-up).
- `[x]` **Phase C** — grammar×spec constrained verify walk (mask rides the
  accept walk; matcher advances on emitted tokens only, no rollback).
  Gates: 100% validity + 12/12 token-identical to grammar-only serial.
- `[x]` **Phase E** — scripts/bench-feature-matrix.ts (six composition
  cells, hard conformance gate, usage.speculation telemetry). **Its first
  smoke run caught three real bugs**: snake_case wire fields never reached
  the grammar resolver (structured output was dead over HTTP since it
  landed); #flushPipeline didn't advance matchers (stale masks on
  mid-decode joins); UniversalDenseModel batched RoPE used the scalar
  offset (uneven-row batches decoded joiners at wrong positions — latent
  for all Tier-0 archs since v0.0.9; fixed via UniversalRope.applyDynamic,
  gated token-exact vs mlx-lm B=2 on Llama-3.2-3B, gateway batch gate
  lifted for plain full-attention universal archs).
- `[x]` **Phase D (admission slice)** — `--kv-budget` aggregate KV
  projection gate (queue-don't-OOM, oversized-alone rejects,
  /stats.batch.{pending_rows,kv_bytes,kv_budget_bytes};
  tests/batch-kv-budget.test.ts).
- `[x]` **Phase D remainder (2026-07-04)** — vectorized homogeneous
  sampling (BIT-equal A/B, kill switch) + extend-join (mlx-lm
  BatchKVCache.extend semantics, own oracle golden, token-for-token on
  CPM + Llama; grammar-churn join test green through the extend path;
  rotating-layer extend deferred).
- Also: universal-rope oracle fixtures machine-keyed (M1-Max flat set +
  per-machine overrides; tests/universal-rope.test.ts header has the regen
  recipe); docs truth pass (server-config.md tiers/composition/recipes).

## Decision: naked default = --l1; levers must beat the baseline (2026-07-05, Josh)

The 2026-07-05 h2h pass (M1 Max 32GB) delivered the "true baseline" the
faithful→L1 consolidation was building toward: **the L1 faithful kernel set
is at exact decode parity with mlx-lm on every model** (comparison 0:
1.00× cpm5/e4b/12B; comparison 1: 1.00–1.07×), and **no output-changing
lever beat it in a paired A/B** — fused-decode 1.00×, fused-gelu +0–1%,
perf arm 0.62–0.93× on e4b (only win 12B @16k +6%, with a KL WARN),
quantized KV 5–20% slower decode than bf16 at ≤16k on BOTH stacks (mlx-lm's
own kv8 trails its bf16; it buys memory headroom only, ~1.3 GB on 12B @16k).

- Decision (Josh): **naked = `--l1`**; prior perf-optimization work is
  untrusted until re-proven; the L1 baseline is the base all future
  optimization is measured against.
- Implemented: `applyDecodeRoute` defaults the tier to l1; `perfKernelEnabled`
  code default flipped OFF; serve/library kv default bf16 (`scripts/serve.ts`
  gained `--kv-config`); explicit `--kv-quant` picks its oracle's composition
  (config→fused sdpa, uniform→unfused = mlx-lm's algorithm). Docs updated in
  the same session (server-config/cli/features-matrix/README + superseding
  note in faithful-l1-consolidation.md).
- The bar for any lever to earn a default back: paired A/B win vs L1 on a
  stable pass (no `unstable` tag), plus KL PASS if output-changing.
- Same session: benchmark harness hardened — run-spread stability retries
  (the 0.64×-vs-optiq "regression" was a mid-pass slow-window artifact;
  07-04's clean pass measured 1.05×), readable model names, chip/RAM machine
  labels, comparison-0 + lever-A/B report sections, python-baseline prefill
  warmup (prefill convention now symmetric), KL 24→96 steps, preflight
  high-CPU foreign-process check.
- Comparison-2 golden gap CLOSED same session: `scripts/regen-mixed-kv-goldens.ts`
  (bf16 prefill → per-layer quantize incl. rotating → stock unfused decode,
  mirroring optiq's install_mixed_kv semantics = our maybeQuantizeKv) +
  `tests/mixed-kv-parity.test.ts` — per-step logits BIT-EXACT (maxDiff 0)
  + 48-token greedy prefix, green on first run.
- Also fixed same session: the faithful-matrix e4b/12B uniform-kv8 ORACLE
  cells were silently missing because STOCK mlx-lm raises
  `NotImplementedError("RotatingKVCache Quantization NYI")` on gemma sliding
  layers — bench.ts's `--baseline-kv <bits>` now applies optiq's
  `patch_rotating_to_quantized` (cache class only; the attention kernel stays
  mlx-lm's; no-op on cpm5). Verified: e4b kv8 oracle cell runs.
- **Phase 1 deletion pass EXECUTED 2026-07-05** (same day): fused-decode,
  fused-gelu, fused-swiglu (+fused-mlp/steel-linear), the perf kernel + its
  frozen-oracle scaffolding, FaithfulMiniCPM5, and `--l3` (hard error now)
  all deleted per Josh ("we will end up redoing all the work we have
  currently done given that we now have a different starting point"). The
  e4b perf-kernel regression root-cause is MOOT (kernel deleted); a future
  flash-decode kernel re-derives from the L1 baseline in the Lab.
- **Phase 0 measured the batch-lane B=1 gap** (M1 Max, median-of-5,
  identical SSE measurement both lanes): cpm5 281→129 (0.46×), e4b
  62→45 (0.72×), 12B 30→26 (0.86×) — a CONSTANT ~4–6 ms/step host tax
  (model-size-independent → host, not GPU; cpm5 has no compiled decode so
  that's not the story). mlx-lm's own BatchGenerator B=1 tax is 3.3%
  (paired A/B, cpm5) — the unified design is proven achievable. Prime
  suspects: per-layer per-step BatchedDecodeMaskCache mask rebuild (24
  layers × ~8 device nodes/step on cpm5), per-token emit path. Phase 2
  worklist in unified-engine-frontier-plan.md §8.
- **Phase 2 decode gap CLOSED 2026-07-05**: the B=1 batch-lane tax was
  (1) `toFloat32()` readback of the pipeline register — the astype queued
  BEHIND the next step's dispatched graph, stalling the pipelined read a
  full GPU step per token (fix: `MlxArray.toIntTokens()` raw int reads;
  general rule: readbacks in pipelined loops must not CREATE ops); and
  (2) per-layer per-step BatchedDecodeMaskCache churn (fix: unpadded fast
  path — bare caches dispatch the serial graph). B=1: cpm5 129→264
  (0.994 in-process), e4b 45→57.6 (0.93), 12B 25.6→29.7 (1.00).
  Instrumentation: MLX_BUN_BATCH_STEP_TRACE=1 + scripts/experiments/
  batch-b1-step-profile.ts. `--batch` 32 default stays gated (plan §8).
- Open (AUDITED 2026-07-06 against benchmarks-serve-2026-07-06b at real
  HTTP defaults — most items closed since written):
  - CLOSED: e4b compiled-decode-at-B=1 and prompt cache for batched rows
    — decode batch/serial now cpm5 266.0/263.8, e4b 61.2/61.2, 12B
    29.7/29.2, unified-vs-pin parity probes token-identical on all three;
    `--batch` default is 8 (server.ts:1136).
  - REWORDED: "cpm5 vs optiq mixed 3-6%" -> no HTTP optiq-mixed oracle
    exists (kv-quant inert upstream, lab/repro/optiq-mixed-kv-inert);
    mixed compares vs our own bf16 + script-path goldens.
  - STILL OPEN: 12B KL-max outlier; CPM extend-join golden regen
    (pre-existing); padded-B>1 per-step mask rebuild remains BY DESIGN
    (batch-scheduler #step padded branch) — unmeasured at B>1, likely
    amortized; measure via a forced-padding agg A/B before building a
    step-stable mask cache. Batch-lane warm/ctx-repeat TTFT deltas from
    06b were re-measured post-write-behind/encode-memo fixes: batched ~=
    serial (261/277 vs 252/257 ms @11k) — no admission tax remains.

## Phase: serve-bench defect sweep — cache invariant + FFI deadlock `[x]` (2026-07-06)

CLOSED — full record archived in git (`git show /Users/joshrossi/Code/mlx-bun/3199c75LAN-archive.md`) ("PLAN archive 2026-08-18").

## Phase: finish-the-list — prefill parity, incremental encode, SSM extract, FFI safety, async persistence `[x]` (2026-07-06)

CLOSED — full record archived in git (`git show /Users/joshrossi/Code/mlx-bun/3199c75LAN-archive.md`) ("PLAN archive 2026-08-18").

## Phase: 2026-07-07 serve-bench residuals — A7 RSS, cpm5 detok, 12B step-0 convention `[x]` (2026-07-07)

CLOSED — full record archived in git (`git show /Users/joshrossi/Code/mlx-bun/3199c75LAN-archive.md`) ("PLAN archive 2026-08-18").

## Phase: audio input — gemma-4 audio tower, e4b first `[ ]` (opened 2026-07-07)

Audio-in/text-out through the chat API. Full design + survey:
**docs/design/audio-input-plan.md** (mlx-lm strips audio entirely → the
oracle is optiq's internal gemma4 machinery, complete but unexposed by
its own serve frontend; our local e4b OptiQ-4bit sidecar ALREADY holds
all 752 `audio_tower.*`/`embed_audio.*` bf16 tensors + `audio_config` +
token ids — no downloads needed). Mirrors the vision port: same sidecar,
same splice/merge seams, same parity-tier ladder.

- [x] **A0 groundwork** (2026-07-07) — `mlx_conv2d` bound; binding it
      surfaced a REAL bun:ffi ABI bug (sub-8-byte stack args get 8-byte
      slots; Apple packs at natural size → shifted garbage from the 10th
      arg, mlx segfaulted on a bogus stream). Workaround: dilation_1|groups
      packed into one u64; bit-exact vs Python mlx incl. groups
      (tests/conv2d.test.ts); repro lab/repro/bun-ffi-stack-args; all
      other >8-arg bindings audited clean. Goldens live:
      `scripts/gen-e4b-audio-golden.py` → goldens/e4b-audio.json +
      4 .bin blobs (mel [159,128]/[267,128], embeds [40,2560]/[67,2560]);
      soft tokens 40/67 exactly as computed from duration; oracle greedy
      decodes: chirp → "cricket chirping", speech → a TOKEN-PERFECT
      "The quick brown fox jumps over the lazy dog." Fixtures tracked
      (fixtures/audio/, regen script TS port byte-identical to the numpy
      original; first-cut linear sweep replaced — e4b grounds sweeps as
      "dog barking", warble grounds robustly). All four §3.3 questions
      RESOLVED in the design doc: audio strictly causal (audio presence
      disables the vision bidir overlay), per-layer ids zero the mm
      union, USM params are fixed defaults, boa/eoa splice-side.
- [x] **A1 decode + features** (2026-07-07) — `src/audio/decode.ts`
      (RIFF/WAVE PCM16/24/32/f32, mean mixdown, linear resample; PCM16
      /32768 = the oracle scaling) + `src/audio/features.ts` (USM mel
      port: pad-to-128-multiple, 160-zero semicausal left pad, 321-frame
      unfold, f32 Hann product, f64 rfft512, transformers-semantics HTK
      filter bank, log+1e-3 floor). KEY FINDING: numpy builds the Hann
      window in float32 and its vectorized f32 cos differs from
      fround(Math.cos) by 1 ulp — that ulp log-amplifies to ~4.5e-4 in
      quiet mel bins, so the oracle's exact 320 f32 window values are
      BAKED into features.ts as the spec (with regen one-liner). With
      them the port hits maxDiff = 1 ulp f32 (4.77e-7) vs the T0 mel
      goldens — gated at 1e-5 in tests/audio-features.test.ts (7 tests,
      model-free; golden-presence-gated per goldens/README.md). Soft
      tokens + frame counts exact (40/159, 67/267). afconvert transcode
      + spliced-ids exactness land with A3/A4 where those layers exist.
- [x] **A2 tower** (2026-07-07) — `src/audio/conformer.ts` (AudioTower:
      SSCP + 12 Conformer blocks + clipped linears + embed_audio from the
      vision sidecar). T1 result: **bit-exact** — rel-RMSE 2.4e-8 both
      fixtures (pure f32-ulp roundtrip; gate 1e-6, ~40× margin). Root
      cause of the free bit-exactness: the oracle feeds f32 mel into bf16
      weights and mlx PROMOTES — activations stay f32 end-to-end (unlike
      the vision tower's bf16 composition), so there is no drift to
      accumulate; the port must NOT cast activations to weight dtype.
      Clipped-linear toggle: OFF diverges 90.2% rel-RMSE — the shipped
      min/max stats are load-bearing. Sidecar convs are already
      MLX-layout (no sanitize transpose). Golden reference point:
      embed_audio output BEFORE /embed_scale; features() returns
      pre-divided (vision convention). tests/e4b-audio-tower.test.ts
      (weight+golden-gated).
- [x] **A3 prompt + LM** (2026-07-07) — `buildMultimodalPrompt`
      (src/vision/prompt.ts generalized; images+audio in document order;
      buildVisionPrompt kept as thin wrapper); `<|audio|>` → boa +
      258881×n + eoa from DECODED samples; forwardEmbeddings gained a
      `multimodal` zeroing mask DECOUPLED from `bidir` (audio-only
      prompts are causal but still zero per-layer ids; `?? bidir`
      fallback keeps vision unchanged); GenerateOptions.multimodalMask.
      T2 EXCEEDED the planned prefix gate: **full greedy stream +
      decoded text match the oracle EXACTLY (incl. EOS)** on both
      fixtures; spliced ids exact. Parity trap found: the oracle merge
      divides by embed_scale AFTER the bf16 cast (mlx weak scalars adopt
      array dtype) — tower features(preDivide=false) + builder-side
      astype→div mirrors it literally. promptEmbeddings prefill is
      single-shot (matches the oracle script; tail-split applies only to
      the token-id path). 17/17 across audio+vision suites, tsc clean.
- [x] **A4 serve + docs** (2026-07-07) — server.ts audio branch (hasAudio
      over `input_audio`/`audio`/`audio_url`, lazy getAudioTower from the
      same sidecar, ZERO new flags), mixed image+audio via one
      buildMultimodalPrompt call, afconvert transcode
      (src/audio/transcode.ts, content-based RIFF sniff first), 30 s
      truncation mirroring the oracle (480k samples BEFORE features —
      keeps the 750-token splice consistent), Anthropic endpoint 400s
      audio blocks with an OpenAI pointer. Serial-lane isolation PROVEN
      non-vacuously (batch.submitted_rows stayed 0 across an audio
      request while a concurrent text request advanced it); media
      requests skip prompt cache + spec decode. T3: gated serve test
      (MLX_BUN_TEST_AUDIO_SERVE=1) 5/5 — live HTTP transcription is
      EXACTLY the golden string; m4a→CoreAudio transcode transcribes;
      malformed parts → 400. Three bugs found in passing:
      normalizeMessages silently ATE audio-bearing content arrays
      (hasMediaPart fix was load-bearing), a pre-existing
      vision-embeddings leak on the adapter-resolve 400 path, and
      afconvert cannot ENCODE mp3 (decode-only — test fixture is m4a).
      Docs in the same commit: server-api.md, features-matrix.md,
      README. 41/41 across audio+vision+anthropic suites; tsc + hygiene
      green.
- [ ] **A5 bench + coverage** — benchmark.sh cells (tower ms, TTFT delta,
      RSS delta) → RESULTS.md; 12B audio cell (sidecar rebuild via optiq
      `build_vision_sidecar` — local 12B sidecar has 1 audio tensor);
      audio×batching=serial documented. Exit: numbers curated; e4b cell
      validated, 12B validated or explicitly deferred.

Non-goals pinned in the design doc §5: TTS/STS/transcription endpoints,
streaming audio, >30 s (cap at 750 like the oracle), video, batched audio
prefill, and 26B-A4B/DiffusionGemma (no `audio_config` — architectural).

## Phase: TurboQuant weights — rotation-folded quantization, Qwen3.8-27B target `[ ]` (opened 2026-08-17)

Goal: the best-possible Qwen3.8-27B experience on our hardware. Mechanism:
QuaRot/SpinQuant-style rotation folding (fold orthogonal R offline into
producer/consumer weight pairs across the residual stream; RMSNorm γ
absorbed first so bare RMSNorm commutes with R) ahead of quantization into
mlx's EXISTING formats — no new qmm kernels (Path A; the 26B gather-qmv
shelving is the precedent). This is the queued weight leg from
docs/design/turboquant-kv.md "Future" (2026-07-06); the KV leg already
shipped and is orthogonal (online rotation stays KV-only).

Landscape scan (2026-08-17, HF): nobody publishes a rotation-based MLX
quant of this model. mlx-community ships 15 Qwen3.8-27B repos in three
families — uniform affine (4bit/8bit g64), FP micro-scaled (mxfp4 g32,
nvfp4 g16, mxfp8), and calibration-ALLOCATED mixed (OptiQ-4bit: 498
overrides, 261 layers at 8-bit; oQ4: 160 layers at 5-bit) — all handle
outliers by allocation, none by rotation. Community mixed recipes bump
exactly the DeltaNet linear-attention projections (5-bit in_proj_*,
8-bit out_proj) → those are the empirically sensitive spots. Experiment
grid: rotation {none, random-Hadamard, learned} × codebook {affine g64,
mxfp4, nvfp4} × allocation {uniform, OptiQ-style}; published incumbents
are free baselines (OptiQ-4bit already local, 19 GB).

Gate (per turboquant-kv.md): perplexity + frozen 6-task eval at equal
effective bpw vs the plain affine convert output AND vs OptiQ-4bit; eval
DB rows; model runs sequential; results labeled host/chip/RAM.

Hardware constraint recorded up front: 27B bf16 (~54 GB) never fully
loads on either laptop — folding bit-identity is proven at W0 scale plus
per-tensor shard checks on 27B; the 27B only ever RUNS folded-and-
quantized (~15 GB at 4-bit). Convert streams shards lazily, so the fold
pass itself is fine. Source artifacts (2026-08-17 correction: the trunk
and the MTP head ship as SEPARATE repos): trunk =
mlx-community/Qwen3.8-27B-bf16 (11 shards, 54.7 GB; Josh-run via
`mlx-bun get`); MTP companion = mlx-community/Qwen3.8-27B-MTP-bf16
(model_type qwen3_5_mtp, block_size 3, ~850 MB — already local +
verified via `mlx-bun get`).

- [x] **W0 folding spike (small model)** — DONE 2026-08-17 (branch
      feature/turboquant-weights; M1 Max 32 GB, busy box — correctness
      only, no perf claims). `src/quantize/rotate.ts` (fold core: untie →
      γ-fold → R₁ → SpinQuant-style per-head R₂, seed-pinned splitmix32
      signs, lazy f32 chains → bf16, per-tensor streaming through the
      existing writer) + `scripts/experiments/w0-fold-llama.ts` (runner
      with --skip-r1/--skip-r2 bisection arms + turboquant_fold.json
      sidecar). Subject mlx-community/Llama-3.2-1B-Instruct-bf16 (tied →
      untie exercised; hidden 2048 / head_dim 64, both pow-2). Fold:
      2.4 s, 3.00 GB out (+0.53 GB = exactly the untied lm_head clone).
      **Exit evidence:** (1) folded model loads + generates through the
      UNMODIFIED engine (UniversalDenseModel path); (2) teacher-forced
      two-model KL (scripts/eval.ts kl, 16×256 tok) **mean 0.00131 /
      median 0.00119 / p95 0.00287** — below the KV curve's
      quality-neutral kv8 yardstick (0.00246); (3) greedy 64-token
      trajectories (step0-top2-dump, 6 prompts): 3/6 token-identical
      incl. top-2 ids, 3 diverge ONLY at near-ties (orig top-2 margins
      0.0 / 0.125 / 0.125 — the accepted bf16 tie-flip mode, 12B step-24
      precedent), pre-divergence top-2 logprob deltas ≤ 0.375; (4)
      non-triviality: folded weights fully re-expressed (mean|Δ|≈mean|w|),
      per-tensor **max|w| down 3–5×** (q_proj 0.676→0.162, down_proj
      0.578→0.110, gate 0.965→0.367 — the affine-scale win), down_proj
      excess kurtosis 1.19→0.22; whole-tensor kurtosis on q/gate is a
      mixed-row stat and not the operative metric. tsc 0. Artifacts
      machine-local: runs/w0-fold-llama/full.
      Mechanics research (agent read of spcl/QuaRot +
      facebookresearch/SpinQuant fold code): full recipe, fold table,
      and four decided deviations (no mean-centering; delete the hidden
      R4 half-fold in rotate_mlp_output; no R3; fp32 folds w/ oracle-venv
      f64 escape hatch) in **docs/design/turboquant-weights.md**. Key
      trap recorded there: QuaRot's v/o rotation needs a RUNTIME op —
      copy SpinQuant's fully-offline R₂ pairing instead.
- [x] **W1 Qwen3.8 corridor map** — DONE 2026-08-18 (design doc §W1).
      DeltaNet blocks fold cleanly on their residual-facing dims (in_proj_*
      readers @R1, out_proj writer R1ᵀ; recurrence internals untouched);
      **R2 is architecturally OFF** (`o_proj(out·σ(gate))` elementwise
      head-space gate doesn't commute with per-head rotation); vision's
      only residual seam is merger.linear_fc2 (deepstack empty); MTP
      companion folds with the same seed; its final-norm γ is dropped
      (shared trunk lm_head — draft-quality-only, measured 71% acceptance).
- [x] **W2 streaming fold+quantize path** — DONE 2026-08-18; promoted into
      the production convert/quantize pipeline 2026-08-20. The original
      script tooling (fold-qwen35 / tq-quantize over the new
      ShardedWriter + Weights.releaseShard; the naive whole-list path
      OOM'd a 51 GB model — 27B fold peak footprint 17.9 GB after the
      fix). Cross-stack: folded 0.8B AND the quantized 27B artifacts load
      + score in STOCK mlx-lm. mxfp4/nvfp4 arms NOT verified (deferred
      with the curve narrowing below). Production seam: one pure
      `WeightTransform` plan + lazy executor contract with Llama/Qwen3.5/MTP
      adapters, invoked by `convert --rotate-weights`; transform provenance
      is persisted in `optiq_metadata.json`. Mixed allocation now injects a
      `ProbeSource` and its default calls the lower-level writer rather than
      recursively re-entering `quantizeModelDir`. Model-free gates: 33 pass;
      typecheck clean. The 64×64 apply/model parity gate is intentionally
      deferred until the active benchmark releases the GPU.
- [x] **W3 curve** — DONE 2026-08-18, affine-only (see design doc table).
      Headline: rotation LOSES at 4-bit g64 RTN (+5% ppl), WINS at 3-bit
      (−24%) and in mixed ≤4 bpw (paired control worse). Per-module
      Frobenius error is a wash at 4-bit — the anisotropy story; the
      4-bit win needs GPTQ-on-rotated (→W5). AWQ-lite equalization spike
      ran and did not rescue 4-bit (details + scripts in design doc).
- [x] **W4 27B artifacts + validation** — DONE 2026-08-18 (busy-box,
      correctness only). `~/models/Qwen3.8-27B-TQ` = rotated mixed
      4-bit attn/embed + 3-bit MLP, **3.86 bpw / 13.9 GB** (the 14z
      M4-Pro fit artifact), ppl 4.932 vs plain-4bit 4.659 (4.5 bpw,
      15 GB) vs rotated-uniform-4bit 4.923; vision kept bf16 in-repo +
      optiq sidecar; MTP companion folded same-seed. VALIDATED: server
      chat (correct reasoning), vision over HTTP (correct colors), MTP
      harness 71% accept / token-identical. NOT shipped: rotated
      uniform-4bit (loses to plain). Frozen 6-task eval cells + quiet-box
      numbers still owed before RESULTS.md rows.
- [~] **W5 calibration composition (the 4-bit flagship win)** — OPENED
      2026-08-18 (Josh: "rotation + calibration + sensitivity-aware pass,
      do it first, then publish the best version"). Every leg has a
      SHIPPED oracle in the pinned venv: GPTQ = `mlx_lm.quant.gptq`
      (forked minimally in scripts/experiments/tq-gptq.py: language-only
      filter — vision H stays a zero scalar and must stay bf16 — plus a
      REAL UPSTREAM BUG FIX: their `err[..., k:k+1]` uses the GLOBAL
      column index on a group-local buffer and mlx out-of-range slice
      assignment silently no-ops, so cross-group error propagation is
      LOST for every group after the first; verified empirically, our
      fork uses the group-local index); sensitivity =
      `mlx_lm.quant.dynamic_quant` (gradient KL) + OptiQ's shipped
      per-layer map for this exact 27B (metadata: it's a 5.14-bpw
      artifact — comparisons must be per-bpw-band). 27B needs a CHUNKED
      Hessian/GPTQ driver (their stock flow = whole bf16 model + all
      Hessians resident; layers.N.mlp.down_proj H alone is 1.2 GB f32).
      - [ ] W5a 0.8B matrix: {plain, rotated} × {RTN, GPTQ} @4bit —
            running; gate: GPTQ > RTN and rotated+GPTQ ≥ GPTQ.
      - [ ] W5b + allocation axis (dynamic_quant / OptiQ map), pick the
            best ≤4.5 bpw recipe.
      - [ ] W5c chunked 27B production run + ppl/eval gates.
- [ ] **W7 Pareto frontier (Josh 2026-08-18 — THE FRAME: "we shouldn't
      operate in a vacuum"):** map (intelligence × tok/s × memory) for
      local models on consumer Macs at the 24 GB and 32 GB budgets, with
      Qwen3.8-27B as the case study — the best open-weight model that can
      do real work locally. The deliverable is a measured frontier chart
      + the claim "highest benchmarks and highest tps at this memory
      level", defended against NON-OURS points, not just our own arms.
      - Arms (artifact × stack): ours {GPTQ-4bit, TQ-mixed-3.86bpw} ×
        mlx-bun; published {OptiQ-4bit 5.14bpw, mlx-community RTN-4bit}
        × {mlx-bun, mlx-lm}; cross-ecosystem anchor {GGUF Q4_K_M ×
        llama.cpp/Ollama}. KV axis composes: --kv-quant turbo k8v3 is
        the context-headroom lever at fixed weight bpw.
      - Intelligence: ppl ladder (done for most arms) + frozen-eval
        subset (mmlu 100 / gsm8k 50 minimum) per arm, eval DB rows.
      - Speed: quiet-machine benchmark.sh decode/TTFT per arm, labeled
        host/chip/RAM (M1 Max 32 GB here; the 24 GB cut NEEDS the
        M4 Pro — Josh-gated).
      - Memory: peak footprint + max-context-that-fits at each budget
        (fit.ts numbers + measured).
      - Honesty rails: paired same-corpus same-seed; per-bpw-band
        comparisons; no perf claims off a loaded box.
- [~] **W6 release — SINGLE REPO (Josh 2026-08-18: bundling beats
      companion repos):** one artifact = quantized trunk + bf16 vision
      (in-main + optiq sidecar) + folded MTP companion at `mtp/`.
      Engine landed: `--draft-kind mtp` with no --draft-model resolves
      `<model>/mtp/` (server.ts + cli.md/server-config.md same commit);
      27b-tqmix re-packaged accordingly. Publish the W5 winner via
      `mlx-bun upload`; awaiting the recipe outcome + Josh's go.

Non-goals (pinned now): custom Lloyd-Max weight FORMAT / any new qmm
kernel; activation quantization (no int4 tensor cores, decode is
weight-bandwidth-bound — w4a16-compute-precision-spike.md); runtime
weight rotation of any kind (weights fold offline; online rotation
remains the KV codec's job); GGUF/AWQ export.

- [ ] **W6.5 DOGFOOD GATE (Josh 2026-08-19: "I wouldn't even publish this
      model if we can't run it" — mlx-bun end-to-end is the PUBLISH
      BLOCKER, ahead of W6 upload):**
      - [x] eval-runner swap-thrash ROOT-CAUSED + fixed (47d6755):
            greedyDecodeBitExact prefilled whole prompts through the LM
            head ([1,L,248k-vocab] throwaway logits, ~1 GB/1k tokens) and
            never cleared the Metal allocator cache → chunked
            forwardHidden prefill (bit-exact: LM head never touches
            cache) + mlx-lm clear cadence. Verify at 27B post-GPQA
            (memory profile + a re-scored subset).
      - [x] **MTP serve-lane FIXED (2026-08-20, M4, live HTTP repro):**
            TWO defects in the one advertised feature — (1) cli.ts's
            draft gate dropped `--draft-kind mtp` without `--draft-model`
            (bundled `mtp/` resolution unreachable; silent no-op);
            (2) draft #sample fed the sampler [1,1,V] logits where the
            contract is [1,V] — top-k's 2-D slice threw the 500 (chat
            defaults carry top_k=20; the greedy harness never hit it;
            same latent bug fixed in glm52-mtp-source). Chat 500s now
            log server-side stacks. Verified over HTTP on the 24 GB M4:
            serial+spec lane, default + greedy sampling, 2.3 tokens per
            target forward, zero 500s.
      - [ ] `mlx-bun perplexity` on qwen3_5 (trainForward cache stub
            lacks SSMCache.advance — qwen3_5.ts:226).
      - [ ] Dogfood close-out: re-score a GPQA subset (~30 q) through
            mlx-bun and match the mlx-lm scores — turns cross-engine
            parity into a certification-data claim, and future eval
            sweeps run in-engine so soak telemetry is OURS.
      - [x] **DeltaNet prefill leak FOUND+FIXED (2026-08-20, the gate's
            first big catch):** qwen3_5 leaked ~1 MB/token of active GPU
            memory in prefill (2.0 GB per 2048-chunk; 46 GB at 32k;
            async-OOM on the 24 GB M4 at ~10-16k). Root cause:
            `cache.conv = ops.contiguous(tail-slice)` — the slice is
            already row-contiguous at B=1, so contiguous() returned a
            NO-OP VIEW pinning the whole [1,S+3,10240] chunk buffer
            (42 MB × 48 layers = the 2.015 GB, exact). Fix: new
            `mlx_copy` binding + `ops.copyOf` true copy; probe now flat
            (16.3→17.2 GB over 16k; peak 19.2 — 27B fits 24 GB). Proven
            by removal; a sibling-retention hypothesis was tested first
            and falsified. Audit swept 7 more extract-and-own
            `contiguous(view)` sites (batched per-row KV extract — the
            A7 RSS residual suspect — glm52 trim, SSM row cut) → all
            copyOf now. Diagnosis harness: tq-mem-probe.ts.
      - [ ] 24 GB near-ceiling UX (M4 2026-08-20: 17 GB model + 1k
            prefill = uncatchable async-GPU-OOM panic at the DEFAULT
            iogpu wired limit ≈75% RAM; `sysctl iogpu.wired_limit_mb=21504`
            fixes it): serve/cli should detect weightsBytes ≈ default
            limit and PRINT the sysctl advice up front instead of dying
            mid-request; document in memory.md + model README ("on 24 GB
            Macs…"). Admission doctrine: clamp/advise, never refuse.
      - (bf16 qwen3_5 loading — .scales hard-require — stays backlog:
        not needed to serve the published quant.)

Queued follow-ups (Josh 2026-08-19, post-campaign — GPU owned by the
certification suite until then):
- [ ] **DSpark×27B Track A:** confidence-scheduled verification on the
      stock MTP head (dynamic γ, STS calibration; no drafter training) —
      paired A/B vs fixed-γ MTP. Design recorded in
      docs/design/dspark-speculative-decoding.md §"27B program".
- [ ] **DSpark×27B Track B:** true multi-token drafter targeting the TQ
      trunk (the 17 GB quant kills the old "27B infeasible to train"
      premise; teacher-forced data gen on the frozen trunk). Gate: beat
      MTP's 0.68 generalizing acceptance or drop.
- [ ] **ORPO LoRA on the TQ 27B (QLoRA shape):** frozen 17 GB base +
      bf16 adapters; first step is a one-layer-backward memory probe at
      target seq lens. Adapters are rotation-basis-married to this
      artifact (card note if published).

## Serving architecture consolidation `[~]` (opened 2026-08-21)

Scope note: this dependency-ordered landing branch also carries the preparatory
route extraction, semantic token sink, request ownership/planning, sampler,
KV/cache capability, runtime-snapshot, and weight-transform seams that S0–S3
build on. They are part of the requested repository-organization campaign, not
unrelated product features. Route parity tests pin every extracted dispatch;
the PR keeps them together because the deeper completion interface consumes
those seams directly.

- [x] **S0 Completion execution.** Added an opaque, single-use
      `PreparedCompletion` and a `CompletionExecutor` over the existing
      `GenerationGateway` and `CompletionSink`. One executor now owns
      admission, placement reporting, semantic events, logprobs, finish
      reason, usage, and pre-generation cleanup for chat and raw-text,
      streaming and non-streaming. The HTTP adapters still own protocol
      frames and JSON shape. `src/server.ts` lost 136 net lines in the S0
      implementation commit. The new
      `execute()` method has cyclomatic complexity 7 and cognitive
      complexity 12 in the code graph.
      - Contract gate: explicit and default-resolved inference settings
        pass through unchanged. A test pins mixed-precision `kvConfig`,
        `quantizedKvStart`, sampling, and adapter selection at the engine
        boundary. Scheduling placement remains a capability check only.
      - Resource gate: admission rejects before stream headers; placement
        failure disposes prepared resources; ownership transfers once before
        generation. Model and cache disposal stay in the gateway/generator.
      - Verification: 44 focused model-free tests pass, `server.ts` imports,
        hygiene and `git diff --check` pass. GPU/model integration tests were
        deliberately not run while the GPQA certification job owns the
        machine.
- [x] **S1 Immutable placement decision.** `GenerationGateway.place()`
      freezes one `GenerationPlacement` for the exact `RequestShape`.
      `CompletionExecutor` uses it for lane reporting and passes it into
      `run()`, which rejects a placement made for another shape. Eligibility
      rules and feature composition are unchanged.
- [x] **S2 Declared model profiles.** Introduce model/artifact profiles that
      name the external artifact fingerprint, fidelity target, required
      engine capabilities, and composed execution path. Keep the generic
      model route as fallback. Specialized Qwen3.8, GLM/Colibri, and future
      frontier profiles may select dedicated kernels and loop structure.
      - `resolveModelProfile()` now freezes artifact identity, config identity,
        fidelity, required capabilities, and loader/graph/loop specialization
        before model construction. Immutable HF snapshot identities are stable
        across cache relocation; local paths and mutable aliases are not
        misrepresented as exact artifacts.
      - Exact declarations pin the validated Qwen3.8 OptiQ and GLM-5.2 Colibri
        revisions. Exact matches outrank family profiles; family profiles retain
        every previous dedicated/generated path; universal dense remains the
        final supported fallback. A matched exact profile with a config or
        capability mismatch refuses instead of downgrading.
        The mutable `mjriii/Qwen3.8-27B` staged artifact intentionally remains
        on the Qwen family profile until the running GPQA evidence closes and a
        published immutable revision can bind that evidence.
      - `createModel()`, `openModel()`, and `loadContext()` consume the declared
        composition; `ServerContext.profile` and the public library exports make
        it inspectable/composable. Profiles do not own MTP, KV, adapters,
        grammar, or sampling, so existing explicit/default-resolved behavior is
        unchanged.
      - Model-free verification: profile/factory/support tests pass, the public
        TypeScript surface typechecks with zero errors, and GPU/model tests were
        deliberately deferred while the GPQA certification job owns the machine.
- [x] **S3 Unified batch mechanism.** Make serial execution the B=1 fast path
      of the same scheduling mechanism where measurements support it. Preserve
      the current serial route until B=1 latency and parity gates pass. Never
      downgrade MTP, KV schemes, TurboQuant, grammar, adapters, or sampling to
      make a request batchable.
      - `GenerationPlacement` now declares `serial` or `continuous`; it no
        longer predicts that a request is "batched." `CompletionExecutor`
        reports and executes that same frozen declaration. Active-row count
        chooses the adopted-cache B=1 fast path or B=N step inside the
        continuous scheduler.
      - The existing evidence supports the current cutover: default-scheduler
        B=1 is byte-identical on the curated serve parity probes and recorded
        paired decode ratios are 0.992–0.996. `--batch 1` still pins the strict
        serial executor, and compositions not yet implemented by the scheduler
        use that executor unchanged.
      - The placement support check does not rewrite MTP/drafting, KV schemes,
        TurboQuant, grammar, adapters, or sampling. Tests pin the mechanism at
        the gateway/executor seam and preserve resolved mixed-KV, sampling, and
        adapter inputs by identity/value.
      - Verification: 55 pure model-free tests pass and the full TypeScript
        surface typechecks. MLX-array tests were not used as a gate after the
        concurrent GPQA run left the MLX stream unavailable; GPU/model
        integration remains deferred.
      - Review hardening (2026-08-21): the resolved `KvScheme` is now the
        authoritative value through server resolution, gateway placement,
        scheduler cache conversion, and KV-budget projection. The scheduler
        no longer rebuilds its conversion map from the legacy `kvConfig`
        fallback, and placement probes the actual configured cache instances
        before admitting a quantized request to the continuous mechanism.
        Scheme-driven conversion and non-convertible-cache regressions pin both
        ends of the interface. The legacy raw `kvConfig` scheduler/budget
        inputs are removed, so production, tests, and diagnostic scripts all
        traverse the same `KvScheme` seam; quantized `batchable()` also returns
        false unless its caller supplies the real cache-conversion probe. The
        scheduler independently refuses an unsupported scheme at construction
        instead of silently serving bf16 with quantized budget accounting.
      - The same audit found two adjacent boundary violations and closed them:
        all in-process benchmark, memory, and training-diagnostic overrides
        now use `configureRuntime()` instead of mutating the already-snapshotted
        environment, and native
        quantization publishes a complete staged model directory with one
        same-filesystem rename. An interrupted writer cannot expose rotated
        weights with a stale config. `CompletionExecutor` also reports live
        token usage to protocol adapters, so an Anthropic/Responses stream
        that fails after emitting tokens closes with accumulated usage instead
        of fabricated zeros. The live usage view is installed only for those
        protocol adapters; ordinary OpenAI streaming selects the no-usage token
        consumer once per request and has no added per-token branch. A worked
        4-wide Llama numerical test now drives the public
        `WeightTransform` plan/context/apply interface and pins R1/R2,
        normalization, tied-head, attention, and MLP fold values instead of
        checking plan shape alone.
      - Review-focused verification after the GPQA pause: 97 fast model-free
        tests pass. All three real mixed-KV GPU gates pass against local
        MiniCPM5 and Gemma 12B artifacts: MiniCPM B=1 is bit-exact for every
        checked logit step; its B=2 padded row peaks at KL 1.21e-1 under the
        0.2 bar; Gemma rotating-quant rows peak at KL 0 and 3.04e-3 under the
        1e-3/1e-1 bars. The missing machine-local MiniCPM binary logits were
        regenerated from the pinned mlx-optiq oracle; the tracked manifest now
        records oracle versions, artifact revision, generator, and blob hashes.
      - Final acceptance (2026-08-21): the complete hygiene-gated two-shard
        suite passes 2,064 tests with 75 intentional skips and zero failures.
        The public TypeScript surface, both Bun entry bundles, web bundle
        freshness, and `git diff --check` pass. All required ignored binary
        fixtures were regenerated from the pinned local oracles; their tracked
        manifests did not drift.
      - A real browser acceptance run started `mlx-bun`, used the shipped web
        UI for a two-turn conversation, and verified streamed content, tool
        cards, context carryover, request metrics, and composer recovery. It
        exposed a pre-existing mainline race: a queued animation-frame render
        closed over mutable assistant state after `turn_end`, causing a null
        dereference and, after the first narrow fix, duplicated final content.
        Per-turn captured state plus an explicit settled guard fixes both; a
        deterministic DOM test drains the pending frame after turn completion.
      - The same full pass fixed two adjacent mainline lifecycle defects. GLM
        compressed-cache filtering now removes common padding before row
        selection and owns the selected result, preserving exact surviving
        rows. Atomic quantization accepts a caller-created empty destination
        but still refuses a populated one and never publishes partial output.
        Server admission tests now pin the documented clamp/diagnostic contract
        instead of the superseded rejection behavior. None of these changes is
        in the token decode hot path: DOM rendering is client-side, GLM row
        filtering runs only on batch membership changes, and atomic publication
        is offline conversion I/O.
      - Post-review immutability gate (2026-08-21): `KvScheme` now copies and
        freezes every per-layer entry and the nested TurboQuant declaration,
        so caller mutation cannot change cache conversion or accounting after
        capability resolution. `GenerationGateway.place()` freezes the exact
        `RequestShape` before it selects a mechanism or exposes placement to a
        callback. Mutation regressions pin both boundaries.
      - Current hot-path performance gate (2026-08-21): two interleaved
        256-token MiniCPM5 serial benchmark repeats ran the identical script
        against clean `main` and this branch. Median best serial decode was
        265.0 tok/s on both sides (branch/main ratio 1.000). This directly
        covers the `StepSampler` change that post-dates the older 0.992–0.996
        scheduler/serial ratios.
- [ ] **S4 Land and post-merge verify.** Open the consolidation PR against
      `main`, resolve code-review and CI findings with focused regressions, and
      rerun the real server/UI conversation on merged `main`. Exit when checks
      are green, the PR is merged, no server remains running, and this phase
      plus its active execution-seam design doc move to the archive.

## Prefill vs mlx-lm — paired re-measurement + root-cause sweep `[x]` (2026-08-22)

Question: do we win prefill? (Josh: decode already wins; prefill was the open
flank.) Method: interleaved fresh-process pairs via `scripts/bench.ts` /
`--baseline` (bf16 KV, identical filler+template conventions, medians),
plus in-process sweeps (`scripts/experiments/prefill-chunk-ab.ts`), a
weight-residency A/B, logits-level chunk-size probes
(`scripts/experiments/prefill-logits-ab.ts` + python twin), and one served
h2h pass. Machine was NOT quiet (ambient loadavg ~3, Chrome/Spotlight
bursts) — ratios within a window are usable, absolute levels are not;
backing rows in the eval DB.

**Served prefill: WE WIN, post-consolidation confirmation** (e4b, real
servers): prefill@1k **1143 vs 866 tok/s (+32%)**, warm TTFT **39 vs 230 ms**
(5.9×), cold TTFT 578 vs 772 ms, decode 53.9 vs 50.3, both parity probes
byte-identical. The engine-level deltas below never survive to the product
surface — their server tax dominates.

**Engine-direct: parity within noise on every model/context except two
reproducible cells.** cpm5 parity everywhere (−2%..+6%); 12B −1..−2% ≤1k,
−0.6% @16k, and −5..−8% @4k/8k ONLY in noisy windows — controlled re-runs
(same-hour singles 232.8 vs 238.1; in-process sweeps 225-233 vs 224)
overlapped bands; the morning deficit did not survive protocol changes.
26B: parity @1024; ≥4k OOMs on BOTH stacks on 24 GB (capacity fact, not a
defeat). Reproducible residuals, both FRESH-PROCESS-only: e4b @256 tok
−12.5% (~30 ms/call fixed cost; in-process only −4%) — candidate host-side
graph-build overhead through bun:ffi vs pybind; low priority given the
served surface. Decode meanwhile reads +7..14% for us in every window
(consistent with the June residual being resolved by later work).

**Root-cause hunt (why python sits stable while we swing):** found their
structural difference — `mlx_lm.load_model(lazy=False)` runs
`mx.eval(model.parameters())`, COPYING every weight out of the file mmap
into allocator-owned buffers at load (measured: eval of an mmap-backed
array is a real copy; full 12B = 1.48 s inside their 37 s ready time). We
keep mmap-wrapped arrays forever (we only eval outputs). Hypothesized this
explains their generation-phase stability; implemented the mirror behind
`MLX_BUN_WEIGHTS_MATERIALIZE` and ran an interleaved OFF/ON A/B ×6 @12B-8k:
**NULL** (medians 216 vs 216) → flag REVERTED, hypothesis dead as measured.
Also killed: file-cache eviction (cat-ing shards through page cache did not
restore speed), warm-in (sweep rep0 ≈ steady), kernel compile (same),
chunk-boundary accounting (drain-loop conventions verified identical:
2048 chunks, drain-to-len−1 tail split, clear_cache per chunk).

**Chunk-size lever: dead for L1, by Josh's logits test.** Smaller chunks
are faster in-process (512/1024 beat 2048 by up to +9% @12B-8k) AND
bit-deterministic at fixed size, BUT logits drift when the convention
changes — and PYTHON DRIFTS MORE (max|Δlogit| ours 0.99/1.81 @1024/512 vs
theirs 4.16/1.31; determinism controls exactly 0 both sides). Intrinsic mlx
reduction-order sensitivity to SDPA key-axis tiling. Since outputs are
convention-pinned, deviating from 2048 breaks bit-parity with mlx-lm
defaults → not an L1 win; earlier "identical greedy trajectories" was
argmax robustness, not bit equality. (Probe gotcha worth remembering:
`Dtype` from ffi.ts is a const enum with lowercase members — a wrong-cased
member is `undefined` at runtime under bun and silently skips the cast.)

**Follow-ups opened:** (1) e4b agg×4 anomaly in today's serve pass — ours
26.6 vs mlx-lm 107.3 tok/s aggregate at 4 concurrent streams despite
winning single-stream decode; possible batch-lane regression from the
consolidation merge, needs its own eyes before any claim. (2) bench-harness
padding drift: our filler loop stops ~7 tokens short of python's on some
tokenizers (267 vs 274 @e4b) — template/counting nuance, makes py wins
conservative, but benchmark.sh's prompt_tokens-equality check would flag it.
(3) Quiet-box confirmation of the served row before quoting absolutes.

## Qwen3.8 prefill — measurement + analysis `[~]` (2026-08-22 evening)

Question (Josh): "for qwen, our performance might not be optimal." Subject:
`mjriii/Qwen3.8-27B-compact` (13 GB — the only Qwen3.8 artifact that fits
24 GB; the 19 GB OptiQ-4bit OOMs the GPU on BOTH stacks here). Architecture:
64 layers = 48 gated-DeltaNet linear + 16 full attention; mixed 4/8-bit
affine quant. Machine quieted (Chrome/Battle.net killed). Method: paired
fresh-process `bench.ts` + in-process sweeps + phase profiling.

**Measured landscape (bf16 KV, paired, prefill tok/s):**

| ctx | ours | mlx-lm | Δ |
|---:|---:|---:|---:|
| ~256 | 94.3 | 107.7 | **−12.5%** |
| ~1024 | 102.8 | 113.8 | −9.7% |
| ~4096 | 94.2 | 72.7 | **+29.6%** |

Decode +17% for us (@256: 21.2 vs 18.1). So: we LOSE short-context by a
constant-ish ~10-13 tok/s, WIN long-context (python degrades with chunk
count, we hold flat).

**Root-cause work so far:**
- Delta-rule scan is NOT the gap: we dispatch mlx-lm's exact Metal kernel
  (same grid/threadgroup/template), unmasked at B=1 both sides; kernel
  sync-profile ≈ 2.8 ms/layer ×48 ≈ 130 ms/chunk.
- Decode arithmetic proves bandwidth ceiling reached (13 GB / 47 ms step ≈
  276 GB/s); prefill wall (~2.5-3.3 s @S=300) is dominated by QUANTIZED
  MATMUL COMPUTE over S (qkv alone ≈ 31 GFLOP/layer), i.e. both stacks are
  qmm-throughput-bound and sit tens of times off any bandwidth roofline.
  Our deficit is a uniform per-op efficiency delta vs pybind dispatch of
  the same mlx primitives — not one bad kernel.
- mx.compile experiment — CLOSED NEGATIVE (2026-08-22 night). Compiling the
  state-free delta core per layer, two variants measured: (a) weights
  closure-captured → +~8-10% steady BUT peak 14.3→22 GB (mlx bakes closed-
  over arrays into each compiled graph; 48 layers duplicated ~half the
  weights); (b) weights as trace INPUTS → memory fixed (14.9 GB) but the
  speed win VANISHED (~66 vs ~72 tok/s default) — proving the "+10%" was
  RAM-for-speed trading (constant baking), not dispatch reduction. Bit-exact
  trajectories in all variants. Conclusion: prefill is qmm-COMPUTE-bound;
  compile doesn't reduce qmm compute. Path stripped; phase profiler kept
  (env-gated via `__deltaProf`, zero cost when unset).

**Improvement roadmap (revised):**
1. Find the ~10% per-op qmm/dispatch efficiency delta vs python (candidate:
   our FFI outArray/error handling per op; candidate: mlx-c dylib build vs
   pip mlx codegen differences). A uniform win here lifts EVERY model's
   prefill. NOTE: this is now the only open lever for short-context Qwen.
2. Python's long-context degradation (113.8@1k → 72.7@4k) is unexplained;
   understanding it may reveal a lever we already have (we hold flat).
3. The 27B full-size artifacts OOM both stacks on 24 GB — capacity note,
   not actionable.

## agg×4 regression — root-caused and fixed `[x]` (2026-08-22, same day)

The lead above was real and is closed. Symptom: unified-engine serve at 4
concurrent short streams = 19-27 tok/s aggregate with rows dying after 1-2
tokens (silent SSE close, no finish frame); `--batch 1` healthy at 52;
pre-merge `2f24caa` healthy at **122.5** tok/s with true batching (~2.3×
serial). Bisect over the merge commits isolated **`443f333` ("route batch
rows by cache capability")**.

Root cause: `BatchedRotatingCache` (bf16) has no `signature()` override, so
`cacheSignature()` → `"unknown"`. 443f333 routed the running batch's cache
into the rot-merge through `isRowBatchCache(prevC) && isRotatingPlainCache(prevC)`
— the second conjunct is false for EVERY bf16 batched cache → `prevRot`
undefined → joiners merged WITHOUT the running row's KV → next full-B decode
step crashed in `updateAndFetch`'s grow-path concatenate (`(1,2,23,256)` vs
`(4,2,256,256)`) → whole-batch drop. The quantized variant escaped because
`BatchedRotatingQuantCache extends RotatingQuantizedKVCache` and inherits a
real signature. Lesson: signature-based routing needs every class to HAVE a
signature — "unknown" must be treated as a bug, not a route.

Fix (one hunk, src/serve/batch-scheduler.ts): within the `"rot"` branch,
route by capability alone — `isRowBatchCache(prevC)` — since the quant
family is dispatched by its own earlier branch. Post-fix e4b CONC×4 =
122-126 tok/s aggregate, all rows finish=length (matches pre-merge);
cpm5 547 tok/s agg; 12B all-rows-complete. Regression pinned by
tests/batch-rotating-join.test.ts (gated, `MLX_BUN_TEST_BATCH_DECODE=1`;
fails pre-fix with the exact concatenate shapes, passes post). Full gated
batch family + tsc green. Coverage gap that let this slip: batch unit tests
only exercised full-attention CPM; the rotating join path now has its own
test.

## Context / lore

Born from an evening of running gemma-4-12B-it-OptiQ-4bit through the
Python stack on this machine (M4 Pro, 24 GB): Xet download stalls, a
segfault on ctrl-C, a PIL-shaped missing dependency, a repo-id-vs-path
crash in the vision engine, and an OOM-by-prompt-cache footgun — none of
them GPU problems. The thesis of this project is that the layer with all
the bugs is also the layer that doesn't need Python.

## Repo hygiene cleanup (2026-07-02)

Landed the phased cleanup (docs/design/repo-cleanup-plan.md): Phase A
(`repro/`+`spikes/` → `lab/`, `archive/` → `docs/archive/`, root strays
cleared), Phase B gate (`scripts/check-hygiene.ts` — binary-in-git +
docs-map coverage, wired into `scripts/test.sh` + CI `hygiene` job),
D2 (already gitignored), D3 (docs-map drift caught + fixed). Findings:
- **B2:** `fixtures/adapters/{upper,french}/adapters.safetensors` (6.6 MB
each) KEPT tracked on the gate's explicit allowlist — stable one-time-
trained LoRA adapter inputs (not churning), opt-in weight-gated test only.
Untrack deferred to Josh pending a confirmed bit-exact regen trainer
(adapter_config.json is ambiguous between optiq `lora train` and mlx-lm).
- **B3:** 27 `tests/fixtures/universal-rope/*.bin` (4–8 KB) +
`qwen-delta-golden.json` (1.08 MB text) STAY — model-free CI-load-bearing,
regen scripts exist.
- **D1:** no `[x]`/CLOSED phases <17 in PLAN.md to archive; phases 6 & 16
have all boxes checked but carry a deliberate `[~]` — reclassify is Josh's
call. oMLX (closed) + Phase 19 are newer than 17, stay.
- **C (history rewrite):** still Josh go/no-go — both laptops re-clone
after. The gate now prevents re-formation regardless.
