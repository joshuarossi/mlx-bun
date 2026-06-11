// Responses API translation layer + store (fast tier — pure logic).
// Event-chain expectations mirror the oracle's docstring order
// (optiq/responses_shim.py): Codex hard-requires output_text.delta and
// response.completed.

import { describe, expect, test } from "bun:test";
import {
  ResponseStore,
  ResponsesStreamTranslator,
  chatJsonToResponses,
  outputItemsToInputItems,
  responsesToChatBody,
  translateOpenAiSseToResponses,
} from "../src/responses";

describe("responsesToChatBody", () => {
  test("string input + instructions → system prefix", () => {
    const oai = responsesToChatBody({
      model: "m",
      instructions: "be terse",
      input: "hello",
      max_output_tokens: 9,
      temperature: 0.1,
    });
    expect(oai.messages).toEqual([
      { role: "system", content: "be terse" },
      { role: "user", content: "hello" },
    ]);
    expect(oai.max_tokens).toBe(9);
    expect(oai.temperature).toBe(0.1);
  });

  test("system/developer items merge into ONE leading system message", () => {
    const oai = responsesToChatBody({
      instructions: "from instructions",
      input: [
        { type: "message", role: "developer", content: "from developer" },
        { role: "user", content: "hi" },
      ],
    });
    const msgs = oai.messages as any[];
    expect(msgs[0]).toEqual({
      role: "system",
      content: "from instructions\n\nfrom developer",
    });
    expect(msgs).toHaveLength(2);
  });

  test("function_call + function_call_output items → tool_calls/tool messages", () => {
    const oai = responsesToChatBody({
      input: [
        { role: "user", content: "weather?" },
        { type: "function_call", call_id: "call_1", name: "get_weather", arguments: '{"city":"Paris"}' },
        { type: "function_call_output", call_id: "call_1", output: "Snow, -3C" },
      ],
    });
    const msgs = oai.messages as any[];
    expect(msgs[1].role).toBe("assistant");
    expect(msgs[1].tool_calls[0].id).toBe("call_1");
    expect(msgs[1].tool_calls[0].function.name).toBe("get_weather");
    expect(msgs[2]).toEqual({ role: "tool", tool_call_id: "call_1", content: "Snow, -3C" });
  });

  test("content part arrays flatten (input_text/output_text)", () => {
    const oai = responsesToChatBody({
      input: [{
        role: "user",
        content: [{ type: "input_text", text: "a" }, { type: "input_text", text: "b" }],
      }],
    });
    expect((oai.messages as any[])[0].content).toBe("ab");
  });

  test("flat tools nest; built-ins dropped; tool_choice name form translates", () => {
    const oai = responsesToChatBody({
      input: "x",
      tools: [
        { type: "function", name: "f", description: "d", parameters: { type: "object" }, strict: true },
        { type: "web_search" },
      ],
      tool_choice: { type: "function", name: "f" },
    });
    expect(oai.tools as any[]).toEqual([{
      type: "function",
      function: { name: "f", description: "d", parameters: { type: "object" }, strict: true },
    }]);
    expect(oai.tool_choice).toEqual({ type: "function", function: { name: "f" } });
  });
});

describe("outputItemsToInputItems", () => {
  test("message + function_call survive; reasoning dropped", () => {
    const items = outputItemsToInputItems([
      { type: "reasoning", summary: [{ type: "summary_text", text: "hmm" }] },
      {
        type: "message", role: "assistant", status: "completed",
        content: [{ type: "output_text", text: "hi", annotations: [] }],
      },
      { type: "function_call", id: "fc_1", call_id: "call_9", name: "f", arguments: "{}" },
    ]);
    expect(items).toEqual([
      {
        type: "message", role: "assistant",
        content: [{ type: "output_text", text: "hi", annotations: [] }],
      },
      { type: "function_call", call_id: "call_9", name: "f", arguments: "{}" },
    ]);
  });
});

describe("chatJsonToResponses", () => {
  test("text + tool_calls + usage with cached tokens", () => {
    const r = chatJsonToResponses(
      {
        choices: [{
          message: {
            content: "hi",
            tool_calls: [{
              id: "call_1", type: "function",
              function: { name: "f", arguments: '{"x":1}' },
            }],
          },
          finish_reason: "tool_calls",
        }],
        usage: {
          prompt_tokens: 4, completion_tokens: 2,
          prompt_tokens_details: { cached_tokens: 3 },
        },
      },
      "m",
      "resp_prev",
    ) as any;
    expect(r.object).toBe("response");
    expect(r.status).toBe("completed");
    expect(r.previous_response_id).toBe("resp_prev");
    expect(r.output[0].type).toBe("message");
    expect(r.output[0].content[0]).toEqual({ type: "output_text", text: "hi", annotations: [] });
    expect(r.output[1]).toMatchObject({
      type: "function_call", call_id: "call_1", name: "f", arguments: '{"x":1}',
    });
    expect(r.usage).toMatchObject({
      input_tokens: 4, output_tokens: 2, total_tokens: 6,
      input_tokens_details: { cached_tokens: 3 },
    });
    expect(r.id).toStartWith("resp_");
  });

  test("length → incomplete", () => {
    const r = chatJsonToResponses(
      { choices: [{ message: { content: "x" }, finish_reason: "length" }] },
      "m",
    ) as any;
    expect(r.status).toBe("incomplete");
  });
});

