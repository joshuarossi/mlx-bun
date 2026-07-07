# Web chat redesign: the definitive plan

Status: proposed · Owner: web/chat surface · Scope: `src/web/app.html`, `src/pi-web.ts`, `src/server.ts` (chat routes), `src/memory/*`, `src/lora.ts` · Horizon: one quarter, phased

This document merges three independent design visions, ten market-research
briefs, and a line-level audit of the current UI and backend into one
execution plan. It supersedes `docs/planning/chat-ui-vision.md` and
`docs/planning/chat-ui-vision-memory-first.md` as the working plan (keep
those two as historical inputs; this is the doc that gets executed against).
It also absorbs and re-prioritizes every item in `docs/planning/web-ui-pass-plan.md`
— those bug-fixes are folded into Phase 0/1 below by number.

---

## 1. Executive summary

**The thesis:** mlx-bun's web chat should not try to be a better ChatGPT. It
should be the only local chat surface where the AI visibly, provably gets
better at knowing *you*, where switching to a domain-specific brain is a
first-class routing decision instead of a filename in a dropdown, and where
"local and private" is a proof you can see on screen, not a claim in a
README. Every serious competitor surveyed — Ollama, LM Studio, Open WebUI,
Odysseus, Jan, Msty, macMLX — either has no personalization story at all
(the MLX-native peers, Ollama, LM Studio) or bolts memory on as a flat
prompt-stuffed fact list (Open WebUI, AnythingLLM, ChatGPT, Claude). None of
them combine automatic personalization **with** weight-level adaptation
(LoRA hot-swap) **with** native MLX serving speed **with** a legible,
auditable tool-trust model. That combination is mlx-bun's only defensible
wedge, and today the UI hides it: the backend (`src/pi-web.ts`, `src/memory/tools.ts`,
`src/lora.ts`, `src/server.ts`) already implements most of it; the 2737-line
`src/web/app.html` shows almost none of it.

**The strategic bet (revised 2026-07-06):** best-in-class is a **superset,
not a wedge**. The goal is the single best UI for macOS local AI, period —
so the qualification round is conceding *nothing*: for every capability a
user judges a local chat app by, we match or beat the best current
implementation, or we make a written skip decision with a substrate reason.
The acceptance test: nobody ever says "I miss how Ollama / LM Studio /
Open WebUI / optiq had X." The axis-by-axis requirement table lives in
[web-chat-beat-matrix.md](web-chat-beat-matrix.md) (11 axes, 112 capability
rows, each MATCH / BEAT / SKIP-with-reason) — it is the coverage checklist
every phase below is planned against. *(An earlier draft of this section
framed the bet as "don't chase Open WebUI's breadth or LM Studio's polish";
that conflated where the moat is with what to build, and is reversed.)*

**On top of that conceded-nothing surface**, we stack the three things no
competitor's architecture allows them to show: (1) memory with a vault you
can open, search, and watch self-heal after a correction — today that is
git-tracked articles + nightly synthesis (real, shipped); the "graduates
into a trained memory LoRA" rung is roadmap, not current capability (the
adapter runtime exists, the memory fine-tunes don't yet — the UI must never
claim it before it ships); (2) LoRA routing as a legible per-surface
decision, not a Python-API-only mechanism (optiq built the engine, never
the UI; LM Studio's own bug tracker confirms adapter hot-swap is
unsupported industry-wide); (3) serving speed and tool trust as ambient,
always-on proof — tok/s, TTFT, which lane is active (serial / spec-decode /
batched), and exactly what a tool call touched on disk — because we control
the whole stack from Metal kernel to composer pixel and nobody else
surveyed does. The differentiators are the reason to *switch*; they are
never an excuse for a missing table stake.

**The pragmatic constraint:** almost none of this requires new backend
capability. Session fork, tool approval, adapter-scoped KV, the memory tool
suite, structured output, the sampler extension set — all of it exists
server-side today with zero or thin UI. The fastest, highest-leverage path
is wiring existing capability to new UI, not a rewrite. Where a rewrite *is*
warranted (the streaming-render architecture, message-tree branching,
virtualized long threads), the plan says so explicitly and scopes it as its
own phase.

---

## 2. Where we are

### 2.1 What's genuinely good today

Read from `src/web/app.html` and `src/pi-web.ts` directly, not assumed:

- **A real, working streaming agent bridge.** `PiWebSession` in `src/pi-web.ts`
  is a legitimately sophisticated per-connection bridge over WebSocket:
  token/thinking deltas, tool-call cards with live per-call approval gating
  (`installApprovalGate`, `pi-web.ts:748-774`, 120s auto-deny via
  `APPROVAL_TIMEOUT_MS`), a follow-up/steering queue distinguishing live
  mid-stream steering from queued follow-ups (`queue_update` event,
  `pi-web.ts:390-397`), disk-persisted sessions with new/list/open/fork/delete
  (`SessionManager.forkFrom`, `pi-web.ts:704-714`), per-turn LoRA injection
  (`injectAdapter`, `pi-web.ts:412-418`), and per-turn sampling overrides
  (`injectSampling`) — all through a pure, unit-tested event-mapping layer
  (`mapEventToFrames`).
- **A distinctive, cohesive visual language.** A real design-token system
  (`:root` vars, `app.html:17-33`), gradient hero type, hairline cards,
  ambient blooms — reads as considered, not a generic Bootstrap clone, across
  all 7 tabs consistently.
- **A hand-rolled markdown renderer that is actually careful.** `mdToHtml`/`mdInline`
  (`app.html:1113-1238`) escape-then-restore code spans, gate link/autolink
  targets through `mdSafeUrl` against `javascript:` URLs, and support GFM
  tables/task-lists/fenced code with a working copy button — a rare area
  where the hand-rolled approach is already competitive with a library.
- **Real session depth.** Fork/list/delete round-trip through pi's own
  `SessionManager` and render in the sidebar with per-row actions
  (`app.html:1735-1736`).
- **Live perf instrumentation already computed.** Context-window meter
  (`app.html:1696-1703`) and post-turn tok/s + TTFT (`app.html:1667-1677`)
  exist — just under-designed as small dim text instead of a first-class
  signal.

### 2.2 The most damaging gaps

Ranked by severity, from the three-part current-state audit:

1. **(Critical) No personal-memory surface exists at all.** The memory tool
   suite (`memory_resolve/category/read/section/links/infobox/list/status/search`
   plus `reference_*`, `src/memory/tools.ts:60-76`) is silently wired into
   the web chat's tool allowlist whenever a vault exists
   (`webChatToolAllowlist(memoryEnabled)`, `pi-web.ts:78-83`) and a
   `memoryHint` is appended to the system prompt — but nothing downstream
   renders memory tool calls differently from a generic tool card, there is
   no vault browser, no status indicator, no way to see, search, correct, or
   trust what the model just read about you. This is the single largest gap
   between the product's stated identity ("local-to-you", MEMORY.md) and
   what ships.
