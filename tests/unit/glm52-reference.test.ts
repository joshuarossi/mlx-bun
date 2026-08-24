import { describe, expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import {
  composeSharedRoutedSwiGluF32,
  dequantizeInt4F32,
  dequantizeInt8PerRowF32,
  dsaScoresFromProjectedF32,
  matmulInt4F32,
  matmulInt8PerRowF32,
  partialInterleavedRopeF32,
  rmsNormF32,
  routeTrueTopKF32,
  selectDsaThresholdTiesF32,
  swiGluF32,
  type SwiGluWeights,
} from "../../src/model/glm52-reference";

const ROOT = resolve(import.meta.dir, "..", "..");
const fixture = JSON.parse(
  readFileSync(join(ROOT, "fixtures/colibri-glm52/v1.json"), "utf8"),
);

function expectWithin(
  actual: ArrayLike<number>,
  expected: ArrayLike<number>,
  atol: number,
  rtol: number,
): void {
  expect(actual.length).toBe(expected.length);
  for (let index = 0; index < actual.length; index++) {
    const error = Math.abs(actual[index]! - expected[index]!);
    const limit = atol + rtol * Math.abs(expected[index]!);
    expect(error).toBeLessThanOrEqual(limit);
  }
}

function flatten(matrix: number[][]): number[] {
  return matrix.flatMap((row) => row);
}

function spineWeights(): SwiGluWeights {
  const data = fixture.glm_operator_spine;
  return {
    gate: data.gate_weight_output_major,
    up: data.up_weight_output_major,
    down: data.down_weight_output_major,
  };
}

describe("GLM-5.2 reference arithmetic", () => {
  test("matches captured int8 per-row dequantization and matmul", () => {
    const data = fixture.quantization.int8_per_row;
    const matrix = {
      outputRows: data.shape.output_rows,
      inputColumns: data.shape.input_columns,
      qbytes: data.qbytes_u8,
      scales: data.scales_f32,
    };
    expect(Array.from(dequantizeInt8PerRowF32(matrix))).toEqual(flatten(data.dequant_f32));
    const output = matmulInt8PerRowF32(data.input_f32, matrix);
    for (let row = 0; row < output.length; row++)
      expectWithin(output[row]!, data.matmul_f32[row], data.atol, data.rtol);
  });

  test("matches captured grouped int4 and covers the per-row format", () => {
    const data = fixture.quantization.int4_grouped;
    const grouped = {
      outputRows: data.shape.output_rows,
      inputColumns: data.shape.input_columns,
      qbytes: data.qbytes_u8,
      scales: data.scales_f32,
      groupSize: data.group_size,
    };
    expect(Array.from(dequantizeInt4F32(grouped))).toEqual(flatten(data.dequant_f32));
    const output = matmulInt4F32(data.input_f32, grouped);
    for (let row = 0; row < output.length; row++)
      expectWithin(output[row]!, data.matmul_f32[row], data.atol, data.rtol);

    // q=[-8,-1,0,7, 1,-2], low input nibble first.
    const perRow = {
      outputRows: 1,
      inputColumns: 6,
      qbytes: [0x70, 0xf8, 0x69],
      scales: [0.5],
      groupSize: null,
    };
    expect(Array.from(dequantizeInt4F32(perRow))).toEqual([-4, -0.5, 0, 3.5, 0.5, -1]);
    expect(Array.from(matmulInt4F32([[1, 2, 3, 4, 5, 6]], perRow)[0]!)).toEqual([5.5]);
  });

  test("matches RMSNorm and the captured SwiGLU operator spine", () => {
    const data = fixture.glm_operator_spine;
    const normalized = rmsNormF32(data.input, data.norm_weight, data.epsilon);
    expectWithin(normalized, data.normalized, data.atol, data.rtol);
    const output = swiGluF32(normalized, spineWeights());
    expectWithin(output, data.mlp_output, data.atol, data.rtol);
  });

  test("uses pair-interleaved partial RoPE and preserves the unrotated tail", () => {
    // At position zero, pair-interleaved [a0,b0,a1,b1] becomes split
    // [a0,a1,b0,b1], making the layout contract independently observable.
    expect(Array.from(partialInterleavedRopeF32(
      [1, 2, 3, 4, 91, 92],
      0,
      4,
      8_000_000,
    ))).toEqual([1, 3, 2, 4, 91, 92]);

    const rotated = partialInterleavedRopeF32([1, 0, 0, 1, 7], 1, 4, 10_000);
    expectWithin(rotated, [
      Math.fround(Math.cos(1)),
      Math.fround(-Math.sin(0.01)),
      Math.fround(Math.sin(1)),
      Math.fround(Math.cos(0.01)),
      7,
    ], 2e-7, 2e-7);
  });

  test("matches true correction-biased top-k with unbiased execution weights", () => {
    const data = fixture.true_top8_router;
    const route = routeTrueTopKF32(
      data.logits_f32,
      data.correction_bias_f32,
      data.top_k,
      data.norm_topk,
      data.routed_scale,
    );
    expect(route.indices).toEqual(data.expected_indices);
    expect(route.indices.slice(0, 2)).toEqual([0, 1]); // exact tie -> lower ID.
    expectWithin(route.rawSigmoidScores, data.expected_raw_sigmoid_f32, data.atol, data.rtol);
    expectWithin(route.selectionScores, data.expected_choice_f32, data.atol, data.rtol);
    expectWithin(route.executionWeights, data.expected_weights_f32, data.atol, data.rtol);
  });

  test("accumulates routed experts in order and adds the shared expert unweighted", () => {
    const data = fixture.glm_operator_spine;
    const normalized = rmsNormF32(data.input, data.norm_weight, data.epsilon);
    const weights = spineWeights();
    const output = composeSharedRoutedSwiGluF32(normalized, [
      { expert: weights, weight: 0.25 },
      { expert: weights, weight: 0.5 },
    ], weights);
    expectWithin(
      output,
      data.mlp_output.map((value: number) => Math.fround(value * 1.75)),
      2e-5,
      2e-5,
    );
  });

  test("matches every captured DSA threshold/tie case and projected scoring", () => {
    for (const data of fixture.dsa_selection.cases) {
      const selected = selectDsaThresholdTiesF32(data.scores, data.keep);
      expect(selected.threshold).toBe(data.expected.threshold);
      expect(selected.selected).toEqual(data.expected.selected);
    }

    const scores = dsaScoresFromProjectedF32(
      [[1, 0], [0, 1]],
      [[1, 2], [-1, 3], [0, 0]],
      [2, 1],
    );
    expectWithin(scores, [2, 1.5, 0], 2e-6, 2e-6);
    expect(selectDsaThresholdTiesF32(scores, 2).selected).toEqual([0, 1]);
  });

});
