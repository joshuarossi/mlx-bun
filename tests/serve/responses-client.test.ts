import { expect, test } from "bun:test";
import { createResponsesClient } from "../../src/serve/responses-client";

const request = (body: unknown) => new Request("http://engine/v1/responses", {
  method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body),
});
const output = [{ type: "message", role: "assistant", content: [{ type: "output_text", text: "first reply" }] }];

test("conversation state belongs to the client when its worker is replaced", async () => {
  const client = createResponsesClient();
  await (await client.forward(request({ input: "first", instructions: "be brief" }), async (req) => {
    expect(req.headers.get("x-mlx-bun-response-owner")).toBe("parent");
    return Response.json({ id: "resp_first", output, previous_response_id: null });
  })).json();
  const result = await client.forward(request({ previous_response_id: "resp_first", input: "next" }), async (req) => {
    const body = await req.json() as any;
    expect(body.previous_response_id).toBeUndefined();
    expect(body.instructions).toBe("be brief");
    expect(body.input).toHaveLength(3);
    expect(body.input[0].content).toBe("first");
    expect(body.input[2].content).toBe("next");
    return Response.json({ id: "resp_second", output: [], previous_response_id: null });
  });
  expect((await result.json() as any).previous_response_id).toBe("resp_first");
  expect(client.stats.entries).toBe(2);
});

test("split SSE frames preserve metadata and store only response.completed", async () => {
  const client = createResponsesClient();
  const events = [
    { type: "response.created", response: { id: "resp_stream", output: [], previous_response_id: null } },
    { type: "response.output_text.delta", delta: "héllo" },
    { type: "response.completed", response: { id: "resp_stream", output, previous_response_id: null } },
  ];
  const bytes = new TextEncoder().encode(events.map((e) => `event: ${e.type}\ndata: ${JSON.stringify(e)}\n\n`).join(""));
  const response = await client.forward(request({ input: "first", stream: true }), async () => new Response(new ReadableStream({
    start(controller) {
      for (let i = 0; i < bytes.length; i += 7) controller.enqueue(bytes.slice(i, i + 7));
      controller.close();
    },
  }), { headers: { "content-type": "text/event-stream" } }));
  expect(client.stats.entries).toBe(0);
  const text = await response.text();
  expect(text).toContain("héllo");
  expect(text).toContain("event: response.completed");
  expect(client.stats.entries).toBe(1);
  expect((await client.forward(request({ previous_response_id: "missing", input: "next" }), async () => {
    throw new Error("must not reach worker");
  })).status).toBe(404);
});

test("worker errors are not stored as completed conversations", async () => {
  const client = createResponsesClient();
  const response = await client.forward(request({ input: "first" }), async () => Response.json({ error: "busy" }, { status: 429 }));
  expect(response.status).toBe(429);
  expect(client.stats.entries).toBe(0);
});
