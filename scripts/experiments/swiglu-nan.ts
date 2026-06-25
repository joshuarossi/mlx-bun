import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { lastPositionLogits } from "../../src/model/gemma4-base";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const config = await loadModelConfig(SNAP);
const model = new MiniCPM5Model(await Weights.open(SNAP), config) as any;
const prompt = [0, 608, 4894, 304, 6918, 357]; // "The capital of France is"

function nanCheck(tag: string) {
  const cache = model.makeCache();
  const logits = model.forward(prompt, cache);
  const l = lastPositionLogits(logits);
  let nan = 0, max = -Infinity;
  for (const v of l) { if (Number.isNaN(v)) nan++; else max = Math.max(max, v); }
  console.log(`${tag}: NaN=${nan}/${l.length} maxLogit=${Number.isFinite(max)?max.toFixed(3):max}`);
  logits.dispose();
  for (const c of cache) c.dispose();
}

console.log("FUSED_SWIGLU =", process.env.MLX_BUN_FUSED_SWIGLU, "MMIN =", process.env.MLX_BUN_FUSED_SWIGLU_MMIN);
nanCheck("prefill");