const parseFrames = (frames: string[]) =>
  frames.map((f) => {
    const event = /event: (.*)\n/.exec(f)![1]!;
    const data = JSON.parse(/data: (.*)\n\n/.exec(f)![1]!);
    return { event, data };
  });

describe("ResponsesStreamTranslator", () => {
  test("text stream: oracle event chain incl. Codex-required events", () => {
    const t = new ResponsesStreamTranslator("m");
    const frames = [
      ...t.addChunk({ choices: [{ delta: { role: "assistant", content: "" } }] }),
      ...t.addChunk({ choices: [{ delta: { content: "he" } }] }),
      ...t.addChunk({ choices: [{ delta: { content: "y" } }] }),
      ...t.addChunk({
        choices: [{ delta: {}, finish_reason: "stop" }],
        usage: { prompt_tokens: 3, completion_tokens: 2 },
      }),
      ...t.finalize(),
    ];
    const ev = parseFrames(frames);
    expect(ev.map((e) => e.event)).toEqual([
      "response.created",
      "response.in_progress",
      "response.output_item.added",
      "response.content_part.added",
      "response.output_text.delta",
      "response.output_text.delta",
      "response.output_text.done",
      "response.content_part.done",
      "response.output_item.done",
      "response.completed",
    ]);
    const done = ev.at(-1)!.data.response;
    expect(done.status).toBe("completed");
    expect(done.output[0].content[0].text).toBe("hey");
    expect(done.usage.output_tokens).toBe(2); // real usage, not chunk count
    expect(t.finalResponse()).toEqual(done);
  });

  test("tool call stream: function_call item + arguments delta/done", () => {
    const t = new ResponsesStreamTranslator("m");
    const frames = [
      ...t.addChunk({ choices: [{ delta: { content: "ok " } }] }),
      ...t.addChunk({
        choices: [{
          delta: {
            tool_calls: [{
              index: 0, id: "call_7", type: "function",
              function: { name: "get_weather", arguments: '{"city":"Tokyo"}' },
            }],
          },
        }],
      }),
      ...t.addChunk({ choices: [{ delta: {}, finish_reason: "tool_calls" }] }),
      ...t.finalize(),
    ];
    const ev = parseFrames(frames);
    const names = ev.map((e) => e.event);
    // text item closes before the function_call item opens
    expect(names.indexOf("response.output_item.done")).toBeLessThan(
      names.lastIndexOf("response.output_item.added"),
    );
    expect(names).toContain("response.function_call_arguments.delta");
    expect(names).toContain("response.function_call_arguments.done");
    const completed = ev.at(-1)!.data.response;
    const fc = completed.output.find((o: any) => o.type === "function_call");
    expect(fc).toMatchObject({
      call_id: "call_7", name: "get_weather", arguments: '{"city":"Tokyo"}',
    });
  });
});

describe("translateOpenAiSseToResponses", () => {
  test("end-to-end bytes + onComplete capture", async () => {
    const enc = new TextEncoder();
    const upstream = new ReadableStream<Uint8Array>({
      start(c) {
        const send = (o: unknown) => c.enqueue(enc.encode(`data: ${JSON.stringify(o)}\n\n`));
        send({ choices: [{ delta: { content: "yo" } }] });
        send({
          choices: [{ delta: {}, finish_reason: "stop" }],
          usage: { prompt_tokens: 1, completion_tokens: 1 },
        });
        send("[DONE]");
        c.close();
      },
    });
    let captured: any = null;
    const out = translateOpenAiSseToResponses(upstream, "m", "resp_x", (f) => (captured = f));
    const text = await new Response(out).text();
    expect(text).toContain("event: response.output_text.delta");
    expect(text).toContain("event: response.completed");
    expect(captured.output[0].content[0].text).toBe("yo");
    expect(captured.previous_response_id).toBe("resp_x");
  });
});

describe("ResponseStore", () => {
  test("put/get round-trip with LRU touch", () => {
    const s = new ResponseStore();
    s.put("a", { input: [{ x: 1 }], output: [{ y: 2 }], instructions: "i" });
    expect(s.get("a")).toEqual({ input: [{ x: 1 }], output: [{ y: 2 }], instructions: "i" });
    expect(s.get("missing")).toBeNull();
    expect(s.size).toBe(1);
    expect(s.totalBytes).toBeGreaterThan(0);
  });

  test("byte-capped LRU evicts oldest first", () => {
    const s = new ResponseStore(60_000, 200);
    const big = "x".repeat(80); // ~86 bytes/entry: 3 entries overflow the 200-byte cap
    s.put("a", { input: [big], output: [], instructions: null });
    s.put("b", { input: [big], output: [], instructions: null });
    s.get("a"); // touch a → b is now LRU
    s.put("c", { input: [big], output: [], instructions: null }); // over cap
    expect(s.get("b")).toBeNull(); // evicted
    expect(s.get("a")).not.toBeNull();
    expect(s.get("c")).not.toBeNull();
    expect(s.totalBytes).toBeLessThanOrEqual(200);
  });

  test("TTL expiry drops entries lazily", async () => {
    const s = new ResponseStore(10); // 10 ms TTL
    s.put("a", { input: ["x"], output: [], instructions: null });
    await Bun.sleep(25);
    expect(s.get("a")).toBeNull();
    expect(s.size).toBe(0);
  });
});
