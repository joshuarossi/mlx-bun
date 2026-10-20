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
skill directory. Memory is the first contributor (`@mlx-bun/module-memory/chat`), offered only while the vault exists.

## Browser panel

`src/panel/` defines `<mlx-chat-panel>`, the module's `panel` (`workspace: true`): the shell gives it the whole page, leads
the tabs with it, keeps it attached while another page shows (a turn in flight survives a visit elsewhere) and calls its
`enter()` and `leave()`. It renders into the light DOM on the web kit (`@mlx-bun/web-kit`): the host page links the kit's
tokens and base vocabulary, so the markup uses `.btn`, `.input`, `.tag`, `.dot` and `.notice` directly and `style.ts`
holds only the chat's own rules, written against the kit's token names. It imports only its own files, `protocol.ts` (the
data protocol it shares with the backend) and the kit. Each file has one job:

| File | Owns |
| --- | --- |
| `index.ts` | The element: markup, the narrow-screen drawer and its focus trap, the methods the host calls |
| `chat.ts` | The controller: per-turn state, dispatch of the server's frames to the parts below, the controls' wiring |
| `session.ts` | The socket over the kit's `createSocket`: status, reconnect while the page shows, resuming the open chat |
| `turn.ts` | The streaming reply: deltas, tool cards, the approval card, Sources, the meta line, `endTurn` |
| `history.ts` | The replayed thread and the message actions (Copy, Regenerate, Edit, the branch toggle) |
| `sessions.ts` | The recent-chats sidebar, its search and export |
| `composer/` | The message box: state, attachments, sampling and system-prompt popovers, `#` mentions, Send and Stop, the status and perf line |
| `app-context.ts` | The app-aware assistant: context pushes, `ui_navigate` and `ui_spotlight` (with `assistant.ts` and `ui-catalog.ts`) |
| `markdown.ts`, `rag.ts`, `voice.ts`, `adapters-panel.ts` | The markdown renderer, chat-with-files retrieval, the hold-to-talk mic, the adapter routing table |

The socket (`/ws/chat`) is one JSON-framed connection per tab. Leaving the page never closes it; after an unexpected
close it reconnects only while the chat page shows (otherwise on the next `enter()`), settles a reply that was streaming
and frees the composer, and on the new connection's `ready` reopens the chat it was in and re-asserts this browser's
settings. A served-model change (the kit's `HOST_EVENTS.modelChanged`, heard through `onHostEvent`) reconnects at once
when no turn is in flight. There is no client-side heartbeat: a dead server shows up as the socket's own close. The
socket and the routes (`/api/sessions/*`, `/api/settings/tool-approvals`, and the adapter and memory routes it reads) keep
their shipped root paths, resolved on the origin of the connection's `apiBase` through the kit's `createApi`.

What the panel needs from its host page, beyond its connection, is the `host` property (`ChatHost` in `panel/host.ts`,
all optional): a `mounted(panel)` callback, where a companion attaches through `panel.companionSlots()` (the sidebar
entry and its count, the consent card and its two actions, the greeting's chips: elements the chat keeps by id); a
`toolCard` hook (memory's provenance chips); the agent-tools `settings` section of the host's settings dialog;
`notify(message, kind)`, the host's toasts, without which a notice shows for about four seconds in the chat's own
`#chat-notice` live region beside the composer; and `app`, the host's pages for the assistant: `currentRoute()`,
`navigate(route)`, `currentView()` (the host's overlay, such as `memory-panel`), `wizardStep()` and `onChange(listener)`,
which the host calls when the route, view or step changed. Without `app` the chat is the only route, its own adapters
sheet (`adapters-panel`) the only view, and `ui_navigate` says the host cannot navigate; the panel never reads the
page's address or the host page's markup. Its methods for the host are `newChat`, `copyLastResponse`, `setCodingTools`,
`refreshAdapters`, `focusComposer`, `toggleThinking`, `recentChats`, `openSession`, `exportActiveChat`, `companionSlots`,
the narrow-screen drawer (`toggleDrawer`, `closeDrawer`, `drawerOpen`) and the popovers for the host's Escape sweep
(`popoverOpen`, `closePopover`). The empty state names the served model from the kit's `HOST_EVENTS.serverStatus`.
`panel/ui-catalog.ts` names the assistant's route ids (validated in server frames) and spotlight targets: the chat's
knowledge of this app, which should move to contributions once the shell lists them.

The assistant follows open shadow roots when it captures visible controls or resolves spotlight targets, so the job
modules' encapsulated forms remain available in its page context, and skips controls inside hidden pages or assistant
chrome. It pushes the page's context on every `ready` and every change the host reports (and when its adapters sheet
opens or closes), never on a timer. Routed spotlight requests navigate through the host and wait for its change and a
laid-out frame before resolving a control, including a panel's first visit or return after detachment.

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
[panel](tests/panel.test.ts) (happy-dom: markdown streaming parity; the turn lifecycle through the real element on the
kit's fake socket, covering normal completion, Stop, an upstream error, a dropped connection and its resume, socket
cleanup across reconnects, and the absence of a heartbeat; the host contract: notices with and without `notify`, the
assistant's context and navigation with and without `app`, the kit's host events, the companion slots; composer,
mentions, adapters, retrieval, the assistant). The app's boot test
([boot](../../apps/mlx-bun/tests/web/boot.test.ts)) runs the built bundle against `app.html` and covers the panel mounted
by the shell, its host side and its drawer. The opt-in
[real-weights test](../../apps/mlx-bun/tests/engine/chat-native.test.ts) (`MLX_BUN_APP_TEST_MODEL=<snapshot directory>`)
serves a model through the app and runs a greedy chat with a read-only tool call and a reopened session; with
`MLX_BUN_CHAT_TRANSCRIPT=<file>` it writes the transcript's structure so two builds can be compared.
