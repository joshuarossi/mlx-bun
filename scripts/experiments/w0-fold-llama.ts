// W0 folding spike (PLAN.md "TurboQuant weights"): produce a rotation-folded
// bf16 copy of a Llama-family model and verify it loads. Parity gate runs
// separately via step0-top2-dump.ts on the original vs folded dirs.
//
//   bun scripts/experiments/w0-fold-llama.ts <src-model-dir> <out-dir> \
//       [--seed N] [--skip-r1] [--skip-r2]
//
// --skip-r1 leaves only the γ-fold (+R2 unless also skipped) — bisection arms
// for a parity failure. Output: folded safetensors + edited config
// (tie_word_embeddings=false) + copied tokenizer files + turboquant_fold.json
// sidecar (seed + recipe provenance).

import { existsSync, mkdirSync, copyFileSync, writeFileSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { Weights } from "../../src/weights";
import { foldLlamaWeights } from "../../src/quantize/rotate";
import { writeShardedSafetensors } from "../../src/quantize/safetensors-writer";

const args = process.argv.slice(2);
const positional = args.filter((a) => !a.startsWith("--"));
const srcDir = positional[0];
const outDir = positional[1];
if (!srcDir || !outDir) {
  console.error("usage: bun scripts/experiments/w0-fold-llama.ts <src-model-dir> <out-dir> [--seed N] [--skip-r1] [--skip-r2]");
  process.exit(1);
}
const seedIdx = args.indexOf("--seed");
const seed = seedIdx > -1 ? Number(args[seedIdx + 1]) : 42;
const r1 = !args.includes("--skip-r1");
const r2 = !args.includes("--skip-r2");

const rawConfig = JSON.parse(readFileSync(join(srcDir, "config.json"), "utf8")) as Record<string, unknown>;
if (rawConfig.model_type !== "llama")
  throw new Error(`w0-fold-llama targets model_type llama, got ${String(rawConfig.model_type)}`);
if (rawConfig.quantization)
  throw new Error("source model is quantized — folding needs full-precision weights");

const hiddenSize = Number(rawConfig.hidden_size);
const numHeads = Number(rawConfig.num_attention_heads);
const geo = {
  numLayers: Number(rawConfig.num_hidden_layers),
  hiddenSize,
  numHeads,
  numKvHeads: Number(rawConfig.num_key_value_heads ?? numHeads),
  headDim: Number(rawConfig.head_dim ?? hiddenSize / numHeads),
};

console.log(`fold: ${srcDir} → ${outDir}`);
console.log(`geometry ${JSON.stringify(geo)} seed=${seed} r1=${r1} r2=${r2}`);

mkdirSync(outDir, { recursive: true });
const weights = await Weights.open(srcDir);
try {
  const t0 = performance.now();
  const { tensors, meta } = foldLlamaWeights(weights, geo, { seed, r1, r2 });
  const result = writeShardedSafetensors(outDir, tensors, {});
  for (const t of tensors) t.array.dispose();
  console.log(`wrote ${result.shards.length} shard(s), ${(result.totalSize / 1e9).toFixed(2)} GB, ` +
    `${result.totalParams} params in ${((performance.now() - t0) / 1000).toFixed(1)}s`);

  // Folded config: untied (the fold wrote a separate folded lm_head).
  const outConfig = { ...rawConfig, tie_word_embeddings: false };
  writeFileSync(join(outDir, "config.json"), JSON.stringify(outConfig, null, 2));
  for (const f of ["tokenizer.json", "tokenizer_config.json", "special_tokens_map.json", "generation_config.json"]) {
    if (existsSync(join(srcDir, f))) copyFileSync(join(srcDir, f), join(outDir, f));
  }
  writeFileSync(
    join(outDir, "turboquant_fold.json"),
    JSON.stringify({ source: srcDir, generatedAt: new Date().toISOString(), ...meta }, null, 2),
  );
  console.log("config (untied) + tokenizer files + turboquant_fold.json written");
} finally {
  weights.dispose();
}
