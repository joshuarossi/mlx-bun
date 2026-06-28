import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import * as ops from "../../src/mlx/ops";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { steelLinear } from "../../src/model/steel-linear-kernel";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const model = new MiniCPM5Model(await Weights.open(SNAP), await loadModelConfig(SNAP)) as any;
function mk(M: number, H: number) { const xs=new Float32Array(M*H); for(let i=0;i<xs.length;i++) xs[i]=Math.sin(i*0.5)*0.4; return MlxArray.fromFloat32(xs,[M,H]).astype(Dtype.bfloat16); }
const L0 = model.layers[0];
const cases: [string, any, number][] = [
  ["q_proj(H=1536)", L0.attn.qProj, 1536],
  ["o_proj(H=2048)", L0.attn.oProj, 2048],
  ["down(H=4608)", L0.mlp.down, 4608],
];
for (const M of [6, 128]) {
  for (const [name, lin, H] of cases) {
    const x = mk(M, H);
    const ref = lin.forward(x).astype(Dtype.float32).toFloat32();
    const got = steelLinear(x, lin.w, lin.scales, lin.biases, lin.spec).astype(Dtype.float32).toFloat32();
    let md=0,nan=0; for(let i=0;i<ref.length;i++){if(Number.isNaN(got[i]!))nan++;else md=Math.max(md,Math.abs(ref[i]!-got[i]!));}
    console.log(`M=${String(M).padStart(3)} ${name.padEnd(16)} bits=${lin.spec.bits}  maxDiff=${md.toExponential(3)} NaN=${nan}`);
  }
}
