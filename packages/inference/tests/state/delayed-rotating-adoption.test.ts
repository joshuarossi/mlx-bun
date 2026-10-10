// A delayed rotating wrapper that adopts one solo row attends and stores
// exactly as that row's serial lifecycle does: main's delayed-rotating-model
// contract (wrapper hidden/logits/state equal the serially maintained solo
// caches), here including a ring the default tail-split prefill has already
// wrapped (its physical columns are not in temporal order), a single block
// past the window, a row converting during decode after the wrap, and a row
// converted before adoption; in float16 and bfloat16, for a small geometry and
// Llama-3.2-3B's (24 query heads, 8 KV heads, head dim 128). Whether a changed
// column order changes the result depends on the data, so every case runs
// eight decode steps.
import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import * as ops from "@mlx-bun/mlx/ops";
import { Dtype } from "@mlx-bun/mlx/ffi";
import type { MlxArray } from "@mlx-bun/mlx/array";
import { RotatingKVCache } from "../../src/state/rotating-kv";
import { RotatingQuantizedKVCache } from "../../src/state/rotating-quantized-kv";
import { createKvMaintenance } from "../../src/state/kv-maintenance";
import { captureKvAttention } from "../../src/state/kv-attention-view";
import { disposeTriple } from "../../src/state/quantized-tensor";
import { alignRotatingRows } from "../../src/state/rotating-kv-layout";
import type { Cache } from "../../src/contracts/mlx/cache";
import { DelayedRotatingQuantizedKVCache } from "../../src/state/delayed-rotating-quantized-kv";
import { cloneKvCaches } from "../../src/state/persistence";

const W = 8;
const digest = (a: MlxArray) => { using c = ops.contiguous(a); return createHash("sha256").update(c.rawBytes()).digest("hex"); };
/** One attention step as the model runs it: the group mask from the cache
 * before its write, then the cache's own attention view. */
const attend = (cache: Cache, q: MlxArray, k: MlxArray, v: MlxArray, scale: number): string => {
  const mask = cache.makeMask(k.shape[2]!, W);
  try {
    const view = captureKvAttention(cache, k, v);
    try { using out = view.attend(q, scale, mask); return digest(out); } finally { view.dispose(); }
  } finally { mask.arr?.dispose(); }
};
/** A solo rotating row's logical state: offset, reuse floor and its newest window. */
const logical = (cache: Cache) => {
  const describe = (planes: MlxArray[]) => ({ offset: cache.offset, minimum: cache.minimumReusableOffset ?? 0,
    kind: cache.constructor.name, planes: planes.map(digest) });
  if (cache instanceof RotatingQuantizedKVCache) {
    const [k, v] = cache.temporalView();
    try { return describe([k.packed, k.scales, k.biases, v.packed, v.scales, v.biases]); } finally { disposeTriple(k); disposeTriple(v); }
  }
  const [k, v] = (cache as RotatingKVCache).temporalView();
  try { return describe([k, v]); } finally { k.dispose(); v.dispose(); }
};
/** Write a block into a solo row in whichever precision it holds. */
const write = (cache: Cache, k: MlxArray, v: MlxArray) => {
  if (cache instanceof RotatingQuantizedKVCache) { const [kq, vq] = cache.updateAndFetchQuantized(k, v); disposeTriple(kq); disposeTriple(vq); }
  else for (const a of (cache as RotatingKVCache).updateAndFetch(k, v)) a.dispose();
};

