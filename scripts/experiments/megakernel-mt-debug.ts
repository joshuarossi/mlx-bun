import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "./megakernel-kernel";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";
const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5));
const tok = 608; // a prompt token
function once(G: number): Float32Array {
  const r = new MegakernelRunner(model, 512, G);
  const lg = r.decodeStep(tok); // pos=0
  const v = lg.toFloat32(); lg.dispose(); r.dispose();
  return v.slice();
}
const a = once(1);
const b = once(Number(process.env.G || 4));
let md=0, mi=0; for(let i=0;i<a.length;i++){ const d=Math.abs(a[i]!-b[i]!); if(d>md){md=d;mi=i;} }
let am1=0,b1=-1e9,am2=0,b2=-1e9;
for(let i=0;i<a.length;i++){ if(a[i]!>b1){b1=a[i]!;am1=i;} if(b[i]!>b2){b2=b[i]!;am2=i;} }
console.log(`G=1 argmax=${am1}  G=${process.env.G||4} argmax=${am2}  maxDiff=${md.toFixed(4)} at i=${mi}  a[${mi}]=${a[mi]!.toFixed(3)} b[${mi}]=${b[mi]!.toFixed(3)}`);
console.log(`first 6 logits G1: ${Array.from(a.slice(0,6)).map(x=>x.toFixed(3))}`);
console.log(`first 6 logits G4: ${Array.from(b.slice(0,6)).map(x=>x.toFixed(3))}`);
