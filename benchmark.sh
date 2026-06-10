#!/bin/sh
# Phase 15 head-to-head benchmark — the one-shot entry point.
#
#   1. Reboot. Open nothing else (no browser).
#   2. ./benchmark.sh            (full matrix, ~45-60 min)
#      ./benchmark.sh --skip-26b (faster pass, ~20 min)
#
# Strictly sequential: each measured leg is its own fresh process
# (ours / python direct, then each server started, measured, killed
# before the next starts). Results land in the eval DB
# (~/.cache/mlx-bun/evals.sqlite) AND benchmarks-h2h-<date>.md.
# Refuses to run unless the machine is clear (swap ~0, memory free,
# no thermal throttle) and re-checks between legs.
set -e
cd "$(dirname "$0")"
exec bun scripts/bench-h2h.ts all "$@"
