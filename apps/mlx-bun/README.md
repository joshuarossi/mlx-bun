# mlx-bun app

The runnable terminal app, server, and web surfaces live here. Default startup
loads a local model and serves the browser app, Pi web chat, and OpenAI-compatible
completions through one continuous scheduler. Model-management commands remain
available separately: `get`, `scan`, `ls`, `fit`, and `gc`.

After the root native setup, run
`bun apps/mlx-bun/bin/mlx-bun.mjs serve --model <cached-model-or-directory>`,
or use `mlx-bun` after the root's `bun run link-cli` step. The launcher checks
the app manifest's Bun minimum and Apple Silicon macOS before loading app code.
Help and version work before native setup; inference requires the staged natives.
Use `serve --help` for accepted options. A terminal session opens the browser
unless `--no-open` is supplied. Startup without a model selects a cached model;
if none is supported, it downloads the starter, then hands the recommended model
to the app's download owner as a background transfer, visible on `GET /downloads`
and joined at shutdown. A signal before the app exists cancels selection (a
starter download stays resumable); a signal during model load closes the app as
soon as it is up. Shutdown handlers are installed as soon as the listener binds.
Known unfinished features return HTTP 501 during migration; their remaining
work is tracked in [PLAN](../../PLAN.md). Unknown routes return 404, as do
main's lab pages (`/curves`, `/curve-terrain`, `/dag`, `/generate`, `/signal`):
they are not product surface.

Main's admission and runtime flags keep their units and semantics: `--memory-budget`
(decimal GB) is the usable envelope for model load, request admission, the process
allocator limit, optional cache residency, and `/stats.admission.memory_budget_bytes`;
`--context-length` feeds the GLM-5.2 resource plan and other families ignore it;
`--force-wire` and `--allow-private-media` set their library runtime switches for
the serving process; `--expert-offload` builds `<model>/.mlx-bun-offload` on first
use and activates it before construction for MoE models, while dense models log
and continue; the `--hlg-*` family sets the HLG sampling default; and
`MLX_BUN_SHUTDOWN_TIMEOUT_MS` (finite, positive, else 120 s) bounds shutdown.
The process-wide settings an app applies (offload routing, the allocator limit,
the runtime switches) are restored after its engine releases the model, on close
and on startup failure, so a later app in the same process starts from what it
found; offload restore only redirects routing and never unmaps borrowed weights.
`--adapter <dir>` (alias `--adapter-path`) mounts a LoRA adapter right after the model loads, before any request, under the directory's basename as its id; it becomes the default for requests without an `adapter` field, an explicit `adapter` (including `"none"`) still wins, `/v1/adapters` lists it, and a bad directory fails startup with `adapter mount failed: …` after releasing the model. The opt-in [startup adapter test](tests/engine/startup-adapter.test.ts) produces a three-step adapter with the fine-tune producer and serves with it. Main's speculative flags are restored with its validation: `--draft-model` resolves like the main model (a query never downloads) and its kind is auto-detected, `--draft-kind` overrides it (`ngram` is model-free; `mtp` alone mounts the bundled companion), `--num-draft-tokens`, `--ngram-max`/`--ngram-min` (ngram only; otherwise a warning), and `--mtp on|off` for GLM-5.2. The opt-in [draft flags test](tests/engine/draft-flags.test.ts) serves with ngram drafting and checks the speculation telemetry and exactness against a plain run. `--paged-kv` (env mirror `MLX_BUN_PAGED_KV=1`) with `--paged-kv-block-size` (only alongside paging) sets the paged KV request default; Gemma4-family requests use the paged path and other families answer the typed capability error, never a hidden serial lane. Startup rejects paging combined with a loaded draft, per-layer KV quantization, or TurboQuant; bf16 and uniform KV4/KV8 remain supported. The opt-in [paged KV test](tests/engine/paged-kv.test.ts) covers both family outcomes.

Shutdown stops background cache demotion, closes chat sessions, drains active
HTTP responses, then flushes caches and releases the engine. The CLI bounds this
with a 120-second deadline; cleanup failures or deadline expiry exit with code 1
(main exited 0 on timeout). SSD sub-options without `--ssd-cache` now fail before
model loading instead of warning and being ignored. The existing
`MLX_BUN_RD_CONTEXT_LIMIT` cap remains supported and is intersected with a loaded
GLM memory plan; this draft adds no serving context or read-only CLI flags.
Programmatic composition still accepts explicit context and read-only policy.

`src/cli/main.ts` dispatches commands; `args.ts` owns accepted options and help;
`hub.ts` owns model-management presentation; `terminal.ts` owns formatting.
`model-selection.ts` owns automatic selection policy; `serve.ts` composes the
model, cache, engine, HTTP routes, browser assets, and Pi backend.
The CLI uses public library APIs. It does not own cache indexing, downloads,
fit calculations, model graphs, or numerical execution.

From the repository root, run `bun apps/mlx-bun/src/cli/main.ts --help`.
The [executable behavior examples](tests/hub-cli.test.ts) demonstrate scanning,
listing, fit estimates, and safe GC against a temporary synthetic cache with
native MLX blocked. Run them with `bun run --filter mlx-bun test`.
`bun scripts/verify-packages.ts --app-only` repeats those tests through an
installed package artifact, compiling only the app microphone helper and never
loading MLX or accessing audio.

`gc` previews changes unless `--yes` is supplied; `--dry-run` always prevents
deletion. Cache location and Hugging Face credentials follow the
[hub library](../../packages/hub/README.md). This workspace remains private
while app licensing and release packaging are decided.

## One-shot inference

