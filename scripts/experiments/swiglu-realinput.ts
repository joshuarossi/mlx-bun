import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import * as ops from "../../src/mlx/ops";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { fusedSwiglu } from "../../src/model/fused-swiglu-kernel";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const model = new MiniCPM5Model(await Weights.open(SNAP), await loadModelConfig(SNAP)) as any;

// Capture the REAL input to layer 0's MLP (fused OFF so forward is clean).
let captured: Float32Array | null = null, capShape: number[] = [];
const mlp0 = model.layers[0].mlp;
const orig = mlp0.forward.bind(mlp0);
mlp0.forward = (x: MlxArray) => { if (!captured) { captured = x.astype(Dtype.float32).toFloat32(); capShape = x.shape.slice(); } return orig(x); };
const cache = model.makeCache();
const logits = model.forward([0,608,4894,304,6918,357], cache);
logits.dispose();
mlp0.forward = orig;
console.log("captured x shape", capShape, "len", captured!.length);
let xmin=Infinity,xmax=-Infinity,xabs=0;
for (const v of captured!) { xmin=Math.min(xmin,v); xmax=Math.max(xmax,v); xabs=Math.max(xabs,Math.abs(v)); }
console.log(`x range [${xmin.toFixed(3)}, ${xmax.toFixed(3)}] maxAbs=${xabs.toFixed(3)}`);

const x = MlxArray.fromFloat32(captured!, capShape).astype(Dtype.bfloat16);
const gate = mlp0.gate.forward(x), up = mlp0.up.forward(x);
const sig = ops.sigmoid(gate), silu = ops.mul(gate, sig);
const ref = ops.mul(silu, up).astype(Dtype.float32).toFloat32();
const fb = fusedSwiglu(x, mlp0.gate.w, mlp0.gate.scales, mlp0.gate.biases, mlp0.up.w, mlp0.up.scales, mlp0.up.biases, mlp0.gate.spec).astype(Dtype.float32).toFloat32();
let maxDiff=0,nan=0,worst=-1;
for (let i=0;i<ref.length;i++){ if(Number.isNaN(fb[i]!)){nan++;continue;} const d=Math.abs(ref[i]!-fb[i]!); if(d>maxDiff){maxDiff=d;worst=i;} }
console.log(`L0 silu maxDiff=${maxDiff.toExponential(3)} NaN=${nan}/${ref.length} worst@${worst} ref=${ref[worst]?.toFixed(4)} fused=${fb[worst]?.toFixed(4)}`);
