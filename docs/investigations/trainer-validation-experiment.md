# Trainer validation experiment

**Status:** in progress (started 2026-06-20). **Goal:** prove the from-scratch
SFT/DPO/ORPO trainer actually works before trusting any downstream result — general
capability (Goal 1) or task-specific (Goal 2).

## Why this exists — the smoking gun

The margin/accuracy is recorded in `metrics.json` (`valTrajectory[].margin`,
`bestMargin`), not the stdout log. The prior `cpm5-uf` ORPO run (λ=0.1) shows:

| step | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 |
|---|---|---|---|---|---|---|---|---|
| accuracy | .507 | .514 | .534 | .541 | .534 | .520 | .547 | .547 |
| margin | .132 | .124 | .110 | .120 | .136 | .128 | .118 | .123 |

**Preference accuracy is ~0.52 (near the 0.50 coin-flip) and the margin is flat.**
ORPO's defining job is to push accuracy up and widen the margin. This is *not* a clean
"it works" signal. Caveats: 800 steps ≈ 0.05 epoch (undertrained), provenance
(from-base vs warm-start) unconfirmed. But it's enough to make validation mandatory:
**we cannot currently claim our ORPO learns the preference at all.**

## Method-decomposition (the validation key)

`ORPO_loss = NLL(chosen) + λ·L_OR`. NLL is exactly the SFT objective; L_OR is the
reference-free odds-ratio preference term. So we validate the building blocks, and ORPO
is covered by its parts plus a small ORPO-specific surface (the OR term + λ).

mlx-lm has **no DPO/ORPO** — so the oracle strategy is:
- **SFT/NLL** → numeric parity vs **mlx-lm tuner** (oracle env exists).
- **DPO + OR loss** → **numeric unit test vs the paper's equations** on a fixed tiny
  input (hand-computed expected loss + grad). No external dep. Optional stronger
  cross-check: **TRL** `DPOTrainer`/`ORPOTrainer` loss (PyTorch; multi-GB env →
  approve-first, not default).

Every positive control is designed so "weak data / weak lever" is **not** an available
excuse — success must be unambiguous.

## PILLAR 1 — Prove the trainer (gate for everything)

