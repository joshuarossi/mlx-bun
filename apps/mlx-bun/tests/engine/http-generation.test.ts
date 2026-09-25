import { expect, test } from "bun:test";

const modelDir = process.env.MLX_BUN_APP_TEST_MODEL;

// Opt-in: uses an already-downloaded autoregressive model, never downloads one.
// A supplied invalid path or missing native runtime must fail rather than skip.
test.skipIf(!modelDir)("real HTTP generation shares the continuous engine and recovers after stream cancellation", async () => {
  const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
  const { scanSnapshot } = await import("@mlx-bun/hub/registry");
  const model = await scanSnapshot(modelDir!, "test-model");
  if (!model) throw new Error("Model path has no loadable checkpoint");
  const options = parseServeOptions({ values: { port: "0", ctx: "2048", "max-tokens": "8", "prompt-cache": "0.125", "no-open": true }, positionals: [] });
  const app = await startModelServer(model, options);
  const base = new URL(`http://127.0.0.1:${app.port}`);
  try {
    expect((await fetch(base)).headers.get("content-type")).toContain("text/html");
    expect((await fetch(new URL("/health", base))).status).toBe(200);
    const endpoint = new URL("/v1/chat/completions", base);
    const body = { messages: [{ role: "user", content: "Say hello in one sentence." }], max_tokens: 8, temperature: 0 };
    const request = (options: typeof body & { stream?: boolean } = body) => fetch(endpoint, { method: "POST",
      headers: { "content-type": "application/json" }, body: JSON.stringify(options) });
    const baselineResponse = await request();
    expect(baselineResponse.status).toBe(200);
    const baseline = await baselineResponse.json();
    expect(baseline.choices).toHaveLength(1);
    const pair = await Promise.all([request(), request()]);
    for (const response of pair) {
      expect(response.status).toBe(200);
      const repeated = await response.json();
      expect(repeated.choices).toEqual(baseline.choices);
      expect(repeated.usage.prompt_tokens_details.cached_tokens).toBeGreaterThan(0);
    }
    const stream = await request({ ...body, max_tokens: 128, stream: true });
    expect(stream.status).toBe(200);
    const reader = stream.body!.getReader();
    try { expect((await reader.read()).done).toBe(false); }
    finally { await reader.cancel(); }
    const afterCancel = await request();
    expect(afterCancel.status).toBe(200);
    await afterCancel.arrayBuffer();
    await app.close();
    await expect(fetch(base)).rejects.toThrow();
  } finally { await app.close(); }
}, 120_000);
