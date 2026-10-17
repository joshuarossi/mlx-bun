// Reviewed manual host/lifetime adapter: not a TS/C++ interpreter or proof
// of native lengths, custom-kernel allocation, callbacks, or hardware execution.
import {resolve} from "node:path";
import {pathToFileURL} from "node:url";
import checkBufferLeaseSourceBinding from "../../contracts/mlx/BufferLeaseSourceBinding";
const hashes:Record<string,string>={
  "../packages/inference/src/kernels/sampling/normalized-argmax.ts": "1578cff1ef678cbff3e2e9a754c6d7ba369e455885127e8d15c8b61f22a87740",
  ".lake/sources/mlx/1f8e74e3f12f31365464a6867c6579f0e9b29d85/mlx/backend/metal/logsumexp.cpp": "e629a1fa0b8744c7ee7913ccdb37caf6d22ad76aa6945282aa6adc4afdd316e7"
};
const entries:readonly(readonly[string,string,string])[]=[
  [
    "graphSource",
    "../packages/inference/src/kernels/sampling/normalized-argmax.ts",
    "function kernelGraph(logits: MlxArray): MlxArray {"
  ],
  [
    "selectionSource",
    "../packages/inference/src/kernels/sampling/normalized-argmax.ts",
    "export function normalizedArgmax(logits: MlxArray): MlxArray {"
  ],
  [
    "scalarSource",
    ".lake/sources/mlx/1f8e74e3f12f31365464a6867c6579f0e9b29d85/mlx/backend/metal/logsumexp.cpp",
    "void LogSumExp::eval_gpu(const std::vector<array>& inputs, array& out) {"
  ]
];
const reviewedLean="859e231dfab97afefc4f1c6e50d8336782c4eb91ec0ed6982cd5e3f01279005b";
const hash=(s:string)=>new Bun.CryptoHasher("sha256").update(s).digest("hex");
function checkedHash(text:string,expected:string,message:string):void{if(hash(text)!==expected)throw Error(message);}
function rejects(action:()=>void,message:string):void{let rejected=false;try{action();}catch{rejected=true;}if(!rejected)throw Error(message);}
function extract(text:string,marker:string):string{const at=text.indexOf(marker);if(at<0||text.indexOf(marker,at+1)>=0)throw Error("Missing/ambiguous source method");let depth=0;for(let i=at;i<text.length;i++){if(text[i]==="{")depth++;if(text[i]==="}"&&--depth===0)return text.slice(at,i+1);}throw Error("Unterminated source method");}
function bind(text:string,marker:string,literal:string):void{if(extract(text,marker)!==literal)throw Error("Source literal differs");}
export interface NormalizedArgmaxLeaseBindingOptions{proofsRoot?:string;leanSource?:string;selfTest?:boolean;}
export default async function checkNormalizedArgmaxLeaseSourceBinding(options:NormalizedArgmaxLeaseBindingOptions={}):Promise<void>{
 const here=new URL("./",import.meta.url);const root=options.proofsRoot?pathToFileURL(resolve(options.proofsRoot)+"/"):new URL("../../",here);
 await checkBufferLeaseSourceBinding({proofsRoot:root.pathname,selfTest:options.selfTest});
 const texts:Record<string,string>={};for(const[path,expected]of Object.entries(hashes)){const text=await Bun.file(new URL(path,root)).text();checkedHash(text,expected,"Reviewed source changed: "+path);texts[path]=text;}
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL("NormalizedArgmaxLeaseMemory.lean",here)).text();checkedHash(lean,reviewedLean,"Reviewed Lean translation changed");
 for(const[name,path,marker]of entries){const prefix="def "+name+" : String := r#\"";const at=lean.indexOf(prefix);if(at<0||lean.indexOf(prefix,at+1)>=0)throw Error("Missing/ambiguous source literal");const end=lean.indexOf("\"#",at+prefix.length);if(end<0)throw Error("Unterminated source literal");const literal=lean.slice(at+prefix.length,end);bind(texts[path]!,marker,literal);if(options.selfTest){rejects(()=>bind(texts[path]!,marker,literal+" "),"Literal mutation escaped");rejects(()=>bind(texts[path]!,marker+"__missing",literal),"Missing marker escaped");}}
 if(options.selfTest){for(const[path,text]of Object.entries(texts))rejects(()=>checkedHash(text+" ",hashes[path]!,"Reviewed source changed"),"Source hash mutation escaped");rejects(()=>checkedHash(lean+" ",reviewedLean,"Reviewed Lean translation changed"),"Lean hash mutation escaped");}
}
if(import.meta.main){const arg=(n:string)=>{const i=process.argv.indexOf(n);if(i<0)return undefined;const v=process.argv[i+1];if(!v||v.startsWith("--"))throw Error("Missing "+n);return v;};await checkNormalizedArgmaxLeaseSourceBinding({proofsRoot:arg("--proofs-root"),leanSource:arg("--lean-source"),selfTest:process.argv.includes("--self-test")});console.log("Normalized-argmax lease source binding passed");}
