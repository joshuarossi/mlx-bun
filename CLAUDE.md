# CLAUDE.md — working notes for agents on mlx-bun

Read PLAN.md first: phases, exit criteria, and the **Reference
environment** section (oracle venv, weights paths, measured baselines).
README.md has the pitch and scope boundaries.

**Doc map:**
- `STATUS.md` — live handoff: current state + next action (read this for "where are we").
- `PLAN.md` — durable phase log, exit criteria, findings (the engineering contract).
- `README.md` — product pitch, quickstart, API surface, scope boundaries.
- `benchmarks/RESULTS.md` — curated results: parity / performance / quality.
- `docs/reference/` — server-api, server-config, library-api, embedding (user-facing reference).
- `docs/design/` — design docs (optimization plan, compat CLI surface, parallel slots, this reorg).
- `docs/investigations/` — investigation write-ups (pi built-in, starter port, lab build).
- `docs/planning/` — product/vision: PRODUCT_ROADMAP, IDEAS, ResearchTopics, journal.
- `AGENTS.md` → symlink to this file.

## Ground rules

- **Never start long-running servers or multi-GB downloads from a
  session.** Josh runs servers himself (`/Users/joshrossi/Code/mlx-lm/serve-gemma.sh`
  is the Python reference server). Testing against an already-running
  server with curl is fine. Ask before anything persistent.
- **Work the plan**: find the next unchecked box in PLAN.md, do it, update
  the marker, record decisions in PLAN.md (e.g. the Phase 0 pivot
  decision). PLAN.md is the durable state between sessions — write
  conclusions down; don't rely on conversation memory.
- **Logit parity with mlx-lm is the correctness oracle.** The Python
  reference lives in `/Users/joshrossi/Code/mlx-lm/.venv` (mlx 0.31.2,
  mlx-lm 0.31.3, mlx-optiq 0.2.1). Run reference scripts with that venv's
  python: `/Users/joshrossi/Code/mlx-lm/.venv/bin/python`.
- **Every perf claim gets a number on this machine** (M4 Pro, 24 GB,
  ~273 GB/s). Reference numbers live in benchmarks-h2h-<date>.md
  (cleared-machine matrix; 12B direct 25.3 vs mlx-lm 25.9 tok/s).
  Beware: numbers measured on a loaded machine are garbage — use
  ./benchmark.sh (preflight-gated) for anything quotable.
- Readable reference source (installed in the oracle venv,
  `site-packages/`): `mlx_lm/models/gemma3.py` and `mlx_lm/server.py`
  for the port targets; `optiq/runtime/fused_quant_sdpa.py` and
  `optiq/vlm/` for quantized-KV attention and the vision sidecar.

## Hard-won environment facts

- Bun pinned at ≥ 1.3.14 (upgraded 2026-06-10): `Bun.Image` (native OS
  image codecs incl. HEIC/AVIF) is the decode path for vision inputs —
  see `src/vision/preprocess.ts`. Full test suite re-verified post-upgrade.
- `Bun.mmap` panics (SIGTRAP) on files > 4 GB (still true in 1.3.14) —
  use libc mmap via bun:ffi (`src/mmap.ts`).
- Metal/mlx cannot no-copy-wrap host pointers that aren't page-aligned:
  GPU ops silently read garbage (CPU-stream ops are fine). Weights load
  via `mlx_load_safetensors` on the **CPU stream** (Load has no GPU
  kernel). See PLAN.md Phase 1 findings.
- When binding mlx-c functions, read the full signature from the header
  first — a missed trailing optional param shifts the stream arg and
  produces "There is no Stream(...)" errors at eval time.
- HF downloads: Xet stalls on this network — `HF_HUB_DISABLE_XET=1`.
  Auth is set up (`hf auth login` done).
- optiq tooling wants local snapshot *paths*, not HF repo ids (its
  runtime treats `--model` as a filesystem path in places).
- The OptiQ vision sidecar (`optiq_vision.safetensors`, bf16, ~105 MB)
  auto-enables in optiq serve when present; needs pillow in Python land.
- mlx-lm's prompt cache is count-capped (10 entries), not byte-capped —
  multi-GB KV entries make it an OOM footgun. Ours must be byte-capped.
- pi integration: `~/.pi/agent/models.json`, provider pattern documented
  there; optiq servers require apiKey starting with `sk-optiq-`.
