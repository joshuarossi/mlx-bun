// Offline GLM-5.2 Expert Atlas analysis.
//
// Each prompt is one independent observation. Selection counts are normalized
// within a run, averaged within a category, and only promoted to an affinity
// label when the top topic fires in multiple independent prompts. Nothing in
// this module feeds residency, routing, or prefetch policy.

import type { Glm52RouteTraceRecord } from "./glm52-coupling";

export interface Glm52AtlasProbeSet {
  readonly schemaVersion: 1;
  readonly provenance: {
    readonly source: string;
    readonly sourceCommit: string;
    readonly method: string;
  };
  readonly categories: Readonly<Record<string, readonly string[]>>;
}

export interface Glm52AtlasRun {
  readonly category: string;
  readonly promptIndex: number;
  readonly totalSelections: number;
  readonly counts: ReadonlyMap<string, number>;
}

export interface Glm52AtlasExpert {
  readonly layer: number;
  readonly expert: number;
  readonly total: number;
  readonly specialization: number;
  readonly topTopic: string;
  readonly topLift: number;
  readonly reliability: {
    readonly firedRuns: number;
    readonly totalRuns: number;
  };
  readonly affinity: Readonly<Record<string, number>>;
}

export interface Glm52AtlasAnalysis {
  readonly schemaVersion: 1;
  readonly categories: readonly string[];
  readonly runCount: number;
  readonly method: {
    readonly minCount: number;
    readonly minRuns: number;
    readonly strongThreshold: number;
    readonly normalization: "mean per-run selection share";
  };
  readonly summary: {
    readonly expertsSeen: number;
    readonly expertsKept: number;
    readonly droppedSparse: number;
    readonly droppedUnreplicated: number;
    readonly strongSpecialists: number;
    readonly strongSpecialistRate: number;
  };
  readonly experts: readonly Glm52AtlasExpert[];
}

export interface Glm52AtlasValidationTrial {
  readonly category: string;
  readonly promptIndex: number;
  readonly predicted: string;
  readonly correct: boolean;
  readonly ownShare: number;
  readonly bestOtherShare: number;
  readonly scores: Readonly<Record<string, number>>;
}

export interface Glm52AtlasValidation {
  readonly topK: number;
  readonly hits: number;
  readonly trials: number;
  readonly accuracy: number;
  readonly chance: number;
  readonly protocol: "global leave-one-prompt-out";
  readonly trialsByPrompt: readonly Glm52AtlasValidationTrial[];
}

export interface Glm52AtlasBuildOptions {
  readonly minCount?: number;
  readonly minRuns?: number;
  readonly strongThreshold?: number;
}

const CATEGORY = /^[a-z0-9][a-z0-9_]*$/;

function finiteUnit(value: number, label: string): void {
  if (!Number.isFinite(value) || value < 0 || value > 1)
    throw new RangeError(`${label} must be in [0, 1]`);
}

function positiveInteger(value: number, label: string): void {
  if (!Number.isSafeInteger(value) || value <= 0)
    throw new RangeError(`${label} must be a positive safe integer`);
}

function round(value: number, digits = 6): number {
  const scale = 10 ** digits;
  return Math.round(value * scale) / scale;
}

function expertKey(layer: number, expert: number): string {
  return `${layer}:${expert}`;
}

function parseExpertKey(key: string): [number, number] {
  const fields = key.split(":");
  const layer = Number(fields[0]);
  const expert = Number(fields[1]);
  if (fields.length !== 2 || !Number.isSafeInteger(layer) || layer < 0 ||
      !Number.isSafeInteger(expert) || expert < 0) {
    throw new Error(`invalid GLM Atlas expert key ${key}`);
  }
  return [layer, expert];
}

export function glm52AtlasRunId(category: string, promptIndex: number): string {
  if (!CATEGORY.test(category))
    throw new Error(`invalid GLM Atlas category ${category}`);
  if (!Number.isSafeInteger(promptIndex) || promptIndex < 0)
    throw new RangeError(`invalid GLM Atlas prompt index ${promptIndex}`);
  return `${category}:${promptIndex}`;
}

