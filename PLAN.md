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
  synthetic tests alone do not close this item. Same-shaped component controls
  isolate a change without qualifying the candidate: real Gemma2 B2 rows and a
  different prefill chunk geometry differ from main's B1 in logits and valid KV,
  an open difference that needs same-shaped oracle or main comparisons and
  investigation, not a tolerance.
- [ ] Confirm the long-term mixed-KV reference contract for single-query decode:
  the documented stock mlx-lm path or OptiQ serve's fused default. The opt-in
  state comparison verifies the existing composition; keep that implementation unchanged during
  this refactor and do not imply blanket OptiQ serve compatibility.
- [ ] Extend training preservation beyond the
  preservation-checked short MiniCPM SFT/DPO/ORPO paths and the short Qwen3.5 and
  Gemma4 e4b SFT pairs (two updates each: exact losses and adapter tensors, and a
  fresh reload that changes logits).
  Cover other model families and specialized training paths before claiming
  their numerical preservation; synthetic native tests do not close this item.

## Three gates before replacing main

Finish the remaining implementation first, then run these on the assembled
candidate before saving main to a reference branch and merging
`refactor/monorepo` into main. Inventory the existing benchmark and
evaluation suites from main rather than substituting a smaller smoke suite.
Pin both source revisions and retain reproducible commands and results outside
Git; reusable verification code stays in Git. Focused PR checks do not close
these gates. The full applicable numerical parity suites remain required too.

- [ ] **Intelligence benchmarks.** Run the full existing evaluation suite,
  including GSM8K and the other intelligence benchmarks main provides, against
  both main and the candidate. Match model artifacts, dataset revisions and
  splits, prompts/templates, scoring, sampling settings, seeds and limits.
  Report per-benchmark scores and failed or skipped evaluations; investigate
  and resolve regressions before accepting the gate. A smoke run or subset
  does not establish full-suite acceptance.
- [ ] **Head-to-head performance.** Run the usual full H2H suite on the same
  quiet machine with the same artifacts, inputs, configuration and execution
  shapes, including single-request and batched workloads. Exit: decode,
  prefill, complete-request time and memory match main in paired measurements;
  regressions are traced and fixed, with affected parity and benchmarks rerun.
