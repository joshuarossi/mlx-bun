// Measurement-only GLM-5.2 PILOT predictor.
//
// Faithful to direct Colibri's first-stage policy: after layer L attention,
// normalize that raw residual with layer L+1's post-attention norm and apply
// layer L+1's router. This module records prediction quality and available
// lead time only. It never touches residency or submits expert I/O.

import {
  summarizeExpertLatencies,
  type ExpertHintTelemetry,
  type ExpertLatencySummary,
  type ExpertRouteLike,
} from "../expert-residency";
import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { Glm52Config } from "./glm52-config";
import { rmsNormF32Mlx } from "./glm52-mla";
import { routeGlm52MoeF32 } from "./glm52-moe";

export const GLM52_PILOT_MAX_ROWS = 8;

export interface Glm52PilotWeightSource {
  tensor(name: string): MlxArray;
}

export interface Glm52PilotLayerTelemetry {
  readonly layer: number;
  readonly calls: number;
  readonly rows: number;
  readonly predictedSelections: number;
  readonly actualSelections: number;
  readonly matchedSelections: number;
  readonly exactRows: number;
  readonly precision: number;
  readonly recall: number;
  readonly exactRowRate: number;
}

export interface Glm52PilotHintSink {
  hintExperts(layer: number, expertIds: readonly number[]): void;
  drainHintTelemetry(): ExpertHintTelemetry;
}

export interface Glm52PilotTelemetry {
  readonly mode: "measure-only" | "hint-only";
  readonly maxRows: number;
  readonly hintK: number;
  readonly predictionCalls: number;
  readonly observedCalls: number;
  readonly rows: number;
  readonly predictedSelections: number;
  readonly actualSelections: number;
  readonly matchedSelections: number;
  readonly exactRows: number;
  readonly precision: number;
  readonly recall: number;
  readonly exactRowRate: number;
  /** Set-overlap hit rate for each predicted rank, useful for PILOT_K. */
  readonly rankHitRate: readonly number[];
  readonly skippedWideCalls: number;
  readonly skippedWideRows: number;
  readonly abandonedPredictions: number;
  readonly predictionLatency: ExpertLatencySummary;
  /** Time from prediction completion until the target router is observed. */
  readonly leadTime: ExpertLatencySummary;
  readonly layers: readonly Glm52PilotLayerTelemetry[];
  readonly hints: ExpertHintTelemetry | null;
}

interface PendingPrediction {
  readonly rows: readonly (readonly number[])[];
  readonly completedAt: number;
}

interface MutablePilotCounts {
  calls: number;
  rows: number;
  predictedSelections: number;
  actualSelections: number;
  matchedSelections: number;
  exactRows: number;
}

function emptyCounts(): MutablePilotCounts {
  return {
    calls: 0,
    rows: 0,
    predictedSelections: 0,
    actualSelections: 0,
    matchedSelections: 0,
    exactRows: 0,
  };
}

function ratio(numerator: number, denominator: number): number {
  return denominator === 0 ? 0 : numerator / denominator;
}

function publicCounts(
  layer: number,
  counts: MutablePilotCounts,
): Glm52PilotLayerTelemetry {
  return {
    layer,
    ...counts,
    precision: ratio(counts.matchedSelections, counts.predictedSelections),
    recall: ratio(counts.matchedSelections, counts.actualSelections),
    exactRowRate: ratio(counts.exactRows, counts.rows),
  };
}

export class Glm52PilotTracker {
  readonly config: Glm52Config;
  readonly weights: Glm52PilotWeightSource;
  readonly maxRows: number;
  readonly hintK: number;
  #now: () => number;
  #hintSink: Glm52PilotHintSink | null;
  #pending = new Map<number, PendingPrediction>();
  #counts = emptyCounts();
  #layers = new Map<number, MutablePilotCounts>();
  #rankMatches: number[];
  #predictionMs: number[] = [];
  #leadMs: number[] = [];
  #predictionCalls = 0;
  #observedCalls = 0;
  #skippedWideCalls = 0;
  #skippedWideRows = 0;

