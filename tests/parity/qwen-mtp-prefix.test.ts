import { describe, expect, spyOn, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const enabled = Bun.env.MLX_BUN_TEST_MTP_PREFIX === "1";
describe.skipIf(!enabled)("paired Qwen MTP prefill cache", async () => {
  if (!enabled) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { Qwen35Model } = await import("../../src/model/qwen3_5");
  const { KVCache, QuantizedKVCache, TurboQuantKVCache } = await import("../../src/model/gemma4-base");
  const { QwenMtpProvider } = await import("../../src/spec/qwen-mtp-source");
  const { PromptCache } = await import("../../src/prompt-cache");
  const { SsdCacheStore } = await import("../../src/ssd-cache");
  const { SsdDurabilityCoordinator } = await import("../../src/ssd-durability");
  const { SpillQueue, cloneKvCaches } = await import("../../src/kv-store");
  const { cacheBytes } = await import("../../src/prompt-cache");
  const { disposeResources } = await import("../../src/engine/resources");
  const { specServeRun } = await import("../../src/spec/serve-loop");
  const { withResource } = await import("../../src/engine/resources");
  const { leaseCacheStates } = await import("../../src/backends/mlx/state-views");
  const { clearCache, activeMemory } = await import("../../src/mlx/ffi");
  const { contiguous } = await import("../../src/mlx/ops");
  const target = Bun.env.MLX_BUN_TEST_MTP_TARGET!;
  const draft = Bun.env.MLX_BUN_TEST_MTP_DRAFT!;
  const kvBits = Number(Bun.env.MLX_BUN_TEST_MTP_KV_BITS ?? 0);
  const turboQuant = Bun.env.MLX_BUN_TEST_MTP_TURBO === "1" ? { kBits: 8, vBits: 3 } : undefined;
  const kvOptions = turboQuant ? { turboQuant, quantizedKvStart: Number(Bun.env.MLX_BUN_TEST_MTP_TURBO_START ?? 0) } : kvBits ? { kvBits, kvGroupSize: 64, quantizedKvStart: Number(Bun.env.MLX_BUN_TEST_MTP_KV_START ?? 0) } : {};

  function digest(entry: any) {
    const h = createHash("sha256");
    // SSD restore grows allocation capacity. Compare the live logical state,
    // including every recurrent value and companion tensor, without padding.
    const live = cloneKvCaches(entry.caches);
    try {
      h.update(JSON.stringify(live.map(cache => [cache.offset, cache.minimumReusableOffset ?? 0])));
      withResource(leaseCacheStates(live), (state) => {
        for (const a of [...state, ...entry.attachments.flatMap((attachment: any) => attachment.tensors)]) {
          h.update(JSON.stringify({ shape: a.shape, dtype: a.dtype }));
          const bytes = contiguous(a);
          try { h.update(bytes.rawBytesView()); }
          finally { bytes.dispose(); }
        }
      });
      return h.digest("hex");
    } finally { disposeResources(live); }
  }

  test("repeated prompts restore unchanged target, draft and hidden state with exact continuations", async () => {
    const config = await loadModelConfig(target), weights = await Weights.open(target);
    const model = new Qwen35Model(weights, config), provider = await QwenMtpProvider.load(draft);
    const tokenizer = await loadTokenizer(target);
    const corpus = tokenizer.encode("Alpha beta gamma delta. The workshop inventory contains brass washers and maple dowels. ".repeat(250));
    const store = new PromptCache(4 * 1024 ** 3);
    const put = store.put, take = store.take;
    let captured: string | undefined;
    const restored: Array<{ same: boolean; tokens: number }> = [], rows: any[] = [];
    const putSpy = spyOn(store, "put").mockImplementation(function (this: InstanceType<typeof PromptCache>, ...args) {
      captured = digest({ caches: args[1], attachments: args[4] });
      return put.apply(this, args);
    });
    const takeSpy = spyOn(store, "take").mockImplementation(function (this: InstanceType<typeof PromptCache>, ...args) {
      const state = take.apply(this, args);
      if (state) restored.push({ same: digest(state) === captured, tokens: state.tokens.length });
      return state;
    });
    try {
      for (const length of [128, 513, 2051]) {
        const prompt = corpus.slice(0, length), boundary = length - 3;
        const runs: any[] = [];
        store.clear();
        // Warm model execution without publishing cache state.
        await specServeRun(model, provider, 2, prompt, { ...kvOptions, maxTokens: 1, temperature: 0 }, () => {});
        for (let repeat = 0; repeat < 3; repeat++) {
          const tokens: number[] = [], start = performance.now();
          const stats = await specServeRun(model, provider, 2, prompt, {
            ...kvOptions, maxTokens: 24, temperature: 0, seed: 42, snapshotAt: boundary,
          }, token => { tokens.push(token); }, { prefixCache: store });
          clearCache();
          runs.push({ repeat, tokens, cached: stats.cachedTokens,
            speculation: stats.spec, wallMs: performance.now() - start, activeBytes: activeMemory() });
          expect(stats.cachedTokens).toBe(repeat ? boundary : 0);
          if (repeat) {
            expect(tokens).toEqual(runs[0].tokens);
            expect(stats.spec?.acceptanceLengths).toEqual(runs[0].speculation.acceptanceLengths);
          }
        }
        rows.push({ length, boundary, runs });
      }
      expect(restored.length).toBe(6);
      expect(restored.every(r => r.same)).toBe(true);
    } finally {
      putSpy.mockRestore(); takeSpy.mockRestore();
      store.clear(); provider.dispose(); weights.dispose(); clearCache();
      if (Bun.env.MLX_BUN_TEST_MTP_REPORT) await Bun.write(Bun.env.MLX_BUN_TEST_MTP_REPORT,
        JSON.stringify({ target, draft, kvOptions, rows, restored, activeAfterDisposal: activeMemory() }, null, 2));
    }
  }, 600000);

  test.each(["request", "group"] as const)("shared SSD restart restores target, draft and pending hidden with an exact continuation (%s)", async (method) => {
    const dir = mkdtempSync(join(tmpdir(), "qwen-mtp-ssd-"));
    const config = await loadModelConfig(target), weights = await Weights.open(target);
    const model = new Qwen35Model(weights, config);
    let provider = await QwenMtpProvider.load(draft);
    const tokenizer = await loadTokenizer(target);
    const prompt = tokenizer.encode("The workshop inventory contains brass washers and maple dowels. ".repeat(100)).slice(0, 513);
    const boundary = prompt.length - 3;
    const storeOptions = { dir, maxBytes: 4 * 1024 ** 3, modelId: target,
      configFingerprint: "mtp-native-restart", tokenizerHash: "mtp-native-restart", verify: true };
    const ssd = new SsdCacheStore(storeOptions);
    const cache = new PromptCache(4 * 1024 ** 3);
    const queue = new SpillQueue(4 * 1024 ** 3, cacheBytes,
      item => ssd.storeAsync(item.tokens, item.caches, item.ns, undefined, item.attachments), disposeResources);
    const durability = new SsdDurabilityCoordinator(cache, queue, cloneKvCaches);
    cache.onPut = (tokens, ns) => durability.schedule(tokens, ns);
    let namespace = "", captured = "", convertedPublications = 0;
    const put = cache.put;
    const putSpy = spyOn(cache, "put").mockImplementation(function (this: InstanceType<typeof PromptCache>, ...args) {
      namespace = args[2]!;
      const start = kvOptions.quantizedKvStart ?? 0;
      if (start > 0 && args[0].length >= start) {
        for (const state of args[1]) {
          expect(state instanceof KVCache && state.offset >= start).toBe(false);
          if (state instanceof TurboQuantKVCache || state instanceof QuantizedKVCache) {
            expect(state.minimumReusableOffset).toBeGreaterThanOrEqual(start);
            expect(state.minimumReusableOffset).toBeLessThanOrEqual(state.offset);
          }
        }
        convertedPublications++;
      }
      if (args[0].length === boundary) captured = digest({ caches: args[1], attachments: args[4] });
      return put.apply(this, args);
    });
    let restoredCache: InstanceType<typeof PromptCache> | undefined;
    const run: typeof specServeRun = async (targetModel, draftProvider, depth, ids, options, output, services = {}) => {
      if (method === "request") return specServeRun(targetModel, draftProvider, depth, ids, options, output, services);
      const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
      const { bindSpeculativeGroupRequests } = await import("../../src/backends/mlx/speculative-group");
      const group = new MlxBatchExecutionGroup(targetModel, { maxBatch: 4, promptCache: services.prefixCache });
      try {
        const result = await group.submit({ method: bindSpeculativeGroupRequests(targetModel, draftProvider, depth)(options),
          promptIds: ids, eosTokenIds: options.eosTokenIds ?? targetModel.config.eosTokenIds,
          maxTokens: options.maxTokens ?? 512, snapshotAt: options.snapshotAt, onToken: output });
        return { ...result, prefillTps: 0, decodeTps: 0, cacheTokens: [] };
      } finally { await group.close(); }
    };

    try {
      const options = { ...kvOptions, maxTokens: 24, temperature: 0, seed: 42, snapshotAt: boundary };
      const coldTokens: number[] = [];
      const cold = await run(model, provider, 2, prompt, options,
        token => { coldTokens.push(token); }, { prefixCache: cache });
      expect(cold.cachedTokens).toBe(0);
      expect((await durability.flush()).durable).toBe(true);
      expect(queue.pendingBytes).toBe(0);
      cache.clear();
      provider.dispose();
      provider = await QwenMtpProvider.load(draft);
      const restarted = new SsdCacheStore(storeOptions);
      expect(restarted.scan()).toBe(method === "group" ? 2 : 1);
      expect(restarted.find(prompt, namespace)?.prefixLen).toBe(boundary);
      let restoredDigest = "";
      restoredCache = new PromptCache(4 * 1024 ** 3, null, {
        find(tokens, ns) {
          const hit = restarted.find(tokens, ns);
          return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null;
        },
        restore(handle) {
          const loaded = restarted.restore(handle as Parameters<typeof restarted.restore>[0], model);
          if (!loaded) return null;
          restoredDigest = digest(loaded);
          return { ...loaded, retain() {} };
        },
        store: (tokens, caches, ns, attachments) => restarted.store(tokens, caches, ns, attachments),
      });
      for (let repeat = 0; repeat < 2; repeat++) {
        const tokens: number[] = [];
        const warm = await run(model, provider, 2, prompt, options,
          token => { tokens.push(token); }, { prefixCache: restoredCache });
        expect(warm.cachedTokens).toBe(boundary);
        expect(restoredDigest).toBe(captured);
        expect(tokens).toEqual(coldTokens);
        expect(warm.spec?.acceptanceLengths).toEqual(cold.spec?.acceptanceLengths);
      }
      expect(restarted.stats.restores).toBe(2);
      if ((kvOptions.quantizedKvStart ?? 0) > 0)
        expect(convertedPublications).toBeGreaterThan(0);
    } finally {
      putSpy.mockRestore();
      await durability.flush();
      cache.clear(); restoredCache?.clear();
      provider.dispose(); weights.dispose(); clearCache();
      rmSync(dir, { recursive: true, force: true });
    }
  }, 600000);
});
