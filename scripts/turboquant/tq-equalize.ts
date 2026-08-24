// AWQ-style per-channel equalization for a qwen3_5 snapshot (works on folded
// OR plain bf16): at each decoder-norm site, scale the norm gain by 1/s and
// the consumer weight columns by s, where s = (mean|x|/geomean)^alpha from
// tq-collect-actstats.py. Exactly function-preserving (adjacent diagonal pair,
// no residual crossing); the point is to rebalance quantization salience —
// high-activation channels get finer effective precision.
//
// Precision detail: the norm gain is stored bf16, so s_weights is the exact
// f32 inverse of the bf16-rounded 1/s — the runtime product is 1 to f32.
//
//   bun scripts/turboquant/tq-equalize.ts <src-dir> <stats.json> <out-dir> [--alpha 0.5]

import { existsSync, mkdirSync, copyFileSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { Weights } from "../../src/weights";
import { ShardedWriter } from "../../src/quantize/safetensors-writer";
import { MlxArray } from "../../src/mlx/array";
import { Dtype, clearCache } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";

const args = process.argv.slice(2);
const positional = args.filter((a) => !a.startsWith("--"));
const [srcDir, statsPath, outDir] = positional;
if (!srcDir || !statsPath || !outDir) {
  console.error("usage: bun scripts/turboquant/tq-equalize.ts <src-dir> <stats.json> <out-dir> [--alpha 0.5]");
  process.exit(1);
}
const aIdx = args.indexOf("--alpha");
const alpha = aIdx > -1 ? Number(args[aIdx + 1]) : 0.5;

const stats = JSON.parse(readFileSync(statsPath, "utf8")) as Record<string, number[]>;

/** bf16 round via f32 bit truncation-with-round-to-nearest-even. */
function toBf16(x: number): number {
  const buf = new DataView(new ArrayBuffer(4));
  buf.setFloat32(0, x);
  let bits = buf.getUint32(0);
  const lsb = (bits >>> 16) & 1;
  bits = (bits + 0x7fff + lsb) & 0xffff0000;
  buf.setUint32(0, bits);
  return buf.getFloat32(0);
}

/** norm site → per-channel {gainScale (bf16-rounded 1/s), weightScale (exact inverse)} */
const scales = new Map<string, { gain: Float32Array; weight: Float32Array }>();
for (const [site, a] of Object.entries(stats)) {
  const n = a.length;
  const logs = a.map((v) => Math.log(Math.max(v, 1e-12)));
  const geo = Math.exp(logs.reduce((x, y) => x + y, 0) / n);
  const gain = new Float32Array(n);
  const weight = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    let s = Math.pow(Math.max(a[i]!, 1e-12) / geo, alpha);
    s = Math.min(8, Math.max(1 / 8, s));
    const g = toBf16(1 / s);
    gain[i] = g;
    weight[i] = 1 / g;
  }
  scales.set(site, { gain, weight });
}

/** consumer weight name → its norm site (same associations as the fold plan) */
function normSiteFor(name: string): string | null {
  const m = /^(language_model\.model\.layers\.\d+)\.(.+)\.weight$/.exec(name);
  if (m) {
    const mod = m[2]!;
    if (/^self_attn\.(q|k|v)_proj$/.test(mod) || /^linear_attn\.in_proj_(qkv|z|b|a)$/.test(mod))
      return `${m[1]}.input_layernorm.weight`;
    if (/^mlp\.(gate|up)_proj$/.test(mod))
      return `${m[1]}.post_attention_layernorm.weight`;
    return null;
  }
  if (name === "language_model.lm_head.weight") return "language_model.model.norm.weight";
  return null;
}

mkdirSync(outDir, { recursive: true });
const weights = await Weights.open(srcDir);
try {
  const writer = new ShardedWriter(outDir);
  const names = weights.tensorNames;
  const byFile = new Map<string, string[]>();
  for (const n of names) {
    const f = weights.fileOf(n)!;
    (byFile.get(f) ?? byFile.set(f, []).get(f)!).push(n);
  }
  let eqW = 0;
  let eqN = 0;
  for (const [file, list] of byFile) {
    for (const name of list) {
      const src = weights.tensor(name);
      if (scales.has(name)) {
        // Norm gain: γ' = γ · (bf16-rounded 1/s)
        const { gain } = scales.get(name)!;
        const gArr = MlxArray.fromFloat32(gain, [gain.length]);
        const f32 = src.astype(Dtype.float32);
        const scaled = ops.mul(f32, gArr);
        const out = scaled.astype(Dtype.bfloat16);
        out.eval();
        for (const t of [gArr, f32, scaled]) t.dispose();
        writer.add(name, out);
        eqN++;
      } else {
        const site = normSiteFor(name);
        if (site && scales.has(site)) {
          const { weight } = scales.get(site)!;
          const wArr = MlxArray.fromFloat32(weight, [weight.length]);
          const f32 = src.astype(Dtype.float32);
          const scaled = ops.mul(f32, wArr);
          const out = scaled.astype(Dtype.bfloat16);
          out.eval();
          for (const t of [wArr, f32, scaled]) t.dispose();
          writer.add(name, out);
          eqW++;
        } else {
          const copy = src.astype(src.dtype);
          copy.eval();
          writer.add(name, copy);
        }
      }
    }
    weights.releaseShard(file);
    clearCache();
  }
  const res = writer.finish();
  console.log(`equalized ${eqW} consumer weights, ${eqN} norm gains (alpha=${alpha}); ` +
    `${res.shards.length} shard(s), ${(res.totalSize / 1e9).toFixed(2)} GB`);
  for (const f of ["config.json", "tokenizer.json", "tokenizer_config.json", "special_tokens_map.json", "generation_config.json", "chat_template.jinja", "vocab.json", "merges.txt", "preprocessor_config.json", "video_preprocessor_config.json", "turboquant_fold.json"]) {
    if (existsSync(join(srcDir, f))) copyFileSync(join(srcDir, f), join(outDir, f));
  }
  writeFileSync(join(outDir, "turboquant_equalize.json"),
    JSON.stringify({ source: srcDir, stats: statsPath, alpha, generatedAt: new Date().toISOString() }, null, 2));
} finally {
  weights.dispose();
}