`mlx-bun generate [query] --prompt "…"` (alias `gen`) prints generated text and
exits. It uses the model's chat template when available; `--raw` feeds the prompt
verbatim. Main's greedy sampling, 256-token default cap, optional sampler/KV
settings, and unfiltered generated text are CLI policy. Model-author serving
sampling defaults do not replace them. Tier, serial, and compiled switches are
not exposed; execution uses the same continuous engine at capacity one.
TurboQuant KV options remain unavailable until shared execution supports them;
`generate --help` lists the currently accepted settings.

`mlx-bun embed [query] --text "…"` prints a vector per text, or one OpenAI-style
list with `--json`. Without text it reads nonempty stdin lines; `--instruct`
retains the query instruction. Without a model query it selects the first cached
embedding model. Generate resolves a local directory or registry query directly.
Neither command downloads models, opens a listener, or starts the browser.

`cli/inference.ts` owns argument policy, model selection, and terminal output.
The model host allows a missing template for these consumers; serving still
requires one. Shared text prompt construction preserves the CLI's explicit
no-added-specials encoding and HTTP's existing duplicate-BOS correction.
Both commands close the owned engine after success, failure, or cancellation.
[CPU examples](tests/inference-cli.test.ts) cover behavior and composition and
run against the installed artifact in `verify-packages --app-only`;
real-weight correctness and speed remain separate verification.

## Engine

`src/engine/` owns loaded model lifetimes, preparation admission and the shared
continuous scheduler. `createAppEngine` takes ownership of its model context;
closing drains execution before releasing compiled runners, adapters, drafts,
model constants and weights. Replacement models can provide their own binding.
HTTP parsing, response formatting and web policy belong above this boundary.

[Engine behavior tests](tests/engine/model-host.test.ts) verify injected model
loading and lifecycle without native MLX. The gateway and session tests beside
it cover cancellation, output delivery and the same scheduler path at capacity
one and greater. These are CPU checks, not real-weight numerical verification.
The first engine slice reports unsupported shared-execution capabilities rather
than running a hidden serial path. The library's denoising method still needs
shared scheduler support before the app can serve diffusion models.

`engine/cache-services` composes the library prompt cache and persistence. Its
default is 8 GB of RAM with plain KV; SSD storage requires an explicit directory.
Composition must pass the returned `continuationServices` to
`binding.gateway.configureContinuation` and supply `promptCache`,
`resolvedKvScheme`, `stateCodecs`, `adapterNamespace`, and checkpoint availability
as gateway options. The engine borrows these services; construction alone does
not attach them. Pass `close` through the owned `beforeModelDispose` hook so shutdown
drains execution, flushes persistence, clears cache state, then frees the model.
`flush` also supports explicit durability checks while the app is running:
`server/cache-routes.ts` serves main's `POST /admin/cache/flush` (200 with the
durability counters plus `entries` and `longest_durable_prefix_tokens`, 503
with the same counters when anything remains pending or failed) and
`POST /admin/cache/session/close` (`closed` reports whether a string
`session_id` was supplied; closing drops the session's cache association and
never deletes checkpoints, and it never waits for a flush in progress).
Cache policy tests inject storage and allocator ports; real SSD/numerical runs
remain separate verification.

## Server seams

`server/routes.ts` composes chat/text completion, Anthropic Messages, Responses, embedding, and discovery
handlers over an injected engine. Its `handle(Request)` returns a response or
`null` for the next application surface; it never opens a socket or closes the
borrowed engine. Application startup owns those lifetimes.

`server/management-routes.ts` owns tool-approval settings and confirmed cache
cleanup over the existing chat and hub libraries. Startup shares
`ServeOptions.chatPaths.toolApprovalsFile` with Pi and the settings routes.
GC requires an explicit `yes: true`, uses the hub's conservative plan, closes
its registry after rescanning, and invalidates discovery even if a rescan fails
after deletion. Execution returns 409 if the plan would remove the active model
snapshot, including a model reached through a symlink. Planning/execution errors
use the management JSON error shape. The [management tests](tests/server/management-routes.test.ts)
use isolated approval files and synthetic caches with native MLX blocked.
Hugging Face credential and upload routes are described under publishing below.

Inside `server/`, request parsing and prompt preparation precede the single-use
admission plan. The completion executor consumes the engine contract; the sink
and OpenAI wire modules own reasoning/tool/content events, JSON, and SSE.
`prompt-contracts.ts` describes owned media inputs; `media-prompt.ts` adapts
HTTP content parts to the library's numerical input builders. Grammar and media
work enter the engine's preparation domain before allocating native resources.
Text-only protocol work loads no MLX library. `anthropic.ts` translates Messages
requests and semantic completion events, including tools, thinking, and usage.
Its JSON and SSE paths use the same preparation, capability admission, scheduler,
and cancellation as chat completions; no second service is created.
`responses.ts` owns Responses translation and its process-local, one-hour,
32 MiB history. Successful JSON and SSE requests retain input, output, and
instructions for `previous_response_id`; failed or cancelled requests do not.
A generation error ends SSE with `response.failed`, without a misleading completion event. Composition
may supply `responseHistory` to replace the store; no isolated-worker forwarding
or duplicate completion service is involved.

