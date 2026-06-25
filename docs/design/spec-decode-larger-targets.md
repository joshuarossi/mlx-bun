# Spec decode on larger targets — does the Gemma drafter pay on 12B / 26B?

Status: **12B γ=1 is a WIN after the verify fix; matches optiq bit-exactly** (2026-06-14; 26B not run)
Owner: decode / spec
Default: **off** (speculation is opt-in; non-spec greedy is untouched)

## Result (2026-06-14, v2) — fixed the wrong-oracle bug; γ=1 now wins

The first 12B measurement (v1, below) was made through a verify path that
targeted the **wrong oracle**. Fixing it changed the conclusion.

### The wrong-oracle bug

Assistant-drafter speculation is an **optiq** feature — mlx-lm has only
generic standalone-`draft_model` two-model spec and structurally cannot
drive a KV-borrowing drafter. So the correctness oracle is optiq's
`spec_generate`. **Both optiq and mlx-lm BATCH the verify lm-head** (one
matmul over the γ+1 window, then argmax per position); neither is bit-
exact to stock token-at-a-time decode. Our port instead verified
**per-position** to be bit-exact to *stock decode* — a target no real
implementation has, and one that re-reads the ~1 GB tied lm-head matrix
γ+1× per iteration instead of once. So we were exact to the wrong thing
*and* paying a γ-scaling tax for it. Fix: `picksBatched` in
`src/spec/generate.ts` — one batched verify lm-head, matching optiq.

### Do we match optiq? YES — bit-exact (e4b)

Cross-checked our `specGenerate` against optiq's `spec_generate` on the
identical prompt ids (`scripts/oracle-spec.py` + `scripts/spec-dump.ts`),
e4b γ=2: **identical 48-token output AND identical accept/reject trace**
(drafted 60, accepted 17, target calls 31 in both). Before the fix we
matched *stock*, not optiq, at knife-edges; now we match optiq.

### Is it still a loss? Not at γ=1 (12B)

12B pair, batched verify (loaded machine — ratios paired/trustworthy,
absolutes depressed & not quotable):

| γ | v2 speedup (batched) | v1 (per-position) | acceptance |
|---|----------------------|-------------------|-----------|
| 1 | **1.09× (WIN)** | 0.96× | 42% |
| 2 | 0.91× (near break-even) | 0.77× | 29% |
| 3 | 0.72× | 0.67× | 23% |
| 4 | 0.56× | 0.52× | 17% |

Acceptance is unchanged (the fix only touches verify cost, not which
tokens are accepted). The per-position verify was a large self-inflicted
tax: removing it flips γ=1 from loss to **win** and moves γ=2 to the edge.
γ≥2 still loses because the *drafter's own* cost dominates there — the
12B drafter is heavy (hidden 1024 vs e4b 256, 16 heads, and a full 262k
tied-embedding head **every draft step**) and acceptance falls with depth.

**So the v1 "hypothesis refuted / net loss at every γ" was itself partly
an artifact of the wrong-oracle verify.** Corrected conclusion: γ=1
speculation on 12B is a real ~9% decode win (pending clean-machine
confirmation before quoting); γ≥2 doesn't pay with the shipped heavy
drafter.

### Bonus finding: we're ahead of optiq on the unified drafters

optiq's *installed* runtime can't actually drive the 12B/26B
`gemma4_unified_assistant` drafters: its head detection is config-based
(`use_ordered_embeddings = num_centroids and top_k`), but those artifacts
declare `num_centroids` while shipping **no** centroid tensors and **no**
`lm_head` (tied `embed_tokens` instead). optiq loads the centroid path
with zero-init weights → garbage drafts → **0% acceptance** (measured:
drafted 46, accepted 0 on 12B). Our `drafter.ts` detects the head by
**tensor presence** and uses the tied-embedding path → 29% acceptance on
the same artifact.

### Remaining levers / next

- **Clean-machine rerun** before promoting any number to RESULTS.md
  (baseline jumped 15.4→24.4 between runs under memory pressure — exactly
  why only paired ratios are trusted here).