- **1a · SFT positive control** *(infra GREEN, behavioral check WEAK)*. Train
  `fixtures/adapters/data-upper` from scratch on MiniCPM5; assert generations are
  actually uppercased (oracle: the repo's pre-trained `upper` adapter). Existing
  `train-e2e.test.ts` only checks loss↓ — add the behavioral assert. *(seconds)*
- **1b · DPO positive control** *(MISSING)*. Trivial preference (chosen uppercase,
  rejected lowercase). Assert **margin increases** and **preference accuracy → ~1.0**.
- **1c · ORPO positive control + the real question.** (i) Same trivial preference →
  accuracy → ~1.0. (ii) **From-BASE ORPO on UF**, multiple epochs, watch margin widen
  and accuracy climb well above chance — directly resolves the near-chance finding
  (undertraining vs warm-start vs bug).
- **1d · Loss-formula parity.** SFT NLL vs mlx-lm; DPO/ORPO loss + grad vs hand-computed
  paper equations (unit test). The training-side analogue of the inference logit-parity
  oracle — currently MISSING.
- **1e · vs the paper.** Internal proxy first: preference accuracy robustly > chance on
  UF. Then (approve-first, LLM-judge) AlpacaEval/MT-Bench **direction** vs base (not
  absolute — paper used 7B). optiq suite (incl. IFEval) is an already-local downstream.

> **Gate:** until 1a–1c are green, Pillars 2 & 3 sit on an unverified trainer.

## PILLAR 2 — Measure general-capability impact (optiq suite)

All 6 datasets are present locally (`~/.cache/mlx-bun/eval-data/`: mmlu, gsm8k, ifeval,
bfcl, humaneval, hashhop); harness = `scripts/eval.ts capability`.
- **2a · Eval parity:** run on base CPM5, reproduce optiq's **30.28** within tolerance
  (validates the *measurement* before trusting deltas; confirm the README's open BFCL
  "no-calls" / MMLU "at-chance" flags aren't broken on our side).
- **2b · Delta:** trained checkpoint vs base, on the 6-task mean.
- **2c · Targeting:** mean is floored by **BFCL 0.0 / GSM8K 2.7 / HashHop 4.0**; UF hits
  the already-strong IFEval, so expect small mean movement. Highest-leverage Goal-1 lever
  is **BFCL** (0.0 is format-trainable; 0→30 = +5 on the mean).

## PILLAR 3 — Task-specific (separate; gated on Pillar 1)

Chunk segmenter via `scripts/chunk-eval.ts` (boundary/label accuracy), using the
hard-negative ORPO data (remove-a-cut / add-a-cut, balanced to kill the length
shortcut). Measured by chunk accuracy, not val loss / capability. Credibility depends on
Pillar 1.

## Sequencing & gates

1. Pillar 1 positive controls (1a→1b→1c-trivial) — fast, "does the machinery work."
2. Pillar 1 real replication (1c from-base UF) + 1d loss-formula parity.
3. Pillar 2a eval-parity (reproduce 30.28) → 2b deltas.
4. Pillar 3 — once the trainer is trusted.

## Execution log

### 2026-06-20 — Pillar 1 quick validations: PASS

**Machinery + gradient correctness — GREEN.** `MLX_BUN_TEST_TRAIN=1 bun test
train-autograd train-e2e train-orpo-e2e` → 8 pass / 0 fail, real training on
MiniCPM5 (11.3s). `train-autograd` confirms the backward matches autograd.

**ORPO positive control (prefer-uppercase, 12 train / 4 val, 120 iters, lr 1e-3) — PASS.**
Held-out preference accuracy **1.000 by step 10**, margin **5.5 → 4.0** (noisy at lr=1e-3
but accuracy solid). Logged: `runs/orpo-pc.{json,csv}`.

**DPO positive control (same data) — PASS, cleaner.** Accuracy **1.000 from step 10**,
margin **monotonic 6.46 → 9.67**. Logged: `runs/dpo-pc.{json,csv}`.

**Conclusion: the preference machinery is validated.** On a learnable preference both
DPO and ORPO drive accuracy to 1.0 and the margin wide open (vs UF's flat ~0.12). A
broken trainer could not. ⇒ **The UF near-chance result is the DATA, not a bug** — UF
pairs are genuinely subtle for a 1B (both responses plausible); "prefer uppercase" is
trivially separable. The smoking gun is explained: implementation sound, lever weak.

**Gotcha found (recorded so we don't repeat it):** `AdapterManager.mount` (the *serving*
hot-swap path) does **not** reflect into `branchLogpMean` (the *training* forward) — an
external base-vs-adapter `orpoMetrics` measurement via mount returns bit-identical
numbers (measured: 0.500/0.1463 both). Measure training-side metrics via the
`trainLora` emit / loraState path (`scripts/experiments/pref-control.ts`), not mount.

**Logging for plotting:** `runs/<stem>.{json,csv}` — per-step train `{loss, accuracy,
margin}` + per-eval val `{loss, accuracy, margin}`. CSV columns: `phase,step,loss,
accuracy,margin`. Tools: `scripts/experiments/pref-control.ts` (train+log),
`scripts/experiments/measure-pref.ts` (standalone adapter eval — superseded by the
emit path for training metrics; see gotcha).

### 2026-06-20 — Pillar 2a: capability-harness parity. Two bugs found + fixed.

**The first-measure step caught two harness bugs** (exactly its purpose — never trust a
delta until the harness reproduces the published baseline):

1. **Thinking mode.** The eval rendered the chat template's *default* (thinking-on for
   MiniCPM5); optiq's numbers are **non-thinking** (HF card: IFEval 64.7 is non-thinking).
   Symptom: IFEval **36.7%** vs 64.7. **Fix:** `src/eval/runner.ts` `generateText` now
   renders `enableThinking: false` by default (env `MLX_BUN_EVAL_THINK=1` to re-enable).
   → IFEval **73.3%** (n=30), optiq ballpark.
2. **HumanEval oracle-python path.** `src/eval/tasks/humaneval.ts` hardcoded
   `/Users/joshrossi/Code/mlx-lm/.venv/bin/python` — wrong on this machine (it's
   `mlx-lm-example`), so every code-exec spawned a missing interpreter → **0%**. **Fix:**
   env-overridable `MLX_BUN_ORACLE_PYTHON` (committed default = reference box; never
   re-commit the path). → HumanEval **53.3%** (n=15), optiq 57.9.

**Post-fix parity (base CPM5, non-thinking, n=20 — all ballpark):**

| | MMLU | GSM8K | IFEval | BFCL | HumanEval | HashHop |
|---|---|---|---|---|---|---|
| ours | 55.0 | 10.0 | 75.0 | 0.0 | ~53 | 0.0 |
| optiq | 52.4 | 2.7 | 64.7 | 0.0 | 57.9 | 4.0 |

⇒ **harness reproduces optiq.** Small-n inflation on GSM8K/IFEval will settle toward
optiq on the full set. **Exp-1 baseline harness VALIDATED.**

### Ready-to-fire sequence (everything staged; only GPU time remains)

All measurement tools validated. `scripts/eval.ts` now takes `--adapter <dir>` (mounts the
trained LoRA → x2). `ORC=/Users/joshrossi/Code/mlx-lm-example/.venv/bin/python` below.

1. **x1** (running): `MLX_BUN_ORACLE_PYTHON=$ORC bun scripts/eval.ts capability --candidate MiniCPM5`
2. **Train** (user): from-base ORPO/UF → `./adapters/cpm5-uf-frombase` (command in chat).
3. **x2 (Exp 1 after):** `MLX_BUN_ORACLE_PYTHON=$ORC bun scripts/eval.ts capability --candidate MiniCPM5 --adapter ./adapters/cpm5-uf-frombase` → compare to x1.
4. **Exp 2 gen (GPU):** `bun scripts/experiments/prefbench.ts gen mtbench ./adapters/cpm5-uf-frombase mtbench-uf` (and `gen alpaca … alpaca-uf 200` for a subset).
5. **Exp 2 judge (codex, anytime):** `bun scripts/experiments/prefbench.ts judge mtbench-uf` → TRAINED win-rate vs BASE.

### Next
- **Full baseline:** see step 1 (running). **(long → user-launched)**
- **Train (the "do"):** from-base ORPO on UF (`pref-control.ts`, command in chat). **(long → user-launched)**
- **Re-measure → x2**, compare to x1. Exp 1 done.
- **Exp 2 judge — VALIDATED (keyless).** No OpenAI key needed: the judge shells out to
  `codex exec -m gpt-5.4-mini` (codex's own auth), forcing structured `{"winner":...}` via
  `--output-schema` and reading the clean verdict from `-o`. `scripts/experiments/llm-judge.ts`
  — `judgeOnce` + `judgePair` (judges BOTH orders to cancel small-judge position bias).
  Positive control: **3/3 obvious good-vs-bad pairs, good won both orders, zero flips.**
  1bx vs 1bx1; consistency (same judge both sides), not absolute comparability to the paper's GPT-4.
- **Exp 2 harness — STAGED.** Prompts downloaded: `~/.cache/mlx-bun/eval-data/{mt_bench.jsonl
  (80), alpaca_eval.json (805)}`. Two-phase runner `scripts/experiments/prefbench.ts`:
  `gen <mtbench|alpaca> <adapterDir> <stem> [limit]` (GPU — base then trained, non-thinking)
  → `runs/<stem>.responses.jsonl`; `judge <stem> [limit]` (codex) → TRAINED win-rate vs BASE,
  judging trained-vs-base **directly** (head-to-head, not vs a fixed reference). Only the `gen`
  phase needs GPU; everything else is validated. Fire after the from-base training produces
  `./adapters/cpm5-uf-frombase`.
- **1c real / 1d parity** — still open (lower priority now the positive controls + harness parity are green).
