import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { argmaxLastPosition, lastPositionLogits } from "../../src/model/gemma4-base";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const model = new MiniCPM5Model(await Weights.open(SNAP), await loadModelConfig(SNAP)) as any;
const golden = await Bun.file("goldens/minicpm5-parity.json").json();
const cache = model.makeCache();
// TEACHER FORCING: always advance with the oracle's token, so contexts stay identical.
let tokens = golden.prompt_ids;
let agree = 0, total = 0, sumMaxDiff = 0, sumKL = 0;
for (let step = 0; step < 100; step++) {
  const logits = model.forward(tokens, cache);
  const ours = lastPositionLogits(logits);
  const ref = new Float32Array(await Bun.file(`goldens/minicpm5-logits-step${step}.bin`).arrayBuffer());
  let md = 0; for (let i=0;i<ref.length;i++) md=Math.max(md, Math.abs(ours[i]!-ref[i]!));
  sumMaxDiff += md;
  // KL(ref || ours) over softmax
  let mr=-Infinity,mo=-Infinity; for(let i=0;i<ref.length;i++){if(ref[i]!>mr)mr=ref[i]!;if(ours[i]!>mo)mo=ours[i]!;}
  let zr=0,zo=0; for(let i=0;i<ref.length;i++){zr+=Math.exp(ref[i]!-mr);zo+=Math.exp(ours[i]!-mo);}
  let kl=0; for(let i=0;i<ref.length;i++){const pr=Math.exp(ref[i]!-mr)/zr; if(pr>1e-12){const po=Math.exp(ours[i]!-mo)/zo; kl+=pr*Math.log(pr/Math.max(po,1e-30));}}
  sumKL += kl;
  if (argmaxLastPosition(logits) === golden.greedy_ids[step]) agree++;
  total++;
  logits.dispose();
  tokens = [golden.greedy_ids[step]!]; // teacher-force with oracle token
}
for (const c of cache) c.dispose();
console.log(`FUSED=${process.env.MLX_BUN_FUSED_SWIGLU} EVAL=${process.env.MLX_BUN_SWIGLU_EVAL} MMIN=${process.env.MLX_BUN_FUSED_SWIGLU_MMIN}`);
console.log(`teacher-forced argmax agreement: ${agree}/${total}   mean maxDiff: ${(sumMaxDiff/total).toFixed(4)}   mean KL: ${(sumKL/total).toExponential(3)} nats`);
