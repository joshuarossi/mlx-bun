// Shared model-free fixtures for the token-fast-forwarding tests: a
// deterministic word/punctuation tokenizer and a couple of minimal chat
// templates. Not a test file — imported by tests/unit/fill-*.test.ts and
// tests/serve/fill-*.test.ts.
import { Template } from "@huggingface/jinja";
import type { ChatMessage, RenderOptions, ToolDefinition } from "../../src/chat-template";

/** Markers a real tokenizer would give their own vocabulary id. */
const SPECIALS = [
  "<|im_start|>", "<|im_end|>", "<tool_call>", "</tool_call>",
  "<arg_key>", "</arg_key>", "<arg_value>", "</arg_value>",
  "<|assistant|>", "<|user|>", "<|system|>", "<|observation|>",
  "<tool_response>", "</tool_response>", "<tools>", "</tools>",
  "<think>", "</think>", "[gMASK]", "<sop>",
].sort((a, b) => b.length - a.length);

export interface FakeTokenizer {
  encode(text: string, addSpecialTokens?: boolean): number[];
  decode(ids: number[], skipSpecialTokens?: boolean): string;
  idToToken(id: number): string;
  readonly bosTokenId: number | null;
  readonly eosTokenId: number | null;
  /** Test-only: the piece behind each id. */
  pieces(ids: number[]): string[];
}

/** Specials stay whole; everything else splits into word runs and single
 *  punctuation characters. Ids are assigned in first-seen order and are stable
 *  for the lifetime of the instance.
 *
 *  `merges` adds extra multi-character sequences that tokenize as ONE token,
 *  matched greedily like the specials. That reproduces the BPE behavior the
 *  row compiler has to survive: Qwen3.5 encodes `<function=get_weather>` as
 *  `< function =get _weather >` — `=get` is a single token, so a probe with a
 *  placeholder name (which splits as `… = zzalpha…`) invents a boundary after
 *  `=` that the real stream never has. */
export function makeTokenizer(merges: string[] = []): FakeTokenizer {
  const ids = new Map<string, number>();
  const pieces: string[] = [];
  const greedy = [...SPECIALS, ...merges].sort((a, b) => b.length - a.length);
  const idOf = (piece: string): number => {
    const hit = ids.get(piece);
    if (hit !== undefined) return hit;
    const id = pieces.length;
    pieces.push(piece);
    ids.set(piece, id);
    return id;
  };
  const split = (text: string): string[] => {
    const out: string[] = [];
    let i = 0;
    while (i < text.length) {
      const special = greedy.find((s) => text.startsWith(s, i));
      if (special) { out.push(special); i += special.length; continue; }
      const word = /^[A-Za-z0-9_]+/.exec(text.slice(i));
      if (word) { out.push(word[0]); i += word[0].length; continue; }
      out.push(text[i]!);
      i += 1;
    }
    return out;
  };
  return {
    encode: (text: string) => split(text).map(idOf),
    decode: (list: number[]) => list.map((id) => pieces[id] ?? "").join(""),
    idToToken: (id: number) => pieces[id] ?? "",
    bosTokenId: null,
    eosTokenId: null,
    pieces: (list: number[]) => list.map((id) => pieces[id] ?? ""),
  };
}

/** Qwen-style: JSON tool calls inside `<tool_call>` markers. */
export const QWEN_STYLE_TEMPLATE = `{% for m in messages %}<|im_start|>{{ m.role }}
{% if m.tool_calls %}{% for tc in m.tool_calls %}<tool_call>
{"name": "{{ tc.function.name }}", "arguments": {{ tc.function.arguments | tojson }}}
</tool_call>{% endfor %}{% else %}{{ m.content }}{% endif %}<|im_end|>
{% endfor %}{% if add_generation_prompt %}<|im_start|>assistant
{% endif %}`;

/** Qwen3.5-style XML: `<function=NAME>` / `<parameter=KEY>`. Paired with
 *  `MERGES_XML` this is the shape that caught the placeholder-probe bug. */
export const QWEN_XML_TEMPLATE = `{% for m in messages %}<|im_start|>{{ m.role }}
{% if m.tool_calls %}{% for tc in m.tool_calls %}<tool_call>
<function={{ tc.function.name }}>{% for k, v in tc.function.arguments.items() %}
<parameter={{ k }}>
{{ v }}
</parameter>{% endfor %}
</function>
</tool_call>{% endfor %}{% else %}{{ m.content }}{% endif %}<|im_end|>
{% endfor %}{% if add_generation_prompt %}<|im_start|>assistant
{% endif %}`;

/** Merges that exist for the REAL tool names and not for a placeholder — the
 *  exact asymmetry that made a placeholder-probed scaffold end at a boundary
 *  the model's own stream does not have. */
export const MERGES_XML = ["=get", "=search"];

/** Same shape, but assistant tool_calls are never rendered. */
export const NO_TOOL_CALLS_TEMPLATE = `{% for m in messages %}<|im_start|>{{ m.role }}
{{ m.content }}<|im_end|>
{% endfor %}{% if add_generation_prompt %}<|im_start|>assistant
{% endif %}`;

export function jinjaTemplate(source: string) {
  const compiled = new Template(source);
  return {
    render: (messages: ChatMessage[], options: RenderOptions = {}) =>
      compiled.render({
        messages,
        add_generation_prompt: options.addGenerationPrompt ?? true,
        tools: options.tools ?? null,
      }),
  };
}

/** One string property, required, additionalProperties:false — the sole-key
 *  shape that compiles a key row. */
export const WEATHER_TOOL: ToolDefinition = {
  type: "function",
  function: {
    name: "get_weather",
    parameters: {
      type: "object",
      properties: { city: { type: "string" } },
      required: ["city"],
      additionalProperties: false,
    },
  },
};

/** Two properties — a name row but no key row. */
export const SEARCH_TOOL: ToolDefinition = {
  type: "function",
  function: {
    name: "search_docs",
    parameters: {
      type: "object",
      properties: { query: { type: "string" }, limit: { type: "integer" } },
    },
  },
};
