// STREAMING uniform quantizer for 27B-scale qwen3_5 VL snapshots: language
// modules quantize uniformly (embed + lm_head included), `vision_tower.*` is
// excluded and stays bf16 in the same repo (our tower loads raw tensors; the
// OptiQ ships vision only as an optiq/ sidecar — we ALSO keep in-main tensors). Streams shard-by-shard with
// source release + incremental writer: the production quantizeModelDir holds
// every source AND output array live until the end, which cannot fit a 51 GB
// model on 32 GB (same OOM class as the 2026-08-18 fold OOM).
//
//   bun scripts/experiments/tq-quantize.ts <src-dir> <out-dir> [--bits 4] [--group 64]

import { mkdirSync } from "node:fs";
import { Weights } from "../../src/weights";
import { loadModelConfig } from "../../src/config";
import { quantize } from "../../src/mlx/ops";
import { cpuStream } from "../../src/mlx/array";
import { Dtype, clearCache } from "../../src/mlx/ffi";
import { ShardedWriter } from "../../src/quantize/safetensors-writer";
import { isQuantizable } from "../../src/quantize";
import { buildQuantizationBlock, writeQuantizedConfig, type PerLayerEntry } from "../../src/quantize/config-writer";

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
const bits = Number(opt("bits", "4"));
const groupSize = Number(opt("group", "64")) as 32 | 64;
const excluded = (base: string): boolean => base.startsWith("vision_tower.");
// --profile tqmix: 3-bit MLP bulk + 4-bit attention/DeltaNet/embed/head —
// the rotated-low-bit band where TQ wins, with sensitive corridors kept at 4.
const profile = opt("profile", "");
const bitsFor = (base: string): number => {
  if (profile !== "tqmix") return bits;
  if (base.includes(".mlp.")) return 3;
  return 4;
};

const config = await loadModelConfig(srcDir);
if (config.quantization) throw new Error("source is already quantized");
mkdirSync(outDir, { recursive: true });

const weights = await Weights.open(srcDir);
const writer = new ShardedWriter(outDir);
const perLayer = new Map<string, PerLayerEntry>();
let nQuantized = 0;
let quantizedParams = 0;
let quantizedBits = 0;

const t0 = performance.now();
try {
  const names = weights.tensorNames;
  const byFile = new Map<string, string[]>();
  for (const n of names) {
    const f = weights.fileOf(n)!;
    let list = byFile.get(f);
    if (!list) byFile.set(f, (list = []));
    list.push(n);
  }
  let done = 0;
  for (const [file, list] of byFile) {
    for (const name of list) {
      const src = weights.tensor(name);
      const base = name.endsWith(".weight") ? name.slice(0, -".weight".length) : null;
      const eligible = base !== null && isQuantizable(src.shape, groupSize);
      if (!eligible || excluded(base!)) {
        // Copy out of the shard map so the shard can be released.
        const copy = src.astype(src.dtype);
        writer.add(name, copy);
        if (eligible && excluded(base!)) perLayer.set(base!, false);
      } else {
        const moduleBits = bitsFor(base!);
        const bf16 = src.astype(Dtype.bfloat16, cpuStream);
        const q = quantize(bf16, groupSize, moduleBits, "affine", cpuStream);
        bf16.dispose();
        writer.add(`${base}.weight`, q.packed);
        writer.add(`${base}.scales`, q.scales);
        if (q.biases) writer.add(`${base}.biases`, q.biases);
        if (moduleBits !== bits) perLayer.set(base!, { bits: moduleBits, groupSize });
        nQuantized++;
        const params = src.shape.reduce((a, b) => a * b, 1);
        quantizedParams += params;
        quantizedBits += params * moduleBits + (params / groupSize) * 32;
      }
      done++;
    }
    weights.releaseShard(file);
    clearCache();
    process.stdout.write(`\r  ${done}/${names.length} tensors (${file})   `);
  }
  const res = writer.finish();
  const achievedBpw = quantizedParams > 0 ? quantizedBits / quantizedParams : 0;
  console.log(`\nquantized ${nQuantized} modules, ${achievedBpw.toFixed(2)} bpw, ` +
    `${(res.totalSize / 1e9).toFixed(2)} GB in ${((performance.now() - t0) / 1000).toFixed(0)}s`);

  const block = buildQuantizationBlock({ bits, groupSize, mode: "affine" }, perLayer);
  await writeQuantizedConfig(config.raw, outDir, block, {
    srcDir,
    optiq: {
      method: "uniform_affine",
      base_model: srcDir,
      bits,
      group_size: groupSize,
      achieved_bpw: achievedBpw,
      per_layer_count: nQuantized,
    },
  });
  console.log("config + aux files written");
} finally {
  weights.dispose();
  clearCache();
}
