import type { MlxArray } from "./mlx/array";
import type { MlxHandle } from "./mlx/ffi";
import type { ExpertIOSegment } from "./expert-io";
import type {
  ExpertLfruCandidate,
  ExpertUsageEntry,
  ExpertUsageLedger,
  ExpertUsageRoute,
} from "./expert-usage";

export const DEFAULT_EXPERT_WORKING_SLOTS = 64;

export interface ExpertResidencyBudgetInput {
  readonly budgetBytes: number;
  readonly fixedBytes: number;
  readonly slotBytes: number;
  readonly sparseLayers: number;
  readonly workingSlots?: number;
  readonly pinnedExperts?: number;
  readonly maxSlotsPerLayer?: number;
}

export interface ExpertResidencyPlan {
  readonly budgetBytes: number;
  readonly fixedBytes: number;
  readonly slotBytes: number;
  readonly sparseLayers: number;
  readonly workingSlots: number;
  readonly pinnedSlots: number;
  readonly slotsPerLayer: number;
  readonly residentSlots: number;
  readonly totalSlots: number;
  readonly slabBytes: number;
  readonly plannedBytes: number;
}

function positiveSafeInteger(value: number, name: string): void {
  if (!Number.isSafeInteger(value) || value <= 0)
    throw new RangeError(`${name} must be a positive safe integer`);
}

/**
 * Derive the only admissible fixed-capacity layout. One persistent slot per
 * sparse layer plus the global working bank is a hard startup floor.
 */
export function planExpertResidency(
  input: ExpertResidencyBudgetInput,
): ExpertResidencyPlan {
  positiveSafeInteger(input.budgetBytes, "expert budgetBytes");
  if (!Number.isSafeInteger(input.fixedBytes) || input.fixedBytes < 0)
    throw new RangeError("expert fixedBytes must be a non-negative safe integer");
  positiveSafeInteger(input.slotBytes, "expert slotBytes");
  positiveSafeInteger(input.sparseLayers, "expert sparseLayers");
  const workingSlots = input.workingSlots ?? DEFAULT_EXPERT_WORKING_SLOTS;
  const pinnedSlots = input.pinnedExperts ?? 0;
  positiveSafeInteger(workingSlots, "expert workingSlots");
  if (!Number.isSafeInteger(pinnedSlots) || pinnedSlots < 0)
    throw new RangeError("expert pinnedExperts must be a non-negative safe integer");

  const mandatorySlots = workingSlots + pinnedSlots + input.sparseLayers;
  const mandatoryBytes = mandatorySlots * input.slotBytes;
  if (!Number.isSafeInteger(mandatoryBytes) ||
      input.fixedBytes + mandatoryBytes > input.budgetBytes) {
    throw new Error(
      `expert residency budget cannot start: ${input.budgetBytes} bytes does not fit ` +
      `${input.fixedBytes} fixed + ${workingSlots} working + ${pinnedSlots} pinned + ` +
      `one slot for each of ${input.sparseLayers} sparse layers`,
    );
  }

  const variableBytes =
    input.budgetBytes - input.fixedBytes -
    (workingSlots + pinnedSlots) * input.slotBytes;
  let slotsPerLayer = Math.floor(variableBytes / (input.sparseLayers * input.slotBytes));
  if (input.maxSlotsPerLayer !== undefined) {
    positiveSafeInteger(input.maxSlotsPerLayer, "expert maxSlotsPerLayer");
    slotsPerLayer = Math.min(slotsPerLayer, input.maxSlotsPerLayer);
  }
  const residentSlots = slotsPerLayer * input.sparseLayers;
  const totalSlots = workingSlots + pinnedSlots + residentSlots;
  const slabBytes = totalSlots * input.slotBytes;
  return {
    budgetBytes: input.budgetBytes,
    fixedBytes: input.fixedBytes,
    slotBytes: input.slotBytes,
    sparseLayers: input.sparseLayers,
    workingSlots,
    pinnedSlots,
    slotsPerLayer,
    residentSlots,
    totalSlots,
    slabBytes,
    plannedBytes: input.fixedBytes + slabBytes,
  };
}

export interface ExpertRouteLike {
  readonly indices: ArrayLike<number>;
}

export interface ExpertUnionConsumer {
  readonly row: number;
  readonly rank: number;
}

export interface ExpertUnionEntry {
  readonly expertId: number;
  readonly consumers: readonly ExpertUnionConsumer[];
}

