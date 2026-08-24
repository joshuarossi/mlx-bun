// Fold a qwen3_5 trunk (VL wrapper) or its MTP companion with the TurboQuant
// weight rotation (R1+γ; no R2 — attn_output_gate). STREAMING: walks the
// source shard-by-shard, releases each source shard after use, and writes
// through the incremental ShardedWriter — peak memory is one source shard +
// one output shard, never the model (the naive path OOM'd at 27B).
//
// The companion MUST be folded with the same --seed as its trunk.
//
//   bun scripts/turboquant/fold-qwen35.ts <src-dir> <out-dir> [--seed N]

import { existsSync, mkdirSync, copyFileSync, writeFileSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { Weights } from "../../src/weights";
import { planQwen35Fold, planQwenMtpFold, QwenFoldContext } from "../../src/quantize/rotate";
import { ShardedWriter } from "../../src/quantize/safetensors-writer";
import { clearCache } from "../../src/mlx/ffi";

const args = process.argv.slice(2);
const positional = args.filter((a) => !a.startsWith("--"));
const [srcDir, outDir] = positional;
if (!srcDir || !outDir) {
  console.error("usage: bun scripts/turboquant/fold-qwen35.ts <src-dir> <out-dir> [--seed N]");
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
  const names = weights.tensorNames;
  const isCompanion = names.includes("fc.weight") && names.includes("pre_fc_norm_hidden.weight");
  const textCfg = (raw.text_config ?? raw) as Record<string, unknown>;
  const hiddenSize = Number(textCfg.hidden_size);
  console.log(`fold ${isCompanion ? "MTP companion" : "trunk"}: hidden=${hiddenSize} seed=${seed} (streaming)`);

  const plan = isCompanion ? planQwenMtpFold(names) : planQwen35Fold(names);
  const ctx = new QwenFoldContext(weights, hiddenSize, seed, plan.gammaNames);
  const writer = new ShardedWriter(outDir);

  const t0 = performance.now();
  // Walk in SOURCE SHARD order so each shard is touched once then released.
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
      const op = plan.ops.get(name)!;
      const folded = ctx.apply(op, weights.tensor(name));
      writer.add(name, folded);
      done++;
    }
    // Tied-head clone rides with the shard holding the embedding source.
    if (plan.extraHead && list.includes(plan.extraHead.from)) {
      const cloned = ctx.apply(
        { kind: "input", gamma: plan.extraHead.gamma },
        weights.tensor(plan.extraHead.from),
      );
      writer.add(plan.extraHead.name, cloned);
    }
    weights.releaseShard(file);
    clearCache();
    process.stdout.write(`\r  ${done}/${names.length} tensors (${file})   `);
  }
  const res = writer.finish();
  console.log(`\nwrote ${res.shards.length} shard(s), ${(res.totalSize / 1e9).toFixed(2)} GB, ` +
    `${res.totalParams} params in ${((performance.now() - t0) / 1000).toFixed(1)}s`);

  // Untie if the fold cloned a head out of tied embeddings.
  const outCfg = { ...raw } as Record<string, unknown>;
  if (!isCompanion && plan.extraHead) {
    if (outCfg.tie_word_embeddings !== undefined) outCfg.tie_word_embeddings = false;
    if (typeof outCfg.text_config === "object" && outCfg.text_config !== null)
      (outCfg.text_config as Record<string, unknown>).tie_word_embeddings = false;
  }
  writeFileSync(join(outDir, "config.json"), JSON.stringify(outCfg, null, 2));
  for (const f of ["tokenizer.json", "tokenizer_config.json", "special_tokens_map.json", "generation_config.json", "chat_template.jinja", "vocab.json", "merges.txt", "preprocessor_config.json", "video_preprocessor_config.json"]) {
    if (existsSync(join(srcDir, f))) copyFileSync(join(srcDir, f), join(outDir, f));
  }
  writeFileSync(join(outDir, "turboquant_fold.json"),
    JSON.stringify({
      source: srcDir, generatedAt: new Date().toISOString(), seed,
      r1: true, r2: false, hiddenSize, deviations: plan.deviations,
    }, null, 2));
  console.log("config + tokenizer/preprocessor files + turboquant_fold.json written");
} finally {
  weights.dispose();
}
