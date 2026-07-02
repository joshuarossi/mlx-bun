// GATED: batch failure containment + serial-lane drain (batching-v2-plan
// step 2, D5/D6).
//
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batch-containment.test.ts
//
// Two behaviors, both mlx-lm semantics:
//   1. CONTAINMENT (D5): one row's onToken throwing evicts THAT row (its
//      submit promise rejects) and the sibling rows keep decoding to their own
//      finish — the failure domain is the row, not the batch (mlx-lm `remove`,
//      server.py:913-919).
//   2. DRAIN (D6): while a serial-lane request waits on the gateway, the
//      scheduler stops admitting new rows, finishes the running ones, and
//      releases the GPU lock so the serial request runs — then admission
//      resumes (mlx-lm drain_batch). Without this, a sustained stream of
//      batchable requests starves the serial lane FOREVER, so the test keeps
//      the batch saturated (a fresh batchable submit whenever one finishes)
//      and asserts a serial request still completes, and that batchable
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
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { createModel } = await import("../src/model/factory");
  const ops = await import("../src/mlx/ops");
  const { BatchScheduler } = await import("../src/serve/batch-scheduler");
  const { GenerationGateway } = await import("../src/serve/generation-gateway");
  type GenerateStats = import("../src/generate").GenerateStats;

  const config = await loadModelConfig(CPM_BASE);
  const weights = await Weights.open(CPM_BASE);
  const model = createModel(weights, config);

  test("one row's onToken throwing evicts that row; siblings complete", async () => {
    const sched = new BatchScheduler(model, { maxBatch: 4 });
    const MAX = 6;
    const boom = new Error("SSE controller gone");
    const subs = PROMPTS.map((p, i) => {
      const got: number[] = [];
      const stats = sched.submit({
        promptIds: p,
        maxTokens: MAX,
        eosTokenIds: [], // fixed-length rows: every survivor must reach MAX
        sample: (l) => ops.argmaxAxis(l, -1),
        onToken: (t) => {
          // row 1 blows up on its 3rd token (mid-decode, after the batch formed)
          if (i === 1 && got.length === 2) throw boom;
          got.push(t);
        },
      });
      return { got, stats };
    });

    await expect(subs[1]!.stats).rejects.toBe(boom);
    const [s0, s2] = await Promise.all([subs[0]!.stats, subs[2]!.stats]);
    // Siblings were NOT rejected and ran to their own finish.
    expect(s0.generatedTokens).toBe(MAX);
    expect(s0.finishReason).toBe("length");
    expect(subs[0]!.got.length).toBe(MAX);
    expect(s2.generatedTokens).toBe(MAX);
    expect(s2.finishReason).toBe("length");
    expect(subs[2]!.got.length).toBe(MAX);
    // The failed row emitted exactly the tokens before the throw.
    expect(subs[1]!.got.length).toBe(2);
  }, 240_000);

  test("serial-lane request completes under sustained batchable load (drain), then batching resumes", async () => {
    let serialRan = false;
    const serialStats: GenerateStats = {
      promptTokens: 1, cachedTokens: 0, generatedTokens: 1,
      prefillMs: 0, decodeMs: 0, prefillTps: 0, decodeTps: 0, cacheTokens: [],
    };
    const gw = new GenerationGateway(model, 2, async (_ids, _opts, onToken) => {
      serialRan = true;
      await onToken(42); // no GPU work — the LOCK is what's under test
      return serialStats;
    });
    const batchShape = {
      hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
      hasLogitsExtras: false, wantsLogprobs: false, userSeed: false, kvQuant: false,
    };
    const opts = { maxTokens: 4, temperature: 0, eosTokenIds: [] };

    // Saturate the batch: whenever a batchable run finishes, launch another —
    // the running batch NEVER empties on its own, so pre-drain the scheduler
    // would hold the mutex forever and the serial request would starve.
    let stop = false;
    let batchedDone = 0;
    const inflight = new Set<Promise<void>>();
    const launch = (i: number): void => {
      const p = gw
        .run(PROMPTS[i % PROMPTS.length]!, opts, () => {}, undefined, batchShape)
        .then(() => {
          batchedDone++;
          if (!stop) launch(i + 1);
        })
        .finally(() => { inflight.delete(p); });
      inflight.add(p);
    };
    launch(0);
    launch(1);
    // Let the batch actually form before the serial request queues.
    while (batchedDone < 2) await new Promise((r) => setTimeout(r, 20));

    const serial = gw.run(
      PROMPTS[0]!, opts, () => {}, undefined, { ...batchShape, userSeed: true },
    );
    const done = await Promise.race([
      serial.then(() => "serial" as const),
      new Promise<"starved">((r) => setTimeout(() => r("starved"), 120_000)),
    ]);
    expect(done).toBe("serial"); // drain: the batch paused admission + handed over
    expect(serialRan).toBe(true);

    // Resume: batchable traffic still completes after the serial run (kick()).
    const before = batchedDone;
    const resumed = gw.run(PROMPTS[1]!, opts, () => {}, undefined, batchShape);
    const rs = await resumed;
    expect(rs.generatedTokens).toBeGreaterThan(0);
    expect(batchedDone).toBeGreaterThanOrEqual(before);

    stop = true;
    await Promise.all([...inflight]);
  }, 240_000);
});
