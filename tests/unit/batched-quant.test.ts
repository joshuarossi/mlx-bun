// Model-free mechanics gate for the quantized dynamic-B ops (Phase 3.1):
// merge/extend/filter over (packed, scales, biases) triples are pure array
// surgery along the TOKEN axis — a row's quantized bytes must be IDENTICAL
// before and after any batch re-arrangement (quantization packs along
// head_dim, so token-axis padding/concat/take can never touch a group).
// Runs in the normal suite (synthetic tensors, no model).

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { mergeQuantRows, extendQuantRows, filterQuantRows, type QuantRow } from "../../src/model/batched-quant";

const H = 2, D = 64, GROUP = 32, BITS = 4;

/** Deterministic pseudo-random bf16 [1,H,L,D] and its quantized triple. */
function quantRow(L: number, seed: number): QuantRow {
  const n = H * L * D;
  const data = new Float32Array(n);
  let x = seed >>> 0;
  for (let i = 0; i < n; i++) {
    x = (x * 1664525 + 1013904223) >>> 0;
    data[i] = ((x >>> 8) / 2 ** 24 - 0.5) * 4;
  }
  const f32 = MlxArray.fromFloat32(data, [1, H, L, D]);
  const bf = f32.astype(Dtype.bfloat16);
  f32.dispose();
  const keys = ops.quantize(bf, GROUP, BITS);
  const values = ops.quantize(bf, GROUP, BITS);
  bf.dispose();
  return { keys, values };
}

const disposeTriple = (t: ops.QuantizedTensor) => {
  t.packed.dispose(); t.scales.dispose(); t.biases.dispose();
};
const disposeRow = (r: QuantRow) => { disposeTriple(r.keys); disposeTriple(r.values); };

/** Extract row b's unpadded slice of a batched triple and compare bytes with
 *  the original solo triple. */
function expectRowIdentical(
  batched: ops.QuantizedTensor, b: number, pad: number, solo: ops.QuantizedTensor,
): void {
  const L = solo.packed.shape[2]!;
  for (const part of ["packed", "scales", "biases"] as const) {
    const whole = batched[part];
    const dLast = whole.shape[3]!;
    const cut = whole.slice([b, 0, pad, 0], [b + 1, H, pad + L, dLast]);
    const got = cut.toFloat32();
    const want = solo[part].toFloat32();
    cut.dispose();
    expect(got.length).toBe(want.length);
    let same = true;
    for (let i = 0; i < want.length; i++) if (got[i] !== want[i]) { same = false; break; }
    expect(same).toBe(true); // bit-identical: batch surgery must not touch bytes
  }
}

describe("batched quantized KV mechanics (model-free)", () => {
  test("mergeQuantRows: rows land right-aligned, bytes identical", () => {
    const rows = [quantRow(24, 1), quantRow(9, 2), quantRow(17, 3)];
    const m = mergeQuantRows(rows);
    expect(m.width).toBe(24);
    expect(m.leftPad).toEqual([0, 15, 7]);
    expect(m.keys.packed.shape[0]).toBe(3);
    rows.forEach((r, b) => {
      expectRowIdentical(m.keys, b, m.leftPad[b]!, r.keys);
      expectRowIdentical(m.values, b, m.leftPad[b]!, r.values);
    });
    rows.forEach(disposeRow);
    disposeTriple(m.keys); disposeTriple(m.values);
  });

  test("extendQuantRows: pads grow, never shrink; all three tensors stay in sync", () => {
    const a = quantRow(12, 4);
    const b = quantRow(20, 5);
    const m0 = mergeQuantRows([a]);
    const ext = extendQuantRows(m0.keys, m0.values, m0.leftPad, b);
    expect(ext.width).toBe(20);
    expect(ext.leftPad).toEqual([8, 0]); // existing row's pad grew by 8
    expectRowIdentical(ext.keys, 0, 8, a.keys);
    expectRowIdentical(ext.keys, 1, 0, b.keys);
    expectRowIdentical(ext.values, 0, 8, a.values);
    for (const part of ["packed", "scales", "biases"] as const)
      expect(ext.keys[part].shape[2]).toBe(20); // token axis in lockstep across the triple
    disposeRow(a); disposeRow(b);
    disposeTriple(m0.keys); disposeTriple(m0.values);
    disposeTriple(ext.keys); disposeTriple(ext.values);
  });

  test("filterQuantRows: eviction keeps surviving rows byte-identical", () => {
    const rows = [quantRow(10, 6), quantRow(10, 7), quantRow(10, 8)];
    const m = mergeQuantRows(rows);
    const f = filterQuantRows(m.keys, m.values, [0, 2]);
    expect(f.keys.packed.shape[0]).toBe(2);
    expectRowIdentical(f.keys, 0, 0, rows[0]!.keys);
    expectRowIdentical(f.keys, 1, 0, rows[2]!.keys);
    rows.forEach(disposeRow);
    disposeTriple(m.keys); disposeTriple(m.values);
    disposeTriple(f.keys); disposeTriple(f.values);
  });
});
