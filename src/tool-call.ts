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
