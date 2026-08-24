import { describe, expect, it } from "bun:test";
import type {
  ExpertIOHintSegment,
  ExpertIOHintSnapshot,
  ExpertIOSegment,
} from "../../src/expert-io";
import { ExpertUsageLedger } from "../../src/expert-usage";
import {
  ExpertResidencyManager,
  buildExpertHintSegments,
  buildExpertBatchUnion,
  planExpertResidency,
  summarizeExpertLatencies,
  type ExpertResidencyBackend,
} from "../../src/expert-residency";

class FakeBackend implements ExpertResidencyBackend {
  readonly events: string[] = [];
  readonly slots: number;
  footprint: number;
  failNextWait = false;
  failNextRelease = false;
  hintSnapshot: ExpertIOHintSnapshot = {
    submitted: 0,
    completed: 0,
    dropped: 0,
    operations: 0,
    bytes: 0,
    errors: 0,
    queueDepth: 0,
    inFlight: 0,
  };
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

  hintSegments(segments: readonly ExpertIOHintSegment[]): boolean {
    this.events.push(`hint:${segments.map((segment) => segment.offset).join(",")}`);
    this.hintSnapshot = {
      ...this.hintSnapshot,
      submitted: this.hintSnapshot.submitted + 1,
      completed: this.hintSnapshot.completed + 1,
      operations: this.hintSnapshot.operations + segments.length,
      bytes: this.hintSnapshot.bytes + segments.reduce(
        (sum, segment) => sum + segment.length,
        0,
      ),
    };
    return true;
  }

  hintTelemetry(): ExpertIOHintSnapshot {
    return { ...this.hintSnapshot };
  }
}

function fixture(options: {
  cap?: number;
  pinned?: Array<{ layer: number; expertId: number }>;
  usage?: ExpertUsageLedger;
} = {}) {
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
    usage: options.usage,
    locate: (layer, expertId) => ({
      layer,
      expertId,
      segments: [{ file: 0, offset: layer * 1_000 + expertId, destination: 0, length: 1 }],
    }),
  });
  return { plan, backend, manager };
}

