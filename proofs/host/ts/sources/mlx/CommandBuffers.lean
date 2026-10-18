import host.ts.Source
namespace Host.Ts.Sources.Mlx.CommandBuffers
set_option maxRecDepth 100000

/-- Verbatim `packages/mlx/src/command-buffers.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// MLX's command-buffer limits on the GPU architectures where other values were measured.
//
// MLX 0.32.2 commits a command buffer once it holds more than MLX_MAX_OPS_PER_BUFFER operations or binds more than
// MLX_MAX_MB_PER_BUFFER Mi elements of distinct buffers, and an evaluation waits while more than ten committed buffers
// are in flight. It reads both variables once, when it builds its Metal device (`Device::Device` in
// mlx/backend/metal/device.cpp, defaults by architecture suffix: 50/50 on `s`), which happens at the first array or
// device query, never at library load. The binding therefore sets them before it loads MLX, from the architecture Metal
// reports for the device MLX will use (MLX_METAL_GPU_ARCH first, as MLX resolves it). Bun's `process.env`
// assignment does not reach the native environment, so this calls libc `setenv`; it never overwrites a variable the
// environment already holds, so a user's value wins, one variable at a time.

import { CString, dlopen, FFIType, type Pointer } from "bun:ffi";

/** The two limits MLX reads for a command buffer. */
export interface CommandBufferLimits {
  /** Operations a command buffer holds before MLX commits it (`MLX_MAX_OPS_PER_BUFFER`). */
  readonly maxOps: number;
  /** Mi elements of distinct buffers a command buffer binds before MLX commits it (`MLX_MAX_MB_PER_BUFFER`). */
  readonly maxMb: number;
}

/** Limits by the architecture name Metal reports; every other architecture keeps MLX's own table. */
export const COMMAND_BUFFER_LIMITS: Readonly<Record<string, CommandBufferLimits>> = Object.freeze({
  // M1 Max: with MLX's 50/50 a 27B model's decode forward commits a buffer every layer or two of weights; raising
  // either limit alone gains nothing. Measured on Qwen3.8 27B Trellis (in-process serve, greedy, two sessions each,
  // identical tokens), 400/100 decodes 19.5 tok/s plain and 25.8 with DFlash 2 adaptive against 19.2 and 25.2 at
  // 50/50, prompts of 300-2048 positions as fast and bit-identical. The element limit stays low because a
  // synchronous evaluation commits nothing until it binds that many elements, so the GPU idles while MLX encodes it:
  // the Neural Engine prompt split waits for each layer's buffer fills, and 150 (decode 19.7 and 25.9) slows prompts
  // of 300 positions by 2.5% (1024 and 2048 level).
  applegpu_g13s: Object.freeze({ maxOps: 400, maxMb: 100 }),
});

/** The variables that give `architecture` its limits; empty where MLX's own table stands. */
export function commandBufferEnvironment(architecture: string): Readonly<Record<string, string>> {
  const limits = COMMAND_BUFFER_LIMITS[architecture];
  return limits ? { MLX_MAX_OPS_PER_BUFFER: String(limits.maxOps), MLX_MAX_MB_PER_BUFFER: String(limits.maxMb) } : {};
}

const cstring = (text: string) => Buffer.from(`${text}\0`, "utf8");

/** Set this machine's limits in the native environment, leaving each variable it already holds. Call before MLX
 *  builds its device: the binding does, before loading MLX. */
export function applyCommandBufferLimits(): void {
  const libc = dlopen("/usr/lib/libSystem.B.dylib", {
    getenv: { args: [FFIType.ptr], returns: FFIType.ptr },
    setenv: { args: [FFIType.ptr, FFIType.ptr, FFIType.i32], returns: FFIType.i32 },
  }).symbols;
  const override = libc.getenv(cstring("MLX_METAL_GPU_ARCH"));
  const architecture = override ? new CString(override).toString() : metalArchitecture();
  for (const [name, value] of Object.entries(commandBufferEnvironment(architecture)))
    if (libc.setenv(cstring(name), cstring(value), 0) !== 0) throw new Error(`setenv ${name} failed`);
}

/** The architecture name of the system's Metal device (MLX's device on Apple Silicon), without loading MLX; empty
 *  without a Metal device, where MLX fails on its own. */
function metalArchitecture(): string {
  const objc = dlopen("/usr/lib/libobjc.A.dylib", {
    sel_registerName: { args: [FFIType.ptr], returns: FFIType.ptr },
    objc_msgSend: { args: [FFIType.ptr, FFIType.ptr], returns: FFIType.ptr },
  }).symbols;
  const metal = dlopen("/System/Library/Frameworks/Metal.framework/Metal", {
    MTLCreateSystemDefaultDevice: { args: [], returns: FFIType.ptr },
  }).symbols;
  const send = (receiver: Pointer | null, selector: string) =>
    receiver && objc.objc_msgSend(receiver, objc.sel_registerName(cstring(selector)));
  const device = metal.MTLCreateSystemDefaultDevice();
  if (!device) return "";
  try {
    // Getters return objects the device owns; copy the name before releasing the device.
    const name = send(send(send(device, "architecture"), "name"), "UTF8String");
    return name ? new CString(name).toString() : "";
  } finally { send(device, "release"); }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Mlx.CommandBuffers