const CASES: [string, number[], number][] = [
  // label, prefill chunks (a trailing 1 is the tail-split token), conversion start
  ["tail split past the window", [11, 1], 14],
  ["one block past the window", [12], 14],
  ["within the window, converting after the wrap", [5, 1], 9],
  ["converted in prefill before adoption", [6, 6, 1], 6],
];
const DTYPES: [string, Dtype][] = [["float16", Dtype.float16], ["bfloat16", Dtype.bfloat16]];
const GEOMETRIES = [{ name: "4Q/2KV/D64", heads: 4, kvHeads: 2, dim: 64 }, { name: "24Q/8KV/D128", heads: 24, kvHeads: 8, dim: 128 }];
for (const [dtypeName, dtype] of DTYPES) for (const g of GEOMETRIES) for (const bits of [4, 8]) for (const [label, chunks, start] of CASES)
test(`${dtypeName} ${g.name} KV${bits} ${label}: the adopted wrapper equals the serial row`, () => {
  const steps = 8, scale = 1 / Math.sqrt(g.dim);
  const tensor = (n: number, seed: number, heads = g.kvHeads) => {
    using key = ops.randomKey(BigInt(seed)); return ops.randomNormal([1, heads, n, g.dim], dtype, 0, 1, key);
  };
  const options = { kvBits: bits, kvGroupSize: 64, quantizedKvStart: start };
  const serial = createKvMaintenance(options);
  // Two identical solo rows: prefill writes, maintained after each non-final
  // chunk and before the first decode (the serial loop and the batch cohort).
  const prefilled = () => {
    const caches: Cache[] = [new RotatingKVCache(W)];
    let seed = 1, position = 0;
    for (const [index, n] of chunks.entries()) {
      using k = tensor(n, seed++), v = tensor(n, seed++);
      write(caches[0]!, k, v);
      position += n;
      if (index < chunks.length - 1) serial(caches);
    }
    serial(caches);
    expect(caches[0]!.offset).toBe(position);
    return caches;
  };
  const solo = prefilled(), adopted = prefilled();
  try {
    createKvMaintenance(options).prepareBatch!(adopted);
    expect(adopted[0]!.signature()).toStartWith("kv:delayed-rotating");
    for (let t = 0; t < steps; t++) {
      serial(solo); // the serial loop maintains before each decode forward
      using q = tensor(1, 100 + t, g.heads), k = tensor(1, 200 + t), v = tensor(1, 300 + t);
      expect(attend(adopted[0]!, q, k, v, scale), `step ${t} attention`).toBe(attend(solo[0]!, q, k, v, scale));
      const extracted = (adopted[0] as unknown as { extractRow(row: number): Cache }).extractRow(0);
      try { expect(logical(extracted), `step ${t} state`).toEqual(logical(solo[0]!)); } finally { extracted.dispose(); }
    }
  } finally { for (const cache of [...solo, ...adopted]) cache.dispose(); }
});

// Adoption takes views of every physical plane array; whichever view fails,
// the views already taken are released and the caller's source row is intact.
for (const quantized of [false, true]) test(`${quantized ? "quantized" : "plain"} single-row adoption releases its views when one fails and leaves the source intact`, () => {
  const tensor = (n: number, seed: number) => { using key = ops.randomKey(BigInt(seed)); return ops.randomNormal([1, 2, n, 64], Dtype.float16, 0, 1, key); };
  const failures = quantized ? 6 : 2;
  for (let failing = 0; failing < failures; failing++) {
    let rows: Cache[] = [new RotatingKVCache(W)];
    for (const [n, seed] of [[11, 1], [1, 3]] as const) { using k = tensor(n, seed), v = tensor(n, seed + 1); write(rows[0]!, k, v); }
    if (quantized) createKvMaintenance({ kvBits: 4, kvGroupSize: 64, quantizedKvStart: 1 })(rows);
    const source = rows[0]!, before = logical(source);
    const ring = source as unknown as { keys: unknown; values: unknown };
    const arrays = (quantized ? [ring.keys, ring.values].flatMap(t => { const q = t as { packed: MlxArray; scales: MlxArray; biases: MlxArray };
      return [q.packed, q.scales, q.biases]; }) : [ring.keys, ring.values]) as MlxArray[];
    expect(arrays).toHaveLength(failures);
    const taken: MlxArray[] = [];
    arrays.forEach((array, index) => {
      if (index > failing) return;
      const slice = array.slice.bind(array);
      (array as unknown as { slice: unknown }).slice = index === failing
        ? () => { throw new Error("injected view failure"); }
        : (...args: Parameters<MlxArray["slice"]>) => { const view = slice(...args); taken.push(view); return view; };
    });
    try {
      expect(() => alignRotatingRows(rows), `failure at array ${failing}`).toThrow("injected view failure");
    } finally { for (const array of arrays) delete (array as unknown as { slice?: unknown }).slice; }
    expect(taken).toHaveLength(failing);
    for (const view of taken) expect(() => view.handle, `view before array ${failing}`).toThrow("used after dispose");
    expect(logical(source), `source after failure at array ${failing}`).toEqual(before);
    source.dispose(); rows = [];
  }
});