The [request pipeline](tests/server/pipeline.test.ts) and
[HTTP examples](tests/server/routes.test.ts) execute with an injected engine,
including cancellation and ownership cleanup. Real-weight media and generation
verification remains separate; these tests prove the HTTP/engine boundary.
`server/start.ts` mounts HTTP, browser, and WebSocket handlers. Shutdown cancels
chat, closes connections, drains execution, flushes caches, and releases the
model. Its [listener tests](tests/server-start.test.ts) exercise real loopback
sockets without native MLX. The opt-in [model test](tests/engine/http-generation.test.ts)
uses `MLX_BUN_APP_TEST_MODEL=<cached-directory>` to exercise actual app startup,
lone/concurrent deterministic completion, live cache counters, stream cancellation,
Messages JSON, Responses JSON with a chained follow-up, and a real Pi WebSocket
turn with session persistence and replay. All chat, vault, and skill paths are
temporary; HTTP and WebSocket waits share a bounded network budget before shutdown.
The cached checkpoint used for this smoke is `mlx-community/MiniCPM5-1B-OptiQ-4bit`,
revision `664aabaed233c653f82716d8dc822234d0091f78`.
It never downloads weights; missing native libraries or an invalid supplied
checkpoint fail. This checks HTTP/Pi behavior, not quantize jobs, a compiled-binary
lifecycle, numerical parity, or performance.

`server/status-routes.ts` borrows live cache, scheduler, model diagnostic and
Responses-history counters for `GET /stats`; `GET /fit` uses the public hub fit
functions and the served artifact metadata. Predictions remain advisory and do
not impose an admission limit. GLM admission accounting uses its actual explicit
memory plan rather than the generic resident-weight estimate. Batch mode remains
continuous even at capacity one. Pending SSD counters include the generation
checkpoint queue as well as prompt-cache persistence work.
Historical EvalDB measurements have no migrated owner, so measurement fields
remain null; old machine-specific GLM throughput constants are not reported as
measurements for the current server or CLI fit output. The library retains those
historical constants. The dashboard shows an unavailable marker
when no estimate exists. [Status tests](tests/server/status-routes.test.ts) use
synthetic counters and CPU fit inputs without a model or native MLX.

## Web chat backend

`src/chat/protocol.ts` owns browser messages. `backend.ts` owns a per-server
WebSocket lifecycle behind the `ChatBackend` interface and a send-frame callback.
The Pi implementation in `pi-backend.ts` calls the application's loopback HTTP
API; it imports no server, engine, or native numerical implementation.
`history.ts`, `events.ts`, and `policy.ts` own transcript operations, event
translation, and chat policy; the tool modules own app navigation, web retrieval,
and durable approval choices. Pi dependencies stay in this app workspace.

Composition supplies the backend factory to `makeChatWebSocketHandler`, mounts
its `websocket` handler, and awaits its `dispose()` on shutdown. Each connection
gets an independent agent session. Abort and approval messages remain available
while a prompt is running. Shutdown cancels each backend, waits for pending
startup and message cleanup, then reports any peer disposal failures. Pi waits
for the agent to become idle and for an in-flight session replacement before
releasing its runtime. The [lifecycle examples](tests/chat-backend.test.ts)
exercise startup failure, disconnects, cancellation, and shutdown without a
server or native libraries; [chat behavior tests](tests/chat-policy.test.ts)
cover history, sampling scopes, thinking events, tool-loop policy, and UI tools.

Memory is disabled until its app owner supplies tool definitions, names, skill
paths, and its prompt hint through `PiBackendOptions.memory`. Download context
is an optional callback from app composition. Standalone Pi integration remains
deferred. The protocol exposes no serial-serving lane selection.

`chat/session-search.ts` reads Pi JSONL transcripts for body search; the sibling
`session-files.ts` owns confined reads and the shared default directory.
`server/session-routes.ts` owns search/export HTTP responses. Startup passes the
same resolved session directory to Pi and these routes. Searches retain main's
case-insensitive Unicode snippets and limits; export returns valid raw JSONL
entries while skipping partial lines. Lexical and resolved paths must stay in
the configured directory, including symlink targets. No index or background
lifecycle is created. [Session tests](tests/session-search.test.ts) use temporary
trees, and the [Pi smoke test](tests/chat-runtime.test.ts) searches and exports a
transcript written by the real SDK in app-supplied paths.

App composition can supply `PiBackendOptions.paths` (`cwd`, `agentDir`,
`sessionDir`, `toolApprovalsFile`) to isolate runtime settings and transcripts.
Omitting them preserves the installed app locations. These are composition
options, not CLI switches. The [SDK smoke test](tests/chat-runtime.test.ts)
uses temporary paths and a fixed loopback SSE response to exercise real Pi
startup, provider hooks, streaming, cancellation, and transcript persistence
without a model or access to the installed app's chat storage.

## Browser app

`src/web/browser/` preserves the existing chat, model, training, quantization,
dataset, memory, and status UI. Browser code imports only local browser modules
and the data-only chat/job protocols. Unported backend features may return 501
during migration; preserving their UI does not claim their backend is ready.

`src/web/assets.ts` provides `createWebHandler()`, which loads the static payloads
and returns a `Request → Response | null` handler for application composition.
It opens no listener. `bun run --filter mlx-bun build:web` creates ignored
`dist/web/app.js`; prepack generates and includes that file, so installed apps
need no build step. A source checkout with no generated bundle compiles the
browser entry in memory on startup, without writing installation files. The
build script and runtime fallback share `web/build.ts`. Static HTML, theme, manifest, worker, and icon live in
`src/web/public/`. The vendored highlight.js bundle retains its BSD license in
`public/vendor/hljs-LICENSE`; its existing header records upstream provenance.

[Browser behavior tests](tests/web/browser.test.ts) cover streaming rendering,
escaping, attachments, panels, and interactions without a live server.
[Static tests](tests/web/assets.test.ts) exercise the built bundle and asset
headers. The packed consumer check verifies the same assets after installation.

`server/adapter-routes.ts` presents available and resident adapters and mounts or
unmounts through the engine execution lock. It borrows the engine; no HTTP
handler owns tensors. Serving with an adapter still uses the shared scheduler
and reports 501 for unsupported batched capabilities.

