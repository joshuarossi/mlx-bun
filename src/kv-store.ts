// KV-cache persistence: save prompt caches to disk, reload by streamed copy.
// The serialization core of the SSD cold tier (docs/design/ssd-kv-cold-tier.md).
//
// File layout (every tensor PAGE-ALIGNED — the Phase 1 corollary: files
// we write can be mmap'd and handed to the GPU without copies):
//   [magic "MLXBUNKV2\n"][u32 LE header length][u32 LE dataStart]
//   [u64 LE header hash][JSON header][padding]
//   [tensor data at 16 KiB-aligned offsets]
// Header: { formatVersion, modelId, configFingerprint, ns, tokenizerHash,
//           createdAt, tokens, caches: [{ kind, offset, idx?, maxSize?,
//           groupSize?, bits?, kBits?, vBits?, headDim?,
//           tensors: [{ off, bytes, shape, dtype, hash }] }] }
//
// v2 over v1: quantized cache kinds (kv_config quantization — v1 could not
// persist it; NOTE bf16 is the serving default since the 2026-07-05 L1
// decision, quantized KV is opt-in), SSM kind (Qwen3.5 hybrid),
// invalidation metadata (configFingerprint covers the kv-quant scheme;
// tokenizerHash guards vocab drift; ns = adapter spec), per-tensor hashes
// (verified opt-in — the hash pass roughly doubles restore reads),
// a header hash (always verified — cheap), and atomic tmp+fsync+rename
// writes. v1 files are not migrated: nothing shipped wrote them (the
// format was test/experiment-only) — they read as "not a v2 file" and the
// SSD tier deletes-and-regenerates.
//
// v3 over v2: fixed-width (zero-padded 16-hex) tensor hashes, which let the
// writer STREAM — header sized up front, tensors materialized/hashed/written
// one at a time, header patched in last (peak host transient = one tensor,
// not the whole entry). Same magic; v2 files read as unsupported and the
// SSD tier deletes-and-regenerates (machine-local, cheap).
//
// Reload (2026-07-07, A7-restore) is a STREAMED COPY — the read-side twin
// of the v3 streaming writer: each tensor is copied out of a read-only mmap
// into an mlx-owned leaf (MlxArray.fromBytesCopy), its clean file pages
// dropped (MADV_DONTNEED) right after, and the mapping unmapped before
// loadKvCache returns. Peak host transient = the live entry + one tensor,
// and NOTHING outlives the call: the old zero-copy wrap (COW mmap +
// fromPointer) required pinning every restore mapping for the PROCESS
// lifetime once the FFI-dtor fix removed the unmap signal (2026-07-06) —
// one leaked full-entry mapping per restore — and the exactly-offset-sized
// restored buffers made the first post-restore decode step concat-copy the
// whole entry again.

import { openSync, writeSync, readSync, closeSync, fsyncSync, renameSync, rmSync } from "node:fs";
import { MmapFile, MADV_DONTNEED } from "./mmap";
import { MlxArray } from "./mlx/array";
import type { Dtype } from "./mlx/ffi";
import * as ops from "./mlx/ops";
import {
  type Cache, KVCache, RotatingKVCache,
  QuantizedKVCache, RotatingQuantizedKVCache,
  TurboQuantKVCache, type TurboQuantTensor,
} from "./model/gemma4-base";
import { SSMCache } from "./model/qwen3-delta";

const MAGIC = "MLXBUNKV2\n";
const ALIGN = 16384;
/** magic + u32 headerLen + u32 dataStart + u64 headerHash */
const PREFIX_LEN = MAGIC.length + 4 + 4 + 8;

// Fixed-width (16 hex chars): the v3 streaming writer sizes the header
// BEFORE materializing any tensor bytes, so hash strings must not change
// the header's byte length when the real values replace the placeholders.
const hash64 = (bytes: Uint8Array): string => Bun.hash(bytes).toString(16).padStart(16, "0");

export type CacheKind = "kv" | "rotating" | "qkv" | "rotating-qkv" | "ssm" | "turboquant";

interface TensorSlot {
  off: number;
  bytes: number;
  shape: number[];
  dtype: number;
  hash: string;
}

