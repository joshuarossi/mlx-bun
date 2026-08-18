#!/usr/bin/env bun

/**
 * Controlled GLM-5.2 Expert Atlas sweep.
 *
 * One streamed model load is reused, but every probe receives a fresh KV cache
 * and an isolated route-trace segment. MTP, persistent usage, learning, PILOT,
 * hints, and sampling are all disabled so only accepted target routes count.
 */

import { createHash } from "node:crypto";
import {
  existsSync,
  mkdirSync,
  readFileSync,
  realpathSync,
  renameSync,
  statSync,
} from "node:fs";
import { join, resolve } from "node:path";
import { ChatTemplate } from "../src/chat-template";
import { gpuStream, type MlxArray } from "../src/mlx/array";
import {
  clearCache,
  maxRecommendedWorkingSetSize,
  setMemoryLimit,
  setWiredLimit,
  synchronize,
} from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import {
  glm52AtlasRunId,
  validateGlm52AtlasProbeSet,
} from "../src/model/glm52-atlas";
import { Glm52RouteTraceCollector } from "../src/model/glm52-coupling";
import { argmaxLastPosition } from "../src/model/gemma4-base";
import { Glm52Model } from "../src/model/glm52";
import { planGlm52MemoryForArtifact } from "../src/model/glm52-memory";
import { loadTokenizer } from "../src/tokenizer";

interface ProbeTask {
  readonly category: string;
  readonly promptIndex: number;
  readonly prompt: string;
  readonly tracePath: string;
}

interface ProbeResult {
  readonly category: string;
  readonly promptIndex: number;
  readonly promptTokens: number;
  readonly generatedTokens: number;
  readonly tokenIds: readonly number[];
  readonly traceRecords: number;
  readonly routeSelections: number;
  readonly wallMs: number;
}

function argumentsMap(argv: string[]): Map<string, string> {
  const values = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: probe-colibri-glm52-g6-atlas.ts --model DIR " +
        "--library DYLIB --output-dir DIR [--probes FILE " +
        "--max-tokens 1..128 --resume 0|1]",
      );
    }
    values.set(key.slice(2), value);
  }
  return values;
}

function required(values: Map<string, string>, key: string): string {
  const value = values.get(key);
  if (!value) throw new Error(`missing --${key}`);
  return resolve(value);
}

async function serialPrompt(
  model: Glm52Model,
  prompt: readonly number[],
  maxTokens: number,
  eosTokenIds: ReadonlySet<number>,
): Promise<number[]> {
  const cache = model.makeCache();
  const tokens: number[] = [];
  try {
    const promptIds = ops.fromInt32([...prompt], [1, prompt.length]);
    let hidden: MlxArray;
    try {
      hidden = await model.forwardHiddenAsync(promptIds, cache);
    } finally {
      promptIds.dispose();
    }
    let logits: MlxArray;
    try {
      logits = model.logitsFromHidden(hidden);
    } finally {
      hidden.dispose();
    }
    let pending = argmaxLastPosition(logits);
    logits.dispose();
    tokens.push(pending);
    synchronize(gpuStream);
    clearCache();

    while (tokens.length < maxTokens && !eosTokenIds.has(pending)) {
      const ids = ops.fromInt32([pending], [1, 1]);
      let nextHidden: MlxArray;
      try {
        nextHidden = await model.forwardHiddenAsync(ids, cache);
      } finally {
        ids.dispose();
      }
      let nextLogits: MlxArray;
      try {
        nextLogits = model.logitsFromHidden(nextHidden);
      } finally {
        nextHidden.dispose();
      }
      pending = argmaxLastPosition(nextLogits);
      nextLogits.dispose();
      tokens.push(pending);
      synchronize(gpuStream);
      clearCache();
    }
    return tokens;
  } finally {
    for (const layer of cache) layer.dispose();
  }
}

const cli = argumentsMap(Bun.argv.slice(2));
const modelDir = realpathSync(required(cli, "model"));
const libraryPath = realpathSync(required(cli, "library"));
const outputDir = required(cli, "output-dir");
const tracesDir = join(outputDir, "traces");
const manifestPath = join(outputDir, "manifest.json");
const probesPath = resolve(
  cli.get("probes") ?? "fixtures/colibri-glm52/atlas-probes.json",
);
const maxTokens = Number(cli.get("max-tokens") ?? "64");
const resume = cli.get("resume") === "1";
if (!Number.isSafeInteger(maxTokens) || maxTokens < 1 || maxTokens > 128)
  throw new Error("--max-tokens must be an integer in 1..128");
