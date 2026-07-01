# DSpark — handoff

**State:** faithful DSpark (DFlash KV-injection + Markov + confidence) is **built
and proven architecturally correct** (overfit τ=3.24, paper-range). It does not
yet net a speedup on e4b — that's a data-scale + target-speed problem, not an
architecture problem. Full design + measured numbers:
[docs/design/dspark-speculative-decoding.md](../design/dspark-speculative-decoding.md).

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
1. **Retarget to a slow model (27B or 12b).** The drafter reads dims from the
   model + tapLayers is config, so it ports — but needs regen+train on that
   model. 27B on 32GB is memory-tight (17.75GB weights); may need the serve
   process stopped to free the ~14GB for regen. This is where a real speedup lives.
2. **Scale training data** — thousands of on-distribution generations (not 160)
   to lift generalizing τ toward the overfit ~0.75.
3. **Tighten the draft inference loop** — per-position host syncs + double 262K
   LM-head make the draft heavy; needed for τ to translate to wall-clock.
4. **Finish the paper:** RNN head (Eq 6), STS calibration (§3.2.1), hardware-aware
   prefix scheduler (Alg 1 — single-user = confidence-scheduled draft-length pruning).
5. **Rename** `dflash`→`dspark` (faithful module IS DSpark; v1 = legacy single-vector).

## Key files
`src/spec/dspark/{module,data,generate}-dflash.ts`, `{loss,sample}.ts`;
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
