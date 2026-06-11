// Anthropic Messages translation layer (fast tier — pure logic, no
// weights). Event-grammar expectations mirror the oracle shim's
// documented order (optiq/anthropic_shim.py docstring).

import { describe, expect, test } from "bun:test";
import {
  AnthropicStreamTranslator,
  anthropicToChatBody,
  chatJsonToAnthropic,
  translateOpenAiSse,
} from "../src/anthropic";

describe("anthropicToChatBody", () => {
  test("system + string messages + sampling params", () => {
    const oai = anthropicToChatBody({
      model: "m",
      system: "be brief",
      messages: [{ role: "user", content: "hi" }],
      max_tokens: 7,
      temperature: 0.2,
      top_p: 0.9,
      top_k: 5,
      stop_sequences: ["END"],
    });
    expect(oai.messages).toEqual([
      { role: "system", content: "be brief" },
      { role: "user", content: "hi" },
    ]);
    expect(oai.max_tokens).toBe(7);
    expect(oai.temperature).toBe(0.2);
    expect(oai.top_p).toBe(0.9);
    expect(oai.top_k).toBe(5);
    expect(oai.stop).toEqual(["END"]);
    expect(oai.stream).toBeUndefined();
  });

  test("system as content blocks flattens to text", () => {
    const oai = anthropicToChatBody({
      system: [{ type: "text", text: "a" }, { type: "text", text: "b" }],
      messages: [{ role: "user", content: "x" }],
    });
    expect((oai.messages as any[])[0]).toEqual({ role: "system", content: "a\nb" });
  });

  test("tool_use block → assistant tool_calls (native, not inline text)", () => {
    const oai = anthropicToChatBody({
      messages: [
        { role: "user", content: "weather?" },
        {
          role: "assistant",
          content: [
            { type: "text", text: "checking" },
            { type: "tool_use", id: "toolu_1", name: "get_weather", input: { city: "Paris" } },
          ],
        },
      ],
    });
    const asst = (oai.messages as any[])[1];
    expect(asst.role).toBe("assistant");
    expect(asst.content).toBe("checking");
    expect(asst.tool_calls).toHaveLength(1);
    expect(asst.tool_calls[0].id).toBe("toolu_1");
    expect(asst.tool_calls[0].function.name).toBe("get_weather");
    expect(JSON.parse(asst.tool_calls[0].function.arguments)).toEqual({ city: "Paris" });
  });

  test("tool_result block → role:tool message with tool_call_id", () => {
    const oai = anthropicToChatBody({
      messages: [
        {
          role: "user",
          content: [
            { type: "tool_result", tool_use_id: "toolu_1", content: "Snow, -3C" },
            { type: "text", text: "and now?" },
          ],
        },
      ],
    });
    const msgs = oai.messages as any[];
    expect(msgs[0]).toEqual({ role: "tool", tool_call_id: "toolu_1", content: "Snow, -3C" });
    expect(msgs[1]).toEqual({ role: "user", content: "and now?" });
  });

  test("tool_result content-block list flattens", () => {
    const oai = anthropicToChatBody({
      messages: [
        {
          role: "user",
          content: [{
            type: "tool_result",
            tool_use_id: "t",
            content: [{ type: "text", text: "line1" }, { type: "text", text: "line2" }],
          }],
        },
      ],
    });
    expect((oai.messages as any[])[0].content).toBe("line1\nline2");
  });

  test("image blocks → image_url vision parts (base64 and url)", () => {
    const oai = anthropicToChatBody({
      messages: [
        {
          role: "user",
          content: [
            { type: "text", text: "what is this?" },
            { type: "image", source: { type: "base64", media_type: "image/png", data: "AAAA" } },
            { type: "image", source: { type: "url", url: "https://x/y.png" } },
          ],
        },
      ],
    });
    const parts = (oai.messages as any[])[0].content;
    expect(parts[0]).toEqual({ type: "text", text: "what is this?" });
    expect(parts[1].image_url.url).toBe("data:image/png;base64,AAAA");
    expect(parts[2].image_url.url).toBe("https://x/y.png");
  });

  test("Anthropic tools map to OpenAI function tools; thinking dropped", () => {
    const oai = anthropicToChatBody({
      messages: [
        {
          role: "assistant",
          content: [
            { type: "thinking", thinking: "hmm" },
            { type: "text", text: "answer" },
          ],
        },
        { role: "user", content: "next" },
      ],
      tools: [
        {
          name: "get_weather",
          description: "weather",
          input_schema: { type: "object", properties: {} },
        },
        { type: "web_search_20250305", name: "web_search" } as any, // server tool: dropped
      ],
    });
    expect((oai.messages as any[])[0]).toEqual({ role: "assistant", content: "answer" });
    expect(oai.tools as any[]).toHaveLength(1);
    expect((oai.tools as any[])[0]).toEqual({
      type: "function",
      function: {
        name: "get_weather",
        description: "weather",
        parameters: { type: "object", properties: {} },
      },
    });
  });

  test("empty messages rejected", () => {
    expect(() => anthropicToChatBody({ messages: [] })).toThrow();
  });
});