- **Cheaper drafter head**: the 262k tied-embed argmax every draft step is
  the dominant remaining γ≥2 cost; capping/approximating it (e4b-style)
  could extend the win past γ=1.
- **26B-MoE**: still unlikely — MoE decode reads only top-8/128 experts
  (~2.4 GB active), so per-token target cost is *lower* than its size →
  harder to beat. Measure if curious.
- **Optional strict mode**: the old per-position verify gave "spec output
  identical to spec-off" — a product nicety no oracle provides. Could be
  kept as a default-off `strictVerify` flag rather than deleted
  ([[dont-delete-optionality-on-one-measurement]]) — not implemented; ask.

## v1 (superseded) — per-position verify, "net loss at every γ"

> Kept for the record. The numbers (0.96/0.77/0.67/0.52×) were real but
> measured through the wrong-oracle per-position verify; v2 above is the
> optiq-faithful measurement.

## TL;DR

The Gemma `-assistant-bf16` drafters are Gemma's substitute for an MTP
head: a 4-layer Q-only module that reuses the target's KV + hidden state
to draft tokens (`src/spec/drafter.ts`), verified by the target's own
greedy pick (`src/spec/generate.ts`). True MTP (a trained
`mtp.safetensors` head + an `optiq/runtime/mtp` backend) **does not exist
for Gemma** and never will — that's the Qwen path (Phase 14). The
assistant drafter is the functional equivalent we already have.

It was measured a **net loss on e4b** (Phase 6): γ=2 ran at 0.78× the
54 tok/s baseline, ~23% acceptance — because e4b decode is already too
fast for a low-acceptance drafter to beat. **This doc is the experiment
to find out whether the same drafter wins on a slower target**, where
each skipped target-forward is worth more.

## The hypothesis

The drafter's per-step cost is roughly fixed. The *value* of each
accepted draft = one skipped target forward, which grows as the target
gets slower per token. e4b is the worst case for speculation (fastest
target). So the SAME acceptance rate can flip net-positive as the target
slows:

| target | non-spec decode | per-accepted-draft value | drafter | status |
|--------|-----------------|--------------------------|---------|--------|
| e4b              | ~54 tok/s | low  | 160 MB (cached) | **measured net loss** (0.91/0.78/0.63/0.51× @ γ=1–4) |
| 12B              | ~25 tok/s | ~2× e4b | 846 MB (cached) | **measured net loss** — see Result above (hypothesis refuted) |
| 26B-A4B (MoE)    | ~32 tok/s | high (MoE forward) | 839 MB (HF, **not downloaded**) | untested (follow-on; expect loss) |

> The reasoning below is the *pre-measurement* hypothesis — kept for the
> record. It predicted the crossover assuming a fixed-cost drafter; the
> 12B drafter is not fixed-cost (it scales with the target), which is
> exactly why the Result section above refutes it.

Crossover intuition: a drafter is a net win when
`acceptance × (target_step_cost − draft_step_cost) > verify_overhead`.
On e4b the target step is cheap, so the bar isn't cleared at 23%. On 12B
the target step is ~2× more expensive while the drafter cost barely
moves — same acceptance, very different sign. **Measure, don't assume**
(it could still lose; this is exactly the kind of thing the e4b result
warned against assuming).

Acceptance itself may also differ on 12B (a stronger target predicts
itself differently). We don't know the direction — that's why we run it.

## What is already wired (this change)

- **`scripts/spec-bench.ts`** — now multi-pair, **one pair per process**
  (memory-safe; 12B+drafter ≈ 8 GB, 26B ≈ 17 GB, never co-resident):
  - `bun scripts/spec-bench.ts e4b` (default) — reproduces the baseline.
  - `bun scripts/spec-bench.ts 12B` — the experiment.
  - `bun scripts/spec-bench.ts 26B` — follow-on.
  - Auto-detects whether each `(target, drafter)` snapshot pair is
    present; exits with a clear "download with: hf download …" message
    otherwise. Records baseline + γ-sweep (acceptance + tok/s) to the
    eval DB tagged `spec-bench[<id>]`.
