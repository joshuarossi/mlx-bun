import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "./megakernel-kernel";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";
const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5));
const golden = await Bun.file("goldens/minicpm5-parity.json").json();
const G = Number(process.env.G || 4);
const r1 = new MegakernelRunner(model, 512, 1);
const r4 = new MegakernelRunner(model, 512, G);
const prompt: number[] = golden.prompt_ids;
const toks = [...prompt, ...golden.greedy_ids.slice(0, 6)];
for (let s = 0; s < toks.length; s++) {
  const a = r1.decodeStep(toks[s]!); const b = r4.decodeStep(toks[s]!);
  const va = a.toFloat32(), vb = b.toFloat32();
  let md=0,mi=0,am1=0,b1=-1e9,am2=0,b2=-1e9;
  for(let i=0;i<va.length;i++){ const d=Math.abs(va[i]!-vb[i]!); if(d>md){md=d;mi=i;} if(va[i]!>b1){b1=va[i]!;am1=i;} if(vb[i]!>b2){b2=vb[i]!;am2=i;} }
  console.log(`step ${s} pos=${s} tok=${toks[s]}  maxDiff=${md.toFixed(4)}  G1arg=${am1} G${G}arg=${am2}`);
  a.dispose(); b.dispose();
}
