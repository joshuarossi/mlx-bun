// Fold a qwen3_5 trunk (VL wrapper) or its MTP companion with the TurboQuant
// weight rotation (R1+γ; no R2 — attn_output_gate). Companion detection is by
// tensor names (fc.weight + pre_fc_norm_*). The companion MUST be folded with
// the same --seed as its trunk (shared residual basis).
//
//   bun scripts/experiments/fold-qwen35.ts <src-dir> <out-dir> [--seed N]

import { existsSync, mkdirSync, copyFileSync, writeFileSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { Weights } from "../../src/weights";
import { foldQwen35Weights, foldQwenMtpWeights } from "../../src/quantize/rotate";
import { writeShardedSafetensors } from "../../src/quantize/safetensors-writer";

const args = process.argv.slice(2);
const positional = args.filter((a) => !a.startsWith("--"));
const [srcDir, outDir] = positional;
if (!srcDir || !outDir) {
  console.error("usage: bun scripts/experiments/fold-qwen35.ts <src-dir> <out-dir> [--seed N]");
  process.exit(1);
}
const seedIdx = args.indexOf("--seed");
const seed = seedIdx > -1 ? Number(args[seedIdx + 1]) : 42;

const raw = JSON.parse(readFileSync(join(srcDir, "config.json"), "utf8")) as Record<string, unknown>;
if (raw.quantization || raw.quantization_config)
  throw new Error("source is quantized — fold needs full-precision weights (dequant first)");

mkdirSync(outDir, { recursive: true });
const weights = await Weights.open(srcDir);
try {
  const isCompanion = weights.has("fc.weight") && weights.has("pre_fc_norm_hidden.weight");
  const textCfg = (raw.text_config ?? raw) as Record<string, unknown>;
  const hiddenSize = Number(textCfg.hidden_size);
  console.log(`fold ${isCompanion ? "MTP companion" : "trunk"}: hidden=${hiddenSize} seed=${seed}`);

  const t0 = performance.now();
  const { tensors, meta } = isCompanion
    ? foldQwenMtpWeights(weights, hiddenSize, seed)
    : foldQwen35Weights(weights, hiddenSize, { seed });
  const res = writeShardedSafetensors(outDir, tensors, {});
  for (const t of tensors) t.array.dispose();
  console.log(`wrote ${res.shards.length} shard(s), ${(res.totalSize / 1e9).toFixed(2)} GB, ` +
    `${res.totalParams} params in ${((performance.now() - t0) / 1000).toFixed(1)}s`);

  // Untie if the fold cloned a head out of tied embeddings.
  const outCfg = { ...raw } as Record<string, unknown>;
  if (!isCompanion) {
    if (outCfg.tie_word_embeddings !== undefined) outCfg.tie_word_embeddings = false;
    if (typeof outCfg.text_config === "object" && outCfg.text_config !== null)
      (outCfg.text_config as Record<string, unknown>).tie_word_embeddings = false;
  }
  writeFileSync(join(outDir, "config.json"), JSON.stringify(outCfg, null, 2));
  for (const f of ["tokenizer.json", "tokenizer_config.json", "special_tokens_map.json", "generation_config.json", "chat_template.jinja", "vocab.json", "merges.txt", "preprocessor_config.json", "video_preprocessor_config.json"]) {
    if (existsSync(join(srcDir, f))) copyFileSync(join(srcDir, f), join(outDir, f));
  }
  writeFileSync(join(outDir, "turboquant_fold.json"),
    JSON.stringify({ source: srcDir, generatedAt: new Date().toISOString(), ...meta }, null, 2));
  console.log("config + tokenizer/preprocessor files + turboquant_fold.json written");
} finally {
  weights.dispose();
}
