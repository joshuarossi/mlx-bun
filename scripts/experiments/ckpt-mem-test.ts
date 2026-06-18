// Does the Checkpoint primitive actually REDUCE backward memory? A deep stack
// of MLP layers (big intermediates) differentiated with value_and_grad, peak
// measured with per-layer checkpointing ON vs OFF. Effective checkpointing
// should make peak ~independent of depth (one layer's interior live at a time).
//
//   CKPT=1 bun scripts/ckpt-mem-test.ts   # checkpointed
//   CKPT=0 bun scripts/ckpt-mem-test.ts   # not

import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { Checkpoint } from "../../src/mlx/checkpoint";
import { evalAll } from "../../src/mlx/ops";
import { peakMemory, resetPeakMemory, activeMemory, cacheMemory, clearCache } from "../../src/mlx/ffi";

const L = Number(process.env.L ?? 4096);
const D = Number(process.env.D ?? 2048);
const LAYERS = Number(process.env.LAYERS ?? 32);
const CKPT = process.env.CKPT !== "0";
const gb = (b: number) => `${(b / 1e9).toFixed(2)} GB`;

const mk = (shape: number[], s: number) =>
  ops.mulScalar(ops.randomNormal(shape, Dtype.float32, 0, 1, ops.randomKey(BigInt(s))), 0.02);
// FROZEN big weights (NOT grad'd) + tiny trainable scale per layer — the LoRA
// case: params/grads small, ACTIVATIONS dominate. Checkpointing should give a
// big reduction here if it works.
const W1 = Array.from({ length: LAYERS }, (_, i) => mk([D, 4 * D], 100 + i));
const W2 = Array.from({ length: LAYERS }, (_, i) => mk([4 * D, D], 200 + i));
const SCALES = Array.from({ length: LAYERS }, () => MlxArray.fromFloat32(new Float32Array([1.0]), [1]));
evalAll([...W1, ...W2, ...SCALES]); // materialize weights to leaves (no lingering randn intermediates)

const sumAll = (a: MlxArray) => ops.sumAxis(ops.reshape(a, [a.size]), 0, false);

const ZERO = MlxArray.fromFloat32(new Float32Array([0]), []);
// one MLP layer: h + scale * W2( relu(h @ W1) ). W1/W2 frozen (captured), scale
// is the trainable input. Dispose intermediates (mlx-bun needs this).
function layer(h: MlxArray, scale: MlxArray, w1: MlxArray, w2: MlxArray): MlxArray {
  const hw1 = ops.matmul(h, w1);
  const mid = ops.maximum(hw1, ZERO); hw1.dispose();   // [L, 4D] relu
  const out = ops.matmul(mid, w2); mid.dispose();        // [L, D]
  const scaled = ops.mul(out, scale); out.dispose();
  const res = ops.add(h, scaled); scaled.dispose();
  return res;
}

// ONE reused checkpoint closure (like Python/mlx-lm's class-level patch),
// vs a fresh one per layer (REUSE=0). Hypothesis: reuse lets mlx stream.
const REUSE = process.env.REUSE !== "0";
const sharedCk = new Checkpoint((ins) => [layer(ins[0]!, ins[1]!, ins[2]!, ins[3]!)]);

function loss(scales: MlxArray[]): MlxArray {
  let h = mk([L, D], 7);
  for (let i = 0; i < LAYERS; i++) {
    if (CKPT) {
      const ck = REUSE ? sharedCk : new Checkpoint((ins) => [layer(ins[0]!, ins[1]!, ins[2]!, ins[3]!)]);
      const next = ck.apply([h, scales[i]!, W1[i]!, W2[i]!])[0]!;
      h.dispose(); h = next;
    } else {
      const next = layer(h, scales[i]!, W1[i]!, W2[i]!);
      h.dispose(); h = next;
    }
  }
  return sumAll(h);
}

