# Investigation: pi as a "built-in" terminal for mlx-bun

*2026-06-12. Question (PRODUCT_ROADMAP "Harness UX" / PLAN direction A):
can `mlx-bun pi` drop the user into a working pi agent session against
the locally running model — and what's the best mechanism? Sources:
https://pi.dev/docs/latest (sdk, tui, rpc, custom-provider pages) plus
direct inspection of the installed packages
(`~/.bun/install/global/node_modules/@earendil-works/*`, v0.79.1).*

## TL;DR

**Yes, and better than hoped.** pi is not just embeddable — it is a
Bun-native, MIT-licensed npm package whose own release binary is built
with `bun build --compile`, the exact toolchain mlx-bun's Phase 5
single-binary bundle already uses. The full interactive TUI (editor,
chat history, all built-in commands) is an exported SDK class
(`InteractiveMode`), not CLI-only internals. Four integration options
exist, they are not mutually exclusive, and the recommended path is:
ship the cheap subprocess launcher now, promote to a true in-binary
embed as the flagship. pi's RPC mode separately gives us the protocol
for the built-in web chat UI, so this investigation pays for direction
A's part 1 as well.

## What pi is, technically

- Four MIT-licensed packages, all v0.79.1, all from
  `github.com/earendil-works/pi`:
  `pi-coding-agent` (13 MB, the agent + CLI + SDK), `pi-ai` (4.9 MB,
  provider/streaming layer), `pi-agent-core` (1.3 MB), `pi-tui`
  (1.9 MB, differential-rendering TUI lib). ~21 MB total on disk
  before tree-shaking — negligible next to model weights, modest next
  to mlx-bun's current binary.
- **Bun-compile native**: `pi-coding-agent`'s `build:binary` script is
  literally `bun build --compile ./dist/bun/cli.js ...` — upstream
  ships a Bun single-file executable themselves. Embedding it in our
  Bun bundle is a supported configuration, not an experiment.
- Engines: node ≥ 22.19 (pi-tui uses `/v`-flag regexes — fails under
  node 18, fine under Bun ≥ 1.3.x, which mlx-bun already pins).
- Assets that must ride along in a binary (upstream's
  `copy-binary-assets` is the manifest): theme JSONs, a few PNGs,
  export-html templates, `photon_rs_bg.wasm` (image ops), and pi-tui's
  prebuilt `.node` natives (`darwin-arm64`/`darwin-x64` ship in the
  package).
- Local-model support is **already proven on this machine**:
  `~/.pi/agent/models.json` has an `mlx` provider
  (`api: "openai-completions"`, baseUrl + `sk-optiq-` key, compat
  flags) serving Qwen quants. mlx-bun's OpenAI surface is what pi
  expects.

## The four integration options

### Option 1 — `mlx-bun harness pi`: configure the user's existing pi

Write/merge the provider entry into `~/.pi/agent/models.json` (or drop
a tiny extension that calls `pi.registerProvider(...)` — the
documented programmatic route, which can even discover models
dynamically from our `/v1/models`). Validate with one tiny request,
print the launch command.

- **Effort**: hours. **Risk**: low (must merge, not clobber, user
  config — the docs' extension route avoids touching models.json at
  all). **Verdict**: do regardless; this is the harness-adapter
  pattern from the roadmap and it's nearly free.

### Option 2 — `mlx-bun pi` (v1): spawn the user's installed pi

Start our server, then spawn `pi` with a session-scoped provider
config (extension dir or env) pointing at it. If pi isn't installed,
print the install one-liner.

- **Effort**: a day with polish. **Risk**: version skew with whatever
  pi the user has; not "built-in" — two installs.
- **Verdict**: the right v1. Real UX win immediately, zero coupling.

### Option 3 — SDK embed (the real "built-in"): pi inside the mlx-bun binary

This is the one the question was really about, and the SDK is
explicitly designed for it:

- `createAgentSession({...})` builds a session; the
  `examples/sdk/12-full-control.ts` example shows **zero-discovery**
  embedding: in-memory `SessionManager`/`SettingsManager`/
  `ModelRegistry`, custom `ResourceLoader`, explicit tool list,
  runtime API keys — nothing leaks from/to `~/.pi` unless we want it
  to.
