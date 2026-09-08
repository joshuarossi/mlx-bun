---
status: active
axis: ON
canonical-for: decode-speed-levers
plan-anchor: "Phase 6 — Speed: change what gets computed `[~]`"
last-verified: 2026-09-07
---

# Inference performance program

This is the canonical performance research plan. The current priority is the
Qwen3.8-27B program in section 7, covering quants, the complete execution graph,
custom kernels, deterministic token replay, prefill, decode, and serving.
Sections 1–6 retain the earlier cross-model research and the
**port ledger vs oMLX** (§6, folded in from `docs/design/decode-speed-program.md` on
2026-08-23). Status and run logs live in PLAN.md (Phase 6 and the serve
h2h phases); the architecture the levers plug into is
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
(PLAN.md "Decision: naked default = --l1": decode parity with mlx-lm on every
model; no output-changing lever beat it). Faster therefore means one of five
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
- **Per-slot drafting under batching** — the composition-matrix row in the
  architecture doc; a mounted draft routes every request serial today.

### Lever 2 — native MLX updates against the pinned control

We are pinned to the oracle stack in PLAN.md "Reference environment" (mlx
0.31.2). The July audit below identified upstream changes absent from that
pin. Recheck current releases and the native libraries actually loaded before
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
The deliverable is a frontier of configurations for the M4 Pro, with a reason
to keep or reject every investigated method. A smaller artifact, a faster
microkernel, and a higher draft acceptance rate are intermediate results.
Each must survive the full application measurement.

Josh narrowed the remaining hardware scope to the M4 Pro on 2026-09-06.
M1 Max runs are not required for this campaign. Existing M1 Max evidence
remains historical; the final report format still supports other machines.

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
| R0 | Exact artifact and execution controls for performance | Freeze `673b43f` plus the integrated local diff; matched token IDs, active graph/method/quant, raw timings and actual memory. Use relevant numerical and lifetime gates; the wider refactor acceptance program is separate. Resolve the M4 delta golden cell before L1 promotion. |
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
| R16 | MLX graph and loop | Use model-owned graph/method bindings for compiled regions, stable buffers/shapes, graph replay, cache donation, allocation removal, bounded device-side chaining and host/GPU overlap. Measure session/lease/readback costs without adding per-op evals. Preserve cancellation and ownership gates. |
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
between cells, and repeat finalists in a separate session on the M4 Pro.

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

The scope also includes every owned kernel and native operation used by the
project's other model paths. Maintain an inventory of dispatch sites, generated
specializations, dtype/shape/layout eligibility, callers, reference behavior,
available workloads and measurements. Cover attention, projections, recurrent
layers, embeddings, normalization, activation, sampling, masks, cache codecs,
media paths and streamed experts, including graph construction and host work.
Each inventory row needs an explicit result; a Qwen-only trace cannot close
an operation used elsewhere. Keep unavailable-model or hardware cells visible.
Run the final comparison on the M4 Pro. Pin source, runtime/library
versions, artifacts, request settings and
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

The MTP-prefix integration, now included in the PR #47 feature branch, permits Qwen uniform KV4 with start=0
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
follows after inference exits. The completed retry is recorded later in this section.
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

### 7.8 Execution progress and next measurements

