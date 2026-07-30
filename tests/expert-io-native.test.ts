import { afterAll, beforeAll, describe, expect, it } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  _pollExpertReadUntilReady,
  ExpertIOSlabStore,
  selectExpertLruVictim,
} from "../src/expert-io";
import { MlxArray, gpuStream } from "../src/mlx/array";
import { Dtype, activeMemory, cacheMemory, clearCache, synchronize } from "../src/mlx/ffi";
import { MetalKernel } from "../src/mlx/metal-kernel";
import * as ops from "../src/mlx/ops";
import { buildSyntheticExpertFile } from "../scripts/experiments/gen-colibri-expert-file";

const dir = mkdtempSync(join(tmpdir(), "mlx-bun-expert-io-"));
const dylib = join(dir, "libexpert_io.dylib");
const data = Uint8Array.from({ length: 64 * 1024 }, (_, i) => i & 255);
const file = join(dir, "experts.bin");
const secondFile = join(dir, "experts-second.bin");
const secondData = Uint8Array.from({ length: 64 * 1024 }, (_, i) => 255 - (i & 255));
const floatFile = join(dir, "floats.bin");
const floatData = Float32Array.from({ length: 4096 }, (_, i) => i / 16);
const layoutFile = join(dir, "layout.bin");
const layout = buildSyntheticExpertFile({ layers: 1, expertsPerLayer: 2, hiddenSize: 64, intermediateSize: 32, bits: 4, groupSize: 16 });

beforeAll(async () => {
  writeFileSync(file, data);
  writeFileSync(secondFile, secondData);
  writeFileSync(floatFile, new Uint8Array(floatData.buffer));
  writeFileSync(layoutFile, layout.bytes);
  const proc = Bun.spawn(["sh", "scripts/build-expert-io.sh", dylib], { stdout: "ignore", stderr: "pipe" });
  if (await proc.exited) throw new Error(await new Response(proc.stderr).text());
});
afterAll(() => rmSync(dir, { recursive: true, force: true }));

