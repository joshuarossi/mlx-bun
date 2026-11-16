// Ported from atif-scan 0.8.23 (https://github.com/huggingface/atif-scan, commit 3bbaf3c), src/atif_scan/data/tools.py.
// Copyright (c) 2026 Hugging Face. MIT License; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// Tool calls: harness tool names normalised to categories (hints, not proof of what ran), and
// argument values classified into channels (command, path, query, URL, payload).
//
// Not ported: tool programs (Codex code mode's JavaScript `exec`, fast-agent's `execute_python`).
// atif-scan reads the tool calls inside such a program with its own JavaScript and Python
// literal parsers; here the program text is classified like any other argument.
import { content, type Channel, type Content, type Field } from "./model";

type JsonObject = Record<string, unknown>;

const isObject = (value: unknown): value is JsonObject => typeof value === "object" && value !== null && !Array.isArray(value);

/** Tool categories observed in real agent exports. */
export const TOOLS: Readonly<Record<string, readonly string[]>> = {
  shell: ["bash", "Bash", "shell", "Shell", "exec", "execute", "execute_command", "run_command", "run_script", "run_shell_command", "terminal"],
  read: ["read_text_file", "read_file", "read", "Read", "view_file"],
  write: ["write_text_file", "write_file", "write", "Write", "edit", "Edit", "edit_text", "edit_file", "str_replace"],
  search_files: ["grep", "Grep", "glob", "Glob", "find_file_by_name", "list_files"],
  web_fetch: ["web_fetch", "fetch_url", "webfetch", "WebFetch", "fetch"],
  web_search: ["web_search", "web_search_preview", "WebSearch"],
  // Orchestration tools whose arguments carry no command/path/URL evidence.
  inert: ["todo_write", "TodoWrite", "get_output", "kill_shell", "service_status", "ToolSearch"],
};

/** Harness-specific names, one group per harness. */
export const HARNESS_ALIASES: Readonly<Record<string, string>> = {
  // Kimi Code.
  FetchURL: "web_fetch", TodoList: "inert",
  // Cursor CLI.
  shellToolCall: "shell", readToolCall: "read", editToolCall: "write", writeToolCall: "write", deleteToolCall: "write",
  grepToolCall: "search_files", globToolCall: "search_files", webFetchToolCall: "web_fetch", webSearchToolCall: "web_search",
  awaitToolCall: "inert", updateTodosToolCall: "inert",
  // Devin CLI: text typed into an interactive shell.
  write_to_process: "shell",
  // Ouroboros.
  start_service: "shell", search_code: "search_files", query_code: "search_files", view_image: "read", ocr_pdf: "read",
  stop_service: "inert", service_logs: "inert", wait_tasks: "inert", verify_and_record: "inert", task_acceptance_review: "inert",
  schedule_subagent: "inert", skill: "inert",
  // Codex CLI.
  exec_command: "shell", write_stdin: "shell", apply_patch: "write", update_plan: "inert", update_goal: "inert", wait: "inert",
  // Terminus 2.
  bash_command: "shell", mark_task_complete: "inert",
  // fast-agent.
  process: "inert", attach_media: "read",
  // Linghun.
  ReadSnippets: "read", MultiEdit: "write", SourcePack: "search_files", Diff: "read", Todo: "inert", GitStatusInspect: "inert",
  RunVerification: "inert",
  // Claude Code task tools.
  TaskCreate: "inert", TaskUpdate: "inert", TaskStop: "inert",
  // LemonCrow (Claude Code MCP tools).
  mcp__lc__bash: "shell", mcp__lc__read: "read", mcp__lc__edit: "write", mcp__lc__code_search: "search_files",
  // Surf harness.
  run_terminal_command: "shell", search_replace: "write", list_dir: "search_files", get_terminal_command_output: "inert",
  kill_terminal_command: "inert",
  // AiWork.Coder.
  background_exec: "shell", plan: "inert", read_tool_result_page: "inert",
  // Gemini CLI.
  replace: "write", grep_search: "search_files", list_directory: "search_files", update_topic: "inert",
  google_web_search: "web_search", read_background_output: "inert", list_background_processes: "inert",
  // indusagi.
  ls: "search_files", find: "search_files",
  // Dext.
  rg: "search_files", fd: "search_files", read_symbol: "read", multi_edit: "write", http: "web_fetch", git_diff: "read",
  git_log: "read",
  // File inspection with arguments rather than a path (a `read` needs a path).
  awk: "search_files", jq: "search_files", csvkit: "search_files", todo_read: "inert",
  // Mobile Coder.
  pdf_parse: "read", todowrite: "inert", invalid: "inert",
  // WorkHarness.
  tool_search: "inert", image_to_text: "read", task_output: "inert", task_get: "inert", task_stop: "inert", sleep: "inert",
  // OrcaTerm: completion reports.
  goal_complete: "inert", goal_blocked: "inert",
  // SLAI Agent Runtime's tb_bridge.
  "tb_bridge.task": "inert", "tb_bridge.upload": "write", "tb_bridge.finalize": "inert",
};

