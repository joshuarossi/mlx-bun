# The mlx-bun beat matrix

Purpose: an axis-by-axis competitive requirement table for making mlx-bun's
web chat UI THE SINGLE BEST macOS local-AI chat surface — not best-in-a-niche,
best, period. Every row is a capability judged against the best current
implementation anywhere in the surveyed field (mlx-lm, mlx-optiq, Ollama, Open
WebUI, LM Studio, Odysseus, Jan, Msty, GPT4All, AnythingLLM, Enchanted,
macMLX/mlx-serve, ChatGPT, Claude.ai). Sourced from the 10-agent market-research
corpus plus a direct line-level audit of `src/web/app.html`, `src/pi-web.ts`,
`src/server.ts` and the merged plan at
`docs/design/web-chat-redesign.md`. Supplemented with a fresh read of
mlx-optiq's live Lab docs (mlx-optiq.com/docs/lab/{chat,arena,hub}) — optiq is
the closest-cousin MLX product, so its rows are held to the strictest
standard: the operating rule for this matrix is **zero "I miss how
<competitor> had X" moments**, so every capability below is MATCH, BEAT, or an
explicit SKIP with a stated engine-substrate reason.

*(Caveat: the Odysseus rows rest on the research agent's public-web
identification of "Odysseus" — Cookbook recommender / Skills /
Observer-Reflector memory / SSRF CVEs. If that's not the Odysseus meant,
those rows describe the wrong product and need a re-run; no verdict in this
matrix flips on them.)*

Verdict legend:
- **MATCH** — users expect it; parity is sufficient (e.g. code-block copy).
- **BEAT** — an axis where mlx-bun can be clearly, structurally better because
  of something we alone have (in-process server, `/fit`, whole-stack control,
  MLX-native, memory vault, adapters). The "what beating requires" column says
  *how*, not "do it better."
- **SKIP** — the engine genuinely lacks the substrate (image gen, voice). One
  line each so silence is never mistaken for an oversight.

---

## Axis 1 — Chat fundamentals

