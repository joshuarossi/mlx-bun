# Memory

mlx-bun memory is a local Markdown wiki that the built-in pi agents can read as durable user context.

Core rule:

> Chat agents read memory articles. `mlx-bun memory synthesize` is the only writer.

The current release includes the vault, read path, Obsidian open flow, and scheduler. Synthesis is scaffolded but still a no-op M1 stub. The planned synthesis engine uses the same local models you chat with, switched into an editorial pipeline with stage-specific LoRA adapters.

## Storage

- Vault: `~/.mlx-bun/wiki/`
- User articles: `~/.mlx-bun/wiki/articles/*.md`
- Read-only reference docs: `~/.mlx-bun/wiki/Reference/*.md`
- Meta pages: `~/.mlx-bun/wiki/Meta/*.md`
- Talk pages: `~/.mlx-bun/wiki/Talk/`
- Override: `MLX_BUN_WIKI=/path/to/wiki`
- Derived synthesis DB: `~/.cache/mlx-bun/memory.sqlite`

The vault is plain Markdown, git-tracked, and opens directly in Obsidian. `Reference/` contains read-only symlinks to mlx-bun's own docs so memory has useful built-in residents on day one; synthesis must never write them.

## CLI

```bash
mlx-bun memory init              # create the wiki; optional import + schedule
mlx-bun memory status            # path, article count, git, schedule, recent articles
mlx-bun memory open              # open wiki in Obsidian/Finder
mlx-bun memory open <article>    # open a specific article
mlx-bun memory list              # list article stems + Reference/* docs
mlx-bun memory search <query>    # search articles
mlx-bun memory toc <article>     # headings + anchors
mlx-bun memory section <article> <anchor>
mlx-bun memory links <article>   # outbound/inbound wikilinks
mlx-bun memory read <article>    # print article body
mlx-bun memory synthesize --dry-run
mlx-bun memory schedule --at 03:00
mlx-bun memory unschedule
```

`memory synthesize` is currently safe and side-effect-free: it reports that M1 stage bodies are not implemented and writes nothing. In the full flow, `memory init` will be able to offer the HF-hosted memory adapter pack download so synthesis can run locally.

## Agent tools

Both `mlx-bun pi` and the web chat expose these read-only tools:

- `memory_search`
- `memory_read`
- `memory_toc`
- `memory_section`
- `memory_links`
- `memory_list` — user articles plus read-only `Reference/*` docs
- `memory_status` — vault path, setup state, article count, git state, last-synthesis placeholder, schedule state, recent changed articles

The tools are always registered. If no vault exists, they return a setup message instead of disappearing. Search/read results prefixed with `Reference/` are mlx-bun docs, not user memory articles.

## Obsidian

```bash
mlx-bun memory open
mlx-bun memory open Archie_Project
```

The first command opens the vault. The second opens one article. Obsidian is preferred; Finder/default Markdown app is the fallback.

## Synthesis roadmap

M1/M2 will turn saved pi sessions into articles using the local model plus four specialized LoRA adapters trained by Josh from existing Lucien-scale pipeline data and distributed from Hugging Face:

1. deterministic ingest of saved web/terminal pi session JSONL;
2. **memory-chunk LoRA** — conversation → topic chunks (already trained as a WIP artifact);
3. **memory-bucket LoRA** — chunk → existing bucket or new article proposal;
4. **memory-synthesis LoRA** — chunks + existing article → conservative article update candidate;
5. **memory-editor LoRA** — candidate article → polished wiki Markdown;
6. deterministic footnote/wikilink normalization, quality gates, and git commit.

The adapters propose; the pipeline validates and writes. The pipeline writes only `articles/`; `Reference/` is immutable context. Until synthesis lands, memory works with imported/hand-written user articles plus the built-in read-only mlx-bun reference docs.
