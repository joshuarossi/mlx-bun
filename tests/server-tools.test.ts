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
    const chunks = events.filter((e) => e !== "[DONE]").map((e) => JSON.parse(e));
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

  test("anthropic: real Anthropic SDK — multi-turn streamed conversation with tool use", async () => {
    // The Phase 11 exit criterion verbatim, SDK-validated wire shapes.
    const { default: Anthropic } = await import("@anthropic-ai/sdk");
    const client = new Anthropic({ baseURL: base, apiKey: "sk-local" });

    // turn 1 (streamed): the model calls the tool
    const stream1 = client.messages.stream({
      model: "gemma-test",
      max_tokens: 96,
      temperature: 0,
      tools: [{
        name: "get_weather",
        description: "Get the current weather for a city",
        input_schema: {
          type: "object",
          properties: { city: { type: "string" } },
          required: ["city"],
        },
      }],
      messages: [
        { role: "user", content: "What is the weather in Paris right now? Use the tool." },
      ],
    });
    const turn1 = await stream1.finalMessage();
    expect(turn1.stop_reason).toBe("tool_use");
    const toolUse = turn1.content.find((b) => b.type === "tool_use") as any;
    expect(toolUse.name).toBe("get_weather");
    expect(toolUse.input.city).toBe("Paris");

    // turn 2 (streamed): tool result goes back, grounded answer comes out
    const stream2 = client.messages.stream({
      model: "gemma-test",
      max_tokens: 96,
      temperature: 0,
      messages: [
        { role: "user", content: "What is the weather in Paris right now? Use the tool." },
        { role: "assistant", content: turn1.content },
        {
          role: "user",
          content: [{
            type: "tool_result", tool_use_id: toolUse.id, content: "Snow, -3C",
          }],
        },
      ],
    });
    let streamedText = "";
    stream2.on("text", (t) => (streamedText += t));
    const turn2 = await stream2.finalMessage();
    expect(turn2.stop_reason).toBe("end_turn");
    expect(streamedText.toLowerCase()).toMatch(/snow|-3/);
    expect(turn2.usage.output_tokens).toBeGreaterThan(0);
  }, 360_000);

  // ---- OpenAI Responses API (Phase 11) — same server, same model ----

  const responses = async (body: Record<string, unknown>) =>
    fetch(`${base}/v1/responses`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ max_output_tokens: 96, temperature: 0, ...body }),
    });

  test("responses: multi-turn resumed conversation via previous_response_id", async () => {
    const r1 = await responses({
      input: "My favorite color is teal. Reply with exactly: noted",
    });
    expect(r1.status).toBe(200);
    const first = (await r1.json()) as any;
    expect(first.object).toBe("response");
    expect(first.status).toBe("completed");
    expect(first.id).toStartWith("resp_");
    expect(first.output[0].content[0].type).toBe("output_text");
    expect(first.usage.input_tokens).toBeGreaterThan(0);

    // follow-up WITHOUT resending history — the store must splice it in
    const r2 = await responses({
      previous_response_id: first.id,
      input: "What is my favorite color? One word.",
    });
    expect(r2.status).toBe(200);
    const second = (await r2.json()) as any;
    expect(second.previous_response_id).toBe(first.id);
    const text = second.output
      .find((o: any) => o.type === "message")
      .content[0].text.toLowerCase();
    expect(text).toContain("teal");
  }, 360_000);

  test("responses: streaming emits Codex-required events and stores the result", async () => {
    const r = await responses({
      input: "Count from 1 to 5, digits only.",
      stream: true,
    });
    expect(r.status).toBe(200);
    expect(r.headers.get("content-type")).toContain("text/event-stream");
    const raw = await r.text();
    const events = [...raw.matchAll(/event: ([\w.]+)\ndata: (.*)\n/g)]
      .map((m) => ({ event: m[1]!, data: JSON.parse(m[2]!) }));
    expect(events[0]!.event).toBe("response.created");
    expect(events.at(-1)!.event).toBe("response.completed");
    const text = events
      .filter((e) => e.event === "response.output_text.delta")
      .map((e) => e.data.delta)
      .join("");
    expect(text).toMatch(/1.*2.*3.*4.*5/s);
    const completed = events.at(-1)!.data.response;
    expect(completed.output[0].content[0].text).toBe(text);
    expect(completed.usage.output_tokens).toBeGreaterThan(0);

    // the streamed response is resumable too
    const follow = await responses({
      previous_response_id: completed.id,
      input: "What number came right after 2? One word.",
    });
    expect(follow.status).toBe(200);
    const fb = (await follow.json()) as any;
    const ftext = fb.output
      .find((o: any) => o.type === "message")
      .content[0].text;
    expect(ftext).toMatch(/3|three/i);
  }, 360_000);

  test("responses: real OpenAI SDK client completes a resumed multi-turn conversation", async () => {
    // The Phase 11 exit criterion verbatim: an OpenAI-SDK Responses
    // client, not hand-rolled fetch — the SDK validates wire shapes.
    const { default: OpenAI } = await import("openai");
    const client = new OpenAI({ baseURL: `${base}/v1`, apiKey: "sk-local" });
    const first = await client.responses.create({
      model: "gemma-test",
      input: "Remember the codeword: zebra. Reply with exactly: stored",
      max_output_tokens: 64,
      temperature: 0,
    });
    expect(first.status).toBe("completed");
    const second = await client.responses.create({
      model: "gemma-test",
      previous_response_id: first.id,
      input: "What was the codeword? One word.",
      max_output_tokens: 64,
      temperature: 0,
    });
    expect(second.output_text.toLowerCase()).toContain("zebra");

    // streamed leg through the SDK's event iterator
    const stream = await client.responses.create({
      model: "gemma-test",
      input: "Reply with exactly: ping",
      max_output_tokens: 32,
      temperature: 0,
      stream: true,
    });
    let streamedText = "";
    let completed = false;
    for await (const event of stream) {
      if (event.type === "response.output_text.delta") streamedText += event.delta;
      if (event.type === "response.completed") completed = true;
    }
    expect(completed).toBe(true);
    expect(streamedText.toLowerCase()).toContain("ping");
  }, 360_000);

  test("responses: unknown previous_response_id → 404; store visible in /stats", async () => {
    const r = await responses({ previous_response_id: "resp_nope", input: "x" });
    expect(r.status).toBe(404);
    const err = (await r.json()) as any;
    expect(err.error.type).toBe("invalid_request_error");

    const stats = (await (await fetch(`${base}/stats`)).json()) as any;
    expect(stats.response_store.entries).toBeGreaterThan(0);
    expect(stats.response_store.bytes).toBeGreaterThan(0);
    expect(stats.response_store.max_bytes).toBe(32 * 1024 * 1024);
  });
});
