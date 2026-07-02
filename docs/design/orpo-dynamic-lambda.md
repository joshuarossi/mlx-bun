# Dynamic λ controller for ORPO (adaptive preference pressure)

**Status:** proposed (design only — not built). **Opened:** 2026-06-20.
**Reaffirmed + reframed by Josh 2026-07-01** (see "The band framing" below).
**Surface:** `src/train/loss.ts` (orpoMetrics/orpoLoss), `src/train/trainer.ts`
(orpoLoop, the λ config), the segmented ORPO classes in `src/train/segmented.ts`.

## The band framing (Josh, 2026-07-01 — the product statement)

> "Vary the lambda term based on the loss or another signal — maintain the
> interest inside a band: learn preference HARDER while you are still able to
> stay coherent. A self-stabilizing AND self-discovering hyperparameter, which
> optimizes the training to get as much preference as possible while not
> resulting in degeneracy."

That is the controller's contract in one sentence: **λ is not a hyperparameter
to tune, it is a process variable to control** — push preference pressure to
the maximum the model can currently bear (self-discovering), retreat on
confirmed coherence damage (self-stabilizing), and hold the system inside the
healthy band rather than at a fixed point. Everything below (phases, AIMD/PID,
displacement decomposition) is the mechanism for that contract.

**Interplay with `sft_scope` (landed 2026-07-01):** the default chosen-NLL is
now full prompt+response. The controller's displacement signal must key on the
**response-only `lw`** (which `orpoMetrics` computes for the odds ratio in both
modes) — full-scope NLL mixes prompt modeling into the level and would mask a
crushed `logp(chosen-response)`. Instrument both, control on response-only.

## Paper lens (2026-07-01): is this citable?

Closest prior: **β-DPO (arXiv 2407.08639)** — dynamic β for DPO, calibrated
per-batch from the reward gap. Ours differs on three axes worth claiming:
(1) **closed-loop trajectory control** (a controller tracking a non-stationary
optimum across the run) vs per-batch heuristic calibration; (2) the control
signal is **displacement-aware** — the (dLw, dLr) decomposition targets the
known ORPO/DPO failure mode directly (cf. likelihood displacement,
arXiv 2410.08847 "Unintentional Unalignment"); (3) **objective-agnostic**
actuator (ORPO λ, SimPO β/γ). The incremental P→PD→PID build IS the ablation
section. The claim to stake: *"the optimal preference pressure is
non-stationary, so a controller strictly dominates any fixed λ a sweep can
find — and a displacement-aware control law finds the coherence cliff without
a priori knowledge of it."* Referees will demand: ≥2 datasets, ≥2 model sizes,
the static-λ sweep as the baseline family (the controller must beat the BEST
constant, not λ=0.1), seeds, and the positive-control sanity run this doc
already specifies. Workshop/arXiv-preprint tier as a single-model study;
main-track needs the multi-model sweep.

## Motivation

ORPO's loss is `L = NLL(chosen) + λ·OR`. The two terms learn on different
timescales, and a **static λ** can't serve both:

- **The SFT/NLL half learns easily** — the model quickly raises `logp(chosen)`
  (fits the response *style*). Observed live: val loss falls steadily while
  preference accuracy/margin barely move.
- **The preference/OR half is hard** — on subtle data (UltraFeedback on a 1B) the
  model doesn't generalize "which of two plausible answers is better."
- **Over-weighting OR backfires** via **likelihood displacement**: the model widens
  the *relative* margin by **crushing `logp(rejected)`** (and sometimes dropping
  `logp(chosen)` too) rather than genuinely preferring chosen — degrading fluency.

A fixed λ either under-pressures the preference (λ too low → never leans on OR) or
over-pressures it (λ too high → displacement/degeneration). The hypothesis: an
**adaptive, displacement-aware λ** — low while SFT learns, ramped once SFT
saturates, backed off the moment displacement appears — can find a generalization
regime a static λ sails past. (Static λ tuning was the blunt version we rejected;
this is the targeted version.)

## Control signals (what we measure)

`orpoMetrics` (`loss.ts:1249`) already computes everything; we just don't surface it:

- **`lw`** = mean `logp(chosen)` (currently folded into `nll = mean(−lw)`).
- **`lr`** = mean `logp(rejected)` (currently only used inside the odds ratio).
- **`margin`** = mean log-odds (chosen vs rejected) — already emitted.
- **`accuracy`** = fraction `lw > lr` — already emitted.

