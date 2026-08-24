---
status: active
axis: ON
canonical-for: batching
plan-anchor: "Phase 18 — Concurrent / batched serving (slots) + parallel load benchmark `[~]` (2026-06-13)"
last-verified: 2026-08-23
---

# Batching — continuous scheduling for `--batch N`

The canonical design for concurrent serving: the scheduling seam
(`src/serve/generation-gateway.ts`), the continuous-batching engine
(`src/serve/batch-scheduler.ts`), the dynamic-B cache primitives
(`src/model/batched-*.ts`), admission, and the parity discipline that
gates all of it. Consolidates batching-perf-path.md, parallel-slots.md,
batching-v2-plan.md, the batching items of
grammar-spec-batching-integration.md, and the scheduler tie-in from
paged-kv-cache.md. Status and dated progress live in PLAN.md (see the
plan anchor above); this file describes the mechanism as it exists and
what is still open.

User-facing mirror: docs/reference/server-config.md ("Execution modes",
compatibility matrix, known limitations) and docs/reference/cli.md.

## 1. Why batch, and why continuous

Decode on Apple Silicon is bandwidth-bound: every token streams the whole
weight set through the GPU to produce one token. Batch B sequences and
the weights stream once for B tokens — aggregate tok/s scales roughly
linearly until the compute roofline.

The motivating workload is one person's agent harness: a coding agent
fans out sub-agents against one local server. Serially, the Nth agent's
first token waits for N−1 full generations. Batched, 4–8 agents decode
together — each stream somewhat slower, nobody queued. "Single-user" in
this project means single user, many agents. Consequences that shape the
design: arrivals are uncoordinated (so scheduling is concurrency-driven),
sub-agents share long system prompts (so prefix reuse on the batch lane
matters), and agent fleets want long contexts (so quantized KV must
compose with batching).

The scheduler is **continuous** (iteration-level), never static: it
works per decode step, admitting a newly arrived request after a short
prefill and retiring finished rows between steps. A late request joins at
the next step instead of waiting for the in-flight batch to finish. By
Little's law requests overlap even at modest rates because generations
last seconds. When traffic never overlaps there is only ever one live row
and the engine runs its B=1 fast path (§4.4).

## 2. Decisions and rationale

