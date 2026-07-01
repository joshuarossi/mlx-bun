import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "./megakernel-kernel";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";
const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5));
const golden = await Bun.file("goldens/minicpm5-parity.json").json();
const runner = new MegakernelRunner(model);
const prompt: number[] = golden.prompt_ids;
const t0 = performance.now();
let logits = runner.decodeStep(prompt[0]!);
for (let i=1;i<prompt.length;i++){ logits.dispose(); logits = runner.decodeStep(prompt[i]!); }
const v = logits.toFloat32();
const dt = performance.now()-t0;
let argmax=0,best=-Infinity,nan=false,fmax=-Infinity;
for(let i=0;i<v.length;i++){ if(Number.isNaN(v[i]!))nan=true; if(v[i]!>best){best=v[i]!;argmax=i;} fmax=Math.max(fmax,Math.abs(v[i]!)); }
const ref = new Float32Array(await Bun.file('goldens/minicpm5-logits-step0.bin').arrayBuffer());
let refArg=0,rb=-Infinity,md=0; for(let i=0;i<ref.length;i++){ if(ref[i]!>rb){rb=ref[i]!;refArg=i;} md=Math.max(md,Math.abs(v[i]!-ref[i]!)); }
console.log(`prefill ${prompt.length} steps in ${dt.toFixed(0)}ms (${(dt/prompt.length).toFixed(1)}ms/step)`);
console.log(`step0 argmax ours=${argmax} ref=${refArg} golden=${golden.greedy_ids[0]}  maxDiff=${md.toFixed(3)}  |max logit|=${fmax.toFixed(2)}  nan=${nan}`);
console.log(`ours[${argmax}]=${v[argmax]!.toFixed(3)} ref[${refArg}]=${ref[refArg]!.toFixed(3)}`);
runner.dispose();
