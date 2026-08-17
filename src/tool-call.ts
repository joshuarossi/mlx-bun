// Gemma 4 tool-call parsing — port of mlx-lm tool_parsers/gemma4.py.
//
// The model emits   <|tool_call>call:name{key:value,...}<tool_call|>
// where strings are delimited by the <|"|> special token, keys are bare,
// and numbers/bools/objects/arrays are JSON-ish. After its tool_call
// blocks the model emits <|tool_response> (token 50, in the EOS set) —
// the request to the runtime for results.
//
// Token ids (tokenizer.json added_tokens; stable for this family):
//   <|tool_call> 48   <tool_call|> 49   <|tool_response> 50   <|"|> 52
//   <|channel> 100   <channel|> 101  (reasoning channel; see CHANNEL_* below)

export const TOOL_CALL_START = 48;
export const TOOL_CALL_END = 49;
export const TOOL_RESPONSE_START = 50;

/** Gemma 4 reasoning channel sentinels. With thinking on, the model wraps its
 *  chain-of-thought as  <|channel>thought\n…<channel|>  before the final
 *  answer. soc_token=`<|channel>` (100), eoc_token=`<channel|>` (101). These
 *  are special tokens stripped at decode, so reasoning must be split at the
 *  TOKEN level (ToolAwareStream), not from decoded text. */
export const CHANNEL_START = 100;
export const CHANNEL_END = 101;

const QUOTE = '<|"|>';

export interface ParsedToolCall {
  name: string;
  /** Parsed argument object (callers serialize for OpenAI's string field). */
  arguments: Record<string, unknown>;
  /** Set only when strict parsing failed and a repair pass recovered the
   *  call — never silent (Axis 7 self-healing beat row). `repairs` lists
   *  every malformation class that had to be corrected, in application
   *  order, so failures are observable (logs/telemetry) instead of masked. */
  repaired?: true;
  repairs?: RepairKind[];
}

interface ToolSpec {
  function?: { name?: string; parameters?: Record<string, unknown> };
  name?: string;
}

/** Convert gemma4 argument syntax to JSON: extract <|"|>-strings to
 *  placeholders, quote bare keys, restore strings JSON-escaped. */
