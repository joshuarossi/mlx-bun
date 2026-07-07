# DSpark serving program — flip spec wall-clock positive + design the product surface

Status: **PLANNED** (2026-07-07). Trigger for Josh's pickup: TurboQuant merge —
but only Phase 5 actually depends on it; Phases 0–4 are start-anytime.
Owner: decode / spec. Predecessors: PR #19 (DSpark paper code-complete +
serve-integrated + DeepSpec oracle), the first-live-run findings in
[dspark-handoff.md](../investigations/dspark-handoff.md) "FIRST LIVE RUN".

## The problem, in numbers (2026-07-07 first live run, loaded machine)

`gemma-4-12B-it-OptiQ-4bit` + `deepseek-ai/dspark_gemma4_12b_block7` (γ=7):

- **τ ≈ 2.8** committed tokens per target forward (2.7× fewer target calls) —
  the algorithm WORKS, at 26–33% per-token acceptance (the predicted
  OptiQ-4bit-target degradation vs their bf16 training).
- **Wall-clock LOST ~3.4×** (spec 14.6 vs serial 49.8 agg tok/s). The tax is
  the drafter itself: 6.9 GB bf16 → ~3 GB of weight reads per draft round
  (2 GB untied lm_head + 7 × 134 MB markov_w2 + layers), ~14 host syncs per
  round in the transcription-faithful `draftBlock`, tapped verifies falling
  back to the unoptimized monolith, and ~14 GB of two-model weights
  squeezing the 24 GB box.
- The 20 s bench TTFT was conc-4 queueing on the serial-forced spec lane
  (documented routing), not prefill — but per-request slowdown is real.

**Goal:** spec ≥ 1.3× serial decode on 12B at the best config, clean-machine
paired A/B — then (and only then) design when it's on by default. Every phase
has its own gate; the drafter-quantization thesis
([[drafter-quantization-thesis]]) makes the risky-looking phase (aggressive
quant) the SAFEST: drafter numerics only move acceptance, never correctness,
so the entire quality gate is one acceptance A/B.

**THE OBJECTIVE, stated right (Josh, 2026-07-07): 26–33% acceptance with the
bf16 drafter is the WORKABLE BASELINE — τ≈2.8 already pays. The question
quantization must answer is PRESERVATION: do we still get that number at
4-bit?** The point of quantizing (and of mixed precision specifically) is
never compression for its own sake — it's cutting the drafter's cost 4×
WITHOUT making it terrible at predicting tokens.

**Sensitivity is MEASURED, never guessed — and THE TOOL ALREADY EXISTS
(Josh): optiq's sensitivity method** (mlx-optiq.com/docs/sensitivity —
per-group simulate-quant → KL vs reference on a curated calibration mix →
greedy knapsack allocation to target BPW, emitted as a quant predicate).
Phase 1e adopts it for the drafter rather than inventing anything; the
drafter's target-hiddens-in forward even makes it cheaper (cached hiddens →
no 12B in the sweep loop). Allocation comes from the measured table;
hypotheses (lm_head argmax-proximal, chain compounding, buffered layers)
are recorded for falsification only. Phase 1.5 (fine-tune) is an OPTIONAL
UPSIDE lever on top of the workable baseline, not a premise that acceptance
is broken.

**And TurboQuant's role, stated right (Josh): TQ is the better-quant-at-
EQUAL-bits instrument — the preservation tool, not a compression ladder.**
Mechanism: distribute the weight vectors Gaussian, then place the
quantization levels non-uniformly with FINER step sizes around the peak
where the mass lives — affine 4-bit spends half its levels on tails TQ
barely pays for. Expected: TQ-4bit preserves acceptance better than
affine-4bit at the same size; the Phase-5 headline comparison is TQ-4 vs
affine-4 AT EQUAL BPW, with lower-bpw rungs only after that's won.

## Phase 0 — baseline + attribution (no code; Josh's shell for GPU runs)

The scoreboard everything else is measured against. All directional runs
fine on a loaded box; the FINAL pre/post pair must be clean-machine.

