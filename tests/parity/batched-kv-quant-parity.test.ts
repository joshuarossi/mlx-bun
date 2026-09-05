// Batched MIXED-precision quantized KV — Phase 3.1 gates (the composition
// rule: a composition inherits its scheme's oracle, so batched mixed-KV
// anchors to the L2/optiq golden per row).
//
//   Gate 1 (bit-exact): ONE row through the REAL BatchScheduler, teacher-
//     forced down the cpm5 mixed golden — per-step logits (0..3) must be
//     IDENTICAL (maxDiff 0) to the optiq-composition golden: the B=1
//     unpadded fast path + serial-boundary solo conversion dispatch the
//     same graph as the serial `--kv-quant config` path the golden
//     verifies. Since the prefill tail-split fix (2026-07-07) BOTH sides
//     compute step 0 from an L=1 forward of the last prompt token on
//     converted caches (the oracle serve-loop convention, mlx-lm
//     generate.py:430-453), so step 0 is a strict compare too — the old
//     GEMV-vs-GEMM argmax anchor is retired.
//   Gate 2 (B=2 dynamic join, teacher-forced): two rows joining
//     mid-flight, both forced down their solo trajectories. The UNPADDED
//     row must be BIT-EXACT vs its solo serial-quantized run (it is — the
//     wrapper adds nothing for pad-0 rows; same "CPM bonus" as the bf16
//     suite). The PADDED row is KL-gated at the quantized calibration:
//     the same harness in pure bf16 shows KL to ~9e-3 on the padded row
//     (the pre-existing batched-attention reduction-order noise the bf16
//     suite calibrated at 1e-2); quantization amplifies it via grid
//     snapping of decode-written K/V. The amplitude is a THRESHOLD effect
//     and strongly JOIN-STEP dependent (bin flips compound): measured
//     2026-07-05 (batched-quant-kl-profile.ts JOIN_AT=K, main and 3.2
//     identical, extend vs re-merge byte-identical): K=5→4.5e-2,
//     K=6→3.5e-2, K=7→1.5e-1, K=8→1.3e-1; bf16 stays ≤9e-3 at every K.
//     The join is therefore PINNED (JOIN_STEP below) so the gate is
//     deterministic, with the bar calibrated for that geometry. Padded-row
//     KL is a sanity envelope, not the correctness contract — that is the
//     unpadded row's bit-exactness plus the model-free byte-identity of
//     the triple surgery (tests/batched-quant.test.ts).
//
// Model-gated (loads cpm5) behind the batch-decode opt-in, house style:
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batched-kv-quant-parity.test.ts
// The model-free triple-surgery mechanics live in tests/batched-quant.test.ts
// (always on).

import { describe, expect, test } from "bun:test";
import type { MlxArray } from "../../src/mlx/array";
import { goldenAt } from "../support/goldens";
import { SNAPSHOT, SNAPSHOT_MINICPM5 } from "../support/paths";
import { existsSync } from "node:fs";
import { createHash } from "node:crypto";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const haveCpm = existsSync(`${SNAPSHOT_MINICPM5}/config.json`);
const haveGemma = existsSync(`${SNAPSHOT}/kv_config.json`);
const goldenFile = goldenAt("mixed-kv-cpm.json");
const haveGolden = await goldenFile.exists();
const MIN_PREFIX = 24; // of 48 — the standing knife-edge allowance

