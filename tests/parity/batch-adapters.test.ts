// MLX_BUN_TEST_BATCH_ADAPTERS=1 bun test tests/parity/batch-adapters.test.ts
import { expect, test, spyOn } from "bun:test";
import { existsSync } from "node:fs";

const artifact = Bun.env.MLX_BUN_TEST_BATCH_ADAPTER_MODEL ??
  `${Bun.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/98d7dc6a93ae05583e8a10018c8099459b58aeeb`;
const enabled = Bun.env.MLX_BUN_TEST_BATCH_ADAPTERS === "1" &&
  existsSync(`${artifact}/config.json`) && existsSync("fixtures/adapters/upper/adapters.safetensors");

test.skipIf(!enabled)("adapter sets share compatible batches and retain separate prefix state", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { Gemma4Model } = await import("../../src/model/gemma4");
  const { AdapterManager } = await import("../../src/lora");
  const { GenerationGateway } = await import("../../src/serve/generation-gateway");
  const { generate } = await import("../../src/generate");
  const { PromptCache } = await import("../../src/prompt-cache");
  const { resolveKvScheme } = await import("../../src/kv-scheme");
  const { QuantizedKVCache, RotatingQuantizedKVCache } = await import("../../src/model/gemma4-base");
  const bits = Bun.env.MLX_BUN_TEST_BATCH_ADAPTER_KV_BITS;
  const kvScheme = bits ? resolveKvScheme({ override: Number(bits) }) : undefined;
  const capture = Bun.env.MLX_BUN_TEST_BATCH_ADAPTER_LOGPROBS === "1";
  let sawQuantized = false;
  const { clearCache } = await import("../../src/mlx/ffi");
  const weights = await Weights.open(artifact);
  const model = new Gemma4Model(weights, await loadModelConfig(artifact));
  const manager = new AdapterManager(model);
  const cache = new PromptCache(1024 ** 3);
  const prompt = [2, 105, 2364, 107, 1567, 506, 2390, 107];
  const frames: Array<{ batch: number; adapters: string[] }> = [];
  const forward = model.forwardHidden.bind(model);
  const probe = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
    frames.push({ batch: ids.shape[0]!, adapters: [...model.loraState.active] });
    sawQuantized ||= caches.some(cache => cache instanceof QuantizedKVCache || cache instanceof RotatingQuantizedKVCache);
    return forward(ids, caches);
  });
  type Request = { adapters: string[]; tokens?: number; fail?: boolean };
  const run = async (batch: number, requests: Request[], promptIds = prompt, cached = false, replaceBeforeAdmission = false) => {
    frames.length = 0;
    const gateway = new GenerationGateway(model, batch, async (ids, options, sink) => {
      if (batch > 1) throw new Error("adapter request reached the serial executor");
      const gen = generate(model, ids, options);
      for await (const value of gen) await sink(value.token, value.logprobs);
      return gen.stats!;
    }, { kvScheme, ...(cached ? { promptCache: cache } : {}),
      adapterNamespace: ids => manager.cacheNamespace(ids) });
    let unblock: (() => void) | undefined;
    const hold = replaceBeforeAdmission ? new Promise<void>(resolve => { unblock = resolve; }) : undefined;
    const replacement = replaceBeforeAdmission ? gateway.runExclusive(async () => {
      await hold;
      manager.unmount("upper");
      await manager.mount("upper", "fixtures/adapters/french");
    }) : undefined;
    try {
      const pending = requests.map(async ({ adapters, tokens = 12, fail }) => {
        const shape = { hasVision: false, hasAdapters: adapters.length > 0,
          hasRepetitionPenalty: false, hasLogitsExtras: false, userSeed: false,
          wantsLogprobs: capture, hasDraft: false, kvQuant: !!kvScheme, turboQuant: false, hasGrammar: false };
        const options = { ...kvScheme?.generationOptions, logprobs: capture, topLogprobs: capture ? 3 : 0, adapters, maxTokens: tokens, temperature: 0, eosTokenIds: [], snapshotAt: promptIds.length - 1 };
        const placement = gateway.place(shape, options);
        expect(placement.mechanism).toBe(batch === 1 ? "serial" : "continuous");
        const output: number[] = [];
        try {
          const stats = await gateway.run(promptIds, options, (token, logprobs) => {
            if (capture) {
              expect(Number.isFinite(logprobs?.logprob)).toBe(true);
              expect(logprobs?.top).toHaveLength(3);
            }
            output.push(token);
            if (fail && output.length === 2) throw new Error("adapter callback failed");
          }, undefined, shape, placement);
          return { output, stats };
        } catch (error) {
          if (!fail) throw error;
          expect(String(error)).toContain("adapter callback failed");
          return { output, stats: null };
        }
      });
      unblock?.();
      await replacement;
      const results = await Promise.all(pending);
      return { results, frames: [...frames] };
    } finally { unblock?.(); await gateway.close(); expect(model.loraState.active).toEqual([]); clearCache(); }
  };
  try {
    await manager.mount("upper", "fixtures/adapters/upper");
    await manager.mount("french", "fixtures/adapters/french");
    const upper = { adapters: ["upper"] }, french = { adapters: ["french"] }, base = { adapters: [] };
    const serial = await run(1, [upper]);
    expect((await run(4, [upper])).results[0]!.output).toEqual(serial.results[0]!.output);
    const pair = await run(4, [upper, upper]);
    expect(pair.frames.some(frame => frame.batch === 2)).toBe(true);
    expect(pair.frames.every(frame => frame.adapters.join() === "upper")).toBe(true);
    const frenchAlone = await run(4, [french]), baseAlone = await run(4, [base]);
    const mixed = await run(4, [upper, upper, french, base, upper]);
    expect(mixed.results.slice(0, 2).map(result => result.output))
      .toEqual(pair.results.map(result => result.output));
    expect(mixed.results[2]!.output).toEqual(frenchAlone.results[0]!.output);
    expect(mixed.results[3]!.output).toEqual(baseAlone.results[0]!.output);
    expect(mixed.results[4]!.output).toEqual(serial.results[0]!.output);
    expect(mixed.frames.filter(frame => frame.batch > 1).every(frame => frame.adapters.join() === "upper")).toBe(true);
    const failed = await run(4, [{ ...upper, fail: true }, upper, french]);
    expect(failed.results[0]!.stats).toBeNull();
    expect(failed.results[1]!.output).toHaveLength(12);
    expect(failed.results[2]!.output).toEqual(frenchAlone.results[0]!.output);
    const longPrompt = Array.from({ length: 259 }, (_, index) => prompt[index % prompt.length]!);
    const coldUpper = await run(4, [upper], longPrompt, true);
    const coldFrench = await run(4, [french], longPrompt, true);
    expect(coldUpper.results[0]!.stats!.cachedTokens).toBe(0);
    expect(coldFrench.results[0]!.stats!.cachedTokens).toBe(0);
    const warmUpper = await run(4, [upper], longPrompt, true);
    const warmFrench = await run(4, [french], longPrompt, true);
    expect(warmUpper.results[0]!.stats!.cachedTokens).toBe(258);
    expect(warmFrench.results[0]!.stats!.cachedTokens).toBe(258);
    expect(warmUpper.results[0]!.output).toEqual(coldUpper.results[0]!.output);
    expect(warmFrench.results[0]!.output).toEqual(coldFrench.results[0]!.output);
    const replaced = await run(4, [upper], longPrompt, true, true);
    expect(replaced.results[0]!.stats!.cachedTokens).toBe(0);
    expect(replaced.results[0]!.output).toEqual(coldFrench.results[0]!.output);
    expect((await run(4, [upper], longPrompt, true)).results[0]!.stats!.cachedTokens).toBe(258);
    if (kvScheme) expect(sawQuantized).toBe(true);
    console.log("[batch-adapters] B=1 control, B=2 compatible groups, mixed queue, failure cleanup and isolated prefix reuse pass");
  } finally {
    probe.mockRestore(); cache.clear(); manager.unmount("upper"); manager.unmount("french");
    weights.dispose(); clearCache();
  }
}, 300_000);
