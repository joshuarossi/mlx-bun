# Investigation: HLG sampling — a piecewise tone curve on the logits

*2026-06-14. Question: can the structure of a piecewise nonlinear transfer
function (HLG, the HDR transfer function) be transplanted onto a logit
distribution as a sampling method, and if so, where do you place its pivot
(middle grey)? Design contract: [docs/design/hlg-sampling.md](../design/hlg-sampling.md).
Code: `src/sampler.ts` (`applyHlg`, `makeSampler`). Harness:
`scripts/hlg-compare.ts`. Model under test: `gemma-4-e4b-it-OptiQ-4bit` on the
M4 Pro.*

> **Outcome.** Two passes. **Pass 1** (a *parametric* HLG-shaped curve, §1–9):
> top-anchored pivot holds; entropy/median collapse into word-salad because a
> permissive (lifting) toe inflates the 262k-vocab tail. **Pass 2** (the *literal*
> HLG transfer system, then the user's exact `HLGShaper`, §10): the full chain
> transplants onto sampling, but only with **two adaptations the source domain
> doesn't need** — (1) **windowed-anchor input** (LM logits are a spike-plus-tail,
> not an image's tonal spread, so min-max over the vocab collapses every candidate
> into the shoulder and elevates deep-tail junk in the mid), and (2) **the toe
> inverted** (a sampler crushes shadows; HLG describes them). With those, the
> `HLGShaper` is a **working, coherent replacement sampler** (e4b, W=5 /
> out_scale=18) exposing **four orthogonal knobs** — `s_m` (mid sharpness) · `A`
> (shoulder / confidence) · `x_floor`+toe (tail gate) · `L_W` (global γ) — where
> temperature gave one. Method note that recurs throughout: **distinct-2 rewards
> garbage**; read the text.
>
> **Final verdict (§14, after TWO premature verdicts were each corrected).** Pass 1
> concluded "control, not dominance" — a sweep-range + metric artifact (A swept
> only [0.2,0.8]; distinct-2 at small N). Widening every knob (runL) + self-BLEU
> **+ a semantic embedding metric** at N=10 (runM) + **reading the text** (runN)
> *looked like* a reversal: at A=0.01, s_m=0.05, self-BLEU 0.783 vs 0.672, text
> verified genuinely diverse and correct. **But the fresh-seed repeat (runO) did
> not replicate it** — the default's own self-BLEU swung +0.083 across seeds and at
> seed 5000 edged above the HLG cell, so N=10 variance (~0.08) swamps the effect.
> **Honest landing: HLG's loose-corner cells are *comparable* to the default on
> diversity at equal coherence — within N=10 noise — with at most a small,
> consistent embedding edge below the measurement resolution. Neither "dominance"
> nor "negative" survives; it's a wash at this N.** Meta-result: the fresh-seed
> repeat caught BOTH premature verdicts within one run each — sweep wide, use ≥2
> metrics, repeat seeds, read the text.

## TL;DR

- **The transplant is real and cheap.** One piecewise curve (`applyHlg`),
  model-agnostic, O(V) per token, replaces the temperature scaling step. Bit-exact
  degeneracy to temperature is the safety anchor; flag-off is byte-identical.
- **HLG is a replacement sampler**, not a layer: `if (hlg.enabled)` → the curve
  is the whole post-logits step; `else` → top_p, top_k, temperature (unchanged).
- **Pivot = top-anchored.** Of the three middle-grey methods, only top-anchored
  survives as a drop-in replacement. Entropy and median place the pivot near the
  peak on confident distributions, dumping the whole distribution into the
  lifting toe → near-uniform over 262k tokens → garbage.
- **Mild positive signal where it should appear:** HLG raises lexical diversity
  on open-ended prompts (brainstorm 0.78 → 0.88, continuation 0.75 → 0.86) while
  leaving the confident factual answer untouched (0.30). The concrete win: it
  broke e4b out of always opening the paperclip list with "SIM Card Ejector".
- **Method lesson:** distinct-2 rewards incoherence; entropy/median scored
  ~1.0 *because* they were broken. Diversity metrics must be paired with a
  coherence gate (perplexity / NLL under the base recipe).

---

## 1. The idea — a cross-domain transplant

Temperature is a single global slope on the logits (`logit / T`). Its limitation
is a coupling: the only way it loosens the model's grip on the top token is by
raising `T`, which simultaneously lifts the tail. One number can't move two
regions independently.

Nonlinear transfer functions in signal/color encoding solve the analogous
problem with a **piecewise** curve that shapes the low, middle, and high range
under separate constraints. HLG (Hybrid Log-Gamma, ARIB STD-B67 / ITU-R BT.2100)
is the specific structure lifted here: a gamma segment for the lower range and a
log segment for the upper range, joined at a breakpoint. A logit distribution is
another value distribution, so the apparatus carries over. Whether it *helps* is
an empirical question — settled by measurement in this domain, not by the
structure's pedigree in its original one.

Mapped onto the three regions of a token distribution:

