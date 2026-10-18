import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
const revision="1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const nativeHash="2dd13c2496f5d6f0856e4ca99db2ceb5c6d7dc0c344b9ba8e41ef3b7d7ed8a97";
const pins:Record<string,string>={MlxLogAddExpSyntax:"e2a176c8088b5657bd0bd020bf7ca3579e490b71d63193be05b052c5632041d4",MlxLogAddExpSource:"05c9be2659a9847831a4e3c3c9a66cd9569740927728d31a3868dd9bbcbfe677"};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
export function extract(native:string):Record<string,string>{
 const start=native.indexOf("struct LogAddExp {");const end=native.indexOf("template <>",start);
 if(start<0)throw Error("LogAddExp source boundary missing");const body=native.slice(start,end<0?undefined:end);
 const take=(re:RegExp)=>{const match=body.match(re)?.[0];if(match===undefined)throw Error("LogAddExp source statement missing");return match;};
 return {nanSource:take(/if \(metal::isnan\(x\)[\s\S]*?quiet_NaN\(\);\n    }/),
 infinitySource:take(/constexpr T inf =[^;]*;/),maximumSource:take(/T maxval =[^;]*;/),minimumSource:take(/T minval =[^;]*;/),
 returnSource:take(/return \(minval == -inf[\s\S]*?;/)};
}
export function checkExtracted(native:string,syntax:string):void{
 for(const[name,statement]of Object.entries(extract(native))){
  const literal=syntax.match(new RegExp(`def ${name} : String := "((?:[^"\\\\]|\\\\.)*)"`))?.[1];
  if(literal===undefined||JSON.parse(`"${literal}"`)!==statement)throw Error(`LogAddExp source literal drift: ${name}`);
 }
}
export function checkSource(native:string,leans:Record<string,string>):void{
 if(hash(native)!==nativeHash)throw Error("LogAddExp native source drift");
 for(const[file,pin]of Object.entries(pins))if(hash(leans[file]??"")!==pin)throw Error("LogAddExp proof drift");
 checkExtracted(native,leans.MlxLogAddExpSyntax!);
}
function rejected(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("LogAddExp mutation accepted");}
export async function checkMlxLogAddExpSourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const native=await Bun.file(resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/kernels/binary_ops.h`)).text();
 const leans=Object.fromEntries(await Promise.all(Object.keys(pins).map(async f=>[f,await Bun.file(resolve(root,`kernels/delta/${f}.lean`)).text()])));
 checkSource(native,leans);
 if(options.selfTest){
  for(const statement of Object.values(extract(native))){const bad=native.replace(statement,statement.replace(/./,"!"));rejected(()=>checkSource(bad,leans));rejected(()=>checkExtracted(bad,leans.MlxLogAddExpSyntax!));}
  for(const f of Object.keys(pins))rejected(()=>checkSource(native,{...leans,[f]:leans[f]+"\n"}));
  for(const[a,b]of [["metal::max(x, y)","metal::min(x, y)"],["minval - maxval","maxval - minval"],["maxval + log1p","minval + log1p"]]){
   const bad=leans.MlxLogAddExpSyntax!.replace(a!,b!);if(bad===leans.MlxLogAddExpSyntax)throw Error("LogAddExp mutation anchor missing");
   rejected(()=>checkExtracted(native,bad));rejected(()=>checkSource(native,{...leans,MlxLogAddExpSyntax:bad}));
  }
  rejected(()=>checkSource(native+"\n",leans));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxLogAddExpSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("MLX finite LogAddExp source binding passed.");}
