#!/usr/bin/env bun
// Phase 1a (docs/design/dspark-serving-program.md): quantize a DeepSpec
// drafter checkpoint to an mlx-native affine sibling.
//
//   bun scripts/dspark-quantize-drafter.ts <drafter-dir> \
//     [--out <dir>] [--bits 4|8] [--group-size 32|64]
//
// Policy (src/spec/dspark/quantize-drafter.ts): every 2-D matmul weight
// quantizes — layers, fc, lm_head, markov_w2, plus embed_tokens/markov_w1
// as quantized-gather tables; confidence_head + norms + layer_scalar stay
// bf16. Output: sharded safetensors + config.json with the house
// quantization block (per-module overrides, mlx `false` convention for the
// kept-bf16 head), verified loadable (DeepspecDrafter load + fc smoke).
//
// The quality gate for the result is the Phase-1c acceptance A/B
// (scripts/dspark-drafter-ab.ts) — run it before adopting any rung.

import { quantizeDrafterDir } from "../src/spec/dspark/quantize-drafter";

function usage(): never {
  console.error(
    "usage: bun scripts/dspark-quantize-drafter.ts <drafter-dir> [--out <dir>] [--bits 4|8] [--group-size 32|64]",
  );
  process.exit(2);
}

const args = process.argv.slice(2);
let src: string | null = null;
let out: string | null = null;
let bits: 4 | 8 = 4;
let groupSize: 32 | 64 = 64;

for (let i = 0; i < args.length; i++) {
  const a = args[i]!;
  if (a === "--out") out = args[++i] ?? usage();
  else if (a === "--bits") {
    const v = Number(args[++i]);
    if (v !== 4 && v !== 8) usage();
    bits = v;
  } else if (a === "--group-size") {
    const v = Number(args[++i]);
    if (v !== 32 && v !== 64) usage();
    groupSize = v;
  } else if (a.startsWith("-")) usage();
  else if (src === null) src = a;
  else usage();
}
if (!src) usage();
src = src.replace(/\/+$/, "");
const outDir = out ?? `${src}-affine-q${bits}-g${groupSize}`;

console.log(`source : ${src}`);
console.log(`output : ${outDir}`);
console.log(`scheme : affine ${bits}-bit, group ${groupSize} (confidence_head kept bf16)`);

const t0 = performance.now();
const result = await quantizeDrafterDir(src, outDir, {
  bits,
  groupSize,
  onProgress: (stage, message, progress) => {
    if (stage === "quantizing" && Math.round(progress * 100) % 10 !== 0) return;
    console.log(`  [${stage}] ${message}`);
  },
});
const secs = ((performance.now() - t0) / 1000).toFixed(1);

const gb = (n: number) => (n / 1024 ** 3).toFixed(2);
console.log(`\ndone in ${secs}s`);
console.log(`  modules quantized : ${result.nQuantized}`);
console.log(`  achieved bpw      : ${result.achievedBpw.toFixed(2)}`);
console.log(`  bytes written     : ${gb(result.write.totalSize)} GB across ${result.write.shards.length} shard(s)`);
console.log(`  load smoke        : PASS (DeepspecDrafter load + quantized fc forward)`);
console.log(`\nnext: acceptance A/B vs the bf16 source (Phase 1c):`);
console.log(`  bun scripts/dspark-drafter-ab.ts --target <target-model> --drafter-a ${src} --drafter-b ${outDir}`);
