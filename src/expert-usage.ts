import {
  closeSync,
  existsSync,
  fsyncSync,
  openSync,
  readFileSync,
  renameSync,
  rmSync,
  writeSync,
} from "node:fs";

const UINT32_MAX = 0xffff_ffff;

export interface ExpertUsageRoute {
  readonly indices: ArrayLike<number>;
}

export interface ExpertUsageLedgerOptions {
  readonly path: string;
  readonly layers: readonly number[];
  readonly expertsPerLayer: number;
  /** A damaged profile is derived state: report it and start fresh. */
  readonly onWarning?: (message: string) => void;
}

export interface ExpertUsageEntry {
  readonly count: number;
  readonly heat: number;
  readonly lastAccess: number;
}

export interface ExpertUsageSnapshot {
  readonly clock: number;
  readonly routeSelections: number;
  readonly totalCount: number;
  readonly nonzeroCounts: number;
  readonly dirty: boolean;
}

export interface ExpertUsageCount {
  readonly layer: number;
  readonly expertId: number;
  readonly count: number;
}

export interface ExpertAutoPinPlan {
  readonly historySelections: number;
  readonly confidence: number;
  readonly requestedBudgetBytes: number;
  readonly usableBudgetBytes: number;
  readonly plannedBytes: number;
  readonly pins: readonly ExpertUsageCount[];
}

export interface ExpertAutoPinInput {
  readonly ledger: ExpertUsageLedger;
  /** Bytes available to the persistent LRU + pin tiers after working banks. */
  readonly residentTierBudgetBytes: number;
  /** One non-evictable LRU slot per managed layer. */
  readonly mandatoryResidentBytes: number;
  readonly slotBytes: (layer: number) => number;
  readonly minHistorySelections?: number;
  readonly fullConfidenceSelections?: number;
  readonly pinShare?: number;
  readonly minPinBudgetBytes?: number;
}

export interface ExpertLfruCandidate {
  readonly layer: number;
  readonly coldSlot: number;
  readonly coldExpertId: number;
  readonly hotExpertId: number;
  readonly coldScore: number;
  readonly hotScore: number;
  readonly gain: number;
}

export function expertLfruScore(
  heat: number,
  lastAccess: number,
  clock: number,
): number {
  const age = (clock - lastAccess) >>> 0;
  return heat * 256 + (age < 255 ? 255 - age : 0);
}

export function selectExpertLfruCandidates(
  candidates: readonly ExpertLfruCandidate[],
  limit = 4,
): ExpertLfruCandidate[] {
  positiveSafeInteger(limit, "live-repin limit");
  return candidates.slice().sort((left, right) =>
    right.gain - left.gain ||
    left.layer - right.layer ||
    left.hotExpertId - right.hotExpertId)
    .slice(0, limit);
}

function positiveSafeInteger(value: number, name: string): void {
  if (!Number.isSafeInteger(value) || value <= 0)
    throw new RangeError(`${name} must be a positive safe integer`);
}

function incrementUint32(value: number, amount: number): number {
  return Math.min(UINT32_MAX, value + amount);
}

/**
 * Colibri-compatible long-term expert frequency plus session-local heat and
 * recency. The on-disk format is one `layer expert count` row per nonzero
 * counter, matching Colibri's `.coli_usage` reader.
 */
export class ExpertUsageLedger {
  readonly path: string;
  readonly layers: readonly number[];
  readonly expertsPerLayer: number;
  #counts = new Map<number, Uint32Array>();
  #heat = new Map<number, Uint32Array>();
  #last = new Map<number, Uint32Array>();
  #clock = 0;
  #routeSelections = 0;
  #dirty = false;

  private constructor(options: ExpertUsageLedgerOptions) {
    if (!options.path) throw new Error("expert usage path must not be empty");
    positiveSafeInteger(options.expertsPerLayer, "expertsPerLayer");
    if (options.expertsPerLayer > UINT32_MAX)
      throw new RangeError("expertsPerLayer exceeds uint32 range");
    const layers = options.layers.slice();
    if (layers.length === 0 || new Set(layers).size !== layers.length)
      throw new Error("expert usage layers must be non-empty and unique");
    for (const layer of layers)
      if (!Number.isSafeInteger(layer) || layer < 0)
        throw new RangeError(`invalid expert usage layer ${layer}`);
    this.path = options.path;
    this.layers = Object.freeze(layers);
    this.expertsPerLayer = options.expertsPerLayer;
    for (const layer of layers) {
      this.#counts.set(layer, new Uint32Array(options.expertsPerLayer));
      this.#heat.set(layer, new Uint32Array(options.expertsPerLayer));
      this.#last.set(layer, new Uint32Array(options.expertsPerLayer));
    }
  }

  static open(options: ExpertUsageLedgerOptions): ExpertUsageLedger {
    const ledger = new ExpertUsageLedger(options);
    if (!existsSync(options.path)) return ledger;
    try {
      ledger.#load(readFileSync(options.path, "utf8"));
    } catch (error) {
      const detail = error instanceof Error ? error.message : String(error);
      options.onWarning?.(
        `ignoring invalid expert usage profile ${options.path}: ${detail}`,
      );
      ledger.#clearCounts();
    }
    return ledger;
  }

