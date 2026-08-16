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
  linear(
    input: MlxArray,
    name: string,
    outputRows: number,
    inputColumns: number,
  ): MlxArray;
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
  /** Colibri's shared-expert-corrected predictor, scored independently. */
  readonly twoStep: Glm52PilotVariantTelemetry | null;
}

export interface Glm52PilotVariantTelemetry {
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
  readonly rankHitRate: readonly number[];
  readonly predictionLatency: ExpertLatencySummary;
  readonly leadTime: ExpertLatencySummary;
  readonly layers: readonly Glm52PilotLayerTelemetry[];
}

interface PendingPrediction {
  readonly rows: readonly (readonly number[])[];
  readonly completedAt: number;
  readonly twoStep: {
    readonly rows: readonly (readonly number[])[];
    readonly completedAt: number;
  } | null;
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

function pilotSwiglu(
  source: Glm52PilotWeightSource,
  input: MlxArray,
  prefix: string,
  intermediate: number,
  hidden: number,
): MlxArray {
  const gate = source.linear(
    input,
    `${prefix}.gate_proj.weight`,
    intermediate,
    hidden,
  );
  const up = source.linear(
    input,
    `${prefix}.up_proj.weight`,
    intermediate,
    hidden,
  );
  const activated = ops.silu(gate);
  const product = ops.mul(activated, up);
  gate.dispose();
  up.dispose();
  activated.dispose();
  const output = source.linear(
    product,
    `${prefix}.down_proj.weight`,
    hidden,
    intermediate,
  );
  product.dispose();
  return output;
}

export class Glm52PilotTracker {
  readonly config: Glm52Config;
  readonly weights: Glm52PilotWeightSource;
  readonly maxRows: number;
  readonly hintK: number;
  readonly twoStepEnabled: boolean;
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
  #twoCounts = emptyCounts();
  #twoLayers = new Map<number, MutablePilotCounts>();
  #twoRankMatches: number[];
  #twoPredictionMs: number[] = [];
  #twoLeadMs: number[] = [];
  #twoPredictionCalls = 0;
  #twoObservedCalls = 0;

  constructor(options: {
    config: Glm52Config;
    weights: Glm52PilotWeightSource;
    maxRows?: number;
    now?: () => number;
    hintK?: number;
    hintSink?: Glm52PilotHintSink;
    twoStep?: boolean;
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
    this.twoStepEnabled = options.twoStep === true;
    if (this.twoStepEnabled && this.hintK > 0) {
      throw new Error(
        "GLM PILOT two-step measurement cannot submit baseline-only hints",
      );
    }
    if (this.twoStepEnabled && this.config.numSharedExperts < 1)
      throw new Error("GLM PILOT two-step measurement requires a shared expert");
    this.#now = options.now ?? (() => performance.now());
    this.#hintSink = options.hintSink ?? null;
    this.#rankMatches = Array(this.config.numExpertsPerToken).fill(0);
    this.#twoRankMatches = Array(this.config.numExpertsPerToken).fill(0);
  }

  #predictRows(
    residual: MlxArray,
    targetLayer: number,
    rowCount: number,
  ): readonly (readonly number[])[] {
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
      return Object.freeze(predicted.map((row) => Object.freeze(row)));
    } finally {
      logits?.dispose();
      routerTranspose.dispose();
      normalized.dispose();
    }
  }

