// GATED: rotating-layer join-during-decode (regression for the 2026-08-22
// agg×4 outage).
//
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batch-rotating-join.test.ts
//
// Scenario: a hybrid sliding-window model (gemma-4-e4b → BatchedRotatingCache
// layers) is decoding one row when three more rows join mid-decode. The merge
// must carry the RUNNING batch's cache into BatchedRotatingCache.merge —
// 443f333 routed it through isRotatingPlainCache(), whose signature check is
// false for every BatchedRotatingCache (the class has no signature()
// override, so cacheSignature → "unknown"), prevRot evaluated undefined, the
// merged ring was built without the running row, and the next full-B decode
// step crashed in updateAndFetch's grow-path concatenate — whole-batch drop,
// every stream closed silently after 1-2 tokens. Fix routes by capability
// (isRowBatchCache) alone; this test pins that.
//
// Uses e4b (the hybrid model the outage reproduced on). Full-attention
// routing lives in tests/batch-containment.test.ts (CPM).

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { hfSnapshot } from "../support/paths";
import * as ops from "../../src/mlx/ops";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const E4B_BASE = hfSnapshot("models--mlx-community--gemma-4-e4b-it-OptiQ-4bit");
const haveE4b = existsSync(`${E4B_BASE}/config.json`);

describe.skipIf(!optIn || !haveE4b)("rotating-layer join-during-decode (e4b)", async () => {
  if (!optIn || !haveE4b) return;
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { createModel } = await import("../../src/model/factory");
  const { BatchScheduler } = await import("../../src/serve/batch-scheduler");

  const config = await loadModelConfig(E4B_BASE);
  const weights = await Weights.open(E4B_BASE);
  const model = createModel(weights, config);

  test("rows joining a running rotating-layer batch all complete", async () => {
    const sched = new BatchScheduler(model, { maxBatch: 4 });
    const MAX = 8;
    const joiners: Promise<{ generatedTokens: number; finishReason: string }>[] = [];
    let got = 0;

    // Row A starts alone. On its SECOND decoded token, burst-admit B/C/D —
    // the exact admission order behind the outage (running batch + joiners
    // merged mid-decode).
    const first = sched.submit({
      promptIds: [2, 5_769, 8_467, 2_359, 107, 106],
      maxTokens: MAX,
      eosTokenIds: [], // fixed-length rows: every survivor must reach its max
      sample: (l) => ops.argmaxAxis(l, -1),
      onToken: () => {
        got++;
        if (got === 2 && joiners.length === 0) {
          for (let i = 1; i <= 3; i++) {
            joiners.push(
              sched.submit({
                promptIds: [2, 5_769 + i, 8_467, 2_359, 107, 106],
                maxTokens: MAX - i,
                eosTokenIds: [],
                sample: (l) => ops.argmaxAxis(l, -1),
                onToken: () => {},
              }),
            );
          }
        }
      },
    });

    const all = await Promise.all([first, ...joiners]);
    // Pre-fix the joiners rejected with the concatenate crash and row A died
    // with them (whole-batch drop); post-fix every row runs to its own length.
    expect(all[0]!.generatedTokens).toBe(MAX);
    expect(all[0]!.finishReason).toBe("length");
    expect(joiners.length).toBe(3);
    for (const s of all.slice(1)) {
      expect(s.generatedTokens).toBeGreaterThan(0);
      expect(s.finishReason).toBe("length");
    }
  }, 240_000);
});