| Capability | Best today (who + what makes theirs best) | Verdict | What beating them concretely requires | Backend status |
|---|---|---|---|---|
| Streaming responses with visible Stop | Universal table stakes (ChatGPT/Claude/all local apps) — Stop is prominent, never buried in a menu | MATCH | Already shipped (`app.html` composer) | exists |
| Stop actually kills in-flight tool work | optiq Lab: the stop button SIGKILLs sandboxed tool subprocesses, not just the token stream | MATCH | Ensure our stop aborts running tool calls (bash/web_fetch) through the pi bridge, not only the generation — a half-stop that leaves a shell command running is a visible miss vs. the closest-cousin MLX product | thin addition (verify + wire abort through the pi tool layer) |
| Chat persistence to disk, no account | optiq persists to `~/.optiq/lab/chats/`; universal among local apps | MATCH | Already shipped — pi `SessionManager` disk-persisted sessions with richer lifecycle (fork) than optiq's | exists |
| Regenerate response | ChatGPT/Claude cycle response variants (1/2, 2/2…); Open WebUI same | MATCH | Add a regenerate button per assistant turn, reusing the existing send pipeline | thin addition |
| Edit-and-resend (non-destructive branch) | ChatGPT/Claude: edit a prior user message silently forks; `< 1/2 >` toggle above the edited message | MATCH | Reuse `SessionManager.forkFrom` (already exists server-side) at message granularity instead of whole-session only | thin addition (server primitive exists, needs per-message wiring) |
| Full conversation tree view | Neither ChatGPT nor Claude ships this natively — only a linear toggle; third-party extensions (BranchGPT) exist because users want it | BEAT | Build a genuine node-graph view of every edit-branch, reusing `forkFrom` — a documented gap neither cloud incumbent has closed. Phase 4 stretch, not launch-blocking. | new build (UI only; fork primitive exists) |
| Live steering (type while streaming to redirect) | mlx-bun already has this wired server-side (`queue_update`, distinct `steering`/`followUp` arrays) — no competitor in the survey does this | BEAT | Fix the existing truthy-vs-length-tested array bug (`web-ui-pass-plan.md` #2) so the feature that already exists actually renders | exists (buggy — Phase 0 fix) |
| Follow-up queue while a turn streams | Same as above — server already distinguishes queued follow-ups from live steering | BEAT | Same fix as above; this is a genuine differentiator once rendering is correct | exists (buggy) |
| Stop/regenerate reachable by keyboard | ChatGPT ships a full shortcut sheet (`Cmd+/`) | MATCH | `Cmd/Ctrl+Shift+O` new chat, `Shift+Esc` focus composer, etc. — adopt ChatGPT's vocabulary verbatim, zero cost to originality | thin addition |
| Message-level copy (full assistant text) | Universal — every competitor has full-message copy, not just code-fence copy | MATCH | Add copy button to the message action row | thin addition |
| Delete a single message | Common in Open WebUI, LM Studio | MATCH | Add to message action row | thin addition |
| Multi-turn context management / auto-compaction | mlx-lm's byte-capped LRU prompt cache is the correctness bar; pi already does session compaction | MATCH | Already exists server-side; only gap is a UI seam marking *when* compaction happened | thin addition (mark the seam) |

---

## Axis 2 — Rendering & content

| Capability | Best today | Verdict | What beating them concretely requires | Backend status |
|---|---|---|---|---|
| GFM markdown (tables, task lists, blockquotes, autolinks) | mlx-bun's own hand-rolled `mdToHtml` is already competitive with library output | MATCH | Nothing — already good, keep it | exists |
| Syntax-highlighted code blocks | Every mainstream competitor (ChatGPT, Claude, Open WebUI, LM Studio) has this; mlx-bun renders plain monochrome `<pre><code>` | MATCH | Vendor Shiki (or a lighter WASM-free alternative) self-hosted, no CDN, applied only to completed blocks | new build (thin — rendering only) |
| LaTeX/math rendering | Universal via KaTeX in modern chat UIs; mlx-bun has none | MATCH | Vendor KaTeX self-hosted, same completed-block-only pass | new build (thin) |
| Diagram rendering (Mermaid) | Present in several competitors' RAG-heavy stacks | MATCH | Optional — low priority; add if code-heavy audience demands it | new build |
| O(n²) streaming re-render fix | Streamdown/t3.chat's block-memoized architecture (split completed vs. live-tail block, skip re-parse on stable blocks) | BEAT | mlx-bun is the only local competitor whose whole pitch is serving *speed* — a frontend that stutters on a fast, spec-decode-accelerated response undercuts the product's own thesis. Port the block-memoization *idea* into the existing vanilla renderer (no framework). This unblocks every other visual change touching the render path. | new build (architecture fix, no new backend) |
| Unterminated-markdown repair mid-stream | Streamdown's context-aware auto-close of open fences/emphasis | MATCH | Port the repair-pass idea alongside the block-memoization fix | new build (thin, bundled with above) |
| Sandboxed HTML/canvas preview for fenced HTML | optiq Lab's Canvas: fenced HTML blocks render live in a sandboxed allow-scripts iframe with a view-source toggle — shipped today in the closest-cousin MLX product | MATCH | Add the same allow-scripts iframe render + view-source toggle for HTML fences, opt-in-by-heuristic like ChatGPT's Canvas walk-back (not mandatory). Explicit "no I-miss-optiq-Canvas" requirement. | new build |
| Artifacts/Canvas side-panel | Claude Artifacts / ChatGPT Canvas: persistent versioned side panel, highlight-to-scope-edit, version scrubber | MATCH (opt-in, not launch-required) | OpenAI itself partially walked Canvas back in May 2026 for the common case — ship opt-in-by-heuristic (auto-open above ~10 lines / high fence density), not a mandatory pane. Real effort; explicitly Phase 4. | new build |
| logprobs-derived confidence visualization | Nobody in the local-AI survey ships this in-chat at all | BEAT | Server already validates and returns `logprobs`/`top_logprobs` (mlx-lm-matched shape) with zero UI. An opt-in per-token confidence overlay is pure whitespace — no competitor's server even supports it as cleanly. | exists (server), new build (UI) |
| Structured-output / JSON-schema picker | optiq Lab ships JSON mode via lm-format-enforcer (schema-constrained, deliberately pure-Python at a stated ~1ms/token cost); mlx-lm has zero `response_format` support; most local UIs don't expose it even when the server supports it | BEAT | Server already supports `response_format` json_schema/json_object + `guided_grammar`/`guided_regex`/`guided_choice` via **xgrammar token bitmasks** — structurally faster than optiq's ~1ms/token pure-Python enforcer, and broader (grammar/regex/choice, not just JSON schema). Ship a schema/grammar picker with live validation; we beat the closest cousin on both overhead and surface. | exists (server), thin addition (UI) |

---

## Axis 3 — Model discovery & management

| Capability | Best today | Verdict | What beating them concretely requires | Backend status |
|---|---|---|---|---|
| Hardware-fit traffic light on model selection | LM Studio: green/yellow/red against detected RAM/VRAM before download commit | BEAT | We already have per-SKU fit prediction measured against *this specific Mac's bandwidth* (`GET /fit`, `src/fit.ts`) — not a generic heuristic like LM Studio's. Wire it into both the model list and the in-chat model switcher. | exists (server), thin addition (UI) |
| One-click model library browse + load + chat (Hub) | optiq Lab's Hub: three sources in one browser — published OptiQ quants auto-discovered from mlx-community (family/size/bit-profile/download counts), HF search of any MLX-compatible model (OptiQ-only filter), and local converted dirs (vision badge when a sidecar is present) — with one-click load-to-server AND new-chat per row | BEAT | Match the three-source browse→load→chat loop, then beat it where optiq is documented weakest: their Hub has **no hardware-fit indicator beyond raw size** — put a `/fit`-computed green/yellow/red badge (predicted decode tok/s + safe context for *this* Mac) on every row, at the exact point of download/load commitment | exists (`/fit`), new build (library UI) |
| Capability badges (vision/tool-use/reasoning) | LM Studio's `model.yaml` badges; Ollama's library tag chips | MATCH | Surface known properties (SigLIP vision, quant tier) as UI chrome — we already know these, just not rendered | thin addition |
| In-chat model switching (no restart) | optiq Lab Hub: hot-swap the serving model in place in ~5-30s without restarting the Lab; Jan's router mode (single process, on-demand load/unload) | MATCH | `#nav-model` is currently a dead `<span>` with no click handler — wire a clickable picker that triggers the same in-place hot-swap; match optiq's 5-30s bar | thin addition |
| Model swap preserves session history + re-primes cleanly | Every competitor surveyed is documented as bad at this (LM Studio has an open bug clearing the selector on swap) | BEAT | Since we control the whole stack (session + KV + adapter layer), a swap that keeps history and re-primes cleanly is a believable, demonstrable win nobody else in the survey has actually shipped correctly | thin addition (UI + verify session continuity) |
| Resident multi-model pinning / LRU pool | macMLX's per-model pin/LRU-evict pool | MATCH | Extend existing adapter-namespaced KV logic to full models for users bouncing between two models | new build |
| Running-models resource table | Ollama's `ollama ps` (PROCESSOR split, UNTIL auto-unload countdown) | BEAT | Build the equivalent Status-tab table PLUS columns no competitor can show: LoRA adapter attached, KV tier/quant, spec-decode draft pairing | new build |
| Live per-layer quantization sensitivity visualization | optiq computes this internally (KL cost per layer per bit-width) but never renders it — a documented gap even in the best-in-class quant tool | BEAT | We already compute or could compute per-layer bit allocation; a heatmap/bar-strip nobody in the entire surveyed field has shipped, turning an opaque flag into a screenshot-able trust signal | thin addition (Quantize tab exists; visualization is new) |
| One-command coding-tool integration (`ollama launch <tool>`) | Ollama: `ollama launch claude --model X` wires Claude Code/Codex/OpenCode at itself with zero config | BEAT | We already speak both OpenAI- and Anthropic-compatible protocols — `mlx-bun launch <tool>` is nearly free to build and makes us infrastructure other daily tools sit on | thin addition (CLI, not chat UI, but a real distribution wedge) |

---

## Axis 4 — Customization: prompts / presets / sampling

| Capability | Best today | Verdict | What beating them concretely requires | Backend status |
|---|---|---|---|---|
| Full sampler parameter set (min_p, XTC, penalty families + windows, logit_bias) | mlx-lm's own `/v1/chat/completions` (the oracle) accepts all of these; mlx-bun's composer only exposes 3 of ~11 | MATCH | Server already implements the full set (`src/server.ts`) — wire `min_p`/XTC/penalties/logit_bias/seed into the sampling popover behind an Advanced disclosure. Table-stakes gap against our own drop-in-replacement claim. | exists (server), thin addition (UI, WS `set_sampling` currently hardcodes 3 fields) |
| Per-model correct sampling defaults | LM Studio auto-binds presets per model | MATCH | Fix the hardcoded MiniCPM5-shaped `SAMP_REC` — resolve defaults from `generation_config.json` per served model, which the server already supports | exists (server), thin addition (UI) |
| Per-MESSAGE sampling granularity (temp / max_tokens / thinking per turn, in the composer) | optiq Lab: temperature, max tokens, and enable_thinking overridable per message directly in the chat composer — per-turn granularity, not a per-session settings modal | MATCH | Our per-turn plumbing already exists (`injectSampling` per-turn overrides via `set_sampling`, per-model thinking toggle) — the gap is presentation: keep the popover per-turn-scoped and visible at the composer, not buried, so optiq's per-message granularity has a direct equal | exists (per-turn `injectSampling` + thinking toggle), thin addition (composer placement) |
| Saved/shareable prompt presets (system prompt + params bundle) | LM Studio Presets: exportable, importable, auto-bound per model | MATCH | Build a preset save/load layer over the existing sampling+system-prompt state | new build |
| Slash-command prompt library with variable-filled forms | Open WebUI's `/name` + `{{var}}` popup | MATCH | Well-tested pattern, no meaningful downside; build as a Phase-2/3 item | new build |
| Model-string variant shorthand (`:precise`/`:no-think`) | optiq's `:no-think`/`:precise`/`:creative` suffixes for rigid clients | MATCH | Cheap compatibility hack for agent clients that only set `model` — trivial to add given presets already exist conceptually | new build (thin) |
| Persona/bundle system (prompt + adapter + tools + memory scope, named, switchable) | Msty's Persona Studio + Crew Conversations; AnythingLLM workspace pinning | BEAT | We're the only one who can bind a *named* bundle to an actual LoRA weight swap (not just a system-prompt swap) — Msty/AnythingLLM personas are prompt bundles only. Phase 4 item; data model should be shaped now so it's a thin layer later. | new build |
| Warm/preload a context explicitly | mlx-lm's `cache_prompt` as a first-class CLI verb | MATCH | Expose an explicit "warm this session" action turning a backend perf trick into a felt speed win | new build |

---

## Axis 5 — Knowledge: documents & RAG

| Capability | Best today | Verdict | What beating them concretely requires | Backend status |
|---|---|---|---|---|
| Zero-config document attach (point-and-chat) | GPT4All's LocalDocs: point at a folder, fully offline, no pipeline setup | MATCH | Table-stakes risk: our Chat tab currently has no document/RAG story at all. Ship the simplest possible attach-and-answer path first. | new build |
| Transparent inline-vs-RAG mode selection | LM Studio: auto-decide inline (fits context) vs. chunk+embed (doesn't), zero user configuration | MATCH | Copy the zero-config decision engine; then extend the *same* engine to also route into the memory vault (see Axis 6) so "attach a file" and "recall memory" feel like one retrieval system | new build |
| Chat-with-files RAG + citation badges + Sources panel | optiq Lab ships this today in the closest-cousin MLX product: attached non-image files are indexed with a **dependency-free BM25 retriever**, chunks retrieved with inline `[n]` citation markers plus a Sources panel; Open WebUI's SourcePanel adds page-level PDF deep links | MATCH (v1 = optiq's bar) | Match optiq's exact v1 shape — BM25 index over attachments, `[n]` markers, Sources panel (filename+snippet, not full PDF-page rendering) — then extend the same retrieval component to vault articles (Axis 6), which optiq has no concept of | new build (optiq's dependency-free BM25 proves the v1 needs no vector infra) |
| Unified `#`/`@` retrieval mention (files + docs) | Open WebUI's `#` command pulls a KB doc or raw URL as one interaction | MATCH | Extend to both attached files and vault articles as *one* retrieval gesture — this is where the RAG axis and the memory axis (Axis 6) genuinely merge for us | new build |
| Retrieval-mode toggle (chunked search vs. full-context) | Open WebUI's Focused/Full-Context switch | MATCH | Cheap, well-proven; add per-document toggle | new build |
| Hybrid RAG (BM25 + vector + reranking) | Open WebUI's serious RAG maturity (configurable hybrid retrieval, reranking, full-context bypass) | SKIP (full hybrid, for now) | The *hybrid/reranking* tier is what's skipped, not RAG itself — the BM25 v1 above is required (optiq proves it's cheap), and embeddings exist (`src/embed.ts`) for a later vector upgrade; full Open WebUI-grade reranking infrastructure is not warranted at launch | new build (large, deferred tier) |
| Local semantic search over the user's OWN chat history | Nobody in the survey does this — competitors' RAG is document-centric, not "my own past conversations" | BEAT | The memory vault + session history IS a corpus no competitor's RAG concept reaches; making "search my own past" a first-class retrieval target ties directly into the local-to-you thesis | new build |

---

## Axis 6 — Memory & personalization

| Capability | Best today | Verdict | What beating them concretely requires | Backend status |
|---|---|---|---|---|
| Auto-extracted, editable memory list (facts/preferences) | AnythingLLM's Observer/Reflector; ChatGPT's Manage Memories (dated rows, per-item delete, search/sort) | BEAT | mlx-bun's memory is architecturally deeper: a git-tracked Markdown vault, read-only at chat time, written only by nightly synthesis — not a flat fact list. The UI's job is making that *visible*: a real Memory panel (vault browser + search), not inventing a new prompt-stuffing mechanism. | exists (`src/memory/tools.ts`, `vaultStatus()`), thin server addition (REST wrappers) + new UI |
| Per-turn provenance ("the assistant looked this up") | ChatGPT/Claude show *what* is remembered but never *how*; nobody shows live per-turn citations for memory reads | BEAT | Memory tool calls already fire silently in web chat with zero distinct rendering. Give them a citation-chip card style (not the generic wrench icon) — the single highest-leverage rendering change in the whole plan. | exists (tools fire), thin addition (card styling) |
| Git-diff / history view of what memory synthesis changed | No competitor's architecture can do this — ChatGPT/Claude synthesis runs on someone else's infrastructure, unauditable even in principle | BEAT | Our synthesis runs locally and is git-tracked. A per-article git-log/diff toggle lets a user *watch* an article evolve after a correction — the sharpest wedge against both cloud incumbents' otherwise-superior memory UX, because ours is mechanistically inspectable and theirs structurally cannot be. | exists (git history is real), thin server addition (log/diff read route) + new UI |
| Wikilink knowledge-graph view | Nobody in the survey has a git-tracked personal wiki at all, so nobody has this | BEAT | `memory_links` already resolves inbound/outbound wikilinks per article — cheap to expose as a graph view; a "knowledge graph of what the model knows about you" nobody else's architecture supports | exists (`memory_links` tool), new build (graph UI) |
| Scope control (this-session / this-surface / global) | AnythingLLM's workspace-vs-global memory scoping | MATCH | Vault is currently single-scope; scope selection is a reasonable v2 addition once the panel exists | new build |
| Pause vs. reset as distinct actions | ChatGPT/Claude: pause (stop reading/writing, keep data) vs. reset (irreversible wipe) as two different stakes levels | MATCH | Cheap UX pattern to copy once settings/memory panel exists | thin addition |
| Memory that graduates into trained weights (not just context) | Nobody — not AnythingLLM, not ChatGPT, not Claude — synthesizes memory into actual model weights; all of them are context-window-bounded fact lists | BEAT | This is mlx-bun's single deepest structural moat: the nightly "dreaming" pipeline can eventually bake a fact into a memory LoRA, not just a growing prompt. A visible marker distinguishing "raw context" vs. "baked into your memory LoRA" is a distinction no competitor's architecture can even express. | partial (synthesis-to-context exists; synthesis-to-LoRA is a further phase per project memory) |
| First-run memory consent flow | AnythingLLM/Odysseus bury consent in settings; nobody makes it a first-60-seconds moment | BEAT | `mlx-bun memory init` today is CLI-only, invisible to anyone who never opens a terminal. A one-line skippable consent card in the hero screen puts personalization consent in the same 60 seconds as "install to chat under a minute" — no competitor frames it this tightly. | exists (CLI), thin addition (hero-screen card) |
| Nightly synthesis schedule status visible | Odysseus runs nightly audits but doesn't surface schedule state in mainstream UI docs | MATCH | `vaultStatus()` already returns schedule state, last-run time — just render it | exists, thin addition |
| Self-evolving procedural memory ("Skills") | Odysseus: auto-distills reusable markdown playbooks from multi-tool-call sessions, teacher-escalation on failure | SKIP (v1) | Genuinely novel mechanic but a large, separate system (distillation trigger, confidence scoring, LLM-as-judge harness) — not core to the memory-vault thesis; defer as a later differentiator, not a launch requirement | new build (large, deferred) |

---

## Axis 7 — Tools & agents

| Capability | Best today | Verdict | What beating them concretely requires | Backend status |
|---|---|---|---|---|
| Tool-call visibility as a distinct card (not silent) | Universal table stakes now (Open WebUI, LM Studio, Jan, AnythingLLM all show tool cards) | MATCH | Already shipped (`app.html` running/ok/fail cards) | exists |
| Inline, non-blocking approval cards | Jan v0.8.0: moved away from blocking modal to inline cards embedded in the tool-call bubble, plus global "Allow All" | MATCH | We already have the approval round-trip (`installApprovalGate`) — the presentation layer needs to match Jan's proven inline pattern | exists (backend), thin addition (styling matches Jan's pattern already) |
| Editable arguments before approval | LM Studio: edit the proposed call's arguments, not just accept/deny | MATCH | Extend the existing approval card to allow inline argument editing before execute | thin addition |
| Durable, tool-identity-keyed "always allow" | Universally fragile across the field — Claude Desktop's persistence resets on app update; Cowork doesn't persist across sessions at all | BEAT | This is an easy, concrete bar: store approvals in a real versioned config file keyed by stable tool identity, with a migration test across simulated version bumps — fixing a failure mode every competitor visibly has | new build (small — config file + test) |
| Gated tools (bash/edit/write) actually reachable in web chat | optiq Lab ships a terminal tool (bash one-liners with dangerous-command filtering) live in chat today; mlx-bun's own approval-card UI is fully built but currently dead code — the browser allowlist excludes every `GATED_TOOL` | MATCH (fix our own regression) | Wire `codingTools: true` behind an explicit off-by-default "let it touch files" toggle so the already-shipped UI stops being inert; our per-call approval gate is a *stronger* trust model than optiq's static dangerous-command filter once it's actually reachable | exists (backend + UI both exist, just disconnected) |
| Sandboxed Python execution tool | optiq Lab: built-in Python tool running in a sandbox with AST-level security checks, killed cleanly on Stop | MATCH | Add a Python-interpreter tool to the pi tool surface (or route through the existing gated bash path with an interpreter preset); single-user local means "runs on your machine" is the honest framing, with the approval gate as the control — full AST-sandbox parity is optional, the *capability* is the requirement | new build (moderate; approval plumbing exists) |
| Self-healing tool calls (auto-correct malformed formats) | optiq Lab: auto-corrects six distinct malformed tool-call formats instead of failing the turn — directly addresses the reliability gap mlx-lm's own server logs warn about (truncated/failed parses, no recovery) | MATCH | Add a repair layer in the tool-call parse path (`src/tool-call.ts`) covering the common malformation classes; small local models flub tool-call syntax constantly, so without this every optiq user switching over feels a reliability regression | new build (parser hardening; tool-call parsing exists) |
| Tool-loop hygiene (dedup, retry budget, turn cap, force-finish) | optiq Lab: skips identical consecutive successful calls (dedup), gives 3 failed attempts then forces course-correction (retry budget), caps the loop at 25 turns, and force-generates a text answer if the cap is hit (never ends a turn tool-looping with no answer) | MATCH | Implement the same four guards in the pi agent-loop bridge; the force-finish guarantee ("you always get an answer, never a stuck loop") is the piece users notice most | new build (loop-policy layer over existing agent loop) |
| Argument/diff preview before approval | Neither ChatGPT nor Claude previews the concrete blast radius (file diff, shell command, bytes written) before approval — both show name + yes/no only | BEAT | mlx-bun's approval hook already has the data; showing an actual diff/args preview clears a bar neither cloud incumbent has cleared | thin addition |
| Per-session disk-touch tally (trust log) | Nobody in the survey ships a running "what did the agent touch on disk this session" ledger distinct from tool-call cards | BEAT | Single-user local execution means this is honest, cheap, and uniquely credible — "runs on your machine, with your files" instead of Open WebUI/Odysseus's sandbox theater for multi-tenant deployments we don't need | new build |
| Curated pre-wired tool pack on first run | Cherry Studio: filesystem, web search, GitHub, fetch, memory pre-registered, zero JSON config | MATCH | Ship a default pack including our own wiki-read/vault tool — turns first-run into a memory-flywheel demo instead of a config chore | new build (small) |
| MCP server support | Open WebUI native MCP + mcpo proxy; LM Studio Cursor-compatible `mcp.json`; Jan MCP marketplace | MATCH | Add MCP client support behind the existing tool-call plumbing — real engineering, but table stakes for 2026 agentic chat | new build (moderate-large) |
| Web search + URL fetch, no API key | optiq Lab: built-in DuckDuckGo search + URL fetch requiring zero API keys, on by default in chat; Odysseus/Open WebUI need SearXNG/config | MATCH | `web_search`/`web_fetch` tools already exist, keyless and read-only-safe — but `web_fetch` is currently excluded from the hardcoded `WELCOME_TOOLS` allowlist; widen the toolset per served model and expose an explicit per-turn toggle | exists (tools), thin addition (allowlist + UI toggle) |
| Approval-fatigue-aware defaults | Field-wide complaint (Jan, LM Studio, Claude Desktop users all report fatigue) | MATCH | Ship read-only/local tools (file read, our wiki-read) as always-allow-by-default, reserve prompts for write/network/execute-class tools | thin addition |
| tool_choice forcing a specific function | API-only today (`src/server.ts`); no chat-UI concept | SKIP (chat UI) | Real capability but a power-user/API concern, not a chat-composer affordance — low priority for the redesign | exists (API), not a UI priority |
| No-code visual agent-flow builder | AnythingLLM's Agent Flows canvas; Odysseus admin-gated automation | SKIP | Building a general visual flow builder from scratch is a multi-quarter distraction with no differentiator payoff; if we need automation, scope it narrowly (a "schedule a synthesis-style job" UI) rather than a general canvas | not planned |
| Deep-research-style multi-step trace panel | Odysseus's Deep Research; Open WebUI's Interleaved Thinking | MATCH | Table stakes for agentic 2026 chat UIs; wrap a visible plan/trace UI around existing tool-call infra as a research-flavored preset | new build |

