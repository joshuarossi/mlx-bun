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
 *  required for the GPU to gather from it. */
export function expertOffloadArray(name: string): MlxArray | null {
  if (!mm || !manifest) return null;
  const e = manifest.get(name);
  if (!e) return null;
  return MlxArray.fromView(mm.view(e.offset, e.length), e.shape, SAFETENSORS_TO_MLX[e.dtype]);
}

if (process.env.MLX_BUN_EXPERT_OFFLOAD) activateExpertOffload(process.env.MLX_BUN_EXPERT_OFFLOAD);