export function gemmaArgsToJson(text: string): string {
  const strings: string[] = [];
  let out = "";
  let i = 0;
  while (i < text.length) {
    const start = text.indexOf(QUOTE, i);
    if (start === -1) {
      out += text.slice(i);
      break;
    }
    const end = text.indexOf(QUOTE, start + QUOTE.length);
    if (end === -1) throw new Error("unterminated <|\"|> string");
    out += text.slice(i, start) + `\x00${strings.length}\x00`;
    strings.push(text.slice(start + QUOTE.length, end));
    i = end + QUOTE.length;
  }
  // quote bare keys (after { or ,)
  out = out.replace(/([{,])\s*([\w-]+)\s*:/g, (_, pre, key) => `${pre}${JSON.stringify(key)}:`);
  // restore strings as JSON literals
  out = out.replace(/\x00(\d+)\x00/g, (_, n) => JSON.stringify(strings[Number(n)]!));
  return out;
}

/** Parse every `call:name{...}` block in a decoded tool-call segment.
 *
 *  Strict scan first (unchanged behavior on well-formed input). On the two
 *  ways a small model mangles THIS family's syntax specifically —
 *  (a) generation truncated mid-call (an unterminated `<|"|>` string or a
 *  brace that never closes, both hit_max_tokens artifacts) and (b) a
 *  trailing comma surviving `gemmaArgsToJson`'s conversion to JSON — the
 *  repair pass recovers by treating "ran off the end of the text" as an
 *  implicit close (mirrors closeUnbalanced's brace-stack unwind, adapted
 *  for the `<|"|>`-quoted syntax) and re-running stripTrailingCommas on the
 *  converted JSON. Recovered calls are tagged repaired/repairs; a segment
 *  that still can't be recovered throws exactly as before. */
export function parseToolCalls(text: string): ParsedToolCall[] {
  const calls: ParsedToolCall[] = [];
  let i = 0;
  while (i < text.length) {
    const m = /call:([\w-]+)\{/.exec(text.slice(i));
    if (!m) break;
    const nameEnd = i + m.index + m[0].length - 1; // position of '{'
    // balanced-brace scan, skipping <|"|>-delimited strings
    let depth = 0;
    let j = nameEnd;
    let unterminatedString = false;
    while (j < text.length) {
      if (text.startsWith(QUOTE, j)) {
        const close = text.indexOf(QUOTE, j + QUOTE.length);
        if (close === -1) { unterminatedString = true; break; }
        j = close + QUOTE.length;
        continue;
      }
      const c = text[j];
      if (c === "{") depth++;
      else if (c === "}") {
        depth--;
        if (depth === 0) break;
      }
      j++;
    }
    const truncated = unterminatedString || depth !== 0;
    let argsBlock: string;
    const repairs: RepairKind[] = [];
    if (truncated) {
      // Ran off the end of the text without closing — truncated generation.
      // Close the dangling <|"|> string (if any) then append enough `}` to
      // balance whatever braces are still open, using the SAME depth
      // counter's remaining value (skip <|"|>-quoted spans again so a
      // brace character inside a string doesn't miscount).
      let closeDepth = 0;
      let k = nameEnd;
      let inQuote = false;
      while (k < text.length) {
        if (text.startsWith(QUOTE, k) && !inQuote) { inQuote = true; k += QUOTE.length; continue; }
        if (inQuote) {
          if (text.startsWith(QUOTE, k)) { inQuote = false; k += QUOTE.length; continue; }
          k++;
          continue;
        }
        const c = text[k];
        if (c === "{") closeDepth++;
        else if (c === "}") closeDepth--;
        k++;
      }
      argsBlock = text.slice(nameEnd) + (inQuote ? QUOTE : "") + "}".repeat(Math.max(closeDepth, 1));
      repairs.push("unbalanced_braces");
      j = text.length - 1;
    } else {
      argsBlock = text.slice(nameEnd, j + 1);
    }
    let converted = gemmaArgsToJson(argsBlock);
    let parsed: unknown;
    try {
      parsed = JSON.parse(converted);
    } catch {
      const commas = stripTrailingCommas(converted);
      if (!commas.changed) throw new Error("unbalanced braces in tool call");
      try {
        parsed = JSON.parse(commas.out);
      } catch {
        throw new Error("unbalanced braces in tool call");
      }
      converted = commas.out;
      repairs.push("trailing_commas");
    }
    calls.push({
      name: m[1]!,
      arguments: parsed as Record<string, unknown>,
      ...(repairs.length ? { repaired: true, repairs } : {}),
    });
    i = j + 1;
  }
  return calls;
}

const TOOL_CALL_BLOCK_RE = /<tool_call>\s*([\s\S]*?)\s*<\/tool_call>/gi;
const XML_FUNCTION_EQUALS_RE = /^\s*<function=([^>\s]+)>\s*([\s\S]*?)\s*<\/function>\s*$/i;
const XML_PARAMETER_EQUALS_RE = /<parameter=([^>\s]+)>\s*([\s\S]*?)\s*<\/parameter>/gi;
const GLM52_ARG_KEY_RE = /<arg_key>/i;
const GLM52_ARG_PAIR_RE = /<arg_key>\s*([\s\S]*?)\s*<\/arg_key>\s*<arg_value>\s*([\s\S]*?)\s*<\/arg_value>/gi;
const XML_FUNCTION_ATTR_RE = /<function\s+name=["']([^"']+)["']\s*>\s*([\s\S]*?)\s*<\/function>/gi;
// CDATA alternative first so a `</param>` inside a CDATA block never
// terminates the value early.
const XML_PARAM_ATTR_RE = /<param\s+name=["']([^"']+)["']\s*>((?:<!\[CDATA\[[\s\S]*?\]\]>|[\s\S])*?)<\/param>/gi;

function toolSpecName(tool: ToolSpec): string | null {
  const name = tool.function?.name ?? tool.name;
  return typeof name === "string" && name.trim() ? name.trim() : null;
}

function decodeXml(text: string): string {
  return text
    .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, "$1")
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&amp;/g, "&")
    .trim();
}

/** JSON-schema type names for a parameter (handles `type: [..]` unions). */
function schemaTypeNames(schema: unknown): Set<string> {
  if (!schema || typeof schema !== "object") return new Set();
  const raw = (schema as Record<string, unknown>).type;
  if (typeof raw === "string") return new Set([raw]);
  if (Array.isArray(raw)) return new Set(raw.filter((t): t is string => typeof t === "string"));
  return new Set();
}

