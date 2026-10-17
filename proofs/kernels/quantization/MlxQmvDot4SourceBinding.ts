import { createHash } from "node:crypto";
import { resolve } from "node:path";
import { fileURLToPath,pathToFileURL } from "node:url";
import { checkMlxQmvInput4SourceBinding } from "./MlxQmvInput4SourceBinding.ts";
const revision="1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const sourceHash="2a007016da606afe569adb9adcc05e00f14558ad2e094bcb4f8974beb53c316f";
const pins:Record<string,string>={
  "MlxQmvDot4Syntax": "bba5bd7c71dba5579ef67f27962d1d78ce31cd25c3db678f83a68559da7928be",
  "MlxQmvDot4Source": "708ec2e951369657470a1a2b56a5b866555967f119278a92abdf9f1b93b05eec",
  "MlxQmvDot4LoopSource": "c695fa34c75e953094aad8681f86c95819af8bf27d143cf9c25deb0059d3b827",
  "MlxQmvDot4FunctionSyntax": "624c468aaabe7a30ca42b456c597aaedc9105672ca910676f694053b05e0bd06",
  "MlxQmvDot4FunctionSource": "4265141f5749beeae1d84c3cd0c7ff968ca53a6c5519e3c902403a90db3f781f",
  "MlxQmvDot4TileMemory": "ab106d4598aaedf9e8b1e3d623e260e269de8a4e4845b2190306e5828931f9b9",
  "MlxQmvPrivate4Memory": "1768d9d8c8dfc9ba84b4536122064640c4364317a2cb4566c75d8a9b60dcbf30"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
const unescape=(s:string):string=>JSON.parse(`"${s}"`);
export function extract(native:string):Record<string,string>{
 const start=native.indexOf("inline U qdot(");const end=native.indexOf("inline U qdot_safe(",start);
 if(start<0||end<0)throw Error("MLX qdot boundaries missing");
 const body=native.slice(start,end);const branch=body.slice(body.indexOf("else if (bits == 4) {"),body.indexOf("else if (bits == 5) {"));
 const statement=branch.match(/accum \+=[\s\S]*?;/)?.[0];
 const pointer=branch.match(/const device uint16_t\* ws =[^;]*;/)?.[0];
 const header=branch.match(/for \([^\n]*\) \{/)?.[0];
 const initial=body.match(/U accum = [^;]*;/)?.[0];const returned=body.match(/return scale[^;]*;/)?.[0];
 if(!statement||!pointer||!header||!initial||!returned)throw Error("MLX qdot statements missing");
 return {sourceBody:statement,sourcePointer:pointer,sourceHeader:header,sourceInitializer:initial,sourceReturn:returned};
}
export function checkExtracted(native:string,leans:Record<string,string>):void{
 const got=extract(native);
 for(const [name,file] of [["sourceBody","MlxQmvDot4Syntax"],["sourceHeader","MlxQmvDot4LoopSource"],
 ["sourcePointer","MlxQmvDot4FunctionSyntax"],["sourceInitializer","MlxQmvDot4FunctionSyntax"],["sourceReturn","MlxQmvDot4FunctionSyntax"]]){
  const literal=leans[file!]?.match(new RegExp(`def ${name} : String := "((?:[^"\\\\]|\\\\.)*)"`))?.[1];
  if(literal===undefined||unescape(literal)!==got[name!])throw Error(`MLX native qdot literal drift: ${name}`);
 }
}
export function checkSource(native:string,leans:Record<string,string>):void{
 if(hash(native)!==sourceHash)throw Error("MLX native qdot source drift");
 for(const [file,pin]of Object.entries(pins))if(hash(leans[file]??"")!==pin)throw Error("MLX native qdot proof drift");
 checkExtracted(native,leans);
}
function rejected(f:()=>void):void{let fail=false;try{f();}catch{fail=true;}if(!fail)throw Error("MLX qdot mutation accepted");}
export async function checkMlxQmvDot4SourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const native=await Bun.file(resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/kernels/quantized.h`)).text();
 const leans=Object.fromEntries(await Promise.all(Object.keys(pins).map(async f=>[f,await Bun.file(resolve(root,`kernels/quantization/${f}.lean`)).text()])));
 await checkMlxQmvInput4SourceBinding(options);checkSource(native,leans);
 if(options.selfTest){
  const start=native.indexOf("inline U qdot(");const four=native.indexOf("else if (bits == 4) {",start);
  for(const [a,b]of [["0x000f","0x000e"],["0xf000","0x0f00"],["uint16_t","uint32_t"],["values_per_thread / 4","values_per_thread / 8"],["x_thread[4 * i + 3]","x_thread[4 * i + 2]"]]){
   const bad=native.slice(0,four)+native.slice(four).replace(a!,b!);rejected(()=>checkSource(bad,leans));rejected(()=>checkExtracted(bad,leans));
  }
  for(const f of Object.keys(pins))rejected(()=>checkSource(native,{...leans,[f]:leans[f]+"\n"}));
  rejected(()=>checkExtracted(native,{...leans,MlxQmvDot4Syntax:leans.MlxQmvDot4Syntax!.replace("0x000f","0x000e")}));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxQmvDot4SourceBinding({selfTest:process.argv.includes("--self-test")});console.log("MLX native qdot source binding passed.");}
