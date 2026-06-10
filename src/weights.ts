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

export class Weights {
  readonly shards: ShardedSafetensors;
  /** shard filename → native mlx map handle (string → lazy array). */
  readonly #maps = new Map<string, bigint>();
  readonly #arrays = new Map<string, MlxArray>();

  private constructor(shards: ShardedSafetensors) {
    this.shards = shards;
  }

  static async open(modelDir: string): Promise<Weights> {
    const self = new Weights(await ShardedSafetensors.open(modelDir));
    for (const [file, sf] of self.shards.files) {
      // out-param slots read back via read.u64, not [0] (DFG stale-read
      // bug — see outArray in mlx/ffi.ts). Cold path, but the rule is
      // uniform: native wrote it, read.* reads it.
      const arrMap = new BigUint64Array([C.mlx_map_string_to_array_new()]);
      const metaMap = new BigUint64Array([C.mlx_map_string_to_string_new()]);
      const arrMapPtr = ptr(arrMap);
      const metaMapPtr = ptr(metaMap);
      const status = C.mlx_load_safetensors(
        arrMapPtr, metaMapPtr, ptr(cstr(sf.path)), cpuStream,
      );
      C.mlx_map_string_to_string_free(read.u64(metaMapPtr, 0));
      if (status !== 0) throw new Error(`mlx_load_safetensors(${sf.path}) failed`);
      self.#maps.set(file, read.u64(arrMapPtr, 0));
    }
    return self;
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
      const mapHandle = [...this.#maps.entries()]
        .find(([file]) => this.shards.files.get(file) === sf)![1];
      const slot = new BigUint64Array([C.mlx_array_new()]);
      const slotPtr = ptr(slot);
      if (C.mlx_map_string_to_array_get(slotPtr, mapHandle, ptr(cstr(name))) !== 0)
        throw new Error(`tensor ${name} missing from native map`);
      arr = new MlxArray(read.u64(slotPtr, 0));
      this.#arrays.set(name, arr);
    }
    return arr;
  }

  dispose(): void {
    for (const arr of this.#arrays.values()) arr.dispose();
    this.#arrays.clear();
    for (const map of this.#maps.values()) C.mlx_map_string_to_array_free(map);
    this.#maps.clear();
  }
}
