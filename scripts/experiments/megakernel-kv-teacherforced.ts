// Phase 4 (L2) correctness gate: drive 100 decode steps through the megakernel with
// in-kernel quantized KV (MLX_BUN_MEGAKERNEL_KVQUANT=1), teacher-forced on the optiq
// mixed-precision-KV golden (goldens/minicpm5-kv-parity.json + minicpm5-kv-logits-step*.bin).
//   MLX_BUN_MEGAKERNEL_KVQUANT=1 bun scripts/experiments/megakernel-kv-teacherforced.ts
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner, USE_KVQUANT } from "../../src/model/megakernel-kernel";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";

const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5));
const golden = await Bun.file("goldens/minicpm5-kv-parity.json").json();
const STEPS = Number(process.env.STEPS || 100);
console.log(`KVQUANT mode: ${USE_KVQUANT} (set MLX_BUN_MEGAKERNEL_KVQUANT=1 for L2)`);

async function run(): Promise<{ agree: number; maxDiff: number; kl: number; nan: boolean }> {
  const runner = new MegakernelRunner(model);
  const prompt: number[] = golden.prompt_ids;
  let logits = runner.decodeStep(prompt[0]!);
  for (let i = 1; i < prompt.length; i++) { logits.dispose(); logits = runner.decodeStep(prompt[i]!); }

  let agree = 0, sumMaxDiff = 0, sumKL = 0, nan = false;
  for (let step = 0; step < STEPS; step++) {
    const ours = logits.toFloat32();
    const ref = new Float32Array(await Bun.file(`goldens/minicpm5-kv-logits-step${step}.bin`).arrayBuffer());
    let md = 0, argmax = 0, best = -Infinity;
    for (let i = 0; i < ref.length; i++) {
      if (Number.isNaN(ours[i]!)) nan = true;
      md = Math.max(md, Math.abs(ours[i]! - ref[i]!));
      if (ours[i]! > best) { best = ours[i]!; argmax = i; }
    }
    sumMaxDiff += md;
    let mr = -Infinity, mo = -Infinity;
    for (let i = 0; i < ref.length; i++) { if (ref[i]! > mr) mr = ref[i]!; if (ours[i]! > mo) mo = ours[i]!; }
    let zr = 0, zo = 0;
    for (let i = 0; i < ref.length; i++) { zr += Math.exp(ref[i]! - mr); zo += Math.exp(ours[i]! - mo); }
    let kl = 0;
    for (let i = 0; i < ref.length; i++) { const pr = Math.exp(ref[i]! - mr) / zr; if (pr > 1e-12) kl += pr * Math.log(pr / Math.max(Math.exp(ours[i]! - mo) / zo, 1e-30)); }
    sumKL += kl;
    if (argmax === golden.greedy_ids[step]) agree++;
    logits.dispose();
    if (step + 1 < STEPS) logits = runner.decodeStep(golden.greedy_ids[step]!);
  }
  runner.dispose();
  return { agree, maxDiff: sumMaxDiff / STEPS, kl: sumKL / STEPS, nan };
}

const r1 = await run();
console.log(`run1: agree ${r1.agree}/${STEPS}  meanMaxDiff ${r1.maxDiff.toFixed(4)}  meanKL ${r1.kl.toExponential(3)}  nan=${r1.nan}`);
const r2 = await run();
console.log(`run2: agree ${r2.agree}/${STEPS}  meanMaxDiff ${r2.maxDiff.toFixed(4)}  meanKL ${r2.kl.toExponential(3)}  nan=${r2.nan}`);
// L2 is an L3-class path: the megakernel's qmv4 GEMV differs from mlx's quantized_matmul
// by ~1 bf16 ULP (== L1's 9.7e-4 residual), and quantization DISCONTINUITY amplifies that
// ULP at q-level/group boundaries (root cause confirmed: megakernel-kv-cmpl1/cmpkv.ts).
// So gate by KL + teacher-forced agreement (like perf-kernel-oracle), NOT the bit-exact
// golden. ~93/100 + KL ~1.4e-2 is the megakernel L2 ceiling.
const deterministic = r1.agree === r2.agree && Math.abs(r1.maxDiff - r2.maxDiff) < 1e-6;
const pass = r1.agree >= 90 && r1.kl < 2e-2 && !r1.nan && deterministic;
console.log(`\nPhase 4 L2 gate: ${pass ? "PASS" : "FAIL"}  (L3-class: need ≥90/${STEPS} + meanKL<2e-2 vs optiq mixed-KV golden, deterministic, no NaN; deterministic=${deterministic})`);
process.exit(pass ? 0 : 1);
