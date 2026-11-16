// Ported from atif-scan 0.8.23 (https://github.com/huggingface/atif-scan, commit 3bbaf3c), src/atif_scan/detectors/web_opens.py,
// with what it reads from src/atif_scan/data/web_inputs.py and src/atif_scan/data/web_results.py.
// Copyright (c) 2026 Hugging Face. MIT License; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// Web opens that name only a reference, read from their results.
//
// Codex's web tool opens a page by a reference to an earlier result (`{"open": [{"ref_id":
// "turn0search3"}]}`), so the call records no URL: its URL field is unreadable by design. The
// opened page's URL is in the open's own result, whose header names it (`Title (URL)`, then
// citation metadata naming the open). Reference IDs aren't resolved through earlier search
// results: exports can omit those or reuse IDs across compactions. An open whose result names
// no page (an error, nothing recorded) stays unresolved: what it opened is unknown.
//
// Not ported: a result recorded as a serialized list of content blocks (a JSON or Python repr
// of `[{"type": "text", "text": …}]`, as Codex code mode records). atif-scan unwraps it with
// Python's `ast` module; here such a result reads as atif-scan reads one it cannot parse:
// no text and no content, so an open by reference with that result stays unresolved. Media
// in a result and tool programs (`call.web_input`) do not exist in a guard trace.
import type { Content, Locator, Step, ToolCall, Trace } from "../model";

// --- data/web_inputs.py ----------------------------------------------------------------

const REFERENCE = /^turn\d+(?:search|view)\d+$/;

export interface WebInput {
  readonly recorded: boolean;
  readonly sourceKnown: boolean;
}

const input = (recorded: boolean, sourceKnown: boolean): WebInput => ({ recorded, sourceKnown });
const isObject = (value: unknown): value is Record<string, unknown> => typeof value === "object" && value !== null && !Array.isArray(value);

// Python `str.strip()` whitespace.
// eslint-disable-next-line no-control-regex
const EDGE_SPACE = /^[\t-\r\x1c-\x20\x85\xa0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]+|[\t-\r\x1c-\x20\x85\xa0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]+$/g;

/** Python `str.strip()`. */
export const strip = (text: string): string => text.replace(EDGE_SPACE, "");

function target(value: unknown): WebInput {
  if (typeof value !== "string" || !strip(value)) return input(false, false);
  if (value.startsWith("https://") || value.startsWith("http://")) return input(true, true);
  // Historical exports can omit the reference-producing result, or reuse IDs across
  // compactions. Literal IDs prove an input, never a unique source link.
  return input(REFERENCE.test(value), false);
}

function entry(action: string, value: unknown): WebInput {
  if (!isObject(value)) return input(false, false);
  if (action === "search_query") {
    const known = typeof value.q === "string" && strip(value.q) !== "";
    return input(known, known);
  }
  return target("ref_id" in value ? value.ref_id : "reference_id" in value ? value.reference_id : value.url);
}

/** Read only recognized action envelopes; arbitrary nested prose is not input. */
export function parseWebInput(name: string, args: unknown): WebInput | null {
  if (name !== "web__run" && name !== "web.run") return null;
  if (!isObject(args)) return input(false, false);
  const rows: WebInput[] = [];
  for (const action of ["search_query", "open", "click", "find"]) {
    if (!(action in args)) continue;
    const batch = args[action];
    if (!Array.isArray(batch) || !batch.length) rows.push(input(false, false));
    else for (const item of batch) rows.push(entry(action, item));
  }
  return input(rows.length > 0 && rows.every(row => row.recorded), rows.length > 0 && rows.every(row => row.sourceKnown));
}

export function webInput(call: ToolCall): WebInput {
  const parsed = parseWebInput(call.name, call.arguments);
  if (parsed !== null) return parsed;
  const wanted = call.tool === "web_search" ? "query" : "url";
  const fields = call.fields.filter(([channel]) => channel === wanted).map(([, value]) => value);
  const known = fields.length > 0 && fields.every(value => value.understood && strip(value.text) !== "");
  return input(known, known);
}

// --- data/web_results.py ---------------------------------------------------------------

