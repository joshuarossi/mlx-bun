// Qwen3.8-27B artifact conformance. The caller selects an exact quant path.
// No download or server; availability does not imply target status.
// One artifact per process to keep peak residency bounded:
// MLX_BUN_QWEN_QUANT_PATH=/path/to/artifact bun test tests/parity/qwen-quant-engine.test.ts
import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";

const artifact = process.env.MLX_BUN_QWEN_QUANT_PATH;
if (artifact && !existsSync(`${artifact}/config.json`))
  throw new Error(`requested Qwen quant is unavailable: ${artifact}`);
const enabled = !!artifact;

describe.skipIf(!enabled)("Qwen3.8-27B quant: engine contracts", () => {
  test("bound graph and session preserve native logits, greedy output, and cache coverage", async () => {
    const { createModel } = await import("../../src/model/factory");
    const { loadModelConfig } = await import("../../src/config");
    const { Weights } = await import("../../src/weights");
    const { loadTokenizer } = await import("../../src/tokenizer");
    const { generate } = await import("../../src/generate");
    const { bindMlxGraph } = await import("../../src/backends/mlx/graph");
    const { createLegacyInferenceEngine } = await import("../../src/backends/mlx/legacy-engine");
    const { GenerationGateway } = await import("../../src/serve/generation-gateway");
    const { MlxArray } = await import("../../src/mlx/array");
    const { clearCache } = await import("../../src/mlx/ffi");
    const { PromptCache } = await import("../../src/prompt-cache");
    const { cloneKvCaches } = await import("../../src/kv-store");
    const config = await loadModelConfig(artifact!);
    const weights = await Weights.open(artifact!);
    const model = createModel(weights, config);
    const tokenizer = await loadTokenizer(artifact!);
    const prompt = tokenizer.encode("Explain in two sentences why a laptop can run a quantized language model.");
    const options = { temperature: 0, maxTokens: 16, prefillChunkSize: 8 };
    const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
      hasLogitsExtras: false, wantsLogprobs: false, userSeed: false, kvQuant: false,
      turboQuant: false, hasGrammar: false, hasDraft: false };
    const gateway = new GenerationGateway(model, 1, async (ids, options, onToken) => {
      const generation = generate(model, ids, options);
      for await (const token of generation)
        if (await onToken(token.token, token.logprobs) === false) break;
      if (!generation.stats) throw new Error("generation did not settle its metrics");
      return generation.stats;
    });
    const engine = createLegacyInferenceEngine(gateway);
    try {
      expect(model.config.modelType).toBe("qwen3_5");
      expect(model.config.text.numHiddenLayers).toBe(64);
      const graph = bindMlxGraph(model, { id: "qwen-quant", artifact: artifact!, stateAbi: "legacy-cache-array-v1" });
      const directState = model.makeCache();
      const boundState = model.makeCache();
      const ids = MlxArray.fromInt32(Int32Array.from(prompt), [1, prompt.length]);
      try {
        const directHidden = model.forwardHidden(ids, directState);
        const boundHidden = await graph.forwardHidden(ids, boundState);
        try {
          const [batch, positions, width] = directHidden.shape as [number, number, number];
          const last = directHidden.slice([0, positions - 1, 0], [batch, positions, width]);
          const direct = model.logitsFromHidden(last);
          last.dispose();
          const bound = graph.projectLogits(boundHidden, { type: "last" });
          try {
            expect(bound.toFloat32Host()).toEqual(direct.toFloat32Host());
            expect(boundState.map((cache) => cache.offset)).toEqual(directState.map((cache) => cache.offset));
          } finally { direct.dispose(); bound.dispose(); }
        } finally { directHidden.dispose(); boundHidden.dispose(); }
      } finally {
        ids.dispose();
        for (const state of [...directState, ...boundState]) state.dispose();
        clearCache();
      }
      const legacy = generate(model, prompt, options);
      const expected: number[] = [];
      for await (const token of legacy) expected.push(token.token);
      const session = await engine.open({ promptIds: prompt, options, shape }, { output: "collect" });
      const outcome = await session.result;
      expect(outcome.status).toBe("completed");
      if (outcome.status !== "completed") throw new Error(JSON.stringify(outcome));
      expect([...outcome.output!]).toEqual(expected);
      expect(outcome.result.metrics.cacheTokens).toEqual(legacy.stats!.cacheTokens);
      expect(outcome.result.metrics.generatedTokens).toBe(legacy.stats!.generatedTokens);
      expect(gateway.busy).toBe(false);

      // The primary model has recurrent state as well as attention KV. A
      // borrowed prefix must survive extension by multiple independent runs.
      // Align the snapshot with the existing chunk boundary so the comparison
      // changes ownership only, not GEMM/SDPA prefill geometry.
      const prefixStore = new PromptCache(256 * 1024 * 1024);
      const ownedState = model.makeCache();
      try {
        const seeded = generate(model, prompt, { ...options, cache: ownedState, snapshotAt: 8,
          onPrefillDone() { prefixStore.put(prompt.slice(0, 8), cloneKvCaches(ownedState)); } });
        const seededTokens: number[] = [];
        for await (const token of seeded) seededTokens.push(token.token);
        expect(seededTokens).toEqual(expected);
        for (let borrow = 0; borrow < 2; borrow++) {
          const entry = prefixStore.take(prompt);
          expect(entry?.tokens.length).toBe(8);
          if (!entry) throw new Error("prefix cache did not retain the snapshot");
          try {
            const resumed = generate(model, prompt, { ...options, cache: entry.caches });
            const tokens: number[] = [];
            for await (const token of resumed) tokens.push(token.token);
            expect(tokens).toEqual(expected);
            expect(resumed.stats!.cachedTokens).toBe(8);
          } finally {
            for (const cache of entry.caches) cache.dispose();
            entry.retain?.();
          }
        }
      } finally { prefixStore.clear(); for (const cache of ownedState) cache.dispose(); }
    } finally {
      await engine.close();
      weights.dispose();
      clearCache();
    }
  }, 180_000);
});
