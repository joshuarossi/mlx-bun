import host.ts.Source
namespace Host.Ts.Sources.Mlx.HostBuffer
set_option maxRecDepth 100000

/-- Verbatim `packages/mlx/src/host-buffer.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { dlopen, ptr, read, type Pointer } from "bun:ffi";

// Page alignment permits Metal to use the restored allocation directly.
// The destructor is native free, so final release may occur on any thread.
const libc = dlopen("/usr/lib/libSystem.B.dylib", {
  posix_memalign: { args: ["ptr", "u64", "u64"], returns: "i32" },
  free: { args: ["ptr"], returns: "void" },
});
export const hostBufferDestructor = Number(Reflect.get(libc.symbols.free, "ptr"));

/** Unpublished CPU storage. A reader fills it before ownership moves to MLX. */
export class HostBuffer {
  #pointer: number;
  constructor(readonly bytes: number) {
    const slot = new BigUint64Array(1), address = ptr(slot);
    const status = libc.symbols.posix_memalign(address, 16384n, BigInt(Math.max(16384, Math.ceil(bytes / 16384) * 16384)));
    if (status) throw new Error(`KV restore allocation failed (${status})`);
    this.#pointer = Number(read.u64(address));
  }
  get pointer(): number { return this.#pointer; }
  transfer(): number { const p = this.#pointer; this.#pointer = 0; return p; }
  dispose(): void { if (this.#pointer) libc.symbols.free(this.transfer() as Pointer); }
  [Symbol.dispose](): void { this.dispose(); }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Mlx.HostBuffer
