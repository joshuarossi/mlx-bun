import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
import {checkMlxOutputGateSourceBinding} from "../attention/MlxOutputGateSourceBinding.ts";
import {checkMlxOutputGateUnarySourceBinding} from "../attention/MlxOutputGateUnarySourceBinding.ts";
import {checkMlxOutputGateHostSourceBinding} from "../attention/MlxOutputGateHostSourceBinding.ts";
const runtimeHash="3f0e11f777f57b6595d57d62ec3f8b8331cbfa7263183e1baa98892efe935aec";
const pins:Record<string,string>={
  "DeltaBetaSource": "d3d3fd394b363a01b1c87c27b26b3f7b68b4aaf8818e2afe34d28f13795cdd91",
  "DeltaBetaMemory": "0d7b327994408dcdf22f7a5832383b99405c8d652c4668c6f37022fd4dd29c4a"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
export function checkSource(runtime:string,leans:Record<string,string>):void{
 if(hash(runtime)!==runtimeHash)throw Error("Delta beta runtime source drift");
 if(!runtime.includes("const beta = ops.sigmoid(b); // bf16"))throw Error("Delta beta selected host operation drift");
 if(Object.keys(pins).length!==2)throw Error("Delta beta verification pins not finalized");
 for(const[file,pin]of Object.entries(pins))if(hash(leans[file]??"")!==pin)throw Error("Delta beta proof drift");
}
function rejected(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("Delta beta mutation accepted");}
export async function checkDeltaBetaSourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const runtime=await Bun.file(resolve(root,"../packages/inference/src/kernels/delta/gated.ts")).text();
 const leans=Object.fromEntries(await Promise.all(Object.keys(pins).map(async f=>[f,await Bun.file(resolve(root,`kernels/delta/${f}.lean`)).text()])));
 await checkMlxOutputGateSourceBinding(options);await checkMlxOutputGateUnarySourceBinding(options);await checkMlxOutputGateHostSourceBinding(options);
 checkSource(runtime,leans);
 if(options.selfTest){
  for(const[a,b]of [["ops.sigmoid(b)","ops.sigmoid(a)"],["ops.sigmoid(b)","ops.exp(b)"]]){
   const bad=runtime.replace(a!,b!);if(bad===runtime)throw Error("Delta beta runtime mutation anchor missing");rejected(()=>checkSource(bad,leans));
  }
  for(const f of Object.keys(pins))rejected(()=>checkSource(runtime,{...leans,[f]:leans[f]+"\n"}));
  for(const[f,a,b]of [["DeltaBetaSource","⟨base,48,true,true,false⟩","⟨base,49,true,true,false⟩"],
   ["DeltaBetaSource","HalfMemory.store memory (2*store.word) store.value","HalfMemory.store memory (2*store.word+2) store.value"],
   ["DeltaBetaMemory","gates.beta.trace.schedule","gates.beta.trace.schedule.reverse"]]){
   const bad=leans[f!]!.replace(a!,b!);if(bad===leans[f!])throw Error("Delta beta Lean mutation anchor missing");rejected(()=>checkSource(runtime,{...leans,[f!]:bad}));
  }
  rejected(()=>checkSource(runtime+"\n",leans));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkDeltaBetaSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Delta beta current-buffer native source binding passed.");}