if (cli.has("resume") && cli.get("resume") !== "0" && !resume)
  throw new Error("--resume must be 0 or 1");

const probesText = readFileSync(probesPath, "utf8");
const probes = validateGlm52AtlasProbeSet(JSON.parse(probesText));
const probesSha256 = createHash("sha256").update(probesText).digest("hex");
mkdirSync(tracesDir, { recursive: true });
const tasks: ProbeTask[] = [];
for (const category of Object.keys(probes.categories).sort()) {
  const prompts = probes.categories[category]!;
  for (let promptIndex = 0; promptIndex < prompts.length; promptIndex++) {
    tasks.push({
      category,
      promptIndex,
      prompt: prompts[promptIndex]!,
      tracePath: join(tracesDir, `${category}_${promptIndex}.jsonl`),
    });
  }
}

const previous = existsSync(manifestPath)
  ? JSON.parse(readFileSync(manifestPath, "utf8")) as Record<string, unknown>
  : null;
if (previous) {
  if (!resume)
    throw new Error(`${manifestPath} exists; pass --resume 1 to continue`);
  if (previous.model !== modelDir || previous.probesSha256 !== probesSha256 ||
      previous.maxTokens !== maxTokens) {
    throw new Error("existing Atlas manifest does not match model/probes/options");
  }
}
const resultMap = new Map<string, ProbeResult>();
for (const value of (previous?.runs as ProbeResult[] | undefined) ?? [])
  resultMap.set(glm52AtlasRunId(value.category, value.promptIndex), value);
const pending = tasks.filter((task) => {
  const id = glm52AtlasRunId(task.category, task.promptIndex);
  const hasTrace = existsSync(task.tracePath) && statSync(task.tracePath).size > 0;
  const hasResult = resultMap.has(id);
  if (resume && hasTrace !== hasResult) {
    throw new Error(
      `incomplete Atlas checkpoint ${id}: trace=${hasTrace}, manifest=${hasResult}`,
    );
  }
  return !(resume && hasTrace && hasResult);
});
if (pending.length === 0) {
  console.log(`Atlas sweep already complete: ${tasks.length}/${tasks.length}`);
  process.exit(0);
}
for (const task of pending) {
  if (existsSync(task.tracePath))
    throw new Error(`${task.tracePath} exists; refusing to overwrite`);
}

const startedAt = typeof previous?.startedAt === "string"
  ? previous.startedAt
  : new Date().toISOString();
const writeManifest = async (completedAt?: string): Promise<void> => {
  const temp = `${manifestPath}.tmp-${process.pid}`;
  await Bun.write(temp, `${JSON.stringify({
    schemaVersion: 1,
    gate: "G6 GLM-5.2 Expert Atlas",
    model: modelDir,
    library: libraryPath,
    probesPath,
    probesSha256,
    probeProvenance: probes.provenance,
    maxTokens,
    controls: {
      mtp: false,
      persistentUsage: false,
      autoPin: false,
      liveRepin: false,
      pilot: false,
      routerPruning: false,
      temperature: 0,
      enableThinking: false,
      cacheIsolation: "fresh per prompt",
      routeIsolation: "one segment per prompt",
    },
    startedAt,
    ...(completedAt ? { completedAt } : {}),
    completedRuns: resultMap.size,
    expectedRuns: tasks.length,
    runs: [...resultMap.values()].sort((left, right) =>
      left.category.localeCompare(right.category) ||
      left.promptIndex - right.promptIndex),
  }, null, 2)}\n`);
  renameSync(temp, manifestPath);
};
await writeManifest();

