# Memory system — design sketch

Status: **design** (nothing built yet; capture prerequisite already landed)
Owner: assistant layer (pi-web / pi-terminal / web-tools / jobs)
Default: **off** until the user opts in (vault + schedule are explicit, consented actions)

Ported from **lucien** (`~/Code/lucien`, vault at `~/Dreaming`) — a separate,
already-working system at real scale (thousands of conversations, hundreds of
articles). We are **not importing lucien**; we are reimplementing its ideas as a
first-class, reusable mlx-bun module that runs on the **local model** and wires
into mlx-bun's own substrate (sessions, jobs, web-tools, skills, CLI).

## Goal

Give the local assistant durable, user-specific memory so it can **resume
instead of restart**. The product thesis is "local to you" — the moat is
private accumulated context, not the weights ([[local-to-you-thesis]]). Memory
is how that context accumulates.

Three steps, the **flywheel**:

1. **Capture** — conversations during sessions are saved to disk.
2. **Synthesize** — nightly, a scheduled pass turns those conversations into
   *articles* (a small personal wiki).
3. **Consult** — the assistant (web + CLI) has read tools + a skill that make it
   read the relevant articles when answering.

Talk → assistant reads the wiki → you add/correct context → nightly synthesis
folds it into articles → richer next conversation. Articles are *priors*,
conversations are *evidence*, synthesis updates the priors over time; chat-time
access is read-only.

## Naming: "memory", not "the Dreaming"

Recommendation: user-facing name is **memory** (`mlx-bun memory …`), the store
is `~/.mlx-bun/memory/`. We keep lucien's *good descriptive concepts* (articles,
wikilinks, Meta governance pages, Talk pages, conservative integrate-don't-
overwrite synthesis) but drop the mythology ("the Dreaming", "librarian",
"dreaming"). Reasons:

