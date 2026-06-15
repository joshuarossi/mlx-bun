# STATUS — live handoff

The single "what's the state, what's next" doc. Durable phase history,
exit criteria, and findings live in [PLAN.md](PLAN.md); this file is the
transient front door that stays current. Product/UX north star:
[docs/planning/PRODUCT_ROADMAP.md](docs/planning/PRODUCT_ROADMAP.md).

## Current state (2026-06-14) — Phase 18 batched serving LIVE (full-attention), on branch `batch-serving`

> **`--batch N` now actually serves B>1** for full-attention models (CPM):
> scheduler + gateway wired into the live server, end-to-end tested. Remaining:
> Gemma/sliding-window dynamic-B, the `extend` join optimization, prompt-cache
> reuse under batching, and clean-machine throughput numbers.

> **Resume here:** `git checkout batch-serving` (off `main`; not yet merged).
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
- Oracle tooling: `scripts/gen-batched-golden.py` (needs optiq `register()` to
  load gemma4_unified in mlx-lm; uses mlx-lm `_make_cache`) → fixtures
  `tests/fixtures/batched-golden-*.json`. Real-path validator: `realBatchedGreedy`
  + gated `…ORACLE…` tests in `tests/batched-decode-parity.test.ts`
  (run: `MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batched-decode-parity.test.ts`).
- Earlier (on `main`): P1 parallel-load harness (`scripts/bench-serving-load.ts`).

## Next action — extend the live `--batch N` engine (it serves full-attention B>1)

The engine is BUILT and LIVE (steps 1, 2a, 2b done — below). Remaining work, in
rough priority. Gate each with the teacher-forced parity tests; keep `--batch 1`
(and serial fallback) untouched.

- **Gemma / sliding-window dynamic-B** — the big one. The scheduler is
  full-attention only (`BatchScheduler.#admit` throws on `RotatingKVCache`;
  gateway routes sliding-window models to serial). Needs per-row ring-wrap mask
  + `mergeKVRows`/`filterKVRows` for `RotatingKVCache`, gated against a sliding
  mlx-lm dynamic golden. Until then `--batch N` only batches CPM-like models.
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
