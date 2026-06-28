// Smoke test: load plain-Qwen3 (Qwen3-Embedding-4B-4bit-DWQ) through mlx-bun's
// new Qwen3Model graph and verify it produces sensible sentence embeddings.
// This is a RELATIVE sanity check (similar sentences → high cosine, unrelated →
// low), NOT bit-exact parity — that gate runs against the mlx-lm oracle on the
// benchmark machine (scripts/gen-qwen3-embed-golden.py + the parity test).
//
// Usage: bun scripts/experiments/qwen3-embed-smoke.ts [model-dir]

import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { loadTokenizer } from "../../src/tokenizer";
import * as ops from "../../src/mlx/ops";
import { Glob } from "bun";

async function resolveModelDir(): Promise<string> {
  if (process.argv[2]) return process.argv[2];
  const hub = `${process.env.HOME}/.cache/huggingface/hub`;
  const glob = new Glob("models--mlx-community--Qwen3-Embedding-*/snapshots/*/config.json");
  for await (const f of glob.scan({ cwd: hub, absolute: true })) {
    return f.replace(/\/config\.json$/, "");
  }
  throw new Error("no Qwen3-Embedding snapshot found in HF cache");
}

const modelDir = await resolveModelDir();
console.log(`model dir: ${modelDir}`);

const config = await loadModelConfig(modelDir);
console.log(`model_type=${config.modelType} arch=${config.architectures.join(",")} layers=${config.text.numHiddenLayers} hidden=${config.text.hiddenSize} headDim=${config.text.headDim} tied=${config.text.tieWordEmbeddings} ropeBase=${config.text.ropeParameters.full_attention?.ropeTheta}`);

const weights = await Weights.open(modelDir);
const model = createModel(weights, config);
console.log(`built ${model.constructor.name}`);

const tok = await loadTokenizer(modelDir);
// Qwen3-Embedding terminates each input with <|endoftext|> and pools the last
// token. Derive its id from the tokenizer (encode the literal, no specials).
const eod = tok.encode("<|endoftext|>", false);
if (eod.length !== 1) throw new Error(`unexpected <|endoftext|> encoding: ${eod}`);
const EOD = eod[0]!;
console.log(`<|endoftext|> id = ${EOD}`);

function embed(text: string): Float32Array {
  const ids = [...tok.encode(text, false), EOD];
  const idArr = ops.fromInt32(ids, [1, ids.length]);
  const vec = (model as any).embedPooled(idArr) as import("../../src/mlx/array").MlxArray;
  idArr.dispose();
  const out = Float32Array.from(vec.toFloat32());
  vec.dispose();
  return out;
}

function cosine(a: Float32Array, b: Float32Array): number {
  let dot = 0;
  for (let i = 0; i < a.length; i++) dot += a[i]! * b[i]!;
  return dot; // both are L2-normalized → dot == cosine
}

const sentences = [
  "The cat sat on the warm windowsill in the afternoon sun.",   // 0
  "A kitten rested by the sunny window during the day.",        // 1  ~0
  "Quarterly revenue grew 12% driven by cloud subscriptions.",  // 2  far from 0/1
  "Cloud subscription growth lifted the company's earnings.",   // 3  ~2
];

console.log("\nembedding…");
const vecs = sentences.map(embed);
console.log(`dim=${vecs[0]!.length}`);

console.log("\ncosine matrix:");
for (let i = 0; i < vecs.length; i++) {
  const row = vecs.map((_, j) => cosine(vecs[i]!, vecs[j]!).toFixed(3)).join("  ");
  console.log(`  s${i}: ${row}`);
}

const simPair = cosine(vecs[0]!, vecs[1]!);
const simPair2 = cosine(vecs[2]!, vecs[3]!);
const crossA = cosine(vecs[0]!, vecs[2]!);
const crossB = cosine(vecs[1]!, vecs[3]!);
console.log(`\nrelated(0,1)=${simPair.toFixed(3)} related(2,3)=${simPair2.toFixed(3)} | unrelated(0,2)=${crossA.toFixed(3)} unrelated(1,3)=${crossB.toFixed(3)}`);
const ok = simPair > crossA && simPair > crossB && simPair2 > crossA && simPair2 > crossB;
console.log(ok ? "\n✅ PASS: related pairs cohere above unrelated pairs" : "\n❌ FAIL: geometry does not separate related from unrelated");
process.exit(ok ? 0 : 1);