## Memory vault

`src/memory/article.ts` owns Markdown article structure; `vault.ts` owns vault
initialization, filesystem reads, search, links, and Git history. The default
vault is `~/.mlx-bun/wiki`, with `MLX_BUN_WIKI` as its override.
`server/memory-routes.ts` exposes the read/init HTTP surface through
`createMemoryRoutes({ root })`; CLI startup composes it before model routes.
Initialization is explicit and idempotent, and its path stays confined to the
vault or temporary trees. Existing article/Talk directory links remain usable;
initialization confines its actual write targets. Reference seeding defaults to
none; composition can pass explicit `referenceSources` without inferring old
repository documentation paths. Merely starting the app does not create a vault.

[Route tests](tests/server/memory-routes.test.ts) use injected temporary vaults
and real local Git history; [article tests](tests/memory/article.test.ts) cover
parsing and round trips. `query.ts` owns deterministic article navigation;
`tools.ts` owns the read-only Pi definitions and prompt hint. CLI composition
passes the same vault root to REST and chat and supplies a skill directory
(default `~/.mlx-bun/skills`). `ServeOptions.memoryPaths` permits isolated app
composition without adding CLI flags. Missing vaults expose no memory tools and
create no skill files. Bundled skills are package assets; standalone binary
embedding remains part of the release migration.

[Tool tests](tests/memory/tools.test.ts) exercise temporary vaults, and the
[SDK test](tests/chat-runtime.test.ts) executes a memory tool through a real
read-only Pi session with a synthetic loopback model. No read tool starts a
synthesis run.

### Memory synthesis

Main's nightly pipeline lives under `src/memory/` unchanged in prompts, stage
order, database schema (`db.ts`, `~/.cache/mlx-bun/memory.sqlite`), vault
layout, Git usage, and the dedup/normalize/reconcile rules: `pipeline.ts` drives
the four resumable, chronological stage workers in `stages.ts` (SEGMENT via
`chunk.ts`, ENTITY-EXTRACT via `entity.ts` + `resolve.ts`, ROUTE via `route.ts`,
SYNTHESIZE via `synthesize.ts`/`cluster.ts`/`reconcile.ts`), then the
deterministic `crosslink.ts` pass and the `wikify.ts` editorial sweep. `events.ts`
holds the shared event contract so no stage imports the orchestrator.

The engine is reached only through `model.ts`'s `MemoryCompletionClient` seam.
The memory domain defines the interface; composition injects the one
implementation, `server/memory-completion-client.ts`, which posts each stage
call to a serving mlx-bun's own `/v1/chat/completions` (raw greedy sampling,
neutral logit processors and the model template's thinking defaults, the
stage's system/user turns, `adapter: "memory-chunk"` for the chunk stage when
`~/.cache/mlx-bun/adapters/memory-chunk` exists and `"none"` otherwise) so
synthesis rides the continuous-batching scheduler. `MLX_BUN_MEMORY_BATCH`
(default 1) bounds the calls in flight per batched stage. Nothing in the memory
domain loads a model, and no serial lane exists. Each run receives its client
and vault root explicitly; Meta policy reads use that same vault. A failed batch
stops admission, cancels siblings, and joins them before returning its error.
`server/memory-synthesis.ts` owns active server runs: request/body cancellation
aborts the run, and server shutdown cancels and joins all synthesis before engine
drain. Completed stage writes are resumable; cancellation does not roll them back.

`GET /v1/memory/synthesize[?dry=1]` streams the run as SSE (`stage`/`log`/`done`
events, a `summary`, then `[DONE]`; a failure ends with an `error` event); it is
mounted only when composition supplies the pipeline. `mlx-bun memory` exposes
main's subcommands: `init`/`setup` (the wizard below), `status` (default),
`open`, `list`, `search`, `toc`, `section`, `links`, `read`, `synthesize`
(`--dry-run`; `--since`/`--model` parsed but not consumed, as in main), the
stage workers `segment`, `extract`, `route`, `synthesize-stage` (`--limit`,
`--convs`), `link`, and `schedule`/`unschedule`. Model-driven subcommands talk
to the server named by `--host`/`--port` (the serve defaults) and fail with a
pointer to `mlx-bun serve` when none answers. The entity gold main read from
`goldens/dreaming-entities-gold.json` is a published dataset: without that
file the resolver runs unseeded (store aliases still fold).

[Pipeline tests](tests/memory/) port main's model-free suites with fake stage
calls, in-test vaults, and an in-test entity gold; the
[client test](tests/server/memory-completion-client.test.ts) and
[verb test](tests/memory-cli.test.ts) use a fake fetch and a temporary HOME.

### Memory setup and nightly schedule

`mlx-bun memory init` (also `memory setup`) runs main's onboarding wizard.
`mlx-bun setup` is main's true alias of `mlx-bun memory`: `mlx-bun setup init`
is the same wizard and a bare `mlx-bun setup` reports status. The wizard
initializes the vault through the same `setupVault` as `POST /api/memory/init`
(idempotent; no reference seeding), offers to import an existing wiki's
`articles/` (main's prompt; default yes once a path is given; the import is
committed), and offers to install the nightly synthesis job (main's prompt;
default no; then asks for the time, default 03:00). A non-TTY stdin answers
every prompt with its default, so a scripted run initializes the vault and
installs nothing.

