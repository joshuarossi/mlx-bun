# Batching v2 — state map, debt, and the gap plan

Status: **PLAN** (written 2026-07-01, read-only audit — no code changed)
Scope: the `--batch N` continuous-batching engine (`src/serve/batch-scheduler.ts`,
`src/serve/generation-gateway.ts`, `src/model/batched-mask.ts`,
`src/model/batched-rotating.ts`, the `server.ts` wiring).
Predecessor docs: [parallel-slots.md](parallel-slots.md) (the design, still
accurate on the primitives), PLAN.md Phase 18 (history),
[server-config.md](../reference/server-config.md) (user-facing modes doc).

Mandate (Josh): batching is "kinda implemented, but is not great… make sure we
have all the code really well done, and documented and exposed via the flags."

**Standing decisions honored throughout (do not relitigate):**
- `--batch N` is a **mode switch**, not a load-dependent fallback. Josh decided
  this explicitly (determinism: results must not depend on concurrency, and the
  drop-in-for-`mlx_lm.server` promise needs a predictable path). Auto-batching
  "when >1 request arrives" was considered and **rejected** — an idle-vs-loaded
  server would produce different numerics for the same request. This plan keeps
  `--batch` as the UX and documents the rejection.
- The batched lane is **compat mode** (bit-parity with mlx-lm B=N, bf16, no
  perf flags) — see server-config.md "compat mode" section. All work below
  preserves that guarantee; anything that can't be oracle-gated is L3 and
  deferred (item f).

**In-flight work this plan routes around (2026-07-01):**
- **Same-ms seed collision fix** — `server.ts:1120` defaults
  `seed: req.seed ?? (Date.now() & 0xffffffff)`; two batched rows admitted in
  the same millisecond sample identical RNG streams. A fix is IN FLIGHT by
  another agent. Noted as context; **not planned here**.
- **`src/model/gemma4-base.ts` is modified in another agent's working tree**
  (and `src/model/universal/` is a new in-flight subsystem). Items below that
  would naturally touch cache classes are designed to live in NEW files
  (`BatchedKVCache` beside `BatchedRotatingCache`) precisely so they don't
  collide; coordinate before touching gemma4-base.ts.

---

## 1. State map (verified against code, not docs)

### 1.1 Architecture as built

```
handler (server.ts)                         GenerationGateway (generation-gateway.ts)
  promptIdsFor → options → RequestShape ──▶   willBatch(shape)?
  onToken closure (StopMatcher +               ├─ no  → AsyncMutex → serialRun
    tool router + thinking splitter +          │        (= runGeneration: PromptCache
    SSE send / collector)                      │         take/put + generate())
                                               └─ yes → BatchScheduler.submit
                                                          (batch-scheduler.ts)
BatchScheduler #drive loop (detached, Bun-async, no threads):
  acquire mutex (held first-admit → batch-empty)
  ├─ #admit each pending row: SOLO prefill (one forward, whole prompt)
  │    → sample token 0 → re-MERGE whole batch per layer
  │    (full layers: temporalView + per-row slice + mergeKVRows → new KVCache;
  │     rot layers: BatchedRotatingCache.merge)
  ├─ #step: forward [B,1] (full layers wrapped per-step in
  │    BatchedDecodeMaskCache; rot caches persistent), per-row sample on
  │    [1,V] slices, SYNC readback [B], clearCache()
  ├─ #emit per row (EOS → "stop" w/o onToken; onToken false → "stop";
  │    generated ≥ maxTokens → "length")
  └─ #applyFilter(keep): full layers filterKVRows → new KVCache;
       rot layers filter() in place
```

- **Scheduler loop shape**: iteration-level (continuous) scheduling — admit
  between steps, evict after each step. Correct design; the loop-body
  *mechanics* carry the debt (§2).
- **Admission today**: count-only — `#running.length < #maxBatch`
  (batch-scheduler.ts:138). No byte projection, no KV budget. The server's
  per-request `context_over_budget` 400 (server.ts:~1780, from `fit()`) checks
  each request against **single-sequence** max-safe-context; N rows can jointly
  exceed the budget (documented as limitation #2 in server-config.md).
- **Eviction**: per-step `#applyFilter` (batch-scheduler.ts:327-355) —
  full-attention layers rebuild a fresh `KVCache` from `filterKVRows`
  (takeAxis on B); rotating caches filter in place including padding
  reduction. Matches mlx-lm `filter` semantics (cache.py:1016-1033) except
  ours doesn't do the `min_left_pad` shift-left for full layers (mlx-lm
  reduces padding after filter; ours keeps stale left pad until the next
  merge — correct but wasteful width).
