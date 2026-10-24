# Refactor plan

Open work only; delete a block when its exit criteria are met. Josh has authorized the library and application migration through a first full
draft; keep changes focused and reviewed. Standalone Pi integration is deferred. Ownership and documentation rules live in [ARCHITECTURE.md](ARCHITECTURE.md).

Decisions that govern all work:

- One engine: the continuous batching scheduler. A single request is a batch of one; there is no second one-at-a-time engine or fallback path. A shape the scheduler cannot run yet gets a typed error.
- Main is reference-only, not an oracle to reproduce: an improvement over main is fine when bit parity (where the numerical contract requires it), performance and test gates hold.
- mlx-bun is a drop-in superset of mlx-lm: the `mlx-bun.<cmd>` aliases accept mlx-lm arguments (landed in #241; the flags they refuse are listed in the
  [app README](apps/mlx-bun/README.md#mlx-lm-compatibility-mlx-buncmd)).
- Refactor acceptance requires numerical parity, preserved functionality and no
  performance regressions. Knowledge benchmark scores characterize the candidate
  quant for its Hugging Face model card; that publication work has its own criteria.
- Legos compose at load. A graph never contains a fallback to another graph, the cache owns its read, and the
  scheduler calls named phases. The remaining graph-files acceptance and composition work are
  listed below.

## Graph files

- [ ] Resolve performance acceptance for the final `refactor/graph-files` merge request to
      `main`. Review the saved short paired reports, including slower decode and aggregate
      samples under the accepted current machine conditions. A quiet paired run is required
      before making performance claims; current-condition results cannot establish that gate.
      Josh decides when the merge request merges.

## Composition refactor

Landed on `refactor/composition` (PR #323 to `main`), 2026-10-10 to 2026-10-12. Every served
configuration is one composition resolved at load; the loader selects the graph from a table keyed
on the composition; the scheduler names the phase and the row count; the cache owns storage, the
read, prefix reuse, paging, SSD offload and eviction; drafters bind one selection operation;
every graph is a written arrangement selected at load and extends nothing; the architecture
gate holds the rules with an empty ratchet. The rules and the ownership live in
[ARCHITECTURE.md](ARCHITECTURE.md); the evidence per step is in the PR description, the merged
PRs' descriptions and this file's history; the gates are the written-file architecture rules, the
conformance suites, the identity tests against each family's generic graph, the recorded
synthetic digests, the real-weight parity suites, `packages/inference/scripts/digest.ts` and
`teacher-forced-kl.ts`, and the paired check in `.github/workflows/perf.yml`.

### Open

- [ ] A teacher-forced KL of a request decoded at four rows against the same request at one row
      on the M4 Pro composition, the number the bit-stability decision promised to record
      (`teacher-forced-kl.ts` over a four-row group needs a capture mode for batched rows).
- [ ] `scripts/bench-mtp.ts`'s KV option fails on its first drafted arm with "No target row
      layout for kv:bf16-first:kv:quant:4:64" (`serve --kv-quant 4` works); fix the bench tool
      and run the 4-bit sweep it was meant for.
- [ ] Gemma 2 on real weights once: the M1 Max's hub cache holds `gemma-2-2b-it-4bit`; run the
      opt-in native suite there (`MLX_BUN_GEMMA2_NATIVE=1`) and record the digests.
- [ ] Two guards unreachable by inspection, delete or keep with the reason:
      `packages/training/src/segmented.ts`'s quantized donor KV refusal (training caches hold
      plain KV) and the latent width checks (GLM-5.2's widths fit).
- [ ] Synthetic digests are recorded for `applegpu_g16s` and `applegpu_g13s`; the cases skip on
      any other host until recorded there (`scripts/synthetic-digests.ts record`).

Facts recorded for the program after the merge, not planned here: on the M1 Max a verify round
of two rows costs 1.77 plain decode steps and of eight rows 2.05 (1.30 and 1.94 on the M4 Pro);
that graph runs operations of nine to 256 rows on its wider layers and more on the generic
blocks, and one-sequence prompt pieces of 224 to 2048 positions on the Neural Engine split (mean
KL against the GPU alone 1.2e-4 to 1.9e-3), prefilling 1k- and 8k-token prompts at 207 and 213
tok/s (200 on the M4 Pro). With the gate settings the graph declares, DFlash 2 adaptive decodes
30.5 tok/s greedy, 28.5 under Qwen's instruct sampling and 24.5 under its thinking sampling
against plain decode's 19.5, 19.1 and 19.1, the MTP head 26.7, 24.8 and 22.4 (in-process serve,
192 tokens, eight prompts, sampled modes over three seeds); two and four concurrent greedy
requests decode 42.6 and 47.5 to 48.3 tok/s in aggregate with DFlash 2 against plain's 24.2 and
36.2. Open: on short creative text (35 to 80 tokens) both drafters still trail plain decode, by
up to 16% under instruct sampling and 3% greedy, in drafted rounds the text does not repay. The
paired check's band is narrower than session drift for sub-percent decode differences (the clean
M1 Max run is the null); the TurboQuant fused decode kernel covers head dimensions 64, 128, 256
and 512 and 96 decodes on the plain path.

The measurements of record before the merge. M1 Max (2026-10-12, clean machine, `perf.yml`):
Trellis default decode 14.1 → 14.0 tok/s (1.000 [0.995, 1.006]), e4b default 64.4 → 64.3 (0.998
[0.997, 1.000]), DFlash 2 main at depth 7 → head adaptive 3.8 → 12.1 tok/s. M4 Pro (2026-10-12,
rebooted, preflight clear before and after, main 9593d881 against 5fb5e380, the tree #323
merges): Trellis default decode 14.5 → 14.5 tok/s (1.001 [1.000, 1.002]), prefill of the 1k
prompt 175.1 → 176.6 (1.005 [0.999, 1.011]), cold TTFT 4326 → 4291 ms (0.995 [0.989, 1.001]);
e4b default decode 59.3 → 59.2 (0.999 [0.998, 1.000], which `perf-check.ts decide` flags as a
regression: a tenth of a percent, the same class as the M1 Max's 0.998), prefill and TTFT 1.000;
the ladder's DFlash 2 adaptive command over two alternating rounds: decode 30.5 / 31.4 → 31.5 /
31.3 tok/s, TTFT 169 / 167 → 173 / 168 ms, and the greedy text of five captured requests
identical to main's. Server ready time is about 100 ms longer than main's (1.54 against 1.44 s:
the Neural Engine programs load in 850 against 795 ms, the worker is ready 40 ms later); the
first request's TTFT is equal; a server's first start from a fresh checkout path costs about
500 ms more on either tree (a per-path cache), which is what the first candidate session of each
paired run showed. The clean M4 Pro exposed two regressions the dirty machine had hidden, both
fixed before the merge: the generated M4 Pro graph had stopped running one-sequence prompt pieces
of 640 to 2048 positions on the Neural Engine (#349: main's ranges are the composition's data,
the scheduler picks the operation by row count, which reverses C3's exact-chunk rule), and the
DFlash 2 drafter's context projections had lost main's 5..8-row simdgroup-matrix kernel rule,
which diverged the greedy text through the adaptive depth trajectory (#348); a sha bisection
could not see either, the captured texts could. The M1 Max paired check fails its preflight
while that machine is in use (swap above 512 MB).

## Verify the migrated library

- [ ] Establish real-weight parity for Qwen Trellis and Gemma, and extend MiniCPM
  beyond the [verified basic decode path](packages/inference/README.md#external-parity-evidence),
  against the applicable external oracle and main: logits, state continuation and
  every graph's paths under identical artifacts and settings. Python environments and
  generated references stay outside the repository; reusable runners are in Git
  ([runtime comparison](packages/inference/README.md#repeatable-runtime-comparison)).
  Exit: opt-in comparisons meet the numerical contracts against pinned published
  golden revisions recording source revisions and oracle versions; synthetic tests
  alone do not close this. Done so far: the
  [written Gemma4 graph test](packages/inference/tests/parity/gemma4-written.test.ts)
  passed on e4b and 12B (identity within this tree; 26B-A4B not run). Packed Trellis now matches main in 96 full greedy logit vectors, three shared
  B1/depth-two MTP runs (on the M1 Max, whose verify windows reassociate, by KL and greedy
  agreement), and the 18-case plain-KV runtime grid with restored
  continuation ([evidence](packages/inference/README.md#packed-qwen-trellis-parity)).
  Open: published references and broader Trellis shapes;
  [runtime-oracle](packages/inference/tests/parity/runtime-oracle.test.ts) references
  for Gemma and extended MiniCPM (MiniCPM mixed KV waits on the next item);
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

## Improvements identified during migration

Concrete improvements with the current limitation and the owning domain. Preserve
shipped behavior first; an improvement is not permission to redesign during migration.
Migration gaps stay required work in the feature table.

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
- [ ] (capability reporting) `/v1/models` reports DiffusionGemma with `vision: false` (as main)
  though image requests succeed.

## Text-to-image (MOSS-Image)

Library, family, quantizer, image host and `@mlx-bun/module-images` are implemented with
their evidence in the [inference README](packages/inference/README.md#text-to-image).
Open:

- [ ] Resolve every check that fails the original bounds (the review adjudicated
      only the last block's text rows). At `6e1d329a`, both Base and SFT fail trajectory
      steps 6 and 7, and the corrected spatial-token cosine also fails at step 5.
      All consumed DiT stage checks pass. The review's two
      experiments ran; the SITU and one-row projection fixes they led to, the earlier and
      newly introduced failures, the attention experiments and the measured
      sensitivity are in the [inference README](packages/inference/README.md#moss-image-comparison-acceptance-pending).
      Independent review accepted the evidence of sensitivity without accepting the
      remaining differences. The tiled MOSS attention kernel keeps bf16 softmax
      numerators without holding the scores. The single complete-pipeline image
      comparison is recorded; full-model acceptance across prompts and configurations
      and performance qualification remain open. Exit:
      each passes its bound. Record exact tensor mismatch counts separately;
      passing a tolerance is not bit parity. The official OpenMOSS engine remains
      the full-model reference; Python tooling stays external.
- [ ] Written graph files for one model on one machine (Base and SFT on the M4 Pro and
      M1 Max) once profiling chooses their bindings, with paired measurements on a quiet
      machine. Exit: the files and their numbers.
- [ ] Memory on 24 GB: every measured run completed while the machine swapped, and the
      near-constant 18.4 GB process footprint under staging is unexplained. Exit: an
      explanation and a quiet-machine measurement of process footprint, RSS and MLX peak.
- [ ] Shared image, voice and text serving is deferred. Add it through the loader's
      admission and graph bindings and the scheduler's execution contracts, preserving
      existing model paths. Exit: the composed operations coordinate loading, memory,
      execution, cancellation and disposal through those interfaces; MOSS layers and
      graphs contain no cross-model coordination.
- [ ] q8 has numerical error measurements only, taken with the conditioner's earlier
      linear-attention layers; no quality evaluation, and no 4-bit artifact has been built
      or measured.

## Split the app into modules

- [ ] Split `apps/mlx-bun` into modules on core services, as the repository split into apps and
  libraries (design: [Modular application](ARCHITECTURE.md#modular-application); contracts:
  `packages/app-core`). Modules: transcription, chat, models, train, quantize, datasets, memory,
  benchmarks (answer quality, `scripts/eval-serve.ts`), metrics and performance (live tokens/s, TTFT,
  batch occupancy, queue, KV/prefix usage and hit rate, memory per loaded model, swap and load
  times; launching `bench-serve` profiles with history). An agentic workflow engine is a later module,
  not planned here. Every step keeps existing paths, verbs and behavior: moved tests keep their
  expectations, and steps that move an execution path rerun real weights before and after.
  - [ ] (d) Memory module migration under validation (moved as is; the memory feature stays deferred).
    Datasets, quantize, benchmarks, train, models and chat landed. Every module's browser page is a panel
    on `@mlx-bun/web-kit`, mounted by the web shell. Memory reaches chat
    through `registry` (`chat.tool`, `chat.guidance`); its panel owns the memory entry, consent card and
    provenance chips, wired through the chat panel's `host`. The chat panel owns its markdown
    renderer, hold-to-talk mic (calling transcription over HTTP), and the assistant's app catalog, which
    should come from contributions once the shell lists them. Models owns hub, library, cleanup, adapter
    administration and its panel; chat owns selection of adapters for a turn. Exit per module: its domain
    leaves `apps/mlx-bun/src`, its browser page becomes its panel, the app domain map shrinks, and
    served-surface inventories are unchanged.
  - [ ] (e) Model host events reach every consumer. Residency, live switching, saved state and the model router landed
    (`serve` runs one isolated worker per resident model by default, held by memory fit in the parent; `--in-process`
    loads them in the serving process; the two share one residency manager), the host publishes `model.load` (with
    `resumed` when saved state was found), `model.unload` (reason `evicted`, flushed) and `model.memory`, and each worker's
    own events are relayed onto the parent's bus. The in-process composition now shares one `modelHost` across
    persistent and model-scoped modules for `generate`, `adapters` and the borrowed Whisper `transcribe` operation.
    Isolated HTTP voice discovery and idle unloading preserve the configured companion's identity and policy.
    Remaining: the isolated parent's typed module host also leases `transcribe` from its companion worker.
    Exit: a module acquires
    `generate` and `transcribe` from one service (the models module already leases `adapters` and switches the served model through the state's host).

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
| Memory synthesis (nightly pipeline) | n/a (app-owned; pipeline ported op-for-op) | done (task model on the continuous gateway under the engine's execution lease; isolated: the current worker's `/admin/memory/complete`) | done (`GET /v1/memory/synthesize`, `schedule` in `/api/memory/status`) | done (`memory` verbs incl. `init`/`setup`, `schedule`) | read panel done; no synthesize control (as main) | partial: stages match main token for token and in full logits, width-3 batch, isolated synthesis; [details](apps/mlx-bun/README.md#memory-synthesis) | Decision: the memory feature is incomplete and deferred; the ingest source is unchanged (Pi's global sessions directory, as main) |
| Live model switching, residency, isolation | n/a | done (one crash-isolated worker per resident model by default, held by the parent by memory fit; `--in-process` loads them in the serving process; either way the LRU model is drained with its saved state) | done (`POST /api/hub/serve`, routing by request `model`, `/v1/models` and `/library` with residency; worker socket: `/health`, `/admin/lease`, `/admin/drain`, `/admin/memory/complete`, `/admin/events`, `/admin/adapters`; isolated parent: `/engine`, `/health`, `/stats`) | done (`--model-budget`, `--ssd-cache`, `--in-process`; `--isolate` is accepted and ignored) | the Models panel switches live | partial: two small models resident and serving concurrently, a swap through saved state that resumes the prior conversation, and a pinned Whisper, in the default isolated mode and with `--in-process` (Qwen2.5-0.5B, MiniCPM5-1B, Whisper large-v3-turbo), and a worker killed mid-request answers 502 and reloads and resumes; no oracle parity; [details](apps/mlx-bun/README.md#model-host-residency-by-memory-fit) | Decisions (Josh): residency is by memory fit, saved state makes a swap feel like two models running, isolation is the default (one worker per resident model; `--in-process` opts out), and web chat works under isolation. Internal worker routes on TCP (`/admin/lease`, `/admin/drain`, `/admin/memory/complete`, `/admin/events`, `/admin/adapters`) and `/engine` under `--in-process` answer 404, not 501. Small items: Improvements |
| Speculative decoding: draft models, n-gram, MTP, DSpark/DFlash | done | done (one lane: a request is a batch of one; every provider is grouped since E5) | rides completions | done (`--draft-model`, `--draft-kind`, `--num-draft-tokens`, `--ngram-*`, `--mtp`; `draft regen|train|calibrate|quantize` produce drafters) | n/a | partial: B1 main preservation for n-gram (MiniCPM), Gemma4 two-model and Qwen3.8 Trellis MTP; [grouped consumer](packages/inference/README.md#speculative-generation) ran for n-gram, two-model and assistant | Open: DSpark, DeepSpec and GLM-5.2 native MTP unverified on real weights (none local); the cache × method matrix is closed by B3 and B4. Was: other provider/target/cache combinations; equality with main or an oracle; HTTP; performance |
| Paged KV | done | done (every graph with KV, every row kind; pages under bf16, affine, per-layer and TurboQuant; the direct reader is the composition field `pagedKv.direct`) | rides completions | done (`--paged-kv`, `--paged-kv-block-size`) | n/a | done for Gemma4 E4B/12B: gathered pages equal plain KV bit for bit, direct reader within tolerance, KV4/KV8 pages, HTTP cancellation per reader, cold prefill; [details](packages/inference/README.md#state-and-attention) | Open: warm-prefix (prompt cache on) identity over HTTP (main's `paged-cache-http` test is not ported); broader model support closed by B3 and B4 |
| Unsupported request shapes (typed error) | done | typed `UnsupportedExecutionError` per shape | typed 501 envelope | `generate` prints it, exit 1 | n/a | per shape once supported | Shapes become compositions under the Composition refactor (Phase E); the typed error stays for a request the composition was not built for |
| DiffusionGemma denoising (shared execution) | done (interleaved rows, B=1 graph calls) | done (placed continuously; encoded and paged KV compose since B4; grammar, draft, logprobs, logits processors and fill are refused with typed reasons, the denoising method having no token phases) | rides completions | rides `generate` | n/a | partial: text and one-image requests match main's measured trajectories (direct, grouped, B2/B4 join and cancel, HTTP), image cancellation and disconnect recovery pass; [details](packages/inference/README.md#optional-execution-and-persistence) | Open: stacked (B>1) canvases and token-chunked prefill (separate optimizations); concurrent HTTP rows, full logits and KV planes, external-oracle parity, performance. Main's `goldens/diffusion/gen*.json` no longer match main on MLX 0.32.2, so references are measured |
| Evaluation and benchmarking: `bench`, `evals`, `perplexity`, EvalDB, eval tasks | n/a (experiments; the in-package bench harness moves out) | n/a | `/fit` measured fields stay null | not app verbs | status page shows dashes | n/a | Runs consume the published packages and drive the app through its public HTTP and CLI surface; results are published as datasets or quoted as text in docs. The benchmarks and metrics modules ([split](#split-the-app-into-modules)) launch these runners and show history; they add no second runner |
| Pi terminal: `pi`, `harness pi` | n/a | chat backend reusable | n/a | held (`pi-terminal`, `harness-pi` not ported) | n/a | n/a | Held by Josh |
| Managed jobs: quantize, fine-tune, `convert`, `fuse`, datasets | n/a | done (each job child leads its own process group; stop is SIGTERM then SIGKILL after 3 s; the child stops its group when the parent's stdin pipe closes) | done (job, dataset and adapter routes) | done (`train`, `convert`, `fuse`) | job views done | partial: finished and merged fine-tune adapters mount, unmount and reproduce in a fresh process, and `fuse` output loads and generates (MiniCPM5-1B, opt-in `managed-jobs.test.ts`); [details](apps/mlx-bun/README.md#jobs-quantization-and-fine-tuning) | Decision: a managed job keeps running when its terminal closes (quantize's synchronous sensitivity sweep cannot observe the closed pipe): accepted. Verified on M1 Max: all four managed-job cases (including BF16 sensitivity cancellation and uniform conversion), isolated memory synthesis/cancellation, base memory stages and width-3 batching, and standalone library-host build. The trained memory-chunk adapter case still skips without its artifact. Relocated compiled app, installed current/previous bundles, worker and managed-child reentry passed (`verify:binary`; #295). |
| Existing-user data compatibility: prior-format sessions, jobs, settings, vault, caches; memory Reference symlinks into the main checkout | n/a | partial (Pi sessions, browser preferences and active-job prior schemas read across versions; the web chat sidebar lists every recorded chat; old `~/.cache/mlx-bun*` job history, memory and registry data are left in place, not migrated; adapter stores are listed read-only) | n/a | n/a | n/a | partial: synthetic old/new round trips (Pi sessions, preferences, jobs) and an acceptance on an isolated copy of real data pass (53 sessions, 10 adapters); the credential and schedule paths only synthetically (no saved token or nightly plist in the real data) | Decisions: everything mlx-bun writes by default lives under `MLX_BUN_HOME` (`~/.mlx-bun`); the HF hub cache holds downloads only; explicit paths win (#224); the opt-in `--expert-offload` still builds inside the model directory. Before deleting the old checkout Josh selects what to preserve outside it: the memory Reference symlink targets (7 point into it; 2 already dangle) and ignored adapters, checkpoints and other local artifacts that Git cannot recover. No automatic retargeting. Open: opening a chat appends SDK entries and opening a v1/v2 chat rewrites it, as in main |
| Docs surface and gates | n/a | n/a | HTTP and configuration inventories generated from source | CLI inventory generated from source | site and legacy redirects implemented | `apps/website/tests/server-api.test.ts`, `apps/website/tests/server-config.test.ts` | Per ARCHITECTURE: generate inventories from source as build-only output with a coverage gate, and write the explanations by hand (models, environment, training, memory, distribution, troubleshooting; quotable numbers as text with provenance in a benchmarks page). No STATUS file, docs map, or ledgers are restored. |

## Candidate quant and Hugging Face model card

This work characterizes the first quant published under the `mlx-bun` organization.
Use a validated engine to evaluate the artifact; duplicating quality evaluations
on main and the refactor is only useful when investigating a behavior difference.

- [ ] Audit the completed M4 Pro campaign for reusable scores: exact artifact and
  source revisions, dataset splits, prompts/templates, thinking mode, sampling,
  token budget, answer extraction, scoring and truncations. Retain scores whose
  protocol can be reproduced and accurately named; identify missing evidence.
- [ ] Select established benchmark protocols that support comparison with the base
  model or popular quants. Use the upstream runners, task definitions and scorers;
  record versions and full dataset coverage. Compare matching protocols, including
  thinking mode and generation budget. Label externally reported results and their
  settings; unresolved protocol differences cannot establish relative quant quality.
  Frozen subsets and different MMLU task variants must be named explicitly.
- [ ] Prepare model-card performance numbers from qualified measurements on M4 Pro,
  M1 Max or both. Record machine, engine/build, context, batch, KV configuration,
  cache state and MTP alongside prefill/decode, request latency and memory as measured.
- [ ] Document the quant's creation from the actual manifests: base model revision,
  quantizer revision and commands, rotation/folding, calibration and mixed-precision
  allocation, packing, final size and runtime requirements. Replace the inherited
  base-model card with the candidate's own measured results and reproduction details.
  Exit: the artifact and model card are ready to review and publish under `mlx-bun`.

## Completion

- [ ] Josh could delete the pre-refactor reference branch (`origin/pre-monorepo`, main at `02d723a`) without losing a capability it shipped.
  Exit: every row above is all-done or carries a recorded decision and is deleted;
  the verify items above close against pinned published goldens or are recorded
  decisions; main's user flows (CLI verbs, HTTP protocols, web chat, jobs,
  installed and compiled artifacts, existing user data) are accepted with real
  weights; documentation follows ARCHITECTURE (generated inventories, handwritten
  explanations, no ledgers); no capability main shipped is retired silently.

## Ideas and research

One line per idea: the question and the domains it touches. Picking one up makes it an item
above with an exit; an answered one moves its finding to the owning documentation and is deleted.

- **Formal proofs composed along the contracts** (kernels, layers, graphs, cache, scheduler; Josh,
  2026-10-11): because every piece implements a contract defined between layers and nothing crosses
  one any other way, correctness can be proven per lego (a kernel against its reference op over the
  composition's fixed shapes, a cache lego against the conformance obligations, a graph against its
  phase table) and composed the way the program composes, kernels to layers to graphs. Today's
  bit-identity gates are the empirical form; the contracts' JSDoc obligations (ownership, disposal,
  ordering, numerical guarantees) are the statements. Proofs compose over structure and bit-identity
  under the same kernels, not real-number equality. Strata (https://github.com/strata-org/Strata) might be a useful tool to explore (Josh,
  2026-10-12).

- **SkillOpt skill optimization** (chat, memory, a new optimization domain; [research](https://github.com/joshuarossi/mlx-bun/pull/247)):
  can SkillOpt's gated skill-edit loop (Microsoft, MIT, arXiv:2605.23904) improve the default
  assistant's prompt and skills and the memory stages' `Meta` policies with local models as target
  and optimizer, and should the loop run inside mlx-bun? First experiment: a `scripts/` runner using
  SkillOpt's `openai_compatible` backend against `mlx-bun serve` on one verifier-scored task set,
  measuring the optimizer's edit-JSON parse rate and the held-out gain with a 4B–27B optimizer.
