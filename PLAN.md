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


> Completed early history — Phases 0–5 and 8–11, Optimization Plans A–D, and the early session-handoff blocks — lives in [PLAN-archive.md](PLAN-archive.md). (Phases 6 `[~]` and 7 `[ ]` remain active below.)

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
  [orpo-flash-cce-pin-leak.md](investigations/orpo-flash-cce-pin-leak.md).
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
  - [ ] **teacher-forced grad fidelity** — flash vs full-logits `dh` (cosine +
        relnorm) on real data, as the standing L3 quality regression.
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
  Full design + roadmap: [parity-tier-dag.md](design/parity-tier-dag.md).
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

## Phase 13 — TurboQuant `[ ]` (research path — PROMOTED 2026-06-12)

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
      serving now done — see PLAN-archive.md NEXT UP block; landed Phase 9/10).
      First sub-step needs no Python: our
      server-vs-our-direct overhead via an ephemeral in-process server
      (e4b, idle machine) — pins the "our server adds ~nothing" half
      of the 70%-faster hypothesis.
- **Decision (Josh, 2026-06-10): do not start ANY of these
  measurements — including the Python-free server-overhead sub-step —
  until mixed-precision KV serving landed (see PLAN-archive.md NEXT UP block;
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
      pickup instructions live there now) (now in PLAN-archive.md).
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
docs/investigations/pi-builtin-investigation.md (+ styled HTML twin). pi v0.79.1, MIT,
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
      aesthetic (archive/wwdc-mlx-bun.html grammar — black stage, gradient
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
      docs/investigations/lab-build-journal.md +
      archive/mlx-bun-lab-report.html.
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
      prompt-cache hit on turn 2). Details in docs/planning/journal.md.

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
docs/investigations/pi-builtin-investigation.md) and the built-in web UI make us *more
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
            (tests/fixtures/batched-golden-cpm.json).
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

> **Status (2026-06-17):** Empirically a wash vs. plain temperature (Pass 4 verdict: within N=10 noise). Superseded by the Curve Designer (`src/curve-sampler.ts`) which shipped as a general-purpose tone-curve sampler. Findings preserved as history; open items below are struck as moot.

A new sampling transform inspired by HLG (Hybrid Log-Gamma, the HDR transfer
function): where temperature is one global slope, HLG is **piecewise** — a
pivoted toe/gain/shoulder curve on the per-token log-probs that rolls off the
highlight (top-token dominance), boosts the mids (novelty/local contrast), and
holds a soft toe on the shadows (suppress the tail smoothly, don't crush the
blacks). The thesis: temperature *couples* "reduce top dominance" with "inflate
the tail"; a region-aware tone curve **decouples** them. Post-inference and
model-agnostic — applies to all four models and both lanes with no per-model
code. Full design + math in **docs/design/hlg-sampling.md**.

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
      (docs/investigations/hlg-sampling-investigation.md), server-config /
      server-api / README sampling sections, STATUS next-action, memory note. (moot — superseded)~~

- ~~**Exit criterion**: neutrality gates bit-exact across all four models and
  both lanes; capability suite non-regressed (or, if it regresses, shipped
  default-off with a documented creative/open-ended use-case); a measured
  diversity gain at matched entropy vs temperature; ~0 decode-tok/s regression
  with the flag on. Default stays **off** regardless — novel knob, never a
  silent change to the default sampler. (moot — phase closed/superseded)~~

### Phase 19 findings (2026-06-14) — see docs/investigations/hlg-sampling-investigation.md

Curve in place; HLG finalised as a **replacement sampler** (`if hlg → curve
else → top_p/top_k/temperature`). Pivot question answered empirically on e4b
(4 runs, `scripts/experiments/hlg-compare.ts`; full transcripts in
docs/investigations/hlg-runs/):
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
docs/investigations/hlg-sampling-investigation.md.

## Publishing decision (2026-06-12, Josh)

Zip-sharing is over — publish properly: **bun/npm first, then brew.**
(npm channel = source package running under the user's bun; brew =
the compiled bundle. Publishing likely also means making the repo
public, which fixes the native-pack anonymous-download caveat.)
Two gates before publishing:
- [x] **Sub-GB starter model working** — MiniCPM5 Track A chosen and
      ported on branch `codex-minicpm5-starter-port`. See
      **docs/investigations/starter-model-port-handoff.md** for the discovery that
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
design + reasoning: `docs/investigations/expert-offload-single-user-moe.md`.

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
- Two fused custom kernels in the forward have no vjp: the perf decode
  kernel (`MLX_BUN_PERF_KERNEL`) and the GEGLU MLP kernel
  (`MLX_BUN_FUSED_GELU`). Training MUST disable both (set =0) or backward
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
- Refs: `docs/investigations/steel-flash-cce-handoff.md`, `docs/reference/orpo-quickstart.md`,
  `docs/reference/training.md`. `[~]` open: the big CPM5 UF run + the chunk segmenter + e4b overnight.

## Context / lore

Born from an evening of running gemma-4-12B-it-OptiQ-4bit through the
Python stack on this machine (M4 Pro, 24 GB): Xet download stalls, a
segfault on ctrl-C, a PIL-shaped missing dependency, a repo-id-vs-path
crash in the vision engine, and an OOM-by-prompt-cache footgun — none of
them GPU problems. The thesis of this project is that the layer with all
the bugs is also the layer that doesn't need Python.
