// FAST (model-free): BatchedRotatingQuantCache — Phase 3 milestone 2. The
// composition rule binds the SERIAL RotatingQuantizedKVCache as the per-row
// oracle (no stack ships batched rotating-quantized KV), so the gates here
// are LOGICAL byte-identity per row against serial caches fed the same
// inputs, driven through ring wrap:
//   1. B=1: twin merged from a serial solo, then both advanced one token at
//      a time — temporalView triples byte-identical at every step, and the
//      twin's mask/ring bookkeeping identical to the oracle-verified bf16
//      BatchedRotatingCache driven through the same geometry.
//   2. B=2 (uneven rows → left-pad): each twin row's valid temporal slice
//      byte-identical to its serial oracle at every step, through wrap
//      (where the pad is consumed) — plus filter() dropping a row.
// Quantize-on-write is deterministic and packs along HEAD_DIM, so identical
// bf16 inputs must produce identical (packed, scales, biases) bytes; any
// divergence is a ring-mechanics bug, not noise. Real-model coverage:
// tests/batched-kv-quant-parity.test.ts (gemma gate).

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";
import { RotatingQuantizedKVCache } from "../../src/model/gemma4-base";
import { BatchedRotatingQuantCache } from "../../src/model/batched-rotating-quant";
import { BatchedRotatingCache } from "../../src/model/batched-rotating";

const H = 2, D = 64, MAX = 8, GROUP = 64, BITS = 4;

/** Deterministic pseudo-random floats (LCG) — same stream every run. */
const lcg = (seed: number) => {
  let s = seed >>> 0;
  return () => {
    s = (s * 1664525 + 1013904223) >>> 0;
    return (s / 0xffffffff) * 2 - 1;
  };
};
const bf16Row = (rng: () => number, L: number): MlxArray => {
  const f = new Float32Array(H * L * D);
  for (let i = 0; i < f.length; i++) f[i] = rng();
  const a = MlxArray.fromFloat32(f, [1, H, L, D]);
  const b = a.astype(Dtype.bfloat16);
  a.dispose();
  return b;
};

const readTriple = (t: ops.QuantizedTensor) => ({
  packed: t.packed.toIntTokens(),
  scales: t.scales.toFloat32(),
  biases: t.biases.toFloat32(),
});
const disposeTriple = (t: ops.QuantizedTensor): void => {
  t.packed.dispose(); t.scales.dispose(); t.biases.dispose();
};
const expectTripleEqual = (a: ops.QuantizedTensor, b: ops.QuantizedTensor, tag: string) => {
  const ra = readTriple(a), rb = readTriple(b);
  expect(ra.packed.length, `${tag} packed len`).toBe(rb.packed.length);
  expect(ra.packed, `${tag} packed`).toEqual(rb.packed);
  expect(Array.from(ra.scales), `${tag} scales`).toEqual(Array.from(rb.scales));
  expect(Array.from(ra.biases), `${tag} biases`).toEqual(Array.from(rb.biases));
};

/** Slice one batch row's valid temporal region out of a twin triple. */
const rowSlice = (t: ops.QuantizedTensor, b: number, from: number): ops.QuantizedTensor => {
  const cut = (a: MlxArray): MlxArray => {
    const [, h, S, d] = a.shape as [number, number, number, number];
    return a.slice([b, 0, from, 0], [b + 1, h, S, d]);
  };
  return { packed: cut(t.packed), scales: cut(t.scales), biases: cut(t.biases) };
};