  /** Count every selected route before the execution plan deduplicates it. */
  recordRoutes(layer: number, routes: readonly ExpertUsageRoute[]): void {
    const counts = this.#counts.get(layer);
    const heat = this.#heat.get(layer);
    const last = this.#last.get(layer);
    if (!counts || !heat || !last)
      throw new RangeError(`layer ${layer} is not tracked by expert usage`);

    const selected: number[] = [];
    for (let row = 0; row < routes.length; row++) {
      for (let rank = 0; rank < routes[row]!.indices.length; rank++) {
        const expertId = Number(routes[row]!.indices[rank]);
        if (!Number.isSafeInteger(expertId) || expertId < 0 ||
            expertId >= this.expertsPerLayer) {
          throw new RangeError(
            `route ${row} rank ${rank} has invalid expert ${expertId}`,
          );
        }
        selected.push(expertId);
      }
    }

    for (const expertId of selected) {
      counts[expertId] = incrementUint32(counts[expertId]!, 1);
      heat[expertId] = incrementUint32(heat[expertId]!, 1);
      this.#clock = (this.#clock + 1) >>> 0;
      last[expertId] = this.#clock;
      this.#routeSelections++;
    }
    if (selected.length) this.#dirty = true;
  }

  entry(layer: number, expertId: number): ExpertUsageEntry {
    this.#validateEntry(layer, expertId);
    return {
      count: this.#counts.get(layer)![expertId]!,
      heat: this.#heat.get(layer)![expertId]!,
      lastAccess: this.#last.get(layer)![expertId]!,
    };
  }

