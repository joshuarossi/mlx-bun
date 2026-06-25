// TGN×G perf+correctness sweep. TGN is import-baked (MLX_BUN_MEGAKERNEL_TGN),
// so run this once per TGN; G is per-runner and swept in-process (model loaded once).
//   MLX_BUN_MEGAKERNEL_TGN=128 GS=48,56,64,72 bun scripts/experiments/megakernel-sweep.ts
// Down-proj tiling (MAXROWS=8) requires G*TGN >= 6144 for correctness.
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "../../src/model/megakernel-kernel";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";

const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5));
const golden = await Bun.file("goldens/minicpm5-parity.json").json();
const TGN = Number(process.env.MLX_BUN_MEGAKERNEL_TGN) || 256;
const GLIST = (process.env.GS || "32,48,64").split(",").map(Number);
const STEPS = Number(process.env.STEPS || 64);
const CHECK = Number(process.env.CHECK || 30); // teacher-forced steps for correctness
const tok = (i: number) => golden.greedy_ids[i % golden.greedy_ids.length]!;

// load step-0..CHECK goldens once for correctness
const refs: Float32Array[] = [];
for (let s = 0; s < CHECK; s++) refs.push(new Float32Array(await Bun.file(`goldens/minicpm5-logits-step${s}.bin`).arrayBuffer()));

function klOf(ours: Float32Array, ref: Float32Array): number {
  let mr = -Infinity, mo = -Infinity;
  for (let i = 0; i < ref.length; i++) { if (ref[i]! > mr) mr = ref[i]!; if (ours[i]! > mo) mo = ours[i]!; }
  let zr = 0, zo = 0;
  for (let i = 0; i < ref.length; i++) { zr += Math.exp(ref[i]! - mr); zo += Math.exp(ours[i]! - mo); }
  let kl = 0;
  for (let i = 0; i < ref.length; i++) { const pr = Math.exp(ref[i]! - mr) / zr; if (pr > 1e-12) kl += pr * Math.log(pr / Math.max(Math.exp(ours[i]! - mo) / zo, 1e-30)); }
  return kl;
}

function evalConfig(G: number): { agree: number; kl: number; tps: number } {
  const r = new MegakernelRunner(model, 1024, G);
  // teacher-forced correctness over the prompt + CHECK steps
  const prompt: number[] = golden.prompt_ids;
  let logits = r.decodeStep(prompt[0]!);
  for (let i = 1; i < prompt.length; i++) { logits.dispose(); logits = r.decodeStep(prompt[i]!); }
  let agree = 0, sumKL = 0;
  for (let s = 0; s < CHECK; s++) {
    const ours = logits.toFloat32();
    let am = 0, best = -Infinity;
    for (let i = 0; i < ours.length; i++) if (ours[i]! > best) { best = ours[i]!; am = i; }
    if (am === golden.greedy_ids[s]) agree++;
    sumKL += klOf(ours, refs[s]!);
    logits.dispose();
    if (s + 1 < CHECK) logits = r.decodeStep(golden.greedy_ids[s]!);
  }
  // perf: warm then time
  for (let i = 0; i < 3; i++) r.decodeStep(tok(i)).dispose();
  const t0 = performance.now();
  for (let i = 0; i < STEPS; i++) r.decodeStep(tok(i)).dispose();
  const dt = performance.now() - t0;
  r.dispose();
  return { agree, kl: sumKL / CHECK, tps: STEPS / (dt / 1000) };
}

console.log(`TGN=${TGN}  baseline ~216 tok/s`);
for (const G of GLIST) {
  try {
    const { agree, kl, tps } = evalConfig(G);
    const ok = agree >= CHECK - 1 ? "ok" : "BAD";
    console.log(`G=${G}\tTGN=${TGN}\t${tps.toFixed(1)} tok/s\t${(1000 / tps).toFixed(2)} ms/tok\tagree ${agree}/${CHECK} ${ok}\tKL ${kl.toExponential(2)}`);
  } catch (e) {
    console.log(`G=${G}: ERROR ${(e as Error).message?.slice(0, 80)}`);
  }
}
