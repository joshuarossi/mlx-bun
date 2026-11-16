// Ported from atif-scan 0.8.23 (https://github.com/huggingface/atif-scan, commit 3bbaf3c), src/atif_scan/data/credentials.py.
// Copyright (c) 2026 Hugging Face. MIT License; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// Credential shapes shared by the secret detectors and masking.
//
// Three kinds of evidence:
//
// - Token shapes that are credentials wherever they appear (`sk-…`, `hf_…`, `ghp_…`, AWS key
//   IDs, JWTs, private-key blocks, `LLM|<id>|<token>` harness keys, …).
// - Bearer webhooks: exact Slack/Discord incoming capability targets. Their IDs/tokens are
//   masked wherever repeated.
// - Named values: an assignment whose *name* says it holds a secret (`OPENAI_API_KEY=…`,
//   `"api_key": "…"`, `os.environ["X_TOKEN"] = "…"`, `--api-key …`, `x-api-key: …`). Names are
//   split into components, so `TIKTOKEN_CACHE_DIR` or `MAX_TOKENS` are not secrets, and
//   path/URL/placeholder values (`/root/.ssh/id_rsa`, `${KEY}`, `<your-key>`, `***`) are ignored.
//
// `find` is the broad masking contract, not the exposure predicate. `findExposures` adds
// contextual exclusions for code identifiers and explicit dummy values. Never use exposure
// findings to decide what is safe to publish.
//
// Findings carry spans only; values never leave memory except as masking input.
import * as webhooks from "./webhooks";

export type Span = readonly [number, number];

// The leading lookahead lists every alternative's first character (`-----BEGIN`, sk/pk/rk,
// hf_, gh*_/github_pat_, xox*, AKIA/AIza, eyJ, LLM|): it adds nothing to the match, but lets
// the regex engine skip to candidate positions. Update it with any new alternative.
// Python's `$` also matches before a final newline: `(?=\n?$)`.
const PRIVATE_KEY_SOURCE = String.raw`-----BEGIN [A-Z ]*PRIVATE KEY-----.*?(?:-----END [A-Z ]*PRIVATE KEY-----|(?=\n?$))`;
export const PRIVATE_KEY = new RegExp(PRIVATE_KEY_SOURCE, "s");
export const TOKEN_SHAPES = new RegExp(
  String.raw`(?=[-sprhgxAeL])(?:${PRIVATE_KEY_SOURCE}|` +
    // Real keys carry a digit (`sk-proj-…`, `sk-ant-api03-…`); `rk-free-variables-list` in
    // Lisp code doesn't.
    String.raw`\b(?:sk|pk|rk)-(?=[\w-]*\d)[A-Za-z0-9_-]{16,}|` +
    String.raw`\bhf_[A-Za-z0-9]{20,}|` +
    String.raw`\bgh[pousr]_[A-Za-z0-9]{20,}|` +
    String.raw`\bgithub_pat_[A-Za-z0-9_]{20,}|` +
    String.raw`\bxox[abprs]-[A-Za-z0-9-]{10,}|` +
    String.raw`\bAKIA[0-9A-Z]{16}\b|` +
    String.raw`\bAIza[0-9A-Za-z_-]{35}|` +
    String.raw`\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}|` +
    // Harness-issued model keys (`LLM|<numeric id>|<token>`), seen in leaderboard sandboxes.
    String.raw`\bLLM\|\d{6,}\|[A-Za-z0-9_-]{12,})`,
  "gs",
);

