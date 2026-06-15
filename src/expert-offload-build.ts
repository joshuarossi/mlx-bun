// E1 expert offload — BUILD (PLAN Phase 19).
//
// Produces the page-aligned offload file (experts.bin + manifest.json): each
// expert tensor's bytes are copied to a 16 KB-aligned offset so the GPU can
// gather it directly from a read-only file mmap (safetensors packs tensors at
// arbitrary offsets; the Phase-1 GPU-alignment rule needs page alignment).
// Kept separate from the runtime (src/expert-offload.ts) so the hot model
// path doesn't import the converter / safetensors-writer code.

import {
  openSync, writeSync, closeSync, writeFileSync, mkdirSync, existsSync, statSync, readFileSync,
} from "node:fs";
import { ShardedSafetensors } from "./safetensors";
import type { OffloadEntry, OffloadManifest } from "./expert-offload";

const PAGE = 16384;
const alignUp = (n: number, a: number) => Math.ceil(n / a) * a;
const isExpertTensor = (n: string) => n.includes("switch_glu") || n.includes(".experts.");
const layerOf = (n: string) => Number(n.match(/layers\.(\d+)/)?.[1] ?? -1);

/** Reuse `<modelPath>/.mlx-bun-offload` if present and valid for this model,
 *  else build it. Returns the offload dir (pass to activateExpertOffload). */
export async function ensureOffloadFile(
  modelPath: string,
  onProgress?: (msg: string) => void,
  outDir = `${modelPath}/.mlx-bun-offload`,
): Promise<string> {
  const bin = `${outDir}/experts.bin`;
  const man = `${outDir}/manifest.json`;
  if (existsSync(bin) && existsSync(man)) {
    try {
      const m = JSON.parse(readFileSync(man, "utf8")) as OffloadManifest;
      if (m.model === modelPath && statSync(bin).size === m.totalBytes) {
        onProgress?.(`reusing ${bin}`);
        return outDir;
      }
    } catch { /* fall through to rebuild */ }
  }
  await buildOffloadFile(modelPath, outDir, onProgress);
  return outDir;
}

export async function buildOffloadFile(
  modelPath: string,
  outDir: string,
  onProgress?: (msg: string) => void,
  layerCap = Infinity,
): Promise<OffloadManifest> {
  const shards = await ShardedSafetensors.open(modelPath);
  const names = shards.tensorNames
    .filter(isExpertTensor)
    .filter((n) => layerOf(n) < layerCap)
    .sort((a, b) => layerOf(a) - layerOf(b) || a.localeCompare(b));
  if (!names.length) throw new Error(`${modelPath}: no expert tensors (not an MoE model?)`);

  mkdirSync(outDir, { recursive: true });
  const fd = openSync(`${outDir}/experts.bin`, "w");
  const pad = Buffer.alloc(PAGE);
  let offset = 0;
  let i = 0;
  const tensors: OffloadEntry[] = [];
  for (const name of names) {
    const aligned = alignUp(offset, PAGE);
    if (aligned > offset) { writeSync(fd, pad, 0, aligned - offset); offset = aligned; }
    const info = shards.info(name);
    const bytes = shards.view(name); // zero-copy view into the source mmap
    writeSync(fd, bytes);
    tensors.push({ name, offset, length: bytes.length, dtype: info.dtype, shape: info.shape });
    offset += bytes.length;
    if (++i % 30 === 0) onProgress?.(`packing experts ${(offset / 1e9).toFixed(1)} GB (${i}/${names.length})`);
  }
  closeSync(fd);
  const manifest: OffloadManifest = { page: PAGE, model: modelPath, totalBytes: offset, tensors };
  writeFileSync(`${outDir}/manifest.json`, JSON.stringify(manifest));
  onProgress?.(`wrote ${(offset / 1e9).toFixed(2)} GB, ${tensors.length} tensors, ${new Set(names.map(layerOf)).size} layers`);
  return manifest;
}
