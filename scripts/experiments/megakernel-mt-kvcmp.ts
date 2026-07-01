import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "./megakernel-kernel";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";
import { Dtype } from "../../src/mlx/ffi";
const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5));
function kvAfterOneStep(G:number){ const r=new MegakernelRunner(model,512,G); const lg=r.decodeStep(608); lg.dispose();
  const kc=r.kcache.astype(Dtype.float32); const v=kc.toFloat32().slice(); kc.dispose();
  const lc=lg; return {v, KVDIM:r.KVDIM, kvSeq:r.kvSeq}; }
const a=kvAfterOneStep(1); const b=kvAfterOneStep(4);
// compare layer0, pos0: indices [0*kvSeq*KVDIM + 0*KVDIM + (0..KVDIM)]
const KVDIM=a.KVDIM, kvSeq=a.kvSeq;
let md=0,mi=0; for(let i=0;i<KVDIM;i++){ const d=Math.abs(a.v[i]!-b.v[i]!); if(d>md){md=d;mi=i;} }
console.log(`L0 pos0 KV maxDiff=${md.toFixed(5)} at ${mi}  a=${a.v[mi]!.toFixed(4)} b=${b.v[mi]!.toFixed(4)}`);
console.log(`first 6 k  G1: ${Array.from(a.v.slice(0,6)).map(x=>x.toFixed(4))}`);
console.log(`first 6 k  G4: ${Array.from(b.v.slice(0,6)).map(x=>x.toFixed(4))}`);
// also check a later layer (L5 pos0)
const base=5*kvSeq*KVDIM; let md2=0,mi2=0; for(let i=0;i<KVDIM;i++){const d=Math.abs(a.v[base+i]!-b.v[base+i]!); if(d>md2){md2=d;mi2=i;}}
console.log(`L5 pos0 KV maxDiff=${md2.toFixed(5)} at ${mi2}  a=${a.v[base+mi2]!.toFixed(4)} b=${b.v[base+mi2]!.toFixed(4)}`);