- [ ] **0a. Oracle gate the bf16 port ONCE** (before any optimization, so
  later acceptance deltas are attributable to quant/tuning, not port bugs):
  torch venv + DeepSpec install (header of
  `scripts/oracle-dspark-deepspec.py` documents setup), dump the temp-0
  trace (threshold 0 and 0.5 arms), run
  `scripts/dspark-deepspec-compare.ts` — target vs their reference on the
  **bf16 HF 12B** (`--target` the bf16 snapshot; the OptiQ-4bit arm is
  `--acceptance-only`, a measurement not a bit gate). Fixture per
  goldens/README.md conventions. Exit: round-for-round PASS, or a filed
  divergence with the first-divergent round attached.
- [ ] **0b. γ sweep, conc 1** (no code): serve with `--num-draft-tokens`
  ∈ {2, 3, 5, 7} × `bench-feature-matrix.ts --concurrency 1 --cells
  serial,spec`. Record per-request tok/s + acceptance + TTFT per γ. Exit: a
  table; the best-γ config is the Phase 1 comparison base.
- [ ] **0c. Time attribution**: xctrace (or coarse: MLX_BUN_LANE_DEBUG +
  timers around `source.draft` / verify forward / commit in a scratch
  branch) on ~20 rounds. Split: draft-block GPU, draft host syncs, verify
  forward, tap/commit overhead. Plus the paging check: RSS + `vm_stat`
  pageouts during a run (is the 14 GB pairing thrashing?). Exit: a
  percentage breakdown — it ORDERS phases 1–3 by measured value, replacing
  the estimates below.

## Phase 1 — quantize the drafter (uniform 4-bit baseline; NOT TurboQuant yet)

The expected big lever: 6.9 GB → ~1.8 GB kills bandwidth AND memory pressure.
mlx-native group quantization, no research dependency.

- [x] **1a. `scripts/dspark-quantize-drafter.ts`** *(DONE 2026-07-07 — thin
  driver over the house quantizer: `src/spec/dspark/quantize-drafter.ts`
  adds a `quantizePredicate` overlay (confidence_head kept bf16, recorded
  as the mlx `false` convention); load smoke = DeepspecDrafter reload +
  one quantized fc forward)* — reads a DeepSpec-format
  checkpoint dir, writes a quantized sibling (same config.json + arch stamp,
  plus the house `quantization: {bits, group_size}` block). Per-tensor
  policy:
  - QUANTIZE (group-64, 4-bit default, flag-tunable): every 2-D matmul
    weight — `layers.*.self_attn.{q,k,o}_proj`, `layers.*.mlp.{gate,up,
    down}_proj`, `fc`, `lm_head`, `markov_head.markov_w2`, and
    `embed_tokens` + `markov_head.markov_w1` as quantized-gather lookups
    (mlx QuantizedEmbedding semantics — mlx-lm quantizes embeddings; ours
    must match its gather-dequant numerics).
  - KEEP bf16: all norms, `layers.*.layer_scalar`, `confidence_head.proj.*`
    (tiny), biases.
  - Output verified loadable before exit (load smoke).
- [x] **1b. Quantized forward in `src/spec/dspark/deepspec-module.ts`**
  *(DONE 2026-07-07 — MatW/TableW weight representation: `.scales` sibling
  detection, quantized_matmul transpose=true for every Linear, mlx
  QuantizedEmbedding gather-dequant for embed_tokens/markov_w1; bf16 path
  keeps the lazy transpose views untouched; synthetic quantized-checkpoint
  describe block added — 8-bit tracks bf16 token-for-token)*:
  detect quantization at load (scales/biases sibling keys — the house
  detection pattern), route matmuls through `quantized_matmul` and lookups
  through the quantized-gather path; bf16 path untouched (both formats load
  through the same class — kind detection unchanged). Synthetic-format test
  extended with a tiny quantized checkpoint (same file, new describe block).