  constructor(options: {
    config: Glm52Config;
    weights: Glm52PilotWeightSource;
    maxRows?: number;
    now?: () => number;
    hintK?: number;
    hintSink?: Glm52PilotHintSink;
  }) {
    this.config = options.config;
    this.weights = options.weights;
    this.maxRows = options.maxRows ?? GLM52_PILOT_MAX_ROWS;
    if (!Number.isSafeInteger(this.maxRows) || this.maxRows < 1)
      throw new RangeError("GLM PILOT maxRows must be a positive safe integer");
    this.hintK = options.hintK ?? 0;
    if (!Number.isSafeInteger(this.hintK) || this.hintK < 0 ||
        this.hintK > this.config.numExpertsPerToken) {
      throw new RangeError(
        `GLM PILOT hintK must be in 0..${this.config.numExpertsPerToken}`,
      );
    }
    if ((this.hintK > 0) !== (options.hintSink !== undefined))
      throw new Error("GLM PILOT hintK and hintSink must be enabled together");
    this.#now = options.now ?? (() => performance.now());
    this.#hintSink = options.hintSink ?? null;
    this.#rankMatches = Array(this.config.numExpertsPerToken).fill(0);
  }

  /** Predict layer L+1 from layer L's raw post-attention residual. */
  predictNext(sourceLayer: number, residual: MlxArray): void {
    const targetLayer = sourceLayer + 1;
    if (targetLayer < this.config.firstKDenseReplace ||
        targetLayer >= this.config.numHiddenLayers) return;
    const [batch, tokens, hidden] = residual.shape;
    if (residual.shape.length !== 3 || hidden !== this.config.hiddenSize) {
      throw new Error(
        `GLM PILOT requires [B,T,${this.config.hiddenSize}] residual input`,
      );
    }
    const rowCount = batch! * tokens!;
    if (rowCount > this.maxRows) {
      this.#skippedWideCalls++;
      this.#skippedWideRows += rowCount;
      return;
    }
    if (this.#pending.has(targetLayer)) {
      throw new Error(
        `GLM PILOT already has a pending prediction for layer ${targetLayer}`,
      );
    }

    const started = this.#now();
    const prefix = `model.layers.${targetLayer}`;
    const normalized = rmsNormF32Mlx(
      residual,
      this.weights.tensor(`${prefix}.post_attention_layernorm.weight`),
      this.config.rmsNormEps,
    );
    const routerTranspose = ops.transposeAxes(
      this.weights.tensor(`${prefix}.mlp.gate.weight`),
      [1, 0],
    );
    let logits: MlxArray | null = null;
    try {
      logits = ops.matmul(normalized, routerTranspose);
      const host = logits.toFloat32();
      const correctionBias = this.weights
        .tensor(`${prefix}.mlp.gate.e_score_correction_bias`)
        .toFloat32();
      const predicted: number[][] = [];
      for (let row = 0; row < rowCount; row++) {
        const begin = row * this.config.numRoutedExperts;
        const route = routeGlm52MoeF32(
          host.subarray(begin, begin + this.config.numRoutedExperts),
          correctionBias,
          {
            topK: this.config.numExpertsPerToken,
            normalize: this.config.normTopkProb,
            routedScale: this.config.routedScalingFactor,
          },
        );
        predicted.push(Array.from(route.indices));
      }
      if (this.#hintSink) {
        const hinted: number[] = [];
        const seen = new Set<number>();
        for (const row of predicted) {
          for (const expertId of row.slice(0, this.hintK)) {
            if (seen.has(expertId)) continue;
            seen.add(expertId);
            hinted.push(expertId);
          }
        }
        this.#hintSink.hintExperts(targetLayer, hinted);
      }
      const completedAt = this.#now();
      this.#pending.set(targetLayer, {
        rows: Object.freeze(predicted.map((row) => Object.freeze(row))),
        completedAt,
      });
      this.#predictionCalls++;
      this.#predictionMs.push(completedAt - started);
    } finally {
      logits?.dispose();
      routerTranspose.dispose();
      normalized.dispose();
    }
  }

  /** Compare a pending prediction with the real layer router output. */
  observeActual(layer: number, routes: readonly ExpertRouteLike[]): void {
    const pending = this.#pending.get(layer);
    if (!pending) return;
    this.#pending.delete(layer);
    if (pending.rows.length !== routes.length) {
      throw new Error(
        `GLM PILOT layer ${layer} predicted ${pending.rows.length} rows, ` +
        `observed ${routes.length}`,
      );
    }
    this.#observedCalls++;
    this.#leadMs.push(Math.max(0, this.#now() - pending.completedAt));
    let layerCounts = this.#layers.get(layer);
    if (!layerCounts) {
      layerCounts = emptyCounts();
      this.#layers.set(layer, layerCounts);
    }
    this.#counts.calls++;
    layerCounts.calls++;

    for (let row = 0; row < routes.length; row++) {
      const predicted = pending.rows[row]!;
      const actual = Array.from(routes[row]!.indices, Number);
      const actualSet = new Set(actual);
      let matched = 0;
      for (let rank = 0; rank < predicted.length; rank++) {
        if (!actualSet.has(predicted[rank]!)) continue;
        matched++;
        if (rank < this.#rankMatches.length) this.#rankMatches[rank]!++;
      }
      const exact = predicted.length === actual.length &&
        matched === actual.length;
      for (const counts of [this.#counts, layerCounts]) {
        counts.rows++;
        counts.predictedSelections += predicted.length;
        counts.actualSelections += actual.length;
        counts.matchedSelections += matched;
        if (exact) counts.exactRows++;
      }
    }
  }

  /** Turn-safe snapshot. Draining also discards predictions left by failure. */
  drainTelemetry(): Glm52PilotTelemetry {
    const abandonedPredictions = this.#pending.size;
    const observedRows = this.#counts.rows;
    const telemetry: Glm52PilotTelemetry = {
      mode: this.#hintSink ? "hint-only" : "measure-only",
      maxRows: this.maxRows,
      hintK: this.hintK,
      predictionCalls: this.#predictionCalls,
      observedCalls: this.#observedCalls,
      rows: observedRows,
      predictedSelections: this.#counts.predictedSelections,
      actualSelections: this.#counts.actualSelections,
      matchedSelections: this.#counts.matchedSelections,
      exactRows: this.#counts.exactRows,
      precision: ratio(
        this.#counts.matchedSelections,
        this.#counts.predictedSelections,
      ),
      recall: ratio(
        this.#counts.matchedSelections,
        this.#counts.actualSelections,
      ),
      exactRowRate: ratio(this.#counts.exactRows, observedRows),
      rankHitRate: Object.freeze(this.#rankMatches.map((matches) =>
        ratio(matches, observedRows))),
      skippedWideCalls: this.#skippedWideCalls,
      skippedWideRows: this.#skippedWideRows,
      abandonedPredictions,
      predictionLatency: summarizeExpertLatencies(this.#predictionMs),
      leadTime: summarizeExpertLatencies(this.#leadMs),
      layers: Object.freeze([...this.#layers.entries()]
        .sort(([left], [right]) => left - right)
        .map(([layer, counts]) => publicCounts(layer, counts))),
      hints: this.#hintSink?.drainHintTelemetry() ?? null,
    };
    this.#pending.clear();
    this.#counts = emptyCounts();
    this.#layers.clear();
    this.#rankMatches = Array(this.config.numExpertsPerToken).fill(0);
    this.#predictionMs = [];
    this.#leadMs = [];
    this.#predictionCalls = 0;
    this.#observedCalls = 0;
    this.#skippedWideCalls = 0;
    this.#skippedWideRows = 0;
    return telemetry;
  }
}
