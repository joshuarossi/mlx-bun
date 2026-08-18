# DSpark — handoff

**State (2026-07-06): the DSpark paper is CODE-COMPLETE and serve-integrated.**
Architecture proven correct (overfit τ=3.24, paper-range); serve-integrated
behind `--draft-model` (Phase 1 — the `DraftSource` seam is KV-borrowing-ready;
sibling AssistantSource verified bit-lossless on real weights,
`tests/spec-serve-assistant.test.ts`); and every remaining paper component
landed in Phase 2 the same day: Alg-1 confidence-scheduled draft-length pruning
(checkpoint-driven, zero change for uncalibrated checkpoints), STS calibration
(§3.2.1, `calibration.ts` + `scripts/dspark-calibrate.ts`), the RNN sequential
head (Eq 6, `--seq-head rnn`, init-equivalent to Markov), the tightened draft
loop (on-device token chaining + deferred conf reads + `collectLogits:false`
on serve — bit-identity pinned), and the `dspark` variant rename + central
loader. Suites: smoke 21/21 · dspark tests 17/17 · adjacent server suites
green. **What remains is exactly the GPU work below** — data scale + 12B
retarget + train + calibrate + measure; e4b not netting a speedup is a
data/target-speed problem, not architecture. Full design:
[docs/design/dspark-speculative-decoding.md](../design/dspark-speculative-decoding.md).

## PATH A (preferred, no training) — DeepSeek's published 12B drafter

DeepSeek released a TRAINED drafter for our exact target:
`deepseek-ai/dspark_gemma4_12b_block7` (6.86 GB bf16, γ=7; DeepSpec repo is
the MIT reference impl + the oracle — see the "DeepSpec ground truth" section
of the design doc). Once the deepspec-variant port lands:

```sh
# 1. download the trained drafter (~6.9 GB)
mlx-bun get deepseek-ai/dspark_gemma4_12b_block7
# 2. oracle gate: dump their reference trace (temp 0 = RNG-free deterministic)
#    in a torch venv, then compare ours round-for-round (scripts staged)
# 3. measure + serve (auto-detected via config.json architectures field)
mlx-bun serve --model gemma-4-12B-it-OptiQ-4bit --draft-model <snapshot-of-dspark_gemma4_12b_block7>
```

### Oracle protocol (step 2, expanded)

Two staged scripts implement the temp-0 deterministic trace protocol against
DeepSpec's own reference implementation (github.com/deepseek-ai/DeepSpec, MIT).
At temperature 0 their leaky-rejection verify degenerates to exact argmax
token-match — the whole round trace is RNG-free and reproducible, so a
plain round-for-round diff is a real bit-exact gate (same discipline as the
D2 diffusion oracle, minus RNG parity entirely — see the design doc's
"DeepSpec ground truth" section).

```sh
# a. dump the reference trace — needs its OWN torch venv (NOT the mlx-lm
#    oracle venv at /Users/joshrossi/Code/mlx-lm/.venv, which has no
#    torch/deepspec and shouldn't); see the script header for the exact
#    venv-setup + pip install steps.
.venv-deepspec/bin/python scripts/oracle-dspark-deepspec.py \
    --target <snapshot-dir-of-google/gemma-4-12B-it> \
    --drafter <snapshot-of-dspark_gemma4_12b_block7> \
    --data prompts.jsonl --n 8 --max-new-tokens 128 \
    --temperature 0 --confidence-threshold 0 \
    --out goldens/dspark-deepspec/trace-thr0.jsonl

# b. compare our port round-for-round
bun scripts/dspark-deepspec-compare.ts \
    --fixture goldens/dspark-deepspec/trace-thr0.jsonl \
    --target gemma-4-12B-it-bf16 --drafter <snapshot-of-dspark_gemma4_12b_block7>
```

Run the pair twice — once at `--confidence-threshold 0` (no pruning), once at
`0.5` — to gate both the base draft loop and the confidence-truncation path.

Fixture location: `goldens/dspark-deepspec/*.jsonl` follows the house
manifest convention (goldens/README.md) — these are machine-independent
**JSON manifests** (prompts + token-id traces, no tensor blobs), so they are
the **tracked** kind, not the `.bin` machine-specific kind. Regenerate by
rerunning step (a); there is no `scripts/regen-*` wrapper for this family yet
since the oracle run needs its own GPU-hosting torch venv, not the mlx-lm
oracle venv this repo otherwise standardizes on.

**The OptiQ-4bit caveat is load-bearing, not a footnote**: the fixture above
is generated against the bf16 HF target. A `dspark-deepspec-compare.ts` run
with `--target` pointing at our bf16 12B is the TRUE bit-exact gate. A run
with `--target` pointing at the OptiQ-4bit-quantized 12B we actually serve is
a **separate acceptance-rate measurement** — tapped hiddens differ
numerically at 4-bit, so round-for-round divergence there is expected, not a
bug; pass `--acceptance-only` on that arm so the script reports an aggregate
accept-length reading instead of a PASS/FAIL assert.

