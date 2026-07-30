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

type CallbackHandle = Pick<JSCallback, "ptr" | "close">;
type NativeCall<F extends (...args: any[]) => any> =
  (...args: Parameters<F>) => ReturnType<F>;

/** Constructor-only dependency seam for deterministic native failure tests. */
export interface CustomVjpConstructorHooks {
  callback?: (
    callback: ConstructorParameters<typeof JSCallback>[0],
    definition: ConstructorParameters<typeof JSCallback>[1],
  ) => CallbackHandle;
  forwardClosureNew?: NativeCall<typeof C.mlx_closure_new_func_payload>;
  vjpClosureNew?: NativeCall<typeof C.mlx_closure_custom_new_func_payload>;
  transformedNew?: NativeCall<typeof C.mlx_closure_new>;
  transform?: NativeCall<typeof C.mlx_custom_vjp>;
  closureFree?: NativeCall<typeof C.mlx_closure_free>;
  customClosureFree?: NativeCall<typeof C.mlx_closure_custom_free>;
}

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
  readonly #fwdCb: CallbackHandle;
  readonly #vjpCb: CallbackHandle;
  readonly #fwdClosure: bigint;
  readonly #vjpClosure: bigint;
  readonly #combined: bigint;
  readonly #freeClosure: NativeCall<typeof C.mlx_closure_free>;
  readonly #freeCustomClosure: NativeCall<typeof C.mlx_closure_custom_free>;
  #error: string | null = null;
  #disposed = false;

  constructor(
    fwd: (inputs: MlxArray[]) => MlxArray[],
    vjp: (primals: MlxArray[], cotangents: MlxArray[], outputs: MlxArray[]) => MlxArray[],
    hooks: CustomVjpConstructorHooks = {},
  ) {
    const makeCallback = hooks.callback ?? ((callback, definition) => new JSCallback(callback, definition));
    const forwardClosureNew = hooks.forwardClosureNew ?? C.mlx_closure_new_func_payload;
    const vjpClosureNew = hooks.vjpClosureNew ?? C.mlx_closure_custom_new_func_payload;
    const transformedNew = hooks.transformedNew ?? C.mlx_closure_new;
    const transform = hooks.transform ?? C.mlx_custom_vjp;
    this.#freeClosure = hooks.closureFree ?? C.mlx_closure_free;
    this.#freeCustomClosure = hooks.customClosureFree ?? C.mlx_closure_custom_free;

    const fwdCb = makeCallback(
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

    let vjpCb: CallbackHandle;
    try {
      vjpCb = makeCallback(
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
    } catch (e) {
      // Callback construction is itself fallible. The native-closure guard
      // below starts only after both callbacks exist, so this partial state
      // must release the already-created forward callback here.
      fwdCb.close();
      throw e;
    }

    let fwdClosure: bigint | null = null;
    let vjpClosure: bigint | null = null;
    let slot: BigUint64Array | null = null;
    try {
      fwdClosure = forwardClosureNew(fwdCb.ptr as never, null, null);
      vjpClosure = vjpClosureNew(vjpCb.ptr as never, null, null);
      slot = new BigUint64Array([transformedNew()]);
      if (transform(ptr(slot), fwdClosure, vjpClosure) !== 0)
        throw new Error(`mlx_custom_vjp failed: ${takeMlxError() ?? ""}`);
      this.#fwdCb = fwdCb;
      this.#vjpCb = vjpCb;
      this.#fwdClosure = fwdClosure;
      this.#vjpClosure = vjpClosure;
      this.#combined = read.u64(ptr(slot), 0);
    } catch (e) {
      if (slot) this.#freeClosure(read.u64(ptr(slot), 0));
      if (fwdClosure !== null) this.#freeClosure(fwdClosure);
      if (vjpClosure !== null) this.#freeCustomClosure(vjpClosure);
      fwdCb.close();
      vjpCb.close();
      throw e;
    }
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
    this.#freeClosure(this.#combined);
    this.#freeClosure(this.#fwdClosure);
    this.#freeCustomClosure(this.#vjpClosure);
    this.#fwdCb.close();
    this.#vjpCb.close();
  }

  [Symbol.dispose](): void {
    this.dispose();
  }
}