describe.skipIf(!optIn || !haveCpm || !haveGolden)("batched mixed-KV parity (cpm5)", async () => {
  if (!optIn || !haveCpm || !haveGolden) return;
  const golden = (await goldenFile.json()) as {
    prompt_ids: number[]; mixed: number[]; logit_steps: number; logit_sha256: string[];
  };

  const { loadModelConfig } = await import("../../src/config");
  const { resolveKvScheme } = await import("../../src/kv-scheme");
  const { Weights } = await import("../../src/weights");
  const { createModel } = await import("../../src/model/factory");
  const { BatchScheduler } = await import("../../src/serve/batch-scheduler");
  const ops = await import("../../src/mlx/ops");
  const { clearCache } = await import("../../src/mlx/ffi");

  const config = await loadModelConfig(SNAPSHOT_MINICPM5);
  const kvScheme = resolveKvScheme({ override: "config", config: config.kvQuant });
  const weights = await Weights.open(SNAPSHOT_MINICPM5);
  const model = createModel(weights, config);
  expect(config.kvQuant?.length).toBe(24); // all-full-attention config = P1 batchable

  test("gate 1 — B=1 row through the scheduler: per-step logits BIT-EXACT vs the optiq golden", async () => {
    const sched = new BatchScheduler(model, { maxBatch: 2, kvScheme });
    const captured: Float32Array[] = [];
    let step = 0;
    await sched.submit({
      promptIds: golden.prompt_ids,
      maxTokens: 48,
      eosTokenIds: [],
      plainGreedy: false, // per-row sampler runs every step (we teacher-force)
      sample: (logits1V: MlxArray) => {
        if (step < golden.logit_steps) captured.push(logits1V.toFloat32());
        const tok = golden.mixed[step]!; // teacher-force the golden trajectory
        step++;
        return ops.fromInt32([tok], [1]);
      },
      onToken: () => true,
    });
    expect(step).toBe(48);
    // Steps 0..3 BIT-EXACT vs the oracle golden — since the prefill
    // tail-split fix (2026-07-07), step 0 is an L=1 forward on both sides
    // (the golden regen mirrors the oracle serve loop: prefill ids[:-1] →
    // convert → L=1 step), so the old GEMV-vs-GEMM argmax anchor is now a
    // strict compare.
    for (let s = 0; s < golden.logit_steps; s++) {
      const bytes = await goldenAt(`mixedkv-cpm-logits-step${s}.bin`).arrayBuffer();
      expect(createHash("sha256").update(new Uint8Array(bytes)).digest("hex"))
        .toBe(golden.logit_sha256[s]!);
      const ref = new Float32Array(bytes);
      let maxDiff = 0;
      for (let i = 0; i < ref.length; i++)
        maxDiff = Math.max(maxDiff, Math.abs(captured[s]![i]! - ref[i]!));
      expect(maxDiff).toBe(0); // the composition inherits the scheme's oracle
    }
    clearCache();
  }, 240_000);

  test("gate 2 — B=2 dynamic join, teacher-forced: per-row KL vs solo serial-quantized within the calibrated envelope", async () => {
    // Quantized calibration at JOIN_STEP (see header). Re-measured
    // 2026-07-07 after the prefill tail-split re-anchor: the padded row's
    // grid-snap geometry shifted (the last prompt token's KV is now
    // quantized-written by the L=1 step) — deterministic 1.21e-1 at K=6,
    // the same threshold-effect amplitude the 2026-07-05 K-sweep already
    // measured at adjacent joins (K=7→1.5e-1, K=8→1.3e-1). Bar carries
    // the usual margin; the correctness contract stays the UNPADDED row's
    // bit-exactness (a real fault shifts BOTH rows to O(10)).
    const KL_TOL_PADDED = 2e-1;
    const JOIN_STEP = 6; // pinned join geometry — the bar is calibrated HERE
    const STEPS = 32;
    // Two prompts, different lengths (the joiner is shorter → left-padded).
    const promptA = golden.prompt_ids;
    const promptB = golden.prompt_ids.slice(0, Math.floor(golden.prompt_ids.length / 2));

    /** Solo serial-quantized run: greedy trajectory + per-step logits.
     *  Tail-split composition (2026-07-07, matches generate.ts and the
     *  oracle serve loop): prefill ids[:-1] bf16 → convert per kv_config →
     *  step-0 from an L=1 forward of the last prompt token (KV written
     *  into the quantized caches). */
    const solo = async (ids: number[]): Promise<{ toks: number[]; logits: Float32Array[] }> => {
      const { maybeQuantizeKv } = await import("../../src/generate");
      const { lastPositionLogits, argmaxLastPosition } = await import("../../src/model/gemma4");
      const kvOpts = { kvConfig: config.kvQuant!, quantizedKvStart: 0 };
      const cache = model.makeCache();
      const toks: number[] = [];
      const logits: Float32Array[] = [];
      const head = model.forward(ids.slice(0, -1), cache);
      head.dispose();
      maybeQuantizeKv(cache, kvOpts);
      let l = model.forward([ids[ids.length - 1]!], cache);
      logits.push(lastPositionLogits(l));
      toks.push(argmaxLastPosition(l));
      l.dispose();
      for (let s = 1; s < STEPS; s++) {
        l = model.forward([toks[s - 1]!], cache);
        logits.push(lastPositionLogits(l));
        toks.push(argmaxLastPosition(l));
        l.dispose();
      }
      for (const c of cache) c.dispose();
      clearCache();
      return { toks, logits };
    };
    const refA = await solo(promptA);
    const refB = await solo(promptB);

    /** log-stable KL(p||q) from raw logit vectors. */
    const klDiv = (x: Float32Array, y: Float32Array): number => {
      let mx = -Infinity, my = -Infinity;
      for (let i = 0; i < x.length; i++) { if (x[i]! > mx) mx = x[i]!; if (y[i]! > my) my = y[i]!; }
      let sx = 0, sy = 0;
      for (let i = 0; i < x.length; i++) { sx += Math.exp(x[i]! - mx); sy += Math.exp(y[i]! - my); }
      const lsx = Math.log(sx), lsy = Math.log(sy);
      let kl = 0;
      for (let i = 0; i < x.length; i++) {
        const lp = x[i]! - mx - lsx;
        const p = Math.exp(lp);
        if (p > 0) kl += p * (lp - (y[i]! - my - lsy));
      }
      return kl;
    };

    const sched = new BatchScheduler(model, { maxBatch: 2, kvScheme });
    const mkForced = (ids: number[], forced: number[], sink: Float32Array[]) => {
      let step = 0;
      return {
        promptIds: ids, maxTokens: STEPS, eosTokenIds: [], plainGreedy: false,
        sample: (lp: MlxArray) => {
          sink.push(lp.toFloat32());
          return ops.fromInt32([forced[step++]!], [1]);
        },
        onToken: () => true,
      };
    };
    const gotA: Float32Array[] = [];
    const gotB: Float32Array[] = [];
    const a = sched.submit(mkForced(promptA, refA.toks, gotA));
    // B joins while A decodes (dynamic join through the extend path) — at
    // the PINNED step, so the grid-snap noise geometry is deterministic.
    while (gotA.length < JOIN_STEP) await new Promise((r) => setTimeout(r, 2));
    const b = sched.submit(mkForced(promptB, refB.toks, gotB));
    await Promise.all([a, b]);
    clearCache();

    expect(gotA.length).toBe(STEPS);
    expect(gotB.length).toBe(STEPS);
    // Unpadded row: BIT-EXACT at EVERY step incl. 0 — with the shared
    // tail-split convention both sides compute step-0 from the same L=1
    // forward on identically composed caches (the old GEMV/GEMM step-0
    // caveat is gone).
    for (let s = 0; s < STEPS; s++) {
      let maxAbs = 0;
      const ref = refA.logits[s]!, got = gotA[s]!;
      for (let i = 0; i < ref.length; i++) maxAbs = Math.max(maxAbs, Math.abs(ref[i]! - got[i]!));
      expect(maxAbs).toBe(0);
    }
    // Padded row: calibrated KL bar.
    let maxKl = 0;
    for (let s = 1; s < STEPS; s++) maxKl = Math.max(maxKl, klDiv(refB.logits[s]!, gotB[s]!));
    console.log(`padded row: max step KL ${maxKl.toExponential(2)} (bar ${KL_TOL_PADDED})`);
    expect(maxKl).toBeLessThanOrEqual(KL_TOL_PADDED);
  }, 480_000);
});