- **High-probability region** (confident tokens) → **shoulder**: roll the slope
  off so the top compresses toward its neighbours ("won't be so fixed on that
  answer").
- **Mid-probability region** (novelty/interest) → **gain**: control the slope.
- **Low-probability tail** → **toe**: shape it smoothly rather than hard-clipping
  (top_p/top_k) or inflating it (high temperature).

---

## 2. The curve

Operate in log-probability space. Let `ℓ_i` be each token's log-prob and `μ` the
pivot. With centered coordinate `z = ℓ_i − μ`, remap with a C¹ log-toe /
linear-mid / log-shoulder curve:

```
        ⎧  −m·w − m·β_t·ln(1 + (−z − w)/β_t)     z < −w     (toe / shadows)
 g(z) = ⎨   m·z                                  |z| ≤ w    (gain / mids)
        ⎩   m·w + m·β_h·ln(1 + ( z − w)/β_h)     z >  w     (shoulder / highlights)
```

Output logits `ℓ'_i = g(z_i)`, then the existing categorical draw. Properties:

- **Monotone in ℓ** ⇒ ranking-preserving (argmax invariant). It's a contrast/tone
  operation, not a re-ranker.
- **Slope** is `m` at the pivot and decays as `m·β/(β + d)` a distance `d` past
  each knot — continuous, always positive.
- **Degeneracy = safety anchor:** `m=1`, rolloff off ⇒ `g(z)=z` (identity,
  bit-exact); rolloff off, any `m` ⇒ `g(z)=m·z` (temperature `T=1/m`, bit-exact).
- **`-inf` safe:** a masked token lands in the toe branch and stays `-inf`.

Knobs (all in nats): `gain` m (mid slope; folds from temperature as m=1/T by
default, explicit override allowed), `width` w (mid half-width), `shoulder` β_h,
`toe` β_t, plus the pivot and its offset.

### The critical, non-obvious property: the toe is *permissive*

"Don't crush the blacks" means the toe slope is **less** than linear, so deep-tail
tokens are pulled *up* toward a floor at `−m·w` rather than suppressed. This is
the opposite of top_p/top_k (hard cut) and gentler than temperature. It is the
mechanism behind the central finding below: as a replacement for the hard
cutoffs, the toe under-suppresses the tail, and only the pivot's distance below
the peak keeps the top token dominant.

---

## 3. Architecture — a replacement sampler

`makeSampler` (`src/sampler.ts`) branches:

```
if (hlg.enabled)  → scaled = applyHlg(lp, params)        // the whole methodology;
                                                          // toe does the tail control
else              → top_p, then top_k, then mulScalar(1/T) // exactly what we used to do
```

Mutually exclusive. When HLG is on, top_p/top_k are **not** applied — the smooth
toe is their replacement, not a layer on top. Greedy (`temperature 0`) returns
argmax in both branches (a monotone curve can't move the argmax), so HLG is a
no-op there by construction. Flag-off (`hlg` undefined) is byte-identical to the
prior sampler.

> Evolution note: earlier experiment runs (0, A, B below) were built before the
> clean replacement restructure — they either passed no cutoffs (so HLG ran
> alone by accident) or kept top_p/top_k under HLG (layering). Run C is the first
> true replacement test and is where the architecture was finalised.

---

## 4. Three pivots (middle grey)

The same curve, centered three ways (`hlgPivotBase` in `src/sampler.ts`), applied
to the full logprob vector:

1. **`top`** — μ = ℓmax − `offset`. Middle grey a fixed number of nats below the
   peak. One `max` reduction.
2. **`entropy`** — μ = Σ p·ℓ = −H. The distribution's center of mass in tonal
   space ("auto-exposure"). One dot product.
3. **`median`** — μ = the logprob at the 50% cumulative-mass boundary
   ("auto-levels" / histogram median). Reuses the sort top-p already does.

---

## 5. Implementation status

- **Piece 1** — pure `applyHlg(lp, params)` + degeneracy/monotonicity/`-inf`
  tests. `src/sampler.ts`, `tests/hlg-sampling.test.ts`.
- **Piece 2** — wired into `makeSampler`; CLI flags `--hlg-sampling` +
  `--hlg-width/-shoulder/-toe/-pivot-offset`; `ServerOptions.hlg`; per-request
  `hlg` object on `ChatRequest` resolved by `resolveHlg` in `toOptions`.
- **Piece 4 (brought forward)** — all three pivot modes + the explicit `gain`
  override; `HlgConfig.gain`/`pivot` widened. `--hlg-pivot` CLI flag still TODO.
- **Replacement architecture** — finalised (Section 3).
- Tests: **14/14 green**, tsc clean. Pure (no weights): bit-exact degeneracy to
  temperature/identity, monotone + ranking-preserving, `-inf` safe, three pivots
  monotone+finite+distinct, wiring neutrality (identity config ≡ plain
  temperature, rolloff-on diverges).

Harness: `scripts/hlg-compare.ts` — runs a fixed prompt set × sampling patterns,
K samples each, reports distinct-2 (after stripping the shared chat-template
prefix) + unique-count + length, and prints the samples. The model's recommended
recipe is read from its `generation_config.json` (e4b: temp 1.0 · top_p 0.95 ·
top_k 64).

---

## 6. Experiments

All on `gemma-4-e4b-it-OptiQ-4bit`, K=4 samples/cell (greedy n=1), maxTokens 80,
seeds 1234–1237. distinct-2 = unique bigrams / total bigrams pooled across the K
samples; higher = more lexically varied (**but see the garbage caveat in Run C**).
Full transcripts in the appendices.

### 6.1 Run 0 — the wrong baseline (Appendix A)

Patterns: `greedy`, `temp-0.7`, `temp-1.2`, `hlg-default`, `hlg-rolloff` —
**temperature alone, no top_p/top_k, and not the model's recommended temp.** This
was wrong on two counts (the recommended recipe gates the tail with top_p
0.95/top_k 64, and the recommended temp is 1.0, not 0.7/1.2). distinct-2 here was
computed *without* the prefix strip, so it is not comparable to later runs.

| prompt | greedy | temp-0.7 | temp-1.2 | hlg-default | hlg-rolloff |
|---|---|---|---|---|---|
| creative | 0.97 | 0.85 | 0.95 | 0.88 | 0.88 |
| brainstorm | 0.97 | 0.69 | 0.59 | 0.63 | 0.68 |
| factual | 1.00 | 0.30 | 0.30 | 0.30 | 0.30 |
| reasoning | 0.87 | 0.28 | 0.34 | 0.30 | 0.34 |
| continuation | 0.97 | 0.84 | 0.87 | 0.83 | 0.83 |

What it taught: the prompts + temp ≤ 1.2 never put e4b into HLG's target regime
(confident prompts collapse everything, including temp-1.2; open prompts give
temp-1.2 free diversity with no visible downside). And the baseline must be the
model's own recipe, not an arbitrary temperature. Both corrected after.

### 6.2 Run A — recommended control; layered vs replace (Appendix B)

Patterns hold the recommended recipe (temp 1.0 · top_p 0.95 · top_k 64) and vary
the curve. `rec+hlg` = recipe **with** HLG layered on top of top_p/top_k.
`hlg-replace` = recipe temp, **no** cutoffs, HLG's toe doing tail control.
distinct-2 here and after is prefix-stripped.

| prompt | recommended | rec+hlg | hlg-replace |
|---|---|---|---|
| creative | 0.90 | 0.89 | 0.90 |
| brainstorm | 0.78 | **0.88** | **0.88** |
| factual | 0.30 | 0.30 | 0.30 |
| reasoning | 0.28 | 0.32 | 0.34 |
| continuation | 0.75 | **0.84** | **0.86** |

The positive signal first appears: HLG raises open-ended diversity (brainstorm
+0.10, continuation +0.09–0.11) and leaves factual locked at 0.30. Concrete win —
`rec+hlg` broke the "SIM Card Ejector" rut on item 1: *"**Improvised Zipper
Pull:** If the tab or pull on a zipper breaks off…"*. Cost first appears in
`hlg-replace`: one frayed tail token (*"a cartographer's stain—**aving
purpose**"*).

### 6.3 Run B — gain variants (Appendix C)

Recipe held fixed (top_p/top_k kept); HLG layered with explicit gains and varied
edges, pivot top. Confirms the open-ended diversity gain is robust across knobs
and never disturbs factual.

| prompt | standard | hlg-rolloff | hlg-midboost | hlg-soft | hlg-full |
|---|---|---|---|---|---|
| creative | 0.90 | **0.96** | 0.90 | 0.94 | 0.92 |
| brainstorm | 0.78 | **0.88** | 0.82 | **0.88** | **0.88** |
| factual | 0.30 | 0.30 | 0.30 | 0.30 | 0.30 |
| reasoning | 0.28 | 0.31 | 0.32 | 0.31 | 0.32 |
| continuation | 0.75 | **0.82** | 0.83 | 0.84 | **0.85** |

### 6.4 Run C — the pivot comparison, as a true replacement (Appendix D) — DECISIVE

`standard` = recipe. `hlg-top` / `hlg-entropy` / `hlg-median` = **replacement**
sampler (no top_p/top_k), one curve (gain 1.0, width 3, shoulder 4, toe 4), only
the pivot placement changes (offset 6 for top; 0 for entropy/median).

| prompt | standard | hlg-top | hlg-entropy | hlg-median |
|---|---|---|---|---|
| creative | 0.90 | 0.95 | 0.99 ⚠️ | 1.00 ⚠️ |
| brainstorm | 0.78 | 0.91 | 0.99 ⚠️ | 1.00 ⚠️ |
| factual | 0.30 | 0.55 | 0.99 ⚠️ | 1.00 ⚠️ |
| reasoning | 0.28 | 0.35 | 1.00 ⚠️ | 0.99 ⚠️ |
| continuation | 0.75 | 0.88 | 1.00 ⚠️ | 1.00 ⚠️ |

⚠️ = the score is **garbage**, not diversity.

- `hlg-top` is coherent and varied. Continuation #3: *"…how it acts like a coral
  reef—brilliantly shaped in its fleeting, vibrant bloom, only to be slowly
  colonized and ultimately obscured by the perpetual, grinding algae of the
  new…"*
- `hlg-entropy` continuation #1: *"'The Aideang strane簿 sche tup de uman tuturí
  namiatório hidadierá escult প্রশ্ন p a'i nto'…"*
- `hlg-median` factual #2: *"The जैसे overtakehouses仰рачи倾olver漏洞格局 ᵛ<br
  Zweigen graisseuse.apparent échelle saisonAlloc Lieu en cours rotation follicle
  orbit 結構"*

---

## 7. Findings

### 7.1 The pivot is top-anchored

As a replacement sampler, **only the top-anchored pivot is viable**. Entropy and
median collapse to multilingual token-salad on every prompt.

### 7.2 Why — the toe permissiveness × pivot offset (the mechanism)

The toe lifts the deep tail toward a floor at `−m·w` instead of suppressing it. In
replacement mode (no hard cutoffs) the only thing keeping the top token dominant
is how far below the peak the pivot sits, because that sets where the toe floor
lands and therefore the total tail mass over a 262k vocab. With the Run C params
(m=1, w=3, β_t=4):

- **`hlg-top`**, μ = ℓmax − 6: top token maps to g ≈ +5.2, a deep-tail token
  (ℓmax − 20) to g ≈ −8.3 → gap ≈ 13.5 nats. Tail mass ≈ 262k·e^−13.5 ≈ **0.4×**
  the peak → top stays dominant → coherent.
- **`hlg-entropy` / `hlg-median`**, μ ≈ ℓmax (both land near the peak on a
  confident distribution): the entire distribution falls into the toe; a deep-tail
  token maps ~9.6 nats below the top → tail mass ≈ 262k·e^−9.6 ≈ **17×** the peak
  → near-uniform over the vocab → garbage.

The 6-nat offset is the difference between tail-mass 0.4 (coherent) and 17
(salad). The adaptive pivots have no equivalent "push the floor down" lever, so
they place middle grey too high to survive a replacement. (They would likely
behave layered on top of top_p/top_k, or given their own downward offset — future
work, not a drop-in replacement.)

### 7.3 distinct-2 rewards garbage

Entropy/median scored ~1.0 distinct-2 *because* they emit random unique tokens.
Lexical-diversity metrics reward incoherence and must be paired with a coherence
gate (e.g. NLL/perplexity of the generation under the model's standard recipe, or
a fraction-of-in-vocab/in-language check). This directly shapes the Piece 5
diversity lens.

### 7.4 The positive signal (the thesis, mildly confirmed)

Across Runs A and B, HLG consistently raises open-ended diversity (brainstorm
0.78 → 0.88, continuation 0.75 → 0.86) while leaving the confident factual answer
at 0.30 — more variation where it helps, none where it shouldn't. The decoupling
the thesis predicts does appear; it is mild at default knobs.

### 7.5 Costs / caveats

- Even `hlg-top` leaks a trickle (stray "ten正常的 yards", "schuman") — the toe is
  leakier than hard cutoffs.
- `hlg-top` loosened the factual answer more than desired (0.30 → 0.55, "the
  planet' adorable axis"). A confident answer probably shouldn't be varied at all.
- The confident prompts (factual/reasoning) never trigger temperature's
  garbage-tail failure mode on e4b, so this model can't showcase the *full*
  decoupling advantage — a less confident model or longer generations might.

---

## 8. Current state

- Curve in place, replacement architecture finalised, three pivots implemented +
  tested (14/14 green, tsc clean).
- Pivot question answered: **top-anchored**.
- Harness (`scripts/hlg-compare.ts`) reusable and reads each model's recommended
  recipe.

---

## 9. Next steps

1. **Shape the toe** (the "shape the pieces" step): on the top-anchored pivot,
   sweep `β_t` (smaller = harder tail suppression) and the offset `c` to stop the
   residual leak without killing the open-ended diversity gain. This is the
   calibration that sets the shipped default.
2. **Coherence-gated diversity metric** for Piece 5: distinct-n + an NLL/perplexity
   gate so garbage can't win. Add as `src/eval/tasks/diversity.ts`.
3. **Capability guardrail**: `bun scripts/eval.ts capability` with the chosen
   top-anchored config vs off — confirm GSM8K/BFCL/etc. don't regress.
4. **Decide entropy/median's fate**: either retire them for replacement use, or
   give them a downward offset / pair them with top_p/top_k and re-test.
5. `--hlg-pivot` CLI flag (the last bit of Piece 4).
6. Batched neutrality test (Piece 3) — plumbing already live via the shared
   sampler.

---

## 10. Pass 2 — the full HLG transfer system → the working HLGShaper

Pass 1 used an HLG-*shaped* parametric curve. Pass 2 implemented the **literal**
HLG system (BT.2100) and then the user's exact `HLGShaper`, end-to-end. Code:
`src/sampler.ts` (`applyHlgOetf`, `applyHlgEotf`, `applyHlgPipeline`,
`applyHlgShaper`). All A/B against the model's **default recipe, untouched** (the
only thing taken from the standard side); the HLG side is a full **replacement**
(no temp/top_p/top_k). Runs D–G in `hlg-runs/`.

**The arc, and what each step taught:**

1. **Literal OETF, replacement** (runD). `E' = √(3E)` below 1/12, `a·ln(12E−b)+c`
   above; sample ∝ V. **Semi-garbage.** The √ toe is HLG's *precision* curve — it
   **lifts** the tail (√ of 1e-6 is 1e-3); over 262k tokens that floods the draw.
2. **EOTF (decode) vs OETF (encode)** (runE). The inverse-OETF low branch `E'²/3`
   **squares the tail down** — coherent where the OETF flooded. So the *direction*
   matters, and the **OOTF on a grayscale (single-"pixel") distribution reduces
   to `E^γ` = temperature** (no colour channels for luminance to couple), with
   `γ = 1.2+0.42·log10(L_W/1000)`. The "system-level" part has no sampling analog.
3. **Full pipeline `α·E'^γ`** (runF predecessor). As pure logits with `α=5` over
   262k → near-uniform (the flat floor outweighs the top): `α` must exceed
   `ln(vocab) ≈ 12.5` just for the top to win.
4. **The exact HLGShaper** (runF/runG). min-max input → still garbage, but
   *prompt-dependent* this time, with coherent fragments fighting through. Cause:
   **min-max over the 262k vocab collapses every real candidate into the shoulder**
   (`x ≥ 0.9`, log-compressed together) while the **mid band `s_m` elevates is
   tokens 15–22 nats below the top = noise**. The curve was fine; the *signal* was
   wrong.

**The two adaptations the source domain doesn't need** (both found empirically):

- **Windowed-anchor input** instead of min-max: `x = clamp((ℓ−ℓmax)/W + 1, 0, 1)`.
  The top `W` nats of real candidates span the curve; deeper tokens clamp into the
  toe. (LM logits are a spike-plus-tail, not an image's tonal spread.)
- **The toe inverted**: a **cubic** `e·x³+f·x²` that suppresses to 0, not HLG's
  `√` that lifts. (A sampler crushes shadows; HLG describes them.)

**Result (runF/runG).** With `W=5, out_scale=18` the HLGShaper is a **working,
coherent replacement sampler** — vivid, varied, factually/arithmetically correct,
no salad (e.g. continuation: *"…it doesn't archive; it re-weaves… the vibrant
threads of joy are often knotted with the dull grey of forgotten anxiety…"*).
Comparable to the default recipe on both coherence and diversity.

**Knob sweep (runG).** The four orthogonal knobs are live — `s_m` (mid sharpness),
`A` (shoulder/confidence), `x_floor`+toe (tail gate), `L_W` (global γ) — **where
temperature gave one.** But the **coherent slice of that 4-D space is narrow**:
loosening toward more diversity (`W=7, out_scale=13, A=0.6`) tipped straight back
into garbage, because a *smooth* tail over 262k stays coherent only under
aggressive gating (nothing hard-cuts like top-k). So the chain *works*, but the
sweep did **not** yet show it beating temperature on diversity.

**Open / next.** Probe the corner the loose run missed: keep the **toe/x_floor
gate aggressive** (tail dead) while loosening **A + out_scale** (flatten the top,
spread the survivors) — decoupling "kill the tail" from "loosen the top," the
original thesis. Plus a coherence-gated diversity metric (distinct-n is useless —
it scores the salad ~1.0). Default stays **off**; this is a novel knob, never a
silent change to the sampler.

---

## 11. Pass 3 — fencing the exposure axes (clean single-variable sweeps)

The runG sweep was confounded: B-sharp→B-loose moved **three** knobs at once
(`W` 5→7, `out_scale` 18→13, `A` .35→.60), so its collapse couldn't be
attributed. Two fixes made the knobs separable:

**Decouple `out_scale` from `W`.** It had been hand-retuned (12→18) when `W`
went 10→5 — a coupling that confounds every comparison. Now `out_scale`
**auto-derives** so the top-1-to-reference final-logit gap equals a fixed
`target_gap`, *independent of W* (the reference token sits `ref_gap` nats below
the top; its post-shape value is the scalar curve evaluated in JS — no device
cost). Calibrated so `W=5 ⇒ out_scale≈18` (the known-good); it rises to ≈35 at
W=8 to hold the same effective sharpness. `W` is now a clean 1-D variable.

**The factual prompt is the canary** — it has the sharpest spike-to-tail
structure, so it breaks last; read it for the *first junk-token position*, not
just pass/fail.

**W-sweep (runH; W ∈ {4..8}, all else fixed at A=.35 / s_m=.7 / L_W=1200 /
out_scale auto):**

| W | out_scale | factual canary |
| --- | --- | --- |
| 4 | 15.0 | **junk** (sample 2 breaks at word 3) — below the floor |
| 5 | 18.3 | clean ×3 |
| 6 | 23.6 | clean ×3 |
| 7 | 29.4 | clean ×3 |
| 8 | 35.4 | clean ×3 |

- **Bad wall at W=4, basin W=5–8.** The cliff is a *floor* (too-narrow window),
  not a high-W ceiling. Within the basin, diversity is **nearly constant** (same
  ~3 creative openings / continuation framings at every W) because auto-`out_scale`
  holds sharpness fixed. So **`W` is a coherence-floor knob, not a diversity
  knob** — it sets *which* candidates are eligible, not how spread the draw is.
- The W-sweep left two suspects for the runG (B-loose) collapse (`A` and
  `out_scale` both also moved). The **A-sweep (runI; A ∈ {.20..​.60}, W=6 fixed,
  out_scale auto)** resolves it: the **factual canary is clean at every A,
  including `A=.60`**. So neither `W` nor `A` killed B-loose — **by elimination
  the killer was the manually-set `out_scale=13`** (< half the ~29 the
  auto-derivation gives W=7). The decoupling wasn't just *a* confound; it was
  *the* one. (This corrects an earlier draft that blamed `A`.)

**Corrected knob model** (after fencing W and A):
- `out_scale` / `target_gap` = **sharpness — the load-bearing knob** (too low →
  garbage, as in B-loose; now auto-derived → robust) and **the diversity lever**.
- `W` = **coherence floor** (bad wall at 4; robust ≥ 5).
- `A` = **robust across .20–.60** — modulates framing subtly, does NOT break
  coherence. *Not* the dangerous knob after all.
- `s_m`, `L_W` — untested.

With `W` and `A` both fenced as wide basins, the shaper is **robust, not a
knife-edge** — the runG "narrow regime" was the `out_scale` confound. Temperature
collapses all of these into one knob; here they separate. The single axis that
decides whether the curve beats temperature on diversity is **`target_gap`** (the
sharpness lever), swept next — canary-gated, at fixed W=6 / A=.35.

---

## 12. The automated knob map — and the verdict

`scripts/hlg-map.ts` — two-stage (cheap factual-canary **coherence** gate →
**diversity** on survivors only, so garbage can't win), per-knob 1-D sweeps from
the known-good base, every cell scored against the **default recipe** as the
diversity reference. runJ / `hlg-map.json`. Coherence = non-Latin letter ratio
(the salad signature); ACCEPTABLE < 1% on both the canary and the open prompts.

Default recipe reference: **diversity 0.87, junk 0.0%.**

| knob | acceptable range | diversity across band | role |
| --- | --- | --- | --- |
| `W` | **[5, 8]** (wall ≤4) | 0.80 → 0.72 | coherence floor |
| `A` | **[0.2, 0.8]** (no cliff) | ~0.79 (0.73 high) | near-inert |
| `target_gap` | **[12, 20]** (cliff ≤10) | 0.79 → 0.69 | coherence floor + sharpness |
| `s_m` | **[0.4, 1.3]** (no cliff) | flat 0.78–0.80 | near-inert |
| `L_W` | **[50, 4000]** (no cliff) | ~0.79 (0.71 at 4000) | near-inert |

**Verdict (conclusive):**

1. **No acceptable cell beats the default.** The shaper caps at ~**0.80**
   diversity; the default is **0.87** — at the same zero junk. Across the entire
   five-knob space the HLG curve is consistently *less* diverse than
   temperature+top_p+top_k while coherent.
2. **Only `W` and `target_gap` do anything, and both are coherence *gates*, not
   diversity dials.** `A`, `s_m`, `L_W` are near-inert across their whole valid
   range. So "four orthogonal controls where temperature gave one" doesn't
   materialise — it's one gate (sharpness/window) plus three inert knobs, and the
   only way to move diversity is off the cliff into garbage.
3. **Why the default wins:** a hard tail-cut (top_p/top_k) *removes* the tail, so
   you can be loose on the ~64 survivors without garbage. A smooth curve must
   keep the tail gated by sharpness, and that same gating caps how loose the top
   can get — the hard cut is strictly more diversity-efficient. And the default
   already keys off the distribution's own entropy (peaked→decisive, broad→loose)
   via top_p — the adaptive behaviour the curve was reaching for, done better.

**Bottom line.** The HLG transfer system transplants onto sampling and yields a
*working, coherent* replacement sampler; the cross-domain mapping is sound and
the two required adaptations (windowed anchor, inverted toe) are real findings.
But it does **not** beat a well-tuned temperature+cutoff recipe — equal-or-less
diversity at equal coherence, everywhere in the mapped space.

## 13. Frontier probe — better metric + interactions (the definitive landing)

The §12 map has two blind spots: distinct-2 is lexical/noisy at small N, and every
sweep is one-knob-at-a-time from one base (so it cannot see a B-loose-type *joint*
failure). `scripts/hlg-frontier.ts` closes both — **self-BLEU on the divergent
region at N=10** (diversity = 1 − self-BLEU), over a curated set: the per-knob
diversity edges **plus** the `target_gap×W` / `target_gap×A` corners. runK /
`hlg-frontier.json`. Default reference: **diversity 0.672.**

| cell | diversity (1−selfBLEU) | canary |
| --- | --- | --- |
| **default** | **0.672** | clean (reference) |
| tg12 × A.2 | 0.605 | clean (best HLG) |
| tg=12 | 0.570 | clean |
| base / Lw50 / sM1.3 | ~0.53 | clean |
| W=5 / A.20 / tg12×W8 | ~0.50 | clean |
| tg12 × A.8 | 0.470 | clean |
| **tg12 × W5** | — | **REJECT 8.5%** |
| **tg12 × W5 × A.2** | — | **REJECT 4.1%** |

1. **The sharper metric widens the gap — but reveals the real gradient.** Lowering
   `target_gap` (15→12) and `A` (.35→.2) genuinely raises diversity (0.525 → 0.570
   → 0.605) — the gradient distinct-2 flattened. So the knobs *do* control
   diversity. But the ceiling is **0.605 vs default 0.672** (~10% gap), consistent.
2. **The interaction probes caught a joint failure the marginal map structurally
   could not.** `tg=12` alone is clean, `W=5` alone is clean, but **`tg12 × W5`
   rejects (8.5% junk)** — so the "valid ranges" are **not** an independent box
   `W∈[5,8] × tg∈[12,20]`; they're a **coupled manifold** (low target_gap needs a
   *wider* W: tg12×W8 clean, tg12×W5 not). Exactly the B-loose-type joint failure
   the one-at-a-time map can't see.

**Final, rigorous verdict.** HLG sampling gives **finer, decomposed control over
the coherence/diversity tradeoff, but does not dominate temperature on the
frontier** — its reachable diversity sits strictly inside the default's, and
pushing to the edge crosses a coupled coherence cliff. A true, useful, publishable
**negative-but-informative result** — control, not dominance.

---

## 14. Reversal — wide ranges + semantic metric + text verification → DOMINANCE

The §12/§13 "negative" was **premature**, from the two methodology gaps the user
flagged: (a) sweep ranges too narrow (A ∈ [0.2,0.8] never reached the loose
extreme where the shoulder actually engages), and (b) distinct-2 is noisy at
small N. Fixing both overturns the verdict.

**Wide-range map (runL):** every knob swept across orders of magnitude — and
**every knob breaks somewhere** (so each does something): W low (~5),
target_gap low (~12), L_W low (γ→0), A **high** (~100 → garbage), s_m **high**
(~4 → curve goes non-monotonic). The loose extremes the narrow sweeps skipped
(A=0.01, s_m=0.05) approach/match the default — the cells that mattered.

**Frontier + semantic metric (runM):** N=10, self-BLEU (lexical) + **embedding**
(1 − mean cosine of mean-pooled LM hidden states, semantic) + distinct-2, on the
loose-edge cells. Default reference: self-BLEU 0.672, emb 0.136.

| cell | self-BLEU | emb | distinct2 |
| --- | --- | --- | --- |
| default | 0.672 | 0.136 | 0.73 |
| A=0.01 | 0.713 ★ | 0.128 | 0.73 |
| s_m=0.05 | 0.720 ★ | 0.136 | 0.74 |
| **A.01 × s_m.05** | **0.783 ★** | **0.142 ★** | **0.79** |
| A.01 × s_m.05 × Lw10 | 0.745 ★ | 0.143 ★ | 0.78 |

**Text verification (runN):** read every output of `A.01 × s_m.05`. Factual: all
four correct (varied phrasings, not degenerate). Reasoning: equations set up
correctly. Creative/continuation: genuinely diverse, vivid, coherent — *real*
variety, not metric-fooling repetition. Confirmed.

**Reversed verdict.** At the loose corner **A=0.01, s_m=0.05** (W=6,
target_gap=15, L_W=1200) HLG **beats** the default temperature+cutoff recipe on
diversity — self-BLEU 0.783 vs 0.672 (large), distinct-2 0.79 vs 0.73, embedding
marginal — at **zero junk and full correctness**, verified by reading the text.
This is the **thesis realized**: A→0 flattens the overconfident top, s_m→0 keeps
the mids loose, the window/target_gap gate kills the tail — loosening the top
*without* lifting the tail, the one thing a single temperature knob structurally
cannot do. Caveats: the semantic edge is small (+0.006 on a weak LM-hidden-state
proxy, not a real sentence encoder); single seed-base at N=10 (the large,
text-verified *lexical* margin still wants one fresh-seed repeat); `×Lw10`
occasionally breaks character.

**Fresh-seed repeat (runO, seed 5000) — the dominance does NOT replicate.** The
default's own self-BLEU swung **+0.083** across seeds (0.672 → 0.755), *larger*
than the effect I claimed; at seed 5000 the default (0.755) edges **above**
A.01×s_m.05 (0.747). N=10 self-BLEU variance (~0.08) swamps the effect — no
self-BLEU dominance survives. The only signal stable across both seeds is the
small **embedding** edge (loose HLG cells > default at both: 0.142/0.141 vs the
default's 0.136/0.121), on a weak proxy.

| | self-BLEU s1000 → s5000 | emb-div s1000 → s5000 |
| --- | --- | --- |
| default | 0.672 → **0.755** | 0.136 → 0.121 |
| A.01 × s_m.05 | 0.783 → **0.747** | 0.142 → 0.141 |

**Honest final landing (neither premature verdict).** HLG's loose-corner cells
(A=0.01, s_m=0.05) are **comparable** to the default on diversity at equal
coherence — *within N=10 measurement noise* — with at most a small, consistent
*semantic* (embedding) edge below what this metric/N can resolve. Proving a real
effect of that size needs N in the hundreds (variance ~1/√N) or a proper sentence
encoder, not the LM's own hidden states. **Meta-result: the fresh-seed repeat is
the discipline that catches over-claims — it caught the premature "negative"
(§12/§13) AND the premature "dominance" (§14 first draft) within one run each.**
(Runs L/M/N/O.)

---

## 15. Mapping the terrain (ongoing — not verdicts)

Reframing, deliberately: this is a forest, not a yes/no, and §12–§14's
"verdicts" (negative → dominance → wash) were premature lurches at individual
data points. Each run is a *coordinate*. What we actually have is a partial map
of where the shaper is coherent and how diverse it is, held loosely.

`scripts/hlg-grid.ts` adds the first **2-D** layer — `A × s_m` (runP, N=5; cell =
self-BLEU-div (emb-div), `✗` = canary broke; default contour 0.799 / 0.140):

```
 s_m\A    0.01        0.05        0.2         1           5
 0.05    +0.81(.15)  +0.83(.12)  +0.86(.14)  +0.82(.13)   0.56(.04)
 0.2     +0.85(.13)   0.73(.11)  +0.86(.07)   0.76(.05)   0.58(.10)
 0.7     +0.80(.13)   0.74(.11)  +0.81(.06)   0.72(.05)   0.67(.05)
 1.5      0.79(.13)   0.71(.11)   0.74(.09)   0.66(.05)   ✗3%
 3       +0.78(.16)   ✗3%         ✗3%         ✗4%         ✗4%
```

Terrain features (confidence noted):
- **The coherent basin's upper edge is a coupled `A↔s_m` trade-off** (sharp,
  reliable): `s_m=3` breaks across the row *except* at `A=0.01` (a clean **spur**),
  and `A=5` breaks a row lower (`s_m=1.5`). Loose `A` *buys* high-`s_m` tolerance —
  hard shoulder-flattening appears to stabilize the otherwise non-monotonic
  high-`s_m` mid. Same coupling family as `tg×W` (§13).
- **Diversity is a noisy plateau near the default level**, sloping down only toward
  tight `A` (`A=5`: self-BLEU 0.56–0.67, clearly low). The dense `+` cells sit
  within the measured seed-noise (±0.08) of the default — comparable, not a clean
  peak. (emb at N=5 is noisier; trust the coherence contour and the `A` slope.)

**Second plane — `W × target_gap` (runQ, N=5):**

```
 W\tg     10          13          16          25          50
 4       ✗21%        ✗6%         ✗4%         0.78(.05)   0.57(.03)
 5       ✗38%        ✗4%         0.75(.05)   0.78(.05)   0.57(.03)
 6       ✗4%        +0.81(.06)   0.71(.05)   0.71(.05)   0.50(.03)
 10       0.75(.09)  0.78(.05)   0.74(.05)   0.73(.04)   0.57(.03)
 20      +0.88(.06)  0.58(.05)   0.63(.05)   0.60(.04)   0.58(.03)
```

The coherence cliff is a clean **diagonal**: wide `W` buys low `target_gap`, high
`target_gap` buys narrow `W` — they trade off, exactly like `A↔s_m`. **Two
independent planes now show the same coupling — promoting it from quirk to
structural fact: the coherent basin is walled by COUPLED diagonal cliffs, not
independent per-knob thresholds; the knobs trade off against each other at the
edge.** (This is why the marginal 1-D ranges can't be trusted jointly — the
`tg12×W5` failure was the first hint.) Diversity peaks at the loose corner (wide
`W`, low `target_gap`: 0.88; falls to 0.50–0.57 as `target_gap` sharpens), near
the default contour and within seed-noise.

**Cross-pair coherence (runS, canary-only — swap partners).** Each shaping knob
(`A`, `s_m`) × each gate knob (`tg`, `W`). The coupling is **selective, not
global**:
- **`A` is nearly orthogonal to the gates** — in `A×tg` and `A×W` the gate cliffs
  (`tg<~12`, `W<~5`) hold across *every* `A` (only the extreme `A=100` corner
  nudges them). `A` reshapes the top without moving the coherence floor.
- **`s_m` is the coupling hub** — `s_m×tg` is a clean diagonal (`s_m=0.2` *rescues*
  `tg=8`; `s_m≥2` breaks `tg=12`), `s_m×W` the same milder bend. Loose mid demands
  a tighter gate.

So the coherence wall is a **gate+mid cluster** (`tg`, `W`, `s_m` share a
tail-mass budget) with **`A` outside it**. Mechanism: the floor is a *tail*
phenomenon (gates set it, `s_m` feeds the mid into it); `A` only flattens the
*top* — no tail mass — so it's free on coherence.

**Map so far (held loosely, no verdict):** a coherent basin whose wall is a
coupled `tg`/`W`/`s_m` surface, with **`A` an orthogonal degree of freedom**;
diversity a noisy plateau rising toward the loose corner, near the default level.
The two diversity levers split by their relation to the wall — **`A` is free,
`s_m` is coupled.** All pairwise coherence boundaries now mapped (2 within-pair +
4 cross-pair). Next layers: the **blind external-judge** read (`scripts/hlg-blind.ts`,
artifacts ready — independent of self-BLEU/embedding), and zooming the loose
corner / the `A↔s_m` spur.

### Generalization across models (runT CPM5, runU 12B)

The whole map above is e4b. To ask whether the basin geometry is a property of
the *curve* or of *e4b*, re-ran the cross-pair coherence map on two more models:
**12B** (dense Gemma, same ~262k vocab as e4b) and **CPM5** (MiniCPM5-1B,
Llama-family, ~73k vocab). The split is clean:

- **The sharpness cluster replicates on all three.** `s_m×target_gap` is the same
  diagonal everywhere (low `s_m` tolerates low `tg`; high `s_m` needs high `tg`),
  and `A` stays orthogonal to the `tg` gate. Two architectures, two vocab sizes —
  same structure. This is the load-bearing finding, and it's curve-level, not
  model-level. (CPM5's diagonal is *shifted* — it breaks only at `s_m≥2` where the
  Gemmas break at `s_m≥0.7` — i.e. the same coupling direction, a more tolerant
  threshold.)
- **The window (`W`) axis is vocab-dependent.** The two same-vocab Gemmas (e4b, 12B)
  behave identically on `W` (low-`W` gate breaks across all `A`; `s_m×W` couples at
  `W=5`); CPM5 diverges (`W=3` robust at low `A`, `s_m×W` fully decoupled, plus a
  high-`A`/wide-`W` break absent in e4b — 12B shows a mild hint of the same). The
  12B control did its job: it tracked e4b, not CPM5, confirming the `W` difference
  follows vocab size (smaller vocab → less tail to inflate → different gate dynamics).

So the **sharpness coupling is the invariant**; the **window axis is the
vocab-sensitive part**. Visualized in `scripts/hlg-viz.ts` (e4b diversity terrain)
and `scripts/hlg-viz-cross.ts` (3-model coherence comparison). Logs: runT (CPM5),
runU (12B).

### L_W — the fifth knob (runV e4b, runW 12B, runX CPM5)

`L_W` sets the OOTF gamma: `γ = 1.2 + 0.42·log10(L_W/1000)`. The auto-`out_scale`
pins the top→reference gap to `target_gap`, so `L_W` does **not** move the anchor —
it bends the **curvature** of the mid/tail. Swept wide (`L_W` 1 … 10⁶, γ −0.06 … 2.46),
`scripts/hlg-lw.ts`, two-stage:

- **`L_W` is not a gate-cluster member.** Coherence is robust across **five decades**
  (`L_W ∈ [3, 10⁵]`, γ ∈ [0.14, 2.04]) — the opposite of `tg`/`W`'s tight breaks.
  It walls only at the *extremes*: low (`L_W≈1`, γ<0 *inverts* the ranking → junk)
  and high (`L_W≈10⁶`, γ≈2.46, over-sharpened → junk). The low wall and coherent
  range are **identical on e4b and 12B** (same-vocab Gemmas). The *high* wall is
  Gemma-only: **CPM5 has no high wall** (clean through `L_W=10⁶`, range `[3, 10⁶]`) —
  the smaller vocab is more robust at high γ, the same vocab-sensitivity seen on `W`.
- **Diversity response is model-specific, and not monotone.** On e4b it's an
  interior peak that *appeared* to rise above the 0.70 default (0.76 at γ≈1.0) — **but
  this was K=6 noise, retracted at K=20** (see the deep-dive below): the K=20 default is
  0.633 and every `L_W` point sits at 0.42–0.45, well below it. On 12B (K=6) it's a flat
  **0.51–0.56 floor below the 0.72 default**. Corrected read: `L_W` diversity is *below*
  the recommended recipe on every model measured — it does not help diversity.

`L_W` is therefore its own kind of knob: a **curvature control**, coherence-robust
(unlike the gates), with a non-monotone diversity response whose useful direction
flips by model. Visualized in `scripts/hlg-lw-viz.ts`.

### Cliff resolution (runY e4b, runZ 12B, runAA CPM5)

The coarse maps stepped *over* the steepest features. `scripts/hlg-cliff.ts` steps
`target_gap` 7→13 (unit) at base, and `W` 3→10 at `A=100` (the channel-closing edge),
reporting the junk% gradient (K=5 seeds). Fine resolution revealed **two different
cliff shapes** the coarse jumps had flattened into "a break somewhere in 8–12":

- **`target_gap` is a graded ramp, not a step.** e4b 31%→17%→1% over tg 8→9→10;
  12B 17%→4%→1%. The whole transition is a 2–3-step slope. Its *position shifts by
  vocab*: CPM5 coherent earliest (clean by tg≈8), e4b latest (still 31% at tg 8,
  crosses tg 9→10), 12B between — same vocab-sensitivity as the `W`/`L_W`-high stories.
- **`W` at high `A` is a sharp edge.** All three sit on a high junk plateau through
  W 3–7, then drop to 0% at **W=8** — an abrupt channel close between 7 and 8. The
  *edge position is model-invariant* (all three close 7→8); only the plateau *height*
  differs by vocab. So the channel-closing W is a property of the window math at high
  `A`, not the model.

The earlier "12B is steeper" hypothesis **did not hold** — e4b's `tg` cliff is if
anything the steepest (31→1 over two steps vs 12B's gentler 24→17→4→1). 12B's
"sensitivity" was real but in *diversity* (the `L_W` suppression), not cliff
steepness — two distinct senses. Logged as a data point. Visualized in
`scripts/hlg-cliff-viz.ts`.

**Knob taxonomy (the five mapped, held as terrain):** `tg`+`W`+`s_m` = the coupled
*gate/sharpness cluster* (tight, coupled, vocab-shifted breaks); `A` = orthogonal to
the wall (free diversity lever); `L_W` = a coherence-robust *curvature* knob (walls
only at γ extremes; diversity *below* default — see K=20). Cliff shapes split too:
`tg` graded, `W@highA` sharp.

### K=20 deep-dive (runAB grids, runAC peaks — e4b)

Four experiments re-run at K=20 (`scripts/hlg-grid2.ts`, `scripts/hlg-peak.ts`) to
settle the noisy diversity claims and resolve the cross-terms. Results corrected two
earlier reads:

- **The cliffs are tilted surfaces, not fixed walls.** The `tg` cliff edge *slides
  monotonically with `s_m`*: at `s_m=0.2` there's no cliff at all (0% to tg=7), at
  `s_m=0.7` it sits at tg≈9, at `s_m=2` past tg=12, at `s_m=4` out of frame. And the
  `W` edge *slides with `A`*: it closes at W≈4–5 for `A`≤10 but not until **W≈8 at
  `A=100`** — so the "invariant 7→8 edge" above was specific to `A=100`, not general.
- **The `L_W` "peak beats default" was noise — retracted.** At K=20 the e4b default is
  0.633 and every `L_W` point is 0.42–0.45 (~0.19 below). The K=6 0.76>0.70 was
  small-sample artifact; `L_W` shaping is below default on every model measured.
- **`A` is confirmed the free diversity lever** — clean monotone, 0.66 (A=0.01) → 0.31
  (A=0.7), and the *one* place HLG clears a default is the loosest `A` (+0.03 at 0.01).
  (Sweep cut at A=0.7 when the batch was stopped; trend + ceiling captured.)

### Edge texture (runAE — sub-unit K=20) + a single-config probe

`scripts/hlg-edge.ts` zooms sub-unit into the transitions, tracking break-*rate* and
max (not just mean). The edges turn out heterogeneous:

- **Gate cliffs (`tg`, `W`) are *statistical* edges** — per seed bimodal (clean or
  hard-break, max 43–88% mid-ramp); the smooth ramp is the declining *fraction* of
  seeds that break (`tg` 20→2/20 over 7→10; `W` 18→0/20 over 6→8.5), not a softening.
- **`L_W` low wall is a *hard* threshold at γ=0** — the ranking sign-flip; every γ≥0 is clean.
- **`L_W` high wall is barely a wall** — 3/20 at γ=2.46; the coarse "REJECT" was a 1-of-2-seed artifact.

`scripts/hlg-eval1.ts` evaluates one explorer-dialed config at K=20. A heavily reshaped
curve (W 7.5, A 3.55, s_m 0.05, **target_gap 4**, γ 1.93, xM 0.74, xFloor 0.45) came back
**20/20 incoherent** (pure salad; "diversity 1.000" = the garbage signature — why the
two-stage gate exists). The driver: `target_gap=4` → `out_scale≈5.2` → HLG top-1 25% (vs
raw 50%), entropy *up* → samples the tail. **Lesson: the curve shape is secondary to the
final sharpness (`out_scale`); the distribution's top-1/entropy is the coherence oracle.**
The shaper now forwards the curve-geometry params (`xM/yM/xFloor/yFloor/p`) through
`HlgConfig` so explorer-tuned configs can be evaluated faithfully.

Interactive tools: `docs/investigations/hlg-explorer.html` (live curve + distribution
under sliders), `docs/investigations/hlg-ab.html` (side-by-side samples). Full report:
`docs/investigations/hlg-report.html` (`scripts/hlg-report.ts`, figures in `hlg-figs/`).

---

## Appendix A — Run 0 (original: greedy / temp-0.7 / temp-1.2 / hlg-default / hlg-rolloff)

```
# HLG sampling comparison — model "gemma-4-e4b-it-OptiQ-4bit", K=4, maxTokens=80

═══ [creative] Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog.
  ▸ greedy       len~ 36  unique 1/1  distinct-2 0.97
      1. The fog, a thick, clammy blanket that swallowed the beam of the old lantern, seemed to press against the glass of the tower, and it was in that suffocating grey that Silas first saw the impossible.
  ▸ temp-0.7     len~ 35  unique 4/4  distinct-2 0.85
      1. The fog, a thick, clammy blanket that swallowed the beam of the lantern, seemed to press against the glass, and it was through that swirling gray veil that Silas first saw the impossible.
      2. The sea fog, a thick, soupy thing that swallowed the beam of the old lantern whole, was the perfect shroud for what he found bobbing just beyond the reach of the rocks.
      3. The fog, a clammy, grey beast clinging to the tower like wet shrouds, usually offered only the familiar damp chill, but tonight, it carried a scent utterly alien—a metallic tang mixed with the faint, sweet perfume of som…
      4. The fog, a thick, clammy blanket that swallowed the horizon whole, seemed to carry a faint, unnatural chime as Silas, perched in the lantern room, peered into its milky depths.
  ▸ temp-1.2     len~ 39  unique 4/4  distinct-2 0.95
      1. The swirling, pea-soup fog that clung to the edge of the jagged coastline seemed to thicken just as a flash of unnatural green light pulsed from the watery expanse below the lantern's rhythmic beam.
      2. The sea fog, a thick, soupy thing that seemed to swallow the very light from the lantern, usually brought with it only the familiar smell of salt and damp rock, but this morning, it carried a scent unreasonably sweet—lik…
      3. The relentless, butter-yellow fog was thick enough to chew, and steady, Elias felt the usual creeping silence of the isolated tower until a single, impossibly bright crimson streak broke through the gray curtain near the…
      4. The St. Agnes, usually a solitary sentinel against the swirling gray, held a silence that felt too deep until he saw the impossible gleam through the shroud of fog clinging to the lantern room's glass.
  ▸ hlg-default  len~ 33  unique 4/4  distinct-2 0.88
      1. The fog, a thick, woolly blanket that swallowed the beam of the lantern, seemed to press against the glass, and it was through that swirling gray veil that Silas first saw the impossible.
      2. The sea fog, a thick, soupy thing that seemed to swallow the very sound of the waves, usually brought with it only the familiar smell of salt and damp stone, but this morning, it carried a faint, metallic tang, like old …
      3. The relentless, salt-laced fog that clung to the tower like a shroud offered no respite until the moment a slick, pearlescent object drifted into the beam of his lantern.
      4. The fog, a thick, clammy blanket that swallowed the horizon whole, finally delivered something unexpected to the beam of the old lighthouse.
  ▸ hlg-rolloff  len~ 34  unique 4/4  distinct-2 0.88
      1. The fog, a thick, woolly blanket that swallowed the beam of his lantern, seemed to press against the glass, and it was through that swirling gray veil that Silas first saw the impossible.
      2. The sea fog, a thick, soupy thing that seemed to swallow the very light from the lantern, usually brought with it only the familiar smell of salt and damp rock, but this morning, it carried a scent of something metallic …
      3. The relentless, salt-laced fog that clung to the tower like a shroud offered no respite until the moment a slick, pearlescent object drifted into the beam of his lantern.
      4. The fog, a thick, clammy blanket that swallowed the horizon whole, finally delivered something unexpected to the beam of the old lighthouse.

[brainstorm/factual/reasoning/continuation: full text in run0-original.log —
 factual & reasoning were near-identical across all rows (~0.30); brainstorm
 temp-1.2 dipped to 0.59 (all converged on "SIM Card Ejector" as item 1).]
```

Full verbatim transcript: [hlg-runs/run0-original.log](hlg-runs/run0-original.log).

## Appendix B — Run A (recommended / rec+hlg / hlg-replace)

Full transcript: see the run output below (creative + continuation shown; factual
& reasoning collapsed to ~0.30 near-verbatim across all rows).

```
═══ [creative]
  ▸ recommended  distinct-2 0.90
      1. The fog, a thick, woolly blanket that swallowed the beam of his lantern, seemed to press against the glass, and it was through that swirling gray veil that Silas first saw the impossible.
      2. The sea fog … carried a faint, metallic tang, like old …
      3. The relentless, salt-laced fog … until the silence was broken by a sound that certainly hadn't been the groan of the old lamp mechanism.
      4. The fog … finally delivered something unexpected to the beam of the Grand Shoal light.
  ▸ rec+hlg      distinct-2 0.89
      1. The fog, a thick and suffocating blanket that clung to the granite tower like wet wool, had been a familiar, monotonous companion to Elias for thirty years, yet this morning … a scent entirel…
      3. The relentless, salt-laced fog that clung to the tower like a shroud offered up, on a Tuesday afternoon, something that was decidedly, inexplicably *not* a seabird.
  ▸ hlg-replace  distinct-2 0.90
      1. The fog, a thick and scudding curtain that had swallowed the coastline whole … what Silas glimpsed in its inky heart was something that decidedly did not belong t…
      3. The relentless, butter-yellow fog … a single, impossible flash of deep sap…

═══ [brainstorm]  recommended 0.78 → rec+hlg 0.88 → hlg-replace 0.88
  rec+hlg #1: "…1. **Improvised Zipper Pull:** If the tab or pull on a zipper breaks off or becomes too small to grip, you can carefully thread a s…"  ← broke the "SIM Card Ejector" rut

═══ [continuation]  recommended 0.75 → rec+hlg 0.84 → hlg-replace 0.86
  hlg-replace #4 (tail leak): "…behaves like a cartographer's stain—aving purpose, dissolving under new light…"
```

Complete verbatim transcript: [hlg-runs/runA-recommended.log](hlg-runs/runA-recommended.log).

## Appendix C — Run B (gain variants: rolloff / midboost / soft / full)

Diversity numbers in §6.3. Representative creative openings:

```
  ▸ hlg-rolloff #1: "The swirling, pea-soup fog that clung to the edge of the jagged coastline seemed to thicken just as Elias, his face ruddy from years of wind-whipped solitude, noticed a flicker of unnatural, vibrant green…"
  ▸ hlg-midboost #1: "…it was through that swirling gray veil that Silas first saw it—a perfectly smooth, obsidian orb bobbing just…"
  ▸ hlg-full #3: "The relentless, salt-laced fog … offered up, on a Tuesday afternoon, something that was decidedly, inexplicably *not* a seabird."
```

All rows coherent; factual locked at 0.30; continuation 0.75 → 0.82–0.85.
Complete verbatim transcript: [hlg-runs/runB-gain-variants.log](hlg-runs/runB-gain-variants.log).

## Appendix D — Run C (pivots: top / entropy / median, as replacement) — full transcript

```
# standard (control) = the model's recipe: temp 1 · top_p 0.95 · top_k 64
# hlg-* = REPLACEMENT sampler (one curve, 3 pivot placements, no top_p/top_k).

═══ [creative]
  ▸ standard     0.90
      1. The fog, a thick, woolly blanket … Silas first saw the impossible.
      2. The sea fog … a faint, metallic tang, like old …
      3. The relentless, salt-laced fog … the groan of the old lamp mechanism.
      4. The fog … the beam of the Grand Shoal light.
  ▸ hlg-top      0.95
      1. The swirling, pea-soup fog that clung to the edge of the jagged coastline seemed to thicken just as a flash of unnatural green light pulsed from the gray expanse.
      2. The sea fog … carried a scent of something alien.
      3. The relentless, butter-yellow fog was thick enough to chew … the odd, rhythmic glimmer appeared ten正常的 yards from t…  [← stray token]
      4. The fog, usually a thick, insulating blanket around the solitary tower, began to swirl with an unnatural luminescence as he made his evening rounds.
  ▸ hlg-entropy  0.99  ⚠️ GARBAGE
      1. The Lern AideObserver, a scfileobjextracted keeper subs tuturल्तान subscription exam بالتfog साप्ताहिक， প্রশ্ন তোলার মতো অপ্রত্যাশিত, when MSMাবেনевич' başlayan তার ঘূর্ণAvlৰ আলো inulai a peculiar हॉकी of scent and effor…
      2. The जैसে overtakehouses, a thickolver漏洞 খাওয়ার,ᵛ<br Zweigen graissesigğim, is where Continuando stared homedidnivased the fog pressing against synthwave- kajak-soaked ClauseCloudsPPT…
  ▸ hlg-median   1.00  ⚠️ GARBAGE
      1. The Lern AideObserveratic簿 scfileobjextracteddatabases Nimbus stretched thickatório بالتح साप्ताहिक帳 প্রশ্ন, a hateful, damp shroud…
      2. The जैसे overtakehouses,рачиnolver fog খাওয়ার,ᵛकेनोइक 瞭臤ğim stumbledgryifford丹अ through traysivased glass sacksстая

═══ [factual]
  ▸ standard     0.30  — "The seasons on Earth are primarily caused by the tilt of the Earth's axis as it revolves around the Sun." (×4, minor variants)
  ▸ hlg-top      0.55  — mostly correct; #3 leaked: "the tilt of the planet' adorable axis … throughout kä's orbit."
  ▸ hlg-entropy  0.99  ⚠️ — "The Lern AideObserver Electrons' scfileobjextracted, tutur tubatório hidadier tut প্রশ্নତ୍Kurs'"
  ▸ hlg-median   1.00  ⚠️ — "The जैसे overtakehouses仰рачи倾olver漏洞格局 ᵛ<br Zweigen graisseuse.apparent échelle saisonAlloc Lieu en cours rotation follicle orbit 結構"

═══ [reasoning]
  ▸ standard     0.28  — coherent step-by-step (×4)
  ▸ hlg-top      0.35  — coherent; tiny leaks ("scavenging price of the bat", "প্রশ্ন let 'B'")
  ▸ hlg-entropy  1.00  ⚠️ GARBAGE
  ▸ hlg-median   0.99  ⚠️ GARBAGE

═══ [continuation]
  ▸ standard     0.75  — coherent, vivid (×4)
  ▸ hlg-top      0.88  — coherent AND varied:
      2. "…how it insists on polishing fractured timelines into gleaming, heroic monuments, even when the original quarry was a muddy, bewildered ditch."
      3. "…how it acts like a coral reef—brilliantly shaped in its fleeting, vibrant bloom, only to be slowly colonized and ultimately obscured by the perpetual, grinding algae of the new…"
      4. "…how it vaccinates us against our own truth … yesterday's sharpest agony marketable as yesterday' recalls u…"  [← tail fraying]
  ▸ hlg-entropy  1.00  ⚠️ GARBAGE — "'The Aideang strane簿 sche tup de uman tuturí namiatório hidadierá escult প্রশ্ন p a'i nto'…"
  ▸ hlg-median   1.00  ⚠️ GARBAGE — "'The Aideang strane簿 scfileobj tup ad tutur sbonnadier…"
```

Complete verbatim transcript: [hlg-runs/runC-pivots.log](hlg-runs/runC-pivots.log).

---

*Raw logs (committed, full verbatim transcripts):*
Pass 1 — [run0-original.log](hlg-runs/run0-original.log),
[runA-recommended.log](hlg-runs/runA-recommended.log),
[runB-gain-variants.log](hlg-runs/runB-gain-variants.log),
[runC-pivots.log](hlg-runs/runC-pivots.log).
Pass 2 — [runD-oetf.log](hlg-runs/runD-oetf.log) (literal OETF),
[runE-eotf.log](hlg-runs/runE-eotf.log) (EOTF/OOTF),
[runF-shaper-working.log](hlg-runs/runF-shaper-working.log) (HLGShaper W5/os18 — works),
[runG-shaper-sweep.log](hlg-runs/runG-shaper-sweep.log) (knob sweep, full untruncated text).
Pass 3 (premature negative) — [runH-wsweep.log](hlg-runs/runH-wsweep.log) (clean 1-D W sweep),
[runI-asweep.log](hlg-runs/runI-asweep.log) (clean 1-D A sweep),
[runJ-knobmap.log](hlg-runs/runJ-knobmap.log) (narrow 5-knob map),
[runK-frontier.log](hlg-runs/runK-frontier.log) (N=10 self-BLEU + interactions).
Pass 4 (reversal → DOMINANCE) — [runL-widemap.log](hlg-runs/runL-widemap.log) (wide ranges, all knobs break),
[runM-frontier-emb.log](hlg-runs/runM-frontier-emb.log) + [hlg-frontier.json](hlg-runs/hlg-frontier.json) (N=10, self-BLEU + **embedding** + distinct-2),
[runN-verify.log](hlg-runs/runN-verify.log) (text verification of A.01×s_m.05 — correct + genuinely diverse).
Harnesses: `scripts/hlg-compare.ts`, `scripts/hlg-map.ts`, `scripts/hlg-frontier.ts` (the latter now scores embedding-similarity too).
