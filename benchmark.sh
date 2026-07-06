#!/bin/sh
# The one-shot benchmark entry point — REDESIGNED 2026-07-05 ("run the
# correct things in the correct ways, record what we care about").
#
# DEFAULT PASS (~15-30 min): scripts/bench-serve.ts — real servers, real
# paths, real defaults. The mlx-bun arms spawn the ACTUAL CLI; mlx-lm and
# optiq run their real servers; every metric arrives over HTTP as a user
# would see it. One server per cell serves ALL its metrics:
#   decode tok/s (spread/stability policy) · TTFT cold (~1k, nonce-busted)
#   · TTFT warm/cached (the prompt-cache story) · prefill tok/s ·
#   long-context prefill/TTFT/decode (ONE prefill, decode sampled on 64
#   tokens — never "generate 16k to measure 16k") · aggregate tok/s at 4
#   concurrent streams (the sub-agents number) · load→ready time.
#
#   ./benchmark.sh                     cpm5 + e4b + 12B, all arms
#   ./benchmark.sh --models cpm5,12B   subset
#   ./benchmark.sh --with-serial       add the --batch 1 pinned arm
#   ./benchmark.sh --skip-context      drop the long-context leg (fastest)
#   ./benchmark.sh --context 8192      shorter context leg
#
# ENGINE PASS (opt-in, slow — kernel-level questions): in-process direct
# legs (gen-peak memory, kernel parity vs the python oracles) + the
# faithful-kernel matrix + kill-switch A/Bs:
#   ./benchmark.sh --engine
#
# Quotable ABSOLUTE numbers need a quiet machine (reboot, nothing open).
# Ratios/parity survive a dirty machine; rows carry machine-state labels
# either way. Results: eval DB (~/.cache/mlx-bun/evals.sqlite) + a dated
# markdown report in the working dir (gitignored).
set -e
cd "$(dirname "$0")"

# Keep the Mac awake for the whole pass (idle-sleep keys off HID, not GPU).
caffeinate -dimsu -w $$ &

if [ "$1" = "--engine" ]; then
  shift
  REPORT="benchmarks-engine-$(date +%F)-$(hostname -s).md"
  echo "=== engine pass: direct legs (in-process, gen-peak, oracle parity) ==="
  bun scripts/bench-h2h.ts direct --force "$@"
  echo ""
  echo "=== L1 kernel matrix (faithful default - each kernel vs mlx-lm) ==="
  bun scripts/bench-faithful-matrix.ts --tokens 256 --models cpm5,e4b,12B
  echo ""
  echo "=== fused-prefill A/B ==="
  bun scripts/bench-fused-prefill.ts
  MLX_BUN_NO_FUSED_SDPA=1 bun scripts/bench-fused-prefill.ts
  echo ""
  echo "=== compiled-decode paired A/B ==="
  bun scripts/bench-compiled-decode.ts
  echo ""
  echo "=== rendering engine report -> $REPORT ==="
  bun scripts/bench-h2h.ts table --out "$REPORT"
  echo "engine pass complete — $REPORT + eval-DB rows written."
  exit 0
fi

# Default: the product-level serve pass.
bun scripts/bench-serve.ts all "$@"
echo ""
echo "serve pass complete. Engine-level questions: ./benchmark.sh --engine"
