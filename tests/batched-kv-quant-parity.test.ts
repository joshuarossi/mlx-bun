// Batched MIXED-precision quantized KV — Phase 3.1 gates (the composition
// rule: a composition inherits its scheme's oracle, so batched mixed-KV
// anchors to the L2/optiq golden per row).
//
//   Gate 1 (bit-exact): ONE row through the REAL BatchScheduler, teacher-
//     forced down the cpm5 mixed golden — DECODE-step logits (1..3) must be
//     IDENTICAL (maxDiff 0) to the optiq-composition golden: the B=1
//     unpadded fast path + serial-boundary solo conversion dispatch the
//     same graph as the serial `--kv-quant config` path the golden
//     verifies. Step 0 asserts the argmax only: both engines' prefill
//     slices hLast then computes [1,V] logits (GEMV), while the golden
//     takes the last row of the full [L,V] matmul (GEMM) — a known bf16
//     tiling convention difference shared by the SERIAL engine (verified:
//     serial via model.forward matches the golden bit-exact incl. step 0;
//     scripts/experiments/mixed-cpm-serial-check.ts), not a batching
//     artifact.
//   Gate 2 (B=2 dynamic join, teacher-forced): two rows joining
//     mid-flight, both forced down their solo trajectories. The UNPADDED
//     row must be BIT-EXACT vs its solo serial-quantized run (it is — the
//     wrapper adds nothing for pad-0 rows; same "CPM bonus" as the bf16
//     suite). The PADDED row is KL-gated at the quantized calibration:
//     the same harness in pure bf16 shows KL to ~9e-3 on the padded row
//     (the pre-existing batched-attention reduction-order noise the bf16
//     suite calibrated at 1e-2); quantization amplifies it via grid
//     snapping of decode-written K/V — measured max 3.5e-2 on 2026-07-05
//     (scripts/experiments/batched-quant-kl-profile.ts) → bar 5e-2.
//
// Model-gated (loads cpm5) behind the batch-decode opt-in, house style:
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batched-kv-quant-parity.test.ts
// The model-free triple-surgery mechanics live in tests/batched-quant.test.ts
// (always on).

import { describe, expect, test } from "bun:test";
import type { MlxArray } from "../src/mlx/array";
import { goldenAt } from "./goldens";
import { SNAPSHOT_MINICPM5 } from "./paths";
import { existsSync } from "node:fs";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const haveCpm = existsSync(`${SNAPSHOT_MINICPM5}/config.json`);
const goldenFile = goldenAt("mixed-kv-cpm.json");
const haveGolden = await goldenFile.exists();
const MIN_PREFIX = 24; // of 48 — the standing knife-edge allowance

describe.skipIf(!optIn || !haveCpm || !haveGolden)("batched mixed-KV parity (cpm5)", async () => {
  if (!optIn || !haveCpm || !haveGolden) return;
  const golden = (await goldenFile.json()) as {
    prompt_ids: number[]; mixed: number[]; logit_steps: number;
  };

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { createModel } = await import("../src/model/factory");
  const { generate } = await import("../src/generate");
  const { BatchScheduler } = await import("../src/serve/batch-scheduler");
  const { toLogprobs } = await import("../src/sampler");
  const ops = await import("../src/mlx/ops");
  const { clearCache } = await import("../src/mlx/ffi");

  const config = await loadModelConfig(SNAPSHOT_MINICPM5);
  const weights = await Weights.open(SNAPSHOT_MINICPM5);
  const model = createModel(weights, config);
  expect(config.kvQuant?.length).toBe(24); // all-full-attention config = P1 batchable

  const greedySample = (lp: MlxArray): MlxArray => {
    const l = toLogprobs(lp);
    const t = ops.argmaxAxis(l, -1);
    l.dispose();
    return t;
  };

  test("gate 1 — B=1 row through the scheduler: per-step logits BIT-EXACT vs the optiq golden", async () => {
    const sched = new BatchScheduler(model, { maxBatch: 2, kvConfig: config.kvQuant! });
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
    // Step 0: argmax anchor only (GEMV-vs-GEMM prefill convention, above).
    const ref0 = new Float32Array(await goldenAt("mixedkv-cpm-logits-step0.bin").arrayBuffer());
    const argmax = (a: Float32Array) => a.reduce((m, x, i) => (x > a[m]! ? i : m), 0);
    expect(argmax(captured[0]!)).toBe(argmax(ref0));
    expect(argmax(captured[0]!)).toBe(golden.mixed[0]!);
    // Steps 1..3: L=1 decode on both sides — BIT-EXACT vs the oracle golden.
    for (let s = 1; s < golden.logit_steps; s++) {
      const ref = new Float32Array(await goldenAt(`mixedkv-cpm-logits-step${s}.bin`).arrayBuffer());
      let maxDiff = 0;
      for (let i = 0; i < ref.length; i++)
        maxDiff = Math.max(maxDiff, Math.abs(captured[s]![i]! - ref[i]!));
      expect(maxDiff).toBe(0); // the composition inherits the scheme's oracle
    }
    clearCache();
  }, 240_000);

  test("gate 2 — B=2 dynamic join, teacher-forced: per-row KL vs solo serial-quantized within the calibrated envelope", async () => {
    const KL_TOL_PADDED = 5e-2; // quantized calibration (see header)
    const STEPS = 32;
    // Two prompts, different lengths (the joiner is shorter → left-padded).
    const promptA = golden.prompt_ids;
    const promptB = golden.prompt_ids.slice(0, Math.floor(golden.prompt_ids.length / 2));

    /** Solo serial-quantized run: greedy trajectory + per-step logits. */
    const solo = async (ids: number[]): Promise<{ toks: number[]; logits: Float32Array[] }> => {
      const { maybeQuantizeKv } = await import("../src/generate");
      const { lastPositionLogits, argmaxLastPosition } = await import("../src/model/gemma4");
      const kvOpts = { kvConfig: config.kvQuant!, quantizedKvStart: 0 };
      const cache = model.makeCache();
      const toks: number[] = [];
      const logits: Float32Array[] = [];
      let l = model.forward(ids, cache);
      logits.push(lastPositionLogits(l));
      toks.push(argmaxLastPosition(l));
      l.dispose();
      maybeQuantizeKv(cache, kvOpts);
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

    const sched = new BatchScheduler(model, { maxBatch: 2, kvConfig: config.kvQuant! });
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
    // B joins while A decodes (dynamic join through the extend path).
    await new Promise((r) => setTimeout(r, 50));
    const b = sched.submit(mkForced(promptB, refB.toks, gotB));
    await Promise.all([a, b]);
    clearCache();

    expect(gotA.length).toBe(STEPS);
    expect(gotB.length).toBe(STEPS);
    // Unpadded row: BIT-EXACT at every decode step (steps 1+; step 0 is the
    // GEMV/GEMM prefill convention, argmax-anchored in gate 1).
    for (let s = 1; s < STEPS; s++) {
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
