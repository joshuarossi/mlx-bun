import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "./megakernel-kernel";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";
const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5));
const golden = await Bun.file("goldens/minicpm5-parity.json").json();
const G = Number(process.env.G || 4);
const ra = new MegakernelRunner(model, 512, G);
const rb = new MegakernelRunner(model, 512, G);
const toks=[...golden.prompt_ids, ...golden.greedy_ids.slice(0,8)];
for(let s=0;s<toks.length;s++){
  const a=ra.decodeStep(toks[s]!), b=rb.decodeStep(toks[s]!);
  const va=a.toFloat32(), vb=b.toFloat32();
  let md=0; for(let i=0;i<va.length;i++) md=Math.max(md,Math.abs(va[i]!-vb[i]!));
  console.log(`step ${s} pos=${s}  MT-vs-MT maxDiff=${md.toExponential(2)} ${md>0.01?"  <-- NONDETERMINISTIC":""}`);
  a.dispose(); b.dispose();
}