export interface CacheHeaderEntry {
  kind: CacheKind;
  offset: number;
  /** rotating variants: ring write index */
  idx?: number;
  /** rotating variants: window size */
  maxSize?: number;
  /** quantized variants (qkv/rotating-qkv: mlx affine scheme) */
  groupSize?: number;
  bits?: number;
  /** turboquant: per-side bit widths (reuses the `bits` field's slot class
   *  but needs both — asymmetric key/value bit widths, unlike qkv's single
   *  `bits`). `groupSize` is unused for turboquant (fixed at 32, the
   *  BLOCK_SIZE constant — not a configurable field like qkv's). */
  kBits?: number;
  vBits?: number;
  /** turboquant: head_dim, needed to unpack kIdx/vPacked on restore
   *  (packed byte width alone doesn't recover the original element count). */
  headDim?: number;
  /** kv/rotating: [k, v] · qkv/rotating-qkv: [kPacked, kScales, kBiases,
   *  vPacked, vScales, vBiases] · ssm: [conv, recurrent] · turboquant:
   *  [kIdx, kScales, kZeros, vPacked, vScales] */
  tensors: TensorSlot[];
}

export interface KvSaveMeta {
  modelId?: string;
  /** configFingerprint(config) — covers every graph-shaping field incl.
   *  the kv-quant scheme, so a scheme flip invalidates naturally. */
  configFingerprint?: string;
  /** Adapter namespace (PromptCache ns — adapters joined with "+"). */
  ns?: string;
  /** sha256 of tokenizer.json: identical ids must mean identical text. */
  tokenizerHash?: string;
}

export interface KvFileHeader extends KvSaveMeta {
  formatVersion: 3;
  createdAt: number;
  tokens: number[];
  caches: CacheHeaderEntry[];
}

const alignUp = (n: number) => Math.ceil(n / ALIGN) * ALIGN;

/** Snapshot one cache into header entry + LAZY tensor sources (v3 streaming
 *  writer: sizes/shapes are metadata, bytes materialize ONE tensor at a
 *  time at write — the old all-blobs-up-front path doubled RSS by the whole
 *  entry, ~390 MB for a 16k cpm5 entry, on every write-behind). Quantized
 *  full caches are sliced to the live [.., :offset, :] region (token axis —
 *  quantization groups run along the FEATURE dim, so a sequence-axis cut
 *  never splits a group); rotating caches persist the whole ring
 *  as-laid-out with ringIdx. Slice handles are lazy graph nodes (no GPU
 *  materialization until rawBytes at write time). */
