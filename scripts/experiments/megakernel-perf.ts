// Paired decode tok/s: baseline (MLX-ops forward) vs megakernel at a given G.
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "./megakernel-kernel";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";
const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5));
const golden = await Bun.file("goldens/minicpm5-parity.json").json();
const G = Number(process.env.G || 8);
const STEPS = Number(process.env.STEPS || 64);
const tok = (i: number) => golden.greedy_ids[i % golden.greedy_ids.length]!; // fixed decode tokens
function megakernel(): number {
  const r = new MegakernelRunner(model, 1024, G);
  for (let i=0;i<golden.prompt_ids.length;i++) r.decodeStep(golden.prompt_ids[i]!).dispose();
  for (let i=0;i<3;i++) r.decodeStep(tok(i)).dispose(); // warm (decodeStep evalAll forces the kernel)
  const t0=performance.now();
  for (let i=0;i<STEPS;i++) r.decodeStep(tok(i)).dispose();
  const dt=performance.now()-t0; r.dispose();
  return STEPS/(dt/1000);
}
const a=megakernel(), b=megakernel();
console.log(`G=${G}  megakernel decode: ${a.toFixed(1)} / ${b.toFixed(1)} tok/s  (${(1000/a).toFixed(2)} ms/tok)   [baseline ~222 tok/s, floor ~394]`);
