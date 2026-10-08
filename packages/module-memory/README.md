# @mlx-bun/module-memory

The existing memory feature, moved as is: a local Markdown wiki, read-only chat tools,
article/reference search and Git history, the synthesis DAG, its resumable stage workers,
and the `memory` / `setup` verbs and nightly launchd schedule. The feature's unfinished
work stays deferred; this migration changes ownership, not the pipeline or its inputs.

The module requires `storage` and `registry` and runs in the app. Its declared stores are
`wiki/`, `skills/` and `db/memory.sqlite` under the host's root. Activation and read routes
resolve paths with `create: false`; they create no vault, skill or database. `POST
/api/memory/init` explicitly initializes the vault. Existing default paths, `MLX_BUN_WIKI`
and `ServeOptions.memoryPaths` remain the app's composition policy, and explicit paths win.
The twelve read-only tools contribute through `chat.tool`; `chat.guidance` supplies the
hint and bundled skill. They are offered only when the vault exists, checked for each
new chat. Read tools never run synthesis.

`GET /api/memory/{status,list,search,article,links,history,diff}`, `POST /api/memory/init`
and `GET /v1/memory/synthesize` retain their root paths, response envelopes and SSE frames.
The CLI retains its flags, help, setup prompts, output and launchd program identity.
`createMemoryModule({ client, cli })` receives narrow host adapters for the dedicated task
model and terminal/system actions. A synthesis run owns its client's optional `release`
until its pipeline and all completions settle; shutdown aborts and joins every run. The
app keeps its lazily loaded task model and execution leases, and isolation holds the
current worker's residency lease for the whole run. It still uses the same Gemma task
model and chunk adapter; it does not substitute the chat model's ordinary generation API.

The `./panel` entry defines `<mlx-memory-panel>`, a persistent companion overlay
(`panel.overlay: true`) with no route or nav tab. It retains the full-height drawer,
article/history views, sidebar count, first-run consent and provenance chips. The host
calls `attachChat()` after its chat sidebar mounts and uses `toolCard`, `open`, `close`
and `isOpen` through the element. Requests honor `connection.apiBase`, including a remote
or prefixed URL. The light-DOM panel uses the existing page tokens and optional
`#chat-memory-entry`, consent/chip hooks and `#toasts`; standalone hosts can omit them.
One memory panel is mounted per document. Reattachment preserves its chrome listeners.

`src/skills/` is shipped as a package asset and embedded into the standalone binary.
`bun test` exercises the original domain expectations, temporary vaults and real Git,
registry activation, consent paths, and panel lifecycle without loading model weights.
