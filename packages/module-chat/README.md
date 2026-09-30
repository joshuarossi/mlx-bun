# @mlx-bun/module-chat

The default assistant as an application module (`AppModule<"modelHost" | "storage" | "registry">`, design:
[Modular application](../../ARCHITECTURE.md#modular-application)): a Pi agent over the served model, one session per
browser tab on a WebSocket, saved chats, durable tool approvals, the tools other modules contribute, and the browser
panel. Nothing here imports an app or another module; the model, the storage root and the registry come from the host.
The mlx-bun app installs it (`apps/mlx-bun/src/modules.ts`) and runs it in its persistent state.

## What it serves

Declared in `src/manifest.ts`, at the paths the browser and external tools already use (all `mount: "root"`):
`GET /ws/chat` (the socket), `GET /api/sessions/search`, `GET /api/sessions/export` (read-only over the session
directory), and `GET`/`DELETE /api/settings/tool-approvals`. The host serves the socket (`createModuleSockets` in
`@mlx-bun/app-services`) and stops the module, which closes every chat, before it drains. A host that serves no
sockets refuses the module.

| Storage entry | Path under `MLX_BUN_HOME` | Holds |
| --- | --- | --- |
| `sessions` | `sessions/` | Saved chats, one Pi JSONL file each; the memory pipeline reads them too |
| `agent` | `pi-sessions/` | The Pi agent's own directory |
| `approvals` | `tool-approvals.json` | Tools the user chose to always allow (mode 0600; absent, corrupt or unknown-version data means ask again) |

Entries resolve when a chat or route first needs them, so a host that never chats writes nothing. An embedder's explicit
path for an entry wins (`createStorage`'s `explicit` map); `createChatModule({ readOnly, cwd })` carries what the host
decides beyond its services: a read-only server (no file-changing tool, every gated call denied) and Pi's working
directory.

## The model

Every model access goes through `modelHost`. A connection describes the current model from its wire when it starts
(`src/describe.ts`: `GET /v1/models` for capabilities and sampling defaults, `/stats` for the enforced context), so
the same code serves a model in this process and one behind an isolation worker, and a switch is followed because each
request asks the host for the *current* model. The Pi SDK takes a base URL, not a transport, so the module runs a private
loopback (`src/model-bridge.ts`: `127.0.0.1`, an ephemeral port, started with the first chat, a per-run bearer token, only
`POST /v1/chat/completions`) that leases the current model's `generate` for each request and releases the lease when the
response body ends or is cancelled. Pi's own model id, `local`, is the host's to route.

## What other modules contribute

`src/extensions.ts` reads the registry when each session is built: `chat.tool` contributions (a name, schema, `run`, and
the attestation `readOnly: true`; a tool that does not attest is never offered; an optional `available()` decides per
session) become Pi tools that run without an approval prompt, and `chat.guidance` contributions add a prompt hint and a
skill directory. Memory is the first contributor (`apps/mlx-bun/src/memory/chat.ts`), offered only while the vault exists.

## Browser panel

`src/panel/` defines `<mlx-chat-panel>`, the module's `panel` (`workspace: true`): the shell gives it the whole page, leads
the tabs with it, keeps it attached while another page shows (a turn in flight survives a visit elsewhere) and calls its
`enter()` and `leave()`. It renders into the light DOM with its own markup (`template.ts`) and stylesheet (`style.ts`),
takes the host page's design tokens and base element styles, and imports only its own files and `protocol.ts`, the data
protocol it shares with the backend. It carries its own markdown renderer, composer (attachments, sampling and system-prompt
popovers, `#` mentions, chat-with-files retrieval), recent-chats sidebar, adapter routing table, the hold-to-talk mic
(`voice.ts`, which calls transcription's `/v1/audio/sessions` routes over HTTP), and the app-aware assistant.

What the panel needs from its host page, beyond its connection, is the `host` property (`panel/host.ts`, all optional): a
`mounted` callback (memory attaches its sidebar entry and consent card), a `toolCard` hook (memory's provenance chips),
and the agent-tools `settings` section of the host's settings dialog. Its methods for the host are `newChat`,
`copyLastResponse`, `setCodingTools`, `refreshAdapters`, `focusComposer`, `toggleThinking`, `recentChats`, `openSession`,
`exportActiveChat`, the mobile drawer (`toggleDrawer`, `closeDrawer`, `drawerOpen`) and the popovers for the host's Escape
sweep (`popoverOpen`, `closePopover`). The host page also supplies a `#toasts` container and, for the assistant, its own
routes, overlays and spotlight targets (`panel/ui-catalog.ts` names them: the chat's knowledge of this app, which should
move to contributions once the shell lists them).

The assistant follows open shadow roots when it captures visible controls or resolves spotlight targets, so the job
modules' encapsulated forms remain available in its page context. Its wizard-step observer rebinds on navigation as
the shell mounts those panels, and skips controls inside hidden pages or assistant chrome.

## Tests

Model-free. [module](tests/module.test.ts) loads the module in a host with a scripted model host and drives a real chat on a
real listener with the real Pi SDK: the wire-described `ready`, a prompt, a contributed read-only tool, the answer, and the
saved chat reopened with the same transcript; the socket's close codes; the read-only policy.
[model-bridge](tests/model-bridge.test.ts), [describe](tests/describe.test.ts) and [extensions](tests/extensions.test.ts)
cover the loopback (authorization, leases), the description and the registry surface. The moved suites keep their
expectations: [chat-backend](tests/chat-backend.test.ts) (socket lifetime, Pi disposal, the approval gate, facts read at
connect), [chat-policy](tests/chat-policy.test.ts), [chat-runtime](tests/chat-runtime.test.ts) (the real SDK against fixed
loopback SSE, transcripts in app-supplied paths), [session-search](tests/session-search.test.ts),
[tool-approvals](tests/tool-approvals.test.ts), [web-tools](tests/web-tools.test.ts), [routes](tests/routes.test.ts), and
[panel](tests/panel.test.ts) (happy-dom: markdown streaming parity, the turn lifecycle through the real element, composer,
mentions, adapters, retrieval, the assistant). The app's boot test
([boot](../../apps/mlx-bun/tests/web/boot.test.ts)) runs the built bundle against `app.html` and covers the panel mounted
by the shell, its host side and its drawer. The opt-in
[real-weights test](../../apps/mlx-bun/tests/engine/chat-native.test.ts) (`MLX_BUN_APP_TEST_MODEL=<snapshot directory>`)
serves a model through the app and runs a greedy chat with a read-only tool call and a reopened session; with
`MLX_BUN_CHAT_TRANSCRIPT=<file>` it writes the transcript's structure so two builds can be compared.
