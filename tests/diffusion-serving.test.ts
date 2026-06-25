// GATED integration: DiffusionGemma served end-to-end through the HTTP server.
// Ephemeral in-process server (dies with the test). The non-autoregressive
// denoising engine is routed through generate()'s diffusion branch and streamed
// via the normal token machinery (OpenAI + Anthropic + SSE).
//
//   MLX_BUN_TEST_DIFFUSION=1 bun test tests/diffusion-serving.test.ts
//
// The engine NUMERICS are gated by tests/diffusion-gen-parity.test.ts
// (token-for-token vs optiq). This gates the WIRING: that a diffusion model
// loads, answers chat (stream + non-stream), and reports usage — no AR forward
// is ever called on it (createModel returns DiffusionGemmaModel; the gateway
// keeps it on the serial lane).

import { afterAll, describe, expect, test } from "bun:test";
import { SNAPSHOT_DIFFUSION, snapshotDiffusionAvailable } from "./paths";

const optIn = process.env.MLX_BUN_TEST_DIFFUSION === "1";
const haveWeights = await snapshotDiffusionAvailable();

describe.skipIf(!optIn || !haveWeights)("DiffusionGemma HTTP serving", async () => {
  if (!optIn || !haveWeights) return;
  const { createServer, loadContext } = await import("../src/server");
  const ctx = await loadContext(SNAPSHOT_DIFFUSION, "diffusiongemma");
  const server = createServer(ctx, 0, {});
  const base = `http://localhost:${server.port}`;
  afterAll(() => server.stop(true));

  const chat = (body: Record<string, unknown>) =>
    fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(body),
    });

  test("/v1/models lists the diffusion model", async () => {
    const m = (await (await fetch(`${base}/v1/models`)).json()) as any;
    expect(m.data[0].id).toContain("diffusiongemma");
  });

  test("non-streaming chat answers with coherent text + stop", async () => {
    const r = await chat({
      messages: [{ role: "user", content: "What is the capital of France? One word." }],
      max_tokens: 32,
    });
    expect(r.status).toBe(200);
    const b = (await r.json()) as any;
    const content = b.choices[0].message.content as string;
    expect(content.length).toBeGreaterThan(0);
    expect(content.toLowerCase()).toContain("paris");
    expect(b.choices[0].finish_reason).toBe("stop");
    expect(b.usage.completion_tokens).toBeGreaterThan(0);
  }, 120_000);

  test("streaming chat emits content deltas then [DONE]", async () => {
    const r = await chat({
      messages: [{ role: "user", content: "Say hello." }],
      max_tokens: 24,
      stream: true,
    });
    expect(r.status).toBe(200);
    const text = await r.text();
    expect(text).toContain("data:");
    expect(text).toContain("[DONE]");
    // at least one content delta carried text
    const deltas = [...text.matchAll(/"content":"([^"]+)"/g)].map((m) => m[1]);
    expect(deltas.join("").trim().length).toBeGreaterThan(0);
  }, 120_000);

  test("Anthropic /v1/messages answers", async () => {
    const r = await fetch(`${base}/v1/messages`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        model: "diffusiongemma",
        max_tokens: 24,
        messages: [{ role: "user", content: "Reply with the word: ok" }],
      }),
    });
    expect(r.status).toBe(200);
    const b = (await r.json()) as any;
    expect(b.content[0].text.length).toBeGreaterThan(0);
  }, 120_000);
});
