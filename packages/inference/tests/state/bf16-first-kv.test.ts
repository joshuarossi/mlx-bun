// B1d bit-identity gate: the quantized legos `--kv-quant N` composes against
// the path they replace. "Old" is today's: a plain cache read as the graphs
// read it (`makeMask` before the append, `updateAndFetch`, the fused SDPA), with
// `createKvMaintenance` run on it after every append (the conversion the served
// path performs after each forward), then the graphs' affine call
// (`updateAndFetchQuantized`, `quantizedSdpa`) or TurboQuant call (deferred-V
// fetch, SDPA, inverse rotation) once it has converted. "New" is the lego's
// phase-named read. Same random q/k/v. Every read's output must match (maxDiff
// 0), and after every step the stored positions below the offset (bytes),
// `signature()`, the offset and the reuse floor. Padding past the offset is the
// lego's own and is not compared.
import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { AttentionCache, AttentionRead, Cache } from "../../src/contracts/mlx/cache";
import { unrotateValues } from "../../src/kernels/turboquant/ops";
import { quantizedSdpa } from "../../src/layers/quantized-attention";
import { unfusedAffineKernels } from "../../src/state/affine-attention";
import { Bf16FirstQuantizedKVCache, Bf16FirstRotatingQuantizedKVCache, Bf16FirstTurboQuantKVCache } from "../../src/state/bf16-first-kv";
import { DelayedQuantizedKVCache } from "../../src/state/delayed-quantized-kv";
import { DelayedRotatingQuantizedKVCache } from "../../src/state/delayed-rotating-quantized-kv";
import { DelayedTurboQuantKVCache } from "../../src/state/delayed-turboquant-kv";
import { KVCache } from "../../src/state/kv";
import { createKvMaintenance } from "../../src/state/kv-maintenance";
import { QuantizedKVCache } from "../../src/state/quantized-kv";
import { disposeTriple } from "../../src/state/quantized-tensor";
import { RotatingKVCache } from "../../src/state/rotating-kv";
import { RotatingQuantizedKVCache } from "../../src/state/rotating-quantized-kv";
import { turboQuantFusedDecode } from "../../src/state/turboquant-codec";
import { TurboQuantKVCache } from "../../src/state/turboquant-kv";
import { disposeResources } from "../../src/runtime/resources";

const HKV = 2, HQ = 8, D = 128, SCALE = 0.088, GROUP = 64;
/** The sliding window of the rotating cases: the 300- and 250-position windows
 * overflow it and the long decode run wraps the ring in place. */
const W = 128;

let seed = 1;
function tensor(shape: number[]): MlxArray {
  const n = shape.reduce((a, b) => a * b, 1);
  const data = new Float32Array(n);
  let s = (seed++ * 2654435761) >>> 0;
  for (let i = 0; i < n; i++) { s = (s * 1664525 + 1013904223) >>> 0; data[i] = (s / 2 ** 32) * 4 - 2; }
  using f = MlxArray.fromFloat32(data, shape);
  return f.astype(Dtype.bfloat16);
}
const kv = (B: number, L: number): [MlxArray, MlxArray] => [tensor([B, HKV, L, D]), tensor([B, HKV, L, D])];
const query = (B: number, L: number) => tensor([B, HQ, L, D]);

/** Elementwise, read row-major: both sides go through `ops.contiguous` because
 * the fused SDPA can return a transposed layout above eight queries. */
function maxDiff(a: MlxArray, b: MlxArray): number {
  expect(a.shape).toEqual(b.shape);
  using ra = ops.contiguous(a), rb = ops.contiguous(b);
  using fa = ra.astype(Dtype.float32), fb = rb.astype(Dtype.float32);
  const x = fa.toFloat32(), y = fb.toFloat32();
  let m = 0;
  for (let i = 0; i < x.length; i++) m = Math.max(m, Math.abs(x[i]! - y[i]!));
  return m;
}

type Step = "D" | number;
interface Scheme { readonly name: string; readonly bits?: number; readonly rotating: boolean }
const SCHEMES: readonly Scheme[] = [
  { name: "affine 4", bits: 4, rotating: false },
  { name: "affine 8", bits: 8, rotating: false },
  { name: "affine 4 rotating", bits: 4, rotating: true },
  { name: "affine 8 rotating", bits: 8, rotating: true },
  { name: "TurboQuant k8v3", rotating: false },
];
const maintenanceOf = (scheme: Scheme, start: number) => createKvMaintenance(scheme.bits
  ? { kvBits: scheme.bits, kvGroupSize: GROUP, quantizedKvStart: start }
  : { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: start });
