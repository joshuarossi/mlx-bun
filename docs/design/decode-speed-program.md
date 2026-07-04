# Decode-speed program — the ranked path to faster tokens

Status: PLANNED (2026-07-04). The single-stream decode roadmap, written
down after the mode-matrix benchmark (scripts/bench-modes.ts) confirmed
what the roofline work predicted: **the baseline decode path has no waste
left** — e4b/cpm5/12B sit at the memory-bandwidth wall in every tier, so
tier levers can't buy short-context decode speed. Faster means one of
four physical moves. Each lever below has evidence, an expected win, and
a trigger; pick them up in order.

The physics: decode tok/s ≈ bandwidth ÷ bytes-touched-per-token
(M4 Pro ~273 GB/s). To go faster: read the bytes ONCE for several tokens
(speculation, batching), read FEWER bytes (quantization), SKIP reads
(caching), or shave the non-GPU residue (host overhead). TTFT/throughput
are already leadership territory (caches 16×/8.7× second-turn TTFT,
batching 12× TTFT + 2.1× aggregate under load, 2–5× startup vs the
Python stacks) — this program is about the decode number itself.

## The levers, ranked

### 1. Speculative decoding — the only wall-breaker  [expected 1.1–3×]

One target forward verifies γ drafts + a bonus: the weight read amortizes
over up-to-γ+1 tokens. The serve loop, verify math (L1: 48/48 vs mlx-lm),
grammar composition, and `usage.speculation` telemetry ALL landed
2026-07-03; what remains is drafters worth running:

- **1a. AssistantSource (build next)** — wrap the optiq KV-borrowing
  gemma assistant drafter (`src/spec/drafter.ts`, bit-exact vs optiq's
  spec_generate) as a `DraftSource` behind the SAME `--draft-model` flag
  (parity-plan §7.9 dispatch-by-artifact). Artifacts downloaded for e4b +
  12B. Measured today: **12B γ=1 ≈ 1.09×** with this deliberately heavy
  drafter (docs/design/spec-decode-larger-targets.md). L2 oracle exists.
- **1b. Cheaper drafter head** — the 262k tied-embedding argmax every
  draft step dominates γ≥2 cost; capping/approximating it extends the win
  past γ=1 (same doc, "remaining levers").
