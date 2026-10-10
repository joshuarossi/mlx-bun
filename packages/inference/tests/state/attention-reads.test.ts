// B1a bit-identity gate: every bf16 cache's named reads against what the
// graphs compute today for the same cache and phase. "Old" is the graph's call
// copied verbatim: `makeMask` before the append, `updateAndFetch`, then
// `ops.sdpa` with that mask (the paged attention-state branch, Gemma 4's
// `bidirMask`, DiffusionGemma's canvas read where those apply). "New" is the
// phase-named append and `attend`. Same random q/k/v; maxDiff must be 0.
import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { AttentionCache, AttentionRead, Cache } from "../../src/contracts/mlx/cache";
import { bidirMask } from "../../src/kernels/attention/masks";
import { AttentionMasks } from "../../src/state/attention-read";
import { BatchedKVCache } from "../../src/state/batched-kv";
import { PaddedKVRows } from "../../src/state/batched-mask";
import { BatchedRotatingCache } from "../../src/state/batched-rotating";
import { KVCache } from "../../src/state/kv";
import { PagedKVCache, type PagedQuantization } from "../../src/state/paged/cache";
import { PagedKvRows } from "../../src/state/paged/rows";
import { RotatingKVCache } from "../../src/state/rotating-kv";
import { SpeculativeRotatingKVCache } from "../../src/state/speculative-rotating-kv";
import { disposeResources } from "../../src/runtime/resources";

const HKV = 2, HQ = 8, D = 128, SCALE = 0.088, WINDOW = 32;

let seed = 1;
function tensor(shape: number[]): MlxArray {
  const n = shape.reduce((a, b) => a * b, 1);
  const data = new Float32Array(n);
  let s = (seed++ * 2654435761) >>> 0;
  for (let i = 0; i < n; i++) { s = (s * 1664525 + 1013904223) >>> 0; data[i] = (s / 2 ** 32) * 4 - 2; }
  using f = MlxArray.fromFloat32(data, shape);
  return f.astype(Dtype.bfloat16);
}
const kv = (B: number, L: number, d = D): [MlxArray, MlxArray] => [tensor([B, HKV, L, d]), tensor([B, HKV, L, d])];
const query = (B: number, L: number, d = D) => tensor([B, HQ, L, d]);

/** Elementwise; outputs are read row-major (the fused SDPA can return a
 * transposed layout, which a linear host read would scramble). */
function maxDiff(a: MlxArray, b: MlxArray): number {
  expect(a.shape).toEqual(b.shape);
  using ra = ops.contiguous(a), rb = ops.contiguous(b);
  using fa = ra.astype(Dtype.float32), fb = rb.astype(Dtype.float32);
  const x = fa.toFloat32(), y = fb.toFloat32();
  let m = 0;
  for (let i = 0; i < x.length; i++) m = Math.max(m, Math.abs(x[i]! - y[i]!));
  return m;
}

/** The graphs' read today: mask before the append, updateAndFetch, fused SDPA. */
function oldRead(cache: Cache, window: number | null, k: MlxArray, v: MlxArray, q: MlxArray): MlxArray {
  const mask = cache.makeMask(k.shape[2]!, window);
  const [keys, values] = cache.updateAndFetch(k, v);
  try { return ops.sdpa(q, keys, values, SCALE, mask.mode, mask.arr); }
  finally { keys.dispose(); values.dispose(); mask.arr?.dispose(); }
}

/** Qwen3Attention's paged branch today: the attention-state view when the
 * cache has one, else updateAndFetch and the fused SDPA. */
function oldPagedRead(cache: Cache, k: MlxArray, v: MlxArray, q: MlxArray): MlxArray {
  const mask = cache.makeMask(k.shape[2]!, null);
  try {
    if (cache.attentionState) {
      const view = cache.attentionState.appendAndFetch(k, v);
      try { return view.attend(q, SCALE, mask, false); } finally { view.dispose(); }
    }
    const [keys, values] = cache.updateAndFetch(k, v);
    try { return ops.sdpa(q, keys, values, SCALE, mask.mode, mask.arr); }
    finally { keys.dispose(); values.dispose(); }
  } finally { mask.arr?.dispose(); }
}

