// Confirming probe for the expert-offload mmap path (no model, no server).
//
// Two questions, end to end:
//   [1] CORRECTNESS — can the GPU run gather_qmm reading a quantized expert's
//       weights DIRECTLY from a page-aligned mmap (vs the Phase-1 "GPU reads
//       garbage from unaligned wrapped pointers" hazard)? Assert bit-exact
//       against the identical weights held resident.
//   [2] EVICTION — does munmap of a large mapped region return its RAM to the
//       OS (rss), confirming the elastic clean-page path at scale?
//
// Run: bun scripts/probe-mmap-gather.ts

import { C, Dtype, clearCache, synchronize } from "../src/mlx/ffi";
import { MlxArray, gpuStream, cpuStream } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { MmapFile } from "../src/mmap";
import { toArrayBuffer } from "bun:ffi";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { writeFileSync, unlinkSync } from "node:fs";

const PAGE = 16384; // Apple Silicon page size
const MB = 1024 * 1024;
const GB = 1024 * MB;
const alignUp = (n: number, a: number) => Math.ceil(n / a) * a;
const g = (b: number) => (b / GB).toFixed(3).padStart(7);
const rss = () => process.memoryUsage().rss;

function bytesOf(a: MlxArray): Uint8Array {
  a.eval();
  const fn: Record<string, (h: bigint) => number | null> = {
    float32: C.mlx_array_data_float32, float16: C.mlx_array_data_float16,
    bfloat16: C.mlx_array_data_bfloat16, uint32: C.mlx_array_data_uint32,
  };
  const f = fn[a.dtypeName];
  if (!f) throw new Error(`bytesOf: unsupported dtype ${a.dtypeName}`);
  const p = f(a.handle);
  return new Uint8Array(toArrayBuffer(p as never, 0, a.nbytes)).slice();
}

function rand(n: number, seed: number): Float32Array {
  const out = new Float32Array(n);
  let s = seed >>> 0;
  for (let i = 0; i < n; i++) { s = (s * 1664525 + 1013904223) >>> 0; out[i] = (s / 2 ** 32) * 2 - 1; }
  return out;
}

console.log(`\n=== mmap gather_qmm probe (pid ${process.pid}) ===\n`);

// ── [1] correctness: GPU gather over page-aligned mmap == resident ───────
console.log("[1] GPU gather_qmm over a page-aligned mmap'd quantized expert");
{
  const E = 4, OUT = 64, IN = 128, GROUP = 32, bits = 4;
  const spec: ops.QuantSpec = { bits, groupSize: GROUP, mode: "affine" };
  const wFull = MlxArray.fromFloat32(rand(E * OUT * IN, 7), [E, OUT, IN]);
  const q = ops.quantize(wFull, GROUP, bits); // { packed(uint32), scales, biases }

  // Lay packed/scales/biases into a file, each at a 16 KB-aligned, NON-zero
  // offset (start one page in, so we test realistic offsets, not just base).
  const tensors = [q.packed, q.scales, q.biases];
  const offs: number[] = [];
  let cur = PAGE;
  for (const t of tensors) { offs.push(cur); cur = alignUp(cur + t.nbytes, PAGE); }
  const buf = Buffer.alloc(cur);
  tensors.forEach((t, i) => Buffer.from(bytesOf(t)).copy(buf, offs[i]!));
  const tmp = join(tmpdir(), `mlxbun-gather-probe-${process.pid}.bin`);
  writeFileSync(tmp, buf);

  const mm = MmapFile.open(tmp, "ro");
  const wrap = (t: MlxArray, off: number) =>
    MlxArray.fromView(mm.view(off, t.nbytes), t.shape, t.dtype);
  const mPacked = wrap(q.packed, offs[0]!);
  const mScales = wrap(q.scales, offs[1]!);
  const mBiases = wrap(q.biases, offs[2]!);

  // x [1,2,IN] -> [1,2,1,1,IN] like SwitchGLU; indices [1,2,2] uint32
  const x = MlxArray.fromFloat32(rand(2 * IN, 11), [1, 2, IN]);
  const indices = ops.fromInt32([2, 0, 1, 3], [1, 2, 2]).astype(Dtype.uint32);
  let h = ops.expandDims(x, -2); h = ops.expandDims(h, -3);

  // both on the GPU stream — the path that "reads garbage" if unaligned
  const resident = ops.gatherQmm(h, q.packed, q.scales, q.biases, indices, spec, false).eval();
  const mmapped = ops.gatherQmm(h, mPacked, mScales, mBiases, indices, spec, false).eval();
  const a = resident.toFloat32(), b = mmapped.toFloat32();
  let maxDiff = 0, anyNaN = false;
  for (let i = 0; i < a.length; i++) {
    if (Number.isNaN(b[i]!)) anyNaN = true;
    maxDiff = Math.max(maxDiff, Math.abs(a[i]! - b[i]!));
  }
  console.log(`    output shape ${JSON.stringify(mmapped.shape)}, ${a.length} values`);
  console.log(`    packed at file offset ${offs[0]} (16KB-aligned: ${offs[0]! % PAGE === 0})`);
  console.log(`    NaN in mmap output: ${anyNaN}`);
  console.log(`    max |resident - mmap| = ${maxDiff}`);
  console.log(`    => ${maxDiff === 0 && !anyNaN ? "BIT-EXACT — GPU reads aligned mmap correctly ✓" : "MISMATCH — alignment/read hazard ✗"}`);

  for (const t of [wFull, q.packed, q.scales, q.biases, x, indices, h, resident, mmapped, mPacked, mScales, mBiases]) t.dispose();
  synchronize(gpuStream);
  mm.unmap();
  try { unlinkSync(tmp); } catch {}
}

// ── [2] eviction at scale: munmap returns mapped RAM to the OS ────────────
console.log("\n[2] mmap ~1 GB, fault in, evict via munmap (rss is valid for file pages)");
{
  const bytes = 1 * GB;
  const tmp = join(tmpdir(), `mlxbun-evict-probe-${process.pid}.bin`);
  // write in 64 MB chunks to avoid a 1 GB host buffer
  const chunk = Buffer.alloc(64 * MB);
  for (let i = 0; i < chunk.length; i += 4) chunk.writeFloatLE((i % 991) / 991, i);
  const fd = require("node:fs").openSync(tmp, "w");
  for (let w = 0; w < bytes; w += chunk.length) require("node:fs").writeSync(fd, chunk);
  require("node:fs").closeSync(fd);

  const r0 = rss();
  const mm = MmapFile.open(tmp, "ro");
  const arr = MlxArray.fromView(mm.view(0, bytes), [bytes / 4], Dtype.float32);
  const touched = ops.add(arr, arr, cpuStream).eval(); // fault every page in from disk
  synchronize(cpuStream);
  const r1 = rss();
  touched.dispose(); arr.dispose();
  synchronize(gpuStream); synchronize(cpuStream);
  mm.unmap(); clearCache();
  const r2 = rss();
  console.log(`    baseline rss            ${g(r0)} GB`);
  console.log(`    after mmap + fault-in   ${g(r1)} GB   (+${g(r1 - r0)})`);
  console.log(`    after munmap            ${g(r2)} GB   (${g(r2 - r1)})`);
  console.log(`    => ${r2 - r0 < 0.2 * GB ? "RAM returned to OS ✓" : "RAM stuck ✗"}  (watch Activity Monitor too)`);
  try { unlinkSync(tmp); } catch {}
}

console.log("");
