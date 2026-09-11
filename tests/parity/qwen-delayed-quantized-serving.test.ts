import { describe, expect, spyOn, test } from "bun:test";
import type { GenerateOptions } from "../../src/generate";

const ngram = Bun.env.MLX_BUN_TEST_GROUP_NGRAM === "1";
const enabled = Bun.env.MLX_BUN_TEST_BATCH_SPEC_REPLAY === "1";
describe.skipIf(!enabled)("Shared drafting with delayed affine KV", async () => {
  if (!enabled) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { AssistantProvider } = await import("../../src/spec/assistant-source");
  const { DflashProvider } = await import("../../src/spec/dflash-source");
  const { DeepspecProvider } = await import("../../src/spec/deepspec-source");
  const { TwoModelProvider } = await import("../../src/spec/two-model");
  const { NgramProvider } = await import("../../src/spec/ngram-source");
  const { QwenMtpProvider } = await import("../../src/spec/qwen-mtp-source");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { bindMlxGateway } = await import("../../src/backends/mlx/gateway-binding");
  const { bindSpeculativeGroupRequests } = await import("../../src/backends/mlx/speculative-group");
  const { DelayedQuantizedKVCache } = await import("../../src/model/delayed-quantized-kv");
  const { DelayedRotatingQuantizedKVCache } = await import("../../src/model/delayed-rotating-quantized-kv");
  const { QuantizedKVCache, RotatingQuantizedKVCache, RotatingKVCache } = await import("../../src/model/gemma4-base");
  const { clearCache } = await import("../../src/mlx/ffi");

  test("seeded B1/B3 continuation survives mixed precision, retirement and late admission", async () => {
    const path = Bun.env.MLX_BUN_TEST_MTP_TARGET!;
    const weights = await Weights.open(path), model = createModel(weights, await loadModelConfig(path));
    const draft = Bun.env.MLX_BUN_TEST_MTP_DRAFT!;
    const provider = Bun.env.MLX_BUN_TEST_GROUP_DFLASH === "1" ? await DflashProvider.load(draft)
      : Bun.env.MLX_BUN_TEST_GROUP_ASSISTANT === "1" ? await AssistantProvider.load(draft)
      : Bun.env.MLX_BUN_TEST_GROUP_DEEPSPEC === "1" ? await DeepspecProvider.load(draft)
      : Bun.env.MLX_BUN_TEST_GROUP_TWO_MODEL === "1" ? await TwoModelProvider.load(draft)
      : Bun.env.MLX_BUN_TEST_GROUP_NGRAM === "1" ? new NgramProvider()
      : await QwenMtpProvider.load(draft);
    const depth = Number(Bun.env.MLX_BUN_TEST_MTP_DEPTH ?? 3);
    const kvConfig = Bun.env.MLX_BUN_TEST_ROTATING_KV_CONFIG === "1" ? model.config.kvQuant : undefined;
    if (Bun.env.MLX_BUN_TEST_ROTATING_KV_CONFIG === "1") expect(kvConfig?.length).toBeGreaterThan(0);
    const options: GenerateOptions = { ...(kvConfig?.length ? { kvConfig } : { kvBits: Number(Bun.env.MLX_BUN_TEST_MTP_KV_BITS ?? 4), kvGroupSize: 64 }), quantizedKvStart: 10,
      temperature: 0.7, seed: 42, logprobs: true, topLogprobs: 3 };
    const gateway = bindMlxGateway(model, { provider, numDraftTokens: depth });
    expect(gateway.plan({ hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
      userSeed: true, kvQuant: true, turboQuant: false, hasLogitsExtras: false,
      hasGrammar: false, wantsLogprobs: true, hasDraft: true }, options,
      { continuous: true, quantizedBatch: true, checkpoints: false }))
      .toMatchObject({ method: "speculative", mechanism: "continuous" });
    const bind = bindSpeculativeGroupRequests(model, provider, depth);
    const caches = model.makeCache();
    const rotating = caches.some(cache => cache instanceof RotatingKVCache);
    for (const cache of caches) cache.dispose();
    const observed = [DelayedQuantizedKVCache.prototype,
      ...(rotating ? [DelayedRotatingQuantizedKVCache.prototype] : [])].map(prototype => {
      const state = { mixed: false, converted: false };
      const begin = prototype.specRoundBegin;
      const spy = spyOn(prototype, "specRoundBegin").mockImplementation(function (this: typeof prototype) {
        begin.call(this);
        const flags = this.rowOffsets.map((_, index) => {
          const row = this.extractRow(index);
          try {
            if (row instanceof QuantizedKVCache || row instanceof RotatingQuantizedKVCache) {
              expect(row.minimumReusableOffset).toBeGreaterThanOrEqual(10);
              expect(row.minimumReusableOffset).toBeLessThanOrEqual(row.offset);
              return true;
            }
            return false;
          } finally { row.dispose(); }
        });
        state.mixed ||= flags.some(Boolean) && !flags.every(Boolean);
        state.converted ||= flags.every(Boolean);
      });
      return { state, spy };
    });
    const run = async (count: number, late = false) => {
      const group = new MlxBatchExecutionGroup(model, { maxBatch: 3 });
      const tokens: number[][] = Array.from({ length: count }, () => []);
      const metadata: unknown[][] = Array.from({ length: count }, () => []);
      let maxRows = 0, joiner: Promise<unknown> | undefined;
      const submit = (row: number) => group.submit({ method: bind(options),
        promptIds: Array.from({ length: row === 0 ? (ngram ? 7 : 3) : 12 + row }, (_, i) => ngram ? i % 3 + 1 : i + 1),
        maxTokens: row === 0 ? 20 : 12 + row, eosTokenIds: [],
        onToken(token, extra) {
          tokens[row]!.push(token); metadata[row]!.push(extra);
          maxRows = Math.max(maxRows, group.activeRows);
          if (late && row === 0 && tokens[0]!.length === 6) joiner = submit(1);
          if (row === 2 && tokens[row]!.length === 5) return false;
        } });
      try {
        const stats = await Promise.all(Array.from({ length: late ? 1 : count }, (_, row) => submit(row)));
        await joiner;
        expect(group.activeRows + group.pendingRows).toBe(0);
        expect(maxRows).toBe(late ? 2 : count);
        for (const stat of stats) expect(stat.spec!.rounds).toBeGreaterThan(0);
        if (ngram) expect(stats.some(stat => stat.spec!.drafted > 0)).toBe(true);
        return { tokens, metadata, speculation: stats.map(stat => stat.spec) };
      } finally { await group.close(); clearCache(); }
    };
    try {
      expect(await run(1)).toEqual(await run(1));
      expect(await run(3)).toEqual(await run(3));
      expect(await run(2, true)).toEqual(await run(2, true));
      for (const { state } of observed) { expect(state.mixed).toBe(true); expect(state.converted).toBe(true); }
    } finally { for (const { spy } of observed) spy.mockRestore(); provider.dispose(); weights.dispose(); clearCache(); }
  }, 600000);
});