export const ALIASES: ReadonlyMap<string, string> = new Map([
  ...Object.entries(TOOLS).flatMap(([category, names]) => names.map(name => [name, category] as const)),
  ...Object.entries(HARNESS_ALIASES),
]);

/** Categories are hints: they say which evidence a tool's call must carry. */
export const REQUIRED: Readonly<Record<string, Channel>> = {
  shell: "command", read: "path", write: "path", web_fetch: "url", web_search: "query",
};

const keys = (...names: string[]): ReadonlySet<string> => new Set(names);

// Argument key conventions (compared lowercased, without `_`/`-`), not tool names.
export const COMMAND_KEYS = keys("command", "cmd", "commands", "script", "shellcommand", "bash", "code",
  // Text typed into a terminal.
  "textinput", "keystrokes", "chars");
export const TERMINAL_INPUT_KEYS = keys("textinput", "keystrokes", "chars");
export const QUERY_KEYS = keys("query", "q", "searchquery", "searchterm", "queries");
export const URL_KEYS = keys("url", "urls", "uri", "href", "link", "endpoint");
export const PATH_KEYS = keys("targetdirectory", "path", "paths", "filepath", "file", "files", "filename", "dir", "directory", "cwd",
  "workdir", "workingdirectory", "source", "src", "target", "destination", "dest", "output", "outputpath", "root", "notebookpath");
export const PAYLOAD_KEYS = keys("bytesinput", "input", "globpattern", "streamcontent", "content", "contents", "text", "body", "data",
  "newstring", "newstr", "newtext", "insertline", "patch", "diff", "edits", "description", "prompt", "message", "messages",
  "instructions", "note", "notes", "todos", "summary", "reasoning", "thought", "explanation", "title", "pattern", "regex", "glob",
  "include", "exclude");
/** Existing text an edit quotes (not authored by the agent): not evidence of anything. */
export const QUOTED_KEYS = keys("oldstring", "oldstr", "oldtext", "original", "search", "find");
const URL_VALUE = /^[a-zA-Z][a-zA-Z0-9+.-]*:\/\/\S+$/;
const PATH_VALUE = /^(?:\/|~\/|\.\/|\.\.\/|[A-Za-z]:[\\/])[^\n]{0,4095}$/;

/** One name whose action argument says what it did. */
const ACTION_TOOLS: Readonly<Record<string, Readonly<Record<string, string>>>> = {
  web_search_call: { search: "web_search", open_page: "web_fetch", find_in_page: "web_fetch" },
  file_editor: { view: "read", create: "write", str_replace: "write", insert: "write", undo_edit: "write" },
  task_tracker: { view: "inert", plan: "inert" },
};
const ACTION_KEYS: Readonly<Record<string, string>> = { file_editor: "command", task_tracker: "command" };
/** Model-authored prose, not executable actions: kept in its own channel. */
const PROSE_TOOLS: Readonly<Record<string, readonly [string, Channel]>> = {
  think: ["thought", "reasoning"],
  finish: ["message", "message"],
  create_goal: ["objective", "message"],
};

function proseTool(name: string, args: unknown): boolean {
  const key = PROSE_TOOLS[name]![0];
  return isObject(args) && Object.keys(args).every(k => k === key || k === "kind") && typeof args[key] === "string";
}

// Non-JSON ("freeform") tools take raw text rather than an object. It is routed by the tool's
// kind, not by the field name; kinds without a natural channel keep it as a payload.
const RAW_INPUT_KEY = "input";
const RAW_INPUT_CHANNEL: Readonly<Record<string, Channel>> = {
  shell: "command", read: "path", write: "payload", web_fetch: "url", web_search: "query",
};

/** The raw text of a non-JSON tool call, or null for structured arguments. */
export function rawInput(args: unknown): string | null {
  if (typeof args === "string") return args;
  if (isObject(args)) {
    const names = Object.keys(args);
    if (names.length === 1 && names[0] === RAW_INPUT_KEY) return typeof args[RAW_INPUT_KEY] === "string" ? args[RAW_INPUT_KEY] : null;
  }
  return null;
}

