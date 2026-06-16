// Bit-exact training-loss parity vs mlx-lm across MULTIPLE mask spans (so a
// single input can't mask-match by coincidence). For each (promptLen, L) it
// checks BOTH the loss (vs mlx-lm default_loss) AND the denominator: our
// responseOnlyCe divides by M = (len-1) - max(0, promptLen-1); mlx-lm divides by
// ntoks = mask.sum(). Reads /tmp/parity_multi.json (from mlxlm-loss-multi.py).
//   MLX_BUN_PERF_KERNEL=0 MLX_BUN_FUSED_GELU=0 bun scripts/parity-vs-mlxlm.ts

import { readFileSync, readdirSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { sftLoss, maskedCe } from "../src/train/loss";
import { trainForward } from "../src/train/forward";
import { MlxArray } from "../src/mlx/array";
import type { SftBatch } from "../src/train/dataset";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;

const { ids: allIds, configs } = JSON.parse(readFileSync("/tmp/parity_multi.json", "utf8")) as {
  ids: number[];
  configs: { promptLen: number; L: number; loss: number; ntoks: number }[];
};

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);

console.log(`### parity-vs-mlxlm (multi-span)  — loss AND denominator (M vs ntoks)`);
let allOk = true;
for (const c of configs) {
  const ids = allIds.slice(0, c.L);
  const batch: SftBatch = { ids: [ids], promptLens: [c.promptLen] };
  const l = sftLoss(model, batch); // response-only CE (sums M positions)
  l.eval();
  const ours = l.toFloat32()[0]!;
  l.dispose();
  // Full-masked CE: full logits, sum over ALL T positions (masked) — mlx-lm's
  // exact summation. Should be bit-exact with mlx-lm.
  const T = c.L - 1;
  const inputHost = new Int32Array(T);
  for (let t = 0; t < T; t++) inputHost[t] = ids[t]!;
  const inputIds = MlxArray.fromInt32(inputHost, [1, T]);
  const logits = trainForward(model, inputIds);
  const fl = maskedCe(logits, batch);
  fl.eval();
  const full = fl.toFloat32()[0]!;
  fl.dispose(); logits.dispose(); inputIds.dispose();
  // Our denominator, mirroring responseOnlyCe: M = (len-1) - max(0, promptLen-1).
  const startT = Math.max(0, c.promptLen - 1);
  const M = c.L - 1 - startT;
  const denomMatch = M === c.ntoks;            // mask span / denominator correct?
  const respIsOpt = ours === full;             // response-only == full-masked (memory opt, no math change)?
  const ulps = Math.abs(full - c.loss) / (15.6 * 2 ** -23); // residual vs mlx-lm, in float32 ulps
  const ok = denomMatch && respIsOpt && ulps < 1; // parity to within float32 noise
  allOk &&= ok;
  console.log(
    `###  pL=${c.promptLen} L=${c.L}: denom M=${M} ${denomMatch ? "==" : "!="} ntoks=${c.ntoks}` +
    `  |  resp-only==full-masked: ${respIsOpt ? "yes" : "NO"}` +
    `  |  vs mlx-lm: ${ulps < 0.01 ? "BIT-EXACT" : `${ulps.toFixed(2)} f32-ulp`}  ${ok ? "OK" : "FAIL"}`,
  );
}
weights.dispose();
console.log(`### ${allOk ? "PASS — denominator/span exact, response-only == full-masked (memory opt, not parity risk), loss within 1 float32-ulp of mlx-lm" : "FAIL"}`);
process.exitCode = allOk ? 0 : 1;
