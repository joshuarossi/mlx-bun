// Phase 4 step 1: validate my transcription of mlx's affine_quantize formula
// (quantized.h:2432) against ops.quantize/ops.dequantize, so the in-kernel KV
// quantize is known-correct before integration. group_size=64 (KV), bits 4 & 8.
//   bun scripts/experiments/kv-quant-formula-check.ts
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";

const GS = 64, D = 128, ROWS = 8;

// mlx affine_quantize formula, per group (quantized.h:2432-2496)
function quantGroup(w: number[], bits: number): { scale: number; bias: number; q: number[] } {
  const nBins = (1 << bits) - 1, eps = 1e-7;
  // mlx inits w_min=Limits<T>::max, w_max=0, then min/max over the group.
  let wmin = Infinity, wmax = 0;
  for (const v of w) { wmin = Math.min(wmin, v); wmax = Math.max(wmax, v); }
  let scale = Math.max((wmax - wmin) / nBins, eps);
  const side = Math.abs(wmin) > Math.abs(wmax);
  scale = side ? scale : -scale;
  const edge = side ? wmin : wmax;
  const q0 = Math.round(edge / scale);
  scale = q0 === 0 ? scale : edge / q0;
  const bias = q0 === 0 ? 0 : edge;
  const q = w.map((v) => Math.min(Math.round((v - bias) / scale), nBins));
  return { scale, bias, q };
}

const f32 = new Float32Array(ROWS * D);
for (let i = 0; i < f32.length; i++) f32[i] = (Math.sin(i * 12.9898) * 43758.5453 % 1) * 4 - 2; // deterministic [-2,2)
const x = MlxArray.fromFloat32(f32, [ROWS, D]).astype(Dtype.bfloat16);
const xf = x.toFloat32(); // bf16-rounded values (what mlx quantizes)

for (const bits of [4, 8]) {
  const q = ops.quantize(x, GS, bits);
  const deqMlx = ops.dequantize(q.packed, q.scales, q.biases, { groupSize: GS, bits, mode: "affine" }).toFloat32();
  // my JS dequant from the formula
  let maxDiff = 0, maxScaleDiff = 0;
  const scMlx = q.scales.toFloat32(), biMlx = q.biases.toFloat32();
  const nGroups = D / GS;
  for (let r = 0; r < ROWS; r++) for (let g = 0; g < nGroups; g++) {
    const base = r * D + g * GS;
    const grp = Array.from({ length: GS }, (_, k) => xf[base + k]!);
    const { scale, bias, q: qj } = quantGroup(grp, bits);
    const sIdx = r * nGroups + g;
    maxScaleDiff = Math.max(maxScaleDiff, Math.abs(scale - scMlx[sIdx]!), Math.abs(bias - biMlx[sIdx]!));
    for (let k = 0; k < GS; k++) maxDiff = Math.max(maxDiff, Math.abs((scale * qj[k]! + bias) - deqMlx[base + k]!));
  }
  console.log(`bits=${bits}: maxScale/biasDiff=${maxScaleDiff.toExponential(2)}  max dequant diff (JS formula vs ops round-trip)=${maxDiff.toExponential(2)}`);
  q.packed.dispose(); q.scales.dispose(); q.biases.dispose();
}
console.log("(diffs ~bf16 ULP ⇒ formula transcription correct)");
