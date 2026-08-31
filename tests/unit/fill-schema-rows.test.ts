// Strict fill rows (K3b) — scaffold probing against real templates.
//
// The compiler knows nothing about tool-call syntax: it renders the same
// conversation with different real tool names / real schema keys / probe
// values and diffs the TOKEN IDS. So the assertions here are token-exact and
// format-agnostic — Qwen-style XML (`<function=NAME>`), Qwen-style JSON
// (`{"name": …}`), and GLM-5.2's `<arg_key>`/`<arg_value>` (the shipped
// renderer, src/chat-template.ts) all compile, and a template that does not
// render tool_calls compiles to nothing.
//
// THE GATE THAT MATTERS (regression, 2026-08-31): every row's
// [trigger…emit] must appear as a contiguous ID SUBSEQUENCE of a real
// rendering — not merely as a text substring. Probing with placeholder names
// used to produce spans that decoded to the right TEXT but split at a token
// boundary the real stream never has (`=` + `get` where the model emits the
// merged `=get`), so the filled stream diverged in ids while matching byte for
// byte. Text checks pass that bug; id checks catch it.
//
// Model-free: a deterministic word/punctuation tokenizer with configurable
// merges stands in for a real BPE vocabulary (tests/support/fill-fixtures.ts).
// The real-tokenizer version of this gate is tests/parity/fill-strict.test.ts.
import { describe, expect, test } from "bun:test";
import {
  renderGlm52Chat, type ChatMessage, type ToolDefinition,
} from "../../src/chat-template";
import { compileStrictFillRows, type FillTemplateLike } from "../../src/fill/schema-rows";
import type { FillRow } from "../../src/fill/fill-session";
import {
  jinjaTemplate,
  makeTokenizer,
  MERGES_XML,
  NO_TOOL_CALLS_TEMPLATE,
  QWEN_STYLE_TEMPLATE,
  QWEN_XML_TEMPLATE,
  SEARCH_TOOL as SEARCH,
  WEATHER_TOOL as WEATHER,
  type FakeTokenizer,
} from "../support/fill-fixtures";

const messages: ChatMessage[] = [{ role: "user", content: "hi" }];
const kinds = (rows: FillRow[]) => rows.map((r) => r.kind);
const asText = (tokenizer: FakeTokenizer, row: FillRow) => ({
  trigger: tokenizer.pieces(row.trigger).join(""),
  emit: tokenizer.pieces(row.emit).join(""),
});

/** Index of `needle` as a contiguous run inside `haystack`, or -1. */
function idSubsequenceAt(haystack: readonly number[], needle: readonly number[]): number {
  for (let i = 0; i + needle.length <= haystack.length; i++) {
    let ok = true;
    for (let j = 0; j < needle.length; j++) {
      if (haystack[i + j] !== needle[j]) { ok = false; break; }
    }
    if (ok) return i;
  }
  return -1;
}

function compile(
  template: FillTemplateLike, tokenizer: FakeTokenizer, tools: ToolDefinition[],
): FillRow[] {
  return compileStrictFillRows({
    template, tokenizer, messages, tools, renderOptions: { tools },
  }).rows;
}

/** Token ids the compiler decided legitimately END an argument value — what
 *  the echo tier is allowed to stop at (src/fill/echo-index.ts). */
function delimiters(
  template: FillTemplateLike, tokenizer: FakeTokenizer, tools: ToolDefinition[],
): string[] {
  return tokenizer.pieces(compileStrictFillRows({
    template, tokenizer, messages, tools, renderOptions: { tools },
  }).delimiters);
}

/** THE gate: every row is a slice of a rendering the model could produce.
 *  A row that names one tool need only appear in that tool's rendering. */
function expectRowsSliceRealRenderings(
  template: FillTemplateLike,
  tokenizer: FakeTokenizer,
  tools: ToolDefinition[],
  rows: FillRow[],
  calls: { name: string; args: Record<string, unknown> }[],
): void {
  const renderings = calls.map(({ name, args }) => tokenizer.encode(template.render(
    [...messages, {
      role: "assistant", content: "",
      tool_calls: [{ id: "call_x", type: "function", function: { name, arguments: args } }],
    }],
    { tools, addGenerationPrompt: false },
  )));
  for (const row of rows) {
    const seq = [...row.trigger, ...row.emit];
    const found = renderings.some((ids) => idSubsequenceAt(ids, seq) !== -1);
    expect({ kind: row.kind, text: asText(tokenizer, row), contiguousInSomeRealRendering: found })
      .toMatchObject({ contiguousInSomeRealRendering: true });
  }
}

const WEATHER_CALL = { name: "get_weather", args: { city: "Paris" } };
const SEARCH_CALL = { name: "search_docs", args: { query: "kv cache", limit: 5 } };

