import {resolve} from "node:path";
import {pathToFileURL} from "node:url";
const here=new URL("./",import.meta.url);
const reviewed:Record<string,string>={
  "AffineInput4Syntax.lean": "9d193a00939a6c3009722b2686ebae386d0db73f46021908616befbcbcdf6b89",
  "AffineInput4Source.lean": "ab12e36d1c2afc769bb34d086231559570479cb314330f5dc02042b44aa515a7",
  "AffineScratch4Source.lean": "9d0f4427b5d8e6314a0cc640db575f8c50d0db5407604671f308ea9cfb2a6e99"
};
const sourceHash="cb5bd05e24a13547f5672cbe661c0262bc18969eea62266b185fcc3e68a1d20b";
const hash=(s:string)=>new Bun.CryptoHasher("sha256").update(s).digest("hex");
function checkedHash(text:string,expected:string):void{if(hash(text)!==expected)throw Error("Reviewed affine input source changed");}
function rejects(action:()=>void):void{let failed=false;try{action();}catch{failed=true;}if(!failed)throw Error("Affine input mutation escaped validator");}
function unique(source:string,regex:RegExp):string{const matches=[...source.matchAll(regex)];if(matches.length!==1)throw Error("Missing/ambiguous input phase");return matches[0]![0];}
function selected(source:string):Record<string,string>{
 const start=source.indexOf("inline float mlxq_load_vector(");const end=source.indexOf("// float(q)",start);
 if(start<0||end<0)throw Error("Missing loader");const loader=source.slice(start,end);
 const branch=loader.indexOf("} else {");if(branch<0)throw Error("Missing four-bit branch");
 return {sourcePublish:unique(source,/ss\[c\] = mlxq_load_vector[^\n]*;\n    for \(int j = [^\n]*;/g),sourceInitializer:unique(loader,/float sum = [^;]*;/g),sourceReturn:unique(loader,/return sum;/g),
 sourceLoop:unique(loader.slice(branch),/for \(int i = [^\n]*\{\n(?:[^\n]*\n)*?    \}/g)};
}
function bind(source:string,lean:string):void{for(const[name,expected]of Object.entries(selected(source))){const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("(?:[^"\\\\]|\\\\.)*")$','gm'))];if(matches.length!==1||JSON.parse(matches[0]![1]!)!==expected)throw Error("Parsed input literal differs: "+name);}}
export async function checkAffineInput4SourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+"/"):new URL("../../../",here);
 const source=await Bun.file(new URL("packages/inference/src/kernels/quantization/affine-row.ts",root)).text();checkedHash(source,sourceHash);
 const lean=(await Bun.file(new URL("AffineInput4Syntax.lean",here)).text())+"\n"+(await Bun.file(new URL("AffineScratch4Source.lean",here)).text());for(const[path,expected]of Object.entries(reviewed))checkedHash(await Bun.file(new URL(path,here)).text(),expected);bind(source,lean);
 if(options.selfTest){rejects(()=>checkedHash(source+" ",sourceHash));for(const[path,expected]of Object.entries(reviewed)){const text=await Bun.file(new URL(path,here)).text();rejects(()=>checkedHash(text+" ",expected));}
 for(const[from,to]of [["float sum = 0;","float sum = 1;"],["i += 4) {","i += 2) {"],["sum += x[i] + x[i + 1] + x[i + 2] + x[i + 3];","sum += x[i] + x[i + 2] + x[i + 1] + x[i + 3];"],["x[i + 3] / 4096.0f","x[i + 3] / 2048.0f"],["x_thread[i + 2] = x[i + 2] / 256.0f","x_thread[i + 2] = x[i + 1] / 256.0f"],["return sum;","return 0;"],["xs[c * 16 + j] = t[j]","xs[c * 16 + j] = t[0]"]]){const changed=source.replace(from!,to!);if(changed===source)throw Error("Mutation did not apply");rejects(()=>bind(changed,lean));}
 rejects(()=>bind(source,lean.replace("/ 4096.0f","/ 2048.0f")));}
}
if(import.meta.main){await checkAffineInput4SourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Affine input source binding passed");}
