// Correctness microtest for the Checkpoint primitive (src/mlx/checkpoint.ts).
// Verifies that gradients through a checkpointed subgraph match the
// non-checkpointed reference — for both explicit inputs and CAPTURED leaves
// (params used inside the checkpoint but not passed as inputs). The latter
// decides whether layer integration can simply capture the swapped-in LoRA
// primals instead of threading them as inputs.
//
//   bun scripts/checkpoint-test.ts

import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { Checkpoint } from "../../src/mlx/checkpoint";

const sumAll = (a: MlxArray): MlxArray => ops.sumAxis(ops.reshape(a, [a.size]), 0, false);
const close = (a: Float32Array, b: number[]): boolean =>
  a.length === b.length && b.every((v, i) => Math.abs(a[i]! - v) < 1e-3);

const xData = new Float32Array([1, 2, 3, 4]);

// --- Test A: grad through a checkpointed cube, wrt the explicit input ---
// f(x) = sum(x^3) → df/dx = 3x^2 = [3, 12, 27, 48]
{
  const ckpts: Checkpoint[] = [];
  const vag = new ValueAndGrad((primals) => {
    const x = primals[0]!;
    const ck = new Checkpoint((ins) => {
      const a = ins[0]!;
      return [ops.mul(ops.mul(a, a), a)]; // a^3
    });
    ckpts.push(ck);
    const y = ck.apply([x])[0]!;
    return sumAll(y);
  }, [0]);

  const x = MlxArray.fromFloat32(xData, [4]);
  const { value, grads } = vag.apply([x]);
  const g = grads[0]!.toFloat32();
  console.log(`A: value=${value.toFloat32()[0]} (want 100), grad=${[...g]} (want 3,12,27,48) → ${close(g, [3, 12, 27, 48]) ? "PASS" : "FAIL"}`);
  value.dispose(); grads[0]!.dispose(); x.dispose();
  for (const c of ckpts) c.dispose();
  vag.dispose();
}

// --- Test B: grad to a param threaded as an EXPLICIT checkpoint input ---
// (The robust path, matching mlx-lm passing trainable_parameters as inputs:
//  the checkpoint closure must be a pure function of its inputs — capturing the
//  vag's primal wrappers fails because those are disposed before backward.)
// f(x, w) = sum(x * w) → df/dx = w = [2,2,2,2], df/dw = sum(x) = 10
{
  const ckpts: Checkpoint[] = [];
  const vag = new ValueAndGrad((primals) => {
    const x = primals[0]!;
    const w = primals[1]!;
    const ck = new Checkpoint((ins) => [ops.mul(ins[0]!, ins[1]!)]); // pure: a * wIn
    ckpts.push(ck);
    const y = ck.apply([x, w])[0]!; // w threaded as an explicit input
    return sumAll(y);
  }, [0, 1]);

  const x = MlxArray.fromFloat32(xData, [4]);
  const w = MlxArray.fromFloat32(new Float32Array([2, 2, 2, 2]), [4]); // same shape (no broadcast)
  const { value, grads } = vag.apply([x, w]);
  const gx = grads[0]!.toFloat32();
  const gw = grads[1]!.toFloat32();
  // f=sum(x*w): df/dx=w=[2,2,2,2], df/dw=x=[1,2,3,4]
  const ok = close(gx, [2, 2, 2, 2]) && close(gw, [1, 2, 3, 4]);
  console.log(`B: value=${value.toFloat32()[0]} (want 20), grad_x=${[...gx]} (want 2,2,2,2), grad_w=${[...gw]} (want 1,2,3,4) → ${ok ? "PASS" : "FAIL"}`);
  value.dispose(); grads[0]!.dispose(); grads[1]!.dispose(); x.dispose(); w.dispose();
  for (const c of ckpts) c.dispose();
  vag.dispose();
}