describe("regression: a token that merges under the real name, not under a placeholder", () => {
  // `<function=get_weather>` tokenizes as `< function =get _weather >`, so the
  // boundary after `=` exists ONLY for a placeholder name. This is the bug the
  // 0.8B weights run caught: byte-identical text, divergent ids.
  const template = jinjaTemplate(QWEN_XML_TEMPLATE);

  test("the scaffold stops BEFORE the merged token, never mid-merge", () => {
    const tokenizer = makeTokenizer(MERGES_XML);
    const rows = compile(template, tokenizer, [WEATHER, SEARCH]);
    const scaffold = rows.find((r) => r.kind === "scaffold")!;
    expect(asText(tokenizer, scaffold)).toEqual({
      trigger: "<tool_call>",
      emit: "\n<function",       // NOT "\n<function=" — `=get` is one token
    });
    expect(asText(tokenizer, scaffold).emit.endsWith("=")).toBe(false);
  });

  test("the merged token belongs to the name trigger, and the rest is injected", () => {
    const tokenizer = makeTokenizer(MERGES_XML);
    const rows = compile(template, tokenizer, [WEATHER, SEARCH]);
    expect(rows.filter((r) => r.kind === "name").map((r) => asText(tokenizer, r))).toEqual([
      { trigger: "<tool_call>\n<function=get", emit: "_weather><parameter=city>\n" },
      { trigger: "<tool_call>\n<function=search", emit: "_docs><parameter=" },
    ]);
  });

  test("every row is a contiguous id subsequence of a real rendering", () => {
    const tokenizer = makeTokenizer(MERGES_XML);
    const rows = compile(template, tokenizer, [WEATHER, SEARCH]);
    expect(rows.length).toBeGreaterThan(0);
    expectRowsSliceRealRenderings(
      template, tokenizer, [WEATHER, SEARCH], rows, [WEATHER_CALL, SEARCH_CALL]);
  });

  test("one tool: the whole header through the sole key is one determined span", () => {
    const tokenizer = makeTokenizer(MERGES_XML);
    const rows = compile(template, tokenizer, [WEATHER]);
    expect(kinds(rows)).toEqual(["scaffold", "close"]);
    expect(asText(tokenizer, rows[0]!)).toEqual({
      trigger: "<tool_call>",
      emit: "\n<function=get_weather><parameter=city>\n",
    });
    expectRowsSliceRealRenderings(template, tokenizer, [WEATHER], rows, [WEATHER_CALL]);
  });
});

describe("close rows", () => {
  const template = jinjaTemplate(QWEN_XML_TEMPLATE);

  test("armed only when EVERY tool takes exactly one required argument", () => {
    // With a multi-argument tool in the request, the first `</parameter>` may
    // be followed by a SECOND parameter — injecting the close would drop it.
    const one = makeTokenizer(MERGES_XML);
    expect(kinds(compile(template, one, [WEATHER]))).toContain("close");
    const two = makeTokenizer(MERGES_XML);
    expect(kinds(compile(template, two, [WEATHER, SEARCH]))).not.toContain("close");
  });

  test("the trigger carries letters, so a bare `</` in prose cannot arm it", () => {
    const tokenizer = makeTokenizer(MERGES_XML);
    const close = compile(template, tokenizer, [WEATHER]).find((r) => r.kind === "close")!;
    expect(asText(tokenizer, close)).toEqual({
      trigger: "</parameter",
      emit: "></function>\n</tool_call>",
    });
    // The turn end is left to the model: `</tool_call>` ends the span.
    expect(asText(tokenizer, close).emit).not.toContain("<|im_end|>");
  });
});

describe("Qwen-style JSON <tool_call> template", () => {
  const template = jinjaTemplate(QWEN_STYLE_TEMPLATE);

  test("one tool: call open, name, and the sole key are all determined", () => {
    const tokenizer = makeTokenizer();
    const rows = compile(template, tokenizer, [WEATHER]);
    expect(kinds(rows)).toEqual(["scaffold"]);
    expect(asText(tokenizer, rows[0]!)).toEqual({
      trigger: "<tool_call>",
      emit: '\n{"name": "get_weather", "arguments": {"city": ',
    });
    // The value's opening quote is NOT injected: an integer-typed key has none.
    expect(asText(tokenizer, rows[0]!).emit.endsWith('"')).toBe(false);
    expectRowsSliceRealRenderings(template, tokenizer, [WEATHER], rows, [WEATHER_CALL]);
  });

  test("two tools: the scaffold stops at the name, each name row resumes it", () => {
    const tokenizer = makeTokenizer();
    const rows = compile(template, tokenizer, [WEATHER, SEARCH]);
    expect(kinds(rows)).toEqual(["scaffold", "name", "name"]);
    expect(rows.map((r) => asText(tokenizer, r))).toEqual([
      { trigger: "<tool_call>", emit: '\n{"name": "' },
      { trigger: '<tool_call>\n{"name": "get_weather', emit: '", "arguments": {"city": ' },
      { trigger: '<tool_call>\n{"name": "search_docs', emit: '", "arguments": {"' },
    ]);
    expectRowsSliceRealRenderings(
      template, tokenizer, [WEATHER, SEARCH], rows, [WEATHER_CALL, SEARCH_CALL]);
  });

  test("rows chain: a name trigger resumes exactly where the scaffold ended", () => {
    const tokenizer = makeTokenizer();
    const rows = compile(template, tokenizer, [WEATHER, SEARCH]);
    const scaffold = rows.find((r) => r.kind === "scaffold")!;
    const name = rows.find((r) => r.kind === "name")!;
    const afterScaffold = [...scaffold.trigger, ...scaffold.emit];
    expect(name.trigger.slice(0, afterScaffold.length)).toEqual(afterScaffold);
  });

  test("a multi-property tool's span stops before the key the model picks", () => {
    const tokenizer = makeTokenizer();
    const rows = compile(template, tokenizer, [SEARCH]);
    // `query` vs `limit` diverge, so nothing past the arguments brace is
    // determined — the model chooses which key comes first.
    expect(asText(tokenizer, rows[0]!).emit).toBe('\n{"name": "search_docs", "arguments": {"');
  });
});

