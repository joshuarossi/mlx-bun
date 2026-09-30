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
A route a surface does not mount returns 404, as do main's lab pages
(`/curves`, `/curve-terrain`, `/dag`, `/generate`, `/signal`): they are not
product surface. A request shape the engine cannot run returns a typed 501
(`UnsupportedExecutionError`); remaining work is tracked in
[PLAN](../../PLAN.md).

Main's admission and runtime flags keep their units and semantics: `--memory-budget`
(decimal GB) is the usable envelope for model load, request admission, the process
allocator limit, optional cache residency, and `/stats.admission.memory_budget_bytes`;
`--context-length` feeds the context reservation of runtimes that plan memory up front and other models ignore it;
`--force-wire` and `--allow-private-media` set their library runtime switches for
the serving process; `--expert-offload` builds `<model>/.mlx-bun-offload` on first
use and activates it before construction for MoE models, while dense models log
and continue; the `--hlg-*` family sets the HLG sampling default; and
`MLX_BUN_SHUTDOWN_TIMEOUT_MS` (finite, positive, else 120 s) bounds shutdown.
The process-wide settings an app applies (offload routing, the allocator limit,
the runtime switches) are restored after its engine releases the model, on close
and on startup failure, so a later app in the same process starts from what it
found; offload restore only redirects routing and never unmaps borrowed weights.
`serve` and `generate` accept numerical presets: `--l1` selects KV off
and unfused SDPA; `--l2` selects model-config KV and fused SDPA, and wins if both
are given. An explicit `--kv-quant` overrides the preset and sets the kernel
default (fused for `config`, unfused otherwise); `--fused-sdpa on|off` overrides
that default. The policy is resolved before model loading, including in isolated
model workers, and restored on shutdown or startup failure.

`--adapter <dir>` (alias `--adapter-path`) mounts a LoRA adapter right after the
model loads, before any request, under the directory's basename as its id; it
becomes the default for requests without an `adapter` field, an explicit
`adapter` (including `"none"`) still wins, `/v1/adapters` lists it, and a bad
directory fails startup with `adapter mount failed: …` after releasing the
model.
The opt-in [startup adapter test](tests/engine/startup-adapter.test.ts) produces
a three-step adapter with the fine-tune producer and serves with it; the opt-in
[DiffusionGemma adapter test](tests/engine/diffusion-adapter.test.ts) serves a
saved denoising adapter (hot mount and unmount, per-request selection, an
adapter row beside a base row, the startup default).
Main's speculative flags are restored with its validation: `--draft-model`
resolves like the main model (a query never downloads) and its kind is
auto-detected, `--draft-kind` overrides it (`ngram` is model-free; `mtp` alone
mounts the bundled companion), `--num-draft-tokens`, `--ngram-max`/`--ngram-min`
(ngram only; otherwise a warning), and `--mtp on|off` for checkpoints that carry their own draft head.
The opt-in [draft flags test](tests/engine/draft-flags.test.ts) serves with
ngram drafting and checks the speculation telemetry and exactness against a
plain run.
`--paged-kv` (env mirror `MLX_BUN_PAGED_KV=1`) with `--paged-kv-block-size`
(only alongside paging) sets the paged KV request default; Gemma4-family
requests use the paged path and other families answer the typed capability
error, never a hidden serial lane.
Startup rejects paging combined with a loaded draft, per-layer KV quantization,
or TurboQuant; bf16 and uniform KV4/KV8 remain supported.
As main's server did, startup also rejects `--kv-quant turbo` when the model's
full-attention head dimension is not one the TurboQuant codec encodes
(`TURBOQUANT_HEAD_DIMS`), before any request, instead of failing each request in
prefill.
Startup, and `generate`, also reject a requested KV scheme the model's cache
layers cannot take, since every request carries it: GLM-5.2's MLA cache takes no
KV scheme, so `--kv-quant 4|8|turbo` (and `config` or `--l2` when a
`kv_config.json` exists) is refused there; main accepted the option and served GLM-5.2 in bf16
while reporting the requested scheme.
`--kv-quant config` without the model's `kv_config.json` stays bf16.
The opt-in [paged KV test](tests/engine/paged-kv.test.ts) covers both family
outcomes.

Shutdown stops background cache demotion, closes chat sessions, drains active
HTTP responses, then flushes caches and releases the engine. The CLI bounds this
with a 120-second deadline; cleanup failures or deadline expiry exit with code 1
(main exited 0 on timeout). SSD sub-options fail before model loading when saved
state is off (`--ssd-cache off` or `--prompt-cache 0`) instead of warning and being ignored. The existing
`MLX_BUN_RD_CONTEXT_LIMIT` cap remains supported and is intersected with a loaded
loaded runtime memory plan; this draft adds no serving context or read-only CLI flags.
Programmatic composition still accepts explicit context and read-only policy.

