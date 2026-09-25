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
- [ ] Finish restoring main's training checks: `diffusion-lora.test.ts` is
  ported to `packages/training/tests/native/diffusion-lora.test.ts`, opted in
  with `MLX_BUN_TRAINING_DIFFUSION_MODEL`; real-weight acceptance is pending a
  coordinated GPU slot. Exit: that run passes on the cached checkpoint. (The
  flash-CCE STEEL kernels compile again: the copied steel header now carries
  upstream MLX's explicit `thread` qualifiers for MSL 4.1, and the ported
  fused-CE matrix passes in full against the fused head; main still carries
  the unqualified header.)

## Optimize after the full draft

- [ ] Run paired same-machine performance comparisons against main using the
  same artifacts and configuration. Exit: decode, prefill, complete-request time,
  and memory evidence is recorded; regressions are resolved or explicitly reviewed.

## Improvements identified during migration

Record concrete improvements here as they are discovered, with the current
limitation and the responsible library or app domain. Preserve shipped behavior
first; an improvement is not permission to redesign its implementation during
migration. Existing migration gaps remain required work in the feature table.

- [ ] Generalize paged KV across supported models that use KV attention (Josh's
  target). Main's app restricted paging to Gemma4, and the migrated library's shared
  execution binding currently has the same family restriction; the app reports
  an unsupported-execution error for other families. Broader support is an
  improvement, not a missing capability previously exposed by the app. Cache storage, block allocation,
  row operations, snapshots and lifecycle belong to the cache library domain
  (currently `packages/inference/src/state/`, including `state/paged/`). Model
  graphs supply attention/cache bindings through lower-level contracts; numerical
  paged-attention kernels remain in `kernels/`, and execution owns scheduling.
  Extend those seams rather than put model switches in the cache implementation.
  Check mixed recurrent/KV models explicitly: recurrent state is not itself a KV
  cache. Exit: supported KV attention paths use the cache contract with real-model
  numerical, continuation, cancellation and batched-execution coverage. This
  records the ownership and target; it does not introduce a new package now.

## Migrate the application

- [ ] Migrate the server, engine host, web app, and job orchestration into
  `apps/mlx-bun`, keeping their interfaces in the consuming domains. Exit: app consumers use public library APIs;
  application contracts and policy stay out of the inference library.
