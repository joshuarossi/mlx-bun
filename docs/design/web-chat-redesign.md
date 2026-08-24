---
status: active
axis: USING
canonical-for: web-chat
plan-anchor: none
last-verified: 2026-08-23
---

# Web chat — the built-in chat surface (canonical design)

Scope: `src/web/` (app.html + `src/web/src/*.ts` built into `app.js`),
`src/pi-web.ts` (the WebSocket bridge), the thin REST wrappers the UI calls
(`src/memory/rest.ts`, `src/hub-rest.ts`, `src/serve/session-search.ts`,
`src/serve/model-admin-routes.ts`), `src/tool-approvals.ts`.

This is the one canonical doc for the web chat. It absorbs the former
beat matrix (`web-chat-beat-matrix.md`, kept as Appendix A), the web half
of `adapters-end-to-end.md` (§3.6 here), and the desktop-shell idea (one
History line). Status/changelog prose belongs in PLAN.md; this file holds
the design, the as-built contract, and the open items.

**Standing decision (2026-06-14): the chat UI is a Pi embed, not a
hand-rolled chat.** The browser talks to an in-process
`@earendil-works/pi-coding-agent` `AgentSession` over `/ws/chat`
(`src/pi-web.ts`). Pi owns the agent loop, tool execution, session files
(new/list/open/fork/delete, `SessionManager.forkFrom`), the tree
navigation behind edit/regenerate (`AgentSession.navigateTree`),
compaction, thinking levels, and the steering/follow-up queue. Nothing in
this design rebuilds those; the web work is (a) frames that expose them,
(b) UI that makes them legible, (c) the few capabilities Pi has no
concept of (memory vault, LoRA adapters, serving lanes, hardware fit,
the app-aware assistant).

---

## 1. Thesis and principles

**Thesis.** mlx-bun's web chat should not try to be a better ChatGPT. It
is the local chat surface where the assistant visibly, provably gets
better at knowing *you* (a git-tracked memory vault you can open and
diff), where switching to a domain-specific brain is a routing decision
(LoRA adapters, stackable), and where "local, private, fast" is shown on
screen (lane badge, tok/s, TTFT, provenance chips) instead of asserted.

**Doctrine (revised 2026-07-06): superset, not wedge.** Concede nothing a
daily LM Studio / Open WebUI / optiq-Lab user would miss — every
capability in Appendix A is MATCH, BEAT, or a written SKIP with a
substrate reason — and stack the differentiators on top. The
differentiators are the reason to switch, never an excuse for a missing
table stake.

**Principles.**

1. **Wire before you invent.** The server already had most of the
   capability (sampler set, structured output, adapters, memory tools,
   fork, approval gate); the highest-leverage work was wiring, and the
   remaining open items are still mostly wiring.
2. **Show, don't assert.** Privacy, speed, memory each get a UI proof.
3. **Progressive disclosure, one flag.** Chat is the whole app for a
   first-time user; Quantize / Fine-tune / Build Dataset / Status /
   Curves / Routes sit behind one persisted Developer toggle.
4. **Quiet retrieval, legible provenance.** Memory tools fire silently;
   every consulted article gets a small expandable chip.
5. **Speed is ambient.** tok/s, TTFT, context-fill, and the serving lane
   live next to the composer, server-reported, never client-inferred.
6. **Local-only is an honest simplification.** Single user, own machine:
   "runs on your machine, with your files" plus a per-call approval gate,
   not multi-tenant sandbox theater.
7. **Keyboard-first, mouse-complete.** Every primary action has a key
   path and a visible one.
8. **Never hijack.** No spotlight, panel, or approval ever traps focus or
   blocks the screen; the user is never in a state they have to escape.
9. **The bar for done is visual polish** at 375 / 768 / 1024 px and
   desktop, 200 % zoom, `prefers-reduced-motion` honored, no layout shift
   while streaming. Visual QA at phase boundaries has the standing of
   tests.

---

## 2. Architecture as built

### 2.1 The bridge: `src/pi-web.ts`

One `PiWebSession` per WebSocket connection wraps one Pi `AgentSession`.
Pi events map to frames through the pure, unit-tested `mapEventToFrames`
(`tests/pi-web.test.ts`). The frame types are exported **type-only** and
imported by the frontend (`src/web/src/chat.ts`), so contract drift
between browser and server is a compile error, not a runtime bug.

Client → server (`ClientMessage`):