function attendOnce(read: AttentionRead, q: MlxArray): MlxArray {
  try { const out = read.attend(q, SCALE); out.eval(); return out; } finally { read.dispose(); }
}

type Step = "D" | number; // decode, or a window of that many rows
type Phase = (cache: AttentionCache, k: MlxArray, v: MlxArray) => AttentionRead;
const decode: Phase = (cache, k, v) => cache.appendDecode(k, v);
const windowRead: Phase = (cache, k, v) => cache.appendWindow(k, v);

interface Outcome { label: string; diff: number }
const outcomes: Outcome[] = [];

/** Run `steps` on two identically prepared caches: old read on one, new on the
 * other. Returns each step's maxDiff. */
function compareSteps<C extends AttentionCache>(label: string, pair: [C, C], B: number,
  steps: readonly Step[], old: (cache: C, k: MlxArray, v: MlxArray, q: MlxArray) => MlxArray, d = D): number[] {
  const diffs: number[] = [];
  for (const step of steps) {
    const L = step === "D" ? 1 : step;
    const [k, v] = kv(B, L, d);
    using q = query(B, L, d);
    try {
      using expected = old(pair[0], k, v, q);
      using actual = attendOnce((step === "D" ? decode : windowRead)(pair[1], k, v), q);
      const diff = maxDiff(actual, expected);
      diffs.push(diff);
      outcomes.push({ label: `${label} ${step === "D" ? "decode" : `window ${L}`} @${pair[1].offset - L}`, diff });
    } finally { k.dispose(); v.dispose(); }
  }
  return diffs;
}

function twice<C>(make: () => C): [C, C] { return [make(), make()]; }

/** Advance both caches identically through the deprecated append, which
 * stores exactly as the new reads do for decode and windows of two or more. */
function advance(pair: [Cache, Cache], B: number, steps: readonly Step[], d = D): void {
  for (const [index, step] of steps.entries()) {
    const [k, v] = kv(B, step === "D" ? 1 : step, d);
    try { for (const cache of pair) for (const a of cache.updateAndFetch(k, v)) a.dispose(); }
    finally { k.dispose(); v.dispose(); }
    if (index % 64 === 63) ops.evalAll(pair.flatMap(cache => cache.state()));
  }
}

/** Solo caches with the given histories, identical between the two runs. */
function soloRows<C extends Cache>(make: () => C, lengths: readonly number[], d = D): [C[], C[]] {
  const a: C[] = [], b: C[] = [];
  for (const length of lengths) {
    const [x, y] = twice(make);
    const [k, v] = kv(1, length, d);
    try { for (const c of [x, y]) for (const arr of c.updateAndFetch(k, v)) arr.dispose(); }
    finally { k.dispose(); v.dispose(); }
    a.push(x); b.push(y);
  }
  return [a, b];
}

function expectAllZero(diffs: number[]): void { expect(Math.max(0, ...diffs)).toBe(0); }

test("KVCache: decode and windows of 1, 3, 8, 37 and across the 256 step", () => {
  const pair = twice(() => new KVCache());
  try {
    expectAllZero(compareSteps("KVCache", pair, 1,
      [37, "D", "D", 1, 3, 8, 37, 200, "D", 8, 1], (c, k, v, q) => oldRead(c, null, k, v, q)));
  } finally { disposeResources(pair); }
});

test("RotatingKVCache: decode and windows before, across and after the sliding boundary", () => {
  const pair = twice(() => new RotatingKVCache(WINDOW));
  const ring = Array<Step>(40).fill("D");
  try {
    expectAllZero(compareSteps("RotatingKVCache", pair, 1,
      [3, 8, "D", "D", "D", "D", "D", 1, 37, ...ring, 3, 8, 37, "D", "D", "D"],
      (c, k, v, q) => oldRead(c, WINDOW, k, v, q)));
  } finally { disposeResources(pair); }
});

