// Measurement-only GLM-5.2 cross-layer route coupling.
//
// The collector observes full router rows before expert-union deduplication.
// The offline model mirrors Colibri's raw coactivation voting, but never
// feeds a prediction back into residency or execution.

import type { ExpertUsageRoute } from "../expert-usage";

export interface Glm52RouteTraceRecord {
  readonly segment: string;
  readonly forward: number;
  readonly row: number;
  readonly layer: number;
  readonly indices: readonly number[];
}

export class Glm52RouteTraceCollector {
  #segment: string | null = null;
  #forward = -1;
  #lastLayer: number | null = null;
  #records: Glm52RouteTraceRecord[] = [];

  beginSegment(segment: string): void {
    if (!segment.trim()) throw new Error("GLM route trace segment is empty");
    this.#segment = segment;
    this.#forward = -1;
    this.#lastLayer = null;
  }

  observe(layer: number, routes: readonly ExpertUsageRoute[]): void {
    if (this.#segment === null)
      throw new Error("GLM route trace requires beginSegment() first");
    if (!Number.isSafeInteger(layer) || layer < 0)
      throw new RangeError(`invalid GLM route trace layer ${layer}`);
    if (this.#lastLayer === null || layer <= this.#lastLayer) this.#forward++;
    this.#lastLayer = layer;
    for (let row = 0; row < routes.length; row++) {
      const indices = Array.from(routes[row]!.indices, Number);
      if (indices.length === 0 || new Set(indices).size !== indices.length ||
          indices.some((expert) =>
            !Number.isSafeInteger(expert) || expert < 0)) {
        throw new Error(
          `invalid GLM route trace row ${this.#segment}:${this.#forward}:${row}`,
        );
      }
      this.#records.push(Object.freeze({
        segment: this.#segment,
        forward: this.#forward,
        row,
        layer,
        indices: Object.freeze(indices),
      }));
    }
  }

  snapshot(): readonly Glm52RouteTraceRecord[] {
    return Object.freeze(this.#records.slice());
  }
}

interface RoutePosition {
  readonly key: string;
  readonly segment: string;
  readonly forward: number;
  readonly row: number;
  readonly records: Glm52RouteTraceRecord[];
  readonly layers: Map<number, readonly number[]>;
}

function routePositions(
  records: readonly Glm52RouteTraceRecord[],
): RoutePosition[] {
  const positions = new Map<string, RoutePosition>();
  for (const record of records) {
    if (!record.segment || !Number.isSafeInteger(record.forward) ||
        record.forward < 0 || !Number.isSafeInteger(record.row) ||
        record.row < 0 || !Number.isSafeInteger(record.layer) ||
        record.layer < 0 || record.indices.length === 0 ||
        new Set(record.indices).size !== record.indices.length ||
        record.indices.some((expert) =>
          !Number.isSafeInteger(expert) || expert < 0)) {
      throw new Error("invalid GLM route trace record");
    }
    const key = `${record.segment}\u0000${record.forward}\u0000${record.row}`;
    let position = positions.get(key);
    if (!position) {
      position = {
        key,
        segment: record.segment,
        forward: record.forward,
        row: record.row,
        records: [],
        layers: new Map(),
      };
      positions.set(key, position);
    }
    if (position.layers.has(record.layer))
      throw new Error(`duplicate GLM route trace layer ${record.layer} at ${key}`);
    const indices = Object.freeze(Array.from(record.indices, Number));
    position.layers.set(record.layer, indices);
    position.records.push({ ...record, indices });
  }
  return [...positions.values()];
}

export interface Glm52CouplingTarget {
  readonly expertId: number;
  readonly count: number;
}

export interface Glm52CouplingEntry {
  readonly sourceLayer: number;
  readonly delta: 1 | 2;
  readonly sourceExpert: number;
  readonly targets: readonly Glm52CouplingTarget[];
}

export interface Glm52CouplingMarginal {
  readonly layer: number;
  readonly targets: readonly Glm52CouplingTarget[];
}

export interface Glm52CouplingModel {
  readonly maxCandidates: number;
  readonly entries: readonly Glm52CouplingEntry[];
  readonly marginals: readonly Glm52CouplingMarginal[];
}

function increment(
  counts: Map<number, number>,
  expertId: number,
): void {
  counts.set(expertId, (counts.get(expertId) ?? 0) + 1);
}

