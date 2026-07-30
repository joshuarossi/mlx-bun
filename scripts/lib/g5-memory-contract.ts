import {
  appendFileSync,
  mkdirSync,
  writeFileSync,
} from "node:fs";
import { dirname } from "node:path";
import type {
  SwapUsage,
  VmStatCounters,
} from "./g3-live-guard";

export const G5_MAX_TOKENS = 128;
export const G5_MAX_PHYSICAL_FOOTPRINT_BYTES = 25 * 1024 ** 3;
export const G5_MAX_COMPRESSOR_GROWTH_BYTES = 256 * 1024 ** 2;
export const G5_FLAT_MEMORY_TOLERANCE_BYTES = 256 * 1024 ** 2;

export interface G5EnvironmentSample {
  readonly vm: VmStatCounters;
  readonly swapUsage: SwapUsage;
  readonly processRssBytes: number;
  readonly physicalFootprintBytes: number;
  readonly mlxActiveBytes: number;
  readonly mlxCacheBytes: number;
  readonly mlxPeakBytes: number;
  readonly mainResidency: Record<string, number | string> | null;
  readonly mtpResidency: Record<string, number | string> | null;
}

export interface G5CheckpointContext {
  readonly phase: string;
  readonly turn?: "cold" | "warm";
  readonly generatedTokens?: number;
  readonly note?: string;
}

export interface G5MemoryCheckpoint
extends G5CheckpointContext, G5EnvironmentSample {
  readonly sequence: number;
  readonly elapsedMs: number;
  readonly swapoutDeltaBytes: number;
  readonly compressorDeltaBytes: number;
  readonly compressionCountDelta: number;
  readonly maxPhysicalFootprintBytes: number;
  readonly maxCompressorGrowthBytes: number;
  readonly violations: readonly string[];
}

export class G5MemoryContractError extends Error {
  readonly checkpoint: G5MemoryCheckpoint;

  constructor(checkpoint: G5MemoryCheckpoint) {
    super(
      `G5 memory contract tripped at ${checkpoint.phase}: ` +
      checkpoint.violations.join("; "),
    );
    this.name = "G5MemoryContractError";
    this.checkpoint = checkpoint;
  }
}

export interface G5MemoryMonitorOptions {
  readonly tracePath: string;
  readonly maxPhysicalFootprintBytes: number;
  readonly maxCompressorGrowthBytes: number;
  readonly sample: () => G5EnvironmentSample;
  readonly now?: () => number;
}

/**
 * Low-frequency process/system monitor for the manual G5 gate. It treats
 * swapout as a zero-tolerance violation and allows only a documented bounded
 * increase in system-wide compressor occupancy.
 */
export class G5MemoryMonitor {
  readonly tracePath: string;
  readonly maxPhysicalFootprintBytes: number;
  readonly maxCompressorGrowthBytes: number;
  readonly baseline: G5EnvironmentSample;
  #sample: G5MemoryMonitorOptions["sample"];
  #now: () => number;
  #startedAt: number;
  #sequence = 0;
  #tripped: G5MemoryCheckpoint | null = null;
  #maxObservedPhysicalFootprintBytes = 0;
  #maxObservedCompressorDeltaBytes = 0;

  constructor(options: G5MemoryMonitorOptions) {
    for (const [label, value] of [
      ["maxPhysicalFootprintBytes", options.maxPhysicalFootprintBytes],
      ["maxCompressorGrowthBytes", options.maxCompressorGrowthBytes],
    ] as const) {
      if (!Number.isSafeInteger(value) || value < 0)
        throw new RangeError(`${label} must be a non-negative safe integer`);
    }
    this.tracePath = options.tracePath;
    this.maxPhysicalFootprintBytes = options.maxPhysicalFootprintBytes;
    this.maxCompressorGrowthBytes = options.maxCompressorGrowthBytes;
    this.#sample = options.sample;
    this.#now = options.now ?? performance.now.bind(performance);
    this.#startedAt = this.#now();
    this.baseline = this.#sample();
    mkdirSync(dirname(this.tracePath), { recursive: true });
    writeFileSync(this.tracePath, "");
    this.record({ phase: "baseline" });
  }

  get tripped(): G5MemoryCheckpoint | null {
    return this.#tripped;
  }

  get maxObservedPhysicalFootprintBytes(): number {
    return this.#maxObservedPhysicalFootprintBytes;
  }

  get maxObservedCompressorDeltaBytes(): number {
    return this.#maxObservedCompressorDeltaBytes;
  }

