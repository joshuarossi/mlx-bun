# CLAUDE.md — working notes for agents on mlx-bun

Read PLAN.md first: phases, exit criteria, and the **Reference
environment** section (oracle venv, weights paths, measured baselines).
README.md has the pitch and scope boundaries.

**Doc map:**
- `STATUS.md` — live handoff: current state + next action (read this for "where are we").
- `PLAN.md` — durable phase log, exit criteria, findings (the engineering contract).
- Closed-phase history is in git, not a file: `git log --oneline -- PLAN.md` and `git show 3199c75:PLAN-archive.md` (the final archive snapshot before deletion).
- `README.md` — product pitch, quickstart, API surface, scope boundaries.
- `CONTEXT.md` — serving domain vocabulary and rejected synonyms.
- `benchmarks/RESULTS.md` — curated results: parity / performance / quality.
- `docs/reference/` — cli, server-api, server-config, features-matrix, library-api, embedding, distribution, training, orpo-quickstart, memory, models (user-facing reference).
- `docs/design/` — ACTIVE engineering docs (archived when their work closes — CONTRIBUTING.md rule 3): adapters-end-to-end, audio-input-plan, batching-perf-path, batching-v2-plan, bucketing-stage, colibri-glm52-port, compat-cli-surface-design, decode-speed-program, diffusion-gemma-port, docs-reorg-plan, dreaming-nightly-pipeline, dspark-serving-program, dspark-speculative-decoding, faithful-l1-consolidation, generic-model-support, grammar-spec-batching-integration, memory-inference-path, memory-synthesis, memory-system, minicpm5-decode-megakernel, mlx-lm-serving-execution-seam, mlx-lm-tool-parity-plan, omlx-adoption-map, optimization_plan, orpo-dynamic-lambda, orpo-future-enhancements, orpo-training, paged-kv-cache, parallel-slots, parity-tier-dag, pre-colibri-stabilization, repo-cleanup-plan, runtime-isolation, segmented-backward-training, spec-decode-larger-targets, ssd-kv-cold-tier, structured-output, tauri-desktop-app, the-dreaming-handoff, the-dreaming-master-plan, turboquant-kv, turboquant-weights, unified-engine-frontier-plan, w4a16-compute-precision-spike, web-chat-beat-matrix, web-chat-redesign, write-pipeline-entity.
- `docs/planning/` — LIVING product/vision docs only: PRODUCT_ROADMAP (absorbed IDEAS), ResearchTopics, video-series, release-notes-v0.2.0 (unpublished draft).
- `docs/archive/` — frozen history; read-only, never extended in place. Completed investigations (chunk-finetune-experiment, colibri-oracle-pin, curve-bisector-routing, decode-roofline-lookagain, dspark-handoff, expert-offload-single-user-moe, hlg-blind-prompts, hlg-sampling-investigation, indexshare-performance-spike, kernel-perf-review-2026-07, lab-build-journal, openwiki-evaluation, orpo-base-uf-experiment-and-directions, orpo-flash-cce-pin-leak, orpo-uf-testing-handoff, pareto-specialized-runtime-findings, pi-builtin-investigation, segmented-backward-handoff, starter-model-port-handoff, steel-flash-cce-handoff, trainer-validation-experiment), superseded design docs (hlg-sampling), retired planning docs (journal, chat-ui-vision, chat-ui-vision-memory-first, web-ui-pass-plan, website-readme-pass-plan, chunk-task-roadmap, curve-sampler-research-plan, memory-docs-and-dag-plan, pi-integration-review), release notes (release-notes-v0.0.9, release-notes-v0.0.10, release-notes-v0.0.11, release-notes-v0.0.12, release-notes-v0.0.13). Raw run data + generated HTML deleted 2026-08-23 — recover via `git show c61bc4b:<path>`.
- (Keep these lists in sync with `ls docs/{reference,design,planning,archive}/**/*.md` when adding or archiving docs — the docs-map hygiene gate enforces coverage by basename.)
- `AGENTS.md` → symlink to this file.

**Repo layout (root dirs, one line each — keep this honest):**
- `src/` code · `tests/` gated + fast suites · `scripts/` production tooling (`scripts/experiments/` = one-off research) · `docs/` see map above · `website/` the site (deploys from main) · `benchmarks/` curated RESULTS.md.
- `goldens/` parity fixtures — `.json` manifests tracked, `.bin` blobs machine-specific + regenerable + UNTRACKED (see goldens/README.md).
- `fixtures/` small tracked test inputs (images, tiny safetensors) used by the model-free CI suite.
- `lab/` code that proves a point but isn't the product: `lab/repro/` minimal reproductions for UPSTREAM bug reports (e.g. `bun-ffi-f64/` = Bun FFI float64 bug, ISSUE.md inside); `lab/spikes/` one-off feasibility probes (tiny). Self-contained, not part of the build.
- `docs/archive/` frozen one-off HTML reports (was root `archive/`).
- `packaging/` signing entitlements + Homebrew formula source-of-truth; `bin/` the npm launcher; `extensions/` pi provider extension.
- Untracked working dirs (gitignored, machine-local): `adapters/`, `runs/`, `reports/`, `dist*/`, `node_modules/`, stray bench artifacts.

## Ground rules