// The deprecated updateAndFetch writes a one-position append in place, so a
// one-row window attended the ring in ring order there. The window read
// concatenates (temporal order). The same keys in another order: identical at
// some sizes, bf16 rounding apart at others.
for (const [window, d] of [[WINDOW, D], [1024, 256]]) {
  test(`RotatingKVCache: a one-row window after a ${window}-ring wraps (documented divergence, head dim ${d})`, () => {
    for (let trial = 0; trial < 3; trial++) {
      const pair = twice(() => new RotatingKVCache(window!));
      try {
        advance(pair, 1, [37, ...Array<Step>(window! + 20 + trial).fill("D")], d);
        const [diff] = compareSteps(`RotatingKVCache(${window}) d${d} [divergent: old wrote in place]`, pair, 1, [1],
          (c, k, v, q) => oldRead(c, window!, k, v, q), d);
        expect(diff!).toBeLessThan(0.05);
      } finally { disposeResources(pair); }
    }
  });
}

for (const lengths of [[9, 9], [5, 17], [5, 17, 3, 40]]) {
  test(`BatchedKVCache: ${lengths.length} rows at offsets ${lengths.join(",")}`, () => {
    const [a, b] = soloRows(() => new KVCache(), lengths);
    const pair = twice(() => new BatchedKVCache());
    try {
      pair[0].mergeRows(a); pair[1].mergeRows(b);
      expectAllZero(compareSteps(`BatchedKVCache[${lengths}]`, pair, lengths.length,
        ["D", "D", 1, 3, 8, 37, "D"], (c, k, v, q) => oldRead(c, null, k, v, q)));
    } finally { disposeResources([...pair, ...a, ...b]); }
  });

  test(`PaddedKVRows: ${lengths.length} rows at offsets ${lengths.join(",")}`, () => {
    const [a, b] = soloRows(() => new KVCache(), lengths);
    const pair = twice(() => new PaddedKVRows());
    try {
      pair[0].mergeRows(a); pair[1].mergeRows(b);
      expectAllZero(compareSteps(`PaddedKVRows[${lengths}]`, pair, lengths.length,
        ["D", "D", 1, 3, 8, 37, "D"], (c, k, v, q) => oldRead(c, null, k, v, q)));
    } finally { disposeResources([...pair, ...a, ...b]); }
  });
}

for (const padding of [{ leftPadding: [2, 0], lengths: [6, 8] }, { lengths: [5, 8], rightPadding: [3, 0] },
  { leftPadding: [0, 3, 1, 5], lengths: [8, 5, 7, 3], rightPadding: [0, 0, 0, 0] }]) {
  test(`BatchedKVCache: padded prefill ${JSON.stringify(padding)}`, () => {
    const B = padding.lengths.length;
    const pair = twice(() => new BatchedKVCache());
    try {
      for (const cache of pair) cache.preparePrefill(padding);
      const diffs = compareSteps(`BatchedKVCache prefill`, pair, B, [8], (c, k, v, q) => oldRead(c, null, k, v, q));
      for (const cache of pair) cache.finalizePrefill();
      diffs.push(...compareSteps(`BatchedKVCache after prefill`, pair, B, ["D", "D", 3], (c, k, v, q) => oldRead(c, null, k, v, q)));
      expectAllZero(diffs);
    } finally { disposeResources(pair); }
  });

  test(`BatchedRotatingCache: padded prefill ${JSON.stringify(padding)}`, () => {
    const B = padding.lengths.length;
    const pair = twice(() => new BatchedRotatingCache(WINDOW, Array(B).fill(0)));
    try {
      for (const cache of pair) cache.preparePrefill(padding);
      const diffs = compareSteps(`BatchedRotatingCache prefill`, pair, B, [8, 1], (c, k, v, q) => oldRead(c, WINDOW, k, v, q));
      for (const cache of pair) cache.finalizePrefill();
      diffs.push(...compareSteps(`BatchedRotatingCache after prefill`, pair, B, ["D", "D", 3, 37, "D"],
        (c, k, v, q) => oldRead(c, WINDOW, k, v, q)));
      expectAllZero(diffs);
    } finally { disposeResources(pair); }
  });
}