---

## Axis 8 — Multimodal

| Capability | Best today | Verdict | What beating them concretely requires | Backend status |
|---|---|---|---|---|
| Vision input (image attach + inference) | Universal now (Ollama desktop, LM Studio, optiq's bf16 sidecar) | MATCH | Already wired end-to-end correctly (capability negotiation via `ready` frame's `vision` flag); only fix needed is stale "switch to 12B" copy now that e2b/e4b/26B/31B are all vision-capable | exists |
| Vision + prompt-cache unification (no perf tax when text-only) | LM Studio's Unified MLX Engine: single code path conditionally attaches a VisionAddOn, ~25x faster follow-up TTFT via shared caching | MATCH | Verify our own vision path already avoids a text-only tax (SigLIP sidecar pattern is architecturally similar); if not already true, this is a real perf investment worth matching | exists (verify) |
| Image generation | Not in scope for any MLX-native serving engine surveyed except bolted-on extras (mlx-serve) | SKIP | No image-generation model/pipeline exists in the engine at all — genuine substrate gap, not a UI decision | not built |
| Speech-to-speech voice mode | ChatGPT Advanced Voice Mode: single model hears tone/emotion, replies in 2-3s | SKIP | No speech/TTS/STT engine exists. This is a hard, expensive model-latency problem, not a UI problem — a naive STT→LLM→TTS bolt-on would read as a visible regression against user expectations set by the cloud bar. Correctly scoped as out of v1. | not built |
| Native OS voice I/O (dictation, TTS readback) | Enchanted's native SwiftUI voice I/O across Apple devices | SKIP | Same substrate gap as above — no TTS/STT pipeline; Enchanted rides macOS system APIs we haven't wired at all | not built |
| Document (PDF/DOCX) attach with inline-vs-RAG | LM Studio's transparent dual mode | MATCH | Covered under Axis 5 (Knowledge) — same capability, cross-referenced here for multimodal completeness | new build |
| Screenshot capture in a floating companion window | ChatGPT macOS's Option+Space + instant screenshot; mlx-serve's Ctrl-Space quick launcher | BEAT | The Tauri shell already wraps the same web UI with zero bespoke chrome; adding a global hotkey + floating window wired to the existing vision pipeline is a concrete way to earn native-app status a browser SPA structurally can't claim | exists (vision pipeline), new build (Tauri-specific, Phase 4) |

