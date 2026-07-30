// Native map ownership for Weights.open(). Model/file-free: deterministic
// shards and MLX bindings are injected, so failure on shard N can be repeated
// without allocating real arrays.

import { describe, expect, test } from "bun:test";
import { ShardedSafetensors, type SafetensorsFile } from "../src/safetensors";
import {
  Weights,
  type WeightsNativeBindings,
} from "../src/weights";

type HandleKind = "array" | "metadata";

interface HandleRecord {
  kind: HandleKind;
  frees: number;
}

function fakeShards(count: number): ShardedSafetensors {
  const shards = new ShardedSafetensors();
  for (let index = 0; index < count; index++) {
    const filename = `model-${String(index + 1).padStart(5, "0")}.safetensors`;
    shards.files.set(
      filename,
      { path: `/fake/${filename}` } as SafetensorsFile,
    );
  }
  return shards;
}

class TrackingNative implements WeightsNativeBindings {
  readonly handles = new Map<bigint, HandleRecord>();
  readonly loadedPaths: string[] = [];
  #next = 1n;
  #loadCall = 0;
  #metadataAllocation = 0;

  constructor(
    readonly failLoadAt?: number,
    readonly failMode: "status" | "throw" = "status",
    readonly failMetadataAllocationAt?: number,
  ) {}

  #allocate(kind: HandleKind): bigint {
    const handle = this.#next++;
    this.handles.set(handle, { kind, frees: 0 });
    return handle;
  }

  #free(handle: bigint, kind: HandleKind): void {
    const record = this.handles.get(handle);
    if (!record) throw new Error(`free of unknown ${kind} handle ${handle}`);
    if (record.kind !== kind)
      throw new Error(`freed ${record.kind} handle ${handle} as ${kind}`);
    record.frees++;
    if (record.frees > 1) throw new Error(`double free of ${kind} handle ${handle}`);
  }

  newArrayMap(): bigint {
    return this.#allocate("array");
  }

  freeArrayMap(handle: bigint): void {
    this.#free(handle, "array");
  }

  newStringMap(): bigint {
    this.#metadataAllocation++;
    if (this.#metadataAllocation === this.failMetadataAllocationAt)
      throw new Error("injected metadata-map allocation failure");
    return this.#allocate("metadata");
  }

  freeStringMap(handle: bigint): void {
    this.#free(handle, "metadata");
  }

  loadSafetensors(
    _arrayMapSlot: BigUint64Array,
    _metadataMapSlot: BigUint64Array,
    path: string,
  ): number {
    this.#loadCall++;
    this.loadedPaths.push(path);
    if (this.#loadCall !== this.failLoadAt) return 0;
    if (this.failMode === "throw")
      throw new Error("injected mlx_load_safetensors throw");
    return 1;
  }

  records(kind: HandleKind): HandleRecord[] {
    return [...this.handles.values()].filter((record) => record.kind === kind);
  }

  expectAllFreedExactlyOnce(): void {
    for (const record of this.handles.values())
      expect(record.frees).toBe(1);
  }
}

async function openWith(
  shards: ShardedSafetensors,
  native: TrackingNative,
): Promise<Weights> {
  return await Weights.open("/unused", {
    native,
    openShards: async () => shards,
  });
}

describe("Weights.open native map ownership", () => {
  for (const mode of ["status", "throw"] as const) {
    test(`shard-N ${mode} failure frees current and retained maps exactly once`, async () => {
      const shards = fakeShards(3);

      for (let iteration = 0; iteration < 100; iteration++) {
        const native = new TrackingNative(2, mode);
        await expect(openWith(shards, native)).rejects.toThrow(
          mode === "status"
            ? "mlx_load_safetensors"
            : "injected mlx_load_safetensors throw",
        );

        // Shard 1 transferred its array map to Weights. Shard 2 failed while
        // owning its current array map. Both metadata maps stayed local.
        expect(native.loadedPaths).toEqual([
          "/fake/model-00001.safetensors",
          "/fake/model-00002.safetensors",
        ]);
        expect(native.records("array")).toHaveLength(2);
        expect(native.records("metadata")).toHaveLength(2);
        native.expectAllFreedExactlyOnce();
      }
    });
  }

  test("metadata-map allocation failure frees current and earlier array maps", async () => {
    const native = new TrackingNative(undefined, "status", 2);
    await expect(openWith(fakeShards(3), native)).rejects.toThrow(
      "injected metadata-map allocation failure",
    );

    expect(native.loadedPaths).toEqual(["/fake/model-00001.safetensors"]);
    expect(native.records("array")).toHaveLength(2);
    expect(native.records("metadata")).toHaveLength(1);
    native.expectAllFreedExactlyOnce();
  });

  test("successful open keeps array maps until dispose and still frees metadata", async () => {
    const native = new TrackingNative();
    const weights = await openWith(fakeShards(3), native);

    expect(native.records("array").map((record) => record.frees))
      .toEqual([0, 0, 0]);
    expect(native.records("metadata").map((record) => record.frees))
      .toEqual([1, 1, 1]);

    weights.dispose();
    native.expectAllFreedExactlyOnce();

    // Existing idempotent disposal ownership remains unchanged.
    weights.dispose();
    native.expectAllFreedExactlyOnce();
  });
});
