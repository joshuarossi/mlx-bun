import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
import {checkMlxQmvDot4SourceBinding} from "./MlxQmvDot4SourceBinding.ts";
const revision="1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const sourceHash="2a007016da606afe569adb9adcc05e00f14558ad2e094bcb4f8974beb53c316f";
const pins:Record<string,string>={
  "MlxQmvFast4Syntax": "24e0016aa11e8dd94f93aecf59391be870aa45a465afb185938f8046d556eee0",
  "MlxQmvFast4LoopSource": "cc7115195963c1cf93b09f502e7a94ea2baaa00fc8f1f3ea54eb5f09fca0a9b2",
  "MlxQmvFast4Output": "b68e5dba8584b5a68b1d885ddad231ef0dab2ccbcc069acc386a088fc6f8af36",
  "MlxQmvFast4Pointers": "4452c3842ec5808dd8d849ae2c85b9f7a9688be6983924e9e859eb9a0a3c7d1a",
  "MlxQmvFast4Memory": "5a779abedc9233db3dc48e4de1586494185fa36042b4bf3d7f126cbc42e25167"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
export function extract(native:string):Record<string,string>{
 const start=native.indexOf("METAL_FUNC void qmv_fast_impl(");const end=native.indexOf("METAL_FUNC void qmv_impl(",start);
 if(start<0||end<0)throw Error("MLX qmv_fast source boundaries missing");
 const body=native.slice(start,end);
 const take=(pattern:RegExp)=>{const v=body.match(pattern)?.[0];if(v===undefined)throw Error("MLX qmv_fast source statement missing");return v;};
 return {
  configSource:take(/constexpr int packs_per_thread =[\s\S]*?constexpr int scale_step_per_thread =[^;]*;/),
  headerSource:take(/for \(int k =[^\n]*\{/),
  innerSource:take(/for \(int row =[^\n]*\{/),
  initialSource:take(/thread U result\[[^\n]*;/),
  callSource:take(/result\[row\] \+= qdot[^;]*;/),
  loadSource:take(/U sum = load_vector[^;]*;/),
  rowSource:take(/const int out_row =[\s\S]*?;/),
  outputSource:take(/result\[row\] = simd_sum[\s\S]*?\n    }/),
  pointersSource:take(/ws \+= out_row[\s\S]*?y \+= [^;]*;/),
  updatesSource:take(/ws \+= block_size[\s\S]*?x \+= block_size;/),
  readsSource:take(/auto wl =[\s\S]*?U b = bl\[0\];/),
 };
}
const owners:Record<string,string>={configSource:"MlxQmvFast4Syntax",headerSource:"MlxQmvFast4Syntax",innerSource:"MlxQmvFast4Syntax",
 initialSource:"MlxQmvFast4Syntax",callSource:"MlxQmvFast4Syntax",loadSource:"MlxQmvFast4Syntax",rowSource:"MlxQmvFast4Output",
 outputSource:"MlxQmvFast4Output",pointersSource:"MlxQmvFast4Pointers",updatesSource:"MlxQmvFast4Pointers",readsSource:"MlxQmvFast4Pointers"};
export function checkExtracted(native:string,leans:Record<string,string>):void{
 const statements=extract(native);
 for(const [name,file]of Object.entries(owners)){
  const literal=leans[file]?.match(new RegExp(`def ${name} : String := "((?:[^"\\\\]|\\\\.)*)"`))?.[1];
  if(literal===undefined||JSON.parse(`"${literal}"`)!==statements[name])throw Error(`MLX qmv_fast literal drift: ${name}`);
 }
 // Explicit selected helper/template/native primitive boundary. These pins
 // bind the reviewed power-of-two helper interpretation and launch ABI.
 for(const fragment of ["return (bits == 3 || bits == 5) ? 8 : (bits == 6 ? 4 : wsize / bits);",
 "constexpr int power_of_2_bits = (bits & (bits - 1)) == 0;",
 "return power_of_2_bits ? (wsize / 8) : (bits == 5 ? 5 : 3);",
 "MLX_MTL_CONST int SIMD_SIZE = 32;","typedef float U;",
 "const int in_vec_size_w = in_vec_size * bytes_per_pack / pack_factor;",
 "const int in_vec_size_g = in_vec_size / group_size;",
 "const device uint8_t* ws = (const device uint8_t*)w;"])
  if(!native.includes(fragment))throw Error("MLX qmv_fast selected helper drift");
}
export function checkSource(native:string,leans:Record<string,string>):void{
 if(hash(native)!==sourceHash)throw Error("MLX qmv_fast native source drift");
 for(const [file,pin]of Object.entries(pins))if(hash(leans[file]??"")!==pin)throw Error("MLX qmv_fast proof drift");
 checkExtracted(native,leans);
}
function rejected(f:()=>void):void{let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("MLX qmv_fast mutation accepted");}
export async function checkMlxQmvFast4SourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const native=await Bun.file(resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/kernels/quantized.h`)).text();
 const leans=Object.fromEntries(await Promise.all(Object.keys(pins).map(async file=>[file,await Bun.file(resolve(root,`kernels/quantization/${file}.lean`)).text()])));
 await checkMlxQmvDot4SourceBinding(options);checkSource(native,leans);
 if(options.selfTest){
  for(const statement of Object.values(extract(native))){
   const bad=native.replaceAll(statement,statement.replace(/./,"!"));rejected(()=>checkSource(bad,leans));rejected(()=>checkExtracted(bad,leans));
  }
  for(const [name,file]of Object.entries(owners)){
   const bad={...leans,[file]:leans[file]!.replace(`def ${name} : String`, `def removed_${name} : String`)};
   rejected(()=>checkSource(native,bad));rejected(()=>checkExtracted(native,bad));
  }
  for(const file of Object.keys(pins))rejected(()=>checkSource(native,{...leans,[file]:leans[file]+"\n"}));
  rejected(()=>checkSource(native+"\n",leans));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxQmvFast4SourceBinding({selfTest:process.argv.includes("--self-test")});console.log("MLX qmv_fast four-bit source binding passed.");}
