import { createHash } from "node:crypto";
import { resolve } from "node:path";
import { fileURLToPath,pathToFileURL } from "node:url";
import { checkMlxQmvHostSourceBinding } from "./MlxQmvHostSourceBinding.ts";
const revision="1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const sourceHash="2a007016da606afe569adb9adcc05e00f14558ad2e094bcb4f8974beb53c316f";
const leanHash="40a9ddc99f3821e1e8b93d43be0959b0ea0b43ac7167397d57c406ae541df5da";
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
export function extract(native:string): string {
  const start=native.indexOf("inline U load_vector(");
  const end=native.indexOf("inline U load_vector_safe(",start);
  if(start<0||end<0)throw Error("MLX load_vector boundaries missing");
  const body=native.slice(start,end);
  const four=body.indexOf("else if (bits == 4) {");
  const tail=body.indexOf("else if (bits == 5)",four);
  if(four<0||tail<0)throw Error("MLX load_vector four-bit branch missing");
  const branch=body.slice(four,tail);
  const loop=branch.slice(branch.indexOf("for ("),branch.lastIndexOf("}")).trim();
  return loop;
}
export function checkExtracted(native:string,lean:string):void {
  const loop=lean.match(/def sourceLoop : String := r#"([\s\S]*?)"#/)?.[1];
  if(loop===undefined||extract(native)!==loop)throw Error("MLX load_vector parsed literal mismatch");
  const start=native.indexOf("inline U load_vector(");
  const end=native.indexOf("inline U load_vector_safe(",start);
  const body=native.slice(start,end);
  for(const [name,statement] of [["sourceInitial","U sum = 0;"],["sourceReturn","return sum;"]]) {
    if(!body.includes(statement!)||!lean.includes(`def ${name} : String := "${statement}"`))throw Error("MLX load_vector initializer/return drift");
  }
}
export function checkSource(native:string,lean:string):void {
  if(hash(native)!==sourceHash)throw Error("MLX quantized header drift");
  if(hash(lean)!==leanHash)throw Error("MLX input parsed semantics drift");
  checkExtracted(native,lean);
}
function rejected(f:()=>void):void {let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("MLX input mutation accepted");}
export async function checkMlxQmvInput4SourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
  const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
  const [native,lean]=await Promise.all([
    Bun.file(resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/kernels/quantized.h`)).text(),
    Bun.file(resolve(root,"kernels/quantization/MlxQmvInput4Source.lean")).text(),
  ]);
  await checkMlxQmvHostSourceBinding(options);
  checkSource(native,lean);
  if(options.selfTest){
    const start=native.indexOf("inline U load_vector(");
    const branch=native.indexOf("else if (bits == 4) {",start);
    for(const [a,b] of [["values_per_thread","8"],["i += 4","i += 8"],["4096.0f","2048.0f"],["x[i + 3]","x[i + 2]"]]) {
      const bad=native.slice(0,branch)+native.slice(branch).replace(a!,b!);
      rejected(()=>checkSource(bad,lean));rejected(()=>checkExtracted(bad,lean));
    }
    rejected(()=>checkSource(native,lean.replace('then "16"','then "8"')));
    rejected(()=>checkExtracted(native,lean.replace("U sum = 0;","U sum = 1;")));
    rejected(()=>checkSource(native+"\n",lean));
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 await checkMlxQmvInput4SourceBinding({selfTest:process.argv.includes("--self-test")});console.log("MLX native four-bit input source binding passed.");
}
