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

export const TOOL_CALL_START = 48;
export const TOOL_CALL_END = 49;
export const TOOL_RESPONSE_START = 50;

const QUOTE = '<|"|>';

export interface ParsedToolCall {
  name: string;
  /** Parsed argument object (callers serialize for OpenAI's string field). */
  arguments: Record<string, unknown>;
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

/** Parse every `call:name{...}` block in a decoded tool-call segment. */
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
    while (j < text.length) {
      if (text.startsWith(QUOTE, j)) {
        const close = text.indexOf(QUOTE, j + QUOTE.length);
        if (close === -1) throw new Error("unterminated <|\"|> string");
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
    if (depth !== 0) throw new Error("unbalanced braces in tool call");
    const argsBlock = text.slice(nameEnd, j + 1);
    calls.push({
      name: m[1]!,
      arguments: JSON.parse(gemmaArgsToJson(argsBlock)) as Record<string, unknown>,
    });
    i = j + 1;
  }
  return calls;
}

const TOOL_CALL_BLOCK_RE = /<tool_call>\s*([\s\S]*?)\s*<\/tool_call>/gi;
const XML_FUNCTION_EQUALS_RE = /^\s*<function=([^>\s]+)>\s*([\s\S]*?)\s*<\/function>\s*$/i;
const XML_PARAMETER_EQUALS_RE = /<parameter=([^>\s]+)>\s*([\s\S]*?)\s*<\/parameter>/gi;
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

function parseJsonToolCall(block: string): ParsedToolCall | null {
  let payload: unknown;
  try {
    payload = JSON.parse(block);
  } catch {
    return null;
  }
  if (!payload || typeof payload !== "object") throw new Error("JSON tool_call payload must be an object");
  const obj = payload as Record<string, any>;
  const fn = obj.function && typeof obj.function === "object" ? obj.function : obj;
  const name = typeof fn.name === "string" ? fn.name.trim() : "";
  if (!name) throw new Error("JSON tool_call is missing a function name");
  const args = fn.arguments ?? obj.arguments ?? {};
  if (typeof args === "string") {
    const parsed = args.trim() ? JSON.parse(args) : {};
    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed))
      throw new Error("tool_call arguments must be a JSON object");
    return { name, arguments: parsed as Record<string, unknown> };
  }
  if (!args || typeof args !== "object" || Array.isArray(args))
    throw new Error("tool_call arguments must be a JSON object");
  return { name, arguments: args as Record<string, unknown> };
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
 *  `<function=name><parameter=...>`, and MiniCPM5's native
 *  `<function name="..."><param name="...">...` template shape. */
export function parseGeneratedToolCalls(text: string, tools: ToolSpec[]): ParsedToolCall[] {
  if (!tools.length) return [];
  const known = new Set(tools.map(toolSpecName).filter((n): n is string => !!n));
  const calls: ParsedToolCall[] = [];
  for (const block of text.matchAll(TOOL_CALL_BLOCK_RE)) {
    const body = block[1]!.trim();
    const parsed = parseJsonToolCall(body) ?? parseXmlEqualsToolCall(body, tools);
    if (!parsed) throw new Error("unsupported tool_call payload format");
    calls.push(parsed);
  }
  TOOL_CALL_BLOCK_RE.lastIndex = 0;
  if (calls.length === 0) calls.push(...parseXmlAttrToolCalls(text, tools));
  for (const c of calls) {
    if (!known.has(c.name)) throw new Error(`unknown tool '${c.name}'`);
  }
  return calls;
}
