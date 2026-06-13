// mx.fast.metal_kernel from Bun (docs/design/optimization_plan.md Phase E): the
// intended MLX extension point for custom Metal kernels — no fork. The
// kernel body is Metal Shading Language; mlx generates the signature
// from input/output names (inputs by name, outputs by name, plus
// `*_shape`/`*_strides`/`*_ndim` helpers when referenced). Dispatched
// like any lazy op: apply() builds graph nodes, eval runs the kernel.

import { ptr, read } from "bun:ffi";
import { C, Dtype, type MlxHandle, takeMlxError } from "./ffi";
import { MlxArray, gpuStream } from "./array";

function vectorString(strings: string[]): { vec: MlxHandle; keepAlive: Buffer[] } {
  const bufs = strings.map((s) => Buffer.from(s + "\0", "utf8"));
  const ptrs = new BigUint64Array(bufs.map((b) => BigInt(ptr(b))));
  const vec = C.mlx_vector_string_new_data(ptr(ptrs), BigInt(bufs.length));
  return { vec, keepAlive: bufs };
}

export interface MetalKernelSpec {
  name: string;
  inputNames: string[];
  outputNames: string[];
  /** Kernel BODY (not a full function) in MSL. */
  source: string;
  /** Optional includes/defines prepended outside the kernel. */
  header?: string;
  ensureRowContiguous?: boolean;
  atomicOutputs?: boolean;
}

export interface MetalKernelCall {
  outputs: { shape: number[]; dtype: Dtype }[];
  grid: [number, number, number];
  threadGroup: [number, number, number];
  templateInts?: Record<string, number>;
  templateDtypes?: Record<string, Dtype>;
  initValue?: number;
  stream?: MlxHandle;
}

export class MetalKernel {
  #kernel: MlxHandle;
  #disposed = false;

  constructor(spec: MetalKernelSpec) {
    const inNames = vectorString(spec.inputNames);
    const outNames = vectorString(spec.outputNames);
    const name = Buffer.from(spec.name + "\0", "utf8");
    const source = Buffer.from(spec.source + "\0", "utf8");
    const header = Buffer.from((spec.header ?? "") + "\0", "utf8");
    this.#kernel = C.mlx_fast_metal_kernel_new(
      ptr(name), inNames.vec, outNames.vec, ptr(source), ptr(header),
      spec.ensureRowContiguous ?? true, spec.atomicOutputs ?? false,
    );
    C.mlx_vector_string_free(inNames.vec);
    C.mlx_vector_string_free(outNames.vec);
  }

  apply(inputs: MlxArray[], call: MetalKernelCall): MlxArray[] {
    if (this.#disposed) throw new Error("MetalKernel used after dispose");
    const cfg = C.mlx_fast_metal_kernel_config_new();
    try {
      for (const o of call.outputs) {
        const shape = new Int32Array(o.shape);
        if (C.mlx_fast_metal_kernel_config_add_output_arg(cfg, ptr(shape), BigInt(o.shape.length), o.dtype) !== 0)
          throw new Error(`metal_kernel add_output_arg failed: ${takeMlxError() ?? ""}`);
      }
      C.mlx_fast_metal_kernel_config_set_grid(cfg, call.grid[0], call.grid[1], call.grid[2]);
      C.mlx_fast_metal_kernel_config_set_thread_group(cfg, call.threadGroup[0], call.threadGroup[1], call.threadGroup[2]);
      if (call.initValue !== undefined)
        C.mlx_fast_metal_kernel_config_set_init_value(cfg, call.initValue);
      for (const [k, v] of Object.entries(call.templateInts ?? {})) {
        const kb = Buffer.from(k + "\0", "utf8");
        C.mlx_fast_metal_kernel_config_add_template_arg_int(cfg, ptr(kb), v);
      }
      for (const [k, v] of Object.entries(call.templateDtypes ?? {})) {
        const kb = Buffer.from(k + "\0", "utf8");
        C.mlx_fast_metal_kernel_config_add_template_arg_dtype(cfg, ptr(kb), v);
      }

      const handles = new BigUint64Array(inputs.map((a) => a.handle));
      const inVec = C.mlx_vector_array_new_data(ptr(handles), BigInt(inputs.length));
      const slot = new BigUint64Array([C.mlx_vector_array_new()]);
      const slotPtr = ptr(slot);
      const status = C.mlx_fast_metal_kernel_apply(slotPtr, this.#kernel, inVec, cfg, call.stream ?? gpuStream);
      const outVec = read.u64(slotPtr, 0);
      C.mlx_vector_array_free(inVec);
      if (status !== 0) {
        C.mlx_vector_array_free(outVec);
        throw new Error(`metal_kernel apply failed: ${takeMlxError() ?? "(no message)"}`);
      }
      const n = Number(C.mlx_vector_array_size(outVec));
      const outs: MlxArray[] = [];
      const aSlot = new BigUint64Array(1);
      const aPtr = ptr(aSlot);
      for (let i = 0; i < n; i++) {
        aSlot[0] = C.mlx_array_new();
        if (C.mlx_vector_array_get(aPtr, outVec, BigInt(i)) !== 0) {
          C.mlx_vector_array_free(outVec);
          throw new Error(`metal_kernel output get(${i}) failed: ${takeMlxError() ?? ""}`);
        }
        outs.push(new MlxArray(read.u64(aPtr, 0)));
      }
      C.mlx_vector_array_free(outVec);
      return outs;
    } finally {
      C.mlx_fast_metal_kernel_config_free(cfg);
    }
  }

  dispose(): void {
    if (this.#disposed) return;
    this.#disposed = true;
    C.mlx_fast_metal_kernel_free(this.#kernel);
  }
}

/** mlx_metal_start/stop_capture — wrap a single decode step to inspect
 *  its command buffer in Xcode (Phase E step 2: size the prize). Needs
 *  MTL_CAPTURE_ENABLED=1 in the environment. */
export function metalCapture(path: string, fn: () => void): void {
  const p = Buffer.from(path + "\0", "utf8");
  if (C.mlx_metal_start_capture(ptr(p)) !== 0)
    throw new Error(`metal_start_capture failed: ${takeMlxError() ?? ""}`);
  try {
    fn();
  } finally {
    C.mlx_metal_stop_capture();
  }
}
