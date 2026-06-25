import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { argmaxLastPosition, lastPositionLogits } from "../../src/model/gemma4-base";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const model = new MiniCPM5Model(await Weights.open(SNAP), await loadModelConfig(SNAP)) as any;
const golden = await Bun.file("goldens/minicpm5-parity.json").json();
const cache = model.makeCache();
let tokens = golden.prompt_ids;
let greedyMatch = 0, total = 0, sumMaxDiff = 0;
for (let step = 0; step < 100; step++) {
  const logits = model.forward(tokens, cache);
  if (step < golden.logit_steps) {
    const ours = lastPositionLogits(logits);
    const ref = new Float32Array(await Bun.file(`goldens/minicpm5-logits-step${step}.bin`).arrayBuffer());
    let md = 0; for (let i=0;i<ref.length;i++) md=Math.max(md, Math.abs(ours[i]!-ref[i]!));
    sumMaxDiff += md;
  }
  const next = argmaxLastPosition(logits);
  logits.dispose();
  total++;
  if (next === golden.greedy_ids[step]) greedyMatch++;
  tokens = [next];
}
for (const c of cache) c.dispose();
console.log(`FUSED=${process.env.MLX_BUN_FUSED_SWIGLU} EVAL=${process.env.MLX_BUN_SWIGLU_EVAL} MMIN=${process.env.MLX_BUN_FUSED_SWIGLU_MMIN}`);
console.log(`greedy trajectory match: ${greedyMatch}/${total}   mean per-step logit maxDiff: ${(sumMaxDiff/total).toFixed(4)}`);