- [x] **1c. The acceptance A/B harness** *(DONE 2026-07-07 — runner drives
  `specServeRun` per arm (target loaded once, drafters sequential); spec
  telemetry extended with per-position draftedByPos/acceptedByPos; the
  stats/verdict math is model-free in `src/spec/dspark/ab-stats.ts`,
  unit-tested in tests/dspark-ab-stats.test.ts; chat-template rendering
  pins enable_thinking OFF)* — `scripts/dspark-drafter-ab.ts`:
  same target, same prompt set (≥32 prompts, temp 0), drafter A vs drafter
  B; reports per-position acceptance, τ, tok/s, and a paired verdict. This
  is THE gate for every quantization experiment from here on (Phase 5
  reuses it unchanged). Model-free logic unit-tested; the run itself is
  GPU/Josh.
- [ ] **1d. Run it**: 4-bit vs bf16 drafter at best-γ from 0b. Exit criteria:
  acceptance drop ≤ 3 points absolute AND wall-clock strictly improves;
  record both. If 4-bit alone flips spec past serial — say so loudly in the
  handoff, that's the headline.
- [ ] **1e. The MEASURED sensitivity map — ADOPT OPTIQ'S METHOD, don't
  invent** (mlx-optiq.com/docs/sensitivity; source readable in the oracle
  venv's `site-packages/optiq`). Their loop, verbatim: reference logits on
  calibration data → simulate-quantize ONE group (quantize→dequantize
  round-trip) → KL divergence on the full output distribution → restore →
  next (group, bits); then their greedy knapsack (max KL-reduction per
  extra bit) allocates to a target BPW. **Applied to the drafter it gets
  CHEAPER than optiq's own runs**: the drafter isn't mlx_lm-loadable
  (its forward needs target hiddens), so `optiq convert` can't run on it
  directly — but that same fact removes the 12B from the loop entirely.
  Cache tapped hiddens ONCE over an optiq-style 6-domain calibration mix
  (our PATH-B shard format stores exactly this), then the whole sweep is
  drafter-forward-only KL: 3B × ~10 groups × candidate bits = minutes.
  The knapsack's output config gets ONE end-to-end acceptance A/B (1c
  harness) as confirmation — KL is the search signal, acceptance is the
  ship gate. Their protected-tensor defaults (lm_head/embed highest bits,
  first/last blocks) are noted as the static prior their own exact method
  exists to replace — we run the exact method; the drafter is small.

## Phase 1.5 — acceptance upside (OPTIONAL; the baseline is already workable)

26–33% (τ≈2.8) with the bf16 drafter pays as-is — this phase is the
opportunistic numerator work on top, NOT a precondition: the gap vs their
bf16-target numbers is distribution shift with a known mechanism, and every
point recovered multiplies the cost work. Run it if Phase 1's preserved
acceptance + cost win lands short of the ≥1.3× goal, or whenever the upside
is worth the run.

- [ ] **1.5a. Adaptation fine-tune on OUR target's hiddens** — their
  checkpoint as init (the expensive pretraining is done; this is short
  distribution adaptation, not their 10-epoch/38 TB run). The data comes
  from OUR stack by construction: tap `[5,17,29,41,46]` hidden dumps from
  the OptiQ-4bit 12B over on-distribution generations (the PATH-B regen
  tooling extracts exactly this). OPEN DESIGN (resolve first): where the
  gradient runs — (a) export our tapped-hidden shards into DeepSpec's
  torch trainer format and fine-tune with THEIR code (MIT; least new code,
  needs a torch box/venv and a shard-format bridge), vs (b) a training
  path for the deepspec module in our stack (autograd through the port —
  more work, fully local). Gate: acceptance A/B (1c harness) pre/post
  fine-tune on held-out prompts; expected: a large chunk of the
  bf16-vs-OptiQ gap closes.
- [ ] **1.5b. Confidence-threshold activation** — at 26% acceptance the
  scheduler is finally in its design regime: sweep the raw threshold
  (their knob) and/or our calibrated thresholds; objective =
  tokens-per-second, not τ (pruning doomed positions trades a little τ
  for less wasted draft+verify work). Free: no code, the machinery
  shipped in PR #19.