export interface ExpertUnionWave {
  readonly entries: readonly ExpertUnionEntry[];
}

/**
 * Stable row-major, route-rank-major union. Repeated experts keep their first
 * position and collect every consumer; waves never exceed the scratch bank.
 */
export function buildExpertBatchUnion(
  routes: readonly ExpertRouteLike[],
  maxUniquePerWave = DEFAULT_EXPERT_WORKING_SLOTS,
): ExpertUnionWave[] {
  positiveSafeInteger(maxUniquePerWave, "maxUniquePerWave");
  const entries: Array<{ expertId: number; consumers: ExpertUnionConsumer[] }> = [];
  const byExpert = new Map<number, { expertId: number; consumers: ExpertUnionConsumer[] }>();
  for (let row = 0; row < routes.length; row++) {
    const route = routes[row]!;
    for (let rank = 0; rank < route.indices.length; rank++) {
      const expertId = Number(route.indices[rank]);
      if (!Number.isSafeInteger(expertId) || expertId < 0)
        throw new RangeError(`route ${row} rank ${rank} has invalid expert ${expertId}`);
      let entry = byExpert.get(expertId);
      if (!entry) {
        entry = { expertId, consumers: [] };
        byExpert.set(expertId, entry);
        entries.push(entry);
      }
      entry.consumers.push({ row, rank });
    }
  }
  const waves: ExpertUnionWave[] = [];
  for (let begin = 0; begin < entries.length; begin += maxUniquePerWave) {
    waves.push({
      entries: entries.slice(begin, begin + maxUniquePerWave).map((entry) => ({
        expertId: entry.expertId,
        consumers: Object.freeze(entry.consumers.slice()),
      })),
    });
  }
  return waves;
}

export interface ExpertResidencyBackend {
  readonly slots: number;
  submitSegments(
    slot: number,
    generation: bigint,
    segments: readonly ExpertIOSegment[],
  ): void;
  wait(slot: number, generation: bigint): Promise<void>;
  cancel(slot: number, generation: bigint): void;
  lease(slot: number, generation: bigint, consumer?: "cpu" | "gpu"): void;
  releaseGpuFenced(slot: number, generation: bigint): void;
  discard(slot: number, generation: bigint): void;
  physicalFootprint(): number;
}

export interface ExpertResidencyLocation {
  readonly layer: number;
  readonly expertId: number;
  readonly segments: readonly ExpertIOSegment[];
}

export interface ExpertResidencyManagerOptions {
  readonly plan: ExpertResidencyPlan;
  readonly sparseLayerIds: readonly number[];
  readonly backend: ExpertResidencyBackend;
  readonly locate: (layer: number, expertId: number) => ExpertResidencyLocation;
  readonly pinned?: ReadonlyArray<{ layer: number; expertId: number }>;
  readonly usage?: ExpertUsageLedger;
}

type SlotRole = "working" | "layer" | "pinned" | "disabled";
type SlotPhase = "idle" | "loading" | "ready" | "leased";

interface SlotRecord {
  readonly id: number;
  role: SlotRole;
  phase: SlotPhase;
  layer: number | null;
  expertId: number | null;
  generation: bigint;
  lastUse: bigint;
}

export interface ExpertResidencyLeaseEntry {
  readonly layer: number;
  readonly expertId: number;
  readonly slot: number;
  readonly generation: bigint;
  readonly hit: boolean;
}

export interface ExpertResidencySnapshot {
  readonly clock: bigint;
  readonly generation: bigint;
  readonly working: number;
  readonly resident: number;
  readonly pinned: number;
  readonly disabled: number;
  readonly loading: number;
  readonly leased: number;
  readonly physicalFootprint: number;
  readonly budgetBytes: number;
  readonly hits: number;
  readonly misses: number;
  readonly evictions: number;
  readonly pressureEvictions: number;
  readonly repinSwaps: number;
}

export interface ExpertResidencyMapEntry {
  readonly slot: number;
  readonly layer: number;
  readonly expertId: number;
  readonly tier: "resident" | "pinned";
  readonly lastUse: bigint;
  readonly usage: ExpertUsageEntry | null;
}

export interface ExpertRepinEvent {
  readonly layer: number;
  readonly evictedPin: number;
  readonly admittedPin: number;
  readonly gain: number;
}

function expertKey(layer: number, expertId: number): string {
  return `${layer}:${expertId}`;
}

