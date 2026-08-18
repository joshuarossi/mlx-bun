# OpenWiki — evaluation & fit analysis

**Date:** 2026-07-06
**Author:** investigation (agent), worktree `investigate/openwiki-memory`
**Subject:** [langchain-ai/openwiki](https://github.com/langchain-ai/openwiki) — "a CLI that writes and
maintains agent documentation for your codebase, built specifically for agents to consume."
**Question asked:** how (if at all) does OpenWiki fit inside our memory system ("The Dreaming"), and
is it a good fit anywhere else in mlx-bun?

---

## TL;DR — four verdicts

| # | Question | Verdict | One-liner |
|---|----------|---------|-----------|
| 1 | Adopt OpenWiki **as the memory engine**? | ❌ **No** | Architecturally the mirror-image of The Dreaming; would throw away the hard-won decomposition + gate design and drag LangChain into a Bun/MLX-only repo. |
| 2 | Borrow OpenWiki **patterns** into memory? | 🟡 **Marginal** | We already independently arrived at its good ideas, usually in stronger form. One minor borrow (the `_plan.md` durable-plan artifact). |
| 3 | Run OpenWiki **on mlx-bun the repo** (its own agent docs)? | ✅ **Yes, good fit** | It targets exactly our named failure mode — reference-doc drift — and runs as an external dev tool, not a vendored dep. |
| 4 | Point OpenWiki **at our own OpenAI-compatible server**? | ✅ **Yes — the strategic find** | DeepAgents-over-local-mlx-bun is an on-brand, zero-cloud dogfood showcase *and* a hard agentic-tool-use conformance test for the server. |

The headline: **OpenWiki is not a fit *inside* the memory pipeline, but it is a fit *around* mlx-bun** —
as a doc tool for our own repo and, more interestingly, as a real LangChain agent to run *against* our
server to prove the "drop-in, local, agentic" thesis.

---

## 1. What OpenWiki is (full rundown)

A CLI (`npm install -g openwiki`) from LangChain, released **v0.0.1 on 2026-07-05** (i.e. one day old at
time of writing; ~7.7k stars, but 42 open PRs / 48 issues — treat as brand-new and unstable). MIT
licensed. TypeScript/JavaScript.

**Purpose.** Generate and maintain a repo's documentation *for coding agents*, not for humans. The
generated wiki is "structured markdown optimized for LLM context — headings, cross-references, and
summaries designed for an agent to quickly find relevant context." Motivation from the launch post:
*"Agents write better code when they understand the repo they're working in,"* and stuffing the whole
repo into one `CLAUDE.md` wastes context in large repos.

**Surface.**
```
openwiki --init            # pick provider + API key, then generate the wiki
openwiki                   # interactive
openwiki "<request>"       # interactive, seeded
openwiki -p "<request>"    # one-shot, non-interactive
openwiki --update          # refresh from repo changes since last run
```
- Writes an `openwiki/` directory of markdown pages.
- Patches `AGENTS.md` / `CLAUDE.md` with a pointer to the wiki **and a "when to use it" note**.
- Ships a **GitHub Action** and **GitLab CI** template that open a PR/MR when docs need updating.
- Config in `~/.openwiki/.env`: provider, API key, model id, optional LangSmith tracing.
- Providers: OpenRouter (default, an open model), Fireworks, Baseten, OpenAI, Anthropic, and
  **OpenAI-compatible** via `OPENAI_COMPATIBLE_BASE_URL` (also `ANTHROPIC_BASE_URL`). ← load-bearing
  for verdict 4.

## 2. How OpenWiki works (architecture)

Built on LangChain's **DeepAgents** + **LangGraph**. The construction is deliberately thin:

```ts
const agent = createDeepAgent({
  model,
  tools: [],                         // NO custom tools
  checkpointer,                      // thread memory
  backend: new LocalShellBackend({ /* vfs → repo root */ }),
  systemPrompt: createSystemPrompt(command),
});
```

- **No bespoke tools.** It hands a general coding agent a `LocalShellBackend`: a virtual filesystem
  mapped to the repo root exposing `ls / read_file / write_file / edit_file / glob / grep` plus a
  sandboxed `execute` (120 s timeout, 100 KB output cap). All capability comes from the shell backend.
- **All the IP is in the system prompt + the loop.** The prompt encodes:
  - **Discovery → plan.** Before writing, the agent writes a temporary `openwiki/_plan.md` listing
    *intended pages, source evidence per page, and remaining questions.*
  - **Granularity rules.** ≤~10 primary source files → a `quickstart.md` + at most 1–2 supporting
    pages. *"Do not create a directory unless it represents a real documentation area."*
  - **One canonical page per concept.** *"Keep each concept in one canonical page… keep the detailed
    explanation in the canonical page and make other mentions brief or link-only."* Inline source-file
    references so a reader can verify.
  - **Surgical, diff-budgeted updates.** On `--update` it *"checks which commits landed since the last
    run, uses git diffs to understand what changed, then updates the wiki."* Soft budget: *"if fewer
    than about 5 source files changed, update at most 1–2 wiki pages… Updates may be a no-op."*
- **Change detection** by content snapshot (`createOpenWikiContentSnapshot`); persists run metadata
  only when the wiki actually changed.
- Streaming LangGraph invocation with a checkpointer keyed by `thread_id` (interactive Q&A over the
  wiki + codebase reuses the thread).

**Design bet:** a *strong single model* + a *good prompt* + a *free-roaming agent* with raw shell
tools. Trust the model to hold the repo in its head and write files directly.

## 3. The Dreaming, in one screen (for contrast)

Our memory system ("The Dreaming", `src/memory/*`, ~12 k LoC, running end-to-end on real data):

- **Corpus:** the user's conversation history (pointer-DB of `messages` → `chunks` as
  `(conv,start,end)` ranges), not a code tree.
