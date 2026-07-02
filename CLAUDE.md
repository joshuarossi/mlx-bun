# CLAUDE.md — working notes for agents on mlx-bun

Read PLAN.md first: phases, exit criteria, and the **Reference
environment** section (oracle venv, weights paths, measured baselines).
README.md has the pitch and scope boundaries.

**Doc map:**
- `STATUS.md` — live handoff: current state + next action (read this for "where are we").
- `PLAN.md` — durable phase log, exit criteria, findings (the engineering contract).
- `PLAN-archive.md` — closed-history phases moved out of PLAN.md to keep it scannable.
- `README.md` — product pitch, quickstart, API surface, scope boundaries.
- `benchmarks/RESULTS.md` — curated results: parity / performance / quality.
- `docs/reference/` — cli, server-api, server-config, library-api, embedding, distribution, training, orpo-quickstart, memory, models (user-facing reference).
- `docs/design/` — adapters-end-to-end, bucketing-stage, compat-cli-surface-design, diffusion-gemma-port, docs-reorg-plan, dspark-speculative-decoding, hlg-sampling, memory-inference-path, memory-synthesis, memory-system, minicpm5-decode-megakernel, optimization_plan, orpo-dynamic-lambda, orpo-future-enhancements, orpo-training, parallel-slots, parity-tier-dag, runtime-isolation, segmented-backward-training, spec-decode-larger-targets, tauri-desktop-app, the-dreaming-handoff, the-dreaming-master-plan, w4a16-compute-precision-spike, write-pipeline-entity.
- `docs/investigations/` — chunk-finetune-experiment, curve-bisector-routing, decode-roofline-lookagain, dspark-handoff, expert-offload-single-user-moe, hlg-sampling-investigation, kernel-perf-review-2026-07, lab-build-journal, orpo-base-uf-experiment-and-directions, orpo-flash-cce-pin-leak, orpo-uf-testing-handoff, pi-builtin-investigation, segmented-backward-handoff, starter-model-port-handoff, steel-flash-cce-handoff, trainer-validation-experiment.
- `docs/planning/` — product/vision: PRODUCT_ROADMAP, IDEAS, ResearchTopics, journal, chunk-task-roadmap, curve-sampler-research-plan.
- (Keep these lists in sync with `ls docs/{reference,design,investigations,planning}/*.md` when adding docs.)
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
  mlx-lm 0.31.3, mlx-optiq 0.2.4). Run reference scripts with that venv's
  python: `/Users/joshrossi/Code/mlx-lm/.venv/bin/python`.
- **Every perf claim gets a number on this machine** (M4 Pro, 24 GB,
  ~273 GB/s). Curated reference numbers live in `benchmarks/RESULTS.md`
  (parity / performance / quality). `./benchmark.sh` (preflight-gated)
  writes a dated `benchmarks-h2h-<date>.md` artifact in the working dir
  during a run — those files are gitignored. Numbers on a loaded machine
  are garbage; use benchmark.sh for anything quotable.
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
- `scripts/experiments/` holds one-off research/debug scripts; production scripts, tooling, bench-*, regen-*, parity-*, gen-model, and eval/serve scripts stay at `scripts/` root.