`memory schedule [--at HH:MM]` writes main's launchd agent,
`~/Library/LaunchAgents/com.mlx-bun.memory.plist` (label `com.mlx-bun.memory`,
`StartCalendarInterval` at the local time, default 03:00, `RunAtLoad` off,
`ProcessType` Background, logs in `~/.mlx-bun/logs/memory-synthesis.{out,err}.log`),
then `launchctl unload` and `launchctl load -w` it; a failed load is reported,
not thrown. `memory unschedule` runs `launchctl unload -w` and deletes the
plist. The job runs `/bin/zsh -lc "exec <program> memory synthesize"`, where
the program is the executable identity captured at startup
(`jobs/executable.ts`) plus the CLI entry when running from source; it is
never a PATH lookup and never `process.execPath` read later. Because synthesis
runs through a serving mlx-bun, the job needs `mlx-bun serve` running at that
time; every status surface says so (the improvement that the server should own
the scheduled run is recorded in PLAN).

`scheduleStatus` reports `installed` (plist present), `loaded` (`launchctl
list com.mlx-bun.memory` succeeds), `at` (read back from the plist; `null`
when absent or hand-edited), and `note` (what the job runs and needs).
`memory status` prints it as the `nightly` line, `GET /api/memory/status`
returns it as `schedule` beside `status` (absent when no vault exists), and
the `memory_status` tool prints its `nightly` line; the memory skill tells the
assistant not to claim a scheduled run happened unless the last synthesis
commit shows it.

`src/memory/schedule.ts` owns the plist and takes the home directory and the
`launchctl` runner as seams; `cli/memory.ts` adds the vault root, the job's
program, and the prompt; the tool and route factories take a `schedule` probe.
[Schedule tests](tests/memory/schedule.test.ts) and the
[setup verb test](tests/setup-cli.test.ts) drive every path under a temporary
home with a recording `launchctl`, an injected vault root, and scripted
answers; spawned runs use a temporary HOME and a non-TTY stdin. No test
reaches the real launchd, `~/Library/LaunchAgents`, or `~/.mlx-bun`.

## Jobs, quantization, and fine-tuning

`jobs/` owns the lazily opened SQLite store, durable NDJSON events, SSE tails,
and managed subprocess lifetimes. `quantize/` owns submitted quantization policy
and CPU-only model inspection; the numerical work uses `@mlx-bun/quantize`.
`finetune/` owns dataset inspection and submitted SFT/DPO/ORPO policy; its child
runner loads the chosen model and invokes `@mlx-bun/training`. Library defaults
are supplied to the app mapper, which preserves main's ORPO recipe and bf16
head fallback. The child restores its wired-memory limit and releases its model
and weights on completion or failure. Training progress passes through unchanged
to job events, preserving metrics, adapter paths, and stage fields; the job owner
alone emits the terminal lifecycle event.
`cli/job-entry.ts` resolves the producer in the child process. HTTP parsing and
wire responses stay in `server/job-routes.ts`, `server/quantize-routes.ts`, and
`server/finetune-routes.ts`.

`mlx-bun convert <repo-or-path> -q` is main's mlx_lm.convert counterpart: a
local model directory, a downloaded model, or an `org/name` repo id (fetched
first, resumable) is quantized into `--mlx-path` (default `mlx_model`, which
must not already exist) by the same `createQuantizeRunner` producer the web
quantize job runs, as an owned child process over a temporary job store (the
sensitivity sweep is synchronous, so only a separate process keeps the parent
responsive; progress is tailed from the job log). `--q-bits 4|8` and `--q-group-size 32|64` select
uniform affine quantization; `--target-bpw` with `--candidate-bits`,
`--calibration-mix`, `--n-calibration`, `--rotate-weights`, and
`--rotation-seed` select the mixed path. `--upload-repo` resolves the write
token before any work and publishes through the app publisher afterwards; an
upload failure keeps the model and prints the retry hint. `--dtype`,
`-d`/`--dequantize`, `--quant-predicate`, a non-affine `--q-mode`, and plain
non-quantizing conversion are refused with main's messages. Each conversion owns a
private root beside the destination holding the child's result, staging, temp
probes, and job store; only a complete result is published, by one rename.
SIGINT/SIGTERM terminate and join the child immediately, even mid-sweep
(SIGKILL after a grace period if it ignores SIGTERM), and on every failure or
cancellation the parent removes only that owned root, never anything inferred
from a name. `cli/convert.ts` owns the verb. [Convert tests](tests/convert-cli.test.ts)
cover validation, source resolution, the producer config, credential ordering,
upload, cancellation, the child owner (complete-result publish, a SIGTERM-ignoring child, a failing child, an unrelated sibling left intact),
and the spawned CLI with native MLX blocked; they do not quantize real weights.

Composition injects the engine execution lease. A job drains active inference
and holds that lease until its child exits and output streams finish; inference
then resumes. As in main's direct-process server, resident model weights and
caches remain allocated while the child runs. Shutdown stops queued jobs, aborts
admission waits, terminates active children, and awaits them before closing the
store and engine. Opening the app does not create the job database until a job
route is used. A fine-tuning job selects its own model path;
the resident inference model's adapter/training capabilities do not gate it.

`cli/train.ts` owns the `train`, `train-watch`, and `fuse` verbs as thin
presentation over this producer and the public training library. `train`
validates main's flags before any model resolution, preflights the dataset,
prints the plan, and drives `createFinetuneRunner` in-process (`--dry-run` stops
at the plan). SIGINT/SIGTERM abort at the next optimizer-step boundary, after any
checkpoint writes already started have completed. Cancellation detaches training
state and releases its resources; completed checkpoints remain usable. A final
save already started is allowed to finish and is reported as success. `train-watch` (`finetune/watch.ts`) tails the trainer's
`<adapter>/metrics.jsonl`. `fuse` merges an adapter through `fuseAdapter` and
refuses the mlx_lm.fuse flags main refused; the merge cannot be interrupted, so
a signal arriving during it lets the output finish rather than leaving a partial
directory. [Training CLI tests](tests/train-cli.test.ts) use injected
dependencies and a spawned CLI with native MLX blocked.