- **Engine:** ONE local model (`gemma-4-e4b-it-OptiQ-4bit`) + per-stage LoRAs, loaded once. No cloud.
- **Pipeline:** `SEGMENT → EXTRACT → ROUTE → SECTION-ROUTE → PATCH → NORMALIZE → LINK → WIKIFY →
  RECONCILE → COMMIT`, every stage the *smallest atomic task* (binary yes/no preferred).
- **Output:** entity-centric wiki — articles are *things*, with infoboxes, wikilinks, categories.
- **Invariants enforced by code, not the model:** *"LoRAs propose, gates dispose"* — ≥70% prose floor,
  every citation survives, weak output → NO-OP, deterministic footnote bijection + wikilink
  canonicalization, one git commit per run.
- **Single writer:** *"Chat agents read memory; `mlx-bun memory synthesize` is the only writer."* Reads
  go through 7 read-only `memory_*` tools + a bundled skill.
- **Self-healing:** chronological walk; latest statement wins; AI errors silently overwritten.

**Design bet:** the exact opposite of OpenWiki — a *weak local model* + *heavy decomposition* +
*deterministic scaffolding*. Assume the model **cannot** hold an article in its head or be trusted to
write files freely, and engineer around that.

## 4. Head-to-head: same shape, opposite philosophy

Both are *"corpus → agentic synthesis → LLM-navigable markdown wiki → agent consumes it, kept fresh
incrementally."* That surface similarity is why the question is worth asking. But under the hood they
are mirror images:

| Axis | OpenWiki | The Dreaming |
|------|----------|--------------|
| Corpus | Code repository | Personal conversation history |
| Model | Strong cloud model (default OpenRouter) | Weak local e4b + LoRAs, no cloud |
| Capacity model | Big context — model holds the repo | *Capacity by decomposition* — can't hold an article |
| Harness | Thin (shell tools + one prompt) | Thick (10-stage DAG, ledgers, gates) |
| Writes | Agent writes files freely | Single writer, gated, git-committed |
| Dedup | Prompt rule ("one canonical page") | Deterministic entity name-match routing |
| Update trigger | `git diff` since last commit | Chronological chunk cursor / new sessions |
| Self-healing | Re-edit page on diff | Chronological latest-value reconcile |
| Determinism | Trusts the model | Code enforces invariants |
| Deps | LangChain + DeepAgents + LangGraph | Bun-native, MLX-only, minimal |

