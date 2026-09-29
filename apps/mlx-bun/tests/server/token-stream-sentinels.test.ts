import { expect, test } from "bun:test";
import type { LoadedTokenizer, SentinelTokens } from "@mlx-bun/inference/input";
import { selectToolStreamMode, ToolAwareStream } from "../../src/server/token-streams";

// Ids chosen so that no vocabulary family constant could produce them.
const sentinels: SentinelTokens = { toolCallStart: 7001, toolCallEnd: 7002, channelStart: 7003, channelEnd: 7004 };
const words: Record<number, string> = { 1: "Hello ", 2: "thought\n", 3: "weighing", 4: "Done.", 5: "call:get_weather{city:<|\"|>Paris<|\"|>}",
  [sentinels.toolCallStart]: "<|tool_call>", [sentinels.toolCallEnd]: "<tool_call|>",
  [sentinels.channelStart]: "<|channel>", [sentinels.channelEnd]: "<channel|>" };
const special = new Set(Object.values(sentinels));
const tokenizer = {
  decode: (ids: number[], skipSpecial = false) => ids.filter(id => !(skipSpecial && special.has(id))).map(id => words[id] ?? "").join(""),
} as unknown as LoadedTokenizer;

test("the stream router is chosen by declared sentinels, never by a model type", () => {
  expect(selectToolStreamMode(sentinels, true)).toBe("sentinel-tokens");
  expect(selectToolStreamMode(sentinels, false)).toBe("sentinel-tokens");
  expect(selectToolStreamMode(null, true)).toBe("buffered-text");
  expect(selectToolStreamMode(undefined, false)).toBe("plain");
});

test("sentinel routing splits reasoning and tool calls at the declared ids", () => {
  const router = new ToolAwareStream(tokenizer, "sentinel-tokens", [{ type: "function", function: { name: "get_weather", parameters: {} } }], undefined, sentinels);
  let content = "";
  for (const token of [1, sentinels.channelStart, 2, 3, sentinels.channelEnd, 4, sentinels.toolCallStart, 5, sentinels.toolCallEnd]) content += router.push(token);
  content += router.flush();
  expect(content).toBe("Hello Done.");
  expect(router.takeReasoning()).toBe("\nweighing");
  expect(router.toolCalls().map(call => ({ name: call.function.name, arguments: JSON.parse(call.function.arguments) })))
    .toEqual([{ name: "get_weather", arguments: { city: "Paris" } }]);
});

test("without declared sentinels the same ids are ordinary tokens", () => {
  const router = new ToolAwareStream(tokenizer, "plain", null);
  let content = "";
  for (const token of [1, sentinels.channelStart, 3, sentinels.channelEnd]) content += router.push(token);
  content += router.flush();
  // Nothing is captured as reasoning or a tool call; the text stays content.
  expect(router.takeReasoning()).toBe("");
  expect(router.toolCalls()).toEqual([]);
  expect(content).toBe("Hello weighing");
});

test("sentinel routing without resolved ids is refused rather than guessed", () => {
  expect(() => new ToolAwareStream(tokenizer, "sentinel-tokens", null)).toThrow("needs the resolved sentinel ids");
});
