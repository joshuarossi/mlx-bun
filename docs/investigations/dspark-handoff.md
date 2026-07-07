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

## GPU run recipe — 12B retarget (Josh's shell; agent-spawned runs get reaped)

The payoff target is **12B** (27B is memory-infeasible to train on 24 GB; the
pipeline stays dim-generic so 27B remains a future recipe). All three scripts
take `--model` and (new, 2026-07-06) `--tap-layers` — the retarget is now a
pure parameterization, no code edits. **`--tap-layers` MUST be identical across
regen and train** (the shard feature dim is `m*H`, `m = tapLayers.length`).

12B has 48 layers → tap set `24,37,47,48` (mid / late / last / post-finalNorm
sentinel = `layers.length`); tune if desired.

```sh
# 0. one-time: cache the 12B target + a prompt/topic corpus (thousands of
#    on-distribution topics — the data-scale lever; 160 only reached per-pos ~0.17).
HF_HUB_DISABLE_XET=1 hf download mlx-community/gemma-4-12B-it-OptiQ-4bit
# (12B target may need the serve process stopped to free memory for regen.)

# 1. regen multi-layer training shards from the 12B target's own generations
bun scripts/dspark-regen-dflash.ts \
  --model gemma-4-12B-it-OptiQ-4bit --tap-layers 24,37,47,48 \
  --topics <thousands-of-topics.txt> --out data/dspark-12b --max-resp 320

# 2. train the drafter against the 12B (warm-start survivable via --resume;
#    GPU runs kept getting killed ~step 5000 pre-resume). Optional A/B:
#    --seq-head rnn trains the Eq-6 RNN head instead of Markov (Eq 5).
bun scripts/dspark-train-dflash.ts \
  --model gemma-4-12B-it-OptiQ-4bit --tap-layers 24,37,47,48 \
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