for (const lengths of [[5, 20], [5, 40], [3, 40, 17, 70]]) {
  test(`BatchedRotatingCache: ${lengths.length} rows at offsets ${lengths.join(",")}, across the window`, () => {
    const [a, b] = soloRows(() => new RotatingKVCache(WINDOW), lengths);
    const pair = twice(() => new BatchedRotatingCache(WINDOW, []));
    try {
      pair[0].mergeRows(a); pair[1].mergeRows(b);
      // A one-row window only while the merged ring has room: once it is full,
      // the deprecated append writes one position in place (see below).
      const roomy = Math.max(...lengths) + 1 < WINDOW;
      expectAllZero(compareSteps(`BatchedRotatingCache[${lengths}]`, pair, lengths.length,
        [...(roomy ? [1] : []), "D", "D", 3, 8, 37, ...Array<Step>(40).fill("D"), 3, "D", 8, "D"],
        (c, k, v, q) => oldRead(c, WINDOW, k, v, q)));
    } finally { disposeResources([...pair, ...a, ...b]); }
  });
}

for (const [window, d] of [[WINDOW, D], [128, 256]]) {
  test(`BatchedRotatingCache: a one-row window after a ${window}-ring wraps (documented divergence, head dim ${d})`, () => {
    for (let trial = 0; trial < 3; trial++) {
      const [a, b] = soloRows(() => new RotatingKVCache(window!), [37, window! + 50], d);
      const pair = twice(() => new BatchedRotatingCache(window!, []));
      try {
        pair[0].mergeRows(a); pair[1].mergeRows(b);
        advance(pair, 2, Array<Step>(window! + 20 + trial).fill("D"), d);
        const [diff] = compareSteps(`BatchedRotatingCache(${window}) d${d} [divergent: old wrote in place]`, pair, 2, [1],
          (c, k, v, q) => oldRead(c, window!, k, v, q), d);
        expect(diff!).toBeLessThan(0.05);
      } finally { disposeResources([...pair, ...a, ...b]); }
    }
  });
}

test("SpeculativeRotatingKVCache: verify windows and decode across the window", () => {
  const [a, b] = soloRows(() => new RotatingKVCache(WINDOW), [5, 40]);
  const pair = twice(() => new SpeculativeRotatingKVCache(WINDOW));
  try {
    pair[0].mergeRows(a); pair[1].mergeRows(b);
    expectAllZero(compareSteps("SpeculativeRotatingKVCache[5,40]", pair, 2,
      ["D", 3, 8, ...Array<Step>(30).fill("D"), 37, "D"], (c, k, v, q) => oldRead(c, WINDOW, k, v, q)));
  } finally { disposeResources([...pair, ...a, ...b]); }
});

const pagedConfigs: Array<{ name: string; direct: boolean; quantization?: PagedQuantization }> = [
  { name: "bf16", direct: false }, { name: "bf16 direct", direct: true },
  { name: "kv4", direct: false, quantization: { bits: 4, groupSize: 64 } },
  { name: "kv8 direct", direct: true, quantization: { bits: 8, groupSize: 64 } },
];

for (const config of pagedConfigs) {
  test(`PagedKVCache ${config.name}: decode and windows`, () => {
    const steps: Step[] = [37, "D", "D", 37, 200, "D"];
    const shortWindows: Step[] = [1, 3, 8];
    const pair = twice(() => new PagedKVCache(1024, 16, config.direct, config.quantization));
    try {
      expectAllZero(compareSteps(`PagedKVCache ${config.name}`, pair, 1, steps, oldPagedRead));
      const short = compareSteps(`PagedKVCache ${config.name}${config.direct ? " [divergent: old used the direct kernel]" : ""}`,
        pair, 1, shortWindows, oldPagedRead);
      if (config.direct) expect(Math.max(...short)).toBeLessThan(0.05);
      else expectAllZero(short);
    } finally { disposeResources(pair); }
  });
}

