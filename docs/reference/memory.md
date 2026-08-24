# Memory — the personal wiki

`mlx-bun memory` is a local, durable memory for your assistant: a wiki of
Markdown articles at `~/.mlx-bun/wiki/` that the built-in pi agent reads to
remember your projects, people, decisions, and history across sessions. It is
yours — git-tracked, editable in any tool (Obsidian opens it as a vault), and it
never leaves the machine.

The one rule the whole feature is built around:

> Chat-time agents **read** memory. `mlx-bun memory synthesize` is the only
> thing that **writes** it.

Articles are durable priors; conversations are evidence; synthesis is the
deliberate, auditable step that turns evidence into updated articles. Normal
chat never mutates an article. Nightly synthesis is called **the Dreaming**;
its engineering design lives in
[dreaming-nightly-pipeline.md](../design/dreaming-nightly-pipeline.md) — this
page is the user-facing reference.

## Quick start

```bash
mlx-bun memory init            # create the wiki; offers import + nightly job
mlx-bun pi                     # the assistant now reads your memory automatically
mlx-bun memory status          # where it is, how many articles, schedule state
mlx-bun memory search <query>  # find something from the terminal
mlx-bun memory open            # browse it in Obsidian
```

`init` is idempotent and safe to re-run. It never overwrites files you have
edited: the README and `Meta/` pages are written only when missing. Once a
wiki exists, every `mlx-bun pi` session and the web chat behind `mlx-bun serve`
pick it up with no further configuration; if it does not exist, no memory
tools or prompt hints are exposed at all.

`mlx-bun setup` is a true alias for `mlx-bun memory` (same subcommands).

## What the wiki contains

Everything lives under one portable folder (copy it and your memory moves
with you):

| Path | What it is |
| --- | --- |
| `~/.mlx-bun/wiki/` | The vault root. Override with `MLX_BUN_WIKI=/path/to/wiki`. |
| `articles/*.md` | Your memory articles — one topic per file, `Topic_Name.md`. The only thing synthesis writes. |
| `Reference/*.md` | Read-only symlinks to mlx-bun's own docs (README, server API/config, library API, embedding, distribution, training, ORPO quickstart, product roadmap), so the assistant can answer mlx-bun questions on day one. Synthesis never writes here. |
| `Meta/*.md` | Operational pages the pipeline follows: editorial guidelines, article conventions, infobox schemas, category definitions, entities policy, summary style, bucketing/buckets, chunking, topics to ignore. Edit them to steer synthesis. |
| `Talk/` | Per-article discussion and conflict notes. |
| `README.md`, `.gitignore` | Orientation page; keeps `.DS_Store` and Obsidian workspace state out of git. |

The vault is plain Markdown and a git repository (`init` runs `git init` and
makes the initial commit). Every synthesis run commits its changes, so any
article change is reviewable and revertible with ordinary git. You can edit
any file directly; the next run respects your edits.

Two things live **outside** the vault because they are derived or operational:

- `~/.cache/mlx-bun/memory.sqlite` — the synthesis store (ingested
  conversations, chunks, buckets, watermarks, and a rebuildable index of the
  articles). The vault is truth; this DB is a cache plus pipeline ledger.
- `~/.mlx-bun/logs/memory-synthesis.{out,err}.log` — output of the nightly job.

Article names are **stems**: the filename without `.md`, underscores for
spaces (`Archie_Project`). Every command and tool below takes a stem.

## CLI

All subcommands are `mlx-bun memory <sub>`; with no subcommand, `status` runs.
An unknown subcommand prints help and exits non-zero (so scripts and launchd
jobs can detect typos).

### Set up and inspect

```bash
mlx-bun memory init              # create the wiki (alias: setup)
mlx-bun memory status            # path, article + reference counts, git, nightly state, recent articles
mlx-bun memory open [article]    # open the wiki or one article (alias: browse)
```

`init` walks through setup in a terminal: creates the vault, then offers to
seed it by importing `articles/*.md` from an existing wiki you point it at
(existing files are never overwritten), then offers to install the nightly
synthesis job. Both offers are TTY-only and default to no import / no
schedule, so a non-interactive `init` just creates the vault.

