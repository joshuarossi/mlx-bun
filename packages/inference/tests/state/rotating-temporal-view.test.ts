// Rotating caches expose their live window through temporalView: the newest
// min(offset, maxSize) positions in chronological order, whatever the ring's
// physical layout. Every expectation is cut from the full token history, so it
// is independent of ring mechanics. Cases cover an oversized first block,
// successive chunks and in-place wrap, then the owners that consume the view:
// batched merge and extraction (the shared join path), aligned rows, clone,
// SSD restore, conversion to quantized storage and donor capture.
import { Dtype } from "@mlx-bun/mlx/ffi";
import { unfusedAffineKernels } from "../../src/state/affine-attention";
import { afterAll, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { RotatingKVCache } from "../../src/state/rotating-kv";
import { RotatingQuantizedKVCache } from "../../src/state/rotating-quantized-kv";
import { BatchedRotatingCache } from "../../src/state/batched-rotating";
import { rollbackRotatingRing } from "../../src/state/rotating-row-transaction";
import { BatchedRotatingQuantCache } from "../../src/state/batched-rotating-quant";
import { alignRotatingRows, rotatingSourcePosition } from "../../src/state/rotating-kv-layout";
import { plainRowStorage, quantizedRowStorage, temporalStorageView } from "../../src/state/batched-row-storage";
import { cloneKvCaches, loadKvCache, saveKvCache } from "../../src/state/persistence";
import { disposeTriple } from "../../src/state/quantized-tensor";
import { KVCache } from "../../src/state/kv";
import { TurboQuantKVCache } from "../../src/state/turboquant-kv";

const W = 8, H = 2, D = 64, GROUP = 64, BITS = 8;
const scratch = mkdtempSync(join(tmpdir(), "rotating-view-"));
afterAll(() => rmSync(scratch, { recursive: true, force: true }));

const ones = (n: number) => Array<number>(n).fill(1);
/** Write sequences (block lengths; 1 is an in-place decode write). */
const CASES: Record<string, number[]> = {
  "initial oversize": [13],
  "exactly W-1": [7],
  "exactly W": [8],
  "W+1": [9],
  "successive chunks": [5, 6, 9],
  "after in-place wrap": [5, ...ones(10)],
  "chunk after wrap": [5, ...ones(6), 4],
  "decode after oversize": [13, 1, 1],
  "decode across W": [7, 1, 1],
  "mixed": [3, 1, 12, 1, 1, 20, 1],
};

/** Rows tagged per position as [1, H, n, D]; values carry the tag, head and
 * lane, so a missing, stale or misordered row cannot compare equal. A position
 * rewritten after a trim or rollback carries a new generation in its tag. */
function blockOf(tags: readonly number[], sign: 1 | -1): MlxArray {
  const n = tags.length, data = new Float32Array(H * n * D);
  for (let h = 0; h < H; h++) for (let i = 0; i < n; i++) for (let d = 0; d < D; d++)
    data[(h * n + i) * D + d] = sign * (tags[i]! + h * 0.25 + d / 128);
  return MlxArray.fromFloat32(data, [1, H, n, D]);
}
const range = (from: number, to: number) => Array.from({ length: to - from }, (_, i) => from + i);
const block = (from: number, to: number, sign: 1 | -1) => blockOf(range(from, to), sign);
/** One position per row, as a batched decode step writes it. */
function rowsAt(positions: number[], sign: 1 | -1): MlxArray {
  const rows = positions.map(p => block(p, p + 1, sign));
  try { return ops.concatAxis(rows, 0); } finally { for (const row of rows) row.dispose(); }
}
const floats = (a: MlxArray) => { using c = ops.contiguous(a); return Array.from(c.toFloat32()); };
const sha = (a: MlxArray) => { using c = ops.contiguous(a); return new Bun.CryptoHasher("sha256").update(c.rawBytes()).digest("hex"); };
const tripleSha = (t: ops.QuantizedTensor) => [sha(t.packed), sha(t.scales), sha(t.biases)];

/** The live window after `offset` positions, from the history alone. */
function windowOf(offset: number): [number, number] { return [offset - Math.min(offset, W), offset]; }
function expectPlain(label: string, view: [MlxArray, MlxArray], offset: number) {
  expectPlainTags(label, view, range(0, offset));
}
/** The live window of an explicit history: its newest min(length, W) tags. */
function expectPlainTags(label: string, [keys, values]: [MlxArray, MlxArray], history: readonly number[]) {
  const live = history.slice(history.length - Math.min(history.length, W));
  using k = blockOf(live, 1);
  using v = blockOf(live, -1);
  expect({ label, shape: keys.shape, keys: floats(keys), values: floats(values) })
    .toEqual({ label, shape: k.shape, keys: floats(k), values: floats(v) });
}
function expectQuantized(label: string, view: [ops.QuantizedTensor, ops.QuantizedTensor], offset: number) {
  expectQuantizedTags(label, view, range(0, offset));
}
function expectQuantizedTags(label: string, [keys, values]: [ops.QuantizedTensor, ops.QuantizedTensor], history: readonly number[]) {
  const live = history.slice(history.length - Math.min(history.length, W));
  using k = blockOf(live, 1);
  using v = blockOf(live, -1);
  const qk = ops.quantize(k, GROUP, BITS), qv = ops.quantize(v, GROUP, BITS);
  try {
    expect({ label, width: keys.packed.shape[2], keys: tripleSha(keys), values: tripleSha(values) })
      .toEqual({ label, width: live.length, keys: tripleSha(qk), values: tripleSha(qv) });
  } finally { disposeTriple(qk); disposeTriple(qv); }
}
const plainView = (cache: RotatingKVCache, label: string, offset: number) => {
  const view = cache.temporalView();
  try { expectPlain(label, view, offset); } finally { for (const a of view) a.dispose(); }
};
const quantizedView = (cache: RotatingQuantizedKVCache, label: string, offset: number) => {
  const view = cache.temporalView();
  try { expectQuantized(label, view, offset); } finally { disposeTriple(view[0]); disposeTriple(view[1]); }
};

function write(cache: RotatingKVCache | RotatingQuantizedKVCache, from: number, n: number) {
  writeTags(cache, range(from, from + n));
}
function writeTags(cache: RotatingKVCache | RotatingQuantizedKVCache, tags: readonly number[]) {
  using k = blockOf(tags, 1);
  using v = blockOf(tags, -1);
  if (cache instanceof RotatingKVCache) for (const a of cache.updateAndFetch(k, v)) a.dispose();
  else for (const t of cache.updateAndFetchQuantized(k, v)) disposeTriple(t);
}
/** Check a cache's view against an explicit history, for either storage. */
function viewTags(cache: RotatingKVCache | RotatingQuantizedKVCache, label: string, history: readonly number[]) {
  if (cache instanceof RotatingKVCache) {
    const view = cache.temporalView();
    try { expectPlainTags(label, view, history); } finally { for (const a of view) a.dispose(); }
  } else {
    const view = cache.temporalView();
    try { expectQuantizedTags(label, view, history); } finally { disposeTriple(view[0]); disposeTriple(view[1]); }
  }
}
const STORAGE = {
  plain: () => new RotatingKVCache(W),
  quantized: () => new RotatingQuantizedKVCache(W, GROUP, BITS, unfusedAffineKernels(BITS, GROUP, Dtype.bfloat16)),
} as const;
/** A writer that tags every newly written position with its generation. */
function history(cache: RotatingKVCache | RotatingQuantizedKVCache) {
  const tags: number[] = [];
  let generation = 0;
  return {
    tags,
    write(n: number) {
      const next = Array.from({ length: n }, (_, i) => tags.length + i + 1000 * generation);
      writeTags(cache, next);
      tags.push(...next);
    },
    /** Drop the newest n positions; rewrites get a new generation. */
    drop(n: number) { tags.length -= n; generation++; },
  };
}
/** Drive a fresh cache through a case, checking after every write. */
function drive<C extends RotatingKVCache | RotatingQuantizedKVCache>(make: () => C, writes: number[],
  check: (cache: C, offset: number, step: string) => void): C {
  const cache = make();
  let offset = 0;
  for (const [i, n] of writes.entries()) {
    write(cache, offset, n);
    offset += n;
    check(cache, offset, `write ${i} (+${n})`);
  }
  return cache;
}

test("plain storage: the view is the newest window after every write, as the shared source position reads it", () => {
  for (const [name, writes] of Object.entries(CASES)) {
    const cache = drive(() => new RotatingKVCache(W), writes, (c, offset, step) => {
      plainView(c, `${name}: ${step}`, offset);
      // The batched owners borrow the same window through rotatingSourcePosition.
      const state = rotatingSourcePosition(c), range = { from: Math.max(0, state.activeLength - Math.min(offset, W)), to: state.activeLength };
      using k = temporalStorageView(plainRowStorage, c.keys!, state, range);
      using v = temporalStorageView(plainRowStorage, c.values!, state, range);
      expectPlain(`${name}: ${step} (source position)`, [k, v], offset);
    });
    cache.dispose();
  }
});

test("quantized storage: the view is the quantized newest window after every write", () => {
  for (const [name, writes] of Object.entries(CASES)) {
    const cache = drive(() => new RotatingQuantizedKVCache(W, GROUP, BITS, unfusedAffineKernels(BITS, GROUP, Dtype.bfloat16)), writes, (c, offset, step) => {
      quantizedView(c, `${name}: ${step}`, offset);
      const state = rotatingSourcePosition(c), range = { from: Math.max(0, state.activeLength - Math.min(offset, W)), to: state.activeLength };
      const k = temporalStorageView(quantizedRowStorage, c.keys!, state, range);
      const v = temporalStorageView(quantizedRowStorage, c.values!, state, range);
      try { expectQuantized(`${name}: ${step} (source position)`, [k, v], offset); }
      finally { disposeTriple(k); disposeTriple(v); }
    });
    cache.dispose();
  }
});

test("conversion, clone, SSD restore and donor capture keep the newest window", () => {
  for (const [name, writes] of Object.entries(CASES)) {
    const offset = writes.reduce((a, b) => a + b, 0);
    const cache = drive(() => new RotatingKVCache(W), writes, () => {});
    // Donor rows are the live window, full width valid.
    const donor = cache.captureDonorRows();
    try {
      expectPlain(`${name}: donor rows`, [donor.keys, donor.values], offset);
      expect({ name, starts: donor.starts, ends: donor.ends, offsets: donor.offsets })
        .toEqual({ name, starts: [0], ends: [Math.min(offset, W)], offsets: [offset] });
    } finally { donor.keys.dispose(); donor.values.dispose(); }
    // Clone and SSD restore carry the raw ring; the view reads the same window.
    const [clone] = cloneKvCaches([cache]) as [RotatingKVCache];
    plainView(clone, `${name}: clone`, offset);
    clone.dispose();
    const path = join(scratch, `${name.replaceAll(" ", "-")}.safetensors`);
    saveKvCache(path, Array.from({ length: offset }, (_, i) => i), [cache], { modelId: "synthetic" });
    const loaded = loadKvCache(path, { makeCache: () => [new RotatingKVCache(W)] }, { modelId: "synthetic", verify: true });
    plainView(loaded.caches[0] as RotatingKVCache, `${name}: SSD restore`, offset);
    for (const c of loaded.caches) c.dispose();
    // Conversion quantizes the ring as laid out; its view is the quantized window.
    const quantized = cache.toQuantized(GROUP, BITS, unfusedAffineKernels);
    quantizedView(quantized, `${name}: converted`, offset);
    const attention = quantized.captureDonorAttention();
    expect({ name, width: attention.width }).toEqual({ name, width: Math.min(offset, W) });
    attention.dispose();
    quantized.dispose();
  }
});

test("TurboQuant conversion encodes the newest window of a rotating cache", () => {
  // The public conversion consumes the plain view. (A wrapped source keeps its
  // absolute offset over min(offset, W) encoded rows; app maintenance never
  // converts rotating layers.) The encoding must equal one of exactly the
  // window's rows, built from the history alone.
  for (const [name, writes] of Object.entries(CASES)) {
    const [from, to] = windowOf(writes.reduce((a, b) => a + b, 0));
    const turbo = TurboQuantKVCache.fromKVCache(drive(() => new RotatingKVCache(W), writes, () => {}), 8, 3);
    const reference = new KVCache();
    using k = block(from, to, 1);
    using v = block(from, to, -1);
    for (const a of reference.updateAndFetch(k, v)) a.dispose();
    const expected = TurboQuantKVCache.fromKVCache(reference, 8, 3);
    expect({ name, state: turbo.state().map(sha) }).toEqual({ name, state: expected.state().map(sha) });
    turbo.dispose();
    expected.dispose();
  }
});

test("a late join merges each row's newest window, and extraction and decode keep it", () => {
  // The shared join path: an adopted row and a joiner, each read through its own view.
  const pairs: [string, string][] = [["initial oversize", "exactly W-1"], ["decode after oversize", "successive chunks"],
    ["mixed", "initial oversize"], ["exactly W", "chunk after wrap"]];
  for (const [first, second] of pairs) {
    const label = `${first} + ${second}`;
    const solos = [first, second].map(name => drive(() => new RotatingKVCache(W), CASES[name]!, () => {}));
    const offsets = [first, second].map(name => CASES[name]!.reduce((a, b) => a + b, 0));
    const views = solos.map(solo => solo.temporalView());
    const batched = BatchedRotatingCache.merge(views.map(([keys, values]) => ({ keys, values })), offsets, W);
    for (const view of views) for (const a of view) a.dispose();
    for (const solo of solos) solo.dispose();
    const extractAll = (step: string, at: number[]) => {
      for (const [row, offset] of at.entries()) {
        const extracted = batched.extractRow(row)!;
        plainView(extracted, `${label}: row ${row} ${step}`, offset);
        extracted.dispose();
      }
    };
    extractAll("merged", offsets);
    for (let step = 0; step < 3 * W; step++) {
      using k = rowsAt(offsets, 1);
      using v = rowsAt(offsets, -1);
      for (const a of batched.updateAndFetch(k, v)) a.dispose();
      for (let row = 0; row < offsets.length; row++) offsets[row]! += 1;
      extractAll(`decode ${step}`, offsets);
    }
    batched.dispose();
  }
});

/** One forward on a batched ring, as attention reads it: write `N` positions per
 * row (tagged with their absolute position) and return, per row and query, the
 * tags of the columns its mask admits. The cache's offsets advance by `N`. */
function forwardSeen(batched: BatchedRotatingCache, offsets: number[], N: number): number[][][] {
  const kRows = offsets.map(offset => block(offset, offset + N, 1)), vRows = offsets.map(offset => block(offset, offset + N, -1));
  using k = ops.concatAxis(kRows, 0);
  using v = ops.concatAxis(vRows, 0);
  for (const a of [...kRows, ...vRows]) a.dispose();
  const mask = batched.makeMask(N, W);
  if (mask.mode !== "array") throw new Error("expected an array mask");
  using allowed = mask.arr!;
  const [keys, values] = batched.updateAndFetch(k, v);
  using _values = values;
  using keysOwned = keys;
  using numeric = allowed.astype(keysOwned.dtype);
  const S = keysOwned.shape[2]!, tags = floats(keysOwned), flags = floats(numeric);
  return offsets.map((_, row) => Array.from({ length: N }, (_, i) => {
    const columns: number[] = [];
    for (let col = 0; col < S; col++)
      if (flags[(row * N + i) * S + col]) columns.push(Math.round(tags[((row * H) * S + col) * D]!));
    return columns.toSorted((a, b) => a - b);
  }));
}
/** What each query must attend: its own newest window, from the row's history. */
const windows = (offsets: readonly number[], N: number) =>
  offsets.map(offset => Array.from({ length: N }, (_, i) => range(Math.max(0, offset + i - W + 1), offset + i + 1)));

function mergedRows(rowWrites: number[][]): { batched: BatchedRotatingCache; offsets: number[] } {
  const solos = rowWrites.map(writes => drive(() => new RotatingKVCache(W), writes, () => {}));
  const offsets = rowWrites.map(writes => writes.reduce((a, b) => a + b, 0));
  const views = solos.map(solo => solo.temporalView());
  const batched = BatchedRotatingCache.merge(views.map(([keys, values]) => ({ keys, values })), offsets, W);
  for (const view of views) for (const a of view) a.dispose();
  for (const solo of solos) solo.dispose();
  return { batched, offsets };
}

test("a block write after in-place decode masks each merged row to its own window", () => {
  // A joiner with fewer positions than the window keeps left padding; once
  // in-place decode rotates the ring, a verify block reorders the ring into
  // temporal order and its mask must drop the same history column the block drops.
  for (let decode = 0; decode <= W; decode++) {
    const label = `after ${decode} decode steps`;
    const { batched, offsets } = mergedRows([CASES["mixed"]!, [3]]);
    try {
      for (let step = 0; step < decode; step++) {
        forwardSeen(batched, offsets, 1);
        for (let row = 0; row < offsets.length; row++) offsets[row]! += 1;
      }
      const expected = windows(offsets, 3);
      expect({ label, seen: forwardSeen(batched, offsets, 3) }).toEqual({ label, seen: expected });
    } finally { batched.dispose(); }
  }
});

test("verify rounds that keep different prefixes per row leave every row's window intact", () => {
  // The scheduler's shape: decode, a wide verify block, a per-row rollback, and
  // decode again, repeatedly, on rows of different lengths.
  const rounds: [number, number[]][] = [[3, [3, 1]], [4, [4, 1]], [2, [2, 2]], [5, [1, 5]], [3, [1, 1]]];
  for (const [first, second] of [[CASES["mixed"]!, [3]], [CASES["mixed"]!, [5]], [[13], [4]]] as [number[], number[]][]) {
    for (let decode = 0; decode <= W; decode++) {
      const label = `${first.join("+")} with ${second.join("+")}, ${decode} decode steps`;
      let { batched, offsets } = mergedRows([first, second]);
      try {
        const decodeOnce = () => {
          expect({ label, seen: forwardSeen(batched, offsets, 1) }).toEqual({ label, seen: windows(offsets, 1) });
          offsets = offsets.map(offset => offset + 1);
        };
        for (let step = 0; step < decode; step++) decodeOnce();
        for (const [round, [width, keep]] of rounds.entries()) {
          const before = [...offsets];
          expect({ label, round, seen: forwardSeen(batched, offsets, width) }).toEqual({ label, round, seen: windows(offsets, width) });
          batched = rollbackRotatingRing(batched, before, keep);
          offsets = before.map((offset, row) => offset + keep[row]!);
          decodeOnce(); decodeOnce();
        }
      } finally { batched.dispose(); }
    }
  }
});

test("quantized rows merge through their newest windows", () => {
  const names = ["initial oversize", "successive chunks"];
  const solos = names.map(name => drive(() => new RotatingQuantizedKVCache(W, GROUP, BITS, unfusedAffineKernels(BITS, GROUP, Dtype.bfloat16)), CASES[name]!, () => {}));
  const offsets = names.map(name => CASES[name]!.reduce((a, b) => a + b, 0));
  const views = solos.map(solo => solo.temporalView());
  const batched = BatchedRotatingQuantCache.merge(views.map(([keys, values]) => ({ keys, values })), offsets, W, GROUP, BITS);
  for (const [keys, values] of views) { disposeTriple(keys); disposeTriple(values); }
  for (const solo of solos) solo.dispose();
  for (const [row, offset] of offsets.entries()) {
    const extracted = batched.extractRow(row)!;
    quantizedView(extracted, `${names[row]}: merged quantized row`, offset);
    extracted.dispose();
  }
  batched.dispose();
});

test("an extracted row that kept an oversized block still exposes its newest window", () => {
  // Aligned rows take a multi-token block after alignment (a later prefill
  // chunk); extraction without a limit keeps the oversized active block.
  for (const [prefix, blockLength] of [[3, 12], [0, 13], [6, 2], [9, 20]] as const) {
    const label = `prefix ${prefix} + block ${blockLength}`;
    const solo = new RotatingKVCache(W);
    if (prefix) write(solo, 0, prefix);
    const [aligned] = alignRotatingRows([solo]);
    using k = block(prefix, prefix + blockLength, 1);
    using v = block(prefix, prefix + blockLength, -1);
    for (const a of aligned!.updateAndFetch(k, v)) a.dispose();
    const extracted = aligned!.extract() as RotatingKVCache;
    aligned!.dispose();
    let offset = prefix + blockLength;
    plainView(extracted, `${label}: extracted`, offset);
    for (const n of [1, 5, 1]) { write(extracted, offset, n); offset += n; plainView(extracted, `${label}: +${n}`, offset); }
    extracted.dispose();
  }
});

test("a pre-wrap trim, then view and append, exposes the rewritten window (plain and quantized)", () => {
  for (const [storage, make] of Object.entries(STORAGE)) {
    for (const [prefill, trimmed, appends] of [[[6], 2, [1, 3, 4]], [[7], 3, [1, 1, 6]], [[3, 1, 1], 1, [5, 1]],
      [[2, 2, 2], 4, [9]]] as const) {
      const label = `${storage}: ${prefill.join("+")} trim ${trimmed}`;
      const cache = make(), h = history(cache);
      for (const n of prefill) h.write(n);
      expect({ label, trimmable: cache.isTrimmable() }).toEqual({ label, trimmable: true });
      cache.trim(trimmed);
      h.drop(trimmed);
      viewTags(cache, `${label}: after trim`, h.tags);
      for (const n of appends) { h.write(n); viewTags(cache, `${label}: +${n}`, h.tags); }
      cache.dispose();
    }
  }
});

test("a rollback after an oversized concat, then view and append, exposes the kept window (plain and quantized)", () => {
  // The verify-block rollback: a multi-token write, then trim(k, bypass).
  for (const [storage, make] of Object.entries(STORAGE)) {
    for (const [before, verify, rejected, appends] of [[[6], 4, 2, [1, 3]], [[12], 3, 2, [1, 4, 1]],
      [[5, ...ones(5)], 4, 3, [1, 2]], [[7], 5, 5, [1, 9]], [[20], 4, 1, [1]]] as const) {
      const label = `${storage}: ${before.length > 2 ? `${before[0]}+${before.length - 1}x1` : before.join("+")} verify ${verify} reject ${rejected}`;
      const cache = make(), h = history(cache);
      for (const n of before) h.write(n);
      h.write(verify);
      viewTags(cache, `${label}: verify block`, h.tags);
      cache.trim(rejected, true);
      h.drop(rejected);
      viewTags(cache, `${label}: after rollback`, h.tags);
      for (const n of appends) { h.write(n); viewTags(cache, `${label}: +${n}`, h.tags); }
      cache.dispose();
    }
  }
});

test("clone and SSD restore keep the window and accept further writes; the source is unchanged (plain and quantized)", () => {
  for (const [storage, make] of Object.entries(STORAGE)) {
    for (const [name, writes] of Object.entries(CASES)) {
      const label = `${storage}: ${name}`;
      const source = make(), h = history(source);
      for (const n of writes) h.write(n);
      const snapshot = [...h.tags];
      const [clone] = cloneKvCaches([source]) as [RotatingKVCache | RotatingQuantizedKVCache];
      const path = join(scratch, `${storage}-${name.replaceAll(" ", "-")}-continue.safetensors`);
      saveKvCache(path, snapshot.map((_, i) => i), [source], { modelId: "synthetic" });
      const loaded = loadKvCache(path, { makeCache: () => [make()] }, { modelId: "synthetic", verify: true });
      const restored = loaded.caches[0] as RotatingKVCache | RotatingQuantizedKVCache;
      for (const [copy, kind] of [[clone, "clone"], [restored, "SSD restore"]] as const) {
        const tags = [...snapshot];
        viewTags(copy, `${label}: ${kind}`, tags);
        for (const n of [1, 4, 1, 9]) {
          const next = Array.from({ length: n }, (_, i) => tags.length + i + 5000);
          writeTags(copy, next);
          tags.push(...next);
          viewTags(copy, `${label}: ${kind} +${n}`, tags);
        }
        copy.dispose();
      }
      viewTags(source, `${label}: source after copies advanced`, snapshot);
      source.dispose();
    }
  }
});