  record(
    context: G5CheckpointContext,
    enforce = false,
  ): G5MemoryCheckpoint {
    const sample = this.#sample();
    if (sample.vm.pageSizeBytes !== this.baseline.vm.pageSizeBytes)
      throw new Error("vm_stat page size changed during G5 probe");
    const swapoutDeltaPages =
      sample.vm.swapouts - this.baseline.vm.swapouts;
    if (swapoutDeltaPages < 0)
      throw new Error("vm_stat swapout counter moved backwards");
    const swapoutDeltaBytes =
      swapoutDeltaPages * sample.vm.pageSizeBytes;
    const compressorDeltaBytes =
      (
        sample.vm.compressorPages -
        this.baseline.vm.compressorPages
      ) * sample.vm.pageSizeBytes;
    const compressionCountDelta =
      sample.vm.compressions - this.baseline.vm.compressions;
    this.#maxObservedPhysicalFootprintBytes = Math.max(
      this.#maxObservedPhysicalFootprintBytes,
      sample.physicalFootprintBytes,
    );
    this.#maxObservedCompressorDeltaBytes = Math.max(
      this.#maxObservedCompressorDeltaBytes,
      compressorDeltaBytes,
    );
    const violations: string[] = [];
    if (sample.physicalFootprintBytes > this.maxPhysicalFootprintBytes) {
      violations.push(
        `physical footprint ${sample.physicalFootprintBytes} > ` +
        `${this.maxPhysicalFootprintBytes}`,
      );
    }
    if (swapoutDeltaBytes > 0)
      violations.push(`swapout grew by ${swapoutDeltaBytes} bytes`);
    if (compressorDeltaBytes > this.maxCompressorGrowthBytes) {
      violations.push(
        `compressor occupancy grew by ${compressorDeltaBytes} bytes > ` +
        `${this.maxCompressorGrowthBytes}`,
      );
    }
    const checkpoint: G5MemoryCheckpoint = {
      ...context,
      ...sample,
      sequence: this.#sequence++,
      elapsedMs: this.#now() - this.#startedAt,
      swapoutDeltaBytes,
      compressorDeltaBytes,
      compressionCountDelta,
      maxPhysicalFootprintBytes: this.maxPhysicalFootprintBytes,
      maxCompressorGrowthBytes: this.maxCompressorGrowthBytes,
      violations,
    };
    appendFileSync(this.tracePath, `${JSON.stringify(checkpoint)}\n`);
    if (violations.length > 0 && this.#tripped === null)
      this.#tripped = checkpoint;
    if (enforce && violations.length > 0)
      throw new G5MemoryContractError(checkpoint);
    return checkpoint;
  }
}

export interface G5TurnReport {
  readonly name: "cold" | "warm";
  readonly tokenIds: readonly number[];
  readonly timing: {
    readonly prefillMs: number;
    readonly decodeMs: number;
    readonly decodeTps: number;
    readonly wallMs: number;
    readonly endToEndTps: number;
  };
  readonly finalPhysicalFootprintBytes: number;
}

export interface G5LaneReport {
  readonly schemaVersion: 1;
  readonly gate: "G5 32 GB memory contract";
  readonly mode: "on" | "off";
  readonly result: "pass" | "error";
  readonly contract: {
    readonly processLimitBytes: number;
    readonly maxCompressorGrowthBytes: number;
    readonly flatMemoryToleranceBytes: number;
  };
  readonly turns: readonly G5TurnReport[];
  readonly memory: {
    readonly maxPhysicalFootprintBytes: number;
    readonly maxCompressorDeltaBytes: number;
    readonly swapoutDeltaBytes: number;
  };
}

export interface G5PairSummary {
  readonly tokenCount: number;
  readonly mtpOnColdTps: number;
  readonly mtpOnWarmTps: number;
  readonly mtpOffColdTps: number;
  readonly mtpOffWarmTps: number;
  readonly mtpOnColdEndToEndTps: number;
  readonly mtpOnWarmEndToEndTps: number;
  readonly mtpOffColdEndToEndTps: number;
  readonly mtpOffWarmEndToEndTps: number;
  readonly mtpOnWarmVsCold: number;
  readonly mtpOffWarmVsCold: number;
  readonly warmMtpSpeedup: number;
  readonly maxPhysicalFootprintBytes: number;
}

