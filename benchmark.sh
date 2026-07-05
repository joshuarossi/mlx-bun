#!/bin/sh
# Head-to-head benchmark — the one-shot entry point. Runs the comparisons
# across BOTH arenas (direct + server) and writes ONE report sectioned by
# comparison:
#   0. L1 kernel matrix   (faithful default - each)   — the baseline holds
#   1. mlx-bun vs mlx-lm  (bf16 KV, no mixed quant)   — requirement: bit parity
#   2. mlx-bun vs optiq   (mixed kv_config)           — requirement: bit parity
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
# We pass --force so preflight WARNS rather than refuses: a multi-hour
# unattended run must not abort on a transient blip. With the caffeinate
# assertion above holding the machine awake, preflight should now PASS on
# its own — the blanket `‡ preflight-failed` tags on past runs were NOT a
# dirty machine (swap 0, free >90%, zero foreign processes) but the
# `loadAvg1m > 8` check tripping on the run-queue spike right after a
# wake-from-sleep. So --force here is a legitimate belt-and-suspenders, not
# an admission of measuring dirty. Rows are only tagged `‡` if a check
# genuinely trips; parity and KL/ratio verdicts don't depend on machine
# state either way.
set -e
cd "$(dirname "$0")"

# Keep the Mac awake for the whole pass. macOS idle-sleep keys off HID
# inactivity, NOT GPU/CPU load, so an unattended run gets slept mid-leg and
# the suspended process stretches a ~1-2 h pass across many hours (and the
# post-wake run-queue spike fakes `loadAvg1m > 8` preflight failures). This
# assertion lives only as long as this script (PID $$) and releases on exit.
# caffeinate ships with macOS (/usr/bin/caffeinate) — nothing to install.
caffeinate -dimsu -w $$ &

REPORT="benchmarks-h2h-$(date +%F)-$(hostname -s).md"

# Comparisons 1 & 2 (vs mlx-lm and vs optiq, direct + server arenas).
bun scripts/bench-h2h.ts all --force "$@"

# Comparison 0 — L1 kernel matrix. The faithful compiled-activation kernels are
# the DEFAULT; this measures what removing each faithful kernel costs, all vs
# mlx-lm, per model. Confirms the L1 default is at/above mlx-lm. Direct arena
# (spawns the mlx-lm python; no servers). cpm5 + e4b + 12B.
echo ""
echo "=== comparison 0: L1 kernel matrix (faithful default - each kernel vs mlx-lm) ==="
bun scripts/bench-faithful-matrix.ts --tokens 256 --models cpm5,e4b,12B

# Kill-switch A/Bs (bit-exact levers: confirm the fast default still wins).
# Paired/in-process; each records eval-DB rows the unified report reads.
echo ""
echo "=== fused-prefill A/B (12B @8k kv8: fused vs stock transient + tok/s) ==="
bun scripts/bench-fused-prefill.ts
MLX_BUN_NO_FUSED_SDPA=1 bun scripts/bench-fused-prefill.ts
echo ""
echo "=== compiled-decode paired A/B (12B @8k, e4b @600/@8k, serve kv_config) ==="
echo "    cleared-machine confirmation of the mx.compile lever (dirty-paired ref: e4b +5.2% @600)"
bun scripts/bench-compiled-decode.ts

# Re-render the unified, sectioned report so it INCLUDES the rows written
# after bench-h2h all's own render.
echo ""
echo "=== rendering unified report -> $REPORT ==="
bun scripts/bench-h2h.ts table --out "$REPORT"
echo ""
echo "benchmark pass complete — $REPORT + eval-DB rows written."
