import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import * as ops from "../../src/mlx/ops";
import { lastPositionLogits } from "../../src/model/gemma4-base";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const model = new MiniCPM5Model(await Weights.open(SNAP), await loadModelConfig(SNAP)) as any;
function prefill(P: number) {
  const toks = Array.from({length:P}, (_,i)=> (i*131+7)%50000);
  const ITERS = 12;
  let t0=performance.now();
  for(let it=0;it<ITERS;it++){const cache=model.makeCache();const lg=model.forward(toks,cache);lastPositionLogits(lg);lg.dispose();for(const c of cache)c.dispose();}
  return (performance.now()-t0)/ITERS;
}
prefill(64); // warm
for (const P of [16, 64, 256, 512]) {
  process.env.MLX_BUN_FUSED_SWIGLU=""; const off=prefill(P);
  process.env.MLX_BUN_FUSED_SWIGLU="1"; const on=prefill(P);
  process.env.MLX_BUN_FUSED_SWIGLU="";
  console.log(`prefill P=${String(P).padStart(4)}  off=${off.toFixed(2)}ms  fused+eval=${on.toFixed(2)}ms  ratio=${(off/on).toFixed(2)}x`);
}
