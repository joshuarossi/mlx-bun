// Weights: model directory → lazy mlx arrays.
//
// Tensor data goes through mlx's native safetensors loader
// (mlx_load_safetensors): opening is milliseconds, and each tensor's bytes
// are read into an mlx-owned (page-aligned, Metal-visible) buffer only
// when first evaluated — the same lazy semantics as Python's mx.load.
//
// Why not wrap our own mmap pointers? Verified in Phase 1: GPU ops on
// externally-wrapped buffers read garbage unless the pointer is
// page-aligned, and safetensors tensor offsets are arbitrary (not even
// element-aligned). CPU-stream ops on wrapped pointers are correct, but
// the weights' consumers are GPU kernels. See PLAN.md Phase 1 findings.
//
// The JS-side parser (ShardedSafetensors) stays as the metadata source:
// names, shapes, dtypes, byte sizes — for the registry, fit reports, and
// validation — without touching tensor bytes.

import { ptr, read } from "bun:ffi";
import { ShardedSafetensors, type TensorInfo } from "./safetensors";
import { MlxArray, cpuStream } from "./mlx/array";
import { C } from "./mlx/ffi";

const cstr = (s: string) => Buffer.from(s + "\0", "utf8");

export interface WeightsNativeBindings {
  newArrayMap(): bigint;
  freeArrayMap(handle: bigint): void;
  newStringMap(): bigint;
  freeStringMap(handle: bigint): void;
  loadSafetensors(
    arrayMapSlot: BigUint64Array,
    metadataMapSlot: BigUint64Array,
    path: string,
  ): number;
}

export interface WeightsOpenOptions {
  /** Failure-injection seam; production callers use the native MLX bindings. */
  native?: WeightsNativeBindings;
  /** Parser seam used by ownership tests to provide deterministic shard order. */
  openShards?: (modelDir: string) => Promise<ShardedSafetensors>;
}

const NATIVE_WEIGHTS: WeightsNativeBindings = {
  newArrayMap: () => C.mlx_map_string_to_array_new(),
  freeArrayMap: (handle) => {
    C.mlx_map_string_to_array_free(handle);
  },
  newStringMap: () => C.mlx_map_string_to_string_new(),
  freeStringMap: (handle) => {
    C.mlx_map_string_to_string_free(handle);
  },
  loadSafetensors: (arrayMapSlot, metadataMapSlot, path) =>
    C.mlx_load_safetensors(
      ptr(arrayMapSlot),
      ptr(metadataMapSlot),
      ptr(cstr(path)),
      cpuStream,
    ),
};

export class Weights {
  readonly shards: ShardedSafetensors;
  /** shard filename → native mlx map handle (string → lazy array). */
  readonly #maps = new Map<string, bigint>();
  readonly #arrays = new Map<string, MlxArray>();
  readonly #native: WeightsNativeBindings;

  private constructor(
    shards: ShardedSafetensors,
    native: WeightsNativeBindings,
  ) {
    this.shards = shards;
    this.#native = native;
  }

  static async open(
    modelDir: string,
    options: WeightsOpenOptions = {},
  ): Promise<Weights> {
    const native = options.native ?? NATIVE_WEIGHTS;
    const shards = await (options.openShards ?? ShardedSafetensors.open)(modelDir);
    const self = new Weights(shards, native);
    try {
      for (const [file] of self.shards.files) self.#openShard(file);
      return self;
    } catch (error) {
      // A failure on shard N must release every array map transferred by
      // shards 1..N-1. The current shard remains owned by the inner guard.
      self.dispose();
      throw error;
    }
  }