- `InteractiveMode` is exported: "full TUI interactive mode with
  editor, chat history, and all built-in commands", constructed from
  an `AgentSessionRuntime`. We do not rebuild a chat TUI from pi-tui
  primitives (the tui docs are explicit that components are for
  extensions, not a full-app kit) — we run *pi's own* TUI in-process.
- Provider wiring: register an `openai-completions` provider at our
  own server's baseUrl (loopback HTTP into our already-running
  `Bun.serve` — simplest and keeps one code path for external
  clients), models listed from our registry with real context-window
  numbers per device profile.
- Flow for `mlx-bun pi`: detect profile → ensure model → start server
  in-process → `createAgentSession` against `localhost` →
  `new InteractiveMode(runtime).run()`.

Open engineering questions (all look tractable, none look fatal):

1. **One process, two workloads**: the TUI event loop and the
   server/generation queue share the JS thread; mlx compute happens in
   native code but graph-build is JS-side (~ms-scale per decode step).
   TUI rendering is differential and cheap; needs a smoke test for
   input latency during decode, not a redesign.
2. **Bundle plumbing**: embed pi's asset list + pi-tui `.node`
   prebuilds + photon wasm into the Phase 5 compile. Upstream's own
   binary build proves each piece works under `bun build --compile`;
   our work is making *their* asset-path resolution find files inside
   *our* bundle.
3. **Version pinning**: pi moves fast (0.79.x); pin exact, upgrade
   deliberately, keep Option 2 as the fallback path when upstream
   breaks SDK surface.
4. **Identity**: embedded pi should read/write its own session dir
   (`~/.mlx-bun/pi-sessions` or similar) and not fight a user's
   standalone pi install. The full-control example shows every knob
   needed (`agentDir`, custom storage paths).

- **Effort**: ~1–2 weeks including bundle work and latency testing.
- **Verdict**: feasible and high-value; this is the appliance moment —
  one binary, one command, a real agent on a local model.

### Option 4 — RPC / JSON event-stream mode (not for the terminal — for the web UI)

`pi --mode rpc` speaks JSONL over stdin/stdout: `prompt`, `steer`,
`abort`, model control, state/stats queries, plus a streamed event
model (`message_update` deltas, `tool_execution_*`, `turn_*`) and even
an extension-UI sub-protocol. The docs name "custom frontends (web
dashboards…)" as a primary use case.

- **Verdict**: wrong tool for `mlx-bun pi` (we'd be rebuilding pi's
  TUI on top of pi), but the **right backbone for the built-in web
  chat UI**: `mlx-bun` serves a page; the server bridges
  WebSocket ↔ RPC events (or drives `AgentSession.subscribe()`
  in-process — same event shapes, no subprocess). Tool calls,
  steering, and progress come for free instead of us re-implementing
  an agent loop in the browser.

## Does this make sense as a feature?

Yes — it is arguably the highest-leverage product move available:

- It converts mlx-bun from "a server you point things at" into a
  complete local-AI appliance, which is the PRODUCT_ROADMAP north
  star verbatim.
- The marginal cost is small because the hard parts are already done
  on both sides: our OpenAI surface is SDK-verified, pi's SDK is
  designed for embedding, and both projects compile with the same Bun
  toolchain. MIT licensing removes the bundling question.
- One investigation, both deliverables: the same `AgentSession` event
  stream powers the embedded TUI *and* the web chat UI, so direction
  A's two halves share a core.
- Caveats worth stating: we take on pi's release cadence as a
  dependency; the agent quality ceiling is the local model's (12B
  OptiQ tool-calling is decent but this becomes the showcase — the
  Lucien-direction evals would tell us exactly how good); and the
  embedded TUI must not degrade decode throughput (measure, per house
  rules).

## Recommended sequence

1. **Now**: Option 1 + Option 2 (`mlx-bun harness pi`, subprocess
   `mlx-bun pi`). Days of work, immediate demo value, zero coupling.
2. **Next**: Option 3 spike — minimal embedded
   `createAgentSession` + `InteractiveMode` against the in-process
   server, *without* bundle work (run via `bun run` first). Gate: TUI
   stays responsive during 12B decode.
3. **Then**: fold pi's assets into the Phase 5 compile → true
   single-binary `mlx-bun pi`; reuse the session-event plumbing for
   the web chat UI (Option 4 shape, in-process).
