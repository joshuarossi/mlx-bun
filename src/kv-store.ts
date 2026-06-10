// KV-cache persistence: save prompt caches to disk, reload zero-copy.
//
// File layout (every tensor PAGE-ALIGNED — the Phase 1 corollary: files
// we write can be mmap'd and handed to the GPU without copies):
//   [magic "MLXBUNKV1\n"][u32 LE header length][JSON header][padding]
//   [tensor data at 16 KiB-aligned offsets]
// Header: { tokens, caches: [{ kind, offset, idx?, maxSize?, dtype,
//           kShape, vShape, kOffset, vOffset }] }
//
// Reload mmaps copy-on-write (MAP_PRIVATE): if mlx ever donates one of
// these buffers, writes hit private pages, never the file.

import { openSync, writeSync, closeSync } from "node:fs";
import { MmapFile } from "./mmap";
import { MlxArray } from "./mlx/array";
import type { Dtype } from "./mlx/ffi";
import * as ops from "./mlx/ops";
import {
  type Cache, KVCache, RotatingKVCache, Gemma4Model,
} from "./model/gemma4";

/** Contiguous raw bytes of (possibly a view of) an array. */
function contiguousBytes(a: MlxArray): Uint8Array {
  const c = ops.contiguous(a);
  const bytes = c.rawBytes();
  c.dispose();
  return bytes;
}

const MAGIC = "MLXBUNKV1\n";
const ALIGN = 16384;

interface CacheHeaderEntry {
  kind: "kv" | "rotating";
  offset: number;
  idx?: number;
  maxSize?: number;
  dtype: number;
  kShape: number[];
  vShape: number[];
  kOffset: number;
  vOffset: number;
  kBytes: number;
  vBytes: number;
}

export interface KvFileHeader {
  tokens: number[];
  caches: CacheHeaderEntry[];
}

const alignUp = (n: number) => Math.ceil(n / ALIGN) * ALIGN;

export function saveKvCache(path: string, tokens: number[], caches: Cache[]): void {
  const entries: CacheHeaderEntry[] = [];
  const blobs: Uint8Array[] = [];

  // compact each cache to its live region and snapshot bytes
  let dataOffset = 0; // relative; rebased after header is sized
  for (const c of caches) {
    let keys: MlxArray;
    let values: MlxArray;
    let kind: "kv" | "rotating";
    let idx: number | undefined;
    let maxSize: number | undefined;
    if (c instanceof RotatingKVCache) {
      kind = "rotating";
      idx = c.ringIdx;
      maxSize = c.maxSize;
      if (!c.keys || !c.values) throw new Error("cannot persist an empty cache");
      keys = c.keys;
      values = c.values;
    } else if (c instanceof KVCache) {
      kind = "kv";
      if (!c.keys || !c.values) throw new Error("cannot persist an empty cache");
      // store only the live [.., :offset, :] region
      const [B, H, , D] = c.keys.shape as [number, number, number, number];
      const vD = c.values.shape[3]!;
      keys = c.keys.slice([0, 0, 0, 0], [B, H, c.offset, D]);
      values = c.values.slice([0, 0, 0, 0], [B, H, c.offset, vD]);
    } else {
      throw new Error("unknown cache type");
    }

    const kBytesArr = contiguousBytes(keys);
    const vBytesArr = contiguousBytes(values);
    const kOffset = alignUp(dataOffset);
    const vOffset = alignUp(kOffset + kBytesArr.length);
    dataOffset = vOffset + vBytesArr.length;

    entries.push({
      kind, offset: c.offset, idx, maxSize,
      dtype: keys.dtype,
      kShape: keys.shape, vShape: values.shape,
      kOffset, vOffset,
      kBytes: kBytesArr.length, vBytes: vBytesArr.length,
    });
    blobs.push(kBytesArr, vBytesArr);
    if (c instanceof KVCache) {
      keys.dispose();
      values.dispose();
    }
  }

  const header: KvFileHeader = { tokens, caches: entries };
  const headerJson = new TextEncoder().encode(JSON.stringify(header));
  const dataStart = alignUp(MAGIC.length + 8 + headerJson.length);

  const fd = openSync(path, "w");
  try {
    const pre = new Uint8Array(dataStart);
    pre.set(new TextEncoder().encode(MAGIC), 0);
    const dv = new DataView(pre.buffer);
    dv.setUint32(MAGIC.length, headerJson.length, true);
    dv.setUint32(MAGIC.length + 4, dataStart, true);
    pre.set(headerJson, MAGIC.length + 8);
    writeSync(fd, pre, 0, pre.length, 0);

    let blobIdx = 0;
    for (const e of entries) {
      writeSync(fd, blobs[blobIdx]!, 0, e.kBytes, dataStart + e.kOffset);
      writeSync(fd, blobs[blobIdx + 1]!, 0, e.vBytes, dataStart + e.vOffset);
      blobIdx += 2;
    }
  } finally {
    closeSync(fd);
  }
}

/** Read only the header (cheap — for prefix matching across many files). */
export function readKvHeader(path: string): KvFileHeader & { dataStart: number } {
  const fd = openSync(path, "r");
  try {
    const head = new Uint8Array(MAGIC.length + 8);
    require("node:fs").readSync(fd, head, 0, head.length, 0);
    if (new TextDecoder().decode(head.subarray(0, MAGIC.length)) !== MAGIC)
      throw new Error(`${path}: not an mlx-bun KV cache file`);
    const dv = new DataView(head.buffer);
    const len = dv.getUint32(MAGIC.length, true);
    const dataStart = dv.getUint32(MAGIC.length + 4, true);
    const body = new Uint8Array(len);
    require("node:fs").readSync(fd, body, 0, len, MAGIC.length + 8);
    const header = JSON.parse(new TextDecoder().decode(body)) as KvFileHeader;
    return { ...header, dataStart };
  } finally {
    closeSync(fd);
  }
}

export interface LoadedKvCache {
  tokens: number[];
  caches: Cache[];
  /** Keep referenced as long as the caches live. */
  mmap: MmapFile;
}

export function loadKvCache(path: string, model: Gemma4Model): LoadedKvCache {
  const header = readKvHeader(path);
  const mmap = MmapFile.open(path, "cow");
  const dataStart = header.dataStart;

  const caches: Cache[] = [];
  for (const e of header.caches) {
    const keys = MlxArray.fromPointer(
      mmap.pointer(dataStart + e.kOffset), e.kShape, e.dtype as Dtype,
    );
    const values = MlxArray.fromPointer(
      mmap.pointer(dataStart + e.vOffset), e.vShape, e.dtype as Dtype,
    );
    if (e.kind === "rotating") {
      const c = new RotatingKVCache(e.maxSize!);
      c.restoreState(keys, values, e.offset, e.idx!);
      caches.push(c);
    } else {
      const c = new KVCache();
      c.restoreState(keys, values, e.offset);
      caches.push(c);
    }
  }
  if (caches.length !== model.layers.length)
    throw new Error(
      `${path}: ${caches.length} cached layers but model has ${model.layers.length}`,
    );
  return { tokens: header.tokens, caches, mmap };
}
