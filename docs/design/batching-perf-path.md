# Batching perf path — promote continuous batching out of compat mode

Status: P5 + two gate fixes LANDED (2026-07-02, same day). Since then
(2026-07-03, executed via grammar-spec-batching-integration.md Phases D/E):
the **P3 KV-budget admission slice LANDED** (`--kv-budget` aggregate
projection gate, queue-don't-OOM,
`/stats.batch.{pending_rows,kv_bytes,kv_budget_bytes}`,
tests/batch-kv-budget.test.ts) and the **P0 bench harness LANDED** as
`scripts/bench-feature-matrix.ts` (the six-cell composition matrix;
`scripts/bench-serving-load.ts` stays a client-only stack-vs-stack tool).
Also 2026-07-03: **Tier-0 universal models (plain full-attention, e.g.
Llama) now batch** — per-row RoPE ported (`UniversalRope.applyDynamic`)
and gated token-exact vs mlx-lm B=2
(tests/batched-decode-parity.test.ts "Llama 3B Tier-0"); maskArray +
sliding universal archs stay serial (unvalidated cells). Rest PLANNED —
P0 COMPLETED 2026-07-04: extend-join (full-attention; own mlx-lm extend oracle) + vectorized all-greedy sampling (BIT-equal A/B).

**Headline result (M1 Max 32 GB, loaded machine, 4 concurrent × 128 tok,
median of 3, wall-clock aggregate; oMLX 0.4.5.dev1, same OptiQ snapshots):**

| Model | oMLX | mlx-bun `--batch 4` | mean TTFT (theirs/ours) |
| --- | --- | --- | --- |
| MiniCPM5-1B | 339.0 | **345.4** | 397 / **119 ms** |
| gemma-4-e4b | **89.8** | 87.1 (−3%) | 815 / **397 ms** |
| Qwen3.5-4B | **100.9** | 99.5 (−1%) | 848 / **368 ms** |

What landed (all bit-gated, `tsc` 0, suites green):
1. **P5 — SSM batched path** (`SSMCache.mergeRows`/`filter` in
   `src/model/qwen3-delta.ts`; "ssm" kind in `batch-scheduler.ts` merge/wrap/
   filter; per-row RoPE via `ropeOffsetArr` in `qwen3_5.ts`; gate relaxed in
   `generation-gateway.ts`, kill switch `MLX_BUN_BATCH_SSM=0`). Oracle:
   `tests/qwen35-batched-parity.test.ts` — solo-prefill+merge batched greedy
   is **token-for-token identical** to mlx-lm B=2 left-padded batch
   (`goldens/apple-m1-max/batched-golden-qwen35.json`). No ssm_mask needed:
   rows solo-prefill unpadded, decode feeds one real token per row.
