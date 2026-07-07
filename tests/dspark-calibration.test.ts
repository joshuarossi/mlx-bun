// STS calibration (§3.2.1) — model-free, synthetic. fitStsThresholds is pure
// math (no MLX arrays), so this suite is fast-tier and gate-free. The final
// test wires a fitted StsCalibration into module-dflash.ts#forwardInfer's Alg-1
// pruning using the zero-init stub-model pattern from
// scripts/dspark-dflash-smoke.ts (conf.w/b zero ⟹ every c_k = σ(0) = 0.5).

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { fitStsThresholds, type ConfSample } from "../src/spec/dspark/calibration";
import { DflashDrafter, DEFAULT_DFLASH_CONFIG, type TargetDims } from "../src/spec/dspark/module-dflash";

function rng(seed: number) {
  let s = seed >>> 0 || 1;
  return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; };
}

describe("fitStsThresholds", () => {
  const GAMMA = 5;
  // A demanding target (0.9) so the fit is forced up near the step edge —
  // at the default-ish target (0.5) precision already clears the bar at very
  // low τ whenever the base acceptance rate is high, which says nothing about
  // separation. 0.9 actually exercises "smallest τ meeting target".
  const TARGET = 0.9;

  // Monotone-in-conf synthetic data: at position k, acceptance is a hard
  // step at conf > 0.6 (noise-free), except position 3 which is intentionally
  // under-sampled and position 4 which is all-rejected regardless of conf.
  function buildSamples(): ConfSample[] {
    const r = rng(42);
    const samples: ConfSample[] = [];
    for (let k = 0; k < GAMMA; k++) {
      if (k === 3) {
        // under-sampled: fewer than minSamples(50) observations
        for (let i = 0; i < 10; i++) {
          const conf = r();
          samples.push({ pos: k, conf, accepted: conf > 0.6 });
        }
        continue;
      }
      for (let i = 0; i < 200; i++) {
        const conf = r();
        const accepted = k === 4 ? false : conf > 0.6; // pos 4: all-rejected
        samples.push({ pos: k, conf, accepted });
      }
    }
    return samples;
  }

  test("position 0 always → threshold 0 (never pruned anyway)", () => {
    const sts = fitStsThresholds(buildSamples(), GAMMA, TARGET, 50);
    expect(sts.thresholds[0]).toBe(0);
  });

  test("monotone positions fit τ ≈ smallest conf clearing target (~0.6)", () => {
    const sts = fitStsThresholds(buildSamples(), GAMMA, TARGET, 50);
    // Positions 1,2 are well-sampled and cleanly separated at 0.6.
    for (const k of [1, 2]) {
      expect(sts.thresholds[k]).toBeGreaterThan(0.5);
      expect(sts.thresholds[k]).toBeLessThan(0.65);
    }
  });

  test("under-sampled position → 0 (insufficient evidence)", () => {
    const sts = fitStsThresholds(buildSamples(), GAMMA, TARGET, 50);
    expect(sts.thresholds[3]).toBe(0);
  });

  test("all-rejected position → 1.0 (head can't call it, prune always)", () => {
    const sts = fitStsThresholds(buildSamples(), GAMMA, TARGET, 50);
    expect(sts.thresholds[4]).toBe(1.0);
  });

  test("determinism: same input (any order) → same output", () => {
    const samples = buildSamples();
    const a = fitStsThresholds(samples, GAMMA, TARGET, 50);
    const shuffled = [...samples].sort(() => 0.5 - Math.random());
    const b = fitStsThresholds(shuffled, GAMMA, TARGET, 50);
    expect(b.thresholds).toEqual(a.thresholds);
    // re-run on the identical (unshuffled) array too
    const c = fitStsThresholds(samples, GAMMA, TARGET, 50);
    expect(c.thresholds).toEqual(a.thresholds);
  });

  test("target/samples provenance round-trips onto the result", () => {
    const samples = buildSamples();
    const sts = fitStsThresholds(samples, GAMMA, TARGET, 50);
    expect(sts.target).toBe(TARGET);
    expect(sts.samples).toBe(samples.length);
  });

  test("no samples at all → every non-zero position is 0 (insufficient evidence)", () => {
    const sts = fitStsThresholds([], GAMMA, TARGET, 50);
    expect(sts.thresholds).toEqual([0, 0, 0, 0, 0]);
  });
});

describe("fitStsThresholds → forwardInfer wiring (end-to-end)", () => {
  test("fitted StsCalibration prunes a zero-init drafter to 1 token", () => {
    // Stub model: only embed.scales.dtype, embed.encode, logitsFromHidden used
    // (pattern lifted from scripts/dspark-dflash-smoke.ts).
    const A = 1, G = 5, V = 64, H = 32, m = 3, dDraft = 32;
    const cfg = { ...DEFAULT_DFLASH_CONFIG, gamma: G, dDraft, nLayers: 2, nHeads: 4, markovRank: 16, tapLayers: [1, 2, 3] };
    const dims: TargetDims = { hiddenSize: H, vocabSize: V, eps: 1e-6 };
    const r = rng(7);

    const fakeEmbed = MlxArray.fromFloat32(new Float32Array(V * H).map(() => (r() - 0.5) * 0.1), [V, H]).eval();
    const fakeHead = MlxArray.fromFloat32(new Float32Array(H * V).map(() => (r() - 0.5) * 0.1), [H, V]).eval();
    const fakeScales = MlxArray.fromFloat32(new Float32Array([1]), [1]).astype(Dtype.bfloat16).eval();
    const stub = {
      embed: { scales: fakeScales, encode: (ids: MlxArray) => ops.takeAxis(fakeEmbed, ids, 0) },
      logitsFromHidden: (h: MlxArray) => { const hf = h.dtype === Dtype.float32 ? h : h.astype(Dtype.float32); const o = ops.matmul(hf, fakeHead); if (hf !== h) hf.dispose(); return o; },
    } as unknown as import("../src/model/gemma4").Gemma4Model;

    const d = DflashDrafter.initFromDims(dims, cfg, "test");
    const Lctx = 7;
    const mH = m * H;
    const hCtx = MlxArray.fromFloat32(new Float32Array(A * Lctx * mH).map(() => r()), [A, Lctx, mH]);

    // conf.w/b are zero-init ⟹ every c_k = σ(0) = 0.5 exactly, so a threshold
    // ABOVE 0.5 must prune everything past position 0 regardless of which
    // position it's applied at. Target=0.9 forces the fit past the conf=0.5
    // cluster (precision there is exactly 0.5, which fails a 0.9 bar) to the
    // conf=0.6 cluster (precision ~0.98).
    const sts = fitStsThresholds(
      [
        { pos: 0, conf: 0.5, accepted: true },
        // position 1: force τ=0.6 by construction (0.6 clears target=0.9, 0.5 does not)
        ...Array.from({ length: 60 }, (_, i) => ({ pos: 1, conf: 0.5, accepted: false } as ConfSample)),
        ...Array.from({ length: 60 }, (_, i) => ({ pos: 1, conf: 0.6, accepted: true } as ConfSample)),
      ],
      G,
      0.9,
      50,
    );
    expect(sts.thresholds[1]).toBeCloseTo(0.6, 4);

    const block = d.forwardInfer(stub, hCtx, 3, G, { thresholds: sts.thresholds });
    expect(block.tokens.length).toBe(1);
    expect(block.conf.length).toBe(1);
    expect(block.draftLogits!.shape[1]).toBe(1);

    block.draftLogits!.dispose();
    hCtx.dispose();
    d.dispose();
    fakeEmbed.dispose(); fakeHead.dispose(); fakeScales.dispose();
  });
});
