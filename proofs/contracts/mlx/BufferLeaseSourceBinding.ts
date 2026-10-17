// Byte/hash binding for a manually reviewed ownership/cache translation.
// Not a C++ interpreter, shared_ptr implementation, native allocator proof,
// GPU completion proof, or physical RAM bound.
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
const revision="1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const hashes: Record<string,string>={
  "backend/common/buffer_cache.h": "a4b4ea74476ad681a9a5db2063ae3939108a60b0df2014b590338bd1cccf0205",
  "backend/metal/eval.cpp": "b03bd6c3aabda6f246a5d15ae21dc7e856d18f5af0d488c25e02e484718dce50",
  "backend/metal/allocator.cpp": "b317edbeda67afbafe63a4abe685c810b1fb0fd7d94f5f5ee17a7773bf97c65f",
  "array.h": "5c90807aa44226c557c5bda740bdc1732109810e8862697ad5d374092669db65"
};
const entries: readonly (readonly [string,string,string])[]=[
  [
    "cacheSource",
    "backend/common/buffer_cache.h",
    "  T* reuse_from_cache(size_t size) {"
  ],
  [
    "recycleSource",
    "backend/common/buffer_cache.h",
    "  void recycle_to_cache(T* buf) {"
  ],
  [
    "evalSource",
    "backend/metal/eval.cpp",
    "void eval(array& arr) {"
  ],
  [
    "freeSource",
    "backend/metal/allocator.cpp",
    "void MetalAllocator::free(Buffer buffer) {"
  ],
  [
    "dataSource",
    "array.h",
    "    ~Data() {"
  ]
];
const reviewedLean="ba5fd9ae60d62f00edcd45b4ea6ef7d24f23312dc126d3441d08b4ec97342bcb";
function hash(text:string):string{return new Bun.CryptoHasher("sha256").update(text).digest("hex");}
function checkedHash(text:string,expected:string,message:string):void{if(hash(text)!==expected)throw Error(message);}
function rejects(action:()=>void,message:string):void{let rejected=false;try{action();}catch{rejected=true;}if(!rejected)throw Error(message);}
function extract(text:string,marker:string):string{
  const at=text.indexOf(marker);
  if(at<0||text.indexOf(marker,at+1)>=0)throw Error("Missing/ambiguous native method: "+marker);
  let depth=0;
  for(let i=at;i<text.length;i++){if(text[i]==="{")depth++;if(text[i]==="}"&&--depth===0)return text.slice(at,i+1);}
  throw Error("Unterminated native method");
}
function bind(text:string,marker:string,literal:string):void{
  if(extract(text,marker)!==literal)throw Error("Native method differs from Lean source literal");
}
export interface BufferLeaseBindingOptions {proofsRoot?:string;leanSource?:string;selfTest?:boolean;}
export default async function checkBufferLeaseSourceBinding(options:BufferLeaseBindingOptions={}):Promise<void>{
  const here=new URL("./",import.meta.url);
  const root=options.proofsRoot?pathToFileURL(resolve(options.proofsRoot)+"/"):new URL("../../",here);
  const native=new URL(".lake/sources/mlx/"+revision+"/mlx/",root);
  const sources:Record<string,string>={};
  for(const [path,expected]of Object.entries(hashes)){
    const text=await Bun.file(new URL(path,native)).text();
    checkedHash(text,expected,"Pinned native source changed: "+path);
    sources[path]=text;
  }
  const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL("BufferLeaseMemory.lean",here)).text();
  checkedHash(lean,reviewedLean,"Reviewed Lean translation changed");
  for(const [name,path,marker]of entries){
    const prefix="def "+name+" : String := r#\"";
    const start=lean.indexOf(prefix);
    if(start<0||lean.indexOf(prefix,start+1)>=0)throw Error("Missing/ambiguous Lean source literal: "+name);
    const end=lean.indexOf("\"#",start+prefix.length);
    if(end<0)throw Error("Unterminated Lean source literal");
    const literal=lean.slice(start+prefix.length,end);
    bind(sources[path]!,marker,literal);
    if(options.selfTest){rejects(()=>bind(sources[path]!,marker,literal+" "),"Literal mutation escaped binding");rejects(()=>bind(sources[path]!,marker+"__missing",literal),"Missing marker escaped binding");}
  }
  if(options.selfTest){
    for(const [path,text]of Object.entries(sources))rejects(()=>checkedHash(text+" ",hashes[path]!,"Pinned native source changed"),"Native hash mutation escaped binding");
    rejects(()=>checkedHash(lean+" ",reviewedLean,"Reviewed Lean translation changed"),"Lean hash mutation escaped binding");
  }
}
if(import.meta.main){
  const arg=(name:string)=>{const i=process.argv.indexOf(name);if(i<0)return undefined;const v=process.argv[i+1];if(!v||v.startsWith("--"))throw Error("Missing "+name);return v;};
  await checkBufferLeaseSourceBinding({proofsRoot:arg("--proofs-root"),leanSource:arg("--lean-source"),selfTest:process.argv.includes("--self-test")});
  console.log("Buffer-lease source binding passed");
}
