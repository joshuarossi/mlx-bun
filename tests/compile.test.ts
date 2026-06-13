// mx.compile plumbing (Phase A of docs/design/optimization_plan.md): JSCallback-traced
// closure → mlx_compile → native replay, plus bit-exactness of the
// dynamic-start op variants the compiled decode graph substitutes for
// their baked-int forms.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import * as compile from "../src/mlx/compile";
import { Dtype } from "../src/mlx/ffi";

/** Deterministic pseudo-random floats (parity tests must not depend on
 *  Math.random). */
function fill(n: number, seed = 1234): Float32Array {
  const out = new Float32Array(n);
  let s = seed >>> 0;
  for (let i = 0; i < n; i++) {
    s = (s * 1664525 + 1013904223) >>> 0;
    out[i] = (s / 0xffffffff) * 2 - 1;
  }
  return out;
}

function bf16(data: Float32Array, shape: number[]): MlxArray {
  const f = MlxArray.fromFloat32(data, shape);
  const b = f.astype(Dtype.bfloat16);
  f.dispose();
  return b;
}

describe("CompiledFunction", () => {
  test("traces once, replays with new values", () => {
    const fn = new compile.CompiledFunction((inputs) => {
      const two = ops.scalarLike(2, inputs[0]!);
      const one = ops.scalarLike(1, inputs[0]!);
      const doubled = ops.mul(inputs[0]!, two);
      const out = ops.add(doubled, one);
      for (const a of [two, one, doubled]) a.dispose();
      return [out];
    });
    const before = compile.traceCalls;

    const x1 = MlxArray.fromFloat32(new Float32Array([1, 2, 3]), [3]);
    const [y1] = fn.apply([x1]);
    expect([...y1!.toFloat32()]).toEqual([3, 5, 7]);

    const x2 = MlxArray.fromFloat32(new Float32Array([5, 6, 7]), [3]);
    const [y2] = fn.apply([x2]);
    expect([...y2!.toFloat32()]).toEqual([11, 13, 15]);

    // shapeless: a different length must NOT retrace
    const x3 = MlxArray.fromFloat32(new Float32Array([1, 1, 1, 1, 1]), [5]);
    const [y3] = fn.apply([x3]);
    expect([...y3!.toFloat32()]).toEqual([3, 3, 3, 3, 3]);

    expect(compile.traceCalls - before).toBe(1);
    for (const a of [x1, y1!, x2, y2!, x3, y3!]) a.dispose();
    fn.dispose();
  });

  test("multiple inputs and outputs", () => {
    const fn = new compile.CompiledFunction(([a, b]) => {
      return [ops.add(a!, b!), ops.mul(a!, b!)];
    });
    const a = MlxArray.fromFloat32(new Float32Array([2, 3]), [2]);
    const b = MlxArray.fromFloat32(new Float32Array([10, 20]), [2]);
    const [sum, prod] = fn.apply([a, b]);
    expect([...sum!.toFloat32()]).toEqual([12, 23]);
    expect([...prod!.toFloat32()]).toEqual([20, 60]);
    for (const x of [a, b, sum!, prod!]) x.dispose();
    fn.dispose();
  });

  test("trace errors surface as JS exceptions", () => {
    const fn = new compile.CompiledFunction(() => {
      throw new Error("boom from trace");
    });
    const x = MlxArray.fromFloat32(new Float32Array([1]), [1]);
    expect(() => fn.apply([x])).toThrow("boom from trace");
    x.dispose();
    fn.dispose();
  });
});

describe("dynamic-start ops are bit-exact vs their static forms", () => {
  test("ropeDynamic(offset arr) == rope(offset int), bf16", () => {
    const x = bf16(fill(1 * 8 * 4 * 64), [1, 8, 4, 64]);
    const stat = ops.rope(x, 64, 10000, 37, null);
    const offArr = ops.fromInt32([37], []);
    const dyn = ops.ropeDynamic(x, 64, 10000, offArr, null);
    expect(Buffer.compare(stat.rawBytes(), dyn.rawBytes())).toBe(0);
    for (const a of [x, stat, offArr, dyn]) a.dispose();
  });

  test("sliceUpdateDynamic(start arr) == sliceUpdate(start ints), bf16", () => {
    const base = bf16(fill(1 * 2 * 8 * 4, 7), [1, 2, 8, 4]);
    const upd = bf16(fill(1 * 2 * 1 * 4, 99), [1, 2, 1, 4]);
    const stat = ops.sliceUpdate(base, upd, [0, 0, 5, 0], [1, 2, 6, 4]);
    const startArr = ops.fromInt32([5], [1]);
    const dyn = ops.sliceUpdateDynamic(base, upd, startArr, [2]);
    expect(Buffer.compare(stat.rawBytes(), dyn.rawBytes())).toBe(0);
    for (const a of [base, upd, stat, startArr, dyn]) a.dispose();
  });

  test("mini cache step (write+concat) compiled == uncompiled", () => {
    // The shape of the compiled decode step in miniature: a ring write at
    // a position carried as an array value, plus a concat fetch, both
    // inside one compiled graph, replayed at two different offsets.
    const step = (buf: MlxArray, k: MlxArray, pos: MlxArray) => {
      const updated = ops.sliceUpdateDynamic(buf, k, pos, [2]);
      const grown = ops.concatAxis([buf, k], 2);
      return [updated, grown];
    };
    const fn = new compile.CompiledFunction(([buf, k, pos]) => step(buf!, k!, pos!));

    for (const pos of [2, 6]) {
      const buf = bf16(fill(1 * 2 * 8 * 4, pos), [1, 2, 8, 4]);
      const k = bf16(fill(1 * 2 * 1 * 4, pos + 50), [1, 2, 1, 4]);
      const posArr = ops.fromInt32([pos], [1]);
      const [cu, cg] = fn.apply([buf, k, posArr]);
      const [uu, ug] = step(buf, k, posArr);
      expect(Buffer.compare(cu!.rawBytes(), uu!.rawBytes())).toBe(0);
      expect(Buffer.compare(cg!.rawBytes(), ug!.rawBytes())).toBe(0);
      for (const a of [buf, k, posArr, cu!, cg!, uu!, ug!]) a.dispose();
    }
    fn.dispose();
  });
});
