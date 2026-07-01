import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import * as ops from "../../src/mlx/ops";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { fusedMlp } from "../../src/model/fused-mlp-kernel";
const SNAP="/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const model=new MiniCPM5Model(await Weights.open(SNAP),await loadModelConfig(SNAP)) as any;
const H=1536;
function bench(M:number){
  const xs=new Float32Array(M*H);for(let i=0;i<xs.length;i++)xs[i]=Math.sin(i*0.3)*0.4;
  const x=MlxArray.fromFloat32(xs,[M,H]).astype(Dtype.bfloat16);
  const mlps=model.layers.map((l:any)=>l.mlp);
  const IT=15;
  let t0=performance.now();
  for(let it=0;it<IT;it++)for(const m of mlps){const g=m.gate.forward(x),u=m.up.forward(x);const s=ops.sigmoid(g),si=ops.mul(g,s);const h=ops.mul(si,u);const o=m.down.forward(h);ops.evalAll([o]);g.dispose();s.dispose();si.dispose();u.dispose();h.dispose();o.dispose();}
  const unf=(performance.now()-t0)/IT;
  const h0=ops.zeros([M, (mlps[0] as any).down.w.shape[0]], x.dtype);  // zero residual: fused outputs h+mlp(x)
  t0=performance.now();
  for(let it=0;it<IT;it++)for(const m of mlps){const o=fusedMlp(x,m.gate.w,m.gate.scales,m.gate.biases,m.gate.spec,m.up.w,m.up.scales,m.up.biases,m.up.spec,m.down.w,m.down.scales,m.down.biases,m.down.spec,h0);ops.evalAll([o]);o.dispose();}
  const fus=(performance.now()-t0)/IT;
  console.log(`M=${String(M).padStart(4)}  unfused=${unf.toFixed(2)}ms  fusedMLP=${fus.toFixed(2)}ms  speedup=${(unf/fus).toFixed(2)}x`);
}
bench(8);
for(const M of [8,64,256,512]) bench(M);
