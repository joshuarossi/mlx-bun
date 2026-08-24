---
status: active
axis: ON
canonical-for: decode-speed-levers
plan-anchor: "Phase 6 — Speed: change what gets computed `[~]`"
last-verified: 2026-08-23
---

# Decode-speed program — the ranked path to faster tokens

This is the only doc that ranks open decode-speed levers. It also carries the
**port ledger vs oMLX** (§6, folded in from `docs/design/decode-speed-program.md` on
2026-08-23). Status and run logs live in PLAN.md (Phase 6 and the serve
h2h phases); the architecture the levers plug into is
`unified-engine-frontier-plan.md`; curated numbers are
`docs/reference/benchmarks.md`. Every lever here has evidence, an expected
win, and a trigger; pick them up in order. No number below is new — each
cites where it was measured.

## 1. The physics and the baseline

Decode tok/s ≈ bandwidth ÷ bytes-touched-per-token. The mode-matrix benchmark
(`scripts/bench-matrix.ts modes`) confirmed what the roofline work predicted:
the L1 decode path sits at the memory-bandwidth wall on every dedicated model
at short context, so tier levers cannot buy single-stream decode speed
(PLAN.md "Decision: naked default = --l1": decode parity with mlx-lm on every
model; no output-changing lever beat it). Faster therefore means one of four
physical moves:

1. read the weight bytes ONCE for several tokens — speculation, batching;
2. read FEWER bytes — quantization quality-per-bit;
3. SKIP reads — caching (prefill/TTFT side, already leadership territory);
4. shave the non-GPU residue — host overhead, dispatch count, residency.

One correction the bandwidth framing missed (2026-07-04, CPM5): small
ELEMENTWISE ops are dispatch-bound, not bandwidth-bound. An unfused swiglu
(`sigmoid` + `mul` + `mul`, 3 kernels/layer × 24) cost ~5% of decode; porting
mlx-lm's `@mx.compile` swiglu (`compiledSwiglu`, now the default in
`src/model/minicpm5.ts`, `qwen3.ts`, `qwen3_5.ts`, `qwen3-moe.ts`,
`universal/dense.ts`; `MLX_BUN_COMPILED_SWIGLU=0` kills it) moved CPM5 to
parity with mlx-lm, bit-identical tokens. The win was per-dispatch host +
encode tax, which is why CompiledDecode was 0% there (it replays the same
unfused graph). The bandwidth wall holds for the *matmul* path; elementwise
fusion is the exception.

## 2. The levers, ranked

### Lever 1 — speculative decoding: the only wall-breaker  [expected 1.1–3× where drafts land]

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
| `mtp` | `qwen-mtp-source.ts`, `glm52-mtp-source.ts` — the target's own native multi-token head | landed; GLM-5.2 MTP on by default (`--mtp on|off`), Qwen3.8 MTP unblocked in v0.2.0 | Qwen3.8 TQ artifacts: 71–76% accept in the harness (STATUS.md); an HTTP-lane Qwen-MTP slice bug is an open PLAN box |
| `ngram` | `ngram-source.ts` — model-free prompt lookup, lossless | landed | no drafter weights; drafts copied from the request's own context (`--ngram-max/--ngram-min`) |

What remains is drafters worth running, in this order:

- **1a. Native MTP as the default speed lever on the 27B targets** — the
  only drafter with zero extra weight reads. Trigger: close the HTTP-lane
  slice bug, then a quiet-box paired A/B (spec vs `--mtp off`) on the
  Qwen3.8 artifacts; promote to the h2h table.
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

### Lever 2 — mlx bump: narrow MoE / spec-decode wins, not a general decode lever  [main-only, from source]

We are pinned to the oracle stack in PLAN.md "Reference environment" (mlx
0.31.2). The decode-relevant upstream work is on mlx `main`, unreleased; a
bump means building mlx + mlx-c from source AND running the oracles (mlx-lm /
optiq, which target the released mlx) on an unvalidated combination. Oracle
validity is the real cost — golden regen is the verification, not the gate.
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

What `main` does NOT have:
[ml-explore/mlx#3553](https://github.com/ml-explore/mlx/issues/3553) is an
OPEN issue, not a fix, and `qmv_wide` is not wired into the gather path —
there is no `gather_qmm` M=1 fast path upstream; the MoE M=1 compute-bound
gap is ours to close (the shelved moe-qmv kernel; roofline #2).
[ml-explore/mlx#3120](https://github.com/ml-explore/mlx/pull/3120) (split-K
small-M quant matmul) predates the 0.31.2 tag — probably already ours;
confirm before counting it.

Sequence: land this WITH lever 1, where #3485 + #3764 both pay off — not as a
standalone "faster decode" move it isn't.

### Lever 3 — quantization quality-per-bit: fewer bytes IS more tok/s  [expected ~10–15% per half-bit]

Decode scales roughly linearly with weight bytes, so every quality-per-bit
program is a decode program wearing quality clothes: the sensitivity-driven
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

**1a native MTP quiet-box A/B → 2 mlx bump + re-bench (with the spec verify
in hand) → 3 quiet-box numbers for the TQ artifacts → 1b cheaper assistant
head → 1c DSpark flip** (as its phases land, Josh-gated runs), with §4 host
residuals as filler between blocks. Re-run `scripts/bench-matrix.ts modes`
(e4b + 12B, short/2k/4k) after each lever lands — it is this program's
scoreboard; promote clean-machine rows to `docs/reference/benchmarks.md`.

## 4. What this program is NOT about

TTFT, prefill, and throughput are tracked elsewhere: prompt cache + SSD tier
(`docs/design/kv-cache.md`), batching aggregate (`docs/design/batching.md`),
prefill vs mlx-lm (PLAN.md "Prefill vs mlx-lm — paired re-measurement",
"Qwen3.8 prefill — measurement + analysis", and the prompt-to-response
attribution matrix in STATUS.md). This doc is about the decode number itself.

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
