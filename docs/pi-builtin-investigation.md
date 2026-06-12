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

**Pros**: nearly free; respects the user's pi setup, sessions, themes,
extensions; zero version coupling; the dynamic-discovery extension
keeps the model list in sync with our server automatically.
**Cons**: requires pi to already be installed; not "built-in" — the
appliance story still has two moving parts; config-merge bugs are the
classic way to annoy users (the extension route mostly avoids this).

### Option 2 — `mlx-bun pi` (v1): spawn the user's installed pi

Start our server, then spawn `pi` with a session-scoped provider
config (extension dir or env) pointing at it. If pi isn't installed,
print the install one-liner.

- **Effort**: a day with polish. **Risk**: version skew with whatever
  pi the user has; not "built-in" — two installs.
- **Verdict**: the right v1. Real UX win immediately, zero coupling.
- **Bonus**: unrecognized flags pass straight through, so
  `mlx-bun pi -p "summarize @notes.md"` (pi's non-interactive print
  mode), `--mode json/rpc`, `--continue`, `--resume` etc. all work on
  day one without us implementing anything.

**Pros**: fast to ship; full pi feature surface via passthrough;
upgrades to pi arrive for free; failure modes are simple (no pi →
print install hint). **Cons**: still two installs; we can't control
the pi version (an upstream flag/behavior change can break our
launcher); per-run provider injection needs care so we don't pollute
the user's global config; process lifecycle (server + child TUI)
needs clean shutdown handling.

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
  one binary, one command, a real agent on a local model. `-p` and
  `--mode rpc/json` remain supported natively: `runPrintMode` and
  `runRpcMode` are SDK exports, so the embedded CLI keeps pi's
  headless modes.

**Pros**: the true appliance — one binary, no prior installs; we pin
and test the exact pi version we ship; full control of defaults
(session dir, tools, system prompt, model list per device profile);
in-process events shared with the web UI; offline-clean.
**Cons**: most engineering (asset bundling, latency validation); we
own the upgrade treadmill for a fast-moving 0.x dependency; embedded
pi diverges from the user's own pi config/extensions unless we
deliberately opt into discovery; binary grows ~20 MB.

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

**Pros**: documented, versioned JSONL protocol; UI-agnostic (web,
IDE, bots); steering/abort/stats built in; works with either the
subprocess or the embedded session as the engine. **Cons**: not a
terminal UX at all; strict framing rules to honor; the extension-UI
sub-protocol must be bridged if extensions prompt the user.

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

## Implementation plan

To be explicit about the recommendation: **the locally installed pi is
the v1 stepping stone, not the destination.** Users who have their own
pi always get first-class support (P1); the flagship `mlx-bun pi` ends
as the embedded, single-binary experience (P3/P4).

### P1 — `mlx-bun harness pi` (hours–1 day)

1. Detect pi (`which pi`, `~/.bun/bin/pi`, npm global); report version.
2. Generate an extension file (e.g. `~/.pi/agent/extensions/mlx-bun.ts`)
   that calls `pi.registerProvider("mlx-bun", ...)` with **dynamic
   discovery**: fetch our `/v1/models` at pi startup so the model list
   tracks the server. No models.json surgery; trivially reversible
   (delete one file).
3. Validate: tiny completion against the running server through pi's
   provider path; print `pi --provider mlx-bun` launch hint.
4. Failure modes: pi missing → print install one-liner; server down →
   offer to start it.

### P2 — `mlx-bun pi` v1: subprocess launcher (~1–2 days)

1. Ensure server: reuse a running instance if healthy, else start
   in-process and wait for readiness.
2. Resolve the pi binary; if absent, offer the installer.
3. Spawn pi with stdio inherited and a **session-scoped provider**: a
   generated `-e <tmp-extension>.ts` registering the provider for this
   run only (no global config writes), plus
   `--provider mlx-bun --model <profile default>`.
4. **Pass through all remaining argv** — this is where `mlx-bun pi -p
   "..."`, `--mode rpc`, `--continue`, `@file` args work for free.
5. Lifecycle: child exit → optionally keep the server warm (flag);
   SIGINT goes to the child (pi handles double-ctrl-C), server shuts
   down cleanly after.

### P3 — embed spike (≤1 week, run via `bun run`, no bundling yet)

1. Add pi packages as pinned deps (exact `0.79.x`).
2. Wire `createAgentSession` full-control style: in-memory
   registry/settings, our provider at the loopback baseUrl, session
   dir under `~/.mlx-bun/`, default tools, our system prompt.
3. Run `new InteractiveMode(runtime)` in the same process as the
   server.
4. **Gates** (house rule — numbers on this machine): editor latency
   during 12B decode subjectively clean + decode tok/s within noise
   of server-only; tool-call round-trip (read/bash/edit) works against
   the 12B; clean teardown.
5. Decide discovery policy: default isolated; `--pi-config` opt-in to
   the user's `~/.pi` extensions/skills/themes.

### P4 — single binary + shared event plumbing (~1 week)

1. Fold pi's asset manifest (theme JSONs, PNGs, export-html templates,
   photon wasm, pi-tui darwin `.node` prebuilds) into the Phase 5
   `bun build --compile`; patch/verify pi's asset-path resolution
   inside the bundle (upstream's own binary build is the existence
   proof).
2. CLI surface: `mlx-bun pi [pi-args]` → embedded `InteractiveMode`;
   `-p` → `runPrintMode`; `--mode rpc` → `runRpcMode`. Subprocess
   path (P2) remains as `--external-pi` fallback.
3. Web chat UI rides the same `AgentSession.subscribe()` events over
   WebSocket (Option 4 shape, in-process — no subprocess needed).
4. Upgrade policy: bump pi deliberately per release, re-run the P3
   gates as the regression suite.

## Recommended sequence

P1 + P2 now (days, immediate demo value, zero coupling) → P3 spike
with its latency gate → P4 single-binary flagship, reusing the event
plumbing for the built-in web UI.
