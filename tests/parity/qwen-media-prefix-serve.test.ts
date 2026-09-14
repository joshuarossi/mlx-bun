import { describe, expect, test } from "bun:test";
import { encode } from "fast-png";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const path = process.env.MLX_BUN_TEST_QWEN_MEDIA_SERVE_MODEL;
const videoPath = process.env.MLX_BUN_TEST_QWEN_MEDIA_VIDEO;
describe.skipIf(!path)("Qwen prepared-media prefix reuse", async () => {
  if (!path) return;
  const { createServer, loadContext } = await import("../../src/server");
  const ctx = await loadContext(path, "qwen-media-prefix");
  function image(color: [number, number, number]) {
    const data = Uint8Array.from({ length: 64 * 64 * 3 }, (_, i) => color[i % 3]!);
    const png = Buffer.from(encode({ width: 64, height: 64, channels: 3, data })).toString("base64");
    return { type: "image_url", image_url: { url: `data:image/png;base64,${png}` } };
  }
  const requestMessages = (media: unknown) => [{ role: "user", content: [media,
    { type: "text", text: "Name the dominant color, then describe it in a sentence." },
  ] }];
  for (const storage of ["ram", "ssd"] as const) for (const kv of ["kv4", "k8v3"] as const)
    test(`${storage} ${kv} retains generated media history and isolates different images`, async () => {
      const dir = mkdtempSync(join(tmpdir(), "mlx-qwen-media-prefix-"));
      const options = { ...(kv === "kv4" ? { kvQuant: 4 as const }
        : { turboQuant: { kBits: 8 as const, vBits: 3 as const } }),
        ...(storage === "ssd" ? { promptCacheBytes: 16, ssdCacheDir: dir, ssdCacheVerify: true }
          : { promptCacheBytes: 2 ** 30 }),
      };
      let server = createServer(ctx, 0, options);
      const chat = async (messages: unknown[]) => {
        const response = await fetch(`http://127.0.0.1:${server.port}/v1/chat/completions`, {
          method: "POST", headers: { "content-type": "application/json" },
          body: JSON.stringify({ messages, temperature: 0, seed: 42, max_tokens: 16,
            chat_template_kwargs: { enable_thinking: false } }), signal: AbortSignal.timeout(120_000),
        });
        const body = await response.json() as any;
        expect(response.status, JSON.stringify(body)).toBe(200);
        expect(body.usage.lane).toBe("batched"); return body;
      };
      const flush = async () => {
        const body = await (await fetch(`http://127.0.0.1:${server.port}/admin/cache/flush`, { method: "POST" })).json() as any;
        expect(body.durable).toBe(true);
      };
      try {
        const messages = requestMessages(image([255, 0, 0]));
        const first = await chat(messages);
        expect(first.choices[0].message.content).toMatch(/red/i);
        expect(first.usage.prompt_tokens_details.cached_tokens).toBe(0);
        if (storage === "ssd") { await flush(); server.stop(true); server = createServer(ctx, 0, options); }
        const next = await chat([...messages, { role: "assistant", content: first.choices[0].message.content },
          { role: "user", content: "Repeat the color, in one word." }]);
        expect(next.choices[0].message.content).toMatch(/red/i);
        expect(next.usage.prompt_tokens_details.cached_tokens).toBeGreaterThan(first.usage.prompt_tokens - 1);
        const blue = await chat(requestMessages(image([0, 0, 255])));
        expect(blue.choices[0].message.content).toMatch(/blue/i);
        expect(blue.usage.prompt_tokens_details.cached_tokens).toBe(0);
        if (storage === "ssd") await flush();
      } finally { server.stop(true); rmSync(dir, { recursive: true, force: true }); }
    }, 120_000);
  test.skipIf(!videoPath || !existsSync(videoPath))("video timestamps and mRoPE survive a generated-history cache hit", async () => {
    const server = createServer(ctx, 0, { kvQuant: 4 });
    try {
      const media = { type: "video", data: Buffer.from(await Bun.file(videoPath!).arrayBuffer()).toString("base64") };
      const messages = requestMessages(media);
      async function chat(input: unknown[]) {
        const response = await fetch(`http://127.0.0.1:${server.port}/v1/chat/completions`, {
          method: "POST", headers: { "content-type": "application/json" },
          body: JSON.stringify({ messages: input, temperature: 0, seed: 42, max_tokens: 16,
            chat_template_kwargs: { enable_thinking: false } }),
        });
        const body = await response.json() as any;
        expect(response.status, JSON.stringify(body)).toBe(200); return body;
      }
      const first = await chat(messages);
      expect(first.choices[0].message.content).toMatch(/red/i);
      const second = await chat([...messages, { role: "assistant", content: first.choices[0].message.content },
        { role: "user", content: "Repeat the color." }]);
      expect(second.choices[0].message.content).toMatch(/red/i);
      expect(second.usage.prompt_tokens_details.cached_tokens).toBeGreaterThan(first.usage.prompt_tokens - 1);
    } finally { server.stop(true); }
  }, 120_000);
});
