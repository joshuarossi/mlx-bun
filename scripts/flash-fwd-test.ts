// Validate the flash-attention FORWARD shader against mlx-bun's stock ops.sdpa
// on e4b-like dims (head_dim 256, GQA 16/2 heads, causal). Flash uses online
// softmax (fp32 accum, fp16 store) so it won't be bit-identical to one-shot
// SDPA, but a small max-abs-diff confirms the shader compiles + computes
// attention correctly. Bit-exact-vs-optiq is a separate cross-runtime check.
//
//   bun scripts/flash-fwd-test.ts

import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { flashForward } from "../src/model/flash-attention";

const D = 256, T = 64, Hq = 16, Hkv = 2;
const mkRand = (shape: number[], seed: number): MlxArray =>
  ops.randomNormal(shape, Dtype.float32, 0, 1, ops.randomKey(BigInt(seed))).astype(Dtype.float16);

const q = mkRand([1, Hq, T, D], 1);
const k = mkRand([1, Hkv, T, D], 2);
const v = mkRand([1, Hkv, T, D], 3);
const scale = 1 / Math.sqrt(D);

const [O, L] = flashForward(q, k, v, scale, true);
const Oref = ops.sdpa(q, k, v, scale, "causal", null);

const a = O.astype(Dtype.float32).toFloat32();
const b = Oref.astype(Dtype.float32).toFloat32();
let maxDiff = 0;
for (let i = 0; i < a.length; i++) maxDiff = Math.max(maxDiff, Math.abs(a[i]! - b[i]!));

console.log(`flash O shape [${O.shape.join(",")}], L shape [${L.shape.join(",")}]`);
console.log(`flash[0..4]=${[...a.slice(0, 4)].map((x) => x.toFixed(4))}`);
console.log(`sdpa [0..4]=${[...b.slice(0, 4)].map((x) => x.toFixed(4))}`);
console.log(`max abs diff = ${maxDiff.toExponential(3)}  → ${maxDiff < 0.05 ? "PASS (shader computes attention)" : "FAIL"}`);
