#!/bin/sh
# Phase 15 head-to-head benchmark — the one-shot entry point.
#
#   1. Reboot. Open nothing else (no browser).
#   2. ./benchmark.sh            (full matrix, ~45-60 min)
#      ./benchmark.sh --skip-26b (faster pass, ~20 min)
#      ./benchmark.sh --redo     (ignore recent rows; force every cell
#                                 fresh — REQUIRED after engine changes,
#                                 or the resume window silently re-renders
#                                 stale rows as "results")
#
# Strictly sequential: each measured leg is its own fresh process
# (ours / python direct, then each server started, measured, killed
# before the next starts). Results land in the eval DB
# (~/.cache/mlx-bun/evals.sqlite) AND benchmarks-h2h-<date>.md.
# Refuses to run unless the machine is clear (swap ~0, memory free,
# no thermal throttle) and re-checks between legs.
set -e
cd "$(dirname "$0")"
bun scripts/bench-h2h.ts all "$@"

# Fused-path A/Bs (NEXT UP 1: decide the MLX_BUN_NO_FUSED_SDPA and
# MLX_BUN_FUSED_DECODE defaults). Both are paired/in-process designs, so
# they stay meaningful right after the matrix; each records eval-DB rows.
echo ""
echo "=== fused-prefill A/B (12B @8k kv8: fused vs stock transient + tok/s) ==="
bun scripts/bench-fused-prefill.ts
MLX_BUN_NO_FUSED_SDPA=1 bun scripts/bench-fused-prefill.ts
echo ""
echo "=== fused-decode paired A/B (12B @8k kv8: tiled vs stock decode) ==="
bun scripts/bench-fused-decode.ts
echo ""
echo "=== perf-kernel paired A/B (12B serve kv_config: fused Metal kernel vs compat) ==="
echo "    decides the MLX_BUN_PERF_KERNEL default (Phase E v2; dirty-paired ref 1.02-1.04)"
bun scripts/bench-perf-kernel.ts
echo ""
echo "=== compiled-decode paired A/B (12B @8k, e4b @600/@8k, serve kv_config) ==="
echo "    cleared-machine confirmation of the mx.compile lever (dirty-paired ref: e4b +5.2% @600)"
bun scripts/bench-compiled-decode.ts
echo ""
echo "benchmark pass complete — matrix md + eval-DB rows written."
