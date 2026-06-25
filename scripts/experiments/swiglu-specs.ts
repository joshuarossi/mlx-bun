import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const config = await loadModelConfig(SNAP);
const model = new MiniCPM5Model(await Weights.open(SNAP), config) as any;
for (let L = 0; L < model.layers.length; L++) {
  const m = model.layers[L].mlp;
  const mism = m.gate.spec.bits !== m.up.spec.bits || m.gate.spec.groupSize !== m.up.spec.groupSize;
  console.log(`L${String(L).padStart(2)} gate=${m.gate.spec.bits}/${m.gate.spec.groupSize} up=${m.up.spec.bits}/${m.up.spec.groupSize} down=${m.down.spec.bits}/${m.down.spec.groupSize} ${mism?"<<< MISMATCH":""}`);
}
