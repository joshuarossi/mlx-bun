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
const xs = new Float32Array(6*Hdim); for (let i=0;i<xs.length;i++) xs[i]=Math.sin(i*0.7)*0.5;
const x = MlxArray.fromFloat32(xs,[6,Hdim]).astype(Dtype.bfloat16);
for (const L of [0,1,7,10,23]) {
  const m = model.layers[L].mlp;
  const g=m.gate.forward(x),u=m.up.forward(x);const s=ops.sigmoid(g),si=ops.mul(g,s);
  const ref=ops.mul(si,u).astype(Dtype.float32).toFloat32();
  const fb=fusedSwiglu(x,m.gate.w,m.gate.scales,m.gate.biases,m.up.w,m.up.scales,m.up.biases,m.gate.spec,m.up.spec).astype(Dtype.float32).toFloat32();
  let md=0,nan=0; for(let i=0;i<ref.length;i++){if(Number.isNaN(fb[i]!))nan++;else md=Math.max(md,Math.abs(ref[i]!-fb[i]!));}
  console.log(`L${String(L).padStart(2)} gate=${m.gate.spec.bits} up=${m.up.spec.bits}  maxDiff=${md.toExponential(3)} NaN=${nan}`);
}