// A provider acknowledgement is status metadata, not the page/search body.
const STATUS_ONLY = /^\s*(?:status\s*[:=]\s*)?(?:ok|success|successful|done|completed|pending|running)\s*[.!]?\s*$/i;
const RUNNER = new RegExp(
  String.raw`^Script[ \t]+completed[.!]?[ \t]*(?:\r?\n` +
    String.raw`[ \t]*Wall[ \t]+time[ \t]*:?[ \t]*\d+(?:\.\d+)?[ \t]+seconds[ \t]*)?` +
    String.raw`(?:\r?\n[ \t]*Output:[ \t]*(?<body>[\s\S]*))?\s*$`,
  "i",
);
// Deliberately anchored: prose mentioning a failed fetch is still page content.
const RETRIEVAL_ERROR = new RegExp(
  String.raw`^(?:` +
    String.raw`(?:status\s*[:=]\s*)?(?:error|failed)[.!]?` +
    String.raw`|(?:Error|Web(?:Fetch|Search)Error|HTTPError)\s*:\s*\S[^\r\n]*` +
    String.raw`|(?:failed|unable) to (?:fetch|retrieve|open|access|download)\b[^\r\n]*` +
    String.raw`|(?:fetch|retrieval|web search|request) failed\b[^\r\n]*` +
    String.raw`|HTTP(?: error)?\s+[45]\d\d(?:\s+[^\r\n]+)?` +
    String.raw`)$`,
  "i",
);
// Provider error envelopes require a whole header and citation/source metadata.
// A page merely discussing internal errors or unresolved clicks is not an error.
const PROVIDER_METADATA = new RegExp(
  String.raw`^\ue200cite\ue202turn\d+[a-z]+\d+\ue201` +
    String.raw`[ \t]+\[wordlim: \d+\][ \t]+Source:[ \t]+` +
    String.raw`(?:find|open|click|search)\(\{[^\r\n]*\}\)[^\r\n]*$`,
);
const CLICK_ERROR = /^Unable to resolve click call\b[^\r\n]*$/i;
// A serialized content-block envelope ([{"type": "text", "text": ...}, ...], as JSON or a
// Python repr), or an empty one. Only a known block type opens it: a JSON API body that
// is an array of records (GitHub contents, Hub trees with "type": "file") is page text.
const BLOCK_TYPES = "text|input_text|output_text|image|input_image|image_url|refusal|resource|audio|input_audio";
const SERIALIZED_BLOCKS = new RegExp(String.raw`^\[\s*(?:]\s*$|\{\s*['"]type['"]\s*:\s*['"](?:${BLOCK_TYPES})['"])`);
// Python `str.splitlines()` boundaries.
// eslint-disable-next-line no-control-regex
const LINE_BREAK = /\r\n|[\n\r\v\f\x1c\x1d\x1e\x85\u2028\u2029]/;

/** Evidence available in one result, not a claim of successful retrieval. */
export type WebResultState = "unavailable" | "status_only" | "error" | "content";

function splitlines(text: string): string[] {
  const lines = text.split(LINE_BREAK);
  if (lines[lines.length - 1] === "") lines.pop();
  return lines;
}

function providerError(text: string): boolean {
  const lines = splitlines(text);
  if (lines.length < 2) return false;
  if (lines[0] === "Internal Error ()") return PROVIDER_METADATA.test(lines[1]!);
  // Some providers place the explicit click failure after citation metadata.
  return PROVIDER_METADATA.test(lines[0]!) && CLICK_ERROR.test(lines[1]!);
}

function textState(value: string): WebResultState {
  let text = strip(value);
  const wrapper = RUNNER.exec(text);
  if (wrapper) {
    text = strip(wrapper.groups?.body ?? "");
    if (!text) return "status_only";
  }
  if (!text) return "unavailable";
  if (STATUS_ONLY.test(text)) return "status_only";
  return RETRIEVAL_ERROR.test(text) || providerError(text) ? "error" : "content";
}

/** Classify readable result evidence, retaining unknown and wrapper gaps. */
export function webResultState(content: Content): WebResultState {
  if (!content.understood) return "unavailable";
  const text = strip(content.text);
  // Not ported: the block envelope is read as one atif-scan could not parse.
  if (SERIALIZED_BLOCKS.test(text)) return "unavailable";
  return textState(text);
}

/** Only meaningful, understood text can clear a returned-content predicate. */
export const recordedWebContent = (content: Content): boolean => webResultState(content) === "content";

/** A result's readable text; "" when the result isn't readable (or is a serialized block
 * envelope, which is not unwrapped here). */
export function recordedText(content: Content): string {
  if (!content.understood) return "";
  const text = strip(content.text);
  return SERIALIZED_BLOCKS.test(text) ? "" : text;
}

// --- detectors/web_opens.py ------------------------------------------------------------

// A Codex `open` result's header: `Title (URL)` then citation metadata naming the open.
// A program that prints `JSON.stringify(r)` leaves the line break escaped (`\\n`).
export const OPENED_PAGE = new RegExp(
  String.raw`\((https?://[^\s)\\]+)\)\s*(?:\n|\\n)\ue200cite\ue202turn\d+view\d+\ue201[^\n]{0,200}?Source:\s*open\(`,
  "g",
);

/** A fetch that names only a reference (`turn0search8`), not a URL. */
export function byReference(call: ToolCall): boolean {
  return call.tool === "web_fetch" && !webInput(call).sourceKnown;
}

export interface Opened {
  readonly url: string;
  /** The URL in the result (the whole result when it can't be placed). */
  readonly at: Locator;
}

/** The pages an open's results name, read from the result's text. */
export function* opened(step: Step, call: ToolCall): Generator<Opened> {
  for (const [observation, result] of step.resultsFor(call)) {
    for (const match of recordedText(result.content).matchAll(OPENED_PAGE)) {
      const url = match[1]!;
      const start = result.content.text.indexOf(url);
      const at: Locator = { step: step.index, channel: "observation", observation };
      yield { url, at: start >= 0 ? { ...at, span: [start, start + url.length] } : at };
    }
  }
}

/** An open by reference whose result names no page (an error, nothing recorded). */
export function unresolved(step: Step, call: ToolCall): boolean {
  if (!byReference(call)) return false;
  const results = step.resultsFor(call);
  return !results.length || !results.every(([, result]) => recordedWebContent(result.content));
}

/** Every open by reference in the agent's calls. */
export function* referenceOpens(trace: Trace): Generator<[Step, ToolCall]> {
  for (const [step, call] of trace.agentCalls()) if (byReference(call)) yield [step, call];
}
