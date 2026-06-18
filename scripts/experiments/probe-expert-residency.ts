// Expert-residency memory probe (no model, no server, no download).
//
// Answers the load-bearing question for expert offload: when we load an
// expert-sized buffer, use it, and release it, does the OS actually get the
// RAM back — and what does an in-place slot overwrite cost?
//
// Three oracles per snapshot:
//   active = mlx_get_active_memory  (mlx's live-array accounting)
//   cache  = mlx_get_cache_memory   (buffers freed by arrays but retained)
//   rss    = process.memoryUsage().rss  (the OS-visible resident set)
// The model: dispose() should move bytes active->cache (active drops, cache
// rises); clearCache() returns cache->OS (cache drops, rss drops).
//
// Run: bun scripts/probe-expert-residency.ts

import {
  activeMemory, cacheMemory, peakMemory, resetPeakMemory, clearCache,
  synchronize, Dtype,
} from "../../src/mlx/ffi";
import { MlxArray, gpuStream, cpuStream } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { MmapFile } from "../../src/mmap";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { writeFileSync, unlinkSync } from "node:fs";

const MB = 1024 * 1024;
const GB = 1024 * MB;
const g = (b: number) => (b / GB).toFixed(3).padStart(7);

function snap(label: string) {
  synchronize(gpuStream);
  synchronize(cpuStream);
  const a = activeMemory(), c = cacheMemory(), r = process.memoryUsage().rss;
  console.log(`    ${label.padEnd(34)} active=${g(a)}  cache=${g(c)}  rss=${g(r)}  (GB)`);
  return { a, c, r };
}

const SLAB_ELEMS = 128 * MB / 4;
const EXPERT_ELEMS = 512 * MB / 4;
const bigArray = (elems: number, step: number): MlxArray =>
  ops.arange(0, elems * step, step, Dtype.float32).eval();

console.log("\n=== expert-residency memory probe ===\n");
bigArray(1024, 1).dispose();
clearCache();
resetPeakMemory();
snap("baseline (warm, cleared)");

// ── Control: one 512 MB array, dispose, clearCache ───────────────────────
console.log("\n[control] single 512 MB array");
let x: MlxArray | null = bigArray(EXPERT_ELEMS, 1);
snap("allocated+eval");
x.dispose(); x = null;
snap("after dispose()");
clearCache();
snap("after clearCache()");

// ── Phase A — 4×512 MB, dispose all, clearCache ──────────────────────────
console.log("\n[A] 4×512 MB (2 GB), dispose all, then clearCache");
let arrs: (MlxArray | null)[] = [];
for (let i = 0; i < 4; i++) arrs.push(bigArray(EXPERT_ELEMS, i + 1));
snap("after load+eval");
for (const a of arrs) a!.dispose();
arrs = [];
snap("after dispose() all");
clearCache();
const aClear = snap("after clearCache()");

// ── Phase B — fixed-slot overwrite cost ──────────────────────────────────
console.log("\n[B] sliceUpdate one 128 MB slot of an 8-slot (1 GB) pool");
let pool: MlxArray | null = ops.reshape(bigArray(8 * SLAB_ELEMS, 1), [8, SLAB_ELEMS]).eval();
const bUpd = snap("pool resident");
const update = ops.reshape(bigArray(SLAB_ELEMS, 7), [1, SLAB_ELEMS]).eval();
const t0 = performance.now();
const updated = ops.sliceUpdate(pool, update, [3, 0], [4, SLAB_ELEMS]).eval();
const t1 = performance.now();
const aUpd = snap("after sliceUpdate(slot 3)");
console.log(`    -> ${(t1 - t0).toFixed(1)} ms; active +${g(aUpd.a - bUpd.a)} GB (slab=0.125; pool still referenced => copy, not donation)`);
pool.dispose(); pool = null; update.dispose(); updated.dispose(); clearCache();
snap("after dispose+clearCache");

// ── Phase C — mmap clean-page path ───────────────────────────────────────
console.log("\n[C] mmap 512 MB file, CPU-stream read, release via munmap");
const tmp = join(tmpdir(), `mlxbun-expert-probe-${process.pid}.bin`);
try {
  const bytes = 512 * MB;
  const buf = Buffer.allocUnsafe(bytes);
  for (let i = 0; i + 4 <= bytes; i += 4096) buf.writeFloatLE((i % 997) / 997, i);
  writeFileSync(tmp, buf);
  const bMap = snap("before mmap");
  const mm = MmapFile.open(tmp, "ro");
  const arr = MlxArray.fromView(mm.view(0, bytes), [bytes / 4], Dtype.float32);
  const touched = ops.add(arr, arr, cpuStream).eval();
  const mapped = snap("after fromView+read");
  touched.dispose(); arr.dispose(); mm.unmap(); clearCache();
  const rel = snap("after dispose+munmap+clearCache");
  console.log(`    bring-in rss +${g(mapped.r - bMap.r)} GB; release rss ${g(rel.r - mapped.r)} GB`);
} catch (e) {
  console.log(`    mmap path errored: ${(e as Error).message}`);
} finally {
  try { unlinkSync(tmp); } catch {}
}

console.log(`\npeak this run: ${g(peakMemory())} GB\n`);
