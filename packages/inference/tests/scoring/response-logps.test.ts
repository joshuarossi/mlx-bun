import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { ValueAndGrad } from "@mlx-bun/mlx/autograd";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { sequenceLogProbabilities } from "../../src/scoring/response-logps";

const ids = [[0, 1, 2, 3, 4, 0], [4, 3, 2, 1, 0, 0]];
const mask = [[0, 0, 1, 1, 1, 1], [0, 0, 1, 1, 0, 0]];
const shape = [2, 5, 8];
const data = Float32Array.from({ length: 80 }, (_, i) => 20 + Math.sin(i * 0.7) * 2);

// Compute the oracle from the input's represented values, not the values lost
// when converting the fixture to a lower precision.
function oracle(values: Float32Array) {
  const scores = [0, 0], grads = new Float32Array(values.length);
  for (let b = 0; b < 2; b++) for (let t = 0; t < 5; t++) {
    const offset = (b * 5 + t) * 8;
    const row = values.slice(offset, offset + 8), max = Math.max(...row);
    const denominator = row.reduce((sum, v) => sum + Math.exp(v - max), 0);
    const target = ids[b]![t + 1]!, weight = mask[b]![t + 1]!;
    scores[b]! += weight * (row[target]! - max - Math.log(denominator));
    for (let v = 0; v < 8; v++) grads[offset + v] = weight *
      ((v === target ? 1 : 0) - Math.exp(row[v]! - max) / denominator);
  }
  return { scores, grads };
}

for (const [name, dtype] of [["bf16", Dtype.bfloat16], ["f16", Dtype.float16], ["f32", Dtype.float32]] as const) {
  test(`${name} response scores normalize in f32 and borrow their inputs`, () => {
    using source = MlxArray.fromFloat32(data, shape);
    using logits = source.astype(dtype);
    const represented = logits.toFloat32(), expected = oracle(represented);
    const scores = sequenceLogProbabilities(logits, ids, mask);
    expect(scores.dtype).toBe(Dtype.float32);
    expect(scores.shape).toEqual([2]);
    for (const [b, score] of scores.toFloat32().entries()) expect(score).toBeCloseTo(expected.scores[b]!, 5);
    scores.dispose();
    expect(logits.toFloat32()).toEqual(represented);
    expect(ids).toEqual([[0, 1, 2, 3, 4, 0], [4, 3, 2, 1, 0, 0]]);
    expect(mask).toEqual([[0, 0, 1, 1, 1, 1], [0, 0, 1, 1, 0, 0]]);
  });

  test(`${name} response scoring keeps finite gradients and masks prompt/padding`, () => {
    using source = MlxArray.fromFloat32(data, shape);
    using logits = source.astype(dtype);
    const expected = oracle(logits.toFloat32());
    using expectedF32 = MlxArray.fromFloat32(expected.grads, shape);
    using expectedGrad = expectedF32.astype(dtype);
    using vag = new ValueAndGrad(p => {
      using scores = sequenceLogProbabilities(p[0]!, ids, mask);
      return ops.sumAxis(scores, 0, false);
    }, [0]);
    const { value, grads } = vag.apply([logits]);
    try {
      expect(value.toFloat32()[0]!).toBeCloseTo(expected.scores[0]! + expected.scores[1]!, 5);
      expect(grads).toHaveLength(1);
      expect(grads[0]!.shape).toEqual(shape);
      const actual = grads[0]!.toFloat32(), reference = expectedGrad.toFloat32();
      for (let i = 0; i < actual.length; i++) {
        expect(Number.isFinite(actual[i])).toBe(true);
        expect(actual[i]!).toBeCloseTo(reference[i]!, 5);
      }
    } finally {
      value.dispose();
      for (const grad of grads) grad.dispose();
    }
  });
}
