import { describe, expect, it } from "bun:test";
import type { ExpertIOSegment } from "../src/expert-io";
import {
  ExpertResidencyManager,
  buildExpertBatchUnion,
  planExpertResidency,
  type ExpertResidencyBackend,
} from "../src/expert-residency";

class FakeBackend implements ExpertResidencyBackend {
  readonly events: string[] = [];
  readonly slots: number;
  footprint: number;
  failNextWait = false;
  failNextRelease = false;
  #states: Array<{ generation: bigint; phase: "idle" | "loading" | "ready" | "leased" }>;

  constructor(slots: number, footprint = 1) {
    this.slots = slots;
    this.footprint = footprint;
    this.#states = Array.from({ length: slots }, () => ({ generation: 0n, phase: "idle" }));
  }

  submitSegments(slot: number, generation: bigint, segments: readonly ExpertIOSegment[]): void {
    const state = this.#states[slot]!;
    if (state.phase === "loading" || state.phase === "leased") throw new Error("busy");
    state.generation = generation;
    state.phase = "loading";
    this.events.push(`load:${slot}:${generation}:${segments[0]!.offset}`);
  }

  async wait(slot: number, generation: bigint): Promise<void> {
    const state = this.#states[slot]!;
    if (state.generation !== generation || state.phase !== "loading") throw new Error("stale");
    state.phase = "ready";
    this.events.push(`ready:${slot}:${generation}`);
    if (this.failNextWait) {
      this.failNextWait = false;
      throw new Error("forced read failure");
    }
  }

  cancel(slot: number, generation: bigint): void {
    const state = this.#states[slot]!;
    if (state.generation !== generation) throw new Error("stale");
    state.phase = "ready";
    this.events.push(`cancel:${slot}:${generation}`);
  }

  lease(slot: number, generation: bigint): void {
    const state = this.#states[slot]!;
    if (state.generation !== generation || state.phase !== "ready") throw new Error("not ready");
    state.phase = "leased";
    this.events.push(`lease:${slot}:${generation}`);
  }

  releaseGpuFenced(slot: number, generation: bigint): void {
    const state = this.#states[slot]!;
    if (state.generation !== generation || state.phase !== "leased") throw new Error("not leased");
    if (this.failNextRelease) {
      this.failNextRelease = false;
      throw new Error("forced release failure");
    }
    state.phase = "ready";
    this.events.push(`release:${slot}:${generation}`);
  }

  discard(slot: number, generation: bigint): void {
    const state = this.#states[slot]!;
    if (state.generation !== generation || state.phase !== "ready") throw new Error("not ready");
    state.phase = "idle";
    this.footprint = Math.max(0, this.footprint - 100);
    this.events.push(`discard:${slot}:${generation}`);
  }

  physicalFootprint(): number {
    return this.footprint;
  }
}

function fixture(options: { cap?: number; pinned?: Array<{ layer: number; expertId: number }> } = {}) {
  const pinned = options.pinned ?? [];
  const plan = planExpertResidency({
    budgetBytes: 100_000,
    fixedBytes: 1_000,
    slotBytes: 100,
    sparseLayers: 2,
    workingSlots: 4,
    pinnedExperts: pinned.length,
    maxSlotsPerLayer: options.cap ?? 2,
  });
  const backend = new FakeBackend(plan.totalSlots);
  const manager = new ExpertResidencyManager({
    plan,
    backend,
    sparseLayerIds: [3, 4],
    pinned,
    locate: (layer, expertId) => ({
      layer,
      expertId,
      segments: [{ file: 0, offset: layer * 1_000 + expertId, destination: 0, length: 1 }],
    }),
  });
  return { plan, backend, manager };
}

describe("expert residency planning", () => {
  it("derives the layer cap after the fixed 64-working and pinned tiers", () => {
    const plan = planExpertResidency({
      budgetBytes: 25_000,
      fixedBytes: 10_000,
      slotBytes: 100,
      sparseLayers: 75,
      workingSlots: 64,
      pinnedExperts: 10,
    });
    expect(plan.slotsPerLayer).toBe(1);
    expect(plan.totalSlots).toBe(149);
    expect(plan.plannedBytes).toBe(24_900);
  });

  it("refuses startup unless one slot per sparse layer fits", () => {
    expect(() => planExpertResidency({
      budgetBytes: 10_000,
      fixedBytes: 1_000,
      slotBytes: 100,
      sparseLayers: 75,
      workingSlots: 64,
    })).toThrow(/cannot start/);
  });
});

describe("expert batch union", () => {
  it("deduplicates in stable row/rank order and chunks at the working bound", () => {
    const waves = buildExpertBatchUnion([
      { indices: [7, 2, 9] },
      { indices: [2, 8, 7] },
    ], 2);
    expect(waves.map((wave) => wave.entries.map((entry) => entry.expertId)))
      .toEqual([[7, 2], [9, 8]]);
    expect(waves[0]!.entries[0]!.consumers).toEqual([
      { row: 0, rank: 0 },
      { row: 1, rank: 2 },
    ]);
  });
});

