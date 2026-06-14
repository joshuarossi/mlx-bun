#!/bin/sh
# Head-to-head benchmark — the one-shot entry point. Runs all THREE
# comparisons across BOTH arenas (direct + server) and writes ONE report
# sectioned by comparison:
#   1. mlx-bun vs mlx-lm  (bf16 KV, no mixed quant)   — requirement: bit parity
#   2. mlx-bun vs optiq   (mixed kv_config)           — requirement: bit parity
#   3. mlx-bun perf vs mlx-bun compat (same engine)   — requirement: low KL + similar scores
#
#   1. Reboot. Open nothing else (no browser). [only needed for quotable
#      ABSOLUTE tok/s — parity (1,2) and KL/ratios (3) are valid dirty too]
#   2. ./benchmark.sh            (cpm/e4b/12B matrix; 26B skipped by default)
#      ./benchmark.sh --with-26b (include the 26B MoE — much slower)
#      ./benchmark.sh --redo     (ignore recent rows; force every cell
#                                 fresh — REQUIRED after engine changes,
#                                 or the resume window silently re-renders
#                                 stale rows as "results")
#
# Strictly sequential: each measured leg is its own fresh process. Results
# land in the eval DB (~/.cache/mlx-bun/evals.sqlite) AND
# benchmarks-h2h-<date>-<host>.md.
#
# The clean-machine preflight WARNS rather than refuses (we pass --force):
# rows measured on a dirty machine are tagged `preflight-failed` (‡ in the
# report) so the absolute tok/s carries its caveat, while the parity and
# KL/ratio verdicts — which don't depend on machine state — still stand.
set -e
cd "$(dirname "$0")"

REPORT="benchmarks-h2h-$(date +%F)-$(hostname -s).md"

# Comparisons 1 & 2 (vs mlx-lm and vs optiq, direct + server arenas).
bun scripts/bench-h2h.ts all --force "$@"

# Comparison 3 (our perf vs our compat: KL + similar scores). Paired and
# in-process, so meaningful right after the matrix; records eval-DB rows the
# unified report reads. e4b (default) + 12B.
echo ""
echo "=== comparison 3: perf vs compat (e4b, then 12B) — KL + tok/s ratios ==="
bun scripts/bench-compat-vs-perf.ts --model gemma-4-e4b-it-OptiQ-4bit
bun scripts/bench-compat-vs-perf.ts --model gemma-4-12B-it-OptiQ-4bit

# Fused-path A/Bs (decide the MLX_BUN_NO_FUSED_SDPA and MLX_BUN_FUSED_DECODE
# defaults). Paired/in-process; each records eval-DB rows.
echo ""
echo "=== fused-prefill A/B (12B @8k kv8: fused vs stock transient + tok/s) ==="
bun scripts/bench-fused-prefill.ts
MLX_BUN_NO_FUSED_SDPA=1 bun scripts/bench-fused-prefill.ts
echo ""
echo "=== fused-decode paired A/B (12B @8k kv8: tiled vs stock decode) ==="
bun scripts/bench-fused-decode.ts
echo ""
echo "=== perf-kernel paired A/B (12B serve kv_config: compat vs perf-mode Metal kernel) ==="
echo "    compat (MLX_BUN_PERF_KERNEL=0, bit-parity, the vs-python config) vs perf-mode (=1, default; ref 1.02-1.04)"
bun scripts/bench-perf-kernel.ts
echo ""
echo "=== compiled-decode paired A/B (12B @8k, e4b @600/@8k, serve kv_config) ==="
echo "    cleared-machine confirmation of the mx.compile lever (dirty-paired ref: e4b +5.2% @600)"
bun scripts/bench-compiled-decode.ts

# Re-render the unified, sectioned report so it INCLUDES comparison 3's rows
# (bench-h2h all wrote it before those rows existed).
echo ""
echo "=== rendering unified report (3 comparisons) -> $REPORT ==="
bun scripts/bench-h2h.ts table --out "$REPORT"
echo ""
echo "benchmark pass complete — $REPORT + eval-DB rows written."
