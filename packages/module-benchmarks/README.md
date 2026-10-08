# @mlx-bun/module-benchmarks

Answer-quality benchmarks as an application module (`AppModule<"jobs" | "storage" | "modelHost" | "catalog">`,
design: [Modular application](../../ARCHITECTURE.md#modular-application)). It is speed and memory's counterpart: the
[metrics module](../module-metrics/README.md) measures how fast a model serves, this one measures how well it answers.
It launches the existing capability evaluation runner (`scripts/eval-serve.ts` and `scripts/eval/*`: GSM8K, GSM8K-50,
MMLU, IFEval, BFCL, HumanEval, HashHop, over HTTP, greedy, datasets pinned by sha256) as a job and keeps the compact
results. The runner stays the only implementation: this package pins, scores and compares nothing itself; it starts
the runner's `plan`, `run`, `compare` and `tasks` commands, streams their output into the job's log, and reduces the
finished `result.json`. Nothing here imports an app or another module; the job service, the storage root, the served
model's identity and the catalog come from the host. The mlx-bun app installs it (`apps/mlx-bun/src/modules.ts`).

## A run

`POST /api/benchmarks/runs` submits an `eval-serve` job (`gpu: "exclusive"`, so the app holds its execution lease and
no model generates meanwhile). The body takes `tasks` (ids or a set name: `capability`, `smoketest`, `all`; default
`smoketest`, the 50-question GSM8K draw), `model` (a catalog id or query; default the served model, found through
`modelHost.defaultFor("generate")` and resolved to its directory by `catalog.find`, which must declare `generate`)
and `enableThinking`. The job then:

1. runs `eval-serve.ts plan` with that model directory, the module's `data` directory and the MLX library
   (the checkout's staged one), saving `plans/<id>.json`. The runner refuses a dataset that is
   missing or whose sha256 is not its pin, and the job fails with the runner's message.
2. runs `eval-serve.ts run --plan` against a fresh server the runner starts from the checkout's own
   `apps/mlx-bun/bin/mlx-bun.mjs serve --model <dir> --port <free>` in a sandboxed `HOME`. The app's served model
   stays resident and idle; the evaluated server is the runner's, so a run's provenance (source tree, library,
   command) is the runner's own. It reports progress from the runner's per-item counters (`mmlu 25/969`) across the
   plan's tasks and cancels by SIGTERM (the runner stops its server and saves what it has).
3. reduces `result.json` to a history entry.

A request never names a plan, a data directory or a command; those are a programmatic job's (`config.plan` an absolute
plan file, `config.data` an absolute directory, `config.native` an absolute MLX library). The job needs a source checkout (the runner is not shipped in the
binary) and `bun` on PATH, and says so when either is missing. HumanEval executes generated programs only through the
datasets module's Docker verifier; without Docker (or its image) the task is skipped as unverified, never run on the
host, and the run is incomplete. The runner also calls a run incomplete when the evaluated tree is dirty, since its
commit then does not identify the source; the entry keeps the scores and lists the problem.

Datasets are never downloaded. The pinned files (`gsm8k.jsonl`, `gsm8k_optiq_frozen.jsonl`, `mmlu_optiq_frozen.jsonl`,
`mmlu_optiq_dev.jsonl`, and the IFEval, BFCL, HumanEval and HashHop ones) must already be in the `data` entry;
`GET /tasks` says, per task, which are there. How to obtain them is in `bun scripts/eval-serve.ts --help`.

Routes (declared in `src/manifest.ts`, mounted at `/api/benchmarks`): `GET /tasks` (the runner's own listing: sets,
pinned datasets and rows, verifier need, and whether each file is present), `POST /runs`, `GET /runs` (history,
newest first, `limit`), `GET /runs/<id>`, `GET /compare?base=<id>&candidate=<id>`, `GET /jobs`, `GET /jobs/<id>`,
and `DELETE /jobs/<id>`.

## History and comparison

Everything lands under `MLX_BUN_HOME`, outside Git:

| Storage entry | Path | Holds |
| --- | --- | --- |
| `history` | `benchmarks/history/` | One compact JSON per finished run: identity, model (path, repository, revision), machine, completeness, problems, and per task its status, accuracy, correct and total, wall time, and the runner's capability mean with the tasks it excluded |
| `runs` | `benchmarks/runs/` | Each run's directory as the runner wrote it: `result.json` (with provenance), `samples.jsonl` (per sample), `report.md`, the server's log |
| `plans` | `benchmarks/plans/` | The pinned plan each run was made from |
| `data` | `benchmarks/data/` | The sha256-pinned datasets, placed by the user |

A run that ends incomplete keeps its history entry (`complete: false`, with the problems the runner printed) and its job
fails; score acceptance stays unreviewed, as in the runner. `GET /compare` runs `eval-serve.ts compare` over the two
runs' full `result.json` files and returns its report (every score difference, sample flip, skip and provenance
mismatch, no tolerance), whether the runner judged them comparable, and each task's accuracy difference.

## Panel

`src/panel/index.ts` defines `<mlx-benchmarks-panel>`: one self-contained custom element (shadow DOM, no imports but its
data protocol's types) that takes `connection = { apiBase, eventsUrl }`, lists the tasks (one whose dataset is missing
cannot be chosen), starts a run for the chosen tasks and model, shows the running job's progress, the history with
per-task accuracy, and a comparison of two runs. It polls its own routes and does not read the events URL. The app's
web shell (`@mlx-bun/web-shell`) mounts it: the app's browser build imports the manifest's `panel.entry`
(`@mlx-bun/module-benchmarks/panel`) and gives the shell the manifest's tag, title and path (route `#/benchmarks`)
with `connection = { apiBase: "/api/benchmarks", eventsUrl: "/api/benchmarks/stream" }`, so the standalone binary
carries it too and the module serves no script.

## Tests

Model-free: [evals](tests/evals.test.ts) (the runner's command lines, progress from its counters, compact scores,
plan refusal, incomplete and failed runs, cancellation, missing checkout, library or model, history and comparison; the
last two cases run the real script's `tasks` and `plan`), [module](tests/module.test.ts) (manifest against
`@mlx-bun/app-host`, every route through the job service, that a request cannot name a plan, data directory or
command) and [panel](tests/panel.test.ts) (happy-dom). The runner's task listing is tested in
[eval.test.ts](../../scripts/eval/eval.test.ts). The opt-in
[real-weights test](../../apps/mlx-bun/tests/engine/benchmarks-native.test.ts)
(`MLX_BUN_APP_TEST_MODEL=<snapshot directory>`, `MLX_BUN_EVAL_DATA=<pinned datasets>`) runs `gsm8k-50` and `mmlu`
through the module against the served model and requires the history's scores and per-sample outcomes to equal a
direct `eval-serve.ts run` of the same plan.
