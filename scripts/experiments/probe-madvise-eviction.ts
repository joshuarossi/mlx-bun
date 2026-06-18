// E1 mechanism probe: eviction WITHIN a single mmap'd expert tensor.
//
// E1 wants to mmap the stacked [E, ...] expert weight once and keep only the
// hot experts resident, dropping cold ones with madvise. Two questions:
//   [A] CORRECTNESS — if cold experts' pages are madvise(DONTNEED)'d out and
//       only the SELECTED experts are faulted in, does GPU gather_qmm still
//       return the bit-exact result? (i.e. is gather row-local, and can the
//       GPU read a partially-resident mapping?)
//   [B] RECLAIM — does madvise actually return page RAM to the OS on macOS,
//       and with which advice (DONTNEED vs FREE_REUSABLE)?
//
// Run: bun scripts/probe-madvise-eviction.ts

import { Dtype, synchronize } from "../../src/mlx/ffi";
import { MlxArray, gpuStream, cpuStream } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { MmapFile, MADV_DONTNEED, MADV_FREE_REUSABLE } from "../../src/mmap";
import { writeFileSync, unlinkSync, openSync, writeSync, closeSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const PAGE = 16384;
const MB = 1024 * 1024;
const GB = 1024 * MB;
const alignUp = (n: number, a: number) => Math.ceil(n / a) * a;
const alignDn = (n: number, a: number) => Math.floor(n / a) * a;
const g = (b: number) => (b / GB).toFixed(3).padStart(7);
const rss = () => process.memoryUsage().rss;

function bytesOf(a: MlxArray): Uint8Array {
  a.eval();
  const C = require("../../src/mlx/ffi").C;
  const { toArrayBuffer } = require("bun:ffi");
  const fn: Record<string, any> = {
    float32: C.mlx_array_data_float32, float16: C.mlx_array_data_float16,
    bfloat16: C.mlx_array_data_bfloat16, uint32: C.mlx_array_data_uint32,
  };
  return new Uint8Array(toArrayBuffer(fn[a.dtypeName](a.handle), 0, a.nbytes)).slice();
}
function rand(n: number, seed: number): Float32Array {
  const out = new Float32Array(n); let s = seed >>> 0;
  for (let i = 0; i < n; i++) { s = (s * 1664525 + 1013904223) >>> 0; out[i] = (s / 2 ** 32) * 2 - 1; }
  return out;
}

console.log(`\n=== madvise eviction probe (pid ${process.pid}) ===\n`);

// ── [A] gather bit-exact with cold experts madvise'd out ─────────────────
console.log("[A] drop cold experts via madvise, keep selected resident, GPU gather");
{
  const E = 64, OUT = 512, IN = 512, GROUP = 32, bits = 4;
  const spec: ops.QuantSpec = { bits, groupSize: GROUP, mode: "affine" };
  const wFull = MlxArray.fromFloat32(rand(E * OUT * IN, 7), [E, OUT, IN]);
  const q = ops.quantize(wFull, GROUP, bits);           // packed [E, OUT, IN*bits/32] uint32
  const packedBytes = bytesOf(q.packed);
  const expertStride = packedBytes.length / E;          // bytes per expert row-block
  console.log(`    ${E} experts, ${(expertStride / 1024).toFixed(0)} KB each (${(expertStride / PAGE).toFixed(1)} pages)`);

  // file: packed at a non-zero page-aligned offset
  const base = PAGE;
  const total = alignUp(base + packedBytes.length, PAGE);
  const buf = Buffer.alloc(total);
  Buffer.from(packedBytes).copy(buf, base);
  const tmp = join(tmpdir(), `mlxbun-madv-${process.pid}.bin`);
  writeFileSync(tmp, buf);

  const mm = MmapFile.open(tmp, "ro");
  const mPacked = MlxArray.fromView(mm.view(base, packedBytes.length), q.packed.shape, q.packed.dtype);

  // 2 tokens, selecting experts {7,40} and {13,55}; scales/biases stay resident
  const sel = [7, 40, 13, 55];
  const x = MlxArray.fromFloat32(rand(2 * IN, 11), [1, 2, IN]);
  const indices = ops.fromInt32([7, 40, 13, 55], [1, 2, 2]).astype(Dtype.uint32);
  let h = ops.expandDims(x, -2); h = ops.expandDims(h, -3);

  const ref = ops.gatherQmm(h, q.packed, q.scales, q.biases, indices, spec, false).eval().toFloat32();

  // drop ALL packed pages, then fault in ONLY the selected experts
  mm.advise(base, alignDn(packedBytes.length, PAGE), MADV_DONTNEED);
  let touched = 0;
  const view = mm.view(base, packedBytes.length);
  for (const e of sel) {
    const lo = alignDn(e * expertStride, PAGE), hi = alignUp((e + 1) * expertStride, PAGE);
    for (let p = lo; p < hi && p < view.length; p += PAGE) touched ^= view[p]!; // fault the page
  }
  console.log(`    madvise(DONTNEED) all packed; faulted selected experts {${sel}} (chk ${touched & 1})`);

  // GPU gather reading the partially-resident mapping
  process.stderr.write("    running GPU gather over partially-resident mmap...\n");
  const got = ops.gatherQmm(h, mPacked, q.scales, q.biases, indices, spec, false).eval().toFloat32();

  let maxDiff = 0, nan = false;
  for (let i = 0; i < ref.length; i++) { if (Number.isNaN(got[i]!)) nan = true; maxDiff = Math.max(maxDiff, Math.abs(ref[i]! - got[i]!)); }
  console.log(`    NaN: ${nan}   max|resident - evicted| = ${maxDiff}`);
  console.log(`    => ${maxDiff === 0 && !nan ? "BIT-EXACT — gather is row-local; cold experts can be evicted ✓" : "MISMATCH — gather needs non-selected pages ✗ (use subset-tensor design)"}`);

  for (const a of [wFull, q.packed, q.scales, q.biases, x, indices, h, mPacked]) a.dispose();
  synchronize(gpuStream); mm.unmap();
  try { unlinkSync(tmp); } catch {}
}

// ── [B] does madvise reclaim RAM to the OS on macOS? ─────────────────────
console.log("\n[B] madvise RAM reclaim: map 1 GB, fault in, DONTNEED vs FREE_REUSABLE");
{
  const bytes = 1 * GB;
  const tmp = join(tmpdir(), `mlxbun-madv-big-${process.pid}.bin`);
  const chunk = Buffer.alloc(64 * MB);
  for (let i = 0; i < chunk.length; i += 4) chunk.writeFloatLE((i % 991) / 991, i);
  const fd = openSync(tmp, "w");
  for (let w = 0; w < bytes; w += chunk.length) writeSync(fd, chunk);
  closeSync(fd);

  const mm = MmapFile.open(tmp, "ro");
  const view = mm.view(0, bytes);
  let acc = 0;
  for (let p = 0; p < bytes; p += PAGE) acc ^= view[p]!; // fault every page in
  const r1 = rss();
  mm.advise(0, bytes, MADV_DONTNEED);
  const r2 = rss();
  mm.advise(0, bytes, MADV_FREE_REUSABLE);
  const r3 = rss();
  console.log(`    after fault-in        rss ${g(r1)} GB (chk ${acc & 1})`);
  console.log(`    after MADV_DONTNEED    rss ${g(r2)} GB  (${g(r2 - r1)})`);
  console.log(`    after FREE_REUSABLE    rss ${g(r3)} GB  (${g(r3 - r1)} total)`);
  const dropped = r1 - Math.min(r2, r3);
  console.log(`    => ${dropped > 0.5 * GB ? `RECLAIM WORKS via ${r2 < r1 - 0.5 * GB ? "MADV_DONTNEED" : "MADV_FREE_REUSABLE"} ✓` : "madvise did NOT reclaim — fall back to munmap ✗"}`);
  mm.unmap();
  try { unlinkSync(tmp); } catch {}
}
console.log("");
