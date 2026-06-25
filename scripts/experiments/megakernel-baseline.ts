// Phase 0: establish the MiniCPM5 decode baseline (paired, same-process) and
// confirm the existing forward passes the teacher-forced golden gate. Grounds
// the megakernel perf target. Run:
//   bun scripts/experiments/megakernel-baseline.ts
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { argmaxLastPosition, lastPositionLogits } from "../../src/model/gemma4-base";
import * as ops from "../../src/mlx/ops";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";

const SNAP = SNAPSHOT_MINICPM5;
const model = new MiniCPM5Model(await Weights.open(SNAP), await loadModelConfig(SNAP)) as any;
const golden = await Bun.file("goldens/minicpm5-parity.json").json();

// --- Correctness: teacher-forced argmax agreement vs goldens ---
{
  const cache = model.makeCache();
  let tokens = golden.prompt_ids;
  let agree = 0;
  for (let step = 0; step < 100; step++) {
    const logits = model.forward(tokens, cache);
    if (argmaxLastPosition(logits) === golden.greedy_ids[step]) agree++;
    logits.dispose();
    tokens = [golden.greedy_ids[step]!];
  }
  for (const c of cache) c.dispose();
  console.log(`baseline teacher-forced argmax agreement: ${agree}/100`);
}

// --- Perf: decode tok/s. Prefill the prompt, then time N greedy decode steps. ---
function timeDecode(label: string, steps: number): number {
  const cache = model.makeCache();
  // prefill
  let logits = model.forward(golden.prompt_ids, cache);
  let next = argmaxLastPosition(logits);
  logits.dispose();
  // warm a couple
  for (let i = 0; i < 3; i++) {
    logits = model.forward([next], cache);
    next = argmaxLastPosition(logits);
    logits.dispose();
  }
  const t0 = performance.now();
  for (let i = 0; i < steps; i++) {
    logits = model.forward([next], cache);
    next = argmaxLastPosition(logits);
    logits.dispose();
  }
  const dt = performance.now() - t0;
  for (const c of cache) c.dispose();
  const toks = steps / (dt / 1000);
  console.log(`${label}: ${steps} steps in ${dt.toFixed(1)}ms  =>  ${toks.toFixed(1)} tok/s  (${(dt / steps).toFixed(2)} ms/tok)`);
  return toks;
}

const STEPS = Number(process.env.STEPS || 64);
timeDecode("baseline decode", STEPS);
timeDecode("baseline decode (rerun)", STEPS);
