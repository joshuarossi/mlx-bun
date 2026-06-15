// E1 step 1 (PLAN Phase 19): convert a MoE model's expert tensors into a
// page-aligned offload-ready file + manifest (see src/expert-offload-build.ts).
// The production path is `mlx-bun serve <model> --expert-offload` (builds on
// first use); this script is for ad-hoc conversion + verification.
//
//   bun scripts/convert-offload-experts.ts [registry-query] [outDir] [--layers N]

import { Registry } from "../src/registry";
import { buildOffloadFile } from "../src/expert-offload-build";
import { MmapFile } from "../src/mmap";
import { ShardedSafetensors } from "../src/safetensors";

const PAGE = 16384;
const QUERY = process.argv[2] && !process.argv[2].startsWith("--") ? process.argv[2] : "26B";
const OUT = process.argv[3] && !process.argv[3].startsWith("--") ? process.argv[3] : "/tmp/expert-offload";
const li = process.argv.indexOf("--layers");
const LAYER_CAP = li > -1 ? Number(process.argv[li + 1]) : Infinity;

const reg = new Registry();
if (reg.list().length === 0) await reg.scan();
const modelPath = reg.resolve(QUERY).path;
reg.close();
console.log(`model:  ${modelPath}`);

const manifest = await buildOffloadFile(modelPath, OUT, (m) => console.log(`  ${m}`), LAYER_CAP);
console.log(`wrote:  ${OUT}/experts.bin + manifest.json`);

// verify: every tensor 16 KB-aligned and byte-identical to the source
const shards = await ShardedSafetensors.open(modelPath);
const mm = MmapFile.open(`${OUT}/experts.bin`, "ro");
let bad = 0;
for (const t of manifest.tensors) {
  if (t.offset % PAGE !== 0) { bad++; console.log(`  UNALIGNED ${t.name} @ ${t.offset}`); continue; }
  const src = shards.view(t.name);
  const dst = mm.view(t.offset, t.length);
  for (const p of [0, 1, (t.length >> 1) & ~3, t.length - 1]) {
    if (src[p] !== dst[p]) { bad++; console.log(`  MISMATCH ${t.name} @ byte ${p}`); break; }
  }
}
mm.unmap();
console.log(`verify: ${manifest.tensors.length - bad}/${manifest.tensors.length} aligned + byte-identical  ${bad === 0 ? "✓" : "✗"}`);
