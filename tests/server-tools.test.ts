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

  // ---- Anthropic /v1/messages (Phase 11) — same server, same model ----

  const ANTHROPIC_TOOLS = [{
    name: "get_weather",
    description: "Get the current weather for a city",
    input_schema: {
      type: "object",
      properties: { city: { type: "string", description: "City name" } },
      required: ["city"],
    },
  }];

  const messages = async (body: Record<string, unknown>) =>
    fetch(`${base}/v1/messages`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ max_tokens: 96, temperature: 0, ...body }),
    });

  test("anthropic: non-streaming text message", async () => {
    const res = await messages({
      messages: [{ role: "user", content: "Reply with exactly: pong" }],
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.type).toBe("message");
    expect(body.role).toBe("assistant");
    expect(body.id).toStartWith("msg_");
    const text = body.content.find((b: any) => b.type === "text");
    expect(text.text.toLowerCase()).toContain("pong");
    expect(body.stop_reason).toBe("end_turn");
    expect(body.usage.input_tokens).toBeGreaterThan(0);
    expect(body.usage.output_tokens).toBeGreaterThan(0);
  }, 180_000);

  test("anthropic: tool_use emitted for a tool-shaped request", async () => {
    const res = await messages({
      messages: [{ role: "user", content: "What is the weather in Paris right now? Use the tool." }],
      tools: ANTHROPIC_TOOLS,
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.stop_reason).toBe("tool_use");
    const tu = body.content.find((b: any) => b.type === "tool_use");
    expect(tu.name).toBe("get_weather");
    expect(tu.input.city).toBe("Paris");
    expect(tu.id).toBeTruthy();
  }, 180_000);

  test("anthropic: tool_result round-trip produces a grounded answer", async () => {
    const res = await messages({
      messages: [
        { role: "user", content: "What is the weather in Paris right now? Use the tool." },
        {
          role: "assistant",
          content: [{
            type: "tool_use", id: "toolu_abc",
            name: "get_weather", input: { city: "Paris" },
          }],
        },
        {
          role: "user",
          content: [{
            type: "tool_result", tool_use_id: "toolu_abc", content: "Snow, -3C",
          }],
        },
      ],
      tools: ANTHROPIC_TOOLS,
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.stop_reason).toBe("end_turn");
    const text = body.content.find((b: any) => b.type === "text");
    expect(text.text.toLowerCase()).toMatch(/snow|-3/);
  }, 180_000);

  test("anthropic: streaming event grammar + reassembled text", async () => {
    const res = await messages({
      messages: [{ role: "user", content: "Count from 1 to 5, digits only." }],
      stream: true,
    });
    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toContain("text/event-stream");
    const raw = await res.text();
    const events = [...raw.matchAll(/event: (\w+)\ndata: (.*)\n/g)]
      .map((m) => ({ event: m[1]!, data: JSON.parse(m[2]!) }));
    expect(events[0]!.event).toBe("message_start");
    expect(events.at(-1)!.event).toBe("message_stop");
    const startIdx = events.findIndex((e) => e.event === "content_block_start");
    const stopIdx = events.findIndex((e) => e.event === "content_block_stop");
    expect(startIdx).toBeGreaterThan(0);
    expect(stopIdx).toBeGreaterThan(startIdx);
    const text = events
      .filter((e) => e.event === "content_block_delta" && e.data.delta?.type === "text_delta")
      .map((e) => e.data.delta.text)
      .join("");
    expect(text).toMatch(/1.*2.*3.*4.*5/s);
    const md = events.find((e) => e.event === "message_delta")!;
    expect(md.data.delta.stop_reason).toBe("end_turn");
    expect(md.data.usage.output_tokens).toBeGreaterThan(0);
  }, 180_000);

  test("anthropic: invalid body → anthropic-shaped 400", async () => {
    const res = await messages({ messages: [] });
    expect(res.status).toBe(400);
    const body = (await res.json()) as any;
    expect(body.type).toBe("error");
    expect(body.error.type).toBe("invalid_request_error");
  });
});