describe("chatJsonToAnthropic", () => {
  test("text + usage (with cache read)", () => {
    const a = chatJsonToAnthropic(
      {
        choices: [{ message: { role: "assistant", content: "hi" }, finish_reason: "stop" }],
        usage: {
          prompt_tokens: 10, completion_tokens: 3,
          prompt_tokens_details: { cached_tokens: 8 },
        },
      },
      "m",
    ) as any;
    expect(a.type).toBe("message");
    expect(a.role).toBe("assistant");
    expect(a.content).toEqual([{ type: "text", text: "hi" }]);
    expect(a.stop_reason).toBe("end_turn");
    expect(a.usage).toEqual({
      input_tokens: 10, output_tokens: 3, cache_read_input_tokens: 8,
    });
    expect(a.id).toStartWith("msg_");
  });

  test("tool_calls → tool_use blocks + stop_reason tool_use", () => {
    const a = chatJsonToAnthropic(
      {
        choices: [{
          message: {
            role: "assistant",
            content: null,
            tool_calls: [{
              id: "call_1", type: "function",
              function: { name: "f", arguments: '{"x":1}' },
            }],
          },
          finish_reason: "tool_calls",
        }],
        usage: { prompt_tokens: 1, completion_tokens: 1 },
      },
      "m",
    ) as any;
    expect(a.content).toEqual([{ type: "tool_use", id: "call_1", name: "f", input: { x: 1 } }]);
    expect(a.stop_reason).toBe("tool_use");
  });

  test("length → max_tokens", () => {
    const a = chatJsonToAnthropic(
      { choices: [{ message: { content: "x" }, finish_reason: "length" }] },
      "m",
    ) as any;
    expect(a.stop_reason).toBe("max_tokens");
  });
});

const parseFrames = (frames: string[]) =>
  frames.map((f) => {
    const event = /event: (.*)\n/.exec(f)![1];
    const data = JSON.parse(/data: (.*)\n\n/.exec(f)![1]!);
    return { event, data };
  });

describe("AnthropicStreamTranslator", () => {
  test("text stream: oracle event grammar order", () => {
    const t = new AnthropicStreamTranslator("m");
    const frames = [
      ...t.addChunk({ choices: [{ delta: { role: "assistant", content: "" } }] }),
      ...t.addChunk({ choices: [{ delta: { content: "Hel" } }] }),
      ...t.addChunk({ choices: [{ delta: { content: "lo" } }] }),
      ...t.addChunk({
        choices: [{ delta: {}, finish_reason: "stop" }],
        usage: { prompt_tokens: 5, completion_tokens: 2 },
      }),
      ...t.finalize(),
    ];
    const ev = parseFrames(frames);
    expect(ev.map((e) => e.event)).toEqual([
      "message_start",
      "content_block_start",
      "content_block_delta",
      "content_block_delta",
      "content_block_stop",
      "message_delta",
      "message_stop",
    ]);
    expect(ev[1]!.data.content_block.type).toBe("text");
    expect(ev[2]!.data.delta).toEqual({ type: "text_delta", text: "Hel" });
    const md = ev.at(-2)!.data;
    expect(md.delta.stop_reason).toBe("end_turn");
    expect(md.usage.output_tokens).toBe(2); // real usage, not chunk count
  });

  test("tool_calls delta → tool_use block with input_json_delta", () => {
    const t = new AnthropicStreamTranslator("m");
    const frames = [
      ...t.addChunk({ choices: [{ delta: { content: "I'll check. " } }] }),
      ...t.addChunk({
        choices: [{
          delta: {
            tool_calls: [{
              index: 0, id: "call_9", type: "function",
              function: { name: "get_weather", arguments: '{"city":"Paris"}' },
            }],
          },
        }],
      }),
      ...t.addChunk({ choices: [{ delta: {}, finish_reason: "tool_calls" }] }),
      ...t.finalize(),
    ];
    const ev = parseFrames(frames);
    const types = ev.map((e) => e.event);
    // text block closes before the tool_use block opens
    expect(types).toEqual([
      "message_start",
      "content_block_start", // text
      "content_block_delta",
      "content_block_stop",
      "content_block_start", // tool_use
      "content_block_delta", // input_json_delta
      "content_block_stop",
      "message_delta",
      "message_stop",
    ]);
    const open = ev[4]!.data;
    expect(open.content_block).toEqual({
      type: "tool_use", id: "call_9", name: "get_weather", input: {},
    });
    expect(ev[5]!.data.delta).toEqual({
      type: "input_json_delta", partial_json: '{"city":"Paris"}',
    });
    expect(ev.at(-2)!.data.delta.stop_reason).toBe("tool_use");
  });

  test("empty generation still emits one empty text block", () => {
    const t = new AnthropicStreamTranslator("m");
    const ev = parseFrames(t.finalize());
    expect(ev.map((e) => e.event)).toEqual([
      "message_start",
      "content_block_start",
      "content_block_stop",
      "message_delta",
      "message_stop",
    ]);
  });
});

describe("translateOpenAiSse", () => {
  test("translates an OpenAI SSE byte stream end-to-end (quoted [DONE])", async () => {
    const enc = new TextEncoder();
    const upstream = new ReadableStream<Uint8Array>({
      start(c) {
        const send = (o: unknown) => c.enqueue(enc.encode(`data: ${JSON.stringify(o)}\n\n`));
        send({ choices: [{ delta: { role: "assistant", content: "" } }] });
        send({ choices: [{ delta: { content: "hey" } }] });
        send({
          choices: [{ delta: {}, finish_reason: "stop" }],
          usage: { prompt_tokens: 2, completion_tokens: 1 },
        });
        send("[DONE]"); // our server's quoted terminator
        c.close();
      },
    });
    const out = translateOpenAiSse(upstream, "m");
    const text = await new Response(out).text();
    const events = [...text.matchAll(/event: (\w+)/g)].map((m) => m[1]);
    expect(events).toEqual([
      "message_start",
      "content_block_start",
      "content_block_delta",
      "content_block_stop",
      "message_delta",
      "message_stop",
    ]);
    expect(text).toContain('"text_delta","text":"hey"');
    expect(text).toContain('"output_tokens":1');
  });
});
