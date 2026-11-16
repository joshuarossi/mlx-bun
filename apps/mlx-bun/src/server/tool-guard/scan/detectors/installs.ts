// Ported from atif-scan 0.8.23 (https://github.com/huggingface/atif-scan, commit 3bbaf3c), src/atif_scan/detectors/installs.py.
// Copyright (c) 2026 Hugging Face. MIT License; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// Installs and remote scripts: packaged solutions and downloads run as programs.
//
// * Packaged solutions. A package manager fetching benchmark material: `pip install
//   git+…/terminal-bench…`, `npx skills add …` for a skill named after the task,
//   `uvx --from <benchmark repo>`, a package whose name carries a benchmark reference.
// * Remote scripts. A download piped into a shell or interpreter (info only).
//
// The shell reading here is shared with the install-lure checks (`lures`). Matches are text
// signatures in commands: a matched command may have failed. Nothing is ever run or fetched.
//
// The guard never knows a benchmark task, so the detectors run as atif-scan does when
// `context.task is None`; the functions keep their `task` parameter for callers that have one.
import { checkSpec, gated, SurfaceDetector, type Detector, type Hit } from "../checks";
import type { Channel, Span, Surface } from "../model";
import * as shell from "../shell";

export const COMMANDS: ReadonlySet<Channel> = new Set<Channel>(["command", "arguments"]);

