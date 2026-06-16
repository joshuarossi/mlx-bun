// Validate Gemma4Model.runLayerRange (segmented-backward model-side, Phase B)
// against the training forward (trainForwardHidden -> base forwardLayers) on e4b
// — the model with per-layer-input embeddings AND KV-shared donors (22,23), the
// two e4b-specific paths runLayerRange must thread. Expect bit-exact.
//
//   bun scripts/gemma4-runlayerrange-test.ts        # L=512 (sliding window edge + full layers)

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { Gemma4Model } from "../src/model/gemma4";
import { MlxArray } from "../src/mlx/array";
import { TrainingCache } from "../src/train/forward";
import { trainForwardHidden } from "../src/train/forward";
import type { Cache } from "../src/model/gemma4-base";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const L = Number(process.env.L ?? 512);

console.log(`### gemma4-runLayerRange-test  e4b  L=${L}`);
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof Gemma4Model)) throw new Error("expected Gemma4Model");
const nLayers = model.layers.length;
console.log(`### layers=${nLayers} numDonors=${model.numDonors} perLayerWidth=${model.perLayerWidth} reusedDonors=${[...model.reusedDonors]}`);

// Synthetic ids [1, L].
const idsHost = new Int32Array(Array.from({ length: L }, (_, i) => ((i * 13 + 5) % 4000) + 1));
const ids = MlxArray.fromInt32(idsHost, [1, L]);

// Reference: the stock training forward (TrainingCache -> base forwardLayers,
// since the generated forwardLayers' #matches(cache) rejects TrainingCache).
const ref = trainForwardHidden(model, ids); // [1, L, hidden], finalNorm'd
ref.eval();
const refData = ref.toFloat32();
ref.dispose();

// Test: embedForSegmented + makeTrainingMasks + runLayerRange(0, nLayers) + finalNorm.
const { hScaled, perLayer } = model.embedForSegmented(ids);
const caches: Cache[] = Array.from({ length: model.numDonors }, () => new TrainingCache());
const masks = model.makeTrainingMasks(caches, L);
const { h, donorKvOut } = model.runLayerRange(hScaled, 0, nLayers, caches, masks, perLayer, new Map());
hScaled.dispose();
perLayer?.dispose();
const testHidden = model.finalNorm.forward(h);
h.dispose();
testHidden.eval();
const testData = testHidden.toFloat32();
testHidden.dispose();
for (const m of masks.values()) m.arr?.dispose();
for (const c of caches) c.dispose();
// runLayerRange returns the reused donors' K/V (22,23) over the full range — in a
// real segmented run these become boundaries; here just free them.
for (const s of donorKvOut.values()) { if (s.kind === "plain") { s.keys.dispose(); s.values.dispose(); } }
ids.dispose();
weights.dispose();

// Compare.
let maxRel = 0, maxAbs = 0;
for (let i = 0; i < refData.length; i++) {
  const d = Math.abs(refData[i]! - testData[i]!);
  if (d > maxAbs) maxAbs = d;
  const rel = d / (Math.abs(refData[i]!) || 1);
  if (rel > maxRel) maxRel = rel;
}
console.log(`### donorKvOut keys (reused donors emitted) = ${[...donorKvOut.keys()]}`);
console.log(`### runLayerRange vs forwardLayers: maxRel=${(maxRel * 100).toFixed(5)}%  maxAbs=${maxAbs.toExponential(3)}`);
const ok = maxAbs < 1e-3 && maxRel < 1e-3;
console.log(`### ${ok ? "PASS — runLayerRange == training forwardLayers (bit-exact)" : "FAIL"}`);
process.exitCode = ok ? 0 : 1;