---

## Axis 9 — Performance & transparency

| Capability | Best today | Verdict | What beating them concretely requires | Backend status |
|---|---|---|---|---|
| Live tok/s + TTFT readout | LM Studio 0.4's ambient context-fullness/tok-s chrome; macMLX's Benchmark tab | MATCH | Already computed (`app.html` post-turn readout) — just under-designed as small dim text | exists |
| Context-window meter | LM Studio's persistent fullness indicator | MATCH | Already exists (`app.html:1696-1703`) | exists |
| Serving-lane badge (serial / spec-decode / batched) | Nobody in the entire surveyed field integrates lane-awareness into the *live chat surface* — macMLX/mlx-serve have a separate Benchmark tab, not live-turn lane visibility | BEAT | This is the one thing no competitor's architecture allows, because none of them control both spec-decode and batching as internally routed lanes AND expose that routing per-turn in the chat itself. Needs a small per-turn `lane` field added server-side (usage payload + pi-web frame) — the single highest-differentiation, lowest-backend-cost item in the whole matrix. | thin server addition (field doesn't exist yet) + UI |
| Prompt-cache-hit telemetry per turn | mlx-lm's LRUPromptCache tracks reuse internally but never surfaces it to a user; nobody in the survey shows "served from cache" per turn | BEAT | We already compute cache-hit counts server-side; surfacing "this turn reused N cached tokens, saved Xms" turns an invisible backend optimization into a felt trust/speed signal | exists (server), thin addition (UI) |
| Built-in Benchmark tab (prefill/decode tok/s, TTFT, peak RSS) | macMLX's Benchmark tab; mlx-serve's "+39% geomean" claim | MATCH | We already discipline every perf claim with `benchmark.sh` (per CLAUDE.md ground rules) — exposing a lightweight in-app version turns internal QA into user-facing proof | exists (harness), new build (in-app UI) |
| Compare/split view of two configs on one prompt | optiq's Model Arena is the closest-cousin implementation: side-by-side 2-model comparison on identical prompts, model B spun up in a second server on port+1 on demand, both panes streaming live with tok/s + token counts, both models staying loaded while Arena is open, thinking force-disabled for reasoning models so comparisons show real answers; Msty's Split Chat adds synced typing across N panes | BEAT | Match the Arena mechanics (two live-streaming panes, tok/s per pane, thinking force-disabled — copy that design decision verbatim), then beat it on two documented Arena gaps: (1) compare things optiq *can't* — base vs. LoRA-adapted variant, bit-exact parity mode vs. L3 fast path — since Arena only compares whole models; (2) add a quality signal (Arena shows only speed + token counts, no voting/ranking — its own docs' weakness), e.g. a memory-grounded check or preference capture wired into the ORPO data pipeline | new build |
| Concurrency / batch-slot visibility | optiq's documented `--max-concurrent-equivalent` guidance | MATCH | Document + add a live concurrency/slot indicator tied to our shipped `--batch N` concurrent serving | thin addition |
| Hardware-fit prediction (`/fit`) surfaced in chat | LM Studio's traffic light is generic-heuristic; we measure actual bandwidth per SKU | BEAT | `GET /fit` already predicts decode tok/s and safe context for *this specific Mac* — surface it in the model switcher and adapter picker, not buried in the Status tab only | exists (server), thin addition (surface beyond Status tab) |
| Auto-sized context window to available memory | Ollama has open feature requests for exactly this (currently a conservative fixed default) | BEAT | Our M4-Pro-tuned memory-headroom knowledge (Metal/unified memory) lets us size this more precisely than Ollama's generic GPU detection; the context-window meter already exists as the display surface | thin addition (logic; UI meter exists) |
| Provable "zero cloud calls" per session | No cloud competitor can make this claim structurally; local competitors don't bother proving it | BEAT | A per-session network-activity indicator (there were zero egress calls) is trivially true for us and impossible for ChatGPT/Claude's "temporary chat" (still retained 30 days per OpenAI's own disclosure) | new build (small) |

---

## Axis 10 — Polish: onboarding / theming / keyboard / a11y / mobile

| Capability | Best today | Verdict | What beating them concretely requires | Backend status |
|---|---|---|---|---|
| Dark + light theme, `prefers-color-scheme` | Universal table stakes; mlx-bun is dark-only today (`--bg:#000` hardcoded) | MATCH | Add `prefers-color-scheme` handling + a light theme; audit design tokens | thin addition |
| `prefers-reduced-motion` respect | WCAG baseline; ambient blooms currently unconditional | MATCH | Guard shimmer/bloom animations behind the media query | thin addition |
| Full keyboard shortcut sheet (`Cmd/Ctrl+/`) | ChatGPT's documented vocabulary is the de facto standard | MATCH | Adopt ChatGPT's exact bindings where sensible — zero cost to originality, reuses existing copy-button code for "copy last response" | thin addition |
| Command palette (`Cmd/Ctrl+K`) | ChatGPT/Claude: universal "do anything" entry point | MATCH | Build a palette covering new chat/session search/model-adapter switch/thinking toggle | new build |
| Mobile responsive layout down to 375px | Universal table stakes; mlx-bun's sidebar vanishes at 760px with zero replacement | MATCH | Replace the vanishing sidebar with a slide-over drawer + hamburger — table stakes, not differentiation | new build (small) |
| PWA installability (manifest + service worker) | Open WebUI ships "Install app" as a first-class menu item | MATCH | Add a manifest + minimal cache-first shell service worker; scope explicitly as shell-instant-load + installability, not offline chat (app is useless without the local server running) | new build (small) |
| A11y: `role="log" aria-live="polite"` on the thread | WCAG ARIA23 documented technique; mlx-bun has 11 total `aria-*` attributes across 2737 lines | MATCH | Throttle to paragraph/sentence boundaries, never per-token; verify against actual VoiceOver testing, not just docs | new build (small) |
| Full keyboard tab order + focus rings + Escape-to-close | Baseline a11y expectation; currently no documented strategy | MATCH | Trap focus in popovers, Escape returns focus to trigger | thin addition |
| Progressive disclosure (Simple / Developer mode) | LM Studio's User/Power-User/Developer toggle — one codebase, one switch, not a fork | MATCH | Collapse Quantize/Fine-tune/Build-Dataset/Status/Curves/Routes behind one Developer toggle so Chat is the whole app for a first-time user — directly serves "install to chat under a minute" | new build (IA move, no new backend) |
| Personalized, server-driven onboarding chips | Nobody ties onboarding chips to actual server state — LM Studio/Ollama's onboarding is generic | BEAT | Replace 4 static marketing chips with server-driven ones: one drawn from real vault content, one offering to try an adapter, a first-run memory-consent card — because our onboarding can reflect real personalization state nobody else's architecture has to reflect | thin addition (`vaultStatus()`, `/v1/adapters/available` already exist) |
| Chat export (Markdown/PDF/plain text) | LM Studio exports to PDF/MD/plain text; Open WebUI exports JSON | MATCH | Add export action to session actions; local-only, no server cost concern | new build (small) |
| Chat sharing (shareable link) | Open WebUI: shareable chat links | SKIP | Requires a hosting/sharing surface that conflicts with the single-user, local-only, no-contributors identity — a shareable *link* implies a server reachable by someone else, which is out of scope by design, not a capability gap | not planned (scope decision) |
| Full-text search across message bodies | Claude's own search is title-only — a widely-cited annoyance; local storage removes any indexing-cost excuse | BEAT | No server-cost constraint exists locally the way it does for Claude/ChatGPT's cloud indexing — ship real full-text body search, not just title search, and be visibly better than the cloud incumbents on this specific point | new build (small) |
| Session/conversation folders and pins | Open WebUI folders/tags; ChatGPT pin/star | MATCH | Add pin + lightweight tag/folder grouping to the sidebar | new build |
| Native menu-bar/tray behavior (clean quit, no zombie process) | Ollama gets public complaints for exactly the failure mode to avoid (can't hide dock icon, can't fully quit) | MATCH | Cheap insurance in the Tauri shell — verify clean quit/hide-dock-icon before shipping, avoid inheriting a known competitor failure mode | thin addition (Tauri config) |

---

## Axis 11 — Sessions & organization

| Capability | Best today | Verdict | What beating them concretely requires | Backend status |
|---|---|---|---|---|
| New / list / open / fork / delete sessions | mlx-bun already round-trips all of this through pi's `SessionManager` | MATCH | Already shipped, real depth | exists |
| Session search box | Table stakes; mlx-bun's sidebar has none today | MATCH | Add a filter/search input above the session list | thin addition (small) |
| Per-message branch-from-here (not just whole-session fork) | ChatGPT/Claude's edit-creates-branch convention | MATCH | `SessionManager.forkFrom` already exists server-side — expose at message granularity, not just the sidebar | thin addition |
| Projects (scoped knowledge + memory per workspace) | Claude Projects: persistent system instructions + files + isolated memory summary per project | BEAT | A Project is effectively "routed context + adapter scope" in UX terms even though Anthropic implements it as RAG-over-files; we can implement the same UX shape with an actual weight-level adapter swap underneath, something Claude's Projects structurally cannot do since they don't ship adapter weights per customer | new build (persona/bundle concept, Phase 4) |
| Temporary/incognito chat | ChatGPT/Claude: one-click pill in composer header, per-conversation scope | BEAT | Cloud "temporary chat" is still retained 30 days per OpenAI's own disclosure "for safety" — ours can be **provably** never written to disk at all, because we control the whole stack. Pair with a per-session "zero cloud calls" indicator. | new build (small) |
| Multi-model / multi-adapter compare | Msty's Split Chat; optiq's Model Arena; LM Studio's Split View | BEAT | Covered in Axis 9 — cross-referenced here as an organizational pattern (parallel panes as a session-management primitive, not just a perf demo) | new build |
| Conversation export/import (portable JSON) | Open WebUI: JSON export/import | MATCH | Local JSON already backs every session on disk — expose an explicit export/import action | thin addition |

---

## The 10 beats

Ranked by (visible wow) × (structural defensibility) — the ten rows where
mlx-bun can be clearly, demonstrably better than the current best, not just
equal.

1. **Serving-lane badge in live chat (Axis 9).** No competitor surveyed —
   not macMLX, not mlx-serve, not optiq — integrates spec-decode/batch/serial
   lane-awareness into the actual chat surface; they all bury it in a separate
   Benchmark tab. Demo: watch the badge flip from "serial" to "spec-decode
   active" mid-conversation on the `dspark` branch and see tok/s visibly jump
   in the same breath.
2. **Memory git-diff / self-healing view (Axis 6).** ChatGPT and Claude show
   *what* is remembered but never *how* — their synthesis is a black box on
   someone else's infrastructure. Demo: correct a fact mid-chat, run nightly
   synthesis, then open the article's git diff and watch the exact line
   change.
3. **Per-turn memory provenance chip (Axis 6).** Memory tools already fire
   silently today with zero UI trace — this is a near-free wiring fix with
   outsized visible payoff. Demo: ask a personal question, see a small
   "read: Photography" citation chip appear and expand to the source
   article.
4. **LoRA adapter routing made legible + stackable (Axis 4/6).** LM Studio's
   own bug tracker confirms adapter hot-swap is unsupported industry-wide;
   optiq proved the mechanism but shipped it Python-API-only. Demo: swap from
   "general-purpose" to a named adapter mid-session with a visible RAM-cost
   note, then stack a second adapter (`"a+b"`) live.
5. **Adapter/parity compare view (Axis 9/11).** optiq's Arena (the
   closest-cousin implementation: two live panes, port+1 second server,
   tok/s per pane, thinking force-disabled) can only compare whole *models*
   and shows no quality signal at all — its own documented gap. Nobody
   compares a base model against its own LoRA-adapted variant, or bit-exact
   parity mode against the fast path, on the identical prompt. Demo: fire
   one prompt at base vs. adapted, side by side, and see the adapter
   visibly change the answer's grounding — a comparison Arena literally
   cannot express.
