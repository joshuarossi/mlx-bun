// GATED: the continuous-batching scheduler (src/serve/batch-scheduler.ts).
//
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batch-scheduler.test.ts
//
// The batched FORWARD and the dynamic-B cache ops are already oracle-verified
// (tests/batched-decode-parity.test.ts, tests/batched-rotating.test.ts). This
// gates the ORCHESTRATION on top — admission (solo prefill + merge into a
// running batch, per-layer by attention type), the step loop, per-row sampling
// + token accounting, and eviction (filter).
//
// METHODOLOGY — teacher-forced, NOT free-running greedy. Batched decode is not
// bit-exact vs solo (left-padding shifts each row's attention reduction order),
// so comparing free-running greedy *trajectories* measures chaos: one bf16
// argmax flip cascades (see memory: teacher-forced-gating-for-non-bitexact-paths).
// Instead we FORCE each row to follow its solo-greedy trajectory and compare the
// scheduler's per-row *logits* to the solo teacher-forced logits via KL. Forcing
// makes eviction/join timing deterministic; KL tolerates benign batch noise but
// still catches a real bug (wrong leftPad after evict/join, mis-routed tokens)
// as a logit shift. Plus a routing assertion: each row's emitted tokens, counts,
// and finish reason are exactly what the schedule dictates.
//
// Two models: CPM (all full-attention) and Gemma 12B (interleaved sliding +
// full — the mixed-layer path through the scheduler). Short prompts → the Gemma
// sliding window doesn't wrap here; the ring-wrap math is gated bit-exact vs
// mlx-lm model-free in tests/batched-rotating.test.ts.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const CPM_BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveCpm = existsSync(`${CPM_BASE}/config.json`);
const haveGemma = await snapshotAvailable();

const delay = (ms: number) => new Promise<void>((r) => setTimeout(r, ms));

// KL(softmax(p) || softmax(q)) in nats — the "same distribution?" metric.
const klDiv = (p: Float32Array, q: Float32Array): number => {
  const mp = Math.max(...p), mq = Math.max(...q);
  let zp = 0, zq = 0;
  for (let i = 0; i < p.length; i++) { zp += Math.exp(p[i]! - mp); zq += Math.exp(q[i]! - mq); }
  const lzp = Math.log(zp), lzq = Math.log(zq);
  let kl = 0;
  for (let i = 0; i < p.length; i++) {
    const pp = Math.exp(p[i]! - mp - lzp);
    if (pp > 0) kl += pp * ((p[i]! - mp - lzp) - (q[i]! - mq - lzq));
  }
  return kl;
};
const KL_TOL = 1e-2; // benign batch noise ~5e-3; a real shift is ~2e-1

const PROMPTS = [
  [1, 100, 200, 300, 400, 500, 600], // len 7
  [1, 150, 250, 350, 450], // len 5
  [1, 130, 230, 330, 430, 530], // len 6
];
const STEPS = 11;
const MAXTOK = [5, 8, 11]; // staggered → rows evict at different steps

/** Teacher-forced scheduler parity for one model: each of three rows is forced
 *  along its solo-greedy trajectory; the scheduler's per-row logits must match
 *  solo (KL); emitted tokens/counts/finish are exactly the schedule. Run twice —
 *  all-at-once (staggered eviction 3→2→1→0) and a mid-stream join. */
