# Memory system

Status: **M0/M0.5 landed (2026-06-19)**. The vault, read tools, CLI, Obsidian open flow, and launchd scheduling are implemented. The actual synthesis stage bodies are still **M1 TODO**; `mlx-bun memory synthesize` is currently a safe no-op stub. The planned M1/M2 synthesis engine uses the same local models the user chats with, plus stage-specific LoRA adapters trained by Josh from the existing Lucien-scale memory corpus and distributed from Hugging Face.

## Contract

The memory contract is ported from `../lucien`:

> **Chat-time agents read memory. The synthesis pipeline writes memory.**

Memory articles are durable priors. Conversations are evidence. Synthesis is the deliberate, auditable process that turns evidence into updated articles. Normal chat must not mutate articles.

This gives both terminal and web the full pi agent experience without turning memory into an unsafe scratchpad:

- Terminal and web expose the same read-only memory tools through one shared pi surface factory.
- Memory tools/skill are exposed only when the user has enabled the vault.
- When enabled, memory is scoped to user-specific continuity: explicit recall, named personal projects/people/preferences/decisions/history, or missing personal context.
- Memory is **not** the default first step for weather, current public facts, generic web research, or ordinary coding/file tasks where the current files are sufficient.
- Mutating/coding tools remain full-power and approval-gated by pi/web as usual.
- Memory article writes happen only through `mlx-bun memory synthesize` once M1 lands.
- Users can always browse/edit their own Markdown vault directly, especially via Obsidian.

## User-facing model

- User-facing capability: **memory**.
- Store on disk: `~/.mlx-bun/wiki/` (override: `MLX_BUN_WIKI`).
- User articles: `~/.mlx-bun/wiki/articles/*.md`.
- Read-only reference residents: `~/.mlx-bun/wiki/Reference/*.md` symlinked to mlx-bun's own docs.
- Operational pages: `~/.mlx-bun/wiki/Meta/*.md`.
- Talk pages: `~/.mlx-bun/wiki/Talk/`.
- Synthesis DB: `~/.cache/mlx-bun/memory.sqlite`.

The vault is plain Markdown and git-tracked. It is intentionally usable as an Obsidian vault. `Reference/` is a separate read-only namespace: chat tools may search/read it, but synthesis must skip it and never write through those symlinks. The SQLite DB is derived state and lives in the rebuildable cache, not in the user-owned Markdown vault.

Stage-specific memory LoRAs are product assets, not user-authored vault content. The creator trains them from the existing memory-pipeline data, publishes them to Hugging Face, and `memory init` can offer to download/cache them for local synthesis.

## What is implemented now

### Vault and article helpers

`src/memory/vault.ts` implements:

- `vaultRoot()` → `~/.mlx-bun/wiki` or `MLX_BUN_WIKI`.
- `setupVault()` — idempotent directory/Meta/README/git setup plus `Reference/` symlinks.
- `listArticles()` / `listReferenceDocs()` / `listMemoryDocuments()`.
- `readArticle()` / `searchArticles()` over both user articles and read-only references.
- `parseToc()` / `extractSection()`.
- `getArticleLinks()` with resolved inbound/outbound wikilinks.
- `importArticlesFrom()` for seeding from an existing vault such as `~/Dreaming`.
- `vaultStatus()` with article/reference counts and recent user article mtimes.

The read/search/link logic is ported from Lucien's pure filesystem helpers, not from MCP.

### CLI

`mlx-bun memory` supports:

```bash
mlx-bun memory init              # create vault, optionally import + schedule
mlx-bun memory setup             # alias for init
mlx-bun memory status            # path, article count, git, schedule, recent articles
mlx-bun memory open              # open the vault in Obsidian, fallback Finder
mlx-bun memory open <article>    # open one article in Obsidian/default Markdown app
mlx-bun memory list              # list article stems + Reference/* docs
mlx-bun memory search <query>    # search articles
mlx-bun memory toc <article>     # headings + anchors
mlx-bun memory section <article> <anchor>
mlx-bun memory links <article>   # inbound/outbound wikilinks
mlx-bun memory read <article>    # print full article
mlx-bun memory synthesize [--dry-run] [--model <q>] [--since <cursor>]
mlx-bun memory schedule [--at HH:MM]
mlx-bun memory unschedule
```