const plainOf = (scheme: Scheme): Cache => scheme.rotating ? new RotatingKVCache(W) : new KVCache();
const legoOf = (scheme: Scheme, start: number): AttentionCache => !scheme.bits
  ? new Bf16FirstTurboQuantKVCache(8, 3, start, turboQuantFusedDecode())
  : scheme.rotating ? new Bf16FirstRotatingQuantizedKVCache(W, GROUP, scheme.bits, start)
  : new Bf16FirstQuantizedKVCache(GROUP, scheme.bits, start);
/** Evaluate a cache's state, releasing the views a cache hands out fresh. */
function materialize(cache: Cache): void {
  const state = cache.state();
  try { ops.evalAll(state); } finally { if (cache.stateNeedsDispose) for (const array of state) array.dispose(); }
}

/** The graphs' read today on whichever storage the old path holds. */
function oldRead(cache: Cache, window: number | null, k: MlxArray, v: MlxArray, q: MlxArray): MlxArray {
  const mask = cache.makeMask(k.shape[2]!, window);
  try {
    if (cache instanceof QuantizedKVCache || cache instanceof RotatingQuantizedKVCache) {
      const [keys, values] = cache.updateAndFetchQuantized(k, v);
      try { return quantizedSdpa(q, keys, values, SCALE, mask, cache.groupSize, cache.bits); }
      finally { disposeTriple(keys); disposeTriple(values); }
    }
    if (cache instanceof TurboQuantKVCache) {
      const [keys, values] = cache.updateAndFetchDeferredV(k, v);
      try { using rotated = ops.sdpa(q, keys, values, SCALE, mask.mode, mask.arr); return unrotateValues(rotated); }
      finally { keys.dispose(); values.dispose(); }
    }
    const [keys, values] = cache.updateAndFetch(k, v);
    try { return ops.sdpa(q, keys, values, SCALE, mask.mode, mask.arr); }
    finally { keys.dispose(); values.dispose(); }
  } finally { mask.arr?.dispose(); }
}

function attendOnce(read: AttentionRead, q: MlxArray): MlxArray {
  try { const out = read.attend(q, SCALE); out.eval(); return out; } finally { read.dispose(); }
}
const newRead = (cache: AttentionCache, step: Step, k: MlxArray, v: MlxArray, q: MlxArray) =>
  attendOnce(step === "D" ? cache.appendDecode(k, v) : cache.appendWindow(k, v), q);

/** Planes of `state()` that differ in any byte below each storage's own
 * stored length (the offset, or the ring's physical length once it wraps). */
function storedDifferences(old: Cache, lego: Cache): string[] {
  const a = old.state(), b = lego.state();
  try {
    expect(b.length).toBe(a.length);
    const differing: string[] = [];
    for (let plane = 0; plane < a.length; plane++) {
      const x = a[plane]!, y = b[plane]!;
      const n = Math.min(old.offset, x.shape[2]!);
      expect(Math.min(lego.offset, y.shape[2]!)).toBe(n);
      expect(y.dtype).toBe(x.dtype);
      using xs = x.slice([0, 0, 0, 0], [x.shape[0]!, x.shape[1]!, n, x.shape[3]!]);
      using ys = y.slice([0, 0, 0, 0], [y.shape[0]!, y.shape[1]!, n, y.shape[3]!]);
      using xc = ops.contiguous(xs), yc = ops.contiguous(ys);
      if (!Buffer.from(xc.rawBytesView()).equals(Buffer.from(yc.rawBytesView()))) differing.push(`plane ${plane}`);
    }
    return differing;
  } finally {
    if (old.stateNeedsDispose) for (const array of a) array.dispose();
    if (lego.stateNeedsDispose) for (const array of b) array.dispose();
  }
}

interface Outcome { label: string; diff: number | string }
const outcomes: Outcome[] = [];

const FULL: readonly Step[] = [7, "D", "D", "D", 300, "D", "D", 250, "D", "D", "D", 40, "D", "D"];
const RING: readonly Step[] = [7, "D", "D", "D", 300, "D", "D", 250, ...Array<Step>(140).fill("D"), 40, "D", "D"];