// ---- plain reads while every row is still plain ----------------------------------------
// A softcap graph reads plain keys and values. Before conversion the delayed
// rotating wrapper answers from each row's own ring: an adopted row keeps its
// physical columns and phase (no temporal normalization); several aligned rows
// join along the batch.
const f16 = (b: number, heads: number, n: number, seed: number) => {
  using key = ops.randomKey(BigInt(seed)); return ops.randomNormal([b, heads, n, 64], Dtype.float16, 0, 1, key);
};
const maskDigest = (a: MlxArray) => { using bytes = a.astype(Dtype.uint8); return digest(bytes); };
const rowOf = (a: MlxArray, row: number) => a.slice([row, 0, 0, 0], [row + 1, a.shape[1]!, a.shape[2]!, a.shape[3]!]);
const maskRow = (mask: { mode: "" | "causal" | "array"; arr: MlxArray | null }, row: number) => {
  if (!mask.arr) return { mode: mask.mode, arr: null };
  const start = mask.arr.shape.map(() => 0), end = [...mask.arr.shape];
  if (end.length === 4 && end[0]! > 1) { start[0] = row; end[0] = row + 1; }
  return { mode: mask.mode, arr: mask.arr.slice(start, end) };
};
const soloRows = (lengths: number[], seed: number) => lengths.map((length, index) => {
  const row = new RotatingKVCache(W);
  using k = f16(1, 2, length, seed + 2 * index), v = f16(1, 2, length, seed + 2 * index + 1);
  write(row, k, v);
  return row;
});

for (const [label, chunks] of [["tail split past the window", [11, 1]], ["one block past the window", [12]], ["within the window", [5, 1]]] as const)
test(`B1 plain reads keep the adopted ring's physical bytes and attend as the solo row: ${label}, then an oversize block`, () => {
  const options = { kvBits: 4, kvGroupSize: 64, quantizedKvStart: 1000 };
  const prefilled = () => {
    const caches: Cache[] = [new RotatingKVCache(W)];
    let seed = 1;
    for (const n of chunks) { using k = f16(1, 2, n, seed++), v = f16(1, 2, n, seed++); write(caches[0]!, k, v); }
    return caches;
  };
  const solo = prefilled(), adopted = prefilled();
  try {
    createKvMaintenance(options).prepareBatch!(adopted);
    expect(adopted[0]!.signature()).toStartWith("kv:delayed-rotating");
    for (const [step, n] of [1, 1, 1, 10, 1, 1].entries()) {
      using q = f16(1, 4, n, 100 + step), k = f16(1, 2, n, 200 + step), v = f16(1, 2, n, 300 + step);
      // Each cache's own mask before its write, as the model builds it.
      const am = adopted[0]!.makeMask(n, W), sm = solo[0]!.makeMask(n, W);
      try {
        const [ak, av] = adopted[0]!.updateAndFetch(k, v), [sk, sv] = solo[0]!.updateAndFetch(k, v);
        try {
          expect([digest(ak), digest(av)], `step ${step} (${n} tokens) physical bytes`).toEqual([digest(sk), digest(sv)]);
          using ao = ops.sdpa(q, ak, av, 1 / 8, am.mode, am.arr), so = ops.sdpa(q, sk, sv, 1 / 8, sm.mode, sm.arr);
          expect(digest(ao), `step ${step} attention`).toBe(digest(so));
        } finally { for (const a of [ak, av, sk, sv]) a.dispose(); }
      } finally { am.arr?.dispose(); sm.arr?.dispose(); }
      const extracted = (adopted[0] as unknown as { extractRow(row: number): Cache }).extractRow(0);
      try { expect(logical(extracted), `step ${step} state`).toEqual(logical(solo[0]!)); } finally { extracted.dispose(); }
    }
  } finally { for (const cache of [...solo, ...adopted]) cache.dispose(); }
});

