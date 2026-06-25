import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
const SNAP = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78";
const model = new MiniCPM5Model(await Weights.open(SNAP), await loadModelConfig(SNAP)) as any;
let call = 0;
for (let L=0;L<model.layers.length;L++){const m=model.layers[L].mlp;
  const match = m.gate.spec.bits===m.up.spec.bits && m.gate.spec.groupSize===m.up.spec.groupSize;
  if (match) { call++; console.log(`call#${call} = L${L} bits=${m.gate.spec.bits} I=${m.gate.w.shape[0]} I%32=${m.gate.w.shape[0]%32}`); }
}
