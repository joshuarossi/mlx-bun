// Native autograd via mlx-c value_and_grad over a JS loss closure.
//
// Encapsulates the exact FFI lifecycle proven in spikes/phase-train-vag.ts:
//   JS loss closure (JSCallback) → mlx_closure_new_func_payload →
//   mlx_value_and_grad → mlx_closure_value_and_grad_apply → read grads.
//
// House rules honored:
// - Out-params read via bun:ffi `read.u64` (never slot[0] — DFG stale-read).
// - The JS closure NEVER throws across the FFI boundary (try/catch → return 1);
//   the captured error is re-thrown on the JS side after apply() fails.
// - All native handles (closure, value_and_grad closure, JSCallback) are held
//   alive on the instance and freed in dispose().

import { JSCallback, ptr, read } from "bun:ffi";
import { C } from "./ffi";
import { MlxArray } from "./array";

/** A reusable value-and-grad over a JS-built loss graph.
 *
 *  `loss(primals)` receives the input arrays in argument order and must
 *  return a single SCALAR MlxArray (the loss). The graph it builds is
 *  differentiated w.r.t. the inputs named in `argIdx`. `apply(primals)`
 *  returns the loss value and exactly `argIdx.length` gradients (one per
 *  differentiated input, in `argIdx` order).
 *
 *  The closure must not throw; if the user `loss` throws, the error is
 *  captured and surfaced from `apply()`. The MlxArrays handed to `loss`
 *  are owned by mlx — do NOT dispose them; the returned loss IS disposed
 *  of by mlx's graph. */
export class ValueAndGrad {
  readonly #cb: JSCallback;
  readonly #closure: bigint;
  readonly #vag: bigint;
  readonly #argIdx: Int32Array;
  #closureError: string | null = null;
  #disposed = false;

  constructor(loss: (primals: MlxArray[]) => MlxArray, argIdx: number[]) {
    if (argIdx.length === 0) throw new Error("ValueAndGrad: argIdx must be non-empty");
    this.#argIdx = new Int32Array(argIdx);

    this.#cb = new JSCallback(
      (outPtr: number, inVec: bigint, _payload: number): number => {
        try {
          // Read the primals out of the input vector_array. mlx_vector_array_get
          // returns a fresh (ref-counted) handle, so disposing the wrapper
          // afterward is correct — it drops our reference, not mlx's graph
          // reference (proven in spikes/phase-train-vag.ts).
          const n = Number(C.mlx_vector_array_size(inVec));
          const primals: MlxArray[] = [];
          for (let i = 0; i < n; i++) {
            const slot = new BigUint64Array([C.mlx_array_new()]);
            const sp = ptr(slot);
            if (C.mlx_vector_array_get(sp, inVec, BigInt(i)) !== 0)
              throw new Error(`vector_array_get(${i}) failed`);
            primals.push(new MlxArray(read.u64(sp, 0)));
          }
          const out = loss(primals);
          // Populate *out with the single scalar loss. set_data copies the
          // handle into the output vector (mlx retains its own reference), so
          // disposing the loss wrapper afterward drops only our reference.
          const handles = new BigUint64Array([out.handle]);
          if (C.mlx_vector_array_set_data(outPtr as never, ptr(handles), 1n) !== 0)
            throw new Error("vector_array_set_data failed");
          for (const p of primals) p.dispose();
          out.dispose();
          return 0;
        } catch (e) {
          this.#closureError = e instanceof Error ? e.message : String(e);
          return 1;
        }
      },
      { args: ["ptr", "u64", "ptr"], returns: "i32" },
    );

    this.#closure = C.mlx_closure_new_func_payload(this.#cb.ptr as never, null, null);

    const vagSlot = new BigUint64Array([C.mlx_closure_value_and_grad_new()]);
    if (C.mlx_value_and_grad(ptr(vagSlot), this.#closure, ptr(this.#argIdx), BigInt(this.#argIdx.length)) !== 0) {
      // best-effort cleanup before throwing
      C.mlx_closure_free(this.#closure);
      this.#cb.close();
      throw new Error("mlx_value_and_grad failed");
    }
    this.#vag = read.u64(ptr(vagSlot), 0);
  }

  /** Run the loss + backward on `primals` (in argument order). Returns the
   *  scalar loss and one gradient per differentiated input. Caller owns all
   *  returned arrays (dispose them). */
  apply(primals: MlxArray[]): { value: MlxArray; grads: MlxArray[] } {
    if (this.#disposed) throw new Error("ValueAndGrad used after dispose");
    this.#closureError = null;

    const handles = new BigUint64Array(primals.map((p) => p.handle));
    const inVec = C.mlx_vector_array_new_data(ptr(handles), BigInt(primals.length));

    const valueSlot = new BigUint64Array([C.mlx_vector_array_new()]);
    const gradsSlot = new BigUint64Array([C.mlx_vector_array_new()]);
    const st = C.mlx_closure_value_and_grad_apply(ptr(valueSlot), ptr(gradsSlot), this.#vag, inVec);
    const valueVec = read.u64(ptr(valueSlot), 0);
    const gradsVec = read.u64(ptr(gradsSlot), 0);
    if (st !== 0) {
      C.mlx_vector_array_free(valueVec);
      C.mlx_vector_array_free(gradsVec);
      C.mlx_vector_array_free(inVec);
      const detail = this.#closureError ? `: ${this.#closureError}` : "";
      throw new Error(`value_and_grad_apply failed${detail}`);
    }

    // value vector has exactly one entry (the scalar loss).
    const value = vecGet(valueVec, 0);

    const nGrads = Number(C.mlx_vector_array_size(gradsVec));
    if (nGrads !== this.#argIdx.length) {
      value.dispose();
      C.mlx_vector_array_free(valueVec);
      C.mlx_vector_array_free(gradsVec);
      C.mlx_vector_array_free(inVec);
      throw new Error(`expected ${this.#argIdx.length} grads, got ${nGrads}`);
    }
    const grads: MlxArray[] = [];
    for (let i = 0; i < nGrads; i++) grads.push(vecGet(gradsVec, i));

    C.mlx_vector_array_free(valueVec);
    C.mlx_vector_array_free(gradsVec);
    C.mlx_vector_array_free(inVec);
    return { value, grads };
  }

  dispose(): void {
    if (this.#disposed) return;
    this.#disposed = true;
    C.mlx_closure_value_and_grad_free(this.#vag);
    C.mlx_closure_free(this.#closure);
    this.#cb.close();
  }

  [Symbol.dispose](): void {
    this.dispose();
  }
}

/** Pull array `i` out of a vector_array into an owned MlxArray wrapper. */
function vecGet(vec: bigint, i: number): MlxArray {
  const slot = new BigUint64Array([C.mlx_array_new()]);
  const sp = ptr(slot);
  if (C.mlx_vector_array_get(sp, vec, BigInt(i)) !== 0)
    throw new Error(`vector_array_get(${i}) failed`);
  return new MlxArray(read.u64(sp, 0));
}
