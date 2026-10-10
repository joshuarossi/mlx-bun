// B1c bit-identity gate: the TurboQuant caches' named reads against what the
// graphs compute today for the same cache and phase. "Old" is the graph's
// deferred-V call copied verbatim (MiniCPM5's LlamaAttention; Gemma 4's
// attention runs the same ops): `makeMask` before the append,
// `rotatedValueAttention.updateAndFetchDeferredV`, `ops.sdpa` with that mask,
// then `captureValueTransform?.()` or `unrotateValues` on the output. "New" is
// the phase-named append and `attend`, which un-rotates inside the read. Same
// random q/k/v; maxDiff must be 0.
import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { AttentionCache, AttentionRead, Cache } from "../../src/contracts/mlx/cache";
import { unrotateValues } from "../../src/kernels/turboquant/ops";
import { AttentionMasks } from "../../src/state/attention-read";
import { BatchedTurboQuantKVCache } from "../../src/state/batched-turboquant-kv";
import { ownedCacheLayoutFactory } from "../../src/state/layout";
import { TurboQuantKVCache } from "../../src/state/turboquant-kv";
import { disposeResources } from "../../src/runtime/resources";

const HKV = 2, HQ = 8, D = 128, SCALE = 0.088;
/** Every k/v width the codec accepts (`TURBOQUANT_VALID_KBITS`/`VBITS`). */
const K_BITS = [2, 4, 5, 8], V_BITS = [2, 3, 4, 5, 8];
const COMBOS = K_BITS.flatMap(kb => V_BITS.map(vb => [kb, vb] as const));
const NAMED = [[8, 3], [4, 4]] as const;
const FUSED = [true, false];

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

/** Elementwise; outputs are read row-major (the fused SDPA returns a
 * transposed layout above 8 queries, which a linear host read would scramble). */
function maxDiff(a: MlxArray, b: MlxArray): number {
  expect(a.shape).toEqual(b.shape);
  expect(a.dtype).toBe(b.dtype);
  using ra = ops.contiguous(a), rb = ops.contiguous(b);
  using fa = ra.astype(Dtype.float32), fb = rb.astype(Dtype.float32);
  const x = fa.toFloat32(), y = fb.toFloat32();
  let m = 0;
  for (let i = 0; i < x.length; i++) m = Math.max(m, Math.abs(x[i]! - y[i]!));
  return m;
}

/** The graphs' deferred-V read today (models/minicpm5/model.ts LlamaAttention,
 * the `rotatedValueAttention` branch; the mask is the forward's, built from the
 * cache before any layer appends). */
function oldRead(cache: Cache, k: MlxArray, v: MlxArray, q: MlxArray): MlxArray {
  const mask = cache.makeMask(k.shape[2]!, null);
  try {
    const [keys, values] = cache.rotatedValueAttention!.updateAndFetchDeferredV(k, v);
    const rotated = ops.sdpa(q, keys, values, SCALE, mask.mode, mask.arr);
    keys.dispose();
    values.dispose();
    const attn = cache.rotatedValueAttention!.captureValueTransform?.()(rotated) ?? unrotateValues(rotated);
    rotated.dispose();
    return attn;
  } finally { mask.arr?.dispose(); }
}

function attendOnce(read: AttentionRead, q: MlxArray): MlxArray {
  try { const out = read.attend(q, SCALE); out.eval(); return out; } finally { read.dispose(); }
}

type Step = "D" | number; // decode, or a window of that many rows

interface Outcome { label: string; diff: number }
const outcomes: Outcome[] = [];

/** Run `steps` on two identically prepared caches: old read on one, new on the
 * other. Returns each step's maxDiff. */
function compareSteps<C extends AttentionCache>(label: string, pair: [C, C], B: number,
  steps: readonly Step[], d = D): number[] {
  const diffs: number[] = [];
  for (const step of steps) {
    const L = step === "D" ? 1 : step;
    const [k, v] = kv(B, L, d);
    using q = query(B, L, d);
    try {
      const at = pair[1].offset;
      using expected = oldRead(pair[0], k, v, q);
      using actual = attendOnce(step === "D" ? pair[1].appendDecode(k, v) : pair[1].appendWindow(k, v), q);
      expect(pair[1].offset).toBe(pair[0].offset);
      const diff = maxDiff(actual, expected);
      diffs.push(diff);
      outcomes.push({ label: `${label} ${step === "D" ? "decode" : `window ${L}`} @${at}`, diff });
    } finally { k.dispose(); v.dispose(); }
  }
  return diffs;
}

function twice<C>(make: () => C): [C, C] { return [make(), make()]; }

