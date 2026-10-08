import type { AppModule } from "@mlx-bun/app-core";

const memoryDetails = `A local, durable memory for the assistant: a wiki of Markdown articles
(~/.mlx-bun/wiki) it reads to remember your projects, people, and history
across sessions. It is yours: git-tracked, editable in any tool (Obsidian
opens it as a vault), and it never leaves the machine. Once set up, it loads
automatically into every \`mlx-bun serve\` session.

Subcommands:
  init, setup        Create the wiki + walk through setup (idempotent);
                     offers to import an existing vault and install the
                     nightly synthesis job
  status             Path, article count, git + schedule state (the default)
  open, browse [article]
                     Open the wiki, or a specific article, in Obsidian
                     (falls back to Finder / the default Markdown app)
  list               List article titles + read-only Reference docs
  search <query>     Search articles from the terminal
  toc <article>      Print an article's headings + anchors
  section <article> <anchor>
                     Print one article section
  links <article>    Show resolved outbound + inbound wikilinks
  read <article>     Print an article (stem, e.g. Archie_Project)
  synthesize         Run the FULL synthesis DAG now (--since, --model,
                     --dry-run); also: pipeline, all
  segment | extract | route | synthesize-stage
                     Run ONE decomposed stage worker (--limit N —
                     segment/extract/synthesize-stage only; --convs a,b).
                     Each pulls its eligible work from the DB by state, walks
                     oldest-conversation-first, persists, and exits — resumable,
                     and runnable as separate concurrent processes on slices.
  link               Deterministic cross-linking stage: inline-link first
                     mentions + rebuild ## See also (--limit N; no model)
  schedule           Install the nightly launchd job (--at HH:MM [03:00])
  unschedule         Remove the nightly launchd job

The read path is live: the assistant reads a wiki you set up by hand or
import during \`memory init\`. Run \`mlx-bun memory open\` to browse it in
Obsidian/Finder, or \`mlx-bun memory open <article>\` to jump to a specific
page. Synthesis (conversations -> articles) runs the full local pipeline via
\`mlx-bun memory synthesize\` (or per-stage: segment/extract/route/
synthesize-stage/link); the nightly job runs it on a schedule. These load the
memory task model on first use; --host/--port use a serving mlx-bun instead.`;