Caveat: trained against the bf16 HF target; our serving 12B is OptiQ-4bit —
tapped hiddens differ numerically, so measure acceptance rather than assuming
their 60–85%.

**FIRST LIVE RUN (2026-07-07, loaded machine — directional only):** τ ≈ 2.8
committed/target-forward (200 tok / 72 verify rounds; per-token acceptance
26–33% — the predicted OptiQ-4bit degradation), output coherent, losslessness
holding. **But wall-clock LOST ~3.4×** (spec 14.6 vs serial 49.8 agg tok/s;
the 20 s bench TTFT is conc-4 queueing on the serial-forced spec lane, not
prefill). The tax is the drafter itself. **The full step-by-step program for
the next pass is
[docs/design/dspark-serving-program.md](../design/dspark-serving-program.md)**
(phases, gates, dependency graph; pickup at TurboQuant merge, only its
Phase 5 waits for it). Lever summary:
1. **Quantize the drafter** — the big one, and the ideal quantization target
   PERIOD: drafter numerics only move ACCEPTANCE, never correctness
   (losslessness is structural), so aggressive bpw is safe and the gate is a
   single acceptance A/B. 6.9 GB bf16 → ~1.8 GB @4-bit kills both the
   ~3 GB/round bandwidth tax (2 GB lm_head + 7×134 MB markov_w2 reads) and
   the 14 GB two-model memory pressure on 24 GB. Uniform 4-bit (mlx-native)
   first as the baseline; **TurboQuant (Phase 13), when it lands, competes
   on acceptance-per-byte against that baseline** — the drafter is its
   lowest-risk first customer. Enabler either way: quantized-weight support
   in deepspec-module's forward (quantized_matmul, the house pattern).
2. **Tighten deepspec draftBlock** — ~14 host syncs/round (7 argmax + 7
   confidence reads); replay the on-device chaining + deferred-conf
   tightening already done for our own module (threshold=0 needs NO conf
   reads).
3. **captureLayer in the GENERATED gemma forwards** — tapped verifies
   currently fall back to the monolith (correct-but-unspecialized); teach
   scripts/gen-model.ts to emit the tap so spec verifies keep the fast path.
4. **γ sweep** — γ=7 at ~30% acceptance wastes drafts;
   `--num-draft-tokens 2..3` may net better wall-clock free of any code.

## PATH B — train our own module (custom targets / research)

The payoff target is **12B** (27B is memory-infeasible to train on 24 GB; the
pipeline stays dim-generic so 27B remains a future recipe). All three scripts
take `--model` and (new, 2026-07-06) `--tap-layers` — the retarget is now a
pure parameterization, no code edits. **`--tap-layers` MUST be identical across
regen and train** (the shard feature dim is `m*H`, `m = tapLayers.length`).

12B tap set: use **`5,17,29,41,46`** — DeepSeek's actual trained
`target_layer_ids` for this model (their layer-output convention matches our
tapLayers indexing; audited 2026-07-06). Our earlier `24,37,47,48` guess is
superseded.

```sh
# 0. one-time: cache the 12B target + a prompt/topic corpus (thousands of
#    on-distribution topics — the data-scale lever; 160 only reached per-pos ~0.17).
mlx-bun get mlx-community/gemma-4-12B-it-OptiQ-4bit
# (12B target may need the serve process stopped to free memory for regen.)

# 1. regen multi-layer training shards from the 12B target's own generations
bun scripts/dspark-regen-dflash.ts \
  --model gemma-4-12B-it-OptiQ-4bit --tap-layers 5,17,29,41,46 \
  --topics <thousands-of-topics.txt> --out data/dspark-12b --max-resp 320

# 2. train the drafter against the 12B (warm-start survivable via --resume;
#    GPU runs kept getting killed ~step 5000 pre-resume). Optional A/B:
#    --seq-head rnn trains the Eq-6 RNN head instead of Markov (Eq 5).
bun scripts/dspark-train-dflash.ts \
  --model gemma-4-12B-it-OptiQ-4bit --tap-layers 5,17,29,41,46 \
  --data data/dspark-12b --out ckpt/dspark-12b \
  --iters 8000 --batch 8 [--seq-head rnn] [--ddraft 2560] [--resume ckpt/dspark-12b]

# 3. STS-calibrate (§3.2.1): fit per-position confidence thresholds on real
#    verify outcomes and stamp them into dspark.json — this ACTIVATES the
#    Alg-1 confidence scheduler at decode (uncalibrated = fixed-γ, no change).
bun scripts/dspark-calibrate.ts \
  --model gemma-4-12B-it-OptiQ-4bit \
  --drafter ckpt/dspark-12b --data <prompts.jsonl> [--target 0.5]

# 4. measure live τ + tok/s vs vanilla 12B decode (clean machine — dirty
#    numbers are garbage). Run BOTH pre- and post-calibration for the
#    scheduler's own A/B (MLX_BUN_DSPARK_MINCONF=<c> = manual uniform knob).
bun scripts/dspark-measure-dflash.ts \
  --model gemma-4-12B-it-OptiQ-4bit \
  --drafter ckpt/dspark-12b --data <prompts.jsonl>

# 5. serve it (auto-detected as kind=dspark via dspark.json; γ pinned to cfg.gamma)
mlx-bun serve --model gemma-4-12B-it-OptiQ-4bit --draft-model ckpt/dspark-12b
```