The controller keys on the **decomposition of margin growth**:
- margin ↑ because **`lw` ↑** → *healthy* (genuinely preferring chosen).
- margin ↑ because **`lr` ↓** while `lw` flat/falling → *displacement* (the cheat).

So the load-bearing new instrumentation is **surfacing `lw` and `lr` separately**
per eval (not just `nll`/`margin`).

## The controller (state machine)

Runs at **each val eval** (every `stepsPerEval` steps) — val (`lw`, `lr`) is the
stable signal; per-step B=1 train metrics are too noisy to control on. Maintains a
short window of recent val (`lw`, `lr`, margin, accuracy).

```
state: { phase, lambda, window[] }   # lambda starts at LAMBDA_MIN
on each val eval (lw, lr, margin, acc):
  dLw = lw - lw_prev ; dLr = lr - lr_prev

  PHASE 1 — SFT warmup (lambda = LAMBDA_MIN, low):
    stay while the NLL is still improving (dLw > EPS_SFT, i.e. chosen logp rising).
    when dLw plateaus (|dLw| < EPS_SFT over K evals) → SFT saturated → PHASE 2.

  PHASE 2 — preference ramp:
    each eval, lambda += RAMP (cap LAMBDA_MAX), applying OR pressure —
    AS LONG AS chosen holds: dLw >= -EPS_DISP.
    if accuracy/margin respond (margin widening with dLw >= 0) → keep ramping.
    if displacement detected (dLw < -EPS_DISP, i.e. chosen logp dropping, or
       dLr << 0 with dLw <= 0) → PHASE 3.

  PHASE 3 — displacement backoff:
    lambda -= BACKOFF (floor LAMBDA_MIN) until chosen recovers (dLw >= 0),
    then hold (hysteresis) before considering another ramp.
```

Knobs (all tunable): `LAMBDA_MIN≈0.05`, `LAMBDA_MAX≈0.5`, `RAMP/BACKOFF≈0.05`,
window `K≈3` evals, `EPS_SFT`/`EPS_DISP` set from the observed val-`lw` noise scale.
Hysteresis (require K consecutive evals before a phase flip) prevents oscillation.

**Degeneration guard (hard stop):** if `lw` falls below its phase-1 starting value
by more than a threshold, freeze λ at `LAMBDA_MIN` and log — the model is paying for
margin with chosen's likelihood, which a backoff alone isn't recovering.

## Control-theory framing (PID / AIMD) — added 2026-06-23

The phase state-machine above is one instance of a more general and more honest
frame: **this is closed-loop control.** The **process variable** is the SFT signal
(NLL / `lw`), the **actuator** is the preference weight (ORPO's λ, *or* SimPO's
β/γ — the controller is objective-agnostic), and the **control law** is what maps the
measured degradation back to the actuator. Two laws worth naming:

- **AIMD** (additive-increase / multiplicative-decrease — TCP congestion control):
  ramp the preference up *gently* while the SFT is healthy, **slam it down hard** the
  moment degradation ("congestion") appears. Famously robust and forgiving of its own
  knobs. The PHASE-2 ramp / PHASE-3 backoff is essentially AIMD.
- **PID** decomposes the response into three terms, each fixing a failure the others
  can't:
  - **P (proportional · the level):** how degraded is `lw` *right now* → back off in proportion. (Leaves a steady-state offset.)
  - **D (derivative · the slope):** is degradation *accelerating* → a **leading indicator** that catches the helping→hurting **inflection before the level rises**, so you pull back *earlier* and leave less damage to heal. **Gotcha:** differentiating a noisy signal amplifies noise → use a *robust* slope (slope of the EMA, or a windowed regression), never raw step deltas. The slope is where most of the value is.
  - **I (integral · accumulated error):** the "missing letter." P leaves a chronic offset and D ignores it (flat slope at steady-state) → the model can settle hovering with a *small persistent* NLL elevation = quiet permanent SFT damage. I accumulates that residual and drives `lw` **back to its floor**. **Gotcha — integral windup:** if the actuator is pinned (λ at floor) while error persists, the integral piles up and **overshoots** on recovery → needs **anti-windup** (clamp/stop accumulating when saturated).

**Build it incrementally — P → PD → PID** — each term earning its place against an
*observed* failure of the simpler controller (P oscillates/offsets → add D; chronic
offset remains → add I with anti-windup). That's both good control practice and an
**ablation that writes the experimental section**, and it stops us from tuning three
gains blind.

