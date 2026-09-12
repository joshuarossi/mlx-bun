---
status: active
axis: ON
canonical-for: batching
plan-anchor: "Phase 18 — Concurrent / batched serving (slots) + parallel load benchmark `[~]` (2026-06-13)"
last-verified: 2026-09-10
---

# Batching — continuous scheduling for `--batch N`

The canonical design for concurrent serving: the scheduling seam
(`src/serve/generation-gateway.ts`), the continuous-batching engine
(`src/serve/batch-scheduler.ts`), the dynamic-B cache primitives
(`src/model/batched-*.ts`), admission, and the parity discipline that
gates all of it. Consolidates docs/design/batching.md, docs/design/batching.md,
docs/design/batching.md, the batching items of
docs/design/batching.md, and the scheduler tie-in from
docs/design/kv-cache.md. Status and dated progress live in PLAN.md (see the
plan anchor above); this file describes the mechanism as it exists and
what is still open.

Phase 6 now requires shared method/session execution at B=1 and B>1, full
batch feature parity, and configuration organized by owning interface. The
boundaries are defined in [engine architecture §12.5–12.7](unified-engine-frontier-plan.md#125-capability-negotiation-and-planning).
The separate serial mechanism described below is the current implementation;
retiring its duplicate lifecycle is open work. Backend specializations may
remain when they improve measured performance. R17 owns output checkpoint
publication to the shared RAM/SSD cache.

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
  does not implement runs unchanged on the serial mechanism today. That
  fallback preserves behavior during migration; it does not meet the new
  batch feature-parity requirement.
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
- **Spec decode and scheduling are separate concerns.** A mounted
  `--draft-model` selects speculation only for compatible requests. Ordinary
  fallback requests can batch when their actual features permit it. Concurrent
  speculation is an explicit feature gap in the shared-execution program;
  accepted lengths and target/draft state belong to the decode method.

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
  AND adapter state supports compatible groups (when adapters are selected)
  AND KV scheme supports the loaded cache layouts
  AND selected method has a grouped implementation
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

**KV-scheme capability:** the resolved `KvScheme` qualifies per-layer affine,
start-zero uniform affine, and ordinary TurboQuant with immediate or delayed
conversion through actual cache and layout support. The MLX layout binding
creates encoded rows; scheduling does not encode or decode KV. Qualified methods
share delayed affine/TurboQuant conversion and per-layer affine policies through
these row interfaces; TurboQuant sliding layers remain bf16.
Unsupported compositions retain the existing serial route until their shared implementation and acceptance are complete.

Paged Gemma4 bf16 requests compose through `PagedKvRows`; the request state
policy supplies block storage and prompt-cache bypass without changing scheduling.
GLM `--mtp on` (its default) mounts the MTP
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
(`plainGreedy` from the gateway: temperature 0, no logprob capture, no processors, no
grammar), one `toLogprobs` + `argmaxAxis` over `[B,V]` replaces B
slice/sample/concat graphs — per-row identical math, tie behavior
included. `MLX_BUN_BATCH_VEC_SAMPLE=0` forces the per-row closure path.
Length-doomed rows get a placeholder slot (never emitted; one KV write
on their own about-to-evict row).

**Sampling boundary.** `contracts/sampling.ts` defines `SamplingSession`:
borrow model logits, apply request-owned processing/selection, return the
chosen token and optional probability tensors. Device and host-token MLX
samplers implement the same generic contract. `createRowSampling` accepts a
sampler through that interface and binds its captures to output delivery.
The scheduler receives token tensors and a callback, with no probability
retention policy. Captures are evaluated with their token and retained by
request-local step until emission; cancellation and unconsumed lookahead
release them. Token-only requests retain the existing vectorized shortcut.
Explicit seeds no longer determine scheduler placement. The seed and local
sample index select the random key, independently of sibling requests.
Reproducibility is conditional on the same numerical execution composition,
not a promise of equal logits across different batch shapes. The preserved
`--batch 1` control supplies the earlier fixed-shape behavior.
Vectorized logprob capture and the broader sampling-kernel interface remain
optimization work; this change establishes no performance dominance.

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
lockstep. Full layers also remove the minimum left padding shared by all
survivors, matching `mlx-lm BatchKVCache.filter`. Buffer width and per-row
padding shrink together, preserving absolute RoPE positions. Quantized full
layers slice the token axis of packed/scales/biases together; rotating layers
retain their separate layout. Keeping those unused columns can change logits
through a different attention reduction shape.

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
   (`src/lab/paged-kv/paged-kv.ts`, `--paged-kv`) shipped as a serial-only,
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
| scheduler orchestration (admit/step/evict/join) | `tests/batch-scheduler.test.ts` | gated, exact live same-B protocol oracle (CPM and Gemma 12B) |
| per-row containment, drain, full-attention join routing | `tests/batch-containment.test.ts` | gated |
| rotating-layer join mid-decode (2026-08-22 regression) | `tests/batch-rotating-join.test.ts` | gated |
| KV-budget queueing + projection math | `tests/batch-kv-budget.test.ts`, `kv-budget-projection.test.ts` | gated / fast |
| vectorized sampling bit-equal A/B | `tests/batch-vec-sample.test.ts` | gated |
| grammar under batching (mixed masks, 4 schemas at B=4, churn, joiner, truncation) | `tests/batch-grammar.test.ts` | gated |
| quantized dynamic-B ops; batched mixed-KV per row vs serial composition | `tests/batched-quant.test.ts`, `batched-rotating-quant.test.ts`, `batched-kv-quant-parity.test.ts` | fast / gated |
| per-row extract == solo bytes | `tests/batched-extract.test.ts` | fast |
| live server: engage, `/stats`, SSE fan-out, serial coexistence | `tests/batch-serving.test.ts` | gated smoke |

Closeout recheck (2026-09-08, Apple M1 Max 32 GB, Bun 1.4.0,
MLX 0.32.2): the old Gemma solo-KL bound failed even though all 24 captured
simultaneous-admission vectors matched the same-B oracle exactly. Replaying
the mid-stream join exposed a separate mismatch in two later vectors: the
native full cache retained padding that `BatchKVCache.filter` removes.
The scheduler now performs that removal. The live protocol gate passes all
48 full-vector hashes on each of MiniCPM5 and Gemma 12B, including row
retirement and a join triggered after two emitted tokens. The oracle receives
inputs and row/step identities, never the native expected hashes. It uses
mlx-lm merge/extend/filter operations and ordinary full-attention KV caches
when the reference state has no padding, matching serving's scalar-position
policy. No tolerance was increased and no golden was regenerated.

Production oracle: `scripts/oracle/batch-scheduler-reference.py`. Initial
capture and comparison: `reports/qwen38-closeout/gemma-protocol/`.
Before/after gates: `gemma-protocol-gate.log`,
`gemma-protocol-filter-trim-gate.log`, `batch-protocol-final-gate.log`.
The original unchanged-HEAD failure remains in
`memory-baseline-batch-scheduler.log`. Quantized slice and broader serving
checks accompany the filter change; M4 campaign acceptance remains separate.


Benchmark harness: `scripts/bench-matrix.ts features` (six-cell
composition matrix over live SSE: TTFT p50/p95 at the first SSE token,
wall-clock aggregate tok/s, schema conformance as a hard gate);
`scripts/bench-serving-load.ts` is the client-only stack-vs-stack tool.
Quotable numbers come from a clean machine only; SSE bursts inflate
naive tok/s — use wall-clock.

## 8. Open items

### Consolidation matrix

This is the implementation gap inventory, not a claim that all combinations
have passed acceptance. Phase 6 coordinates the work; Phase 18 tracks its
batch cells. Current placement rules are in `src/engine/execution-plan.ts`.

The window-crossing scheduler gate in `tests/parity/batch-scheduler.test.ts`
now passes on Gemma 12B and e4b on both development machines. Two rows cross
the sliding window during decode; a third begins beyond it and joins late.
The pinned oracle replays the same admissions, merges and retirements and
compares every sampled full float32 logit vector. Run with
`MLX_BUN_TEST_BATCH_RING_WRAP=1`; `MLX_BUN_TEST_BATCH_RING_MODEL` selects the
existing artifact. Evidence is recorded in benchmarks.md.

Josh revised the immediate objective to shared batching by default with
effectively equal measured single-request performance. Serving already defaults
to a concurrency cap of eight, with B1 execution for a lone eligible request.
Explicit `--batch 1` and compatibility routing retain serial. Removing that
executor is deferred; complete feature parity is follow-up work, not a blocker
for the current default. Supported ordinary requests use the shared method.
Compare single-request B=1 latency, cold/cached
prefill and sustained decode as well as concurrent throughput. Record memory,
cache reuse and actual admitted rows. Keep kernel settings fixed for the
refactor comparison; measure new kernel optimizations in separate experiments.
Keep measured single-request regressions and unsupported features explicit.
They do not require repeating completed checks or withholding the current default.

| Concern | Current implementation | Required completion |
|---|---|---|
| Scheduling and ordinary decode | Default cap eight uses shared execution at B1/B>1; explicit `--batch 1` retains serial | Keep the batched default using existing measurements; address specific regressions separately. Serial removal is deferred |
| Speculative decode | Qwen MTP, prompt lookup, standalone, assistant, DeepSpec and seeded DSpark/DFlash providers are integrated through shared B1/B>1 interfaces, with the native/HTTP/cache checks recorded below | Finish specific unsupported combinations and measured regressions; GLM artifact testing is deferred and no trained DSpark/DFlash checkpoint exists |
| Sampling and logprobs | Shared sampler contract; ordinary groups capture logprobs and accept explicit seeds | Extend same-B oracle/feature compositions and matched performance; preserve per-request RNG/history |
| Grammar and fill | Grammar batches where enabled; grammar jump and fill remain serial-only | Shared constraint/proposal contracts and qualified batch compositions |
| Adapters and media | Compatible adapter groups use shared execution; media remains serial | Adapter performance and broader compositions; media preparation and compatible state through shared execution |
| KV layout | Full and rotating affine/TurboQuant layouts, delayed/per-layer transitions, speculative donors and ordinary paged storage are integrated and tested below | Direct paged-attention kernel, block sharing and quantized/speculative paging remain separate extensions; do not repeat the completed row-layout gates |
| Prefix and output reuse | Ordinary and grouped methods publish generated target/companion state to one RAM/SSD cache | Native/HTTP and full Kanban retention/durability acceptance are complete; investigate new regressions without reopening unchanged gates |
| Generation resume | Shared ordinary resume is integrated after both-machine native/HTTP compiled, quantized/delayed and mixed-grammar checks, combined suites and eight M4 timing arms. The packed-model fixture now owns fresh weights per server | Adapter resume is integrated through the same policy; native/HTTP composition checks accompany it. Reuse the completed ordinary resume evidence |
| Usage and cleanup | The gateway forwards timing/rates; the missing first-token timestamp in ordinary batch admission is now fixed | Consistent events/accounting, row cancellation, failure cleanup and persistence on shutdown |
| Configuration | Placement still chooses path-specific implementations | One resolved configuration per concern; no setting silently disappears when B changes |

Tests must exercise actual B>1 work, not requests routed back to serial.
Completed checks remain evidence for their recorded source and settings. A new
run needs a named changed behavior, uncovered case or reproduced failure;
an open umbrella row is not a reason to repeat all its passing checks.
The working tree now has a shared transaction lifecycle for request-owned
acceptance counts. Recurrent state and attention KV implement the same round
operations. Attention rollback changes logical coverage without moving KV;
subsequent appends overwrite rejected tips. Positions, masks, extraction,
empty draft prefixes, late joins and retirement belong to that storage layout.
A singleton preserves allocated prefill capacity and uses the existing scalar
RoPE and causal-mask operations. Removing the longest recurrent row now updates
the group's maximum coverage to its survivors.

`MlxStateRows` applies admission, filtering and extraction through layer-owned
row layouts. Attention KV and `BatchedSSMCache` implement the same port; the
collection contains no model-family branches or persistence policy. Admission
borrows prepared state and builds all layer replacements before releasing the
active collection. Unit checks cover reorder, extraction, removal of every row,
reuse, donor ownership and failed admission. Full-target MTP controls preserve
all retained state at B=1/2/4 on both Macs through this collection.

The affine row layout composes those same position/retention
operations for affine KV's packed values, scales and biases. It adds no
dequantization to joins, rollback or extraction. Qwen attention consumes a
quantized numerical port rather than selecting the concrete cache class.
Focused KV4/KV8 storage checks pass, including unequal acceptance, overwritten
rejected tips, joins, growth, removal and compact extraction. Full-target MTP
bf16/KV4/KV8 round checks pass on both Macs, including output-aligned stopping
and survivor continuation at smaller B. Both complete model-free suites and
typechecks pass. `BatchedQuantizedKVCache` and the numerical attention port are
adopted in the working tree. The tested source matches the adopted source;
native logs and the `batched-quantized-state-manifest.json` live in the
composition-baseline reports. Same-B external quantized-oracle coverage and
actual speculative serving acceptance remain open.

The row method also handles a zero-proposal round through the
same graph/commit interfaces. It processes the pending companion KV row without
sampling a draft or projecting draft logits, then retains the target hidden
row needed for later speculation. The old request producer skips this update;
the native control instead discards a depth-one proposal to obtain the same
processed state. The change is adopted after full-round bf16/KV4/KV8 checks at B=1/2/4 on
both Macs, companion checks that forbid draft sampling/head projection in the
zero round, both complete model-free suites and typechecks. The source manifest
and native logs live in the composition-baseline reports. This does not adopt
the separately measured request-producer replacement or B=1 hidden slice.

The provider exposes grouped companion state through the existing
checkpoint representation. `PreparedStateChange` lets target and draft owners
stage a join independently; `applyStateChanges` publishes both only after all
preparation succeeds, then releases their old state. A failed preparation
leaves active membership intact. Publication performs no graph construction or
validation, and adds no operation to the decode round. Focused checks cover
failed joins, cleanup errors and released allocations. Full bf16/KV4/KV8
rounds through coordinated admission and both complete suites pass on both
Macs. This interface is adopted; serving must now use it before exposing a new
request to scheduling. Source identity and checks live in the
composition-baseline `mtp-admission-manifest.json`. Companion ownership
details live in speculative-decoding §4.8.

The MTP numerical graph is separate from request lifecycle and sampling. It
uses the cache's positions for both singleton and batched forwards. Native
checks on both Macs preserve full-target state and subsequent output at B=2,
plus the companion graph's output and KV after unequal prefix retention.
Uniform acceptance uses the existing recurrent kernel; unequal acceptance uses
the row-length-aware state-only kernel. The separate uniform state-only replay
experiment did not establish a serving win, so it is not promoted.

The exact-token acceptance walk is now a portable request state machine.
It tracks accepted drafts, correction/bonus tokens, EOS, token budgets and
grammar termination. Sampling still owns score processing and request history.
A group can stop sampling a finished walk while advancing the others.

The MTP row method keeps draft-token arrays on device between steps and reads
one complete proposal block. Its sampler is injected; committed state can be
extracted, filtered and joined between rounds. Greedy and seeded sampling pass
at depths 1/2/4 on both Macs, including retirement, reorder, rejoin and reuse
after removing every row. B=1 preserves the existing producer's proposals and
state. At B=2, per-step host-read and device-chain controls match at the same B.
The M4's B=2 KV differs from independent B=1 controls; cross-B byte equality is
not claimed, and the initial result remains in the raw logs.

`advanceSpeculativeRows` composes injected drafting, target verification,
request samplers and state transactions into one committed round. It has no
admission, output delivery or persistence policy. Each sampler walks only its
accepted prefix, recording logprobs and respecting EOS, grammar and remaining
token budget. The existing request adapter and grouped method now use the same
`sampleSpeculativeRows` operation. Failure tests cover disposal of verification
tensors when sampling or target/draft retention fails; the caller discards the
failed method state.

Native complete-round tests pass on both Macs at B=1/2/4 and depths 1/2/4,
with seeded depth-two coverage. They compare proposals, target samples,
logprobs, every retained target layer and draft KV/hidden state across three
rounds. B=1 uses the prior request producer and manual accept loop as control;
B=2/4 use a manual same-B loop with host reads between draft steps. These are
internal refactor controls, not a replacement for the external numerical oracle.
The row method is adopted in the working tree but not yet selected by serving;
matched complete-request performance remains an acceptance gate.

The next isolated candidate replaces the request producer's draft/commit loop
with the shared row method at B=1. The frozen `mtp-shared-draft-reference`
checkout retains the previous producer for native continuation and paired
serving comparisons. A zero-proposal round must retain its pending companion
KV row before resuming speculation; the old producer skipped that state update.
Native continuation checks pass on both Macs. Both serving orders preserve
responses but do not establish equal-or-better performance; the candidate is
not adopted. Numbers and frozen source identities live in benchmarks.md.
The subsequent isolated change replaces the B=1 hidden gather with a slice of
the same verification context, retaining the shared method. Its first serving
block is essentially flat in decode, but the reverse-order block regresses;
neither the source replacement nor the slice specialization is adopted.

The isolated round interface also separates verification/sampling from state
commit. `advanceSpeculativeOutputs` composes that round with the portable
`deliverDraftOutputs` operation. Each consumer receives verified tokens through
`GenerationOutput`; its stop, failure or cancellation affects its own request.
Both target and draft state then retain the same published, processed prefix,
excluding unpublished EOS and unprocessed correction/bonus tokens. Failed or
cancelled state must be discarded. Continuing requests keep their complete
accepted prefix. Verification context is an opaque disposable resource,
allowing graph-specific hidden taps without putting model details into
scheduling. The output method is adopted in the working tree; it is not wired
to serving. Focused tests and the complete isolated model-free suite pass.
Final-source native controls pass on both Macs, including removal of stopped
requests and continued generation at B=4→2 and B=2→1. They retain the old
request producer as the independent B=1 control. Same-B survivor comparisons
check tokens, logprobs and every retained target/companion state. Logs and the
source manifest live in the composition-baseline reports.

These are method/state dependencies, not served batched MTP acceptance. Grouped
draft generation, verification and sampling still need to be integrated into
the shared executor, with actual concurrent serving, cancellation, persistence,
quantized-layout composition and matched performance checks.
Parallel tool execution in Pi only exercises inference batching if model
requests overlap; record admitted rows and arrival schedules in the evidence.
Josh's September 8 M1 Max and M4 Pro suites are the ordinary-execution
baseline, recorded in [benchmarks.md](../reference/benchmarks.md#direct-scheduler-b1-versus-serial--both-machines-2026-09-08).
Retain those results and target new measurements at changed implementations
and newly supported features. They justify consolidation, but do not prove
the missing feature combinations or removal of host overhead.

### Remaining mechanisms

- **`--prompt-concurrency`**: not accepted by the CLI (mlx-lm's cap on
  joiners per iteration; the drop-in alias slot). Today at most one
  joiner prefills at a time.
- **Rotating-layer `extend`**: Gemma joins extend their full layers but
  re-merge their sliding layers (`BatchedRotatingCache.merge` only).
- **Logprobs acceptance**: ordinary batch capture is implemented through
  the sampler interface. Unit coverage checks interleaved pipelines,
  processor-adjusted probabilities, top-only capture and abandoned outputs;
  `tests/parity/batch-logprobs.test.ts` exercises real B=1/B=2 and retirement.
  On M4 Pro, the packed Qwen campaign artifact passes native and HTTP
  serial/B=1 identity, actual B=2 capture on/off token identity, row retirement,
  selected/top-only wire shapes and SSE omission. This is an internal
  composition check, not a same-B external oracle or performance comparison.
  Explicit-seed gateway tests also reproduce serial/B=1 outputs and repeat
  fixed B=2 and controlled B=3 joins on M1 Gemma e4b and M4 packed Qwen.
  These keep the numerical composition fixed; they do not assert
  arrival-independent output across different batch shapes.
  Broader compositions and matched performance remain open.
  Cached-request diagnostics found synchronous recurrent-boundary persistence
  inside a RAM hit and a serial request-time durability flush. Both are
  removed: the shared cache lends immutable state views, and SSD writes run
  independently of requests, acquiring idle ownership without draining active
  batches. Explicit flush and shutdown remain durability
  boundaries. Native repeated-prefix and SSD-restart continuation checks pass
  on M1 and M4, including the saved long-prefix size on M4. A stalled-write
  regression verifies RAM reuse and snapshot lifetime through donor eviction.
  Balanced Bun 1.4.2 serving preserves outputs and near-equal decode time,
  but a small cached first-output gap remains. First admission now seeds the existing device-token register to overlap its readback
  with the following forward. Same-B MiniCPM/Gemma oracle vectors, compiled
  B=1, grammar, first-token stop/EOS/length, callback containment, seeded
  sampling and native/HTTP logprobs pass. Both serving arm orders preserve
  outputs and close most of the remaining gap; the change is adopted in the
  working tree. Actual method selection now precedes scheduling: configuring
  a draft does not force ordinary logprob or supported affine-KV fallbacks
  onto the serial executor. Native B=2 fallback outputs match ordinary B=2
  on M1 and M4; HTTP tests with a configured draft also reach B=2 without
  opening the producer. HTTP correctness tests align request arrivals at the gateway
  to require concurrent work; serving benchmarks retain natural arrivals.
  Broader pressure acceptance remains open.
  Measurements live in benchmarks.md.
The gateway forwards timing/rates, but native regression coverage found that
ordinary admission never set the first-token timestamp. That caused zero decode
time even for multi-token responses. The timestamp is now recorded at first-token
emission; repeated shared-prefix B=2 tests check positive decode time and rate.
Both execution lanes already use the same omitted-library-cap fallback. Broader
usage and stopping compositions remain in the matrix.
- **LoRA-group batching**: ordered adapter sets now select compatible groups
  through a backend-owned execution context. The scheduling driver sees only
  readiness. Context changes and prefix identity bind under the execution
  lease; adapter replacement while queued cannot reuse stale KV. Gemma e4b
  native B=1/B=2, mixed queues, callback failure, separate prefix reuse and
  queued replacement pass on M1/M4. Both machines match the pinned same-B
  oracle through retirement and late joins; KV4/logprobs composition also passes.
  Both M4 serving arm orders preserve single-request output. A small cached
  first-output gap keeps strict performance dominance open;
  simultaneous different adapters within a single forward remain future work.
  Shared adapter speculation is qualified by the grouped provider's
  `supportsTargetAdapters` capability. Prompt lookup declares it because its
  draft state contains token history, with no separate learned graph to adapt.
  Target prefill and verification retain the existing group adapter context;
  adapter revision namespaces protect both target and lookup checkpoints.
  Unqualified combinations retain ordinary execution. Learned providers do not
  declare this capability. The native `adapter-lookup.test.ts` gate covers
  compatible rows, seeded logprobs, failure cleanup and adapter prefix isolation;
  both-machine bf16/KV4/TurboQuant checks pass, including existing ordinary-adapter
  regressions. HTTP tests verify actual generated token alignment, exact seeded
  RAM/SSD restart choices and speculation metadata, adapter namespace isolation
  and concurrent requests. Concatenating a second newline can change the rendered
  token boundary; the negative tokenization control preserves that distinction.
  Full suites/typechecks pass; eight M4 comparisons are complete. Ordinary source cost is
  effectively flat. Enabled lookup has low draft acceptance and loses concurrent
  throughput on this workload; stricter matching is under separate measurement.
  The feature remains opt-in and does not qualify a new default.
  Evidence: `reports/qwen38-closeout/composition-baseline/adapter-lookup/`.
- **Prompt-cache byte interplay**: mirror mlx-lm's
  `trim_to(total − activeBatchBytes)` so the LRU and the live batch
  share one ceiling. Derived default for `--kv-budget` (usable − weights
  − prompt-cache cap − headroom) instead of unlimited-when-unset.
- **Long-context batched golden is complete** for the recorded Gemma 12B/e4b
  same-B window-crossing, retirement and late-join cases on both machines.
  See the ring-wrap gate above; it is not outstanding implementation work.
- **Unvalidated model cells** stay serial by the capability gate:
  gemma2-family (`maskArray`) and sliding-window universal archs.
- **Paged KV**: ordinary shared storage is integrated and measured. Direct
  paged attention, block sharing and quantized/speculative paging remain;
  the state/cache interfaces own storage, independently of scheduling.
- **GLM MTP with concurrent requests**: the isolated shared provider passes
  tiny-model and same-B Python state checks. Josh deferred final real-artifact
  testing; see the GLM section below.
- **Grammar jump-forward** (`MLX_BUN_GRAMMAR_JUMP`) is serial-only;
  `#stepGrammar` does not jump. Native XGrammar-2 via TVM-FFI has a
  B≫8 trigger.
- **Device-side step chaining (depth-k pipelining)**: serial-decode
  work, orthogonal to the scheduler; the matrix's serial baselines show
  its headroom.
- **Batch-invariant kernels** (identical numerics regardless of B): Lab
  research item; would restore determinism under load for free.
- **Qwen MTP with concurrent requests is integrated**: variable accepted
  lengths, method-owned state alignment, shared sampling and generated RAM/SSD
  reuse have passed the controls recorded below. Further work must identify a
  specific unsupported composition or regression.
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

### Shared KV maintenance

`createKvMaintenance` resolves the KV policy once when composing an execution
session. The ordinary generator, speculative prefill and the MLX execution group call
this same backend operation at their populated-cache boundaries. Per-layer lookup
is no longer rebuilt on every serial decode step. Streaming conversion still
materializes and releases each layer before converting the next. The existing
single-call `maybeQuantizeKv` export remains a compatibility entry point.
Server uniform KV4/KV8 now uses the same operation and existing quantized
batch layouts. Capability discovery probes actual cache-owning layers, including
Gemma's shorter donor prefix; it does not infer a separate scheduler from the
quantization label. M1 Gemma e4b and M4 packed Qwen native tests cover seeded
sampling with logprobs, exact serial/B=1 output, and repeatable controlled
B=2/B=3 joins. Matched serving performance and same-B external oracle coverage
remain open. Start-zero TurboQuant now has encoded row-layout support for
ordinary and Qwen MTP methods. Positive ordinary TurboQuant thresholds now
have merged-row transitions; Qwen delayed affine conversion is also adopted.

Prefill policy is now shared too. The execution group captures its chunk
default once; ordinary and speculative preparation use it, and both honor a
library request override. The gateway forwards that override instead of
silently using the group default for ordinary requests. The scheduler does
not choose a numerical prefill chunk. M1 native seeded-sampling and MTP
RAM/SSD checks pass on both Macs. The first matched M4 short control preserves
all measured outputs with effectively unchanged timing; long-context checks
and balanced acceptance remain open.

Delayed ordinary TurboQuant conversion is now adopted after the mixed-phase,
prefix-reuse, fused/unfused and composed MTP/generated-output checks pass on
M4 as well as the original M1 family gates. The cache publishes its actual
irreversible conversion boundary through clone, extraction, RAM lookup and
SSD metadata; earlier plain donors remain usable. The first M4 hygiene run
found only a stale generated docs map. After regeneration, full hygiene passes
on both machines without changing tested code. The main full suite and typecheck
pass for ordinary conversion. Delayed shared MTP is also adopted after native
state/continuation, seeded B1/B3/late-admission, SSD and complete-suite gates on
both machines. Conversion follows retained state after rollback and preserves
physical row positions; the codec and kernels are unchanged. The main full suite, typecheck and hygiene pass. Qwen delayed affine is also adopted; these correctness gates establish
no new TQ default or performance gain.

### Variable proposal lengths

The shared method accepts 0..depth proposals independently per
request. It sizes the rectangular target graph from the longest returned
proposal, right-pads shorter rows, and samples only through each row's own
bonus position. State commit retains the pending token and accepted inputs;
no padding enters a reusable checkpoint. If every proposal is empty, the
method runs one target step even when the configured draft depth is positive.
Scheduling does not choose proposal lengths or manage their acceptance.

The M1 Qwen control covers four rows with 0/1/2/3 proposals, greedy and seeded
sampling, independent retirement and re-admission. Both bf16 and KV4 preserve
tokens, logprobs, target state and companion state against explicit same-B
controls that use a different right-padding token. These are internal
composition checks, not an external oracle or a performance claim. Unit tests
also prove that padding consumes no sampler steps and terminal consumers
retain only delivered inputs. The complete candidate suite and typecheck pass.
M4 uniform/variable native controls and the complete suite also pass. The
first fixed-settings serving comparison was slower despite identical outputs
and speculation statistics. Alternating frozen-source controls do not reproduce
that slowdown and retain identical work. The three-file verifier patch is now
adopted; the main complete suite and typecheck pass. Provider migrations must retain their own
prefill/checkpoint conventions; this verifier alone does not change eligibility.
Evidence: `reports/qwen38-closeout/composition-baseline/variable-proposals/`.

### Prompt lookup through the shared method

The shared executor now implements prompt lookup as a provider-owned draft
row group. Each row holds committed token history, proposes repeated spans,
and appends only inputs retained by verification. It uses the same variable
proposal verifier, sampler, target state, membership transactions and cache
publication as MTP. Scheduling has no prompt-lookup branch.

Preparation explicitly supplies processed-token coverage to the provider.
For tail-split lookup, the last prompt token becomes the first pending input;
completed-output keys include it exactly once. Integer history tensors use the
existing companion-checkpoint format and byte accounting. The generic tensor
reader now supports int32 for streamed SSD persistence; no separate prompt
lookup writer or storage queue is introduced.

M1 Qwen bf16/KV4/KV8/fused-TQ serving checks pass B1 controls, real B4 verification, independent
consumer stops/failures, cancellation, late joins, seeded logprobs and grammar.
All four schemes pass tool turns with thinking off/on, generated-prefix RAM reuse and fresh-PID
SSD restoration with identical responses, logprobs and acceptance. The initial
SSD flush failure exposed the missing int32 raw-byte reader; its regression
now passes. MTP3 serving regressions also pass in bf16/KV4/TQ after the shared
preparation changes. Unsplit-prefill serving and the complete model-free/SSD
suite and typecheck also pass. The same planned native/HTTP scheme matrix,
MTP regressions, unsplit-prefill and complete suite now pass on M4. An initial
M4 wrapper failure supplied CLI quantization value `0` instead of `off`; it
failed before inference, was retained, and the corrected wrapper resumed
without source changes. Fixed-MTP timing is effectively unchanged. Both lookup arm orders preserve
single-request outputs with small decode improvements and new cached-prefix
reuse. Concurrent outputs differ and observed shared throughput is lower, so
strict dominance is unproven. Default depth-10 KV4 serving checks now pass on
both Macs and exercise all ten proposal positions. Serving eligibility is
currently Qwen only. The seven-file patch is adopted; its concurrent
performance gap remains open, and serial deletion is not qualified.
Evidence: `reports/qwen38-closeout/composition-baseline/ngram-group/`.

A separate composed checkout combines the adopted variable verifier and ordinary
TQ cache with prompt lookup and delayed speculative TQ. The only production
hunk shared by the two candidate patches is the generic cache preparation hook
before state admission; the merged source is verified against both deltas.
M1 fused/unfused target/MTP and prompt-lookup native checks, threshold-crossing
SSD restart, full suite and typecheck pass. The lookup extension exercises the
same delayed-cache serving test by substituting its draft provider, including
mixed phases, seeded metadata, retirement and late joins. M4 composition now passes the same native/SSD gates, full suite, typecheck
and hygiene. Both production patches are now adopted in main, with exact
file identity against the tested composed source. Fixed-MTP composition
timing is effectively unchanged. Main full-suite, typecheck and hygiene checks pass.
Evidence: `reports/qwen38-closeout/composition-baseline/method-composed/`.

### One-token prefill allocator maintenance candidate

A native first-output diagnostic found milliseconds of allocator cleanup after
a cached one-token target forward. A separate candidate retains allocator
buffers for single-token prefill work and still clears after larger chunks.
This is method-owned maintenance; the scheduler, sampler and cache-persistence
policy are unchanged. KV4 and delayed-TQ one-token suffix SSD continuations,
complete suites and typechecks pass on M1/M4. Alternating M4 fixed-MTP timing
preserves every request/output/usage record and consistently reduces cached
first-output latency. The first control has slower cold/decode timings, so
a broad throughput gain is not established. The 8k M1 allocation comparison
retains identical output/acceptance, nearly equal peak live allocation and a
larger final allocator pool. Matched serial/shared timing still shows a cached-latency regression; the
candidate remains isolated and long-context/SSD pressure remains open.
Evidence: `reports/qwen38-closeout/composition-baseline/single-token-maintenance/`.

### Delayed affine conversion

The adopted delayed-affine implementation extracts `TransitioningKvRows` from the
existing TurboQuant adapter. It owns committed positions, conversion, physical
padding, merge/extract and speculative rollback. Codec-specific adapters retain
their attention arithmetic. The affine adapter uses the storage-owned
`KvAttentionState` port for mixed-precision rows and the existing packed batch
attention once every row converts. Model binding declares support once and
passes that capability to request planning and executor construction.

Both Macs pass KV4/KV8 target rollback and continuation, ordinary serial/B1
seeded token/logprob equality, MTP B1/B3 retirement and late admission, plus SSD
restoration with conversion in prefill or decode. Fused/unfused TQ native and
serving regressions pass. Final full suites and typechecks pass on both Macs.
Positive affine thresholds and non-default group sizes have distinct cache
identities; captured conversion floors survive extraction and SSD restoration.
The original constructor-capability failure is retained in the raw evidence.

Alternating M4 fixed-settings comparisons preserve every request output, usage
and finish reason with effectively unchanged timing. The reviewed implementation
is adopted in the unreleased working tree. Eligibility currently covers Qwen;
other model attention ports remain open. Main full-suite/typecheck/hygiene checks pass. Prompt lookup also passes KV4/KV8
B1/B3 seeded continuation, actual proposals, retirement and late admission on
both Macs without scheduler or sampler changes.
No serial deletion or performance gain is established by these checks. Evidence is under
`reports/qwen38-closeout/composition-baseline/delayed-affine/`.

The adopted attention port preserves Gemma's donor/shared-layer contract: a donor
calls `Cache.attentionState.appendAndFetch` once, then every sharing layer calls
`KvAttentionView.attend` on the same captured state. The view owns tensor handles
and captured row alignment independently of later cache mutation or disposal.
The model retains pre-write RoPE positions through all consumers and releases
the view once at the end of the pass. Qwen and MiniCPM use one consumer per
append. Existing training attention paths remain separate from these inference
cache views. Scheduling and sampling do not manage attention-view lifetimes.


The captured-view implementation exposes `appendAndFetch` and a
reusable `KvAttentionView.attend`. Qwen consumes one view per append; Gemma can
retain it for sharing layers. KV4/KV8 unit checks preserve two distinct queries
after further appends, conversion, row reordering and disposal of the original
cache. Full-model Gemma 12B logits and active cache state match the existing
consumer path. The initial state test compared unused allocator capacity;
the corrected check compares every processed value, and keeps the failed raw
comparison. Gemma 12B/e4b and MiniCPM KV4/KV8 pass on both machines. The e4b checks
exercise multiple reads per append. The M4 full suite passes. The initial M1
suite used a fallback DeltaNet fixture because this worktree lacked the
already-qualified machine golden; copying that unchanged fixture makes the
focused test pass. Qwen KV4/KV8 rollback, MTP and prompt lookup regressions plus the corrected
M1 suite pass. Both-machine typechecks and KV4/KV8 SSD continuations pass.
Alternating M4 decode/cached/throughput timing is effectively unchanged. The
final control end check flags a small CPU daemon; the raw result is retained
and assessed under the campaign background-CPU policy. Startup remains less
stable and is not qualified by this screen. The reviewed change is adopted;
main integration suite, typecheck and hygiene pass.
Gateway eligibility is unchanged until the broader storage combinations pass.
Candidate evidence: `reports/qwen38-closeout/composition-baseline/kv-attention-view/`.


Delayed rotating affine storage remains a separate missing composition. Its
logical row positions and physical ring columns are different state: conversion
or packing must preserve the mask/column relationship. Existing
`BatchedRotatingQuantCache` has encoded row merging; the shared
`BatchedRotatingState` owns ring positions. Reuse those interfaces rather than
introducing a scheduler quantization branch. Qualify unequal offsets, conversion
before/after wrap, retirement, late admission, shared Gemma consumers and
persisted conversion floors before widening the gateway capability.

The first M4 benchmark wrapper stopped before inference because its parent
shell inherited an older oracle path. The Qwen correctness child had already
passed with the explicit pinned environment. Only the unstarted benchmark was
resumed, with that same explicit environment; the completed four-arm comparison
and failed launch log are retained.


### Multi-token rotating storage

The adopted rotating-block implementation removes the one-token-only restriction
from both bf16 and affine batched rings. `RowStorage` supplies encoded tensor
operations; `appendRotatingStorage` retains chronological history without
unpacking affine tensors; `BatchedRotatingState.commitConcat` owns padding,
logical positions and the physical write head. One-token updates retain their
existing in-place implementation. The port follows the pinned mlx-lm
`BatchRotatingKVCache._update_concat` for left-padded inputs.

A block temporarily holds up to window + block length - 1 columns so every
query retains its full context. Extraction preserves that active block, while
merge views select the newest window. Dropping the temporary suffix during
extraction would corrupt subsequent continuation. No scheduler or sampler
changes are needed for these storage operations.

The same-B live oracle gate covers B=1/2/3, unequal left padding, mixed
one-token and block writes, repeated wrap, overshoot, row reordering,
retirement, late admission and extracted state. bf16 values and masks match
mlx-lm exactly on both Macs. KV4/KV8 share its geometry and preserve every
extracted affine component against the native quantizer. Existing Gemma 12B
ring-wrap serving still matches 48 full logit vectors per machine. Both-machine model-free/SSD suites and typechecks pass. The reviewed six-file
change is adopted; main typecheck/hygiene pass. No performance or full
batched-prefill claim is made.
Right-padded prefill finalization and speculative rollback of overwritten
ring entries remain part of the shared-execution work. Delayed rotating
precision conversion is implemented below.
Evidence: `reports/qwen38-closeout/composition-baseline/rotating-block/`.


### Delayed rotating affine conversion

The adopted implementation uses `TransitioningKvRows` for ordinary membership,
retirement, checkpoints and precision changes. `SpeculativeTransitioningKvRows`
adds rollback for layouts that implement it; ordinary rotating storage does not
advertise speculative rollback. `TransitioningKvPositions` supplies geometry
without a codec. Full-attention positions retain the existing `KvTensorRows`
operations, and rotating positions use `BatchedRotatingState`.

An aligned row keeps the group's physical ring columns while exposing its own
logical position to the shared affine-maintenance policy. Conversion quantizes
the existing buffers without changing their physical layout, write head or
padding. Once every row is converted, the encoded planes concatenate
without reordering columns. `captureKvAttention` provides the same owned read
view for either representation; Gemma's donor and sharing layers can keep
reading it after the cache advances. No scheduling or sampling branch is added.

Membership changes normalize borrowed solo rows through owned clones. Empty
plain and affine cache clones now remain valid empty caches, enabling a group
to be assembled before its first input. Extraction preserves each row's
conversion floor in the existing persistence schema. The implementation enables
positive affine thresholds for ordinary Gemma execution; other speculative
providers, rotating rollback and true batched-prefill scheduling remain open.

Gemma 12B and e4b KV4/KV8 pass exact hidden/logit and active-state checks before
and after the real sliding window on both Macs. Serialized output snapshots
preserve token IDs, state and conversion floors; restored snapshots continue
identically to RAM snapshots in the same process. These are not fresh-process
or long Kanban acceptance. Seeded gateway checks match serial at B1 and repeat
B2/B3 admission schedules exactly on both machines. The model-free checks cover
mixed precision, empty rows, conversion before/after wrap, block updates,
retirement, late joins and attention reads after owner disposal. Final complete suites and typechecks pass on both Macs, as do Qwen affine
MTP/lookup and fused/unfused TurboQuant regressions. Artifact-defined per-layer
Gemma compression also passes both-machine hidden/logit/state and persistence
checks. Four alternating M4 default Qwen benchmark arms preserve all responses
and show effectively flat decode, cached latency and concurrent throughput;
startup equivalence remains open. The reviewed fifteen-file implementation is
adopted in the unreleased working tree. Main integration suite, typecheck and hygiene pass.
Measurements and source identities live in benchmarks.md.
Evidence: `reports/qwen38-closeout/composition-baseline/delayed-rotating/`.


### Singleton admission copy candidate

An isolated candidate replaces singleton `copyOf` calls with `contiguous` in
attention and recurrent admission. The proposed GPU-copy saving is not
supported: the M4 MLX 0.32.2 probe shows both operations share existing storage.
This agrees with the existing explanation in `mlx/materialize.ts`; a method
name is not evidence of a physical copy. The evaluated synthetic Qwen-shaped
probe shows no additional GPU allocation for either version. Also, shared MTP
publishes its first token before the singleton group merge, so that merge is
not on its first-output critical path.

Both-machine ownership tests cover independent updates, donor immutability,
self-merge, spare capacity and source/group disposal. Typechecks pass. The M4
bf16/KV4/KV8 round matrix, fused/unfused TQ, delayed affine/TQ serving and full
suite pass. M1 native/serving and the complete suite also pass. The alternating
M4 HTTP comparison preserves all responses and records lower cached latency
in both candidate arms. The physical-copy explanation is disproven, so further
attribution/repetition remains before adoption. Startup equivalence and direct
serial dominance are still unproven. Extraction and larger group concatenation
are unchanged. Timing belongs in benchmarks.md.
Evidence: `reports/qwen38-closeout/composition-baseline/singleton-state/`.


### Recurrent output-row retention

`SSMCache.extractRow` used `copyOf` with a comment promising compact storage.
The current MLX implementation aliases that storage: after releasing a B>1
source group, one retained row still owns the entire group's backing buffers.
The M1 allocation probe reproduces this for B=2/4/8. This is separate from
singleton admission, where sharing a complete allocation is appropriate.

The adopted extraction fix uses the existing `materializeCopy` port for
a proper subset of a batch and retains a separate array handle for B1. Row
values and logical offsets do not change. The allocation regression fails on
the unchanged control and passes on the candidate, including exact values and
disposal on both Macs. Both-machine KV4 MTP round matrices, bf16/KV4/TQ generated
RAM/SSD continuations, complete suites and typechecks pass. Four alternating
M4 HTTP arms preserve all responses and support integration without a broad
speed claim. The source and regression test are adopted; main integration
suite and typecheck pass. Long-context pressure acceptance remains open.
No scheduler, sampler, persistence queue or quantization policy changes.
Evidence: `reports/qwen38-closeout/composition-baseline/ssm-extraction/`.


### Padded prefill cache interfaces

The adopted cache-interface portion adds `PaddedPrefillCache`. Its frozen
validation checkout is `padded-prefill-validation`.
Preparation receives each prompt's lengths and left/right padding. Finalization
removes trailing padding from logical coverage and aligns retained state before
decode or checkpoint publication. The cache owns these operations; neither the
scheduler nor a quantization codec chooses token positions.

`FullPrefillPadding` applies one row-roll index to arbitrary full-cache tensor
planes. Plain KV, affine KV4/KV8 and TurboQuant reuse it without dequantizing or
requantizing the stored values. Rotating storage instead moves completed rows'
padding ahead of valid history before each block trims its window. Both plain
and affine rings share that position logic and preserve physical alignment.

One-token padded chunks use the existing rotating concat operation and block
mask. MLX-LM's public dispatch rejects this case before finalization. The gate
therefore invokes its existing `_update_concat` and takes the first query from
its two-token block mask for this extension. Ordinary decode retains the ring
write. This is an extension checked against oracle operations, not a claim that
the upstream public dispatcher supports the same call.

The live geometry gate checks B1/B2/B3, left/right padding, an existing prefix,
window overflow, zero-length prefixes, one-token chunks, finalization, extraction
and continuation.
Plain tensors, masks and positions match the reference. Affine and TurboQuant
retained bytes match their existing codecs applied to oracle-retained rows.
MiniCPM5 and Gemma 12B/e4b also match full same-B logit vectors after padded
prefill and three continuations with whole-prompt, 5/5/1 and singleton chunks
on both Macs. Complete suites and typechecks pass on both machines. Qwen KV4
MTP rounds, both TurboQuant decode settings and generated-prefix bf16/KV4/TQ
RAM/SSD continuations also pass on both Macs. These regression runs use ordinary
unpadded preparation; they do not qualify Qwen padded prefill.

The cache-interface changes are adopted; main integration suite and typecheck pass.
Qwen recurrent-state masking, delayed rotating transitions and ordinary
preparation cohorts are adopted below, including cancellation/checkpoints.
MTP preparation and full-cache delayed padding still keep S1a open.
No serving performance result or default change is claimed for this candidate.
Evidence: `reports/qwen38-closeout/composition-baseline/padded-prefill/`.

Full-cache finalization now retains absolute valid ends, as rotating storage
already does. It removes only padding actually processed. This lets a cohort
finish early after a longer request leaves, or finalize a partial prefix before
the original planned width. Ending before any right padding leaves tensors and
positions untouched. Filtering and reordering requests also filters those ends.
The unchanged control subtracts unprocessed padding and produces negative
coverage in the shortened-cohort regression; its failure log is retained.

Both-machine geometry checks cover completed and shortened B1/B2/B3 prefills,
cached prefixes, leading padding, request retirement/reordering before
finalization, extraction and three subsequent decode steps. The reference full
cache receives the effective padding of the processed prefix; Bun receives the
original plan. Survivor checks select the corresponding oracle rows without
changing their physical columns. Plain state/masks match exactly; affine and
TurboQuant retained bytes match encoding those oracle rows. Host lifecycle
tests also cover finalization before any work and preparation after a partial
checkpoint. Model-free suites, SSD tests and typechecks pass on both Macs.
This fixes cache preparation semantics; serving cohorts and their cancellation
handling are still unwired. No speed or default change is claimed.
Evidence: `reports/qwen38-closeout/composition-baseline/padded-partial/`.


### Recurrent-state padding

The adopted recurrent-padding change extends the same prefill port to
Qwen's recurrent cache. `SsmPrefillPadding` tracks remaining real-token lengths
and leading padding. Each cache advances coverage by real tokens only and
filters that metadata with its rows. Finalization clears preparation state.
Uniform prompts keep the unmasked kernel and ordinary convolution tail.

The model constructs one mask for all recurrent layers. DeltaNet zeroes padded
QKV inputs before convolution, selects each row's convolution tail by its
remaining length, and uses the pinned oracle's masked recurrence. Masked steps
leave recurrent state unchanged. The existing kernel body is shared between
masked and unmasked specializations; scheduling does not choose or manipulate
these state operations. The convolution-tail selection already used by
variable speculative rollback is reused here.

The primitive gate compares full output and state hashes with the pinned GPU
oracle at the 27B head geometry. It includes B1/B3, fully masked rows, singleton
steps and an unmasked continuation. The unchanged control fails this gate.
The small Qwen model passes padded full-model checks on M1. Both Macs pass
same-B 27B full-logit and convolution/recurrent-state checks for unequal prompts,
batch-of-one and uniform B3, with whole-prompt, singleton-tail and all-singleton
chunks. The machines use their locally installed affine 27B artifacts; these
are per-machine oracle comparisons, not an engine or artifact speed comparison.

The isolated checkout initially retained three obsolete HEAD files and lacked
its machine-specific golden blobs. Those setup problems were corrected against
the validated base; no golden was regenerated. Initial scalar creation also
needed the existing typed-array constructor. Failure logs remain with the
candidate evidence. Both-machine MTP/TQ/generated RAM/SSD regressions, full
suites and typechecks pass. Four alternating M4 HTTP arms preserve all responses
with roughly flat decode/cached/throughput timing. Startup equivalence remains
open. The change is adopted; main integration suite and typecheck pass.
Delayed-codec preparation and actual serving cohorts remain open.
Evidence: `reports/qwen38-closeout/composition-baseline/padded-ssm/`.

### Delayed rotating compression during padded prefill

Delayed rotating KV4/KV8 now implements the same preparation/finalization port.
Each physical row receives its own token lengths and the common batch layout.
All rows use the padded block operation when any sibling has right padding,
including a singleton chunk in a row without padding. An initial implementation
lost alignment by letting that row switch to a ring write while its sibling
continued block writes. The retained failing regression exposed incorrect cache
bytes when those rows later packed together.

The shared position snapshot now combines every row's pending valid end when
format conversion packs a group. Maintenance uses valid token counts, so a
padded suffix cannot cross a precision threshold or inflate the earliest
reusable prefix. Physical write positions remain separate. Retirement and
reordering preserve pending preparation state before and after packing.

Both-machine geometry gates include B1/B2/B3/B4/B8, KV4/KV8, multiple transition
thresholds, cached history, ring overflow, singleton chunks, early finalization
and survivor continuation. Cache geometry comes from the pinned MLX-LM oracle.
Encoded bytes match the existing codec applied to oracle-retained rows; exact
attention checks use those oracle tensors and masks with the native operation
at the same B as each mixed or packed representation. Gemma 12B/e4b also pass
same-B padded model logits through the delayed layout before conversion.
The latter is plain-KV model coverage, not a quantized padded full-model oracle.
Ordinary Gemma conversion and RAM/SSD continuations, complete model-free suites
and typechecks pass on both Macs.

The change is adopted in the unreleased working tree. Four alternating Gemma
M4 benchmark arms preserve all responses; the small timing differences are
recorded in benchmarks.md and establish no speed win or serial dominance.
Full-attention delayed affine/TurboQuant padding remains open. Ordinary serving
now uses the real-token cohort described below.

Ordinary serving uses a method-owned cohort of equal-length
chunks of real tokens. It admits later arrivals between forwards. Each request
retains its planned maintenance, checkpoint and tail boundaries when a peer
causes an earlier split. Scheduling chooses membership; the preparation method
runs shared forwards; cache layouts merge positions and retain precision policy.
The same target driver now serves MTP and prompt lookup; their providers own
companion prefill state through the separate method interface.

The first lifecycle runs exposed an empty-state native evaluation and missing
initialization when a cold recurrent row joins populated state. Empty caches
submit no evaluation. The recurrent layout initializes the new row's state
with zeros, matching the pinned reference's ArraysCache.merge behavior.
Qwen 27B on the M4 then exposed a logit mismatch immediately after retirement.
Full-attention storage now removes padding shared by all survivors, matching
BatchKVCache.filter. Affine planes inherit that operation; TurboQuant's tensor
storage applies it too. These are cache membership operations, independent of
scheduler, sampler and inference method.

Focused tests cover staggered B1→B2→B3 joins, real-token identity, native retained
bytes with immediate/delayed affine and TurboQuant conversion, checkpoint
boundaries, cancellation and completion callback failure. A scheduler-level test
submits a request during the first forward and observes it in the next chunk.
The model gate compares every full logit vector to the pinned same-B reference
through joins and retirement, then compares each extracted row's continuation.
It passes Qwen 27B and Gemma 12B on both Macs; the M1 also passes Qwen 0.8B.
Padded cache geometry/encoded-state/attention checks pass on both machines.
The padded oracle now performs retirement itself; stock filter omits pending
prefill metadata, so the fixture selects its right-padding/length metadata with
the same row indices before calling the existing finalize operation.

MTP delayed affine/TurboQuant regressions pass on both Macs. Four-arm M4
timing and response differences are recorded in benchmarks.md.
An added token-zero check then found that the M4 Qwen 27B sampler receives
different logits when each completed row projects its hidden state separately.
The shared forward's full vectors still match; the M=1 projection changes its
arithmetic. A follow-up candidate projects the batch before selecting logits
for each sampler. Its focused lifecycle checks and the M4 Qwen 27B/Gemma 12B full-vector,
sampler-logit and continuation checks pass on both Macs. Full model-free suites
and typechecks pass on both; all 829 nonignored source/test files match across
the isolated copies. Fresh four-arm M4 timing is effectively flat. The corrected
cohort is adopted in the unreleased working tree; main integration suite, typecheck and hygiene pass. Seeded delayed-TQ/affine serving and logprob/wire checks also pass on
M1. Unsplit-prefill seeded serving passes M1 Qwen 0.8B and M4 Gemma 12B.
Validated source: `/Users/joshrossi/.cache/mlx-bun/prefill-cohort-logits-validation`.
A separate admission-control benchmark retains the measured code but disables
additional cohort admission. That control restores every baseline response,
attributing the changed concurrent text to shared prefill.
Full delayed affine/TurboQuant padded preparation and MTP prefill cohorts remain
open. The production HTTP benchmark now measures long aggregate prompts and
staggered arrivals. Its four-arm M4 comparison exposes a first-output latency
regression and no throughput win at the current chunk size. M1 traces show
internal token zero ready before a long B3 preparation chunk delays the first
response write. A matching smaller-chunk M4 screen still loses latency and
throughput. Prefill work-unit sizing and admission policy need tuning through
the shared scheduler/preparation interfaces. This is a scheduling decision
within the shared executor; it must not introduce another serial method.
See benchmarks.md for numbers and limits.
Evidence: `reports/qwen38-closeout/composition-baseline/prefill-cohort/`.

An isolated follow-up exposes preparation work through the scheduling contract.
The preparation owner reports each admitted request's initial uncached token
count; the queue adapter reports the next prompt length as an upper bound before
cache restoration. The scheduler extends a cohort only while the combined
weight fits its internal preparation budget, currently 2,048 tokens. The first
request always enters and can exceed that budget alone. No request is rejected
or sent to another executor. Short late arrivals still join ongoing preparation.
An earlier version reduced the weight as prefill progressed. That allowed a
nearly completed request to attract another long request into its tail; the
first M4 screen restored early latency but still lost total request time. The
current candidate retains admission weight until the request leaves preparation.
This policy changes grouping, not per-request chunk or precision boundaries.
Cache lookup/restoration remains in preparation, not scheduling. The conservative
queued estimate can postpone a cached long request until current preparation
ends. A native Qwen/TurboQuant check with a long RAM prefix passes repeat output,
retirement, immutable cache bytes and actual B2 decode on M1. The original late
prefill join remains covered, alongside a group test that holds a nearly finished
row's weight and then advances its queued sibling through the same executor.
The seven-file fixed-weight policy is adopted in the unreleased working tree.
Both complete suites/types and long-prefix ownership checks pass. The M4
comparison restores the large first-output loss and all response identity,
while small unfavorable timing differences remain in benchmarks.md. Main
integration suite/typecheck pass; strict performance dominance remains open.
Candidate: `/Users/joshrossi/.cache/mlx-bun/prefill-budget-validation`.
Evidence: `reports/qwen38-closeout/composition-baseline/prefill-cohort/budget*`.

A separate two-file lifetime candidate releases input IDs after the forward and
releases unused hidden output before cache evaluation/maintenance, matching the
existing shared prefill primitive. The cohort previously retained those handles
until the end of the work unit. Finished rows still retain hidden output through
batched projection and sampling. Focused ownership checks pass on M1, and the Qwen 27B
same-B model/sampler/continuation gates pass on both Macs. The M1 full suite and
typecheck pass. The four-arm M4 comparison preserves all responses but shows no
throughput or material measured-memory benefit. This candidate is not adopted;
its M4 full suite/typecheck was not run. Timing and limits are in benchmarks.md.
Candidate: `/Users/joshrossi/.cache/mlx-bun/prefill-drain-validation`.

The next isolated candidate exposes `DraftPrefillGroup` from the draft provider.
It borrows each batch of new target tokens and context, and owns companion KV,
the pending true hidden row, cold/restored membership and checkpoint capture.
`QwenMtpRows` supplies preparation and draft/commit state at B1 and B>1;
its preparation port requires no sampler. A restored request bridges its next
token to the saved preceding hidden; cold members discard that bridge. The
remaining chunk pairs each shifted token with its preceding target hidden.
Preparation evaluates KV and the retained final hidden, leaving unused decoder
outputs outside the evaluated graph. Membership and state extraction reuse the
existing cache storage and checkpoint format. The scheduler is unchanged.

Pinned same-B checks pass companion KV and full decoder continuation through
B1/B2/B3/B4, cold joins, restored prefixes, retirement and a long chunk boundary
on both Macs. Those checks exposed a pre-existing unfused activation in the MTP
MLP. Reusing the target's compiled SwiGLU matches the reference vectors. Existing
MTP draft/commit checks and both complete suites/typechecks pass. Initial suite
failures came from omitted benchmark fixtures and an old M1 DeltaNet golden in
the isolated checkouts; restoring each machine's existing inputs fixes them
without changing the implementation or regenerating goldens.

The seven-file provider port and numerical correction are adopted in the
unreleased working tree. The M4 HTTP comparison preserves response text and
prompt/output counts with effectively flat timing, while draft acceptance
traces change. That comparison did not exercise batched MTP prefill because
shared target preparation was not yet connected to the new port. Numbers and limits are in
benchmarks.md. Main integration suite/typecheck pass.

The isolated `MlxPrefillRows` driver now owns target membership and chunk
progression for ordinary, Qwen MTP and prompt-lookup preparation. Each method
supplies initialization, chunk planning, checkpoint capture and completion.
The draft provider owns companion prefill state and materializes restored
companion copies before target membership releases an SSD backing lease.
Final-step maintenance is explicit in the chunk plan. A fully restored
pending-token prefix completes without a zero-length model forward.
Prepared rows return to scheduling before joining active decode, preserving
the first-output publication boundary.

The connected implementation passes full suites and typechecks on both Macs,
and the target's same-B oracle checks through staggered prefill and continuation.
The companion and Gemma 12B target oracles also pass on M1. Expanded native MTP serving checks on both
Macs prove that a request submitted during the first target chunk joins the
next chunk before any output. M4 passes this check with prompt lookup and
TurboQuant as well. These checks also cover B1 producer parity, B4 execution,
retirement, cache reuse and HTTP grammar/logprobs. Generated target/draft
checkpoints preserve RAM/SSD continuation after restart on both Macs with TQ.
An added M1 probe confirms four rows actually share prefill in that cache test,
before the first output.

Added method lifecycle checks verify exact target/history coverage, zero-work
restored prefixes and cancellation before and after preparation completes.
The latter exposed a failure that rejected siblings before active admission.
The method now rejects and releases only the cancelled ready row. A first-token
consumer failure also leaves an unfinished sibling running. M1 delayed affine
MTP/lookup and delayed TurboQuant MTP checks preserve seeded continuation,
metadata and speculation through mixed precision, retirement and late joins.
The common driver also passes M1 ordinary TQ ownership checks with a 4096-token
RAM prefix through concurrent use, retirement and supersession.
The balanced M4 comparison is complete. Shared MTP prefill reduces concurrent
throughput. Two attribution runs retain the same shared engine but prepare
requests individually; both reproduce control responses and restore throughput.
This isolates the regression to enabling shared preparation, without requiring
a separate serial executor. A narrower policy that finishes a resumed final
prefill step before admitting new rows does not recover throughput and produces
the same responses and speculation counters as the shared-prefill candidate.
Neither scheduling variant is adopted. The common driver is adopted with the
cache ownership fix described below.
Phase/layer probes narrow the sustained gap to MLP evaluation despite identical
Trellis routes, shapes, dtypes and call counts. Settling target state and clearing
the temporary pool after preparation does not restore throughput and is not
adopted. The snapshot-lifetime investigation below recovers this loss. Numbers
and conditions are in benchmarks.md. Broader composed oracle/cache coverage and
other draft providers remain open.
Candidate: `/Users/joshrossi/.cache/mlx-bun/mtp-prefill-validation`.
Evidence: `reports/qwen38-closeout/composition-baseline/prefill-cohort/mtp-prefill*`.

Common-driver candidate: `/Users/joshrossi/.cache/mlx-bun/mtp-cohort-validation`.
Evidence: `reports/qwen38-closeout/composition-baseline/prefill-cohort/mtp-cohort*`.
The integration patch and source hashes are recorded in
`mtp-cohort-integration.patch` and `mtp-cohort-integration-manifest.json`
under that evidence directory. Native logs identify which test expansion
ran; earlier serving checks did not include arrival during target prefill.


A deferred compact row snapshot retained its full parent batch until evaluated.
Resolving target snapshots before RAM retention recovers the concurrent loss
in two M4 runs while preserving every shared-prefill response and full usage
record. Failed tile-size, input-evaluation and residency experiments are closed.

The adopted implementation moves snapshot materialization into the
RAM prefix-cache implementation. A backend operation resolves target state and
opaque companion tensors before storage accepts ownership. It performs no
serialization or disk I/O; eventual SSD persistence keeps its existing queue.
Ordinary decode, MTP and lookup publish through the same interface and need no
method-local evaluation rule. Evaluation failure leaves ownership with the
publisher. The regression test measures retained allocation before any cache
read and covers both target and companion rows. Both-machine suites/typechecks, composed native checks and the matched M4
comparison pass. Main integration suite, typechecks and hygiene pass. Strict B1/long-prefill
acceptance and remaining feature combinations are still open. Numbers belong in
benchmarks.md; source and validation records are in
`mtp-cohort-cache-boundary-manifest.json` under the cohort evidence directory.


### Full-attention delayed compression during padded prefill

The integrated full-attention implementation provides the existing padded-prefill
port for delayed affine and TurboQuant rows. Each row keeps physical write
positions, valid token coverage and pending finalization separately. Conversion
uses valid coverage; codec tensors retain their physical alignment. When all
rows share an encoding, the packed layout inherits pending valid ends. Finalizing
and retiring rows move encoded planes without re-encoding live values. The same
row wrapper and transition lifecycle serve affine and TurboQuant; model methods
and scheduling are unchanged.

The extended pinned cache oracle passes on both Macs with KV4/KV8 and TQ K8/V3
and K4/V4, multiple conversion thresholds, cached history, shortened prefill,
retirement/reorder, continuation, and leading padding across multiple chunks.
It checks masks, positions, retained encoded bytes and same-B attention. Invalid
padding bytes are not state: moving encoded zero padding can preserve a different
signed zero than encoding it again, while retained values and attention remain
exact. Existing unpadded row/cohort regressions pass on M1. The Gemma model gate
exposes a before-conversion mismatch when affine attention runs uniform BF16
rows separately. The candidate now assembles those tensors through the same
helper as TurboQuant and runs attention at the model's B. The cache oracle
passes after that change, as does the Gemma affine full-model gate. Both
regression suites and typechecks pass. Affine MTP/lookup and delayed affine/TQ
seeded serving pass on M1; TQ MTP serving passes on M4. Generated MTP3/B4
RAM/SSD continuations pass on both Macs. All four matched M4 arms preserve responses and usage. The measured small
throughput decrease is recorded in benchmarks.md; strict B1/long-prefill
acceptance remains open. Main integration suite/typechecks pass. Candidate:
`/Users/joshrossi/.cache/mlx-bun/full-delayed-prefill-validation`; evidence:
`reports/qwen38-closeout/composition-baseline/full-delayed-prefill/`.


### Standalone autoregressive draft graph integration

The integrated implementation runs a standalone draft graph at the group's B and
hands its log-probabilities to the existing row sampler. Immutable batch
snapshots retain accepted recurrent/attention boundaries without changing
scheduler policy. Full acceptance retains the last draft token as companion
state and re-feeds it with the next target token in one forward, preserving
the reference's two-token shape. Mixed one-/two-token feeds use the existing
padding interface. Zero-proposal rounds preserve processed-token coverage.

The lifecycle test covers mixed acceptance, removal/reordering, zero proposals
and mixed re-feed lengths. A native Qwen 0.8B gate on M1 checks exact B1
attention/recurrent state and continuation at depths 0, 1, 3 and 4. The provider is integrated; its old single-request source now
adapts the same draft engine at B1. The small Qwen target/drafter passes B1/B4
serving, late joins, consumer failures, seeded sampling/logprobs and HTTP
coverage. Companion state reuses backend cache codecs; asynchronous prefill
completion now preserves target-context ownership. The 27B target with the 0.8B
standalone drafter passes B1/B4 serving on both Macs (228 assertions each),
and depth-three TurboQuant generation restores through RAM and cold SSD
(33 assertions each). The M4 pinned Python oracle passes the Llama 3B/1B
pair, including four templated cases at draft depths two and three, grammar
and stopping. Full suites pass on M1/M4 (2,153/2,157 tests), as do all
typechecks and the existing MTP/lookup native regressions. The first matched M4 comparison improves B1 decode and cache reuse but
hits a GPU allocation failure in the four-request phase, including the
benchmark’s retry. The allocation trace explains why short correctness
coverage did not expose this workload failure. Replaying
all prior requests reproduces the failure with 4,005 MiB of accounted RAM
cache entries and a 17,987 MiB observed allocation peak. A fresh aggregate
passes. The retained entries consume the remaining working-set headroom;
the repeated comparison holds both arms at 2 GiB RAM plus SSD and completes
all four arms. Decode/cached/aggregate gains and cold/startup costs are
recorded in benchmarks.md. Main integration suite, typechecks and hygiene pass. The retained 4 GiB failure remains part of cache-settings acceptance.
Validation source:
`/Users/joshrossi/.cache/mlx-bun/two-model-batch-validation`; source hashes and
checks: `reports/qwen38-closeout/composition-baseline/two-model-batch/`.

### Full-attention target capability binding

The integrated implementation moves the shared target-layout factory behind
one storage capability binding. Grouped speculation then depends on the
model graph's batch support and the storage transaction factory, replacing
the Qwen-only target selection. Scheduler and draft-provider policy are
unchanged; quantized speculation retains its existing qualification while
plain full-attention targets are tested. On M1, Llama 3B with the same model
as drafter passes shared B1/B4 serving, late joins, retirement, seeded
sampling/logprobs and grammar (224 assertions). Prompt lookup passes the
same serving harness; generated RAM/SSD continuation passes at depth three.
The pinned Llama model oracle is exact at B1/2/3/4/8 across padding, chunks
and continuation (541 assertions), and mixed-prefix target rollback passes
1,352 state/continuation assertions. The complete M1 suite and typechecks pass.
Both-machine Llama and MiniCPM serving/lookup/cache checks pass, as do the
wide same-B oracle, Qwen MTP/TQ regressions, full suites and typechecks.
The M4 shared B1 path also passes the pinned templated speculation oracle.
Four matched M4 arms complete; gains, cold-prefill cost and the changed
concurrent response are recorded in benchmarks.md. Main integration suite, all typechecks and full hygiene pass. Rotating target transactions remain the next storage gap.
Validation source:
`/Users/joshrossi/.cache/mlx-bun/full-kv-speculation-validation`;
evidence: `reports/qwen38-closeout/composition-baseline/full-kv-speculation/`.


### Rotating target transactions

The rotating-storage adapter now exposes independent speculative acceptance
through the existing target transaction interface. It reuses the existing
ring kernels and keeps the verification rectangle: rejected suffixes move
into masked left padding. Contracting the rectangle preserved KV columns
but failed Gemma continuation equality; that candidate was replaced.
Published rows contain the newest accepted window; ordinary ring extraction
retains its pinned-oracle oversized-block behavior. No scheduler change.

Tagged storage windows, cloning, retirement and subsequent writes pass.
Both-machine Gemma 12B lookup serving passes at B1/B4, including late joins,
consumer failures, grammar, seeded sampling/logprobs and HTTP coverage.
Both-machine Gemma target transactions pass 3,080 assertions across prompts
straddling the actual 1,024-token window, unequal acceptance and continuation.
Both-machine pinned padded-model oracle passes at B1/2/3/4/8, and
standalone draft generation restores through RAM/cold SSD. The default
lookup depth of ten exposed a singleton geometry difference; an unwrapped
single row now retains its scalar prefix geometry without adding padding.
The depth-ten serving gates now pass for Gemma 12B and e4b on both Macs.
Both final suites/typechecks pass, alongside the Qwen MTP/TurboQuant regression.
The final-source matched M4 comparison completes: concurrent throughput and
cache reuse improve, while B1 decode is effectively equal. Startup variation
and different concurrent trajectories are recorded in benchmarks.md.
The adapter is integrated; main integration suite, all typechecks and full hygiene pass. Quantized rotating
speculation and the remaining providers are still open.
Validation source: `/Users/joshrossi/.cache/mlx-bun/rotating-speculation-validation`.
Evidence: `reports/qwen38-closeout/composition-baseline/rotating-speculation/`.


### Assistant draft rows

The assistant provider now supplies the same prefill and decode row interfaces
as standalone drafting. It retains only the last true target hidden and its
processed-token count. The target layout supplies captured donor attention;
full and rotating layouts own valid intervals and masks. The draft graph does
not know the scheduler or cache geometry. Matching layers and draft steps reuse
the same donor mask. All proposals remain on device until the chain completes.
Generated checkpoints store the hidden companion alongside existing target KV,
using the same RAM ownership and queued SSD persistence.

Both e4b centroid and 12B tied heads use one graph at B1/B2/B4. The pinned
optiq loader assumes centroid presence from config; the 12B numerical test binds
its actual tied embedding head by tensor presence while retaining upstream
layers. The e4b end-to-end test uses unmodified optiq `spec_generate`. Both
machines pass these checks, serving/retirement/late joins, grammar/logprobs and
generated RAM/SSD continuations. Tagged donor columns independently verify
padding, rejected suffixes, wrap and row removal. The old contiguous transposed
weights caused a hidden-state mismatch on M4 even before this refactor. Keeping
upstream's strided weight views restores exactness and avoids duplicate weights.

The candidate is integrated after both regression suites/types and the four-arm
M4 comparison. Main integration suite, all typechecks and full hygiene pass. Throughput and cached
latency improve; readiness and concurrent-trajectory differences remain recorded
in benchmarks.md. DeepSpec follows through projected context rows.
Evidence: `reports/qwen38-closeout/composition-baseline/assistant-batch/`.


### Shared DeepSpec context rows

DeepSpec's context projections and block graph now accept the active row count.
The MLX projected-context owner reuses full-attention row storage, cache codecs
and coordinated membership. Its attention port hides context geometry and
validity from the block graph. The provider declares its target taps and stores
projected context as the ordinary method companion in RAM and queued SSD.
Accepted lengths advance each row independently; rejected context never survives
in a published checkpoint. The sequential proposal head stays on device through
the block, and serving skips unconsumed confidence values when truncation is off.

Synthetic tests cover bf16/quantized projections, confidence truncation through
zero proposals, differing commit lengths, restoration and retirement. Real Gemma
12B serving/generated RAM/SSD checks pass with both DeepSpec bf16 and its affine
4-bit sibling on both Macs, including the trained seven-token block. Native B1
full logits and confidence match the frozen implementation; B2/B4 repeat exactly
with independent positions. These comparisons are regression controls, not a new
external DeepSpec oracle: the existing Torch oracle requires a separate reference
environment and bf16 target that are not currently installed on either laptop.
Real-window checks confirm that shared speculation remains active across wrap
while the previous serial path stops drafting there. Both-machine regression
suites and all typechecks pass. Four matched M4 arms improve aggregate throughput
and cached latency; startup cost and one changed concurrent response remain
recorded in benchmarks.md. The candidate is integrated; the main regression
suite, all typechecks and full hygiene pass. DSpark/DFlash is next and shares the projected-context lifecycle.
Evidence: `reports/qwen38-closeout/composition-baseline/deepspec-batch/`.


### Shared DSpark/DFlash provider

The draft graph accepts B1 and B>1 through one backbone and sequential proposal
head. Markov and RNN heads retain their existing numerical behavior. Confidence
can retire proposals independently for each row, and sampled proposal streams
remain independent. Serving avoids confidence and float-logit outputs it does
not consume. Scheduling does not select a draft implementation.

DSpark and DeepSpec use the same projected-context lifecycle. The provider binds
projection and proposal operations; the shared owner handles prefill, accepted
lengths, row membership, capture and restoration. The MLX context store applies
padding and attention validity. Generated context enters the existing RAM cache
and queued SSD persistence as a method companion.

Pinned graph outputs and both-machine Markov/RNN real-Gemma serving/generated
RAM/SSD tests pass. Those tests use seeded draft weights, so they establish
execution and state contracts, not trained acceptance or quality. Josh confirms
that no DSpark/DFlash checkpoint has been trained yet. DeepSpec's real trained provider passes again
after the extraction. Full suites and all typechecks pass on both Macs. Four M4
arms measure the extraction using the same trained DeepSpec checkpoint and
preserve all responses and usage. The measured throughput cost is recorded in
benchmarks.md. The provider is integrated; the main suite, all typechecks
and full hygiene pass. Trained DSpark performance qualification remains open. Evidence:
`reports/qwen38-closeout/composition-baseline/dflash-batch/`.


### Affine rotating speculation and encoded assistant donors

Uniform start-zero KV4/KV8 target layouts now compose with grouped draft
providers on full-attention and rotating targets. Acceptance bookkeeping is
shared by plain and encoded rings. Packed values, scales and biases use the
same row operations; rollback, retirement and snapshots never dequantize.
Ordinary rotating extraction retains the oracle's oversized-block geometry;
committed speculative snapshots retain only the newest valid window.
Unpadded verification keeps the existing fused attention mask dispatch.
Standard universal attention and MiniCPM now consume encoded cache ports
instead of assuming plain arrays or a concrete affine cache class. The
universal softcap branch retains its existing plain-only qualification.

Assistant drafting consumes an opaque donor-attention interface. Storage owns
the encoded planes and validity ranges; the assistant only supplies queries.
Its compatibility source now adapts the same row graph at B1. The redundant
plain-only AssistantTarget interface is removed. Additive donor masks follow
the pinned affine attention operation, independently of boolean cache masks.

Native continuation controls must hold both batch size and physical attention
width fixed. The pinned Python oracle reproduces the captured different-width
full-attention results byte for byte: one bf16 output differs despite identical
queries and valid KV. The transaction test pads only the reference's fetched
views to the compared width, retaining exact state and hidden checks.
The old executor disables speculation near the rotating boundary, so its KV4
text can differ from active shared speculation. Live-window tests record that
comparison and check repeated active execution; they do not relabel ordinary
fallback as an exact speculative oracle.

Both-machine KV4/KV8 serving and generated RAM/SSD checks pass for DeepSpec,
assistant, standalone and lookup providers; seeded DSpark heads pass the same
state contracts. Real-window transactions, same-width target controls, pinned
regressions, full suites and all typechecks pass. Six M4 benchmark arms preserve
bf16 responses and usage with effectively unchanged throughput. KV4 improves
aggregate throughput on this workload, with different generated text and more
prefill time; the comparison is recorded in benchmarks.md. The change is
integrated; the main suite, all typechecks and full hygiene pass.
Evidence: reports/qwen38-closeout/composition-baseline/rotating-spec-quant/.
Strict performance dominance and removal of the serial control remain open.


### TurboQuant donor attention and grouped draft composition

Solo, packed and delayed TurboQuant storage expose the same owned donor-attention
interface as plain and affine caches. Captures preserve physical columns, row
validity and right-prefill padding without appending tokens, converting precision
or advancing membership. Assistant attention consumes eagerly decoded values,
preserving its existing operation order. MiniCPM retains its explicit deferred
value rotation. Storage chooses the existing codec and fused decode kernels;
scheduling does not identify the encoding or draft provider.

The gateway advertises grouped TurboQuant from the bound target and provider
capabilities. Positive conversion thresholds use the existing row-local
transition lifecycle; sliding layers remain bf16. Per-layer affine speculative
configuration composes through the same bound row capabilities. Group binding now snapshots per-layer and
TQ options so caller mutation cannot change a live graph or its persisted
identity. Explicit per-layer schemes get distinct group/cache keys, with
canonical layer ordering; absent/empty schemes preserve existing keys exactly.

The isolated candidate passes independent K8/V3 donor codec plus pinned assistant
graph controls at B1/B2/B4 with fused decoding on/off for both Gemma assistant
artifacts on the M4, alongside the unchanged bf16 oracle. M1 assistant and
MiniCPM lookup pass start-zero serving/generated RAM/SSD and delayed conversion,
retirement and late admission. Both-machine assistant, DeepSpec, standalone and lookup serving/generated
RAM/SSD, delayed conversion and late admission pass, along with seeded DSpark
heads, Qwen regressions, final suites and typechecks. Twelve M4 timing arms
record both source-only costs and TQ configuration tradeoffs in benchmarks.md.
The source is integrated; main suite, all typechecks and full hygiene pass.
Evidence: `reports/qwen38-closeout/composition-baseline/turboquant-donor/`.

The independent assistant control also exposed an existing centroid-head
numerical shortcut on M1: matrix multiplication did not preserve the oracle's
bf16 multiplication followed by reduction. On identical B2 hidden state, Python
reproduced the old candidate token with matmul and the oracle token with explicit
multiply/sum. The shared head now preserves that operation order at every B and
selects the lowest vocabulary ID among tied candidate scores, matching sparse
vocabulary argmax without materializing a full-vocabulary logits buffer. The
independent codec, hidden-state and token assertions remain exact. The M1 e4b
control and unmodified end-to-end optiq generation pass after the correction;
final both-machine regressions pass. The source-only and TQ timing comparisons
are recorded in benchmarks.md. Attribution repeats recover the prior decode rate on the unchanged candidate, so they do not establish a code regression. Captured diagnostics live
with the composition evidence.


### Delayed and per-layer affine rotating speculation

Rotating storage owns an accepted-column transaction shared by plain and affine rings. The generic transition interface invokes that transaction while rows have different precisions; after conversion it packs them into the existing affine layout. Conversion sees only committed tokens. Scheduling and draft providers do not inspect the quantization scheme.

Full and rotating caches expose owned donor-attention views. Mixed rows retain their physical columns, valid offsets and padding; assistants submit queries and masks without materializing a common decoded cache. Pending right-prefill padding is excluded before finalization, including when a physical block exceeds the sliding window. Captures survive cache conversion, row reordering and disposal.

The gateway now advertises supported affine configurations from the target/provider binding, including model-defined per-layer schemes and positive library thresholds. The served CLI schemes retain start zero. Independent attention fixtures cover padding and ownership; exact target hidden/logit controls cross the real sliding boundary at verification widths one and eight. Native checks cover continuation, precision transitions, unequal retirement, late admission, grammar/logprobs and generated RAM/SSD companions. Legacy serving rejects some of these combinations; repeated shared execution is not relabeled as a legacy speculative oracle.

Both-machine provider/native/suite/typechecks and six matched M4 benchmark arms are complete. Bf16 responses and usage remain exact; model-defined per-layer KV trades higher single-request decode for lower aggregate throughput on the measured workload. The change is integrated; main suite, types and full hygiene pass. Evidence: `reports/qwen38-closeout/composition-baseline/delayed-rotating-spec/`. Defaults and the serial retirement criterion remain unchanged.


### GLM compressed target and native MTP rows

The integrated implementation adds independent accepted-column transactions and cold-row membership to compressed MLA/DSA storage, without reconstructing full K/V. Native MTP exposes a shared numerical graph and a grouped provider. Its prompt prefill retains the target anchor while leaving MTP cache empty; committed accepted positions are rebuilt from true target hidden states. Target token coverage and the shorter draft-cache offset remain separate checkpoint metadata. The existing attachment interface persists both through the generic RAM/SSD cache.

Both-machine tiny-model controls cover exact B1 proposals/absorption, zero-proposal rounds, streamed expert calls, B4 membership with DSA enabled, late admission, retirement, generated-prefix identity and identical RAM/SSD next drafts. DSA verification retains every request row and shares each logical query selection across FULL/SHARED layers. Compressed multi-token attention now masks physical left padding, including native MTP absorption. Empty DSA rows survive filtering and resumed writes. Six two-layer dense/sparse boundary cases per machine match independent pinned Python/MLX hidden and every cache plane byte-for-byte. Python uses the uncompiled sigmoid/multiply activation that this model graph calls. Different-B controls retain greedy IDs but can differ in small f32 values because physical widths select absorbed/reconstructed attention and different matrix kernels; they are not the exact numerical oracle. Both full model-free suites, the SSD suite and all typechecks pass. The tested implementation is integrated in the PR. Josh has deferred final GLM-5.2 Colibri artifact testing. This does not establish real-artifact numerical or performance acceptance. Evidence: `reports/qwen38-closeout/composition-baseline/mla-transaction/`.


### Paged storage through shared row and request-state interfaces

`PagedKvRows` owns per-request block pools, immutable snapshots, gathering, masks, offsets and row membership. The existing executor binds it through the cache-layout interface. `MlxRequestStatePolicy` supplies compatible state construction and a prompt-cache port; paging selects no prefix store. Switching back to ordinary requests restores their cache port. The same paging constructor serves the compatibility entry point and shared prefill. B1 keeps the existing paged numerical graph; B>1 gathers padded attention inputs while retaining separate persistent pools. Gemma12 full sampled logits and HTTP choices match the ordinary same-B controls, including seeded sampling, logprobs and grammar. Both-machine model-free, SSD and typechecks pass. The native storage comparison fixes cohort membership and snapshot boundaries on both sides, covering small blocks and the default block boundary; otherwise cache publication changes the numerical prefill graph. The matched M4 source comparison is effectively flat, and shared paging improves concurrent throughput versus serial while retaining effectively equal B1 decode. Concurrent text can differ across batch geometries; the exact storage oracle compares the same geometry. Timing and limitations live in benchmarks.md; evidence is `reports/qwen38-closeout/composition-baseline/paged-rows/`. Paged attention kernels, block-level prefix sharing, quantized paging and speculative paging remain separate work.

The sampler now exposes an optional stateless operation for compatible independent score rows. Ordinary decode and speculative verification share normalized-score argmax. Verification can sample a rectangle in one device operation and readback; acceptance still consumes only each request's valid positions. Grammar, processors, stochastic sampling, logprob capture and custom sampler functions retain their request-local operation. Same-shape numerical tests include rounding-created ties and large vocabularies; both-machine native/generated RAM/SSD and suites pass. Twelve matched M4 arms preserve ordinary throughput and improve lookup aggregate throughput; startup and trajectory limits are recorded in benchmarks.md. Lookup defaults remain unchanged. Evidence: `reports/qwen38-closeout/composition-baseline/independent-sampling/`.


### Campaign checkout consolidation

The PR incorporates the accepted implementations from the M1 and M4 campaign
checkouts, including ordinary resume, adapter-aware resume and GLM shared MTP
state. Older TQ, provider, cache and prefill candidates are superseded by the
integrated compositions above. Benchmark baselines and rejected wider-Trellis,
option-capture, state-only replay and cohort scheduling variants remain
experiment records; copying them over the selected implementation would undo
later work. The singleton `copyOf` to `contiguous` candidate remains unpromoted
because its attribution and startup result are unresolved.

The 80 secondary Git worktrees and 99 campaign source copies were removed
after their source files and reports were verified in a content-addressed local archive under
`reports/pr-closeout/checkout-archive/`, with per-checkout manifests, SHA-256
objects and the recorded base commit. The PR retains the implementation and
findings; bulky raw experiment data stays local under the repository policy.


### Scheduling reference algorithms and request observations

The next scheduling baseline is an iteration token budget, following the
upstream implementations below. Review date: 2026-09-12. Read implementation
order as well as configuration docs; scheduling first does not necessarily
mean delivering output before the iteration's other GPU work finishes.

| Reference | Algorithm and ownership | Application here |
|---|---|---|
| [vLLM V1 scheduler, `dff76bc`](https://github.com/vllm-project/vllm/blob/dff76bc3e8d702901e6dda5971f9506a6c1bc00f/vllm/v1/core/sched/scheduler.py#L562) | Tracks computed tokens against required tokens, including speculative positions. Allocates the iteration budget to running requests before waiting requests. Prefill chunks and decode tokens can enter the same execution batch. | Represent remaining work through the scheduling interface; methods supply valid token work and the backend owns batch packing and kernels. |
| [llama.cpp server, `3057bb6`](https://github.com/ggml-org/llama.cpp/blob/3057bb66c86c46d5781e50e85462a760ba7d1feb/tools/server/server-context.cpp#L2974) | Adds generating/drafting slots before filling the remaining batch capacity with compatible prompt tokens. Logical batch and physical microbatch capacities are distinct. HTTP workers own parsing, templates and streaming; one inference thread owns slots. | Preserve execution ownership while allowing request preparation and response transport to progress independently. A shared request count is insufficient; account for token work too. |
| [mlx-lm generator, `dcbcf78`](https://github.com/ml-explore/mlx-lm/blob/dcbcf786c0cf56f9a12fabe9468c887781431ae2/mlx_lm/generate.py#L1783) | Advances generation first, admits/splits prompt rows, then processes bounded prompt chunks. Prompt and generation batches remain separate. Responses return after prompt processing, whose cache evaluation synchronizes. The pinned oracle has the same order. | This is the closest numerical/backend reference, but its response timing is not evidence that output is immediately flushed. Compare its actual request timeline. |
| [LangChain streaming](https://docs.langchain.com/oss/python/langchain/streaming) | Routes model-provided text, reasoning and tool-call chunks through the agent application. | Reference for stream semantics; this layer does not select GPU prefill/decode work. |

[vLLM's tuning guidance](https://docs.vllm.ai/en/latest/configuration/optimization/#chunked-prefill)
explicitly treats token budget as a latency/throughput tradeoff. Its GPU-specific
budget recommendations are not Apple Silicon defaults. Start with the established
algorithm, measure the same submitted work on M4, and retain deviations only
with recorded benefits and costs. No framework guarantees one universally best
chunk size or latency policy.

The established backend exposes `advance()` and `advancePreparation()`
operations. `MlxPrefillRows` groups prompt rows, while ordinary and speculative
methods advance decoding rows separately. The existing preparation budget limits
cohort admission; it is not vLLM's combined per-iteration token budget. True mixed
execution therefore needs backend work as well as scheduling policy. Padding a
single decode token to a long prompt's width would defeat the intended saving.

Phase 18 S1b adds bounded mixed work. The method retains request identity,
computed/required positions and candidate state. Scheduling allocates
bounded work to active requests and then queued requests; the backend executes
compatible selections. Sampling and cache ownership remain unchanged. Acceptance
covers lone requests, arrivals during prefill and decode, unequal lengths,
cancellation/retirement, speculative work and quantized state. Compare first
semantic output, inter-output gaps, total workload time, occupancy, padding and
memory alongside aggregate throughput. Same-B numerical contracts remain binding.

The P2R observer now separates row preparation, forward, remaining cache
execution, maintenance, checkpoint capture, projection, completion and companion
work. Shared work IDs and process-local time origins allow cross-request
attribution without counting shared GPU work several times. Bounded initial
routing spans expose hidden control tokens. Measurement semantics and the report
command live in [server-config](../reference/server-config.md); measured results
live in [benchmarks](../reference/benchmarks.md#prefill-observation-and-scheduling-screen).
The simple active-before-prefill experiment remains an unadopted patch in the
local report directory; it is not the mixed execution design above.


#### Mixed token execution

The Lab Gemma and Qwen3.5/3.8 paths execute running decode and queued prompt work together.
`ExecutionGroup.mixedPreparation` reports running-token demand and the minimum
prompt work needed for progress. The scheduler reserves that demand and assigns
the remaining iteration budget to preparation. Existing cohort admission still
accounts for total prompt work. Removing that limit was measured and rejected:
on this M4 workload, larger cohorts lost throughput and delayed later first
outputs. Both variants execute the same bounded mixed-token model port.

`MlxPreparationWork` carries a token allowance and forward operation into the
shared preparation driver. It limits actual tokens across rows while preserving
planned precision conversions and checkpoint endpoints. `runMixedTokenIteration`
collects the preparation and decode forward inputs. The model's `MixedTokenModel`
port receives independent `TokenGroup` inputs with their existing row geometry
and caches. Decode finishes sampling, publication and retirement before a
completed preparation can join the active rows. A restored or cancelled
preparation can finish without producing model work; an exhausted decode can
publish its pending token without another forward.

Gemma reuses its existing attention and feed-forward layer interfaces. Attention
retains each group's RoPE positions, masks, SDPA shape and cache operations.
`mapPackedTokens` concatenates only real tokens for the feed-forward block and
restores each group's output shape afterwards. It adds no padding or host
readback. This is shared feed-forward execution, not a fully packed attention
kernel. The unpacked control keeps the same scheduler budget to isolate the
packing benefit. The original single-group model call remains unchanged.

Packing can change GEMV/GEMM dispatch relative to solo generation. The numerical
contract therefore uses the pinned oracle with the same packed feed-forward
geometry and independent attention shapes. The real-model test passes on M4 for
Gemma e4b, 12B and 26B with bf16 and uniform affine KV4, continuation, and unequal
decode/prefill row counts. The
uniform-KV oracle explicitly uses stock quantized SDPA on both sides. Native
state tests also cover bounded preparation with immediate and delayed affine
and TurboQuant conversion. Failure, cancellation and retirement tests exercise
the shared execution group and the work coordinator.

Qwen reuses its attention/DeltaNet and feed-forward blocks through the same
model port. Masks, convolution tails and recurrent state remain per group;
layer evaluation materializes both residual and cache outputs to bound prefill
memory. Each `TokenGroup` can supply a borrowed layer-capture callback and
request preservation of its matmul geometry. Speculative methods use those
options for target verification, including pending tokens and draft candidates,
and keep provider companion updates in their preparation/verification adapters.
The scheduler sees the method’s target-token demand, not its draft algorithm.
Hidden captures belong to each work item instead of a shared mutable model tap.

The measured default decision is to retain mixed execution as opt-in. Gemma
first-output latency improves with an aggregate-throughput cost; Qwen MTP has
no first-output win and loses aggregate throughput, despite a shorter worst
streaming pause. This closes the bounded S1b comparison. Trace phase
`engine.mixed_forward` records the model-call construction span and real token
counts; GPU waits remain at the existing evaluation/readback boundaries. The
[measured comparison](../reference/benchmarks.md#mixed-prefill-and-decode-token-work)
records latency, throughput, streaming gaps and the unpacked control. Runtime
settings live in [server-config](../reference/server-config.md).


### Grammar candidates through the shared verifier

`GrammarController.proposeTokens` reads xgrammar's forced continuation without
advancing the matcher. It joins the existing WASM queue so concurrent requests
cannot overlap calls into the single WASM instance. A request-owned constraint
port supplies candidates to the same grouped verifier used by learned drafts
and prompt lookup. The sampler applies each request's mask and commits its
accepted tokens; scheduling only sees method work. Target graph binding no
longer requires a serial draft constructor.

The constraint provider reuses prompt lookup's committed-history ownership and
checkpoint format. It never searches history and has no serial draft method.
Empty candidate lists use the verifier's existing one-token step. Candidate
rejection and row retirement keep target and companion state aligned through
the existing transaction and output interfaces.

`MLX_BUN_GRAMMAR_JUMP=1` selects this method for eligible shared structured-output
requests without a configured drafter; `MLX_BUN_GRAMMAR_DRAFT_TOKENS` controls
depth separately from batching. Shared logprobs remain available because every
output is sampled. Explicit serial retains direct retokenized jump-forward.
That algorithm skips target sampling for forced spans; the shared proposal
algorithm verifies them. Both remain opt-in and must be compared separately.

The focused MiniCPM and packed-Qwen checks cover nonmutating proposals, B1 and
concurrent requests, independent stopping/cancellation, affine/TurboQuant and
logprob delivery. Fixed bf16 MiniCPM outputs match ordinary decoding. Affine
MiniCPM can choose different valid tokenizations across verification widths;
repeated fixed-configuration outputs match. Same-geometry verifier/KV oracles
remain the numerical contract. Performance is recorded in benchmarks.md.