interface TensorSource { arr: MlxArray; disposeAfter: boolean }
function snapshotCache(c: Cache, dataOffset: number): { entry: CacheHeaderEntry; sources: TensorSource[]; next: number } {
  const slots: TensorSlot[] = [];
  const sources: TensorSource[] = [];
  let cursor = dataOffset;
  const HASH_PLACEHOLDER = "0".repeat(16); // fixed-width; patched at write
  const push = (a: MlxArray, disposeAfter: boolean): void => {
    const off = alignUp(cursor);
    slots.push({ off, bytes: a.nbytes, shape: a.shape, dtype: a.dtype, hash: HASH_PLACEHOLDER });
    sources.push({ arr: a, disposeAfter });
    cursor = off + a.nbytes;
  };
  const liveSlice = (a: MlxArray, upTo: number): MlxArray => {
    const [B, H, , D] = a.shape as [number, number, number, number];
    return a.slice([0, 0, 0, 0], [B, H, upTo, D]);
  };
  const pushTriple = (t: ops.QuantizedTensor, upTo: number | null): void => {
    for (const a of [t.packed, t.scales, t.biases]) {
      if (upTo === null) push(a, false);
      else push(liveSlice(a, upTo), true);
    }
  };

  let entry: CacheHeaderEntry;
  if (c instanceof TurboQuantKVCache) {
    const t = c.state();
    if (t.length === 0) throw new Error("cannot persist an empty cache");
    const [kIdx, kScales, kZeros, vPacked, vScales] = t as [MlxArray, MlxArray, MlxArray, MlxArray, MlxArray];
    // state() already trims to offset — dispose these lazy slice views
    // once written (same disposeAfter contract as liveSlice elsewhere).
    for (const a of [kIdx, kScales, kZeros, vPacked, vScales]) push(a, true);
    entry = { kind: "turboquant", offset: c.offset, kBits: c.kBits, vBits: c.vBits,
      headDim: c.headDim ?? 0, tensors: slots };
  } else if (c instanceof RotatingQuantizedKVCache) {
    if (!c.keys || !c.values) throw new Error("cannot persist an empty cache");
    pushTriple(c.keys, null);
    pushTriple(c.values, null);
    entry = { kind: "rotating-qkv", offset: c.offset, idx: c.ringIdx, maxSize: c.maxSize,
      groupSize: c.groupSize, bits: c.bits, tensors: slots };
  } else if (c instanceof QuantizedKVCache) {
    if (!c.keys || !c.values) throw new Error("cannot persist an empty cache");
    pushTriple(c.keys, c.offset);
    pushTriple(c.values, c.offset);
    entry = { kind: "qkv", offset: c.offset, groupSize: c.groupSize, bits: c.bits, tensors: slots };
  } else if (c instanceof RotatingKVCache) {
    if (!c.keys || !c.values) throw new Error("cannot persist an empty cache");
    push(c.keys, false);
    push(c.values, false);
    entry = { kind: "rotating", offset: c.offset, idx: c.ringIdx, maxSize: c.maxSize, tensors: slots };
  } else if (c instanceof SSMCache) {
    if (!c.conv || !c.recurrent) throw new Error("cannot persist an empty cache");
    push(c.conv, false);
    push(c.recurrent, false);
    entry = { kind: "ssm", offset: c.offset, tensors: slots };
  } else if (c instanceof KVCache) {
    if (!c.keys || !c.values) throw new Error("cannot persist an empty cache");
    push(liveSlice(c.keys, c.offset), true);
    push(liveSlice(c.values, c.offset), true);
    entry = { kind: "kv", offset: c.offset, tensors: slots };
  } else {
    throw new Error("unknown cache type");
  }
  return { entry, sources, next: cursor };
}

/** Persist `caches` (+ the exact token prefix they encode) to `path`.
 *  ATOMIC: written to `<path>.tmp`, fsync'd, renamed — a crash mid-write
 *  leaves only a .tmp orphan (ignored + reaped by SsdCacheStore.scan). */
/** Zero-copy in-memory clone of a cache list at its CURRENT state — new
 *  cache instances holding slice VIEWS of the live tensors (mlx arrays are
 *  immutable: continued generation replaces the source caches' internal
 *  arrays, it never mutates the shared buffers, so views are stable).
 *  Built for the prompt-boundary prompt-cache snapshot (multi-turn agent
 *  traffic: the reply's decode→encode roundtrip drift makes prompt+gen
 *  entries untrimmable at context > sliding window — a prompt-only entry
 *  is ALWAYS an exact prefix of the next turn, immune to drift). Must be
 *  called while the caches hold EXACTLY the state to snapshot (post-wrap
 *  rings cannot be rewound later). Same per-kind dispatch as
 *  snapshotCache/loadKvCache. */