  /** Load one shard's native string→array map (lazy re-open path too). */
  #openShard(file: string): void {
    const sf = this.shards.files.get(file);
    if (!sf) throw new Error(`no shard file ${file}`);
    // out-param slots read back via read.u64, not [0] (DFG stale-read
    // bug — see outArray in mlx/ffi.ts). Cold path, but the rule is
    // uniform: native wrote it, read.* reads it.
    const arrMap = new BigUint64Array([this.#native.newArrayMap()]);
    const arrMapPtr = ptr(arrMap);
    let arrayMapTransferred = false;
    try {
      const metaMap = new BigUint64Array([this.#native.newStringMap()]);
      const metaMapPtr = ptr(metaMap);
      try {
        const status = this.#native.loadSafetensors(arrMap, metaMap, sf.path);
        if (status !== 0)
          throw new Error(`mlx_load_safetensors(${sf.path}) failed`);
        this.#maps.set(file, read.u64(arrMapPtr, 0));
        arrayMapTransferred = true;
      } finally {
        this.#native.freeStringMap(read.u64(metaMapPtr, 0));
      }
    } finally {
      if (!arrayMapTransferred)
        this.#native.freeArrayMap(read.u64(arrMapPtr, 0));
    }
  }

  /** Free one shard's native map AND every cached tensor from it, releasing
   *  all bytes materialized while consuming that shard. The shard transparently
   *  re-opens on the next tensor() touching it (header parse only — lazy).
   *  Required by streaming whole-model transforms at 27B scale: the native map
   *  retains every evaluated source array, so per-tensor dispose alone frees
   *  nothing — the whole model accumulates in RAM (2026-08-18 fold OOM). */
  releaseShard(file: string): void {
    const sf = this.shards.files.get(file);
    if (!sf) return;
    for (const [name, arr] of this.#arrays) {
      if (this.shards.tensorToFile.get(name) === sf) {
        arr.dispose();
        this.#arrays.delete(name);
      }
    }
    const map = this.#maps.get(file);
    if (map !== undefined) {
      this.#native.freeArrayMap(map);
      this.#maps.delete(file);
    }
  }

  /** The shard filename holding `name` (for releaseShard scheduling). */
  fileOf(name: string): string | undefined {
    const sf = this.shards.tensorToFile.get(name);
    if (!sf) return undefined;
    for (const [file, cand] of this.shards.files) if (cand === sf) return file;
    return undefined;
  }

  get tensorNames(): string[] {
    return this.shards.tensorNames;
  }

  info(name: string): TensorInfo {
    return this.shards.info(name);
  }

  has(name: string): boolean {
    return this.shards.tensorToFile.has(name);
  }

  /** Lazy mlx array for a tensor; cached per name. */
  tensor(name: string): MlxArray {
    let arr = this.#arrays.get(name);
    if (!arr) {
      const sf = this.shards.tensorToFile.get(name);
      if (!sf) throw new Error(`no tensor named ${name}`);
      let entry = [...this.#maps.entries()]
        .find(([file]) => this.shards.files.get(file) === sf);
      if (!entry) {
        // Shard was releaseShard()'d — transparently re-open it.
        const file = this.fileOf(name)!;
        this.#openShard(file);
        entry = [file, this.#maps.get(file)!];
      }
      const mapHandle = entry[1];
      const slot = new BigUint64Array([C.mlx_array_new()]);
      const slotPtr = ptr(slot);
      if (C.mlx_map_string_to_array_get(slotPtr, mapHandle, ptr(cstr(name))) !== 0)
        throw new Error(`tensor ${name} missing from native map`);
      arr = new MlxArray(read.u64(slotPtr, 0));
      this.#arrays.set(name, arr);
    }
    return arr;
  }

  /** Dispose + evict one cached tensor so its materialized bytes are freed
   *  mid-walk. Streaming whole-model transforms (fold/quantize at 27B scale)
   *  MUST release each source tensor after its consumer evaluates, or the
   *  cache accumulates the entire model in RAM. Safe to call for names never
   *  accessed; the next tensor(name) call re-opens it from the map. */
  release(name: string): void {
    const arr = this.#arrays.get(name);
    if (arr) {
      arr.dispose();
      this.#arrays.delete(name);
    }
  }

  dispose(): void {
    for (const arr of this.#arrays.values()) arr.dispose();
    this.#arrays.clear();
    for (const map of this.#maps.values()) this.#native.freeArrayMap(map);
    this.#maps.clear();
  }
}
