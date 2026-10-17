import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
import {checkVectorCopySourceBinding} from "../../kernels/copy/VectorCopySourceBinding.ts";
import {checkAttentionGateCopyFreshRowSourceBinding} from "./AttentionGateCopyFreshRowSourceBinding.ts";
const pins:Record<string,string>={
 "models/qwen/KvCapacityPreservationSourceMemory":"da123646a0f01d8426c16a4895b7304d0a4632744261c3233b3f5f929da4ae79",
 "models/qwen/AttentionGateCopyFreshSources":"afe5e15c42f7df041ecfb7af7cad9d5cf8e2acb4e0cc8b48326b801e5a330ab6",
 "kernels/copy/VectorCopyWideSemantics":"e6d1f078677b4e23a6b2974036af9c1b1d27188b32b04076306d1f8222e4d7fa",
 "kernels/copy/VectorCopyWideBodySemantics":"b23f118ee386669a56cd1e0c0572fa3f9d4051dec8890edbb49247b858aa4f7b",
 "kernels/copy/VectorCopyWideInterleaving":"d124706287d539e9855cd8525ada96d44aa81f8903eb00f7e5fd5b68a7af9af3"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
export function checkProofs(sources:Record<string,string>):void{
 for(const[file,pin]of Object.entries(pins))if(hash(sources[file]??"")!==pin)throw Error("Capacity-general KV full preservation source drift");
}
function rejected(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("Fresh KV preservation mutation accepted");}
export async function checkAttentionGateCopyFreshSourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const sources=Object.fromEntries(await Promise.all(Object.keys(pins).map(async file=>[file,await Bun.file(resolve(root,file+".lean")).text()])));
 await checkAttentionGateCopyFreshRowSourceBinding(options);await checkVectorCopySourceBinding(options);checkProofs(sources);
 if(options.selfTest){
  for(const file of Object.keys(pins))rejected(()=>checkProofs({...sources,[file]:sources[file]+"\n"}));
  for(const[file,a,b]of [
   ["models/qwen/KvCapacityPreservationSourceMemory","execution completed copied.trace copied.initial","execution completed otherTrace otherInitial"],
   ["models/qwen/KvCapacityPreservationSourceMemory","(sameHeap : after=before)","(sameHeap : True)"],
   ["models/qwen/AttentionGateCopyFreshSources","read.kv.keys.memory read.kv.values.preservation.memory","p.preparation.storage.memory read.kv.values.preservation.memory"],
   ["models/qwen/AttentionGateCopyFreshSources","read.input.cache.memory=read.kv.values.appended.copy.memory","read.input.cache.memory=p.preparation.storage.memory"],
   ["kernels/copy/VectorCopyWideBodySemantics","Statements source destination body","Statements source destination []"],
   ["kernels/copy/VectorCopyWideInterleaving","copied.before=before","copied.before=after.memory"]]){
    const bad=sources[file!]!.replace(a!,b!);if(bad===sources[file!])throw Error("Fresh KV preservation mutation anchor missing");
    rejected(()=>checkProofs({...sources,[file!]:bad}));
   }
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkAttentionGateCopyFreshSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Capacity-general fresh KV parsed preservation and row source binding passed.");}
