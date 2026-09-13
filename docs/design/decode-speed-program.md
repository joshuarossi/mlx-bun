---
status: active
axis: ON
canonical-for: decode-speed-levers
plan-anchor: "Phase 6 — Speed: change what gets computed `[~]`"
last-verified: 2026-09-08
---

# Inference performance program

This is the canonical performance research plan. The current priority is the
Qwen3.8-27B program in section 7, covering quants, the complete execution graph,
custom kernels, deterministic token replay, prefill, decode, and serving.
Sections 1–6 retain the earlier cross-model research and the
**port ledger vs oMLX** (§6, folded in from `docs/design/omlx-adoption-map.md`
in `2b571ff`, 2026-08-24). Open status lives in PLAN.md (Phase 6); the
campaign run log is
[qwen38-27b-campaign-log.md](../archive/investigations/qwen38-27b-campaign-log.md)
and its outcome ledger is §7.13; the architecture the levers plug into is
`unified-engine-frontier-plan.md`; curated numbers are
`docs/reference/benchmarks.md`. Every lever here has evidence, an expected
win, and a trigger; pick them up in order. No number below is new — each
cites where it was measured.

## 1. The physics and the baseline

For an efficient bandwidth-bound implementation,
decode tok/s ≈ bandwidth ÷ bytes-touched-per-token. The earlier mode-matrix benchmark
(`scripts/bench-matrix.ts modes`) confirmed what the roofline work predicted:
the then-tested L1 decode paths approached the memory-bandwidth wall
at short context, so tier levers cannot buy single-stream decode speed
(naked default = `--l1`, decided 2026-07-05, `git show 3199c75:PLAN-archive.md`:
decode parity with mlx-lm on every model; no output-changing lever beat it). Faster therefore means one of five
physical moves:

1. read the weight bytes ONCE for several tokens — speculation, batching;
2. read FEWER bytes — quantization quality-per-bit;
3. SKIP reads — caching (prefill/TTFT side, already leadership territory);
4. shave the non-GPU residue — host overhead, dispatch count, residency.
5. execute the math more efficiently when arithmetic, access patterns or
   occupancy keep the implementation below its bandwidth limit.

One correction the bandwidth framing missed (2026-07-04, CPM5): small
ELEMENTWISE ops are dispatch-bound, not bandwidth-bound. An unfused swiglu
(`sigmoid` + `mul` + `mul`, 3 kernels/layer × 24) cost ~5% of decode; porting
mlx-lm's `@mx.compile` swiglu (`compiledSwiglu`, now the default in
`src/model/minicpm5.ts`, `qwen3.ts`, `qwen3_5.ts`, `qwen3-moe.ts`,
`universal/dense.ts`; `MLX_BUN_COMPILED_SWIGLU=0` kills it) moved CPM5 to
parity with mlx-lm, bit-identical tokens. The win was per-dispatch host +
encode tax, which is why CompiledDecode was 0% there (it replays the same
unfused graph). Packed trellis is a further exception: unpack arithmetic,
memory access patterns, and occupancy can dominate its matrix products.
Section 7 measures these limits for each shape and chip instead of assuming
fewer bits are faster.

## 2. The levers, ranked

### Lever 1 — speculative decoding, subject to a wall-clock win

One target forward verifies γ drafts + a bonus token: the weight read
amortizes over up to γ+1 tokens. The serve loop is the ONE verify/accept
executor (`src/spec/serve-loop.ts`, faithful to mlx-lm's
`speculative_generate_step`; grammar composes on the verify walk), reached
through `serve --draft-model` / `--draft-kind`, with `usage.speculation`
telemetry. Drafters, as wired in `src/spec/` and `src/cli.ts` on 2026-08-23:

| kind | source | status | evidence |
|---|---|---|---|
| `two-model` | `two-model.ts` — a full same-tokenizer draft model (mlx_lm.server parity) | landed | 48/48 token-for-token vs mlx-lm's spec path (`docs/design/batching.md` Phase B) |
| `assistant` | `assistant-source.ts` — optiq's KV-borrowing Gemma "-assistant" drafter | landed (was "build next" in the 2026-07-04 draft of this doc) | bit-exact vs optiq's `spec_generate`; 12B γ=1 ≈ 1.09× (`docs/design/speculative-decoding.md`); e4b a net loss at every γ (PLAN.md Phase 6) |
| `dspark` / `deepspec` | `dflash-source.ts`, `deepspec-source.ts` — DFlash KV-injection (ours / DeepSeek's released drafters) | landed, wall-clock NEGATIVE so far | 12B + block-7 drafter: τ ≈ 2.8 committed tokens per target forward but ~3.4× slower wall-clock (spec 14.6 vs serial 49.8 agg tok/s, loaded box) — the drafter's own weight reads and host syncs are the tax (`docs/design/speculative-decoding.md`) |
| `mtp` | `qwen-mtp-source.ts`, `glm52-mtp-source.ts` | Qwen3.8 implemented, opt-in; measured negative on the 27B | `speculative-decoding.md` section 4.4 records the off/on wall-clock comparison; acceptance alone is not a speed result |
| `ngram` | `ngram-source.ts` — model-free prompt lookup, lossless | landed | no drafter weights; drafts copied from the request's own context (`--ngram-max/--ngram-min`) |

What remains is drafters worth running, in this order:

- **1a. Reopen native MTP only with a changed cost model.** The native head
  still reads head weights, projects vocabulary logits, and samples drafts.
  The recorded Qwen off/on comparison lost. Test head quantization and small-M
  verify kernels against the same artifact with MTP off; retain off as control.
- **1b. Cheaper drafter head** — the 262k tied-embedding argmax every draft
  step dominates γ≥2 cost on the Gemma assistant drafter; capping or
  approximating it extends the win past γ=1 (`docs/design/speculative-decoding.md`
  "remaining levers").
- **1c. DSpark wall-clock flip** — `docs/design/speculative-decoding.md` Phases 0–4
  (drafter weight diet, host-sync reduction in `draftBlock`, tapped verifies
  on the optimized graph). Goal there: spec ≥ 1.3× serial on 12B at the best
  config, clean machine. No-oracle / KL-gated (Lab).
- **1d. Grammar-aware speculation** — the grammar mask collapses the
  drafting problem on structured output. State in `src/` today:
  (i) **jump-forward** exists as `MLX_BUN_GRAMMAR_JUMP=1`, opt-in, in the
  serial NON-spec loop only (`generate.ts` `shouldUseGrammarJump`; the batch
  lane's `#stepGrammar` doesn't jump; excluded when logprobs are requested).
  It is not yet folded into a spec verify window as a pre-accepted draft.
  (ii) **constrained drafting** is NOT implemented — the drafter runs free and
  the mask rides the verify walk (`serve-loop.ts` header); the
  `MLX_BUN_SPEC_GRAMMAR_DRAFT` lever an older draft of this doc named does not
  exist in `src/`. The measured motivation stands: acceptance dropped 51%→29%
  under grammar with a blind drafter (our own matrix). (iii) grammar-pruned
  draft TREES (XGrammar-2's `traverse_draft_tree`) — idea only.
- **Drafting under batching** — grouped provider execution is implemented at
  B1/B>1, with method-owned candidate generation, verification and companion
  state. Remaining compositions and evidence live in [batching](batching.md#consolidation-matrix).

### Lever 2 — native MLX updates against the pinned control

The runtime and oracle now use MLX 0.32.2 / native pack 0.4.0; see §7.12 and
[environment](../reference/environment.md). The historical July audit below
identified upstream changes absent from its then-current MLX 0.31.2 pin. Recheck current releases and the native libraries actually loaded before
an upgrade experiment. A new mlx/mlx-c build also needs matching oracles;
retain the pinned installation and test the new stack in isolation.
Upstream refs are full URLs on purpose (a bare `#NNNN` here resolves to our
own tracker).

What `main` has (confirmed against the PR pages, 2026-07-04):
- [ml-explore/mlx#3485](https://github.com/ml-explore/mlx/pull/3485)
  `GatherQMM::output_shapes` (merged 2026-05-29, zero numeric change) — THE
  prize: `src/model/compiled-decode.ts` still keeps MoE models uncompiled
  because GatherQMM lacks `output_shapes` in the pinned mlx (verified
  2026-08-23); this unblocks CompiledDecode over the MoE and attacks the
  26B/30B-A3B host term.
- [ml-explore/mlx#3764](https://github.com/ml-explore/mlx/pull/3764)
  `qmv_wide` (merged 2026-06-26) — small-M (≈2–8) quant matvec: helps the
  spec-decode VERIFY forward and small batches, NOT single-stream M=1 and NOT
  the gather/MoE path. Becomes the default at M≈2–8 → re-baseline batched
  goldens.

The older description of
[ml-explore/mlx#3553](https://github.com/ml-explore/mlx/issues/3553) was wrong:
it describes a dense small-M QMV discontinuity, not the MoE gather path, and
is closed as of 2026-09-04. Issue status does not establish which fix is in
our binary. Inspect the selected dispatch and measure Qwen's actual shapes.
[ml-explore/mlx#3120](https://github.com/ml-explore/mlx/pull/3120) (split-K
small-M quant matmul) predates the 0.31.2 tag — probably already ours;
confirm before counting it.

For the dense 27B, prioritize small-M reuse for fill spans and prefill before
reopening MTP. MoE-specific changes belong to the other models' experiments.

### Lever 3 — quantization quality, bytes and measured latency

On bandwidth-bound paths, reducing weight bytes can improve decode. Packed
formats also change unpack cost and access patterns, so test the latency of
each recipe. Existing quality-per-bit work includes the sensitivity-driven
knapsack (`convert --target-bpw`, `src/quantize/sensitivity.ts`, a port of
optiq's `analyze_sensitivity_exact`), rotation-folded quantization
(`--rotate-weights`, `docs/design/turboquant.md`), and TurboQuant KV
(`docs/design/turboquant.md`). The 27B program's measured verdict (STATUS.md /
PLAN.md "TurboQuant weights"): quality saturates at ≥4.5 bpw on ppl and
MMLU/GSM8K; recipes matter below 4 bpw, where rotation wins (the 3.86 bpw /
13.9 GB Qwen3.8-27B-TQ artifact is the M4 Pro 24 GB fit lever). Decode tok/s
for those artifacts on a quiet box is still owed (PLAN W7) — do not quote a
speed number for them until it exists. Gate for any new recipe: perplexity +
the frozen 6-task eval at equal bpw, eval-DB rows.

### Lever 4 — host-side residuals  [expected 2–8% on affected models]

- **Compiled elementwise activations — LANDED** (§1). Same standalone
  `sigmoid/silu + mul` pattern audited into every dedicated file; gemma geglu
  is `MLX_BUN_COMPILED_GEGLU` (default on).
- **Weight residency (wiring) — LANDED 2026-08-23** (PLAN.md "Prefill vs
  mlx-lm — paired re-measurement" and the follow-up; STATUS.md): the
  large-model wiring policy was stale against macOS's reported working set,
  so Qwen3.8-27B ran unwired. Both the serial generator and the continuous
  scheduler now hold the same re-entrant wired scope (`acquireModelWiredLimit`
  in `src/generate.ts`) while they own the GPU; the controlled replay moved
  the final Qwen L=1 forward from about 1.48 s to 55 ms. Numerics unchanged.
  Rule: a decode-class regression on a large model is a residency question
  before it is a kernel question.
- **e4b ~5% per-step host overhead** (PLAN.md Phase 7 residual; dispatch
  count) — still open; prime suspect is the same unfused-elementwise class.
  Method: xctrace shader-list diff vs mlx-lm (the qwen3.5 kernel-trace parity
  method), then `mx.compile` the site.
- **P4 device-side step chaining** — depth-k chained step graphs, one host
  sync per k tokens (`docs/design/batching.md` P4). Attacks OUR FFI/readback
  cost — a different mechanism from oMLX's burst decode, whose refutation
  (§6) does not apply.
- **Padded-B>1 per-step mask rebuild** — by design in the scheduler's padded
  branch; unmeasured at B>1, likely amortized. Measure via a forced-padding
  aggregate A/B before building a step-stable mask cache (PLAN.md 2026-07-06
  audit).
- **MoE M=1 gather path** — see lever 2; the compute-bound gap on 26B/30B-A3B
  is a kernel item, not a bump item.

### Non-levers (measured; don't re-litigate without new evidence)

- **Megakernels at M=1** — bandwidth floor: ceiling ~1.78× on CPM5, achieved
  0.94× (`docs/design/generic-model-support.md`); multi-token amortization is
  required, which is lever 1 / batching.
- **oMLX-style burst decode** — refuted for Bun (§6).
- **Fused-decode / perf kernel / custom fused-gelu** — deleted 2026-07-05
  after losing the paired A/B (architecture doc §11). A future flash-decode
  kernel re-derives from the L1 baseline in the Lab.
- **QKV / gate-up matmul fusion at M=1** — CPM5 2026-07-04: q/k/v blocked by
  OptiQ mixed precision (v_proj 8-bit vs q/k 4-bit); gate/up fusible in 18/24
  layers but the speed-ceiling version measured ~2% SLOWER — matmul
  dispatches are bandwidth-hidden and a concatenated `[2I]` qmv is less
  efficient at M=1 than two `[I]`. Contrast the swiglu win: elementwise ops
  are dispatch-bound.
- **Host graph-build overlap** — already hidden by the pipelined loop
  (spin-injection proof in
  `docs/archive/investigations/decode-roofline-lookagain.md`).
- **Debranching alone** — ~0% (host JS conditionals hidden by the GPU-bound
  pipeline); it stays a hygiene item in the architecture doc, not a speed
  lever.

## 3. Sequence

The current Qwen3.8-27B order is section 7.7: trustworthy controls, graph
capture, packed kernels and deterministic replay, then the remaining measured
bottlenecks and serving interactions. MTP requires a changed cost model.
For shared engine changes, also run `scripts/bench-matrix.ts modes` on the
affected e4b/12B controls. Promote clean-machine rows to
`docs/reference/benchmarks.md`.

## 4. Related design ownership

Section 7 coordinates TTFT, prefill, decode, and throughput. Implementation
design remains with its topic: prompt cache + SSD tier
(`docs/design/kv-cache.md`), batching aggregate (`docs/design/batching.md`),
prefill vs mlx-lm (PLAN.md "Prefill vs mlx-lm — paired re-measurement",
"Qwen3.8 prefill — measurement + analysis", and the prompt-to-response
attribution matrix in STATUS.md).

## 5. Measurement discipline

- Every claim is a paired A/B on this machine, labeled host/chip/RAM; run
  spread is the quality signal (`bench-h2h` retries unstable cells and
  withholds verdicts). Numbers on a loaded machine are not quotable.
- Wall-clock only. SSE-burst inflates naive tok/s; oMLX's own logs
  over-report.
- Verify the served model id (`/v1/models`) before trusting any bench.
- A perf gap vs mlx-lm/optiq is OUR bug until proven otherwise: copy the
  oracle op-for-op, prove the kernel set identical (xctrace shader-list
  diff, `export_to_dot` op-set diff), then optimize.

## 6. Port ledger vs oMLX

oMLX (github.com/jundot/omlx, Apache-2.0) is the systematic port source for
serving features: read its real implementation (the full source ships in the
local app bundle under `/Applications/oMLX.app/Contents/Resources/omlx/`),
port the IDEA into our architecture, keep it only if OUR benchmarks improve.
Attribution: derived code is noted in `THIRD_PARTY_LICENSES.md` (the
xgrammar row credits `api/grammar.py`); idea ports get a source comment.

### Where oMLX sits in the tier model

It doesn't slot at L1 or L2 — it decomposes. The tiers are numerics
contracts; oMLX is a Python appliance ON mlx-lm:

- its stock forwards are mlx-lm's numerics = our existing L1 oracle (no new
  oracle value);
- its own numeric inventions (oQ, custom kernels, DFlash, MTP) are
  oracle-less = Lab-class here, and get our Lab gating (KL/eval/envelope +
  kill switch) that they lack upstream;
- its product surface (SSD cache, EnginePool, menu bar, MCP, grammar) is the
  tier-agnostic serving layer — keyed by the effective scheme, never part of
  the decode-numerics graph.

### Ported, kept (benchmarked wins)

| feature | theirs | ours | result |
|---|---|---|---|
| Continuous batching | scheduler on mlx-lm `BatchGenerator` | `--batch N` (default 8) → `src/serve/batch-scheduler.ts`, per-row samplers/processors, SSM (Qwen3.5) rows, `--kv-budget` admission, universal (Llama) per-row RoPE | cpm5 aggregate win, e4b/Qwen3.5 within a few %, TTFT 2–3× better (`docs/design/batching.md`); B=1 through the scheduler 0.992–0.996 of serial (PLAN.md) |
| SSD KV cold tier | `cache/paged_ssd_cache.py` (content-hashed blocks) | `src/ssd-cache.ts` + kv-store v2 (whole-entry spill, zero-copy mmap), inside `PromptCache.take()` | restart TTFT 12.1 s → 0.24 s vs their 1–3 s; 0% decode overhead vs their ~20% (`docs/design/kv-cache.md`) |
| Structured output | `api/grammar.py` | `@mlc-ai/web-xgrammar` (WASM), full `response_format`/`guided_*` surface, serial AND batched, composes with spec | byte-identical content vs oMLX (`docs/reference/server-api.md`) |
| Multi-model serving / EnginePool | `engine_pool.py` (LRU + pinning + load/unload) | `--isolate --model-pool N` → `ModelPool` in `src/serve/isolate.ts`: LRU residency over engine children, routing by the request `model` field, spawn-overlap switching, drain → demote-to-SSD → park | switch ~1.5 s, switch-back ~1.2 s with the conversation's KV restored from disk (PLAN.md 2026-07-05, M1 Max, cpm5⇄qwen0.8b) |
| DFlash serving wiring | `engine/dflash.py` + their published drafts | `DflashSource` / `DeepSpecSource` behind the same `DraftSource` seam as every other drafter (`--draft-kind dspark|deepspec`) | serve-integrated; wall-clock negative on 12B so far (lever 1c) |

### Ported, refuted (do not re-add without new evidence)

| feature | why it doesn't transfer |
|---|---|
| Adaptive burst decode (`engine_core.py _step_burst`) | Amortizes Python GIL/asyncio ping-pong (~1 ms/token). Bun's `setImmediate` hop costs microseconds; the faithful port REGRESSED cpm5 B=4 aggregate 345→289, batch-lane B=1 149→121, and TTFT ~+100 ms (first-token SSE flush waits out the burst). Reverted with a breadcrumb in `batch-scheduler.ts`. |

### Queue (by leverage; ★ = Josh explicitly wants)

1. **★ Menu bar app** (`apps/omlx-mac/`, native SwiftUI + Sparkle) — product
   layer. Their repo is the structural reference; our signed/notarized single
   binary is the sidecar. Supersedes `docs/design/web-chat-redesign.md`'s Electron
   ambivalence. Not started.
2. **oQ-style sensitivity-driven quantization** (`oq.py`,
   `docs/oQ_Quantization.md`) — Lab-class, would land in `convert` beside
   `--target-bpw`: calibration-measured per-layer sensitivity with boosts on
   non-expert tensors only and batched expert GPTQ. Note the distinction: our
   `sensitivity.ts` is a port of optiq's exact-KL sweep, not oMLX's oQ. Gate:
   perplexity + 6-task eval vs the knapsack at equal bpw. The 27B finding that
   quality saturates ≥4.5 bpw narrows where this can pay (sub-4 bpw).
3. **Vision feature cache** (`cache/vision_feature_cache.py`) — encoder
   features for repeated-image agent turns; natural second client of the SSD
   substrate (Layer 0 in the architecture doc). Not started.
4. **MCP tool execution in serve** (`--mcp-config`, `mcp_routes.py`) — Pi
   already owns tool orchestration for our UIs; scope to bare-API consumers.
   Not started.
5. **Prefill progress observability** (`prefill_progress.py`) — /stats + web
   UI surfacing for long prompts. Our `PromptResponseTrace` is a diagnostic,
   not a live progress signal. Not started.
6. **Rerank endpoint** (`/v1/rerank`) — needs a reranker model family first.
7. **Document ingestion (MarkItDown)** — would go through Pi attachments, not
   the server.
8. **Admin one-click benchmark with prefix-cache-hit testing** — fold into
   `scripts/bench-serving-load.ts` as a cache-hit-ratio mode; not present.

### Explicitly not porting

- **Audio STT/TTS/STS** — our audio work is the input tower
  (`docs/design/generic-model-support.md`), not their pipeline.
- **Their SSE burst streaming** — a side effect of the GIL workaround;
  per-token streaming is strictly better UX at zero cost here.
- **Python-side scheduler details** (GIL executors, collector reaping) —
  runtime-specific.

### Porting discipline

1. Read their real source first (the local app bundle) — the README lies
   less than the code.
2. Port the idea into OUR architecture; never transliterate Python.
3. Benchmark before/after on THIS machine; keep only wins (burst decode died
   here). Wall-clock metrics only.
4. Numeric features get Lab gates + kill switches; serving features get
   effective-scheme keying; nothing touches the L1/L2 contracts.
5. Verify the served model id before trusting any bench.

## 7. Qwen3.8-27B research program

Josh requested a complete inference optimization campaign on 2026-09-04.
Optimize useful completed work at a measured quality and memory budget.
The deliverable is a frontier of configurations, with a reason
to keep or reject every investigated method; every number records the
host/chip/RAM it was measured on. A smaller artifact, a faster
microkernel, and a higher draft acceptance rate are intermediate results.
Each must survive the full application measurement.

Single-request performance is a primary acceptance target alongside aggregate
serving. Use the existing `scripts/bench-serve.ts all` workload, which replaced
the root `benchmark.sh` in `7d81462`: sustained decode, cold and cached TTFT,
1k and long-context prefill, decode at context, restart reuse, sampled RSS and
load/readiness. Its prefill rate includes the work before the first streamed
token; keep pure native prefill timing separate. A short-prompt TTFT gain does
not establish a 1k/long-context gain. Record MLX active/peak allocations
separately from sampled RSS, which does not account for all GPU memory.

Preserve the refactor's request, completion, graph and session contracts.
Keep numerical dispatch and resource handling in backend/model operations;
HTTP parsing must not select kernels. Add an abstraction only when a retained
change needs it. Remove closed experimental helpers after documenting their
findings, and reject extra production caches or dispatch branches without a
complete-request benefit.

This program includes new weight formats, custom Metal kernels, fusion,
unrolling, alternate algorithms, and deterministic replay without verification.
It supersedes the older weights-leg restriction against new qmm kernels for
this campaign. Numerical changes retain the repository's L1/L2/Lab contracts.
The weight recipe remains in [turboquant.md](turboquant.md), cache design in
[kv-cache.md](kv-cache.md), and replay/speculation design in
[speculative-decoding.md](speculative-decoding.md). PLAN owns open status.

### 7.1 What the initial audit establishes

The local artifacts select the dense `qwen3_5` graph: 64 layers, three
GatedDeltaNet layers followed by one full-attention layer per group of four.
Hidden width is 5120; MLP width is 17408. There are 192 MLP matrices.
Full attention has 24 query heads, four KV heads, and head dimension 256.
GDN has 16 key heads and 48 value heads, both with dimension 128.
These are config/header observations, not measured shader dispatches.

The packed Q3 metadata contains duplicate module aliases. Counting config
entries reports twice the actual trellis matrix count. The new
`scripts/bench/model-inventory.ts` counts tensors present in shard headers,
groups matrices by role, logical shape, bits, group size and coding axis,
and includes scales/biases in matrix storage. Its matrix bpw denominator is
explicit; it does not claim whole-model bpw or resident memory. It does not
read or hash weight payloads. Sidecars and MTP companions require their own
inventory. Raw inventories and source pins go under `reports/qwen38-rd/`.

The source inspection found these starting points:

- `TrellisLinear.forward` uses packed matvec for flattened M ≤ 4 and dense
  expansion plus stock matmul above it. Prefill currently evaluates each
  projection, and `Qwen35Model.forwardLayers` evaluates cache outputs per
  layer, to bound live buffers. Removing these barriers without replacing
  their memory bound can recreate the OOM already being fixed.
- Decode defaults to trellis variant 6. It computes f32 code×scale, whereas
  expansion rounds to bf16. A trace across M=4/5 therefore crosses both a
  performance boundary and a numerical boundary. Variant 4 has deliberately
  wrong numerics and is only a diagnostic cost floor.
- Trellis dispatch hard-codes 128 threads, four SIMD groups and 128 scatter
  splits. Gate/up fusion requires compatible geometry. These are parameters
  to measure per chip and bit allocation, not universal optima.
- `GatedDeltaNet.forward` separately dispatches convolution, SiLU, q/k norms,
  q/k scaling, gate computation, recurrence and gated output normalization.
  Its recurrence already keeps state in registers across sequence positions.
- Full attention separately applies the output sigmoid and multiplication.
  Any fusion must reproduce the existing intermediate rounding to retain L1.
- The existing `__deltaProf` instrumentation calls `evalAll` between stages.
  It is useful for isolation and changes execution overlap. Its times cannot
  be summed into a claimed production speedup.
- Strict fill already uses `policy: "assert"`: no verification/readback in
  normal operation. It advances hidden states and all caches for the span,
  skips intermediate vocabulary heads, and discards an in-flight sample.
  The source still pays that discarded sample's scheduled work.
- MTP is an optional, previously losing 27B arm. See the actual off/on
  experiment in speculative-decoding section 4.4. High acceptance never
  established a Qwen throughput win.

The initial CPU inventory covers the locally available 27B artifacts. The
first benchmark preflight refused the occupied M4. Subsequent native controls
and candidate timings are diagnostic; the quiet HTTP baseline remains open.
Environment details,
including the different installed OptiQ versions, belong in
[environment.md](../reference/environment.md).

#### Refactor review: main at `673b43f` (2026-09-05)

The 35 commits after `6d45ca1` merge the interface-based engine refactor.
Its implementation and acceptance record are in
[engine architecture §12.13](unified-engine-frontier-plan.md#1213-implementation-status-2026-09-05).
They change the execution paths to inspect and the way we register candidates;
they do not establish a new 27B performance baseline. The repeated upstream
HTTP comparisons used MiniCPM5/Gemma e4b on a loaded M1 Max. The designated
27B quants, quiet performance and second-machine acceptance remain open.
Upstream did not change `qwen3_5.ts`, `trellis-linear.ts` or `qwen3-delta.ts`
in this merge. Retain the existing quant-quality controls and negative MTP
result, then remeasure the complete serving path at the new revision.

The M4 Pro audit now uses isolated, unmodified `6d45ca1` and `673b43f`
checkouts. Their MLX binding and Qwen/Trellis numerical source blobs are
identical. Six fresh-process native AB/BA pairs hold Bun, artifact, variant 6,
greedy settings and a bounded prefill policy fixed. All warmup and measured
IDs agree at 6/128/512 prompt tokens, every worker exits cleanly, and both
source snapshots stay fixed. Native TTFT, complete-request timing and memory
are approximately flat; this provides no evidence of a native regression on
those workloads. Six serial HTTP process pairs also preserve every response,
token count and finish reason, with fixed sources and clean shutdowns. TTFT,
complete-request time and sampled peak RSS are approximately flat. Telemetry
confirms the serial executor. Six additional default-scheduler pairs also
preserve every response, with fixed sources and clean shutdowns. Per-request
telemetry proves that these requests enter the scheduler. Complete-request
timing is flat or slightly lower after the refactor, decode timing is flat,
and sampled peak RSS is close. These controls provide no evidence of a
refactor slowdown on the measured native or serving workloads. Both historical
revisions run unmodified; no memory-fix overlay was needed for these bounded
requests. Prompt/SSD caches are disabled throughout. Cached, sustained-pressure
and second-machine acceptance remain separate checks.
Evidence: `refactor-fixed-kernel-audit-plan.json`, `refactor-native-paired.json`
and `refactor-native-paired-review.json`, plus
`refactor-http-paired-{serial,default}-review.json`, under `reports/qwen38-rd/`.

The refactor is completed infrastructure for this performance campaign.
Its unrelated interface and product-acceptance work stays in its own program.
Use the new seams to isolate the expensive computation, then measure whether
a replacement pays off. The plan changes in five places:

- **R0 follows the current execution path.** Freeze the merged source plus local
  diff, then run `tests/parity/qwen-quant-engine.test.ts` separately for each
  exact artifact via `MLX_BUN_QWEN_QUANT_PATH`. Follow with same-artifact
  serial/default/oracle controls. Use the same memory safeguards on any old/new
  revision comparison; the unpatched packed-prefill OOM path is not a viable
  baseline. Historical reports retain their original source identity.
- **Register kernel candidates through the model implementation registry.**
  `model/implementation.ts` selects the declared graph/loader/loop and refuses
  missing or incompatible implementations. Give a changed graph, layout or
  method an explicit identity and compatible state/codec ABI. Verify the
  selected registration in every benchmark; no silent fallback arm.
- **Profile the new lifecycle as well as the kernels.** Shared prefill now
  uses `inference/prefill.ts` and `backends/mlx/prefill.ts`; native serial
  ownership lives in `backends/mlx/serial-executor.ts`. Session demand,
  resolved policy, leases, snapshots and readback cleanup are part of the
  measured path. Shared prefill extraction does not implement B-wide prefill.
- **Preserve bounded memory while tuning.** Local projection/cache evaluation
  barriers remain. The local serial headroom guard now enters through the MLX
  binding after cache acquisition and restores its previous model hook on
  every exit. SSD tensor steps share the gateway lease and pending writes drain
  before serial generation. Test failed demotion, cancelled replay and retained
  checkpoints before changing those boundaries in R2/R16/R17/R22.
- **Replay and MTP must pass resolved-policy gates.** The new speculative
  bindings and rollback ownership are correctness infrastructure. They are not
  evidence of faster MTP. Confirm strict fill is active under the captured
  execution policy and that checkpoint identity includes that policy before
  timing R15. Keep MTP off in the initial controls.

The earlier M4 DeltaNet discrepancy is resolved by an explicit pinned-oracle
replay on unchanged inputs. Bun and Python match exactly; the old fixture
differs at one output. The regenerated fixture records provenance and exact
recurrent-state hashes, with no tolerance change. See
[environment.md](../reference/environment.md) for the evidence and command.
The model-free checkpoint passes with the experimental kernels and replayed
fixture. Quiet application and full-model same-machine oracle acceptance
remain open.

The native control worker now freezes prompt token IDs for both engines and
records the configured plus tokenizer EOS policy, fresh-cache wall time,
TTFT, actual outputs and peak memory. Repeated short-prompt controls on the
flagship, compact and RTN4 affine artifacts reproduce the oracle's greedy
outputs. Their original timing comparison had unmatched wiring: the Python
worker omitted mlx-lm's usual wired scope. That worker is corrected and
matched-wiring timing controls must be repeated. Raw paired reports live in
`reports/qwen38-rd/native-affine-paired/`; their residual-swap preflight fails,
so they establish neither a quiet serving baseline nor full logit parity.
The longer flagship prefill completed its warmup but crashed in the measured
Bun request. Native exception tracing confirms a Metal OOM, also reproduced
in the Python worker with its usual wired scope. Clearing the Bun allocator
cache at request entry does not fix it. Both workers complete repeated
requests with chunk size 512 and identical observed tokens. Chunking changes
the numerical graph, so this does not prove identity against chunk size 2048.
These direct workers bypass serving admission and pressure safeguards; their
failures do not establish a regression in the repaired serving path. Evidence:
`reports/qwen38-rd/native-memory-ledger.json` and `native-memory-chunk512-screen/`.
Remaining quants and packed controls are separate cells. See
[benchmark tooling](../reference/benchmarks.md) for commands.

### 7.2 Freeze the controls and workload matrix

Start with packed Q3, the affine flagship, plain RTN4, compact affine, and
published OptiQ. Retain the down-input-axis and unrotated artifacts as known
quality-failure controls. Inventory the fake-quant and carrier artifacts,
but do not load them on a machine where the full working set cannot fit.
The bf16 teacher uses the existing streamed KL procedure on these Macs.
Test every available artifact once; expand expensive sweeps around survivors.

| axis | cells and controls |
|---|---|
| Stack | Same affine snapshot on mlx-bun serial and pinned mlx-lm first; default scheduler separately. Packed trellis has no stock mlx-lm loader. Its carrier is a different precision and footprint. vLLM-Metal is a same-MLX comparison where the artifact is supported; llama.cpp/GGUF is a separately qualified ecosystem comparison. |
| Weights | Existing artifacts first; affine 2/3/4/5/6/8-bit with supported group sizes 32/64/128; mixed allocation; rotated/plain RTN and calibrated recipes; trellis k2/k3/k4 mixtures and the Q5 2.75 budget; supported mxfp4/nvfp4; new codes or layouts after microkernel evidence. Do not equate nominal bits with total bytes. |
| Context | 128, 1k, 4k, 8k, 16k and 32k prompt tokens; 64k and larger only after a measured memory projection. Decode at each depth, without generating an entire long context to establish it. |
| Prefill | Chunk sizes 128/256/512/1024/2048, plus unsplit only when it fits. Test a partial final chunk, cached suffixes, and the one-token tail convention. |
| Output | 256 generated tokens for screening, plus a sustained 1024-token cell for finalists. Record actual counts, EOS and finish reasons. Never score early EOS as faster completion of the same task. |
| B and M | B=1 serial control; scheduler concurrency 1/2/4/8 as memory permits. Kernel M=1/2/3/4/5/8/16/32/128/512, including B×sequence products with the same M but different cache semantics. |
| KV | bf16, affine KV8/KV4, then TurboQuant k8v3 and measured alternatives. GDN state is a separate allocation. Verify the active codec, bytes and dispatch; RSS is insufficient. |
| Work | Plain text, long reasoning, code generation/editing, multi-turn tool sessions, structured output, raw completions including the EOS-cliff items. Screen text first; finalists also cover repeated images and short video. |
| Reuse | Cold process, process-warm with cold prompt, RAM prefix hit, SSD restore, exact resumed generation and edited-prefix miss. Pin cache budget and checkpoint policy. |
| Replay/spec | Fill off baseline; strict no-verification fill; echo separately; MTP off/on only after head/verify economics. Unsupported combinations get a reason, not a silently inactive arm. |

Freeze prompt token IDs, tokenizer/template hashes, thinking mode, tools,
stop policy, sampler settings, context and output budgets. Use the same
prompt and initial cache state within each pair. Greedy engine tests and
representative stochastic serving tests answer different questions.

Record source commit plus source diff hash, model revision and shard content
hashes or existing trusted manifests, quantization map, compiled native library
and metallib hashes, Python packages, Bun, OS, chip, RAM, wired limit, disk,
power and thermal state. Hash large payloads outside timed runs. A matching
config hash does not prove identical weights. Keep pinned-oracle comparisons
separate from an isolated newer-MLX experiment; never upgrade the oracle in place.

### 7.3 Account for the complete graph

Generation and serving each need a measured baseline and acceptance result.
Native timing covers model computation, generation-loop scheduling and state
cleanup. HTTP timing additionally covers preparation, admission/queue wait,
cache lookup/restore, transport and stream completion. Measure cold prompts,
RAM hits, SSD restores, edited prefixes, concurrent requests, disconnects
and continued tool sessions. Keep per-request TTFT, stream gaps, complete
request latency and aggregate throughput; a burst of SSE chunks is not a
sequence of individually timed model tokens. Attribute the server overhead
using request traces and matched native work, accounting for cache, batching
and sampler differences before subtracting timings.

Tune operations by their contracts, not by the model name. Each candidate
records supported shapes, dtypes, strides, quant layout, reduction/rounding
order, state ownership, hardware and workspace limits. Compare applicable
algorithms and tune dispatch across those regimes. Retained kernels belong
in the shared operation layer; model code selects them only when the
contract holds and retains a tested fallback. Other models using that
operation need their own call-site and full-model gates. A winner on this
Qwen/M4 shape is evidence for that cell, not a universal best kernel.

Use the knowledge graph to discover definitions, then follow the actual
implementations and MLX/Metal dispatch. The static index sometimes resolves
generic `forward`, `state` and `dispose` methods to unrelated classes. It is
a navigation aid; runtime traces establish the executed graph.

| stage | local entry points and work to account for |
|---|---|
| Request and admission | `serve/request-prep.ts`, `chat-stage.ts`, `session-completion-engine.ts`, `generation-gateway.ts`, `engine/session.ts` and `execution-coordinator.ts`: tokenization, demand, queue/lease wait, resolved policy, actual lane and admission. |
| Model and method binding | `model/implementation.ts`, `backends/mlx/model-serving.ts`, `graph.ts`, `autoregressive.ts` and `serial-executor.ts`: exact registration, captured runtime, hidden-state/logit selection, state ownership and native execution. Trace the selected method rather than assuming every registration uses the compatibility binder. |
| Prefill scheduling | `inference/prefill.ts`, `backends/mlx/prefill.ts` and `batch-group.ts`: shared chunk/tail/snapshot decisions, cache evaluation, maintenance, temporary disposal and scheduler yields. Distinguish shared scheduling from B-wide kernels. |
| Embedding and output | `qwen3_5.ts`, `gemma4-base.ts`: embedding gather/dequant, final norm, untied vocabulary projection, dtype casts, sample/logits processors and host token readback. Include both embedding and head storage. |
| Every layer | `Qwen3Layer.forward`: input/post-attention RMSNorm and residual adds. Count each dispatch, view, materialized copy and temporary. |
| GDN projections | `GatedDeltaNet.forward`: qkv, z, a, b and output projections, including small head projections often missed by MLP-only profiling. |
| GDN convolution | Prefix concat, depthwise conv, SiLU, tail copy, state lifetime and update; distinguish S=1 from prefill. |
| GDN recurrence | `qwen3-delta.ts`: q/k normalization/scaling, computeG, sigmoid beta, scan, f32 state reads/writes, gated normalization and speculative prefix replay. |
| Full attention | q-plus-output-gate projection, k/v projections, q/k norms, reshape/transpose, RoPE/mRoPE, cache update, SDPA dispatch, output gate and o projection. |
| Quantized attention | `quantized-sdpa.ts` and `turboquant/`: quantize, pack, gather/dequantize, tile attention, rotations and reductions. Trace the selected branch and its masks. |
| MLP | Affine QMV/QMM; trellis reduce/scatter/expand/fused gate-up; split-K partials, final sum/cast, SwiGLU and down projection for all 192 matrices. |
| Generation loop | `generate.ts`, `backends/mlx/request-policy.ts`, `engine/resources.ts`, `mlx/ops.ts`, `mlx/ffi.ts`: graph construction, compile caches, async/blocking eval, pending sample and readback ownership, cancellation, disposal and memory cache management. |
| Reuse and persistence | `prompt-cache.ts`, `kv-store.ts`, `ssd-cache.ts`: hashes, snapshots, state copies, cache-owned views, disk stalls, generation-lock contention and cancellation. |
| Optional paths | `spec/serve-loop.ts`, `qwen-mtp-source.ts`, `fill/*`, batch scheduler, grammar sampling, vision tower/merger and image feature reuse. Activate and trace each separately. |

For each exercised regime export the MLX graph before materialization and
capture a warmed Metal trace. Use production scheduling for attribution;
profiled/debug captures are never the reported timing run. MLX documents
graph capture and source-labelled debug builds in its
[Metal debugger guide](https://ml-explore.github.io/mlx/build/html/dev/metal_debugger.html).
The installed mlx-c exports `mlx_export_to_dot(FILE*, mlx_node_namer,
mlx_vector_array)`; its header and dylib symbol were checked without loading
MLX. The Bun wrapper still needs that graph-export binding. Metal capture already
exists as `metalCapture(path, fn)` in `src/mlx/metal-kernel.ts`, bound to
`mlx_metal_start_capture`/`stop_capture`. Reuse it with
`MTL_CAPTURE_ENABLED=1`; warm first, then evaluate outputs and cache state
inside its synchronous callback so the capture contains executed work.
Use Instruments for host/encode timing and counters alongside the capture.

Export each region before its existing evaluation barrier. A graph exported
only after the full forward can omit already-materialized projections and
earlier prefill chunks. Join the fragments using named tensor/state edges and
an explicit barrier ledger; do not remove the memory bounds to obtain a larger
graph. Compiled/custom operations also require their source-level subgraphs
and Metal pipelines in the coverage record.

Each kernel row records caller, shader/pipeline, shape, strides, dtype,
quantization, grid/threadgroup, registers/spills where tooling exposes them,
threadgroup memory, dispatch count, GPU duration, logical read/write bytes,
intermediate allocations and synchronization edges. Use counters to distinguish
bandwidth, instruction throughput, latency and occupancy limits. Logical
bytes divided by time is not a measurement of DRAM traffic.

Cover all shader dispatches, graph nodes and explicit host/GPU waits in every
selected regime. Group identical shapes for tuning, but retain layer counts
and call-site mapping. Reconcile GPU intervals and host gaps with end-to-end
wall time; investigate an unexplained remainder above 5%. Overlapping kernel
times must not be added as though they were serial wall time. Untested branches
remain marked untested.

Microbench both dependent repeated work and independent work with production
pipeline depth. Warm compilation, evaluate outputs and state, then time batches
of operations with one final synchronization. Avoid an `eval()` per tiny op
unless explicitly measuring sync overhead. Check against the real forward:
constant-input reuse, cached expansions or dead graphs can create false wins.

### 7.4 Experiments, in execution order

This is the initial search set. Each row expands into single-variable trials
with its source reference, gate, raw result and stopping reason in the run
ledger. A candidate's priority changes when the measured graph changes.

| ID | experiment | measure and deciding condition |
|---|---|---|
| R0 | Exact artifact and execution controls for performance | Freeze `673b43f` plus the integrated local diff; matched token IDs, active graph/method/quant, raw timings and actual memory. Use relevant numerical and lifetime gates; the wider refactor acceptance program is separate. The M4 DeltaNet golden cell is resolved (§7.1; environment.md). |
| R1 | Packed prefill tile decode plus matmul | Decode a tile into registers/threadgroup storage and consume it with supported Metal matrix operations. Compare with bounded dense expansion. Win must lower TTFT without a larger peak live working set. |
| R2 | Bounded expansion scheduling | Compare per-projection, per-layer and bounded groups of projections; include cache outputs in dependencies. Test async evaluation and explicit memory budgets. A removed wait is a win only if memory lifetime stays bounded. |
| R3 | Axis-0 scatter layout and split-K | Sweep splits 16/32/64/128/256, lane/output ownership, row tiling, vector loads and split-reduction fusion. Preserve the rotated coding axis. Include partial-buffer traffic and final reduction. |
| R4 | Axis-1 reduce and gate/up fusion | Sweep 64/128/256 threads, rows per group, run unrolling, accumulator count and fused/separate gate-up. Inspect spills and occupancy; tune mixed-k eligibility rather than forcing incompatible fusions. |
| R5 | Decode primitive | Compare precise/refined reciprocal, existing f32 variant, bf16-rounded reference, compressed/half LUT, hybrid lookup/computation and alternate computed codes. Exact rewrites keep identical decoded weights; changed codes need a new artifact and quality gate. |
| R6 | Offline repacking without re-quantization | Tile/interleave code words and scales to make down-proj reads coalesced; optional expanded state-window indices trade bytes for ALU. Prove all reconstructed weights identical before model measurements. |
| R7 | Small-M packed kernel | Reuse each decoded weight across 2/3/4/5/8 input vectors. Measure the M=4/5 boundary, fill spans and MTP verifies. Tune crossover by chip, shape, k and dtype, including temporary memory. |
| R8 | Fused GDN conv/state/SiLU | Specialize the short convolution, update the state tail in the same dispatch, preserve the oracle's intermediate rounding. Compare vLLM-Metal's fused implementation; no blanket claim that it is L1-equivalent. |
| R9 | GDN norm, gates and recurrence | Fuse q/k scaling into normalization, combine gate math where legal, unroll Dk loops, test layout/TG_DV, register-resident state and output norm/gate fusion. Validate f32 recurrent state, not just next-token logits. |
| R10 | Parallel/chunkwise GDN prefill | Compare the sequential scan with chunkwise matrix formulations, scan decompositions and recomputation/workspace tradeoffs. Investigate CUDA CuTe/FLA algorithms; re-derive for Metal. Different reduction order is a Lab candidate unless exactness is proven. |
| R11 | Affine QMV/QMM and native builds | Real Qwen shapes at every available bit/group size; compare current binary, newer MLX and selected backports, plus llama.cpp Metal tiling. Keep L1 against the matching oracle build. |
| R12 | Norm/residual/activation/projection fusion | Enumerate producer/consumer pairs throughout the graph, including full-attention output gating and compatible QKV or GDN projections. Measure copy cost, register pressure and changed reductions. Older CPM5 fusion losses do not settle Qwen trellis. |
| R13 | Attention and KV | Stock SDPA dispatch, tiling, grouped-query reuse, fused KV append/quantize, direct attention over compressed KV, mask specialization, RoPE fusion and paged versus contiguous storage. Measure quality, TTFT and decode by depth. |
| R14 | Vocabulary head and sampler | Last-position-only projection, exact fused matvec/argmax for eligible greedy requests, GPU logits processors, reduced readbacks and structured-output singleton runs. Head elimination must respect logprobs and sampling contracts. |
| R15 | Deterministic no-verification replay | Follow section 7.5. Improve proven coverage and span execution economics; report wall time and output identity independently. This is a first-class track ahead of speculative drafter training. |
| R16 | MLX graph and loop | Use model-owned graph/method bindings for compiled regions, stable buffers/shapes, graph replay, cache donation, allocation removal, bounded device-side chaining and host/GPU overlap. Measure session/lease/readback costs without adding per-op evals. Preserve cancellation and ownership gates. | |  |  | Early-output native, HTTP, cancellation/overlap and cached/SSD acceptance is complete; see benchmarks.md for monitored repeats and activity limits. Scoped Llama submission-limit integration remains a separate model-owned candidate.
| R17 | Hybrid prefix and recurrent state reuse | Exact prefixes, semantic anchors, page/block storage, compact active-state updates and checkpoint cadence. Test mixed prompt edits and cancellation; no KV-only hit that loses the corresponding recurrent state. |
| R18 | Scheduler | Solo latency, actual B-wide prefill, continuous batching, chunked-prefill/decode interleaving and shape buckets. Report per-request latency and aggregate throughput; one cannot substitute for the other. |
| R19 | Weight-quality allocation | Measured latency-aware allocation across MLP, attention, GDN, embedding and head; GPTQ/LDLQ calibration and damping; QTIP/YAQA rounding; group size, k, L, block length, rotations and sensitive-layer exceptions. Optimize quality/bytes/time together. |
| R20 | MTP economics | Off versus gamma 1/2/3/4 with a compatible head; head quantization, bounded adaptive gamma, verification cost, state replay and peak residency. Native MTP's previous loss is the control. Accept-rate improvements alone fail. |
| R21 | Other exact speculative sources | Prompt lookup, n-grams, suffix reuse and smaller draft models; grammar-aware proposals. Include target verification and rollback cost. This is separate from proven assert replay. |
| R22 | Residency and shared memory | Weight loading, mmap/page alignment, wired-budget scopes, allocator cache, copy elimination and snapshot ownership. CPU work shares memory bandwidth with the GPU; overlap is measured, not presumed free. |
| R23 | Media and task completion | Image/video tower, preprocessing, encoder feature cache and merger, plus tool streaming, checkpoint stalls and reconnects. Finalists must improve the actual agent session, not only synthetic decode. |
| R24 | Larger departures | Learned/codebook quantization, sparse residual/outlier correction, activation quantization, pruning, layer skipping, low-rank approximations, QAT/distillation and alternative drafters. First estimate kernel support, quality, training memory and maximum possible benefit; only feasible candidates advance to bounded experiments. |

For every row first derive its maximum possible end-to-end gain from the
observed critical path. If a part occupies fraction f and could become s
times faster, the serial approximation is `1 / (1 - f + f/s)`; account for
overlap separately. A poor bound can close a candidate for this workload,
provided its inputs and assumptions are recorded. A previous negative result
on another chip, format or batch shape cannot close the current cell.

### 7.5 Deterministic replay without verification

The intended fast path is to emit a known span, run one state-advancing append,
and resume prediction at its end. Normal serving performs no token verification
for an asserted span. Correctness audits are separate runs and are not part of
that timing. The implementation details and contract now live in
speculative-decoding section 7.4.

Inventory candidate spans by tool schema, template, parser state and actual
token boundaries. Separate a unique continuation under enforced constraints,
a deterministic application transform, an exact cached continuation under the
same state/policy, and a merely frequent continuation. Repeated text or a
temperature-zero model is not by itself proof that a suffix is known.

Screen the existing strict rows first. They currently use a suffix match,
so test triggers inside quoted tool syntax, code blocks, prose and prior roles.
Exercise shared tool-name prefixes, multiple calls, optional/extra keys,
`additionalProperties`, escaped values, stop/EOS within spans, whitespace
merges and non-ASCII tokenization. Template token containment establishes a
possible serialization; the 27B output gate establishes observed agreement.
A universally valid claim needs a rule that enforces the unique continuation.

The existing strict weights test can now select an exact artifact using
`MLX_BUN_TEST_FILL_MODEL`. Run it on the flagship and packed Q3, then expand
to all retained quants and a frozen adversarial/real-session corpus. Compare
every emitted token, stop decision, KV offset and subsequent teacher-forced
logits/state. Require nonzero fills. Keep a held-out set of sessions unused
while designing the rows. A passing small regression test is not a proof for
all possible prompts.

Then optimize the actual mechanism: remove redundant in-flight vocabulary
work where pipeline ordering allows it, combine adjacent determined spans,
cache compiled schema plans by exact tokenizer/template/tools identity, and
choose append chunking from the packed M curve. Strict fill currently excludes
batch placement, grammar, quantized KV, media, mounted drafts, logprobs and
fixed seeds through its eligibility checks. Extend one combination at a time
after proving state and sampler behavior. A mounted draft must not silently
disable the arm being called a fill benchmark.

Per event record available span length, injected length, independent agreement,
append time, vocabulary projections avoided, wasted scheduled samples and
resume cost. Per session record task outcome, TTFT, time to first tool call,
emitted tokens, prediction steps, total GPU work and wall time. Disable
`MLX_BUN_FILL_TRACE` for timings: its per-position vocabulary head/readback
reintroduces work that production assert skips. All-assert acceptance counters
are not a verification success rate.

The optimistic saving at fill fraction f is bounded by the work actually
removed. Even `1/(1-f)` assumes zero append cost and no other bottleneck.
Filled positions still traverse the state-update graph. An emitted rate above
a one-token-per-forward estimate shows amortization; it does not show that
those positions never passed through model layers.

### 7.6 MLX and Metal opportunities, with outside implementations

Start with algorithms and data dependencies. CUDA warp widths, tensor-core
instructions, shared-memory budgets, graph capture and PCIe transfer models
do not specify a good Metal implementation. Unified memory removes some
copies, while CPU/GPU contention and page residency can still dominate.
MLX can defer evaluation, fuse compiled regions, reuse buffers and overlap
graph construction with GPU work. Explicit evaluation can also be necessary
to release large live intermediates. Each opportunity needs an ownership and
memory-lifetime argument alongside its speed result.

Read source at pinned revisions and attach the relevant functions to each
experiment. The initial source snapshot is recorded in
`reports/qwen38-rd/upstream/sources.json`; downloaded code stays in reports.
Sources used for the first candidate set:

| source | transferable idea and local experiment |
|---|---|
| [vLLM-Metal fused conv](https://github.com/vllm-project/vllm-metal/blob/327d7cb7d19f47f3e32ebb1b561b535365e2b34e/vllm_metal/metal/kernels_v2/gdn_conv1d_silu_decode.metal) | Direct state-tail convolution, SiLU and compact state output in one launch, R8. Its f32 accumulation/activation order must be checked against our bf16 intermediate. |
| [vLLM-Metal lazy GDN](https://github.com/vllm-project/vllm-metal/blob/327d7cb7d19f47f3e32ebb1b561b535365e2b34e/vllm_metal/attention/impls/gdn_lazy.py) | Lazy custom operations, compact active-request states and shape-specific recurrence dispatch, R9/R16/R17. Their prefill kernel still loops across sequence positions; it is not evidence of a parallel-scan win. |
| [vLLM-Metal tiled attention](https://github.com/vllm-project/vllm-metal/blob/327d7cb7d19f47f3e32ebb1b561b535365e2b34e/vllm_metal/metal/kernels_v2/pagedattention_tiled.metal) | Paged variable-length attention and grouped-query reuse, R13/R18. M5 NAX work is a separate hardware arm, not an M1/M4 capability. |
| [vLLM Qwen GDN](https://github.com/vllm-project/vllm/blob/6cbb3c154ef1449d2b3c9131a237f36faa695734/vllm/model_executor/layers/mamba/gdn/qwen_gdn_linear_attn.py) | Fused decode and chunkwise prefill are separate regimes. Inspect gates, normalization and state layout, then derive a Metal implementation, R9/R10. |
| [vLLM hybrid cache design](https://github.com/vllm-project/vllm/blob/6cbb3c154ef1449d2b3c9131a237f36faa695734/docs/design/hybrid_kv_cache_manager.md) | Cache groups, prefix intersections and recurrent-state constraints, R17. Paging the 16 attention layers alone does not solve the 48 GDN layers. |
| [vLLM graph execution](https://github.com/vllm-project/vllm/blob/6cbb3c154ef1449d2b3c9131a237f36faa695734/docs/design/cuda_graphs.md) | Distinct decode/prefill capture regimes and shape buckets, R16/R18. MLX compilation is not CUDA Graph replay; measure which host/encode work it actually removes. |
| [llama.cpp Metal GDN](https://github.com/ggml-org/llama.cpp/blob/427291b5b34cd914a31b3fd3b61a68f6184f4b9f/ggml/src/ggml-metal/kernels/gated_delta_net.metal) | Compile-time dimensions, unrolled register state, transposed layout and optional recent-state snapshots, R9/R17/R20. Head mapping and scaling differ across implementations; preserve Qwen's equations. |
| [MLX qmv_wide](https://github.com/ml-explore/mlx/pull/3764) | Decode a weight group once and reuse across small M, R7/R11/R20. The affine path is hardware-gated upstream; inspect the binary actually loaded. |
| [MLX compilation](https://ml-explore.github.io/mlx/build/html/usage/compile.html) | Region fusion and caching, with explicit state and shape-dependent branches. Do not make the M=4/5 dispatch shapeless without proving the selected branch, R16. |
| [XGrammar MLX bitmask](https://github.com/mlc-ai/xgrammar/blob/b5048784c65f70ca20bc5fb640b06c84583b7a92/python/xgrammar/kernels/apply_token_bitmask_mlx.py) | Compiled byte-to-bitmap lookup versus direct Metal bit extraction. Both avoid the current per-token CPU float-mask expansion. Compare host cost, complete sampling time, padded vocab, dtypes and lifetime; preserve additive-mask numerics, R14/R16. |
| [QTIP](https://arxiv.org/abs/2406.11235), [YAQA](https://github.com/Cornell-RelaxML/yaqa-quantization) | Hardware-friendly computed/lookup code tradeoffs and improved rounding, R5/R19. CUDA speed results are hypotheses on Metal. |
| [Gated Delta Networks](https://arxiv.org/abs/2412.06464) | Parallel training/chunk formulations of the gated delta rule, R10. Compare the equations and long-run state drift before a Metal implementation. |
| [T-MAC](https://github.com/microsoft/T-MAC) | Activation lookup tables for mixed-precision CPU matmul, R5/R22/R24. Its bit-plane representation is not the current trellis code, and CPU work competes for shared bandwidth; test format compatibility and total wall time. |
| [SGLang jump-forward removal](https://github.com/sgl-project/sglang/pull/4032) | The old scheduler's jump-forward path was removed for maintenance in March 2025. Study its grammar/state/tokenization integration for R15/R18; an old feature description or residual API is not a current runnable baseline. |

Continue the source search around each measured bottleneck: FlashAttention
tiling and online softmax, FlashInfer, FLA chunk algorithms, SGLang prefix reuse
and structured-output jump-forward, MLX-LM/OptiQ/oMLX scheduling, and low-bit
lookup methods such as T-MAC. Record a specific paper/function, hardware
assumptions, local counterpart and falsifiable test before a port. CPU SIMD
and GPU cooperating on shared memory are also candidates where the dependency
graph permits it. No GPU-wide synchronization or persistent megakernel is
assumed safe across threadgroups without a documented Metal mechanism.

### 7.7 Gates, scheduling and completion

First establish trustworthy controls. Then capture the graph, run R1–R7 and
R15 on the packed artifact, and R8–R14/R16 on both packed and affine controls.
Use R17–R23 for full-serving improvements and interactions. Run R19 throughout
the kernel work so the allocation objective uses measured latency, not bits
alone. R24 advances only after a feasible memory/quality/cost screen.

Use a warmup followed by at least five paired measurement blocks for an
initial verdict, alternating or randomizing AB/BA within a balanced schedule.
One model-owning process at a time on these Macs; restart paired server arms
sequentially when both do not fit. Control cold-cache and warm-cache trials
explicitly. Preserve all samples and interruptions. Do not keep retrying until
a favorable result appears. Recheck residency, swap activity and thermal state
between cells, and repeat finalists in a separate quiet-machine session.

Estimate paired log-ratio confidence intervals with sessions/prompts as the
independent units. A default speed win should exceed 3% and have a 95% lower
bound above no improvement on its declared workload. Smaller repeatable wins
may justify simple changes, with their uncertainty reported. Use enough
requests to estimate tail latency; a handful of runs cannot establish p99.
Test isolated wins together, since fusion, quant allocation, batching and fill
often interact. Keep the incumbent if the combined arm regresses.

L1/L2 changes pass the existing same-state oracle logit gates at matching B
and machine. Trellis repacks also prove every reconstructed weight identical.
Changed reductions/precision/algorithms enter Lab with teacher-forced logits
and recurrent-state checks over chunk boundaries and long continuations.
Evaluate actual packed serving, not only the carrier. Quantization quality
uses frozen KL/ppl screens plus MMLU, templated GSM, raw GSM, code/tool tasks
and the existing six-task suite. Track per-item failures and immediate EOS.
Use a held-out set for finalists. Define task noninferiority margins before
the trial and collect enough items to resolve them; n=50/100 is a screen,
not evidence that a small quality regression is absent.

Every candidate gets one outcome: repeatable win, measured loss, inconclusive
with the next discriminating experiment, proven inapplicable to this hardware,
or blocked with the missing resource named. Record hypothesis, baseline and
candidate revisions, changed parameter, expected limiting resource, artifact,
workload, correctness/quality evidence, performance distribution, memory,
decision and the condition that would justify reopening it. Save raw samples,
traces and commands in reports; record measured runs in the eval DB; promote
only qualified numbers to [benchmarks.md](../reference/benchmarks.md).

The campaign is exhausted for a declared machine/workload when every row has
such evidence, all exercised graph branches are accounted for, finalists pass
the combined and held-out gates, and a final source review finds no untested
applicable candidate with meaningful remaining headroom. Blocked or
unmeasured rows do not count as exhausted. This is a reproducible stopping
rule for a finite search, not a claim that no future algorithm can be faster.
§7.13 is the outcome ledger this rule requires: one row per R0–R24 with its
outcome, retained flags, evidence, next discriminating step and reopen
condition.

The scope also includes every owned kernel and native operation used by the
project's other model paths. Maintain an inventory of dispatch sites, generated
specializations, dtype/shape/layout eligibility, callers, reference behavior,
available workloads and measurements. Cover attention, projections, recurrent
layers, embeddings, normalization, activation, sampling, masks, cache codecs,
media paths and streamed experts, including graph construction and host work.
Each inventory row needs an explicit result; a Qwen-only trace cannot close
an operation used elsewhere. Keep unavailable-model or hardware cells visible.
Run the final comparison on a quiet machine and record its host/chip/RAM.
Pin source, runtime/library versions, artifacts, request settings and
cache state so kernel gains are not confused with different test conditions.

The final task benchmark uses
[Luke's published kanban prompt](https://github.com/lukesdevlab/youtube/blob/3288d1918fa6140c10f3b2de2d37f9d717a5ab75/prompts/kanban.txt),
pinned before execution (SHA-256
`c40b3c8e0e4d37b316179281aafef187839df7bb0e945f5c1d0f6c5b79fbb521`).
It requests a local vanilla web app with board/card editing, drag-and-drop,
archive/restore, combined filters, themes and persistence. The upstream prompt
asks the builder to verify through code review; independent browser evaluation
happens after the agent finishes. Preserve the exact prompt in each run.
The upstream repo supplies model settings but does not establish a pinned
agent harness for this comparison. Record our harness and any differences
explicitly; this is not a hardware-matched reproduction of a video score.

Before running that final task, freeze one agent/tool interface, system prompt,
dependencies, context/output/turn/time limits and seed list for every arm.
Use clean isolated workspaces and identical tool access; save the full request,
response, tool, usage and timing trace. Run the incumbent and final engine
configurations on the same artifacts, with same-artifact MLX-LM controls where
supported. Test different quants as separate quality/performance arms. Keep
MTP, replay and cache policy explicit. Do not repair generated code during
scoring or use final-task output to tune the candidate being evaluated.

| Final task measure | Evidence and interpretation |
|---|---|
| Completion | All required behavior works without manual edits; report partial completion and timeouts. |
| Functional behavior | Exercise edits, card/column movement, safe deletion, restoration, combined filters and reload persistence in a fresh browser profile. |
| Usability | Record keyboard behavior, empty states, feedback and screenshots in both themes. |
| Complete task time | Measure from first agent request to its completion, plus evaluation time separately. |
| Engine contribution | Per-turn queue/TTFT/decode time, prompt/generated/cached tokens, tool round count, retries, errors and compactions. |
| Resource use | Peak active/RSS/wired memory, swap activity, cache bytes and actual serving lane. |
| Repeatability | All prespecified runs and seeds, including failures; compare success rate and time conditional on completion. |

Source snapshots and the manifest are in
`reports/qwen38-rd/lukes-kanban/`. The first attempted task is preserved in
`reports/qwen38-rd/kanban-final/optimized-mtp-invalid-32k-sleep/` and excluded
from completion-time claims. Its Pi profile incorrectly declared 32,768 tokens,
causing premature compaction, and macOS sleep interrupted the run. The artifact
declares 262,144 positions. The corrected profile derives the effective window
from that metadata and the server's admission limit, recording both separately.
Use Pi's standard compaction reserve and recent-history settings, hold
`caffeinate -is`, and record real wall time plus active monotonic time. The
original profile, traces and partial app remain available.

The corrected thinking-off candidate completed generation without compaction,
but failed static app acceptance: `main.js` redeclared a `let` variable and the
requested README was absent. No manual edits or repair prompts were supplied.
The original-source task exhausted two automatic retries during a long tool
response. That run is excluded from task-time comparison because the recording
proxy inherited Bun's socket idle timeout. An independent six-minute silent
stream reproduces the default timeout and completes with `timeout: false`.
Pi's own HTTP idle setting is now explicit. The runner also reads Pi's terminal
events, because an exhausted retry can still leave a zero process exit code.

Josh corrected the benchmark configuration: the task must use a named profile
from Luke's `model-configs.ini`, including its sampling, context, thinking and
effort settings. The agent-selected greedy configurations are invalid for this
benchmark, including the later thinking-enabled attempt, which was stopped.
Do not reuse their times as Luke benchmark results. The pinned prompt itself
matches upstream. The profile audit resolves inherited defaults, records source
hashes and rejects missing effort or changed sampling values. Context and effort
differ across Luke's coding profiles. The selected section is
`qwen3.8-27b-q3_k_xl-coding-128k`: 131072 context, xhigh thinking, temperature
0.6, top-p 0.95, top-k 20, min-p 0, presence penalty 0 and inherited seed 42.
The task uses that exact prompt and request recipe. Its first attempt was
stopped after a serving bug discarded the preceding thinking on tool turns.

The MTP-prefix integration (merged in PR #47) permits Qwen uniform KV4 with start=0
behind `MLX_BUN_QWEN_SPEC_KV4`. Prefill converts attention caches through
`maybeQuantizeKv`; rollback binds after conversion, and prefix identity includes
KV bits, group size and conversion policy. Recurrent state remains full precision.
A native sampled test restores all sixteen quantized target layers plus draft
state with identical continuation after forced rejected drafts. The HTTP check
also preserves repeated output and acceptance decisions, with active speculation
and cache reuse. The initial native coverage check failed only because its
repetitive prompt accepted every draft; the forced-rejection check supplies that
missing coverage. Both records remain in `reports/qwen38-rd/`.

This is an explicit MLX adaptation. The target remains Josh's required packed
12 GB Trellis artifact. MLX affine KV4 group64 differs from GGUF q4_0; the single
MTP-layer cache stays bf16. The corrected-history run uses the profile’s 256-token batch
size for MLX prefill, bounding long-context attention workspace.
`MLX_BUN_RD_CONTEXT_LIMIT` narrows the isolated server's physical admission
ceiling to exactly 131072, never enlarges it. Pi uses the same context and
xhigh effort. Responses run until EOS or remaining context, with no invented
16K cap. Task timing includes automatic tool use and retries; app scoring
follows after inference exits. The completed retry is recorded below.
Raw evidence and invalid runs remain in `reports/qwen38-rd/kanban-final/`.

The paired cache currently captures prompt checkpoints only. Extending it to
verified generated boundaries is still open: preserve target, draft and pending
hidden alignment, and require an exact prefix of the next rendered conversation.
Tool-argument serialization can change tokenization, so a completed-response
snapshot alone cannot replace the earlier stable-prefix checkpoint. The uniform
KV4 prefill path also retains native unfused quantized attention, which materializes
query-by-context scores. Long tool-turn prefill needs its own memory and timing
acceptance; decode memory alone does not establish that result. Measured task sources stay frozen while these costs are measured.

The stopped profile attempt also reproduced a protocol bug. Pi returns prior
assistant thinking as `reasoning`; Qwen’s template reads `reasoning_content`.
Despite `preserve_thinking: true`, normalization previously dropped that history
from the rendered prompt. The fix supplies the canonical alias without mutating
the input or replacing an explicit canonical string. Unit tests cover tool calls,
rendering and precedence. The recorded request now retains its complete reasoning.
The active runner independently renders each prompt and checks its token count
against engine usage. This failure remains separate from the earlier attempts
that used incorrect sampling settings.

The subsequent long-history HTTP gate passes with the corrected normalizer,
256-token prefill, target KV4 and MTP. Cold and restored requests preserve
output and draft acceptance, including naturally rejected proposals. The
corrected-history task runs with source hashes frozen and all original settings
retained. Evidence: `reports/qwen38-rd/luke-history-kv4-preflight.json` and
`reports/qwen38-rd/kanban-final/luke-q3-128k-xhigh-history-fixed/`.

That task ended with only three app files. All prompt counts and MTP/cache
checks passed, but a valid nested edit array failed in tool parsing. Qwen
parameters now follow the pinned mlx-lm parser: raw entity text, with one
framing newline removed at each end. Outer Qwen markup is selected before
JSON repair can misread a parameter as a tool envelope. Legacy attribute XML
keeps its existing decoding policy. The actual saved response now produces
one intact edit call through the real tokenizer and streaming parser.
Regression tests, strict-fill checks, both workspace typechecks and hygiene
pass. The raw failed result and untouched app remain preserved; its numbers
are in benchmarks.md. The fresh run with both fixes is preserved in
`reports/qwen38-rd/kanban-final/luke-q3-128k-xhigh-tool-values-fixed/`.

That run ended in a Metal out-of-memory error during the next long-history
turn, before Pi finished. Completed requests kept the full rendered history
and used MTP with cached prefixes. Static checks find no README. The separate
browser smoke confirms basic creation but finds a blocking card-editor
ReferenceError in the incomplete app. Its source is unchanged; no repair
prompts were supplied. Timings, counts and memory measurements live in
[benchmarks.md](../reference/benchmarks.md#fresh-pi-kanban-diagnostic-m4-pro-2026-09-07).

Do not promote the isolated KV4/MTP/prefix composition or claim a successful
task-time gain. Josh's known workload is roughly 100,000 generated tokens,
including thinking, plus the initial prompt and subsequent tool history.
Fixing only the observed failure boundary is insufficient. Start with a
110,000-token accumulated-context capacity screen, then check sustained
generation, tool turns and cache reuse beyond the expected task size, within
the unchanged published context settings. A short continuation at a large
synthetic context is a memory screen, not proof of full task completion.
The unchanged initial capacity screen finished target prefill but failed
inside the first MTP draft round. Allocation traces and source hashes are
preserved; numbers live in benchmarks.md. Draft prefill built a deferred KV
graph across every chunk, and its pending hidden row was a view into the
complete prompt buffer. The main source and isolated candidate now evaluate only draft KV
at each existing chunk boundary and materialize the retained final row.
Unused prefill attention/MLP outputs stay unevaluated. A focused allocation
test fails before this change and passes afterwards. A separate sampling
failure test exposed unowned in-flight output and logits; scoped disposal
now releases them on errors as well. The small full-model comparison retains
exact output tokens and MTP acceptance traces, including cached replay.
The final-source native capacity screen completes repeated continuations at
the larger context, preserves exact cached replay and recovers after an
injected output-sink failure without additional retained request memory.
Main-source ownership tests, a real-target short MTP identity gate and both
workspace typechecks pass. Saved-history HTTP acceptance also passes, including
the failed request, conversation growth and exact replay at the larger context.
The guarded fresh Pi retry also failed with Metal out of memory, this time
during sustained decode rather than the first draft after prefill. Its source
and profile stayed fixed. The complete first response and its MTP acceptance
trace match the preceding task; later tool results reflect their actual runs.
The untouched app supplies its README but fails both the card-editor and
archive-panel checks. Measurement and quality audits are preserved beside
the raw result in `kanban-final/luke-q3-128k-xhigh-mtp-memory-fixed/`.
This failure leaves sustained-generation acceptance open. The passing short
capacity checks do not establish reliability over the full workload.

The sustained allocation trace identifies a separate lifetime problem in
`mlx/ops.ts`: the range cache retained every distinct large `arange` for the
process lifetime. Quantized causal attention requests a new context-length
range on each verification round above the cache's minimum length. Disposing
the returned mask view did not release the cache's owner. The range cache now
limits retained array data to 8 MiB, evicts least recently used owners with
explicit disposal, and leaves oversized ranges owned only by their callers.
Repeated vocabulary and attention-layer ranges still share storage; outstanding
lazy views retain their native references after eviction. The focused allocation
regression fails before this change and passes afterwards. The full-model
sustained repeat preserves every output token and MTP acceptance decision,
with fixed sources and bounded retained allocation after model disposal.
Numbers and the single-pair timing limitation are in benchmarks.md.

After fresh-task acceptance, screen a reusable integer position-range prefix
and the native integer `arange` path on Bun 1.4 against this bounded-cache
baseline. The current minimum cache length still rebuilds smaller attention
ranges across layers. Keep exact range/mask values, outstanding-view ownership
and the memory bound as gates; measure complete prefill and verification rounds
before retaining an allocation or dispatch optimization.

The pinned MLX 0.32.2 source also gives a specific native scheduling experiment
for the three-query KV4 verification window. Qwen's 24 query heads share four
KV heads (GQA6), with D256. `quantizedSdpaUnfused` currently presents the heads
as separate broadcast batches. In `mlx/backend/metal/quantized.cpp`, the
M4-eligible affine key multiplication selects `qmv_wide`: three vectors per
threadgroup, eight reduction lanes, and a separate batch for each query head.
Its code already reuses weights across the three query positions.

Screen pairing two query heads in the key multiplication only. Reshaping the
query from `[B,KV,6,3,D]` to `[B,KV,3,6,D]` keeps this dispatch below its matrix
threshold and keeps the native vector tile at three. The grid changes from
`(1,ceil(N/8),24)` to `(2,ceil(N/8),12)` for B=1, offering a way to change K
reuse and scheduling through native MLX operations. Restore the original score
shape before masking and softmax. This is an unmeasured hypothesis: actual
shader dispatch, layout/materialization and exact output must be checked;
source-level broadcast does not establish actual DRAM traffic.
If the paired-head screen passes, also screen groups of three heads. Its nine
query rows remain below the matrix threshold, but MLX selects five vectors per
threadgroup rather than three. That changes the compiled kernel specialization;
do not infer numerical identity from the common source body. Measure both real
strided queries and contiguous queries: `ensure_row_contiguous_matrix` may add
a copy before multiplication, and the complete attention timing must include it.
The recorded CLI selects uniform `--kv-quant 4`, which configures the unfused
MLX-LM composition through `applyDecodeRoute`; this runtime option is not an
inherited environment variable. Preserve that selection in the control. A
smaller graph experiment can reuse one materialized causal mask across Qwen's
full-attention layers: `forwardLayers` already shares a mask object, but its
causal string currently rebuilds the boolean array in each unfused attention
call. Keep the bf16 and OptiQ dispatch policies intact and measure the retained
mask's lifetime as well as complete-forward timing before retaining that change.

Do not apply that fold indiscriminately to the value multiplication. Its native
matrix threshold is four query rows, so the same reshape would change the
algorithm. At long context it uses `qvm_split_k`, with 32 partitions beyond
8192 reduction elements and an explicit reduction of the intermediate results.
Preserve that partition and reduction contract in any custom scheduling arm.
The relevant implementation is `mlx/backend/metal/kernels/quantized.h` in the
pinned source. Run these experiments as separate arms against the frozen successful task's
source; require operation, complete-attention, full-model and serving gates.

The fresh Pi retry with the bounded range cache completes under the same
published profile, prompt and settings, with source hashes frozen. Its untouched
app passes the required functional browser checks, including card editing,
combined filters, archive/restore, column controls, native card/header drags
and persistence. The README and modular plain-script entry are present. The
passing sustained replay preceded launch; all prior controls and failed tasks
remain preserved. No app code was edited and no repair prompts were supplied.
Browser checks ran after inference exited. The original intercepted-drag
probes and an incomplete mouse-drop probe remain beside the successful native
interaction checks, which deliver dragover before releasing the button.
Measured completion time, rates and memory are in benchmarks.md.

The completed run includes Pi context compaction. Its summary request and
subsequent work remain inside task elapsed time. Pi serializes the older conversation
into a new summary prompt, so those tokens do not share the original chat's
exact prefix. Do not substitute the old KV state merely because the transcript
describes the same history. The JSON stream uses `compaction_start`; the frozen
outcome helper counts only `auto_compaction_start`. Derived lifecycle
counts now include both event names; the raw outcome and its saved helper remain
unchanged for audit. The shared helper was corrected only after the run ended.
Assess whether Pi's compaction reserve can avoid an
unnecessary summary while keeping the published context limit and sampling
settings. Check which settings the upstream protocol actually pins before
changing a client policy, and report that arm explicitly. Include context
admission, truncated responses and subsequent task quality in its acceptance.
The existing admission limit is not proof that the composed execution fits.
Generated
history checkpoints remain a separate opportunity to remove repeated prefill;
their target, draft and pending-token state must align with the next rendered
conversation prefix. For append-only caches with an unchanged codec, also
evaluate deferring the attention-KV view capture until request cleanup while
capturing the recurrent state and pending hidden row at the checkpoint. Older
KV rows remain available in the live cache; retaining a second native owner
throughout decoding can force an otherwise avoidable copy. This requires an
explicit lifetime contract, prefix availability checks, correct cleanup on
cancellation/errors, and accounting for shared backing storage. Sliding-window
eviction or requantization of older rows must disqualify that reuse. Generated
checkpoints must match actual next-request tokens; tool serialization is not
assumed identical. Keep a valid fallback checkpoint within the memory budget.
Collect matched successful original/final task-time comparisons. The completed
run establishes a usable result on this source, not an optimization percentage.
Capacity acceptance does not establish the fastest completion method. Measure
draft acceptance and verify-window attention cost at the context depths reached
late in the actual task. Compare complete request times when tuning the draft
schedule within the published profile; short-context MTP throughput cannot
stand in for those measurements.
The pinned quantized value-product dispatch makes draft depth three a concrete
next screen: its four-position target window reaches the native matrix-kernel
threshold, whereas the current three-position window uses split-K vector
multiplication at long context. Compare depths one, two and three and an
ordinary continuation at matched context, keeping the sampling recipe fixed.
This is a source-derived scheduling hypothesis, not a measured speed claim;
each window's native arithmetic, rollback, cache reuse and completed response
remain correctness and acceptance gates.

### 7.8 Execution log (archived)

The chronological run log (2026-09-04 → 2026-09-08; harness preparation,
early first token, shared-M/tile/split-K kernels, graph exports and counter
calibration, MLX scheduling settings, shared affine kernels, GDN
specializations, strict fill, grammar mask, mmap loader, KV append census)
moved verbatim to
[qwen38-27b-campaign-log.md](../archive/investigations/qwen38-27b-campaign-log.md).
Every evidence filename it cites is kept there and resolves to
`reports/qwen38-rd/` on the measuring host. Outcomes, retained flags, next
steps and reopen conditions per row are in §7.13; §7.9–§7.12 stay live.
Changes that landed by default from that log are correctness or memory fixes,
not speed defaults: bounded 8 MiB range cache (§7.7), per-chunk draft-KV
evaluation (§7.7), compact state materialization through stock DynamicSlice,
SSD boundary-before-transfer fix, Qwen tool-parameter parser,
`reasoning_content` alias, EOS/finish-reason accounting, native pack 0.4.0.

### 7.9 Project kernel coverage

The current AST census has 37 custom Metal kernel construction sites in 15
files; frozen source controls retain the two old-core affine kernels the
MLX 0.32.2 consolidation removed (§7.12). The initial inventory also counted
355 calls into 162 distinct MLX C APIs; that count includes allocation,
configuration and graph operations, not native GPU kernels. Runtime
specializations still need shape, dtype, layout and stream coverage. Evidence:
`reports/qwen38-rd/project-kernel-consolidated-census.json` (current), with
the earlier censuses in `project-kernel-inventory.json`,
`project-kernel-coverage.json`, `project-kernel-vector-expand-addendum.json`,
`project-kernel-turboquant-addendum.json`, `project-kernel-inverse-addendum.json`
and `project-kernel-wide-addendum.json`.

| Owned kernel family | Sites | Current evidence and next coverage |
|---|---:|---|
| Packed grammar mask | 1 | Exact micro and HTTP outputs; serving timing inconclusive under external load. |
| Joint TurboQuant K/V decoding and selected inverse rotation | 2 | Experimental opt-in; exact operation/lifetime and R6/RTN4 integrated model gates pass on MLX 0.32.2. Integrated inverse-rotation HTTP passes six pairs per quant with decode gains in every pair; R6 complete time improves and RTN4 complete time is inconclusive. Six deferred-consumer pairs per MiniCPM/Gemma also improve complete requests on consolidated source. Combined/pressure and quiet acceptance remain. Direct packed-key attention is exact but slower. Details live in turboquant.md. |
| Flash attention forward, D, dKV and dQ | 4 | D256 alternative screen fails one KL gate; other attention shapes and backward costs remain. |
| GLM sparse-attention rank and contract keys | 2 | Both keys now use uint32 with stable score sorting. Operation and complete tiny-model state gates pass; six balanced pairs per shape improve selection latency. Real Colibri serving remains unmeasured. |
| GLM q4/q8 streamed expert gate/up and down | 4 | Synthetic resident-slot geometry screen and six balanced repeats preserve intermediate/output bytes and cleanup. BF16 timing is bimodal across identical process configurations; no geometry default retained. Attribute that variation before further timing claims. Real model and I/O overlap remain unmeasured. |
| Qwen causal convolution, SiLU and copied tail | 1 | Exact operation/model/state gates; fusion has no compelling full-model speed win. |
| Gated recurrent update | 1 | Unrolling, geometry, compilation and normalization fusion screened; full-model gains too small to retain. |
| Qwen multimodal rotary embedding | 1 | Direct-stride fusion preserves operation/model state, but the complete-forward gain is too small to retain. Actual image/video HTTP coverage remains. |
| Trellis reduce, scatter, expand and gate/up variants | 9 | Shared rows and fusion improve measured cells. Device codebook lookup loses. A scoped threadgroup integer table improves repeated M3/4 scatter, full forwards and MTP HTTP requests with exact outputs; M1 loses and stays procedural. Scheduling and prefill controls remain. Broader bit/axis/shape/model coverage remains. |
| Trellis split-K projection and accumulation | 2 | Short-prefill model/serving acceptance; larger shapes and additional artifacts remain. |
| Trellis tiled projection | 1 | Short axis-1 tiles accepted diagnostically; larger tiles, context and memory pressure remain. |
| Trellis native-wide prefill | 1 | Reached only under `MLX_BUN_TRELLIS_VARIANT=11..13` (default 6 expands then uses native matmul). Matches MLX 0.32.2 small-prefill arithmetic on eligible GPUs. Operation, integrated R6 state/generation and six HTTP pairs per lane pass. Short-prefill TTFT improves; broader context and quiet acceptance remain. |
| Trellis vectorized expansion | 1 | Exact operation, full-model prefill and HTTP responses. Shorter serial and default-scheduler HTTP prefills improve; existing-suite timing mostly flat. Broader context, pressure and quiet-machine gates remain. |
| Cross-entropy forward/backward variants | 7 | All seven routes pass the vocabulary-partition screen, including 54 forced-fallback cases. The isolated fast-dispatch opportunity does not apply to the available models wired into this loss path; broader real-loss profiling remains. |

The native-operation audit covers quantized/dense/gather matmul, SDPA,
normalization, rotary embeddings, elementwise activation, convolution,
reductions/sorts, indexing and scatter, quantization/dequantization, Hadamard
transforms, sampling, copies and cache growth. Account for compiled graph
boundaries, custom VJPs, host readbacks, allocator work and serialization.
An operation can remain native after a measured negative result; replacing
every kernel is not the exit criterion.

An explicit codebook lookup does not improve the tested packed decode
kernels. The corrected screen preserves all 69 cases per candidate using
float32 integer values, int16 integer values or pre-scaled float32 values.
It covers reduce, both scatter layouts and fused gate/up across f32, f16 and
bf16, including the M4/5 fallback boundary. All four processes return active
allocation to zero. At the large Qwen M1 bf16 projections, even the int16
table takes 0.802 ms versus 0.331 ms for reduce, 0.747 versus 0.443 ms for
scatter, and 1.474 versus 0.615 ms for gate/up. These diagnostic operation
losses close the candidate before full-model testing. No lookup cache or
kernel is added to production.

The first prototype changed the shared lookup table and failed dense-fallback
identity at M5/8. That fallback uses a precisely divided table, while the
packed matvec preserves the procedural decoder's multiply order. The corrected
prototype keeps the original expansion table and replaces both macro and
inline decode sites. Retain the initial failure and the corrected exact
negative result separately. Evidence is `trellis-codebook.json` and
`trellis-codebook-scoped{,-review}.json`.

The distinct threadgroup-table follow-up leaves a narrower M3/4 scatter
candidate open. Six full-model and six MTP serving pairs preserve outputs
with small gains. Its results, unchanged-prefill controls and scope live in
[turboquant.md](turboquant.md). It does not justify a one-token decode change.

A separate Metal constant-address-space table also loses at M1. Two balanced
pairs use the actual R6 packed projections, identical tensor hashes and the
same synthetic activation seed. A 4,096-entry int16 table nearly doubles
complete MLP latency in both orders on the M4 Pro with MLX 0.32.2. All four
workers exit normally and source hashes remain fixed. The benchmark's internal
v13-versus-v13 check does not compare output bytes across source arms, so this
is a rejected speed screen, not a correctness-qualified implementation. No
full-model run or production change follows. An earlier accidentally
overlapped pair was terminated and excluded. Evidence:
mlx-upgrade-0.32.2/trellis-constant-{screen,review,invalid-attempt}.json.

The four streamed-expert kernels now have a synthetic resident-slot screen.
It covers Q4/Q8, bf16/f32, M1/2/4/8 and H/I=32/32 plus 6144/2048. The larger
dimensions come from the documented Colibri slot size and need confirmation
against actual artifact metadata. One, two, four and eight SIMD groups per
threadgroup preserve every gate/up intermediate and final SwiGLU output byte
in 96 candidate comparisons. All four processes return active allocation to
zero. This excludes disk I/O and full-model execution.

Six balanced repeats at the larger dimensions preserve another 288 comparisons
across 24 fresh processes, again with zero final active allocation. The large
first-screen bf16 gains do not establish a retained geometry. Identical Q4 M2
controls vary from about 0.29 to 0.58 ms; Q8 M1 controls vary from about 0.24 to
0.51 ms. Some candidate/control pairs reverse by nearly 2x. Float32 is much
steadier and generally flat across geometries. Attribute this bf16 timing
variation before further optimization claims. No geometry default changes.
These synthetic screens were measured on the M4 Pro 24 GB. Real Colibri serving remains unavailable;
the local GLM-5.3-Flash artifact uses a different architecture. Evidence:
`streamed-expert-screen{,-review}.json` and
`streamed-expert-repeat{,-review}.json`.

Four identical four-SIMD-group processes with the normal-scheduling recorder
preserve all 64 cell outputs and return active allocation to zero. The bf16
timings are stable in this instrumented sample: Q4 M2 is 0.288–0.293 ms and
Q8 M1 is 0.240–0.244 ms. GPU command-span union per call is about 0.222 and
0.177 ms respectively, with no measured gaps between command spans. This
does not capture the slow regime seen with the normal library, so it cannot
explain that variation. The recorder uses a separately built MLX library;
its wall timings cannot select the production geometry. Preserve the
inconclusive verdict until the real workload or a control captures both
regimes. Evidence: `streamed-expert-trace{,-review}.json`.

Six balanced same-geometry blocks compare the stock library, the separate
build with recording disabled, and that build with recording enabled. All
192 candidate comparisons preserve intermediate/output bytes and every
process releases its active allocation. The bf16 variation occurs in all
three arms. Recorder timestamps now capture both regimes: the Q4 M2 median
command span per complete operation ranges from 0.230 to 0.658 ms, and Q8 M1
from 0.177 to 0.451 ms. Each measured buffer still has sixteen dispatches for
eight complete operations. Some transitions happen within one process. This
rules out host overhead alone; command spans include waits and do not isolate
the underlying GPU cause. No geometry or library change is retained. Evidence:
`streamed-expert-library{,-review}.json` and
`streamed-expert-library-span-review.json`.

The sparse-selection screen reduces the contract-order key from uint64 to
uint32: the above-threshold class needs one bit and valid MLX positions fit
in the remaining 31 bits. The score-ranking key is initially unchanged.
All 75 cases preserve selected positions and threshold bits, covering several
context/selection sizes, ties, signed zero and nonfinite values. Finite inputs
also match the host contract. Each case releases every active native byte.
Six AB/BA blocks at the deployed topK of 2,048 then preserve all 90 paired
cases. Median selection latency improves about 2–9%, or 28–39 microseconds,
on the M4 Pro 24 GB; every pair improves. This is the complete selection
operation, not model-generation or serving throughput. Evidence is
`dsa-order-u32-screen.json` and `dsa-order-u32-repeat{,-review}.json`.

The pinned MLX implementation explains the crossover: uint64 sort keys use
smaller blocks, so a 2,048-key sort takes the multi-block path. It also sends
GPU `argpartition` through a full merge sort. MLX's documented stable
`argsort` permits a second reduction: retain the 32-bit descending IEEE score
key and let stability preserve ascending positions for equal score bits.
Use `argsort` explicitly for that guarantee. This preserves the existing
special-value ranking, without relying on stability from the partition API.
Primary sources are [MLX 0.31.2 sorting](https://github.com/ml-explore/mlx/blob/v0.31.2/mlx/backend/metal/sort.cpp)
and its [stable-sort contract](https://github.com/ml-explore/mlx/blob/v0.31.2/mlx/ops.h).
The combined prototype passes the same 75 cases. Six balanced blocks then
preserve all 90 paired cases and improve every pair: median selection latency
falls 10.47–15.80% across the tested context/pattern cells. Ordinary score rows
save about 48 microseconds at 2,049 positions and 218 microseconds at 262,144.
All native active bytes are released. Evidence is
`dsa-rank-u32-screen.json` and `dsa-rank-u32-repeat{,-review}.json`.

The complete deterministic tiny-model comparison also preserves all six
teacher-forced/greedy/sampled cases at topK 1 and 2,048: every logit byte,
requested log probability, selection, cache state and usage record agrees.
Each arm executes 76 sparse selections and returns active memory to zero.
Existing model tests cover cache restore, mixed-length batching, streamed
execution, MTP and HTTP. A separate execution check confirms the transformed
module is used: all 34 tests pass. Evidence is `dsa-model-screen.json` and
`dsa-rank-u32-model-tests-v2{.txt,.transform.json}`. Bun's test run did not write
the initial process-exit observer file, so the second run asserts coverage
inside a test instead. The local artifact scan finds no compatible Colibri
configuration; the available GLM-5.3 Flash is `glm5_next`, not this
`glm_moe_dsa` path. Real-artifact serving remains open.

The exact representation change is integrated in the existing DSA module
without another flag or interface. A permanent 8,193-position test checks
threshold ties on strided float32/float16/bfloat16 inputs. The first test run
uses the wrong import location for `Dtype`; after correcting that test import,
all 34 focused production tests and the three typechecks pass. Evidence is
`dsa-production-unit-v2.txt` and `dsa-production-typecheck-v2.txt`. The complete
model-free suite also passes: 1,840 passed, 10 skipped and zero failures, with
hygiene passing. Evidence is `dsa-production-model-free.txt` and
`dsa-production-hygiene.txt`. This is a measured shared-operation improvement;
it is not a Qwen throughput claim.

The top-p sampling audit finds a removable inverse-permutation construction.
Keep the incumbent probability calculation, ascending sort and cumulative
sums, then scatter the cutoff mask directly to token positions. A pure MLX
mask scatter and a fused Metal output scatter preserve every output byte in
216 cases across four vocabularies, three dtypes, three cutoffs, strided
inputs, ties and nonfinite values. The initial run stops at its cleanup
assertion on case 109: the current path intentionally caches the large
`arange` used for inversion. Fresh-process probes attribute the retained
524,288/999,424 bytes to those index arrays, while both candidates release all
active bytes. This is an existing cache, not a disposal failure.

The corrected screen prewarms that range cache and checks cleanup against
its measured baseline. The pure MLX rewrite is mostly flat; the fused kernel
has a modest operation-level gain. Compiling all three versions also
preserves all 216 cases, with exactly one trace per compiled function and
the expected remaining range-cache bytes. Evidence is
`top-p-scatter-screen-v2{,-review}.json`,
`top-p-scatter-compiled-screen{,-review}.json` and
`top-p-lifetime-{source,native,scatter,metal}.json`. The subsequent sampler,
model and HTTP gates below determine retention. The production sampler is
unchanged.

The full seeded sampler screen then passes 180 cases across three vocabularies
and dtypes, four finite/masked distributions, both seeds and four step indices.
Top-p alone and its production combinations with top-k, min-p and XTC preserve
all sampled IDs in six implementations. All 54 compiled functions trace once;
disposal leaves only the incumbent range cache. The initial attempted B=3
case fails in the incumbent: this sampler's contract is one `[1,V]` row, as
used by sampled serving. That failed probe is retained. Evidence is
`top-p-sampler-screen-v2{,-review}.json`.

The initial complete-generation screen passes 60 generations on Llama 1B and
Qwen packed/RTN4. Emitted IDs, requested log probabilities, live cache bytes
and usage agree. The packed quant's complete sampled timings are effectively
flat. RTN4's compiled-fusion arm also has a slower untouched greedy control,
so its timing needs a repeat before attribution. These are screens, not
retention evidence. Evidence is `top-p-native-screen{,-review}.json`.

The actual HTTP screen passes 126 requests across 18 fresh servers, preserving
all 84 paired responses and usage records on serial and continuous execution.
A research-only default-seed provider returns 42 in both arms. Requests omit
the explicit seed field, which would select serial execution; placement is
unchanged and the continuous lane/submitted-row counters are asserted.
The apparent packed serial improvement does not survive six balanced pairs:
all 30 paired responses remain exact, but complete sampled request time is
0.183% higher at the median and only one pair is faster. The untouched greedy
control moves by +0.058%. These loaded-machine results (M4 Pro) do not justify
retaining the fusion for Qwen. Evidence is `top-p-http-screen{,-review}.json`
and `top-p-http-r6-serial-repeat{,-review}.json`.

Llama 1B's six balanced pairs per serving lane preserve all 84 paired
responses across 168 requests. Top-p-only complete time decreases by 0.399%
in serial and 0.380% in continuous serving, with all six pairs faster in each
lane. Top-p plus top-k changes by -0.132%/-0.196%; greedy remains effectively
flat. This is a small model-specific observation, not broad dispatch
eligibility or a Qwen gain. Keep it in the evidence ledger while testing
the complete graph's submission limits, traversal and synchronization.
No production sampler flag or kernel is added. Evidence is
`top-p-http-llama-repeat{,-review}.json`.

Kernel timing is only a screen. Retention requires complete native generation
and actual serial/continuous HTTP comparisons at matched inputs, seeds and
compute shapes. Measure TTFT, prefill, decode, complete request time and memory.
When a fusion wins in isolation but loses in a request, inspect command-buffer
and encoder boundaries, synchronization, buffer lifetimes and overlap with the
next decode step. Capture traces separately from uninstrumented timing. A
smaller dispatch count does not establish better scheduling or throughput.

The cross-entropy audit identifies two separate restrictions. The existing
hidden-width guard rejects Qwen's 5,120-wide head before kernel dispatch;
supporting that width is a separate task. For supported widths, vocabulary
partitioning can disable both Steel routes even when the vocabulary is
tile-aligned. Using the existing maximum block size of
8,192 as the stride, with the final block capped at the vocabulary length,
keeps every tile in bounds. This fixed stride also avoids empty trailing
blocks at larger vocabularies. Every forward
and backward route must use the same partition, including block-skip metadata;
merely weakening the dispatch guard would permit unsafe final-tile loads.
The prepared head-only screen compares full-logit values and unfiltered
gradients, retains already-aligned controls, and measures actual dispatch and
allocation. Both initial arms pass 20 smaller cases and then hit the same
existing Qwen width restriction. A supported-width continuation passes all
24 cases for 4/8-bit weights, varied token counts, softcap and boundary targets.
Candidate loss and unfiltered gradients remain within the predeclared
full-logit-reference tolerances; already-aligned forward controls retain
identical bytes. All tracked arrays are released. The changed partition and
kernel reduction order are not bit-exact to the old fallback. The isolated
timing screen favors the fast route at Llama-sized head geometry, but repeated
timing, actual-weight gradients, pruning and complete training/evaluation
measurements remain. This establishes no inference gain. Protocol and evidence:
`cce-block-alignment-plan.json`, `cce-block-alignment-{control,candidate}-screen.json`
and `cce-block-alignment-supported-review.json` under campaign reports.

The follow-up forces SIMD, scalar and lane forward routes plus SIMD/scalar
backward on both partitions. All 54 cases pass the same full-logit and
unfiltered-gradient gates, including an unaligned vocabulary that must keep
its fallback. Maximum log-probability error is 1.91e-6; maximum gradient
relative L2 error is 1.12e-5. Every process returns to zero active bytes, with
fixed source. Together with the Steel screen this exercises all seven kernel
construction sites. Evidence is `cce-block-alignment-fallbacks{,-review}.json`.

The production call-site audit closes this candidate without integration on
the current available workloads. `headQuant` in the loss path accepts Gemma4
and MiniCPM5. The available Gemma heads have vocabulary 262,144 and block stride
8,192; MiniCPM5 has vocabulary 130,560 and stride 8,160. Both already satisfy
the Steel alignment guard. The Llama geometries that improved in isolation
are not wired into this loss helper. Changing their model support would be
separate work, and changing an already-aligned partition would add numerical
differences without the proposed dispatch benefit. Reopen if a supported
model actually reaches a misaligned block partition. No inference, full-loss
or training speedup is claimed; closed one-off helpers are removed after
recording the result.

Local complete snapshots include Gemma e4b/12B/26B, diffusion Gemma, MiniCPM5,
Llama 1B/3B, assistant heads and GLM weights. Snapshot/file availability is
recorded in `reports/qwen38-rd/project-other-models.json`. Availability is not
execution acceptance. The GLM artifact exceeds device memory and requires its
streamed path; measure expert-slot kernels separately before full requests.

A broader 4-bit prototype supports float16 and inner dimensions outside the
native fast-matvec regime. It must reproduce native dispatch's eight versus
sixteen values per lane, including the matching reduction order; masking the
old kernel's final loads alone is insufficient. All 320 synthetic dtype,
shape and strided-input checks pass. Six full-model pairs per append length
on Gemma 12B/e4b, MiniCPM5 and Llama 1B/3B preserve logits, live cache bytes
and continuation, with fixed source hashes. Gemma 12B improves at M4/8;
e4b improves at M8 but is approximately flat at M4. MiniCPM and both Llama
models regress in eligible cells. This prototype is not integrated: qualify
individual matrix shapes and full HTTP requests before widening dispatch.
Evidence: `affine-shared-cross-model-exactness.json` and
`affine-shared-cross-model-{gemma12,gemmae4b,minicpm5,llama1,llama3}-review.json`
under `reports/qwen38-rd/`.

An actual-weight follow-up covers 44 matrix/append-length cases with exact
outputs, six AB/BA pairs, and both repeated dispatch and dispatch after a
scratch-memory sweep. Small attention projections generally favor native
MLX; large float16 output-head matrices identify a narrower shared-kernel
candidate. The initial Gemma 12B cells overlap an external Playwright/Node
burst recorded by preflight and vary substantially. Retain that run but repeat
those affected cells before deriving eligibility. Operation timing remains
distinct from full-model and HTTP acceptance. Evidence:
`affine-cross-model-matrix-{inventory,screen,screen-review}.json` under the
campaign report directory.

A separate Gemma 12B repeat, with more dispatches per timing sample, preserves
all outputs and yields consistent improvements on its larger projections.
The smaller projection remains marginal or slower. The repeat retains its
own source hashes and machine observations; it does not replace the noisy
run. Evidence: `affine-cross-model-matrix-gemma12-repeat.json`.

Restricting the float16 candidate to large output heads preserves every
32-step greedy stream, live cache byte and continuation on Llama 1B/3B.
Six native pairs at B4/8 show small gains; B1 is flat. Six fresh-process HTTP
pairs per model then preserve all 312 paired responses, including usage and
finish reasons, with observed B4/8 overlap and clean server exits. The B8
serving gain is modest on 1B and below one percent on 3B; single-request
timing is flat. B4 is inconclusive. This does not justify widening production
dispatch. Both arms disable the existing shared-affine flag, and the candidate
pays its eligibility checks. The first two HTTP attempts failed overlap
qualification and remain excluded. Evidence:
`affine-head-batched-decode-mfirst-{llama1,llama3}-review.json` and
`affine-shared-head-http-{llama1,llama3}-overlap-review.json`. These
loaded-machine diagnostics (M4 Pro) do not replace quiet-machine acceptance. Closed head-only helpers
are removed; the broader operation's eligibility work remains open.

A bf16-only selection uses large projections and leaves small matrices on
native MLX. The first selection preserves six full-model pairs per length on
Gemma 12B/e4b. Expanding the 12B selection to its other positive matrix shapes
preserves every checked logit, live cache byte and continuation. Both models
improve at M8; 12B also improves at M4. A 32-step fixed-B 12B repeat confirms
identity and the batched gain. Single-token controls are approximately flat.
The initial raw-completion HTTP comparison fails response identity at B4,
with differing admission histories and mostly repeated-character output in
both arms. Templated chat produces coherent text but also fails response
identity on its third B8 pair. A live diagnostic then compares every selected
projection against native MLX on the same inputs. All 36,704 operations are
byte-identical, including both M4 and M8, and both servers exit cleanly.
Those synchronizations invalidate its timing. A native A/A control with the
candidate disabled in both servers reproduces the same wording difference
when the second arm staggers arrivals by one millisecond per request. Both
servers exit cleanly, with stable sources and zero candidate calls. Thus the
response variation also occurs without the candidate; it is not evidence of
a candidate-only arithmetic error. Preserve both failed response gates.
Subsequent timing pairs retain every difference and require single-request
text identity, all usage/finish invariants and the independent same-input
numerical gates. Do not claim multi-request response identity when it fails.
Evidence:
`affine-large-projection-full-model-{gemma12,gemmae4b}-review.json`,
`affine-large-projection-v2-full-model-gemma12-review.json`,
`affine-large-projection-batched-decode-gemma12-review.json` and
`affine-large-projection-http-gemma12.json`,
`affine-large-projection-chat-http-gemma12.json` and
`affine-large-projection-verify-http-gemma12.json` and
`affine-large-projection-chat-http-native-control-gemma12.json`.
Six subsequent 12B timing pairs complete with stable sources, clean server
exits and all 156 paired responses identical in that run. Both observed B4
and B8 improve in every pair; B1 is approximately flat. Earlier response
failures remain part of the evidence. See
`affine-large-projection-chat-http-qualified-gemma12-review.json`.
The next control adds only large 4-bit bf16 projections whose K is divisible
by 256 but not 512, with M4/8 and both K and N at least 3072. The existing production
shared-affine flag is enabled in both arms, including its 3/8-bit kernels.
Six native pairs per append length preserve all logits, live states and
continuations. Both M4 and M8 improve in every pair; M1 and M128 controls are
approximately flat. The candidate exercises 105 additional projections at
M4/8. Evidence: `affine-nonfast-large-full-model-gemma12-review.json`.
The then-existing opt-in 4-bit kernel selected native eight- or sixteen-value
lane arithmetic for those shapes, off by default, with the 3/8-bit selection
restricted to its original shapes; that kernel and its flag were removed in
the MLX 0.32.2 consolidation (§7.12) and survive only in frozen source controls. Large nonfast
output heads with N≥65536 remain native because no such head has passed the
model/serving performance gate. This does not change the measured Gemma
projection selection. Focused tests
cover strided activations/metadata, compiled replay and native fallback.
The integrated version preserves six full-model pairs per append length and
improves M4/8. Six further production HTTP pairs improve B4/8 in every pair,
with single-request timing approximately flat, fixed sources and clean exits.
Two B8 warmup responses exhibit the same wording difference as the prior
native A/A control. All usage and finish invariants match; whole-response
identity does not hold for that run. Preserve those differences and the
independent numerical gates. Evidence:
`affine-nonfast-integrated-full-model-gemma12-review.json` and
`affine-nonfast-integrated-chat-http-gemma12-review.json`.
Live same-input verification then checks all 50,149 selected 4/8-bit operations
against native MLX with identical bytes, fixed sources and clean exits. Its
synchronizations invalidate timing. Evidence:
`affine-nonfast-integrated-verify-http-gemma12-review.json`. Six complete
flag-off/flag-on HTTP pairs also improve B4/8 in every measured pair, with
approximately flat single-request throughput, fixed sources and clean exits.
Two B8 warmup responses differ; preserve those alongside the live numerical
gate. All usage and finish invariants match. Evidence:
`affine-nonfast-integrated-chat-http-native-gemma12-review.json`. This does not establish a gain
for smaller models or justify enabling the flag across model families. Superseded projection and verification
helpers are removed after recording their findings; the incumbent comparison
helpers are removed after the native-flag control completes.

One shared candidate is launch-configuration reuse. The current wrapper
recreates output/template/grid configuration on every custom-kernel call.
[mlx-c v0.6.0's implementation](https://github.com/ml-explore/mlx-c/blob/v0.6.0/mlx/c/fast.cpp)
copies that configuration into the apply call. A bounded per-kernel cache can
therefore reuse it while keeping tensor inputs dynamic. Qualify changed shapes,
template order, initialization, compile traces, eviction and disposal, then
measure full models and HTTP. No default change follows from the source audit.

The first configuration-reuse prototype passes 160 changing shape/dtype
checks plus compiled replay, eviction and disposal. Six packed-model pairs
at M1/4/8/128 preserve logits, live cache bytes and continuation. Full-model
timings are approximately flat, with unchanged peak allocation. Compact
Qwen's affine control is also approximately flat. MiniCPM's single-forward
samples vary; a 32-step fixed-B repeat preserves every token, live state byte
and continuation with small B4/8 gains, but its unused B1 control also moves.
The subsequent HTTP run fails response identity in a later B8 wave. Its two
arms have different early admission histories. Six A/A pairs and six further
pairs with deliberately staggered arrivals do not reproduce the mismatch.
That leaves the cause unresolved; admission sensitivity is a hypothesis, not
a finding. The changed response occurred in the cache-disabled arm. Close
this prototype without integration: Qwen is approximately flat and MiniCPM
does not pass the serving gate. The HTTP mismatch remains unresolved in the
broader correctness coverage. Evidence:
`reports/qwen38-rd/metal-config-cache-exactness.json` and
`metal-config-cache-full-model-{packed,compact,minicpm5}-review.json`, plus
`metal-config-cache-batched-decode-minicpm5-api-review.json` and
`metal-config-cache-http-minicpm5.json`.
The control reports are `metal-config-cache-http-minicpm5-control-review.json`
and `metal-config-cache-http-minicpm5-admission-control-review.json`; their
passing responses do not replace the failed A/B gate.
Closed configuration-cache helpers are removed; raw reports remain.

The multimodal rotary audit identifies repeated angle evaluation across
heads/layers and a contiguous-input requirement after Q/K transposes.
Separate prototypes test shared float32 angles, direct stride reads, and both
together. All 108 operation comparisons preserve bf16/f16/f32 bytes across
partial/full rotary dimensions, multiple positions and strided inputs. A
16-layer Q/K schedule includes angle construction and uses distinct inputs
per layer. Short-sequence variants lose; direct stride reads improve the
prefill operation, while angle reuse alone is weaker. Timing varies within
the sweep and the operation is a small part of a complete 27B forward.
The full-body gate keeps shorter sequences native and uses fixed 3D
positions. All 35 logit/state/continuation cases match, but M128 is slightly
slower and M512 is approximately flat. Peak allocation decreases only
slightly. Close the prototype without integration; the operation gain does
not establish a useful complete-model gain. This gate excludes image encoding
and is not a real vision-request benchmark. Text-only generation uses native
fast RoPE. Evidence: `mrope-reuse-screen-review.json` and
`mrope-stride-full-model-packed-review.json`. Closed helpers are removed; raw
reports and source hashes remain.

The final quiet-machine bundle must record host/chip/RAM, incumbent and
candidate source hashes, local diff, Bun/native/oracle versions, model hashes,
flags and workload files.
Run the existing serving suite and native generation separately on a quiet machine,
with fixed cache conditions and all paired samples retained. Its existing
numbers are historical controls until the workload and version metadata match.

### 7.10 Final benchmark and HTML comparison report

The offline renderer and replay fixtures are implemented. It imports the
existing native/serve formats, retains failures and provenance, and suppresses
speed ratios for incompatible work or unqualified runs. Its current metrics
and limitations live in benchmarks.md. A bounded MiniCPM M1 diagnostic passes
the real measurement path with the explicit reference control; concurrent
output differences remain visible. Fixed-source block log-ratio intervals now
use a deterministic bootstrap across distinct workload seeds, with duplicate
seeds excluded and at least five blocks required. Quality inputs, the frozen
final protocol and quiet final matrix remain acceptance work;
rendering saved evidence does not close this gate.

After the optimization gates close, build and run a repeatable benchmark for
the incumbent, combined finalists and retained quantizations on a quiet
machine, recording its host/chip/RAM.
The benchmark must preserve the existing suite's measurements while making
native generation, serving, memory and quality comparisons easier to inspect.
Its protocol is frozen before final runs; the held-out Kanban task in section
7.7 remains a separate task evaluation and is never an optimization fixture.

Use Bun/TypeScript for orchestration, measurement, validation, statistics and
HTML generation. Python is confined to launching or instrumenting the pinned
MLX-LM/OptiQ reference. The mlx-bun arm loads and serves through the existing
engine and request interfaces. Browser rendering is outside the timed engine
and HTTP cells. Any later chat-UI profiling needs its own browser workload.

Extend the current native worker, serving measurements, machine preflight,
artifact inventory and result persistence. Start from the serving suite's
versioned raw JSON and existing report functions; extract shared functions
only when both callers need them. Keep execution, comparison and HTML rendering
separate. Rendering saved results must require neither model weights nor a
running server, GPU, Python or network connection. Raw data remains portable
between machines, and the SQLite store is an index rather than the only copy.

| Measurement group | Required cells and definitions |
|---|---|
| Single-request generation | Fixed token-ID prompts at the declared context depths, first emitted token, prefill time and processed tokens, sustained decode time, actual generated token count, total generation time and cleanup. Record computation boundaries so prefill throughput excludes unrelated loading or queue time. |
| Single-request HTTP | Serial execution and actual continuous execution with one request. Measure request start to headers, first byte, first visible content or tool output, final output and stream completion. Preserve server phase timings where available. SSE chunks are not tokens; client-visible output gaps and native token intervals have separate names. |
| Startup and reuse | Fresh-process readiness and first request, warm process with an uncached prompt, RAM prefix hit, SSD restore, exact continuation and edited-prefix miss. Record cache budget, persisted state and actual reused-token counts. A new process does not imply a cold filesystem cache. Page-cache-cold trials require an explicit controlled protocol. |
| Sustained serving | Fixed arrival schedules and concurrency levels within each machine's capacity; per-request queue time, TTFT, completion latency, stream stalls, aggregate completed requests and output tokens per second, error rate and throughput meeting declared latency limits. Verify actual lane, admitted rows and batch occupancy; a seed option must not silently route a continuous test through serial execution. Include cancellation, recovery and long multi-turn cache pressure. |
| Memory and resource use | Startup, prefill, decode, cache retention and post-disposal observations; peak server-process RSS, native active/peak allocations, allocator cache, KV and recurrent state, SSD cache size, system memory pressure and swap activity. Record sampler frequency and process ownership. Unified-memory and file-mapping accounting can change RSS without saving physical memory. Add energy only if supported measurement is calibrated and its overhead is excluded from ordinary timing. |
| Fidelity and quality | Same-input logits and cache/state gates at matched compute shapes, generated IDs where available, output bytes, usage and finish reasons. Different quantizations carry artifact bytes, quality results and task failures alongside performance. Early EOS, reduced thinking or incomplete output cannot count as faster completion of the same work. |

For supported artifacts, pair each native/HTTP mlx-bun cell with the same
artifact on the pinned MLX-LM reference. Pin tokenizer, template, sampler,
seed, thinking, tools, budgets, cache state, prefill chunk/tail policy and
wiring. Store both requested and effective configuration. Identical seeds
alone do not establish equivalent graph shapes or RNG consumption. If a
reference lacks a feature or measurement, show an unsupported cell with its
reason. Packed trellis has no stock MLX-LM loader; a different affine or GGUF
artifact belongs in the quality/size comparison and cannot be its speedup
denominator. OptiQ and additional backends are separate supported controls.

Record immutable machine, session, workload and artifact identifiers; OS,
chip, memory, power/thermal conditions, storage, Bun and oracle versions;
source commit/diff and native-library hashes; weight content manifests;
commands, resolved flags, protocol version, timestamps and preflight results.
Resolve accelerator details explicitly: actual draft architecture/artifact,
draft weight precision, block size, native MTP, prompt selection and KV format.
Requested flags or a model's nominal weight precision do not establish those
states. Report native active-memory peaks separately from process RSS.
Hash large files before timing. Preserve every attempted request, failure,
timeout, interruption and retry, with reasons for exclusions. Diagnostics
remain identifiable and cannot become quiet acceptance rows during import.

Use the internal-SSD active-model policy in environment.md. Artifact transfer
and hash verification precede the timed run; record the active volume and
storage protocol. For startup, report readiness, first-request latency and
their combined elapsed time. Eager weight loading must not appear faster
merely because it moves disk work before the readiness signal. Historical
external-drive measurements stay separate from internal-drive comparisons.

A Bun FFI collector prototype reads macOS `proc_pid_rusage` v4 directly for
an owned PID. Its layout is checked against the installed SDK; RSS, physical
footprint, lifetime peak physical footprint and disk-byte counters keep distinct
fields. The PID's start tick guards against reuse, and an exited or unreadable
process returns no sample. A 64 MiB allocation calibration matches Bun's RSS
and the expected physical-footprint growth; live/exited child reads and disposal
also pass. Two 32-sample blocks per arm measure about 0.0013–0.0015 ms per native
read versus 1.09–1.14 ms for the current `ps` subprocess. This is collector
overhead only, not an inference speedup. Validate real-server accounting and
sampling effects before using it in the final benchmark. Evidence:
process-memory-sdk-layout.json and process-memory-calibration.json under
reports/qwen38-rd. Existing timing reports keep their original collector.

Apply section 7.7's balanced paired blocks, independent-session repeats and
correctness gates. Calculate speed ratios within a machine and compatible
protocol/artifact cells. Show raw distributions, sample counts and paired
uncertainty; estimate tail percentiles only with adequate request counts.
Use a prespecified stopping rule and acceptance thresholds. Keep supported
configuration tradeoffs visible instead of averaging different workloads,
precision levels or machines into a single score.

The offline HTML report should provide machine/model/quant/backend/configuration
filters, baseline selection among compatible rows, absolute metrics and
within-machine deltas, distributions, memory-versus-speed and quality-versus-size
plots. Every summary links to raw JSON, provenance and correctness evidence.
Failed, skipped, unsupported and unmeasured cells remain visible. Escape saved
model output and other external strings; report generation must not execute
them. Embed the report's required assets so the exported file works offline.

Exit requires a model-free replay fixture proving schema validation, unit
definitions, pairing, failure handling and renderer escaping; a bounded live
smoke through the real measurement paths; then the frozen final matrix on
a quiet machine. Compare the old suite and new suite on shared cells to
detect measurement changes before attributing a difference to the engine.
Publish qualified numbers only in the canonical benchmark reference, with
raw JSON and HTML under `reports/`. Machine access or unsupported cells that
remain unavailable must be named explicitly and cannot be counted as done.

### 7.11 Mac quant video follow-up

The September 6 [RepoChad video](https://www.youtube.com/watch?v=dHK90xc9Q64)
names additional Mac quantization and serving configurations. Its description
contains chapters and hashtags, with no external artifact links. Automatic
captions were advertised but could not be retrieved. The investigation used
public storyboard frames to identify visible recommendations, then inspected
primary model cards and source. It did not recover a transcript. Metadata,
frames and pinned sources are retained in
`reports/qwen38-rd/video-dHK90xc9Q64/`.

The concrete new weight candidate is
[`manjunathshiva/Qwen3.8-27B-tq3-mini-g64`](https://huggingface.co/manjunathshiva/Qwen3.8-27B-tq3-mini-g64/tree/5542979c87f72acaa9019633649cb6624e32699f).
It stores independent eight-centroid indices, ten codes per uint32, with
fp16 RMS scales per 64 inputs and online randomized Hadamard rotation.
Index storage is 3.2 bits/value before scales and other tensors. This differs
from the campaign's Trellis format. The custom wrapper can load it directly;
stock MLX-LM and our current loader do not implement this format.

Its [M1 kernel](https://github.com/manjunathshiva/turboquant-mlx/blob/f4e3d34a831fc1f6acd8e7c29665bad358ce878e/kernels/polar_qmv.py)
uses five shared-memory barriers to reduce one SIMD group's partial sums.
First compare explicit converged SIMD shuffles with the same 16/8/4/2/1 tree,
element order, group scale placement and final cast. Include the wrapper's
bf16-to-f32 promotion and complete online rotation cost. The Apache-2.0 source
and attribution are pinned. [Conversion seeds rotations per projection path](https://github.com/manjunathshiva/turboquant-mlx/blob/f4e3d34a831fc1f6acd8e7c29665bad358ce878e/quantize_model.py);
gate/up sharing requires identical saved sign tensors. Do not reconstruct
those signs from a base seed, since conversion also uses Python string hashing.
Different small-M and expanded paths have separate rounding/reduction contracts.

The video's attractive M4 Pro result matches
[oMLX record sio0vt3c](https://omlx.ai/benchmarks/performance/sio0vt3c): DFlash2,
quantized draft weights and block size five are enabled; native MTP is off.
It is not a plain Q4 decode baseline. The
[Qwen DFlash2 artifact](https://huggingface.co/z-lab/Qwen3.8-27B-DFlash2/tree/50307d4c4cde6860d4eee73e2547cd786fe8e8a4)
is a concrete R21 candidate. Existing Gemma draft support does not establish
support for this architecture. Any port needs target-state/rollback identity,
draft residency and full-request comparisons with ordinary decode and fixed-two
native MTP. Guaranteed structural appends remain a separate operation.

The pinned oMLX package file actually selects
[dflash-mlx c55324c, v0.1.10+omlx.7](https://github.com/jundot/omlx/blob/aa8db73496bd8367989e2862f50b315885b9b91a/pyproject.toml).
The older v0.1.10+omlx.4 string is an engine compatibility comment. At that
[dependency revision](https://github.com/jundot/dflash-mlx/tree/c55324c86540c369f6818a0f47eae544d405475b),
DFlash2 adds dynamic grouped causal convolutions around both attention and
MLP, plus a selector that conditions each token on its selected predecessor
using top-16 candidates and rank-256 codebooks. Our existing DFlash provider
needs this architecture and selector in addition to Qwen target taps; loading
the checkpoint into the current provider would not implement DFlash2.

The fork's flat greedy verify path concatenates proposed and target token IDs
for one host read, then checks acceptance and EOS from that result. Hidden
feature extraction launches asynchronously outside profiling. This does not
mean every mode has one synchronization: repetition penalties need another
ID read and stochastic acceptance follows a separate path. Our speculative
accept walk reads each sampled target position eagerly, and Qwen MTP reads
each draft token before the next draft step. Test grouped reads first for
history-independent greedy requests. Preserve the shared sampler's processor,
grammar, RNG and history contract; do not bypass it for a blanket fast path.
The pinned eleven-file
source bundle and hashes are in video-dHK90xc9Q64/dflash-source-manifest.json.

The grouped-read experiment is closed without a production change. Two Bun
prototypes keep the existing independent per-position sampler calls: one
concatenates their IDs for one read; the other uses `evalAll` followed by direct
integer reads. Each passes 144 operation cases, including ties and nonfinite
logits, with unchanged inputs and zero retained allocation after disposal.
The operation improves when several positions are consumed, but computing
unused positions makes a first-position rejection slower.

Six balanced three-arm HTTP blocks then preserve all 84 candidate/control
response comparisons, usage and acceptance traces across 126 requests. All
arms use the same R6 target, saved q4 MTP companion, gamma 2, bf16 KV and greedy
seed 42. Ordinary sampling makes 432 eager ID reads per server; either
prototype replaces verification reads with 152 grouped windows plus seven
ordinary first-token reads. All servers exit cleanly with equal active
capacity, and all 547 source hashes remain fixed. Complete-request paired
medians for concatenation improve only 0.33%, 0.06% and 0.23% across the code,
explanation and JSON fixtures. The `evalAll` alternative improves 0.26% and
0.04% but regresses 0.44% on JSON. Losses remain in both results. These
diagnostics (M4 Pro) establish no broad serving benefit worth another sampler path.
Evidence: spec-grouped-greedy-screen.json, spec-grouped-greedy-eval-screen.json
and spec-grouped-greedy-three-http{,-review}.json. This tests target verification
readback only, not DFlash2's architecture or the separate forced-token method.

The scalar checkpoint's reported four agent failures on a 16 GB Mac mix missing
tool calls, a queue timeout and perseveration ending in OOM. The same weights
pass on a larger Mac, with differing wrapper builds unresolved. These reports
do not isolate quantization damage. Borrow the long-agent memory/context tests
using current artifacts first. Likewise,
[SpecPrefill](https://github.com/jundot/omlx/blob/aa8db73496bd8367989e2862f50b315885b9b91a/omlx/patches/specprefill.py)
selects a prompt subset with a smaller model. Keeping RoPE positions does not
reconstruct skipped GDN recurrence updates. It belongs in an approximate Lab
arm with original/selected token counts, retrieval and task-quality gates.

Priority is the bounded M1 scalar operation screen, current-artifact long-agent
memory/context coverage, then Qwen DFlash2 feasibility. Only positive operation
economics and quality evidence justify a new full-model loader or artifact.
Approximate prompt reduction follows the exact-path work. No external speed
or memory figure changes our baseline.

The bounded Bun/Metal M1 screen now preserves all 54 fixture cases, including
online rotation, dtype promotion and incomplete packed rows. Six fresh-process
repeats preserve every fixture/output hash and release all active allocations.
For the 5120-to-17408 projection, explicit shuffles reduce complete rotated
operation time by a median 2.77–3.84% across the three input dtypes; the reverse
projection improves 0.63–1.06%. Every pair improves. Packed-word reuse is slower,
forced loop unrolling adds little, and larger threadgroups do not establish an
additional large-projection benefit. This is the literal upstream source run
through our Bun binding on synthetic matrices, not installed-wrapper parity or
a current-engine/full-model improvement. Evidence: `polar-qmv-screen-v2.json`,
`polar-qmv-variants.json`, `polar-qmv-geometry.json` and
`polar-qmv-repeat{,-review}.json`.

A separate exact prototype fuses the upstream large-prefill unpack, centroid
gather and group-scale multiplication into one fp16 expansion. The original
fallback builds uint32 indices, narrows them to uint8, widens them for gather,
then multiplies the gathered weights by scales. The screen preserves all 16
expanded-weight and complete-operation cases, including small padded rows and
zero/subnormal/overflow scale values. Six fresh processes then preserve all 84
large-projection comparisons at M257/512, including rotation and native matmul,
with identical cross-process hashes and zero final active allocation. Median
complete-operation time falls 40.85–57.51%; peak temporary allocation falls
765.00–765.05 MiB. Every pair improves. These were measured on the M4 Pro on synthetic
resident matrices. They do not measure real model quality, RSS or whole-model
speed, and they do not replace the separate small-M QMM arithmetic. Evidence:
`polar-expand.json` and `polar-expand-repeat{,-review}.json`.

Our existing `TurboQuantKVCache.#decode` has the same unpack/gather/scale
pattern. The byte-packed KV decoder and the narrower inverse-rotation
operation are integrated behind `MLX_BUN_TURBOQUANT_FUSED_DECODE=1`; their
gates, numbers and the closed direct packed-key attention arm live in
turboquant.md, "Packed-value decode fusion investigation", and the ledger row
is §7.13 R13. The video's weight format still has no production loader or
kernel here.

### 7.12 Custom-kernel graph reuse and the MLX runtime update

The pinned runtime separates three costs. `metal_kernel` constructs a lazy
custom primitive on each eager call. Its GPU evaluator uses MLX's ordinary
command encoder and cached Metal library/pipeline. `compile` separately caches
an optimized graph, then instantiates it with new inputs during native replay.
Avoiding JavaScript tracing does not remove all native graph or dispatch work.

The actual Bun probe confirms shape-specific compilation works with custom
kernels: five calls over shapes 8/8/16/16/8 trace twice, invoke the shape/grid
callbacks twice and return exact outputs for changing values. Native shapeless
addition traces once across those shapes. Both custom shapeless variants fail
with `CustomKernel cannot infer output shapes`, even when JS callbacks supply
output shapes and the launch grid. All allocations release after disposal.
The wrapper comments now describe this accurately: callbacks run during eager
construction or tracing, never during native replay. Evidence:
custom-kernel-compile-probe.json; the earlier helper error is retained separately.

This is an upstream limitation, not solely a Bun binding omission. The
[CustomKernel declaration at current MLX main](https://github.com/ml-explore/mlx/blob/ce916dbbcaa88e433b6fd1e60a17f766d49c27fe/mlx/fast_primitives.h)
still lacks `output_shapes`, and captures a concrete launch grid. A future
native operation must infer both result shapes and dispatch from current
inputs. Passing an output-shape callback through our existing JS interface
cannot supply that native behavior. Prior per-projection shape-specific caching
and launch-configuration reuse did not improve complete Qwen requests (§7.8/7.9);
those negative results remain. Next candidates must target larger reusable
regions or measured native construction costs, with growing-cache, compile,
state, cancellation and complete-request gates.

Josh authorized upgrading to the latest stable MLX. The fresh upstream check
finds [MLX v0.32.2](https://github.com/ml-explore/mlx/releases/tag/v0.32.2), released
2026-08-25; Homebrew currently offers 0.32.1. The staged runtime pairs that
version with [MLX-C c74db530](https://github.com/ml-explore/mlx-c/tree/c74db5307cc8ce122f48d97ef951b30578674e7f),
whose CMake dependency pins 0.32.2. The full source build stopped because this
Mac lacks the offline Metal toolchain. The completed build instead links the
C wrapper against MLX's verified official 0.32.2 native wheel libraries.
Bun loads those native libraries directly. Local build, archive and library
hashes are recorded in `reports/qwen38-rd/mlx-upgrade-0.32.2/`.

The initial cross-version checks used a temporary dual-ABI adapter. The
consolidated production binding now directly uses the 0.32.2 C API. Attention
supplies `force_fused=false`, cumulative sum supplies an absent optional dtype,
and both cumulative operations call the axis-taking symbols. Startup checks
the linked core version. The original cross-version suites and the later
Trellis-port suites passed on both runtimes; their separate reports remain.

The frozen shared-affine port was validated against the 0.31.2 core. Identical packed
weights, activations and metadata reproduce four exactness differences against
0.32.2 native multi-row matmul. The custom outputs are unchanged across versions
and match separate native M1 rows. Upstream `qmv_wide` decodes each group once
for several vectors and uses different arithmetic and an eight-lane reduction.
Native dispatch on the new core preserves its numerical contract. The final
production code removes the old affine kernel and its experimental flag;
the frozen source controls retain that implementation for comparisons.

Six balanced process pairs screen ten affine shapes with twenty alternating
operation samples per implementation. New native Q3 gate/up-shaped operations
improve over old shared operations in all six blocks; Q4 results are mixed by
shape and block, while Q8 loses in every block. These are loaded-machine
operation diagnostics, not full-model gains, and refer to affine Q3 rather
than Trellis. All input hashes agree and every process releases its arrays.
Evidence: affine-{old,new}-screen.json and affine-runtime-repeat{,-review}.json.
Same-version RTN4 oracle gates now pass on both cores and on both official
0.32.2 macOS builds. Each comparison covers contexts 0/64/512 and append lengths
1/4/8/128, checking complete logit arrays, every live cache array, and a fixed
continuation. All twelve cells are byte-exact against the matching MLX-LM
reference. The two new-core builds also agree with each other in those cells.
Source hashes stay fixed and every worker exits cleanly. Evidence:
runtime-oracle-rtn4.json and runtime-oracle-rtn4-macos14.json.
The package selects the verified macOS 14 native pack 0.4.0, now published;
distribution.md records the release. Final-source acceptance
passes 16 RTN4 same-version reference cases (including actual 4K/8K prompts),
36 Trellis forward/state/continuation cases and six Trellis generations.
The Trellis control is the accepted new-core implementation; this is not a
claim of an external packed-Trellis oracle. All three workers exit cleanly,
with fixed source, library and reference hashes. Evidence:
`final-source-gates.json`. The consolidated model-free suite passes 1,875 tests
with ten skips; all three typechecks and hygiene pass. Integrated inverse-KV
serving also passes its repeated response and decode gates; its complete-time
verdict differs by quant, as recorded in turboquant.md. Broader same-version
reference checks and combined/pressure acceptance remain. The old runtime and both source controls remain
separate; environment.md records their paths.

Production targets one pinned runtime. Trellis, rotation and TurboQuant
continue through their existing interfaces. The integrated inverse-KV decoder
passes its new-core R6 and RTN4 comparisons against the preceding joint decoder.
Each checks 12 full forward/state/continuation cases and four greedy/sampled
generations at 2K and 8K contexts. Logits, complete cache arrays, token IDs,
logprobs and usage are exact. Each pair has equal final active allocation and
clean exits. These comparisons isolate the KV change and do not establish
every Trellis variant's equivalence. Evidence: r6-kv-inverse-full.json and
rtn4-kv-inverse-full.json.

The separate new-core Trellis v6/v13 model gate catches an M8 append mismatch.
M1/3/4/128/512 and all four tested generations remain exact. The first differing
cache appears after layer zero. Upstream `gemv_wide` changes the arithmetic of
contiguous small-M dense projections on M3 and newer GPUs. The old direct
Trellis prefill tile reproduces the preceding SIMD-matrix reduction instead.
A deterministic operation reproduction fails at every M5..15 row count and
passes again at M16, where native dispatch returns to GEMM. The replacement
kernel decodes packed Trellis weights to bf16 within the new eight-iteration,
four-value dot-product loop. Sharing each decoded row across all M vectors
preserves the native reduction and wins the initial complete-operation screen
for every tested 2/3/4-bit cell. A full-model prototype comparison passes all
36 forward/state/continuation cells and four greedy/sampled generations.
Those timings are screening evidence, not serving results.

The integrated implementation keeps geometry and arithmetic in
`trellis-wide-prefill.ts`. It is dispatched only under
`MLX_BUN_TRELLIS_VARIANT=11..13` (`TrellisLinear.forward` in
`src/model/trellis-linear.ts`); the default variant 6 still expands and uses
native matmul, so this path is opt-in, not production. Qwen supplies an explicit layout proof from its
RMSNorm output through the existing MLP and linear calls. Unproven layouts
return to native expansion/matmul for the affected sizes. Reading lazy-array
strides before evaluation cannot establish this proof, and inserting an eval
would change scheduling. Native arithmetic also depends on the GPU generation;
the gate reads MLX's architecture identifier once and retains the earlier
dispatch on pre-M3 hardware. The operation tests cover every M5..15 size for
all three bit widths and a full-size transposed-input fallback. The integrated
model comparison passes all 36 forward/state/continuation cases and six
greedy/sampled generations, including short prompts. Logits, tokens, logprobs
and cache state are exact. Both processes release to the same active-memory
baseline. The complete model-free suite passes on both cores, with 1,882 passes
and ten skips on the new core, and 1,881 passes and eleven skips on the old
core. The additional skipped test needs the new native reduction. All three
typechecks and hygiene pass. Preserve the
failed model report; no equality check is weakened. Evidence: trellis-runtime-full,
trellis-wide-screen, trellis-wide-perf, trellis-wide-full and
trellis-wide-integrated-full reports in the upgrade directory.

Six balanced actual HTTP pairs per serial/continuous lane preserve every
response, usage count and finish reason. The raw 9/12-token prompts exercise
8/11-row prefills with normal tail splitting. TTFT improves in every pair;
complete-request time improves in all but one measured fixture pair. Decode
and peak RSS are effectively unchanged. These are narrow, loaded-M4-Pro
diagnostics. The first continuous attempt supplied an explicit seed, which
correctly selected serial placement. Its failure remains recorded. The
corrected continuous requests use greedy decoding without an explicit seed
and assert actual scheduler admission and batched usage. Evidence:
trellis-wide-http.json, trellis-wide-continuous.json and
trellis-wide-http-review.json. This supports the new small-prefill path;
it does not establish a general decode gain from upgrading MLX.

Two balanced runtime blocks complete all 24 native workers with fixed source
and library hashes. Short-prompt decode is effectively unchanged. RTN4's
short-prompt first-token time improves slightly in both orders. Long-prefill
timings vary substantially by order, so the initial apparent gain is not an
accepted upgrade result. Both new-core builds produce identical tokens across
all repeats. At the 4,096-token prompt, both quants produce stable but different
continuations across core versions. Those differences remain explicit in the
report. The additional same-version oracle uses the actual long-prompt IDs,
repeated for 8K, with 512-token prefix chunks and the final 511-token tail.
Both append lengths, one and eight tokens, pass at both contexts. Full
logits, every live cache array and the fixed continuation are byte-exact;
both workers exit cleanly with fixed source hashes. Evidence:
runtime-oracle-long-macos14.json and
native-runtime-screen{,-review}.json. These runs used a loaded machine (M4 Pro)
and are not canonical benchmark rows.

A native proxy prototype establishes a narrower graph-reuse option. It holds
the original custom operation, delegates evaluation to MLX's existing encoder,
and supplies constant output shapes only after checking that every custom
input retains its captured shape and dtype. Other graph inputs may change
dimensions. The two-output probe returns exact results over five changing
input-value/native-shape calls with one JS trace. A changed custom input shape
throws before dispatch; returning to the original shape still works. Disposal
returns active memory to zero. This does not add general dynamic-shape custom
kernels or establish a model speedup. Evidence: fixed-custom-probe.json and the pinned native helper build
in the upgrade directory.

The actual Qwen region probe also needs fixed-input `Slice` support. Its
native proxy retains the same strict shape/dtype checks. Default compilation
passes all 48 R6 recurrent/full-attention cases with one trace per region, but
changes an RTN4 full-attention output while preserving KV state. Disabling
fusion everywhere instead changes recurrent state. Keeping normal fusion in
recurrent regions and disabling additional fusion in full-attention regions
passes all 48 cases on both quants, including growing contexts and continuations.
All failed comparisons remain recorded; none becomes a tolerance-based pass. Evidence:
qwen-fixed-region-{r6,rtn4}-v{2,3,4}.json in the upgrade directory.

Composing these regions as 64 cached per-layer graphs passes R6's eight full
forward/state cases and six greedy/sampled generations, including logprobs.
Every layer traces once and all compiled closures release. Request timing is
flat or slightly slower. RTN4 fails the full-model numerical gate despite the
regional passes. Its one-token forward changes logits while initially
preserving cache arrays; subsequent continuations also change state. RTN4
timing shows no gain. This per-layer implementation stays out of production.
It establishes a limited graph-reuse mechanism, but changing graph boundaries
still requires full-model identity and request-time evidence. Both arms exit
normally with equal final active allocation for each model. Evidence:
qwen-fixed-layer-r6-full-v2.json and qwen-fixed-layer-rtn4-full.json.

A whole-model graph experiment preserves the existing inner compiled regions.
In the pinned MLX source, `detail::compile`
calls the original function when an input is already a tracer. Nested
`computeG` therefore expands into the outer trace, and an outer `no_fuse` mode
also removes its required inner fusion. Warming the inner cache does not
change that branch. A research helper temporarily restores ordinary inner
compilation, then restores tracer ownership before the outer graph is built.
The changing-input probe passes ten bf16/f32 cases with two traces and
unchanged input bytes. Both R6 and RTN4 then pass eight full forward/state
cases and six greedy/sampled generations each, including logprobs and
continuations. Each whole-model closure runs 394 times with two traces and
releases on weight disposal; both controls agree on final active allocation.
This resolves the earlier RTN4 composition failure for this implementation.
The first native timing screen is slower on both quants. It is not a balanced
performance verdict, but supplies no speed candidate. Attribute cache copying
and graph bookkeeping before further request-time comparisons. No production
tracer manipulation or whole-model compilation change is integrated.
Evidence: `compiled-region-probe.json` and
`qwen-fixed-hidden-regions-{r6,rtn4}.json` in the upgrade directory.

A narrower experiment uses ordinary fixed-shape `CompiledFunction` for the
sixteen groups of three recurrent layers. Full-attention layers keep their
native capacity-backed KV updates. This needs no native proxy or tracer
manipulation: hidden inputs and initialized recurrent/conv states have fixed
decode shapes. Both R6 and RTN4 pass eight complete forward/state/continuation
cases and six greedy/sampled generations, including logprobs. Each group
traces once, the sixteen groups execute 6,304 calls, and all closures release
with the same final active allocation as the ordinary control. R6's initial
comparison uses the external archive; RTN4 uses the byte-verified internal
active copy specified in environment.md. The initial fixed-order timing
screens supply no request-time gain, but unchanged prefill timings also
drift. The follow-up alternates ordinary and compiled generation within one
loaded internal-SSD model, with four balanced pairs each at 8- and 128-token
prompts. Both quants preserve all forty warm/measured generations, logprobs,
live state and steady active ownership. Sixteen closures trace once per model
across 10,240 group calls, then close. Median paired complete-time reductions
are only 0.062% for R6 and 0.202% for RTN4, with one slower pair on each.
This does not justify adding model execution and lifetime machinery; no
production integration or HTTP speed claim. Evidence:
`qwen-fixed-ssm-groups-r6.json` and
`qwen-fixed-ssm-groups-rtn4-internal.json`, plus `qwen-ssm-hot-review.json`
and its raw per-quant reports in the upgrade directory.

The broader matching-core audit catches a separate MiniCPM5 prefill gap.
M1/M8 agree, while M128 changes logits and state from layer four onward.
Its Llama MLP had limited compiled SwiGLU to decode, whereas MLX-LM compiles
the activation at every sequence length. Using the oracle operation for
prefill restores all six same-input logit/state/continuation cases in the
isolated control. The model-owned implementation now uses that existing
compiled helper at every length outside an enclosing compiled trace.
The explicit opt-out remains. Integrated MiniCPM5, Llama 1B and Gemma e4b
reference checks pass all eighteen cases. The retained opt-in regression
`tests/parity/runtime-oracle.test.ts` repeats the full logits, live state and
continuations with the matching runtime and sequential subprocesses; all
three model tests pass. Training and serving checks remain before this
runtime correction closes.
Evidence: `runtime-oracle-broader.json` and
`runtime-oracle-compiled-prefill.json` in the upgrade directory.

The intervening release notes are:

| Release | Changes relevant to this program |
|---|---|
| [0.32.0](https://github.com/ml-explore/mlx/releases/tag/v0.32.0) | Small-batch quantized matvec, RMSNorm register reuse, custom Metal math modes, compile cleanup and shapeless-reduction fixes. |
| [0.32.1](https://github.com/ml-explore/mlx/releases/tag/v0.32.1) | Lower custom-kernel naming overhead, reusable Metal hazard tracking, small-batch dense matvec, shader-cache collision and shapeless-matmul fixes. |
| [0.32.2](https://github.com/ml-explore/mlx/releases/tag/v0.32.2) | Optional forced fused attention, GQA8 reuse, sliced-array quantization and compiled-cast fixes; additional NAX paths apply to newer GPU architectures. |

Useful upstream changes include [removing regex from custom-kernel name
construction](https://github.com/ml-explore/mlx/pull/3869), [reusing Metal hazard
tracking allocations](https://github.com/ml-explore/mlx/pull/3882), [fixing
same-name shader cache collisions](https://github.com/ml-explore/mlx/pull/3833),
and [correcting shapeless matmul's dynamic dimensions](https://github.com/ml-explore/mlx/pull/3813).
Their reported gains are not our measurements. New [GQA8 attention reuse](https://github.com/ml-explore/mlx/pull/4077)
has a narrow D64/128 dispatch; Qwen3.8-27B uses GQA6/D256, so it is an algorithm
lead rather than a direct dispatch win here. The [optional fused full-attention
path](https://github.com/ml-explore/mlx/pull/4185) explicitly trades throughput
for bounded temporary memory. Evaluate that tradeoff on the actual
eligible path. Reference numerical changes must be explained, never hidden by
loosening the oracle tolerance.

Qwen layer evaluation bounds deferred prefill work. The exact oracle and
retained-history results, including superseded reservation trials, are in
[benchmarks.md](../reference/benchmarks.md). Josh's closeout machine policy
permits the recorded audio-daemon CPU activity with exclusive GPU ownership,
available memory and stable alternating pairs. Earlier diagnostic evidence
keeps its original classification.

Josh subsequently chose request execution over predicted-memory refusal. The
reservation prototypes remain historical diagnostics. Default fit estimates
must neither reject prompts nor clamp completion caps; only explicit operator
limits and fixed representation capacities apply. The Qwen layer evaluation
fix stays, while reservation callbacks and their hot-path checks are removed.
Actual failures remain recorded in reliability and timing results.

### 7.13 Outcome ledger

One row per §7.4 experiment, in the §7.7 vocabulary (repeatable win, measured
loss, inconclusive, blocked, unmeasured). Every campaign number was measured
on Joshs-MBP-2025.local (Apple M4 Pro, 24 GB) unless a row says otherwise;
the host is provenance, not scope. All "repeatable win" rows have at least
six balanced pairs with exact outputs. The original rows below describe
loaded-machine diagnostics. The closeout serial v6/v13 suite now passes six
balanced pairs under the recorded audio-CPU allowance, with every paired
request matching. Final-source native state and bf16/KV4 MTP-prefix gates
also pass. Continuous and combined pressure acceptance remain; no default
has changed. New evidence is in `reports/qwen38-closeout/` and
[benchmarks.md](../reference/benchmarks.md). Historical evidence paths
are relative to `reports/qwen38-rd/` on the measuring host; the narrative
behind each row is the archived log
([qwen38-27b-campaign-log.md](../archive/investigations/qwen38-27b-campaign-log.md)),
§7.9–§7.12, [turboquant.md](turboquant.md) "Packed kernel experiments" and
"Packed-value decode fusion investigation", and
[speculative-decoding.md](speculative-decoding.md) §4.7/§7.4.

| ID | Experiment | Outcome | Retained flags / defaults | Evidence files | Next discriminating step or missing resource | Reopen condition |
|---|---|---|---|---|---|---|
| R0 | Exact artifact and execution controls | **Inconclusive.** Isolated unmodified `6d45ca1`/`673b43f` checkouts: six native AB/BA pairs per flagship/compact/RTN4 match every ID at 6/128/512 prompt tokens with flat TTFT/complete/memory; six serial and six default-scheduler HTTP pairs preserve every response with flat or slightly lower complete time. Updated Bun vs MLX-LM native controls (six pairs per affine artifact, 64 tokens) emit identical IDs, complete time close, small median Bun advantage. Graph exports (v6/v8 at M=1/4/5), dispatch inventory, per-operation counter calibration and a schedule recorder exist; dispatch-level GPU sampling is unsupported on the M4 Pro, so per-kernel attribution stays open. The M4 DeltaNet golden is resolved (stale fixture; Bun and Python agree). The quiet serial/default/mlx-lm HTTP baseline never ran; the packed target has no stock mlx-lm arm. | None (controls only). | `refactor-fixed-kernel-audit-plan.json`, `refactor-native-paired{,-review}.json`, `refactor-http-paired-{serial,default}-review.json`, `native-affine-paired{,-review}.json`, `native-affine-paired/`, `native-memory-ledger.json`, `native-memory-chunk512-screen/`, `graph-captures/`, `variant8-attached.trace`, `attached-trace-summary.json`, `labelled-v8-analysis.json`, `labelled-v8-kernels.txt`, `variant8-labelled.trace`, `metal-counter-capabilities.json`, `mlx-counter-source-manifest.json`, `mlx-counter-build.patch`, `metal-counter-pooled-unit.stderr.txt`, `metal-counter-calibration-review.json`, `mlx-schedule-source-manifest.json`, `mlx-schedule-smoke-v2.log`, `top-p-schedule-screen{,-review}.json`, `empty-submit-r6-steady-trace{,-review}.json`, `mlx-empty-submit-steady-source-manifest.json` | Exclusive M4 time is now available. Finish the final-source serving/reference controls: `bun scripts/bench-serve.ts all --model-path ~/models/Qwen3.8-27B-q3-trellis-ldlq-k300-packed-interleave2-rd --arms mlx-bun-serial --context 4096 --tokens 192 --workload-seed <block>` alternated with the default arm across blocks, plus the RTN4 affine artifact with `--arms mlx-bun-serial,mlx-lm` (the only same-artifact oracle cell); quiet preflight passing; distinct `--out` per block. | Any change to the controlled path: native pack bump, artifact layout change, new kernel default. |
| R1 | Packed prefill tile decode plus matmul | **Adopted in the v0.4.0 default.** Variant 11 (tiled axis-1 gate/up, M=5..32) and variant 12 (split-K axis-0 down, M=5..8) reconstruct bf16 weights inside tiles with exact full-model logits/state/continuation; six native paired blocks improve eligible M; six raw-completion HTTP pairs per lane improve TTFT and complete time (six-token prompt, 8/64 output tokens); the second tile pass improves eight-request throughput and B=1 TTFT in six pairs. All 40 larger tile geometries at M=128/512 are exact but none beats expansion plus native matmul in six AB/BA pairs. On MLX 0.32.2/M3+ the M5..15 axis-1 path uses the wide-prefill kernel (native `gemv_wide` arithmetic); six HTTP pairs per lane improve TTFT in every pair, decode and RSS unchanged. | Trellis variant 13 is the shipped default; older variants remain explicit controls. | `variant11-full-model-review.json`, `trellis-v11-http{,-review}.json`, `variant12-full-model.json`, `trellis-splitk-{screen,tuning,full-model}-review.json`, `trellis-v12-combined-http{,-review}.json`, `trellis-v12-combined-native-review.json`, `trellis-v12-native-failure-replay.json`, `trellis-tile-layout-screen-review.json`, `trellis-tile-full-model-review.json`, `trellis-splitk-bm8-{other-bits,full-model}-review.json`, `trellis-tile-integrated-forward-review.json`, `trellis-tile-http-review.json`, `trellis-tile-seeded-serial-http-review.json`, `trellis-tile-native{,-review}.json`, `trellis-large-prefill-screen{,-review}.json`, `mlx-upgrade-0.32.2/trellis-wide-{screen,perf,full,integrated-full}`, `mlx-upgrade-0.32.2/trellis-wide-http{,-review}.json`, `mlx-upgrade-0.32.2/trellis-wide-continuous.json` | Existing six-pair serial/default/combined comparisons and final-source native gates are accepted. Reuse them; broader pressure and final report work remain separately tracked in Phase 6. | A tile geometry beating native matmul at M≥128 on real k3 matrices, or a GPU generation that changes native small-M dispatch. |
| R2 | Bounded expansion scheduling | **Repeatable win (opt-in).** Unrestricted deferral (variant 9) and unrestricted async submission gain on short prompts but fail the saved-agent pressure gate (Metal insufficient memory at the 12,954-token request). The bounded policy (async only while MLX active allocation is below 75% of the recommended working set) passes serial and continuous pressure gates; integrated six HTTP pairs per lane: TTFT -4.00%/-3.96% at 128 prompt tokens (six wins), -1.43%/-1.40% at 512; wall -0.63..-0.88%; decode flat; native M16/128/512 forwards -2.09/-6.19/-2.80% with about +368/403 MB peak allocation. | `MLX_BUN_TRELLIS_ASYNC_EXPAND=1`, variant 13 only, default off. | `variant9-full-model.json`, `trellis-v13-boundary-full-model{,-review}.json`, `trellis-v13-boundary-http-serial{,-review}.json`, `qwen-long-boundary-serial{,-review}.json`, `qwen-long-async-serial{,-review}.json`, `trellis-v13-bounded-full-model{,-review}.json`, `qwen-long-bounded-{serial,default}{,-review}.json`, `trellis-v13-bounded-http-{serial,default}{,-review}.json`, `trellis-async-integrated-{typecheck,hygiene,model-free}.txt`, `trellis-async-production-full-model{,-review}.json`, `trellis-async-production-http-{serial,default}{,-review}.json`, `trellis-async-production-long-{serial,default}{,-review}.json` | Combined arm (variant 13 + async expand + fused TurboQuant KV + MTP) through the saved seven-request agent-boundary fixture on a quiet machine; the 75% threshold has one pressure pair per lane. | A change to the memory headroom guard or to per-layer cache evaluation boundaries (R16/R17). |
| R3 | Axis-0 scatter layout and split-K | **Adopted in the v0.4.0 default.** Variant 8 (balanced word-aligned 3-bit scatter, all 32 lanes; k3/T256/L≤12) and variant 10 (scatter decode shared across M=2..4) pass exact full-model gates and improve M=1/2/4 and M=2..4 in six native blocks; row-loop unrolling not retained. A threadgroup integer codebook restricted to the M3/4 k3 interleaved down projection: six pairs -1.44/-2.00% forwards, six MTP HTTP pairs -1.07/-1.27/-1.19% complete time (5/6, 5/6, 4/6 wins), six four-request cohorts -1.49% (4/6); M1 loses and stays procedural; folded into variant 13. A 2.59% M128 control slowdown in one sequence was not reproduced by two controls. Variant 6 unchanged. | Trellis variant 13 is the shipped default; older variants remain explicit controls. | `balanced3-screen/`, `scatter-unroll-screen/`, `aligned3-screen/`, `variant8-paired/`, `variant8-full-model.json`, `shared-scatter-screen/`, `shared-scatter-all-screen/`, `variant10-full-model.json`, `trellis-threadgroup-codebook.json`, `trellis-threadgroup-scatter{,-m3}{,-review}.json`, `trellis-scatter-full{,-repeat}{,-review}.json`, `trellis-scatter-http{,-repeat}{,-review}.json`, `trellis-scatter-prefill{,-review}.json`, `trellis-scatter-sequence{,-review}.json`, `trellis-scatter-http-trace{,-review}.json`, `trellis-scatter-cohort-v2{,-review}.json`, `trellis-scatter-integration-source-change.json`, `trellis-scatter-integration-focused-tests-final.txt`, `trellis-scatter-integration-typecheck.txt`, `trellis-scatter-integrated-full{,-review}.json`, `trellis-scatter-integrated-http{,-review}.json`, `trellis-scatter-integrated-cohort{,-v2}{,-review}.json` | Existing six-pair serial/default/combined comparisons and final-source native gates are accepted. Reuse them; broader pressure and final report work remain separately tracked in Phase 6. | k2/k4 down projections (only k3 interleaved is qualified) or a new bit allocation from R19. |
| R4 | Axis-1 reduce and gate/up fusion | **Adopted in the v0.4.0 default.** Variant 7 shares each decoded gate/up weight across M=2..4 with fused gate/up, keeping the variant-6 accumulator order; exact matrix/MLP/full-model gates at M=1..5 and six AB/BA blocks retain the complete-MLP gain; the last-position append sweep confirms the M=4/5 cost discontinuity. Sharing activation loads across 2/4/8 output rows per SIMD group loses at k3 M=1; smaller threadgroups do not rescue it. The M=1 decode kernel is unchanged; the 64/128/256-thread and accumulator sweep with spill/occupancy inspection never ran because per-dispatch counters are unavailable. | Trellis variant 13 is the shipped default; older variants remain explicit controls. | `paired-shared-m/`, `variant7/`, `shared-m-full-model.json`, `shared-m-append-lengths.json`, `trellis-shared-rows-k3-r*-m1.json`, `trellis-shared-rows-k3-r*-s*-m1.json` | Missing resource: per-dispatch GPU counters or an Instruments shader profile (unsupported on the M4 Pro) to drive the M=1 thread/rows/accumulator sweep. | Kernel-level GPU timing becomes available, or a k mixture changes gate/up bit widths. |
| R5 | Decode primitive | **Measured loss.** Every alternate decoder loses at M=1 (M4 Pro): device f32 LUT (all bit widths), constant int16 table (0.802 vs 0.331 ms reduce, 0.747 vs 0.443 ms scatter, 1.474 vs 0.615 ms gate/up), device/threadgroup fp16 tables, and a constant int16 table on MLX 0.32.2 (nearly 2x complete MLP). The integer y-mad rewrite is exact with no useful gain; the readable expression stays. The only retained table is the scoped M3/4 scatter codebook (R3). The activation audit finds the packed fused SwiGLU uses a float32 precise-exp sigmoid unlike compiled MLX: a Lab distinction, no default change. | None. | `lut6-*.json`, `trellis-codebook.json`, `trellis-codebook-scoped{,-review}.json`, `trellis-constant-short-k3-m1.json`, `trellis-device-half-k3-m{1,4}.json`, `trellis-threadgroup-half-k3-m{1,4}.json`, `mlx-upgrade-0.32.2/trellis-constant-{screen,review,invalid-attempt}.json`, `trellis-y-mad-manifest.json`, `trellis-y-mad-k*-m*.json`, `trellis-activation-audit.json` | None for exact rewrites; a changed code family (QTIP/YAQA computed codes) needs a new artifact plus the KL/MMLU/tGSM/rawGSM screen before any kernel. | A hardware generation with faster threadgroup/constant memory relative to ALU, or a new code family with quality evidence. |
| R6 | Offline repacking without re-quantization | **Repeatable win (opt-in artifact).** Two-block interleaving of k3 axis-0 code words inverts to identical code bytes; prototype readers preserve 35 full-model cases. A separately written lossless artifact (quantizer `--interleave-codes`) read by every kernel from one resident code copy: six native pairs improve single-token/M4 forwards and 64-token generation in every pair with equal peak allocation; six serial and six default-scheduler HTTP pairs improve decode at 6/128/512 prompt tokens in every pair; TTFT small or mixed; RSS flat. | Not a default artifact change; served benchmarks use `Qwen3.8-27B-q3-trellis-ldlq-k300-packed-interleave2-rd`. | `trellis-block-interleave-screen-review.json`, `trellis-block-interleave-full-model-{g2,g10}-review.json`, `trellis-block-interleave-native-generation-g2-interface-review.json`, `trellis-block-interleave-http-{serial,default}-review.json`, `trellis-interleaved-readers-screen-review.json`, `trellis-interleaved-readers-full-model-count-review.json`, `trellis-interleaved-readers-order-full-model-review.json`, `trellis-interleaved-vector-schedule-screen-review.json`, `trellis-interleaved-readers-schedule-full-model-review.json`, `trellis-interleave-integrated-tests.txt`, `trellis-interleave-integrated-tail-tests.txt`, `trellis-interleave-model-free.txt`, `trellis-interleave-artifact-review.json`, `trellis-interleave-artifact-native-fd-review.json`, `trellis-interleave-encoder-tests.txt`, `trellis-interleave-artifact-http-{serial,default}-review.json` | Quiet-machine six-pair original vs interleaved artifact `bench-serve all` serial with prompt cache enabled (all artifact gates ran cache-disabled). | Expanded state-window index variant (bytes for ALU) untested; k2/k4 interleaving unqualified. |
| R7 | Small-M packed kernel | **Adopted in the v0.4.0 default.** Shared-M variants 7/8/10 reuse decoded weights across M=2..4 (R3/R4); the M=4/5 whole-model cost discontinuity is confirmed and the packed-to-expanded crossover is also a numerical boundary: the M≤8 crossover prototype wins MLP time but changes output bytes for every bit width, so it is Lab and not retained. The wide-prefill kernel (variants 11–13 on MLX 0.32.2/M3+) shares each decoded row across all M=5..15 vectors reproducing native `gemv_wide` arithmetic: 36 forward/state/continuation cases and six generations exact; six HTTP pairs per lane improve TTFT in every pair with decode/RSS unchanged. Fill spans and MTP verifies inherit these curves (R15/R20). | Trellis variant 13 is the shipped default; older variants remain explicit controls. | `shared-m-append-lengths.json`, `m8-screen/`, `mlx-upgrade-0.32.2/trellis-runtime-full`, `mlx-upgrade-0.32.2/trellis-wide-{screen,perf,full,integrated-full}`, `mlx-upgrade-0.32.2/trellis-wide-http{,-review}.json`, `mlx-upgrade-0.32.2/trellis-wide-continuous.json` | Pre-M3 GPU qualification of the wide path (the gate keeps the earlier dispatch there) via the `trellis-wide` model gate on an M1/M2 host; the M≤8 crossover needs a KL/long-state quality gate if pursued as Lab. | Any MLX runtime bump that changes small-M dense dispatch (rerun `trellis-runtime-full`). |
| R8 | Fused GDN conv/state/SiLU | **Measured loss.** A fused convolution/SiLU/copied-tail prototype matches bf16/f32 outputs and live tail at B=1/2 only with MLX's typed sigmoid expression; it passes full packed-model logits, live state, continuation and speculative rollback. Against an independently materialized baseline its full-model timing is approximately flat with similar peak memory; unpromoted. Side finding landed as default: `mlx_copy` aliasing retained the source buffer; compact state materialization now uses stock DynamicSlice. | None (DynamicSlice materialization is a memory fix, not a speed default). | `gdn-stage-probe.json`, `conv-probe-typed-sigmoid.json`, `qwen-conv-materialized-packed.json`, `materialize-final-packed-comparison.json` | None; the missing instrument is per-dispatch GPU timing of the conv stage. | Attribution shows conv/SiLU above 3% of the decode critical path. |
| R9 | GDN norm, gates and recurrence | **Measured loss.** Threadgroup layouts, fixed sequence lengths, unrolling, compiled wrappers and typed sigmoid fusion pass all 114 shape cells after correcting a float32 sigmoid rewrite that broke bf16 recurrence. A compiled fixed-length candidate preserves full-model identity but its isolated gains mostly disappear in full forwards; a fused recurrence + output RMSNorm + gate kernel passes 60 isolated cells and small-M full-model checks with a gain too small to integrate. Fixed-shape CompiledFunction over the 16 SSM groups (R16) gives -0.062%/-0.202% median. Production dispatch unchanged. | None. | `gdn-specialization-typed.json`, `gdn-static-full-model-review.json`, `gdn-fused-norm-probe.json`, `gdn-fused-norm-full-model-review.json`, `mlx-upgrade-0.32.2/qwen-fixed-ssm-groups-r6.json`, `mlx-upgrade-0.32.2/qwen-fixed-ssm-groups-rtn4-internal.json`, `mlx-upgrade-0.32.2/qwen-ssm-hot-review.json` | None until prefill-regime attribution shows the recurrence dominates (decode M=1 was the measured target). | Prefill attribution, or a transposed-state layout with a measured M=1 win. |
| R10 | Parallel/chunkwise GDN prefill | **Prefill attribution complete; no parallel rewrite retained.** Current packed-target controls and an operation observer preserve complete hidden/state hashes at 1k/4k/8k on both Macs. Gated-delta work is roughly 2.6–2.7% of M4 complete prefill, so it is not the principal bottleneck. M1 instrumentation perturbs larger runs. A chunkwise/scan formulation remains Lab because changing reduction order requires a separate quality contract. | None. | `upstream/sources.json` | Attribution is accepted; prioritize the measured expansion/projection/attention costs. A later chunkwise Metal arm needs same-input recurrent-state and held-out quality checks before any adoption. | Not applicable; never opened. |
| R11 | Affine QMV/QMM and native builds | **Inconclusive.** Shared-M affine kernels won M4/8 (and M3/5/6/7 4-bit, compact 3/8-bit) in six full-model pairs and six HTTP pairs per configuration with exact outputs and flat B1; cross-model, Gemma 12B large projections win while MiniCPM/Llama regress; a compiled-call cache was closed. MLX 0.32.2 (native pack 0.4.0) superseded it: upstream `qmv_wide` implements the same reuse with different arithmetic, so the custom kernel and its flag were removed (§7.12); frozen source controls keep it. New-core affine Q3 gate/up operations beat the old shared ops in all six blocks, Q4 mixed, Q8 loses (operation level); RTN4 short decode flat, long-prefill timing order-dependent; twelve RTN4 oracle cells and 4K/8K prompts byte-exact on both cores. No end-to-end Qwen gain from the runtime change is established. | Native pack 0.4.0 (MLX 0.32.2) is the pinned runtime; no flag. | `affine-qmv-screen.json`, `affine-qmv-compiled.json`, `affine-shared-m-probe{,-initial}.json`, `affine-shared-m-debug-scale-bits.json`, `affine-shared-m-full-model-{packed,rtn4}-review.json`, `affine-shared-m-http-rtn4-review.json`, `affine-shared-m-production-full-model-rtn4-review.json`, `affine-shared-m-shapeless.json`, `affine-shared-m-integrated-unit.txt`, `affine-shared-m-integrated-http-rtn4-review.json`, `affine-shared-m-width-{rtn4,full-model-rtn4}-review.json`, `affine-shared-m-all-bits-*.json`, `affine-shared-m-broader-*`, `shared-affine-frontier-http-{rtn4,compact}-review.json`, `affine-compiled-call-cache-{full-model,http}-compact-review.json`, `affine-shared-cross-model-exactness.json`, `affine-shared-cross-model-{gemma12,gemmae4b,minicpm5,llama1,llama3}-review.json`, `affine-cross-model-matrix-{inventory,screen,screen-review}.json`, `affine-cross-model-matrix-gemma12-repeat.json`, `affine-head-batched-decode-mfirst-{llama1,llama3}-review.json`, `affine-shared-head-http-{llama1,llama3}-overlap-review.json`, `affine-large-projection-*.json`, `affine-nonfast-*-review.json`, `mlx-upgrade-0.32.2/affine-{old,new}-screen.json`, `mlx-upgrade-0.32.2/affine-runtime-repeat{,-review}.json`, `mlx-upgrade-0.32.2/runtime-oracle-rtn4{,-macos14}.json`, `mlx-upgrade-0.32.2/runtime-oracle-long-macos14.json`, `mlx-upgrade-0.32.2/native-runtime-screen{,-review}.json`, `mlx-upgrade-0.32.2/final-source-gates.json` | Quiet-machine six-pair old-core vs 0.32.2 `bench-serve all` on the RTN4 artifact with the same-artifact mlx-lm arm, to separate the runtime change from kernel changes. | A native pack bump, or MLX changing `qmv_wide` eligibility for GQA6/D256 or Q8 shapes. |
| R12 | Norm/residual/activation/projection fusion | **Measured loss.** Residual-add/RMSNorm kernel (90 synthetic cases exact; six packed pairs at M1/4/8/128): M1 slightly slower, M4/8 flat, M128 varies. Fused affine gate/up/SwiGLU with the typed sigmoid (48 RTN4 cells exact): only M=1 wins in isolation, full-forward gain too small. Multimodal RoPE shared angles/direct strides (108 cases exact): M128 slightly slower, M512 flat, image encoding excluded. None integrated; helpers removed. Full-attention output-gate and QKV concatenation fusions were enumerated but not prototyped. | None. | `residual-rms-screen-scalar-review.json`, `residual-rms-full-model-packed-review.json`, `affine-gateup-debug{,-typed}.json`, `affine-gateup-typed.json`, `affine-gateup-full-model-review.json`, `mrope-reuse-screen-review.json`, `mrope-stride-full-model-packed-review.json` | None until per-kernel attribution shows elementwise/norm dispatches exceed 3% of the decode critical path. | Attribution evidence as above, or a real vision-request benchmark for mRoPE. |
| R13 | Attention and KV | **Repeatable win (opt-in).** Joint TurboQuant K/V packed decode plus row-grouped inverse rotation at N≥8192: six 8,846-token HTTP blocks on R6 k8v3 improve decode 83.87% and complete time 12.77% versus the original codec, inverse rotation adds 5.39%/1.05%; on MLX 0.32.2 the inverse improves decode 4.69% (R6) and 5.98% (RTN4) in every pair, R6 complete -0.79% all six, RTN4 complete inconclusive; six MiniCPM and six Gemma deferred-consumer pairs improve complete time. Direct packed-key attention is exact but 6–19% slower than joint decode plus native SDPA (closed). Dense register-resident attention loses timing; Steel D256 fails one KL screen (Lab). KV append census: ordinary appends copy only the new row, rejecting the whole-cache-copy hypothesis; no append kernel. bf16-KV rows unaffected; TurboQuant KV remains serial-only. | `MLX_BUN_TURBOQUANT_FUSED_DECODE=1`, default off; details in turboquant.md. | `tq-value-*{,-review}.json`, `tq-kv-screen.json`, `tq-kv-independent.json`, `tq-kv-repeat{,-review}.json`, `tq-kv-full{,-review}.json`, `tq-kv-policy-http{,-review}.json`, `tq-kv-long-full{,-review}.json`, `tq-kv-rotation-{screen,repeat,rows-screen,rows-repeat,long,long-http}{,-review}.json`, `tq-kv-rtn4-full{,-review}.json`, `tq-kv-nonfinite.json`, `tq-kv-minicpm-full{,-review}.json`, `tq-kv-gemma-e4b-full{,-review}.json`, `tq-kv-integrated-*{,-review}.json`, `tq-kv-integrated-rtn4-http-acceptance.json`, `tq-kv-memory{,-review}.json`, `allocator-capacity-repro.json`, `tq-kv-inverse-integrated-r6-full{,-review}.json`, `mlx-upgrade-0.32.2/{r6,rtn4}-kv-inverse-full.json`, `mlx-upgrade-0.32.2/inverse-kv-http{,-replacement,-review,-isolation}.json`, `mlx-upgrade-0.32.2/deferred-kv-http{,-review}.json`, `tq-key-sdpa-screen.json`, `tq-key-sdpa-complete-repeat{,-review}.json`, `steel-attention-tune-manifest.json`, `attention-cpu-check.json`, `attention-oracle-check.json`, `attention-full-model-packed-128-512-review.json`, `dense-attention-memory-tune-review.json`, `kv-append-donation-probe{,-review}.json`, `kv-append-model-trace-2049{,-review}.json`, `kv-append-http-text-census{,-review}.json`, `kv-append-native-8193{,-review}.json` | Quiet-machine six-pair `bench-serve all --arms mlx-bun-serial --kv-quant turbo` flag off/on on both quants at 8k context; separately the unmeasured three-query KV4 verify-window head-pairing screen from §7.7. | MLX ships fused quantized SDPA for GQA6/D256, TurboQuant KV becomes batch-eligible, or the RTN4 complete-time cell resolves. |
| R14 | Vocabulary head and sampler | **Adopted normalized greedy kernel; other candidates remain characterized separately.** Same-input model/operation checks pass on both Macs. MiniCPM standard AB/BA throughput improves and packed Qwen MTP3/TQ stays effectively flat. **Inconclusive.** Compiled Metal grammar bitmask (`MLX_BUN_TOKEN_MASK=metal`) preserves mask bytes and sampled IDs at three vocabularies and beats the host loop in eight paired blocks, but six compact HTTP pairs at B1/B4 are inconclusive (B1 flat, B4 regresses under residual swap); host masking remains default. Top-p inverse-permutation removal is exact in 216/180 cases; Qwen packed serial six pairs +0.183% complete time (loss), Llama 1B -0.399%/-0.380% with six wins per lane; no production change. DSA sort keys reduced to uint32 are integrated as a shared-operation win (selection latency -10.47..-15.80%), not a Qwen result. Grouped greedy verify readback closed (R21). The exact fused matvec/argmax head was never prototyped. | Shared normalized greedy selection is the default. Grammar-mask Metal selection remains opt-in; DSA uint32 keys are integrated. | `token-mask-probe.json`, `token-bitmask-unit.txt`, `token-bitmask-grammar-metal.txt`, `token-mask-sampling{,-review}.json`, `grammar-mask-http-compact-review.json`, `top-p-scatter-screen-v2{,-review}.json`, `top-p-scatter-compiled-screen{,-review}.json`, `top-p-lifetime-{source,native,scatter,metal}.json`, `top-p-sampler-screen-v2{,-review}.json`, `top-p-native-screen{,-review}.json`, `top-p-http-screen{,-review}.json`, `top-p-http-r6-serial-repeat{,-review}.json`, `top-p-http-llama-repeat{,-review}.json`, `dsa-order-u32-{screen,repeat}{,-review}.json`, `dsa-rank-u32-{screen,repeat}{,-review}.json`, `dsa-model-screen.json`, `dsa-rank-u32-model-tests-v2{.txt,.transform.json}`, `dsa-production-{unit-v2,typecheck-v2,model-free,hygiene}.txt`; `reports/prefill-observation/sampler-*` | Quiet-machine six-pair grammar-mask host vs metal at B1/B4 on a structured-output fixture (the only open candidate with a positive operation result). | Head attribution shows the vocabulary projection or readback material for greedy requests. |
| R15 | Deterministic no-verification replay | **Repeatable win (opt-in).** Strict fill has parser-state guards (complete `</parameter>` delimiter, request-local tool-only context), a schema open-object compiler fix, and model-owned four-token append chunks that reproduce M1 arithmetic via broadcast `[M,1,K]` weight views and split at MLX attention transitions (KV 1023/1024/8192/32768/65536 on `applegpu_g16s`). Final internal-SSD comparison: twelve balanced pairs, 96 exact responses, zero verification; complete time -9.83%/-15.40% (R6 weather/bash) and -1.63%/-2.94% (RTN4), every pair improving; tool output is buffered so this is not a decode-rate result. Staged-body prototype flat, closed. Quantized-KV composition: TurboQuant k8v3 passes after a lease fix, affine KV4/KV8 now preserve complete state after one-token attention is retained within shared projection appends. The qualified model binding declares KV4/KV8 and K8V3 support; delayed conversion passes real-generation state checks. Both quants retain exact HTTP responses in six-pair affine and TQ comparisons. Saved tool-history fixtures pass 20 affine pairs; held-out task quality and quantized verification remain separate. | `MLX_BUN_FILL=strict`, `MLX_BUN_FILL_APPEND_CHUNK_SIZE=0` (model limit), `MLX_BUN_FILL_MAX_SPAN=32`; default off. | `fill-parser-boundary-r6.json`, `fill-boundary-tokenizer-audit-v4.json`, `fill-boundary-cpu-tests-v8.log`, `fill-boundary-native{,-m1,-batch1,-batch1-v2-rtn4}-r6.json`, `fill-first-layer-{shape-probe,batched-m1}.json`, `fill-boundary-http-{screen,repeat,review}.json`, `fill-append-*.json`, `fill-append-final-model-free.log`, `fill-append-state-ownership-native-test.log`, `fill-schema-*`, `strict-fill-variant{6,7}.txt`, `strict-fill-v1{0,1}-cap{32,4}-served-eos.json`, `fill-adversarial-state-v12-eos-review.json`, `fill-state-v12-cap{32,4}-{eos,seed42}.json`, `fill-identical-input-append-review.json`, `fill-chunked-*-review.json`, `fill-integrated-{state-v12-seed42,http-packed}-review.json`, `fill-chunked-integrated-{unit,model-free,typecheck,hygiene}.txt`, `fill-staged-unit.txt`, `fill-staged-state-v13-seed42-review.json`, `fill-staged-complete-requests-review.json` | Frozen held-out real-session/adversarial corpus through `MLX_BUN_TEST_FILL_MODEL=<dir> MLX_BUN_FILL=strict bun test tests/parity/fill-strict.test.ts` on both quants (token IDs, stop decisions, subsequent logits/state), then a quiet six-pair HTTP repeat. | A Qwen tool-template or parser change, tool schemas with pattern properties, or a chunk-limit qualification on another GPU. |
| R16 | MLX graph and loop | **Earlier output adopted.** Early first token in the serial loop: six native pairs improve first-token latency at 6/128/512 tokens with exact tokens/state/usage; six chat HTTP pairs (84 requests, 42 exact) improve first visible output with complete time flat; raw prompts show no client gain because token 220 emits no event. The suffix screen finds a prefill-shape effect after a one-token return (seven packed/six RTN4 cases change state); explicit M=1 alignment restores exactness. The final caller-owned alignment passes both-machine state/continuation checks and monitored M4 serving comparisons; first visible output improves with complete time close. Closed: shape-specific compiled-call cache, Metal launch-config cache (MiniCPM HTTP mismatch unresolved), untouched-finalize elision (-0.069%), submission/traversal limits for Qwen (Llama 25/25 gives -2.44% native and -1.86..-3.02% HTTP, diagnostic, not integrated), fixed-input proxies, per-layer graphs (RTN4 fails identity), whole-model graph (slower), SSM-group compilation (-0.06%/-0.20%). Shapeless custom kernels are an upstream MLX limitation. | `MLX_BUN_EARLY_FIRST_TOKEN` defaults on; `=0` retains the old output order. | `first-yield-*`, `first-token-production-long-{serial,continuous}{,-review}.json`, `first-token-lifecycle-{llama,qwen}{,-review}.json`, `affine-compiled-call-cache-{full-model,http}-compact-review.json`, `metal-config-cache-*`, `mlx-untouched-finalize-source-manifest.json`, `untouched-finalize-*`, `graph-schedule-screen-plan.json`, `graph-schedule-screen{,-review,-contamination}.json`, `graph-schedule-rtn4-rescreen-v2{,-review}.json`, `graph-schedule-llama-repeat{,-review}.json`, `graph-schedule-llama-http-repeat{,-review}.json`, `mlx-upgrade-0.32.2/custom-kernel-compile-probe.json`, `mlx-upgrade-0.32.2/fixed-custom-probe.json`, `mlx-upgrade-0.32.2/qwen-fixed-region-{r6,rtn4}-v{2,3,4}.json`, `mlx-upgrade-0.32.2/qwen-fixed-layer-{r6-full-v2,rtn4-full}.json`, `mlx-upgrade-0.32.2/compiled-region-probe.json`, `mlx-upgrade-0.32.2/qwen-fixed-hidden-regions-{r6,rtn4}.json` | Early-output native, HTTP, cancellation/overlap and cached/SSD acceptance is complete; see benchmarks.md for monitored repeats and activity limits. Scoped Llama submission-limit integration remains a separate model-owned candidate. | MLX adds shape-inferring CustomKernel or graph replay, or per-token host-overhead attribution changes. |
| R17 | Hybrid prefix and recurrent state reuse | **Implemented and accepted for generated reuse.** One cache owns immutable target/recurrent state and draft companions, original generated token IDs, session/content lookup, RAM residency and queued SSD persistence. Native and HTTP checks cover continued mutation, cancellation, earlier-boundary fallback and fresh-process restoration on both Macs. The saved Kanban miss/OOM sequence passes with identical output; the completed session-cache Kanban run hits every follow-up and flushes all snapshots durably. Its app-quality defects remain separate from cache acceptance. | Shared RAM/SSD publication and generated-token provenance are enabled; whole-file SSD and LRU remain selected after measured alternatives. | `reports/kanban-cache-fixed-fresh/`, `reports/kanban-cache-fixed-repeat-r1/`, `reports/kanban-session-cache-r2/`; [cache implementation](kv-cache.md#54-background-persistence-and-ram-residency) and [measured task comparison](../reference/benchmarks.md#full-kanban-with-session-cache-and-queued-persistence). | No missing generated-history implementation. Reuse the completed native/HTTP and full-task evidence; do not rerun unchanged gates. | A reproduced history-alignment, retention, durability or reuse regression. |
| R18 | Scheduler | **Early output and shared batching adopted.** Continuous-scheduler early yield (same `MLX_BUN_EARLY_FIRST_TOKEN` flag): six AB/BA blocks, 84 responses, 42 exact, median TTFT -7.66% code / -7.90% explanation / -5.63% JSON (74–77 ms) with complete time +0.04..+0.15%; the integrated one-block check gives -68..-90 ms; 120 streaming cancellation/arrival requests pass on both quants and lanes. Concurrency evidence for kernels: v6 vs v12 four-request waves improve every pair and the tile pass improves eight-request throughput (R1). The historical four-request kernel waves predate shared cohorts. B-wide prefill is now adopted, and current default serving uses shared ordinary/speculative execution; mixed iteration work is measured and remains off. Fixed-arrival sustained serving remains open. | Early first output defaults on; `MLX_BUN_EARLY_FIRST_TOKEN=0` retains the control. | `first-prepare-scheduler-{control,candidate}.txt`, `first-prepare-http-screen-plan.json`, `first-prepare-http-{screen,repeat}{,-review}.json`, `first-prepare-production-{unit,model-free,typecheck,hygiene}.txt`, `first-prepare-production-http-r6-v2{,-review}.json`, `first-token-lifecycle-{llama,qwen}{,-review}.json`, `trellis-concurrent-http{,-review}.json`, `trellis-tile-http-review.json`, `trellis-scatter-integrated-cohort-v2{,-review}.json` | Fixed-arrival-schedule sustained-serving cell (concurrency 2/4/8; per-request queue/TTFT/latency and aggregate tok/s, verified lane and admitted rows) per §7.10 on a quiet machine. | A change to admission, mixed-work scheduling or output/cache boundaries. |
| R19 | Weight-quality allocation | **Unmeasured (not started).** No latency-aware allocation objective ran alongside the kernel work as §7.7 requires. Quality evidence predates §7 and lives in turboquant.md (Q3 KL 0.1553 at 3.55 bpw; Q2b packed 12.14 GiB, KL 0.1550; rotated down axis kept because `--down-axis in` costs rawGSM 29/50 vs 44/50). The Kanban task ran on the k300 packed artifact; R6 interleaving is lossless so it adds no quality delta. Q5 2.75-budget arm, q2a/q2b task columns and the rawGSM EOS-cliff root cause remain open in turboquant.md. | None. | turboquant.md "Q campaign" and "FINAL BOARD" sections | Allocation sweep weighting per-role bits by the measured M=1 kernel costs from R3/R4/R5, gated by the frozen KL/MMLU/tGSM/rawGSM screens; needs GPU time for quantization and evaluation. | Not applicable; never opened. |
| R20 | MTP economics | **Repeatable win (opt-in).** Six balanced three-arm blocks versus native full-prefill on the packed artifact: fixed two drafts change complete time -43.22%/-38.81%/-44.92% (code/explanation/JSON) with every pair improving, TTFT -5.5..-8.4%, peak RSS +653 MiB; RTN4 -34.95%/-26.95%/-38.48%. Adaptive one-to-three drafts adds about 3% (ratios 0.9698/0.9782/0.9624) and stays research-only. Folded 4-bit/8-bit MTP heads: -1.48/-3.67/-2.95% and -0.65/-2.29/-1.86% with peak RSS 12.53/12.74 vs 13.04 GB; 1,184 vocabulary rows and 48 state samples byte-exact against serial replay. EOS and finish-reason accounting fixed. The quiet M1 Max control (0.821x at gamma 2, 2026-08-18) predates the kernel work. Shared serving has short depth-2/3/4 comparisons, native depth-3 coverage and completed late-context MTP1/2/3 controls. Current KV4/MTP2 and fused K8V3/MTP3 both pass the 78,678-token cached/SSD workload. KV4/MTP2 remains the measured long-agent recommendation; depth 3 crosses a different KV4 value-product dispatch boundary. See benchmarks.md. | `--draft-kind mtp --num-draft-tokens 2` opt-in; EOS/finish-reason fixes landed. | `mtp-v*-gamma*.json`, `mtp-corpus-screen/`, `mtp-screen-prompts.json`, `mtp-heldout-{plan,http,http-review}.json`, `mtp-heldout-native{,-review}.json`, `spec-token-counts-*.txt`, `mtp-post-eos-http{,-review}.json`, `spec-eos-serving-*.txt`, `mtp-eos-budget{,-integrated}-http{,-review}.json`, `spec-eos-continuous-*.txt`, `eos-budget-continuous{,-v2}-http{,-review}.json`, `mtp-quantized-draft-*-http{,-review}.json`, `mtp-draft-artifact-q4-{build,audit}.json`, `mtp-draft-quant-oracle.json`, `mtp-draft-artifact-q8-build.json`, `mtp-quantized-loader-*.txt`, `mtp-artifact-ownership{,-v2}.json`, `mtp-artifact-{screen,repeat}-http{,-review}.json`, `mtp-artifact-native{,-context}{,-review}.json`, `mtp-artifact-context-screen-http.json`, `mtp-matched-prefill-{r6,rtn4}-{screen-http,repeat}{,-review}.json`, `mtp-rtn4-screen-{plan,http,http-review}.json`, `mtp-rtn4-divergence-v2-audit{,-review}.json`, `mtp-rtn4-prefill-control{,-review}.json`, `mtp-v10-{planets,prose}-gamma{2,3}.json`, `mtp-provider-dispose-{before,after}.json`, `mtp-provider-ownership-tests.txt`, `mtp-post-dispose-http.json` | Late-context KV4 depths 1/2/3 and ordinary controls are complete; the current ordinary cached-repeat failure is resolved. TQ/MTP3 passes the original context, RAM repeat and SSD restart. Current-source KV4/MTP2 and automatic prefill sizing pass; KV4/MTP2 remains the measured agent recommendation. | Any change to verify-window arithmetic (KV4 head pairing, fused KV) or a DFlash2 drafter (R21). |
| R21 | Other exact speculative sources | **Shared lookup implemented; DFlash2 unimplemented.** Qwen DFlash2 (the z-lab artifact behind the oMLX record the video cites; block size five, native MTP off) needs dynamic grouped causal convolutions around attention and MLP plus a top-16/rank-256 selector; the existing DFlash provider does not implement that architecture, so loading the checkpoint would not be DFlash2. Grouped greedy verify readback is closed: six three-arm blocks, 84 exact comparisons, concatenation improves only 0.33%/0.06%/0.23% and the evalAll variant regresses JSON 0.44%. Prompt lookup is now adopted through the shared variable-proposal verifier, with both-machine bf16/KV4/KV8/TQ B4 serving, generated RAM/SSD and MTP regression checks. M4 arm orders show small single-request gains and lower aggregate throughput with changed concurrent outputs; it remains optional. The DSpark/DFlash execution provider has seeded-fixture coverage, but no trained checkpoint exists. This does not implement DFlash2. SpecPrefill remains a separate approximate Lab arm. | Shared prompt lookup is available; trained-drafter performance remains unmeasured. | `video-dHK90xc9Q64/`, `video-dHK90xc9Q64/dflash-source-manifest.json`, `spec-grouped-greedy-screen.json`, `spec-grouped-greedy-eval-screen.json`, `spec-grouped-greedy-three-http{,-review}.json` | Missing resource: a DFlash2 architecture/selector port with target-state/rollback identity and draft residency, then a three-arm block (ordinary / fixed-two MTP / DFlash2) on the held-out prompts. | The port exists, or an exact n-gram source shows at least 3% on the saved Kanban history. |
| R22 | Residency and shared memory | **mmap loss; range-construction improvement.** Page-aligned file-backed weights through Metal roots are exact in every payload/output case, but six native pairs give +0.25% (later +0.02%) on 64-token generation with no faster pair, six serial HTTP pairs +0.04..+0.14% complete and +0.14..+0.21% decode, and the balanced cold-start follow-up is worse in five of six pairs (+18.42% first token, +12.93% first generation). Peak RSS falls from 12,182,749,184 to 482,508,800 bytes as file-backed accounting only; physical RAM saving unproven. A read-only donation hazard was found and fixed in the prototype before closing; helpers removed. Retained as memory correctness, not speed: the 8 MiB bounded range cache in `mlx/ops.ts` (Kanban sustained run peak active -1,582,612,480 bytes, +2.171% time in one pair) and per-chunk draft-KV evaluation. | Native long position ranges reduce operator/host-allocation work without a material model/serving speed claim; bounded range cache and per-chunk draft-KV evaluation remain memory fixes. | `mmap-page-window{,-pointer}-screen.json`, `mmap-weights-native-{llama1,packed}-screen.json`, `mmap-weights-native-packed-paired{,-review}.json`, `mmap-weights-http-serial{,-review}.json`, `mmap-weights-ownership-packed{,-mapping}.json`, `mmap-weights-single-consumer-lazy{,-mapping}.json`, `mmap-weights-whole-consumer-lazy.json`, `mmap-whole-consumer-source-integrity.json`, `mmap-donation-{ro,cow}-screen.json`, `mmap-managed-donation-screen.json`, `mmap-weights-managed-whole-consumer-lazy{,-mapping}.json`, `mmap-managed-submitted.json`, `mmap-weights-managed-native-{repeat,screen}{,-review}.json`, `mmap-initial-residency-attribution.json`, `mmap-lazy-view-ownership.json`, `mmap-weights-lazy-managed-native-screen{,-review}.json`, `mmap-prefault-native-screen.json`, `mmap-cold-native-repeat{,-review}.json`, `mmap-managed-shard-release{,-mapping}.json`, `mmap-managed-active-accounting-review.json`, `kanban-arange-{allocation-evidence,regression,micro-memory,reconstruction}.json`, `kanban-sustained-77k-owned-control.json`, `kanban-sustained-arange-comparison.json` | Native long int32 positions are accepted as an operator/host-allocation optimization after exact range/view/bound checks, six monitored M4 complete-forward pairs and two standard serving arm orders. Model and serving performance are effectively flat; the initial unmonitored regression is not reproduced. A reusable power-of-two prefix remains unselected after an inconsistent M1 screen. See benchmarks.md for activity records and limits. | A controlled page-cache-cold startup cell (§7.10) exists; mmap lost warm but cold was never controlled. |
| R23 | Media and task completion | **Inconclusive.** The fresh Pi Kanban task on the 12.14 GiB packed target with Luke's `qwen3.8-27b-q3_k_xl-coding-128k` profile (131072 context, xhigh thinking, temperature 0.6, seed 42; KV4, MTP depth 2, paired prefixes, MLX 0.32.2) completed in 3h 33m 7.685s with 130,494 output tokens over 62 requests, 79.706% draft acceptance, 11.916 GiB peak combined RSS; the untouched app passes the functional browser checks. Earlier attempts failed on a tool-parser bug, dropped reasoning history, Metal OOM at the 85,238-token request and OOM during sustained decode. The later accepted R17 session-cache Kanban run completes in 83m57s with 76,031 output tokens, every follow-up cached and durable final persistence; its two application defects remain recorded. No matched successful original-source run exists, so these different trajectories cannot supply an engine-only task-time speedup. Image/video tower and encoder-cache cells remain unmeasured. | Tool-parameter parser and `reasoning_content` alias landed as correctness fixes; no speed default. | `lukes-kanban/`, `kanban-final/optimized-mtp-invalid-32k-sleep/`, `kanban-final/luke-q3-128k-xhigh-{history-fixed,tool-values-fixed,mtp-memory-fixed,arange-bounded}/`, `kanban-final/comparison.html`, `kanban-capacity-110k-control.json`, `kanban-capacity-8k-final-comparison.json`, `kanban-capacity-110k-owned-final.json`, `kanban-memory-http-{owned,responsiveness}.json`; numbers in benchmarks.md Kanban sections | Missing resource: about four hours of exclusive GPU ownership on an idle machine for a matched original-source run (`673b43f`, variant 6, bf16 KV, no MTP) under the identical profile, prompt, seed and harness. | No engine-only task-time ratio without a matched baseline. R17 generated-history acceptance is complete and does not need another unchanged task run. |
| R24 | Larger departures | **Blocked.** Only feasibility and operation screens exist. For the video's tq3-mini codebook format (eight-centroid indices, ten codes per uint32, 3.2 bits/value), the literal upstream `polar_qmv` through the Bun binding on synthetic matrices: explicit SIMD shuffles cut the 5120-to-17408 rotated operation 2.77–3.84% (every pair), and a fused fp16 expansion cuts large-prefill operation time 40.85–57.51% with about 765 MiB less temporary allocation. No production loader or kernel, no quality evidence; the checkpoint's reported agent failures are unresolved. Learned quantization, sparse residuals, activation quantization, pruning, layer skipping, low-rank, QAT/distillation and alternative drafters have no recorded kernel/quality/memory/benefit estimate. | None. | `video-dHK90xc9Q64/`, `polar-qmv-screen-v2.json`, `polar-qmv-variants.json`, `polar-qmv-geometry.json`, `polar-qmv-repeat{,-review}.json`, `polar-expand.json`, `polar-expand-repeat{,-review}.json` | Missing resource: a decision to build a loader for the tq3-mini format plus its KL/MMLU/tGSM/rawGSM screen on the actual checkpoint; without that the row is a feasibility bound only. | An artifact with quality evidence at or below Q2b bytes, or the operation gains reproduced whole-model. |

Josh's original direction is to "only ask the model to decode tokens that we
can't reasonably already know." This includes reasoning snippets copied into
tool arguments, repeated atomic values such as URLs, and predictable tool JSON
structure and field order. The goal is deterministic continuation wherever the
application can establish the text, with known-text proposals where the model's
choice remains uncertain. Prefix-cache reuse avoids rereading history; it does
not by itself avoid generating the same text again. Strict appends and verified
copy proposals have different behavior contracts and must be measured as such.
Josh deferred the broader deterministic-continuation investigation. Generated
state reuse is active R17 work and comes first; it is part of the original
cache objective, not completion of the broader continuation direction.

The R17 closeout audit confirms a reusable generated prefix in the saved
first tool turn: the first response's reasoning text tokenizes as an exact
extension of the original prompt inside the next rendered request. This is
textual opportunity evidence only, not an accepted recurrent-state snapshot
or a timing result. See `reports/qwen38-closeout/r17-first-tool-prefix-opportunity.json`.
A candidate must retain aligned target KV/recurrent state, draft KV and the
pending true hidden row at a completed decode boundary before tool formatting
can diverge. Preserve the original prompt snapshot as a fallback within the
existing cache budget. Test with independent prompts and verify snapshot
identity after further decode; saved task timings cannot substitute for that
state test. Quantities and original task timings belong in benchmarks.md.

R17 uses the existing tiered cache. `createMlxSerialExecutor` now passes its
shared cache service into speculative execution. `QwenMtpProvider` supplies a
checkpoint codec and retains no prefix store of its own. Prefill publishes
paired target/draft state through `PromptCache.take`/`put`; processed output
publication remains unfinished. `PromptCache` owns RAM/SSD prefix selection,
eviction and write-behind persistence. The execution-state interface must capture, restore and serialize a
complete token-prefix checkpoint, regardless of whether those tokens came
from a prompt or generated output. Qwen MTP supplies its target KV/recurrent
state, draft KV and pending hidden row through that interface; it must not
grow a second storage policy.

The first implementation step now gives ordinary and batched consumers the
same `PrefixCache` contract. MLX companion tensors flow through the existing
RAM budget, spill queue, streamed SSD writer/reader and durability coordinator.
The new storage tests pass on M1 Max and M4 Pro, including a fresh-process
restore; layout and ownership details belong in [kv-cache method companion state](kv-cache.md#method-companion-state).
Qwen MTP prefill migration now passes native bf16/KV4 RAM and SSD restart
continuation gates on both Macs. Live target/draft/hidden hashes, emitted IDs
and acceptance decisions match after reuse; the cache/provider restart also
checks stable draft identity. Raw gates are in
`reports/qwen38-closeout/composition-baseline/{m1,m4}-shared-mtp-cache-*.log`.
Generated-ID alignment, native fresh-process continuation and saved-request
performance acceptance remain unfinished.

A subsequent isolated output-checkpoint candidate resolves the final verified
round and publishes only processed content. Synthetic stop/EOS/callback cases
pass. Generated-prefix SSD continuation matches fresh recomputation on M1 Max
in bf16/KV4 and on M4 Pro in KV4. M4 bf16 preserves checkpoint bytes but changes
the next argmax; a fresh split-prefill control also changes logits. The cause
is not yet established against a matched execution/oracle control, so this
candidate is not adopted. Evidence: `composition-baseline/m*-mtp-generated-reuse*.log`
under `reports/qwen38-closeout/`. Shared execution work continues independently.

A subsequent shared-method implementation publishes target-row and draft-provider
snapshots through the common cache port before retirement. M1/M4 bf16/KV4/fused
TQ native tests preserve actual processed-ID coverage and RAM/SSD continuation,
including early stops and immutable donors after sibling/follow-up work.
Production parser/template replay also preserves the sampled prefix of bounded
tool turns with thinking off/on. Production HTTP RAM reuse and fresh-process
SSD restoration now also pass on both Macs in bf16/KV4/fused TQ with thinking off/on;
responses, logprobs and acceptance match within each restart pair. These
results do not replace the long Kanban or performance gates. The five-file
change is adopted; final native/HTTP composition with the prefill-policy fix
and its matched short M4 benchmark now pass. Long Kanban and pressure
acceptance remain. Details belong to the method-companion
section in kv-cache.md; evidence is in the separate
`generated-prefix-composition-validation` checkout's `reports/generated-prefix/`.

The pre-refactor source and measured-evidence hashes are preserved under
`reports/qwen38-closeout/composition-baseline/manifest.json`. It distinguishes
the current unmeasured working tree from the frozen source used for the M4
comparisons. Baseline numbers and limitations remain in benchmarks.md. Keep
interface refactors, kernel experiments and the MTP depth comparison as
separate changes before measuring their composition.

Acceptance must cover actual generated IDs at a rendered-stable boundary,
continued generation after capture without changing the retained state, RAM
reuse, eviction to SSD, a fresh-process SSD restore, and an exact-prefix miss
that still selects a usable earlier checkpoint. Retain shorter recurrent
boundaries because a later state cannot be trimmed back. Account for all
companion tensors in the existing cache budgets and persistence lifecycle.
Measure complete next-request time, including capture/write/restore cost;
the saved work is not literally free. The current Kanban candidate remains
frozen while this change is developed and supplies the pre-R17 task evidence.

The private `joshuarossi/kanban-board` archive was audited at
`c34577fecbf5e1b4c48c13b14c7a7f92b92b6ba9`. Its first request and first SSE
response are byte-identical to the original saved evidence. The archived
second request changes two literal escape sequences inside reasoning from
`\u0000` to `\^@`; this explains its earlier reconstructed-prefix divergence.
Do not change either evidence copy or treat that archive difference as a Pi
serialization defect. The original saved request retains the full reasoning
prefix. Both comparisons retokenize decoded reasoning; the SSE has no original
sampled IDs, so the execution-state gate must record those IDs directly.
Evidence: `reports/qwen38-closeout/r17-repo-prefix-audit.json`.

#### Shipped defaults and remaining experiment gates

[Server configuration](../reference/server-config.md) owns effective defaults,
precedence and supported combinations. Trellis v13, eligible KV4 speculation
and paired MTP prompt reuse shipped in v0.4.0. Shared batching is the default;
R17 generated RAM/SSD persistence and long-agent setting selection are accepted.
Serial removal and exhaustive feature migration are deferred by the current
milestone. Remaining experiments do not reopen those completed gates.

| Control | Accepted evidence | Remaining work |
| --- | --- | --- |
| `MLX_BUN_TRELLIS`, `MLX_BUN_TRELLIS_VARIANT` | Shipped selection; six serial, six continuous and six combined KV4/MTP pairs, plus native state gates. | Additional experimental variants retain their own numerical/performance requirements. |
| `MLX_BUN_TRELLIS_ASYNC_EXPAND` | Native, short serving and saved long-agent pressure checks pass. | Broader combined settings; retain as an experiment until a supported workload wins. |
| `MLX_BUN_EARLY_FIRST_TOKEN` | Streaming/cancellation/overlap and cached/SSD gates pass. Caller-owned M=1 alignment preserves state on M1 and M4. Monitored paired chat HTTP checks support earlier visible output; default on. | No open early-output acceptance gate. Invisible token zero need not improve raw-prompt latency; no decode-throughput gain claimed. |
| `MLX_BUN_TURBOQUANT_FUSED_DECODE` | Joint decoder and inverse rotation pass Qwen native/HTTP and MiniCPM/Gemma deferred-consumer gates. Codec policy composes with shared ordinary/drafting groups; fused K8V3/MTP3 passes the 78,678-token cached/SSD run. | Additional combined/pressure cases; separate codec-setting comparisons from kernel-only gains. |
| `MLX_BUN_QWEN_SPEC_KV4` | Combined M4 pairs, completed tasks and the current 78,678-token cached/SSD workload pass. KV4/MTP2 remains the measured long-agent choice. | Three-query verify-window head pairing is a separate unmeasured kernel candidate. |
| `MLX_BUN_MTP_PROMPT_CACHE` | Shared byte accounting, generated-boundary checkpoints, RAM/SSD restart and full Kanban session retention pass. | No open R17 acceptance gate; new methods retain their own state contracts. |
| `MLX_BUN_FILL`, append chunk/span controls | Qualified Qwen committed appends preserve bf16/KV4/KV8/K8V3 state; balanced HTTP and saved tool-history fixture comparisons pass. | Held-out task quality, shared direct append, speculative/quantized verification and other model/GPU qualifications remain distinct cells. |
| Fill trace and echo-index controls | Trace is diagnostic; echo is a separate Lab algorithm. | Disable trace for timing; measure echo task quality and whole-request cost before promotion. |
| `MLX_BUN_RD_PREFILL_CHUNK` | Captured policy selects work size; explicit overrides remain. Automatic long hybrid prefill matches all 19 fixed-size responses through cached/SSD restart. | No open default-selection gate. |
| `MLX_BUN_RD_CONTEXT_LIMIT` | Explicit caller constraint; fit estimates remain advisory. | Benchmark control, not a speed candidate. |
| `MLX_BUN_TOKEN_MASK` | Exact structured-output responses; previous serving timing is inconclusive. | Controlled B1/B4 comparison if the mask implementation changes. |
| `MLX_BUN_PREFILL_TAIL_SPLIT` | Existing policy explains recorded RTN4 ordinary/MTP trajectory differences. | Changing that policy requires a separate numerical/quality comparison. |

#### Closed candidates

Do not re-open without new evidence of the kind named in the row's reopen
condition.

- Device f32 code LUT for variant-6 decode: slower at M=1 for every bit width (`lut6-*.json`).
- Constant-address-space int16 codebook table: 0.802 vs 0.331 ms reduce; nearly 2x complete MLP on MLX 0.32.2 (`trellis-codebook*`, `trellis-constant-*`).
- Device/threadgroup fp16 code tables at M=1/4: lose; threadgroup table retained only for M3/4 k3 scatter inside variant 13.
- Integer y-mad final-sum rewrite: exact, no useful gain; readable expression kept.
- Shared activation loads across 2/4/8 gate/up rows per SIMD group: loses at k3 M=1.
- Row-loop unrolling of the aligned 3-bit scatter: no material gain.
- Larger fused prefill tiles at M=128/512 (40 geometries): all exact, none beats expansion plus native matmul.
- Contiguous packed reads with transposed threadgroup writes and threadgroup padding: slower; not retained.
- Variant 9 unrestricted deferred expansion and unrestricted async submission: fail the saved-agent pressure gate (Metal insufficient memory); superseded by the bounded 75% policy.
- M≤8 packed/expanded crossover: MLP win but changes output bytes; Lab, not in production dispatch.
- fp16 storage as a Steel GEMM throughput shortcut: source audit shows float accumulation regardless; rejected.
- Fused GDN convolution/SiLU/copied tail (R8): flat full-model timing; unpromoted.
- GDN compiled fixed-length recurrence and fused recurrence/RMSNorm/gate kernels (R9): gains too small; not integrated.
- Fixed-shape CompiledFunction over 16 SSM groups: -0.062%/-0.202%; no integration.
- Fixed-input custom-kernel proxies, 64 per-layer cached graphs (RTN4 fails identity) and whole-model graph (slower): no production tracer manipulation.
- Affine QMV layout screen (rows per SIMD group / groups per threadgroup): no accepted whole-model gain.
- Shared-M affine kernels and `MLX_BUN_AFFINE_SHARED_M` (4-bit M3..8, compact 3/8-bit, nonfast large projections): superseded by MLX 0.32.2 `qmv_wide`; kernel and flag removed, frozen source controls retain them.
- Shape-specific compiled-call cache around shared-affine kernels: HTTP gains shrink to flat; not integrated.
- Broader cross-model 4-bit shared-affine prototype: MiniCPM/Llama regress; float16 head-only B8 variant <1% on 3B; not integrated.
- Fused affine gate/up/SwiGLU: only M=1 wins in isolation; full-forward gain too small.
- Residual-add/RMSNorm fused kernel: M1 slightly slower, M4/8 flat; not integrated.
- Multimodal RoPE shared angles/direct strides: M128 slightly slower, M512 flat; closed.
- Metal launch-configuration cache: Qwen flat, MiniCPM fails the serving response gate (cause unresolved); closed.
- Untouched-finalize elision in the Metal backend: -0.069%/+0.108%; closed without integration.
- MLX submission/traversal/sync settings for Qwen: no compelling setting (0.94% traversal gain matched the 0.92% default drift); Llama 25/25 remains diagnostic, unintegrated.
- `MLX_METAL_FAST_SYNCH=1`: stalls the installed library's large bf16 three-stream case; not attributed to any prototype.
- Top-p inverse-permutation removal (pure MLX and fused Metal): Qwen +0.183% complete; Llama -0.4%; no production sampler change.
- Grouped greedy verify readback (concatenated and evalAll): ≤0.33% gain, JSON regression; closed.
- Direct packed-key TurboQuant attention: exact, 6–19% slower than joint decode plus native SDPA; closed.
- Fused inverse-Hadamard one-row layout inside the joint decoder: +12.76..+24.67% slower; only the row-grouped N≥8192 variant retained.
- Dense register-resident attention (vLLM-Metal port): loses timing; Steel D256 fails one 512-token KL screen; Lab, unintegrated.
- KV append whole-cache-copy hypothesis: rejected by native/HTTP census (one-row copies); no append kernel.
- mmap file-backed weight loader (immutable, managed, lazy, prefault variants): warm flat-to-slower, cold worse in 5/6; closed as a performance candidate.
- Staged-body strict-fill prototype (skip the discarded in-flight sample): flat; closed.
- Multi-query affine attention inside strict append: recurrent state diverges at layer 4. Superseded by the qualified one-token attention calculation within shared projection appends; KV4/KV8 now pass state and serving gates.
- Cross-entropy block-alignment partition: no wired model reaches a misaligned partition; closed without integration.
- Streamed-expert threadgroup geometry: bf16 timing bimodal in all three library arms; no geometry default retained.
- Proc-pid-rusage FFI collector: 0.0013 ms vs 1.09 ms per read, collector only; existing reports keep the ps collector.
- Video tq3-mini polar format: operation wins on synthetic matrices; no loader, kernel or quality evidence; not adopted.