[Job lifecycle tests](tests/jobs/lifecycle.test.ts) exercise leases, crash/error
paths, shutdown, HTTP/SSE, and a real CPU-only child with temporary storage.
[Quantization policy tests](tests/quantize/policy.test.ts) verify option forwarding
and output naming with an injected numerical operation. They do not run or
establish parity for actual checkpoint quantization.
[Fine-tuning policy tests](tests/finetune/policy.test.ts) cover the app recipe,
explicit overrides, dataset inspection, HTTP submission, progress, and resource
cleanup with a fake native runtime. These CPU checks do not extend the numerical
claims in the [training evidence](../../packages/training/README.md).

Composition takes `storagePaths` (job store, saved token file, artifact root)
like `chatPaths` and `memoryPaths`, so embedded and test servers never touch
the user's jobs or credentials. The opt-in
[managed-jobs acceptance](tests/engine/managed-jobs.test.ts) runs a real
`mlx-bun serve` process under a temporary HOME and `HF_HUB_CACHE` with the
cached model named by `MLX_BUN_APP_TEST_MODEL`: a quantize job whose artifact
appears in the library and reloads for a short generation, inference after its
lease, a three-step SFT job with a
periodic checkpoint, a long job cancelled by shutdown (child terminated, row
terminal, complete checkpoint metadata kept, no final adapter, bounded progress),
and a restart on the same storage that mounts the preserved checkpoint; then a spawned `train` interrupted by SIGINT at a step
boundary, and, with a cached bf16 snapshot named by
`MLX_BUN_APP_TEST_BF16_MODEL`, a `convert` interrupted after its durable job log
reaches the Probing/Sensitivity stage and a complete uniform conversion whose
output reloads and generates. It downloads nothing.

## Dataset jobs

`dataset/` owns the existing template inputs, generation, Hugging Face import,
and 90/10 JSONL split. `server/dataset-routes.ts` owns template discovery and
submission; CLI composition supplies the bound loopback port and runner. Jobs
run in-process and call the normal HTTP inference surface, so each inference
request uses continuous batching without an exclusive GPU lease. Shutdown
cancels requests and retry waits and joins tasks before closing job storage.

Twelve templates are enabled. `verified_code` remains visible with an unavailable
explanation and returns 501 until generated-code execution has a migrated owner.
[Dataset tests](tests/dataset/lifecycle.test.ts)
use temporary storage and synthetic HTTP responses, without a model or download.

Adapter merge/export requests are owned by `server/adapter-artifact-routes.ts`.
Merge uses the public training library while holding the engine execution lock;
export writes a CPU-only manifest without taking that lock. Both preserve the
existing output roots and prefixes, with unique suffixes so simultaneous requests
cannot overwrite each other's artifacts.

`publishing/credentials.ts` owns the app's `~/.mlx-bun/hf.json` token file (mode
0600). Resolution prefers the saved token, then `HF_TOKEN`, then the shared HF
cache through the hub resolver. Explicit paths and environment isolate tests
and embedded consumers. Settings responses expose presence only.
`publishing/upload.ts` selects an explicit source or the supplied job's output
and passes resolved credentials to the public hub uploader. HTTP shapes and
errors belong to `server/publishing-routes.ts`; CLI composition supplies the
read-only job lookup. Quantized models and adapters publish as model repos;
datasets publish as dataset repos. Uploads need no model execution lease.
[Publishing tests](tests/server/publishing-routes.test.ts) use temporary token
storage and an injected uploader; they never read installed credentials or
publish to Hugging Face.

`cli/upload.ts` is the `upload` verb, main's `mlx_lm.upload` counterpart:
`mlx-bun upload --path <dir> --upload-repo <org/repo> [--private]` (the path
defaults to `mlx_model`). It resolves the token through
`publishing/credentials.ts`, fails before any request when the repo id,
directory, or write token is missing, and pushes a model repo through the same
public hub uploader with the commit message "Upload with mlx-bun". SIGINT or
SIGTERM aborts the transfer; nothing is committed after an abort. The
[upload CLI tests](tests/upload-cli.test.ts) drive the verb with injected
dependencies and spawn the real CLI against a local mock Hub with an isolated
home directory and an invented token.

## Web hub

`server/hub-routes.ts` owns the web hub list/search and restart-required response.
Local rows consume registry and fit APIs; search remains request-owned and
cancels with its caller. `hub/downloads.ts` owns web-started transfers: admission
is synchronous before the metadata request, so a duplicate submit answers 409;
`GET /downloads` serves the owner's rows, one per transfer from admission (the
browser shows "preparing…" until the listing and preflight finish) through the
hub tracker's live row to done, or to an error when the listing fails or
shutdown cancels it; completion rescans the registry and
invalidates discovery; shutdown aborts and joins every transfer before the engine
closes, leaving resumable partials and publishing nothing. Selecting a model
returns a restart command, preserving main's behavior without claiming a live
switch.

## Audio transcription

