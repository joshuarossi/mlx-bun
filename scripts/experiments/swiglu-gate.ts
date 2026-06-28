import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import * as ops from "../../src/mlx/ops";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { fusedSwiglu } from "../../src/model/fused-swiglu-kernel";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const model = new MiniCPM5Model(await Weights.open(SNAP), await loadModelConfig(SNAP)) as any;
const Hdim = 1536;
const xs = new Float32Array(6 * Hdim);
for (let i = 0; i < xs.length; i++) xs[i] = Math.sin(i * 0.7) * 0.5;
const x = MlxArray.fromFloat32(xs, [6, Hdim]).astype(Dtype.bfloat16);
for (const L of [0, 1]) {
  const mlp = model.layers[L].mlp;
  // reference: raw gate projection via mlx quantized_matmul
  const ref = mlp.gate.forward(x).astype(Dtype.float32).toFloat32();
  // fused with DEBUG_GATE writes Lg (raw gate) into hidden
  const fb = fusedSwiglu(x, mlp.gate.w, mlp.gate.scales, mlp.gate.biases, mlp.up.w, mlp.up.scales, mlp.up.biases, mlp.gate.spec).astype(Dtype.float32).toFloat32();
  let maxDiff = 0, nan = 0, worst = -1;
  for (let i = 0; i < ref.length; i++) { if (Number.isNaN(fb[i]!)) {nan++;continue;} const d=Math.abs(ref[i]!-fb[i]!); if(d>maxDiff){maxDiff=d;worst=i;} }
  console.log(`L${L} bits=${mlp.gate.spec.bits}: GATE maxDiff=${maxDiff.toExponential(3)} NaN=${nan} worst@${worst} ref=${ref[worst]?.toFixed(4)} fused=${fb[worst]?.toFixed(4)}`);
}
