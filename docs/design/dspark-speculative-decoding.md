# DSpark speculative decoding for mlx-bun

Implementation of DeepSeek's **DSpark** ("Confidence-Scheduled Speculative
Decoding with Semi-Autoregressive Generation", `DSpark_paper.pdf`) against this
repo's models. DSpark = a **DFlash** parallel backbone (KV-injected, all γ draft
tokens in one pass) **+ a lightweight sequential head** (Markov, Eq 5, or RNN,
Eq 6) that adds intra-block dependency (the *semi-autoregressive* part) **+ a
confidence head → STS calibration → hardware-aware prefix scheduler**. Decode
becomes draft → verify → accept; output is lossless (bit-identical to the target
at any temperature); only decode speed (τ) changes.

> **DFlash vs DSpark:** DFlash is *only* the parallel backbone (prior work) and
> suffers suffix decay. DSpark adds the sequential head + confidence-scheduled
> verification. The sequential Markov head is what makes this DSpark.

## Two implementations (flag-selected, both in `src/spec/dspark/`)

| | `module.ts` (v1) | `module-dflash.ts` (v2, **the real one**) |
|---|---|---|
| context | **single vector** (final hidden at the anchor) fused as one token | faithful **multi-layer KV injection** (Eq 2–3): H_ctx = RMSNorm(W_c·[H^{l1};…;H^{lm}]) over the FULL context, re-projected into every draft layer's K/V |
| layers | 2 | 5 |
| status | **superseded** — dropped the paper's core idea (kept as baseline) | the actual DSpark model (Markov variant) |

v1 was a shortcut that removed the load-bearing mechanism; it never tested the
paper. v2 is faithful. Checkpoints stamp `variant` in `dspark.json`; the runtime
loads the matching module. (`variant:"dflash"` should be renamed to `"dspark"` —
see Open items.)

## The mechanism (v2, paper Eq 2–3)

- **Eq 2 (context):** tap the target's hidden states at layers `{l1…lm}` (e4b
  default {20,31,41,42}, the last = post-finalNorm), concat on the feature axis,
  project to the draft width: `H_ctx ∈ [L_ctx, d]`. Extraction via a parity-safe
  `model.hiddenTap` (no-op when off) added to `gemma4.ts` `forwardLayers`.
- **Eq 3 (injection):** every draft layer forms `K_i=[W_i^K H_ctx; W_i^K H_d]`,
  `V_i` likewise, `Q_i=W_i^Q H_d`; the γ-block queries attend bidirectionally
  over `[context ++ block]`. Context is read-only memory re-projected fresh each
  layer. The draft projects the target's HIDDEN STATES with its OWN Wk/Wv (not
  the target's K/V — that's the separate `GemmaAssistantDrafter` baseline).
- **Markov head (Eq 5):** `B_k = W1[x_{k-1}]·W2`, r=256, W2=0 init → starts as
  pure DFlash, τ climbs as intra-block dependency is learned.
- **Confidence head (Eq 7):** `c_k = σ(wᵀ[h_k; W1[x_{k-1}]])`.
- **Loss (Eq 9–12):** `0.1·CE + 0.9·TV + 1.0·BCE`, position-weighted.
- **Lossless verify** (`generate-dflash.ts`): greedy = longest-prefix match;
  temp>0 = `min(1,p/q)` accept + residual `norm(relu(p−q))` resample. Growing
  multi-layer H_ctx buffer; rollback via `trim(n, bypass=true)` (physically
  slices the rejected tips past the sliding window — see `gemma4-base.ts`).

## Results & findings (measured, M1 Max 32GB, e4b OptiQ-4bit)

**The architecture is CORRECT — proven by an overfit test.** Trained on 3
articles, eval on the same 3: per-position acceptance **~0.75**, τ **3.24** —
squarely paper-range (0.6–0.9 / τ 3–4). So the faithful DFlash, correctly
implemented, reaches the paper's numbers.