export function cloneKvCaches(caches: Cache[]): Cache[] {
  const view = (a: MlxArray): MlxArray => a.slice(a.shape.map(() => 0), [...a.shape]);
  const liveView = (a: MlxArray, upTo: number): MlxArray => {
    const [B, H, , D] = a.shape as [number, number, number, number];
    return a.slice([0, 0, 0, 0], [B, H, upTo, D]);
  };
  const tripleView = (t: ops.QuantizedTensor, upTo: number | null): ops.QuantizedTensor => ({
    packed: upTo === null ? view(t.packed) : liveView(t.packed, upTo),
    scales: upTo === null ? view(t.scales) : liveView(t.scales, upTo),
    biases: upTo === null ? view(t.biases) : liveView(t.biases, upTo),
  });
  const out: Cache[] = [];
  try {
    for (const c of caches) {
      if (c instanceof TurboQuantKVCache) {
        const state = c.state();
        if (state.length === 0) throw new Error("cannot clone an empty cache");
        const [kIdx, kScales, kZeros, vPacked, vScales] = state;
        const n = new TurboQuantKVCache(c.kBits, c.vBits);
        n.restoreState(
          { kIdx: view(kIdx!), kScales: view(kScales!), kZeros: view(kZeros!),
            vPacked: view(vPacked!), vScales: view(vScales!) },
          c.offset, c.headDim!,
        );
        for (const a of state) a.dispose();
        out.push(n);
      } else if (c instanceof RotatingQuantizedKVCache) {
        if (!c.keys || !c.values) throw new Error("cannot clone an empty cache");
        const n = new RotatingQuantizedKVCache(c.maxSize, c.groupSize, c.bits);
        n.restoreState(tripleView(c.keys, null), tripleView(c.values, null), c.offset, c.ringIdx);
        out.push(n);
      } else if (c instanceof QuantizedKVCache) {
        if (!c.keys || !c.values) throw new Error("cannot clone an empty cache");
        const n = new QuantizedKVCache(c.groupSize, c.bits);
        n.restoreState(tripleView(c.keys, c.offset), tripleView(c.values, c.offset), c.offset);
        out.push(n);
      } else if (c instanceof RotatingKVCache) {
        if (!c.keys || !c.values) throw new Error("cannot clone an empty cache");
        const n = new RotatingKVCache(c.maxSize);
        n.restoreState(view(c.keys), view(c.values), c.offset, c.ringIdx);
        out.push(n);
      } else if (c instanceof SSMCache) {
        if (!c.conv || !c.recurrent) throw new Error("cannot clone an empty cache");
        const n = new SSMCache();
        n.conv = view(c.conv);
        n.recurrent = view(c.recurrent);
        n.offset = c.offset;
        out.push(n);
      } else if (c instanceof KVCache) {
        if (!c.keys || !c.values) throw new Error("cannot clone an empty cache");
        const n = new KVCache();
        n.restoreState(liveView(c.keys, c.offset), liveView(c.values, c.offset), c.offset);
        out.push(n);
      } else {
        throw new Error("cloneKvCaches: unknown cache type");
      }
    }
  } catch (err) {
    for (const c of out) c.dispose();
    throw err;
  }
  return out;
}

/** Shared v3 writer core, one `yield` after each tensor write. The sync
 *  wrapper drains it in a tight loop; the async wrapper awaits a macrotask
 *  between yields so the EVENT LOOP KEEPS SERVING while a multi-hundred-MB
 *  entry flushes (the write-behind persistence contract: durability never
 *  blocks a request). try/finally still runs on early generator close. */
