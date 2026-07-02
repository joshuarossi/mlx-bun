---
title: Benchmarks
description: Head-to-head numbers against the Python MLX stacks, with the honest negatives.
---

Head-to-head against the Python stacks (mlx-lm 0.31.3, mlx-optiq 0.2.1 — the
versions installed at measurement time; the reference venv has since moved to
mlx-optiq 0.2.4), same machine (M4 Pro, 24 GB), same day, same Hugging Face
snapshots, preflight-gated clean machine, median-of-N with warmups discarded.

The curated table (parity / performance / quality) with per-row provenance lives
in [benchmarks/RESULTS.md](https://github.com/joshuarossi/mlx-bun/blob/main/benchmarks/RESULTS.md).

## Headline numbers

| | mlx-bun | mlx-lm | optiq |
|---|---|---|---|
| **TTFT, served (warm)** | **45–90 ms** | 219–224 ms | 222–331 ms |
| **server start → ready** | **0.36–0.47 s** | 0.76–0.98 s | 0.79–1.00 s |
| **decode through HTTP** (e4b / 12B / 26B) | **54.5** / 25.2 / **54.9** | 53.5 / — / 52.2 | 53.5 / **25.5** / † |
| **server tax vs own direct decode** | **≈ 0%** | −5…−7% | ≈ 0% |
| **direct decode** (engine only) | −1.9…−4.4% vs mlx-lm | baseline | −0.8…−1.2% |
| **12B decode @8k context** | 23.3 (23.0 kv-mixed) | **24.4** | 23.2 kv-mixed |

## The honest negatives

In this matrix, our **direct** decode trailed mlx-lm on every model (12B −1.9%,
26B −2.9%, e4b −4.4% at short context; the 12B gap grew to −4.5% @8k), and
optiq's served 12B edges ours by ~1% (25.5 vs 25.2) — while paying 3.7× the
TTFT.

**Post-matrix (2026-06-11), the decode gap was root-caused and fixed:** a
prefill→decode allocator-reclaim stall that mlx-lm clears with `mx.clear_cache`
and bills to prompt time (we billed it to decode). After the reference-faithful
fix, same-session paired runs put the 12B *ahead* at short context (25.1 vs
24.0) and at parity @8k (23.8 vs 23.9). A clean-machine re-measure is still
pending as of 2026-07 (it will also pick up the newer mlx-optiq 0.2.4) — until
it lands, the numbers on this page stand as measured; e4b retains a ~5%
per-step host-overhead residual.

Served through HTTP — how agents actually use a local model — mlx-bun has the
fastest decode on e4b and the 26B, and the fastest TTFT and startup everywhere
by 2–5×.

> † optiq serve produced no output on the 26B (the Metal OOM crash class from
> Python's non-lazy load transient — reproduced in isolation; mlx-bun and mlx-lm
> both served the same model from the same machine state). One further optiq cell
> is blocked on an upstream optiq bug; both are documented in the results file.

These numbers are the 2026-06-11 cleared-machine re-run with the long-context
guard active (every @8k row verified at its requested context).
