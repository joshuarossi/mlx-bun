# Curve sampler: bisectors, routing, and the falsification

**Question.** The v2 log-prob transfer-curve sampler (`src/curve-sampler.ts`, the
`/curves` designer) replaces temperature+softmax with a drawn monotone curve. It
*feels* like it reaches outputs temperature can't. Three experiments ask: is that
real, where does it come from, and is the mechanism "routing through forks"?

All runs: `mlx-community/gemma-4-e4b-it-OptiQ-4bit` (e4b), greedy reference paths,
the local server / direct model load. Scripts are reusable (swap the `PROMPTS`).

---

## 1. Can pure temperature reproduce a curve's output? — No.

`scripts/curve-temp-match.ts`, `curve-temp-seedsearch.ts`, `curve-temp-grid.ts`,
`curve-temp-weights.ts`. Take a curve-generated sample; sweep **pure** temperature
(top-p/top-k off) across T and across seeds (the seed is a free variable), looking
for an exact match.

- **Lighthouse (creative):** 924 pure-temperature samples across T = 0.4–2.0 and
  ~340 seeds → **0 exact matches, 0 crossings of the curve's fork.** The only seed
  that reproduced the curve's *opening* was the curve's own seed (102), which then
  forked away. Temperature shares ≤14 words then diverges into different content.
- **Weights-advice (constrained):** also 0 exact, but the miss is **cosmetic** —
  temperature forks at word 6 (`when`→`with`) yet converges on the same advice.
  Same meaning, different surface form.

So "couldn't temp do that anyway?" → no, but the curve's distinctiveness is
**prompt-dependent**: real divergence on open prompts, phrasing-only on constrained
ones. Different *shape* → different reachable samples. (Mechanism TBD — see §3.)

---

## 2. The bisector map — where do prompts route into separate timelines?

`scripts/bisector-trace.ts`. Rank-2 probe: walk the greedy reference; at each
position force the rank-2 token and greedy-continue; classify the branch as
**reconverged** (re-merges with the reference content, alignment-free longest common
token-substring) or **diverged**. A diverging branch whose rank-2 had real
probability (≥0.05) is a **genuine fork / bisector**; rank-2 with ~0 probability is
**forced** noise. Output: `docs/investigations/curve-runs/bisector-trace.json`.

Among **genuine alternatives** (rank-2 prob ≥ 5%):

| prompt    | genuine alts | fork % | genuine-fork depths            | deepest | path |
|-----------|--------------|--------|--------------------------------|---------|------|
| creative  | 21           | **48%**| 1,3,10,12,18,19,20,22,**27,28**| 28      | 41   |
| advice    | 26           | **27%**| 1,13,14,16,17,**39,40**        | 40      | 80   |
| factual   | 18           | **17%**| 14,15,18                       | 18      | 62   |

- **Creative:** forks spread continuously, deep, no flat region.
- **Factual:** hard **funnel** (0–13 locked on "…is Paris"), thin choice band
  (14–18, population phrasing), then **flat** (19–61). 83% of genuine alternatives
  re-merge — the "constrained → rank-2 reconverges" prediction.
- **Advice:** two-basin — opening stance, long re-merge body, second fork cluster
  at 39–40 (new list item).

The bisector field is real, and its shape explains the §1 asymmetry.

---

## 3. Does the curve ACTUALLY route at the bisectors? — Falsified.

`scripts/bisector-route.ts`. Ground truth = §2 labels. Under **matched seeds**,
generate samples with each policy, align to the greedy reference, find the **first
departure**, and compute the departure **hazard** at FORK vs RE-MERGE nodes (both
high-entropy, so the ratio isolates fork-*selectivity* from raw entropy). Policies:
`default` (T=1+top-p+top-k), `temp0.8` (pure), `curve-id` (identity curve — control,
same machinery, no shaping), `curve-router` (gate tail, open head — the shape that
*should* route). Step-5 coherence: fork-departures must stay within ~1 nat/token of
the reference (not garbage). Output: `curve-runs/bisector-route.json`.

**Creative**

| policy       | FORK | REMERGE | **FORK/REMERGE** | coherent |
|--------------|------|---------|------------------|----------|
| default      | 26%  | 34%     | 0.75             | 9/9      |
| temp 0.8     | 7%   | 23%     | 0.30             | 3/3      |
| curve-id     | 26%  | 34%     | **0.77**         | 9/9      |
| curve-router | 43%  | 55%     | **0.79**         | 13/13    |

`curve-router`'s fork-selectivity (0.79) **equals the no-op identity curve (0.77)**
and default (0.75). The router shape raised departure *volume* (43%/55% vs 26%/34%)
**proportionally** — targeting unchanged. Every ratio is below 1: all policies depart
*more* at re-merge than at forks.

**Factual:** `curve-router` 12.98 vs default 19.89 / temp 15.0 — *below* temperature.
(High ratios just reflect the 3 forks being the only high-entropy nodes amid 38
locked-elaboration positions.)

### Conclusion

**The "routes through forks" claim is false** for this curve — its fork-selectivity
matches a no-op control. The curve changes the **volume** of diversification, not its
**targeting**. The trap: `curve-router` has the highest *absolute* fork-rate (43%),
which naively reads as "forks most"; that's only more diversification overall.

This reconciles §1 honestly: the curve still reaches outputs temperature can't
(different *shape* → different reachable samples), but **not by targeting forks** —
it's a different reshuffle, not a smarter one. All fork-departures stayed coherent,
so this is a *coherent* reshuffle, not a garbage artifact.

**Likely structural reason:** fork-ness (does the rank-2 branch reconverge?) is a
property of the downstream trajectory — invisible in the local next-token
distribution. A local transfer curve can only see current logits, so it can't
preferentially depart at forks vs locally-identical re-merges. A local sampler
probably *can't* be a fork-router by construction; only an entropy reshuffle.

### Caveats / next steps

- `curve-router` is the natural router shape, **not a user-drawn curve** — drop a
  real curve JSON in as a 5th policy to confirm.
- 20 seeds × 1 prompt/pole — scale to ~5 prompts/pole × more seeds for error bars.
- Loophole: test whether fork nodes carry a distinct *local* logit shape (e.g.
  bimodality) that a cleverer curve could exploit.

## Reproduce

```bash
bun run scripts/bisector-trace.ts      # the map  → curve-runs/bisector-trace.json
bun run scripts/bisector-route.ts      # the test → curve-runs/bisector-route.json
bun run scripts/curve-temp-grid.ts     # temp-can't-reproduce (server on :8090)
```