`engine/transcription-service.ts` owns the Whisper checkpoint's residency
(main's `TranscriptionService`). The weights load on the first take through
the library's public `openWhisperModel`, `loadWhisperTokenizer`, and
`WhisperTranscriber`; takes run one at a time (FIFO) and, in the full server,
inside the generation gateway's exclusive lock, so decoding never overlaps
chat generation. Residency follows main's flags: `--whisper-idle-unload <s>`
(default `0`: release right after every take; the next take pages the weights
back in from the OS file cache) and `--whisper-resident` (never release).
`mlx_bun.timings.load_ms` in every response is non-zero exactly when that
request paged the weights in. Loading, the Silero VAD gate, and audio decoding
are an injected runtime, so the [service tests](tests/engine/transcription-service.test.ts)
prove the lifecycle (lazy load, idle timer, resident mode, unload-after-take,
FIFO takes, sessions, close) with a fake clock and no weights.

`server/audio-routes.ts` serves main's speech-to-text surface:
`POST /v1/audio/transcriptions` and `POST /v1/audio/translations` (multipart
`file` or JSON base64/`data:` URL; `language`, `prompt`, `response_format`
`json` | `verbose_json` | `text` | `srt` | `vtt`, `temperature`, `stream`
server-sent events, `timestamp_granularities[]`, and main's non-standard
`beam_size`, `vocabulary`, `condition_on_previous_text`, `no_speech_threshold`,
`without_timestamps`, `vad`/`vad_threshold`/`vad_min_speech_ms`/`vad_trim`,
`faithful`, `audio_ctx`); streaming dictation sessions (`POST /v1/audio/sessions`,
`POST /v1/audio/sessions/<id>/audio` with `audio/pcm;rate=16000` float32 or any
CoreAudio container, `POST /v1/audio/sessions/<id>/finish`,
`DELETE /v1/audio/sessions/<id>`; unknown ids 404, a finished session 409, more
than 64 open sessions 429); and `POST /admin/transcription/unload`, which pages
the weights out and returns `unloaded` with the stats block (`resident`, `loads`,
`unloads`, `requests`, `last_load_ms`, `idle_unload_sec`). Errors keep main's
statuses: 400 for fields, undecodable audio, and clips under 0.1 s; 415 for the
content type; 499 on client cancel; 503 `model_unavailable` with the
`mlx-bun get` hint when no Whisper checkpoint is on disk. The group is mounted
only with a service provider; the app composition always supplies one.

`serve.ts` composes the companion: `--whisper-model <path|query>` resolves like
the main model and refuses a non-Whisper checkpoint before loading; without it
the first downloaded `whisper` checkpoint is looked up once, on the first audio
request (as in main, a checkpoint downloaded later needs a restart).
`GET /v1/models` lists the companion (`transcription: true`, `resident`) beside
the chat model, whose `capabilities.transcription` reports whether one exists;
the web chat's `ready.transcription` probe (the hold-to-talk mic) reads the
same provider. Shutdown closes the service (timer cancelled, weights released)
before the chat model. Serving a Whisper checkpoint as the main model starts
the transcription-only server: the audio routes plus `/v1`, `/v1/models`,
`/health`, and `/stats` (the last two carry the `transcription` stats block),
with no chat model, prompt cache, jobs, web app, or browser open; `--preload`
loads the weights before the listener binds. The
[route tests](tests/server/audio-routes.test.ts) cover parsing, every response
format, streaming, sessions over the real service with a fake runtime, and the
transcription-only discovery routes; the [serve tests](tests/serve-cli.test.ts)
cover the flags, both `runServe` branches, and both compositions. The opt-in
[transcription test](tests/engine/transcription.test.ts)
(`MLX_BUN_TEST_NATIVE=1 MLX_BUN_APP_TEST_WHISPER_MODEL=<snapshot directory>`)
serves a real checkpoint, transcribes a synthesized tone, and pages the weights
out through the unload route; transcript parity against mlx-whisper is the
library's contract, not this app check.

`mlx-bun transcribe <audio-file> [query]` is main's one-shot speech-to-text
verb over the same service, no server. The clip is read and decoded (WAV
through the exact PCM parser, anything CoreAudio reads through AudioToolbox)
before any model is resolved, so a bad file never opens the registry. The
model is `--model`, else the second positional, else `--query`, else the first
downloaded `whisper` checkpoint (the `mlx-bun get` hint when none).
`--language`, `--task translate`, `--beam-size`, `--temperature`,
`--no-fallback`, `--prompt`, `--no-timestamps`, `--no-condition`,
`--word-timestamps`, `--faithful`, and `--audio-ctx` keep main's decoding
policy (the `(0, 0.2, …, 1.0)` fallback ladder unless a temperature or
`--no-fallback` is given). `--vad` (with `--vad-threshold` and `--vad-model`)
prints an empty result and never loads Whisper when the Silero gate finds no
speech; `--vad-trim` is accepted without cropping, as in main. `--format` is
`text` (default) | `json` | `verbose_json` | `srt` | `vtt`; `--verbose` prints
each segment as it decodes and a realtime summary on stderr. SIGINT aborts the
decode or the take, releases the weights, and exits 1. The file CLI accepts
clips under 0.1 s, as main did; HTTP keeps its existing minimum duration.

`mlx-bun dictate [query]` is main's push-to-talk loop. `engine/mic-capture.ts`
spawns the AVAudioEngine sidecar (`native/mic-capture.swift` →
`mlx-bun-mic-capture`: 16 kHz mono float32 PCM on stdout; `ready`, `hotkey
down`, `hotkey up`, and `error:` lines on stderr; macOS asks for Microphone
permission on first use), resolved from `MLX_BUN_MIC_CAPTURE`, beside the
standalone executable, or the package's `dist/native/`. Source checkouts stage it
explicitly with `bun run --filter mlx-bun build:native` (requires swiftc);
`prepack` builds it into the published artifact. Runtime never compiles helpers.
Enter starts and stops a take (`q` or
Ctrl-C quits); `--hotkey [keycode]` holds a key instead (default 61, Right
Option; needs Input Monitoring). Every 250 ms of audio feeds a transcription
session while you speak, so the text lands about one window after the take
ends, and the Silero gate keeps silence from running Whisper (`--no-vad` skips
it and, unlike main, does not load its weights). The transcript prints;
`--copy` pipes it to `pbcopy`; `--type` sends System Events keystrokes after
`--type-delay` (1 s in Enter mode, 0 with `--hotkey`; needs Accessibility).
The backend is the in-process service with `--idle-unload <s>` (default 30;
0 = release after every take) and `--resident`, or `--server <url>` for a
running server's `/v1/audio/sessions`. Stopping ends the sidecar's stdin,
terminates it, joins it (SIGKILL after two seconds), and only then releases
the weights. It cancels and joins session requests and active transcription,
cleans up the open session, and prevents delayed copying or typing after
cancellation. Ctrl-C exits 0, as in main.

The [transcribe tests](tests/transcribe-cli.test.ts) and
[dictate tests](tests/dictate-cli.test.ts) run both verbs over the real
service with a fake runtime and a fake capture source (generated WAV and PCM,
every format, chunked feeding, the VAD gate, residency, delivery, the server
backend, cancellation joining the capture before the weights release) and
spawn the CLI for help and error paths; they also run against the installed
artifact in `verify-packages --app-only`. The
[mic capture tests](tests/engine/mic-capture.test.ts) cover resolution, the
sidecar protocol, and the terminate-and-join with shell stand-ins. A real
microphone is exercised only by hand; package and relocated-bundle verification
resolve the shipped helper and run `--help` before any audio initialization.

## Standalone bundle

After staging the root native setup and the app helper with
`bun run --filter mlx-bun build:native`, run `bun run build:binary` from the root.
`dist/bundle/` contains the executable, native libraries/helpers, Pi's Photon
WASM sidecar, the project license, and combined MLX/inference third-party notices.
Move the whole directory together. Web assets and the memory skill
are embedded; source checkouts retain their existing asset readers and browser
build fallback. No terminal Pi assets are included.

`bun run verify:binary` builds into temporary storage, relocates the directory,
installs it through the curl installer using a local archive and temporary home,
and checks the actual CLI and managed child plus a compiled consumer for web,
memory, synthetic registry/fit, native path resolution, microphone helper help,
and Photon initialization.
The default performs no MLX/GPU operation or remote download. Mac CI runs this check.
With exclusive GPU access, `bun run verify:binary --model /path/to/cached-model`
also starts the actual relocated executable, checks its web assets, `/stats`,
`/fit`, and a chat completion, then requires a clean SIGTERM exit. It discovers
the supplied weights through a temporary HF snapshot symlink and isolates the
child's home, caches, and chat storage; it never copies or downloads weights.
This is a local build artifact, not signing/notarization or release publishing.

[`scripts/install.sh`](../../scripts/install.sh) installs a complete release
bundle under `${MLX_BUN_INSTALL_DIR:-$HOME/.mlx-bun}/app-install/` and links
`~/.local/bin/mlx-bun`. `MLX_BUN_VERSION` selects `latest` or a pinned tag.
The installer validates the files and version before switching its `current`
symlink and retains the old app on failure. Successful updates keep the current
and immediate previous bundles, plus any older bundle used by a running app.
Other older owned bundles and stale stages are removed on the next install;
vnode inspection keeps bundles used by apps launched through PATH or symlinks,
and an inconclusive inspection retains the affected bundle. The CLI captures
its executable identity at startup, so managed jobs launched after an upgrade
still use that running app's original build. A later install prunes old bundles
after their processes exit.
Sessions, wiki, credentials, and legacy flat installation files
outside `app-install/` stay intact. A custom `MLX_BUN_INSTALL_DIR` relocates only
the installed bundle; application data still lives under `~/.mlx-bun`.
A concurrent install is blocked by `app-install/lock`; after an interrupted
installer, remove the reported absolute lock directory only after confirming
its recorded PID is no longer an installer. Run the script with `--help` for usage.
The public installer must not deploy before a compatible release bundle exists;
older release archives lack the newly required license and notice files.

`bun scripts/prepare-homebrew.ts /path/to/mlx-bun-v<version>-arm64.tar.gz`
prepares a local `mlx-bun.rb` beside the archive, with its version, release URL,
and SHA256. The formula installs the entire bundle in `libexec` and symlinks its
command into `bin`. Preparation checks archive members; release verification
must additionally check that its binary version matches the archive filename.
Preparation does not install, sign, notarize, publish, or
update the tap. [Installer tests](tests/install.test.ts) use local archives and
temporary homes, including reinstall and failure paths, without network access.

## Release preparation

`bun scripts/prepare-release.ts prepare /new/output/directory` builds from staged
natives, checks the executable against the app manifest version, packs workspace
packages, and writes unsigned local archives, checksums, and a Homebrew formula.
`preparation.json` records bundle hashes, dependency-first package publication
order, and pending private/version decisions. Nothing changes those decisions or
publishes. The `unsigned/` output is for local verification only.

The same script has explicit `sign <directory> <Developer-ID-identity>`,
`notarize <directory> <keychain-profile>`, and `package <directory>` stages.
Signing handles every nested Mach-O before the executable, applies the preserved
Bun JIT/library-validation entitlements, verifies each signature, and checks
launch/version. Notarization submits to Apple and requires JSON status `Accepted`;
an exit code of zero alone is insufficient. Packaging rejects changed bundle
bytes and missing accepted evidence, then writes the versioned and stable arm64
tarballs, matching checksum sidecars, and formula under `release/`.

Run `--help` for usage. Signing/notarization and publishing require Josh's release
instruction; preparation and tests do not access identities or Apple services.
GitHub/npm publication and tap synchronization remain separate unfinished release
work. No stage invokes those operations. [Release tests](tests/release.test.ts)
use captured mock signing/notary commands; they do not prove a real signature or
Apple acceptance.