for (const config of pagedConfigs) for (const lengths of [[29], [29, 41], [29, 41, 63, 87]]) {
  test(`PagedKvRows ${config.name}: ${lengths.length} rows at offsets ${lengths.join(",")}`, () => {
    const [a, b] = soloRows(() => new PagedKVCache(1024, 16, config.direct, config.quantization), lengths);
    const pair = twice(() => new PagedKvRows(1024, 16, config.direct, config.quantization));
    try {
      pair[0].mergeRows(a); pair[1].mergeRows(b);
      const B = lengths.length;
      // Without an attention state, several rows today join left-padded for one
      // SDPA; the new read keeps each row alone, as the attention-state path does.
      const merged = !config.direct && !config.quantization && B > 1;
      const label = `PagedKvRows ${config.name}[${lengths}]${merged ? " [divergent: old merged rows]" : ""}`;
      const long = compareSteps(label, pair, B, ["D", 37, "D"], oldPagedRead);
      const short = compareSteps(`${label}${config.direct ? " [divergent: old used the direct kernel]" : ""}`,
        pair, B, [3], oldPagedRead);
      if (merged) expect(Math.max(...long, ...short)).toBeLessThan(0.05);
      else {
        expectAllZero(long);
        if (config.direct) expect(short[0]!).toBeLessThan(0.05); else expectAllZero(short);
      }
    } finally { disposeResources([...pair, ...a, ...b]); }
  });
}

test("committed spans: KVCache and BatchedKVCache read as the graph's bf16 window", () => {
  const diffs: number[] = [];
  for (const L of [1, 2, 3, 4]) {
    const [a, b] = soloRows(() => new KVCache(), [23, 23]);
    const solo: [KVCache, KVCache] = [a[1]!, b[1]!];
    const batched = twice(() => new BatchedKVCache());
    try {
      batched[0].mergeRows([a[0]!]); batched[1].mergeRows([b[0]!]);
      for (const pair of [solo, batched] as Array<[KVCache | BatchedKVCache, KVCache | BatchedKVCache]>) {
        const [k, v] = kv(1, L);
        using q = query(1, L);
        try {
          using expected = oldRead(pair[0], null, k, v, q);
          using actual = attendOnce(pair[1].appendCommitted(k, v), q);
          const diff = maxDiff(actual, expected);
          diffs.push(diff);
          outcomes.push({ label: `${pair[1].constructor.name} committed ${L} @23`, diff });
        } finally { k.dispose(); v.dispose(); }
      }
    } finally { disposeResources([...batched, ...a, ...b]); }
  }
  expectAllZero(diffs);
});

test("bidirectional first window: KVCache and RotatingKVCache match Gemma 4's bidirMask read", () => {
  const diffs: number[] = [];
  for (const L of [3, 8, 37]) {
    for (const [name, make, window] of [["KVCache", () => new KVCache(), null],
      ["RotatingKVCache", () => new RotatingKVCache(WINDOW), WINDOW]] as const) {
      const pair = twice(make as () => KVCache | RotatingKVCache);
      const flags = Array.from({ length: L }, (_, i) => i >= 1 && i <= Math.floor(L / 2) ? 1 : 0);
      using flagsI = ops.fromInt32(flags, [L]);
      using bidir = flagsI.astype(Dtype.bool);
      const [k, v] = kv(1, L);
      using q = query(1, L);
      try {
        const mask = bidirMask(L, window, bidir);
        const [keys, values] = pair[0].updateAndFetch(k, v);
        using expected = ops.sdpa(q, keys, values, SCALE, mask.mode, mask.arr);
        expected.eval(); keys.dispose(); values.dispose(); mask.arr?.dispose();
        using actual = attendOnce(pair[1].appendBidirectional(k, v, bidir), q);
        const diff = maxDiff(actual, expected);
        diffs.push(diff);
        outcomes.push({ label: `${name} bidirectional ${L} @0`, diff });
      } finally { k.dispose(); v.dispose(); disposeResources(pair); }
    }
  }
  expectAllZero(diffs);
});

