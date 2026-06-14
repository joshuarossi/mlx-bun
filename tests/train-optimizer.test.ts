// FAST: AdamW optimizer math.
//
//  (1) Converges on a quadratic f(p) = sum((p - target)^2): the param
//      should approach the target after enough steps.
//  (2) The t=1 update matches a hand-computed value (bias correction).

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { AdamW, warmupCosineSchedule } from "../src/train/optimizer";

/** grad of f(p) = sum((p - target)^2) is 2(p - target). */
function quadGrad(p: MlxArray, target: MlxArray): MlxArray {
  const diff = ops.sub(p, target);
  const g = ops.mulScalar(diff, 2);
  diff.dispose();
  return g;
}

describe("AdamW", () => {
  test("converges on a quadratic", () => {
    const target = MlxArray.fromFloat32(new Float32Array([3, -2, 0.5, 5]), [4]);
    let p = MlxArray.fromFloat32(new Float32Array([0, 0, 0, 0]), [4]);

    const opt = new AdamW([p], { lr: 0.1, weightDecay: 0 }, (_i, np) => { p = np; });
    for (let step = 0; step < 400; step++) {
      const g = quadGrad(opt.getParam(0), target);
      opt.step([g]);
      opt.evalState();
    }
    const final = opt.getParam(0).toFloat32();
    const tgt = target.toFloat32();
    for (let i = 0; i < 4; i++) expect(final[i]!).toBeCloseTo(tgt[i]!, 2);

    target.dispose();
    opt.getParam(0).dispose();
    opt.dispose();
  });

  test("t=1 update matches hand-computed value", () => {
    // p0 = 1, grad = 2, lr = 0.1, b1=0.9, b2=0.999, eps=1e-8, wd=0.
    // m̂ = g, v̂ = g², update = g/(|g|+eps) ≈ 1, p1 = 1 - lr·1 = 0.9
    let p = MlxArray.fromFloat32(new Float32Array([1]), []);
    const opt = new AdamW([p], { lr: 0.1, betas: [0.9, 0.999], eps: 1e-8, weightDecay: 0 }, (_i, np) => { p = np; });
    const g = MlxArray.fromFloat32(new Float32Array([2]), []);
    opt.step([g]);
    opt.evalState();
    const v = opt.getParam(0).toFloat32()[0]!;
    // 1 - 0.1 * (2 / (2 + 1e-8)) ≈ 0.9
    expect(v).toBeCloseTo(0.9, 5);
    expect(opt.step_count).toBe(1);
    opt.getParam(0).dispose();
    opt.dispose();
  });

  test("weight decay shrinks the param toward zero", () => {
    // With a zero gradient, only the decay term acts: p1 = p0·(1 - lr·wd).
    let p = MlxArray.fromFloat32(new Float32Array([10]), []);
    const opt = new AdamW([p], { lr: 0.1, weightDecay: 0.5 }, (_i, np) => { p = np; });
    const g = MlxArray.fromFloat32(new Float32Array([0]), []);
    opt.step([g]);
    opt.evalState();
    // decay: 10·(1 - 0.1·0.5) = 9.5; adam term is 0/(0+eps)=0.
    expect(opt.getParam(0).toFloat32()[0]!).toBeCloseTo(9.5, 4);
    opt.getParam(0).dispose();
    opt.dispose();
  });

  test("warmupCosineSchedule ramps then decays", () => {
    const sched = warmupCosineSchedule(1.0, 10, 110);
    // step 1 (0-based 0): (0+1)/10 * 1 = 0.1
    expect(sched(1)).toBeCloseTo(0.1, 6);
    // step 10 (0-based 9): (9+1)/10 = 1.0 (peak)
    expect(sched(10)).toBeCloseTo(1.0, 6);
    // at the very end, near min_lr = 0.1
    expect(sched(110)).toBeCloseTo(0.1, 2);
    // monotone-ish: post-warmup decays below peak
    expect(sched(60)).toBeLessThan(1.0);
    expect(sched(60)).toBeGreaterThan(0.1);
  });
});
