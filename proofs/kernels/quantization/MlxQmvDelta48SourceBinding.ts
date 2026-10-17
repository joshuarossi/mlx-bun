import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
import {checkMlxQmvFast4SourceBinding} from "./MlxQmvFast4SourceBinding.ts";
const pins:Record<string,string>={
  "layers/AffineNativeParsedSource4": "f6c10d841da030b7b7bd525a8e33770bec9b8d7ff6df07c43c0c994d5b26cf45",
  "models/qwen/Delta48NativeParsedAffine4": "2c4c1d44b210b5ba3c63be0a9216cfafe9d47986b281cf7d943f8ff919799303"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
// This guard preserves the layer/model composition and chains the pinned
// native extraction checks. Model bit-width/descriptor attachment and compiler
// primitive contracts remain the same explicit theorem boundaries.
export function checkProofs(sources:Record<string,string>):void{
 for(const [file,pin]of Object.entries(pins))if(hash(sources[file]??"")!==pin)throw Error("MLX Delta48 source composition drift");
}
function rejected(f:()=>void):void{let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("MLX Delta48 composition mutation accepted");}
export async function checkMlxQmvDelta48SourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const sources=Object.fromEntries(await Promise.all(Object.keys(pins).map(async file=>[file,await Bun.file(resolve(root,file+".lean")).text()])));
 await checkMlxQmvFast4SourceBinding(options);checkProofs(sources);
 if(options.selfTest){
  for(const file of Object.keys(pins))rejected(()=>checkProofs({...sources,[file]:sources[file]+"\n"}));
  const model="models/qwen/Delta48NativeParsedAffine4";
  for(const [a,b]of [["phase.a a ha","phase.b a ha"],["phase.b b hb","phase.a b hb"],[".storage.projectionA.read head",".storage.projectionB.read head"],[".storage.projectionB.read head",".storage.projectionA.read head"],["a.budget input target error head","0"],["b.budget input target error head","0"]]){
   const bad=sources[model]!.replace(a!,b!);if(bad===sources[model])throw Error("MLX Delta48 mutation anchor missing");
   rejected(()=>checkProofs({...sources,[model]:bad}));
  }
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxQmvDelta48SourceBinding({selfTest:process.argv.includes("--self-test")});console.log("MLX Delta48 native source composition binding passed.");}