`memory synthesize` currently reports the M1 stub and writes nothing. Scheduling is real; the scheduled job is harmless until synthesis lands. In the full flow, `memory init` should also offer to download the memory pipeline adapter pack from Hugging Face so synthesis is ready to run locally.

### pi/web tools

`src/memory/tools.ts` defines native pi custom tools:

- `memory_search`
- `memory_read`
- `memory_toc`
- `memory_section`
- `memory_links`
- `memory_list` (user articles plus read-only `Reference/*` docs)
- `memory_status` (vault path, setup state, article count, git state, last-synthesis placeholder, schedule state, recent changed articles)

These tools are registered by the shared pi surface in `src/pi-session.ts` and consumed by both front doors:

- `src/pi-terminal.ts`
- `src/pi-web.ts`

If the vault does not exist, memory tools and the memory skill are not exposed at all, avoiding prompt fixation on unavailable memory. If the vault exists, `memoryIndexHint()` adds a short scoped presence hint. Detailed usage lives in the memory skill rather than dumping article titles into the prompt.

Read-only mlx-bun docs are now a separate lookup surface (`reference_search`, `reference_read`, `reference_list`) rather than being mixed into personal-memory search. Personal memory answers “what does the user think / what did we decide”; reference tools answer “what do mlx-bun docs say.”

### Bundled memory skill

`src/web/skills/memory/SKILL.md` is bundled through `src/web/skills.ts` and materialized under `~/.mlx-bun/skills` for pi to load.

The skill tells the agent to:

- consult memory quietly for personal context;
- use `memory_search` then `memory_read`, or `memory_toc` + `memory_section` for focused reads;
- use `memory_links` for nearby concepts/backlinks;
- use `memory_status` for setup/location/schedule questions;
- never announce retrieval as the user's experience;
- never edit memory articles during chat;
- open the vault/article for the user if asked via `mlx-bun memory open [article]`.

### Session capture substrate

The synthesis pipeline will ingest mlx-bun's own pi sessions only:

- web sessions: `~/.mlx-bun/sessions/...` / `~/.mlx-bun/pi-sessions/...` depending on the web `SessionManager` path;
- terminal sessions: `~/.mlx-bun/pi/sessions/...`.

No Playwright, scraping, cloud transcript import, or Lucien runtime dependency is planned for mlx-bun memory.

### Scheduling

`src/memory/schedule.ts` installs a launchd agent:

- label: `com.mlx-bun.memory`
- plist: `~/Library/LaunchAgents/com.mlx-bun.memory.plist`
- command: `mlx-bun memory synthesize`
- logs: `~/.mlx-bun/logs/memory-synthesis.{out,err}.log`

`mlx-bun memory schedule --at 03:00` installs/loads it. `unschedule` unloads/removes it. `status` and `memory_status` report it.

## Synthesis pipeline design (M1/M2)

The M1/M2 pipeline mirrors Lucien's proven stages while running on the same local model stack the user chats with. The difference is execution context and authority: chat uses the model conversationally and read-only; synthesis runs the model as a constrained editor behind deterministic gates.

```text
ingest      deterministic: pi session JSONL -> memory.sqlite conversations
chunk       base model + memory-chunk LoRA -> topic chunks
cluster     base model + memory-bucket LoRA -> buckets / target articles
synthesize  base model + memory-synthesis LoRA -> candidate article updates
wikify      base model + memory-editor LoRA + deterministic normalization
changelog   deterministic: run summary + git commit
```

The chunking LoRA has already been trained as a WIP artifact. The remaining stage adapters are planned product assets trained by Josh from the existing Lucien/pipeline data and published to Hugging Face. mlx-bun should download/cache them during `memory init` (with user consent) or lazily on first `memory synthesize`.

Important nouns must stay distinct:

- **Conversation** — source transcript/evidence.
- **Chunk** — topical segment from a conversation.
- **Bucket** — staging group that collects related chunks.
- **Article** — durable Markdown memory page.

### Bookkeeping DB

`src/memory/db.ts` defines `MemoryStore` over `~/.cache/mlx-bun/memory.sqlite` with tables for:

- `conversations`
- `chunks`
- `buckets`
- `watermarks`
- `synthesized_bucket_chunks`

The DB is derived and rebuildable from sessions + articles. It should not be committed to the vault.

### Stage-specific adapters

The pipeline deliberately uses **four specialized LoRA adapters** rather than one generic memory adapter:

| Stage | Adapter | Job | Primary quality signal |
| --- | --- | --- | --- |
| Chunk | memory-chunk | Conversation transcript → topic-coherent chunks | Boundary/label accuracy vs gold chunks |
| Bucket | memory-bucket | Chunk → existing bucket or new bucket proposal | Stable routing, low duplicate topics, good article target |
| Synthesize | memory-synthesis | New chunks + existing article → conservative candidate update | Citation preservation, faithful integration, no hallucinated claims |
| Edit/wikify | memory-editor | Candidate article → normalized wiki Markdown | Style, wikilinks, references, deterministic format compliance |

These adapters do **not** get direct write authority. They produce candidates. The pipeline validates, normalizes, and decides whether to write/commit.

Implementation notes:

- Adapters should be cached with the rest of mlx-bun's HF/downloaded artifacts, not stored in the wiki vault.
- `memory init` should describe the adapter pack plainly and ask before downloading multi-MB/GB assets.
- `memory synthesize --dry-run` must work without downloading adapters when it only builds the deterministic manifest.
- If a required adapter is missing for a real synthesis stage, the command should offer the download or fail cleanly; it should not silently fall back to an untrained prompt path unless explicitly requested.
- Future routing should use the existing adapter-scoped generation path: one resident base model, stage LoRA mounted per pipeline call.

### Current stage modules

These files exist as typed stubs and currently throw if called directly:

- `src/memory/ingest.ts`
- `src/memory/chunk.ts`
- `src/memory/cluster.ts`
- `src/memory/synthesize.ts`
- `src/memory/wikify.ts`
- `src/memory/prompts.ts`

`src/memory/pipeline.ts` intentionally does **not** call them yet. It emits a no-op M1-stub plan so manual and scheduled synthesis cannot accidentally corrupt the vault before gates exist.

## Synthesis quality gates to port from Lucien

M1 should preserve these Lucien properties:

- deterministic manifest / dry-run before writes;
- per-bucket/per-article workers so failures are isolated;
- idempotency via `synthesized_bucket_chunks`;
- backfill behavior for existing imported articles;
- orphan detection when ledger and files disagree;
- conservative update prompt: integrate, do not rewrite wholesale;
- minimum word-count/truncation guard, e.g. Lucien's 70% floor;
- citation preservation: every original `conv:` reference survives;
- deterministic footnote repair;
- deterministic wikilink normalization;
- git commit for article changes;
- changelog / run summary.

A weak local-model synthesis pass should no-op, not damage the vault. This remains true even with trained adapters: LoRAs propose; deterministic gates dispose. Synthesis must operate only on `articles/` and must treat `Reference/` as immutable read-only context.

## Consent and safety

- Local session capture is local-only and part of pi/web session persistence.
- Creating the vault is explicit: `mlx-bun memory init`.
- Scheduling is explicit: `mlx-bun memory schedule` or the init wizard prompt.
- Chat-time memory tools are read-only and auto-allowed.
- Opening Obsidian/Finder is user-directed browsing/editing; it is not agent mutation.
- Article mutation by the agent during chat is out of bounds.

## Next implementation steps

1. Implement `memory synthesize --dry-run` manifest generation without model calls.
2. Add memory adapter-pack metadata and `memory init` download prompt (HF-hosted LoRAs; chunk adapter exists as WIP, others follow).
3. Implement ingest from saved pi session JSONL into `MemoryStore`.
4. Wire the chunk stage to the memory-chunk LoRA and evaluate with chunk boundary/label accuracy.
5. Implement bucket assignment with the memory-bucket LoRA and article manifest create/update/backfill/orphan modes.
6. Implement per-article synthesis workers with the memory-synthesis LoRA and conservative gates.
7. Implement editor/wikify adapter pass plus deterministic footnote/wikilink normalization and git commits.
8. Move synthesis execution onto the jobs runner with SSE progress once manual synthesis is reliable.