2. **Logits processors batch** (`generation-gateway.ts`): the per-row sampler
   folds `makeLogitsProcessors` over a per-row device-side token history
   (generate()'s pushHistory), so repetition/presence/frequency penalties +
   logit_bias + min_p/XTC no longer route serial. Load-bearing discovery:
   **Qwen3.5 ships a default repetition penalty in generation_config.json**,
   which routed EVERY request serial under `--batch N` — the SSM port alone
   changed nothing over HTTP until this landed.
3. Diagnostic breadcrumb: `MLX_BUN_LANE_DEBUG=1` logs per-request lane
   decisions + shape (server.ts) — how (2) was found.

Bench-method traps found while measuring — **both FIXED 2026-07-02**:
- `serve`/`bench` accepted `--model` but IGNORED it (positional-only fuzzy
  query; auto-pick silently loaded the wrong model). Now: `--model
  <path-or-query>` is an explicit override — a directory with config.json
  loads via `scanSnapshot` (no registry dependency), anything else resolves
  like the positional. Precedence: `--model` > positional > `--query` >
  auto-pick.
- Event-loop starvation during generation was the SERIAL lane, not batch
  (batch's drive loop yields per step — `/stats` answered in ~8 ms mid-
  generation once measured properly): serial decode is an unbroken microtask
  chain, so `/stats`//health/new accepts stalled for the whole generation
  (measured 2.5 s on a 512-token run). Fixed with a ≥25 ms rate-limited
  macrotask hop wrapped around onToken in `GenerationGateway.run`'s serial
  branch — covers all four API surfaces, streaming and not. After: `/stats`
  10–44 ms mid-generation, decode unchanged (cpm5 serial 193 tok/s). Motivated by the oMLX head-to-head (M1 Max,
2026-07-02): at 4 concurrent requests oMLX's continuous batching gets
1.46–1.89× our aggregate throughput (Qwen3.5-4B 97.3 vs 66.5 tok/s;
MiniCPM5 328 vs 173; e4b 85 vs 52) and our mean TTFT queue-inflates to
1.1–3.8 s. Single-stream we match or beat them (e4b 55.8 vs 53.7,
Qwen3.5 66.3 vs 63.9, TTFT 3–7× better everywhere); the gap is entirely
the serial lane going flat under parallel load. Full comparison + numbers:
the 2026-07-02 oMLX report (Claude artifact) and `~/.omlx` bench scripts.

Design stance: the batch lane grows the **same parity-tier DAG as the
serial lane** (docs/design/parity-tier-dag.md). `--l1 --batch N` stays
bit-exact mlx-lm-B=N compat mode forever (the oracle checkpoint); the
default/`--l3` batch path becomes the optimized one. `--batch` remains a
mode switch, not a load fallback.

## 1. Current state

`src/serve/batch-scheduler.ts` (`BatchScheduler`) is a real
continuous-batching engine: iteration-level scheduling, pipelined decode
(`#step` via `ops.asyncEvalAll`, mlx-lm `GenerationBatch._step`
semantics), chunked joiner prefill (2048-token chunks) interleaved with
decode, per-row eviction (`filterKVRows` / `BatchedRotatingCache.filter`),
per-row failure containment, drain-on-serial-waiter, `clearCache` every
256 steps. Bit-parity with mlx-lm B=N verified at B=2 across all 4 model
paths (`tests/batched-decode-parity.test.ts`, `tests/batched-rotating.test.ts`,
`tests/batch-scheduler.test.ts`) — plus, since 2026-07-03, Tier-0
universal plain-full-attention archs (Llama 3B, token-exact vs mlx-lm B=2;
see header).

`src/serve/generation-gateway.ts` (`GenerationGateway.willBatch`) routes;
one `AsyncMutex` is the GPU/`loraState` exclusion domain. The batch lane
is deliberately compat mode: it calls `model.forwardHidden` /
`logitsFromHidden` directly, bypassing `generate()` and every perf lever.

### Levers the batch lane lacks, and why

| Lever | Serial mechanism | Why batch can't use it today |
| --- | --- | --- |
| Quantized KV (`kv_config`) | `maybeQuantizeKv` (`src/generate.ts:101`) | `QuantizedKVCache` (`src/model/gemma4-base.ts:419`) has no dynamic-B ops (no merge/filter/extend/temporalView over the packed/scales/biases triples); `willBatch` hard-gates `kvQuant` → serial |
| Perf-kernel fused decode SDPA | dispatched from `quantizedSdpa` (`gemma4-base.ts:1560`) | kernel M=1-specialized: `fused-decode-kernel.ts:262` rejects `B !== 1 \|\| L !== 1`, and requires empty mask (batched decode needs per-row left-pad validity) |
| Fused N-tiled SDPA (`--fused-decode`) | `quantizedSdpaTiled` | needs 2-D mask; batched masks are 4-D `[B,1,1,S]` (`buildBatchedDecodeMask`); quantized-only anyway |
| Compiled decode | `CompiledDecode.for()` (`generate.ts:518-525`) | trace is `[1,1]`; B changes every join/evict |
| Prompt-cache prefix reuse | `PromptCache.take/put` in `runGeneration` | bypassed by design in v1; every batched row solo-prefills (`cachedTokens: 0`) |
| Vectorized sampling | n/a | `#step` samples per row (B slice+sample+concat graphs per token) |

Two more gap sources specific to the benchmark:

- **Qwen3.5 never batches at all** — **FIXED by P5 (2026-07-02, header
  item 1)**: `SSMCache.mergeRows`/`filter` landed; Qwen3.5 batches
  token-exact vs mlx-lm B=2.
- Joins re-merge the whole batch (O(B·S) slice storm, `#mergeJoiner`)
  instead of mlx-lm's `extend`.

## 2. Gap analysis: quantized KV + fused kernels at B>1

- `QuantizedKVCache` already stores `[B,H,S,D']` triples; missing is
  dynamic-B surgery. New `src/model/batched-quant.ts`:
  `BatchedQuantizedKVCache` = quantized twin of `BatchedRotatingCache`
  (merge/extend/filter/extract/temporalView = the `mergeKVRows`/`filterKVRows`
  B-axis ops from `src/model/batched-mask.ts:171,196`, applied to all three
  triples). Left-pad must align to quantization group boundaries — pad in
  whole 256-token STEP granules (both caches already grow in STEP=256).
- Conversion point mirrors `maybeQuantizeKv`: row solo-prefills bf16,
  `toQuantized` per layer per `kv_config` before merge.
- **Scope cut**: shipped `kv_config.json` quantize full-attention layers
  only ⇒ P1 = quantized full layers + bf16 `BatchedRotatingCache` sliding
  layers (the serial `config` composition). Batched rotating-quant deferred.
- Correctness fallback: `quantizedSdpaUnfused` (`gemma4-base.ts:1273`) is
  already B-generic with `mask.mode === "array"`; needs the batched mask
  broadcast as `[B,1,1,1,N]` for the 5-D GQA score reshape.
- Perf kernel at B>1: (1) drop the `B !== 1` gate (keep `L !== 1`);
  (2) grid gains a B axis (`[TG_THREADS, H·B, G]`), `SCORE_ROW` offsets
  index `((b·KV + kv)·N + n)`; (3) replace the empty-mask requirement with
  a per-row `leftPad` int32 `[B]` input — each row's n-loop starts at
  `max(blockStart, leftPad[b])`, so pad bytes are never read.
- RoPE per-row positions already solved (`ropeOffsetArr`, the S1b.1 fix).

## 3. Phases

### P0 — Baseline + engine quick wins (no new numerics)  [S–M, 2–4 days]
- Bench harness — **DONE 2026-07-03**: landed as
  `scripts/bench-feature-matrix.ts` (six-cell composition matrix over live
  SSE, TTFT p50/p95 + aggregate tok/s; integration-plan Phase E).
  `scripts/bench-serving-load.ts` exists as the client-only stack-vs-stack
  tool and stays one. Clean-machine run remains Josh-gated.
- Land `extend` join (full-attention twin + `BatchedRotatingCache.extend`);
  oracle: extend `scripts/gen-batched-dynamic-golden.py` (mlx-lm `extend`).
  **LANDED 2026-07-04** for full-attention layers (`extendKVRows`,
  mlx-lm `BatchKVCache.extend` semantics; own oracle
  `scripts/gen-batched-extend-golden.py`, token-for-token CPM + Llama;
  `MLX_BUN_BATCH_EXTEND=0` = re-merge). `BatchedRotatingCache.extend`
  (sliding layers on Gemma joins) remains open.
- Vectorize the homogeneous-sampler fast path in `#step` (all-greedy →
  one `ops.argmaxAxis` on `[B,V]`); mixed rows keep the loop. **LANDED
  2026-07-04** (BIT-equal A/B, `MLX_BUN_BATCH_VEC_SAMPLE=0`;
  tests/batch-vec-sample.test.ts).
- Exit: gated suites unchanged; B=4 baseline recorded; joins not O(B·S).

### P1 — Quantized KV at B>1  [M–L, 1–1.5 wk]
- `src/model/batched-quant.ts` + scheduler wiring (layer kind
  `"full" | "rot" | "qfull"`); solo-prefill bf16 → `toQuantized` → extend.
- Batched mask 5-D broadcast; validate `quantizedSdpaUnfused`.
- `willBatch`: `kvQuant` stops being a serial gate when quant layers are
  full-attention-only.
- Exit (parity ladder; no external oracle — mlx-lm quant batching NYI):
  (1) B=1-row batched-quant **bit-exact vs serial `--kv-quant config`**;
  (2) row-isolation within the calibrated bf16-reduction envelope;
  (3) KL vs batched-bf16 ≤ serial quant-vs-bf16 KL; 6-task eval unchanged;
  (4) `--l1 --batch N` suites untouched.

### P2 — Perf kernel at B>1 + fallback matrix  [M, ~1 wk]
- Kernel edits per §2; dispatch when every row supported, else unfused.
- Fallback matrix documented in server-config.md.
- Batched frozen-oracle envelope (B=2/4 `freeze-perf-oracle` variant,
  ≥56/64 per row, `tests/perf-kernel-oracle.test.ts` pattern).
- Exit: dispatch counter proves engagement; envelope green; measured
  uplift at B=4 vs P1 unfused on a clean machine; if <5%, ship the
  fallback matrix only and close honestly.

### P3 — Admission, prompt cache, adapters, defaults  [M–L, 1–1.5 wk]
- KV-budget admission — **LANDED 2026-07-03** (integration-plan Phase D):
  `--kv-budget <GB>` caps the batch's aggregate projected KV
  (prompt+max_tokens per row, window-capped); over-budget joiners QUEUE
  (FIFO), never OOM; a single request over the budget alone rejects with
  an actionable error; `/stats.batch.{pending_rows,kv_bytes,kv_budget_bytes}`;
  gated by tests/batch-kv-budget.test.ts. `--prompt-concurrency` still open.
- Prompt-cache reuse under batching: `take` at admit, forward uncached
  tail; on finish/evict `extract(row)` → solo caches → `put`. Quantized
  entries are non-trimmable mid-group — match on full-prefix or STEP
  boundaries. Real `prefillMs/decodeMs`; `BatchStats.cachedTokens` real.
- Single-adapter batches: adapter-spec = batch compatibility key
  (join if match, drain if not; `loraState.active` set once per epoch).
- Default review: if batch lane at 1 live row is within ~2% of serial,
  propose flipping the shipped default to `--batch 4` (Josh decision,
  numerics change vs serial default); else README recommends `--batch 4`
  for agent workloads.
- Exit: TTFT p50 <500 ms / p95 <1.5 s at 4 concurrent short prompts;
  `cached_tokens>0` on repeats under `--batch 2`; oversized-request
  queueing test (no OOM); B=4 aggregate within 15% of oMLX on cpm5 + e4b.

### P4 — Burst decode  [REVISED after reading + porting oMLX's source]
- **oMLX-style event-loop bursting: BUILT AND REFUTED (2026-07-02).** Read
  their actual implementation (`omlx/engine_core.py _step_burst` — full
  source ships in `/Applications/oMLX.app/Contents/Resources/omlx/`): it is
  NOT a GPU trick — it runs K `scheduler.step()` calls per
  `run_in_executor` hand-off with adaptive time budgets (100 ms single /
  30 ms concurrent, 64-step cap) because each per-token hand-off ping-pongs
  the GIL with asyncio/uvicorn (~1 ms/token; their comment: 80 vs 74 tok/s).
  Ported faithfully to `BatchScheduler.#drive` and measured: **regression**
  — cpm5 B=4 345→289, batch-lane B=1 149→121, TTFT +~100 ms (SSE flushes
  wait out the budget). Bun's `setImmediate` hop costs microseconds — no
  GIL to dodge — so the port kept the cost and lost the win. Reverted;
  numbers restored (cpm5 B=4 349.1). Breadcrumb comment left at the drive
  loop. This also explains their ~21-token SSE bursts (measurement trap in
  the comparison report).
- **Still open (different mechanism, not refuted): device-side step
  chaining** — generalize `generateInner`'s pipeline to depth k (k chained
  step graphs fed device-side, one host sync per k tokens). That attacks
  OUR real per-token cost (FFI graph-build + sync readback), which is not
  what oMLX's burst attacks. Exit unchanged: bit-exact vs depth-1, cpm5
  single-stream gap vs oMLX (178 vs ~214) is the target; no regression at
  k=1.