| Frame | Purpose |
|---|---|
| `prompt` (text, images?) | send a turn; images ride as attachments |
| `abort` | stop the turn (`session.abort()`; verified to abort in-flight tool subprocesses) |
| `approval` (callId, decision, editedArgs?, alwaysAllow?) | answer a gated tool call; edited args are substituted in place; `alwaysAllow` persists to `src/tool-approvals.ts` |
| `set_thinking` | reasoning channel on/off (Pi thinking level medium ↔ off) |
| `set_coding_tools` | opt-in "let it touch files" (default OFF); takes effect on the *next* session because Pi bakes the tool list at session creation |
| `set_adapter` (id \| null) | active LoRA adapter for subsequent turns (`"a+b"` stacks) |
| `set_sampling` (scope session \| next_turn, temperature … seed) | full sampler set; `next_turn` is a one-shot override composed over the session-level one |
| `set_system_prompt` | per-session user prompt layered over the built-in surface prompt (applied per turn via `before_agent_start`) |
| `new_session` / `list_sessions` / `open_session` / `fork_session` / `delete_session` | Pi session lifecycle |
| `regenerate` / `edit_resend` / `switch_sibling` | message actions; all are sibling branches in the same session file via `navigateTree` |
| `context` (AppUiContext) | app-aware assistant: route/view/step + `uiSnapshot`, pushed on route and wizard-step change |

Server → client (`ServerMessage`):

| Frame | Purpose |
|---|---|
| `ready` (model, vision, audio, thinking, genDefaults) | capability negotiation; drives image attach, thinking toggle, sampling defaults |
| `turn_start` / `text_delta` / `thinking_delta` / `turn_end` (lane?) | streaming; `lane` is `"serial" \| "serial+spec" \| "batched"` from `src/serve/lane-registry.ts`, keyed by the assistant message's `responseId`, absent when unknown — never guessed |
| `tool_start` / `tool_update` / `tool_end` / `tool_approval_request` | tool cards and the approval card |
| `queue_update` (steering[], followUp[]) | live steering vs queued follow-ups |
| `history` / `sessions` / `siblings` | transcript replay, sidebar, `< i/n >` toggle data |
| `context` (tokens, contextWindow, percent) | context-window meter (same name as the client frame, opposite direction) |
| `coding_tools` (active, pending) | honest current-vs-pending state of the opt-in |
| `tool_approvals` (alwaysAllow[]) | durable always-allow set, on `ready` and after change |
| `ui_navigate` / `ui_spotlight` | app-aware assistant side channel, validated server-side |
| `error` | surfaced in the thread |

Injection hooks (all Pi extension hooks, no custom provider plumbing):
`before_provider_request` injects `adapter` (`injectAdapter`) and sampling
(`injectSampling` / `composeSampling`); `before_agent_start` injects the
user system prompt and the ambient app-context line; `tool_call` /
`tool_result` carry the approval gate and loop hygiene.

### 2.2 The frontend: `src/web/`

Vanilla TypeScript, no framework. `scripts/build-web.ts` bundles
`src/web/src/main.ts` into `src/web/app.js`, which `src/server.ts` serves
at `/assets/app.js`; `app.html` holds the markup and CSS. Runtime stays
self-contained (no CDN); the only vendored asset is highlight.js
(`src/web/vendor/`). The bundler errors if a value import ever pulls
server code into the browser bundle (type-only imports from `pi-web.ts`
are the intended seam).

| Module | Owns |
|---|---|
| `shell.ts` | DOM helpers, toast, focus trap, theme (auto/dark/light), shortcut sheet (Cmd/Ctrl+/), mobile drawer, hash router, connection pill + model identity poll, Developer toggle (`DEV_TABS`), `/dag` probe for the Routes tab |
| `chat.ts` | the WebSocket, thread render, streaming, tool cards, approval card, queue bar, Sources panel, memory-chip dispatch, app-context push |
| `composer.ts` | attachments, `#` mention picker, sampling popover (full set + Advanced + scope), system prompt + presets v1 (localStorage), adapter quick-select, perf strip (tok/s, TTFT, context, lane) |
| `sessions.ts` | sidebar list/search/fork/delete/export, full-text "in messages" search, sibling toggle, per-message actions (copy / regenerate / edit) |
| `markdown.ts` | `mdToHtml`, block-memoized `renderBlocksIncremental`, highlight pass, `[n]` citation linkify, Canvas toggle for html/svg fences |
| `memory-panel.ts` | Memory panel, provenance chips, personalized hero chips + first-run consent card |
| `adapters-panel.ts` | adapter routing table (three states, RAM cost, stacking) |
| `model-picker.ts` | `#nav-model` popover over `/library` with per-row `/fit` verdict |
| `hub.ts` | Model Hub panel (`/api/hub/*`), download progress via `/downloads` |
| `rag.ts` | client-side BM25 over attached-file text |
| `palette.ts` | command palette (Cmd/Ctrl+K), built via createElement |
| `assistant.ts` + `ui-catalog.ts` | `captureUiSnapshot`, spotlight resolution/overlay, route + spotlight catalog |
| `quantize.ts` / `finetune.ts` / `dataset.ts` / `status.ts` | the Developer tabs (job SSE via `api.ts` `jobStream`) |
| `protocol.ts` / `api.ts` | frontend-only shapes (job stream) and the JSON/SSE helpers |