function* saveKvCacheSteps(path: string, tokens: number[], caches: Cache[], meta: KvSaveMeta): Generator<void, void, void> {
  // Plan pass: header entries + lazy tensor sources, NO bytes materialized.
  const entries: CacheHeaderEntry[] = [];
  const sources: TensorSource[] = [];
  let dataOffset = 0; // relative; rebased after header is sized
  try {
    for (const c of caches) {
      const s = snapshotCache(c, dataOffset);
      entries.push(s.entry);
      sources.push(...s.sources);
      dataOffset = s.next;
    }

    // Header size is final NOW: hashes are fixed-width placeholders that get
    // patched in place (same byte length) after the data pass computes them.
    const header: KvFileHeader = {
      formatVersion: 3, createdAt: Date.now(), ...meta, tokens, caches: entries,
    };
    const headerLen = new TextEncoder().encode(JSON.stringify(header)).length;
    const dataStart = alignUp(PREFIX_LEN + headerLen);

    const tmp = `${path}.tmp`;
    const fd = openSync(tmp, "w");
    try {
      // Data pass: materialize → hash → write → drop, ONE tensor at a time.
      // The hash+write read a ZERO-COPY view of the contiguous mlx buffer
      // (rawBytesView) — never a JS-heap copy. rawBytes() here looked
      // "streamed" but each call allocated a dead per-tensor JS-heap copy
      // whose reclamation is GC-timing-dependent — up to a whole extra
      // entry of heap on a busy server (the A7 residual). Now zero JS
      // allocations; the only real transient is the one mlx-side
      // contiguous copy (allocator-pooled; none at all for contiguous
      // sources — mlx save-transient measured 0 bytes, 2026-07-07). NOTE:
      // the hash+write still CPU-touch the live entry's unified-memory
      // pages, which makes them VISIBLE to ps RSS — accounting, not an
      // allocation (see bench-serve.ts' per-leg RSS note).
      let srcIdx = 0;
      for (const e of entries) {
        for (const slot of e.tensors) {
          const src = sources[srcIdx++]!;
          const c = ops.contiguous(src.arr);
          try {
            const bytes = c.rawBytesView(); // evals; aliases the mlx buffer
            if (bytes.length !== slot.bytes)
              throw new Error(`tensor byte-length drift: planned ${slot.bytes}, got ${bytes.length}`);
            slot.hash = hash64(bytes);
            writeSync(fd, bytes, 0, bytes.length, dataStart + slot.off);
          } finally {
            c.dispose(); // the view dies with the buffer — nothing retains it
          }
          if (src.disposeAfter) { src.arr.dispose(); src.disposeAfter = false; }
          yield;
        }
      }

      // Header pass: real hashes in, byte length unchanged by construction.
      const headerJson = new TextEncoder().encode(JSON.stringify(header));
      if (headerJson.length !== headerLen)
        throw new Error(`header length drift: planned ${headerLen}, got ${headerJson.length}`);
      const pre = new Uint8Array(dataStart);
      pre.set(new TextEncoder().encode(MAGIC), 0);
      const dv = new DataView(pre.buffer);
      dv.setUint32(MAGIC.length, headerJson.length, true);
      dv.setUint32(MAGIC.length + 4, dataStart, true);
      dv.setBigUint64(MAGIC.length + 8, BigInt(Bun.hash(headerJson)), true);
      pre.set(headerJson, PREFIX_LEN);
      writeSync(fd, pre, 0, pre.length, 0);
      fsyncSync(fd);
    } catch (err) {
      closeSync(fd);
      try { rmSync(tmp, { force: true }); } catch {}
      throw err;
    }
    closeSync(fd);
    renameSync(tmp, path);
  } finally {
    // Slices created in the plan pass are ours to free on EVERY path.
    for (const s of sources) if (s.disposeAfter) s.arr.dispose();
  }
}

export function saveKvCache(path: string, tokens: number[], caches: Cache[], meta: KvSaveMeta = {}): void {
  for (const _ of saveKvCacheSteps(path, tokens, caches, meta)) { /* drain */ }
}

/** Non-blocking variant: yields the event loop after every tensor write so
 *  serving interleaves with the flush. Caller owns `caches` lifetime for
 *  the duration (pass zero-copy clones, dispose after).
 *
 *  `waitTurn` (optional) is awaited BEFORE every step — including the first —
 *  so the caller can gate the flush's schedule (the server passes the
 *  gateway's onIdle: each tensor step is a blocking GPU sync on the decode
 *  stream + a synchronous multi-MB writeSync, and the old unconditional
 *  setImmediate pacing interleaved those slices exactly between decode
 *  tokens — the 2026-07-07 decode@ctx contamination. A request arriving
 *  MID-flush pauses the remaining tensors until idle again). Gate failures
 *  are swallowed: scheduling advice must never corrupt the write path
 *  (an early generator close inside the fd-open section would leak the fd). */
export async function saveKvCacheAsync(
  path: string, tokens: number[], caches: Cache[], meta: KvSaveMeta = {},
  waitTurn?: () => Promise<void>,
): Promise<void> {
  const steps = saveKvCacheSteps(path, tokens, caches, meta);
  while (true) {
    if (waitTurn) await waitTurn().catch(() => {});
    if (steps.next().done) break;
    await new Promise<void>((r) => setImmediate(r));
  }
}

/** One pending write-behind item: an entry's copied tokens + OWNED
 *  zero-copy cache clones (the queue disposes them on every exit path). */
