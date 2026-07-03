// Phase-train feasibility spike (GATE for src/train/*).
//
// Proves the full native-autograd FFI path before any trainer code exists:
//   JS loss closure (JSCallback)  →  mlx_value_and_grad  →  grads for A/B
// against a finite-difference oracle. If this is RED, native LoRA training
// via mlx-c is not viable as designed and the plan must change.
//
// Graph (LoRA-shaped): loss = mean( (x + (x@A)@B − y)^2 ), scalar.
//   A [8,2] and B [2,8] are the differentiation leaves (argnums [0,1]);
//   x [4,8], y [4,8] are frozen inputs. Both A and B are seeded NONZERO so
//   dL/dA and dL/dB are each nontrivial (a real check, not dA≡0).
//
// House rules honored: out-params read via bun:ffi read.u64 (never slot[0],
// DFG stale-read bug); the closure NEVER throws across the FFI boundary
// (try/catch → return 1).

import { dlopen, FFIType, JSCallback, ptr, read } from "bun:ffi";
import { C } from "../src/mlx/ffi";
import { MlxArray, gpuStream } from "../src/mlx/array";
import { add, sub, mul, matmul, reshape, sumAxis, mulScalar } from "../src/mlx/ops";

const { ptr: P, i32, u64 } = FFIType;

// Symbols not yet in src/mlx/ffi.ts (bound here to keep the spike self-contained).
const A = dlopen("/opt/homebrew/lib/libmlxc.dylib", {
  mlx_value_and_grad: { args: [P, u64, P, u64], returns: i32 },
  mlx_closure_value_and_grad_new: { args: [], returns: u64 },
  mlx_closure_value_and_grad_apply: { args: [P, P, u64, u64], returns: i32 },
  mlx_closure_value_and_grad_free: { args: [u64], returns: i32 },
}).symbols;

// --- the differentiable graph (shared by the eager oracle and the closure) --
// Disposes its own intermediates; returns the scalar loss. Inputs are owned
// by the caller (eager path) or by the autograd input vector (closure path).
function buildLossGraph(a: MlxArray, b: MlxArray, x: MlxArray, y: MlxArray): MlxArray {
  const xa = matmul(x, a);     // [4,2]
  const xab = matmul(xa, b);   // [4,8]
  const pred = add(x, xab);    // [4,8]  (the LoRA residual shape)
  const resid = sub(pred, y);  // [4,8]
  const sq = mul(resid, resid);
  const flat = reshape(sq, [N]);
  const s = sumAxis(flat, 0, false); // scalar []
  const loss = mulScalar(s, 1 / N);
  for (const t of [xa, xab, pred, resid, sq, flat, s]) t.dispose();
  return loss;
}

const ROWS = 4, IN = 8, RANK = 2, OUT = 8;
const N = ROWS * OUT;

// Deterministic nonzero seed data.
const det = (n: number, f: (i: number) => number) =>
  new Float32Array(Array.from({ length: n }, (_, i) => f(i)));
const xData = det(ROWS * IN, (i) => Math.sin(i * 0.7) * 0.5);
const yData = det(ROWS * OUT, (i) => Math.cos(i * 0.4) * 0.3);
const aData = det(IN * RANK, (i) => ((i * 7 + 3) % 11) / 11 - 0.5);
const bData = det(RANK * OUT, (i) => ((i * 5 + 1) % 9) / 9 - 0.4);

const xConst = MlxArray.fromFloat32(xData, [ROWS, IN]);
const yConst = MlxArray.fromFloat32(yData, [ROWS, OUT]);

/** Eager (no-autograd) loss for finite differencing. */
function computeLoss(a: Float32Array, b: Float32Array): number {
  const aArr = MlxArray.fromFloat32(a, [IN, RANK]);
  const bArr = MlxArray.fromFloat32(b, [RANK, OUT]);
  const loss = buildLossGraph(aArr, bArr, xConst, yConst);
  const v = loss.toFloat32()[0]!;
  for (const t of [aArr, bArr, loss]) t.dispose();
  return v;
}

// --- the JS loss closure (the keystone) ------------------------------------
let closureError: string | null = null;
const lossCallback = new JSCallback(
  (outPtr: number, inVec: bigint, _payload: number): number => {
    try {
      const get = (i: number): MlxArray => {
        const slot = new BigUint64Array([C.mlx_array_new()]);
        const sp = ptr(slot);
        if (C.mlx_vector_array_get(sp, inVec, BigInt(i)) !== 0)
          throw new Error(`vector_array_get(${i}) failed`);
        return new MlxArray(read.u64(sp, 0));
      };
      const a = get(0), b = get(1), x = get(2), y = get(3);
      const loss = buildLossGraph(a, b, x, y);
      // populate *out with [loss]
      const handles = new BigUint64Array([loss.handle]);
      if (C.mlx_vector_array_set_data(outPtr as never, ptr(handles), 1n) !== 0)
        throw new Error("vector_array_set_data failed");
      for (const t of [a, b, x, y, loss]) t.dispose();
      return 0;
    } catch (e) {
      closureError = e instanceof Error ? e.message : String(e);
      return 1; // never throw across the FFI boundary
    }
  },
  { args: ["ptr", "u64", "ptr"], returns: "i32" },
);

