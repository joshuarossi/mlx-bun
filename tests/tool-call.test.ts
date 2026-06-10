// Unit tests for the gemma4 tool-call parser (fast tier).

import { describe, expect, test } from "bun:test";
import { gemmaArgsToJson, parseToolCalls } from "../src/tool-call";

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
