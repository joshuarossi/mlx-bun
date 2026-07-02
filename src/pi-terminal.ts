// mlx-bun pi-terminal — drive pi's OWN interactive TUI in-process against the
// local mlx-bun server (Phase 16 P3/P4). No subprocess, no requirement that
// the user install pi: pi is a bundled dependency, so we build an
// AgentSessionRuntime with the SDK and hand it to pi's exported InteractiveMode.
//
// This is the terminal twin of src/pi-web.ts (the headless web embed). They
// share the provider wiring (src/pi-provider.ts) and the curated skills
// (src/web/skills.ts); the differences are:
//   - we build an AgentSessionRuntime (InteractiveMode needs the runtime, not
//     the bare session createAgentSession returns), via the same
//     createAgentSessionServices + createAgentSessionFromServices the pi CLI
//     uses (dist/main.js) — see examples/sdk/13-session-runtime.ts;
//   - tool approval is pi's own built-in TUI prompt, so there's no custom
//     approval gate here (the web path needs one only because the browser
//     drives approvals over a WebSocket);
//   - the system prompt is a custom mlx-bun CODING-agent persona (the web
//     path is a general chat assistant);
//   - sessions persist (~/.mlx-bun/pi) so /resume and history work.
//
// Modes mirror pi's CLI: interactive (InteractiveMode), one-shot print
// (`-p` / `--mode json` → runPrintMode), and JSONL RPC (`--mode rpc` →
// runRpcMode). All three are SDK exports, so the embedded CLI keeps pi's
// headless surface.

import { homedir } from "node:os";
import { join } from "node:path";
import {
  InteractiveMode,
  SessionManager,
  createAgentSessionFromServices,
  createAgentSessionRuntime,
  createAgentSessionServices,
  initTheme,
  runPrintMode,
  runRpcMode,
  type CreateAgentSessionRuntimeFactory,
} from "@earendil-works/pi-coding-agent";
import { buildPiAgentSurface } from "./pi-session";
import { buildPiProvider, DEFAULT_CONTEXT_WINDOW } from "./pi-provider";

/** How the embedded agent runs. Mirrors pi's CLI appMode. */
export type PiTerminalMode = "interactive" | "print" | "rpc";

/**
 * Full toolset the terminal agent is offered: pi's built-in coding tools plus
 * our outward-facing web tools. pi treats this list as an allowlist, so a
 * custom tool's name MUST appear here or it's filtered out before the model
 * sees it. Mutating tools (bash/edit/write) surface pi's own TUI approval
 * prompt at call time — we don't add a gate.
 */
/**
 * System prompt for the embedded terminal coding agent.
 *
 * This fully REPLACES pi's default coding-agent prompt (it flows to
 * buildSystemPrompt's `customPrompt` via the resource loader's `systemPrompt`).
 * We replace rather than append so the agent's identity is mlx-bun's, not
 * "operating inside pi, a coding agent harness", and so pi's block of internal
 * documentation paths is dropped. pi still auto-appends the current date and
 * working directory, so we don't repeat them here.
 *
 * Unlike the web chat (a general assistant), this is a true terminal CODING
 * agent: it lives in the user's project directory with real read/run/edit
 * tools. The capability list stays honest about which tools ask for approval
 * so the model never promises an action the user must still confirm.
 */
export function buildTerminalSystemPrompt(modelLabel?: string): string {
  const model = modelLabel ? `the local model \`${modelLabel}\`` : "a local model";
  return `You are mlx-bun's terminal coding agent — a capable, hands-on pair programmer working alongside the user in their terminal. You run on ${model} entirely on the user's own Apple-silicon Mac via mlx-bun, so the whole session stays local and private; nothing leaves the machine except the explicit web tools below.

You operate inside the user's current project directory. Available capabilities when relevant: read-only file inspection (read, ls, find, grep), web search/fetch (web_search, web_fetch), weather, and user-approved local actions (bash, edit, write).

Use tools in service of helping the user, not as a performance. For ordinary social conversation, answer naturally yourself. For real-world facts, current events, schedules, releases, local information, recommendations, restaurants, movies, prices, travel, docs, or anything likely to have changed, look it up with web_search/web_fetch or weather instead of relying on memory or guessing. For coding tasks, inspect the files, investigate before you answer, and follow through to a working result. When you need to change code or run something, propose the concrete edit or command and let the approval prompt handle consent — don't ask permission in prose first.

Environment metadata such as current date, working directory, model name, and available tools may be provided for context; do not report or summarize that metadata unless the user asks for it or it is directly relevant. Do not narrate tool policies or internal workflows.

Be honest about what you did and what you found, including mistakes, dead ends, and anything you couldn't do. Keep responses tight and skimmable: format with Markdown, show file paths and commands plainly, and cite links when you used the web.`;
}

