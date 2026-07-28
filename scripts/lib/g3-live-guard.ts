import {
  appendFileSync,
  mkdirSync,
  writeFileSync,
} from "node:fs";
import { dirname } from "node:path";

export interface VmStatCounters {
  readonly pageSizeBytes: number;
  readonly pageins: number;
  readonly pageouts: number;
  readonly swapins: number;
  readonly swapouts: number;
}

export interface SwapUsage {
  readonly totalBytes: number;
  readonly usedBytes: number;
  readonly freeBytes: number;
  readonly raw: string;
}

function requiredCounter(
  counters: ReadonlyMap<string, number>,
  name: string,
): number {
  const value = counters.get(name);
  if (value === undefined)
    throw new Error(`vm_stat output is missing ${name}`);
  return value;
}

export function parseVmStat(text: string): VmStatCounters {
  const pageSize = text.match(/page size of\s+(\d+)\s+bytes/i);
  if (!pageSize) throw new Error("vm_stat output is missing the page size");
  const counters = new Map<string, number>();
  for (const line of text.split(/\r?\n/)) {
    const match = line.match(/^([A-Za-z]+):\s+(\d+)\.\s*$/);
    if (match) counters.set(match[1]!.toLowerCase(), Number(match[2]));
  }
  return {
    pageSizeBytes: Number(pageSize[1]),
    pageins: requiredCounter(counters, "pageins"),
    pageouts: requiredCounter(counters, "pageouts"),
    swapins: requiredCounter(counters, "swapins"),
    swapouts: requiredCounter(counters, "swapouts"),
  };
}

const SIZE_MULTIPLIER: Readonly<Record<string, number>> = {
  K: 1024,
  M: 1024 ** 2,
  G: 1024 ** 3,
};

export function parseSwapUsage(text: string): SwapUsage {
  const values = new Map<string, number>();
  for (const match of text.matchAll(
    /(total|used|free)\s*=\s*([0-9.]+)([KMG])/gi,
  )) {
    values.set(
      match[1]!.toLowerCase(),
      Number(match[2]) * SIZE_MULTIPLIER[match[3]!.toUpperCase()]!,
    );
  }
  const totalBytes = values.get("total");
  const usedBytes = values.get("used");
  const freeBytes = values.get("free");
  if (
    totalBytes === undefined ||
    usedBytes === undefined ||
    freeBytes === undefined
  ) {
    throw new Error("vm.swapusage output is incomplete");
  }
  return { totalBytes, usedBytes, freeBytes, raw: text.trim() };
}

export interface G3LiveResidency {
  readonly working: number;
  readonly resident: number;
  readonly pinned: number;
  readonly disabled: number;
  readonly loading: number;
  readonly leased: number;
  readonly hits: number;
  readonly misses: number;
  readonly evictions: number;
  readonly pressureEvictions: number;
}

export interface G3LiveEnvironmentSample {
  readonly vm: VmStatCounters;
  readonly swapUsage: SwapUsage;
  readonly processRssBytes: number;
  readonly physicalFootprintBytes: number | null;
  readonly mlxActiveBytes: number;
  readonly mlxCacheBytes: number;
  readonly mlxPeakBytes: number;
  readonly residency: G3LiveResidency | null;
}

export interface G3LiveCheckpointContext {
  readonly phase: string;
  readonly forward?: string;
  readonly layer?: number;
  readonly wave?: number;
  readonly requestedExperts?: readonly number[];
  readonly note?: string;
}

export interface G3LiveCheckpoint
extends G3LiveCheckpointContext, G3LiveEnvironmentSample {
  readonly sequence: number;
  readonly elapsedMs: number;
  readonly swapinDeltaPages: number;
  readonly swapoutDeltaPages: number;
  readonly swapinDeltaBytes: number;
  readonly swapoutDeltaBytes: number;
  readonly guardLimitBytes: number;
  readonly guardTripped: boolean;
}

export class G3SwapoutGuardError extends Error {
  readonly checkpoint: G3LiveCheckpoint;

  constructor(checkpoint: G3LiveCheckpoint) {
    super(
      `G3 swapout guard tripped at ${checkpoint.phase}: ` +
      `${checkpoint.swapoutDeltaBytes} bytes >= ` +
      `${checkpoint.guardLimitBytes} bytes`,
    );
    this.name = "G3SwapoutGuardError";
    this.checkpoint = checkpoint;
  }
}

export interface G3LiveGuardOptions {
  readonly tracePath: string;
  readonly maxSwapoutDeltaBytes: number;
  readonly sample: () => G3LiveEnvironmentSample;
  readonly now?: () => number;
}

/**
 * Synchronous JSONL guard for a manual, bounded full-model probe. Checkpoints
 * are flushed immediately so an abort or SIGINT leaves a usable last-known
 * layer/wave record.
 */
export class G3LiveGuard {
  readonly tracePath: string;
  readonly maxSwapoutDeltaBytes: number;
  readonly baseline: G3LiveEnvironmentSample;
  #sample: G3LiveGuardOptions["sample"];
  #now: () => number;
  #startedAt: number;
  #sequence = 0;
  #tripped: G3LiveCheckpoint | null = null;

  constructor(options: G3LiveGuardOptions) {
    if (
      !Number.isSafeInteger(options.maxSwapoutDeltaBytes) ||
      options.maxSwapoutDeltaBytes <= 0
    ) {
      throw new RangeError(
        "maxSwapoutDeltaBytes must be a positive safe integer",
      );
    }
    this.tracePath = options.tracePath;
    this.maxSwapoutDeltaBytes = options.maxSwapoutDeltaBytes;
    this.#sample = options.sample;
    this.#now = options.now ?? performance.now.bind(performance);
    this.#startedAt = this.#now();
    this.baseline = this.#sample();
    mkdirSync(dirname(this.tracePath), { recursive: true });
    writeFileSync(this.tracePath, "");
    this.record({ phase: "baseline" });
  }

  get tripped(): G3LiveCheckpoint | null {
    return this.#tripped;
  }

  record(
    context: G3LiveCheckpointContext,
    enforce = false,
  ): G3LiveCheckpoint {
    const sample = this.#sample();
    if (sample.vm.pageSizeBytes !== this.baseline.vm.pageSizeBytes)
      throw new Error("vm_stat page size changed during G3 probe");
    const swapinDeltaPages =
      sample.vm.swapins - this.baseline.vm.swapins;
    const swapoutDeltaPages =
      sample.vm.swapouts - this.baseline.vm.swapouts;
    if (swapinDeltaPages < 0 || swapoutDeltaPages < 0)
      throw new Error("vm_stat swap counters moved backwards");
    const checkpoint: G3LiveCheckpoint = {
      ...context,
      ...sample,
      sequence: this.#sequence++,
      elapsedMs: this.#now() - this.#startedAt,
      swapinDeltaPages,
      swapoutDeltaPages,
      swapinDeltaBytes:
        swapinDeltaPages * sample.vm.pageSizeBytes,
      swapoutDeltaBytes:
        swapoutDeltaPages * sample.vm.pageSizeBytes,
      guardLimitBytes: this.maxSwapoutDeltaBytes,
      guardTripped:
        swapoutDeltaPages * sample.vm.pageSizeBytes >=
        this.maxSwapoutDeltaBytes,
    };
    appendFileSync(this.tracePath, `${JSON.stringify(checkpoint)}\n`);
    if (checkpoint.guardTripped && this.#tripped === null)
      this.#tripped = checkpoint;
    if (enforce && checkpoint.guardTripped)
      throw new G3SwapoutGuardError(checkpoint);
    return checkpoint;
  }
}