- **Never start long-running servers or multi-GB downloads from a
  session.** Josh runs servers himself (`/Users/joshrossi/Code/mlx-lm/serve.sh`
  is the Python reference server). Testing against an already-running
  server with curl is fine. Ask before anything persistent.
- **Work the plan**: find the next unchecked box in PLAN.md, do it, update
  the marker, record decisions in PLAN.md (e.g. the Phase 0 pivot
  decision). PLAN.md is the durable state between sessions — write
  conclusions down; don't rely on conversation memory.
- **Docs land WITH the feature, reference docs included.** A change to the
  served surface (flags, request/response fields, lane routing, defaults)
  updates the user-facing mirror in the SAME commit: server-config.md,
  server-api.md, cli.md, README as applicable — not just STATUS and the
  design doc next to the code. Reference-doc drift is the observed failure
  mode (2026-07-03 sweep: structured output was undocumented in
  server-api.md, cli.md lacked three flags, README pinned dead versions).
  Avoid literal version strings in prose; the docs-map hygiene gate checks
  file coverage, not content — content accuracy is this rule.
- **Logit parity with mlx-lm is the correctness oracle.** The Python
  reference lives in `/Users/joshrossi/Code/mlx-lm/.venv` (mlx 0.31.2,
  mlx-lm 0.31.3, mlx-optiq 0.2.15). Run reference scripts with that venv's
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

- Bun pinned at ≥ 1.4.0: `Bun.Image` (native OS
  image codecs incl. HEIC/AVIF) is the decode path for vision inputs —
  see `src/vision/preprocess.ts`. Full test suite re-verified post-upgrade.
- `Bun.mmap` panics (SIGTRAP) on files > 4 GB (still true in 1.3.14) —
  use libc mmap via bun:ffi (`src/mmap.ts`).
- Metal/mlx cannot no-copy-wrap host pointers that aren't page-aligned:
  GPU ops silently read garbage (CPU-stream ops are fine). Weights load
  via `mlx_load_safetensors` on the **CPU stream** (Load has no GPU
  kernel). See PLAN.md Phase 1 findings.
- bun:ffi (≤1.3.14) mis-lays sub-8-byte STACK args on macOS arm64: it
  writes one 8-byte slot per arg, but the Apple ABI packs stack args at
  natural size — a binding whose 9th+ int-class args put an i32 before
  more args hands the callee shifted garbage (mlx_conv2d's
  segfault-at-0x1; the bogus value landed in the stream arg). Fix: pack
  adjacent stack-i32 pairs into ONE u64 little-endian (see ops.conv2d).
  f32 args don't count toward the 8 (they ride v-registers); all-u64/ptr
  tails and a lone trailing bool are safe. Repro:
  lab/repro/bun-ffi-stack-args. Bun 1.4 fixes the ABI layout, so bindings now
  use their natural header signatures and the packed-u64 workaround is gone.
- When binding mlx-c functions, read the full signature from the header
  first — a missed trailing optional param shifts the stream arg and
  produces "There is no Stream(...)" errors at eval time.
- HF downloads: Xet stalls on this network — `HF_HUB_DISABLE_XET=1`.
  Auth is set up (`hf auth login` done).
- optiq tooling wants local snapshot *paths*, not HF repo ids (its
  runtime treats `--model` as a filesystem path in places).
- The OptiQ vision sidecar (`optiq_vision.safetensors`, bf16, ~105 MB)
  auto-enables in optiq serve when present; needs pillow in Python land.
- mlx-lm's server prompt cache is byte-capped now (as of the pinned
  oracle, mlx-lm 0.31.3): `LRUPromptCache` in `models/cache.py` takes
  `max_size` (default 10) AND `max_bytes`, evicting through a typed LRU
  (`CacheOrder`, assistant/user/system deques); `--prompt-cache-bytes`
  trims to budget in server.py. The old "count-capped only" OOM footgun
  is fixed upstream — the lesson stands: ours must be byte-capped.
- NEVER hand mlx a buffer dtor that calls into JS (bun:ffi JSCallback):
  mlx releases the last `array::Data` ref from the **Metal completion
  thread** (gpu::eval retains buffers until the command buffer completes,
  i.e. past dispose()), and a JS callback there deadlocks serving or
  SIGTRAPs mid-GC (2026-07-06 restart-restore hang). Use a native dtor
  (`dlsym(free)` + payload 0) and pin backing mmaps for the process.
  Related: bun:ffi symbol `.ptr` returns the address BIT-CAST TO FLOAT64
  (lab/repro/bun-ffi-f64) — resolve function addresses via dlsym.
- mlx-lm's TokenizerWrapper injects `enable_thinking=True` by default for
  thinking-capable models (`tokenizer_utils.py` `apply_chat_template`:
  `kwargs["enable_thinking"] = self.has_thinking` when the caller didn't
  set it) — a standing hazard for any cross-stack parity/bench prompt:
  pin `enable_thinking` explicitly or the rendered prompts drift.
- pi integration: `~/.pi/agent/models.json`, provider pattern documented
  there; optiq servers require apiKey starting with `sk-optiq-`.
- `scripts/experiments/` holds one-off research/debug scripts; production scripts, tooling, bench-*, regen-*, parity-*, gen-model, and eval/serve scripts stay at `scripts/` root.
