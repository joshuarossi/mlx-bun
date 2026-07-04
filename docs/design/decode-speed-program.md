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
- **1c. DSpark (THE goal drafter)** — DFlash KV-injection, architecture
  verified (overfit τ=3.24, paper-range). Blockers are research, not
  serve wiring: 27B/12B retarget (regen+train, Josh's shell), data scale
  (thousands of on-distribution generations vs 160), draft-loop
  tightening. At τ≈3 on the 27B agent workload: **~15 → ~35–45 tok/s**
  (docs/investigations/dspark-handoff.md). Slots in as `DflashSource`,
  L3/KL-gated.

### 2. mlx bump — free upstream wins  [expected: 26B decode, small-M everywhere]

Pinned at mlx 0.31.2. Upstream has since merged `qmv_wide` and has
`gather_qmm` M=1 work in flight — aimed exactly at the 26B MoE's profiled
~4 ms/step gap we root-caused to their missing fast path (mlx#3553; see
STATUS kernel-review closeout). Bump, re-run the parity suites + this
benchmark, re-measure the qmm-pad workaround. Cheapest possible win;
gate = every L1/L2 golden still green (machine-keyed regen where needed).

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
