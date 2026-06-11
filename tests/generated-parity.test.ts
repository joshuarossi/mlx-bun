// Generated-model parity (optimization_plan.md Phase C): the generated
// specialization must be BIT-EXACT with the monolith under the config it
// was generated for (the shipped kv_config serve scenario) — the gate IS
// the generator's test. Covers prefill (L>1, causal/window masks), ring
// + growing decode, and the compiled-decode interplay (the trace runs
// through the generated forwardLayers).

import { afterAll, afterEach, describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();

describe.skipIf(!haveWeights)("generated 12B vs monolith", async () => {
  if (!haveWeights) return;
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model, argmaxLastPosition, lastPositionLogits } = await import("../src/model/gemma4");
  const g12b = await import("../src/model/generated/gemma4-12b");
  const { configFingerprint } = await import("../src/model/fingerprint");
  const { CompiledDecode } = await import("../src/model/compiled-decode");
  const { generate } = await import("../src/generate");
  const { loadTokenizer } = await import("../src/tokenizer");
  const ops = await import("../src/mlx/ops");

  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
  // both models share the weights object (and so the same tensor handles)
  const mono = new Gemma4Model(weights, config);
  const gen = new g12b.GeneratedGemma4(weights, config);
  const tok = await loadTokenizer(SNAPSHOT);

  afterAll(async () => {
    CompiledDecode.for(mono).dispose();
    CompiledDecode.for(gen).dispose();
    weights.dispose();
    (await import("../src/mlx/ffi")).clearCache();
  });
  afterEach(async () => (await import("../src/mlx/ffi")).clearCache());

  let msg = "Explain the memory hierarchy of a modern computer in detail.";
  const filler = "Context: caches, DRAM, bandwidth, and latency all interact. ";
  while (tok.encode(msg).length < 1100) msg = filler + msg;
  const prompt = tok.encode(msg).slice(0, 1100);

  test("fingerprint dispatch matches this config", () => {
    expect(configFingerprint(config)).toBe(g12b.FINGERPRINT);
  });

  const trajectory = async (
    model: InstanceType<typeof Gemma4Model>, compiled: boolean,
  ): Promise<number[]> => {
    process.env.MLX_BUN_COMPILED_DECODE = compiled ? "1" : "0";
    try {
      const out: number[] = [];
      const g = generate(model, prompt, {
        maxTokens: 24, temperature: 0, kvConfig: config.kvQuant!, quantizedKvStart: 0,
      });
      for await (const t of g) out.push(t.token);
      return out;
    } finally {
      delete process.env.MLX_BUN_COMPILED_DECODE;
    }
  };

  test("greedy trajectories identical under the serve kv_config (compiled on)", async () => {
    const uses0 = g12b.generatedForwardUses;
    const a = await trajectory(gen, true);
    const usedGenerated = g12b.generatedForwardUses - uses0;
    const b = await trajectory(mono, true);
    expect(a.length).toBeGreaterThan(4);
    expect(a).toEqual(b);
    // under SEGMENTED compiled decode the per-step path is CompiledDecode's
    // (layer-wise segments), so the generated forwardLayers serves the
    // prefill only; full decode coverage is the uncompiled test below
    expect(usedGenerated).toBeGreaterThanOrEqual(1);
  }, 240_000);

  test("greedy trajectories identical, uncompiled (full generated coverage)", async () => {
    const uses0 = g12b.generatedForwardUses;
    const a = await trajectory(gen, false);
    const usedGenerated = g12b.generatedForwardUses - uses0;
    const b = await trajectory(mono, false);
    expect(a.length).toBeGreaterThan(4);
    expect(a).toEqual(b);
    // prefill + every decode step ride the generated fast path
    expect(usedGenerated).toBeGreaterThanOrEqual(a.length - 1);
  }, 240_000);

  test("logits bit-exact per step (uncompiled isolation)", () => {
    process.env.MLX_BUN_COMPILED_DECODE = "0";
    try {
      const run = (model: InstanceType<typeof Gemma4Model>): Float32Array[] => {
        const cache = model.makeCache();
        try {
          // serve scenario: convert per kv_config before any forward
          for (let i = 0; i < cache.length; i++) {
            const e = config.kvQuant!.find((q) => q.layerIdx === i);
            if (e) cache[i] = (cache[i] as never as { toQuantized(g: number, b: number): typeof cache[number] }).toQuantized(e.groupSize, e.bits);
          }
          const collected: Float32Array[] = [];
          let tokens: number[] = prompt;
          for (let s = 0; s < 3; s++) {
            const logits = model.forward(tokens, cache);
            collected.push(lastPositionLogits(logits));
            const next = argmaxLastPosition(logits);
            logits.dispose();
            tokens = [next];
          }
          return collected;
        } finally {
          for (const c of cache) c.dispose();
        }
      };
      const a = run(gen);
      const b = run(mono);
      for (let s = 0; s < a.length; s++) {
        let maxDiff = 0;
        for (let i = 0; i < a[s]!.length; i++)
          maxDiff = Math.max(maxDiff, Math.abs(a[s]![i]! - b[s]![i]!));
        expect(maxDiff).toBe(0);
      }
    } finally {
      delete process.env.MLX_BUN_COMPILED_DECODE;
    }
  }, 240_000);

  test("bf16 compat config falls back to the monolith path, identical output", () => {
    const uses0 = g12b.generatedForwardUses;
    const cacheA = gen.makeCache();
    const cacheB = mono.makeCache();
    try {
      const la = gen.forward(prompt.slice(0, 64), cacheA);
      const lb = mono.forward(prompt.slice(0, 64), cacheB);
      const fa = lastPositionLogits(la);
      const fb = lastPositionLogits(lb);
      la.dispose();
      lb.dispose();
      expect(Buffer.compare(Buffer.from(fa.buffer), Buffer.from(fb.buffer))).toBe(0);
      // bf16 caches don't match the generated signature → fallback
      expect(g12b.generatedForwardUses).toBe(uses0);
    } finally {
      for (const c of [...cacheA, ...cacheB]) c.dispose();
    }
  }, 120_000);

  void ops;
});