test("B2 plain reads with unequal offsets join the aligned rows and attend as the plain row views do", () => {
  const source = soloRows([3, 11], 20), control = cloneKvCaches(source);
  const group = new DelayedRotatingQuantizedKVCache(W, 64, 4, 1000); group.mergeRows(source);
  const twin = new DelayedRotatingQuantizedKVCache(W, 64, 4, 1000); twin.mergeRows(source);
  try {
    for (const [step, n] of [1, 1, 3, 1, 1, 1, 1, 1].entries()) {
      using q = f16(2, 4, n, 400 + step), k = f16(2, 2, n, 500 + step), v = f16(2, 2, n, 600 + step);
      const mask = group.makeMask(n, W), twinMask = twin.makeMask(n, W);
      try {
        expect(twinMask.mode).toBe(mask.mode);
        if (mask.arr) expect(maskDigest(twinMask.arr!)).toBe(maskDigest(mask.arr));
        const [keys, values] = group.updateAndFetch(k, v);
        try {
          expect(keys.shape[0]).toBe(2);
          // Per row, the plain row view's arithmetic over this read's row.
          const outputs: MlxArray[] = [];
          try {
            for (let row = 0; row < 2; row++) {
              using qr = rowOf(q, row), kr = rowOf(keys, row), vr = rowOf(values, row);
              const m = maskRow(mask, row);
              try { outputs.push(ops.sdpa(qr, kr, vr, 1 / 8, m.mode, m.arr)); } finally { m.arr?.dispose(); }
            }
            using got = ops.concatAxis(outputs, 0);
            const view = twin.appendAndFetch(k, v);
            try { using expected = view.attend(q, 1 / 8, twinMask); expect(digest(got), `step ${step}`).toBe(digest(expected)); }
            finally { view.dispose(); }
          } finally { for (const o of outputs) o.dispose(); }
        } finally { keys.dispose(); values.dispose(); }
      } finally { mask.arr?.dispose(); twinMask.arr?.dispose(); }
      for (let row = 0; row < 2; row++) {
        using kr = rowOf(k, row), vr = rowOf(v, row);
        write(control[row]!, kr, vr);
        const extracted = group.extractRow(row);
        try { expect(logical(extracted), `step ${step} row ${row} state`).toEqual(logical(control[row]!)); } finally { extracted.dispose(); }
      }
    }
  } finally { group.dispose(); twin.dispose(); for (const c of [...source, ...control]) c.dispose(); }
});

