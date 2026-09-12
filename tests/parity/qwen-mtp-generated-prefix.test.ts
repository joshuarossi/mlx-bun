import { describe, expect, spyOn, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { GenerateOptions } from "../../src/generate";

const enabled = Bun.env.MLX_BUN_TEST_MTP_PREFIX === "1";
const ngram = Bun.env.MLX_BUN_TEST_GROUP_NGRAM === "1";
const dflash = Bun.env.MLX_BUN_TEST_GROUP_DFLASH === "1";
const deepspec = Bun.env.MLX_BUN_TEST_GROUP_DEEPSPEC === "1";
const assistant = Bun.env.MLX_BUN_TEST_GROUP_ASSISTANT === "1";
const twoModel = Bun.env.MLX_BUN_TEST_GROUP_TWO_MODEL === "1";
describe.skipIf(!enabled)(`generated prefixes from shared ${ngram ? "prompt lookup" : dflash ? "DSpark draft" : deepspec ? "DeepSpec draft" : assistant ? "assistant draft" : twoModel ? "standalone draft" : "MTP"}`, async () => {
  if (!enabled) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { NgramProvider } = await import("../../src/spec/ngram-source");
  const { QwenMtpProvider } = await import("../../src/spec/qwen-mtp-source");
  const { DflashProvider } = await import("../../src/spec/dflash-source");
  const { DeepspecProvider } = await import("../../src/spec/deepspec-source");
  const { AssistantProvider } = await import("../../src/spec/assistant-source");
  const { TwoModelProvider } = await import("../../src/spec/two-model");
  const loadProvider = (path: string) => ngram ? new NgramProvider() : dflash ? DflashProvider.load(path) : deepspec ? DeepspecProvider.load(path) : assistant ? AssistantProvider.load(path) : twoModel ? TwoModelProvider.load(path) : QwenMtpProvider.load(path);
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { bindSpeculativeGroupRequests } = await import("../../src/backends/mlx/speculative-group");
  const { PromptCache } = await import("../../src/prompt-cache");
  const { SsdCacheStore } = await import("../../src/ssd-cache");
  const { TieredPromptCache } = await import("../../src/tiered-prompt-cache");
  const { cloneKvCaches } = await import("../../src/kv-store");
  const { disposeResources, withResource } = await import("../../src/engine/resources");
  const { disposeAttachments } = await import("../../src/backends/mlx/checkpoint-state");
  const { leaseCacheStates } = await import("../../src/backends/mlx/state-views");
  const { contiguous } = await import("../../src/mlx/ops");
  const { clearCache } = await import("../../src/mlx/ffi");
  type Hit = NonNullable<ReturnType<InstanceType<typeof PromptCache>["take"]>>;
  const release = (hit: Hit) => disposeResources([...hit.caches,
    { dispose: () => disposeAttachments(hit.attachments) }, { dispose: () => hit.retain?.() }]);
  const digest = (entry: Pick<Hit, "caches" | "attachments">) => {
    const hash = createHash("sha256"), state = cloneKvCaches(entry.caches);
    try {
      hash.update(JSON.stringify(state.map(cache => cache.offset)));
      hash.update(JSON.stringify(entry.attachments?.map(a => [a.schema, a.metadata])));
      withResource(leaseCacheStates(state), arrays => {
        for (const array of [...arrays, ...(entry.attachments ?? []).flatMap(a => a.tensors)]) {
          hash.update(JSON.stringify([array.shape, array.dtype]));
          using bytes = contiguous(array); hash.update(bytes.rawBytesView());
        }
      });
      return hash.digest("hex");
    } finally { disposeResources(state); }
  };

  test("retired rows publish actual processed IDs and retain immutable RAM/SSD continuations", async () => {
    const target = Bun.env.MLX_BUN_TEST_MTP_TARGET!, draft = Bun.env.MLX_BUN_TEST_MTP_DRAFT!;
    const directory = mkdtempSync(join(tmpdir(), "mtp-generated-"));
    const weights = await Weights.open(target), model = createModel(weights, await loadModelConfig(target));
    let provider = await loadProvider(draft);
    const depth = Number(Bun.env.MLX_BUN_TEST_MTP_DEPTH ?? 3);
    const bits = Number(Bun.env.MLX_BUN_TEST_MTP_KV_BITS ?? 0);
    const turboQuant = Bun.env.MLX_BUN_TEST_MTP_TURBO === "1" ? { kBits: 8, vBits: 3 } : undefined;
    const quantizedKvStart = Number(Bun.env.MLX_BUN_TEST_MTP_KV_START ?? 0);
    const kvConfig = Bun.env.MLX_BUN_TEST_ROTATING_KV_CONFIG === "1" ? model.config.kvQuant : undefined;
    if (Bun.env.MLX_BUN_TEST_ROTATING_KV_CONFIG === "1") expect(kvConfig?.length).toBeGreaterThan(0);
    const options: GenerateOptions = { temperature: 0, seed: 42, maxTokens: 20,
      ...(turboQuant ? { turboQuant, quantizedKvStart } : kvConfig?.length ? { kvConfig, quantizedKvStart } : bits ? { kvBits: bits, kvGroupSize: 64, quantizedKvStart } : {}) };
    const storeOptions = { dir: directory, maxBytes: 4 * 1024 ** 3, modelId: target,
      configFingerprint: "generated-mtp", tokenizerHash: "generated-mtp", verify: true };
    const ssd = new SsdCacheStore(storeOptions);
    const cache = new TieredPromptCache(4 * 1024 ** 3, ssd, {
      find(tokens, ns) { const hit = ssd.find(tokens, ns); return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null; },
      restore(handle) {
        const hit = ssd.restore(handle as Parameters<typeof ssd.restore>[0], model);
        return hit ? { ...hit, retain() {} } : null;
      },
      store: (tokens, caches, ns, attachments) => ssd.store(tokens, caches, ns, attachments),
    });
    const { durability, spillQueue: queue } = cache;
    const prompts = Array.from({ length: 4 }, (_, row) => [1, 2, 3, 4, 5, 6, 7 + row]);
    const outputs: number[][] = [[], [], [], []];
    let maxPrefillRows = 0;
    const forward = model.forwardHidden.bind(model);
    const prefillProbe = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
      if (outputs.every(tokens => tokens.length === 0)) maxPrefillRows = Math.max(maxPrefillRows, ids.shape[0]!);
      return forward(ids, caches);
    });
    const snapshots = new Map<number, { ids: number[]; namespace: string; hash: string }>();
    const put = cache.put;
    const spy = spyOn(cache, "put").mockImplementation(function (this: InstanceType<typeof PromptCache>, ...args) {
      const row = prompts.findIndex(prompt => prompt.every((token, index) => token === args[0][index]));
      if (row >= 0 && args[0].length > prompts[row]!.length && !snapshots.has(row)) {
        if (ngram) expect(args[4]?.[0]?.tensors[0]?.shape[0]).toBe(args[0].length);
        else if (twoModel || assistant || deepspec || dflash) expect(args[4]?.[0]?.metadata.processedTokens).toBe(args[0].length);
        else expect(args[4]?.[0]?.metadata.draftOffset).toBe(args[0].length - 1);
        snapshots.set(row, { ids: [...args[0]], namespace: args[2]!, hash: digest({ caches: args[1], attachments: args[4] }) });
      }
      return put.apply(this, args);
    });
    let restored: InstanceType<typeof PromptCache> | undefined;
    try {
      const group = new MlxBatchExecutionGroup(model, { maxBatch: 4, promptCache: cache });
      const aborted = new AbortController(); let maxRows = 0;
      try {
        const outcomes = await Promise.allSettled(prompts.map((promptIds, row) => group.submit({
          method: bindSpeculativeGroupRequests(model, provider, depth)(options), promptIds,
          cacheNamespace: `generated-${row}`, maxTokens: 20, eosTokenIds: [],
          ...(row === 3 ? { signal: aborted.signal } : {}),
          onToken(token) {
            outputs[row]!.push(token); maxRows = Math.max(maxRows, group.activeRows);
            if (row === 1 && outputs[row]!.length === 6) return false;
            if (row === 2 && outputs[row]!.length === 7) throw new Error("failed consumer");
            if (row === 3 && outputs[row]!.length === 8) aborted.abort(new Error("cancelled consumer"));
          },
        })));
        expect(maxRows).toBe(4);
        if (ngram || twoModel || assistant || deepspec || dflash) expect(maxPrefillRows).toBeGreaterThanOrEqual(3);
        else expect(maxPrefillRows).toBe(4);
        expect(outcomes.map(value => value.status)).toEqual(["fulfilled", "fulfilled", "rejected", "rejected"]);
        expect([...snapshots.keys()].sort()).toEqual([0, 1]);
      } finally { await group.close(); }
      for (const row of [0, 1]) {
        const snapshot = snapshots.get(row)!, transcript = [...prompts[row]!, ...outputs[row]!];
        expect(snapshot.ids).toEqual(transcript.slice(0, snapshot.ids.length));
        expect(transcript.length - snapshot.ids.length).toBeGreaterThanOrEqual(0);
        expect(transcript.length - snapshot.ids.length).toBeLessThanOrEqual(1);
        const held = cache.take([...snapshot.ids, 31], snapshot.namespace)!;
        try { expect(digest(held)).toBe(snapshot.hash); } finally { release(held); }
      }
      const continueRow = async (row: number, storage: InstanceType<typeof PromptCache>) => {
        const next = [...prompts[row]!, ...outputs[row]!, 11, 12, 13], tokens: number[] = [];
        const group = new MlxBatchExecutionGroup(model, { maxBatch: 4, promptCache: storage });
        try {
          const result = await group.submit({ method: bindSpeculativeGroupRequests(model, provider, depth)(options),
            promptIds: next, snapshotAt: 1, cacheNamespace: `generated-${row}`, maxTokens: 12, eosTokenIds: [],
            onToken(token) { tokens.push(token); } });
          expect(result.cachedTokens).toBe(snapshots.get(row)!.ids.length);
          return { tokens, acceptance: result.spec?.acceptanceLengths };
        } finally { await group.close(); }
      };
      const warm = [];
      for (const row of [0, 1]) {
        warm.push(await continueRow(row, cache));
        expect(await continueRow(row, cache)).toEqual(warm[row]!);
        const snapshot = snapshots.get(row)!, held = cache.take([...snapshot.ids, 32], snapshot.namespace)!;
        try { expect(digest(held)).toBe(snapshot.hash); } finally { release(held); }
        const edited = [...snapshot.ids]; edited[edited.length - 1] = 33;
        const fallback = cache.take([...edited, 34], snapshot.namespace)!;
        try { expect(fallback.tokens).toEqual(prompts[row]!.slice(0, -1)); } finally { release(fallback); }
      }
      expect((await durability.flush()).durable).toBe(true);
      expect(queue.pendingBytes).toBe(0);
      cache.clear(); provider.dispose(); provider = await loadProvider(draft);
      const restarted = new SsdCacheStore(storeOptions); expect(restarted.scan()).toBeGreaterThan(0);
      restored = new PromptCache(4 * 1024 ** 3, null, {
        find(tokens, ns) { const hit = restarted.find(tokens, ns); return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null; },
        restore(handle) {
          const hit = restarted.restore(handle as Parameters<typeof restarted.restore>[0], model);
          return hit ? { ...hit, retain() {} } : null;
        },
        store: (tokens, caches, ns, attachments) => restarted.store(tokens, caches, ns, attachments),
      });
      for (const row of [0, 1]) {
        const snapshot = snapshots.get(row)!;
        const hit = restored.take([...snapshot.ids, 31], snapshot.namespace)!;
        try { expect(digest(hit)).toBe(snapshot.hash); } finally { release(hit); }
        expect(await continueRow(row, restored)).toEqual(warm[row]!);
      }
      console.error(JSON.stringify({ depth, bits, turboQuant, maxRows,
        generated: outputs.map(tokens => tokens.length), prefixes: [...snapshots.values()].map(item => item.ids.length) }));
    } finally {
      spy.mockRestore(); prefillProbe.mockRestore(); await durability.flush(); cache.clear(); restored?.clear();
      provider.dispose(); weights.dispose(); clearCache(); rmSync(directory, { recursive: true, force: true });
    }
  }, 600000);
});
