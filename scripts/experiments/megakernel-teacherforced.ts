// Phase 2 correctness gate: drive 100 decode steps through the megakernel,
// teacher-forced on goldens/minicpm5-parity.json. Require ≥98/100 argmax
// agreement, deterministic across runs, no NaN.  bun scripts/experiments/megakernel-teacherforced.ts
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "./megakernel-kernel";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";

const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5));
const golden = await Bun.file("goldens/minicpm5-parity.json").json();
const STEPS = Number(process.env.STEPS || 100);

async function run(): Promise<{ agree: number; maxDiff: number; kl: number; nan: boolean }> {
  const runner = new MegakernelRunner(model);
  // Sequential M=1 over the prompt == prefill: the logits after feeding the last
  // prompt token predict the next token (== golden step 0).
  const prompt: number[] = golden.prompt_ids;
  let logits = runner.decodeStep(prompt[0]!);
  for (let i = 1; i < prompt.length; i++) { logits.dispose(); logits = runner.decodeStep(prompt[i]!); }

  let agree = 0, sumMaxDiff = 0, sumKL = 0, nan = false;
  for (let step = 0; step < STEPS; step++) {
    const ours = logits.toFloat32(); // [1,V] → V
    const ref = new Float32Array(await Bun.file(`goldens/minicpm5-logits-step${step}.bin`).arrayBuffer());
    let md = 0, argmax = 0, best = -Infinity;
    for (let i = 0; i < ref.length; i++) {
      if (Number.isNaN(ours[i]!)) nan = true;
      md = Math.max(md, Math.abs(ours[i]! - ref[i]!));
      if (ours[i]! > best) { best = ours[i]!; argmax = i; }
    }
    sumMaxDiff += md;
    // KL(ref || ours)
    let mr = -Infinity, mo = -Infinity;
    for (let i = 0; i < ref.length; i++) { if (ref[i]! > mr) mr = ref[i]!; if (ours[i]! > mo) mo = ours[i]!; }
    let zr = 0, zo = 0;
    for (let i = 0; i < ref.length; i++) { zr += Math.exp(ref[i]! - mr); zo += Math.exp(ours[i]! - mo); }
    let kl = 0;
    for (let i = 0; i < ref.length; i++) { const pr = Math.exp(ref[i]! - mr) / zr; if (pr > 1e-12) kl += pr * Math.log(pr / Math.max(Math.exp(ours[i]! - mo) / zo, 1e-30)); }
    sumKL += kl;
    if (argmax === golden.greedy_ids[step]) agree++;
    logits.dispose();
    if (step + 1 < STEPS) logits = runner.decodeStep(golden.greedy_ids[step]!); // teacher-force
  }
  runner.dispose();
  return { agree, maxDiff: sumMaxDiff / STEPS, kl: sumKL / STEPS, nan };
}

const r1 = await run();
console.log(`run1: agree ${r1.agree}/${STEPS}  meanMaxDiff ${r1.maxDiff.toFixed(4)}  meanKL ${r1.kl.toExponential(3)}  nan=${r1.nan}`);
const r2 = await run();
console.log(`run2: agree ${r2.agree}/${STEPS}  meanMaxDiff ${r2.maxDiff.toFixed(4)}  meanKL ${r2.kl.toExponential(3)}  nan=${r2.nan}`);
const deterministic = r1.agree === r2.agree && Math.abs(r1.maxDiff - r2.maxDiff) < 1e-6;
const pass = r1.agree >= 98 && !r1.nan && deterministic;
console.log(`\nPhase 2 gate: ${pass ? "PASS" : "FAIL"}  (need ≥98/${STEPS}, deterministic, no NaN; deterministic=${deterministic})`);
process.exit(pass ? 0 : 1);