export function validateGlm52AtlasProbeSet(
  value: unknown,
): Glm52AtlasProbeSet {
  if (!value || typeof value !== "object")
    throw new Error("GLM Atlas probe set must be an object");
  const input = value as Record<string, unknown>;
  if (input.schemaVersion !== 1)
    throw new Error("unsupported GLM Atlas probe schema");
  const provenance = input.provenance as Record<string, unknown> | undefined;
  if (!provenance || ["source", "sourceCommit", "method"].some(
    (key) => typeof provenance[key] !== "string" ||
      !(provenance[key] as string).trim(),
  )) {
    throw new Error("GLM Atlas probe provenance is incomplete");
  }
  const raw = input.categories;
  if (!raw || typeof raw !== "object" || Array.isArray(raw))
    throw new Error("GLM Atlas categories must be an object");
  const entries = Object.entries(raw as Record<string, unknown>);
  if (entries.length < 2)
    throw new Error("GLM Atlas requires at least two categories");
  const categories: Record<string, readonly string[]> = {};
  for (const [category, prompts] of entries) {
    if (!CATEGORY.test(category))
      throw new Error(`invalid GLM Atlas category ${category}`);
    if (!Array.isArray(prompts) || prompts.length < 3 ||
        prompts.some((prompt) => typeof prompt !== "string" || !prompt.trim())) {
      throw new Error(
        `GLM Atlas category ${category} requires at least three prompts`,
      );
    }
    categories[category] = Object.freeze(prompts.slice());
  }
  return Object.freeze({
    schemaVersion: 1,
    provenance: Object.freeze({
      source: provenance.source as string,
      sourceCommit: provenance.sourceCommit as string,
      method: provenance.method as string,
    }),
    categories: Object.freeze(categories),
  });
}

export function buildGlm52AtlasRun(
  category: string,
  promptIndex: number,
  records: readonly Glm52RouteTraceRecord[],
): Glm52AtlasRun {
  const segment = glm52AtlasRunId(category, promptIndex);
  const counts = new Map<string, number>();
  let totalSelections = 0;
  if (records.length === 0)
    throw new Error(`GLM Atlas run ${segment} has no route records`);
  for (const record of records) {
    if (record.segment !== segment)
      throw new Error(
        `GLM Atlas run ${segment} contains segment ${record.segment}`,
      );
    if (!Number.isSafeInteger(record.forward) || record.forward < 0 ||
        !Number.isSafeInteger(record.row) || record.row < 0 ||
        !Number.isSafeInteger(record.layer) || record.layer < 0 ||
        record.indices.length === 0 ||
        new Set(record.indices).size !== record.indices.length) {
      throw new Error(`GLM Atlas run ${segment} has an invalid route row`);
    }
    for (const expert of record.indices) {
      if (!Number.isSafeInteger(expert) || expert < 0)
        throw new Error(`GLM Atlas run ${segment} has invalid expert ${expert}`);
      const key = expertKey(record.layer, expert);
      counts.set(key, (counts.get(key) ?? 0) + 1);
      totalSelections++;
    }
  }
  return Object.freeze({
    category,
    promptIndex,
    totalSelections,
    counts,
  });
}

function checkedRuns(
  probes: Glm52AtlasProbeSet,
  runs: readonly Glm52AtlasRun[],
): {
  categories: string[];
  ordered: Glm52AtlasRun[];
} {
  const categories = Object.keys(probes.categories).sort();
  const expected = new Set<string>();
  for (const category of categories) {
    const prompts = probes.categories[category]!;
    for (let index = 0; index < prompts.length; index++)
      expected.add(glm52AtlasRunId(category, index));
  }
  const seen = new Set<string>();
  for (const run of runs) {
    const id = glm52AtlasRunId(run.category, run.promptIndex);
    if (!expected.has(id)) throw new Error(`unexpected GLM Atlas run ${id}`);
    if (seen.has(id)) throw new Error(`duplicate GLM Atlas run ${id}`);
    if (!Number.isSafeInteger(run.totalSelections) || run.totalSelections <= 0)
      throw new Error(`GLM Atlas run ${id} has no selections`);
    let counted = 0;
    for (const [key, count] of run.counts) {
      parseExpertKey(key);
      positiveInteger(count, `GLM Atlas count ${id}/${key}`);
      counted += count;
    }
    if (counted !== run.totalSelections)
      throw new Error(
        `GLM Atlas run ${id} count total ${counted} != ${run.totalSelections}`,
      );
    seen.add(id);
  }
  const missing = [...expected].filter((id) => !seen.has(id));
  if (missing.length)
    throw new Error(`missing GLM Atlas runs: ${missing.join(", ")}`);
  return {
    categories,
    ordered: runs.slice().sort((left, right) =>
      left.category.localeCompare(right.category) ||
      left.promptIndex - right.promptIndex),
  };
}

