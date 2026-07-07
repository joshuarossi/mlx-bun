# Chat UI Vision: The Model That Knows You

**Stance: memory/personalization-first.** Every other axis in this
doc — speed, tools, LoRA routing, privacy — is real, but it is in
service of one idea: mlx-bun is the only local chat surface where the
model visibly, auditably gets better at being *yours* over time. If we
build a fast, private, tool-capable chat app that doesn't make that
tangible on screen, we've built LM Studio with worse artifacts. That is
not the plan.

## The feeling

Open the app. It's not a hero screen with generic suggestion chips —
it's a hero screen that already knows something. Not in a creepy way:
in the way a good assistant who's worked with you for months starts a
Monday with "want me to pick up the Lisbon itinerary thing from
Thursday?" instead of "How can I help you today?" It should feel like
walking into a room where someone has been quietly paying attention,
not opening a fresh terminal.

The tell, mechanically: a chat with mlx-bun after a month of use is a
*different product* from day one — not because we shipped a new model,
but because the sidebar, the hero, and the answers themselves carry
accumulated context the user can see, correct, and trust. Cloud
chatbots fake a version of this behind a black box on someone else's
server. Local competitors (LM Studio, Ollama, macMLX) don't attempt
it — stateless between chats by design. Open WebUI and AnythingLLM
attempt it as prompt-stuffing into a flat fact list. Odysseus gets
closest (memory + skills) but on vLLM/llama.cpp infra with no adapter
concept at all. **Nobody combines memory-as-training-artifact with
weight-level LoRA routing and native MLX speed. That combination is the
whole pitch, and today it's invisible in our own UI** — the vault, the
memory tools, and the adapter runtime already exist server-side; none
of it shows on screen.

## The five things that make this unmistakable

**1. Memory is a visible citizen of the chat, not a silent tool call.**
Today `memory_search`/`memory_read` fire invisibly inside a generic
tool-call card indistinguishable from a bash command. The redesign
gives memory its own visual language: when the model consults the
vault mid-answer, a small soft-colored chip appears inline — not a
context dump, not an approval gate (it's read-only, never needs
permission), just a quiet citation: **"grounded in: Photography,
Lisbon-2026"**. Click it, it expands to the exact section read. This
is the single highest-leverage UI change in the whole plan: it turns
an architectural property ("the model is grounded in your vault") into
a *felt* one, every single turn, for free, using tool-call
infrastructure that already exists.

**2. A real Memory surface — not a settings toggle, a workspace.** New
8th tab (or better: reachable via one click from the sidebar, since
memory is chat-adjacent, not admin-adjacent): a vault browser. Articles
+ categories on the left, a reading pane on the right, a wikilink graph
view (the backend already resolves `memory_links` — nobody has drawn
it). Critically: a **git-history scrubber** on every article, because
self-healing-through-correction (the wiki updates itself when you
contradict a prior claim) is our best differentiator-in-the-flesh and
today it happens with zero visible seam. Correct the model about your
camera body in a chat on Tuesday; open the Photography article on
Wednesday and see the diff, dated, with the source conversation linked.
This is the "watch it happen" answer to ChatGPT/Claude's opaque
"Manage Memories" list — we don't just show *what* is remembered, we
show *how it changed and why*, because the whole pipeline runs on the
user's own disk.

**3. LoRA adapters are a routing story, not a filename dropdown.** The
current `<select>` lists raw ids (`minicpm5-chunk-final · r16`). The
redesign gives every adapter a name, a one-line specialty, and a
*kind*: **memory adapters** (trained nightly from the vault — these are
the "gets to know you" adapters) versus **task adapters** (coding,
writing-voice, whatever a user trains deliberately). The composer shows
a small persistent chip: **"grounded in your Writing adapter"** with a
one-click swap, and — since the backend already supports it — a
**stacking** affordance (memory adapter + task adapter together,
visibly, not just via a hidden `a+b` string). This is where LoRA
routing and memory literally become the same feature in the UI: a
memory-LoRA *is* accumulated personalization made concrete in weights,
and that's a claim no competitor's "persona" or "preset" system
(LM Studio Presets, Msty Personas, Ollama Modelfiles) can make, because
none of them adapt weights per user.

**4. Speed is shown, not hidden, because it's the substrate memory runs
on.** A live perf strip near the composer — tok/s, TTFT, prompt-cache
hit (already computed server-side, never surfaced), a plain-English
serving-lane badge ("batched ×3" / "spec-decode active"). This isn't a
generic benchmarking flex: it's what makes "the model reads your whole
vault before answering, every time, and it's still instant" credible
instead of hopeful. Fast local retrieval is worthless if it feels slow.