function ranked(counts: Map<number, number>): Glm52CouplingTarget[] {
  return [...counts.entries()]
    .map(([expertId, count]) => ({ expertId, count }))
    .sort((left, right) =>
      right.count - left.count || left.expertId - right.expertId);
}

export function buildGlm52CouplingModel(
  records: readonly Glm52RouteTraceRecord[],
  maxCandidates = 16,
): Glm52CouplingModel {
  if (!Number.isSafeInteger(maxCandidates) || maxCandidates < 1)
    throw new RangeError("GLM coupling maxCandidates must be positive");
  const pairs = new Map<string, {
    sourceLayer: number;
    delta: 1 | 2;
    sourceExpert: number;
    counts: Map<number, number>;
  }>();
  const marginals = new Map<number, Map<number, number>>();
  for (const position of routePositions(records)) {
    for (const [layer, actual] of position.layers) {
      let counts = marginals.get(layer);
      if (!counts) {
        counts = new Map();
        marginals.set(layer, counts);
      }
      for (const expertId of actual) increment(counts, expertId);
    }
    for (const [sourceLayer, source] of position.layers) {
      for (const delta of [1, 2] as const) {
        const target = position.layers.get(sourceLayer + delta);
        if (!target) continue;
        for (const sourceExpert of source) {
          const key = `${sourceLayer}:${delta}:${sourceExpert}`;
          let pair = pairs.get(key);
          if (!pair) {
            pair = {
              sourceLayer,
              delta,
              sourceExpert,
              counts: new Map(),
            };
            pairs.set(key, pair);
          }
          for (const targetExpert of target)
            increment(pair.counts, targetExpert);
        }
      }
    }
  }
  return Object.freeze({
    maxCandidates,
    entries: Object.freeze([...pairs.values()]
      .sort((left, right) =>
        left.sourceLayer - right.sourceLayer ||
        left.delta - right.delta ||
        left.sourceExpert - right.sourceExpert)
      .map((pair) => Object.freeze({
        sourceLayer: pair.sourceLayer,
        delta: pair.delta,
        sourceExpert: pair.sourceExpert,
        targets: Object.freeze(ranked(pair.counts).slice(0, maxCandidates)),
      }))),
    marginals: Object.freeze([...marginals.entries()]
      .sort(([left], [right]) => left - right)
      .map(([layer, counts]) => Object.freeze({
        layer,
        targets: Object.freeze(ranked(counts)),
      }))),
  });
}

interface MutableScore {
  rows: number;
  predictedSelections: number;
  actualSelections: number;
  matchedSelections: number;
  exactRows: number;
}

export interface Glm52CouplingScore {
  readonly rows: number;
  readonly predictedSelections: number;
  readonly actualSelections: number;
  readonly matchedSelections: number;
  readonly exactRows: number;
  readonly precision: number;
  readonly recall: number;
  readonly exactRowRate: number;
}

export interface Glm52CouplingEvaluation {
  readonly delta: 1 | 2;
  readonly budget: number;
  readonly coupled: Glm52CouplingScore;
  readonly marginal: Glm52CouplingScore;
  readonly recallLift: number;
}

function scoreRow(
  score: MutableScore,
  predicted: readonly number[],
  actual: readonly number[],
): void {
  const actualSet = new Set(actual);
  let matched = 0;
  for (const expert of predicted)
    if (actualSet.has(expert)) matched++;
  score.rows++;
  score.predictedSelections += predicted.length;
  score.actualSelections += actual.length;
  score.matchedSelections += matched;
  if (predicted.length === actual.length && matched === actual.length)
    score.exactRows++;
}

function publicScore(score: MutableScore): Glm52CouplingScore {
  const ratio = (numerator: number, denominator: number): number =>
    denominator === 0 ? 0 : numerator / denominator;
  return {
    ...score,
    precision: ratio(score.matchedSelections, score.predictedSelections),
    recall: ratio(score.matchedSelections, score.actualSelections),
    exactRowRate: ratio(score.exactRows, score.rows),
  };
}