function categoryShares(
  categories: readonly string[],
  runs: readonly Glm52AtlasRun[],
): Map<string, Float64Array> {
  const index = new Map(categories.map((category, i) => [category, i]));
  const byCategory = new Map<string, Glm52AtlasRun[]>();
  for (const category of categories) byCategory.set(category, []);
  for (const run of runs) byCategory.get(run.category)?.push(run);
  const shares = new Map<string, Float64Array>();
  for (const category of categories) {
    const categoryRuns = byCategory.get(category)!;
    if (categoryRuns.length === 0) continue;
    const c = index.get(category)!;
    for (const run of categoryRuns) {
      for (const [key, count] of run.counts) {
        let values = shares.get(key);
        if (!values) {
          values = new Float64Array(categories.length);
          shares.set(key, values);
        }
        values[c] = values[c]! +
          count / run.totalSelections / categoryRuns.length;
      }
    }
  }
  return shares;
}

function deterministicTop(
  categories: readonly string[],
  values: ArrayLike<number>,
): number {
  let best = 0;
  for (let index = 1; index < categories.length; index++)
    if (values[index]! > values[best]!) best = index;
  return best;
}

export function buildGlm52Atlas(
  probes: Glm52AtlasProbeSet,
  runs: readonly Glm52AtlasRun[],
  options: Glm52AtlasBuildOptions = {},
): Glm52AtlasAnalysis {
  const minCount = options.minCount ?? 30;
  const minRuns = options.minRuns ?? 2;
  const strongThreshold = options.strongThreshold ?? 0.5;
  positiveInteger(minCount, "GLM Atlas minCount");
  positiveInteger(minRuns, "GLM Atlas minRuns");
  finiteUnit(strongThreshold, "GLM Atlas strongThreshold");
  const checked = checkedRuns(probes, runs);
  const { categories, ordered } = checked;
  if (categories.some((category) =>
    probes.categories[category]!.length < minRuns)) {
    throw new Error("GLM Atlas minRuns exceeds a category's prompt count");
  }
  const shares = categoryShares(categories, ordered);
  const runsByCategory = new Map<string, Glm52AtlasRun[]>();
  for (const category of categories) runsByCategory.set(category, []);
  for (const run of ordered) runsByCategory.get(run.category)!.push(run);

  let droppedSparse = 0;
  let droppedUnreplicated = 0;
  const experts: Glm52AtlasExpert[] = [];
  for (const [key, meanShares] of shares) {
    const total = ordered.reduce(
      (sum, run) => sum + (run.counts.get(key) ?? 0),
      0,
    );
    if (total < minCount) {
      droppedSparse++;
      continue;
    }
    const sum = meanShares.reduce((value, next) => value + next, 0);
    if (sum <= 0) continue;
    const probabilities = Array.from(meanShares, (value) => value / sum);
    const topIndex = deterministicTop(categories, probabilities);
    const topTopic = categories[topIndex]!;
    const topRuns = runsByCategory.get(topTopic)!;
    const firedRuns = topRuns.filter((run) =>
      (run.counts.get(key) ?? 0) > 0).length;
    if (firedRuns < minRuns) {
      droppedUnreplicated++;
      continue;
    }
    const entropy = -probabilities.reduce(
      (value, probability) =>
        value + (probability > 0 ? probability * Math.log(probability) : 0),
      0,
    );
    const specialization = Math.max(
      0,
      Math.min(1, 1 - entropy / Math.log(categories.length)),
    );
    const affinity: Record<string, number> = {};
    for (let index = 0; index < categories.length; index++)
      affinity[categories[index]!] = round(probabilities[index]!);
    const [layer, expert] = parseExpertKey(key);
    experts.push(Object.freeze({
      layer,
      expert,
      total,
      specialization: round(specialization),
      topTopic,
      topLift: round(probabilities[topIndex]! * categories.length),
      reliability: Object.freeze({
        firedRuns,
        totalRuns: topRuns.length,
      }),
      affinity: Object.freeze(affinity),
    }));
  }
  experts.sort((left, right) =>
    right.specialization - left.specialization ||
    right.total - left.total ||
    left.layer - right.layer ||
    left.expert - right.expert);
  const strongSpecialists = experts.filter(
    (expert) => expert.specialization >= strongThreshold,
  ).length;
  return Object.freeze({
    schemaVersion: 1,
    categories: Object.freeze(categories),
    runCount: ordered.length,
    method: Object.freeze({
      minCount,
      minRuns,
      strongThreshold,
      normalization: "mean per-run selection share",
    }),
    summary: Object.freeze({
      expertsSeen: shares.size,
      expertsKept: experts.length,
      droppedSparse,
      droppedUnreplicated,
      strongSpecialists,
      strongSpecialistRate: round(
        strongSpecialists / Math.max(1, experts.length),
      ),
    }),
    experts: Object.freeze(experts),
  });
}