Use the integrated memory safeguards and relevant numerical controls in
section 7.1, then measure the expensive computation. The existing benchmark
accepts an exact local artifact and can print its
commands without loading a model. The first prepared jobs are the affine
flagship on mlx-bun serial versus mlx-lm, followed by packed Q3 on mlx-bun
serial. Start at 4k context; widen only after the measured memory row.
The commands and preparation mode are documented in
[benchmarks.md](../reference/benchmarks.md#running-the-benchmark).

The harness now keeps all five decode samples, uses reproducible nonces with
`--workload-seed`, pins thinking mode across arms, and saves request bodies,
counts, finish reasons, errors and wall times in a JSON companion. It rejects
missing token usage instead of counting SSE chunks as tokens. Each block
still needs an explicit AB/BA order and a distinct output path; one harness
pass is a screening block, not the full paired-session confidence interval.
Identical decoded text and prompt counts remain a smoke check; engine logit
and token-ID gates provide the stronger correctness evidence.

The matched-prefill MTP control exposed a separate ordinary-generation
latency cost: the serial loop constructs the next decode step before yielding
token zero. A runtime-only source transform yields the first sampled token
before that construction, retaining the later pipeline and excluding fill,
grammar and resumed generation. Its initial packed-model pair preserves every
token ID, live cache state, cache key, usage count and finish reason at raw
prompt lengths 6/128/512. Native first-token latency improves while complete
generation time is approximately flat. Six lifecycle tests, the 26 existing
fill-loop tests and 15 binding tests pass with the prototype. One binding
cancellation expectation needs the new event order: token zero may arrive
before cancellation triggered inside the subsequent forward; no token arrives
after cancellation. Consumer return at that first yield leaves a correctly
described prompt-only cache. Those screens changed only the runtime-loaded module.

The first serial HTTP pair preserves all seven warm/measured responses but
does not reproduce the native TTFT improvement. Client-visible output can lag
token zero through detokenizer buffering. A separate sink observer confirms
that these raw prompts first generate bare-space token 220, which emits no
event, followed by token 17 (`2`), which emits content and yields for network
progress. Both arms preserve that sequence; earlier delivery of the hidden
space cannot improve client TTFT. Keep this negative result and test chat
fixtures before attributing a serving win or integrating the prototype.
Both screens keep sources fixed and exit cleanly. Evidence:
`first-yield-native-screen{,-review}.json`, `first-yield-http-screen.json`,
`first-yield-http-observe.json` and its per-server `*.sink.json` records,
`first-yield-smoke-candidate-v2.txt`, `first-yield-existing-loop-tests.txt` and
`first-yield-binding-order-tests.txt` in the campaign report directory.

The subsequent three-fixture chat HTTP screen preserves all seven paired
responses and improves first visible output on each measured fixture, with
approximately flat complete-request time. Evidence:
`first-yield-chat-http-screen{,-review}.json`. A simplified version captures
the current sample index before yielding and increments the normal generated
count immediately, avoiding a second stats counter. Its control passes eight
tests and the candidate passes 49 lifecycle, binding and fill-loop tests,
including two- and three-token budgets. The first budget test expected an
explicit native `length` reason, but the incumbent leaves budget completion
implicit; the corrected assertion preserves that contract. Evidence:
`first-yield-v2-{control-tests,tests,tests-corrected}.txt`. The simplified
prototype then completes six fresh-process native pairs. All 36 warm/measured
token, live-state, cache-key and usage comparisons agree; every measured pair
improves first-token latency at all three prompt lengths. Complete generation
time is approximately flat. All 12 children exit cleanly with fixed sources
and the same remaining active allocation after explicit cleanup. Evidence:
`first-yield-native-v2-repeat{,-review}.json`. Six chat server pairs then
complete all 84 requests with 42 exact response/count/finish comparisons.
Every measured pair improves first visible output, with approximately flat
complete-request time. The sampled native audit also preserves token IDs,
requested log probabilities and live cache state across two seeds and two
prompt lengths, with penalties enabled. Both runs keep sources fixed and
exit cleanly. Evidence: `first-yield-chat-http-v2-repeat{,-review}.json` and
`first-yield-sampled-native.json`. Other artifacts and cached/pressure
acceptance remain, including first-token consumer return and follow-up reuse.

The serial change is now integrated behind `MLX_BUN_EARLY_FIRST_TOKEN=1`,
default off. Its scheduling decision comes from the binding's captured
runtime; request and execution interfaces are unchanged. Eight permanent
binding tests cover both settings, captured-policy isolation, short budgets,
early return, cancellation and initial EOS. The focused tests and enabled-fill
regression pass, as do all three typechecks, hygiene and the complete
model-free suite: 1,831 pass, 10 skip, zero failures. The first cancellation
test incorrectly expected final stats after an exception; the corrected test
preserves the existing null-stats contract for aborted runs. Orderly consumer
return still reports the emitted token and exact cache key. Real-model and
HTTP flag comparisons follow the prototype measurements before this thread
can close. Evidence: `first-yield-production-unit{,-v2}.txt`,
`first-yield-production-fill-enabled.txt`, `first-yield-production-typecheck.txt`,
`first-yield-production-hygiene.txt` and `first-yield-production-model-free.txt`.
The integrated packed-model native pair preserves all six warm/measured
token/state/key/usage comparisons. Its serial HTTP pair completes 14 responses
with all seven paired text/count/finish checks exact. Both reproduce earlier
first-token delivery and keep sources fixed with clean child exits. A slow
HTTP warmup is retained; these integration screens do not replace the six
balanced prototype pairs for timing evidence. Evidence:
`first-yield-production-native-r6{,-review}.json` and
`first-yield-production-http-r6{,-review}.json`. Closed source-transform and
duplicate test helpers are removed; permanent tests and raw reports remain.
The first integrated RTN4 native pair also preserves all six token/state/key
comparisons. Its apparent large complete-time difference is not accepted as
a speed gain: step intervals change substantially within the control process,
system swap grows and final preflight records substantial Chrome CPU use.
Keep this correctness result and repeat timing before attribution. Evidence:
`first-yield-production-native-rtn4{,-review}.json` and per-token arrival times
in the same report. No unrelated application was stopped.

The continuous scheduler has its own first-output boundary: an empty group
finishes preparation and emits token zero, then advances decode before its
event-loop yield. A separate prototype adds a yield only when preparation
leaves exactly one active row and no queued arrivals. It preserves grouped
short admissions and stops immediately if the group closes during that await.
Nine scheduling tests pass for each control/candidate arm; an actual
continuous HTTP screen must verify wire placement and client arrival time.
Evidence: `first-prepare-scheduler-{control,candidate}.txt` and the frozen
`first-prepare-http-screen-plan.json` in the campaign report directory.

Six subsequent AB/BA blocks complete on the M4 Pro with 12 clean server exits,
84 responses and 42 exact paired responses, including counts, finish reasons
and cache usage. The actual continuous lane and submitted-row increment are
checked for every request. Median paired TTFT changes are -7.66% for code,
-7.90% for explanation and -5.63% for JSON, about 74–77 ms earlier. Complete
request time changes by +0.15%, +0.04% and +0.08%, respectively. One code pair
has 2.20% worse TTFT and remains in the report. The machine begins with Chrome
CPU activity and existing swap, so these are diagnostic measurements. Chrome
is unrelated background load; a Bun HTTP client sends requests directly to
the server without the chat UI. Source hashes remain fixed. Evidence is
`first-prepare-http-repeat{,-review}.json`; scheduler lifecycle and broader
request gates remain before integration.

The continuous option is now integrated under `MLX_BUN_EARLY_FIRST_TOKEN`,
default off. The MLX backend reads its captured runtime and passes a boolean
to the generic scheduler. No request or execution-contract field is added.
After the early yield, the scheduler restarts its policy loop so new arrivals,
cancelled queued work, admission holds and shutdown are observed before the
next step. Eight added unit cases cover those transitions, short-admission
grouping, an existing active row and cleanup on a failed yield. All 1,839
model-free tests, the three typechecks and hygiene pass. Integrated real HTTP,
cache, pressure and quiet gates remain. The integrated native option also
passes four sampled cases per artifact on packed Q3 and RTN4, preserving all
32 token IDs, requested log probabilities, cache keys, live KV/recurrent state
and usage. Each arm returns to the same measured native allocation baseline
after disposal. These are correctness checks, not repeated timing claims.
Evidence is `first-prepare-production-{unit,model-free,typecheck,hygiene}.txt`
and `first-yield-production-sampled-{r6,rtn4}.json`.

The first integrated continuous HTTP attempt is retained as a setup failure.
Its driver set the new option after MLX imports had captured the runtime, so
the candidate's execution counter remained zero and rejected the run. The
corrected driver sets the flag in the child environment before imports. Both
arms then execute the same instrumented production source, with seven early
yields in the candidate and zero in the control. All seven paired responses
and usage/finish checks pass, with fixed source and clean exits. TTFT improves
by 68–90 ms across the three measured fixtures; this one-block integration
check does not replace the six prototype timing pairs. Evidence is
`first-prepare-production-http-r6-v2{,-review}.json`; the original unsuffixed
report preserves the failed path-coverage check.

Nine packed-Q3 native cache-lifecycle pairs also pass. At prompt lengths
6/128/512, each arm either returns after one token, returns after two, or
aborts after one, then reuses its own borrowed cache for a 16-token follow-up.
An early first-token return/abort covers the prompt alone; the incumbent has
already fed token zero. Clean-return cache keys reflect those exact positions,
and an aborted generation retains the existing null-stats contract. A
one-token follow-up suffix with ordinary tail splitting gives matched M=1
forwards for any missing emitted token. All subsequent tokens, requested log
probabilities, final live cache states and cache keys match. Both processes
return to 16,390 native active bytes after disposal, without forced GC, and
the source stays fixed. This proves the covered native reuse transitions;
HTTP cache/SSD pressure and broader suffix shapes remain. Evidence is
`first-yield-production-cache-r6.json`. The same nine pairs also pass on RTN4,
including every follow-up token, requested log probability, cache key and live
state. Both RTN4 arms return to six native active bytes after disposal. Its
separate evidence is `first-yield-production-cache-rtn4.json`.

The broader native suffix screen completes 110 follow-ups across both Qwen
quants at suffix lengths 1/2/3/4/5/8/31/127/511/512/513. It does not pass
universal identity. After returning at token one, the early arm's prompt-only
cache makes the next prefill one token longer. Seven packed and six RTN4
cases change log probabilities or live state; two packed cases and one RTN4
case also change emitted IDs. Every two-token-return case remains exact.
Feeding the missing emitted token separately at M=1 restores exact stopped
state and all 22 aligned follow-ups, including requested log probabilities
and cache keys. Both arms return to their original active-allocation baselines.
This identifies a prefill-shape effect, not a seed mismatch or a corrupted
snapshot. Keep the option experimental; reconciling the first-token cache
boundary needs an implementation and performance gate before default
promotion. Evidence is `first-yield-suffix-qwen{,-review}.json`. The preceding
Llama smoke also records a natural 512-token suffix state/logprob difference.

The integrated option also passes the saved seven-request agent-boundary/SSD
gate in serial and actual continuous serving on the M4 Pro 24 GB. The first
six one-token budgets retain their original path; each lane's counter proves
the new option runs once on the final 512-token request. All 14 paired choices
and complete usage records match. The longest prompt has 14,465 tokens and
reuses the same 12,953-token prefix in every arm. All four final flushes report
14 durable entries, no pending/missing/failed snapshots, and a longest durable
prefix of 14,976 tokens. Sources stay fixed and all servers exit cleanly.
These non-streaming responses establish the covered memory/cache lifecycle,
not a TTFT result or an agent task success. Broader suffix shapes remain.
Evidence is
`first-token-production-long-{serial,continuous}{,-review}.json`.

Actual streaming HTTP cancellation and arrival checks now pass 120 requests
across eight Qwen servers, covering packed Q3 and RTN4, serial and continuous
serving, and both option settings. Each server aborts twice at headers and
twice at first output, then completes an independent recovery request after
each abort. The server observes all 32 cancellations and settles before
consuming the 512-token budget. Every recovery response, usage record and
finish reason matches its reference. Final active MLX allocation equals the
loaded-model baseline exactly, with no cache entries or active/pending rows.
One-token budgets also remain exact. Both overlapping-arrival fixtures
observe two active rows in continuous serving, with actual admission counts;
serial serving remains serial. All sources stay fixed and servers exit
cleanly. A preceding Llama smoke adds 60 requests and 16 cancellations.
These instrumented checks establish lifecycle behavior, not speed. Concurrent
trajectories are not compared across differing admission timing and batch
shapes. Evidence is `first-token-lifecycle-{llama,qwen}{,-review}.json`.

The first actual continuous HTTP pair then completes all 14 requests with
seven exact response/count/finish comparisons and verified batched placement.
First visible output improves on all three measured chat fixtures; complete
time varies slightly. Both servers exit cleanly with fixed sources. This
remains a prototype pending balanced repeats and broader scheduling gates.
Evidence: `first-prepare-http-screen{,-review}.json`.

The first performance work after the pull uses the packed artifact's actual
k2/k3/k4 matrices. The M=1/2/3/4/5/8 screen identifies the gate/up crossover
and the down-projection bit-width asymmetry. Shared-M reduce and fused gate/up
kernels are retained as experimental variant 7 after exact matrix/MLP checks
and six balanced diagnostic A/B blocks. Variant 8 adds a balanced and aligned
3-bit down kernel; it improves the observed M=1/2/4 full-model forwards while
preserving logits, live state and subsequent-token checks. A device LUT for the existing f32
code values loses on this M4 and is recorded as a negative result. Kernel
implementation, commands and evidence live in turboquant.md's packed-kernel section.

The full packed 27B passes logits, live recurrent/KV state and subsequent-token
identity at M=1..5. Six paired native-forward blocks also retain the gain at
M=2/4, but they use a short synthetic prefix and project every output position.
They are not HTTP decode, verified MTP or strict-fill throughput measurements.
The existing exact-artifact graph/session/cache gate passes on the packed
model as well. Variant 6 remains the default.

The packed 27B strict-fill regression passes on variants 6 and 7: nonzero
assert injection, no verification events and exactly matching emitted tokens.
This is one tool-call fixture, not a held-out determinism or timing result.
The last-position-only native append sweep covers M=1/2/3/4/5/8/9/16 with
six paired blocks, preserving candidate/current logits and live state in every
cell. It retains the small-M gain and confirms the M=4/5 whole-model cost
discontinuity. Raw evidence: `reports/qwen38-rd/shared-m-append-lengths.json`.

Variant 10 now shares scatter decode across small M as well. It passes the
same exact full-model gates and improves M=2..4 against variant 8 in six
paired native blocks. Variant 9 separately moves expanded-projection
evaluation to the existing layer boundary. Its observed outputs agree, but
peak memory rises. Extending the packed crossover to M=8 is a distinct Lab
candidate with observed output differences. The packed-kernel section in
turboquant.md owns these implementations and evidence.

Integrated variant 11 adds direct tiled gate/up prefill for M=5..32, with
the same full-model logit/state gates and paired native improvement against
variant 10. The operation has no model-name dependency; its dispatch profile
currently covers the measured Qwen MLP geometry. It also improves the strict
fill fixture's complete generation time in six paired fill/no-fill blocks,
with identical emitted tokens and no verification forwards. This remains
fixture evidence, not a universal determinism proof. Evidence:
`variant11-full-model-review.json` and
`strict-fill-v11-cap32-served-eos.review.json`. Six paired raw-completion
HTTP blocks per method improve first-token and complete-request latency,
with identical output, through strict serial and continuous B=1 execution.
They cover one six-token prompt and eight/64 output tokens; concurrency and
broader-workload conclusions remain open. Evidence: `trellis-v11-http.json`
and `trellis-v11-http-review.json`.

Variant 12 adds tiled split-K down projection at M=5..8. The integrated
kernel passes exact full-model logits/state/continuation checks and improves
six native paired blocks without changing the paths outside that range.
Its implementation and sweep evidence live in turboquant.md. Serving and
combined-candidate measurements remain separate gates. The combined variant
12 versus original variant 6 now passes six raw-completion HTTP pairs for
each serial/default scheduling method, with matching text and actual token
counts at eight/64 output tokens. Source hashes stay fixed throughout all
24 bounded server processes. These one-prompt, B=1 diagnostics improve both
TTFT and complete-request latency; they do not establish concurrent load or
quiet-machine performance. Evidence: `trellis-v12-combined-http.json` and
`trellis-v12-combined-http-review.json`. The exact-input native control also
improves first-token and complete-request time in six paired blocks per
output length, with identical emitted IDs. One candidate worker escaped
through Bun with a C++ exception; its traced replay and the complete repeated
pair succeed. The original failed block is retained and excluded from timing
aggregation. This does not close the runtime reliability issue. Evidence:
`trellis-v12-combined-native-review.json`, its original/resumed reports and
`trellis-v12-native-failure-replay.json`.

The packed serving comparison now also covers four simultaneous raw
completions. Six fresh-process pairs compare variants 6 and 12, with a warm
four-request wave followed by a measured wave. Every arm observes four active
batch rows, all responses/counts/finish reasons agree, and the candidate
improves complete-wave throughput in every pair. Prompt and SSD caches are
disabled; the source snapshot stays fixed and all twelve servers exit cleanly.
These diagnostics establish that the shared small-M kernels improve actual
concurrent serving, alongside the earlier B=1 results. Mixed lengths, larger
concurrency and quiet M4 Pro acceptance remain separate gates.
Evidence: `trellis-concurrent-http.json` and
`trellis-concurrent-http-review.json`.

The operation trace led to smaller M=5..8 matrix tiles and deferred evaluation
for direct tiles. Dense expansion retains its projection boundary. The
integrated kernels pass targeted units and an old-source/new-source comparison
at ten append lengths, including logits, live cache bytes and continuation.
Six subsequent HTTP process pairs compare the previous and updated variant 12
at B=1 and eight concurrent requests. Every wave observes the expected active
row count; all paired warmup and measured responses, token counts and finish
reasons agree. Eight-request throughput improves consistently; B=1 first-token
latency improves, with a much smaller complete-request gain. All twelve servers
exit cleanly and the source hashes remain fixed. The initial explicit-seed
pilot routed through serial and is excluded from batching evidence. These
remain M4 Pro diagnostics, with variant 6 unchanged. Evidence:
`trellis-tile-integrated-forward-review.json`, `trellis-tile-http-review.json`
and `trellis-tile-seeded-serial-http-review.json` in the campaign directory.
Six old/new native process pairs also preserve all 64 emitted IDs and finish
reasons in warmup and measurement. First-token latency improves in every pair;
the complete native request improves slightly because single-row decode is
unchanged. All twelve workers complete with fixed source hashes. Evidence:
`trellis-tile-native.json` and `trellis-tile-native-review.json`.
The tile and evaluation-boundary experiments are detailed in turboquant.md.

The existing `bench-serve.ts all` suite also completes two AB/BA process pairs
for packed variants 6 and 12 with the serial arm, fixed workload seed and 192
decode tokens. Source snapshots match across all four runs. All 38 paired
recorded requests and the separate raw/chat parity probes agree; every server
exits cleanly, all SSD entries are durable, and no failed samples are dropped.
Single-request decode improves consistently at both tested contexts. Cold
prefill improves modestly; warm first-token latency varies between pairs and
sampled RSS shows no reduction. The requested context target produces 2,679
actual prompt tokens. The four-request aggregate leg is serial queue throughput,
not batching evidence. This M4 Pro diagnostic does not promote a default or
replace quiet-machine acceptance. Evidence:
`single-request-suite-packed.json` and `single-request-suite-packed-review.json`,
with all four raw suite reports in the campaign directory.

Variant 13 adds vectorized packed-weight expansion after a larger fused-tile
screen failed to beat native matmul. The operation and packing contract are
documented in turboquant.md. Focused tests cover every codebook state, circular
windows, scale dtypes, strided inputs and fallback. The integrated 12/13
comparison preserves logits, live cache bytes and continuation at five append
lengths across seven blocks, including six measured AB/BA pairs. Actual kernel
calls confirm the eligible prefills improve while M=1/8 retain their existing
path. All three typechecks, hygiene and 1,795 model-free tests pass. Evidence:
`trellis-vector-integrated-full-model-review.json` and
`trellis-vector-integrated-{unit,typecheck,hygiene,model-free}.txt` in the
campaign report directory.

Two subsequent AB/BA pairs through the existing serving suite preserve all 38
paired requests, raw/chat parity and SSD restart durability. All four servers
exit cleanly with fixed source snapshots and no failures. Cold TTFT at the
smaller prefill improves modestly, while decode, long-context TTFT and RSS are
approximately flat. Cached TTFT varies substantially, so it is not an accepted
kernel gain. An external browser/build/test burst occurs near the first pair's
transition and is retained in the observations. This result does not establish
a broad serving improvement or promote variant 13. Quiet M4 Pro acceptance
remains. Evidence: `vector-expand-suite-packed.json`,
`vector-expand-suite-packed-review.json` and
`vector-expand-suite-load-observations.json` in the campaign directory.

Six further serial HTTP AB/BA pairs isolate 6/16/128/512-token prompts with
64 generated tokens and prompt/SSD caching disabled. Each shape receives a
separate warmup; all first-shape timings are retained. Every paired response,
token count and finish reason matches across all 54 warmup/measured requests,
sources remain fixed, and all twelve servers shut down cleanly. TTFT and
complete-request time improve in every 16/128-token pair. The six-token
control and decode speed are flat; the 512-token and sampled RSS results are
less consistent. Six default-scheduler pairs repeat the improvement at
16/128 tokens, with exact responses, fixed sources and clean shutdowns.
Per-request telemetry proves scheduler admission. Existing swap usage and
background CPU activity keep both M4 Pro series diagnostic; the 512-token
effect remains less consistent. Evidence:
`trellis-vector-short-http-paired-{serial,default}.json` and the corresponding
`-review.json` files in the campaign directory. Quiet, second-machine and
pressure acceptance remain before any default promotion.

The updated affine controls now complete six alternating Bun/MLX-LM process
pairs for each flagship, compact and RTN4 artifact. They use the same six raw
prompt IDs, 64 output tokens, tokenizer/model EOS handling, production wiring
decisions and fresh-cache cleanup. Every pair emits identical IDs. Complete
native request time is close, with a small median Bun advantage; MLX-LM has
slightly lower first-token latency. These diagnostic controls establish no
new kernel win or HTTP conclusion. All 36 workers finish and the source
snapshot stays fixed. Evidence: `native-affine-paired.json` and
`native-affine-paired-review.json` in the campaign report directory.

The shared grammar bitmask candidate compares host expansion, direct Metal,
compiled Metal and XGrammar's compiled MLX bitmap-table approach. The compiled
Metal operation preserves the additive mask's bytes for bf16/f16/f32,
strided inputs, missing words, signed zero and nonfinite values. Its owned
host snapshot survives matcher mutation before lazy evaluation. Repeated
calls release their arrays after stream synchronization. Complete greedy,
sampled and logprob-enabled sampling retains identical selected tokens and
logprob bytes across changing masks at three vocabulary sizes, and improves
eight paired blocks against the actual host loop. An earlier probe used a
slower host callback expansion and is excluded from performance evidence.
Grammar integration is opt-in pending actual serving measurements. Evidence:
`token-mask-probe.json`, `token-bitmask-unit.txt` and
`token-bitmask-grammar-metal.txt`, plus `token-mask-sampling.json` and
`token-mask-sampling-review.json` in the report directory.

The first dense attention prototype adapts vLLM-Metal's register-resident
online softmax. It reduces temporary memory but loses the timing screen.
Instantiating pinned MLX Steel attention at head dimension 256 is faster on
some self-attention shapes, while the long-K/short-Q suffix case remains
slower. Tiling must follow both lengths and the device's workspace limit.
This changes numerics relative to the current unfused bf16 path and stays
Lab pending model and task-quality checks. Evidence:
`steel-attention-tune-manifest.json` and its per-tile reports. The initial
probe's small-head error metrics used physical output order; the corrected
contiguous readback agrees with the pinned oracle and CPU reference in
`attention-cpu-check.json` and `attention-oracle-check.json`.
The full packed-model Steel test is flat at 128/512 prompt tokens; one
512-token cell exceeds its predeclared last-logit KL screen, despite matching
the observed argmax. It has no model-level speed or quality acceptance.
Moving Q into threadgroup storage and transposing K storage did not rescue
the separate register-based prototype's timing. Evidence:
`attention-full-model-packed-128-512-review.json` and
`dense-attention-memory-tune-review.json`. Larger-context and exact-arithmetic
attention candidates remain separate experiments.

Graph export now records the existing evaluation boundaries for variants
6/8 at M=1/4/5. Small-M forward has one final evaluation boundary. M=5 has
192 projection evaluations, 64 layer evaluations and a final evaluation.
The exported graphs identify the exercised operations, including affine
projections, packed custom kernels, GDN, convolution, norms, RoPE, attention
and casts. Counts are exported operation occurrences, not GPU dispatches.
Raw graphs and the manifest are in `reports/qwen38-rd/graph-captures/`.

An attached Metal System Trace captures the warmed Bun target and its GPU
encoder intervals. The installed release MLX labels only command buffers
and encoders, so individual-kernel duration attribution remains open. The
capture covers part of prefill and decode; it is not a complete TTFT trace.
The first launch-based capture contains no target GPU work and is excluded.
Evidence: `variant8-attached.trace` and `attached-trace-summary.json` in the
same report directory. A pinned MLX source checkout supports inspection of
the actual dispatch and an isolated profiling build without changing the
oracle or installed runtime.

The isolated profiling build now records the kernel name, dispatch grid,
threadgroup geometry and pipeline limits for each submitted dispatch. A second
attached trace adds operation labels to encoder scopes. Those scopes contain
multiple operations, including zero-work views, so their GPU duration cannot
be attributed to the label's final operation. The selected Xcode counter
profile is unsupported on this M4 and exports no shader or counter samples.
Use the dispatch inventory to select isolated operation experiments while
individual GPU timing remains open. Evidence: `labelled-v8-analysis.json`,
`labelled-v8-kernels.txt` and `variant8-labelled.trace` in the report directory.

A direct device capability query exposes timestamp counters only at compute
stage boundaries on this M4 Pro. Dispatch-level sampling is unsupported.
The isolated pinned runtime now samples each operation in a separate encoder,
reserving two slots in a shared counter buffer and resolving them once per
completed command buffer. A per-operation allocation first exhausted Metal's
sample-buffer resources; a larger pool exceeded its documented-in-error size
limit. Both failed attempts are retained, and the final pool fits that limit.
The installed native library and Python oracle are unchanged.

Calibration compares the release library, the isolated build without
segmentation, segmentation alone, and counters. At B=1 and append lengths
1/4/8/128 from a 32-token prefix, every arm preserves logits, live cache bytes
and one continuation across one warmup and three measured forwards. The
instrumented full-forward overhead is small in this screen. All recorded
timestamps are valid, and sampled CPU/GPU clock pairs agree. These are
operation-encoder intervals: operations with multiple dispatches stay grouped,
intervals can overlap and include waits, and their sum is not GPU wall time
or critical-path attribution. The small-M trace directs further work toward
packed projections and affine matvecs; the eight-token trace exposes the
cost of the tiled prefill path. Evidence: `metal-counter-capabilities.json`,
`mlx-counter-source-manifest.json`, `mlx-counter-build.patch`,
`metal-counter-pooled-unit.stderr.txt` and
`metal-counter-calibration-review.json` in the report directory.

A separate schedule recorder now preserves MLX's normal encoder and command
buffer boundaries. It counts existing dispatches, barriers, fence waits and
temporary references, and reads command-buffer GPU start/end times in the
completion handler, following [Metal's timing contract](https://developer.apple.com/documentation/metal/mtlcommandbuffer/gpustarttime).
It rejects simultaneous operation segmentation. The first smoke test exposes
a unit mistake in the recorder: the pinned runtime's `buffer_sizes_` adds
`data_size()`, which counts dtype elements. Correct the recorder to report
that heuristic as elements and multiply by item size for temporary bytes.
The effective M4 Pro submission defaults are 50 dispatches and 50 shifted
element-count units. The setting's upstream name remains
`MLX_MAX_MB_PER_BUFFER`; it is not a literal byte ceiling. Temporary-reference
totals are also not peak resident memory.

The corrected recorder passes 45 complete generations across Llama 1B and
Qwen packed/RTN4, comparing the ordinary library, the isolated library without
telemetry and the recorder with native/raw/compiled sampler arms. Every
token, live state byte and usage record agrees. Warmed complete timings show
no clear systematic instrumentation shift in this screen; repeated overhead
calibration remains necessary for quantitative timing attribution. The
64-token packed sampling trace loses four dispatches per token with fusion,
but all three sampler arms still submit 3,905 buffers containing dispatches.
Many additional buffers contain no kernel dispatches; they may still carry
event waits or signals. Audit callers before attempting to remove them.
Command-buffer spans include internal waits, so their union is not kernel
active time or device utilization. Evidence is `mlx-schedule-source-manifest.json`,
`mlx-schedule-smoke-v2.log` and `top-p-schedule-screen{,-review}.json`.

A separate caller trace attributes 24 zero-dispatch submissions during steady
packed greedy decode to the pressure branch in MLX's `eval_impl`, reached
through `async_eval`. That branch finalizes open GPU streams before waiting
for outstanding work. All three traced generations preserve emitted IDs,
live cache bytes and usage against the calibrated recorder. Startup-only
stacks had instead reached final evaluation and synchronization, so they
could not establish the steady decode cause. The trace adds CPU logging and
is not timing evidence. These observations do not establish that an empty
dispatch list has no event work. Keep the validated recorder separate from
the caller-trace build. Evidence is `empty-submit-r6-steady-trace{,-review}.json`
and `mlx-empty-submit-steady-source-manifest.json`.

The next stock-library screen varies MLX's command-buffer submission limits,
bounded breadth-first graph traversal and optional Metal synchronization
implementation. Measure complete warmed generation, with matching token IDs,
requested log probabilities and live state, before changing native code or
retaining a setting. New-shape prefill cells are correctness screens until
their shapes are warmed in both arms. Positive cells require balanced native
and actual serial/continuous HTTP repeats, plus memory and disposal checks.
The frozen screen is `graph-schedule-screen-plan.json`.

That first screen passes all 120 generations and 27 complete arm comparisons
on Llama 1B and Qwen packed/RTN4. No packed-model decode setting has a
compelling first-pass gain. The later RTN4 timings overlap with unrelated
disburse TypeScript/Vite/Playwright jobs, including higher load and swap use.
Exclude RTN4 timing from tuning decisions and repeat it after those workers
exit; retain its exactness results. Llama's smaller-buffer observation needs
balanced repeats. Evidence is `graph-schedule-screen{,-review}.json` and
`graph-schedule-screen-contamination.json`. Retained tuning belongs at the
existing model-owned execution seams; these experiments do not establish
new global defaults.

The RTN4 rescreen completes 40 generations with nine exact arm comparisons,
including a return to the default settings at the end. The apparent 0.94%
greedy gain with traversal width 64 matches the ending default's 0.92% drift;
sampled generation is flat in both. Larger submission limits also fail to
improve both decode fixtures. No Qwen setting advances from this screen.
New-shape prefill timings remain excluded. Evidence is
`graph-schedule-rtn4-rescreen-v2{,-review}.json`.

Llama's six balanced native pairs preserve all 30 paired generations, including
requested log probabilities and live state. Reducing both submission limits
to 25 lowers complete warmed generation time by 2.44% for greedy and 2.30%
for sampled output; all six pairs improve in each cell. TTFT is effectively
flat. Peak MLX allocation falls in the measured cells, which is not a claim
about physical RAM savings. Six actual HTTP pairs per lane then preserve all
84 paired responses across 168 requests. Complete time improves by
1.86–3.02% in serial and 2.22–3.00% in continuous serving across the three
fixtures, with every pair faster. These M4 Pro results remain diagnostic.
The controls are `graph-schedule-llama-repeat{,-review}.json` and
`graph-schedule-llama-http-repeat{,-review}.json`. MLX caches these settings
at device initialization; assigning environment variables from a later
model forward would not apply the measured policy. Broader contexts,
lifecycle coverage and scoped integration remain.

A separate native prototype elides `finalize` only when the command buffer
has not been touched since the preceding commit. Access to the buffer,
encoder creation, output registration and temporary registration all make it
ineligible. This preserves event-only and completion-handler work, and leaves
explicit synchronization unchanged. The isolated build and its disabled arm
each pass 84 stream/lifetime cases against the installed library, spanning
three dtypes, two sizes, two memory limits, CPU/GPU and GPU/GPU dependencies,
view-only events and disposal before asynchronous completion. All cases
return active memory to zero. The subsequent 45 complete generations also
preserve IDs, requested log probabilities, live state and usage across the
three artifacts and both library controls. Packed generation is effectively
flat. Six subsequent RTN4 AB/BA pairs preserve all 30 paired generations but
find no reliable gain: complete greedy time changes by -0.069%, sampled by
+0.108% and warmed prefill by +0.011%. Peak MLX allocation is flat. Close the
prototype without production integration. Evidence
is `mlx-untouched-finalize-source-manifest.json` and
`untouched-finalize-stream-default{,-review}.json`, plus
`untouched-finalize-native{,-review}.json` and
`untouched-finalize-rtn4-repeat{,-review}.json`.

The separate exact traces confirm that the prototype removes the intended
submissions. For 64 packed sampled tokens, zero-dispatch buffers fall from
3,311 to 194, while all 116,164 dispatches and 3,905 buffers containing
dispatches remain. RTN4's corresponding zero-dispatch count falls from 4,083
to two; its 115,947 dispatches remain. The sampled skip counters record
3,113/4,072 omitted calls. Counts need not subtract exactly between runs
because pressure callbacks and completion timing vary. This is mechanism
evidence, not an end-to-end speed claim. Evidence is
`untouched-finalize-trace{,-review}.json`.

The optional upstream `MLX_METAL_FAST_SYNCH=1` mode stalls in the installed
library's large bf16 three-stream case under the probe's small submission
limits. A stack sample finds the host in `scheduler::wait_for_one` and a
worker in `Fence::wait`. Stop only that probe after more than 100 seconds
without progress, retain its partial results, and rerun all default-mode
cases successfully. Do not attribute this stock-library failure to the new
prototype or treat the unrun experimental-mode arms as passes. Evidence is
`untouched-finalize-stream.json`, `untouched-finalize-stream-fast1-interruption.json`
and `untouched-finalize-stream-fast1-default.sample.txt`.
The initial interruption annotation mislabeled that case as f32; the partial
report's dtype 12 identifies bf16. The corrected attribution is recorded in
`untouched-finalize-stream-fast1-failure-review.json`.

The existing GDN stage profiler has also been run at M=1/4/128/512 against
unprofiled forwards from the same prefix. Observed logits agree. Its added
stage/layer evaluations substantially inflate small-M time, so those stage
durations cannot substitute for GPU kernel attribution. Evidence:
`reports/qwen38-rd/gdn-stage-probe.json`. A fused convolution/SiLU/copied-tail
prototype matches the tested bf16/f32 outputs and live tail at B=1/2. It
requires MLX's typed sigmoid expression; a float32 rewrite changes bf16
results. The opt-in operation now passes full packed-model logits, live
state, continuation and speculative rollback checks. Its initial memory
benefit exposed an aliasing baseline: `mlx_copy` retains the source buffer.
The default path now uses a shared compact materialization operation backed
by stock MLX DynamicSlice, with gradient and compiled-execution gates.
Replacing the alias preserves all tested packed-model logits, live state,
continuation and rollback bytes. Explicit disposal still owns handle cleanup;
the copy change allows the large backing allocation to be released.
Against an independently materialized baseline, convolution fusion has
approximately flat full-model timing and similar peak memory. It remains an
unpromoted R8 experiment. Evidence: `qwen-conv-materialized-packed.json`,
`materialize-final-packed-comparison.json`, and `conv-probe-typed-sigmoid.json`.
The final stock-copy rerun is a correctness gate; concurrent CPU trace exports
exclude its diagnostic timings from performance comparisons.

GDN specialization now covers threadgroup layouts, fixed sequence lengths,
loop unrolling, compiled wrappers and typed sigmoid fusion. Correcting the
initial float32 sigmoid rewrite restores exact bf16 recurrence and state.
The subsequent shape sweep passes all 114 cells. A compiled fixed-length
candidate preserves full-model logits, live state and continuation, but its
isolated gains mostly disappear in full forwards. A separate fused recurrence,
output RMS normalization and gate kernel passes 60 isolated shape/dtype cells
and the small-M full-model checks. Its full-forward improvement is too small
to justify integration at this point. Neither candidate changes production
dispatch. Evidence: `gdn-specialization-typed.json`,
`gdn-static-full-model-review.json`, `gdn-fused-norm-probe.json` and
`gdn-fused-norm-full-model-review.json`.

The affine matvec layout screen preserves pinned MLX's reduction arithmetic
while varying output rows per SIMD group and groups per threadgroup. Actual
packed-artifact head and GDN projection weights pass exact checks with both
direct and compiled wrappers. The best isolated head cells improve only
slightly, and the small-M projection results are mixed. There is no accepted
whole-model gain. Combined projection dispatch remains a separate candidate.
Evidence: `affine-qmv-screen.json` and `affine-qmv-compiled.json`.

A second affine prototype shares packed weights and quantization metadata
across four or eight input rows, preserving MLX's dot-product and SIMD
reduction order. The corrected real-matrix screen passes all 50 cases; larger
GDN projections improve in isolation, while vocabulary-head gains are smaller.
An initial bf16 failure was large, not rounding noise: some shared-row layouts
read incorrect scale/bias values. Explicit bf16 bit expansion avoids the
observed failure without resident float32 metadata copies. Direct and compiled
bf16/f32 debug cells then agree exactly. The underlying compiler cause is not
established. Six full-model pairs preserve logits, live cache bytes and
continuation on both packed and plain RTN4 artifacts. RTN4 improves consistently
at M=4/8 with unchanged peak allocation and flat unused-shape controls. Packed
improves little; its unused M=128 control also shifts, so the smaller packed
timing difference needs an independent check. Six RTN4 HTTP process pairs
then preserve all 108 paired warmup/measured responses, token counts and
finish reasons. Every measured eight-request wave reaches eight active rows
and improves throughput; the single-request control is approximately flat.
All twelve servers exit cleanly with fixed source hashes. Evidence:
`affine-shared-m-http-rtn4-review.json`, `affine-shared-m-probe.json`,
`affine-shared-m-probe-initial.json` and
`affine-shared-m-debug-scale-bits.json`, plus
`affine-shared-m-full-model-{packed,rtn4}-review.json`.

The retained shared operation is `src/mlx/affine-shared-m.ts`, opt-in via
`MLX_BUN_AFFINE_SHARED_M=1`. Eligibility follows dtype, quantization, shape
and stream rather than a model name. It retains native MLX for unsupported
cells and during shapeless compile traces: the native CustomKernel primitive
cannot infer output shapes there. The trace context is restored on return or
exception. Shape-specific compiled calls remain eligible. Focused tests cover
strided activations and metadata, leading dimensions, shape changes and
fallbacks. A cleaned-up kernel passes another six RTN4 full-model pairs and
retains the gain. Six final production-flag HTTP pairs preserve all 156 paired
warmup/measured responses with fixed source hashes and clean server exits.
Both four- and eight-request throughput improve in every pair; the
single-request control is flat. Dispatch counters confirm M4 and M8 use the
shared operation. Broader artifacts and quiet M4 Pro gates remain. Evidence:
`affine-shared-m-production-full-model-rtn4-review.json`,
`affine-shared-m-shapeless.json`, `affine-shared-m-integrated-unit.txt` and
`affine-shared-m-integrated-http-rtn4-review.json`.

The next row-width screen passes all 112 real RTN4 matrix cases at
M=2/3/5/6/7. Six full-model pairs per width also preserve logits, live state
and continuation. M2 loses and retains native dispatch. M3 improves slightly;
M5/6/7 improve consistently without a material peak-memory increase. The large
head needs separate geometry: its M6/7 shared-row cells lose even when smaller
projections win. Wider integration therefore keeps those head cells native.
Evidence: `affine-shared-m-width-rtn4-review.json` and
`affine-shared-m-width-full-model-rtn4-review.json`.

A broader-format prototype initially fails nine of 216 arithmetic cells,
all bf16 M8 layouts with 3- or 5-bit weights. The errors are large and survive
float32 output storage. Float32 activations remove the large error but also
change the reference's typed arithmetic. Explicit bf16 input expansion plus
rounding after each typed addition preserves that arithmetic and passes all
216 dtype/bit/group-size cells. Evidence:
`affine-shared-m-all-bits-correctness-review.json`,
`affine-shared-m-all-bits-debug.json` and
`affine-shared-m-all-bits-explicit-input-correctness-review.json`.

The compact artifact supplies actual 3-bit head/MLP and 8-bit attention/GDN
matrices. All 80 real-matrix cells agree exactly, including compiled calls.
Reusing each packed load for two input rows at 3-bit and four at 8-bit wins
the retained M4/8 cells. Both compute four output rows per SIMD group, with
two SIMD groups per threadgroup. Six full-model pairs
with the prototype and another six with the cleaned production operation
preserve logits, live cache bytes and continuation; both row counts improve,
unused-shape controls stay approximately flat and peak allocation is unchanged.
The 3/8-bit implementation now lives in `src/mlx/affine-shared-quant.ts`, under
the same opt-in flag and native fallback rules. Other bit widths and group
sizes remain research-only. Evidence:
`affine-shared-m-all-bits-explicit-compact-review.json`,
`affine-shared-m-all-bits-full-model-compact-review.json` and
`affine-shared-m-broader-full-model-compact-review.json`.

The final 4-bit operation includes M3/5/6/7, retaining native M2 and the large
head at M5/6/7. Six complete-model pairs per width preserve logits, state and
continuation. Six production-flag HTTP pairs at B1/3/5/6/7 preserve all 264
paired warmup/measured responses. Each measured wave reaches the requested
active width; candidate dispatch is observed and all twelve servers exit
cleanly. Concurrent throughput improves in every pair. Single-request decode
is approximately flat. All pairs are retained, including noisier final runs:
the machine has residual swap, XProtect is active at the initial preflight,
and unrelated build/browser activity is observed after the run. This remains
a diagnostic result. Wider model coverage remains open.
Evidence: `affine-shared-m-broader-full-model-rtn4-review.json` and
`shared-affine-frontier-http-rtn4-review.json`. Current focused tests, all
three typechecks, hygiene and the complete model-free tier pass; the latter
has 1,785 passes, ten skips and no failures. Evidence:
`affine-shared-m-broader-{unit,typecheck,hygiene,model-free}.txt`.

Six final compact production-flag HTTP pairs preserve all 156 paired warmup
and measured responses, usage counts and stop reasons. Both B4 and B8 improve
in every measured pair; the median B1 control is flat, with individual noisy
outliers retained. Actual active widths and both 3/8-bit dispatches are
observed, all twelve servers exit cleanly and source hashes remain fixed.
Residual swap keeps this diagnostic. Evidence:
`shared-affine-frontier-http-compact-review.json`.

A subsequent host-overhead prototype caches shape-specific compiled calls
around these shared-affine kernels. Every weight/scale/bias/activation remains
a dynamic input, so one compiled function can serve distinct model layers.
Six compact full-model pairs retain exact logits, state and continuation;
24 compiled configurations serve all eligible projections without new traces
in measured rows. The eligible M4/8 cells improve modestly. Six subsequent
HTTP process pairs preserve all 156 paired warm/measured responses with clean
server exits and fixed source hashes. Serving gains shrink to approximately
flat at B1/4 and a small B8 difference. This does not justify integrating the
extra compiled-function cache at present. Evidence:
`affine-compiled-call-cache-full-model-compact-review.json` and
`affine-compiled-call-cache-http-compact-review.json`.

The grammar-mask operation now completes six compact HTTP process pairs at
B1/4 with shared-affine enabled in both arms and grammar jumping disabled.
All 60 paired warm/measured responses match and satisfy the frozen JSON
schema; both arms apply the mask the same number of times. Every concurrent
wave reaches four active rows, source hashes remain fixed and all servers
exit cleanly. The timing is inconclusive for promotion: residual swap and
overlapping unrelated build/browser work are recorded, the B1 median is
approximately flat and the B4 median regresses. Preserve all samples and
revisit on a controlled session. Host masking remains default. Evidence:
`grammar-mask-http-compact-review.json`.

A fused affine gate/up/SwiGLU prototype shares activation loads and replaces
the two projections plus activation dispatch. Its first version preserves
both projection outputs but fails the activation check: a float32 sigmoid
expression differs from MLX's dtype-specific expression. The corrected
kernel passes all 48 real RTN4 small-M cells, including complete MLP output.
Only M=1 benefits in that isolated screen. Restricting the full-model prototype
to M=1 preserves logits, live state and continuation across six paired blocks,
but its full-forward gain is too small to justify integration. Longer-M
forwards retain the original path. Evidence: `affine-gateup-debug.json`,
`affine-gateup-debug-typed.json`, `affine-gateup-typed.json` and
`affine-gateup-full-model-review.json`. The existing packed activation's
separate arithmetic contract needs its own audit before reusing that code
in an affine operation.

A residual-add/RMSNorm kernel preserves the native reduction topology and
the rounded residual before normalization. All 90 synthetic bf16/f16/f32
cases preserve both outputs. Six packed-model pairs at M1/4/8/128 then
preserve logits, live cache bytes and continuation, with 64 fused calls per
forward. M1 is slightly slower, M4/8 are approximately flat and M128 varies.
The complete path does not establish a compelling benefit, so this version
is not integrated. Operation samples include wrapper/evaluation costs and are
not GPU-only timestamps. Evidence: `residual-rms-screen-scalar-review.json`
and `residual-rms-full-model-packed-review.json`. Earlier driver/binding
failures occurred before timing and remain separate. Closed helpers are
removed after recording the finding.

The first real HTTP screen uses the compact artifact through bounded CLI
servers. It retains request hashes, actual usage, arrival times, cache hits,
restart durability, concurrent request completion and failures. Its cold
context leg required a Bun restart; the retried nonce changed the prompt, so
that context comparison is unmatched. The chat probe also diverged despite
equal prompt counts. Frozen chat IDs produce identical direct Bun/Python
tokens. A cold HTTP control reproduces the Python difference only in its
seedless BatchGenerator path; `seed=0` selects its serial method and matches
the direct text. Compare those execution methods separately. The Bun HTTP
sample also omits a final space, so it has no byte-identical wire-output claim.
The benchmark records failed-attempt
stderr and process status, including failures recovered by retry. This screen
is diagnostic and establishes no serving win. Evidence and exclusions:
`serving-compact-screen-0.review.json` and
`serving-primes-native-comparison.json` in the report directory.

Repeated native-throw traces identify the continuous serving crash as Metal
command-buffer out-of-memory. Bun 1.4.2 avoids it in one screen but misses
one pending SSD snapshot at its first restart boundary; neither issue is
closed. Continuous preparation and decode now share the serial memory
guard, entered after cache acquisition under the execution lease. Ownership,
refusal and guard restoration tests pass. The same context failure still
reproduces: the affine graph's transient allocations occur at evaluation,
after the per-layer construction checks. Investigate allocator residency
and snapshot retention before declaring this fixed. Evidence:
`serving-compact-bun140-throw.review.json`,
`serving-compact-bun142-throw.review.json` and
`serving-compact-shared-guard.review.json`. Source snapshots now include
untracked kernels as well as tracked changes.

The frozen compact request isolates a cache-consumption cause: after one
warm repeat transfers the exact recurrent boundary out of RAM, a third
identical prompt loses that prefix and prefills again. Stopping after two
requests also reproduces a missing SSD snapshot followed by a false-success
flush; restart cannot reuse the longer untrimmable descendant. Persisting the
boundary before transfer preserves the third request's prefix. Durability
records now remain dirty until actually covered, and already-durable records
avoid another clone. Ownership/failure and coordinator regression gates pass.
The three-request HTTP replay preserves output and cached tokens through
repeat and restart, with no missing flush. The two-request replay also writes
the consumed boundary before restart. This requires a synchronous SSD write
on the first transfer when that boundary is not already durable. The complete
compact serving diagnostic now finishes context repeats, SSD flush/restart
and four concurrent streams without a recorded failure. One diagnostic pass
does not close long-agent or repeated reliability acceptance. Evidence:
`ssd-boundary-before.json`, `ssd-boundary-two-before.json`,
`ssd-boundary-after.json`, `ssd-boundary-two-after.json`,
`ssd-boundary-tests.txt` and `serving-compact-boundary-fixed.review.json`
in the campaign report directory.

The merged packed path now passes the seven saved Pi tool-result boundaries
in separate serial and continuous server processes. Both arms use variant 12
and the same frozen requests. Each completes the longest prompt, emits the
requested 512 tokens, demotes old cache entries under pressure, and finishes
with a durable SSD flush and no pending, missing or failed snapshots. Responses
match across the two methods and the source snapshot stays fixed. The system
prompt was reconstructed once with the installed Pi package and frozen;
historical system-prompt byte identity is not established. This is a bounded
memory/integration check, not a long-running agent success claim. No returned
tools execute. Evidence: `agent-boundary-fixture.json`,
`agent-boundary-current.json` and `agent-boundary-current-review.json`.

The M4 DeltaNet fixture discrepancy is now traced to the cached reference,
not a Bun/oracle disagreement. Both implementations match gate values, output
bytes and complete recurrent state on the frozen inputs. The explicit
replay changes one older expected output and adds oracle provenance/state
hashes. The platform evidence and regeneration procedure live in
[environment.md](../reference/environment.md).

R22 now tests immutable file-backed weights through page-aligned Metal roots
and ordinary MLX tensor views. The existing external-buffer entry point is
sufficient for element-aligned tensors; each root includes the leading page
padding and the tensor view carries the offset. This resembles
[llama.cpp's mapped Metal buffer views](https://github.com/ggml-org/llama.cpp/blob/427291b5b34cd914a31b3fd3b61a68f6184f4b9f/ggml/src/ggml-metal/ggml-metal-device.m#L1999),
which align the root pointer and split oversized mappings into overlapping
views. The prototype uses no new artifact and no new production loader.
Small metadata and unsupported element alignment retain native loading.
All 32 operation cases match payload bytes and GPU add/matmul results;
pointer equality proves that the candidate aliases the file, and file hashes
stay unchanged. The Llama 1B artifact is ineligible because its large payloads
start at odd byte offsets, so that initial native/native control establishes
no candidate performance result.

The first packed 27B native pair maps 758 tensors, 11,895,111,680 payload
bytes, through 11,907,530,752 bytes of page windows. Prefix state, ten
full-forward logit/live-state/continuation cases and both generation token
sequences match. The subsequent six-pair repeat preserves all 60 full-forward
logit/state/continuation cases, every prefix state and all 12 generation
comparisons. Sources stay fixed and all 12 child processes exit cleanly.
The measured 64-token generation is 0.25% slower by median paired wall-time
ratio, with no faster pair; TTFT is approximately flat. M1 is about 0.6%
faster, while M4/8/128/512 give no consistent useful improvement. Evidence:
`mmap-weights-native-packed-paired{,-review}.json`. Readiness varies strongly
with order and file-cache state, so it has no cold-start improvement claim. Process RSS and macOS
physical-footprint accounting fall sharply because most private copied weights
become file-backed mappings. That does not shrink model bytes or establish a
corresponding reduction in total physical RAM: clean file pages and GPU
residency require separate accounting. Preserve MLX active/peak bytes, RSS,
`vmmap` output and system pressure together. Evidence:
`reports/qwen38-rd/mmap-page-window{,-pointer}-screen.json` and
`mmap-weights-native-{llama1,packed}-screen.json`.

The serial HTTP follow-up completes six fresh-server pairs with all 42
warm/measured response texts, usage counts and finish reasons exact. Sources
remain fixed and all servers exit cleanly. Warm complete-response time is
0.04% to 0.14% slower by median paired ratio; decode is 0.14% to 0.21% slower.
Median per-server peak RSS changes from 12,182,749,184 to 482,508,800 bytes.
The recorded physical-footprint summaries show the same private/file-backed
accounting change, not a smaller tensor working set. Evidence:
`mmap-weights-http-serial{,-review}.json`. Default scheduling, system-memory
pressure and cold file-cache behavior remain separate gates.

The initial prototype retains immutable roots and mapping owners for the
process, matching the existing external-array lifetime requirement. A retained
loader must also prove unload, outstanding GPU-reference ownership, repeated
model replacement, pressure behavior and HTTP performance. No default or
production lifetime change follows from this screen. A subsequent ownership
prototype stores array/root handles with each `Weights` instance and releases
them on disposal. Existing shard mappings remain mapped for the process. Three
full-artifact cycles each load 2,019 tensors and release all 13,056,265,696
active bytes. An outstanding GPU consumer survives weight disposal, produces
the exact expected output and releases the remaining 2,048 bytes on disposal;
active memory is zero before GC. Evidence:
`mmap-weights-ownership-packed{,-mapping}.json`. Three additional cycles
retain a single-input lazy negation, dispose the weights before submitting it,
and then evaluate it. Outputs remain exact; the pending view retains
39,747,584 bytes until its disposal, after which active memory returns to zero
before GC. Evidence: `mmap-weights-single-consumer-lazy{,-mapping}.json`.
The whole-tensor follow-up fails output identity on the first cycle after
owner disposal, although active memory returns to zero and the source tensor
still matches the untouched original artifact. The earlier small view did
not qualify for unary buffer donation: MLX also bounds excess backing-buffer
bytes. Thus those passing cases did not establish donation safety. Keep this
read-only loader out of production; reduce the failure on scratch data and
test writable private mappings with native lifetime ownership. Evidence:
`mmap-weights-whole-consumer-lazy.json`, its log and
`mmap-whole-consumer-source-integrity.json`. Full serving, default-scheduler
and pressure gates remain for any corrected loader.

Scratch files isolate the failure across float32/bfloat16 and aligned/offset
views. With a retained root, all read-only cases are exact and output uses a
separate buffer. After root release, all four donated read-only cases return
the original input bytes instead of the negation. Private writable mappings
preserve every output, including donation, and leave each file unchanged.
Evidence: `mmap-donation-{ro,cow}-screen.json`. The corrected prototype gives
each private page window a native payload destructor that unmaps it on the
last MLX buffer release. It uses no JavaScript destructor or new production
API. All eight scratch ownership cases preserve output and file bytes, retain
the mapping through the live consumer, and release every mapping afterward.
Three full-artifact cycles then preserve the whole-tensor lazy negation after
weight disposal. Only its 1,654,784-byte mapping survives until the pending
consumer is disposed; native mapping counts and MLX active bytes return to
zero before GC. Evidence: `mmap-managed-donation-screen.json` and
`mmap-weights-managed-whole-consumer-lazy{,-mapping}.json`. A further 64-cycle
scratch gate submits chained operations asynchronously and disposes the
input handles. Half the cycles check every output value; the others dispose
the final output before synchronization. All release every native mapping and
return MLX active memory to zero. Evidence: `mmap-managed-submitted.json`.
Six subsequent private-mapping native blocks on the M4 Pro 24 GB preserve 60 full-forward
logit/state/continuation cases and 12 8/64-token generation comparisons, with
fixed sources, clean exits and zero remaining native mapping windows. The
64-token warm generation median paired wall-time change is +0.02%; TTFT is
+0.13%. Warm full forwards at M1/4/8/128/512 have no useful consistent speed
gain. The opening-plus-first-hidden-forward phase is about 7.38 seconds slower
by median paired difference, but that observation materializes different
amounts of the model. After the hidden-only forward, native head tensors are
still lazy while mapped roots already account for their full extent. The
727,580,672-byte active-allocation difference is exactly the 715,161,600-byte
head plus 12,419,072 bytes of page padding, in all six pairs. Large changes in
RSS and `vmmap` physical-footprint accounting still do not establish how much
system RAM is saved. Child wall time includes `vmmap` inspection and is not a
performance metric. Evidence is
`mmap-weights-managed-native-repeat{,-review}.json` and
`mmap-initial-residency-attribution.json`.

A separate lazy-view control removes per-tensor evaluation and pointer checks
from loading. All 64 unsubmitted consumers and 64 submitted consumers remain
valid after releasing their weight owners, then release every mapping and
return active allocation to zero without forced GC. Its model screen preserves
ten full-forward cases and both generations, but warm 64-token generation is
+0.22% slower and the first hidden-forward phase does not improve. This rules
out retaining the lazy change on that screen; it does not isolate the cause
of the first-use cost. Evidence is
`mmap-lazy-view-ownership.json` and
`mmap-weights-lazy-managed-native-screen{,-review}.json`. Neither prototype is
integrated.

A subsequent four-arm screen measures opening the model through the first
generated token, completing all 64 tokens, then a warm 64-token generation.
Native loading, lazy private mappings, mapped pages with an OS read-ahead
hint, and mapped pages read once per page preserve all token IDs, live state
and usage, then release every mapping. On the M4 Pro 24 GB, native first-token
time from opening is 14.09 seconds; lazy mapping is 13.62 seconds, read-ahead
19.97 seconds and explicit reads 30.50 seconds. These timings include the
preparation itself. Warm generation is approximately flat. The two CPU
preparation methods lose this screen. Lazy mapping's small first-generation
gain needs balanced repeats: this is one fixed-order block with unpurged
filesystem cache. Neither a cold-storage result nor a physical-memory saving
is established. Evidence is `mmap-prefault-native-screen.json`.

The balanced follow-up rejects that apparent cold-generation gain. All six
fresh-process pairs preserve both 64-token generations, live state and usage,
with fixed sources, clean exits and all 758 mappings released. First-token
time from opening is worse in five pairs: the median paired change is +18.42%
or +2.24 seconds. Completing the first generation is +12.93% or +2.29 seconds;
warm generation is approximately flat at +0.24%. One large native outlier
remains in the report. The filesystem cache is unpurged and the machine is
not quiet, so these are diagnostic results. RSS accounting falls sharply for
file-backed pages but physical-memory savings are still unproven. Close this
loader as a performance candidate on the measured workload; no integration
or HTTP speed claim follows. Closed loader, page-preparation and ownership
helpers are removed; raw plans and evidence remain in
`mmap-cold-native-repeat{,-review}.json`.

The first full-model pair with native private mappings preserves prefix state,
all ten checked logit/live-state/continuation cases and both 8/64-token
generation sequences. Sources remain fixed; both children exit cleanly and
the mapped child releases all 758 native windows before exit. Its 64-token
wall time is approximately flat. This single pair is a correctness screen,
not a performance acceptance. Evidence:
`mmap-weights-managed-native-screen{,-review}.json`. Repeated native/HTTP,
and pressure gates still apply. A subsequent API ownership gate preserves
pending-consumer output and rematerialized source bytes after `release`,
`releaseShard` and `dispose`. It rejects a late view change and releases the
mapping after an intentional tensor-fixup failure. All native mapping counts
and MLX active bytes return to zero. Evidence:
`mmap-managed-shard-release{,-mapping}.json`.

Next: finish MTP and strict-fill request measurements after the kernel
changes, broaden their correctness and state audits, and obtain individual
kernel attribution. Continue shared GDN/convolution/affine/prefill work and
the exact-artifact controls across quants. Quiet application A/Bs, pressure
replay and quiet M4 Pro gates remain. Recheck process ownership and preflight
before each GPU run; diagnostic measurements cannot promote a default.

The native-owned managed mapping is visible to MLX allocation accounting.
Across all ten full-model rows in its paired screen, mapped peak allocation
exceeds the incumbent by exactly 12,419,072 bytes, the difference between
page-aligned root and payload bytes. The low process RSS is not evidence of
an unaccounted model in the async-scheduling threshold. Combining these
experiments still needs a separate pressure gate. Evidence:
`mmap-managed-active-accounting-review.json`.

A dedicated KV append dispatch probe covers 18 bf16 cases with four KV heads
and dimension 256, at depths 65/256/2049/2048/8193/8192. Every active prefix,
new row and retained snapshot remains exact; explicit cleanup returns MLX
active allocation to zero. With spare capacity and no retained view, each
SliceUpdate dispatches only the new-row copy. Holding an evaluated temporal
view adds a full-buffer copy; releasing it restores donation. At a 256-step
growth boundary, the pair allocates padding, concatenates old/new storage
and appends, totaling eight dispatches regardless of retained views. This
rejects the assumption that ordinary cache append always copies the full
buffer. The next gate is a real-generation census of retained views and
growth; instrumented one-shot timings do not establish a speed win. Evidence:
`kv-append-donation-probe{,-review}.json` and its native dispatch log.

A real native-generation census on the interleaved v13 artifact uses a
2,049-token synthetic prompt and 32 generated tokens. Without a prompt
snapshot, all 1,024 observed one-row K/V appends dispatch only the new-row
copy. Retaining a real `cloneKvCaches` snapshot produces 32 full-buffer copies,
one per K/V buffer, then 992 new-row-only appends. Both runs emit identical
IDs with fixed sources. This rejects a repeated whole-cache copy in the
tested native path; serving, deeper contexts and other cache types remain
separate coverage. The counter build is for attribution, not timing claims.
Explicit cleanup leaves 16,390 active bytes, so this is not a zero-allocation
claim. Evidence: `kv-append-model-trace-2049{,-review}.json` and its dispatch
log under campaign reports.

The actual HTTP census confirms the same append behavior at a verified
2,049-token text prompt. Serial and continuous servers each complete two
16-token warmups and a 32-token measured response. All three paired outputs,
counts and finish reasons match, the continuous lane is verified, and both
servers exit cleanly with fixed source. Each measured request has 1,024
one-row K/V update encoders, all writing only the new row; neither performs
a full-buffer copy for those appends. No matching update records fall outside
the request phase markers. This rejects a repeated whole-cache-copy hypothesis
for both tested HTTP lanes with prefix caching disabled. Deeper context,
retained snapshots, growth boundaries and compressed caches remain separate
regimes. The original token-array HTTP fixture was correctly rejected by the
endpoint; the corrected text fixture is encoded and hashed by the Bun
tokenizer before tracing. Evidence is
`kv-append-http-text-census{,-review}.json` and its per-server dispatch logs.

The native census also passes at an 8,193-token prompt with 32 generated
tokens. Ordinary ownership again gives 1,024 new-row-only K/V writes. A held
snapshot gives 32 whole-buffer copies followed by 992 new-row-only writes.
The two runs emit identical IDs, cover the same 8,224 cached tokens, keep
sources fixed and return to 16,390 active bytes after explicit cleanup.
Each phase also contains 480 larger prefill updates. These counts classify
`SliceUpdate` encoders only; allocation/growth and copy traffic in other
operations remain separate measurements. Evidence is
`kv-append-native-8193{,-review}.json` and its dispatch log. There is no timing
claim or new append kernel from this attribution result.

### 7.9 Project kernel coverage

The initial AST inventory contains 35 custom Metal kernel construction sites
and 355 calls into 162 distinct MLX C APIs. The API count includes allocation,
configuration and graph operations; it is not a count of native GPU kernels.
Runtime specializations still need shape, dtype, layout and stream coverage.
The complete construction-site list, source hashes and per-site evidence are
`reports/qwen38-rd/project-kernel-inventory.json` and
`project-kernel-coverage.json`. Every site remains open for broader coverage.
Variant 13 adds the 36th construction site; its source hash and evidence are
in `project-kernel-vector-expand-addendum.json` alongside that initial census.
Joint TurboQuant K/V decoding adds the 37th. A refreshed construction-site
census and its evidence are in `project-kernel-turboquant-addendum.json`.
The narrowly selected inverse-rotation kernel adds the 38th; the refreshed AST
census is `project-kernel-inverse-addendum.json`.
The MLX 0.32.2 Trellis small-prefill port adds the 39th. Its refreshed census
and gates are in `project-kernel-wide-addendum.json` and §7.12.
Consolidating the runtime removes the two old-core affine construction sites.
The current AST census has 37 sites in 15 files; frozen controls retain the
retired kernels. Evidence: `project-kernel-consolidated-census.json`.

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
| Trellis native-wide prefill | 1 | Matches MLX 0.32.2 small-prefill arithmetic on eligible GPUs. Operation, integrated R6 state/generation and six HTTP pairs per lane pass. Short-prefill TTFT improves; broader context and quiet acceptance remain. |
| Trellis vectorized expansion | 1 | Exact operation, full-model prefill and HTTP responses. Shorter serial and default-scheduler HTTP prefills improve; existing-suite timing mostly flat. Broader context, pressure and quiet M4 Pro gates remain. |
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
These are M4 Pro 24 GB diagnostics. Real Colibri serving remains unavailable;
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
control moves by +0.058%. These M4 Pro diagnostic results do not justify
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
`affine-shared-head-http-{llama1,llama3}-overlap-review.json`. These M4 Pro
diagnostics do not replace quiet-machine acceptance. Closed head-only helpers
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
The existing opt-in 4-bit kernel now selects native eight- or sixteen-value
lane arithmetic for those shapes. The flag remains off by default, and the
3/8-bit selection remains restricted to its original shapes. Large nonfast
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

The final M4 Pro bundle must record incumbent and candidate source hashes,
local diff, Bun/native/oracle versions, model hashes, flags and workload files.
Run the existing serving suite and native generation separately on the M4 Pro,
with fixed cache conditions and all paired samples retained. Its existing
numbers are historical controls until the workload and version metadata match.

### 7.10 Final benchmark and HTML comparison report

After the optimization gates close, build and run a repeatable benchmark for
the incumbent, combined finalists and retained quantizations on the M4 Pro.
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
the M4 Pro. Compare the old suite and new suite on shared cells to
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
0.04% but regresses 0.44% on JSON. Losses remain in both results. These M4 Pro
diagnostics establish no broad serving benefit worth another sampler path.
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
or memory figure changes our baseline; remaining runs stay on the M4 Pro.

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
765.00–765.05 MiB. Every pair improves. These are M4 Pro diagnostics on synthetic
resident matrices. They do not measure real model quality, RSS or whole-model
speed, and they do not replace the separate small-M QMM arithmetic. Evidence:
`polar-expand.json` and `polar-expand-repeat{,-review}.json`.

Our existing `TurboQuantKVCache.#decode` has the same unpack/gather/scale
pattern. The byte-packed KV decoder passes operation repeats, long-context
Qwen state, RTN4 and deferred D128/D512 consumer gates. It is integrated behind
an experimental opt-in, with exact operation/fallback/lifetime checks, six
HTTP pairs per R6/RTN4 quant and the first integrated 8K state gate. Allocation
diagnostics distinguish live-array ownership from Metal buffer capacity.
Six long-context three-arm blocks preserve responses and improve complete time;
the narrower inverse-rotation operation is now integrated. Its R6 and RTN4
model and repeated HTTP response gates pass on the new core. Decode improves
on both; R6 complete time improves while RTN4 complete time remains inconclusive.
Six HTTP
pairs each on MiniCPM and Gemma deferred consumers pass response identity and
improve complete time. Pressure and quiet acceptance remain. Direct packed-key
attention preserves the native arithmetic but loses
against the integrated decoder in complete codec/attention repeats; that
additional speed candidate is closed.
Its mechanism and evidence
live in turboquant.md, "Packed-value decode fusion investigation". The video's
weight format still has no production loader or kernel here.

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
`trellis-wide-prefill.ts`. Qwen supplies an explicit layout proof from its
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
native-runtime-screen{,-review}.json. These runs used the loaded M4 Pro and
are not canonical benchmark rows.

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
for bounded temporary memory. Evaluate that tradeoff on the M4 Pro's actual
eligible path. Reference numerical changes must be explained, never hidden by
loosening the oracle tolerance.
