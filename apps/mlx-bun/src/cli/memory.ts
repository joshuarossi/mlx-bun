// `mlx-bun memory` — main's memory verb: walk through setup, inspect the wiki
// from the terminal, run synthesis, and manage the nightly launchd job. Read
// subcommands touch only the vault; the stage workers and the full DAG reach the
// model through the loopback client onto a serving mlx-bun (`--host`/`--port`,
// the serve defaults), never in-process. `mlx-bun setup` is main's true alias
// (`mlx-bun setup init` == `mlx-bun memory init`).
//
// Every persistent action goes through MemoryDependencies: the home directory
// that holds the launchd plist and logs, the `launchctl` runner, the program the
// job runs (the executable identity captured at startup, never process.execPath),
// and the prompt that asks before anything persistent. Tests inject all four.

import { homedir } from "node:os";
import { join } from "node:path";
import { readdir } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import type { CommandArgs } from "./args";
import { help } from "./args";
import { banner, boxLines, renderHelp, step, style } from "./terminal";
import pkg from "../../package.json" with { type: "json" };
import { executablePath } from "../jobs/executable";
import type { MemoryCompletionClient } from "../memory/model";
import type { SynthesisEvent } from "../memory/events";
import { createLoopbackMemoryClient } from "../server/memory-completion-client";
import { formatAt, installSchedule, parseAt, removeSchedule, scheduleStatus } from "../memory/schedule";
import {
  vaultRoot, vaultStatus, setupVault, importArticlesFrom, commitVault,
  listMemoryDocuments, readArticle, resolveArticlePath, searchArticles,
  parseToc, extractSection, getArticleLinks,
} from "../memory/vault";

export interface MemoryDependencies {
  log(line: string): void;
  error(line: string): void;
  /** Run a macOS `open` invocation; resolves with its exit code. */
  open(args: string[]): Promise<number>;
  /** The vault root every subcommand reads or initializes (main: `vaultRoot()`). */
  vault: string;
  /** Home directory holding the launchd plist (Library/LaunchAgents) and its logs (.mlx-bun/logs). */
  home: string;
  /** Run `launchctl <args>`; true on exit 0. Undefined keeps the real launchctl. */
  launchctl?: (args: string[]) => Promise<boolean>;
  /** The command the nightly job runs before `memory synthesize`. */
  program: readonly string[];
  /** Line prompt: resolves the trimmed answer, or `fallback` when it is blank or
   *  the session is non-interactive (main: a non-TTY stdin never hangs and
   *  never confirms a persistent action). */
  ask(question: string, fallback: string): Promise<string>;
}

/** The job's command: the executable captured at startup, plus this CLI's entry
 *  when running from source (a compiled binary carries its own entry). */
function synthesisProgram(): string[] {
  const entry = fileURLToPath(new URL("./main.ts", import.meta.url));
  return entry.includes("$bunfs") ? [executablePath] : [executablePath, entry];
}

function defaultDependencies(): MemoryDependencies {
  return {
    log: (line) => console.log(line),
    error: (line) => console.error(line),
    async open(args) { return await Bun.spawn(["open", ...args], { stdout: "ignore", stderr: "ignore" }).exited; },
    vault: vaultRoot(),
    home: homedir(),
    program: synthesisProgram(),
    async ask(question, fallback) {
      if (!process.stdin.isTTY) return fallback;
      const { createInterface } = await import("node:readline/promises");
      const rl = createInterface({ input: process.stdin, output: process.stdout });
      try {
        return (await rl.question(question)).trim() || fallback;
      } finally {
        rl.close();
      }
    },
  };
}

/** Main read `--port` as a bare value; a bad one is a usage error here. */
function serverUrl(args: CommandArgs): string {
  const host = typeof args.values.host === "string" && args.values.host ? args.values.host : "127.0.0.1";
  const raw = typeof args.values.port === "string" ? args.values.port : "8080";
  const port = Number(raw);
  if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error(`--port must be an integer in 1..65535, got ${raw}`);
  return `http://${host.includes(":") && !host.startsWith("[") ? `[${host}]` : host}:${port}`;
}

