import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import type { Glm52Config } from "../src/model/glm52-config";
import { Glm52PilotTracker } from "../src/model/glm52-pilot";

function config(): Glm52Config {
  return {
    modelDir: "/pilot-test",
    modelType: "glm_moe_dsa",
    architectures: ["GlmMoeDsaForCausalLM"],
    hiddenSize: 2,
    numHiddenLayers: 2,
    numAttentionHeads: 1,
    numKeyValueHeads: 1,
    qLoraRank: 1,
    kvLoraRank: 1,
    qkNopeHeadDim: 1,
    qkRopeHeadDim: 1,
    qkHeadDim: 2,
    vHeadDim: 1,
    firstKDenseReplace: 1,
    intermediateSize: 2,
    moeIntermediateSize: 1,
    numRoutedExperts: 4,
    numExpertsPerToken: 2,
    numSharedExperts: 1,
    nGroup: 1,
    topkGroup: 1,
    normTopkProb: true,
    routedScalingFactor: 1,
    rmsNormEps: 1e-5,
    ropeTheta: 10_000,
    ropeInterleave: true,
    vocabSize: 4,
    maxPositionEmbeddings: 32,
    indexTopk: 0,
    indexNumHeads: 0,
    indexHeadDim: 0,
    indexerRopeInterleave: true,
    indexerTypes: ["full", "full"],
    numNextnPredictLayers: 0,
    indexShareForMtpIteration: false,
    eosTokenIds: [1],
    padTokenId: 0,
    raw: {},
  };
}

class PilotWeights {
  readonly values = new Map<string, MlxArray>();

  constructor() {
    this.values.set(
      "model.layers.1.post_attention_layernorm.weight",
      MlxArray.fromFloat32(new Float32Array([1, 1]), [2]),
    );
    this.values.set(
      "model.layers.1.mlp.gate.weight",
      MlxArray.fromFloat32(new Float32Array([
        1, 0,
        0, 1,
        -1, 0,
        0, -1,
      ]), [4, 2]),
    );
    this.values.set(
      "model.layers.1.mlp.gate.e_score_correction_bias",
      MlxArray.fromFloat32(new Float32Array(4), [4]),
    );
  }

  tensor(name: string): MlxArray {
    const value = this.values.get(name);
    if (!value) throw new Error(`missing PILOT test tensor ${name}`);
    return value;
  }

  dispose(): void {
    for (const value of this.values.values()) value.dispose();
  }
}

describe("GLM-5.2 measurement-only PILOT", () => {
  test("scores next-layer top-k overlap, rank quality, and lead time", () => {
    const weights = new PilotWeights();
    const input = MlxArray.fromFloat32(new Float32Array([2, 1]), [1, 1, 2]);
    const ticks = [10, 12, 20];
    const tracker = new Glm52PilotTracker({
      config: config(),
      weights,
      now: () => ticks.shift()!,
    });
    try {
      tracker.predictNext(0, input);
      // Prediction is [0,1]; actual shares only expert 0.
      tracker.observeActual(1, [{ indices: [0, 3] }]);
      const telemetry = tracker.drainTelemetry();
      expect({
        predictions: telemetry.predictionCalls,
        observed: telemetry.observedCalls,
        rows: telemetry.rows,
        predicted: telemetry.predictedSelections,
        actual: telemetry.actualSelections,
        matched: telemetry.matchedSelections,
        exact: telemetry.exactRows,
      }).toEqual({
        predictions: 1,
        observed: 1,
        rows: 1,
        predicted: 2,
        actual: 2,
        matched: 1,
        exact: 0,
      });
      expect(telemetry.precision).toBe(0.5);
      expect(telemetry.recall).toBe(0.5);
      expect(telemetry.exactRowRate).toBe(0);
      expect(telemetry.rankHitRate).toEqual([1, 0]);
      expect(telemetry.predictionLatency).toMatchObject({
        count: 1,
        totalMs: 2,
        p50Ms: 2,
      });
      expect(telemetry.leadTime).toMatchObject({
        count: 1,
        totalMs: 8,
        p50Ms: 8,
      });
      expect(telemetry.layers).toEqual([{
        layer: 1,
        calls: 1,
        rows: 1,
        predictedSelections: 2,
        actualSelections: 2,
        matchedSelections: 1,
        exactRows: 0,
        precision: 0.5,
        recall: 0.5,
        exactRowRate: 0,
      }]);
    } finally {
      input.dispose();
      weights.dispose();
    }
  });

  test("preserves Colibri's eight-row measurement guard", () => {
    const weights = new PilotWeights();
    const input = MlxArray.fromFloat32(new Float32Array(18), [1, 9, 2]);
    const tracker = new Glm52PilotTracker({ config: config(), weights });
    try {
      tracker.predictNext(0, input);
      tracker.observeActual(1, Array.from({ length: 9 }, () => ({
        indices: [0, 1],
      })));
      const telemetry = tracker.drainTelemetry();
      expect({
        predictionCalls: telemetry.predictionCalls,
        observedCalls: telemetry.observedCalls,
        skippedWideCalls: telemetry.skippedWideCalls,
        skippedWideRows: telemetry.skippedWideRows,
      }).toEqual({
        predictionCalls: 0,
        observedCalls: 0,
        skippedWideCalls: 1,
        skippedWideRows: 9,
      });
    } finally {
      input.dispose();
      weights.dispose();
    }
  });

  test("draining reports and clears a prediction abandoned by failure", () => {
    const weights = new PilotWeights();
    const input = MlxArray.fromFloat32(new Float32Array([2, 1]), [1, 1, 2]);
    const tracker = new Glm52PilotTracker({ config: config(), weights });
    try {
      tracker.predictNext(0, input);
      expect(tracker.drainTelemetry().abandonedPredictions).toBe(1);
      expect(tracker.drainTelemetry()).toMatchObject({
        predictionCalls: 0,
        observedCalls: 0,
        abandonedPredictions: 0,
      });
    } finally {
      input.dispose();
      weights.dispose();
    }
  });
});