describe("GLM-5.2 <arg_key>/<arg_value> template (a wholly different format)", () => {
  const template: FillTemplateLike = { render: (m, o) => renderGlm52Chat(m, o) };

  test("the same compiler finds the same kind of determined span", () => {
    const tokenizer = makeTokenizer();
    const rows = compile(template, tokenizer, [WEATHER]);
    expect(kinds(rows)).toEqual(["scaffold"]);
    expect(asText(tokenizer, rows[0]!)).toEqual({
      trigger: "<tool_call>",
      emit: "get_weather<arg_key>city</arg_key><arg_value>",
    });
    expectRowsSliceRealRenderings(template, tokenizer, [WEATHER], rows, [WEATHER_CALL]);
  });

  test("two tools: GLM puts nothing between the call open and the name", () => {
    const tokenizer = makeTokenizer();
    const rows = compile(template, tokenizer, [WEATHER, SEARCH]);
    // The shared prefix is `<tool_call>` alone — one token, nothing to save —
    // so only the per-tool name row survives.
    expect(kinds(rows)).toEqual(["name"]);
    expect(asText(tokenizer, rows[0]!)).toEqual({
      trigger: "<tool_call>get_weather",
      emit: "<arg_key>city</arg_key><arg_value>",
    });
    expectRowsSliceRealRenderings(
      template, tokenizer, [WEATHER, SEARCH], rows, [WEATHER_CALL, SEARCH_CALL]);
  });
});

describe("value delimiters (what the echo tier may stop at)", () => {
  test("XML: the markup that follows a value, not the newline before it", () => {
    const tokenizer = makeTokenizer(MERGES_XML);
    // The template puts `\n</parameter>` after a value; the NEWLINE is not the
    // delimiter (a newline ends nothing in particular — and treating it as one
    // would let the echo tier assert on it). The first non-whitespace token of
    // the closing markup is. This fixture splits it as `<`; a real BPE gives
    // `</` (Qwen3.5-0.8B, id 510).
    expect(delimiters(jinjaTemplate(QWEN_XML_TEMPLATE), tokenizer, [WEATHER]))
      .toEqual(["<"]);
  });

  test("JSON: the closing quote", () => {
    const tokenizer = makeTokenizer();
    expect(delimiters(jinjaTemplate(QWEN_STYLE_TEMPLATE), tokenizer, [WEATHER]))
      .toEqual(['"']);
  });

  test("a template with no determined span offers no delimiters", () => {
    const tokenizer = makeTokenizer();
    expect(delimiters(jinjaTemplate(NO_TOOL_CALLS_TEMPLATE), tokenizer, [WEATHER]))
      .toEqual([]);
  });
});

describe("degrade paths", () => {
  test("a template that never renders tool_calls compiles to no rows", () => {
    const tokenizer = makeTokenizer();
    expect(compile(jinjaTemplate(NO_TOOL_CALLS_TEMPLATE), tokenizer, [WEATHER])).toEqual([]);
  });

  test("a template that renders the arguments but not the name compiles to no rows", () => {
    const nameless = jinjaTemplate(
      `{% for m in messages %}<|im_start|>{{ m.role }}
{% if m.tool_calls %}{% for tc in m.tool_calls %}<tool_call>
{{ tc.function.arguments | tojson }}
</tool_call>{% endfor %}{% else %}{{ m.content }}{% endif %}<|im_end|>
{% endfor %}{% if add_generation_prompt %}<|im_start|>assistant
{% endif %}`);
    expect(compile(nameless, makeTokenizer(), [WEATHER])).toEqual([]);
  });

  test("a template that throws on the probe render compiles to no rows", () => {
    expect(compile(
      { render: () => { throw new Error("no tool_calls in this template"); } },
      makeTokenizer(), [WEATHER])).toEqual([]);
  });

  test("no tools, no rows", () => {
    expect(compile(jinjaTemplate(QWEN_STYLE_TEMPLATE), makeTokenizer(), [])).toEqual([]);
  });
});
