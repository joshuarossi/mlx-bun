// Deterministic unit tests for gradient accumulation (accumulateStep), the
// shared lever all three training loops (sft/dpo/orpo) use to raise the
// effective batch without the B>1 activation memory.
//
// These are pure-math tests over synthetic micro-batches (no model), so they
// run in the default suite — fast and ungated. The end-to-end + flat-peak
// demonstration over a real model lives in scripts/experiments/parity-gradaccum.ts.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { activeMemory, clearCache } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { accumulateStep } from "../src/train/trainer";

const vec = (xs: number[]) => MlxArray.fromFloat32(new Float32Array(xs), [xs.length]);
const read = (a: MlxArray) => Array.from(a.toFloat32());

describe("accumulateStep", () => {
  test("accumSteps=1 is a pass-through: loss + grads unchanged, afterMicroEval runs once", () => {
    let microCalls = 0;
    let afterCalls = 0;
    const { loss, grads } = accumulateStep(
      1,
      () => {
        microCalls++;
        return { value: vec([2.5]), grads: [vec([1, -2, 3]), vec([10])] };
      },
      () => { afterCalls++; },
    );
    expect(microCalls).toBe(1);
    expect(afterCalls).toBe(1);
    expect(loss).toBeCloseTo(2.5, 6);
    expect(read(grads[0]!)).toEqual([1, -2, 3]);
    expect(read(grads[1]!)).toEqual([10]);
    for (const g of grads) g.dispose();
  });

  test("accumSteps=N over IDENTICAL micro-batches == one backward (mean of equal grads)", () => {
    let microCalls = 0;
    let afterCalls = 0;
    const { loss, grads } = accumulateStep(
      3,
      () => {
        microCalls++;
        return { value: vec([2.0]), grads: [vec([3, 6, 9]), vec([12])] };
      },
      () => { afterCalls++; },
    );
    expect(microCalls).toBe(3);
    expect(afterCalls).toBe(3);
    // Mean loss of three identical scalars; mean grad of three identical vectors.
    expect(loss).toBeCloseTo(2.0, 5);
    expect(read(grads[0]!)[0]!).toBeCloseTo(3, 4);
    expect(read(grads[0]!)[1]!).toBeCloseTo(6, 4);
    expect(read(grads[0]!)[2]!).toBeCloseTo(9, 4);
    expect(read(grads[1]!)[0]!).toBeCloseTo(12, 4);
    for (const g of grads) g.dispose();
  });

  test("accumSteps=N mean-accumulates DIFFERENT micro-batch grads + averages the loss", () => {
    const lossSeq = [1, 2, 3];
    const gradSeq = [[6, 0], [12, 30], [3, -9]]; // means: 7, 7
    let i = 0;
    const { loss, grads } = accumulateStep(3, () => {
      const out = { value: vec([lossSeq[i]!]), grads: [vec(gradSeq[i]!)] };
      i++;
      return out;
    });
    expect(loss).toBeCloseTo(2.0, 5); // (1+2+3)/3
    expect(read(grads[0]!)[0]!).toBeCloseTo(7, 4); // (6+12+3)/3
    expect(read(grads[0]!)[1]!).toBeCloseTo(7, 4); // (0+30-9)/3
    for (const g of grads) g.dispose();
  });

  test("no leak: repeated accumulation steps do not grow active memory", () => {
    // Warm up + settle the allocator, then assert active memory is flat across
    // many accumulation steps (the per-micro grads + accumulators are disposed).
    const oneStep = () => {
      const { grads } = accumulateStep(4, () => ({
        value: vec([1.0]),
        grads: [vec([1, 2, 3, 4, 5]), vec([6, 7])],
      }));
      // The caller owns the returned grads (opt.step would dispose them).
      for (const g of grads) g.dispose();
    };
    for (let i = 0; i < 5; i++) oneStep();
    clearCache();
    const before = activeMemory();
    for (let i = 0; i < 50; i++) oneStep();
    clearCache();
    const after = activeMemory();
    // Flat to within allocator-bookkeeping noise. A genuine per-step leak (even
    // one small array held back) would grow by thousands of bytes over 50 steps;
    // this stays within a few hundred.
    expect(after - before).toBeLessThan(1024);
  });
});
