# mlx-bun app

The runnable terminal app, server, and web surfaces live here. Default startup
loads a local model and serves the browser app, Pi web chat, and OpenAI-compatible
completions through one continuous scheduler. Model-management commands remain
available separately: `get`, `scan`, `ls`, `fit`, and `gc`.

After the root native setup, run
`bun apps/mlx-bun/src/cli/main.ts serve --model <cached-model-or-directory>`.
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
`--adapter <dir>` (alias `--adapter-path`) mounts a LoRA adapter right after the model loads, before any request, under the directory's basename as its id; it becomes the default for requests without an `adapter` field, an explicit `adapter` (including `"none"`) still wins, `/v1/adapters` lists it, and a bad directory fails startup with `adapter mount failed: …` after releasing the model. The opt-in [startup adapter test](tests/engine/startup-adapter.test.ts) produces a three-step adapter with the fine-tune producer and serves with it.

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
installed package artifact, without building or loading native libraries.

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
read-only Pi session with a synthetic loopback model. Synthesis, nightly
scheduling, and the memory CLI remain unavailable; status and skill guidance
say so explicitly. No read tool starts those lifecycles.

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
at the plan). SIGINT/SIGTERM abort the run at the next progress event; the
trainer has no cancellation seam, so a cancelled run releases its resources but
writes no final adapter. `train-watch` (`finetune/watch.ts`) tails the trainer's
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

## Standalone bundle

After staging the root native setup, run `bun run build:binary` from the root.
`dist/bundle/` contains the executable, native libraries/helpers, Pi's Photon
WASM sidecar, the project license, and combined MLX/inference third-party notices.
Move the whole directory together. Web assets and the memory skill
are embedded; source checkouts retain their existing asset readers and browser
build fallback. No terminal Pi assets are included.

`bun run verify:binary` builds into temporary storage, relocates the directory,
and checks the actual CLI and managed child plus a compiled consumer for web,
memory, synthetic registry/fit, native path resolution and Photon initialization.
The default performs no MLX/GPU operation or remote download. Mac CI runs this check.
With exclusive GPU access, `bun run verify:binary --model /path/to/cached-model`
also starts the actual relocated executable, checks its web assets, `/stats`,
`/fit`, and a chat completion, then requires a clean SIGTERM exit. It discovers
the supplied weights through a temporary HF snapshot symlink and isolates the
child's home, caches, and chat storage; it never copies or downloads weights.
This is a local build artifact, not signing/notarization or release publishing.
