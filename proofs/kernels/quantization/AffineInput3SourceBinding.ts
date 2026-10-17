import {checkAffinePreload4SourceBinding} from "./AffinePreload4SourceBinding";
import {resolve} from "node:path";
import {pathToFileURL} from "node:url";
const here=new URL("./",import.meta.url);
const sourceHash="cb5bd05e24a13547f5672cbe661c0262bc18969eea62266b185fcc3e68a1d20b";
const reviewed:Record<string,string>={
  "AffineInput3Syntax.lean": "4f28a43cae5cd80a5b8b2a0431face21489a2853df2382249c4c9def4dfbd4b3",
  "AffineInput3Source.lean": "a9fa9e425a8b3b6c5baa9f0f920fd47e0ae1f71067f5b2fa1b0dcb800b09239c",
  "AffinePreload3Source.lean": "fa586df9cc1e2c96d8f64dc8623aae5097cf66f06cf2b71e5675d6287359856b"
};
const hash=(s:string)=>new Bun.CryptoHasher("sha256").update(s).digest("hex");
function checkedHash(text:string,expected:string):void{if(hash(text)!==expected)throw Error("Reviewed three-bit input changed");}
function rejects(action:()=>void):void{let rejected=false;try{action();}catch{rejected=true;}if(!rejected)throw Error("Three-bit input mutation escaped validator");}
function unique(source:string,regex:RegExp):string{const matches=[...source.matchAll(regex)];if(matches.length!==1)throw Error("Missing/ambiguous input phase");return matches[0]![0];}
function selected(source:string):Record<string,string>{const start=source.indexOf("inline float mlxq_load_vector(");const end=source.indexOf("} else {",start);if(start<0||end<0)throw Error("Missing loader branch");const loader=source.slice(start,end);return {
 branchSource:unique(loader,/if \(bits == [^)]*\)/g),sourceLoop:unique(loader,/for \(int i = [^\n]*\{\n(?:[^\n]*\n)*?    \}/g)};}
function bind(source:string,lean:string):void{for(const[name,body]of Object.entries(selected(source))){const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("(?:[^"\\\\]|\\\\.)*")$','gm'))];if(matches.length!==1||JSON.parse(matches[0]![1]!)!==body)throw Error("Parsed three-bit input literal differs: "+name);}}
export async function checkAffineInput3SourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 await checkAffinePreload4SourceBinding(options);
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+"/"):new URL("../../../",here);
 const source=await Bun.file(new URL("packages/inference/src/kernels/quantization/affine-row.ts",root)).text();checkedHash(source,sourceHash);
 const lean=await Bun.file(new URL("AffineInput3Syntax.lean",here)).text();for(const[path,expected]of Object.entries(reviewed))checkedHash(await Bun.file(new URL(path,here)).text(),expected);bind(source,lean);
 if(options.selfTest){rejects(()=>checkedHash(source+" ",sourceHash));for(const[path,expected]of Object.entries(reviewed)){const text=await Bun.file(new URL(path,here)).text();rejects(()=>checkedHash(text+" ",expected));}
 for(const[from,to]of [["if (bits == 3)","if (bits == 4)"],["i += 8)","i += 4)"],["x[i + 3] + x[i + 4]","x[i + 4] + x[i + 3]"],["x[i + 2] / 64.0f","x[i + 2] / 32.0f"],["x_thread[i + 6] = x[i + 6] / 4.0f","x_thread[i + 6] = x[i + 5] / 4.0f"]]){const changed=source.replace(from!,to!);if(changed===source)throw Error("Mutation did not apply");rejects(()=>bind(changed,lean));}
 rejects(()=>bind(source,lean.replace("/ 128.0f","/ 64.0f")));}
}
if(import.meta.main){await checkAffineInput3SourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Three-bit input source binding passed");}
