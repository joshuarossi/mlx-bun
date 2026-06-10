// libc mmap via bun:ffi.
//
// Bun.mmap panics (SIGTRAP, Bun 1.3.3) on files larger than 4 GB because
// JSC ArrayBuffers cap at 2^32 bytes — and weight shards routinely exceed
// that. We don't need a whole-file ArrayBuffer anyway: tensors go to mlx
// as raw pointers (base + offset), and only small ranges (headers) are
// ever viewed from JS.

import { dlopen, FFIType, toArrayBuffer } from "bun:ffi";
import { closeSync, fstatSync, openSync } from "node:fs";

const libc = dlopen("/usr/lib/libSystem.B.dylib", {
  mmap: {
    args: [FFIType.u64, FFIType.u64, FFIType.i32, FFIType.i32, FFIType.i32, FFIType.i64],
    returns: FFIType.u64,
  },
  munmap: { args: [FFIType.u64, FFIType.u64], returns: FFIType.i32 },
  madvise: { args: [FFIType.u64, FFIType.u64, FFIType.i32], returns: FFIType.i32 },
}).symbols;

const PROT_READ = 0x1;
const PROT_WRITE = 0x2;
const MAP_SHARED = 0x1;
const MAP_PRIVATE = 0x2;
const MAP_FAILED = 0xffffffffffffffffn;

export class MmapFile {
  readonly path: string;
  readonly base: bigint;
  readonly size: number;
  #mapped = true;

  private constructor(path: string, base: bigint, size: number) {
    this.path = path;
    this.base = base;
    this.size = size;
  }

  /** Open read-only (MAP_SHARED) or copy-on-write (MAP_PRIVATE +
   *  PROT_WRITE — writes go to private pages, never the file; used for
   *  KV-cache reloads where mlx may donate buffers). */
  static open(path: string, mode: "ro" | "cow" = "ro"): MmapFile {
    const fd = openSync(path, "r");
    try {
      const size = fstatSync(fd).size;
      if (size === 0) throw new Error(`${path}: empty file`);
      const prot = mode === "cow" ? PROT_READ | PROT_WRITE : PROT_READ;
      const flags = mode === "cow" ? MAP_PRIVATE : MAP_SHARED;
      const base = libc.mmap(0n, BigInt(size), prot, flags, fd, 0n);
      if (base === MAP_FAILED) throw new Error(`${path}: mmap failed`);
      return new MmapFile(path, base, size);
    } finally {
      closeSync(fd); // mapping survives close
    }
  }

  /** Raw pointer to byte `offset` (for FFI consumers like mlx). */
  pointer(offset: number): number {
    if (offset < 0 || offset > this.size) throw new RangeError(`offset ${offset} out of range`);
    return Number(this.base + BigInt(offset));
  }

  /** JS view of a range. Only for small ranges (headers, spot checks);
   *  the view aliases the mapping — do not retain past munmap. */
  view(offset: number, length: number): Uint8Array {
    if (offset + length > this.size) throw new RangeError("view out of range");
    if (length >= 2 ** 32) throw new RangeError("JS views cap at 4 GB");
    return new Uint8Array(toArrayBuffer(this.pointer(offset) as never, 0, length));
  }

  unmap(): void {
    if (!this.#mapped) return;
    this.#mapped = false;
    libc.munmap(this.base, BigInt(this.size));
  }
}
