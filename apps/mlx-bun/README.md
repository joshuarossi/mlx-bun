# mlx-bun app

The runnable terminal app, server, and web surfaces live here. The first slice
provides model-management commands: `get`, `scan`, `ls`, `fit`, and `gc`.
Server and default web startup are still being migrated; running without a
command reports that limitation instead of silently doing something else.

`src/cli/main.ts` dispatches commands; `args.ts` owns accepted options and help;
`hub.ts` owns model-management presentation; `terminal.ts` owns formatting.
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
The returned continuation services and adapter namespace are borrowed by the
engine. Pass its `close` through the owned `beforeModelDispose` hook so shutdown
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
Server listening, application startup, additional API surfaces, and the web UI
are subsequent migration slices.

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
while a prompt is running. The [lifecycle examples](tests/chat-backend.test.ts)
exercise startup failure, disconnects, cancellation, and shutdown without a
server or native libraries; [chat behavior tests](tests/chat-policy.test.ts)
cover history, sampling scopes, thinking events, tool-loop policy, and UI tools.

Memory is disabled until its app owner supplies tool definitions, names, skill
paths, and its prompt hint through `PiBackendOptions.memory`. Download context
is an optional callback from app composition. Browser assets and HTTP/WebSocket
route wiring remain separate migration work. Standalone Pi integration remains
deferred. The protocol exposes no serial-serving lane selection.
