// Compiled-decode parity gate (optimization_plan.md Phase A, step 5):
// the compiled step must be BIT-EXACT with the uncompiled path — full
// logit vectors and greedy trajectories — across every cache
// configuration (plain/quantized × growing/ring). Compile must not
// change numerics; any divergence here is root-caused, never tolerated.
//
// Prompt lengths are chosen against the 12B's sliding window (1024):
// ~600 tokens keeps rotating caches in the growing ("concat") phase,
// ~1300 wraps them into the steady ring phase.

import { afterAll, afterEach, describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();

const E4B_SNAPSHOT = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/fcdb12d740cd813634064567fc7cb51159b34253`;
const have4b = await Bun.file(`${E4B_SNAPSHOT}/config.json`).exists();

describe.skipIf(!haveWeights)("compiled decode parity (12B)", async () => {
  if (!haveWeights) return;
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model, argmaxLastPosition, lastPositionLogits } = await import("../src/model/gemma4");
  const { CompiledDecode } = await import("../src/model/compiled-decode");
  const { generate } = await import("../src/generate");
  const { loadTokenizer } = await import("../src/tokenizer");
  const { ChatTemplate } = await import("../src/chat-template");
  const ops = await import("../src/mlx/ops");

  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
  const model = new Gemma4Model(weights, config);
  const tok = await loadTokenizer(SNAPSHOT);
  const template = await ChatTemplate.load(SNAPSHOT);

  // The suite runs in one process: free the compiled closures and hand
  // the allocator's cached transients back, or this file's residual
  // pushes the combined suite over the working-set cliff.
  afterAll(async () => {
    // closures hold tape references into the weights: dispose them first,
    // then free the weight arrays themselves — this file's models must
    // not stay resident under the rest of the suite (the combined
    // process otherwise crosses the pressure line where an async Metal
    // alloc failure becomes the documented uncatchable crash)
    CompiledDecode.for(model).dispose();
    weights.dispose();
    (await import("../src/mlx/ffi")).clearCache();
  });
  // the suite shares one process: return pooled transients promptly
  afterEach(async () => (await import("../src/mlx/ffi")).clearCache());

  const promptOf = (targetTokens: number): number[] => {
    let msg = "Write a detailed essay about the history of computing.";
    const filler =
      "Background context: the history of computation spans mechanical " +
      "calculators, relays, vacuum tubes, transistors, and accelerators. ";
    while (tok.encode(msg).length < targetTokens - 24) msg = filler + msg;
    const ids = tok.encode(template.render([{ role: "user", content: msg }]));
    return ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;
  };

  const SHORT = promptOf(600);
  // > the 1024 sliding window (ring phase) but no larger: this file
  // shares the suite's process and its prefill transients stack on
  // everything else's residency
  const LONG = promptOf(1100);

  const trajectory = async (
    promptIds: number[], compiled: boolean, extra: object = {},
  ): Promise<number[]> => {
    const prev = process.env.MLX_BUN_COMPILED_DECODE;
    process.env.MLX_BUN_COMPILED_DECODE = compiled ? "1" : "0";
    try {
      const out: number[] = [];
      const gen = generate(model, promptIds, { maxTokens: 32, temperature: 0, ...extra });
      for await (const t of gen) out.push(t.token);
      return out;
    } finally {
      if (prev === undefined) delete process.env.MLX_BUN_COMPILED_DECODE;
      else process.env.MLX_BUN_COMPILED_DECODE = prev;
    }
  };

  const cases: [string, number[], object][] = [
    ["bf16 caches, growing phase", SHORT, {}],
    ["bf16 caches, ring phase", LONG, {}],
    ["uniform kv4, ring phase", LONG, { kvBits: 4, kvGroupSize: 64, quantizedKvStart: 0 }],
    ["kv_config mixed per-layer, ring phase", LONG, { kvConfig: config.kvQuant!, quantizedKvStart: 0 }],
  ];

  for (const [name, prompt, extra] of cases) {
    test(`greedy trajectory identical: ${name}`, async () => {
      const before = CompiledDecode.stepsExecuted;
      const on = await trajectory(prompt, true, extra);
      const compiledSteps = CompiledDecode.stepsExecuted - before;
      const off = await trajectory(prompt, false, extra);
      expect(on.length).toBeGreaterThan(4);
      expect(on).toEqual(off);
      // the compiled path must actually have run (no silent fallback)
      expect(compiledSteps).toBeGreaterThanOrEqual(on.length - 1);
    }, 240_000);
  }

  test("full logit vectors bit-exact per compiled step (ring + concat)", () => {
    const STEPS = 4;
    const run = (compiled: boolean): Float32Array[] => {
      const cache = model.makeCache();
      try {
        const ids0 = ops.fromInt32(LONG, [1, LONG.length]);
        const h0 = model.forwardHidden(ids0, cache);
        ids0.dispose();
        const logits0 = model.logitsFromHidden(h0);
        h0.dispose();
        let next = argmaxLastPosition(logits0);
        logits0.dispose();

        const collected: Float32Array[] = [];
        for (let s = 0; s < STEPS; s++) {
          // production feeds the sampler's uint32 token array; matching
          // dtype keeps the closure on one trace signature (the retrace
          // detector flags signature drift by design)
          const curI32 = ops.fromInt32([next], [1]);
          const cur = curI32.astype(3 /* Dtype.uint32 */);
          curI32.dispose();
          let logits;
          if (compiled) {
            const r = CompiledDecode.for(model).step(cur, cache);
            logits = r.logits;
            ops.evalAll([logits, ...r.evalWith]);
          } else {
            const ids = ops.reshape(cur, [1, 1]);
            const h = model.forwardHidden(ids, cache);
            ids.dispose();
            logits = model.logitsFromHidden(h);
            h.dispose();
            ops.evalAll([logits, ...cache.flatMap((c) => c.state())]);
          }
          cur.dispose();
          collected.push(lastPositionLogits(logits));
          next = argmaxLastPosition(logits);
          logits.dispose();
        }
        return collected;
      } finally {
        for (const c of cache) c.dispose();
      }
    };

    const compiled = run(true);
    const plain = run(false);
    for (let s = 0; s < compiled.length; s++) {
      let maxDiff = 0;
      for (let i = 0; i < plain[s]!.length; i++)
        maxDiff = Math.max(maxDiff, Math.abs(compiled[s]![i]! - plain[s]![i]!));
      expect(maxDiff).toBe(0); // bit-exact: compile must not change numerics
    }
  }, 240_000);
});

describe.skipIf(!have4b)("compiled decode parity (e4b: per-layer input + KV sharing)", async () => {
  if (!have4b) return;
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model } = await import("../src/model/gemma4");
  const { CompiledDecode } = await import("../src/model/compiled-decode");
  const { generate } = await import("../src/generate");
  const { loadTokenizer } = await import("../src/tokenizer");
  const { ChatTemplate } = await import("../src/chat-template");

  const config = await loadModelConfig(E4B_SNAPSHOT);
  const weights = await Weights.open(E4B_SNAPSHOT);
  const model = new Gemma4Model(weights, config);
  const tok = await loadTokenizer(E4B_SNAPSHOT);
  const template = await ChatTemplate.load(E4B_SNAPSHOT);

  afterAll(async () => {
    CompiledDecode.for(model).dispose();
    weights.dispose();
    (await import("../src/mlx/ffi")).clearCache();
  });
  afterEach(async () => (await import("../src/mlx/ffi")).clearCache());

  // e4b window is 512: 700 tokens already wraps the rings
  let msg = "Explain how a transistor works.";
  const filler = "Context: semiconductors, doping, junctions, and gates matter here. ";
  while (tok.encode(msg).length < 700 - 24) msg = filler + msg;
  const ids = tok.encode(template.render([{ role: "user", content: msg }]));
  const prompt = ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;

  for (const [name, extra] of [
    ["bf16", {}],
    ["kv_config mixed", { kvConfig: config.kvQuant!, quantizedKvStart: 0 }],
  ] as const) {
    test(`greedy trajectory identical: ${name}`, async () => {
      const collect = async (compiled: boolean): Promise<number[]> => {
        process.env.MLX_BUN_COMPILED_DECODE = compiled ? "1" : "0";
        try {
          const out: number[] = [];
          const gen = generate(model, prompt, { maxTokens: 24, temperature: 0, ...extra });
          for await (const t of gen) out.push(t.token);
          return out;
        } finally {
          delete process.env.MLX_BUN_COMPILED_DECODE;
        }
      };
      const before = CompiledDecode.stepsExecuted;
      const on = await collect(true);
      const compiledSteps = CompiledDecode.stepsExecuted - before;
      const off = await collect(false);
      expect(on.length).toBeGreaterThan(4);
      expect(on).toEqual(off);
      expect(compiledSteps).toBeGreaterThanOrEqual(on.length - 1);
    }, 240_000);
  }
});
