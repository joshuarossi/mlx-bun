// GATED: vectorized homogeneous sampling (batching-perf-path P0, executed as
// integration-plan Phase D).
//
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batch-vec-sample.test.ts
//
// When every live row is plain greedy (temperature 0, no processors, no
// grammar), the scheduler samples the whole step with ONE log-softmax+argmax
// over [B,V] instead of B slice/sample/concat graphs. The gate is BIT
// equality: the vectorized path and the per-row closure path
// (MLX_BUN_BATCH_VEC_SAMPLE=0) must produce token-identical streams — the
// ops are row-independent with identical per-row shapes, so any divergence
// is a bug, not noise. Also: a mixed batch (one temperature>0 row) must
// take the per-row path and still work.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const CPM_BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveCpm = existsSync(`${CPM_BASE}/config.json`);

describe.skipIf(!optIn || !haveCpm)("batch scheduler — vectorized greedy sampling (CPM)", () => {
  test("vectorized == per-row (bit equality), mixed batch falls back", async () => {
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { GenerationGateway } = await import("../src/serve/generation-gateway");

    const config = await loadModelConfig(CPM_BASE);
    const weights = await Weights.open(CPM_BASE);
    const model = createModel(weights, config);
    const { loadTokenizer } = await import("../src/tokenizer");
    const tok = await loadTokenizer(CPM_BASE);
    const SHAPE = {
      hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
      userSeed: false, kvQuant: false, hasLogitsExtras: false,
      wantsLogprobs: false, hasGrammar: false, hasDraft: false,
    };
    const PROMPTS = [
      "The mountain path wound upward through",
      "Long ago, in a village by the river,",
      "The recipe calls for three cups of",
    ];

    const runBatch = async (temps: number[]): Promise<number[][]> => {
      const gw = new GenerationGateway(model, 4, async () => {
        throw new Error("serial lane reached");
      });
      const results = await Promise.all(
        PROMPTS.map(async (p, i) => {
          const got: number[] = [];
          await gw.run(
            tok.encode(p),
            { maxTokens: 12, temperature: temps[i] ?? 0 },
            (t) => { got.push(t); },
            undefined,
            SHAPE,
          );
          return got;
        }),
      );
      return results;
    };

    try {
      // A: vectorized (default on, all-greedy)
      delete process.env.MLX_BUN_BATCH_VEC_SAMPLE;
      const vec = await runBatch([0, 0, 0]);
      // B: per-row closure path (kill switch)
      process.env.MLX_BUN_BATCH_VEC_SAMPLE = "0";
      const loop = await runBatch([0, 0, 0]);
      delete process.env.MLX_BUN_BATCH_VEC_SAMPLE;

      expect(vec).toEqual(loop); // BIT equality — same math, same order
      for (const s of vec) expect(s.length).toBe(12);

      // mixed batch: one sampled row disqualifies the fast path (per-row
      // closures run); everything still completes.
      const mixed = await runBatch([0, 0.8, 0]);
      for (const s of mixed) expect(s.length).toBe(12);
      // greedy rows are unaffected by the sampled sibling (row independence)
      expect(mixed[0]).toEqual(vec[0]);
      expect(mixed[2]).toEqual(vec[2]);
    } finally {
      weights.dispose();
    }
  }, 300_000);
});