- **Join**: `#admit` re-merges the ENTIRE batch (batch-scheduler.ts:193-254):
  per layer, temporalView of the running batch, B per-row slices, re-concat
  with the new row. O(B·S) traffic per join **plus** ~2B slice kernels per
  layer. mlx-lm instead `extend`s (cache.py:1035-1078): pad self+other once,
  one concat — and prefills joiners as a right-padded *batch* (see item a/d).

### 1.2 The `willBatch` gate — exact predicate today

`generation-gateway.ts:113-127`: batches iff **all** of

```
batch > 1
AND model is not DiffusionGemmaModel          (non-AR)
AND !hasVision                                 (offset-0 prefill + bidir mask)
AND !hasAdapters                               (loraState is one global field)
AND !hasRepetitionPenalty                      (no per-row logits processors)
AND !hasLogitsExtras                           (min_p ∥ xtc_probability ∥ logit_bias
                                                ∥ presence ∥ frequency — one family gate)
AND !wantsLogprobs                             (non-stream logprobs/top_logprobs capture)
AND !userSeed                                  (body.seed !== undefined)
AND !kvQuant                                   (request carries kvConfig/kvBits —
                                                i.e. any explicit --kv-quant)
```

`RequestShape` is built **twice**, near-identically: chat (server.ts:1813-1826)
and completions (server.ts:2085-2096, `hasVision: false`). mlx-lm's gate for
comparison (server.py:371-374, 685-686): `draft_model is None AND all caches
hasattr 'merge' AND args.seed is None`. **We have no cache-capability check**
— see debt D1.

### 1.3 Which caches support which dynamic-B ops

| Cache | merge | filter | extend | extract | batched mask | verified vs |
| --- | --- | --- | --- | --- | --- | --- |
| `KVCache` (full attn) | ✅ `mergeKVRows` (batched-mask.ts:171) | ✅ `filterKVRows` (:196) | ❌ (join = re-merge) | ✅ implicit (per-row slice in `#admit`) | ✅ `BatchedDecodeMaskCache` wrapper | mlx-lm `BatchKVCache` dynamic golden (gated) |
| `RotatingKVCache` (sliding) | ✅ `BatchedRotatingCache.merge` (batched-rotating.ts:273) | ✅ `.filter` (:233) | ❌ | ✅ `.temporalView` (:207) | ✅ built-in `makeMask` incl. ring-roll | mlx-lm `BatchRotatingKVCache` model-free golden (FAST, incl. ring-wrap) |
| `SSMCache` (Qwen3.5 gated-DeltaNet, qwen3-delta.ts:184) | ❌ | ❌ | ❌ | ❌ (no `temporalView`) | ❌ (`makeMask` returns empty; comment says "B=1 single-stream") | — |
| `QuantizedKVCache` / rotating-quant | n/a — excluded by the `kvQuant` gate (bf16-only v1) | | | | | no oracle exists (L2/L3, item f) |