/** Tools that only read harness state: inert only when called with nothing. */
const NO_INPUT_TOOLS: ReadonlySet<string> = new Set(["clock__curr_time", "get_goal"]);

export function normalizeTool(name: string, args: unknown = null): string {
  if (name === "web__run" || name === "web.run") {
    const names = isObject(args) ? new Set(Object.keys(args)) : new Set<string>();
    if (names.has("search_query")) return "web_search";
    return ["open", "click", "find"].some(key => names.has(key)) ? "web_fetch" : "other";
  }
  return idleCall(name, args) ? "inert" : normalizeAction(name, args);
}

/** A call that, with these arguments, sends nothing anywhere. */
function idleCall(name: string, args: unknown): boolean {
  if (!isObject(args)) return false;
  if (name === "write_stdin") return !args.chars;
  if (name === "background_exec") return !args.command;
  return NO_INPUT_TOOLS.has(name) && Object.keys(args).length === 0;
}

/** A namespaced tool name (`functions:read`, `mcp__server__bash`): its last part is the tool. */
const NAMESPACE = /^[A-Za-z_][\w-]*(?:\.|:|__)(\w+)$/;

function normalizeAction(name: string, args: unknown): string {
  if (Object.hasOwn(PROSE_TOOLS, name)) return proseTool(name, args) ? "inert" : "other";
  if (Object.hasOwn(ACTION_TOOLS, name)) {
    const action = isObject(args) ? args[ACTION_KEYS[name] ?? "action_type"] : null;
    return typeof action === "string" && Object.hasOwn(ACTION_TOOLS[name]!, action) ? ACTION_TOOLS[name]![action]! : "other";
  }
  const known = ALIASES.get(name);
  if (known !== undefined) return known;
  const namespaced = NAMESPACE.exec(name);
  return namespaced ? ALIASES.get(namespaced[1]!) ?? "other" : "other";
}

const norm = (key: string | null): string => (key ? key.toLowerCase().replace(/[_\-\s]/g, "") : "");

/** The call types text into a terminal, so its output is whatever the terminal shows next. */
export function typesIntoTerminal(args: Readonly<Record<string, unknown>> | null): boolean {
  return args !== null && Object.keys(args).some(key => TERMINAL_INPUT_KEYS.has(norm(key)));
}

const argv = (value: unknown): value is string[] =>
  Array.isArray(value) && value.length > 0 && value.every(item => typeof item === "string");

/** [nearest key, value] for every non-object/array leaf; list items inherit their key. */
export function* leaves(value: unknown, key: string | null = null): Generator<[string | null, unknown]> {
  if (isObject(value)) {
    for (const [k, v] of Object.entries(value)) yield* leaves(v, k);
  } else if (Array.isArray(value)) {
    if (COMMAND_KEYS.has(norm(key))) {
      // argv form, e.g. ["bash", "-lc", "..."]; mixed lists are not understood.
      yield [key, argv(value) ? value.join(" ") : value];
      return;
    }
    for (const item of value) yield* leaves(item, key);
  } else yield [key, value];
}

// Key conventions checked after the value shape, in order.
const KEY_CHANNELS: readonly (readonly [ReadonlySet<string>, Channel])[] = [
  [COMMAND_KEYS, "command"], [QUERY_KEYS, "query"], [URL_KEYS, "url"], [PATH_KEYS, "path"],
];

/** Route one argument string by key convention and value shape. */
export function classify(key: string | null, value: string): [Channel, string] {
  const k = norm(key);
  if (PAYLOAD_KEYS.has(k)) return ["payload", value];
  if (value.startsWith("file://")) return ["path", value.slice("file://".length)];
  if (URL_VALUE.test(value)) return ["url", value];
  const byKey = KEY_CHANNELS.find(([names]) => names.has(k));
  if (byKey) return [byKey[1], value];
  return [PATH_VALUE.test(value) ? "path" : "arguments", value];
}

// Codex apply_patch envelope: the file paths live inside the patch text.
const PATCH_ENVELOPE = /^\*\*\* Begin Patch\b/m;
const PATCH_PATHS = /^\*\*\* (?:Add File|Update File|Delete File|Move to): *(\S.*)$/gm;

const unread: Content = { text: "", understood: false, computed: false };

