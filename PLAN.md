# Refactor plan

Open work only; delete a block when its exit criteria are met. Josh has authorized the library and application migration through a first full
draft; keep changes focused and reviewed. Standalone Pi integration is deferred. Ownership and documentation rules live in [ARCHITECTURE.md](ARCHITECTURE.md).

## Verify the migrated library

- [ ] Establish real-weight parity for Qwen Trellis and Gemma, and extend MiniCPM
  beyond the [verified basic decode path](packages/inference/README.md#external-parity-evidence),
  against their applicable external oracle and main. Keep Python environments, setup,
  and reference generation outside this repository. Cover logits, state
  continuation, and relevant specialized paths under identical artifacts and
  settings. Exit: opt-in comparisons meet the numerical contracts against pinned
  published golden revisions that record source revisions and oracle versions;
  synthetic tests alone do not close this item.
- [ ] Confirm the long-term mixed-KV reference contract for single-query decode:
  the documented stock mlx-lm path or OptiQ serve's fused default. The opt-in
  state comparison verifies the existing composition; keep that implementation unchanged during
  this refactor and do not imply blanket OptiQ serve compatibility.
- [ ] Extend training preservation beyond the
  preservation-checked short MiniCPM SFT/DPO/ORPO paths.
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
datasets; experiments and benchmarks live outside it. Serial-only and
compilation switches stay absent by Josh's decision; isolation and pooling stay as
optional capabilities by his decision (see that row); nothing else here is dropped
without one.

| Feature | Library | Engine / host | Server | CLI | Web | Evidence | Next step or decision |
|---|---|---|---|---|---|---|---|
| Audio: Whisper transcription, Gemma4 audio input, voice sessions | done (`input/audio`, `models/whisper`, Conformer, VAD; decode/mel/format tests) | partial (Gemma4 audio tower loads; no Whisper service or resident/idle lifecycle) | 501 (`/v1/audio/*`, `/v1/audio/sessions*`, `/admin/transcription/unload`) | missing (`transcribe`, `dictate`, mic capture) | UI done (voice panel); chat mic probe wired false | missing (no paired Whisper run) | Whisper service owner in the engine with `--whisper-*` lifecycle, then routes, then verbs |
| Memory synthesis (nightly pipeline) | n/a (app-owned; main's synthesize/pipeline/stages/cluster/db/schedule not migrated) | partial (loopback completion client and tracked jobs exist from datasets) | 501 (`/v1/memory/synthesize`) | missing (`memory`, `setup`) | read panel done; synthesize button hits 501 | n/a (port main's pipeline/cluster/db tests) | Memory owner runs synthesis over the continuous engine client, never main's serial fallback; then verbs and schedule; `scheduleStatus` then reports real state |
| Live model switching, isolation, model pool | n/a | missing (main's `isolate`, `parent-application`, `responses-client`; `--isolate`, `--model-pool`, `--unix`) | restart answer done (`/api/hub/serve`); 501 (`/admin/lease`, `/admin/drain`, `/engine`) | flags absent | hub panel done | n/a | Decided (Josh): isolation and pooling stay as optional capabilities, off by default with a pool cap of 1, and web chat works under isolation (main answered 501 there). Owning implementation, after the CLI batch: I1 splits the app composition into persistent CPU state (web, Pi, Responses history, memory, jobs, downloads, credentials, sessions, settings) and model-scoped HTTP composition (native binding, caches, grammar, media, adapters, status) with no behavior change; I2 adds worker mode on a Unix socket with private admin lease/drain/health and packaged child re-execution through the `__job`-style entry; I3 adds the parent proxy behind `--isolate` (restart budget, 502 `engine_unavailable`, drain, shutdown, parent-owned Pi over loopback HTTP and parent-owned Responses history, `/engine`) with browser stream/stop/crash/reconnect acceptance in the same change; I4 adds the exact-id LRU pool behind `--model-pool` with serialized cold starts, drained eviction, library invalidation reaching live hosts, GC protecting every resident or loading model, Pi `local` as the default-worker alias, and job leases spanning all workers until child exit and log drain. Keeps the existing HTTP boundary; tensor-bearing engine calls are never transported. |
| Speculative decoding: draft models, n-gram, MTP, DSpark/DFlash | done (`generation/speculative`, MTP models and state) | partial (draft slot in the host; grouped draft required; ungrouped shapes report the typed capability error) | rides completions | done (`--draft-model`, `--draft-kind`, `--num-draft-tokens`, `--ngram-*`, `--mtp`; `--preload` is a Whisper flag, tracked in the audio row) | n/a | partial (opt-in ngram prompt-lookup run on MiniCPM with telemetry and exactness; no paired two-model or MTP run) | Shared execution for ungrouped drafts; paired two-model and MTP runs measured in the performance pass |
| Paged KV | done (`kernels/attention/paged`, `state/paged`) | partial (Gemma4 only; others report the typed error) | rides completions | done (`--paged-kv`, `--paged-kv-block-size`, env mirror) | n/a | partial (opt-in Gemma4 paged completion and the non-Gemma4 typed error; no paired numerical run) | Batched paged path for non-Gemma4, or an explicit drop decision |
| Serial-only request shapes: universal Gemma2 masks, sliding-attention caches, media without batched input, non-batchable quantized and Turbo KV, grammar with batching off, DiffusionGemma denoising | done (models exist, incl. `diffusion-gemma`, `universal`) | typed `UnsupportedExecutionError` per shape | 501 envelope | `generate` prints the error, exit 1 | n/a | per shape, when supported | Shared-scheduler support per shape (to support, not dropped); DiffusionGemma needs a denoising plan in the batched executor; resolve `--kv-quant turbo`, `--fused-sdpa`, `--l1`/`--l2`/`--l3` with layer policy |
| Evaluation and benchmarking: `bench`, `evals`, `perplexity`, EvalDB, eval tasks | n/a (experiments; the in-package bench harness moves out) | n/a | `/fit` measured fields stay null | not app verbs | status page shows dashes | n/a | Runs outside this repository, consuming the published packages and driving the app through its public HTTP and CLI surface; results are published as datasets or quoted as text in docs |
| Dataset `verified_code` execution | n/a | 501 at submit; template visible as unavailable | 501 | n/a | done | n/a | An owned sandboxed executor; main's `spawnSync` of generated Python is not to be ported |
| Pi terminal: `pi`, `harness pi` | n/a | chat backend reusable | n/a | held (`pi-terminal`, `harness-pi` not ported) | n/a | n/a | Held by Josh |
| Embedding API: `mlx-bun/client` and `mlx-bun/engine` (`createCompletionClient`, `createDirectHost`, `openIsolatedHost`) | n/a | missing (no app export; `startModelServer` is the only host entry) | n/a | n/a | n/a | n/a | Preserve as public app exports with new homes in the isolation series: the direct host from the I1 composition split, the isolated host from I3, the completion client over the existing HTTP boundary; package exports and consumer tests in the verifier |
| Existing-user data compatibility: prior-format sessions, jobs, settings, vault, caches; memory Reference symlinks that point into the main checkout | n/a | missing (no diagnosis) | n/a | n/a | n/a | n/a | Diagnosis and migration that preserve user edits, with prior-format inputs generated in-test (no fixtures committed); acceptance on an isolated copy of real user data |
| Docs surface and gates | n/a | n/a | HTTP/config inventories pending | CLI inventory generated from source | site and legacy redirects implemented | n/a | Per ARCHITECTURE: generate inventories from source as build-only output with a coverage gate (the server API from the route handlers' registered surfaces, the server configuration from the serve options and runtime keys), and write the explanations by hand (models, environment, training, memory, distribution, troubleshooting; quotable numbers as text with provenance in a benchmarks page). No STATUS file, docs map, or ledgers are restored. |
| Installation and release | n/a | n/a | n/a | bundle done (relocatable executable, opt-in verified) | n/a | n/a | All four install paths (Bun/npm launcher, Homebrew, curl script, source checkout) with app-only dependency closure and bin resolution; upgrade and version behavior; signing preparation (nested helpers, Bun entitlements, notarization status) without releasing; prior-data compatibility. Standalone third-party notices (build-binary copies only the MLX notices today) are owned separately by the reviewer's subagent. No actual release. |

- [ ] Completion: Josh could delete main without losing a capability it shipped.
  Exit: every row above is all-done or carries a recorded decision and is deleted;
  the verify items above close against pinned published goldens or are recorded
  decisions; main's user flows (CLI verbs, HTTP protocols, web chat, jobs,
  installed and compiled artifacts, existing user data) are accepted with real
  weights; documentation follows ARCHITECTURE (generated inventories, handwritten
  explanations, no ledgers); no capability main shipped is retired silently.
