// Server integration (slow tier): ephemeral-port server inside the test
// process (dies with the test), real chat + streaming requests.

import { afterAll, describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();

describe.skipIf(!haveWeights)("openai-compatible server", async () => {
  if (!haveWeights) return;
  const { createServer, loadContext } = await import("../src/server");
  const ctx = await loadContext(SNAPSHOT, "gemma-4-12b-it-optiq");
  const server = createServer(ctx, 0);
  const base = `http://localhost:${server.port}`;
  afterAll(() => server.stop(true));

  test("GET /v1/models lists the model", async () => {
    const res = await fetch(`${base}/v1/models`);
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.data[0].id).toBe("gemma-4-12b-it-optiq");
  });

  test("non-streaming chat completion", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "Reply with exactly the word: ping" }],
        max_tokens: 8,
        temperature: 0,
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.object).toBe("chat.completion");
    expect(body.choices[0].message.role).toBe("assistant");
    expect(body.choices[0].message.content.toLowerCase()).toContain("ping");
    expect(body.usage.prompt_tokens).toBeGreaterThan(0);
    expect(body.usage.completion_tokens).toBeGreaterThan(0);
  }, 120_000);

  test("streaming chat completion (SSE)", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "Count from 1 to 5, digits only." }],
        max_tokens: 24,
        temperature: 0,
        stream: true,
      }),
    });
    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toContain("text/event-stream");
    const text = await res.text();
    const events = text.split("\n\n").filter((l) => l.startsWith("data: "))
      .map((l) => l.slice(6));
    expect(events.at(-1)).toBe('"[DONE]"');
    const chunks = events.slice(0, -1).map((e) => JSON.parse(e));
    const content = chunks
      .flatMap((c: any) => c.choices?.[0]?.delta?.content ?? [])
      .join("");
    expect(content).toContain("1");
    const final = chunks.at(-1) as any;
    expect(final.choices[0].finish_reason).toBeTruthy();
    expect(final.usage.completion_tokens).toBeGreaterThan(0);
  }, 120_000);

  test("malformed request → 400", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ messages: [] }),
    });
    expect(res.status).toBe(400);
  });
});
