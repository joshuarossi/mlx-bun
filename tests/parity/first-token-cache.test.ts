// Opt-in native gate for retained caches after a consumer stops at token zero.
// MLX_BUN_TEST_FIRST_TOKEN_MODEL=/path bun test tests/parity/first-token-cache.test.ts
import { expect, test } from "bun:test";
import { createHash } from "node:crypto";

const artifact = Bun.env.MLX_BUN_TEST_FIRST_TOKEN_MODEL;

test.skipIf(!artifact)("early first-token return preserves retained state and later multi-token prefills", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");
  const { generate } = await import("../../src/generate");
  const { configureRuntime } = await import("../../src/runtime-config");
  const { cloneKvCaches } = await import("../../src/kv-store");
  const { leaseCacheStates } = await import("../../src/backends/mlx/state-views");
  const { withResource } = await import("../../src/engine/resources");
  const { clearCache } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const weights = await Weights.open(artifact!);
  const model = createModel(weights, await loadModelConfig(artifact!));
  const tokenizer = await loadTokenizer(artifact!), template = await ChatTemplate.load(artifact!);
  const digest = (array: import("../../src/mlx/array").MlxArray) => {
    const data = ops.contiguous(array);
    try { return createHash("sha256").update(data.rawBytesView()).digest("hex"); }
    finally { data.dispose(); }
  };
  const state = (caches: import("../../src/model/gemma4").Cache[]) => caches.map(cache =>
    withResource(leaseCacheStates([cache]), arrays => ({
      kind: cache.signature(), offset: cache.offset,
      tensors: arrays.map(array => {
        const shape = array.shape;
        const live = cache.signature() !== "ssm" && shape.length === 4 && cache.offset < shape[2]!
          ? array.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, cache.offset, shape[3]!]) : null;
        try { return { shape: (live ?? array).shape, dtype: array.dtype, hash: digest(live ?? array) }; }
        finally { live?.dispose(); }
      }),
    })));
  try {
    for (const repeats of [1, 24]) {
      const content = "The workshop inventory contains brass washers, maple dowels and copper wire. ".repeat(repeats)
        + "Summarize the inventory in one sentence.";
      const prompt = tokenizer.encode(template.render([{ role: "user", content }], { enableThinking: true }));
      const runs: Array<{ token: number; tokens: number[]; caches: ReturnType<typeof model.makeCache> }> = [];
      try {
        for (const early of [false, true]) {
          const caches = model.makeCache();
          const restore = configureRuntime({ MLX_BUN_EARLY_FIRST_TOKEN: early ? "1" : "0" });
          let retained = false;
          try {
            const generation = generate(model, prompt, { cache: caches, maxTokens: 8, temperature: 0 });
            const iterator = generation[Symbol.asyncIterator]();
            const first = await iterator.next();
            expect(first.done).toBe(false);
            await iterator.return(undefined);
            expect(generation.stats!.generatedTokens).toBe(1);
            expect(generation.stats!.cacheTokens).toHaveLength(prompt.length + 1);
            runs.push({ token: first.value!.token, tokens: generation.stats!.cacheTokens, caches });
            retained = true;
          } finally {
            restore();
            if (!retained) for (const cache of caches) cache.dispose();
          }
        }
        expect(runs[1]!.token).toBe(runs[0]!.token);
        expect(runs[1]!.tokens).toEqual(runs[0]!.tokens);
        expect(state(runs[1]!.caches)).toEqual(state(runs[0]!.caches));
        for (const length of [1, 2, 4, 5, 16]) {
          const suffix = Array.from({ length }, (_, i) => 420 + i);
          const results = runs.map(run => {
            const caches = cloneKvCaches(run.caches);
            try {
              const logits = model.forward(suffix, caches);
              try { return { logits: digest(logits), state: state(caches) }; }
              finally { logits.dispose(); }
            } finally { for (const cache of caches) cache.dispose(); }
          });
          expect(results[1]).toEqual(results[0]);
        }
        console.log(`[first-return] prompt=${prompt.length}: retained state and five continuation shapes exact`);
      } finally {
        for (const run of runs) for (const cache of run.caches) cache.dispose();
        clearCache();
      }
    }
  } finally { weights.dispose(); clearCache(); }
}, 300_000);