`sw.js` + `manifest.webmanifest`: shell-only cache-first service worker
for installability and instant shell — explicitly not offline chat.

### 2.3 Tool surface and trust model

`webChatToolAllowlist(memoryEnabled, codingTools)` in `pi-web.ts`:

- Always: `read`, `web_search` (`WELCOME_TOOLS`) and the three app-aware
  tools (`get_current_app_context`, `navigate_app`, `spotlight_ui`).
- With a vault: the memory and reference read tools (`src/memory/tools.ts`).
- Opt-in only: `grep`, `find`, `ls`, and the gated `bash` / `edit` /
  `write`.

Everything except the gated three is `READ_ONLY_TOOLS` (auto-allowed).
Gated calls open the approval card: argument preview, editable arguments,
allow / deny / always-allow, auto-deny after `APPROVAL_TIMEOUT_MS`.
Always-allow is durable and keyed by tool name (`src/tool-approvals.ts`).
Loop hygiene (`LOOP_HYGIENE`): consecutive-identical-call blocking (with
the prior result inlined, since Pi's `tool_call` hook can only block with
an error result), a failed-retry budget nudge, and a turn cap with
force-finish. Format-aware tool-call repair lives in `src/tool-call.ts`
(`RepairKind`), tagged on the parsed call.

### 2.4 REST the UI depends on

`GET /v1/adapters` (mounted; `ram_bytes`), `GET /v1/adapters/available`
(on disk; `compatible`, `mounted`), `POST` / `DELETE /v1/adapters`;
`GET /fit`, `/library`, `/downloads`, `/stats`, `/v1/models`;
`/api/memory/{status,list,search,article,links,history,diff}` +
`POST /api/memory/init` (`src/memory/rest.ts`); `/api/hub/{local,search}`,
`POST /api/hub/download`, `POST /api/hub/serve` (`src/hub-rest.ts`);
`/api/sessions/{search,export}`; `/api/gc/{plan,execute}`;
`/api/jobs/:id/stream`. User-facing contract: `docs/reference/server-api.md`.

### 2.5 Regression harness

