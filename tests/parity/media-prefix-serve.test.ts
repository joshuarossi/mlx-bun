// Real media identity + shared generated-prefix storage. No downloads.
import { afterAll, describe, expect, test } from "bun:test";
import { encode } from "fast-png";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const path = process.env.MLX_BUN_TEST_MEDIA_PREFIX_MODEL;
describe.skipIf(!path)("shared media prefix reuse", async () => {
  if (!path) return;
  const { configureRuntime } = await import("../../src/runtime-config");
  const restore = configureRuntime({ MLX_BUN_MEDIA_PREFIX_CACHE: "1" });
  const { createServer, loadContext } = await import("../../src/server");
  const ctx = await loadContext(path, "media-prefix-test");
  afterAll(restore);
  function messages(color: [number, number, number], instruction = "Name this image's single color. Answer with one word.") {
    const data = Uint8Array.from({ length: 64 * 64 * 3 }, (_, i) => color[i % 3]!);
    const png = Buffer.from(encode({ width: 64, height: 64, channels: 3, data })).toString("base64");
    return [{ role: "user", content: [
      { type: "image_url", image_url: { url: `data:image/png;base64,${png}` } },
      { type: "text", text: instruction },
    ] }];
  }
  for (const storage of ["ram", "ssd"] as const) for (const format of ["bf16", "kv4", "k8v3", "kv4-delayed", "k8v3-delayed"] as const) test(`${storage} ${format}: reuse media history, isolate different media, and retain generated outputs`, async () => {
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-media-prefix-"));
    const options = { ...(storage === "ssd"
      ? { promptCacheBytes: 16, ssdCacheDir: dir, ssdCacheVerify: true }
      : { promptCacheBytes: 512 * 2 ** 20 }),
      ...(format === "bf16" ? {} : format.startsWith("kv4")
        ? { kvQuant: 4 as const, quantizedKvStart: format.endsWith("delayed") ? 8 : 0 }
        : { turboQuant: { kBits: 8 as const, vBits: 3 as const }, quantizedKvStart: format.endsWith("delayed") ? 8 : 0 }),
    };
    let server = createServer(ctx, 0, options);
    const red = messages([255, 0, 0]);
    const chat = async (input: unknown[]) => {
      const response = await fetch(`http://127.0.0.1:${server.port}/v1/chat/completions`, {
        method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ messages: input, temperature: 0, seed: 42, max_tokens: 16 }),
        signal: AbortSignal.timeout(120_000),
      });
      const body = await response.json() as any;
      expect(response.status, JSON.stringify(body)).toBe(200);
      expect(body.usage.lane).toBe("batched");
      return body;
    };
    const flush = async () => {
      const result = await (await fetch(`http://127.0.0.1:${server.port}/admin/cache/flush`, { method: "POST" })).json() as any;
      expect(result.durable).toBe(true);
    };
    try {
      const first = await chat(red);
      expect(first.choices[0].message.content).toMatch(/red/i);
      expect(first.usage.prompt_tokens_details.cached_tokens).toBe(0);
      if (storage === "ssd") { await flush(); server.stop(true); server = createServer(ctx, 0, options); }
      const followup = await chat([...red, { role: "assistant", content: first.choices[0].message.content },
        { role: "user", content: "Repeat that color, in one word." }]);
      expect(followup.choices[0].message.content).toMatch(/red/i);
      expect(followup.usage.prompt_tokens_details.cached_tokens).toBeGreaterThan(first.usage.prompt_tokens - 1);
      if (storage === "ssd") await flush();
      const repeated = await chat(red);
      expect(repeated.choices[0].message.content).toBe(first.choices[0].message.content);
      // Atomic media prefill can cross the delayed-conversion threshold.
      // The retained KV cannot rewind before that precision boundary.
      if (format.endsWith("delayed")) expect(repeated.usage.prompt_tokens_details.cached_tokens).toBe(0);
      else expect(repeated.usage.prompt_tokens_details.cached_tokens).toBeGreaterThan(0);
      const different = await chat(messages([0, 0, 255]));
      expect(different.choices[0].message.content).toMatch(/blue/i);
      expect(different.usage.prompt_tokens_details.cached_tokens).toBe(0);
      if (storage === "ssd") await flush();
    } finally { server.stop(true); rmSync(dir, { recursive: true, force: true }); }
  }, 120_000);
  test("audio and mixed identities include the complete media set and causal policy", async () => {
    const fixture = (await Bun.file("goldens/e4b-audio.json").json()).fixtures.speech;
    const wav = Buffer.from(await Bun.file(fixture.wav).arrayBuffer()).toString("base64");
    const audio = { type: "input_audio", input_audio: { data: wav, format: "wav" } };
    const red = messages([255, 0, 0]);
    const mixed = [{ role: "user", content: [red[0]!.content[0]!, audio, { type: "text", text: fixture.text }] }];
    const audioOnly = [{ role: "user", content: [audio, { type: "text", text: fixture.text }] }];
    const server = createServer(ctx, 0, { promptCacheBytes: 512 * 2 ** 20 });
    async function chat(messages: unknown[]) {
      const response = await fetch(`http://127.0.0.1:${server.port}/v1/chat/completions`, {
        method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ messages, temperature: 0, seed: 42, max_tokens: 32 }),
      });
      const body = await response.json() as any;
      expect(response.status, JSON.stringify(body)).toBe(200); return body;
    }
    try {
      await chat(red);
      for (const messages of [mixed, audioOnly]) {
        const first = await chat(messages);
        expect(first.usage.prompt_tokens_details.cached_tokens).toBe(0);
        expect(first.choices[0].message.content).toMatch(/quick brown fox/i);
        const next = await chat([...messages, { role: "assistant", content: first.choices[0].message.content },
          { role: "user", content: "Repeat the transcription." }]);
        expect(next.usage.prompt_tokens_details.cached_tokens).toBeGreaterThan(first.usage.prompt_tokens - 1);
        expect(next.choices[0].message.content).toMatch(/quick brown fox/i);
      }
    } finally { server.stop(true); }
  }, 120_000);

});
