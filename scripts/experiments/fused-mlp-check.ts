import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import * as ops from "../../src/mlx/ops";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { fusedMlp } from "../../src/model/fused-mlp-kernel";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const model = new MiniCPM5Model(await Weights.open(SNAP), await loadModelConfig(SNAP)) as any;
const Hdim=1536;
const xs=new Float32Array(6*Hdim); for(let i=0;i<xs.length;i++) xs[i]=Math.sin(i*0.7)*0.5;
const x=MlxArray.fromFloat32(xs,[6,Hdim]).astype(Dtype.bfloat16);
for (const L of [0,1,7]) {
  const m=model.layers[L];
  const ref=m.mlp.forward(x).astype(Dtype.float32).toFloat32();   // unfused reference
  const fb=fusedMlp(x, m.mlp.gate.w,m.mlp.gate.scales,m.mlp.gate.biases,m.mlp.gate.spec,
                       m.mlp.up.w,m.mlp.up.scales,m.mlp.up.biases,m.mlp.up.spec,
                       m.mlp.down.w,m.mlp.down.scales,m.mlp.down.biases,m.mlp.down.spec).astype(Dtype.float32).toFloat32();
  let md=0,nan=0; for(let i=0;i<ref.length;i++){if(Number.isNaN(fb[i]!))nan++;else md=Math.max(md,Math.abs(ref[i]!-fb[i]!));}
  console.log(`L${L} g${m.mlp.gate.spec.bits}/u${m.mlp.up.spec.bits}/d${m.mlp.down.spec.bits}  maxDiff=${md.toExponential(3)} NaN=${nan}/${ref.length}`);
}