for (const scheme of SCHEMES) for (const start of [0, 512]) {
  test(`${scheme.name}, start ${start}: the lego reads and stores as plain storage converted after each append`, () => {
    const maintain = maintenanceOf(scheme, start);
    const old: Cache[] = [plainOf(scheme)];
    const lego = legoOf(scheme, start);
    const window = scheme.rotating ? W : null;
    const steps = scheme.rotating ? RING : FULL;
    let converted = -1;
    const bf16Reads: number[] = [], quantizedReads: number[] = [], stored: string[] = [];
    try {
      for (const [index, step] of steps.entries()) {
        const L = step === "D" ? 1 : step;
        const [k, v] = kv(1, L);
        using q = query(1, L);
        try {
          const plain = old[0]!.signature().includes("plain");
          using expected = oldRead(old[0]!, window, k, v, q);
          expected.eval();
          maintain(old);
          using actual = newRead(lego, step, k, v, q);
          const diff = maxDiff(actual, expected);
          (plain ? bf16Reads : quantizedReads).push(diff);
          if (diff !== 0) outcomes.push({ label: `${scheme.name} start ${start} step ${index} (${step === "D" ? "decode" : `window ${L}`})`, diff });
          if (converted < 0 && !old[0]!.signature().includes("plain")) converted = old[0]!.offset;
          expect(lego.signature(), `step ${index}`).toBe(old[0]!.signature());
          expect(lego.offset, `step ${index}`).toBe(old[0]!.offset);
          expect(lego.minimumReusableOffset ?? 0, `step ${index}`).toBe(old[0]!.minimumReusableOffset ?? 0);
          stored.push(...storedDifferences(old[0]!, lego).map(plane => `step ${index} ${plane}`));
        } finally { k.dispose(); v.dispose(); }
        if (index % 32 === 31) { materialize(old[0]!); materialize(lego); }
      }
      // The transition happened inside the sequence, after the append that
      // reached the start: the first append at start 0, the 250-position
      // window (312 to 562) at start 512.
      expect(converted).toBe(start === 0 ? 7 : 562);
      const max = (diffs: number[]) => diffs.length ? Math.max(...diffs) : 0;
      outcomes.push({ label: `${scheme.name} start ${start}: ${bf16Reads.length} reads before the conversion`, diff: max(bf16Reads) });
      outcomes.push({ label: `${scheme.name} start ${start}: ${quantizedReads.length} reads after the conversion at offset ${converted}`,
        diff: max(quantizedReads) });
      outcomes.push({ label: `${scheme.name} start ${start}: stored positions below the offset and signature after each of ${steps.length} steps`,
        diff: stored.length ? stored.join(", ") : 0 });
      expect(stored).toEqual([]);
      expect(max([...bf16Reads, ...quantizedReads])).toBe(0);
    } finally { disposeResources([...old, lego]); }
  });
}

/** The quantized-from-token-zero cache a lego is not: built empty, it
 * quantizes the first append too. Its kernels are not composed yet (B1):
 * unfused, the uniform `--kv-quant N` composition. */
const fromZeroOf = (scheme: Scheme): Cache => !scheme.bits ? new TurboQuantKVCache(8, 3, turboQuantFusedDecode())
  : scheme.rotating ? new RotatingQuantizedKVCache(W, GROUP, scheme.bits, unfusedAffineKernels(scheme.bits, GROUP, Dtype.bfloat16))
  : new QuantizedKVCache(GROUP, scheme.bits, unfusedAffineKernels(scheme.bits, GROUP, Dtype.bfloat16));
/** The conversion `kv-maintenance` performs, applied by hand. */
const convertedOf = (scheme: Scheme, plain: Cache): Cache => !scheme.bits
  ? TurboQuantKVCache.fromKVCache(plain as KVCache, 8, 3, turboQuantFusedDecode())
  : (plain as KVCache | RotatingKVCache).toQuantized(GROUP, scheme.bits);