function analyticGrads(): { dA: Float32Array; dB: Float32Array } {
  const closure = C.mlx_closure_new_func_payload(lossCallback.ptr as never, null, null);

  const vagSlot = new BigUint64Array([A.mlx_closure_value_and_grad_new()]);
  const argnums = new Int32Array([0, 1]); // differentiate A and B
  if (A.mlx_value_and_grad(ptr(vagSlot), closure, ptr(argnums), 2n) !== 0)
    throw new Error("mlx_value_and_grad failed");
  const vag = read.u64(ptr(vagSlot), 0);

  const aArr = MlxArray.fromFloat32(aData, [IN, RANK]);
  const bArr = MlxArray.fromFloat32(bData, [RANK, OUT]);
  const primals = new BigUint64Array([aArr.handle, bArr.handle, xConst.handle, yConst.handle]);
  const inVec = C.mlx_vector_array_new_data(ptr(primals), 4n);

  const valueSlot = new BigUint64Array([C.mlx_vector_array_new()]);
  const gradsSlot = new BigUint64Array([C.mlx_vector_array_new()]);
  const st = A.mlx_closure_value_and_grad_apply(ptr(valueSlot), ptr(gradsSlot), vag, inVec);
  if (st !== 0) throw new Error(`value_and_grad_apply failed${closureError ? `: ${closureError}` : ""}`);
  const gradsVec = read.u64(ptr(gradsSlot), 0);

  const nGrads = Number(C.mlx_vector_array_size(gradsVec));
  if (nGrads !== 2) throw new Error(`expected exactly 2 grads (frozen base), got ${nGrads}`);

  const grad = (i: number): Float32Array => {
    const slot = new BigUint64Array([C.mlx_array_new()]);
    C.mlx_vector_array_get(ptr(slot), gradsVec, BigInt(i));
    const arr = new MlxArray(read.u64(ptr(slot), 0));
    const out = arr.toFloat32();
    arr.dispose();
    return out;
  };
  const dA = grad(0), dB = grad(1);

  C.mlx_vector_array_free(read.u64(ptr(valueSlot), 0));
  C.mlx_vector_array_free(gradsVec);
  C.mlx_vector_array_free(inVec);
  A.mlx_closure_value_and_grad_free(vag);
  C.mlx_closure_free(closure);
  aArr.dispose(); bArr.dispose();
  return { dA, dB };
}

// --- run + finite-difference check -----------------------------------------
const { dA, dB } = analyticGrads();

const EPS = 1e-3, TOL = 1e-2;
let fails = 0, checks = 0;

function checkGrad(name: string, base: Float32Array, analytic: Float32Array, shape: [number, number]) {
  const [r, c] = shape;
  // sample a spread of coordinates
  const coords = [0, 1, 3, r * c - 1, Math.floor(r * c / 2)].filter((i, k, a) => i < r * c && a.indexOf(i) === k);
  for (const idx of coords) {
    const plus = base.slice(); plus[idx]! += EPS;
    const minus = base.slice(); minus[idx]! -= EPS;
    const fd = name === "A"
      ? (computeLoss(plus, bData) - computeLoss(minus, bData)) / (2 * EPS)
      : (computeLoss(aData, plus) - computeLoss(aData, minus)) / (2 * EPS);
    const an = analytic[idx]!;
    const rel = Math.abs(an - fd) / (Math.abs(an) + 1e-4);
    checks++;
    const ok = rel < TOL;
    if (!ok) fails++;
    console.log(
      `  d${name}[${idx}]: analytic=${an.toFixed(6)} finite-diff=${fd.toFixed(6)} rel=${rel.toExponential(2)} ${ok ? "ok" : "FAIL"}`,
    );
  }
}

console.log("value_and_grad finite-difference check (LoRA-shaped loss):");
checkGrad("A", aData, dA, [IN, RANK]);
checkGrad("B", bData, dB, [RANK, OUT]);

for (const t of [xConst, yConst]) t.dispose();
lossCallback.close();

if (fails > 0) {
  console.error(`\nFAIL: ${fails}/${checks} grad coordinates outside tolerance ${TOL}`);
  process.exit(1);
}
console.log(`\nPASS: ${checks}/${checks} grads match finite-difference (<${TOL}); exactly 2 grads returned (base frozen).`);
console.log("Native mlx-c autograd via a JSCallback closure works → src/train is GO.");