describe("native expert I/O slabs", () => {
  it("never polls native state again after close wins a pending wait", async () => {
    for (let iteration = 0; iteration < 250; iteration++) {
      let closed = false;
      let polls = 0;
      const sleeping = Promise.withResolvers<void>();
      const resume = Promise.withResolvers<void>();
      const wait = _pollExpertReadUntilReady(
        () => {
          if (closed) throw new Error("expert slab store is closed");
        },
        () => {
          polls++;
          if (closed) throw new Error("polled freed expert state");
          return 35; // EAGAIN on macOS
        },
        async () => {
          sleeping.resolve();
          await resume.promise;
        },
      );

      await sleeping.promise;
      closed = true;
      resume.resolve();

      await expect(wait).rejects.toThrow(/closed/);
      expect(polls).toBe(1);
    }
  });

  it("scatter-loads disjoint regions from multiple shards into one slot", async () => {
    const store = new ExpertIOSlabStore(
      [file, secondFile],
      { slots: 1, slotBytes: 16 * 1024, workers: 2, libraryPath: dylib },
    );
    try {
      store.submitSegments(0, 1n, [
        { file: 0, offset: 123, destination: 0, length: 4096 },
        { file: 1, offset: 456, destination: 8192, length: 4096 },
      ]);
      await store.wait(0, 1n);
      store.lease(0, 1n);
      const view = store.view(0, 1n);
      expect(view.byteLength).toBe(12 * 1024);
      expect(view.subarray(0, 4096)).toEqual(data.subarray(123, 123 + 4096));
      expect(view.subarray(8192, 12 * 1024)).toEqual(
        secondData.subarray(456, 456 + 4096),
      );
      store.releaseCpu(0, 1n);
      expect(() => store.submitSegments(0, 2n, [
        { file: 0, offset: 0, destination: 0, length: 1024 },
        { file: 1, offset: 0, destination: 512, length: 1024 },
      ])).toThrow(/overlaps/);
    } finally {
      store.close();
    }
  });

  it("loads positioned bytes into stable aligned slots and fences reuse", async () => {
    const store = new ExpertIOSlabStore(file, { slots: 2, slotBytes: 16 * 1024, workers: 2, libraryPath: dylib });
    try {
      store.submit(0, 1n, 4096, 8192);
      expect(() => store.pointer(0, 1n)).toThrow(/active lease/);
      await store.wait(0, 1n);
      store.lease(0, 1n);
      const pointer = store.pointer(0, 1n);
      expect(pointer % (16 * 1024)).toBe(0);
      expect(store.view(0, 1n, 8192)).toEqual(data.subarray(4096, 12288));
      expect(() => store.submit(0, 2n, 0, 1024)).toThrow(/errno 16/);
      expect(() => store.close()).toThrow(/errno 16/);
      store.releaseCpu(0, 1n);
      expect(() => store.pointer(0, 1n)).toThrow(/active lease/);
      store.submit(0, 2n, 0, 1024);
      await store.wait(0, 2n); store.lease(0, 2n);
      expect(store.pointer(0, 2n)).toBe(pointer);
      expect(store.view(0, 2n, 1024)).toEqual(data.subarray(0, 1024));
      store.releaseCpu(0, 2n);
    } finally { store.close(); }
  });

  it("reports short reads and rejects stale generations", async () => {
    const store = new ExpertIOSlabStore(file, { slots: 1, slotBytes: 16 * 1024, workers: 1, libraryPath: dylib });
    try {
      store.submit(0, 7n, data.length - 10, 100);
      await expect(store.wait(0, 7n)).rejects.toThrow(/errno/);
      expect(() => store.lease(0, 6n)).toThrow(/errno/);
    } finally { store.close(); }
  });

  it("cancels publication before a slot is reused", async () => {
    const store = new ExpertIOSlabStore(file, { slots: 1, slotBytes: 16 * 1024, workers: 1, libraryPath: dylib });
    try {
      store.submit(0, 10n, 0, 16 * 1024);
      store.cancel(0, 10n);
      await expect(store.wait(0, 10n)).rejects.toThrow(/errno/);
      expect(() => store.lease(0, 10n)).toThrow(/errno/);
      store.submit(0, 11n, 4096, 4096);
      await store.wait(0, 11n); store.lease(0, 11n);
      expect(store.view(0, 11n, 4096)).toEqual(data.subarray(4096, 8192));
      store.releaseCpu(0, 11n);
    } finally { store.close(); }
  });

  it("selects deterministic LRU victims while excluding pinned and leased slots", () => {
    const trace = [
      selectExpertLruVictim([{ slot: 2, lastUse: 1n }, { slot: 1, lastUse: 1n }]),
      selectExpertLruVictim([{ slot: 0, lastUse: 1n, pinned: true }, { slot: 1, lastUse: 2n }]),
      selectExpertLruVictim([{ slot: 0, lastUse: 1n, leased: true }, { slot: 1, lastUse: 2n, pinned: true }]),
    ];
    expect(trace).toEqual([1, 1, null]);
  });

  it("matches a stateful forced hit/miss/evict reference trace", () => {
    const slots = [{ slot: 0, expert: -1, lastUse: 0n }, { slot: 1, expert: -1, lastUse: 0n }];
    const actions: string[] = [];
    let clock = 0n;
    for (const expert of [4, 7, 4, 9, 7, 9]) {
      clock++;
      const hit = slots.find((slot) => slot.expert === expert);
      if (hit) { hit.lastUse = clock; actions.push(`hit:${expert}@${hit.slot}`); continue; }
      const free = slots.find((slot) => slot.expert < 0);
      const victimId = free?.slot ?? selectExpertLruVictim(slots)!;
      const victim = slots[victimId]!;
      actions.push(victim.expert < 0 ? `load:${expert}@${victimId}` : `evict:${victim.expert}->${expert}@${victimId}`);
      victim.expert = expert; victim.lastUse = clock;
    }
    expect(actions).toEqual([
      "load:4@0", "load:7@1", "hit:4@0", "evict:7->9@1", "evict:4->7@0", "hit:9@1",
    ]);
  });

  it("keeps fixed slot addresses and bounded RSS under forced churn", async () => {
    const before = process.memoryUsage().rss;
    const store = new ExpertIOSlabStore(file, { slots: 2, slotBytes: 16 * 1024, workers: 2, libraryPath: dylib });
    const pointers: Array<number | undefined> = [];
    try {
      for (let generation = 1; generation <= 1_000; generation++) {
        const slot = generation & 1;
        const offset = (generation * 97) % (data.length - 4096);
        store.submit(slot, BigInt(generation), offset, 4096);
        await store.wait(slot, BigInt(generation));
        store.lease(slot, BigInt(generation));
        const pointer = store.pointer(slot, BigInt(generation));
        pointers[slot] ??= pointer;
        expect(pointer).toBe(pointers[slot]!);
        expect(store.view(slot, BigInt(generation), 32)).toEqual(data.subarray(offset, offset + 32));
        store.releaseCpu(slot, BigInt(generation));
      }
      expect(process.memoryUsage().rss - before).toBeLessThan(16 * 1024 * 1024);
    } finally { store.close(); }
  });

  it("decommits an idle generation without changing the reusable virtual address", async () => {
    const store = new ExpertIOSlabStore(file, {
      slots: 1, slotBytes: 16 * 1024, workers: 1, libraryPath: dylib,
    });
    try {
      expect(store.physicalFootprint()).toBeGreaterThan(0);
      store.submit(0, 1n, 0, 16 * 1024);
      await store.wait(0, 1n);
      store.lease(0, 1n);
      const address = store.pointer(0, 1n);
      store.releaseCpu(0, 1n);
      store.discard(0, 1n);
      expect(() => store.pointer(0, 1n)).toThrow(/active lease/);

      store.submit(0, 2n, 4096, 4096);
      await store.wait(0, 2n);
      store.lease(0, 2n);
      expect(store.pointer(0, 2n)).toBe(address);
      expect(store.view(0, 2n, 4096)).toEqual(data.subarray(4096, 8192));
      store.releaseCpu(0, 2n);
    } finally {
      store.close();
    }
  });

  it("feeds one registered slab to stock MLX and custom Metal without staging", async () => {
    const store = new ExpertIOSlabStore(floatFile, { slots: 1, slotBytes: floatData.byteLength, workers: 1, libraryPath: dylib });
    const kernel = new MetalKernel({
      name: "g1_slab_add_one", inputNames: ["inp"], outputNames: ["out"],
      source: "uint i = thread_position_in_grid.x; out[i] = inp[i] + 1.0f;",
    });
    let external: MlxArray | null = null;
    let stock: MlxArray | null = null;
    let metal: MlxArray | null = null;
    try {
      store.submit(0, 1n, 0, floatData.byteLength); await store.wait(0, 1n); store.lease(0, 1n, "gpu");
      expect(() => store.releaseCpu(0, 1n)).toThrow(/errno 16/);
      synchronize(gpuStream); clearCache();
      const before = activeMemory();
      external = MlxArray.fromPointer(store.pointer(0, 1n), [floatData.length], Dtype.float32);
      // MLX accounts the external leaf once at its logical byte size; a
      // second full-size staging allocation would exceed this bound.
      expect(activeMemory() - before).toBeLessThanOrEqual(floatData.byteLength);

      // Mutation after wrapping must be visible at lazy evaluation time: an
      // eager hidden input copy would preserve the old 0.0 value instead.
      new DataView(store.view(0, 1n, 4).buffer).setFloat32(0, 9, true);
      stock = ops.mulScalar(external, 2);
      metal = kernel.apply([external], {
        outputs: [{ shape: [floatData.length], dtype: Dtype.float32 }],
        grid: [floatData.length, 1, 1], threadGroup: [256, 1, 1],
      })[0]!;
      expect(stock.toFloat32()[0]).toBe(18);
      expect(metal!.toFloat32()[0]).toBe(10);
      external.dispose(); external = null;
      await store.releaseAfterGpuSync(0, 1n, [stock, metal!]);

      // Poison/reload only after the fence. Evaluated outputs must no longer
      // observe the reusable input slot.
      store.submit(0, 2n, 4, floatData.byteLength - 4); await store.wait(0, 2n);
      expect(stock.toFloat32()[0]).toBe(18);
      expect(metal!.toFloat32()[0]).toBe(10);
    } finally {
      external?.dispose(); stock?.dispose(); metal?.dispose(); kernel.dispose();
      synchronize(gpuStream); store.close();
    }
  });

  it("keeps MLX allocator usage flat across fenced slab reuse", async () => {
    const store = new ExpertIOSlabStore(floatFile, { slots: 1, slotBytes: floatData.byteLength, workers: 1, libraryPath: dylib });
    let warmBytes = 0;
    try {
      for (let generation = 1; generation <= 100; generation++) {
        const gen = BigInt(generation);
        store.submit(0, gen, 0, floatData.byteLength); await store.wait(0, gen); store.lease(0, gen, "gpu");
        const external = MlxArray.fromPointer(store.pointer(0, gen), [floatData.length], Dtype.float32);
        const output = ops.mulScalar(external, 2);
        expect(output.toFloat32()[1]).toBe(0.125);
        await store.releaseAfterGpuSync(0, gen, [output]);
        external.dispose(); output.dispose(); clearCache();
        if (generation === 10) warmBytes = activeMemory() + cacheMemory();
      }
      expect(activeMemory() + cacheMemory()).toBeLessThanOrEqual(warmBytes + 64 * 1024);
    } finally { synchronize(gpuStream); store.close(); }
  });

  it("consumes a complete contiguous gate/up/down region through both paths", async () => {
    const region = layout.manifest.experts[0]!.weights;
    const store = new ExpertIOSlabStore(layoutFile, { slots: 1, slotBytes: 16 * 1024, workers: 1, libraryPath: dylib });
    const kernel = new MetalKernel({
      name: "g1_slab_u8_identity", inputNames: ["inp"], outputNames: ["out"],
      source: "uint i = thread_position_in_grid.x; out[i] = inp[i];",
    });
    let external: MlxArray | null = null;
    let stock: MlxArray | null = null;
    let metal: MlxArray | null = null;
    try {
      store.submit(0, 1n, region.offset, region.length); await store.wait(0, 1n); store.lease(0, 1n, "gpu");
      external = MlxArray.fromPointer(store.pointer(0, 1n), [region.length], Dtype.uint8);
      const aliased = store.view(0, 1n, region.length);
      aliased[0] = 231;
      stock = external.astype(Dtype.float32);
      metal = kernel.apply([external], {
        outputs: [{ shape: [region.length], dtype: Dtype.uint8 }],
        grid: [region.length, 1, 1], threadGroup: [256, 1, 1],
      })[0]!;
      expect(stock.toFloat32()[0]).toBe(231);
      expect(metal.rawBytes()).toEqual(aliased);
      external.dispose(); external = null;
      await store.releaseAfterGpuSync(0, 1n, [stock, metal]);
    } finally {
      external?.dispose(); stock?.dispose(); metal?.dispose(); kernel.dispose();
      synchronize(gpuStream); store.close();
    }
  });

  it("evaluates a lazy graph before releasing and poisoning its GPU slot", async () => {
    const store = new ExpertIOSlabStore(floatFile, { slots: 1, slotBytes: floatData.byteLength, workers: 1, libraryPath: dylib });
    let external: MlxArray | null = null;
    let lazy: MlxArray | null = null;
    try {
      store.submit(0, 1n, 0, floatData.byteLength); await store.wait(0, 1n); store.lease(0, 1n, "gpu");
      external = MlxArray.fromPointer(store.pointer(0, 1n), [floatData.length], Dtype.float32);
      new DataView(store.view(0, 1n, 4).buffer).setFloat32(0, 2, true);
      lazy = ops.mulScalar(external, 2); // deliberately not evaluated here
      await store.releaseAfterGpuSync(0, 1n, [lazy]);
      external.dispose(); external = null;
      store.submit(0, 2n, 0, floatData.byteLength); await store.wait(0, 2n); store.lease(0, 2n);
      new DataView(store.view(0, 2n, 4).buffer).setFloat32(0, 9, true);
      store.releaseCpu(0, 2n);
      expect(lazy.toFloat32()[0]).toBe(4);
    } finally { external?.dispose(); lazy?.dispose(); synchronize(gpuStream); store.close(); }
  });

  it("rejects views after close without entering native code", () => {
    const store = new ExpertIOSlabStore(file, { slots: 1, slotBytes: 16 * 1024, workers: 1, libraryPath: dylib });
    store.close();
    expect(() => store.view(0, 1n)).toThrow(/closed/);
  });
});
