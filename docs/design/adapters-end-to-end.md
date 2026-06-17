# Adapters end-to-end — notes / TODO (2026-06-16)

Working notes for wiring trained LoRA adapters through the whole stack: Pi (CLI +
web), the web Chat page UI, and the server's discovery surface. Captured from the
2026-06-16 session (serving verified working; pi-extension mechanism confirmed from
a pi session example).

## The mental model — three distinct states

Josh's framing, which the whole design should keep separate:

1. **Available** — adapters that exist *on disk* and are *compatible* with the
   currently-served model. Not in memory, cost nothing. (Discovery problem.)
2. **Loaded / mounted** — adapters mounted into the *running server* via
   `AdapterManager`; they cost memory. (`POST`/`DELETE /v1/adapters`.)
3. **Selected for this request** — the `adapter` field on a given request:
   `"none"` (default) | `"<id>"` | `"a+b"` (stacked). (`resolveSpec`.)

You can be available-but-not-loaded, loaded-but-not-selected, etc. The UI and the
API should let you move an adapter between these states explicitly.

## What already exists (server side)

- `GET /v1/adapters` → lists **loaded** adapters (`id, path, rank, scale, size_bytes, mounted_layers`). `src/server.ts:1086`
- `POST /v1/adapters {id, path}` → **load/mount**. `src/server.ts:1094`
- `DELETE /v1/adapters/:id` → **unload/unmount**. `src/server.ts:1113`
- Request `adapter` field → `resolveSpec` (`src/lora.ts:231`): `"none"`/empty → `[]`
  (genuine base); unknown id → **throws** (loud, not a silent base fallback);
  `"a+b"` stacks. Default behavior is already "none".

So **loaded** and **selected** are done. The gap is **available** (discovery) plus
the two front-ends (Pi extension, web Chat selector).

## TODO

### A. Pi CLI/terminal — adapter via extension  *(default none)*

Mechanism (confirmed from the pi docs in-session): a Pi extension using the
`before_provider_request` hook to inject the field into the outgoing
OpenAI-compatible payload. `models.json` can't add arbitrary body fields — the hook
is the right tool.

Create `~/.pi/agent/extensions/mlx-bun-adapter.ts`:

```ts
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("before_provider_request", (event) => {
    const payload = event.payload as Record<string, unknown>;
    if (payload.model !== "local") return;        // only our local alias
    const adapter = process.env.PI_MLX_ADAPTER;    // unset → default none
    if (!adapter) return;                          // no field → server serves base
    return { ...payload, adapter };
  });
}
```

- Defaults to **none** (env unset → hook returns `undefined` → payload unchanged).
- Selection via `PI_MLX_ADAPTER=chunk pi --provider mlx-bun --model local -p "..."`
  (no native `-p --adapter` flag; unknown CLI flags get rejected). Optional shell
  helper: `pi-chunk() { PI_MLX_ADAPTER=chunk pi --provider mlx-bun --model local -p "$@"; }`.
- Put it in the global `~/.pi/agent/extensions/` dir so it loads for non-interactive
  `-p` too. `/reload` to pick it up.
- **Ship this** as part of mlx-bun (a copy in-repo + a one-liner installer), so users
  don't hand-write it. Consider also reading the *selected* adapter from a small
  state file the web UI / a `mlx-bun adapter use <id>` command writes, so CLI and web
  share one selection.

### B. Web Chat page — selector + load/unload  *(default none)*

Path: `src/web/app.html` (UI) ↔ `/ws/chat` (`src/pi-web.ts`) ↔ in-process Pi ↔ model.

- **Selector** in `app.html`: a dropdown of *available* adapters with **"none"
  selected by default**. Changing it sets the active selection for subsequent
  messages. Allow multi-select → `"a+b"` (resolveSpec already supports stacking).
- **Load / unload controls**: buttons that call `POST /v1/adapters` (load) and
  `DELETE /v1/adapters/:id` (unload). Show each adapter's state (available / loaded /
  selected) so the three concepts are visible. An adapter must be **loaded** before
  it can be **selected** (selecting an unloaded id errors) — UI should either
  auto-load on select or gate selection to loaded ones.
- **Plumb the selection into the request.** Since Pi runs in-process behind
  `/ws/chat`, the chosen adapter has to reach the payload Pi sends to the model.
  Two options:
  1. Register the same `before_provider_request` hook inside `pi-web.ts` and read the
     selection from the WS session state, or
  2. Set `adapter` directly on the model call where pi-web constructs it.
  The WS protocol (`src/pi-web.ts`) needs a new client→server message to carry the
  selected adapter id(s), and the `ready` message could carry the available list.

### C. Server — adapter **discovery** (the missing "available" list)

- Add a store the server scans for available adapters:
  - `~/.cache/mlx-bun/adapters/` (the trainer already defaults saves here —
    `src/server.ts:1653`) and/or a **sidecar next to the model dir**.
- New endpoint, e.g. `GET /v1/adapters/available` →
  `[{ id, path, source_repo, rank, scale, compatible }]`, where each entry is read
  from the adapter's `optiq_lora_config.json` (`source_model`, `rank`, `scale`).
