# Parity-tier DAG → meaningful CLI flags

**Status:** vision / roadmap (2026-06-21). The first artifact exists — a zoomable,
tier-tagged map of the training + inference DAGs at
[`docs/dag/training-inference-map.html`](../dag/training-inference-map.html). This
doc records where it goes and *why*: to turn a sprawling pile of CLI flags into a
small, coherent, tier-organized surface.

## The framework (recap)

Every node in the compute graph sits in the **lowest parity tier whose oracle it
matches bit-for-bit**:

- **L1** — drop-in for **mlx-lm** (its op is the oracle; bit-exact or it's a bug).
- **L2** — drop-in for **mlx-optiq** (optiq's behavior is the oracle).
- **the Lab** (formerly the `--l3` tier — deleted as a product mode 2026-07-05,
  [unified-engine-frontier-plan.md §6](unified-engine-frontier-plan.md)) — **our
  originals** (flash-CCE head, ORPO loss, prefix-share, segmented backward, HLG
  sampler, expert offload). **No oracle ships**, so correctness is gated by
  finite-difference / KL / quality, *not* parity. Output-changing inference
  experiments live here as env-flag items with a bench + expiry, until one beats
  the L1 baseline in a paired A/B.

**The gate is the oracle.** A node can only live in a lower tier if that oracle
exists AND it matches bit-exactly; otherwise it bubbles up. Note the subtlety the
map already shows: an *optimization* that still matches the oracle stays low —
`compiled-decode` is ours but is L1 because it replays the same ops bit-for-bit.
Only nodes with **no** oracle (flash-CCE) are *forced* into the Lab. (Background +
post-mortem: [orpo-flash-cce-pin-leak.md](../archive/investigations/orpo-flash-cce-pin-leak.md).)

## Two axes: parity gates performance

Every optimization has **two independent coordinates**, and conflating them is what
made the flag surface unreadable:

1. **Parity** — *which reference does it reproduce bit-for-bit?* This sets the
   **lowest level** it may live in: matches mlx-lm → L1; matches mlx-optiq but not
   mlx-lm → L2; matches neither → no-oracle, Lab-gated (KL + tests).
2. **Performance** — *is it the fastest correct way?* This sets whether it's the
   **default (on)** within its level, or a kept-but-**off** opt-in.

**Parity gates performance.** A faster kernel that breaks mlx-lm parity is simply
*not in L1* — it bubbles up to whatever level its parity allows. You never trade the
guarantee for speed silently; you change levels, and the user opts in. The level is
your floor of trust; the default within it is the best way to honor that floor.

### Decision procedure for any new optimization

1. **Measure its parity** (run it both ways, compare — "one flag, one measurement
   per lever"). The lowest oracle it matches bit-for-bit is its level ceiling.
2. **Measure its performance** vs that level's current default:
   - **faster AND holds the guarantee** → it becomes the **default (on)** for that level.
   - **slower but still correct** → **keep it as a documented default-off flag**
     (optionality for A/B; never the default, never deleted).
   - **breaks the guarantee but offers a real tradeoff** (e.g. 2× tok/s at KL
     0.0015) → a **Lab item** (env-flag, bench + expiry); it earns a place only
     by beating the L1 baseline in a paired A/B.

Worked examples:
- *5% less memory, still bit-for-bit with mlx-lm* → **default-on in L1.**
- *2× tok/s, but KL 0.0015 to mlx-lm* → **Lab item** (proves itself or expires).
- *another way, 3% slower, still correct* → **kept, off in every level.**

### Our decode levers under this rule (today)

| lever | parity | perf | placement |
|---|---|---|---|
| `compiled-decode` | bit-exact w/ uncompiled (`compiled-decode.test`) | faster | **default-on, every level** |
| `perf-kernel` | envelope-gated, no bit-exact oracle (was gated ≥56/64 teacher-forced argmax vs our own frozen compat trajectory) | regressed e4b 0.62–0.93× | **DELETED 2026-07-05, [unified-engine-frontier-plan.md §6](unified-engine-frontier-plan.md)** (kernel + frozen-oracle tests removed) |
| `fused-sdpa` | matches optiq bit-for-bit, not mlx-lm (`fused-sdpa.test` tier-a goldens) | faster | **default follows `--kv-quant`** (on for `config` — the L2 bridge; off for uniform/bf16) |
| `fused-decode` | (no oracle) | ~1.00× (`optimization_plan.md`) | **DELETED 2026-07-05, [unified-engine-frontier-plan.md §6](unified-engine-frontier-plan.md)** |

So `--l1/--l2` is the **parity** axis (the guarantee), and the defaults within
each tier are the **performance** axis (the fastest kernel that still holds it).
2026-07-05 outcome ([unified-engine-frontier-plan.md §6](unified-engine-frontier-plan.md)):
no output-changing decode kernel beat the L1 baseline in a paired A/B, so `--l3`
was deleted as a product mode (the flag now hard-errors) along with its kernels
(perf-kernel, fused-decode). The no-oracle territory — HLG sampler, expert
offload, batched mixed-precision — is now the **Lab**: env-flag experiments with
a bench + expiry, gated by KL + quality, off the decode axis.

> History: commit `f1bf5cc` put the perf kernel in the L2 preset claiming
> "perf-kernel-oracle.test asserts the fused kernel == the frozen optiq goldens".
> Both halves were wrong — that golden is frozen from mlx-bun's own compat engine,
> and the gate is argmax-agreement, not equality — so 2026-07-01 restored the tier
> rule: the bare tier is the guarantee; perf kernels are opt-ins within it.
> Deletion outcome: the perf kernel never beat the L1 baseline in a paired A/B
> (regressed e4b 0.62–0.93×; only win 12B@16k +6% with a KL WARN), so it was
> DELETED 2026-07-05 with its frozen-oracle tests
> ([unified-engine-frontier-plan.md §6](unified-engine-frontier-plan.md)).

## Why this matters for CLI flags

We are accumulating a **lot** of flags (`--grad-accum`, `--grad-clip`, `--seg`,
`--no-flash`, `--no-prefix`, `--no-segment`, `--lambda`, `--val-size`, kv-quant
knobs, sampler knobs, …). The problem isn't any one flag — it's the **combinatorics**
and the fact that **some are never really a choice** (always-on guards, or the only
viable route). The tier-tagged DAG makes each flag legible by asking: **what route
does this flag push the computation down, and what tier is that route?**

A flag falls into exactly one of three buckets:

| flag selects… | tier effect | what it IS | action |
|---|---|---|---|
| the only viable route (no alternative node) | — | not a choice | **always-on default; drop the flag** |
| between two routes at the SAME tier / same oracle | none | cosmetic / safety guard | **default it; expose only if it ever fails** |
| between a **lower-tier** route and a **no-oracle (Lab)** route | **L1/L2 ↔ Lab** | a real **parity ⇄ optimization** knob | **keep, document as such, group by tier** |

So the DAG lets us answer "**what flags push down THAT route**" for any path, and
from that:

1. **Prune always-on flags to defaults** — anything whose alternative route is
   never selected, or whose toggle doesn't change the tier, shouldn't be a flag.
2. **Surface the real axis.** The flags that genuinely matter all toggle
   *bit-exact-lower-tier ⇄ our-no-oracle-optimization*. Those could collapse into a small
   number of intent-level switches (e.g. a single `--exact` that forces every node
   down to its lowest tier, vs the optimized default) instead of N independent
   kernel toggles the user has to understand individually.
3. **Group the rest by what they trade** — memory (`--seg`, all bit-exact → not a
   parity choice, a memory↔compute knob), hyperparameters (`--lambda`, `--lr` →
   training knobs, orthogonal to tier), etc.

### Worked classification (current training flags)

- `--grad-clip 1.0` → standard guard, L1, **always-on default** (not a route choice).
- `--seg N` / `--no-segment` → memory↔compute, **bit-exact either way** → a *memory*
  knob, **not** a parity choice. Should read as "memory budget," not "exactness."
- `--grad-accum N` → changes the accumulation route (L1; smoother grads) → a real
  *training-quality* knob.
- `--no-flash` → **no-oracle flash-CCE → L2 MLX fused head** → a genuine *parity ⇄
  perf* fallback (the one place the head leaves the no-oracle class).
- `--no-prefix` → **no-oracle prefix-share → bit-exact two-forward** → a *perf* knob
  with no numerical cost.
- `--lambda` → ORPO hyperparameter (pure no-oracle) → a *training* knob.

The pattern: most flags are **memory/training knobs or always-on guards**; only a
couple are true **parity ⇄ optimization** toggles. Today they're a flat list the
user must reason about individually; tier-tagging lets us present them as what they
actually are.

## Roadmap to make it executable

The map is hand-authored today. To make the framework *enforce* itself:

1. **Derive the graph from code** — extract the call graph + per-node op/oracle tags
   so it stays in sync and is **queryable** ("every no-oracle node", "paths that
   cross into the Lab", "the pure-L1 subgraph", "flags that select route X").
2. **CI-enforce the gate** — a node tagged L1 must have a passing bit-exact parity
   test vs mlx-lm; if it can't, it's a bug or must be re-tagged no-oracle. "The
   oracle is the gate" becomes a check, not a principle.
3. **Shrink the no-oracle surface** — audit whether anything in the Lab island is
   actually bit-exact-able and just unproven (e.g. the prefix-shared *forward* is
   already bit-exact — `prefix-shared-parity.ts` — so only the encode-once *fold*
   is truly no-oracle). Minimizing it minimizes what needs KL/quality gates.
4. **Generate the flag surface from the graph** — once flags map to routes, the CLI
   help + defaults can be derived: always-on routes have no flag, parity⇄opt routes
   collapse to intent switches, knobs group by what they trade.

End state: instead of a growing flat list of flags the user memorizes, a small set
of intent-level switches whose meaning is exactly "which tier route does the compute
take," backed by a DAG that's checked in CI.
