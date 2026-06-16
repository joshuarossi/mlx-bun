# mlx-bun benchmark results (curated)

The durable, hand-maintained benchmark record. Raw per-run files
(`benchmarks-h2h-<date>-<machine>.md/.html`) are gitignored ephemera; the
structured backing record is the user-local eval DB
(`~/.cache/mlx-bun/evals.sqlite`). Promote a run into this file
deliberately when it becomes the new reference.

There are **three categorically different kinds of measurement** — kept in
separate sections because they answer different questions:

1. **Parity** — are we *bit-exact* with the upstream oracle? (pass/fail)
2. **Performance** — *numbers* under like-for-like config (tok/s, memory…).
3. **Quality** — for non-bit-exact optimizations, what does the speed cost
   in output quality? (6-test mean + KL)

**Machine:** Apple M4 Pro, 24 GB unified (`Joshs-MBP-2025`), ~273 GB/s.
**Oracle toolchain:** Bun 1.3.14; Python 3.13.5 with mlx 0.31.2,
mlx-lm 0.31.3, mlx-optiq 0.2.1. Numbers below are the 2026-06-14
cleared-machine run (commits `97457e4` / `d1e0296`), preflight-gated,
median-of-N with warmups discarded.

**Model legend** (registry hash → repo):

| hash | model |
|---|---|
| `664aabaed233` | `MiniCPM5-1B-OptiQ-4bit` (sub-GB starter) |
| `fcdb12d740cd` | `gemma-4-e4b-it-OptiQ-4bit` |
| `5b1101065d20` | `gemma-4-12B-it-OptiQ-4bit` |
| `dbfd2a779b03` | `gemma-4-26B-A4B-it-OptiQ-4bit` (MoE) |

> **Legend corrected 2026-06-15.** An earlier revision had the gemma
> hashes cycled (`5b…`→e4b, `dbfd…`→12B, `fcdb…`→26B). The mapping above is
> the authoritative one from `tests/paths.ts` (`SNAPSHOT`=`5b…`=12B,
> `SNAPSHOT_26B`=`dbfd…`=26B) and the e4b snapshot hash used across
> `tests/*.test.ts` (`fcdb…`=e4b), corroborated by on-disk weight size
> (e4b 7.0G · 12B 8.4G · 26B 18G). The **Performance** rows below were
> labeled by the old legend; each gemma row has been relabeled to its true
> model, re-identified by its gen-peak / steady-RSS fingerprint —
> e4b≈6.6 GB, 12B≈9.0 GB, 26B≈17.7 GB — which is stable across runs. The
> row *data* was correct; only the model labels moved.

---

## 1. Parity (porting correctness) — bit-exact vs the oracle

The correctness oracle. Each cell is **bit-for-bit** logit parity against
the upstream reference under matched config, proven by the test suite
(regenerated only by `scripts/regen-*.ts` against the oracle venv). This
is the gate the Performance/Quality numbers are only meaningful *under*.

| model | L1: mlx-lm, standard (bf16) KV | L2: mlx-optiq, mixed-precision KV | proof |
|---|---|---|---|
| MiniCPM5-1B | ✓ 100/100 logit vectors | ✓ 100/100 logit vectors | `tests/minicpm5-parity.test.ts`, `tests/minicpm5-kv-parity.test.ts` |
| gemma-4-e4b | ✓ | ✓ | `tests/parity.test.ts`, `tests/kv-quant.test.ts` |
| gemma-4-12B | ✓ | ✓ | `tests/parity.test.ts`, `tests/kv-quant.test.ts` |
| gemma-4-26B | ✓ | ✓ (mixed per-layer scheme) | `tests/parity-26b.test.ts`, `tests/rotating-kvq.test.ts` |

Fused quantized-attention prefill is separately bit-exact against
optiq's reference (`tests/fused-sdpa.test.ts`).

---

## 2. Performance — like-for-like numbers

Two comparison axes: **vs the oracles**, and **our optimized path vs our
own bit-exact compat path** (does an optimization beat the baseline it
diverges from). Within mlx-bun, `bf16` is the L1-compatible path and
`mixed` is the L2-compatible path; both are bit-exact, so the bf16↔mixed
delta is the first "our-vs-our" axis. L3 perf-kernel / fused-decode rows
(non-bit-exact, default-off) land here once measured under the
teacher-forced gate — none recorded yet.

