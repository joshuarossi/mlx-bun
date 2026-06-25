// GPU capture of the corrupting fused-SwiGLU forward (deep lazy graph, NO per-layer
// eval). Run with MTL_CAPTURE_ENABLED=1; writes a .gputrace to open in Xcode.
//   MTL_CAPTURE_ENABLED=1 MLX_BUN_FUSED_SWIGLU=1 MLX_BUN_FUSED_SWIGLU_MMIN=1 \
//     MLX_BUN_SWIGLU_NOEVAL=1 bun scripts/experiments/swiglu-capture.ts
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { lastPositionLogits } from "../../src/model/gemma4-base";
import { metalCapture } from "../../src/mlx/metal-kernel";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const model = new MiniCPM5Model(await Weights.open(SNAP), await loadModelConfig(SNAP)) as any;
const out = `${process.cwd()}/scripts/experiments/swiglu-corrupt.gputrace`;
const cache = model.makeCache();
// Warm: build kernels once OUTSIDE the capture (their compile isn't the bug).
const warm = model.forward([0,608,4894,304,6918,357], cache); lastPositionLogits(warm); warm.dispose();
for (const c of cache) (c as any).offset = 0;
const cache2 = model.makeCache();
metalCapture(out, () => {
  // ONE forward; the single deep-graph eval at lastPositionLogits is the corrupting
  // command buffer (all 24 fused_swiglu dispatches + MLX's buffer assignment).
  const lg = model.forward([0,608,4894,304,6918,357], cache2);
  const l = lastPositionLogits(lg); // forces the eval
  let nan=0,max=-Infinity; for(const v of l){if(Number.isNaN(v))nan++;else max=Math.max(max,v);}
  console.log(`captured forward: NaN=${nan} maxLogit=${Number.isFinite(max)?max.toFixed(3):max} (corrupt if != ~14.69)`);
  lg.dispose();
});
console.log(`\\ngputrace written: ${out}`);
