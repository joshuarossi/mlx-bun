# Curve sampler — preregistered research plan (distinctness track)

*2026-07-01. Status: PREREGISTERED — hypotheses and analysis fixed BEFORE the
fresh runs. Mandate (Josh): "I am not ready to give up on the curve sampler.
I think there ARE outputs that cannot be reached by just p, k and temp — temp
means you cannot control different areas of prob." The old experiments are not
trusted as-is (audit in §6); this plan replaces them. The distinctness track is
being PURSUED, not folded into the assessment's "honest negative" framing
(reports/curve-designer-paper-assessment-2026-07-01.md) — the assessment's
venue advice (workshop/demo tier unless the empirical section lands) is noted,
not contested.*

Object under study: `src/curve-sampler.ts` — the v2 monotone-cubic (PCHIP)
log-prob transfer curve, `p_out ∝ exp(curve(log p_in))`, replacing
temperature+top-p/top-k when active.

---

## 1. The theorem (in hand — pure math, section-ready)

**Setup.** Base next-token logprobs ℓ ∈ ℝ^V, base probs p = softmax(ℓ). Call a
sampler a **single-slope truncation sampler** if its output is

  q_i ∝ exp(ℓ_i / T) for i ∈ S,  q_i = 0 otherwise,

for some temperature T > 0 and survivor set S. This family contains, exactly:

| method | survivor set S | S is a rank prefix? | slope on S |
|---|---|---|---|
| temperature | V | yes (trivially) | 1/T |
| top-k | k highest | yes | 1/T |
| top-p | smallest prefix with mass ≥ p | yes | 1/T |
| min-p | {i : p_i ≥ α·p_max} | yes | 1/T |
| top-nσ | {i : ℓ_i ≥ ℓ_max − n·σ(ℓ)} | yes | 1/T |
| ε / η (desmoothing) | absolute / entropy-scaled floor | yes | 1/T |
| typical | surprisal closest to H | **not necessarily** | 1/T |
| mirostat | feedback-chosen k per step | yes (per step) | 1/T |

Every published truncation sampler differs only in HOW it picks S — on the
survivors, all of them apply ONE global slope.

**Gap-ratio invariant.** For any a, b, c ∈ S with distinct ℓ values:

  R(q) := (ln q_a − ln q_b) / (ln q_b − ln q_c)
        = (ℓ_a − ℓ_b) / (ℓ_b − ℓ_c) = R(p).

Proof: ln q_i = ℓ_i/T − ln Z_S; the normalizer cancels in differences, T
cancels in the ratio. So **no choice of T and no choice of survivor set can
change the log-gap ratios of surviving tokens** — one scalar cannot set
different sharpness in different probability regions.

**The curve breaks it.** A monotone map w with slope s₁ on one log-prob region
and s₂ ≠ s₁ on another gives R(q) = (s₁/s₂)·R(p) for tokens straddling the
regions — order preserved (monotonicity), ratios changed. Hence a curve
distribution with mismatched gap ratios is unreachable EXACTLY by any member of
the family above; the witness (§2) shows the inexact gap is also structurally
large where it matters. Truncating the mismatched region instead costs its
whole mass in TV — so TV_min ≳ min(ratio-mismatch cost, lifted-band mass / 2).

**Honest boundary (both directions).** The curve is a FIXED pointwise map of
the token's own value: it cannot express distribution-ADAPTIVE head selection
(min-p's α·p_max, top-nσ's σ(ℓ), typical's H, mirostat's feedback) nor
non-monotone re-ranking (XTC). The two families intersect exactly on
{temperature + absolute-threshold gates}; **neither contains the other**. The
claim being pursued is "the curve reaches per-step distributions the standard
family cannot", not "the curve subsumes it". (The fork-routing impossibility —
fork-ness is a trajectory property invisible to any local warp — stands as the
other half of the characterization; see curve-bisector-routing.md, strengthened
per §6 F5.)

## 2. The witness (in hand — measured 2026-07-01)

`scripts/experiments/curve-distinctness.ts` (this session; MiniCPM5-1B-OptiQ-
4bit, M1 Max 32 GB). 20 real next-token distributions (5 prompts × {start,
max-entropy "fork", min-entropy, after-comma}); per position, a witness curve
that (i) keeps the top-2 gap EXACTLY as sharp as T=0.7 and (ii) lifts the
p∈[0.001, 0.02] band's total mass to 2× its T=0.7 value (or the largest
feasible factor on flat distributions). Fit = exhaustive (T ∈ [0.05, 3] step
0.001-refined, survivor-prefix m ∈ {1..300, 325..2000, V}) minimizing total
variation — since every (p, k, min-p, top-nσ, ε) survivor set is a rank
prefix, the m-sweep covers ALL of them jointly, any application order.