function toolParameterSchema(
  tools: ToolSpec[], toolName: string, parameterName: string,
): Record<string, unknown> | null {
  for (const tool of tools) {
    if (toolSpecName(tool) !== toolName) continue;
    const params = tool.function?.parameters ?? (tool as Record<string, any>).parameters;
    const props = params && typeof params === "object"
      ? (params as Record<string, any>).properties : null;
    const schema = props && typeof props === "object" ? props[parameterName] : null;
    return schema && typeof schema === "object" ? schema : null;
  }
  return null;
}

/** Oracle `_decode_tool_parameter_value`: string-typed params stay raw
 *  text (a path like "2025" must not become a number); everything else
 *  is JSON-decoded when possible. */
function decodeToolValue(value: string, schema: Record<string, unknown> | null): unknown {
  const text = decodeXml(value);
  if (!text) return "";
  const types = schemaTypeNames(schema);
  if (types.size && [...types].every((t) => t === "string" || t === "null")) return text;
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

// ---- Repair layer (Axis 7 self-healing beat row) ---------------------
//
// pi-ai (node_modules/@earendil-works/pi-ai/dist/utils/json-parse.js)
// already ships a generic JSON repair pass for cloud-model streaming
// tool calls: `repairJson`/`parseJsonWithRepair` fix invalid backslash
// escapes and raw control characters inside strings, and
// `parseStreamingJson` falls back to the `partial-json` package for
// truncated mid-stream JSON. Its `validateToolArguments`
// (utils/validation.js) additionally coerces JSON-Schema primitive
// TYPES (string "3" -> number 3, etc.) once a call is already
// structurally valid JSON. None of that touches the STRUCTURAL
// malformations small local models actually produce here: single
// quotes instead of double, trailing commas, unbalanced/truncated
// braces, a whole call wrapped in a markdown ```json fence, stray
// prose ("Sure, here's the call:") glued in front of the JSON, or the
// function name landing inside `arguments` instead of the envelope
// (toolCallFromPayload above already handles that last one for
// already-valid JSON — the repair pass below reuses it once the text
// is coerced to valid JSON). This layer is therefore purely additive
// to pi-ai's, applied ONLY when strict parsing has already failed, and
// every repair is tagged on the returned ParsedToolCall (`repaired`,
// `repairs`) rather than silently swallowed — see ParsedToolCall above.
export type RepairKind =
  | "fenced_wrapper" // ```json ... ``` or ``` ... ``` wrapper stripped
  | "prose_prefix" // leading non-JSON prose trimmed to the first { or [
  | "single_quotes" // 'like this' -> "like this" (keys and string values)
  | "trailing_commas" // {"a":1,} / [1,2,] -> valid JSON
  | "unbalanced_braces" // truncated generation: missing closing }/]/" appended
  | "python_literals" // True/False/None -> true/false/null
  | "name_in_args"; // function name found inside `arguments` instead of the envelope

/** Strip a ```json fenced block (or bare ```) wrapping the whole payload. */
function stripFence(text: string): { out: string; changed: boolean } {
  const m = /^\s*```(?:json)?\s*\n?([\s\S]*?)\n?```\s*$/i.exec(text.trim());
  if (!m) return { out: text, changed: false };
  return { out: m[1] ?? "", changed: true };
}

/** Trim stray prose before the first `{`/`[` and after the matching
 *  document's last `}`/`]` (a small model narrating "Sure, here's the
 *  call: {...}" or trailing chatter after the JSON). Leaves the text
 *  alone if it doesn't start with prose (no-op safe to always run). */
function stripProsePrefix(text: string): { out: string; changed: boolean } {
  const trimmed = text.trim();
  const firstBrace = trimmed.search(/[{[]/);
  if (firstBrace <= 0) return { out: trimmed, changed: false };
  // Only strip when what precedes genuinely looks like prose (no braces
  // of its own) — never chew into legitimate leading whitespace-only JSON.
  const prefix = trimmed.slice(0, firstBrace);
  if (/[{}[\]]/.test(prefix)) return { out: trimmed, changed: false };
  const lastClose = Math.max(trimmed.lastIndexOf("}"), trimmed.lastIndexOf("]"));
  const out = lastClose >= firstBrace ? trimmed.slice(firstBrace, lastClose + 1) : trimmed.slice(firstBrace);
  return { out, changed: true };
}

/** Convert Python-ish literals (True/False/None) used outside string
 *  literals into JSON ones. Scans char-by-char tracking string state so
 *  a value like "Nonetheless" or a string containing "True" is untouched. */
function pythonLiteralsToJson(text: string): { out: string; changed: boolean } {
  let out = "";
  let changed = false;
  let inString: '"' | "'" | null = null;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i]!;
    if (inString) {
      out += ch;
      if (ch === "\\") { out += text[++i] ?? ""; continue; }
      if (ch === inString) inString = null;
      continue;
    }
    if (ch === '"' || ch === "'") { inString = ch; out += ch; continue; }
    const rest = text.slice(i);
    const wordMatch = /^(True|False|None)\b/.exec(rest);
    if (wordMatch) {
      const replacement = wordMatch[1] === "True" ? "true" : wordMatch[1] === "False" ? "false" : "null";
      out += replacement;
      i += wordMatch[1]!.length - 1;
      changed = true;
      continue;
    }
    out += ch;
  }
  return { out, changed };
}

/** Convert single-quoted JSON (keys and string values) to double-quoted,
 *  tracking string state so an apostrophe INSIDE a double-quoted string
 *  (e.g. "don't") is left alone. Only fires when the text has no double
 *  quotes at all in "quote position" — i.e. looks like it was written
 *  with single quotes throughout — to avoid mangling a string that
 *  legitimately contains a single quote inside double-quoted JSON. */
function singleQuotesToDouble(text: string): { out: string; changed: boolean } {
  if (!/'/.test(text)) return { out: text, changed: false };
  // Heuristic gate: real JSON never opens a key/value with a bare `'`.
  // If the text already parses with plain JSON.parse it wouldn't have
  // reached here, so any '"'-delimited string is assumed intentional and
  // left byte-for-byte; only '...'-delimited runs are retargeted.
  let out = "";
  let changed = false;
  let inDouble = false;
  let inSingle = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i]!;
    if (inDouble) {
      out += ch;
      if (ch === "\\") { out += text[++i] ?? ""; continue; }
      if (ch === '"') inDouble = false;
      continue;
    }
    if (inSingle) {
      if (ch === "\\") { out += ch + (text[++i] ?? ""); continue; }
      if (ch === "'") { out += '"'; inSingle = false; continue; }
      if (ch === '"') { out += '\\"'; continue; } // embedded " must be escaped now
      out += ch;
      continue;
    }
    if (ch === '"') { inDouble = true; out += ch; continue; }
    if (ch === "'") { inSingle = true; changed = true; out += '"'; continue; }
    out += ch;
  }
  return { out, changed };
}

