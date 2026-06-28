import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import * as ops from "../../src/mlx/ops";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { fusedSwiglu } from "../../src/model/fused-swiglu-kernel";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const model = new MiniCPM5Model(await Weights.open(SNAP), await loadModelConfig(SNAP)) as any;
const H = 1536;
// isolate the MLP: time all 24 layers' MLP on an [M,H] input, fused vs unfused (paired).
function bench(M: number) {
  const xs = new Float32Array(M*H); for (let i=0;i<xs.length;i++) xs[i]=Math.sin(i*0.3)*0.4;
  const x = MlxArray.fromFloat32(xs,[M,H]).astype(Dtype.bfloat16);
  // only matching-bits layers (fusable)
  const mlps = model.layers.map((l:any)=>l.mlp).filter((m:any)=>m.gate.spec.bits===m.up.spec.bits);
  const ITERS = 20;
  // unfused
  let t0=performance.now();
  for (let it=0;it<ITERS;it++){ const outs=[]; for(const m of mlps){const g=m.gate.forward(x),u=m.up.forward(x);const s=ops.sigmoid(g),si=ops.mul(g,s);const h=ops.mul(si,u);const o=m.down.forward(h);outs.push(o);g.dispose();s.dispose();si.dispose();u.dispose();h.dispose();} ops.evalAll(outs); for(const o of outs)o.dispose(); }
  const unfused=(performance.now()-t0)/ITERS;
  // fused (controlled eval per call)
  t0=performance.now();
  for (let it=0;it<ITERS;it++){ const outs=[]; for(const m of mlps){const h=fusedSwiglu(x,m.gate.w,m.gate.scales,m.gate.biases,m.up.w,m.up.scales,m.up.biases,m.gate.spec);const o=m.down.forward(h);outs.push(o);h.dispose();} ops.evalAll(outs); for(const o of outs)o.dispose(); }
  const fused=(performance.now()-t0)/ITERS;
  console.log(`M=${String(M).padStart(4)}  unfused=${unfused.toFixed(2)}ms  fused=${fused.toFixed(2)}ms  speedup=${(unfused/fused).toFixed(2)}x  (${mlps.length} MLPs)`);
}
// warmup
bench(8);
for (const M of [1, 8, 64, 256, 512, 1024]) bench(M);