export function evaluateGlm52Coupling(
  model: Glm52CouplingModel,
  records: readonly Glm52RouteTraceRecord[],
  budgets: readonly number[] = [4, 8, 16, 32],
): readonly Glm52CouplingEvaluation[] {
  const uniqueBudgets = [...new Set(budgets)];
  if (!uniqueBudgets.length || uniqueBudgets.some((budget) =>
    !Number.isSafeInteger(budget) || budget < 1)) {
    throw new RangeError("GLM coupling budgets must be positive integers");
  }
  const table = new Map(
    model.entries.map((entry) => [
      `${entry.sourceLayer}:${entry.delta}:${entry.sourceExpert}`,
      entry.targets,
    ]),
  );
  const marginals = new Map(
    model.marginals.map((entry) => [entry.layer, entry.targets]),
  );
  const scores = new Map<string, {
    delta: 1 | 2;
    budget: number;
    coupled: MutableScore;
    marginal: MutableScore;
  }>();
  const empty = (): MutableScore => ({
    rows: 0,
    predictedSelections: 0,
    actualSelections: 0,
    matchedSelections: 0,
    exactRows: 0,
  });
  for (const delta of [1, 2] as const) {
    for (const budget of uniqueBudgets) {
      scores.set(`${delta}:${budget}`, {
        delta,
        budget,
        coupled: empty(),
        marginal: empty(),
      });
    }
  }
  for (const position of routePositions(records)) {
    for (const [sourceLayer, source] of position.layers) {
      for (const delta of [1, 2] as const) {
        const actual = position.layers.get(sourceLayer + delta);
        if (!actual) continue;
        const votes = new Map<number, number>();
        for (const sourceExpert of source) {
          const targets = table.get(`${sourceLayer}:${delta}:${sourceExpert}`);
          for (const target of targets ?? []) {
            votes.set(
              target.expertId,
              (votes.get(target.expertId) ?? 0) + target.count,
            );
          }
        }
        const coupled = ranked(votes).map((target) => target.expertId);
        const marginal = (marginals.get(sourceLayer + delta) ?? [])
          .map((target) => target.expertId);
        for (const budget of uniqueBudgets) {
          const score = scores.get(`${delta}:${budget}`)!;
          // Runtime-faithful: an unseen source produces fewer candidates;
          // unlike the reporting baseline, coupling never marginal-backfills.
          scoreRow(score.coupled, coupled.slice(0, budget), actual);
          scoreRow(score.marginal, marginal.slice(0, budget), actual);
        }
      }
    }
  }
  return Object.freeze([...scores.values()]
    .sort((left, right) =>
      left.delta - right.delta || left.budget - right.budget)
    .map((score) => {
      const coupled = publicScore(score.coupled);
      const marginal = publicScore(score.marginal);
      return Object.freeze({
        delta: score.delta,
        budget: score.budget,
        coupled,
        marginal,
        recallLift: coupled.recall - marginal.recall,
      });
    }));
}

export interface Glm52CouplingTraceSplit {
  readonly segment: string;
  readonly trainPositions: number;
  readonly testPositions: number;
  readonly train: readonly Glm52RouteTraceRecord[];
  readonly test: readonly Glm52RouteTraceRecord[];
}

export function splitGlm52RouteTrace(
  records: readonly Glm52RouteTraceRecord[],
  options: { segment?: string; trainFraction?: number } = {},
): Glm52CouplingTraceSplit {
  const segments = [...new Set(records.map((record) => record.segment))];
  const segment = options.segment ?? segments[0];
  if (!segment || !segments.includes(segment))
    throw new Error(`GLM route trace segment ${segment ?? "<none>"} is absent`);
  const fraction = options.trainFraction ?? 0.7;
  if (!(fraction > 0 && fraction < 1))
    throw new RangeError("GLM coupling trainFraction must be between 0 and 1");
  const positions = routePositions(
    records.filter((record) => record.segment === segment),
  );
  if (positions.length < 2)
    throw new Error("GLM coupling split requires at least two route positions");
  const trainPositions = Math.max(
    1,
    Math.min(positions.length - 1, Math.floor(positions.length * fraction)),
  );
  const flatten = (items: readonly RoutePosition[]) => Object.freeze(
    items.flatMap((position) => position.records),
  );
  return Object.freeze({
    segment,
    trainPositions,
    testPositions: positions.length - trainPositions,
    train: flatten(positions.slice(0, trainPositions)),
    test: flatten(positions.slice(trainPositions)),
  });
}