### P5 — SSM batched path (Qwen3.5)  [DONE 2026-07-02 — see header]
- Landed in one day, much cheaper than the ~1 wk estimate: `ssm_mask` under
  left-padding turned out unnecessary (our join model solo-prefills unpadded,
  so SSM state never sees a pad token; mlx-lm's masked-pad prefill is
  equivalent — proven by the token-exact oracle match). Batch ops are plain
  B-axis concat/take on the two state slots.
- Bonus fix that the exit benchmark forced out: logits processors now batch
  (per-row fold; Qwen3.5's default repetition penalty had been routing every
  request serial). Exit numbers in the header table.

Ordering: P1→P2 strictly ordered; P4 and P5 independent (P5 first if the
Qwen3.5 headline matters most). Total ~5–6 wk serial, ~4 wk with P4/P5
parallel.

## 4. Risks

- **No external oracle for quant-batched** — mitigated by the P1 parity
  ladder; `--l1 --batch N` stays the always-reachable bit-exact checkpoint.
- **Metal kernel at B>1**: leftPad start-index never touches pad bytes;
  no atomics (deterministic); gate = batched frozen-oracle envelope +
  dispatch assertions + A/B vs unfused.
- **Memory**: B× quant caches + prompt cache + weights on 24 GB — P3
  admission is the backstop; mirror mlx-lm's
  `trim_to(total − activeBatchBytes)` so LRU and live batch share one
  ceiling. GPU OOM is uncatchable — queueing test before default changes.
- **Ring-wrap at B>1 short-context-verified only**: land a long-context
  bf16 batched golden before any P3 default flip. Quantized rotating out
  of scope.
- **Default flip changes numerics** vs today's serial default — explicit
  Josh decision with doc trail.
- **Benchmark hygiene**: quotable numbers via `bench-serving-load.ts` on a
  clean machine; TTFT at the SSE first-token event, not server-side
  (oMLX's own server log over-reports by excluding ~180 ms/req cache
  bookkeeping — measure them wall-clock only).
- **Regression fence**: all existing gated batch suites + the serial suite
  green unchanged at every phase.