2. **(High) LoRA routing is one flat, undescribed dropdown.** `<select id="chat-adapter">`
   (`app.html:615-618`) lists raw ids with rank (`${a.id}${a.rank ? " · r"+a.rank : ""}`,
   unescaped — a live XSS-shaped bug per finding #15 in `web-ui-pass-plan.md`).
   No description of specialty, no three-state (available/loaded/selected)
   visibility even though `/v1/adapters/available` already returns
   `compatible: boolean`, no multi-adapter stacking exposure even though
   `resolveSpec` in `src/lora.ts` already supports `"a+b"` composition.
3. **(High) The tool-approval UI is fully built and architecturally dead
   in web chat.** The approve/deny card with diff preview exists
   (`app.html:1586-1610`), but the browser session's tool allowlist is
   hardcoded to `WELCOME_TOOLS = ["read", "web_search"]` plus memory tools —
   all in `READ_ONLY_TOOLS` — so `bash`/`edit`/`write` (the only
   `GATED_TOOLS`) never reach the browser surface at all
   (`buildPiAgentSurface({ webTools: true, codingTools: false })`,
   `pi-web.ts:543`). The approval dialog only fires in pi's separate
   terminal/coding-agent embed.
4. **(High) No message-level actions.** No copy on assistant text (only
   inside code fences), no edit-and-resend, no regenerate, no branch-from-a-
   specific-message (only whole-session fork from the sidebar).
5. **(High) Mobile chat loses the sidebar with no replacement.**
   `@media (max-width:760px){#chat-sidebar{display:none}}` (`app.html:345`)
   — no drawer, no hamburger. New chat and all session management become
   unreachable on a phone viewport.
6. **(High) No in-chat model switching.** `#nav-model` is a read-only label
   with no click handler at all (`app.html:527`).
7. **(Medium) Streaming re-parses the entire message on every token.**
   `appendDelta` (`app.html:1522-1531`) does `a.text += delta; a.textNode.innerHTML
   = mdToHtml(a.text)` — full markdown re-parse + innerHTML replace per
   token. This is O(n²) over a response and becomes the visible bottleneck
   on exactly the fast, spec-decode-accelerated generations the product
   exists to showcase.
8. **(Medium) Sampling popover exposes 3 of ~11 server-supported
   parameters**, and the "recommended" defaults are hardcoded to one
   model's shape (`SAMP_REC`, `app.html:1824-1825`, MiniCPM5-tuned),
   silently wrong for every other served model (`web-ui-pass-plan.md` #14).
9. **(Medium) No syntax highlighting, no LaTeX, no diagram rendering.**
   Code fences are plain-escaped monochrome `<pre><code>` (`mdCodeBlock`,
   `app.html:1139-1143`).
10. **(Medium/Low) Dark-only theming, ~11 total `aria-*` attributes across
    2737 lines, no documented keyboard shortcuts beyond Enter/Shift+Enter,
    no chat search, generic non-personalized hero/empty-state.**

Plus the full tactical list already catalogued in `docs/planning/web-ui-pass-plan.md`
(queue-bar array-truthiness bug, library staleness, `[object Object]` adapter
error, dead `status-page.html`, Routes-tab 404 in the compiled binary, stale
vision copy, etc.) — folded into Phase 0/1 below by number, not repeated in
full here.

### 2.3 Free wins — backend capability the UI hides today

These require **zero new backend work**, only wiring:

| Capability | Where it lives | Current UI exposure |
|---|---|---|
| Full sampler extension set: `min_p`, `xtc_probability`/`xtc_threshold`, repetition/presence/frequency penalties + context windows, `logit_bias` | `src/server.ts` request schema (~`:403-414`, `min_p`/XTC doc-comments; line refs drift with the active dspark branch — grep `min_p` to relocate) | 3 of ~11 fields (temp/top_p/top_k) |
| `logprobs`/`top_logprobs` | `src/server.ts:425-431, 982-1044` | none |
| Structured output: `response_format` json_schema/json_object, `guided_grammar`/`guided_regex`/`guided_choice` via xgrammar | `src/server.ts:458-471, 1610-1625` | none |
| Memory tool suite + `memoryHint` | `src/memory/tools.ts`, `pi-web.ts:78-83` | none — fires silently |
| `vaultStatus()` (article count, git state, mtimes, schedule state) | `src/memory/vault.ts:1081` | none |
| `memory_links` (wikilink graph, inbound/outbound) | `src/memory/tools.ts` | none |
| Adapter three-state model: available (disk) / loaded (mounted) / selected (per-request); `compatible` flag; `"a+b"` stacking | `src/lora.ts`, `GET /v1/adapters/available`, `resolveSpec` | one flat single-select dropdown |
| Tool-call approval gate with diff/arg preview | `pi-web.ts:748-774`, `app.html:1586-1610` | dead code in web chat (allowlist excludes gated tools) |
| Fork-from-session (`SessionManager.forkFrom`) | `pi-web.ts:704-714` | sidebar-level only, not per-message |
| `Responses` API `previous_response_id` resumption, Anthropic `cache_control`/`tool_choice` forcing | `src/responses.ts`, `src/anthropic.ts` | API-only, no chat UI concept |
| Prompt-cache-hit telemetry (`cache_read_input_tokens`, `cached_tokens`) | server usage payloads | only the aggregate context meter |
| `GET /fit` hardware-fit prediction (decode tok/s, safe context per SKU) | `src/fit.ts` | none in chat (Status tab only, indirectly) |
| HLG tone-curve sampling (`hlg` request block) | `src/server.ts:449-457, 483-504`, standalone Curve Designer page | disconnected from main chat composer |

**Two near-free wins that DO need thin server additions** (verified 2026-07-06
— easy to mistake for pure wiring, budget them explicitly):

- **Lane badge**: the serving lanes (serial / spec-decode / batched) exist
  internally (`GenerationGateway` routing, `src/server.ts:1162-1168`) but
  **no field on any usage payload or WS frame reports which lane served a
  turn**. The perf strip's tok/s / TTFT / context-fill are client-computed
  already; the lane badge needs a small per-turn `lane` field added
  server-side (usage payload + the pi-web `turn_end`/usage frame) first.
- **Memory panel data**: `memory_list`/`memory_search`/`memory_links` are
  **agent tools** (model-callable, `src/memory/tools.ts`) and `vaultStatus()`
  is a library function — none have HTTP routes. The vault browser (§5.5)
  needs thin REST wrappers (e.g. `GET /api/memory/status|list|search|article`
  + a git log/diff read) added in Phase 2.

---

## 3. Competitive landscape

| Product | Best-in-class at | Structural ceiling vs. mlx-bun |
|---|---|---|
| **mlx-lm** (the oracle) | Correctness/API reference; continuous batching; byte-capped LRU prompt cache; tokenizer-declared capability flags | Zero UI of any kind — its own docs point users elsewhere. No memory, no adapter routing, no structured output, no vision at the server layer. We already win by existing. |
| **mlx-optiq** | Per-layer sensitivity-guided mixed-precision (weights + KV); Model Arena (blind A/B); Hub (browse+load+chat in one screen); multi-adapter hot-swap via `AdapterActivation` (Python API) | Proved the adapter hot-swap *mechanism* (~50MB/adapter, 10 resident ≈ 6.1GB) but never shipped it above the Python API — no UI, no CLI flag. No memory/personalization concept at all. |
| **Ollama** | Zero-friction install/run fusion; `ollama launch <tool>` (redirect Claude Code/Codex at itself); `:cloud` suffix hybrid; visible `ollama ps` resource table | No persistent memory, no LoRA routing, thin first-party GUI (borrows its "best chat UI" reputation from third-party clients). |
| **Open WebUI** | Broadest feature surface (RAG, Channels, RBAC, Functions/Pipelines, MCP, Arena+Elo); native tool calling preserves KV cache | Backend-agnostic by design → zero access to token-level internals (no spec-decode control, no adapter routing, no KV quant visibility). Memory is prompt-injection bounded by context window, not weight-level. Documented long-thread freeze bug (#23067). Enterprise-flavored (RBAC/Channels) — wrong shape for a single-user product. |
| **LM Studio** | Hardware-fit traffic-light on downloads; User/Power/Developer progressive disclosure; Presets (shareable, model-bound config); transparent inline-vs-RAG; Split View | Closed source. Zero memory/personalization layer — presets are static and manual. Zero LoRA hot-swap UI concept. Electron-heavier than a native shell. |
| **Odysseus** | Cookbook hardware-aware model recommender; self-evolving Skills (teacher-escalation authoring); persistent Memory (Observer/Reflector, dedup, nightly audit) | Not MLX-native (targets vLLM/llama.cpp, MLX via Ollama's separate backend). Publicly bad security posture (SSRF/auth-bypass CVEs, unsandboxed shell). No adapter/LoRA concept — customization is prompt/Skills-markdown only, not weight-level. "Vibe-coded" reputation. |
| **AnythingLLM** | Automatic memory extraction (Observer/Reflector, live "3/20" counters, workspace-vs-global scope) — the single feature reportedly driving installs | Memory is workspace-siloed prompt-stuffing, explicitly sent verbatim to whatever provider is configured (no on-device-only guarantee). No LoRA/adapter personalization at all. |
| **Jan** | Inline non-blocking MCP approval cards + global "Allow All"; router mode (single process, on-demand load/unload); MTP/spec-decode toggle in consumer settings (validates our own dspark serial-routing) | Generic single-thread chat core once you strip the MCP/assistant chrome; no memory, no adapter routing. |
| **Msty** | Split Chat (parallel synced multi-model panes); Persona Studio + Crew Conversations + Shadow Persona | Closed-source-leaning; feature-sprawl (Turnstiles/Forge Mode naming). No real adapter-weight mechanism — personas are prompt bundles. |
| **macMLX / mlx-serve** | Genuinely MLX-native, Python-free, same technical identity claim as us (OpenAI+Anthropic API, tiered SSD KV cache, Benchmark tab, quick-launcher hotkey) | Shallow personalization: no cross-session memory, no LoRA routing, basic-to-absent persona support. Proves "MLX-native + fast API" alone is **not** a moat — we already have peers there. |
| **ChatGPT / Claude.ai** | Artifacts/Canvas; highlight-to-scope-edit; edit-message=branch w/ linear toggle; two-layer transparent memory (explicit facts + background synthesis); Projects (scoped knowledge+memory) | Memory mechanism is a black box even though output is legible — synthesis runs on someone else's infrastructure, unauditable. No tree view (only linear branch toggle) — third-party extensions exist to fill this gap. No LoRA-equivalent — Projects route RAG context, not model weights. Voice mode is a hard, cloud-scale-economics problem. |

**What we'd lose vs. mlx-lm:** nothing — mlx-lm has no UI, no session
persistence, no adapter routing, no structured output at the server layer,
no vision at the server layer. Every "loss" is actually a gap we already
close by existing. The one thing to protect explicitly is **bit-exact
parity as a mode**: `--batch N` / flag-free paths must keep matching
mlx-lm's outputs exactly, because "drop-in replacement, losing nothing" is
a standing product promise (see MEMORY.md), not just a chat-UI concern.

**How we beat Open WebUI / LM Studio (revised):** by conceding nothing and
then stacking what they can't copy. Concretely, per the
[beat matrix](web-chat-beat-matrix.md): we MATCH every table stake a user
would miss — system prompts/presets, document chat with citations, in-app
model browse/download (optiq's Hub flow, plus a real `/fit` verdict per row
that optiq lacks), sandboxed HTML canvas, per-message sampling, session
auto-titling, export, shortcuts, themes, mobile — and we skip only where the
engine lacks the substrate (image generation, voice), in writing. The two
exceptions we deliberately don't chase: Open WebUI's multi-tenant enterprise
plumbing (Channels, RBAC) — wrong shape for a single-user local product, a
scope decision rather than a gap — and cloud-scale voice. THEN the wedge:
we're the only surface whose memory is **weight-level-capable** (git-tracked
vault + nightly synthesis today, memory-LoRA rung on the roadmap — not a
context-window fact list with a hard cap) and whose adapter routing is
**real** (LM Studio has zero adapter concept; Open WebUI is
backend-agnostic and structurally cannot see adapters at all). Both are
already true at the engine level — the redesign's job is to make them
visible, legible, and trustworthy, which neither competitor's architecture
permits even if they wanted to.

*(Caveat: the Odysseus row above rests on the research agent's public-web
identification — Cookbook recommender / Skills / Observer-Reflector memory /
SSRF CVEs. If that isn't the Odysseus meant, that row needs a re-run;
nothing else in this doc depends on it.)*

---

## 4. Design principles

1. **Concede nothing; differentiate on top.** The beat matrix
   ([web-chat-beat-matrix.md](web-chat-beat-matrix.md)) is the coverage
   contract: every capability row is MATCHed, BEATen, or SKIPped in writing
   with a substrate reason — never silently absent. Within that, the
   memory/LoRA flywheel gets the design attention (it's the reason to
   switch), but "it's just table stakes" is never a reason a table stake
   ships worse than the best competitor's version. The test for every
   release: would a daily LM Studio / Open WebUI / optiq-Lab user miss
   anything? If yes, that gap has a name and a written decision.
2. **Show, don't assert.** Privacy, speed, and memory are all *provable*
   locally (no network egress, real tok/s, an inspectable git-tracked vault).
   Every one of these claims gets a UI element that proves it, not prose
   that states it. This mirrors the CLAUDE.md ground rule "every perf claim
   gets a number" — extend it to every trust claim getting a UI proof.
3. **Progressive disclosure, one flag, not two apps.** LM Studio's
   User/Power-User/Developer toggle is the reference: one codebase, one
   settings switch, not a fork. Quantize/Fine-tune/Build-Dataset/Curves/Routes
   collapse behind a single "Developer" toggle so Chat is the whole app for
   a first-time user.
4. **Quiet retrieval, legible provenance.** Memory tools fire silently by
   design (never a context dump) but every consulted source gets a small,
   dismissable, expandable citation — the AnythingLLM/ChatGPT memory-panel
   legibility bar, applied to a strictly deeper (weight-level) mechanism.
5. **Speed is ambient, not a stat you have to look up.** tok/s, TTFT,
   context-fill, and which serving lane is active (serial / spec-decode /
   batched ×N) are always visible near the composer, the way LM Studio 0.4
   made context-fullness and processing state ambient chrome.
6. **Wire before you invent.** Prefer surfacing an existing backend
   capability over designing a new one. Section 2.3's free-wins table is the
   backlog triage order, not a suggestion.
7. **Local-only is an honest simplification, not a hedge.** Single-user,
   local-machine execution means tool access, file writes, and shell
   commands can be presented plainly ("runs on your machine, with your
   files") instead of building sandbox theater Open WebUI/Odysseus need for
   multi-tenant deployments we don't have.
8. **Keyboard-first for the power user, mouse-complete for everyone else.**
   Every primary action (new chat, send, stop, regenerate, switch
   model/adapter, command palette) has a keyboard path, but nothing is
   keyboard-only-discoverable — mirror ChatGPT's documented shortcut sheet
   (`Cmd/Ctrl+/`) as the baseline, not a stretch goal.

---

## 5. The redesigned chat experience

### 5.1 Onboarding / empty state

**New vs. today:** the hero ("Local. Private. Yours.", `app.html:564-570`)
currently shows 4 static marketing chips regardless of state. Replace with
server-driven chips: if a vault exists, one chip is drawn from real content
("Ask about {last-synthesized-article}"); if adapters are available, one
offers to try one; if this is a first run, a one-line skippable memory
consent card appears inline ("Let mlx-bun learn from this conversation? Two
clicks, reversible.") — because `mlx-bun memory init` today is CLI-only and
invisible to anyone who never opens a terminal. This directly serves the
"install to chat under a minute" north star: personalization consent should
happen in the same 60 seconds as first chat, not as a separate discovered
CLI step.

**Backend used:** `vaultStatus()` (`src/memory/vault.ts:1081`), `GET
/v1/adapters/available`, existing hero markup as scaffold.

### 5.2 The composer and message actions

**Composer additions (extend, don't rebuild):**
- **LoRA/persona chip** replacing the bare `<select id="chat-adapter">`:
  active adapter's name + one-line specialty description (falls back to
  "general-purpose" until metadata exists), available/incompatible adapters
  grayed by the `compatible` flag `/v1/adapters/available` already returns.
  A note appears on swap ("starts a fresh KV segment") since that's true.
- **Sampling popover** grows from 3 sliders to the full server-supported set
  behind an "Advanced" disclosure: `min_p`, XTC (`xtc_probability`/`xtc_threshold`),
  the three penalty families with context windows, `logit_bias`, seed.
  Defaults resolve per-model from `generation_config.json` (fixing the
  hardcoded MiniCPM5-shaped `SAMP_REC`, `web-ui-pass-plan.md` #14) instead of
  one hardcoded shape.
- **Perf strip** under the composer, always visible: tok/s, TTFT,
  context-fill %, and a **lane badge** (`serial · spec-decode active` /
  `batched ×N` / `parity mode`) — replacing the small dim tok/s text. This is
  the one thing no competitor's UI has, because none of them control the
  serving lane the way we do.
- **Unified `#`/`@` retrieval mention**: typing `#` opens a picker across
  *both* attached files and vault articles as one retrieval gesture (Open
  WebUI's `#`-mention pattern, extended so "attach a file" and "search my
  memory" are the same interaction, not two parallel systems).

**Message actions (new — currently only code-block copy exists):**
- Per assistant turn: copy full message, regenerate, "branch from here"
  (reuses `SessionManager.forkFrom`, currently only exposed at the
  whole-session level).
- Editing a user message creates a lightweight sibling with a `< 1/2 >`
  toggle above it — the ChatGPT/Claude convention users already have muscle
  memory for. **Do not** build a full tree-view graph in this phase (real
  effort neither incumbent bothered to ship); a tree view is a Phase 5
  stretch differentiator (see §6, and note both cloud incumbents ship only
  the linear toggle — a from-scratch tree view is a genuine, buildable gap
  we can claim later, not a launch requirement).

### 5.3 Streaming + steering

Fix the O(n²) re-render (`appendDelta`, `app.html:1522-1531`) by splitting
into completed-block + live-tail-block: parse paragraph/fence boundaries,
skip re-parsing completed blocks, only reprocess the tail (Streamdown/t3.chat's
block-memoization pattern, ported as an idea into the existing vanilla
renderer — no framework needed). Ship self-hosted syntax highlighting (Shiki
or a lighter alternative, applied only to completed blocks) and KaTeX for
math in the same pass, since code fences currently render as monochrome
plain text. This is not optional polish: on a fast local model (the whole
product pitch), the current renderer makes the *frontend* the visible
bottleneck.

Steering and the follow-up queue already work server-side
(`queue_update` carries distinct `steering`/`followUp` arrays,
`pi-web.ts:390-397`) but render broken today (truthy-tested instead of
length-tested arrays, `web-ui-pass-plan.md` #2) — fix as part of this pass
since it's touching the same render path.

### 5.4 Tool-call & approval display

Keep the existing running/ok/fail visual language
(`app.html:1545-1584`). Two concrete changes:
1. **Wire the web chat's tool allowlist to include gated tools** (`bash`/`edit`/`write`)
   behind an explicit, off-by-default "let it touch files" toggle in
   settings (`buildPiAgentSurface({ codingTools: true })` on that path) —
   so the already-built approval-card UI (`app.html:1586-1610`) stops being
   dead code. Extend the card to show editable arguments before
   approve/deny (LM Studio's pattern, beyond mlx-bun's current binary
   allow/deny) and persist "always allow this tool" to a real config file
   keyed by tool identity (fixing the fragile-persistence failure mode
   documented against Claude Desktop/Cowork in the research).
2. **Give memory tool calls a distinct card style** — not the wrench icon,
   something closer to a citation chip — so "the assistant looked something
   up about you" reads differently from "the assistant ran a shell
   command." This is the single highest-leverage rendering change in the
   whole plan given §2.2 finding #1.

### 5.5 Memory surface (view / edit / forget, LoRA indicator)

A real **Memory panel**, reachable from the chat sidebar (not a 7th peer tab
to Quantize/Fine-tune — memory is chat-adjacent, one click away, because
it's the product, not a dev tool). Contents:
- **Vault browser + search**, backed by `memory_list`/`memory_search`,
  with a `Reference/` sub-view for mlx-bun's own docs (clearly separated
  from personal articles) via `reference_list`/`reference_search`.
- **Per-article view with a git-log/diff toggle** — the "watch it self-heal"
  moment made literal: after a correction, a user can see the exact article
  diff from the next nightly synthesis. This is the sharpest wedge against
  ChatGPT/Claude's memory UX, which shows *what* is remembered but never
  *how* — because their synthesis runs on someone else's infrastructure.
  Ours runs locally and the mechanism itself is inspectable.
- **Status strip**: `vaultStatus()` already returns article count, git
  state, last-synthesis time — render it plainly.
- **Wikilink graph view** using `memory_links` (inbound/outbound per
  article) — cheap given the tool already resolves this data; a genuine
  "knowledge graph of what the model knows about you" view nobody else in
  the survey has because nobody else has a git-tracked personal wiki.
- **Per-turn provenance chip** on any assistant message that consulted
  memory tools (from §5.4) — links into this same panel.

### 5.6 Model & adapter switching

Make the nav model label (`#nav-model`, currently a dead `<span>` with no
click handler) clickable to a lightweight picker: what's loaded, hardware-fit
signal (green/yellow/red, LM Studio's pattern) computed against this
specific Mac's measured bandwidth via `GET /fit` — not a generic heuristic,
since we already have per-SKU fit prediction in `src/fit.ts`. Model swap
should preserve session history and re-prime cleanly (every competitor
surveyed is documented as bad at this — LM Studio has an open bug where
switching models clears the selector and forces manual reselection; a
genuinely smooth swap is a believable, demonstrable win).

Adapter selection: promote from flat dropdown (§5.2) to a routing table in
settings showing all three states (available on disk / loaded+mounted /
selected for this request) with RAM cost visible per loaded adapter (optiq's
own numbers: ~50MB/adapter, 10 resident ≈ 6.1GB — a concrete budget to design
the UI affordance against), and expose `"a+b"` stacking since `resolveSpec`
already supports it server-side.

### 5.7 Sessions / projects

Add a search box above the session list (trivial, local-only, full-text —
no reason to skip it given Claude's own title-only search is a widely-cited
annoyance and we have no server-cost constraint). On mobile, replace the
currently-vanishing sidebar (`app.html:345`) with a slide-over drawer
triggered by a hamburger — nothing fancier needed for v1.

A lightweight **persona/bundle** concept (system prompt + adapter selection
+ tool allowlist + memory scope, saved and nameable) is a Phase 5 item (see
§6) — not required for the core redesign, but the composer/settings data
model should be shaped so a "save this as a named bundle" action is a
thin layer on top, not a re-architecture.

### 5.8 Settings

Collapse into three groups: **Chat** (sampling, thinking toggle, tool
allowlist/gating), **Memory** (vault path, consent, synthesis schedule
status — read from `memory_status`), **Developer** (the progressive-disclosure
gate for Quantize/Fine-tune/Build-Dataset/Curves/Routes — see §8).

### 5.9 Structured output

Server already supports `response_format` json_schema/json_object and
`guided_grammar`/`guided_regex`/`guided_choice` via xgrammar
(`src/server.ts:458-471`) with zero UI anywhere. Ship a lightweight
schema/grammar picker in the Advanced sampling disclosure (§5.2) — even a
raw JSON-schema textarea with live validation is pure whitespace relative to
every competitor (mlx-lm has no `response_format` at all; most local UIs
don't expose it even when their server supports it).

### 5.10 Vision / multimodal

Vision is already wired end-to-end correctly (capability negotiation via
the `ready` frame's `vision` flag, `pi-provider.ts:93-100`). The only fix
needed here is the stale copy bug (`web-ui-pass-plan.md` #6: "switch to the
12B for vision" is wrong now that e2b/e4b/26B/31B are all vision-capable via
`visionCapable(m)`). No new UI work required for v1 beyond that correction
and folding image/doc attach into the unified `#` retrieval gesture (§5.2).

### 5.11 Artifacts / code

Fenced-code rendering gets a copy button (already exists) plus syntax
highlighting (§5.3). **Canvas v1 — fenced HTML rendered in a sandboxed
iframe with a view-source toggle — is a Phase 3 item** (optiq Lab ships
exactly this today; "I miss optiq's Canvas" is a disallowed outcome). The
full Artifacts/Canvas *side-panel* (persistent, versioned,
highlight-to-scope-edit) stays a Phase 5 stretch — both cloud incumbents'
own experience (OpenAI partially walked Canvas back in May 2026 for the
common case) argues for opt-in-by-heuristic (auto-open above ~10 lines of
code / high fence density), not a mandatory pane.

---

## 6. Differentiator features (deep treatment)

These five are the headline bets — the features that make this unmistakably
mlx-bun and structurally hard for any surveyed competitor to copy without
rebuilding their own serving stack or personalization architecture.

### 6.1 Memory as a visible, weight-grounded flywheel

Not a fact list (AnythingLLM, ChatGPT, Claude) — a git-tracked vault where
chat-time reads are strictly read-only (`src/memory/tools.ts`) and only
nightly synthesis writes (`docs/design/memory-system.md`). The UI's job:
(a) a provenance chip on any turn that consulted the vault, (b) a real
Memory panel (§5.5) with a git-diff toggle so a user can *watch* an article
evolve after a correction — literally the "self-healing through ordinary
use" story (`docs/design/the-dreaming-master-plan.md`) made visible instead
of asserted, (c) eventually, a visible marker distinguishing "this fact
lives only as raw context" vs. "this has been baked into your memory LoRA" —
a distinction no competitor's architecture can even express, since none of
them synthesize memory into trained weights.

### 6.2 LoRA-per-context routing, made legible

optiq proved the resident-multi-adapter mechanism works (~50MB/adapter,
6.1GB for 10 resident vs. 56GB for 10 full model copies) but shipped it
Python-API-only. LM Studio's own bug tracker confirms adapter hot-swap is
unsupported. mlx-bun already has `/v1/adapters`, adapter-namespaced KV, and
per-request injection working end to end (`src/lora.ts`,
`docs/design/adapters-end-to-end.md`). The UI work is turning this into a
routing table: which adapter is active per-surface, why (matched from
surface / explicitly selected), its RAM cost, and — the genuine escalation —
support for stacking (`"a+b"`) directly in the picker, something the backend
already does and no UI anywhere exposes.

### 6.3 On-device privacy, proven not asserted

A one-click "Temporary chat" pill (matching ChatGPT/Claude's composer-header
convention) that — unlike cloud temporary chat, which OpenAI's own
disclosures say is still retained 30 days for "safety" — can be made
**provably** never written to disk at all, because we control the whole
stack. Pair this with a per-session "zero cloud calls" indicator and a
running tally of what the agent touched on disk (files read/written this
session) as a trust surface distinct from generic tool-call cards.

### 6.4 Speed surfaced as a felt experience, not a hidden stat

The perf strip (§5.2) — tok/s, TTFT, context-fill, lane badge — is the
direct answer to "serving speed is the user metric" (MEMORY.md). No
surveyed competitor (including the MLX-native peers macMLX/mlx-serve, which
do have a Benchmark tab) integrates lane-awareness (serial vs. spec-decode
vs. batched) into the *live chat surface* itself — they show a benchmark
number in a separate tab, we can show which lane is running the actual
conversation right now. This directly explains latency variance instead of
letting it read as jank, and ties concretely into the active `dspark`
spec-decode branch.

### 6.5 Local tool transparency as a trust surface, not a permission dialog

Every competitor's tool-approval UX is either a blocking modal (old Jan,
Claude Desktop) or a binary allow/deny with no argument preview (most).
mlx-bun already has the approval round-trip built (`pi-web.ts:748-774`); the
differentiator is finishing it properly: inline non-blocking cards (Jan
v0.8.0's pattern) with editable arguments before execution (LM Studio's
pattern) and durable, tool-identity-keyed "always allow" persistence (fixing
the failure mode publicly documented against Claude Desktop). Combined with
§6.3's disk-touch tally, this reframes "the agent can run bash" from a scary
permission dialog into a legible, reviewable log — the natural trust story
for a single-user local product that structurally doesn't need Open WebUI's
sandbox theater.

---

## 7. Tech-stack & architecture decision

**Recommendation: stay vanilla-single-file, but stop hand-rolling
everything.** Do not migrate to React/Svelte/a SPA framework. Reasoning:

- The research is explicit that every framework-based pattern found
  (Streamdown's block memoization, react-virtuoso's windowing,
  Radix/Base-UI's accessible primitives) assumes a component-diffing
  runtime — but the *ideas* (memoize completed blocks, window a long list,
  trap focus in a popover) port cleanly into vanilla JS without importing
  the library. The current file already proves this pattern works (the
  hand-rolled markdown renderer is competitive).
- A framework migration is a multi-month distraction that trades a
  self-contained, no-build, no-CDN served single file (the current
  `app.html` header comment's own stated constraint) for a build pipeline,
  for a benefit (component reuse, cleaner state management) that matters
  more at team scale than at this file's actual complexity once the
  concrete gaps (memoized rendering, syntax highlighting, math, a11y) are
  closed directly.
- The three visions converged independently on the same conclusion ("no
  React needed, just a smarter diff in the existing vanilla renderer") —
  treat that convergence as signal, not coincidence.

**What does change:**
- **Split `app.html` into modules that build into the single served file**,
  not a runtime framework. At 2737 lines and growing (memory panel, adapter
  routing table, perf strip, message actions are all net-new surface), a
  single file becomes a real maintenance cost even without a framework.
  Introduce a minimal build step (`bun build` with inline output, still
  zero external CDN dependency at runtime) that concatenates
  `src/web/{shell,chat,memory,adapters,quantize,finetune,dataset,status}.{html,css,ts}`
  into the one file the server ships. This preserves every runtime
  constraint (self-contained, no CSP-breaking externals) while making the
  source tree navigable.
  **The split's primary payoff is the typed contract, not navigability**
  (amended 2026-07-06): once the inline script is TypeScript, it imports
  `ServerMessage`/`ClientMessage` from `src/pi-web.ts` and the job-stream /
  API response shapes from their source modules — and the single largest
  empirical bug class disappears at compile time. Look at what Phase 0
  actually fixed: `e.lr` vs `e.learning_rate`, array-truthiness on a WS
  frame, a response-shape mismatch, a dead string-enum — every one is
  contract drift between untyped inline JS and typed TS, and every one
  becomes a build error after the split. **Scheduled: the split is Phase 2's
  first work item** — before the memory panel and routing table add major
  new surface to the monolith, not after.
- **Frontend regression harness** (amended 2026-07-06 — this repo
  oracle-gates everything else; the UI can't be the one untested surface):
  (a) formalize the inline-script syntax check (extract `<script>`,
  `new Function()` it) as a test/hygiene-gate step instead of an ad-hoc
  command; (b) a `tests/web-app.test.ts` DOM-level unit file (happy-dom or
  equivalent) covering the pure client functions — `splitBlocks`/streaming
  memoization (streamed-then-finalized output must equal one-shot
  `mdToHtml` on a fixture corpus: the renderer's own parity oracle),
  `renderQueue`, `api()` error unwrapping, esc() discipline on
  interpolation sites; (c) post-split, type-checking the frontend modules
  in the same `tsc --noEmit` pass as the server. Playwright-class
  end-to-end stays out of scope until there's a model-free server stub to
  drive it against.
- **Inline, self-hosted Shiki (or a lighter alternative) and KaTeX** as
  vendored, no-CDN assets bundled at build time — a real dependency-weight
  tradeoff against the "no build, no CDN" constraint, but justified because
  monochrome code and raw-LaTeX-backslash output are concrete, embarrassing
  gaps (§2.2 #9) with no vanilla-hand-rolled alternative that doesn't
  reinvent a TextMate-grammar highlighter from scratch.
- **Hand-roll block-memoized streaming and message-list windowing** rather
  than adopt react-virtuoso — port the *idea* (completed-block skip-reparse,
  windowed DOM recycling anchored to bottom scroll) as vanilla functions.

**Tauri desktop compatibility:** the Tauri shell today wraps "the same page,
no bespoke UI" (`docs/design/tauri-desktop-app.md:50-51`). Keep that
contract — every feature in this plan ships to both surfaces for free by
construction, since nothing here depends on a browser-only API. The one
Tauri-specific opportunity (deferred to Phase 5, not required): a global
hotkey + floating companion window (mirroring ChatGPT macOS's Option+Space
and mlx-serve's Ctrl-Space quick-launcher) — a concrete way for the desktop
wrap to earn native-app status instead of being a browser tab in a frame,
made cheap by the vision pipeline already existing server-side.

**Theming:** add `prefers-color-scheme` handling and a light theme (dark-only
today, hardcoded `--bg:#000`). Respect `prefers-reduced-motion` on the
ambient bloom/shimmer animations.

**Responsive/mobile/PWA:** mobile drawer (§5.7); add a web app manifest +
minimal cache-first service worker for the app shell (installable
"add to home screen," zero-cost given the app is already a single served
page) — explicitly scoped as *shell-instant-load + installability*, not
meaningful offline chat (the app is useless without the local inference
server running, so deep offline-caching strategy is not worth over-investing
in). Test standalone-mode viewport height explicitly since browser chrome
disappearing changes available height in ways normal responsive testing
misses.

**A11y:** add `role="log" aria-live="polite" aria-atomic="false"` on the
message thread, throttled to paragraph/sentence boundaries (not per-token —
combining focus-move and live-region announcement in the same update is the
documented anti-pattern per WCAG ARIA23), verified against actual VoiceOver
testing rather than one blog post's guidance. Full keyboard tab order
through composer/sidebar/popovers, visible focus rings, Escape-to-close on
every popover with focus returned to trigger. Ship a `Cmd/Ctrl+/` shortcut
sheet matching ChatGPT's vocabulary where sensible (`Cmd/Ctrl+Shift+O` new
chat, `Shift+Esc` focus composer, `Cmd/Ctrl+Shift+C` copy last response) —
zero cost to originality, closes an embarrassing baseline gap, and "copy
last response" reuses the existing copy-button code.

**Long-thread performance:** windowed rendering (anchored-to-bottom DOM
recycling) once a session exceeds ~150-200 rendered turns — the
memory-flywheel/long-session north star means power users will accumulate
very long sessions over months, more likely here than in a typical
stateless chatbot, so this failure mode (documented against Open WebUI as
issue #23067) is a higher-probability event for us than for competitors.

---

## 8. Information architecture

**Chat is the product. Everything else is a developer tool.** Collapse the
current 7 hash-routed tabs (Chat / Quantize / Fine-tune / Build Dataset /
Status / Curves / Routes) behind a single top-level split:

- **Chat** (default, always visible) — the entire app for a first-time or
  casual user. Contains, reachable via sidebar/settings without leaving the
  view: Memory panel, adapter routing, sampling/structured-output advanced
  settings, model switcher.
- **Developer** (one nav toggle, LM Studio's User/Power-User/Developer
  pattern collapsed to a binary since we don't need three tiers yet) —
  reveals Quantize, Fine-tune, Build Dataset, Status, Curves, Routes as a
  sub-nav. Persisted as a local preference (don't re-ask every session).

This is not hiding capability — it's matching disclosure to audience. A
user who never intends to quantize a model should never see that tab; a
developer flips one switch once and gets everything, including the existing
tabs completely unchanged in their internal design. Status's RAM/KV "Memory"
card keeps its current meaning (system memory) — the personal-memory vault
gets its own distinctly-named panel (§5.5) precisely to avoid the homonym
confusion the audit flagged.

Routes (currently an iframe of a DAG, 404s in the compiled binary per
`web-ui-pass-plan.md` #17) and Curves (a separate full-page route, never
highlights in nav per #19) both move under Developer and get their standing
bugs fixed as part of the IA move (§9 Phase 1).

---

## 9. Phased roadmap

Each phase is independently shippable and includes the relevant tactical
fixes from `docs/planning/web-ui-pass-plan.md` by number. Ordered by
effort/reward, starting with free wins, ending with differentiator
features. The [beat matrix](web-chat-beat-matrix.md) is the coverage
checklist across all phases: at any release point, every matrix row is
either shipped, in a scheduled phase below, or a written SKIP — a MATCH row
with none of those three states is a planning bug.

### Phase 0 — Bug fixes, one UI-only PR (no server changes, ~2-3 days)

Ship first, blocks nothing, touches no backend:

- `web-ui-pass-plan.md` #1: fine-tune live stats field-name mismatch
  (`e.lr`/`e.tps` → `e.learning_rate`/`e.tokens_per_sec`).
- #2: queue-bar array-truthiness bug (`.length` guards, `app.html:1683-1684`).
- #4: `[object Object]` adapter-mount error (unwrap `data.error.message` in
  `api()`, `app.html:1080`).
- #5: quantize inspect result parsing (`support: boolean`, not string enum).
- #6: stale "switch to 12B for vision" copy → model-agnostic.
- #15 (partial): escape `a.id`/`a.path` interpolation in the adapter
  dropdown (`app.html:1897-1898`) — this is a live unescaped-HTML injection
  point, fix immediately regardless of the larger adapter-UI rework in
  Phase 2.
- #16: delete dead `src/status-page.html` + `scripts/status-page-stub.ts`.
- #18: CLI banner copy fix (`src/cli.ts:64`).

### Phase 1 — Free wins: wire existing backend, fix the render bottleneck (1-2 weeks)

The highest-leverage phase — almost all wiring of existing capability +
one architectural render fix. Two deliberate, thin server additions ride
along (scoped in §2.3's caveat): the per-turn `lane` field for the perf
strip, and the gc plan/execute endpoints (#9):

- **Streaming render fix** (§5.3): block-memoized append, replacing
  `appendDelta`'s full re-parse. This unblocks every other visual change in
  this phase since they all touch the same render path.
- Syntax highlighting (vendored Shiki or equivalent) + KaTeX, applied to
  completed blocks only.
- Sampling popover: full parameter set (`min_p`, XTC, penalty families +
  context windows, `logit_bias`, seed) behind an Advanced disclosure;
  per-model `generation_config.json`-sourced defaults (fixes
  `web-ui-pass-plan.md` #14 and #8). Wire end-to-end: popover → `set_sampling`
  WS frame → `SamplingOverrides` → `injectSampling` (all three currently
  hardcode 3 fields, `pi-web.ts:171-176`).
- Perf strip: tok/s, TTFT, context-fill, lane badge (serial/spec-decode/batched)
  under the composer. Server side: add the per-turn `lane` field to the
  usage payload + pi-web frame (see §2.3 caveat) — the badge must be
  server-driven, never client-inferred (risk #5).
- Message actions: copy full assistant message, regenerate, edit-message-as-branch
  with `< 1/2 >` toggle (reuses `SessionManager.forkFrom`).
- Adapter dropdown → chip with specialty description + `compatible` graying
  (still single-select in this phase; full routing table is Phase 2).
- `web-ui-pass-plan.md` #3 (library staleness), #7 (`sft_scope` control),
  #9 (gc affordance — needs the new `/api/gc/plan`/`/api/gc/execute`
  endpoints), #11-13 (the queued `listCanonical`/`visionCapable`/`supportTier`
  wiring, land as its own small PR once server-side lands), #20 (library
  "too big" row fix), #21 documented as a known limitation.
- Mobile sidebar → slide-over drawer.
- Session search box.
- `prefers-color-scheme` + light theme + `prefers-reduced-motion` guards.
- `Cmd/Ctrl+/` shortcut sheet + ChatGPT-vocabulary bindings.
- `role="log" aria-live="polite"` on the thread, focus-trap/Escape on
  popovers.

### Phase 2 — Module split, memory surface + adapter routing table (2-3 weeks)

The two headline differentiators, now that rendering is fixed and settings
have room — preceded by the structural fix that keeps the growing surface
honest:

- **Module split FIRST** (§7, amended): split `app.html` into
  build-concatenated `src/web/*.ts` modules (one served file unchanged at
  runtime) so the frontend imports `ServerMessage`/`ClientMessage` from
  `src/pi-web.ts` and job/API shapes from their source modules — the
  Phase-0 bug class (contract drift) becomes a compile error before the
  memory panel and routing table add major new surface. Ship the frontend
  regression harness (§7) in the same pass: formalized script-syntax gate,
  `tests/web-app.test.ts` over the pure client functions (streaming
  memoization vs. one-shot `mdToHtml` parity fixtures, `renderQueue`,
  `api()` unwrapping), frontend modules in the same `tsc --noEmit` pass.
- **Per-chat system prompt** (beat matrix Axis 4 — table stakes in every
  competitor, currently impossible: the web chat's prompt is hardcoded in
  `buildPiAgentSurface`/`buildWebChatSystemPrompt`): an editable
  system-prompt field per session, layered over the built-in surface prompt,
  carried on the WS session; **presets v1** (named system-prompt + sampling
  bundle, saved locally) shaped so Phase 5's persona bundles (adapter +
  tools + memory scope) are a thin extension.
- **Session auto-titling** (Axis 11): v1 derives from the first user
  message; model-generated titles optional and never queued ahead of real
  turns.
- **Vault-init endpoint** (§5.1 prerequisite): the first-run consent card
  creates the vault from the web UI — needs a thin
  `POST /api/memory/init` wrapping what `mlx-bun memory init` does in the
  CLI (today it's CLI-only and invisible to non-terminal users).
- Memory REST wrappers (prerequisite, server-side — see §2.3 caveat):
  `GET /api/memory/status|list|search|article` + a git log/diff read,
  thin delegating wrappers over `src/memory/vault.ts` / `tools.ts`
  internals. The agent-tool surface stays read-only and unchanged.
- Memory panel (§5.5): vault browser, search, per-article git-diff view,
  status strip, `Reference/` sub-view, wikilink graph via `memory_links`.
- Memory provenance chips on assistant turns that consulted memory tools
  (distinct card style from generic tool calls, §5.4).
- Personalized hero/empty-state chips driven by `vaultStatus()` +
  `/v1/adapters/available` (§5.1); inline memory-consent card for first run.
- Adapter routing table: three-state visibility (available/loaded/selected),
  RAM cost per loaded adapter, `"a+b"` stacking support in the picker.
- Model switcher: clickable `#nav-model`, hardware-fit badge via `GET /fit`,
  session-preserving swap.
- Tool-approval gate properly wired: `codingTools: true` opt-in toggle in
  settings, editable arguments before approve/deny, durable tool-identity-keyed
  "always allow" persistence.
- Structured-output picker (JSON-schema textarea + live validation) in the
  Advanced disclosure.
- Unified `#` retrieval mention (files + vault as one picker).
- Information architecture move: collapse Quantize/Fine-tune/Build
  Dataset/Status/Curves/Routes behind the Developer toggle (§8); fix
  `web-ui-pass-plan.md` #17 (Routes 404 in compiled binary) and #19 (Curves
  nav highlight) as part of this move.

### Phase 3 — Concede nothing: the table-stakes sweep (2-3 weeks)

(Added 2026-07-06 under the superset doctrine — the beat-matrix MATCH rows
a daily LM Studio / Open WebUI / optiq-Lab user would immediately miss.
Each item names its matrix axis.)

- **Chat-with-files RAG v1** (Axis 5): attach-and-answer over attached
  documents with `[n]` citation markers + a sources panel — optiq Lab's
  BM25 dependency-free bar is the v1 target; we have `src/embed.ts` for a
  vector upgrade later, but don't block v1 on it. Extend the unified `#`
  mention (Phase 2) so files and vault articles are one retrieval gesture.
- **Model Hub** (Axis 3): in-app browse (published quants / HF search /
  local) → download with progress → one-click load-to-server + new-chat,
  session-preserving hot-swap — optiq's Hub flow, PLUS the `/fit`
  hardware-verdict column per row that optiq lacks. "Install to chat under
  a minute" stops dead-ending at the CLI.
- **Canvas v1** (Axis 2): fenced-HTML blocks rendered in a sandboxed
  iframe with a view-source toggle (optiq's shipped pattern; the full
  Artifacts side-panel stays Phase 5).
- **Per-message sampling scope** (Axis 4): apply-to-next-turn-only option
  in the sampling popover (optiq's per-message temp/max-tokens/thinking
  granularity), on top of the session-level overrides from Phase 1.
- **Self-healing tool-call loop** (Axis 7): investigate what the pi SDK
  already retries; add format-aware malformed-call repair (we own the
  per-model parsers in `src/tool-call.ts`), consecutive-duplicate dedup, a
  retry budget, and a loop cap with force-finish — small local models
  malform calls more than cloud frontiers, so this matters more here than
  it does for optiq.
- **Stop kills tool subprocesses** (Axis 1): verify/wire abort through the
  pi tool layer so Stop ends running bash/web-fetch work, not just the
  token stream.
- **Chat export** (Axis 10): Markdown/plain-text per session; portable
  JSON export/import (sessions are already local JSON on disk).
- **Command palette** (Axis 10, `Cmd/Ctrl+K`): new chat / session search /
  model + adapter switch / thinking toggle / theme.
- **Full-text session search** (Axis 10 BEAT): body search, not
  title-only — no cloud indexing-cost excuse applies locally.
- **PWA installability** (Axis 10): manifest + shell service worker
  (installability + instant shell, explicitly not offline chat).

### Phase 4 — Trust & speed differentiators (1-2 weeks)

- "Temporary chat" pill — provably never written to disk.
- Per-session disk-touch tally (files read/written this session) as a
  trust log distinct from tool-call cards.
- Prompt-cache-hit telemetry surfaced per turn ("served from cache").
- logprobs-derived confidence visualization (optional, behind Advanced) —
  wire the existing `logprobs`/`top_logprobs` server support into an
  opt-in per-turn confidence overlay.
- HLG tone-curve controls folded into the main chat composer (currently
  disconnected, only reachable via the standalone Curve Designer page).

### Phase 5 — Stretch differentiators (ongoing, pick 1-2 per quarter after Phase 4)

The next tier of unmistakable bets:

- Full conversation tree view (not just linear `< 1/2 >` toggle) — a
  genuine gap neither ChatGPT nor Claude has shipped natively.
- Persona/bundle system: named (system prompt + adapter + tool allowlist +
  memory scope) bundles, switchable in one click, exportable/importable.
- Compare/split view: same prompt against two adapters or two quant tiers
  simultaneously (Msty's Split Chat pattern, repointed at LoRA A/B testing
  instead of cross-vendor model shopping).
- Overnight/background training loop with a persistent monitor and
  completion notification ("wake up to a new adapter") — closes
  `docs/design/adapters-end-to-end.md` §D, currently PENDING.
- Tauri-specific: global hotkey + floating companion window with instant
  screenshot capture (vision pipeline already exists).
- Opt-in-by-heuristic Artifacts/Canvas side-panel for long code/HTML blocks
  with highlight-to-scope-edit (Canvas v1 iframe ships in Phase 3).
- MCP client support (beat matrix Axis 7 — table stakes for 2026 agentic
  chat per Open WebUI/LM Studio/Jan; moderate-large build behind the
  existing tool plumbing, scheduled here rather than silently absent).
- Skills-style self-evolving procedural memory (Odysseus's pattern; large
  separate system, matrix SKIP-for-v1 — revisit once the memory panel has
  usage data).
- Mermaid diagram rendering (matrix Axis 2 — add if the code-heavy audience
  demands it; completed-block hook makes it cheap to slot in).
- Vector upgrade to chat-with-files RAG (BM25 v1 → `src/embed.ts` hybrid).

---

## 10. Success metrics & risks

### Success metrics

- **Memory visibility:** % of sessions where a memory-consulting turn shows
  a provenance chip (should approach 100% of turns where memory tools
  actually fired — a wiring correctness metric, not an engagement metric).
- **Adapter routing usage:** adapter-swap events per week per active user,
  post-Phase-2 vs. pre-redesign baseline (currently near-zero given the
  dropdown's poor legibility).
- **Render performance:** p95 time-to-paint for a 2000-token streamed
  response, measured on the M4 Pro reference machine per the `benchmark.sh`
  discipline — before/after the block-memoization fix, quotable only from a
  preflight-gated run.
- **Tool-approval engagement:** % of gated-tool calls that get an explicit
  approve/deny vs. auto-deny timeout (a proxy for whether the trust surface
  is legible enough to act on, not just present).
- **Mobile session continuity:** % of mobile sessions where a user
  successfully switches sessions via the new drawer (currently impossible).
- **A11y baseline:** VoiceOver walkthrough of a full send→stream→tool-call→
  approve cycle completes with no unannounced state changes.

### Top risks & mitigations

1. **Scope creep into a framework rewrite.** Mitigation: §7's explicit
   recommendation against a SPA framework migration, with the reasoning
   documented so a future session doesn't relitigate it without new
   evidence.
2. **Memory panel becomes a context-dump UX that violates "quiet retrieval"
   (Design Principle 4).** Mitigation: provenance chips are collapsed by
   default, expand-on-click only; no chat-thread content is duplicated into
   the panel automatically.
3. **Adapter routing table adds setup friction before first chat**, cutting
   against "install to chat under a minute." Mitigation: the routing table
   is progressive disclosure behind settings; the composer chip default
   ("general-purpose", no adapter) requires zero configuration.
4. **The IA collapse (Developer toggle) hides a capability an existing user
   relies on daily** (e.g. someone who lives in Quantize). Mitigation: the
   toggle persists as a local preference and is one click, not a
   re-onboarding flow; existing deep-links (`#/quantize` etc.) keep working
   unchanged.
5. **Perf-strip lane badge becomes stale or wrong** during a mode
   transition (e.g. spec-decode falling back to serial mid-session).
   Mitigation: badge is server-driven per-turn from the same instrumentation
   already used for tok/s, not client-inferred; treat any mismatch as a P0
   bug since the entire differentiator rests on it being trustworthy.
6. **The tool-approval "always allow" persistence reintroduces the exact
   fragility documented against Claude Desktop** (resets on update). Mitigation:
   store approvals in a versioned, file-backed config keyed by stable tool
   identity from day one, with an explicit migration test in CI across a
   simulated version bump.
7. **Memory git-diff view surfaces something the user finds unsettling**
   (seeing exactly how much was inferred about them). Mitigation: frame the
   diff view as user-initiated inspection, not a push notification; pair
   with the existing pause/reset actions (already a good ChatGPT/Claude
   pattern) so the "off switch" is never more than one click from the
   panel that shows the most.
8. **(Added 2026-07-06) The superset doctrine balloons scope until nothing
   ships.** Matching 112 matrix rows is a quarter-plus of work; the
   original wedge-only framing failed by conceding too much, and the
   correction can fail by attempting everything at once. Mitigation: the
   phases stay independently shippable and strictly ordered
   (fundamentals → structure → table-stakes sweep → trust/speed →
   stretch); within Phase 3 the sweep is ordered by "what would a daily
   competitor user miss first"; the matrix's shipped/scheduled/SKIP states
   are re-audited at each phase boundary rather than renegotiated
   mid-phase.
9. **(Added 2026-07-06) The untested, untyped frontend erodes as it
   grows.** Phase 0's bug class (contract drift between inline JS and
   typed TS) recurs with every new surface until the module split lands.
   Mitigation: the split + frontend regression harness are Phase 2's
   FIRST work item (§7), before the memory panel and routing table add
   the next thousand lines; until then, every new WS frame or API shape
   consumed by `app.html` gets a line in `tests/pi-web.test.ts` proving
   the producing side's contract.
