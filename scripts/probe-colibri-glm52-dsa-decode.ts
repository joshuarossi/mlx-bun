#!/usr/bin/env bun

/**
 * One fresh-process Stage-2 decode cell. Long prompt construction uses the
 * explicitly bounded dense-benchmark seam; every token after that boundary,
 * including native-MTP verification rows, uses the normal exact DSA path.
 */

import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { gpuStream, type MlxArray } from "../src/mlx/array";
import {
  activeMemory,
  cacheMemory,
  clearCache,
  maxRecommendedWorkingSetSize,
  peakMemory,
  resetPeakMemory,
  setMemoryLimit,
  setWiredLimit,
  synchronize,
} from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { argmaxLastPosition } from "../src/model/gemma4-base";
import { Glm52Model } from "../src/model/glm52";
import {
  planGlm52MemoryForArtifact,
  type Glm52MemoryPlan,
} from "../src/model/glm52-memory";
import { Glm52NativeMtpProvider } from "../src/spec/glm52-mtp-source";
import { specServeRun } from "../src/spec/serve-loop";
import { loadTokenizer } from "../src/tokenizer";
import { parseSwapUsage, parseVmStat } from "./lib/g3-live-guard";

type Toggle = "on" | "off";
type TurnName = "cold" | "warm";

function argumentsMap(argv: string[]): Map<string, string> {
  const out = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: probe-colibri-glm52-dsa-decode.ts " +
        "--model DIR --library DYLIB --output FILE --context N " +
        "--dsa on|off --mtp on|off [--repeat N --max-tokens N]",
      );
    }
    out.set(key.slice(2), value);
  }
  return out;
}

function required(values: Map<string, string>, key: string): string {
  const value = values.get(key);
  if (!value) throw new Error(`missing --${key}`);
  return resolve(value);
}

function positiveInteger(value: string | undefined, label: string): number {
  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed) || parsed < 1)
    throw new Error(`${label} must be a positive integer`);
  return parsed;
}

function command(command: readonly string[]): string {
  const result = Bun.spawnSync([...command], { stdout: "pipe", stderr: "pipe" });
  if (result.exitCode !== 0)
    throw new Error(new TextDecoder().decode(result.stderr));
  return new TextDecoder().decode(result.stdout);
}

function memory(model: Glm52Model | null) {
  const runtime = model?.expertRuntime;
  return {
    at: new Date().toISOString(),
    processRssBytes: process.memoryUsage().rss,
    physicalFootprintBytes: runtime?.store.physicalFootprint() ?? null,
    compressedBytes: runtime?.store.compressedMemory() ?? null,
    mlxActiveBytes: activeMemory(),
    mlxCacheBytes: cacheMemory(),
    mlxPeakBytes: peakMemory(),
    swapUsage: parseSwapUsage(
      command(["/usr/sbin/sysctl", "-n", "vm.swapusage"]),
    ),
    vm: parseVmStat(command(["/usr/bin/vm_stat"])),
    mainResidency: runtime?.manager.snapshot() ?? null,
    mtpResidency: runtime?.mtp?.manager.snapshot() ?? null,
  };
}