- The Dreaming mythology is Josh's personal branding for a *different* project.
  mlx-bun has its own identity (MLX-only, bun/JS, Apple Silicon, "local to
  you" — [[mlx-bun-scope-and-framing]]). Importing the cosmology muddies the
  product story.
- "Memory" is the term users already hold (ChatGPT/Claude memory). It's
  self-explanatory in `--help` and in the assistant's "what can you do?" list —
  no glossary required.
- This is a port/reimplementation, not lucien-the-dependency. A plain name
  avoids implying we ship or require the external lucien MCP.

## Port, not import: what carries over and what changes

| Aspect | lucien | mlx-bun memory |
| --- | --- | --- |
| Read interface | MCP server (stdio) | native web-tools + a bundled skill |
| Synthesis engine | spawns `claude -p --model opus` (cloud) | **the local model** (in-process / local server) |
| Conversation sources | claude-code JSONL + claude.ai (Playwright) + codex | **mlx-bun's own sessions** only (web + pi terminal) |
| Pipeline orchestration | `nightly.sh` + ~36 standalone scripts | a **job runner** on `src/jobs/*` (progress → web UI via SSE) |
| Scheduling | user-added crontab line | `mlx-bun memory schedule` installs a **launchd** agent |
| Setup | `lucien_setup` MCP tool | `mlx-bun memory setup` **or** the assistant via a skill |
| Vault | `~/Dreaming` markdown + git | `~/.mlx-bun/memory/` markdown + git (same format) |
| State DB | `.lucien/lucien.db` (sqlite) | `memory.sqlite` (sqlite) — see storage decision below |

The hard, proven parts we keep wholesale: the **article format** (lead +
sections + `## References` with `conv:` footnotes + `[[wikilinks]]`), the
**Meta governance pages** (editorial conventions live *in* the vault, read by
the synthesis prompts), **idempotency** (watermarks + per-chunk synthesized
markers so re-runs are safe), and the **conservative synthesis gate** (preserve
prose, ≥70% word-count floor, every original citation survives).

The big departure is **synthesis runs locally**. lucien outsources the hard NLP
to Opus; we do it on e4b/12B. That fits the privacy thesis (nothing leaves the
machine) and lines up with the planned **memory LoRAs** — each pipeline stage
(chunk / classify / synthesize / wikify) is a future specialized adapter routed
via `adapterScoped` ([[lora-routing-architecture]]). Synthesis quality on a
local model is the main open *quality* risk; it's a nightly batch job where
latency doesn't matter, so we gate output the way lucien does. Graceful
degradation applies
([[three-tier-parity-and-degradation]]): a weak synthesis pass should no-op, not
corrupt the vault.

## Architecture

### Storage layout

mlx-bun already splits durable user state from rebuildable cache:

- `~/.mlx-bun/` — **durable, user-owned**: `sessions/` (web chat JSONL),
  `pi/` (terminal sessions), `pi-sessions/` (web agentDir), `skills/`,
  `hf.json`.
- `~/.cache/mlx-bun/` — **rebuildable / derived**: `registry.sqlite`,
  `evals.sqlite`, `jobs.sqlite`, `jobs/`, `datasets/`, `quants/`, `adapters/`.

Proposed:

```
~/.mlx-bun/memory/              # the vault — precious, user-owned, git-tracked
  articles/                     #   Topic_Name.md (underscored stems)
  Meta/                         #   Editorial_Guidelines.md, Article_Conventions.md,
                                #   Buckets.md, Topics_to_Ignore.md, Synthesis_Pipeline.md
  Talk/                         #   per-article discussion / conflict notes
  README.md
  .git/                         #   every synthesis run commits here
  .gitignore                    #   ignores memory.sqlite* (don't commit a binary)
  memory.sqlite                 #   synthesis bookkeeping (cursors, chunks, buckets)
```

**Everything lives under `~/.mlx-bun/memory/`** — the vault *and* the bookkeeping
DB (decided 2026-06-14). The win is that "your memory" is one self-contained,
portable folder: copy it and your memory moves to another machine, intact. It
also keeps the privacy story literal — one place to point at and one place to
delete. The DB is derived state (it can be rebuilt from the transcripts +
articles), so the seeded `.gitignore` excludes `memory.sqlite*` — git tracks the
articles (the source of truth, with history), not the binary index. This is a
deliberate, documented exception to the codebase's cache-vs-durable split
(`evals`/`jobs`/`registry` dbs live in `~/.cache/mlx-bun/`), justified by
treating memory as a single portable unit.

### The vault

Identical in spirit to lucien's. `mlx-bun memory setup` seeds it idempotently:
create dirs, write Meta pages (only if missing — never clobber user edits),
write README, `git init` + initial commit. Articles are plain markdown:

```markdown
# Archie Project

The **Archie Project** is an internal AI agent platform Josh built at
[[AlphaPoint]] beginning spring 2026.[^1][^2]

## Origin
...[^1]

## References
[^1]: `conv:a1b2c3d4` (2026-05-10, mlx-bun) — Archie design overview
```

Citations point at `conv:<hash>` — a stable id derived from the source session,
so an article is traceable back to the conversation that produced it. The vault
is a valid Obsidian vault for free (browse with Obsidian, edit by hand; the next
synthesis run respects your edits).

### Ingestion — mlx-bun sessions only

No Playwright, no web scraping. The capture prerequisite **already exists**:
web chat persists each session to `~/.mlx-bun/sessions/*.jsonl` via
`SessionManager.create(...)` ([pi-web.ts:398](../../src/pi-web.ts)), and the
comment there already names this as "the durable transcript store the nightly
memory pipeline reads." Terminal pi persists to `~/.mlx-bun/pi`. Both are pi's
own JSONL format, enumerable via `SessionManager.list/listAll`.

So ingestion = read pi sessions → normalize to `{conv uuid, messages[]}` →
upsert into `memory.sqlite`, tracking a per-source watermark so each nightly run
only processes what's new. pi's session format becomes the ingestion contract
for free.

### The nightly pipeline (on `src/jobs/*`)

Reuse the existing background-job substrate (`src/jobs/{db,runner,sse}.ts`):
register a `memory-synthesis` runner and `submitSubprocess(...)` it so model
state is GPU-isolated. Stages mirror lucien, each emitting `stage`/`log` events
that stream to the web UI through the existing SSE endpoint — synthesis shows up
in the same jobs panel as quantize/finetune.

```
ingest      pi sessions → memory.sqlite (watermark-gated, upsert)
chunk       segment each new conversation into topic chunks   (model call)
cluster     assign chunks to existing buckets / propose new    (model call)
synthesize  per bucket: create-or-update its article           (model call)
wikify      deterministic gate + Wikipedia-style cleanup (non-fatal)
normalize   canonical [[wikilinks]], footnote repair
changelog   per-run digest → Meta/Changelog.md, git commit
```

Idempotency is inherited from lucien's design: watermarks (don't re-ingest),
`chunked_at > updated_at` (re-chunk only changed convs), and a
`synthesized_bucket_chunks` table (never feed the same chunk into an article
twice). A killed run resumes cleanly.