// ---------------------------------------------------------------------------
// SEGMENTED BACKWARD: forward saving detached boundary activations at segment
// edges, then backprop segment-by-segment (reverse) via a surrogate-loss
// value_and_grad (chunked-CE trick). Only ONE segment's activations are live at
// a time -> peak bounded by segment size, NOT the whole stack. dscales match
// the full gradient exactly (reverse-mode AD done in segments).
// ---------------------------------------------------------------------------
function segmentedBackward(segSize: number): { value: number; dscales: number[] } {
  const nSeg = Math.ceil(LAYERS / segSize);
  // Forward: materialize + detach a boundary at each segment edge.
  const boundaries: MlxArray[] = [];
  let h0 = mk([L, D], 7);
  h0 = ops.stopGradient(h0); h0.eval();
  boundaries.push(h0);
  for (let k = 0; k < nSeg; k++) {
    const lo = k * segSize, hi = Math.min(lo + segSize, LAYERS);
    let cur = boundaries[k]!;
    for (let i = lo; i < hi; i++) {
      const next = layer(cur, SCALES[i]!, W1[i]!, W2[i]!);
      if (i > lo) cur.dispose(); // dispose intra-segment, keep the boundary leaf
      cur = next;
    }
    cur = ops.stopGradient(cur); cur.eval();
    boundaries.push(cur);
  }
  const lossArr = sumAll(boundaries[nSeg]!); lossArr.eval();
  const v = lossArr.toFloat32()[0]!; lossArr.dispose();

  // Backward: reverse over segments.
  const dscales: number[] = new Array(LAYERS);
  let dhOut: MlxArray | null = null;
  for (let k = nSeg - 1; k >= 0; k--) {
    const lo = k * segSize, hi = Math.min(lo + segSize, LAYERS);
    const segLen = hi - lo;
    const isLast = k === nSeg - 1;
    const dh = dhOut;
    const argn = Array.from({ length: segLen + 1 }, (_, i) => i);
    const vag = new ValueAndGrad((p) => {
      let hh = p[0]!;
      for (let j = 0; j < segLen; j++) {
        const next = layer(hh, p[1 + j]!, W1[lo + j]!, W2[lo + j]!);
        if (j > 0) hh.dispose();
        hh = next;
      }
      if (isLast) return sumAll(hh);
      const prod = ops.mul(ops.stopGradient(dh!), hh); // surrogate = sum(dh ⊙ output)
      return sumAll(prod);
    }, argn);
    const { grads } = vag.apply([boundaries[k]!, ...SCALES.slice(lo, hi)]);
    evalAll(grads);
    if (dhOut) dhOut.dispose();
    dhOut = grads[0]!; // grad w.r.t. segment input == dh_out for the earlier segment
    for (let j = 0; j < segLen; j++) dscales[lo + j] = grads[1 + j]!.toFloat32()[0]!;
    for (let j = 0; j < segLen; j++) grads[1 + j]!.dispose();
    vag.dispose();
    boundaries[k]!.dispose(); // consumed by this segment's backward
  }
  if (dhOut) dhOut.dispose();
  return { value: v, dscales };
}

const SEG = process.env.SEG ? Number(process.env.SEG) : 0;
const params = SCALES;
const argnums = params.map((_, i) => i);
console.log(`### ckpt-mem-test L=${L} D=${D} layers=${LAYERS} CKPT=${CKPT} SEG=${SEG || "off"}`);

if (SEG > 0) {
  // Correctness: full grads first (copy to JS, dispose), then segmented.
  const vagFull = new ValueAndGrad((p) => loss(p), argnums);
  const full = vagFull.apply(params);
  evalAll(full.grads);
  const fullG = full.grads.map((g) => g.toFloat32()[0]!);
  full.value.dispose(); full.grads.forEach((g) => g.dispose()); vagFull.dispose();
  clearCache();
  resetPeakMemory();
  const seg = segmentedBackward(SEG);
  console.log(`### SEGMENTED(seg=${SEG}) PEAK=${gb(peakMemory())}  active=${gb(activeMemory())}`);
  let maxRel = 0;
  for (let i = 0; i < LAYERS; i++) maxRel = Math.max(maxRel, Math.abs(seg.dscales[i]! - fullG[i]!) / (Math.abs(fullG[i]!) || 1));
  console.log(`### grad match vs full value_and_grad: maxRel=${(maxRel * 100).toFixed(3)}%  (value ${seg.value.toFixed(2)})`);
} else {
  resetPeakMemory();
  const vag = new ValueAndGrad((p) => loss(p), argnums);
  const { value, grads } = vag.apply(params);
  evalAll([value, ...grads]);
  const v = value.toFloat32()[0]!;
  console.log(`### value=${v.toFixed(2)}`);
  console.log(`### PEAK=${gb(peakMemory())}  active(live)=${gb(activeMemory())}  cache=${gb(cacheMemory())}`);
  clearCache();
  console.log(`### after clearCache: active(genuinely held)=${gb(activeMemory())}  cache=${gb(cacheMemory())}`);
}
