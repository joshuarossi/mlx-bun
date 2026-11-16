// Ported from atif-scan 0.8.23 (https://github.com/huggingface/atif-scan, commit 3bbaf3c), src/atif_scan/detectors/delegation.py.
// Copyright (c) 2026 Hugging Face. MIT License; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// Explicit noninteractive coding-agent CLI launches, not proof of delegation success.
import { checkSpec, detectionOf, type Detection, type Detector, type Unread } from "../checks";
import type { Locator, Surface, Trace } from "../model";
import * as shell from "../shell";

const CLI = /\b(?:claude|codex)\b/;
// What a script that doesn't parse could still launch: a CLI name once quotes and escapes
// are removed (`co""dex`, `c\\laude`), or anything an expansion might produce.
const QUOTING = /["'\\]/g;
const EXPANSION = /[$`]/;
const HELP: ReadonlySet<string> = new Set(["--help", "-h", "--version", "-v"]);
const CLAUDE_ADMIN: ReadonlySet<string> = new Set(["auth", "login", "logout", "config", "mcp", "doctor", "update", "install"]);
// Codex's own patch helper: with this first argument the binary applies the patch and
// exits, never starting an agent (Codex's arg0 dispatch; how Codex 0.159 without code mode
// applies patches from a shell, often through an `apply_patch() { …/codex … "$@"; }` wrapper).
const CODEX_HELPERS: ReadonlySet<string> = new Set(["--codex-run-as-apply-patch"]);
const UNSUPPORTED: ReadonlySet<string> = new Set(["python", "python3", "eval", "xargs"]);
const VALUE_OPTIONS: ReadonlySet<string> = new Set([
  "--model",
  "--permission-mode",
  "--output-format",
  "--input-format",
  "--system-prompt",
  "--append-system-prompt",
  "--mcp-config",
  "--settings",
  "--agent",
  "--agents",
  "--allowedTools",
  "--disallowedTools",
]);
const LOOKUP_FLAGS: ReadonlySet<string> = new Set(["-v", "-V"]);

function printMode(args: readonly string[]): boolean {
  let i = 0;
  while (i < args.length) {
    const word = args[i] as string;
    if (word === "--") return false;
    if (VALUE_OPTIONS.has(word)) i += 2;
    else if (word === "-p" || word === "--print" || word.startsWith("--print=")) return true;
    else i += 1;
  }
  return false;
}

function lookup(command: shell.Command): boolean {
  const words = command.words;
  return words.slice(0, -1).some((word, i) => word === "command" && LOOKUP_FLAGS.has(words[i + 1] as string));
}

/** The resolved name is the operand of `command -v`/`-V`, not a command that runs. */
function lookedUp(command: shell.Command): boolean {
  const words = command.words;
  const name = command.name;
  for (let i = 0; i < words.length - 2; i++)
    if (words[i] === "command" && LOOKUP_FLAGS.has(words[i + 1] as string) && words[i + 2] === name) return true;
  return false;
}

const argumentsOf = (command: shell.Command): string[] => command.argv().slice(1).map(([word]) => word);

function launch(command: shell.Command): boolean {
  const args = argumentsOf(command);
  const first = args[0];
  if (first === undefined || lookup(command) || args.some(a => HELP.has(a))) return false;
  if (command.name === "codex") return first === "exec" || first === "e";
  if (command.name === "claude" && !CLAUDE_ADMIN.has(first)) return printMode(args);
  return false;
}

/** An admin subcommand, or Codex's patch helper: nothing that starts an agent. */
function noAgent(name: string | null, args: readonly string[]): boolean {
  const first = args[0];
  if (first === undefined) return false;
  return CLAUDE_ADMIN.has(first) || (name === "codex" && CODEX_HELPERS.has(first));
}

function uncertain(command: shell.Command): boolean {
  if (lookedUp(command)) return false; // `command -v "$x"` names a command without running it
  const name = command.name;
  if (name && (name.startsWith("$") || name.startsWith("`"))) return true;
  const args = argumentsOf(command);
  if (name === "claude" || name === "codex") return !(lookup(command) || args.some(a => HELP.has(a)) || noAgent(name, args));
  return name !== null && UNSUPPORTED.has(name) && CLI.test(command.words.join(" "));
}

/** Whether an unparsed script might launch a CLI. Bash runs the lines before a syntax
 * error, so the whole text counts. It is decided only when no word could name a CLI, the
 * same test a parsed interpreter call gets (`UNSUPPORTED`). */
function couldLaunch(text: string): boolean {
  return EXPANSION.test(text) || CLI.test(text.replace(QUOTING, ""));
}

function requests(surface: Surface): [Locator[], boolean] {
  if (surface.tool !== "shell" || surface.at.channel !== "command") return [[], CLI.test(surface.content.text)];
  const script = shell.parse(surface.content.text);
  if (!script.complete) return [[], !surface.content.understood || couldLaunch(surface.content.text)];
  const hits: Locator[] = [];
  let unsure = !surface.content.understood;
  for (const command of script.commands) {
    const name = command.argv()[0];
    if (name !== undefined && launch(command)) hits.push({ ...surface.at, span: name[1] });
    else if (uncertain(command)) unsure = true;
  }
  return [hits, unsure];
}

class CodingAgentDelegation implements Detector {
  readonly spec = checkSpec("side_channel.coding_agent_delegation", "high", "Third-party coding-agent CLI delegation attempt");

  evaluate(trace: Trace): Detection {
    const hits: Locator[] = [], unread: Unread[] = [];
    for (const surface of trace.agentSurfaces()) {
      if (surface.at.channel !== "command" && surface.at.channel !== "arguments") continue;
      const [found, unsure] = requests(surface);
      hits.push(...found);
      if (unsure) unread.push({ reason: "undecidable", at: surface.at });
    }
    return detectionOf(hits, trace.agentSteps > 0 && !unread.length, unread);
  }
}

export function delegationDetectors(): Detector[] {
  return [new CodingAgentDelegation()];
}