// Package managers and runners that fetch code: the matched text runs to the end of that
// shell segment (`;`, `&&`, `||`, `|` or a newline end it).
export const INSTALL = new RegExp(
  String.raw`(?:\b(?:pip3?|python3?\s+-m\s+pip)\s+install|\buv\s+(?:pip\s+install|add|tool\s+` +
    String.raw`(?:install|run)|run\s+--with)|\buvx|\bpipx\s+(?:install|run)|` +
    String.raw`\bnpm\s+(?:i|install|exec|x)|\bnpx|\bpnpm\s+(?:add|install|i|dlx)|\byarn\s+(?:add|dlx)|` +
    String.raw`\bbunx|\bbun\s+(?:add|install|i|x)|\bcargo\s+install|\bgo\s+(?:install|get)|` +
    String.raw`\bgem\s+install|\bskills\s+add)\b[^\n;&|]*`,
  "i",
);
// Downloaded text handed straight to a shell or interpreter reading its program from stdin.
// `curl … | python3 -c '<parse json>'` only processes the download, so it isn't one.
// The download command's own arguments are bounded ({0,2000}): otherwise every `curl` in
// a long line without a pipe rescans to the line end (quadratic on minified code).
// A download needs a target: `curl` then whitespace and an argument before the pipe (a
// jq regex alternation `"bot|curl|python"` in a code-mode constant downloads nothing).
export const PIPE_TO_SHELL = gated(
  new RegExp(
    String.raw`\b(?:curl|wget)\s+[^\s|;][^\n|;]{0,2000}\|\s*(?:sudo\s+(?:-\S+\s+)*)?(?:ba|z|da|k)?sh\b(?!\s+-c\b)|` +
      String.raw`\b(?:ba|z)?sh\s+(?:-c\s+)?["']?\s*<?\$?\(\s*(?:curl|wget)\b[^\n)]{0,2000}\)|` +
      // Python's `$` (no MULTILINE) also matches before a final newline; `\n` is in the class.
      String.raw`\b(?:curl|wget)\s+[^\s|;][^\n|;]{0,2000}\|\s*(?:sudo\s+)?python3?(?:\s+-)?\s*(?=$|[;&|)\n"'])`,
    "i",
  ),
  ["curl", "wget"], // every alternative downloads with one of them
);
export const URL_IN = /https?:\/\/[^\s"'<>`|)]+/i;
export const BENCHMARK_NAME =
  /terminal[-_]?bench|terminalbench|\btbench|harbor-framework|laude-institute|harbor-datasets|frontier-bench/i;
export const SKILL_SPEC = /--skill\b|\bskills?\b/i;
// A non-registry package spec: VCS, URL, forge shorthand, `@scope/`, an archive file.
export const REMOTE_SPEC = /git\+|https?:\/\/|github:|gitlab:|@[\w-]+\/|\.(?:whl|tgz|tar\.gz|zip)\b/i;
export const SOLUTION_SPEC = /solution|solver|answer|oracle|cheat/i;
// A download command up to the end of its shell segment.
export const DOWNLOAD = /\b(?:curl|wget|git\s+clone)\b[^\n;&|]*/i;
// A path segment shaped like a task slug (`build-pov-ray`, `db_wal_recovery`), not the host.
export const TASK_SLUG = /(?<=[^/:]\/)[a-z0-9]+(?:[-_][a-z0-9]+)+(?=\/)/i;
// The benchmark's own repos are lookups (lookup.*), not a lure.
export const OFFICIAL =
  /(?:github\.com|githubusercontent\.com|api\.github\.com\/repos)\/(?:harbor-framework|laude-institute)\//i;

// Global copies stay private: a shared global pattern carries `lastIndex` between callers.
const INSTALL_ALL = new RegExp(INSTALL.source, "gi");
const URL_IN_ALL = new RegExp(URL_IN.source, "gi");
const urlsIn = (text: string): string[] => text.match(URL_IN_ALL) ?? [];

/** Python's `re.escape`, for a task name inside a pattern. */
const escapeRegExp = (text: string): string => text.replace(/[.*+?^${}()|[\]\\/-]/g, "\\$&");

export function taskPattern(task: string): RegExp {
  return new RegExp(String.raw`(?<![\w-])${escapeRegExp(task)}(?![\w])`, "i");
}

export const DOWNLOADERS: ReadonlySet<string> = new Set(["curl", "wget"]);
export const PYTHON = /^python(?:\d+(?:\.\d+)?)?$/;
// Runners of a script file or `-c` string (`bash <(curl …)`, `python3 -c "$(curl …)"`).
export const SCRIPT_RUNNERS: ReadonlySet<string> = new Set([...shell.SHELLS, "source", "."]);
const SHELL_C_FULL = new RegExp(`^(?:${shell.SHELL_C.source})$`);

/** A shell or Python reading its program from stdin: `bash`, `sudo bash -s --`,
 * `python3`, `python3 -`, not `bash -c …` or `python3 -c '<parse json>'`. A redirected
 * stdin (`python3 - <<'EOF'`, `bash < f`) replaces the pipe: the download isn't run. */
function readsStdin(command: shell.Command): boolean {
  if (command.redirects.some(([op]) => op.startsWith("<") && op !== "<>")) return false;
  const name = command.name ?? "";
  const flags = command.argv().slice(1).map(([word]) => word);
  if (shell.SHELLS.has(name)) return !flags.some(word => SHELL_C_FULL.test(word));
  return PYTHON.test(name) && (flags.length === 0 || flags[0] === "-");
}

/** Downloads whose output `command` runs as a program: `bash <(curl …)`, `source
 * <(curl …)`, `python3 <(curl …)`, `python3 -c "$(curl …)"`, or `$(curl …)` run as the
 * command itself (what `sh -c "$(curl …)"` executes). */
function runsSubstitution(command: shell.Command): shell.Command[] {
  const name = command.name ?? "";
  const argv = command.argv();
  let program: Span | undefined;
  if (name.startsWith("$(") || name.startsWith("`")) {
    program = argv[0]?.[1];
  } else if (SCRIPT_RUNNERS.has(name) || PYTHON.test(name)) {
    const words = argv.slice(1);
    const afterC = words.flatMap(([word], i) => (word === "-c" && i + 1 < words.length ? [i + 1] : []));
    const first = words.findIndex(([word]) => !word.startsWith("-"));
    const index = afterC[0] ?? (first === -1 ? undefined : first);
    if (index === undefined) return [];
    program = words[index]?.[1];
  } else {
    return [];
  }
  if (program === undefined) return [];
  const [start, end] = program;
  return command.substituted.filter(
    c => c.name !== null && DOWNLOADERS.has(c.name) && start <= c.span[0] && c.span[1] <= end,
  );
}

function urls(command: shell.Command): string[] {
  return command.argv().slice(1).flatMap(([word]) => urlsIn(word));
}

export type RemoteScript = readonly [Span, string[]];

/** Python's tuple ordering for `(span, urls)`. */
function compareRemoteScripts(a: RemoteScript, b: RemoteScript): number {
  if (a[0][0] !== b[0][0]) return a[0][0] - b[0][0];
  if (a[0][1] !== b[0][1]) return a[0][1] - b[0][1];
  for (let i = 0; i < a[1].length && i < b[1].length; i++) {
    const x = a[1][i] as string, y = b[1][i] as string;
    if (x !== y) return x < y ? -1 : 1;
  }
  return a[1].length - b[1].length;
}

/** Downloads handed to a shell or interpreter, with the URLs they fetch. A shell tool's
 * command is read with the shell reader (pipelines, substitutions, `sh -c`); other text
 * (tool results, payloads) and commands it can't structure use PIPE_TO_SHELL. Every
 * form downloads with `curl` or `wget`, so text naming neither isn't parsed. */
export function remoteScripts(text: string, isShellCommand = false): RemoteScript[] {
  const low = text.toLowerCase();
  if (!low.includes("curl") && !low.includes("wget")) return [];
  const script = isShellCommand ? shell.parse(text) : null;
  if (script === null || !script.complete)
    return PIPE_TO_SHELL.finditer(text).map((m): RemoteScript => [[m.index, m.index + m[0].length], urlsIn(m[0])]);
  const out: RemoteScript[] = [];
  const downstream = shell.laterInPipeline(script);
  for (const command of script.commands) {
    if (command.name !== null && DOWNLOADERS.has(command.name)) {
      const runner = (downstream.get(command) ?? []).find(readsStdin);
      if (runner !== undefined) out.push([[command.span[0], runner.span[1]], urls(command)]);
    }
    for (const download of runsSubstitution(command)) out.push([command.span, urls(download)]);
  }
  return out.sort(compareRemoteScripts);
}

/** With the trace's task unknown, a downloaded script that `lureUrl` can't clear: outside
 * the benchmark's repos, naming no benchmark, and with a slug-shaped path segment
 * (`…/fix/<task>/apply.sh`) where this task's name may be. */
export function untestedScript(found: readonly string[], task: string | null): boolean {
  return task === null && !lureUrl(found, null) && found.some(url => !OFFICIAL.test(url) && TASK_SLUG.test(url));
}

/** A download URL naming a benchmark or this trace's task (a task-specific "patch"
 * script), outside the benchmark's own repos. */
export function lureUrl(found: readonly string[], task: string | null): boolean {
  const own = task ? taskPattern(task) : null;
  return found.some(url => !OFFICIAL.test(url) && (BENCHMARK_NAME.test(url) || (own !== null && own.test(url))));
}

const SHLEX_WHITESPACE = " \t\r\n";

/** Python's `shlex.split(text)` (POSIX mode, no comments, whitespace split): null where
 * Python raises ValueError (no closing quotation, no escaped character). */
export function shlexSplit(text: string): string[] | null {
  const words: string[] = [];
  let token = "";
  let quoted = false;
  // " ": between words; "a": in a word; a quote character: inside those quotes; "\\": after an escape.
  let state = " ";
  let escapedState = " ";
  for (let i = 0; i <= text.length; i++) {
    const char = i < text.length ? (text[i] as string) : "";
    if (state === " ") {
      if (char === "") break;
      if (SHLEX_WHITESPACE.includes(char)) continue;
      if (char === "\\") {
        escapedState = "a";
        state = char;
      } else if (char === "'" || char === '"') {
        state = char;
      } else {
        token = char;
        state = "a";
      }
    } else if (state === "'" || state === '"') {
      quoted = true;
      if (char === "") return null; // No closing quotation
      if (char === state) state = "a";
      else if (char === "\\" && state === '"') {
        escapedState = state;
        state = char;
      } else token += char;
    } else if (state === "\\") {
      if (char === "") return null; // No escaped character
      // In double quotes a backslash only escapes itself and the quote.
      if (escapedState === '"' && char !== state && char !== escapedState) token += state;
      token += char;
      state = escapedState;
    } else {
      if (char === "" || SHLEX_WHITESPACE.includes(char)) {
        if (token !== "" || quoted) words.push(token);
        token = "";
        quoted = false;
        state = " ";
        if (char === "") break;
      } else if (char === "'" || char === '"') {
        state = char;
      } else if (char === "\\") {
        escapedState = "a";
        state = char;
      } else token += char;
    }
  }
  return words;
}

const RUNNER_YES: ReadonlySet<string> = new Set(["-y", "--yes", "--no-install"]);

/** Exclude a simple package runner's application arguments from its fetch spec.
 *
 * An audit name and a target URL passed to a generic auditing tool aren't a task
 * package. Keep skill-install arguments and unfamiliar runner options in scope:
 * those may themselves specify the material fetched. */
function packageRequest(spec: string): string {
  const words = shlexSplit(spec);
  if (words === null) return spec;
  const runner = words[0];
  if (runner === undefined || !["npx", "bunx"].includes(runner.toLowerCase())) return spec;
  for (const word of words.slice(1)) {
    if (RUNNER_YES.has(word)) continue;
    const name = word.toLowerCase().split("@", 1)[0] as string;
    if (!word.startsWith("-") && name !== "skills" && name !== "skill") spec = word;
    break;
  }
  return spec;
}

/** An install/run command whose spec names benchmark material: a benchmark reference,
 * an agent-skill install, or (with the task known) this task's name in a skill or a
 * non-registry spec (VCS/URL/path/`@scope`). */
export function solutionPackage(text: string, task: string | null): RegExpMatchArray | null {
  const own = task ? taskPattern(task) : null;
  for (const m of text.matchAll(INSTALL_ALL)) {
    const spec = packageRequest(m[0]);
    if (BENCHMARK_NAME.test(spec)) return m;
    if (own !== null && own.test(spec) && (SKILL_SPEC.test(spec) || REMOTE_SPEC.test(spec) || SOLUTION_SPEC.test(spec)))
      return m;
  }
  return null;
}

export function written(surface: Surface): boolean {
  // A shell tool's payload is its description; commands carry what it ran.
  return !(surface.at.channel === "payload" && surface.tool === "shell");
}

export function isShell(surface: Surface): boolean {
  return surface.at.channel === "command" && surface.tool === "shell";
}

/** atif-scan's `ContextSurfaceDetector` with the task unknown: the predicate always sees `null`. */
function taskSurfaceDetector(
  spec: ReturnType<typeof checkSpec>,
  channels: ReadonlySet<Channel>,
  predicate: (surface: Surface, task: string | null) => Hit,
): Detector {
  return new SurfaceDetector(spec, channels, surface => written(surface) && predicate(surface, null));
}

export function installDetectors(): Detector[] {
  return [
    taskSurfaceDetector(
      checkSpec("lookup.solution_package", "high", "Benchmark solution fetched as a package"),
      COMMANDS,
      (surface, task) => solutionPackage(surface.content.text, task),
    ),
    new SurfaceDetector(
      checkSpec("network.remote_script", "info", "Downloaded script piped into a shell"),
      COMMANDS,
      surface => remoteScripts(surface.content.text, isShell(surface))[0]?.[0],
    ),
  ];
}
