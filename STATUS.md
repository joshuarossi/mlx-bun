# STATUS — live handoff

The single "what's the state, what's next" doc. Durable phase history,
exit criteria, and findings live in [PLAN.md](PLAN.md); this file is the
transient front door that stays current. Product/UX north star:
[docs/planning/PRODUCT_ROADMAP.md](docs/planning/PRODUCT_ROADMAP.md).

## Training — segmented backward, Phase A COMPLETE (2026-06-16, uncommitted on `main`)

Long-context LoRA SFT that streams the backward segment-by-segment so only one
segment's activations are live — fits where the optiq/mlx-lm reference spikes/crashes.
On PR [#9](https://github.com/joshuarossi/mlx-bun/pull/9) (`segmented-backward-training`).
**Phase A (MiniCPM5) done + validated + quality-confirmed:** bit-exact grads vs the
full backward (relNorm 0.0000% under flash), peak **10.91 → 3.29 GB @2048** (non-seg
spikes to 21–26 GB @4096; seg stays 6–8 GB), **no memory leak**. Real 300-iter run:
peak **6.51 GB** (baseline 25.47 GB), `chunk-eval` **95.10/100** — EXCEEDS the
non-segmented baseline (91.70). **Phase B (e4b) BUILT + validated:**
`SegmentedBackwardGemma4` (`src/train/segmented.ts`, wired into the trainer) —
forward bit-exact, grads bit-exact for single-consumer donor reuse / ~1% bf16-class
(bf16 non-associativity, grouping-controllable) for the multi-consumer donor-KV sum.
**Trains all 42 layers at 8K (17.5 GB) where `mlx_lm.lora --grad-checkpoint` OOMs
training the same (verified: mlx-lm fits 8K only by dropping to its default 16
trainable layers, 25.7 GB).** At 2K/4K both train all 42; segmented ~15-25% lower
(seg 11.0/16.1 vs mlx-lm 12.8/20.9 GB). No leak; adapter saves. NOTE the earlier
"reference crashes at 4K / ~70 GB" claim was WRONG — it used mlx-bun's OWN
checkpoint (ineffective, 23 GB @2048) as the baseline, not mlx-lm's. Full results +
the corrected mlx-lm comparison: docs/design/segmented-backward-training.md §10. Enable via `TrainConfig.segmentSize` (layers
per segment; 0 = off). Key files: `src/train/segmented.ts` (`SegmentedBackward`),
`src/model/minicpm5.ts` (`runLayerRange`), `src/mlx/autograd.ts` (`Vjp` — the
backward uses `mlx_vjp`, NOT a surrogate-loss `value_and_grad`, which leaked).
Two findings worth knowing: (a) `ops.sdpa`'s fused-eager forward ≠ its autograd
forward in bf16 (~0.12%) — use `MLX_BUN_TRAIN_ATTN=flash` for exact segmented grads;
(b) mlx `eval` doesn't detach, so boundaries are copied to leaves (`fromBytesCopy`).
Full dossier: [docs/design/segmented-backward-training.md](docs/design/segmented-backward-training.md) §9.
**Next:** real 300-iter chunk fine-tune + `chunk-eval` quality vs the 91.70 baseline,
then Phase B (e4b: KV-sharing + per-layer-input + full-attn O(L²) isolation, §5 plan).

## Active branch (2026-06-15) — `qwen3-5-27b-bringup`: Qwen3.6-27B-OptiQ-4bit port

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

## Current state (2026-06-15) — merged to `main`: batched serving + expert offload + HLG Curve Designer

> **HLG Curve Designer (NEW, this session).** A v2 replacement sampler — draw a
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
  Latest commit landed batched-decode foundations + the mlx-lm B=N parity
  oracle (S1b). Batch parity gate = bit-exact vs mlx-lm B=N at the same
  setting (not vs our own B=1). See PLAN.md Phase 18 + parity oracle
  notes, and `docs/design/parallel-slots.md`.
- **Just completed: docs/repo reorganization** — benchmark provenance
  consolidated into [benchmarks/RESULTS.md](benchmarks/RESULTS.md)
  (3 sections: parity / performance / quality), planning docs moved under
  `docs/planning/`, root decluttered, AGENTS.md de-duplicated. Plan and
  rationale: [docs/design/docs-reorg-plan.md](docs/design/docs-reorg-plan.md).
- **Phase 19 — expert offload (single-user MoE residency): spike complete,
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
  PLAN Phase 19 +
  [docs/investigations/expert-offload-single-user-moe.md](docs/investigations/expert-offload-single-user-moe.md).
  Probes/tooling: `scripts/probe-{expert-residency,mmap-gather,madvise-eviction,footprint,metal-wire}.ts`,
  `scripts/run-expert-trace.ts`, `scripts/analyze-expert-trace.ts`, `src/expert-trace.ts`.

> **Resume here:** on `main` (merged). The HLG Curve Designer: `mlx-bun serve <model>`
> → "Curves" tab. Batch-serving + expert-offload remaining work is below.
> Full design + rationale: `docs/design/parallel-slots.md`. Principles are in
> auto-loaded memory (drop-in-for-mlx-lm; optimization-tree/parity-as-correctness;
> per-model/quant specialization; concurrent-serving-slots).

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

## Next action — extend the live `--batch N` engine (serves full-attention AND sliding-window B>1)

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

## Open / Josh-gated

These need Josh physically (hardware, downloads, reboots):

1. **Clean-machine `./benchmark.sh --redo`** after a reboot (+ `sudo purge`
   for purge-cold rows) — quotable rows for the post-decode-fix engine and
   the perf-kernel default decision. Promote results into
   `benchmarks/RESULTS.md`.
2. **M1 Max rerun** — `git pull` then `./benchmark.sh --redo` (its last
   matrix predates the rope-fix).
3. **Phase 14 — Qwen 3.x bring-up** (was targeted ~2026-06-15): pick +
   download the first Qwen quant; also the MTP home and a consumer of the
   default-off fused-decode flag.
4. **Phase 13 — TurboQuant** (promoted research direction).
5. **Phase 12 — SigLIP vision** (on hold; only if needed).
6. **`MLX_BUN_PERF_KERNEL` default flip** — gated on the clean-machine pass.

## Archived handoffs

Older dated handoff blocks (2026-06-10 / 06-11) live in PLAN.md under the
"NEXT UP" / "NEXT SESSION PICKUP" / "SESSION SWEEP" headings, marked as
superseded. They're kept for history; this file is the current state.