- [ ] **1.5c. Quantify the target-fidelity axis** (measurement, not a
  build): acceptance vs target quant — e.g. the same drafter against a
  higher-fidelity 12B variant if one fits (mixed/8-bit tap-layer
  experiments), to split "drafter needs adapting" from "target hiddens
  are too degraded". Informs whether 1.5a alone suffices.

## Phase 2 — tighten `draftBlock` (replay the proven tightening)

`Gemma4DSparkModel.draftBlock` kept the reference's per-position structure
(transcription fidelity): 7 argmax `itemUint32` syncs + 7 confidence
`toFloat32` syncs per round. We already solved this exact shape once
(module-dflash.ts, 2026-07-06 — bit-identity-pinned).

- [ ] **2a. On-device token chaining**: the sequential Markov loop keeps the
  argmax result as a device `[1]` index feeding the next position's
  `takeAxis(markov_w1, ·)`; ONE concat + ONE host read after the loop.
  (Post-1b the bias matmul is quantized too.)
- [ ] **2b. Confidence: compute NOTHING at threshold ≤ 0** (their default —
  today we compute + sync 7 confidences that are then unused); when a
  threshold IS set, per-position reads are inherent to the truncation
  decision (same reasoning as the dflash loop — document it).
- [ ] **2c. `collectLogits`-style skip** for `baseLogits` if the serve path
  still materializes anything it discards (audit `DeepspecSource.draft` —
  it disposes `block.baseLogits` unread; make the module skip building it,
  mirroring `DflashDraftOpts.collectLogits`).
- [ ] **Gate**: bit-identity — pinned tokens on the deterministic synthetic
  checkpoint pre/post rewrite (the tests/dspark-infer-loop.test.ts
  pattern), plus real-checkpoint determinism (same prompt twice → same
  drafts). Tightening is a pure optimization; any token change is a bug.

## Phase 3 — `captureLayer` in the generated gemma forwards

Tapped spec forwards (prefill + EVERY verify round) currently fall back to
the monolith (the 2026-07-07 guard fix — correct-but-unspecialized). The
verify forward is the spec path's biggest single GPU cost; give it back the
generated fast path. Independent of Phases 1–2; parallelizable.

- [ ] **3a. `scripts/gen-model.ts`**: emit the tap exactly as the monolith
  does — `captureLayer(i, h)` after each layer's residual
  (gemma4.ts:970 semantics) + the post-finalNorm sentinel
  (index = nLayers, gemma4.ts:989) — and REMOVE `this.hiddenTap !== null`
  from the emitted fallback guard.