export interface SpillItem {
  tokens: number[];
  caches: Cache[];
  ns: string;
}

/** Bounded write-behind queue (2026-07-07 post-merge review fix).
 *
 *  Pending spill/snapshot clones pin their entries' GPU buffers until the
 *  idle-gated flush gets a turn; the old bare promise chain queued them
 *  WITHOUT BOUND, so under sustained traffic (gate starved, evictions
 *  ongoing) resident memory = prompt-cache cap + every queued clone —
 *  allocator pressure exactly under the load that caused the evictions.
 *
 *  Policy: queued bytes are capped. Over cap, the OLDEST not-in-flight
 *  item is dropped and its clones disposed immediately — cache semantics
 *  (a dropped spill is a future cache miss, never a wrong result; the
 *  contention-free alternative to letting the flush cut into decode).
 *  The item being enqueued is never its own victim (soft cap: one
 *  oversized entry may exceed the cap alone rather than never spilling).
 *  Items run strictly serially in enqueue order via an internal chain;
 *  store failures are swallowed (cold tier is best-effort) but clones
 *  are disposed on every settle path. */
type SpillRec = SpillItem & { bytes: number; dropped: boolean };

export class SpillQueue {
  #queue: SpillRec[] = [];
  #bytes = 0;
  #dropped = 0;
  #inFlight: object | null = null;
  #chain: Promise<void> = Promise.resolve();

  constructor(
    readonly capBytes: number,
    /** Byte size of a clone set (prompt-cache's cacheBytes). */
    readonly bytesOf: (caches: Cache[]) => number,
    /** The actual write (server passes storeAsync + the idle gate). */
    readonly store: (item: SpillItem) => Promise<unknown>,
    /** Clone disposal — frees the pinned GPU memory. */
    readonly disposeClones: (caches: Cache[]) => void,
  ) {}

  /** Bytes pinned by queued (not yet flushed) clones. */
  get pendingBytes(): number { return this.#bytes; }
  get pendingCount(): number { return this.#queue.length; }
  /** Spills dropped by the cap since start (each = one future cache miss). */
  get droppedCount(): number { return this.#dropped; }

  enqueue(item: SpillItem): void {
    const rec = { ...item, bytes: this.bytesOf(item.caches), dropped: false };
    this.#queue.push(rec);
    this.#bytes += rec.bytes;
    while (this.#bytes > this.capBytes) {
      const victim = this.#queue.find(
        (p) => !p.dropped && p !== this.#inFlight && p !== rec,
      );
      if (!victim) break; // only the new item (or in-flight) left — soft cap
      this.#drop(victim);
    }
    this.#chain = this.#chain.then(async () => {
      if (rec.dropped) return; // clones already disposed at drop time
      this.#inFlight = rec;
      try {
        await this.store(rec);
      } catch {
        // best-effort tier — the entry simply won't restore
      } finally {
        this.#inFlight = null;
        this.#remove(rec);
        this.disposeClones(rec.caches);
      }
    });
  }

  /** Settles when everything enqueued so far has flushed or dropped
   *  (tests; a future shutdown hook would await this). */
  drain(): Promise<void> { return this.#chain; }

  #drop(rec: SpillRec): void {
    rec.dropped = true;
    this.#dropped++;
    this.#remove(rec);
    this.disposeClones(rec.caches);
  }

  #remove(rec: SpillRec): void {
    const i = this.#queue.indexOf(rec);
    if (i >= 0) {
      this.#queue.splice(i, 1);
      this.#bytes -= rec.bytes;
    }
  }
}

/** Read only the header (cheap — for prefix matching across many files).
 *  Always verifies the header hash; throws on any structural mismatch. */
