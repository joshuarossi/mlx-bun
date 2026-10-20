# @mlx-bun/web-kit

The browser kit mlx-bun panels and shells build with (design: [Modular application](../../ARCHITECTURE.md#modular-application)).
It is browser code with no workspace dependencies and no DOM access at import time, so a server-side inventory can import
a panel entry that imports it. A module's panel may import it (and nothing else outside its own files and `protocol.ts`);
a module's server code never does. `@mlx-bun/web-shell` and an app's browser code build on it too.

| File | Owns |
| --- | --- |
| `tokens.ts` | `TOKENS_CSS`: the one copy of the visual system (surfaces, ink, lines, the accent, state colours, type, shape, motion, layout), dark by default with `[data-theme="light"]` values. A host serves it to its page; custom properties cascade into every panel's shadow root. |
| `base.ts` | `BASE_CSS`: the component vocabulary (page structure, cards and lists, tables, controls, fields, status and feedback, progress, the log box, the step rail, the empty state) written against the tokens. A panel puts it ahead of its own rules in its shadow root; the host links it once for light-DOM panels and its chrome. |
| `dom.ts` | `$`, `el`, `h`, `esc`, `injectStyles`, `shadowStyles`, `listen`, `createDisposer`, `trapFocus`, `deepActiveElement`. |
| `api.ts` | `createApi(apiBase)`: the JSON client over a module's `apiBase`. Module paths (`history`) resolve under the base, root paths (`/library`) on the base's origin, so a panel works on this page's origin and in a native webview over a remote server. Methods never throw: a transport failure answers `{ ok: false, error: UNREACHABLE }`. `requestJson` is the throwing primitive. |
| `stream.ts` | `openEventStream(url, handlers, options)`: one `EventSource` wrapper for job streams and the metrics stream. Parses JSON, dispatches named events, closes itself on the terminal event (`end`), and is torn down by `close()` or an `AbortSignal`; nothing is delivered after. `byType` routes typed events. |
| `socket.ts` | `createSocket(options)`: a JSON-framed WebSocket that reports its status, reconnects after an unexpected close while `shouldReconnect()` says the page is active, ignores a superseded socket's late events, and makes `close()` final. |
| `format.ts` | `gb`, `mb`, `bytes`, `num`, `ms`, `uptime`, `rate`, `percent`, `tokens`, `relativeTime`, `shortName`: one way to show every measurement. |
| `testing.ts` (`./testing`) | Deterministic fakes for tests: `FakeEventSource`, `FakeWebSocket`, `fakeFetch(routes)`, `installFakes`. Never imported by production code. |

## Visual system

A quiet instrument panel for a local model server: layered neutral surfaces (`--bg`, `--surface`, `--panel`, `--raised`)
separated by hairlines (`--line`), the platform's own type (the app runs offline) with tabular numerals for every
measurement, one accent (`--accent`) for interaction and focus, and semantic colours (`--ok`, `--warn`, `--bad`) only for
state. Code keeps its own dark surface in both themes. Focus rings are visible, motion is short and respects
`prefers-reduced-motion`, and copy is sentence case.

## Tests

`bun test` here covers the client's envelope handling, the stream's normal completion, terminal event, dropped
connection and cancellation, the socket's reconnect and supersession rules, the DOM helpers under happy-dom, the
formatters, and the fakes.