const E4B_SNAPSHOT = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/fcdb12d740cd813634064567fc7cb51159b34253`;
const have4b = await Bun.file(`${E4B_SNAPSHOT}/config.json`).exists();

describe.skipIf(!have4b)("generated e4b vs monolith (KV sharing + per-layer input)", async () => {
  if (!have4b) return;
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model } = await import("../src/model/gemma4");
  const ge4b = await import("../src/model/generated/gemma4-e4b");
  const { configFingerprint } = await import("../src/model/fingerprint");
  const { CompiledDecode } = await import("../src/model/compiled-decode");
  const { generate } = await import("../src/generate");
  const { loadTokenizer } = await import("../src/tokenizer");

  const config = await loadModelConfig(E4B_SNAPSHOT);
  const weights = await Weights.open(E4B_SNAPSHOT);
  const mono = new Gemma4Model(weights, config);
  const gen = new ge4b.GeneratedGemma4(weights, config);
  const tok = await loadTokenizer(E4B_SNAPSHOT);

  afterAll(async () => {
    CompiledDecode.for(mono).dispose();
    CompiledDecode.for(gen).dispose();
    weights.dispose();
    (await import("../src/mlx/ffi")).clearCache();
  });
  afterEach(async () => (await import("../src/mlx/ffi")).clearCache());

  let msg = "Describe how rain forms.";
  const filler = "Context: evaporation, condensation, nucleation, droplets. ";
  while (tok.encode(msg).length < 700) msg = filler + msg;
  const prompt = tok.encode(msg).slice(0, 700);

  test("fingerprint dispatch matches this config", () => {
    expect(configFingerprint(config)).toBe(ge4b.FINGERPRINT);
  });

  for (const compiled of [false, true]) {
    test(`greedy trajectories identical under serve kv_config (compiled ${compiled ? "on" : "off"})`, async () => {
      const run = async (model: InstanceType<typeof Gemma4Model>): Promise<number[]> => {
        process.env.MLX_BUN_COMPILED_DECODE = compiled ? "1" : "0";
        try {
          const out: number[] = [];
          const g = generate(model, prompt, {
            maxTokens: 20, temperature: 0, kvConfig: config.kvQuant!, quantizedKvStart: 0,
          });
          for await (const t of g) out.push(t.token);
          return out;
        } finally {
          delete process.env.MLX_BUN_COMPILED_DECODE;
        }
      };
      const uses0 = ge4b.generatedForwardUses;
      const a = await run(gen);
      const usedGenerated = ge4b.generatedForwardUses - uses0;
      const b = await run(mono);
      expect(a.length).toBeGreaterThan(4);
      expect(a).toEqual(b);
      // e4b runs whole-graph compiled decode, which traces through
      // forwardLayers — generated path serves prefill AND decode in
      // both modes (compiled: once per closure trace + prefill)
      expect(usedGenerated).toBeGreaterThanOrEqual(compiled ? 1 : a.length - 1);
    }, 240_000);
  }
});
