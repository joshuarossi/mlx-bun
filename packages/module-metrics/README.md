# @mlx-bun/module-metrics

Metrics and performance as an application module (`AppModule<"events" | "storage" | "jobs">`,
design: [Modular application](../../ARCHITECTURE.md#modular-application)). It reduces the events the host
publishes into a live view, serves it over HTTP, and launches `scripts/bench-serve.ts` runs as jobs and keeps their
history. Nothing here imports an app or another module; the bus, the storage root and the job service come from the
host. The mlx-bun app installs it (`apps/mlx-bun/src/modules.ts`).

## Events in, snapshot out

`src/store.ts` is a pure reducer over the core events (`model.load`, `model.unload`, `model.memory`,
`request.finished`, `scheduler.sample`, `cache.sample`); the module subscribes to those six types and ignores every
other event, so a recorded stream always renders the same `MetricsSnapshot` (`src/protocol.ts`):

- per model: state, loads, last load time, last unload time and reason, swap time (an evicting unload followed by a
  load within two minutes: unload plus load, credited to the incoming model), weights, KV and prefix-cache bytes,
  the last load error;
- scheduler: rows decoding of capacity, requests queued, tokens per second, and a throughput series (120 samples);
- caches: batch KV bytes against `--kv-budget`, and the prompt cache's bytes, capacity, hits, misses and hit rate;
- requests: totals by finish reason, the last 20, and p50/p95/max over the last 200 finished requests for queue wait,
  time to first token, prefill tokens per second, decode tokens per second and total time, plus the share of prompt
  tokens served from the cache. A request that produced no token has no time to first token, queue wait or rates, so
  it is absent from those distributions.

Routes (declared in `src/manifest.ts`, mounted at `/api/metrics`): `GET /snapshot` (JSON), `GET /stream`
(server-sent: `retry: 1500`, then an `event: snapshot` frame on connect and one after each change, at most two a
second, with `: keepalive` comments every 15 s; a client that stops reading skips frames instead of buffering them),
`GET /history`, `GET /history/<id>`, `GET /bench/profiles`, `POST /bench`, `GET /bench`, `GET /bench/<id>`,
`DELETE /bench/<id>`, and `GET /panel.js` (the panel element as a browser module).

Who publishes, in the app: `@mlx-bun/app-services`' `createEventHub` is the bus (`publish` appends to each
subscriber's bounded queue, 1024 events, dropping the oldest and counting it; handlers run later off the publisher's
stack, in publish order, and a handler that throws is counted and skipped). The Whisper model host publishes its
loads, unloads and memory. `apps/mlx-bun/src/engine/telemetry.ts` is the engine adapter: it wraps the completion
engine to time each request from the run's own stats (`prefillMs`, `decodeTps`) and the first token's arrival, and
samples the gateway (`activeRows`, `kvBytes`) and prompt cache every second, quiet while idle and unchanged, from the
same counters `/stats` reads. `serve-host.ts` publishes the served model's `model.load` with the loader's measured
time. The chat model's unload is not published (the process exits with it), and no
producer publishes swaps yet: residency and swapping arrive with the model host
([PLAN](../../PLAN.md#split-the-app-into-modules) (e)), which will publish `model.unload` with reason `evicted`.
The module requires `jobs`, so the app activates it in its persistent state (`installedModules("state")`), beside
datasets: it subscribes to the state's bus before any model loads and outlives a model host. In the default isolated
server each worker's events are relayed onto the parent's bus, so the view covers every resident model.

## Benchmark runs and history

The `bench-serve` job (`gpu: "exclusive"`, so the app holds its execution lease and no model generates meanwhile)
starts the existing runner, `bun scripts/bench-serve.ts run --plan <plan> --out <dir>`, streams its output into the
job's log, reports `cell n/N` progress, and cancels by SIGTERM (bench-serve stops its servers and saves the run).
A profile is a plan file made by `bench-serve.ts plan`, saved as `bench/plans/<name>.json` in the module's storage
entry; `POST /bench` takes only that name (a plan holds the commands bench-serve starts, so a request never points at
an arbitrary file), while the job's config also accepts an absolute `plan` path for programmatic submission. The job needs a source checkout (the script is not shipped in the
binary) and `bun` on PATH, and says so when either is missing. Everything lands under `MLX_BUN_HOME`, outside Git:

| Storage entry | Path | Holds |
| --- | --- | --- |
| `history` | `metrics/history/` | One compact JSON per finished run: identity, machine, completeness, problems, and per cell the medians of decode tokens per second, cold TTFT, 1k-prefill rate, long-context prefill rate, aggregate rate, cold start and peak RSS |
| `bench` | `metrics/bench/` | `plans/` and each run's own directory (`runs/<id>/run.json`, `report.md`, logs) |

A run that ends incomplete keeps its history entry (`complete: false`, with the problems bench-serve printed) and its
job fails; performance acceptance stays unreviewed, as in bench-serve.

## Panel

`src/panel/index.ts` defines `<mlx-metrics-panel>`: one self-contained custom element (shadow DOM, no imports but
its data protocol's types) that takes `connection = { apiBase, eventsUrl }`, follows the stream, and lists profiles,
the running job and the history with a Run button. Until the web shell exists the module serves the element itself
(`GET /api/metrics/panel.js`, its one source file with the types erased) and the app's status page mounts it while
visible (`web/browser/status.ts` adds the script and the element; a server without the module answers 404 and the
section stays hidden). In the shell the manifest's `panel` (`mlx-metrics-panel`, `@mlx-bun/module-metrics/panel`, path
`/metrics`) is imported at build time and the same element is mounted with the same connection; the status-page
loader and the route go away. The standalone binary does not embed the panel source yet, so there the route answers
404 until the shell bundles panels.

## Tests

Model-free: [store](tests/store.test.ts) (a recorded stream renders every metric; windows are bounded; swaps),
[routes](tests/routes.test.ts) (snapshot shape; stream ordering, throttle, keep-alive, skipping and cleanup with
manual timers), [bench](tests/bench.test.ts) (command line, progress, compact medians, incomplete and failed runs,
cancellation, profile and history listing), [module](tests/module.test.ts) (manifest against `@mlx-bun/app-host`,
events through the real hub into the routes, job routes) and [panel](tests/panel.test.ts) (happy-dom).
The app's [telemetry](../../apps/mlx-bun/tests/engine/telemetry.test.ts) and
[job service](../../apps/mlx-bun/tests/jobs/service.test.ts) tests cover the engine adapter and the exclusive lease.
The opt-in [real-weights test](../../apps/mlx-bun/tests/engine/metrics-native.test.ts)
(`MLX_BUN_APP_TEST_MODEL=<snapshot directory>`) serves a real model through the app and requires the module's
numbers to equal each response's `usage` and `/stats`.
