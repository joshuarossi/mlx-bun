import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
import {checkMlxRmsReductionSourceBinding} from "../../kernels/normalization/MlxRmsReductionSourceBinding.ts";
import {checkMlxRmsLoopSourceBinding} from "../../kernels/normalization/MlxRmsLoopSourceBinding.ts";
import {checkMlxRmsHostSourceBinding} from "../../kernels/normalization/MlxRmsHostSourceBinding.ts";
import {checkMlxRmsOutputSourceBinding} from "../../kernels/normalization/MlxRmsOutputSourceBinding.ts";
import {checkMlxQmvDelta48SourceBinding} from "../../kernels/quantization/MlxQmvDelta48SourceBinding.ts";
import {checkAffineOuter3SourceBinding} from "../../kernels/quantization/AffineOuter3SourceBinding.ts";
import {checkAffineOuter4SourceBinding} from "../../kernels/quantization/AffineOuter4SourceBinding.ts";
const pins:Record<string,string>={
  "models/qwen/DeltaParsedEntry": "60af5464252392e3f4338fc0520b9742a4ca5f068a4951d7d713f549fd65c363",
  "models/qwen/DeltaProjectionParameterSource": "bdf9f35425106eaa0d30536735110fff43c60e7963e3f880b65812437e9e6513",
  "models/qwen/DeltaConstructedPreparationSource": "92decc781d773c68d0e42665d9edc423221276dfa72fb4f07a60d84f38cf2ae1",
  "models/qwen/DeltaParsedProjections": "3196d5d99713a815133f8eaf116865c16c57d82e96425cd9f6621ce03e0de78e"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
export function checkProofs(sources:Record<string,string>):void{
 if(Object.keys(pins).length!==4)throw Error("Delta constructed prefix pins not finalized");
 for(const[file,pin]of Object.entries(pins))if(hash(sources[file]??"")!==pin)throw Error("Delta constructed prefix source composition drift");
}
function rejected(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("Delta constructed prefix mutation accepted");}
export async function checkDeltaConstructedPreparationSourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const sources=Object.fromEntries(await Promise.all(Object.keys(pins).map(async file=>[file,await Bun.file(resolve(root,file+".lean")).text()])));
 await checkMlxRmsReductionSourceBinding(options);await checkMlxRmsLoopSourceBinding(options);
 await checkMlxRmsHostSourceBinding(options);await checkMlxRmsOutputSourceBinding(options);await checkMlxQmvDelta48SourceBinding(options);
 const affineOptions={repositoryRoot:resolve(root,".."),selfTest:options.selfTest};
 await checkAffineOuter3SourceBinding(affineOptions);await checkAffineOuter4SourceBinding(affineOptions);
 checkProofs(sources);
 if(options.selfTest){
  for(const file of Object.keys(pins))rejected(()=>checkProofs({...sources,[file]:sources[file]+"\n"}));
  for(const[file,a,b]of [["models/qwen/DeltaParsedEntry","singleToken false","singleToken true"],
   ["models/qwen/DeltaParsedEntry","entry.affine.source.bytes=entry.normalization.normalized.trace.memory","entry.affine.source.bytes=entry.source.lhs.bytes"],
   ["models/qwen/DeltaProjectionParameterSource","current=AffineMemoryFrames.reframe p original memory same","current=original"],
   ["models/qwen/DeltaProjectionParameterSource","(two.packed i h).trans (one.packed i h)","one.packed i h"],
   ["models/qwen/DeltaConstructedPreparationSource","source.data.affineWeights.a","source.data.affineWeights.b"],
   ["models/qwen/DeltaConstructedPreparationSource","Delta48NativeParsedAffine4.aExecution","Delta48NativeParsedAffine4.bExecution"],
   ["models/qwen/DeltaConstructedPreparationSource","source.entry.affine.qkvBuffer","source.entry.affine.zBuffer"]]){
   const bad=sources[file!]!.replace(a!,b!);if(bad===sources[file!])throw Error("Delta constructed prefix mutation anchor missing");
   rejected(()=>checkProofs({...sources,[file!]:bad}));
  }
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkDeltaConstructedPreparationSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Delta constructed normalization/projection/preparation source binding passed.");}