`tests/web-app.test.ts` (happy-dom) covers the pure client functions:
streamed-then-finalized output must equal one-shot `mdToHtml` (the
renderer's own parity oracle), Canvas fence detection and view-state
survival, `renderQueue` length semantics, `api()` envelope unwrapping,
`esc()` discipline on every interpolation site, adapter/model/hub row
renderers, mention picker, BM25, Sources panel, snapshot capture and
spotlight resolution, catalog validation. `tests/pi-web.test.ts` covers
the frame mapping, sampling composition, loop hygiene, and app-aware
tools. Frontend modules type-check in the same `tsc` pass as the server.

---

## 3. Surfaces

### 3.1 Onboarding / hero

Server-driven chips instead of static marketing copy: one drawn from real
vault content when `/api/memory/status` reports articles, one offering an
available adapter, and a first-run, skippable memory-consent card that
creates the vault via `POST /api/memory/init` — consent happens in the
same first minute as the first chat, not as a CLI step discovered later.
The system prompt (`buildWebChatSystemPrompt`) is deliberately short: a
long welcome prompt made the ~1B starter model greet instead of answer.

### 3.2 Composer and message actions

- Sampling popover: temperature / top_p / top_k plus an Advanced
  disclosure with `min_p`, XTC, repetition / presence / frequency
  penalties with context size, and seed; defaults from `ready.genDefaults`
  (per-model, not a hardcoded shape); scope control session vs next turn.
- System prompt field + presets v1 (name + prompt + sampling; localStorage
  only, no wire shape).
- Adapter quick-select (`#chat-adapter`) with a gear to the routing table
  (§3.6). A swap note says so: a new adapter starts a fresh KV segment.
- `#` mention picker: attached files and vault articles as one retrieval
  gesture.
- Perf strip: tok/s, TTFT, context-fill, lane badge (from `turn_end.lane`).
- Per assistant turn: copy, regenerate; per user turn: edit-and-resend
  with a `< i/n >` sibling toggle. All three are branches of the same Pi
  session (no new file), so history stays in one place. A full tree
  *view* is deliberately not built (open, §5).

### 3.3 Streaming render

`renderBlocksIncremental` splits the message at block boundaries, leaves
settled blocks alone, and re-parses only the live tail, throttled to
animation frames; `finishStreaming` runs one full `mdToHtml` pass so the
final DOM is byte-identical to a one-shot render (tested). Syntax
highlighting (vendored highlight.js) applies to completed blocks only.
Steering and follow-up queues render from `queue_update` with length
checks (the array-truthiness bug is fixed and regression-tested).

### 3.4 Tool cards and approval

Generic tool calls keep the running / ok / fail card. Memory and reference
tool calls render as a **provenance chip** (citation style, expandable,
opens the article in the Memory panel) — the "assistant looked something
up about you" moment reads differently from "ran a shell command". The
approval card (§2.3) is inline and non-blocking. The settings copy says
that toggling coding tools applies to the next new chat (`coding_tools`
frame), never implying immediacy Pi can't deliver.

### 3.5 Memory panel

Reachable from the chat sidebar, not a nav tab (memory is chat-adjacent,
it is the product, not a developer tool). Two screens: list (status strip
from `vaultStatus()`, search, personal articles and a `Reference/`
sub-list) and article (rendered content, inbound/outbound wikilinks line,
a History toggle backed by `/api/memory/history` and `/api/memory/diff` —
the "watch it self-heal after a correction" moment made literal, which
cloud memory UX structurally cannot offer). The agent-tool surface stays
read-only; only nightly synthesis writes (`memory-system.md`,
`memory-synthesis.md`). The plan's wikilink *graph* view is not built —
the panel shows a links line (open, §5).

### 3.6 Model and adapter switching

**Model picker.** `#nav-model` opens a popover over `/library`, each row
with the `/fit` verdict computed for this Mac (predicted decode tok/s,
safe context). There is **no in-process model swap**: the runtime is one
model per process (like mlx-lm), `POST /api/hub/serve` answers
`restart_required` with the exact `mlx-bun serve` command, and the picker
offers that command to copy. The live-swap mechanism that exists
(`ModelPool` spawn-overlap) lives only on the opt-in `--isolate` proxy,
which 501s `/ws/chat` — see `runtime-isolation.md`. Model Hub (`hub.ts`)
adds browse / HF search / download with progress; it never auto-downloads
or auto-serves.

**Adapters — the three-state model** (folded from
`adapters-end-to-end.md`; the design keeps the states separate and lets
the user move an adapter between them explicitly):

1. **Available** — on disk, compatible or not, costs nothing.
   `GET /v1/adapters/available` scans `~/.cache/mlx-bun-finetunes/` and
   `~/.cache/mlx-bun/adapters/` (`listAvailableAdapters`, `src/lora.ts`);
   `id` = directory basename; `rank` / `scale` / `base_model` read from
   `optiq_lora_config.json` or `adapter_config.json`, with the base repo id
   recovered from the stored snapshot path.
2. **Loaded / mounted** — `POST /v1/adapters {id, path}` into the running
   server; costs memory (`ram_bytes` on `GET /v1/adapters`);
   `DELETE /v1/adapters/:id` unmounts.
3. **Selected for this request** — the `adapter` field: `"none"` (default)
   | `"<id>"` | `"a+b"` (stacked, `resolveSpec`). Unknown id throws —
   loud, never a silent base fallback.

The routing table (`adapters-panel.ts`, behind the composer gear) shows
every on-disk adapter with badges for all three states, base-model / rank
/ size / RAM meta, mount / unmount / select / clear actions, and "stack"
tick-boxes that compose two mounted adapters as `"a+b"`. Selecting an
unmounted adapter mounts it first, then sends `set_adapter`; the
`before_provider_request` hook injects the id. Invariants: default none;
an adapter must be mounted before it can be selected; the quick-select and
the table are two views of one selection.

Compatibility as built: `compatible = base_model == null ||
bareName(base_model) === bareName(servedModelId)` — a bare-name match on
the base model, not the repo-id match the original note described.

The **CLI twin** is the Pi extension
`scripts/packaging/pi-extensions/mlx-bun-adapter.ts` (`/adapter`,
`/adapter <id>`, `/adapter off`; server via `MLX_BUN_URL`; same
`before_provider_request` mechanism, in-memory selection). It belongs to
the CLI reference (`docs/reference/cli.md`, alongside `serve --adapter`),
not to this doc.

### 3.7 Sessions

Sidebar with title filter, a full-text "in messages" fallback
(`/api/sessions/search`, confined to the session dir), fork / delete /
export (Markdown / JSON via `/api/sessions/export`). Titles derive from
the session name or first user message (`toSessionListItems`). On narrow
viewports the sidebar becomes a focus-trapped slide-over drawer.

### 3.8 Information architecture and settings

Chat is the product; everything else is a developer tool. One persisted
Developer toggle (`shell.ts`) reveals Quantize / Fine-tune / Build Dataset
/ Status / Curves / Routes. Curves is a separate full page (`/curves`,
labelled as such); Routes is a hash route whose tab visibility is gated by
a `/dag` probe so the compiled binary never shows a broken iframe. Deep
links keep working regardless of the toggle. Status's RAM/KV "Memory"
card keeps meaning system memory; the vault is always "Memory panel".
Settings group as Chat (sampling, thinking, coding-tools opt-in,
always-allow list), Memory (status, consent), Developer (the toggle).

### 3.9 Chat-with-files (RAG v1)

Attached text files below an inline threshold go into the prompt verbatim;
above it, a pure client-side BM25 retriever (`rag.ts`, no embeddings, no
network) selects top chunks, injects them as a numbered context block, and
the reply's `[n]` markers linkify into a collapsed Sources panel.
Citations survive regenerate / edit; they are not persisted into history
replay (needs a `HistoryItem` field — open). A vector upgrade over
`src/embed.ts` is explicitly later.

### 3.10 Code and Canvas

Fenced code gets copy + highlighting. `html` / `svg` fences get a
Preview | Source toggle: a lazily created `sandbox="allow-scripts"`
`srcdoc` iframe, never `allow-same-origin`, height-clamped, view state
preserved across re-render and streaming finish. The persistent Artifacts
side panel is not built (open, §5).

### 3.11 The app-aware assistant

The agent can see and act on the app it lives in — no screenshots, no
vision model in the loop. Product theory: guided tours fail on timing
(help before intent), chatbot help fails on grounding (intent without
state); this is the only shape with both, and the acceptance test is a
feeling — someone is there with you.

- **See:** on route / wizard-step change the browser pushes a `context`
  frame (route, view, step, `uiSnapshot` of visible interactive elements,
  capped ~120, agent chrome excluded). `get_current_app_context` returns
  it; a compact ambient line (route / view / step) is auto-prepended to
  every turn so the model never answers blind.
- **Navigate:** `navigate_app` validated server-side against the route
  catalog → `ui_navigate` → the hash router. Reversible, no approval.
- **Point:** `spotlight_ui` resolves ref → selector → label → catalog
  target against the last snapshot and shows a hand-rolled overlay:
  `pointer-events: none` (the control stays clickable through it), no
  focus trap, auto-dismiss in seconds, any input dismisses, reduced-motion
  honored. Model-invented selectors are a miss, never a throw.

Scope guard: these tools exist only on the pi-web bridge (never the
OpenAI / Anthropic API surface); the snapshot never includes cross-origin
content; approval-gated `ui_act` (fill this form, start this job) is open
work and must render through the §3.4 approval card.

### 3.12 Speed and trust as ambient proof

The perf strip's lane badge is server-reported per turn (risk: a stale or
wrong badge is a P0, because the differentiator rests on it being
trustworthy). Context-fill comes from Pi's `getContextUsage`. What is still
missing from the trust surface is listed in §5.

