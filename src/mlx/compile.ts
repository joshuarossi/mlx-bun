// mx.compile from Bun: wrap a JS graph-builder in an mlx_closure, hand it
// to mlx_compile, and replay the compiled graph in C++ thereafter.
//
// The trace function runs EXACTLY ONCE per (ndim, dtype) input signature
// (shapeless=true): mlx invokes our JSCallback with tracer arrays during
// the first mlx_closure_apply, we build the graph with the ordinary ops
// layer, and every later apply replays it natively — zero per-op FFI.
//
// Contract for trace functions:
// - receive positional MlxArray inputs, return positional MlxArray outputs
// - must NOT dispose the inputs (the trampoline owns them) and must NOT
//   eval anything (tracer arrays have no data — eval inside a trace is an
//   mlx error by design)
// - arrays created inside the trace (weights, scalarLike constants) are
//   captured as graph constants — correct for weights, which never change
// - with shapeless=true the graph must stay valid as dim SIZES change
//   (ndim/dtype changes retrace automatically): no reshape/slice constants
//   derived from a varying dimension

import { JSCallback, ptr, read } from "bun:ffi";
import { C, type MlxHandle, takeMlxError } from "./ffi";
import { MlxArray } from "./array";

export type TraceFn = (inputs: MlxArray[]) => MlxArray[];

const traceRegistry = new Map<number, { fn: TraceFn; count: number }>();
let nextTraceId = 1;
/** Error thrown by a trace fn, carried across the C boundary (the
 *  trampoline must not throw into mlx; it returns non-zero instead). */
let traceError: unknown = null;

/** Count of trace invocations, exposed for tests (a working shapeless
 *  compile traces once and replays thereafter). */
export let traceCalls = 0;

// int (*fun)(mlx_vector_array* res, const mlx_vector_array args, void* payload)
// mlx_vector_array is the usual one-pointer struct, by value → u64.
// Tracing happens synchronously inside mlx_closure_apply on the calling
// thread, so a non-threadsafe JSCallback is safe (same argument as the
// error handler in ffi.ts).
const trampoline = new JSCallback(
  (resPtr: number, argsVec: bigint, payload: number): number => {
    try {
      const entry = traceRegistry.get(payload);
      if (!entry) throw new Error(`compile trampoline: unknown trace id ${payload}`);
      const fn = entry.fn;
      entry.count++;
      traceCalls++;
      const n = Number(C.mlx_vector_array_size(argsVec));
      const inputs: MlxArray[] = [];
      const slot = new BigUint64Array(1);
      const slotPtr = ptr(slot);
      for (let i = 0; i < n; i++) {
        slot[0] = C.mlx_array_new();
        if (C.mlx_vector_array_get(slotPtr, argsVec, BigInt(i)) !== 0)
          throw new Error(`vector_array_get(${i}) failed: ${takeMlxError() ?? ""}`);
        inputs.push(new MlxArray(read.u64(slotPtr, 0)));
      }
      const outputs = fn(inputs);
      const handles = new BigUint64Array(outputs.map((o) => o.handle));
      if (C.mlx_vector_array_set_data(resPtr, ptr(handles), BigInt(outputs.length)) !== 0)
        throw new Error(`vector_array_set_data failed: ${takeMlxError() ?? ""}`);
      for (const o of outputs) o.dispose();
      for (const a of inputs) a.dispose();
      return 0;
    } catch (e) {
      traceError = e;
      return 1;
    }
  },
  { args: ["ptr", "u64", "ptr"], returns: "i32" },
);

/** MLX_COMPILE_MODE_* (compile.h). NO_FUSE keeps the host-side replay win
 *  while disabling kernel fusion — the escape hatch if fusion ever breaks
 *  the bit-exact gate. */
export function setCompileMode(mode: "disabled" | "no_simplify" | "no_fuse" | "enabled"): void {
  const v = { disabled: 0, no_simplify: 1, no_fuse: 2, enabled: 3 }[mode];
  if (C.mlx_set_compile_mode(v) !== 0)
    throw new Error(`mlx_set_compile_mode failed: ${takeMlxError() ?? ""}`);
}

export class CompiledFunction {
  #compiled: MlxHandle;
  #traceId: number;
  #disposed = false;

  /** Times this function's trace ran. A shapeless decode closure must
   *  trace exactly once — its input ndims/dtypes never change — so any
   *  count > 1 is a silent retrace (per-step JS graph builds sneaking
   *  back in) and gets flagged by compiled-decode. */
  get traceCount(): number {
    return traceRegistry.get(this.#traceId)?.count ?? 0;
  }

  constructor(fn: TraceFn, shapeless = true) {
    this.#traceId = nextTraceId++;
    traceRegistry.set(this.#traceId, { fn, count: 0 });
    // payload is the trace id smuggled through the void* (never deref'd);
    // dtor is null — nothing to free on the C side.
    const raw = C.mlx_closure_new_func_payload(trampoline.ptr, this.#traceId as never, null);
    const slot = new BigUint64Array([C.mlx_closure_new()]);
    const slotPtr = ptr(slot);
    const status = C.mlx_compile(slotPtr, raw, shapeless);
    const compiled = read.u64(slotPtr, 0);
    C.mlx_closure_free(raw);
    if (status !== 0) {
      C.mlx_closure_free(compiled);
      traceRegistry.delete(this.#traceId);
      throw new Error(`mlx_compile failed: ${takeMlxError() ?? ""}`);
    }
    this.#compiled = compiled;
  }

  /** Run the compiled graph. First call (per ndim/dtype signature) traces
   *  through the JS fn; later calls replay natively. Returned arrays are
   *  owned by the caller. */
  apply(inputs: MlxArray[]): MlxArray[] {
    if (this.#disposed) throw new Error("CompiledFunction used after dispose");
    const handles = new BigUint64Array(inputs.length);
    for (let i = 0; i < inputs.length; i++) handles[i] = inputs[i]!.handle;
    const inVec = C.mlx_vector_array_new_data(ptr(handles), BigInt(inputs.length));
    const slot = new BigUint64Array([C.mlx_vector_array_new()]);
    const slotPtr = ptr(slot);
    const status = C.mlx_closure_apply(slotPtr, this.#compiled, inVec);
    const outVec = read.u64(slotPtr, 0);
    C.mlx_vector_array_free(inVec);
    if (status !== 0) {
      C.mlx_vector_array_free(outVec);
      const e = traceError;
      traceError = null;
      throw e instanceof Error
        ? e
        : new Error(`compiled apply failed: ${takeMlxError() ?? "(no mlx message)"}`);
    }
    const n = Number(C.mlx_vector_array_size(outVec));
    const outputs: MlxArray[] = [];
    const aSlot = new BigUint64Array(1);
    const aPtr = ptr(aSlot);
    for (let i = 0; i < n; i++) {
      aSlot[0] = C.mlx_array_new();
      if (C.mlx_vector_array_get(aPtr, outVec, BigInt(i)) !== 0) {
        C.mlx_vector_array_free(outVec);
        throw new Error(`vector_array_get(out ${i}) failed: ${takeMlxError() ?? ""}`);
      }
      outputs.push(new MlxArray(read.u64(aPtr, 0)));
    }
    C.mlx_vector_array_free(outVec);
    return outputs;
  }

  dispose(): void {
    if (this.#disposed) return;
    this.#disposed = true;
    C.mlx_closure_free(this.#compiled);
    traceRegistry.delete(this.#traceId);
  }
}
