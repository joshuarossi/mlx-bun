// GATED: aggregate KV-budget admission for the batch scheduler
// (batching-perf-path P3 slice, executed as integration-plan Phase D).
//
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batch-kv-budget.test.ts
//
// The contract: with `kvBudgetBytes` set, the scheduler never has rows
// admitted whose PROJECTED aggregate KV (prompt + max_tokens each,
// window-capped) exceeds the budget — over-budget joiners QUEUE (FIFO)
// until rows evict, and a request that can't fit even alone is REJECTED
// (never a deadlock, never an uncatchable GPU OOM).

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const CPM_BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveCpm = existsSync(`${CPM_BASE}/config.json`);

describe.skipIf(!optIn || !haveCpm)("batch scheduler — KV-budget admission (CPM)", () => {
  test("over-budget joiner queues; all complete; oversized-alone rejects", async () => {
    const { loadModelConfig } = await import("../../src/config");
    const { Weights } = await import("../../src/weights");
    const { createModel } = await import("../../src/model/factory");
    const { BatchScheduler } = await import("../../src/serve/batch-scheduler");
    const { kvBytesAt } = await import("../../src/fit");
    const ops = await import("../../src/mlx/ops");

    const config = await loadModelConfig(CPM_BASE);
    const weights = await Weights.open(CPM_BASE);
    const model = createModel(weights, config);
    try {
      const PROMPT = [1, 100, 200, 300, 400];
      const MAXTOK = 8;
      const rowKv = kvBytesAt(config, PROMPT.length + MAXTOK);
      // budget fits exactly TWO rows (plus slack well under a third)
      const sched = new BatchScheduler(model, {
        maxBatch: 4,
        kvBudgetBytes: rowKv * 2 + rowKv / 2,
      });

      // Track the maximum concurrently-admitted projection the scheduler
      // ever reports — the invariant under test.
      let maxProjected = 0;
      const submit = (promptTail: number) => {
        const got: number[] = [];
        return sched.submit({
          promptIds: [...PROMPT, promptTail],
          maxTokens: MAXTOK,
          eosTokenIds: [],
          sample: (l) => {
            maxProjected = Math.max(maxProjected, sched.projectedKvBytes);
            return ops.argmaxAxis(l, -1);
          },
          onToken: (t) => { got.push(t); },
        }).then((st) => ({ st, got }));
      };

      // three requests, one over the two-row budget — the third must queue
      const [a, b, c] = await Promise.all([submit(11), submit(12), submit(13)]);
      for (const r of [a, b, c]) {
        expect(r.st.generatedTokens).toBe(MAXTOK);
        expect(r.got.length).toBe(MAXTOK);
      }
      const budget = rowKv * 2 + rowKv / 2;
      expect(maxProjected).toBeLessThanOrEqual(budget);
      expect(maxProjected).toBeGreaterThan(0);
      console.log(
        `[kv-budget] rowKv=${(rowKv / 1e6).toFixed(1)}MB budget=${(budget / 1e6).toFixed(1)}MB ` +
          `maxProjected=${(maxProjected / 1e6).toFixed(1)}MB (≤ budget ✓, 3 rows completed)`,
      );

      // oversized-alone: a request whose own projection exceeds the budget
      // rejects with an actionable error instead of deadlocking the queue
      const sched2 = new BatchScheduler(model, {
        maxBatch: 2,
        kvBudgetBytes: Math.floor(rowKv / 2),
      });
      await expect(
        sched2.submit({
          promptIds: PROMPT, maxTokens: MAXTOK, eosTokenIds: [],
          sample: (l) => ops.argmaxAxis(l, -1),
          onToken: () => {},
        }),
      ).rejects.toThrow(/kv budget/);

      // and the queue survives a rejection: a fitting request still runs
      const sched3 = new BatchScheduler(model, {
        maxBatch: 2,
        kvBudgetBytes: rowKv + rowKv / 2,
      });
      const oversized = sched3.submit({
        promptIds: Array.from({ length: 64 }, (_, i) => 1 + i),
        maxTokens: 4096, // projection blows the budget alone
        eosTokenIds: [],
        sample: (l) => ops.argmaxAxis(l, -1),
        onToken: () => {},
      });
      const fine: number[] = [];
      const fineP = sched3.submit({
        promptIds: PROMPT, maxTokens: 4, eosTokenIds: [],
        sample: (l) => ops.argmaxAxis(l, -1),
        onToken: (t) => { fine.push(t); },
      });
      await expect(oversized).rejects.toThrow(/kv budget/);
      const st = await fineP;
      expect(st.generatedTokens).toBe(4);
      expect(fine.length).toBe(4);
    } finally {
      weights.dispose();
    }
  }, 240_000);
});