export interface RunEmbeddedPiOptions {
  /** mlx-bun server base URL, e.g. "http://localhost:8080/v1". */
  baseUrl: string;
  /** Real served model id, used to label the model in the prompt + registry. */
  modelLabel?: string;
  /** Context window advertised to pi. Default: DEFAULT_CONTEXT_WINDOW. */
  contextWindow?: number;
  /** Whether the served model has a switchable thinking channel. */
  reasoning?: boolean;
  /** Whether the served model accepts images (server's vision capability —
   *  /v1/models `vision`). MUST match the real model: see PiProviderOptions. */
  vision?: boolean;
  /** Run mode. Default: "interactive". */
  mode?: PiTerminalMode;
  /** Print mode output format ("text" final-only, "json" event stream). */
  printFormat?: "text" | "json";
  /** First message to send (print: the prompt; interactive: pre-filled turn). */
  initialMessage?: string;
  /** Additional messages to send after initialMessage. */
  messages?: string[];
  /** Force pi's verbose startup banner (interactive only). */
  verbose?: boolean;
}

/**
 * Build an AgentSessionRuntime against the local server and run pi in the
 * requested mode. Returns the process exit code. Disposes the runtime on the
 * way out. Runs in the SAME process as the server when the CLI started one —
 * pi's TUI event loop and the generation queue share the JS thread (mlx
 * compute is native); pi's rendering is differential and cheap.
 */
export async function runEmbeddedPi(opts: RunEmbeddedPiOptions): Promise<number> {
  const mode = opts.mode ?? "interactive";
  const cwd = process.cwd();
  // Own session/settings dir, isolated from any standalone pi install.
  const agentDir = join(homedir(), ".mlx-bun", "pi");
  const sessionDir = join(agentDir, "sessions", `--${cwd.replace(/^[/\\]/, "").replace(/[/\\:]/g, "-")}--`);

  const { authStorage, modelRegistry, model } = buildPiProvider(opts.baseUrl, {
    contextWindow: opts.contextWindow ?? DEFAULT_CONTEXT_WINDOW,
    name: opts.modelLabel ? `${opts.modelLabel} (mlx-bun local)` : undefined,
    reasoning: opts.reasoning ?? false,
    vision: opts.vision ?? false,
  });

  // Shared pi tool/skill surface. Memory is included only when the user has
  // enabled a vault; if present it remains scoped to user-specific continuity.
  const surface = await buildPiAgentSurface();
  const systemPrompt = buildTerminalSystemPrompt(opts.modelLabel) + surface.memoryHint;

  // The runtime factory: same shape as pi's own CLI (dist/main.js) and the
  // shipped examples/sdk/13-session-runtime.ts. The same factory is reused by
  // pi for /new, /resume, /fork — so the provider/prompt/tools are stable
  // across session switches within the TUI.
  const createRuntime: CreateAgentSessionRuntimeFactory = async ({ cwd: rcwd, sessionManager, sessionStartEvent }) => {
    const services = await createAgentSessionServices({
      cwd: rcwd,
      agentDir,
      authStorage,
      modelRegistry,
      resourceLoaderOptions: {
        // Isolated from the user's own ~/.pi: don't inherit their extensions,
        // prompt templates, themes, or auto-discovered skills.
        noExtensions: true,
        noSkills: true,
        noPromptTemplates: true,
        noThemes: true,
        // A coding agent in a project dir SHOULD read the project's own
        // AGENTS.md / CLAUDE.md context files (unlike the web chat).
        noContextFiles: false,
        // Our curated skills on top (noSkills above only disables discovery).
        additionalSkillPaths: surface.skillPaths,
        // Replace pi's default coding-agent prompt with our mlx-bun persona.
        systemPrompt,
      },
    });
    return {
      ...(await createAgentSessionFromServices({
        services,
        sessionManager,
        sessionStartEvent,
        model,
        tools: surface.tools,
        customTools: surface.customTools,
      })),
      services,
      diagnostics: services.diagnostics,
    };
  };

  const sessionManager = SessionManager.create(cwd, sessionDir);
  const runtime = await createAgentSessionRuntime(createRuntime, { cwd, agentDir, sessionManager });

  try {
    if (mode === "rpc") {
      // runRpcMode never returns (Promise<never>); it owns stdin/stdout.
      await runRpcMode(runtime);
      return 0;
    }
    if (mode === "print") {
      return await runPrintMode(runtime, {
        mode: opts.printFormat ?? "text",
        messages: opts.messages,
        initialMessage: opts.initialMessage,
      });
    }
    // interactive — initialize the theme (pi's CLI does this before the TUI)
    // then run pi's own full interactive mode.
    initTheme(runtime.services.settingsManager.getTheme(), true);
    await new InteractiveMode(runtime, {
      initialMessage: opts.initialMessage,
      initialMessages: opts.messages,
      verbose: opts.verbose,
    }).run();
    return 0;
  } finally {
    try {
      await runtime.dispose();
    } catch {
      // Best-effort teardown; never mask the real exit path.
    }
  }
}