- **Concurrency IS the batch size.** `--batch N` is a concurrency cap
  (mlx-lm's `--decode-concurrency` twin, accepted as an alias), not a
  mode switch. Placement declares a *mechanism* per request; the
  scheduler picks B=1 or B=N from its live row count. Default cap is 8
  (`server.ts`: `serverOptions.batch ?? 8`), flipped from 1 on
  2026-07-05 once a lone scheduler request measured within 0.992–0.996
  of the strict serial decode (paired A/B, byte-identical output). The
  earlier "mode switch, auto-batching rejected for determinism" decision
  was reversed with an answer to its objection: mlx_lm.server itself
  batches by arrival, so drop-in parity *requires* it, and anyone who
  needs arrival-independent numerics pins `--batch 1`.
- **`--batch 1` is the determinism pin.** It runs the strict serialized
  single-queue path; a request's bits never depend on what else was in
  flight. Use it for golden regeneration.
- **bf16 batching IS the mlx-lm-parity contract.** mlx-lm's batched
  path is bf16 (`BatchRotatingKVCache.to_quantized` raises), so the
  oracle for a batched row is **mlx-lm's own batch mode at the same B**,
  bit-exact — never our own B=1 (batching changes the attention
  kernel's reduction order, so B=N vs B=1 measures the wrong thing).
  KV-quant unset ⇒ bf16 on both lanes.
- **Compositions inherit the scheme's oracle.** Batched per-layer
  quantized KV (`--kv-quant config`) has no mlx-lm oracle; each row is
  gated against the *serial* composition of the same scheme (unpadded
  rows bit-exact / KL 0; padded rows within a calibrated bf16
  reduction-order envelope). Lab-style KL/eval gates are for no-oracle
  schemes only, never a substitute for an oracle that exists.
- **Compat mode: no parity-breaking levers on the batched step.** The
  scheduler drives `forwardHidden`/`logitsFromHidden` directly. Only
  bit-exact machinery engages: compiled decode at B=1 on adopted
  serial-class caches (same kill switch as serial), the compiled
  activations, the pipelined readback. `--fused-sdpa` and `--force-wire`
  never reach the batched lane.
- **Never downgrade a composition to make it batchable.** Placement is a
  support check only: it does not strip MTP/drafting, KV schemes,
  TurboQuant, grammar, adapters, or sampling. A composition the scheduler
  does not implement runs unchanged on the serial mechanism.
- **Drain, never starve.** A serial-lane waiter pauses admission; running
  rows finish; the lock hands over FIFO; admission resumes (mlx-lm
  `drain_batch`). One `AsyncMutex` is the single exclusion domain for
  the GPU and shared model state (`loraState`): serial generation, the
  scheduler's whole active period, curve `/generate` + `/signal`, and
  adapter mount/unmount all go through it.
- **Byte-budget admission is ours, not mlx-lm's.** mlx-lm caps counts
  only; we project bytes (`--kv-budget`) because GPU OOM is uncatchable.
  Budget accounting is total bytes, mirroring the byte-capped
  `PromptCache` precedent. Queue-don't-OOM; never evict a running row.
- **Solo prefill, then join.** Joiners prefill alone (chunked,
  interleaved with decode steps) and merge/extend into the running
  batch. This is why SSM state needs no `ssm_mask` under left-padding:
  state never sees a pad token, and the token-exact match vs mlx-lm's
  masked-pad prefill proves the equivalence.
- **oMLX-style burst decode is refuted here.** Their `_step_burst` runs
  K steps per event-loop hand-off to dodge Python's per-token GIL
  ping-pong (~1 ms/token). Ported faithfully and measured 2026-07-02
  (M1 Max 32 GB): cpm5 B=4 aggregate 345→289 tok/s, batch-lane B=1
  149→121, TTFT +~100 ms (SSE flushes wait out the budget). Bun's
  `setImmediate` hop costs microseconds; there is nothing to dodge.
  Reverted; the per-yield step is the measured optimum. Don't re-add
  without new evidence.
- **Spec decode and batching are different mechanisms.** A mounted
  `--draft-model` routes every request serial (upstream
  `is_batchable = draft is None`); per-row speculation inside the batch
  is a research question, not a feature gap.

## 3. Scheduling seam — `GenerationGateway`

`place(shape)` freezes one `GenerationPlacement { shape, mechanism }`
with `mechanism ∈ {"serial", "continuous"}`; `run()` rejects a placement
made for another shape. The predicate, exactly as implemented
(`#supportsContinuous`):

```
continuous  iff
  model is not DiffusionGemmaModel           (non-autoregressive)
  AND batch > 1
  AND #modelCachesBatchable()                (cache-capability gate, below)
  AND !hasVision                             (offset-0 prefill + bidirectional mask)
  AND !hasAdapters                           (loraState is one global field)
  AND !wantsLogprobs                         (batch sampler does not capture logprob arrays)
  AND !userSeed                              (reproducibility ⇒ solo, matches mlx-lm)
  AND !(kvQuant AND !#kvBatchable())         (scheme must be a batchable per-layer config)
  AND !turboQuant                            (solo-only v1; belt on top of the capability braces)
  AND !hasDraft                              (spec is a B=1 mode)
  AND !(hasGrammar AND MLX_BUN_GRAMMAR_BATCH=0)
```

`hasRepetitionPenalty` and `hasLogitsExtras` (min_p, XTC, logit_bias,
presence/frequency) are carried on `RequestShape` for stats only — they
do **not** gate. The load-bearing reason: Qwen3.5 ships a default
repetition penalty in `generation_config.json`, which once routed every
request serial. Per-row `StepSampler`s fold the processors over a per-row
device-side token history, so all of these batch.

**Cache-capability gate** (`#modelCachesBatchable`, mirrors mlx-lm
server.py's all-caches-have-`merge` check), memoized from a fresh
`makeCache()`:
- `UniversalDenseModel`: batchable iff `!maskArray` and no
  `sliding_attention` layer type — plain full-attention Tier-0 archs
  (Llama) only; gemma2-family (pad-blind causal mask in `forwardLayers`)
  and sliding-window universal archs are unvalidated cells → serial.
- Otherwise every cache must be `KVCache`, `RotatingKVCache`, a
  `BatchableCache` implementer (GLM-5.2's `MLACache`, which owns its own
  merge/extract/filter and byte projection), or `SSMCache` (Qwen3.5's
  gated-DeltaNet state; `MLX_BUN_BATCH_SSM=0` removes it → serial).

**KV-scheme gate** (`#kvBatchable`): the server's resolved `KvScheme`
batches iff `kind === "affine-config"` and `scheme.batchable()` holds
with every configured layer a plain `KVCache` or plain `RotatingKVCache`.
Uniform `--kv-quant 4|8` (quantizedKvStart threshold semantics) and
`turbo` route serial with a startup warning. The scheme is threaded to
the scheduler only when this passes; the scheduler re-checks at
construction and throws on an unsupported scheme (never bf16 service
with quantized accounting).

Startup refusals (server.ts): `--paged-kv` with `--batch N>1` throws
(paged caches can't merge); GLM `--mtp on` (its default) mounts the MTP
drafter and therefore routes serial+spec — `--mtp off` exposes ordinary
GLM batching.

**Lanes and the lock.** Serial requests run under `runExclusive`, which
counts itself as a serial waiter; the scheduler's `admissionHeld()` reads
that count. The serial branch also wraps `onToken` in a ≥25 ms
rate-limited macrotask hop: serial decode is an unbroken microtask chain
and without the hop `/stats`, `/health`, and accepts stall for the whole
generation (measured 2.5 s on a 512-token cpm5 run, 2026-07-02; after:
10–44 ms). The batch lane needs none — its drive loop yields per step.

`/stats.batch` exposes `{configured, mode, batched, active_rows,
pending_rows, submitted_rows, kv_bytes, kv_budget_bytes}`; `mode` is
`off | serial | batch` (cap ≤1 / model not batchable / batchable).
`MLX_BUN_LANE_DEBUG=1` logs each placement with its shape.

## 4. The engine — `BatchScheduler`

One detached Bun-async driver loop (no threads) owns one running batch.
Per iteration: purge aborted pending rows → decide `hasWork` (running
rows, an in-flight prefill — finished even under drain — or admissible
pending) → sleep on `#wake` when idle, releasing the lock and the wired
limit → otherwise acquire both, start/advance at most one joiner prefill,
burst-admit further queued rows that fit before the next step, run one
decode step, yield.

### 4.1 Admission

FIFO from `#pending`, head-of-line, never reordered. A joiner starts iff
no prefill is in flight, admission isn't held, `running < maxBatch`, and
`#kvAdmits` passes:
- context limit: `prompt + max_tokens > batchCacheMaxTokens` (GLM's
  compressed caches declare one) rejects with `RangeError`;
- no `--kv-budget` ⇒ admit;
- a row whose projected bytes exceed the budget *alone* (empty batch, no
  prefill) rejects with an actionable error — never deadlocks the queue;
- otherwise admit iff `projectedKvBytes + need ≤ budget`, else wait.

Projection is worst-case: `batchRowKvBytes(config, prompt, max_tokens,
scheme)` = the scheme's `bytesAt` (window-capped for rotating layers,
quantized bytes under a config scheme), or per-cache `projectedBytes()`
when every cache is a `BatchableCache`. `/stats.batch.kv_bytes` is the
running + mid-prefill sum.

### 4.2 Joiner prefill (chunked, interleaved, cache-aware)

- **Prompt-cache take at admission** (`RowPromptCache.take`): the solo
  prefill starts from the longest usable cached prefix (namespace `""`
  — adapter requests never reach this lane); `cachedTokens` is real.
  Serves are non-consuming zero-copy clones, so N agents sharing a
  system prompt reuse one prefill. The SSD tier lives inside `take()`,
  so restores reach batch joiners too.
- **Boundary snapshot**: for a cold-ish prefill ≥256 tokens, chunking
  splits exactly at `min(snapshotAt ?? len, len−1)` and a trim-free
  strict-prefix entry is cloned + put there — the same invariant as the
  serial lane's `snapshotAt`. Without it the lane's only entry was the
  untrimmable `[prompt+gen]` finish-time put, a total miss once rings
  wrap (12B batched ctx-repeat 84 s vs serial 0.4 s, 2026-07-06).
- **One chunk per loop iteration** (`prefillChunkSize`, default 2048 =
  the serial constant) with `evalAll(state)` + `#quantizeSolo` +
  `clearCache()` at every chunk boundary, one decode step between
  chunks. Running rows stall at most one chunk per joiner; the prefill
  transient stays bounded.
- **Oracle tail convention** (`MLX_BUN_PREFILL_TAIL_SPLIT`, default on):
  drain to `len−1`, then an L=1 forward of the last prompt token yields
  step-0 logits — mlx-lm's `insert_segments` + `GenerationBatch._step`
  shape, and what keeps `--batch 1 == unified == oracle` bit-exact.
- **Slice before the head**: the last hidden position is sliced before
  `logitsFromHidden` (a whole-prompt `[1,Lp,V]` would be ~4.3 GB bf16 at
  Gemma's V=262k and an 8k prompt).
- **Token 0 is sampled on the solo caches before merge**, so per-row
  serial equivalence holds by construction. A row that stops at token 0
  (EOS, stop sequence, 1-token grammar) never joins `#running`; its
  prompt-only caches go back to the prompt cache.
- **Mixed-precision conversion** (`#quantizeSolo`): the scheduler-side
  mirror of serial `maybeQuantizeKv` — same per-layer map, same skip
  rules, same chunk-boundary placement (`KVCache.toQuantized` /
  `RotatingKVCache.toQuantized`). That placement is what makes a row's
  quantized bytes bit-exact vs serial `--kv-quant config`.

### 4.3 Join: adopt, extend, or merge — by layer kind

`#kinds[layer] ∈ {full, rot, ssm, owned-batch}` from the prototype
caches. Before any merge the decode pipeline is flushed (read + emit) so
the row set is settled and the next step starts cold.

**Adopt-don't-copy.** A row joining an *empty* batch keeps its solo
caches as the inners (pointer handoff, zero bytes moved). The lone row's
caches stay serial-class (`KVCache` / `RotatingKVCache` /
`QuantizedKVCache` / `RotatingQuantizedKVCache`), which is what makes the
B=1 step literally the serial graph and lets compiled decode and
prompt-cache put/take apply to it.

When a second row joins, per layer:

| kind | running batch cache | join op | file |
| --- | --- | --- | --- |
| full (bf16) | `KVCache` `[B,H,S,D]` + shared `#fullLeftPad` | `extendKVRows` — one pad + one B-axis concat, running rows untouched, pads grow (mlx-lm `BatchKVCache.extend`); `MLX_BUN_BATCH_EXTEND=0` = `mergeKVRows` re-merge (per-row slices, pads re-normalized; O(B·S)) | `src/model/batched-mask.ts` |
| full (quantized) | `QuantizedKVCache` over (packed, scales, biases) | `extendQuantRows` / `mergeQuantRows` — the same surgery on all three triples | `src/model/batched-quant.ts` |
| rot (bf16) | `BatchedRotatingCache` (persistent; self-tracks per-row leftPad/offsetArr through ring wrap) | always re-merge: extract each running row's temporal view + the new row → `BatchedRotatingCache.merge(rows, offsets, maxSize)`; an adopted lone `RotatingKVCache` is the first row (pad 0) | `src/model/batched-rotating.ts` |
| rot (quantized) | `BatchedRotatingQuantCache` | same recipe over triples, `merge(rows, offsets, maxSize, groupSize, bits)` | `src/model/batched-rotating-quant.ts` |
| ssm | `SSMCache` `[B,…]` state, no temporal axis, no padding | `SSMCache.mergeRows(prev, solo)` — B-axis concat | `src/model/qwen3-delta.ts` |
| owned-batch | `BatchableCache` (GLM `MLACache`) | `solo.makeEmptyBatch().mergeRows([prev, solo])`; the cache owns leftPad/rowOffsets | `src/model/glm52-cache.ts` |

Routing among these branches is **by capability only** (`isRowBatchCache`,
`isBatchableCache`, `isQuantizedKvCache`, …). `BatchedRotatingCache` has
no `signature()` override, so any signature-based conjunct silently drops
the running batch from the merge — the 2026-08-22 agg×4 outage from
443f333 (joiners built a B<max ring; the next full-B step crashed in the
grow-path concatenate; whole-batch drop). `tests/batch-rotating-join.test.ts`
pins this.

After a real merge every row is marked `merged`: its KV is interleaved in
batched buffers and must be *extracted*, not adopted, at finish.

### 4.4 The decode step

Pipelined, mirroring mlx-lm `GenerationBatch._step`: (1) forward all rows
from the still-unread `[B]` token register (or, cold, from each row's
`current`), sample, `asyncEvalAll` the new register; (2) then read the
*previous* register with `toIntTokens()` (an eval + raw int read — never
`toFloat32()`, whose cast kernel queued behind the whole next step and
stalled every token), emit, evict. Rows that finish get one extra
harmless KV write from the already-built step; `filter` drops the row
(mlx-lm behaves identically). `MLX_BUN_BATCH_NO_PIPELINE=1` reads
synchronously (same math, slower).

**Unpadded fast path.** When every `#fullLeftPad` is 0 the full layers'
per-step `BatchedDecodeMaskCache` / `BatchedQuantDecodeMaskCache`
wrapper is skipped: `KVCache.makeMask(1)` is already the empty mask and
every row sits at the shared scalar offset, so the bare cache dispatches
the same per-step graph serial builds. The wrapper otherwise costs a
host mask build + ~8 device nodes per full layer per token. Rot,
owned-batch, and ssm caches always pass through unwrapped.

**Compiled decode at B=1.** With exactly one row, unpadded, a uint32
register, serial-class inners (`CompiledDecode.supports`; a
filtered-to-one batched rot-quant cache is excluded), and a Gemma4
dense model, the scheduler replays the serial engine's compiled step
(`MLX_BUN_COMPILED_DECODE` is the same kill switch). A failed step is
transactional: the scheduler permanently falls back to the graph path.

**Vectorized homogeneous sampling.** When every live row is plain greedy
(`plainGreedy` from the gateway: temperature 0, no processors, no
grammar), one `toLogprobs` + `argmaxAxis` over `[B,V]` replaces B
slice/sample/concat graphs — per-row identical math, tie behavior
included. `MLX_BUN_BATCH_VEC_SAMPLE=0` forces the per-row closure path.
Length-doomed rows get a placeholder slot (never emitted; one KV write
on their own about-to-evict row).

**Grammar rows** (`#stepGrammar`): read the previous register *before*
building the graph (the matcher's `accept` needs JS numbers), `accept()`
per live grammar row (fires async bitmask fills that overlap the graph
build), `await ready()`, sample per row with the mask applied in the
closure, emit the values already read. While any grammar row is live the
batch effectively runs unpipelined — bounded by the ~0.1 ms readback +
0.004–0.19 ms/row fills. Flushes must `accept()` the flushed tokens too,
or matchers run one token behind on every mid-decode join (found by the
conformance gate, 2026-07-03).

**Housekeeping.** `clearCache()` every 256 steps (serial's cadence;
mlx-lm batched uses 512), not per step. The per-step `setImmediate` hop
is rate-limited to 25 ms when exactly one row is running with an empty
queue and no drain — the 0.4–0.8% B=1 drive-loop tax, paired-measured
2026-07-05. `MLX_BUN_BATCH_STEP_TRACE=1` prints per-step build/read/
emit/gap timings.

### 4.5 Emit, evict, extract

`#emit` mirrors `generate()`: EOS terminates **without** an `onToken`
call; `onToken` returning `false` → `stop`; grammar terminated → `stop`
(the final token was delivered; never sample into an all-`-inf` mask);
`generated ≥ max_tokens` → `length`. Per-row `StopMatcher`, tool router,
and SSE fan-out live in each request's `onToken` closure.

**Failure containment.** A row's `onToken` throwing rejects and evicts
*that* row (mlx-lm `remove`); siblings continue. A forward/sampling error
cannot be attributed to a row: every row rejects and the batch KV is
dropped (`dropOnly`, never put). A prefill error rejects only the joiner.

**Eviction** (`#applyFilter(keep)`): `filterRows` on batched/owned
caches; `filterKVRows` / `filterQuantRows` (B-axis `takeAxis`) on full
layers; the pending register and `#pendingReal` flags are filtered in
lockstep. Full-layer filter keeps stale left padding (no `min_left_pad`
shift-left) — width waste, not correctness (open, §8).

**Finish-time prompt-cache put.** A lone never-merged row hands its
adopted serial-class caches back zero-copy, keyed by `promptIds + fed`
(`fed` = generated tokens whose KV actually entered the cache, per-row
exact via the register's real/placeholder flags; a placeholder that ever
fed taints the row and extraction refuses). A merged row with ≥256
prompt tokens is **extracted** per layer into fresh owned serial caches
before the filter mutates the batch (`#extractRowCaches`: `extractRow`,
`extractKVRow`, `extractQuantRow`; SSM only when the row's advance count
equals the key exactly — recurrent state is untrimmable), evaluated
asynchronously so the batched source buffers free once the copies land,
then put. Extract is a pure slice+copy of byte-preserved rows
(`tests/batched-extract.test.ts`), so an extracted row's bytes equal the
solo run's. All take/put happens inside the gateway's exclusion domain —
the scheduler is the sole owner of cache mutations on its lane.

## 5. The one hard numerics problem: per-sequence position

Rows are different lengths at different positions, but a cache has one
`offset`, RoPE takes one offset, and the mask is built from it. mlx-lm's
solution, and ours: **left-padding + per-row mask + per-row RoPE**.

- Right-align every row so "the current token" is one column → one
  advancing offset still works. Full layers share `#fullLeftPad`; rot
  caches self-track per-row `leftPad`/`offsetArr` across the ring wrap.
- Mask padding with a real `[B,1,1,S]` boolean mask (`j >= leftPad[b]`,
  `buildBatchedDecodeMask`) even at the N=1 decode step, and use the same
  fused bool-mask `scaled_dot_product_attention` mlx-lm uses. An additive
  mask would deviate.
- RoPE positions are a per-row array (`ropeOffsetArr`,
  `ops.ropeDynamic`; `UniversalRope.applyDynamic` for Tier-0 archs).
  Two traps every attention implementation must respect: capture the
  offset array **once** per forward (reading it before and after
  `updateAndFetch` gives K and Q different positions — the 2026-06-14
  Gemma fix; the generator `scripts/gen-model.ts` carries it for
  generated handlers), and a batched cache's `ropeOffsetArr` must be
  **stable within a step** and refreshed only in `releaseRopeArr` (the
  rope-array step-stability contract from milestone 2). MiniCPM5
  (2026-06-14) and universal dense (2026-07-03, latent since v0.0.9)
  each shipped a scalar-offset bug that only the batched oracle caught:
  every model family wires the per-row path separately.
- Batched prefill numerics differ from B=1 prefill (GEMV vs GEMM
  reduction order), and a padded row's attention sum accumulates in a
  different order than its solo run. The unpadded row is bit-exact vs
  solo; the padded row carries bounded bf16 noise (≤0.23 logit diff over
  8 steps, CPM, 2026-06-14). Calibrate the envelope per model; don't
  chase it — mlx-lm B=2 diverges from its own B=1 the same way.

## 6. KV memory model

Three rungs, in increasing fidelity of "who needs it most":

1. **Static per-slot partition** — rejected, never built (wastes memory,
   arbitrary per-slot context cap).
2. **Dynamic shared budget, contiguous padded caches** — what ships.
   Each layer holds one `[B,H,S,D]` buffer (growing in `KVCache.STEP`
   = 256 granules) whose width tracks the *longest* live row; short rows
   pay padding to that width. Admission is by projected total bytes
   (§4.1). Quantized KV multiplies the budget (~4× at 4-bit), and
   batching × quantized KV compounds.
3. **Paged KV** — the density upgrade. `PagedKVCache`/`BlockPool`
   (`src/model/paged-kv.ts`, `--paged-kv`) shipped as a serial-only,
   bf16, Gemma4 full-attention block manager, bit-exact vs the plain
   path. The batching payoff is **not built**: paged caches into the
   scheduler's `LayerInner` union, block-count admission replacing byte
   projection, `#mergeJoiner`/`#applyFilter`/`#extractAndPut` allocating
   and freeing blocks instead of pad+concat, then block-level CoW prefix
   sharing and a fused paged-attention kernel. That is where the
   padded-batch-waste win lives (a 50-token row cohabiting with a
   4000-token row pays ~4000 tokens of KV today).

The `--prompt-cache` budget is the *prefix* cache; live decode KV is a
separate pool. mlx-lm trims its prompt cache to `total − live batch
bytes`; sharing one ceiling between the LRU and the live batch is still
open (§8).

## 7. Verification

Oracle discipline: every batched mechanism lands with a token-for-token
gate against whoever ships the same protocol, generated from the oracle
venv (`scripts/oracle/gen-batched-golden.py` static B=N;
`gen-batched-dynamic-golden.py` merge/extract/filter join+leave;
`gen-batched-extend-golden.py` — extend's pad layout differs from
re-merge, so it has its own golden; `gen-rotating-golden.py`
`BatchRotatingKVCache` model-free incl. ring wrap). Goldens are
machine-layered (`goldens/*.json`, per-GPU overrides under
`goldens/<machine>/`). The B=N-vs-our-B=1 KL harness is an internal
consistency check only, never the gate.

| Behavior | Test | Tier |
| --- | --- | --- |
| rotating merge/decode/mask/filter incl. ring wrap vs mlx-lm; generic row-storage state | `tests/batched-rotating.test.ts`, `batched-rotating-state.test.ts` | fast, oracle |
| static B=2 + dynamic join/leave + extend-join vs mlx-lm (CPM, Gemma 12B/e4b/26B, Llama 3B Tier-0) | `tests/batched-decode-parity.test.ts` (`MLX_BUN_TEST_BATCH_DECODE=1`) | gated, oracle |
| Qwen3.5 SSM batched vs mlx-lm B=2 | `tests/qwen35-batched-parity.test.ts` | gated, oracle |
| scheduler orchestration (admit/step/evict/join) | `tests/batch-scheduler.test.ts` | gated (teacher-forced KL + 12B golden) |
| per-row containment, drain, full-attention join routing | `tests/batch-containment.test.ts` | gated |
| rotating-layer join mid-decode (2026-08-22 regression) | `tests/batch-rotating-join.test.ts` | gated |
| KV-budget queueing + projection math | `tests/batch-kv-budget.test.ts`, `kv-budget-projection.test.ts` | gated / fast |
| vectorized sampling bit-equal A/B | `tests/batch-vec-sample.test.ts` | gated |
| grammar under batching (mixed masks, 4 schemas at B=4, churn, joiner, truncation) | `tests/batch-grammar.test.ts` | gated |
| quantized dynamic-B ops; batched mixed-KV per row vs serial composition | `tests/batched-quant.test.ts`, `batched-rotating-quant.test.ts`, `batched-kv-quant-parity.test.ts` | fast / gated |
| per-row extract == solo bytes | `tests/batched-extract.test.ts` | fast |
| live server: engage, `/stats`, SSE fan-out, serial coexistence | `tests/batch-serving.test.ts` | gated smoke |

Benchmark harness: `scripts/bench-matrix.ts features` (six-cell
composition matrix over live SSE: TTFT p50/p95 at the first SSE token,
wall-clock aggregate tok/s, schema conformance as a hard gate);
`scripts/bench-serving-load.ts` is the client-only stack-vs-stack tool.
Quotable numbers come from a clean machine only; SSE bursts inflate
naive tok/s — use wall-clock.

## 8. Open items

- **`--prompt-concurrency`**: not accepted by the CLI (mlx-lm's cap on
  joiners per iteration; the drop-in alias slot). Today at most one
  joiner prefills at a time.
- **Rotating-layer `extend`**: Gemma joins extend their full layers but
  re-merge their sliding layers (`BatchedRotatingCache.merge` only).
- **Full-layer filter `min_left_pad` shift** after eviction (mlx-lm
  cache.py does it); width waste only.
- **Logprobs on the batch lane**: `wantsLogprobs` routes serial; the
  per-row sampler already computes `toLogprobs` — extend `RowSampler` to
  return extras and pass them through `onToken`.
- **Batched timing stats**: the gateway returns `prefillMs/decodeMs/
  *Tps = 0` for continuous rows; `usage` timing is missing there.
  `maxTokens ?? 512` fallback in the gateway differs from the server
  default (dead in practice, a trap for library callers).
- **LoRA-group batching**: adapter requests route serial. Design
  decided (adapter-set as the batch compatibility key; join if equal,
  drain if not; `loraState.active` set once per epoch); end state is
  per-slot adapter state in the batched step (vLLM/Punica is the oracle).
- **Prompt-cache byte interplay**: mirror mlx-lm's
  `trim_to(total − activeBatchBytes)` so the LRU and the live batch
  share one ceiling. Derived default for `--kv-budget` (usable − weights
  − prompt-cache cap − headroom) instead of unlimited-when-unset.
- **Long-context batched golden**: bf16 batched decode past the sliding
  window is oracle-gated model-free (`batched-rotating`), not yet as an
  end-to-end forward golden on a real Gemma.
- **Unvalidated model cells** stay serial by the capability gate:
  gemma2-family (`maskArray`) and sliding-window universal archs.
- **Paged KV batched integration** (§6 rung 3): block allocation in the
  scheduler, block-count admission, block CoW, fused paged kernel.
- **GLM per-row MTP**: `--mtp on` routes serial+spec; batched MTP is
  post-release.
- **Grammar jump-forward** (`MLX_BUN_GRAMMAR_JUMP`) is serial-only;
  `#stepGrammar` does not jump. Native XGrammar-2 via TVM-FFI has a
  B≫8 trigger.
- **Device-side step chaining (depth-k pipelining)**: serial-decode
  work, orthogonal to the scheduler; the matrix's serial baselines show
  its headroom.
- **Batch-invariant kernels** (identical numerics regardless of B): Lab
  research item; would restore determinism under load for free.
- **Per-row speculation inside the batch**: non-goal (variable accept
  lengths break uniform B); research question, not scheduled.
- **Stale source comments**: `batch-scheduler.ts` header still says
  joins re-merge (extend landed 2026-07-04); `generation-gateway.ts`
  header and server-config.md say merged rows are never re-put
  (`#extractAndPut` now extracts merged rows ≥256 prompt tokens).

## 9. Measured numbers (labels required)

- oMLX head-to-head, **M1 Max 32 GB, loaded machine, 2026-07-02**, 4
  concurrent × 128 tok, median of 3, wall-clock aggregate tok/s, oMLX
  0.4.5.dev1 on the same OptiQ snapshots: MiniCPM5-1B 339.0 vs mlx-bun
  `--batch 4` 345.4 (mean TTFT 397 vs 119 ms); gemma-4-e4b 89.8 vs 87.1;
  Qwen3.5-4B 100.9 vs 99.5 (TTFT 848 vs 368 ms). Before P5/logits
  processors landed the same day, oMLX led 1.46–1.89× and our TTFT
  queue-inflated to 1.1–3.8 s.
- Batch-lane B=1 gap before Phase 2, **cpm5, M1 Max, 2026-07-05**: ~149
  tok/s vs 267 serial (1.8×). mlx-lm's own `BatchGenerator` at B=1:
  256.5 vs 264.6 for `stream_generate` (3.3% tax) — the unified design
  was proven achievable before the gap was closed.
- After Phase 3.2, **2026-07-05 paired A/B**: unified B=1 decode ratios
  0.992–0.996 vs strict serial, byte-identical output (the default-flip
  evidence).
- Batched mixed-KV, **cpm5, 2026-07-05**: `--batch 2 --kv-quant config`
  400 tok @ 240 tok/s aggregate; B=1 bit-exact vs the optiq golden;
  padded-row KL within the 5e-2 envelope (bf16 same-harness ~9e-3).
  Gemma 12B rotating-quant B=2 join: unpadded row KL 0 every step, padded
  ≤4e-3.

## 10. History

- 2026-06-13 — Phase 18 opened; batched padded prefill found already
  proven in the training path (`buildBatchedPadMask`, `BatchedMaskCache`).
- 2026-06-14 — `--batch N` flag (designed as `--slots`; `--decode-concurrency`
  alias); `BatchedDecodeMaskCache` + decode-parity harness; dynamic-B
  `mergeKVRows`/`filterKVRows` vs mlx-lm dynamic golden;
  `BatchedRotatingCache`; `BatchScheduler` + `GenerationGateway` wired;
  L1 row green — CPM, Gemma 12B, e4b, 26B bit-exact vs mlx-lm B=2.
- 2026-07-01 — v2 hotfix bundle: slice-before-head, cache-capability
  gate, one lock domain (`runExclusive`); per-row containment +
  drain-on-serial-waiter; engine hygiene (pipelined decode, clearCache/256,
  chunked interleaved admit).
- 2026-07-02 — SSM batched path (Qwen3.5, token-exact vs mlx-lm B=2);
  per-row logits processors; `MLX_BUN_LANE_DEBUG`; serial-lane macrotask
  hop; oMLX burst port refuted; `--model` override honored by serve/bench.
- 2026-07-03 — grammar B1 per-row matchers + churn gates; `--kv-budget`
  admission + `/stats.batch` fields; Tier-0 universal per-row RoPE fix
  (Llama token-exact vs mlx-lm B=2); `bench-matrix.ts features`.
- 2026-07-04 — extend-join for full-attention layers (own oracle);
  vectorized homogeneous greedy sampling (bit-equal A/B).
- 2026-07-05 — Phase 2: B=1 host tax closed (`toIntTokens`, unpadded
  fast path); Phase 3.1: batched per-layer quantized KV (full layers);
  Phase 3.2: adopt-don't-copy, compiled decode at B=1, prompt-cache
  take/put on the batch lane; milestone 2: batched rotating-quant (every
  shipped `kv_config` batches); `--batch` default 1→8; concurrency-is-the-
  batch-size decision.
- 2026-07-06 — boundary-snapshot put on the batch lane (12B ctx repeat
  84 s → serial-class).
- 2026-07-07 — rot-quant join `temporalView` leak fixed.
- 2026-08-21 — Serving consolidation: immutable `GenerationPlacement`
  (`serial` | `continuous`); resolved `KvScheme` authoritative through
  placement, conversion, and projection; GLM `MLACache` as a
  `BatchableCache`.
- 2026-08-22 — rotating-join regression from 443f333 fixed (capability-only
  merge routing); `tests/batch-rotating-join.test.ts`.
