# ORPO-on-UF — results + testing-phase handoff

**Status:** training done (2026-06-20); **testing phase = next.** This doc is the
"where we are + what to run" so anyone (or a fresh session) can execute the measurements.
Companion: [trainer-validation-experiment.md](trainer-validation-experiment.md) (the
validation that got us here).

## The run that just finished

From-**base** ORPO on UltraFeedback, MiniCPM5-1B.
- **Base:** `mlx-community/MiniCPM5-1B-OptiQ-4bit` (the full post-trained model; optiq quant).
- **Data:** `~/.cache/mlx-bun/eval-data/uf-cpm5` — 14,691 train / 148 val, `{prompt,chosen,rejected}`.
- **Config:** ORPO, **1 epoch (14,691 iters)**, B=1, seq 2048, rank 16, **λ=0.1**, cosine LR
  1e-5, **no-segment**. From base (no warm-start).
- **Command:** `SEQ=2048 EVAL_EVERY=500 RANK=16 SCHED=cosine LAMBDA=0.1
  ADAPTER_DIR=./adapters/cpm5-uf-frombase bun scripts/experiments/pref-control.ts orpo
  ~/.cache/mlx-bun/eval-data/uf-cpm5 uf-frombase 14691 1e-5`

## Key result — the two ORPO halves decoupled

| half | metric | best | at step | final (14690) |
|---|---|---|---|---|
| **SFT** | loss (NLL+λOR) ↓ | **1.5057** | **14500** (the end) | 1.506 |
| **DPO** | margin ↑ | **0.143** | **6000** | 0.127 |
| — | accuracy | **81/148** | ~5500 | 80/148 |

- **SFT improved across the *whole* run** (loss bottomed at the end) → **final adapter = best SFT.**
- **DPO peaked at ~6000 and faded** → **step ~6000 = best DPO**, slightly worse SFT (loss 1.5077).
- **No single checkpoint has both.** Honest summary: a **small, early-peaking preference
  signal** (~+6 questions, chance 74 → peak 81/148) that **drifted down in the tail**, while
  SFT kept inching to its ~1.506 floor. Whether even that small lift **converts** on an
  independent test is the open question the testing phase answers.

## Artifacts + baselines

- **Final adapter:** `./adapters/cpm5-uf-frombase/` (mountable: `eval.ts --adapter`).
- **Trajectory:** `runs/uf-frombase.{json,csv}`; **plot:** `runs/uf-frombase.png` via
  `scripts/experiments/plot-runs.py` (panels: loss=val+train-EMA; questions-correct/148;
  margin — each zoomed to its band).
- **x1 baseline** (base CPM5, full capability suite): **28.69** (in the eval DB; needs the
  MMLU-argmax + HumanEval-python fixes — see Gotchas). optiq published is 30.28.
- **⚠ No intermediate checkpoints this run** — `pref-control.ts` lacked `saveCheckpoints`
  (now **fixed**; future runs checkpoint every val eval + track best-margin). The ~6k peak
  is recoverable by **deterministic replay** (same seed/order → same adapter).

## Testing plan

**PRIMARY — the headline (READY TO RUN):**
- **A. final adapter vs base** on x2 (capability) + Exp 2 (judge win-rate). Answers "did a
  full epoch of ORPO-on-UF move a 1B, on an *independent* test?"

**SWEEP / SYNTHESIS:**
- **B. recover the ~6k peak** — re-run from base to ~7k (checkpoints now on), grab the
  step-6000 (and neighbors, pick best-val). The early-stop peak arm.
- **C. four-way** — base / 6k-peak / final / final+6k on x2 + Exp 2 → traces the
  early-stopping curve on an independent test.
