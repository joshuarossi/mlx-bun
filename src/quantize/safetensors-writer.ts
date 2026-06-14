// Sharded safetensors writer: takes a list of named mlx arrays and writes
// them to disk as one or more `model*.safetensors` files via mlx's native
// saver (mlx_save_safetensors), matching the on-disk layout the loader
// (src/weights.ts → ShardedSafetensors) reads back.
//
// Layout parity with mlx-lm / the MiniCPM5-OptiQ target:
//   - single shard  → `model.safetensors`, NO index file.
//   - multiple shards → `model-00001-of-0000N.safetensors`, plus a
//     `model.safetensors.index.json` { metadata:{total_size,
//     total_parameters}, weight_map: <name → shard> }.
//   - metadata map carries {"format":"mlx"} so the file round-trips through
//     mlx_load_safetensors with the same provenance HF/mlx writes.
//
// Memory discipline: each array is eval'd immediately before insertion so its
// bytes are materialized one tensor at a time (the caller hands us already-
// disposed-after-write arrays), bounding peak memory to ~one tensor over the
// resident weight set rather than the whole model.

import { ptr } from "bun:ffi";
import { writeFileSync } from "node:fs";
import { join } from "node:path";
import { C, takeMlxError } from "../mlx/ffi";
import type { MlxArray } from "../mlx/array";

const cstr = (s: string) => Buffer.from(s + "\0", "utf8");

/** Default greedy shard ceiling: 5 GiB (mlx-lm's MAX shard size). */
export const DEFAULT_SHARD_BYTES = 5 << 30;

export interface NamedTensor {
  name: string;
  array: MlxArray;
}

export interface ShardInfo {
  /** Filename written into outDir (e.g. "model.safetensors"). */
  file: string;
  /** Tensor names placed in this shard, in insertion order. */
  names: string[];
  /** Byte size of the tensors in this shard (sum of nbytes). */
  bytes: number;
}

export interface SafetensorsIndex {
  metadata: { total_size: number; total_parameters: number };
  weight_map: Record<string, string>;
}

export interface WriteResult {
  shards: ShardInfo[];
  totalSize: number;
  totalParams: number;
  /** The index object (also written to disk when shards.length > 1). */
  index: SafetensorsIndex;
}

export interface WriteOpts {
  /** Greedy shard ceiling in bytes (default DEFAULT_SHARD_BYTES). */
  shardBytes?: number;
}

/** Insert one array into a native string→array map (key cstring, handle u64).
 *  Evals the array first so its bytes are materialized exactly here. */
function insertArray(map: bigint, name: string, array: MlxArray): void {
  array.eval();
  if (C.mlx_map_string_to_array_insert(map, ptr(cstr(name)), array.handle) !== 0)
    throw new Error(`map insert ${name} failed: ${takeMlxError() ?? ""}`);
}

/** Build the {"format":"mlx"} metadata map. Caller frees it. */
function newMetaMap(): bigint {
  const map = C.mlx_map_string_to_string_new();
  if (C.mlx_map_string_to_string_insert(map, ptr(cstr("format")), ptr(cstr("mlx"))) !== 0)
    throw new Error(`metadata insert failed: ${takeMlxError() ?? ""}`);
  return map;
}

/** Pack the shard's tensors into a fresh native map and save to `path`. */
function saveShard(path: string, tensors: NamedTensor[]): void {
  const arrMap = C.mlx_map_string_to_array_new();
  const metaMap = newMetaMap();
  try {
    for (const { name, array } of tensors) insertArray(arrMap, name, array);
    if (C.mlx_save_safetensors(ptr(cstr(path)), arrMap, metaMap) !== 0)
      throw new Error(`mlx_save_safetensors(${path}) failed: ${takeMlxError() ?? ""}`);
  } finally {
    C.mlx_map_string_to_array_free(arrMap);
    C.mlx_map_string_to_string_free(metaMap);
  }
}

/** Shard filename for shard i of n (1-based, 5-digit, matches mlx-lm). */
function shardName(i: number, n: number): string {
  if (n === 1) return "model.safetensors";
  const pad = (x: number) => String(x).padStart(5, "0");
  return `model-${pad(i + 1)}-of-${pad(n)}.safetensors`;
}

/** Greedily bin tensors into shards no larger than `shardBytes`. A single
 *  tensor larger than the ceiling still gets its own shard (never split). */
function planShards(tensors: NamedTensor[], shardBytes: number): NamedTensor[][] {
  const shards: NamedTensor[][] = [];
  let cur: NamedTensor[] = [];
  let curBytes = 0;
  for (const t of tensors) {
    const nb = t.array.nbytes;
    if (cur.length > 0 && curBytes + nb > shardBytes) {
      shards.push(cur);
      cur = [];
      curBytes = 0;
    }
    cur.push(t);
    curBytes += nb;
  }
  if (cur.length > 0) shards.push(cur);
  return shards.length > 0 ? shards : [[]];
}

/**
 * Write `tensors` to `outDir` as sharded safetensors. Returns shard layout,
 * total byte size, total parameter count, and the (single source of truth)
 * index object. An index file is written only when there is more than one
 * shard — matching the loader's expectation that a lone `model.safetensors`
 * carries no sidecar index.
 */
export function writeShardedSafetensors(
  outDir: string,
  tensors: NamedTensor[],
  opts: WriteOpts = {},
): WriteResult {
  const shardBytes = opts.shardBytes ?? DEFAULT_SHARD_BYTES;
  const plan = planShards(tensors, shardBytes);
  const n = plan.length;

  const shards: ShardInfo[] = [];
  const weight_map: Record<string, string> = {};
  let totalSize = 0;
  let totalParams = 0;

  for (let i = 0; i < n; i++) {
    const group = plan[i]!;
    const file = shardName(i, n);
    let bytes = 0;
    for (const t of group) {
      bytes += t.array.nbytes;
      totalParams += t.array.size;
      weight_map[t.name] = file;
    }
    totalSize += bytes;
    saveShard(join(outDir, file), group);
    shards.push({ file, names: group.map((t) => t.name), bytes });
  }

  // weight_map sorted by name for a stable, diff-friendly index.
  const sortedMap: Record<string, string> = {};
  for (const name of Object.keys(weight_map).sort()) sortedMap[name] = weight_map[name]!;

  const index: SafetensorsIndex = {
    metadata: { total_size: totalSize, total_parameters: totalParams },
    weight_map: sortedMap,
  };

  if (n > 1) {
    writeFileSync(
      join(outDir, "model.safetensors.index.json"),
      JSON.stringify(index, null, 2),
    );
  }

  return { shards, totalSize, totalParams, index };
}