/** Remove trailing commas before a closing `}`/`]` (whitespace/newlines
 *  between the comma and the close are preserved otherwise). */
function stripTrailingCommas(text: string): { out: string; changed: boolean } {
  let changed = false;
  const out = text.replace(/,(\s*[}\]])/g, (_m, close) => { changed = true; return close; });
  return { out, changed };
}

/** Append the minimal closers to balance braces/brackets/an unterminated
 *  string — a small model that got truncated (or just stopped early)
 *  mid-object. Walks once tracking a stack of open delimiters and string
 *  state; on EOF, closes the open string (if any) then unwinds the stack
 *  in reverse. No-op (unchanged) when already balanced. */
function closeUnbalanced(text: string): { out: string; changed: boolean } {
  const stack: ("}" | "]")[] = [];
  let inString = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i]!;
    if (inString) {
      if (ch === "\\") { i++; continue; }
      if (ch === '"') inString = false;
      continue;
    }
    if (ch === '"') { inString = true; continue; }
    if (ch === "{") stack.push("}");
    else if (ch === "[") stack.push("]");
    else if (ch === "}" || ch === "]") stack.pop();
  }
  if (!inString && stack.length === 0) return { out: text, changed: false };
  let out = text;
  if (inString) out += '"';
  out += stack.reverse().join("");
  return { out, changed: true };
}