// NAME=value (env output, .env files, `export`), with the value optionally quoted.
// Not a comparison: `if token==prev:` would read "=prev" as the value (TB4 telecom).
const ENV = /(?<![\w$])(?<name>[A-Za-z_][A-Za-z0-9_]*)=(?!=)(?<q>['"]?)(?<value>[^\s'"]+)/dg;
// 'name': 'value' / "name" = "value" / os.environ["NAME"] = "value" / name="value":
// the value must be quoted, so code like `token = tok.encode(x)` isn't a secret.
const KEYED = /(?<![\w-])(?<nq>['"]?)(?<name>[A-Za-z_][\w-]*)\k<nq>\]?\s*[:=]\s*(?<q>['"])(?<value>[^'"\s]+)\k<q>/dg;
// --api-key VALUE / --token=VALUE / x-api-key: VALUE / X-Sandbox-Token: VALUE /
// Authorization: Bearer VALUE (headers, CLI flags). Header values are collected like any
// other secret, so the same token printed bare elsewhere in the trace is masked too
// (hf-sandbox's `X-Sandbox-Token`, a Kubernetes service-account bearer token).
const FLAG = new RegExp(
  // Not inside a hyphenated word: "per-token probabilities", "multi-token approach".
  // The lookahead (first characters of all alternatives) only speeds up scanning.
  String.raw`(?=[-xap])(?:(?<![\w-])--?(?<flag>api[_-]?key|token|password|secret)[= ]\s*|` +
    String.raw`\b(?<header>x-api-key|api-key|x-[a-z0-9-]*token)\s*:\s*|` +
    String.raw`\b(?:proxy-)?authorization\s*:\s*bearer\s+)(?<q>['"]?)(?<value>[^\s'"]+)`,
  "dgi",
);
// Mask supported HTTP authentication carrier roles even when the header key/value are
// quoted JSON/native-tool arguments. This is a privacy superset, not a new exposure
// predicate. Keep the scheme outside the sensitive value for propagation.
const AUTHORIZATION = new RegExp(
  String.raw`(?<![\w-])(?<nq>['"]?)(?:proxy-)?authorization\k<nq>\s*[:=]\s*` +
    String.raw`['"]?(?:Bearer|Basic|Token|Key)[ \t]+(?<value>[^\s'"]{8,})`,
  "dgi",
);
const SECRET_PART = new RegExp(
  String.raw`(?:^|_)(?:api_?key|apikey|secret|token|password|passwd|pwd|credentials?|` +
    String.raw`private_key|access_key|secret_key|session_key|auth_key|key)(?:_|$)`,
);
const NOT_SECRET_PART = new RegExp(
  String.raw`(?:^|_)(?:path|file|dir|url|uri|host|port|name|type|cache|len|length|size|count|` +
    String.raw`max|min|limit|env|header|field|prefix|id|ids|format|mode|var|vars|fn|func|` +
    // `KeyError: 'x'`, `"apiKeySource": "…"`, public site/captcha/Stripe keys in page HTML.
    String.raw`error|source|public|publishable|site|captcha|` +
    // keyUsage, past_key_values, src_key_padding_mask, token_owner, secret_oid, token_chars
    String.raw`usage|values?|mask|padding|owner|oid|chars?|` +
    // Public signing keys (`GPG_KEY=<fingerprint>` in every official python image's env)
    // and database/dict keys: primary_key, foreign_key, sort_key, partition_key, displayKey.
    String.raw`gpg|pgp|fingerprint|primary|sort|partition|display|lookup)(?:_|$)`,
);
// Identifiers, not secrets: `rate_key = "embedding_lr"`, `primaryKey="customerId"`, Redis
// key names (`STATE_KEY = "cutover:state"`), dunder markers, parameter paths
// (`layers.0.mlp.weight`). Letters only (bar numeric path segments), so
// `opaqueCredential98765` or `svc_pass_2026` still count. (Whole value: Python `fullmatch`.)
const IDENTIFIER = new RegExp(
  String.raw`^(?:[a-z]+(?:_[a-z]+)+|[a-z]+(?:[A-Z][a-z]+)+|[a-z_]+(?::[a-z_]+)+|__[a-z_]+__|` +
    String.raw`[a-z_]+(?:\.(?:[a-z_]+|\d+))*\.\d+(?:\.(?:[a-z_]+|\d+))+)$`,
);
const PLACEHOLDER = new RegExp(
  String.raw`^(?:\*+|x+|\.+|<[^>]*>|\$\{?\w+\}?|%\w+%|your[\w-]*|changeme|none|null|nil|` +
    String.raw`true|false|dummy|test\w*|example\w*|placeholder|redacted|masked|secret|password|` +
    String.raw`undefined|sk-\.\.\.|\.\.\.)$`,
  "i",
);
// Code, not secrets: attribute access (`scores.get`, `cv2.contourArea`) and references to
// an environment variable by name (`-password=KEY_PASSWORD`). (Whole value.)
const CODE_VALUE = /^(?:[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)+|[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)+(?:=\S*)?)$/;
const NAME_PARTS = /[_-]+|(?<=[a-z0-9])(?=[A-Z])/;
const LETTER = /\p{L}/u;
const DIGITS = /^\d+$/;

/** Does an assignment name say it holds a secret? Components split on _ - and camelCase. */
export function secretName(name: string): boolean {
  const joined = name.split(NAME_PARTS).filter(Boolean).map(part => part.toLowerCase()).join("_");
  if (joined === "key") return false; // `sorted(x, key=len)`, `const key = "OP_"`: code, not secrets
  return SECRET_PART.test(joined) && !NOT_SECRET_PART.test(joined);
}

/** Shorter values (and all-digit ones) are never treated as secrets. */
export const MIN_SECRET_LENGTH = 8;

/** Historical masking heuristic, retained independently of exposure filtering. */
export function plausibleValue(value: string): boolean {
  if (value.length < MIN_SECRET_LENGTH || PLACEHOLDER.test(value) || DIGITS.test(value)) return false;
  return !codeLike(value) && LETTER.test(value);
}

/** A path, URL, substitution, code expression or bare identifier (non-empty value). */
function codeLike(value: string): boolean {
  return (
    "/~.".includes(value[0]!) ||
    value.includes("://") ||
    value.startsWith("$(") ||
    value.startsWith("`") ||
    /[()[\]{}<>\\]/.test(value) ||
    value.endsWith(",") ||
    CODE_VALUE.test(value) ||
    IDENTIFIER.test(value)
  );
}

// These exclusions apply only to exposure findings, never to masking. A generic "key" can
// be a lookup/schema key; explicit authentication components take priority.
const AUTH_PARTS: ReadonlySet<string> = new Set([
  "api", "apikey", "secret", "token", "password", "passwd", "pwd", "credential", "credentials", "private", "access", "session", "auth",
]);
const LOOKUP_PARTS: ReadonlySet<string> = new Set([
  // Configuration and descriptive metadata keys.
  "setting", "settings", "enabled", "analysis", "description", "options",
  // Message routing, merge selectors and relational schema keys.
  "routing", "merge", "foreign",
  "match", // record-matching selectors, not authentication keys
  // Scoped registries, plugin registries, object handles and map selectors.
  // Match components, not particular task identifiers or adjacent word pairs.
  "scope", "plugin", "handle", "map",
]);

// Whole-value semantics, not prefixes: "testament..." and arbitrary credentials beginning
// with "test" are still possible secrets. A test directory is not evidence.
const LITERAL_PLACEHOLDER = new RegExp(
  String.raw`^(?:\*+|x+|\.+|<[^>]*>|\$\{?\w+\}?|%\w+%|your[\w-]*|changeme|` +
    String.raw`none|null|nil|true|false|dummy|test|example|placeholder|redacted|masked|` +
    String.raw`secret|password|undefined|sk-\.\.\.)$`,
  "i",
);
const DUMMY_CREDENTIAL = new RegExp(
  String.raw`^(?:sk[-_])?(?:dummy|test|example|fake|placeholder)[-_]` +
    String.raw`(?:(?:api|access|auth|secret)[-_])?(?:key|token|secret|password)` +
    String.raw`(?:[-_](?:\d+|dummy|test|example|fake|placeholder))?$`,
  "i",
);
const PEM_PLACEHOLDER = new RegExp(
  String.raw`^-----BEGIN (?<label>[A-Z ]*PRIVATE KEY)-----\s*` +
    String.raw`(?:\.{3}|…|<[^<>\r\n]*>)\s*` +
    String.raw`-----END \k<label>-----$`,
);
// These exact public algorithm identifiers overlap the broad sk-* token mask.
// Require the full OpenSSH name and boundary, not a prefix that could hide a key.
const PUBLIC_SSH_ALGORITHM_SOURCE =
  String.raw`(?<![\w@.-])sk-(?:ssh-ed25519|ecdsa-sha2-nistp256)(?:-cert-v01)?@openssh\.com(?![\w@.-])`;
const PUBLIC_SSH_ALGORITHM_AT = new RegExp(PUBLIC_SSH_ALGORITHM_SOURCE, "y");
const PUBLIC_SSH_ALGORITHM_WHOLE = new RegExp(`^${PUBLIC_SSH_ALGORITHM_SOURCE}$`);

function exposureName(name: string): boolean {
  if (!secretName(name)) return false;
  // Also split acronym-to-word boundaries (e.g. APIKey).
  const split = name.replace(/([A-Z]+)([A-Z][a-z])/g, "$1_$2");
  const parts = new Set(split.split(NAME_PARTS).map(part => part.toLowerCase()));
  for (const part of parts) if (AUTH_PARTS.has(part)) return true;
  for (const part of parts) if (LOOKUP_PARTS.has(part)) return false;
  return true;
}

// Tokenizer pieces: byte-level BPE marks a leading space `Ġ` and a newline `Ċ`,
// SentencePiece a word start `▁`. Regression (TB2.1 gpt2-codegolf, DeepSeek): reasoning
// about GPT-2's vocabulary, `token: "ĠWARRANT"`, read as a secret-named value. No issued
// key holds these characters.
const TOKENIZER_PIECE = /[\u0120\u010a\u2581]/;

function exposureValue(value: string): boolean {
  // Keep the historical length/numeric boundary: collected values are replaced globally
  // in prompts and citations, not just at the assignment site.
  if (value.length < MIN_SECRET_LENGTH || DIGITS.test(value)) return false;
  if (TOKENIZER_PIECE.test(value)) return false;
  if (LITERAL_PLACEHOLDER.test(value) || DUMMY_CREDENTIAL.test(value) || PUBLIC_SSH_ALGORITHM_WHOLE.test(value)) return false;
  return !codeLike(value) && LETTER.test(value);
}

const maskedValue = (value: string): boolean => plausibleValue(value) || exposureValue(value);

export interface Found {
  /** "token", "webhook", "authorization" (mask-only), or "named". */
  readonly kind: "token" | "webhook" | "authorization" | "named";
  /** Where to point a citation: the name for named values. */
  readonly span: Span;
  /** The secret itself (masked in citations). */
  readonly value: Span;
}

const whole = (match: RegExpMatchArray): Span => [match.index!, match.index! + match[0].length];
const group = (match: RegExpMatchArray, name: string): Span => match.indices!.groups![name]!;

/** Broad masking candidates, token shapes first; spans may overlap.
 *
 * Preserves the historical candidates even when exposure context excludes them. Also
 * includes opaque test-prefixed values, with the same length/numeric limits. Use
 * `findExposures` for detector findings, not this privacy-oriented API. */
export function* find(text: string): Generator<Found> {
  if (!text) return;
  for (const match of text.matchAll(TOKEN_SHAPES)) yield { kind: "token", span: whole(match), value: whole(match) };
  for (const [span, value] of webhooks.find(text)) yield { kind: "webhook", span, value };
  for (const match of text.matchAll(AUTHORIZATION)) yield { kind: "authorization", span: whole(match), value: group(match, "value") };
  yield* named(text, secretName, maskedValue);
}

/** Context-aware review findings; deliberately narrower than masking candidates.
 *
 * Known token shapes override non-secret assignment names. Self-contained dummy tokens,
 * placeholder-only closed PEM blocks and exact public OpenSSH algorithm names are excluded.
 * Incomplete/suspicious PEM blocks remain review candidates. */
export function* findExposures(text: string): Generator<Found> {
  for (const match of text.matchAll(TOKEN_SHAPES)) {
    const value = match[0];
    PUBLIC_SSH_ALGORITHM_AT.lastIndex = match.index;
    const algorithm = PUBLIC_SSH_ALGORITHM_AT.test(text);
    PUBLIC_SSH_ALGORITHM_AT.lastIndex = 0;
    if (!DUMMY_CREDENTIAL.test(value) && !PEM_PLACEHOLDER.test(value) && !algorithm) yield { kind: "token", span: whole(match), value: whole(match) };
  }
  for (const [span, value] of webhooks.find(text, true)) yield { kind: "webhook", span, value };
  yield* named(text, exposureName, exposureValue);
}

/** Secret-named assignments (`secret` names, `plausible` values) and secret flags. */
function* named(text: string, secret: (name: string) => boolean, plausible: (value: string) => boolean): Generator<Found> {
  for (const pattern of [ENV, KEYED])
    for (const match of text.matchAll(pattern))
      if (secret(match.groups!.name!) && plausible(match.groups!.value!)) yield { kind: "named", span: group(match, "name"), value: group(match, "value") };
  for (const match of text.matchAll(FLAG))
    if (plausible(match.groups!.value!)) yield { kind: "named", span: whole(match), value: group(match, "value") };
}

/** Distinct credential values in `texts`: used to mask the same secret wherever it
 * reappears (a bare value printed on its own line, copied into code). */
export function values(texts: Iterable<string>): Set<string> {
  const out = new Set<string>();
  for (const text of texts) {
    for (const value of webhooks.values(text)) out.add(value);
    for (const found of find(text)) out.add(text.slice(found.value[0], found.value[1]));
  }
  return new Set([...out].filter(value => value.length >= MIN_SECRET_LENGTH));
}

const bySpan = (a: Span, b: Span): number => a[0] - b[0] || a[1] - b[1];

/** Replace every credential value (and any `known` value) with `***`. */
export function mask(text: string, known: Iterable<string> = []): string {
  const spans: Span[] = [...find(text)].map(found => found.value).sort(bySpan);
  const local = new Set([...known, ...webhooks.values(text)]);
  for (const match of text.matchAll(AUTHORIZATION)) local.add(match.groups!.value!);
  local.delete("");
  for (const value of [...local].sort((a, b) => b.length - a.length)) {
    for (let start = text.indexOf(value); start !== -1; start = text.indexOf(value, start + 1)) spans.push([start, start + value.length]);
  }
  if (!spans.length) return text;
  spans.sort(bySpan);
  const merged: [number, number][] = [];
  for (const [start, end] of spans) {
    const last = merged[merged.length - 1];
    if (last !== undefined && start <= last[1]) last[1] = Math.max(last[1], end);
    else merged.push([start, end]);
  }
  let out = "";
  let last = 0;
  for (const [start, end] of merged) {
    out += text.slice(last, start);
    out += text.slice(start, end).startsWith("-----BEGIN") ? "[private key]" : "***";
    last = end;
  }
  return out + text.slice(last);
}
