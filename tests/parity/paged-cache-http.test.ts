import { describe, expect, spyOn, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { SNAPSHOT_E4B, snapshotE4bAvailable } from "../support/paths";

const enabled = Bun.env.MLX_BUN_TEST_PAGED_CACHE === "1" && await snapshotE4bAvailable();
describe.skipIf(!enabled)("paged cache through HTTP request preparation", async () => {
  if (!enabled) return;
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { createModel } = await import("../../src/model/factory");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");
  const { AdapterManager } = await import("../../src/lora");
  const { resolveModelProfile } = await import("../../src/model/profile");
  const { createServer, shutdownServer, flushServerCacheDurability } = await import("../../src/server");
  const { SsdCacheStore } = await import("../../src/ssd-cache");
  const { PagedKVCache } = await import("../../src/lab/paged-kv/paged-kv");
  const { configureRuntime } = await import("../../src/runtime-config");
  const { clearCache } = await import("../../src/mlx/ffi");

  test("bf16 and affine pages reuse RAM and async SSD state without changing output", async () => {
    const directory = mkdtempSync(join(tmpdir(), "paged-http-"));
    const weights = await Weights.open(SNAPSHOT_E4B);
    const model = createModel(weights, await loadModelConfig(SNAPSHOT_E4B));
    const context = { model, tokenizer: await loadTokenizer(SNAPSHOT_E4B), template: await ChatTemplate.load(SNAPSHOT_E4B),
      profile: resolveModelProfile(model.config), modelId: "paged-cache-test", adapters: new AdapterManager(model),
      kvConfig: null, genDefaults: {}, vision: null, loadVision: null,
      visionTokenIds: { imageTokenId: 0, boiTokenId: 0, eoiTokenId: 0 }, audio: null, loadAudio: null, audioTokenIds: null };
    try {
      for (const direct of [false, true]) for (const bits of ["off", 4] as const) {
        const reset = configureRuntime({ MLX_BUN_PAGED_ATTN: direct ? "1" : "0",
          MLX_BUN_SSD_LAYOUT: "blocks", MLX_BUN_SSD_PREFETCH: "1" });
        const options = { batch: 8, promptCacheBytes: 512 * 1024 ** 2, kvQuant: bits,
          hostname: "127.0.0.1", defaultThinking: false, pagedKv: { blockSize: 16 },
          ssdCacheDir: join(directory, `${direct}-${bits}`), ssdCacheVerify: true };
        const request = async (server: ReturnType<typeof createServer>) => {
          const response = await fetch(`http://127.0.0.1:${server.port}/v1/completions`, {
            method: "POST", headers: { "content-type": "application/json", "x-session-affinity": "paged-agent" },
            body: JSON.stringify({ prompt: "Explain immutable caches and memory ownership. ".repeat(Bun.env.MLX_BUN_TEST_SHORT_SESSION === "1" ? 2 : 24),
              temperature: 0, seed: 42, max_tokens: 16 }) });
          const body = await response.json() as any;
          expect(response.status, JSON.stringify(body)).toBe(200);
          expect(body.usage.lane).toBe("batched");
          return body;
        };
        let server: ReturnType<typeof createServer> | undefined;
        const restore = SsdCacheStore.prototype.restoreAsync;
        let restores = 0;
        const probe = spyOn(SsdCacheStore.prototype, "restoreAsync").mockImplementation(async function(this: InstanceType<typeof SsdCacheStore>, ...args) {
          const state = await restore.apply(this, args);
          expect(state?.caches.some(cache => cache instanceof PagedKVCache)).toBe(true);
          restores++;
          return state;
        });
        try {
          server = createServer(context, 0, options);
          const cold = await request(server), warm = await request(server);
          expect(warm.choices).toEqual(cold.choices);
          expect(warm.usage.prompt_tokens_details.cached_tokens).toBeGreaterThan(0);
          expect((await flushServerCacheDurability(server)).durable).toBe(true);
          await shutdownServer(server); server = undefined;
          server = createServer(context, 0, options);
          const disk = await request(server);
          expect(disk.choices).toEqual(cold.choices);
          expect(disk.usage.prompt_tokens_details.cached_tokens).toBeGreaterThan(0);
          expect(restores).toBeGreaterThan(0);
        } finally { if (server) await shutdownServer(server); probe.mockRestore(); reset(); clearCache(); }
      }
    } finally { weights.dispose(); clearCache(); rmSync(directory, { recursive: true, force: true }); }
  }, 240000);
});
