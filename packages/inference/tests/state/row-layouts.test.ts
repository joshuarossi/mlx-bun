// Model-free: the row layouts ordinary continuous decoding keeps its running rows
// in (state/layout `ownedCacheLayout`), through the BatchableCache port the batch
// group drives: mergeRows (an adopted lone row, then joiners), decode steps,
// filterRows, extractRow. The oracle is the solo replay: every row's updates
// applied to its own serial cache; an extracted row must equal it byte for byte,
// and a step's mask and RoPE positions must be what each row's padding implies.
import { describe, expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { BatchableCache, Cache } from "../../src/contracts/mlx/cache";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/runtime/config";
import { isBatchableCache } from "../../src/state/capabilities";
import { PaddedKVRows } from "../../src/state/batched-mask";
import { PaddedQuantKVRows, type QuantRow } from "../../src/state/batched-quant";
import { BatchedRotatingCache } from "../../src/state/batched-rotating";
import { BatchedRotatingQuantCache } from "../../src/state/batched-rotating-quant";
import { BatchedSSMCache } from "../../src/state/batched-ssm";
import { KVCache } from "../../src/state/kv";
import { ownedCacheLayout, ownedCacheLayoutFactory } from "../../src/state/layout";
import { QuantizedKVCache } from "../../src/state/quantized-kv";
import { RotatingKVCache } from "../../src/state/rotating-kv";
import { RotatingQuantizedKVCache } from "../../src/state/rotating-quantized-kv";
import { SSMCache } from "../../src/state/ssm";

const bytes = (a: MlxArray): number[] => { using c = ops.contiguous(a); return [...c.rawBytes()]; };
const grid = (L: number, D: number, f: (t: number, d: number) => number): MlxArray => {
  const data = new Float32Array(L * D);
  for (let t = 0; t < L; t++) for (let d = 0; d < D; d++) data[t * D + d] = f(t, d);
  return MlxArray.fromFloat32(data, [1, 1, L, D]);
};
const dispose3 = (t: ops.QuantizedTensor) => { t.packed.dispose(); t.scales.dispose(); t.biases.dispose(); };
const bytes3 = (t: ops.QuantizedTensor) => [bytes(t.packed), bytes(t.scales), bytes(t.biases)];

/** A serial cache holding row `b`'s first `L` tokens, values a function of (row, token, dim). */
const D = 4, QD = 64, GS = 64, BITS = 4;
const val = (b: number, t: number, d: number) => b * 1000 + t * 10 + d;
const qval = (b: number, t: number, d: number) => b * 100 + t * 3 + d * 0.5;

/** One decode step for every row of `layout` (values for each row's next token), applied to the
 * layout as one [B,1,1,D] update and to each row's solo cache as its own [1,1,1,D] update. */
function stepAll(layout: Cache, rows: { solo: Cache; id: number; f: (b: number, t: number, d: number) => number }[], dim: number,
  quantized = false): void {
  const data = new Float32Array(rows.length * dim);
  rows.forEach((row, b) => { for (let d = 0; d < dim; d++) data[b * dim + d] = row.f(row.id, row.solo.offset, d); });
  using batch = MlxArray.fromFloat32(data, [rows.length, 1, 1, dim]);
  if (quantized) {
    const [k, v] = layout.quantizedAttention!.updateAndFetchQuantized(batch, batch); dispose3(k); dispose3(v);
  } else { const [k, v] = layout.updateAndFetch(batch, batch); k.dispose(); v.dispose(); }
  (layout as { releaseRopeArr?: () => void }).releaseRopeArr?.();
  for (const row of rows) {
    using one = grid(1, dim, (_t, d) => row.f(row.id, row.solo.offset, d));
    if (quantized) {
      const [k, v] = row.solo.quantizedAttention!.updateAndFetchQuantized(one, one); dispose3(k); dispose3(v);
    } else { const [k, v] = row.solo.updateAndFetch(one, one); k.dispose(); v.dispose(); }
  }
}

describe("padded full-attention rows (plain)", () => {
  const solo = (b: number, L: number) => {
    const c = new KVCache(); using k = grid(L, D, (t, d) => val(b, t, d));
    const [rk, rv] = c.updateAndFetch(k, k); rk.dispose(); rv.dispose(); return c;
  };
  const twin = (b: number, L: number) => solo(b, L);
  const rowsOf = (solos: KVCache[], ids: number[]) => ids.map(id => ({ solo: solos[id]!, id, f: val }));
  const same = (extracted: Cache, oracle: KVCache) => {
    const ex = extracted as KVCache;
    expect(ex).toBeInstanceOf(KVCache);
    expect(ex.offset).toBe(oracle.offset);
    const [ek, ev] = ex.temporalView(), [sk, sv] = oracle.temporalView();
    expect(bytes(ek)).toEqual(bytes(sk)); expect(bytes(ev)).toEqual(bytes(sv));
    for (const a of [ek, ev, sk, sv]) a.dispose();
  };

  for (const mode of ["extend", "re-merge"]) {
    test(`an adopted row, two joiners, decode and an eviction keep every row equal to its solo replay (${mode})`, () => {
      const env = mode === "extend" ? {} : { MLX_BUN_BATCH_EXTEND: "0" };
      withRuntimeConfig(createRuntimeConfig(env), () => {
        const lens = [5, 3, 4], solos = lens.map((L, b) => solo(b, L));
        const adopted = twin(0, lens[0]!);
        expect(ownedCacheLayoutFactory(adopted)).toBeDefined();
        let layout = ownedCacheLayout(adopted)!;
        expect(layout).toBeInstanceOf(PaddedKVRows); expect(isBatchableCache(layout)).toBe(true);
        expect(isBatchableCache(adopted)).toBe(false); // a serial cache is a row source, not a batch
        let ids = [0];
        const join = (b: number) => {
          const previous = layout, joiner = twin(b, lens[b]!);
          const next = ownedCacheLayout(joiner)!;
          next.mergeRows([previous, joiner]);
          previous.dispose(); joiner.dispose(); layout = next; ids.push(b);
        };
        // The first merge takes the adopted serial cache itself as its first row.
        const first = ownedCacheLayout(adopted)!, second = twin(1, lens[1]!);
        first.mergeRows([adopted, second]); adopted.dispose(); second.dispose(); layout = first; ids.push(1);
        expect(layout.batchSize).toBe(2);
        expect(layout.rowOffsets).toEqual([5, 3]);
        expect(layout.leftPad).toEqual([0, 2]);
        stepAll(layout, rowsOf(solos, ids), D); stepAll(layout, rowsOf(solos, ids), D);
        join(2);
        expect(layout.rowOffsets).toEqual([7, 5, 4]);
        expect(layout.leftPad.every((pad, i) => pad >= 0 && layout.rowOffsets[i]! + pad === layout.offset)).toBe(true);
        stepAll(layout, rowsOf(solos, ids), D); stepAll(layout, rowsOf(solos, ids), D);
        ids.forEach((id, b) => same(layout.extractRow(b), solos[id]!));
        // Evicting the longest row removes the padding the survivors share; the rest keep decoding.
        const beforeOffset = layout.offset;
        layout.filterRows([1, 2]); ids = [1, 2];
        expect(layout.batchSize).toBe(2);
        expect(layout.leftPad[layout.leftPad.indexOf(Math.min(...layout.leftPad))]).toBe(0);
        expect(layout.offset).toBeLessThan(beforeOffset);
        stepAll(layout, rowsOf(solos, ids), D);
        ids.forEach((id, b) => same(layout.extractRow(b), solos[id]!));
        layout.dispose(); for (const c of solos) c.dispose();
      });
    });
  }

  test("a padded step masks each row's padding and positions it at its own offset; equal rows run the serial graph", () => {
    const a = solo(0, 5), b = solo(1, 3), layout = new PaddedKVRows();
    layout.mergeRows([a, b]);
    expect(layout.leftPad).toEqual([0, 2]);
    // Step N=1 over S = offset + 1 keys: row 1 may not attend its two padding columns.
    const mask = layout.makeMask(1, null);
    expect(mask.mode).toBe("array");
    expect(mask.arr!.shape).toEqual([2, 1, 1, 6]);
    expect([...mask.arr!.toIntTokens()]).toEqual([1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1]);
    expect([...layout.ropeOffsetArr!.toIntTokens()]).toEqual([5, 3]);
    mask.arr!.dispose();
    layout.releaseRopeArr();
    const c = solo(2, 5), same = new PaddedKVRows(); same.mergeRows([a, c]);
    expect(same.leftPad).toEqual([0, 0]);
    expect(same.ropeOffsetArr).toBeUndefined();
    const plain = same.makeMask(1, null);
    expect(plain).toEqual({ mode: "", arr: null });
    for (const cache of [a, b, c, layout, same]) cache.dispose();
  });

  test("it reads dense like the serial cache, borrows its sources and refuses foreign state", () => {
    const layout = new PaddedKVRows(), a = solo(0, 4), b = solo(1, 2);
    expect(layout.denseKvReads?.appendable(0)).toBe(true);
    layout.mergeRows([a, b]);
    expect(a.offset).toBe(4); expect(b.offset).toBe(2); // sources untouched
    expect(() => layout.mergeRows([a, b])).toThrow("needs an empty batch");
    expect(() => new PaddedKVRows().mergeRows([a, new RotatingKVCache(8)])).toThrow("cannot merge");
    expect(layout.projectedBytes(10)).toBeGreaterThan(0);
    for (const c of [a, b, layout]) c.dispose();
  });
});

describe("padded full-attention rows (affine quantized)", () => {
  const quant = (b: number, L: number) => {
    const c = new KVCache(); using k = grid(L, QD, (t, d) => qval(b, t, d));
    const [rk, rv] = c.updateAndFetch(k, k); rk.dispose(); rv.dispose(); return c.toQuantized(GS, BITS);
  };
  const same = (extracted: Cache, oracle: QuantizedKVCache) => {
    const ex = extracted as QuantizedKVCache;
    expect(ex).toBeInstanceOf(QuantizedKVCache);
    expect(ex.offset).toBe(oracle.offset);
    const [ek, ev] = ex.temporalView(), [sk, sv] = oracle.temporalView();
    expect(bytes3(ek)).toEqual(bytes3(sk)); expect(bytes3(ev)).toEqual(bytes3(sv));
    for (const t of [ek, ev, sk, sv]) dispose3(t);
  };

  test("joins, decode, eviction and extraction equal the solo replay, with the padding mask and positions of the plain layout", () => {
    const lens = [5, 3, 4], solos = lens.map((L, b) => quant(b, L));
    const adopted = quant(0, lens[0]!);
    const layout = ownedCacheLayout(adopted)!;
    expect(layout).toBeInstanceOf(PaddedQuantKVRows);
    expect(layout.signature()).toBe(`kv:padded-rows-quant:${BITS}:${GS}`);
    expect(layout.denseKvReads).toBeUndefined(); // attends the quantized planes; no plain read
    const joiner = quant(1, lens[1]!);
    layout.mergeRows([adopted, joiner]); adopted.dispose(); joiner.dispose();
    expect(layout.rowOffsets).toEqual([5, 3]); expect(layout.leftPad).toEqual([0, 2]);
    const mask = layout.makeMask(1, null);
    expect([...mask.arr!.toIntTokens()]).toEqual([1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1]);
    expect([...layout.ropeOffsetArr!.toIntTokens()]).toEqual([5, 3]);
    mask.arr!.dispose(); (layout as PaddedQuantKVRows).releaseRopeArr();
    const rows = (ids: number[]) => ids.map(id => ({ solo: solos[id]!, id, f: qval }));
    let ids = [0, 1];
    stepAll(layout, rows(ids), QD, true); stepAll(layout, rows(ids), QD, true);
    const third = quant(2, lens[2]!), next = new PaddedQuantKVRows(GS, BITS);
    next.mergeRows([layout, third]); layout.dispose(); third.dispose(); ids = [0, 1, 2];
    stepAll(next, rows(ids), QD, true);
    ids.forEach((id, b) => same(next.extractRow(b), solos[id]!));
    next.filterRows([0, 2]); ids = [0, 2];
    stepAll(next, rows(ids), QD, true);
    ids.forEach((id, b) => same(next.extractRow(b), solos[id]!));
    next.dispose(); for (const c of solos) c.dispose();
  });
});

describe("sliding-window rings", () => {
  const W = 8;
  const ring = (b: number, L: number, quantized: boolean) => {
    const c = new RotatingKVCache(W), dim = quantized ? QD : 2, f = quantized ? qval : val;
    using k = grid(L, dim, (t, d) => f(b, t, d));
    const [rk, rv] = c.updateAndFetch(k, k); rk.dispose(); rv.dispose();
    return quantized ? c.toQuantized(GS, BITS) : c;
  };

  test("plain: an adopted ring and two joiners decode through wrap; every extracted row equals its solo replay", () => {
    const lens = [6, 4, 9], solos = lens.slice(0, 2).map((L, b) => ring(b, L, false) as RotatingKVCache);
    const adopted = ring(0, lens[0]!, false), joiner = ring(1, lens[1]!, false);
    const layout = ownedCacheLayout(adopted)!;
    expect(layout).toBeInstanceOf(BatchedRotatingCache);
    layout.mergeRows([adopted, joiner]); adopted.dispose(); joiner.dispose();
    expect(layout.batchSize).toBe(2); expect(layout.rowOffsets).toEqual([6, 4]);
    let ids = [0, 1];
    const rows = (list: number[]) => list.map(id => ({ solo: solos[id]!, id, f: val }));
    for (let s = 0; s < 3; s++) stepAll(layout, rows(ids), 2);
    // A third row joins the running rings, already past the window (its prompt fills it).
    solos.push(ring(2, lens[2]!, false) as RotatingKVCache);
    const late = ring(2, lens[2]!, false), joined = layout.makeEmptyBatch();
    joined.mergeRows([layout, late]); layout.dispose(); late.dispose(); ids = [0, 1, 2];
    expect(joined.batchSize).toBe(3);
    for (let s = 0; s < 6; s++) {
      stepAll(joined, rows(ids), 2);
      ids.forEach((id, b) => {
        const ex = joined.extractRow(b) as RotatingKVCache, oracle = solos[id]!;
        expect(ex.offset).toBe(oracle.offset);
        const [ek, ev] = ex.temporalView(), [sk, sv] = oracle.temporalView();
        expect(bytes(ek)).toEqual(bytes(sk)); expect(bytes(ev)).toEqual(bytes(sv));
        for (const a of [ek, ev, sk, sv]) a.dispose();
        ex.dispose();
      });
    }
    joined.filterRows([0, 2]);
    expect(joined.batchSize).toBe(2);
    joined.dispose(); for (const c of solos) c.dispose();
  });

  test("quantized: an adopted ring and a joiner decode through wrap; every extracted row equals its solo replay", () => {
    const lens = [6, 4], solos = lens.map((L, b) => ring(b, L, true) as RotatingQuantizedKVCache);
    const adopted = ring(0, lens[0]!, true), joiner = ring(1, lens[1]!, true);
    const layout = ownedCacheLayout(adopted)!;
    expect(layout).toBeInstanceOf(BatchedRotatingQuantCache);
    layout.mergeRows([adopted, joiner]); adopted.dispose(); joiner.dispose();
    expect(layout.rowOffsets).toEqual([6, 4]);
    const rows = [0, 1].map(id => ({ solo: solos[id]!, id, f: qval }));
    for (let s = 0; s < 8; s++) {
      stepAll(layout, rows, QD, true);
      [0, 1].forEach(b => {
        const ex = layout.extractRow(b) as RotatingQuantizedKVCache, oracle = solos[b]!;
        expect(ex.offset).toBe(oracle.offset);
        const [ek, ev] = ex.temporalView(), [sk, sv] = oracle.temporalView();
        expect(bytes3(ek)).toEqual(bytes3(sk)); expect(bytes3(ev)).toEqual(bytes3(sv));
        for (const t of [ek, ev, sk, sv]) dispose3(t);
        ex.dispose();
      });
    }
    layout.dispose(); for (const c of solos) c.dispose();
  });
});

describe("recurrent state", () => {
  const conv = (rows: number[]) => MlxArray.fromFloat32(Float32Array.from(rows.flatMap(r => [r, r + 1, r + 2])), [rows.length, 1, 3]);
  const recurrent = (rows: number[]) => MlxArray.fromFloat32(Float32Array.from(rows.flatMap(r => [r * 2, r * 2 + 1])), [rows.length, 1, 1, 2]);
  const ssm = (row: number, offset: number) => {
    const c = new SSMCache(); c.conv = conv([row]); c.recurrent = recurrent([row]); c.advance(offset); return c;
  };

  test("an adopted row and a joiner batch by row, keep their own coverage, and publish only exact coverage", () => {
    const adopted = ssm(1, 5), joiner = ssm(7, 3);
    expect(isBatchableCache(adopted)).toBe(false);
    const layout = ownedCacheLayout(adopted)!;
    expect(layout).toBeInstanceOf(BatchedSSMCache);
    layout.mergeRows([adopted, joiner]); adopted.dispose(); joiner.dispose();
    expect(layout.batchSize).toBe(2); expect(layout.rowOffsets).toEqual([5, 3]); expect(layout.leftPad).toEqual([0, 0]);
    expect(bytes(layout.state()[0]!)).toEqual(bytes(conv([1, 7])));
    expect(bytes(layout.state()[1]!)).toEqual(bytes(recurrent([1, 7])));
    // Recurrent state cannot be trimmed: a row publishes only as the tokens it covers.
    expect(layout.canPublishRow!(0, 5)).toBe(true); expect(layout.canPublishRow!(1, 5)).toBe(false);
    const row = layout.extractRow(1) as SSMCache;
    expect(row.offset).toBe(3); expect(row.offsets).toBeNull();
    expect(bytes(row.conv!)).toEqual(bytes(conv([7])));
    row.dispose();
    layout.filterRows([1]);
    expect(layout.rowOffsets).toEqual([3]);
    layout.dispose();
  });
});

describe("which layout a cache's rows are kept in", () => {
  test("every storage family has one; caches that own their layout make it; foreign state has none", () => {
    const layouts: [Cache, Function][] = [
      [new KVCache(), PaddedKVRows], [new QuantizedKVCache(GS, BITS), PaddedQuantKVRows], [new RotatingKVCache(W_), BatchedRotatingCache],
      [new RotatingQuantizedKVCache(W_, GS, BITS), BatchedRotatingQuantCache], [new SSMCache(), BatchedSSMCache],
    ];
    for (const [cache, kind] of layouts) {
      const layout = ownedCacheLayout(cache) as BatchableCache;
      expect(layout, cache.signature()).toBeInstanceOf(kind);
      expect(isBatchableCache(layout)).toBe(true);
      expect(layout.batchSize ?? 0).toBe(0);
      // An empty layout of the same storage: its own empty batch is the same kind.
      const again = layout.makeEmptyBatch(); expect(again).toBeInstanceOf(kind);
      again.dispose(); layout.dispose(); cache.dispose();
    }
    const foreign = { signature: () => "custom", offset: 0 } as unknown as Cache;
    expect(ownedCacheLayoutFactory(foreign)).toBeUndefined();
    expect(ownedCacheLayout(foreign)).toBeUndefined();
    const owned = new PaddedKVRows();
    expect(ownedCacheLayout(owned)).toBeInstanceOf(PaddedKVRows); // a layout makes its own empty batch
    owned.dispose();
  });
});
const W_ = 8;