export function readKvHeader(path: string): KvFileHeader & { dataStart: number } {
  const fd = openSync(path, "r");
  try {
    const head = new Uint8Array(PREFIX_LEN);
    readSync(fd, head, 0, head.length, 0);
    if (new TextDecoder().decode(head.subarray(0, MAGIC.length)) !== MAGIC)
      throw new Error(`${path}: not an mlx-bun KV v2 cache file`);
    const dv = new DataView(head.buffer);
    const len = dv.getUint32(MAGIC.length, true);
    const dataStart = dv.getUint32(MAGIC.length + 4, true);
    const expectHash = dv.getBigUint64(MAGIC.length + 8, true);
    const body = new Uint8Array(len);
    readSync(fd, body, 0, len, PREFIX_LEN);
    if (BigInt(Bun.hash(body)) !== expectHash)
      throw new Error(`${path}: header hash mismatch (truncated or corrupt)`);
    const header = JSON.parse(new TextDecoder().decode(body)) as KvFileHeader;
    if (header.formatVersion !== 3)
      throw new Error(`${path}: unsupported formatVersion ${header.formatVersion}`);
    return { ...header, dataStart };
  } finally {
    closeSync(fd);
  }
}

export interface LoadedKvCache {
  tokens: number[];
  header: KvFileHeader;
  caches: Cache[];
}

export interface KvLoadExpect {
  /** Reject on metadata mismatch (pass what the server is running). */
  configFingerprint?: string;
  tokenizerHash?: string;
  ns?: string;
  /** Verify every tensor hash before copying it in (off by default,
   *  `--ssd-cache-verify` — the hash pass roughly doubles restore reads). */
  verify?: boolean;
}

/** Copy-restore a full-attention KV tensor into STEP-rounded capacity with
 *  ≥1 token of slack (what a live mid-generation cache looks like) so the
 *  first post-restore updateAndFetch never takes the grow path — the old
 *  exactly-offset-sized restore made that first step concat-copy the ENTIRE
 *  entry into a fresh buffer. Zero padding is bit-safe: writes land at
 *  [offset..) before any read, and attention only reads [:offset+L).
 *  Evaluated EAGERLY so the host-copy leaf frees before the next tensor
 *  streams in (bounded transient). Plain KVCache only — rotating rings and
 *  quantized triples are position-exact layouts. */
function withStepCapacity(a: MlxArray, offset: number): MlxArray {
  const [B, H, S, D] = a.shape as [number, number, number, number];
  const cap = Math.ceil((offset + 1) / KVCache.STEP) * KVCache.STEP;
  if (S >= cap) return a;
  // Internals drained on throw (2026-07-07 review: a grown.eval() failure
  // orphaned z/grown; `a` stays the CALLER's to free — loadKvCache's
  // pending[] holds it).
  let z: MlxArray | null = null;
  let grown: MlxArray | null = null;
  try {
    z = ops.zeros([B, H, cap, D], a.dtype);
    grown = ops.sliceUpdate(z, a, [0, 0, 0, 0], [B, H, S, D]);
    z.dispose();
    z = null;
    grown.eval();
    a.dispose();
    const out = grown;
    grown = null;
    return out;
  } finally {
    z?.dispose();
    grown?.dispose();
  }
}

/** Reload by STREAMED COPY (see the header note): every tensor is copied
 *  into an mlx-owned leaf; the mapping is read-only, its pages dropped
 *  per-tensor, and unmapped before returning — the caches own their bytes
 *  outright (no dtor contract, no pinned mapping, nothing to retain).
 *  `model` is anything with makeCache() — the entry count is validated
 *  against the DONOR cache list (model.layers.length was wrong for
 *  KV-shared models like e4b, whose makeCache() returns donors only). */