`open` prefers Obsidian (`open -a Obsidian` for the vault, the `obsidian://`
URL handler for a single article) and falls back to Finder / the default
Markdown app.

### Read from the terminal

```bash
mlx-bun memory list                        # article stems + Reference/* docs
mlx-bun memory search <query>              # ranked article matches + sample lines
mlx-bun memory toc <article>               # headings with their #anchors
mlx-bun memory section <article> <anchor>  # one section's body
mlx-bun memory links <article>             # resolved outbound + inbound [[wikilinks]]
mlx-bun memory read <article>              # the full article
```

These are the same filesystem helpers the agent tools use. `search` is a
substring search over articles and reference docs, not a semantic one; results
prefixed `Reference/` are mlx-bun docs, not your memory.

### Synthesize

```bash
mlx-bun memory synthesize [--dry-run]      # run the full pipeline now (aliases: pipeline, all)
```

**This writes to your vault** (only `articles/`, committed to git). It runs
the full local DAG — segment → extract → route → create/patch → link — then an
editorial wikify sweep over every article. `--dry-run` is the safe mode: it
lists the planned stages, makes no model calls, and writes nothing. The
command also accepts `--since` and `--model`, but the current pipeline does
not apply them — a run always covers the store's whole pending corpus with the
default model.

Synthesis runs on Gemma-4-e4b (the OptiQ 4-bit release) loaded from the
Hugging Face hub cache; if it is not downloaded the command stops with the
exact `hf download` line to run. If a trained `memory-chunk` adapter is present
at `~/.cache/mlx-bun/adapters/memory-chunk` the segment stage mounts it; every
other stage runs the base model with its policy prompt. Set
`MLX_BUN_MEMORY_BATCH=<n>` to batch model calls (default 1).

Synthesis operates on conversations already loaded into the synthesis store.
The pipeline's ingest step reports "corpus already in the store" — it does not
scan your pi sessions on its own today, so a fresh store yields an empty run.

### Run one stage

The DAG is decomposed into independent, resumable workers. Each pulls its
eligible work from the store by state, walks oldest-conversation-first,
persists, and exits — so you can run them separately, or as separate concurrent
processes on different conversation slices (GPU and memory allowing):

```bash
mlx-bun memory segment          [--limit N] [--convs a,b]   # conversations → topic chunks
mlx-bun memory extract          [--limit N] [--convs a,b]   # chunks → entities
mlx-bun memory route                       [--convs a,b]   # entities → create / capture decisions
mlx-bun memory synthesize-stage [--limit N] [--convs a,b]   # create + patch articles (alias: stage-synthesize)
mlx-bun memory link             [--limit N]                 # deterministic cross-linking, no model
```

`--limit` bounds the batch (segment, extract, synthesize-stage, link);
`--convs` restricts a run to specific conversation ids. `link` inline-links
first mentions of other articles and rebuilds each `## See also` from mentions
and co-occurrence; it is idempotent and needs no model.

### Schedule the Dreaming

```bash
mlx-bun memory schedule [--at HH:MM]   # install the nightly job (default 03:00)
mlx-bun memory unschedule              # remove it
```

`schedule` writes a launchd agent (`~/Library/LaunchAgents/com.mlx-bun.memory.plist`,
label `com.mlx-bun.memory`) that runs `mlx-bun memory synthesize` at the
given local time and loads it. launchd survives reboots and runs a job missed
while the machine was asleep on next wake. `status` shows whether the job is
installed and loaded; if `launchctl load` fails the plist is still written and
the command tells you to load it by hand.

## The Dreaming — what nightly synthesis does

From your side, the Dreaming is a nightly editor that reads what you talked
about and keeps a wiki current. Each run:

1. **Segments** each new conversation into single-topic chunks (pointer ranges
   into the transcript, not copies).
2. **Extracts** the subjects each chunk is about — people, projects, tools,
   decisions — and resolves aliases so "the Lumix" and "Lumix S5" are one thing.
3. **Routes** every subject: enough substance gets its own article; thin
   subjects are captured so they stay searchable until they warrant one. There
   is no notability filter — if you talk about it, it surfaces.
4. **Creates or patches** articles: new subjects get an outline, per-section
   drafts, and an infobox; existing articles get one section folded in at a
   time, the rest left byte-identical. Corrections arrive as ordinary chunks,
   and chronological processing means your latest position wins.