function sameTokens(
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

function validateLane(
  report: G5LaneReport,
  mode: "on" | "off",
  expectedPrefix: readonly number[],
): [G5TurnReport, G5TurnReport] {
  if (report.schemaVersion !== 1 ||
      report.gate !== "G5 32 GB memory contract" ||
      report.mode !== mode ||
      report.result !== "pass") {
    throw new Error(`G5 ${mode} report is not a passing schema-v1 lane`);
  }
  if (report.turns.length !== 2 ||
      report.turns[0]?.name !== "cold" ||
      report.turns[1]?.name !== "warm") {
    throw new Error(`G5 ${mode} report must contain cold then warm turns`);
  }
  const cold = report.turns[0];
  const warm = report.turns[1];
  if (!cold || !warm) throw new Error(`G5 ${mode} report is missing a turn`);
  if (
    report.contract.processLimitBytes !==
    G5_MAX_PHYSICAL_FOOTPRINT_BYTES ||
    report.contract.maxCompressorGrowthBytes !==
    G5_MAX_COMPRESSOR_GROWTH_BYTES ||
    report.contract.flatMemoryToleranceBytes !==
    G5_FLAT_MEMORY_TOLERANCE_BYTES
  ) {
    throw new Error(`G5 ${mode} report changed the fixed memory contract`);
  }
  if (
    cold.tokenIds.length !== G5_MAX_TOKENS ||
    warm.tokenIds.length !== G5_MAX_TOKENS
  ) {
    throw new Error(
      `G5 ${mode} turns must each contain exactly ${G5_MAX_TOKENS} tokens`,
    );
  }
  for (const turn of [cold, warm]) {
    for (const [label, value] of Object.entries(turn.timing)) {
      if (!Number.isFinite(value) || value <= 0)
        throw new Error(`G5 ${mode} ${turn.name} ${label} is not positive`);
    }
  }
  sameTokens(
    cold.tokenIds.slice(0, expectedPrefix.length),
    expectedPrefix,
    `G5 ${mode} direct-oracle prefix`,
  );
  sameTokens(warm.tokenIds, cold.tokenIds, `G5 ${mode} cold/warm`);
  if (
    report.memory.maxPhysicalFootprintBytes >
    report.contract.processLimitBytes
  ) {
    throw new Error(`G5 ${mode} exceeded the process footprint contract`);
  }
  if (report.memory.swapoutDeltaBytes !== 0)
    throw new Error(`G5 ${mode} observed swapout growth`);
  if (
    report.memory.maxCompressorDeltaBytes >
    report.contract.maxCompressorGrowthBytes
  ) {
    throw new Error(`G5 ${mode} exceeded the compressor-growth contract`);
  }
  if (
    warm.finalPhysicalFootprintBytes >
    cold.finalPhysicalFootprintBytes +
    report.contract.flatMemoryToleranceBytes
  ) {
    throw new Error(`G5 ${mode} cold-to-warm footprint is not flat`);
  }
  return [cold, warm];
}

export function evaluateG5Pair(
  on: G5LaneReport,
  off: G5LaneReport,
  expectedPrefix: readonly number[],
): G5PairSummary {
  const [onCold, onWarm] = validateLane(on, "on", expectedPrefix);
  const [offCold, offWarm] = validateLane(off, "off", expectedPrefix);
  sameTokens(onCold.tokenIds, offCold.tokenIds, "G5 MTP on/off");
  return {
    tokenCount: onCold.tokenIds.length,
    mtpOnColdTps: onCold.timing.decodeTps,
    mtpOnWarmTps: onWarm.timing.decodeTps,
    mtpOffColdTps: offCold.timing.decodeTps,
    mtpOffWarmTps: offWarm.timing.decodeTps,
    mtpOnColdEndToEndTps: onCold.timing.endToEndTps,
    mtpOnWarmEndToEndTps: onWarm.timing.endToEndTps,
    mtpOffColdEndToEndTps: offCold.timing.endToEndTps,
    mtpOffWarmEndToEndTps: offWarm.timing.endToEndTps,
    mtpOnWarmVsCold:
      onWarm.timing.endToEndTps /
      Math.max(onCold.timing.endToEndTps, 1e-12),
    mtpOffWarmVsCold:
      offWarm.timing.endToEndTps /
      Math.max(offCold.timing.endToEndTps, 1e-12),
    warmMtpSpeedup:
      onWarm.timing.endToEndTps /
      Math.max(offWarm.timing.endToEndTps, 1e-12),
    maxPhysicalFootprintBytes: Math.max(
      on.memory.maxPhysicalFootprintBytes,
      off.memory.maxPhysicalFootprintBytes,
    ),
  };
}