async function serialTarget(
  model: Glm52Model,
  prompt: readonly number[],
  maxTokens: number,
): Promise<{
  tokens: number[];
  prefillMs: number;
  decodeMs: number;
  decodeTps: number;
}> {
  const cache = model.makeCache();
  const tokens: number[] = [];
  try {
    const prefillStart = performance.now();
    let hidden: MlxArray | null = null;
    for (let offset = 0; offset < prompt.length; offset += 2048) {
      const chunk = prompt.slice(offset, offset + 2048);
      const promptIds = ops.fromInt32([...chunk], [1, chunk.length]);
      try {
        const next = await model.forwardHiddenAsync(promptIds, cache);
        hidden?.dispose();
        hidden = next;
      } finally {
        promptIds.dispose();
      }
      clearCache();
    }
    let logits: MlxArray;
    try {
      logits = model.logitsFromHidden(hidden!);
    } finally {
      hidden?.dispose();
    }
    let pending = argmaxLastPosition(logits);
    logits.dispose();
    synchronize(gpuStream);
    clearCache();
    const prefillMs = performance.now() - prefillStart;
    tokens.push(pending);

    const decodeStart = performance.now();
    while (tokens.length < maxTokens) {
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
    const decodeMs = performance.now() - decodeStart;
    return {
      tokens,
      prefillMs,
      decodeMs,
      decodeTps: maxTokens > 1
        ? ((maxTokens - 1) / Math.max(decodeMs, 1e-6)) * 1000
        : 0,
    };
  } finally {
    for (const layer of cache) layer.dispose();
  }
}

function exact(
  actual: readonly number[],
  expected: readonly number[],
  label: string,
): void {
  const mismatch = actual.findIndex((token, index) => token !== expected[index]);
  if (actual.length !== expected.length || mismatch >= 0) {
    const index = mismatch >= 0 ? mismatch : Math.min(actual.length, expected.length);
    throw new Error(
      `${label} token mismatch at ${index}: ` +
      `${actual[index] ?? "<missing>"} != ${expected[index] ?? "<end>"}`,
    );
  }
}

const cli = argumentsMap(Bun.argv.slice(2));
const modelDir = required(cli, "model");
const libraryPath = required(cli, "library");
const output = required(cli, "output");
const contextTokens = positiveInteger(cli.get("context"), "--context");
const repeat = positiveInteger(cli.get("repeat") ?? "1", "--repeat");
const maxTokens = positiveInteger(cli.get("max-tokens") ?? "16", "--max-tokens");
const dsa = cli.get("dsa") as Toggle | undefined;
const mtp = cli.get("mtp") as Toggle | undefined;
if (dsa !== "on" && dsa !== "off") throw new Error("--dsa must be on or off");
if (mtp !== "on" && mtp !== "off") throw new Error("--mtp must be on or off");
if (contextTokens < 2) throw new Error("--context must be at least 2");
mkdirSync(dirname(output), { recursive: true });

const draftTokens = 3;
let plan: Glm52MemoryPlan | null = null;
let model: Glm52Model | null = null;
let oldMemoryLimit: number | null = null;
let oldWiredLimit: number | null = null;
let primaryError: unknown = null;
const turns: Array<Record<string, unknown>> = [];
const before = memory(null);

try {
  plan = await planGlm52MemoryForArtifact(modelDir, {
    contextTokens: contextTokens + maxTokens + draftTokens + 1,
    maxGenerationTokens: maxTokens,
    enableMtp: mtp === "on",
    mtpDraftTokens: draftTokens,
  });
  oldMemoryLimit = setMemoryLimit(plan.lineItems.allocatorReserveBytes);
  oldWiredLimit = setWiredLimit(maxRecommendedWorkingSetSize());
  resetPeakMemory();

  const tokenizer = await loadTokenizer(modelDir);
  const promptText = "[gMASK]<sop>" + " a".repeat(contextTokens - 2);
  const prompt = tokenizer.encode(promptText, false);
  if (prompt.length !== contextTokens) {
    throw new Error(
      `deterministic prompt encoded to ${prompt.length}, expected ${contextTokens}`,
    );
  }

  const openStart = performance.now();
  model = await Glm52Model.openStreamed(modelDir, {
    budgetBytes: plan.processLimitBytes,
    reserveBytes: plan.runtimeReserveBytes,
    workingSlots: plan.mainWorkingSlots,
    maxSlotsPerLayer: 1,
    usagePath: false,
    workers: 2,
    libraryPath,
    decodeKernel: "metal",
    enableMtp: mtp === "on",
    mtpDraftTokens: plan.mtpDraftTokens,
    enableDsa: dsa === "on",
    ...(dsa === "on"
      ? {
          dsaPrefillMode: "dense-benchmark" as const,
          dsaBenchmarkPrefillTokens: contextTokens,
        }
      : {}),
  });
  const openMs = performance.now() - openStart;
  if (model.capabilities.dsa !== (dsa === "on"))
    throw new Error(`runtime DSA capability did not match --dsa ${dsa}`);
  if ((model.capabilities.mtpEnabled !== false) !== (mtp === "on"))
    throw new Error(`runtime MTP capability did not match --mtp ${mtp}`);
  const opened = memory(model);

  let coldTokens: readonly number[] | null = null;
  for (const name of ["cold", "warm"] as const satisfies readonly TurnName[]) {
    const turnBefore = memory(model);
    const wallStart = performance.now();
    let tokens: number[];
    let prefillMs: number;
    let decodeMs: number;
    let decodeTps: number;
    let speculation: unknown = null;

    if (mtp === "on") {
      const provider = new Glm52NativeMtpProvider(model);
      tokens = [];
      const stats = await specServeRun(
        model,
        provider,
        plan.mtpDraftTokens,
        [...prompt],
        { maxTokens, temperature: 0, eosTokenIds: [] },
        (token) => { tokens.push(token); },
      );
      prefillMs = stats.prefillMs;
      decodeMs = stats.decodeMs;
      decodeTps = stats.decodeTps;
      speculation = stats.spec;
    } else {
      const serial = await serialTarget(model, prompt, maxTokens);
      ({ tokens, prefillMs, decodeMs, decodeTps } = serial);
    }
    if (tokens.length !== maxTokens)
      throw new Error(`${name} emitted ${tokens.length}/${maxTokens} tokens`);
    if (coldTokens) exact(tokens, coldTokens, `${dsa}/${mtp} cold/warm`);
    else coldTokens = [...tokens];
    synchronize(gpuStream);
    clearCache();
    await model.expertRuntime!.finishUsage();
    const wallMs = performance.now() - wallStart;
    turns.push({
      name,
      tokenIds: [...tokens],
      timing: {
        prefillMs,
        decodeMs,
        decodeTps,
        wallMs,
        endToEndTps: (maxTokens / Math.max(wallMs, 1e-6)) * 1000,
      },
      speculation,
      expertTelemetry: model.expertRuntime!.lastTelemetry,
      before: turnBefore,
      after: memory(model),
    });
    console.log(
      `stage2 c=${contextTokens} dsa=${dsa} mtp=${mtp} r=${repeat} ` +
      `${name}: ${decodeTps.toFixed(3)} tok/s`,
    );
  }

  await Bun.write(output, JSON.stringify({
    schemaVersion: 1,
    gate: "G6R Stage 2 DSA decode matrix cell",
    result: "pass",
    cell: { contextTokens, dsa, mtp, repeat, maxTokens, draftTokens },
    scope: {
      performanceClaim: "decode only",
      promptConstruction: dsa === "on"
        ? "dense batched through exact prompt boundary"
        : "dense attention control",
      postPromptDsa: dsa === "on" ? "exact sparse" : "disabled",
      indexerWeightsMappedInBothDsaArms: true,
      expertPolicy: {
        workingSlots: plan.mainWorkingSlots,
        maxSlotsPerLayer: 1,
        workers: 2,
        decodeKernel: "metal",
        usagePath: false,
      },
    },
    plan,
    runtime: {
      openMs,
      capabilities: model.capabilities,
      dsaPrefillMode: model.dsaPrefillMode,
      dsaBenchmarkPrefillTokens: model.dsaBenchmarkPrefillTokens,
      mainPlan: model.expertRuntime!.plan,
      mtpPlan: model.expertRuntime!.mtp?.plan ?? null,
    },
    turns,
    memory: { before, opened, final: memory(model) },
  }, (_key, value) => typeof value === "bigint" ? value.toString() : value, 2) + "\n");
} catch (error) {
  primaryError = error;
  await Bun.write(output, JSON.stringify({
    schemaVersion: 1,
    gate: "G6R Stage 2 DSA decode matrix cell",
    result: "error",
    cell: { contextTokens, dsa, mtp, repeat, maxTokens },
    error: error instanceof Error ? error.message : String(error),
    plan,
    turns,
    memory: { before, failed: memory(model) },
  }, (_key, value) => typeof value === "bigint" ? value.toString() : value, 2) + "\n");
  throw error;
} finally {
  const cleanupErrors: unknown[] = [];
  try { model?.dispose(); } catch (error) { cleanupErrors.push(error); }
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
      primaryError === null ? cleanupErrors : [primaryError, ...cleanupErrors],
      "Stage-2 DSA decode cell teardown failed",
    );
  }
}