async function schedulerParity(base: string, label: string): Promise<void> {
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { createModel } = await import("../src/model/factory");
  const { MlxArray } = await import("../src/mlx/array");
  const { clearCache } = await import("../src/mlx/ffi");
  const { BatchScheduler } = await import("../src/serve/batch-scheduler");

  const config = await loadModelConfig(base);
  const weights = await Weights.open(base);
  const model = createModel(weights, config);
  const eos = model.config.eosTokenIds;

  const argmaxF = (a: Float32Array): number => {
    let bi = 0;
    for (let i = 1; i < a.length; i++) if (a[i]! > a[bi]!) bi = i;
    return bi;
  };
  const lastRowLogits = (lg: InstanceType<typeof MlxArray>): Float32Array => {
    const [, L, V] = lg.shape as [number, number, number];
    const s = lg.slice([0, L - 1, 0], [1, L, V]);
    const f = s.toFloat32();
    s.dispose();
    return f;
  };
  const soloGreedy = (prompt: number[], steps: number): { tokens: number[]; logits: Float32Array[] } => {
    const cache = model.makeCache();
    try {
      const ids = MlxArray.fromInt32(Int32Array.from(prompt), [1, prompt.length]);
      const h = model.forwardHidden(ids, cache);
      ids.dispose();
      const lg = model.logitsFromHidden(h);
      h.dispose();
      let L = lastRowLogits(lg);
      lg.dispose();
      const logits = [L];
      const tokens = [argmaxF(L)];
      clearCache();
      for (let s = 1; s < steps; s++) {
        const tid = MlxArray.fromInt32(Int32Array.from([tokens[s - 1]!]), [1, 1]);
        const h2 = model.forwardHidden(tid, cache);
        tid.dispose();
        const lg2 = model.logitsFromHidden(h2);
        h2.dispose();
        L = lastRowLogits(lg2);
        lg2.dispose();
        logits.push(L);
        tokens.push(argmaxF(L));
        clearCache();
      }
      return { tokens, logits };
    } finally {
      for (const c of cache) c.dispose();
    }
  };

  try {
    const ref = PROMPTS.map((p) => soloGreedy(p, STEPS));
    for (let i = 0; i < PROMPTS.length; i++)
      for (let s = 0; s < MAXTOK[i]!; s++)
        if (eos.includes(ref[i]!.tokens[s]!))
          throw new Error(`[${label}] row ${i} EOSes at step ${s} within max_tokens — pick a longer prompt`);

    const submitForced = (sched: InstanceType<typeof BatchScheduler>, i: number, maxTokens: number) => {
      const captured: Float32Array[] = [];
      const got: number[] = [];
      const stats = sched.submit({
        promptIds: PROMPTS[i]!,
        maxTokens,
        eosTokenIds: eos,
        sample: (l, step) => {
          captured[step] = l.toFloat32();
          return MlxArray.fromInt32(Int32Array.from([ref[i]!.tokens[step]!]), [1]);
        },
        onToken: (t) => { got.push(t); },
      });
      return { captured, got, stats };
    };
    const checkRow = (i: number, maxTokens: number, captured: Float32Array[], got: number[], st: { generatedTokens: number; finishReason: string }) => {
      expect(got).toEqual(ref[i]!.tokens.slice(0, maxTokens));
      expect(st.generatedTokens).toBe(maxTokens);
      expect(st.finishReason).toBe("length");
      let maxKl = 0;
      for (let s = 0; s < maxTokens; s++) maxKl = Math.max(maxKl, klDiv(ref[i]!.logits[s]!, captured[s]!));
      console.log(`[sched ${label} row ${i}] maxKL=${maxKl.toExponential(2)} (steps=${maxTokens})`);
      expect(maxKl).toBeLessThan(KL_TOL);
    };

    // Scenario 1: all three at once → staggered eviction.
    const sched1 = new BatchScheduler(model, { maxBatch: 4 });
    const s1 = PROMPTS.map((_, i) => submitForced(sched1, i, MAXTOK[i]!));
    const st1 = await Promise.all(s1.map((s) => s.stats));
    for (let i = 0; i < PROMPTS.length; i++) checkRow(i, MAXTOK[i]!, s1[i]!.captured, s1[i]!.got, st1[i]!);

    // Scenario 2: row 2 JOINS mid-stream (after 0,1 have stepped).
    const sched2 = new BatchScheduler(model, { maxBatch: 4 });
    const a = submitForced(sched2, 0, MAXTOK[0]!);
    const b = submitForced(sched2, 1, MAXTOK[1]!);
    await delay(40);
    const c = submitForced(sched2, 2, MAXTOK[2]!);
    const st2 = await Promise.all([a.stats, b.stats, c.stats]);
    checkRow(0, MAXTOK[0]!, a.captured, a.got, st2[0]!);
    checkRow(1, MAXTOK[1]!, b.captured, b.got, st2[1]!);
    checkRow(2, MAXTOK[2]!, c.captured, c.got, st2[2]!);
  } finally {
    weights.dispose();
  }
}

describe.skipIf(!optIn || !haveCpm)("batch scheduler — CPM L1 (full-attention)", () => {
  test("teacher-forced: scheduled per-row logits == solo (evict + join)", async () => {
    await schedulerParity(CPM_BASE, "CPM");
  }, 240_000);
});

// Gemma 12B (interleaved sliding + full): the mixed-layer scheduler path. The
// teacher-forced-vs-solo gate above is WRONG for Gemma — batched Gemma diverges
// from SOLO Gemma by ~0.26 KL (large headDim → left-pad reduction-order), while
// matching mlx-lm B=N bit-exactly (realBatchedGreedy). So gate the scheduler
// directly against the mlx-lm B=2 greedy golden: drive it greedy (eos disabled
// to match the golden's fixed-length run) with STAGGERED max_tokens so row 0
// evicts mid-stream, and assert each row's emitted trajectory matches the golden
// (truncated). Exercises per-layer merge (admission) + eviction (rot filter) +
// the mixed full/sliding forward — bit-exact vs mlx-lm. (Ring-wrap is gated
// model-free in tests/batched-rotating.test.ts; this is short-context.)
describe.skipIf(!optIn || !haveGemma)("batch scheduler — Gemma 12B vs mlx-lm B=2 golden", () => {
  test("greedy scheduled trajectories == mlx-lm B=2 (merge + staggered evict)", async () => {
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { MlxArray } = await import("../src/mlx/array");
    const ops = await import("../src/mlx/ops");
    const { BatchScheduler } = await import("../src/serve/batch-scheduler");

    const golden = await Bun.file(`${import.meta.dir}/fixtures/batched-golden-gemma12b.json`).json();
    const prompts = golden.prompts as number[][];
    const steps = golden.steps as number;
    const maxTok = [steps - 3, steps]; // row 0 evicts 3 steps before row 1

    const config = await loadModelConfig(SNAPSHOT);
    const weights = await Weights.open(SNAPSHOT);
    const model = createModel(weights, config);
    try {
      const sched = new BatchScheduler(model, { maxBatch: 4 });
      const subs = prompts.map((p, i) => {
        const got: number[] = [];
        const stats = sched.submit({
          promptIds: p,
          maxTokens: maxTok[i]!,
          eosTokenIds: [], // match the golden's fixed-length (no EOS stop)
          sample: (l) => ops.argmaxAxis(l, -1),
          onToken: (t) => { got.push(t); },
        });
        return { got, stats };
      });
      await Promise.all(subs.map((s) => s.stats));
      for (let i = 0; i < prompts.length; i++) {
        const want = (golden.trajectories[i] as number[]).slice(0, maxTok[i]!);
        console.log(`[sched Gemma row ${i}] got=${JSON.stringify(subs[i]!.got)}`);
        console.log(`[sched Gemma row ${i}] want=${JSON.stringify(want)}`);
        expect(subs[i]!.got).toEqual(want);
      }
    } finally {
      weights.dispose();
    }
  }, 300_000);
});