- **D. DPO-boost (the day's synthesis) — keep best SFT, re-pressure the DPO.** Warm-start
  from the **final** adapter (best SFT, NLL at floor), re-apply the **DPO-helpful examples
  with HIGH λ** (or DPO-only). = dynamic-λ (ramp preference at SFT-saturation) + data-curation
  in one move. Tests the fork: DPO stalled because of a **capacity ceiling** (won't help) or
  **dilution / λ-too-gentle** (margin recovers past 0.143 while loss holds ~1.506 → better on
  *both* axes than any single checkpoint).
- **E. data-valuation control** — `final + (0–6000)` vs `final + (6000–14691)`, same size.
  First-half wins → those examples carry the DPO signal; tie → it's "more preference training,"
  not *which* examples. (We control which pairs go in, so this generalizes to **curating** the
  data with the model as the probe.)

## Commands

`ORC=/Users/joshrossi/Code/mlx-lm-example/.venv/bin/python` (HumanEval interpreter, this machine).

```bash
# A — x2 capability (final vs base; base x1=28.69 already recorded)
MLX_BUN_ORACLE_PYTHON=$ORC bun scripts/eval.ts capability --candidate MiniCPM5 --adapter ./adapters/cpm5-uf-frombase
# A — Exp 2 (gen base+trained responses, then judge head-to-head)
bun scripts/experiments/prefbench.ts gen mtbench ./adapters/cpm5-uf-frombase mtbench-uf   # GPU
bun scripts/experiments/prefbench.ts judge mtbench-uf                                      # codex
# B — replay base→7k to recover the ~6k checkpoint (now checkpoints)
SEQ=2048 EVAL_EVERY=500 RANK=16 SCHED=cosine LAMBDA=0.1 ADAPTER_DIR=./adapters/cpm5-uf-replay \
  bun scripts/experiments/pref-control.ts orpo ~/.cache/mlx-bun/eval-data/uf-cpm5 uf-replay 7000 1e-5
```

## Harness gaps to close for D / E

`pref-control.ts` does **not yet** support (needed for the DPO-boost + control arms):
1. **Warm-start from an adapter** (`--resume` / load a non-zero adapter before training) —
   the trainer has `warm_start_adapter` (see `trainer.ts`); just not wired into pref-control.
2. **Data-subset selection** (feed a chosen subset / order of pairs, e.g. rows 0–6000) —
   pref-control feeds the whole `train.jsonl`; needs a row-range / id-list option.
3. λ is already env-controllable (`LAMBDA=`), so high-λ is ready once 1+2 exist.

## Validated infrastructure (all green — see trainer-validation-experiment.md)

- **Trainer:** positive controls pass — DPO & ORPO drive prefer-uppercase val acc → 1.0;
  grads match autograd. `scripts/experiments/pref-control.ts`.
- **Capability harness:** reproduces optiq across 6 tasks after two fixes (below).
  `eval.ts capability --adapter` wired.
- **Judge:** `gpt-5.4-mini` via `codex exec`, **keyless**, structured, order-swapped,
  3/3 positive control. `scripts/experiments/llm-judge.ts`.
- **Exp 2 harness:** `scripts/experiments/prefbench.ts` (gen/judge); prompts downloaded
  (`mt_bench.jsonl` 80, `alpaca_eval.json` 805).
- **MMLU frozen set:** optiq's exact 969 questions + dev exemplars captured
  (`mmlu_optiq_frozen.jsonl` / `mmlu_optiq_dev.jsonl`) for parity work.

## Gotchas / load-bearing facts

- **`AdapterManager.mount` affects the *serving* forward** (eval generation, chat) **but NOT
  the *training* `branchLogpMean`.** Measure training metrics via the trainLora emit, not mount.
- **Eval env:** `MLX_BUN_ORACLE_PYTHON=$ORC` (HumanEval code-exec — wrong default path on this
  machine); evals default to **non-thinking** (optiq parity; `MLX_BUN_EVAL_THINK=1` to re-enable).
- **MMLU parity:** our number (47.7 old / ~50 argmax) vs optiq 52.4 is **sampling + forward
  parity**, not noise (both deterministic argmax). Use the frozen set; remaining gap = our
  forward vs `mlx_lm` (logit-diff test on the frozen prompts — **queued, GPU**).
- **Determinism:** same seed/order → same adapter. Replay recovers any checkpoint.
- **Server adapter API** (`POST /v1/adapters` + per-request `"adapter":"id"`) is the clean way
  to compare *many* adapters via chat; **raw eval (`--adapter`) is required for capability**
  (MMLU is logit-argmax, not chat generation).

## Recommended order

1. **A** (final vs base) — the headline, READY. Run x2, then Exp 2.
2. **B** — replay to recover the 6k peak (cheap, ~45 min).
3. **C** — eval base/6k/final on the suite (four-way needs D for the +6k arm).
4. Close the **pref-control harness gaps** (warm-start + subset), then **D** (DPO-boost) and
   **E** (data-valuation control) — the synthesis experiments.
5. (Parallel/queued) **MMLU forward-parity** logit-diff to nail x1 ≈ 30.28.
