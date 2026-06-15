// E1's make-or-break measurement, done cheaply (no full model):
// when the GPU runs gather_qmm reading a mmap'd expert weight, does Metal WIRE
// those pages (→ they count against phys_footprint = memory pressure), or read
// them as reclaimable file cache (→ phys_footprint stays ~0)?
//
// phys_footprint (via vmmap) is the metric macOS uses for pressure / shows in
// Activity Monitor. Clean read-only file pages don't count (probe-footprint.ts);
// the question is whether GPU access changes that.
//
// Run: bun scripts/probe-metal-wire.ts

import { Dtype, clearCache, synchronize, C } from "../src/mlx/ffi";
import { MlxArray, gpuStream } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { MmapFile } from "../src/mmap";
import { toArrayBuffer } from "bun:ffi";
import { writeFileSync, unlinkSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const PAGE = 16384, MB = 1024 * 1024;
const alignUp = (n: number, a: number) => Math.ceil(n / a) * a;

function footprintMB(): number {
  const out = Bun.spawnSync(["vmmap", "--summary", String(process.pid)]).stdout.toString();
  const m = out.match(/Physical footprint:\s+([\d.]+)([KMG])/);
  if (!m) return NaN;
  const v = parseFloat(m[1]!), u = m[2]!;
  return u === "G" ? v * 1024 : u === "M" ? v : v / 1024;
}
const show = (l: string) => { const f = footprintMB(); console.log(`    ${l.padEnd(34)} phys_footprint ${f.toFixed(1)} MB`); return f; };
function bytesOf(a: MlxArray): Uint8Array {
  a.eval();
  const fn: Record<string, any> = { uint32: C.mlx_array_data_uint32 };
  return new Uint8Array(toArrayBuffer(fn[a.dtypeName](a.handle), 0, a.nbytes)).slice();
}
function rand(n: number, seed: number): Float32Array {
  const o = new Float32Array(n); let s = seed >>> 0;
  for (let i = 0; i < n; i++) { s = (s * 1664525 + 1013904223) >>> 0; o[i] = (s / 2 ** 32) * 2 - 1; }
  return o;
}

console.log(`\n=== Metal-wire probe (pid ${process.pid}) ===\n`);
const E = 16, OUT = 2048, IN = 8192, GROUP = 32, bits = 4;
const spec: ops.QuantSpec = { bits, groupSize: GROUP, mode: "affine" };

show("baseline");
const wFull = MlxArray.fromFloat32(rand(E * OUT * IN, 7), [E, OUT, IN]);
const q = ops.quantize(wFull, GROUP, bits);
const packedBytes = bytesOf(q.packed);
console.log(`    packed ${(packedBytes.length / MB).toFixed(0)} MB ([${q.packed.shape}]), ${(packedBytes.length / E / MB).toFixed(1)} MB/expert`);
wFull.dispose();

// write packed to a page-aligned file; keep scales/biases resident, drop the
// device-side packed so ONLY the mmap copy remains.
const base = PAGE;
const buf = Buffer.alloc(alignUp(base + packedBytes.length, PAGE));
Buffer.from(packedBytes).copy(buf, base);
const tmp = join(tmpdir(), `mlxbun-wire-${process.pid}.bin`);
writeFileSync(tmp, buf);
const packedShape = q.packed.shape, packedDtype = q.packed.dtype;
q.packed.dispose();
clearCache();
show("quantized, packed→file, device-packed freed");

const mm = MmapFile.open(tmp, "ro");
const view = mm.view(base, packedBytes.length);
let acc = 0;
for (let p = 0; p < view.length; p += PAGE) acc ^= view[p]!; // CPU fault all pages
const afterFault = show(`mmap + CPU fault-in (chk ${acc & 1})`);
const mPacked = MlxArray.fromView(view, packedShape, packedDtype);

const x = MlxArray.fromFloat32(rand(2 * IN, 11), [1, 2, IN]);
const indices = ops.fromInt32([1, 5, 9, 13], [1, 2, 2]).astype(Dtype.uint32);
let h = ops.expandDims(x, -2); h = ops.expandDims(h, -3);

// GPU gather over the mmap'd packed weight — the measurement
for (let i = 0; i < 3; i++) {
  const out = ops.gatherQmm(h, mPacked, q.scales, q.biases, indices, spec, false).eval();
  synchronize(gpuStream);
  out.dispose();
}
const afterGather = show("after 3× GPU gather over mmap");
clearCache();
const afterClear = show("after clearCache");

console.log(`\n    GPU access added ${(afterGather - afterFault).toFixed(1)} MB to phys_footprint (packed is ${(packedBytes.length / MB).toFixed(0)} MB)`);
const wired = afterGather - afterFault > packedBytes.length / MB * 0.5;
console.log(`    => ${wired ? "Metal WIRES mmap pages on GPU access ✗ (working set counts as pressure)" : "Metal reads mmap as reclaimable cache ✓ (pool stays out of pressure)"}`);

for (const a of [q.scales, q.biases, x, indices, h, mPacked]) a.dispose();
synchronize(gpuStream); mm.unmap();
try { unlinkSync(tmp); } catch {}
console.log("");
