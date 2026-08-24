// Extract vision_tower.* tensors from a (folded) trunk snapshot into the
// optiq/optiq_vision.safetensors sidecar our server's qwen vision loader
// reads (Qwen3VLVisionTower.load). The artifact keeps its in-main vision
// tensors too — sidecar for mlx-bun serving, in-main for mlx-vlm compat.
//
//   bun scripts/turboquant/tq-make-vision-sidecar.ts <trunk-dir> <artifact-dir>

import { mkdirSync } from "node:fs";
import { join } from "node:path";
import { Weights } from "../../src/weights";
import { writeShardedSafetensors, type NamedTensor } from "../../src/quantize/safetensors-writer";
import { renameSync } from "node:fs";

const [srcDir, outDir] = process.argv.slice(2);
if (!srcDir || !outDir) {
  console.error("usage: bun scripts/turboquant/tq-make-vision-sidecar.ts <trunk-dir> <artifact-dir>");
  process.exit(1);
}

const weights = await Weights.open(srcDir);
try {
  const vt = weights.tensorNames.filter((n) => n.startsWith("vision_tower."));
  if (vt.length === 0) throw new Error("no vision_tower tensors in source");
  mkdirSync(join(outDir, "optiq"), { recursive: true });
  const tensors: NamedTensor[] = vt.map((name) => ({ name, array: weights.tensor(name) }));
  const res = writeShardedSafetensors(join(outDir, "optiq"), tensors, {});
  if (res.shards.length !== 1) throw new Error("vision sidecar unexpectedly sharded");
  renameSync(join(outDir, "optiq", res.shards[0]!.file), join(outDir, "optiq", "optiq_vision.safetensors"));
  console.log(`optiq/optiq_vision.safetensors: ${vt.length} tensors, ${(res.totalSize / 1e9).toFixed(2)} GB`);
} finally {
  weights.dispose();
}
