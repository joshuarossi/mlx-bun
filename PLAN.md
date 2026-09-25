# Refactor plan

Open work only; delete a block when its exit criteria are met. Josh has authorized the library and application migration through a first full
draft; keep changes focused and reviewed. Standalone Pi integration is deferred. Ownership and documentation rules live in [ARCHITECTURE.md](ARCHITECTURE.md).

## Verify the migrated library

- [ ] Establish real-weight parity for Qwen Trellis and Gemma, and extend MiniCPM
  beyond the [verified basic decode path](packages/inference/README.md#external-parity-evidence),
  against their applicable external oracle and main. Keep Python environments, setup,
  and reference generation outside this repository. Cover logits, state
  continuation, and relevant specialized paths under identical artifacts and
  settings. Exit: reproducible comparisons meet the numerical contracts, with
  source revisions, external oracle versions, and curated evidence in approved
  docs; synthetic tests alone do not close this item.
- [ ] Confirm the long-term mixed-KV reference contract for single-query decode:
  the documented stock mlx-lm path or OptiQ serve's fused default. The
  [state record](packages/inference/measurements/2026-09-25-runtime-state.json)
  verifies the existing composition; keep that implementation unchanged during
  this refactor and do not imply blanket OptiQ serve compatibility.
- [ ] Extend training preservation beyond the
  [preservation-checked short MiniCPM SFT/DPO/ORPO paths](packages/training/measurements/2026-09-25-training-preservation.json).
  Cover other model families and specialized training paths before claiming
  their numerical preservation; synthetic native tests do not close this item.
- [ ] Restore main's remaining training checks in their owning packages:
  `tests/parity/train-e2e.test.ts`, `train-batch-e2e.test.ts`,
  `train-orpo-e2e.test.ts`, `train-regularization-e2e.test.ts`, and
  `diffusion-lora.test.ts`; `tests/research/train-orpo-chunked.test.ts` and
  `train-orpo-fused-ce.test.ts`; and `tests/unit/train-autograd.test.ts`.
  Exit: the seven model tests use explicit caller-supplied cached artifacts,
  skip before native loading when not opted in, and retain their loss, gradient,
  adapter reload, batching, regularization, and specialized-head checks without
  importing old goldens or fixtures. The weight-free ValueAndGrad/Vjp
  finite-difference test belongs in `@mlx-bun/mlx` and must run in native Mac CI.

## Optimize after the full draft

- [ ] Run paired same-machine performance comparisons against main using the
  same artifacts and configuration. Exit: decode, prefill, complete-request time,
  and memory evidence is recorded; regressions are resolved or explicitly reviewed.

## Migrate the application

- [ ] Migrate the server, engine host, web app, and job orchestration into
  `apps/mlx-bun`, keeping their interfaces in the consuming domains. Exit: app consumers use public library APIs;
  application contracts and policy stay out of the inference library.
- [ ] Complete shared-execution support for all shapes main supported through its
  serial fallback: model caches without batch conversion (including Gemma2 masks
  and sliding-attention caches); media without a batched input binding; adapters
  without batched adapter support; non-batchable quantized KV and TurboQuant KV;
  grammar with batching disabled; paged KV without a batched implementation;
  speculative decoding without a grouped draft; and denoising. These are migration
  gaps to support, not dropped capabilities. The app currently reports a typed
  capability error for these shapes. Exit: each uses the shared scheduler and
  preserves main's behavior, verified with real weights and cancellation/streaming
  coverage, without a hidden serial fallback.
- [ ] Preserve continuous batching as the serving default, including single
  requests. Keep compilation choices inside specialized graph layers, without
  serial-only or compilation switches on the new app surface. Exit: the full
  draft preserves main's behavior and cancellation/streaming contracts before
  the subsequent performance pass.

## Remaining features by layer

One row per feature, one column per layer it crosses. A feature closes only when
every cell is done or an explicit decision marks it dropped; delete the row then.
Cells: `done` · `partial` · `missing` · `501` (route stubbed) · `n/a` · `held`.
Evidence means an opt-in real-weight test that passes against a pinned published
golden or regenerates it; synthetic tests never fill it. This repository carries
code, tests, and documentation; goldens, records, and benchmark data are published
datasets, and experiments live in a separate lab repository. Serial-only and
compilation switches stay absent by Josh's decision; nothing else here is dropped
without one.

| Feature | Library | Engine / host | Server | CLI | Web | Evidence | Next step or decision |
|---|---|---|---|---|---|---|---|
| Audio: Whisper transcription, Gemma4 audio input, voice sessions | done (`input/audio`, `models/whisper`, Conformer, VAD; decode/mel/format tests) | partial (Gemma4 audio tower loads; no Whisper service or resident/idle lifecycle) | 501 (`/v1/audio/*`, `/v1/audio/sessions*`, `/admin/transcription/unload`) | missing (`transcribe`, `dictate`, mic capture) | UI done (voice panel); chat mic probe wired false | missing (no paired Whisper run) | Whisper service owner in the engine with `--whisper-*` lifecycle, then routes, then verbs |
| Memory synthesis (nightly pipeline) | n/a (app-owned; main's synthesize/pipeline/stages/cluster/db/schedule not migrated) | partial (loopback completion client and tracked jobs exist from datasets) | 501 (`/v1/memory/synthesize`) | missing (`memory`, `setup`) | read panel done; synthesize button hits 501 | n/a (port main's pipeline/cluster/db tests) | Memory owner runs synthesis over the continuous engine client, never main's serial fallback; then verbs and schedule; `scheduleStatus` then reports real state |
| Hub download from the web | done (`downloadModel`; `DownloadOptions` lacks a signal) | n/a | 501 (`/api/hub/download`) | done (`get`) | UI done | n/a | Caller-owned cancel-and-join seam; shutdown joins transfers before closing their owner; then the route |
| Live model switching, isolation, model pool | n/a | missing (main's `isolate`, `parent-application`, `responses-client`; `--isolate`, `--model-pool`, `--unix`) | restart answer done (`/api/hub/serve`); 501 (`/admin/lease`, `/admin/drain`, `/engine`) | flags absent | hub panel done | n/a | Josh decides whether isolation and model-pool semantics survive into release; if yes, a new process-lifecycle owner |
| Speculative decoding: draft models, n-gram, MTP, DSpark/DFlash | done (`generation/speculative`, MTP models and state) | partial (draft slot in the host; grouped draft required; ungrouped shapes report the typed capability error) | rides completions | missing (`--draft-model`, `--draft-kind`, `--num-draft-tokens`, `--ngram-*`, `--mtp`, `--preload`) | n/a | missing (no paired speculative run) | Draft loading and flags in composition; shared execution for ungrouped drafts; measured in the performance pass |
| Paged KV | done (`kernels/attention/paged`, `state/paged`) | partial (Gemma4 only; others report the typed error) | rides completions | missing (`--paged-kv`, `--paged-kv-block-size`) | n/a | missing | Batched paged path for non-Gemma4, or an explicit drop decision |
| Deferred serving inputs: engine admission, media preprocessing, adapter defaults, shutdown timeout | done (`artifacts/expert-offload`, `experts/*`, adapters, media input) | missing (`--memory-budget`, `--force-wire`, `--context-length`, `--expert-offload` never wired; allocator limit unset; startup adapter mounting absent) | `/stats.admission.memory_budget_bytes` null | flags absent (`--memory-budget`, `--force-wire`, `--context-length`, `--expert-offload`, `--adapter`, `--adapter-path`, `--allow-private-media` now a library env, the `--hlg-*` family, `MLX_BUN_SHUTDOWN_TIMEOUT_MS`) | n/a | n/a | Restore as composition options plus serve flags with main's semantics |
| Serial-only request shapes: universal Gemma2 masks, sliding-attention caches, media without batched input, non-batchable quantized and Turbo KV, grammar with batching off, DiffusionGemma denoising | done (models exist, incl. `diffusion-gemma`, `universal`) | typed `UnsupportedExecutionError` per shape | 501 envelope | `generate` prints the error, exit 1 | n/a | per shape, when supported | Shared-scheduler support per shape (to support, not dropped); DiffusionGemma needs a denoising plan in the batched executor; resolve `--kv-quant turbo`, `--fused-sdpa`, `--l1`/`--l2`/`--l3` with layer policy |
| Training CLI | done (training package incl. fuse, merge, export; dropped parity tests tracked above) | done (finetune job, merge and export routes) | done | missing (`train`, `train-watch` dashboard, `fuse`) | done (finetune panel) | done for short MiniCPM SFT/DPO/ORPO; other paths tracked above | Thin verbs over the job host and training API |
| Quantize CLI | done | done (quantize job) | done | missing (`convert`, main's mlx_lm.convert counterpart) | done | done for uniform and mixed MiniCPM; rotation and Trellis unverified | `convert` verb over the same producer |
| Publishing CLI | done (hub upload) | n/a | done (push routes, HF settings) | missing (`upload`; main's `cli-upload` test) | done | n/a | Verb over the app publishing orchestration |
| Evaluation and benchmarking: `bench`, `evals`, `perplexity`, EvalDB, eval tasks | n/a (experiments; the in-package bench harness moves out) | n/a | `/fit` measured fields stay null | not app verbs | status page shows dashes | n/a | A separate lab repository consumes the published packages and drives the app through its public HTTP and CLI surface; its data is published as datasets; the performance pass runs there |
| Dataset `verified_code` execution | n/a | 501 at submit; template visible as unavailable | 501 | n/a | done | n/a | An owned sandboxed executor; main's `spawnSync` of generated Python is not to be ported |
| Lab pages: `/curves`, `/curve-terrain`, `/dag`, `/generate`, `/signal`, expert-trace, paged-kv lab | n/a | n/a | should be 404 (not product surface; currently in the 501 list) | n/a | `/dag` probe degrades | n/a | Out of the product: drop the placeholders; the Curve Designer and traces belong to the lab repository if kept |
| Cache admin | done (durability flush, session close) | done (`flush` in cache services) | 501 (`/admin/cache/flush`, `/admin/cache/session/close`) | n/a | n/a | n/a | Two thin routes; the documented SSD durability boundary |
| Pi terminal: `pi`, `harness pi` | n/a | chat backend reusable | n/a | held (`pi-terminal`, `harness-pi` not ported) | n/a | n/a | Held by Josh |
| Docs surface and gates | n/a | n/a | served surface documented only in `--help` and READMEs | same | same | n/a | Recreate main's `docs/reference/*` homes (cli, server-api, server-config, models, benchmarks, environment, distribution, training, memory) with the surface and hygiene gates; quotable numbers are text in the benchmarks doc |
| Installation and release | n/a | n/a | n/a | bundle done (relocatable executable, opt-in verified) | n/a | n/a | Bun, Homebrew, curl-script and source-checkout install paths; signing and notarization stay a release step |

- [ ] Every row above reaches all-done or carries a recorded drop decision. Exit:
  the row is deleted; no capability main shipped is retired silently.