- **`tests/spec-decode.test.ts`** — added a `(12B)` parity block,
  auto-skipped until the drafter is downloaded. Gate = long-prefix
  agreement (greedy spec vs greedy non-spec). It guards the shared
  accept/reject/**rollback + cache-trim** machinery against 12B's
  distinct layer/cache shapes — NOT drafter correctness (see the
  important nuance below). The calibrated e4b block (exact `toEqual` +
  knife-edge) is unchanged.

The port (`drafter.ts` + `generate.ts`) is already generic over the
target's `backbone_hidden_size` — drafters are target-bonded artifacts
(e4b 2560, 12B 3840, 26B 2816) but there's no per-pair code, just the
matching weights. Expect to *validate* each cell per the project's
per-model-specialization reality, not assume it's free.

## Important nuance: a broken drafter still produces correct tokens

Speculation can't corrupt output. The target verifies every position and
replaces every rejected draft with its own greedy pick; drafts only ever
*skip* target forwards. So a mis-wired drafter (wrong KV borrow, wrong
projection) shows up as **low/zero acceptance — a perf signal**, not bad
tokens. This splits the validation cleanly:

- **Correctness** (parity test): does the shared accept/reject/rollback
  + cache-trim logic still hold on 12B's cache shapes? A trim bug *would*
  corrupt output, shortly after the first rejection — that's what the
  long-prefix gate catches. (Shape-incompatible KV borrow throws, it
  doesn't silently corrupt.)
- **Payoff** (bench): is acceptance high enough, and the target slow
  enough, that γ>0 beats the non-spec baseline? This is the actual
  question.

## Procedure (once the 12B drafter is downloaded)

1. `hf download mlx-community/gemma-4-12B-it-assistant-bf16`
   (846 MB; `HF_HUB_DISABLE_XET=1`). The 12B OptiQ-4bit target is
   already cached.
2. **Correctness first** — `bun test tests/spec-decode.test.ts`
   (the `(12B)` block now runs). Long-prefix gate must pass for γ=1,2,3.
   If it fails early → rollback/trim bug on 12B caches, fix before
   trusting any number.
3. **Calibrate + promote (optional)** — find a tie-free prompt
   on-device, promote the 12B gate from long-prefix to exact `toEqual`
   like e4b, for a stronger standing guard.
4. **Measure** — `bun scripts/spec-bench.ts 12B` on a clean machine
   (preflight matters: dirty-machine numbers are garbage). Read
   acceptance + speedup-vs-baseline per γ.
5. **Record + decide** — numbers land in the eval DB. Promote into
   `benchmarks/RESULTS.md` only if quotable (clean machine).
6. **26B follow-on** — repeat with `26B` if 12B is encouraging; MoE
   target adds a validation cell (donor KV borrow through the MoE
   decoder), and a slower/heavier forward that should favor speculation
   even more — but the MoE forward also reads only top-8/128 experts at
   decode, so the per-token cost advantage is smaller than weight size
   suggests. Measure.

## Exit criteria

- 12B spec parity gate green (rollback/trim correct on 12B caches).
- 12B acceptance + tok/s-vs-baseline recorded in the eval DB across
  γ=1–4.
- A decision written down: ship speculation as the **default** only for
  the (model, context) cells where it measurably wins; otherwise record
  it as a characterized default-off lever (same disposition as the e4b
  net-loss result — a documented option, never a deletion).

## Caveats / interactions

- **Batched serving (Phase 18).** Speculation needs trimmable caches for
  partial-accept rollback — `generate.ts` throws once a `RotatingKVCache`
  ring wraps past the sliding window — and variable accept-lengths per
  slot break a uniform-B batch. Speculation is naturally a **B=1 latency**
  optimization; batched-throughput serving is a different regime. Layering
  both is real work, not free composition.
- **One serve path, two backends.** The assistant-drafter loop and the
  Qwen MTP runtime are two backends of the *same* "draft γ → verify in one
  forward → accept-longest-prefix → rollback" abstraction. As Phase 14
  (MTP) and Phase 18 (slots) land, build one verify/accept executor, not
  two — the drafter vs MTP-head difference is just what fills the draft.
- **Denominator discipline.** Speedups are only ever vs the *same model's*
  non-spec baseline. e4b's 54 tok/s is the wrong denominator for 12B.