**⇒ D1 (bug): a Qwen3.5 server with `--batch N` errors every batched
request.** The scheduler's constructor classifies `SSMCache` as `"full"`
(batch-scheduler.ts:105, `instanceof RotatingKVCache ? "rot" : "full"`), then
`#admit` casts it to `KVCache` and calls `temporalView()`
(batch-scheduler.ts:200-201) → TypeError; `#drive` catches and rejects the row,
so **every** batched request 500s. `willBatch` has no family/capability gate
(only DiffusionGemma is excluded). And **server-config.md:151-153 claims the
opposite** ("full-attention (CPM), sliding-window (Gemma), and hybrid
gated-DeltaNet (Qwen3.5) — all batch"). The doc claim is false today. Note an
oracle for the real fix exists: mlx-lm's `ArraysCache` implements
`filter/extend/extract/finalize/merge` (cache.py:632-702), which is how mlx-lm
batches Mamba-family state.

### 1.4 Test coverage matrix

| Behavior | Test | Tier | Gate quality |
| --- | --- | --- | --- |
| decode mask math (`buildBatchedDecodeMask`), `mergeKVRows`/`filterKVRows` pure | `tests/batched-decode-mask.test.ts` | FAST (no model) | unit, exact |
| rotating merge/decode/mask/filter incl. **ring-wrap** | `tests/batched-rotating.test.ts` | FAST (fixture) | **oracle-gated** — replays `scripts/gen-rotating-golden.py` vs mlx-lm `BatchRotatingKVCache`, per-step mask + keys |
| batched prefill+decode forward, 4 models | `tests/batched-decode-parity.test.ts` | GATED `MLX_BUN_TEST_BATCH_DECODE=1` + weights | **oracle-gated** — bit-exact vs mlx-lm B=2 goldens (`scripts/gen-batched-golden.py`) |
| dynamic-B join/leave ({A,B}→+C→−A) | same file, CPM | GATED | **oracle-gated** — token-for-token vs `scripts/gen-batched-dynamic-golden.py` (mlx-lm merge/extract/filter) |
| scheduler orchestration (admit/step/evict/join) | `tests/batch-scheduler.test.ts` | GATED | **KL-gated** teacher-forced (tol 1e-2) CPM; Gemma 12B greedy vs mlx-lm B=2 golden |
| server wiring: Option-B engage, `/stats`, concurrent completion, SSE fan-out, serial-lane coexist (user-seed drain, no deadlock) | `tests/batch-serving.test.ts` | GATED (live in-process server) | **smoke** — coherence assertions, no numeric oracle |
| prefill batched mask (training side) | `tests/train-batch{,-e2e}.test.ts` | FAST / gated | oracle (per-row loss == solo) |

**Not tested anywhere:** row-failure containment (one row's error vs the
batch), serial-lane starvation/fairness under sustained batchable load,
KV admission (doesn't exist), batched Qwen3.5 (would fail, §1.3),
ring-wrap **end-to-end** on a real Gemma forward (model-free math is gated;
the long-context forward golden is the known open L1 follow-up),
batched-lane usage-timing stats (currently hardwired zeros).

### 1.5 What the flags/docs currently say (accurate except one claim)

`--batch <n>` (cli.ts:750-757; `--decode-concurrency` accepted as alias),
`--kv-quant` interplay (Option B: unset+batch ⇒ bf16; explicit ⇒ those requests
serial, warned at server.ts:1065-1070), `/stats.batch`
{configured, batched, active_rows} (server.ts:1437-1441). server-config.md's
"Execution modes", lane-picker table, compatibility matrix, compat-mode
rationale, and known-limitations list are **verified accurate against code**
— except the Qwen3.5 batching claim (D1) and it doesn't mention the curve/
signal endpoints' lock bypass (D3, which is a bug to fix, not to document).

---

## 2. Code-quality assessment

**Verdict:** the *primitives* are excellent — oracle-gated, well-commented,
disposal-disciplined (`batched-mask.ts`, `batched-rotating.ts` are among the
cleanest files in the repo). The *orchestration* (`batch-scheduler.ts`,
~360 lines, readable) is correct-by-gate but **naive as an engine**: it has
none of the serial loop's hard-won loop hygiene, its failure domain is the
whole batch, and the server grew a second mutual-exclusion domain that two
endpoints silently don't participate in. Specific debt, ranked:

- **D1 — Qwen3.5 batched = guaranteed request failure + false doc claim.**
  batch-scheduler.ts:105 + :200-201 vs qwen3-delta.ts:184 (`SSMCache`, no
  `temporalView`); server-config.md:151-153. Fix now: a cache-capability gate
  (mirror mlx-lm server.py:371-374) in `willBatch` — batchable iff every
  `makeCache()` element is `KVCache | RotatingKVCache` — plus the doc
  correction. The real SSM batch path is item (h), later. *(confidence 95)*

- **D2 — `#admit` materializes full-prompt logits.**
  batch-scheduler.ts:173-174 runs `logitsFromHidden(h)` on the **whole**
  `[1,Lp,H]` hidden, then slices the last position. The lm_head matmul
  computes `[1,Lp,V]` at eval — at Gemma's V=262k and an 8k prompt that is a
  ~4.3 GB bf16 transient *per admit* (plus the wasted GEMM). The serial path
  slices `hLast` FIRST (generate.ts:466-468) precisely to avoid this. One-line
  reorder + the gated suites re-run. *(confidence 95)*

- **D3 — two mutual-exclusion domains; curve `/generate` and `/signal` bypass
  the gateway.** The old serialized queue (`enqueue`, server.ts:946-951) used
  to be THE GPU lock; generation moved to the gateway's `AsyncMutex`, but
  `/generate` (curve designer, server.ts:1663 — `enqueue(() =>
  runGeneration(...))`) and `/signal` (server.ts:1608 — `enqueue` + raw
  `model.forward`) still run GPU work (and `PromptCache.take/put`) under
  `enqueue` only ⇒ they can run **concurrently with batched decode steps**
  (GPU contention + the prompt-cache "single owner" invariant from
  parallel-slots.md broken). Adapter mount/unmount (server.ts:1578, 1589) sit
  on `enqueue` too — mount is registry-level, but unmount disposing adapter
  arrays concurrently with a serial-lane generation using them is the same
  class of race. The `runGeneration` doc comment "Must be called inside the
  queue" (server.ts:960) is stale. Fix: one lock — expose
  `gateway.runExclusive(fn)` and route curve/signal/adapter-unmount through
  it; fix the comment. *(confidence 90 on curve//signal; 80 on unmount)*

- **D4 — the batched loop lacks the serial loop's pipelining + clearCache
  cadence** (= reports/kernel-perf-review-2026-07-01.json backlog #6, area 7
  verdict). Three sub-items, all in `#step`/`#admit`:
  1. **No `asyncEval` pipelining**: `#step` builds one step's graph then
     synchronously reads all B tokens (`toFloat32`, batch-scheduler.ts:286)
     — every step eats a full dispatch+readback bubble. Serial overlaps step
     n's readback with step n+1's compute (generate.ts:482, 539); mlx-lm's
     `GenerationBatch._step` does exactly this batched (`mx.async_eval`
     next, `mx.eval` current — generate.py:1367-1373).
  2. **`clearCache()` EVERY step** (batch-scheduler.ts:293) — trashes the
     buffer pool each token, so every step re-allocates its transients.
     Serial clears every 256 tokens (generate.ts:571); mlx-lm batched every
     512 steps (generate.py:1778-1779).
  3. **No prefill chunking in `#admit`** — the whole prompt goes through one
     forward (batch-scheduler.ts:172), so a long prompt is an unbounded
     transient (serial chunks at `prefillChunkSize` with per-chunk eval +
     clearCache, generate.ts:440-456; mlx-lm at `prefill_step_size=2048`).
     Worse, admits run to completion before the next `#step`, so **every
     running row stalls for the entire prefill of every joiner**
     (head-of-line blocking; mlx-lm interleaves one decode step with one
     prefill chunk per loop iteration — generate.py:1760-1844).
  *(confidence 90; perf claims need bench numbers per house rules)*

- **D5 — whole-batch failure domain.** Any throw in `#step` — including a
  row's own `onToken` (awaited inline, batch-scheduler.ts:299; an SSE
  controller error qualifies) — is caught in `#drive` (:153-158) and
  **rejects every row and drops the entire batch KV**. mlx-lm removes the
  offending uid and keeps the batch (server.py:913-919). Also: `#admit` has
  no try/finally around the prefill, so `solo` caches + `ids` leak if the
  forward throws (:170-173); onToken should be wrapped per-row so one
  consumer's exception evicts one row. *(confidence 90)*

- **D6 — serial-lane starvation under sustained batchable load.** The
  scheduler holds the mutex while `running ∪ pending ≠ ∅` and **keeps
  admitting** new batchable arrivals (batch-scheduler.ts:135-145); a queued
  serial-lane request (vision, adapter, seed…) waits for the batch to empty,
  which under continuous traffic is *never*. mlx-lm's drain sets
  `drain_batch=True` and **stops admitting** until the incompatible request
  has run (server.py:826-830). Fix: gateway signals "serial waiter present" →
  scheduler pauses admission (finish running rows, release, FIFO mutex hands
  over, then resume). Single-user appliance softens this, but agent fan-out
  is exactly the batching use case, so it's real. *(confidence 85)*

- **D7 — zeroed stats + duplicated request-shape/sampling logic.**
  - Batched stats hardwire `prefillMs/decodeMs/…Tps = 0`
    (generation-gateway.ts:170) → SSE `usage` timing and any logging report
    zeros for batched requests; `cachedTokens` 0 is documented, the timings
    are just missing accounting.
  - `RequestShape` construction duplicated chat vs completions
    (server.ts:1813 vs 2085) — extract one `shapeFor()` helper.
  - `maxTokens` fallback drift: gateway `?? 512` (generation-gateway.ts:160),
    chat finish `?? 1024` (server.ts:1904), completions finish `?? 512`
    (server.ts:2098) — all dead in practice (server defaults 65_536 at
    :1116) but a trap for library callers; unify.
  - The `#emit` EOS/length/onToken contract mirrors `generate()` by comment
    only (batch-scheduler.ts:306-316) — drift risk; a shared contract test
    (same fixture through both lanes) would pin it.
  - Full-layer `filter` keeps stale left-padding (no `min_left_pad`
    shift-left, cf. cache.py:1027-1033) — width waste, not correctness.

None of this contradicts the gates that exist: the numerics ARE oracle-proven.
The debt is engine mechanics, failure domains, and the second lock.

---

## 3. Gap plan (implementation-ready, per item)

### (a) `extend` join op — stop re-merging the running batch

**Port target:** mlx-lm `BatchKVCache.extend` (cache.py:1035-1078) and
`BatchRotatingKVCache.extend` (cache.py:1369-1416). Semantics: right-justify
both caches to a common `_idx`/width (one `mx.pad` each), concat on B, sum
left-padding adjustments. One pad+concat per layer per join, vs today's
per-row slice storm + full rebuild.

**Design:** introduce **`BatchedKVCache`** (new file or in batched-mask.ts) —
the full-attention twin of `BatchedRotatingCache`: owns
`keys/values/leftPad/offset`, methods `merge` (subsumes `mergeKVRows`),
`filter` (subsumes `filterKVRows` + adds the min-left-pad shift),
**`extend`**, `extract(row)` (the per-row slice `#admit` currently inlines),
`makeMask` + `ropeOffsetArr` (subsumes the per-step `BatchedDecodeMaskCache`
wrapper rebuild and the scheduler's shared `#fullLeftPad` field —
batch-scheduler.ts:93, a state smell). `BatchedRotatingCache.extend` follows
the same pad-to-common-idx recipe in temporal order (both sides are kept
temporal by our merge, so no dynamic-roll needed for the N=1-update scope —
verify against the golden, don't assume). Scheduler `#admit` becomes:
solo-prefill → `inners[layer].extend(soloRow)` — no re-merge, no wrapper churn.
**Does not touch gemma4-base.ts** (in-flight ownership).

**Oracle:** extend `scripts/gen-batched-dynamic-golden.py` to drive the join
through mlx-lm's real `extend` (it already drives merge/extract/filter);
assert the same {A,B}→+C→−A per-row trajectories token-for-token, CPM L1 +
a Gemma variant for the rotating extend. Existing gated suites must stay
green unchanged (numerically `extend ≡ re-merge`; the golden proves it).

**Effort: M.**

### (b) Prompt-cache reuse under batching

**mlx-lm behavior (the model to follow):** on insert,
`prompt_cache.fetch_nearest_cache` → pass the pre-warmed per-sequence cache
into the batch (server.py:751-767); on row finish, extract the row's cache and
`insert_cache` it back keyed by all tokens (server.py:900-907).

**Design (parallel-slots.md's sole-owner rule, kept):** all `PromptCache`
take/put happen **inside the scheduler loop** (plus the serial lane, which
already does — the two are mutex-exclusive, and D3's fix closes the remaining
holes).
- `#admit`: `promptCache.take(promptIds, "")` (batched lane is always
  adapter-less, so namespace ""); on hit, the entry's caches ARE the solo
  caches — forward only the uncached tail (the trim/`cachedTokens` logic
  exists in generate.ts; lift the prefix-trim helper rather than reimplement —
  memory: eval-reuse-serving-prompt-path). `BatchStats.cachedTokens` becomes
  real.
- Row finish (`#finish`) or eviction: `extract(row)` (from item a) →
  `restoreState` into fresh solo `KVCache`/`RotatingKVCache`s →
  `promptCache.put(rowTokens, caches, "")`. Cost: O(S_row) copy per finished
  row, off the step hot path (do it after `#applyFilter`).
- Byte interplay with (c): mirror mlx-lm's
  `prompt_cache.trim_to(total − activeBatchBytes)` (server.py:795-799) so the
  LRU + live batch share one ceiling.

**Gate:** batch-serving test asserting `cached_tokens > 0` on an identical
repeat under `--batch 2`; parity assertion that a warm-start row's trajectory
equals the cold row's (same-B, bit-exact — prefix KV is identical by
construction); serial suite untouched.

**Effort: M–L** (the prefix-trim + rotating-cache restore corners are where
the time goes; RotatingKVCache entries past the window are non-trimmable —
mirror the serial path's existing handling).

### (c) KV-budget admission (B×S_max) + `--prompt-concurrency`

**Fact-check first:** mlx-lm does NOT byte-budget admission — it caps counts
(`--decode-concurrency` 32, `--prompt-concurrency` 8), optionally swaps KVCache
→ RotatingKVCache via `max_kv_size`, and byte-trims only the *prompt cache*
against `--prompt-cache-bytes` minus live batch bytes. So byte-budget admission
is OUR addition (rung 2 of parallel-slots.md), consistent with the byte-capped
`PromptCache` precedent and the existing `fit()` admission (server.ts:1012).

**Design:**
- Projected row bytes = Σ_layers 2·bytes_bf16(H_kv·D·S_cap) where
  S_cap = min(promptLen+maxTokens, window) for rotating layers and
  promptLen+maxTokens for full layers (a `projectKvBytes(model, promptLen,
  maxTokens)` helper next to `fit()`, which already knows per-layer shapes).
- Budget = explicit `--kv-budget <GB>` else derived: `fit()`'s usable bytes −
  weights − prompt-cache cap − headroom. Admission: admit while
  Σ projected(running+candidate) ≤ budget; otherwise leave in `#pending`
  (FIFO — no reordering, keeps fairness and determinism of arrival order).
  `maxTokens` default 65_536 makes naive projection admit ~1 row — so
  projection uses a decode-allowance term (e.g. min(maxTokens, 4096) beyond
  prompt) with the true backstop being re-check-on-growth: on each STEP-chunk
  cache growth, re-evaluate; if over budget, stop admitting (never evict a
  running row). Document the estimate honestly.
- **`--prompt-concurrency`: accept for drop-in** (we already accept
  `--decode-concurrency`), mapped to "max joiners admitted per loop
  iteration" — which becomes meaningful exactly when (d)'s interleaved
  chunked admit lands. Until then accept + warn like `--decode-concurrency`'s
  semantic note in cli.ts:744-748. `/stats.batch` grows
  `{pending_rows, kv_bytes, kv_budget_bytes}`.

**Gate:** unit tests on the projection math (pure); a gated live test that
M oversized requests are admitted ≤ budget-implied width and all complete
(queueing, not OOM). Perf numbers only via bench-serving-load on a clean
machine (Josh-gated).

**Effort: M.**

### (d) Pipelining + clearCache cadence + chunked/interleaved admit
(the backlog-#6 transplant — pairs with fixing D2, D4)

1. **Slice-before-head in `#admit`** (D2): `hLast = h.slice(last)` →
   `logitsFromHidden(hLast)`. One-line; do first.
2. **Chunked prefill in `#admit`**: loop `prefillChunkSize` (reuse the serial
   constant) with `evalAll(cache.state)` + `clearCache()` per chunk
   (generate.ts:440-456 pattern).
3. **Interleave admit with steps**: `#drive` admits at most one prefill
   *chunk* (per joiner, up to `--prompt-concurrency` joiners) between decode
   steps instead of running each admit to completion — bounds running-row
   stall to one chunk. (This restructures `#admit` into a resumable
   per-joiner state; mlx-lm's `_currently_processing` is the reference,
   generate.py:1760-1844.)
4. **Pipelined decode**: mirror mlx-lm's `GenerationBatch._step`
   (generate.py:1320-1373): keep step n's sampled `[B]` token array on
   device, `asyncEvalAll` it, build step n+1's graph from the **unread**
   array, then read step n. Eviction moves after the read: rows evicted at
   step n have already contributed a step-n+1 KV write — harmless, `filter`
   drops the row (mlx-lm does exactly this). EOS rows' extra write is also
   how mlx-lm behaves, so parity holds by construction.
5. **clearCache cadence**: every 256 steps (serial's constant; mlx-lm uses
   512 — either is defensible, pick 256 for house consistency and comment
   the divergence).

**Gate:** numerics unchanged ⇒ the teacher-forced KL suite and the mlx-lm
goldens must pass **unchanged** (pipelining is scheduling, not math);
batch-serving smoke; A/B throughput via `scripts/bench-serving-load.ts`
(quotable numbers clean-machine only).

**Effort: M** (item 3 is the bulk; 1/2/5 are S alone).

### (e) Gate widening — which serial-only features can batch safely

Ranked by value/risk. Each needs per-row state listed; each lands with its own
oracle before the `willBatch`/`hasLogitsExtras` split changes.

1. **min_p + XTC — S, low risk, do first.** Pure per-row *samplers*; the
   batched lane already builds a per-request sampler closure
   (generation-gateway.ts:150-156 → `makeSampler(options)`), which already
   implements min_p/XTC for serial. Per-row state: none beyond the closure
   (XTC needs `xtcSpecialTokens`, already in options). Change: move
   `minP`/`xtc*` out of `hasLogitsExtras` into the batchable set. Gate:
   teacher-forced determinism (same seed ⇒ same tokens, batched == serial,
   per row — sampling happens on the `[1,V]` row slice so it's the SAME code
   path); note the seed-collision fix must land first for two same-ms hot
   rows to be meaningfully independent (in flight).
2. **logprobs / top_logprobs — M, low-medium risk.** Non-stream only
   (server.ts:1797-1805 keeps streams capture-free). The scheduler's sampler
   already computes `toLogprobs` per row; extend `RowSampler` to optionally
   return extras (the serial `sampleStep` extras shape, generate.ts) and have
   `#emit` pass them to `onToken` — the handler's `LogprobsCollector` then
   works unchanged. Per-row state: none (readback per emitted token, rows
   that asked for it only). mlx-lm computes logprobs for every batched row
   natively, so behavior-parity is clean.
3. **penalties (repetition/presence/frequency) + logit_bias — M, medium
   risk.** Needs per-row token history + per-row logits processors applied to
   the `[1,V]` slice before sampling — exactly mlx-lm's per-row
   `logits_processors` loop (generate.py:1338-1349, TokenBuffer). We have the
   processors (sampler.ts, serial); per-row state: a bounded history array
   (context sizes 20 by default) per row, filtered on eviction. logit_bias is
   stateless (easiest of the family) — could ship with tier 1 if the family
   gate is split per-feature. Gate: teacher-forced vs serial with identical
   forced trajectories (processors are deterministic given history).
4. **LoRA same-adapter-set batching — L, defer.** Design already decided
   (group-by-adapter + drain, parallel-slots.md Fallbacks); needs adapter-set
   as a batch-compatibility KEY in the scheduler, not just a boolean gate.
   Not before (a)–(d).

Never batch: vision (offset-0 bidirectional prefill), user seed
(reproducibility ⇒ solo — matches mlx-lm), explicit kv-quant (item f),
DiffusionGemma (non-AR).

### (f) Quantized-KV batched — L3 novel extension (design sketch ONLY, deferred)

No ancestor does it (mlx-lm's `to_quantized` raises on batch caches; optiq
doesn't batch) ⇒ no bit-exact oracle, per the three-level fidelity tree this
is KL + 6-task + benchmark gated. Sketch: `BatchedQuantizedKVCache` mirroring
(a)'s `BatchedKVCache` over (packed, scales, biases) triples — merge/filter/
extend are the same B-axis surgery per component; attention falls to
`quantizedSdpaUnfused` with the `[B,1,N,S]` bool mask (the fused decode kernel
requires `mask.mode===""` and the tiled path 2-D causal — both disqualified,
known perf debt from the modes analysis). Value: memory-density (4-bit KV ×
batching compound, ~4× rows per GB) on the 24 GB machine. **Do not start**
until (a)–(d) are landed and a concrete density need exists; then it begins
with a KL harness (batched-quant vs batched-bf16 at same B), never a
trajectory diff.

### (g) Docs + flags

- **server-config.md**: fix the Qwen3.5 batching claim (D1) — with the
  capability gate landed the honest row is "hybrid-cache models (Qwen3.5)
  route to the serial lane; batched SSM is a later port (mlx-lm ArraysCache
  is the oracle)". Update the known-limitations list as (a)–(e) land (each
  item literally deletes a numbered limitation: #1 prompt cache, #2
  admission, #5 extend). Add `--kv-budget`, `--prompt-concurrency`,
  `/stats.batch.{pending_rows,kv_bytes}` when they exist. Add one line
  documenting the auto-batch rejection ("mode, not load-fallback —
  determinism", the standing decision).
- **parallel-slots.md**: refresh the STATUS block (S2 admission half, extend,
  prompt-cache reuse) to point HERE for the v2 execution plan; it remains the
  primitive-design record.
- **`--batch` stays the UX.** No smarter default. `--decode-concurrency`
  alias kept; `--prompt-concurrency` accepted per (c). No new mode flags.
- **STATUS.md / PLAN.md Phase 18**: check off items as they land (house
  rule: write conclusions down).

### (h) (surfaced by this audit, not in the original list) SSM batched path

Port mlx-lm's ArraysCache batch ops for `SSMCache` (conv/recurrent state are
`[B,…]` tensors; merge/filter/extend are trivial B-axis concat/take — no
padding subtleties since there's no sequence axis; the mask is the harder bit:
Qwen3.5's linear layers need an `ssm_mask` under left-padding). Oracle exists
(mlx-lm batches these models). Schedule after (a); until then the capability
gate (D1 fix) keeps Qwen servers correct-but-serial.

---

## 4. Sequencing

Order minimizes risk (correctness first, then the engine, then features),
respects in-flight work (seed fix in flight — untouched; gemma4-base.ts owned
elsewhere — all new cache code goes in new/batched-* files), and gives every
step a gate.

| # | Item | Effort | Test gate | Notes |
| --- | --- | --- | --- | --- |
| 1 | **Hotfix bundle**: D2 slice-before-head; D1 capability gate + server-config.md correction; D3 route curve/`/signal`(/adapter-unmount) through `gateway.runExclusive`; stale comment server.ts:960 | **S** | gated batch suites unchanged; fast suite; new unit: willBatch(Qwen)=false | no numerics change anywhere |
| 2 | **D5/D6 failure + fairness**: per-row onToken containment (evict row, keep batch); `#admit` try/finally; drain-on-serial-waiter | **S–M** | new gated test: throwing onToken evicts one row, siblings complete; drain test (serial completes under sustained batchable load) | mlx-lm `remove` semantics |
| 3 | **(d) engine hygiene**: chunked+interleaved admit, pipelined decode, clearCache cadence | **M** | KL suite + mlx-lm goldens UNCHANGED; bench-serving-load A/B (clean machine, Josh-gated for quotables) | closes perf-review backlog #6 |
| 4 | **(a) `BatchedKVCache` + `extend`** (full + rotating) | **M** | extended dynamic golden (mlx-lm `extend` driven); existing suites green | new files only — no gemma4-base.ts conflict |
| 5 | **(c) KV-budget admission + `--prompt-concurrency`** | **M** | projection unit tests; gated queueing test; `/stats` fields | depends on 3 (interleaved admit) for prompt-concurrency semantics |
| 6 | **(b) prompt-cache reuse under batching** | **M–L** | `cached_tokens>0` gated test; warm==cold row parity; serial suite | depends on 4 (`extract`) + 5 (byte interplay) |
| 7 | **(e) gate widening**: e1 min_p/XTC (S) → e2 logprobs (M) → e3 penalties/logit_bias (M) | **S+M+M** | per-feature: batched==serial teacher-forced/deterministic-seed tests | e1 waits for the seed fix to merge |
| 8 | **(h) SSM batched path** (Qwen3.5) | **M–L** | mlx-lm B=N golden for a Qwen3.5 model (ArraysCache oracle) | un-does the item-1 gate for Qwen; doc row flips back |
| 9 | **(g) docs pass** | **S** | doc-vs-code re-audit (this file's §1 as the checklist) | rolling — update per landing, final sweep here |
| 10 | **(f) quantized-KV batched** | **L** | KL + 6-task + density benchmark — design doc first | DEFERRED — needs a concrete density case |

D7's small items (shared `shapeFor()`, `maxTokens` fallback unification, real
batched timing stats, filter min-left-pad shift, shared emit-contract test)
slot into whichever of steps 2–4 touches the neighboring code; none justify a
standalone step.
