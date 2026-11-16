// Ported from atif-scan 0.8.23 (https://github.com/huggingface/atif-scan, commit 3bbaf3c), src/atif_scan/data/webhooks.py.
// Copyright (c) 2026 Hugging Face. MIT License; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// Offline recognition of bearer webhook URLs. Only explicit HTTPS authorities and complete
// request-target grammars qualify. This is shape recognition, never proof of issuance,
// liveness, invocation or authorization. Masking includes dummy shapes; exposure excludes
// unmistakable repeated-character placeholders. Genuine-shaped capabilities remain sensitive
// even in documentation.
//
// Not ported: atif-scan also recovers a URL assembled from Python string constants with `+`
// (`url = "https://hooks.slack.com/services/…/" + "token"`), which reads the text with Python's
// `ast` module. Here that reader behaves as atif-scan's does when the text is not Python it
// can parse: it finds no assembly. Whole URLs and JSON-escaped URLs are recognized.

export type Span = readonly [number, number];

const SLACK_HOSTS: ReadonlySet<string> = new Set(["hooks.slack.com", "hooks.slack-gov.com"]);
const DISCORD_HOSTS: ReadonlySet<string> = new Set([
  "discord.com", "discordapp.com", "canary.discord.com", "ptb.discord.com", "canary.discordapp.com", "ptb.discordapp.com",
]);
// Both are matched against the whole decoded path (Python `fullmatch`).
const SLACK_PATH = /^\/services\/(?<first>T[A-Z0-9]{8,12})\/(?<second>B[A-Z0-9]{8,12})\/(?<token>[A-Za-z0-9]{24,64})$/d;
const DISCORD_PATH = /^\/api(?:\/v[0-9]{1,2})?\/webhooks\/(?<first>[0-9]{17,20})\/(?<token>[A-Za-z0-9_-]{60,100})(?:\/(?:slack|github))?$/d;
const URL = /(?<![\w:/])https?:\/\/[^\s'"<>`\\]+/gi;
// Decode individual, bounded JSON string literals only. No eval, recursive program
// unescaping, or source execution. Whole-literal redaction is conservative but avoids
// inaccurate offsets after JSON's slash/Unicode escapes.
// eslint-disable-next-line no-control-regex
const JSON_STRING = /"(?:[^"\\\x00-\x1f]|\\(?:["\\/bfnrt]|u[0-9a-fA-F]{4})){1,4096}"/g;
const MIN_REPEAT = 8;
// Python `str.isspace`, a control character, DEL or a backslash.
// eslint-disable-next-line no-control-regex
const NOT_IN_URL = /[\x00-\x20\x7f\x85\xa0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000\\]/;
const SCHEME = /^[A-Za-z][A-Za-z0-9+.-]*$/;
const HEX_PAIR = /^[0-9a-fA-F]{2}$/;
const UNRESERVED = /^[A-Za-z0-9._~-]$/;

/** A structurally valid capability; all bearer components are private. */
export interface WebhookCapability {
  readonly service: "slack" | "discord";
  readonly token: string;
  readonly components: readonly string[];
}

interface Target {
  readonly service: "slack" | "discord";
  readonly token: string;
  readonly components: readonly (readonly [string, Span])[];
}

/** Decode only escaped unreserved bytes, preserving raw-character provenance. */
function decodePath(path: string): [string, Span[]] | null {
  let decoded = "";
  const spans: Span[] = [];
  let pos = 0;
  while (pos < path.length) {
    let end = pos + 1;
    let char = path[pos]!;
    if (char === "%") {
      const escape = path.slice(pos + 1, pos + 3);
      if (!HEX_PAIR.test(escape)) return null;
      char = String.fromCharCode(Number.parseInt(escape, 16));
      if (!UNRESERVED.test(char)) return null;
      end = pos + 3;
    }
    decoded += char;
    spans.push([pos, end]);
    pos = end;
  }
  return [decoded, spans];
}

/** The scheme, authority and path Python's `urlsplit` reads from a URL without spaces or controls. */
function urlsplit(url: string): { scheme: string; netloc: string; path: string } {
  let scheme = "";
  let rest = url;
  const colon = url.indexOf(":");
  if (colon > 0 && SCHEME.test(url.slice(0, colon))) {
    scheme = url.slice(0, colon).toLowerCase();
    rest = url.slice(colon + 1);
  }
  let netloc = "";
  if (rest.startsWith("//")) {
    const end = rest.slice(2).search(/[/?#]/);
    netloc = end < 0 ? rest.slice(2) : rest.slice(2, 2 + end);
    rest = end < 0 ? "" : rest.slice(2 + end);
  }
  const fragment = rest.indexOf("#");
  if (fragment >= 0) rest = rest.slice(0, fragment);
  const query = rest.indexOf("?");
  if (query >= 0) rest = rest.slice(0, query);
  return { scheme, netloc, path: rest };
}

function target(url: string): Target | null {
  if (NOT_IN_URL.test(url)) return null;
  const parsed = urlsplit(url);
  // Exact authority comparison also rejects userinfo, suffixes, local copies, trailing
  // dots, escaped hostnames and non-HTTPS/non-default ports.
  let host = parsed.netloc.toLowerCase();
  if (host.endsWith(":443")) host = host.slice(0, -4);
  if (parsed.scheme !== "https" || !(SLACK_HOSTS.has(host) || DISCORD_HOSTS.has(host))) return null;
  return targetPath(url, parsed.path, host);
}

function targetPath(url: string, path: string, host: string): Target | null {
  const decoded = decodePath(path);
  if (decoded === null) return null;
  const [value, spans] = decoded;
  const service = SLACK_HOSTS.has(host) ? "slack" : "discord";
  const match = (service === "slack" ? SLACK_PATH : DISCORD_PATH).exec(value);
  if (match === null) return null;
  const offset = url.indexOf(path, url.indexOf("://") + 3);
  const components: (readonly [string, Span])[] = [];
  for (const [name, component] of Object.entries(match.groups ?? {})) {
    const [start, end] = match.indices!.groups![name]!;
    components.push([component, [offset + spans[start]![0], offset + spans[end - 1]![1]]]);
  }
  return { service, token: match.groups!.token!, components };
}

/** Recognize one complete URL, not a URL substring or an arbitrary source string.
 *
 * Query/fragment text is not part of the bearer path. IDs and tokens may be synthetic/all-zero:
 * this predicate intentionally does not claim issuance. Unreserved percent escapes are decoded;
 * escaped separators are rejected. */
export function webhookCapability(url: string): WebhookCapability | null {
  const found = target(url);
  if (found === null) return null;
  return { service: found.service, token: found.token, components: found.components.map(([value]) => value) };
}

/** Documentation's XXXXXX/000000 and punctuation-only stand-ins are masked, but not findings.
 * Do not blanket-exempt "test", filenames or prose roles. */
function exposable(token: string): boolean {
  return new Set(token.toLowerCase()).size > 1 && /[\p{L}\p{N}]/u.test(token);
}

function* direct(text: string, exposure: boolean): Generator<[Span, Span, string]> {
  for (const candidate of text.matchAll(URL)) {
    const url = candidate[0].replace(/[.,;:!)\]}]+$/, "");
    const found = target(url);
    if (found === null) continue;
    if (exposure && !exposable(found.token)) continue;
    const whole: Span = [candidate.index, candidate.index + url.length];
    for (const [value, [start, end]] of found.components) yield [whole, [candidate.index + start, candidate.index + end], value];
  }
}

function* jsonCapabilities(text: string, exposure: boolean): Generator<[Span, WebhookCapability]> {
  if (!text.includes("\\/")) return;
  for (const match of text.matchAll(JSON_STRING)) {
    const raw = match[0];
    if (!raw.includes("\\/")) continue;
    let decoded: unknown;
    try {
      decoded = JSON.parse(raw);
    } catch {
      continue;
    }
    const capability = typeof decoded === "string" ? webhookCapability(decoded) : null;
    if (capability !== null && (!exposure || exposable(capability.token))) yield [[match.index, match.index + raw.length], capability];
  }
}

/** Private (whole locator, sensitive value) spans. */
export function* find(text: string, exposure = false): Generator<[Span, Span]> {
  for (const [whole, sensitive] of direct(text, exposure)) yield [whole, sensitive];
  for (const [span] of jsonCapabilities(text, exposure)) yield [span, span];
}

/** Bearer components for trace-wide masking. */
export function values(text: string): Set<string> {
  const out = new Set<string>();
  for (const [, [start, end], component] of direct(text, false)) {
    out.add(component);
    out.add(text.slice(start, end));
  }
  for (const [span, capability] of jsonCapabilities(text, false)) {
    for (const component of capability.components) out.add(component);
    out.add(text.slice(span[0], span[1]));
  }
  return new Set([...out].filter(value => value.length >= MIN_REPEAT));
}
