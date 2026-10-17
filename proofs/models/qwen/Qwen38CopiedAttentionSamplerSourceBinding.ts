import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
import {checkLogSumExpSourceBinding} from "../../kernels/sampling/LogSumExpSourceBinding.ts";
const pins:Record<string,string>={
 "models/qwen/Qwen38CopiedAttentionSamplerSource":"09f11e732f33e3ef5a469747144ab340f55d6e03ca3a4df3b1b49ed2b2d8a8ee",
 "models/qwen/Qwen38CopiedAttentionExecution":"439bcd1c3af7b4c4b2730fdcd02b36e7b77e76c08d832ef1e71fc743b885e004",
 "models/qwen/CopiedAttentionChainParsed":"9a79d77e9de87f6bb2cd7054c84fb5289e08590566d8e7e5754fc10efe903e21",
 "models/qwen/FinalProjectionParsedSource":"e307673918872af910d8b63134664c31a0c126dde16391311114a889ef0d7ecb"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
export function checkProofs(sources:Record<string,string>):void{
 for(const[file,pin]of Object.entries(pins))if(hash(sources[file]??"")!==pin)throw Error("Copied attention sampler source composition drift");
}
function rejected(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("Copied sampler mutation accepted");}
export async function checkQwen38CopiedAttentionSamplerSourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const sources=Object.fromEntries(await Promise.all(Object.keys(pins).map(async file=>[file,await Bun.file(resolve(root,file+".lean")).text()])));
 await checkLogSumExpSourceBinding(options);
 checkProofs(sources);
 if(options.selfTest){
  for(const file of Object.keys(pins))rejected(()=>checkProofs({...sources,[file]:sources[file]+"\n"}));
  const file="models/qwen/Qwen38CopiedAttentionSamplerSource";
  for(const[a,b]of [["execution.workspace.pipeline sampling","execution.workspace.pipeline samplingOther"],
   ["execution.forward.linked","rfl"],
   ["(LogSumExpSamplerSource.source_token execution.sampler.selection","(LogSumExpSamplerSource.source_token otherSelection"],
   ["selected.val ≤ i.val","i.val ≤ selected.val"],
   ["FinalProjectionParsedSource.checked execution.forward.finalParameters","FinalProjectionParsedSource.checked otherParameters"],
   ["execution.sampler.selection.destination","execution.workspace.base"]]){
    const bad=sources[file]!.replace(a!,b!);if(bad===sources[file])throw Error("Copied sampler mutation anchor missing");
    rejected(()=>checkProofs({...sources,[file]:bad}));
   }
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkQwen38CopiedAttentionSamplerSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Copied attention/final projection/current-heap sampler source binding passed.");}