### Synthesis runs on the local model

`mlx-bun memory synthesize` loads a model in-process (or reuses a running
server) and drives every model call through it — **no cloud, local-only**
(decided 2026-06-14). Default synthesis model: **e4b** (decided 2026-06-14) —
lighter, lower memory, and mlx-bun's strongest h2h result; a weak pass is gated
to no-op rather than allowed to corrupt the vault. Overridable per-run
(`--model 12B` when you want the parity model's quality). This is the seam where
the future memory
LoRAs plug in: today base-model + prompt per stage; later `adapterScoped` per
stage ([[lora-routing-architecture]]).

### Read tools — how the assistant consults memory

Add native read tools in `src/web-tools.ts` (the `defineTool` pattern), name
them in `WEB_TOOL_NAMES`, list them in `ALL_TOOLS` in both
[pi-web.ts](../../src/pi-web.ts) and [pi-terminal.ts](../../src/pi-terminal.ts);
read-only, so they auto-allow (no approval gate). Mirror lucien's read surface:

- `memory_search` — keyword/substring search across articles → ranked hits with
  section anchors (the discovery entry point)
- `memory_read` — full article body
- `memory_list` — list article titles (fallback / overview)
- (later) `memory_section`, `memory_links` for focused reads + wikilink graph

**Knowing *when* to consult** uses three reinforcing mechanisms:
1. Tool descriptions that strongly cue "search the user's memory when they
   mention their own projects, people, tools, preferences, or history."
2. A bundled **memory skill** (below) that says "consult quietly before
   answering personal-context questions" — same trigger surface as the
   `anthropic-skills:lucien` skill.
3. Cheap **index injection**: at session start, put the *list of article titles*
   into the system prompt (a few hundred tokens) so the model knows what exists
   and can fetch the right page. (Not the article bodies — that's what the tools
   are for.)

## Two front doors: CLI + assistant

One implementation (the CLI / `src/memory` module), two ways to reach it.

### CLI — `mlx-bun memory <subcommand>`

New `case "memory"` in [cli.ts](../../src/cli.ts) + a `HELP.memory` entry.

```
mlx-bun memory setup            create the vault + Meta pages + git (idempotent)
mlx-bun memory status           vault path, #articles, last synthesis, schedule state
mlx-bun memory synthesize       run the pipeline now (--model, --since, --dry-run)
mlx-bun memory schedule         install the nightly launchd agent (--at 03:00)
mlx-bun memory unschedule       remove the launchd agent
mlx-bun memory search <q>       inspect: search articles from the terminal
mlx-bun memory read <title>     inspect: print an article
mlx-bun memory forget <title>   delete an article (git-tracked, recoverable)
```

### Assistant-driven setup (a bundled skill)

Add `src/web/skills/memory/SKILL.md` to `BUNDLED_SKILLS`
([web/skills.ts](../../src/web/skills.ts)). This is the best vehicle because:

- The skill's **description** makes "manage memory" appear under "what can you
  do?" for free.
- The skill's **body** encodes the explain → consent → setup script: explain in
  plain terms (it's a folder of markdown articles; it saves your conversations;
  it synthesizes them into articles nightly; it uses them to remember you), then
  on agreement run the `mlx-bun memory setup` and `mlx-bun memory schedule`
  commands via the bash tool.

So the assistant can both **offer/explain** memory and **set it up** for you,
and the single CLI implementation stays the source of truth.

### Consent model

Drawn deliberately, two tiers:

- **Capture is default-on, not a consent gate.** Saving sessions locally is what
  pi already does (like shell history) and it never leaves the machine. But
  default-on ≠ silent: state it once ("I keep our chats at `~/.mlx-bun/sessions`
  so I can remember — clear them anytime"). The recent-chats sidebar doubles as
  the "where's my data / delete it" surface.
- **Synthesis into a persistent wiki + a scheduled job IS the consent gate** —
  that's what changes the privacy posture. The skill asks in prose, and the
  per-action approval gate confirms each persistent change (writing the vault,
  installing the launchd agent). Two natural confirmations, the right amount for
  installing a recurring job.

## Scheduling (launchd)

mlx-bun has no scheduler today. Recommendation: **launchd**, not crontab.
mlx-bun is macOS/Apple-Silicon-only by identity, so launchd is the native
choice — it survives reboot, runs missed jobs, and gives clean
install/uninstall. `mlx-bun memory schedule` writes
`~/Library/LaunchAgents/com.mlx-bun.memory.plist` (a `StartCalendarInterval` at
~03:00 running `mlx-bun memory synthesize`) and `launchctl load`s it;
`unschedule` unloads + removes it. Schedule state surfaces in
`mlx-bun memory status`.

## Privacy (the throughline)

Local model + local vault + local cron + local transcripts — **nothing leaves
the machine**. This is consistent with the web-chat privacy framing where the
web tools are the only outbound path. It is also the differentiator: not the
best AI, the best at knowing *you* ([[local-to-you-thesis]]).

## Module layout (reusable)

A self-contained `src/memory/` module so the feature is reusable by both the CLI
and the server, and is testable in isolation:

```
src/memory/
  vault.ts        paths, setup (dirs + Meta + git), article read/write/list
  db.ts           memory.sqlite: conversations, chunks, buckets, watermarks
  ingest.ts       pi sessions → db  (uses SessionManager.list/listAll)
  chunk.ts        conversation → topic chunks  (local-model call)
  cluster.ts      chunks → buckets             (local-model call)
  synthesize.ts   bucket → article create/update + gate  (local-model call)
  wikify.ts       deterministic editorial gate + normalize
  pipeline.ts     registerRunner("memory-synthesis", …) — ties stages together
  tools.ts        memory_search / memory_read / memory_list (web-tools)
  schedule.ts     launchd plist install/remove
  prompts/        per-stage prompts (the future LoRA seams)
```

## Phasing

- **M0 — vault + read path.** `src/memory/{vault,db}.ts`, `memory setup`, the
  read tools + index injection, the bundled skill (offer/explain/setup). No
  synthesis yet — the assistant can already read a hand-written or imported
  vault. Lets us validate the *consult* half against a real vault (even one
  copied from `~/Dreaming`) before building the pipeline.
- **M1 — ingest + pipeline (manual).** `ingest/chunk/cluster/synthesize/wikify`
  as a `memory-synthesis` job, run on demand via `memory synthesize`. Validate
  synthesis quality on the local model against every model/quant we care about
  ([[per-model-quant-specialization]]).
- **M2 — schedule.** launchd install/remove; status surfacing; transparency
  line on first capture.
- **M3 — quality + LoRAs.** Per-stage memory LoRAs via `adapterScoped`; KL /
  quality benchmarks for the synthesis output ([[lora-routing-architecture]]).

## Help text + docs changes (don't forget)

- `HELP.memory` in [cli.ts](../../src/cli.ts) (+ the top-of-file command list).
- README: a "Memory" section under the pitch (the flywheel + privacy).
- `docs/reference/`: a `memory.md` (vault format, CLI surface, tool list).
- This design doc; update PLAN.md with a Memory phase + exit criteria.
- The bundled skill description (so "manage memory" shows in "what can you do?").

## Decisions (settled 2026-06-14)

1. **Storage** — everything (vault + `memory.sqlite`) under `~/.mlx-bun/memory/`,
   one portable folder; `.gitignore` excludes the DB.
2. **Synthesis engine** — local-only, no cloud; weak output is gated to no-op.
3. **Default synthesis model** — e4b, overridable per-run (`--model 12B`).

## Open decisions

1. **Retroactive capture.** On first setup, synthesize past sessions too, or
   future-only? Recommendation: offer "synthesize what's already here" as a
   one-time step right after setup, surfaced by the skill.