- [ ] **Full capability gap analysis and acceptance.** Inventory what main
  actually exposes and exercise its equivalent in the candidate: library APIs,
  CLI verbs/options, HTTP protocols and streaming, web workflows, jobs,
  supported model/cache/generation capabilities, isolation/pooling,
  installation/build artifacts and existing user data. Trace every capability
  to passing acceptance evidence or Josh's explicit decision to change or defer
  it. A route's presence, synthetic test, skipped test or 501 placeholder is not
  proof that the workflow works. Resolve unapproved gaps and rerun affected
  flows; preserve working capabilities without reproducing main's bugs or
  accidental composition restrictions.

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
  conversion; sliding-attention Universal descriptors (now admitted through their
  bound cache operations and per-group masks; real-weight gateway acceptance of
  ordinary, speculative, grammar, fill and encoded paths is open); media without a batched input binding; adapters
  without batched adapter support; non-batchable quantized KV and TurboQuant KV;
  remaining speculative target/cache combinations
  supported by main; and denoising (interleaved shared execution landed for text and
  image requests; real-image cancellation and same-group reuse are verified directly,
  and paired B1 HTTP image disconnect, drain and recovery passed, see the denoising row). All seven built-in draft providers already
  implement grouped execution; their presence alone does not establish real-model
  compatibility for every target/cache combination. These are migration
  gaps to support, not dropped capabilities. The app reports a typed capability
  error for combinations that remain unsupported. Exit: each uses the shared scheduler and
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
| Audio: Whisper transcription, Gemma4 audio input, voice sessions | done (`input/audio`, `models/whisper`, Conformer, VAD; decode/mel/format tests) | done (`engine/transcription-service`: lazy load, `--whisper-idle-unload`/`--whisper-resident` lifecycle, exclusive-lock takes, sessions; Gemma4 audio tower loads) | done (`/v1/audio/transcriptions`, `/v1/audio/translations`, `/v1/audio/sessions*`, `/admin/transcription/unload`; transcription-only server for a Whisper main model; `/v1/models` companion entry) | done (`--whisper-model`, `--whisper-idle-unload`, `--whisper-resident`, `--preload`; `transcribe` and `dictate` over `engine/transcription-service`; `engine/mic-capture` runs main's AVAudioEngine sidecar, bundled with the package and standalone executable) | UI done (composer hold-to-talk dictation through the Whisper companion); in review, two synthetic-microphone dictations passed through the browser composer against a live chat server with a Whisper companion; physical-microphone input remains unqualified. Main and the refactor expose audio upload and translation through HTTP, without dedicated web controls | partial (opt-in transcription-only server test passed with a synthesized tone; in review, paired Whisper numerics against main passed (traced tensors exact for the same checkpoint, audio and options), the transcription-only HTTP lifecycle passed on synthetic English and Spanish speech (multipart and JSON uploads, the translate task, SSE, voice sessions with Silero VAD, unload and reload, stream-disconnect recovery), and two synthetic-microphone dictations passed through the actual browser composer (VAD and Whisper, keyboard and pointer release, caret insertion, recovery; an optional browser network diagnostic failed after the functional assertions); in review, Gemma4 e4b plain-KV audio-only HTTP matched main's prepared embeddings/masks, default-policy outputs and usage, and uncompiled full 262,144-vocabulary logits at B1 and B2 (two identical requests released together after preparation), with stream-disconnect rejection, drain and text recovery; this does not qualify KV planes, other media/model variants, external-oracle parity or performance) | Physical-microphone `dictate`, Gemma4 audio beyond that e4b plain-KV audio-only scope (including mixed image+audio and other model variants), and chat-companion contention and idle-unload timing remain unqualified (CI covers `transcribe`/`dictate` with fakes); performance work follows. Improvement (owner: audio): `transcribe --vad-trim` is accepted but not applied, as in main, although the service already implements `vad.trim`. |
| Memory synthesis (nightly pipeline) | n/a (app-owned; main's pipeline/stages/cluster/db/synthesize/wikify/crosslink/schedule ported op-for-op) | done (memory-owned `MemoryCompletionClient`; the `memory` verb and its nightly job load the memory task model in-process on first use over the app engine's continuous gateway, `cli/memory-engine.ts`, as main did, or use a serving mlx-bun given explicit `--host`/`--port`; `serve`'s own synthesis uses that task model too, created by the first run and resident until shutdown, each completion under the served engine's execution lease so it never overlaps a managed job (chat waits during a memory stage call; main ran them side by side), with each run's cancellation reaching its in-flight completions; under `--isolate` the parent keeps the pipeline, vault and SSE and sends each stage call or batch to the default model worker's private `POST /admin/memory/complete`, where that worker's lazily loaded task model runs it under the worker's execution lease; no serial lane) | done (`GET /v1/memory/synthesize` SSE; `schedule` beside `status` in `GET /api/memory/status`) | done (`memory` verb: `init`/`setup` wizard with main's prompts behind a prompt seam, `status` with the nightly line, read subcommands, `synthesize`, stage workers, `link`, `schedule --at`/`unschedule` behind home/launchctl/program seams; `setup` is main's alias verb) | read panel done; no synthesize control exists (main had none either) | partial (opt-in `tests/engine/memory-native.test.ts` passed: each stage decodes token-for-token as main's bit-exact greedy loop, the chunk adapter changes only the chunk stage, a width-3 batch decodes as one group; the opt-in `--isolate` synthesis case in `tests/engine/isolate.test.ts` passed in review (the task model resident in the default worker, not the parent; wikify on the base task model; an admitted worker call cancelled and joined; served chat unaffected; clean worker and socket shutdown); an external run against main's memory client matched full logits, per-layer KV and text for every stage at width 1 and for width-3 batches; main's model-free memory tests ported; main had no schedule or setup tests, so `tests/memory/schedule.test.ts` and `tests/setup-cli.test.ts` are new and seam-driven; the oracle/golden suites stay outside) | Preserved differently (owner: memory, isolation): under `--isolate` main forwarded `/v1/memory/synthesize` to its default model child, which loaded the task model (e4b and its chunk adapter) as a second resident runtime; here the parent keeps the pipeline, vault and SSE and the default model worker owns the task model (the same second runtime, dropped with that worker on eviction or restart; the pool cap still counts workers only). The parent selects the task snapshot per call, the worker's lazy load loads exactly that directory, and the pool keeps it out of hub GC until that worker has closed. Improvement (owner: memory): the entity seed gold is personal data read from a repository path; seed from the vault's own aliases (`EntityResolver.fromStore`) and drop the file. Gap (owner: memory): `--since`/`--model` are parsed but never consumed (main reserved them too); consuming them is a decision, not part of restoring the in-process task model. |
| Live model switching, isolation, model pool | n/a | done (worker mode: `cli/worker-entry.ts`, `jobs/worker-process.ts`; parent proxy: `cli/serve-isolated.ts`, `jobs/worker-supervisor.ts`; model pool: `jobs/worker-pool.ts`) | restart answer done (`/api/hub/serve`); worker socket serves `/health`, `/admin/lease`, `/admin/drain`, and the default worker's `/admin/memory/complete` (`server/worker-routes.ts`); under `--isolate` the parent serves `/engine`, `/health`, `/stats`, `/downloads`, `/v1/responses` history (`server/proxy-routes.ts`, `server/responses-client.ts`), routes the five model-routed POSTs by exact `/v1/models` id through the pool, and proxies the rest; 501 on TCP (`/admin/lease`, `/admin/drain`; `/engine` without `--isolate`), 404 for `/admin/memory/complete` | `--isolate` and `--model-pool` done | hub panel done | native and browser acceptance passed in review: `--isolate` on MiniCPM5-1B-OptiQ-4bit (streamed generation, SIGKILL then 502 then restart with the same greedy output, the bounded restart limit, clean close) and in the browser (streaming, Stop, mid-stream worker death, session after reload, generation after respawn) (#133); `--model-pool` on MiniCPM5-1B and Qwen3.5-0.8B (both resident at cap 2, discovery, cap-1 eviction and reload, clean close) and in the browser, including a real quantize job holding both workers' leases (#134); lifecycle acceptance, not performance or oracle parity | Decided (Josh): isolation and pooling stay as optional capabilities, off by default with a pool cap of 1, and web chat works under isolation (main answered 501 there). The isolation series is complete: I1 `cli/serve-state.ts` + `serve-host.ts` behind an unchanged `startModelServer`; I2 worker mode (`cli/worker-entry.ts`, `server/worker-routes.ts`, `jobs/worker-process.ts`); I3 the parent proxy behind `--isolate` (`cli/serve-isolated.ts`, `server/proxy-routes.ts`, `jobs/worker-supervisor.ts`, `server/responses-client.ts`); I4 done: the exact-id LRU pool behind `--model-pool` (`jobs/worker-pool.ts`: serialized cold starts with spawn-overlap, drained eviction through the worker's own close, respawn on switch-back, library invalidation fanning out to every serving worker, GC protecting every resident, queued/loading, or draining snapshot through `servedModelPaths`, Pi's `local` as the default-worker alias, job leases joining active loads and evictions, covering every resident worker, and holding back cold starts until release), documented in the [app README](apps/mlx-bun/README.md#model-pool---model-pool) and proven by `tests/jobs/worker-pool.test.ts`, `tests/server/proxy-routes.test.ts`, `tests/serve-isolated.test.ts`. Keeps the existing HTTP boundary; tensor-bearing engine calls are never transported. |
| | | | | | | | Improvement (owner: isolation): the worker's `/health` can only report `ready`/`draining` because the socket binds after the model loads; a pre-bind stub listener would let the parent observe `loading` over the socket instead of inferring it from the missing ready line. |
| | | | | | | | Improvement (owner: isolation): Pi's SDK retries a request refused with 502 before generation started (three attempts, 2/4/8 s) without a browser frame; mapping its `auto_retry_start` event to a frame would show the wait during a respawn. |
| | | | | | | | Improvement (owner: isolation): the worker keeps its own bounded Responses store for requests the parent already records; honoring `x-mlx-bun-response-owner: parent` in the worker's routes would skip the duplicate. |
| | | | | | | | Improvement (owner: isolation): the parent's `/health` answers 200 with `engine.state` while the engine is exhausted; a distinct status for load balancers is a policy decision. |
| | | | | | | | Improvement (owner: isolation): the hub panel's serve action still answers `restart_required`; under `--isolate` it could switch live by routing an exact id through the pool. |
| | | | | | | | Improvement (owner: isolation): the pool remembers exact-id misses until a download or job invalidates the library, so a model fetched from another shell is not routable until then. |
| Speculative decoding: draft models, n-gram, MTP, DSpark/DFlash | done (`generation/speculative`, MTP models and state) | partial (draft slot in the host; grouped draft required; ungrouped shapes report the typed capability error) | rides completions | done (`--draft-model`, `--draft-kind`, `--num-draft-tokens`, `--ngram-*`, `--mtp`; `--preload` is a Whisper flag, tracked in the audio row) | n/a | partial (opt-in ngram prompt-lookup run on MiniCPM with telemetry and exactness; B1 main/new preservation passed in review for Gemma4 two-model and Qwen3.8 Trellis MTP, with accepted and rejected proposals and continuation after rejection) | Verify the other main-supported provider/target/cache combinations with the seven existing grouped providers, HTTP, and grouped (B>1) coverage, then performance measurements |
| Paged KV | done (`kernels/attention/paged`, `state/paged`) | partial (Gemma4 only; others report the typed error; media and adapter rows bypass paging as in main, and adapter rows take generation checkpoints as main's `--batch 1` did) | rides completions | done (`--paged-kv`, `--paged-kv-block-size`, env mirror) | n/a | partial (opt-in Gemma4 paged completion and the non-Gemma4 typed error; in review, main/new Gemma4 12B gathered plain paging matched plain shared execution in full sampled vocabulary vectors at B1/B3, blocks 16 and 256) | The direct paged kernel, encoded caches, KV-plane identity and HTTP cancellation remain outside that run; broader model support and cache ownership are tracked in Improvements identified during migration |
| Serial-only request shapes: Gemma2 advanced compositions (plain KV, grammar, adapter and plain-KV fill requests now batch; direct grammar forced spans preserve main through the shared scheduler ([qualified Gemma2 scope](packages/inference/README.md#scheduler-continuation-and-specialized-path-checks)), fill also inside an adapter context, and plain-KV requests take shared generation continuation checkpoints and two-model and n-gram speculation; encoded KV (TurboQuant is admitted for ordinary decoding through dense-read certification; bounded paired real-weight ordinary/continuation and forced-grammar qualification is linked in the inference README; supplied fill decodes ordinarily, as in main; direct grammar spans include delayed-prefix reuse, cancellation and scheduler recovery, with interleaved B1 graph calls rather than stacked B2 grammar qualification; delayed affine KV's direct grammar jump commits spans while a row reads plain and refuses that row before an unreadable append; real-weight Gemma2-2B B1 check in the inference README), draft providers whose rows tap target hidden layers (the graph has no tap operation), and paging remain; Gemma2 adapter requests with a two-model or n-gram draft now select ordinary continuous decoding and ignore both draft and fill, as main did; paired B1 greedy acceptance with a synthetic nonzero adapter on Gemma2-2B passed against main (full logits and valid KV, either draft, fill/logprobs off and on, zero draft/fill use, physical-unmount restoration); multi-row adapter/draft requests remain unqualified; adapter-free two-model and n-gram drafts now ignore supplied strict/verify/echo fill, while logprobs select ordinary decoding and ignore both, as main did; paired B1 greedy Gemma2-2B acceptance matched main and fill-off controls in full logits, valid KV, proposals, continuing commits, output and logprobs with zero fill use; candidate terminal commits have verified-prefix checks only, and B>1 remains unqualified), sliding-attention Universal descriptors (admitted through their bound cache operations and per-group masks; gateway and direct execution matched at B1 and B2 on a custom Llama-3.2-3B window-8 graph), media without batched input, non-batchable quantized and Turbo KV (delayed affine KV batches for ordinary decoding on MiniCPM5 and on universal graphs whose bound attention reads encoded KV and whose layers all convert, plain or rotating (on a custom Llama-3.2-3B window-8 graph, rotating layers matched main's serial path at B1, gateway matched direct execution at B1 and B2, and fresh-process continuation passed; a single adopted rotating row keeps its physical ring order, which Gemma4 e4b shared state also matched; a restored wrapped ring's continuation can differ from the live one, in main as well); genuine delayed speculation remains excluded; their direct grammar jump commits spans (real-weight B1 check in the inference README); Qwen3 and Qwen3-MoE attend affine KV and take the same path (real-weight Qwen3-4B checks in the inference README; Qwen3-MoE not run on real weights); supplied fill falls back to ordinary decoding as on main and keeps checkpoints ineligible ([bounded paired qualification](packages/inference/README.md#scheduler-continuation-and-specialized-path-checks)); both take eligible generation checkpoints over delayed KV; adapter requests with a configured draft preserve main's ordinary fallback (ignoring draft/fill, preserving requested logprobs and retaining eligible no-fill checkpoints); paired B1 acceptance on cached Qwen2.5-0.5B and MiniCPM5-1B passed six scenarios per model over 16 generated tokens, each paired with a draftless adapter control (TwoModel/Ngram, uniform KV4/KV8/partial mixed KV, full logits and all valid cache planes, zero request-time draft/fill use after normal startup probes, nonzero adapter/unmount controls, plain/encoded retained checkpoints and graceful-abort fresh-process continuation; not every combination or multi-row configured-draft requests), and universal delayed-affine adapters without a configured draft use the ordinary context and continuation path; paired B1 Qwen2.5-0.5B greedy/seeded acceptance passed for uniform KV4/KV8 and partial mixed KV before/after conversion (full logits and all valid cache planes, nonzero adapter/unmount controls, durable fresh-process continuation); separate candidate B2/B4 tests without a configured draft passed joins, cancellation, queued adapter/base isolation and reuse after drain) | done (models exist, incl. `universal`) | typed `UnsupportedExecutionError` per shape | 501 envelope | `generate` prints the error, exit 1 | n/a | per shape, when supported | Shared-scheduler support per shape (to support, not dropped); resolve `--fused-sdpa`, `--l1`/`--l2`/`--l3` with layer policy. `--kv-quant turbo[:k<bits>v<bits>]` (main's parser; `turbo` is k8v3) reaches the cache services in `serve`, isolated workers and `generate`, with the existing Turbo batch and paging refusals unchanged; in review, Qwen3.5-0.8B `turbo` and `turbo:k8v4` passed through the CLI and direct and isolated HTTP (actual codec use, streams, disconnect, recovery, exact greedy output); Gemma4 TurboQuant and full-logit qualification beyond the linked Gemma2 scope remain open |
| DiffusionGemma denoising (shared execution) | done (`generation/diffusion`: request-local MLX key sequence on every path; `execution/denoising-group`: interleaved rows, one bounded unit per row per iteration, B=1 graph calls, one shared dequantized embedding table, per-unit adapter scope) | done (placed continuously; grammar, draft, logprobs, logits processors, fill, encoded and paged KV refused with typed reasons; main silently ignored the token-level ones) | rides completions | rides `generate` | n/a | partial (model-free native and CPU tests pass; the opt-in real-weight test passed against main 02d723a's measured `denoiseSync` trajectories for main's two golden prompts on MLX 0.32.2, B1 direct and grouped plus B2/B4 join and cancel; main's own `goldens/diffusion/gen*.json` no longer match main itself on MLX 0.32.2; with an image, the opt-in test passed in review against main 02d723a's measured reference for its `goldens/diffusion/vision.json` input (direct tokens, steps and finish; grouped B1 tokens; an image row interleaved with a text row, each equal to its solo run), and an HTTP text, image, text sequence matched main's text, finish, usage, prefill pixel bytes and IDs; main's image tokens and finish equal that golden but take 3 steps where it records 4; the real-weight direct-group test also passed cancellation after an image decoder unit with two active rows and a text survivor that had already advanced, no published tokens from the cancelled row, exact survivor output and same-group image/text reuse; state and shared-table disposal calls and caller-owned pixel lifetime were checked, not allocator leak freedom; paired B1 HTTP image disconnect, drain and same-server image/text recovery passed against main; see [inference acceptance](packages/inference/README.md#optional-execution-and-persistence)) | Image requests (one image, as in main) are admitted: their pixels ride the request options (`visionPixels`, which `denoisingRequestOptions` passes to the row's prefill) with `hasVision` false as in main, and the gateway releases them exactly once after reservation, whether the row settles or fails before submission (CPU ownership tests). Stacked (B>1) canvases and token-chunked prefill are separate optimizations; the full prompt prefill stays one unit. Improvement (owner: app capability reporting): `/v1/models` reports DiffusionGemma with `vision: false`, on main and here, although image requests succeed. |
| Evaluation and benchmarking: `bench`, `evals`, `perplexity`, EvalDB, eval tasks | n/a (experiments; the in-package bench harness moves out) | n/a | `/fit` measured fields stay null | not app verbs | status page shows dashes | n/a | Runs outside this repository, consuming the published packages and driving the app through its public HTTP and CLI surface; results are published as datasets or quoted as text in docs |
| Dataset `verified_code` execution | n/a | 501 at submit; template visible as unavailable | 501 | n/a | done | n/a | An owned sandboxed executor; main's `spawnSync` of generated Python is not to be ported |
| Pi terminal: `pi`, `harness pi` | n/a | chat backend reusable | n/a | held (`pi-terminal`, `harness-pi` not ported) | n/a | n/a | Held by Josh |
| Embedding API: `mlx-bun/client`, `mlx-bun/engine`, `mlx-bun/selection`, `mlx-bun/server`, and `mlx-bun/package.json` (`createCompletionClient`, `createDirectHost`, `openIsolatedHost`; main's pure selection helpers; main's in-process `createServer` and `loadContext`) | n/a | done (`mlx-bun/engine` adds `openIsolatedHost` on the private `__worker` app launch form; `mlx-bun/server` restores the server entry over the serve composition's `startContextHost`) | n/a | n/a | n/a | CPU tests over a fake worker and over a supplied binding, and packed consumer tests in the verifier; native acceptance passed: `tests/engine/library-host.test.ts` with real MiniCPM and Whisper weights, including the compiled CLI (#145), and `tests/engine/in-process-server.test.ts` on MiniCPM5-1B (caller binding and prompt builder, Pi ready, close deadline with abort and drain, borrowed-context reuse), run by the author and independently in review | None: main's `initializeMlx` and native bootstrap were removed deliberately with the bundled native runtime, and no root (`.`) namespace or no-op API is recreated; migration uses owner imports (app README) |
| Existing-user data compatibility: prior-format sessions, jobs, settings, vault, caches; memory Reference symlinks that point into the main checkout | n/a | partial (Pi sessions, browser preferences and active jobs read across versions; no migration code needed so far) | n/a | n/a | n/a | partial: a CPU harness wrote and appended Pi sessions (SDK 0.80.3, session v3) old to new and back, keeping trees, labels, compaction, custom metadata, history, search, export and forks (30 assertions); browser preferences round-trip in both directions through the actual UI modules and HTML (132 assertions); active-job prior-schema recovery is covered by `tests/jobs/lifecycle.test.ts`; all on synthetic data with an isolated HOME, no real-session inference; a metadata-only audit of the real data found 7 valid auto-seeded memory Reference symlinks into the main checkout, 2 already-broken custom links and no nightly plist | Before deleting the old checkout, Josh selects what to preserve outside it (the Reference symlink targets; ignored adapters, checkpoints and other local artifacts, which Git history cannot recover); no automatic retargeting or docs restoration. Diagnosis and migration that preserve user edits, with prior-format inputs generated in-test (no fixtures committed); acceptance on an isolated copy of real user data; before deleting the old checkout, inventory and preserve user-selected ignored adapters/checkpoints and other local artifacts outside it, because Git history cannot recover ignored files |
| Docs surface and gates | n/a | n/a | HTTP and configuration inventories generated from source | CLI inventory generated from source | site and legacy redirects implemented | `apps/website/tests/server-api.test.ts`, `apps/website/tests/server-config.test.ts` | Per ARCHITECTURE: generate inventories from source as build-only output with a coverage gate, and write the explanations by hand (models, environment, training, memory, distribution, troubleshooting; quotable numbers as text with provenance in a benchmarks page). No STATUS file, docs map, or ledgers are restored. |
| Installation and release | n/a | n/a | n/a | bundle, launchers, safe installer, formula and staged release preparation implemented | n/a | n/a | Complete the release acceptance checks below; public installer delivery must follow a compatible bundle release; prior-data compatibility. No actual release. |

## Release acceptance

- [ ] Finish GitHub/npm publication and tap synchronization with explicit package
  versions/private decisions and clean-source checks. Verify the intended Git tag
  and registry versions before publication, and require release notes for the
  release body. Actual publication requires Josh's release instruction.
- [ ] With Josh's release instruction, verify real Developer ID signing and
  notarization, including loading the signed native libraries from a relocated
  signed bundle. The native-blocked version check and mocked commands do not
  establish this acceptance.
- [ ] Reproduce the remaining notices of code embedded in prebundled dependencies.
  `babel-plugin-parameter-decorator@1.0.16` in Jiti's prebundle has no license text
  upstream: only its manifest's `"license": "MIT"` and `"author": "Warner"`, its npm
  `gitHead` is not in its repository, and no commit there adds a license file, so a
  full text must come from its author. The toolchain that built XGrammar's WASM is
  unknown (no producers section; a local build): the inference notice reproduces
  Emscripten 3.1.56's texts because the runtime glue is a release-era match for 3.1.56,
  inferred from two fingerprints (WebAssembly-check absence and `Module["ready"]`
  presence), not exact provenance. Whether the stripped WASM links LLVM compiler-rt is
  also unknown; if it does, its notice needs that Emscripten's
  `system/lib/compiler-rt/LICENSE.TXT`.
- [ ] Make partial signing retryable without weakening bundle integrity checks
  before the first real signed release. This is an operational improvement:
  today a partial signing failure safely requires rebuilding a fresh preparation.

## Completion

- [ ] Clear all three transition gates above and review their results with
  Josh before transitioning. Preserve main's exact final commit in a pushed
  reference branch (`pre-monorepo`), merge `refactor/monorepo` into main with
  a merge commit preserving both histories, verify the merged result, then
  remove the redundant refactor branch and worktrees. Main remains reference-only
  until this transition; publishing is a separate authorization.
- [ ] Josh could delete main without losing a capability it shipped.
  Exit: every row above is all-done or carries a recorded decision and is deleted;
  the verify items above close against pinned published goldens or are recorded
  decisions; main's user flows (CLI verbs, HTTP protocols, web chat, jobs,
  installed and compiled artifacts, existing user data) are accepted with real
  weights; documentation follows ARCHITECTURE (generated inventories, handwritten
  explanations, no ledgers); no capability main shipped is retired silently.