let model: Glm52Model | null = null;
let oldMemoryLimit: number | null = null;
let oldWiredLimit: number | null = null;
let primaryError: unknown = null;
try {
  const [tokenizer, template, plan] = await Promise.all([
    loadTokenizer(modelDir),
    ChatTemplate.load(modelDir, { disableThinking: true }),
    planGlm52MemoryForArtifact(modelDir, {
      enableMtp: false,
      maxGenerationTokens: maxTokens,
    }),
  ]);
  oldMemoryLimit = setMemoryLimit(plan.lineItems.allocatorReserveBytes);
  oldWiredLimit = setWiredLimit(maxRecommendedWorkingSetSize());
  const routeTrace = new Glm52RouteTraceCollector();
  model = await Glm52Model.openStreamed(modelDir, {
    budgetBytes: plan.processLimitBytes,
    reserveBytes: plan.runtimeReserveBytes,
    workingSlots: plan.mainWorkingSlots,
    maxSlotsPerLayer: 1,
    workers: 2,
    libraryPath,
    decodeKernel: "metal",
    enableMtp: false,
    usagePath: false,
    autoPin: false,
    liveRepin: false,
    pilotMeasure: false,
    pilotHintK: 0,
    pilotTwoStep: false,
    routeObserver: (layer, routes) => routeTrace.observe(layer, routes),
  });
  const eosTokenIds = new Set(model.config.eosTokenIds);
  for (let taskIndex = 0; taskIndex < pending.length; taskIndex++) {
    const task = pending[taskIndex]!;
    const id = glm52AtlasRunId(task.category, task.promptIndex);
    const rendered = template.render(
      [{ role: "user", content: task.prompt }],
      { addGenerationPrompt: true, enableThinking: false },
    );
    let promptIds = tokenizer.encode(rendered);
    if (promptIds[0] === promptIds[1] &&
        promptIds[0] === tokenizer.bosTokenId) promptIds = promptIds.slice(1);
    if (promptIds.length === 0) throw new Error(`${id} encoded to zero tokens`);

    routeTrace.beginSegment(id);
    const before = routeTrace.snapshot().length;
    const wallStart = performance.now();
    const tokenIds = await serialPrompt(
      model,
      promptIds,
      maxTokens,
      eosTokenIds,
    );
    synchronize(gpuStream);
    clearCache();
    await model.expertRuntime!.finishUsage();
    const records = routeTrace.snapshot().slice(before);
    if (records.length === 0)
      throw new Error(`${id} produced no route records`);
    const routeSelections = records.reduce(
      (sum, record) => sum + record.indices.length,
      0,
    );
    const jsonl = records.map((record) => JSON.stringify(record)).join("\n");
    const traceTemp = `${task.tracePath}.tmp-${process.pid}`;
    await Bun.write(traceTemp, `${jsonl}\n`);
    renameSync(traceTemp, task.tracePath);
    const result: ProbeResult = Object.freeze({
      category: task.category,
      promptIndex: task.promptIndex,
      promptTokens: promptIds.length,
      generatedTokens: tokenIds.length,
      tokenIds: Object.freeze(tokenIds.slice()),
      traceRecords: records.length,
      routeSelections,
      wallMs: performance.now() - wallStart,
    });
    resultMap.set(id, result);
    await writeManifest();
    console.log(
      `[${resultMap.size}/${tasks.length}] ${id}: ` +
      `${promptIds.length}+${tokenIds.length} tokens, ` +
      `${routeSelections.toLocaleString()} selections`,
    );
  }
  await writeManifest(new Date().toISOString());
  console.log(`Atlas sweep complete: ${resultMap.size}/${tasks.length}`);
  console.log(
    `next: bun scripts/analyze-colibri-glm52-g6-atlas.ts ` +
    `--traces ${tracesDir} --output-dir ${join(outputDir, "analysis")}`,
  );
} catch (error) {
  primaryError = error;
  throw error;
} finally {
  const cleanupErrors: unknown[] = [];
  try {
    model?.dispose();
  } catch (error) {
    cleanupErrors.push(error);
  }
  try {
    synchronize(gpuStream);
    clearCache();
    if (oldWiredLimit !== null) setWiredLimit(oldWiredLimit);
    if (oldMemoryLimit !== null) setMemoryLimit(oldMemoryLimit);
  } catch (error) {
    cleanupErrors.push(error);
  }
  if (cleanupErrors.length) {
    throw new AggregateError(
      primaryError === null
        ? cleanupErrors
        : [primaryError, ...cleanupErrors],
      "GLM Atlas probe teardown failed",
    );
  }
}