`src/cli/main.ts` dispatches commands; `args.ts` owns accepted options and help;
the model-management verbs (`get`, `ls`, `scan`, `fit`, `gc`, `upload`) are the models module's; `terminal.ts` owns formatting.
`model-selection.ts` owns automatic selection policy; its pure choices live in
`model-choice.ts` ([`mlx-bun/selection`](#selection-entry-mlx-bunselection)).
`serve.ts` parses the serve flags and owns the process; its composition is
split in two halves:
`serve-state.ts` creates the persistent, CPU-only state that outlives a loaded
model (web assets, the download owner, Responses history, memory, jobs,
sessions, credentials, and their routes) and never imports the engine or a
native module at runtime; `serve-host.ts` creates the model-scoped host,
borrowing that state by parameter and lending it an execution lease, library
invalidation, and the bound port through an attached link. Its
`startModelHost` is the CLI's loader (runtime switches, expert offload, the
model context, the startup adapter) and hands the context to
`startContextHost`, which serves it and any other local model (below): the model
host, the Whisper companion, the model router, the Pi backend, and the listener.
A loaded model is a serving unit (`serving-unit.ts`: binding, caches, engine and
the routes bound to them); the host releases each by the ownership it is given.
`startApp` (`serve.ts`) composes the state and one host with one close in the
app's order; `startModelServer` and
[`mlx-bun/server`](#server-entry-mlx-bunserver) use it.

### Model host: residency by memory fit

`residency/model-residency.ts` implements the `modelHost` contract (`@mlx-bun/app-core`)
for models that generate, over units it does not know the kind of: a loaded model
(`--in-process`) or a worker process that holds one (the default,
[Runtime isolation](#runtime-isolation-the-default)). Residency is by memory, not count: a model that fits
the budget loads beside the others; otherwise the least recently used unpinned,
unleased model is drained (admission stops, work in flight ends), its saved
prompt/KV state is flushed durably under `MLX_BUN_HOME/kv`, and its weights are
released, all before the newcomer loads, so resident bytes never exceed the budget
during a swap. Acquiring it again reloads it, and the next request finds its
prefix by token match in the saved state (a swap-back follow-up reports the
prior conversation as `cached_tokens`). A request for a model that cannot fit
while every other model is busy waits, and never evicts one mid-request. A model
bigger than the whole budget is still served alone. The budget is `--model-budget`
(decimal GB; default 70% of the device's recommended working set, one rule for both
compositions: `defaultBudgetBytes` in `residency/resident-estimate.ts`, or of the RAM the
GPU can wire, as `/fit` does, when the device does not say); a model that is not loaded needs
its weights plus the KV and prefill working set of an 8k context (`residency/resident-estimate.ts`,
the `/fit` model) and, once loaded, what it
reports it holds (weights, projected KV, RAM prefix cache), floored by the process's measured
MLX active memory. A runtime that plans its own memory is served alone. The Whisper companion
counts against the budget and, when it loads, drains a chat model to make room;
`--whisper-resident` pins it (it is never a victim).

`server/model-routes.ts` routes by the request's `model`: an exact local id (the ids
`GET /v1/models` lists) leases that model, and the response body holds the lease until
it ends, so a model is never released under a stream. Anything else (no id, Pi's `local`,
a name another server would know) is the current model's, as is every other model-scoped
path (`/stats`, `/fit`, cache administration, adapters). The current model is the one the
server started with until `POST /api/hub/serve` (the Models panel) or another
switch makes a different one current; naming a model in a request never changes it. `GET /v1/models`
lists every local model with `resident` and `current` (the models module's `/library` marks `serving` and `resident` from the host's own residency); `GET /stats`
adds `models` (budget, resident bytes, each resident model's bytes, leases and last use).
Managed jobs and Whisper decoding pause every resident model (`pauseAll`) and hold back new
loads meanwhile. The host publishes `model.load` (with `resumed` when saved state was found),
`model.unload` (reason `evicted` or `requested`, whether the flush was durable) and `model.memory`
on the app's `events` bus, and each unit's engine publishes its request timings and samples through
`engine/telemetry.ts`; the persistent services' `modelHost` (`served-model-host.ts`) leases the
current model, whose id follows a switch.

`--draft-*`, `--adapter` and `--mtp` belong to the model named at startup and apply
whenever it is (re)loaded; the other models load plain. Adapters mounted at runtime are
lost when their model is evicted. `--expert-offload` routes the process's loads through one
file, so that model is all the process serves. A host built with `createServer` around a
caller's context serves only that context (never evicted); `POST /api/hub/serve` then still
answers that a restart is needed. The [residency tests](tests/residency/model-residency.test.ts),
[router tests](tests/server/model-routes.test.ts) and the opt-in
[native test](tests/engine/model-host-native.test.ts) (the default isolated mode and `--in-process`)
cover it.

Worker mode serves over a Unix socket a parent supplies, in another process.
`jobs/worker-process.ts` is the parent-side owner: it spawns the executable
captured at startup as `__worker` in the compiled binary or the entry script in
source runs (or `[...command, "__worker"]` for an explicit mlx-bun command),
writes the launch record as the first stdin line, reads the ready line from
stdout, and stops the worker with SIGTERM, then SIGKILL after a grace; the end
of stdin means the parent is gone. `cli/worker-entry.ts` takes two private
launch forms, and no flag selects either:

- The model form `{ version, socketPath, model, options }`, sent by the default
  isolated `serve` (one worker per resident model), runs `startModelHost` alone,
  for that one model, with the persistent services stubbed because the parent
  owns them.
- The app form `{ kind: "app", version, socketPath, argv }` runs serve
  arguments (`["--model", model, ...]`) through the CLI's `parseCommand` and
  `runServe`, so the whole app listens on the socket instead of TCP.
  `openIsolatedHost` ([`mlx-bun/engine`](#engine-entry-mlx-bunengine)) sends
  it. `validateAppLaunchArgv` (`serve.ts`) is the CLI's strict
  parse with three differences: `--host`, `--port`, and `--no-open` are
  accepted and never steer the socket bind; the app always loads its models in
  its own process (`--in-process` is implied and `--isolate` is ignored), because a nested
  isolated app would bind TCP instead of the socket; and a
  missing or empty model is refused, because automatic selection may download
  the starter model. SIGTERM, SIGINT, or the end of stdin during startup
  aborts through runServe's startup signal and announces nothing. After ready,
  any of them runs runServe's shutdown under the CLI's deadline
  (`MLX_BUN_SHUTDOWN_TIMEOUT_MS`, default 120 s), and its exit code is the
  worker's. `openIsolatedHost` passes that budget to the supervisor as
  `drainTimeoutMs` and `graceMs` (the supervisor's defaults, 10 s and 3 s,
  serve the model form).

`server/worker-routes.ts` answers `GET /health`, `POST /admin/lease`,
`POST /admin/drain`, `POST /admin/memory/complete` and `GET /admin/events` (the
worker's own event stream, NDJSON) ahead of the routes on
the socket only: a TCP listener answers 404 for all of them, and `/engine`
under `--in-process` is 404 too. In the app form its `/health` replaces
discovery's, and the transcription-only app, which has no execution lease, has
no `/admin/lease` route (404). The memory route (see
[Memory synthesis](#memory-synthesis)) is the model form's: the app form's
synthesis runs in the app itself, so there it is 404.

Both launch forms and the ready line carry the app's package version (the one
`--version` prints). A worker exits 2 with `worker protocol version mismatch`
when the launch record carries a different package version. The check compares
package versions only: it detects a different package version, and two builds
with the same package version are not told apart. The parent rejects a ready
line that does not echo its version, and a worker's exit 2 (a refused launch
record) puts the worker's last stderr line into the rejection.

In the app form, memory synthesis runs on the app's own task model, as in
`serve`, and dataset jobs reach the model through the attached host's own
`/v1/chat/completions` over its socket (the request's
`127.0.0.1:<--port>` is a placeholder), so they call the same app. Pi web chat
does not: its SDK takes a base URL rather than a fetch, so it targets TCP
`127.0.0.1:<--port>`, as in the model form and main. An embedding host that
forwards Request/Response pairs cannot carry `/ws/chat` either, because it is a
WebSocket upgrade.

The app form opens the CLI's user stores under HOME. Its first jobs request
opens the jobs database and marks every queued or running job as a zombie,
including another server's. The vault, sessions, skills, and credentials are
shared without locks, and a worker's job children are not stopped when the
worker crashes. These behaviors predate the app form and match main. Tests
compose the app form with a temporary HOME and every storage override.

## Runtime isolation (the default)

`serve` runs one worker process per resident model and keeps the app up in this
process, which loads no model; `--in-process` opts out and loads the models in the
serving process (the composition every earlier release had). `--isolate` is
accepted, ignored, and warns: it is the default now. Crash isolation is the point: a
model that crashes the native runtime takes down its own worker, not the app or the
other models. It costs a process per model and a loopback hop per request.

**Process layout.** `serve.ts` resolves the model as usual, then `startModelServer`
composes `cli/serve-isolated.ts` instead of the direct host: the same persistent
`createAppState` (web app, download owner, Responses history, memory, jobs,
sessions, credentials, publishing), the model router and a proxy, and one worker per
resident model (`cli/worker-unit.ts`), each supervised by `jobs/worker-supervisor.ts`
over `jobs/worker-process.ts` on its own Unix socket. A worker's launch record pins
its model by path and carries the parsed serve options (draft and Whisper queries
already resolved, `isolate` cleared, `inProcess` set; `--draft-*`, `--adapter` and
`--mtp` go to the startup model's worker only), so a worker never re-resolves a query;
every exported `MLX_BUN_*` variable reaches it unchanged (that includes
`MLX_BUN_HOME`, so every worker shares `kv/`), and its output is forwarded to this
process's log with a `[worker]` prefix. Sockets live in a private `mlx-worker-*`
temp directory (0700, socket 0600) that this process removes on close. This process
loads no engine or native module: `serve.ts` imports the model half only inside the
in-process composition, and the [composition test](tests/serve-isolated.test.ts)
gates both the static closure and the runtime with tripwire mocks.

**Residency.** This process runs the same residency manager as `--in-process`
([Model host](#model-host-residency-by-memory-fit)) over workers. A model that
fits `--model-budget` gets a worker beside the others; otherwise the least recently
used unpinned, unleased model is drained (`POST /admin/drain`, then SIGTERM), its
worker flushes its saved state and exits, and only then does the newcomer's worker
spawn, so resident bytes never exceed the budget. A worker gets the CLI's shutdown
budget (`MLX_BUN_SHUTDOWN_TIMEOUT_MS`, default 120 s, for the drain and again for
the stop) and is never killed before its flush is durable; it exits 0 when the flush
was durable and 3 when it was not, which the `model.unload` event reports as
`flushed`. Naming an evicted model again spawns a worker that resumes from
`MLX_BUN_HOME/kv` (`cached_tokens` on the next turn). Each worker measures its own MLX
memory (active, cache and peak bytes, and the device's recommended working set), since
this process loads no native module: it reports them on `/health` (`memory`) and as a
`worker.memory` line in its `/admin/events` stream at connect, on each second it changed,
and after every finished request (the line is consumed here, never republished on the
bus). A worker counts as active plus cache bytes from its first report (never below the
weights it reported: MLX maps weights lazily, so a worker that has not run yet reads low),
in place of the `/fit` estimate, which stands only before that report (a model that has not
loaded yet needs its estimate) and again while the worker is down. Before it decides who
fits, the residency manager asks every resident worker for a current reading (`GET /health`),
so a reading the stream has not delivered yet still counts; `/engine` and `/health` list each
worker's `memory` (`active_bytes`, `cache_bytes`, `peak_bytes`, or `null`), and
`GET /stats` `models` counts the measured bytes. The default budget is 70% of the working
set the startup model's worker reports, the in-process rule (`--model-budget` overrides it).
A consumer that runs long on a worker holds that model's residency lease for as long as
it runs, so the worker is never drained under it: memory synthesis (a run holds the current
model's lease from its first stage call to its last; in-process it runs on its own task model and
holds none) and, in either composition, modules that generate through the model host (each
`modelHost` lease on the served model holds the residency lease until it is released). Whisper is a worker of its own (the
transcription-only server, `--whisper-resident` pins it), started on the first audio
request and drained like a chat model when memory is short.

**Readiness.** The listener binds after the startup model's worker reports ready (up
to 15 minutes for large models, as main), so startup succeeds or fails the way the
in-process composition does: a worker that dies before its first ready line rejects
startup with its exit and is never retried; the browser opens once the model serves.
Other workers spawn when a request or the hub names their model, and that request
waits for the ready line. The Pi backend learns the current model's capabilities,
generation defaults, and enforced context window from its worker's `/v1/models` and
`/stats`, again after each switch, and again for a respawned worker.

**Application state.** The web app, Pi chat, the Responses history, jobs,
downloads, sessions, memory (the vault and the synthesis pipeline; its task
model is the current worker's), tool-approval settings, and the models module (library, hub, adapters and cache cleanup,
which protects the snapshot of every resident worker's model and the task model snapshot
selected for a worker, kept for that worker's lifetime: each resident model reports its `uses`) live here and survive worker
restarts. Pi runs in this process and reaches the models over loopback HTTP through
the proxy, so web chat works under isolation (main answered 501 on `/ws/chat`); its
`local` model is the current one. Managed jobs pause every resident worker through
each worker's execution lease.

**Routing and proxying.** `server/model-routes.ts` is the same router as in-process,
over worker units: a model-scoped POST is leased to the worker of the model its body
names (the lease lasts until the response ends, so a stream is never cut by an
eviction), anything else is the current model's, `GET /v1/models` and
`/stats` add residency, and `/v1/audio/*` and `/admin/transcription/*` go to Whisper's
worker. `server/proxy-routes.ts` is one route group mounted after the persistent groups:
the hop-by-hop headers are stripped, bodies stream through unchanged, a client abort
aborts the proxied request (`499`), and a worker that cannot take a request answers
`502 { error: { type: "engine_unavailable", state } }`. `POST /v1/responses` goes
through `server/responses-client.ts`: `previous_response_id` resolves against this
process's store, the worker receives the resolved conversation without one (and the
`x-mlx-bun-response-owner: parent` header), and the completed record is remembered
here, so conversations survive a worker restart. This process answers `GET /engine`
(`{ isolated, state, pid, restarts, socket, model, last_exit, response_store, workers }`,
the current model's worker first and `workers` listing every resident one with its
`id`, `role`, `pid`, `state`, `restarts` and `socket`; `state` is `starting`, `ready`,
`restarting`, `exhausted`, `closed`, or `none` when no worker is resident),
`GET /health` (`{ status: "ok", isolated, engine, workers }`), `GET /stats` (the current
worker's body with the residency block, this process's `response_store` and an `engine`
report; with no worker, 200 with only this process's part and an `unavailable` message),
and `/admin/lease`, `/admin/drain`, `/admin/memory/complete`, `/admin/events`, `/admin/adapters` and
`/v1/memory/synthesize` stay socket-only or this process's own and are not forwarded. The hub's `POST /api/hub/serve` is answered here: it acquires the
model (spawning its worker, draining another when memory is short) and makes it current;
`404` for an id that is not local, `502` for a failed spawn.

**Events.** Each worker publishes its engine's events (request timings, samples,
prefix and KV counters, load progress) on its own bus and serves them on
`GET /admin/events`; this process subscribes to every worker's stream and republishes
onto the app's bus, so the metrics module sees all of them. The residency manager
here reports `model.load`, `model.unload` and `model.memory` (a worker's own load and
unload events are dropped), and a respawned worker's stream is resubscribed.

**Crashes.** A worker's unexpected exit is respawned by its supervisor with that
worker's model (the one that was resident, not the startup model) within main's
budget: at most three restarts in a rolling 60-second window. A worker respawns at once
after a single crash, even one within 10 seconds of its spawn; a worker that dies within
10 seconds of its spawn again straight after such a death waits 5 seconds before the retry. The other workers
and the app are untouched. A managed job's execution lease is a connection-owned
`POST /admin/lease` inside each worker, so a respawn waits until it is released and a
reload never shares the GPU with a job. Requests in flight when a worker dies end with
`502`; an SSE response ends with the protocol's own error frame naming the cause
(OpenAI `data: {"error"}`, Anthropic `event: error`, Responses `event: error`), so a
client parser ends with an error rather than a silent truncation and Pi ends the turn
with an error frame instead of replaying the generation. While a worker is down,
new requests for its model answer 502 with the reason and `- retry shortly`; a worker
that exhausts its budget is reported `exhausted` and is replaced by a fresh spawn on
the next request that names its model (a broken unit is evicted, never leased). The
[supervisor](tests/jobs/worker-supervisor.test.ts), [proxy](tests/server/proxy-routes.test.ts)
and [composition](tests/serve-isolated.test.ts) tests drive these paths against a fake
worker over a real socket; the opt-in [native test](tests/engine/model-host-native.test.ts)
kills a real worker mid-request.

**Shutdown.** Synthesis runs, jobs, and downloads stop while the workers are alive, chat
sessions and HTTP responses drain, then every worker is drained, sent SIGTERM (killed
only after the CLI's shutdown budget), and joined, and the socket directory is removed; a
respawn in progress is joined too. A worker's own close aborts and joins its memory calls,
then closes its task model, before its engine.

**Deviations from main.** Main bound the listener before the engine loaded and
made every request wait on readiness, including across restarts, retrying bodyless
GET/HEAD once; here the listener binds after the first ready line and a request
during a restart fails fast with 502 so the UI can report the restart instead of
hanging, and nothing is retried. Main answered 501 on `/ws/chat`; Pi lives in the
parent here. Main's parent `/health` was the child's; here it is this process's with
the workers'. Pi's own SDK policy still retries a request refused with 502 before
generation started (three attempts, 2/4/8 s), which rides out a fast respawn; a
generation that started is never replayed. A Whisper checkpoint as the main model
serves the transcription-only server in this process, as before.

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

## mlx-lm compatibility (`mlx-bun.<cmd>`)

mlx-bun is a superset of mlx-lm's command line under its own names. Each alias
runs the matching verb with `mlx_lm.<cmd>`'s argument spellings translated, and
still accepts the verb's own options; `mlx-bun.<cmd> --help` lists what it maps,
accepts without effect, and refuses. An explicit path behaves as in mlx-lm; a
default output path does not use the working directory (`mlx_model`,
`fused_model`, `adapters`) but stays under `~/.mlx-bun`, and every other default
is the verb's, not mlx-lm's (for example `generate` stops at 256 tokens, not 100).

| Alias | Verb | mlx_lm flags translated |
| --- | --- | --- |
| `mlx-bun.server` | `serve` | `--model --adapter-path --host --port --decode-concurrency --max-tokens --temp --top-p --top-k --draft-model --num-draft-tokens`; headless (`--no-open`) unless told otherwise |
| `mlx-bun.generate` | `generate` | `--model --prompt/-p (- reads stdin) --max-tokens/-m --temp --top-p --top-k --min-p --min-tokens-to-keep --xtc-probability --xtc-threshold --seed --system-prompt --adapter-path --ignore-chat-template --kv-bits (4 or 8, from token 5000) --trust-remote-code --verbose` |
| `mlx-bun.convert` | `convert` | `--hf-path/--model --mlx-path -q --q-bits --q-group-size --dtype -d/--dequantize --upload-repo --trust-remote-code` (4/8-bit, group 32/64, affine) |
| `mlx-bun.fuse` | `fuse` | `--model --adapter-path --save-path --dequantize --upload-repo` |
| `mlx-bun.lora` | `train` (SFT) | `--model --train --data --fine-tune-type lora --optimizer adam/adamw --num-layers --batch-size --iters --val-batches --learning-rate --steps-per-report --steps-per-eval --grad-accumulation-steps --resume-adapter-file --adapter-path --save-every --max-seq-length --grad-checkpoint --seed --mask-prompt -c/--config` (YAML) |
| `mlx-bun.upload` | `upload` | `--path --upload-repo` |

Not supported, each an error naming the mlx_lm flag: `generate` `--extra-eos-token
--prefill-response --use-default-chat-template --chat-template-config
--max-kv-size --prompt-cache-file --quantize-activations --draft-model
--num-draft-tokens`, `--kv-bits` other than 4/8, `--kv-group-size` other than 64;
`server` `--allowed-origins --log-level --chat-template --use-default-chat-template
--chat-template-args --min-p --prompt-concurrency --prefill-step-size
--prompt-cache-size --prompt-cache-bytes --pipeline`; `convert` `--quant-predicate`
and `--q-mode` other than affine, `--q-bits` other than 4/8, `--q-group-size` other
than 32/64; `fuse` `--export-gguf --gguf-path`; `lora` `--test --test-batches`,
`--fine-tune-type dora|full`, optimizers other than adam/adamw, `--clear-cache-threshold
--report-to --project-name`, and the YAML keys `lr_schedule` and `lora_parameters.keys`.
argparse's unique-prefix abbreviations (`--max-tok`) are not accepted. Two behaviors differ without an error: `mlx-bun.lora` always masks the prompt in the
loss (mlx-lm does so only with `--mask-prompt`), and `--trust-remote-code` is
accepted because mlx-bun never runs code from a model repository.

mlx-lm's other console scripts have no counterpart and get no alias: `chat` (no
terminal chat; use the web app), `benchmark`, `cache_prompt`, `evaluate`,
`perplexity`, `manage`, `share`, and the quantizers `awq`, `dwq`, `dynamic_quant`
and `gptq` (`convert --target-bpw` is the mixed-precision path).

Delivery: the package's `bin` links `mlx-bun.<cmd>` to `bin/mlx-bun.<cmd>.mjs`, a
one-line file that runs the shared launcher (npm and Bun resolve a bin to its real
file, so the file's name is the invoked name); the standalone executable
dispatches on the name it was started as; `scripts/install.sh` links each alias
to the same executable beside `~/.local/bin/mlx-bun`, and `bun run link-cli`
links them into `~/.bun/bin`. [Alias tests](tests/mlx-lm-aliases.test.ts) run
mlx_lm's own argument forms through each alias and the launcher files;
[installer tests](tests/install.test.ts) cover the links.

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
than running a hidden serial path. Diffusion models are served through the same
scheduler by the library's interleaved denoising method. An image request's pixels
ride its options, and the gateway releases them exactly once, whether the row
settles or fails before submission. Requests the method cannot apply (grammar,
draft, logprobs, logits processors, fill, encoded or paged KV) receive the typed
capability error.

`engine/cache-services` composes the library prompt cache and persistence. Its
default is 8 GB of RAM with plain KV; a caller supplies `ssdCacheDir` for saved state.
`mlx-bun serve` supplies it by default (`MLX_BUN_HOME/kv`, `--ssd-cache <dir>` moves it,
`off` disables it): one directory per model identity under the root, and
`engine/kv-budget.ts` holds one byte budget across all of them (`--ssd-cache-max`,
default 20 GiB, 0 unlimited). A live store is lent what the other stores and idle
directories leave (never less than a quarter of the budget); a closed store's
directory is idle, and idle directories lose their oldest files first, at start and
after every close. A model that returns finds its directory, and its prefix, intact.
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

`server/management-routes.ts` owns tool-approval settings over the chat approval store; startup shares
`ServeOptions.chatPaths.toolApprovalsFile` with Pi and the settings routes. Confirmed cache
cleanup (`/api/gc/*`) is the models module's, over the hub library and the model host's resident models.
The [management tests](tests/server/management-routes.test.ts) use isolated approval files.
Hugging Face credential and upload routes are described under publishing below.

Inside `server/`, request parsing and prompt preparation precede the single-use
admission plan. The completion executor consumes the engine contract; the sink
and OpenAI wire modules own reasoning/tool/content events, JSON, and SSE.
`prompt-contracts.ts` describes owned media inputs; `media-prompt.ts` owns the
HTTP media policy (which content parts are present, the video guard, and the 400
text for each refusal) and delegates to the loaded model's media preparation.
`engine/media-preparation.ts` binds one route per family when the model loads;
each route borrows the context's tokenizer, template, token ids and lazily loaded
towers and calls the library's numerical input builders. The opt-in
[native media test](tests/engine/media-native.test.ts) (`MLX_BUN_TEST_NATIVE=1` plus
`MLX_BUN_APP_TEST_GEMMA4_AUDIO_MODEL`, `MLX_BUN_APP_TEST_GEMMA4_UNIFIED_MODEL`,
`MLX_BUN_APP_TEST_QWEN_VISION_MODEL` or `MLX_BUN_APP_TEST_DIFFUSION_MODEL`, each a
cached snapshot directory) prepares image, audio, mixed and video prompts through a
loaded model with synthesized media and a warm encoder cache; the opt-in
[media generation test](tests/engine/media-generation.test.ts) serves the same
Gemma4 checkpoint and generates from image, audio and mixed image+audio prompts
(determinism, streaming, rows released together, disconnect recovery). Grammar and media
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

The opt-in [paged KV test](tests/engine/paged-kv.test.ts) also covers Gemma4
HTTP cancellation for each paged reader: the gathered reader and the direct
reader that `MLX_BUN_PAGED_ATTN=1` selects (read, like every `MLX_BUN_` switch,
into the runtime snapshot from the environment). A client leaves a greedy
`/v1/completions` stream mid-generation; the server observes the disconnect, the
row stops storing tokens before its natural end, and the scheduler drains. The
same server then answers another prompt and the abandoned one exactly as a fresh
paged server with the same reader does, and the frames the client received equal
a control stopped (`max_tokens`) at the token that published the last of them.
Every paged cache in the case uses the selected reader; both servers run without
the RAM prompt cache so every compared request prefills cold. Run with
`cd apps/mlx-bun && MLX_BUN_COMPILED_GEMMA_E4B=<cached Gemma4 snapshot directory> bun test tests/engine/paged-kv.test.ts -t "reader"`.

`server/status-routes.ts` borrows live cache, scheduler, model diagnostic and
Responses-history counters for `GET /stats`; `GET /fit` uses the public inference
fit functions (`@mlx-bun/inference/execution/fit`) and the served artifact metadata. Predictions remain advisory and do
not impose an admission limit. A runtime that plans its own memory reports that
plan (`/fit`'s `plan` object lists its streamed tiers and generation allowance;
`/stats.runtime` carries the runtime's own telemetry) instead of the generic
resident-weight estimate. Batch mode remains
continuous even at capacity one. Pending SSD counters include the generation
checkpoint queue as well as prompt-cache persistence work.
Historical EvalDB measurements have no migrated owner, so measurement fields
remain null; old machine-specific throughput constants are not reported as
measurements for the current server or CLI fit output. The library retains those
historical constants. The dashboard shows an unavailable marker
when no estimate exists. [Status tests](tests/server/status-routes.test.ts) use
synthetic counters and CPU fit inputs without a model or native MLX.

## Client entry (`mlx-bun/client`)

`mlx-bun/client` (`src/server/client.ts`) is main's embedding client. It
imports no other module, so it loads without native MLX. `mlx-bun/engine`
(below) re-exports it.

- `createCompletionClient({ baseUrl, headers?, host? })` posts to
  `<baseUrl>/chat/completions` (or `route: "completions"`) with the caller's
  `headers` merged with `content-type: application/json`, the body with
  `stream: false` forced, and the call's `signal`. The transport is the supplied
  host's `forward`, otherwise the global `fetch`; the host stays the caller's.
  A POST is never retried: a non-2xx status rejects with the status and response
  text, and a result without a `choices` array rejects.
- `createDirectHost(handler, shutdown?)` gives an in-process
  `(Request) => Promise<Response>` handler the same host shape. It is an adapter,
  not a model loader. `close()` refuses new work, waits for handlers in flight,
  then calls `shutdown` once; a handler owns any response stream it returns, and
  streams pass through unchanged.
- Types: `EngineHost`, `CompletionCall`, `CompletionResponse`, and main's
  completion contracts `CompletionClient`, `BatchCompletionClient` (ordered
  `completeBatch`), and `TaskClient` (`run` with progress and an optional
  `Cancellation`).

The [client tests](tests/client.test.ts) import the entry through the export
map with native MLX blocked; `verify-packages` repeats them from the installed package.

## Engine entry (`mlx-bun/engine`)

`mlx-bun/engine` (`src/cli/engine-entry.ts`) is main's `src/library.ts`
without `initializeMlx`. It loads without native MLX and starts nothing on
import. It re-exports the client above with its contract types,
`createInferenceEngine` and `CancellationSource` with main's generation
contract types from `@mlx-bun/inference`, and adds `openIsolatedHost`. Main's
`initializeMlx` and its native bootstrap were removed deliberately: the native
runtime ships inside the packages and loads on first use, so there is no
acquisition step to call and no root (`.`) namespace to return. Import each
member from its owner instead (the migration table below). The root's selection helpers are
`mlx-bun/selection` (below), and main's in-process server is
[`mlx-bun/server`](#server-entry-mlx-bunserver).

```ts
import { createCompletionClient, openIsolatedHost } from "mlx-bun/engine";

const host = await openIsolatedHost("/path/to/hf-snapshot", { arguments: ["--max-tokens", "256"] });
try {
  const client = createCompletionClient({ baseUrl: "http://engine/v1", host });
  const result = await client.complete({ body: { messages: [{ role: "user", content: "Hello" }] } });
  console.log(result.choices[0]?.message?.content);
} finally {
  await host.close();
}
```

The caller owns the host: `openIsolatedHost` starts one worker process in the
app launch form above, and `close()` stops it and removes its private socket
directory after it exits. The function's JSDoc states the argument, command,
retry, and close rules.

- `arguments` are `mlx-bun serve` arguments. `--host`, `--port`, and
  `--no-open` only concern a TCP listener and have no effect on the socket;
  `--isolate` is ignored, as the app form is always in-process.
- `command` must run the mlx-bun CLI of the same package version: the
  installed binary, `[bun, <package>/bin/mlx-bun.mjs]`, or
  `[bun, <package>/src/cli/main.ts]`. A compiled consumer must supply it,
  because its own executable is not the mlx-bun CLI. The version handshake
  refuses another package version but cannot tell apart two builds with the
  same version.
- The host forwards to the whole app, so the app form's limitations above
  apply: the user stores under HOME are shared with other mlx-bun processes
  without locks, Pi web chat targets TCP `127.0.0.1:<--port>`, and `/ws/chat`
  cannot pass through `forward`. These predate this entry.

The [engine tests](tests/engine-entry.test.ts) import the entry through the
export map with native MLX blocked and drive the host over a fake worker;
`verify-packages` repeats them from the installed package. The worker's own
refusal and startup behaviors are covered by C2a's
[worker-entry](tests/worker-entry.test.ts) and
[worker-process](tests/jobs/worker-process.test.ts) tests. The opt-in
[native test](tests/engine/library-host.test.ts) (`MLX_BUN_TEST_NATIVE=1` with
`MLX_BUN_APP_TEST_MODEL` and/or `MLX_BUN_APP_TEST_WHISPER_MODEL`) runs real
consumers, including a standalone CLI as `command`, under a temporary HOME;
its real-HOME check is a names-only guard.

## Selection entry (`mlx-bun/selection`)

`mlx-bun/selection` (`src/cli/model-choice.ts`) is main's pure model-selection
helpers from `src/fit.ts`. It imports no module, so it loads without native MLX.
It exports `DEFAULT_REPO_ID`, `STARTER_REPO_ID`, `COEXIST_FRACTION`,
`chooseAutoModel(candidates, preferredRepo, fitsFull, fitsCoexist)` (the
automatic rule `model-selection.ts` applies), and
`largestRecommendedRepoId(ramBytes)` (the 26B at 48 GiB or more, the 12B at
24 GiB or more, otherwise `DEFAULT_REPO_ID`; an explicit opt-in that automatic
selection never calls). Migrating from main's root: `recommendedRepoId()` is
`DEFAULT_REPO_ID`; `largestRecommendedRepoId()` is
`largestRecommendedRepoId(totalmem())` (RAM is now required); `chooseAutoModel`,
`COEXIST_FRACTION` and `DEFAULT_REPO_ID` import from `mlx-bun/selection`.

The [selection tests](tests/selection-entry.test.ts) import the entry through the
export map with native MLX blocked; `verify-packages` repeats them from the
installed package.

## Server entry (`mlx-bun/server`)

`mlx-bun/server` (`src/cli/server-entry.ts`) restores main's in-process
`createServer` and `loadContext`. It loads without native MLX and starts nothing
on import. `createServer` composes the app `mlx-bun serve` composes (`startApp`,
then `startContextHost`) around a context the caller loaded, so it serves the
full app: every HTTP route, the browser app, Pi web chat on `/ws/chat`, jobs,
hub, memory, sessions, and publishing. It parses no CLI arguments, installs no
signal handler, opens no browser, and downloads nothing. The function's JSDoc
states the option, ownership, and close rules.

```ts
import { createServer, loadContext } from "mlx-bun/server";

const context = await loadContext("/path/to/hf-snapshot", "my-model");
const server = await createServer(context, 8080, { hostname: "127.0.0.1", memoryBudgetBytes: 12e9 });
try {
  console.log(`API http://127.0.0.1:${server.port}/v1`);
} finally {
  const { stopped, durability } = await server.close();
  if (stopped) context.dispose();
  if (!durability.durable) console.warn("cache persistence incomplete", durability);
}
```

- Options are serve's settings under their programmatic names (`capacity`,
  `contextLimit`, `defaultGeneratedTokens`, `kvBudgetBytes`,
  `memoryBudgetBytes`, `cache`, `request`, `whisper`, `readOnly`, and the
  `memoryPaths`, `chatPaths`, and `storagePaths` store overrides). Defaults
  follow main's library: port 0 binds an ephemeral port, an omitted `hostname`
  binds every interface (tests pass `127.0.0.1`), capacity 8, bf16 KV, an 8 GB
  RAM prompt cache, and `MLX_BUN_RD_CONTEXT_LIMIT` as the context cap when set.
  User stores default to HOME and are shared with other mlx-bun processes
  without locks, as for the CLI.
- A supplied graph: `binding` (`ModelBinding`) replaces the built-in numerics
  and `buildPrompt` (`ModelPromptBuilder` returning `BuiltPrompt`) replaces
  chat prompt construction. Both reach the engine and routes as given, with no
  registry lookup, model class, or reload. A context without a chat template is
  refused (`model <id> has no chat template`) unless `buildPrompt` builds its
  prompts; such a builder returns `probeStableLen: false`. `artifact` (`path`,
  `sizeBytes`, `expertsBytes`) only describes the weights for `/fit`, `/stats`,
  and hub GC protection.
- Ownership: the context is borrowed by default, as in main. Close and every
  failed start release what the server created and leave the context usable,
  including for another server; the caller disposes it after close resolves
  with `stopped: true`. `ownership: "owned"` makes the server dispose it exactly
  once, after execution drains or when startup fails. The rule is
  `createAppEngine`'s `ownership` option (`releaseContext`,
  `engine/model-host.ts`), applied by the host and the entry until the engine
  takes the context.
- `close({ timeoutMs = 120_000 })` resolves `{ stopped, timedOut, durability }`
  with the final cache flush's result, `durable: false` included. One drain runs
  however often it is called. At the deadline it resolves `stopped: false,
  timedOut: true` with the pending counters and `durable: false` while the
  drain continues; nothing is released under running execution. `flush()`
  flushes cache persistence while serving.
- Process-wide state: the server applies no runtime switches and activates no
  expert offload; those stay with the process's runtime configuration and the
  CLI's loader. It sets the MLX allocator limit from a runtime memory plan or
  `memoryBudgetBytes` and restores the value it found on close and on a failed
  start. The limit is one per process: servers running at the same time share
  it and the last applied wins. Sequential servers over one context are
  supported. The Pi SDK's `proper-lockfile` registers `signal-exit`'s listeners
  on SIGINT, SIGTERM, and other signals when the app's modules first load
  (under the CLI too); they re-raise the signal when no other listener exists.

Migration from main (`02d723a`):

| main | `mlx-bun/server` |
| --- | --- |
| `createServer(ctx, port = 0, serverOptions)` returned Bun's `Server` | `await createServer(context, port = 0, options)` returns `{ port, flush, close }` |
| `shutdownServer(server, timeoutMs = 120_000)` → `{ stopped, timedOut, durability }` | `server.close({ timeoutMs })`, the same result; `server.stop()` becomes `await server.close()` |
| `flushServerCacheDurability(server)` | `server.flush()` |
| `loadContext(dir, id?, { implementations, profiles, … })` | the same, from `mlx-bun/server` |
| `ServerContext`, `ServingContext` | `ModelContext`, `LoadedModelContext` |
| `ServerContext.serving?: ModelServingBinding` | `options.binding` (`ModelBinding`) and `options.buildPrompt` for `serving.buildPrompt`; `createSerial` has no counterpart, since every request runs on the shared scheduler through `binding.gateway` |
| `ModelPromptBuilder`, `BuiltPrompt` | the same names |
| `batch` (1 pinned main's serial executor) | `capacity` (1 is the continuous scheduler at capacity one) |
| `promptCacheBytes`, `kvQuant`, `quantizedKvStart`, `turboQuant`, `ssdCacheDir`, `ssdCacheMaxBytes`, `ssdDemoteIdleSec`, `ssdCacheVerify`, `generationCheckpointTokens` | `cache.*` |
| `pagedKv`, `defaultThinking`, `defaultTemperature`, `defaultTopP`, `defaultTopK`, `hlg` | `request.*` |
| `defaultMaxTokens` | `defaultGeneratedTokens` |
| `whisperModelDir`, `whisperModelId`, `whisperIdleUnloadSec`, `whisperResident` | `whisper.modelDir`, `.modelId`, `.idleUnloadSec`, `.resident` |
| `kvBudgetBytes`, `memoryBudgetBytes`, `hostname`, `defaultAdapter` | the same |
| `owner` | not an option; `/stats` reports `embedded` |
| `unixSocket` | not provided; the private worker launch forms own Unix sockets |
| `CompletionClient`, `BatchCompletionClient`, `TaskClient` (`mlx-bun/engine`) | the same, from `mlx-bun/engine` or `mlx-bun/client` |
| `mlx-bun/package.json` | the same subpath |

The [server entry tests](tests/server-entry.test.ts) import the entry through
the export map with native MLX blocked, then compose the real app over a
supplied binding in child processes with a temporary HOME: main's model
replacement shape (one context, five sequential servers), the full app and
`/ws/chat`, the template-less builder path, startup failures (options, state,
caches, bind) under both ownerships, and close's deadline, drain, and
durability evidence.
`verify-packages` repeats them from the installed package. The opt-in
[native test](tests/engine/in-process-server.test.ts) (`MLX_BUN_TEST_NATIVE=1`
with `MLX_BUN_APP_TEST_MODEL`) serves a real loaded context through a caller
binding under a temporary HOME, aborts a live stream during close, and reuses
the borrowed context for a second server.

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

The sidebar lists every chat in the session directory, whatever working
directory it recorded; main listed only chats recorded under the server's
working directory, which a server started by brew or launchd does not
meaningfully have. Opening a chat whose recorded directory no longer exists (a moved
or deleted checkout) continues it in the server's directory, the SDK's
"continue in current cwd" choice; main, and the SDK without that choice, refuse
to open it. The file keeps its recorded header, and opening a chat appends the
SDK's session entries, as before.

The [existing-user data test](tests/existing-user-data.test.ts) opens data a
prior version left under HOME (sessions, Pi settings, approvals, the saved
token, the vault and its Reference links, adapter stores, the nightly schedule)
through the app with HOME set to a clone and native MLX blocked, and requires
nothing lost: the supplied directory and its link targets unchanged, no
deletion, a byte-identical vault, and only the app's own databases
(`.mlx-bun/db`), its bundled skill, and append-only or message-preserving
session rewrites. The earlier `~/.cache/mlx-bun` jobs, memory and registry
databases are not carried over and must stay byte-identical; its adapter stores
must appear in the picker's catalog. Its default case builds main's formats
in-test; `MLX_BUN_APP_TEST_USER_DATA=<isolated copy laid out as a HOME>` runs it
on real data and prints what to preserve before an old checkout is deleted. It
refuses a copy holding, at any depth, a link that resolves into a live store
(`~/.mlx-bun`, `MLX_BUN_HOME`, `~/.cache`, `~/.pi`, `~/Library`) or a directory
link leaving the copy.

## Browser app

`src/web/browser/` preserves the existing chat, model, training, quantization,
dataset, memory, and status UI as pages of the web shell
([`@mlx-bun/web-shell`](../../packages/web-shell/README.md)), which owns navigation, routing, theme,
the command palette's chrome and the mounting of module panels. `main.ts` composes the shell, the panels of the
installed modules (`installed-panels.ts`, generated by `web/build.ts` from the host's installed modules, so the bundle
carries every panel the host installs and nothing else) and the pages that have not moved into modules yet;
`shell.ts` is the app's glue around the shell (its routes, the Hugging Face and agent-tools settings, the chat
drawer, overlays and key bindings, the connection pill). Browser code imports only local browser modules, the
shell package and the data-only chat/job protocols. Unported backend features may return 501;
preserving their UI does not claim their backend is ready.

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
[Boot tests](tests/web/boot.test.ts) run the built bundle against `app.html` (the shell's tabs and pages, a
module panel mounted through the shell). [Static tests](tests/web/assets.test.ts) exercise the built bundle and asset
headers. The packed consumer check verifies the same assets after installation.

Adapters are the models module's (`/v1/adapters*`, [module README](../../packages/module-models/README.md)): the routes
reach the served model through its `adapters` operation, which `engine/adapter-operation.ts` builds over the loaded context
(mount, unmount and merge run under the engine execution lock in the process that holds the model); no HTTP handler owns
tensors. Serving with an adapter still uses the shared scheduler and reports 501 for unsupported batched capabilities.

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
order, database schema (`db.ts`, `~/.mlx-bun/db/memory.sqlite`), vault
layout, Git usage, and the dedup/normalize/reconcile rules: `pipeline.ts` drives
the four resumable, chronological stage workers in `stages.ts` (SEGMENT via
`chunk.ts`, ENTITY-EXTRACT via `entity.ts` + `resolve.ts`, ROUTE via `route.ts`,
SYNTHESIZE via `synthesize.ts`/`cluster.ts`/`reconcile.ts`), then the
deterministic `crosslink.ts` pass and the `wikify.ts` editorial sweep. `events.ts`
holds the shared event contract so no stage imports the orchestrator.

The engine is reached only through `model.ts`'s `MemoryCompletionClient` seam.
The memory domain defines the interface; composition injects an
implementation. `cli/memory-engine.ts` is main's memory task model (Gemma-4
e4b and its `memory-chunk` adapter), loaded in-process by the first completion
over the app engine's continuous gateway: the `memory` verb and its nightly job
use it, and so does `serve`'s own synthesis, which keeps it resident until
shutdown, as main did. Under `serve` each task-model completion (or batch, once
all its rows join) holds the served engine's execution lease, taken before the
weights load, so memory work never overlaps a managed job; chat waits while a
memory stage call runs (main's in-server client ran beside chat under its own
locks). `server/memory-completion-client.ts` holds the HTTP clients. Its
loopback client posts each stage call to a serving mlx-bun's own
`/v1/chat/completions` (raw greedy sampling, neutral logit processors and the
model template's thinking defaults, the stage's system/user turns,
`adapter: "memory-chunk"` for the chunk stage when
`~/.mlx-bun/adapters/memory-chunk` exists and `"none"` otherwise):
`memory --host`/`--port` use it.

In the default isolated `serve` the parent, which loads no model, keeps the pipeline,
vault, and SSE; the current model's worker owns the task model (the same
in-process client, loaded by its first call and kept until that worker stops). The parent's worker client (also in
`server/memory-completion-client.ts`) sends each `complete` or
`completeBatch` as one `POST /admin/memory/complete` over the worker's
socket (`{ call, snapshot, requests: [{ stage, input, maxTokens }] }`, answered
`{ outputs }` in input order). The worker runs the call under its own execution
lease, taken before the lazy load and released after every row joined, so it
waits for a managed job's lease and a job waits for it; the parent takes no
lease of its own for it. The parent selects the task model snapshot once per call
(`locateTaskModel`), the call carries it, and the call that loads the task model
loads exactly that directory; the parent keeps the selected snapshot out of hub GC
for that worker's lifetime (until it is respawned or the server stops). A cancelled run, a client
disconnect, or the parent's shutdown aborts the request, and the worker aborts
and joins every row. A call is never retried: a worker that stops mid-call fails
that call with an error, and a restart drops the task model with
its worker. Every path rides a continuous-batching scheduler. `MLX_BUN_MEMORY_BATCH`
(default 1) bounds the calls in flight per batched stage. Nothing in the memory
domain loads a model, and no serial lane exists. Each run receives its client
and vault root explicitly; Meta policy reads use that same vault. A failed batch
stops admission, cancels siblings, and joins them before returning its error.
`server/memory-synthesis.ts` owns active server runs: request/body cancellation
aborts the run and its in-flight completions (or its wait for the lease), and
server shutdown cancels and joins all synthesis alongside managed jobs and
downloads, then closes the task model, before engine drain. Completed stage writes are resumable; cancellation does not roll them back.

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

`storage/paths.ts` owns every default location the app writes, all under
`MLX_BUN_HOME` (default `~/.mlx-bun`), read from the environment at call time:
`models/` (convert, web quantize and fuse outputs, plain model directories),
`adapters/` (train, web fine-tune, merge, memory stages), `exports/`,
`datasets/`, `db/` (jobs, model index, memory), `jobs/` (job logs), and the
existing chat, wiki, skill, log and credential files. The Hugging Face cache
holds downloads only; the model index (`openRegistry()`) scans it and
`models/`, so `ls`, `/library`, `serve <name>` and the folder picker find both.
Explicit paths (`--mlx-path`, `--save-path`, `--adapter`, request fields) win.
Earlier versions' job history and model index under `~/.cache/mlx-bun` are not
carried over (the index rebuilds by scan); their adapter stores stay listed.

`jobs/` owns the lazily opened SQLite store, durable NDJSON events, SSE tails,
and managed subprocess lifetimes. `cli/job-entry.ts` resolves the producer in the child process: the installed
module that registered the job kind. HTTP parsing and job wire responses stay in `server/job-routes.ts`.

Fine-tuning is the train module's ([`@mlx-bun/module-train`](../../packages/module-train/README.md): the
`finetune` job, `/api/finetune/inspect-dataset` and `/submit`, the `train`, `train-watch`, `fuse` and `draft` verbs,
`mlx-bun.lora` and `mlx-bun.fuse`, and the `adapters/` storage entry, with `models/` and `datasets/` shared with
quantize and datasets). This app installs it (`src/modules.ts`) and supplies its core services in the
persistent state the same way as quantize's. The verbs run through the verb table (`cli/module-verbs.ts`); a verb
that names no model runs on the app's automatic choice (`resolveModelAuto`, the one `serve` makes), which the
verb host supplies to the catalog. Adapter merge and export are the models module's, on the served model's `adapters`
operation (below).

Quantization and `convert` are the quantize module's ([`@mlx-bun/module-quantize`](../../packages/module-quantize/README.md):
the `quantize` job, `/api/quantize/*`, the `convert` verb and `mlx-bun.convert`). This app installs it
(`src/modules.ts`) and supplies its core services in the persistent state (`cli/serve-state.ts`): its
`process` runner is a child of the job host (`jobs/service.ts`, `jobs/runner.ts`), which holds the execution
lease until the child's process group is gone; the child (`cli/job-entry.ts`) activates the module that
registered the job kind and runs its runner. A one-shot `convert` (`cli/module-verbs.ts`) runs over a job
store of its own, created on first use and removed when it ends, so its runs never appear in the job history.
`convert`'s and `fuse`'s `--upload-repo` push through the modules' `catalog` service (`publishing/catalog-hub.ts`).
`/api/model/resolve-folder`, the fine-tune wizard's folder picker, is the models module's over the same catalog.

Composition injects the engine execution lease. A job drains active inference
and holds that lease until its child's process group is gone and output streams
finish; inference then resumes. The child leads its own process group, so
descendants that outlive it are stopped (SIGTERM, then SIGKILL after 3 s) before
the job counts as joined. The wait is bounded: a process still alive 3 s after
SIGKILL, or one outside the group still holding the output after another 3 s, is
logged and left behind, and the lease is released. Terminal signals no longer reach a group leader, so the
parent holds a pipe on the child's stdin and the child stops its group when that
pipe ends (`MLX_BUN_JOB_PARENT_PIPE`, set by the runner). A row the runner cannot
read after admission fails the job before anything is spawned. As in main's
direct-process server, resident model weights and caches remain allocated while
the child runs. Shutdown stops queued jobs, aborts admission waits, terminates
the active child's process group, and awaits all of it (with the same bound) before closing the store
and engine. Every job row records main's `ended_at` format
(`YYYY-MM-DD HH:MM:SS`, UTC) and `Name: message` errors, in-process dataset jobs included. Opening the app does not create the job database until a job
route is used. A fine-tuning job selects its own model path;
the resident inference model's adapter/training capabilities do not gate it.

The [training CLI tests](tests/train-cli.test.ts) spawn the CLI with native MLX blocked and drive the module's verbs through the
verb table: help (including `draft`'s subcommand paragraph), usage errors, refusals and a dry-run plan. The
module's own tests (`packages/module-train/tests`) use injected dependencies. An opt-in native check saves a tiny
drafter and resolves it like a model path ([draft CLI test](tests/draft-cli.test.ts)).

[Job lifecycle tests](tests/jobs/lifecycle.test.ts) exercise leases, crash/error
paths, shutdown, HTTP/SSE, and a real CPU-only child with temporary storage;
[process-group tests](tests/jobs/process-group.test.ts) use real child processes
with descendants holding the job's output.
The [module's tests](../../packages/module-quantize/tests) verify option forwarding and output
naming with an injected numerical operation; they do not run or establish parity for actual
checkpoint quantization.
The [train module's policy tests](../../packages/module-train/tests/policy.test.ts) cover the app recipe,
explicit overrides, dataset inspection, HTTP submission, progress, and resource
cleanup with a fake native runtime. These CPU checks do not extend the numerical
claims in the [training evidence](../../packages/training/README.md). The opt-in
[fine-tune preservation test](tests/engine/finetune-preservation.test.ts)
(`MLX_BUN_TEST_NATIVE=1 MLX_BUN_APP_TEST_FINETUNE_REFERENCES=<ref.json>[:…]`) runs
this producer on each submit record main's producer ran, for any family or
training path, and requires main's metrics, config files, adapter and checkpoint
tensors, fresh-reload logits, and optionally its `fuse` output exactly; its
header gives the commands that produce the references outside the repository.
On 2026-09-28 it passed on the M1 Max against main `02d723a` run from source with
this tree's staged native library, for mlx-community MiniCPM5-1B-OptiQ-4bit
(`664aabae`). The records were SFT (8 iterations, batch 2, accumulation 2, dropout,
rsLoRA, checkpoints, fused output), ORPO (default L3 heads, grad checkpointing)
and DPO (LoRA+). A reference with a changed seed failed as expected.

Composition takes `storagePaths` (job store, saved token file, and an artifact
root replacing `MLX_BUN_HOME` for models, adapters, exports and datasets) like
`chatPaths` and `memoryPaths`, so embedded and test servers never touch the
user's jobs, credentials or artifacts. The opt-in
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

A further case in the same file consumes finished fine-tune outputs as
artifacts, with the RAM prompt cache off so every compared request prefills
cold. Two SFT jobs train on sentences written at run time. Each finished
adapter (not a checkpoint), and their merge through `POST /api/finetune/merge`,
is mounted with `POST /v1/adapters` and selected per request. A selected
adapter changes the greedy `/v1/completions` text; requests without one, and
requests after `DELETE /v1/adapters/<id>`, return the base choice exactly, text
and per-token logprobs, and an unmounted id is refused. A fresh process mounting
the same two directories reproduces both adapters' choices exactly.
`mlx-bun fuse` then folds one adapter into the base. The output keeps
`config.json`, the tokenizer files, the tensor inventory (names, dtypes, shapes)
and every tensor outside the folded modules byte-identical, changes only folded
modules, and loads with `serve` and generates. Its output is not compared with
the mounted adapter: `fuse` re-quantizes folded modules with their source spec,
so the fused model and the adapter are not bit-exact by contract. Run with
`cd apps/mlx-bun && MLX_BUN_APP_TEST_MODEL=<cached snapshot directory> bun test tests/engine/managed-jobs.test.ts -t "finished fine-tune outputs"`.

## Dataset jobs

Dataset generation is the datasets module's ([`@mlx-bun/module-datasets`](../../packages/module-datasets/README.md):
the thirteen templates, `/api/dataset/templates` and `/api/dataset/submit`, the `dataset`
job kind, the Docker Python verifier). This app installs it (`src/modules.ts`) and supplies
its core services in the persistent state (`cli/serve-state.ts`), because a module that
requires `jobs` runs beside the job store: `jobs/service.ts` runs its task runners on the
job host, so its rows, logs and `/api/jobs` streams are the same as any job's;
`storage` resolves the module's `datasets/` entry under `MLX_BUN_HOME` (the
`artifactRoot` override replaces it, as for other produced artifacts); and
`cli/served-model-host.ts` is the `modelHost` that leases the attached serving host's
model for `generate`, sending the request to its own HTTP listener (its Unix socket in
the worker app form; through the proxy in the default isolated mode), so jobs call the same app.

Adapter merge/export requests are the models module's. Merge is the served model's `adapters` operation: it runs the
public training library under that model's engine execution lock, in the process that holds the model. The default isolated
parent loads no MLX, so `cli/worker-unit.ts` reaches the worker through `cli/worker-adapters.ts` (one JSON call on the
worker's private `POST /admin/adapters`, served by `server/worker-routes.ts` on the worker's own operation), and
`residency/leased-adapters.ts` holds the model resident for each call; `--in-process` calls the unit directly. Export writes
a CPU-only manifest without taking any lease. Merges land in
`~/.mlx-bun/adapters/merged-…` and exports in `~/.mlx-bun/exports/export-…`,
with unique suffixes so simultaneous requests cannot overwrite each other's
artifacts.

`GET /v1/adapters/available` lists the catalog's adapters (`adapterStores()` in
`storage/paths.ts`): `~/.mlx-bun/adapters`, then, read-only, the stores
earlier versions wrote (`~/.cache/mlx-bun/adapters`,
`~/.cache/mlx-bun/mlx-bun-finetunes`, `~/.cache/mlx-bun-finetunes`), each
directory once. Nothing is moved. The [storage layout tests](tests/storage-layout.test.ts)
drive each producer's real default (web fine-tune, merge, a `train` dry run,
the memory stage reader) and require the app's catalog to list it; they
check that a quantize job's and a default `convert` run's directories under
`models/` are what the index, `serve <path|name>` and the folder picker read,
that nothing lands in the hub cache, and that earlier `models--local--…`
quantize snapshots there still resolve. Their tensor files are zeroed
stand-ins; loading and generating from real artifacts is the opt-in
managed-jobs and startup-adapter acceptance.

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

The `upload` verb, main's `mlx_lm.upload` counterpart, is the models module's:
`mlx-bun upload --path <dir> --upload-repo <org/repo> [--private]` (`--path`
is required; there is no working-directory default). It publishes through the catalog
(`publishing/catalog-hub.ts`, which resolves the token through
`publishing/credentials.ts`), fails before any request when the repo id,
directory, or write token is missing, and pushes a model repo through the same
public hub uploader with the commit message "Upload with mlx-bun". SIGINT or
SIGTERM aborts the transfer; nothing is committed after an abort. The
[upload CLI tests](tests/upload-cli.test.ts) spawn the real CLI against a local mock Hub with an isolated
home directory and an invented token; the module's own tests inject the catalog.

## Web hub

The hub routes, the library and the Models panel are the models module's ([`@mlx-bun/module-models`](../../packages/module-models/README.md)),
which this app installs in the persistent state (`placement: "app"`). `hub/downloads.ts` stays here: it owns web-started
transfers, and `catalogTransfers` gives the catalog's `startDownload` and `downloads()` that owner. Admission
is synchronous before the metadata request, so a duplicate submit answers 409;
`GET /downloads` serves the owner's rows, one per transfer from admission (the
panel shows "preparing…" until the listing and preflight finish) through the
hub tracker's live row to done, or to an error when the listing fails or
shutdown cancels it; completion re-indexes the catalog, which announces `catalog.changed` (the module's library rows and the
host's model listing follow it); shutdown aborts and joins every transfer before the engine
closes, leaving resumable partials and publishing nothing. Selecting a model
(`POST /api/hub/serve`, the panel's Serve button) asks the model host to serve it (`ModelHost.serve`, which the serving host
lends through its link): it loads beside the running models when it fits,
otherwise the least recently used one is drained first (see the model host), and the
answer is `{ ok: true, model }` (404 for an id that is not a local model, 502 when it
cannot load). A host that serves one model answers `restart_required` with the
`mlx-bun serve <id>` command.

## Audio transcription

Speech-to-text is the transcription module's ([`@mlx-bun/module-transcription`](../../packages/module-transcription/README.md):
the service, `/v1/audio/*`, `/admin/transcription/unload`, `transcribe`, `dictate`).
This app installs it (`src/modules.ts`) and supplies its core services:
`serve-host.ts` builds the Whisper model host from `--whisper-model`,
`--whisper-idle-unload` and `--whisper-resident`, gives it the generation
gateway's exclusive lock so decoding never overlaps chat, mounts the module's
routes where the audio routes were, and stops the module and then releases the
weights ahead of the chat model. `--preload` and serving a Whisper checkpoint as
the main model start the transcription-only server (the audio routes plus
`/v1`, `/v1/models`, `/health` and `/stats`). `GET /v1/models` and the web
chat's `ready.transcription` probe (the hold-to-talk mic, still the chat
composer's) read the model host's default Whisper. The [serve
tests](tests/serve-cli.test.ts) cover the flags, both `runServe` branches and
both compositions over a fake Whisper backend; the [voice
test](tests/engine/voice.test.ts) and the opt-in [transcription
test](tests/engine/transcription.test.ts) run real weights through this app, and the
opt-in [transcription parity test](tests/engine/transcription-parity.test.ts) checks the
served transcripts against the oracle.

## Metrics and performance

The live view is the metrics module's ([`@mlx-bun/module-metrics`](../../packages/module-metrics/README.md):
`/api/metrics/snapshot`, `/stream`, bench-serve runs and history). This app installs it and supplies what it
subscribes to. `AppState.events` is the `events` bus; `startModelHost` measures the model load and
`startContextHost` publishes it once the modules are active; `src/engine/telemetry.ts` wraps the completion engine
(`engine.completion` is replaced by the observed one, so every route runs through it) to publish each request's
queue wait, time to first token, prefill and decode rates and total time from the run's own stats, and samples the
gateway and prompt cache every second (batch rows of capacity, queue depth, tokens per second, projected KV bytes
against `--kv-budget`, prompt-cache bytes, hits and misses, per-model memory), quiet while idle and unchanged.
Publishing only appends to bounded queues, so a slow subscriber never delays generation; nothing under the engine
imports the bus. The module requires `jobs`, so it activates in the persistent state (`serve-state.ts`) with the state's bus;
`jobs/service.ts` runs its `bench-serve` runner as a managed task (rows and logs in the job store, listed by
`/api/jobs`), under the engine's execution lease because the runner declares `gpu: "exclusive"`. In the default isolated mode
each worker's events are relayed to the parent's bus, so the view there covers every resident model. `/stats`, `/health` and `/fit` are unchanged. The status page loads the
module's panel element while it is visible (`web/browser/status.ts`). The opt-in [real-weights
test](tests/engine/metrics-native.test.ts) (`MLX_BUN_APP_TEST_MODEL=<snapshot directory>`) serves a model and requires
the module's numbers to equal each response's `usage` and `/stats`.

## Benchmarks

Answer-quality evaluation is the benchmarks module's ([`@mlx-bun/module-benchmarks`](../../packages/module-benchmarks/README.md):
`/api/benchmarks/tasks`, `/runs`, `/compare`, the `eval-serve` job kind). It orchestrates `scripts/eval-serve.ts`
(the capability evaluation runner) and scores nothing itself. This app installs it and supplies what it requires in the
persistent state (`cli/serve-state.ts`): the `eval-serve` runner runs on the job host under the engine's execution lease
(`gpu: "exclusive"`), `storage` resolves its `benchmarks/` entries under `MLX_BUN_HOME` (datasets in `benchmarks/data`,
placed by the user, never downloaded), `modelHost` names the served model, and `catalog` (the registry-backed one
over the model index, native-free like the rest of the state) resolves it to its directory.
The runner then starts its own server from `bin/mlx-bun.mjs serve --model <dir> --port <free>` in a sandboxed `HOME`;
the app's served model stays resident and idle. The web shell mounts the module's panel (a Benchmarks tab, from its manifest). The opt-in [real-weights test](tests/engine/benchmarks-native.test.ts)
(`MLX_BUN_APP_TEST_MODEL=<snapshot directory> MLX_BUN_EVAL_DATA=<pinned datasets>`) runs `gsm8k-50` and `mmlu` through
the module and requires its history to equal a direct `eval-serve.ts run` of the same plan.

## Standalone bundle

After staging the root native setup and the microphone helper with
`bun run --filter @mlx-bun/module-transcription build:native`, run `bun run build:binary` from the root.
`dist/bundle/` contains the executable, native libraries/helpers, Pi's Photon
WASM sidecar, the project license, and combined third-party notices: the MLX and
inference package notices, Photon's installed Apache-2.0 license, the app's own
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), and one section per npm package
the build retained. [bundle-notices.ts](../../scripts/bundle-notices.ts) reads the
metafiles of the executable and embedded browser builds: every input that
contributed bytes maps to its nearest `package.json` `name@version`; workspace
packages are excluded. A section copies the installed LICENSE, LICENCE, NOTICE and
COPYING files verbatim. Packages that install none (Pi, XGrammar) must be named at
that exact `name@version` in the app or package notices, which carry the upstream
text with its source revision; otherwise the build fails. Reviewed vendored license
headers are copied from the installed files. Curated sections of the app and
inference notices carry the notices of code that Jiti's prebundle, XGrammar's WASM
build and json-bigint's `lib/parse.js` embed; those packages' retained files are
pinned by sha256, and each curated section by the sha256 of its text. Another
version, a changed file, or a changed or missing section fails the build until
reviewed. The notices still missing are listed under Release acceptance in PLAN.md.
Move the whole directory together. Web assets and the memory skill
are embedded; source checkouts retain their existing asset readers and browser
build fallback. No terminal Pi assets are included.

`bun run verify:binary` builds into temporary storage, archives the bundle with
the release preparation's tar command, and removes the build. The shared
acceptance then extracts the archive to another directory, compiles a consumer
into that copy, checks every notice section of a fresh build, and installs the
unchanged archive through the curl installer using a local curl stub and
temporary home, then upgrades once. It checks the actual CLI and managed child plus the consumer for
web, memory, synthetic registry/fit, native path resolution, microphone helper
help, and Photon initialization in the relocated, installed, and retained
previous bundles.
The default performs no MLX/GPU operation or remote download. Mac CI runs this check.
With exclusive GPU access, `bun run verify:binary --model /path/to/cached-model`
also starts the actual relocated executable, checks its web assets, `/stats`,
`/fit`, and a chat completion, then requires a clean SIGTERM exit. It discovers
the supplied weights through a temporary HF snapshot symlink and isolates the
child's home, caches, and chat storage; it never copies or downloads weights.
This is a local build artifact, not signing/notarization or release publishing.

[`scripts/install.sh`](../../scripts/install.sh) installs a complete release
bundle under `${MLX_BUN_INSTALL_DIR:-$HOME/.mlx-bun}/app-install/` and links
`~/.local/bin/mlx-bun` and, beside it, `mlx-bun.<cmd>` for each
[mlx-lm alias](#mlx-lm-compatibility-mlx-buncmd) (each a link to the same
executable; all are refused where a directory stands and switch with the app).
`MLX_BUN_VERSION` selects `latest` or a pinned tag.
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
temporary homes, including reinstall, failure, and every refusal path (usage,
tag, platform, archive layout, executable and version, command destination,
app-root and `current` ownership), without network access.

## Release preparation

`bun scripts/prepare-release.ts prepare /new/output/directory` builds from staged
natives, checks the executable against the app manifest version, packs workspace
packages, and writes unsigned local archives, checksums, and a Homebrew formula.
It then runs the `verify:binary` acceptance (CPU only) on the unsigned archive
and requires unchanged bundle hashes afterwards; a failure removes `unsigned/`
and writes no `preparation.json`.
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
use captured mock signing/notary commands and a recording acceptance stand-in;
they do not prove a real signature or Apple acceptance.
