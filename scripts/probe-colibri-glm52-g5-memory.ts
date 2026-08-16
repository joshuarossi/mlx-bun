#!/usr/bin/env bun

/**
 * Manual G5 lane: one fresh process, two 128-token turns, one MTP mode.
 *
 * The header-only resource plan is evaluated before resident weights or expert
 * slabs are opened. Run the on and off modes as separate processes, then feed
 * both JSON reports to check-colibri-glm52-g5-memory.ts.
 */

import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import directTrace from "../fixtures/colibri-glm52/g4-direct-mtp-trace.json";
import oracle from "../fixtures/colibri-glm52/real-model-oracle.json";
import {
  G5_FLAT_MEMORY_TOLERANCE_BYTES,
  G5_MAX_COMPRESSOR_GROWTH_BYTES,
  G5_MAX_PHYSICAL_FOOTPRINT_BYTES,
  G5_MAX_TOKENS,
  G5MemoryContractError,
  G5MemoryMonitor,
  type G5EnvironmentSample,
  type G5MeasurementMode,
  type G5TurnReport,
} from "./lib/g5-memory-contract";
import {
  parseSwapUsage,
  parseVmStat,
} from "./lib/g3-live-guard";
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

const SAMPLE_INTERVAL_MS = 15_000;

type Mode = "on" | "off";
type TurnName = "cold" | "warm";