function specialistSets(
  categories: readonly string[],
  training: readonly Glm52AtlasRun[],
  topK: number,
): Map<string, Set<string>> {
  const shares = categoryShares(categories, training);
  const sets = new Map<string, Set<string>>();
  for (let categoryIndex = 0;
    categoryIndex < categories.length;
    categoryIndex++
  ) {
    const scored: Array<{ key: string; score: number; layer: number; expert: number }> = [];
    for (const [key, values] of shares) {
      if (values[categoryIndex]! <= 0) continue;
      const sum = values.reduce((value, next) => value + next, 0);
      const [layer, expert] = parseExpertKey(key);
      scored.push({
        key,
        score: values[categoryIndex]! / sum,
        layer,
        expert,
      });
    }
    scored.sort((left, right) =>
      right.score - left.score ||
      left.layer - right.layer ||
      left.expert - right.expert);
    sets.set(
      categories[categoryIndex]!,
      new Set(scored.slice(0, topK).map((entry) => entry.key)),
    );
  }
  return sets;
}

export function validateGlm52Atlas(
  probes: Glm52AtlasProbeSet,
  runs: readonly Glm52AtlasRun[],
  topK = 200,
): Glm52AtlasValidation {
  positiveInteger(topK, "GLM Atlas validation topK");
  const { categories, ordered } = checkedRuns(probes, runs);
  const trialsByPrompt: Glm52AtlasValidationTrial[] = [];
  let hits = 0;
  for (const held of ordered) {
    // The held-out prompt is absent from every topic model, including the
    // background distribution used to score other categories.
    const training = ordered.filter((run) => run !== held);
    const sets = specialistSets(categories, training, topK);
    const scores: Record<string, number> = {};
    for (const category of categories) {
      const selected = sets.get(category)!;
      let count = 0;
      for (const [key, value] of held.counts)
        if (selected.has(key)) count += value;
      scores[category] = count / held.totalSelections;
    }
    const predictedIndex = deterministicTop(
      categories,
      categories.map((category) => scores[category]!),
    );
    const predicted = categories[predictedIndex]!;
    const correct = predicted === held.category;
    if (correct) hits++;
    const bestOtherShare = Math.max(
      ...categories.filter((category) => category !== held.category)
        .map((category) => scores[category]!),
    );
    trialsByPrompt.push(Object.freeze({
      category: held.category,
      promptIndex: held.promptIndex,
      predicted,
      correct,
      ownShare: round(scores[held.category]!),
      bestOtherShare: round(bestOtherShare),
      scores: Object.freeze(Object.fromEntries(
        categories.map((category) => [category, round(scores[category]!)]),
      )),
    }));
  }
  return Object.freeze({
    topK,
    hits,
    trials: trialsByPrompt.length,
    accuracy: round(hits / trialsByPrompt.length),
    chance: round(1 / categories.length),
    protocol: "global leave-one-prompt-out",
    trialsByPrompt: Object.freeze(trialsByPrompt),
  });
}

export function glm52AtlasWebExperts(
  analysis: Glm52AtlasAnalysis,
): Readonly<Record<string, unknown>> {
  const experts: Record<string, unknown> = {};
  for (const expert of analysis.experts) {
    const entropy = -Object.values(expert.affinity).reduce(
      (value, probability) => value +
        (probability > 0 ? probability * Math.log2(probability) : 0),
      0,
    );
    experts[expertKey(expert.layer, expert.expert)] = Object.freeze({
      affinity: expert.affinity,
      entropy: round(entropy, 3),
      specialization: expert.specialization,
      top: expert.topTopic,
      label: expert.specialization >= analysis.method.strongThreshold
        ? `specialist: ${expert.topTopic}`
        : "generalist",
      total: expert.total,
      reliability: expert.reliability,
    });
  }
  return Object.freeze(experts);
}