export const manifest = {
  id: "memory",
  title: "Memory",
  summary: "A local Markdown vault, read-only chat tools and the existing synthesis and nightly scheduling pipeline.",
  requires: [
    "storage",
    "registry"
  ],
  placement: "app",
  contributes: [
    "chat.tool",
    "chat.guidance"
  ],
  routes: [
    {
      id: "status",
      method: "GET",
      path: "/api/memory/status",
      summary: "Wiki status and nightly schedule",
      response: "json",
      mount: "root"
    },
    {
      id: "list",
      method: "GET",
      path: "/api/memory/list",
      summary: "List articles and reference documents",
      response: "json",
      mount: "root"
    },
    {
      id: "search",
      method: "GET",
      path: "/api/memory/search",
      summary: "Search article and reference content",
      response: "json",
      mount: "root"
    },
    {
      id: "article",
      method: "GET",
      path: "/api/memory/article",
      summary: "Read a document with its article structure",
      response: "json",
      mount: "root"
    },
    {
      id: "links",
      method: "GET",
      path: "/api/memory/links",
      summary: "Read inbound and outbound article links",
      response: "json",
      mount: "root"
    },
    {
      id: "history",
      method: "GET",
      path: "/api/memory/history",
      summary: "Read an article’s Git history",
      response: "json",
      mount: "root"
    },
    {
      id: "diff",
      method: "GET",
      path: "/api/memory/diff",
      summary: "Read an article revision diff",
      response: "json",
      mount: "root"
    },
    {
      id: "init",
      method: "POST",
      path: "/api/memory/init",
      summary: "Initialize the memory wiki",
      response: "json",
      mount: "root"
    },
    {
      id: "synthesize",
      method: "GET",
      path: "/v1/memory/synthesize",
      summary: "Run synthesis and stream progress",
      response: "sse",
      mount: "root"
    }
  ],
  verbs: [
    {
      name: "memory",
      summary: "Your local AI's personal wiki: set it up, inspect it, run synthesis, schedule it",
      positional: [
        {
          name: "subcommand", summary: "Memory action"
        },
        {
          name: "args", summary: "Action arguments",
          repeatable: true
        }
      ],
      helpUsage: "Usage: mlx-bun memory [subcommand] [args] [options]",
      usage: "usage: mlx-bun memory <subcommand> [args] [options]",
      details: memoryDetails,
      options: [
        {
          name: "since",
          type: "string",
          summary: "synthesize: only conversations newer than this (parsed; the pipeline does not consume it yet)"
        },
        {
          name: "model",
          type: "string",
          summary: "synthesize: synthesis model override (parsed; reserved)"
        },
        {
          name: "dry-run",
          type: "boolean",
          summary: "synthesize: plan the stages only, never write the vault"
        },
        {
          name: "limit",
          type: "string",
          summary: "Stage workers: cap the work processed this pass (segment, extract, synthesize-stage, link)"
        },
        {
          name: "convs",
          type: "string",
          summary: "Stage workers: comma-separated conversation ids to restrict the pass to"
        },
        {
          name: "at",
          type: "string",
          summary: "schedule: local wall-clock time for the nightly job, 24h HH:MM [default: 03:00]"
        },
        {
          name: "host",
          type: "string",
          summary: "Run the model calls on a serving mlx-bun at this host instead of loading the memory task model (127.0.0.1 when only --port is given)"
        },
        {
          name: "port",
          type: "string",
          summary: "Port of that server (8080 when only --host is given)"
        }
      ]
    },
    {
      name: "setup",
      summary: "Set up your local AI's memory wiki (alias of mlx-bun memory)",
      positional: [
        {
          name: "subcommand", summary: "Memory action"
        },
        {
          name: "args", summary: "Action arguments",
          repeatable: true
        }
      ],
      helpUsage: "Usage: mlx-bun setup [subcommand] [args] [options]",
      usage: "usage: mlx-bun setup <subcommand> [args] [options]",
      details: memoryDetails,
      options: [
        {
          name: "since",
          type: "string",
          summary: "synthesize: only conversations newer than this (parsed; the pipeline does not consume it yet)"
        },
        {
          name: "model",
          type: "string",
          summary: "synthesize: synthesis model override (parsed; reserved)"
        },
        {
          name: "dry-run",
          type: "boolean",
          summary: "synthesize: plan the stages only, never write the vault"
        },
        {
          name: "limit",
          type: "string",
          summary: "Stage workers: cap the work processed this pass (segment, extract, synthesize-stage, link)"
        },
        {
          name: "convs",
          type: "string",
          summary: "Stage workers: comma-separated conversation ids to restrict the pass to"
        },
        {
          name: "at",
          type: "string",
          summary: "schedule: local wall-clock time for the nightly job, 24h HH:MM [default: 03:00]"
        },
        {
          name: "host",
          type: "string",
          summary: "Run the model calls on a serving mlx-bun at this host instead of loading the memory task model (127.0.0.1 when only --port is given)"
        },
        {
          name: "port",
          type: "string",
          summary: "Port of that server (8080 when only --host is given)"
        }
      ]
    }
  ],
  storage: [
    {
      key: "vault",
      path: "wiki",
      kind: "directory",
      purpose: "Markdown articles and read-only reference links"
    },
    {
      key: "skills",
      path: "skills",
      kind: "directory",
      purpose: "Bundled memory skill for chat"
    },
    {
      key: "db",
      path: "db/memory.sqlite",
      kind: "sqlite",
      purpose: "Ingest and synthesis state"
    }
  ],
  panel: {
    tag: "mlx-memory-panel",
    entry: "@mlx-bun/module-memory/panel",
    title: "Memory",
    path: "/memory",
    developer: false, overlay: true
  }
} as const satisfies Omit<AppModule<"storage" | "registry">, "activate">;
