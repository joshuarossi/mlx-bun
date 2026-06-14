# Research Topics

Speculative, exploratory directions for mlx-bun — theses worth prototyping, not
committed work. Each entry carries enough detail to pick up cold. PLAN.md is for
work in flight; this is for ideas waiting their turn.

---

## 1. Tonal Grading for Token Distributions ("HDR Sampling")

> Replace the global scalar sampling knobs (temperature, top-k, top-p) with a
> region-aware **transfer function** applied to logits before softmax — the
> color-grading move, ported to token distributions.

**Framing — the Wes Anderson point.** A film's symmetrical pastel look isn't a
colorist failing to neutralize; it's a *target*. Grade Marvel that way and it's
"wrong" only against Marvel's acceptance function, not against any absolute.
Different films, different targets — and you have a lot of films. The
Lucien-synthesis agent and the test-writing agent want different *looks*, and
"temperature + a system-prompt vibe word" is the crude contrast slider standing
in for a real grade.

**Core thesis.** Current LLM sampling is "SDR": the available controls
(temperature, top-k, top-p) are crude *global* knobs — the equivalent of a single
contrast slider. Color grading abandoned "just turn the contrast knob" long ago
in favor of transfer functions with region-specific behavior. The same move is
available for sampling: replace global scalar knobs with a region-aware transfer
function applied to the logits before softmax.

**The reframe that makes it work.** Signal vs. noise is defined by *intent*, not
by magnitude — exactly as on a camera sensor, where the noise floor is "noise"
because it doesn't represent what's wanted, not because it's small. The full
logit vector is the model's signal, but it is not the signal *I* care about. My
acceptance criterion defines which part is signal. The low-logit tail is
therefore legitimately treatable as a noise floor to roll off.

**The three regions** — one curve, three treatments. This is precisely what
temperature *cannot* do, since it scales everywhere uniformly:

- **Shoulder** (head / confident tokens): soft rolloff instead of hard
  truncation. Top-k/top-p slam into the ceiling and clip; a shoulder eases the
  top tokens toward co-equality while *preserving their ordering* — it tames
  single-token dominance without destroying the relationships among the spared
  tokens.
- **Midtones** (the plausible-but-distinct band): steepen for local contrast.
  Push apart the tokens that matter so detail comes out sharp. This has no name
  in current sampling because sampling has no concept of distributional
  midtones — and it's the most novel piece.
- **Toe** (tail / unwanted tokens): roll into the floor. Defines them as noise
  relative to intent.

**Curve vocabulary, ported from grading:**

- **Pivot/cut** placed *relative* to the distribution (by rank or percentile),
  recomputed every step — never an absolute logit value, because logits are only
  meaningful up to an additive constant (softmax shift-invariance). HLG's
  relative / scene-referred design is the right philosophical match; LogC3 is
  more absolute / exposure-locked.
- **Slope-matched splices** between regions (C1 continuity — no kink in how
  adjacent-ranked tokens get treated).
- **Curve family:** signed / `log1p`-style forms to stay finite on negative
  logits. An HLG-style architecture (gamma toe + log shoulder, slope-matched) is
  the leading candidate because its two-regime structure happens to match the
  two-regime structure of a real logit distribution — temperature-style shaping
  on the uncertain tail, log-style compression on the overconfident head.

**Why it's not overclaiming.** I am *not* claiming buried capability that a curve
"unclips" — the logits aren't a compressed encoding of something richer. The
honest claim: there is an acceptable manifold the model can't articulate and the
default transform doesn't reliably land on; the curve encodes my
*observer-relative acceptance function* onto a distribution that has no opinion
of its own. This is why sampling knobs exist at all — "friendly / neutral /
professional" are crude gestures at exactly this, and a grade is the
high-resolution version.

**The per-agent-target insight (the payoff).** "Correctly transformed to display"
is not universally acceptable — it's unacceptable for an Oscar-buzz feature and
fine for a sports broadcast, because they have different acceptance functions.
Grading Marvel like Wes Anderson isn't incompetence; it's the wrong *target*. My
agents are different films:

- A **conversation→article synthesis** agent wants range, texture, and
  surprising-but-apt word choices — "cinematic."
- An **acceptance-criteria→tests** agent wants tight, predictable, low-variance
  determinism — "broadcast neutral."

They want different *grades*, not different *temperatures*. Per-task tonal
curves, not per-task scalar knobs.

**Open engineering question — build this first.** The colorist works in a tight
perceptual loop against a calibrated reference monitor; a sampler's curve is
chosen *upstream* of seeing output, with a slower, noisier judgment loop. So the
gating question isn't "is the curve good" — it's **"what is the monitor?"** What
readout tells me the midtones got crisper and the highlights rolled off well, per
target? Candidates: held-out preference, diversity-at-fixed-quality, task-specific
pass rates (for the test agent) vs. human preference (for the synthesis agent).
Define the per-target reference monitor first; the curve design follows from it
the way a grade follows from a trustworthy display.

**Implementation.** A pure elementwise function on the logits tensor inside
mlx-bun's per-step logits-processor hook: sort once for the rank-relative pivot,
apply the slope-matched toe/mid/shoulder curve, renormalize, sample. The hook
already exists — logits processors run at
[`generate.ts:236`](../../src/generate.ts:236)
(`for (const p of processors) logits = disposing(logits, p(history, logits))`),
built by `makeLogitsProcessors` in [`src/sampler.ts`](../../src/sampler.ts) as pure
`(history, logits) => logits` functions applied before `toLogprobs` and the
sampler — so the curve drops in as one more processor in that loop.

Given dispatch dominates decode wall time (~90–96%), the curve's arithmetic cost
rides inside work already dispatched — wall-time-negligible. Parameterize: pivot
rank, toe exponent, midtone slope, shoulder compression. A/B against plain
temperature **at matched effective entropy**, judged on the per-target monitor —
looking for outputs that land in the target region *unreachably* by
temperature-plus-top-p at any setting, not merely "different."

*Relation to current code:* the `--temperature` / `--top-p` / `--top-k` server
defaults (and `generation_config.json`) are the SDR knobs this topic proposes to
supersede — useful as the A/B baseline, not the destination.