/** Solo caches with the given histories, identical between the two runs. */
function soloRows(make: () => TurboQuantKVCache, lengths: readonly number[], d = D): [TurboQuantKVCache[], TurboQuantKVCache[]] {
  const a: TurboQuantKVCache[] = [], b: TurboQuantKVCache[] = [];
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

const fusedName = (fused: boolean) => fused ? "fused" : "eager";

// Decode and windows of 1, 3, 8, 37 and 200; the 200-row window grows the
// 256-step storage from a partial step (trim, then concatenate), and the second
// history decodes across an exactly full step.
const SOLO_STEPS: readonly Step[] = [37, "D", "D", 1, 3, 8, 37, 200, "D", 8, 1];
const FULL_STEP: readonly Step[] = [255, "D", "D", 3, "D"];

for (const [kb, vb] of COMBOS) {
  test(`TurboQuantKVCache k${kb}v${vb}: decode and windows of 1, 3, 8, 37, 200 across the 256 step`, () => {
    const diffs: number[] = [];
    for (const fused of FUSED) for (const steps of [SOLO_STEPS, FULL_STEP]) {
      const pair = twice(() => new TurboQuantKVCache(kb, vb, fused));
      try { diffs.push(...compareSteps(`TurboQuantKVCache k${kb}v${vb} ${fusedName(fused)} d${D}`, pair, 1, steps)); }
      finally { disposeResources(pair); }
    }
    expectAllZero(diffs);
  });
}

for (const [kb, vb] of NAMED) for (const d of [64, 256, 512]) {
  test(`TurboQuantKVCache k${kb}v${vb}: head dim ${d}`, () => {
    const diffs: number[] = [];
    for (const fused of FUSED) {
      const pair = twice(() => new TurboQuantKVCache(kb, vb, fused));
      try { diffs.push(...compareSteps(`TurboQuantKVCache k${kb}v${vb} ${fusedName(fused)} d${d}`, pair, 1, SOLO_STEPS, d)); }
      finally { disposeResources(pair); }
    }
    expectAllZero(diffs);
  });
}

const ROW_LENGTHS = [[9, 9], [5, 17], [5, 17, 3, 40]];
const BATCH_STEPS: readonly Step[] = ["D", "D", 1, 3, 8, 37, 200, "D", 8];

for (const [kb, vb] of COMBOS) {
  test(`BatchedTurboQuantKVCache k${kb}v${vb}: rows at unequal offsets, across the 256 step`, () => {
    const diffs: number[] = [];
    for (const fused of FUSED) for (const lengths of ROW_LENGTHS) {
      const make = () => new TurboQuantKVCache(kb, vb, fused);
      const [a, b] = soloRows(make, lengths);
      const pair = twice(() => new BatchedTurboQuantKVCache(kb, vb, fused));
      try {
        pair[0].mergeRows(a); pair[1].mergeRows(b);
        diffs.push(...compareSteps(`BatchedTurboQuantKVCache k${kb}v${vb} ${fusedName(fused)}[${lengths}]`,
          pair, lengths.length, BATCH_STEPS));
      } finally { disposeResources([...pair, ...a, ...b]); }
    }
    expectAllZero(diffs);
  });
}

for (const [kb, vb] of NAMED) for (const d of [64, 256, 512]) {
  test(`BatchedTurboQuantKVCache k${kb}v${vb}: rows at offsets 5,17,3,40, head dim ${d}`, () => {
    const diffs: number[] = [];
    for (const fused of FUSED) {
      const [a, b] = soloRows(() => new TurboQuantKVCache(kb, vb, fused), [5, 17, 3, 40], d);
      const pair = twice(() => new BatchedTurboQuantKVCache(kb, vb, fused));
      try {
        pair[0].mergeRows(a); pair[1].mergeRows(b);
        diffs.push(...compareSteps(`BatchedTurboQuantKVCache k${kb}v${vb} ${fusedName(fused)} d${d}[5,17,3,40]`,
          pair, 4, BATCH_STEPS, d));
      } finally { disposeResources([...pair, ...a, ...b]); }
    }
    expectAllZero(diffs);
  });
}

const PADDINGS = [{ leftPadding: [2, 0], lengths: [6, 8] }, { lengths: [5, 8], rightPadding: [3, 0] },
  { leftPadding: [0, 3, 1, 5], lengths: [8, 5, 7, 3], rightPadding: [0, 0, 0, 0] }];

for (const [kb, vb] of NAMED) for (const padding of PADDINGS) {
  test(`BatchedTurboQuantKVCache k${kb}v${vb}: padded prefill ${JSON.stringify(padding)}`, () => {
    const B = padding.lengths.length;
    const diffs: number[] = [];
    for (const fused of FUSED) {
      const label = `BatchedTurboQuantKVCache k${kb}v${vb} ${fusedName(fused)}`;
      const pair = twice(() => new BatchedTurboQuantKVCache(kb, vb, fused));
      try {
        for (const cache of pair) cache.preparePrefill(padding);
        diffs.push(...compareSteps(`${label} prefill`, pair, B, [8]));
        for (const cache of pair) cache.finalizePrefill();
        diffs.push(...compareSteps(`${label} after prefill`, pair, B, ["D", "D", 3, 37, 200, "D"]));
      } finally { disposeResources(pair); }
    }
    expectAllZero(diffs);
  });
}

for (const [kb, vb] of NAMED) {
  test(`BatchedTurboQuantKVCache k${kb}v${vb}: verify windows rolled back to unequal rows, then decode`, () => {
    const diffs: number[] = [];
    for (const fused of FUSED) {
      const label = `BatchedTurboQuantKVCache k${kb}v${vb} ${fusedName(fused)} speculative`;
      const [a, b] = soloRows(() => new TurboQuantKVCache(kb, vb, fused), [12, 30]);
      const pair = twice(() => new BatchedTurboQuantKVCache(kb, vb, fused));
      try {
        pair[0].mergeRows(a); pair[1].mergeRows(b);
        for (const keep of [[1, 3], [0, 2], [4, 4]]) {
          for (const cache of pair) cache.specRoundBegin();
          diffs.push(...compareSteps(label, pair, 2, [4]));
          for (const cache of pair) cache.specRoundRollback(keep);
          expect(pair[1].rowOffsets).toEqual(pair[0].rowOffsets);
          diffs.push(...compareSteps(label, pair, 2, ["D", 3]));
        }
      } finally { disposeResources([...pair, ...a, ...b]); }
    }
    expectAllZero(diffs);
  });
}

// Gemma 4's KV-shared layers attend the donor's fetched keys and values with
// their own queries and un-rotate each output; the read is attended again.
for (const [kb, vb] of NAMED) {
  test(`KV-shared queries on one read match the graph's sharer path, k${kb}v${vb}`, () => {
    const diffs: number[] = [];
    for (const fused of FUSED) {
      const [a, b] = soloRows(() => new TurboQuantKVCache(kb, vb, fused), [5, 17]);
      const solo = twice(() => new TurboQuantKVCache(kb, vb, fused));
      const batched = twice(() => new BatchedTurboQuantKVCache(kb, vb, fused));
      try {
        batched[0].mergeRows(a); batched[1].mergeRows(b);
        for (const [name, pair, B] of [["TurboQuantKVCache", solo, 1], ["BatchedTurboQuantKVCache", batched, 2]] as const) {
          for (const L of [37, 1, 3]) {
            const [k, v] = kv(B, L);
            using donorQ = query(B, L), sharerQ = query(B, L);
            try {
              const mask = pair[0].makeMask(L, null);
              const [keys, values] = pair[0].rotatedValueAttention!.updateAndFetchDeferredV(k, v);
              const restore = pair[0].rotatedValueAttention!.captureValueTransform?.();
              const expected = [donorQ, sharerQ].map(q => {
                using attn = ops.sdpa(q, keys, values, SCALE, mask.mode, mask.arr);
                const out = restore ? restore(attn) : unrotateValues(attn);
                out.eval();
                return out;
              });
              keys.dispose(); values.dispose(); mask.arr?.dispose();
              const read = L === 1 ? pair[1].appendDecode(k, v) : pair[1].appendWindow(k, v);
              try {
                for (const [index, q] of [donorQ, sharerQ].entries()) {
                  using actual = read.attend(q, SCALE);
                  const diff = maxDiff(actual, expected[index]!);
                  diffs.push(diff);
                  outcomes.push({ label: `${name} k${kb}v${vb} ${fusedName(fused)} ${index ? "sharer" : "donor"} ${L === 1 ? "decode" : `window ${L}`}`, diff });
                }
              } finally { read.dispose(); disposeResources(expected); }
            } finally { k.dispose(); v.dispose(); }
          }
        }
      } finally { disposeResources([...solo, ...batched, ...a, ...b]); }
    }
    expectAllZero(diffs);
  });
}

test("mask memo: row layouts made from a TurboQuantKVCache share its masks, one build per forward", () => {
  const masks = new AttentionMasks();
  const source = new TurboQuantKVCache(8, 3, true, masks);
  const make = ownedCacheLayoutFactory(source)!;
  const [a] = soloRows(() => new TurboQuantKVCache(8, 3, true), [5, 17]);
  const layers = Array.from({ length: 4 }, () => make() as BatchedTurboQuantKVCache);
  const reference = Array.from({ length: 4 }, () => new BatchedTurboQuantKVCache(8, 3, true));
  const held: AttentionRead[] = [];
  try {
    for (const layer of layers) expect(layer.masks).toBe(masks);
    expect(layers[0]!.makeEmptyBatch().masks).toBe(masks);
    for (const cache of [...layers, ...reference]) cache.mergeRows(a);
    const forward = (L: number) => {
      const diffs: number[] = [];
      for (let layer = 0; layer < 4; layer++) {
        const [k, v] = kv(2, L);
        using q = query(2, L);
        try {
          using expected = oldRead(reference[layer]!, k, v, q);
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
  } finally { disposeResources([...held, ...layers, ...reference, ...a, source]); }
});

test("bit-identity report", () => {
  for (const { label, diff } of outcomes) console.log(`${diff === 0 ? "identical" : "DIFFERS  "} maxDiff=${diff} ${label}`);
  expect(outcomes.length).toBeGreaterThan(0);
});