| pos | kind | H (nats) | band mass ref→witness | TV_min | (T*, k*) |
|---|---|---|---|---|---|
| creative start | start | 1.67 | 0.011→0.022 (×2.0) | 0.0105 | (0.73, 1773) |
| creative fork | max-H | 4.94 | 0.270→0.512 (×1.9) | **0.187** | (1.73, 168) |
| creative comma | after-comma | 4.12 | 0.068→0.136 (×2.0) | 0.0630 | (0.77, 402) |
| advice start | start | 1.10 | 0.010→0.021 (×2.0) | 0.0075 | (0.74, 798) |
| advice fork | max-H | 3.99 | 0.204→0.408 (×2.0) | **0.167** | (0.88, 265) |
| advice comma | after-comma | 1.15 | 0.002→0.004 (×2.0) | 0.0020 | (0.70, 1773) |
| factual start | start | 1.16 | 0.015→0.030 (×2.0) | 0.0096 | (0.77, 94) |
| factual fork | max-H | 3.43 | 0.072→0.143 (×2.0) | 0.0593 | (0.76, 243) |
| factual comma | after-comma | 1.92 | 0.028→0.056 (×2.0) | 0.0265 | (0.74, 101) |
| continuation start | start | 1.01 | 0.009→0.017 (×2.0) | 0.0067 | (0.74, 1323) |
| continuation fork | max-H | 5.19 | 0.369→0.568 (×1.5) | **0.119** | (1.23, 235) |
| continuation comma | after-comma | 2.13 | 0.032→0.064 (×2.0) | 0.0165 | (0.78, 500) |
| brainstorm start | start | 2.16 | 0.014→0.029 (×2.0) | 0.0142 | (0.72, 1723) |
| brainstorm fork | max-H | 5.76 | 0.434→0.585 (×1.35) | **0.114** | (1.20, 264) |
| brainstorm comma | after-comma | 1.73 | 0.016→0.033 (×2.0) | 0.0177 | (0.73, 1148) |

(5 min-entropy positions skipped: band empty — near-deterministic steps have
nothing to lift; the theorem is about positions where sampling matters.)

- **Irreducible TV: min 0.0020, median 0.0177, mean 0.0547, max 0.187.**
- **Fitter control: refitting plain T=0.7 gives max TV 0.008** (mostly
  ≤0.002) — the gaps are real, 10–20× above fitter slack at forks.
- **The gap concentrates exactly at forks** (high-entropy positions): TV
  0.11–0.19 — no (T, p, k, min-p, top-nσ) combination gets within 11–19% total
  variation of the witness there. Best fits either keep T≈0.7-sharp heads and
  miss the band, or go hot (T*=1.2–1.7) to buy band mass and give up the top-2
  gap. Full-support pure temperature is worse still (TV 0.17–0.28 at forks).
- The witness is realizable by the shipped designer: the PCHIP spline through
  the printed knots reproduces the analytic piecewise-linear witness to mean
  TV 0.0083; the curve JSON is printed by the script for pasting into
  `/curves`.
- **Text-level (directional, N=30/arm, 3 prompts, not preregistered):** under
  a fixed global witness curve vs its best global match (T=0.77, k=750),
  per-step TV along generated trajectories averaged 0.024–0.061 (max 0.24),
  but distinct-1/2/3 and junk were indistinguishable at this N. Honest read:
  **per-step distinctness is proven; whether it produces measurably different
  TEXT distributions is exactly H2 below, and is open.**

Reproduce: `bun scripts/experiments/curve-distinctness.ts` (flags:
`--model`, `--positions-per-prompt`, `--gen-n`, `--gen-tokens`, `--skip-text`).

## 3. Hypotheses (fixed before the fresh runs)

- **H1 — per-step distinctness. PROVEN** (§1 theorem + §2 witness). The curve
  family reaches next-token distributions with TV ≥ 0.05 (median-fork ≥ 0.1)
  from the entire single-slope truncation family, at matched top-2 sharpness.
  Remaining H1 work is replication breadth only: same probe on e4b + 12B
  (262k vocab) and 20 → 100 positions. *Null outcome possible:* larger-vocab
  models could shrink the band-lift headroom; report whatever comes out.