  snapshot(): ExpertUsageSnapshot {
    let nonzeroCounts = 0;
    let totalCount = 0;
    for (const counts of this.#counts.values())
      for (const count of counts) {
        totalCount += count;
        if (count !== 0) nonzeroCounts++;
      }
    return {
      clock: this.#clock,
      routeSelections: this.#routeSelections,
      totalCount,
      nonzeroCounts,
      dirty: this.#dirty,
    };
  }

  rankedCounts(): ExpertUsageCount[] {
    const ranked: ExpertUsageCount[] = [];
    for (const layer of this.layers) {
      const counts = this.#counts.get(layer)!;
      for (let expertId = 0; expertId < counts.length; expertId++) {
        const count = counts[expertId]!;
        if (count !== 0) ranked.push({ layer, expertId, count });
      }
    }
    ranked.sort((left, right) =>
      right.count - left.count ||
      left.layer - right.layer ||
      left.expertId - right.expertId);
    return ranked;
  }

  lfruCandidate(
    layer: number,
    pinnedExpertIds: readonly number[],
  ): ExpertLfruCandidate | null {
    if (pinnedExpertIds.length === 0) return null;
    for (const expertId of pinnedExpertIds) this.#validateEntry(layer, expertId);
    const pinned = new Set(pinnedExpertIds);
    let coldSlot = 0;
    let coldScore = this.#lfruScore(layer, pinnedExpertIds[0]!);
    for (let slot = 1; slot < pinnedExpertIds.length; slot++) {
      const score = this.#lfruScore(layer, pinnedExpertIds[slot]!);
      if (score < coldScore) {
        coldSlot = slot;
        coldScore = score;
      }
    }
    let hotExpertId = -1;
    let hotScore = 0;
    for (let expertId = 0; expertId < this.expertsPerLayer; expertId++) {
      if (pinned.has(expertId)) continue;
      const score = this.#lfruScore(layer, expertId);
      if (hotExpertId < 0 || score > hotScore) {
        hotExpertId = expertId;
        hotScore = score;
      }
    }
    if (hotExpertId < 0 ||
        hotScore <= coldScore + Math.floor(coldScore / 4) + 4 * 256) {
      return null;
    }
    return {
      layer,
      coldSlot,
      coldExpertId: pinnedExpertIds[coldSlot]!,
      hotExpertId,
      coldScore,
      hotScore,
      gain: Math.floor((hotScore - coldScore) / 256),
    };
  }

  decayHeat(): void {
    for (const heat of this.#heat.values())
      for (let expertId = 0; expertId < heat.length; expertId++)
        heat[expertId] = heat[expertId]! >>> 1;
  }

  /** Persist the current profile with same-directory temp + atomic rename. */
  flush(): void {
    if (!this.#dirty) return;
    const rows: string[] = [];
    for (const layer of this.layers) {
      const counts = this.#counts.get(layer)!;
      for (let expertId = 0; expertId < counts.length; expertId++) {
        const count = counts[expertId]!;
        if (count !== 0) rows.push(`${layer} ${expertId} ${count}\n`);
      }
    }
    const temp =
      `${this.path}.tmp-${process.pid}-${Math.trunc(Bun.nanoseconds())}`;
    let fd: number | null = null;
    try {
      fd = openSync(temp, "w", 0o600);
      const data = Buffer.from(rows.join(""));
      let written = 0;
      while (written < data.length) {
        written += writeSync(
          fd,
          data,
          written,
          data.length - written,
          written,
        );
      }
      fsyncSync(fd);
      closeSync(fd);
      fd = null;
      renameSync(temp, this.path);
      this.#dirty = false;
    } catch (error) {
      if (fd !== null) closeSync(fd);
      try { rmSync(temp, { force: true }); } catch {}
      throw error;
    }
  }

  #load(text: string): void {
    for (const [index, raw] of text.split("\n").entries()) {
      const line = raw.trim();
      if (!line) continue;
      const fields = line.split(/\s+/);
      if (fields.length !== 3)
        throw new Error(`line ${index + 1}: expected layer expert count`);
      const [layer, expertId, count] = fields.map(Number);
      if (!Number.isSafeInteger(layer) || !this.#counts.has(layer!))
        throw new Error(`line ${index + 1}: invalid layer ${fields[0]}`);
      if (!Number.isSafeInteger(expertId) || expertId! < 0 ||
          expertId! >= this.expertsPerLayer) {
        throw new Error(`line ${index + 1}: invalid expert ${fields[1]}`);
      }
      if (!Number.isSafeInteger(count) || count! < 0 || count! > UINT32_MAX)
        throw new Error(`line ${index + 1}: invalid count ${fields[2]}`);
      const counts = this.#counts.get(layer!)!;
      counts[expertId!] = incrementUint32(counts[expertId!]!, count!);
    }
  }

  #clearCounts(): void {
    for (const counts of this.#counts.values()) counts.fill(0);
  }

  #validateEntry(layer: number, expertId: number): void {
    if (!this.#counts.has(layer))
      throw new RangeError(`layer ${layer} is not tracked by expert usage`);
    if (!Number.isSafeInteger(expertId) || expertId < 0 ||
        expertId >= this.expertsPerLayer) {
      throw new RangeError(`invalid expert ${expertId}`);
    }
  }

  #lfruScore(layer: number, expertId: number): number {
    const heat = this.#heat.get(layer)![expertId]!;
    const last = this.#last.get(layer)![expertId]!;
    return expertLfruScore(heat, last, this.#clock);
  }
}

/**
 * Faithful, budget-safe form of Colibri's startup AUTOPIN policy. History must
 * reach 5k selections; confidence ramps to one at 200k; pins receive at most
 * half of the resident-tier budget and are not created below a 0.5 GB tier.
 */
export function planExpertAutoPins(input: ExpertAutoPinInput): ExpertAutoPinPlan {
  const minHistory = input.minHistorySelections ?? 5_000;
  const fullConfidence = input.fullConfidenceSelections ?? 200_000;
  const pinShare = input.pinShare ?? 0.5;
  const minPinBudget = input.minPinBudgetBytes ?? 500_000_000;
  positiveSafeInteger(minHistory, "auto-pin minHistorySelections");
  positiveSafeInteger(fullConfidence, "auto-pin fullConfidenceSelections");
  if (!Number.isFinite(pinShare) || pinShare <= 0 || pinShare > 1)
    throw new RangeError("auto-pin pinShare must be in (0, 1]");
  if (!Number.isSafeInteger(minPinBudget) || minPinBudget < 0)
    throw new RangeError("auto-pin minPinBudgetBytes must be non-negative");
  if (!Number.isSafeInteger(input.residentTierBudgetBytes) ||
      input.residentTierBudgetBytes < 0 ||
      !Number.isSafeInteger(input.mandatoryResidentBytes) ||
      input.mandatoryResidentBytes < 0) {
    throw new RangeError("auto-pin resident budgets must be non-negative safe integers");
  }

  const historySelections = input.ledger.snapshot().totalCount;
  const confidence = Math.min(historySelections / fullConfidence, 1);
  const requestedBudgetBytes = Math.floor(
    input.residentTierBudgetBytes * pinShare * confidence,
  );
  const usableBudgetBytes = Math.min(
    requestedBudgetBytes,
    Math.max(
      0,
      input.residentTierBudgetBytes - input.mandatoryResidentBytes,
    ),
  );
  const pins: ExpertUsageCount[] = [];
  let plannedBytes = 0;
  if (historySelections >= minHistory && requestedBudgetBytes >= minPinBudget) {
    for (const candidate of input.ledger.rankedCounts()) {
      const bytes = input.slotBytes(candidate.layer);
      positiveSafeInteger(bytes, `auto-pin slotBytes for layer ${candidate.layer}`);
      if (plannedBytes + bytes > usableBudgetBytes) continue;
      pins.push(candidate);
      plannedBytes += bytes;
    }
  }
  return {
    historySelections,
    confidence,
    requestedBudgetBytes,
    usableBudgetBytes,
    plannedBytes,
    pins: Object.freeze(pins),
  };
}