**5. Tool-call and approval UI as a trust surface for an agent with
real disk access.** The approval gate is fully built (per-call
allow/deny, diff preview) but dead in web chat today — the browser
tool allowlist excludes bash/edit/write entirely. Ship a "Power" mode
that widens the toolset with the approval cards already built, styled
as inline code-review hunks (LM Studio's argument-editable pattern,
Jan's non-blocking inline cards). This matters to the memory thesis
specifically: a vault the model can *write* to, not just read, is the
next step after this redesign, and users need to already trust
approval before we get there.

## Making it tangible in the surface

**Layout.** Keep the two-pane shape (sidebar + thread) — it's not
broken, and Msty/Claude/ChatGPT converge on it. Change what the sidebar
*contains*: above the flat session list, a compact **Memory status
strip** — vault article count, "last synthesis: 6h ago, 3 articles
updated," a dot that goes amber if synthesis is overdue. This is
`vaultStatus()` (already returns exactly this data) surfaced for the
first time. One click opens the Memory workspace as a slide-over, not a
full tab switch — memory should feel adjacent to chat, not a separate
destination.

**Composer.** Left of Send: the adapter chip (kind-colored — memory
adapters warm, task adapters cool), click to open a compact router
panel (available/loaded/selected, RAM cost per loaded adapter, stack
toggle). Right of the textarea: the perf strip. Above the composer:
typing `#` surfaces both attached-file context AND vault articles in
one unified picker, because "attach a file" and "recall something I
told you" are the same retrieval gesture from the user's point of view.
Don't teach two mental models for "give the model context."

**Messages.** Each assistant bubble gets, for the first time, a real
action row (copy — currently missing outside code blocks, regenerate,
edit-and-branch with the ChatGPT/Claude convention of a lightweight
`< 1/2 >` sibling toggle rather than a full tree). The memory-citation
chip attaches only when memory tools actually fired that turn — never
fabricated, because false positives here destroy the trust the feature
depends on.

**Model & adapter switching.** The nav model label goes from a static
span to a real switcher (currently zero affordance, a stark gap for a
product built on per-model specialization). The adapter panel sits next
to it, not buried in a settings modal.

**Tool-call display.** Three visual tiers, not one generic card: (a)
read-only tools (file read, web fetch) render minimally, collapsed,
auto-allowed; (b) memory tools render as the soft citation chip from
differentiator #1 — deliberately *not* styled like a tool call; (c)
mutating tools (bash/edit/write, once Power mode exists) render as the
inline approve/deny code-review-hunk card with visible diff. Same
underlying `tool_call` event stream, three renderers — conflating "read
your camera preferences" with "wants to delete a file" in one visual
language is exactly what makes today's UI feel generic.

**Onboarding.** The <1-minute install-to-chat promise gets a second
clause: install-to-chat-*that-remembers*-under-two-minutes. First-run
hero adds one honest, skippable memory-consent step ("Let mlx-bun keep
a personal notes vault on your Mac? Read, edit, or delete it anytime —
it's just Markdown files") in the same breath as the first message, not
buried in a CLI-only `mlx-bun memory init`. Consent has to happen
*before* the flywheel can start proving itself.

## What we deliberately don't build

- **No enterprise/multi-user layer** — no RBAC, no Open-WebUI-style
  Channels, no admin console. mlx-bun is single-user by identity.
- **No general-purpose agent-flow builder** (AnythingLLM's Agent Flows,
  Msty's Turnstiles). Automation, if any, is scoped narrowly to what
  the synthesis pipeline needs, not a drag-and-drop canvas.
- **No cloud tier, no hosted anything** — no Ollama-style `:cloud`
  hybrid. "Escalate to a bigger model" means local spec-decode against
  a larger local target, never a paid API.
- **No email/calendar/documents workspace clone** (Odysseus's scope
  creep). Personal-context connectors, if they ever happen, are
  read-only memory *feeders*, not a productivity suite to maintain.
- **No full conversation-tree graph view.** The lightweight
  sibling-toggle branch UI (ChatGPT/Claude's convention) is the right
  amount of investment; neither incumbent ships a real tree either.
- **No page-level PDF citation rendering as v1.** Filename + snippet
  citation gets most of the trust benefit for a fraction of the
  engineering; save PDF-aware rendering for later.
- **No speech-to-speech voice mode as a v1 commitment** — a bolt-on
  STT→LLM→TTS pipeline reads as worse than what users now expect;
  scope as future work, not parity-by-next-release.
- **No unsandboxed shell tool shipped quietly.** If Power mode widens
  the toolset to bash/edit/write, the approval-gate trust surface
  ships *with* it, not after — Odysseus's unsandboxed bash tool and
  its 48-hour-patched CVEs are the cautionary tale.
- **No competing on raw model-catalog breadth** (Ollama's library,
  LM Studio's HF browser). MLX-only by identity; a focused, well-labeled
  local model/adapter list beats a sprawling catalog we'd have to
  maintain against a moving target.

## Why this ordering, not another

Speed, tool UX, and multi-adapter composition are all worth building —
the research surfaces excellent, copyable patterns for each (Jan's
inline approval cards, LM Studio's hardware-fit indicator, Msty's
split-pane compare). But every one of those patterns is *matchable* by
a well-resourced competitor within a release cycle. The memory flywheel
is not: it requires a vault architecture, a synthesis pipeline, an
adapter-namespaced KV runtime, and a product culture willing to treat
"gets better at being yours" as the headline rather than a checkbox —
all of which mlx-bun already has built and simply hasn't surfaced. The
redesign's job is not to invent new backend capability. It's to stop
hiding the one capability nothing else in this market has, and frame
every other improvement (speed HUD, tool cards, adapter switching) as
infrastructure *for* that capability, not a parallel feature track.