- **H2 — text-level distributional distinctness at matched coherence.** There
  exists a curve (the §2 global witness is the preregistered candidate) such
  that the distribution of its generations differs from EVERY tuned
  single-slope baseline's at equal coherence: MAUVE(curve, baseline) <
  MAUVE(baseline-seed-A, baseline-seed-B) − δ, with δ set by the bootstrap CI.
  *Null outcome is live:* per-step TV of 0.02–0.06 per token may wash out in
  60-token texts (the directional N=30 probe saw no distinct-n separation).
  A null here = "per-step distinctness does not surface in text statistics at
  this scale" — publishable as the boundary of claim 1, and the method paper
  stays closed.
- **H3 — a task/regime where curve-reachable points lie OUTSIDE the
  (T,p,k)+min-p+top-nσ Pareto front** (quality × diversity at matched
  coherence). Candidate regimes (fixed now): (a) constrained-form generation
  where the head must stay sharp while mid-band alternatives carry the
  variety (structured lists, fixed-opening continuations); (b) fork-dense
  creative prompts (the §2 fork TV is largest there); (c) repeated-sampling
  best-of-N settings where band mass controls candidate coverage. *Null
  outcome is live* and would land exactly on the assessment's analysis-paper
  framing.

## 4. Preregistered protocol (the referee-grade run)

**Models:** MiniCPM5-1B (73k vocab), gemma-4-e4b (262k), gemma-4-12B (262k) —
all cached OptiQ-4bit builds; the vocab split is a known moderator (hlg
investigation §15).

**Arms (per model, per prompt):**
1. `default` — the model's own generation_config recipe (temperature/top-p/top-k).
2. `best-Tpk` — (T, p, k) tuned on a held-out prompt set for the target
   coherence level (grid: T ∈ {0.5..1.5 step 0.1} × p ∈ {0.85, 0.9, 0.95, 1} ×
   k ∈ {0, 40, 64, 100, 200}).
3. `min-p` — α ∈ {0.02, 0.05, 0.1, 0.2} × T ∈ {0.7..1.5}.
4. `top-nσ` — n ∈ {1, 1.5, 2, 3} × T ∈ {0.7..1.5}.
5. `mirostat` — τ ∈ {3, 4, 5} (implement or mark N/A if not landed; absence
   documented, not silently dropped).
6. `curve-witness` — the §2 global witness curve (knots frozen in the script
   output, checked into the plan by hash once the run starts).
7. `curve-tuned` — ONE curve hand-tuned in the designer per model BEFORE
   scoring (tuning prompts disjoint from eval prompts), then frozen.

**Prompts:** 30 prompts, 10 per pole {creative/open, advice/constrained,
factual} — fixed list checked in before the run; disjoint 10-prompt tuning set.

**N and power.** N = 100 continuations per (arm × prompt-pole × model) cell,
64 tokens each. Basis: the old N=10 runs put the sd of a cell's self-BLEU
run-mean at ≈0.06 (runO swing 0.083 between two seed bands), i.e. a minimum
detectable effect ≈ 0.17 at N=10 — bigger than every effect ever claimed. At
N=100 the run-mean sd scales to ≈0.019, MDE ≈ 0.053 at α=.05/power .8; for
Δ≈0.05 effects run the planned replication (below) and pool. MAUVE gets
bootstrap CIs (1000 resamples); LLM-judge cells get binomial CIs.

**Seed discipline.** Explicit integer seeds only — no wall-clock seeding
anywhere (the batch same-ms collision class). Disjoint bands per arm:
arm i uses seeds `10000·(i+1) + {0..N−1}`. The WHOLE grid is run TWICE with
band offset +5000 (built-in fresh-seed replication — the discipline that
caught both premature verdicts in hlg §14). No cross-arm seed pairing (arms
are different distributions; pairing buys nothing and invites accidental
correlation stories).

**Metrics (all fixed now):**
- **Coherence gate (per sample, gates everything else):** (a) non-Latin
  letter ratio < 1% AND (b) mean per-token logprob under the model's OWN
  default recipe ≥ (pole-median of the default arm − 1.5 nats) AND (c) no
  4-gram repeated ≥ 3× within the sample. (b)/(c) close the F4 hole — Latin
  word-salad and repetition-degeneration currently pass the gate.
- **Diversity:** coherence-GATED distinct-1/2/3 (computed only over gate
  survivors, reported with survivor rate) + self-BLEU (leave-one-out, so it
  has per-sample values and a real variance estimate).
