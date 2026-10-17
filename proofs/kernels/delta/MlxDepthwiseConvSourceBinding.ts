import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
const revision="1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const metalHash="d0604f69e144ffb65dcfc99e6383880b6d2d61645fa73147f35230034a1cd874";
const hostHash="ffec76d32b453b232245978ee067fac70a0205981d9ff38311e19db422dc0758";
const pins:Record<string,string>={
  "MlxDepthwiseConvSyntax": "9ef9f35403055432d32ff15247f37327a8a769c38e3e4972fb1b4856d2f8a0b4",
  "MlxDepthwiseConvSource": "ac62fc73d871927235485537c9ae23fa0438a11db78ebd206ac93a146ea2e1eb",
  "MlxDepthwiseConvHostSource": "b3be9426dd966fef6a06d2bc06e98b5ea7f57f39e2a8930f0c971b058367b7e9",
  "MlxDepthwiseConvMemory": "136e1447b8dcb5d4e06f49659771267fcef1cb370049349c26ded36e192fa89f"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
export function extract(metal:string):Record<string,string>{
 const start=metal.indexOf("[[kernel]] void depthwise_conv_1d(");const end=metal.indexOf("#define instantiate_depthconv1d",start);
 if(start<0||end<0)throw Error("MLX depthwise conv source boundaries missing");
 const body=metal.slice(start,end);
 const take=(p:RegExp)=>{const s=body.match(p)?.[0];if(s===undefined)throw Error("MLX depthwise conv statement missing");return s;};
 return {pointersSource:take(/out \+=[\s\S]*?w \+= [^;]*;/),initialSource:take(/float acc =[^;]*;/),
  headerSource:take(/for \([^\n]*\{/),productSource:take(/acc \+= [^;]*;/),advanceSource:take(/in \+= strides\[1\];/),
  storeSource:take(/\*out = [^;]*;/)};
}
export function checkExtracted(metal:string,syntax:string):void{
 for(const[name,statement]of Object.entries(extract(metal))){
  const literal=syntax.match(new RegExp(`def ${name} : String := "((?:[^"\\\\]|\\\\.)*)"`))?.[1];
  if(literal===undefined||JSON.parse(`"${literal}"`)!==statement)throw Error(`MLX depthwise conv literal drift: ${name}`);
 }
}
const hostFragments=[
 "auto in = ensure_row_contiguous(in_pre, d, s);","auto wt = ensure_row_contiguous(wt_pre, d, s);",
 "bool is_idil_one = in_dilation[0] == 1;","int C = in.shape(2);","int O = wt.shape(0);",
 "if (is_idil_one && (groups == C) && groups == O && wt_strides[0] == 1 &&\n      wt_dilation[0] == 1 && padding[0] == 0 && !flip)",
 "depthwise_conv_1D_gpu(s, d, in, wt, out);","bool large = in.size() > INT32_MAX || in.data_size() > INT32_MAX;",
 '"depthwise_conv_1d_",','large ? "_large" : ""',"auto B = in.shape(0);","auto Tout = out.shape(1);","auto D = in.shape(2);","auto K = wt.shape(1);",
 "compute_encoder.set_bytes(K, 4);","MTL::Size grid_dims = MTL::Size(D, Tout, B);","compute_encoder.dispatch_threads(grid_dims, group_dims);",
];
export function checkHost(host:string):void{for(const f of hostFragments)if(!host.includes(f))throw Error("MLX depthwise conv reviewed host drift");}
export function checkSource(host:string,metal:string,leans:Record<string,string>):void{
 if(hash(host)!==hostHash||hash(metal)!==metalHash)throw Error("MLX depthwise conv native source drift");
 for(const[file,pin]of Object.entries(pins))if(hash(leans[file]??"")!==pin)throw Error("MLX depthwise conv proof drift");
 checkHost(host);checkExtracted(metal,leans.MlxDepthwiseConvSyntax!);
}
function rejected(f:()=>void):void{let fail=false;try{f();}catch{fail=true;}if(!fail)throw Error("MLX depthwise conv mutation accepted");}
export async function checkMlxDepthwiseConvSourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const [host,metal]=await Promise.all([Bun.file(resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/conv.cpp`)).text(),
 Bun.file(resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/kernels/conv.metal`)).text()]);
 const leans=Object.fromEntries(await Promise.all(Object.keys(pins).map(async f=>[f,await Bun.file(resolve(root,`kernels/delta/${f}.lean`)).text()])));
 checkSource(host,metal,leans);
 if(options.selfTest){
  for(const statement of Object.values(extract(metal))){const bad=metal.replaceAll(statement,statement.replace(/./,"!"));rejected(()=>checkSource(host,bad,leans));rejected(()=>checkExtracted(bad,leans.MlxDepthwiseConvSyntax!));}
  for(const f of hostFragments){const bad=host.replaceAll(f,f.replace(/./,"!"));rejected(()=>checkSource(bad,metal,leans));rejected(()=>checkHost(bad));}
  for(const file of Object.keys(pins))rejected(()=>checkSource(host,metal,{...leans,[file]:leans[file]+"\n"}));
  rejected(()=>checkExtracted(metal,leans.MlxDepthwiseConvSyntax!.replace("static_cast<float>(in[0])","in[0]")));
  rejected(()=>checkSource(host,metal+"\n",leans));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxDepthwiseConvSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("MLX depthwise conv1d source binding passed.");}