/** Try strict JSON.parse first (pi-ai's own escape-level repair already
 *  ran upstream where applicable — see the comment above); on failure,
 *  apply the structural repair passes in order, re-testing after each so
 *  only the ones that were actually needed get tagged. Returns null (no
 *  throw) when nothing recovers a parseable object — callers decide how
 *  to surface that. */
function repairJsonToolText(text: string): { value: unknown; repairs: RepairKind[] } | null {
  const repairs: RepairKind[] = [];
  let candidate = text;

  const fence = stripFence(candidate);
  if (fence.changed) { candidate = fence.out; repairs.push("fenced_wrapper"); }

  const prose = stripProsePrefix(candidate);
  if (prose.changed) { candidate = prose.out; repairs.push("prose_prefix"); }

  const tryParse = (s: string): unknown | undefined => {
    try { return JSON.parse(s); } catch { return undefined; }
  };

  let parsed = tryParse(candidate);
  if (parsed !== undefined) return { value: parsed, repairs };

  const literals = pythonLiteralsToJson(candidate);
  if (literals.changed) {
    parsed = tryParse(literals.out);
    if (parsed !== undefined) return { value: parsed, repairs: [...repairs, "python_literals"] };
    candidate = literals.out;
  }

  const commas = stripTrailingCommas(candidate);
  if (commas.changed) {
    parsed = tryParse(commas.out);
    if (parsed !== undefined) return { value: parsed, repairs: [...repairs, "trailing_commas"] };
    candidate = commas.out;
  }

  const closed = closeUnbalanced(candidate);
  if (closed.changed) {
    parsed = tryParse(closed.out);
    if (parsed !== undefined) return { value: parsed, repairs: [...repairs, "unbalanced_braces"] };
    candidate = closed.out;
  }

  const quotes = singleQuotesToDouble(candidate);
  if (quotes.changed) {
    parsed = tryParse(quotes.out);
    if (parsed !== undefined) return { value: parsed, repairs: [...repairs, "single_quotes"] };
    candidate = quotes.out;
    // Single-quote conversion can itself leave a trailing comma or an
    // unbalanced document (e.g. `{'a': 1,}` truncated) — retry those two
    // passes once more on the requoted text before giving up.
    const commas2 = stripTrailingCommas(candidate);
    if (commas2.changed) {
      parsed = tryParse(commas2.out);
      if (parsed !== undefined) return { value: parsed, repairs: [...repairs, "single_quotes", "trailing_commas"] };
      candidate = commas2.out;
    }
    const closed2 = closeUnbalanced(candidate);
    if (closed2.changed) {
      parsed = tryParse(closed2.out);
      if (parsed !== undefined) return { value: parsed, repairs: [...repairs, "single_quotes", "unbalanced_braces"] };
    }
  }

  return null;
}

/** Lenient JSON.parse used for argument STRINGS nested inside an already
 *  JSON-valid envelope (e.g. `"arguments": "{'a': 1}"`, a small model
 *  double-encoding with the wrong quote style). Falls back through the
 *  same repair passes; throws (not silently {}) when nothing recovers,
 *  same contract as JSON.parse for its callers. */
function parseJsonLoose(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch (err) {
    const repaired = repairJsonToolText(text);
    if (repaired) return repaired.value;
    throw err;
  }
}

/** Build a ParsedToolCall from an already-parsed JSON payload (object or
 *  {function:{name,arguments}} envelope). Shared by the strict and
 *  repaired paths so name/arguments extraction logic lives once. Handles
 *  the "name-in-args confusion" malformation: a small model sometimes
 *  emits the function name INSIDE the arguments object instead of (or in
 *  addition to) the envelope's own `name` field — e.g.
 *  {"arguments":{"name":"read","path":"x"}} with no top-level name at
 *  all. When the envelope has no usable name, an args-embedded `name` (or
 *  `function`) string is promoted and stripped out of the arguments. */
