// Quantize a qwen3_5 VL trunk with the vision tower KEPT bf16 (our tower
// loads raw tensors; the ecosystem convention — OptiQ — strips vision
// entirely, we keep it). Language modules quantize uniformly.
//
//   bun scripts/experiments/tq-quantize.ts <src-dir> <out-dir> [--bits 4] [--group 64]

import { quantizeModelDir } from "../../src/quantize";

const args = process.argv.slice(2);
const positional = args.filter((a) => !a.startsWith("--"));
const [srcDir, outDir] = positional;
if (!srcDir || !outDir) {
  console.error("usage: bun scripts/experiments/tq-quantize.ts <src-dir> <out-dir> [--bits N] [--group N]");
  process.exit(1);
}
const opt = (name: string, dflt: string): string => {
  const i = args.indexOf(`--${name}`);
  return i > -1 ? args[i + 1]! : dflt;
};
const bits = Number(opt("bits", "4")) as 4 | 8;
const groupSize = Number(opt("group", "64")) as 32 | 64;

const t0 = performance.now();
const r = await quantizeModelDir(
  srcDir,
  outDir,
  {
    bits,
    groupSize,
    mode: "affine",
    quantizePredicate: (base) => !base.startsWith("vision_tower."),
  },
  (e) => { if (e.stage !== "quantizing") console.log(`[${e.stage}] ${e.message}`); },
);
console.log(
  `quantized ${r.nQuantized} modules, achieved ${r.achievedBpw.toFixed(2)} bpw, ` +
  `${(r.write.totalSize / 1e9).toFixed(2)} GB in ${((performance.now() - t0) / 1000).toFixed(0)}s`,
);