---

## 4. Tech-stack decisions

- **Vanilla, no SPA framework.** The framework-native ideas (block
  memoization, windowing, focus traps) port as functions; a migration is a
  multi-month distraction at this file's complexity. Recorded so a future
  session doesn't relitigate it without new evidence.
- **Typed module split over a single inline script.** The split's payoff
  is the typed WS/API contract, not navigability: the Phase 0 bug class
  (field-name drift, array truthiness, response-shape mismatch) became
  build errors.
- **Vendored, no-CDN assets only.** highlight.js is vendored; KaTeX was
  planned and is not vendored (open).
- **PWA = installability + instant shell**, never offline chat.
- **Theming:** auto / dark / light via `data-theme`, follows
  `prefers-color-scheme`; animations transform/opacity only and gated by
  `prefers-reduced-motion`.
- **A11y:** `role="log" aria-live="polite"` on the thread, focus traps with
  Escape-returns-focus on every overlay, a shortcut sheet with ChatGPT's
  vocabulary where sensible.
- **Hard rule for every overlay:** the spotlight is not a modal and must
  never be wired into the modal machinery (`closeTopOverlay` / `trapFocus`).

---

## 5. Open work

Nothing below has a PLAN.md phase; it is the backlog this doc owns.
Ordered by leverage.

**Residuals from the shipped phases (verified against src 2026-08-23):**

- KaTeX / math rendering — planned in the render pass, not vendored.
- Structured-output picker (JSON schema / grammar textarea with live
  validation) — server supports `response_format` and
  `guided_grammar|regex|choice`; no composer UI.
- Wikilink graph view — `/api/memory/links` exists; the panel renders a
  links line only.
- Session-preserving live model swap — blocked on a reload seam at the
  engine boundary (`runtime-isolation.md`); until then the Hub / picker
  hand back the restart command.
