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

  test("second turn hits the prompt cache", async () => {
    const turn1 = [{ role: "user", content: "Pick a color and say only its name." }];
    const res1 = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ messages: turn1, max_tokens: 16, temperature: 0 }),
    });
    const body1 = (await res1.json()) as any;
    // other tests may have seeded a few shared-prefix tokens (<bos><|turn>user…)
    expect(body1.usage.prompt_tokens_details.cached_tokens).toBeLessThan(
      body1.usage.prompt_tokens / 2,
    );

    const turn2 = [
      ...turn1,
      { role: "assistant", content: body1.choices[0].message.content },
      { role: "user", content: "Why that one?" },
    ];
    const res2 = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ messages: turn2, max_tokens: 24, temperature: 0 }),
    });
    const body2 = (await res2.json()) as any;
    // Reuse extends to the last assistant turn's `<|turn>model\n` boundary;
    // the ~4 thought-channel prefill tokens after it never re-render and
    // re-prefill each turn. So expect nearly all of turn-1's prompt.
    expect(body2.usage.prompt_tokens_details.cached_tokens).toBeGreaterThanOrEqual(
      body1.usage.prompt_tokens - 6,
    );
    expect(body2.usage.prompt_tokens_details.cached_tokens).toBeGreaterThan(8);

    const stats = (await (await fetch(`${base}/stats`)).json()) as any;
    expect(stats.prompt_cache.hits).toBeGreaterThanOrEqual(1);
    expect(stats.prompt_cache.bytes).toBeGreaterThan(0);
    expect(stats.prompt_cache.bytes).toBeLessThanOrEqual(stats.prompt_cache.max_bytes);
  }, 240_000);

  test("vision: image_url data: URL describes the image", async () => {
    const png = await Bun.file("tests/fixtures/grad-768.png").arrayBuffer();
    const dataUrl = `data:image/png;base64,${Buffer.from(png).toString("base64")}`;
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{
          role: "user",
          content: [
            { type: "image_url", image_url: { url: dataUrl } },
            { type: "text", text: "Describe this image in one short sentence." },
          ],
        }],
        max_tokens: 32,
        temperature: 0,
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    const content = body.choices[0].message.content.toLowerCase();
    expect(content).toMatch(/gradient|color/);
    // image soft tokens included in prompt accounting
    expect(body.usage.prompt_tokens).toBeGreaterThan(250);
  }, 240_000);

  test("malformed request → 400", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ messages: [] }),
    });
    expect(res.status).toBe(400);
  });
});
