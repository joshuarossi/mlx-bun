// Real encoder + request pipeline + shared decode. Point at a Qwen artifact
// with visual tensors; no downloads or persistent server.
import { afterAll, describe, expect, spyOn, test } from "bun:test";
import { encode } from "fast-png";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { Qwen35Model } from "../../src/model/qwen3_5";
const path = process.env.MLX_BUN_TEST_QWEN_MEDIA_SERVE_MODEL;
describe.skipIf(!path)("Qwen shared image serving", async () => {
  if (!path) return;
  const { createServer, loadContext } = await import("../../src/server");
  const ctx = await loadContext(path, "qwen-media-test");
  const model = ctx.model as Qwen35Model, batches: number[] = [];
  const forward = model.forwardHiddenAtPositions.bind(model);
  const probe = spyOn(model, "forwardHiddenAtPositions").mockImplementation((ids, caches, positions) => {
    batches.push(ids.shape[0]!); return forward(ids, caches, positions);
  });
  const server = createServer(ctx, 0, { kvQuant: 4 });
  afterAll(() => { server.stop(true); probe.mockRestore(); });
  function request(color: [number, number, number], width: number, maxTokens: number,
    extra: Record<string, unknown> = {}, port = server.port) {
    const data = Uint8Array.from({ length: width * 64 * 3 }, (_, i) => color[i % 3]!);
    const png = Buffer.from(encode({ width, height: 64, channels: 3, data })).toString("base64");
    return fetch(`http://127.0.0.1:${port}/v1/chat/completions`, {
      method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ messages: [{ role: "user", content: [
        { type: "image_url", image_url: { url: `data:image/png;base64,${png}` } },
        { type: "text", text: "Name the dominant color, then describe this image in at least 100 words." },
      ] }], temperature: 0, max_tokens: maxTokens,
      chat_template_kwargs: { enable_thinking: false }, ...extra }),
      signal: AbortSignal.timeout(120_000),
    });
  }
  test("image logprobs use the shared sampler and preserve request-local positions", async () => {
    const before = model.mrope;
    const response = await request([255, 0, 0], 64, 8, { logprobs: true, top_logprobs: 2 });
    expect(response.status).toBe(200);
    const body = await response.json() as any;
    expect(body.usage.lane).toBe("batched");
    expect(body.choices[0].logprobs.content.length).toBeGreaterThan(0);
    expect(Number.isFinite(body.choices[0].logprobs.content[0].logprob)).toBe(true);
    expect(model.mrope).toBe(before);
  }, 120_000);
  test("different image grids share B2 decode and retain their own color", async () => {
    batches.length = 0;
    const responses = await Promise.all([request([255, 0, 0], 64, 32), request([0, 0, 255], 96, 32)]);
    const bodies: any[] = [];
    for (const response of responses) {
      expect(response.status).toBe(200);
      const body = await response.json() as any; bodies.push(body);
      expect(body.usage.lane).toBe("batched");
      expect(body.usage.prompt_tokens_details.cached_tokens).toBe(0);
    }
    expect(bodies[0].choices[0].message.content).toMatch(/red/i);
    expect(bodies[1].choices[0].message.content).toMatch(/blue/i);
    expect(batches).toContain(2);
    expect(model.mrope).toBeNull();
  }, 120_000);
  test("repeated image features reuse the common cache with identical B1 output and logprobs", async () => {
    const { getVisionTower } = await import("../../src/serve/model-host");
    const tower = getVisionTower(ctx) as unknown as import("../../src/vision/qwen3vl-tower").Qwen3VLVisionTower;
    const encode = spyOn(tower, "encode");
    try {
      const first = await request([0, 255, 0], 96, 16, { logprobs: true, top_logprobs: 2 });
      const second = await request([0, 255, 0], 96, 16, { logprobs: true, top_logprobs: 2 });
      expect(first.status).toBe(200); expect(second.status).toBe(200);
      const a = await first.json() as any, b = await second.json() as any;
      expect(b.choices).toEqual(a.choices);
      expect(b.usage.completion_tokens).toBe(a.usage.completion_tokens);
      expect(encode).toHaveBeenCalledTimes(1);
      const stats = await (await fetch(`http://127.0.0.1:${server.port}/stats`)).json() as any;
      expect(stats.prompt_cache.object_hits).toBeGreaterThan(0);
      expect(stats.prompt_cache.bytes).toBeGreaterThan(0);
    } finally { encode.mockRestore(); }
  }, 120_000);
  test("a new server restores encoder features from SSD without running the tower", async () => {
    const { getVisionTower } = await import("../../src/serve/model-host");
    const tower = getVisionTower(ctx) as unknown as import("../../src/vision/qwen3vl-tower").Qwen3VLVisionTower;
    const encode = spyOn(tower, "encode");
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-media-cache-"));
    const options = { kvQuant: 4 as const, promptCacheBytes: 16, ssdCacheDir: dir, ssdCacheVerify: true };
    let firstServer = createServer(ctx, 0, options);
    let restoredServer: ReturnType<typeof createServer> | undefined;
    try {
      const first = await request([255, 0, 255], 96, 8, { logprobs: true, top_logprobs: 2 }, firstServer.port);
      expect(first.status).toBe(200);
      const a = await first.json() as any;
      const flushed = await (await fetch(`http://127.0.0.1:${firstServer.port}/admin/cache/flush`, { method: "POST" })).json() as any;
      expect(flushed.durable).toBe(true);
      const before = await (await fetch(`http://127.0.0.1:${firstServer.port}/stats`)).json() as any;
      expect(before.prompt_cache.bytes).toBe(0);
      expect(before.ssd_cache.entries).toBe(1);
      firstServer.stop(true);
      restoredServer = createServer(ctx, 0, options);
      const second = await request([255, 0, 255], 96, 8, { logprobs: true, top_logprobs: 2 }, restoredServer.port);
      expect(second.status).toBe(200);
      const b = await second.json() as any;
      expect(b.choices).toEqual(a.choices);
      expect(encode).toHaveBeenCalledTimes(1);
      const after = await (await fetch(`http://127.0.0.1:${restoredServer.port}/stats`)).json() as any;
      expect(after.prompt_cache.object_restores).toBe(1);
      const finalFlush = await (await fetch(`http://127.0.0.1:${restoredServer.port}/admin/cache/flush`, { method: "POST" })).json() as any;
      expect(finalFlush.durable).toBe(true);
    } finally {
      firstServer.stop(true); restoredServer?.stop(true); encode.mockRestore();
      rmSync(dir, { recursive: true, force: true });
    }
  }, 120_000);
});