export class ExpertBatchLease {
  readonly entries: readonly ExpertResidencyLeaseEntry[];
  #manager: ExpertResidencyManager | null;

  constructor(
    manager: ExpertResidencyManager,
    entries: readonly ExpertResidencyLeaseEntry[],
  ) {
    this.#manager = manager;
    this.entries = Object.freeze(entries.slice());
  }

  /**
   * Release after the caller has evaluated every graph that reads these
   * slots and synchronized the consuming stream.
   */
  releaseFenced(): void {
    const manager = this.#manager;
    if (!manager) throw new Error("expert batch lease has already been released");
    try {
      manager.releaseFenced(this.entries);
    } finally {
      this.#manager = null;
    }
  }

  async releaseAfterGpuSync(
    dependentOutputs: readonly MlxArray[],
    stream?: MlxHandle,
  ): Promise<void> {
    if (dependentOutputs.length === 0)
      throw new Error("GPU slot release requires dependent outputs to evaluate");
    const [{ gpuStream }, { synchronize }, ops] = await Promise.all([
      import("./mlx/array"),
      import("./mlx/ffi"),
      import("./mlx/ops"),
    ]);
    ops.evalAll([...dependentOutputs]);
    synchronize(stream ?? gpuStream);
    this.releaseFenced();
  }
}

/**
 * Deterministic, serial-forward residency policy. G7 owns concurrent model
 * rows; G3 deliberately permits only one active streamed expert wave so a
 * leased slot can never be shared or evicted beneath a lazy graph.
 */
export class ExpertResidencyManager {
  readonly plan: ExpertResidencyPlan;
  readonly sparseLayerIds: readonly number[];
  #backend: ExpertResidencyBackend;
  #locate: ExpertResidencyManagerOptions["locate"];
  #usage: ExpertUsageLedger | null;
  #slots: SlotRecord[] = [];
  #working = new Set<number>();
  #layerSlots = new Map<number, Set<number>>();
  #lookup = new Map<string, number>();
  #pinnedKeys = new Set<string>();
  #pinned: Array<{ layer: number; expertId: number }>;
  #active = false;
  #clock = 0n;
  #generation = 0n;
  #hits = 0;
  #misses = 0;
  #evictions = 0;
  #pressureEvictions = 0;
  #repinSwaps = 0;

