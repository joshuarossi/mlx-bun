# Parallel slots — configurable batched serving

Status: **design + phasing** (S0 landed; S1+ not started)
Owner: serving layer
Default: **off** (`--slots 1` = today's serialized path, untouched)

## Goal

Let the server process more than one generation request concurrently,
gated entirely behind a `--slots N` flag. `N=1` runs exactly what we
have today (the serialized promise chain). `N>1` loads a batch
scheduler that runs multiple sequences through one forward pass.

This is a server-path feature — serving speed is the user metric.
Direct/embedding mode stays batch=1.

## Why it helps (and when it doesn't)

The win is **throughput via memory bandwidth**. Decode on Apple Silicon
is bandwidth-bound (~273 GB/s on the M4 Pro): every token streams the
entire weight set through the GPU to produce one token. Batch B
sequences and you stream the weights **once** to produce **B** tokens.
Aggregate tok/s scales ~linearly until the compute roofline.

The crucial design point — **continuous batching, not static
batching**:

- *Static batching*: form a batch, run to completion, then accept the
  next. A request arriving mid-flight waits for the whole batch to
  finish. This is the wrong design; do not build it.
- *Continuous batching* (iteration-level scheduling): the scheduler
  works per **decode step**. After each token it can inject a
  newly-arrived request (after a short prefill) and retire finished
  ones. A late request does **not** wait for the in-flight one to
  finish — it joins at the next step.

So the benefit window is "any time two requests are alive in the same
wall-clock window" — not "a backlog has formed." Because generations
last seconds, requests overlap even at modest rates (Little's law:
concurrent ≈ arrival_rate × mean_generation_time).

When it does **not** help: traffic so light that requests never overlap
in time. Then there's only ever one live sequence and batching is idle
— which is exactly why `--slots 1` is and stays the default.

## Current code: what's batch=1 and what isn't

Good news: the hot path is already written over a batch dim `B`.

- `Attention.forward` reads `const [B, L] = x.shape` and threads `B`
  through every reshape/transpose/SDPA — `src/model/gemma4.ts:152`.
- `KVCache` stores `[B, H, S, D]` and grows/slices generically —
  `src/model/gemma4-base.ts:204` (STEP=256 growth).
- The byte-capped LRU prompt cache already accounts bytes, not count —
  `src/prompt-cache.ts` (the precedent for a byte-budgeted KV pool).

`B=1` is baked into a finite, findable set of places:

| Location | Hardcoded |
| --- | --- |
| `src/generate.ts:295,315,378` | prompt/decode tensors built `[1, L]` / `[1, 1]` |
| `src/generate.ts:320,235` | `hLast` slice `[1, …]`; `sampleStep` reshape `[1, V]` |
| `src/generate.ts:247` | sampler history `[1]`, one sampled token/step |
| `src/model/gemma4.ts:647-653` | per-layer-input reshapes `[1, L, …]` |
| `src/model/gemma4-base.ts:210` | **one scalar `offset` per cache, shared across rows** |
| `src/model/gemma4.ts:174,206` | **scalar RoPE offset** for the whole batch |
| `src/model/gemma4-base.ts:256` | `makeMask` from that single offset (returns empty mask at N=1) |

## The one genuinely hard problem: per-sequence position

Batched sequences are different lengths and at different decode
positions, but the cache has a single `offset`, RoPE takes a scalar
offset, and the mask is built from one offset.

Solution (mlx-lm's, and ours): **left-padding + per-row mask + per-row
RoPE offsets.**

- Right-align every sequence so "the current token" is the same column
  for all rows → one global advancing offset still works.
- Pad on the left; mask the padding with a real `[B, 1, 1, S]` boolean
  mask — **even at the N=1 decode step**, which today returns an empty
  mask (`gemma4-base.ts:257`). That shortcut is the first thing to change.
- RoPE positions become a per-row vector. **We already have the
  primitive**: `ops.ropeDynamic` + the `cache.ropeOffsetArr` array-offset
  path (`gemma4.ts:179,206`), currently used only by compiled decode.

Highest-risk sub-item: Gemma3 alternates sliding-window
(`RotatingKVCache`) and full-attention layers. Per-row offsets through
the ring cache's wrap semantics is the trickiest mask math in the
project. Validate the full-attention mask path first; bring sliding
layers online separately under teacher-forced parity.

### Reuse: batched PREFILL already exists (big de-risk, found 2026-06-14)

The training path already solves batched padded forward and proves it:
- `src/train/forward.ts` — `buildBatchedPadMask(B, L, validLengths, window)`
  builds the `[B,1,L,L]` mask (causal AND per-row key-validity, per distinct
  window) and `BatchedMaskCache` routes it through the stock attention by
  wrapping a real cache and overriding only `makeMask`. Comment confirms
  "KVCache/RotatingKVCache are already shape-generic over B."
- `tests/train-batch-e2e.test.ts` proves a B=2 padded forward's per-row loss
  equals two independent B=1 forwards within bf16 tolerance — i.e. the mask
  makes a real row's logits independent of the other (padded) row. That is
  exactly the teacher-forced gate S1 needs, already passing.
- `tests/train-batch.test.ts` unit-tests the mask (fast, no model).

So batched **prefill** is ~done and reusable (offset-0, right-padded). The
genuinely new work is batched **decode**: a growing per-row KV with per-row
offsets, per-row RoPE (array-offset path), and a per-row N=1 key-validity
mask. First decode brick landed 2026-06-14: `src/model/batched-mask.ts`
`buildBatchedDecodeMask` (left-padded, nonzero-offset counterpart) +
`tests/batched-decode-mask.test.ts` (fast). The two mask builders consolidate
when prefill is wired into serving (S1a).

### S1b decode: design traps & sequencing (found 2026-06-14)

Reading the attention path surfaced two real subtleties — the kind that
produce plausible-but-wrong logits, so flagged before writing the cache:

1. **Prefill/decode padding conventions differ.** Training's batched prefill
   RIGHT-pads (real tokens left-aligned, positions 0..len-1 → scalar RoPE
   offset 0 is correct). Batched decode wants LEFT-padding (rows right-aligned
   so every row's next write lands in the same column → one advancing offset).
   Left-padding then forces **per-row RoPE** (real position = column −
   leftPad[b]) via the array-offset path, and means the prefill KV must be
   re-laid-out (right-aligned) before decode. First cut: prefill each request
   solo, copy its KV into the right-aligned row of a shared `[B,H,Smax,D]`
   decode buffer, then batch the decode.
2. **RoPE offset-timing trap (FIXED 2026-06-14).** `Attention.forward` read
   `cache.ropeOffsetArr` twice — for K *before* `updateAndFetch` and for Q
   *after* it (gemma4.ts ~179 vs ~195/201). Since `updateAndFetch` advances
   `offset`, a per-row position array derived from the live offset would give
   K and Q different positions. Fixed by capturing `offsetArr` once alongside
   `offset` (line ~174). Behavior-preserving (real caches leave it unset;
   compiled-decode passes a constant) — verified bit-exact against
   `tests/compiled-decode.test.ts` (12B, 7/7).

**Sequencing (parity gate first, on the riskiest piece):**
- **S1b.1** — gated teacher-forced *decode* parity harness: manually assemble a
  left-padded 2-row KV from two solo prefills, run K batched decode steps with
  a `BatchedDecodeMaskCache` (delegates KV, returns `buildBatchedDecodeMask`,
  exposes per-row `ropeOffsetArr` pinned to the pre-write offset), and assert
  each row's logits match its solo greedy decode within bf16 tolerance. Gated
  behind an opt-in env + local weights (like `train-batch-e2e`). Isolates
  decode-batching numerics from the prefill-assembly plumbing.
  **DONE 2026-06-14** — `BatchedDecodeMaskCache` (src/model/batched-mask.ts) +
  `tests/batched-decode-parity.test.ts` (`MLX_BUN_TEST_BATCH_DECODE=1`,
  MiniCPM5-1B). Passes: the unpadded row is **bit-exact** vs its solo decode
  (batching isolates rows); the left-padded row matches within bounded bf16
  reduction-order noise (≤0.23, stable over 8 steps — the shared buffer shifts
  its keys by leftPad columns, so the attention sum accumulates in a different
  order). **The gate earned its keep**: it caught `LlamaAttention`
  (src/model/minicpm5.ts) roping Q/K with the scalar `cache.offset` and ignoring
  `ropeOffsetArr` → left-padded rows mis-positioned (logit diff 8.7). Fixed to
  use the dynamic array-offset path when present; MiniCPM5 solo parity stays
  bit-exact vs the oracle. (Gemma4's `Attention` already had the array path; its
  capture-once fix is verified bit-exact vs compiled-decode.) Lesson: each model
  family's attention needs the per-row offset path wired separately.
- **S1b.2** — production KV assembly (solo prefill → left-aligned decode buffer).
- **S1b.3** — scheduler + B-token/step generate loop + per-row stream fan-out.

### The validation matrix — 3 parity layers × every model path

**Current state (2026-06-14).** Roster: **CPM (MiniCPM5-1B) + 3 Gemmas
(e4b / 12B / 26B)**. Every NEW model family (e.g. **Qwen**, planned) adds its
OWN handler path and its own copy of the three layers below — nothing here is
generic. This matrix is a snapshot; re-derive it when the roster changes.

mlx-bun runs every model at one of **three correctness layers**, and must always
**degrade gracefully down the ladder (L3 → L2 → L1)** — that's what the kernel
levers are for:

- **L1 — mlx-lm parity (standard KV).** bf16 KV, **bit-exact vs mlx-lm**. The
  foundation oracle. Path: monolith `Gemma4Model` / `MiniCPM5Model`, `ops.sdpa`,
  perf kernels off.
- **L2 — mlx-optiq parity (mixed-precision KV quant).** quant/mixed KV,
  **bit-exact vs optiq**. Path: `QuantizedKVCache` + `quantizedSdpa` *unfused*
  (`MLX_BUN_PERF_KERNEL=0`).
- **L3 — our perf mode.** generated unrolled handlers + fused/perf kernels;
  **deliberately beyond the oracle — there is NO bit-exact reference for L3**, by
  design (these optimizations go past what mlx-lm/optiq do). The gate is **KL vs
  the compatible upstream + the 6 eval-task mean (`src/eval/tasks/`) + perf
  numbers** — never bit-exactness. Path: generated handler, perf-kernel +
  fused-sdpa + fused-gelu on (the defaults). compiled-decode is inert here
  (CustomKernel has no `output_shapes`) — a compat/benchmark artifact, not a
  production mode. **L3's freedom is bounded by graceful degradation**: it may
  diverge only because L2/L1 stay reachable and provably bit-exact.

Degradation levers: `--perf-kernel off` / `--fused-* off` drops L3→L2; bf16 KV
drops L2→L1. Each layer must stand alone and stay reachable (don't-delete-
optionality as a fallback ladder).

So a feature like batched decode (`--slots`) is "done" only when green at
**every (model × layer)** cell — and each cell may need its own fix:

| Model · path | L1 (bf16 / mlx-lm) | L2 (quant / optiq) | L3 (perf / KL) |
| --- | --- | --- | --- |
| CPM (MiniCPM5) | ✅ S1b.1 | ☐ quant + unfused-mask | ☐ |
| Gemma 12B | ◐ WIP — see below | ☐ generated + sliding-window | ☐ (gen rope fix) |
| Gemma e4b | ☐ + per-layer-input + KV-share | ☐ generated + same | ☐ (gen rope fix) |
| Gemma 26B | ☐ + MoE | ☐ generated + MoE | ☐ (gen rope fix) |
| *(Qwen, future)* | *new path* | *new path* | *new path* |

Harness: `tests/batched-decode-parity.test.ts` is now a reusable per-(model)
runner (`runBatchedDecodeParity`) — generalized over per-layer cache types
(KVCache / RotatingKVCache) with a ring-wrap guard; one test per cell.

**Gate philosophy (revised twice, 2026-06-14):** batched decode is NOT bit-exact
vs single-stream (batching changes the attention kernel's reduction order). The
RIGHT oracle is **mlx-lm's OWN batch mode at the same B** — mlx-lm B=N ≡ mlx-bun
B=N, **bit-exact**. Comparing our B=N to our own B=1 (the KL harness) measures
the wrong thing and can't distinguish a real bug from inherent batched-kernel
behavior. mlx-lm's batch path (oracle venv, confirmed 2026-06-14):
`BatchKVCache`/`BatchRotatingKVCache(left_padding)` — left-padded, a **per-row
`offset` array** (`-left_padding`, `+=1`/step → real per-row position, feeding
RoPE), mask `j >= left_padding[b]` (`create_causal_mask(left_padding=…)`), and
for bf16 the **same fused bool-mask `mx.fast.scaled_dot_product_attention`** we
use. So our approach matches in principle and the **additive-mask idea is wrong**
(would deviate). Oracle generator: `scripts/gen-batched-golden.py` (drives
mlx-lm's real batch-prefill + greedy batch-decode, dumps per-row trajectories +
last-position logits). CPM B=2 oracle captured 2026-06-14.

**Remaining gap:** the KL harness solo-prefills each row then *assembles* a
batched cache, and compares to *solo* decode. mlx-lm batch-PREFILLS (B=N) — so
even prefill KV differs (B=1 vs B=N kernel). To gate faithfully we need a real
mlx-bun **batched prefill + batched decode** path, compared bit-exact to the
mlx-lm B=N golden. (The KL B2-vs-B1 harness stays as a cheap internal-consistency
check, not the gate.)

**Gemma 12B L1 findings (2026-06-14, WIP) — KL separates two effects:**
- **Unpadded row: KL ~5e-3, content-INDEPENDENT** (identical with two identical
  prompts; argmax-stable) → benign mlx batched-attention reduction-order noise,
  NOT a bug. (B=1 through the wrapper is bit-exact, confirming the wrapper +
  ropeDynamic + array mask are correct for Gemma.) Ruled out KV-sharing (12B has
  none) and ring-wrap (guarded).
- **Padded row: KL ~2.6e-1 → a REAL Gemma-specific error**, despite its mask +
  rope being mechanically identical to CPM's padded row (KL 7e-4, fine). Leading
  hypothesis: at Gemma's score magnitudes (headDim 256, scale 1.0) the **bool
  mask doesn't fully clamp the zero-padding columns to −inf**, so padding leaks
  (harmless at CPM's magnitudes). Fix candidates: additive −inf mask, or assemble
  padding that can't leak. Needs layer-level instrumentation; gated test is
  diagnostic-only until root-caused.

Batched-decode landmines found by the modes analysis (2026-06-14):
- **e4b**: `computePerLayerInputs` hardcodes `[1,L,…]` (gemma4.ts:647) → B>1
  breaks; plus KV-sharing (sharer `SharedKv`).
- **Gemmas**: `RotatingKVCache` sliding-window ring — per-row decode mask + ring
  write (the hard one). 26B adds MoE (`GatherQMM`/`SwitchGLU`) batched routing.
- **Generated handlers (L3, all 3 Gemmas)** repeat the K/Q rope timing trap —
  they read `cache.ropeOffsetArr` twice around `updateAndFetch`
  (generated/gemma4-12b.ts:63 & :74). The fix goes in the GENERATOR
  `scripts/gen-model.ts`, then regenerate (the files are DO-NOT-EDIT).
- **Quant + batched**: the `[B,1,N,S]` array mask disqualifies the fused decode
  kernel (`mask.mode===""` required) and the tiled path (2-D causal-equiv
  required), so quant batched decode falls to `quantizedSdpaUnfused` — correct
  but the perf kernel is bypassed (perf debt; a batched-aware fused decode kernel
  is a later item). `quantizedSdpaUnfused` must be validated with a 4-D bool mask.
- **All cells**: compiled-decode forced off under `--slots>1`; LoRA batches only
  within one adapter group (else drain).

## KV memory: dynamic allocation, not static partition

The naive model — reserve `budget / slots` per row, fixed — is rejected:
it wastes memory and imposes an arbitrary per-slot context cap. We
allocate **by need**. Three rungs, in increasing order of "who needs it
most" fidelity and cost:

1. **Static partition** — *not built.* Fixed per-slot ceiling. Wasteful.
2. **Dynamic shared-budget, contiguous caches (padded batch)** — the
   shippable path. Admission is governed by *total projected bytes*
   against one KV budget (mirrors the byte-capped `PromptCache`); each
   sequence grows its own contiguous cache on demand (KVCache already
   grows in 256-token steps). Short prompts use little; long ones take
   more. **Caveat**: a padded batch shares one `[B, H, S, D]` buffer, so
   the buffer width tracks the *longest live sequence* — short rows still
   carry padding to that width. Partial "who needs it most."
3. **Paged KV (the true goal)** — fixed-size KV blocks in a shared pool,
   gathered by a custom paged-attention Metal kernel. No padding waste;
   the neediest sequence grabs more blocks, others fewer; maximizes
   concurrent rows per GB. This is what "dynamically allocate based on
   who needs it most" actually means. Cost: a custom attention kernel +
   a block manager. Feasible — the project already ships custom Metal
   kernels (`src/mlx/metal-kernel.ts`, `src/model/fused-decode-kernel.ts`).

Plan: ship rung 2 (S1–S2) for the throughput win + dynamic admission
with no new kernel; build rung 3 (S3+) as the memory-density upgrade.
Budget accounting is total-bytes from day one.

KV quantization is a force multiplier: 4-bit KV (`generate.ts:67`,
already supported) is ~4× smaller, so the same budget buys ~4× the slots
or ~4× context per slot. Batching + KV-quant compound.

Note: the existing `2e9` (`server.ts:494`) is the **prompt (prefix-reuse)
cache**, not live decode KV. Live caches are made fresh per generation
(`server.ts:517`). Slots introduce a *new* budget: the pool of live
decode caches.

## The scheduler (port of mlx-lm `BatchGenerator` / `ResponseGenerator`)

When `slots > 1`, the single promise chain (`server.ts:487`) is replaced
by a scheduler owning:

- a **pending queue** of admitted requests;
- a **running batch** of ≤ `decodeConcurrency` rows;
- **admission control** against the KV budget;
- a **batchable gate** (mlx-lm `_is_batchable`): same model, compatible
  sampler params, **no fixed seed**, no vision, compatible adapter set;
- **prefill phase** (≤ `promptConcurrency` rows) vs **decode phase**;
- **draining**: an incompatible request waits for the batch to clear,
  then runs in its own batch.

Streaming fan-out is the main plumbing rework: today `generate()` yields
one token to one SSE stream (`server.ts:964,1037`). Batched, each step
produces B tokens that must route to B independent response streams,
each with its own `StopSequencer`/tool-call router. Touches
`server.ts`, `responses.ts`, `anthropic.ts`.

## Fallbacks (must degrade, never break)

- **Vision** → always solo. Image embeddings + bidirectional mask need
  offset-0 single-sequence prefill (`gemma4.ts:690` throws otherwise).
- **LoRA** → batch only requests sharing the same adapter set, else
  drain to solo. `loraState.active` is a single per-generation field
  (`generate.ts:187`); cache namespaces are adapter-keyed
  (`prompt-cache.ts:18`). Per-row adapters is a much harder problem;
  group-by-adapter + drain is accepted (confirmed fine for our use).
- **Fixed seed / unusual sampler** → drain to solo (matches `_is_batchable`).
- **Compiled decode** (`generate.ts:348`) → start **disabled** under
  batching (single-sequence shapeless replay); extend to `[B,1]` later.
- **Prompt cache** → per-row take/put still works, but the
  "single queue ⇒ take/reinsert is race-free" invariant
  (`prompt-cache.ts:7`, `lora.ts:7`) now depends on the **scheduler**
  being the sole owner of cache mutations. Keep all take/put inside the
  scheduler loop.

## Config surface

- `ServerOptions.slots` (default 1); later `kvBudgetBytes`,
  `promptConcurrency`.
- CLI: `--slots N` (S0); later `--kv-budget <GB>`.
- `slots === 1` → today's serialized promise chain, untouched.
  `slots > 1` → scheduler.

## Phasing (incremental, parity-gated)

- **S0 — config seam (DONE).** `--slots N` / `ServerOptions.slots`
  plumbed, validated, surfaced (ready card + `/stats`). `N>1` warns that
  batched execution lands in S1 and runs serially. No behavior change.
- **S1 — static 2-wide, base model only.** Split by the reuse finding:
  - **S1a (prefill)** — reuse the training machinery (`buildBatchedPadMask`
    / `BatchedMaskCache`); wire the serving path to prefill B prompts in one
    forward. Mostly generalization + consolidating the two mask builders.
  - **S1b (decode)** — the new work: a batched KV cache that grows with
    per-row offsets, per-row RoPE via the array-offset path, and the per-row
    `[B,1,1,S]` decode mask (`buildBatchedDecodeMask`, landed 2026-06-14).
    Plus the B-token-per-step decode loop + per-row stream fan-out.
  **Teacher-forced gate**: a 2-row batch must produce per-row logits matching
  two solo runs within bf16 tolerance (the train-batch-e2e methodology, now
  applied to decode).
- **S2 — N-wide + continuous injection/eviction.** Rows retire on EOS;
  queued requests prefill into freed rows. Dynamic byte-budget admission.
- **S3+ — paged KV** (custom paged-attention kernel + block manager),
  KV-quant under batch, LoRA-group batching.

Every phase ships default-off behind `slots=1`; the serialized path is
never removed (only bypassed).

## Open questions / to measure

- Sliding-window per-row masking (above) — retire this correctness risk
  early.
- `async_eval` decode pipelining (`generate.ts:386`) builds step n+1
  before reading n; one row stopping mid-pipeline while others continue
  needs care.
- Throughput ceiling: the B where we cross bandwidth→compute bound, and
  aggregate tok/s vs solo — measured via `benchmark.sh` (preflight-gated;
  loaded-machine numbers don't count).

## References

- mlx-lm continuous batching: `BatchGenerator` / `ResponseGenerator`,
  flags `--decode-concurrency` (default 32), `--prompt-concurrency`
  (default 8); `_is_batchable` gate; batch draining.
  https://deepwiki.com/ml-explore/mlx-lm/3.3-http-server ·
  https://github.com/ml-explore/mlx-lm/issues/499
- optiq: **no** batching — single-process serialized, advises external
  max-concurrency; each in-flight request keeps a resident KV cache.
  https://mlx-optiq.com/docs/serve
