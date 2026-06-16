// Custom vjp via mlx-c mlx_custom_vjp: attach a hand-written backward to a
// forward whose primitives have no usable vjp (a fused mx.fast.metal_kernel
// is a CustomKernel with no gradient). This is the mechanism the L2 flash-
// attention training op uses — the forward is a Metal kernel, the backward is
// three more Metal kernels, wired together here so the enclosing
// value_and_grad differentiates through them.
//
// Same FFI lifecycle as ValueAndGrad/Checkpoint: a JSCallback per closure →
// mlx_closure_new_func_payload (forward) + mlx_closure_custom_new_func_payload
// (vjp) → mlx_custom_vjp → applied with mlx_closure_apply. Closures must not
// throw across the FFI boundary; a JS throw is captured and surfaced from
// apply().

import { JSCallback, ptr, read } from "bun:ffi";
import { C, takeMlxError } from "./ffi";
import { MlxArray } from "./array";

function readVec(vec: bigint): MlxArray[] {
  const n = Number(C.mlx_vector_array_size(vec));
  const out: MlxArray[] = [];
  for (let i = 0; i < n; i++) {
    const slot = new BigUint64Array([C.mlx_array_new()]);
    const sp = ptr(slot);
    if (C.mlx_vector_array_get(sp, vec, BigInt(i)) !== 0)
      throw new Error(`vector_array_get(${i}) failed`);
    out.push(new MlxArray(read.u64(sp, 0)));
  }
  return out;
}

function setVec(outPtr: number, arrays: MlxArray[]): void {
  const handles = new BigUint64Array(arrays.map((a) => a.handle));
  if (C.mlx_vector_array_set_data(outPtr as never, ptr(handles), BigInt(arrays.length)) !== 0)
    throw new Error("vector_array_set_data failed");
}

/** A reusable forward op with a hand-written backward.
 *
 *  `fwd(inputs)` returns the forward outputs. `vjp(primals, cotangents,
 *  outputs)` returns one gradient per primal (in primal order). Both must be
 *  pure functions of their arguments — the vjp re-reads everything from the
 *  graph during the enclosing backward. */
export class CustomVjp {
  readonly #fwdCb: JSCallback;
  readonly #vjpCb: JSCallback;
  readonly #fwdClosure: bigint;
  readonly #vjpClosure: bigint;
  readonly #combined: bigint;
  #error: string | null = null;
  #disposed = false;

  constructor(
    fwd: (inputs: MlxArray[]) => MlxArray[],
    vjp: (primals: MlxArray[], cotangents: MlxArray[], outputs: MlxArray[]) => MlxArray[],
  ) {
    this.#fwdCb = new JSCallback(
      (outPtr: number, inVec: bigint, _payload: number): number => {
        try {
          const inputs = readVec(inVec);
          const outs = fwd(inputs);
          setVec(outPtr, outs);
          for (const p of inputs) p.dispose();
          for (const o of outs) o.dispose();
          return 0;
        } catch (e) {
          this.#error = e instanceof Error ? e.message : String(e);
          return 1;
        }
      },
      { args: ["ptr", "u64", "ptr"], returns: "i32" },
    );

    this.#vjpCb = new JSCallback(
      (resPtr: number, primalsVec: bigint, cotsVec: bigint, outsVec: bigint, _payload: number): number => {
        try {
          const primals = readVec(primalsVec);
          const cots = readVec(cotsVec);
          const outs = readVec(outsVec);
          const grads = vjp(primals, cots, outs);
          setVec(resPtr, grads);
          for (const a of [...primals, ...cots, ...outs]) a.dispose();
          for (const g of grads) g.dispose();
          return 0;
        } catch (e) {
          this.#error = e instanceof Error ? e.message : String(e);
          return 1;
        }
      },
      { args: ["ptr", "u64", "u64", "u64", "ptr"], returns: "i32" },
    );

    this.#fwdClosure = C.mlx_closure_new_func_payload(this.#fwdCb.ptr as never, null, null);
    this.#vjpClosure = C.mlx_closure_custom_new_func_payload(this.#vjpCb.ptr as never, null, null);

    const slot = new BigUint64Array([C.mlx_closure_new()]);
    if (C.mlx_custom_vjp(ptr(slot), this.#fwdClosure, this.#vjpClosure) !== 0) {
      C.mlx_closure_free(this.#fwdClosure);
      C.mlx_closure_custom_free(this.#vjpClosure);
      this.#fwdCb.close();
      this.#vjpCb.close();
      throw new Error(`mlx_custom_vjp failed: ${takeMlxError() ?? ""}`);
    }
    this.#combined = read.u64(ptr(slot), 0);
  }

  apply(inputs: MlxArray[]): MlxArray[] {
    if (this.#disposed) throw new Error("CustomVjp used after dispose");
    this.#error = null;

    const handles = new BigUint64Array(inputs.map((p) => p.handle));
    const inVec = C.mlx_vector_array_new_data(ptr(handles), BigInt(inputs.length));
    const outSlot = new BigUint64Array([C.mlx_vector_array_new()]);
    const st = C.mlx_closure_apply(ptr(outSlot), this.#combined, inVec);
    const outVec = read.u64(ptr(outSlot), 0);
    if (st !== 0) {
      C.mlx_vector_array_free(outVec);
      C.mlx_vector_array_free(inVec);
      const detail = this.#error ?? takeMlxError() ?? "";
      throw new Error(`custom_vjp apply failed${detail ? `: ${detail}` : ""}`);
    }
    const outs = readVec(outVec);
    C.mlx_vector_array_free(outVec);
    C.mlx_vector_array_free(inVec);
    return outs;
  }

  dispose(): void {
    if (this.#disposed) return;
    this.#disposed = true;
    C.mlx_closure_free(this.#combined);
    C.mlx_closure_free(this.#fwdClosure);
    C.mlx_closure_custom_free(this.#vjpClosure);
    this.#fwdCb.close();
    this.#vjpCb.close();
  }

  [Symbol.dispose](): void {
    this.dispose();
  }
}
