// E1 expert offload — RUNTIME (PLAN Phase 19).
//
// Routes expert WEIGHT tensors through a read-only file mmap (clean,
// page-aligned pages that cost ~0 phys_footprint and that the GPU gathers
// directly — probes confirmed bit-exact + non-wiring) instead of the
// anonymous mlx_load_safetensors copy that counts against memory pressure.
//
// Activated two ways, both before model construction:
//   - env MLX_BUN_EXPERT_OFFLOAD=<dir>  (scripts / direct runs)
//   - activateExpertOffload(dir)        (CLI `--expert-offload`)
// The file is produced by src/expert-offload-build.ts. Tensors not in the
// manifest (or when never activated) fall back to the resident path, so this
// is inert by default and safe on a partially-converted file.

import { readFileSync } from "node:fs";
import { MmapFile } from "./mmap";
import { MlxArray, SAFETENSORS_TO_MLX } from "./mlx/array";
import type { SafetensorsDtype } from "./safetensors";
import { runtimeValue } from "./runtime-config";

export interface OffloadEntry {
  name: string;
  offset: number;
  length: number;
  dtype: SafetensorsDtype;
  shape: number[];
}
export interface OffloadManifest {
  page: number;
  model: string;
  totalBytes: number;
  tensors: OffloadEntry[];
}

let mm: MmapFile | null = null;
let manifest: Map<string, OffloadEntry> | null = null;

/** Open the offload file at `dir` (experts.bin + manifest.json) and route
 *  expert weights through it. Call BEFORE the model is constructed. */
export function activateExpertOffload(dir: string): void {
  const parsed = JSON.parse(readFileSync(`${dir}/manifest.json`, "utf8")) as OffloadManifest;
  manifest = new Map(parsed.tensors.map((t) => [t.name, t]));
  mm = MmapFile.open(`${dir}/experts.bin`, "ro");
  process.stderr.write(`[expert-offload] mmap ${dir}/experts.bin (${parsed.tensors.length} tensors)\n`);
}

export function isExpertOffload(): boolean {
  return mm !== null;
}

/** Zero-copy mmap-backed array for `name` if offload is active and the tensor
 *  is in the manifest; else null. The converter aligns every tensor to 16 KB
 *  and the mmap base is page-aligned, so the pointer is page-aligned —
 *  required for the GPU to gather from it.
 *
 *  Lifetime: these arrays are created ONCE at model load
 *  (QuantizedSwitchLinear.load, gemma4-base.ts) and live as model weights;
 *  every decode's gather_qmm references them, so GPU command buffers retain
 *  the mlx buffer past any dispose and mlx may drop the LAST reference on
 *  the Metal completion thread. That's why this must be fromPointer (native
 *  free(NULL) dtor — safe from any thread), NOT the old fromView JSCallback
 *  pin (the 2026-07-06 deadlock class). The memory contract is trivially
 *  met: `mm` is module-level and never unmapped — the mapping owns the
 *  bytes for the process (clean file-backed pages, ~0 phys_footprint). */
export function expertOffloadArray(name: string): MlxArray | null {
  if (!mm || !manifest) return null;
  const e = manifest.get(name);
  if (!e) return null;
  // Bounds check the whole tensor (pointer() only checks the start).
  if (e.offset + e.length > mm.size)
    throw new Error(`expert-offload: ${name} [${e.offset}, +${e.length}) exceeds ${mm.path} (${mm.size} B)`);
  return MlxArray.fromPointer(mm.pointer(e.offset), e.shape, SAFETENSORS_TO_MLX[e.dtype]);
}

const expertOffloadPath = runtimeValue("MLX_BUN_EXPERT_OFFLOAD");
if (expertOffloadPath) activateExpertOffload(expertOffloadPath);
