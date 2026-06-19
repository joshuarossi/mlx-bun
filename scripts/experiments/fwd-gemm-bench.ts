// Calibrate the forward floor: MLX quantizedMatmul (raw GEMM) + a full chunked
// QM+online-softmax forward, vs our flash-CCE forward kernel (~848 ms e4b M=512).
import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { Gemma4Model } from "../../src/model/gemma4";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import * as ops from "../../src/mlx/ops";
import { evalAll, randomNormal } from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";
const E4B = process.env.E4B === "1";
const HOME = process.env.HOME;
const repo = E4B ? "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit" : "models--mlx-community--MiniCPM5-1B-OptiQ-4bit";
const base = `${HOME}/.cache/huggingface/hub/${repo}/snapshots`;
const MODEL = `${base}/${readdirSync(base)[0]}`;
const M = Number(process.env.M ?? 512);
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const H = config.text.hiddenSize, V = config.text.vocabSize;
let w, sc, bi, spec, cap = null;
if (model instanceof Gemma4Model) { const e = model.embed; w=e.w; sc=e.scales; bi=e.biases; spec=e.spec; cap=config.text.finalLogitSoftcapping; }
else { const lh = (model as MiniCPM5Model).lmHead; w=lh.w; sc=lh.scales; bi=lh.biases; spec=lh.spec; }
const h = ops.mulScalar(randomNormal([M, H], Dtype.bfloat16, 0, 1, null), 0.5);
console.log(`### ${E4B?"e4b":"cpm5"} M=${M} H=${H} V=${V}`);
const timeIt = (label: string, fn: () => any[], n = 5) => {
  for (let i = 0; i < 2; i++) { const o = fn(); evalAll(o); o.forEach(x => x.dispose()); }
  const t0 = performance.now();
  for (let i = 0; i < n; i++) { const o = fn(); evalAll(o); o.forEach(x => x.dispose()); }
  console.log(`### ${label}: ${((performance.now()-t0)/n).toFixed(0)} ms`);
};
// A) raw quantizedMatmul → [M, V] logits
timeIt("raw quantizedMatmul [M,V]", () => [ops.quantizedMatmul(h, w!, sc!, bi!, spec!, true)]);
// B) full forward via chunked QM + online-softmax (f32) → logp [M] (no [M,V] retained beyond a chunk)
const targets = Array.from({length: M}, (_, i) => (i*2659+7) % V);
const fullForward = () => {
  const chunk = 256;
  const logps: any[] = [];
  for (let c0 = 0; c0 < M; c0 += chunk) {
    const c1 = Math.min(c0+chunk, M), Cc = c1-c0;
    const hc = h.slice([c0,0],[c1,H]);
    const logits = ops.quantizedMatmul(hc, w!, sc!, bi!, spec!, true); // [Cc, V]
    hc.dispose();
    const lse = ops.logsumexpAxis(logits, -1, false);
    const tgt = (ops as any).fromInt32 ? (ops as any).fromInt32(targets.slice(c0,c1), [Cc,1]) : null;
    logits.dispose(); logps.push(lse); if (tgt) tgt.dispose();
  }
  return logps;
};
timeIt("chunked QM + online-softmax forward", fullForward);
// C) full backward via chunked QM: recompute logits, softmax, g=(onehot−softmax),
//    dh_chunk = QM(g, W, transpose=false). The fused-head dh path (already in loss.ts).
const fullBackward = () => {
  const chunk = 256;
  const dhs: any[] = [];
  for (let c0 = 0; c0 < M; c0 += chunk) {
    const c1 = Math.min(c0+chunk, M), Cc = c1-c0;
    const hc = h.slice([c0,0],[c1,H]);
    const logits = ops.quantizedMatmul(hc, w!, sc!, bi!, spec!, true); // [Cc, V]
    hc.dispose();
    const lse = ops.logsumexpAxis(logits, -1, false);
    const lseCol = ops.reshape(lse, [Cc, 1]); lse.dispose();
    const sm = ops.exp(ops.sub(logits, lseCol)); // [Cc, V] softmax
    logits.dispose(); lseCol.dispose();
    const g = ops.mulScalar(sm, -1); // ≈ −softmax (skip onehot/sech² for timing)
    sm.dispose();
    const dh = ops.quantizedMatmul(g, w!, sc!, bi!, spec!, false); // [Cc, H]
    g.dispose();
    dhs.push(dh);
  }
  return dhs;
};
timeIt("chunked QM backward (dh)", fullBackward);