/** DiffusionGemma's decoder canvas read today (model.ts #makeDecoderMasks and
 * the decoder branch of its attention), for one layer. */
function oldCanvasRead(cache: KVCache | RotatingKVCache, sliding: boolean, slidingWindow: number,
  k: MlxArray, v: MlxArray, q: MlxArray): MlxArray {
  const canvasLength = k.shape[2]!;
  // #makeDecoderMasks
  let mask: { mode: "" | "causal" | "array"; arr: MlxArray | null } = { mode: "", arr: null };
  {
    const offset = cache.offset;
    const [encK, encV] = cache.temporalView();
    const encoderLen = encK.shape[2]!;
    encK.dispose(); encV.dispose();
    const validEncoderLen = Math.min(offset, encoderLen);
    const keyLen = encoderLen + canvasLength;
    const windowPrefix = Math.max(slidingWindow - 1, 0);
    if (sliding && encoderLen > windowPrefix) {
      const start = Math.max(0, validEncoderLen - windowPrefix);
      const positions = ops.arange(0, encoderLen, 1, Dtype.int32);
      const startArr = ops.scalarLike(start, positions);
      const validArr = ops.scalarLike(validEncoderLen, positions);
      const geStart = ops.greaterEqual(positions, startArr);
      const ltValid = ops.less(positions, validArr);
      const encMask = ops.logicalAnd(geStart, ltValid);
      positions.dispose(); startArr.dispose(); validArr.dispose(); geStart.dispose(); ltValid.dispose();
      using ones = ops.fromInt32(new Array(canvasLength).fill(1), [canvasLength]);
      const canvasMask = ones.astype(encMask.dtype);
      const row = ops.concatAxis([encMask, canvasMask], 0);
      encMask.dispose(); canvasMask.dispose();
      const reshaped = ops.reshape(row, [1, 1, 1, keyLen]);
      row.dispose();
      mask = { mode: "array", arr: reshaped };
    }
  }
  // attention, decoder branch
  const offset = cache.offset;
  let maskMode = mask.mode;
  let maskArr = mask.arr;
  let maskArrOwned = false;
  let [encK, encV] = cache.temporalView();
  if (sliding) {
    const window = Math.max(slidingWindow - 1, 0);
    const encoderLen = encK.shape[2]!;
    if (window && encoderLen > window && offset >= encoderLen) {
      const trimK = encK.slice([0, 0, encoderLen - window, 0], encK.shape);
      const trimV = encV.slice([0, 0, encoderLen - window, 0], encV.shape);
      encK.dispose(); encV.dispose();
      encK = trimK; encV = trimV;
      if (maskArr) {
        const ks = maskArr.shape;
        const keep = window + canvasLength;
        maskArr = maskArr.slice([0, 0, 0, ks[3]! - keep], ks);
        maskArrOwned = true;
        maskMode = "array";
      }
    }
  }
  const kCat = ops.concatAxis([encK, k], 2);
  const vCat = ops.concatAxis([encV, v], 2);
  encK.dispose(); encV.dispose();
  const attn = ops.sdpa(q, kCat, vCat, SCALE, maskMode, maskArr);
  attn.eval();
  kCat.dispose(); vCat.dispose();
  if (maskArrOwned) maskArr!.dispose();
  mask.arr?.dispose();
  return attn;
}