- [ ] Complete shared-execution support for all shapes main supported through its
  serial fallback: model caches without batch conversion (including Gemma2 masks
  and sliding-attention caches); media without a batched input binding; adapters
  without batched adapter support; non-batchable quantized KV and TurboQuant KV;
  grammar with batching disabled; remaining speculative target/cache combinations
  supported by main; and denoising. All seven built-in draft providers already
  implement grouped execution; their presence alone does not establish real-model
  compatibility for every target/cache combination. These are migration
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
| Audio: Whisper transcription, Gemma4 audio input, voice sessions | done (`input/audio`, `models/whisper`, Conformer, VAD; decode/mel/format tests) | done (`engine/transcription-service`: lazy load, `--whisper-idle-unload`/`--whisper-resident` lifecycle, exclusive-lock takes, sessions; Gemma4 audio tower loads) | done (`/v1/audio/transcriptions`, `/v1/audio/translations`, `/v1/audio/sessions*`, `/admin/transcription/unload`; transcription-only server for a Whisper main model; `/v1/models` companion entry) | partial (`--whisper-model`, `--whisper-idle-unload`, `--whisper-resident`, `--preload` done; `transcribe`, `dictate`, mic capture missing) | UI done (voice panel); chat mic probe wired to the companion; not yet exercised against a live server | partial (opt-in transcription-only server test with a synthesized tone, written but not yet run; no paired Whisper run) | H2: `transcribe`/`dictate` verbs and the mic-capture sidecar; H3: voice UI acceptance against a running server; paired Whisper run in the performance pass |
| Memory synthesis (nightly pipeline) | n/a (app-owned; main's synthesize/pipeline/stages/cluster/db/schedule not migrated) | partial (loopback completion client and tracked jobs exist from datasets) | 501 (`/v1/memory/synthesize`) | missing (`memory`, `setup`) | read panel done; synthesize button hits 501 | n/a (port main's pipeline/cluster/db tests) | Memory owner runs synthesis over the continuous engine client, never main's serial fallback; then verbs and schedule; `scheduleStatus` then reports real state |
| Live model switching, isolation, model pool | n/a | missing (main's `isolate`, `parent-application`, `responses-client`; `--isolate`, `--model-pool`, `--unix`) | restart answer done (`/api/hub/serve`); 501 (`/admin/lease`, `/admin/drain`, `/engine`) | flags absent | hub panel done | n/a | Decided (Josh): isolation and pooling stay as optional capabilities, off by default with a pool cap of 1, and web chat works under isolation (main answered 501 there). Owning implementation, after the CLI batch: I1 splits the app composition into persistent CPU state (web, Pi, Responses history, memory, jobs, downloads, credentials, sessions, settings) and model-scoped HTTP composition (native binding, caches, grammar, media, adapters, status) with no behavior change; I2 adds worker mode on a Unix socket with private admin lease/drain/health and packaged child re-execution through the `__job`-style entry; I3 adds the parent proxy behind `--isolate` (restart budget, 502 `engine_unavailable`, drain, shutdown, parent-owned Pi over loopback HTTP and parent-owned Responses history, `/engine`) with browser stream/stop/crash/reconnect acceptance in the same change; I4 adds the exact-id LRU pool behind `--model-pool` with serialized cold starts, drained eviction, library invalidation reaching live hosts, GC protecting every resident or loading model, Pi `local` as the default-worker alias, and job leases spanning all workers until child exit and log drain. Keeps the existing HTTP boundary; tensor-bearing engine calls are never transported. |
| Speculative decoding: draft models, n-gram, MTP, DSpark/DFlash | done (`generation/speculative`, MTP models and state) | partial (draft slot in the host; grouped draft required; ungrouped shapes report the typed capability error) | rides completions | done (`--draft-model`, `--draft-kind`, `--num-draft-tokens`, `--ngram-*`, `--mtp`; `--preload` is a Whisper flag, tracked in the audio row) | n/a | partial (opt-in ngram prompt-lookup run on MiniCPM with telemetry and exactness; no paired two-model or MTP run) | Verify main-supported target/cache combinations with the seven existing grouped providers; paired two-model and MTP numerical runs, then performance measurements |
| Paged KV | done (`kernels/attention/paged`, `state/paged`) | partial (Gemma4 only; others report the typed error) | rides completions | done (`--paged-kv`, `--paged-kv-block-size`, env mirror) | n/a | partial (opt-in Gemma4 paged completion and the non-Gemma4 typed error; no paired numerical run) | Verify numerical preservation of main's Gemma4 paged path through shared execution; broader model support and cache ownership are tracked in Improvements identified during migration |
| Serial-only request shapes: universal Gemma2 masks, sliding-attention caches, media without batched input, non-batchable quantized and Turbo KV, grammar with batching off, DiffusionGemma denoising | done (models exist, incl. `diffusion-gemma`, `universal`) | typed `UnsupportedExecutionError` per shape | 501 envelope | `generate` prints the error, exit 1 | n/a | per shape, when supported | Shared-scheduler support per shape (to support, not dropped); DiffusionGemma needs a denoising plan in the batched executor; resolve `--kv-quant turbo`, `--fused-sdpa`, `--l1`/`--l2`/`--l3` with layer policy |
| Evaluation and benchmarking: `bench`, `evals`, `perplexity`, EvalDB, eval tasks | n/a (experiments; the in-package bench harness moves out) | n/a | `/fit` measured fields stay null | not app verbs | status page shows dashes | n/a | Runs outside this repository, consuming the published packages and driving the app through its public HTTP and CLI surface; results are published as datasets or quoted as text in docs |
| Dataset `verified_code` execution | n/a | 501 at submit; template visible as unavailable | 501 | n/a | done | n/a | An owned sandboxed executor; main's `spawnSync` of generated Python is not to be ported |
| Pi terminal: `pi`, `harness pi` | n/a | chat backend reusable | n/a | held (`pi-terminal`, `harness-pi` not ported) | n/a | n/a | Held by Josh |
| Embedding API: `mlx-bun/client` and `mlx-bun/engine` (`createCompletionClient`, `createDirectHost`, `openIsolatedHost`) | n/a | missing (no app export; `startModelServer` is the only host entry) | n/a | n/a | n/a | n/a | Preserve as public app exports with new homes in the isolation series: the direct host from the I1 composition split, the isolated host from I3, the completion client over the existing HTTP boundary; package exports and consumer tests in the verifier |
| Existing-user data compatibility: prior-format sessions, jobs, settings, vault, caches; memory Reference symlinks that point into the main checkout | n/a | missing (no diagnosis) | n/a | n/a | n/a | n/a | Diagnosis and migration that preserve user edits, with prior-format inputs generated in-test (no fixtures committed); acceptance on an isolated copy of real user data; before deleting the old checkout, inventory and preserve user-selected ignored adapters/checkpoints and other local artifacts outside it, because Git history cannot recover ignored files |
| Docs surface and gates | n/a | n/a | served surface documented only in `--help` and READMEs | same | same | n/a | Per ARCHITECTURE: generate inventories from source as build-only output with a coverage gate (the CLI reference from the command table, the server API from the route handlers' registered surfaces, the server configuration from the serve options and runtime keys), and write the explanations by hand (models, environment, training, memory, distribution, troubleshooting; quotable numbers as text with provenance in a benchmarks page). No STATUS file, docs map, or ledgers are restored. |
| Installation and release | n/a | n/a | n/a | bundle done (relocatable executable, opt-in verified) | n/a | n/a | All four install paths (Bun/npm launcher, Homebrew, curl script, source checkout) with app-only dependency closure and bin resolution; upgrade and version behavior; signing preparation (nested helpers, Bun entitlements, notarization status) without releasing; website and generated references; prior-data compatibility. Capture the original compiled executable identity at startup for managed jobs and isolated workers; verify the first child after repeated symlink upgrades uses the original build (the current job runner first reads Bun's lazy `process.execPath` at submission). Standalone third-party notices (build-binary copies only the MLX notices today) are owned separately by the reviewer's subagent. No actual release. |

- [ ] Completion: Josh could delete main without losing a capability it shipped.
  Exit: every row above is all-done or carries a recorded decision and is deleted;
  the verify items above close against pinned published goldens or are recorded
  decisions; main's user flows (CLI verbs, HTTP protocols, web chat, jobs,
  installed and compiled artifacts, existing user data) are accepted with real
  weights; documentation follows ARCHITECTURE (generated inventories, handwritten
  explanations, no ledgers); no capability main shipped is retired silently.
