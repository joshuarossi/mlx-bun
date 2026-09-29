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
(ngram only; otherwise a warning), and `--mtp on|off` for GLM-5.2.
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
(main exited 0 on timeout). SSD sub-options without `--ssd-cache` now fail before
model loading instead of warning and being ignored. The existing
`MLX_BUN_RD_CONTEXT_LIMIT` cap remains supported and is intersected with a loaded
GLM memory plan; this draft adds no serving context or read-only CLI flags.
Programmatic composition still accepts explicit context and read-only policy.

`src/cli/main.ts` dispatches commands; `args.ts` owns accepted options and help;
`hub.ts` owns model-management presentation; `terminal.ts` owns formatting.
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
`startContextHost`, which serves one loaded context (binding, caches, engine,
Whisper companion, model routes, Pi backend, listener) and releases it by the
ownership it is given. `startApp` (`serve.ts`) composes the state and one host
with one close in the app's order; `startModelServer` and
[`mlx-bun/server`](#server-entry-mlx-bunserver) use it.

Worker mode serves over a Unix socket a parent supplies, in another process.
`jobs/worker-process.ts` is the parent-side owner: it spawns the executable
captured at startup as `__worker` in the compiled binary or the entry script in
source runs (or `[...command, "__worker"]` for an explicit mlx-bun command),
writes the launch record as the first stdin line, reads the ready line from
stdout, and stops the worker with SIGTERM, then SIGKILL after a grace; the end
of stdin means the parent is gone. `cli/worker-entry.ts` takes two private
launch forms, and no flag selects either:

- The model form `{ version, socketPath, model, options }`, sent by
  `--isolate`, runs `startModelHost` alone with the persistent services stubbed
  because the parent owns them.
- The app form `{ kind: "app", version, socketPath, argv }` runs serve
  arguments (`["--model", model, ...]`) through the CLI's `parseCommand` and
  `runServe`, so the whole app listens on the socket instead of TCP.
  `openIsolatedHost` ([`mlx-bun/engine`](#engine-entry-mlx-bunengine)) sends
  it. `validateAppLaunchArgv` (`serve.ts`) is the CLI's strict
  parse with three differences: `--host`, `--port`, and `--no-open` are
  accepted and never steer the socket bind; `--isolate` and `--model-pool` are
  refused, because a nested isolated app binds TCP instead of the socket; and a
  missing or empty model is refused, because automatic selection may download
  the starter model. SIGTERM, SIGINT, or the end of stdin during startup
  aborts through runServe's startup signal and announces nothing. After ready,
  any of them runs runServe's shutdown under the CLI's deadline
  (`MLX_BUN_SHUTDOWN_TIMEOUT_MS`, default 120 s), and its exit code is the
  worker's. `openIsolatedHost` passes that budget to the supervisor as
  `drainTimeoutMs` and `graceMs` (the supervisor's defaults, 10 s and 3 s,
  serve the model form).

`server/worker-routes.ts` answers `GET /health`, `POST /admin/lease`,
`POST /admin/drain`, and `POST /admin/memory/complete` ahead of the routes on
the socket only: a TCP listener answers 404 for all three, and `/engine`
outside `--isolate` is 404 too. In the app form its `/health` replaces
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
`/v1/chat/completions` over its socket (the loopback URL's
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

## Runtime isolation (`--isolate`)

`--isolate` is an optional capability, off by default: the model runs in a
crash-isolated worker process while this process keeps the app up. It mirrors
main's documented `--isolate` semantics with the deviations listed at the end.

**Process layout.** `serve.ts` resolves the model as usual, then `startModelServer`
composes `cli/serve-isolated.ts` instead of the direct host: the same persistent
`createAppState` (web app, download owner, Responses history, memory, jobs,
sessions, credentials, publishing), a parent-owned proxy, and a pool of workers
(`jobs/worker-pool.ts`: one per exact `/v1/models` id up to `--model-pool`, one
by default) each supervised by `jobs/worker-supervisor.ts` over
`jobs/worker-process.ts`. A launch
record pins the resolved model by path and carries the parsed serve options
(draft and Whisper queries already resolved to directories, `isolate` cleared),
so the worker never re-resolves a query; every exported `MLX_BUN_*` variable
reaches it unchanged, and its output is forwarded to this process's log with a
`[worker]` prefix. Sockets live in a private `mlx-worker-*` temp directory
(0700, sockets 0600), one per worker, that this process removes on close. This process loads no
engine or native module: `serve.ts` imports the model half only inside the
direct composition, and the [composition test](tests/serve-isolated.test.ts)
gates both the static closure and the runtime with tripwire mocks.

**Readiness.** The listener binds after the worker's ready line (up to 15
minutes for large models, as main), so startup succeeds or fails the way the
direct composition does: a worker that dies before its first ready line rejects
startup with its exit and is never retried; the browser opens once the model
serves. The Pi backend learns the model's capabilities, generation defaults, and
enforced context window from the worker's `/v1/models` and `/stats` once, after
that first ready line.

**Application state.** The web app, Pi chat, the Responses history, jobs,
downloads, sessions, memory (the vault and the synthesis pipeline; its task
model is the default worker's), tool-approval settings, and hub GC (which still
protects every resident or loading snapshot, and the task model snapshot
selected for a worker) live here and survive worker restarts. Pi runs in
this process and reaches the model over loopback HTTP through the proxy, so web
chat works under isolation (main answered 501 on `/ws/chat`).

**Proxying.** `server/proxy-routes.ts` is one route group mounted after the
persistent groups: every remaining path (chat and text completions, Messages,
embeddings, audio, `/v1/models`, `/library`, `/fit`, cache admin, adapters,
adapter artifacts, unknown paths) forwards over the socket with hop-by-hop
headers stripped, request and response bodies streaming through unchanged, and a
client abort aborting the proxied request so the worker sees the disconnect (a
request whose client left answers `499`). `POST /v1/responses` goes through
`server/responses-client.ts`: `previous_response_id` resolves against this
process's store, the worker receives the resolved conversation without one (and
the `x-mlx-bun-response-owner: parent` header), and the completed record is
remembered here, so conversations survive a worker restart. The parent answers
`GET /engine` (`{ isolated, state, pid, restarts, socket, model, last_exit,
response_store, pool }`; `state` is `starting`, `ready`, `restarting`,
`exhausted`, `closed`, or `evicted`; the worker fields describe the default
worker), `GET /health` (`{ status: "ok", isolated, engine: { state, pid,
restarts, socket, model, last_exit, in_flight, leases }, pool }` with `in_flight`,
`leases`, and a `draining` state from the worker while it serves), `GET /stats` (the worker's
body with this process's `response_store` and an `engine` report on top; while
the worker is down, 200 with only the parent's part and an `unavailable`
message), and `GET /downloads` from its own transfer owner. `/admin/lease` and
`/admin/drain` stay unix-socket-only and answer 404 on TCP.
`GET /v1/memory/synthesize` is served by this process's memory owner; each
stage call or batch runs on the default model worker's memory task model over
that worker's private `POST /admin/memory/complete` (never forwarded from TCP,
see [Memory synthesis](#memory-synthesis)).

**Crashes.** An unexpected worker exit is respawned with main's budget: at most
three restarts in a rolling 60-second window, and a worker that died within
10 seconds of its spawn waits 5 seconds before the retry. A managed job's
execution lease is a connection-owned `POST /admin/lease` inside the worker,
acquired after the worker serves and after generation in flight has finished;
a respawn waits until every such lease is released, so a reload never shares the
GPU with a job. Requests in flight when the worker dies end with
`502 { error: { type: "engine_unavailable", state } }`; an SSE response ends
with the protocol's own error frame naming the cause (OpenAI `data: {"error"}`,
Anthropic `event: error`, Responses `event: error`), so a client parser ends
with an error rather than a silent truncation and Pi ends the turn with an error
frame instead of replaying the generation. While the worker is down or
restarting, new requests answer 502 with the reason and `— retry shortly`;
exhausting the budget leaves 502 (`engine restart limit reached … restart the
server`) and `/engine` reporting `exhausted` until the server restarts (no
restart route, as main). The [supervisor](tests/jobs/worker-supervisor.test.ts)
and [proxy](tests/server/proxy-routes.test.ts) tests drive these paths against a
fake worker over a real socket; the opt-in
[isolation test](tests/engine/isolate.test.ts) kills a real worker and checks the
respawned completion.

**Shutdown.** Synthesis runs, jobs, and downloads stop while the worker is alive, chat sessions
and HTTP responses drain, then the worker is drained (`POST /admin/drain`),
sent SIGTERM, SIGKILL after 3 seconds, joined, and the socket directory removed;
a respawn in progress is joined too. The worker's own close aborts and joins its
memory calls, then closes its task model, before its engine.

**Deviations from main.** Main bound the listener before the engine loaded and
made every request wait on readiness, including across restarts, retrying
bodyless GET/HEAD once; here the listener binds after the first ready line and a
request during a restart fails fast with 502 so the UI can report the restart
instead of hanging, and nothing is retried. Main answered 501 on `/ws/chat`;
Pi lives in the parent here. Main's parent `/health` was the child's; here it
is the parent's with the worker's contribution. Main's coordinator serialized
worker startup against jobs from the parent; here the lease is the worker's and
only the respawn waits for a held lease. Pi's own SDK policy still retries a
request refused with 502 before generation started (three attempts, 2/4/8 s),
which rides out a fast respawn; a generation that started is never replayed.
`--isolate` with a Whisper checkpoint as the main model is refused before
anything starts.

## Model pool (`--model-pool`)

`--model-pool <n>` (integer >= 1, default 1) sets how many model workers stay
resident under `--isolate`; without `--isolate` it warns
(`--model-pool has no effect without --isolate (child-per-model pool) — ignored`)
and is ignored, as main. `jobs/worker-pool.ts` owns up to `n` supervisors keyed
by exact `/v1/models` id, each on its own socket in the private directory, with
the model resolved at startup as the default worker. The
[pool test](tests/jobs/worker-pool.test.ts), the
[proxy routing test](tests/server/proxy-routes.test.ts), and the
[composition test](tests/serve-isolated.test.ts) drive these paths against fake
workers; the opt-in [native pool test](tests/engine/model-pool.test.ts) keeps
two real models resident and evicts at cap 1.

**Routing.** `POST` bodies on `/v1/chat/completions`, `/v1/completions`,
`/v1/messages`, `/v1/responses`, and `/v1/embeddings` are buffered to read
`model` and forwarded to the chosen worker byte for byte. An **exact** id the
worker's `/v1/models` lists (a supported canonical registry record, resolved
without a scan or download) routes to that model's own worker, spawning it on
first use; anything else (empty, Pi's `local`, a fuzzy name, `gpt-4`) rides the
default worker, mlx-lm's ignored-field semantics, respawning it when it was
evicted. A body that is not JSON goes to the default worker, which answers its
own 400. Resolution misses are remembered until the library changes. Every
other path (`/v1/models`, `/library`, `/stats`, cache admin, adapters) goes to
the default worker while it is resident or loading, else to the most recently
used resident, and never loads a model.

**Cold starts and eviction.** Cold starts run one at a time; the resident
workers keep serving while the new one loads (spawn-overlap). Each routed
request refreshes its worker's LRU position. Once the new worker is ready it
becomes routable and, over the cap, the least recently used worker (the default
included) is deregistered at once, then drained (`POST /admin/drain` over its
socket: no new admissions, generation in flight finishes) and stopped through
its ordinary close, where the worker's cache services demote its prompt cache to
the SSD tier when `--ssd-cache` is set; the next cold start waits for that stop.
Naming the evicted id again respawns it. A cold start that fails answers only
the request that caused it (502 with the worker's exit) and leaves the pool
unchanged.

**Jobs, invalidation, GC.** A managed job's execution lease covers every
resident worker (one `/admin/lease` connection per worker) until the job's child
exits and its logs drain. Admission joins already-started loads and draining
evictions before leasing the resident workers; cold starts wait until all job
leases release, so model loading never overlaps a job's GPU use. Cancellation
and shutdown abort admission waits. A finished download or job refreshes every
serving worker's library and forgets resolution misses. Hub GC refuses to prune
the snapshot of any resident, queued/loading, draining, or closing model, or the
memory task model snapshot selected for a worker's memory calls, which the pool
retains on that worker until its close has settled (the task model is not a
pool worker: it gets no id, lease, or cap slot).

**Reporting.** `GET /engine` gains `pool: { cap, default, resident: [{ id, pid,
state, restarts, socket }], loading: [ids] }` (residents least recently used
first); its worker fields keep describing the default worker and are `null` with
`state: "evicted"` while it is evicted. `GET /health` carries the same summary
with resident ids only and `GET /stats` the full `engine` report. `/v1/models`
keeps the available-model listing and merges each additional resident's own
discovery row, so checkpoints resolved outside the shared registry still appear
with their actual capabilities. Rows gain `resident: boolean` (and
`loading: true` while a cold start runs). Peer discovery is bounded and preserves
the base listing when another worker is unavailable.

**Deviations from main.** Main clamped any bad `--model-pool` value to 1; here
it is validated like the other numeric flags. Main forwarded every non-routed
request to the default worker, respawning it when evicted, which the browser's
`/stats` and `/library` polls would turn into a spawn loop at cap 1; here those
requests never load a model. Main's requester waited for the victim's drain
before its first answer; here the victim is deregistered at once and drained in
the background, while the next cold start and any job lease wait for it.
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
  `--isolate` and `--model-pool` are refused before anything is spawned.
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
  CLI's loader. It sets the MLX allocator limit from a GLM plan or
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
dataset, memory, and status UI. Browser code imports only local browser modules
and the data-only chat/job protocols. Unported backend features may return 501
(`verified_code` submit); preserving their UI does not claim their backend is ready.

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

Under `serve --isolate` the parent, which loads no model, keeps the pipeline,
vault, and SSE; the default model worker owns the task model (the same
in-process client, loaded by its first call and kept until that worker stops,
as main's default child did). The parent's worker client (also in
`server/memory-completion-client.ts`) sends each `complete` or
`completeBatch` as one `POST /admin/memory/complete` over the default worker's
socket (`{ call, snapshot, requests: [{ stage, input, maxTokens }] }`, answered
`{ outputs }` in input order). The worker runs the call under its own execution
lease, taken before the lazy load and released after every row joined, so it
waits for a managed job's lease and a job waits for it; the parent takes no
pool lease for it. The parent selects the task model snapshot once per call
(`locateTaskModel`), the call carries it, and the call that loads the task model
loads exactly that directory; the pool retains the selected snapshot on that
worker, out of hub GC, until the worker has closed. A cancelled run, a client
disconnect, or the parent's shutdown aborts the request, and the worker aborts
and joins every row. A call is never retried: a worker that stops mid-call fails
that call with an error, and eviction or a restart drops the task model with
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
first, resumable) is quantized into `--mlx-path` (default
`~/.mlx-bun/models/<model>-<bits>bit`, or `-mixed-<bpw>bpw` with `-rot<seed>`
for a rotated run, named from the resolved source; either must not already
exist) by the same `createQuantizeRunner` producer the web
quantize job runs, as an owned child process over a temporary job store (the
sensitivity sweep is synchronous, so only a separate process keeps the parent
responsive; progress is tailed from the job log). `--q-bits 4|8` and `--q-group-size 32|64` select
uniform affine quantization; `--target-bpw` with `--candidate-bits`,
`--calibration-mix`, `--n-calibration`, `--rotate-weights`, and
`--rotation-seed` select the mixed path. `--upload-repo` resolves the write
token before any work and publishes through the app publisher afterwards; an
upload failure keeps the model and prints the retry hint. Without `-q` or
`--target-bpw` the model is rewritten only as asked: `--dtype float16|bfloat16|float32`
casts every floating tensor (a quantized model's scales and biases included; router
and expert biases and SSM decay parameters keep their dtype, as mlx-lm's per-model
cast predicates do) and `-d`/`--dequantize` writes dense weights and drops the
quantization block (`convertModelDir` in `@mlx-bun/quantize`); with `-q`, `--dtype`
is the scales/biases dtype and the dtype of the unquantized tensors (bf16 scales
and unchanged tensors without it). `--quant-predicate` and a non-affine `--q-mode`
are refused, as are `-q` with `-d`. Each conversion owns a
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

`cli/train.ts` owns the `train`, `train-watch`, and `fuse` verbs as thin
presentation over this producer and the public training library. `train`
validates main's flags before any model resolution, preflights the dataset,
prints the plan, and drives `createFinetuneRunner` in-process (`--dry-run` stops
at the plan). SIGINT/SIGTERM abort at the next optimizer-step boundary, after any
checkpoint writes already started have completed. Cancellation detaches training
state and releases its resources; completed checkpoints remain usable. A final
save already started is allowed to finish and is reported as success. `train-watch` (`finetune/watch.ts`) tails the trainer's
`<adapter>/metrics.jsonl` (default: the most recently updated run in
`~/.mlx-bun/adapters`); `train` writes `~/.mlx-bun/adapters/<method>-<model>`
unless `--adapter` is given. `fuse` merges an adapter through `fuseAdapter` into
`--save-path` (default `~/.mlx-bun/models/<model>-fused`, refused if it exists);
`--dequantize` writes dense weights for every quantized module and drops the
quantization block, and `--upload-repo` checks the write token first and pushes the
finished model as `convert` does. GGUF export (`--export-gguf`, `--gguf-path`) is
refused. The merge cannot be interrupted, so
a signal arriving during it lets the output finish (without pushing) rather than
leaving a partial directory. [Training CLI tests](tests/train-cli.test.ts) use injected
dependencies and a spawned CLI with native MLX blocked.

[Job lifecycle tests](tests/jobs/lifecycle.test.ts) exercise leases, crash/error
paths, shutdown, HTTP/SSE, and a real CPU-only child with temporary storage;
[process-group tests](tests/jobs/process-group.test.ts) use real child processes
with descendants holding the job's output.
[Quantization policy tests](tests/quantize/policy.test.ts) verify option forwarding
and output naming with an injected numerical operation. They do not run or
establish parity for actual checkpoint quantization.
[Fine-tuning policy tests](tests/finetune/policy.test.ts) cover the app recipe,
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
export writes a CPU-only manifest without taking that lock. Merges land in
`~/.mlx-bun/adapters/merged-…` and exports in `~/.mlx-bun/exports/export-…`,
with unique suffixes so simultaneous requests cannot overwrite each other's
artifacts.

`GET /v1/adapters/available` lists `adapterCatalogDirs()` in
`server/adapter-routes.ts`: `~/.mlx-bun/adapters`, then, read-only, the stores
earlier versions wrote (`~/.cache/mlx-bun/adapters`,
`~/.cache/mlx-bun/mlx-bun-finetunes`, `~/.cache/mlx-bun-finetunes`), each
directory once. Nothing is moved. The [storage layout tests](tests/storage-layout.test.ts)
drive each producer's real default (web fine-tune, merge, a `train` dry run,
the memory stage reader) and require the route's own catalog to list it; they
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

`cli/upload.ts` is the `upload` verb, main's `mlx_lm.upload` counterpart:
`mlx-bun upload --path <dir> --upload-repo <org/repo> [--private]` (`--path`
is required; there is no working-directory default). It resolves the token through
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

`serve.ts` resolves and `serve-host.ts` composes the companion: `--whisper-model <path|query>` resolves like
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
The opt-in [voice test](tests/engine/voice.test.ts) (`MLX_BUN_TEST_NATIVE=1`,
`MLX_BUN_APP_TEST_WHISPER_MODEL`, optionally `MLX_BUN_APP_TEST_MODEL`) runs both
verbs as spawned CLIs on real Whisper weights with speech synthesized by
macOS `say`, `dictate` through a stand-in sidecar that follows the capture
protocol, and a chat server with the companion: the mic probe, idle unload,
transcription while a reply streams, a voice session, unload, and `dictate
--server`. The physical microphone, key tap, clipboard and typing stay manual.

## Standalone bundle

After staging the root native setup and the app helper with
`bun run --filter mlx-bun build:native`, run `bun run build:binary` from the root.
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
