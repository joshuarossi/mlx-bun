import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import * as ops from "../../src/mlx/ops";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { fusedSwiglu } from "../../src/model/fused-swiglu-kernel";

const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const config = await loadModelConfig(SNAP);
const weights = await Weights.open(SNAP);
const model = new MiniCPM5Model(weights, config) as any;
const mlp = model.layers[0].mlp;
console.log("gate.w", mlp.gate.w.dtype, mlp.gate.w.shape);
console.log("gate.scales", mlp.gate.scales.dtype, mlp.gate.scales.shape);
console.log("gate.biases", mlp.gate.biases?.dtype, mlp.gate.biases?.shape);
console.log("gate.spec", JSON.stringify(mlp.gate.spec), "up.spec", JSON.stringify(mlp.up.spec));
const Hdim = mlp.gate.scales.shape[1] * mlp.gate.spec.groupSize;
const I = mlp.gate.w.shape[0];
console.log("H=", Hdim, "I=", I);

const xs = new Float32Array(6 * Hdim);
for (let i = 0; i < xs.length; i++) xs[i] = Math.sin(i * 0.7) * 0.5;
const x = MlxArray.fromFloat32(xs, [6, Hdim]).astype(Dtype.bfloat16);

const gate = mlp.gate.forward(x);
const up = mlp.up.forward(x);
const sig = ops.sigmoid(gate);
const silu = ops.mul(gate, sig);
const refHidden = ops.mul(silu, up);
const ref = refHidden.astype(Dtype.float32).toFloat32();

const fused = fusedSwiglu(x, mlp.gate.w, mlp.gate.scales, mlp.gate.biases, mlp.up.w, mlp.up.scales, mlp.up.biases, mlp.gate.spec);
const fb = fused.astype(Dtype.float32).toFloat32();

let maxDiff = 0, nanCount = 0;
for (let i = 0; i < ref.length; i++) {
  if (Number.isNaN(fb[i]!)) { nanCount++; continue; }
  maxDiff = Math.max(maxDiff, Math.abs(ref[i]! - fb[i]!));
}
console.log("hidden len", ref.length, "(I*6 =", I*6, ")");
console.log("ref[0..4]  ", Array.from(ref.slice(0,5)).map(v=>v.toFixed(4)).join(" "));
console.log("fused[0..4]", Array.from(fb.slice(0,5)).map(v=>v.toFixed(4)).join(" "));
console.log("maxDiff(non-nan)=", maxDiff, "fusedNaN=", nanCount, "/", ref.length);
