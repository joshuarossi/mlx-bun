#!/bin/sh
# THE benchmark — one pass, real servers, real paths, every number that
# matters (redesigned 2026-07-05; the separate "engine pass" is gone — its
# questions are answered from the same cells):
#
#   Per model × arm (mlx-bun@defaults · mlx-bun --batch 1 [the control
#   arm — --no-serial skips] · mlx-lm · mlx-bun-mixed · optiq-mixed):
#     decode tok/s (spread/stability policy) · TTFT cold (~1k, nonce-
#     busted) · TTFT warm/cached (each stack's own prompt cache) · prefill
#     tok/s · long-context prefill/TTFT/decode (ONE measured prefill;
#     decode sampled on 64 tok + 2 cached repeats) · aggregate tok/s at 4
#     concurrent streams · peak RSS (sampled; labeled — undercounts GPU) ·
#     load→ready time
#   Cross-arm, from the SAME cells:
#     BIT PARITY — a fixed greedy 64-token probe must be byte-identical
#     between stacks of the same scheme (mlx-bun vs mlx-lm; mixed vs
#     optiq; unified engine vs --batch 1), with prompt_tokens equality
#     doubling as a chat-template-parity check. Verdicts render in the
#     report; failures are diagnosed with the divergence offset.
#
#   ./benchmark.sh                     cpm5 + e4b + 12B + Qwen3.8-27B, all arms
#   ./benchmark.sh --no-serial        skip the --batch 1 control arm
#   ./benchmark.sh --models cpm5,qwen27b  subset
#   ./benchmark.sh --skip-context     drop the long-context leg
#   ./benchmark.sh --context 8192     shorter context leg
#
# Quotable ABSOLUTE numbers need a quiet machine (reboot, nothing open);
# parity verdicts and ratios survive a dirty one. Results: eval DB
# (~/.cache/mlx-bun/evals.sqlite) + a dated markdown report (gitignored).
#
# Developer lever A/Bs (faithful-kernel matrix, fused-prefill,
# compiled-decode) are NOT benchmarks — run their scripts directly when
# touching those code paths: scripts/bench-faithful-matrix.ts,
# scripts/bench-fused-prefill.ts, scripts/bench-compiled-decode.ts,
# scripts/bench-h2h.ts direct (in-process gen-peak/oracle legs).
set -e
cd "$(dirname "$0")"

# Refuse headline numbers from a loaded or swapped machine. This keeps the
# documented preflight gate on the canonical entry point.
bun scripts/bench-h2h.ts preflight

# Keep the Mac awake for the whole pass (idle-sleep keys off HID, not GPU).
caffeinate -dimsu -w $$ &

bun scripts/bench-serve.ts all "$@"
