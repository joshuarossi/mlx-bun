// Real-weight gate migrated from main's compiled-decode suite. Native imports
// stay inside beforeAll: an ordinary CI run skips without weights or MLX.
import { afterAll, afterEach, beforeAll, describe, expect, test } from "bun:test";
import type { MlxArray } from "@mlx-bun/mlx";
import type { Cache } from "@mlx-bun/inference/contracts/mlx";
import type { KvSchemeOptions } from "@mlx-bun/inference/state/kv-scheme";
import { configureRuntime } from "@mlx-bun/inference/runtime/config";

const timeout = 240_000;
const forcedTokens = [911, 604, 607, 610];
const promptOf = (length: number) => Array.from({ length }, (_, i) => 100 + (i * 7) % 1000);

for (const [family, checkpoint] of [
  ["12B", process.env.MLX_BUN_COMPILED_GEMMA12B],
  ["e4b", process.env.MLX_BUN_COMPILED_GEMMA_E4B],
] as const) {
  describe.skipIf(!checkpoint)(`compiled decode parity (${family})`, () => {
    let mlx: typeof import("@mlx-bun/mlx");
    let state: typeof import("@mlx-bun/inference/state");
    let CompiledDecode: typeof import("@mlx-bun/inference/generation/compiled-decode").CompiledDecode;
    let generate: typeof import("@mlx-bun/inference/generation").generate;
    let weights: import("@mlx-bun/inference/artifacts").Weights | undefined;
    let model: import("@mlx-bun/inference/models/gemma4").Gemma4Model;
    let initialRetraces: number;
    let growingPrompt: number[];
    let wrappedPrompt: number[];

    beforeAll(async () => {
      // A supplied but invalid checkpoint fails instead of silently skipping.
      expect(await Bun.file(`${checkpoint}/config.json`).exists()).toBe(true);
      mlx = await import("@mlx-bun/mlx");
      state = await import("@mlx-bun/inference/state");
      ({ CompiledDecode } = await import("@mlx-bun/inference/generation/compiled-decode"));
      ({ generate } = await import("@mlx-bun/inference/generation"));
      const { loadModelConfig, Weights } = await import("@mlx-bun/inference/artifacts");
      const { Gemma4Model } = await import("@mlx-bun/inference/models/gemma4");
      const { loadTokenizer, ChatTemplate } = await import("@mlx-bun/inference/input");
      const config = await loadModelConfig(checkpoint!);
      expect(config.modelType.startsWith("gemma4")).toBe(true);
      expect(config.text.enableMoeBlock).toBe(false);
      expect(config.kvQuant?.length).toBeGreaterThan(0);
      // These are different compiled paths: dense segmented vs e4b whole graph.
      expect(config.text.numKvSharedLayers > 0).toBe(family === "e4b");
      weights = await Weights.open(checkpoint!);
      model = new Gemma4Model(weights, config);
      expect(model.windowSize).toBeGreaterThan(8);
      expect(model.perLayerWidth > 0).toBe(family === "e4b");
      initialRetraces = CompiledDecode.unexpectedRetraces;
      const tokenizer = await loadTokenizer(checkpoint!);
      const template = await ChatTemplate.load(checkpoint!);
      // Keep main's rendered prompts for trajectories: arbitrary fixed IDs can
      // legitimately yield immediate EOS before any decode step is exercised.
      const renderedPrompt = (targetTokens: number): number[] => {
        let message = family === "12B"
          ? "Write a detailed essay about the history of computing."
          : "Explain how a transistor works.";
        const filler = family === "12B"
          ? "Background context: the history of computation spans mechanical " +
            "calculators, relays, vacuum tubes, transistors, and accelerators. "
          : "Context: semiconductors, doping, junctions, and gates matter here. ";
        while (tokenizer.encode(message).length < targetTokens - 24) message = filler + message;
        const ids = tokenizer.encode(template.render([{ role: "user", content: message }]));
        return ids[0] === ids[1] && ids[0] === tokenizer.bosTokenId ? ids.slice(1) : ids;
      };
      growingPrompt = renderedPrompt(600);
      wrappedPrompt = renderedPrompt(family === "12B" ? 1100 : 700);
    }, timeout);

    afterEach(() => {
      if (mlx) {
        mlx.synchronize(mlx.gpuStream);
        mlx.clearCache();
      }
      if (CompiledDecode && initialRetraces !== undefined)
        expect(CompiledDecode.unexpectedRetraces).toBe(initialRetraces);
    });
    afterAll(() => {
      // Closures borrow weight arrays. Release their tapes before the weights.
      if (model) CompiledDecode.for(model).dispose();
      weights?.dispose();
      if (mlx) { mlx.synchronize(mlx.gpuStream); mlx.clearCache(); }
    });

    function kvOptions(mixed: boolean): KvSchemeOptions {
      return mixed ? { kvConfig: model.config.kvQuant!, quantizedKvStart: 0 } : {};
    }
    function evalState(cache: Cache[], extra: MlxArray[] = []): void {
      const states = cache.map(c => ({ cache: c, planes: c.state() }));
      try { mlx.ops.evalAll([...extra, ...states.flatMap(s => s.planes)]); }
      finally {
        for (const { cache, planes } of states)
          if (cache.stateNeedsDispose) for (const plane of planes) plane.dispose();
      }
    }
    function forward(ids: number[], cache: Cache[]): MlxArray {
      const input = mlx.ops.fromInt32(ids, [1, ids.length]);
      try { return model.forwardHidden(input, cache); }
      finally { input.dispose(); }
    }
    async function trajectory(prompt: number[], compiled: boolean, extra: KvSchemeOptions): Promise<number[]> {
      const restore = configureRuntime({ MLX_BUN_COMPILED_DECODE: compiled ? "1" : "0" });
      try {
        const out: number[] = [];
        for await (const token of generate(model, prompt, {
          maxTokens: family === "12B" ? 32 : 24, temperature: 0, ...extra,
        })) out.push(token.token);
        return out;
      } finally { restore(); }
    }

    const trajectoryCases = family === "12B"
      ? ["plain growing", "plain wrapped", "uniform kv4 wrapped", "artifact mixed wrapped"]
      : ["plain wrapped", "artifact mixed wrapped"];
    for (const name of trajectoryCases) {
      test(`greedy trajectory and compiled activation: ${name}`, async () => {
        const prompt = name.endsWith("growing") ? growingPrompt : wrappedPrompt;
        const extra = name.startsWith("uniform")
          ? { kvBits: 4, kvGroupSize: 64, quantizedKvStart: 0 }
          : kvOptions(name.startsWith("artifact"));
        const before = CompiledDecode.stepsExecuted;
        const on = await trajectory(prompt, true, extra);
        const compiledSteps = CompiledDecode.stepsExecuted - before;
        const off = await trajectory(prompt, false, extra);
        expect(on.length).toBeGreaterThan(4);
        expect(on).toEqual(off);
        expect(compiledSteps).toBeGreaterThanOrEqual(on.length - 1);
      }, timeout);
    }

    // Compare original native bytes, including dtype and shape. No float cast,
    // tolerance, argmax-only check, or independently chosen continuation tokens.
    function fullLogits(compiled: boolean, context: number, mixed: boolean) {
      const cache = model.makeCache();
      const maintain = state.createKvMaintenance(kvOptions(mixed));
      const restore = configureRuntime({ MLX_BUN_COMPILED_DECODE: compiled ? "1" : "0" });
      try {
        const prefix = promptOf(context);
        for (let position = 0; position < prefix.length; position += 128) {
          const hidden = forward(prefix.slice(position, position + 128), cache);
          try { evalState(cache, [hidden]); maintain(cache); }
          finally { hidden.dispose(); }
          mlx.clearCache();
        }
        expect(cache.every(c => c.offset === context)).toBe(true);
        if (mixed) {
          for (const entry of model.config.kvQuant!) {
            const row = cache[entry.layerIdx];
            // The e4b config may also name sharers; only donor layers own cache.
            if (!row) continue;
            expect(row instanceof state.QuantizedKVCache || row instanceof state.RotatingQuantizedKVCache).toBe(true);
            expect((row as InstanceType<typeof state.QuantizedKVCache>).bits).toBe(entry.bits);
          }
        }
        const collected: { dtype: string; shape: number[]; bytes: Uint8Array }[] = [];
        for (const [step, token] of forcedTokens.entries()) {
          const signed = mlx.ops.fromInt32([token], [1]);
          const cur = signed.astype(mlx.Dtype.uint32);
          signed.dispose();
          let logits: MlxArray | undefined;
          try {
            if (compiled) {
              const result = CompiledDecode.for(model).step(cur, cache);
              logits = result.logits;
              mlx.ops.evalAll([logits, ...result.evalWith]);
            } else {
              const ids = mlx.ops.reshape(cur, [1, 1]);
              let hidden: MlxArray;
              try { hidden = model.forwardHidden(ids, cache); }
              finally { ids.dispose(); }
              try { logits = model.logitsFromHidden(hidden); }
              finally { hidden.dispose(); }
            }
            evalState(cache, [logits]);
            maintain(cache);
            const contiguous = mlx.ops.contiguous(logits);
            try {
              expect(contiguous.size).toBe(model.config.text.vocabSize);
              collected.push({ dtype: contiguous.dtypeName, shape: contiguous.shape, bytes: contiguous.rawBytes() });
            } finally { contiguous.dispose(); }
            expect(cache.every(c => c.offset === context + step + 1)).toBe(true);
          } finally { cur.dispose(); logits?.dispose(); }
        }
        return collected;
      } finally {
        for (const row of cache) row.dispose();
        restore();
      }
    }

    for (const mixed of [false, true]) {
      for (const phase of ["growing", "wrapped"] as const) {
        test(`forced-token full logits are bit-exact: ${mixed ? "artifact mixed" : "plain"}, ${phase}`, () => {
          const context = phase === "growing" ? Math.floor(model.windowSize / 2) : model.windowSize + 64;
          const before = CompiledDecode.stepsExecuted;
          const compiled = fullLogits(true, context, mixed);
          expect(CompiledDecode.stepsExecuted - before).toBe(forcedTokens.length);
          const plain = fullLogits(false, context, mixed);
          expect(compiled.length).toBe(forcedTokens.length);
          for (let step = 0; step < forcedTokens.length; step++) {
            expect(compiled[step]!.dtype).toBe(plain[step]!.dtype);
            expect(compiled[step]!.shape).toEqual(plain[step]!.shape);
            expect(compiled[step]!.bytes).toEqual(plain[step]!.bytes);
          }
        }, timeout);
      }
    }

    if (family === "12B") {
      test("mid-step segment failure rolls back writes before ordinary decode retries", async () => {
        const extra = { kvBits: 8, kvGroupSize: 64, quantizedKvStart: 0 };
        const prompt = wrappedPrompt;
        const origApply = mlx.CompiledFunction.prototype.apply;
        let segmentApplies = 0;
        let forcedThrows = 0;
        // Ring segments carry >10 inputs. Throw at the SECOND ring segment,
        // after the first staged ring update and an intervening real KV write.
        // Uniform kv8 has a unique closure key: the injected fault poisons it.
        mlx.CompiledFunction.prototype.apply = function (inputs) {
          if (inputs.length > 10 && ++segmentApplies === 2) {
            forcedThrows++;
            throw new Error("forced mid-step trace failure (test)");
          }
          return origApply.call(this, inputs);
        };
        try {
          const recovered = await trajectory(prompt, true, extra);
          expect(forcedThrows).toBe(1);
          mlx.CompiledFunction.prototype.apply = origApply;
          const clean = await trajectory(prompt, false, extra);
          expect(recovered.length).toBeGreaterThan(4);
          expect(recovered).toEqual(clean);
        } finally { mlx.CompiledFunction.prototype.apply = origApply; }
      }, timeout);
    }
  });
}