test("readBlock: DiffusionGemma's canvas read over full and sliding context", () => {
  const diffs: number[] = [];
  for (const prompt of [7, 31, 32, 50]) for (const L of [1, 3, 8, 37]) {
    for (const sliding of [false, true]) {
      const make = () => sliding ? new RotatingKVCache(WINDOW) : new KVCache();
      const pair = twice(make);
      const [pk, pv] = kv(1, prompt);
      try {
        for (const cache of pair) for (const a of cache.updateAndFetch(pk, pv)) a.dispose();
        const [k, v] = kv(1, L);
        using q = query(1, L);
        try {
          using expected = oldCanvasRead(pair[0], sliding, WINDOW, k, v, q);
          using actual = attendOnce(pair[1].readBlock(k, v), q);
          const diff = maxDiff(actual, expected);
          diffs.push(diff);
          outcomes.push({ label: `${sliding ? "RotatingKVCache" : "KVCache"} readBlock ${L} over ${prompt}`, diff });
          expect(pair[1].offset).toBe(prompt);
        } finally { k.dispose(); v.dispose(); }
      } finally { pk.dispose(); pv.dispose(); disposeResources(pair); }
    }
  }
  expectAllZero(diffs);
});

test("mask memo: one build per forward over a 4-layer cache set, rebuilt when the offsets advance", () => {
  const masks = new AttentionMasks();
  const [a] = soloRows(() => new KVCache(), [5, 17]);
  const layers = Array.from({ length: 4 }, () => new BatchedKVCache(masks));
  const reference = Array.from({ length: 4 }, () => new BatchedKVCache());
  const held: AttentionRead[] = [];
  try {
    for (const cache of [...layers, ...reference]) cache.mergeRows(a);
    const forward = (L: number) => {
      const diffs: number[] = [];
      for (let layer = 0; layer < 4; layer++) {
        const [k, v] = kv(2, L);
        using q = query(2, L);
        try {
          using expected = oldRead(reference[layer]!, null, k, v, q);
          const read = L === 1 ? layers[layer]!.appendDecode(k, v) : layers[layer]!.appendWindow(k, v);
          held.push(read);
          using actual = read.attend(q, SCALE);
          diffs.push(maxDiff(actual, expected));
        } finally { k.dispose(); v.dispose(); }
      }
      return diffs;
    };
    expectAllZero(forward(3));
    expect(masks.builds).toBe(1);
    expectAllZero(forward(1));
    expect(masks.builds).toBe(2);
    expectAllZero(forward(1));
    expect(masks.builds).toBe(3);
    // A read from an earlier forward still attends after its mask was replaced.
    using q = query(2, 3);
    using before = held[0]!.attend(q, SCALE);
    before.eval();
    masks.clear();
    using after = held[0]!.attend(q, SCALE);
    expect(maxDiff(after, before)).toBe(0);
  } finally { disposeResources([...held, ...layers, ...reference, ...a]); }
});

test("mask memo: interleaved sliding and full layers keep one mask each", () => {
  const masks = new AttentionMasks();
  const [full] = soloRows(() => new KVCache(), [5, 17]);
  const [ring] = soloRows(() => new RotatingKVCache(WINDOW), [5, 40]);
  const layers: Array<BatchedRotatingCache | BatchedKVCache> = [new BatchedRotatingCache(WINDOW, [], masks),
    new BatchedKVCache(masks), new BatchedRotatingCache(WINDOW, [], masks), new BatchedKVCache(masks)];
  try {
    for (const [i, layer] of layers.entries()) layer.mergeRows(i % 2 ? full : ring);
    for (const forward of [3, 1, 1]) {
      const before = masks.builds;
      for (const layer of layers) {
        const [k, v] = kv(2, forward);
        try {
          const read = forward === 1 ? layer.appendDecode(k, v) : layer.appendWindow(k, v);
          read.dispose();
        } finally { k.dispose(); v.dispose(); }
      }
      expect(masks.builds - before).toBe(2);
    }
  } finally { disposeResources([...layers, ...full, ...ring]); }
});

test("bit-identity report", () => {
  for (const { label, diff } of outcomes) console.log(`${diff === 0 ? "identical" : "DIFFERS  "} maxDiff=${diff} ${label}`);
  expect(outcomes.length).toBeGreaterThan(0);
});