- **Filter by the served model.** Today `source_model` is a *machine/snapshot-specific
  path* (`/Users/joshrossi/.cache/huggingface/.../snapshots/<hash>`), which won't
  match across machines/snapshots. Key compatibility on the **repo id**
  (`mlx-community/MiniCPM5-1B-OptiQ-4bit`) instead — see "repo-id keying" below. The
  server already tracks `repoId` per model; `compatible = adapter.source_repo === served.repoId`.

### D. Overnight training from the web UI

Goal (Josh): *"start a new training session before bed, wake up to a new adapter."*
Training must be fully drivable from the web UI — not just a script.

- A **training page / panel** in the web UI: pick base model + dataset, set params
  (rank / scale / num_layers / LR / dropout / iters / seq / segmentSize — the
  configurable-params task, mlx-lm defaults), **start**, and leave it running.
- **Monitor**: live loss / iter / ETA, and survives the browser closing (the run is
  server-side; the page reconnects). `POST /v1/fit` already exists
  (`src/server.ts:1652`) — needs a status/stream endpoint + a UI.
- **Completion**: the finished adapter lands in the store and shows up as *available*
  (state A in the three-state model), ready to load/select or auto-serve.
- This closes the loop with the chunk-task roadmap: iterate data → train overnight →
  wake to a scored adapter.

### E. `--force-adapter` for the nightly serving pipeline

Goal (Josh): spin up a server and say *"use this model AND this adapter"* without
per-request `adapter` fields — for an unattended nightly pipeline.

- New CLI flag, e.g. `mlx-bun serve <model> --force-adapter <id|path>`:
  1. **mount** the adapter at startup (load it), and
  2. **force it active as the default** for every request — overriding the normal
     "selected defaults to none." A request could still override, or `--force-adapter`
     could be a hard pin (decide; pin is simpler for a pipeline).
- Surface it on the ready card's `Perf`/serving summary so it's visible the server is
  adapter-pinned.
- Pairs with D: train overnight via the UI → serve the result with `--force-adapter`
  in the nightly pipeline.

## Cross-cutting / already-open threads to fold in

- **Repo-id keying for adapters** (from this session's discovery check): adapters
  currently record the model only as a fragile absolute path (`source_model` /
  `base_model_name_or_path`). Have the **trainer write the repo id** into the adapter
  config at save time, and match discovery on repo id. Robust across machines and
  snapshots. This is the prerequisite for B's selector and C's `compatible` filter.
- **mlx-lm-aligned training defaults** (pending, separate task): let users choose
  `rank / scale / num_layers / learning_rate / dropout` when starting a run, with
  defaults matching mlx-lm (`num_layers 16, rank 8, scale 20.0, dropout 0.0,
  LR 1e-5, max_seq 2048, batch 4, iters 1000, grad_checkpoint off`). The current
  `minicpm5-chunk-segmented` adapter is the *old* default (rank 16 / scale 1 /
  LR 2e-4 ≈ mlx-lm's scale 20 / LR 1e-5 effective). Flow through
  `DEFAULT_TRAIN_CONFIG` (`src/train/trainer.ts`) → `FinetuneSubmit`/`parseConfig`
  (`src/train/job.ts`) → the `POST /v1/fit` body (`src/server.ts:1652`).
- **Adapter storage location**: prefer a dedicated `~/.cache/mlx-bun/adapters/` store
  with repo-id metadata over writing sidecars into the fragile HF snapshot cache.

## Inventory (scanned 2026-06-16)

5 adapters on this machine, **all local — none in the HF cache** (no LoRA repos
downloaded, no `HF_HOME`/`HF_HUB_CACHE` override):

- **3 production** in `~/.cache/mlx-bun-finetunes/`: `minicpm5-chunk-final`,
  `minicpm5-chunk-segmented`, `minicpm5-chunk-seq8192` — all
  `mlx-community/MiniCPM5-1B-OptiQ-4bit`, rank 16 / scale 1 / all layers / 44.9 MB.
- **2 test fixtures** in `fixtures/adapters/`: `french`, `upper` (num_layers 4,
  7 MB, **no `source_model` recorded** — model-agnostic).

Design implications confirmed by the scan:

1. **HF cache is empty of adapters today** but the discovery scanner should still
   cover `~/.cache/huggingface/hub` (future LoRA pulls land there).
2. **`repo_id` / `source_repo` is absent in every real adapter** — only the
   snapshot *path* is stored. Repo-id keying must come first, plus a one-time
   backfill to stamp the existing three.
3. **The three MiniCPM5 adapters are indistinguishable by config** (same model /
   rank / scale / layers) — only the dir name differs. Discovery must surface the
   dir name as the id and ideally richer metadata (task, data, date) so the selector
   isn't three identical rows.

## Defaults & invariants to lock everywhere

- Selected adapter defaults to **none** (Pi extension, web UI, server) — base model.
- Unknown/typo'd id → **loud error** (already true server-side; surface it in the UI,
  don't silently fall back to base).
- Stacking (`"a+b"`) is supported end-to-end; UI can expose it as multi-select.
- An adapter must be **loaded** before it can be **selected**.