export async function runMemory(args: CommandArgs, supplied: Partial<MemoryDependencies> = {}): Promise<void> {
  const deps = { ...defaultDependencies(), ...supplied };
  const opt = (name: string): string | null => (typeof args.values[name] === "string" ? (args.values[name] as string) : null);
  const flag = (name: string): boolean => args.values[name] === true;
  const root = deps.vault;

  const openMemoryTarget = async (targetPath = root): Promise<"obsidian" | "fallback"> => {
    // For articles, Obsidian's URL handler opens the exact file inside the
    // vault. For the vault root, `open -a Obsidian <folder>` opens the folder
    // as a vault. Both fall back to macOS `open` if Obsidian is unavailable.
    if (targetPath !== root) {
      if ((await deps.open([`obsidian://open?path=${encodeURIComponent(targetPath)}`])) === 0) return "obsidian";
    } else if ((await deps.open(["-a", "Obsidian", root])) === 0) return "obsidian";
    await deps.open([targetPath]);
    return "fallback";
  };

  // Words after `memory`: [subcommand, ...query].
  const words = args.positionals;
  const sub = (words[0] ?? "status").toLowerCase();
  const rest = words.slice(1).join(" ").trim();
  const noVault = () => {
    deps.log(`no memory wiki yet at ${style.dim(root)}`);
    deps.log(`set one up:  ${style.accent("mlx-bun memory init")}`);
  };
  const onEvent = (e: SynthesisEvent) => deps.log(e.type === "stage" ? `  ${style.dim("·")} ${e.message}` : `  ${e.message}`);
  /** The model-driven subcommands run their calls through the serving mlx-bun. */
  const withServer = async <T>(work: (client: MemoryCompletionClient) => Promise<T>): Promise<T> => {
    const url = serverUrl(args);
    return work(createLoopbackMemoryClient(() => url));
  };
  const box = (lines: string[]) => { for (const line of boxLines(lines)) deps.log(line); };
  const launchd = { home: deps.home, launchctl: deps.launchctl };
  const confirmYN = async (q: string, defaultYes: boolean): Promise<boolean> => {
    const a = (await deps.ask(`${q} ${defaultYes ? "[Y/n]" : "[y/N]"} `, "")).toLowerCase();
    if (!a) return defaultYes;
    return a === "y" || a === "yes";
  };

  if (sub === "init" || sub === "setup") {
    banner(pkg.version);
    box([
      `${style.accent("●")} ${style.bold("Personal memory for your local AI")}`,
      "",
      "A wiki of Markdown articles your local assistant reads to remember",
      "your projects, people, and history across sessions. It's yours —",
      `git-tracked at ${style.dim(root)}, editable in any tool, and it`,
      "never leaves this machine.",
    ]);
    const sSetup = step("creating your wiki");
    const res = await setupVault(root);
    sSetup.done(res.alreadySetUp ? `already set up ${style.dim(`· ${root}`)}` : `wiki ready ${style.dim(`· ${root}`)}`);

    // Offer to seed from an existing vault (e.g. a lucien ~/Dreaming) so the
    // assistant has real content to read on day one, before synthesis exists.
    const seedRoot = await deps.ask(
      `\n  Seed from an existing wiki? Enter its path, or blank to skip ${style.dim(`[${join(deps.home, "Dreaming")}]`)}: `,
      "",
    );
    if (seedRoot) {
      const srcArticles = join(seedRoot.replace(/^~(?=$|[/\\])/, deps.home), "articles");
      let count = 0;
      try { count = (await readdir(srcArticles)).filter((n) => n.endsWith(".md")).length; } catch { count = 0; }
      if (count === 0) {
        deps.log(style.dim(`  no articles found under ${srcArticles} — skipping import`));
      } else if (await confirmYN(`  Import ${count} article(s) from ${srcArticles}?`, true)) {
        const sImp = step(`importing ${count} article(s)`);
        const imported = await importArticlesFrom(srcArticles, root);
        await commitVault(root, `Import ${imported.length} article(s) from ${seedRoot}`);
        sImp.done(`imported ${imported.length} article(s)`);
      }
    }

    // Offer to install the nightly synthesis job (a launchd agent). The job
    // runs the real synthesis DAG (`mlx-bun memory synthesize`) — create new
    // entity articles, then the editorial wikify sweep — so installing the
    // schedule keeps your wiki current automatically. Persistent action →
    // TTY-only, defaults to no. Synthesis reaches the model through a serving
    // mlx-bun, so the job needs `mlx-bun serve` running at its time.
    let scheduled: string | null = null;
    deps.log(style.dim(
      "\n  Synthesis (turning your conversations into articles) runs as a nightly job;\n" +
      "  install it now so your wiki stays current automatically.\n" +
      "  The job needs a serving mlx-bun (mlx-bun serve) running at that time.",
    ));
    if (await confirmYN("  Install the nightly synthesis job (runs in the background)?", false)) {
      const atRaw = await deps.ask(`    At what time? 24h HH:MM ${style.dim("[03:00]")}: `, "03:00");
      const sSched = step(`installing nightly job at ${formatAt(parseAt(atRaw))}`);
      const r = await installSchedule({ at: atRaw, program: deps.program }, launchd);
      scheduled = formatAt(r.at);
      sSched.done(
        r.loaded
          ? `nightly job installed ${style.dim(`· ${scheduled} · ${r.plistPath}`)}`
          : `plist written ${style.dim(`· ${r.plistPath} · launchctl load failed (load it manually)`)}`,
      );
    }

    const st = await vaultStatus(root);
    deps.log("");
    box([
      `${style.green("●")} ${style.bold("memory is set up")} ${style.dim(`· ${st.articleCount} article(s) · ${st.referenceCount} reference doc(s)`)}`,
      "",
      `chat now   ${style.accent("mlx-bun serve")} ${style.dim("— the assistant now reads your memory automatically")}`,
      `inspect    ${style.accent("mlx-bun memory status")} ${style.dim("·")} ${style.accent("mlx-bun memory search <q>")}`,
      `browse     ${style.dim(`open ${root} in Obsidian, or any editor`)}`,
      scheduled
        ? `nightly    ${style.green("scheduled")} ${style.dim(`· ${scheduled} daily · mlx-bun memory unschedule to undo`)}`
        : `nightly    ${style.dim("not scheduled · mlx-bun memory schedule to set it up")}`,
      "",
      style.dim("Synthesis (conversations → articles) runs the full DAG: create new entity"),
      style.dim("articles, then an editorial wikify sweep. Run it now: mlx-bun memory synthesize."),
    ]);
    return;
  }

  if (sub === "status") {
    const st = await vaultStatus(root);
    if (!st.exists) return noVault();
    const sched = await scheduleStatus(launchd);
    deps.log("");
    box([
      `${style.bold("memory")} ${style.dim(`· ${root}`)}`,
      "",
      `articles   ${style.bold(String(st.articleCount))}`,
      `reference  ${style.bold(String(st.referenceCount))} ${style.dim("read-only docs")}`,
      `git        ${st.isGitRepo ? style.green("tracked") : style.dim("not a git repo")}`,
      `synthesis  ${style.green("available")} ${style.dim("· mlx-bun memory synthesize")}`,
      `nightly    ${
        sched.installed
          ? `${sched.loaded ? style.green("scheduled") : style.accent("installed (not loaded)")} ${style.dim(`· ${sched.at ? `${formatAt(sched.at)} daily · ` : ""}${sched.plistPath}`)}`
          : style.dim("not scheduled · mlx-bun memory schedule")
      }`,
      ...(sched.installed ? [`           ${style.dim(sched.note)}`] : []),
      st.recentArticles.length
        ? `recent    ${st.recentArticles.slice(0, 5).map((r) => r.article).join(", ")}`
        : `recent    ${style.dim("none")}`,
    ]);
    return;
  }

  if (sub === "open" || sub === "browse") {
    const st = await vaultStatus(root);
    if (!st.exists) return noVault();
    let targetPath = root;
    let label = "memory";
    if (rest) {
      try {
        targetPath = await resolveArticlePath(root, rest);
        label = rest.endsWith(".md") ? rest.slice(0, -3) : rest;
      } catch (err) {
        throw new Error(`${err instanceof Error ? err.message : String(err)}\ntry:  ${style.accent(`mlx-bun memory search ${rest}`)}`);
      }
    }
    const where = await openMemoryTarget(targetPath);
    deps.log(where === "obsidian" ? `opened ${label} in Obsidian: ${targetPath}` : `opened ${label}: ${targetPath}`);
    return;
  }

  // Independent, chronological, resumable STAGE WORKERS. Each pulls its own
  // eligible work from the DB by state, processes a bounded batch, persists,
  // and exits — so a user can run the four as four separate processes on
  // different slices concurrently (GPU/memory allowing). `synthesize` (below)
  // remains the FULL DAG; these are its decomposed pieces.
  if (sub === "segment" || sub === "extract" || sub === "route" || sub === "synthesize-stage" || sub === "stage-synthesize") {
    const stages = await import("../memory/stages");
    const { MemoryStore } = await import("../memory/db");
    const limit = opt("limit") ? parseInt(opt("limit")!, 10) : undefined;
    const convsRaw = opt("convs");
    const convIds = convsRaw ? convsRaw.split(",").map((s) => s.trim()).filter(Boolean) : undefined;
    const store = new MemoryStore();
    deps.log("");
    try {
      await withServer(async (client) => {
        if (sub === "segment") {
          const r = await stages.runSegmentStage(store, { root, client, convIds, limit, onEvent });
          deps.log(style.dim(`\n  segment: ${r.valid} segmented, ${r.chunks} chunks, ${r.skipped} skipped, ${r.errored} errored`));
        } else if (sub === "extract") {
          const r = await stages.runExtractStage(store, { root, client, convIds, limit, onEvent });
          deps.log(style.dim(`\n  extract: ${r.extracted} chunk(s) extracted, ${r.remaining} still pending`));
        } else if (sub === "route") {
          const r = await stages.runRouteStage(store, { client, convIds, onEvent });
          deps.log(style.dim(`\n  route: ${r.decisions.length} entities — ${r.createEligible} create-eligible, ${r.captured.length} captured`));
        } else {
          const r = await stages.runSynthesizeStage(store, { root, client, convIds, limit, onEvent });
          deps.log(style.dim(`\n  synthesize: ${r.created.length} created, ${r.patched.length} patched, ${r.skippedByGate.length} gated`));
        }
      });
    } finally {
      store.close();
    }
    return;
  }

  // CROSS-LINK — the dedicated edge-building stage. Deterministic + idempotent:
  // inline-link first mentions of other articles + rebuild each ## See also from
  // mentions + co-occurrence. No model required.
  if (sub === "link") {
    const { runLinkStage } = await import("../memory/crosslink");
    const { MemoryStore } = await import("../memory/db");
    const limit = opt("limit") ? parseInt(opt("limit")!, 10) : undefined;
    const store = new MemoryStore();
    deps.log("");
    try {
      const r = await runLinkStage(store, { root, limit, onEvent });
      deps.log(style.dim(`\n  link: ${r.linked.length} article(s) linked · ${r.mentionEdges} mention edge(s) · ${r.skippedByGate.length} gated`));
    } finally {
      store.close();
    }
    return;
  }

  if (sub === "synthesize" || sub === "pipeline" || sub === "all") {
    const { runSynthesis } = await import("../memory/pipeline");
    const dryRun = flag("dry-run");
    deps.log("");
    const summary = await withServer((client) => runSynthesis(
      { since: opt("since") ?? undefined, model: opt("model") ?? undefined, dryRun, root, client },
      onEvent,
    ));
    deps.log(style.dim(`\n  ${summary.note}`));
    return;
  }

  if (sub === "schedule") {
    const atRaw = opt("at") ?? "03:00";
    const r = await installSchedule({ at: atRaw, program: deps.program }, launchd);
    deps.log("");
    box([
      r.loaded
        ? `${style.green("●")} ${style.bold("nightly synthesis scheduled")} ${style.dim(`· ${formatAt(r.at)} daily`)}`
        : `${style.accent("●")} ${style.bold("plist written, but launchctl load failed")}`,
      "",
      `plist      ${style.dim(r.plistPath)}`,
      `runs       ${style.dim("mlx-bun memory synthesize (full DAG: create + wikify sweep)")}`,
      `needs      ${style.dim("a serving mlx-bun (mlx-bun serve) at that time")}`,
      `undo       ${style.accent("mlx-bun memory unschedule")}`,
    ]);
    return;
  }

  if (sub === "unschedule") {
    const removed = await removeSchedule(launchd);
    deps.log(removed ? "nightly synthesis job removed" : "no nightly job was installed");
    return;
  }

  if (sub === "list") {
    const docs = await listMemoryDocuments(root);
    if (docs.length === 0) return deps.log("no articles or reference docs yet");
    for (const s of docs) deps.log(`  ${s}`);
    const refs = docs.filter((s) => s.startsWith("Reference/")).length;
    deps.log(style.dim(`\n  ${docs.length - refs} article(s), ${refs} read-only reference doc(s)`));
    return;
  }

  if (sub === "search") {
    if (!rest) throw new Error("usage: mlx-bun memory search <query>");
    const { summaries, hits } = await searchArticles(root, rest, { limit: 12 });
    if (summaries.length === 0) return deps.log(`no articles match "${rest}"`);
    deps.log("");
    for (const s of summaries.slice(0, 15)) {
      const terms = s.matched_terms?.length ? style.dim(` [${s.matched_terms.join(", ")}]`) : "";
      deps.log(`  ${style.bold(s.article)} ${style.dim(`· ${s.occurrences} hit(s)`)}${terms}`);
    }
    if (hits.length) {
      deps.log(style.dim("\n  sample lines:"));
      for (const h of hits.slice(0, 6)) {
        const where = h.anchor ? `${h.article}#${h.anchor}` : h.article;
        deps.log(`  ${style.dim(`${where}:${h.line}`)}  ${h.excerpt}`);
      }
    }
    deps.log(style.dim(`\n  read one:  mlx-bun memory read ${summaries[0]!.article}`));
    return;
  }

  const notFound = (err: unknown, query: string): never => {
    throw new Error(`${err instanceof Error ? err.message : String(err)}\ntry:  ${style.accent(`mlx-bun memory search ${query}`)}`);
  };

  if (sub === "toc") {
    if (!rest) throw new Error("usage: mlx-bun memory toc <article>");
    let content: string;
    try { ({ content } = await readArticle(root, rest)); } catch (err) { return notFound(err, rest); }
    const toc = parseToc(content);
    if (toc.length === 0) return deps.log("no headings");
    for (const h of toc) deps.log(`${"  ".repeat(Math.max(0, h.depth - 1))}- ${h.title}  ${style.dim(`#${h.anchor}`)}`);
    return;
  }

  if (sub === "section") {
    const [article, anchorRaw] = words.slice(1);
    const anchor = anchorRaw?.replace(/^#/, "");
    if (!article || !anchor) throw new Error("usage: mlx-bun memory section <article> <anchor>");
    let content: string;
    try { ({ content } = await readArticle(root, article)); } catch (err) { return notFound(err, article); }
    const section = extractSection(content, anchor);
    if (!section) throw new Error(`no section #${anchor} in ${article}\ntry:  ${style.accent(`mlx-bun memory toc ${article}`)}`);
    deps.log(section);
    return;
  }

  if (sub === "links") {
    if (!rest) throw new Error("usage: mlx-bun memory links <article>");
    let links: Awaited<ReturnType<typeof getArticleLinks>>;
    try { links = await getArticleLinks(root, rest); } catch (err) { return notFound(err, rest); }
    deps.log(`${style.bold("outbound")}:`);
    deps.log(links.outbound.length ? links.outbound.map((s) => `  ${s}`).join("\n") : "  (none)");
    deps.log(`\n${style.bold("inbound")}:`);
    deps.log(links.inbound.length ? links.inbound.map((s) => `  ${s}`).join("\n") : "  (none)");
    return;
  }

  if (sub === "read") {
    if (!rest) throw new Error("usage: mlx-bun memory read <article>");
    let content: string;
    try { ({ content } = await readArticle(root, rest)); } catch (err) { return notFound(err, rest); }
    deps.log(content);
    return;
  }

  // Unknown subcommand: help on stdout, but a FAILURE exit — scripts and
  // launchd jobs must be able to detect typos.
  deps.error(`unknown: mlx-bun memory ${sub}`);
  deps.log(renderHelp(help("memory")));
  process.exitCode = 1;
}
