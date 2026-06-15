# HLG sampling — a piecewise tone curve on the logits

Status: **design + phasing** (no code yet; this doc is the contract)
Owner: sampling layer (`src/sampler.ts`)
Default: **off** (`--hlg-sampling off` = today's temperature sampler, untouched)

> This is the canonical **design/rationale** for HLG sampling. Live
> **status/tracking** (checkboxes, findings) lives in PLAN.md under
> "Phase 19 — HLG sampling". The user-facing flag/param reference lives in
> [docs/reference/server-config.md](../reference/server-config.md) and
> [docs/reference/server-api.md](../reference/server-api.md) once shipped.

## Goal

Add a sampling transform — gated entirely behind `--hlg-sampling on` and a
per-request `hlg` object — that replaces temperature's single global slope
with a **pivoted, region-aware contrast curve** on the per-token
log-probabilities.

The move is a **cross-domain transplant**: take a mathematical structure that is
standard in one field — a piecewise nonlinear transfer function — and apply it
in one that has never used it. HLG (Hybrid Log-Gamma) is the structure we lift:
where a plain gamma is one power curve, HLG is **piecewise**, shaping the low,
middle, and high range of a signal under separate constraints. A logit
distribution is another such signal. The hypothesis is that shaping its three
regions independently buys something a single global temperature cannot — and
that claim is settled by measurement in *this* domain, not by the structure's
track record in its original one.

This is a post-inference, **model-agnostic** transform — it operates on the
logits vector after the forward pass, so it applies identically to every model
(MiniCPM5 + the three Gemma-4 quants) and every lane (serial + `--batch N`)
with **zero per-model code**. It is the first sampling feature in the project
that has **no oracle ancestor** (neither mlx-lm nor optiq does this), so it is
gated by KL + quality + diversity, not parity — with one exception that makes
it safe to ship: see [Correctness](#correctness--evaluation).

## Why temperature isn't enough (the thesis)

Temperature scales every logit by the same factor: `logit / T`. In tone-curve
terms it is a **single straight line through the origin** — one global slope.
Lower `T` steepens it everywhere (sharper, more confident); higher `T` flattens
it everywhere (more diverse).

Its limitation is a **coupling**: the only way temperature loosens the model's
grip on its top token is by raising `T`, which *simultaneously* lifts the tail.
You cannot, with one slope, reduce top-token dominance **and** keep a soft floor
under the tail. Raise the temperature to get novelty and you also import
low-probability noise; lower it to suppress noise and you re-collapse onto the
single most likely token. One number cannot move two regions independently.

The fix is structural, not a better choice of `T`: make the slope **depend on
the region of the distribution**. This is precisely what nonlinear transfer
functions do in signal and color encoding — a single piecewise curve shapes the
low, middle, and high range under separate constraints. The cross-domain idea
here is to transplant that apparatus onto a logit distribution, which is just
another value distribution. Mapped onto the three regions of a token
distribution, the curve's response is:

- **High-probability region** (the model's most confident tokens) →
  **shoulder**: roll the slope off so the top values compress toward their
  neighbours. The model stops being *so fixed* on its favourite answer.
- **Mid-probability region** (where novelty and interest live) → **gain > 1**:
  steepen the slope. The local-contrast boost separates the
  plausible-and-interesting from the merely-mediocre.
- **Low-probability tail** → **toe**: gently reduce the slope toward a soft
  floor. Suppress the tail *smoothly* — unlike top-p/top-k, which hard-clip it
  to `-inf`, and unlike high temperature, which inflates it.

The payoff is the **decoupling** temperature cannot achieve: roll off the high
end *and* hold a soft floor under the tail at the same time — a region of
sampling behaviour no single-knob method reaches. Whether that decoupling is
*useful* is an empirical question, settled in [Correctness](#correctness--evaluation),
not by the pedigree of the curve.

## The transfer function

We operate in **log-probability space**, the natural "stops" axis for a
probability distribution (the sampler already computes `toLogprobs`,
[src/sampler.ts:127](../../src/sampler.ts)). Let `ℓ_i` be each token's log-prob
and `μ` the pivot (middle grey — see [Pivot](#the-pivot--middle-grey)). Define
the centered coordinate

```
z_i = ℓ_i − μ
```

and remap it with a **C¹ log-toe / linear-mid / log-shoulder** curve. The
piecewise form is deliberate — it honours HLG's own breakpoints (HLG literally
switches from a gamma segment to a log segment at E = 1/12):

```
        ⎧  −m·w − m·β_t·ln(1 + (−z − w)/β_t)     z < −w     (toe / shadows)
 g(z) = ⎨   m·z                                  |z| ≤ w    (gain / mids)
        ⎩   m·w + m·β_h·ln(1 + ( z − w)/β_h)     z >  w     (shoulder / highlights)
```

The remapped logits are `ℓ'_i = g(z_i)`. The `+μ` constant shift cancels under
softmax, so we drop it and feed `g(z_i)` straight to the existing
`randomCategorical` draw.

Properties that matter:

- **Slope** is `m` at the pivot and decays as `m·β / (β + d)` a distance `d`
  past each knot — continuous at the knots (C¹), monotone, and always positive.
- **Monotone ⇒ ranking-preserving.** `g` never reorders tokens: it is a pure
  contrast/tone operation, not a re-ranker. Pairwise orderings and the argmax
  are invariant. (Tested — see [Correctness](#correctness--evaluation).)
- **`-inf` safe.** A token masked by top-p/top-k (`ℓ_i = -inf`) lands in the toe
  branch and maps to `-inf` — masking survives the remap, no NaN.

### Knobs → what each controls

| Param | Controls | Effect |
| --- | --- | --- |
| `pivot` μ | center of the curve | where the contrast boost is anchored in the distribution (see below) |
| `gain` m | mid-region slope | `m > 1` sharpens mid-probability tokens; folds temperature (`m = 1/T`) |
| `width` w | extent of the mid region | how many nats around the pivot count as "mids" |
| `shoulder` β_h | high-prob rolloff | small = compresses the top tokens fast → top-token diversity |
| `toe` β_t | low-prob rolloff | small = quick gentle fade of the tail; large = keep more tail |

All knobs are in **nats** (the log-prob unit), so they are scale-free across
models and contexts.

### The degeneracies are the safety anchors

The curve is a **strict generalization of temperature**, and that is what makes
a no-oracle path safe to ship — the default and neutral paths reduce *exactly*
to today's sampler:

- `m = 1`, rolloff off (`w → ∞`, or `β → ∞`) ⟹ `g(z) = z` ⟹ **bit-exact the
  current sampler at T = 1**.
- rolloff off (`w → ∞`), any `m` ⟹ `g(z) = m·z` ⟹ **bit-exact temperature
  `T = 1/m`** (the existing `mulScalar(cur, 1/temperature)` step).

So there is a configuration in which HLG is provably identical to temperature,
down to the bit. That is the parity-equivalent gate (below).

### Greedy is untouched

Under greedy decoding (`temperature === 0`) the sampler returns `argmax`
([src/sampler.ts:78](../../src/sampler.ts)). Because `g` is monotone it cannot
change the argmax, so **HLG is a no-op at temperature 0 by construction** and is
only engaged for `temperature > 0`. The greedy parity gate is therefore
trivially preserved.

## The pivot

Choosing the pivot is the genuinely interesting part: the curve's center has to
mean something across distributions as different as a near-deterministic next
token and a wide-open one. Three modes, all cheap, exposed as `pivot_mode`
(default **top-anchored**). The other two ship as documented opt-in modes —
losing experiments become flags, never deletions.

The pivot is computed from the **full, normalized log-prob vector before any
top-p/top-k masking**, so masked `-inf` entries never contaminate it.

1. **`top` — top-anchored (DEFAULT).** `μ = ℓ_max − c`. The curve centers `c`
   nats below the most-probable token. Predictable, scale-free, one `max`
   reduction. `c` is the meaningful knob; default calibration-pending (Piece 5
   sweep).
2. **`entropy` — entropy-anchored.** `μ = Σ p_i ℓ_i = −H`, the distribution's
   center of mass in tonal space. Auto-exposure: confident contexts (low
   entropy) pull the pivot up near the top; flat contexts push it down. One
   dot-product, information-theoretically natural, less predictable.
3. **`median` — mass-median.** `μ` = the log-prob at the 50% cumulative-mass
   boundary (literal auto-levels / histogram median). Most adaptive; reuses the
   sort top-p already performs.

`width` may likewise be a fixed nat value or, in a later increment, auto-derived
from the log-prob spread (an "auto-contrast" mode). Default fixed for now.

## Temperature semantics

When `hlg` is active, the request's `temperature` **folds into the mid gain**:
`m = 1 / T`. Temperature *is* the mid-tone contrast, and HLG adds the toe and
shoulder on top of it. This avoids double-applying a slope and preserves the
intuition that "temperature" still means "how punchy the mids are." With
rolloff off, `m = 1/T` and `g(z) = z/T` — exactly temperature, as above.

## Where it lands in the code

Sampling is fully model-agnostic and shared by every model and lane
([src/sampler.ts](../../src/sampler.ts), post-inference), so this is a single
transform with no per-model branches.

- **The transform** — a new `applyHlg(lp, params)` in
  [src/sampler.ts](../../src/sampler.ts). HLG is a **replacement sampler**:
  `makeSampler` branches `if (hlg.enabled)` → the curve is the *whole*
  post-logits step (its toe does the tail control), `else` → exactly what we
  used to do (top-p, top-k, then `mulScalar(cur, 1/temperature)`). The two are
  mutually exclusive — when HLG is on, top-p/top-k are **not** applied, because
  the smooth toe is their replacement, not a layer on top of them. Branchless:
  compute the toe / mid / shoulder expressions and select on `z` vs `±w` with
  `where`. Follows the file's strict `owned[]` → `dispose()` discipline (every
  intermediate freed; only the chosen token id crosses to JS).
- **Sampler options** — extend `SamplerOptions`
  ([src/sampler.ts:11](../../src/sampler.ts)) with an optional `hlg` sub-object;
  `makeSampler` builds the HLG step when present, else the existing path
  verbatim.

Three sampler **construction** sites pass the params through; the
degeneracy guarantees keep every existing parity gate green:

- **Serial** — `makeSampler(options)` in
  [src/generate.ts:218](../../src/generate.ts).
- **Batched per-row** — `makeSampler(options)` in
  [src/serve/generation-gateway.ts:127](../../src/serve/generation-gateway.ts).
  Each row already owns its sampler closure, so `hlg` params batch per-request
  for free; the draw site in
  [src/serve/batch-scheduler.ts:276](../../src/serve/batch-scheduler.ts) is
  unchanged beyond construction.

### MLX op feasibility

All elementwise: `exp`, `sub`, `mul`/`mulScalar`, `where`, plus `log` / `log1p`.
The pivot needs one `max` (top), one dot-product (entropy), or the existing sort
(median). Cost is O(V) per token — the same order as the existing top-p step,
negligible against the forward pass, but measured (Piece 5). If `mlx_log1p`
isn't already bound, bind it from the header first — read the full signature to
avoid the trailing-stream-arg footgun (CLAUDE.md).

## Flag, config, and API surface

Conventions per [docs/reference/server-config.md](../reference/server-config.md)
and `serverRuntimeFlags()` ([src/cli.ts](../../src/cli.ts)).

- **CLI**: `--hlg-sampling on|off` (default **off**), plus `--hlg-width`,
  `--hlg-shoulder`, `--hlg-toe`, and the top-anchor offset `--hlg-pivot-offset`
  (the `c` above). There is **no `--hlg-gain`**: the mid gain folds from
  `--temperature` (`m = 1/T`), so temperature stays the one contrast knob and a
  second one would be redundant. `--hlg-pivot top|entropy|median` arrives with
  the alternate pivot modes in Piece 4 (top-anchored is the only mode until
  then). Parsed with the existing `onOff` / `numFlag` helpers; validated (exit
  on bad value); defaults onto `ServerOptions`.
- **ServerOptions** ([src/server.ts](../../src/server.ts)): an `hlg?` config
  object, resolved in `toOptions` with the standard precedence
  (request > CLI default > model config > built-in), exactly like the existing
  sampling defaults.
- **Per-request**: an `hlg` object on `ChatRequest` (unknown fields are already
  tolerated), so it works over OpenAI `/v1/chat/completions`, Anthropic
  `/v1/messages`, and `/v1/responses` with no protocol-specific plumbing.
  Example:
  ```jsonc
  {
    "temperature": 0.7,            // becomes the mid gain m = 1/T
    "hlg": {
      "enabled": true,
      "pivot": "top", "pivot_offset": 6.0,
      "width": 4.0, "shoulder": 4.0, "toe": 6.0
    }
  }
  ```

## Correctness & evaluation

This is a novel path with **no oracle ancestor**, so it is gated by KL +
quality + diversity rather than parity — except for the degeneracy gates, which
*are* parity gates and must be bit-exact.

1. **Neutrality gate (bit-exact)** — `tests/hlg-sampling-parity.test.ts`:
   - flag-off ⟹ the sampler code path is byte-identical to today's (`makeSampler`
     unchanged when `hlg` absent);
   - `hlg` in *identity config* (`gain = 1`, rolloff off) reduces to the current
     sampler with `maxDiff === 0`;
   - `hlg` rolloff-off, `gain = 1/T` reduces to temperature `T` bit-exact.
   Run across **all four models** and **both lanes** (serial + batched) — the
   param plumbing differs per lane, the math does not.
2. **Monotonicity / ranking preservation** — property test over random logits:
   `g` never reorders tokens; argmax invariant; every pairwise ordering held.
3. **KL characterization** — reuse [src/eval/kl.ts](../../src/eval/kl.ts)
   `evaluateKlSelfFlag` (env lever off vs on) to *characterize* (not pass/fail)
   how far each knob moves the distribution from temperature-only. Output: a
   KL-vs-knob curve per model, recorded for the design log. The distribution is
   *supposed* to move; the point is to map the knob space, not to bound drift.
4. **Capability guardrail** — `bun scripts/eval.ts capability --candidate e4b`
   (and 12B, the reference target) with HLG on vs off. The six tasks
   (GSM8K / MMLU / IFEval / BFCL / HumanEval / HashHop) are accuracy-shaped, so
   they measure the **cost**: does shaping the distribution break reasoning or
   tool-calling? That is the guardrail HLG must not regress materially.
5. **Diversity lens (the benefit)** — the six tasks won't show the upside, since
   the whole point is mid-tone novelty. Add a small open-ended eval
   (`src/eval/tasks/diversity.ts`): distinct-n / self-BLEU / cross-sample
   entropy on a creative-prompt set, **HLG vs temperature matched to the same
   output entropy**. The thesis is confirmed iff, at equal entropy, HLG yields
   higher diversity without the tail-garbage temperature would import.
6. **Perf A/B** — a `bench-compat-vs-perf`-style env-lever A/B plus a
   `./benchmark.sh` row: decode tok/s + TTFT, on vs off, to show ~0 decode
   regression. Lands in [benchmarks/RESULTS.md](../../benchmarks/RESULTS.md) §3.

## Phasing (the "piece N" increments)

1. **Pure curve + neutrality tests** — `applyHlg(lp, params)` in `sampler.ts`,
   top-anchored pivot only; degeneracy + monotonicity tests green across all
   four models. (No flag wired yet — pure, fully-tested function.)
2. **Serial wiring** — CLI flags + `ServerOptions` + `toOptions`; live on the
   serial server; per-request `hlg`.
3. **Batched wiring** — gateway/scheduler sampler construction; batched
   neutrality test.
4. **Pivot modes 2 & 3** — entropy + median, behind `--hlg-pivot`.
5. **Eval + benchmark** — KL characterization, capability guardrail, diversity
   lens, perf A/B; set shipped defaults from the sweep; RESULTS.md row.
6. **Docs** — finalize this doc, the investigation write-up, PLAN/STATUS,
   server-config / server-api / README, and a memory note.

## Open questions / risks

- **Default knob values** are calibration-pending — set empirically by the
  Piece 5 sweep, not guessed. Initial exploration points: `c ≈ 6`, `w ≈ 4`,
  `β_h ≈ 4`, `β_t ≈ 6` nats; confirm or replace with measured values.
- **Pivot for very low-entropy distributions** (one token ~1.0): the curve has
  almost nothing to shape; verify it degrades gracefully to "near-greedy" rather
  than amplifying numerical noise in the tail.
- **HLG replaces top-p/top-k** (resolved, not a rail). When HLG is on it *is*
  the sampler — no top-p/top-k underneath; the toe is the smooth cousin of
  min-p and does the tail control. Open question is whether the soft toe
  suppresses the tail *enough* on a 262k vocab to match the hard cutoffs, or
  whether garbage leaks — exactly what the `hlg-compare` harness probes.
- **Does the benefit survive the capability tasks?** If HLG measurably helps
  diversity but dents GSM8K/BFCL, it ships default-off with a documented
  use-case (creative/open-ended), not as a global default — consistent with the
  project's default-off-flags ethos.

## Provenance — and why the source domain doesn't justify it

This is a **cross-domain transplant**. Nonlinear transfer functions are a mature
apparatus in signal and color encoding for reshaping a value distribution under
region-dependent constraints; a logit distribution is just another value
distribution, so the apparatus carries over. HLG (Hybrid Log-Gamma, ARIB
STD-B67 / ITU-R BT.2100) is the specific structure we lift — a gamma segment for
the lower range and a logarithmic segment for the upper range, joined at a
breakpoint — because its piecewise shape maps cleanly onto "boost the mids, roll
off the extremes."

The provenance is where the *structure* comes from; it is **not** the argument
for it. That a transfer function is standard practice in another domain says
nothing about whether it helps token sampling — that is decided only by
measurement (the KL characterization, the capability guardrail, and the
diversity lens in [Correctness](#correctness--evaluation)). The full empirical
write-up goes in `docs/investigations/hlg-sampling-investigation.md` once run.