6. **Model swap that actually preserves the session (Axis 3).** Every
   competitor surveyed is documented as bad at this (LM Studio's own open
   bug). Demo: swap the served model mid-thread and keep scrolling the same
   conversation with no reset, no lost history.
7. **Prompt-cache-hit telemetry per turn (Axis 9).** mlx-lm's LRUPromptCache
   tracks this internally and never shows it; nobody in the field surfaces
   "served from cache" as a felt signal. Demo: a repeated near-identical
   prompt visibly shows "reused 1,400 cached tokens" and a corresponding
   TTFT drop.
8. **Provably-local temporary chat + zero-cloud-calls indicator (Axis 11).**
   Cloud "temporary chat" is retained 30 days per OpenAI's own disclosure —
   ours is structurally different because we control the whole stack. Demo:
   toggle temporary chat, chat normally, then show a network-activity panel
   proving zero egress the whole time.
9. **Tool-call diff/argument preview before approval (Axis 7).** Neither
   ChatGPT nor Claude previews the actual blast radius (file diff, shell
   command) before approval — both show name + yes/no. Demo: approve a
   `write` call and see the literal diff that will land on disk before
   clicking allow.
10. **Full-text search across message bodies (Axis 10/11).** Claude's own
    search is title-only, a widely-cited annoyance, purely because
    server-side indexing has a cost model we don't have locally. Demo:
    search a phrase buried in the middle of a months-old conversation and
    jump straight to it.
