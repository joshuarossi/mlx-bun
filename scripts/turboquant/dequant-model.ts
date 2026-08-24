// Dequantize a quantized MLX snapshot back to bf16 — the small-scale fold
// proof needs a runnable bf16 qwen3_5 and none is published, so we make one
// from the local OptiQ-4bit (fold-parity compares folded-dequant vs
// plain-dequant, which tests fold correctness exactly).
//
//   bun scripts/turboquant/dequant-model.ts <src-dir> <out-dir>

import { existsSync, mkdirSync, copyFileSync, writeFileSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { Weights } from "../../src/weights";
import { loadModelConfig, quantFor } from "../../src/config";
import { dequantize } from "../../src/mlx/ops";
import { cpuStream } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { writeShardedSafetensors, type NamedTensor } from "../../src/quantize/safetensors-writer";

const [srcDir, outDir] = process.argv.slice(2);
if (!srcDir || !outDir) {
  console.error("usage: bun scripts/turboquant/dequant-model.ts <src-dir> <out-dir>");
  process.exit(1);
}

const config = await loadModelConfig(srcDir);
if (!config.quantization) throw new Error("source is not quantized");
mkdirSync(outDir, { recursive: true });

const weights = await Weights.open(srcDir);
try {
  const names = weights.tensorNames;
  const bases = new Set<string>();
  for (const n of names) if (n.endsWith(".scales")) bases.add(n.slice(0, -".scales".length));

  const out: NamedTensor[] = [];
  for (const name of names) {
    if (name.endsWith(".scales") || name.endsWith(".biases")) continue;
    const base = name.endsWith(".weight") ? name.slice(0, -".weight".length) : null;
    if (base && bases.has(base)) {
      const spec = quantFor(config.quantization, base);
      if (!spec) throw new Error(`scales present but no quant spec for ${base}`);
      const deq = dequantize(
        weights.tensor(name), weights.tensor(`${base}.scales`),
        weights.has(`${base}.biases`) ? weights.tensor(`${base}.biases`) : null,
        { bits: spec.bits, groupSize: spec.groupSize, mode: spec.mode }, cpuStream,
      );
      const bf16 = deq.astype(Dtype.bfloat16, cpuStream);
      deq.dispose();
      out.push({ name, array: bf16 });
    } else {
      out.push({ name, array: weights.tensor(name) });
    }
  }
  const res = writeShardedSafetensors(outDir, out, {});
  console.log(`dequantized: ${res.shards.length} shard(s), ${(res.totalSize / 1e9).toFixed(2)} GB`);
  for (const t of out) t.array.dispose();

  const raw = JSON.parse(readFileSync(join(srcDir, "config.json"), "utf8")) as Record<string, unknown>;
  delete raw.quantization;
  delete raw.quantization_config;
  writeFileSync(join(outDir, "config.json"), JSON.stringify(raw, null, 2));
  for (const f of ["tokenizer.json", "tokenizer_config.json", "special_tokens_map.json", "generation_config.json", "chat_template.jinja"]) {
    if (existsSync(join(srcDir, f))) copyFileSync(join(srcDir, f), join(outDir, f));
  }
  console.log("config (quantization dropped) + tokenizer files written");
} finally {
  weights.dispose();
}