**Getting there required finding a real bug — an off-by-one in the p^t target
alignment** (the TV loss, weight 0.9). Block position k predicts `x_{t+1+k}`,
whose target distribution is `softmax(LM_head(h_{t+k}))`; the data gathered the
hidden at `t+k+1` (shifted forward one). Present in **both v1 and v2** — so every
τ number before the fix was trained against a shifted target. Fixed in
`data-dflash.ts` (`blockIdx = g+k`, k=0..γ-1). Before fix: per-pos ~0.08. After:
~0.17 generalizing, ~0.75 overfit.

**Two things stand between "correct architecture" and "net speedup," now
separated:**
1. **Data.** 160 articles → generalizes only to per-pos ~0.17 (plateaus, doesn't
   climb); overfit on 3 proves capacity. The paper uses 1.3M samples × 10 epochs.
   → needs real data scale.
2. **Target speed (the decisive one).** Spec decode amortizes the fixed draft
   overhead only when the *target forward* is expensive. Measured decode:
   **e4b 45.9 tok/s, 12b 27.5 tok/s, 27B ~15 tok/s.** On fast e4b the draft
   overhead dominates → even τ≈3 nets ~0.4–0.5× (SLOWER). On a slow target (27B,
   ~67 ms/forward) that overhead is a small fraction → the same τ≈3 could land
   ~2–3× (15 → ~35–45 tok/s). **e4b is close to the worst case for spec decode;
   the 27B agentic workload is the ideal target and the real motivation.**

Also confirmed: width is NOT the ceiling (`dDraft=1024` and `2560` both plateau
~0.17 pre-scale); the parity-safe `hiddenTap` doesn't change target numerics;
long-context spec rollback works via the `trim(n, bypass)` physical-slice.

## Files
- `src/model/gemma4.ts` — `hiddenTap`/`captureLayer` (parity-safe multi-layer tap).
- `src/model/gemma4-base.ts` — `trim(n, bypass)` on rotating caches (spec rollback past the window).
- `src/spec/dspark/module-dflash.ts` — faithful DFlash+Markov+confidence module.
- `src/spec/dspark/data-dflash.ts` — multi-layer shards, variable-length prefix context, left-pad masking.
- `src/spec/dspark/generate-dflash.ts` — growing-H_ctx lossless decode loop.
- `src/spec/dspark/{loss,sample}.ts` — loss (Eq 9–12) + temp>0 sampling (shared with v1).
- `src/spec/dspark/{module,data,generate}.ts` — v1 single-vector (superseded baseline).
- `scripts/dspark-regen-dflash.ts` / `dspark-train-dflash.ts` (`--resume`) / `dspark-measure-dflash.ts`.
- `scripts/dspark-dflash-smoke.ts` — CPU smoke (16/16). `scripts/dspark-smoke.ts` — v1 smoke (33/33).

## Run sequence (faithful DFlash; GPU = Josh runs)
```
bun scripts/dspark-regen-dflash.ts --topics <topics.txt> --out <data> --max-resp 320
bun scripts/dspark-train-dflash.ts --data <data> --out <ckpt> --iters 8000 --batch 8 [--resume] [--ddraft 2560]
bun scripts/dspark-measure-dflash.ts --drafter <ckpt> --data <prompts.jsonl>   # τ + tok/s vs vanilla
```

## Open items / next
- **Real data scale** (thousands of on-distribution generations, not 160) to lift generalizing τ toward the overfit ~0.75.
- **Retarget to a slow model (27B/12b)** where the τ≈3 architecture actually nets a speedup — the whole point. Needs the drafter sized to that model's H/layers + regen+train there; 27B on 32GB is memory-tight (17.75GB weights + KV budget).
- **Tighten the draft inference loop** (per-position host syncs, double 262K LM-head) so τ translates to wall-clock.
- **Remaining paper components:** RNN head (Eq 6), STS calibration (§3.2.1), hardware-aware prefix scheduler (Alg 1 — single-user form = confidence-scheduled draft-length pruning).
- **Rename** `dflash`→`dspark` (the faithful module IS DSpark; v1 is the legacy single-vector variant).

Full session handoff: `docs/investigations/dspark-handoff.md`.