export function loadKvCache(
  path: string,
  model: { makeCache(): Cache[] },
  expect: KvLoadExpect = {},
): LoadedKvCache {
  const header = readKvHeader(path);
  for (const key of ["configFingerprint", "tokenizerHash", "ns"] as const) {
    if (expect[key] !== undefined && header[key] !== expect[key])
      throw new Error(`${path}: ${key} mismatch (file ${header[key]}, expected ${expect[key]})`);
  }
  const proto = model.makeCache();
  const cacheCount = proto.length;
  for (const c of proto) c.dispose();
  if (header.caches.length !== cacheCount)
    throw new Error(`${path}: ${header.caches.length} cached layers but model has ${cacheCount}`);

  const mmap = MmapFile.open(path, "ro");
  const dataStart = header.dataStart;
  // Every tensor materialized for the CURRENT entry, drained on any throw
  // (2026-07-07 review: a hash mismatch under --ssd-cache-verify — or any
  // per-tensor failure — orphaned the entry's already-built tensors: the
  // catch below only saw completed caches). Cleared once the entry's cache
  // takes ownership; disposing an array withStepCapacity already consumed
  // is safe (dispose is idempotent).
  const pending: MlxArray[] = [];
  const arr = (slot: TensorSlot): MlxArray => {
    const view = mmap.view(dataStart + slot.off, slot.bytes);
    if (expect.verify && hash64(view) !== slot.hash)
      throw new Error(`${path}: tensor hash mismatch at offset ${slot.off}`);
    // mlx_array_new_data COPIES synchronously — the view only has to
    // outlive this call, so the mapping can be advised/unmapped freely.
    const a = MlxArray.fromBytesCopy(view, slot.shape, slot.dtype as Dtype);
    pending.push(a);
    // Drop the just-read clean pages so the load's transient stays at
    // live entry + one tensor (ALIGN = 16 KiB == the arm64 page size, so
    // every tensor offset is page-aligned by construction).
    const len = Math.min(alignUp(slot.bytes), mmap.size - (dataStart + slot.off));
    mmap.advise(dataStart + slot.off, len, MADV_DONTNEED);
    return a;
  };
  /** withStepCapacity whose (possibly fresh) result is pending-tracked. */
  const grownArr = (slot: TensorSlot, offset: number): MlxArray => {
    const g = withStepCapacity(arr(slot), offset);
    pending.push(g);
    return g;
  };
  const triple = (slots: TensorSlot[], at: number): ops.QuantizedTensor =>
    ({ packed: arr(slots[at]!), scales: arr(slots[at + 1]!), biases: arr(slots[at + 2]!) });

  const caches: Cache[] = [];
  try {
    for (const e of header.caches) {
      const t = e.tensors;
      switch (e.kind) {
        case "kv": {
          const c = new KVCache();
          c.restoreState(
            grownArr(t[0]!, e.offset),
            grownArr(t[1]!, e.offset),
            e.offset,
          );
          caches.push(c);
          break;
        }
        case "rotating": {
          const c = new RotatingKVCache(e.maxSize!);
          c.restoreState(arr(t[0]!), arr(t[1]!), e.offset, e.idx!);
          caches.push(c);
          break;
        }
        case "qkv": {
          const c = new QuantizedKVCache(e.groupSize!, e.bits!);
          c.restoreState(triple(t, 0), triple(t, 3), e.offset);
          caches.push(c);
          break;
        }
        case "rotating-qkv": {
          const c = new RotatingQuantizedKVCache(e.maxSize!, e.groupSize!, e.bits!);
          c.restoreState(triple(t, 0), triple(t, 3), e.offset, e.idx!);
          caches.push(c);
          break;
        }
        case "ssm": {
          const c = new SSMCache();
          c.conv = arr(t[0]!);
          c.recurrent = arr(t[1]!);
          c.offset = e.offset;
          caches.push(c);
          break;
        }
        case "turboquant": {
          const c = new TurboQuantKVCache(e.kBits!, e.vBits!);
          const kv: TurboQuantTensor = {
            kIdx: arr(t[0]!), kScales: arr(t[1]!), kZeros: arr(t[2]!),
            vPacked: arr(t[3]!), vScales: arr(t[4]!),
          };
          c.restoreState(kv, e.offset, e.headDim!);
          caches.push(c);
          break;
        }
        default:
          throw new Error(`${path}: unknown cache kind ${(e as { kind: string }).kind}`);
      }
      // This entry's tensors are now owned by its cache — stop tracking them
      // (the catch must not double-free through both pending AND caches).
      pending.length = 0;
    }
  } catch (err) {
    for (const a of pending) a.dispose(); // the mid-entry orphans
    for (const c of caches) c.dispose();
    throw err;
  } finally {
    mmap.unmap(); // every tensor was copied out — nothing aliases the file
  }
  return { tokens: header.tokens, header, caches };
}
