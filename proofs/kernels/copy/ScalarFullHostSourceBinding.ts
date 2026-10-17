// Trusted exact-byte/hash check for the manual Full/Scalar host translation.
// This does not verify C++, broadcast metadata extraction, compilation, or GPU execution.
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { checkVectorCopyHostSourceBinding, type HostBindingOptions } from "./VectorCopyHostSourceBinding";
export interface FullBindingOptions extends HostBindingOptions { fullLeanSource?: string; }
const revision="1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const sources={
  "ops.cpp":"6eae219354d0f9be37a064cb327c863fc3a12dba6668fd61d428e8d09d6baaf2",
  "backend/gpu/primitives.cpp":"5a796463969b675181111b42a7aeadce8243a9d793ec7a00a30051d325bffe86",
};
const fragments=[
  ["fullEvalSource","backend/gpu/primitives.cpp","void Full::eval_gpu("],
  ["zerosSource","ops.cpp","array zeros(const Shape& shape, Dtype dtype"],
  ["fullShapeSource","ops.cpp","array full(Shape shape, array vals, Dtype dtype"],
  ["fullImplSource","ops.cpp","array full_impl("],
] as const;
function extract(text:string,marker:string):string {
  const start=text.indexOf(marker);if(start<0||text.indexOf(marker,start+1)>=0)throw Error(`Expected one ${marker}`);
  const open=text.indexOf(") {",start);if(open<0)throw Error("Missing function body delimiter");
  let depth=0;for(let i=open+2;i<text.length;i++){
    if(text[i]==="{")depth++;if(text[i]==="}"&&--depth===0)return text.slice(start,i+1);
  }throw Error("Unclosed audited function");
}
function bind(text:string,marker:string,literal:string):void {if(extract(text,marker)!==literal)throw Error("Lean Full source literal differs from pinned bytes");}
export async function checkScalarFullHostSourceBinding(options:FullBindingOptions={}):Promise<void>{
  await checkVectorCopyHostSourceBinding(options);
  const here=new URL("./",import.meta.url);
  const root=options.proofsRoot?pathToFileURL(`${resolve(options.proofsRoot)}/`):new URL("../../",here);
  const sourceRoot=new URL(`.lake/sources/mlx/${revision}/mlx/`,root);
  const texts:Record<string,string>={};
  for(const [path,expected] of Object.entries(sources)){
    const text=await Bun.file(new URL(path,sourceRoot)).text();
    if(new Bun.CryptoHasher("sha256").update(text).digest("hex")!==expected)throw Error(`Pinned ${path} changed`);
    texts[path]=text;
  }
  const lean=await Bun.file(options.fullLeanSource?resolve(options.fullLeanSource):new URL("ScalarFullHostSelection.lean",here)).text();
  for(const [name,path,marker]of fragments){
    const literals=[...lean.matchAll(new RegExp(`^def ${name} : String := r#"([\\s\\S]*?)"#`,"gm"))];
    if(literals.length!==1)throw Error(`Expected one ${name} literal`);
    const literal=literals[0]![1]!;
    if(name!=="fullEvalSource"&&!literal.includes("return "))throw Error("Incomplete extracted Full function body");
    bind(texts[path]!,marker,literal);
    if(options.selfTest){
      for(const changed of [literal+" ",literal.replace("{","{ ")]){
        let rejected=false;try{bind(texts[path]!,marker,changed);}catch{rejected=true;}
        if(!rejected)throw Error("Full byte mutation escaped binding");
      }
    }
  }
  if(options.selfTest){
    const original=texts["backend/gpu/primitives.cpp"]!;
    const changed=original.replace("if (in.data_size() == 1) {\n    ctype = CopyType::Scalar;","if (in.data_size() == 2) {\n    ctype = CopyType::Scalar;");
    if(changed===original)throw Error("Full predicate mutation did not apply");
    if(extract(changed,fragments[0][2])===extract(original,fragments[0][2]))throw Error("Full predicate mutation escaped extraction");
  }
}
function option(name:string):string|undefined{const i=process.argv.indexOf(name);if(i<0)return undefined;const v=process.argv[i+1];if(!v||v.startsWith("--"))throw Error(`Missing ${name}`);return v;}
if(import.meta.main){await checkScalarFullHostSourceBinding({proofsRoot:option("--proofs-root"),leanSource:option("--lean-source"),fullLeanSource:option("--full-lean-source"),gpuHeader:option("--gpu-header"),selfTest:process.argv.includes("--self-test")});console.log("Scalar Full host-source binding passed");}