- **Distributional:** MAUVE between arm outputs and (i) the default arm and
  (ii) each other, per pole; embedding model = a real sentence encoder (not
  the LM's own hidden states — a known weak proxy).
- **Quality:** LLM-judge per the dreaming eval methodology (cloud judge;
  hand-curated gold anchors drafted before scoring; surface-variant dedup;
  judge the artifacts, blind to arm, position-flipped pairs). Judge prompt
  frozen in the harness before the run.
- **Per-step (mechanism):** mean TV along trajectories between the curve arm
  and its best-fit single-slope arm (already implemented in the witness
  script) — connects H2 outcomes back to H1 magnitude.

**Pareto construction (H3):** per pole × model, plot (coherence-gated
diversity, judge quality) for every arm-cell; H3 is supported iff a curve
cell sits outside the convex hull of ALL single-slope cells with
non-overlapping bootstrap CIs, in ≥2 of 3 models.

**Commands (harnesses to extend from the existing probe):**
```bash
# H1 replication breadth (exists today):
bun scripts/experiments/curve-distinctness.ts --model gemma-4-e4b-it-OptiQ-4bit --skip-text
bun scripts/experiments/curve-distinctness.ts --model gemma-4-12B-it-OptiQ-4bit --skip-text
# H2/H3 (to build: curve-frontier.ts = hlg-frontier.ts skeleton + arms above,
# N=100, gate (a)+(b)+(c), leave-one-out self-BLEU, MAUVE export):
bun scripts/experiments/curve-frontier.ts --model <m> --n 100 --seed-band 10000
bun scripts/experiments/curve-frontier.ts --model <m> --n 100 --seed-band 15000   # replication
# LLM-judge pass: reuse the dreaming judge protocol (docs/design/* memory-synthesis eval).
```
Machine note: label every result with host/chip/RAM (two laptops in rotation —
M1 Max 32 GB / M4 Pro 24 GB; neither canonical). Nothing here is a perf claim,
but the labeling rule stands.

**Decision rules (fixed now).**
- H2 supported → the paper gains an empirical section 4; method-adjacent
  framing becomes defensible at workshop+.
- H2 null, H3 null → ship the assessment's analysis paper (theorem + witness +
  falsification methodology + tool); the distinctness result stays as the
  per-step section. No re-running with new metrics until a NEW preregistered
  amendment is written.
- Any post-hoc metric additions are labeled exploratory, never headline.

## 5. Paper skeleton this feeds

1. The curve designer (tool, live demo). 2. Expressivity: the gap-ratio
invariant + the two-sided boundary (§1) + fork-routing locality impossibility.
3. The witness — per-step unreachability, quantitative (§2). 4. Text-level
results (H2/H3, whatever they are). 5. Sampler-evaluation hygiene (fresh-seed
repeats catching both false negative and false dominance; coherence-gated
diversity; the audit below as methods material).

## 6. Why the old data is not trusted — audit of the prior experiments

Committed artifacts checked: `docs/investigations/curve-runs/*.json`,
`docs/investigations/hlg-runs/*`, harness sources. Severity: **INVALIDATES** /
**WEAKENS** / cosmetic.

- **F1 — INVALIDATES (the old distinctness claim).** The curve-temp family
  (`scripts/experiments/curve-temp-match.ts:53-69`, `curve-temp-seedsearch.ts:23-47`,
  `curve-temp-grid.ts:26-41`, `curve-temp-weights.ts:28-52`) tests whether pure
  temperature EXACTLY reproduces a specific 64–90-token curve-generated string
  across ~924 samples. (a) No control arm: a temperature-generated string would
  also never be reproduced at other seeds — P(specific sequence) =
  e^(−Σ per-token surprisal) ≈ 0 for ANY stochastic sampler, so "0 exact
  matches" is the guaranteed outcome and distinguishes nothing. (b) With
  top_p=0/top_k=0 the support is FULL — every string is reachable by
  temperature with p>0, so "temperature won't go there" is a category error at
  the string level; the meaningful object is the per-step distribution (now
  measured properly in §2). (c) The headline "0 crossed the fork" is
  conditioned on first reproducing the 84-char prefix exactly
  (`curve-temp-grid.ts:11,31`; `curve-temp-seedsearch.ts:28-30`) — essentially
  only the curve's own seed ever reached the fork, so the fork test had
  effective N≈0. Consequence: `curve-bisector-routing.md` §1's "the curve still
  reaches outputs temperature can't" (repeated in its §3 conclusion) is
  unsupported by those runs. The claim happens to be TRUE per §1–2 here, but
  for the per-step reason, not the exact-string one.