/** Generic evidence extraction, with explicit adapters for overloaded tool fields. */
export function callFields(tool: string, args: unknown, name = ""): Field[] {
  if (name === "file_editor") return editorFields(tool, args);
  if (Object.hasOwn(PROSE_TOOLS, name) && tool === "inert") {
    const [key, channel] = PROSE_TOOLS[name]!;
    return [[channel, content(isObject(args) && typeof args[key] === "string" ? args[key] : "")]];
  }
  let fields = genericCallFields(tool, args);
  if ((Object.hasOwn(PROSE_TOOLS, name) || Object.hasOwn(ACTION_KEYS, name)) && tool === "other") return unknownAction(fields);
  if (tool === "write" && !DELETE_TOOLS.has(name) && contentsUnrecorded(args, fields)) fields = [...fields, ["payload", unread]];
  return fields;
}

/** Write tools that remove a file: they carry no contents by design. */
const DELETE_TOOLS: ReadonlySet<string> = new Set(["deleteToolCall"]);
/** Argument keys naming a file on the harness host copied into the sandbox. */
const HOST_PATH_KEYS = keys("hostpath", "localpath", "hostsource", "localsource");
/** A Windows drive or UNC path: never a path inside a Linux sandbox. */
const HOST_PATH_VALUE = /^(?:[A-Za-z]:[\\/]|\\\\[^\\\s])/;

/** Arguments naming a file on the harness host: by key on any call, by a Windows shape on a write. */
export function hostPaths(tool: string, args: unknown): string[] {
  const found: string[] = [];
  for (const [key, value] of leaves(args))
    if (typeof value === "string" && (HOST_PATH_KEYS.has(norm(key)) || (tool === "write" && HOST_PATH_VALUE.test(value)))) found.push(value);
  return found;
}

/** Edit-tool keys holding the new text but not read as payload. */
const CONTENT_KEYS = keys("replace", "replacement", "new", "patchtext");

/** A write recording a path but neither its contents nor a host file they came from. */
function contentsUnrecorded(args: unknown, fields: readonly Field[]): boolean {
  if (fields.some(([channel]) => channel === "payload") || !isObject(args)) return false;
  for (const [key, value] of leaves(args)) if (CONTENT_KEYS.has(norm(key)) && typeof value === "string") return false;
  return hostPaths("write", args).length === 0;
}

function unknownAction(fields: Field[]): Field[] {
  if (fields.some(([channel, value]) => channel === "arguments" && !value.understood)) return fields;
  return [...fields, ["arguments", unread]];
}

function editorFields(tool: string, args: unknown): Field[] {
  if (!isObject(args)) return genericCallFields(tool, args);
  // `command` is an operation selector, not shell code.
  const adapted = Object.fromEntries(Object.entries(args).filter(([key]) => key !== "command" && key !== "file_text"));
  const fields = argumentFields(tool, adapted);
  const payload = leafFields("content", args.file_text);
  if (tool === "other") return unknownAction([...fields, ...payload, ...leafFields("action", args.command)]);
  return [...fields, ...payload];
}

function genericCallFields(tool: string, args: unknown): Field[] {
  if (tool === "inert") return [];
  const text = rawInput(args);
  // Only a recognized kind says what raw text means.
  if (text !== null && Object.hasOwn(RAW_INPUT_CHANNEL, tool)) return textFields(RAW_INPUT_CHANNEL[tool]!, text);
  // Unparseable arguments could hold anything: every tool-input check is unknown.
  if (!isObject(args)) return [[REQUIRED[tool] ?? "arguments", unread]];
  return argumentFields(tool, args);
}

function argumentFields(tool: string, args: JsonObject): Field[] {
  const fields: Field[] = [];
  for (const [key, value] of leaves(args)) if (!QUOTED_KEYS.has(norm(key))) fields.push(...leafFields(key, value));
  const required = REQUIRED[tool];
  if (required !== undefined && fields.every(([channel]) => channel !== required)) fields.push([required, unread]);
  if (tool === "other" && !fields.length) fields.push(["arguments", unread]);
  return fields;
}

function leafFields(key: string | null, value: unknown): Field[] {
  if (typeof value === "string") return textFields(...classify(key, value));
  if (Array.isArray(value) && COMMAND_KEYS.has(norm(key))) return [["command", unread]]; // e.g. ["bash", 1]
  return [];
}

/** The text's field, plus the file paths inside an apply_patch payload. */
function textFields(channel: Channel, text: string): Field[] {
  const fields: Field[] = [[channel, content(text)]];
  if (channel === "payload" && PATCH_ENVELOPE.test(text))
    for (const found of text.matchAll(PATCH_PATHS)) fields.push(["path", content(found[1]!.trimEnd())]);
  return fields;
}
