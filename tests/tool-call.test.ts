// Unit tests for the gemma4 tool-call parser (fast tier).

import { describe, expect, test } from "bun:test";
import { gemmaArgsToJson, parseGeneratedToolCalls, parseToolCalls } from "../src/tool-call";

const Q = '<|"|>';

describe("gemmaArgsToJson", () => {
  test("strings, numbers, bools, bare keys", () => {
    const src = `{city:${Q}San Francisco${Q},days:3,metric:true}`;
    expect(JSON.parse(gemmaArgsToJson(src))).toEqual({
      city: "San Francisco", days: 3, metric: true,
    });
  });

  test("nested objects and arrays", () => {
    const src = `{filters:{tags:[${Q}a${Q},${Q}b${Q}],limit:10},query:${Q}x${Q}}`;
    expect(JSON.parse(gemmaArgsToJson(src))).toEqual({
      filters: { tags: ["a", "b"], limit: 10 }, query: "x",
    });
  });

  test("strings containing braces, colons, quotes survive", () => {
    const src = `{code:${Q}if (x) { return "y:z"; }${Q}}`;
    expect(JSON.parse(gemmaArgsToJson(src))).toEqual({
      code: 'if (x) { return "y:z"; }',
    });
  });
});

describe("parseToolCalls", () => {
  test("single call", () => {
    const calls = parseToolCalls(`call:get_weather{city:${Q}Paris${Q}}`);
    expect(calls).toEqual([{ name: "get_weather", arguments: { city: "Paris" } }]);
  });

  test("multiple calls in one segment", () => {
    const calls = parseToolCalls(
      `call:a{x:1}call:b{y:${Q}two${Q}}`,
    );
    expect(calls.map((c) => c.name)).toEqual(["a", "b"]);
    expect(calls[1]!.arguments).toEqual({ y: "two" });
  });

  test("empty arguments", () => {
    expect(parseToolCalls("call:list_files{}")).toEqual([
      { name: "list_files", arguments: {} },
    ]);
  });

  test("nested braces in arguments", () => {
    const calls = parseToolCalls(`call:run{config:{a:{b:2}},flag:false}`);
    expect(calls[0]!.arguments).toEqual({ config: { a: { b: 2 } }, flag: false });
  });

  test("no calls → empty array", () => {
    expect(parseToolCalls("just some text")).toEqual([]);
  });

  test("string with braces does not break brace balance", () => {
    const calls = parseToolCalls(`call:echo{text:${Q}}}}{{{${Q}}`);
    expect(calls[0]!.arguments).toEqual({ text: "}}}{{{" });
  });
});

describe("parseGeneratedToolCalls schema-aware values", () => {
  const tools = [{
    type: "function",
    function: {
      name: "read",
      parameters: {
        type: "object",
        properties: {
          path: { type: "string" },
          limit: { type: "number" },
        },
        required: ["path"],
      },
    },
  }];

  test("string-typed params keep JSON-looking text as strings", () => {
    const calls = parseGeneratedToolCalls(
      '<function name="read"><param name="path">2025</param><param name="limit">10</param></function>',
      tools,
    );
    expect(calls[0]!.arguments).toEqual({ path: "2025", limit: 10 });
  });

  test("CDATA values survive, including embedded closing tags", () => {
    const calls = parseGeneratedToolCalls(
      '<function name="read"><param name="path"><![CDATA[a</param>b\nc]]></param></function>',
      tools,
    );
    expect(calls[0]!.arguments).toEqual({ path: "a</param>b\nc" });
  });
});

describe("parseGeneratedToolCalls", () => {
  const tools = [{
    type: "function",
    function: {
      name: "read",
      parameters: {
        type: "object",
        properties: { path: { type: "string" } },
        required: ["path"],
      },
    },
  }];

  test("OpenAI JSON tool_call block", () => {
    expect(parseGeneratedToolCalls(
      '<tool_call>{"name":"read","arguments":{"path":"AGENTS.md"}}</tool_call>',
      tools,
    )).toEqual([{ name: "read", arguments: { path: "AGENTS.md" } }]);
  });

  test("OptiQ/Qwen XML tool_call block", () => {
    expect(parseGeneratedToolCalls(
      "<tool_call><function=read><parameter=path>AGENTS.md</parameter></function></tool_call>",
      tools,
    )).toEqual([{ name: "read", arguments: { path: "AGENTS.md" } }]);
  });

  test("MiniCPM5 native function/param XML", () => {
    expect(parseGeneratedToolCalls(
      '<function name="read"><param name="path">/Users/joshrossi/Code/mlx-bun/AGENTS.md</param></function>',
      tools,
    )).toEqual([{
      name: "read",
      arguments: { path: "/Users/joshrossi/Code/mlx-bun/AGENTS.md" },
    }]);
  });

  test("rejects unknown tool names", () => {
    expect(() => parseGeneratedToolCalls(
      '<function name="write"><param name="path">x</param></function>',
      tools,
    )).toThrow(/unknown tool/);
  });
});