- [ ] **3b. Regenerate all three** (12b / 26b / e4b; regen commands in each
  file's header) — the hand-patched guards are superseded by generator
  output.
- [ ] **Gate**: (i) generated-parity suite green (untapped behavior
  untouched); (ii) NEW tap-parity check — tapped rows bit-equal
  monolith-vs-generated on the same input (model-gated test, e4b);
  (iii) spec bench pre/post for the verify-round win.

## Phase 4 — serving UX: flags, defaults, composition (the product pass)

Decisions, made on Phase 0–3 DATA, then implemented. The doctrine rails:
drop-in-replacement (a lone request must never get slower because a flag
exists), dont-delete-optionality (losing configs stay documented
default-off), spec = opt-in until it WINS a clean-machine paired A/B.

- [ ] **4a. γ default per drafter kind**: the checkpoint's trained γ is the
  cap, not necessarily the default — if 0b says γ=3 beats γ=7 at our
  acceptance, `numDraftTokens` defaults to the measured-best (per-kind
  table in code, overridable), and the handoff documents why.
- [ ] **4b. Quantized-drafter UX**: `mlx-bun get` the bf16 →
  `scripts/dspark-quantize-drafter.ts` is a manual step today; decide
  whether `serve --draft-model <bf16-dir>` should offer/auto-run the
  4-bit conversion (like the starter-model flow) or just print the
  command. Also: registry listing shows drafters distinctly (they are not
  servable models — `/v1/models` must NOT list them; verify).
- [ ] **4c. Spec × prompt-cache composition** (parity-plan §7.6 — currently
  BYPASSED on the spec path, v1 note in serve-loop.ts): multi-turn agents
  re-prefill every turn when a draft is mounted. Scope it here or
  explicitly re-defer with the measured cost (12B multi-turn TTFT with
  spec on). At minimum: the boundary-snapshot machinery must not regress
  when spec is mounted.
- [ ] **4d. Surface audit**: `--draft-kind` (keep), `--num-draft-tokens`
  semantics doc, `/stats` shows mounted drafter + kind + γ, `usage.
  speculation` already ships. server-config.md gets a "speculative
  serving" section consolidating the four kinds + the when-does-it-pay
  table (from Phase 0/1 data). features-matrix + cli.md + README rows.
- [ ] **4e. The default decision, written down**: for each (model, drafter)
  pair measured, spec default on/off per the clean-machine A/B — recorded
  in RESULTS.md "composition" + the features matrix. (Prediction to test:
  ON for 12B+quantized drafter, OFF for e4b anything.)

## Phase 5 — TurboQuant application (the trigger event)

Trigger, precisely: **TQ WEIGHT quantization** in the convert tooling — PR
#20 (2026-07-07) landed TurboQuant for KV; the rotation-based weight-side
is the noted follow-up (turboquant-kv.md), and it's what the drafter
needs. The drafter is its lowest-risk first customer — one-number gate,
no KL/eval battery. **TQ's HYPOTHESIS here is PRESERVATION AT EQUAL BITS**
(Gaussian-distributed vectors + finer step sizes around the peak, where
affine spends half its levels on tails) — a hypothesis 5b MEASURES, never
a default: TurboQuant earns its place the same way everything in this
repo does.

- [ ] **5a.** Extend `dspark-quantize-drafter.ts` with the TurboQuant
  scheme.
- [ ] **5b. THE HEADLINE: TQ-4bit vs affine-4bit AT EQUAL BPW** through the
  Phase-1c harness — same size, whose acceptance is closer to bf16? If
  affine-4 bled in 1d, this is the expected fix; if affine-4 held, TQ's
  margin becomes headroom for lower rungs. Only AFTER TQ-4 ≥ affine-4:
  the lower-bpw ladder (3.5 / 3.0 / 2.5) → acceptance-per-byte curve,
  knee adopted (dont-delete-optionality for the rest).
- [ ] **5b″. TQ IS HOW, SENSITIVITY-AWARE IS WHAT (Josh)** — two orthogonal
  axes, never mixed: TQ vs affine is a METHOD question (decided by 5b's
  equal-bpw measurement — a method that wins at equal bits wins for every
  tensor, so there is no reason to mix METHODS within an artifact);
  sensitivity is the bit ALLOCATION question (the 1e knapsack, whatever
  the method — candidate set {method-2, method-3, method-4, method-8} per
  group, measured KL cost each, greedy to target BPW). IF 5b confirms TQ,
  the artifact is TQ-uniform at knapsack-allocated bits; if it doesn't,
  affine-uniform at knapsack-allocated bits — either way the OUTCOME of
  the measurement, not a premise. Nothing here is "on by default";
  defaults are Phase 4e/6 decisions made on clean-machine numbers.
- [ ] **5b′. PER-TENSOR MIXED PRECISION rungs** (Josh, 2026-07-07). The
  intuition "only 5 layers = few knobs" undercounts: the drafter's mass is
  ~10 TENSOR GROUPS, and two of them are 58% of the bytes — `lm_head`
  (~2 GB, read FULLY every round: the bandwidth whale) and `embed_tokens`
  (~2 GB, gather-only: ~free to read, pure resident-memory win), plus
  `markov_w2` (134 MB read ×7/round ≈ 940 MB). Both whales only shape the
  DRAFT distribution → acceptance-only risk. Mixed rungs to sweep: 3-bit
  lm_head + 3-bit markov_w2 + 4-bit layers; 2-bit embed variants; k_proj
  (2 M params) 8-bit for free. The ~10-group space is small enough for a
  near-exhaustive sweep through the SAME one-number harness — unlike
  sensitivity search on a full model. **Allocation objective (the point):
  PRESERVE the bf16 acceptance at the smallest cost, not minimize bytes —
  and allocation follows the MEASURED sensitivity table from 1e, never a
  prior.** The mixed rungs are built FROM the table: give the measured-
  sensitive groups more bits (or TQ them, post-Phase-5), squeeze the
  measured-insensitive ones. The "only 5 layers" worry dissolves either
  way — the tensor-group space (~10 knobs, two of them 58% of the bytes)
  is the real granularity, and 1e prices every knob empirically.
- [ ] **5c.** If TurboQuant wins: fold the recipe into 4b's UX (the
  conversion the server offers is the TurboQuant one).