- RAG citations persisted into history replay (`HistoryItem` field).
- Long-thread windowing (anchored-to-bottom DOM recycling) — not built;
  months-long sessions are more likely here than in a stateless chatbot.
- Adapter metadata: the discovery rows are indistinguishable when several
  adapters share base / rank / scale; the trainer should stamp task / data
  / date (and a stable repo id) into the adapter config at save time.
- Overnight training from the web UI ("start before bed, wake up to an
  adapter"): the fine-tune wizard streams a job (`/api/jobs/:id/stream`),
  but a reconnectable monitor with completion → "available" hand-off is
  not designed. `--force-adapter` (serve pinned to one adapter for an
  unattended pipeline) is a CLI item, tracked in the CLI reference.

**Trust and speed differentiators (former Phase 4):**

- "Temporary chat" pill — provably never written to disk.
- Per-session disk-touch tally (files read / written) as a trust log
  distinct from tool cards; per-session "zero cloud calls" indicator.
- Prompt-cache-hit telemetry per turn ("reused N cached tokens").
- logprobs-derived confidence overlay (server already returns
  `logprobs` / `top_logprobs`).
- HLG tone-curve controls in the composer (today only on the Curves page).
- App-aware assistant maturity: a persistent minimized affordance on every
  view (Developer tabs included) that minimizes on engagement and
  re-expands only on invocation; process-state enrichment of the snapshot
  (job progress, field completion) beyond route / step.

**Stretch (former Phase 5; pick one or two at a time):**

- Full conversation tree view over the sibling groups Pi already stores.
- Persona bundles (system prompt + adapter + tool allowlist + memory scope)
  — presets v1's data model is shaped so this is a thin layer.
- Compare / split view: one prompt against base vs adapter, or two quant
  tiers, side by side with per-pane tok/s (optiq Arena's mechanics, plus
  the comparisons Arena cannot express).
- Approval-gated `ui_act` tools.
- Artifacts side panel, opt-in by heuristic; Mermaid; vector RAG upgrade;
  MCP client; Skills-style procedural memory (all Appendix A rows with a
  written state).
- Memory that graduates into a trained memory LoRA — roadmap; the UI must
  never claim it before it ships.

**Risks that stay live:** the superset doctrine ballooning scope (keep
items independently shippable; re-audit Appendix A at each boundary, not
mid-stream); the lane badge going stale in a mode transition (server-
driven only); always-allow persistence regressing to the fragility seen in
other desktop agents (versioned config keyed by tool identity, migration
test); the memory diff view unsettling a user (user-initiated inspection,
pause / reset one click away).

---

## History

- 2026-06-12 — minimal `/chat` page (SSE against `/v1/chat/completions`).
- 2026-06-14 — chat replaced with the Pi embed over `/ws/chat`
  (`src/pi-web.ts`), unified hash-routed SPA with the Developer tabs.
- 2026-06-16 — adapter discovery endpoint, web selector, and the Pi CLI
  extension (`adapters-end-to-end.md` written; its web half now lives in
  §3.6, the CLI half belongs to the CLI reference). The Tauri desktop-shell
  idea (`tauri-desktop-app.md`: separate repo, sidecar `mlx-bun serve`,
  WKWebView on `/#/chat`) was written in this period; it is tracked in
  neither PLAN.md nor STATUS.md and is not a plan — the only desktop-specific
  item kept here is that a shell must wrap the same page, no bespoke UI.
- 2026-07-06 — this plan merged three design visions and the market survey;
  Phase 0 (UI-only bug pass) and Phase 1 (block-memoized render,
  highlighting, full sampler popover, perf strip + lane, message actions,
  drawer, theme, shortcuts, a11y) landed. Beat matrix written (Appendix A).
- 2026-07-07 — Phase 2 (typed module split, memory panel + REST, adapter
  routing table, system prompt + presets, approval gate wired, Developer
  IA) and Phase 3 (files RAG, Model Hub, Canvas, per-turn sampling scope,
  self-healing tool calls + loop hygiene, app-aware assistant v1, command
  palette, full-text search, export, PWA) landed.
- 2026-08-23 — consolidated into this canonical doc; verified against src.

---

## Appendix A — beat matrix (condensed)

Every capability a user judges a local chat app by, judged against the best
current implementation in the surveyed field (mlx-lm, mlx-optiq, Ollama,
Open WebUI, LM Studio, Odysseus, Jan, Msty, GPT4All, AnythingLLM,
Enchanted, macMLX/mlx-serve, ChatGPT, Claude.ai). **MATCH** = parity is
enough; **BEAT** = structurally better because of something only we have;
**SKIP** = the engine lacks the substrate, stated so silence is never an
oversight. State column verified against src 2026-08-23. (Caveat: the
Odysseus rows rest on a public-web identification of that product; no
verdict flips on them.)

**Axis 1 — Chat fundamentals**

| Capability | Verdict | State |
|---|---|---|
| Streaming with a prominent Stop | MATCH | shipped |
| Stop aborts in-flight tool work, not just tokens | MATCH | shipped (verified via Pi abort) |
| Disk persistence, no account | MATCH | shipped (Pi sessions) |
| Regenerate | MATCH | shipped |
| Edit-and-resend as a sibling branch, `< i/n >` | MATCH | shipped |
| Full conversation tree view | BEAT | open |
| Live steering + follow-up queue while streaming | BEAT | shipped |
| Keyboard reach for stop / regenerate / new chat | MATCH | shipped |
| Full-message copy | MATCH | shipped |
| Delete a single message | MATCH | open |
| Compaction seam marked in the thread | MATCH | open |

**Axis 2 — Rendering**

| Capability | Verdict | State |
|---|---|---|
| GFM markdown (hand-rolled, competitive) | MATCH | shipped |
| Syntax highlighting, vendored | MATCH | shipped |
| LaTeX / KaTeX | MATCH | open |
| Mermaid | MATCH (low priority) | open |
| Block-memoized streaming (no O(n²) re-parse) | BEAT | shipped |
| Sandboxed HTML / SVG preview with view-source | MATCH | shipped (Canvas v1) |
| Persistent Artifacts side panel | MATCH (opt-in) | open |
| logprobs confidence overlay | BEAT | open (server side exists) |
| Structured-output / grammar picker | BEAT | open (server side exists) |

**Axis 3 — Model discovery and management**

| Capability | Verdict | State |
|---|---|---|
| Hardware-fit verdict per model, measured for this Mac | BEAT | shipped (picker + Hub) |
| Browse / search / download / load in one panel | BEAT | shipped, except live load (restart command) |
| Capability badges (vision, quant tier) | MATCH | shipped (Hub chips) |
| In-chat model switch without restart | MATCH | open (no in-process swap seam) |
| Swap preserves session history | BEAT | open (same blocker) |
| Resident multi-model pool | MATCH | open |
| Running-models resource table with adapter / KV tier / draft columns | BEAT | open |
| Per-layer quantization sensitivity visualization | BEAT | open |
| `mlx-bun launch <tool>` one-command coding-tool wiring | BEAT | open (CLI) |

**Axis 4 — Prompts, presets, sampling**

| Capability | Verdict | State |
|---|---|---|
| Full sampler set in the UI | MATCH | shipped (`logit_bias` not exposed) |
| Per-model correct defaults | MATCH | shipped (`ready.genDefaults`) |
| Per-message sampling scope | MATCH | shipped (`next_turn`) |
| Saved presets (prompt + sampling) | MATCH | shipped v1 (local only) |
| Slash-command prompt library with variables | MATCH | open |
| Model-string variant shorthand (`:no-think`) | MATCH | open |
| Persona bundles bound to a real adapter swap | BEAT | open |
| Explicit "warm this session" | MATCH | open |

**Axis 5 — Documents and RAG**

| Capability | Verdict | State |
|---|---|---|
| Zero-config attach-and-answer | MATCH | shipped |
| Transparent inline-vs-retrieval decision | MATCH | shipped (threshold in `rag.ts`) |
| `[n]` citations + Sources panel | MATCH | shipped |
| Unified `#` mention over files + vault | MATCH | shipped |
| Per-document retrieval-mode toggle | MATCH | open |
| Hybrid BM25 + vector + rerank | SKIP (for now) | open, deferred tier |
| Semantic search over the user's own chat history | BEAT | partial (full-text body search shipped; semantic open) |

**Axis 6 — Memory and personalization**

| Capability | Verdict | State |
|---|---|---|
| Visible, searchable memory (vault browser) | BEAT | shipped |
| Per-turn provenance chip | BEAT | shipped |
| Git history / diff of what synthesis changed | BEAT | shipped |
| Wikilink graph view | BEAT | open (links line only) |
| Scope control (session / surface / global) | MATCH | open |
| Pause vs reset as distinct actions | MATCH | open |
| Memory graduating into trained weights, marked in UI | BEAT | roadmap — never claim early |
| First-run consent in the hero | BEAT | shipped |
| Synthesis schedule status visible | MATCH | shipped (status strip) |
| Self-evolving procedural "Skills" | SKIP (v1) | open, deferred |

**Axis 7 — Tools and agents**

| Capability | Verdict | State |
|---|---|---|
| Tool calls as distinct cards | MATCH | shipped |
| Inline non-blocking approval cards | MATCH | shipped |
| Editable arguments before approval | MATCH | shipped |
| Durable tool-identity-keyed always-allow | BEAT | shipped (`src/tool-approvals.ts`) |
| Gated tools reachable in web chat (opt-in) | MATCH | shipped |
| Sandboxed Python tool | MATCH | open |
| Self-healing malformed tool calls | MATCH | shipped (`src/tool-call.ts`) |
| Loop hygiene (dedup, retry budget, cap, force-finish) | MATCH | shipped |
| Argument / diff preview before approval | BEAT | shipped (args); file diff open |
| Per-session disk-touch tally | BEAT | open |
| Curated default tool pack on first run | MATCH | partial (read, web_search, memory, app-aware) |
| MCP client | MATCH | open |
| Web search + URL fetch without keys | MATCH | `web_search` shipped; `web_fetch` not in the web allowlist |
| Approval-fatigue-aware defaults (read-only auto-allowed) | MATCH | shipped |
| `tool_choice` forcing in the chat UI | SKIP | API only by design |
| Visual agent-flow builder | SKIP | not planned |
| Deep-research trace panel | MATCH | open |

**Axis 8 — Multimodal**

| Capability | Verdict | State |
|---|---|---|
| Image attach + inference | MATCH | shipped (gated by `ready.vision`) |
| No text-only tax from the vision path | MATCH | verify |
| Image generation | SKIP | no substrate |
| Speech-to-speech voice | SKIP | no substrate |
| Native OS dictation / TTS | SKIP | no substrate |
| Document attach (PDF / DOCX) with inline-vs-RAG | MATCH | text files shipped; binary formats open |
| Global hotkey + floating companion window with screenshot | BEAT | open (needs a desktop shell) |

**Axis 9 — Performance and transparency**

| Capability | Verdict | State |
|---|---|---|
| Live tok/s + TTFT | MATCH | shipped |
| Context-window meter | MATCH | shipped |
| Serving-lane badge in the live chat | BEAT | shipped |
| Prompt-cache-hit telemetry per turn | BEAT | open |
| In-app benchmark tab | MATCH | open (harness exists: `scripts/bench-serve.ts`) |
| Compare / split view (base vs adapter, parity vs fast path) | BEAT | open |
| Concurrency / batch-slot indicator | MATCH | open |
| `/fit` surfaced beyond Status | BEAT | shipped (picker, Hub) |
| Auto-sized context to available memory | BEAT | open (UI); admission clamps server-side |
| Provable zero-cloud-calls indicator | BEAT | open |

**Axis 10 — Polish**

| Capability | Verdict | State |
|---|---|---|
| Dark + light, `prefers-color-scheme` | MATCH | shipped |
| `prefers-reduced-motion` | MATCH | shipped |
| Shortcut sheet (Cmd/Ctrl+/) | MATCH | shipped |
| Command palette (Cmd/Ctrl+K) | MATCH | shipped |
| Responsive to 375 px with a drawer | MATCH | shipped |
| PWA installability | MATCH | shipped |
| `aria-live` thread, focus traps, Escape | MATCH | shipped |
| Developer progressive disclosure | MATCH | shipped |
| Server-driven personalized onboarding chips | BEAT | shipped |
| Chat export (Markdown / JSON) | MATCH | shipped |
| Shareable links | SKIP | scope decision (single-user, local) |
| Full-text search across message bodies | BEAT | shipped |
| Session pins / folders | MATCH | open |
| Clean quit / no zombie process in a desktop shell | MATCH | n/a until a shell exists |

**Axis 11 — Sessions**

| Capability | Verdict | State |
|---|---|---|
| New / list / open / fork / delete | MATCH | shipped |
| Session search box | MATCH | shipped |
| Per-message branch-from-here | MATCH | shipped (edit / regenerate siblings) |
| Projects (scoped knowledge + memory + adapter) | BEAT | open (persona bundles) |
| Temporary / incognito chat, provably not on disk | BEAT | open |
| Multi-adapter compare | BEAT | open |
| Portable JSON export / import | MATCH | export shipped; import open |

**Axis 12 — App-aware assistant**

| Capability | Verdict | State |
|---|---|---|
| Agent sees the live UI (structured snapshot) | BEAT | shipped |
| Agent navigates the app | BEAT | shipped |
| Agent spotlights a control | BEAT | shipped |
| Approval-gated agent UI actions (`ui_act`) | BEAT (stretch) | open |

**The beats** (ranked by visible wow × structural defensibility): lane
badge in live chat · memory git-diff view · per-turn provenance chip ·
legible, stackable adapter routing · base-vs-adapter compare view · model
swap that preserves the session · prompt-cache-hit telemetry · provably
local temporary chat · diff preview before approval · full-text body
search · the app-aware assistant. The first four and the last two are
shipped; the rest are §5.
