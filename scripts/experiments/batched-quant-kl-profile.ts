// Gate-2 diagnosis: per-step KL profile of each batched row vs its solo
// serial-quantized run, teacher-forced. Where does divergence start —
// step 0 (systematic), at B's join (batched-forward numerics), or noise?
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { maybeQuantizeKv } from "../../src/generate";
import { lastPositionLogits, argmaxLastPosition } from "../../src/model/gemma4";
import { BatchScheduler } from "../../src/serve/batch-scheduler";
import { goldenAt } from "../../tests/goldens";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";
import * as ops from "../../src/mlx/ops";
import { clearCache } from "../../src/mlx/ffi";
import type { MlxArray } from "../../src/mlx/array";

const golden = (await goldenAt("mixed-kv-cpm.json").json()) as { prompt_ids: number[] };
const BF16 = process.env.PROFILE_BF16 === "1"; // A/B: same harness, no quantization
const config = await loadModelConfig(SNAPSHOT_MINICPM5);
const weights = await Weights.open(SNAPSHOT_MINICPM5);
const model = createModel(weights, config);
const STEPS = 32;

const solo = async (ids: number[]) => {
  const kvOpts = BF16 ? {} : { kvConfig: config.kvQuant!, quantizedKvStart: 0 };
  const cache = model.makeCache();
  const toks: number[] = [];
  const logits: Float32Array[] = [];
  let l = model.forward(ids, cache);
  logits.push(lastPositionLogits(l));
  toks.push(argmaxLastPosition(l));
  l.dispose();
  maybeQuantizeKv(cache, kvOpts);
  for (let s = 1; s < STEPS; s++) {
    l = model.forward([toks[s - 1]!], cache);
    logits.push(lastPositionLogits(l));
    toks.push(argmaxLastPosition(l));
    l.dispose();
  }
  for (const c of cache) c.dispose();
  clearCache();
  return { toks, logits };
};

const klDiv = (x: Float32Array, y: Float32Array): number => {
  let mx = -Infinity, my = -Infinity;
  for (let i = 0; i < x.length; i++) { if (x[i]! > mx) mx = x[i]!; if (y[i]! > my) my = y[i]!; }
  let sx = 0, sy = 0;
  for (let i = 0; i < x.length; i++) { sx += Math.exp(x[i]! - mx); sy += Math.exp(y[i]! - my); }
  const lsx = Math.log(sx), lsy = Math.log(sy);
  let kl = 0;
  for (let i = 0; i < x.length; i++) {
    const lp = x[i]! - mx - lsx;
    const p = Math.exp(lp);
    if (p > 0) kl += p * (lp - (y[i]! - my - lsy));
  }
  return kl;
};
const maxAbs = (x: Float32Array, y: Float32Array): number => {
  let m = 0;
  for (let i = 0; i < x.length; i++) m = Math.max(m, Math.abs(x[i]! - y[i]!));
  return m;
};

const promptA = golden.prompt_ids;
const promptB = golden.prompt_ids.slice(0, Math.floor(golden.prompt_ids.length / 2));
const refA = await solo(promptA);
const refB = await solo(promptB);

const sched = new BatchScheduler(model, { maxBatch: 2, ...(BF16 ? {} : { kvConfig: config.kvQuant! }) });
const stepsAtB: number[] = []; // how many steps A had done when B's sampler first ran
const mk = (forced: number[], sink: Float32Array[], other?: Float32Array[]) => {
  let step = 0;
  return {
    promptIds: step === 0 && other ? promptB : promptA, // overwritten below
    maxTokens: STEPS, eosTokenIds: [], plainGreedy: false,
    sample: (lp: MlxArray) => {
      if (other && step === 0) stepsAtB.push(other.length);
      sink.push(lp.toFloat32());
      return ops.fromInt32([forced[step++]!], [1]);
    },
    onToken: () => true,
  };
};
const gotA: Float32Array[] = [];
const gotB: Float32Array[] = [];
const reqA = { ...mk(refA.toks, gotA), promptIds: promptA };
const reqB = { ...mk(refB.toks, gotB, gotA), promptIds: promptB };
const pa = sched.submit(reqA);
// JOIN_AT=K pins the join deterministically: B submits once A has produced
// K logits (default: the old 50 ms wall-clock race).
const joinAt = Number(process.env.JOIN_AT ?? 0);
if (joinAt > 0) while (gotA.length < joinAt) await new Promise((r) => setTimeout(r, 2));
else await new Promise((r) => setTimeout(r, 50));
const pb = sched.submit(reqB);
await Promise.all([pa, pb]);
clearCache();

console.log(`B joined when A had produced ~${stepsAtB[0]} steps`);
for (const [got, ref, label] of [[gotA, refA.logits, "A"], [gotB, refB.logits, "B"]] as const) {
  const kls = got.map((g, s) => klDiv(ref[s]!, g));
  const abs = got.map((g, s) => maxAbs(ref[s]!, g));
  const firstNonzero = abs.findIndex((x) => x > 0);
  console.log(`row ${label}: first nonzero-diff step ${firstNonzero}; ` +
    `KL by step: ${kls.map((k) => k < 1e-9 ? "0" : k.toExponential(1)).join(" ")}`);
}