## Phase 6 — quotable results + promotion

- [ ] Clean-machine protocol (reboot + `sudo purge`), then: bench-feature-
  matrix conc-1 AND agg×4, serial vs best-spec-config, on 12B (and e4b as
  the expected-negative control). Promote to `benchmarks/RESULTS.md`
  "composition"; update decode-speed-program.md (lever 1c: measured),
  STATUS, and the handoff's FIRST LIVE RUN section with the closing
  numbers.
- [ ] Loose ends carried from PR #19, closed or re-deferred with reasons:
  the paper-faithful gated RNN head (seqHead:"gru", currently variant-
  documented), paper-Alg-1/STS survival-product scheduler (Lab item),
  per-slot spec under batching (unified-engine frontier row — NOT this
  program).

## Dependency graph + who does what

```
0a (oracle gate, Josh: venv+GPU) ──┐
0b (γ sweep, Josh: GPU)  ──────────┼─→ 1a→1b→1c→1d (quant baseline; 1d Josh GPU)
0c (attribution, Josh: GPU) ───────┘        │
                                            ├─→ 1.5 (OPTIONAL acceptance
                                            │    upside: fine-tune on our
                                            │    target's hiddens + threshold
                                            │    sweep; run if 1's preserved
                                            │    acceptance falls short)
                                            ├─→ 2a-2c (tightening; CPU-gated)
3a-3b (generator tap; parallel anytime) ────┤
                                            └─→ 4 (UX, needs 0–3 data)
TurboQuant merge ─→ 5a-5c (reuses 1c harness) ─→ 6 (clean machine, Josh)
```
Priority note: Phase 1's PRESERVATION question ("do we keep 26–33% at
4-bit?") is the program's hinge — one A/B answers it; if affine-4 bleeds,
the answers are MEASURED (1e sensitivity table → mixed allocation) and
ENGINEERED (Phase 5: TQ-4 at equal bpw — the better quant is the designed
fix, not a fallback).

Code phases (1a/1b/2/3/4-impl) are agent-runnable sessions; every GPU
measurement is Josh's shell. Nothing except Phase 5 waits on TurboQuant —
Phases 0–4 can land first so TurboQuant drops into a finished harness.

## Exit criteria for the whole program

1. Spec wall-clock ≥ 1.3× serial on 12B at the recommended config,
   clean-machine paired — or a written verdict that it can't be reached and
   why (with the config left as a characterized default-off lever).
2. **Acceptance PRESERVED and understood**: the quantized drafter holds the
   bf16 baseline's 26–33% (or the mixed rung that does is adopted, or the
   loss is measured and accepted with numbers); the optional 1.5 upside
   levers are run-or-explicitly-deferred — the drafter predicts tokens;
   small was never the goal.
3. The acceptance-per-byte curve exists (TurboQuant vs 4-bit vs mixed vs
   bf16), with acceptance-at-fixed-budget allocation swept (5b′).
4. The serving surface is documented, defaults decided per-pair and
   recorded, and a fresh `mlx-bun get` → serve → speedup flow works without
   reading any design doc.
