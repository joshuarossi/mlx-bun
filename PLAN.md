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
  serial fallback: Gemma2 advanced compositions; model caches without batch
  conversion (including sliding-attention caches); media without a batched input binding; adapters
  without batched adapter support; non-batchable quantized KV and TurboQuant KV;
  grammar on attention-softcap universal models; remaining speculative target/cache combinations
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
| Audio: Whisper transcription, Gemma4 audio input, voice sessions | done (`input/audio`, `models/whisper`, Conformer, VAD; decode/mel/format tests) | done (`engine/transcription-service`: lazy load, `--whisper-idle-unload`/`--whisper-resident` lifecycle, exclusive-lock takes, sessions; Gemma4 audio tower loads) | done (`/v1/audio/transcriptions`, `/v1/audio/translations`, `/v1/audio/sessions*`, `/admin/transcription/unload`; transcription-only server for a Whisper main model; `/v1/models` companion entry) | done (`--whisper-model`, `--whisper-idle-unload`, `--whisper-resident`, `--preload`; `transcribe` and `dictate` over `engine/transcription-service`; `engine/mic-capture` runs main's AVAudioEngine sidecar, bundled with the package and standalone executable) | UI done (voice panel); chat mic probe wired to the companion; not yet exercised against a live server | partial (opt-in transcription-only server test passed with a synthesized tone; no paired Whisper run) | H3: voice UI acceptance against a running server; paired Whisper numerical run before performance work (also the only exercise of `transcribe`/`dictate` against real weights and a live microphone; CI covers them with fakes). Improvement (owner: audio): `transcribe --vad-trim` is accepted but not applied, as in main, although the service already implements `vad.trim`. |
| Memory synthesis (nightly pipeline) | n/a (app-owned; main's pipeline/stages/cluster/db/synthesize/wikify/crosslink/schedule ported op-for-op) | done (memory-owned `MemoryCompletionClient`; the loopback implementation posts to the server's `/v1/chat/completions`, no serial lane) | done (`GET /v1/memory/synthesize` SSE; `schedule` beside `status` in `GET /api/memory/status`) | done (`memory` verb: `init`/`setup` wizard with main's prompts behind a prompt seam, `status` with the nightly line, read subcommands, `synthesize`, stage workers, `link`, `schedule --at`/`unschedule` behind home/launchctl/program seams; `setup` is main's alias verb) | read panel done; no synthesize control exists (main had none either) | n/a (main's model-free memory tests ported; main had no schedule or setup tests, so `tests/memory/schedule.test.ts` and `tests/setup-cli.test.ts` are new and seam-driven; the oracle/golden suites stay outside) | Improvement (owner: memory): the nightly launchd job runs `mlx-bun memory synthesize`, which now needs a serving mlx-bun at its time (every status surface says so); the job should start (or be scheduled by) the server. Improvement (owner: memory): the entity seed gold is personal data read from a repository path; seed from the vault's own aliases (`EntityResolver.fromStore`) and drop the file. Improvement (owner: memory): `--since`/`--model` are parsed but never consumed; consume them (`model` maps naturally to the served model id) or remove them. |
| Live model switching, isolation, model pool | n/a | done (worker mode: `cli/worker-entry.ts`, `jobs/worker-process.ts`; parent proxy: `cli/serve-isolated.ts`, `jobs/worker-supervisor.ts`; model pool: `jobs/worker-pool.ts`) | restart answer done (`/api/hub/serve`); worker socket serves `/health`, `/admin/lease`, `/admin/drain` (`server/worker-routes.ts`); under `--isolate` the parent serves `/engine`, `/health`, `/stats`, `/downloads`, `/v1/responses` history (`server/proxy-routes.ts`, `server/responses-client.ts`), routes the five model-routed POSTs by exact `/v1/models` id through the pool, and proxies the rest; 501 on TCP (`/admin/lease`, `/admin/drain`; `/engine` without `--isolate`) | `--isolate` and `--model-pool` done | hub panel done | opt-in `tests/engine/isolate.test.ts` and `tests/engine/model-pool.test.ts` (real workers; not yet run) | Decided (Josh): isolation and pooling stay as optional capabilities, off by default with a pool cap of 1, and web chat works under isolation (main answered 501 there). The isolation series is complete: I1 `cli/serve-state.ts` + `serve-host.ts` behind an unchanged `startModelServer`; I2 worker mode (`cli/worker-entry.ts`, `server/worker-routes.ts`, `jobs/worker-process.ts`); I3 the parent proxy behind `--isolate` (`cli/serve-isolated.ts`, `server/proxy-routes.ts`, `jobs/worker-supervisor.ts`, `server/responses-client.ts`); I4 done: the exact-id LRU pool behind `--model-pool` (`jobs/worker-pool.ts`: serialized cold starts with spawn-overlap, drained eviction through the worker's own close, respawn on switch-back, library invalidation fanning out to every serving worker, GC protecting every resident, queued/loading, or draining snapshot through `servedModelPaths`, Pi's `local` as the default-worker alias, job leases joining active loads and evictions, covering every resident worker, and holding back cold starts until release), documented in the [app README](apps/mlx-bun/README.md#model-pool---model-pool) and proven by `tests/jobs/worker-pool.test.ts`, `tests/server/proxy-routes.test.ts`, `tests/serve-isolated.test.ts`; browser acceptance is the reviewer's. Keeps the existing HTTP boundary; tensor-bearing engine calls are never transported. |
| | | | | | | | Improvement (owner: isolation): the worker's `/health` can only report `ready`/`draining` because the socket binds after the model loads; a pre-bind stub listener would let the parent observe `loading` over the socket instead of inferring it from the missing ready line. |
| | | | | | | | Improvement (owner: isolation): Pi's SDK retries a request refused with 502 before generation started (three attempts, 2/4/8 s) without a browser frame; mapping its `auto_retry_start` event to a frame would show the wait during a respawn. |
| | | | | | | | Improvement (owner: isolation): the worker keeps its own bounded Responses store for requests the parent already records; honoring `x-mlx-bun-response-owner: parent` in the worker's routes would skip the duplicate. |
| | | | | | | | Improvement (owner: isolation): the parent's `/health` answers 200 with `engine.state` while the engine is exhausted; a distinct status for load balancers is a policy decision. |
| | | | | | | | Improvement (owner: isolation): the hub panel's serve action still answers `restart_required`; under `--isolate` it could switch live by routing an exact id through the pool. |
| | | | | | | | Improvement (owner: isolation): the pool remembers exact-id misses until a download or job invalidates the library, so a model fetched from another shell is not routable until then. |
| Speculative decoding: draft models, n-gram, MTP, DSpark/DFlash | done (`generation/speculative`, MTP models and state) | partial (draft slot in the host; grouped draft required; ungrouped shapes report the typed capability error) | rides completions | done (`--draft-model`, `--draft-kind`, `--num-draft-tokens`, `--ngram-*`, `--mtp`; `--preload` is a Whisper flag, tracked in the audio row) | n/a | partial (opt-in ngram prompt-lookup run on MiniCPM with telemetry and exactness; no paired two-model or MTP run) | Verify main-supported target/cache combinations with the seven existing grouped providers; paired two-model and MTP numerical runs, then performance measurements |
| Paged KV | done (`kernels/attention/paged`, `state/paged`) | partial (Gemma4 only; others report the typed error) | rides completions | done (`--paged-kv`, `--paged-kv-block-size`, env mirror) | n/a | partial (opt-in Gemma4 paged completion and the non-Gemma4 typed error; no paired numerical run) | Verify numerical preservation of main's Gemma4 paged path through shared execution; broader model support and cache ownership are tracked in Improvements identified during migration |
| Serial-only request shapes: Gemma2 advanced compositions (ordinary plain KV now batches), sliding-attention caches, media without batched input, non-batchable quantized and Turbo KV, grammar on attention-softcap universal models, DiffusionGemma denoising | done (models exist, incl. `diffusion-gemma`, `universal`) | typed `UnsupportedExecutionError` per shape | 501 envelope | `generate` prints the error, exit 1 | n/a | per shape, when supported | Shared-scheduler support per shape (to support, not dropped); DiffusionGemma needs a denoising plan in the batched executor; resolve `--kv-quant turbo`, `--fused-sdpa`, `--l1`/`--l2`/`--l3` with layer policy |
| Evaluation and benchmarking: `bench`, `evals`, `perplexity`, EvalDB, eval tasks | n/a (experiments; the in-package bench harness moves out) | n/a | `/fit` measured fields stay null | not app verbs | status page shows dashes | n/a | Runs outside this repository, consuming the published packages and driving the app through its public HTTP and CLI surface; results are published as datasets or quoted as text in docs |
| Dataset `verified_code` execution | n/a | 501 at submit; template visible as unavailable | 501 | n/a | done | n/a | An owned sandboxed executor; main's `spawnSync` of generated Python is not to be ported |
| Pi terminal: `pi`, `harness pi` | n/a | chat backend reusable | n/a | held (`pi-terminal`, `harness-pi` not ported) | n/a | n/a | Held by Josh |
| Embedding API: `mlx-bun/client` and `mlx-bun/engine` (`createCompletionClient`, `createDirectHost`, `openIsolatedHost`) | n/a | missing (no app export; `startModelServer` is the only host entry) | n/a | n/a | n/a | n/a | Preserve as public app exports with new homes in the isolation series: the direct host from the I1 composition split, the isolated host from I3, the completion client over the existing HTTP boundary; package exports and consumer tests in the verifier |
| Existing-user data compatibility: prior-format sessions, jobs, settings, vault, caches; memory Reference symlinks that point into the main checkout | n/a | missing (no diagnosis) | n/a | n/a | n/a | n/a | Diagnosis and migration that preserve user edits, with prior-format inputs generated in-test (no fixtures committed); acceptance on an isolated copy of real user data; before deleting the old checkout, inventory and preserve user-selected ignored adapters/checkpoints and other local artifacts outside it, because Git history cannot recover ignored files |
| Docs surface and gates | n/a | n/a | HTTP/config inventories pending | CLI inventory generated from source | site and legacy redirects implemented | n/a | Per ARCHITECTURE: generate inventories from source as build-only output with a coverage gate (the server API from the route handlers' registered surfaces, the server configuration from the serve options and runtime keys), and write the explanations by hand (models, environment, training, memory, distribution, troubleshooting; quotable numbers as text with provenance in a benchmarks page). No STATUS file, docs map, or ledgers are restored. |
| Installation and release | n/a | n/a | n/a | bundle, launchers, safe installer, formula and staged release preparation implemented | n/a | n/a | Complete the release acceptance checks below; public installer delivery must follow a compatible bundle release; prior-data compatibility. No actual release. |

## Release acceptance

- [ ] Finish GitHub/npm publication and tap synchronization with explicit package
  versions/private decisions and clean-source checks. Verify the intended Git tag
  and registry versions before publication, and require release notes for the
  release body. Actual publication requires Josh's release instruction.
- [ ] Gate release preparation on the existing relocated `bun run verify:binary`
  acceptance; `prepare` currently checks only the executable's version.
- [ ] With Josh's release instruction, verify real Developer ID signing and
  notarization, including loading the signed native libraries from a relocated
  signed bundle. The native-blocked version check and mocked commands do not
  establish this acceptance.
- [ ] Include the bundled Photon WASM's Apache-2.0 notice in the standalone
  notices; the current notice bundle covers only the MLX and inference libraries.
- [ ] Make partial signing retryable without weakening bundle integrity checks
  before the first real signed release. This is an operational improvement:
  today a partial signing failure safely requires rebuilding a fresh preparation.

## Completion

- [ ] Josh could delete main without losing a capability it shipped.
  Exit: every row above is all-done or carries a recorded decision and is deleted;
  the verify items above close against pinned published goldens or are recorded
  decisions; main's user flows (CLI verbs, HTTP protocols, web chat, jobs,
  installed and compiled artifacts, existing user data) are accepted with real
  weights; documentation follows ARCHITECTURE (generated inventories, handwritten
  explanations, no ledgers); no capability main shipped is retired silently.