function toolCallFromPayload(
  payload: unknown,
): { name: string; arguments: Record<string, unknown>; nameInArgs: boolean } | null {
  if (!payload || typeof payload !== "object") return null;
  const obj = payload as Record<string, any>;
  const fn = obj.function && typeof obj.function === "object" ? obj.function : obj;
  let name = typeof fn.name === "string" ? fn.name.trim() : "";
  let args = fn.arguments ?? obj.arguments ?? {};
  if (typeof args === "string") {
    const parsed = args.trim() ? parseJsonLoose(args) : {};
    args = parsed && typeof parsed === "object" && !Array.isArray(parsed) ? parsed : {};
  }
  if (!args || typeof args !== "object" || Array.isArray(args)) return null;
  const argsObj = { ...(args as Record<string, unknown>) };
  let nameInArgs = false;
  if (!name) {
    const embedded = argsObj.name ?? argsObj.function;
    if (typeof embedded === "string" && embedded.trim()) {
      name = embedded.trim();
      delete argsObj.name;
      delete argsObj.function;
      nameInArgs = true;
    }
  }
  if (!name) return null;
  return { name, arguments: argsObj, nameInArgs };
}

/** Shape guard for the wrapper-less last-resort repair path only (see its
 *  call site in parseGeneratedToolCalls). A `<tool_call>`/`<function...>`
 *  tag already proves the model intended a tool call, so toolCallFromPayload
 *  can be lenient there; a bare JSON object with NO such tag is ambiguous —
 *  it could just as easily be an ordinary conversational reply that happens
 *  to be JSON-shaped (e.g. `{"name": "read", "age": 42}` answering "give me
 *  an example record"). Require an actual envelope shape: a `function`
 *  wrapper object, or a top-level/nested `arguments` object (including the
 *  name-in-args case, where the name lives inside that same `arguments`
 *  object) — never just a bare `name`/`function` string sitting next to
 *  unrelated fields. */
function looksLikeToolEnvelope(payload: unknown): boolean {
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) return false;
  const obj = payload as Record<string, unknown>;
  if (obj.function && typeof obj.function === "object" && !Array.isArray(obj.function)) return true;
  const args = obj.arguments;
  if (args && typeof args === "object" && !Array.isArray(args)) return true;
  if (typeof args === "string") return true; // double-encoded arguments string
  return false;
}

function parseJsonToolCall(block: string): ParsedToolCall | null {
  let payload: unknown;
  let repairs: RepairKind[] = [];
  try {
    payload = JSON.parse(block);
  } catch {
    // Strict JSON.parse failed — this is the ONLY point the syntax-repair
    // pass engages (never attempted when the model emitted valid JSON). A
    // repair failure here returns null (not throw): parseGeneratedToolCalls
    // falls through to the XML parsers next, which is the right behavior
    // for a `<tool_call>` block that isn't actually JSON-shaped at all.
    const repaired = repairJsonToolText(block);
    if (!repaired) return null;
    payload = repaired.value;
    repairs = repaired.repairs;
  }
  if (!payload || typeof payload !== "object") throw new Error("JSON tool_call payload must be an object");
  const result = toolCallFromPayload(payload);
  if (!result) throw new Error("tool_call arguments must be a JSON object");
  if (result.nameInArgs) repairs = [...repairs, "name_in_args"];
  const { nameInArgs: _nameInArgs, ...call } = result;
  return repairs.length ? { ...call, repaired: true, repairs } : call;
}

function parseXmlEqualsToolCall(block: string, tools: ToolSpec[]): ParsedToolCall | null {
  const match = XML_FUNCTION_EQUALS_RE.exec(block);
  XML_FUNCTION_EQUALS_RE.lastIndex = 0;
  if (!match) return null;
  const name = match[1]!.trim();
  const body = match[2]!;
  const args: Record<string, unknown> = {};
  for (const param of body.matchAll(XML_PARAMETER_EQUALS_RE)) {
    const key = param[1]!.trim();
    if (!key) throw new Error(`tool '${name}' contains an empty parameter name`);
    args[key] = decodeToolValue(param[2]!, toolParameterSchema(tools, name, key));
  }
  XML_PARAMETER_EQUALS_RE.lastIndex = 0;
  return { name, arguments: args };
}

function parseGlm52ToolCall(block: string, tools: ToolSpec[]): ParsedToolCall | null {
  const firstArg = block.search(GLM52_ARG_KEY_RE);
  const name = (firstArg < 0 ? block : block.slice(0, firstArg)).trim();
  if (!name || !/^[^\s<>]+$/.test(name)) return null;
  if (firstArg < 0) return { name, arguments: {} };

  const body = block.slice(firstArg);
  const args: Record<string, unknown> = {};
  let cursor = 0;
  let matched = false;
  for (const pair of body.matchAll(GLM52_ARG_PAIR_RE)) {
    if (body.slice(cursor, pair.index).trim()) return null;
    const key = pair[1]!.trim();
    if (!key) throw new Error(`tool '${name}' contains an empty argument name`);
    args[key] = decodeToolValue(pair[2]!, toolParameterSchema(tools, name, key));
    cursor = pair.index + pair[0].length;
    matched = true;
  }
  GLM52_ARG_PAIR_RE.lastIndex = 0;
  if (!matched || body.slice(cursor).trim()) return null;
  return { name, arguments: args };
}

