// Gradient checkpointing (rematerialization) via mlx-c mlx_checkpoint.
//
// Wraps a JS function (MlxArray[]) -> MlxArray[] into a closure whose forward
// activations are dropped and RECOMPUTED during the enclosing value_and_grad
// backward. Used to bound training memory on long sequences: instead of
// retaining every transformer layer's activations, each checkpointed unit is
// recomputed one at a time in the backward pass.
//
// Same FFI lifecycle as ValueAndGrad (src/mlx/autograd.ts): a JSCallback over
// the user fn → mlx_closure_new_func_payload → mlx_checkpoint → applied with
// mlx_closure_apply. The closure must not throw across the FFI boundary; a JS
// throw is captured and re-surfaced from apply().

import { JSCallback, ptr, read } from "bun:ffi";
import { C, takeMlxError } from "./ffi";
import { MlxArray } from "./array";

type CallbackHandle = Pick<JSCallback, "ptr" | "close">;
type NativeCall<F extends (...args: any[]) => any> =
  (...args: Parameters<F>) => ReturnType<F>;

/** Constructor-only dependency seam for deterministic native failure tests. */
export interface CheckpointConstructorHooks {
  callback?: (
    callback: ConstructorParameters<typeof JSCallback>[0],
    definition: ConstructorParameters<typeof JSCallback>[1],
  ) => CallbackHandle;
  closureNew?: NativeCall<typeof C.mlx_closure_new_func_payload>;
  transformedNew?: NativeCall<typeof C.mlx_closure_new>;
  transform?: NativeCall<typeof C.mlx_checkpoint>;
  closureFree?: NativeCall<typeof C.mlx_closure_free>;
}

/** A reusable checkpointed wrapper over a JS-built subgraph.
 *
 *  `fn(inputs)` receives the input arrays (in order) and returns one or more
 *  output arrays. Applying the checkpoint builds the same forward graph, but
 *  marks it for recomputation: the enclosing backward recomputes `fn` rather
 *  than reading retained activations. Gradients flow to the explicit inputs
 *  AND to any outer-trace leaves captured by `fn` (e.g. swapped-in LoRA
 *  primals), exactly as if `fn` had been inlined. */
export class Checkpoint {
  readonly #cb: CallbackHandle;
  readonly #closure: bigint;
  readonly #ckpt: bigint;
  readonly #freeClosure: NativeCall<typeof C.mlx_closure_free>;
  #closureError: string | null = null;
  #disposed = false;

  constructor(
    fn: (inputs: MlxArray[]) => MlxArray[],
    hooks: CheckpointConstructorHooks = {},
  ) {
    const makeCallback = hooks.callback ?? ((callback, definition) => new JSCallback(callback, definition));
    const closureNew = hooks.closureNew ?? C.mlx_closure_new_func_payload;
    const transformedNew = hooks.transformedNew ?? C.mlx_closure_new;
    const transform = hooks.transform ?? C.mlx_checkpoint;
    this.#freeClosure = hooks.closureFree ?? C.mlx_closure_free;

    const cb = makeCallback(
      (outPtr: number, inVec: bigint, _payload: number): number => {
        try {
          const n = Number(C.mlx_vector_array_size(inVec));
          const inputs: MlxArray[] = [];
          for (let i = 0; i < n; i++) {
            const slot = new BigUint64Array([C.mlx_array_new()]);
            const sp = ptr(slot);
            if (C.mlx_vector_array_get(sp, inVec, BigInt(i)) !== 0)
              throw new Error(`vector_array_get(${i}) failed`);
            inputs.push(new MlxArray(read.u64(sp, 0)));
          }
          const outs = fn(inputs);
          const handles = new BigUint64Array(outs.map((o) => o.handle));
          if (C.mlx_vector_array_set_data(outPtr as never, ptr(handles), BigInt(outs.length)) !== 0)
            throw new Error("vector_array_set_data failed");
          for (const p of inputs) p.dispose();
          for (const o of outs) o.dispose();
          return 0;
        } catch (e) {
          this.#closureError = e instanceof Error ? e.message : String(e);
          return 1;
        }
      },
      { args: ["ptr", "u64", "ptr"], returns: "i32" },
    );

    let closure: bigint | null = null;
    let slot: BigUint64Array | null = null;
    try {
      closure = closureNew(cb.ptr as never, null, null);
      slot = new BigUint64Array([transformedNew()]);
      if (transform(ptr(slot), closure) !== 0)
        throw new Error(`mlx_checkpoint failed: ${takeMlxError() ?? ""}`);
      this.#cb = cb;
      this.#closure = closure;
      this.#ckpt = read.u64(ptr(slot), 0);
    } catch (e) {
      if (slot) this.#freeClosure(read.u64(ptr(slot), 0));
      if (closure !== null) this.#freeClosure(closure);
      cb.close();
      throw e;
    }
  }

  /** Apply the checkpointed fn. Returns its outputs as owned MlxArrays. */
  apply(inputs: MlxArray[]): MlxArray[] {
    if (this.#disposed) throw new Error("Checkpoint used after dispose");
    this.#closureError = null;

    const handles = new BigUint64Array(inputs.map((p) => p.handle));
    const inVec = C.mlx_vector_array_new_data(ptr(handles), BigInt(inputs.length));
    const outSlot = new BigUint64Array([C.mlx_vector_array_new()]);
    const st = C.mlx_closure_apply(ptr(outSlot), this.#ckpt, inVec);
    const outVec = read.u64(ptr(outSlot), 0);
    if (st !== 0) {
      C.mlx_vector_array_free(outVec);
      C.mlx_vector_array_free(inVec);
      const detail = this.#closureError ?? takeMlxError() ?? "";
      throw new Error(`checkpoint apply failed${detail ? `: ${detail}` : ""}`);
    }
    const nOut = Number(C.mlx_vector_array_size(outVec));
    const outs: MlxArray[] = [];
    for (let i = 0; i < nOut; i++) {
      const slot = new BigUint64Array([C.mlx_array_new()]);
      const sp = ptr(slot);
      if (C.mlx_vector_array_get(sp, outVec, BigInt(i)) !== 0) {
        C.mlx_vector_array_free(outVec);
        C.mlx_vector_array_free(inVec);
        throw new Error(`checkpoint output get(${i}) failed`);
      }
      outs.push(new MlxArray(read.u64(sp, 0)));
    }
    C.mlx_vector_array_free(outVec);
    C.mlx_vector_array_free(inVec);
    return outs;
  }

  dispose(): void {
    if (this.#disposed) return;
    this.#disposed = true;
    this.#freeClosure(this.#ckpt);
    this.#freeClosure(this.#closure);
    this.#cb.close();
  }

  [Symbol.dispose](): void {
    this.dispose();
  }
}