test("padded rotating prefill reads plain, finalizes its positions and decodes as the plain row views do", () => {
  const group = new DelayedRotatingQuantizedKVCache(W, 64, 4, 1000), twin = new DelayedRotatingQuantizedKVCache(W, 64, 4, 1000);
  const lengths = [3, 6], control = lengths.map(() => new RotatingKVCache(W));
  try {
    for (const cache of [group, twin]) { cache.preparePrefill({ lengths, rightPadding: [3, 0] }); cache.beginPrefill(); }
    const step = (index: number, n: number, prefill: boolean) => {
      using q = f16(2, 4, n, 700 + index), k = f16(2, 2, n, 800 + index), v = f16(2, 2, n, 900 + index);
      const mask = group.makeMask(n, W), twinMask = twin.makeMask(n, W);
      try {
        const [keys, values] = group.updateAndFetch(k, v);
        try {
          const view = twin.appendAndFetch(k, v);
          try {
            using expected = view.attend(q, 1 / 8, twinMask);
            // The plain row views attend per row; so does this read, row by row.
            for (let row = 0; row < 2; row++) {
              using a = rowOf(expected, row), qr = rowOf(q, row), kr = rowOf(keys, row), vr = rowOf(values, row);
              const m = maskRow(mask, row);
              try { using b = ops.sdpa(qr, kr, vr, 1 / 8, m.mode, m.arr); expect(digest(b), `step ${index} row ${row}`).toBe(digest(a)); }
              finally { m.arr?.dispose(); }
            }
          } finally { view.dispose(); }
        } finally { keys.dispose(); values.dispose(); }
      } finally { mask.arr?.dispose(); twinMask.arr?.dispose(); }
      for (let row = 0; row < 2; row++) {
        const valid = prefill ? lengths[row]! : n;
        using kr = k.slice([row, 0, 0, 0], [row + 1, 2, valid, 64]), vr = v.slice([row, 0, 0, 0], [row + 1, 2, valid, 64]);
        write(control[row]!, kr, vr);
      }
    };
    step(0, 6, true);
    for (const cache of [group, twin]) { cache.finalizePrefill(); cache.endPrefill(); }
    expect(group.rowOffsets).toEqual(lengths);
    for (let index = 1; index <= 7; index++) {
      step(index, 1, false);
      for (let row = 0; row < 2; row++) {
        const extracted = group.extractRow(row);
        try { expect(logical(extracted), `decode ${index} row ${row} state`).toEqual(logical(control[row]!)); } finally { extracted.dispose(); }
      }
    }
  } finally { group.dispose(); twin.dispose(); for (const c of control) c.dispose(); }
});

test("a rotating plain read appends to no row once any row is converted, before or by the scheduled maintenance", () => {
  const snapshot = (group: DelayedRotatingQuantizedKVCache) => ({ offsets: [...group.rowOffsets], pads: [...group.leftPad],
    rows: group.rowOffsets.map((_, row) => { const s = group.extractRow(row); try { return logical(s); } finally { s.dispose(); } }) });
  const options = { kvBits: 4, kvGroupSize: 64, quantizedKvStart: 6 };
  const maintain = createKvMaintenance(options);
  using k = f16(2, 2, 1, 50), v = f16(2, 2, 1, 51);
  for (const lengths of [[3, 7], [7, 9]]) {
    const source = soloRows(lengths, 40); maintain(source);
    const group = new DelayedRotatingQuantizedKVCache(W, 64, 4, 6); group.mergeRows(source);
    try {
      const before = snapshot(group);
      expect(() => group.updateAndFetch(k, v)).toThrow("mixed precision rows use their attention state");
      expect(snapshot(group)).toEqual(before);
    } finally { group.dispose(); for (const c of source) c.dispose(); }
  }
  const source = soloRows([3, 5], 60), control = cloneKvCaches(source);
  const group = new DelayedRotatingQuantizedKVCache(W, 64, 4, 6); group.mergeRows(source);
  try {
    for (const a of group.updateAndFetch(k, v)) a.dispose();
    expect(group.rowOffsets).toEqual([4, 6]);
    expect(() => group.updateAndFetch(k, v)).toThrow("mixed precision rows use their attention state");
    expect(group.rowOffsets).toEqual([4, 6]);
    using k0 = rowOf(k, 0), v0 = rowOf(v, 0);
    write(control[0]!, k0, v0);
    const first = group.extractRow(0), second = group.extractRow(1);
    try { expect(logical(first)).toEqual(logical(control[0]!)); expect(second).toBeInstanceOf(RotatingQuantizedKVCache); }
    finally { first.dispose(); second.dispose(); }
  } finally { group.dispose(); for (const c of [...source, ...control]) c.dispose(); }
});
