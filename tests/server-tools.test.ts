// Tool-calling integration (slow tier): the real model must emit a tool
// call for an obvious tool-shaped request, and answer after the tool
// response round-trip.

import { afterAll, describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();

const TOOLS = [{
  type: "function" as const,
  function: {
    name: "get_weather",
    description: "Get the current weather for a city",
    parameters: {
      type: "object",
      properties: {
        city: { type: "string", description: "City name" },
      },
      required: ["city"],
    },
  },
}];

describe.skipIf(!haveWeights)("tool calling end-to-end", async () => {
  if (!haveWeights) return;
  const { createServer, loadContext } = await import("../src/server");
  const ctx = await loadContext(SNAPSHOT, "gemma-test");
  const server = createServer(ctx, 0);
  const base = `http://localhost:${server.port}`;
  afterAll(() => server.stop(true));

  const chat = async (messages: unknown[], stream = false) => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages, tools: TOOLS, max_tokens: 96, temperature: 0, stream,
      }),
    });
    expect(res.status).toBe(200);
    return res;
  };

  test("model emits a parsed tool call", async () => {
    const res = await chat([
      { role: "user", content: "What is the weather in Paris right now? Use the tool." },
    ]);
    const body = (await res.json()) as any;
    expect(body.choices[0].finish_reason).toBe("tool_calls");
    const tc = body.choices[0].message.tool_calls;
    expect(tc).toHaveLength(1);
    expect(tc[0].type).toBe("function");
    expect(tc[0].function.name).toBe("get_weather");
    expect(JSON.parse(tc[0].function.arguments).city).toBe("Paris");
    expect(tc[0].id).toStartWith("call_");
  }, 180_000);

  test("tool response round-trip produces a grounded answer", async () => {
    const res = await chat([
      { role: "user", content: "What is the weather in Paris right now? Use the tool." },
      {
        role: "assistant",
        tool_calls: [{
          id: "call_abc", type: "function",
          function: { name: "get_weather", arguments: '{"city":"Paris"}' },
        }],
      },
      { role: "tool", tool_call_id: "call_abc", content: "Snow, -3C" },
    ]);
    const body = (await res.json()) as any;
    expect(body.choices[0].finish_reason).toBe("stop");
    const content = body.choices[0].message.content.toLowerCase();
    expect(content).toMatch(/snow|-3/);
  }, 180_000);

  test("streaming surfaces tool_calls delta and finish_reason", async () => {
    const res = await chat(
      [{ role: "user", content: "Weather in Tokyo? Use the tool." }],
      true,
    );
    const text = await res.text();
    const events = text.split("\n\n").filter((l) => l.startsWith("data: "))
      .map((l) => l.slice(6));
    const chunks = events.filter((e) => e !== '"[DONE]"').map((e) => JSON.parse(e));
    const tcChunk = chunks.find((c: any) => c.choices?.[0]?.delta?.tool_calls);
    expect(tcChunk).toBeDefined();
    expect(tcChunk.choices[0].delta.tool_calls[0].function.name).toBe("get_weather");
    expect(JSON.parse(tcChunk.choices[0].delta.tool_calls[0].function.arguments).city).toBe("Tokyo");
    const final = chunks.at(-1) as any;
    expect(final.choices[0].finish_reason).toBe("tool_calls");
  }, 180_000);
});