/** Result of parsing the pi passthrough argv into an embedded run config. */
export interface ParsedPiArgs {
  mode: PiTerminalMode;
  printFormat: "text" | "json";
  /** Joined free-text message (the trailing words / `-p <text>`). */
  message?: string;
  /** pi's verbose startup banner (interactive only). */
  verbose: boolean;
  /** Unknown flags that were dropped (with their values) — callers should
   *  warn so `--resume`-style pi flags don't fail silently. */
  ignored: string[];
}

/**
 * Parse the argv left over after mlx-bun's own flags are stripped into a
 * mode + message for runEmbeddedPi. Pure (takes `isStdinPiped`) so it's
 * unit-testable. Covers the headline pi modes:
 *   - `-p` / `--print`            → print (text), prompt from -p value / words / stdin
 *   - `--mode json` / `-p --json` → print (json)
 *   - `--mode rpc`                → rpc
 *   - piped stdin (non-TTY)       → print (text), like pi's own CLI
 *   - anything else               → interactive (trailing words pre-fill turn 1)
 * The built-in agent is deliberately scoped to these modes. The full pi
 * flag surface (--continue, --resume, @file expansion, extensions, themes)
 * belongs to the user's OWN pi — point it at this server with
 * `mlx-bun harness pi`.
 */
export function parsePiArgs(passthrough: string[], isStdinPiped: boolean): ParsedPiArgs {
  let print = false;
  let rpc = false;
  let json = false;
  let verbose = false;
  const words: string[] = [];
  const ignored: string[] = [];
  for (let i = 0; i < passthrough.length; i++) {
    const a = passthrough[i]!;
    if (a === "-p" || a === "--print") {
      print = true;
    } else if (a === "--json") {
      json = true;
    } else if (a === "--verbose") {
      verbose = true;
    } else if (a === "--mode") {
      const m = passthrough[++i];
      if (m === "rpc") rpc = true;
      else if (m === "json") { print = true; json = true; }
      else if (m === "text") print = true;
    } else if (a.startsWith("-")) {
      // Unknown flag for the built-in agent: drop it AND its value (the full
      // pi flag surface lives in the user's own pi via `mlx-bun harness pi`).
      // Without the value-swallow, `mlx-bun pi --resume abc123` started a
      // chat with the message "abc123". A following token that looks like
      // another flag is not a value, so it isn't consumed.
      const next = passthrough[i + 1];
      if (next !== undefined && !next.startsWith("-")) {
        ignored.push(`${a} ${next}`);
        i++;
      } else {
        ignored.push(a);
      }
    } else {
      words.push(a);
    }
  }
  const message = words.length > 0 ? words.join(" ") : undefined;
  const printFormat = json ? "json" : "text";
  if (rpc) return { mode: "rpc", printFormat: "text", message, verbose, ignored };
  // `-p`/`--mode` request print; piped stdin makes a bare invocation one-shot
  // too, matching pi's own CLI (it reads stdin → switches to print mode).
  if (print || isStdinPiped) return { mode: "print", printFormat, message, verbose, ignored };
  return { mode: "interactive", printFormat, message, verbose, ignored };
}
