---
name: bench
description: Run THE quotable mlx-bun benchmark (real servers, parity probes) and distil the result into docs/reference/benchmarks.md. Use for "run the benchmark", "h2h vs mlx-lm", "quotable numbers".
---

# bench

1. Preconditions: quiet machine (reboot, nothing open), no training run
   active, oracle venv present (docs/reference/environment.md). Never start
   the benchmark from an agent session while Josh is using the machine — ask.
2. `bun scripts/bench-serve.ts all [--models cpm5,e4b,12B,qwen27b] [--no-serial] [--skip-context] [--context N]`
   — runs the clean-machine preflight itself, holds caffeinate, spawns the
   REAL CLI and the real mlx-lm/optiq servers, writes a dated
   `benchmarks-serve-<date>-<host>.md` in the working dir.
3. Move that dump to `reports/` (gitignored). Root dumps fail the hygiene gate.
4. Read the report: parity ✓ lines are the correctness verdict; the kv-quant
   RSS check is known to misfire on large models with --ssd-cache (accounting,
   not silent bf16) — confirm quantization via decode@ctx and restart-restore
   size instead.
5. Distil ONLY quiet-machine rows into docs/reference/benchmarks.md, labeled
   host/chip/RAM/commit/toolchain. Loaded-machine numbers are directional and
   stay in reports/.
6. Developer lever A/Bs are not benchmarks: `bun scripts/bench-levers.ts <faithful-matrix|fused-prefill|compiled-decode>`,
   `bun scripts/bench-matrix.ts <modes|features>`, `bun scripts/bench-prompt-response.ts` (P2R waterfall; render with `bun scripts/render-p2r-html.ts`).
