// GATED: batch failure containment + serial-lane drain (batching-v2-plan
// step 2, D5/D6).
//
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/parity/batch-containment.test.ts
//
// Two behaviors, both mlx-lm semantics:
//   1. CONTAINMENT (D5): one row's onToken throwing evicts THAT row (its
//      submit promise rejects) and the sibling rows keep decoding to their own
//      finish — the failure domain is the row, not the batch (mlx-lm `remove`,
//      server.py:913-919).
//   2. DRAIN (D6): while exclusive foreground work waits on the gateway, the
//      scheduler stops admitting new rows, finishes the running ones, and
//      releases the GPU lock so the exclusive job runs — then admission
//      resumes (mlx-lm drain_batch). Without this, a sustained stream of
//      batchable requests starves the exclusive worker FOREVER, so the test keeps
//      the batch saturated (a fresh batchable submit whenever one finishes)
//      and asserts exclusive work still completes, and that batchable
//      traffic completes after it (kick/resume).
//
// Uses CPM (full-attention, 1B — the cheap batching model). Numerics are
// gated elsewhere (tests/batch-scheduler.test.ts KL + goldens); this gates
// failure routing and lock fairness, so greedy short rows are enough.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const CPM_BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveCpm = existsSync(`${CPM_BASE}/config.json`);

const PROMPTS = [
  [1, 100, 200, 300, 400, 500, 600],
  [1, 150, 250, 350, 450],
  [1, 130, 230, 330, 430, 530],
];

describe.skipIf(!optIn || !haveCpm)("batch containment + drain (CPM)", async () => {
  if (!optIn || !haveCpm) return;
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { createModel } = await import("../../src/model/factory");
  const ops = await import("../../src/mlx/ops");
  const { BatchScheduler } = await import("../../src/serve/batch-scheduler");
  const { GenerationGateway } = await import("../../src/serve/generation-gateway");

  const config = await loadModelConfig(CPM_BASE);
  const weights = await Weights.open(CPM_BASE);
  const model = createModel(weights, config);

  test.each([[0, 1], [1, 1], [1, 3]])("row %i callback failure at token %i leaves siblings running", async (failedRow, throwAt) => {
    const sched = new BatchScheduler(model, { maxBatch: 4 });
    const MAX = 6;
    const boom = new Error("SSE controller gone");
    const subs = PROMPTS.map((p, i) => {
      const got: number[] = [];
      const stats = sched.submit({
        promptIds: p, maxTokens: MAX, eosTokenIds: [],
        sample: (l) => ops.argmaxAxis(l, -1),
        onToken: (t) => {
          if (i === failedRow && got.length === throwAt - 1) throw boom;
          got.push(t);
        },
      });
      return { got, stats };
    });
    try {
      await expect(subs[failedRow]!.stats).rejects.toBe(boom);
      for (const [row, sub] of subs.entries()) {
        if (row === failedRow) continue;
        const stats = await sub.stats;
        expect(stats.generatedTokens).toBe(MAX);
        expect(stats.finishReason).toBe("length");
        expect(sub.got).toHaveLength(MAX);
      }
      expect(subs[failedRow]!.got).toHaveLength(throwAt - 1);
    } finally { await sched.close(); }
  }, 240_000);

  test.each(["length", "eos", "callback"] as const)("initial-token %s termination preserves output counts and cache coverage", async (ending) => {
    const saved: Array<{ tokens: number[]; offsets: number[] }> = [];
    const sched = new BatchScheduler(model, { maxBatch: 2, promptCache: {
      take: () => null,
      put(tokens, caches, _ns, retain) {
        saved.push({ tokens: [...tokens], offsets: caches.map(cache => cache.offset) });
        for (const cache of caches) cache.dispose();
        retain?.();
      },
    } });
    const output: number[] = [];
    try {
      const stats = await sched.submit({
        promptIds: PROMPTS[0]!, maxTokens: ending === "length" ? 1 : 8,
        eosTokenIds: ending === "eos" ? [7] : [],
        sample: () => ops.fromInt32([7], [1]),
        onToken(token) { output.push(token); return ending !== "callback"; },
      });
      expect(output).toEqual(ending === "eos" ? [] : [7]);
      expect(stats.generatedTokens).toBe(1);
      expect(stats.finishReason).toBe(ending === "length" ? "length" : "stop");
      expect(saved).toHaveLength(1);
      expect(saved[0]!.tokens.slice(0, PROMPTS[0]!.length)).toEqual(PROMPTS[0]!);
      expect(saved[0]!.offsets.every(offset => offset === saved[0]!.tokens.length)).toBe(true);
    } finally { await sched.close(); }
  }, 240_000);

  test("exclusive work completes under sustained batchable load, then batching resumes", async () => {
    let exclusiveRan = false;
    const gw = new GenerationGateway(model, 2, async () => {
      throw new Error("ordinary request fell back to serial");
    });
    const batchShape = {
      hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
      hasLogitsExtras: false, wantsLogprobs: false, userSeed: false, kvQuant: false,
      turboQuant: false, hasGrammar: false,
      hasDraft: false,
    };
    const opts = { maxTokens: 4, temperature: 0, eosTokenIds: [] };

    // Saturate the batch: whenever a batchable run finishes, launch another —
    // the running batch NEVER empties on its own, so pre-drain the scheduler
    // would hold the mutex forever and exclusive work would starve.
    let stop = false;
    let batchedDone = 0;
    const inflight = new Set<Promise<void>>();
    const launch = (i: number): void => {
      const p = gw
        .run(
          PROMPTS[i % PROMPTS.length]!, opts, () => {}, undefined,
          batchShape, gw.place(batchShape),
        )
        .then(() => {
          batchedDone++;
          if (!stop) launch(i + 1);
        })
        .finally(() => { inflight.delete(p); });
      inflight.add(p);
    };
    let deadline: ReturnType<typeof setTimeout> | undefined;
    try {
      launch(0);
      launch(1);
      while (batchedDone < 2) await new Promise((r) => setTimeout(r, 20));
      // Exercise exclusive coordination directly. A seed is ordinary batch
      // sampling now, so it must not be used to force a serial request.
      const exclusive = gw.runExclusive(async () => { exclusiveRan = true; });
      const done = await Promise.race([
        exclusive.then(() => "exclusive" as const),
        new Promise<"starved">((resolve) => { deadline = setTimeout(() => resolve("starved"), 120_000); }),
      ]);
      expect(done).toBe("exclusive");
      expect(exclusiveRan).toBe(true);
      const before = batchedDone;
      const resumed = await gw.run(PROMPTS[1]!, opts, () => {}, undefined,
        batchShape, gw.place(batchShape));
      expect(resumed.generatedTokens).toBeGreaterThan(0);
      expect(batchedDone).toBeGreaterThanOrEqual(before);
    } finally {
      clearTimeout(deadline);
      stop = true;
      await Promise.allSettled([...inflight]);
      await gw.close();
    }
  }, 240_000);
});
