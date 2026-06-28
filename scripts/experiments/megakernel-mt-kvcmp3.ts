import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "../../src/model/megakernel-kernel";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";
import { Dtype } from "../../src/mlx/ffi";
const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5));
const golden = await Bun.file("goldens/minicpm5-parity.json").json();
const toks: number[] = [...golden.prompt_ids];
function run(G:number){ const r=new MegakernelRunner(model,512,G); for(let s=0;s<3;s++){const l=r.decodeStep(toks[s]!); l.dispose();}
  const kc=r.kcache.astype(Dtype.float32); const v=kc.toFloat32().slice(); kc.dispose(); const out={v,KVDIM:r.KVDIM,kvSeq:r.kvSeq}; r.dispose(); return out; }
const a=run(1), b=run(4);
const {KVDIM,kvSeq}=a;
for(const L of [0,1,5,23]) for(const pos of [0,1,2]){
  const base=(L*kvSeq+pos)*KVDIM; let md=0,mi=0;
  for(let i=0;i<KVDIM;i++){const d=Math.abs(a.v[base+i]!-b.v[base+i]!); if(d>md){md=d;mi=i;}}
  console.log(`L${L} pos${pos} KV maxDiff=${md.toFixed(5)} (a=${a.v[base+mi]!.toFixed(4)} b=${b.v[base+mi]!.toFixed(4)})`);
}