// ---- Milestone 2: GEMMA — kv_config naming ROTATING layers batches -------
//
// The 12B kv_config covers all 48 layers (mixed 4/8), most of them sliding-
// window, so this exercises BatchedRotatingQuantCache end-to-end through the
// real scheduler: solo prefill → #quantizeSolo (RotatingKVCache→
// RotatingQuantizedKVCache at the serial boundaries) → adopt (row 1) →
// quantized rot merge (row 2 joins, pinned step) → twin decode. The ring
// bytes are gated byte-identical to the serial oracle model-free
// (tests/batched-rotating-quant.test.ts); this gate covers the ASSEMBLED
// numerics: teacher-forced per-row logits vs the solo serial-quantized run.
//
// KL BOUNDS (measured 2026-07-05, apple-m1-max, join pinned at 6, after the
// step-stable-rope fix): row A (unpadded) is KL-0 at every step (<1e-6 —
// the twin decodes through the generated fast path, per-row rope + array
// mask); row B (padded) peaks at ~4e-3 late (grid-snap quant noise). Bars
// carry margin for join-geometry drift: A 1e-3, B 1e-1. A real fault
// (the generated files' post-update ropeOffsetArr re-read this gate was
// built on) shifts BOTH rows to O(10).
describe.skipIf(!optIn || !haveGemma)("batched mixed-KV parity (gemma 12B, rotating-quant)", () => {
  test("B=2 dynamic join, teacher-forced: per-row KL vs solo serial-quantized", async () => {
    const KL_TOL_A = 1e-3; // unpadded row: measured <1e-6
    const KL_TOL_B = 1e-1; // padded row: measured ~4e-3 peak
    const JOIN_STEP = 6;
    const STEPS = 20;
    const { loadModelConfig } = await import("../../src/config");
    const { resolveKvScheme } = await import("../../src/kv-scheme");
    const { Weights } = await import("../../src/weights");
    const { createModel } = await import("../../src/model/factory");
    const { maybeQuantizeKv } = await import("../../src/generate");
    const { lastPositionLogits, argmaxLastPosition } = await import("../../src/model/gemma4");
    const { BatchScheduler } = await import("../../src/serve/batch-scheduler");
    const ops = await import("../../src/mlx/ops");
    const { clearCache } = await import("../../src/mlx/ffi");

    const config = await loadModelConfig(SNAPSHOT);
    const kvScheme = resolveKvScheme({ override: "config", config: config.kvQuant });
    expect(config.kvQuant?.length).toBeGreaterThan(0);
    const weights = await Weights.open(SNAPSHOT);
    const model = createModel(weights, config);
    try {
      const promptA = [2, 100, 200, 300, 400, 500, 600, 700];
      const promptB = [2, 150, 250, 350, 450];

      // Tail-split composition (2026-07-07): prefill ids[:-1] → convert →
      // L=1 step-0 (see the cpm5 gate 2 solo above).
      const solo = (ids: number[]): { toks: number[]; logits: Float32Array[] } => {
        const kvOpts = { kvConfig: config.kvQuant!, quantizedKvStart: 0 };
        const cache = model.makeCache();
        const toks: number[] = [];
        const logits: Float32Array[] = [];
        const head = model.forward(ids.slice(0, -1), cache);
        head.dispose();
        maybeQuantizeKv(cache, kvOpts);
        let l = model.forward([ids[ids.length - 1]!], cache);
        logits.push(lastPositionLogits(l));
        toks.push(argmaxLastPosition(l));
        l.dispose();
        for (let s = 1; s < STEPS; s++) {
          l = model.forward([toks[s - 1]!], cache);
          logits.push(lastPositionLogits(l));
          toks.push(argmaxLastPosition(l));
          l.dispose();
        }
        for (const c of cache) c.dispose();
        clearCache();
        return { toks, logits };
      };
      const refA = solo(promptA);
      const refB = solo(promptB);

      const klDiv = (x: Float32Array, y: Float32Array): number => {
        let mx = -Infinity, my = -Infinity;
        for (let i = 0; i < x.length; i++) { if (x[i]! > mx) mx = x[i]!; if (y[i]! > my) my = y[i]!; }
        let sx = 0, sy = 0;
        for (let i = 0; i < x.length; i++) { sx += Math.exp(x[i]! - mx); sy += Math.exp(y[i]! - my); }
        const lsx = Math.log(sx), lsy = Math.log(sy);
        let kl = 0;
        for (let i = 0; i < x.length; i++) {
          const lp = x[i]! - mx - lsx;
          const pp = Math.exp(lp);
          if (pp > 0) kl += pp * (lp - (y[i]! - my - lsy));
        }
        return kl;
      };

      const sched = new BatchScheduler(model, { maxBatch: 2, kvScheme });
      const mkForced = (ids: number[], forced: number[], sink: Float32Array[]) => {
        let step = 0;
        return {
          promptIds: ids, maxTokens: STEPS, eosTokenIds: [], plainGreedy: false,
          sample: (lp: MlxArray) => {
            sink.push(lp.toFloat32());
            return ops.fromInt32([forced[step++]!], [1]);
          },
          onToken: () => true,
        };
      };
      const gotA: Float32Array[] = [];
      const gotB: Float32Array[] = [];
      const a = sched.submit(mkForced(promptA, refA.toks, gotA));
      while (gotA.length < JOIN_STEP) await new Promise((r) => setTimeout(r, 2));
      const b = sched.submit(mkForced(promptB, refB.toks, gotB));
      await Promise.all([a, b]);
      clearCache();

      expect(gotA.length).toBe(STEPS);
      expect(gotB.length).toBe(STEPS);
      let maxA = 0, maxB = 0;
      for (let s = 1; s < STEPS; s++) {
        maxA = Math.max(maxA, klDiv(refA.logits[s]!, gotA[s]!));
        maxB = Math.max(maxB, klDiv(refB.logits[s]!, gotB[s]!));
      }
      console.log(`gemma rot-quant B=2: row A maxKL=${maxA.toExponential(2)} row B maxKL=${maxB.toExponential(2)} (bars ${KL_TOL_A}/${KL_TOL_B})`);
      expect(maxA).toBeLessThan(KL_TOL_A);
      expect(maxB).toBeLessThan(KL_TOL_B);
    } finally {
      weights.dispose();
    }
  }, 480_000);
});
