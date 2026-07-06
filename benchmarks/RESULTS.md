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

## Methodology change (2026-07-05)

The primary benchmark is now **`./benchmark.sh` → `scripts/bench-serve.ts`**:
real servers on real paths — the mlx-bun arms spawn the ACTUAL CLI at its
actual defaults (the old harness used a bench-local wrapper, since deleted),
and every metric arrives over HTTP as a user would see it. One server per
cell yields: decode tok/s, cold TTFT (~1k, nonce-busted), warm/cached TTFT
(each stack's own prompt cache), prefill tok/s, long-context
prefill/TTFT/decode (ONE measured prefill; decode sampled on 64 tokens),
aggregate tok/s at 4 concurrent streams, and load→ready time. Context
lengths are recorded from usage.prompt_tokens (measured, not requested).
Engine-level questions (in-process kernel parity, gen-peak memory,
kill-switch A/Bs) live behind `./benchmark.sh --engine`. Numbers below this
note predate the redesign; the next quiet-machine pass supersedes them.

## 2. Performance — like-for-like numbers

Two comparison axes: **vs the oracles**, and **our optimized path vs our
own bit-exact compat path** (does an optimization beat the baseline it
diverges from). Within mlx-bun, `bf16` is the L1-compatible path and
`mixed` is the L2-compatible path; both are bit-exact, so the bf16↔mixed
delta is the first "our-vs-our" axis. Lab experiment rows (no external
oracle; KL/eval-gated) land here once one beats the L1 baseline in a
paired A/B — none recorded yet (the 2026-07-05 candidates were deleted).

### Served (warm) — the path agents actually use

decode tok/s · TTFT ms · server-ready s · steady RSS GB

| model | mlx-bun (mixed) | mlx-bun (bf16) | mlx-lm (bf16) | optiq (mixed)† |
|---|---|---|---|---|
| MiniCPM5-1B | **252.9** · 34 · 0.17 · 1.22 | — | — | 223.6 · 64 · 0.84 · 1.82 |
| gemma-4-e4b | 55.7 · 44 · 0.36 · 7.14 | **57.3** · 48 · 0.36 | 53.5 · 218 · 0.98 · 7.55 | 53.4 · 221 · 0.78 · 7.53 |
| gemma-4-12B | **25.9** · 85 · 0.38 · 9.46 | — | — | 25.5 · 326 · 1.24 · 9.86 |
| gemma-4-26B | 54.2 · **45** · 0.47 · 18.25 | **55.0** · 44 · 0.47 | 52.3 · 228 · 0.77 · 4.87 | — |

† **The served `optiq (mixed)` cells are effectively bf16** — optiq's
KV-quant patch is inert on mlx-lm 0.31.3's batched server path:
`install_mixed_kv` hooks `mlx_lm.generate.maybe_quantize_kv_cache` and
`mlx_lm.server.stream_generate`, but the server routes every *seedless*
text chat request through `BatchGenerator`, which calls neither hook, and
the h2h harness's server requests carry no `seed`. See
`lab/repro/optiq-mixed-kv-inert/` for the mechanism + repro. The data
fingerprint agrees: e4b optiq-mixed served 53.4 tok/s · 7.53 GB RSS ≡
mlx-lm bf16's 53.5 · 7.55. Same caveat applies to any serve-mode
optiq-mixed cell in raw `benchmarks-serve-*` artifacts dated ≤ 2026-07-06.
The **Direct** and **Long context** optiq (mixed) rows below DID measure
real quantized-KV execution (the legs passed `kv_bits=8` straight into
`mlx_lm.generate.stream_generate` — old `bench.ts --baseline-kv config` —
so the 64k collapse and the lower peaks are genuine quantized-KV
behavior), but a second installer defect means the scheme was **uniform
8-bit, not the per-layer map**: `install_mixed_kv`'s hook patch lands on
the `generate` *function* that shadows `mlx_lm.generate` in mlx-lm's
package namespace, never on the module, so mlx-lm's stock uniform
`maybe_quantize_kv_cache` is what ran (empirically proven in the repro
dir). Read "optiq (mixed)" in those two tables as "optiq (uniform kv8)".
mlx-bun (mixed) columns are unaffected — our engine implements the
per-layer scheme natively — and the L2 parity goldens stay valid: every
`regen-*` oracle script applies the scheme explicitly (direct per-layer
`to_quantized`, or calling optiq's patched hook by name), never through
the dead serve-path indirection.

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

_No Lab quality runs recorded yet._ This section is the home for a Lab
experiment's quality measurements when it's promoted (the bar:
paired-A/B win vs L1 on a stable pass + KL PASS — see
docs/design/unified-engine-frontier-plan.md §6-7).
