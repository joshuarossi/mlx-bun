// Does creating + disposing a ValueAndGrad per iteration leak? Loop N times,
// each: build a fresh ValueAndGrad over a closure that captures a sizable
// weight, apply it, dispose everything, measure active. Flat = no leak.

import { readdirSync } from "node:fs";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { ValueAndGrad, Vjp } from "../src/mlx/autograd";
import { evalAll } from "../src/mlx/ops";
import { activeMemory, clearCache } from "../src/mlx/ffi";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { MiniCPM5Model } from "../src/model/minicpm5";

const N = Number(process.env.N ?? 8);
const D = Number(process.env.D ?? 1536);
const L = Number(process.env.L ?? 2048);
const NL = Number(process.env.NL ?? 4); // layers for MODE=layers
const MODE = process.env.MODE ?? "plain"; // plain | quant | layers
const gb = (b: number) => `${(b / 1e9).toFixed(3)} GB`;
function sumAll(a: MlxArray) { return ops.sumAxis(ops.reshape(a, [a.size]), 0, false); }

const x0 = ops.mulScalar(ops.randomNormal([1, L, D], Dtype.bfloat16, 0, 1, ops.randomKey(2n)), 0.1);
x0.eval();

let closure: (p: MlxArray[]) => MlxArray;
let cleanup = () => {};
async function loadModel() {
  const HOME = process.env.HOME!;
  const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
  const dir = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
  const config = await loadModelConfig(dir);
  const weights = await Weights.open(dir);
  const model = createModel(weights, config);
  if (!(model instanceof MiniCPM5Model)) throw new Error("expected MiniCPM5Model");
  return { model, weights };
}
if (MODE === "quant") {
  const { model, weights } = await loadModel();
  const gate = model.layers[0]!.mlp.gate;
  closure = (p) => { const h = gate.forward(p[0]!); const r = sumAll(h); h.dispose(); return r; };
  cleanup = () => weights.dispose();
  console.log(`### vag-leak-test MODE=quant N=${N} L=${L} D=${D} (quantized matmul under fresh vag)`);
} else if (MODE === "layers") {
  const { model, weights } = await loadModel();
  const { TrainingCache } = await import("../src/train/forward");
  const caches = Array.from({ length: model.layers.length }, () => new TrainingCache());
  const SURR = process.env.SURR === "1"; // surrogate loss sum(stopGrad(dh) (.) output)
  const dhConst = SURR ? ops.mulScalar(ops.randomNormal([1, L, D], Dtype.bfloat16, 0, 1, ops.randomKey(9n)), 0.01) : null;
  dhConst?.eval();
  closure = (p) => {
    const h = model.runLayerRange(p[0]!, 0, NL, caches);
    let r: MlxArray;
    if (SURR) { const sg = ops.stopGradient(dhConst!); const prod = ops.mul(sg, h); sg.dispose(); r = sumAll(prod); prod.dispose(); }
    else r = sumAll(h);
    h.dispose(); return r;
  };
  cleanup = () => { weights.dispose(); dhConst?.dispose(); };
  console.log(`### vag-leak-test MODE=layers NL=${NL} SURR=${SURR} N=${N} L=${L} D=${D}`);
} else if (MODE === "manyargs") {
  // plain matmul, but differentiate w.r.t. the input AND many small leaves that
  // are added into the result -> isolates whether high argnum count leaks.
  const NA = Number(process.env.NA ?? 56);
  const W = ops.mulScalar(ops.randomNormal([D, D], Dtype.float32, 0, 1, ops.randomKey(1n)), 0.01);
  W.eval();
  const extras = Array.from({ length: NA }, (_, i) => MlxArray.fromFloat32(new Float32Array(D).fill(0.01 * (i + 1)), [D]));
  extras.forEach((e) => e.eval());
  const argn = Array.from({ length: NA + 1 }, (_, i) => i);
  closure = (p) => {
    let h = ops.matmul(p[0]!, W); // [1,L,D]
    for (let i = 0; i < NA; i++) { const t = ops.add(h, p[1 + i]!); h.dispose(); h = t; }
    const r = sumAll(h); h.dispose(); return r;
  };
  cleanup = () => { W.dispose(); extras.forEach((e) => e.dispose()); };
  // ARGS: which inputs to differentiate. both=[0..NA], x0=[0], extras=[1..NA]
  const which = process.env.ARGS ?? "both";
  const argSel = which === "x0" ? [0] : which === "extras" ? argn.slice(1) : argn;
  console.log(`### vag-leak-test MODE=manyargs NA=${NA} ARGS=${which} (argnums=${argSel.length}) N=${N} L=${L} D=${D}`);
  (globalThis as Record<string, unknown>).__manyargs = { extras, argn: argSel };
} else {
  const W = ops.mulScalar(ops.randomNormal([D, D], Dtype.float32, 0, 1, ops.randomKey(1n)), 0.01);
  W.eval();
  closure = (p) => { const h = ops.matmul(p[0]!, W); const r = sumAll(h); h.dispose(); return r; };
  cleanup = () => W.dispose();
  console.log(`### vag-leak-test MODE=plain N=${N} L=${L} D=${D}`);
}

// MODE=vjp: drive runLayerRange via mlx_vjp (cotangent = dh) instead of a
// surrogate-loss value_and_grad — the candidate leak fix for segmented backward.
if (MODE === "vjp") {
  const { model, weights } = await loadModel();
  const { TrainingCache } = await import("../src/train/forward");
  const caches = Array.from({ length: model.layers.length }, () => new TrainingCache());
  const dh = ops.mulScalar(ops.randomNormal([1, L, D], Dtype.bfloat16, 0, 1, ops.randomKey(9n)), 0.01);
  dh.eval();
  const REUSE = process.env.REUSE === "1";
  const shared = REUSE ? new Vjp((p) => [model.runLayerRange(p[0]!, 0, NL, caches)], 1) : null;
  console.log(`### vag-leak-test MODE=vjp NL=${NL} REUSE=${REUSE} N=${N} L=${L} D=${D}`);
  for (let i = 0; i < N; i++) {
    const vjp = shared ?? new Vjp((p) => [model.runLayerRange(p[0]!, 0, NL, caches)], 1);
    const res = vjp.apply([x0], [dh]);
    evalAll([...res.outputs, ...res.vjps]);
    res.outputs.forEach((o) => o.dispose());
    res.vjps.forEach((v) => v.dispose());
    if (!shared) vjp.dispose();
    clearCache();
    console.log(`### iter ${i}: active=${gb(activeMemory())}`);
  }
  shared?.dispose();
  for (const c of caches) c.dispose();
  dh.dispose();
  x0.dispose();
  weights.dispose();
  process.exit(0);
}

const ma = (globalThis as Record<string, unknown>).__manyargs as { extras: MlxArray[]; argn: number[] } | undefined;
const argnums = ma ? ma.argn : [0];
const applyArgs = ma ? [x0, ...ma.extras] : [x0];
const REUSE = process.env.REUSE === "1";
const sharedVag = REUSE ? new ValueAndGrad(closure, argnums) : null;
console.log(`### REUSE=${REUSE}`);
for (let i = 0; i < N; i++) {
  const vag = sharedVag ?? new ValueAndGrad(closure, argnums);
  const res = vag.apply(applyArgs);
  evalAll([res.value, ...res.grads]);
  res.value.dispose();
  res.grads.forEach((g) => g.dispose());
  if (!sharedVag) vag.dispose();
  clearCache();
  console.log(`### iter ${i}: active=${gb(activeMemory())}`);
}
sharedVag?.dispose();
x0.dispose();
cleanup();
