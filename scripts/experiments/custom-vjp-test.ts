// Correctness microtest for the CustomVjp primitive (src/mlx/custom-vjp.ts).
// Forward is x^2 (whose AUTO grad would be 2x); we attach a deliberately-WRONG
// vjp of 3x. If custom_vjp works, value_and_grad returns the custom 3x — not
// the auto 2x — proving the hand-written backward overrides. This is the
// mechanism the L2 flash-attention op needs (Metal forward + manual backward).
//
//   bun scripts/custom-vjp-test.ts

import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { CustomVjp } from "../../src/mlx/custom-vjp";

const sumAll = (a: MlxArray): MlxArray => ops.sumAxis(ops.reshape(a, [a.size]), 0, false);
const close = (a: Float32Array, b: number[]): boolean =>
  a.length === b.length && b.every((v, i) => Math.abs(a[i]! - v) < 1e-3);

const x = MlxArray.fromFloat32(new Float32Array([1, 2, 3, 4]), [4]);
const cvs: CustomVjp[] = [];
const vag = new ValueAndGrad((primals) => {
  const xi = primals[0]!;
  const cv = new CustomVjp(
    (ins) => [ops.mul(ins[0]!, ins[0]!)], // forward: x^2
    // deliberately WRONG vjp: 3x·cot (true grad of x^2 would be 2x·cot)
    (prim, cots) => [ops.mul(ops.mulScalar(prim[0]!, 3), cots[0]!)],
  );
  cvs.push(cv);
  const y = cv.apply([xi])[0]!;
  return sumAll(y);
}, [0]);

const { value, grads } = vag.apply([x]);
const g = grads[0]!.toFloat32();
const ok = close(g, [3, 6, 9, 12]); // custom 3x, NOT auto 2x
console.log(`value=${value.toFloat32()[0]} (want 30), grad=${[...g]} (want custom 3,6,9,12; auto would be 2,4,6,8) → ${ok ? "PASS" : "FAIL"}`);
console.log(`   → custom_vjp ${ok ? "OVERRIDES the auto grad — flash-attn manual backward can be attached" : "did NOT override"}`);

value.dispose();
grads[0]!.dispose();
x.dispose();
for (const c of cvs) c.dispose();
vag.dispose();
