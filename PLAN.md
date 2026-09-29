# Refactor plan

Open work only; delete a block when its exit criteria are met. Josh has authorized the library and application migration through a first full
draft; keep changes focused and reviewed. Standalone Pi integration is deferred. Ownership and documentation rules live in [ARCHITECTURE.md](ARCHITECTURE.md).

Decisions that govern all work:

- One engine: the continuous batching scheduler. A single request is a batch of one; there is no second one-at-a-time engine or fallback path. A shape the scheduler cannot run yet gets a typed error.
- Main is reference-only, not an oracle to reproduce: an improvement over main is fine when bit parity (where the numerical contract requires it), performance and test gates hold.
- mlx-bun is a drop-in superset of mlx-lm: the `mlx-bun.<cmd>` aliases accept mlx-lm arguments (landed in #241; the flags they refuse are listed in the
  [app README](apps/mlx-bun/README.md#mlx-lm-compatibility-mlx-buncmd)).

## Verify the migrated library

- [ ] Establish real-weight parity for Qwen Trellis and Gemma, and extend MiniCPM
  beyond the [verified basic decode path](packages/inference/README.md#external-parity-evidence),
  against the applicable external oracle and main: logits, state continuation and
  specialized paths under identical artifacts and settings. Python environments and
  generated references stay outside the repository; reusable runners are in Git
  ([runtime comparison](packages/inference/README.md#repeatable-runtime-comparison)).
  Exit: opt-in comparisons meet the numerical contracts against pinned published
  golden revisions recording source revisions and oracle versions; synthetic tests
  alone do not close this. Done so far: the
  [generated Gemma4 graph test](packages/inference/tests/parity/gemma4-generated.test.ts)
  passed on e4b and 12B (identity within this tree; 26B-A4B not run). Open: no
  [runtime-oracle](packages/inference/tests/parity/runtime-oracle.test.ts) reference
  exists yet for Trellis, Gemma or MiniCPM (MiniCPM mixed KV waits on the next item);
  real Gemma2 B2 rows and a different prefill chunk geometry differ from main's B1 in
  logits and valid KV, which needs same-shaped oracle or main comparisons, not a tolerance.
- [ ] Extend speech and embedding evidence. Whisper large-v3-turbo, Silero VAD and
  Qwen3-Embedding-4B-4bit-DWQ match the external oracle and main bit for bit (Whisper fast
  path within main's two-token bound; VAD within 5e-3 of torch) on the
  [opt-in comparisons](packages/inference/README.md#speech-and-embedding-parity). Open: other
  Whisper sizes and non-WAV input, other embedding checkpoints, batched embedding, and
  performance. GLM-5.2 (declared L1) has no local weights and no current numerics evidence, so
  its graph, streamed experts and MTP are unverified against the oracle or main.
- [ ] Confirm the long-term mixed-KV reference contract for single-query decode:
  the documented stock mlx-lm path or OptiQ serve's fused default. The opt-in
  state comparison verifies the existing composition; keep that implementation
  unchanged during this refactor and do not imply blanket OptiQ serve compatibility.
- [ ] Extend training preservation. MiniCPM5 SFT, ORPO and DPO match main exactly
  through the app's [fine-tune preservation test](apps/mlx-bun/tests/engine/finetune-preservation.test.ts),
  as do short Gemma4 e4b SFT pairs and Qwen3.5-0.8B SFT with one LoRA layer (main trains
  Qwen3.5 only when no DeltaNet layer is on the gradient path; here the DeltaNet recurrence
  has a backward, so more layers, DPO and batches train with no main reference);
  DiffusionGemma save, reload and seeded
  generation and its HTTP adapter serving are consistent within this tree (not parity).
  Open: other model families and main-only paths (by_bits/by_kl, warm start); synthetic
  native tests do not close this.

## Three gates before replacing main

Finish the remaining implementation first, then run these on the assembled
candidate before saving main to a reference branch and merging
`refactor/monorepo` into main. Inventory main's existing benchmark and
evaluation suites rather than substituting a smaller smoke suite. Pin both source
revisions and retain reproducible commands and results outside Git; reusable
verification code stays in Git. Focused PR checks do not close these gates, and the
full applicable numerical parity suites remain required too.

- [ ] **Intelligence benchmarks.** Run the full existing evaluation suite, including
  GSM8K and the other benchmarks main provides, against main and the candidate with
  matched artifacts, dataset revisions and splits, prompts/templates, scoring, sampling,
  seeds and limits. Report per-benchmark scores and failed or skipped evaluations;
  resolve regressions before accepting. A smoke run or subset does not close the gate.
  Runner: `bun scripts/eval-serve.ts --help` (the gate has not run against real servers).
  Open: main's `*_optiq_frozen` datasets exist only on one machine and need
  publishing as an external dataset revision; HumanEval needs #223's Docker image.
- [ ] **Head-to-head performance.** Run the full H2H suite (`bun scripts/bench-serve.ts`)
  on one quiet machine with the same artifacts, inputs, configuration and execution
  shapes, single-request and batched. Exit: decode, prefill, complete-request time and
  memory match main in paired measurements; regressions are traced and fixed, with
  affected parity and benchmarks rerun.
- [ ] **Full capability gap analysis and acceptance.** Inventory what main exposes
  (library APIs, CLI verbs/options, HTTP protocols and streaming, web workflows, jobs,
  model/cache/generation capabilities, isolation/pooling, install/build artifacts,
  existing user data) and exercise its equivalent in the candidate. Trace each to
  passing acceptance evidence or Josh's explicit decision to change or defer it; a
  route's presence, synthetic test, skipped test or 501 placeholder is not proof.
  Resolve unapproved gaps and rerun affected flows without reproducing main's bugs
  or accidental composition restrictions.

## Improvements identified during migration

Concrete improvements with the current limitation and the owning domain. Preserve
shipped behavior first; an improvement is not permission to redesign during migration.
Migration gaps stay required work in the feature table.

- [ ] Generalize paged KV across supported models that use KV attention (Josh's target).
  Main's app restricted paging to Gemma4 and the shared execution binding has the same
  family restriction (other families get the typed error). Cache storage, allocation,
  row operations, snapshots and lifecycle belong to `packages/inference/src/state/`
  (`state/paged/`); graphs supply attention/cache bindings through lower-level contracts,
  kernels stay in `kernels/`, execution owns scheduling; extend those seams, no model
  switches in the cache. Check mixed recurrent/KV models explicitly. Exit: supported KV
  attention paths use the cache contract with real-model numerical, continuation,
  cancellation and batched-execution coverage. No new package now.
- [ ] (audio) `transcribe --vad-trim` is accepted but not applied, as in main, though the
  service implements `vad.trim`.
- [ ] (memory) The entity seed gold is personal data read from a repository path; seed from
  the vault's aliases (`EntityResolver.fromStore`) and drop the file.
- [ ] (memory) `--since` and `--model` are parsed and never consumed (main reserved them
  too); consuming them is a decision.
- [ ] (isolation) The worker's `/health` reports only `ready`/`draining` because the socket
  binds after the model loads; a pre-bind stub would let the parent observe `loading`.
- [ ] (isolation) Pi's SDK retries a 502 refused before generation (three attempts, 2/4/8 s)
  without a browser frame; mapping `auto_retry_start` to a frame would show the wait.
- [ ] (isolation) The worker keeps its own bounded Responses store for requests the parent
  already records; honoring `x-mlx-bun-response-owner: parent` would skip the duplicate.
- [ ] (isolation) The parent's `/health` answers 200 while the engine is exhausted; a distinct
  status for load balancers is a policy decision.
- [ ] (isolation) The hub panel's serve action answers `restart_required`; under `--isolate` it
  could switch live by routing an exact id through the pool.
- [ ] (isolation) The pool remembers exact-id misses until a download or job invalidates the
  library, so a model fetched from another shell is not routable until then.
- [ ] (capability reporting) `/v1/models` reports DiffusionGemma with `vision: false` (as main)
  though image requests succeed.

## Migrate the application

- [ ] Migrate the server, engine host, web app, and job orchestration into `apps/mlx-bun`,
  keeping their interfaces in the consuming domains. Exit: app consumers use public library
  APIs; application contracts and policy stay out of the inference library. Remaining:
  `input/media-fetch.ts` names the app's `--allow-private-media`, and
  `scripts/{bundle-files,build-binary,verify-binary}.ts` and
  `apps/mlx-bun/tests/compiled-consumer.ts` import non-exported `packages/mlx/src/native`.
- [ ] Support the shapes under [Unsupported request shapes](#unsupported-request-shapes) as
  capabilities of the graphs that lack them. Exit: each runs on the shared scheduler, verified
  with real weights and cancellation/streaming coverage.
- [ ] Preserve continuous batching as the serving default, including single requests. Keep
  compilation choices inside graph layers, without compilation switches on the app surface.
  Exit: the full draft preserves the cancellation/streaming contracts and, where the contract
  requires it, main's behavior, before the performance pass.

## Split the app into modules

- [ ] Split `apps/mlx-bun` into modules on core services, as the repository split into apps and
  libraries (design: [Modular application](ARCHITECTURE.md#modular-application); contracts:
  `packages/app-core`). Modules: transcription, chat, models, train, quantize, datasets, memory,
  benchmarks (answer quality, `scripts/eval-serve.ts`), metrics and performance (live tokens/s, TTFT,
  batch occupancy, queue, KV/prefix usage and hit rate, memory per loaded model, swap and load
  times; launching `bench-serve` profiles with history). An agentic workflow engine is a later module,
  not planned here. Every step keeps existing paths, verbs and behavior: moved tests keep their
  expectations, and steps that move an execution path rerun real weights before and after.
  - [ ] (c) `events` service and the metrics and performance module. The model host and a scheduler
    adapter publish; inference gains no dependency on the bus. Exit: every metric named above is
    published and rendered from a recorded event stream in a test; a `bench-serve` profile launches
    through jobs and keeps history; on a named machine, paired runs show no throughput loss from
    publishing and the panel's numbers match `/stats` and the run's own output.
  - [ ] (d) Remaining modules, one PR each: models, datasets, quantize, train, benchmarks, chat, memory
    (last, moved as is: the memory feature stays deferred). Modules contribute to each other through the
    `registry` service (memory tools into chat); chat's PR adds its consumer and takes over the browser's
    hold-to-talk mic (`web/browser/voice.ts`) into transcription's panel. Hosts serve module sockets and job
    runners when the first module that declares them lands (they refuse them until then). Exit per module: its
    domain leaves `apps/mlx-bun/src`, the app's domain map shrinks accordingly, and served-surface
    inventories are unchanged.
  - [ ] (e) Model host residency and swapping. Today swapping needs `--isolate` (one worker per
    model), and the pool's spawn-overlap loads the new model while the old ones stay resident, so two
    models can be resident past any budget. Implement the `modelHost` contract: memory-fit residency,
    drain then flush per-model KV/prefix state to `MLX_BUN_HOME` and resume it on return (reusing the
    SSD cache tier), pinned companions (Whisper's `resident`/idle-unload setting becomes the pinned
    role). `--isolate` stays crash isolation, decoupled from swapping; decide `--model-pool`'s meaning
    then. Exit: swap between two models without `--isolate` never exceeds the budget (resident bytes
    from events), the returning model resumes its state (prefix hit), a pinned companion survives
    swaps, and a request for a non-resident model waits instead of thrashing; verified with real
    weights (MiniCPM5-1B and Qwen3.5-0.8B, Whisper as companion).

## Remaining features by layer

One row per feature, one column per layer it crosses. A feature closes only when every cell is
done or a decision marks it dropped; delete the row then. Cells: `done` · `partial` · `missing` ·
`501` (route stubbed) · `n/a` · `held`. Evidence means an opt-in real-weight test that passes against
a pinned published golden or regenerates it; synthetic tests never fill it. This repository carries
code, tests and documentation; goldens, records and benchmark data are published datasets, and
experiments and benchmarks live outside it. Package READMEs hold the evidence detail; keep cells short.

| Feature | Library | Engine / host | Server | CLI | Web | Evidence | Open work or decision |
|---|---|---|---|---|---|---|---|
| Audio: Whisper transcription, Gemma4 audio input, voice sessions | done | done (lazy Whisper companion, exclusive-lock takes) | done (`/v1/audio/*`, `/admin/transcription/unload`, served by `@mlx-bun/module-transcription`) | done (`transcribe`, `dictate` from the module; `--whisper-*` on serve; `apps/transcribe` hosts the module alone) | done (hold-to-talk composer dictation; no upload or translate controls, as main) | partial: Whisper large-v3-turbo and Silero VAD match the external oracle and main ([speech parity](packages/inference/README.md#speech-and-embedding-parity)); Gemma4 e4b audio-only HTTP (B1/B2) matches main; real-weight voice, companion and mixed-media consumers pass; [details](packages/module-transcription/README.md#audio-transcription) | Open: physical-microphone `dictate` (mic, key tap, clipboard, typing); Gemma4 audio with KV quantization and other variants; main parity for mixed image+audio and e2b (app-behavior runs only); Gemma4 audio external-oracle parity; other Whisper checkpoints; performance |
| Memory synthesis (nightly pipeline) | n/a (app-owned; pipeline ported op-for-op) | done (task model on the continuous gateway under the engine's execution lease; `--isolate`: default worker's `/admin/memory/complete`) | done (`GET /v1/memory/synthesize`, `schedule` in `/api/memory/status`) | done (`memory` verbs incl. `init`/`setup`, `schedule`) | read panel done; no synthesize control (as main) | partial: stages match main token for token and in full logits, width-3 batch, `--isolate` synthesis; [details](apps/mlx-bun/README.md#memory-synthesis) | Decision: the memory feature is incomplete and deferred; the ingest source is unchanged (Pi's global sessions directory, as main) |
| Live model switching, isolation, model pool | n/a | done (worker mode, parent proxy, exact-id LRU pool) | done (worker socket: `/health`, `/admin/lease`, `/admin/drain`, `/admin/memory/complete`; `--isolate` parent: `/engine`, `/health`, `/stats`, routing) | done (`--isolate`, `--model-pool`) | hub panel done | partial: `--isolate` (MiniCPM5-1B) and `--model-pool` (MiniCPM5-1B, Qwen3.5-0.8B) lifecycle in CLI and browser (#133, #134); no performance or oracle parity; [details](apps/mlx-bun/README.md#runtime-isolation---isolate) | Decisions (Josh): isolation and pooling stay optional, off by default, pool cap 1, and web chat works under isolation. Residency by memory fit replaces the pool's spawn-overlap under [Split the app into modules](#split-the-app-into-modules) (e). Internal worker routes on TCP (`/admin/lease`, `/admin/drain`, `/admin/memory/complete`) and `/engine` outside `--isolate` answer 404, not 501. Small items: Improvements |
| Speculative decoding: draft models, n-gram, MTP, DSpark/DFlash | done | partial (grouped draft required; ungrouped shapes get the typed error) | rides completions | done (`--draft-model`, `--draft-kind`, `--num-draft-tokens`, `--ngram-*`, `--mtp`; `draft regen|train|calibrate|quantize` produce drafters) | n/a | partial: B1 main preservation for n-gram (MiniCPM), Gemma4 two-model and Qwen3.8 Trellis MTP; [grouped consumer](packages/inference/README.md#speculative-generation) ran for n-gram, two-model and assistant | Open: the grouped consumer for MTP, DSpark, DeepSpec (no local drafts fit 32 GB) and GLM-5.2 native MTP (no local weights); other main-supported provider/target/cache combinations; equality with main or an oracle; HTTP; performance |
| Paged KV | done | partial (Gemma4 only; others get the typed error; media and adapter rows bypass paging) | rides completions | done (`--paged-kv`, `--paged-kv-block-size`) | n/a | done for Gemma4 E4B/12B: gathered pages equal plain KV bit for bit, direct reader within tolerance, KV4/KV8 pages, HTTP cancellation per reader, cold prefill; [details](packages/inference/README.md#state-and-attention) | Open: warm-prefix (prompt cache on) identity over HTTP (main's `paged-cache-http` test is not ported); broader model support under Improvements |
| Unsupported request shapes (typed error) | done | typed `UnsupportedExecutionError` per shape | typed 501 envelope | `generate` prints it, exit 1 | n/a | per shape once supported | Shapes to support and their decisions: [list below](#unsupported-request-shapes) |
| DiffusionGemma denoising (shared execution) | done (interleaved rows, B=1 graph calls) | done (placed continuously; grammar, draft, logprobs, logits processors, fill, encoded and paged KV refused with typed reasons) | rides completions | rides `generate` | n/a | partial: text and one-image requests match main's measured trajectories (direct, grouped, B2/B4 join and cancel, HTTP), image cancellation and disconnect recovery pass; [details](packages/inference/README.md#optional-execution-and-persistence) | Open: stacked (B>1) canvases and token-chunked prefill (separate optimizations); concurrent HTTP rows, full logits and KV planes, external-oracle parity, performance. Main's `goldens/diffusion/gen*.json` no longer match main on MLX 0.32.2, so references are measured |
| Evaluation and benchmarking: `bench`, `evals`, `perplexity`, EvalDB, eval tasks | n/a (experiments; the in-package bench harness moves out) | n/a | `/fit` measured fields stay null | not app verbs | status page shows dashes | n/a | Runs consume the published packages and drive the app through its public HTTP and CLI surface; results are published as datasets or quoted as text in docs. The benchmarks and metrics modules ([split](#split-the-app-into-modules)) launch these runners and show history; they add no second runner |
| Pi terminal: `pi`, `harness pi` | n/a | chat backend reusable | n/a | held (`pi-terminal`, `harness-pi` not ported) | n/a | n/a | Held by Josh |
| Managed jobs: quantize, fine-tune, `convert`, `fuse`, datasets | n/a | done (each job child leads its own process group; stop is SIGTERM then SIGKILL after 3 s; the child stops its group when the parent's stdin pipe closes) | done (job, dataset and adapter routes) | done (`train`, `convert`, `fuse`) | job views done | partial: finished and merged fine-tune adapters mount, unmount and reproduce in a fresh process, and `fuse` output loads and generates (MiniCPM5-1B, opt-in `managed-jobs.test.ts`); [details](apps/mlx-bun/README.md#jobs-quantization-and-fine-tuning) | Decision: a managed job keeps running when its terminal closes (quantize's synchronous sensitivity sweep cannot observe the closed pipe): accepted. Open: the opt-in tests #224 changed without running them are still unrun in part: the rest of `managed-jobs.test.ts`, the memory-synthesis case of `isolate.test.ts`, `memory-native.test.ts` and the standalone-build case of `library-host.test.ts` (its other cases and the `--isolate` case passed on MiniCPM5-1B); also `bun run verify:binary` (compiled `__worker`, `__job` success, Pi session; #225) |
| Existing-user data compatibility: prior-format sessions, jobs, settings, vault, caches; memory Reference symlinks into the main checkout | n/a | partial (Pi sessions, browser preferences and active-job prior schemas read across versions; the web chat sidebar lists every recorded chat; old `~/.cache/mlx-bun*` job history, memory and registry data are left in place, not migrated; adapter stores are listed read-only) | n/a | n/a | n/a | partial: synthetic old/new round trips (Pi sessions, preferences, jobs) and an acceptance on an isolated copy of real data pass (53 sessions, 10 adapters); the credential and schedule paths only synthetically (no saved token or nightly plist in the real data) | Decisions: everything mlx-bun writes by default lives under `MLX_BUN_HOME` (`~/.mlx-bun`); the HF hub cache holds downloads only; explicit paths win (#224); the opt-in `--expert-offload` still builds inside the model directory. Before deleting the old checkout Josh selects what to preserve outside it: the memory Reference symlink targets (7 point into it; 2 already dangle) and ignored adapters, checkpoints and other local artifacts that Git cannot recover. No automatic retargeting. Open: opening a chat appends SDK entries and opening a v1/v2 chat rewrites it, as in main |
| Docs surface and gates | n/a | n/a | HTTP and configuration inventories generated from source | CLI inventory generated from source | site and legacy redirects implemented | `apps/website/tests/server-api.test.ts`, `apps/website/tests/server-config.test.ts` | Per ARCHITECTURE: generate inventories from source as build-only output with a coverage gate, and write the explanations by hand (models, environment, training, memory, distribution, troubleshooting; quotable numbers as text with provenance in a benchmarks page). No STATUS file, docs map, or ledgers are restored. |
| Installation and release | n/a | n/a | n/a | bundle, launchers, safe installer, formula and staged release preparation implemented | n/a | n/a | Complete the release acceptance checks below; public installer delivery must follow a compatible bundle release. Decision: the installer links only `~/.local/bin` (accepted). No actual release. |

### Unsupported request shapes

Refused with a typed error today (`execution/plan.ts`):

- Delayed affine KV with a draft that would speculate.
- Draft providers that tap target hidden layers on Gemma2 (softcap) graphs: the graph has no tap
  operation.
- Paged KV on graphs other than Gemma4 (as in main; broader paging is under Improvements).
- A KV scheme the model's cache cannot read (refused at startup).

Runs, not yet verified on real weights (evidence so far is in the
[inference README](packages/inference/README.md#scheduler-continuation-and-specialized-path-checks)):
multi-row adapter/draft requests; B>1 adapter-free draft or fill requests and stacked-B2 grammar
over encoded KV on Gemma2; a published sliding-window model (evidence is a custom window-8
Llama-3.2-3B graph), including speculation and encoded paths there; Qwen3-MoE affine KV; Gemma4
TurboQuant beyond the Gemma2 scope.

Decided: adapter rows whose draft cannot serve adapters decode ordinarily and keep generation
checkpoints on every graph; on rotating-cache graphs a grammar jump keeps verified proposals and
supplied fill is applied; sliding graphs speculate for adapter+n-gram, encoded KV+draft and
logprobs+draft rows.

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

## Ideas and research

One line per idea: the question and the domains it touches. Picking one up makes it an item
above with an exit; an answered one moves its finding to the owning documentation and is deleted.

- **SkillOpt skill optimization** (chat, memory, a new optimization domain; [research](https://github.com/joshuarossi/mlx-bun/pull/247)):
  can SkillOpt's gated skill-edit loop (Microsoft, MIT, arXiv:2605.23904) improve the default
  assistant's prompt and skills and the memory stages' `Meta` policies with local models as target
  and optimizer, and should the loop run inside mlx-bun? First experiment: a `scripts/` runner using
  SkillOpt's `openai_compatible` backend against `mlx-bun serve` on one verifier-scored task set,
  measuring the optimizer's edit-JSON parse rate and the held-out gain with a 4B–27B optimizer.
