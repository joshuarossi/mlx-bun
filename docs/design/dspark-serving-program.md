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

- [ ] **1a. `scripts/dspark-quantize-drafter.ts`** — reads a DeepSpec-format
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
- [ ] **1b. Quantized forward in `src/spec/dspark/deepspec-module.ts`**:
  detect quantization at load (scales/biases sibling keys — the house
  detection pattern), route matmuls through `quantized_matmul` and lookups
  through the quantized-gather path; bf16 path untouched (both formats load
  through the same class — kind detection unchanged). Synthetic-format test
  extended with a tiny quantized checkpoint (same file, new describe block).
- [ ] **1c. The acceptance A/B harness** — `scripts/dspark-drafter-ab.ts`:
  same target, same prompt set (≥32 prompts, temp 0), drafter A vs drafter
  B; reports per-position acceptance, τ, tok/s, and a paired verdict. This
  is THE gate for every quantization experiment from here on (Phase 5
  reuses it unchanged). Model-free logic unit-tested; the run itself is
  GPU/Josh.
- [ ] **1d. Run it**: 4-bit vs bf16 drafter at best-γ from 0b. Exit criteria:
  acceptance drop ≤ 3 points absolute AND wall-clock strictly improves;
  record both. If 4-bit alone flips spec past serial — say so loudly in the
  handoff, that's the headline.

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

When TurboQuant (Phase 13) merges: the drafter is its lowest-risk first
customer — aggressive bpw, one-number gate.

- [ ] **5a.** Extend `dspark-quantize-drafter.ts` with the TurboQuant
  scheme(s); produce a bpw ladder (4.0 / 3.5 / 3.0 / 2.5) of drafter
  artifacts.
- [ ] **5b.** Run the Phase-1c A/B harness across the ladder →
  **acceptance-per-byte curve** vs the uniform-4-bit baseline. Adopt the
  knee as the recommended artifact; keep the ladder results in the
  investigation doc (dont-delete-optionality).
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
                                            ├─→ 2a-2c (tightening; CPU-gated)
3a-3b (generator tap; parallel anytime) ────┤
                                            └─→ 4 (UX, needs 0–3 data)
TurboQuant merge ─→ 5a-5c (reuses 1c harness) ─→ 6 (clean machine, Josh)
```

Code phases (1a/1b/2/3/4-impl) are agent-runnable sessions; every GPU
measurement is Josh's shell. Nothing except Phase 5 waits on TurboQuant —
Phases 0–4 can land first so TurboQuant drops into a finished harness.

## Exit criteria for the whole program

1. Spec wall-clock ≥ 1.3× serial on 12B at the recommended config,
   clean-machine paired — or a written verdict that it can't be reached and
   why (with the config left as a characterized default-off lever).
2. The acceptance-per-byte curve exists (TurboQuant vs 4-bit vs bf16).
3. The serving surface is documented, defaults decided per-pair and
   recorded, and a fresh `mlx-bun get` → serve → speedup flow works without
   reading any design doc.