5. **Cross-links** the vault (first mentions → `[[wikilinks]]`, co-occurrence →
   See also) and commits.
6. **Wikifies** — an editorial sweep over every article: tighten each section
   without losing any citation or specific detail, refresh the infobox.

Deterministic gates sit between every model step: citation survival, footnote
integrity, word floors, wikilink resolution, article-structure checks. A weak
model output is rejected and the article is left untouched — a bad night is a
no-op, never a corrupted vault. Every article carries `conv:` citations back to
the conversation that supported it.

Everything runs locally on the same base model you chat with; no embeddings,
no cloud. Architecture, stage contracts, and the gate definitions are in
[dreaming-nightly-pipeline.md](../design/dreaming-nightly-pipeline.md).

## Agent tools (pi and web chat)

When a vault exists, `mlx-bun pi` and the web chat register these read-only
tools plus a `memory` skill that teaches the workflow: **FIND** the article,
**READ** it small, follow the graph, use reference docs for mlx-bun questions,
and search only as a last resort. The system prompt gets one soft hint that
memory is on; memory is for user-specific continuity, not a first step for
weather, public facts, or ordinary coding tasks.

**FIND** (deterministic lookup, never a vector search):
- `memory_resolve` — name or alias → the article (stem, title, kind, lead); offers near candidates on a miss.
- `memory_category` — one of category / type / series → member articles.

**READ** (TOC → one section, not a whole-article dump):
- `memory_read` — TOC + lead by default; `force=true` for the full article (large articles still degrade to TOC + lead).
- `memory_section` — one section by heading anchor; the default read granularity.

**Follow the graph**:
- `memory_links` — outbound `[[links]]` grouped by origin (infobox / series / see also / prose) plus inbound backlinks.
- `memory_infobox` — an article's infobox as key:value facts to read. There is no infobox *query* tool; to find articles use `memory_resolve` or `memory_category`.

**Reference docs** (mlx-bun's own docs, mirrored read-only under `Reference/`):
- `reference_search`, `reference_read`, `reference_list`.

**Utility**:
- `memory_list` — your article stems (an overview/fallback, not a first move).
- `memory_status` — vault path, setup state, article count, git state, schedule state.

**Last resort**:
- `memory_search` — substring search across articles; use only after the deterministic finders failed.

All of these are read-only and auto-allowed; none can modify an article. If
the vault is missing, the tools are not registered at all, and the skill and
prompt hint are omitted.

## Web chat: Memory panel and REST routes

The web chat's Memory panel talks to a loopback-only HTTP surface that wraps
the same vault helpers: `GET /api/memory/status`, `/list`, `/search`,
`/article`, `/links`, `/history`, `/diff`, and `POST /api/memory/init` (the
first-run consent card; the same `setupVault` the CLI uses, minus the
interactive import and schedule prompts). A `GET /v1/memory/synthesize`
route streams a synthesis run as server-sent events (`?dry=1` for a dry run).
Wire details — parameters, response shapes, the no-vault response — are owned
by [server-api.md](server-api.md#get-apimemory--post-apimemoryinit). These
routes never touch the agent-tool surface above.

## Consent and safety

- Creating the vault is explicit (`memory init` or the web consent card);
  scheduling is explicit (`memory schedule` or the `init` prompt).
- Chat-time tools are read-only. Article mutation by the agent during chat is
  out of bounds by construction.
- Opening Obsidian or Finder is you browsing and editing your own files; it is
  not agent mutation.
- Imports copy articles in; the source wiki is never modified.
- Nothing — articles, conversations, synthesis — leaves the machine.

## Related

- [cli.md](cli.md#memory--the-personal-wiki) — the `memory` command in the full CLI reference.
- [server-api.md](server-api.md#get-apimemory--post-apimemoryinit) — `/api/memory/*` wire format.
- [dreaming-nightly-pipeline.md](../design/dreaming-nightly-pipeline.md) — the canonical pipeline design.
- [docs/design/dreaming-nightly-pipeline.md](../design/dreaming-nightly-pipeline.md), [docs/design/dreaming-nightly-pipeline.md](../design/dreaming-nightly-pipeline.md) — synthesis internals and the local inference path.