function parseXmlAttrToolCalls(text: string, tools: ToolSpec[]): ParsedToolCall[] {
  const calls: ParsedToolCall[] = [];
  for (const fn of text.matchAll(XML_FUNCTION_ATTR_RE)) {
    const name = fn[1]!.trim();
    const body = fn[2]!;
    const args: Record<string, unknown> = {};
    for (const param of body.matchAll(XML_PARAM_ATTR_RE)) {
      const key = param[1]!.trim();
      if (!key) throw new Error(`tool '${name}' contains an empty parameter name`);
      args[key] = decodeToolValue(param[2]!, toolParameterSchema(tools, name, key));
    }
    XML_PARAM_ATTR_RE.lastIndex = 0;
    calls.push({ name, arguments: args });
  }
  XML_FUNCTION_ATTR_RE.lastIndex = 0;
  return calls;
}

/** OptiQ-style decoded-text tool parsing. Tool markup is parsed only
 *  after generation, and only when tools are active; tokenizer ids are
 *  model-family-specific and must not be used globally. Supports the
 *  OpenAI JSON `<tool_call>...</tool_call>` contract, Qwen-style
 *  `<function=name><parameter=...>`, GLM-5.2's
 *  `name<arg_key>...<arg_value>...`, and MiniCPM5's native
 *  `<function name="..."><param name="...">...` template shape. */
export function parseGeneratedToolCalls(text: string, tools: ToolSpec[]): ParsedToolCall[] {
  if (!tools.length) return [];
  const known = new Set(tools.map(toolSpecName).filter((n): n is string => !!n));
  const calls: ParsedToolCall[] = [];
  for (const block of text.matchAll(TOOL_CALL_BLOCK_RE)) {
    const body = block[1]!.trim();
    const parsed = parseJsonToolCall(body) ??
      parseXmlEqualsToolCall(body, tools) ??
      parseGlm52ToolCall(body, tools);
    if (!parsed) throw new Error("unsupported tool_call payload format");
    calls.push(parsed);
  }
  TOOL_CALL_BLOCK_RE.lastIndex = 0;
  if (calls.length === 0) calls.push(...parseXmlAttrToolCalls(text, tools));
  // Last-resort repair: no `<tool_call>` tags AND no `<function name=...>`
  // XML matched at all — a small model sometimes drops the wrapper tags
  // entirely and emits just (possibly fenced/prose-prefixed/malformed)
  // JSON. Only attempted when everything else found nothing, so a
  // genuinely tool-free assistant reply never risks being misread as a
  // call. Tagged repaired like every other path here.
  //
  // Unlike the `<tool_call>`-wrapped path, there is no surrounding markup
  // here to prove the model actually intended a tool call — an ordinary
  // conversational reply can itself BE a bare JSON object (e.g. "give me
  // an example record" -> `{"name": "read", "age": 42}`), which happens to
  // collide with a real tool name. Require the recovered payload to
  // actually look like a tool-call envelope (an `arguments`/
  // `function.arguments` object, or a `function` wrapper, or the
  // name-in-args shape) before accepting it — a flat object whose only
  // tool-shaped feature is a `name` key that matches a tool is NOT enough
  // signal on its own.
  if (calls.length === 0) {
    const repaired = repairJsonToolText(text.trim());
    if (repaired && looksLikeToolEnvelope(repaired.value)) {
      const result = toolCallFromPayload(repaired.value);
      if (result) {
        const repairs = result.nameInArgs ? [...repaired.repairs, "name_in_args" as const] : repaired.repairs;
        calls.push({ name: result.name, arguments: result.arguments, repaired: true, repairs });
      }
    }
  }
  for (const c of calls) {
    if (!known.has(c.name)) throw new Error(`unknown tool '${c.name}'`);
  }
  return calls;
}