- **1d. Grammar-aware speculation (Josh's insight, 2026-07-04)** — the
  grammar mask collapses the drafting problem on structured output:
  (i) **jump-forward** — when the mask admits exactly ONE token
  (structural JSON runs), emit it with NO forward at all and fold it into
  the next verify window as a pre-accepted draft (zero-cost tokens,
  20–40% of dense-schema output); (ii) **constrained drafting** — mask
  the drafter too (matcher `rollBack` on rejection, the flagged
  MLX_BUN_SPEC_GRAMMAR_DRAFT lever): our own matrix measured acceptance
  DROP 51%→29% under grammar with a blind drafter — constrained drafting
  flips that to ~1.0 on structural spans; (iii) **grammar-pruned draft
  TREES** — a DSpark token tree's branching factor collapses under a
  tight mask, concentrating the budget on content positions
  (XGrammar-2's `traverse_draft_tree`, the U2 trigger in
  structured-output.md). Agent output is majority-structural: this turns
  speculation near-deterministic exactly where agents spend tokens.
- **1c. DSpark (THE goal drafter)** — DFlash KV-injection, architecture
  verified (overfit τ=3.24, paper-range). Blockers are research, not
  serve wiring: 27B/12B retarget (regen+train, Josh's shell), data scale
  (thousands of on-distribution generations vs 160), draft-loop
  tightening. At τ≈3 on the 27B agent workload: **~15 → ~35–45 tok/s**
  (docs/investigations/dspark-handoff.md). Slots in as `DflashSource`,
  L3/KL-gated.

### 2. mlx bump — narrow 26B / spec-decode wins, NOT a general decode lever  [main-only, from-source]

Pinned at mlx 0.31.2 — still the newest *released* mlx (and newest on
PyPI). All the decode-relevant work is UNRELEASED on mlx `main`; there is
no nightly wheel, so a bump means building mlx + mlx-c from source AND
running the oracle (mlx-lm / optiq — no released version targets mlx >
0.31.2) on an unvalidated combination. That oracle validity is the real
cost, NOT golden regen (regenerating goldens is the verification, not a
gate). Upstream refs below are all in `ml-explore/mlx`, full-URL'd — a bare
`#NNNN` in this repo resolves to our own tracker (a 404), not theirs.

What `main` actually has (confirmed against the PR pages):
- [ml-explore/mlx#3485](https://github.com/ml-explore/mlx/pull/3485)
  `GatherQMM::output_shapes` — merged 2026-05-29, zero numeric change. THE
  prize: resolves the `src/generate.ts` blocker that keeps 26B MoE decode
  uncompiled → unblocks CompiledDecode over the MoE (attacks the 26B host
  term).
- [ml-explore/mlx#3764](https://github.com/ml-explore/mlx/pull/3764)
  `qmv_wide` — merged 2026-06-26. Small-M (≈2–8) quant matvec; helps
  SPEC-DECODE verify + batching, NOT single-stream M=1 and NOT the gather /
  MoE path. Becomes the default for M≈2–8 → re-baseline batched goldens.
  This is why the bump pairs with lever 1, not standalone.

What `main` does NOT have (corrects the prior note):
[ml-explore/mlx#3553](https://github.com/ml-explore/mlx/issues/3553) is an
OPEN issue (the problem report), NOT a merged fix, and `qmv_wide` is not
wired into the gather path. There is NO `gather_qmm` M=1 qmv-class fast
path upstream — the 26B M=1 compute-bound gap (~4 ms/step) is ours to close
(the shelved moe-qmv-kernel; roofline #2). Probable no-op:
[ml-explore/mlx#3120](https://github.com/ml-explore/mlx/pull/3120) (split-K
small-M quant matmul) was in mlx HEAD 2026-03-21, before the 0.31.2 tag —
likely already ours; confirm before counting it.

Sequence: land this WITH lever 1 (speculation), where #3485 + #3764 both
pay off — not as a standalone "faster decode" move it isn't.

### 3. Quantization quality-per-bit — fewer bytes IS more tok/s  [expected ~10–15%]

Decode scales ~linearly with weight bytes. oQ-style sensitivity-driven
quant in `convert` (adoption map #4, eval-gated) and TurboQuant (Phase 13)
are decode-speed programs wearing quality clothes: 4.0 → ~3.5 effective
bpw at equal KL ≈ +10–15% decode with zero kernel work. Gate: perplexity
+ 6-task eval vs the existing knapsack at equal bpw.

### 4. Host-side residuals  [expected 2–8% on affected models]

- **e4b ~5% per-step host overhead** (Phase 7 residual; dispatch count).
- **GeneratedMiniCPM5 + fused SwiGLU MLP** — CPM5 still runs the loop
  monolith; the deferred generate-and-fuse win ([[cpm5-generate-and-fuse]]
  memory + steel-qmm-header.ts drop-in).
- **P4 device-side step chaining** — depth-k chained step graphs, one
  host sync per k tokens (batching-perf-path P4; the oMLX burst-decode
  REFUTATION does not apply — this attacks OUR FFI/readback cost, a
  different mechanism).
- **Perf-kernel default flip** — still gated on a clean-machine
  benchmark run (the mode matrix shows it ~neutral on e4b short; judge on
  12B long + clean box before flipping anything).

### Non-levers (measured, don't re-litigate without new evidence)

Megakernels at M=1 (bandwidth floor: ceiling ~1.78× CPM5, achieved 0.94×
— multi-token amortization is required, which is levers 1/batching);
oMLX-style burst decode (refuted for Bun); fused-decode activeN (refuted
end-to-end on 12B, reverted); host graph-build overlap (already hidden by
the pipelined loop — spin-injection proof in decode-roofline-lookagain).

## Sequence

**1a AssistantSource → 2 mlx bump + re-bench → 3 oQ spike → 1b cheaper
head → 1c DSpark** (as its training milestones land, Josh-gated runs),
with §4 host residuals as filler between blocks. Re-run
`scripts/bench-modes.ts` (e4b + 12B, short/2k/4k) after each lever lands —
it is this program's scoreboard; promote clean-machine rows to
benchmarks/RESULTS.md.