describe("expert residency manager", () => {
  it("matches forced miss/hit/evict behavior and keeps four global working slots", async () => {
    const { manager, backend } = fixture({ cap: 1 });
    let lease = await manager.acquireBlock(3, [4]);
    expect(lease.entries.map((entry) => [entry.expertId, entry.hit])).toEqual([[4, false]]);
    lease.releaseFenced();
    expect(manager.snapshot().working).toBe(4);

    lease = await manager.acquireBlock(3, [4]);
    expect(lease.entries[0]!.hit).toBe(true);
    lease.releaseFenced();

    lease = await manager.acquireBlock(3, [7]);
    expect(lease.entries[0]!.hit).toBe(false);
    lease.releaseFenced();
    expect(manager.snapshot()).toMatchObject({
      working: 4,
      resident: 2,
      hits: 1,
      misses: 2,
      evictions: 1,
      leased: 0,
    });
    expect(backend.events.filter((event) => event.startsWith("load:"))).toHaveLength(2);

    lease = await manager.acquireBlock(3, [4]);
    expect(lease.entries[0]!.hit).toBe(false);
    lease.releaseFenced();
  });

  it("protects current hits while reverse-promoting misses", async () => {
    const { manager } = fixture({ cap: 2 });
    let lease = await manager.acquireBlock(3, [1, 2]);
    lease.releaseFenced();
    lease = await manager.acquireBlock(3, [1, 3]);
    expect(lease.entries.map((entry) => [entry.expertId, entry.hit]))
      .toEqual([[1, true], [3, false]]);
    lease.releaseFenced();
    lease = await manager.acquireBlock(3, [1]);
    expect(lease.entries[0]!.hit).toBe(true);
    lease.releaseFenced();
  });

  it("submits resident work before the first miss read", async () => {
    const { manager, backend } = fixture({ cap: 2 });
    let lease = await manager.acquireBlock(3, [1]);
    lease.releaseFenced();
    backend.events.length = 0;
    lease = await manager.acquireBlock(3, [1, 2], (resident) => {
      expect(resident.map((entry) => entry.expertId)).toEqual([1]);
      backend.events.push("resident-submit");
    });
    lease.releaseFenced();
    expect(backend.events.indexOf("resident-submit")).toBeLessThan(
      backend.events.findIndex((event) => event.startsWith("load:")),
    );
  });

  it("keeps configured pinned experts outside LRU eviction", async () => {
    const { manager } = fixture({ cap: 1, pinned: [{ layer: 3, expertId: 9 }] });
    let lease = await manager.acquireBlock(3, [9]);
    lease.releaseFenced();
    for (const expert of [1, 2, 3]) {
      lease = await manager.acquireBlock(3, [expert]);
      lease.releaseFenced();
    }
    lease = await manager.acquireBlock(3, [9]);
    expect(lease.entries[0]!.hit).toBe(true);
    lease.releaseFenced();
  });

  it("only corrects physical pressure at a safe point and permanently lowers capacity", async () => {
    const { manager, backend } = fixture({ cap: 2 });
    let lease = await manager.acquireBlock(3, [1, 2]);
    expect(() => manager.correctForPressure()).toThrow(/safe point/);
    lease.releaseFenced();
    backend.footprint = 100_100;
    const snapshot = manager.correctForPressure();
    expect(snapshot.pressureEvictions).toBe(1);
    expect(snapshot.disabled).toBe(1);
  });

  it("drains and discards a failed generation before reusing its scratch slot", async () => {
    const { manager, backend } = fixture({ cap: 1 });
    backend.failNextWait = true;
    await expect(manager.acquireBlock(3, [5])).rejects.toThrow(/forced read/);
    expect(manager.snapshot()).toMatchObject({ loading: 0, leased: 0 });
    const lease = await manager.acquireBlock(3, [6]);
    expect(lease.entries[0]).toMatchObject({ expertId: 6, hit: false });
    lease.releaseFenced();
  });

  it("never leaves the manager active after a release failure", async () => {
    const { manager, backend } = fixture({ cap: 1 });
    const lease = await manager.acquireBlock(3, [5]);
    backend.failNextRelease = true;
    expect(() => lease.releaseFenced()).toThrow(/release failed/);
    const recovered = await manager.acquireBlock(3, [6]);
    recovered.releaseFenced();
  });

  it("refuses to pretend pressure is corrected below the one-slot floor", () => {
    const { manager, backend } = fixture({ cap: 1 });
    backend.footprint = 100_100;
    expect(() => manager.correctForPressure()).toThrow(/no evictable capacity/);
  });
});