- **F2 — INVALIDATES (transfer of the "wash" verdict to the v2 curve).** The
  only terrain map of the v2 designer family, `scripts/experiments/curve-terrain.ts:18`
  (`--n` default 2, max 5), ran at **N=2 samples/cell, 48 tokens, 2 prompts**
  (committed artifact `curve-runs/curve-terrain.json`: n=2) — self-BLEU at N=2
  is meaningless. Every N=10 frontier number (hlg-frontier/runK-runO) measured
  the **v1 HLGShaper** — a different sampler (adaptive windowed-anchor, i.e.
  distribution-dependent, OUTSIDE the fixed-curve family). **The v2 drawn-curve
  family has never been competitively evaluated at any usable N.** The
  assessment's "method paper closed by own data" inherits this gap.
- **F3 — WEAKENS (every diversity comparison at N=10).** From the
  investigation's own runO: a cell's self-BLEU run-mean moved 0.083 between
  seed bands → sd(run-mean) ≈ 0.06 → minimum detectable effect ≈ 0.17 at N=10
  with one run/cell. Every delta ever claimed (0.05–0.11) is below MDE. The doc
  ultimately landed there honestly ("wash at this N"), but intermediate
  verdicts (§12 "conclusive", §13 "definitive", §14 "DOMINANCE") each
  overran the resolution; ~200+ samples/cell is the floor for Δ≈0.05 (§4 N).
- **F4 — WEAKENS (coherence gates).** All automated verdicts gate coherence on
  non-Latin-script ratio alone (`hlg-map.ts:51-56`, `hlg-frontier.ts:55-59`,
  `curve-terrain.ts:94-98`): Latin-script incoherence ("the planet' adorable
  axis", "—aving purpose", repetition loops) passes as 0% junk, so
  diversity-vs-coherence frontiers can be bought with undetected degeneration.
  The doc's "read the text" discipline patched this manually; the §4 gate
  (logprob + repetition + script) mechanizes it.
- **F5 — WEAKENS (the fork-routing "falsification").** `bisector-route.ts:16`
  — 20 seeds × 1 prompt/pole; the FORK/REMERGE hazard ratios rest on 3–16
  fork-departure events per policy (`curve-runs/bisector-route.json` cohN);
  binomial SE on the rates is ±0.1–0.2, so "router 0.79 ≈ identity 0.77" is an
  equivalence claim an underpowered test cannot establish (it could not
  distinguish a 1.5–2× real ratio). The point estimates being identical is
  suggestive, and the locality argument is sound a priori — but the doc's
  headline "Falsified" and the assessment's "falsified with a proper control"
  overstate; the doc's own caveats (5 prompts/pole, more seeds, user-drawn 5th
  policy) are the fix and move into this protocol.
- **F6 — cosmetic (seeding).** No wall-clock/same-ms seeding in any audited
  harness — all fixed explicit seeds (curve-temp 100+i / 0..299 / 200+i;
  curve-terrain 7300; hlg-map 1234+i, canary 7+i; hlg-frontier 1000+i;
  hlg-grid 2000+i; bisector-route 1..20) and `/generate` derives per-sample
  seeds as base+i (`src/server.ts:1680`). The batch same-ms collision bug does
  not taint these. Arms share seed bases (paired design) with only runO as a
  fresh-seed repeat — §4 makes replication structural instead.
- **F7 — cosmetic.** `bisector-trace.ts` computes rank-2 labels via
  `forwardHidden+logitsFromHidden` while the greedy reference comes from
  `generate()` — the two are known to diverge on near-ties
  (`src/eval/runner.ts:109-113`), and near-ties are forks; the committed
  artifact shows tfMismatch 0/1/0, so no material impact, but the assert
  should stay.

## 7. Doc map

- This plan: `docs/planning/curve-sampler-research-plan.md` (preregistration —
  amend by appending, never by silent edit).
- Witness probe: `scripts/experiments/curve-distinctness.ts`.
- Assessment: `reports/curve-designer-paper-assessment-2026-07-01.md`.
- Prior investigations (superseded on the points in §6):
  `docs/investigations/hlg-sampling-investigation.md`,
  `docs/investigations/curve-bisector-routing.md`.
