import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
import {checkGeneralCopy2DSourceBinding} from "../../kernels/copy/GeneralCopy2DSourceBinding.ts";
import {checkAttentionGateCopyFreshReadBinding} from "./AttentionGateCopyFreshReadBinding.ts";
const pins:Record<string,string>={
 "models/qwen/KvCapacityKernelMemory":"e0685c1a839048f41a50c761f851a19944b3c4ccc1e55b1e57dcc4e0558c189e",
 "models/qwen/AttentionGateCopyFreshRowSources":"39fcdf6a53730000501984e34fd41286304c247d53542f5be67ef4849d97d3ec"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
export function checkProofs(sources:Record<string,string>):void{
 for(const[file,pin]of Object.entries(pins))if(hash(sources[file]??"")!==pin)throw Error("Capacity-general KV row source drift");
}
function rejected(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("Fresh KV row mutation accepted");}
export async function checkAttentionGateCopyFreshRowSourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const sources=Object.fromEntries(await Promise.all(Object.keys(pins).map(async file=>[file,await Bun.file(resolve(root,file+".lean")).text()])));
 await checkAttentionGateCopyFreshReadBinding(options);await checkGeneralCopy2DSourceBinding(options);checkProofs(sources);
 if(options.selfTest){
  for(const file of Object.keys(pins))rejected(()=>checkProofs({...sources,[file]:sources[file]+"\n"}));
  for(const[file,a,b]of [
   ["models/qwen/KvCapacityKernelMemory","slice.preservation.memory","before"],
   ["models/qwen/KvCapacityKernelMemory","slice.appended.copy (checked","otherTrace (checked"],
   ["models/qwen/AttentionGateCopyFreshRowSources","s.front.rope.key.output.bounded","otherBound"],
   ["models/qwen/AttentionGateCopyFreshRowSources","read.kv.values.preservation.memory","read.kv.keys.memory"],
   ["models/qwen/AttentionGateCopyFreshRowSources","(valueChecked read supported).eventAfter.memory=read.input.cache.memory","(valueChecked read supported).eventAfter.memory=otherMemory"]]){
    const bad=sources[file!]!.replace(a!,b!);if(bad===sources[file!])throw Error("Fresh KV row mutation anchor missing");
    rejected(()=>checkProofs({...sources,[file!]:bad}));
   }
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkAttentionGateCopyFreshRowSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Capacity-general fresh KV current-heap GG2 row source binding passed.");}