Pithily: **OpenWiki = smart model, dumb harness. The Dreaming = dumb model, smart harness.** They solve
the same *shape* of problem from opposite ends of the model-capability axis.

## 5. The four fit verdicts, argued

### Verdict 1 — OpenWiki as the memory engine: ❌ No

- **Architectural inversion.** The Dreaming's entire thesis is that a local 4-bit e4b *cannot* do
  OpenWiki's free-roaming, hold-it-in-context, write-files-directly loop — which is *why* the
  decomposition + gate architecture exists. Adopting OpenWiki means discarding the exact design that
  makes local synthesis work.
- **Contract violation.** OpenWiki's agent writes files freely; The Dreaming has a single gated writer
  with a git-commit-per-run audit trail and NO-OP-on-weak-output. These are incompatible write models.
- **Corpus mismatch.** OpenWiki reads a code tree via shell/grep; The Dreaming reads a pointer-DB of
  conversation chunks with chronological self-healing. Different input, different invariants.
- **Identity/deps.** Pulling LangChain + LangGraph into a repo whose stated identity is Bun-native,
  MLX-only, minimal-dep, private (see the `mlx-bun scope & framing` and `drop-in replacement` notes)
  is a non-starter as a runtime dependency.
- **Maturity.** v0.0.1, one day old. Nothing load-bearing should sit on it yet.

### Verdict 2 — Borrow OpenWiki's patterns: 🟡 Marginal

We have *convergently* arrived at most of OpenWiki's good ideas, usually stronger:

| OpenWiki idea | Our equivalent | Who's ahead |
|---------------|----------------|-------------|
| `_plan.md` before writing | CREATE flow: sub-cluster → outline → draft | ~tie; their durable, reviewable *plan artifact* is a nice touch |
| Soft diff budget, updates may be no-op | Idempotency ledger + conservative gate + NO-OP | **us** (ledger is stronger than a prompt heuristic) |
| One canonical page (prompt rule) | Deterministic entity name-match routing | **us** (mechanism > instruction) |
| Patch `AGENTS.md`/`CLAUDE.md` with pointer | 7 read-only `memory_*` tools + bundled skill | **us** (tools > prose pointer) |
| git-diff-driven refresh | chronological chunk cursor | different corpus; both valid |

**Only genuinely fresh borrow:** emit a durable, auditable **plan artifact** (their `_plan.md`) in the
CREATE flow, so a synthesis run's *intended* article/section changes are reviewable in the git diff
alongside the result. Low effort, small upside. Not worth a dedicated work item; fold in opportunistically.

### Verdict 3 — Run OpenWiki on mlx-bun the repo: ✅ Good fit

This is where OpenWiki was literally built to help, and mlx-bun is close to a canonical target:

- **It attacks our named failure mode.** `CLAUDE.md` calls reference-doc drift *"the observed failure
  mode"* (the 2026-07-03 sweep found undocumented flags, dead version pins). The doc-map even carries a
  manual chore: *"keep these lists in sync with `ls docs/…`."* OpenWiki's diff-driven refresh + CI-PR is
  exactly this job.
