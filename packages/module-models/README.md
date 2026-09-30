# @mlx-bun/module-models

Model management as an application module (`AppModule<"catalog" | "modelHost" | "storage" | "events">`, design:
[Modular application](../../ARCHITECTURE.md#modular-application)). It is presentation and verbs over the core
services: the local library and the Hub (search, downloads, switching the served model, cache cleanup), adapter mounting,
merge and export, the `get`, `ls`, `scan`, `fit`, `gc` and `upload` verbs (and, through the host's verb table, the
`mlx-bun.upload` alias), and the Models panel. Nothing here loads a model or MLX: the routes reach a model only through a
`modelHost` lease, and the verbs read the `catalog`. `apps/mlx-bun` installs it and places it in the persistent state
(`placement: "app"`), beside the serving host's residency.

## Routes

Every route keeps the path it shipped at (`mount: "root"`); the panel reaches them at the origin its connection names.

| Route | Over | What |
| --- | --- | --- |
| `GET /library` | catalog, modelHost, events | Every local model with its fit on this machine, which one is served and which are resident. Rows are kept 30 s and dropped on `catalog.changed`; `?refresh=1` re-reads. |
| `GET /downloads` | catalog | Transfers in progress and the recent finished ones. |
| `GET /api/hub/local`, `/search` | catalog | Downloaded models (after a re-index) with fit verdicts; Hugging Face search (offline is an answer). |
| `POST /api/hub/serve` | modelHost | `ModelHost.serve`: loads beside the resident models when it fits, else in place of the least recently used. 404 not local, 502 load failed, `restart_required` on a host that serves one model. |
| `POST /api/hub/download` | catalog | `startDownload`: a transfer that outlives the request; a duplicate answers 409. |
| `POST /api/model/resolve-folder` | catalog | Where a folder the browser's picker selected lives (`catalog.locate`). The quantize module answers the same question at `/api/quantize/resolve-folder`. |
| `GET /api/gc/plan`, `POST /api/gc/execute` | hub library, catalog, modelHost | Superseded snapshots and dead blobs. The plan is recomputed from disk at execution, never taken from the client, and a snapshot a resident model reads (`ResidentModel.uses`) is never pruned (409). |
| `GET /v1/adapters/available`, `GET`/`POST /v1/adapters`, `DELETE /v1/adapters/:id` | catalog, modelHost | On disk (the catalog's), and mounted on the served model through its `adapters` operation. |
| `POST /api/finetune/merge`, `/export` | modelHost, storage | Merge is the served model's `adapters.merge`: native MLX under that model's execution lease, in the process that holds it (a worker, when the host isolates its models). Export writes a manifest and takes no lease. Output goes under the `adapters/` and `exports/` storage entries. |

## Core-service additions this module drives

`catalog`: `list` filters (`query`, `vision`, `maxBytes`, `revisions: "snapshots"`, `companions`, `refresh`) and entries
with `details` (capabilities, quantization, sizes, support tier, snapshot) and adapter `rank`/`scale`; `rescan`;
`download` with a `revision`; `startDownload`/`downloads`; `publish` with `private`, `commitMessage` and progress.
`modelHost`: `serve`, `ResidentModel.uses`, and the lease's `adapters` operation. `CliTerminal`: `heading`, `table`,
`style.gradient`. `PanelSpec.developer`: the Models tab is not behind the Developer switch.

## Verbs

`get` (download a repo, or refresh a substring of a downloaded one), `ls`, `scan`, `fit`, `gc` (preview by default,
`--yes` deletes) and `upload`, with the flags and output they had as built-in commands. `fit` and the others load
lazily, so a host that only serves the routes never loads the fit code. `upload --path <dir> --upload-repo <org/repo>
[--private]` publishes through `catalog.publish`.

## Panel

`<mlx-models-panel>` (`./panel`, shadow DOM, no imports outside this package): the downloaded models with which one is served
and which are loaded, Serve; Hugging Face search with Download and live progress; the adapters on disk with Mount and
Unmount. It fires `mlx-models-changed` when the served model or the mounted adapters changed. The chat's adapter selector
(which mounted adapter a turn uses) is the chat's, not this panel's.

## Tests

Model-free: the routes over fake services, the verbs over fake catalogs and synthetic caches, the panel under happy-dom,
and the module through `loadModules`. The end-to-end download (panel, routes, catalog, the app's download owner, the Hub
downloader against a local fake Hub) is `apps/mlx-bun/tests/web/hub-lifecycle.test.ts`. Real weights: hub switch
between two models and adapter mount, unmount and merge through the default isolated server are run outside the
suite (see the pull request).
