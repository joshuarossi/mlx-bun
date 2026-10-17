import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
import {checkMlxDepthwiseConvSourceBinding} from "./MlxDepthwiseConvSourceBinding.ts";
const modelHash="103789977c9d57857043d5d9e52cbf03fe212add3701a7f7b9e65f9d6ab718c4";
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
export function checkModel(source:string):void{if(hash(source)!==modelHash)throw Error("MLX convolution model source composition drift");}
function rejected(f:()=>void):void{let fail=false;try{f();}catch{fail=true;}if(!fail)throw Error("MLX convolution model mutation accepted");}
export async function checkMlxDepthwiseConvModelBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const model=await Bun.file(resolve(root,"models/qwen/DeltaConvolutionParsedSource.lean")).text();
 await checkMlxDepthwiseConvSourceBinding(options);checkModel(model);
 if(options.selfTest){
  for(const [a,b]of [["execution.stores.memory","execution.stores.before"],["scales.headInput.storage.input.read channel","scales.headInput.storage.qScale.read channel"],
    ["value (DeltaPreparationConstruction.convolved","value (DeltaPreparationConstruction.window"],["Convolution.budget contracted","0 * Convolution.budget contracted"]]){
   const bad=model.replace(a!,b!);if(bad===model)throw Error("MLX convolution model mutation anchor missing");rejected(()=>checkModel(bad));
  }
  rejected(()=>checkModel(model+"\n"));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxDepthwiseConvModelBinding({selfTest:process.argv.includes("--self-test")});console.log("MLX convolution model source composition binding passed.");}
