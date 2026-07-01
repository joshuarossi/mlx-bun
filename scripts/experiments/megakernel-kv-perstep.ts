// Per-step divergence diagnostic for L2: which steps' argmax/KL diverge from the
// optiq mixed-KV golden? Isolates prefill (step 0, bf16 prompt in golden) vs decode.
//   MLX_BUN_MEGAKERNEL_KVQUANT=1 bun scripts/experiments/megakernel-kv-perstep.ts
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "./megakernel-kernel";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";

const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5));
const golden = await Bun.file("goldens/minicpm5-kv-parity.json").json();
const STEPS = Number(process.env.STEPS || 100);

const runner = new MegakernelRunner(model);
const prompt: number[] = golden.prompt_ids;
let logits = runner.decodeStep(prompt[0]!);
for (let i = 1; i < prompt.length; i++) { logits.dispose(); logits = runner.decodeStep(prompt[i]!); }

function kl(ours: Float32Array, ref: Float32Array): number {
  let mr = -Infinity, mo = -Infinity;
  for (let i = 0; i < ref.length; i++) { if (ref[i]! > mr) mr = ref[i]!; if (ours[i]! > mo) mo = ours[i]!; }
  let zr = 0, zo = 0;
  for (let i = 0; i < ref.length; i++) { zr += Math.exp(ref[i]! - mr); zo += Math.exp(ours[i]! - mo); }
  let k = 0;
  for (let i = 0; i < ref.length; i++) { const pr = Math.exp(ref[i]! - mr) / zr; if (pr > 1e-12) k += pr * Math.log(pr / Math.max(Math.exp(ours[i]! - mo) / zo, 1e-30)); }
  return k;
}
const diverged: number[] = [];
for (let step = 0; step < STEPS; step++) {
  const ours = logits.toFloat32();
  const ref = new Float32Array(await Bun.file(`goldens/minicpm5-kv-logits-step${step}.bin`).arrayBuffer());
  let am = 0, best = -Infinity, md = 0;
  for (let i = 0; i < ref.length; i++) { if (ours[i]! > best) { best = ours[i]!; am = i; } md = Math.max(md, Math.abs(ours[i]! - ref[i]!)); }
  const k = kl(ours, ref);
  const agree = am === golden.greedy_ids[step];
  if (!agree || k > 5e-3) { diverged.push(step); console.log(`step ${step}: agree=${agree} ours_argmax=${am} golden=${golden.greedy_ids[step]} maxDiff=${md.toFixed(3)} KL=${k.toExponential(2)}`); }
  logits.dispose();
  if (step + 1 < STEPS) logits = runner.decodeStep(golden.greedy_ids[step]!);
}
runner.dispose();
console.log(`\n${diverged.length} steps diverged (argmax flip or KL>5e-3): [${diverged.join(",")}]`);