- **Additive, not a replacement.** It would generate a *derived, agent-facing structural index of the
  code* — it does **not** replace the curated, opinionated human docs (`PLAN.md` is "the engineering
  contract"; `STATUS.md`, design docs). Think: an auto-maintained `openwiki/` map of `src/` that points
  back into the hand-written design docs.
- **Nice synergy with the vault.** The memory vault already symlinks mlx-bun docs into
  `~/.mlx-bun/wiki/Reference/` (read-only). An auto-maintained repo wiki would flow straight into that
  Reference surface — the personal vault gets a fresher code map for free.
- **Runs as an external dev tool**, a global npm CLI in CI — *not* a vendored dependency. No LangChain
  contamination of the shipped codebase. This sidesteps the Verdict-1 dependency objection entirely.

**Caveat:** the one tension is "cloud API on a local/private repo." Verdict 4 dissolves it.

### Verdict 4 — Point OpenWiki at our own OpenAI-compatible server: ✅ The strategic find

OpenWiki speaks **OpenAI-compatible base URL**; mlx-bun *is* an OpenAI-compatible server (the whole
"drop-in replacement for mlx-lm / serving speed is the user metric" thesis). Compose them:

```
OPENAI_COMPATIBLE_BASE_URL=http://localhost:<mlx-bun-port> \
OPENAI_COMPATIBLE_API_KEY=… openwiki --init   # generate mlx-bun's own wiki, 100% local
```

Why this is the most interesting outcome of the investigation:

1. **On-brand, zero-cloud.** Resolves the Verdict-3 tension: a real LangChain agent documents our repo
   with *no* cloud call, on a Gemma running in mlx-bun. Directly demonstrates the `local-to-you` and
   `install-to-chat` theses on an external, third-party agent.
2. **A hard conformance test.** DeepAgents drives many tool calls + long contexts + streaming. Chat
   parity is easy; *agentic tool-use conformance* is the bar that actually matters for "agents need the
   server" (`serving speed is the user metric`). If OpenWiki runs unmodified end-to-end against our
   server, that's a strong, concrete proof point for the README/website. If it *doesn't*, we've found a
   real function-calling / prefill / KV gap under agentic load — also valuable.
3. **Coverage/stress.** It exercises the server the way a coding agent does (glob/grep/read/write loops,
   big prefills), complementing the batch/spec-decode perf work with a realistic agentic workload.

**Caveat to measure, not assume:** DeepAgents presumes a *capable* model — the very assumption The
Dreaming rejects for local e4b. A 4-bit e4b may drive the free-roaming loop poorly and produce a
mediocre wiki. Mitigations: point it at a larger local model (the 12B parity target) via the same
server, and/or judge output quality explicitly. Either way the *conformance* result (does the loop run?)
is decoupled from the *quality* result (is the wiki good?), and both are worth knowing.

## 6. Recommendation — what to actually do

1. **Do not** put OpenWiki inside the memory pipeline. The Dreaming is more mature for its constraints
   and philosophically opposite. (Verdicts 1 & 2.)
2. **Spike Verdict 4 first — it's the highest-information, lowest-cost move.** Point OpenWiki at a
   running mlx-bun server (Josh runs the server; no session starts it) and try `openwiki --init` on a
   small repo, then on mlx-bun itself. Outcome is binary-useful: either a showcase demo of
   "third-party LangChain agent runs locally on mlx-bun," or a concrete agentic-tool-use bug list for
   the server. Bench it under the standard preflight if any perf number gets quoted
   (`dirty-machine-numbers-are-garbage`).
3. **If the spike is clean,** consider OpenWiki as an *external CI doc tool* for the repo (Verdict 3):
   an auto-maintained `openwiki/` structural map that feeds the vault's `Reference/` surface. Keep it
   clearly subordinate to the hand-written `PLAN.md`/design docs.
4. **Opportunistically** add a durable `_plan.md`-style plan artifact to the memory CREATE flow for
   reviewability (Verdict 2). Not a standalone work item.

## 7. Risks & unknowns

- OpenWiki is **v0.0.1, ~1 day old**, 42 open PRs / 48 issues — API and behavior will churn. Pin a
  commit if used in CI.
- **Local-model quality** driving DeepAgents is unproven (contradicts our own capacity-by-decomposition
  finding). Measure; don't assume the wiki is good just because the loop runs.
- **DeepAgents ⇄ our server function-calling compatibility** is the actual thing under test in Verdict
  4 — tool-call formatting, streaming, and long-prefill behavior are where it could break.
- Do **not** treat any OpenWiki-generated wiki as a source of truth over the curated docs; it's a
  derived index.

## Sources

- [langchain-ai/openwiki](https://github.com/langchain-ai/openwiki) — repo, README, `src/agent/*`
- [LangChain blog — Introducing OpenWiki](https://www.langchain.com/blog/introducing-openwiki-an-open-source-agent-for-repo-documentation)
- Internal: `docs/design/memory-system.md`, `memory-synthesis.md`, `memory-inference-path.md`,
  `write-pipeline-entity.md`, `the-dreaming-master-plan.md`, `the-dreaming-handoff.md`,
  `docs/reference/memory.md`; `src/memory/*` (~12 k LoC).