for (const scheme of SCHEMES) {
  test(`${scheme.name}: the first read is the bf16 read, the reads after the conversion are the quantized read`, () => {
    const lego = legoOf(scheme, 0);
    const plain = plainOf(scheme) as KVCache | RotatingKVCache;
    const fromZero = fromZeroOf(scheme);
    const window = scheme.rotating ? W : null;
    let quantized: Cache | undefined;
    try {
      const [k, v] = kv(1, 7);
      using q = query(1, 7);
      try {
        using bf16 = attendOnce(plain.appendWindow(k, v), q);
        using zero = oldRead(fromZero, window, k, v, q);
        using first = newRead(lego, 7, k, v, q);
        const diff = maxDiff(first, bf16), zeroDiff = maxDiff(first, zero);
        outcomes.push({ label: `${scheme.name} first window 7 vs the bf16 read`, diff });
        outcomes.push({ label: `${scheme.name} first window 7 vs a cache quantized from token zero [expected to differ]`, diff: zeroDiff });
        expect(diff).toBe(0);
        expect(zeroDiff).toBeGreaterThan(0);
      } finally { k.dispose(); v.dispose(); }
      quantized = convertedOf(scheme, plain);
      expect(lego.signature()).toBe(quantized.signature());
      for (const step of ["D", "D", 12, "D"] as const) {
        const L = step === "D" ? 1 : step;
        const [k2, v2] = kv(1, L);
        using q2 = query(1, L);
        try {
          using expected = oldRead(quantized, window, k2, v2, q2);
          using actual = newRead(lego, step, k2, v2, q2);
          const diff = maxDiff(actual, expected);
          outcomes.push({ label: `${scheme.name} after conversion ${step === "D" ? "decode" : `window ${L}`} vs the quantized read`, diff });
          expect(diff).toBe(0);
        } finally { k2.dispose(); v2.dispose(); }
      }
    } finally { disposeResources([lego, plain, fromZero, ...(quantized ? [quantized] : [])]); }
  });
}

/** Solo rows as the scheduler joins them: written, then maintained. */
function joiningRows(scheme: Scheme, start: number, lengths: readonly number[]): Cache[] {
  const rows = lengths.map(length => {
    const row = plainOf(scheme);
    const [k, v] = kv(1, length);
    try { for (const a of row.updateAndFetch(k, v)) a.dispose(); } finally { k.dispose(); v.dispose(); }
    return row;
  });
  maintenanceOf(scheme, start)(rows);
  return rows;
}
const rowsOf = (scheme: Scheme, start: number): AttentionCache & Cache & { mergeRows(rows: readonly Cache[]): void } =>
  !scheme.bits ? new DelayedTurboQuantKVCache(8, 3, start, turboQuantFusedDecode())
    : scheme.rotating ? new DelayedRotatingQuantizedKVCache(16, GROUP, scheme.bits, start)
    : new DelayedQuantizedKVCache(GROUP, scheme.bits, start);

/** The graphs' call on a rows layout today: its mask before the append, then its
 * attention view (affine) or its deferred-V fetch and captured value transform
 * (TurboQuant). */
function oldRowsRead(cache: Cache, window: number | null, k: MlxArray, v: MlxArray, q: MlxArray): MlxArray {
  const mask = cache.makeMask(k.shape[2]!, window);
  try {
    if (cache.rotatedValueAttention) {
      const [keys, values] = cache.rotatedValueAttention.updateAndFetchDeferredV(k, v);
      const restore = cache.rotatedValueAttention.captureValueTransform!();
      try { using rotated = ops.sdpa(q, keys, values, SCALE, mask.mode, mask.arr); return restore(rotated); }
      finally { keys.dispose(); values.dispose(); }
    }
    const view = cache.attentionState!.appendAndFetch(k, v);
    try { return view.attend(q, SCALE, mask); } finally { view.dispose(); }
  } finally { mask.arr?.dispose(); }
}

for (const scheme of SCHEMES) {
  test(`${scheme.name} rows: the phase reads equal the graph's call through and after the transition`, () => {
    const start = 8;
    const sources = joiningRows(scheme, start, [3, 9]);
    const pair = [rowsOf(scheme, start), rowsOf(scheme, start)] as const;
    const window = scheme.rotating ? 16 : null;
    const diffs: number[] = [];
    try {
      for (const cache of pair) cache.mergeRows(sources);
      for (const step of ["D", "D", 4, "D", "D", 20, "D", 3, "D"] as const) {
        const L = step === "D" ? 1 : step;
        const [k, v] = kv(2, L);
        using q = query(2, L);
        try {
          const at = pair[1].offset;
          using expected = oldRowsRead(pair[0], window, k, v, q);
          using actual = newRead(pair[1], step, k, v, q);
          const diff = maxDiff(actual, expected);
          diffs.push(diff);
          outcomes.push({ label: `${scheme.name} rows [3,9] ${step === "D" ? "decode" : `window ${L}`} @${at}`, diff });
        } finally { k.dispose(); v.dispose(); }
      }
      expect(Math.max(...diffs)).toBe(0);
    } finally { disposeResources([...pair, ...sources]); }
  });
}

test("bit-identity report", () => {
  for (const { label, diff } of outcomes) console.log(`${diff === 0 ? "identical" : "DIFFERS  "} maxDiff=${diff} ${label}`);
  expect(outcomes.length).toBeGreaterThan(0);
});