  constructor(options: ExpertResidencyManagerOptions) {
    this.plan = options.plan;
    this.#backend = options.backend;
    this.#locate = options.locate;
    this.#usage = options.usage ?? null;
    this.sparseLayerIds = Object.freeze(options.sparseLayerIds.slice());
    if (this.sparseLayerIds.length !== this.plan.sparseLayers ||
        new Set(this.sparseLayerIds).size !== this.sparseLayerIds.length)
      throw new Error("sparseLayerIds must contain each planned sparse layer exactly once");
    if (options.backend.slots !== this.plan.totalSlots)
      throw new Error(
        `expert backend has ${options.backend.slots} slots; plan requires ${this.plan.totalSlots}`,
      );

    const pinned = options.pinned ?? [];
    this.#pinned = pinned.map((item) => ({ ...item }));
    if (pinned.length !== this.plan.pinnedSlots)
      throw new Error(
        `expert pinned set has ${pinned.length} entries; plan reserves ${this.plan.pinnedSlots}`,
      );
    for (const item of pinned) {
      const key = expertKey(item.layer, item.expertId);
      if (this.#pinnedKeys.has(key)) throw new Error(`duplicate pinned expert ${key}`);
      this.#pinnedKeys.add(key);
    }

    let slot = 0;
    for (; slot < this.plan.workingSlots; slot++) {
      this.#slots.push(this.#newSlot(slot, "working", null));
      this.#working.add(slot);
    }
    for (const layer of this.sparseLayerIds) {
      const layerSlots = new Set<number>();
      for (let index = 0; index < this.plan.slotsPerLayer; index++, slot++) {
        this.#slots.push(this.#newSlot(slot, "layer", layer));
        layerSlots.add(slot);
      }
      this.#layerSlots.set(layer, layerSlots);
    }
    for (; slot < this.plan.totalSlots; slot++)
      this.#slots.push(this.#newSlot(slot, "pinned", null));
  }

  /** Populate the configured hot-store before the first model forward. */
  async preloadPinned(): Promise<void> {
    if (this.#active)
      throw new Error("pinned preload requires a model safe point");
    for (const layer of this.sparseLayerIds) {
      const ids = this.#pinned
        .filter((item) => item.layer === layer)
        .map((item) => item.expertId);
      for (let begin = 0; begin < ids.length; begin += this.plan.workingSlots) {
        const lease = await this.acquireBlock(
          layer,
          ids.slice(begin, begin + this.plan.workingSlots),
        );
        lease.releaseFenced();
      }
    }
  }

  repinCandidates(): ExpertLfruCandidate[] {
    if (this.#active)
      throw new Error("live repin requires a model safe point");
    if (!this.#usage) return [];
    const candidates: ExpertLfruCandidate[] = [];
    for (const layer of this.sparseLayerIds) {
      const ids = this.#pinned
        .filter((item) => item.layer === layer)
        .map((item) => item.expertId);
      const candidate = this.#usage.lfruCandidate(layer, ids);
      if (candidate) candidates.push(candidate);
    }
    return candidates;
  }

  /** Apply one previously selected LFRU promotion at a model safe point. */
  async applyRepin(candidate: ExpertLfruCandidate): Promise<ExpertRepinEvent> {
    if (this.#active)
      throw new Error("live repin requires a model safe point");
    const pinIndex = this.#pinned.findIndex((item) =>
      item.layer === candidate.layer &&
      item.expertId === candidate.coldExpertId);
    if (pinIndex < 0 || this.#pinnedKeys.has(
      expertKey(candidate.layer, candidate.hotExpertId),
    )) {
      throw new Error("stale live-repin candidate");
    }

    let hotSlotId = this.#lookup.get(
      expertKey(candidate.layer, candidate.hotExpertId),
    );
    if (hotSlotId === undefined) {
      const lease = await this.acquireBlock(
        candidate.layer,
        [candidate.hotExpertId],
      );
      lease.releaseFenced();
      hotSlotId = this.#lookup.get(
        expertKey(candidate.layer, candidate.hotExpertId),
      );
    }
    const coldSlotId = this.#lookup.get(
      expertKey(candidate.layer, candidate.coldExpertId),
    );
    if (hotSlotId === undefined || coldSlotId === undefined)
      throw new Error("live repin could not materialize both experts");
    const hot = this.#slots[hotSlotId]!;
    const cold = this.#slots[coldSlotId]!;
    if (hot.role !== "layer" || hot.phase !== "ready" ||
        cold.role !== "pinned" || cold.phase !== "ready") {
      throw new Error("live repin requires ready resident and pinned slots");
    }

    const layerSlots = this.#layerSlots.get(candidate.layer)!;
    layerSlots.delete(hot.id);
    layerSlots.add(cold.id);
    hot.role = "pinned";
    cold.role = "layer";
    cold.lastUse = 0n;
    this.#pinnedKeys.delete(
      expertKey(candidate.layer, candidate.coldExpertId),
    );
    this.#pinnedKeys.add(
      expertKey(candidate.layer, candidate.hotExpertId),
    );
    this.#pinned[pinIndex] = {
      layer: candidate.layer,
      expertId: candidate.hotExpertId,
    };
    this.#repinSwaps++;
    return {
      layer: candidate.layer,
      evictedPin: candidate.coldExpertId,
      admittedPin: candidate.hotExpertId,
      gain: candidate.gain,
    };
  }

  residencyMap(): ExpertResidencyMapEntry[] {
    return this.#slots.flatMap((slot) => {
      if ((slot.role !== "layer" && slot.role !== "pinned") ||
          slot.phase !== "ready" || slot.layer === null ||
          slot.expertId === null) return [];
      return [{
        slot: slot.id,
        layer: slot.layer,
        expertId: slot.expertId,
        tier: slot.role === "pinned" ? "pinned" as const : "resident" as const,
        lastUse: slot.lastUse,
        usage: this.#usage?.entry(slot.layer, slot.expertId) ?? null,
      }];
    });
  }

  /** Record the full router output before batch-union deduplication. */
  recordRoutes(layer: number, routes: readonly ExpertUsageRoute[]): void {
    this.#usage?.recordRoutes(layer, routes);
  }

  async acquireBlock(
    layer: number,
    expertIds: readonly number[],
    beforeMissSubmit?: (
      resident: readonly ExpertResidencyLeaseEntry[],
    ) => void | Promise<void>,
  ): Promise<ExpertBatchLease> {
    if (this.#active)
      throw new Error("concurrent streamed expert waves are deferred to G7");
    const layerSlots = this.#layerSlots.get(layer);
    if (!layerSlots) throw new RangeError(`layer ${layer} is not a sparse residency layer`);
    const unique = [...new Set(expertIds)];
    if (unique.length !== expertIds.length)
      throw new Error("expert block must already be deduplicated");
    if (unique.length > this.plan.workingSlots)
      throw new Error(
        `expert block has ${unique.length} unique experts; working capacity is ` +
        `${this.plan.workingSlots}`,
      );
    for (const expertId of unique)
      if (!Number.isSafeInteger(expertId) || expertId < 0)
        throw new RangeError(`invalid expert id ${expertId}`);

    this.#active = true;
    const entries: ExpertResidencyLeaseEntry[] = [];
    const loaded: SlotRecord[] = [];
    try {
      for (const expertId of unique) {
        const hitId = this.#lookup.get(expertKey(layer, expertId));
        if (hitId === undefined) continue;
        const record = this.#slots[hitId]!;
        if (record.phase !== "ready")
          throw new Error(`resident expert ${layer}:${expertId} is not ready`);
        this.#backend.lease(record.id, record.generation, "gpu");
        record.phase = "leased";
        record.lastUse = ++this.#clock;
        this.#hits++;
        entries.push(this.#entry(record, true));
      }

      const misses = unique.filter(
        (expertId) => !entries.some((entry) => entry.expertId === expertId),
      );
      await beforeMissSubmit?.(Object.freeze(entries.slice()));
      const scratch = [...this.#working]
        .map((id) => this.#slots[id]!)
        .filter((record) => record.phase !== "leased" && record.phase !== "loading")
        .sort((a, b) => a.id - b.id);
      if (scratch.length < misses.length)
        throw new Error(`working tier has ${scratch.length} free slots for ${misses.length} misses`);

      for (let index = 0; index < misses.length; index++) {
        const expertId = misses[index]!;
        const record = scratch[index]!;
        if (record.phase === "ready") {
          if (record.layer !== null && record.expertId !== null)
            this.#lookup.delete(expertKey(record.layer, record.expertId));
          this.#backend.discard(record.id, record.generation);
          record.phase = "idle";
          record.layer = null;
          record.expertId = null;
        }
        const location = this.#locate(layer, expertId);
        if (location.layer !== layer || location.expertId !== expertId)
          throw new Error(`expert locator returned ${location.layer}:${location.expertId}`);
        record.generation = ++this.#generation;
        record.layer = layer;
        record.expertId = expertId;
        this.#backend.submitSegments(record.id, record.generation, location.segments);
        record.phase = "loading";
        loaded.push(record);
        this.#misses++;
      }

      const waits = await Promise.allSettled(loaded.map((record) =>
        this.#backend.wait(record.id, record.generation)));
      for (let index = 0; index < loaded.length; index++) {
        const record = loaded[index]!;
        record.phase = "ready";
        if (waits[index]!.status === "rejected") continue;
        this.#lookup.set(expertKey(layer, record.expertId!), record.id);
        this.#backend.lease(record.id, record.generation, "gpu");
        record.phase = "leased";
        record.lastUse = ++this.#clock;
        entries.push(this.#entry(record, false));
      }
      const failed = waits.find(
        (result): result is PromiseRejectedResult => result.status === "rejected",
      );
      if (failed) throw failed.reason;
      entries.sort(
        (left, right) =>
          expertIds.indexOf(left.expertId) - expertIds.indexOf(right.expertId),
      );
      return new ExpertBatchLease(this, entries);
    } catch (error) {
      const cleanupErrors: unknown[] = [];
      if (entries.some((entry) => this.#slots[entry.slot]!.phase === "leased")) {
        try {
          const [{ gpuStream }, { synchronize }] = await Promise.all([
            import("./mlx/array"),
            import("./mlx/ffi"),
          ]);
          synchronize(gpuStream);
        } catch (cleanupError) {
          cleanupErrors.push(cleanupError);
        }
      }
      for (const entry of entries) {
        const record = this.#slots[entry.slot]!;
        if (record.phase === "leased") {
          try {
            this.#backend.releaseGpuFenced(record.id, record.generation);
            record.phase = "ready";
          } catch (cleanupError) {
            cleanupErrors.push(cleanupError);
            this.#disable(record);
          }
        }
      }
      for (const record of loaded) {
        if (record.role === "disabled") continue;
        if (record.phase === "loading") {
          try {
            this.#backend.cancel(record.id, record.generation);
          } catch (cleanupError) {
            cleanupErrors.push(cleanupError);
            // A completed job may already be READY; drain below either way.
          }
          try {
            await this.#backend.wait(record.id, record.generation);
          } catch {
            // Cancellation/read errors still publish a terminal READY slot.
          }
          record.phase = "ready";
        }
        if (record.phase === "leased") {
          try {
            this.#backend.releaseGpuFenced(record.id, record.generation);
            record.phase = "ready";
          } catch (cleanupError) {
            cleanupErrors.push(cleanupError);
            this.#disable(record);
          }
        }
        if (record.phase === "ready") {
          this.#lookup.delete(expertKey(layer, record.expertId!));
          try {
            this.#backend.discard(record.id, record.generation);
            record.phase = "idle";
            record.layer = null;
            record.expertId = null;
          } catch (cleanupError) {
            cleanupErrors.push(cleanupError);
            this.#disable(record);
          }
        }
      }
      this.#active = false;
      if (cleanupErrors.length) {
        throw new AggregateError(
          [error, ...cleanupErrors],
          "expert acquire failed and cleanup was incomplete",
        );
      }
      throw error;
    }
  }

  releaseFenced(entries: readonly ExpertResidencyLeaseEntry[]): void {
    if (!this.#active) throw new Error("no active expert batch lease");
    const protectedSlots = new Set(entries.map((entry) => entry.slot));
    for (const entry of entries) {
      const record = this.#slots[entry.slot]!;
      if (record.phase !== "leased" || record.generation !== entry.generation) {
        this.#active = false;
        throw new Error(`stale expert lease ${entry.layer}:${entry.expertId}`);
      }
    }
    const releaseErrors: unknown[] = [];
    for (const entry of entries) {
      const record = this.#slots[entry.slot]!;
      try {
        this.#backend.releaseGpuFenced(record.id, record.generation);
        record.phase = "ready";
      } catch (error) {
        releaseErrors.push(error);
        this.#disable(record);
      }
    }
    if (releaseErrors.length) {
      for (const entry of entries) {
        const record = this.#slots[entry.slot]!;
        if (entry.hit || record.phase !== "ready") continue;
        this.#lookup.delete(expertKey(entry.layer, entry.expertId));
        try {
          this.#backend.discard(record.id, record.generation);
          record.phase = "idle";
          record.layer = null;
          record.expertId = null;
        } catch (error) {
          releaseErrors.push(error);
          this.#disable(record);
        }
      }
      this.#active = false;
      throw new AggregateError(releaseErrors, "expert lease release failed");
    }

    try {
      const misses = entries.filter((entry) => !entry.hit).reverse();
      const promoted = new Set<number>();
      for (const entry of misses) {
        const record = this.#slots[entry.slot]!;
        if (this.#pinnedKeys.has(expertKey(entry.layer, entry.expertId))) {
          const target = this.#slots.find(
            (candidate) => candidate.role === "pinned" && candidate.phase === "idle",
          );
          if (target) {
            this.#swapRoles(record, target, "pinned", null);
            promoted.add(record.id);
            continue;
          }
        }
        const target = this.#layerVictim(entry.layer, protectedSlots);
        if (!target) continue;
        if (target.phase === "ready") {
          this.#lookup.delete(expertKey(target.layer!, target.expertId!));
          this.#backend.discard(target.id, target.generation);
          target.phase = "idle";
          target.expertId = null;
          this.#evictions++;
        }
        this.#swapRoles(record, target, "layer", entry.layer);
        promoted.add(record.id);
      }

      for (const entry of misses) {
        if (promoted.has(entry.slot)) continue;
        const record = this.#slots[entry.slot]!;
        this.#lookup.delete(expertKey(entry.layer, entry.expertId));
        this.#backend.discard(record.id, record.generation);
        record.phase = "idle";
        record.layer = null;
        record.expertId = null;
      }
    } finally {
      this.#active = false;
    }
  }

  /**
   * At a model safe point, decommit oldest unpinned resident slots until the
   * live physical footprint falls under budget. Capacity only moves downward.
   */
  correctForPressure(): ExpertResidencySnapshot {
    if (this.#active)
      throw new Error("physical-pressure correction requires a model safe point");
    let footprint = this.#backend.physicalFootprint();
    while (footprint > this.plan.budgetBytes) {
      const victim = this.#slots
        .filter((record) =>
          record.role === "layer" &&
          record.phase === "ready" &&
          this.#layerSlots.get(record.layer!)!.size > 1)
        .sort((a, b) =>
          a.lastUse === b.lastUse ? a.id - b.id : a.lastUse < b.lastUse ? -1 : 1)[0];
      if (!victim) break;
      this.#lookup.delete(expertKey(victim.layer!, victim.expertId!));
      this.#backend.discard(victim.id, victim.generation);
      this.#layerSlots.get(victim.layer!)!.delete(victim.id);
      victim.phase = "idle";
      victim.role = "disabled";
      victim.layer = null;
      victim.expertId = null;
      this.#pressureEvictions++;
      footprint = this.#backend.physicalFootprint();
    }
    if (footprint > this.plan.budgetBytes) {
      throw new Error(
        `expert physical footprint ${footprint} exceeds budget ` +
        `${this.plan.budgetBytes}, and no evictable capacity remains`,
      );
    }
    return this.snapshot(footprint);
  }

  snapshot(physicalFootprint = this.#backend.physicalFootprint()): ExpertResidencySnapshot {
    return {
      clock: this.#clock,
      generation: this.#generation,
      working: this.#slots.filter((slot) => slot.role === "working").length,
      resident: this.#slots.filter((slot) => slot.role === "layer").length,
      pinned: this.#slots.filter((slot) => slot.role === "pinned").length,
      disabled: this.#slots.filter((slot) => slot.role === "disabled").length,
      loading: this.#slots.filter((slot) => slot.phase === "loading").length,
      leased: this.#slots.filter((slot) => slot.phase === "leased").length,
      physicalFootprint,
      budgetBytes: this.plan.budgetBytes,
      hits: this.#hits,
      misses: this.#misses,
      evictions: this.#evictions,
      pressureEvictions: this.#pressureEvictions,
      repinSwaps: this.#repinSwaps,
    };
  }

  #newSlot(id: number, role: SlotRole, layer: number | null): SlotRecord {
    return {
      id,
      role,
      phase: "idle",
      layer,
      expertId: null,
      generation: 0n,
      lastUse: 0n,
    };
  }

  #disable(record: SlotRecord): void {
    if (record.layer !== null && record.expertId !== null)
      this.#lookup.delete(expertKey(record.layer, record.expertId));
    this.#working.delete(record.id);
    if (record.layer !== null)
      this.#layerSlots.get(record.layer)?.delete(record.id);
    record.role = "disabled";
    record.layer = null;
    record.expertId = null;
  }

  #entry(record: SlotRecord, hit: boolean): ExpertResidencyLeaseEntry {
    return {
      layer: record.layer!,
      expertId: record.expertId!,
      slot: record.id,
      generation: record.generation,
      hit,
    };
  }

  #layerVictim(layer: number, protectedSlots: ReadonlySet<number>): SlotRecord | null {
    const candidates = [...this.#layerSlots.get(layer)!]
      .map((id) => this.#slots[id]!)
      .filter((record) =>
        !protectedSlots.has(record.id) &&
        (record.phase === "idle" || record.phase === "ready"))
      .sort((a, b) => {
        if (a.phase === "idle" && b.phase !== "idle") return -1;
        if (b.phase === "idle" && a.phase !== "idle") return 1;
        if (a.lastUse !== b.lastUse) return a.lastUse < b.lastUse ? -1 : 1;
        return a.id - b.id;
      });
    return candidates[0] ?? null;
  }

  #swapRoles(
    loaded: SlotRecord,
    target: SlotRecord,
    destinationRole: "layer" | "pinned",
    destinationLayer: number | null,
  ): void {
    if (loaded.role !== "working" || loaded.phase !== "ready" ||
        target.phase !== "idle")
      throw new Error("expert promotion requires ready working and idle destination slots");
    this.#working.delete(loaded.id);
    this.#working.add(target.id);
    target.role = "working";
    target.layer = null;
    target.expertId = null;
    loaded.role = destinationRole;
    loaded.layer = destinationLayer ?? loaded.layer;
    if (destinationRole === "layer") {
      const set = this.#layerSlots.get(destinationLayer!)!;
      set.delete(target.id);
      set.add(loaded.id);
    }
  }
}