Decision gate (write it down, RESULTS.md only if clean-machine): does 12B live
τ net a wall-clock win? If the draft loop dominates, do the loop-tightening
(per-position host syncs + double 262K LM-head) first — see the open items in
the design doc. Memory guard (`server.ts`) caps context to fit; a client
sending huge `max_tokens` trips admission — lower it.

## What happened (short version)
- Built v1 first as a single-vector shortcut — it dropped the paper's core KV
  injection and was never really DSpark. Chunk (τ≈1.26) and article (τ≈1.16)
  runs on it were misleading.
- Rebuilt the **faithful** DFlash (multi-layer H_ctx injected into every draft
  layer, 5 layers) in parallel `*-dflash.ts` files (v1 kept as baseline; repo
  stays green).
- Found + fixed an **off-by-one in the p^t target** (TV loss trained against a
  distribution shifted one token — present in v1 too, so all prior τ were bogus).
- **Overfit test settled it:** 3 articles, eval on same → per-pos ~0.75, τ=3.24.
  The architecture reaches the paper's numbers; the plateau at ~0.17 on 160
  articles is data-starvation, not capacity (confirmed: width 1024 vs 2560 both
  plateau ~0.17).
- **Target-speed is the other half.** Measured decode: e4b 45.9, 12b 27.5, 27B
  ~15 tok/s. The fixed draft overhead only amortizes on a slow target — so e4b
  is ~worst-case for spec decode; the **27B agentic workload is the real target**
  (τ≈3 there could plausibly net ~2–3× → 15 → ~35–45 tok/s).

## Verified / working
- Parity-safe `hiddenTap` multi-layer extraction (`gemma4.ts`), no-op when off.
- `trim(n, bypass=true)` physical-slice rollback past the sliding window (`gemma4-base.ts`) — lossless gate held on 6K context.
- CPU smoke 16/16 (`dspark-dflash-smoke.ts`): KV-injection forward, autograd, inference, multi-layer variable-context data round-trip.
- Training `--resume` (warm-start from checkpoint) — the GPU runs kept getting killed ~step 5000; resume survives that.

## Next (in priority order)
1. **Retarget to 12B + scale data + train + calibrate + measure** — the GPU
   recipe above is the complete remaining work. (27B stays a future recipe:
   memory-infeasible to train on the 24 GB M4 Pro.)
2. ~~Tighten the draft inference loop~~ **DONE 2026-07-06** (on-device token
   chaining, deferred conf reads, `collectLogits:false`; bit-identity pinned).
3. ~~Finish the paper~~ **DONE 2026-07-06**: RNN head (Eq 6, `--seq-head rnn`),
   STS calibration (§3.2.1), Alg-1 confidence-scheduled draft-length pruning
   (single-user form). ⚠ Eq 6 + §3.2.1 shapes are design-doc-faithful readings
   (paper PDF absent) — verify against the paper when available.
4. ~~Rename `dflash`→`dspark`~~ **DONE 2026-07-06** (canonical variant +
   central loader `src/spec/dspark/loader.ts`; legacy stamps still load).

## Key files
`src/spec/dspark/{module,data,generate}-dflash.ts`, `{loss,sample,calibration,loader}.ts`;
`src/spec/{source,serve-loop,dflash-source,assistant-source}.ts` (the serve seam);
`src/model/gemma4.ts` (hiddenTap), `gemma4-base.ts` (trim bypass);
`scripts/dspark-{regen,train,measure}-dflash.ts`, `dspark-dflash-smoke.ts`.

## Memory / gotchas
- `dspark-drafter-built-v1`, `dont-inflate-scope-build-the-paper` (the lesson:
  build the paper's mechanism first — the faithful build was ~1hr; the wrong
  builds cost the session).
- e4b hidden_size = **2560** (not 2816 — a different config block). Module reads dims live.
- Memory admission guard (`server.ts:1538`) rejects `prompt+max_tokens > maxSafeContext`
  because a mid-gen GPU OOM SIGKILLs the server. 27B/32GB caps ~22.5k; a client
  sending `max_tokens=64k` trips it — lower max_tokens (or make it a runtime stop).
