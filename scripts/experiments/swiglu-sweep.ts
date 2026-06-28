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
const Hdim = model.layers[0].mlp.gate.scales.shape[1] * model.layers[0].mlp.gate.spec.groupSize;
const xs = new Float32Array(6 * Hdim);
for (let i = 0; i < xs.length; i++) xs[i] = Math.sin(i * 0.7) * 0.5;
const x = MlxArray.fromFloat32(xs, [6, Hdim]).astype(Dtype.bfloat16);

for (let L = 0; L < model.layers.length; L++) {
  const mlp = model.layers[L].mlp;
  const gate = mlp.gate.forward(x), up = mlp.up.forward(x);
  const sig = ops.sigmoid(gate), silu = ops.mul(gate, sig);
  const ref = ops.mul(silu, up).astype(Dtype.float32).toFloat32();
  const fb = fusedSwiglu(x, mlp.gate.w, mlp.gate.scales, mlp.gate.biases, mlp.up.w, mlp.up.scales, mlp.up.biases, mlp.gate.spec).astype(Dtype.float32).toFloat32();
  let maxDiff = 0, nan = 0;
  for (let i = 0; i < ref.length; i++) { if (Number.isNaN(fb[i]!)) nan++; else maxDiff = Math.max(maxDiff, Math.abs(ref[i]!-fb[i]!)); }
  console.log(`L${String(L).padStart(2)} bits=${mlp.gate.spec.bits} gs=${mlp.gate.spec.groupSize}  maxDiff=${maxDiff.toExponential(3)}  NaN=${nan}/${ref.length}`);
}