function argumentsMap(argv: string[]): Map<string, string> {
  const out = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: probe-colibri-glm52-g5-memory.ts " +
        "--mode on|off --model DIR --library DYLIB --output FILE " +
        "--trace FILE [--memory-mode strict|observe] " +
        "[--usage-path FILE --auto-pin 0|1 --live-repin 0|1] " +
        "[--pilot-measure 0|1]",
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

function command(command: readonly string[]): string {
  const result = Bun.spawnSync([...command], {
    stdout: "pipe",
    stderr: "pipe",
  });
  if (result.exitCode !== 0)
    throw new Error(new TextDecoder().decode(result.stderr));
  return new TextDecoder().decode(result.stdout);
}

function residency(
  manager:
    | NonNullable<Glm52Model["expertRuntime"]>["manager"]
    | undefined,
): Record<string, number | string> | null {
  if (!manager) return null;
  const snapshot = manager.snapshot();
  return {
    working: snapshot.working,
    resident: snapshot.resident,
    pinned: snapshot.pinned,
    disabled: snapshot.disabled,
    loading: snapshot.loading,
    leased: snapshot.leased,
    hits: snapshot.hits,
    misses: snapshot.misses,
    evictions: snapshot.evictions,
    pressureEvictions: snapshot.pressureEvictions,
    clock: snapshot.clock.toString(),
    generation: snapshot.generation.toString(),
  };
}

function environment(model: Glm52Model | null): G5EnvironmentSample {
  const runtime = model?.expertRuntime;
  const rss = process.memoryUsage().rss;
  return {
    vm: parseVmStat(command(["/usr/bin/vm_stat"])),
    swapUsage: parseSwapUsage(
      command(["/usr/sbin/sysctl", "-n", "vm.swapusage"]),
    ),
    processRssBytes: rss,
    // Before the native store exists RSS is the best available lower-bound
    // sample. Every post-open sample uses task-wide phys_footprint.
    physicalFootprintBytes:
      runtime?.store.physicalFootprint() ?? rss,
    processCompressedBytes: runtime?.store.compressedMemory() ?? 0,
    mlxActiveBytes: activeMemory(),
    mlxCacheBytes: cacheMemory(),
    mlxPeakBytes: peakMemory(),
    mainResidency: residency(runtime?.manager),
    mtpResidency: residency(runtime?.mtp?.manager),
  };
}

async function serialTarget(
  model: Glm52Model,
  prompt: readonly number[],
  maxTokens: number,
  onToken: (token: number) => boolean,
): Promise<{
  tokens: number[];
  prefillMs: number;
  decodeMs: number;
  decodeTps: number;
}> {
  const cache = model.makeCache();
  const tokens: number[] = [];
  try {
    const promptIds = ops.fromInt32([...prompt], [1, prompt.length]);
    const prefillStart = performance.now();
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
    synchronize(gpuStream);
    clearCache();
    const prefillMs = performance.now() - prefillStart;
    tokens.push(pending);
    if (!onToken(pending)) {
      return { tokens, prefillMs, decodeMs: 0, decodeTps: 0 };
    }

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
      if (!onToken(pending)) break;
    }
    const decodeMs = performance.now() - decodeStart;
    return {
      tokens,
      prefillMs,
      decodeMs,
      decodeTps:
        tokens.length > 1
          ? ((tokens.length - 1) / Math.max(decodeMs, 1e-6)) * 1000
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
  const mismatch = actual.findIndex(
    (token, index) => token !== expected[index],
  );
  if (actual.length !== expected.length || mismatch >= 0) {
    const index = mismatch >= 0
      ? mismatch
      : Math.min(actual.length, expected.length);
    throw new Error(
      `${label} token mismatch at ${index}: ` +
      `${actual[index] ?? "<missing>"} != ${expected[index] ?? "<end>"}`,
    );
  }
}

const cli = argumentsMap(Bun.argv.slice(2));
const mode = cli.get("mode") as Mode | undefined;
if (mode !== "on" && mode !== "off")
  throw new Error("--mode must be on or off");
const measurementMode = (cli.get("memory-mode") ?? "strict") as
  G5MeasurementMode;
if (measurementMode !== "strict" && measurementMode !== "observe") {
  throw new Error("--memory-mode must be strict or observe");
}
const enforceMemoryContract = measurementMode === "strict";
const modelDir = required(cli, "model");
const libraryPath = required(cli, "library");
const output = required(cli, "output");
const tracePath = required(cli, "trace");
const usagePath = cli.get("usage-path")
  ? resolve(cli.get("usage-path")!)
  : null;
const autoPin = cli.get("auto-pin") === "1";
const liveRepin = cli.get("live-repin") === "1";
const pilotMeasure = cli.get("pilot-measure") === "1";
if ((autoPin || liveRepin) && !usagePath)
  throw new Error("--auto-pin/--live-repin require --usage-path");
mkdirSync(dirname(output), { recursive: true });
mkdirSync(dirname(tracePath), { recursive: true });
if (usagePath) mkdirSync(dirname(usagePath), { recursive: true });

let model: Glm52Model | null = null;
let plan: Glm52MemoryPlan | null = null;
let monitor: G5MemoryMonitor | null = null;
let pendingMonitorError: unknown = null;
let currentTurn: TurnName | undefined;
let generatedTokens = 0;
let interval: ReturnType<typeof setInterval> | null = null;
let oldMemoryLimit: number | null = null;
let oldWiredLimit: number | null = null;
let wiredLimitBytes: number | null = null;
let primaryError: unknown = null;
let openMs: number | null = null;
const turns: Array<G5TurnReport & {
  speculation: unknown;
  finalMemory: G5EnvironmentSample;
  expertTelemetry: unknown;
  repin: unknown;
  tierMap: unknown;
}> = [];

try {
  monitor = new G5MemoryMonitor({
    tracePath,
    maxPhysicalFootprintBytes: G5_MAX_PHYSICAL_FOOTPRINT_BYTES,
    maxCompressorGrowthBytes: G5_MAX_COMPRESSOR_GROWTH_BYTES,
    sample: () => environment(model),
  });
  plan = await planGlm52MemoryForArtifact(modelDir, {
    enableMtp: mode === "on",
    maxGenerationTokens: G5_MAX_TOKENS,
    mtpDraftTokens: directTrace.request.draft_tokens,
  });
  monitor.record({
    phase: "preflight_passed",
    note: `${plan.plannedProcessBytes} planned process bytes`,
  }, enforceMemoryContract);
  oldMemoryLimit = setMemoryLimit(plan.lineItems.allocatorReserveBytes);
  // This harness calls the serial/spec loops directly rather than generate().
  // Hold the same scoped MLX wired limit as the production execution path.
  wiredLimitBytes = maxRecommendedWorkingSetSize();
  oldWiredLimit = setWiredLimit(wiredLimitBytes);
  resetPeakMemory();

  const openStart = performance.now();
  model = await Glm52Model.openStreamed(modelDir, {
    budgetBytes: plan.processLimitBytes,
    reserveBytes: plan.runtimeReserveBytes,
    workingSlots: plan.mainWorkingSlots,
    maxSlotsPerLayer: 1,
    usagePath: usagePath ?? false,
    autoPin,
    liveRepin,
    pilotMeasure,
    workers: 2,
    libraryPath,
    decodeKernel: "metal",
    enableMtp: mode === "on",
    mtpDraftTokens: plan.mtpDraftTokens,
  });
  openMs = performance.now() - openStart;
  const runtime = model.expertRuntime!;
  if (!autoPin && runtime.plan.plannedBytes !== plan.plannedProcessBytes) {
    throw new Error(
      `runtime plan ${runtime.plan.plannedBytes} != G5 resource equation ` +
      `${plan.plannedProcessBytes}`,
    );
  }
  if (autoPin && runtime.plan.plannedBytes > plan.processLimitBytes) {
    throw new Error(
      `learning runtime plan ${runtime.plan.plannedBytes} exceeds process limit ` +
      `${plan.processLimitBytes}`,
    );
  }
  if (!autoPin &&
    (runtime.mtp?.plan.slabBytes ?? 0) !==
    plan.lineItems.mtpExpertSlabBytes
  ) {
    throw new Error("runtime MTP slab does not match the G5 resource equation");
  }
  monitor.record({
    phase: "model_opened",
    note: `${openMs.toFixed(3)} ms`,
  }, enforceMemoryContract);

  interval = setInterval(() => {
    if (pendingMonitorError !== null) return;
    try {
      monitor!.record({
        phase: "periodic",
        ...(currentTurn ? { turn: currentTurn } : {}),
        generatedTokens,
      }, enforceMemoryContract);
    } catch (error) {
      pendingMonitorError = error;
    }
  }, SAMPLE_INTERVAL_MS);

  let coldTokens: readonly number[] | null = null;
  for (const turn of ["cold", "warm"] as const) {
    currentTurn = turn;
    generatedTokens = 0;
    pendingMonitorError = null;
    monitor.record(
      { phase: "turn_start", turn },
      enforceMemoryContract,
    );
    const wallStart = performance.now();
    let tokens: number[] = [];
    let timing: Omit<
      G5TurnReport["timing"],
      "wallMs" | "endToEndTps"
    >;
    let speculation: unknown = null;
    const onToken = (token: number): boolean => {
      tokens.push(token);
      generatedTokens = tokens.length;
      if (tokens.length % 8 === 0)
        console.log(
          `G5 ${mode} ${turn}: ${tokens.length}/${G5_MAX_TOKENS}`,
        );
      return pendingMonitorError === null;
    };

    if (mode === "on") {
      const provider = new Glm52NativeMtpProvider(model);
      const stats = await specServeRun(
        model,
        provider,
        plan.mtpDraftTokens,
        [...oracle.evidence.teacher_forcing_prefix_ids],
        {
          maxTokens: G5_MAX_TOKENS,
          temperature: 0,
          eosTokenIds: [],
        },
        onToken,
      );
      const spec = stats.spec;
      speculation = spec
        ? {
            drafted: spec.drafted,
            accepted: spec.accepted,
            rejected: spec.rejected ?? spec.drafted - spec.accepted,
            verifyForwards: spec.rounds ?? spec.targetCalls - 1,
            acceptanceLengths: [...(spec.acceptanceLengths ?? [])],
            tokensPerForward: spec.tokensPerForward ?? 0,
            forwardsSaved: spec.forwardsSaved ?? 0,
          }
        : null;
      timing = {
        prefillMs: stats.prefillMs,
        decodeMs: stats.decodeMs,
        decodeTps: stats.decodeTps,
      };
    } else {
      // serialTarget owns its token array; avoid double-pushing via onToken.
      const serial = await serialTarget(
        model,
        oracle.evidence.teacher_forcing_prefix_ids,
        G5_MAX_TOKENS,
        (token) => {
          generatedTokens++;
          if (generatedTokens % 8 === 0)
            console.log(
              `G5 ${mode} ${turn}: ${generatedTokens}/${G5_MAX_TOKENS}`,
            );
          return pendingMonitorError === null;
        },
      );
      tokens = serial.tokens;
      timing = {
        prefillMs: serial.prefillMs,
        decodeMs: serial.decodeMs,
        decodeTps: serial.decodeTps,
      };
    }
    if (pendingMonitorError !== null)
      throw pendingMonitorError;
    exact(
      tokens.slice(0, directTrace.token_ids.length),
      directTrace.token_ids,
      `G5 ${mode} ${turn} direct-oracle prefix`,
    );
    if (tokens.length !== G5_MAX_TOKENS)
      throw new Error(`G5 ${mode} ${turn} emitted ${tokens.length} tokens`);
    if (coldTokens) exact(tokens, coldTokens, `G5 ${mode} cold/warm`);
    else coldTokens = [...tokens];

    synchronize(gpuStream);
    clearCache();
    await runtime.finishUsage();
    const finalCheckpoint = monitor.record({
      phase: "turn_complete",
      turn,
      generatedTokens: tokens.length,
    }, enforceMemoryContract);
    const wallMs = performance.now() - wallStart;
    turns.push({
      name: turn,
      tokenIds: [...tokens],
      timing: {
        ...timing,
        wallMs,
        endToEndTps:
          (G5_MAX_TOKENS / Math.max(wallMs, 1e-6)) * 1000,
      },
      finalPhysicalFootprintBytes:
        finalCheckpoint.physicalFootprintBytes,
      speculation,
      finalMemory: environment(model),
      expertTelemetry: runtime.lastTelemetry,
      repin: runtime.lastRepin,
      tierMap: {
        main: runtime.manager.residencyMap().map((entry) => ({
          ...entry,
          lastUse: entry.lastUse.toString(),
        })),
        mtp: runtime.mtp?.manager.residencyMap().map((entry) => ({
          ...entry,
          lastUse: entry.lastUse.toString(),
        })) ?? null,
      },
    });
  }
  currentTurn = undefined;
  if (interval) {
    clearInterval(interval);
    interval = null;
  }
  const final = monitor.record(
    { phase: "complete" },
    enforceMemoryContract,
  );
  const cold = turns[0]!;
  const warm = turns[1]!;
  if (enforceMemoryContract &&
    warm.finalPhysicalFootprintBytes >
    cold.finalPhysicalFootprintBytes + G5_FLAT_MEMORY_TOLERANCE_BYTES
  ) {
    throw new Error(
      `G5 ${mode} cold-to-warm footprint grew by ` +
      `${warm.finalPhysicalFootprintBytes -
        cold.finalPhysicalFootprintBytes} bytes`,
    );
  }
  const report = {
    schemaVersion: 1 as const,
    gate: "G5 32 GB memory contract" as const,
    mode,
    measurementMode,
    result: "pass" as const,
    contract: {
      processLimitBytes: plan.processLimitBytes,
      maxCompressorGrowthBytes: G5_MAX_COMPRESSOR_GROWTH_BYTES,
      flatMemoryToleranceBytes: G5_FLAT_MEMORY_TOLERANCE_BYTES,
      maxTokens: G5_MAX_TOKENS,
      sampleIntervalMs: SAMPLE_INTERVAL_MS,
      wiredLimitBytes,
    },
    plan,
    runtime: {
      openMs,
      mainPlan: runtime.plan,
      mtpPlan: runtime.mtp?.plan ?? null,
      usagePath,
      autoPin: runtime.autoPin,
      autoPinEnabled: autoPin,
      liveRepinEnabled: liveRepin,
      pilotMeasureEnabled: pilotMeasure,
      usage: runtime.usage?.snapshot() ?? null,
    },
    turns,
    memory: {
      maxPhysicalFootprintBytes:
        monitor.maxObservedPhysicalFootprintBytes,
      maxCompressorDeltaBytes:
        monitor.maxObservedCompressorDeltaBytes,
      maxProcessCompressedDeltaBytes:
        monitor.maxObservedProcessCompressedDeltaBytes,
      swapoutDeltaBytes: final.swapoutDeltaBytes,
      baseline: monitor.baseline,
      final,
      tracePath,
    },
  };
  await Bun.write(output, `${JSON.stringify(report, null, 2)}\n`);
  console.log(
    `G5 ${mode}: ${enforceMemoryContract ? "PASS" : "OBSERVED"}; warm e2e ` +
    `${warm.timing.endToEndTps.toFixed(3)} tok/s; ` +
    `decode ${warm.timing.decodeTps.toFixed(3)} tok/s; ` +
    `peak ${(report.memory.maxPhysicalFootprintBytes / 1024 ** 3)
      .toFixed(3)} GiB`,
  );
} catch (error) {
  primaryError = error;
  if (interval) {
    clearInterval(interval);
    interval = null;
  }
  const report = {
    schemaVersion: 1,
    gate: "G5 32 GB memory contract",
    mode,
    measurementMode,
    result: "error",
    error: error instanceof Error ? error.message : String(error),
    ...(error instanceof G5MemoryContractError
      ? { violatingCheckpoint: error.checkpoint }
      : {}),
    plan,
    turns,
    memory: monitor
      ? {
          maxPhysicalFootprintBytes:
            monitor.maxObservedPhysicalFootprintBytes,
          maxCompressorDeltaBytes:
            monitor.maxObservedCompressorDeltaBytes,
          maxProcessCompressedDeltaBytes:
            monitor.maxObservedProcessCompressedDeltaBytes,
          baseline: monitor.baseline,
          tracePath,
        }
      : null,
  };
  await Bun.write(output, `${JSON.stringify(report, null, 2)}\n`);
  throw error;
} finally {
  if (interval) clearInterval(interval);
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
      "G5 probe teardown failed",
    );
  }
}
