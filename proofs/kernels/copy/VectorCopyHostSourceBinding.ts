// Trusted host byte/hash guard for the manual C++ translation in the Lean
// module. It is not a verified C++ parser, Metal compiler, or GPU execution.
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
const revision = "1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const hashes: Record<string,string> = {
  "gpu/copy.h": "ec5de8e2acaaa509aa4b1e42a6c6e478a189d8aae44a02f04b7d757ce8a2bc51",
  "gpu/copy.cpp": "9e6304129e8a2425aae4d913e8b9eefb2dac4bf8afac5c460cfc9331c6c48031",
  "common/copy.h": "2caa44885b43327747e53460f317e3107b9a0c012759a3c8f3d44095d1819ef0",
  "metal/copy.cpp": "35570b10905afb07f59ea16bf7abf840d290435fedbf716ca83cc7c51691e5d8",
  "metal/utils.h": "2b57319453758b5f7c776de946375701f97f84deabca02a1ef024f0153599c70",
  "metal/kernels/copy.metal": "ed8a579eb6fe6a14c36560d2c8b548baf99e66fa77d300fb4ad7554883820eba",
};
export interface HostBindingOptions {
  proofsRoot?: string;
  leanSource?: string;
  // The minimal old source pin omits this one small header. Root integration
  // may add it to that pin; until then supply its exact-revision local path.
  gpuHeader?: string;
  selfTest?: boolean;
}
function hash(text: string): string { return new Bun.CryptoHasher("sha256").update(text).digest("hex"); }
function wrapper(text: string): string {
  const marker = "void copy_gpu_inplace(\n    const array& in,\n    array& out,\n    CopyType ctype,\n    const Stream& s) {";
  const at = text.indexOf(marker);
  if (at<0 || text.indexOf(marker,at+1)>=0) throw Error("Expected one short copy_gpu_inplace definition");
  const end = text.indexOf("\n}",at);
  if (end<0) throw Error("Missing short wrapper closing brace");
  return text.slice(at,end+2);
}
function bind(source: string,literal: string): void {
  if (wrapper(source)!==literal) throw Error("Lean wrapperSource differs from pinned wrapper bytes");
}
export async function checkVectorCopyHostSourceBinding(options: HostBindingOptions = {}): Promise<void> {
  const here = new URL("./",import.meta.url);
  const root = options.proofsRoot ? pathToFileURL(`${resolve(options.proofsRoot)}/`) : new URL("../../",here);
  const sourceRoot = new URL(`.lake/sources/mlx/${revision}/mlx/backend/`,root);
  const texts: Record<string,string> = {};
  for (const [path,expected] of Object.entries(hashes)) {
    const file = path==="gpu/copy.h" && options.gpuHeader ? resolve(options.gpuHeader) : new URL(path,sourceRoot);
    if (!await Bun.file(file).exists()) throw Error(path==="gpu/copy.h"
      ? `Missing ${path}; supply --gpu-header with the exact revision header (SHA256 ${expected})`
      : `Missing pinned MLX source ${path}`);
    const text=await Bun.file(file).text();
    if(hash(text)!==expected) throw Error(`Pinned ${path} changed; review manual host translation`);
    texts[path]=text;
  }
  const lean=await Bun.file(options.leanSource ? resolve(options.leanSource) : new URL("VectorCopyHostSelection.lean",here)).text();
  const literals=[...lean.matchAll(/^def wrapperSource : String := r#"([\s\S]*?)"#/gm)];
  if(literals.length!==1) throw Error("Expected exactly one Lean wrapperSource literal");
  const literal=literals[0]![1]!;
  bind(texts["gpu/copy.cpp"]!,literal);
  if(options.selfTest) {
    const mutations=[texts["gpu/copy.cpp"]!.replace("out.strides(), 0, 0, ctype","out.strides(), 1, 0, ctype"),
      texts["gpu/copy.cpp"]!.replace("in.strides(), out.strides()","out.strides(), in.strides()")];
    for(const changed of mutations){let rejected=false;try{bind(changed,literal);}catch{rejected=true;}if(!rejected)throw Error("Wrapper mutation escaped binding");}
    let rejected=false;try{bind(texts["gpu/copy.cpp"]!,literal+" ");}catch{rejected=true;}if(!rejected)throw Error("Whitespace mutation escaped binding");
    for(const [path,text] of Object.entries(texts))if(hash(text+" ")===hashes[path])throw Error("Hash mutation escaped binding");
  }
}
function option(name: string): string|undefined {
  const i=process.argv.indexOf(name);if(i<0)return undefined;
  const value=process.argv[i+1];if(!value || value.startsWith("--"))throw Error(`Missing ${name} value`);return value;
}
if(import.meta.main){
  await checkVectorCopyHostSourceBinding({proofsRoot:option("--proofs-root"),leanSource:option("--lean-source"),gpuHeader:option("--gpu-header"),selfTest:process.argv.includes("--self-test")});
  console.log("Vector-copy host-source binding passed");
}
