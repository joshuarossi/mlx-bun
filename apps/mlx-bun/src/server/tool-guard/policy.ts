// Ported from SafeAgents (https://github.com/huggingface/safeagents, commit a8ee22d), src/safeagents/policy.py and
// src/safeagents/constants.py. Copyright 2026 the HuggingFace Inc. team. Apache License 2.0; the full text is in
// apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// Checks that need only the request: the tools it declared and the hosts it mentions.

/** Hosts that may appear in tool calls even if the conversation never mentions them. */
export const DEFAULT_ALLOWED_HOSTS: readonly string[] = [
  "localhost", "127.0.0.1", "github.com", "githubusercontent.com", "pypi.org", "pythonhosted.org", "huggingface.co", "hf.co",
  "npmjs.org", "crates.io",
];

/** Domains reserved for examples (RFC 2606), allowed on top of any allowlist: no one can register
 * them, so a call reaches no one through them. */
const RESERVED_HOSTS: readonly string[] = ["example.com", "example.net", "example.org"];

// What lets a call reach a host: a network client in a command or in code, or a tool that fetches.
// A URL anywhere else (a CSV row, a log line in a test fixture, a docstring citation) is data the
// call writes, not a request it makes.
const NETWORK_PATTERN = new RegExp(
  String.raw`\b(?:curl|wget|nc|ncat|netcat|telnet|ssh|scp|sftp|rsync|ftp)\s` +
  String.raw`|\bgit\s+(?:clone|fetch|pull|push|ls-remote)\b|\bpip3?\s+install\b|/dev/(?:tcp|udp)/` +
  String.raw`|\brequests\.(?:get|post|put|patch|delete|head|options|request|Session)\b|\burlopen\(|\burllib\.request\b` +
  String.raw`|\bhttpx\.|\baiohttp\.|\bhttp\.client\b|\bsocket\.(?:socket|create_connection)\b|\bfetch\(`, "i");
/** Tools that reach a URL by themselves (`web_fetch`, `browser_exec`, ...), whatever their arguments say. */
const NETWORK_TOOL_PATTERN = /fetch|browse|browser|web|http|url|download/i;

const AUTHORITY_PATTERN = /:\/\/([^\s/?#"'\\`)\]>]*)/g;
const HOST_PATTERN = /^[a-z0-9.-]*/;
// Not after `=`: `pkg==0.5.1.4` is a version, not an address.
const IPV4 = String.raw`\d{1,3}(?:\.\d{1,3}){3}`;
const IPV4_PATTERN = new RegExp(String.raw`(?<![\d.=])${IPV4}(?![\d.])`, "g");
const IPV4_ONLY = new RegExp(`^${IPV4}$`);
/** The line boundaries Python's `str.splitlines` uses. */
const LINE_BREAK = new RegExp(String.raw`\r\n|[\n\r\v\f\x1c-\x1e\x85\u2028\u2029]`);

/** Tool names in the request's `tools`: OpenAI `function.name`, Anthropic `name`. */
export function declaredTools(request: { tools?: unknown }): Set<string> {
  const names = new Set<string>();
  for (const tool of Array.isArray(request.tools) ? request.tools : []) {
    if (typeof tool !== "object" || tool === null) continue;
    const { function: fn, name: direct } = tool as { function?: unknown; name?: unknown };
    const name = typeof fn === "object" && fn !== null && !Array.isArray(fn) ? (fn as { name?: unknown }).name : direct;
    if (typeof name === "string") names.add(name);
  }
  return names;
}

/** Lowercased hosts in `text`: the host of `scheme://` URLs and bare IPv4 literals, sorted. */
export function extractHosts(text: string): string[] {
  const lowered = text.toLowerCase();
  const hosts = new Set<string>();
  for (const [, authority] of lowered.matchAll(AUTHORITY_PATTERN)) {
    const host = HOST_PATTERN.exec(authority!.slice(authority!.lastIndexOf("@") + 1))![0];
    if (host) hosts.add(host);
  }
  for (const [address] of lowered.matchAll(IPV4_PATTERN))
    if (address.split(".").every(octet => Number(octet) <= 255)) hosts.add(address);
  return [...hosts].sort();
}

/** The text a call's raw JSON arguments carry: every string value, decoded (a command's newlines
 * are real again). Matching the raw JSON instead reads an escaped newline before `cat` as `ncat`,
 * a network client. */
export function callText(args: string): string {
  let value: unknown;
  try { value = JSON.parse(args); } catch { return args; }
  const strings: string[] = [];
  const walk = (item: unknown): void => {
    if (typeof item === "string") strings.push(item);
    else if (Array.isArray(item)) item.forEach(walk);
    else if (typeof item === "object" && item !== null) Object.values(item).forEach(walk);
  };
  walk(value);
  return strings.join("\n");
}

/** What a request allows its response to call. */
export class RequestPolicy {
  readonly #declared: Set<string>;
  readonly #context: string;
  readonly #allowedHosts: string[];

  constructor(request: { messages?: unknown; tools?: unknown }, allowedHosts: readonly string[] = DEFAULT_ALLOWED_HOSTS) {
    this.#declared = declaredTools(request);
    // The request without the model's own turns: a host the model wrote earlier is no more
    // sourced than one it writes now.
    const messages = Array.isArray(request.messages)
      ? request.messages.filter(message => !(typeof message === "object" && message !== null && (message as { role?: unknown }).role === "assistant"))
      : request.messages;
    this.#context = JSON.stringify({ ...request, messages }).toLowerCase();
    this.#allowedHosts = [...allowedHosts, ...RESERVED_HOSTS].map(host => host.toLowerCase());
  }

  /** Why a call to `name` with raw `args` should be blocked, if it should. */
  check(name: string, args: string): string | null {
    if (!this.#declared.has(name)) return "undeclared tool";
    // A host only matters in a call that can reach it: one in a file the call writes is data.
    const text = callText(args);
    const networkTool = NETWORK_TOOL_PATTERN.test(name);
    if (!networkTool && !NETWORK_PATTERN.test(text)) return null;
    // A URL's host counts anywhere in such a call (code often names the URL a line before it opens
    // it). A bare IP counts only on a line that reaches out: elsewhere it is data, like the log
    // lines of a test fixture.
    const reaching = networkTool ? text : text.split(LINE_BREAK).filter(line => NETWORK_PATTERN.test(line)).join("\n");
    const urlHosts = extractHosts(text).filter(host => !IPV4_ONLY.test(host));
    for (const host of [...new Set([...urlHosts, ...extractHosts(reaching)])].sort()) {
      // A substring test, as in SafeAgents: a host that is part of a longer mentioned name passes.
      if (this.#context.includes(host)) continue;
      if (this.#allowedHosts.some(allowed => host === allowed || host.endsWith(`.${allowed}`))) continue;
      return `host \`${host}\` appears nowhere in the conversation`;
    }
    return null;
  }
}
