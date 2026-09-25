# mlx-bun app

The runnable terminal app, server, and web surfaces live here. Default startup
loads a local model and serves the browser app, Pi web chat, and OpenAI-compatible
completions through one continuous scheduler. Model-management commands remain
available separately: `get`, `scan`, `ls`, `fit`, and `gc`.

After the root native setup, run `bun run --filter mlx-bun build:web`, then
`bun apps/mlx-bun/src/cli/main.ts serve --model <cached-model-or-directory>`.
Use `serve --help` for accepted options. A terminal session opens the browser
unless `--no-open` is supplied. Startup without a model selects a cached model;
if none is supported, it downloads the starter and then the recommended model.
Known unfinished features return HTTP 501 during migration; their remaining
work is tracked in [PLAN](../../PLAN.md). Unknown routes return 404.

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
`flush` also supports explicit durability checks while the app is running.
Cache policy tests inject storage and allocator ports; real SSD/numerical runs
remain separate verification.

## Server seams

`server/routes.ts` composes chat/text completion, embedding, and discovery
handlers over an injected engine. Its `handle(Request)` returns a response or
`null` for the next application surface; it never opens a socket or closes the
borrowed engine. Application startup owns those lifetimes.

Inside `server/`, request parsing and prompt preparation precede the single-use
admission plan. The completion executor consumes the engine contract; the sink
and OpenAI wire modules own reasoning/tool/content events, JSON, and SSE.
`prompt-contracts.ts` describes owned media inputs; `media-prompt.ts` adapts
HTTP content parts to the library's numerical input builders. Grammar and media
work enter the engine's preparation domain before allocating native resources.
Text-only protocol work loads no MLX library.

The [request pipeline](tests/server/pipeline.test.ts) and
[HTTP examples](tests/server/routes.test.ts) execute with an injected engine,
including cancellation and ownership cleanup. Real-weight media and generation
verification remains separate; these tests prove the HTTP/engine boundary.
`server/start.ts` mounts HTTP, browser, and WebSocket handlers. Shutdown cancels
chat, closes connections, drains execution, flushes caches, and releases the
model. Its [listener tests](tests/server-start.test.ts) exercise real loopback
sockets without native MLX. The opt-in [model test](tests/engine/http-generation.test.ts)
uses `MLX_BUN_APP_TEST_MODEL=<cached-directory>` to exercise actual app startup,
lone/concurrent deterministic completion, stream cancellation, and shutdown.
It never downloads weights; missing native libraries or an invalid supplied
checkpoint fail. This is a behavior check, not an oracle or performance claim.

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
need no build step. Static HTML, theme, manifest, worker, and icon live in
`src/web/public/`. The vendored highlight.js bundle retains its BSD license in
`public/vendor/hljs-LICENSE`; its existing header records upstream provenance.

[Browser behavior tests](tests/web/browser.test.ts) cover streaming rendering,
escaping, attachments, panels, and interactions without a live server.
[Static tests](tests/web/assets.test.ts) exercise the built bundle and asset
headers. The packed consumer check verifies the same assets after installation.


## Jobs and quantization

`jobs/` owns the lazily opened SQLite store, durable NDJSON events, SSE tails,
and managed subprocess lifetimes. `quantize/` owns submitted quantization policy
and CPU-only model inspection; the numerical work uses `@mlx-bun/quantize`.
`cli/job-entry.ts` resolves the producer in the child process. HTTP parsing and
wire responses stay in `server/job-routes.ts` and `server/quantize-routes.ts`.

Composition injects the engine execution lease. A job drains active inference
and holds that lease until its child exits and output streams finish; inference
then resumes. As in main's direct-process server, resident model weights and
caches remain allocated while the child runs. Shutdown stops queued jobs, aborts
admission waits, terminates active children, and awaits them before closing the
store and engine. Opening the app does not create the job database until a job
route is used. Dataset, finetune, and artifact publishing remain separate work.

[Job lifecycle tests](tests/jobs/lifecycle.test.ts) exercise leases, crash/error
paths, shutdown, HTTP/SSE, and a real CPU-only child with temporary storage.
[Quantization policy tests](tests/quantize/policy.test.ts) verify option forwarding
and output naming with an injected numerical operation. They do not run or
establish parity for actual checkpoint quantization.
