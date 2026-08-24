import { describe, expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { MlxArray } from "../../src/mlx/array";
import {
  composeGlm52MoeOutputsF32,
  composeGlm52MoeOutputsMlx,
  executeGlm52MoeReferenceF32,
  planGlm52MoeBatchF32,
  routeGlm52MoeF32,
} from "../../src/model/glm52-moe";
import { rmsNormF32, type SwiGluWeights } from "../../src/model/glm52-reference";

const ROOT = resolve(import.meta.dir, "..", "..");
const fixture = JSON.parse(
  readFileSync(join(ROOT, "fixtures/colibri-glm52/v1.json"), "utf8"),
);

function expectWithin(
  actual: ArrayLike<number>,
  expected: ArrayLike<number>,
  tolerance = 2e-6,
): void {
  expect(actual.length).toBe(expected.length);
  for (let index = 0; index < actual.length; index++)
    expect(Math.abs(actual[index]! - expected[index]!)).toBeLessThanOrEqual(tolerance);
}

function spineWeights(): SwiGluWeights {
  const data = fixture.glm_operator_spine;
  return {
    gate: data.gate_weight_output_major,
    up: data.up_weight_output_major,
    down: data.down_weight_output_major,
  };
}

describe("GLM-5.2 exact MoE primitives", () => {
  test("forms a stable multi-row expert union with exact route weights", () => {
    const logits = [
      Float32Array.from([2, 1, 0, -1]),
      Float32Array.from([0, 3, 2, 1]),
    ];
    const correction = new Float32Array(4);
    const config = { topK: 2, normalize: true, routedScale: 1 };
    const expectedRoutes = logits.map((row) =>
      routeGlm52MoeF32(row, correction, config));
    const plan = planGlm52MoeBatchF32(logits, correction, config, 2);
    expect(plan.routes).toEqual(expectedRoutes);
    expect(plan.waves.map((wave) => wave.jobs.map((job) => job.expertId)))
      .toEqual([[0, 1], [2]]);
    expect([...plan.waves[0]!.jobs[0]!.rows]).toEqual([0]);
    expect([...plan.waves[0]!.jobs[0]!.weights])
      .toEqual([expectedRoutes[0]!.executionWeights[0]!]);
    expect([...plan.waves[1]!.jobs[0]!.rows]).toEqual([1]);
  });

  test("matches captured sigmoid+bias top-8 and raw-sigmoid execution weights", () => {
    const data = fixture.true_top8_router;
    const route = routeGlm52MoeF32(data.logits_f32, data.correction_bias_f32, {
      topK: data.top_k,
      normalize: data.norm_topk,
      routedScale: data.routed_scale,
    });
    expect(route.indices).toEqual(data.expected_indices);
    expectWithin(route.rawSigmoidScores, data.expected_raw_sigmoid_f32);
    expectWithin(route.selectionScores, data.expected_choice_f32);
    expectWithin(route.executionWeights, data.expected_weights_f32);
  });

  test("keeps lower expert IDs on exact ties and never executes with correction bias", () => {
    const tied = routeGlm52MoeF32([0, 0, 0, 0], [0, 0, 0, 0], {
      topK: 3,
      normalize: false,
      routedScale: 2,
    });
    expect(tied.indices).toEqual([0, 1, 2]);
    expect(Array.from(tied.executionWeights)).toEqual([1, 1, 1]);

    const corrected = routeGlm52MoeF32([-10, 10], [2, -2], {
      topK: 1,
      normalize: false,
      routedScale: 1,
    });
    // Bias deliberately makes the almost-zero raw score win selection.
    expect(corrected.indices).toEqual([0]);
    expect(corrected.executionWeights[0]).toBe(corrected.rawSigmoidScores[0]);
    expect(corrected.executionWeights[0]).not.toBe(corrected.selectionScores[0]);
  });

  test("composes routed outputs in route order and adds shared output unweighted", () => {
    const route = routeGlm52MoeF32([2, 1], [0, 0], {
      topK: 2,
      normalize: true,
      routedScale: 1.25,
    });
    const routed = [
      { expertId: route.indices[0]!, output: [1, 2, 3] },
      { expertId: route.indices[1]!, output: [4, 5, 6] },
    ];
    const shared = [10, 20, 30];
    const expected = composeGlm52MoeOutputsF32(route, routed, shared);

    const a = MlxArray.fromFloat32(new Float32Array(routed[0]!.output), [3]);
    const b = MlxArray.fromFloat32(new Float32Array(routed[1]!.output), [3]);
    const s = MlxArray.fromFloat32(new Float32Array(shared), [3]);
    const actual = composeGlm52MoeOutputsMlx(route, [
      { expertId: routed[0]!.expertId, output: a },
      { expertId: routed[1]!.expertId, output: b },
    ], s);
    try {
      expectWithin(actual.toFloat32(), expected);
    } finally {
      actual.dispose();
      a.dispose();
      b.dispose();
      s.dispose();
    }
  });

  test("exposes a reference expert-resolution seam independent of residency", () => {
    const data = fixture.glm_operator_spine;
    const input = rmsNormF32(data.input, data.norm_weight, data.epsilon);
    const weights = spineWeights();
    const route = routeGlm52MoeF32([2, 1], [0, 0], {
      topK: 2,
      normalize: true,
      routedScale: 0.75,
    });
    const seen: number[] = [];
    const output = executeGlm52MoeReferenceF32(input, route, (expertId) => {
      seen.push(expertId);
      return weights;
    }, weights);
    expect(seen).toEqual(route.indices);
    expectWithin(
      output,
      data.mlp_output.map((value: number) => Math.fround(value * 1.75)),
      2e-5,
    );
  });

  test("rejects route/output mismatches at the shared-expert seam", () => {
    const route = routeGlm52MoeF32([1, 0], [0, 0], {
      topK: 1,
      normalize: false,
      routedScale: 1,
    });
    expect(() => composeGlm52MoeOutputsF32(route, [], null)).toThrow("output count");
    expect(() => composeGlm52MoeOutputsF32(
      route,
      [{ expertId: 1, output: [1] }],
      null,
    )).toThrow("!= route");
  });
});
