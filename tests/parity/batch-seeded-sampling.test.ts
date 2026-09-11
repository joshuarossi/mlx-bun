// Seeded sampling through the production request gateway and execution groups.
// MLX_BUN_TEST_BATCH_SAMPLING_MODEL=/path bun test tests/parity/batch-seeded-sampling.test.ts
import { expect, test, spyOn } from "bun:test";
import type { TokenLogprobs } from "../../src/contracts/generation";

const artifact = Bun.env.MLX_BUN_TEST_BATCH_SAMPLING_MODEL;

test.skipIf(!artifact)("seeded request sampling composes with native groups and controlled joins", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { generate } = await import("../../src/generate");
  const { GenerationGateway } = await import("../../src/serve/generation-gateway");
  const { clearCache } = await import("../../src/mlx/ffi");
  const { resolveKvScheme, KvScheme } = await import("../../src/kv-scheme");
  const { DelayedTurboQuantKVCache } = await import("../../src/model/delayed-turboquant-kv");
  const { QuantizedKVCache, RotatingQuantizedKVCache, TurboQuantKVCache } = await import("../../src/model/gemma4-base");
  const kvBits = Bun.env.MLX_BUN_TEST_BATCH_SAMPLING_KV_BITS;
  const affineStart = Number(Bun.env.MLX_BUN_TEST_BATCH_AFFINE_START ?? 0);
  const { DelayedQuantizedKVCache } = await import("../../src/model/delayed-quantized-kv");
  const turboQuant = Bun.env.MLX_BUN_TEST_BATCH_SAMPLING_TURBO === "1" ? { kBits: 8, vBits: 3 } : undefined;
  const kvScheme = turboQuant ? new KvScheme("turbo", { turboQuant, quantizedKvStart: Number(Bun.env.MLX_BUN_TEST_BATCH_TURBO_START ?? 0) }) : kvBits ? new KvScheme("affine-uniform", { kvBits: Number(kvBits), quantizedKvStart: affineStart }) : undefined;
  const weights = await Weights.open(artifact!);
  const model = createModel(weights, await loadModelConfig(artifact!));
  const tokenizer = await loadTokenizer(artifact!);
  const prompts = ["Write a story about a dragon.", "List some creative names for a new bakery.",
    "Explain why the sky appears blue during the day."].map(p => tokenizer.encode(p));
  const options = (index: number) => ({ ...kvScheme?.generationOptions, temperature: 0.8, seed: [734, 319, 123][index]!,
    topP: 0.92, topK: 40, minP: 0.02, repetitionPenalty: 1.1,
    presencePenalty: 0.15, frequencyPenalty: 0.05, logprobs: true, topLogprobs: 3,
    maxTokens: [24, 32, 20][index]!, eosTokenIds: [],
    prefillChunkSize: Number(Bun.env.MLX_BUN_TEST_BATCH_PREFILL_CHUNK ?? 16) });
  type Output = Array<{ token: number; lp?: TokenLogprobs }>;
  let maxB = 0;
  let sawQuantized = false;
  let sawMixed = false;
  const forward = model.forwardHidden.bind(model);
  const probe = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
    maxB = Math.max(maxB, ids.shape[0]!);
    if (!sawMixed && ids.shape[0]! > 1) {
      const cache = caches.find(c => c instanceof DelayedTurboQuantKVCache || c instanceof DelayedQuantizedKVCache);
      if (cache) {
        const converted = cache.rowOffsets.map((_, row) => {
          const state = cache.extractRow(row);
          try { return state instanceof QuantizedKVCache || state instanceof TurboQuantKVCache; }
          finally { state.dispose(); }
        });
        sawMixed = converted.some(Boolean) && !converted.every(Boolean);
      }
    }
    sawQuantized ||= caches.some(c => c instanceof QuantizedKVCache || c instanceof RotatingQuantizedKVCache || c instanceof TurboQuantKVCache || !!c.rotatedValueAttention || !!c.attentionState);
    return forward(ids, caches);
  });
  const run = async (count: number, join = false) => {
    maxB = 0;
    sawQuantized = false;
    const group = new GenerationGateway(model, 3, async () => { throw new Error("seeded request fell back to serial"); }, { kvScheme });
    const outputs: Output[] = [];
    let joined: Promise<void> | undefined;
    const submit = async (index: number) => {
      const output: Output = [];
      outputs[index] = output;
      const o = options(index);
      const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: true,
        hasLogitsExtras: true, wantsLogprobs: true, userSeed: true,
        kvQuant: !!kvScheme && !turboQuant, turboQuant: !!turboQuant, hasGrammar: false, hasDraft: false };
      const placement = group.place(shape, o);
      expect(placement.mechanism).toBe("continuous");
      const stats = await group.run(prompts[index]!, o, (token, lp) => {
        output.push({ token, lp });
        if (join && index === 0 && output.length === 4) joined = submit(2);
      }, undefined, shape, placement);
      expect(stats.generatedTokens).toBe(o.maxTokens);
      expect(output).toHaveLength(o.maxTokens);
    };
    try {
      await Promise.all(Array.from({ length: count }, (_, i) => submit(i)));
      await joined;
      if (kvScheme) expect(sawQuantized).toBe(true);
      return { outputs, maxB };
    } finally { await group.close(); clearCache(); }
  };
  try {
    const serial: Output = [];
    for await (const t of generate(model, prompts[0]!, options(0))) serial.push({ token: t.token, lp: t.logprobs });
    const single = await run(1);
    expect(single.maxB).toBe(1);
    expect(single.outputs[0]).toEqual(serial);
    const pair = await run(2), repeat = await run(2);
    expect(pair.maxB).toBe(2);
    expect(repeat.outputs).toEqual(pair.outputs);
    const joined = await run(2, true), joinedRepeat = await run(2, true);
    expect(joined.maxB).toBe(3);
    expect(joinedRepeat.outputs).toEqual(joined.outputs);
    if (Number(Bun.env.MLX_BUN_TEST_BATCH_TURBO_START ?? 0) > 0 || affineStart > 0) expect(sawMixed).toBe(true);
    console.log(`[batch-seeded-sampling] ${kvScheme?.label ?? "bf16"}: serial/B=1 exact; fixed B=2 and controlled B=3 joins repeat exactly`);
  } finally { probe.mockRestore(); weights.dispose(); clearCache(); }
}, 300_000);