describe("BatchedRotatingQuantCache (milestone 2, model-free)", () => {
  test("B=1: byte-identical to the serial oracle through ring wrap; ring bookkeeping == bf16 twin", () => {
    const rngQ = lcg(42), rngT = lcg(42), rngB = lcg(42);
    const PREFILL = 5, STEPS = 18; // wraps MAX=8 twice over

    // Serial oracle: prefill (concat path) then merge the twin from its view.
    const serial = new RotatingQuantizedKVCache(MAX, GROUP, BITS);
    {
      const k = bf16Row(rngQ, PREFILL), v = bf16Row(rngQ, PREFILL);
      const [fk, fv] = serial.updateAndFetchQuantized(k, v);
      disposeTriple(fk); disposeTriple(fv);
      k.dispose(); v.dispose();
    }
    const [sk0, sv0] = serial.temporalView();
    const twin = BatchedRotatingQuantCache.merge([{ keys: sk0, values: sv0 }], [serial.offset], MAX, GROUP, BITS);
    disposeTriple(sk0); disposeTriple(sv0);

    // bf16 control with the same geometry (content irrelevant — we compare
    // MASKS and per-row bookkeeping, which are content-independent).
    const ctlRow = () => {
      const f = new Float32Array(H * PREFILL * D).fill(0.5);
      return MlxArray.fromFloat32(f, [1, H, PREFILL, D]);
    };
    const ck = ctlRow(), cv = ctlRow();
    const bf = BatchedRotatingCache.merge([{ keys: ck, values: cv }], [PREFILL], MAX);
    ck.dispose(); cv.dispose();

    for (let s = 0; s < STEPS; s++) {
      // Masks/bookkeeping compared PRE-write (the model's read order).
      const mq = twin.makeMask(1, MAX);
      const mb = bf.makeMask(1, MAX);
      expect(Array.from(mq.arr!.toFloat32()), `step ${s} mask`).toEqual(Array.from(mb.arr!.toFloat32()));
      mq.arr!.dispose(); mb.arr!.dispose();
      expect(twin.leftPad, `step ${s} leftPad`).toEqual(bf.leftPad);
      expect(twin.offsetArr, `step ${s} offsetArr`).toEqual(bf.offsetArr);

      const kq = bf16Row(rngT, 1), vq = bf16Row(rngT, 1);
      const [tk, tv] = twin.updateAndFetchQuantized(kq, vq);
      disposeTriple(tk); disposeTriple(tv);
      kq.dispose(); vq.dispose();

      const ks = bf16Row(rngB, 1), vs = bf16Row(rngB, 1);
      // Same LCG stream as rngT one call-pair behind? No — rngT and rngB
      // advanced identically (same seed, same call counts), so ks/vs are
      // byte-identical to kq/vq.
      const [sk, sv] = serial.updateAndFetchQuantized(ks, vs);
      disposeTriple(sk); disposeTriple(sv);
      ks.dispose(); vs.dispose();

      const bk = MlxArray.fromFloat32(new Float32Array(H * D).fill(0.5), [1, H, 1, D]);
      const bv = MlxArray.fromFloat32(new Float32Array(H * D).fill(0.5), [1, H, 1, D]);
      const [xk, xv] = bf.updateAndFetch(bk, bv);
      xk.dispose(); xv.dispose();
      bk.dispose(); bv.dispose();

      expect(twin.offset, `step ${s} scalar offset`).toBe(serial.offset);
      const [tvk, tvv] = twin.temporalView();
      const [svk, svv] = serial.temporalView();
      expectTripleEqual(tvk, svk, `step ${s} K`);
      expectTripleEqual(tvv, svv, `step ${s} V`);
      for (const t of [tvk, tvv, svk, svv]) disposeTriple(t);
    }
    twin.dispose();
    serial.dispose();
    bf.dispose();
  });

  test("B=2 uneven rows: each row byte-identical to its serial oracle through wrap; filter() drops a row", () => {
    const mk = (seed: number, prefill: number) => {
      const rng = lcg(seed);
      const c = new RotatingQuantizedKVCache(MAX, GROUP, BITS);
      const k = bf16Row(rng, prefill), v = bf16Row(rng, prefill);
      const [fk, fv] = c.updateAndFetchQuantized(k, v);
      disposeTriple(fk); disposeTriple(fv);
      k.dispose(); v.dispose();
      return { rng, c };
    };
    const A = mk(7, 6), B = mk(9, 3); // uneven → row B left-padded by 3

    const [ak, av] = A.c.temporalView();
    const [bk, bv] = B.c.temporalView();
    const twin = BatchedRotatingQuantCache.merge(
      [{ keys: ak, values: av }, { keys: bk, values: bv }],
      [A.c.offset, B.c.offset], MAX, GROUP, BITS,
    );
    for (const t of [ak, av, bk, bv]) disposeTriple(t);
    expect(twin.leftPad).toEqual([0, 3]);

    const STEPS = 14; // wraps: pads consumed, then steady-state ring
    // Fresh per-step decode streams; the BATCHED [2,...] input row must be
    // rowA-stacked-on-rowB so each row's bytes match its serial twin.
    const rngA = lcg(1234), rngB2 = lcg(5678);
    const rngA2 = lcg(1234), rngB3 = lcg(5678);
    for (let s = 0; s < STEPS; s++) {
      const a1k = bf16Row(rngA, 1), a1v = bf16Row(rngA, 1);
      const b1k = bf16Row(rngB2, 1), b1v = bf16Row(rngB2, 1);
      const k2 = ops.concatAxis([a1k, b1k], 0);
      const v2 = ops.concatAxis([a1v, b1v], 0);
      const [tk, tv] = twin.updateAndFetchQuantized(k2, v2);
      disposeTriple(tk); disposeTriple(tv);
      for (const a of [a1k, a1v, b1k, b1v, k2, v2]) a.dispose();

      const step = (o: { rng: () => number; c: RotatingQuantizedKVCache }, rng: () => number) => {
        const k = bf16Row(rng, 1), v = bf16Row(rng, 1);
        const [fk, fv] = o.c.updateAndFetchQuantized(k, v);
        disposeTriple(fk); disposeTriple(fv);
        k.dispose(); v.dispose();
      };
      step(A, rngA2);
      step(B, rngB3);

      // Per-row logical comparison: twin row b's valid temporal slice ==
      // the serial cache's LAST (valid - pad_b) temporal entries.
      const [twK, twV] = twin.temporalView();
      const valid = twK.packed.shape[2]!;
      for (const [b, oracle] of [[0, A.c], [1, B.c]] as const) {
        const pad = Math.max(0, twin.leftPad[b]!);
        const rowK = rowSlice(twK, b, pad);
        const rowV = rowSlice(twV, b, pad);
        const [oK, oV] = oracle.temporalView();
        const oLen = oK.packed.shape[2]!;
        const skip = oLen - (valid - pad);
        const cutO = (t: ops.QuantizedTensor): ops.QuantizedTensor => ({
          packed: t.packed.slice([0, 0, skip, 0], [1, H, oLen, t.packed.shape[3]!]),
          scales: t.scales.slice([0, 0, skip, 0], [1, H, oLen, t.scales.shape[3]!]),
          biases: t.biases.slice([0, 0, skip, 0], [1, H, oLen, t.biases.shape[3]!]),
        });
        const oKc = cutO(oK), oVc = cutO(oV);
        expectTripleEqual(rowK, oKc, `step ${s} row ${b} K`);
        expectTripleEqual(rowV, oVc, `step ${s} row ${b} V`);
        for (const t of [rowK, rowV, oK, oV, oKc, oVc]) disposeTriple(t);
        expect(twin.offsetArr[b], `step ${s} row ${b} offset`).toBe(oracle.offset);
      }
      disposeTriple(twK); disposeTriple(twV);
    }

    // Eviction: keep only row 1 (the ex-padded row); it must keep matching B.
    twin.filter([1]);
    expect(twin.leftPad.length).toBe(1);
    for (let s = 0; s < 4; s++) {
      const k = bf16Row(rngB2, 1), v = bf16Row(rngB2, 1);
      const [tk, tv] = twin.updateAndFetchQuantized(k, v);
      disposeTriple(tk); disposeTriple(tv);
      k.dispose(); v.dispose();
      const k2 = bf16Row(rngB3, 1), v2 = bf16Row(rngB3, 1);
      const [fk, fv] = B.c.updateAndFetchQuantized(k2, v2);
      disposeTriple(fk); disposeTriple(fv);
      k2.dispose(); v2.dispose();

      const [twK, twV] = twin.temporalView();
      const [oK, oV] = B.c.temporalView();
      const pad = Math.max(0, twin.leftPad[0]!);
      const valid = twK.packed.shape[2]!;
      const rowK = rowSlice(twK, 0, pad), rowV = rowSlice(twV, 0, pad);
      const oLen = oK.packed.shape[2]!;
      const skip = oLen - (valid - pad);
      const cutO = (t: ops.QuantizedTensor): ops.QuantizedTensor => ({
        packed: t.packed.slice([0, 0, skip, 0], [1, H, oLen, t.packed.shape[3]!]),
        scales: t.scales.slice([0, 0, skip, 0], [1, H, oLen, t.scales.shape[3]!]),
        biases: t.biases.slice([0, 0, skip, 0], [1, H, oLen, t.biases.shape[3]!]),
      });
      const oKc = cutO(oK), oVc = cutO(oV);
      expectTripleEqual(rowK, oKc, `post-filter step ${s} K`);
      expectTripleEqual(rowV, oVc, `post-filter step ${s} V`);
      for (const t of [rowK, rowV, oK, oV, oKc, oVc]) disposeTriple(t);
    }
    twin.dispose();
    A.c.dispose();
    B.c.dispose();
  });
});
