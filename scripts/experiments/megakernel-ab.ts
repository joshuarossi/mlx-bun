// Paired same-process A/B: baseline (MLX-ops decode) vs megakernel, interleaved
// and repeated, reporting the median ratio so machine state cancels
// ([[dirty-machine-numbers-are-garbage]] — only paired ratios survive load).
//   MLX_BUN_MEGAKERNEL_TGN=256 G=48 REPS=5 bun scripts/experiments/megakernel-ab.ts
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "../../src/model/megakernel-kernel";
import { argmaxLastPosition } from "../../src/model/gemma4-base";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";

const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5)) as any;
const golden = await Bun.file("goldens/minicpm5-parity.json").json();
const G = Number(process.env.G || 48);
const STEPS = Number(process.env.STEPS || 64);
const REPS = Number(process.env.REPS || 5);
const tok = (i: number) => golden.greedy_ids[i % golden.greedy_ids.length]!;

function baseDecode(): number {
  const cache = model.makeCache();
  let logits = model.forward(golden.prompt_ids, cache);
  let next = argmaxLastPosition(logits); logits.dispose();
  for (let i = 0; i < 3; i++) { logits = model.forward([next], cache); next = argmaxLastPosition(logits); logits.dispose(); }
  const t0 = performance.now();
  for (let i = 0; i < STEPS; i++) { logits = model.forward([tok(i)], cache); next = argmaxLastPosition(logits); logits.dispose(); } // argmax forces eval (MLX is lazy)
  const dt = performance.now() - t0;
  for (const c of cache) c.dispose();
  return STEPS / (dt / 1000);
}
function megaDecode(): number {
  const r = new MegakernelRunner(model, 1024, G);
  for (const t of golden.prompt_ids) r.decodeStep(t).dispose();
  for (let i = 0; i < 3; i++) r.decodeStep(tok(i)).dispose();
  const t0 = performance.now();
  for (let i = 0; i < STEPS; i++) r.decodeStep(tok(i)).dispose();
  const dt = performance.now() - t0; r.dispose();
  return STEPS / (dt / 1000);
}

const base: number[] = [], mega: number[] = [];
for (let rep = 0; rep < REPS; rep++) { base.push(baseDecode()); mega.push(megaDecode()); }
const med = (a: number[]) => a.slice().sort((x, y) => x - y)[Math.floor(a.length / 2)]!;
const b = med(base), m = med(mega);
console.log(`TGN=${process.env.MLX_BUN_MEGAKERNEL_TGN || 256} G=${G}  REPS=${REPS}`);
console.log(`baseline  median ${b.toFixed(1)} tok/s  (${base.map(x => x.toFixed(0)).join(",")})`);
console.log(`megakernel median ${m.toFixed(1)} tok/s  (${mega.map(x => x.toFixed(0)).join(",")})`);
console.log(`ratio megakernel/baseline = ${(m / b).toFixed(3)}×`);