describe("expert residency planning", () => {
  it("limits F_NOCACHE advisory hints to the scale tail", () => {
    const segments: ExpertIOSegment[] = [
      { file: 0, offset: 100, destination: 0, length: 80 },
      { file: 1, offset: 500, destination: 128, length: 64 },
    ];
    expect(buildExpertHintSegments(segments, 144, true)).toEqual([{
      file: 1,
      offset: 516,
      length: 48,
    }]);
    expect(buildExpertHintSegments(segments, 144, false)).toEqual([
      { file: 0, offset: 100, length: 80 },
      { file: 1, offset: 500, length: 64 },
    ]);
  });

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

describe("expert telemetry", () => {
  it("uses nearest-rank percentiles", () => {
    expect(summarizeExpertLatencies([8, 1, 3, 2, 5])).toEqual({
      count: 5,
      totalMs: 19,
      p50Ms: 3,
      p95Ms: 8,
      p99Ms: 8,
      maxMs: 8,
    });
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

  it("reports demand bytes and waits without counting policy preload", async () => {
    const { manager } = fixture({
      cap: 2,
      pinned: [{ layer: 4, expertId: 9 }],
    });
    await manager.preloadPinned();
    let lease = await manager.acquireBlock(3, [1, 2]);
    lease.releaseFenced();
    lease = await manager.acquireBlock(3, [1, 2]);
    lease.releaseFenced();
    const telemetry = manager.drainDemandTelemetry();
    expect(telemetry).toMatchObject({
      hits: 2,
      misses: 2,
      loads: 2,
      readOperations: 2,
      readBytes: 2,
      diskService: { count: 2 },
      foregroundWait: { count: 1 },
    });
    expect(manager.drainPolicyTelemetry()).toMatchObject({
      hits: 0,
      misses: 1,
      loads: 1,
      readOperations: 1,
      readBytes: 1,
      diskService: { count: 1 },
      foregroundWait: { count: 1 },
    });
    expect(manager.drainDemandTelemetry()).toMatchObject({
      hits: 0,
      misses: 0,
      readBytes: 0,
    });
  });

  it("queues deduplicated advisory hints without changing residency or demand", async () => {
    const { manager, backend } = fixture({ cap: 2 });
    const lease = await manager.acquireBlock(3, [1]);
    lease.releaseFenced();
    manager.drainDemandTelemetry();
    const before = manager.residencyMap();

    manager.hintExperts(3, [1, 2, 2]);

    expect(manager.residencyMap()).toEqual(before);
    expect(manager.drainDemandTelemetry()).toMatchObject({
      hits: 0,
      misses: 0,
      loads: 0,
      readBytes: 0,
    });
    expect(manager.drainHintTelemetry()).toEqual({
      candidates: 2,
      residentSkipped: 1,
      submitErrors: 0,
      submitted: 1,
      completed: 1,
      dropped: 0,
      operations: 1,
      bytes: 1,
      errors: 0,
      queueDepth: 0,
      inFlight: 0,
    });
    expect(backend.events).toContain("hint:3002");
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

  it("preloads the configured hot-store before the first demand access", async () => {
    const { manager, backend } = fixture({
      cap: 1,
      pinned: [
        { layer: 3, expertId: 9 },
        { layer: 4, expertId: 7 },
      ],
    });
    await manager.preloadPinned();
    expect(backend.events.filter((event) => event.startsWith("load:")))
      .toHaveLength(2);
    for (const [layer, expertId] of [[3, 9], [4, 7]] as const) {
      const lease = await manager.acquireBlock(layer, [expertId]);
      expect(lease.entries[0]).toMatchObject({ expertId, hit: true });
      lease.releaseFenced();
    }
  });

  it("applies exact LFRU hysteresis at a safe point and exposes the live map", async () => {
    const usage = ExpertUsageLedger.open({
      path: `/tmp/mlx-bun-unused-usage-${process.pid}-${Date.now()}`,
      layers: [3, 4],
      expertsPerLayer: 16,
    });
    const { manager } = fixture({
      cap: 1,
      pinned: [{ layer: 3, expertId: 9 }],
      usage,
    });
    await manager.preloadPinned();
    manager.recordRoutes(3, [{ indices: Array(12).fill(2) }]);
    const candidates = manager.repinCandidates();
    expect(candidates).toHaveLength(1);
    expect(candidates[0]).toMatchObject({
      layer: 3,
      coldExpertId: 9,
      hotExpertId: 2,
      gain: 12,
    });
    const event = await manager.applyRepin(candidates[0]!);
    expect(event).toEqual({
      layer: 3,
      evictedPin: 9,
      admittedPin: 2,
      gain: 12,
    });
    expect(manager.residencyMap()).toEqual(expect.arrayContaining([
      expect.objectContaining({ layer: 3, expertId: 2, tier: "pinned" }),
      expect.objectContaining({ layer: 3, expertId: 9, tier: "resident" }),
    ]));
    expect(manager.snapshot().repinSwaps).toBe(1);
    usage.decayHeat();
    expect(usage.entry(3, 2).heat).toBe(6);
  });

  it("observes full route rows before demand union without changing them", () => {
    const observed: Array<{ layer: number; indices: readonly number[] }> = [];
    const plan = planExpertResidency({
      budgetBytes: 100_000,
      fixedBytes: 1_000,
      slotBytes: 100,
      sparseLayers: 1,
      workingSlots: 2,
      maxSlotsPerLayer: 1,
    });
    const manager = new ExpertResidencyManager({
      plan,
      backend: new FakeBackend(plan.totalSlots),
      sparseLayerIds: [3],
      locate: (layer, expertId) => ({
        layer,
        expertId,
        segments: [{ file: 0, offset: expertId, destination: 0, length: 1 }],
      }),
      routeObserver: (layer, routes) => {
        for (const route of routes)
          observed.push({ layer, indices: Array.from(route.indices, Number) });
      },
    });
    const routes = [{ indices: [4, 2] }, { indices: [1, 3] }];
    manager.recordRoutes(3, routes);
    expect(observed).toEqual([
      { layer: 3, indices: [4, 2] },
      { layer: 3, indices: [1, 3] },
    ]);
    expect(routes).toEqual([{ indices: [4, 2] }, { indices: [1, 3] }]);
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
