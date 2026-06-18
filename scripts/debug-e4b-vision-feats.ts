// Debug: compare mlx-bun SigLIP features vs optiq's dump (/tmp/e4b-vis-feats.f32
// from scripts/dump-e4b-vision-feats.py). Isolates the vision port from the LM.
//   bun scripts/debug-e4b-vision-feats.ts
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { Gemma4Model } from "../src/model/gemma4";
import { SiglipVisionTower, parseSiglipConfig } from "../src/vision/siglip";
import * as ops from "../src/mlx/ops";

const E4B = process.argv[2]
  ?? `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/fcdb12d740cd813634064567fc7cb51159b34253`;

const config = await loadModelConfig(E4B);
const weights = await Weights.open(E4B);
const model = new Gemma4Model(weights, config);
const sigCfg = parseSiglipConfig(config.raw.vision_config as Record<string, unknown>);
const tower = SiglipVisionTower.load(E4B, sigCfg, model.embedScale);

const bytes = new Uint8Array(await Bun.file("tests/fixtures/grad-768.png").arrayBuffer());
const pre = await tower.preprocess(bytes);
console.log(`softTokens=${pre.softTokens} numReal=${pre.numReal}`);

const { Dtype } = await import("../src/mlx/ffi");
// features() returns the /embed_scale'd soft tokens; optiq's dump is BEFORE
// the divide, so multiply back to compare apples-to-apples.
const pooled = process.env.MLX_BUN_VIS_STAGE === "pooled";
const feats = tower.features(pre);
// pooled stage: compare raw (no embed_scale) to optiq's encoder dump.
const scaled = pooled ? feats : ops.mulScalar(feats, model.embedScale);
const cont = ops.contiguous(scaled); // guard against non-contiguous readback
const f32 = cont.astype(Dtype.float32);
const mine = f32.toFloat32();
if (scaled !== feats) scaled.dispose();
feats.dispose();
cont.dispose();
f32.dispose();

const refFile = pooled ? "/tmp/e4b-vis-encoder.f32" : "/tmp/e4b-vis-feats.f32";
const ref = new Float32Array(await Bun.file(refFile).arrayBuffer());
if (ref.length !== mine.length) {
  console.error(`length mismatch: mine ${mine.length} vs ref ${ref.length}`);
  process.exit(1);
}
let sse = 0, refSS = 0, maxAbs = 0, maxRel = 0;
for (let i = 0; i < ref.length; i++) {
  const d = mine[i]! - ref[i]!;
  sse += d * d;
  refSS += ref[i]! * ref[i]!;
  const ad = Math.abs(d);
  if (ad > maxAbs) maxAbs = ad;
  const rel = ad / (Math.abs(ref[i]!) + 1e-6);
  if (rel > maxRel) maxRel = rel;
}
console.log(`feats[1,${pre.softTokens},2560] vs optiq:`);
console.log(`  rel-RMSE  = ${(Math.sqrt(sse / refSS) * 100).toFixed(4)}%`);
console.log(`  max |abs| = ${maxAbs.toExponential(3)}`);
console.log(`  max |rel| = ${maxRel.toExponential(3)}`);
console.log(`  sample mine[0..6] = ${Array.from(mine.slice(0, 6)).map((x) => x.toFixed(4))}`);
console.log(`  sample ref [0..6] = ${Array.from(ref.slice(0, 6)).map((x) => x.toFixed(4))}`);
