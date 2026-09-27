// Rotating caches expose their live window through temporalView: the newest
// min(offset, maxSize) positions in chronological order, whatever the ring's
// physical layout. Every expectation is cut from the full token history, so it
// is independent of ring mechanics. Cases cover an oversized first block,
// successive chunks and in-place wrap, then the owners that consume the view:
// batched merge and extraction (the shared join path), aligned rows, clone,
// SSD restore, conversion to quantized storage and donor capture.
import { afterAll, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { RotatingKVCache } from "../../src/state/rotating-kv";
import { RotatingQuantizedKVCache } from "../../src/state/rotating-quantized-kv";
import { BatchedRotatingCache } from "../../src/state/batched-rotating";
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

/** Positions [from, to) as [1, H, n, D]; values carry the position, head and
 * lane, so a missing, stale or misordered row cannot compare equal. */
function block(from: number, to: number, sign: 1 | -1): MlxArray {
  const n = to - from, data = new Float32Array(H * n * D);
  for (let h = 0; h < H; h++) for (let i = 0; i < n; i++) for (let d = 0; d < D; d++)
    data[(h * n + i) * D + d] = sign * (from + i + h * 0.25 + d / 128);
  return MlxArray.fromFloat32(data, [1, H, n, D]);
}
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
function expectPlain(label: string, [keys, values]: [MlxArray, MlxArray], offset: number) {
  const [from, to] = windowOf(offset);
  using k = block(from, to, 1);
  using v = block(from, to, -1);
  expect({ label, shape: keys.shape, keys: floats(keys), values: floats(values) })
    .toEqual({ label, shape: k.shape, keys: floats(k), values: floats(v) });
}
function expectQuantized(label: string, [keys, values]: [ops.QuantizedTensor, ops.QuantizedTensor], offset: number) {
  const [from, to] = windowOf(offset);
  using k = block(from, to, 1);
  using v = block(from, to, -1);
  const qk = ops.quantize(k, GROUP, BITS), qv = ops.quantize(v, GROUP, BITS);
  try {
    expect({ label, width: keys.packed.shape[2], keys: tripleSha(keys), values: tripleSha(values) })
      .toEqual({ label, width: to - from, keys: tripleSha(qk), values: tripleSha(qv) });
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
  using k = block(from, from + n, 1);
  using v = block(from, from + n, -1);
  if (cache instanceof RotatingKVCache) for (const a of cache.updateAndFetch(k, v)) a.dispose();
  else for (const t of cache.updateAndFetchQuantized(k, v)) disposeTriple(t);
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
    const cache = drive(() => new RotatingQuantizedKVCache(W, GROUP, BITS), writes, (c, offset, step) => {
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
    const quantized = cache.toQuantized(GROUP, BITS);
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

test("quantized rows merge through their newest windows", () => {
  const names = ["initial oversize", "successive chunks"];
  const solos = names.map(name => drive(() => new RotatingQuantizedKVCache(W, GROUP, BITS), CASES[name]!, () => {}));
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