**Why a controller beats a sweep (the real argument):** the optimal preference
pressure is **non-stationary** — fragile early (push less), robust late (push more) —
so **no fixed λ is optimal.** A sweep finds the best *constant*; the controller tracks
the moving target and finds the best *trajectory*, which strictly dominates. The pitch
isn't just "one run instead of six," it's "**beats any fixed value** a sweep could
find." (The displacement backoff is also why this is *more* than auto-tuning — it
targets the degradation signal directly.)

**Degenerate failure to guard (beyond the §degeneration hard-stop):** if the law backs
off too eagerly it **collapses the preference term to ~0 → you've trained pure SFT.**
The AIMD/PID balance must **favor pushing** (aggressive-ish increase, retreat only on
*confirmed* degradation), and target a small **safety margin below the cliff** rather
than the absolute max-bearable (the edge is fragile).

**Synergy with the diffusion frontier:** all of this is noise-robustness machinery for
controlling off a noisy process variable — so it transfers *especially* well to a
diffusion LM, where the likelihood is a stochastic ELBO (even noisier). See
[orpo-base-uf-experiment-and-directions.md](../investigations/orpo-base-uf-experiment-and-directions.md) §6.7.

## Wiring

1. **Instrument (small):** add `lw`, `lr` to `orpoMetrics`'s return + the trainer's
   `metric` emit (train and val). `pref-control.ts` / `metrics.json` log them so the
   controller (and our plots) can see the decomposition.
2. **Make λ dynamic:** today `cfg.orpoLambda` is a constant threaded into
   `orpoLoss(model, batch, cfg.orpoLambda, …)` and **baked into the segmented ORPO
   classes' constructors** (`new SegmentedBackwardOrpo(model, lora, ranges,
   cfg.orpoLambda, …)`). Change to a **mutable λ source**:
   - simplest: a `{ value: number }` box (or a getter) passed instead of the scalar;
     the loss / segmented step reads `lambdaRef.value` each step.
   - the segmented classes expose a `setLambda(x)` (or read the ref) so the
     constructor-baked constant becomes a live field.
3. **The controller** lives in `orpoLoop` (`trainer.ts`): after each val eval, feed
   the val (`lw`, `lr`, margin, acc) to `updateLambda(state)` and write the new λ
   into the ref. Log every λ change (`· λ 0.10 → 0.15 (SFT saturated, ramping)`).
4. **Off by default:** gate behind a config flag (`orpoLambdaSchedule: "static" |
   "adaptive"`); static = today's behavior, exact.

## Experiment design (how we validate it)

Head-to-head, **same data / seed / everything else**, on the from-base UF setup:
- **Arm A:** static λ=0.1 (the current run — the baseline).
- **Arm B:** adaptive λ (this controller).

Compare:
- **val accuracy + margin** trajectories (does B clear the noise floor / widen
  margin where A stalls?);
- **`lw` trajectory** (does B avoid displacement — `lw` non-decreasing — where a
  high static λ would crater it?);
- the **downstream** numbers: Exp-1 capability x2 and Exp-2 win-rate (does B's model
  actually win more head-to-head?).

Success = B generalizes measurably better (val acc clears ~0.55 with margin lifting,
and/or Exp-2 win-rate > A's) **without** degeneration (`lw` holds). Null result is
also informative: "even adaptive λ can't beat the 1B capacity ceiling on UF."

## Open questions / risks

- **Cadence:** controlling on val every `stepsPerEval` may be too coarse (few control
  steps per run). Option: a cheaper, more frequent "control eval" on a small fixed
  probe set distinct from the reported val set.
- **Confounds the replication claim:** an adaptive-λ result is no longer "standard
  ORPO" — it's our method. Keep Arm A (static 0.1) as the honest paper-replication;
  Arm B is the "can we do better" research arm. Report both.
- **Tuning the controller's own knobs** risks the same trap (we'd be tuning a tuner).
  Mitigate: set EPS thresholds from observed noise scale, not by hand-fitting to one
  run; validate the controller on the *positive control* (prefer-uppercase) first —
  it should ramp λ early (SFT saturates fast) and never trip displacement.

## References

- `src/train/loss.ts:1249` `orpoMetrics` (computes `lw`,`lr`,`nll`,`or`,`accuracy`,`margin`).
- `src/train/trainer.ts` `orpoLoop` (λ config, val emit), `DEFAULT_TRAIN_CONFIG.orpoLambda`.
- `src/train/segmented.ts` segmented ORPO classes (λ baked in constructor).
- `scripts/experiments/pref-control.ts` (trajectory logging — extend with `lw`,`lr`).
- Context: [[opssdpa-dk-vjp-bug]] (validate grads vs autograd), the dynamic-λ
  discussion + the live from-base UF val trajectory (2026-06-20).
