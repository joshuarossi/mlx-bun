// Prefix ownership through actual shared execution, supersession and row retirement.
// MLX_BUN_TEST_RECURRENT_PREFIX_MODEL=/path bun test tests/parity/batch-prefix-sharing.test.ts
import { expect, spyOn, test } from "bun:test";
import { createHash } from "node:crypto";

const artifact = Bun.env.MLX_BUN_TEST_RECURRENT_PREFIX_MODEL;

test.skipIf(!artifact)("concurrent rows retain exact RAM prefix bytes through retirement and trimmable supersession", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { generate } = await import("../../src/generate");
  const { GenerationGateway } = await import("../../src/serve/generation-gateway");
  const { PromptCache } = await import("../../src/prompt-cache");
  const { cloneKvCaches } = await import("../../src/kv-store");
  const { leaseCacheState } = await import("../../src/backends/mlx/state-views");
  const { RotatingKVCache } = await import("../../src/model/gemma4-base");
  const { withResource, ownResource, disposeResources } = await import("../../src/engine/resources");
  const { resolveKvScheme, KvScheme } = await import("../../src/kv-scheme");
  const { clearCache } = await import("../../src/mlx/ffi");
  const { contiguous } = await import("../../src/mlx/ops");
  const bits = Number(Bun.env.MLX_BUN_TEST_SHARED_PREFIX_KV_BITS ?? 0);
  const turboQuant = Bun.env.MLX_BUN_TEST_SHARED_PREFIX_TURBO === "1" ? { kBits: 8, vBits: 3 } : undefined;
  const turboStart = Number(Bun.env.MLX_BUN_TEST_SHARED_PREFIX_TURBO_START ?? 0);
  const kvScheme = turboQuant ? new KvScheme("turbo", { turboQuant, quantizedKvStart: turboStart }) : bits ? resolveKvScheme({ override: bits }) : undefined;
  const weights = await Weights.open(artifact!);
  const model = createModel(weights, await loadModelConfig(artifact!));
  const tokenizer = await loadTokenizer(artifact!);
  const prefixTokens = Number(Bun.env.MLX_BUN_TEST_SHARED_PREFIX_TOKENS ?? 512);
  const prompt = tokenizer.encode("The workshop keeps brass washers, maple dowels and copper wire. ".repeat(prefixTokens)).slice(0, prefixTokens);
  const boundary = prompt.slice(0, -1);
  let stores = 0;
  const cache = new PromptCache(8e9, null, {
    find: () => null, restore: () => null,
    store() { stores++; throw new Error("SSD unavailable"); },
  });
  const options = { ...kvScheme?.generationOptions, temperature: 0, eosTokenIds: [], prefillChunkSize: 512 };
  const fresh = model.makeCache();
  let maxB = 0;
  let conversionOffset = 0;
  const forward = model.forwardHidden.bind(model);
  const probe = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
    maxB = Math.max(maxB, ids.shape[0]!);
    const result = forward(ids, caches);
    conversionOffset = Math.max(conversionOffset, ...caches.map(c => c.minimumReusableOffset ?? 0));
    return result;
  });
  const gateway = new GenerationGateway(model, 2, async () => {
    throw new Error("prefix request fell back to serial");
  }, { promptCache: cache, kvScheme });
  const digest = (caches = cache.findExact(boundary)!.caches) => {
    const hash = createHash("sha256");
    for (const state of caches) withResource(
      // A trimmed ring may retain allocation capacity and an inactive suffix.
      // Compare every live byte in chronological order, using its cache contract.
      state instanceof RotatingKVCache
        ? ownResource(state.temporalView(), disposeResources)
        : leaseCacheState(state), arrays => {
      hash.update(JSON.stringify([state.signature(), state.offset]));
      for (const array of arrays) {
        hash.update(JSON.stringify(array.shape));
        const bytes = contiguous(array);
        try { hash.update(bytes.rawBytesView()); } finally { bytes.dispose(); }
      }
    });
    return hash.digest("hex");
  };
  try {
    const cold = generate(model, prompt, { ...options, maxTokens: 1, cache: fresh,
      snapshotAt: boundary.length,
      onPrefillDone() { cache.put(boundary, cloneKvCaches(fresh)); } });
    for await (const _token of cold) { /* populate the shared prefix */ }
    for (const state of fresh.splice(0)) state.dispose();
    const donor = cache.findExact(boundary)!;
    expect(donor).not.toBeNull();
    const recurrent = donor.caches.some(state => state.signature() === "ssm");
    if (turboQuant) expect(donor.caches.some(state => !!state.rotatedValueAttention)).toBe(turboStart <= boundary.length);
    if (Bun.env.MLX_BUN_TEST_EXPECT_SLIDING === "1")
      expect(donor.caches.some(state => state.signature().includes("rotating"))).toBe(true);
    const before = digest();
    const run = async () => {
      maxB = 0;
      const outputs: number[][] = [[], []];
      await Promise.all([16, 32].map(async (maxTokens, row) => {
        const requestOptions = { ...options, maxTokens };
        const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
          hasLogitsExtras: false, wantsLogprobs: false, userSeed: false,
          kvQuant: !!kvScheme && !turboQuant, turboQuant: !!turboQuant, hasGrammar: false, hasDraft: false };
        const placement = gateway.place(shape, requestOptions);
        expect(placement.mechanism).toBe("continuous");
        const stats = await gateway.run(prompt, requestOptions, token => { outputs[row]!.push(token); },
          undefined, shape, placement);
        expect(stats.cachedTokens).toBe(boundary.length);
        expect(stats.generatedTokens).toBe(maxTokens);
        expect(stats.decodeMs).toBeGreaterThan(0);
        expect(stats.decodeTps).toBeGreaterThan(0);
        expect(outputs[row]).toHaveLength(maxTokens);
      }));
      expect(maxB).toBe(2);
      // Recurrent donors must remain. Trimmable entries may be superseded by
      // longer prefixes; both contracts must restore the same logical bytes.
      if (recurrent || turboStart > boundary.length) expect(cache.findExact(boundary)).toBe(donor);
      const restored = cache.take(prompt)!;
      expect(restored).not.toBeNull();
      try {
        expect(restored.tokens).toEqual(boundary);
        expect(digest(restored.caches)).toBe(before);
      } finally {
        for (const state of restored.caches) state.dispose();
        restored.retain?.();
      }
      expect(stores).toBe(0);
      return outputs;
    };
    const first = await run();
    expect(await run()).toEqual(first);
    expect(gateway.submittedRows).toBe(4);
    if (turboStart > boundary.length && turboStart < prompt.length + 16) expect(conversionOffset).toBe(turboStart);
  } finally {
    await gateway.close(); probe.mockRestore(); cache.clear();
    for (const state of fresh) state.dispose();
    weights.dispose(); clearCache();
  }
}, 300_000);