  #predictTwoStep(
    sourceLayer: number,
    residual: MlxArray,
    rowCount: number,
  ): readonly (readonly number[])[] {
    const sourcePrefix = `model.layers.${sourceLayer}`;
    const normalized = rmsNormF32Mlx(
      residual,
      this.weights.tensor(
        `${sourcePrefix}.post_attention_layernorm.weight`,
      ),
      this.config.rmsNormEps,
    );
    const sharedIntermediate =
      this.config.moeIntermediateSize * this.config.numSharedExperts;
    const shared = pilotSwiglu(
      this.weights,
      normalized,
      `${sourcePrefix}.mlp.shared_experts`,
      sharedIntermediate,
      this.config.hiddenSize,
    );
    const corrected = ops.add(residual, shared);
    try {
      return this.#predictRows(corrected, sourceLayer + 1, rowCount);
    } finally {
      corrected.dispose();
      shared.dispose();
      normalized.dispose();
    }
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
    const predicted = this.#predictRows(residual, targetLayer, rowCount);
    {
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
      let twoStep: PendingPrediction["twoStep"] = null;
      // The first sparse target is preceded by a dense layer and therefore
      // has no shared_experts block to apply as Colibri's second step.
      if (this.twoStepEnabled &&
          sourceLayer >= this.config.firstKDenseReplace) {
        const twoStarted = this.#now();
        const rows = this.#predictTwoStep(sourceLayer, residual, rowCount);
        const twoCompletedAt = this.#now();
        twoStep = { rows, completedAt: twoCompletedAt };
        this.#twoPredictionCalls++;
        this.#twoPredictionMs.push(twoCompletedAt - twoStarted);
      }
      this.#pending.set(targetLayer, {
        rows: predicted,
        completedAt,
        twoStep,
      });
      this.#predictionCalls++;
      this.#predictionMs.push(completedAt - started);
    }
  }

  #scorePrediction(
    layer: number,
    predictedRows: readonly (readonly number[])[],
    routes: readonly ExpertRouteLike[],
    counts: MutablePilotCounts,
    layers: Map<number, MutablePilotCounts>,
    rankMatches: number[],
  ): void {
    let layerCounts = layers.get(layer);
    if (!layerCounts) {
      layerCounts = emptyCounts();
      layers.set(layer, layerCounts);
    }
    counts.calls++;
    layerCounts.calls++;
    for (let row = 0; row < routes.length; row++) {
      const predicted = predictedRows[row]!;
      const actual = Array.from(routes[row]!.indices, Number);
      const actualSet = new Set(actual);
      let matched = 0;
      for (let rank = 0; rank < predicted.length; rank++) {
        if (!actualSet.has(predicted[rank]!)) continue;
        matched++;
        if (rank < rankMatches.length) rankMatches[rank]!++;
      }
      const exact = predicted.length === actual.length &&
        matched === actual.length;
      for (const target of [counts, layerCounts]) {
        target.rows++;
        target.predictedSelections += predicted.length;
        target.actualSelections += actual.length;
        target.matchedSelections += matched;
        if (exact) target.exactRows++;
      }
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
    const observedAt = this.#now();
    this.#leadMs.push(Math.max(0, observedAt - pending.completedAt));
    this.#scorePrediction(
      layer,
      pending.rows,
      routes,
      this.#counts,
      this.#layers,
      this.#rankMatches,
    );
    if (pending.twoStep) {
      this.#twoObservedCalls++;
      this.#twoLeadMs.push(
        Math.max(0, observedAt - pending.twoStep.completedAt),
      );
      this.#scorePrediction(
        layer,
        pending.twoStep.rows,
        routes,
        this.#twoCounts,
        this.#twoLayers,
        this.#twoRankMatches,
      );
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
      twoStep: this.twoStepEnabled
        ? {
            predictionCalls: this.#twoPredictionCalls,
            observedCalls: this.#twoObservedCalls,
            rows: this.#twoCounts.rows,
            predictedSelections: this.#twoCounts.predictedSelections,
            actualSelections: this.#twoCounts.actualSelections,
            matchedSelections: this.#twoCounts.matchedSelections,
            exactRows: this.#twoCounts.exactRows,
            precision: ratio(
              this.#twoCounts.matchedSelections,
              this.#twoCounts.predictedSelections,
            ),
            recall: ratio(
              this.#twoCounts.matchedSelections,
              this.#twoCounts.actualSelections,
            ),
            exactRowRate: ratio(
              this.#twoCounts.exactRows,
              this.#twoCounts.rows,
            ),
            rankHitRate: Object.freeze(this.#twoRankMatches.map((matches) =>
              ratio(matches, this.#twoCounts.rows))),
            predictionLatency: summarizeExpertLatencies(
              this.#twoPredictionMs,
            ),
            leadTime: summarizeExpertLatencies(this.#twoLeadMs),
            layers: Object.freeze([...this.#twoLayers.entries()]
              .sort(([left], [right]) => left - right)
              .map(([layer, counts]) => publicCounts(layer, counts))),
          }
        : null,
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
    this.#twoCounts = emptyCounts();
    this.#twoLayers.clear();
    this.#twoRankMatches = Array(this.config.numExpertsPerToken).fill(0);
    this.#twoPredictionMs = [];
    this.#twoLeadMs = [];
    this.#twoPredictionCalls = 0;
    this.#twoObservedCalls = 0;
    return telemetry;
  }
}