### Served (warm) — the path agents actually use

decode tok/s · TTFT ms · server-ready s · steady RSS GB

| model | mlx-bun (mixed) | mlx-bun (bf16) | mlx-lm (bf16) | optiq (mixed) |
|---|---|---|---|---|
| MiniCPM5-1B | **252.9** · 34 · 0.17 · 1.22 | — | — | 223.6 · 64 · 0.84 · 1.82 |
| gemma-4-e4b | 55.7 · 44 · 0.36 · 7.14 | **57.3** · 48 · 0.36 | 53.5 · 218 · 0.98 · 7.55 | 53.4 · 221 · 0.78 · 7.53 |
| gemma-4-12B | **25.9** · 85 · 0.38 · 9.46 | — | — | 25.5 · 326 · 1.24 · 9.86 |
| gemma-4-26B | 54.2 · **45** · 0.47 · 18.25 | **55.0** · 44 · 0.47 | 52.3 · 228 · 0.77 · 4.87 | — |

Across every served model: mlx-bun has the fastest decode and the fastest
TTFT/startup (2–5×), at ~0% server tax vs its own direct engine.

### Direct (engine only)

decode tok/s · prefill tok/s · gen-peak GB

| model | mlx-bun (bf16) | mlx-bun (mixed) | mlx-lm (bf16) | optiq (mixed) |
|---|---|---|---|---|
| MiniCPM5-1B | 268.6 · 1817 · 1.01 | 241.9 · 1651 · 1.01 | **271.0** · 800 · 1.03 | 249.5 · 706 · 1.03 |
| gemma-4-e4b | **57.1** · 304 · 6.61 | 55.7 · 283 · 6.61 | 56.5 · 373 · 6.65 | 56.1 · 368 · 6.65 |
| gemma-4-12B | **26.0** · 168 · 8.99 | 25.8 · 166 · 8.99 | 25.9 · 141 · 9.10 | 25.7 · 137 · 9.00 |
| gemma-4-26B | 55.0 · 206 · 17.71 | 53.9 · 208 · 17.71 | **55.6** · 187 · 17.78 | 55.0 · 190 · 17.72 |

Direct decode is at parity-to-slightly-behind mlx-lm (the residual host
overhead per step); prefill leads on the larger models. See PLAN.md
"Decode gap RESOLVED" for the root-cause/fix history.

### Long context (gemma-4-12B) — where the gap opens

decode tok/s · gen-peak GB

| context | mlx-bun (bf16) | mlx-bun (mixed) | mlx-lm (bf16) | optiq (mixed) |
|---|---|---|---|---|
| 16k | 23.9 · 11.82 | 23.5 · 10.61 | 23.9 · 11.72 | 21.6 · 11.19 |
| 64k | **20.9** · 15.77 | 18.7 · 10.46 | 20.9 · 15.91 | 12.3 · 14.89 |

At 64k mlx-bun holds parity with mlx-lm on bf16 while optiq collapses to
12.3 tok/s; mlx-bun's mixed-KV trades ~2 tok/s for ~5 GB lower peak.

### Attempted but failed (2026-06-14)

- `gemma-4-12B/optiq/kv=config`: `quantized_matmul` weight/scales
  shape mismatch (upstream optiq bug; tracked). _(Relabeled from the
  old-legend name "e4b" = hash `5b…` = 12B; no gen-peak was recorded for
  this failed run, so the model id here is inferred from the legend, not
  fingerprinted.)_

---

## 3. Quality — for non-bit-exact (L3) optimizations only

When a custom path trades bit-exactness for speed, quantify the cost so a
perf win is only claimed with its quality delta — e.g. *"+23% tok/s while
holding ±5% on the 6-test mean."*

- **6-test mean** — mean score across `src/eval/tasks/`: bfcl, gsm8k,
  hashhop, humaneval, ifeval, mmlu — optimized path vs the compatible
  upstream.
- **KL divergence** — optimized vs compatible token distribution.

_No L3 quality runs recorded yet._ The perf kernels (`--perf-kernel`,
`MLX_BUN_FUSED_DECODE`) ship default-off; this section is the home for
their quality measurements when they're promoted. See
`docs/design/optimization_plan.md` and PLAN.md Phase 7.
