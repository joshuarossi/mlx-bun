import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import * as ops from "../../src/mlx/ops";
import { lastPositionLogits } from "../../src/model/gemma4-base";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const model = new MiniCPM5Model(await Weights.open(SNAP), await loadModelConfig(SNAP)) as any;
// Force GPU-resident contiguous copies of every MLP weight (rules out the
// mmap/page-alignment "GPU reads garbage" footgun).
for (const l of model.layers) {
  for (const lin of [l.mlp.gate, l.mlp.up]) {
    const w2 = ops.contiguous(lin.w); const s2 = ops.contiguous(lin.scales); const b2 = ops.contiguous(lin.biases);
    ops.evalAll([w2,s2,b2]);
    (lin as any).w = w2; (lin as any).scales = s2; (lin as any).biases = b2;
  }
}
const cache = model.makeCache();
for (let r=0;r<3;r++){
  const lg = model.forward([0,608,4894,304,6918,357], cache);
  const l = lastPositionLogits(lg); let nan=0,max=-Infinity; for(const v of l){if(Number.isNaN(v))nan++;else max=Math.max(max,v);}
  console.log(`run ${r}: NaN=${nan} maxLogit=${Number.isFinite(max)?max.toFixed(3):max}`);
  lg.dispose();
  for (const c of cache) (c as any).offset = 0; // reset cache for repeat
}
